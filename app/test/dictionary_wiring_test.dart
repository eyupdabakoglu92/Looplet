import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/dictionary/dictionary_providers.dart';
import 'package:looplet_dictionary/looplet_dictionary.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dictionaryServiceProvider loads the bundled Turkish list', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final service = await container.read(dictionaryServiceProvider.future);

    expect(service.isFailSafe, isFalse);
    expect(service.language, LanguageCode.tr);
    expect(service.isValidWord('masal', minLength: 4), isTrue);
    expect(service.isEligibleTarget('MASAL'), isTrue);
    expect(service.isValidWord('zzzz', minLength: 4), isFalse);
  });
}
