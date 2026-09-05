import 'package:looplet_core/looplet_core.dart';

import 'engine_config.dart';
import 'move.dart';
import 'word_validator.dart';

/// Why an `applyMove` / `undo` was not applied. Nothing changes on a rejection.
enum MoveRejectReason {
  /// A column move on a puzzle where `columnMovesEnabled == false`.
  columnMovesDisabled,

  /// The target line has ≤ 1 movable cell, so a rotation would be identity.
  lineFullyImmovable,

  /// `move.index` is out of range, or the direction does not match the axis.
  outOfRange,

  /// `applyMove` / `undo` after the puzzle is solved.
  puzzleComplete,

  /// `undo` with no applied moves.
  nothingToUndo,
}

/// The result of one `applyMove` / `undo` step.
final class GridStep {
  const GridStep({
    required this.applied,
    required this.state,
    this.rejectedReason,
    this.thawedThisStep = false,
    this.solvedThisStep = false,
  });

  /// Whether the step changed the grid. When `false`, [state] is the unchanged
  /// pre-step state and [rejectedReason] is non-null.
  final bool applied;

  /// Non-null iff `applied == false`.
  final MoveRejectReason? rejectedReason;

  /// The next state if [applied]; the unchanged state otherwise.
  final GridState state;

  /// A frozen tile thawed on this step.
  final bool thawedThisStep;

  /// The puzzle became solved on this step.
  final bool solvedThisStep;
}

/// Immutable snapshot of the grid: the 25 letters, which frozen tiles have
/// thawed, and whether the target is formed. Pure — `applyMove` returns a new
/// [GridState] and never mutates `this`.
final class GridState {
  const GridState._(this._config, this._cells, this._thawed, this.isSolved);

  /// The t = 0 state for [config]: thaw and win are evaluated once against the
  /// authored grid, so a pre-worded frozen row or a pre-solved grid is surfaced
  /// immediately.
  factory GridState.initial(EngineConfig config, WordValidator validator) {
    final cells = <String>[
      for (final row in config.initialGrid) ...row,
    ];
    final thawed = _evaluateThaw(
      config,
      cells,
      const <GridCoord>{},
      validator,
    );
    final solved = _evaluateWin(config, cells);
    return GridState._(
      config,
      List<String>.unmodifiable(cells),
      Set<GridCoord>.unmodifiable(thawed),
      solved,
    );
  }

  final EngineConfig _config;

  /// Row-major, length `gridSize * gridSize`. Unmodifiable.
  final List<String> _cells;

  /// Frozen cells that have thawed so far. Unmodifiable.
  final Set<GridCoord> _thawed;

  /// The target word occupies a contiguous left-to-right run in some row.
  final bool isSolved;

  int get _size => _config.gridSize;

  String _at(int row, int col) => _cells[row * _size + col];

  /// Current letters as a nested `[row][col]` list (unmodifiable, materialized
  /// on each call — the hot path is `applyMove`, not this).
  List<List<String>> get letters =>
      List<List<String>>.unmodifiable(<List<String>>[
        for (var r = 0; r < _size; r++)
          List<String>.unmodifiable(<String>[
            for (var c = 0; c < _size; c++) _cells[r * _size + c],
          ]),
      ]);

  /// Frozen tiles that have thawed (unmodifiable).
  Set<GridCoord> get thawedCells => _thawed;

  TileStatus statusAt(GridCoord c) {
    if (_config.lockedCells.contains(c)) return TileStatus.locked;
    if (_thawed.contains(c)) return TileStatus.thawed;
    if (_config.frozenCells.contains(c)) return TileStatus.frozen;
    return TileStatus.normal;
  }

  /// A cell that a shift can move: `normal` or `thawed`.
  bool isMovable(GridCoord c) {
    final s = statusAt(c);
    return s == TileStatus.normal || s == TileStatus.thawed;
  }

  /// Stable state identity for search / deduplication (F06). Turkish-lower
  /// letters row-major, then `§`, then thawed coordinates sorted row-major.
  /// Excludes locked cells, the target, and `columnMovesEnabled` — those are
  /// constant across an F06 search and carried by [EngineConfig].
  String canonicalKey() {
    final buffer = StringBuffer();
    for (final cell in _cells) {
      buffer.write(TurkishCase.toLowerTr(cell));
    }
    buffer.write('§');
    final sorted = _thawed.toList()..sort();
    buffer.write(sorted.map((c) => '${c.row},${c.col}').join(';'));
    return buffer.toString();
  }

