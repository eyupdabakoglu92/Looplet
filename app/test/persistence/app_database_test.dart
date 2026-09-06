import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/guest_id.dart';
import 'package:looplet_app/persistence/migration_guard.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('schemaVersion is 1', () {
    expect(db.schemaVersion, 1);
  });

  test('onCreate seeds exactly one player + its singleton rows', () async {
    final player = await db.select(db.players).getSingle();
    expect(isGuestId(player.guestId), isTrue);
    expect(player.firebaseUid, isNull);
    expect(player.createdAtUtcMs, greaterThan(0));

    final settings = await db.select(db.settingsRows).getSingle();
    expect(settings.guestId, player.guestId);
    expect(settings.soundEnabled, isTrue);
    expect(settings.hapticsEnabled, isTrue);
    expect(settings.language, 'tr');

    final journey = await db.select(db.journeyProgressRows).getSingle();
    expect(journey.highestUnlockedLevel, 1);
    expect(journey.completedLevelsCsv, '');

    final streak = await db.select(db.dailyStreaks).getSingle();
    expect(streak.currentStreak, 0);
    expect(streak.bestStreak, 0);
    expect(streak.lastCompletedDate, isNull);
  });

  test('store_meta kv row records the guest id + schema version', () async {
    final meta = await (db.select(
      db.kvRows,
    )..where((t) => t.key.equals(AppDatabase.storeMetaKey))).getSingle();
    expect(meta.schemaVersion, 1);
    final decoded = jsonDecode(meta.valueJson) as Map<String, Object?>;
    final player = await db.select(db.players).getSingle();
    expect(decoded['guestId'], player.guestId);
  });

  test('protected + fresh tables start empty', () async {
    expect(await db.select(db.personalBests).get(), isEmpty);
    expect(await db.select(db.dailyEntries).get(), isEmpty);
    expect(await db.select(db.dailyAttempts).get(), isEmpty);
    expect(await db.select(db.syncQueueRows).get(), isEmpty);
    expect(await db.select(db.dailyPuzzleCacheRows).get(), isEmpty);
  });

  group('MigrationGuard.guardPlayerData', () {
    setUp(() async {
      final g = (await db.select(db.players).getSingle()).guestId;
      await db
          .into(db.personalBests)
          .insert(
            PersonalBestsCompanion.insert(
              guestId: g,
              levelId: 'L1',
              bestMoveCount: 5,
              stars: 3,
              isPerfect: true,
              firstCompletedAtUtcMs: 1,
            ),
          );
      await db
          .into(db.dailyEntries)
          .insert(
            DailyEntriesCompanion.insert(
              guestId: g,
              lang: 'tr',
              dailyDate: '2026-01-01',
              dailyId: 'd1',
              firstRunMoveCount: 10,
              firstRunDurationMs: 1000,
              firstRunStars: 2,
              firstRunCompletedAtUtcMs: 2,
              syncStatus: DailySyncStatus.local,
            ),
          );
    });

    test('passes when a no-op migration keeps rows', () async {
      await MigrationGuard.guardPlayerData(db, () async {});
      expect(await db.select(db.personalBests).get(), hasLength(1));
    });

    test('passes when only a non-protected table changes', () async {
      await MigrationGuard.guardPlayerData(db, () async {
        await db
            .into(db.dailyPuzzleCacheRows)
            .insert(
              DailyPuzzleCacheRowsCompanion.insert(
                lang: 'tr',
                dailyDate: '2026-01-02',
                puzzleJson: '{}',
                fetchedAtUtcMs: 1,
              ),
            );
      });
    });

    test('throws when a migration drops protected rows', () async {
      await expectLater(
        MigrationGuard.guardPlayerData(db, () async {
          await db.delete(db.personalBests).go();
        }),
        throwsA(isA<MigrationDataLossError>()),
      );
    });

    test('throws when a daily_entry row is deleted', () async {
      await expectLater(
        MigrationGuard.guardPlayerData(db, () async {
          await db.delete(db.dailyEntries).go();
        }),
        throwsA(isA<MigrationDataLossError>()),
      );
    });
  });
}
