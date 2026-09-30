import 'dart:collection';

import 'package:looplet_engine/looplet_engine.dart';

import 'lower_bound.dart';
import 'solve_result.dart';

/// Build-time minimum-move solver over the F02 engine's state space.
///
/// Node identity = `GridState.canonicalKey()`. Successors = `EngineConfig
/// .legalMoves` (sorted by a total [Move] order). Cost per move = 1.
/// Contract: `ai-system/features/f06-.../architecture.md` "looplet_solver";
/// pruning: F07 `architecture.md` A7.
abstract final class Solver {
  /// Breadth-first search under an increasing bound. Bound `b` keeps a child
  /// only if `depth + lowerBound(child) <= b`, for `b = lowerBound(start)` up
  /// to `budget.maxDepth`. The lower bound is admissible, so no bound below
  /// the optimum finds a win and the first success is at the optimum. It is
  /// also consistent, so the first discoverer of every kept state is kept: the
  /// returned `sequence` is byte-identical to an unpruned forward BFS (fixed
  /// successor order + FIFO + first-discovered parents).
  ///
  /// [lowerBound] defaults to [WinLowerBound]; tests pass [noLowerBound] to get
  /// the exhaustive search. Only admissible, consistent bounds are valid.
  static SolveResult solve(
    EngineConfig config,
    WordValidator validator, {
    SearchBudget budget = const SearchBudget(),
    SearchStats? stats,
    MoveLowerBound? lowerBound,
  }) {
    final guard = SearchGuard(budget, 'solve', stats: stats);
    final start = GridState.initial(config, validator);
    if (start.isSolved) return const Optimal(0, <Move>[]);
    final bound = lowerBound ?? WinLowerBound(config).call;
    final startKey = start.canonicalKey();
    final first = bound(start);
    if (first >= WinLowerBound.unreachable) return const Unsolvable();

    for (var limit = first; limit <= budget.maxDepth; limit++) {
      final visited = <String>{startKey};
      final parent = <String, _Parent>{};
      final queue = Queue<_Node>()..add(_Node(start, startKey, 0));
      // A child cut by the finite bound may lead to a win beyond it.
      var hitWall = false;

      while (queue.isNotEmpty) {
        final node = queue.removeFirst();
        final childDepth = node.depth + 1;
        for (final move in _orderedLegalMoves(config, node.state)) {
          try {
            guard.check(visited.length);
          } on SearchLimitExceeded catch (e) {
            return BudgetExceeded(budget,
                cause: e.cause, nodes: e.nodes, elapsed: e.elapsed);
          }
          final step = node.state.applyMove(move, config, validator);
          if (!step.applied) continue;
          final childKey = step.state.canonicalKey();
          if (visited.contains(childKey)) continue;
          final remaining = bound(step.state);
          if (childDepth + remaining > limit) {
            if (remaining < WinLowerBound.unreachable) hitWall = true;
            continue;
          }
          if (visited.length >= budget.maxNodes) {
            final e = guard.exceeded(SearchStopCause.nodes);
            return BudgetExceeded(budget,
                cause: e.cause, nodes: visited.length, elapsed: e.elapsed);
          }

          parent[childKey] = _Parent(node.key, move);
          if (step.state.isSolved) {
            return Optimal(
                childDepth, _reconstruct(parent, startKey, childKey));
          }

          visited.add(childKey);
          queue.add(_Node(step.state, childKey, childDepth));
        }
      }
      // Every reachable state was kept and none wins.
      if (!hitWall) return const Unsolvable();
    }
    final e = guard.exceeded(SearchStopCause.depth);
    return BudgetExceeded(budget,
        cause: SearchStopCause.depth, nodes: e.nodes, elapsed: e.elapsed);
  }

  /// Compatibility API. Throws SearchLimitExceeded on incomplete computation;
  /// use enumerateOptimalSolutionsWithCoverage for explicit cap coverage.
  static List<List<Move>> enumerateOptimalSolutions(
    EngineConfig config,
    WordValidator validator, {
    int cap = 1000,
    SearchBudget budget = const SearchBudget(),
  }) =>
      enumerateOptimalSolutionsWithCoverage(config, validator,
              cap: cap, budget: budget)
          .sequences;

