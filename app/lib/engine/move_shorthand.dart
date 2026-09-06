import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';

/// Compact textual form of a [Move] — the format the F08 active-session snapshot
/// persists and F06 def-files use: `R<i>` row-right, `L<i>` row-left,
/// `D<i>` column-down, `U<i>` column-up. Example: `"R0 D2 L4"`.
///
/// App-local so `app` needs no dependency on `tools/looplet_authoring` (which
/// carries an equivalent helper for the authoring CLI).
class MoveShorthandException implements Exception {
  MoveShorthandException(this.message);

  final String message;

  @override
  String toString() => 'MoveShorthandException: $message';
}

/// Parses `["R0", "D2", "L4"]` (the snapshot's `appliedMoves`) into moves.
List<Move> parseMoveList(Iterable<String> tokens) => <Move>[
  for (final token in tokens) parseMove(token),
];

/// Parses one token (`"R0"`). Throws [MoveShorthandException] if malformed.
Move parseMove(String token) {
  final trimmed = token.trim();
  if (trimmed.length < 2) {
    throw MoveShorthandException('bad move token "$token"');
  }
  final index = int.tryParse(trimmed.substring(1));
  if (index == null || index < 0) {
    throw MoveShorthandException('bad index in "$token"');
  }
  return switch (trimmed[0].toUpperCase()) {
    'R' => Move.rowRight(index),
    'L' => Move.rowLeft(index),
    'D' => Move.columnDown(index),
    'U' => Move.columnUp(index),
    _ => throw MoveShorthandException('unknown move kind "${trimmed[0]}"'),
  };
}

/// `["R0", "D2", "L4"]` for a move list — the snapshot's `appliedMoves`.
List<String> formatMoveList(Iterable<Move> moves) =>
    moves.map(formatMove).toList(growable: false);

/// `"R0"` for a single move.
String formatMove(Move move) {
  final kind = switch (move.direction) {
    MoveDirection.right => 'R',
    MoveDirection.left => 'L',
    MoveDirection.down => 'D',
    MoveDirection.up => 'U',
  };
  return '$kind${move.index}';
}
