import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:looplet_core/looplet_core.dart' show MoveAxis;

import '../design/design.dart';
import '../play/play_layout.dart';
import '../play/play_session_controller.dart';
import '../reduce_motion.dart';
import 'journey_strings.dart';

/// The levels 4–6 column micro-tutorial (F05 `architecture.md §9`; visual
/// authority F03 `ui-design.md` §4–§7, Loop Glass, Phase D1). A diegetic,
/// action-gated coach-mark over the board: a periwinkle ghost ring on the
/// tutorial cell and a glass hint pill in the gap between the board and the
/// HUD — never over a control, so undo and restart stay usable (A-1). **No
/// button, no dim.**
///
/// * Touch-down on the board hides the ghost (120 ms); it returns after 600 ms
///   of idle (fading in over 160 ms) — never under the finger (A-6).
/// * The first column-axis drag that commits (applied or bounced) satisfies
///   the gate: [onSatisfied] fires at once (the caller persists the `kv` ack)
///   and the pill + ghost fade out over [exitDuration].
/// * Reduced motion: the ghost is static; every fade is instant.
///
/// The behaviour contract (trigger, action gate, ack, re-show — F05 AC4 /
/// AC11) is unchanged.
class ColumnTutorialOverlay extends StatefulWidget {
  const ColumnTutorialOverlay({
    required this.controller,
    required this.strings,
    required this.layout,
    required this.onSatisfied,
    super.key,
  });

  final PlaySessionController controller;
  final JourneyStrings strings;
  final PlayLayout layout;

  /// Fired once, when a column-axis drag is committed. The caller persists the
  /// `kv` ack and removes the overlay after [exitDuration].
  final VoidCallback onSatisfied;

  /// The pill + ghost fade-out once the gate is satisfied.
  static const Duration exitDuration = Duration(milliseconds: 160);

  /// The ghost loop: up 0.45 stride and back, ease-in-out.
  static const Duration loopDuration = Duration(milliseconds: 1200);
  static const Duration hideDuration = Duration(milliseconds: 120);
  static const Duration returnDelay = Duration(milliseconds: 600);
  static const Duration returnDuration = Duration(milliseconds: 160);

  /// The tutorial cell the ghost points at (the board's centre, S-07 / D1-08).
  static const (int, int) tutorialCell = (2, 2);

  /// §19.8 (3): drop the pill's vertical padding 7·s → 5·s above 1.15× if the
  /// device run measured under 4 pt of clearance. It did — 3.9 pt above the
  /// pill on the iPhone 16e at the 1.3× cap (F03 `frontend.md` §19) — so the
  /// pre-agreed fallback is on.
  static const bool compactPillAbove115 = true;

  @override
  State<ColumnTutorialOverlay> createState() => _ColumnTutorialOverlayState();
}

class _ColumnTutorialOverlayState extends State<ColumnTutorialOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _loop;
  late final AnimationController _ghost; // 1 = shown
  late final AnimationController _exit;
  late final bool _reduceMotion;
  Timer? _returnTimer;
  bool _satisfied = false;

  @override
  void initState() {
    super.initState();
    _reduceMotion = reduceMotionRequested();
    _loop = AnimationController(
      vsync: this,
      duration: ColumnTutorialOverlay.loopDuration,
    );
    _ghost = AnimationController(vsync: this, value: 1);
    _exit = AnimationController(
      vsync: this,
      duration: ColumnTutorialOverlay.exitDuration,
    );
    if (!_reduceMotion) _loop.repeat();
    widget.controller.addListener(_onController);
    // The hint is announced once, politely; the ghost is decorative.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        SemanticsService.announce(
          widget.strings.columnTutorialHint,
          Directionality.maybeOf(context) ?? TextDirection.ltr,
        ),
      );
    });
  }

  void _onController() {
    if (_satisfied) return;
    final c = widget.controller;
    final phase = c.phase;
    final animating =
        phase == PlaySessionPhase.animatingShift ||
        phase == PlaySessionPhase.animatingBounce;
    if (animating && c.activeLine?.axis == MoveAxis.column) {
      _satisfied = true;
      _returnTimer?.cancel();
      widget.onSatisfied();
      if (_reduceMotion) {
        _exit.value = 1;
      } else {
        _exit.forward();
      }
      return;
    }
    if (phase == PlaySessionPhase.tracking) {
      // The finger is down: the ghost steps aside and stays hidden.
      _returnTimer?.cancel();
      _setGhost(0, ColumnTutorialOverlay.hideDuration);
    } else if (phase == PlaySessionPhase.idle &&
        _ghost.value < 1 &&
        !(_returnTimer?.isActive ?? false)) {
      _returnTimer = Timer(ColumnTutorialOverlay.returnDelay, () {
        if (!mounted || _satisfied) return;
        if (widget.controller.phase != PlaySessionPhase.idle) return;
        _setGhost(1, ColumnTutorialOverlay.returnDuration);
      });
    }
  }

  void _setGhost(double target, Duration duration) {
    if (_reduceMotion) {
      _ghost.value = target;
    } else {
      _ghost.animateTo(target, duration: duration, curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    _returnTimer?.cancel();
    _loop.dispose();
    _ghost.dispose();
    _exit.dispose();
    super.dispose();
  }

  /// 0 → 1 → 0 over one loop, ease-in-out on each half (the prototype's
  /// `travel` keyframes).
  static double _travel(double t) => t < 0.5
      ? Curves.easeInOut.transform(t * 2)
      : 1 - Curves.easeInOut.transform((t - 0.5) * 2);

  @override
  Widget build(BuildContext context) {
    final layout = widget.layout;
    final s = layout.s;
    final g = layout.board;
    final (row, col) = ColumnTutorialOverlay.tutorialCell;
    final cell = layout.boardRect.topLeft + g.cellCenter(row, col);
    final band = layout.hintBand;
    final up = 0.45 * g.stride;
    final ghostTop =
        cell.dy +
        (TutorialGhost.ringCentreFromBottomRef - TutorialGhost.heightRef) * s;

    return Positioned.fill(
      child: IgnorePointer(
        // The overlay points; the board underneath takes the gesture, and the
        // HUD beside the pill stays usable.
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[_loop, _ghost, _exit]),
          builder: (context, _) {
            final p = _reduceMotion ? 0.0 : _travel(_loop.value);
            final shown = 1 - _exit.value;
            return Stack(
              children: <Widget>[
                Positioned(
                  left: cell.dx - 24 * s,
                  top: ghostTop - up * p,
                  child: Opacity(
                    opacity: (_ghost.value * shown).clamp(0.0, 1.0),
                    child: TutorialGhost(chevronOpacity: 1 - 0.4 * p),
                  ),
                ),
                Positioned.fromRect(
                  rect: band,
                  child: Center(
                    child: Opacity(
                      opacity: shown.clamp(0.0, 1.0),
                      child: HintPill(
                        text: widget.strings.columnTutorialHint,
                        compactAbove115:
                            ColumnTutorialOverlay.compactPillAbove115,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
