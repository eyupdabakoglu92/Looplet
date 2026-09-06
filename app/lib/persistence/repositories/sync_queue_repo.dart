import 'package:drift/drift.dart';

import '../app_database.dart';

/// Primitive operations over the `sync_queue` table. The drain state machine +
/// backoff live in `DailyResultSyncService`; this repo just moves rows between
/// states transactionally (F08 architecture → `sync_queue` Contract).
class SyncQueueRepo {
  SyncQueueRepo(this._db);

  final AppDatabase _db;

  /// Enqueues a work item. If [idempotencyKey] is non-null and a non-`parked`
  /// row already exists for it, returns that row and inserts nothing
  /// (exactly-once at the client edge).
  Future<SyncQueueRow> enqueue({
    required SyncQueueKind kind,
    required String? idempotencyKey,
    required String payloadJson,
    required int nowUtcMs,
  }) async {
    return _db.transaction(() async {
      if (idempotencyKey != null) {
        final existing =
            await (_db.select(_db.syncQueueRows)..where(
                  (t) =>
                      t.idempotencyKey.equals(idempotencyKey) &
                      t.state.equalsValue(SyncQueueState.parked).not(),
                ))
                .getSingleOrNull();
        if (existing != null) return existing;
      }
      final id = await _db
          .into(_db.syncQueueRows)
          .insert(
            SyncQueueRowsCompanion.insert(
              kind: kind,
              payloadJson: payloadJson,
              state: SyncQueueState.pending,
              idempotencyKey: Value(idempotencyKey),
              createdAtUtcMs: nowUtcMs,
              updatedAtUtcMs: nowUtcMs,
            ),
          );
      return byId(id).then((row) => row!);
    });
  }

  Future<SyncQueueRow?> byId(int id) => (_db.select(
    _db.syncQueueRows,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<SyncQueueRow>> all() => _db.select(_db.syncQueueRows).get();

  /// `pending` rows whose `nextAttemptAtUtcMs` is due, oldest first. Rows still
  /// awaiting a `firebaseUid` (null `idempotencyKey`) are excluded — the caller
  /// backfills the key first.
  Future<List<SyncQueueRow>> duePending(int nowUtcMs) =>
      (_db.select(_db.syncQueueRows)
            ..where(
              (t) =>
                  t.state.equalsValue(SyncQueueState.pending) &
                  t.idempotencyKey.isNotNull() &
                  t.nextAttemptAtUtcMs.isSmallerOrEqualValue(nowUtcMs),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.createdAtUtcMs)]))
          .get();

  /// Rows still waiting for a `firebaseUid` before they can be sent.
  Future<List<SyncQueueRow>> awaitingAuth() =>
      (_db.select(_db.syncQueueRows)..where(
            (t) =>
                t.state.equalsValue(SyncQueueState.pending) &
                t.idempotencyKey.isNull(),
          ))
          .get();

  Future<void> setIdempotencyKey(int id, String key, int nowUtcMs) => _patch(
    id,
    SyncQueueRowsCompanion(
      idempotencyKey: Value(key),
      updatedAtUtcMs: Value(nowUtcMs),
    ),
  );

  Future<void> markInFlight(int id, int nowUtcMs) => _patch(
    id,
    SyncQueueRowsCompanion(
      state: const Value(SyncQueueState.inFlight),
      updatedAtUtcMs: Value(nowUtcMs),
    ),
  );

  Future<void> markSynced(int id, int nowUtcMs) => _patch(
    id,
    SyncQueueRowsCompanion(
      state: const Value(SyncQueueState.synced),
      lastError: const Value(null),
      updatedAtUtcMs: Value(nowUtcMs),
    ),
  );

  Future<void> scheduleRetry(
    int id, {
    required int nextAttemptAtUtcMs,
    required String? lastError,
    required int nowUtcMs,
  }) async {
    final row = await byId(id);
    if (row == null) return;
    await _patch(
      id,
      SyncQueueRowsCompanion(
        state: const Value(SyncQueueState.pending),
        attemptCount: Value(row.attemptCount + 1),
        nextAttemptAtUtcMs: Value(nextAttemptAtUtcMs),
        lastError: Value(lastError),
        updatedAtUtcMs: Value(nowUtcMs),
      ),
    );
  }

  Future<void> park(
    int id, {
    required String? lastError,
    required int nowUtcMs,
  }) => _patch(
    id,
    SyncQueueRowsCompanion(
      state: const Value(SyncQueueState.parked),
      lastError: Value(lastError),
      updatedAtUtcMs: Value(nowUtcMs),
    ),
  );

  /// Returns `inFlight` rows untouched since [staleBeforeUtcMs] to `pending` and
  /// makes them immediately due again, so a crashed/stuck send is retried
  /// (safe — the idempotency key guards the server). Returns the number
  /// reclaimed.
  Future<int> reclaimStaleInFlight(int staleBeforeUtcMs, int nowUtcMs) =>
      (_db.update(_db.syncQueueRows)..where(
            (t) =>
                t.state.equalsValue(SyncQueueState.inFlight) &
                t.updatedAtUtcMs.isSmallerThanValue(staleBeforeUtcMs),
          ))
          .write(
            SyncQueueRowsCompanion(
              state: const Value(SyncQueueState.pending),
              nextAttemptAtUtcMs: Value(nowUtcMs),
              updatedAtUtcMs: Value(nowUtcMs),
            ),
          );

  /// Bounded parked-item auto-retry, called once per app start: `parked` rows
  /// with fewer than [maxPostParkAttempts] revivals go back to `pending`.
  /// Returns the number revived.
  Future<int> reviveParkedForAppStart(
    int nowUtcMs, {
    int maxPostParkAttempts = 3,
  }) async {
    final revivable =
        await (_db.select(_db.syncQueueRows)..where(
              (t) =>
                  t.state.equalsValue(SyncQueueState.parked) &
                  t.postParkAttemptCount.isSmallerThanValue(
                    maxPostParkAttempts,
                  ),
            ))
            .get();
    for (final row in revivable) {
      await _patch(
        row.id,
        SyncQueueRowsCompanion(
          state: const Value(SyncQueueState.pending),
          postParkAttemptCount: Value(row.postParkAttemptCount + 1),
          nextAttemptAtUtcMs: Value(nowUtcMs),
          updatedAtUtcMs: Value(nowUtcMs),
        ),
      );
    }
    return revivable.length;
  }

  Future<void> _patch(int id, SyncQueueRowsCompanion patch) => (_db.update(
    _db.syncQueueRows,
  )..where((t) => t.id.equals(id))).write(patch);
}
