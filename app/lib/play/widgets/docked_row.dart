import 'package:flutter/widgets.dart';
import 'package:looplet_core/looplet_core.dart' show TileStatus;

import '../play_theme.dart';
import 'board_tile.dart';

/// The docked answer row (`ui-design.md` §16): the winning row's tiles plus the
/// drawn amber seam bar as one unit that lifts out of the board, glides to the
/// dock under the target rail and stays there while the F04 panel rises.
///
/// One `RepaintBoundary` layer moved by the parent's `Positioned` — nothing else
/// on the board repaints during the dock. Decorative: the completion panel
/// announces the result, so this is excluded from semantics.
class DockedAnswerRow extends StatelessWidget {
  const DockedAnswerRow({
    required this.letters,
    required this.statuses,
    required this.tile,
    required this.dockProgress,
    this.gap = PlayTheme.tileGap,
    this.scale = 1.0,
    super.key,
  });

  final List<String> letters;
  final List<TileStatus> statuses;
  final double tile;

  /// The board's tile gap, so the docked row keeps the x of every tile of its
  /// home row (§16.3 "the row keeps its x"; the D1 board uses 6.5·s).
  final double gap;

  /// 0 (at home / travelling) → 1 (docked). Drives the shadow only: deeper
  /// (y+10, blur 24) in flight, resting (y+6, blur 16) at the dock.
  final double dockProgress;

  /// `< 1.0` only for the §16.3 fallback (free zone shorter than the unit).
  final double scale;

  /// Vertical extent of the unit: tile + 3 pt gap + 3 pt seam.
  static double heightFor(double tile) => tile + 6;

  /// Width of a row of [count] tiles.
  static double widthFor(
    double tile,
    int count, {
    double gap = PlayTheme.tileGap,
  }) => count * tile + (count - 1) * gap;

  @override
  Widget build(BuildContext context) {
    final n = letters.length;
    final stride = tile + gap;
    final width = widthFor(tile, n, gap: gap);
    final radius = tile * PlayTheme.tileRadiusFraction;
    final lift = 1 - dockProgress.clamp(0.0, 1.0);

    Widget unit = SizedBox(
      width: width,
      height: heightFor(tile),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // Contact shadow of the lifted row.
          Positioned(
            left: 0,
            top: 0,
            width: width,
            height: tile,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0x73000000),
                    offset: Offset(0, 6 + 4 * lift),
                    blurRadius: 16 + 8 * lift,
                  ),
                ],
              ),
            ),
          ),
          for (var c = 0; c < n; c++)
            Positioned(
              left: c * stride,
              top: 0,
              width: tile,
              height: tile,
              child: BoardTile(
                letter: letters[c],
                size: tile,
                status: statuses[c],
                winning: true,
              ),
            ),
          // The drawn seam, same geometry as the board's own (3 pt, 3 pt below).
          Positioned(
            left: 0,
            top: tile + 3,
            width: width,
            height: 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: PlayTheme.amber,
                borderRadius: BorderRadius.circular(2),
                boxShadow: const <BoxShadow>[
                  BoxShadow(color: Color(0x66FFC24B), blurRadius: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (scale != 1.0) {
      unit = Transform.scale(
        scale: scale,
        alignment: Alignment.topCenter,
        child: unit,
      );
    }
    return ExcludeSemantics(child: RepaintBoundary(child: unit));
  }
}
