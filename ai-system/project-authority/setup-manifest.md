# Project Setup Manifest — LOOPLET

> Status: OPERATIONAL. Project-specific scaffold/bootstrap recipe for the `Project Setup` role.
> This file carries operation recipes and canonical commands only — no role or architecture authority.

Last Updated: 2026-09-03
Owner: Tech Lead

---

## Purpose

* Carries the LOOPLET-specific scaffold recipe so no commands live in the prompt layer.
* Single source of the canonical build / test / boot commands.
* Consumed by `Run Project Setup` (one-time, DURUM 0) and by any later role that needs a canonical verification command.

---

## Governing Docs

* Role behavior: `/ai-system/prompts/project-setup.md`
* Platform stack authority: `/ai-system/project-authority/platform.md`
* Release / CI authority: `/ai-system/project-authority/release.md`
* Execution semantics: `/ai-system/role-execution-contract.md`

---

## Workspace Targets

| Target | Purpose | Required | Notes |
| --- | --- | --- | --- |
| repo root (melos) | monorepo orchestration, shared lints, CI | Yes | `melos.yaml`, root `pubspec.yaml`, `analysis_options.yaml`, `.gitignore`, `README.md`, `.github/workflows/ci.yml` |
| `packages/looplet_core` | shared value types, Turkish-locale case utility, Result types | Yes | pure Dart — **no** `flutter` dependency |
| `packages/looplet_dictionary` | F01 dictionary service + curated word-list assets | Yes | pure Dart, depends only on `looplet_core`; ships `assets/tr/` + `assets/en/` |
| `packages/looplet_engine` | F02 grid model / shift / locked-frozen / win | Yes (skeleton) | pure Dart, depends on `looplet_core` |
| `packages/looplet_content` | puzzle definition models + JSON (de)serialization, shared enums | Yes (skeleton) | pure Dart, depends on `looplet_core` |
| `packages/looplet_solver` | F06 minimum-move solver library | Yes (skeleton) | pure Dart, depends on `looplet_engine` |
| `tools/looplet_authoring` | F06 level-authoring CLI | Yes (skeleton) | Dart executable package, depends on `looplet_engine` + `looplet_solver` + `looplet_content` |
| `app` | Flutter application (iOS + Android, portrait) | Yes | depends on all `looplet_*` packages via path |
| `content/` | versioned puzzle JSON artifacts | Yes (folder + README) | populated by F05/F06/F07, not by Project Setup |
| `infra/` | Firebase project config + Cloud Functions (TypeScript) | No | provisioned as a **separate DURUM 0** when the first backend feature (F07/F08/F12) starts; Tech Lead re-triggers Project Setup then. Create `infra/README.md` stub only. |

Skeleton = compiling package with `pubspec.yaml`, a `lib/<name>.dart` barrel exporting a placeholder, and one passing `test/` smoke test. No feature logic.

---

## Scaffold / Bootstrap Recipe

Target directory: repo root — `/Users/eyupcandabakoglu/Projects/Looplet/` (the `ai-system/` folder already exists and is left untouched).

### Global constraints (apply to every step)

* Flutter: stable channel. Dart SDK constraint for every package: `sdk: '>=3.4.0 <4.0.0'`.
* Pure-Dart packages (`looplet_core`, `looplet_dictionary`, `looplet_engine`, `looplet_content`, `looplet_solver`, `tools/looplet_authoring`) must **not** depend on `flutter`, Firebase, or each other beyond the dependency edges in Workspace Targets.
* Inter-package dependencies use `path:` references (melos resolves them locally).
* Shared lints: root `analysis_options.yaml` includes `package:lints/recommended.yaml` plus `implicit-casts: false`, `implicit-dynamic: false`. Every package's `analysis_options.yaml` does `include: ../../analysis_options.yaml` (adjust depth for `app`).
* File naming `snake_case.dart`; do not add dependencies beyond those listed here.
* No feature logic, no normalization code, no dictionary parsing — those are `Frontend/Mobile Developer` tasks (F01.1-FE onward).

