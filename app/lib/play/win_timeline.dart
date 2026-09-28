import 'dart:math' as math;

import 'package:flutter/animation.dart';

/// `cubic-bezier(.22, 1, .36, 1)` — the glide / flight curve `E` of F03
/// `ui-design.md` §16.5.
const Cubic kGlideCurve = Cubic(0.22, 1, 0.36, 1);

double _seg(double ms, num start, num end, Curve curve) {
  if (ms <= start) return 0;
  if (ms >= end) return 1;
  return curve.transform((ms - start) / (end - start));
}

/// One band of the result's entrance: its opacity and how far below its rest
/// position it still is, in reference units (× s).
typedef BandMotion = ({double opacity, double rise});

/// The result's bands, in entrance order (F03 `ui-design.md` §16.5).
enum ResultBand {
  /// The fixed back button — fades, no rise.
  back,

  /// The badge row and the display headline.
  head,

  /// The data subtitle.
  sub,

  /// The stars (outline) and the stats card.
  stats,

  /// The primary pill and the secondary link.
  cta,
}

/// The `won` presentation — win sequence, board → result transition and the
/// star reveal — as a pure function of the time since `T0`, the settle that
/// yields `solvedThisStep` (F03 architecture §20.3 (1), `ui-design.md` §16.5
/// and §16.11.1). One `AnimationController` of [total] length drives every
/// piece, so the ordering is a single source of truth and testable by pumping
/// time.
///
/// Controller and persistence timing are **not** part of this: the
/// `completed` snapshot, F04's personal-best write and F05's unlock stay
/// triggered at `won` (§20.3 (3)).
class WinTimeline {
  const WinTimeline._(this.reduceMotion);

  static const WinTimeline regular = WinTimeline._(false);

  /// OS reduced motion (`reduceMotionRequested()`): the row is lime and static
  /// at T0; hold to 300; a 160 ms cross-fade (300–460); the content fades in
  /// 460–660; stars static; rest at 660.
  static const WinTimeline reduced = WinTimeline._(true);

  static WinTimeline forReduceMotion(bool reduceMotion) =>
      reduceMotion ? reduced : regular;

  final bool reduceMotion;

  /// Nothing outside the board may have opacity > 0 before this (§20.3 (1)).
  static const int resultStartMs = 600;

  /// Per-tile fill (90 ms) and its left-to-right stagger (30 ms).
  static const int fillMs = 90;
  static const int staggerMs = 30;

  /// The row glide, as one unit (600–840).
  static const int glideStartMs = 600;
  static const int glideEndMs = 840;

  /// The result is mounted (laid out at opacity 0) from here: inside the
  /// static hold (the row is lime, the bloom has settled), so its first build
  /// never lands on a moving frame, and its slot is laid out well before the
  /// glide at 600 (reduced: the cross-fade at 300).
  int get resultMountMs => reduceMotion ? 150 : 450;

  /// Rest: input unlocks (§20.3 (2)).
  int get restMs => reduceMotion ? 660 : 940;

  /// The controller's length — the star reveal runs after rest (940–1300).
  int get endMs => reduceMotion ? 660 : 1300;

  Duration get total => Duration(milliseconds: endMs);

  bool atRest(double ms) => ms >= restMs;

  /// Lime fill of answer tile [i] (0 → 1): 90 ms each, 30 ms apart, linear.
  double fill(double ms, int i) => reduceMotion
      ? 1
      : _seg(ms, i * staggerMs, i * staggerMs + fillMs, Curves.linear);

  /// The single bloom at the row's board position: 0 → 1 (100–240) → 0.55
  /// (–450), ease-out; then out with the board (600–720, ease-in). None
  /// under reduced motion.
  double bloom(double ms) {
    if (reduceMotion || ms < 100) return 0;
    if (ms < 240) return _seg(ms, 100, 240, Curves.easeOut);
    if (ms < 450) return 1 - 0.45 * _seg(ms, 240, 450, Curves.easeOut);
    if (ms < 600) return 0.55;
    return 0.55 * (1 - _seg(ms, 600, 720, Curves.easeIn));
  }

  /// The board (without the answer row) and every piece of Play chrome —
  /// header, `HAMLE`, goal rail, HUD, tutorial: 1 → 0.5 (0–200, ease-out),
  /// then 0.5 → 0 (600–720, ease-in). Reduced: 0.5 at T0, → 0 over 300–460.
  double chrome(double ms) {
    if (reduceMotion) return 0.5 * (1 - _seg(ms, 300, 460, Curves.linear));
    if (ms < 600) return 1 - 0.5 * _seg(ms, 0, 200, Curves.easeOut);
    return 0.5 * (1 - _seg(ms, 600, 720, Curves.easeIn));
  }

