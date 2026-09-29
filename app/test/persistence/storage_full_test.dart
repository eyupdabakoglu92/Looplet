// F08-FE13 / F08.STORAGE — the storage-full fault-injection harness (F08
// `architecture.md` → Resilience "Storage full / write error"; AC7;
// Activation 2026-09-29 A4).
//
// A **real file database** on the production connection (`AppDatabase.at`,
// drift's background isolate). `PRAGMA max_page_count` is pinned to the
// current size, then a filler row is grown until its page has no free byte
// left, so the next write that needs one more byte there fails with
// `SQLITE_FULL` (13) — the same error a full disk gives SQLite.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/persistence/active_session_snapshot.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/daily_result_sync_service.dart';
import 'package:looplet_app/persistence/repositories/active_session_repo.dart';
import 'package:looplet_app/persistence/repositories/daily_repo.dart';
import 'package:looplet_app/persistence/repositories/player_repo.dart';
import 'package:looplet_app/persistence/repositories/sync_queue_repo.dart';
import 'package:looplet_app/persistence/store_recovery.dart';
import 'package:looplet_app/play/debug_puzzle_library.dart';
import 'package:looplet_app/play/play_session_controller.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:path/path.dart' as p;

const int _sqliteFull = 13;

late Directory _dir;
late AppDatabase _db;

Future<int> _pragma(String name) async =>
    (await _db.customSelect('PRAGMA $name').getSingle()).data.values.single
        as int;

/// Pins the database to its current page count (a full disk).
Future<void> _lockSize() async {
  expect(await _pragma('freelist_count'), 0, reason: 'no free pages to reuse');
  final pages = await _pragma('page_count');
  await _db.customSelect('PRAGMA max_page_count = $pages').get();
  expect(await _pragma('max_page_count'), pages);
}

/// Frees space again (the player cleared storage).
Future<void> _unlockSize() =>
    _db.customSelect('PRAGMA max_page_count = 1073741823').get();

Future<bool> _fits(String sql, List<Object> args) async {
  try {
    await _db.customStatement(sql, args);
    return true;
  } catch (error) {
    expect(classifyStoreFailure(error).sqliteCode, _sqliteFull);
    return false;
  }
}

/// Grows the text column of one filler row (already inserted) to the largest
/// length that still fits: its page then has no free byte left.
Future<void> _fillPage(String updateSql) async {
  var lo = 0;
  var hi = 8192;
  expect(await _fits(updateSql, <Object>['x' * hi]), isFalse);
  while (hi - lo > 1) {
    final mid = (lo + hi) ~/ 2;
    if (await _fits(updateSql, <Object>['x' * mid])) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  expect(await _fits(updateSql, <Object>['x' * lo]), isTrue);
  expect(await _fits(updateSql, <Object>['x' * (lo + 1)]), isFalse);
}

Future<ActiveSessionSnapshot?> _saved() => ActiveSessionRepo(_db).read();

/// One non-solving row shift (row 2 → right) on smoke-tr-01, committed.
void _move(PlaySessionController c) {
  c.beginDrag(startRow: 2, startCol: 0);
  c.updateDrag(const Offset(40, 0));
  expect(c.endDrag(const Offset(40, 0)), DragResolution.shift);
  expect(c.commitShift(), isFalse, reason: 'not a win');
}

List<String> _captureLog() {
  final lines = <String>[];
  final original = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null) lines.add(message);
  };
  addTearDown(() => debugPrint = original);
  return lines;
}

