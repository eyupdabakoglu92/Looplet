# LOOPLET

A mobile word-based logic puzzle. The player slides rows and columns of a 5×5
letter grid to form a visible target word in the fewest moves. See
`ai-system/product/product-prd.md` for the full product definition.

## Monorepo layout

| Path | What |
| --- | --- |
| `app/` | Flutter application (iOS + Android, portrait) |
| `packages/looplet_core/` | shared value types, Turkish-locale case utility |
| `packages/looplet_dictionary/` | curated word list + validation service (F01) |
| `packages/looplet_engine/` | deterministic grid model / shift / win detection (F02) |
| `packages/looplet_content/` | puzzle definition models + JSON serialization |
| `packages/looplet_solver/` | minimum-move solver library (F06) |
| `tools/looplet_authoring/` | level-authoring CLI (F06) |
| `content/` | versioned puzzle JSON artifacts |
| `infra/` | Firebase config + Cloud Functions (provisioned later) |

Domain packages (`looplet_*`) are pure Dart and import neither Flutter nor Firebase.

## Prerequisites

- Flutter stable (Dart SDK 3.4+)
- melos: `dart pub global activate melos ^6.0.0`

## Canonical commands

Authoritative source: `ai-system/project-authority/setup-manifest.md`.

```sh
melos bootstrap          # resolve all package dependencies (run after any pubspec change)
melos run format:check   # fail if code is not formatted
melos run analyze        # static analysis (all packages + flutter analyze)
melos run test           # unit tests (pure-Dart packages) + flutter test (app)
melos run content:check  # validate committed puzzle artifacts under content/
melos run build:app      # release Android App Bundle
```

## Run the app locally

The Flutter app lives in `app/`. As of now it boots to a placeholder shell
(a dark screen with "LOOPLET" centred) — the game and menu screens are still
being built (features F03, F05, F09, F10). It compiles and runs; there is just
nothing to play yet.

```sh
cd app

# 1. Pick a target
flutter devices            # list connected devices / running simulators
open -a Simulator           # (macOS) boot an iOS simulator, then re-check devices
#   Android: start an emulator from Android Studio, or `flutter emulators --launch <id>`

# 2. Run
flutter run                       # uses the only/attached device
flutter run -d "iPhone 15"        # or target one explicitly by name/id
```

Notes:

- **iOS Simulator** is the least-friction target (Xcode is already set up). A
  physical iPhone needs Developer Mode on the device + a signing team in
  `app/ios` (Xcode → Runner → Signing & Capabilities).
- **Android** needs the Android SDK (Android Studio); it is not required for the
  iOS/simulator path.
- **Web** is not enabled — the app was scaffolded for `ios,android` only. Add it
  with `flutter create --platforms=web .` from `app/` if you want `-d chrome`.
- The authoring CLI (`tools/looplet_authoring`) is a separate build-time tool,
  not the app: `cd tools/looplet_authoring && dart run bin/looplet_authoring.dart --help`.
