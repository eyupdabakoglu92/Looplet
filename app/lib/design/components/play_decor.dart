import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../tokens.dart';
import '../typography.dart';

// Play-surface decorations of the Loop Glass Play (F03 `ui-design.md` §7,
// Phase D1; allowed in the design layer by F03 architecture §19.8 (2)). Each
// is static: the Play screen drives their motion.

/// One rim rail of the active line: a 3·s periwinkle bar with a soft glow. The
/// board places two at the card's edges across the moving line — side edges
/// for a row ([Axis.vertical]), top and bottom for a column
/// ([Axis.horizontal]) — where the tiles wrap (`ui-design.md` §9 (2)).
class LineRail extends StatelessWidget {
  const LineRail({required this.length, this.axis = Axis.vertical, super.key});

  /// Length along the rail, in logical px (already scaled).
  final double length;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final thickness = 3 * LoopScale.of(context);
    final vertical = axis == Axis.vertical;
    return SizedBox(
      width: vertical ? thickness : length,
      height: vertical ? length : thickness,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: LoopColors.periwinkle,
          borderRadius: BorderRadius.circular(2),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: LoopColors.periwinkle, blurRadius: 14),
          ],
        ),
      ),
    );
  }
}

/// The column-tutorial ghost (`ui-design.md` §7): a 48·s periwinkle ring
/// centred on the tutorial cell, with the drawn up/down chevrons 42·s above
/// its centre. The widget is 48·s wide and 90·s tall; the ring's centre sits
/// 24·s above its bottom edge. Decorative — excluded from semantics.
class TutorialGhost extends StatelessWidget {
  const TutorialGhost({this.chevronOpacity = 1, super.key});

  /// The chevrons pulse 1 ↔ 0.6 while the ghost loops.
  final double chevronOpacity;

  /// Height of the widget in reference units (× s).
  static const double heightRef = 90;

  /// Distance from the widget's bottom edge to the ring's centre (× s).
  static const double ringCentreFromBottomRef = 24;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    return ExcludeSemantics(
      child: SizedBox(
        width: 48 * s,
        height: heightRef * s,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              left: 12 * s,
              top: 0,
              child: Opacity(
                opacity: chevronOpacity.clamp(0.0, 1.0),
                child: LoopIconView(
                  LoopIcon.upDown,
                  color: LoopColors.periwinkle,
                  size: 24 * s,
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                width: 48 * s,
                height: 48 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LoopColors.periwinkle.withValues(alpha: 0.28),
                  border: Border.all(
                    color: LoopColors.periwinkle,
                    width: 1.5,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: LoopColors.periwinkle.withValues(alpha: 0.6),
                      blurRadius: 26,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The tutorial hint pill (`ui-design.md` §7): glass, a lime sparkle and one
/// sentence, 300·s wide. Its text is capped at 1.3× (F03 architecture §19.3
/// (1)); above 1.15× the sparkle is hidden so the sentence keeps two lines, and
/// [compactAbove115] drops the vertical padding from 7·s to 5·s (the
/// pre-agreed fallback, §19.8 (3)).
class HintPill extends StatelessWidget {
  const HintPill({required this.text, this.compactAbove115 = false, super.key});

  final String text;
  final bool compactAbove115;

  /// The text-scale factor above which the sparkle is hidden.
  static const double iconThreshold = 1.15;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    final scaler = loopCappedTextScaler(context);
    final large = scaler.scale(100) / 100 > iconThreshold;
    final vPad = (large && compactAbove115 ? 5 : 7) * s;
    return Container(
      width: 300 * s,
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: vPad),
      decoration: BoxDecoration(
        gradient: LoopGradients.glass,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: LoopColors.glassEdge),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0x59020410),
            blurRadius: 30 * s,
            offset: Offset(0, 12 * s),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          if (!large) ...<Widget>[
            LoopIconView(
              LoopIcon.sparkle,
              color: LoopColors.limeMid,
              size: 20 * s,
            ),
            SizedBox(width: 10 * s),
          ],
          Expanded(
            child: Text(
              text,
              style: LoopText.bodyText(
                s,
                color: LoopColors.text,
              ).copyWith(fontSize: 13 * s, height: 1.2),
              textScaler: scaler,
            ),
          ),
        ],
      ),
    );
  }
}

/// A loading placeholder cell (`ui-design.md` §8 "Loading"): white 6 % with a
/// 7 % edge at the tile radius, at the exact final tile geometry.
class SkeletonCell extends StatelessWidget {
  const SkeletonCell({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(size * LoopRadii.tileFraction),
        border: Border.all(color: LoopColors.glassFillEdge),
      ),
    ),
  );
}
