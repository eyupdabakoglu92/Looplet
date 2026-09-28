import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/engine/engine_providers.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/persistence/repositories/active_session_repo.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/play/play_session_screen.dart';
import 'package:looplet_app/play/widgets/puzzle_board.dart';
import 'package:looplet_app/play/widgets/result_view.dart';
import 'package:looplet_engine/looplet_engine.dart';

/// F03-QA-03 (`architecture.md` §12): an OS pointer cancel (app switch, system
/// gesture, call) aborts the drag — no move. Flutter's pan recogniser reports a
/// cancel of an *accepted* pan through `onPanEnd`, so these tests send a real
/// `PointerCancelEvent` through the binding (`TestGesture.cancel`) rather than
/// calling handlers; a mirror that only sends the lifecycle `paused` cannot see
/// the defect.

Widget _app(AppDatabase db) => ProviderScope(
  overrides: <Override>[
    appDatabaseProvider.overrideWithValue(db),
    wordValidatorProvider.overrideWith(
      (ref) async => const NeverValidWordValidator(),
    ),
  ],
  child: const MaterialApp(
    home: PlaySessionScreen(
      args: PlaySessionArgs(
        source: PuzzleSource.journey,
        debugPuzzleId: 'smoke-tr-01',
      ),
    ),
  ),
);

Future<void> _boot(WidgetTester tester, AppDatabase db) async {
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(db));
  await tester.pumpAndSettle();
  expect(find.byType(PuzzleBoard), findsOneWidget);
}

/// Left-most cell of row 0 (`A S A L M`; one right shift wins `MASAL`).
Offset _row0Start(WidgetTester tester) {
  final box = tester.getRect(find.byType(PuzzleBoard));
  return Offset(box.left + box.width * 0.18, box.top + box.height * 0.12);
}

Future<void> _expectNoMove(WidgetTester tester, {int moves = 0}) async {
  expect(find.text('$moves'), findsOneWidget); // MOVES read-out
  expect(find.byType(ResultView), findsNothing);
}

/// The persisted resume snapshot's applied moves (`null` = no row).
Future<List<String>?> _appliedMoves(WidgetTester tester, AppDatabase db) async {
  final snap = await tester.runAsync(() => ActiveSessionRepo(db).read());
  return snap?.appliedMoves;
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  testWidgets('a PointerCancel while a row is lifted aborts: no move, not '
      'persisted — also after the app is then paused', (tester) async {
    await _boot(tester, db);

    final gesture = await tester.startGesture(_row0Start(tester));
    await gesture.moveBy(const Offset(60, 0)); // past the slop → row lifted
    await tester.pump();
    await gesture.moveBy(const Offset(40, 0)); // the winning direction
    await tester.pump();
    await gesture.cancel(); // the OS took the touch away
    await tester.pumpAndSettle();

    await _expectNoMove(tester);

    // The interruption then backgrounds the app (real order on iOS).
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    await _expectNoMove(tester);
    expect(await _appliedMoves(tester, db), isEmpty);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    await _expectNoMove(tester);

    // The board is idle again: an ordinary swipe now plays normally.
    await tester.dragFrom(_row0Start(tester), const Offset(220, 0));
    await tester.pumpAndSettle();
    expect(find.byType(ResultView), findsOneWidget);
  });

  testWidgets('a PointerCancel before the pan slop is crossed also aborts', (
    tester,
  ) async {
    await _boot(tester, db);

    final gesture = await tester.startGesture(_row0Start(tester));
    await gesture.moveBy(const Offset(6, 0)); // < 18 pt: pan not accepted yet
    await gesture.cancel();
    await tester.pumpAndSettle();
    await _expectNoMove(tester);

    await tester.dragFrom(_row0Start(tester), const Offset(220, 0));
    await tester.pumpAndSettle();
    expect(find.byType(ResultView), findsOneWidget);
  });

  testWidgets('a genuine release still resolves — inside the plate', (
    tester,
  ) async {
    await _boot(tester, db);

    final gesture = await tester.startGesture(_row0Start(tester));
    await gesture.moveBy(const Offset(60, 0));
    await gesture.moveBy(const Offset(60, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.byType(ResultView), findsOneWidget); // the 1-move win
  });

  testWidgets('a genuine release still resolves — outside the plate', (
    tester,
  ) async {
    await _boot(tester, db);
    final box = tester.getRect(find.byType(PuzzleBoard));

    final start = _row0Start(tester);
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(Offset(box.width * 0.3, 0));
    // The finger runs on well past the board's right edge before lifting.
    await gesture.moveBy(Offset(box.width * 0.9, 0));
    expect(box.contains(start + Offset(box.width * 1.2, 0)), isFalse);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.byType(ResultView), findsOneWidget);
  });

  testWidgets('a non-winning release still commits exactly one move and '
      'persists it (unchanged branch)', (tester) async {
    await _boot(tester, db);

    // Row 1 (`B C D F G`): a right shift is legal but not a win → MOVES 1.
    final box = tester.getRect(find.byType(PuzzleBoard));
    final row1 = Offset(
      box.left + box.width * 0.18,
      box.top + box.height * 0.32,
    );
    final gesture = await tester.startGesture(row1);
    await gesture.moveBy(const Offset(120, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(find.byType(ResultView), findsNothing);
    expect(await _appliedMoves(tester, db), <String>['R1']);
  });
}
