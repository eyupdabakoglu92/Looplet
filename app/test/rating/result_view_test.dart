// F03-FE-D2 — the full-screen result (F03 architecture §20.3 (4)–(10), §20.7
// C1; `ui-design.md` §16.6 layout, §16.8 variants, §16.11 strings and
// semantics; §16.11.1 items 8–12, 14–15, 17). Carries the F04 AC1–AC10 panel
// coverage (formerly `completion_panel_test` / `completion_cta_weighting_test`)
// onto the result.
import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:looplet_app/design/design.dart';
import 'package:looplet_app/engine/engine_providers.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/persistence/repositories/active_session_repo.dart';
import 'package:looplet_app/persistence/repositories/personal_best_repo.dart';
import 'package:looplet_app/persistence/repositories/player_repo.dart';
import 'package:looplet_app/play/play_layout.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/play/play_session_controller.dart';
import 'package:looplet_app/play/play_session_providers.dart';
import 'package:looplet_app/play/play_session_screen.dart';
import 'package:looplet_app/play/play_strings.dart';
import 'package:looplet_app/play/widgets/result_view.dart';
import 'package:looplet_app/rating/completion_result.dart';
import 'package:looplet_app/rating/rating_strings.dart';
import 'package:looplet_app/rating/result_model.dart';
import 'package:looplet_app/rating/star_rating.dart';
import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_engine/looplet_engine.dart';

import '../design/text_ink_support.dart';
import '../play/play_test_support.dart';

// --- models --------------------------------------------------------------------

CompletionResult _completion({
  required int player,
  int optimal = 3,
  int? priorBest,
  bool persisted = true,
}) {
  final stars = starsForResult(player: player, optimal: optimal);
  final best = priorBest == null
      ? player
      : (player < priorBest ? player : priorBest);
  return CompletionResult(
    levelId: 'journey-tr-05',
    source: PuzzleSource.journey,
    targetWord: 'BULUT',
    playerMoves: player,
    optimalMoves: optimal,
    stars: stars,
    isPerfect: stars == 3,
    personalBestMoves: persisted ? best : 0,
    bestIsPerfect: persisted && best == optimal,
    bestOutcome: bestOutcomeFor(player: player, priorBest: priorBest),
    ratingPersisted: persisted,
  );
}

ResultModel _model({
  required int player,
  int optimal = 3,
  int? priorBest,
  bool resolved = true,
  bool persisted = true,
  ResultNext next = ResultNext.next,
}) => ResultModel.from(
  completion: _completion(
    player: player,
    optimal: optimal,
    priorBest: priorBest,
    persisted: persisted,
  ),
  ratingResolved: resolved,
  targetWord: 'BULUT',
  moveCount: player,
  next: next,
);

final ResultModel _unrated = ResultModel.from(
  completion: null,
  ratingResolved: true,
  targetWord: 'BULUT',
  moveCount: 3,
  next: ResultNext.none,
);

// --- standalone harness ----------------------------------------------------------

