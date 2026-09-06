import 'package:flutter/foundation.dart';

import '../persistence/active_session_snapshot.dart' show PuzzleSource;

/// How this completion compares to the level's stored personal best
/// (`architecture.md` §5).
enum BestOutcome {
  /// No prior `personal_best` row — this result sets the bar (AC8).
  firstClear,

  /// Beat the previous best (AC6) — drives the celebratory panel treatment.
  newBest,

  /// Equalled the previous best.
  matchedBest,

  /// Worse than the previous best (AC5) — the panel shows this run's stars but
  /// the retained better `personalBestMoves`.
  noImprovement,
}

/// Immutable result of a solved puzzle, built by F03's win path and handed to
/// the F04 completion panel (`architecture.md` §5). Only produced when the
/// puzzle carries a usable `optimalMoves` — the defensive no-optimal case is a
/// `CompletionResult`-less "bare completion" (`architecture.md` §6).
@immutable
class CompletionResult {
  const CompletionResult({
    required this.levelId,
    required this.source,
    required this.targetWord,
    required this.playerMoves,
    required this.optimalMoves,
    required this.stars,
    required this.isPerfect,
    required this.personalBestMoves,
    required this.bestIsPerfect,
    required this.bestOutcome,
    required this.ratingPersisted,
  });

  /// The puzzle id — the `personal_best` key (journey / debug).
  final String levelId;
  final PuzzleSource source;
  final String targetWord;

  /// `engine.moveCount` — net of undos.
  final int playerMoves;
  final int optimalMoves;

  /// 1..3 (never 0).
  final int stars;

  /// `stars == 3`.
  final bool isPerfect;

  /// The best **after** this completion is recorded (`== playerMoves` on
  /// `firstClear` / `newBest`). `0` is the sentinel for "unavailable" — the
  /// write failed, or the read-back has not resolved yet, or this is a Daily
  /// completion (F07 owns Daily persistence). The panel renders "—".
  final int personalBestMoves;

  /// `personal_best.isPerfect` after the write.
  final bool bestIsPerfect;

  final BestOutcome bestOutcome;

  /// `true` only for a journey completion that was actually written to
  /// `personal_best`. `false` for Daily (F07) and for a caught write failure.
  final bool ratingPersisted;

  /// Whether a real personal-best figure is available to show.
  bool get personalBestAvailable => personalBestMoves > 0;

  /// How far this run was from optimal (`0` ⇔ Perfect). Never negative for a
  /// valid input.
  int get movesOverOptimal =>
      playerMoves > optimalMoves ? playerMoves - optimalMoves : 0;

  CompletionResult copyWith({
    int? personalBestMoves,
    bool? bestIsPerfect,
    BestOutcome? bestOutcome,
    bool? ratingPersisted,
  }) => CompletionResult(
    levelId: levelId,
    source: source,
    targetWord: targetWord,
    playerMoves: playerMoves,
    optimalMoves: optimalMoves,
    stars: stars,
    isPerfect: isPerfect,
    personalBestMoves: personalBestMoves ?? this.personalBestMoves,
    bestIsPerfect: bestIsPerfect ?? this.bestIsPerfect,
    bestOutcome: bestOutcome ?? this.bestOutcome,
    ratingPersisted: ratingPersisted ?? this.ratingPersisted,
  );
}

/// Pure derivation of [BestOutcome] from this run's move count and the best that
/// existed **before** the write (`null` ⇔ first clear). Unit-tested alongside
/// F08's `PersonalBestRepo` (`architecture.md` §11).
BestOutcome bestOutcomeFor({required int player, required int? priorBest}) {
  if (priorBest == null) {
    return BestOutcome.firstClear;
  }
  if (player < priorBest) {
    return BestOutcome.newBest;
  }
  if (player == priorBest) {
    return BestOutcome.matchedBest;
  }
  return BestOutcome.noImprovement;
}