void main() {
  setUp(() {
    _dir = Directory.systemTemp.createTempSync('looplet-full-');
    final file = File(p.join(_dir.path, AppDatabase.storeFileName));
    _db = AppDatabase.at(() async => file);
  });
  tearDown(() async {
    await _db.close();
    _dir.deleteSync(recursive: true);
  });

  test('the active session: a full store rolls the write back, keeps the '
      'last good snapshot, logs persist_failed, play continues from memory, '
      'and the next boundary retries', () async {
    final log = _captureLog();
    final repo = ActiveSessionRepo(_db);
    final c = PlaySessionController(
      puzzle: const DebugPuzzleLibrary().load('smoke-tr-01'),
      source: PuzzleSource.journey,
      validator: const NeverValidWordValidator(),
      activeSessionRepo: repo,
    );
    addTearDown(c.dispose);
    await c.whenPersisted;
    _move(c);
    await c.whenPersisted;
    final lastGood = await _saved();
    expect(lastGood!.appliedMoves, <String>['R2']);

    // The disk fills up.
    await _db.customStatement(
      "INSERT INTO kv(key, value_json, schema_version) VALUES ('zz-fill', '', 1)",
    );
    await _lockSize();
    await _fillPage("UPDATE kv SET value_json = ? WHERE key = 'zz-fill'");

    _move(c);
    await c.whenPersisted; // the failure is caught inside — never thrown

    // Non-fatal persist_failed with the storage error.
    final failed = log.where((l) => l.startsWith('play: persist_failed'));
    expect(failed, hasLength(1));
    expect(failed.single, contains('(code 13)'));
    // Play continues from memory.
    expect(c.moveCount, 2);
    expect(c.phase, PlaySessionPhase.idle);
    // Rolled back: the last good snapshot, whole, and a sound file.
    final kept = await _saved();
    expect(kept!.toJson(), lastGood.toJson());
    expect(
      (await _db.customSelect('PRAGMA integrity_check').getSingle())
          .data
          .values
          .single,
      'ok',
    );

    // Still full: the next boundary tries again and fails the same way.
    _move(c);
    await c.whenPersisted;
    expect(
      log.where((l) => l.startsWith('play: persist_failed')),
      hasLength(2),
    );
    expect((await _saved())!.toJson(), lastGood.toJson());

    // Space is back: the next boundary persists the whole in-memory session,
    // the moves whose writes failed included.
    await _unlockSize();
    _move(c);
    await c.whenPersisted;
    expect(
      log.where((l) => l.startsWith('play: persist_failed')),
      hasLength(2),
    );
    expect((await _saved())!.appliedMoves, <String>['R2', 'R2', 'R2', 'R2']);
    expect((await _saved())!.moveCount, c.moveCount);
  });

  test(
    'a durable multi-row write: a full store rolls the whole transaction '
    'back — no partial write (the queue item and the daily_entry mirror)',
    () async {
      final player = PlayerRepo(_db);
      final daily = DailyRepo(_db);
      final queue = SyncQueueRepo(_db);
      final guest = await player.currentGuestId();
      final sync = DailyResultSyncService(
        db: _db,
        queue: queue,
        daily: daily,
        player: player,
        sender: (_) async => SyncSendResult.retryable,
        isSyncEnabled: () async => false,
      );
      addTearDown(sync.dispose);

      // The durable first run (the last good state), recorded while there is
      // space: `daily_entry` is a never-dropped table.
      expect(
        await daily.recordCompletion(
          guestId: guest,
          lang: 'tr',
          dailyDate: '2026-09-29',
          dailyId: 'daily-tr-2026-09-29',
          moveCount: 12,
          durationMs: 60000,
          stars: 2,
          completedAtUtcMs: 1759100000000,
        ),
        DailyCompletionOutcome.firstRun,
      );

      // The disk fills up — the daily_entry page has no free byte left.
      await _db.customStatement(
        'INSERT INTO daily_entry(guest_id, lang, daily_date, daily_id, '
        'first_run_move_count, first_run_duration_ms, first_run_stars, '
        "first_run_completed_at_utc_ms, sync_status) VALUES (?, 'tr', "
        "'1999-01-01', '', 1, 1, 1, 1, 'synced')",
        <Object>[guest],
      );
      await _lockSize();
      await _fillPage(
        "UPDATE daily_entry SET daily_id = ? WHERE daily_date = '1999-01-01'",
      );

      // Enqueue = one transaction: the queue insert (fits: an empty table's
      // page) + the mirror `local` → `queued` (one more byte: does not fit).
      // SQLite rolls the transaction back itself on SQLITE_FULL; drift then
      // reports its own ROLLBACK as a CouldNotRollBackException carrying it.
      await expectLater(
        sync.enqueueFirstRun(
          DailyResultPayload(
            lang: 'tr',
            dailyDate: '2026-09-29',
            dailyId: 'daily-tr-2026-09-29',
            moves: 12,
            optimalMoves: 8,
            durationMs: 60000,
            stars: 2,
            completedAtUtcMs: 1759100000000,
          ),
        ),
        throwsA(
          predicate<Object>((e) => classifyStoreFailure(e).sqliteCode == 13),
        ),
      );

      // Nothing of the transaction persisted; the first run is intact.
      expect(
        await queue.all(),
        isEmpty,
        reason: 'the queue insert rolled back',
      );
      final entry = await daily.firstRun(guest, 'tr', '2026-09-29');
      expect(entry!.syncStatus, DailySyncStatus.local);
      expect(entry.firstRunMoveCount, 12);
      expect(entry.firstRunCompletedAtUtcMs, 1759100000000);
    },
  );
}
