import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/persistence/active_session_snapshot.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/repositories/active_session_repo.dart';
import 'package:looplet_app/play/debug_puzzle_library.dart';
import 'package:looplet_app/play/play_session_controller.dart';
import 'package:looplet_engine/looplet_engine.dart';

/// level01: row 0 is `A S A L M`; one right-shift makes `M A S A L` = MASAL.
PlaySessionController _fresh(
  ActiveSessionRepo repo, {
  String id = 'smoke-tr-01',
}) {
  final puzzle = const DebugPuzzleLibrary().load(id);
  return PlaySessionController(
    puzzle: puzzle,
    source: PuzzleSource.journey,
    validator: const NeverValidWordValidator(),
    activeSessionRepo: repo,
    clock: () => DateTime.utc(2026, 9, 6, 12),
  );
}

Future<Move> _solveMove(PlaySessionController c) async {
  // Drag row 0 to the right.
  c.beginDrag(startRow: 0, startCol: 0);
  c.updateDrag(const Offset(40, 0));
  final res = c.endDrag(const Offset(40, 0));
  expect(res, DragResolution.shift);
  return const Move.rowRight(0);
}

void main() {
  late AppDatabase db;
  late ActiveSessionRepo repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ActiveSessionRepo(db);
  });

  tearDown(() => db.close());

  test('cancelDrag while tracking → idle, line dropped, no move, no write '
      '(F03-QA-03)', () async {
    final c = _fresh(repo);
    await c.whenPersisted;

    c.beginDrag(startRow: 0, startCol: 0);
    c.updateDrag(const Offset(40, 0));
    expect(c.phase, PlaySessionPhase.tracking);
    expect(c.activeLine, isNotNull);

    c.cancelDrag();
    expect(c.phase, PlaySessionPhase.idle);
    expect(c.activeLine, isNull);
    expect(c.moveCount, 0);

    // A release delivered after the cancel resolves nothing.
    expect(c.endDrag(const Offset(40, 0)), DragResolution.none);
    expect(c.moveCount, 0);

    await c.whenPersisted;
    expect((await repo.read())!.appliedMoves, isEmpty);
    c.dispose();
  });

  test('cancelDrag is inert outside tracking (idle, animatingShift)', () async {
    final c = _fresh(repo);
    await c.whenPersisted;

    c.cancelDrag(); // idle
    expect(c.phase, PlaySessionPhase.idle);

    await _solveMove(c); // → animatingShift, move already applied
    c.cancelDrag();
    expect(c.phase, PlaySessionPhase.animatingShift);
    c.dispose();
  });

  test('fresh start writes an initial in-progress snapshot', () async {
    final c = _fresh(repo);
    await c.whenPersisted;
    final snap = await repo.read();
    expect(snap, isNotNull);
    expect(snap!.puzzleId, 'smoke-tr-01');
    expect(snap.status, ActiveSessionStatus.inProgress);
    expect(snap.moveCount, 0);
    expect(snap.undosRemaining, 3);
    c.dispose();
  });

  test(
    'a legal drag → shift phase → commitShift → idle + MOVES 1 + persisted',
    () async {
      final c = _fresh(repo);
      await c.whenPersisted;

      c.beginDrag(startRow: 1, startCol: 1);
      c.updateDrag(const Offset(40, 0));
      // Row 1 = B C D F G → a right shift is legal but not a win.
      expect(c.endDrag(const Offset(40, 0)), DragResolution.shift);
      expect(c.phase, PlaySessionPhase.animatingShift);

      final won = c.commitShift();
      expect(won, isFalse);
      expect(c.phase, PlaySessionPhase.idle);
      expect(c.moveCount, 1);

      await c.whenPersisted;
      final snap = await repo.read();
      expect(snap!.moveCount, 1);
      expect(snap.appliedMoves, <String>['R1']);
      c.dispose();
    },
  );

  test(
    'solving the puzzle → won, wonRow 0, completed snapshot then cleared',
    () async {
      final c = _fresh(repo);
      await c.whenPersisted;

      await _solveMove(c);
      final won = c.commitShift();
      expect(won, isTrue);
      expect(c.phase, PlaySessionPhase.won);
      expect(c.wonRow, 0);
      expect(c.isSolved, isTrue);

      await c.whenPersisted;
      // completed snapshot written, then the active row cleared (AC on completion).
      expect(await repo.read(), isNull);
      c.dispose();
    },
  );

  test('rejected move → bounce phase → commitBounce → idle, MOVES unchanged, '
      'nothing persisted', () async {
    final c = _fresh(repo);
    await c.whenPersisted;
    // level01 has columnMovesEnabled == false → a vertical drag is rejected.
    c.beginDrag(startRow: 0, startCol: 2);
    c.updateDrag(const Offset(0, 40));
    expect(c.endDrag(const Offset(0, 40)), DragResolution.bounce);
    expect(c.phase, PlaySessionPhase.animatingBounce);
    c.commitBounce();
    expect(c.phase, PlaySessionPhase.idle);
    expect(c.moveCount, 0);

    final snap = await repo.read();
    expect(snap!.moveCount, 0); // still the initial snapshot
    c.dispose();
  });

  test('no input queue — beginDrag is ignored while not idle', () {
    final c = _fresh(repo);
    c.beginDrag(startRow: 1, startCol: 1);
    c.updateDrag(const Offset(40, 0));
    c.endDrag(const Offset(40, 0)); // → animatingShift
    expect(c.phase, PlaySessionPhase.animatingShift);

    c.beginDrag(startRow: 2, startCol: 2); // must be ignored
    expect(c.phase, PlaySessionPhase.animatingShift);
    c.dispose();
  });

  test(
    'undo: consumes the quota, restores state, stops at 0 with no effect',
    () async {
      final c = _fresh(repo, id: 'smoke-tr-02'); // 2-move puzzle, no win on R1
      await c.whenPersisted;

      for (var i = 0; i < 3; i++) {
        c.beginDrag(startRow: 1, startCol: 1);
        c.updateDrag(const Offset(40, 0));
        c.endDrag(const Offset(40, 0));
        c.commitShift();
      }
      expect(c.moveCount, 3);
      expect(c.undosRemaining, 3);
      expect(c.canUndo, isTrue);

      expect(c.undo(), isTrue);
      expect(c.undo(), isTrue);
      expect(c.undo(), isTrue);
      expect(c.moveCount, 0);
      expect(c.undosRemaining, 0);
      expect(c.canUndo, isFalse);

      // A 4th undo is a no-op (AC6) — no throw, no state change.
      expect(c.undo(), isFalse);
      expect(c.moveCount, 0);
      c.dispose();
    },
  );

  test('restart: MOVES 0, undos back to 3, restartCount++', () async {
    final c = _fresh(repo, id: 'smoke-tr-02');
    await c.whenPersisted;

    c.beginDrag(startRow: 1, startCol: 1);
    c.updateDrag(const Offset(40, 0));
    c.endDrag(const Offset(40, 0));
    c.commitShift();
    c.undo();
    expect(c.moveCount, 0);
    expect(c.undosRemaining, 2);

    expect(c.restart(), isTrue);
    expect(c.moveCount, 0);
    expect(c.undosRemaining, 3);
    expect(c.restartCount, 1);

    await c.whenPersisted;
    final snap = await repo.read();
    expect(snap!.restartCount, 1);
    c.dispose();
  });

  test('hydrate from a matching snapshot restores counters + moves', () async {
    // Seed a snapshot: one R1 move, 1 undo used, 2 restarts, some elapsed.
    await repo.save(
      ActiveSessionSnapshot(
        puzzleId: 'smoke-tr-02',
        puzzleSource: PuzzleSource.journey,
        lang: 'tr',
        appliedMoves: const <String>['R1'],
        undosRemaining: 2,
        restartCount: 2,
        elapsedMsAccumulated: 41200,
        thawedFrozenCells: const <String>[],
        status: ActiveSessionStatus.inProgress,
        startedAtUtcMs: 1757145000000,
        lastPersistedAtUtcMs: 1757145041200,
      ),
    );

    final snap = await repo.read();
    final puzzle = const DebugPuzzleLibrary().load('smoke-tr-02');
    final c = PlaySessionController(
      puzzle: puzzle,
      source: PuzzleSource.journey,
      validator: const NeverValidWordValidator(),
      activeSessionRepo: repo,
      restoreFrom: snap,
    );

    expect(c.hydratedFromSnapshot, isTrue);
    expect(c.moveCount, 1);
    expect(c.undosRemaining, 2);
    expect(c.restartCount, 2);
    c.dispose();
  });

  test(
    'paused mid-shift-animation commits the move (never a torn snapshot)',
    () async {
      final c = _fresh(repo, id: 'smoke-tr-02');
      await c.whenPersisted;

      c.beginDrag(startRow: 1, startCol: 1);
      c.updateDrag(const Offset(40, 0));
      c.endDrag(const Offset(40, 0));
      expect(c.phase, PlaySessionPhase.animatingShift);

      c.onAppPaused(); // app backgrounded before the widget animation settled
      expect(c.phase, PlaySessionPhase.idle);
      expect(c.moveCount, 1);

      await c.whenPersisted;
      final snap = await repo.read();
      expect(snap!.moveCount, 1);
      expect(snap.appliedMoves, <String>['R1']);
      c.dispose();
    },
  );

  test('paused mid-drag cancels the gesture without a move', () async {
    final c = _fresh(repo);
    await c.whenPersisted;
    c.beginDrag(startRow: 2, startCol: 2);
    c.updateDrag(const Offset(40, 0));
    expect(c.phase, PlaySessionPhase.tracking);

    c.onAppPaused();
    expect(c.phase, PlaySessionPhase.idle);
    expect(c.moveCount, 0);
    c.dispose();
  });
}
