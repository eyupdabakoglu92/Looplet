import 'package:drift/drift.dart';

import '../app_database.dart';

/// Sound / haptics / language toggles (product PRD §15 `Settings`). Written by
/// F10; read by F10 + F11. Write-through, one row per guest.
class SettingsRepo {
  SettingsRepo(this._db);

  final AppDatabase _db;

  Future<SettingsRow> read(String guestId) => (_db.select(
    _db.settingsRows,
  )..where((t) => t.guestId.equals(guestId))).getSingle();

  Stream<SettingsRow> watch(String guestId) => (_db.select(
    _db.settingsRows,
  )..where((t) => t.guestId.equals(guestId))).watchSingle();

  Future<void> setSoundEnabled(String guestId, bool value) =>
      _write(guestId, SettingsRowsCompanion(soundEnabled: Value(value)));

  Future<void> setHapticsEnabled(String guestId, bool value) =>
      _write(guestId, SettingsRowsCompanion(hapticsEnabled: Value(value)));

  Future<void> setLanguage(String guestId, String value) =>
      _write(guestId, SettingsRowsCompanion(language: Value(value)));

  Future<void> _write(String guestId, SettingsRowsCompanion patch) =>
      (_db.update(
        _db.settingsRows,
      )..where((t) => t.guestId.equals(guestId))).write(patch);
}
