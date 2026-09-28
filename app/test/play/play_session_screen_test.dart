// F03 Play screen — the behaviour contract (AC1/AC2/AC4/AC7/AC8, unchanged)
// and the Loop Glass Play surface of Phase D1 (F03-FE-D1; `ui-design.md`
// §5–§8, the §11.5 acceptance list; architecture §19, §19.8).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/design/design.dart';
import 'package:looplet_app/play/play_layout.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/play/play_session_providers.dart';
import 'package:looplet_app/play/widgets/puzzle_board.dart';
import 'package:looplet_app/play/widgets/target_rail.dart';
import 'package:looplet_app/play/widgets/result_view.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:drift/native.dart';
import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_engine/looplet_engine.dart';

import 'play_test_support.dart';

const PlaySessionArgs _smoke01 = PlaySessionArgs(
  source: PuzzleSource.journey,
  debugPuzzleId: 'smoke-tr-01',
);

/// No single move forms MASAL here (the letters never align in one line).
const List<String> _noWin = <String>[
  'BKNRT',
  'SMVYZ',
  'ZCDFG',
  'HJKLP',
  'RSTVY',
];

/// Touch down on (row, col) and drag past the pan slop, then [delta] more —
/// the line lifts once the tracked delta passes the 18 px threshold.
Future<TestGesture> _lift(
  WidgetTester tester,
  int row,
  int col,
  Offset delta,
) async {
  final g = await tester.startGesture(cellCenter(tester, row, col));
  final slop = Offset(delta.dx.sign * 20, delta.dy.sign * 20);
  await g.moveBy(slop);
  await g.moveBy(delta);
  return g;
}

/// Drag row 0 to the right — `A S A L M` → `M A S A L` (MASAL), a 1-move win.
Future<void> _solveRow0(WidgetTester tester) async {
  await tester.dragFrom(cellCenter(tester, 0, 0), const Offset(140, 0));
  await tester.pumpAndSettle();
}

