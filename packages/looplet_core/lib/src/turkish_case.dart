/// Turkish-locale case conversion.
///
/// Dart's built-in `String.toLowerCase()` / `toUpperCase()` are wrong for
/// Turkish: `'I'.toLowerCase()` yields `'i'` (should be `'ı'`) and
/// `'İ'.toLowerCase()` yields `'i̇'` (an `i` plus a combining dot). LOOPLET game
/// and dictionary logic must go through this class instead
/// (`project-authority/platform.md` §11, HARD RULE).
///
/// `İ` and `I` are treated as distinct letters: they lower-case to `i` and `ı`
/// respectively, which are different code points and therefore different
/// dictionary keys. Circumflex vowels (`â î û` / `Â Î Û`) are ordinary distinct
/// letters and are never stripped.
abstract final class TurkishCase {
  static const Map<String, String> _toLower = <String, String>{
    'I': 'ı',
    'İ': 'i',
    'Ç': 'ç',
    'Ğ': 'ğ',
    'Ö': 'ö',
    'Ş': 'ş',
    'Ü': 'ü',
  };

  static const Map<String, String> _toUpper = <String, String>{
    'i': 'İ',
    'ı': 'I',
    'ç': 'Ç',
    'ğ': 'Ğ',
    'ö': 'Ö',
    'ş': 'Ş',
    'ü': 'Ü',
  };

  /// Lower-cases [input] using Turkish rules.
  static String toLowerTr(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final ch = String.fromCharCode(rune);
      buffer.write(_toLower[ch] ?? ch.toLowerCase());
    }
    return buffer.toString();
  }

  /// Upper-cases [input] using Turkish rules.
  static String toUpperTr(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final ch = String.fromCharCode(rune);
      buffer.write(_toUpper[ch] ?? ch.toUpperCase());
    }
    return buffer.toString();
  }
}
