// F03-FE9 — the fast, always-green automated coverage of `qa.md §17`
// scenarios 1–4 for the puzzle-play screen. Runs in the standard
// `melos run test` / CI `verify` gate (no device / emulator needed).
//
// The `integration_test/play_session_test.dart` suite covers the same
// scenarios on a device (`flutter test integration_test -d <device>`) as a
// best-effort gate per `release.md §4`; the visual items (`qa.md §17` 5–7) are
// a manual device pass — see `frontend.md` "F03-FE9".

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/engine/engine_providers.dart';
import 'package:looplet_app/persistence/active_session_snapshot.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/persistence/repositories/active_session_repo.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/play/play_session_screen.dart';
import 'package:looplet_app/play/widgets/board_tile.dart';
import 'package:looplet_app/rating/completion_panel.dart';
import 'package:looplet_app/play/widgets/puzzle_board.dart';
import 'package:looplet_core/looplet_core.dart' show TileStatus;
import 'package:looplet_engine/looplet_engine.dart';

const _small = Size(360, 780);
const _large = Size(430, 932);

Widget _app(AppDatabase db, String debugPuzzleId) => ProviderScope(
  overrides: <Override>[
    appDatabaseProvider.overrideWithValue(db),
    // The smoke puzzles here have no frozen tile that should thaw, so a
    // never-valid validator is enough — and it makes the tampered-cache
    // assertion meaningful (`smoke-tr-06` `2,2` can never legitimately thaw).
    wordValidatorProvider.overrideWith(
      (ref) async => const NeverValidWordValidator(),
    ),
  ],
  child: MaterialApp(
    home: PlaySessionScreen(
      args: PlaySessionArgs(
        source: PuzzleSource.journey,
        debugPuzzleId: debugPuzzleId,
      ),
    ),
  ),
);

Offset _rowStart(WidgetTester tester, int row) {
  final box = tester.getRect(find.byType(PuzzleBoard));
  const plate = 10.0;
  const gap = 8.0;
  final tile = (box.width - 2 * plate - 4 * gap) / 5;
  final stride = tile + gap;
  return Offset(
    box.left + plate + tile * 0.5,
    box.top + plate + row * stride + tile * 0.5,
  );
}

/// The MOVES HUD value — the only bare integer on the playing stage (the
/// completion sheet's stat only exists after a win, which these callers avoid).
int _moves(WidgetTester tester) {
  for (var n = 0; n <= 99; n++) {
    if (find.text('$n').evaluate().isNotEmpty) return n;
  }
  return -1;
}

Future<void> _boot(WidgetTester tester, AppDatabase db, String id) async {
  await tester.pumpWidget(_app(db, id));
  await tester.pumpAndSettle();
  expect(find.byType(PuzzleBoard), findsOneWidget);
}

