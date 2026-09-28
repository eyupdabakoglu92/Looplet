import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// An elliptical lime radial (F03 `ui-design.md` §16.5): the win bloom at the
/// row's board position (`radial-gradient(50% 60%, lime .30 → 0 at 70 %)`)
/// and the result's radial behind the answer row (`50% 50%, .13 → 0 at
/// 72 %`). The ellipse's radii are [radiusX] × width and [radiusY] × height,
/// centred in the box. Part of the single glow; decorative.
class LimeGlow extends StatelessWidget {
  const LimeGlow({
    required this.alpha,
    required this.stop,
    this.radiusX = 0.5,
    this.radiusY = 0.5,
    super.key,
  });

  /// The bloom: `.30` to 0 at 70 %, radii 50 % × 60 %.
  const LimeGlow.bloom({Key? key})
    : this(alpha: 0.30, stop: 0.70, radiusY: 0.6, key: key);

  /// The result radial: `.13` to 0 at 72 %, radii 50 % × 50 %.
  const LimeGlow.result({Key? key}) : this(alpha: 0.13, stop: 0.72, key: key);

  /// Opacity of the lime at the centre.
  final double alpha;

  /// Where the lime reaches 0, as a fraction of the radius.
  final double stop;
  final double radiusX;
  final double radiusY;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: CustomPaint(
        painter: _LimeGlowPainter(alpha, stop, radiusX, radiusY),
        size: Size.infinite,
      ),
    ),
  );
}

class _LimeGlowPainter extends CustomPainter {
  const _LimeGlowPainter(this.alpha, this.stop, this.radiusX, this.radiusY);

  final double alpha;
  final double stop;
  final double radiusX;
  final double radiusY;

  @override
  void paint(Canvas canvas, Size size) {
    final rx = size.width * radiusX;
    final ry = size.height * radiusY;
    if (rx <= 0 || ry <= 0) return;
    const unit = Rect.fromLTRB(-1, -1, 1, 1);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          LoopColors.limeMid.withValues(alpha: alpha),
          LoopColors.limeMid.withValues(alpha: 0),
        ],
        stops: <double>[0, stop],
      ).createShader(unit);
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..scale(rx, ry)
      ..drawRect(
        Rect.fromLTRB(
          -size.width / 2 / rx,
          -size.height / 2 / ry,
          size.width / 2 / rx,
          size.height / 2 / ry,
        ),
        paint,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_LimeGlowPainter old) =>
      old.alpha != alpha ||
      old.stop != stop ||
      old.radiusX != radiusX ||
      old.radiusY != radiusY;
}
