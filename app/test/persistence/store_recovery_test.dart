// F08-FE13 — the unreadable-store recovery, the loop guard and the Retry
// reconnect (F08 `architecture.md` → Resilience; Activation 2026-09-29 A1 / A2).
//
// Every bootstrap case runs the production connection: `AppDatabase.at(...)`
// on a real file in a temporary directory, opened on drift's background
// isolate — the path that wraps a SQLite error in a `DriftRemoteException`
// and keeps a failed connection dead.

import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:drift/remote.dart' show DriftRemoteException;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/bootstrap.dart';
import 'package:looplet_app/firebase_emulator.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/daily_result_sync_service.dart';
import 'package:looplet_app/persistence/migration_guard.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/persistence/store_recovery.dart';
import 'package:looplet_app/persistence/sync_providers.dart';
import 'package:path/path.dart' as p;

/// `seed-d3.sh corrupt` writes exactly these bytes.
const String _notADatabase =
    'not a database, just some bytes to fail the open\n'
    'not a database, just some bytes to fail the open\n'
    'not a database, just some bytes to fail the open\n'
    'not a database, just some bytes to fail the open\n'
    'not a database, just some bytes to fail the open\n'
    'not a database, just some bytes to fail the open\n'
    'not a database, just some bytes to fail the open\n'
    'not a database, just some bytes to fail the open\n';

late Directory _dir;
File get _store => File(p.join(_dir.path, AppDatabase.storeFileName));

List<String> _files() =>
    _dir.listSync().map((e) => p.basename(e.path)).toList()..sort();

List<String> _quarantined() =>
    _files().where((n) => n.contains('.corrupt-')).toList();

/// A valid store with a completed level 3 and a personal best on it.
Future<String> _writeGoodStore(File file) async {
  final db = AppDatabase.forTesting(NativeDatabase(file));
  final guest = (await db.select(db.players).getSingle()).guestId;
  await db
      .into(db.personalBests)
      .insert(
        PersonalBestsCompanion.insert(
          guestId: guest,
          levelId: 'journey-tr-03',
          bestMoveCount: 7,
          stars: 3,
          isPerfect: true,
          firstCompletedAtUtcMs: 1,
        ),
      );
  await db.close();
  return guest;
}

/// (player rows, personal_best rows) of the store at [file], read with a
/// plain connection that runs no migration.
Future<(int, int)> _rows(File file) async {
  final raw = NativeDatabase(file);
  final db = AppDatabase.forTesting(raw);
  try {
    final players = await db
        .customSelect('SELECT COUNT(*) c FROM player')
        .getSingle();
    final bests = await db
        .customSelect('SELECT COUNT(*) c FROM personal_best')
        .getSingle();
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 1, reason: 'still schema v1');
    return (players.read<int>('c'), bests.read<int>('c'));
  } finally {
    await db.close();
  }
}

/// A store whose header is intact but whose first page is garbage — the
/// schema query fails with `SQLITE_CORRUPT`.
Future<void> _writeCorruptStore(File file) async {
  await _writeGoodStore(file);
  final bytes = file.readAsBytesSync();
  for (var i = 100; i < 4096; i++) {
    bytes[i] = 0xAB;
  }
  file.writeAsBytesSync(bytes);
}

/// The error of the first query on the production connection to [file].
Future<Object> _firstQueryError(File file) async {
  final db = AppDatabase.at(() async => file);
  try {
    await db.select(db.players).get();
  } catch (error) {
    return error;
  } finally {
    await db.close();
  }
  fail('the first query on $file did not fail');
}

/// The app's graph with the real file connection and inert network edges.
ProviderContainer _container({List<Override> extra = const <Override>[]}) {
  final container = ProviderContainer(
    overrides: <Override>[
      appStoreFileProvider.overrideWithValue(() async => _store),
      syncSenderProvider.overrideWithValue(
        (Map<String, Object?> _) async => SyncSendResult.retryable,
      ),
      connectivityRegainedProvider.overrideWithValue(
        const Stream<bool>.empty(),
      ),
      ...extra,
    ],
  );
  addTearDown(() async {
    await container.read(appDatabaseProvider).close();
    container.dispose();
  });
  return container;
}

Future<AppBootstrap> _boot(ProviderContainer c) =>
    c.read(appBootstrapProvider.future);

/// The Retry of `StoreErrorScreen` (`app_router.dart` `_BootstrapGate`).
Future<AppBootstrap> _retry(ProviderContainer c) {
  c.invalidate(appBootstrapProvider);
  return _boot(c);
}

