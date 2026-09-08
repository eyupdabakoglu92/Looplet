import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../persistence/app_database.dart';
import '../persistence/persistence_providers.dart';

/// The 4–6 column micro-tutorial acknowledged flag (`architecture.md §9`, §14).
/// Stored as a `kv` row — **no F08 schema change** (D2). Absence ⇔ not
/// acknowledged. Single-guest today, so a bare key; registered in the `kv` key
/// registry (`architecture.md §14`).
class JourneyTutorialRepo {
  JourneyTutorialRepo(this._db);

  final AppDatabase _db;

  static const String kvKey = 'journey_col_tutorial_ack';
  static const int _kvSchemaVersion = 1;

  Future<bool> isColumnTutorialAcknowledged() async {
    final row = await (_db.select(
      _db.kvRows,
    )..where((t) => t.key.equals(kvKey))).getSingleOrNull();
    if (row == null) return false;
    try {
      final decoded = jsonDecode(row.valueJson);
      return decoded is Map<String, Object?> && decoded['ack'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Idempotent. Called only when the player completes the gated column shift.
  Future<void> acknowledgeColumnTutorial({DateTime? at}) => _db
      .into(_db.kvRows)
      .insertOnConflictUpdate(
        KvRowsCompanion.insert(
          key: kvKey,
          valueJson: jsonEncode(<String, Object?>{
            'ack': true,
            'atUtcMs': (at ?? DateTime.now().toUtc()).millisecondsSinceEpoch,
          }),
          schemaVersion: _kvSchemaVersion,
        ),
      );
}

final journeyTutorialRepoProvider = Provider<JourneyTutorialRepo>(
  (ref) => JourneyTutorialRepo(ref.watch(appDatabaseProvider)),
);
