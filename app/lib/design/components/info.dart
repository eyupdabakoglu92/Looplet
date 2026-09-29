import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../tokens.dart';
import '../typography.dart';
import 'surfaces.dart';

/// Lime-on-olive badge (`HARİKA`, `YENİ EN İYİ`): pill + sparkle icon + caps label.
class LoopBadge extends StatelessWidget {
  const LoopBadge({
    required this.label,
    this.icon = LoopIcon.sparkle,
    super.key,
  });

  final String label;
  final LoopIcon? icon;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    return Semantics(
      label: label,
      // Without this, the icon (decorative) and the child `Text` (whose
      // content equals `label`) leak their own implicit semantics and the
      // label is announced twice (F00-FE-A11Y-REWORK QA-02).
      excludeSemantics: true,
      child: Container(
        height: 42 * s,
        padding: EdgeInsets.symmetric(horizontal: 17 * s),
        decoration: BoxDecoration(
          gradient: LoopGradients.badge,
          borderRadius: BorderRadius.circular(LoopRadii.pillFull),
          border: Border.all(color: LoopColors.badgeEdge),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              LoopIconView(icon!, color: LoopColors.limeMid, size: 18 * s),
              SizedBox(width: 7 * s),
            ],
            Text(label, style: LoopText.badge(s)),
          ],
        ),
      ),
    );
  }
}

/// The HAMLE (moves) card: counter over a caps label, 60 wide × a *minimum*
/// of 63 tall (F00-FE-A11Y-REWORK QA-01). Two protections, not one:
/// [loopCappedTextScaler] keeps the digits from ever needing more than the
/// fixed 60-pt width, and `minHeight` (not a fixed height) lets the card grow
/// a touch if it still needs more than 63 — a fixed height plus the text cap
/// alone was still 1.5 pt short on a real device at the OS accessibility-medium
/// floor; real font hinting doesn't match a widget test closely enough to
/// trust a hand-picked ceiling for the last pixel. At the default OS text
/// size this renders at exactly 60 × 63, identical to the old fixed size.
///
/// Above the default text size the card also grows *below* the label, by up
/// to [capGrowth]·s at the 1.3× cap (F03 architecture §19.10 (1),
/// F03-QA-D1-01). At the cap the label is almost as wide as the card, so it
/// must sit well clear of the 22·s bottom corner arcs, not just of the bottom
/// edge: without the growth its outer letters crossed the arcs from OS size
/// xxL up. The counter and label keep the positions they would have without
/// the growth and the card keeps its width, so it only lengthens downward.
/// Its glyph ink stays ≥ 2 pt inside the rounded rect at every OS size, in the
/// app's Material text context, where the counter inherits the theme's line
/// height (`moves_card_ink_test.dart`).
class MovesCard extends StatelessWidget {
  const MovesCard({required this.moves, this.label = 'HAMLE', super.key});

  final int moves;
  final String label;

  /// Extra height below the label at the 1.3× text cap, in design units (·s);
  /// proportional to the label's text scale in between, 0 at 1.0×.
  static const double capGrowth = 13;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    final capped = loopCappedTextScaler(context);
    // The label is the widest line, so its (possibly non-linear) scale sets
    // the growth.
    final labelSize = LoopText.label(s).fontSize!;
    final t = capped.scale(labelSize) / labelSize;
    final grow = capGrowth * s * ((t - 1) / 0.3).clamp(0.0, 1.0);
    return Semantics(
      label: '$label $moves',
      excludeSemantics: true,
      child: Container(
        width: 60 * s,
        constraints: BoxConstraints(minHeight: 63 * s + grow),
        // The growth is all below the column, which lays out as without it.
        padding: EdgeInsets.only(bottom: grow),
        decoration: BoxDecoration(
          gradient: LoopGradients.moves,
          borderRadius: BorderRadius.circular(22 * s),
          border: Border.all(color: const Color(0x17FFFFFF)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('$moves', style: LoopText.counter(s), textScaler: capped),
            SizedBox(height: 7 * s),
            Text(label, style: LoopText.label(s), textScaler: capped),
          ],
        ),
      ),
    );
  }
}

/// One cell of a [StatCard]: a value (optionally with a small earned star) over
/// a caps label. Numerals are tabular.
class StatCell {
  const StatCell({required this.value, required this.label, this.star = false});

  final String value;
  final String label;
  final bool star;
}

/// A card of value/label cells, at least 74 pt tall — `minHeight`, not a
/// fixed height, plus [loopCappedTextScaler] on each cell's texts (both
/// protections, see [MovesCard]; the cap matters more here since a cell's
/// *width* is fixed by its `Expanded` share and can't grow the way the
/// card's height can) (F00-FE-A11Y-REWORK QA-01).
class StatCard extends StatelessWidget {
  const StatCard({required this.cells, this.width, super.key});

