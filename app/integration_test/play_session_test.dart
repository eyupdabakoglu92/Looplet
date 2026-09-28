// F03-FE9 — on-device runtime-validation suite for the puzzle-play screen.
//
// Covers `qa.md §17` scenarios 1–4 with the `integration_test` binding:
//   1. gesture → shift wiring at 2 surface sizes (small + large logical width)
//   2. 0 double-registered moves during the ~190 ms animation window
//   3. kill / relaunch resume + a tampered `thawedFrozenCells` cache is
//      re-derived, not trusted
//   4. app lifecycle — `paused` mid-drag cancels; `paused` mid-animation commits
//      a settled move; `resumed` is safe
//
// Intended run: `flutter test integration_test -d <device-or-emulator>` (the
// CI `integration` job / a device-matrix pass). This is a **best-effort** gate
// per `project-authority/release.md §4` — failure is investigated, not
// auto-blocking. A headless `flutter test integration_test/` run is slow and
// timing-sensitive for this app's drift-backed boot; group 4 never requests a
// frame while the app is paused (see the comment there); the fast, always-green
// automated coverage of the same scenarios lives in
// `test/play/play_session_runtime_test.dart`. The visual items (`qa.md §17`
// 5–7) are the manual device pass — see `frontend.md` "F03-FE9".

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:looplet_app/engine/engine_providers.dart';
import 'package:looplet_app/persistence/active_session_snapshot.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/persistence/repositories/active_session_repo.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/play/play_session_screen.dart';
import 'package:looplet_app/design/design.dart';
import 'package:looplet_app/play/play_layout.dart';
import 'package:looplet_app/play/widgets/result_view.dart';
import 'package:looplet_app/play/widgets/puzzle_board.dart';
import 'package:looplet_engine/looplet_engine.dart';

const _small = Size(360, 780);
const _large = Size(430, 932);

Widget _app(AppDatabase db, String debugPuzzleId) => ProviderScope(
  overrides: <Override>[
    appDatabaseProvider.overrideWithValue(db),
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

AppDatabase _freshDb() => AppDatabase.forTesting(NativeDatabase.memory());

Offset _rowStart(WidgetTester tester, int row) {
  final box = tester.getRect(find.byType(PuzzleBoard));
  return box.topLeft + BoardGeometry.forWidth(box.width).cellCenter(row, 0);
}

int _moves(WidgetTester tester) {
  for (var n = 0; n <= 99; n++) {
    if (find.text('$n').evaluate().isNotEmpty) return n;
  }
  return -1;
}

Future<void> _flush(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 200));

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

/// The play screen's setup + snapshot read are real async futures; poll until
/// the board is on-stage instead of relying on a single `pumpAndSettle`.
Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 12),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 40));
    if (finder.evaluate().isNotEmpty) {
      await tester.pumpAndSettle();
      return;
    }
  }
  throw StateError('timed out waiting for $finder');
}

