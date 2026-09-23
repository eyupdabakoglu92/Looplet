import 'package:flutter/widgets.dart';

/// Design tokens of the selected Design Foundation (Direction C — "Loop Glass",
/// `ai-system/project-authority/design-foundation.md` §17/§18) as specified by
/// `features/f00-design-foundation/ui-design.md` §7–§8 and the token sheet
/// `design/S-91-components.png`.
///
/// This layer is **new and parallel**: `PlayTheme` and every shipped surface are
/// untouched (F00 `architecture.md` §7.2). Colours were measured from the user's
/// reference screens (design-foundation §17.4); lime = resolution / emphasis /
/// primary action, periwinkle = where you are / the active row, cream = the tile.
abstract final class LoopColors {
  // ground
  static const Color groundTop = Color(0xFF0A1030);
  static const Color groundMid = Color(0xFF070C25);
  static const Color groundBottom = Color(0xFF050A1E);
  static const Color topLight = Color(0xFF2D3766);
  static const Color tealSpill = Color(0x521A5860);

  // text
  static const Color text = Color(0xFFF4F6FF);
  static const Color muted = Color(0xFFAEB4CA);

  // lime — resolution, emphasis word, primary action, earned star
  static const Color lime = Color(0xFFDDFA6B);
  static const Color limeMid = Color(0xFFD0EF58);
  static const Color limeTileTop = Color(0xFFE3FB7E);
  static const Color limeTileBottom = Color(0xFFCDEB4B);
  static const Color ctaTop = Color(0xFFE2FB78);
  static const Color ctaBottom = Color(0xFFD3F04F);
  static const Color limeInk = Color(0xFF0B1020);

  // periwinkle — current position, active row rim, current node
  static const Color periwinkle = Color(0xFFA8B4F9);
  static const Color periwinkleLow = Color(0xFF8792F0);
  static const Color nodeCurrentTop = Color(0xFFB9C3FF);

  // tile
  static const Color tileTop = Color(0xFFFFFCF7);
  static const Color tileBottom = Color(0xFFF0E9DC);
  static const Color tileActiveTop = Color(0xFFFFFFFF);
  static const Color tileActiveBottom = Color(0xFFF3EEE4);
  static const Color tileInk = Color(0xFF141826);

  // locked / frozen / rail
  static const Color lockedTop = Color(0xFF4149A0);
  static const Color lockedBottom = Color(0xFF2B3170);
  static const Color frozenTop = Color(0xFFDFF1FB);
  static const Color frozenBottom = Color(0xFFB5D6EC);
  static const Color frozenBorder = Color(0xFF3C6E9B);
  // solid ring inside the dashes
  static const Color frozenRing = Color(0xFF7FB0D6);
  static const Color frozenIcon = Color(0xFF3F78A8);
  static const Color railTop = Color(0xFF2B2B58);
  static const Color railBottom = Color(0xFF242349);
  static const Color railEdge = Color(0x52969FEB); // rgba(150,160,235,.32)

  // glass surfaces
  static const Color glassTop = Color(0x803C4A86); // rgba(60,74,134,.50)
  static const Color glassBottom = Color(0x94161E40); // rgba(22,30,64,.58)
  static const Color slateTop = Color(0x942E4054); // rgba(46,64,84,.58)
  static const Color slateBottom = Color(0xA8111928); // rgba(17,25,40,.66)
  static const Color boardTop = Color(0xDB161E40); // rgba(22,30,64,.86)
  static const Color boardBottom = Color(0xE0090E24); // rgba(9,14,36,.88)
  static const Color glassEdge = Color(0x1AFFFFFF); // rgba(255,255,255,.10)
  static const Color glassFill = Color(0x13FFFFFF); // rgba(255,255,255,.075)
  static const Color glassFillEdge = Color(0x12FFFFFF); // rgba(255,255,255,.07)
  static const Color movesTop = Color(0x577884C4); // rgba(120,132,196,.34)
  static const Color movesBottom = Color(0x4D46508C); // rgba(70,80,140,.30)
  static const Color divider = Color(0x1AFFFFFF);
  static const Color outlineEdge = Color(0x2EFFFFFF); // rgba(255,255,255,.18)

  // badge (olive glass)
  static const Color badgeTop = Color(0x429AB432);
  static const Color badgeBottom = Color(0x3D5A781E);
  static const Color badgeEdge = Color(0x6BD0EF58);

  // shadows
  static const Color shadow = Color(0x73020410); // rgba(2,4,16,.45)
  static const Color shadowDeep = Color(0x8C020410); // .55
}

