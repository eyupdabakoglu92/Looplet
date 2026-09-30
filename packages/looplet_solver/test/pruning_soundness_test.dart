import 'dart:collection';
import 'dart:math';

import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:looplet_solver/looplet_solver.dart';
import 'package:test/test.dart';

import 'support/reference.dart';

// F07 A7: pruning is valid only if it never changes a result. Every fixture is
// solved and enumerated twice — with the default WinLowerBound and exhaustively
// (noLowerBound) — and the outputs must be identical.

final _words = SetWordValidator(
    <String>['MASAL', 'MASA', 'ASAL', 'KALE', 'SAKA', 'ALAN', 'KASA']);
const _letters = 'MASALKEBDN';

/// Deterministic small fixtures: the target in a random row, random filler,
/// scrambled by real engine moves, then locked / frozen masks on the result.
List<EngineConfig> _fixtures() {
  final random = Random(20260930);
  final fixtures = <EngineConfig>[];
  var attempts = 0;
  while (fixtures.length < 24 && attempts < 400) {
    attempts++;
    final rows = <List<String>>[
      for (var r = 0; r < 5; r++)
        [for (var c = 0; c < 5; c++) _letters[random.nextInt(_letters.length)]]
    ];
    rows[random.nextInt(5)] = 'MASAL'.split('');
    // Scramble under a target that never matches (a solved state is terminal).
    final plain = EngineConfig(initialGrid: rows, targetWord: 'QQQQQ');
    var state = GridState.initial(plain, const NeverValidWordValidator());
    for (var i = 0; i < 3 + random.nextInt(3); i++) {
      final moves = plain.legalMoves(state);
      if (moves.isEmpty) break;
      state = state
          .applyMove(moves[random.nextInt(moves.length)], plain,
              const NeverValidWordValidator())
          .state;
    }
    final kind = fixtures.length % 4; // open, locked, frozen, both
    final cells = <GridCoord>[
      for (var r = 0; r < 5; r++)
        for (var c = 0; c < 5; c++) GridCoord(r, c)
    ]..shuffle(random);
    final config = EngineConfig(
      initialGrid: state.letters,
      targetWord: 'MASAL',
      lockedCells: kind == 1 || kind == 3 ? {cells[0]} : {},
      frozenCells: kind == 2 || kind == 3 ? {cells[1], cells[2]} : {},
    );
    final initial = GridState.initial(config, _words);
    if (initial.isSolved || initial.thawedCells.isNotEmpty) continue;
    final exhaustive = Solver.solve(config, _words, lowerBound: noLowerBound);
    if (exhaustive is! Optimal || exhaustive.moves > 4) continue;
    fixtures.add(config);
  }
  return fixtures;
}

/// Empty when [bound] reproduces the exhaustive results on every fixture.
List<String> _mismatches(
    List<EngineConfig> fixtures, MoveLowerBound Function(EngineConfig) bound) {
  final found = <String>[];
  for (var i = 0; i < fixtures.length; i++) {
    final config = fixtures[i];
    final pruned = Solver.solve(config, _words, lowerBound: bound(config));
    final exhaustive = Solver.solve(config, _words, lowerBound: noLowerBound);
    String describe(SolveResult r) => switch (r) {
          Optimal(:final moves, :final sequence) =>
            'optimal $moves ${seqString(sequence)}',
          Unsolvable() => 'unsolvable',
          BudgetExceeded() => 'budget',
        };
    if (describe(pruned) != describe(exhaustive)) {
      found.add('#$i solve: ${describe(pruned)} != ${describe(exhaustive)}');
      continue;
    }
    final a = Solver.enumerateOptimalSolutionsWithCoverage(config, _words,
        lowerBound: bound(config));
    final b = Solver.enumerateOptimalSolutionsWithCoverage(config, _words,
        lowerBound: noLowerBound);
    if (a.complete != b.complete ||
        a.sequences.map(seqString).join('|') !=
            b.sequences.map(seqString).join('|')) {
      found.add('#$i enumeration differs');
    }
  }
  return found;
}

