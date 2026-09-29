import 'dart:math' as math;
import 'dart:ui' show Size;

import 'package:flutter/foundation.dart' show immutable;

import '../design/tokens.dart';

/// The Home / shell geometry (F05 `ui-design.md` §6): authored in the
/// 358 × 717 reference and scaled by width, `s = W / 358`, with the spare
/// height `e = H − 717·s`. Positions are in screen coordinates (the reference
/// includes the status-bar band), like `PlayLayout`.
///
/// On a frame wider than the reference aspect (widget tests, tablets) `s` is
/// capped by the height and the 358·s column is centred. On the supported
/// phones (390–440 pt wide) `s` is exactly `W / 358`.
@immutable
class ShellLayout {
  factory ShellLayout(Size screen) {
    final s = math.min(
      screen.width / LoopSpacing.referenceWidth,
      screen.height / referenceHeight,
    );
    final left = (screen.width - LoopSpacing.referenceWidth * s) / 2;
    final extra = math.max(0.0, screen.height - referenceHeight * s);
    return ShellLayout._(screen, s, left, extra);
  }

  const ShellLayout._(this.screen, this.s, this.left, this.extra);

  static const double referenceHeight = 717;

  final Size screen;

  /// The design scale.
  final double s;

  /// x of the reference column's left edge (0 on the supported phones).
  final double left;

  /// The spare height `e`.
  final double extra;

  /// The wordmark's top-left, (25, 58)·s — the same on the splash, Home and
  /// the store-error screen (ui-design §4 sibling parity).
  double get wordmarkLeft => left + 25 * s;
  double get wordmarkTop => 58 * s;

  /// The wordmark's font size, 25·s.
  double get wordmarkSize => 25 * s;

  /// Home's content column: left 24·s, width 309·s, top `115·s + 0.1·e`.
  double get homeColumnLeft => left + 24 * s;
  double get homeColumnWidth => 309 * s;
  double get homeColumnTop => 115 * s + 0.1 * extra;

  /// The store-error column band: 118·s … `H − 40·s`, left 24.5·s.
  double get errorBandTop => 118 * s;
  double get errorBandBottom => screen.height - 40 * s;
  double get errorColumnLeft => left + 24.5 * s;
}
