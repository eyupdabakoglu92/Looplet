import 'package:flutter/material.dart';

/// F03 design tokens — "Backlit board on a dark stage" (`ui-design.md` §5).
///
/// The play screen is the first real LOOPLET surface, so it carries its own
/// small visual system (colour / radius / motion) rather than leaning on the
/// bootstrap `ThemeData`. F10 owns the global app theme later; these tokens are
/// intentionally self-contained.
@immutable
class PlayTheme {
  const PlayTheme._();

  // --- stage ---------------------------------------------------------------
  static const Color stage0 = Color(0xFF0B0C16); // gradient top
  static const Color stage1 = Color(0xFF141322); // gradient bottom
  static const Color stageGlow = Color(0xFF2A2350); // radial spotlight
  static const Color plate = Color(0xFF0E0F1C); // recessed board panel

  // --- tiles ------------------------------------------------------------------
  static const Color tileHi = Color(0xFFF4EFE6); // neutral tile gradient top
  static const Color tileLo = Color(0xFFE7DFCF); // neutral tile gradient bottom
  static const Color ink = Color(0xFF1B1A24); // neutral-tile glyph

  static const Color amber = Color(0xFFFFC24B); // resolution / CTA
  static const Color amberLo = Color(0xFFFFB020);
  static const Color inkAmber = Color(0xFF2A1B00); // winning-tile glyph

  static const Color cyan = Color(0xFF5AA9FF); // active-drag energy / rails
  static const Color brass = Color(0xFFC9A24B); // locked pivot ring + glyph
  static const Color frost = Color(0xFFDCE8F2); // frozen tile fill
  static const Color frostLine = Color(0xFF9BC4E6); // frozen crystal border

  // --- text on the stage ---------------------------------------------------
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8A88A0); // labels, chevron, Close
  static const Color danger = Color(0xFFE06A5A); // debug load error only

  // --- completion panel / sheet (F03 seam → F04 realises) -----------------
  static const Color sheetSurface = Color(0xFF191A2B); // raised dark panel
  static const Color sheetHighlight = Color(0x14FFFFFF); // 1 px top edge
  static const Color sheetRecess = Color(0xFF12131F); // inset comparison track
  static const Color sheetScrim = Color(0x66000000); // ~40% over the dim board

  // --- geometry ----------------------------------------------------------------
  static const double boardWidthFraction =
      0.88; // of screen width (prd ~85–90%)
  static const double tileGap = 8; // 4/8 rhythm at reference width
  static const double platePadding = 10;
  static const double tileRadiusFraction = 0.19; // of tile size
  static const double zoneGap = 28; // target→board, board→HUD (fixed)
  static const double minTileSize = 56; // shrink floor before gaps compress

  // --- motion ------------------------------------------------------------------
  /// Shift animation duration (inside the product's 150–250 ms band).
  static const Duration shiftDuration = Duration(milliseconds: 190);

  /// Rejected-move rubber-band bounce-back.
  static const Duration bounceDuration = Duration(milliseconds: 140);

  /// Full bounded win choreography (`ui-design.md` §8 — ≤ ~600 ms).
  static const Duration winDuration = Duration(milliseconds: 600);

  /// Undo / restart grid swap — quick, not a full shift.
  static const Duration swapDuration = Duration(milliseconds: 120);

  /// `cubic-bezier(0.22, 1, 0.36, 1)` — fast out, soft settle.
  static const Cubic shiftCurve = Cubic(0.22, 1, 0.36, 1);
  static const Cubic bounceCurve = Cubic(0.4, 0, 0.2, 1);

  /// Opacity the HUD controls drop to while input is locked.
  static const double lockedControlsOpacity = 0.55;
  static const double wonControlsOpacity = 0.40;

  /// Dim overlay on non-active tiles during drag / animation.
  static const double inactiveTileDim = 0.08;

  // --- type ------------------------------------------------------------------
  static TextStyle tileLetter(double size) => TextStyle(
    fontSize: size * 0.46,
    fontWeight: FontWeight.w800,
    letterSpacing: size * 0.02,
    height: 1,
  );

  static const TextStyle movesNumber = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: paper,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    height: 1,
  );

  static const TextStyle microLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: muted,
    height: 1,
  );

  static const TextStyle completionWord = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: amber,
    letterSpacing: 2,
    height: 1.05,
  );

  static const TextStyle completionStat = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: paper,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    height: 1,
  );

  static const TextStyle helper = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: muted,
    height: 1.3,
  );

  /// A dark [ColorScheme] the app-level [MaterialApp] can adopt so the F08
  /// recovery screens still read correctly against the new stage palette.
  static ColorScheme get colorScheme => const ColorScheme.dark(
    primary: amber,
    onPrimary: inkAmber,
    secondary: cyan,
    surface: stage1,
    onSurface: paper,
    error: danger,
    outline: muted,
  );
}
