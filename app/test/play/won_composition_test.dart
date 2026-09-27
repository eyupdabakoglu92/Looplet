// F03-FE-WON — `ui-design.md` §16 "Won composition" + `architecture.md` §18
// "Won-sequence authority" (F03-QA-01). Evidence `F03.WIN-LAYOUT`:
//
//  * pure timeline / geometry rules (any screen size);
//  * the rect-testable visibility rule §16.5 on the real screen, winning rows
//    0–4 × {Perfect, non-Perfect} × {390×844, 440×956}, plus 393×852, OS text
//    scale 1.3, reduce-motion, the "panel never before T0+600 ms" rule and the
//    Retry exit.
import 'dart:math' as math;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/engine/engine_providers.dart';
import 'package:looplet_app/design/design.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/play/play_layout.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/play/play_session_providers.dart';
import 'package:looplet_app/play/play_session_screen.dart';
import 'package:looplet_app/play/widgets/docked_row.dart';
import 'package:looplet_app/play/widgets/puzzle_board.dart';
import 'package:looplet_app/play/won_composition.dart';
import 'package:looplet_app/rating/completion_panel.dart';
import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_engine/looplet_engine.dart';

// --- pure rules --------------------------------------------------------------

void main() {
  group('WonTimeline (regular)', () {
    const tl = WonTimeline.regular;
    double v(int ms) => ms / tl.totalMs;

    test(
      'win sequence first: nothing of the panel exists before T0+600 ms',
      () {
        expect(tl.dockStarted(v(599)), isFalse);
        expect(tl.panelStarted(v(599)), isFalse);
        expect(tl.scrim(v(599)), 0);
        expect(tl.panel(v(599)), 0);
        expect(tl.dock(v(599)), 0);
      },
    );

    test('dock 600–840, scrim 620–840, panel 680–940, then at rest', () {
      expect(tl.dockStarted(v(600)), isTrue);
      expect(tl.dock(v(840)), 1);
      expect(tl.scrim(v(620)), 0);
      expect(tl.scrim(v(840)), 1);
      expect(tl.panelStarted(v(680)), isTrue);
      expect(tl.panelStarted(v(679)), isFalse);
      expect(tl.panel(v(940)), 1);
      expect(tl.atRest(v(939)), isFalse);
      expect(tl.atRest(1), isTrue);
    });

    test('the panel is never ahead of the dock (row lands as it rises)', () {
      for (var ms = 0; ms <= tl.totalMs; ms += 10) {
        expect(tl.dock(v(ms)), greaterThanOrEqualTo(tl.panel(v(ms)) - 1e-9));
      }
    });
  });

  group('WonTimeline (reduced motion)', () {
    const tl = WonTimeline.reduced;
    double v(int ms) => ms / tl.totalMs;

    test('holds ≥ 300 ms static, then fades; at rest ≈ T0+660', () {
      expect(tl.reduceMotion, isTrue);
      expect(tl.dockStarted(v(299)), isFalse);
      expect(tl.dockStarted(v(300)), isTrue);
      expect(tl.panelStarted(v(459)), isFalse);
      expect(tl.panelStarted(v(460)), isTrue);
      expect(tl.totalMs, 660);
    });
  });

  group('WonGeometry (ui-design §16.3, D1: the row docks onto the goal)', () {
    // The D1 Loop Glass header: the rail tiles come from `PlayLayout`; the
    // won stack is the safe area (status bar 47 / 59 / 62, home indicator 34).
    const cases = <(String, Size, double)>[
      ('390×844', Size(390, 844), 47),
      ('393×852', Size(393, 852), 59),
      ('440×956', Size(440, 956), 62),
    ];
    for (final (name, size, top) in cases) {
      test('$name: tiles centred on the goal, panel at the shipped 0.36 H', () {
        final layout = PlayLayout(size);
        final tile = layout.board.tile;
        final g = WonGeometry.compute(
          screenHeight: size.height,
          stackTopGlobal: top,
          stackBottomGlobal: size.height - 34,
          railTopLocal: layout.railTop - top,
          railBottomLocal: layout.railBottom - top,
          tile: tile,
        );
        final unit = WonGeometry.unitHeight(tile);
        final dockTopG = top + g.dockTopLocal;
        expect(g.fits, isTrue);
        expect(g.dockScale, 1.0);
        expect(
          dockTopG + tile / 2,
          closeTo((layout.railTop + layout.railBottom) / 2, 1e-9),
        );
        // The panel keeps the shipped cap (≤ 64 % of H), floored 16 pt under
        // the docked unit — which binds by < 3 pt on 390/393-pt phones.
        final floor = dockTopG + unit + 16;
        expect(
          g.panelTopGlobal,
          closeTo(math.max(0.36 * size.height, floor), 1e-9),
        );
        expect(g.panelTopGlobal - 0.36 * size.height, lessThan(3));
        expect(
          g.panelMaxHeight,
          closeTo(size.height - 34 - g.panelTopGlobal, 1e-6),
        );
      });
    }

    test('a lower rail floors the panel under the docked unit', () {
      final g = WonGeometry.compute(
        screenHeight: 852,
        stackTopGlobal: 59,
        stackBottomGlobal: 818,
        railTopLocal: 250,
        railBottomLocal: 296,
        tile: 57,
      );
      final dockTopG = 59 + g.dockTopLocal;
      expect(dockTopG, closeTo(59 + 273 - 28.5, 1e-9));
      expect(
        g.panelTopGlobal,
        closeTo(dockTopG + WonGeometry.unitHeight(57) + 16, 1e-9),
      );
      expect(g.dockScale, 1.0);
    });

    test('a too-short frame scales the row (≥ 0.8) then reports no fit', () {
      final shrink = WonGeometry.compute(
        screenHeight: 500,
        stackTopGlobal: 0,
        stackBottomGlobal: 440,
        railTopLocal: 380,
        railBottomLocal: 420,
        tile: 58,
      );
      expect(shrink.dockScale, inInclusiveRange(0.8, 1.0));
      expect(shrink.dockScale, lessThan(1.0));
      expect(shrink.fits, isTrue);
      final none = WonGeometry.compute(
        screenHeight: 500,
        stackTopGlobal: 0,
        stackBottomGlobal: 420,
        railTopLocal: 380,
        railBottomLocal: 420,
        tile: 58,
      );
      expect(none.fits, isFalse);
    });
  });

  // --- on the real screen -----------------------------------------------------

  for (final size in const <Size>[Size(390, 844), Size(440, 956)]) {
    final label = '${size.width.toInt()}×${size.height.toInt()}';
    group('§16.5 visibility rule @ $label', () {
      for (var row = 0; row < 5; row++) {
        for (final perfect in <bool>[true, false]) {
          testWidgets(
            'winning row $row · ${perfect ? "Perfect" : "2★"}: docked row and '
            'seam clear of the panel',
            (tester) async {
              await _win(tester, size, row: row, perfect: perfect);
              _expectRestVisibility(tester, size);
            },
          );
        }
      }
    });
  }

  testWidgets('393×852, row 4 Perfect (QA reference device)', (tester) async {
    const size = Size(393, 852);
    await _win(tester, size, row: 4, perfect: true);
    _expectRestVisibility(tester, size);
  });

  testWidgets('OS text scale 1.3 at 390×844 (Perfect, row 4): same rules', (
    tester,
  ) async {
    const size = Size(390, 844);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _win(tester, size, row: 4, perfect: true);
    _expectRestVisibility(tester, size);
  });

  // D1: the Loop Glass header moved the rail down; the panel top is floored
  // under the dock (WonGeometry). Checked with the real fonts and the device
  // safe-area insets, where the stack is shortest.
  group('D1 dock on the device geometry', () {
    setUpAll(() async {
      for (final (family, asset) in <(String, String)>[
        ('SpaceGrotesk', 'assets/fonts/SpaceGrotesk.ttf'),
        ('Manrope', 'assets/fonts/Manrope.ttf'),
      ]) {
        final loader = FontLoader(family)..addFont(rootBundle.load(asset));
        await loader.load();
      }
    });

    for (final (name, size, top) in <(String, Size, double)>[
      ('16e 390×844', const Size(390, 844), 47),
      ('16 393×852', const Size(393, 852), 59),
      ('16 Pro Max 440×956', const Size(440, 956), 62),
    ]) {
      for (final scale in <double>[1.0, 1.3]) {
        for (final perfect in <bool>[true, false]) {
          testWidgets('$name @${scale}x · ${perfect ? "Perfect" : "2★"}: row '
              'docked on the goal, panel clear of it and ≤ 64 % H', (
            tester,
          ) async {
            tester.view.padding = FakeViewPadding(top: top, bottom: 34);
            tester.view.viewPadding = FakeViewPadding(top: top, bottom: 34);
            if (scale != 1.0) {
              tester.platformDispatcher.textScaleFactorTestValue = scale;
              addTearDown(
                tester.platformDispatcher.clearTextScaleFactorTestValue,
              );
            }
            await _win(tester, size, row: 4, perfect: perfect);
            _expectRestVisibility(tester, size);
            final panel = tester.getRect(find.byType(CompletionPanel));
            final density = tester
                .widget<CompletionPanel>(find.byType(CompletionPanel))
                .density;
            // ignore: avoid_print
            print(
              'won $name @${scale}x ${perfect ? "P" : "2*"}: panel '
              '${panel.height.toStringAsFixed(1)} pt (top '
              '${panel.top.toStringAsFixed(1)}), density ${density.name}',
            );
            expect(panel.bottom, lessThanOrEqualTo(size.height - 34 + 0.5));
          });
        }
      }
    }
  });

  testWidgets('F04 variants: first-clear → matched → newBest+Perfect, row 4', (
    tester,
  ) async {
    const size = Size(390, 844);
    await _win(tester, size, row: 4, perfect: false); // first clear, 2 moves
    _expectRestVisibility(tester, size);

    // Retry → the panel and the docked row leave, the board re-lights.
    await tester.tap(find.text('Yeniden'));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();
    expect(find.byType(CompletionPanel), findsNothing);
    expect(find.byType(DockedAnswerRow), findsNothing);
    expect(find.byType(LoopBackButton), findsOneWidget);

    await _playOut(tester, row: 4, perfect: false); // same 2 moves → matched
    _expectRestVisibility(tester, size);
    await tester.tap(find.text('Yeniden'));
    await tester.pumpAndSettle();

    await _playOut(tester, row: 4, perfect: true); // 1 move → new best
    _expectRestVisibility(tester, size);
  });

  // --- timeline on the real screen ---------------------------------------------

  testWidgets(
    'panel and scrim never appear before T0+600 ms; dock then panel',
    (tester) async {
      const size = Size(390, 844);
      await _boot(tester, size, row: 2);
      await _swipeRow(tester, 2);
      await _pumpToWonT0(tester);

      // Just before 600 ms: the win sequence only.
      await tester.pump(const Duration(milliseconds: 560));
      expect(find.byType(CompletionPanel), findsNothing);
      expect(find.byType(DockedAnswerRow), findsNothing);

      // Past the dock start and the panel start.
      await tester.pump(const Duration(milliseconds: 170));
      expect(find.byType(DockedAnswerRow), findsOneWidget);
      expect(find.byType(CompletionPanel), findsOneWidget);
      // The star reveal is held until the panel is at rest.
      expect(
        tester
            .widget<CompletionPanel>(find.byType(CompletionPanel))
            .startReveal,
        isFalse,
      );
      // The panel is not tappable while it is still sliding.
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CompletionPanel>(find.byType(CompletionPanel))
            .startReveal,
        isTrue,
      );
    },
  );

  for (final signal in <String, FakeAccessibilityFeatures>{
    'iOS reduceMotion': const FakeAccessibilityFeatures(reduceMotion: true),
    'Android disableAnimations': const FakeAccessibilityFeatures(
      disableAnimations: true,
    ),
  }.entries) {
    testWidgets('reduce motion (${signal.key}): static row, hold, then fade; '
        'same rest rules', (tester) async {
      const size = Size(390, 844);
      tester.platformDispatcher.accessibilityFeaturesTestValue = signal.value;
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      await _boot(tester, size, row: 3);
      await _swipeRow(tester, 3);
      await _pumpToWonT0(tester);

      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byType(CompletionPanel), findsNothing);
      expect(find.byType(DockedAnswerRow), findsNothing);
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // ≈ T0+350: dock fade
      expect(find.byType(DockedAnswerRow), findsOneWidget);
      expect(find.byType(CompletionPanel), findsNothing);
      await tester.pumpAndSettle();
      _expectRestVisibility(tester, size);
    });
  }
}

