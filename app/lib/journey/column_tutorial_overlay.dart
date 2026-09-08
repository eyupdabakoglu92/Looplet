import 'dart:async';

import 'package:flutter/material.dart';
import 'package:looplet_core/looplet_core.dart' show MoveAxis;

import '../play/play_session_controller.dart';
import '../play/play_theme.dart';
import 'journey_strings.dart';

/// The levels 4–6 column micro-tutorial (`ui-design.md §6/§7.3`,
/// `architecture.md §9`). A diegetic, action-gated coach-mark over the F03
/// board: a dim layer + a looping vertical-drag gesture ghost + F03's cyan
/// loop-rails + one line of copy. **No button.** Clears only when the player
/// completes a column-axis drag (applied or bounced); re-prompts on a row
/// gesture or after ~6 s idle.
class ColumnTutorialOverlay extends StatefulWidget {
  const ColumnTutorialOverlay({
    required this.controller,
    required this.strings,
    required this.onSatisfied,
    super.key,
  });

  final PlaySessionController controller;
  final JourneyStrings strings;

  /// Fired once, when a column-axis drag is committed. The caller persists the
  /// `kv` ack flag and removes the overlay.
  final VoidCallback onSatisfied;

  @override
  State<ColumnTutorialOverlay> createState() => _ColumnTutorialOverlayState();
}

class _ColumnTutorialOverlayState extends State<ColumnTutorialOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ghost;
  Timer? _idleTimer;
  bool _satisfied = false;
  int _emphasis = 0; // bumped to trigger a re-prompt cycle

  @override
  void initState() {
    super.initState();
    final reduceMotion = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    _ghost = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (reduceMotion) {
      _ghost.value = 0.5; // static: finger centred, arrow visible
    } else {
      _ghost.repeat(reverse: true);
    }
    widget.controller.addListener(_onController);
    _armIdleTimer();
  }

  void _armIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 6), () {
      if (mounted && !_satisfied) setState(() => _emphasis++);
    });
  }

  void _onController() {
    if (_satisfied) return;
    final c = widget.controller;
    final animating =
        c.phase == PlaySessionPhase.animatingShift ||
        c.phase == PlaySessionPhase.animatingBounce;
    final axis = c.activeLine?.axis;
    if (animating && axis == MoveAxis.column) {
      _satisfied = true;
      widget.onSatisfied();
    } else if (animating && axis == MoveAxis.row) {
      _armIdleTimer();
      if (mounted) setState(() => _emphasis++);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    _idleTimer?.cancel();
    _ghost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        // The overlay dims + points, but the board underneath must still take
        // the gesture the tutorial is asking for.
        child: Stack(
          children: <Widget>[
            const ColoredBox(color: Color(0x73000000)), // ~45%
            Center(
              child: _GestureGhost(progress: _ghost, emphasis: _emphasis),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 40,
              child: AnimatedScale(
                // a single pulse on each re-prompt
                scale: _emphasis.isEven ? 1.0 : 1.06,
                duration: const Duration(milliseconds: 220),
                child: Text(
                  widget.strings.columnTutorialHint,
                  textAlign: TextAlign.center,
                  style: PlayTheme.helper.copyWith(
                    fontSize: 14,
                    color: PlayTheme.paper,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GestureGhost extends StatelessWidget {
  const _GestureGhost({required this.progress, required this.emphasis});

  final Animation<double> progress;
  final int emphasis; // rebuild key for the re-prompt pulse

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        // progress 0..1 ↔ a vertical travel of ±26 px around centre.
        final dy = (progress.value - 0.5) * 52;
        return SizedBox(
          width: 64,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // vertical double-arrow hint (cyan — F03's active colour)
              Icon(
                Icons.unfold_more_rounded,
                size: 44,
                color: PlayTheme.cyan.withValues(alpha: 0.55),
              ),
              // the "finger"
              Transform.translate(
                offset: Offset(0, dy),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PlayTheme.paper.withValues(alpha: 0.9),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: PlayTheme.cyan.withValues(alpha: 0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
