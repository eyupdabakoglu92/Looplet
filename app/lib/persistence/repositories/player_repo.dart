import 'package:drift/drift.dart';

import '../app_database.dart';

/// The guest identity row. There is exactly one `player` row, seeded on first
/// launch (`AppDatabase._seedDefaults`). `guestId` is the durable local key;
/// `firebaseUid` is filled asynchronously once Anonymous Auth completes and may
/// stay null forever on a persistently-offline install
/// (F08 architecture → Guest Identity Model).
class PlayerRepo {
  PlayerRepo(this._db);

  final AppDatabase _db;

  Future<Player> current() => _db.select(_db.players).getSingle();

  Future<String> currentGuestId() async => (await current()).guestId;

  Future<String?> currentFirebaseUid() async => (await current()).firebaseUid;

  /// Records the Anonymous Auth UID (write-through). Idempotent.
  Future<void> setFirebaseUid(String firebaseUid) async {
    final guestId = await currentGuestId();
    await (_db.update(_db.players)..where((t) => t.guestId.equals(guestId)))
        .write(PlayersCompanion(firebaseUid: Value(firebaseUid)));
  }
}
