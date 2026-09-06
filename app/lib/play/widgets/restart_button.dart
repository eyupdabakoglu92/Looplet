import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../play_theme.dart';

/// Restart (`ui-design.md` §7 "Restart control") — deliberately *unlike* Undo:
/// an outline circle with a full-loop arrow, on the right, small footprint,
/// separated by a divider. No confirmation (AC7). Inert during animation / won.
class RestartButton extends StatefulWidget {
  const RestartButton({
    required this.enabled,
    required this.onPressed,
    required this.semanticLabel,
    super.key,
  });

  final bool enabled;
  final VoidCallback onPressed;
  final String semanticLabel;

  @override
  State<RestartButton> createState() => _RestartButtonState();
}

class _RestartButtonState extends State<RestartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) return;
    _spin.forward(from: 0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.enabled
        ? PlayTheme.muted
        : PlayTheme.muted.withValues(alpha: 0.35);
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: RotationTransition(
            turns: _spin.drive(Tween<double>(begin: 0, end: 1)),
            child: Icon(Icons.refresh_rounded, size: 22, color: color),
          ),
        ),
      ),
    );
  }
}
