import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The drawn thin-outline icon set of the selected Design Foundation
/// (ui-design §7, `design/S-91-components.png` icon row). It replaces the
/// Material Icons placeholders (`chevron_left_rounded`, `refresh_rounded`,
/// `undo_rounded`, `push_pin`, `unfold_more_rounded`, `error_outline_rounded`)
/// as each surface is reworked. Drawn in Dart from the design's 24 × 24 paths —
/// no icon package, no font (F00 `architecture.md` §7.4).
enum LoopIcon {
  back,
  sliders,
  flame,
  sparkle,
  star,
  undo,
  restart,
  arrowUpRight,
  arrowRight,
  lock,
  snowflake,
  upDown,
}

class LoopIconView extends StatelessWidget {
  const LoopIconView(
    this.icon, {
    required this.color,
    this.size = 20,
    this.strokeWidth,
    this.filled = false,
    this.semanticLabel,
    super.key,
  });

  final LoopIcon icon;
  final Color color;
  final double size;

  /// Stroke in 24-unit viewBox coordinates; defaults to the icon's designed weight.
  final double? strokeWidth;

  /// Only meaningful for [LoopIcon.star] (earned star) and [LoopIcon.lock].
  final bool filled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final painter = CustomPaint(
      size: Size.square(size),
      painter: LoopIconPainter(
        icon,
        color: color,
        strokeWidth: strokeWidth,
        filled: filled,
      ),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: painter);
    return Semantics(label: semanticLabel, image: true, child: painter);
  }
}

class LoopIconPainter extends CustomPainter {
  const LoopIconPainter(
    this.icon, {
    required this.color,
    this.strokeWidth,
    this.filled = false,
  });

  final LoopIcon icon;
  final Color color;
  final double? strokeWidth;
  final bool filled;