  final List<StatCell> cells;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    final children = <Widget>[];
    for (var i = 0; i < cells.length; i++) {
      if (i > 0) {
        children.add(
          Container(width: 1, height: 44 * s, color: LoopColors.divider),
        );
      }
      final c = cells[i];
      children.add(
        Expanded(
          child: Semantics(
            label: '${c.label} ${c.value}',
            excludeSemantics: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      c.value,
                      style: LoopText.stat(s),
                      textScaler: loopCappedTextScaler(context),
                    ),
                    if (c.star)
                      Padding(
                        padding: EdgeInsets.only(left: 2 * s, top: 2 * s),
                        child: LoopIconView(
                          LoopIcon.star,
                          color: LoopColors.limeMid,
                          size: 12 * s,
                          filled: true,
                          strokeWidth: 1,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 9 * s),
                Text(
                  c.label,
                  style: LoopText.label(s),
                  textScaler: loopCappedTextScaler(context),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return GlassCard(
      slate: true,
      radius: 26,
      width: width,
      minHeight: 74 * s,
      padding: EdgeInsets.symmetric(horizontal: 6 * s),
      child: Row(children: children),
    );
  }
}

/// The five states of a loop-track node (F05 `ui-design.md` §7, D3; F05
/// architecture §18.7 ruling 2). Every state differs in fill *and* edge *and*
/// size, so none is colour-only.
enum LoopNodeState {
  /// A completed level: lime 38·s.
  done,

  /// Where the player is: periwinkle 58·s with the 76·s halo.
  current,

  /// Unlocked, not completed, not current: glass fill, solid periwinkle edge.
  open,

  /// Not yet unlocked: faint fill, dashed muted edge, muted numeral.
  locked,

  /// Level 30 once the whole Journey is complete: lime 58·s with a lime halo.
  finish,
}

/// A node of the loop track. `done` = lime rounded square, `current` = the
/// larger periwinkle square with a halo; D3 adds `open`, `locked` and `finish`
/// ([LoopNodeState]). The original call form `LoopNode(number:, current:)`
/// keeps its behaviour; [state] wins when given.
class LoopNode extends StatelessWidget {
  const LoopNode({
    required this.number,
    this.current = false,
    LoopNodeState? state,
    super.key,
  }) : _state = state;

  final int number;
  final bool current;
  final LoopNodeState? _state;

  /// The resolved state.
  LoopNodeState get state =>
      _state ?? (current ? LoopNodeState.current : LoopNodeState.done);

  /// Whether [state] is drawn large (58·s) with a 76·s halo.
  static bool isLarge(LoopNodeState state) =>
      state == LoopNodeState.current || state == LoopNodeState.finish;

  /// The widget's own square edge for [state] at scale [s]: the halo for the
  /// large states, the node itself otherwise.
  static double extentFor(LoopNodeState state, double s) =>
      (isLarge(state) ? 76 : 38) * s;

  // Local constants of this component (not tokens; §18.7 ruling 2): the open
  // and locked edges at .62 alpha clear 3 : 1 on the glass card
  // (`design/src/contrast-d3.txt`: 3.52 and 3.41).
  static const Color _openFill = Color(0x0FFFFFFF); // rgba(255,255,255,.06)
  static const Color _openEdge = Color(0x9EA8B4F9); // rgba(168,180,249,.62)
  static const Color _lockedFill = Color(0x09FFFFFF); // rgba(255,255,255,.035)
  static const Color _lockedEdge = Color(0x9EAEB4CA); // rgba(174,180,202,.62)
  static const Color _finishHalo = Color(0x1CDDFA6B); // rgba(221,250,107,.11)
  static const Color _finishHaloEdge = Color(0x4DDDFA6B); // .30

  /// The spoken state (§18.7 ruling 2): the bare digit does not say whether
  /// the stop is done or current, and colour is not available to a screen
  /// reader (F00-FE-A11Y-REWORK QA-02).
  static String spokenState(LoopNodeState state) => switch (state) {
    LoopNodeState.done || LoopNodeState.finish => 'tamamlandı',
    LoopNodeState.current => 'geçerli seviye',
    LoopNodeState.open => 'açık',
    LoopNodeState.locked => 'kilitli',
  };

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    final st = state;
    final large = isLarge(st);
    final size = (large ? 58 : 38) * s;
    final radius = size * 0.34;
    final numeral = Text(
      '$number',
      style: LoopText.node(
        (large ? 17 : 14) * s,
        color: switch (st) {
          LoopNodeState.open => LoopColors.text,
          LoopNodeState.locked => LoopColors.muted,
          _ => LoopColors.limeInk,
        },
      ),
      textScaler: loopCappedTextScaler(context),
    );
    final Widget node = switch (st) {
      LoopNodeState.done ||
      LoopNodeState.current ||
      LoopNodeState.finish => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: st == LoopNodeState.current
              ? LoopGradients.nodeCurrent
              : LoopGradients.nodeDone,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: switch (st) {
                LoopNodeState.current => LoopColors.periwinkleLow.withValues(
                  alpha: 0.45,
                ),
                LoopNodeState.finish => LoopColors.limeMid.withValues(
                  alpha: 0.34,
                ),
                _ => LoopColors.limeMid.withValues(alpha: 0.28),
              },
              blurRadius: (large ? 30 : 20) * s,
              offset: Offset(0, (large ? 12 : 8) * s),
            ),
          ],
        ),
        child: numeral,
      ),
      LoopNodeState.open => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _openFill,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: _openEdge, width: 1.5 * s),
        ),
        child: numeral,
      ),
      LoopNodeState.locked => CustomPaint(
        painter: DashedRRectPainter(
          color: _lockedEdge,
          radius: radius,
          strokeWidth: 1.5 * s,
          fill: _lockedFill,
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: numeral),
        ),
      ),
    };
    final child = large
        ? Container(
            width: 76 * s,
            height: 76 * s,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: st == LoopNodeState.finish
                  ? _finishHalo
                  : LoopColors.periwinkle.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(26 * s),
              border: Border.all(
                color: st == LoopNodeState.finish
                    ? _finishHaloEdge
                    : LoopColors.periwinkle.withValues(alpha: 0.25),
              ),
            ),
            child: node,
          )
        : node;
    return Semantics(
      label: '$number, ${spokenState(st)}',
      child: ExcludeSemantics(child: child),
    );
  }
}

