import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:test/test.dart';

import 'support/helpers.dart';

const _validator = NeverValidWordValidator();

EngineConfig withLocked(Set<GridCoord> locked) => cfg(
      <String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRSTU', 'VYZAB'],
      target: 'WWWWW',
      locked: locked,
    );

void main() {
  test('locked tile stays put; the rest rotate around it (worked example)', () {
    // Row 0 "A B [C] D E", C locked at col 2, shift right -> "E A C B D".
    final engine = GridEngine(
      withLocked(<GridCoord>{const GridCoord(0, 2)}),
      validator: _validator,
    );
    final step = engine.applyMove(const Move.rowRight(0));
    expect(step.applied, isTrue);
    expect(rowOf(engine.state, 0), 'EACBD');
    expect(engine.state.statusAt(const GridCoord(0, 2)), TileStatus.locked);
  });

  test('left rotation around a locked tile is the inverse of right', () {
    final engine = GridEngine(
      withLocked(<GridCoord>{const GridCoord(0, 2)}),
      validator: _validator,
    );
    engine
      ..applyMove(const Move.rowRight(0))
      ..applyMove(const Move.rowLeft(0));
    expect(rowOf(engine.state, 0), 'ABCDE');
  });

  test('locked tile at every column position keeps its letter', () {
    for (var lockCol = 0; lockCol < 5; lockCol++) {
      final engine = GridEngine(
        withLocked(<GridCoord>{GridCoord(0, lockCol)}),
        validator: _validator,
      );
      final lockedLetter = engine.state.letters[0][lockCol];
      engine.applyMove(const Move.rowRight(0));
      expect(
        engine.state.letters[0][lockCol],
        lockedLetter,
        reason: 'locked col $lockCol',
      );
    }
  });

  test('two locked tiles in one row: both fixed, the other three rotate', () {
    // Row 0 "A B [C] [D] E" -> shift right -> non-locked positions [0,1,4]
    // hold [A,B,E] -> forward rotation -> col0=E, col1=A, col4=B.
    final engine = GridEngine(
      withLocked(<GridCoord>{const GridCoord(0, 2), const GridCoord(0, 3)}),
      validator: _validator,
    );
    engine.applyMove(const Move.rowRight(0));
    expect(rowOf(engine.state, 0), 'EACDB');
  });

  test('a fully locked row is a no-op and is not counted', () {
    final engine = GridEngine(
      withLocked(<GridCoord>{
        const GridCoord(0, 0),
        const GridCoord(0, 1),
        const GridCoord(0, 2),
        const GridCoord(0, 3),
        const GridCoord(0, 4),
      }),
      validator: _validator,
    );
    final step = engine.applyMove(const Move.rowRight(0));
    expect(step.applied, isFalse);
    expect(step.rejectedReason, MoveRejectReason.lineFullyImmovable);
    expect(engine.moveCount, 0);
    expect(rowOf(engine.state, 0), 'ABCDE');
  });

  test('a row with a single movable cell is also fully immovable', () {
    final engine = GridEngine(
      withLocked(<GridCoord>{
        const GridCoord(1, 0),
        const GridCoord(1, 1),
        const GridCoord(1, 2),
        const GridCoord(1, 3),
      }),
      validator: _validator,
    );
    final step = engine.applyMove(const Move.rowLeft(1));
    expect(step.applied, isFalse);
    expect(step.rejectedReason, MoveRejectReason.lineFullyImmovable);
  });

  test('a row with exactly two movable cells swaps them (real move)', () {
    final engine = GridEngine(
      withLocked(<GridCoord>{
        const GridCoord(2, 1),
        const GridCoord(2, 2),
        const GridCoord(2, 3),
      }),
      validator: _validator,
    );
    // movable cols [0,4] hold [K,O] -> any shift swaps -> "O L M N K".
    final step = engine.applyMove(const Move.rowRight(2));
    expect(step.applied, isTrue);
    expect(rowOf(engine.state, 2), 'OLMNK');
    expect(engine.moveCount, 1);
  });

  test('locked cell also anchors its column', () {
    final engine = GridEngine(
      withLocked(<GridCoord>{const GridCoord(2, 0)}),
      validator: _validator,
    );
    // column 0 = A F [K] P V, K locked -> shift down -> movable rows [0,1,3,4]
    // hold [A,F,P,V] -> forward -> row0=V, row1=A, row3=F, row4=P.
    engine.applyMove(const Move.columnDown(0));
    expect(engine.state.letters.map((r) => r[0]).join(), 'VAKFP');
  });
}
