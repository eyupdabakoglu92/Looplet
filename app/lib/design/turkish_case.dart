/// Locale-correct Turkish casing for display labels (design-foundation §7
/// "Turkish casing rule"). `String.toUpperCase()` is locale-blind: it maps `i`
/// to `I`, which breaks `HARİKA`, `İLK`, `YENİ EN İYİ`, `OPTİMAL`, `SEVİYE`.
/// Authored uppercase constants stay the preferred source; use these helpers
/// wherever a label is derived from a lowercase string.
String turkishUpper(String input) {
  final b = StringBuffer();
  for (final rune in input.runes) {
    final c = String.fromCharCode(rune);
    switch (c) {
      case 'i':
        b.write('İ');
      case 'ı':
        b.write('I');
      default:
        b.write(c.toUpperCase());
    }
  }
  return b.toString();
}

/// Turkish lowercasing (`I → ı`, `İ → i`); the plain `toLowerCase()` turns
/// `İ` into `i` + a combining dot.
String turkishLower(String input) {
  final b = StringBuffer();
  for (final rune in input.runes) {
    final c = String.fromCharCode(rune);
    switch (c) {
      case 'I':
        b.write('ı');
      case 'İ':
        b.write('i');
      default:
        b.write(c.toLowerCase());
    }
  }
  return b.toString();
}
