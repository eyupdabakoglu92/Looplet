import 'dart:io';

import 'package:drift/drift.dart' show CouldNotRollBackException;
import 'package:drift/native.dart' show SqliteException;
import 'package:drift/remote.dart' show DriftRemoteException;
import 'package:path/path.dart' as p;

import 'migration_guard.dart';

/// How the bootstrap treats a failure to open the on-device store (F08
/// `architecture.md` → Activation 2026-09-29 A1 rule 1).
enum StoreFailureKind {
  /// `SQLITE_NOTADB` (26) / `SQLITE_CORRUPT` (11) while opening or on the
  /// first query → quarantine + recreate (the Resilience row, AC8).
  unreadable,

  /// [MigrationDataLossError] or an exception thrown by a migration step
  /// ([MigrationStepError]) → the store-error screen, data intact (AC9).
  migration,

  /// Anything else (`SQLITE_CANTOPEN`, `SQLITE_IOERR`, `SQLITE_FULL`,
  /// `SQLITE_BUSY`, …) → the store-error screen; Retry reconnects (A2).
  other,
}

/// A classified store-open failure.
class StoreFailure {
  const StoreFailure(this.kind, this.error, {this.sqliteCode});

  final StoreFailureKind kind;
  final Object error;

  /// The primary SQLite result code, when the cause is a [SqliteException].
  final int? sqliteCode;

  /// `SQLITE_NOTADB (26)` / `SQLITE_CORRUPT (11)` / `SQLITE_<n>` for the log.
  String get codeLabel => switch (sqliteCode) {
    null => error.runtimeType.toString(),
    sqliteNotADb => 'SQLITE_NOTADB ($sqliteNotADb)',
    sqliteCorrupt => 'SQLITE_CORRUPT ($sqliteCorrupt)',
    final code => 'SQLITE_$code',
  };
}

/// `SQLITE_CORRUPT` — "database disk image is malformed".
const int sqliteCorrupt = 11;

/// `SQLITE_NOTADB` — "file is not a database".
const int sqliteNotADb = 26;

/// Classifies a failure raised while opening the store or running its first
/// query. The production connection runs in a background isolate, so a SQLite
/// error arrives wrapped in a [DriftRemoteException]; it is unwrapped here.
StoreFailure classifyStoreFailure(Object error) {
  final cause = _rootCause(error);
  if (cause is MigrationDataLossError || cause is MigrationStepError) {
    return StoreFailure(StoreFailureKind.migration, error);
  }
  if (cause is! SqliteException) {
    return StoreFailure(StoreFailureKind.other, error);
  }
  // The extended code carries the primary code in its low byte
  // (e.g. SQLITE_CORRUPT_INDEX = 779 → 11).
  final code = cause.extendedResultCode & 0xff;
  final kind = code == sqliteNotADb || code == sqliteCorrupt
      ? StoreFailureKind.unreadable
      : StoreFailureKind.other;
  return StoreFailure(kind, error, sqliteCode: code);
}

/// Unwraps drift's wrappers (possibly nested) to the original error: the
/// isolate wrapper, and the failed `ROLLBACK` after SQLite already rolled a
/// transaction back itself (it does so on `SQLITE_FULL` / `SQLITE_IOERR`).
Object _rootCause(Object error) {
  var current = error;
  while (true) {
    switch (current) {
      case DriftRemoteException(:final remoteCause):
        current = remoteCause;
      case CouldNotRollBackException(:final cause):
        current = cause;
      default:
        return current;
    }
  }
}

/// The SQLite companion files that belong to a database file. `-journal` is
/// included with the contract's `-wal` / `-shm`: the store runs in the default
/// rollback-journal mode, and a stale hot journal left beside a recreated
/// store would be rolled back into it.
const List<String> storeCompanionSuffixes = <String>[
  '-wal',
  '-shm',
  '-journal',
];

/// Moves [store] (and its companions) aside as
/// `<name>.corrupt-<utcMs>` (`-wal` / `-shm` / `-journal` keep their suffix,
/// so the set opens together for a manual support recovery). Never deletes the
/// bytes it quarantines; only an **older** quarantined copy is deleted, so at
/// most the newest one is kept (A1 rule 2). Returns the quarantined file (it
/// may not exist when [store] did not).
Future<File> quarantineStoreFile(File store, {required int utcMs}) async {
  final dir = store.parent;
  final name = p.basename(store.path);
  final quarantined = File(p.join(dir.path, '$name.corrupt-$utcMs'));
  final prefix = '$name.corrupt-';
  final keep = p.basename(quarantined.path);

  if (await store.exists()) await store.rename(quarantined.path);
  for (final suffix in storeCompanionSuffixes) {
    final companion = File('${store.path}$suffix');
    if (await companion.exists()) {
      await companion.rename('${quarantined.path}$suffix');
    }
  }

  // Keep only the newest quarantined copy.
  await for (final entity in dir.list(followLinks: false)) {
    if (entity is! File) continue;
    final base = p.basename(entity.path);
    if (!base.startsWith(prefix)) continue;
    final isCurrent =
        base == keep ||
        storeCompanionSuffixes.any((suffix) => base == '$keep$suffix');
    if (!isCurrent) await entity.delete();
  }
  return quarantined;
}

/// Launch-scoped store state. It lives for the whole app process (the provider
/// is never invalidated), so it survives Retry.
class StoreLaunchState {
  /// Set once the store was quarantined + recreated in this launch. The loop
  /// guard: a later unreadable store in the same launch is an error state,
  /// never a second recreate (A1 rule 3).
  bool recreatedThisLaunch = false;

  /// Set when a bootstrap run ended without a ready store. The next run (only
  /// Retry re-runs it) closes that connection and opens a fresh one (A2).
  bool connectionStale = false;
}
