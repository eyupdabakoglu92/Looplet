import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/persistence/active_session_snapshot.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/repositories/active_session_repo.dart';
import 'package:looplet_app/persistence/repositories/daily_puzzle_cache.dart';
import 'package:looplet_app/persistence/repositories/daily_repo.dart';
import 'package:looplet_app/persistence/repositories/daily_streak_repo.dart';
import 'package:looplet_app/persistence/repositories/journey_progress_repo.dart';
import 'package:looplet_app/persistence/repositories/personal_best_repo.dart';
import 'package:looplet_app/persistence/repositories/player_repo.dart';
import 'package:looplet_app/persistence/repositories/settings_repo.dart';

void main() {
  late AppDatabase db;
  late String guestId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    guestId = await PlayerRepo(db).currentGuestId();
  });
  tearDown(() => db.close());

  group('ActiveSessionRepo.watch (F05-FE3-HOME)', () {
    ActiveSessionSnapshot snapshot(String puzzleId) => ActiveSessionSnapshot(
      puzzleId: puzzleId,
      puzzleSource: PuzzleSource.journey,
      lang: 'tr',
      appliedMoves: const <String>['R1'],
      undosRemaining: 3,
      restartCount: 0,
      elapsedMsAccumulated: 4200,
      thawedFrozenCells: const <String>[],
      status: ActiveSessionStatus.inProgress,
      startedAtUtcMs: 1757145000000,
      lastPersistedAtUtcMs: 1757145004200,
    );

    /// Consecutive duplicates collapsed — Drift may re-emit an unchanged row
    /// when another `kv` key is written; only real transitions matter here.
    List<String?> transitions(List<String?> seen) => <String?>[
      for (var i = 0; i < seen.length; i++)
        if (i == 0 || seen[i] != seen[i - 1]) seen[i],
    ];

    test('emits the current value, then every save and clear', () async {
      final repo = ActiveSessionRepo(db);
      final seen = <String?>[];
      final sub = repo.watch().listen((s) => seen.add(s?.puzzleId));
      await pumpEventQueue();

      await repo.save(snapshot('journey-tr-02'));
      await pumpEventQueue();
      await repo.save(snapshot('journey-tr-03'));
      await pumpEventQueue();
      await repo.clear();
      await pumpEventQueue();
      await sub.cancel();

      expect(transitions(seen), <String?>[
        null,
        'journey-tr-02',
        'journey-tr-03',
        null,
      ]);
    });

    test(
      'a corrupt row is discarded and emits null, without looping',
      () async {
        await db
            .into(db.kvRows)
            .insertOnConflictUpdate(
              KvRowsCompanion.insert(
                key: ActiveSessionSnapshot.kvKey,
                valueJson: '{not json',
                schemaVersion: ActiveSessionSnapshot.currentSnapshotVersion,
              ),
            );
        final seen = <String?>[];
        final sub = ActiveSessionRepo(
          db,
        ).watch().listen((s) => seen.add(s?.puzzleId));
        await pumpEventQueue();
        await sub.cancel();

        expect(seen, isNotEmpty);
        expect(seen, everyElement(isNull));
        // The corrupt emission + the delete's re-emission — then it settles.
        expect(seen.length, lessThanOrEqualTo(3));
        final row =
            await (db.select(db.kvRows)
                  ..where((t) => t.key.equals(ActiveSessionSnapshot.kvKey)))
                .getSingleOrNull();
        expect(row, isNull);
      },
    );
  });

  group('PlayerRepo', () {
    test('setFirebaseUid writes through, idempotently', () async {
      final repo = PlayerRepo(db);
      expect(await repo.currentFirebaseUid(), isNull);
      await repo.setFirebaseUid('anon-uid-1');
      expect(await repo.currentFirebaseUid(), 'anon-uid-1');
      await repo.setFirebaseUid('anon-uid-1');
      expect(await repo.currentFirebaseUid(), 'anon-uid-1');
    });
  });

  group('SettingsRepo', () {
    test('toggles persist', () async {
      final repo = SettingsRepo(db);
      await repo.setSoundEnabled(guestId, false);
      await repo.setHapticsEnabled(guestId, false);
      await repo.setLanguage(guestId, 'en');
      final row = await repo.read(guestId);
      expect(row.soundEnabled, isFalse);
      expect(row.hapticsEnabled, isFalse);
      expect(row.language, 'en');
    });
  });

  group('JourneyProgressRepo', () {
    test(
      'markCompleted records + unlocks the next level, idempotently',
      () async {
        final repo = JourneyProgressRepo(db);
        await repo.markCompleted(guestId, 1);
        await repo.markCompleted(guestId, 2);
        await repo.markCompleted(guestId, 2); // repeat
        final row = await repo.read(guestId);
        expect(await repo.completedLevels(guestId), {1, 2});
        expect(row.highestUnlockedLevel, 3);
        expect(row.completedLevelsCsv, '1,2');
      },
    );

    test(
      'does not lower highestUnlockedLevel on an out-of-order completion',
      () async {
        final repo = JourneyProgressRepo(db);
        await repo.markCompleted(guestId, 5); // unlocks 6
        await repo.markCompleted(guestId, 2); // must not drop to 3
        expect((await repo.read(guestId)).highestUnlockedLevel, 6);
      },
    );
  });

  group('PersonalBestRepo', () {
    test(
      'best move count only decreases; isPerfect + firstCompletedAt',
      () async {
        final repo = PersonalBestRepo(db);

        expect(
          await repo.recordCompletion(
            guestId: guestId,
            levelId: 'L1',
            moveCount: 8,
            stars: 2,
            optimalMoves: 5,
            completedAtUtcMs: 100,
          ),
          isTrue,
        );
        // Worse result → rejected.
        expect(
          await repo.recordCompletion(
            guestId: guestId,
            levelId: 'L1',
            moveCount: 12,
            stars: 1,
            optimalMoves: 5,
            completedAtUtcMs: 200,
          ),
          isFalse,
        );
        // Better + perfect → accepted; first-completion timestamp preserved.
        expect(
          await repo.recordCompletion(
            guestId: guestId,
            levelId: 'L1',
            moveCount: 5,
            stars: 3,
            optimalMoves: 5,
            completedAtUtcMs: 300,
          ),
          isTrue,
        );

        final best = await repo.read(guestId, 'L1');
        expect(best!.bestMoveCount, 5);
        expect(best.stars, 3);
        expect(best.isPerfect, isTrue);
        expect(best.firstCompletedAtUtcMs, 100);
      },
    );
  });

  group('DailyRepo', () {
    test('first run is immutable; later completions become attempts', () async {
      final repo = DailyRepo(db);

      final first = await repo.recordCompletion(
        guestId: guestId,
        lang: 'tr',
        dailyDate: '2026-03-01',
        dailyId: 'd-2026-03-01',
        moveCount: 11,
        durationMs: 60000,
        stars: 2,
        completedAtUtcMs: 1000,
      );
      expect(first, DailyCompletionOutcome.firstRun);

      final replay = await repo.recordCompletion(
        guestId: guestId,
        lang: 'tr',
        dailyDate: '2026-03-01',
        dailyId: 'd-2026-03-01',
        moveCount: 8, // better, but must NOT change the official first run
        durationMs: 40000,
        stars: 3,
        completedAtUtcMs: 2000,
      );
      expect(replay, DailyCompletionOutcome.replay);

      final entry = await repo.firstRun(guestId, 'tr', '2026-03-01');
      expect(entry!.firstRunMoveCount, 11);
      expect(entry.firstRunStars, 2);
      expect(entry.syncStatus, DailySyncStatus.local);

      final attempts = await repo.attempts(guestId, 'tr', '2026-03-01');
      expect(attempts, hasLength(1));
      expect(attempts.single.attemptNo, 2);
      expect(attempts.single.moveCount, 8);

      await repo.recordCompletion(
        guestId: guestId,
        lang: 'tr',
        dailyDate: '2026-03-01',
        dailyId: 'd-2026-03-01',
        moveCount: 9,
        durationMs: 45000,
        stars: 3,
        completedAtUtcMs: 3000,
      );
      final attempts2 = await repo.attempts(guestId, 'tr', '2026-03-01');
      expect(attempts2.map((a) => a.attemptNo), [2, 3]);
    });

    test('setSyncStatus mirrors the queue state', () async {
      final repo = DailyRepo(db);
      await repo.recordCompletion(
        guestId: guestId,
        lang: 'tr',
        dailyDate: '2026-03-02',
        dailyId: 'd2',
        moveCount: 10,
        durationMs: 1,
        stars: 2,
        completedAtUtcMs: 1,
      );
      await repo.setSyncStatus(
        guestId,
        'tr',
        '2026-03-02',
        DailySyncStatus.synced,
      );
      expect(
        (await repo.firstRun(guestId, 'tr', '2026-03-02'))!.syncStatus,
        DailySyncStatus.synced,
      );
    });
  });

  group('DailyStreakRepo', () {
    test('stores exactly what F07 computes', () async {
      final repo = DailyStreakRepo(db);
      await repo.write(
        guestId,
        currentStreak: 3,
        bestStreak: 7,
        lastCompletedDate: '2026-04-10',
      );
      final row = await repo.read(guestId);
      expect(row.currentStreak, 3);
      expect(row.bestStreak, 7);
      expect(row.lastCompletedDate, '2026-04-10');
    });
  });

  group('DailyPuzzleCache', () {
    test('put / get / evictOlderThan', () async {
      final cache = DailyPuzzleCache(db);
      await cache.put(
        lang: 'tr',
        dailyDate: '2026-05-01',
        puzzleJson: '{"a":1}',
        fetchedAtUtcMs: 1,
      );
      await cache.put(
        lang: 'tr',
        dailyDate: '2026-05-10',
        puzzleJson: '{"a":2}',
        fetchedAtUtcMs: 2,
      );

      expect(await cache.get('tr', '2026-05-01'), '{"a":1}');
      expect(await cache.get('tr', '2026-06-01'), isNull);

      final removed = await cache.evictOlderThan('2026-05-05');
      expect(removed, 1);
      expect(await cache.get('tr', '2026-05-01'), isNull);
      expect(await cache.get('tr', '2026-05-10'), '{"a":2}');
    });
  });
}
