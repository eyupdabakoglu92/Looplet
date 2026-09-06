import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_engine/looplet_engine.dart';

import '../content/puzzle_engine_config.dart';
import '../engine/move_shorthand.dart';
import 'active_session_snapshot.dart';
import 'elapsed_timer.dart';

/// A hydrated play session rebuilt from an [ActiveSessionSnapshot]. Handed to
/// F03, which owns the play UI. The engine's `thawedCells` and `isSolved` are
/// **re-derived** by replaying `appliedMoves` — the snapshot's
/// `thawedFrozenCells` is only a render cache and is not trusted here.
class RestoredSession {
  RestoredSession({
    required this.engine,
    required this.puzzleId,
    required this.puzzleSource,
    required this.undosRemaining,
    required this.restartCount,
    required this.timer,
    required this.status,
    required this.startedAtUtcMs,
  });

  final GridEngine engine;
  final String puzzleId;
  final PuzzleSource puzzleSource;
  final int undosRemaining;
  final int restartCount;
  final ElapsedTimer timer;
  final ActiveSessionStatus status;
  final int startedAtUtcMs;
}

/// Raised when a snapshot cannot be replayed against its puzzle (e.g. the
/// dictionary corpus changed and a frozen-thaw move no longer applies). The
/// caller falls back to a clean start.
class SessionRestoreException implements Exception {
  SessionRestoreException(this.message);

  final String message;

  @override
  String toString() => 'SessionRestoreException: $message';
}

/// Rebuilds a [RestoredSession] from a validated [snapshot] + its [puzzle].
///
/// The [puzzle] is supplied by the caller (F03/F05/F07 resolve `snapshot.puzzleId`
/// to a `Puzzle` — for Journey from bundled content, for Daily from
/// `DailyPuzzleCache`). [validator] is the production `WordValidator`.
RestoredSession restoreSession(
  ActiveSessionSnapshot snapshot,
  Puzzle puzzle,
  WordValidator validator,
) {
  if (puzzle.id != snapshot.puzzleId) {
    throw SessionRestoreException(
      'puzzle "${puzzle.id}" does not match snapshot "${snapshot.puzzleId}"',
    );
  }

  final EngineConfig config;
  try {
    config = toEngineConfig(puzzle);
  } on EngineConfigError catch (e) {
    throw SessionRestoreException('invalid puzzle config: ${e.message}');
  }

  final engine = GridEngine(config, validator: validator);

  final List<Move> moves;
  try {
    moves = parseMoveList(snapshot.appliedMoves);
  } on MoveShorthandException catch (e) {
    throw SessionRestoreException('bad appliedMoves: ${e.message}');
  }

  try {
    engine.restoreMoves(moves);
  } on StateError catch (e) {
    throw SessionRestoreException('replay rejected: ${e.message}');
  }

  return RestoredSession(
    engine: engine,
    puzzleId: snapshot.puzzleId,
    puzzleSource: snapshot.puzzleSource,
    undosRemaining: snapshot.undosRemaining,
    restartCount: snapshot.restartCount,
    timer: ElapsedTimer.resumed(snapshot.elapsedMsAccumulated),
    status: snapshot.status,
    startedAtUtcMs: snapshot.startedAtUtcMs,
  );
}
