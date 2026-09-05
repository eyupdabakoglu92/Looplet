import 'package:looplet_engine/looplet_engine.dart';
import 'package:test/test.dart';

import 'support/helpers.dart';

const _validator = NeverValidWordValidator();

void main() {
  // A grid whose only 5-letter row-equality with the target is unreachable, so
  // shifts never accidentally win.
  EngineConfig plain() => cfg(
        <String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRSTU', 'VYZAB'],
        target: 'QQQQQ'.replaceAll('Q', 'W'), // 'WWWWW' — never formable
      );

  group('row shift', () {
    test('right wraps the last cell to the front', () {
      final engine = GridEngine(plain(), validator: _validator);
      final step = engine.applyMove(const Move.rowRight(0));
      expect(step.applied, isTrue);
      expect(rowOf(engine.state, 0), 'EABCD');
      expect(engine.moveCount, 1);
    });

    test('left wraps the first cell to the back', () {
      final engine = GridEngine(plain(), validator: _validator);
      engine.applyMove(const Move.rowLeft(0));
      expect(rowOf(engine.state, 0), 'BCDEA');
    });

    test('only the targeted row changes', () {
      final engine = GridEngine(plain(), validator: _validator);
      engine.applyMove(const Move.rowRight(2));
      expect(rowOf(engine.state, 0), 'ABCDE');
      expect(rowOf(engine.state, 1), 'FGHIJ');
      expect(rowOf(engine.state, 2), 'OKLMN');
      expect(rowOf(engine.state, 3), 'PRSTU');
    });

    test('five right shifts return to the start (identity)', () {
      final engine = GridEngine(plain(), validator: _validator);
      for (var i = 0; i < 5; i++) {
        engine.applyMove(const Move.rowRight(1));
      }
      expect(rowOf(engine.state, 1), 'FGHIJ');
      expect(engine.moveCount, 5);
    });

    test('left then right is a no-op on the grid', () {
      final engine = GridEngine(plain(), validator: _validator);
      engine
        ..applyMove(const Move.rowLeft(3))
        ..applyMove(const Move.rowRight(3));
      expect(rowOf(engine.state, 3), 'PRSTU');
    });
  });

  group('column shift', () {
    test('down wraps the bottom cell to the top', () {
      final engine = GridEngine(plain(), validator: _validator);
      engine.applyMove(const Move.columnDown(0));
      // column 0 top-to-bottom was A F K P V -> V A F K P
      expect(engine.state.letters.map((r) => r[0]).join(), 'VAFKP');
    });

    test('up wraps the top cell to the bottom', () {
      final engine = GridEngine(plain(), validator: _validator);
      engine.applyMove(const Move.columnUp(4));
      // column 4 was E J O U B -> J O U B E
      expect(engine.state.letters.map((r) => r[4]).join(), 'JOUBE');
    });

    test('rejected when column moves are disabled', () {
      final engine = GridEngine(
        cfg(
          <String>['ABCDE', 'FGHIJ', 'KLMNO', 'PRSTU', 'VYZAB'],
          target: 'WWWWW',
          columns: false,
        ),
        validator: _validator,
      );
      final step = engine.applyMove(const Move.columnDown(0));
      expect(step.applied, isFalse);
      expect(step.rejectedReason, MoveRejectReason.columnMovesDisabled);
      expect(engine.moveCount, 0);
      expect(gridOf(engine.state), 'ABCDE/FGHIJ/KLMNO/PRSTU/VYZAB');
    });
  });

  group('rejections leave state and count untouched', () {
    test('index out of range (high and low)', () {
      final engine = GridEngine(plain(), validator: _validator);
      for (final move in <Move>[
        const Move.rowLeft(5),
        const Move.rowRight(-1),
        const Move.columnUp(99),
      ]) {
        final step = engine.applyMove(move);
        expect(step.applied, isFalse);
        expect(step.rejectedReason, MoveRejectReason.outOfRange);
      }
      expect(engine.moveCount, 0);
      expect(gridOf(engine.state), 'ABCDE/FGHIJ/KLMNO/PRSTU/VYZAB');
    });
  });
}
