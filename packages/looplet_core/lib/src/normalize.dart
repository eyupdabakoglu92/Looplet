import 'turkish_case.dart';

/// Lowercase Turkish alphabet plus the circumflex vowels. Circumflex forms are
/// kept as distinct letters (never folded to the bare vowel) per
/// `ai-system/features/f01-dictionary-service/architecture.md`.
const String _turkishLowerLetters = 'abcçdefgğhıijklmnoöprsştuüvyzâîû';

final Set<int> _turkishLowerRunes = _turkishLowerLetters.runes.toSet();

/// Normalizes [input] for Turkish dictionary lookup.
///
/// Trims, applies [TurkishCase.toLowerTr], and returns the result **only if**
/// every character is a Turkish letter (the 29-letter alphabet plus `â î û`).
/// Returns `null` — never an empty string, never throwing — when [input] is
/// blank or contains any non-letter (space, hyphen, digit, punctuation, or a
/// letter outside the Turkish set such as `q w x` or accented Latin).
///
/// `İ` and `I` normalize to `i` and `ı`: different keys, never merged.
String? normalizeTurkish(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  final lowered = TurkishCase.toLowerTr(trimmed);
  for (final rune in lowered.runes) {
    if (!_turkishLowerRunes.contains(rune)) return null;
  }
  return lowered;
}

/// Normalizes [input] for plain-Latin (e.g. English) dictionary lookup.
///
/// Trims, lower-cases with ordinary Unicode rules (no Turkish map), and returns
/// the result only if every character is ASCII `a`–`z`. Returns `null`
/// otherwise. Used for the `en` language where Turkish casing must not apply.
String? normalizeLatin(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  final lowered = trimmed.toLowerCase();
  for (final unit in lowered.codeUnits) {
    if (unit < 0x61 || unit > 0x7A) return null;
  }
  return lowered;
}
