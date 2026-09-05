import 'package:looplet_core/looplet_core.dart';

import 'grid_state.dart';
import 'move.dart';

/// Thrown synchronously by [EngineConfig] for a malformed puzzle definition.
/// This is a programming / authoring error, not a runtime path.
final class EngineConfigError extends ArgumentError {
  EngineConfigError(super.message);
}

/// Immutable static puzzle data for the engine: the authored grid, the target
/// word, the locked and frozen cells, and whether column moves are allowed.
///
/// The engine is written for a square `gridSize` taken from [initialGrid], not
/// hard-coded to 5.
final class EngineConfig {
  factory EngineConfig({
    required List<List<String>> initialGrid,
    required String targetWord,
    Set<GridCoord> lockedCells = const <GridCoord>{},
    Set<GridCoord> frozenCells = const <GridCoord>{},
    bool columnMovesEnabled = true,
  }) {
    final size = _validate(initialGrid, targetWord, lockedCells, frozenCells);
    final grid = List<List<String>>.unmodifiable(<List<String>>[
      for (final row in initialGrid) List<String>.unmodifiable(row),
    ]);
    return EngineConfig._(
      initialGrid: grid,
      targetWord: targetWord,
      lockedCells: Set<GridCoord>.unmodifiable(lockedCells),
      frozenCells: Set<GridCoord>.unmodifiable(frozenCells),
      columnMovesEnabled: columnMovesEnabled,
      gridSize: size,
    );
  }

  EngineConfig._({
    required this.initialGrid,
    required this.targetWord,
    required this.lockedCells,
    required this.frozenCells,
    required this.columnMovesEnabled,
    required this.gridSize,
  });

  /// `[row][col]`, unmodifiable; each cell is a single letter (authored casing).
  final List<List<String>> initialGrid;

  /// MVP: `targetWord.runes.length == gridSize`; letters only.
  final String targetWord;

  /// Coordinates whose letters never move. May be empty; several per line OK.
  final Set<GridCoord> lockedCells;

  /// Coordinates that are immovable until a valid word forms in their row.
  /// Disjoint from [lockedCells].
  final Set<GridCoord> frozenCells;

  /// `false` for Journey levels 1–3 — the engine rejects column moves.
  final bool columnMovesEnabled;

  /// Side length of the square grid (5 for the MVP).
  final int gridSize;

  static final RegExp _letter = RegExp(r'^\p{L}$', unicode: true);
  static final RegExp _letters = RegExp(r'^\p{L}+$', unicode: true);

  static int _validate(
    List<List<String>> grid,
    String targetWord,
    Set<GridCoord> locked,
    Set<GridCoord> frozen,
  ) {
    if (grid.isEmpty) {
      throw EngineConfigError('initialGrid must not be empty');
    }
    final size = grid.length;
    for (var r = 0; r < size; r++) {
      final row = grid[r];
      if (row.length != size) {
        throw EngineConfigError(
          'initialGrid must be square: row $r has ${row.length} cells, '
          'expected $size',
        );
      }
      for (var c = 0; c < size; c++) {
        final cell = row[c];
        if (cell.runes.length != 1 || !_letter.hasMatch(cell)) {
          throw EngineConfigError(
            'initialGrid[$r][$c] must be a single letter, got "$cell"',
          );
        }
      }
    }
    if (targetWord.runes.length != size || !_letters.hasMatch(targetWord)) {
      throw EngineConfigError(
        'targetWord must be $size letters, got "$targetWord"',
      );
    }
    for (final coord in <GridCoord>{...locked, ...frozen}) {
      if (coord.row < 0 ||
          coord.row >= size ||
          coord.col < 0 ||
          coord.col >= size) {
        throw EngineConfigError('cell $coord is out of range for a $size grid');
      }
    }
    final overlap = locked.intersection(frozen);
    if (overlap.isNotEmpty) {
      throw EngineConfigError(
        'a cell cannot be both locked and frozen: ${overlap.first}',
      );
    }
    return size;
  }

  /// Every move that would return `applied: true` from [state]: excludes column
  /// moves when disabled, excludes fully-immovable lines, and is empty once the
  /// puzzle is solved.
  List<Move> legalMoves(GridState state) {
    if (state.isSolved) return const <Move>[];
    final moves = <Move>[];
    for (var i = 0; i < gridSize; i++) {
      if (_movableCount(state, MoveAxis.row, i) >= 2) {
        moves
          ..add(Move.rowLeft(i))
          ..add(Move.rowRight(i));
      }
      if (columnMovesEnabled && _movableCount(state, MoveAxis.column, i) >= 2) {
        moves
          ..add(Move.columnUp(i))
          ..add(Move.columnDown(i));
      }
    }
    return moves;
  }

  int _movableCount(GridState state, MoveAxis axis, int index) {
    var count = 0;
    for (var i = 0; i < gridSize; i++) {
      final coord =
          axis == MoveAxis.row ? GridCoord(index, i) : GridCoord(i, index);
      if (state.isMovable(coord)) count++;
    }
    return count;
  }
}
