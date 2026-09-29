/// Strings of the app shell: the store-error screen (F08 `StoreErrorScreen`,
/// restyled in F05 D3 — F05 `ui-design.md` §12, architecture §18.3 (7)).
/// Interim copy (PO / localization, F10-UI-LOCALIZATION); Turkish casing is
/// authored — never `toUpperCase`.
class ShellStrings {
  const ShellStrings({
    required this.storeErrorLabel,
    required this.storeErrorHeadline,
    required this.storeErrorBody,
    required this.retry,
    required this.debugDetailsLabel,
  });

  /// The card's caps label. TR: "KAYITLI VERİLER".
  final String storeErrorLabel;

  /// Two authored lines. TR: "Kayıtlı verilerin⏎açılamadı."
  final String storeErrorHeadline;

  /// Reassurance first — restates F08 AC9 (data intact), promises nothing more.
  final String storeErrorBody;

  /// The one action. TR: "Tekrar dene".
  final String retry;

  /// The debug-only details box label. TR: "DEBUG · YALNIZ GELİŞTİRME DERLEMESİ".
  final String debugDetailsLabel;

  static const ShellStrings _tr = ShellStrings(
    storeErrorLabel: 'KAYITLI VERİLER',
    storeErrorHeadline: 'Kayıtlı verilerin\naçılamadı.',
    storeErrorBody: 'İlerlemen güvende; hiçbir şey silinmedi.',
    retry: 'Tekrar dene',
    debugDetailsLabel: 'DEBUG · YALNIZ GELİŞTİRME DERLEMESİ',
  );

  static const ShellStrings _en = ShellStrings(
    storeErrorLabel: 'SAVED DATA',
    storeErrorHeadline: 'Couldn’t open\nyour saved data.',
    storeErrorBody: 'Your progress is safe; nothing was deleted.',
    retry: 'Try again',
    debugDetailsLabel: 'DEBUG · DEVELOPMENT BUILD ONLY',
  );

  static ShellStrings of(String lang) => switch (lang) {
    'en' => _en,
    _ => _tr,
  };
}
