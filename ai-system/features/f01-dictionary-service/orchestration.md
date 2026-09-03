# F01 — dictionary-service: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In QA**

---

## Current Owner

QA

---

## Current Phase

QA (client-only, automated — `looplet_core` + `looplet_dictionary` + app wiring)

---

## Active Task Ledger

- [x] Task ID: F01.0-PS | Assigned Role: Project Setup | Status: Done | Summary: Melos monorepo + 6 pure-Dart packages + Flutter `app` scaffolded per `setup-manifest.md` Steps 1–7. All gates green except Android bundle build (CI-only, no local SDK). No dependency substitutions.
- [x] Task ID: F01.1-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `looplet_core/lib/src/turkish_case.dart` + `normalize.dart`. `İ`≠`I`, circumflex preserved, letters-only → `String?`. 18 tests.
- [x] Task ID: F01.2-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `looplet_dictionary` public API per contract + `app/lib/dictionary/` (rootBundle source + Riverpod providers) + `ProviderScope`.
- [x] Task ID: F01.3-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `dictionary_asset.dart` parse + `_buildIndex` re-normalize/dedupe into `Set<String>`. Representation decision + measurement in `frontend.md` §14.
- [x] Task ID: F01.4-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | Fail-safe on missing/corrupt/empty with exact diagnostic codes; `StateError` after `dispose`. 6 tests.
- [x] Task ID: F01.5-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `LanguageCode.{tr,en}`; per-language `normalizeFn`; `switchLanguage` atomic swap, no residue; `en` stub. 6 tests.
- [x] Task ID: F01.6-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `assets/tr/dictionary.json` (101 provisional words / 30 five-letter targets) + `assets/en/dictionary.json` stub.
- [x] Task ID: F01.7-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | 56 tests; `qa_word_set_test.dart` golden set vs the real shipped asset; `frontend.md` delivered.
- [ ] Task ID: F01.1-QA | Assigned Role: QA | Status: Open | Summary: Acceptance Criteria + contract verification (see Open Tasks / QA).
- [ ] Task ID: F01.2-QA | Assigned Role: QA | Status: Open | Summary: Turkish correctness + misuse matrix.
- [ ] Task ID: F01.3-QA | Assigned Role: QA | Status: Open | Summary: Fail-safe + language isolation.
- [ ] Task ID: F01.4-QA | Assigned Role: QA | Status: Open | Summary: Evidence-class check + CI coverage; emit verdict → Tech Lead.

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
- [x] (F01.1-FE) `TurkishCase` + `normalize` in `looplet_core` — done (18 tests).
- [x] (F01.2-FE) `looplet_dictionary` public API + app wiring (rootBundle source + Riverpod providers + ProviderScope) — done.
- [x] (F01.3-FE) Asset loading + indexing; representation = `Set<String>`, decision + measurement in `frontend.md` §14 — done.
- [x] (F01.4-FE) Fail-safe semantics + `StateError` after dispose — done (6 tests). Note: "query before load" is unreachable given `load` is the only constructor.
- [x] (F01.5-FE) Language isolation + `en` stub + atomic `switchLanguage` — done (6 tests).
- [x] (F01.6-FE) `assets/tr/dictionary.json` (101 provisional words / 30 targets) + `assets/en/dictionary.json` stub — done.
- [x] (F01.7-FE) 56 tests incl. golden QA set vs the real shipped asset; `frontend.md` delivered — done.

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

* Updated By: Frontend/Mobile Developer
* Timestamp: 2026-09-03
* Summary: F01.1-FE … F01.7-FE complete. `looplet_core` Turkish case + normalization (`turkish_case.dart`, `normalize.dart`); `looplet_dictionary` full public API (`DictionaryService`, `DictionaryAssetSource`, `DictionaryLogger`+`NoopDictionaryLogger`, `LanguageCode`, `DictionaryAsset`); provisional `assets/tr/dictionary.json` (101 words / 30 five-letter targets) + `assets/en/dictionary.json` stub; app wiring (`app/lib/dictionary/` rootBundle source + Riverpod providers, `ProviderScope` in `main.dart`). Representation = `Set<String>` (decision + footprint projection in `frontend.md` §14). One architecture-note deviation recorded (`frontend.md` §4/§16): dictionary assets are declared by the package's own `pubspec.yaml` `flutter: assets:` section, not by the app — the app-side declaration in `architecture.md` "Integration Rules" does not work in Flutter; no contract impact. Gates green: `format:check`, `analyze` (6 pkgs + `flutter analyze`), `test` (56 tests), `flutter build ios --release --no-codesign`. Not committed to git.

