import 'package:flutter/widgets.dart';

/// Whether the OS asks for reduced motion — the single read every screen uses
/// (`F03-QA-04`).
///
/// iOS "Reduce Motion" surfaces as [AccessibilityFeatures.reduceMotion] (the
/// flag is iOS-only) while Android "Remove animations" surfaces as
/// [AccessibilityFeatures.disableAnimations]; reading only one of them leaves
/// the other platform on the full-motion path.
///
/// Reads the live platform value (not `MediaQuery`) so it works from
/// `initState`/listeners as well as `build`.
bool reduceMotionRequested() {
  final features =
      WidgetsBinding.instance.platformDispatcher.accessibilityFeatures;
  return features.reduceMotion || features.disableAnimations;
}
