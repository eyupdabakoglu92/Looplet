// F05-FE.TUTORIAL — the levels 4–6 column micro-tutorial (`architecture.md §9`,
// `ui-design.md §6`). Shown iff a Journey level in 4..6 with the `kv` ack unset;
// action-gated on a committed column-axis drag; the ack persists only when the
// gate is satisfied, not merely by opening the level.

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/design/design.dart';
import 'package:looplet_app/engine/engine_providers.dart';
import 'package:looplet_app/journey/column_tutorial_overlay.dart';
import 'package:looplet_app/journey/journey_content.dart';
import 'package:looplet_app/journey/journey_tutorial.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/play/play_layout.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/play/play_session_screen.dart';
import 'package:looplet_app/play/widgets/puzzle_board.dart';
import 'package:looplet_engine/looplet_engine.dart';

const String _hint = 'Sütunları da kaydırabilirsin — yukarı ya da aşağı.';

Map<String, Object?> _level4Json() => <String, Object?>{
  'schemaVersion': 1,
  'contentVersion': 'test',
  'id': 'journey-tr-04',
  'puzzleType': 'journey',
  'journeyLevelNumber': 4,
  'language': 'tr',
  // No single row/column move forms MASAL (letters never align in one line).
  'grid': const <String>['BKNRT', 'SMVYZ', 'ZCDFG', 'HJKLP', 'RSTVY'],
  'targetWord': 'MASAL',
  'lockedCells': const <String>[],
  'frozenCells': const <String>[],
  'columnMovesEnabled': true,
  'optimalMoves': 3,
  'difficultyScore': 1,
  'difficultyLabel': 'easy',
  'difficultyBreakdown': const <String, Object?>{},
};

