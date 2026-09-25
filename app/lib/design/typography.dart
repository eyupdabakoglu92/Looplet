import 'package:flutter/painting.dart';

import 'tokens.dart';

/// Type roles of the selected Design Foundation (ui-design §10): **Space
/// Grotesk** for display, headings, tile glyphs and numerals; **Manrope** for
/// body, labels and CTAs. Both are variable fonts, so every style selects the
/// weight axis explicitly with a [FontVariation] (the file default is the
/// lightest instance). Numerals use tabular figures.
///
/// Sizes are the 358-pt reference values; pass the scale from [LoopScale.of].
abstract final class LoopText {
  static const String heading = 'SpaceGrotesk';
  static const String body = 'Manrope';

  static const List<FontFeature> _tnum = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static TextStyle _sg(
    double size,
    double weight, {
    double? height,
    double letterSpacing = 0,
    Color color = LoopColors.text,
    List<FontFeature>? features,
  }) => TextStyle(
    fontFamily: heading,
    fontSize: size,
    fontWeight: _bucket(weight),
    fontVariations: <FontVariation>[FontVariation('wght', weight)],
    height: height,
    letterSpacing: letterSpacing,
    color: color,
    fontFeatures: features,
  );

  static TextStyle _mr(
    double size,
    double weight, {
    double? height,
    double letterSpacing = 0,
    Color color = LoopColors.text,
    List<FontFeature>? features,
  }) => TextStyle(
    fontFamily: body,
    fontSize: size,
    fontWeight: _bucket(weight),
    fontVariations: <FontVariation>[FontVariation('wght', weight)],
    height: height,
    letterSpacing: letterSpacing,
    color: color,
    fontFeatures: features,
  );

  /// Nearest `FontWeight` for semantics/fallback (the variation carries the real weight).
  static FontWeight _bucket(double w) {
    if (w < 350) return FontWeight.w300;
    if (w < 450) return FontWeight.w400;
    if (w < 550) return FontWeight.w500;
    if (w < 650) return FontWeight.w600;
    return FontWeight.w700;
  }

  /// "Döngü tamamlandı." — 33 / 1.13, 500.
  ///
  /// Callers pass `textScaler: loopCappedTextScaler(context)` on the `Text`/
  /// `Text.rich` itself (F00-FE-A11Y-REWORK2 QA-04): uncapped, a long Turkish
  /// word ("tamamlandı", "döngüyü") outgrows the line at extreme OS text
  /// scales (>= accessibility-extra-extra-extra-large, ~3.12x) before the
  /// whole sentence does, and Flutter's line breaker then splits that single
  /// word mid-character with no hyphen (observed: "tamamlandı." → "tama" /
  /// "mland" / "ı.", the trailing "ı." isolated on its own line) — not a
  /// widow, a forced mid-word break. The cap keeps every word inside the
  /// line at the cost of the text not growing past 1.3x; softWrap still lets
  /// the sentence itself take as many lines as it needs.
  static TextStyle display(double s) =>
      _sg(33 * s, 500, height: 1.13, letterSpacing: -0.005 * 33 * s);

  /// "Sıradaki döngüyü çöz." — 28 / 1.16, 500.
  ///
  /// Same `loopCappedTextScaler` requirement and reasoning as [display].
  static TextStyle headline(double s) =>
      _sg(28 * s, 500, height: 1.16, letterSpacing: -0.005 * 28 * s);

  /// Stat numeral — 24, 500, tabular.
  static TextStyle stat(double s) => _sg(24 * s, 500, features: _tnum);

  /// Moves counter — 22, 500, tabular.
  static TextStyle counter(double s) => _sg(22 * s, 500, features: _tnum);

  /// Tile glyph — 38 % of the tile edge, 500, tabular.
  static TextStyle tileGlyph(double tile, {Color color = LoopColors.tileInk}) =>
      _sg(tile * 0.38, 500, color: color, height: 1, features: _tnum);

  /// Node numeral (loop track).
  static TextStyle node(double size, {Color color = LoopColors.limeInk}) =>
      _sg(size, 500, color: color, height: 1, features: _tnum);

  /// Wordmark "Looplet" — 25, 500, −0.01 em.
  static TextStyle wordmark(double size, {Color color = LoopColors.text}) =>
      _sg(size, 500, color: color, height: 1, letterSpacing: -0.01 * size);

  /// CTA label — 16, 500.
  static TextStyle cta(double s, {Color color = LoopColors.limeInk}) =>
      _mr(16 * s, 500, height: 1, color: color);

  /// Body — 14.5, 500, muted by default.
  static TextStyle bodyText(double s, {Color color = LoopColors.muted}) =>
      _mr(14.5 * s, 500, height: 1.25, color: color);

  /// Link / secondary label — 15.5, 500.
  static TextStyle link(double s, {Color color = LoopColors.muted}) =>
      _mr(15.5 * s, 500, height: 1, color: color);

  /// Small caps label — 11.5, 600, +0.2 em. Author the string in uppercase
  /// (or use `turkishUpper`); never rely on locale-blind uppercasing.
  ///
  /// Line height 1.3, not 1.0 (F00-FE-A11Y-REWORK QA-04): at 1.0 a caption
  /// that wraps to two lines (long text, large OS text size) has its lines
  /// touch. 1.3 keeps a single line's position close to the original render
  /// while giving a wrapped one room.
  static TextStyle caption(double s, {Color color = LoopColors.muted}) => _mr(
    11.5 * s,
    600,
    height: 1.3,
    letterSpacing: 0.2 * 11.5 * s,
    color: color,
  );

  /// Stat/HAMLE small label — 11 (raised from the render's 10.4–10.5, ui-design
  /// §17.3), 600, +0.14 em.
  ///
  /// Height stays 1.0, unlike `caption` (QA-04 named both roles, but this one
  /// is only ever a short single word — SEN, OPTİMAL, HAMLE — inside the
  /// fixed 60 x 63 / 74-pt-tall `MovesCard`/`StatCard` boxes, capped by
  /// [loopCappedTextScaler]; it never reaches a second line, so there is
  /// nothing for a taller line height to protect, and raising it would only
  /// shrink those boxes' margin against their fixed token size for no gain.
  static TextStyle label(double s, {Color color = LoopColors.muted}) =>
      _mr(11 * s, 600, height: 1, letterSpacing: 0.14 * 11 * s, color: color);

  /// Badge label — 11, 600, +0.14 em, lime.
  static TextStyle badge(double s) => _mr(
    11 * s,
    600,
    height: 1,
    letterSpacing: 0.14 * 11 * s,
    color: LoopColors.limeMid,
  );
}
