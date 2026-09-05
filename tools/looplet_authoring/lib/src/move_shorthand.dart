import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';

/// `R<i>` row-right, `L<i>` row-left, `D<i>` column-down, `U<i>` column-up.
/// Example: `"R0 D2 L4"`.
class MoveShorthandException implements Exception {
  MoveShorthandException(this.message);
  final String message;
  @override
  String toString() => 'MoveShorthandException: $message';
}

List<Move> parseMoves(String input) {
  final tokens = input.trim().split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
  return <Move>[for (final token in tokens) _parseOne(token)];
}

Move _parseOne(String token) {
  if (token.length < 2) {
    throw MoveShorthandException('bad move token "$token"');
  }
  final index = int.tryParse(token.substring(1));
  if (index == null || index < 0) {
    throw MoveShorthandException('bad index in "$token"');
  }
  return switch (token[0].toUpperCase()) {
    'R' => Move.rowRight(index),
    'L' => Move.rowLeft(index),
    'D' => Move.columnDown(index),
    'U' => Move.columnUp(index),
    _ => throw MoveShorthandException('unknown move kind "${token[0]}"'),
  };
}

String formatMoves(List<Move> moves) => moves.map(formatMove).join(' ');

String formatMove(Move move) {
  final kind = switch (move.direction) {
    MoveDirection.right => 'R',
    MoveDirection.left => 'L',
    MoveDirection.down => 'D',
    MoveDirection.up => 'U',
  };
  return '$kind${move.index}';
}
