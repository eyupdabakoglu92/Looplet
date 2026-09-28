// F03-FE-D2 — the win sequence, the board → result transition and the retry
// transition (F03 architecture §20.3 (1)–(2), (7), §20.7 C2; `ui-design.md`
// §16.5 and the §16.11.1 acceptance list items 1–7, 13, 16).
//
// * pure timeline bounds (any device);
// * on the real screen, frame by frame from T0 (the settle frame): nothing of
//   the result before T0 + 600, the row's displacement from its own board
//   cells ≤ 0.5 pt before 600 (C2), chrome gone by 720, rest at 940 / 660,
//   the star pop, taps dropped before rest, system back, background / kill
//   mid-sequence, and the retry transition at 360 / 160.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/design/design.dart';
import 'package:looplet_app/persistence/active_session_snapshot.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/repositories/active_session_repo.dart';
import 'package:looplet_app/persistence/repositories/journey_progress_repo.dart';
import 'package:looplet_app/persistence/repositories/personal_best_repo.dart';
import 'package:looplet_app/persistence/repositories/player_repo.dart';
import 'package:looplet_app/play/play_layout.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/play/widgets/puzzle_board.dart';
import 'package:looplet_app/play/widgets/result_view.dart';
import 'package:looplet_app/play/widgets/travelling_tile.dart';
import 'package:looplet_app/play/win_timeline.dart';
import 'package:looplet_content/looplet_content.dart';

import 'play_test_support.dart';

// --- fixtures ---------------------------------------------------------------

const List<String> _filler = <String>['BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'];

/// `MASAL` is one `rowRight` away in [row] (`A S A L M`); optimal 1.
Puzzle _rowWin(int row, {String id = 'd2-row'}) {
  var f = 0;
  return _puzzle(
    id: '$id-$row',
    grid: <String>[
      for (var r = 0; r < 5; r++) r == row ? 'ASALM' : _filler[f++],
    ],
    columns: false,
  );
}

/// Row [row] reads `M A S A B` with its `A` and `S` locked (C-11); a column-4
/// shift down brings the `L` from the row above into it → `MASAL`.
Puzzle _lockedRowWin(int row) {
  var f = 0;
  final grid = <String>[
    for (var r = 0; r < 5; r++) r == row ? 'MASAB' : _filler[f++],
  ];
  final above = (row + 4) % 5;
  grid[above] = '${grid[above].substring(0, 4)}L';
  return _puzzle(
    id: 'd2-locked-$row',
    grid: grid,
    columns: true,
    locked: <GridCoord>{GridCoord(row, 1), GridCoord(row, 2)},
  );
}

Puzzle _puzzle({
  required String id,
  required List<String> grid,
  required bool columns,
  Set<GridCoord> locked = const <GridCoord>{},
}) => Puzzle(
  schemaVersion: 1,
  contentVersion: 'test',
  id: id,
  puzzleType: PuzzleType.journey,
  journeyLevelNumber: 1,
  language: 'tr',
  grid: grid,
  targetWord: 'MASAL',
  lockedCells: locked,
  frozenCells: const <GridCoord>{},
  columnMovesEnabled: columns,
  optimalMoves: 1,
  difficultyScore: 1,
  difficultyLabel: DifficultyLabel.easy,
  difficultyBreakdown: const <String, num>{},
);

Future<AppDatabase> _boot(
  WidgetTester tester,
  Puzzle puzzle, {
  Size size = kIphone16,
  int? level,
}) async {
  setDevice(tester, size, top: 59, bottom: 34);
  return bootPlay(
    tester,
    puzzle: puzzle,
    args: PlaySessionArgs(
      source: PuzzleSource.journey,
      journeyLevel: level,
      debugPuzzleId: level == null ? puzzle.id : null,
    ),
  );
}

Future<void> _swipeRow(WidgetTester tester, int row) =>
    tester.dragFrom(cellCenter(tester, row, 0), const Offset(140, 0));

Future<void> _swipeColumnDown(WidgetTester tester, int col) =>
    tester.dragFrom(cellCenter(tester, 2, col), const Offset(0, 140));

