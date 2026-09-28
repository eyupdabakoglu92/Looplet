import 'package:flutter/widgets.dart';

import '../tokens.dart';

// Result-surface decoration of the full-screen result (F03 `ui-design.md`
// §16.6, Phase D2; allowed in the design layer by F03 architecture §20.7 (6)).
// Static: the Play screen drives its visibility.

/// The fixed band above the Result's scrolling column: the ground colour
/// `#0B1234` to 78 % of its height, then a fade to transparent, 54·s + 58 pt
/// tall. It sits behind the fixed back button and is shown only while the
/// column is scrolled ([visibility] 0 → 1), so scrolled text never collides
/// with the button (the column scrolls only above the 1.3× text cap).
/// Decorative — excluded from semantics and hit testing.
class ScrollBand extends StatelessWidget {
  const ScrollBand({this.visibility = 1, super.key});

  /// 0 at scroll offset 0 (invisible), 1 once the column is scrolled.
  final double visibility;

  /// The band's ground colour.
  static const Color ground = Color(0xFF0B1234);

  /// The band's height for the design scale [s].
  static double heightFor(double s) => 54 * s + 58;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    final v = visibility.clamp(0.0, 1.0);
    if (v == 0) return SizedBox(height: heightFor(s));
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Opacity(
          opacity: v,
          child: SizedBox(
            height: heightFor(s),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[ground, ground, Color(0x000B1234)],
                  stops: <double>[0, 0.78, 1],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