  static double defaultStroke(LoopIcon icon) => switch (icon) {
    LoopIcon.back ||
    LoopIcon.arrowUpRight ||
    LoopIcon.arrowRight ||
    LoopIcon.lock ||
    LoopIcon.upDown => 1.9,
    LoopIcon.snowflake => 1.7,
    LoopIcon.star => 1.6,
    _ => 1.7,
  };

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth ?? defaultStroke(icon)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    switch (icon) {
      case LoopIcon.back:
        canvas.drawPath(
          Path()
            ..moveTo(15, 5)
            ..lineTo(8, 12)
            ..lineTo(15, 19),
          stroke,
        );
      case LoopIcon.sliders:
        canvas
          ..drawPath(
            Path()
              ..moveTo(4, 7)
              ..lineTo(12, 7)
              ..moveTo(18, 7)
              ..lineTo(20, 7)
              ..moveTo(4, 17)
              ..lineTo(6, 17)
              ..moveTo(12, 17)
              ..lineTo(20, 17),
            stroke,
          )
          ..drawCircle(const Offset(15, 7), 2.6, stroke)
          ..drawCircle(const Offset(9, 17), 2.6, stroke);
      case LoopIcon.flame:
        canvas.drawPath(
          Path()
            ..moveTo(12, 3)
            ..cubicTo(12.8, 6.2, 17.4, 8, 17.4, 13)
            ..arcToPoint(
              const Offset(6.6, 13),
              radius: const Radius.circular(5.4),
              clockwise: true,
            )
            ..cubicTo(6.6, 11, 7.6, 9.6, 8.8, 8.6)
            ..cubicTo(9.0, 10.3, 9.8, 11.2, 11.0, 11.4)
            ..cubicTo(10.2, 8.4, 10.6, 5.4, 12, 3)
            ..close(),
          stroke,
        );
      case LoopIcon.sparkle:
        canvas
          ..drawPath(
            Path()
              ..moveTo(10, 4.5)
              ..lineTo(12, 10)
              ..lineTo(17.5, 12)
              ..lineTo(12, 14)
              ..lineTo(10, 19.5)
              ..lineTo(8, 14)
              ..lineTo(2.5, 12)
              ..lineTo(8, 10)
              ..close(),
            stroke,
          )
          ..drawPath(
            Path()
              ..moveTo(19, 3.5)
              ..lineTo(19, 7.5)
              ..moveTo(17, 5.5)
              ..lineTo(21, 5.5),
            stroke,
          );
      case LoopIcon.star:
        final star = Path()
          ..moveTo(12, 2.2)
          ..lineTo(14.8, 8.8)
          ..lineTo(22, 9.5)
          ..lineTo(16.6, 14.2)
          ..lineTo(18.2, 21.2)
          ..lineTo(12, 17.5)
          ..lineTo(5.8, 21.2)
          ..lineTo(7.4, 14.2)
          ..lineTo(2, 9.5)
          ..lineTo(9.2, 8.8)
          ..close();
        if (filled) canvas.drawPath(star, fill);
        canvas.drawPath(star, stroke);
      case LoopIcon.undo:
        canvas
          ..drawPath(
            Path()
              ..moveTo(9, 14)
              ..lineTo(4, 9)
              ..lineTo(9, 4),
            stroke,
          )
          ..drawPath(
            Path()
              ..moveTo(4, 9)
              ..lineTo(13.5, 9)
              ..arcToPoint(
                const Offset(13.5, 22),
                radius: const Radius.circular(6.5),
                clockwise: true,
              )
              ..lineTo(10, 22),
            stroke,
          );
      case LoopIcon.restart:
        canvas
          ..drawPath(
            Path()
              ..moveTo(3.5, 12)
              ..arcToPoint(
                const Offset(6.2, 5.8),
                radius: const Radius.circular(8.5),
                largeArc: true,
                clockwise: false,
              )
              ..lineTo(3.5, 8.4),
            stroke,
          )
          ..drawPath(
            Path()
              ..moveTo(3.5, 3.6)
              ..lineTo(3.5, 8.4)
              ..lineTo(8.3, 8.4),
            stroke,
          );
      case LoopIcon.arrowUpRight:
        canvas
          ..drawPath(
            Path()
              ..moveTo(7, 17)
              ..lineTo(17, 7),
            stroke,
          )
          ..drawPath(
            Path()
              ..moveTo(8.5, 7)
              ..lineTo(17, 7)
              ..lineTo(17, 15.5),
            stroke,
          );
      case LoopIcon.arrowRight:
        canvas
          ..drawPath(
            Path()
              ..moveTo(5, 12)
              ..lineTo(19, 12),
            stroke,
          )
          ..drawPath(
            Path()
              ..moveTo(13, 6)
              ..lineTo(19, 12)
              ..lineTo(13, 18),
            stroke,
          );
      case LoopIcon.lock:
        final body = RRect.fromRectAndRadius(
          const Rect.fromLTWH(5, 10.5, 14, 10),
          const Radius.circular(2.6),
        );
        if (filled) canvas.drawRRect(body, fill);
        canvas
          ..drawRRect(body, stroke)
          ..drawPath(
            Path()
              ..moveTo(8.5, 10.5)
              ..lineTo(8.5, 8)
              ..arcToPoint(
                const Offset(15.5, 8),
                radius: const Radius.circular(3.5),
                clockwise: true,
              )
              ..lineTo(15.5, 10.5),
            stroke,
          );
      case LoopIcon.snowflake:
        canvas
          ..drawPath(
            Path()
              ..moveTo(12, 2.5)
              ..lineTo(12, 21.5)
              ..moveTo(3.8, 7.2)
              ..lineTo(20.2, 16.8)
              ..moveTo(3.8, 16.8)
              ..lineTo(20.2, 7.2),
            stroke,
          )
          ..drawPath(
            Path()
              ..moveTo(9.3, 4.2)
              ..lineTo(12, 6)
              ..lineTo(14.7, 4.2)
              ..moveTo(9.3, 19.8)
              ..lineTo(12, 18)
              ..lineTo(14.7, 19.8),
            stroke,
          );
      case LoopIcon.upDown:
        canvas.drawPath(
          Path()
            ..moveTo(7.5, 9.5)
            ..lineTo(12, 5)
            ..lineTo(16.5, 9.5)
            ..moveTo(7.5, 14.5)
            ..lineTo(12, 19)
            ..lineTo(16.5, 14.5),
          stroke,
        );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(LoopIconPainter old) =>
      old.icon != icon ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.filled != filled;
}

/// Small helper: a dashed rounded-rectangle outline (frozen tile border, ghost
/// slot). Kept here so `components/` need no package for it. Dash and gap default
/// to about 3 x and 2 x the stroke width, which is how the source renders' browser
/// `dashed` border reads (checked by eye against S-91 / C-03).
class DashedRRectPainter extends CustomPainter {
  const DashedRRectPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1.5,
    double? dash,
    double? gap,
    this.fill,
  }) : _dash = dash,
       _gap = gap;

  final Color color;
  final double radius;
  final double strokeWidth;
  final double? _dash;
  final double? _gap;
  final Color? fill;

  double get dash => _dash ?? 3 * strokeWidth;
  double get gap => _gap ?? 2 * strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    ).deflate(strokeWidth / 2);
    if (fill != null) {
      canvas.drawRRect(rrect, Paint()..color = fill!);
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final end = math.min(d + dash, metric.length);
        canvas.drawPath(metric.extractPath(d, end), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(DashedRRectPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.dash != dash ||
      old.gap != gap ||
      old.fill != fill;
}