void main() {
  final fixtures = _fixtures();

  test('fixtures cover every mechanic class and several optima', () {
    expect(fixtures, hasLength(24));
    final optima = {
      for (final c in fixtures)
        (Solver.solve(c, _words, lowerBound: noLowerBound) as Optimal).moves
    };
    expect(optima.length, greaterThanOrEqualTo(3), reason: '$optima');
    expect(fixtures.where((c) => c.lockedCells.isNotEmpty), isNotEmpty);
    expect(fixtures.where((c) => c.frozenCells.isNotEmpty), isNotEmpty);
  });

  test('pruned solve and enumeration equal the exhaustive search', () {
    expect(_mismatches(fixtures, (c) => WinLowerBound(c).call), isEmpty);
  });

  test('pruned optimum equals the independent IDDFS reference', () {
    for (final config in fixtures) {
      expect((Solver.solve(config, _words) as Optimal).moves,
          referenceOptimal(config, _words, maxLimit: 4));
    }
  });

  test('negative: an inadmissible bound is caught by the same comparison', () {
    // Overestimates by one on every unsolved state: wins are pruned away.
    MoveLowerBound inflated(EngineConfig c) {
      final base = WinLowerBound(c);
      return (s) => s.isSolved ? 0 : base(s) + 1;
    }

    expect(_mismatches(fixtures, inflated), isNotEmpty);
  });

  test('WinLowerBound is admissible and consistent on every reachable state',
      () {
    for (final config in fixtures.take(5)) {
      final bound = WinLowerBound(config);
      final start = GridState.initial(config, _words);
      final seen = <String>{start.canonicalKey()};
      final queue = Queue<(GridState, int)>()..add((start, 0));
      while (queue.isNotEmpty) {
        final (state, depth) = queue.removeFirst();
        final exact = referenceOptimal(
            EngineConfig(
                initialGrid: state.letters,
                targetWord: config.targetWord,
                lockedCells: config.lockedCells,
                frozenCells: {
                  for (final c in config.frozenCells)
                    if (!state.thawedCells.contains(c)) c
                }),
            _words,
            maxLimit: 3);
        if (exact != null) {
          expect(bound(state), lessThanOrEqualTo(exact));
        }
        if (depth == 2) continue;
        for (final move in config.legalMoves(state)) {
          final next = state.applyMove(move, config, _words).state;
          expect(bound(state), lessThanOrEqualTo(1 + bound(next)));
          if (seen.add(next.canonicalKey())) queue.add((next, depth + 1));
        }
      }
    }
  });

  test('a wrong locked cell makes its window unreachable', () {
    final config = cfg(<String>['XASAL', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
        target: 'MASAL',
        locked: <GridCoord>{
          for (var r = 0; r < 5; r++) GridCoord(r, 0),
        });
    final start = GridState.initial(config, const NeverValidWordValidator());
    expect(WinLowerBound(config)(start), WinLowerBound.unreachable);
    expect(Solver.solve(config, const NeverValidWordValidator()),
        isA<Unsolvable>());
  });

  group('stop causes are recorded; nodes decide before the clock', () {
    final config = cfg(<String>['SALMA', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
        target: 'MASAL');
    const never = NeverValidWordValidator();

    test('node bound', () {
      final r =
          Solver.solve(config, never, budget: const SearchBudget(maxNodes: 1))
              as BudgetExceeded;
      expect(r.cause, SearchStopCause.nodes);
    });

    test('depth bound', () {
      final r =
          Solver.solve(config, never, budget: const SearchBudget(maxDepth: 1))
              as BudgetExceeded;
      expect(r.cause, SearchStopCause.depth);
    });

    test('time ceiling', () {
      final r = Solver.solve(config, never,
              budget: const SearchBudget(timeBudget: Duration(microseconds: 1)))
          as BudgetExceeded;
      expect(r.cause, SearchStopCause.time);
    });

    test('both exceeded → nodes, independent of the host clock', () {
      final guard = SearchGuard(
          const SearchBudget(
              maxNodes: 1, timeBudget: Duration(microseconds: 1)),
          'test');
      expect(
          () => guard.check(2),
          throwsA(isA<SearchLimitExceeded>()
              .having((e) => e.cause, 'cause', SearchStopCause.nodes)));
    });

    test('scorer propagates the cause and stats record every phase', () {
      final stats = SearchStats();
      DifficultyScorer.score(config, never, stats: stats);
      expect(stats.toJson().map((e) => e['phase']),
          ['solve', 'optimal enumeration', 'solve', 'difficulty state tree']);
      expect(
          () => DifficultyScorer.score(config, never,
              budget: const SearchBudget(maxNodes: 1)),
          throwsA(isA<SearchLimitExceeded>()
              .having((e) => e.cause, 'cause', SearchStopCause.nodes)));
    });
  });
}
