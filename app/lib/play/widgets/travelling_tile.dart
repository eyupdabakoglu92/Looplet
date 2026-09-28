import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// One tile of the answer row while it travels (F03 `ui-design.md` §16.5,
/// §16.7): decorative — the result announces the answer.
///
/// * [TravellingTile.win] — the win sequence and the glide: the tile's own
///   board face (normal, locked or frozen) under the lime winning face, which
///   fills in over it ([fill] 0 → 1); the lock / snowflake icon and the frozen
///   dashes go with the face they belong to (C-11).
/// * [TravellingTile.flight] — the retry flight: the lime face over the goal
///   rail's face, cross-fading to the rail ([lime] 1 → 0).
///
/// Size, radius and glyph are interpolated by the caller, so the tile morphs
/// (never a scale-only transform).
class TravellingTile extends StatelessWidget {
  const TravellingTile.win({
    required this.letter,
    required TileState base,
    required double fill,
    required this.width,
    required this.height,
    required this.radius,
    required this.glyph,
    super.key,
  }) : _base = base,
       _lime = fill,
       _flight = false;

  const TravellingTile.flight({
    required this.letter,
    required double lime,
    required this.width,
    required this.height,
    required this.radius,
    required this.glyph,
    super.key,
  }) : _base = TileState.normal,
       _lime = lime,
       _flight = true;

  final String letter;
  final double width;
  final double height;
  final double radius;

  /// Glyph font size.
  final double glyph;

  final TileState _base;
  final double _lime;
  final bool _flight;

  @override
  Widget build(BuildContext context) {
    final lime = _lime.clamp(0.0, 1.0);
    final limeFace = TileFace(
      letter: letter,
      size: width,
      height: height,
      radius: radius,
      glyphSize: glyph,
      state: TileState.winning,
    );
    if (lime >= 1) return ExcludeSemantics(child: limeFace);
    final under = _flight
        ? _RailFace(
            letter: letter,
            width: width,
            height: height,
            radius: radius,
            glyph: glyph,
          )
        : TileFace(
            letter: letter,
            size: width,
            height: height,
            radius: radius,
            glyphSize: glyph,
            state: _base,
          );
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            under,
            if (lime > 0) Opacity(opacity: lime, child: limeFace),
          ],
        ),
      ),
    );
  }
}

/// The goal rail's tile face (`RailTile`: indigo gradient, 1 px edge, soft
/// shadow, light glyph) at any size — the flight lands on it.
class _RailFace extends StatelessWidget {
  const _RailFace({
    required this.letter,
    required this.width,
    required this.height,
    required this.radius,
    required this.glyph,
  });

  final String letter;
  final double width;
  final double height;
  final double radius;
  final double glyph;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LoopGradients.rail,
        borderRadius: BorderRadius.circular(radius),
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
        style: LoopText.node(glyph, color: LoopColors.text),
        textScaler: loopCappedTextScaler(context),
      ),
    );
  }
}
