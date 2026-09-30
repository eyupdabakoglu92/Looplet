import 'dart:collection';

import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:looplet_solver/looplet_solver.dart';

/// Absence is a statement only about the supplied finite depth, never global
/// unsolvability. History-dependent requirements are included in node identity.
final class WitnessSearch {
  const WitnessSearch(this.status, this.moves, this.nodes, {this.stop});
  final String status; // FOUND, ABSENT_WITHIN_DEPTH, UNKNOWN
  final List<Move> moves;
  final int nodes;

  /// Why an UNKNOWN search stopped (cause, nodes, elapsed); null otherwise.
  final SearchLimitExceeded? stop;
}

int maxCorrect(EngineConfig config, GridState state) {
  final target = TurkishCase.toLowerTr(config.targetWord).split('');
  var best = 0;
  for (final row in state.letters) {
    var correct = 0;
    for (var c = 0; c < target.length; c++) {
      if (TurkishCase.toLowerTr(row[c]) == target[c]) correct++;
    }
    if (correct > best) best = correct;
  }
  return best;
}

bool movedThawedLetter(GridState before, GridState after, Move move) {
  final a = before.letters;
  final b = after.letters;
  return before.thawedCells.any((c) =>
      (move.axis == MoveAxis.row ? c.row : c.col) == move.index &&
      a[c.row][c.col] != b[c.row][c.col]);
}

/// Real-engine replay, including terminal and rejected-move checks.
List<GridState>? replay(
    EngineConfig config, WordValidator words, List<Move> moves,
    {bool requireWin = true}) {
  final states = <GridState>[GridState.initial(config, words)];
  for (final move in moves) {
    final step = states.last.applyMove(move, config, words);
    if (!step.applied) return null;
    states.add(step.state);
  }
  if (requireWin && !states.last.isSolved) return null;
  return states;
}

/// Finds a shortest bounded witness. The optional second engine must accept
/// exactly the same sequence and win on its last move (Q5 common optimum).
///
/// A child is kept only if `depth + lowerBound(child) <= maxDepth` (for the
/// common search, the larger bound of the two engines). The bound is
/// admissible, so a cut child cannot win within [maxDepth] and absence stays
/// exhaustive; it is consistent, so the first discoverer of every kept state is
/// kept and the returned witness equals the unpruned breadth-first one (F07
/// A7). Move filters and history flags only restrict paths, which keeps both
/// properties. [lowerBound] exists for the pruned-vs-exhaustive tests.
WitnessSearch searchWitness(
  EngineConfig config,
  WordValidator words, {
  required int maxDepth,
  SearchBudget budget = const SearchBudget(),
  bool nondecreasingOnly = false,
  int? thawRowBeforeWin,
  bool requireUsefulThaw = false,
  EngineConfig? commonWith,
  SearchStats? stats,
  MoveLowerBound Function(EngineConfig)? lowerBound,
  String phase = 'quality witness',
}) {
  final guard = SearchGuard(budget, phase, stats: stats);
  final bound = (lowerBound ?? (c) => WinLowerBound(c).call)(config);
  final otherBound = commonWith == null
      ? null
      : (lowerBound ?? (c) => WinLowerBound(c).call)(commonWith);
  final start = GridState.initial(config, words);
  final other =
      commonWith == null ? null : GridState.initial(commonWith, words);
  final nodes = <_Node>[_Node(start, other, -1, null, 0, false, false)];
  final queue = Queue<int>()..add(0);
  final seen = <String>{nodes.first.key};
  List<Move> path(int i) {
    final moves = <Move>[];
    while (nodes[i].parent >= 0) {
      moves.add(nodes[i].move!);
      i = nodes[i].parent;
    }
    return moves.reversed.toList();
  }

  try {
    while (queue.isNotEmpty) {
      guard.check(nodes.length);
      final i = queue.removeFirst();
      final node = nodes[i];
      if (node.state.isSolved) {
        if ((commonWith == null || node.other!.isSolved) &&
            (thawRowBeforeWin == null || node.thawed) &&
            (!requireUsefulThaw || node.used)) {
          return WitnessSearch('FOUND', path(i), nodes.length);
        }
        continue;
      }
      if (node.depth >= maxDepth) continue;
      if (node.depth >= budget.maxDepth) {
        throw guard.exceeded(SearchStopCause.depth);
      }
      for (final move in config.legalMoves(node.state)) {
        guard.check(nodes.length);
        final step = node.state.applyMove(move, config, words);
        if (!step.applied) continue;
        if (nondecreasingOnly &&
            maxCorrect(config, step.state) < maxCorrect(config, node.state)) {
          continue;
        }
        GridState? nextOther;
        if (commonWith != null) {
          final second = node.other!.applyMove(move, commonWith, words);
          if (!second.applied) continue;
          nextOther = second.state;
          // Neither terminal engine permits a later continuation.
          if (step.state.isSolved != nextOther.isSolved) continue;
        }
        var remaining = bound(step.state);
        if (otherBound != null) {
          final second = otherBound(nextOther!);
          if (second > remaining) remaining = second;
        }
        if (node.depth + 1 + remaining > maxDepth) continue;
        final thawed = node.thawed ||
            (thawRowBeforeWin != null &&
                !step.state.isSolved &&
                step.state.thawedCells.any((c) =>
                    c.row == thawRowBeforeWin &&
                    !start.thawedCells.contains(c)));
        final used = requireUsefulThaw &&
            (node.used || movedThawedLetter(node.state, step.state, move));
        final child =
            _Node(step.state, nextOther, i, move, node.depth + 1, thawed, used);
        if (!seen.add(child.key)) continue;
        guard.check(nodes.length + 1);
        nodes.add(child);
        queue.add(nodes.length - 1);
      }
    }
    return WitnessSearch('ABSENT_WITHIN_DEPTH', const [], nodes.length);
  } on SearchLimitExceeded catch (stop) {
    return WitnessSearch('UNKNOWN', const [], nodes.length, stop: stop);
  }
}

final class _Node {
  _Node(this.state, this.other, this.parent, this.move, this.depth, this.thawed,
      this.used);
  final GridState state;
  final GridState? other;
  final int parent;
  final Move? move;
  final int depth;
  final bool thawed;
  final bool used;
  String get key =>
      '${state.canonicalKey()}|${other?.canonicalKey()}|$thawed|$used';
}
