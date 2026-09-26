// In-memory AppDatabase for widget tests that mount a screen watching Drift
// query streams — e.g. the F05 home, whose read-model watches both
// `journey_progress` and the active-session row (f05 architecture.md §6).
//
// By default drift keeps a stream query alive for one event-loop iteration
// after its last listener cancels, via a zero-duration timer. When the widget
// tree is disposed at the end of a test, that timer is still pending inside
// flutter_test's fake clock ("A Timer is still pending even after the widget
// tree was disposed") and a later `db.close()` waits on it forever. Closing
// streams synchronously is drift's documented option for such test setups.
// Not a test suite itself — no `_test` suffix.

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:looplet_app/persistence/app_database.dart';

AppDatabase widgetTestDatabase() => AppDatabase.forTesting(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);
