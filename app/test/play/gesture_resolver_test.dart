import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/play/gesture_resolver.dart';
import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';

void main() {
  const resolver = GestureResolver(thresholdLogicalPx: 18, tieBandRatio: 0.15);

  group('threshold (AC4)', () {
    test('below threshold on both axes → no move', () {
      expect(
        resolver.resolve(startRow: 2, startCol: 3, delta: const Offset(10, 8)),
        isNull,
      );
    });

    test('exactly at threshold → a move', () {
      final move = resolver.resolve(
        startRow: 1,
        startCol: 1,
        delta: const Offset(18, 0),
      );
      expect(move, isNotNull);
    });
  });

  group('dominant axis + direction (AC2 / AC3)', () {
    test('horizontal dominant, positive dx → rowRight of the start row', () {
      final move = resolver.resolve(
        startRow: 3,
        startCol: 0,
        delta: const Offset(60, 12),
      );
      expect(move, const Move.rowRight(3));
    });

    test('horizontal dominant, negative dx → rowLeft', () {
      final move = resolver.resolve(
        startRow: 0,
        startCol: 4,
        delta: const Offset(-40, 5),
      );
      expect(move, const Move.rowLeft(0));
    });

    test('vertical dominant, positive dy → columnDown of the start col', () {
      final move = resolver.resolve(
        startRow: 0,
        startCol: 2,
        delta: const Offset(6, 55),
      );
      expect(move, const Move.columnDown(2));
    });

    test('vertical dominant, negative dy → columnUp', () {
      final move = resolver.resolve(
        startRow: 4,
        startCol: 1,
        delta: const Offset(-3, -30),
      );
      expect(move, const Move.columnUp(1));
    });
  });

  group('diagonal tie → favour horizontal (architecture §7)', () {
    test('near-equal axes resolves to a row move', () {
      final move = resolver.resolve(
        startRow: 2,
        startCol: 2,
        delta: const Offset(40, 38),
      );
      expect(move, const Move.rowRight(2));
    });

    test('clearly vertical (outside the tie band) still resolves vertical', () {
      final move = resolver.resolve(
        startRow: 2,
        startCol: 2,
        delta: const Offset(20, 60),
      );
      expect(move, const Move.columnDown(2));
    });
  });

  test('one cell only — a long flick and a short drag map the same', () {
    final short = resolver.resolve(
      startRow: 1,
      startCol: 0,
      delta: const Offset(22, 0),
    );
    final long = resolver.resolve(
      startRow: 1,
      startCol: 0,
      delta: const Offset(600, 0),
    );
    expect(short, const Move.rowRight(1));
    expect(long, const Move.rowRight(1));
  });

  group('trackingAxis (AC9 lift affordance)', () {
    test('null below threshold', () {
      expect(resolver.trackingAxis(const Offset(5, 5)), isNull);
    });

    test('row past threshold', () {
      expect(resolver.trackingAxis(const Offset(30, 4)), MoveAxis.row);
    });

    test('column past threshold', () {
      expect(resolver.trackingAxis(const Offset(4, 30)), MoveAxis.column);
    });
  });
}
