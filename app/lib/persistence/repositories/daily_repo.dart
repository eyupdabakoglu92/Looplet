import 'package:drift/drift.dart';

import '../app_database.dart';

/// Outcome of recording a daily completion.
enum DailyCompletionOutcome {
  /// The first completed run for this `(guestId, lang, dailyDate)` — the
  /// official result; first-run fields written; ready to enqueue for sync.
  firstRun,

  /// A later replay — stored as a `daily_attempt` row only; the official result
  /// and any sync are untouched.
  replay,
}

/// Daily first-run result + replay attempts (product PRD §15 `DailyEntry`).
/// Written by F07. **First-run fields are immutable once set** — a later
/// completion only appends a `daily_attempt` and never re-enqueues sync
/// (F08 architecture → Reconciliation Algorithm).
class DailyRepo {
  DailyRepo(this._db);

  final AppDatabase _db;

  Future<DailyEntry?> firstRun(String guestId, String lang, String dailyDate) =>
      (_db.select(_db.dailyEntries)..where(
            (t) =>
                t.guestId.equals(guestId) &
                t.lang.equals(lang) &
                t.dailyDate.equals(dailyDate),
          ))
          .getSingleOrNull();

  Future<List<DailyAttempt>> attempts(
    String guestId,
    String lang,
    String dailyDate,
  ) =>
      (_db.select(_db.dailyAttempts)
            ..where(
              (t) =>
                  t.guestId.equals(guestId) &
                  t.lang.equals(lang) &
                  t.dailyDate.equals(dailyDate),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.attemptNo)]))
          .get();

  /// Records a completion. Write-through, transactional.
  Future<DailyCompletionOutcome> recordCompletion({
    required String guestId,
    required String lang,
    required String dailyDate,
    required String dailyId,
    required int moveCount,
    required int durationMs,
    required int stars,
    required int completedAtUtcMs,
  }) async {
    return _db.transaction(() async {
      final existing = await firstRun(guestId, lang, dailyDate);
      if (existing == null) {
        await _db
            .into(_db.dailyEntries)
            .insert(
              DailyEntriesCompanion.insert(
                guestId: guestId,
                lang: lang,
                dailyDate: dailyDate,
                dailyId: dailyId,
                firstRunMoveCount: moveCount,
                firstRunDurationMs: durationMs,
                firstRunStars: stars,
                firstRunCompletedAtUtcMs: completedAtUtcMs,
                syncStatus: DailySyncStatus.local,
              ),
            );
        return DailyCompletionOutcome.firstRun;
      }

      final priorAttempts = await attempts(guestId, lang, dailyDate);
      final nextAttemptNo = priorAttempts.isEmpty
          ? 2
          : priorAttempts.last.attemptNo + 1;
      await _db
          .into(_db.dailyAttempts)
          .insert(
            DailyAttemptsCompanion.insert(
              guestId: guestId,
              lang: lang,
              dailyDate: dailyDate,
              attemptNo: nextAttemptNo,
              moveCount: moveCount,
              durationMs: durationMs,
              stars: stars,
              completedAtUtcMs: completedAtUtcMs,
            ),
          );
      return DailyCompletionOutcome.replay;
    });
  }

  /// Mirrors the `sync_queue` item state for display (F08 architecture — updated
  /// in the same transaction as the queue transition by the sync service).
  Future<void> setSyncStatus(
    String guestId,
    String lang,
    String dailyDate,
    DailySyncStatus status,
  ) =>
      (_db.update(_db.dailyEntries)..where(
            (t) =>
                t.guestId.equals(guestId) &
                t.lang.equals(lang) &
                t.dailyDate.equals(dailyDate),
          ))
          .write(DailyEntriesCompanion(syncStatus: Value(status)));
}
