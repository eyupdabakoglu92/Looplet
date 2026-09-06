import 'package:flutter/widgets.dart';

import '../play_theme.dart';

/// The always-visible goal (`ui-design.md` §7 "Target rail"): the target word as
/// small **outline-ghost** tiles — same rounded-rect silhouette as the board,
/// ~46% scale, outline + very low fill — under a tracked micro-label. Separated
/// from the board by scale + treatment (here) + a divider glow + air (screen).
class TargetRail extends StatelessWidget {
  const TargetRail({
    required this.label,
    required this.word,
    required this.tileSize,
    super.key,
  });

  final String label;
  final String word;

  /// The board's tile size; ghost tiles render at ~46% of it.
  final double tileSize;

  @override
  Widget build(BuildContext context) {
    final ghost = (tileSize * 0.46).clamp(22.0, 40.0);
    final letters = word.characters.toList(growable: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: PlayTheme.microLabel),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (var i = 0; i < letters.length; i++) ...<Widget>[
              if (i > 0) SizedBox(width: ghost * 0.42),
              _GhostTile(letter: letters[i], size: ghost),
            ],
          ],
        ),
      ],
    );
  }
}

class _GhostTile extends StatelessWidget {
  const _GhostTile({required this.letter, required this.size});

  final String letter;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(
          size * PlayTheme.tileRadiusFraction,
        ),
        border: Border.all(color: PlayTheme.muted.withValues(alpha: 0.55)),
      ),
      child: Text(
        letter,
        style: PlayTheme.tileLetter(size).copyWith(
          color: PlayTheme.paper.withValues(alpha: 0.8),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