  /// Pure step. Never throws for a rejected move — returns `applied == false`
  /// with the unchanged state. See `architecture.md` "Shift algorithm".
  ///
  /// The [config] parameter is kept for call-site clarity and API stability, but
  /// every config read goes through the stored `_config` so there is a single
  /// source of truth. Callers must pass a config equivalent to the one this
  /// state was built with.
  GridStep applyMove(Move move, EngineConfig config, WordValidator validator) {
    if (isSolved) {
      return GridStep(
        applied: false,
        state: this,
        rejectedReason: MoveRejectReason.puzzleComplete,
      );
    }
    if (move.axis == MoveAxis.column && !_config.columnMovesEnabled) {
      return GridStep(
        applied: false,
        state: this,
        rejectedReason: MoveRejectReason.columnMovesDisabled,
      );
    }
    if (move.index < 0 ||
        move.index >= _config.gridSize ||
        !move.axisDirectionMatches) {
      return GridStep(
        applied: false,
        state: this,
        rejectedReason: MoveRejectReason.outOfRange,
      );
    }

    final line = _lineCoords(move.axis, move.index);
    final movablePositions = <int>[];
    for (var i = 0; i < line.length; i++) {
      if (isMovable(line[i])) movablePositions.add(i);
    }
    if (movablePositions.length <= 1) {
      return GridStep(
        applied: false,
        state: this,
        rejectedReason: MoveRejectReason.lineFullyImmovable,
      );
    }

    final k = movablePositions.length;
    final movableLetters = <String>[
      for (final p in movablePositions) _at(line[p].row, line[p].col),
    ];
    final next = List<String>.of(_cells);
    for (var i = 0; i < k; i++) {
      // Forward (right / down): new letter at movable position i is the letter
      // that was at movable position i-1 (wrapping). Backward: i+1.
      final srcIndex = (move.isForward ? i - 1 : i + 1) % k;
      final coord = line[movablePositions[i]];
      next[coord.row * _size + coord.col] = movableLetters[srcIndex];
    }

    final nextThawed = _evaluateThaw(_config, next, _thawed, validator);
    final nextSolved = _evaluateWin(_config, next);

    return GridStep(
      applied: true,
      state: GridState._(
        _config,
        List<String>.unmodifiable(next),
        Set<GridCoord>.unmodifiable(nextThawed),
        nextSolved,
      ),
      thawedThisStep: nextThawed.length > _thawed.length,
      solvedThisStep: nextSolved && !isSolved,
    );
  }

  List<GridCoord> _lineCoords(MoveAxis axis, int index) => <GridCoord>[
        for (var i = 0; i < _size; i++)
          axis == MoveAxis.row ? GridCoord(index, i) : GridCoord(i, index),
      ];

  // --- pure static evaluators -------------------------------------------------

  /// Rows containing a still-frozen tile are scanned for any contiguous
  /// left-to-right run of ≥ 4 letters that the validator accepts. If found,
  /// every still-frozen tile in that row thaws. Row only — never the column.
  static Set<GridCoord> _evaluateThaw(
    EngineConfig config,
    List<String> cells,
    Set<GridCoord> current,
    WordValidator validator,
  ) {
    if (config.frozenCells.isEmpty) return current;

    final unthawedRows = <int>{};
    for (final fc in config.frozenCells) {
      if (!current.contains(fc)) unthawedRows.add(fc.row);
    }
    if (unthawedRows.isEmpty) return current;

    final size = config.gridSize;
    Set<GridCoord>? result;
    for (final row in unthawedRows) {
      final rowLetters = <String>[
        for (var c = 0; c < size; c++) cells[row * size + c],
      ];
      if (_rowHasValidWord(rowLetters, validator)) {
        result ??= <GridCoord>{...current};
        for (final fc in config.frozenCells) {
          if (fc.row == row) result.add(fc);
        }
      }
    }
    return result ?? current;
  }

  /// Every contiguous left-to-right window of length 4..n.
  static bool _rowHasValidWord(
    List<String> rowLetters,
    WordValidator validator,
  ) {
    final n = rowLetters.length;
    for (var len = 4; len <= n; len++) {
      for (var start = 0; start + len <= n; start++) {
        final window = rowLetters.sublist(start, start + len).join();
        if (validator.isValidWord(window, minLength: 4)) return true;
      }
    }
    return false;
  }

  /// The target occupies a contiguous left-to-right run of `targetLength` cells
  /// in some row (Turkish-normalized comparison). Left-to-right only — reverse,
  /// vertical, and diagonal never match. For the MVP `targetLength == gridSize`,
  /// so this is a full-row match.
  static bool _evaluateWin(EngineConfig config, List<String> cells) {
    final size = config.gridSize;
    final target = TurkishCase.toLowerTr(config.targetWord);
    final targetLength = config.targetWord.runes.length;
    for (var row = 0; row < size; row++) {
      for (var start = 0; start + targetLength <= size; start++) {
        final runBuffer = StringBuffer();
        for (var c = start; c < start + targetLength; c++) {
          runBuffer.write(TurkishCase.toLowerTr(cells[row * size + c]));
        }
        if (runBuffer.toString() == target) return true;
      }
    }
    return false;
  }

  // --- value equality (letters + thawed + solved; NOT config) ---------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GridState) return false;
    if (other.isSolved != isSolved) return false;
    if (other._cells.length != _cells.length) return false;
    for (var i = 0; i < _cells.length; i++) {
      if (other._cells[i] != _cells[i]) return false;
    }
    return other._thawed.length == _thawed.length &&
        _thawed.every(other._thawed.contains);
  }

  @override
  int get hashCode => Object.hash(
        isSolved,
        Object.hashAll(_cells),
        Object.hashAllUnordered(_thawed),
      );

  @override
  String toString() => 'GridState(${_cells.map(TurkishCase.toLowerTr).join()}, '
      'thawed: ${_thawed.length}, solved: $isSolved)';
}
