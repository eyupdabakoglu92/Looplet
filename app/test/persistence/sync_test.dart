import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/daily_result_sync_service.dart';
import 'package:looplet_app/persistence/fake_daily_result_producer.dart';
import 'package:looplet_app/persistence/repositories/daily_repo.dart';
import 'package:looplet_app/persistence/repositories/player_repo.dart';
import 'package:looplet_app/persistence/repositories/sync_queue_repo.dart';

/// A controllable clock + a scripted sender.
class _Harness {
  _Harness(this.db)
    : queue = SyncQueueRepo(db),
      daily = DailyRepo(db),
      player = PlayerRepo(db);

  final AppDatabase db;
  final SyncQueueRepo queue;
  final DailyRepo daily;
  final PlayerRepo player;

  int now = 1000000;
  bool syncEnabled = true;
  final List<Map<String, Object?>> sent = <Map<String, Object?>>[];
  late SyncSendResult Function(Map<String, Object?>) reply;

  DailyResultSyncService service() => DailyResultSyncService(
    db: db,
    queue: queue,
    daily: daily,
    player: player,
    clock: () => now,
    jitterRandom: Random(0),
    isSyncEnabled: () async => syncEnabled,
    sender: (payload) async {
      sent.add(payload);
      return reply(payload);
    },
    attemptCap: 3,
    baseDelay: const Duration(seconds: 30),
    maxDelay: const Duration(hours: 6),
    staleInFlightAfter: const Duration(seconds: 20),
  );
}