Future<void> _pumpResult(
  WidgetTester tester,
  ResultModel model, {
  Size size = kIphone16,
  double textScale = 1,
  VoidCallback? onNext,
  VoidCallback? onRetry,
}) async {
  setDevice(tester, size, top: 59, bottom: 34, textScale: textScale);
  final layout = PlayLayout(size);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: LoopColors.groundBottom,
        body: LoopScale(
          value: layout.s,
          child: ResultView(
            model: model,
            letters: model.word.split(''),
            strings: PlayStrings.of('tr'),
            rating: RatingStrings.of('tr'),
            layout: layout,
            motion: ResultMotion.rest,
            slotKey: GlobalKey(),
            interactive: true,
            onBack: () {},
            onRetry: onRetry ?? () {},
            onNext: model.next == ResultNext.none ? null : (onNext ?? () {}),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(); // the radial is placed after the first layout
}

String? _primary(WidgetTester tester) =>
    tester.widget<LimePill>(find.byType(LimePill)).label;

TextLink _link(WidgetTester tester) =>
    tester.widget<TextLink>(find.byType(TextLink));

List<String> _stats(WidgetTester tester) =>
    tester.widget<StatCard>(find.byType(StatCard)).cells.map((c) {
      return '${c.label}=${c.value}${c.star ? '★' : ''}';
    }).toList();

double _maxScroll(WidgetTester tester) => tester
    .state<ScrollableState>(find.byType(Scrollable))
    .position
    .maxScrollExtent;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  // --- the §16.8 variant table (pure) ---------------------------------------------

  group(
    'ResultModel — badges, markers, CTA weighting (C-4, §20.3 (5)–(6))',
    () {
      test('Perfect first clear → HARİKA, 3★, best 3★, Next primary', () {
        final m = _model(player: 3);
        expect(m.badge, ResultBadge.perfect);
        expect(m.stars, 3);
        expect((m.best, m.bestIsPerfect), (3, true));
        expect(m.nextIsPrimary, isTrue);
      });

      test('Perfect + new best → HARİKA only (it wins over YENİ EN İYİ)', () {
        final m = _model(player: 3, priorBest: 5);
        expect(m.badge, ResultBadge.perfect);
      });

      test('new best (2★) → YENİ EN İYİ; Retry primary', () {
        final m = _model(player: 5, priorBest: 6);
        expect(m.badge, ResultBadge.newBest);
        expect(m.stars, 2);
        expect(m.best, 5);
        expect(m.nextIsPrimary, isFalse);
      });

      test('first clear (2★), matched best → no badge', () {
        expect(_model(player: 4).badge, ResultBadge.none);
        expect(_model(player: 5, priorBest: 5).badge, ResultBadge.none);
      });

      test('no improvement (1★) → no badge, the retained best (AC5)', () {
        final m = _model(player: 8, priorBest: 4);
        expect(m.badge, ResultBadge.none);
        expect(m.stars, 1);
        expect(m.best, 4);
      });

      test('C1: stars and HARİKA never wait; EN İYİ and YENİ EN İYİ do', () {
        final perfect = _model(player: 3, priorBest: 5, resolved: false);
        expect(perfect.stars, 3);
        expect(perfect.badge, ResultBadge.perfect);
        expect(perfect.best, isNull);
        final newBest = _model(player: 5, priorBest: 6, resolved: false);
        expect(newBest.badge, ResultBadge.none);
        expect(newBest.best, isNull);
      });

      test('C1: a failed write → EN İYİ —, no best badge', () {
        final m = _model(player: 5, priorBest: 6, persisted: false);
        expect(m.best, isNull);
        expect(m.badge, ResultBadge.none);
        expect(m.bestIsPerfect, isFalse);
      });

      test(
        'no Next handler → Retry primary even when Perfect; link disabled',
        () {
          final m = _model(player: 3, next: ResultNext.none);
          expect(m.nextIsPrimary, isFalse);
          expect(m.nextDisabled, isTrue);
        },
      );

      test('no-optimal fallback → unrated, — · —, no badge', () {
        expect(_unrated.rated, isFalse);
        expect((_unrated.optimal, _unrated.best), (null, null));
        expect(_unrated.badge, ResultBadge.none);
      });
    },
  );

  // --- the variants, rendered -------------------------------------------------------

  group('variants on screen (§16.8, §16.11.1 (9)–(11))', () {
    testWidgets('D2-01 Perfect · first clear', (tester) async {
      await _pumpResult(tester, _model(player: 3));
      expect(find.text('HARİKA'), findsOneWidget);
      expect(tester.widget<StarRow>(find.byType(StarRow)).earned, 3);
      expect(_stats(tester), <String>['SEN=3', 'OPTİMAL=3', 'EN İYİ=3★']);
      expect(_primary(tester), 'Sonraki bölüm');
      expect(_link(tester).label, 'Tekrar oyna');
      expect(find.text('Hedef üç hamlede yerine oturdu.'), findsOneWidget);
      expect(find.text('Döngü\ntamamlandı.'), findsOneWidget);
    });

    testWidgets('D2-02 Perfect + new best → one badge', (tester) async {
      await _pumpResult(tester, _model(player: 3, priorBest: 5));
      expect(find.text('HARİKA'), findsOneWidget);
      expect(find.text('YENİ EN İYİ'), findsNothing);
    });

    testWidgets('D2-03 new best 2★', (tester) async {
      await _pumpResult(tester, _model(player: 5, priorBest: 6));
      expect(find.text('YENİ EN İYİ'), findsOneWidget);
      expect(tester.widget<StarRow>(find.byType(StarRow)).earned, 2);
      expect(_stats(tester), <String>['SEN=5', 'OPTİMAL=3', 'EN İYİ=5']);
      expect(_primary(tester), 'Tekrar oyna');
      expect(_link(tester).label, 'Sonraki bölüm');
    });

    testWidgets('D2-04 first clear 2★ / D2-05 matched best: no badge', (
      tester,
    ) async {
      for (final m in <ResultModel>[
        _model(player: 4),
        _model(player: 5, priorBest: 5),
      ]) {
        await _pumpResult(tester, m);
        expect(find.byType(LoopBadge), findsNothing);
        expect(_primary(tester), 'Tekrar oyna');
      }
    });

    testWidgets('D2-06 no improvement 1★: the retained best', (tester) async {
      await _pumpResult(tester, _model(player: 8, priorBest: 4));
      expect(find.byType(LoopBadge), findsNothing);
      expect(tester.widget<StarRow>(find.byType(StarRow)).earned, 1);
      expect(_stats(tester), <String>['SEN=8', 'OPTİMAL=3', 'EN İYİ=4']);
      expect(find.text('Hedef sekiz hamlede yerine oturdu.'), findsOneWidget);
    });

    testWidgets('D2-07 no-optimal: the line in the stars slot, — · —', (
      tester,
    ) async {
      await _pumpResult(tester, _unrated);
      expect(find.byType(StarRow), findsNothing);
      expect(find.text('Bu bölüm puanlanamadı.'), findsOneWidget);
      expect(_stats(tester), <String>['SEN=3', 'OPTİMAL=—', 'EN İYİ=—']);
      expect(_primary(tester), 'Tekrar oyna');
      expect(find.text('Sonraki bölüm · yakında'), findsOneWidget);
    });

    testWidgets('D2-08 Next not wired: Retry primary even when Perfect; the '
        'link is disabled "Sonraki bölüm · yakında"', (tester) async {
      await _pumpResult(tester, _model(player: 3, next: ResultNext.none));
      expect(find.text('HARİKA'), findsOneWidget);
      expect(_primary(tester), 'Tekrar oyna');
      expect(_link(tester).onPressed, isNull);
      expect(find.text('Sonraki bölüm · yakında'), findsOneWidget);
      expect(find.semantics.byLabel('Sonraki bölüm, yakında'), findsOne);
    });

    testWidgets('D2-09 / 09b level 30: "Yolculuğu tamamla" in both weightings '
        '(F05 AC12)', (tester) async {
      var next = 0;
      await _pumpResult(
        tester,
        _model(player: 5, optimal: 5, next: ResultNext.terminal),
        onNext: () => next++,
      );
      expect(_primary(tester), 'Yolculuğu tamamla');
      await tester.tap(find.text('Yolculuğu tamamla'));
      expect(next, 1);
      await _pumpResult(
        tester,
        _model(player: 7, optimal: 5, next: ResultNext.terminal),
        onNext: () => next++,
      );
      expect(_link(tester).label, 'Yolculuğu tamamla');
      await tester.tap(find.text('Yolculuğu tamamla'));
      expect(next, 2);
    });

    testWidgets('no legacy marker survives (C-4, §16.10)', (tester) async {
      for (final m in <ResultModel>[
        _model(player: 3),
        _model(player: 5, priorBest: 6),
        _model(player: 8, priorBest: 4),
        _model(player: 4),
      ]) {
        await _pumpResult(tester, m);
        for (final legacy in <String>[
          '3 / 3',
          '2 / 3',
          '1 / 3',
          '+1',
          '+2',
          '=',
          'İLK',
          'daha iyi',
          'ÇÖZÜLDÜ',
          'YENİ REKOR',
          'Kapat',
          'SONRAKİ',
          'Yeniden',
        ]) {
          expect(find.text(legacy), findsNothing, reason: legacy);
        }
      }
    });

    testWidgets('one glow: the pill has a neutral shadow; stars are flat', (
      tester,
    ) async {
      await _pumpResult(tester, _model(player: 3));
      expect(tester.widget<LimePill>(find.byType(LimePill)).glow, isFalse);
      // Every earned star is a flat filled icon (no shadow in `StarRow`).
      expect(
        find.descendant(
          of: find.byType(StarRow),
          matching: find.byType(DecoratedBox),
        ),
        findsNothing,
      );
    });
  });

  // --- layout (§16.6) ---------------------------------------------------------------

  group('layout anchors at 1.0× (±2 pt, §16.11.1 (8))', () {
    for (final device in kPlayDevices) {
      testWidgets('${device.width.toInt()}×${device.height.toInt()}', (
        tester,
      ) async {
        final layout = PlayLayout(device);
        final s = layout.s;
        final e = layout.extra;
        void near(String what, double actual, double expected) {
          expect(
            actual,
            closeTo(expected, 2),
            reason: '$what: $actual vs $expected',
          );
        }

        await _pumpResult(tester, _model(player: 3), size: device);
        final back = tester.getRect(
          find.descendant(
            of: find.byType(ResultView),
            matching: find.byType(GlassIconButton),
          ),
        );
        near('back x', back.left, 24 * s);
        near('back y', back.top, 54 * s);
        expect(back.width, closeTo(44, 1e-6));
        expect(back.height, closeTo(44, 1e-6));

        near(
          'badge top',
          tester.getRect(find.byType(LoopBadge)).top,
          54 * s + 0.16 * e,
        );
        near(
          'headline top',
          tester.getRect(find.text('Döngü\ntamamlandı.')).top,
          112 * s + 0.24 * e,
        );
        final headline = paragraphOf(tester, find.text('Döngü\ntamamlandı.'));
        expect(lineTexts(headline), hasLength(2));

        final tiles = find.descendant(
          of: find.byType(ResultView),
          matching: find.byType(TileFace),
        );
        expect(tiles, findsNWidgets(5));
        final first = tester.getRect(tiles.first);
        near('tiles top', first.top, 258 * s + 0.4 * e);
        near('tile w', first.width, 52.5 * s);
        near('tile h', first.height, 59 * s);
        near(
          'tiles left',
          first.left,
          (device.width - (5 * 52.5 + 4 * 6.5) * s) / 2,
        );
        near(
          'stars top',
          tester.getRect(find.byType(StarRow)).top,
          349 * s + 0.4 * e,
        );
        final stats = tester.getRect(find.byType(StatCard));
        near('stats top', stats.top, 392.5 * s + 0.4 * e);
        near('stats h', stats.height, 74 * s);
        near('stats w', stats.width, 309 * s);
        final pill = tester.getRect(find.byType(LimePill));
        near('pill top', pill.top, 485 * s + 0.4 * e);
        near('pill h', pill.height, 63.5 * s);
        final link = tester.getRect(find.byType(TextLink));
        near(
          'link centre',
          link.center.dy,
          575.75 * s + 0.4 * e,
        ); // table: 658.0 on 16
        expect(link.height, greaterThanOrEqualTo(44));
        expect(link.width, closeTo(309 * s, 0.5)); // full-column hit box
      });
    }

    testWidgets('the badge row is reserved: the row lands at the same place '
        'with and without a badge', (tester) async {
      await _pumpResult(tester, _model(player: 3));
      final withBadge = tester.getRect(
        find
            .descendant(
              of: find.byType(ResultView),
              matching: find.byType(TileFace),
            )
            .first,
      );
      await _pumpResult(tester, _model(player: 4));
      final without = tester.getRect(
        find
            .descendant(
              of: find.byType(ResultView),
              matching: find.byType(TileFace),
            )
            .first,
      );
      expect(without, withBadge);
    });
  });

  group('text scale (C-9, §16.11.1 (12))', () {
    for (final device in kPlayDevices) {
      for (final scale in kOsTextScales.where((x) => x <= 1.3)) {
        testWidgets(
          '${device.width.toInt()} pt at ${scale}x: fits, no scroll',
          (tester) async {
            await _pumpResult(
              tester,
              _model(player: 5, optimal: 5, next: ResultNext.terminal),
              size: device,
              textScale: scale,
            );
            expect(tester.takeException(), isNull);
            expect(_maxScroll(tester), 0);
          },
        );
      }
    }

    for (final device in kPlayDevices) {
      testWidgets('${device.width.toInt()} pt at AX5: scrolls, back fixed, '
          'lands at 0, band only when scrolled, no mid-word break', (
        tester,
      ) async {
        await _pumpResult(
          tester,
          _model(player: 3, next: ResultNext.none),
          size: device,
          textScale: 3.118,
        );
        expect(tester.takeException(), isNull);
        expect(_maxScroll(tester), greaterThan(0));
        final position = tester
            .state<ScrollableState>(find.byType(Scrollable))
            .position;
        expect(position.pixels, 0);
        expect(
          tester.widget<ScrollBand>(find.byType(ScrollBand)).visibility,
          0,
        );
        final backFinder = find.descendant(
          of: find.byType(ResultView),
          matching: find.byType(GlassIconButton),
        );
        final back = tester.getRect(backFinder);

        // Container text stays capped; free text follows the OS.
        final headline = paragraphOf(tester, find.text('Döngü\ntamamlandı.'));
        expect(headline.textScaler.scale(10) / 10, closeTo(1.3, 1e-9));
        for (final text in <String>[
          'Hedef üç hamlede yerine oturdu.',
          'Tekrar oyna',
          'Sonraki bölüm · yakında',
        ]) {
          final p = paragraphOf(tester, find.text(text));
          expect(p.textScaler.scale(10) / 10, closeTo(3.118, 1e-9));
          expect(lineBreakFaults(text, lineTexts(p)), isEmpty, reason: text);
        }

        position.jumpTo(position.maxScrollExtent);
        await tester.pump();
        expect(tester.getRect(backFinder), back);
        expect(
          tester.widget<ScrollBand>(find.byType(ScrollBand)).visibility,
          1,
        );
        // The link is reachable above the home indicator.
        expect(
          tester.getRect(find.byType(TextLink)).bottom,
          lessThanOrEqualTo(device.height - 34 + 0.5),
        );
      });
    }
  });

  // F03-FE-D2R — F03-QA-D2-01, architecture §20.9 (1): the band follows the
  // scroll position after a scroll-metrics change, not only after a scroll.
  group('scroll band after a live OS text-size change (§20.9 (1))', () {
    ScrollPosition position(WidgetTester tester) =>
        tester.state<ScrollableState>(find.byType(Scrollable)).position;
    double band(WidgetTester tester) =>
        tester.widget<ScrollBand>(find.byType(ScrollBand)).visibility;
    // Nothing is painted when the band is hidden: it builds a bare spacer.
    Finder bandPaint() => find.descendant(
      of: find.byType(ScrollBand),
      matching: find.byType(Opacity),
    );

    // AX5 → scrolled to the end → the OS text size drops to [scale].
    Future<void> shrinkWhileScrolled(
      WidgetTester tester,
      Size device,
      double scale,
    ) async {
      await _pumpResult(
        tester,
        _model(player: 3, priorBest: 5, next: ResultNext.none),
        size: device,
        textScale: 3.118,
      );
      final p = position(tester);
      p.jumpTo(p.maxScrollExtent);
      await tester.pump();
      expect(band(tester), 1);
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      await tester.pump(); // relayout: the offset is clamped (no listener)
      await tester.pump(); // the ScrollMetricsNotification's rebuild
      expect(tester.takeException(), isNull);
    }

    for (final device in kPlayDevices) {
      for (final scale in <double>[1, 1.3]) {
        testWidgets('${device.width.toInt()} pt, AX5 scrolled → ${scale}x: '
            'no band over the badge and back button', (tester) async {
          await shrinkWhileScrolled(tester, device, scale);
          final p = position(tester);
          expect(p.maxScrollExtent, 0);
          expect(p.pixels, 0);
          expect(band(tester), 0);
          expect(bandPaint(), findsNothing);
          expect(find.byType(LoopBadge), findsOneWidget);
          expect(
            find.descendant(
              of: find.byType(ResultView),
              matching: find.byType(GlassIconButton),
            ),
            findsOneWidget,
          );
        });
      }

      testWidgets('${device.width.toInt()} pt, AX5 scrolled → 2.1x (still '
          'scrolls, offset clamped below the fade distance): the band '
          'matches the clamped offset', (tester) async {
        await shrinkWhileScrolled(tester, device, 2.1);
        final p = position(tester);
        expect(p.maxScrollExtent, greaterThan(0));
        expect(p.maxScrollExtent, lessThan(ResultView.bandFadeDistance));
        expect(p.pixels, p.maxScrollExtent);
        expect(
          band(tester),
          closeTo(p.pixels / ResultView.bandFadeDistance, 1e-9),
        );
      });
    }
  });

  // --- semantics (§16.11) ---------------------------------------------------------

  testWidgets('semantics: labels and traversal back → verdict → answer → '
      'stars → stats → primary → link', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpResult(tester, _model(player: 3, next: ResultNext.none));
    final order = tester.semantics
        .simulatedAccessibilityTraversal()
        .map((n) => n.label)
        .where((l) => l.isNotEmpty)
        .toList();
    final expected = <String>[
      'Ana ekrana dön',
      'Harika',
      'Döngü tamamlandı.',
      'Hedef üç hamlede yerine oturdu.',
      'Cevap: BULUT',
      '3 / 3 yıldız, Harika',
      'Sen 3, optimal 3, en iyi 3, harika',
      'Tekrar oyna',
      'Sonraki bölüm, yakında',
    ];
    var at = -1;
    for (final label in expected) {
      final i = order.indexOf(label);
      expect(i, greaterThan(at), reason: '"$label" in $order');
      at = i;
    }
    handle.dispose();
  });

  // --- the rating read (C1), through the screen -------------------------------------

  group('C1 — the late personal-best read (§20.7)', () {
    for (final fail in <bool>[false, true]) {
      testWidgets(
        fail
            ? 'a failed write: EN İYİ stays —, no badge'
            : 'no badge and — until resolved; then YENİ EN İYİ fades in with '
                  'no layout shift',
        (tester) async {
          setDevice(tester, kIphone16, top: 59, bottom: 34);
          final db = AppDatabase.forTesting(NativeDatabase.memory());
          addTearDown(db.close);
          final guest = await PlayerRepo(db).currentGuestId();
          await PersonalBestRepo(db).recordCompletion(
            guestId: guest,
            levelId: 'c1-late',
            moveCount: 4,
            stars: 1,
            optimalMoves: 1,
            completedAtUtcMs: 1757100000000,
          );
          final repo = _GatedBestRepo(db, fail: fail);
          await tester.pumpWidget(_screen(db, repo, _c1Puzzle()));
          await tester.pumpAndSettle();

          // 2 moves against optimal 1 → 2★, beating the prior 4.
          await tester.dragFrom(cellCenter(tester, 1, 0), const Offset(140, 0));
          await tester.pumpAndSettle();
          await tester.dragFrom(cellCenter(tester, 2, 0), const Offset(140, 0));
          await tester.pumpAndSettle();

          expect(
            tester.widget<ResultView>(find.byType(ResultView)).interactive,
            isTrue,
          );
          expect(_stats(tester).last, 'EN İYİ=—');
          expect(find.text('YENİ EN İYİ'), findsNothing);
          expect(tester.widget<StarRow>(find.byType(StarRow)).earned, 2);
          Rect answer() => tester.getRect(
            find
                .descendant(
                  of: find.byType(ResultView),
                  matching: find.byType(TileFace),
                )
                .first,
          );
          final before = answer();
          final headline = tester.getRect(find.text('Döngü\ntamamlandı.'));

          repo.gate.complete();
          await tester.pump();
          await tester.pump();
          if (fail) {
            await tester.pumpAndSettle();
            expect(_stats(tester).last, 'EN İYİ=—');
            expect(find.byType(LoopBadge), findsNothing);
            return;
          }
          expect(find.text('YENİ EN İYİ'), findsOneWidget);
          await tester.pump(const Duration(milliseconds: 80));
          final fade = tester.widget<FadeTransition>(
            find
                .ancestor(
                  of: find.byType(LoopBadge),
                  matching: find.byType(FadeTransition),
                )
                .first,
          );
          expect(fade.opacity.value, inExclusiveRange(0, 1));
          await tester.pumpAndSettle();
          expect(_stats(tester).last, 'EN İYİ=2');
          expect(answer(), before);
          expect(tester.getRect(find.text('Döngü\ntamamlandı.')), headline);
        },
      );
    }
  });

  // --- F04 AC1–AC10 on the result, through the screen ---------------------------------

  group('F04 content on the result (AC1–AC10)', () {
    Future<AppDatabase> boot(WidgetTester tester, String id) async {
      setDevice(tester, kIphone16, top: 59, bottom: 34);
      return bootPlay(
        tester,
        args: PlaySessionArgs(source: PuzzleSource.journey, debugPuzzleId: id),
      );
    }

    Future<void> shift(WidgetTester tester, int row) async {
      await tester.dragFrom(cellCenter(tester, row, 0), const Offset(140, 0));
      await tester.pumpAndSettle();
    }

    testWidgets('smoke-tr-01 in 1 (optimal 1): Perfect + first clear, every '
        'AC7 element (AC1, AC7, AC8)', (tester) async {
      await boot(tester, 'smoke-tr-01');
      await shift(tester, 0);
      expect(find.byType(ResultView), findsOneWidget);
      expect(find.semantics.byLabel('Cevap: MASAL'), findsOne); // target word
      expect(_stats(tester), <String>['SEN=1', 'OPTİMAL=1', 'EN İYİ=1★']);
      expect(tester.widget<StarRow>(find.byType(StarRow)).earned, 3);
      expect(find.text('HARİKA'), findsOneWidget);
      expect(find.text('Tekrar oyna'), findsOneWidget); // Retry
      expect(find.text('Sonraki bölüm · yakında'), findsOneWidget); // Next
      expect(
        find.semantics.byLabel('Sen 1, optimal 1, en iyi 1, harika'),
        findsOne,
      );
      expect(find.semantics.byLabel('3 / 3 yıldız, Harika'), findsOne);
    });

    testWidgets('Retry → again in 1 → matched best, still Perfect', (
      tester,
    ) async {
      await boot(tester, 'smoke-tr-01');
      await shift(tester, 0);
      await tester.tap(find.text('Tekrar oyna'));
      await tester.pumpAndSettle();
      expect(find.byType(ResultView), findsNothing);
      await shift(tester, 0);
      expect(find.text('HARİKA'), findsOneWidget);
      expect(find.text('YENİ EN İYİ'), findsNothing);
      expect(_stats(tester).last, 'EN İYİ=1★');
    });

    testWidgets('smoke-tr-02 in 3 (optimal 2) → 2★, not Perfect (AC2, AC9)', (
      tester,
    ) async {
      await boot(tester, 'smoke-tr-02');
      await shift(tester, 1);
      await shift(tester, 0);
      await shift(tester, 0);
      expect(tester.widget<StarRow>(find.byType(StarRow)).earned, 2);
      expect(find.text('HARİKA'), findsNothing);
      expect(_stats(tester).take(2), <String>['SEN=3', 'OPTİMAL=2']);
    });

    testWidgets('a beaten prior best → the best updates, but Perfect wins the '
        'badge (AC6)', (tester) async {
      setDevice(tester, kIphone16, top: 59, bottom: 34);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final guest = await PlayerRepo(db).currentGuestId();
      await PersonalBestRepo(db).recordCompletion(
        guestId: guest,
        levelId: 'smoke-tr-01',
        moveCount: 4,
        stars: 1,
        optimalMoves: 1,
        completedAtUtcMs: 1757100000000,
      );
      await tester.pumpWidget(
        playApp(
          db: db,
          puzzle: null,
          args: const PlaySessionArgs(
            source: PuzzleSource.journey,
            debugPuzzleId: 'smoke-tr-01',
          ),
          direct: true,
        ),
      );
      await tester.pumpAndSettle();
      await shift(tester, 0);
      expect(_stats(tester).last, 'EN İYİ=1★');
      expect(find.text('HARİKA'), findsOneWidget);
      expect(find.text('YENİ EN İYİ'), findsNothing);
    });

    testWidgets('a worse result → this run\'s stars, the retained better best '
        '(AC5)', (tester) async {
      setDevice(tester, kIphone16, top: 59, bottom: 34);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final guest = await PlayerRepo(db).currentGuestId();
      await PersonalBestRepo(db).recordCompletion(
        guestId: guest,
        levelId: 'smoke-tr-02',
        moveCount: 2,
        stars: 3,
        optimalMoves: 2,
        completedAtUtcMs: 1757100000000,
      );
      await tester.pumpWidget(
        playApp(
          db: db,
          puzzle: null,
          args: const PlaySessionArgs(
            source: PuzzleSource.journey,
            debugPuzzleId: 'smoke-tr-02',
          ),
          direct: true,
        ),
      );
      await tester.pumpAndSettle();
      await shift(tester, 1);
      await shift(tester, 0);
      await shift(tester, 0);
      expect(tester.widget<StarRow>(find.byType(StarRow)).earned, 2);
      expect(_stats(tester), <String>['SEN=3', 'OPTİMAL=2', 'EN İYİ=2★']);
      expect(find.byType(LoopBadge), findsNothing);
      expect(
        (await PersonalBestRepo(db).read(guest, 'smoke-tr-02'))?.bestMoveCount,
        2,
      );
    });

    testWidgets('no-optimal puzzle → the unrated result; Retry still there', (
      tester,
    ) async {
      setDevice(tester, kIphone16, top: 59, bottom: 34);
      await bootPlay(tester, puzzle: _noOptimalPuzzle());
      await shift(tester, 0);
      expect(find.byType(ResultView), findsOneWidget);
      expect(find.text('Bu bölüm puanlanamadı.'), findsOneWidget);
      expect(find.byType(StarRow), findsNothing);
      expect(find.byType(LoopBadge), findsNothing);
      expect(_stats(tester), <String>['SEN=1', 'OPTİMAL=—', 'EN İYİ=—']);
      expect(find.text('Tekrar oyna'), findsOneWidget);
    });

    test('PlaySessionController with optimalMoves < 1 → ratingUnavailable, '
        'no CompletionResult, logs rating_blocked_no_optimal', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final guestId = await PlayerRepo(db).currentGuestId();
      final logs = <String?>[];
      final previous = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) => logs.add(message);
      addTearDown(() => debugPrint = previous);

      final controller = PlaySessionController(
        puzzle: _noOptimalPuzzle(),
        source: PuzzleSource.journey,
        validator: const NeverValidWordValidator(),
        activeSessionRepo: ActiveSessionRepo(db),
        personalBestRepo: PersonalBestRepo(db),
        guestId: guestId,
        clock: () => DateTime.utc(2026, 9, 7, 12),
      );
      addTearDown(controller.dispose);
      await controller.whenPersisted;
      controller
        ..beginDrag(startRow: 0, startCol: 0)
        ..updateDrag(const Offset(40, 0));
      expect(controller.endDrag(const Offset(40, 0)), DragResolution.shift);
      expect(controller.commitShift(), isTrue);
      expect(controller.ratingUnavailable, isTrue);
      expect(controller.completion, isNull);
      expect(
        logs.any((m) => m != null && m.contains('rating_blocked_no_optimal')),
        isTrue,
      );
    });
  });
}

