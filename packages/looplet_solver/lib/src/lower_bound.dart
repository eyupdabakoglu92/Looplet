import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';

/// A lower bound on the number of moves from a state to a win. Searches prune
/// a node when `depth + bound > limit`; that is sound only for an admissible
/// bound (never above the true remaining distance). Returns [unreachable] when
/// no win is possible from the state.
typedef MoveLowerBound = int Function(GridState state);

/// No pruning: every search becomes exhaustive. Reference for tests.
int noLowerBound(GridState state) => 0;

/// Admissible and consistent lower bound for the F02 engine (F07 A7).
///
/// For a win in row `r` at window start `s`, let `M` be the window cells whose
/// letter differs from the target and `d` the number of target letters (as a
/// multiset) missing from row `r`. Then:
///
/// * a row move never changes which letters a row holds, a column move changes
///   exactly one cell of row `r`, and a thaw changes no letter — so at least
///   `d` column moves are needed;
/// * a cell of row `r` changes only by a row-`r` move or a move of its column —
///   so a solution with no row-`r` move needs a move in each column of `M`
///   (`|M|` moves), and one with a row-`r` move needs `1 + d`;
/// * a locked cell never changes, so a window with a wrong locked cell cannot
///   win.
///
/// The bound is `min over (r, s)` of `min(|M|, 1 + d)`. One move changes `|M|`
/// and `d` of any window by at most one, except a row-`r` move, which leaves
/// `d` unchanged and keeps `|M| >= d`; so the bound drops by at most one per
/// move (consistent). Frozen cells are treated as movable (they may thaw),
/// which only lowers the bound.
final class WinLowerBound {
  WinLowerBound(EngineConfig config)
      : _size = config.gridSize,
        _target = [
          for (final rune in config.targetWord.runes)
            TurkishCase.toLowerTr(String.fromCharCode(rune))
        ],
        _locked = {
          for (final c in config.lockedCells) c.row * config.gridSize + c.col
        } {
    for (final letter in _target) {
      _need[letter] = (_need[letter] ?? 0) + 1;
    }
  }

  /// Larger than any search depth; no win is reachable.
  static const int unreachable = 1 << 20;

  final int _size;
  final List<String> _target;
  final Set<int> _locked;
  final Map<String, int> _need = {};

  int call(GridState state) {
    if (state.isSolved) return 0;
    final rows = state.letters;
    var best = unreachable;
    for (var r = 0; r < _size; r++) {
      final row = [for (final letter in rows[r]) TurkishCase.toLowerTr(letter)];
      final have = <String, int>{};
      for (final letter in row) {
        have[letter] = (have[letter] ?? 0) + 1;
      }
      var missing = 0;
      _need.forEach((letter, count) {
        final present = have[letter] ?? 0;
        if (count > present) missing += count - present;
      });
      for (var start = 0; start + _target.length <= _size; start++) {
        var wrong = 0;
        var dead = false;
        for (var i = 0; i < _target.length; i++) {
          if (row[start + i] != _target[i]) {
            wrong++;
            if (_locked.contains(r * _size + start + i)) {
              dead = true;
              break;
            }
          }
        }
        if (dead) continue;
        final bound = wrong < 1 + missing ? wrong : 1 + missing;
        if (bound < best) best = bound;
      }
    }
    return best;
  }
}
