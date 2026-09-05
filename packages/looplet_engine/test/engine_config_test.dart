import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:test/test.dart';

import 'support/helpers.dart';

void main() {
  group('EngineConfig validation', () {
    test('accepts a well-formed 5x5 puzzle', () {
      final config = cfg(
        <String>['KAMEL', 'SİRAT', 'DONUK', 'BEYAZ', 'TAŞIT'],
        target: 'MASAL',
        locked: <GridCoord>{const GridCoord(0, 0)},
        frozen: <GridCoord>{const GridCoord(4, 4)},
      );
      expect(config.gridSize, 5);
      expect(config.targetWord, 'MASAL');
    });

    test('rejects a non-square grid', () {
      expect(
        () => EngineConfig(
          initialGrid: <List<String>>[
            <String>['A', 'B', 'C'],
            <String>['D', 'E'],
            <String>['F', 'G', 'H'],
          ],
          targetWord: 'ABC',
        ),
        throwsA(isA<EngineConfigError>()),
      );
    });

    test('rejects an empty grid', () {
      expect(
        () => EngineConfig(initialGrid: <List<String>>[], targetWord: 'A'),
        throwsA(isA<EngineConfigError>()),
      );
    });

    test('rejects a multi-character or empty cell', () {
      expect(
        () => cfg(<String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
                target: 'MASAL')
            .gridSize,
        returnsNormally,
      );
      expect(
        () => EngineConfig(
          initialGrid: <List<String>>[
            <String>['AB', 'C', 'D', 'E', 'F'],
            for (var i = 0; i < 4; i++) <String>['G', 'H', 'I', 'J', 'K'],
          ],
          targetWord: 'MASAL',
        ),
        throwsA(isA<EngineConfigError>()),
      );
      expect(
        () => EngineConfig(
          initialGrid: <List<String>>[
            <String>['', 'C', 'D', 'E', 'F'],
            for (var i = 0; i < 4; i++) <String>['G', 'H', 'I', 'J', 'K'],
          ],
          targetWord: 'MASAL',
        ),
        throwsA(isA<EngineConfigError>()),
      );
    });

    test('rejects a non-letter cell', () {
      expect(
        () => EngineConfig(
          initialGrid: <List<String>>[
            <String>['1', 'C', 'D', 'E', 'F'],
            for (var i = 0; i < 4; i++) <String>['G', 'H', 'I', 'J', 'K'],
          ],
          targetWord: 'MASAL',
        ),
        throwsA(isA<EngineConfigError>()),
      );
    });

    test('rejects a target whose length != grid width', () {
      expect(
        () => cfg(<String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
            target: 'ABCD'),
        throwsA(isA<EngineConfigError>()),
      );
    });

    test('rejects a target with a non-letter', () {
      expect(
        () => cfg(<String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
            target: 'ABC1E'),
        throwsA(isA<EngineConfigError>()),
      );
    });

    test('rejects a coordinate out of range', () {
      expect(
        () => cfg(
          <String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
          target: 'MASAL',
          locked: <GridCoord>{const GridCoord(5, 0)},
        ),
        throwsA(isA<EngineConfigError>()),
      );
      expect(
        () => cfg(
          <String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
          target: 'MASAL',
          frozen: <GridCoord>{const GridCoord(0, -1)},
        ),
        throwsA(isA<EngineConfigError>()),
      );
    });

    test('rejects a cell that is both locked and frozen', () {
      expect(
        () => cfg(
          <String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
          target: 'MASAL',
          locked: <GridCoord>{const GridCoord(1, 1)},
          frozen: <GridCoord>{const GridCoord(1, 1)},
        ),
        throwsA(isA<EngineConfigError>()),
      );
    });

    test('EngineConfigError is an ArgumentError', () {
      expect(EngineConfigError('x'), isA<ArgumentError>());
    });

    test('exposed collections are unmodifiable', () {
      final config = cfg(
        <String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV', 'YZBCD'],
        target: 'MASAL',
        locked: <GridCoord>{const GridCoord(0, 0)},
      );
      expect(
        () => config.lockedCells.add(const GridCoord(1, 1)),
        throwsUnsupportedError,
      );
      expect(
        () => config.initialGrid[0][0] = 'Z',
        throwsUnsupportedError,
      );
    });
  });
}
