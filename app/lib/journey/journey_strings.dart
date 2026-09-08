/// Externalized strings for the F05 Journey home surface + the column
/// micro-tutorial (`ui-design.md §13`). Same interim per-language pattern as
/// F03's `PlayStrings` / F04's `RatingStrings` — `gen_l10n` stays
/// `[DEFERRED — F10-or-earlier]`. Final TR copy is owned by PO / localization.
class JourneyStrings {
  const JourneyStrings({
    required this.continueLabel,
    required this.replayLabel,
    required this.levelWord,
    required this.inProgressSuffix,
    required this.progressUnit,
    required this.allCompleteKicker,
    required this.columnTutorialHint,
    required this.levelsWord,
    required this.completeWord,
  });

  /// Home primary CTA, normal state. TR: "DEVAM ET".
  final String continueLabel;

  /// Home primary CTA in the "all 30 complete" terminal state. TR: "TEKRAR OYNA".
  final String replayLabel;

  /// The caption noun under CONTINUE. TR: "Seviye".
  final String levelWord;

  /// Appended to the caption for a resumable level. TR: " · sürüyor".
  final String inProgressSuffix;

  /// Micro-label at the ring's centre. TR: "SEVİYE".
  final String progressUnit;

  /// Kicker shown in the terminal state. TR: "TAMAMLANDI".
  final String allCompleteKicker;

  /// The one line of the column micro-tutorial overlay.
  final String columnTutorialHint;

  /// For the ring's `Semantics` label. TR: "seviye".
  final String levelsWord;

  /// For the ring's `Semantics` label. TR: "tamamlandı".
  final String completeWord;

  /// `Seviye 12` / `Seviye 12 · sürüyor`.
  String levelCaption(int n, {bool inProgress = false}) =>
      '$levelWord $n${inProgress ? inProgressSuffix : ''}';

  /// `12 / 30 seviye tamamlandı — Seviye 13`.
  String progressSemantics(int done, int? current) {
    final base = '$done / 30 $levelsWord $completeWord';
    return current == null ? base : '$base — $levelWord $current';
  }

  static const JourneyStrings _tr = JourneyStrings(
    continueLabel: 'DEVAM ET',
    replayLabel: 'TEKRAR OYNA',
    levelWord: 'Seviye',
    inProgressSuffix: ' · sürüyor',
    progressUnit: 'SEVİYE',
    allCompleteKicker: 'TAMAMLANDI',
    columnTutorialHint: 'Sütunları da kaydırabilirsin — yukarı ya da aşağı.',
    levelsWord: 'seviye',
    completeWord: 'tamamlandı',
  );

  static const JourneyStrings _en = JourneyStrings(
    continueLabel: 'CONTINUE',
    replayLabel: 'REPLAY',
    levelWord: 'Level',
    inProgressSuffix: ' · in progress',
    progressUnit: 'LEVEL',
    allCompleteKicker: 'COMPLETE',
    columnTutorialHint: 'You can slide columns too — up or down.',
    levelsWord: 'levels',
    completeWord: 'complete',
  );

  static JourneyStrings of(String lang) => switch (lang) {
    'en' => _en,
    _ => _tr,
  };
}
