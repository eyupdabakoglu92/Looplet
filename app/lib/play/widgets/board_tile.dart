import 'package:flutter/widgets.dart';
import 'package:looplet_core/looplet_core.dart' show TileStatus;

import '../../design/icons.dart';
import '../play_theme.dart';

/// The legacy (Direction A) grid cell, kept **only for the `won` moment** until
/// Phase D2 (F03 `ui-design.md` §11.1, §16): the amber winning row on the board
/// and in the docked answer row. Every other Play state renders the Loop Glass
/// `TileFace`. A `locked` tile keeps its brass ring; its pin glyph is now the
/// drawn lock icon (no Material icon remains in the app, §11.4).
class BoardTile extends StatelessWidget {
  const BoardTile({
    required this.letter,
    required this.size,
    required this.status,
    this.winning = false,
    this.pressed = false,
    this.dim = 0,
    super.key,
  });

  final String letter;
  final double size;
  final TileStatus status;
  final bool winning;
  final bool pressed;

  /// 0..1 overlay applied to non-active tiles during a drag / shift.
  final double dim;

  @override
  Widget build(BuildContext context) {
    final radius = size * PlayTheme.tileRadiusFraction;
    final frost = status == TileStatus.frozen;
    final locked = status == TileStatus.locked;

    final Gradient fill;
    final Color glyph;
    if (winning) {
      fill = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[PlayTheme.amber, PlayTheme.amberLo],
      );
      glyph = PlayTheme.inkAmber;
    } else if (frost) {
      fill = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFEAF2FA), PlayTheme.frost],
      );
      glyph = PlayTheme.ink.withValues(alpha: 0.7);
    } else {
      fill = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[PlayTheme.tileHi, PlayTheme.tileLo],
      );
      glyph = PlayTheme.ink;
    }

    Widget tile = AnimatedScale(
      scale: pressed ? 0.97 : (winning ? 1.06 : 1.0),
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: fill,
          borderRadius: BorderRadius.circular(radius),
          border: frost
              ? Border.all(color: PlayTheme.frostLine, width: 1.5)
              : null,
          boxShadow: <BoxShadow>[
            const BoxShadow(
              color: Color(0x38000000),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
            const BoxShadow(
              color: Color(0x4D000000),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
            if (winning)
              const BoxShadow(color: Color(0x66FFC24B), blurRadius: 16),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (locked)
              LoopIconView(
                LoopIcon.lock,
                size: size * 0.62,
                color: PlayTheme.brass.withValues(alpha: 0.18),
              ),
            Text(
              letter,
              style: PlayTheme.tileLetter(size).copyWith(color: glyph),
            ),
          ],
        ),
      ),
    );

    if (locked) {
      tile = Stack(
        alignment: Alignment.center,
        children: <Widget>[
          tile,
          IgnorePointer(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: PlayTheme.brass, width: 2),
              ),
              margin: EdgeInsets.all(size * 0.06),
            ),
          ),
        ],
      );
    }

    if (dim > 0) {
      tile = Stack(
        children: <Widget>[
          tile,
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, dim),
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return tile;
  }
}
