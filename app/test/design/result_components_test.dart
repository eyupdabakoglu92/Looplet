// The Phase D2 design-layer additions (F03 architecture §20.7 (6)): the
// answer-size `TileFace.answer`, the `StarRow` reveal and the `ScrollBand`.
// No token value changes; the F00 component tests stay as they are.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/design/design.dart';
import 'package:looplet_app/play/widgets/travelling_tile.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double s = 1.1,
  double textScale = 1,
}) async {
  if (textScale != 1) {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: LoopScale(
          value: s,
          child: Center(child: child),
        ),
      ),
    ),
  );
}

void main() {
  group('TileFace.answer', () {
    testWidgets('winning, 52.5 × 59·s, radius 24·s, glyph 22·s', (
      tester,
    ) async {
      await _pump(tester, const TileFace.answer(letter: 'B', scale: 1.1));
      final face = tester.widget<TileFace>(find.byType(TileFace));
      expect(face.state, TileState.winning);
      expect(face.size, closeTo(57.75, 1e-9));
      expect(face.height, closeTo(64.9, 1e-9));
      expect(face.radius, closeTo(26.4, 1e-9));
      final size = tester.getSize(find.byType(TileFace));
      expect(size.width, closeTo(57.75, 1e-9));
      expect(size.height, closeTo(64.9, 1e-9));
      final text = tester.widget<Text>(find.text('B'));
      expect(text.style!.fontSize, closeTo(24.2, 1e-9));
      expect(text.style!.color, LoopColors.limeInk);
    });

    testWidgets('its glyph is capped at 1.3× (AX5)', (tester) async {
      await _pump(
        tester,
        const TileFace.answer(letter: 'B', scale: 1.1),
        textScale: 3.12,
      );
      final text = tester.widget<Text>(find.text('B'));
      expect(text.textScaler!.scale(10), closeTo(13, 1e-9));
      expect(tester.takeException(), isNull);
    });

    testWidgets('without glyphSize the board tile keeps 38 % of its edge', (
      tester,
    ) async {
      await _pump(tester, const TileFace(letter: 'B', size: 50));
      expect(
        tester.widget<Text>(find.text('B')).style!.fontSize,
        closeTo(19, 1e-9),
      );
    });
  });

  group('StarRow reveal', () {
    test('pop: 0 → (0, .6); 60 % → (1, 1.18); end → (1, 1)', () {
      expect(StarRow.pop(0), (opacity: 0.0, scale: 0.6));
      final peak = StarRow.pop(0.6);
      expect(peak.opacity, 1);
      expect(peak.scale, closeTo(1.18, 1e-9));
      expect(StarRow.pop(1), (opacity: 1.0, scale: 1.0));
      expect(StarRow.pop(0.3).scale, inExclusiveRange(0.6, 1.18));
    });

    Iterable<LoopIconView> filled(WidgetTester tester) => tester
        .widgetList<LoopIconView>(find.byType(LoopIconView))
        .where((i) => i.filled);

    testWidgets('earned stars start as outlines and pop 110 ms apart', (
      tester,
    ) async {
      await _pump(tester, const StarRow(earned: 2, revealMs: 0));
      expect(filled(tester), isEmpty); // opacity 0 → not built
      await _pump(tester, const StarRow(earned: 2, revealMs: 70));
      expect(filled(tester), hasLength(1)); // star 0 mid-pop
      final pop = tester.widget<Transform>(
        find.ancestor(
          of: find.byWidget(filled(tester).first),
          matching: find.byType(Transform),
        ),
      );
      expect(pop.transform.getMaxScaleOnAxis(), greaterThan(1));
      await _pump(tester, const StarRow(earned: 2, revealMs: 360));
      expect(filled(tester), hasLength(2)); // the unearned third never fills
    });

    testWidgets('static (null) = the shipped look: earned filled at once', (
      tester,
    ) async {
      await _pump(tester, const StarRow(earned: 3));
      expect(filled(tester), hasLength(3));
      expect(
        find.descendant(
          of: find.byType(StarRow),
          matching: find.byType(Transform),
        ),
        findsNothing,
      );
    });

    testWidgets('semantics unchanged: "N / 3 yıldız"', (tester) async {
      await _pump(tester, const StarRow(earned: 1, revealMs: 0));
      expect(find.semantics.byLabel('1 / 3 yıldız'), findsOne);
    });
  });

  group('ScrollBand', () {
    testWidgets('54·s + 58 pt tall; invisible at 0, the ground at 1', (
      tester,
    ) async {
      await _pump(tester, const ScrollBand(visibility: 0));
      expect(
        tester.getSize(find.byType(ScrollBand)).height,
        closeTo(117.4, 1e-9),
      );
      expect(find.byType(DecoratedBox), findsNothing);

      await _pump(tester, const ScrollBand());
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(ScrollBand),
          matching: find.byType(DecoratedBox),
        ),
      );
      final gradient =
          (box.decoration as BoxDecoration).gradient! as LinearGradient;
      expect(gradient.colors.first, ScrollBand.ground);
      expect(gradient.stops, <double>[0, 0.78, 1]);
      expect(gradient.colors.last.a, 0);
      // Decorative: no semantics, no hit testing.
      expect(
        find.descendant(
          of: find.byType(ScrollBand),
          matching: find.byType(IgnorePointer),
        ),
        findsOneWidget,
      );
    });
  });

  group('TravellingTile (C-11)', () {
    testWidgets('a locked face under a half fill keeps its icon; full fill '
        'swallows it', (tester) async {
      Widget tile(double fill) => TravellingTile.win(
        letter: 'A',
        base: TileState.locked,
        fill: fill,
        width: 57,
        height: 57,
        radius: 19,
        glyph: 21.7,
      );
      Finder lock() => find.byWidgetPredicate(
        (w) => w is LoopIconView && w.icon == LoopIcon.lock,
      );
      await _pump(tester, tile(0.5));
      expect(lock(), findsOneWidget);
      await _pump(tester, tile(1));
      expect(lock(), findsNothing);
      expect(
        tester.widget<TileFace>(find.byType(TileFace)).state,
        TileState.winning,
      );
    });

    testWidgets('a frozen face: its snowflake and dashes go with the fill', (
      tester,
    ) async {
      Widget tile(double fill) => TravellingTile.win(
        letter: 'A',
        base: TileState.frozen,
        fill: fill,
        width: 57,
        height: 57,
        radius: 19,
        glyph: 21.7,
      );
      Finder snow() => find.byWidgetPredicate(
        (w) => w is LoopIconView && w.icon == LoopIcon.snowflake,
      );
      Finder dashes() => find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is DashedRRectPainter,
      );
      await _pump(tester, tile(0));
      expect(snow(), findsOneWidget);
      expect(dashes(), findsOneWidget);
      await _pump(tester, tile(1));
      expect(snow(), findsNothing);
      expect(dashes(), findsNothing);
    });

    testWidgets('the flight ends on the rail face (lime 0)', (tester) async {
      await _pump(
        tester,
        const TravellingTile.flight(
          letter: 'A',
          lime: 0,
          width: 39.5,
          height: 46.1,
          radius: 15.4,
          glyph: 18.1,
        ),
      );
      final text = tester.widgetList<Text>(find.text('A')).first;
      expect(text.style!.color, LoopColors.text);
    });
  });
}
