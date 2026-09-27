import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// The goal (F03 `ui-design.md` §6–§7, Loop Glass): the `HEDEF DÖNGÜ` caption
/// over the target word as indigo [RailTile]s — a different object from the
/// cream board tiles, so the goal pairs with the board without competing. No
/// divider line (§10).
///
/// Laid out from the caption's glyph-box top: the tiles start 25·s below it
/// (172·s → 197·s in the reference), so the widget's bottom edge is the rail
/// tiles' bottom. The won moment docks the answer row onto these tiles and
/// fades them out beneath it ([tileOpacity]; `won_composition.dart`).
///
/// One semantics node: "Hedef döngü: TARİH".
class TargetRail extends StatelessWidget {
  const TargetRail({
    required this.label,
    required this.word,
    required this.semanticsLabel,
    this.tileOpacity = 1,
    super.key,
  });

  final String label;
  final String word;

  /// e.g. "Hedef döngü: TARİH".
  final String semanticsLabel;

  /// The rail tiles' opacity (the caption stays): 0 once the answer row has
  /// docked onto them.
  final double tileOpacity;

  /// Caption glyph-box top → rail-tile top, in reference units.
  static const double tilesOffsetRef = 25;

  /// Rail-tile height, in reference units (`RailTile`: 36 × 42).
  static const double tilesHeightRef = 42;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    final letters = word.characters.toList(growable: false);
    final scaler = loopCappedTextScaler(context);
    final captionStyle = LoopText.caption(s);
    // The reference sets the caption on a 1.0 line; the role's 1.3 line adds
    // 0.15 em above the glyphs, so the text box starts that much higher to
    // keep the glyphs where the render has them at every capped scale.
    final captionShift = 0.15 * scaler.scale(captionStyle.fontSize!);

    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: SizedBox(
        height: (tilesOffsetRef + tilesHeightRef) * s,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              top: -captionShift,
              child: Text(
                label,
                style: captionStyle,
                textScaler: scaler,
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: tilesOffsetRef * s,
              child: Opacity(
                opacity: tileOpacity.clamp(0.0, 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (var i = 0; i < letters.length; i++) ...<Widget>[
                      if (i > 0) SizedBox(width: 8 * s),
                      RailTile(letter: letters[i]),
                    ],
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
