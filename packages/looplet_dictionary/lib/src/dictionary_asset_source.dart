/// Supplies the raw text of a dictionary asset.
///
/// The Flutter app provides a `rootBundle`-backed implementation; tests provide
/// fakes. Implementations may throw anything (an [Error] or an [Exception]) when
/// the asset is absent — `DictionaryService.load` treats any throw as
/// "asset missing" and falls back to a fail-safe service.
abstract interface class DictionaryAssetSource {
  /// Returns the UTF-8 text of the asset at [path] (a bundle key such as
  /// `packages/looplet_dictionary/assets/tr/dictionary.json`).
  Future<String> readAsset(String path);
}
