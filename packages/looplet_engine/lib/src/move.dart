import 'package:looplet_core/looplet_core.dart';

/// A single-cell circular shift of one row or column. Construct with a named
/// constructor so the axis and direction are always a valid pair.
final class Move {
  const Move._(this.axis, this.index, this.direction);

  /// Shift row [index] one cell left (`[b c d e a]`).
  const Move.rowLeft(int index)
      : this._(MoveAxis.row, index, MoveDirection.left);

  /// Shift row [index] one cell right (`[e a b c d]`).
  const Move.rowRight(int index)
      : this._(MoveAxis.row, index, MoveDirection.right);

  /// Shift column [index] one cell up (`[b c d e a]` top-to-bottom).
  const Move.columnUp(int index)
      : this._(MoveAxis.column, index, MoveDirection.up);

  /// Shift column [index] one cell down (`[e a b c d]` top-to-bottom).
  const Move.columnDown(int index)
      : this._(MoveAxis.column, index, MoveDirection.down);

  final MoveAxis axis;
  final int index;
  final MoveDirection direction;

  /// True when [direction] is a valid pairing for [axis]. Always true for a
  /// Move built via a named constructor; checked defensively by the engine.
  bool get axisDirectionMatches => switch (axis) {
        MoveAxis.row =>
          direction == MoveDirection.left || direction == MoveDirection.right,
        MoveAxis.column =>
          direction == MoveDirection.up || direction == MoveDirection.down,
      };

  /// True for `right` (row) / `down` (column) — the "forward" rotation.
  bool get isForward =>
      direction == MoveDirection.right || direction == MoveDirection.down;

  @override
  bool operator ==(Object other) =>
      other is Move &&
      other.axis == axis &&
      other.index == index &&
      other.direction == direction;

  @override
  int get hashCode => Object.hash(axis, index, direction);

  @override
  String toString() => 'Move(${axis.name} $index ${direction.name})';
}