  /// The answer row's glide from its board cells to the result slot (0 → 1,
  /// curve `E`). Always 0 under reduced motion (the row does not travel).
  double glide(double ms) =>
      reduceMotion ? 0 : _seg(ms, glideStartMs, glideEndMs, kGlideCurve);

  /// Whether the travelling row (the overlay copy of the board row) is drawn;
  /// after this the result's own answer row takes over at the slot.
  bool overlayRow(double ms) => reduceMotion ? ms < 460 : ms < glideEndMs;

  /// Opacity of the overlay row: 1; under reduced motion it fades out in place
  /// (300–460) while the result row fades in.
  double overlayRowOpacity(double ms) =>
      reduceMotion ? 1 - _seg(ms, 300, 460, Curves.linear) : 1;

  /// Opacity of the result's own answer row.
  double resultRow(double ms) {
    if (reduceMotion) return _seg(ms, 300, 460, Curves.linear);
    return ms >= glideEndMs ? 1 : 0;
  }

  /// The lime radial behind the result row: 680–920 (ease); reduced 300–460.
  double radial(double ms) => reduceMotion
      ? _seg(ms, 300, 460, Curves.linear)
      : _seg(ms, 680, 920, Curves.ease);

  /// A band's entrance (fade + rise 12·s, ease-out): back / head 700–860,
  /// subtitle 740–900, stars + stats 780–940, CTA + link 820–940. Reduced:
  /// every band fades 460–660 (linear), no rise.
  BandMotion band(ResultBand band, double ms) {
    if (reduceMotion) {
      return (opacity: _seg(ms, 460, 660, Curves.linear), rise: 0);
    }
    final (int start, int end) = switch (band) {
      ResultBand.back || ResultBand.head => (700, 860),
      ResultBand.sub => (740, 900),
      ResultBand.stats => (780, 940),
      ResultBand.cta => (820, 940),
    };
    final t = _seg(ms, start, end, Curves.easeOut);
    return (opacity: t, rise: band == ResultBand.back ? 0 : 12 * (1 - t));
  }

  /// The star reveal clock (ms since 940), or `null` under reduced motion
  /// (static, already filled).
  double? starRevealMs(double ms) =>
      reduceMotion ? null : math.max(0, ms - restMs);
}

/// "Tekrar oyna": the result → Play transition A, "the answer returns to the
/// goal" (F03 `ui-design.md` §16.5, architecture §20.7 (1)). `T0` = the tap;
/// `retryFromCompletion()` has already restarted the grid.
class RetryTimeline {
  const RetryTimeline._(this.reduceMotion);

  static const RetryTimeline regular = RetryTimeline._(false);

  /// Reduced: a sequential dip — the result (row included) fades out 0–80,
  /// Play fades in 80–160; rest at 160.
  static const RetryTimeline reduced = RetryTimeline._(true);

  static RetryTimeline forReduceMotion(bool reduceMotion) =>
      reduceMotion ? reduced : regular;

  final bool reduceMotion;

  /// Rest: input unlocks (≤ 400, §20.3 (7)).
  int get restMs => reduceMotion ? 160 : 360;

  Duration get total => Duration(milliseconds: restMs);

  /// The result content, back button and radial: opacity and drop (× s) —
  /// 0–140 fade out + drop 8·s (ease-in); reduced 0–80 fade (linear).
  BandMotion resultOut(double ms) {
    if (reduceMotion) {
      return (opacity: 1 - _seg(ms, 0, 80, Curves.linear), rise: 0);
    }
    final t = _seg(ms, 0, 140, Curves.easeIn);
    return (opacity: 1 - t, rise: 8 * t);
  }

  /// Whether the flying row is drawn: it flies 0–300 and, having landed as
  /// the rail's own face, stays on the rail until rest, when the real rail
  /// tiles take over. Reduced: never — the row fades out with the result.
  bool flying(double ms) => !reduceMotion && ms < restMs;

  /// The flight from the result slot to the rail slots (0 → 1, curve `E`).
  double flight(double ms) => _seg(ms, 0, 300, kGlideCurve);

  /// The flying tiles' lime face over their rail face (1 → 0, 100–300).
  double flightLime(double ms) => 1 - _seg(ms, 100, 300, Curves.linear);

  /// Play on the restarted grid: 160–360 (ease-out); reduced 80–160.
  double playIn(double ms) => reduceMotion
      ? _seg(ms, 80, 160, Curves.linear)
      : _seg(ms, 160, 360, Curves.easeOut);

  /// The board card rises 10·s into place with [playIn] (× s).
  double boardRise(double ms) => reduceMotion ? 0 : 10 * (1 - playIn(ms));
}
