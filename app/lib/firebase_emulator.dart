import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

// Debug-only Firebase emulator wiring — test tooling (F08 `architecture.md`
// Activation 2026-09-29 A3). Nothing here runs in a profile or release build.

const String _emulatorDefine = String.fromEnvironment(
  'LOOPLET_FIREBASE_EMULATOR',
);

/// The project the local emulators run as (`infra/functions` `test:emulator`,
/// `firebase emulators:start --project demo-looplet`) — a `demo-` project
/// never reaches a real Firebase backend.
const String firebaseEmulatorProjectId = 'demo-looplet';

/// Emulator ports (`infra/firebase.json`).
const int firebaseAuthEmulatorPort = 9099;
const int firebaseFirestoreEmulatorPort = 8080;
const int firebaseFunctionsEmulatorPort = 5001;

/// Name of the Firebase app used against the emulators. A named app, because
/// on iOS the default app keeps the project of `GoogleService-Info.plist`
/// whatever options Dart passes, and the Functions emulator serves
/// `/<projectId>/…` for [firebaseEmulatorProjectId] only.
const String firebaseEmulatorAppName = 'looplet-emulator';

/// The emulator host of `--dart-define=LOOPLET_FIREBASE_EMULATOR=<host>`, or
/// null. The gate: [debugBuild] is `kDebugMode` at every call site, a
/// compile-time constant, so a profile or release build never connects to an
/// emulator whatever the define says.
String? firebaseEmulatorHost({
  required bool debugBuild,
  String define = _emulatorDefine,
}) {
  if (!debugBuild) return null;
  final host = define.trim();
  return host.isEmpty ? null : host;
}

FirebaseApp? _emulatorApp;

/// The Firebase app the app talks to: the emulator app once
/// [initializeEmulatorFirebaseApp] ran (debug only), otherwise the default
/// app. Throws `[core/no-app]` before any init — callers resolve it lazily.
FirebaseApp loopletFirebaseApp() => _emulatorApp ?? Firebase.app();

/// Initializes the named emulator app as [firebaseEmulatorProjectId] and
/// points Auth, Firestore and Functions at [host].
Future<void> initializeEmulatorFirebaseApp(String host) async {
  final app = await Firebase.initializeApp(
    name: firebaseEmulatorAppName,
    options: DefaultFirebaseOptions.currentPlatform.copyWith(
      projectId: firebaseEmulatorProjectId,
    ),
  );
  await FirebaseAuth.instanceFor(
    app: app,
  ).useAuthEmulator(host, firebaseAuthEmulatorPort);
  FirebaseFirestore.instanceFor(
    app: app,
  ).useFirestoreEmulator(host, firebaseFirestoreEmulatorPort);
  FirebaseFunctions.instanceFor(
    app: app,
  ).useFunctionsEmulator(host, firebaseFunctionsEmulatorPort);
  _emulatorApp = app;
  debugPrint(
    'firebase: emulators at $host (auth $firebaseAuthEmulatorPort, '
    'firestore $firebaseFirestoreEmulatorPort, functions '
    '$firebaseFunctionsEmulatorPort, project $firebaseEmulatorProjectId)',
  );
}
