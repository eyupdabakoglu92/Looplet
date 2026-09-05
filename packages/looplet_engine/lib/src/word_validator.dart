/// Port for word validation, so `looplet_engine` does not depend on
/// `looplet_dictionary`. The app supplies an adapter over F01's
/// `DictionaryService`; the solver / tools supply their own; tests inject fakes.
///
/// Implementations MUST be pure/deterministic (equal inputs → equal output for
/// the life of the object) — the engine's determinism guarantee depends on it.
abstract interface class WordValidator {
  /// Same contract as `DictionaryService.isValidWord`: `true` iff [candidate]
  /// normalizes to a letters-only word of at least [minLength] letters in the
  /// active language's curated list.
  bool isValidWord(String candidate, {int minLength = 1});
}

/// A [WordValidator] that accepts nothing. Use for puzzles with no frozen tiles.
final class NeverValidWordValidator implements WordValidator {
  const NeverValidWordValidator();

  @override
  bool isValidWord(String candidate, {int minLength = 1}) => false;
}
