/// Languages LOOPLET ships a dictionary for. The string [code] matches the
/// Flutter `gen-l10n` locale keys and the `looplet_content` language keys.
enum LanguageCode {
  tr('tr'),
  en('en');

  const LanguageCode(this.code);

  /// Stable lowercase key, e.g. `'tr'`.
  final String code;

  /// Bundle key for this language's word-list asset. The app must declare
  /// `packages/looplet_dictionary/assets/<code>/` under `flutter/assets`.
  String get assetPath =>
      'packages/looplet_dictionary/assets/$code/dictionary.json';

  /// Resolves a [code] string to a [LanguageCode], or `null` if unknown.
  static LanguageCode? fromCode(String code) {
    for (final value in LanguageCode.values) {
      if (value.code == code) return value;
    }
    return null;
  }
}