/// Radii (ui-design §6/§7). Tiles use a fraction of their edge.
abstract final class LoopRadii {
  static const double card = 30;
  static const double boardCard = 34;
  static const double tileFraction = 0.33;
  static const double square = 15;
  static const double roundButton = 17;
  static const double pillFull = 999;
}

/// Reference-frame spacing, in points at the 358-pt reference width; multiply by
/// [LoopScale.of] (`width / 358`).
abstract final class LoopSpacing {
  static const double referenceWidth = 358;
  static const double gutter = 24;
  static const double boardCardWidth = 308.5;
  static const double boardPadding = 11;
  static const double tile = 52;
  static const double tileGap = 6.5;
  static const double ctaHeight = 63.5;
}

/// Ordered gradients used by several components.
abstract final class LoopGradients {
  static const LinearGradient glass = LinearGradient(
    begin: Alignment(-0.6, -1),
    end: Alignment(0.6, 1),
    colors: <Color>[LoopColors.glassTop, LoopColors.glassBottom],
  );
  static const LinearGradient slate = LinearGradient(
    begin: Alignment(-0.6, -1),
    end: Alignment(0.6, 1),
    colors: <Color>[LoopColors.slateTop, LoopColors.slateBottom],
  );
  static const LinearGradient board = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[LoopColors.boardTop, LoopColors.boardBottom],
  );
  static const LinearGradient tile = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[LoopColors.tileTop, LoopColors.tileBottom],
  );
  static const LinearGradient tileActive = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[LoopColors.tileActiveTop, LoopColors.tileActiveBottom],
  );
  static const LinearGradient lime = LinearGradient(
    begin: Alignment(-0.3, -1),
    end: Alignment(0.3, 1),
    colors: <Color>[LoopColors.limeTileTop, LoopColors.limeTileBottom],
  );
  static const LinearGradient cta = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[LoopColors.ctaTop, LoopColors.ctaBottom],
  );
  static const LinearGradient locked = LinearGradient(
    begin: Alignment(-0.3, -1),
    end: Alignment(0.3, 1),
    colors: <Color>[LoopColors.lockedTop, LoopColors.lockedBottom],
  );
  static const LinearGradient frozen = LinearGradient(
    begin: Alignment(-0.3, -1),
    end: Alignment(0.3, 1),
    colors: <Color>[LoopColors.frozenTop, LoopColors.frozenBottom],
  );
  static const LinearGradient rail = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[LoopColors.railTop, LoopColors.railBottom],
  );
  static const LinearGradient moves = LinearGradient(
    begin: Alignment(-0.6, -1),
    end: Alignment(0.6, 1),
    colors: <Color>[LoopColors.movesTop, LoopColors.movesBottom],
  );
  static const LinearGradient badge = LinearGradient(
    begin: Alignment(-0.6, -1),
    end: Alignment(0.6, 1),
    colors: <Color>[LoopColors.badgeTop, LoopColors.badgeBottom],
  );
  static const LinearGradient nodeDone = lime;
  static const LinearGradient nodeCurrent = LinearGradient(
    begin: Alignment(-0.3, -1),
    end: Alignment(0.3, 1),
    colors: <Color>[LoopColors.nodeCurrentTop, LoopColors.periwinkleLow],
  );
}

/// The design-system scale factor `width / 358`, clamped to the supported phone
/// range (390–440 pt wide ≈ 1.09–1.23). Provide a [LoopScale] to override
/// (tests, gallery variants); otherwise it is derived from the media width.
class LoopScale extends InheritedWidget {
  const LoopScale({required this.value, required super.child, super.key});

  final double value;

  static double of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LoopScale>();
    if (scope != null) return scope.value;
    final width = MediaQuery.sizeOf(context).width;
    return (width / LoopSpacing.referenceWidth).clamp(0.9, 1.3);
  }

  @override
  bool updateShouldNotify(LoopScale oldWidget) => value != oldWidget.value;
}

/// A scale ceiling for compact, fixed-geometry pieces (a card numeral/label,
/// the wordmark) so OS Dynamic Type still grows them, but never past a size
/// their token box can hold (F00-FE-A11Y-REWORK, QA-01). Capped at 1.3 — the
/// top of the OS *standard* content-size range, just below where the
/// Accessibility sizes begin — verified with no `RenderFlex` overflow up to
/// the largest OS accessibility size (`components_test.dart`). The reading
/// itself stays available at full OS size through VoiceOver/TalkBack: every
/// piece this is used on carries its own `Semantics` label read from the
/// value, not from the glyphs.
///
/// Not used on primary actionable text (button/link labels): those grow with
/// the full OS scale and their container reflows instead (`LimePill`,
/// `OutlinePill`).
TextScaler loopCappedTextScaler(BuildContext context) =>
    MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);