// A band 1–3 level (rows only) — used to prove the tutorial does NOT show
// outside the 4–6 band.
Map<String, Object?> _level1Json() => <String, Object?>{
  'schemaVersion': 1,
  'contentVersion': 'test',
  'id': 'journey-tr-01',
  'puzzleType': 'journey',
  'journeyLevelNumber': 1,
  'language': 'tr',
  'grid': const <String>['ASALM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
  'targetWord': 'MASAL',
  'lockedCells': const <String>[],
  'frozenCells': const <String>[],
  'columnMovesEnabled': false,
  'optimalMoves': 1,
  'difficultyScore': 1,
  'difficultyLabel': 'easy',
  'difficultyBreakdown': const <String, Object?>{},
};

Map<String, Object?> _manifestJson() => <String, Object?>{
  'schemaVersion': 1,
  'contentVersion': 'test',
  'lang': 'tr',
  'mode': 'smoke',
  'levels': <Map<String, Object?>>[
    for (var n = 1; n <= 4; n++)
      <String, Object?>{
        'n': n,
        'id': 'journey-tr-${n.toString().padLeft(2, '0')}',
        'asset': 'tr/journey-tr-${n.toString().padLeft(2, '0')}.json',
        'difficultyLabel': 'easy',
      },
  ],
};

class _MapAssetSource implements JourneyAssetSource {
  _MapAssetSource(this._files);
  final Map<String, String> _files;
  @override
  Future<String> readString(String assetKey) async {
    final v = _files[assetKey];
    if (v == null) throw StateError('missing asset "$assetKey"');
    return v;
  }
}

final JourneyAssetSource _source = _MapAssetSource(<String, String>{
  'tr/journey_manifest_tr.json': jsonEncode(_manifestJson()),
  'tr/journey-tr-01.json': jsonEncode(_level1Json()),
  'tr/journey-tr-04.json': jsonEncode(_level4Json()),
});

Widget _app(AppDatabase db, {int level = 4}) => ProviderScope(
  overrides: <Override>[
    appDatabaseProvider.overrideWithValue(db),
    wordValidatorProvider.overrideWith(
      (ref) async => const NeverValidWordValidator(),
    ),
    journeyAssetSourceProvider.overrideWithValue(_source),
  ],
  child: MaterialApp(
    home: PlaySessionScreen(
      args: PlaySessionArgs(source: PuzzleSource.journey, journeyLevel: level),
    ),
  ),
);

Offset _cell(WidgetTester tester, int row, int col) {
  final box = tester.getRect(find.byType(PuzzleBoard));
  return box.topLeft + BoardGeometry.forWidth(box.width).cellCenter(row, col);
}

void _reduceMotion(WidgetTester tester) {
  // The overlay's gesture ghost `repeat()`s unless animations are disabled;
  // switching it to its static pose keeps `pumpAndSettle` from timing out.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _boot(WidgetTester tester, AppDatabase db, {int level = 4}) async {
  await tester.pumpWidget(_app(db, level: level));
  await tester.pumpAndSettle();
  expect(find.byType(PuzzleBoard), findsOneWidget);
}

void main() {
  testWidgets('shows on level 4, ignores a row drag, clears + persists on a '
      'column drag', (tester) async {
    _reduceMotion(tester);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await _boot(tester, db);

    expect(find.byType(ColumnTutorialOverlay), findsOneWidget);
    expect(find.text(_hint), findsOneWidget);

    // A row-axis drag must not satisfy the gate.
    await tester.dragFrom(_cell(tester, 2, 0), const Offset(140, 0));
    await tester.pumpAndSettle();
    expect(find.byType(ColumnTutorialOverlay), findsOneWidget);
    expect(
      await JourneyTutorialRepo(db).isColumnTutorialAcknowledged(),
      isFalse,
    );

    // A column-axis drag clears the overlay and writes the `kv` ack.
    await tester.dragFrom(_cell(tester, 2, 2), const Offset(0, 140));
    await tester.pumpAndSettle();
    expect(find.byType(ColumnTutorialOverlay), findsNothing);
    expect(
      await JourneyTutorialRepo(db).isColumnTutorialAcknowledged(),
      isTrue,
    );
  });

  testWidgets('an existing ack suppresses the overlay entirely', (
    tester,
  ) async {
    _reduceMotion(tester);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await JourneyTutorialRepo(db).acknowledgeColumnTutorial();

    await _boot(tester, db);
    expect(find.byType(ColumnTutorialOverlay), findsNothing);
  });

  testWidgets('not shown for a Journey level outside the 4–6 band', (
    tester,
  ) async {
    _reduceMotion(tester);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await _boot(tester, db, level: 1);
    expect(find.byType(ColumnTutorialOverlay), findsNothing);
    expect(
      await JourneyTutorialRepo(db).isColumnTutorialAcknowledged(),
      isFalse,
    );
  });

  testWidgets('force-quit before the gated move → re-shows on the next 4–6 '
      'entry (AC11)', (tester) async {
    _reduceMotion(tester);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    // First entry: overlay shown, player quits without a column move.
    await _boot(tester, db, level: 4);
    expect(find.byType(ColumnTutorialOverlay), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(
      await JourneyTutorialRepo(db).isColumnTutorialAcknowledged(),
      isFalse,
    );

    // Second entry (same guest / DB): the overlay re-shows.
    await _boot(tester, db, level: 4);
    expect(find.byType(ColumnTutorialOverlay), findsOneWidget);

    // …and a column drag now clears it for good.
    await tester.dragFrom(_cell(tester, 2, 2), const Offset(0, 140));
    await tester.pumpAndSettle();
    expect(find.byType(ColumnTutorialOverlay), findsNothing);
    expect(
      await JourneyTutorialRepo(db).isColumnTutorialAcknowledged(),
      isTrue,
    );

    // Third entry: acknowledged → never again.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await _boot(tester, db, level: 4);
    expect(find.byType(ColumnTutorialOverlay), findsNothing);
  });

  // F03-QA-04: the gesture ghost loops unless the OS asks for reduced motion —
  // iOS reports that as `reduceMotion`, Android as `disableAnimations`.
  Future<void> bootWith(
    WidgetTester tester,
    FakeAccessibilityFeatures features,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = features;
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(_app(db));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ColumnTutorialOverlay), findsOneWidget);
  }

  testWidgets('control — no OS signal: the gesture ghost loops', (
    tester,
  ) async {
    await bootWith(tester, const FakeAccessibilityFeatures());
    await tester.pump(const Duration(seconds: 6));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final signal in <String, FakeAccessibilityFeatures>{
    'iOS reduceMotion': const FakeAccessibilityFeatures(reduceMotion: true),
    'Android disableAnimations': const FakeAccessibilityFeatures(
      disableAnimations: true,
    ),
  }.entries) {
    testWidgets('${signal.key}: the gesture ghost is static', (tester) async {
      await bootWith(tester, signal.value);
      await tester.pumpAndSettle(); // throws if the ghost still loops
    });
  }

  group('D1 overlay (F03 ui-design §4–§7; A-1, A-6)', () {
    Future<AppDatabase> bootAt(
      WidgetTester tester,
      Size size, {
      double textScale = 1,
      bool reduced = false,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      if (textScale != 1) {
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      if (reduced) {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(reduceMotion: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
      }
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      await tester.pumpWidget(_app(db));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(ColumnTutorialOverlay), findsOneWidget);
      return db;
    }

    double ghostOpacity(WidgetTester tester) => tester
        .widget<Opacity>(
          find
              .ancestor(
                of: find.byType(TutorialGhost),
                matching: find.byType(Opacity),
              )
              .first,
        )
        .opacity;

    double pillOpacity(WidgetTester tester) => tester
        .widget<Opacity>(
          find
              .ancestor(
                of: find.byType(HintPill),
                matching: find.byType(Opacity),
              )
              .first,
        )
        .opacity;

    for (final (name, size) in <(String, Size)>[
      ('390×844', const Size(390, 844)),
      ('393×852', const Size(393, 852)),
      ('440×956', const Size(440, 956)),
    ]) {
      for (final scale in <double>[1.0, 1.3, 3.12]) {
        testWidgets('$name, OS text ${scale}x: the pill sits between the board '
            'and the HUD with ≥ 4 pt clearance', (tester) async {
          for (final (family, asset) in <(String, String)>[
            ('SpaceGrotesk', 'assets/fonts/SpaceGrotesk.ttf'),
            ('Manrope', 'assets/fonts/Manrope.ttf'),
          ]) {
            final loader = FontLoader(family)..addFont(rootBundle.load(asset));
            await loader.load();
          }
          await bootAt(tester, size, textScale: scale, reduced: true);
          expect(tester.takeException(), isNull);

          final pill = tester.getRect(find.byType(HintPill));
          final board = tester.getRect(find.byType(BoardCard));
          final undo = tester.getRect(find.byType(UndoPill));
          final restart = tester.getRect(find.byType(GlassIconButton));
          final above = pill.top - board.bottom;
          final below = undo.top - pill.bottom;
          // ignore: avoid_print
          print(
            'hint-pill $name @${scale}x: h ${pill.height.toStringAsFixed(1)} '
            'above ${above.toStringAsFixed(1)} below ${below.toStringAsFixed(1)}',
          );
          expect(above, greaterThanOrEqualTo(4), reason: 'clear of the board');
          expect(below, greaterThanOrEqualTo(4), reason: 'clear of the HUD');
          expect(pill.overlaps(undo), isFalse);
          expect(pill.overlaps(restart), isFalse);
          expect((above - below).abs(), lessThan(0.5), reason: 'centred');
          // The sparkle is hidden above 1.15× so the sentence keeps two lines.
          final sparkle = find.descendant(
            of: find.byType(HintPill),
            matching: find.byType(LoopIconView),
          );
          expect(sparkle, scale > 1.15 ? findsNothing : findsOneWidget);
        });
      }
    }

    testWidgets('undo and restart stay usable under the tutorial', (
      tester,
    ) async {
      await bootAt(tester, const Size(393, 852), reduced: true);
      await tester.dragFrom(_cell(tester, 2, 0), const Offset(140, 0));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.byType(UndoPill));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
      await tester.dragFrom(_cell(tester, 2, 0), const Offset(140, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GlassIconButton));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
      expect(find.byType(ColumnTutorialOverlay), findsOneWidget);
    });

    testWidgets('the ghost hides on touch-down and returns after 600 ms idle '
        '(A-6)', (tester) async {
      await bootAt(tester, const Size(393, 852));
      expect(ghostOpacity(tester), 1);

      final g = await tester.startGesture(_cell(tester, 2, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 130));
      expect(ghostOpacity(tester), 0, reason: 'hidden under the finger');

      await g.moveBy(const Offset(20, 0));
      await g.moveBy(const Offset(120, 0));
      await tester.pump(const Duration(milliseconds: 50));
      expect(ghostOpacity(tester), 0, reason: 'stays hidden while dragging');
      await g.up(); // a row move: the tutorial stays
      // Frame by frame through the 190 ms settle, then idle.
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(ghostOpacity(tester), 0, reason: 'not back right after release');
      await tester.pump(const Duration(milliseconds: 250)); // ≈ 380 ms idle
      expect(ghostOpacity(tester), 0, reason: 'not back before 600 ms idle');
      await tester.pump(const Duration(milliseconds: 300)); // the timer fires
      await tester.pump(const Duration(milliseconds: 200)); // 160 ms fade-in
      expect(ghostOpacity(tester), closeTo(1, 1e-9));
      expect(find.byType(ColumnTutorialOverlay), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('the first column move fades the pill out over 160 ms', (
      tester,
    ) async {
      final db = await bootAt(tester, const Size(393, 852));
      expect(pillOpacity(tester), 1);
      await tester.dragFrom(_cell(tester, 2, 2), const Offset(0, 140));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      expect(pillOpacity(tester), inExclusiveRange(0.0, 1.0));
      expect(
        await JourneyTutorialRepo(db).isColumnTutorialAcknowledged(),
        isTrue,
        reason: 'the ack is written at the gated move, not after the fade',
      );
      await tester.pump(const Duration(milliseconds: 120));
      expect(find.byType(ColumnTutorialOverlay), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('the hint is announced once; the ghost is excluded', (
      tester,
    ) async {
      final announced = <String>[];
      tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(SystemChannels.accessibility, (
            message,
          ) async {
            final map = message! as Map<Object?, Object?>;
            if (map['type'] == 'announce') {
              announced.add(
                (map['data']! as Map<Object?, Object?>)['message']! as String,
              );
            }
            return null;
          });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(
              SystemChannels.accessibility,
              null,
            ),
      );
      await bootAt(tester, const Size(393, 852), reduced: true);
      await tester.dragFrom(_cell(tester, 2, 0), const Offset(140, 0));
      await tester.pumpAndSettle();
      expect(announced.where((m) => m == _hint), hasLength(1));
      final ghost = find.byType(TutorialGhost);
      expect(
        find.descendant(of: ghost, matching: find.byType(ExcludeSemantics)),
        findsWidgets,
      );
    });
  });
}
