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
class MovesCard extends StatelessWidget {
  const MovesCard({required this.moves, this.label = 'HAMLE', super.key});

  final int moves;
  final String label;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    return Semantics(
      label: '$label $moves',
      excludeSemantics: true,
      child: Container(
        width: 60 * s,
        constraints: BoxConstraints(minHeight: 63 * s),
        decoration: BoxDecoration(
          gradient: LoopGradients.moves,
          borderRadius: BorderRadius.circular(22 * s),
          border: Border.all(color: const Color(0x17FFFFFF)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$moves',
              style: LoopText.counter(s),
              textScaler: loopCappedTextScaler(context),
            ),
            SizedBox(height: 7 * s),
            Text(
              label,
              style: LoopText.label(s),
              textScaler: loopCappedTextScaler(context),
            ),
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

/// A node of the loop track: done = lime rounded square, current = larger
/// periwinkle square with a halo.
class LoopNode extends StatelessWidget {
  const LoopNode({required this.number, this.current = false, super.key});

  final int number;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    final size = (current ? 58 : 38) * s;
    final node = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: current ? LoopGradients.nodeCurrent : LoopGradients.nodeDone,
        borderRadius: BorderRadius.circular(size * 0.34),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: current
                ? LoopColors.periwinkleLow.withValues(alpha: 0.45)
                : LoopColors.limeMid.withValues(alpha: 0.28),
            blurRadius: current ? 30 * s : 20 * s,
            offset: Offset(0, (current ? 12 : 8) * s),
          ),
        ],
      ),
      child: Text(
        '$number',
        style: LoopText.node((current ? 17 : 14) * s),
        textScaler: loopCappedTextScaler(context),
      ),
    );
    final child = current
        ? Container(
            width: 76 * s,
            height: 76 * s,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LoopColors.periwinkle.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(26 * s),
              border: Border.all(
                color: LoopColors.periwinkle.withValues(alpha: 0.25),
              ),
            ),
            child: node,
          )
        : node;
    // The bare digit doesn't say whether this stop is done or the current
    // one; the colour distinction alone isn't available to a screen reader
    // (F00-FE-A11Y-REWORK QA-02 note).
    return Semantics(
      label: current ? '$number, geçerli seviye' : '$number, tamamlandı',
      child: ExcludeSemantics(child: child),
    );
  }
}

/// A row of stars: earned = filled lime (no glow — one-glow rule), empty =
/// outline. The group is announced as "N / 3 yıldız".
class StarRow extends StatelessWidget {
  const StarRow({
    required this.earned,
    this.total = 3,
    this.size = 19,
    this.gap = 14,
    this.starWord = 'yıldız',
    super.key,
  });

  final int earned;
  final int total;
  final double size;
  final double gap;
  final String starWord;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    return Semantics(
      label: '$earned / $total $starWord',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (var i = 0; i < total; i++) ...<Widget>[
              if (i > 0) SizedBox(width: gap * s),
              LoopIconView(
                LoopIcon.star,
                color: i < earned
                    ? LoopColors.limeMid
                    : const Color(0x8CF4F6FF),
                size: size * s,
                filled: i < earned,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