// --- C1 support --------------------------------------------------------------------

/// A personal-best store whose reads wait on [gate] — the slow read-back of
/// §20.7 C1 — and optionally fail (the write-failure path).
class _GatedBestRepo extends PersonalBestRepo {
  _GatedBestRepo(super.db, {required this.fail});

  final Completer<void> gate = Completer<void>();
  final bool fail;

  @override
  Future<PersonalBest?> read(String guestId, String levelId) async {
    await gate.future;
    if (fail) throw StateError('disk full');
    return super.read(guestId, levelId);
  }
}

/// `MASAL` one `rowRight` away in row 2; optimal 1; a filler row 1 to waste a
/// move on.
Puzzle _c1Puzzle() => Puzzle(
  schemaVersion: 1,
  contentVersion: 'test',
  id: 'c1-late',
  puzzleType: PuzzleType.journey,
  journeyLevelNumber: 1,
  language: 'tr',
  grid: const <String>['BCDFG', 'HJKLN', 'ASALM', 'PRTUV', 'YZBCD'],
  targetWord: 'MASAL',
  lockedCells: const <GridCoord>{},
  frozenCells: const <GridCoord>{},
  columnMovesEnabled: false,
  optimalMoves: 1,
  difficultyScore: 1,
  difficultyLabel: DifficultyLabel.easy,
  difficultyBreakdown: const <String, num>{},
);

