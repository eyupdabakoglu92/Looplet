# F01 — dictionary-service: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In Progress**

---

## Current Owner

Frontend/Mobile Developer

---

## Current Phase

Frontend Development (scaffold complete; implementation of `looplet_core` normalization + `looplet_dictionary` service)

---

## Active Task Ledger

- [x] Task ID: F01.0-PS | Assigned Role: Project Setup | Status: Done | Summary: Melos monorepo + 6 pure-Dart packages + Flutter `app` scaffolded per `setup-manifest.md` Steps 1–7. Verified: `melos bootstrap` (7 pkgs), `format:check`, `analyze`, `test` all green; `flutter build ios --release --no-codesign` green. `melos run build:app` (Android) not run locally — no Android SDK on this machine; CI covers it. No dependency substitutions needed.
- [ ] Task ID: F01.1-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: `TurkishCase` + `normalize` in `looplet_core` per `architecture.md` "Turkish Normalization (CONTRACT)".
- [ ] Task ID: F01.2-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: `looplet_dictionary` public API exactly as `architecture.md` "Public API" block, incl. `DictionaryAssetSource` + `DictionaryLogger`; wire the `app/pubspec.yaml` asset declaration + `rootBundle` source.
- [ ] Task ID: F01.3-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: Asset loading + indexing; decide + record in-memory representation vs a measured footprint target.
- [ ] Task ID: F01.4-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: Fail-safe semantics (missing/corrupt/empty asset) + `StateError` for query-before-load / after-dispose.
- [ ] Task ID: F01.5-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: Language isolation; `en` stub; `switchLanguage` leaves no residue.
- [ ] Task ID: F01.6-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: Ship provisional reviewed `assets/tr/dictionary.json` + `assets/en/dictionary.json` stub incl. 5-letter `targets`.
- [ ] Task ID: F01.7-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: AC-to-test mapping, golden QA word set, `frontend.md` with traceability + representation decision + per-AC evidence.

---

## QA Scope

* client-only (package-level, automated `dart test`; no device runtime required — see `architecture.md` QA Focus and `platform.md` §10)

---

## Release Scope

* none

---

## Open Tasks

### Project Setup
- [x] (F01.0-PS) Create the melos-managed monorepo exactly as `platform.md` §3 "Monorepo Layout" specifies. Minimum for this feature:
  * root `melos.yaml`, root `pubspec.yaml`, `.gitignore`, `analysis_options.yaml` (shared lints), `README.md`
  * `packages/looplet_core/` — pure-Dart package, `pubspec.yaml` (no Flutter dep), `lib/looplet_core.dart`, `test/` with one passing smoke test
  * `packages/looplet_dictionary/` — pure-Dart package depending only on `looplet_core`; `lib/looplet_dictionary.dart`; `assets/tr/` and `assets/en/` folders present; `test/` with one passing smoke test
  * `app/` — minimal Flutter app skeleton that builds (`flutter build` passes); no feature screens required yet
  * placeholder package folders for `looplet_engine`, `looplet_solver`, `looplet_content`, `tools/looplet_authoring`, and top-level `content/`, `infra/` MAY be stubbed but are not required to compile for F01
  * GitHub Actions workflow running the `platform.md` / `release.md` §4 CI gates (format, analyze, `dart test` across packages, `flutter build`)
  * Confirm `dart format --set-exit-if-changed`, `dart analyze`, and `dart test` are green across `looplet_core` + `looplet_dictionary`
  * Hand off to Frontend/Mobile Developer per `Next Role`

### Frontend
- [ ] (F01.1-FE) Implement `TurkishCase` + `normalize` in `looplet_core` per `architecture.md` "Turkish Normalization (CONTRACT)": explicit `İ↔i`, `I↔ı`, `Ç Ğ Ö Ş Ü` map; letters-only enforcement; circumflex kept distinct. Table tests over the full `Ç Ğ İ I Ö Ş Ü` set including `İ ≠ I`.
- [ ] (F01.2-FE) Implement `looplet_dictionary` public API exactly as the `architecture.md` "Public API" block: `DictionaryService.load`, `switchLanguage`, `isValidWord({minLength})`, `isEligibleTarget`, `normalize`, `isFailSafe`, `dispose`; `DictionaryAssetSource` + `DictionaryLogger` abstractions.
- [ ] (F01.3-FE) Asset loading + indexing: parse the `dictionary.json` contract shape, defensively re-normalize/dedupe/sort on load, build the validity + target lookups. Decide and record the in-memory representation against a measured low-end footprint target (Open Technical Decision → document choice + measurement in `frontend.md`).
- [ ] (F01.4-FE) Fail-safe semantics: missing / corrupt / empty asset → completed `load`, `isFailSafe == true`, all lookups `false`, correct diagnostic (`dictionary.asset.missing|corrupt|empty`); `StateError` only for query-before-load / query-after-dispose.
- [ ] (F01.5-FE) Language isolation: `en` stub asset wired; `switchLanguage` fully replaces the active index with no residue; `en` uses ordinary Unicode lowercasing.
- [ ] (F01.6-FE) Ship an initial reviewed `assets/tr/dictionary.json` (provisional list acceptable for development if the curated corpus is not yet delivered — see F01 PRD Open Questions) and a minimal `assets/en/dictionary.json` stub. Include the curated 5-letter `targets` array.
- [ ] (F01.7-FE) Tests: map every F01 PRD Acceptance Criterion to a `dart test`; add the golden "must-accept / must-reject" QA word set, length-rule tests, malformed-input tests, fail-safe tests, language-isolation test. Produce `frontend.md` with task-to-code traceability, the in-memory-representation decision + measurement, preserved-behavior notes (n/a — greenfield), and per-AC test evidence.