  /// Every winning sequence of exactly the optimal length, in lexicographic
  /// successor order, up to [cap]. A winning sequence of optimal length visits
  /// each state at its BFS distance (else a shorter win exists), so this equals
  /// the old distance-layer walk. The depth-first walk keeps a child only if
  /// `depth + lowerBound(child) <= optimum` and remembers (state, remaining)
  /// pairs with no completion; both cuts drop only failing branches, so the
  /// list and its order are unchanged. Resource count: explored prefixes.
  static OptimalSolutions enumerateOptimalSolutionsWithCoverage(
    EngineConfig config,
    WordValidator validator, {
    int cap = 1000,
    SearchBudget budget = const SearchBudget(),
    SearchStats? stats,
    MoveLowerBound? lowerBound,
  }) {
    if (cap < 1) throw ArgumentError.value(cap, 'cap', 'must be positive');
    final guard = SearchGuard(budget, 'optimal enumeration', stats: stats);
    final result = solve(config, validator,
        budget: budget, stats: stats, lowerBound: lowerBound);
    if (result is BudgetExceeded) {
      throw SearchLimitExceeded('optimal solve', budget,
          cause: result.cause, nodes: result.nodes, elapsed: result.elapsed);
    }
    if (result is! Optimal) return const OptimalSolutions([], complete: true);
    final optimal = result.moves;
    if (optimal == 0) return const OptimalSolutions([[]], complete: true);
    final bound = lowerBound ?? WinLowerBound(config).call;
    final start = GridState.initial(config, validator);

    // Collect cap+1 to distinguish a complete set of exactly cap solutions
    // from truncation.
    final solutions = <List<Move>>[];
    final path = <Move>[];
    final noCompletion = <String>{};
    var prefixes = 0;
    bool dfs(GridState state, int depth) {
      if (solutions.length > cap) return true;
      guard.check(++prefixes);
      if (depth == optimal) {
        if (!state.isSolved) return false;
        solutions.add(List<Move>.of(path));
        return true;
      }
      var found = false;
      for (final move in _orderedLegalMoves(config, state)) {
        if (solutions.length > cap) return true;
        final step = state.applyMove(move, config, validator);
        if (!step.applied) continue;
        if (depth + 1 + bound(step.state) > optimal) continue;
        final key = '${step.state.canonicalKey()}|${optimal - depth - 1}';
        if (noCompletion.contains(key)) continue;
        path.add(move);
        final completed = dfs(step.state, depth + 1);
        path.removeLast();
        if (completed) {
          found = true;
        } else {
          noCompletion.add(key);
        }
      }
      return found;
    }

    dfs(start, 0);
    return OptimalSolutions(solutions.take(cap).toList(),
        complete: solutions.length <= cap);
  }

  static List<Move> _orderedLegalMoves(EngineConfig config, GridState state) {
    final moves = config.legalMoves(state);
    if (moves.length > 1) moves.sort(_compareMoves);
    return moves;
  }

  static int _compareMoves(Move a, Move b) {
    final byAxis = a.axis.index.compareTo(b.axis.index);
    if (byAxis != 0) return byAxis;
    final byIndex = a.index.compareTo(b.index);
    if (byIndex != 0) return byIndex;
    return a.direction.index.compareTo(b.direction.index);
  }

  static List<Move> _reconstruct(
    Map<String, _Parent> parent,
    String startKey,
    String goalKey,
  ) {
    final moves = <Move>[];
    var key = goalKey;
    while (key != startKey) {
      final step = parent[key]!;
      moves.add(step.move);
      key = step.parentKey;
    }
    return moves.reversed.toList(growable: false);
  }
}

final class _Node {
  _Node(this.state, this.key, this.depth);
  final GridState state;
  final String key;
  final int depth;
}

final class _Parent {
  _Parent(this.parentKey, this.move);
  final String parentKey;
  final Move move;
}
