import 'engine_config.dart';
import 'grid_state.dart';
import 'move.dart';
import 'word_validator.dart';

/// Stateful play-session façade over the pure [GridState] core: keeps the
/// applied-move history so `undo` and `restart` work, and exposes `moveCount`.
///
/// F06's solver uses the pure core directly and does not touch this class.
final class GridEngine {
  GridEngine(this.config, {required WordValidator validator})
      : _validator = validator,
        _initialState = GridState.initial(config, validator) {
    _state = _initialState;
  }

  final EngineConfig config;
  final WordValidator _validator;
  final GridState _initialState;
  final List<Move> _moves = <Move>[];

  late GridState _state;

  /// The current grid snapshot.
  GridState get state => _state;

  /// Number of applied moves. Rejected moves and `undo` never change this; it is
  /// frozen once the puzzle is solved.
  int get moveCount => _moves.length;

  bool get isSolved => _state.isSolved;

  /// The applied moves in order (unmodifiable).
  List<Move> get appliedMoves => List<Move>.unmodifiable(_moves);

  /// Applies [move]. Appends to the history and advances the state only if the
  /// step is `applied`; a rejected move leaves the engine untouched.
  GridStep applyMove(Move move) {
    final step = _state.applyMove(move, config, _validator);
    if (step.applied) {
      _moves.add(move);
      _state = step.state;
    }
    return step;
  }

  /// Removes the last applied move and re-folds the state from t = 0, so thaw
  /// and solved status are history-accurate (a tile can revert to `frozen`).
  ///
  /// Rejected with `nothingToUndo` when there is no history, or `puzzleComplete`
  /// once the puzzle is solved.
  GridStep undo() {
    if (_state.isSolved) {
      return GridStep(
        applied: false,
        state: _state,
        rejectedReason: MoveRejectReason.puzzleComplete,
      );
    }
    if (_moves.isEmpty) {
      return GridStep(
        applied: false,
        state: _state,
        rejectedReason: MoveRejectReason.nothingToUndo,
      );
    }
    _moves.removeLast();
    _state = _fold(_moves);
    return GridStep(applied: true, state: _state);
  }

  /// Returns to the authored initial state: clears the history and re-uses the
  /// cached t = 0 state. Always allowed, including after the puzzle is solved.
  void restart() {
    _moves.clear();
    _state = _initialState;
  }

  /// Replaces the history with [moves] (e.g. F08 resume) and folds. Throws
  /// [StateError] if any move does not apply — the caller should then fall back
  /// to a clean start. Produces the same state as replaying [applyMove] in order.
  void restoreMoves(List<Move> moves) {
    final folded = _fold(moves);
    _moves
      ..clear()
      ..addAll(moves);
    _state = folded;
  }

  GridState _fold(List<Move> moves) {
    var current = _initialState;
    for (var i = 0; i < moves.length; i++) {
      final step = current.applyMove(moves[i], config, _validator);
      if (!step.applied) {
        throw StateError(
          'grid-engine fold: move $i (${moves[i]}) rejected: '
          '${step.rejectedReason}',
        );
      }
      current = step.state;
    }
    return current;
  }
}
