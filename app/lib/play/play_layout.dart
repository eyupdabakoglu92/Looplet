import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

import 'package:flutter/foundation.dart' show immutable;

import '../design/tokens.dart';

/// The Loop Glass Play geometry (F03 `ui-design.md` §6 and §11.5, F00
/// `ui-design.md` §6). Pure, so every rect is unit-testable for any screen.
///
/// The layout is authored in the 358 × 717 reference and scaled by width,
/// `s = W / 358`. The extra height `e = H − 717 s` goes 0.3 e above the goal
/// and board and 0.7 e above the HUD, so taller phones breathe instead of
/// stretching the board. All positions are in screen coordinates (the
/// reference includes the status-bar band).
///
/// On a frame wider than the reference aspect (widget tests, tablets) `s` is
/// capped by the height and the 358·s column is centred, so nothing overflows.
/// On the supported phones (390–440 pt wide) `s` is exactly `W / 358`.
@immutable
class PlayLayout {
  factory PlayLayout(Size screen) {
    final s = math.min(
      screen.width / LoopSpacing.referenceWidth,
      screen.height / referenceHeight,
    );
    final left = (screen.width - LoopSpacing.referenceWidth * s) / 2;
    final extra = math.max(0.0, screen.height - referenceHeight * s);
    return PlayLayout._(screen, s, left, extra);
  }

  const PlayLayout._(this.screen, this.s, this.left, this.extra);

  static const double referenceHeight = 717;

  final Size screen;

  /// The design scale `W / 358` (see the class comment).
  final double s;

  /// x of the reference column's left edge (0 on the supported phones).
  final double left;

  /// The extra height `e`.
  final double extra;

  double get e1 => 0.3 * extra;

  // --- header -----------------------------------------------------------------

  /// Top-left of the 20·s back chevron, (25, 96)·s.
  Offset get backIcon => Offset(left + 25 * s, 96 * s);

  /// The back control's hit box: ≥ 44 pt tall, centred on the chevron,
  /// starting 16 pt from the left edge (`ui-design.md` §6 App Chrome).
  double get backHitLeft => left + 16;
  double get backHitTop => backIcon.dy + 10 * s - 22;

  /// Chevron inset inside the hit box.
  double get backHitInset => backIcon.dx - backHitLeft;

  /// Top-left of the `HAMLE` card, (273.5, 75)·s.
  Offset get movesCard => Offset(left + 273.5 * s, 75 * s);

  // --- goal ---------------------------------------------------------------------

  /// Top of the `HEDEF DÖNGÜ` caption's glyph box, 172·s + 0.3 e.
  double get captionTop => 172 * s + e1;

  /// Top of the rail tiles, 197·s + 0.3 e.
  double get railTop => 197 * s + e1;

  /// Bottom of the rail tiles (42·s tall).
  double get railBottom => railTop + 42 * s;

  // --- board --------------------------------------------------------------------

  BoardGeometry get board => BoardGeometry(s);

  /// The board card: 308.5 × 307.5·s, centred, top 261.5·s + 0.3 e.
  Rect get boardRect => Rect.fromLTWH(
    left + (LoopSpacing.referenceWidth - BoardGeometry.cardWidthRef) / 2 * s,
    261.5 * s + e1,
    board.width,
    board.height,
  );

  // --- HUD ----------------------------------------------------------------------

  /// Top of the HUD band, 592.5·s + e.
  double get hudTop => 592.5 * s + extra;

  /// The undo pill: (29·s, hudTop), 98.5 × 50·s.
  Rect get undoRect => Rect.fromLTWH(left + 29 * s, hudTop, 98.5 * s, 50 * s);

  /// The restart square: 44 pt at x 289·s, centred on the undo pill.
  Rect get restartRect =>
      Rect.fromLTWH(left + 289 * s, hudTop + (50 * s - 44) / 2, 44, 44);

  /// The band the tutorial hint pill is centred in: board bottom → HUD top.
  Rect get hintBand =>
      Rect.fromLTRB(0, boardRect.bottom, screen.width, undoRect.top);
}

/// Board-card geometry (`ui-design.md` §6): card 308.5 × 307.5·s, padding
/// 11·s, tiles 52·s, gap 6.5·s. Everything scales with the card, so a rect of
/// the card alone is enough to find any cell ([BoardGeometry.forWidth]).
@immutable
class BoardGeometry {
  const BoardGeometry(this.s, {this.gridSize = 5});

  factory BoardGeometry.forWidth(double cardWidth, {int gridSize = 5}) =>
      BoardGeometry(cardWidth / cardWidthRef, gridSize: gridSize);

  static const double cardWidthRef = LoopSpacing.boardCardWidth;
  static const double cardHeightRef = 307.5;

  /// The tile grid's span in the reference: 2 × 11 + 5 × 52 + 4 × 6.5.
  static const double _gridSpanRef = 308;

  final double s;
  final int gridSize;

  double get width => cardWidthRef * s;
  double get height => cardHeightRef * s;
  double get pad => LoopSpacing.boardPadding * s;
  double get gap => LoopSpacing.tileGap * s;
  double get tile =>
      (_gridSpanRef -
          2 * LoopSpacing.boardPadding -
          (gridSize - 1) * LoopSpacing.tileGap) /
      gridSize *
      s;
  double get stride => tile + gap;

  /// Width of a full row of tiles.
  double get rowWidth => gridSize * tile + (gridSize - 1) * gap;

  /// Top-left of cell (row, col), card-local.
  Offset cellOrigin(int row, int col) =>
      Offset(pad + col * stride, pad + row * stride);

  Rect cellRect(int row, int col) => cellOrigin(row, col) & Size(tile, tile);

  Offset cellCenter(int row, int col) => cellRect(row, col).center;

  /// The cell under a card-local point (clamped to the grid).
  ({int row, int col}) cellAt(Offset local) => (
    row: ((local.dy - pad) / stride).floor().clamp(0, gridSize - 1),
    col: ((local.dx - pad) / stride).floor().clamp(0, gridSize - 1),
  );
}
