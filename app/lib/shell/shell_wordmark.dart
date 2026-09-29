import 'package:flutter/widgets.dart';

import '../design/wordmark.dart';
import '../reduce_motion.dart';

/// The `Looplet` wordmark of the shell (splash, Home, store error), placed by
/// its caller at (25, 58)·s.
///
/// It fades in once per app process — 0 → 1 in [fadeDuration], instant under
/// reduced motion (F05 `ui-design.md` §4). The progress is process-wide: when
/// the splash hands over to Home mid-fade, Home's wordmark continues from the
/// same opacity, so the hand-off has no jump; once the fade is done every
/// later wordmark is simply there.
class ShellWordmark extends StatefulWidget {
  const ShellWordmark({required this.fontSize, super.key});

  final double fontSize;

  /// The splash wordmark fade (ui-design §4; flexible 120–200 ms, §11).
  static const Duration fadeDuration = Duration(milliseconds: 160);

  static double _progress = 0;

  /// The process-wide fade progress, 0…1.
  @visibleForTesting
  static double get fadeProgress => _progress;

  /// Starts the next wordmark from 0 again (tests only).
  @visibleForTesting
  static void resetFadeForTest() => _progress = 0;

  @override
  State<ShellWordmark> createState() => _ShellWordmarkState();
}

class _ShellWordmarkState extends State<ShellWordmark>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: ShellWordmark.fadeDuration,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (reduceMotionRequested()) ShellWordmark._progress = 1;
    _fade.value = ShellWordmark._progress;
    if (_fade.value < 1) {
      _fade.addListener(() => ShellWordmark._progress = _fade.value);
      _fade.forward();
    }
  }

  // Defensive: if Reduce Motion is switched on (or its flag reaches the
  // engine) while the fade runs, the wordmark is simply there. The iOS
  // embedder's own 0.2 s cross-fade of the native launch view on the first
  // Flutter frame is outside Flutter's control (F05-FE-D3 frontend.md).
  @override
  void didChangeAccessibilityFeatures() {
    if (reduceMotionRequested() && _fade.value < 1) {
      _fade.value = 1;
      ShellWordmark._progress = 1;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: LoopletWordmark(fontSize: widget.fontSize),
  );
}
