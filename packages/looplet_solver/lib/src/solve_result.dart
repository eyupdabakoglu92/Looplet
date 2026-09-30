import 'package:looplet_engine/looplet_engine.dart';

/// Bounds that separate a "publishable" puzzle from `BudgetExceeded`. The
/// search runs at authoring time on a workstation; a puzzle that blows any
/// bound is not shippable and the designer adjusts it.
final class SearchBudget {
  const SearchBudget({
    this.maxDepth = 16,
    this.maxNodes = 5000000,
    this.timeBudget = const Duration(seconds: 30),
  });

  /// The search never expands a node whose successors would be at depth
  /// `> maxDepth`. Hitting this wall without a solution yields `BudgetExceeded`.
  final int maxDepth;

  /// Distinct visited states cap.
  final int maxNodes;

  /// Wall-clock cap.
  final Duration timeBudget;
}

/// A bounded analysis did not finish. Never interpret this as absence of a
/// path, or publish partial metrics as a complete difficulty calculation.
final class SearchLimitExceeded implements Exception {
  const SearchLimitExceeded(this.phase, this.budget);
  final String phase;
  final SearchBudget budget;
  @override
  String toString() => 'SearchLimitExceeded($phase: UNKNOWN)';
}

/// Shared guard for a single analysis. Count retained distinct states in graph
/// searches and explored prefixes in path enumeration (both consume resources).
final class SearchGuard {
  SearchGuard(this.budget, this.phase) {
    if (budget.maxDepth < 0 ||
        budget.maxNodes < 1 ||
        budget.timeBudget <= Duration.zero) {
      throw ArgumentError('Search budget must have nonnegative depth, positive '
          'nodes and positive time');
    }
  }
  final SearchBudget budget;
  final String phase;
  final Stopwatch _watch = Stopwatch()..start();
  void check(int nodes) {
    if (nodes > budget.maxNodes || _watch.elapsed >= budget.timeBudget) {
      throw SearchLimitExceeded(phase, budget);
    }
  }
}

final class OptimalSolutions {
  const OptimalSolutions(this.sequences, {required this.complete});
  final List<List<Move>> sequences;

  /// False means [sequences] is only a deterministic sample, not all paths.
  final bool complete;
}

/// The result of a solve. Sealed — exactly one of the three subtypes.
sealed class SolveResult {
  const SolveResult();
}

/// A proven minimum: no shorter move sequence reaches a winning state.
final class Optimal extends SolveResult {
  const Optimal(this.moves, this.sequence);

  /// The provable minimum move count.
  final int moves;

  /// One optimal solution (deterministic tie-break). `sequence.length == moves`;
  /// folding it over `GridState.initial` reaches `isSolved`; every step applies.
  final List<Move> sequence;
}

/// No winning state is reachable from the initial grid.
final class Unsolvable extends SolveResult {
  const Unsolvable();
}

/// The minimum was not proven within [budget] (depth wall, node cap, or time).
final class BudgetExceeded extends SolveResult {
  const BudgetExceeded(this.budget);

  final SearchBudget budget;
}
