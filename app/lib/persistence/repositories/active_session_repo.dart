import 'dart:convert';

import 'package:drift/drift.dart' show SimpleSelectStatement;
import 'package:flutter/foundation.dart';

import '../active_session_snapshot.dart';
import '../app_database.dart';

/// Reads/writes the in-progress puzzle snapshot as a single transactional `kv`
/// row (`kv['active_session']`) — F08 architecture → Active-Session Snapshot
/// Contract. Write-through: F03 calls [save] on every state-change boundary.
///
/// A corrupt or unreadable snapshot is discarded (durable tables are separate
/// and untouched) and [read] returns null — F08 AC8. The reason is logged.
class ActiveSessionRepo {
  ActiveSessionRepo(this._db);

  final AppDatabase _db;

  Future<void> save(ActiveSessionSnapshot snapshot) => _db
      .into(_db.kvRows)
      .insertOnConflictUpdate(
        KvRowsCompanion.insert(
          key: ActiveSessionSnapshot.kvKey,
          valueJson: jsonEncode(snapshot.toJson()),
          schemaVersion: ActiveSessionSnapshot.currentSnapshotVersion,
        ),
      );

  SimpleSelectStatement<$KvRowsTable, KvRow> _query() =>
      _db.select(_db.kvRows)
        ..where((t) => t.key.equals(ActiveSessionSnapshot.kvKey));

  /// The saved session, or null if there is none or it is corrupt.
  Future<ActiveSessionSnapshot?> read() async =>
      _decode(await _query().getSingleOrNull());

  /// Live view of the saved session: emits the current value on listen, then
  /// again on every [save] / [clear] — the F05 home read-model's second source
  /// (`f05 architecture.md §6`). A corrupt row is discarded exactly as [read]
  /// does; the resulting delete re-emits `null`, so there is no loop.
  Stream<ActiveSessionSnapshot?> watch() =>
      _query().watchSingleOrNull().asyncMap(_decode);

  Future<ActiveSessionSnapshot?> _decode(KvRow? row) async {
    if (row == null) return null;
    try {
      final decoded = jsonDecode(row.valueJson);
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('active_session is not a JSON object');
      }
      return ActiveSessionSnapshot.fromJson(decoded);
    } catch (error, stack) {
      debugPrint('save_corrupt_recovered: discarding active_session — $error');
      FlutterError.dumpErrorToConsole(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'looplet.persistence',
          context: ErrorDescription('reading the active-session snapshot'),
        ),
      );
      await clear();
      return null;
    }
  }

  Future<bool> hasSession() async => (await read()) != null;

  Future<void> clear() => (_db.delete(
    _db.kvRows,
  )..where((t) => t.key.equals(ActiveSessionSnapshot.kvKey))).go();
}