---

## Next Role

QA

---

## Next Action

### QA

```text
Verify F01 (client-only, automated — no device runtime required per architecture.md QA Focus + platform.md §10).

Authority: features/f01-dictionary-service/prd.md (Acceptance Criteria), architecture.md (API / Event Contract,
QA Focus), frontend.md (delivery report + test evidence by task).

F01.1-QA — Acceptance Criteria + contract:
- Walk every AC in prd.md and confirm a passing automated test covers it (frontend.md §17 maps them).
- Confirm the public API signatures in lib match architecture.md "Public API" verbatim (named params,
  isValidWord({int minLength = 1}), normalize -> String?, isFailSafe getter, Future<void> for load/switchLanguage/dispose).
- Confirm the additive-only surface (NoopDictionaryLogger, LanguageCode.fromCode, DictionaryAsset export) does not
  alter contract behavior.

F01.2-QA — Turkish correctness + misuse matrix:
- İ ≠ I produces distinct keys; casing invariance (all-caps == lowercase == mixed); full Ç Ğ İ I Ö Ş Ü table.
- non-letter / empty / whitespace / over-long / q w x / accented-Latin input -> false, never throws.
- minLength short-circuits before a list hit (3-letter word rejected at minLength: 4).

F01.3-QA — Fail-safe + language isolation:
- missing / corrupt / wrong-shape / empty asset -> completed load, isFailSafe == true, all lookups false,
  correct diagnostic code (dictionary.asset.missing|corrupt|empty); no-logger path does not throw.
- query after dispose -> StateError.
- en service cannot see tr entries; switchLanguage both directions leaves no residue; no-op to active language;
  switch to a missing language -> fail-safe.

F01.4-QA — Evidence class + CI:
- Confirm "automated functional" evidence is sufficient (platform.md §10) — no device runtime needed for F01.
- Confirm .github/workflows/ci.yml runs format:check + analyze + test across the workspace (these suites are included).
- Note: melos run build:app (Android) is CI-only locally (no Android SDK on the dev machine); iOS release build passes.

Run from repo root: melos run format:check && melos run analyze && melos run test
Emit a QA verdict (Approved / Approved with Notes / Rejected / Runtime Validation Pending). Next Role after QA is always Tech Lead.
```

---

## Change Log

* v1 (2026-09-03) — Tech Lead greenfield bootstrap. F01 feature created and activated; Current Owner = Project Setup for DURUM 0 scaffold; routing plan Project Setup → Frontend/Mobile Developer → QA → Tech Lead.
* v2 (2026-09-03) — Project Setup: blocked. `setup-manifest.md` missing (mandatory input). No scaffold performed. Blocker raised, Next Role → Tech Lead to author the manifest.
* v3 (2026-09-03) — Tech Lead: authored `project-authority/setup-manifest.md` (LOOPLET stack recipe, Steps 1–7 + canonical commands, containerization N/A). Blocker cleared. Current Status → In Progress; Next Role → Project Setup to execute F01.0-PS.
* v4 (2026-09-03) — Project Setup: F01.0-PS done. Melos monorepo scaffolded (6 pure-Dart packages + Flutter `app`), all gates green except Android bundle build (deferred to CI — no local Android SDK). No dep substitutions. Current Owner → Frontend/Mobile Developer; Next Role → Frontend/Mobile Developer for F01.1-FE. Scaffold on disk, uncommitted.
* v5 (2026-09-03) — Frontend/Mobile Developer: F01.1-FE … F01.7-FE done. `looplet_core` normalization + `looplet_dictionary` service + provisional assets + app wiring. 56 tests green; format/analyze/iOS-build green. One recorded deviation from an `architecture.md` note (assets declared package-side, not app-side — no contract impact; flagged for Tech Lead). Current Owner → QA; Next Role → QA (client-only). Uncommitted.
