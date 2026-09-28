/// Externalized strings for the F04 rating content of the full-screen result
/// (F04 `architecture.md` §7, as amended by F03 architecture §20.4).
///
/// LOOPLET is localization-ready (Turkish primary). There is no `gen_l10n`
/// toolchain yet, so — like F03's `PlayStrings` — F04 keeps its handful of
/// strings in a small per-language table. Final TR copy is owned by
/// PO / localization (F10-UI-LOCALIZATION).
///
/// Phase D2 (F03 architecture §20.3 (5), audit C-4): the `3 / 3` caption, the
/// `İLK` tag, "daha iyi" and `YENİ REKOR` are gone; the badges are `HARİKA`
/// and `YENİ EN İYİ`. Caps strings are authored in upper case.
class RatingStrings {
  const RatingStrings({
    required this.perfect,
    required this.newBest,
    required this.perfectSpoken,
    required this.newBestSpoken,
    required this.best,
    required this.you,
    required this.optimal,
    required this.youSpoken,
    required this.optimalSpoken,
    required this.bestSpoken,
    required this.perfectInline,
    required this.noRating,
    required this.starWord,
  });

  /// Badge iff Perfect (it wins over a new best). TR: "HARİKA".
  final String perfect;

  /// Badge iff a new best that is not Perfect. TR: "YENİ EN İYİ".
  final String newBest;

  /// [perfect] / [newBest] as read by a screen reader. TR: "Harika",
  /// "Yeni en iyi".
  final String perfectSpoken;
  final String newBestSpoken;

  /// Stat labels. TR: "EN İYİ", "SEN", "OPTİMAL".
  final String best;
  final String you;
  final String optimal;

  /// Stat names as read by a screen reader. TR: "Sen", "optimal", "en iyi".
  final String youSpoken;
  final String optimalSpoken;
  final String bestSpoken;

  /// "Perfect" inside the stats sentence (authored, never lower-cased at
  /// runtime). TR: "harika".
  final String perfectInline;

  /// The defensive no-optimal line in the stars slot. TR: "Bu bölüm
  /// puanlanamadı."
  final String noRating;

  /// The word for "stars" in the star group's label. TR: "yıldız".
  final String starWord;

  /// The star group's label: "2 / 3 yıldız", or "3 / 3 yıldız, Harika".
  String starGroupSemantics({required int stars, required bool perfect}) {
    final base = '$stars / 3 $starWord';
    return perfect ? '$base, $perfectSpoken' : base;
  }

  /// The stats card as one node: "Sen 3, optimal 3, en iyi 3", plus
  /// ", harika" when the best is Perfect. `null` values read as "—".
  String statsSemantics({
    required int you,
    required int? optimal,
    required int? best,
    required bool bestIsPerfect,
  }) {
    String v(int? n) => n == null ? '—' : '$n';
    final base =
        '$youSpoken $you, $optimalSpoken ${v(optimal)}, '
        '$bestSpoken ${v(best)}';
    return bestIsPerfect ? '$base, $perfectInline' : base;
  }

  static const RatingStrings _tr = RatingStrings(
    perfect: 'HARİKA',
    newBest: 'YENİ EN İYİ',
    perfectSpoken: 'Harika',
    newBestSpoken: 'Yeni en iyi',
    best: 'EN İYİ',
    you: 'SEN',
    optimal: 'OPTİMAL',
    youSpoken: 'Sen',
    optimalSpoken: 'optimal',
    bestSpoken: 'en iyi',
    perfectInline: 'harika',
    noRating: 'Bu bölüm puanlanamadı.',
    starWord: 'yıldız',
  );

  static const RatingStrings _en = RatingStrings(
    perfect: 'PERFECT',
    newBest: 'NEW BEST',
    perfectSpoken: 'Perfect',
    newBestSpoken: 'New best',
    best: 'BEST',
    you: 'YOU',
    optimal: 'OPTIMAL',
    youSpoken: 'You',
    optimalSpoken: 'optimal',
    bestSpoken: 'best',
    perfectInline: 'perfect',
    noRating: 'This level has no rating.',
    starWord: 'stars',
  );

  /// Resolve by language key; falls back to Turkish (the launch language).
  static RatingStrings of(String lang) => switch (lang) {
    'en' => _en,
    _ => _tr,
  };
}
