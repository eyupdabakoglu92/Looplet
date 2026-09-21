import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../tokens.dart';
import '../typography.dart';

/// Tile states of the selected Design Foundation (ui-design §8). State is never
/// colour-only: active = lift + periwinkle rim; winning = lime + the single
/// glow; locked = indigo + lock icon; frozen = ice + snowflake + dashed border.
enum TileState { normal, active, winning, locked, frozen, inactive }

class TileFace extends StatelessWidget {
  const TileFace({
    required this.letter,
    required this.size,
    this.state = TileState.normal,
    this.height,
    this.radius,
    super.key,
  });

  final String letter;

  /// Tile width in logical px (already scaled).
  final double size;

  /// Defaults to [size] (square); the Result answer tiles are taller than wide.
  final double? height;
  final double? radius;
  final TileState state;

  @override
  Widget build(BuildContext context) {
    final h = height ?? size;
    final r = radius ?? size * LoopRadii.tileFraction;
    final glyphColor = switch (state) {
      TileState.winning => LoopColors.limeInk,
      TileState.locked => LoopColors.text,
      _ => LoopColors.tileInk,
    };
    final gradient = switch (state) {
      TileState.active => LoopGradients.tileActive,
      TileState.winning => LoopGradients.lime,
      TileState.locked => LoopGradients.locked,
      TileState.frozen => LoopGradients.frozen,
      _ => LoopGradients.tile,
    };
    final shadows = switch (state) {
      TileState.active => <BoxShadow>[
        BoxShadow(
          color: LoopColors.periwinkle.withValues(alpha: 0.6),
          blurRadius: 26,
        ),
        const BoxShadow(
          color: LoopColors.shadowDeep,
          blurRadius: 26,
          offset: Offset(0, 16),
        ),
      ],
      TileState.winning => <BoxShadow>[
        BoxShadow(
          color: LoopColors.limeMid.withValues(alpha: 0.34),
          blurRadius: 26,
          offset: const Offset(0, 10),
        ),
      ],
      _ => <BoxShadow>[
        const BoxShadow(
          color: LoopColors.shadow,
          blurRadius: 16,
          offset: Offset(0, 7),
        ),
      ],
    };
    final border = switch (state) {
      TileState.active => Border.all(color: LoopColors.periwinkle, width: 2),
      TileState.locked => Border.all(
        color: LoopColors.periwinkle.withValues(alpha: 0.55),
        width: 1.5,
      ),
      // 1.5 pt dashes (painted below) over a 1.5 pt solid ring, as in the
      // source render's `border: dashed` + `inset` ring (S-91 / C-03).
      TileState.frozen => Border.all(color: LoopColors.frozenRing, width: 3),
      _ => null,
    };
    Widget tile = SizedBox(
      width: size,
      height: h,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(r),
              border: border,
              boxShadow: shadows,
            ),
          ),
          if (state == TileState.frozen)
            CustomPaint(
              painter: DashedRRectPainter(
                color: LoopColors.frozenBorder.withValues(alpha: 0.75),
                radius: r,
              ),
            ),
          Center(
            child: Text(
              letter,
              style: LoopText.tileGlyph(size, color: glyphColor),
            ),
          ),
          if (state == TileState.locked || state == TileState.frozen)
            Positioned(
              top: size * 0.08,
              right: size * 0.08,
              child: LoopIconView(
                state == TileState.locked ? LoopIcon.lock : LoopIcon.snowflake,
                color: state == TileState.locked
                    ? LoopColors.text
                    : LoopColors.frozenIcon,
                size: size * 0.27,
              ),
            ),
        ],
      ),
    );
    if (state == TileState.inactive) tile = Opacity(opacity: 0.42, child: tile);
    return tile;
  }
}

/// The dashed outline left where the winning row lifted off (ui-design §8).
class GhostSlot extends StatelessWidget {
  const GhostSlot({required this.size, this.height, this.radius, super.key});

  final double size;
  final double? height;
  final double? radius;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: height ?? size,
    child: CustomPaint(
      painter: DashedRRectPainter(
        color: LoopColors.lime.withValues(alpha: 0.5),
        fill: LoopColors.lime.withValues(alpha: 0.05),
        radius: radius ?? size * LoopRadii.tileFraction,
      ),
    ),
  );
}

/// A tile of the target-word rail (dark, 36 × 42 at the reference).
class RailTile extends StatelessWidget {
  const RailTile({required this.letter, super.key});

  final String letter;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    return Container(
      width: 36 * s,
      height: 42 * s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LoopGradients.rail,
        borderRadius: BorderRadius.circular(14 * s),
        border: Border.all(color: LoopColors.railEdge),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0x59020410),
            blurRadius: 14 * s,
            offset: Offset(0, 6 * s),
          ),
        ],
      ),
      child: Text(
        letter,
        style: LoopText.node(16.5 * s, color: LoopColors.text),
      ),
    );
  }
}