Future<void> _bootTo(WidgetTester tester, AppDatabase db, String id) async {
  await tester.pumpWidget(_app(db, id));
  await _pumpUntil(tester, find.byType(PuzzleBoard));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('1 — gesture → shift wiring at 2 surface sizes (AC2/AC3/AC4)', () {
    for (final size in <Size>[_small, _large]) {
      final label = '${size.width.toInt()}x${size.height.toInt()}';

      testWidgets(
        '$label — a row-0 right swipe forms the target → completion',
        (tester) async {
          await tester.binding.setSurfaceSize(size);
          await _bootTo(tester, _freshDb(), 'smoke-tr-01');
          expect(_moves(tester), 0);

          await tester.dragFrom(_rowStart(tester, 0), const Offset(140, 0));
          await tester.pumpAndSettle();

          expect(find.byType(ResultView), findsOneWidget);
          expect(find.text('Döngü\ntamamlandı.'), findsOneWidget);
          await _unmount(tester);
        },
      );

      testWidgets('$label — a sub-threshold drag does not move (AC4)', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(size);
        await _bootTo(tester, _freshDb(), 'smoke-tr-01');

        await tester.dragFrom(_rowStart(tester, 2), const Offset(6, 4));
        await tester.pumpAndSettle();

        expect(_moves(tester), 0);
        expect(find.byType(ResultView), findsNothing);
        await _unmount(tester);
      });

      testWidgets('$label — a rejected column move → MOVES unchanged', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(size);
        await _bootTo(tester, _freshDb(), 'smoke-tr-01');

        await tester.dragFrom(_rowStart(tester, 2), const Offset(0, 140));
        await tester.pumpAndSettle();

        expect(_moves(tester), 0);
        expect(find.byType(ResultView), findsNothing);
        await _unmount(tester);
      });
    }
  });

  group('2 — no double-registered moves during the animation window (AC5)', () {
    testWidgets('a second drag during the ~190 ms shift is dropped', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(_large);
      await _bootTo(tester, _freshDb(), 'smoke-tr-02');

      await tester.dragFrom(_rowStart(tester, 1), const Offset(140, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      await tester.dragFrom(_rowStart(tester, 1), const Offset(140, 0));
      await tester.pumpAndSettle();

      expect(_moves(tester), 1);
      await _unmount(tester);
    });

    testWidgets(
      'rapid same-row swipes each count only after the previous settles',
      (tester) async {
        await tester.binding.setSurfaceSize(_large);
        await _bootTo(tester, _freshDb(), 'smoke-tr-02');

        await tester.dragFrom(_rowStart(tester, 1), const Offset(140, 0));
        await tester.pumpAndSettle();
        await tester.dragFrom(_rowStart(tester, 1), const Offset(140, 0));
        await tester.pumpAndSettle();

        expect(_moves(tester), 2);
        await _unmount(tester);
      },
    );
  });

  group('3 — kill / relaunch resume (AC10)', () {
    testWidgets('MOVES + restart survive a dispose + remount on the same DB', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(_large);
      final db = _freshDb();

      await _bootTo(tester, db, 'smoke-tr-02');
      for (var i = 0; i < 3; i++) {
        await tester.dragFrom(_rowStart(tester, 1), const Offset(140, 0));
        await tester.pumpAndSettle();
      }
      expect(_moves(tester), 3);
      await _flush(tester);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await _bootTo(tester, db, 'smoke-tr-02');
      expect(_moves(tester), 3);

      await tester.tap(find.byType(GlassIconButton));
      await tester.pumpAndSettle();
      expect(_moves(tester), 0);
      await _flush(tester);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await _bootTo(tester, db, 'smoke-tr-02');
      expect(_moves(tester), 0);
      await _unmount(tester);
    });

    testWidgets(
      'a tampered thawedFrozenCells cache is re-derived, not trusted',
      (tester) async {
        await tester.binding.setSurfaceSize(_large);
        final db = _freshDb();

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

        await _bootTo(tester, db, 'smoke-tr-06');

        final tiles = tester
            .widgetList<TileFace>(find.byType(TileFace))
            .toList();
        final frozen = tiles.where((t) => t.state == TileState.frozen).toList();
        expect(frozen, hasLength(1));
        expect(frozen.single.letter, 'S');
        await _unmount(tester);
      },
    );
  });

  // F03-QA-02 / F03-FE-INTEG: on a LIVE binding `handleAppLifecycleStateChanged(
  // paused)` switches frame scheduling off (as the OS does), so any `pump` /
  // `pumpAndSettle` issued while paused never completes — the previous form of
  // these tests hung for ~17 min. The rule here: never request a frame while
  // paused; assert what must already be true *at pause* straight from the store,
  // then resume and settle. A 90 s timeout turns any future hang into a fast
  // failure.
  group('4 — app lifecycle (architecture.md §12)', () {
    const hangGuard = Timeout(Duration(seconds: 90));

    testWidgets(
      'paused mid-drag cancels the gesture, no move',
      timeout: hangGuard,
      (tester) async {
        await tester.binding.setSurfaceSize(_large);
        final db = _freshDb();
        await _bootTo(tester, db, 'smoke-tr-02');

        final gesture = await tester.startGesture(_rowStart(tester, 1));
        await gesture.moveBy(const Offset(40, 0));
        await tester.pump(); // frames still enabled: the row is lifted
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        // Paused: no pump. The pointer up is a plain event dispatch.
        await gesture.up();
        // The cancelled gesture must not have persisted a move.
        final atPause = await ActiveSessionRepo(db).read();
        expect(atPause?.moveCount ?? 0, 0);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();

        expect(_moves(tester), 0);
        expect(tester.takeException(), isNull);
        await _unmount(tester);
      },
    );

    testWidgets(
      'an OS pointer cancel mid-drag aborts, then the app pauses — no move '
      '(F03-QA-03)',
      timeout: hangGuard,
      (tester) async {
        await tester.binding.setSurfaceSize(_large);
        final db = _freshDb();
        await _bootTo(tester, db, 'smoke-tr-02');

        final gesture = await tester.startGesture(_rowStart(tester, 1));
        await gesture.moveBy(const Offset(40, 0));
        await tester.pump(); // frames still enabled: the row is lifted
        // The real iOS order: the OS cancels the touch first…
        await gesture.cancel();
        await tester.pump();
        // …then the app leaves the foreground. Paused: no pump.
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        final atPause = await ActiveSessionRepo(db).read();
        expect(atPause?.moveCount ?? 0, 0, reason: 'no move persisted');
        expect(atPause?.appliedMoves ?? const <String>[], isEmpty);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();

        expect(_moves(tester), 0);
        expect(tester.takeException(), isNull);
        await _unmount(tester);
      },
    );

    testWidgets(
      'paused mid-animation commits a settled move (never torn)',
      timeout: hangGuard,
      (tester) async {
        await tester.binding.setSurfaceSize(_large);
        final db = _freshDb();
        await _bootTo(tester, db, 'smoke-tr-02');

        await tester.dragFrom(_rowStart(tester, 1), const Offset(140, 0));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50)); // mid-shift
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        // `onAppPaused` commits the in-flight shift synchronously and persists;
        // give the fire-and-forget write a moment without scheduling a frame.
        await Future<void>.delayed(const Duration(milliseconds: 300));
        final atPause = await ActiveSessionRepo(db).read();
        expect(
          atPause?.moveCount,
          1,
          reason: 'settled move persisted at pause',
        );
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();

        expect(_moves(tester), 1);
        expect(tester.takeException(), isNull);
        await _flush(tester);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await _bootTo(tester, db, 'smoke-tr-02');
        expect(_moves(tester), 1);
        await _unmount(tester);
      },
    );
  });
}