### QA
- [ ] (F01.1-QA) Acceptance Criteria + contract verification: every AC in `features/f01-dictionary-service/prd.md` and every rule in `architecture.md` "API / Event Contract" is covered by a passing automated test; public API signature matches the contract exactly.
- [ ] (F01.2-QA) Turkish correctness + misuse matrix: `İ ≠ I` distinct keys; casing invariance; full normalization table; non-letter / empty / whitespace / over-long input returns `false` without throw; `minLength` short-circuits before a scan.
- [ ] (F01.3-QA) Fail-safe + language isolation: corrupt/missing/empty asset → no crash, `isFailSafe`, all `false`, correct log code; `en` service cannot see `tr` entries; `switchLanguage` leaves no residue; query-before-load / after-dispose → `StateError`.
- [ ] (F01.4-QA) Evidence class check: confirm `automated functional` evidence is sufficient per `platform.md` §10 (no device runtime needed); confirm CI runs the F01 suites. Emit QA verdict → Tech Lead.

---

## Blockers

* None.
* Non-blocking note (scaffold): `melos run build:app` (Android App Bundle) was **not** verified locally — this machine has no Android SDK (`flutter doctor`: "Unable to locate Android SDK"). The iOS release build passed locally (`Built build/ios/iphoneos/Runner.app`). The Android gate runs in CI (`.github/workflows/ci.yml`, `subosito/flutter-action` provides the SDK). If CI's Android build fails, that is a scaffold follow-up, not an F01 logic issue.
* Non-blocking note (content): the production-quality curated Turkish corpus + target-word review is a Product Owner / content deliverable (F01 PRD Open Questions). Implementation proceeds with a provisional reviewed list; swapping in the final asset is a content change, not code, and does not re-open F01 code.

---

## Last Decision

* 2026-09-03 — Tech Lead (greenfield bootstrap):
  * F01 selected as the first feature: P0, no dependencies, hard dependency for F02 and F06.
  * Complexity = SIMPLE/MODERATE. **No Technical Analyst** (single cohesive module, ACs already Given/When/Then, no multi-service / realtime / auth). **No UI Designer** (pure infrastructure, zero screens).
  * Repo is unscaffolded → DURUM 0: Project Setup runs first (F01.0-PS), then Frontend/Mobile Developer implements the package, then QA (client-only, automated).
  * Contract locked in `architecture.md`: public Dart API, `dictionary.json` asset shape, Turkish normalization spec (`İ ≠ I`, circumflex kept distinct), fail-safe semantics, `looplet_dictionary` may depend only on `looplet_core`.
  * Release Scope = none.
