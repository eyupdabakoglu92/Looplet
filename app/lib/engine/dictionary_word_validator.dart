import 'package:looplet_dictionary/looplet_dictionary.dart';
import 'package:looplet_engine/looplet_engine.dart';

/// Adapts F01's [DictionaryService] to the engine's [WordValidator] port, so
/// `looplet_engine` never depends on `looplet_dictionary`.
class DictionaryWordValidator implements WordValidator {
  const DictionaryWordValidator(this._dictionary);

  final DictionaryService _dictionary;

  @override
  bool isValidWord(String candidate, {int minLength = 1}) =>
      _dictionary.isValidWord(candidate, minLength: minLength);
}
