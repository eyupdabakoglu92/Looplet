import 'dart:async';

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

/// Live Journey progress for the home surface (`architecture.md §6`, amended
/// 2026-09-26). Re-derives whenever EITHER source changes:
/// * a win commits (`JourneyProgressRepo.watch`);
/// * the active-session snapshot changes (`ActiveSessionRepo.watch` — session
///   start, move, completion, clear).
///
/// The home stays mounted under the pushed `/play` route, so a one-shot
/// snapshot read would leave it stale for the rest of the app session: the
/// same persisted state must yield the same model warm or cold.
final journeyProgressModelProvider = StreamProvider<JourneyProgressModel>((
  ref,
) async* {
  final guestId = await ref.watch(currentGuestIdProvider.future);
  final repo = ref.watch(journeyProgressRepoProvider);
  final activeRepo = ref.watch(activeSessionRepoProvider);

  yield* _combineLatest(repo.watch(guestId), activeRepo.watch());
});

/// Emits a [JourneyProgressModel] from the latest value of each source once
/// both have emitted, then again whenever either emits. Closes when both
/// sources are done.
Stream<JourneyProgressModel> _combineLatest(
  Stream<JourneyProgressRow> rows,
  Stream<ActiveSessionSnapshot?> snapshots,
) {
  late final StreamController<JourneyProgressModel> controller;
  StreamSubscription<JourneyProgressRow>? rowSub;
  StreamSubscription<ActiveSessionSnapshot?>? snapshotSub;
  JourneyProgressRow? row;
  ActiveSessionSnapshot? snapshot;
  var hasSnapshot = false;
  var doneCount = 0;

  void emit() {
    final current = row;
    if (current == null || !hasSnapshot) return;
    controller.add(
      buildJourneyProgressModel(row: current, activeSnapshot: snapshot),
    );
  }

  void done() {
    if (++doneCount == 2) controller.close();
  }

  controller = StreamController<JourneyProgressModel>(
    onListen: () {
      rowSub = rows.listen(
        (value) {
          row = value;
          emit();
        },
        onError: controller.addError,
        onDone: done,
      );
      snapshotSub = snapshots.listen(
        (value) {
          snapshot = value;
          hasSnapshot = true;
          emit();
        },
        onError: controller.addError,
        onDone: done,
      );
    },
    onPause: () {
      rowSub?.pause();
      snapshotSub?.pause();
    },
    onResume: () {
      rowSub?.resume();
      snapshotSub?.resume();
    },
    onCancel: () async {
      await rowSub?.cancel();
      await snapshotSub?.cancel();
    },
  );
  return controller.stream;
}
