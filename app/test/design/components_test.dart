import 'dart:io';
import 'dart:ui' show SemanticsFlag;

import 'package:flutter/material.dart' show MaterialApp, Scaffold;
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

  group('accessibility rework (F00-FE-A11Y-REWORK)', () {
    testWidgets(
      'QA-02: every pressable and the badge are a single semantics node '
      '(no duplicate/merged label)',
      (tester) async {
        Future<void> checkSingle(
          Widget widget,
          Finder finder, {
          String? expectSubstring,
        }) async {
          await tester.pumpWidget(host(widget));
          final node = tester.getSemantics(finder);
          expect(
            node.childrenCount,
            0,
            reason:
                'no descendant semantics node under $finder — otherwise '
                'VoiceOver/TalkBack would stop on it a second time',
          );
          expect(
            node.label.contains('\n'),
            isFalse,
            reason:
                'label should not be a merged/duplicated string: '
                '"${node.label}"',
          );
          if (expectSubstring != null) {
            expect(node.label, contains(expectSubstring));
          }
        }

        await checkSingle(
          LimePill(label: 'Sonraki bölüm', onPressed: () {}, width: 300),
          find.byType(LimePill),
        );
        await checkSingle(
          OutlinePill(label: 'Secondary', onPressed: () {}, width: 300),
          find.byType(OutlinePill),
        );
        await checkSingle(
          const TextLink(label: 'Tekrar oyna', onPressed: null),
          find.byType(TextLink),
        );
        await checkSingle(
          GlassIconButton(
            icon: LoopIcon.back,
            onPressed: () {},
            semanticLabel: 'Ana ekrana dön',
          ),
          find.byType(GlassIconButton),
        );
        await checkSingle(
          UndoPill(quota: 2, onPressed: () {}, semanticLabel: 'Geri al'),
          find.byType(UndoPill),
          expectSubstring: '2 / 3',
        );
        await checkSingle(
          const LoopBadge(label: 'HARİKA'),
          find.byType(LoopBadge),
        );
      },
    );

    testWidgets(
      'QA-02: LoopNode announces done vs current, not just the number',
      (tester) async {
        await tester.pumpWidget(host(const LoopNode(number: 4)));
        expect(tester.getSemantics(find.byType(LoopNode)).label, contains('4'));
        expect(
          tester.getSemantics(find.byType(LoopNode)).label,
          isNot(equals('4')),
        );
        await tester.pumpWidget(host(const LoopNode(number: 5, current: true)));
        expect(
          tester.getSemantics(find.byType(LoopNode)).label,
          contains('geçerli'),
        );
      },
    );

    testWidgets(
      'QA-03: focus ring shows only while focused (no size change) and '
      'Enter/Space activates',
      (tester) async {
        FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.alwaysTraditional;
        addTearDown(
          () => FocusManager.instance.highlightStrategy =
              FocusHighlightStrategy.automatic,
        );
        var taps = 0;
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: LoopScale(
                  value: 1,
                  child: LimePill(
                    label: 'Sonraki bölüm',
                    onPressed: () => taps++,
                    width: 300,
                  ),
                ),
              ),
            ),
          ),
        );

        bool ringVisible() => tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .any((d) => d.position == DecorationPosition.foreground);

        final sizeUnfocused = tester.getSize(find.byType(LimePill));
        expect(ringVisible(), isFalse);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(ringVisible(), isTrue);
        expect(tester.getSize(find.byType(LimePill)), sizeUnfocused);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(taps, 1);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        expect(taps, 2);

        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        expect(ringVisible(), isFalse);
      },
    );
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
      expect(LoopIcon.values.length, 13);
      expect(LoopIconPainter.defaultStroke(LoopIcon.loopBreak), 1.8);
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

    // F00-FE-A11Y-REWORK (QA-01): the original coverage stopped at 1.3, just
    // under the 1.35 (xxxLarge) point where `MovesCard` first overflowed, and
    // well under 1.65 (accessibility-medium, the `platform.md` §14 floor)
    // where `MovesCard` and `StatCard` both did. `SingleChildScrollView` lays
    // out its whole child regardless of scroll position, so a single pump
    // already exercises every section — no drag needed to reach them.
    for (final scale in <double>[1.3, 1.35, 1.65, 2.35, 3.12]) {
      testWidgets('OS text scale ${scale}x: no exception', (tester) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(
              size: const Size(393, 852),
              textScaler: TextScaler.linear(scale),
            ),
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: DesignGalleryScreen(),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets(
      'QA-01: MovesCard, StatCard, LoopNode and LoopletWordmark hold their '
      'longest realistic content at any OS text scale',
      (tester) async {
        for (final scale in <double>[1.35, 1.65, 2.35, 3.12]) {
          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(
                size: const Size(393, 852),
                textScaler: TextScaler.linear(scale),
              ),
              child: const Directionality(
                textDirection: TextDirection.ltr,
                child: Center(
                  child: LoopScale(
                    value: 393 / 358,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        MovesCard(moves: 100),
                        StatCard(
                          width: 309,
                          cells: <StatCell>[
                            StatCell(value: '128', label: 'SEN'),
                            StatCell(value: '12', label: 'OPTİMAL'),
                            StatCell(value: '9', label: 'EN İYİ', star: true),
                          ],
                        ),
                        LoopNode(number: 30, current: true),
                        LoopletWordmark(fontSize: 44),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull, reason: 'scale=$scale');
        }
      },
    );

    testWidgets(
      'F00-FE-A11Y-REWORK2 (QA-04): display/headline stay capped at 1.3x '
      'regardless of OS text scale, so a long word never outgrows the line',
      (tester) async {
        for (final scale in <double>[1.3, 1.65, 2.35, 3.12]) {
          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(
                size: const Size(393, 852),
                textScaler: TextScaler.linear(scale),
              ),
              child: const Directionality(
                textDirection: TextDirection.ltr,
                child: DesignGalleryScreen(),
              ),
            ),
          );
          await tester.pump();

          final display = tester.widget<Text>(
            find.byWidgetPredicate(
              (w) => w is Text && w.data == 'Döngü\ntamamlandı.',
            ),
          );
          final headlines = tester.widgetList<Text>(
            find.byWidgetPredicate(
              (w) =>
                  w is Text &&
                  w.textSpan != null &&
                  w.textSpan!.toPlainText().contains('Sıradaki'),
            ),
          );
          expect(
            headlines,
            isNotEmpty,
            reason: 'expected both headline instances at scale=$scale',
          );
          for (final t in <Text>[display, ...headlines]) {
            expect(
              t.textScaler,
              isNotNull,
              reason: 'must pass loopCappedTextScaler explicitly',
            );
            expect(
              t.textScaler!.scale(100),
              closeTo(130, 0.5),
              reason:
                  'a $scale x OS scale must still resolve to the 1.3x cap '
                  '(scale=$scale)',
            );
          }
        }
      },
    );
  });

  group('D1 design-layer additions (F03 architecture §19.8 (2))', () {
    const s390 = 390 / 358;

    Widget scaled(Widget child, {double textScale = 1, Size? size}) =>
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: MediaQueryData(
              size: size ?? const Size(390, 844),
              textScaler: TextScaler.linear(textScale),
            ),
            child: LoopScale(
              value: s390,
              child: Center(child: child),
            ),
          ),
        );

    testWidgets('TileFace and RailTile glyphs are capped at 1.3× — no overflow '
        'at AX5 (3.12) on a 390-pt width (A-2)', (tester) async {
      await tester.pumpWidget(
        scaled(
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TileFace(letter: 'Ş', size: 52 * s390),
              TileFace(letter: 'İ', size: 52 * s390, state: TileState.locked),
              TileFace(letter: 'Ğ', size: 52 * s390, state: TileState.frozen),
              RailTile(letter: 'Ü'),
            ],
          ),
          textScale: 3.12,
        ),
      );
      expect(tester.takeException(), isNull);
      for (final text in tester.widgetList<Text>(find.byType(Text))) {
        expect(text.textScaler!.scale(100), closeTo(130, 0.01));
      }
      for (final letter in <String>['Ş', 'İ', 'Ğ']) {
        final glyph = tester.getRect(find.text(letter));
        final tile = tester.getRect(
          find.ancestor(of: find.text(letter), matching: find.byType(TileFace)),
        );
        expect(tile.contains(glyph.topLeft), isTrue, reason: letter);
        expect(tile.contains(glyph.bottomRight), isTrue, reason: letter);
      }
    });

    testWidgets('TileFace iconScale scales the corner icon about its centre', (
      tester,
    ) async {
      await tester.pumpWidget(
        scaled(
          const TileFace(
            letter: 'A',
            size: 57,
            state: TileState.frozen,
            iconScale: 0.6,
          ),
        ),
      );
      final scale = tester.widget<Transform>(
        find
            .ancestor(
              of: find.byType(LoopIconView),
              matching: find.byType(Transform),
            )
            .first,
      );
      expect(scale.transform.storage[0], closeTo(0.6, 1e-9)); // x scale
    });

    for (final (name, control) in <(String, Widget)>[
      (
        'GlassIconButton',
        GlassIconButton(
          icon: LoopIcon.restart,
          onPressed: () {},
          semanticLabel: 'Baştan',
        ),
      ),
      (
        'UndoPill',
        UndoPill(quota: 2, onPressed: () {}, semanticLabel: 'Geri al'),
      ),
    ]) {
      testWidgets('$name brightens fill .075 → .14 and edge .07 → .18 while '
          'pressed — also under reduced motion (fill only)', (tester) async {
        Color fill() =>
            decorationOf(tester, find.byType(control.runtimeType)).color!;
        Color edge() =>
            (decorationOf(tester, find.byType(control.runtimeType)).border!
                    as Border)
                .top
                .color;
        for (final reduced in <bool>[false, true]) {
          tester.platformDispatcher.accessibilityFeaturesTestValue =
              FakeAccessibilityFeatures(reduceMotion: reduced);
          await tester.pumpWidget(scaled(control));
          expect(fill(), LoopColors.glassFill);
          expect(edge(), LoopColors.glassFillEdge);
          final g = await tester.startGesture(
            tester.getCenter(find.byType(control.runtimeType)),
          );
          await tester.pump();
          expect(fill(), const Color(0x24FFFFFF));
          expect(edge(), LoopColors.outlineEdge);
          expect(
            tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
            reduced ? 1.0 : 0.98,
          );
          await g.up();
          await tester.pump(const Duration(milliseconds: 120));
          expect(fill(), LoopColors.glassFill);
        }
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      });
    }

    testWidgets(
      'UndoPill: a spent dot dims over 120 ms; instant when reduced',
      (tester) async {
        final dots = find.descendant(
          of: find.byType(UndoPill),
          matching: find.byType(AnimatedContainer),
        );
        await tester.pumpWidget(
          scaled(
            UndoPill(quota: 3, onPressed: () {}, semanticLabel: 'Geri al'),
          ),
        );
        expect(dots, findsNWidgets(3));
        expect(
          tester.widget<AnimatedContainer>(dots.first).duration,
          const Duration(milliseconds: 120),
        );
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(reduceMotion: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        await tester.pumpWidget(
          scaled(
            UndoPill(quota: 2, onPressed: () {}, semanticLabel: 'Geri al'),
          ),
        );
        expect(
          tester.widget<AnimatedContainer>(dots.first).duration,
          Duration.zero,
        );
      },
    );

    testWidgets('LoopBackButton: chevron + capped label, one ≥ 44 pt node', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        scaled(
          LoopBackButton(
            label: 'SEVİYE 26',
            semanticLabel: 'Geri, Seviye 26',
            padding: const EdgeInsets.only(left: 11, right: 8),
            onPressed: () => taps++,
          ),
          textScale: 3.12,
        ),
      );
      expect(tester.takeException(), isNull);
      final size = tester.getSize(find.byType(LoopBackButton));
      expect(size.height, greaterThanOrEqualTo(44));
      expect(size.width, greaterThanOrEqualTo(44));
      final icon = tester.widget<LoopIconView>(find.byType(LoopIconView));
      expect(icon.icon, LoopIcon.back);
      expect(icon.color, LoopColors.muted);
      final label = tester.widget<Text>(find.text('SEVİYE 26'));
      expect(label.textScaler!.scale(100), closeTo(130, 0.01));
      expect(label.style!.color, LoopColors.muted);
      final node = tester.getSemantics(find.byType(LoopBackButton));
      expect(node.label, 'Geri, Seviye 26');
      expect(node.childrenCount, 0);
      await tester.tap(find.byType(LoopBackButton));
      expect(taps, 1);
    });

    testWidgets('LineRail: a 3·s periwinkle bar with a glow, either axis', (
      tester,
    ) async {
      await tester.pumpWidget(
        scaled(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              LineRail(length: 40),
              LineRail(length: 40, axis: Axis.horizontal),
            ],
          ),
        ),
      );
      final rails = find.byType(LineRail);
      expect(tester.getSize(rails.first), const Size(3 * s390, 40));
      expect(tester.getSize(rails.last), const Size(40, 3 * s390));
      final d = decorationOf(tester, rails.first);
      expect(d.color, LoopColors.periwinkle);
      expect(d.boxShadow!.single.blurRadius, 14);
    });

    testWidgets('TutorialGhost: 48·s ring + up/down chevrons, decorative', (
      tester,
    ) async {
      await tester.pumpWidget(scaled(const TutorialGhost(chevronOpacity: 0.6)));
      expect(
        tester.getSize(find.byType(TutorialGhost)),
        const Size(48 * s390, 90 * s390),
      );
      final ring = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(TutorialGhost),
              matching: find.byType(Container),
            ),
          )
          .single;
      final d = ring.decoration! as BoxDecoration;
      expect(d.shape, BoxShape.circle);
      expect(d.border!.top.color, LoopColors.periwinkle);
      expect(
        (d.border! as Border).top.strokeAlign,
        BorderSide.strokeAlignOutside,
      );
      expect(
        tester.widget<LoopIconView>(find.byType(LoopIconView)).icon,
        LoopIcon.upDown,
      );
      expect(
        tester
            .widget<Opacity>(
              find.ancestor(
                of: find.byType(LoopIconView),
                matching: find.byType(Opacity),
              ),
            )
            .opacity,
        0.6,
      );
      expect(
        find.descendant(
          of: find.byType(TutorialGhost),
          matching: find.byType(ExcludeSemantics),
        ),
        findsWidgets,
      );
    });

    for (final scale in <double>[1.0, 1.15, 1.2, 1.3]) {
      testWidgets('HintPill at ${scale}x: 300·s glass, sparkle only up to '
          '1.15×, text capped', (tester) async {
        await tester.pumpWidget(
          scaled(
            const HintPill(
              text: 'Sütunları da kaydırabilirsin — yukarı ya da aşağı.',
            ),
            textScale: scale,
          ),
        );
        expect(tester.getSize(find.byType(HintPill)).width, 300 * s390);
        expect(
          decorationOf(tester, find.byType(HintPill)).gradient,
          LoopGradients.glass,
        );
        expect(
          find.byType(LoopIconView),
          scale > 1.15 ? findsNothing : findsOneWidget,
        );
        final text = tester.widget<Text>(find.byType(Text));
        expect(
          text.textScaler!.scale(100),
          closeTo(scale.clamp(1.0, 1.3) * 100, 0.01),
        );
      });
    }

    testWidgets('HintPill padding: 7·s, 5·s above 1.15× with the fallback', (
      tester,
    ) async {
      Future<double> padTop(double scale, {required bool compact}) async {
        await tester.pumpWidget(
          scaled(
            HintPill(text: 'Sütunları da', compactAbove115: compact),
            textScale: scale,
          ),
        );
        final c = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(HintPill),
                matching: find.byType(Container),
              )
              .first,
        );
        return (c.padding! as EdgeInsets).top;
      }

      expect(await padTop(1.3, compact: false), closeTo(7 * s390, 1e-9));
      expect(await padTop(1.3, compact: true), closeTo(5 * s390, 1e-9));
      expect(await padTop(1.0, compact: true), closeTo(7 * s390, 1e-9));
    });

    testWidgets('SkeletonCell: white 6 % with a 7 % edge at the tile radius', (
      tester,
    ) async {
      await tester.pumpWidget(scaled(const SkeletonCell(size: 57)));
      final d = decorationOf(tester, find.byType(SkeletonCell));
      expect(d.color, const Color(0x0FFFFFFF));
      expect(d.border!.top.color, LoopColors.glassFillEdge);
      expect(
        d.borderRadius,
        BorderRadius.circular(57 * LoopRadii.tileFraction),
      );
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
