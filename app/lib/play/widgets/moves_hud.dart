import 'package:flutter/widgets.dart';

import '../play_theme.dart';

/// The live `MOVES` read (`ui-design.md` §7). A big tabular figure over a
/// tracked micro-label, directly on the stage (no card). The number does a
/// brief scale-pulse when it changes on settle.
class MovesHud extends StatelessWidget {
  const MovesHud({required this.moves, required this.label, super.key});

  final int moves;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $moves',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TweenAnimationBuilder<double>(
            key: ValueKey<int>(moves),
            tween: Tween<double>(begin: 1.06, end: 1.0),
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Text('$moves', style: PlayTheme.movesNumber),
          ),
          const SizedBox(height: 4),
          Text(label, style: PlayTheme.microLabel),
        ],
      ),
    );
  }
}