// --- helpers -------------------------------------------------------------------

/// 5×5 puzzle whose target `MASAL` is one `rowRight` away in [row]
/// (`A S A L M`); every other row is filler that can never spell it.
Puzzle _puzzleWinningInRow(int row) {
  const filler = <String>['BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'];
  var f = 0;
  return Puzzle(
    schemaVersion: 1,
    contentVersion: 'test',
    id: 'won-row-$row',
    puzzleType: PuzzleType.journey,
    journeyLevelNumber: 1,
    language: 'tr',
    grid: <String>[
      for (var r = 0; r < 5; r++) r == row ? 'ASALM' : filler[f++],
    ],
    targetWord: 'MASAL',
    lockedCells: const <GridCoord>{},
    frozenCells: const <GridCoord>{},
    columnMovesEnabled: false,
    optimalMoves: 1,
    difficultyScore: 1,
    difficultyLabel: DifficultyLabel.easy,
    difficultyBreakdown: const <String, num>{},
  );
}

Future<void> _boot(WidgetTester tester, Size size, {required int row}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final puzzle = _puzzleWinningInRow(row);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        wordValidatorProvider.overrideWith(
          (ref) async => const NeverValidWordValidator(),
        ),
        playSessionSetupProvider.overrideWith(
          (ref, args) async => PlaySessionSetup(
            puzzle: puzzle,
            validator: const NeverValidWordValidator(),
          ),
        ),
      ],
      child: MaterialApp(
        home: PlaySessionScreen(
          args: PlaySessionArgs(
            source: PuzzleSource.journey,
            debugPuzzleId: puzzle.id,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byType(PuzzleBoard), findsOneWidget);
}

Offset _rowStart(WidgetTester tester, int row) {
  final box = tester.getRect(find.byType(PuzzleBoard));
  return box.topLeft + BoardGeometry.forWidth(box.width).cellCenter(row, 0);
}

Future<void> _swipeRow(WidgetTester tester, int row) async {
  await tester.dragFrom(_rowStart(tester, row), const Offset(140, 0));
}

/// Advances frame by frame until the back control disappears — the `won` frame
/// (`T0`); the won timeline starts on the following frame.
Future<void> _pumpToWonT0(WidgetTester tester) async {
  for (var i = 0; i < 400; i++) {
    await tester.pump(const Duration(milliseconds: 4));
    if (find.byType(LoopBackButton).evaluate().isEmpty) return;
  }
  fail('the session never reached `won`');
}

/// Plays a full attempt and settles on the completion panel at rest.
Future<void> _playOut(
  WidgetTester tester, {
  required int row,
  required bool perfect,
}) async {
  if (!perfect) {
    // One wasted move on another row → 2 moves against optimal 1 (2★).
    await _swipeRow(tester, (row + 1) % 5);
    await tester.pumpAndSettle();
  }
  await _swipeRow(tester, row);
  await tester.pumpAndSettle();
  expect(find.byType(CompletionPanel), findsOneWidget);
}

Future<void> _win(
  WidgetTester tester,
  Size size, {
  required int row,
  required bool perfect,
}) async {
  await _boot(tester, size, row: row);
  await _playOut(tester, row: row, perfect: perfect);
}

/// `ui-design.md` §16.5 — the rect-testable visibility rule, at rest, with
/// the D1 adaptation (the row docks onto the goal; `won_composition.dart`).
void _expectRestVisibility(WidgetTester tester, Size size) {
  final w = tester.getRect(find.byType(DockedAnswerRow));
  final p = tester.getRect(find.byType(CompletionPanel));
  final tile = tester
      .widget<DockedAnswerRow>(find.byType(DockedAnswerRow))
      .tile;
  final railTiles = find.byType(RailTile);
  final railTop = tester.getRect(railTiles.first).top;
  final railBottom = tester.getRect(railTiles.first).bottom;

  // 1. Docked unit clear of the panel, on the goal, inside the screen.
  expect(w.overlaps(p), isFalse, reason: 'docked row $w overlaps panel $p');
  expect(
    p.top - w.bottom,
    greaterThanOrEqualTo(16 - 0.5),
    reason: 'clearance panel↔row',
  );
  expect(
    w.top + tile / 2,
    closeTo((railTop + railBottom) / 2, 0.5),
    reason: 'the answer tiles sit on the goal tiles',
  );
  // The goal tiles have faded out beneath the answer.
  final railFade = tester.widget<Opacity>(
    find.ancestor(of: railTiles.first, matching: find.byType(Opacity)).first,
  );
  expect(railFade.opacity, 0);
  expect(w.left, greaterThanOrEqualTo(0));
  expect(w.right, lessThanOrEqualTo(size.width));
  // The whole answer row is on screen: five glyph tiles inside the unit.
  expect(
    find.descendant(of: find.byType(DockedAnswerRow), matching: find.text('M')),
    findsOneWidget,
  );

  // 2. Panel cap: top at/below 0.36 H.
  expect(p.top, greaterThanOrEqualTo(0.36 * size.height - 0.5));

  // 4. The winning word left the board: ghost cells, no lit tile of it.
  // 5. Controls: Retry / Next / Close are inside the screen and ≥ 44 pt tall.
  for (final label in <String>['Yeniden', 'Kapat']) {
    final r = tester.getRect(
      find
          .ancestor(
            of: find.text(label),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    expect(r.height, greaterThanOrEqualTo(44 - 0.5), reason: '$label height');
    expect(r.bottom, lessThanOrEqualTo(size.height));
    expect(r.top, greaterThanOrEqualTo(p.top));
  }
}