void main() {
  group('§17.1 — gesture → shift wiring at 2 surface sizes (AC2/AC3/AC4)', () {
    for (final size in <Size>[_small, _large]) {
      final label = '${size.width.toInt()}x${size.height.toInt()}';

      testWidgets('$label · a row-0 right swipe forms the target', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);

        await _boot(tester, db, 'smoke-tr-01');
        expect(_moves(tester), 0);

        // smoke-tr-01 row 0 = A S A L M → one cell right = M A S A L (MASAL).
        await tester.dragFrom(_rowStart(tester, 0), const Offset(140, 0));
        await tester.pumpAndSettle();

        expect(find.byType(CompletionPanel), findsOneWidget);
        expect(find.text('ÇÖZÜLDÜ'), findsOneWidget);
      });

      testWidgets('$label · a sub-threshold drag does not move (AC4)', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);

        await _boot(tester, db, 'smoke-tr-01');
        await tester.dragFrom(_rowStart(tester, 2), const Offset(6, 4));
        await tester.pumpAndSettle();

        expect(_moves(tester), 0);
        expect(find.byType(CompletionPanel), findsNothing);
      });

      testWidgets(
        '$label · a rejected column move → MOVES unchanged, no error',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);
          final db = AppDatabase.forTesting(NativeDatabase.memory());
          addTearDown(db.close);

          await _boot(tester, db, 'smoke-tr-01'); // columnMovesEnabled == false
          await tester.dragFrom(_rowStart(tester, 2), const Offset(0, 140));
          await tester.pumpAndSettle();

          expect(_moves(tester), 0);
          expect(find.byType(CompletionPanel), findsNothing);
        },
      );
    }
  });

  group(
    '§17.2 — no double-registered moves during the animation window (AC5)',
    () {
      testWidgets('a second drag during the ~190 ms shift is dropped', (
        tester,
      ) async {
        tester.view.physicalSize = _large;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);

        await _boot(tester, db, 'smoke-tr-02');

        // Row 1 = B C D F G → a legal, non-winning right shift.
        await tester.dragFrom(_rowStart(tester, 1), const Offset(140, 0));
        await tester.pump(); // start the shift animation
        await tester.pump(const Duration(milliseconds: 60)); // mid-window
        // A second gesture while phase == animatingShift → dropped, not queued.
        await tester.dragFrom(_rowStart(tester, 1), const Offset(140, 0));
        await tester.pumpAndSettle();

        expect(_moves(tester), 1);
      });

      testWidgets('rapid same-row swipes each count only after the previous '
          'settles', (tester) async {
        tester.view.physicalSize = _large;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);

        await _boot(tester, db, 'smoke-tr-02');

        await tester.dragFrom(_rowStart(tester, 1), const Offset(140, 0));
        await tester.pumpAndSettle();
        await tester.dragFrom(_rowStart(tester, 1), const Offset(140, 0));
        await tester.pumpAndSettle();

        expect(_moves(tester), 2);
      });
    },
  );

  group('§17.3 — kill / relaunch resume (AC10)', () {
    testWidgets('MOVES + restart survive a dispose + remount on the same DB', (
      tester,
    ) async {
      tester.view.physicalSize = _large;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      // One shared DB across the "kill" — overrideWithValue bypasses the
      // provider's `onDispose(db.close)`, so it stays open across remounts.
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _boot(tester, db, 'smoke-tr-02');
      for (var i = 0; i < 3; i++) {
        await tester.dragFrom(_rowStart(tester, 1), const Offset(140, 0));
        await tester.pumpAndSettle();
      }
      expect(_moves(tester), 3);

      // "Kill" — tear the tree down (disposes the controller + its writes).
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      // "Relaunch" on the same DB → restored from the snapshot.
      await _boot(tester, db, 'smoke-tr-02');
      expect(_moves(tester), 3);

      // Restart persists too.
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pumpAndSettle();
      expect(_moves(tester), 0);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await _boot(tester, db, 'smoke-tr-02');
      expect(_moves(tester), 0);
    });

    testWidgets('a persisted 1-move session restores after a dispose + remount', (
      tester,
    ) async {
      tester.view.physicalSize = _large;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      // Seed via the repo directly (as F08 does) and confirm the screen hydrates.
      await ActiveSessionRepo(db).save(
        ActiveSessionSnapshot(
          puzzleId: 'smoke-tr-02',
          puzzleSource: PuzzleSource.journey,
          lang: 'tr',
          appliedMoves: const <String>['R1'],
          undosRemaining: 2,
          restartCount: 1,
          elapsedMsAccumulated: 41200,
          thawedFrozenCells: const <String>[],
          status: ActiveSessionStatus.inProgress,
          startedAtUtcMs: 1757145000000,
          lastPersistedAtUtcMs: 1757145041200,
        ),
      );

      await _boot(tester, db, 'smoke-tr-02');
      expect(_moves(tester), 1);
    });

    testWidgets(
      'a tampered thawedFrozenCells cache is re-derived, not trusted',
      (tester) async {
        tester.view.physicalSize = _large;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);

        // smoke-tr-06 has a frozen tile at 2,2 (row 2 = X A S A L). Seed a
        // snapshot with NO moves but a bogus "2,2 is thawed" cache entry.
        await ActiveSessionRepo(db).save(
          ActiveSessionSnapshot(
            puzzleId: 'smoke-tr-06',
            puzzleSource: PuzzleSource.journey,
            lang: 'tr',
            appliedMoves: const <String>[],
            undosRemaining: 3,
            restartCount: 0,
            elapsedMsAccumulated: 0,
            thawedFrozenCells: const <String>['2,2'],
            status: ActiveSessionStatus.inProgress,
            startedAtUtcMs: 1757145000000,
            lastPersistedAtUtcMs: 1757145000000,
          ),
        );

        await _boot(tester, db, 'smoke-tr-06');

        // Replaying zero moves with a never-valid validator leaves 2,2 FROZEN —
        // the snapshot's "thawed" cache was not trusted.
        final tiles = tester
            .widgetList<BoardTile>(find.byType(BoardTile))
            .toList();
        final frozen = tiles
            .where((t) => t.status == TileStatus.frozen)
            .toList();
        expect(frozen, hasLength(1));
        expect(frozen.single.letter, 'S');
        expect(tiles.where((t) => t.status == TileStatus.thawed), isEmpty);
      },
    );
  });

  group('§17.4 — app lifecycle (architecture.md §12)', () {
    testWidgets('paused mid-drag cancels the gesture, no move', (tester) async {
      tester.view.physicalSize = _large;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _boot(tester, db, 'smoke-tr-02');

      final gesture = await tester.startGesture(_rowStart(tester, 1));
      await gesture.moveBy(const Offset(40, 0));
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(_moves(tester), 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('paused mid-animation commits a settled move (never torn)', (
      tester,
    ) async {
      tester.view.physicalSize = _large;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _boot(tester, db, 'smoke-tr-02');

      await tester.dragFrom(_rowStart(tester, 1), const Offset(140, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50)); // mid-shift
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(_moves(tester), 1); // committed, not lost, not doubled
      expect(tester.takeException(), isNull);

      // Survives a kill / relaunch.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await _boot(tester, db, 'smoke-tr-02');
      expect(_moves(tester), 1);
    });
  });
}