* 2026-09-03 — Tech Lead (blocker resolution): authored `project-authority/setup-manifest.md`. Scaffold decisions locked there: melos ^6 monorepo; all `looplet_*` packages scaffolded now as compiling skeletons (not just F01's two) so F02/F06 devs fill logic rather than re-scaffold; `app` gets Riverpod + go_router + Drift + sqlite libs now, **no Firebase packages** until the F07/F08/F12 `infra` DURUM 0; containerization N/A; version-substitution rule = nearest lower compatible, same major, recorded.
* 2026-09-03 — Project Setup (scaffold outcome): all manifest dependency constraints resolved as written (melos 6.3.3, flutter_riverpod 2.6.1, go_router 14.8.1, drift/drift_dev 2.31.0, build_runner 2.15.1) — **no substitutions**. Toolchain: Flutter 3.32.8 / Dart 3.8.1. `app` kept Flutter's generated `flutter_lints ^4.0.0` line to match the pure packages' `lints ^4.0.0`. `app` SDK floor left at Flutter's generated `^3.8.1` (pure packages stay `>=3.4.0 <4.0.0`). iOS deployment target raised to 13.0 in `AppFrameworkInfo.plist` + `Runner.xcodeproj` (3 configs); Android `minSdk = 24`. Android bundle build unverified locally (no Android SDK) — CI gate covers it.

---

## Last Update

* Updated By: Project Setup
* Timestamp: 2026-09-03
* Summary: Executed F01.0-PS. Scaffolded the melos monorepo: root config (`melos.yaml`, `pubspec.yaml`, shared `analysis_options.yaml`, `.gitignore`, `README.md`, `.github/workflows/ci.yml` with SHA-pinned actions), 6 pure-Dart packages (`looplet_core`, `looplet_dictionary` + `assets/tr|en`, `looplet_engine`, `looplet_content`, `looplet_solver`, `tools/looplet_authoring`) each with a compiling barrel + passing smoke test, and the Flutter `app` (portrait-locked, path deps + Riverpod/go_router/Drift/sqlite libs, NO Firebase, iOS 13.0 / Android minSdk 24, placeholder shell). `content/` + `infra/` README stubs. All manifest dependency versions resolved as specified — no substitutions. Verified green: `melos bootstrap` (7 pkgs), `format:check`, `analyze` (6 pkgs + `flutter analyze`), `test` (6 smoke tests + app widget test), `flutter build ios --release --no-codesign`. `melos run build:app` deferred to CI (no local Android SDK). Not committed to git.

---

## Next Role

Frontend/Mobile Developer

---

## Next Action

### Frontend/Mobile Developer

```text
Start F01.1-FE, then continue F01.2-FE … F01.7-FE per the Active Task Ledger.

Authority: features/f01-dictionary-service/architecture.md is contract authority; features/f01-dictionary-service/prd.md
holds the Acceptance Criteria; project-authority/platform.md §11 has the Turkish-locale HARD RULE and naming/localization rules.

F01.1-FE — looplet_core (packages/looplet_core):
- Implement `TurkishCase.toLowerTr(String)` / `toUpperTr(String)` with the explicit map from architecture.md
  "Turkish Normalization (CONTRACT)": I→ı, İ→i, ı→I, i→İ; Ç↔ç, Ğ↔ğ, Ö↔ö, Ş↔ş, Ü↔ü; all other letters ordinary casing.
- Implement `normalize(String)` = toLowerTr + trim, returning null if any character is not a Turkish/Latin letter
  (do NOT return an empty string, do NOT throw).
- Circumflex vowels (â î û) are DISTINCT letters — never stripped by normalize.
- İ and I must normalize to different code points (i vs ı) → different keys. This is the pivotal test.
- Replace the `loopletCoreReady` placeholder; keep the barrel export surface clean (export the public API from lib/looplet_core.dart).
- Tests: full table over Ç Ğ İ I Ö Ş Ü (upper↔lower both directions), İ≠I, all-caps vs lowercase vs mixed-case equality
  after normalize, non-letter/empty/whitespace → null, circumflex preserved.

Then F01.2-FE onward: implement the looplet_dictionary public API exactly as architecture.md "Public API"
(DictionaryService.load / switchLanguage / isValidWord({minLength}) / isEligibleTarget / normalize / isFailSafe / dispose;
DictionaryAssetSource + DictionaryLogger). Add the dictionary asset declaration + a rootBundle-backed DictionaryAssetSource
to app/pubspec.yaml + app code (currently commented out in app/pubspec.yaml). Parse the dictionary.json contract shape,
re-normalize/dedupe/sort defensively on load, and record the in-memory-representation decision + a measured footprint in frontend.md.

Verify with: melos run format:check && melos run analyze && melos run test  (from repo root).
Produce features/f01-dictionary-service/frontend.md: task-to-code traceability, the representation decision + measurement,
per-AC test evidence, preserved-behavior = n/a (greenfield).
On completion set Next Role = QA (client-only) per architecture.md QA Focus.
```

---

## Change Log

* v1 (2026-09-03) — Tech Lead greenfield bootstrap. F01 feature created and activated; Current Owner = Project Setup for DURUM 0 scaffold; routing plan Project Setup → Frontend/Mobile Developer → QA → Tech Lead.
* v2 (2026-09-03) — Project Setup: blocked. `setup-manifest.md` missing (mandatory input). No scaffold performed. Blocker raised, Next Role → Tech Lead to author the manifest.
* v3 (2026-09-03) — Tech Lead: authored `project-authority/setup-manifest.md` (LOOPLET stack recipe, Steps 1–7 + canonical commands, containerization N/A). Blocker cleared. Current Status → In Progress; Next Role → Project Setup to execute F01.0-PS.
* v4 (2026-09-03) — Project Setup: F01.0-PS done. Melos monorepo scaffolded (6 pure-Dart packages + Flutter `app`), all gates green except Android bundle build (deferred to CI — no local Android SDK). No dep substitutions. Current Owner → Frontend/Mobile Developer; Next Role → Frontend/Mobile Developer for F01.1-FE. Scaffold on disk, uncommitted.
