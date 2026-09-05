import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:looplet_solver/looplet_solver.dart';
import 'package:test/test.dart';

import 'support/reference.dart';

final _masal = SetWordValidator(<String>['MASAL']);
const _never = NeverValidWordValidator();

void main() {
  group('minimality vs the independent IDDFS reference', () {
    void expectMatchesReference(EngineConfig config, WordValidator validator) {
      final result = Solver.solve(config, validator);
      final reference = referenceOptimal(config, validator, maxLimit: 6);
      expect(reference, isNotNull,
          reason: 'reference could not solve within 6');
      expect(result, isA<Optimal>());
      final optimal = result as Optimal;
      expect(optimal.moves, reference, reason: 'solver optimal != reference');
      // the returned sequence is valid and minimal
      expect(optimal.sequence, hasLength(optimal.moves));
      expect(fold(config, validator, optimal.sequence).isSolved, isTrue);
    }

    test('no tiles — optimal 1', () {
      expectMatchesReference(
        cfg(<String>['ASALM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
            target: 'MASAL'),
        _never,
      );
    });

    test('no tiles — optimal 2', () {
      expectMatchesReference(
        cfg(<String>['SALMA', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
            target: 'MASAL'),
        _never,
      );
    });

    test('no tiles — a column move is the optimal move', () {
      // columnDown(0) pulls row0.col0 == "M" into row1.col0 → row 1 = "MASAL".
      expectMatchesReference(
        cfg(<String>['MCDFG', 'XASAL', 'HJKLN', 'PRTUV', 'YZBCD'],
            target: 'MASAL'),
        _never,
      );
    });

    test('with a locked tile elsewhere', () {
      expectMatchesReference(
        cfg(<String>['ASALM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
            target: 'MASAL', locked: <GridCoord>{const GridCoord(2, 2)}),
        _never,
      );
    });

    test('with a frozen tile on the solving path (thaw + win)', () {
      // columnDown(0) makes row 2 spell MASAL, thawing (2,2) and winning.
      expectMatchesReference(
        cfg(<String>['BCDFG', 'MHJKL', 'XASAL', 'PRTUV', 'YZBCD'],
            target: 'MASAL', frozen: <GridCoord>{const GridCoord(2, 2)}),
        _masal,
      );
    });
  });

  test('already-solved grid → Optimal(0, [])', () {
    final result = Solver.solve(
      cfg(<String>['MASAL', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
          target: 'MASAL'),
      _never,
    );
    expect(result, isA<Optimal>());
    expect((result as Optimal).moves, 0);
    expect(result.sequence, isEmpty);
  });

  test('unsolvable grid → Unsolvable (small reachable space, fully exhausted)',
      () {
    // Rows 0/1/3/4 fully locked → column moves are no-ops; only row 2 can cycle
    // through the 5 rotations of "ABCDE", none of which is "MASAL".
    final locked = <GridCoord>{
      for (final r in <int>[0, 1, 3, 4])
        for (var c = 0; c < 5; c++) GridCoord(r, c),
    };
    final result = Solver.solve(
      cfg(<String>['FGHIJ', 'KLMNO', 'ABCDE', 'PRTUV', 'YZBCD'],
          target: 'MASAL', locked: locked),
      _never,
    );
    expect(result, isA<Unsolvable>());
  });

  group('BudgetExceeded', () {
    final hard = cfg(<String>['SALMA', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
        target: 'MASAL'); // optimal 2

    test('depth wall', () {
      final result =
          Solver.solve(hard, _never, budget: const SearchBudget(maxDepth: 1));
      expect(result, isA<BudgetExceeded>());
    });

    test('node cap', () {
      final result =
          Solver.solve(hard, _never, budget: const SearchBudget(maxNodes: 1));
      expect(result, isA<BudgetExceeded>());
    });

    test(
        'a genuinely unsolvable puzzle with a low depth wall still reports '
        'BudgetExceeded, not Unsolvable', () {
      final result = Solver.solve(
        cfg(<String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
            target: 'MASAL'),
        _never,
        budget: const SearchBudget(maxDepth: 2),
      );
      expect(result, isA<BudgetExceeded>());
    });
  });

  group('determinism', () {
    final config = cfg(<String>['SALMA', 'MHJKL', 'XASAL', 'PRTUV', 'YZBCD'],
        target: 'MASAL', frozen: <GridCoord>{const GridCoord(2, 2)});

    test('same minimum + byte-identical sequence across runs', () {
      final a = Solver.solve(config, _masal) as Optimal;
      final b = Solver.solve(config, _masal) as Optimal;
      expect(a.moves, b.moves);
      expect(seqString(a.sequence), seqString(b.sequence));
    });

    test('returned sequence uses only applied moves and reaches isSolved', () {
      final result = Solver.solve(config, _masal) as Optimal;
      expect(fold(config, _masal, result.sequence).isSolved, isTrue);
    });
  });

  group('enumerateOptimalSolutions', () {
    test('finds every optimal solution for a small puzzle', () {
      // "SALMA" -> MASAL is optimal 2; only rowRight(0) twice.
      final config = cfg(<String>['SALMA', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
          target: 'MASAL');
      final solutions = Solver.enumerateOptimalSolutions(config, _never);
      expect(solutions, isNotEmpty);
      for (final solution in solutions) {
        expect(solution, hasLength(2));
        expect(fold(config, _never, solution).isSolved, isTrue);
      }
      // deterministic order
      final again = Solver.enumerateOptimalSolutions(config, _never);
      expect(again.map(seqString).toList(), solutions.map(seqString).toList());
    });

    test('respects the cap', () {
      final config = cfg(<String>['ASALM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
          target: 'MASAL');
      expect(
        Solver.enumerateOptimalSolutions(config, _never, cap: 1),
        hasLength(lessThanOrEqualTo(1)),
      );
    });

    test('unsolvable → empty; solved → [[]]', () {
      final locked = <GridCoord>{
        for (final r in <int>[0, 1, 3, 4])
          for (var c = 0; c < 5; c++) GridCoord(r, c),
      };
      expect(
        Solver.enumerateOptimalSolutions(
          cfg(<String>['FGHIJ', 'KLMNO', 'ABCDE', 'PRTUV', 'YZBCD'],
              target: 'MASAL', locked: locked),
          _never,
        ),
        isEmpty,
      );
      expect(
        Solver.enumerateOptimalSolutions(
          cfg(<String>['MASAL', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
              target: 'MASAL'),
          _never,
        ),
        <List<Move>>[<Move>[]],
      );
    });
  });
}
