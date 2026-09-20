import 'package:flutter/animation.dart';

import 'play_theme.dart';

/// The `won` moment's timeline (`ui-design.md` §16.2, `architecture.md` §18
/// "Won-sequence authority"). `T0` = the settle that yields `solvedThisStep`;
/// one [AnimationController] of [total] length drives every won-presentation
/// piece through the intervals below, so the ordering is a single source of
/// truth and is testable by pumping time.
///
/// Controller/persistence timing is **not** part of this: `completed` snapshot,
/// F04's personal-best write and F05's unlock stay triggered at `won` (§9/§10).
class WonTimeline {
  const WonTimeline._({
    required this.totalMs,
    required this.dockStartMs,
    required this.dockEndMs,
    required this.scrimStartMs,
    required this.scrimEndMs,
    required this.panelStartMs,
    required this.panelEndMs,
    required this.reduceMotion,
  });

  /// Regular: win sequence 0–600, dock 600–840, scrim 620–840, panel 680–940.
  static const WonTimeline regular = WonTimeline._(
    totalMs: 940,
    dockStartMs: 600,
    dockEndMs: 840,
    scrimStartMs: 620,
    scrimEndMs: 840,
    panelStartMs: 680,
    panelEndMs: 940,
    reduceMotion: false,
  );

  /// OS "reduce motion": static amber row + seam at T0, hold ≥ 300 ms, the row
  /// cross-fades (160 ms) to the dock, scrim + panel fade in (200 ms) from 460.
  static const WonTimeline reduced = WonTimeline._(
    totalMs: 660,
    dockStartMs: 300,
    dockEndMs: 460,
    scrimStartMs: 460,
    scrimEndMs: 660,
    panelStartMs: 460,
    panelEndMs: 660,
    reduceMotion: true,
  );

  final int totalMs;
  final int dockStartMs;
  final int dockEndMs;
  final int scrimStartMs;
  final int scrimEndMs;
  final int panelStartMs;
  final int panelEndMs;
  final bool reduceMotion;

  Duration get total => Duration(milliseconds: totalMs);

  static WonTimeline forReduceMotion(bool reduceMotion) =>
      reduceMotion ? reduced : regular;

  double _v(int ms) => ms / totalMs;

  double _interval(double v, int startMs, int endMs, Curve curve) => Interval(
    _v(startMs),
    _v(endMs),
    curve: curve,
  ).transform(v.clamp(0.0, 1.0));

  /// 0 → 1 while the answer row moves from its board slot to the dock (regular)
  /// or cross-fades in at the dock (reduced).
  double dock(double v) => _interval(
    v,
    dockStartMs,
    dockEndMs,
    reduceMotion ? Curves.linear : PlayTheme.shiftCurve,
  );

  /// 0 → 1: the 40 % scrim.
  double scrim(double v) =>
      _interval(v, scrimStartMs, scrimEndMs, Curves.easeOut);

  /// 0 → 1: the panel slide (regular) or fade (reduced).
  double panel(double v) => _interval(
    v,
    panelStartMs,
    panelEndMs,
    reduceMotion ? Curves.easeOut : PlayTheme.shiftCurve,
  );

  /// The board's winning row hands over to the docked overlay (its home cells
  /// become ghost outlines) from the moment the dock begins.
  bool dockStarted(double v) => v * totalMs >= dockStartMs;

  /// The panel is built from the moment its slide/fade begins — never before
  /// `T0 + 600 ms` (F03-QA-01 contract).
  bool panelStarted(double v) => v * totalMs >= panelStartMs;

  /// All won-presentation animation finished; the panel is at rest and the F04
  /// star reveal may start.
  bool atRest(double v) => v >= 1.0;
}

/// Where the docked answer row goes and how tall the panel may be
/// (`ui-design.md` §16.3). Pure, so the rule is unit-testable for any screen.
///
/// Coordinates: `screenHeight` and the `*Global` values are in the same global
/// space; results in `dockTopLocal` are relative to the stack (`stackTopGlobal`).
class WonGeometry {
  const WonGeometry({
    required this.dockTopLocal,
    required this.panelMaxHeight,
    required this.dockScale,
    required this.fits,
  });

  /// Gap between the divider under the target rail and the top of the dock.
  static const double dividerGap = 12;

  /// Minimum clearance between the docked unit's bottom and the panel top.
  static const double panelGap = 16;

  /// `panelTop ≥ 0.36 × H` ⇔ panel height ≤ 64 % of H (§16.3 panel cap).
  static const double panelTopFraction = 0.36;

  /// Docked unit = the tile row + the 3 pt seam bar 3 pt below it.
  static double unitHeight(double tile) => tile + 3 + 3;

  /// Top of the docked unit (row top) in stack-local coordinates.
  final double dockTopLocal;

  /// Max panel height so that its top stays at/below `0.36 H`.
  final double panelMaxHeight;

  /// 1.0 normally; < 1.0 only when the free zone is shorter than the unit
  /// (§16.3 fallback, floor 0.8).
  final double dockScale;

  /// `false` when even the 0.8 fallback does not fit — the caller must not let
  /// the panel cover the row; it logs / raises the clarification path.
  final bool fits;

  static WonGeometry compute({
    required double screenHeight,
    required double stackTopGlobal,
    required double stackBottomGlobal,
    required double dividerBottomLocal,
    required double tile,
  }) {
    final unit = unitHeight(tile);
    final zoneTop = stackTopGlobal + dividerBottomLocal + dividerGap;
    final zoneBottom = panelTopFraction * screenHeight - panelGap;
    final zone = zoneBottom - zoneTop;

    var scale = 1.0;
    var fits = true;
    if (zone < unit) {
      scale = (zone / unit).clamp(0.8, 1.0);
      fits = zone >= unit * 0.8;
    }
    final dockTopGlobal = zoneTop + (zone - unit * scale) / 2;
    return WonGeometry(
      dockTopLocal: dockTopGlobal - stackTopGlobal,
      panelMaxHeight: (stackBottomGlobal - panelTopFraction * screenHeight)
          .clamp(0.0, double.infinity),
      dockScale: scale,
      fits: fits,
    );
  }
}
