/// Externalized user-facing strings for the play session (F03).
///
/// LOOPLET is localization-ready (Turkish primary, `product-prd.md` §1). There
/// is no `gen_l10n` / `.arb` toolchain in the app yet — wiring one is a
/// separate Tech Lead call — so F03 keeps its handful of strings in a small
/// per-language table with the same "look up by language key" shape the
/// dictionary layer uses. No display string is hard-coded in a widget.
class PlayStrings {
  const PlayStrings({
    required this.targetLabel,
    required this.movesLabel,
    required this.solvedKicker,
    required this.retry,
    required this.close,
    required this.back,
    required this.loadFailed,
    required this.undoTooltip,
    required this.restartTooltip,
    required this.boardSemantics,
  });

  /// Above the target rail. TR: "HEDEF".
  final String targetLabel;

  /// Under the MOVES number. TR: "HAMLE".
  final String movesLabel;

  /// Completion sheet kicker. TR: "ÇÖZÜLDÜ".
  final String solvedKicker;

  /// Completion sheet primary CTA. TR: "Yeniden".
  final String retry;

  /// Completion sheet secondary action. TR: "Kapat".
  final String close;

  /// Back-affordance semantics label. TR: "Geri".
  final String back;

  /// Debug puzzle-entry load error. TR: "Bu bulmaca yüklenemedi".
  final String loadFailed;

  final String undoTooltip; // TR: "Geri al"
  final String restartTooltip; // TR: "Baştan"

  /// Screen-reader description prefix for the board. `{target}` / `{moves}` are
  /// filled by the caller.
  final String boardSemantics;

  static const PlayStrings _tr = PlayStrings(
    targetLabel: 'HEDEF',
    movesLabel: 'HAMLE',
    solvedKicker: 'ÇÖZÜLDÜ',
    retry: 'Yeniden',
    close: 'Kapat',
    back: 'Geri',
    loadFailed: 'Bu bulmaca yüklenemedi',
    undoTooltip: 'Geri al',
    restartTooltip: 'Baştan',
    boardSemantics: 'Bulmaca tahtası',
  );

  static const PlayStrings _en = PlayStrings(
    targetLabel: 'TARGET',
    movesLabel: 'MOVES',
    solvedKicker: 'SOLVED',
    retry: 'Retry',
    close: 'Close',
    back: 'Back',
    loadFailed: 'Couldn’t load this puzzle',
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
