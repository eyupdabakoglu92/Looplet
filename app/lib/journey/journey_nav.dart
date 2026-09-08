import 'journey_content.dart';

/// The level a `Next Level` tap navigates to from Journey level [n], or `null`
/// when there is no next level → the caller routes to the terminal state
/// (`architecture.md §8`). [manifestLevelCount] is how many levels the active
/// manifest actually ships (30 in `strict` mode; fewer in the interim).
int? nextJourneyLevel(int n, {required int manifestLevelCount}) {
  if (n < 1 || n >= journeyLevelCount) return null; // level 30 → terminal
  if (n + 1 > manifestLevelCount) return null; // no content yet → terminal
  return n + 1;
}