void main() {
  group('behaviour (unchanged)', () {
    testWidgets('renders the goal, board, and HAMLE 0 (AC1)', (tester) async {
      setDevice(tester, kIphone16);
      await bootPlay(tester, args: _smoke01);

      expect(find.text('HEDEF DÖNGÜ'), findsOneWidget);
      expect(find.text('HAMLE'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.byType(PuzzleBoard), findsOneWidget);
      // The rail is one node: "Hedef döngü: MASAL".
      expect(find.bySemanticsLabel('Hedef döngü: MASAL'), findsOneWidget);
      expect(find.byType(RailTile), findsNWidgets(5));
    });

    testWidgets(
      'a legal swipe that forms the target → the full-screen result (AC2/AC8)',
      (tester) async {
        setDevice(tester, kIphone16);
        await bootPlay(tester, args: _smoke01);

        await _solveRow0(tester);

        expect(find.byType(ResultView), findsOneWidget);
        expect(find.text('Döngü\ntamamlandı.'), findsOneWidget);
        expect(find.text('Tekrar oyna'), findsOneWidget);
        // No Close anywhere (architecture §20.3 (7)).
        expect(find.text('Kapat'), findsNothing);
        // smoke-tr-01 is optimal 1, solved in 1 → Perfect + first clear.
        expect(find.text('HARİKA'), findsOneWidget);
        expect(find.bySemanticsLabel('Cevap: MASAL'), findsOneWidget);
        // Only the result's own back button is on screen at rest; the Play
        // header, board and HUD are gone (§20.3 (4)).
        expect(find.byType(LoopBackButton), findsNothing);
        expect(find.byType(PuzzleBoard), findsNothing);
        expect(find.text('HAMLE'), findsNothing);
      },
    );

    testWidgets('Retry from the result resets the board (AC7)', (tester) async {
      setDevice(tester, kIphone16);
      await bootPlay(tester, args: _smoke01);
      await _solveRow0(tester);
      expect(find.byType(ResultView), findsOneWidget);

      await tester.tap(find.text('Tekrar oyna'));
      await tester.pumpAndSettle();

      expect(find.byType(ResultView), findsNothing);
      expect(find.text('0'), findsOneWidget); // MOVES reset
      expect(find.byType(LoopBackButton), findsOneWidget); // back is back
    });

    testWidgets('a sub-threshold tap does not change MOVES (AC4)', (
      tester,
    ) async {
      setDevice(tester, kIphone16);
      await bootPlay(tester, args: _smoke01);

      await tester.dragFrom(cellCenter(tester, 2, 2), const Offset(6, 4));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
      expect(find.byType(ResultView), findsNothing);
    });
  });

  group('D1 layout (ui-design §6, §11.5 (1)–(4))', () {
    for (final (name, size) in <(String, Size)>[
      ('iPhone 16 393×852', kIphone16),
      ('iPhone 16e 390×844', kIphone16e),
      ('iPhone 16 Pro Max 440×956', kIphone16ProMax),
    ]) {
      testWidgets('$name: every rect sits on the width-scaled geometry', (
        tester,
      ) async {
        setDevice(tester, size);
        await bootPlay(tester, puzzle: testPuzzle(grid: _noWin));
        final l = PlayLayout(size);
        final s = size.width / 358;
        expect(l.s, closeTo(s, 1e-9));

        void near(Rect actual, Rect expected, String what) {
          for (final (a, e, edge) in <(double, double, String)>[
            (actual.left, expected.left, 'left'),
            (actual.top, expected.top, 'top'),
            (actual.width, expected.width, 'width'),
            (actual.height, expected.height, 'height'),
          ]) {
            expect(a, closeTo(e, 0.01), reason: '$what $edge');
          }
        }

        // (1) Board card: 308.5·s wide (86 % of W), centred, radius 34·s.
        near(tester.getRect(find.byType(BoardCard)), l.boardRect, 'board');
        expect(l.boardRect.width / size.width, closeTo(0.86, 0.005));
        expect(l.boardRect.center.dx, closeTo(size.width / 2, 0.01));
        // Tiles 52·s with a 6.5·s gap, 11·s from the card edge.
        final tile00 = tester.getRect(find.byType(TileFace).first);
        expect(tile00.width, closeTo(52 * s, 0.01));
        expect(tile00.left - l.boardRect.left, closeTo(11 * s, 0.01));
        // (2) Header: the chevron at (25, 96)·s; the HAMLE card at
        // (273.5, 75)·s, 60 × 63·s minimum.
        final chevron = find.descendant(
          of: find.byType(LoopBackButton),
          matching: find.byType(LoopIconView),
        );
        expect(tester.getTopLeft(chevron).dx, closeTo(25 * s, 0.01));
        expect(tester.getTopLeft(chevron).dy, closeTo(96 * s, 0.01));
        final back = tester.getRect(find.byType(LoopBackButton));
        expect(back.left, closeTo(16, 0.01));
        expect(back.height, greaterThanOrEqualTo(44 - 1e-6));
        expect(back.width, greaterThanOrEqualTo(44 - 1e-6));
        final moves = tester.getRect(find.byType(MovesCard));
        expect(moves.topLeft.dx, closeTo(273.5 * s, 0.01));
        expect(moves.topLeft.dy, closeTo(75 * s, 0.01));
        expect(moves.width, closeTo(60 * s, 0.01));
        expect(moves.height, greaterThanOrEqualTo(63 * s - 0.01));
        // (3) Rail tiles 36 × 42·s at y 197·s + 0.3 e; no divider line.
        final rail = tester.getRect(find.byType(RailTile).first);
        expect(rail.top, closeTo(l.railTop, 0.01));
        expect(rail.width, closeTo(36 * s, 0.01));
        expect(rail.height, closeTo(42 * s, 0.01));
        expect(
          tester.getRect(find.byType(TargetRail)).bottom,
          closeTo(l.railBottom, 0.01),
        );
        // (4) HUD: undo 98.5 × 50·s at (29·s, 592.5·s + e); restart 44 pt
        // at x 289·s, centred on the pill.
        near(tester.getRect(find.byType(UndoPill)), l.undoRect, 'undo');
        near(
          tester.getRect(find.byType(GlassIconButton)),
          l.restartRect,
          'restart',
        );
        expect(l.restartRect.center.dy, closeTo(l.undoRect.center.dy, 1e-9));
      });
    }

    testWidgets('393×852 matches the handoff table to 0.15 pt', (tester) async {
      setDevice(tester, kIphone16);
      await bootPlay(tester, puzzle: testPuzzle(grid: _noWin));
      void pt(double actual, double expected, String what) =>
          expect(actual, closeTo(expected, 0.15), reason: what);

      final board = tester.getRect(find.byType(BoardCard));
      pt(board.left, 27.15, 'board x');
      pt(board.top, 306.6, 'board y');
      pt(board.width, 338.7, 'board w');
      pt(board.height, 337.6, 'board h');
      pt(board.bottom, 644.2, 'board bottom');
      final moves = tester.getTopLeft(find.byType(MovesCard));
      pt(moves.dx, 300.2, 'HAMLE x');
      pt(moves.dy, 82.3, 'HAMLE y');
      final rail = tester.getRect(find.byType(RailTile).first);
      pt(rail.top, 235.8, 'rail y');
      pt(rail.width, 39.5, 'rail w');
      pt(rail.height, 46.1, 'rail h');
      final undo = tester.getRect(find.byType(UndoPill));
      pt(undo.left, 31.8, 'undo x');
      pt(undo.top, 715.3, 'undo y');
      pt(undo.width, 108.1, 'undo w');
      pt(undo.height, 54.9, 'undo h');
      final restart = tester.getRect(find.byType(GlassIconButton));
      pt(restart.left, 317.3, 'restart x');
      pt(restart.top, 720.7, 'restart y');
      pt(undo.top - board.bottom, 71.1, 'board → HUD gap');
      // The HAMLE label is ≥ 12 pt at 393 (ruling 2026-09-21).
      final label = tester.widget<Text>(find.text('HAMLE'));
      expect(label.style!.fontSize, greaterThanOrEqualTo(12));
    });

    testWidgets('no Material icon on the D1 surface, idle or mid-drag', (
      tester,
    ) async {
      setDevice(tester, kIphone16);
      await bootPlay(tester, puzzle: testPuzzle(grid: _noWin));
      expect(find.byType(Icon), findsNothing);
      // Mid-drag too.
      final g = await _lift(tester, 2, 0, const Offset(30, 0));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Icon), findsNothing);
      await g.up();
      await tester.pumpAndSettle();
    });
  });

  group('header (ui-design §6 App Chrome, §19.8 (5))', () {
    testWidgets('SEVİYE NN is bound to the Journey level; back pops to /', (
      tester,
    ) async {
      setDevice(tester, kIphone16);
      await bootPlay(
        tester,
        puzzle: testPuzzle(grid: _noWin, level: 26),
        args: const PlaySessionArgs(
          source: PuzzleSource.journey,
          journeyLevel: 26,
        ),
      );
      expect(find.text('SEVİYE 26'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(LoopBackButton)).label,
        'Geri, Seviye 26',
      );

      await tester.tap(find.byType(LoopBackButton));
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
      expect(find.byType(PuzzleBoard), findsNothing);
    });

    testWidgets('two digits below 10: SEVİYE 07', (tester) async {
      setDevice(tester, kIphone16);
      await bootPlay(
        tester,
        puzzle: testPuzzle(grid: _noWin, level: 7),
        args: const PlaySessionArgs(
          source: PuzzleSource.journey,
          journeyLevel: 7,
        ),
      );
      expect(find.text('SEVİYE 07'), findsOneWidget);
    });

    testWidgets('a session with no level number shows the chevron alone', (
      tester,
    ) async {
      setDevice(tester, kIphone16);
      await bootPlay(tester, args: _smoke01);
      expect(find.textContaining('SEVİYE'), findsNothing);
      expect(tester.getSemantics(find.byType(LoopBackButton)).label, 'Geri');
    });

    testWidgets('system back behaves like the chevron', (tester) async {
      setDevice(tester, kIphone16);
      await bootPlay(tester, puzzle: testPuzzle(grid: _noWin));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    });
  });

  group('loading and load error (ui-design §8, §11.5 (12)–(13))', () {
    testWidgets('loading → loaded: the board card does not move; no spinner; '
        '"Yükleniyor" only after 300 ms', (tester) async {
      setDevice(tester, kIphone16);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final gate = Completer<PlaySessionSetup>();
      await tester.pumpWidget(
        playApp(
          db: db,
          puzzle: null,
          args: const PlaySessionArgs(
            source: PuzzleSource.journey,
            journeyLevel: 7,
          ),
          setup: () => gate.future,
          direct: true,
        ),
      );
      await tester.pump();

      final loadingRect = tester.getRect(find.byType(BoardCard));
      expect(loadingRect, PlayLayout(kIphone16).boardRect);
      expect(find.byType(SkeletonCell), findsNWidgets(25));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(MovesCard), findsNothing);
      expect(find.byType(UndoPill), findsNothing);
      expect(find.text('SEVİYE 07'), findsOneWidget);
      expect(find.bySemanticsLabel('Yükleniyor'), findsNothing);
      await tester.pump(const Duration(milliseconds: 320));
      expect(find.bySemanticsLabel('Yükleniyor'), findsOneWidget);

      gate.complete(
        PlaySessionSetup(
          puzzle: testPuzzle(grid: _noWin, level: 7),
          validator: const NeverValidWordValidator(),
        ),
      );
      await tester.pump();
      await tester.pump();
      // Cross-fading: the skeleton is still there under the arriving tiles.
      expect(tester.getRect(find.byType(BoardCard).last), loadingRect);
      await tester.pumpAndSettle();
      expect(find.byType(BoardCard), findsOneWidget);
      expect(tester.getRect(find.byType(BoardCard)), loadingRect);
      expect(find.byType(SkeletonCell), findsNothing);
      expect(find.byType(MovesCard), findsOneWidget);
    });

    testWidgets('an unsupported source shows the calm error card', (
      tester,
    ) async {
      setDevice(tester, kIphone16);
      await bootPlay(
        tester,
        args: const PlaySessionArgs(source: PuzzleSource.daily),
      );

      expect(find.text('Bu bulmaca yüklenemedi.'), findsOneWidget);
      expect(find.text('Ana ekrana dön'), findsOneWidget);
      expect(find.byType(LimePill), findsOneWidget);
      expect(
        tester
            .widgetList<LoopIconView>(find.byType(LoopIconView))
            .map((v) => v.icon),
        containsAll(<LoopIcon>[LoopIcon.loopBreak, LoopIcon.back]),
      );
      expect(find.byType(Icon), findsNothing);
      // No raw exception text reaches the screen.
      expect(find.textContaining('Unsupported'), findsNothing);
      expect(find.textContaining('F07'), findsNothing);
    });

    testWidgets('the error pill goes home (/)', (tester) async {
      setDevice(tester, kIphone16);
      await bootPlay(
        tester,
        args: const PlaySessionArgs(source: PuzzleSource.daily),
      );
      await tester.tap(find.text('Ana ekrana dön'));
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('on the error screen system back returns to /', (tester) async {
      setDevice(tester, kIphone16);
      await bootPlay(
        tester,
        args: const PlaySessionArgs(source: PuzzleSource.daily),
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('the error card reflows at AX5 with no exception', (
      tester,
    ) async {
      await loadAppFonts();
      setDevice(tester, kIphone16e, textScale: 3.12);
      await bootPlay(
        tester,
        args: const PlaySessionArgs(source: PuzzleSource.daily),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Ana ekrana dön'), findsOneWidget);
    });
  });

  group('motion and state (ui-design §5, §8, §11.5 (5)–(8))', () {
    testWidgets('HAMLE changes at the settle, not at release', (tester) async {
      setDevice(tester, kIphone16);
      await bootPlay(tester, puzzle: testPuzzle(grid: _noWin));

      await tester.dragFrom(cellCenter(tester, 1, 0), const Offset(140, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100)); // mid-settle
      expect(movesShown(tester), 0);
      await tester.pumpAndSettle();
      expect(movesShown(tester), 1);
    });

    testWidgets('a lifted row: periwinkle rim, rails at the side edges, the '
        'rest at 42 %, the wrap ghost at 30 % — never lime', (tester) async {
      setDevice(tester, kIphone16);
      await bootPlay(tester, puzzle: testPuzzle(grid: _noWin));

      final g = await _lift(tester, 2, 0, const Offset(30, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100)); // lift done

      final faces = tester.widgetList<TileFace>(find.byType(TileFace));
      expect(faces.where((f) => f.state == TileState.active), hasLength(7));
      expect(faces.where((f) => f.state == TileState.winning), isEmpty);
      final rails = tester.widgetList<LineRail>(find.byType(LineRail));
      expect(rails, hasLength(2));
      expect(rails.every((r) => r.axis == Axis.vertical), isTrue);
      final board = tester.getRect(find.byType(BoardCard));
      final railRects = find
          .byType(LineRail)
          .evaluate()
          .map((e) => tester.getRect(find.byWidget(e.widget)))
          .toList();
      expect(railRects.first.center.dx, closeTo(board.left, 3));
      expect(railRects.last.center.dx, closeTo(board.right, 3));
      // The rest of the board is one dimmed group at 42 %.
      final rest = tester.widget<Opacity>(
        find.ancestor(of: find.text('B'), matching: find.byType(Opacity)).first,
      );
      expect(rest.opacity, closeTo(0.42, 0.001));
      // Two wrap ghosts at 30 % (the clip hides the leading one).
      final ghosts = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .where((o) => (o.opacity - 0.30).abs() < 1e-9);
      expect(ghosts, hasLength(2));

      await g.up();
      await tester.pumpAndSettle();
      expect(find.byType(LineRail), findsNothing);
      expect(
        tester
            .widgetList<TileFace>(find.byType(TileFace))
            .where((f) => f.state == TileState.active),
        isEmpty,
      );
    });

    testWidgets('a lifted column puts the rails on the top and bottom edges', (
      tester,
    ) async {
      setDevice(tester, kIphone16);
      await bootPlay(tester, puzzle: testPuzzle(grid: _noWin));

      final g = await _lift(tester, 1, 2, const Offset(0, 30));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final rails = tester.widgetList<LineRail>(find.byType(LineRail));
      expect(rails, hasLength(2));
      expect(rails.every((r) => r.axis == Axis.horizontal), isTrue);
      final board = tester.getRect(find.byType(BoardCard));
      final top = tester.getRect(find.byType(LineRail).first);
      expect(top.center.dy, closeTo(board.top, 3));
      await g.up();
      await tester.pumpAndSettle();
    });

    testWidgets('the lift fades in over 90 ms; reduced motion: instant', (
      tester,
    ) async {
      setDevice(tester, kIphone16);
      await bootPlay(tester, puzzle: testPuzzle(grid: _noWin));
      double restOpacity() => tester
          .widget<Opacity>(
            find
                .ancestor(of: find.text('B'), matching: find.byType(Opacity))
                .first,
          )
          .opacity;

      var g = await _lift(tester, 2, 0, const Offset(30, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 45));
      expect(restOpacity(), inExclusiveRange(0.42, 1.0));
      await tester.pump(const Duration(milliseconds: 60));
      expect(restOpacity(), closeTo(0.42, 0.001));
      await g.up();
      await tester.pumpAndSettle();

      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(reduceMotion: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      g = await _lift(tester, 2, 0, const Offset(30, 0));
      await tester.pump();
      expect(restOpacity(), closeTo(0.42, 0.001));
      await g.up();
      await tester.pumpAndSettle();
    });

    testWidgets('undo: lime quota dots + "n / 3 hak"; disabled at 0 moves and '
        'at 0 quota (AC6)', (tester) async {
      setDevice(tester, kIphone16);
      await bootPlay(tester, puzzle: testPuzzle(grid: _noWin));
      UndoPill pill() => tester.widget<UndoPill>(find.byType(UndoPill));

      expect(pill().onPressed, isNull); // 0 moves
      expect(pill().quota, 3);
      expect(
        tester.getSemantics(find.byType(UndoPill)).label,
        'Geri al, 3 / 3 hak',
      );

      for (var spent = 1; spent <= 3; spent++) {
        await tester.dragFrom(cellCenter(tester, 1, 0), const Offset(140, 0));
        await tester.pumpAndSettle();
        expect(pill().onPressed, isNotNull);
        await tester.tap(find.byType(UndoPill));
        await tester.pumpAndSettle();
        expect(movesShown(tester), 0);
        expect(pill().quota, 3 - spent);
        expect(
          tester.getSemantics(find.byType(UndoPill)).label,
          'Geri al, ${3 - spent} / 3 hak',
        );
      }
      // Quota spent: a move no longer enables undo — no prompt, no dialog.
      await tester.dragFrom(cellCenter(tester, 1, 0), const Offset(140, 0));
      await tester.pumpAndSettle();
      expect(movesShown(tester), 1);
      expect(pill().onPressed, isNull);
      await tester.tap(find.byType(UndoPill), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(movesShown(tester), 1);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('restart is a 44 pt glass square with no dialog (AC7)', (
      tester,
    ) async {
      setDevice(tester, kIphone16);
      await bootPlay(tester, puzzle: testPuzzle(grid: _noWin));
      await tester.dragFrom(cellCenter(tester, 1, 0), const Offset(140, 0));
      await tester.pumpAndSettle();
      expect(movesShown(tester), 1);

      final restart = tester.widget<GlassIconButton>(
        find.byType(GlassIconButton),
      );
      expect(restart.icon, LoopIcon.restart);
      expect(tester.getSize(find.byType(GlassIconButton)), const Size(44, 44));
      expect(tester.getSemantics(find.byType(GlassIconButton)).label, 'Baştan');
      await tester.tap(find.byType(GlassIconButton));
      await tester.pumpAndSettle();
      expect(movesShown(tester), 0);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('special tiles: locked = indigo + lock, frozen = ice + '
        'snowflake (non-colour cues)', (tester) async {
      setDevice(tester, kIphone16);
      await bootPlay(
        tester,
        puzzle: testPuzzle(
          grid: _noWin,
          locked: <GridCoord>{const GridCoord(0, 0)},
          frozen: <GridCoord>{const GridCoord(2, 2)},
        ),
      );
      final faces = tester.widgetList<TileFace>(find.byType(TileFace)).toList();
      expect(
        faces.where((f) => f.state == TileState.locked).single.letter,
        'B',
      );
      expect(
        faces.where((f) => f.state == TileState.frozen).single.letter,
        'D',
      );
      final icons = tester
          .widgetList<LoopIconView>(
            find.descendant(
              of: find.byType(PuzzleBoard),
              matching: find.byType(LoopIconView),
            ),
          )
          .map((v) => v.icon)
          .toList();
      expect(icons, containsAll(<LoopIcon>[LoopIcon.lock, LoopIcon.snowflake]));
    });
  });

  group('thaw (ui-design §5, §11.5 (7); A-5)', () {
    // Row 2 `X A A T S` with the X frozen: one right shift rotates the movable
    // letters to `X S A A T` — "SAAT" thaws the X (not a win).
    Puzzle thawPuzzle() => testPuzzle(
      grid: const <String>['BKNRT', 'MVYZC', 'XAATS', 'HJKLP', 'RBTVY'],
      frozen: <GridCoord>{const GridCoord(2, 0)},
    );
    const validator = SetWordValidator(<String>{'SAAT'});

    List<TileFace> frozenFaces(WidgetTester tester) => tester
        .widgetList<TileFace>(find.byType(TileFace))
        .where((f) => f.state == TileState.frozen)
        .toList();

    Future<void> settleThawingMove(WidgetTester tester) async {
      await tester.dragFrom(cellCenter(tester, 2, 2), const Offset(140, 0));
      for (var i = 0; i < 100 && movesShown(tester) == 0; i++) {
        await tester.pump(const Duration(milliseconds: 4));
      }
      expect(movesShown(tester), 1, reason: 'the move settled');
    }

    testWidgets('a 180 ms cross-fade; the snowflake shrinks as it fades', (
      tester,
    ) async {
      setDevice(tester, kIphone16);
      await bootPlay(tester, puzzle: thawPuzzle(), validator: validator);
      expect(frozenFaces(tester), hasLength(1));

      await settleThawingMove(tester);
      await tester.pump(const Duration(milliseconds: 90));
      final fading = frozenFaces(tester);
      expect(fading, hasLength(1));
      expect(fading.single.iconScale, inExclusiveRange(0.6, 1.0));
      final veil = tester.widget<Opacity>(
        find
            .ancestor(
              of: find.byWidget(fading.single),
              matching: find.byType(Opacity),
            )
            .first,
      );
      expect(veil.opacity, inExclusiveRange(0.0, 1.0));

      await tester.pump(const Duration(milliseconds: 110));
      expect(frozenFaces(tester), isEmpty);
      await tester.pumpAndSettle();
      expect(frozenFaces(tester), isEmpty);
    });

    testWidgets('reduced motion: the thaw is instant at the settle', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(reduceMotion: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      setDevice(tester, kIphone16);
      await bootPlay(tester, puzzle: thawPuzzle(), validator: validator);
      expect(frozenFaces(tester), hasLength(1));

      await settleThawingMove(tester);
      expect(frozenFaces(tester), isEmpty);
    });
  });

  group('text scale (§19.3 (1), §11.5 (10); A-2)', () {
    for (final (name, size) in <(String, Size)>[
      ('390×844', kIphone16e),
      ('393×852', kIphone16),
    ]) {
      for (final scale in <double>[1.0, 1.35, 3.12]) {
        testWidgets('$name at OS text ${scale}x: every Play text is capped at '
            '1.3×, nothing overflows', (tester) async {
          await loadAppFonts();
          setDevice(tester, size, textScale: scale);
          await bootPlay(
            tester,
            puzzle: testPuzzle(
              grid: _noWin,
              level: 26,
              locked: <GridCoord>{const GridCoord(0, 0)},
              frozen: <GridCoord>{const GridCoord(2, 2)},
            ),
            args: const PlaySessionArgs(
              source: PuzzleSource.journey,
              journeyLevel: 26,
            ),
          );
          expect(tester.takeException(), isNull);
          final expected = scale.clamp(1.0, 1.3) * 100;
          for (final text in tester.widgetList<Text>(find.byType(Text))) {
            expect(
              text.textScaler?.scale(100) ?? -1,
              closeTo(expected, 0.01),
              reason: '"${text.data}" must take loopCappedTextScaler',
            );
          }
          // Board glyphs stay inside their tiles.
          for (final e in find.byType(TileFace).evaluate()) {
            final face = e.widget as TileFace;
            final tileRect = tester.getRect(find.byWidget(face));
            final glyph = tester.getRect(
              find.descendant(
                of: find.byWidget(face),
                matching: find.text(face.letter),
              ),
            );
            expect(tileRect.contains(glyph.topLeft), isTrue);
            expect(tileRect.contains(glyph.bottomRight), isTrue);
          }
        });
      }
    }
  });
}