/// Advances frame by frame to T0 — the settle frame, the first one that
/// draws the travelling answer row. Time since T0 then equals the pumped time.
Future<void> _toT0(WidgetTester tester) async {
  for (var i = 0; i < 400; i++) {
    await tester.pump(const Duration(milliseconds: 4));
    if (find.byType(TravellingTile).evaluate().isNotEmpty) return;
  }
  fail('the session never reached `won`');
}

ResultView _result(WidgetTester tester) =>
    tester.widget<ResultView>(find.byType(ResultView));

/// Every opacity of the result on this frame.
List<double> _resultOpacities(ResultMotion m) => <double>[
  m.back,
  m.head,
  m.sub,
  m.stats,
  m.cta,
  m.radial,
  m.answer,
];

/// The winning row's board cells, in screen coordinates.
List<Rect> _boardCells(Size size, int row) {
  final layout = PlayLayout(size);
  return <Rect>[
    for (var c = 0; c < 5; c++)
      layout.board.cellRect(row, c).shift(layout.boardRect.topLeft),
  ];
}

List<Rect> _travelling(WidgetTester tester) {
  final tiles = find.byType(TravellingTile);
  return <Rect>[
    for (var i = 0; i < tiles.evaluate().length; i++)
      tester.getRect(tiles.at(i)),
  ];
}

double _maxDisplacement(List<Rect> a, List<Rect> b) {
  var d = 0.0;
  for (var i = 0; i < a.length; i++) {
    for (final v in <double>[
      (a[i].left - b[i].left).abs(),
      (a[i].top - b[i].top).abs(),
      (a[i].width - b[i].width).abs(),
      (a[i].height - b[i].height).abs(),
    ]) {
      if (v > d) d = v;
    }
  }
  return d;
}

