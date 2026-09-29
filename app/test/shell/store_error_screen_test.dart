// F05-FE-D3 — the store-error screen (F08 AC9; F05 architecture §18.3 (7),
// `ui-design.md` §6 / §8 `D3-20…20d` / §11.1 (13)): Turkish copy, the raw
// exception never shown outside debug and always logged, one Retry that re-runs
// the bootstrap (the splash shows while it runs), AX5 scrolling under the band.
// There was no StoreErrorScreen test before D3 (architecture §18.7).

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/app_router.dart';
import 'package:looplet_app/bootstrap.dart';
import 'package:looplet_app/design/design.dart';
import 'package:looplet_app/home_screen.dart';
import 'package:looplet_app/shell/splash_screen.dart';
import 'package:looplet_app/shell/shell_wordmark.dart';

import '../play/play_test_support.dart' show loadAppFonts;

const String raw =
    'SqliteException(26): while executing, file is not a database, '
    'PRAGMA user_version;';

void main() {
  setUpAll(loadAppFonts);
  setUp(() {
    ShellWordmark.resetFadeForTest();
    HomeScreen.resetEntranceForTest();
  });

  void screen(
    WidgetTester tester, {
    Size size = const Size(393, 852),
    double textScale = 1,
  }) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(reduceMotion: true);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  Widget app(Widget home) => MaterialApp(home: home);

  testWidgets('Turkish copy, one Retry, no exception text when details are '
      'off (profile / release)', (tester) async {
    screen(tester);
    var retries = 0;
    await tester.pumpWidget(
      app(
        StoreErrorScreen(
          message: raw,
          onRetry: () => retries++,
          showDetails: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('KAYITLI VERİLER'), findsOneWidget);
    expect(find.text('Kayıtlı verilerin\naçılamadı.'), findsOneWidget);
    expect(
      find.text('İlerlemen güvende; hiçbir şey silinmedi.'),
      findsOneWidget,
    );
    expect(find.text('Tekrar dene'), findsOneWidget);
    expect(find.byType(LimePill), findsOneWidget);
    expect(find.byType(LoopletWordmark), findsOneWidget);
    // Never the raw message, never English, no Material chrome, no back.
    expect(find.textContaining('Sqlite'), findsNothing);
    expect(find.textContaining('DEBUG'), findsNothing);
    expect(find.textContaining('Couldn'), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(Icon), findsNothing);
    expect(find.byType(LoopBackButton), findsNothing);

    await tester.tap(find.byType(LimePill));
    expect(retries, 1);
  });

  testWidgets('the exception is logged in every build', (tester) async {
    screen(tester);
    final logged = <String>[];
    final previous = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) =>
        logged.add(message ?? '');
    try {
      await tester.pumpWidget(
        app(StoreErrorScreen(message: raw, onRetry: () {}, showDetails: false)),
      );
    } finally {
      debugPrint = previous; // restored before the binding's invariant check
    }
    expect(logged.where((l) => l.contains(raw)), hasLength(1));
  });

  testWidgets('debug builds: the details box, apart from the player copy and '
      'out of the semantics tree', (tester) async {
    screen(tester);
    await tester.pumpWidget(
      app(StoreErrorScreen(message: raw, onRetry: () {})), // kDebugMode
    );
    await tester.pumpAndSettle();
    expect(kDebugMode, isTrue);
    expect(find.text('DEBUG · YALNIZ GELİŞTİRME DERLEMESİ'), findsOneWidget);
    expect(find.text(raw), findsOneWidget);
    // Below the pill.
    expect(
      tester.getRect(find.text(raw)).top,
      greaterThan(tester.getRect(find.byType(LimePill)).bottom),
    );
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel(RegExp('Sqlite')), findsNothing);
    expect(find.bySemanticsLabel(RegExp('DEBUG')), findsNothing);
    expect(find.bySemanticsLabel('Kayıtlı verilerin\naçılamadı.'), findsOne);
    expect(
      find.bySemanticsLabel('İlerlemen güvende; hiçbir şey silinmedi.'),
      findsOne,
    );
    expect(find.bySemanticsLabel('Tekrar dene'), findsOne);
    expect(find.bySemanticsLabel('KAYITLI VERİLER'), findsNothing);
    semantics.dispose();
  });

  testWidgets('1.0× on 393 × 852: wordmark (25, 58)·s, the column centred in '
      '118·s … H − 40·s, no scroll', (tester) async {
    screen(tester);
    await tester.pumpWidget(
      app(StoreErrorScreen(message: raw, onRetry: () {}, showDetails: false)),
    );
    await tester.pumpAndSettle();
    const s = 393 / 358;
    final wordmark = tester.getTopLeft(find.byType(LoopletWordmark));
    expect(wordmark.dx, closeTo(25 * s, 2));
    expect(wordmark.dy, closeTo(58 * s, 2));
    final card = tester.getRect(find.byType(GlassCard));
    final pill = tester.getRect(find.byType(LimePill));
    expect(card.left, closeTo(24.5 * s, 1));
    expect(pill.top - card.bottom, closeTo(20 * s, 1));
    final mid = (card.top + pill.bottom) / 2;
    expect(mid, closeTo((118 * s + 852 - 40 * s) / 2, 2));
    expect(pill.height, greaterThanOrEqualTo(44));
    final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scroll.position.maxScrollExtent, closeTo(0, 0.01));
  });

  for (final size in const <Size>[Size(390, 844), Size(440, 956)]) {
    testWidgets('AX5 on ${size.width.toInt()} pt: scrolls, the pill is '
        'reached, the band covers the status bar, nothing overflows', (
      tester,
    ) async {
      screen(tester, size: size, textScale: 3.118);
      await tester.pumpWidget(
        app(StoreErrorScreen(message: raw, onRetry: () {}, showDetails: false)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scroll.position.maxScrollExtent, greaterThan(0));
      expect(tester.widget<ScrollBand>(find.byType(ScrollBand)).visibility, 0);

      scroll.position.jumpTo(scroll.position.maxScrollExtent);
      await tester.pump();
      expect(tester.widget<ScrollBand>(find.byType(ScrollBand)).visibility, 1);
      final pill = tester.getRect(find.byType(LimePill));
      expect(pill.bottom, lessThanOrEqualTo(size.height));
      // Container text capped, free text at the OS scale; the pill grows.
      final head = tester.widget<Text>(
        find.text('Kayıtlı verilerin\naçılamadı.'),
      );
      expect(head.textScaler!.scale(10) / 10, closeTo(1.3, 1e-6));
      expect(pill.height, greaterThan(63 * size.width / 358));
    });
  }

  testWidgets('the gate: a failing bootstrap → the error screen; Retry → the '
      'splash while it re-runs → the screen again if it fails again', (
    tester,
  ) async {
    screen(tester);
    var calls = 0;
    final retry = Completer<AppBootstrap>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          appBootstrapProvider.overrideWith((ref) {
            calls++;
            if (calls == 1) {
              return Future<AppBootstrap>.value(
                const AppBootstrapMigrationError(raw),
              );
            }
            return retry.future;
          }),
        ],
        child: Consumer(
          builder: (context, ref, _) =>
              MaterialApp.router(routerConfig: ref.watch(appRouterProvider)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(StoreErrorScreen), findsOneWidget);

    await tester.tap(find.byType(LimePill));
    await tester.pump();
    expect(calls, 2);
    expect(find.byType(StoreErrorScreen), findsNothing);
    expect(find.byType(LoopSplashScreen), findsOneWidget);

    retry.complete(const AppBootstrapMigrationError(raw));
    await tester.pumpAndSettle();
    expect(find.byType(StoreErrorScreen), findsOneWidget);
  });
}
