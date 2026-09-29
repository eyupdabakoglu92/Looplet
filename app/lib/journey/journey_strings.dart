/// Externalized strings for the F05 Journey home surface + the column
/// micro-tutorial. Same interim per-language pattern as F03's `PlayStrings` /
/// F04's `RatingStrings` — `gen_l10n` stays `[DEFERRED — F10-or-earlier]`.
/// Final TR copy is owned by PO / localization (F10-UI-LOCALIZATION); the D3
/// home copy is interim (F05 `ui-design.md` §12, architecture §18.3 (4),
/// §18.7 ruling 3). Turkish casing is authored — never `toUpperCase`.
class JourneyStrings {
  const JourneyStrings({
    required this.continueLabel,
    required this.replayLabel,
    required this.levelWord,
    required this.inProgressWord,
    required this.journeyWord,
    required this.headlineFirst,
    required this.headlineNext,
    required this.headlineReplay,
    required this.headlineComplete,
    required this.columnTutorialHint,
    required this.levelsWord,
    required this.completeWord,
  });

  /// Home CTA whenever there is a level to continue. TR: "Devam et".
  final String continueLabel;

  /// Home CTA in the terminal state (all 30 done, no session). TR: "Tekrar oyna".
  final String replayLabel;

  /// The caption noun under the CTA. TR: "Seviye".
  final String levelWord;

  /// The in-progress word of the caption and the CTA semantics. TR: "sürüyor".
  final String inProgressWord;

  /// The card label's noun, authored in caps. TR: "YOLCULUK".
  final String journeyWord;

  /// The card headline per situation (C1, architecture §18.7): one lime word.
  final JourneyHeadlineText headlineFirst;
  final JourneyHeadlineText headlineNext;
  final JourneyHeadlineText headlineReplay;
  final JourneyHeadlineText headlineComplete;

  /// The one line of the column micro-tutorial overlay.
  final String columnTutorialHint;

  /// For the progress `Semantics` label. TR: "seviye".
  final String levelsWord;

  /// For the progress `Semantics` label. TR: "tamamlandı".
  final String completeWord;

  /// `YOLCULUK · 12 / 30`.
  String journeyLabel(int done) => '$journeyWord · $done / 30';

  /// `Seviye 12` / `Seviye 12 · sürüyor`, with no-break joins so the caption
  /// can only break before "·" (ui-design §11 Must, §12).
  String levelCaption(int n, {bool inProgress = false}) =>
      '$levelWord $n${inProgress ? ' · $inProgressWord' : ''}';

  /// `12 / 30 seviye tamamlandı — Seviye 13`.
  String progressSemantics(int done, int? current) {
    final base = '$done / 30 $levelsWord $completeWord';
    return current == null ? base : '$base — $levelWord $current';
  }

  /// The CTA's announcement: `Devam et, Seviye 12, sürüyor` (§12 Semantics).
  String ctaSemantics(String label, int level, {bool inProgress = false}) =>
      '$label, $levelWord $level${inProgress ? ', $inProgressWord' : ''}';

  static const JourneyStrings _tr = JourneyStrings(
    continueLabel: 'Devam et',
    replayLabel: 'Tekrar oyna',
    levelWord: 'Seviye',
    inProgressWord: 'sürüyor',
    journeyWord: 'YOLCULUK',
    headlineFirst: JourneyHeadlineText('İlk\n', 'döngüyü', ' çöz.'),
    headlineNext: JourneyHeadlineText('Sıradaki\n', 'döngüyü', ' çöz.'),
    headlineReplay: JourneyHeadlineText('Yarım kalan\n', 'döngüne', ' dön.'),
    headlineComplete: JourneyHeadlineText('Tüm ', 'döngüler', '\ntamam.'),
    columnTutorialHint: 'Sütunları da kaydırabilirsin — yukarı ya da aşağı.',
    levelsWord: 'seviye',
    completeWord: 'tamamlandı',
  );

  static const JourneyStrings _en = JourneyStrings(
    continueLabel: 'Continue',
    replayLabel: 'Play again',
    levelWord: 'Level',
    inProgressWord: 'in progress',
    journeyWord: 'JOURNEY',
    headlineFirst: JourneyHeadlineText('Solve your\nfirst ', 'loop', '.'),
    headlineNext: JourneyHeadlineText('Solve the\nnext ', 'loop', '.'),
    headlineReplay: JourneyHeadlineText('Back to your\nopen ', 'loop', '.'),
    headlineComplete: JourneyHeadlineText('Every ', 'loop', '\ncomplete.'),
    columnTutorialHint: 'You can slide columns too — up or down.',
    levelsWord: 'levels',
    completeWord: 'complete',
  );

  static JourneyStrings of(String lang) => switch (lang) {
    'en' => _en,
    _ => _tr,
  };
}

/// A two-line authored headline with one lime emphasis word:
/// `before` + `emphasis` (lime) + `after`; the line break is part of the text.
class JourneyHeadlineText {
  const JourneyHeadlineText(this.before, this.emphasis, this.after);

  final String before;
  final String emphasis;
  final String after;

  /// The plain text (for tests and logs).
  String get plain => '$before$emphasis$after';
}
