import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/rating/star_rating.dart';

void main() {
  group('starsForResult — the AC1–AC4 / AC9 / AC10 table', () {
    test('player == optimal → 3 (Perfect) — AC1', () {
      expect(starsForResult(player: 6, optimal: 6), 3);
      expect(isPerfectResult(player: 6, optimal: 6), isTrue);
      // The smoke set: optimal 1 and optimal 2 both hit Perfect.
      expect(starsForResult(player: 1, optimal: 1), 3);
      expect(starsForResult(player: 2, optimal: 2), 3);
    });

    test('optimal+1 .. optimal+3 inclusive → 2 — AC2 / AC9', () {
      expect(starsForResult(player: 7, optimal: 6), 2);
      expect(starsForResult(player: 8, optimal: 6), 2);
      expect(starsForResult(player: 9, optimal: 6), 2); // AC9 upper boundary
      expect(isPerfectResult(player: 7, optimal: 6), isFalse);
    });

    test('optimal+4 → 1 — AC10 lower boundary', () {
      expect(starsForResult(player: 10, optimal: 6), 1);
    });

    test('arbitrarily far from optimal → still 1, never 0 — AC3 / AC4', () {
      expect(starsForResult(player: 16, optimal: 6), 1);
      expect(starsForResult(player: 106, optimal: 6), 1);
      expect(starsForResult(player: 5, optimal: 1), 1);
    });

    test(
      'defensive player < optimal → 3 (logged), and isPerfect stays == 3',
      () {
        expect(starsForResult(player: 3, optimal: 6), 3);
        expect(isPerfectResult(player: 3, optimal: 6), isTrue);
      },
    );

    test('boundary sweep around optimal = 4', () {
      expect(starsForResult(player: 4, optimal: 4), 3);
      expect(starsForResult(player: 5, optimal: 4), 2);
      expect(starsForResult(player: 6, optimal: 4), 2);
      expect(starsForResult(player: 7, optimal: 4), 2);
      expect(starsForResult(player: 8, optimal: 4), 1);
      expect(starsForResult(player: 9, optimal: 4), 1);
    });
  });
}