/// A row of stars: earned = filled lime (no glow — one-glow rule), empty =
/// outline. The group is announced as "N / 3 yıldız".
///
/// [revealMs] is the Result's star reveal (F03 `ui-design.md` §16.5,
/// architecture §20.7 (6)): the time since the reveal began. Every star then
/// starts as an outline, and earned star `i` pops in over
/// `[i × popStagger, i × popStagger + popDuration]` — opacity 0 → 1 and scale
/// 0.6 → 1.18 (at 60 %) → 1, ease-out on each segment. `null` = static.
class StarRow extends StatelessWidget {
  const StarRow({
    required this.earned,
    this.total = 3,
    this.size = 19,
    this.gap = 14,
    this.starWord = 'yıldız',
    this.revealMs,
    super.key,
  });

  final int earned;
  final int total;
  final double size;
  final double gap;
  final String starWord;
  final double? revealMs;

  static const Duration popDuration = Duration(milliseconds: 140);
  static const Duration popStagger = Duration(milliseconds: 110);

  /// The whole reveal of three earned stars: 2 × 110 + 140 = 360 ms.
  static const Duration revealDuration = Duration(milliseconds: 360);

  static const Color _outline = Color(0x8CF4F6FF);

  /// Opacity and scale of one star's pop at [t] (0…1 of [popDuration]).
  static ({double opacity, double scale}) pop(double t) {
    final v = t.clamp(0.0, 1.0);
    if (v <= 0) return (opacity: 0, scale: 0.6);
    if (v < 0.6) {
      final k = Curves.easeOut.transform(v / 0.6);
      return (opacity: k, scale: 0.6 + (1.18 - 0.6) * k);
    }
    final k = Curves.easeOut.transform((v - 0.6) / 0.4);
    return (opacity: 1, scale: 1.18 + (1 - 1.18) * k);
  }

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    final reveal = revealMs;
    Widget star(int i) {
      final outline = LoopIconView(
        LoopIcon.star,
        color: _outline,
        size: size * s,
      );
      if (i >= earned) return outline;
      final filled = LoopIconView(
        LoopIcon.star,
        color: LoopColors.limeMid,
        size: size * s,
        filled: true,
      );
      if (reveal == null) return filled;
      final start = i * popStagger.inMilliseconds;
      final p = pop((reveal - start) / popDuration.inMilliseconds);
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          outline,
          if (p.opacity > 0)
            Opacity(
              opacity: p.opacity,
              child: Transform.scale(scale: p.scale, child: filled),
            ),
        ],
      );
    }

    return Semantics(
      label: '$earned / $total $starWord',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (var i = 0; i < total; i++) ...<Widget>[
              if (i > 0) SizedBox(width: gap * s),
              star(i),
            ],
          ],
        ),
      ),
    );
  }
}
