import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:test/test.dart';

import 'support/helpers.dart';

final _validator = SetWordValidator(<String>['MASAL', 'KALEM', 'ADAM']);

void main() {
  group('thaw at construction (t = 0)', () {
    test('a frozen row that already spells a word starts thawed', () {
      final engine = GridEngine(
        cfg(
          <String>['MASAL', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
          target: 'KALEM',
          frozen: <GridCoord>{const GridCoord(0, 2)},
        ),
        validator: _validator,
      );
      expect(
        engine.state.statusAt(const GridCoord(0, 2)),
        TileStatus.thawed,
      );
    });

    test('the word need not pass through the frozen cell (4-letter window)',
        () {
      final engine = GridEngine(
        cfg(
          <String>['ADAMX', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
          target: 'KALEM',
          frozen: <GridCoord>{const GridCoord(0, 4)}, // X, outside "ADAM"
        ),
        validator: _validator,
      );
      expect(
        engine.state.statusAt(const GridCoord(0, 4)),
        TileStatus.thawed,
      );
    });

    test('two frozen tiles in the same row thaw together', () {
      final engine = GridEngine(
        cfg(
          <String>['MASAL', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
          target: 'KALEM',
          frozen: <GridCoord>{const GridCoord(0, 0), const GridCoord(0, 3)},
        ),
        validator: _validator,
      );
      expect(engine.state.statusAt(const GridCoord(0, 0)), TileStatus.thawed);
      expect(engine.state.statusAt(const GridCoord(0, 3)), TileStatus.thawed);
    });

    test('frozen tiles in different rows are evaluated independently', () {
      final engine = GridEngine(
        cfg(
          <String>['MASAL', 'BCDFG', 'XYXYX', 'PRTUV', 'YZBCD'],
          target: 'KALEM',
          frozen: <GridCoord>{const GridCoord(0, 2), const GridCoord(2, 2)},
        ),
        validator: _validator,
      );
      expect(engine.state.statusAt(const GridCoord(0, 2)), TileStatus.thawed);
      expect(engine.state.statusAt(const GridCoord(2, 2)), TileStatus.frozen);
    });

    test('the column is never scanned — only the row', () {
      // Column 2 spells MASAL top-to-bottom; row 2 does not spell anything.
      final engine = GridEngine(
        cfg(
          <String>['XXMXX', 'XXAXX', 'XXSXX', 'XXAXX', 'XXLXX'],
          target: 'KALEM',
          frozen: <GridCoord>{const GridCoord(2, 2)},
        ),
        validator: _validator,
      );
      expect(engine.state.statusAt(const GridCoord(2, 2)), TileStatus.frozen);
    });
  });

  group('thaw on a later move', () {
    // Column-0 "down" brings row1.col0 into row2.col0. With row2 = "X A S A L"
    // and row1.col0 = "M", the move makes row 2 spell "MASAL".
    EngineConfig scenario({required String target}) => cfg(
          <String>['BCDFG', 'MHJKL', 'XASAL', 'PRTUV', 'YZBCD'],
          target: target,
          frozen: <GridCoord>{const GridCoord(2, 2)},
        );

    test('thaws when a move forms a word in the frozen row (no win)', () {
      final engine =
          GridEngine(scenario(target: 'KALEM'), validator: _validator);
      expect(engine.state.statusAt(const GridCoord(2, 2)), TileStatus.frozen);

      final step = engine.applyMove(const Move.columnDown(0));
      expect(step.applied, isTrue);
      expect(rowOf(engine.state, 2), 'MASAL');
      expect(step.thawedThisStep, isTrue);
      expect(step.solvedThisStep, isFalse);
      expect(engine.state.statusAt(const GridCoord(2, 2)), TileStatus.thawed);
      expect(engine.isSolved, isFalse);
    });

    test('thaw + win on the same move: win is terminal, move counted', () {
      final engine =
          GridEngine(scenario(target: 'MASAL'), validator: _validator);
      final step = engine.applyMove(const Move.columnDown(0));
      expect(step.applied, isTrue);
      expect(step.thawedThisStep, isTrue);
      expect(step.solvedThisStep, isTrue);
      expect(engine.isSolved, isTrue);
      expect(engine.moveCount, 1);
      expect(
        engine.applyMove(const Move.rowRight(0)).rejectedReason,
        MoveRejectReason.puzzleComplete,
      );
    });

    test('thaw is permanent — a later move that breaks the word keeps it', () {
      final engine =
          GridEngine(scenario(target: 'KALEM'), validator: _validator);
      engine.applyMove(const Move.columnDown(0)); // thaws (2,2)
      engine.applyMove(
          const Move.rowRight(2)); // now (2,2) is movable, row scrambles
      expect(rowOf(engine.state, 2), isNot('MASAL'));
      expect(engine.state.statusAt(const GridCoord(2, 2)), TileStatus.thawed);
    });

    test('undo of the causing move re-freezes the tile', () {
      final engine =
          GridEngine(scenario(target: 'KALEM'), validator: _validator);
      engine.applyMove(const Move.columnDown(0));
      expect(engine.state.statusAt(const GridCoord(2, 2)), TileStatus.thawed);

      final undo = engine.undo();
      expect(undo.applied, isTrue);
      expect(rowOf(engine.state, 2), 'XASAL');
      expect(engine.state.statusAt(const GridCoord(2, 2)), TileStatus.frozen);
      expect(engine.moveCount, 0);
    });
  });

  test('a frozen tile is immovable until it thaws', () {
    // Row 0 has a frozen tile and no word; a shift rotates around it.
    final engine = GridEngine(
      cfg(
        <String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
        target: 'WWWWW',
        frozen: <GridCoord>{const GridCoord(0, 2)},
      ),
      validator: _validator,
    );
    engine.applyMove(const Move.rowRight(0));
    // col 2 unchanged, others rotate: "E A C B D"
    expect(rowOf(engine.state, 0), 'EACBD');
    expect(engine.state.statusAt(const GridCoord(0, 2)), TileStatus.frozen);
  });
}
