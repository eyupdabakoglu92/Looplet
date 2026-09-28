import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/engine/engine_providers.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/play/play_session_screen.dart';
import 'package:looplet_app/play/widgets/puzzle_board.dart';
import 'package:looplet_app/play/widgets/result_view.dart';
import 'package:looplet_app/play/widgets/travelling_tile.dart';
import 'package:looplet_app/design/design.dart' show StarRow;
import 'package:looplet_app/reduce_motion.dart';
import 'package:looplet_engine/looplet_engine.dart';

/// F03-QA-04: iOS "Reduce Motion" arrives as `AccessibilityFeatures.reduceMotion`
/// (iOS-only); Android "Remove animations" as `disableAnimations`. Every site
/// must honour either. Widget tests can only fake the flags — that the iOS
/// setting really flips `reduceMotion` is proven on the simulator by QA.

/// One entry per OS signal, plus the "no signal" control.
final Map<String, FakeAccessibilityFeatures> kMotionSignals =
    <String, FakeAccessibilityFeatures>{
      'iOS reduceMotion': const FakeAccessibilityFeatures(reduceMotion: true),
      'Android disableAnimations': const FakeAccessibilityFeatures(
        disableAnimations: true,
      ),
      'both': const FakeAccessibilityFeatures(
        reduceMotion: true,
        disableAnimations: true,
      ),
    };

void setFeatures(WidgetTester tester, FakeAccessibilityFeatures features) {
  tester.platformDispatcher.accessibilityFeaturesTestValue = features;
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

void main() {
  group('reduceMotionRequested()', () {
    testWidgets('false with no OS signal', (tester) async {
      setFeatures(tester, const FakeAccessibilityFeatures());
      expect(reduceMotionRequested(), isFalse);
    });

    for (final entry in kMotionSignals.entries) {
      testWidgets('true for ${entry.key}', (tester) async {
        setFeatures(tester, entry.value);
        expect(reduceMotionRequested(), isTrue);
      });
    }
  });

  group('the win sequence and star reveal (play_session_screen.dart)', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    /// Plays smoke-tr-01's 1-move win and stops on T0, the settle frame.
    Future<void> winToT0(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            appDatabaseProvider.overrideWithValue(db),
            wordValidatorProvider.overrideWith(
              (ref) async => const NeverValidWordValidator(),
            ),
          ],
          child: const MaterialApp(
            home: PlaySessionScreen(
              args: PlaySessionArgs(
                source: PuzzleSource.journey,
                debugPuzzleId: 'smoke-tr-01',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final box = tester.getRect(find.byType(PuzzleBoard));
      await tester.dragFrom(
        Offset(box.left + box.width * 0.18, box.top + box.height * 0.12),
        Offset(box.width * 0.6, 0),
      );
      for (var i = 0; i < 400; i++) {
        await tester.pump(const Duration(milliseconds: 4));
        if (find.byType(TravellingTile).evaluate().isNotEmpty) return;
      }
      fail('the session never reached `won`');
    }

    /// Answer tiles still showing their board face under the lime fill.
    int filling(WidgetTester tester) => find
        .descendant(
          of: find.byType(TravellingTile),
          matching: find.byType(Opacity),
        )
        .evaluate()
        .length;

    testWidgets('control — no OS signal: the row fills L→R, the stars pop', (
      tester,
    ) async {
      setFeatures(tester, const FakeAccessibilityFeatures());
      await winToT0(tester);
      await tester.pump(const Duration(milliseconds: 60));
      expect(filling(tester), greaterThan(0)); // mid-fill
      await tester.pump(const Duration(milliseconds: 1000)); // T0 + 1060
      expect(tester.widget<StarRow>(find.byType(StarRow)).revealMs, 120);
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
    });

    for (final entry in kMotionSignals.entries) {
      testWidgets('${entry.key}: the row is lime at T0; rest at 660 with the '
          'stars static', (tester) async {
        setFeatures(tester, entry.value);
        await winToT0(tester);
        expect(filling(tester), 0); // already lime, no fill running
        for (var t = 0; t < 660; t += 20) {
          await tester.pump(const Duration(milliseconds: 20));
        }
        final result = tester.widget<ResultView>(find.byType(ResultView));
        expect(result.interactive, isTrue);
        expect(tester.widget<StarRow>(find.byType(StarRow)).revealMs, isNull);
        expect(tester.hasRunningAnimations, isFalse);
        expect(find.text('HARİKA'), findsOneWidget); // complete, not skipped
      });
    }
  });
}
