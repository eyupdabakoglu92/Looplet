/// Externalized user-facing strings for the play session (F03).
///
/// LOOPLET is localization-ready (Turkish primary, `product-prd.md` §1). There
/// is no `gen_l10n` / `.arb` toolchain in the app yet — wiring one is a
/// separate Tech Lead call — so F03 keeps its handful of strings in a small
/// per-language table with the same "look up by language key" shape the
/// dictionary layer uses. No display string is hard-coded in a widget.
///
/// The Phase D1 strings (`HEDEF DÖNGÜ`, `SEVİYE NN`, the load-error copy) and
/// the Phase D2 result copy (headline, subtitle, "Sonraki bölüm", "Tekrar
/// oyna", "Yolculuğu tamamla") are interim copy (F03 architecture §19.3 (5),
/// §19.8 (6), §20.3 (10), §20.7 (3)); PO / localization may revise them here
/// (F10-UI-LOCALIZATION). Caps strings are authored in upper case — never
/// produced by a locale-blind `toUpperCase()`.
class PlayStrings {
  const PlayStrings({
    required this.targetLabel,
    required this.targetSemantics,
    required this.levelCaps,
    required this.levelWord,
    required this.movesLabel,
    required this.resultHeadline,
    required this.resultSubtitle,
    required this.resultSubtitleOne,
    required this.numberWords,
    required this.nextLevel,
    required this.playAgain,
    required this.finishJourney,
    required this.soonSuffix,
    required this.answerWord,
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

  /// The result's display headline, with its authored line break (F03
  /// architecture §20.7 (5)). TR: "Döngü\ntamamlandı."
  final String resultHeadline;

  /// The result's data subtitle; `{n}` is the player's move count, spelled
  /// through [numberWords] when it has an entry. TR: "Hedef {n} hamlede
  /// yerine oturdu." (`hamlede` takes no plural after a number).
  final String resultSubtitle;

  /// [resultSubtitle] for exactly one move (TR needs no separate form).
  final String resultSubtitleOne;

  /// Spelled numbers for the subtitle, index = the number (TR: "bir" … "on"
  /// for 1–10; digits above). Empty = digits always.
  final List<String> numberWords;

  /// The result's Next action. TR: "Sonraki bölüm".
  final String nextLevel;

  /// The result's Retry action. TR: "Tekrar oyna".
  final String playAgain;

  /// The Next action on the last Journey level (F05 AC12). TR: "Yolculuğu
  /// tamamla".
  final String finishJourney;

  /// Suffix of a Next action that is not wired (non-Journey). TR: "· yakında".
  final String soonSuffix;

  /// The answer row's screen-reader prefix ("Cevap: BULUT"). TR: "Cevap".
  final String answerWord;

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

  /// The result subtitle for [moves]: "Hedef üç hamlede yerine oturdu."
  String subtitleFor(int moves) {
    final n = moves >= 1 && moves < numberWords.length
        ? numberWords[moves]
        : '$moves';
    return (moves == 1 ? resultSubtitleOne : resultSubtitle).replaceFirst(
      '{n}',
      n,
    );
  }

  /// The headline on one line, for announcements.
  String get resultHeadlineSpoken => resultHeadline.replaceAll('\n', ' ');

  /// The disabled Next link as rendered: "Sonraki bölüm · yakında".
  String get nextLevelSoon => '$nextLevel $soonSuffix';

  /// The disabled Next link as announced: "Sonraki bölüm, yakında".
  String get nextLevelSoonSpoken =>
      '$nextLevel, ${soonSuffix.replaceFirst(RegExp(r'^[·\s]+'), '')}';

  static const PlayStrings _tr = PlayStrings(
    targetLabel: 'HEDEF DÖNGÜ',
    targetSemantics: 'Hedef döngü',
    levelCaps: 'SEVİYE',
    levelWord: 'Seviye',
    movesLabel: 'HAMLE',
    resultHeadline: 'Döngü\ntamamlandı.',
    resultSubtitle: 'Hedef {n} hamlede yerine oturdu.',
    resultSubtitleOne: 'Hedef {n} hamlede yerine oturdu.',
    numberWords: <String>[
      '',
      'bir',
      'iki',
      'üç',
      'dört',
      'beş',
      'altı',
      'yedi',
      'sekiz',
      'dokuz',
      'on',
    ],
    nextLevel: 'Sonraki bölüm',
    playAgain: 'Tekrar oyna',
    finishJourney: 'Yolculuğu tamamla',
    soonSuffix: '· yakında',
    answerWord: 'Cevap',
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
    resultHeadline: 'Loop\ncomplete.',
    resultSubtitle: 'Target set in {n} moves.',
    resultSubtitleOne: 'Target set in {n} move.',
    numberWords: <String>[],
    nextLevel: 'Next level',
    playAgain: 'Play again',
    finishJourney: 'Finish the journey',
    soonSuffix: '· soon',
    answerWord: 'Answer',
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