void main() {
  late AppDatabase db;
  late _Harness h;
  late String guestId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    h = _Harness(db);
    guestId = await h.player.currentGuestId();
    await h.player.setFirebaseUid('uid-1');
    await h.daily.recordCompletion(
      guestId: guestId,
      lang: 'tr',
      dailyDate: '2026-06-01',
      dailyId: 'd-2026-06-01',
      moveCount: 12,
      durationMs: 60000,
      stars: 2,
      completedAtUtcMs: 999,
    );
  });
  tearDown(() => db.close());

  DailyResultPayload payload() => DailyResultPayload(
    lang: 'tr',
    dailyDate: '2026-06-01',
    dailyId: 'd-2026-06-01',
    moves: 12,
    optimalMoves: 8,
    durationMs: 60000,
    stars: 2,
    completedAtUtcMs: 999,
  );

  group('SyncQueueRepo', () {
    test('enqueue dedups on a non-parked idempotency key', () async {
      final a = await h.queue.enqueue(
        kind: SyncQueueKind.dailyResult,
        idempotencyKey: 'uid-1|tr|2026-06-01',
        payloadJson: '{}',
        nowUtcMs: h.now,
      );
      final b = await h.queue.enqueue(
        kind: SyncQueueKind.dailyResult,
        idempotencyKey: 'uid-1|tr|2026-06-01',
        payloadJson: '{}',
        nowUtcMs: h.now,
      );
      expect(b.id, a.id);
      expect(await h.queue.all(), hasLength(1));
    });

    test(
      'duePending respects nextAttemptAt and excludes keyless rows',
      () async {
        await h.queue.enqueue(
          kind: SyncQueueKind.dailyResult,
          idempotencyKey: null, // awaiting auth
          payloadJson: '{}',
          nowUtcMs: h.now,
        );
        final keyed = await h.queue.enqueue(
          kind: SyncQueueKind.dailyResult,
          idempotencyKey: 'uid-1|tr|2026-06-02',
          payloadJson: '{}',
          nowUtcMs: h.now,
        );
        expect(await h.queue.duePending(h.now), hasLength(1));
        await h.queue.scheduleRetry(
          keyed.id,
          nextAttemptAtUtcMs: h.now + 60000,
          lastError: 'x',
          nowUtcMs: h.now,
        );
        expect(await h.queue.duePending(h.now), isEmpty);
        expect(await h.queue.duePending(h.now + 60000), hasLength(1));
      },
    );

    test('reviveParkedForAppStart is bounded to 3 lifetime revivals', () async {
      final row = await h.queue.enqueue(
        kind: SyncQueueKind.dailyResult,
        idempotencyKey: 'uid-1|tr|2026-06-03',
        payloadJson: '{}',
        nowUtcMs: h.now,
      );
      await h.queue.park(row.id, lastError: 'x', nowUtcMs: h.now);
      expect(await h.queue.reviveParkedForAppStart(h.now), 1);
      await h.queue.park(row.id, lastError: 'x', nowUtcMs: h.now);
      expect(await h.queue.reviveParkedForAppStart(h.now), 1);
      await h.queue.park(row.id, lastError: 'x', nowUtcMs: h.now);
      expect(await h.queue.reviveParkedForAppStart(h.now), 1);
      await h.queue.park(row.id, lastError: 'x', nowUtcMs: h.now);
      expect(await h.queue.reviveParkedForAppStart(h.now), 0); // cap hit
    });
  });

  group('DailyResultSyncService', () {
    test(
      'enqueueFirstRun stores one queue row + marks the entry queued',
      () async {
        await h.service().enqueueFirstRun(payload());
        expect(await h.queue.all(), hasLength(1));
        expect(
          (await h.daily.firstRun(guestId, 'tr', '2026-06-01'))!.syncStatus,
          DailySyncStatus.queued,
        );
      },
    );

    test('CREATED → synced (queue + entry mirror), one send', () async {
      final s = h.service();
      h.reply = (_) => SyncSendResult.created;
      await s.enqueueFirstRun(payload());
      await s.drain();
      expect(h.sent, hasLength(1));
      expect(h.sent.single['dailyDate'], '2026-06-01');
      final q = (await h.queue.all()).single;
      expect(q.state, SyncQueueState.synced);
      expect(
        (await h.daily.firstRun(guestId, 'tr', '2026-06-01'))!.syncStatus,
        DailySyncStatus.synced,
      );
    });

    test(
      'ALREADY_SUBMITTED → synced (reconciliation: earlier run wins)',
      () async {
        final s = h.service();
        h.reply = (_) => SyncSendResult.alreadySubmitted;
        await s.enqueueFirstRun(payload());
        await s.drain();
        final entry = (await h.daily.firstRun(guestId, 'tr', '2026-06-01'))!;
        expect(entry.firstRunMoveCount, 12); // untouched by sync
        expect(entry.syncStatus, DailySyncStatus.synced);
        expect((await h.queue.all()).single.state, SyncQueueState.synced);
      },
    );

    test('exactly-once: a repeated enqueue + drain still sends once', () async {
      final s = h.service();
      h.reply = (_) => SyncSendResult.created;
      await s.enqueueFirstRun(payload());
      await s.enqueueFirstRun(payload()); // same key — no new row
      await s.drain();
      await s.drain(); // idempotent
      expect(h.sent, hasLength(1));
      expect(await h.queue.all(), hasLength(1));
    });

    test('retryable → pending with backoff + attemptCount bump', () async {
      final s = h.service();
      h.reply = (_) => SyncSendResult.retryable;
      await s.enqueueFirstRun(payload());
      await s.drain();
      final q = (await h.queue.all()).single;
      expect(q.state, SyncQueueState.pending);
      expect(q.attemptCount, 1);
      expect(q.nextAttemptAtUtcMs, greaterThan(h.now));
      // Not due yet.
      await s.drain();
      expect(h.sent, hasLength(1));
    });

    test('retryable at the attempt cap → parked + entry parked', () async {
      final s = h.service();
      h.reply = (_) => SyncSendResult.retryable;
      await s.enqueueFirstRun(payload());
      for (var i = 0; i < 5; i++) {
        await s.drain();
        h.now += const Duration(hours: 7).inMilliseconds; // always due
      }
      final q = (await h.queue.all()).single;
      expect(q.state, SyncQueueState.parked);
      expect(
        (await h.daily.firstRun(guestId, 'tr', '2026-06-01'))!.syncStatus,
        DailySyncStatus.parked,
      );
    });

    test('nonRetryable → parked immediately', () async {
      final s = h.service();
      h.reply = (_) => SyncSendResult.nonRetryable;
      await s.enqueueFirstRun(payload());
      await s.drain();
      expect((await h.queue.all()).single.state, SyncQueueState.parked);
    });

    test('kill-switch off → no send', () async {
      final s = h.service();
      h.syncEnabled = false;
      h.reply = (_) => SyncSendResult.created;
      await s.enqueueFirstRun(payload());
      await s.drain();
      expect(h.sent, isEmpty);
      expect((await h.queue.all()).single.state, SyncQueueState.pending);
    });

    test(
      'awaitingAuth: keyless item is backfilled once firebaseUid exists',
      () async {
        // Simulate "Anonymous Auth has not completed yet".
        await db.customStatement('UPDATE player SET firebase_uid = NULL');
        final s = h.service();
        h.reply = (_) => SyncSendResult.created;
        await s.enqueueFirstRun(payload());
        var q = (await h.queue.all()).single;
        expect(q.idempotencyKey, isNull);
        await s.drain(); // still keyless → not sent
        expect(h.sent, isEmpty);

        await h.player.setFirebaseUid('uid-late');
        await s.drain();
        q = (await h.queue.all()).single;
        expect(q.idempotencyKey, 'uid-late|tr|2026-06-01');
        expect(q.state, SyncQueueState.synced);
        expect(h.sent, hasLength(1));
      },
    );

    test('stale inFlight is reclaimed and retried safely', () async {
      final s = h.service();
      var replies = 0;
      h.reply = (_) {
        replies++;
        return replies == 1 ? SyncSendResult.retryable : SyncSendResult.created;
      };
      await s.enqueueFirstRun(payload());

      // First drain: mark inFlight then "crash" — simulate by forcing the row
      // back to inFlight and advancing the clock past the stale window.
      await s
          .drain(); // retryable → pending, attemptCount 1, nextAttempt future
      final row = (await h.queue.all()).single;
      await h.queue.markInFlight(row.id, h.now);
      h.now += const Duration(seconds: 25).inMilliseconds;

      await s.drain(); // reclaims the stale inFlight → pending → send → created
      expect((await h.queue.all()).single.state, SyncQueueState.synced);
    });
  });

  group('FakeDailyResultProducer', () {
    test(
      'first produce → firstRun + one queue row; repeat → replay, no new row',
      () async {
        final s = h.service();
        h.reply = (_) => SyncSendResult.created;
        final producer = FakeDailyResultProducer(
          player: h.player,
          daily: h.daily,
          sync: s,
        );

        final first = await producer.produce(
          lang: 'tr',
          dailyDate: '2026-07-04',
          dailyId: 'd-2026-07-04',
        );
        expect(first, DailyCompletionOutcome.firstRun);
        expect(await h.queue.all(), hasLength(1));

        final again = await producer.produce(
          lang: 'tr',
          dailyDate: '2026-07-04',
          dailyId: 'd-2026-07-04',
        );
        expect(again, DailyCompletionOutcome.replay);
        expect(await h.queue.all(), hasLength(1)); // no second enqueue
      },
    );
  });
}
