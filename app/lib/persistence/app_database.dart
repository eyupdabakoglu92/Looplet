import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show visibleForOverriding;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'guest_id.dart';
import 'migration_guard.dart';

part 'app_database.g.dart';

/// Sync state of a recorded daily result (denormalized mirror of the
/// `sync_queue` item for that key — see [SyncQueueState]).
enum DailySyncStatus { local, queued, synced, parked }

/// Work-queue state for a deferred sync item. `awaitingAuth` (from the F08
/// contract) is represented as `pending` + a null `idempotencyKey`.
enum SyncQueueState { pending, inFlight, synced, parked }

/// Kind of queued sync work.
enum SyncQueueKind { dailyResult }

// ---------------------------------------------------------------------------
// Tables — `ai-system/features/f08-offline-persistence-and-sync/architecture.md`
// → "Persistence Schema". Table names match the contract exactly.
// ---------------------------------------------------------------------------

class Players extends Table {
  @override
  String get tableName => 'player';

  TextColumn get guestId => text()();
  TextColumn get firebaseUid => text().nullable()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {guestId};
}

class SettingsRows extends Table {
  @override
  String get tableName => 'settings';

  TextColumn get guestId => text()();
  BoolColumn get soundEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get hapticsEnabled =>
      boolean().withDefault(const Constant(true))();
  TextColumn get language => text().withDefault(const Constant('tr'))();

  @override
  Set<Column<Object>> get primaryKey => {guestId};
}

class JourneyProgressRows extends Table {
  @override
  String get tableName => 'journey_progress';

  TextColumn get guestId => text()();
  IntColumn get highestUnlockedLevel =>
      integer().withDefault(const Constant(1))();
  TextColumn get completedLevelsCsv => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {guestId};
}

class PersonalBests extends Table {
  @override
  String get tableName => 'personal_best';

  TextColumn get guestId => text()();
  TextColumn get levelId => text()();
  IntColumn get bestMoveCount => integer()();
  IntColumn get stars => integer()();
  BoolColumn get isPerfect => boolean()();
  IntColumn get firstCompletedAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {guestId, levelId};
}

class DailyEntries extends Table {
  @override
  String get tableName => 'daily_entry';

  TextColumn get guestId => text()();
  TextColumn get lang => text()();
  TextColumn get dailyDate => text()();
  TextColumn get dailyId => text()();
  IntColumn get firstRunMoveCount => integer()();
  IntColumn get firstRunDurationMs => integer()();
  IntColumn get firstRunStars => integer()();
  IntColumn get firstRunCompletedAtUtcMs => integer()();
  TextColumn get syncStatus => textEnum<DailySyncStatus>()();

  @override
  Set<Column<Object>> get primaryKey => {guestId, lang, dailyDate};
}

class DailyAttempts extends Table {
  @override
  String get tableName => 'daily_attempt';

  TextColumn get guestId => text()();
  TextColumn get lang => text()();
  TextColumn get dailyDate => text()();
  IntColumn get attemptNo => integer()();
  IntColumn get moveCount => integer()();
  IntColumn get durationMs => integer()();
  IntColumn get stars => integer()();
  IntColumn get completedAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {guestId, lang, dailyDate, attemptNo};
}

class DailyStreaks extends Table {
  @override
  String get tableName => 'daily_streak';

  TextColumn get guestId => text()();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get bestStreak => integer().withDefault(const Constant(0))();
  TextColumn get lastCompletedDate => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {guestId};
}

class DailyPuzzleCacheRows extends Table {
  @override
  String get tableName => 'daily_puzzle_cache';

  TextColumn get lang => text()();
  TextColumn get dailyDate => text()();
  TextColumn get puzzleJson => text()();
  IntColumn get fetchedAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {lang, dailyDate};
}

class SyncQueueRows extends Table {
  @override
  String get tableName => 'sync_queue';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => textEnum<SyncQueueKind>()();