Puzzle _noOptimalPuzzle() => Puzzle(
  schemaVersion: 1,
  contentVersion: 'test',
  id: 'no-optimal-test',
  puzzleType: PuzzleType.journey,
  journeyLevelNumber: 1,
  language: 'tr',
  grid: const <String>['ASALM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
  targetWord: 'MASAL',
  lockedCells: const <GridCoord>{},
  frozenCells: const <GridCoord>{},
  columnMovesEnabled: false,
  optimalMoves: 0,
  difficultyScore: 1,
  difficultyLabel: DifficultyLabel.easy,
  difficultyBreakdown: const <String, num>{},
);

Widget _screen(AppDatabase db, PersonalBestRepo repo, Puzzle puzzle) {
  final router = GoRouter(
    initialLocation: '/play',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: Text('HOME')),
      ),
      GoRoute(
        path: '/play',
        builder: (context, state) => PlaySessionScreen(
          args: PlaySessionArgs(
            source: PuzzleSource.journey,
            debugPuzzleId: puzzle.id,
          ),
        ),
      ),
    ],
  );
  return ProviderScope(
    overrides: <Override>[
      appDatabaseProvider.overrideWithValue(db),
      personalBestRepoProvider.overrideWithValue(repo),
      wordValidatorProvider.overrideWith(
        (ref) async => const NeverValidWordValidator(),
      ),
      playSessionSetupProvider.overrideWith(
        (ref, args) async => PlaySessionSetup(
          puzzle: puzzle,
          validator: const NeverValidWordValidator(),
        ),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}
