// F05-FE-D3 — the Home of Design Adoption Phase D3 (F05 `ui-design.md` §4–§12,
// architecture §18.3 / §18.7): the Loop Glass composition — the `Looplet`
// wordmark, the Journey card (label, headline, loop track), one lime CTA and
// its caption. Covers every §8 state, the C1 copy rule, the N1 CONTINUE rule
// warm and cold, the loading frame, the C3 entrance, the §11.1 (1) anchors,
// text scale up to AX5 and the C2 debug row.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:looplet_app/design/design.dart';
import 'package:looplet_app/home_screen.dart';
import 'package:looplet_app/persistence/active_session_snapshot.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/persistence/repositories/active_session_repo.dart';
import 'package:looplet_app/persistence/repositories/journey_progress_repo.dart';
import 'package:looplet_app/persistence/repositories/player_repo.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/shell/shell_wordmark.dart';

import '../play/play_test_support.dart' show loadAppFonts;
import '../support/widget_test_database.dart';

const String nb = ' ';

void main() {
  late AppDatabase db;
  PlaySessionArgs? lastPlayArgs;

  setUpAll(loadAppFonts);

  setUp(() {
    db = widgetTestDatabase();
    lastPlayArgs = null;
    HomeScreen.resetEntranceForTest();
    ShellWordmark.resetFadeForTest();
  });
  tearDown(() => db.close());

  void screen(
    WidgetTester tester, {
    Size size = const Size(393, 852),
    double textScale = 1,
    bool reduced = true,
  }) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    tester.platformDispatcher.accessibilityFeaturesTestValue = reduced
        ? const FakeAccessibilityFeatures(reduceMotion: true)
        : const FakeAccessibilityFeatures();
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  Widget buildApp({bool showDebugRow = false}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (context, state) => HomeScreen(showDebugRow: showDebugRow),
        ),
        GoRoute(
          path: '/play',
          builder: (context, state) {
            lastPlayArgs = state.extra as PlaySessionArgs?;
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('PLAY ROUTE'),
                ),
              ),
            );
          },
        ),
      ],
    );
    return ProviderScope(
      overrides: <Override>[appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  bool hasSemanticsLabel(WidgetTester tester, String label) => tester
      .widgetList<Semantics>(find.byType(Semantics))
      .any((s) => s.properties.label == label);

  Future<void> seedCompleted(int upTo) async {
    final guestId = await PlayerRepo(db).currentGuestId();
    for (var n = 1; n <= upTo; n++) {
      await JourneyProgressRepo(db).markCompleted(guestId, n);
    }
  }

  Future<void> seedSession(int level) => ActiveSessionRepo(db).save(
    ActiveSessionSnapshot(
      puzzleId: 'journey-tr-${level.toString().padLeft(2, '0')}',
      puzzleSource: PuzzleSource.journey,
      lang: 'tr',
      appliedMoves: const <String>['R1'],
      undosRemaining: 3,
      restartCount: 0,
      elapsedMsAccumulated: 4200,
      thawedFrozenCells: const <String>[],
      status: ActiveSessionStatus.inProgress,
      startedAtUtcMs: 1757145000000,
      lastPersistedAtUtcMs: 1757145004200,
    ),
  );

  Finder rich(String text) => find.text(text, findRichText: true);

  /// The line tops of a laid-out paragraph.
  List<double> lineTops(RenderParagraph p, String text) {
    final tops = <double>{
      for (final b in p.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: text.length),
      ))
        b.top.roundToDouble(),
    }.toList()..sort();
    return tops;
  }

  List<(int, LoopNodeState)> nodes(WidgetTester tester) => tester
      .widgetList<LoopNode>(find.byType(LoopNode))
      .map((n) => (n.number, n.state))
      .toList();

  Future<void> tapCta(WidgetTester tester) async {
    await tester.tap(find.byType(LimePill));
    await tester.pumpAndSettle();
    expect(find.text('PLAY ROUTE'), findsOneWidget);
  }

  group('states and copy (ui-design §8, §12; C1)', () {
    testWidgets('new player 0 / 30: "İlk döngüyü çöz.", 1 current, 2–5 '
        'locked, "Devam et" → level 1', (tester) async {
      screen(tester);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('YOLCULUK · 0 / 30'), findsOneWidget);
      expect(rich('İlk\ndöngüyü çöz.'), findsOneWidget);
      expect(find.text('Devam et'), findsOneWidget);
      expect(find.text('Seviye${nb}1'), findsOneWidget);
      expect(nodes(tester), <(int, LoopNodeState)>[
        (1, LoopNodeState.current),
        (2, LoopNodeState.locked),
        (3, LoopNodeState.locked),
        (4, LoopNodeState.locked),
        (5, LoopNodeState.locked),
      ]);
      expect(
        hasSemanticsLabel(tester, '0 / 30 seviye tamamlandı — Seviye 1'),
        isTrue,
      );
      expect(hasSemanticsLabel(tester, 'Devam et, Seviye 1'), isTrue);

      await tapCta(tester);
      expect(lastPlayArgs?.source, PuzzleSource.journey);
      expect(lastPlayArgs?.journeyLevel, 1);
    });

    testWidgets('level 1 started at 0 / 30 → "Sıradaki…" and "· sürüyor" '
        '(C1: the headline changes, not only the caption)', (tester) async {
      screen(tester);
      await seedSession(1);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(rich('Sıradaki\ndöngüyü çöz.'), findsOneWidget);
      expect(find.text('Seviye${nb}1 ·${nb}sürüyor'), findsOneWidget);
      expect(hasSemanticsLabel(tester, 'Devam et, Seviye 1, sürüyor'), isTrue);
    });

    testWidgets('mid 4 / 30: 1–4 done, 5 current, "Seviye 5" → level 5', (
      tester,
    ) async {
      screen(tester);
      await seedCompleted(4);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('YOLCULUK · 4 / 30'), findsOneWidget);
      expect(rich('Sıradaki\ndöngüyü çöz.'), findsOneWidget);
      expect(find.text('Seviye${nb}5'), findsOneWidget);
      expect(nodes(tester).map((n) => n.$2).toList(), <LoopNodeState>[
        LoopNodeState.done,
        LoopNodeState.done,
        LoopNodeState.done,
        LoopNodeState.done,
        LoopNodeState.current,
      ]);
      await tapCta(tester);
      expect(lastPlayArgs?.journeyLevel, 5);
    });

    testWidgets('replay before 30 / 30 (12 done, replaying 7): "Yarım kalan '
        'döngüne dön.", window 5–9 with 7 current', (tester) async {
      screen(tester);
      await seedCompleted(12);
      await seedSession(7);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(rich('Yarım kalan\ndöngüne dön.'), findsOneWidget);
      expect(find.text('Seviye${nb}7 ·${nb}sürüyor'), findsOneWidget);
      expect(nodes(tester), <(int, LoopNodeState)>[
        (5, LoopNodeState.done),
        (6, LoopNodeState.done),
        (7, LoopNodeState.current),
        (8, LoopNodeState.done),
        (9, LoopNodeState.done),
      ]);
      await tapCta(tester);
      expect(lastPlayArgs?.journeyLevel, 7);
    });

    testWidgets('terminal 30 / 30 without a session: "Tüm döngüler tamam.", '
        '26–29 done + 30 finish, "Tekrar oyna" → level 1', (tester) async {
      screen(tester);
      await seedCompleted(30);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('YOLCULUK · 30 / 30'), findsOneWidget);
      expect(rich('Tüm döngüler\ntamam.'), findsOneWidget);
      expect(find.text('Tekrar oyna'), findsOneWidget);
      expect(find.text('Devam et'), findsNothing);
      expect(find.text('Seviye${nb}1'), findsOneWidget);
      expect(nodes(tester).last, (30, LoopNodeState.finish));
      expect(
        nodes(tester).where((n) => n.$2 == LoopNodeState.current),
        isEmpty,
      );
      expect(hasSemanticsLabel(tester, '30 / 30 seviye tamamlandı'), isTrue);
      expect(hasSemanticsLabel(tester, 'Tekrar oyna, Seviye 1'), isTrue);

      await tapCta(tester);
      expect(lastPlayArgs?.journeyLevel, 1);
    });
  });

  group('N1 — 30 / 30 with a replay in progress (§18.3 (2))', () {
    Future<void> expectN1Home(WidgetTester tester) async {
      expect(find.text('YOLCULUK · 30 / 30'), findsOneWidget);
      expect(rich('Tüm döngüler\ntamam.'), findsOneWidget);
      expect(find.text('Devam et'), findsOneWidget);
      expect(find.text('Tekrar oyna'), findsNothing);
      expect(find.text('Seviye${nb}12 ·${nb}sürüyor'), findsOneWidget);
      expect(nodes(tester), <(int, LoopNodeState)>[
        (10, LoopNodeState.done),
        (11, LoopNodeState.done),
        (12, LoopNodeState.current),
        (13, LoopNodeState.done),
        (14, LoopNodeState.done),
      ]);
      expect(
        hasSemanticsLabel(tester, '30 / 30 seviye tamamlandı — Seviye 12'),
        isTrue,
      );
      expect(hasSemanticsLabel(tester, 'Devam et, Seviye 12, sürüyor'), isTrue);
    }

    testWidgets('warm: the replay starts while Home is mounted → CONTINUE '
        'resumes it; the card still says complete', (tester) async {
      screen(tester);
      await seedCompleted(30);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Tekrar oyna'), findsOneWidget);

      await seedSession(12);
      await tester.pumpAndSettle();
      await expectN1Home(tester);
      await tapCta(tester);
      expect(lastPlayArgs?.journeyLevel, 12);
    });

    testWidgets('cold: a relaunch with the replay saved shows the same Home', (
      tester,
    ) async {
      screen(tester);
      await seedCompleted(30);
      await seedSession(12);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await expectN1Home(tester);

      // Relaunch: a fresh ProviderScope over the same store.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await expectN1Home(tester);
      await tapCta(tester);
      expect(lastPlayArgs?.journeyLevel, 12);
    });

    testWidgets('the replay cleared → back to the terminal state', (
      tester,
    ) async {
      screen(tester);
      await seedCompleted(30);
      await seedSession(12);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await ActiveSessionRepo(db).clear();
      await tester.pumpAndSettle();
      expect(find.text('Tekrar oyna'), findsOneWidget);
      expect(find.text('Seviye${nb}1'), findsOneWidget);
    });
  });

  group('loading, entrance and motion (ui-design §4 / §5; C3)', () {
    testWidgets('before the model loads Home is the splash frame: the '
        'wordmark only — no card, no CTA, no spinner', (tester) async {
      screen(tester);
      await tester.pumpWidget(buildApp());
      expect(find.byType(LoopletWordmark), findsOneWidget);
      expect(find.byType(GlassCard), findsNothing);
      expect(find.byType(LimePill), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pumpAndSettle();
      expect(find.byType(GlassCard), findsOneWidget);
    });

    int fadingLayers(WidgetTester tester) => tester
        .widgetList<Opacity>(
          find.descendant(
            of: find.byType(HomeScreen),
            matching: find.byType(Opacity),
          ),
        )
        .where((o) => o.opacity < 1)
        .length;

    Future<void> untilModel(WidgetTester tester) async {
      for (
        var i = 0;
        i < 50 && find.byType(GlassCard).evaluate().isEmpty;
        i++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)),
        );
        await tester.pump();
      }
      expect(find.byType(GlassCard), findsOneWidget);
    }

    testWidgets('the entrance plays once at the first model frame, is at rest '
        'by 340 ms, and nothing moves afterwards', (tester) async {
      screen(tester, reduced: false);
      await seedCompleted(4);
      await tester.pumpWidget(buildApp());
      await untilModel(tester);

      expect(fadingLayers(tester), greaterThan(0)); // entering
      await tester.pump(const Duration(milliseconds: 200));
      expect(fadingLayers(tester), greaterThan(0)); // caption still entering
      await tester.pump(const Duration(milliseconds: 160));
      expect(fadingLayers(tester), 0); // at rest (340 ms + a frame)
      await tester.pump(const Duration(seconds: 5));
      expect(tester.hasRunningAnimations, isFalse); // no idle motion
    });

    testWidgets('no entrance on the return from /play, nor on a remount in '
        'the same process', (tester) async {
      screen(tester, reduced: false);
      await seedCompleted(4);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tapCta(tester);
      await tester.tap(find.text('PLAY ROUTE'));
      await tester.pump();
      expect(fadingLayers(tester), 0);
      await tester.pumpAndSettle();
      expect(fadingLayers(tester), 0);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(buildApp());
      await untilModel(tester);
      expect(fadingLayers(tester), 0);
    });

    testWidgets('Reduce Motion switched on after the first frame stops the '
        'wordmark fade and the entrance at once', (tester) async {
      screen(tester, reduced: false);
      await seedCompleted(4);
      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 16));
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(reduceMotion: true);
      await tester.pump();
      expect(ShellWordmark.fadeProgress, 1);
      await untilModel(tester);
      expect(fadingLayers(tester), 0);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('reduced motion: the content appears at once', (tester) async {
      screen(tester);
      await seedCompleted(4);
      await tester.pumpWidget(buildApp());
      await untilModel(tester);
      expect(fadingLayers(tester), 0);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('layout (§11.1 (1), (11), (12))', () {
    testWidgets('anchors at 1.0× on 393 × 852: wordmark (25, 58)·s, card '
        'top 132.8 and 300·s tall, CTA top 486.3, caption 17·s below', (
      tester,
    ) async {
      screen(tester);
      await seedCompleted(4);
      await seedSession(5);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      const s = 393 / 358;
      const e = 852 - 717 * s;
      final wordmark = tester.getTopLeft(find.byType(LoopletWordmark));
      expect(wordmark.dx, closeTo(25 * s, 2));
      expect(wordmark.dy, closeTo(58 * s, 2));
      final card = tester.getRect(find.byType(GlassCard));
      expect(card.top, closeTo(115 * s + 0.1 * e, 2)); // 132.8
      expect(card.left, closeTo(24.5 * s, 2));
      expect(card.height, closeTo(300 * s, 2));
      final cta = tester.getRect(find.byType(LimePill));
      expect(cta.top, closeTo(486.3, 2));
      expect(cta.width, closeTo(309 * s, 1));
      expect(cta.height, greaterThanOrEqualTo(44));
      final caption = tester.getRect(find.text('Seviye${nb}5 ·${nb}sürüyor'));
      expect(caption.top, closeTo(cta.bottom + 17 * s, 2));
    });

    for (final size in const <Size>[
      Size(390, 844),
      Size(393, 852),
      Size(440, 956),
    ]) {
      for (final scale in const <double>[1.3, 3.118]) {
        testWidgets('${size.width.toInt()} pt at ${scale}x: no scroll, no '
            'overflow, container text capped, words unbroken', (tester) async {
          screen(tester, size: size, textScale: scale);
          await seedCompleted(12);
          await seedSession(13);
          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          final scroll = tester
              .state<ScrollableState>(
                find.descendant(
                  of: find.byType(HomeScreen),
                  matching: find.byType(Scrollable),
                ),
              )
              .position;
          expect(scroll.maxScrollExtent, 0, reason: 'Home must not scroll');

          // Container text at the 1.3× cap.
          final label = tester.widget<Text>(find.text('YOLCULUK · 12 / 30'));
          final ctx = tester.element(find.text('YOLCULUK · 12 / 30'));
          final capped = label.textScaler ?? MediaQuery.textScalerOf(ctx);
          expect(capped.scale(10) / 10, closeTo(scale.clamp(1, 1.3), 1e-6));

          // The headline keeps its two authored lines; the caption breaks at
          // most once, before "·"; the CTA label stays on one line.
          const head = 'Sıradaki\ndöngüyü çöz.';
          expect(
            lineTops(tester.renderObject<RenderParagraph>(rich(head)), head),
            hasLength(2),
          );
          const cap = 'Seviye${nb}13 ·${nb}sürüyor';
          final capPara = tester.renderObject<RenderParagraph>(find.text(cap));
          final capLines = lineTops(capPara, cap);
          expect(capLines.length, lessThanOrEqualTo(2));
          if (capLines.length == 2) {
            final second = capPara
                .getPositionForOffset(Offset(1, capLines[1] + 2))
                .offset;
            expect(cap.substring(second), '·${nb}sürüyor');
          }
          expect(
            lineTops(
              tester.renderObject<RenderParagraph>(find.text('Devam et')),
              'Devam et',
            ),
            hasLength(1),
          );
          expect(tester.getSize(find.byType(LimePill)).height, greaterThan(44));

          // Nothing below the screen edge.
          expect(
            tester.getRect(find.text('Seviye${nb}13 ·${nb}sürüyor')).bottom,
            lessThanOrEqualTo(size.height),
          );
        });
      }
    }
  });

  group('the debug row (C2)', () {
    // The nearest Offstage above the row's label (the Navigator has its own).
    bool rowShown(WidgetTester tester) => !tester
        .widget<Offstage>(
          find
              .ancestor(
                of: find.text('debug', skipOffstage: false),
                matching: find.byType(Offstage, skipOffstage: false),
              )
              .first,
        )
        .offstage;

    testWidgets('1.0×: shown at the bottom, clear of the caption; the anchors '
        'do not move', (tester) async {
      screen(tester);
      await seedCompleted(4);
      await tester.pumpWidget(buildApp(showDebugRow: true));
      await tester.pumpAndSettle();
      expect(rowShown(tester), isTrue);
      final caption = tester.getRect(find.text('Seviye${nb}5'));
      final row = tester.getRect(find.byType(Wrap));
      expect(row.top, greaterThan(caption.bottom));
      expect(tester.getRect(find.byType(LimePill)).top, closeTo(486.3, 2));
    });

    testWidgets('a live OS text-size change 1.0× → AX5 while mounted hides '
        'it; back to 1.0× shows it again', (tester) async {
      screen(tester, size: const Size(390, 844));
      await seedCompleted(12);
      await seedSession(13);
      await tester.pumpWidget(buildApp(showDebugRow: true));
      await tester.pumpAndSettle();
      expect(rowShown(tester), isTrue);

      tester.platformDispatcher.textScaleFactorTestValue = 3.118;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(rowShown(tester), isFalse);

      tester.platformDispatcher.textScaleFactorTestValue = 1;
      await tester.pumpAndSettle();
      expect(rowShown(tester), isTrue);
    });

    testWidgets('AX5 on 390 × 844: omitted, and no overflow', (tester) async {
      screen(tester, size: const Size(390, 844), textScale: 3.118);
      await seedCompleted(4);
      await tester.pumpWidget(buildApp(showDebugRow: true));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(rowShown(tester), isFalse);
    });
  });

  testWidgets('chrome: no back affordance, no Material icon, no future-scope '
      'item on Home (§11.1 (15), (16))', (tester) async {
    screen(tester);
    await seedCompleted(4);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(find.byType(LoopBackButton), findsNothing);
    expect(find.byType(BackButton), findsNothing);
    expect(find.byType(Icon), findsNothing);
    expect(find.byType(LimePill), findsOneWidget); // one action
    expect(find.byType(GlassIconButton), findsNothing); // no settings square
    expect(find.byType(StarRow), findsNothing); // no stars chip
  });
}
