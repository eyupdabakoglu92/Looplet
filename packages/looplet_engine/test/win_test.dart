import 'package:looplet_engine/looplet_engine.dart';
import 'package:test/test.dart';

import 'support/helpers.dart';

const _validator = NeverValidWordValidator();

void main() {
  test('win when a row settles as the target, left to right', () {
    // Row 1 = "A S A L M"; shift right once -> "M A S A L" == target.
    final engine = GridEngine(
      cfg(
        <String>['BCDFG', 'ASALM', 'HJKLN', 'PRTUV', 'YZBCD'],
        target: 'MASAL',
      ),
      validator: _validator,
    );
    final step = engine.applyMove(const Move.rowRight(1));
    expect(step.applied, isTrue);
    expect(step.solvedThisStep, isTrue);
    expect(engine.isSolved, isTrue);
  });

  test('target matches regardless of letter casing', () {
    final engine = GridEngine(
      cfg(
        <String>['masal', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
        target: 'MASAL',
      ),
      validator: _validator,
    );
    expect(engine.isSolved, isTrue); // pre-solved at t = 0
  });

  test('a reversed row does not win', () {
    final engine = GridEngine(
      cfg(
        <String>['LASAM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
        target: 'MASAL',
      ),
      validator: _validator,
    );
    expect(engine.isSolved, isFalse);
  });

  test('the target spelled down a column does not win', () {
    final engine = GridEngine(
      cfg(
        <String>['MXXXX', 'AXXXX', 'SXXXX', 'AXXXX', 'LXXXX'],
        target: 'MASAL',
      ),
      validator: _validator,
    );
    expect(engine.isSolved, isFalse);
  });

  test('repeated target letters are matched positionally', () {
    // "MASAL" has two A. A row of {M,A,S,A,L} in the wrong order must not win.
    final engine = GridEngine(
      cfg(
        <String>['MSAAL', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
        target: 'MASAL',
      ),
      validator: _validator,
    );
    expect(engine.isSolved, isFalse);
  });

  test('counter freezes and moves are rejected after a win', () {
    final engine = GridEngine(
      cfg(
        <String>['ASALM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
        target: 'MASAL',
      ),
      validator: _validator,
    );
    engine.applyMove(const Move.rowRight(0)); // -> MASAL, win
    expect(engine.moveCount, 1);

    final blocked = engine.applyMove(const Move.rowLeft(3));
    expect(blocked.applied, isFalse);
    expect(blocked.rejectedReason, MoveRejectReason.puzzleComplete);
    expect(engine.moveCount, 1);

    final blockedUndo = engine.undo();
    expect(blockedUndo.applied, isFalse);
    expect(blockedUndo.rejectedReason, MoveRejectReason.puzzleComplete);
  });

  test('restart works after a win', () {
    final engine = GridEngine(
      cfg(
        <String>['ASALM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
        target: 'MASAL',
      ),
      validator: _validator,
    );
    engine.applyMove(const Move.rowRight(0));
    expect(engine.isSolved, isTrue);

    engine.restart();
    expect(engine.isSolved, isFalse);
    expect(engine.moveCount, 0);
    expect(rowOf(engine.state, 0), 'ASALM');
  });
}
