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
    final start = GridState.initial(config, validator);
    if (start.isSolved) return const Optimal(0, <Move>[]);

    final stopwatch = Stopwatch()..start();
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
        final step = node.state.applyMove(move, config, validator);
        if (!step.applied) continue;
        final childKey = step.state.canonicalKey();
        if (visited.contains(childKey)) continue;

        parent[childKey] = _Parent(node.key, move);
        if (step.state.isSolved) {
          return Optimal(childDepth, _reconstruct(parent, startKey, childKey));
        }

        visited.add(childKey);
        queue.add(_Node(step.state, childKey, childDepth));

        if (visited.length > budget.maxNodes) return BudgetExceeded(budget);
        if (stopwatch.elapsed > budget.timeBudget)
          return BudgetExceeded(budget);
      }
    }

    // The whole reachable set within the depth wall was explored. If a branch
    // was ever pruned at the wall, we cannot conclude Unsolvable.
    return hitDepthWall ? BudgetExceeded(budget) : const Unsolvable();
  }

  /// Every distinct optimal solution, up to [cap]. Used by the difficulty
  /// scorer. Deterministic order. Returns `[]` if unsolvable / budget-exceeded,
  /// `[[]]` if the puzzle is already solved.
  static List<List<Move>> enumerateOptimalSolutions(
    EngineConfig config,
    WordValidator validator, {
    int cap = 1000,
  }) {
    final result = solve(config, validator);
    if (result is! Optimal) return const <List<Move>>[];
    final optimal = result.moves;
    if (optimal == 0) return <List<Move>>[<Move>[]];

    final start = GridState.initial(config, validator);
    // Forward BFS building the shortest distance to every state within `optimal`.
    final dist = <String, int>{start.canonicalKey(): 0};
    final queue = Queue<GridState>()..add(start);
    while (queue.isNotEmpty) {
      final state = queue.removeFirst();
      final depth = dist[state.canonicalKey()]!;
      if (depth == optimal) continue;
      for (final move in _orderedLegalMoves(config, state)) {
        final step = state.applyMove(move, config, validator);
        if (!step.applied) continue;
        final key = step.state.canonicalKey();
        if (!dist.containsKey(key)) {
          dist[key] = depth + 1;
          queue.add(step.state);
        }
      }
    }

    // DFS confined to the "optimal DAG": every prefix of an optimal solution is
    // a shortest path to its state, so only follow edges to a state whose
    // shortest distance is exactly one greater.
    final solutions = <List<Move>>[];
    final path = <Move>[];

    void dfs(GridState state, int depth) {
      if (solutions.length >= cap) return;
      if (depth == optimal) {
        if (state.isSolved) solutions.add(List<Move>.of(path));
        return;
      }
      for (final move in _orderedLegalMoves(config, state)) {
        if (solutions.length >= cap) return;
        final step = state.applyMove(move, config, validator);
        if (!step.applied) continue;
        if (dist[step.state.canonicalKey()] != depth + 1) continue;
        path.add(move);
        dfs(step.state, depth + 1);
        path.removeLast();
      }
    }

    dfs(start, 0);
    return solutions;
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
