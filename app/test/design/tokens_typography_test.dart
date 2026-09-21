import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/design/design.dart';

/// F00.DS-AUTOMATED — the token values and type roles are the design's
/// (`ui-design.md` §7–§10, `design/S-91-components.png`). A change here is a
/// change to the Design Foundation, not a refactor.
void main() {
  group('colour roles', () {
    test('semantic separation: lime, periwinkle, cream', () {
      expect(LoopColors.lime, const Color(0xFFDDFA6B));
      expect(LoopColors.limeMid, const Color(0xFFD0EF58));
      expect(LoopColors.periwinkle, const Color(0xFFA8B4F9));
      expect(LoopColors.tileTop, const Color(0xFFFFFCF7));
      expect(LoopColors.tileInk, const Color(0xFF141826));
    });

    test('text and muted labels', () {
      expect(LoopColors.text, const Color(0xFFF4F6FF));
      expect(LoopColors.muted, const Color(0xFFAEB4CA));
    });

    test(
      'contrast of the label / ink pairs meets the design (ui-design §13)',
      () {
        double channel(double v) => v <= 0.03928
            ? v / 12.92
            : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
        double lum(Color c) =>
            0.2126 * channel(c.r) +
            0.7152 * channel(c.g) +
            0.0722 * channel(c.b);
        double ratio(Color a, Color b) {
          final x = lum(a), y = lum(b);
          return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
        }

        expect(
          ratio(LoopColors.muted, const Color(0xFF0A1030)),
          greaterThan(8.5),
        );
        expect(
          ratio(LoopColors.muted, const Color(0xFF2A345A)),
          greaterThan(4.5),
        );
        expect(
          ratio(LoopColors.limeInk, const Color(0xFFDCF868)),
          greaterThan(12),
        );
        expect(ratio(LoopColors.tileInk, LoopColors.tileTop), greaterThan(12));
      },
    );

    test('gradients keep their endpoints', () {
      expect(LoopGradients.cta.colors, <Color>[
        LoopColors.ctaTop,
        LoopColors.ctaBottom,
      ]);
      expect(LoopGradients.lime.colors, <Color>[
        LoopColors.limeTileTop,
        LoopColors.limeTileBottom,
      ]);
      expect(LoopGradients.tile.colors.first, LoopColors.tileTop);
    });
  });

  group('type roles', () {
    test('headings use Space Grotesk 500 through the weight axis', () {
      final s = LoopText.display(1);
      expect(s.fontFamily, LoopText.heading);
      expect(s.fontSize, 33);
      expect(s.height, 1.13);
      expect(s.fontVariations, contains(const FontVariation('wght', 500)));
    });

    test('body, CTA and captions use Manrope with the right weights', () {
      expect(LoopText.cta(1).fontFamily, LoopText.body);
      expect(LoopText.cta(1).fontSize, 16);
      expect(
        LoopText.caption(1).fontVariations,
        contains(const FontVariation('wght', 600)),
      );
      expect(LoopText.caption(1).letterSpacing, closeTo(0.2 * 11.5, 1e-9));
      expect(LoopText.bodyText(1).fontSize, 14.5);
    });

    test('numerals are tabular', () {
      for (final style in <TextStyle>[
        LoopText.stat(1),
        LoopText.counter(1),
        LoopText.tileGlyph(52),
      ]) {
        expect(
          style.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      }
    });

    test('HAMLE / stat label is raised to 11 pt (ui-design §17.3)', () {
      expect(LoopText.label(1).fontSize, 11);
    });

    test('tile glyph is 38 % of the tile edge', () {
      expect(LoopText.tileGlyph(52).fontSize, closeTo(19.76, 1e-9));
    });

    test('styles scale with the design scale', () {
      expect(LoopText.display(1.1).fontSize, closeTo(33 * 1.1, 1e-9));
    });
  });

  group('LoopScale', () {
    testWidgets('derives width / 358 clamped to 0.9–1.3', (tester) async {
      late double small, phone, huge;
      Widget probe(Size size, void Function(double) out) => MediaQuery(
        data: MediaQueryData(size: size),
        child: Builder(
          builder: (context) {
            out(LoopScale.of(context));
            return const SizedBox();
          },
        ),
      );
      await tester.pumpWidget(probe(const Size(200, 400), (v) => small = v));
      await tester.pumpWidget(probe(const Size(393, 852), (v) => phone = v));
      await tester.pumpWidget(probe(const Size(1000, 800), (v) => huge = v));
      expect(small, 0.9);
      expect(phone, closeTo(393 / 358, 1e-9));
      expect(huge, 1.3);
    });

    testWidgets('an explicit LoopScale wins', (tester) async {
      late double v;
      await tester.pumpWidget(
        LoopScale(
          value: 1,
          child: Builder(
            builder: (context) {
              v = LoopScale.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(v, 1);
    });
  });
}
