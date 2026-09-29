import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../tokens.dart';
import 'info.dart';

/// The loop-track geometry (F05 `ui-design.md` §6, D3 direction A "sliding
/// five"), in the 358-pt reference space. Pure, so every centre is
/// unit-testable; multiply by the design scale `s` to draw.
///
/// Coordinates are local to the track block: the full card width (308) by
/// [blockHeight] (166), whose top sits at card y [trackTop] (134).
abstract final class LoopTrackGeometry {
  /// The card (and track block) width.
  static const double cardWidth = 308;

  /// The track block's height.
  static const double blockHeight = 166;

  /// Card-local y where the track block starts (headline bottom 122 + 12).
  static const double trackTop = 134;

  /// Centre-to-centre spacing between two small nodes.
  static const double smallGap = 50;

  /// Centre-to-centre spacing next to a large node (current or finish).
  static const double largeGap = 64;

  /// The chain is centred on this card x.
  static const double centreX = 154;

  /// Card-local height of the rising line at card x [x]:
  /// `236 − 62·p^1.25`, `p = (x − 40) / 230` clamped to 0…1.
  static double lineY(double x) {
    final p = ((x - 40) / 230).clamp(0.0, 1.0);
    return 236 - 62 * math.pow(p, 1.25).toDouble();
  }

  /// Block-local node centres for [states], left to right.
  static List<Offset> centres(List<LoopNodeState> states) {
    final xs = <double>[0];
    for (var i = 1; i < states.length; i++) {
      final wide =
          LoopNode.isLarge(states[i]) || LoopNode.isLarge(states[i - 1]);
      xs.add(xs[i - 1] + (wide ? largeGap : smallGap));
    }
    final offset = centreX - (xs.first + xs.last) / 2;
    return <Offset>[
      for (final x in xs) Offset(x + offset, lineY(x + offset) - trackTop),
    ];
  }

  /// Block-local start of the lead-in line (the card's left edge).
  static const Offset leadInStart = Offset(0, 236 - trackTop + 4);

  /// Whether a tail fits after a last node at block x [lastX]: at least 48 pt
  /// of room to the card's right edge.
  static bool tailFits(double lastX) => cardWidth - lastX > 48;
}

/// The loop track (F05 `ui-design.md` §6–§7, D3; architecture §18.3 (3),
/// §18.7): a window of consecutive levels as [LoopNode]s along a rising line,
/// with a lead-in line when levels lie before the window and a dashed tail
/// when levels follow it. Display-only (no tap handler) and excluded from
/// semantics — the Journey progress is announced once by its caller
/// (§18.7 ruling 2).
class LoopTrack extends StatelessWidget {
  const LoopTrack({
    required this.firstLevel,
    required this.states,
    this.levelCount = 30,
    super.key,
  });

  /// The level number of the first node.
  final int firstLevel;

  /// One state per node, left to right.
  final List<LoopNodeState> states;

  /// The Journey's length (a tail is drawn only while levels follow).
  final int levelCount;

  /// A lime lead-in fades in from the card's edge iff the window starts after
  /// level 1 (ui-design §6).
  bool get hasLeadIn => firstLevel > 1;

  /// A dashed tail runs to the card's edge iff levels follow the window and
  /// there are at least 48 pt of room after the last node.
  bool get hasTail =>
      firstLevel + states.length - 1 < levelCount &&
      LoopTrackGeometry.tailFits(LoopTrackGeometry.centres(states).last.dx);

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    final centres = LoopTrackGeometry.centres(states);
    return ExcludeSemantics(
      child: SizedBox(
        width: LoopTrackGeometry.cardWidth * s,
        height: LoopTrackGeometry.blockHeight * s,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned.fill(
              child: CustomPaint(
                painter: _LoopTrackPainter(
                  scale: s,
                  centres: centres,
                  states: states,
                  leadIn: hasLeadIn,
                  tail: hasTail,
                ),
              ),
            ),
            for (var i = 0; i < states.length; i++)
              Positioned(
                left: centres[i].dx * s - LoopNode.extentFor(states[i], s) / 2,
                top: centres[i].dy * s - LoopNode.extentFor(states[i], s) / 2,
                child: LoopNode(number: firstLevel + i, state: states[i]),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoopTrackPainter extends CustomPainter {
  _LoopTrackPainter({
    required this.scale,
    required this.centres,
    required this.states,
    required this.leadIn,
    required this.tail,
  });

  final double scale;
  final List<Offset> centres;
  final List<LoopNodeState> states;
  final bool leadIn;
  final bool tail;

  static const Color _dotted = Color(0x6BAEB4CA); // rgba(174,180,202,.42)
  static const Color _tail = Color(0x4DAEB4CA); // rgba(174,180,202,.30)

  /// A smooth monotone curve through two centres (a symmetric cubic with 0.45
  /// handles, as in the renders — ui-design §11 "Flexible").
  Path _segment(Offset a, Offset b) {
    final dx = (b.dx - a.dx) * 0.45;
    return Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(a.dx + dx, a.dy, b.dx - dx, b.dy, b.dx, b.dy);
  }

  Paint _solid(double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = width * scale;

  void _dashed(Canvas canvas, Path path, Color color) {
    final paint = _solid(2)..color = color;
    final dash = 2 * scale, gap = 5 * scale;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(
          metric.extractPath(d, math.min(d + dash, metric.length)),
          paint,
        );
        d += dash + gap;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pts = <Offset>[for (final c in centres) c * scale];
    if (leadIn) {
      const start = LoopTrackGeometry.leadInStart;
      final from = start * scale;
      canvas.drawPath(
        _segment(from, pts.first),
        _solid(3.2)
          ..shader = LinearGradient(
            colors: <Color>[
              LoopColors.limeMid.withValues(alpha: 0),
              LoopColors.limeMid.withValues(alpha: 0.9),
            ],
          ).createShader(Rect.fromLTRB(from.dx, 0, pts.first.dx, 1)),
      );
    }
    for (var i = 1; i < pts.length; i++) {
      final a = pts[i - 1], b = pts[i];
      final path = _segment(a, b);
      switch (states[i]) {
        case LoopNodeState.done || LoopNodeState.finish:
          final fromCurrent = states[i - 1] == LoopNodeState.current;
          canvas.drawPath(
            path,
            _solid(3.2)
              ..color = LoopColors.limeMid.withValues(
                alpha: fromCurrent ? 0.55 : 0.9,
              ),
          );
        case LoopNodeState.current:
          canvas.drawPath(
            path,
            _solid(3.2)
              ..shader = LinearGradient(
                colors: <Color>[
                  LoopColors.limeMid.withValues(alpha: 0.9),
                  LoopColors.periwinkle.withValues(alpha: 0.9),
                ],
              ).createShader(Rect.fromLTRB(a.dx, 0, b.dx, 1)),
          );
        case LoopNodeState.open || LoopNodeState.locked:
          _dashed(canvas, path, _dotted);
      }
    }
    if (tail) {
      final last = pts.last;
      _dashed(
        canvas,
        Path()
          ..moveTo(last.dx + 30 * scale, last.dy)
          ..lineTo(
            (LoopTrackGeometry.cardWidth - 6) * scale,
            last.dy - 8 * scale,
          ),
        _tail,
      );
    }
  }

  @override
  bool shouldRepaint(_LoopTrackPainter old) =>
      old.scale != scale ||
      old.leadIn != leadIn ||
      old.tail != tail ||
      !_listEquals(old.states, states);

  static bool _listEquals(List<LoopNodeState> a, List<LoopNodeState> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