### Step 1 — repo root (melos)

1. Create `melos.yaml`:
   * `name: looplet`
   * `packages:` globs → `packages/**`, `tools/**`, `app`
   * `scripts:` (exact names, used as the canonical commands below):
     * `analyze` → `melos exec -- "dart analyze ."` and, scoped to `app`, `flutter analyze`
     * `format:check` → `dart format --output=none --set-exit-if-changed .`
     * `format` → `dart format .`
     * `test` → `melos exec --dir-exists=test -- "dart test"` for pure packages + `melos exec --scope=app -- "flutter test"`
     * `build:app` → `melos exec --scope=app -- "flutter build appbundle --release"`
2. Root `pubspec.yaml`: `name: looplet_workspace`, `environment: sdk: '>=3.4.0 <4.0.0'`, `dev_dependencies: melos: ^6.0.0`.
3. `analysis_options.yaml` (shared, as above).
4. `.gitignore`: Dart/Flutter standard (`.dart_tool/`, `build/`, `.packages`, `*.iml`, `.idea/`, `ios/Pods/`, `android/.gradle/`, `*.g.dart` is **kept** — no codegen in MVP, so nothing generated to ignore beyond `.dart_tool`).
5. `README.md`: one paragraph + the canonical commands from this manifest.
6. `.github/workflows/ci.yml`: per `release.md` §4 — jobs: setup (Flutter stable + `dart pub global activate melos ^6.0.0` + `melos bootstrap`), `melos run format:check`, `melos run analyze`, `melos run test`, `melos run build:app`, `flutter build ios --release --no-codesign` (macOS runner). Pin every third-party action to a commit SHA.

### Step 2 — `packages/looplet_core`

1. `dart create -t package packages/looplet_core` (or equivalent manual layout).
2. `pubspec.yaml`: `name: looplet_core`, SDK constraint as above, `dev_dependencies: {test: ^1.25.0, lints: ^4.0.0}`. No runtime dependencies.
3. `lib/looplet_core.dart`: barrel exporting `src/placeholder.dart` (a single `const loopletCoreReady = true;`).
4. `test/looplet_core_test.dart`: asserts `loopletCoreReady == true`.
5. `analysis_options.yaml`: `include: ../../analysis_options.yaml`.

### Step 3 — `packages/looplet_dictionary`

1. Same package layout as Step 2, `name: looplet_dictionary`.
2. `pubspec.yaml`: `dependencies: {looplet_core: {path: ../looplet_core}}`, `dev_dependencies: {test: ^1.25.0, lints: ^4.0.0}`.
3. Create empty folders `assets/tr/` and `assets/en/` each with a `.gitkeep`. (The real `dictionary.json` assets are authored by `Frontend/Mobile Developer` in F01.6-FE.) Since this is a pure-Dart package, asset *bundling* is the `app`'s responsibility — note in the package README that `app/pubspec.yaml` will declare `packages/looplet_dictionary/assets/**` under `flutter/assets` when F01.2-FE wires the `rootBundle` source.
4. `lib/looplet_dictionary.dart`: barrel exporting `src/placeholder.dart` (`const loopletDictionaryReady = true;`).
5. `test/looplet_dictionary_test.dart`: smoke test.
6. `analysis_options.yaml`: include shared.

### Step 4 — skeleton packages `looplet_engine`, `looplet_content`, `looplet_solver`

For each: package layout as Step 2, correct `name`, dependency edges per Workspace Targets (`looplet_engine` → `looplet_core`; `looplet_content` → `looplet_core`; `looplet_solver` → `looplet_engine`), `dev_dependencies: {test, lints}`, a `lib/<name>.dart` barrel with a `const <name>Ready = true;`, one smoke test, shared `analysis_options.yaml` include.

### Step 5 — `tools/looplet_authoring`

1. Dart **executable** package (`dart create -t console tools/looplet_authoring`), `name: looplet_authoring`, `publish_to: none`.
2. `dependencies:` path refs to `looplet_engine`, `looplet_solver`, `looplet_content`.
3. `bin/looplet_authoring.dart`: `void main(List<String> args) { print('looplet authoring CLI — not yet implemented'); }`.
4. One smoke test in `test/`.

