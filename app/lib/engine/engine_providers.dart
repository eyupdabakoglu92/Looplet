import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looplet_engine/looplet_engine.dart';

import '../dictionary/dictionary_providers.dart';
import 'dictionary_word_validator.dart';

/// A [WordValidator] backed by the loaded dictionary service. Resolves once the
/// dictionary is ready; used by the engine for frozen-tile thaw checks.
final wordValidatorProvider = FutureProvider<WordValidator>((ref) async {
  final dictionary = await ref.watch(dictionaryServiceProvider.future);
  return DictionaryWordValidator(dictionary);
});
