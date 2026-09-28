import 'package:flutter/foundation.dart';

import 'completion_result.dart';

/// The verdict badge (F03 architecture §20.3 (5), audit C-4).
enum ResultBadge { none, perfect, newBest }

/// What "Next" does from this result (F03 architecture §20.3 (6)).
enum ResultNext {
  /// No Next handler (non-Journey session): the link is disabled
  /// "Sonraki bölüm · yakında".
  none,

  /// Journey level N < 30: "Sonraki bölüm".
  next,

  /// The last Journey level: "Yolculuğu tamamla" → the terminal Home (F05
  /// AC12).
  terminal,
}

/// Everything the full-screen result shows, derived from the controller's
/// completion — the §16.8 variant table as a pure function (F03 `ui-design.md`
/// §16.8, architecture §20.3 (5)–(6) and correction C1 of §20.7).
@immutable
class ResultModel {
  const ResultModel({
    required this.word,
    required this.playerMoves,
    required this.rated,
    required this.optimal,
    required this.stars,
    required this.perfect,
    required this.best,
    required this.bestIsPerfect,
    required this.badge,
    required this.next,
  });

  /// Builds the model from the controller's read model.
  ///
  /// * [completion] `null` → the defensive no-optimal fallback: no stars, no
  ///   badge, `—` for OPTİMAL and EN İYİ.
  /// * Stars, `isPerfect` and `HARİKA` come from the synchronous result and
  ///   never wait for the personal-best read-back (C1).
  /// * `EN İYİ` is `—` and `YENİ EN İYİ` absent until [ratingResolved], and
  ///   stay so when the write failed (`ratingPersisted == false`).
  factory ResultModel.from({
    required CompletionResult? completion,
    required bool ratingResolved,
    required String targetWord,
    required int moveCount,
    required ResultNext next,
  }) {
    if (completion == null) {
      return ResultModel(
        word: targetWord,
        playerMoves: moveCount,
        rated: false,
        optimal: null,
        stars: 0,
        perfect: false,
        best: null,
        bestIsPerfect: false,
        badge: ResultBadge.none,
        next: next,
      );
    }
    final bestKnown =
        ratingResolved &&
        completion.ratingPersisted &&
        completion.personalBestAvailable;
    final ResultBadge badge;
    if (completion.isPerfect) {
      badge = ResultBadge.perfect;
    } else if (bestKnown && completion.bestOutcome == BestOutcome.newBest) {
      badge = ResultBadge.newBest;
    } else {
      badge = ResultBadge.none;
    }
    return ResultModel(
      word: completion.targetWord,
      playerMoves: completion.playerMoves,
      rated: true,
      optimal: completion.optimalMoves,
      stars: completion.stars,
      perfect: completion.isPerfect,
      best: bestKnown ? completion.personalBestMoves : null,
      bestIsPerfect: bestKnown && completion.bestIsPerfect,
      badge: badge,
      next: next,
    );
  }

  /// The target word (the answer row spells it).
  final String word;
  final int playerMoves;

  /// `false` for the no-optimal fallback.
  final bool rated;

  /// `null` = "—".
  final int? optimal;

  /// 1..3 when [rated]; 0 otherwise.
  final int stars;
  final bool perfect;

  /// The retained personal best; `null` = "—" (not resolved yet, not
  /// persisted, or unrated).
  final int? best;

  /// The small lime ★ beside `EN İYİ`.
  final bool bestIsPerfect;
  final ResultBadge badge;
  final ResultNext next;

  /// "Sonraki bölüm" (or "Yolculuğu tamamla") is the lime pill iff Perfect
  /// and a Next handler exists; otherwise "Tekrar oyna" is (F04 §7 as
  /// shipped, §20.3 (6)).
  bool get nextIsPrimary => perfect && next != ResultNext.none;

  /// The Next link is disabled ("· yakında") iff there is no handler.
  bool get nextDisabled => next == ResultNext.none;

  @override
  bool operator ==(Object other) =>
      other is ResultModel &&
      other.word == word &&
      other.playerMoves == playerMoves &&
      other.rated == rated &&
      other.optimal == optimal &&
      other.stars == stars &&
      other.perfect == perfect &&
      other.best == best &&
      other.bestIsPerfect == bestIsPerfect &&
      other.badge == badge &&
      other.next == next;

  @override
  int get hashCode => Object.hash(
    word,
    playerMoves,
    rated,
    optimal,
    stars,
    perfect,
    best,
    bestIsPerfect,
    badge,
    next,
  );
}
