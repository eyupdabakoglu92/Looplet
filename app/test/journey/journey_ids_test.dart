import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/journey/journey_content.dart';
import 'package:looplet_app/journey/journey_nav.dart';

void main() {
  group('journeyLevelId / parseJourneyLevel (architecture.md §4)', () {
    test('id is journey-<lang>-<NN>, zero-padded', () {
      expect(journeyLevelId(1, 'tr'), 'journey-tr-01');
      expect(journeyLevelId(7, 'tr'), 'journey-tr-07');
      expect(journeyLevelId(30, 'en'), 'journey-en-30');
    });

    test('round-trips', () {
      for (var n = 1; n <= 30; n++) {
        expect(parseJourneyLevel(journeyLevelId(n, 'tr')), n);
      }
    });

    test('non-journey ids → null', () {
      expect(parseJourneyLevel('smoke-tr-01'), isNull);
      expect(parseJourneyLevel('journey-tr-1'), isNull); // not zero-padded
      expect(parseJourneyLevel('journey-tr-00'), isNull); // out of 1..30
      expect(parseJourneyLevel('journey-tr-31'), isNull);
      expect(parseJourneyLevel('daily-tr-2026-09-08'), isNull);
      expect(parseJourneyLevel(''), isNull);
    });
  });

  group('nextJourneyLevel (architecture.md §8)', () {
    test('normal advance', () {
      expect(nextJourneyLevel(5, manifestLevelCount: 30), 6);
      expect(nextJourneyLevel(29, manifestLevelCount: 30), 30);
    });

    test('level 30 → terminal (null)', () {
      expect(nextJourneyLevel(30, manifestLevelCount: 30), isNull);
    });

    test('past the last available level → terminal (null)', () {
      // interim manifest has 5 levels
      expect(nextJourneyLevel(5, manifestLevelCount: 5), isNull);
      expect(nextJourneyLevel(4, manifestLevelCount: 5), 5);
    });

    test('out-of-range n → null', () {
      expect(nextJourneyLevel(0, manifestLevelCount: 30), isNull);
    });
  });
}