/// Captures `debugPrint` for the log assertions.
List<String> _captureLog() {
  final lines = <String>[];
  final original = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null) lines.add(message);
  };
  addTearDown(() => debugPrint = original);
  return lines;
}

/// A store whose migration step always throws (schema v2 over a v1 file).
class _FailingStepDatabase extends AppDatabase {
  _FailingStepDatabase(File file, this.error)
    : super.forTesting(NativeDatabase.createInBackground(file));

  final Object error;

  @override
  int get schemaVersion => 2;

  @override
  Future<void> upgradeStep(Migrator m, int from) async => throw error;
}

/// A store whose migration reports data loss (the never-drop guard).
class _DataLossDatabase extends AppDatabase {
  _DataLossDatabase(File file)
    : super.forTesting(NativeDatabase.createInBackground(file));

  @override
  int get schemaVersion => 2;

  @override
  Future<void> upgradeStep(Migrator m, int from) async =>
      customStatement('DELETE FROM personal_best');
}

void main() {
  // Firebase init (fire-and-forget in the bootstrap) then fails quietly on the
  // missing platform channel instead of on a missing binding.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => _dir = Directory.systemTemp.createTempSync('looplet-store-'));
  tearDown(() => _dir.deleteSync(recursive: true));

  group('classifyStoreFailure (A1 rule 1)', () {
    test('NOTADB and CORRUPT are unreadable', () {
      for (final code in <int>[26, 11, 779 /* SQLITE_CORRUPT_INDEX */]) {
        final f = classifyStoreFailure(SqliteException(code, 'x'));
        expect(f.kind, StoreFailureKind.unreadable, reason: 'code $code');
        expect(f.sqliteCode, code & 0xff);
      }
    });

    test('the production connection wraps them in a DriftRemoteException — '
        'still unreadable; CANTOPEN stays other', () async {
      _store.writeAsStringSync(_notADatabase);
      final notADb = await _firstQueryError(_store);
      expect(notADb, isA<DriftRemoteException>());
      expect(classifyStoreFailure(notADb).kind, StoreFailureKind.unreadable);
      expect(classifyStoreFailure(notADb).sqliteCode, 26);

      _store.deleteSync();
      await _writeCorruptStore(_store);
      final corrupt = await _firstQueryError(_store);
      expect(corrupt, isA<DriftRemoteException>());
      expect(classifyStoreFailure(corrupt).kind, StoreFailureKind.unreadable);
      expect(classifyStoreFailure(corrupt).sqliteCode, 11);

      _store.deleteSync();
      Directory(_store.path).createSync();
      final cantOpen = await _firstQueryError(_store);
      expect(cantOpen, isA<DriftRemoteException>());
      expect(classifyStoreFailure(cantOpen).kind, StoreFailureKind.other);
      expect(classifyStoreFailure(cantOpen).sqliteCode, 14);
    });

    test('migration errors are migration failures', () {
      for (final error in <Object>[
        MigrationDataLossError('x'),
        MigrationStepError(SqliteException(11, 'x'), fromVersion: 1),
        CouldNotRollBackException(
          MigrationDataLossError('x'),
          StackTrace.empty,
          SqliteException(1, 'no transaction is active'),
        ),
      ]) {
        expect(classifyStoreFailure(error).kind, StoreFailureKind.migration);
      }
    });

    test('everything else is other', () {
      for (final error in <Object>[
        SqliteException(14, 'cantopen'),
        SqliteException(10, 'ioerr'),
        SqliteException(13, 'full'),
        SqliteException(5, 'busy'),
        // SQLite rolled the transaction back itself; drift's ROLLBACK failed.
        CouldNotRollBackException(
          SqliteException(13, 'full'),
          StackTrace.empty,
          SqliteException(1, 'no transaction is active'),
        ),
        StateError('x'),
        const FileSystemException('x'),
      ]) {
        expect(
          classifyStoreFailure(error).kind,
          StoreFailureKind.other,
          reason: '$error',
        );
      }
    });
  });

  group('quarantineStoreFile (A1 rule 2)', () {
    test('renames the store and its companions; never deletes them', () async {
      _store.writeAsStringSync('main');
      File('${_store.path}-wal').writeAsStringSync('wal');
      File('${_store.path}-shm').writeAsStringSync('shm');
      File('${_store.path}-journal').writeAsStringSync('journal');

      final q = await quarantineStoreFile(_store, utcMs: 1000);

      expect(p.basename(q.path), 'looplet.sqlite.corrupt-1000');
      expect(_files(), <String>[
        'looplet.sqlite.corrupt-1000',
        'looplet.sqlite.corrupt-1000-journal',
        'looplet.sqlite.corrupt-1000-shm',
        'looplet.sqlite.corrupt-1000-wal',
      ]);
      expect(q.readAsStringSync(), 'main');
      expect(File('${q.path}-wal').readAsStringSync(), 'wal');
    });

    test('keeps only the newest quarantined copy', () async {
      _store.writeAsStringSync('first');
      File('${_store.path}-wal').writeAsStringSync('first-wal');
      await quarantineStoreFile(_store, utcMs: 1000);
      _store.writeAsStringSync('second');
      await quarantineStoreFile(_store, utcMs: 2000);

      expect(_files(), <String>['looplet.sqlite.corrupt-2000']);
      expect(
        File(
          p.join(_dir.path, 'looplet.sqlite.corrupt-2000'),
        ).readAsStringSync(),
        'second',
      );
    });
  });

  group('bootstrap recovery (A1 rules 2–5)', () {
    test('NOTADB (the seed-d3.sh corrupt bytes) → quarantined, recreated, '
        'db_reinitialized, ready as a new guest', () async {
      _store.writeAsStringSync(_notADatabase);
      final log = _captureLog();
      final c = _container();

      expect(await _boot(c), isA<AppBootstrapReady>());

      expect(_quarantined(), hasLength(1));
      expect(_quarantined().single, matches(r'^looplet\.sqlite\.corrupt-\d+$'));
      expect(
        File(p.join(_dir.path, _quarantined().single)).readAsStringSync(),
        _notADatabase,
        reason: 'the unreadable bytes are kept, not deleted',
      );
      expect(
        log.where((l) => l.startsWith('store: db_reinitialized')).single,
        contains('SQLITE_NOTADB (26)'),
      );
      // The recreated store is the normal onCreate seed: a new guest, level 1.
      final db = c.read(appDatabaseProvider);
      expect(await db.select(db.players).get(), hasLength(1));
      final journey = await db.select(db.journeyProgressRows).getSingle();
      expect(journey.highestUnlockedLevel, 1);
      expect(journey.completedLevelsCsv, '');
      expect(c.read(storeLaunchStateProvider).recreatedThisLaunch, isTrue);
    });

    test('CORRUPT (a malformed first page) → recovered the same way', () async {
      await _writeCorruptStore(_store);
      final log = _captureLog();
      final c = _container();

      expect(await _boot(c), isA<AppBootstrapReady>());
      expect(_quarantined(), hasLength(1));
      expect(
        log.where((l) => l.startsWith('store: db_reinitialized')).single,
        contains('SQLITE_CORRUPT (11)'),
      );
    });

    test('a good store opens untouched (no quarantine, same guest)', () async {
      final guest = await _writeGoodStore(_store);
      final c = _container();

      expect(await _boot(c), isA<AppBootstrapReady>());
      expect(_quarantined(), isEmpty);
      final db = c.read(appDatabaseProvider);
      expect((await db.select(db.players).getSingle()).guestId, guest);
      expect(await db.select(db.personalBests).get(), hasLength(1));
    });

    test('no store → created (first launch), no quarantine', () async {
      final c = _container();
      expect(await _boot(c), isA<AppBootstrapReady>());
      expect(_quarantined(), isEmpty);
      expect(_store.existsSync(), isTrue);
    });

    test('a MigrationDataLossError → the error screen, the file untouched, '
        'no recreate', () async {
      await _writeGoodStore(_store);
      final log = _captureLog();
      final c = _container(
        extra: <Override>[
          appDatabaseProvider.overrideWith((ref) {
            final db = _DataLossDatabase(_store);
            ref.onDispose(db.close);
            return db;
          }),
        ],
      );

      final result = await _boot(c);
      expect(result, isA<AppBootstrapStoreError>());
      expect(
        (result as AppBootstrapStoreError).kind,
        StoreFailureKind.migration,
      );
      await c.read(appDatabaseProvider).close();
      expect(_quarantined(), isEmpty);
      expect(await _rows(_store), (1, 1), reason: 'data intact (AC9)');
      expect(log.any((l) => l.startsWith('store: migration_failed')), isTrue);
      expect(log.any((l) => l.contains('db_reinitialized')), isFalse);
    });

    test('a throwing migration step — even with a CORRUPT cause — is a '
        'migration failure, never a recreate', () async {
      await _writeGoodStore(_store);
      final c = _container(
        extra: <Override>[
          appDatabaseProvider.overrideWith((ref) {
            final db = _FailingStepDatabase(
              _store,
              SqliteException(11, 'malformed during the step'),
            );
            ref.onDispose(db.close);
            return db;
          }),
        ],
      );

      final result = await _boot(c) as AppBootstrapStoreError;
      expect(result.kind, StoreFailureKind.migration);
      expect(result.message, contains('migration step from v1 failed'));
      await c.read(appDatabaseProvider).close();
      expect(_quarantined(), isEmpty);
      expect(await _rows(_store), (1, 1), reason: 'the old store, intact');
    });

    test('another failure (CANTOPEN: a directory at the store path) → the '
        'error screen, no quarantine', () async {
      Directory(_store.path).createSync();
      final c = _container();

      final result = await _boot(c) as AppBootstrapStoreError;
      expect(result.kind, StoreFailureKind.other);
      expect(result.message, contains('(code 14)'));
      expect(_quarantined(), isEmpty);
      expect(Directory(_store.path).existsSync(), isTrue);
    });
  });

  group('the loop guard (A1 rule 3)', () {
    test('the recreated store fails too → the error state; one recreate, one '
        'quarantine', () async {
      _store.writeAsStringSync(_notADatabase);
      var opened = 0;
      final c = _container(
        extra: <Override>[
          // Every connection sees an unreadable file: the recreate cannot help.
          appDatabaseProvider.overrideWith((ref) {
            opened++;
            if (!_store.existsSync()) _store.writeAsStringSync(_notADatabase);
            final db = AppDatabase.at(() async => _store);
            ref.onDispose(db.close);
            return db;
          }),
        ],
      );

      final result = await _boot(c) as AppBootstrapStoreError;
      expect(result.kind, StoreFailureKind.unreadable);
      expect(opened, 2, reason: 'the original + exactly one recreate');
      expect(_quarantined(), hasLength(1));

      // Retry in the same launch: still unreadable → the error state again,
      // no second recreate / quarantine.
      final again = await _retry(c) as AppBootstrapStoreError;
      expect(again.kind, StoreFailureKind.unreadable);
      expect(opened, 3, reason: 'Retry reconnects but does not recreate');
      expect(_quarantined(), hasLength(1));
    });
  });

  group('Retry reconnects (A2, F08-RETRY-STORE-CONNECTION)', () {
    test('a store fixed between attempts recovers on Retry, without a '
        'relaunch', () async {
      // CANTOPEN: the store path is taken by a directory (the "other" class;
      // the failed background connection stays dead once opened).
      Directory(_store.path).createSync();
      final c = _container();
      final firstDb = c.read(appDatabaseProvider);

      expect(await _boot(c), isA<AppBootstrapStoreError>());
      expect(c.read(storeLaunchStateProvider).connectionStale, isTrue);

      Directory(_store.path).deleteSync(); // the cause goes away

      expect(await _retry(c), isA<AppBootstrapReady>());
      expect(
        identical(c.read(appDatabaseProvider), firstDb),
        isFalse,
        reason: 'Retry ran on a fresh connection',
      );
      expect(c.read(storeLaunchStateProvider).connectionStale, isFalse);
      expect(_quarantined(), isEmpty);
    });

    test('the old connection is closed before the fresh one opens', () async {
      Directory(_store.path).createSync();
      final c = _container();
      final firstDb = c.read(appDatabaseProvider);
      expect(await _boot(c), isA<AppBootstrapStoreError>());
      Directory(_store.path).deleteSync();

      await _retry(c);
      // A closed drift database rejects every query.
      await expectLater(
        firstDb.customSelect('SELECT 1').get(),
        throwsA(anything),
      );
    });

    test('a ready bootstrap leaves the connection alone', () async {
      final c = _container();
      final db = c.read(appDatabaseProvider);
      expect(await _boot(c), isA<AppBootstrapReady>());
      expect(c.read(storeLaunchStateProvider).connectionStale, isFalse);
      expect(identical(c.read(appDatabaseProvider), db), isTrue);
    });
  });

  group('the emulator gate (A3)', () {
    test('off in non-debug builds whatever the define says', () {
      expect(
        firebaseEmulatorHost(debugBuild: false, define: '127.0.0.1'),
        isNull,
      );
      expect(firebaseEmulatorHost(debugBuild: false, define: ''), isNull);
    });

    test('in a debug build: the define, or none', () {
      expect(
        firebaseEmulatorHost(debugBuild: true, define: ' 127.0.0.1 '),
        '127.0.0.1',
      );
      expect(firebaseEmulatorHost(debugBuild: true, define: ''), isNull);
    });

    test('the default define is empty (no emulator unless asked)', () {
      expect(firebaseEmulatorHost(debugBuild: true), isNull);
    });
  });
}
