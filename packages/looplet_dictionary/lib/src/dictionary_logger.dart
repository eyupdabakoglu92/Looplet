/// Diagnostic sink for the dictionary service. The app wires this to its logger
/// / Crashlytics non-fatals; tests can record the codes.
///
/// Codes emitted by `DictionaryService`:
/// * `dictionary.asset.missing` (warn) — no asset for the requested language
/// * `dictionary.asset.corrupt` (error) — asset present but not parseable
/// * `dictionary.asset.empty`   (warn) — asset parsed but has no words
abstract interface class DictionaryLogger {
  void warn(String code, {Map<String, Object?> data});

  void error(
    String code, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> data,
  });
}

/// A [DictionaryLogger] that discards everything. Default when no logger is
/// passed to `DictionaryService.load`.
final class NoopDictionaryLogger implements DictionaryLogger {
  const NoopDictionaryLogger();

  @override
  void warn(String code,
      {Map<String, Object?> data = const <String, Object?>{}}) {}

  @override
  void error(
    String code, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> data = const <String, Object?>{},
  }) {}
}
