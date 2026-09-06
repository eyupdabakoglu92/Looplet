import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:looplet_core/looplet_core.dart' show MoveAxis;
import 'package:looplet_engine/looplet_engine.dart';

/// Pure swipe → [Move] mapping (`architecture.md` §7). Widget-free and fully
/// unit-tested; the board widget calls [resolve] on pointer-up.
///
/// The exact numbers ([thresholdLogicalPx], [tieBandRatio]) are Frontend + QA
/// on-device tuning (`architecture.md` §18) — the defaults here are the F03-FE2
/// starting values and are exposed so QA can sweep them on the device matrix.
class GestureResolver {
  const GestureResolver({
    this.thresholdLogicalPx = 18,
    this.tieBandRatio = 0.15,
  }) : assert(thresholdLogicalPx > 0),
       assert(tieBandRatio >= 0 && tieBandRatio < 1);

  /// Minimum dominant-axis travel (logical px) before a swipe counts. Below
  /// this a tap or micro-drag is a no-op — `MOVES` never changes (AC4).
  final double thresholdLogicalPx;

  /// When `||dx| - |dy||` is within this fraction of the larger component the
  /// swipe is a near-diagonal "tie" and resolves to **horizontal**
  /// (`architecture.md` §7 — the Tech Lead resolution of the product's open
  /// diagonal-tie question).
  final double tieBandRatio;

  /// The [Move] a release from cell `(startRow, startCol)` with cumulative
  /// [delta] (pointer-up minus pointer-down, screen coords, y-down) maps to, or
  /// `null` for a below-threshold no-op.
  ///
  /// Exactly one cell, regardless of `delta` magnitude or flick velocity. The
  /// returned move may still be rejected by the engine (fully-immovable line,
  /// column moves disabled, …) — that is the caller's bounce-back path, not a
  /// concern here.
  Move? resolve({
    required int startRow,
    required int startCol,
    required Offset delta,
  }) {
    final adx = delta.dx.abs();
    final ady = delta.dy.abs();
    final maxMag = math.max(adx, ady);
    if (maxMag < thresholdLogicalPx) return null;

    final isTie = (adx - ady).abs() <= tieBandRatio * maxMag;
    final horizontal = isTie || adx >= ady;

    if (horizontal) {
      return delta.dx >= 0 ? Move.rowRight(startRow) : Move.rowLeft(startRow);
    }
    return delta.dy >= 0 ? Move.columnDown(startCol) : Move.columnUp(startCol);
  }

  /// The axis a drag past threshold is tracking, for the live "lift + rail"
  /// affordance while the finger is still down. Returns `null` while the drag is
  /// still below threshold (no line should lift yet).
  MoveAxis? trackingAxis(Offset delta) {
    final adx = delta.dx.abs();
    final ady = delta.dy.abs();
    final maxMag = math.max(adx, ady);
    if (maxMag < thresholdLogicalPx) return null;
    final isTie = (adx - ady).abs() <= tieBandRatio * maxMag;
    return (isTie || adx >= ady) ? MoveAxis.row : MoveAxis.column;
  }
}
