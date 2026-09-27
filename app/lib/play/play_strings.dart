/// Externalized user-facing strings for the play session (F03).
///
/// LOOPLET is localization-ready (Turkish primary, `product-prd.md` §1). There
/// is no `gen_l10n` / `.arb` toolchain in the app yet — wiring one is a
/// separate Tech Lead call — so F03 keeps its handful of strings in a small
/// per-language table with the same "look up by language key" shape the
/// dictionary layer uses. No display string is hard-coded in a widget.
///
/// The Phase D1 strings (`HEDEF DÖNGÜ`, `SEVİYE NN`, the load-error copy) are
/// interim copy (F03 architecture §19.3 (5), §19.8 (6)); PO / localization may
/// revise them here (F10-UI-LOCALIZATION). Caps strings are authored in upper
/// case — never produced by a locale-blind `toUpperCase()`.
class PlayStrings {
  const PlayStrings({
    required this.targetLabel,
    required this.targetSemantics,
    required this.levelCaps,
    required this.levelWord,
    required this.movesLabel,
    required this.solvedKicker,
    required this.retry,
    required this.close,
    required this.back,
    required this.loadFailed,
    required this.backHome,
    required this.loading,
    required this.undoTooltip,
    required this.restartTooltip,
    required this.boardSemantics,
  });

  /// Over the target rail. TR: "HEDEF DÖNGÜ".
  final String targetLabel;

  /// The rail's screen-reader name, read as "Hedef döngü: TARİH".
  final String targetSemantics;

  /// Caps level word of the header label (`SEVİYE 07`). TR: "SEVİYE".
  final String levelCaps;

  /// Spoken level word ("Geri, Seviye 26"). TR: "Seviye".
  final String levelWord;

  /// The HAMLE card label. TR: "HAMLE".
  final String movesLabel;

  /// Completion sheet kicker. TR: "ÇÖZÜLDÜ".
  final String solvedKicker;

  /// Completion sheet primary CTA. TR: "Yeniden".
  final String retry;

  /// Completion sheet secondary action. TR: "Kapat".
  final String close;

  /// Back-affordance semantics label. TR: "Geri".
  final String back;

  /// The load-error headline. TR: "Bu bulmaca yüklenemedi."
  final String loadFailed;

  /// The load-error action. TR: "Ana ekrana dön".
  final String backHome;

  /// Announced when loading takes longer than 300 ms. TR: "Yükleniyor".
  final String loading;

  final String undoTooltip; // TR: "Geri al"
  final String restartTooltip; // TR: "Baştan"

  /// Screen-reader description prefix for the board. `{target}` / `{moves}` are
  /// filled by the caller.
  final String boardSemantics;

  /// The header level label, two digits: `SEVİYE 07`, `SEVİYE 26`.
  String levelLabel(int level) =>
      '$levelCaps ${level.toString().padLeft(2, '0')}';

  /// The back control's screen-reader label: "Geri, Seviye 26", or "Geri"
  /// when the session has no level number (debug set, Daily).
  String backSemantics(int? level) =>
      level == null ? back : '$back, $levelWord $level';

  static const PlayStrings _tr = PlayStrings(
    targetLabel: 'HEDEF DÖNGÜ',
    targetSemantics: 'Hedef döngü',
    levelCaps: 'SEVİYE',
    levelWord: 'Seviye',
    movesLabel: 'HAMLE',
    solvedKicker: 'ÇÖZÜLDÜ',
    retry: 'Yeniden',
    close: 'Kapat',
    back: 'Geri',
    loadFailed: 'Bu bulmaca yüklenemedi.',
    backHome: 'Ana ekrana dön',
    loading: 'Yükleniyor',
    undoTooltip: 'Geri al',
    restartTooltip: 'Baştan',
    boardSemantics: 'Bulmaca tahtası',
  );

  static const PlayStrings _en = PlayStrings(
    targetLabel: 'TARGET LOOP',
    targetSemantics: 'Target loop',
    levelCaps: 'LEVEL',
    levelWord: 'Level',
    movesLabel: 'MOVES',
    solvedKicker: 'SOLVED',
    retry: 'Retry',
    close: 'Close',
    back: 'Back',
    loadFailed: 'Couldn’t load this puzzle.',
    backHome: 'Back to home',
    loading: 'Loading',
    undoTooltip: 'Undo',
    restartTooltip: 'Restart',
    boardSemantics: 'Puzzle board',
  );

  /// Resolve by language key; falls back to Turkish (the launch language).
  static PlayStrings of(String lang) => switch (lang) {
    'en' => _en,
    _ => _tr,
  };
}