  /// `"{firebaseUid}|{lang}|{dailyDate}"`; null while awaiting Anonymous Auth.
  TextColumn get idempotencyKey => text().nullable()();
  TextColumn get payloadJson => text()();
  TextColumn get state => textEnum<SyncQueueState>()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  IntColumn get postParkAttemptCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get nextAttemptAtUtcMs =>
      integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  IntColumn get createdAtUtcMs => integer()();
  IntColumn get updatedAtUtcMs => integer()();
}

class KvRows extends Table {
  @override
  String get tableName => 'kv';

  TextColumn get key => text()();
  TextColumn get valueJson => text()();
  IntColumn get schemaVersion => integer()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [
    Players,
    SettingsRows,
    JourneyProgressRows,
    PersonalBests,
    DailyEntries,
    DailyAttempts,
    DailyStreaks,
    DailyPuzzleCacheRows,
    SyncQueueRows,
    KvRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens (or creates) the on-device store at
  /// `<app-documents>/looplet.sqlite`.
  AppDatabase() : this.at(defaultStoreFile);

  /// Opens (or creates) the store at the file [locate] resolves, on a
  /// background isolate — the production connection. The bootstrap needs the
  /// path to quarantine an unreadable store (F08 Activation A1).
  AppDatabase.at(Future<File> Function() locate)
    : super(_openConnection(locate));

  /// In-memory database for tests.
  AppDatabase.forTesting(super.executor);

  /// Bumped by any breaking schema change; every `onUpgrade` step is wrapped by
  /// [MigrationGuard.guardPlayerData]. Downgrade is unsupported (`release.md`
  /// §6).
  @override
  int get schemaVersion => 1;

  /// File name of the on-device store.
  static const String storeFileName = 'looplet.sqlite';

  /// Meta `kv` key holding `{ "guestId": ..., "createdAtUtcMs": ... }`.
  static const String storeMetaKey = 'store_meta';

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedDefaults();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Forward-only. Each future step MUST live inside this guard so a
      // release can never drop personal_best / daily_entry / daily_streak
      // rows (F08 architecture → Persistence Schema; F08 AC9). Drift does not
      // wrap `onUpgrade` in a transaction itself: this one makes a throwing
      // step or a guard violation roll everything back — the old DB is kept,
      // with no partial apply (Resilience "Migration step throws").
      await transaction(() async {
        await MigrationGuard.guardPlayerData(this, () async {
          for (var v = from; v < to; v++) {
            try {
              await upgradeStep(m, v);
            } on MigrationDataLossError {
              rethrow;
            } catch (error) {
              // Typed so the bootstrap never mistakes a failing step for an
              // unreadable store (no recreate; keep the old DB).
              throw MigrationStepError(error, fromVersion: v);
            }
          }
        });
      });
    },
  );

  /// One forward step v[from] → v[from]+1. Every future step lands here, inside
  /// the guard above.
  @visibleForOverriding
  Future<void> upgradeStep(Migrator m, int from) async {
    switch (from) {
      // case 1: await _migrateV1toV2(m); break;
      default:
        break;
    }
  }

  Future<void> _seedDefaults() async {
    final guestId = newGuestId();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await transaction(() async {
      await into(
        players,
      ).insert(PlayersCompanion.insert(guestId: guestId, createdAtUtcMs: now));
      await into(
        settingsRows,
      ).insert(SettingsRowsCompanion.insert(guestId: guestId));
      await into(
        journeyProgressRows,
      ).insert(JourneyProgressRowsCompanion.insert(guestId: guestId));
      await into(
        dailyStreaks,
      ).insert(DailyStreaksCompanion.insert(guestId: guestId));
      await into(kvRows).insert(
        KvRowsCompanion.insert(
          key: storeMetaKey,
          valueJson: '{"guestId":"$guestId","createdAtUtcMs":$now}',
          schemaVersion: schemaVersion,
        ),
      );
    });
  }
}

/// `<app-documents>/looplet.sqlite`.
Future<File> defaultStoreFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File(p.join(dir.path, AppDatabase.storeFileName));
}

LazyDatabase _openConnection(Future<File> Function() locate) {
  return LazyDatabase(
    () async => NativeDatabase.createInBackground(await locate()),
  );
}
