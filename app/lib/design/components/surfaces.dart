import 'package:flutter/widgets.dart';

import '../tokens.dart';

/// Frosted-glass card (ui-design §7): gradient + 1 px edge + soft shadow. No
/// backdrop blur (F03 architecture §18 performance clarification) — the glass
/// is a gradient, an edge and a shadow. `slate` is the stat-card variant.
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.slate = false,
    this.radius = LoopRadii.card,
    this.padding,
    this.width,
    this.height,
    super.key,
  });

  final Widget child;
  final bool slate;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        gradient: slate ? LoopGradients.slate : LoopGradients.glass,
        borderRadius: BorderRadius.circular(radius * s),
        border: Border.all(color: LoopColors.glassEdge),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0x59020410),
            blurRadius: 60 * s,
            offset: Offset(0, 24 * s),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// The darker card that holds the 5 × 5 board, with the periwinkle top light line.
class BoardCard extends StatelessWidget {
  const BoardCard({required this.child, this.width, this.height, super.key});

  final Widget child;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    return Stack(
      children: <Widget>[
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LoopGradients.board,
            borderRadius: BorderRadius.circular(LoopRadii.boardCard * s),
            border: Border.all(color: const Color(0x17FFFFFF)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0x66020410),
                blurRadius: 60 * s,
                offset: Offset(0, 26 * s),
              ),
            ],
          ),
          child: child,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 144 * s,
              height: 2 * s,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Color(0x008792F0),
                    LoopColors.periwinkleLow,
                    Color(0x008792F0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The page ground: deep navy gradient, a soft light top-right and a faint teal
/// spill left-middle (ui-design §10 Background). The lights are circular
/// radial gradients — an approximation of the design's elliptical ones.
class LoopBackdrop extends StatelessWidget {
  const LoopBackdrop({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            LoopColors.groundTop,
            LoopColors.groundMid,
            LoopColors.groundBottom,
          ],
          stops: <double>[0, 0.55, 1],
        ),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -0.88),
            radius: 0.85,
            colors: <Color>[Color(0xB32D3766), Color(0x002D3766)],
            stops: <double>[0, 0.72],
          ),
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-1, 0.16),
              radius: 0.6,
              colors: <Color>[LoopColors.tealSpill, Color(0x001A5860)],
              stops: <double>[0, 0.72],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
