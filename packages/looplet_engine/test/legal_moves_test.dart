import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:test/test.dart';

import 'support/helpers.dart';

const _validator = NeverValidWordValidator();

void main() {
  test('an open 5x5 grid has 20 legal moves (2 per row + 2 per column)', () {
    final config = cfg(
      <String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
      target: 'WWWWW',
    );
    final state = GridState.initial(config, _validator);
    expect(config.legalMoves(state), hasLength(20));
  });

  test('columns are excluded when disabled', () {
    final config = cfg(
      <String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
      target: 'WWWWW',
      columns: false,
    );
    final state = GridState.initial(config, _validator);
    final moves = config.legalMoves(state);
    expect(moves, hasLength(10));
    expect(moves.every((m) => m.axis == MoveAxis.row), isTrue);
  });

  test('a fully-immovable line contributes no moves', () {
    final config = cfg(
      <String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
      target: 'WWWWW',
      locked: <GridCoord>{
        const GridCoord(0, 0),
        const GridCoord(0, 1),
        const GridCoord(0, 2),
        const GridCoord(0, 3),
        const GridCoord(0, 4),
      },
    );
    final state = GridState.initial(config, _validator);
    final moves = config.legalMoves(state);
    expect(moves.any((m) => m.axis == MoveAxis.row && m.index == 0), isFalse);
    // column 0 also loses a movable cell but still has 4 -> still legal
    expect(moves.any((m) => m.axis == MoveAxis.column && m.index == 0), isTrue);
  });

  test('legalMoves is empty once solved', () {
    final config = cfg(
      <String>['MASAL', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
      target: 'MASAL',
    );
    final state = GridState.initial(config, _validator);
    expect(state.isSolved, isTrue);
    expect(config.legalMoves(state), isEmpty);
  });

  test('every legal move actually applies; every applied move is legal', () {
    final config = cfg(
      <String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
      target: 'WWWWW',
      locked: <GridCoord>{
        // fully lock row 0 -> rowLeft(0)/rowRight(0) must be rejected
        const GridCoord(0, 0),
        const GridCoord(0, 1),
        const GridCoord(0, 2),
        const GridCoord(0, 3),
        const GridCoord(0, 4),
        const GridCoord(2, 2),
      },
    );
    final state = GridState.initial(config, _validator);
    final legal = config.legalMoves(state).toSet();

    for (final move in legal) {
      expect(
        state.applyMove(move, config, _validator).applied,
        isTrue,
        reason: '$move is listed legal but was rejected',
      );
    }

    // Exhaustively check the rejected ones are indeed not legal.
    for (var i = 0; i < 5; i++) {
      for (final move in <Move>[
        Move.rowLeft(i),
        Move.rowRight(i),
        Move.columnUp(i),
        Move.columnDown(i),
      ]) {
        final applied = state.applyMove(move, config, _validator).applied;
        expect(legal.contains(move), applied, reason: '$move');
      }
    }
  });
}
