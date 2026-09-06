import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'app_database.dart';
import 'repositories/daily_repo.dart';
import 'repositories/player_repo.dart';
import 'repositories/sync_queue_repo.dart';

/// The payload for one daily-result submission — matches the
/// `submitDailyResultV1` callable request (F08 architecture → Firebase Sync
/// Surface). `uid` is added server-side from the auth context, never here.
class DailyResultPayload {
  DailyResultPayload({
    required this.lang,
    required this.dailyDate,
    required this.dailyId,
    required this.moves,
    required this.optimalMoves,
    required this.durationMs,
    required this.stars,
    required this.completedAtUtcMs,
    this.clientAttemptNumber = 1,
  });

  final String lang;
  final String dailyDate;
  final String dailyId;
  final int moves;
  final int optimalMoves;
  final int durationMs;
  final int stars;
  final int completedAtUtcMs;
  final int clientAttemptNumber;

  Map<String, Object?> toJson() => <String, Object?>{
    'lang': lang,
    'dailyDate': dailyDate,
    'dailyId': dailyId,
    'moves': moves,
    'optimalMoves': optimalMoves,
    'durationMs': durationMs,
    'stars': stars,
    'completedAtUtcMs': completedAtUtcMs,
    'clientAttemptNumber': clientAttemptNumber,
  };

  static DailyResultPayload fromJson(Map<String, Object?> json) =>
      DailyResultPayload(
        lang: json['lang']! as String,
        dailyDate: json['dailyDate']! as String,
        dailyId: json['dailyId']! as String,
        moves: json['moves']! as int,
        optimalMoves: json['optimalMoves']! as int,
        durationMs: json['durationMs']! as int,
        stars: json['stars']! as int,
        completedAtUtcMs: json['completedAtUtcMs']! as int,
        clientAttemptNumber: (json['clientAttemptNumber'] as int?) ?? 1,
      );
}

/// Outcome of one send attempt, mapped from the callable's response / error
/// (F08 architecture → Firebase Sync Surface → client mapping). The transport
/// implementation (the callable binding) is F08-FE8; this service is testable
/// now with a fake [SyncSender].
enum SyncSendResult {
  /// Server wrote the first-run doc.
  created,

  /// Server already had a first-run doc — reconciliation success (the earlier
  /// run stays authoritative).
  alreadySubmitted,

  /// Transient failure (transport error, timeout, INTERNAL, 5xx) — retry.
  retryable,

  /// Permanent failure (INVALID_PAYLOAD, UNSUPPORTED_LANGUAGE) — park.
  nonRetryable,
}

typedef SyncSender =
    Future<SyncSendResult> Function(Map<String, Object?> payload);

