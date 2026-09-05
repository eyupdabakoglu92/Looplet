import 'package:looplet_core/looplet_core.dart';
import 'package:test/test.dart';

void main() {
  group('GridCoord', () {
    test('value equality and hashCode', () {
      expect(const GridCoord(1, 2), const GridCoord(1, 2));
      expect(const GridCoord(1, 2).hashCode, const GridCoord(1, 2).hashCode);
      expect(const GridCoord(1, 2) == const GridCoord(2, 1), isFalse);
    });

    test('compareTo orders row-major', () {
      final coords = <GridCoord>[
        const GridCoord(2, 0),
        const GridCoord(0, 4),
        const GridCoord(0, 1),
        const GridCoord(1, 3),
      ]..sort();
      expect(coords, <GridCoord>[
        const GridCoord(0, 1),
        const GridCoord(0, 4),
        const GridCoord(1, 3),
        const GridCoord(2, 0),
      ]);
    });

    test('works as a Set key (dedupes equal coordinates)', () {
      final input = <GridCoord>[
        const GridCoord(0, 0),
        GridCoord(0, 0 + 0), // same value, distinct instance
        const GridCoord(1, 2),
      ];
      final s = input.toSet();
      expect(s, hasLength(2));
      expect(s.contains(const GridCoord(0, 0)), isTrue);
    });
  });

  test('enums expose the expected values', () {
    expect(MoveAxis.values, <MoveAxis>[MoveAxis.row, MoveAxis.column]);
    expect(MoveDirection.values, <MoveDirection>[
      MoveDirection.left,
      MoveDirection.right,
      MoveDirection.up,
      MoveDirection.down,
    ]);
    expect(TileStatus.values, <TileStatus>[
      TileStatus.normal,
      TileStatus.locked,
      TileStatus.frozen,
      TileStatus.thawed,
    ]);
  });
}
