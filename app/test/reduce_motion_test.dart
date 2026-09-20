import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/engine/engine_providers.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/persistence/repositories/active_session_repo.dart';
import 'package:looplet_app/play/debug_puzzle_library.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/play/play_session_controller.dart';
import 'package:looplet_app/play/play_session_screen.dart';
import 'package:looplet_app/play/widgets/puzzle_board.dart';
import 'package:looplet_app/rating/completion_panel.dart';
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

  group('PuzzleBoard win (puzzle_board.dart)', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    Future<void> winOnBoard(WidgetTester tester) async {
      final c = PlaySessionController(
        puzzle: const DebugPuzzleLibrary().load('smoke-tr-01'),
        source: PuzzleSource.journey,
        validator: const NeverValidWordValidator(),
        activeSessionRepo: ActiveSessionRepo(db),
        clock: () => DateTime.utc(2026, 9, 6, 12),
      );
      addTearDown(c.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Center(child: PuzzleBoard(controller: c, boardSize: 340)),
        ),
      );
      c.beginDrag(startRow: 0, startCol: 0);
      c.updateDrag(const Offset(40, 0));
      expect(c.endDrag(const Offset(40, 0)), DragResolution.shift);
      expect(c.commitShift(), isTrue); // the 1-move win
      await tester.pump();
    }

    /// Width of the board's own amber seam bar (3 pt tall) — the winning
    /// row's full width once drawn.
    double seamWidth(WidgetTester tester) => tester
        .widgetList<Positioned>(find.byType(Positioned))
        .firstWhere((p) => p.height == 3 && p.width != null)
        .width!;

    const fullRow = 5 * ((340 - 2 * 10 - 4 * 8) / 5) + 4 * 8; // 320

    testWidgets('control — no OS signal: the seam is still drawing at 100 ms', (
      tester,
    ) async {
      setFeatures(tester, const FakeAccessibilityFeatures());
      await winOnBoard(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(seamWidth(tester), lessThan(fullRow - 1));
      await tester.pumpAndSettle();
      expect(seamWidth(tester), closeTo(fullRow, 0.5));
    });

    for (final entry in kMotionSignals.entries) {
      testWidgets('${entry.key}: the amber row + seam render static', (
        tester,
      ) async {
        setFeatures(tester, entry.value);
        await winOnBoard(tester);
        await tester.pump(const Duration(milliseconds: 100));
        expect(seamWidth(tester), closeTo(fullRow, 0.5)); // already complete
      });
    }
  });

  group('CompletionPanel reveal (completion_panel.dart)', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    Future<void> winThroughScreenUntilReveal(WidgetTester tester) async {
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
      // Step to the moment the panel is at rest and its reveal starts.
      for (var i = 0; i < 200; i++) {
        await tester.pump(const Duration(milliseconds: 20));
        final panel = find.byType(CompletionPanel);
        if (panel.evaluate().isNotEmpty &&
            tester.widget<CompletionPanel>(panel).startReveal) {
          return;
        }
      }
      fail('the completion panel never started its reveal');
    }

    testWidgets('control — no OS signal: the stars strike in one by one', (
      tester,
    ) async {
      setFeatures(tester, const FakeAccessibilityFeatures());
      await winThroughScreenUntilReveal(tester);
      await tester.pump(const Duration(milliseconds: 40));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
    });

    for (final entry in kMotionSignals.entries) {
      testWidgets('${entry.key}: the reveal is its end state, nothing runs', (
        tester,
      ) async {
        setFeatures(tester, entry.value);
        await winThroughScreenUntilReveal(tester);
        await tester.pump(const Duration(milliseconds: 40));
        expect(tester.hasRunningAnimations, isFalse);
        expect(find.text('HARİKA'), findsOneWidget); // complete, not skipped
      });
    }
  });
}
