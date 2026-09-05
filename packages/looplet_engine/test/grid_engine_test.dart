import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:test/test.dart';

import 'support/helpers.dart';

const _validator = NeverValidWordValidator();

EngineConfig plain() => cfg(
      <String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
      target: 'WWWWW',
    );

void main() {
  test('moveCount increments only on applied moves', () {
    final engine = GridEngine(plain(), validator: _validator);
    engine
      ..applyMove(const Move.rowRight(0))
      ..applyMove(const Move.rowRight(0))
      ..applyMove(const Move.rowLeft(1));
    expect(engine.moveCount, 3);

    engine.applyMove(const Move.rowLeft(99)); // rejected
    expect(engine.moveCount, 3);
  });

  test('undo reverts exactly the last move and the counter', () {
    final engine = GridEngine(plain(), validator: _validator);
    for (var i = 0; i < 5; i++) {
      engine.applyMove(const Move.rowRight(2));
    }
    final afterFive = gridOf(engine.state);

    // Compare against an independent engine taken to 4 moves.
    final reference = GridEngine(plain(), validator: _validator);
    for (var i = 0; i < 4; i++) {
      reference.applyMove(const Move.rowRight(2));
    }

    final undo = engine.undo();
    expect(undo.applied, isTrue);
    expect(engine.moveCount, 4);
    expect(gridOf(engine.state), gridOf(reference.state));
    expect(gridOf(engine.state), isNot(afterFive));
    expect(engine.appliedMoves, hasLength(4));
  });

  test('undo with no history is rejected', () {
    final engine = GridEngine(plain(), validator: _validator);
    final undo = engine.undo();
    expect(undo.applied, isFalse);
    expect(undo.rejectedReason, MoveRejectReason.nothingToUndo);
    expect(engine.moveCount, 0);
  });

  test('undo back to zero returns the initial grid', () {
    final engine = GridEngine(plain(), validator: _validator);
    engine
      ..applyMove(const Move.rowRight(0))
      ..applyMove(const Move.columnDown(3));
    engine.undo();
    engine.undo();
    expect(engine.moveCount, 0);
    expect(gridOf(engine.state), 'ABCDE/FGHIJ/KLMNO/PRTUV/YZBCD');
  });

  test('restart clears history and restores the initial grid', () {
    final engine = GridEngine(plain(), validator: _validator);
    engine
      ..applyMove(const Move.rowRight(0))
      ..applyMove(const Move.rowRight(0))
      ..applyMove(const Move.columnUp(1));
    engine.restart();
    expect(engine.moveCount, 0);
    expect(engine.appliedMoves, isEmpty);
    expect(gridOf(engine.state), 'ABCDE/FGHIJ/KLMNO/PRTUV/YZBCD');
  });

  test('appliedMoves is an unmodifiable view', () {
    final engine = GridEngine(plain(), validator: _validator);
    engine.applyMove(const Move.rowRight(0));
    expect(
      () => engine.appliedMoves.add(const Move.rowLeft(0)),
      throwsUnsupportedError,
    );
  });

  group('restoreMoves', () {
    test('produces the same state as replaying the moves one by one', () {
      final moves = <Move>[
        const Move.rowRight(0),
        const Move.columnDown(2),
        const Move.rowLeft(4),
        const Move.columnUp(1),
      ];

      final replayed = GridEngine(plain(), validator: _validator);
      for (final m in moves) {
        replayed.applyMove(m);
      }

      final restored = GridEngine(plain(), validator: _validator);
      restored.restoreMoves(moves);

      expect(gridOf(restored.state), gridOf(replayed.state));
      expect(restored.moveCount, moves.length);
      expect(restored.appliedMoves, moves);
    });

    test('throws if a persisted move does not apply', () {
      final engine = GridEngine(plain(), validator: _validator);
      expect(
        () => engine.restoreMoves(<Move>[const Move.rowLeft(42)]),
        throwsStateError,
      );
    });
  });

  test('the state views cannot mutate engine state', () {
    final engine = GridEngine(plain(), validator: _validator);
    expect(() => engine.state.letters[0][0] = 'Z', throwsUnsupportedError);
    expect(
      () => engine.state.thawedCells.add(const GridCoord(0, 0)),
      throwsUnsupportedError,
    );
  });
}
