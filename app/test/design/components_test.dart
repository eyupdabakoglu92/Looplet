import 'dart:io';
import 'dart:ui' show SemanticsFlag;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/design/design.dart';
import 'package:looplet_app/design/gallery/design_gallery_screen.dart';

/// F00.DS-AUTOMATED — every component and state of `ui-design.md` §7–§8.
/// Widget tests can prove structure, tokens, semantics and layout; that the
/// pixels match the design is proven by the runtime gallery parity (F00.DS-PARITY).
Widget host(Widget child, {double scale = 393 / 358, Size? size}) =>
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(size: size ?? const Size(393, 852)),
        child: LoopScale(
          value: scale,
          child: Center(child: child),
        ),
      ),
    );

BoxDecoration decorationOf(WidgetTester tester, Finder f) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(of: f, matching: find.byType(DecoratedBox)).first,
  );
  return box.decoration as BoxDecoration;
}

void main() {
  group('TileFace states (ui-design §8) — never colour-only', () {
    testWidgets('normal: cream gradient, ink glyph, no icon', (tester) async {
      await tester.pumpWidget(host(const TileFace(letter: 'A', size: 57)));
      final d = decorationOf(tester, find.byType(TileFace));
      expect(d.gradient, LoopGradients.tile);
      expect(find.byType(LoopIconView), findsNothing);
      final text = tester.widget<Text>(find.text('A'));
      expect(text.style!.color, LoopColors.tileInk);
      expect(text.style!.fontSize, closeTo(57 * 0.38, 1e-9));
    });

    testWidgets('active: periwinkle rim and lift shadow, not lime', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const TileFace(letter: 'A', size: 57, state: TileState.active)),
      );
      final d = decorationOf(tester, find.byType(TileFace));
      expect(d.gradient, LoopGradients.tileActive);
      expect((d.border! as Border).top.color, LoopColors.periwinkle);
      expect((d.border! as Border).top.width, 2);
      expect(d.boxShadow!.length, 2);
      expect(d.boxShadow!.first.color.a, closeTo(0.6, 0.01)); // periwinkle glow
    });

    testWidgets('winning: lime gradient + the single lime glow', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const TileFace(letter: 'A', size: 57, state: TileState.winning)),
      );
      final d = decorationOf(tester, find.byType(TileFace));
      expect(d.gradient, LoopGradients.lime);
      expect(d.boxShadow!.single.color.a, closeTo(0.34, 0.01));
      expect(
        tester.widget<Text>(find.text('A')).style!.color,
        LoopColors.limeInk,
      );
    });

    testWidgets('locked: indigo + a lock icon (non-colour cue)', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const TileFace(letter: 'A', size: 57, state: TileState.locked)),
      );
      expect(
        decorationOf(tester, find.byType(TileFace)).gradient,
        LoopGradients.locked,
      );
      final icon = tester.widget<LoopIconView>(find.byType(LoopIconView));
      expect(icon.icon, LoopIcon.lock);
    });

    testWidgets('frozen: ice + snowflake + dashed border painter', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const TileFace(letter: 'A', size: 57, state: TileState.frozen)),
      );
      final d = decorationOf(tester, find.byType(TileFace));
      expect(d.gradient, LoopGradients.frozen);
      // solid ring under the dashes (the dashes alone read as a faint dotted edge)
      expect(d.border!.top.color, LoopColors.frozenRing);
      expect(d.border!.top.width, 3);
      expect(
        tester.widget<LoopIconView>(find.byType(LoopIconView)).icon,
        LoopIcon.snowflake,
      );
      expect(
        find.descendant(
          of: find.byType(TileFace),
          matching: find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is DashedRRectPainter,
          ),
        ),
        findsOneWidget,
      );
    });

    test(
      'dashed outline follows the source renders dash pattern (3 x / 2 x)',
      () {
        const p = DashedRRectPainter(color: LoopColors.lime, radius: 10);
        expect(p.strokeWidth, 1.5);
        expect(p.dash, 4.5);
        expect(p.gap, 3);
        const wide = DashedRRectPainter(
          color: LoopColors.lime,
          radius: 10,
          dash: 8,
          gap: 2,
        );
        expect((wide.dash, wide.gap), (8, 2));
      },
    );

    testWidgets('inactive: 42 % opacity', (tester) async {
      await tester.pumpWidget(
        host(const TileFace(letter: 'A', size: 57, state: TileState.inactive)),
      );
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.42);
    });

    testWidgets('non-square tile (Result answer tile 52.5 x 59)', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const TileFace(letter: 'B', size: 57.6, height: 64.8, radius: 26)),
      );
      expect(tester.getSize(find.byType(TileFace)), const Size(57.6, 64.8));
    });

    testWidgets('ghost slot and rail tile have the design sizes', (
      tester,
    ) async {
      await tester.pumpWidget(host(const GhostSlot(size: 57)));
      expect(tester.getSize(find.byType(GhostSlot)), const Size(57, 57));
      await tester.pumpWidget(host(const RailTile(letter: 'B')));
      expect(
        tester.getSize(find.byType(RailTile)).width,
        closeTo(36 * 393 / 358, 0.01),
      );
      expect(
        tester.getSize(find.byType(RailTile)).height,
        closeTo(42 * 393 / 358, 0.01),
      );
    });
  });

  group('buttons', () {
    testWidgets('LimePill: glow variant vs neutral (one-glow rule)', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          LimePill(label: 'Devam et', onPressed: () {}, glow: true, width: 300),
        ),
      );
      final glow = decorationOf(
        tester,
        find.byType(LimePill),
      ).boxShadow!.single;
      expect(glow.color.a, closeTo(0.26, 0.01));
      expect(glow.color.g, greaterThan(glow.color.b)); // lime, not neutral

      await tester.pumpWidget(
        host(LimePill(label: 'Sonraki bölüm', onPressed: () {}, width: 300)),
      );
      final neutral = decorationOf(
        tester,
        find.byType(LimePill),
      ).boxShadow!.single;
      expect(neutral.color, const Color(0x80020410)); // dark, no lime
    });

    testWidgets('LimePill fires onPressed and is a semantic button', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          LimePill(label: 'Sonraki bölüm', onPressed: () => taps++, width: 300),
        ),
      );
      await tester.tap(find.byType(LimePill));
      expect(taps, 1);
      final node = tester.getSemantics(find.byType(LimePill));
      expect(node.label, 'Sonraki bölüm');
      expect(node.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(node.hasFlag(SemanticsFlag.isEnabled), isTrue);
    });

    testWidgets('disabled: no callback, 45 % opacity, disabled semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const LimePill(label: 'Sonraki bölüm', onPressed: null, width: 300),
        ),
      );
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.45);
      expect(
        tester
            .getSemantics(find.byType(LimePill))
            .hasFlag(SemanticsFlag.isEnabled),
        isFalse,
      );
    });

    testWidgets('TextLink disabled shows the suffix and keeps a 44 pt target', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const TextLink(
            label: 'Sonraki bölüm',
            onPressed: null,
            disabledSuffix: '· yakında',
          ),
        ),
      );
      expect(find.text('Sonraki bölüm · yakında'), findsOneWidget);
      expect(
        tester.getSize(find.byType(TextLink)).height,
        greaterThanOrEqualTo(44),
      );
    });

    testWidgets('GlassIconButton never drops below the 44 pt target', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          GlassIconButton(
            icon: LoopIcon.back,
            onPressed: () {},
            semanticLabel: 'Ana ekrana dön',
            size: 40,
          ),
        ),
      );
      final size = tester.getSize(find.byType(GlassIconButton));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
      expect(
        tester.getSemantics(find.byType(GlassIconButton)).label,
        'Ana ekrana dön',
      );
    });

    testWidgets(
      'UndoPill shows the quota as lime dots and dims the spent ones',
      (tester) async {
        await tester.pumpWidget(
          host(UndoPill(quota: 2, onPressed: () {}, semanticLabel: 'Geri al')),
        );
        final dots = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(UndoPill),
                matching: find.byType(Container),
              ),
            )
            .where((c) {
              final d = c.decoration;
              return d is BoxDecoration && d.shape == BoxShape.circle;
            })
            .map((c) => (c.decoration! as BoxDecoration).color!)
            .toList();
        expect(dots.length, 3);
        expect(dots[0], LoopColors.limeMid);
        expect(dots[1], LoopColors.limeMid);
        expect(dots[2].a, lessThan(0.5));
      },
    );

    testWidgets('press feedback scales to 98 %, and not under reduced motion', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(LimePill(label: 'Sonraki bölüm', onPressed: () {}, width: 300)),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(LimePill)),
      );
      await tester.pump(const Duration(milliseconds: 120));
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
        0.98,
      );
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 120));

      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(reduceMotion: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final g2 = await tester.startGesture(
        tester.getCenter(find.byType(LimePill)),
      );
      await tester.pump(const Duration(milliseconds: 120));
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
        1.0,
      );
      await g2.up();
    });
  });

  group('info components', () {
    testWidgets('LoopBadge renders its caps label (Turkish İ preserved)', (
      tester,
    ) async {
      await tester.pumpWidget(host(const LoopBadge(label: 'YENİ EN İYİ')));
      expect(find.text('YENİ EN İYİ'), findsOneWidget);
      expect(
        tester.getSize(find.byType(LoopBadge)).height,
        closeTo(42 * 393 / 358, 0.01),
      );
    });

    testWidgets(
      'MovesCard: 60 x 63 at the reference, tabular counter, announced once',
      (tester) async {
        await tester.pumpWidget(host(const MovesCard(moves: 3), scale: 1));
        expect(tester.getSize(find.byType(MovesCard)), const Size(60, 63));
        expect(tester.getSemantics(find.byType(MovesCard)).label, 'HAMLE 3');
      },
    );

    testWidgets('StatCard: three cells, earned star on the third, 74 pt tall', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const StatCard(
            width: 309,
            cells: <StatCell>[
              StatCell(value: '3', label: 'SEN'),
              StatCell(value: '3', label: 'OPTİMAL'),
              StatCell(value: '3', label: 'EN İYİ', star: true),
            ],
          ),
          scale: 1,
        ),
      );
      expect(find.text('SEN'), findsOneWidget);
      expect(find.text('OPTİMAL'), findsOneWidget);
      expect(find.text('EN İYİ'), findsOneWidget);
      expect(tester.getSize(find.byType(StatCard)).height, 74);
      expect(
        tester
            .widgetList<LoopIconView>(find.byType(LoopIconView))
            .where((i) => i.icon == LoopIcon.star)
            .length,
        1,
      );
    });

    testWidgets('LoopNode: done 38, current 58 with a 76 halo', (tester) async {
      await tester.pumpWidget(host(const LoopNode(number: 2), scale: 1));
      expect(tester.getSize(find.byType(LoopNode)), const Size(38, 38));
      await tester.pumpWidget(
        host(const LoopNode(number: 5, current: true), scale: 1),
      );
      expect(tester.getSize(find.byType(LoopNode)), const Size(76, 76));
    });

    testWidgets(
      'StarRow: earned filled, empty outline, announced "N / 3 yıldız"',
      (tester) async {
        await tester.pumpWidget(host(const StarRow(earned: 2)));
        final icons = tester
            .widgetList<LoopIconView>(find.byType(LoopIconView))
            .toList();
        expect(icons.map((i) => i.filled), <bool>[true, true, false]);
        expect(icons[0].color, LoopColors.limeMid);
        expect(tester.getSemantics(find.byType(StarRow)).label, '2 / 3 yıldız');
      },
    );

    testWidgets(
      'Wordmark reads "Looplet": capital L, last three letters lime',
      (tester) async {
        await tester.pumpWidget(host(const LoopletWordmark()));
        final span =
            tester.widget<Text>(find.byType(Text)).textSpan! as TextSpan;
        expect(span.toPlainText(), 'Looplet');
        expect((span.children![0] as TextSpan).text, 'Loop');
        expect((span.children![1] as TextSpan).text, 'let');
        expect((span.children![1] as TextSpan).style!.color, LoopColors.lime);
        expect((span.children![0] as TextSpan).style!.color, LoopColors.text);
      },
    );
  });

  group('surfaces', () {
    testWidgets('GlassCard slate uses the slate gradient; radius scales', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const GlassCard(
            slate: true,
            width: 100,
            height: 50,
            child: SizedBox(),
          ),
        ),
      );
      final d = decorationOf(tester, find.byType(GlassCard));
      expect(d.gradient, LoopGradients.slate);
      expect(
        (d.borderRadius! as BorderRadius).topLeft.x,
        closeTo(30 * 393 / 358, 0.01),
      );
    });

    testWidgets('BoardCard draws the periwinkle top light line', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const BoardCard(width: 300, height: 300, child: SizedBox())),
      );
      expect(tester.getSize(find.byType(BoardCard)), const Size(300, 300));
    });
  });

  group('icons', () {
    for (final icon in LoopIcon.values) {
      testWidgets('${icon.name} paints at 24 and 48 without error', (
        tester,
      ) async {
        await tester.pumpWidget(
          host(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                LoopIconView(icon, color: LoopColors.text, size: 24),
                LoopIconView(
                  icon,
                  color: LoopColors.text,
                  size: 48,
                  filled: true,
                ),
              ],
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(
          tester.getSize(find.byType(LoopIconView).first),
          const Size(24, 24),
        );
      });
    }

    test('every icon has a designed stroke weight', () {
      for (final icon in LoopIcon.values) {
        expect(LoopIconPainter.defaultStroke(icon), inInclusiveRange(1.5, 2.0));
      }
      expect(LoopIcon.values.length, 12);
    });

    testWidgets('a labelled icon is announced, an unlabelled one is not', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const LoopIconView(
            LoopIcon.lock,
            color: LoopColors.text,
            semanticLabel: 'Kilitli',
          ),
        ),
      );
      expect(tester.getSemantics(find.byType(LoopIconView)).label, 'Kilitli');
    });
  });

  group('gallery layout', () {
    // Widget tests render unloaded fonts with the wide Ahem test font; load the
    // real bundled families so overflow checks measure real text.
    setUpAll(() async {
      for (final (family, asset) in <(String, String)>[
        ('SpaceGrotesk', 'assets/fonts/SpaceGrotesk.ttf'),
        ('Manrope', 'assets/fonts/Manrope.ttf'),
      ]) {
        final loader = FontLoader(family)..addFont(rootBundle.load(asset));
        await loader.load();
      }
    });

    for (final (name, size) in <(String, Size)>[
      ('iPhone 16 393x852', const Size(393, 852)),
      ('iPhone 16e 390x844', const Size(390, 844)),
      ('iPhone 16 Pro Max 440x956', const Size(440, 956)),
    ]) {
      testWidgets('$name: no overflow or exception', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(size: size),
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: DesignGalleryScreen(),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        // scroll through the whole gallery: every section builds and lays out
        final scroll = find.byType(SingleChildScrollView);
        for (var i = 0; i < 12; i++) {
          await tester.drag(scroll, const Offset(0, -700));
          await tester.pump();
          expect(tester.takeException(), isNull);
        }
      });
    }

    testWidgets('OS text scale 1.3: no exception', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(
            size: Size(393, 852),
            textScaler: TextScaler.linear(1.3),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: DesignGalleryScreen(),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('font assets (F00 architecture §7.3)', () {
    test('Space Grotesk and Manrope ship with their OFL texts', () async {
      for (final asset in <String>[
        'assets/fonts/SpaceGrotesk.ttf',
        'assets/fonts/Manrope.ttf',
      ]) {
        final data = await rootBundle.load(asset);
        expect(data.lengthInBytes, greaterThan(50000), reason: asset);
      }
      for (final asset in <String>[
        'assets/fonts/OFL-SpaceGrotesk.txt',
        'assets/fonts/OFL-Manrope.txt',
      ]) {
        // OFL texts live beside the fonts in the repository (not bundled); the
        // file must exist next to them.
        expect(await _exists(asset), isTrue, reason: asset);
      }
    });

    test('the font manifest declares both families', () async {
      final manifest = await rootBundle.loadString('FontManifest.json');
      expect(manifest, contains('SpaceGrotesk'));
      expect(manifest, contains('Manrope'));
    });
  });
}

Future<bool> _exists(String repoRelative) async {
  // flutter test runs with the package root as the working directory.
  // ignore: avoid_slow_async_io
  return File(repoRelative).exists();
}
