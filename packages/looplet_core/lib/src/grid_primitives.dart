// Engine primitive value types shared by looplet_engine, looplet_content, the
// app, and the authoring tools. These live in looplet_core (not looplet_content)
// so looplet_engine can use them without depending on looplet_content
// (see project-authority/platform.md §11).

/// Whether a move acts on a grid row or a grid column.
enum MoveAxis { row, column }

/// The direction a row or column is shifted by one cell. `left`/`right` pair
/// with [MoveAxis.row]; `up`/`down` pair with [MoveAxis.column].
enum MoveDirection { left, right, up, down }

/// The status of a single grid cell.
///
/// * `normal` — a movable cell with no special behavior.
/// * `locked` — never moves; other cells of its line rotate around it. Stays
///   locked for the whole puzzle.
/// * `frozen` — immovable (like `locked`) until a valid word forms in its row.
/// * `thawed` — a `frozen` cell that has been unlocked; behaves like `normal`
///   for the rest of the session.
enum TileStatus { normal, locked, frozen, thawed }

/// A `(row, col)` cell coordinate. Value type: equal coordinates are `==` and
/// share a `hashCode`; [compareTo] orders row-major (row, then col).
final class GridCoord implements Comparable<GridCoord> {
  const GridCoord(this.row, this.col);

  final int row;
  final int col;

  @override
  bool operator ==(Object other) =>
      other is GridCoord && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  int compareTo(GridCoord other) {
    final byRow = row.compareTo(other.row);
    return byRow != 0 ? byRow : col.compareTo(other.col);
  }

  @override
  String toString() => 'GridCoord($row, $col)';
}