/// Session-level service that delivers offline daily results **exactly once**
/// with **first-run-authoritative** reconciliation.
///
/// Ownership: constructed once at app start and never owned or cancelled by a
/// screen (F08 architecture → Ownership & Lifecycle; `platform.md` §7). Wire the
/// real callable [SyncSender] (F08-FE8) and the connectivity stream (F08-FE9)
/// into it; both are injectable so the queue state machine is unit-testable in
/// isolation.
class DailyResultSyncService {
  DailyResultSyncService({
    required AppDatabase db,
    required SyncQueueRepo queue,
    required DailyRepo daily,
    required PlayerRepo player,
    required SyncSender sender,
    required Future<bool> Function() isSyncEnabled,
    int Function()? clock,
    Random? jitterRandom,
    Stream<bool>? connectivityRegained,
    this.attemptCap = 10,
    this.baseDelay = const Duration(seconds: 30),
    this.maxDelay = const Duration(hours: 6),
    this.staleInFlightAfter = const Duration(seconds: 20),
  }) : _db = db,
       _queue = queue,
       _daily = daily,
       _player = player,
       _sender = sender,
       _isSyncEnabled = isSyncEnabled,
       _clock = clock ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch),
       _jitter = jitterRandom ?? Random() {
    _connectivitySub = connectivityRegained?.listen((_) => drain());
  }

  final AppDatabase _db;
  final SyncQueueRepo _queue;
  final DailyRepo _daily;
  final PlayerRepo _player;
  final SyncSender _sender;
  final Future<bool> Function() _isSyncEnabled;
  final int Function() _clock;
  final Random _jitter;
  StreamSubscription<bool>? _connectivitySub;

  final int attemptCap;
  final Duration baseDelay;
  final Duration maxDelay;
  final Duration staleInFlightAfter;

  bool _draining = false;

  /// Enqueues a first-run result for deferred sync + marks the entry `queued`.
  /// The idempotency key needs `firebaseUid`; if Auth has not completed the item
  /// is stored keyless (`awaitingAuth`) and keyed later by [drain].
  Future<void> enqueueFirstRun(DailyResultPayload payload) async {
    final now = _clock();
    final firebaseUid = await _player.currentFirebaseUid();
    final key = firebaseUid == null
        ? null
        : _idempotencyKey(firebaseUid, payload.lang, payload.dailyDate);
    await _db.transaction(() async {
      await _queue.enqueue(
        kind: SyncQueueKind.dailyResult,
        idempotencyKey: key,
        payloadJson: jsonEncode(payload.toJson()),
        nowUtcMs: now,
      );
      await _daily.setSyncStatus(
        await _player.currentGuestId(),
        payload.lang,
        payload.dailyDate,
        DailySyncStatus.queued,
      );
    });
  }

  /// Processes due queue items once. No-op while `daily_sync_enabled` is false
  /// (Remote Config kill-switch). Safe to call repeatedly / concurrently — a
  /// second call while one is in flight returns immediately.
  Future<void> drain() async {
    if (_draining) return;
    if (!await _isSyncEnabled()) return;
    _draining = true;
    try {
      final now = _clock();
      await _queue.reclaimStaleInFlight(
        now - staleInFlightAfter.inMilliseconds,
        now,
      );
      await _backfillKeys(now);

      for (final row in await _queue.duePending(_clock())) {
        await _process(row);
      }
    } finally {
      _draining = false;
    }
  }

  /// Bounded parked-item retry — call once per app start (F08 architecture:
  /// "on each app start, `parked` items are moved back to `pending` once, up to
  /// `postParkAttemptCount < 3`").
  Future<int> reviveParkedOnAppStart() =>
      _queue.reviveParkedForAppStart(_clock());

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
  }

  // ---- internals ----------------------------------------------------------

  Future<void> _backfillKeys(int now) async {
    final firebaseUid = await _player.currentFirebaseUid();
    if (firebaseUid == null) return;
    for (final row in await _queue.awaitingAuth()) {
      final payload = DailyResultPayload.fromJson(
        jsonDecode(row.payloadJson) as Map<String, Object?>,
      );
      await _queue.setIdempotencyKey(
        row.id,
        _idempotencyKey(firebaseUid, payload.lang, payload.dailyDate),
        now,
      );
    }
  }

  Future<void> _process(SyncQueueRow row) async {
    final now = _clock();
    await _queue.markInFlight(row.id, now);
    final payload = jsonDecode(row.payloadJson) as Map<String, Object?>;

    SyncSendResult result;
    try {
      result = await _sender(payload);
    } catch (error) {
      debugPrint('sync send threw, treating as retryable: $error');
      result = SyncSendResult.retryable;
    }

    switch (result) {
      case SyncSendResult.created:
      case SyncSendResult.alreadySubmitted:
        await _db.transaction(() async {
          await _queue.markSynced(row.id, _clock());
          await _mirrorEntryStatus(payload, DailySyncStatus.synced);
        });
      case SyncSendResult.nonRetryable:
        await _park(row, payload, 'nonRetryable');
      case SyncSendResult.retryable:
        if (row.attemptCount + 1 >= attemptCap) {
          await _park(row, payload, 'attempt cap ($attemptCap) reached');
        } else {
          await _queue.scheduleRetry(
            row.id,
            nextAttemptAtUtcMs: _nextAttemptAt(row.attemptCount + 1),
            lastError: 'retryable',
            nowUtcMs: _clock(),
          );
        }
    }
  }

  Future<void> _park(
    SyncQueueRow row,
    Map<String, Object?> payload,
    String reason,
  ) async {
    await _db.transaction(() async {
      await _queue.park(row.id, lastError: reason, nowUtcMs: _clock());
      await _mirrorEntryStatus(payload, DailySyncStatus.parked);
    });
  }

  Future<void> _mirrorEntryStatus(
    Map<String, Object?> payload,
    DailySyncStatus status,
  ) async {
    await _daily.setSyncStatus(
      await _player.currentGuestId(),
      payload['lang']! as String,
      payload['dailyDate']! as String,
      status,
    );
  }

  int _nextAttemptAt(int attemptCount) {
    final rawMs = baseDelay.inMilliseconds * (1 << attemptCount);
    final cappedMs = rawMs.clamp(0, maxDelay.inMilliseconds);
    // ±20% jitter (F08 architecture → sync_queue backoff).
    final jitterMs = ((_jitter.nextDouble() * 2 - 1) * 0.2 * cappedMs).round();
    return _clock() + (cappedMs + jitterMs).clamp(0, maxDelay.inMilliseconds);
  }

  static String _idempotencyKey(String firebaseUid, String lang, String date) =>
      '$firebaseUid|$lang|$date';
}
