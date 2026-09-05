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
