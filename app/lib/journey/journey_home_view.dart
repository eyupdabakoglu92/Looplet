import '../design/components/info.dart' show LoopNodeState;
import 'journey_content.dart' show journeyLevelCount;
import 'journey_progress.dart';
import 'journey_strings.dart';

/// Which headline Home shows (F05 architecture §18.7 C1).
enum JourneyHeadline { first, next, replay, complete }

/// What the D3 Home shows for a [JourneyProgressModel] — pure, so every rule is
/// unit-testable (F05 `ui-design.md` §6 / §8 / §12; architecture §18.3 (2),
/// §18.7 C1).
///
/// * **CTA:** `currentLevel` = the model's `continueTarget`. The terminal state
///   is `continueTarget == null` — never `allComplete`: with all 30 done and a
///   replay in progress, CONTINUE resumes the replay (the user's N1 decision,
///   PO-REV-2026-09-29-F05-CONTINUE).
/// * **Window** (direction A "sliding five"): five consecutive levels.
///   Terminal → 26–30. A replay (a completed level above the current one) →
///   `start = clamp(current − 2, 1, 26)`; otherwise the current level is the
///   frontier → `start = clamp(current − 4, 1, 26)`.
class JourneyHomeView {
  factory JourneyHomeView.of(JourneyProgressModel model) {
    final current = model.continueTarget;
    final completed = model.completedLevels;
    final inProgress = model.inProgressLevel;
    final count = model.progressCount;

    final JourneyHeadline headline;
    if (count >= journeyLevelCount) {
      headline = JourneyHeadline.complete;
    } else if (inProgress != null && completed.contains(inProgress)) {
      headline = JourneyHeadline.replay;
    } else if (count == 0 && inProgress == null) {
      headline = JourneyHeadline.first;
    } else {
      headline = JourneyHeadline.next;
    }

    final int start;
    if (current == null) {
      start = journeyLevelCount - windowSize + 1;
    } else {
      final replay = completed.any((n) => n > current);
      start = (current - (replay ? 2 : 4)).clamp(
        1,
        journeyLevelCount - windowSize + 1,
      );
    }

    LoopNodeState stateOf(int n) {
      if (current == null && n == journeyLevelCount) {
        return LoopNodeState.finish;
      }
      if (n == current) return LoopNodeState.current;
      if (completed.contains(n)) return LoopNodeState.done;
      if (n <= model.highestUnlockedLevel) return LoopNodeState.open;
      return LoopNodeState.locked;
    }

    return JourneyHomeView._(
      progressCount: count,
      currentLevel: current,
      inProgress: inProgress != null,
      headline: headline,
      windowStart: start,
      windowStates: List<LoopNodeState>.unmodifiable(<LoopNodeState>[
        for (var i = 0; i < windowSize; i++) stateOf(start + i),
      ]),
    );
  }

  const JourneyHomeView._({
    required this.progressCount,
    required this.currentLevel,
    required this.inProgress,
    required this.headline,
    required this.windowStart,
    required this.windowStates,
  });

  /// The track shows this many levels.
  static const int windowSize = 5;

  final int progressCount;

  /// The level CONTINUE resumes or opens; `null` ⇔ the terminal state.
  final int? currentLevel;

  /// A Journey session is in progress (the caption and CTA say "sürüyor").
  final bool inProgress;

  final JourneyHeadline headline;

  /// The first level of the track's window.
  final int windowStart;

  /// One state per window level, left to right.
  final List<LoopNodeState> windowStates;

  /// The terminal state: all 30 done and no session in progress.
  bool get terminal => currentLevel == null;

  /// Where the CTA goes: the current level, or level 1 to play again.
  int get ctaTarget => currentLevel ?? 1;

  String ctaLabel(JourneyStrings strings) =>
      terminal ? strings.replayLabel : strings.continueLabel;

  String caption(JourneyStrings strings) =>
      strings.levelCaption(ctaTarget, inProgress: !terminal && inProgress);

  String ctaSemantics(JourneyStrings strings) => strings.ctaSemantics(
    ctaLabel(strings),
    ctaTarget,
    inProgress: !terminal && inProgress,
  );

  String progressSemantics(JourneyStrings strings) =>
      strings.progressSemantics(progressCount, currentLevel);

  JourneyHeadlineText headlineText(JourneyStrings strings) =>
      switch (headline) {
        JourneyHeadline.first => strings.headlineFirst,
        JourneyHeadline.next => strings.headlineNext,
        JourneyHeadline.replay => strings.headlineReplay,
        JourneyHeadline.complete => strings.headlineComplete,
      };
}
