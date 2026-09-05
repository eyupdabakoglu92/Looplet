import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';

/// A [WordValidator] over an explicit word set (Turkish-normalized).
class SetWordValidator implements WordValidator {
  SetWordValidator(Iterable<String> words)
      : _words = words.map(TurkishCase.toLowerTr).toSet();

  final Set<String> _words;

  @override
  bool isValidWord(String candidate, {int minLength = 1}) {
    if (candidate.runes.length < minLength) return false;
    return _words.contains(TurkishCase.toLowerTr(candidate));
  }
}

/// Builds an [EngineConfig] from row strings like `'MASAL'`.
EngineConfig cfg(
  List<String> rows, {
  required String target,
  Set<GridCoord> locked = const <GridCoord>{},
  Set<GridCoord> frozen = const <GridCoord>{},
  bool columns = true,
}) =>
    EngineConfig(
      initialGrid: <List<String>>[for (final r in rows) r.split('')],
      targetWord: target,
      lockedCells: locked,
      frozenCells: frozen,
      columnMovesEnabled: columns,
    );

/// INDEPENDENT minimum-move reference: iterative-deepening DFS with **no
/// visited set** (full re-exploration each depth). Different algorithm from
/// `Solver.solve` (BFS + dedup), so agreement is real evidence of correctness.
/// Returns the true optimal, or `null` if unsolvable within [maxLimit].
int? referenceOptimal(
  EngineConfig config,
  WordValidator validator, {
  int maxLimit = 5,
}) {
  final start = GridState.initial(config, validator);
  for (var limit = 0; limit <= maxLimit; limit++) {
    if (_dfs(start, config, validator, limit)) return limit;
  }
  return null;
}

bool _dfs(
    GridState state, EngineConfig config, WordValidator validator, int limit) {
  if (state.isSolved) return true;
  if (limit == 0) return false;
  for (final move in config.legalMoves(state)) {
    final step = state.applyMove(move, config, validator);
    if (!step.applied) continue;
    if (_dfs(step.state, config, validator, limit - 1)) return true;
  }
  return false;
}

/// Folds [moves] over `GridState.initial` and asserts each step applies; returns
/// the final state.
GridState fold(EngineConfig config, WordValidator validator, List<Move> moves) {
  var state = GridState.initial(config, validator);
  for (final move in moves) {
    final step = state.applyMove(move, config, validator);
    if (!step.applied) {
      throw StateError('move $move did not apply during fold');
    }
    state = step.state;
  }
  return state;
}

String seqString(List<Move> moves) => moves.map((m) => m.toString()).join(' ');
