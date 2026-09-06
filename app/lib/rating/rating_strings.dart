/// Externalized strings for the F04 completion panel (`architecture.md` §7).
///
/// LOOPLET is localization-ready (Turkish primary). There is no `gen_l10n`
/// toolchain yet, so — like F03's `PlayStrings` — F04 keeps its handful of
/// strings in a small per-language table. Final TR copy is owned by
/// PO / localization (same track as F03's microcopy follow-on).
///
/// The panel also reuses three F03 `PlayStrings` values verbatim:
/// `solvedKicker` (ÇÖZÜLDÜ), `retry` (Yeniden), `close` (Kapat).
class RatingStrings {
  const RatingStrings({
    required this.perfect,
    required this.newBest,
    required this.best,
    required this.you,
    required this.optimal,
    required this.firstRecord,
    required this.betterKept,
    required this.nextLevel,
    required this.soon,
    required this.ratingUnavailable,
    required this.starsOfThree,
    required this.starWord,
    required this.starsSemanticsPerfect,
  });

  /// Struck plate shown when `stars == 3`. TR: "HARİKA".
  final String perfect;

  /// Ribbon shown when `bestOutcome == newBest`. TR: "YENİ REKOR".
  final String newBest;

  /// Personal-best cell label. TR: "EN İYİ".
  final String best;

  /// Your-moves cell label. TR: "SEN".
  final String you;

  /// Optimal-moves cell label. TR: "OPTİMAL".
  final String optimal;

  /// First-clear tag on the best cell. TR: "İLK".
  final String firstRecord;

  /// `noImprovement` tag on the best cell. TR: "daha iyi".
  final String betterKept;

  /// Secondary CTA label (disabled in F04 scope). TR: "SONRAKİ".
  final String nextLevel;

  /// Disabled-affordance suffix on the secondary CTA. TR: "yakında".
  final String soon;

  /// Defensive no-optimal fallback line. TR: "Puan yok".
  final String ratingUnavailable;

  /// `{n}` filled by the caller — the "N / 3" caption under the stars.
  final String starsOfThree;

  /// The word for "stars" used in the screen-reader label. TR: "yıldız".
  final String starWord;

  /// Screen-reader suffix appended to the star count when `isPerfect`.
  /// TR: "Harika".
  final String starsSemanticsPerfect;

  /// Screen-reader label for the star group, e.g. "2 / 3 yıldız" or
  /// "3 / 3 yıldız — Harika".
  String starGroupSemantics({required int stars, required bool perfect}) {
    final base = '$stars / 3 $starWord';
    return perfect ? '$base — $starsSemanticsPerfect' : base;
  }

  /// The "N / 3" caption with `{n}` substituted.
  String starsCaption(int stars) => starsOfThree.replaceFirst('{n}', '$stars');

  static const RatingStrings _tr = RatingStrings(
    perfect: 'HARİKA',
    newBest: 'YENİ REKOR',
    best: 'EN İYİ',
    you: 'SEN',
    optimal: 'OPTİMAL',
    firstRecord: 'İLK',
    betterKept: 'daha iyi',
    nextLevel: 'SONRAKİ',
    soon: 'yakında',
    ratingUnavailable: 'Puan yok',
    starsOfThree: '{n} / 3',
    starWord: 'yıldız',
    starsSemanticsPerfect: 'Harika',
  );

  static const RatingStrings _en = RatingStrings(
    perfect: 'PERFECT',
    newBest: 'NEW BEST',
    best: 'BEST',
    you: 'YOU',
    optimal: 'OPTIMAL',
    firstRecord: 'FIRST',
    betterKept: 'kept',
    nextLevel: 'NEXT LEVEL',
    soon: 'soon',
    ratingUnavailable: 'No rating',
    starsOfThree: '{n} / 3',
    starWord: 'stars',
    starsSemanticsPerfect: 'Perfect',
  );

  /// Resolve by language key; falls back to Turkish (the launch language).
  static RatingStrings of(String lang) => switch (lang) {
    'en' => _en,
    _ => _tr,
  };
}
