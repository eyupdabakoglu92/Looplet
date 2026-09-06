import 'package:flutter/foundation.dart';

import 'daily_result_sync_service.dart';
import 'repositories/daily_repo.dart';
import 'repositories/player_repo.dart';

/// Test/dev seam that fabricates a first daily completion and enqueues it for
/// sync — so the `sync_queue` + reconciliation + callable path can be exercised
/// end-to-end **without F07** (F08 architecture → Scope Boundary F08 ↔ F07).
///
/// F07 replaces this with the real Daily producer, calling the same
/// [DailyResultSyncService.enqueueFirstRun]. Guarded so it can never run in a
/// release build.
class FakeDailyResultProducer {
  FakeDailyResultProducer({
    required PlayerRepo player,
    required DailyRepo daily,
    required DailyResultSyncService sync,
  }) : _player = player,
       _daily = daily,
       _sync = sync;

  final PlayerRepo _player;
  final DailyRepo _daily;
  final DailyResultSyncService _sync;

  /// Records a fake completion for `(lang, dailyDate)` and enqueues it if it is
  /// the first run. Returns the outcome. No-op in release builds unless
  /// [allowInRelease] is set (tests only).
  Future<DailyCompletionOutcome?> produce({
    String lang = 'tr',
    String dailyDate = '2026-01-01',
    String dailyId = 'fake-daily',
    int moves = 12,
    int optimalMoves = 8,
    int durationMs = 60000,
    int stars = 2,
    int completedAtUtcMs = 1767225600000,
    bool allowInRelease = false,
  }) async {
    if (kReleaseMode && !allowInRelease) {
      assert(false, 'FakeDailyResultProducer must not run in release');
      return null;
    }

    final guestId = await _player.currentGuestId();
    final outcome = await _daily.recordCompletion(
      guestId: guestId,
      lang: lang,
      dailyDate: dailyDate,
      dailyId: dailyId,
      moveCount: moves,
      durationMs: durationMs,
      stars: stars,
      completedAtUtcMs: completedAtUtcMs,
    );

    if (outcome == DailyCompletionOutcome.firstRun) {
      await _sync.enqueueFirstRun(
        DailyResultPayload(
          lang: lang,
          dailyDate: dailyDate,
          dailyId: dailyId,
          moves: moves,
          optimalMoves: optimalMoves,
          durationMs: durationMs,
          stars: stars,
          completedAtUtcMs: completedAtUtcMs,
        ),
      );
    }
    return outcome;
  }
}
