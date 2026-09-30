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

  /// Wall-clock safety ceiling, checked after the node bound (host-dependent).
  final Duration timeBudget;
}

/// Why a bounded analysis stopped. Node and depth stops are properties of the
/// inputs; a time stop is the outer safety ceiling and depends on the host.
enum SearchStopCause { nodes, depth, time }

/// A bounded analysis did not finish. Never interpret this as absence of a
/// path, or publish partial metrics as a complete difficulty calculation.
final class SearchLimitExceeded implements Exception {
  const SearchLimitExceeded(this.phase, this.budget,
      {this.cause = SearchStopCause.depth,
      this.nodes = 0,
      this.elapsed = Duration.zero});
  final String phase;
  final SearchBudget budget;
  final SearchStopCause cause;

  /// Resource count when the analysis stopped (see [SearchGuard.check]).
  final int nodes;
  final Duration elapsed;

  /// Machine-readable stop record for reports.
  Map<String, Object> toJson() => {
        'phase': phase,
        'cause': cause.name,
        'nodes': nodes,
        'elapsedMs': elapsed.inMilliseconds,
      };
  @override
  String toString() => 'SearchLimitExceeded($phase: UNKNOWN, cause '
      '${cause.name}, nodes $nodes, ${elapsed.inMilliseconds} ms)';
}

/// Shared guard for a single analysis. Count retained distinct states in graph
/// searches and explored prefixes in path enumeration (both consume resources).
///
/// The node bound is checked before the clock, so an analysis that fits the
/// node bound is decided by its inputs; the clock only stops a runaway.
final class SearchGuard {
  SearchGuard(this.budget, this.phase, {SearchStats? stats}) {
    if (budget.maxDepth < 0 ||
        budget.maxNodes < 1 ||
        budget.timeBudget <= Duration.zero) {
      throw ArgumentError('Search budget must have nonnegative depth, positive '
          'nodes and positive time');
    }
    stats?._guards.add(this);
  }
  final SearchBudget budget;
  final String phase;
  final Stopwatch _watch = Stopwatch()..start();
  int _peak = 0;
  Duration _lastCheck = Duration.zero;

  /// Largest resource count seen by [check].
  int get peakNodes => _peak;

  /// Time from creation to the last [check]: the phase's duration once it has
  /// finished (the guard is not told when a phase ends).
  Duration get elapsed => _lastCheck;

  void check(int nodes) {
    if (nodes > _peak) _peak = nodes;
    _lastCheck = _watch.elapsed;
    if (nodes > budget.maxNodes) throw exceeded(SearchStopCause.nodes);
    if (_watch.elapsed >= budget.timeBudget) {
      throw exceeded(SearchStopCause.time);
    }
  }

  SearchLimitExceeded exceeded(SearchStopCause cause) {
    _lastCheck = _watch.elapsed;
    return SearchLimitExceeded(phase, budget,
        cause: cause, nodes: _peak, elapsed: _lastCheck);
  }
}

/// Optional collector of per-phase resource use, for evidence reports. It
/// never changes a search result.
final class SearchStats {
  final List<SearchGuard> _guards = [];

  /// One entry per guarded phase, in creation order.
  List<Map<String, Object>> toJson() => [
        for (final guard in _guards)
          {
            'phase': guard.phase,
            'peakNodes': guard.peakNodes,
            'elapsedMs': guard.elapsed.inMilliseconds,
          }
      ];
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
  const BudgetExceeded(this.budget,
      {this.cause = SearchStopCause.depth,
      this.nodes = 0,
      this.elapsed = Duration.zero});

  final SearchBudget budget;
  final SearchStopCause cause;
  final int nodes;
  final Duration elapsed;
}
