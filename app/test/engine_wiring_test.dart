import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/dictionary/dictionary_providers.dart';
import 'package:looplet_app/engine/dictionary_word_validator.dart';
import 'package:looplet_app/engine/engine_providers.dart';
import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DictionaryWordValidator delegates to DictionaryService', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final validator = await container.read(wordValidatorProvider.future);
    expect(validator, isA<WordValidator>());
    // "masal" is in the shipped provisional Turkish list.
    expect(validator.isValidWord('MASAL', minLength: 4), isTrue);
    expect(validator.isValidWord('zzzz', minLength: 4), isFalse);
  });

  test(
    'a GridEngine built with the real validator thaws on a real word',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final dictionary = await container.read(dictionaryServiceProvider.future);
      final validator = DictionaryWordValidator(dictionary);

      final engine = GridEngine(
        EngineConfig(
          initialGrid: <List<String>>[
            'MASAL'.split(''),
            'BCDFG'.split(''),
            'HJKLN'.split(''),
            'PRTUV'.split(''),
            'YZBCD'.split(''),
          ],
          targetWord: 'KALEM',
          frozenCells: <GridCoord>{const GridCoord(0, 2)},
        ),
        validator: validator,
      );

      // Row 0 already spells MASAL -> frozen tile thaws at t = 0.
      expect(engine.state.statusAt(const GridCoord(0, 2)), TileStatus.thawed);
      expect(engine.isSolved, isFalse);
    },
  );
}
