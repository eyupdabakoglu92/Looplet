import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../persistence/active_session_snapshot.dart';
import '../persistence/app_database.dart' show JourneyProgressRow;
import '../persistence/persistence_providers.dart';
import 'journey_content.dart';

/// Per-level state derived from `journey_progress` + the active-session
/// snapshot (`architecture.md §6`). Consumers must handle **all four**.
enum LevelState { locked, unlockedIncomplete, completed, inProgress }

/// A snapshot of Journey progress for the home surface + navigation
/// (`architecture.md §6`). Pure — built by [buildJourneyProgressModel].
class JourneyProgressModel {
  const JourneyProgressModel({
    required this.highestUnlockedLevel,
    required this.completedLevels,
    required this.inProgressLevel,
  });

  final int highestUnlockedLevel;
  final Set<int> completedLevels;

  /// The level number of the single in-progress Journey session, if any.
  final int? inProgressLevel;

  /// `|completedLevels ∩ {1..30}|` — the ring's amber-run length.
  int get progressCount =>
      completedLevels.where((n) => n >= 1 && n <= journeyLevelCount).length;

  bool get allComplete => progressCount >= journeyLevelCount;

  LevelState stateOf(int n) {
    if (n == inProgressLevel) return LevelState.inProgress;
    if (completedLevels.contains(n)) return LevelState.completed;
    if (n > highestUnlockedLevel) return LevelState.locked;
    return LevelState.unlockedIncomplete;
  }

  /// The level CONTINUE resolves to (`architecture.md §6/§8`): the in-progress
  /// level, else the lowest unlocked-incomplete level, else `null` (all done →
  /// the terminal state).
  int? get continueTarget {
    if (inProgressLevel != null) return inProgressLevel;
    for (var n = 1; n <= journeyLevelCount; n++) {
      if (n <= highestUnlockedLevel && !completedLevels.contains(n)) return n;
    }
    return null;
  }
}

/// Pure builder — `journey_progress` row + the (optional) active-session
/// snapshot → the model.
JourneyProgressModel buildJourneyProgressModel({
  required JourneyProgressRow row,
  required ActiveSessionSnapshot? activeSnapshot,
}) {
  final completed = row.completedLevelsCsv
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .map(int.parse)
      .toSet();

  int? inProgress;
  final snap = activeSnapshot;
  if (snap != null &&
      snap.puzzleSource == PuzzleSource.journey &&
      snap.status == ActiveSessionStatus.inProgress) {
    inProgress = parseJourneyLevel(snap.puzzleId);
  }

  return JourneyProgressModel(
    highestUnlockedLevel: row.highestUnlockedLevel,
    completedLevels: completed,
    inProgressLevel: inProgress,
  );
}

/// Live Journey progress for the home surface — re-emits when a win commits
/// (`JourneyProgressRepo.markCompleted` → the Drift `watchSingle` stream),
/// re-reading the active-session snapshot on each tick.
final journeyProgressModelProvider = StreamProvider<JourneyProgressModel>((
  ref,
) async* {
  final guestId = await ref.watch(currentGuestIdProvider.future);
  final repo = ref.watch(journeyProgressRepoProvider);
  final activeRepo = ref.watch(activeSessionRepoProvider);

  await for (final row in repo.watch(guestId)) {
    final snap = await activeRepo.read();
    yield buildJourneyProgressModel(row: row, activeSnapshot: snap);
  }
});
