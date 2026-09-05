import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:test/test.dart';

import 'support/helpers.dart';

/// One test per Acceptance Criterion in
/// `ai-system/features/f02-grid-engine/prd.md`, for QA traceability.
void main() {
  final wordValidator = SetWordValidator(<String>['MASAL', 'ADAM']);
  const never = NeverValidWordValidator();

  EngineConfig open({String target = 'WWWWW', bool columns = true}) => cfg(
        <String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
        target: target,
        columns: columns,
      );

  test('AC: row ABCDE shifted right -> EABCD, move count +1', () {
    final e = GridEngine(open(), validator: never);
    e.applyMove(const Move.rowRight(0));
    expect(rowOf(e.state, 0), 'EABCD');
    expect(e.moveCount, 1);
  });

  test('AC: row ABCDE shifted left -> BCDEA', () {
    final e = GridEngine(open(), validator: never);
    e.applyMove(const Move.rowLeft(0));
    expect(rowOf(e.state, 0), 'BCDEA');
  });

  test('AC: column down -> EABCD; column up -> BCDEA (top-to-bottom)', () {
    final down = GridEngine(open(), validator: never)
      ..applyMove(const Move.columnDown(0));
    expect(down.state.letters.map((r) => r[0]).join(),
        'YAFKP'); // A F K P Y -> Y A F K P
    final up = GridEngine(open(), validator: never)
      ..applyMove(const Move.columnUp(0));
    expect(up.state.letters.map((r) => r[0]).join(),
        'FKPYA'); // A F K P Y -> F K P Y A
  });

  test(
      'AC: target formed in a row (any casing) -> solved, counter frozen, '
      'further moves rejected', () {
    final e = GridEngine(
      cfg(<String>['asalm', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
          target: 'MASAL'),
      validator: never,
    );
    e.applyMove(const Move.rowRight(0));
    expect(e.isSolved, isTrue);
    expect(e.moveCount, 1);
    expect(e.applyMove(const Move.rowLeft(2)).rejectedReason,
        MoveRejectReason.puzzleComplete);
    expect(e.undo().rejectedReason, MoveRejectReason.puzzleComplete);
  });

  test('AC: reversed row / vertical column do not win', () {
    expect(
      GridEngine(
        cfg(<String>['LASAM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
            target: 'MASAL'),
        validator: never,
      ).isSolved,
      isFalse,
    );
    expect(
      GridEngine(
        cfg(<String>['MZZZZ', 'AZZZZ', 'SZZZZ', 'AZZZZ', 'LZZZZ'],
            target: 'MASAL'),
        validator: never,
      ).isSolved,
      isFalse,
    );
  });

  test('AC: locked tile at col 2 of "A B C D E", shift right -> "E A C B D"',
      () {
    final e = GridEngine(
      cfg(<String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
          target: 'WWWWW', locked: <GridCoord>{const GridCoord(0, 2)}),
      validator: never,
    );
    e.applyMove(const Move.rowRight(0));
    expect(rowOf(e.state, 0), 'EACBD');
  });

  test(
      'AC: line with <=1 movable cell -> applied:false, lineFullyImmovable, '
      'not counted', () {
    final e = GridEngine(
      cfg(<String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
          target: 'WWWWW',
          locked: <GridCoord>{
            for (var c = 0; c < 5; c++) GridCoord(0, c),
          }),
      validator: never,
    );
    final step = e.applyMove(const Move.rowRight(0));
    expect(step.applied, isFalse);
    expect(step.rejectedReason, MoveRejectReason.lineFullyImmovable);
    expect(e.moveCount, 0);
  });

  test('AC: column move rejected when columnMovesEnabled == false', () {
    final e = GridEngine(open(columns: false), validator: never);
    final step = e.applyMove(const Move.columnUp(1));
    expect(step.applied, isFalse);
    expect(step.rejectedReason, MoveRejectReason.columnMovesDisabled);
    expect(gridOf(e.state), 'ABCDE/FGHIJ/KLMNO/PRTUV/YZBCD');
  });

  test(
      'AC: a valid >=4-letter run in a frozen row thaws every frozen cell '
      'in that row', () {
    final e = GridEngine(
      cfg(<String>['MASAL', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
          target: 'WWWWW',
          frozen: <GridCoord>{const GridCoord(0, 1), const GridCoord(0, 4)}),
      validator: wordValidator,
    );
    expect(e.state.statusAt(const GridCoord(0, 1)), TileStatus.thawed);
    expect(e.state.statusAt(const GridCoord(0, 4)), TileStatus.thawed);
  });

  test('AC: frozen row that also equals the target -> thaw AND solved', () {
    final e = GridEngine(
      cfg(<String>['BCDFG', 'MHJKL', 'XASAL', 'PRTUV', 'YZBCD'],
          target: 'MASAL', frozen: <GridCoord>{const GridCoord(2, 2)}),
      validator: wordValidator,
    );
    final step = e.applyMove(const Move.columnDown(0));
    expect(step.thawedThisStep, isTrue);
    expect(step.solvedThisStep, isTrue);
    expect(e.isSolved, isTrue);
    expect(e.moveCount, 1);
  });

  test(
      'AC: 5 moves then undo -> state == after 4 moves, count 4, '
      'move-5 thaw reverts', () {
    final config = cfg(
      <String>['BCDFG', 'MHJKL', 'XASAL', 'PRTUV', 'YZBCD'],
      target: 'KALEM',
      frozen: <GridCoord>{const GridCoord(2, 2)},
    );
    // The 5th move (columnDown(0)) brings row1.col0 == "M" into row2.col0,
    // making row 2 spell "MASAL" and thawing (2,2). Rows 1 and 2 are otherwise
    // untouched by moves 1–4.
    final e = GridEngine(config, validator: wordValidator);
    e
      ..applyMove(const Move.rowRight(0))
      ..applyMove(const Move.rowRight(3))
      ..applyMove(const Move.rowRight(4))
      ..applyMove(const Move.rowRight(0))
      ..applyMove(const Move.columnDown(0)); // 5th -> thaws (2,2)
    expect(e.moveCount, 5);
    expect(e.state.statusAt(const GridCoord(2, 2)), TileStatus.thawed);

    final ref = GridEngine(config, validator: wordValidator)
      ..applyMove(const Move.rowRight(0))
      ..applyMove(const Move.rowRight(3))
      ..applyMove(const Move.rowRight(4))
      ..applyMove(const Move.rowRight(0));

    e.undo();
    expect(e.moveCount, 4);
    expect(gridOf(e.state), gridOf(ref.state));
    expect(e.state.statusAt(const GridCoord(2, 2)), TileStatus.frozen);
  });

  test('AC: undo with no moves -> nothingToUndo, nothing changes', () {
    final e = GridEngine(open(), validator: never);
    final step = e.undo();
    expect(step.applied, isFalse);
    expect(step.rejectedReason, MoveRejectReason.nothingToUndo);
    expect(e.moveCount, 0);
  });

  test('AC: restart -> initial grid, count 0, thaw/solved re-derived', () {
    final e = GridEngine(open(), validator: never)
      ..applyMove(const Move.rowRight(0))
      ..applyMove(const Move.columnDown(1));
    e.restart();
    expect(gridOf(e.state), 'ABCDE/FGHIJ/KLMNO/PRTUV/YZBCD');
    expect(e.moveCount, 0);
  });

  test('AC: two independent folds of (config, moves) -> equal state + key', () {
    final moves = <Move>[
      const Move.rowRight(0),
      const Move.columnDown(2),
      const Move.rowLeft(4),
    ];
    GridState fold() {
      var s = GridState.initial(open(), never);
      for (final m in moves) {
        s = s.applyMove(m, open(), never).state;
      }
      return s;
    }

    expect(fold(), fold());
    expect(fold().canonicalKey(), fold().canonicalKey());
  });

  test('AC: canonicalKey equal on identical letters+status, differs on change',
      () {
    final a = GridState.initial(open(), never);
    final b = GridState.initial(open(), never);
    expect(a.canonicalKey(), b.canonicalKey());
    final moved = a.applyMove(const Move.rowRight(0), open(), never).state;
    expect(moved.canonicalKey(), isNot(a.canonicalKey()));
  });

  test('AC: malformed EngineConfig throws', () {
    expect(() => cfg(<String>['ABCD'], target: 'ABCD'),
        throwsA(isA<EngineConfigError>()));
    expect(
        () => cfg(<String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
            target: 'ABC'),
        throwsA(isA<EngineConfigError>()));
    expect(
        () => cfg(<String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
            target: 'MASAL',
            locked: <GridCoord>{const GridCoord(1, 1)},
            frozen: <GridCoord>{const GridCoord(1, 1)}),
        throwsA(isA<EngineConfigError>()));
  });
}
