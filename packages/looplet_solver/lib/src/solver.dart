import 'dart:collection';

import 'package:looplet_engine/looplet_engine.dart';

import 'solve_result.dart';

/// Build-time minimum-move solver over the F02 engine's state space.
///
/// Node identity = `GridState.canonicalKey()`. Successors = `EngineConfig
/// .legalMoves` (sorted by a total [Move] order). Cost per move = 1.
/// Contract: `ai-system/features/f06-.../architecture.md` "looplet_solver".
abstract final class Solver {
  /// Forward BFS. The first `isSolved` state dequeued is at the minimum depth,
  /// so `Optimal.moves` is a provable minimum. Deterministic: a fixed successor
  /// order + FIFO + first-discovered parents ⇒ byte-stable `sequence`.
  static SolveResult solve(
    EngineConfig config,
    WordValidator validator, {
    SearchBudget budget = const SearchBudget(),
  }) {
    final guard = SearchGuard(budget, 'solve');
    final start = GridState.initial(config, validator);
    if (start.isSolved) return const Optimal(0, <Move>[]);

    final startKey = start.canonicalKey();
    final visited = <String>{startKey};
    final parent = <String, _Parent>{};
    final queue = Queue<_Node>()..add(_Node(start, startKey, 0));

    var hitDepthWall = false;

    while (queue.isNotEmpty) {
      final node = queue.removeFirst();
      final childDepth = node.depth + 1;
      if (childDepth > budget.maxDepth) {
        hitDepthWall = true;
        continue;
      }

      for (final move in _orderedLegalMoves(config, node.state)) {
        try {
          guard.check(visited.length);
        } on SearchLimitExceeded {
          return BudgetExceeded(budget);
        }
        final step = node.state.applyMove(move, config, validator);
        if (!step.applied) continue;
        final childKey = step.state.canonicalKey();
        if (visited.contains(childKey)) continue;
        if (visited.length >= budget.maxNodes) return BudgetExceeded(budget);

        parent[childKey] = _Parent(node.key, move);
        if (step.state.isSolved) {
          return Optimal(childDepth, _reconstruct(parent, startKey, childKey));
        }

        visited.add(childKey);
        queue.add(_Node(step.state, childKey, childDepth));
      }
    }

    // The whole reachable set within the depth wall was explored. If a branch
    // was ever pruned at the wall, we cannot conclude Unsolvable.
    return hitDepthWall ? BudgetExceeded(budget) : const Unsolvable();
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

  static OptimalSolutions enumerateOptimalSolutionsWithCoverage(
    EngineConfig config,
    WordValidator validator, {
    int cap = 1000,
    SearchBudget budget = const SearchBudget(),
  }) {
    if (cap < 1) throw ArgumentError.value(cap, 'cap', 'must be positive');
    final guard = SearchGuard(budget, 'optimal enumeration');
    final result = solve(config, validator, budget: budget);
    if (result is BudgetExceeded) {
      throw SearchLimitExceeded('optimal solve', budget);
    }
    if (result is! Optimal) return const OptimalSolutions([], complete: true);
    final optimal = result.moves;
    if (optimal == 0) return const OptimalSolutions([[]], complete: true);
    final start = GridState.initial(config, validator);
    final dist = <String, int>{start.canonicalKey(): 0};
    final queue = Queue<GridState>()..add(start);
    while (queue.isNotEmpty) {
      guard.check(dist.length);
      final state = queue.removeFirst();
      final depth = dist[state.canonicalKey()]!;
      if (depth == optimal) continue;
      for (final move in _orderedLegalMoves(config, state)) {
        guard.check(dist.length);
        final step = state.applyMove(move, config, validator);
        if (!step.applied) continue;
        final key = step.state.canonicalKey();
        if (!dist.containsKey(key)) {
          guard.check(dist.length + 1);
          dist[key] = depth + 1;
          queue.add(step.state);
        }
      }
    }

    // Collect cap+1 to distinguish a complete set of exactly cap solutions
    // from truncation. DFS prefixes also have a resource bound.
    final solutions = <List<Move>>[];
    final path = <Move>[];
    var prefixes = 0;
    void dfs(GridState state, int depth) {
      if (solutions.length > cap) return;
      guard.check(++prefixes);
      if (depth == optimal) {
        if (state.isSolved) solutions.add(List<Move>.of(path));
        return;
      }
      for (final move in _orderedLegalMoves(config, state)) {
        if (solutions.length > cap) return;
        final step = state.applyMove(move, config, validator);
        if (!step.applied) continue;
        if (dist[step.state.canonicalKey()] != depth + 1) continue;
        path.add(move);
        dfs(step.state, depth + 1);
        path.removeLast();
      }
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