### Step 6 — `app`

1. `flutter create --org com.looplet --project-name looplet_app --platforms=ios,android app`.
2. `app/pubspec.yaml`:
   * `dependencies:` add path refs to `looplet_core`, `looplet_dictionary`, `looplet_engine`, `looplet_content`; add `flutter_riverpod: ^2.5.0`, `go_router: ^14.0.0`, `drift: ^2.18.0`, `sqlite3_flutter_libs: ^0.5.0`, `path_provider: ^2.1.0`, `path: ^1.9.0`.
   * `dev_dependencies:` `flutter_lints: ^4.0.0`, `drift_dev: ^2.18.0`, `build_runner: ^2.4.0`, `integration_test` (sdk).
   * Do **not** add Firebase packages yet — they land with F07/F08/F12 (separate `infra` DURUM 0 + app wiring).
3. Lock orientation to portrait in `main.dart` (`SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`), keep the default counter scaffold otherwise — no feature screens.
4. `app/analysis_options.yaml`: `include: ../analysis_options.yaml` + `include: package:flutter_lints/flutter.yaml`.
5. iOS: set deployment target to 13.0 in `ios/Podfile` / project; Android: `minSdkVersion 24` in `android/app/build.gradle`.
6. Confirm `flutter build appbundle --release` and `flutter build ios --release --no-codesign` both pass.

### Step 7 — `content/` + `infra/`

1. `content/README.md`: "Versioned puzzle JSON artifacts (Journey + Daily). Populated by F05/F06/F07. Schema owned by `packages/looplet_content`."
2. `infra/README.md`: "Firebase project config + Cloud Functions (TypeScript). Provisioned as a separate Project Setup (DURUM 0) when the first backend feature (F07/F08/F12) starts. Do not scaffold here during F01."

### Application rules

* Run `melos bootstrap` after all `pubspec.yaml` files exist; resolve until clean.
* Commit all `pubspec.lock` files (root, every package, `app`) — required green by `release.md` §10.
* If any listed dependency version does not resolve against the current stable Flutter/Dart, pick the nearest lower compatible version, keep the same major, and record the substitution in `frontend.md` / the Project Setup report — do **not** change majors or add alternative packages.
* If a step conflicts with `platform.md` or `release.md`, stop and raise a Tech Lead blocker — do not choose silently.

---

## Canonical Verification Commands

* Build: `melos run build:app`  _(→ `flutter build appbundle --release` in `app/`)_
* Test: `melos run test`  _(→ `dart test` in every package with a `test/` dir + `flutter test` in `app/`)_
* Boot / dev run: `melos exec --scope=app -- "flutter run"`
* Extra verification: `melos run format:check && melos run analyze`
* Bootstrap (run once after scaffold, and after any `pubspec.yaml` change): `melos bootstrap`

---

## Canonical Containerization Commands

* Dockerfile path(s): N/A
* Compose file(s): N/A
* Image build: N/A
* Container run: N/A
* Compose up / down: N/A
* Container smoke test: N/A

Rule: LOOPLET is a mobile app + Firebase-CLI-deployed functions. `release.md` §6 sets "Containerization required: No". No Docker artifacts are created.

---

## Safety Rules

* This manifest carries operation recipe only; it produces no role or architecture authority.
* If the manifest conflicts with a delivery spec (`architecture.md`, `orchestration.md`) or with `platform.md` / `release.md`, `Project Setup` raises a Tech Lead blocker instead of resolving it.
* No dependency or scaffold deviation beyond what is listed here is applied without a Tech Lead decision.
* `backend.md` / `frontend.md` / `game-dev.md` are delivery reports; `Project Setup` does not apply their contents — the respective developer edits project files directly from the second feature onward.
* `Project Setup` runs once (DURUM 0). The `infra/` Firebase/functions workspace is a future, separately Tech-Lead-triggered DURUM 0.