void _reduceMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(reduceMotion: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

void main() {
  // --- pure timeline ---------------------------------------------------------

  group('WinTimeline (regular)', () {
    const tl = WinTimeline.regular;

    test('nothing outside the board before 600; the row does not glide', () {
      for (var ms = 0.0; ms < 600; ms += 1) {
        expect(tl.glide(ms), 0, reason: 'glide at $ms');
        expect(tl.radial(ms), 0, reason: 'radial at $ms');
        expect(tl.resultRow(ms), 0, reason: 'result row at $ms');
        for (final b in ResultBand.values) {
          expect(tl.band(b, ms).opacity, 0, reason: '$b at $ms');
        }
      }
    });

    test('fill L→R 30 ms apart, 90 ms each; the whole row lime by 210', () {
      expect(tl.fill(0, 0), 0);
      expect(tl.fill(45, 0), closeTo(0.5, 1e-9));
      expect(tl.fill(29, 1), 0);
      expect(tl.fill(90, 0), 1);
      expect(tl.fill(209, 4), lessThan(1));
      for (var i = 0; i < 5; i++) {
        expect(tl.fill(210, i), 1);
      }
    });

    test('dim to 50 % by 200, chrome and board at 0 by 720', () {
      expect(tl.chrome(0), 1);
      expect(tl.chrome(200), closeTo(0.5, 1e-9));
      expect(tl.chrome(599), closeTo(0.5, 1e-9));
      expect(tl.chrome(660), inExclusiveRange(0, 0.5));
      expect(tl.chrome(720), 0);
    });

    test('one bloom 100–450 (0 → 1 → .55), out with the board by 720', () {
      expect(tl.bloom(99), 0);
      expect(tl.bloom(240), closeTo(1, 1e-9));
      expect(tl.bloom(450), closeTo(0.55, 1e-9));
      expect(tl.bloom(599), closeTo(0.55, 1e-9));
      expect(tl.bloom(720), 0);
    });

    test('glide 600–840, result bands in order, rest at 940', () {
      expect(tl.glide(840), 1);
      expect(tl.resultRow(839), 0);
      expect(tl.resultRow(840), 1);
      expect(tl.band(ResultBand.head, 700).opacity, 0);
      expect(tl.band(ResultBand.head, 860).opacity, 1);
      expect(tl.band(ResultBand.head, 700).rise, 12);
      expect(tl.band(ResultBand.sub, 740).opacity, 0);
      expect(tl.band(ResultBand.stats, 780).opacity, 0);
      expect(tl.band(ResultBand.cta, 820).opacity, 0);
      for (final b in ResultBand.values) {
        expect(tl.band(b, 940), (opacity: 1.0, rise: 0.0));
      }
      expect(tl.restMs, 940);
      expect(tl.atRest(939), isFalse);
      expect(tl.atRest(940), isTrue);
    });

    test('stars pop 940 / 1050 / 1160, done by 1300', () {
      expect(tl.starRevealMs(940), 0);
      expect(tl.starRevealMs(1300), 360);
      expect(StarRow.revealDuration.inMilliseconds, 360);
      expect(tl.endMs, 1300);
    });
  });

  group('WinTimeline (reduced)', () {
    const tl = WinTimeline.reduced;

    test('row lime and board at 50 % at T0; hold to 300', () {
      for (var i = 0; i < 5; i++) {
        expect(tl.fill(0, i), 1);
      }
      expect(tl.chrome(0), 0.5);
      expect(tl.chrome(300), 0.5);
      expect(tl.bloom(200), 0);
      expect(tl.glide(500), 0);
      expect(tl.resultRow(300), 0);
      expect(tl.overlayRowOpacity(300), 1);
    });

    test('cross-fade 300–460, content 460–660, rest 660, stars static', () {
      expect(tl.resultRow(380), closeTo(0.5, 1e-9));
      expect(tl.overlayRowOpacity(380), closeTo(0.5, 1e-9));
      expect(tl.chrome(460), 0);
      expect(tl.radial(460), 1);
      expect(tl.band(ResultBand.head, 460).opacity, 0);
      expect(tl.band(ResultBand.cta, 660).opacity, 1);
      expect(tl.band(ResultBand.head, 560).rise, 0);
      expect(tl.restMs, 660);
      expect(tl.starRevealMs(660), isNull);
    });
  });

  group('RetryTimeline', () {
    test('regular: out 0–140 with an 8·s drop, flight 0–300, Play 160–360', () {
      const rt = RetryTimeline.regular;
      expect(rt.resultOut(140), (opacity: 0.0, rise: 8.0));
      expect(rt.flight(300), 1);
      expect(rt.flightLime(100), 1);
      expect(rt.flightLime(300), 0);
      expect(rt.playIn(160), 0);
      expect(rt.playIn(360), 1);
      expect(rt.boardRise(160), 10);
      expect(rt.restMs, 360);
      expect(rt.flying(359), isTrue);
      expect(rt.flying(360), isFalse);
    });

    test('reduced: a dip — out 0–80, in 80–160, no flight', () {
      const rt = RetryTimeline.reduced;
      expect(rt.resultOut(80).opacity, 0);
      expect(rt.playIn(80), 0);
      expect(rt.playIn(160), 1);
      expect(rt.flying(10), isFalse);
      expect(rt.restMs, 160);
    });
  });

  // --- the real screen, frame by frame -----------------------------------------

  for (final row in <int>[0, 2, 4]) {
    testWidgets('row $row: nothing of the result before T0 + 600; the row '
        'holds its board cells (C2 ≤ 0.5 pt); chrome at 0 by 720; rest at '
        '940', (tester) async {
      await _boot(tester, _rowWin(row));
      await _swipeRow(tester, row);
      await _toT0(tester);
      final cells = _boardCells(kIphone16, row);

      var ms = 0;
      var worst = 0.0;
      while (ms < 600) {
        // Mounted (at opacity 0) only inside the static hold, from 450.
        final mounted = find.byType(ResultView).evaluate().isNotEmpty;
        expect(mounted, ms >= 450, reason: 'result mounted at T0 + $ms');
        if (mounted) {
          final m = _result(tester).motion;
          for (final o in _resultOpacities(m)) {
            expect(o, 0, reason: 'a result opacity > 0 at T0 + $ms');
          }
          expect(_result(tester).interactive, isFalse);
        }
        final tiles = _travelling(tester);
        expect(tiles, hasLength(5));
        final d = _maxDisplacement(tiles, cells);
        if (d > worst) worst = d;
        expect(d, lessThanOrEqualTo(0.5), reason: 'row moved at T0 + $ms');
        final step = ms < 590 ? 10 : 599 - ms;
        if (step <= 0) break;
        await tester.pump(Duration(milliseconds: step));
        ms += step;
      }
      // ignore: avoid_print
      print('row $row: max displacement before 600 = $worst pt');

      // 600 → 720: the row travels and morphs; chrome is gone by 720.
      await tester.pump(const Duration(milliseconds: 121)); // T0 + 720
      final mid = _travelling(tester);
      expect(mid.first.height, greaterThan(cells.first.height + 0.5));
      expect(find.byType(PuzzleBoard), findsNothing); // opacity 0 → offstage
      expect(find.byType(LoopBackButton), findsNothing);

      await tester.pump(const Duration(milliseconds: 219)); // T0 + 939
      expect(_result(tester).interactive, isFalse);
      await tester.pump(const Duration(milliseconds: 1)); // T0 + 940
      expect(_result(tester).interactive, isTrue);
      expect(find.byType(TravellingTile), findsNothing);
      await tester.pumpAndSettle();
    });
  }

  testWidgets('the row lands on the laid-out slot (within 1 pt) and the '
      'stars pop 940 / 1050 / 1160', (tester) async {
    await _boot(tester, _rowWin(4));
    await _swipeRow(tester, 4);
    await _toT0(tester);
    for (var t = 0; t < 820; t += 20) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pump(const Duration(milliseconds: 19)); // T0 + 839
    final landed = _travelling(tester);
    final answers = find.descendant(
      of: find.byType(ResultView),
      matching: find.byType(TileFace),
    );
    final slot = <Rect>[
      for (var i = 0; i < answers.evaluate().length; i++)
        tester.getRect(answers.at(i)),
    ];
    expect(slot, hasLength(5));
    expect(_maxDisplacement(landed, slot), lessThanOrEqualTo(1));

    StarRow stars() => tester.widget<StarRow>(find.byType(StarRow));
    await tester.pump(const Duration(milliseconds: 101)); // T0 + 940
    expect(stars().revealMs, 0);
    await tester.pump(const Duration(milliseconds: 110)); // T0 + 1050
    expect(stars().revealMs, 110);
    await tester.pumpAndSettle();
    expect(stars().revealMs, 360);
  });

  testWidgets('C-11: locked tiles in the winning row fill with it; their '
      'icons are gone by T0 + 210', (tester) async {
    await _boot(tester, _lockedRowWin(0));
    await _swipeColumnDown(tester, 4);
    await _toT0(tester);
    Finder locks() => find.descendant(
      of: find.byType(TravellingTile),
      matching: find.byWidgetPredicate(
        (w) => w is LoopIconView && w.icon == LoopIcon.lock,
      ),
    );
    expect(locks(), findsNWidgets(2)); // under the fill at T0
    await tester.pump(const Duration(milliseconds: 60));
    expect(locks(), findsNWidgets(2)); // A (col 1) half-filled, S not yet
    await tester.pump(const Duration(milliseconds: 150)); // T0 + 210
    expect(locks(), findsNothing);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Cevap: MASAL'), findsOneWidget);
  });

  testWidgets('C-11 reduced: the locked tiles are lime at T0', (tester) async {
    _reduceMotion(tester);
    await _boot(tester, _lockedRowWin(2));
    await _swipeColumnDown(tester, 4);
    await _toT0(tester);
    expect(
      find.descendant(
        of: find.byType(TravellingTile),
        matching: find.byWidgetPredicate(
          (w) => w is LoopIconView && w.icon == LoopIcon.lock,
        ),
      ),
      findsNothing,
    );
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion: static row, hold to 300, cross-fade, rest at '
      '660, stars static', (tester) async {
    _reduceMotion(tester);
    await _boot(tester, _rowWin(2));
    await _swipeRow(tester, 2);
    await _toT0(tester);
    final cells = _boardCells(kIphone16, 2);

    await tester.pump(const Duration(milliseconds: 299));
    for (final o in _resultOpacities(_result(tester).motion)) {
      expect(o, 0);
    }
    expect(_maxDisplacement(_travelling(tester), cells), 0);
    await tester.pump(const Duration(milliseconds: 81)); // T0 + 380
    expect(_result(tester).motion.answer, closeTo(0.5, 0.01));
    await tester.pump(const Duration(milliseconds: 279)); // T0 + 659
    expect(_result(tester).interactive, isFalse);
    await tester.pump(const Duration(milliseconds: 1)); // T0 + 660
    expect(_result(tester).interactive, isTrue);
    expect(tester.widget<StarRow>(find.byType(StarRow)).revealMs, isNull);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('tutorial active at T0 (L4–6): it dims and fades with the '
      'chrome, then stops ticking behind the result', (tester) async {
    setDevice(tester, kIphone16, top: 59, bottom: 34);
    await bootPlay(
      tester,
      puzzle: _rowWin(2),
      args: const PlaySessionArgs(
        source: PuzzleSource.journey,
        journeyLevel: 5,
      ),
      settle: false,
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(HintPill), findsOneWidget);
    await _swipeRow(tester, 2); // a row move leaves the column tutorial up
    await _toT0(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(HintPill), findsOneWidget); // at 50 %, not removed
    await tester.pump(const Duration(milliseconds: 500)); // T0 + 800
    expect(find.byType(HintPill), findsNothing); // gone with the chrome
    await tester.pump(const Duration(milliseconds: 600)); // past the stars
    expect(tester.hasRunningAnimations, isFalse); // the ghost loop is muted
  });

  testWidgets('taps before rest are dropped, not queued (board, pill, link, '
      'back)', (tester) async {
    await _boot(tester, _rowWin(2));
    await _swipeRow(tester, 2);
    await _toT0(tester);
    await tester.pump(const Duration(milliseconds: 900));
    // The controls are laid out (fading in) but inert.
    await tester.tap(find.text('Tekrar oyna'), warnIfMissed: false);
    await tester.tap(
      find.descendant(
        of: find.byType(ResultView),
        matching: find.byType(GlassIconButton),
      ),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pumpAndSettle();
    // Nothing happened: still the result, not Home, not a restarted Play.
    expect(find.byType(ResultView), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
    expect(_result(tester).interactive, isTrue);
  });

  testWidgets('during the sequence nothing is announced or focusable', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _boot(tester, _rowWin(2));
    await _swipeRow(tester, 2);
    await _toT0(tester);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.semantics.byLabel('Cevap: MASAL'), findsNothing);
    expect(find.semantics.byLabel(RegExp('Bulmaca tahtası')), findsNothing);
    expect(find.semantics.byLabel('Tekrar oyna'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.semantics.byLabel('Cevap: MASAL'), findsOne);
    expect(find.semantics.byLabel('Tekrar oyna'), findsOne);
    handle.dispose();
  });

  testWidgets('system back at T0 + 300 → Home, the completion persisted', (
    tester,
  ) async {
    final db = await _boot(tester, _rowWin(2), level: 9);
    await _swipeRow(tester, 2);
    await _toT0(tester);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
    expect(find.byType(ResultView), findsNothing);

    final guest = await PlayerRepo(db).currentGuestId();
    expect(await ActiveSessionRepo(db).read(), isNull);
    expect(
      (await PersonalBestRepo(db).read(guest, 'd2-row-2'))?.bestMoveCount,
      1,
    );
    final progress = await JourneyProgressRepo(db).read(guest);
    expect(progress.completedLevelsCsv.split(','), contains('9'));
  });

  testWidgets('background at T0 + 300 → the rest state on resume', (
    tester,
  ) async {
    await _boot(tester, _rowWin(2));
    await _swipeRow(tester, 2);
    await _toT0(tester);
    await tester.pump(const Duration(milliseconds: 300));
    for (final s in <AppLifecycleState>[
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
    await tester.pump();
    for (final s in <AppLifecycleState>[
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
    await tester.pump();
    expect(_result(tester).interactive, isTrue);
    expect(tester.widget<StarRow>(find.byType(StarRow)).revealMs, 360);
    expect(find.byType(TravellingTile), findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('killed at T0 + 300 → no active session; best and unlock '
      'written', (tester) async {
    final db = await _boot(tester, _rowWin(2), level: 9);
    await _swipeRow(tester, 2);
    await _toT0(tester);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(const SizedBox()); // the process dies
    await tester.pumpAndSettle();

    final guest = await PlayerRepo(db).currentGuestId();
    expect(await ActiveSessionRepo(db).read(), isNull);
    expect(await PersonalBestRepo(db).read(guest, 'd2-row-2'), isNotNull);
    final progress = await JourneyProgressRepo(db).read(guest);
    expect(progress.completedLevelsCsv.split(','), contains('9'));
    expect(progress.highestUnlockedLevel, 10);
  });

  // --- retry ---------------------------------------------------------------------

  testWidgets('retry A: the row flies into the rail (0–300), Play at rest by '
      '360 — HAMLE 0, undo disabled, 3 dots; restart count +1', (tester) async {
    final db = await _boot(tester, _rowWin(2));
    await _swipeRow(tester, 2);
    await tester.pumpAndSettle();
    expect(_result(tester).interactive, isTrue);

    await tester.tap(find.text('Tekrar oyna'));
    await tester.pump(); // T0 of the retry (the first frame after the tap)
    await tester.pump(const Duration(milliseconds: 300));
    final layout = PlayLayout(kIphone16);
    final s = layout.s;
    final width = 5 * 36 * s + 4 * 8 * s;
    final left = (kIphone16.width - width) / 2;
    final rail = <Rect>[
      for (var i = 0; i < 5; i++)
        Rect.fromLTWH(left + i * 44 * s, layout.railTop, 36 * s, 42 * s),
    ];
    expect(_maxDisplacement(_travelling(tester), rail), lessThanOrEqualTo(0.5));
    // Input is still locked until rest.
    expect(find.byType(ResultView), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 59)); // + 359
    expect(find.byType(ResultView), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1)); // + 360: rest
    expect(find.byType(ResultView), findsNothing);
    expect(find.byType(TravellingTile), findsNothing);
    expect(movesShown(tester), 0);
    final undo = tester.widget<UndoPill>(find.byType(UndoPill));
    expect(undo.onPressed, isNull);
    expect(undo.quota, 3);
    expect(find.byType(RailTile), findsNWidgets(5));

    await tester.pumpAndSettle();
    final snapshot = await ActiveSessionRepo(db).read();
    expect(snapshot?.restartCount, 1);
    expect(snapshot?.appliedMoves, isEmpty);
    expect(snapshot?.undosRemaining, 3);
  });

  testWidgets('retry reduced: a dip, at rest by 160', (tester) async {
    _reduceMotion(tester);
    await _boot(tester, _rowWin(2));
    await _swipeRow(tester, 2);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tekrar oyna'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.byType(TravellingTile), findsNothing); // no flight
    await tester.pump(const Duration(milliseconds: 119)); // + 159
    expect(find.byType(ResultView), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1)); // + 160
    expect(find.byType(ResultView), findsNothing);
    expect(movesShown(tester), 0);
  });

  testWidgets('a board drag during the retry is dropped; after rest it plays', (
    tester,
  ) async {
    await _boot(tester, _rowWin(2));
    await _swipeRow(tester, 2);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tekrar oyna'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.dragFrom(cellCenter(tester, 1, 0), const Offset(140, 0));
    await tester.pumpAndSettle();
    expect(movesShown(tester), 0);
    await tester.dragFrom(cellCenter(tester, 1, 0), const Offset(140, 0));
    await tester.pumpAndSettle();
    expect(movesShown(tester), 1);
  });

  testWidgets('back button at rest → Home', (tester) async {
    await _boot(tester, _rowWin(2));
    await _swipeRow(tester, 2);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Ana ekrana dön'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('a restored-solved session lands on the result at rest', (
    tester,
  ) async {
    setDevice(tester, kIphone16);
    final puzzle = _rowWin(1);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await ActiveSessionRepo(db).save(
      ActiveSessionSnapshot(
        puzzleId: puzzle.id,
        puzzleSource: PuzzleSource.journey,
        lang: 'tr',
        appliedMoves: const <String>['R1'],
        undosRemaining: 3,
        restartCount: 0,
        elapsedMsAccumulated: 5000,
        thawedFrozenCells: const <String>[],
        status: ActiveSessionStatus.completed,
        startedAtUtcMs: 1757145000000,
        lastPersistedAtUtcMs: 1757145005000,
      ),
    );
    await tester.pumpWidget(playApp(db: db, puzzle: puzzle, direct: true));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(_result(tester).interactive, isTrue);
    expect(find.text('HARİKA'), findsOneWidget);
  });
}
