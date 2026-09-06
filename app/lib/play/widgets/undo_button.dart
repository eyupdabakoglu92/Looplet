import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../play_theme.dart';

/// The 3-action Undo control (`ui-design.md` §7 "Undo control"): a wide pill
/// with a loop-back arrow + remaining-count pips. At quota 0 it is a visibly
/// dead control — tap does nothing, **no dialog / ad / toast** (AC6).
class UndoButton extends StatelessWidget {
  const UndoButton({
    required this.remaining,
    required this.enabled,
    required this.onPressed,
    required this.semanticLabel,
    super.key,
  });

  final int remaining;
  final bool enabled;
  final VoidCallback onPressed;
  final String semanticLabel;

  static const int _maxPips = 3;

  @override
  Widget build(BuildContext context) {
    final active = enabled && remaining > 0;
    return Semantics(
      button: true,
      enabled: active,
      label: '$semanticLabel — $remaining',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: active ? onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1E1F30) : const Color(0xFF161725),
            borderRadius: BorderRadius.circular(16),
            border: Border(
              top: BorderSide(
                color: PlayTheme.paper.withValues(alpha: active ? 0.06 : 0.0),
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.undo_rounded,
                size: 20,
                color: active
                    ? PlayTheme.paper
                    : PlayTheme.muted.withValues(alpha: 0.35),
              ),
              const SizedBox(width: 12),
              for (var i = 0; i < _maxPips; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: 6),
                _Pip(filled: i < remaining, active: active),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Pip extends StatelessWidget {
  const _Pip({required this.filled, required this.active});

  final bool filled;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? PlayTheme.paper
        : PlayTheme.muted.withValues(alpha: 0.35);
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : null,
        border: filled ? null : Border.all(color: color),
      ),
    );
  }
}
