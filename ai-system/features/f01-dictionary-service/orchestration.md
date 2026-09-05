# F01 — dictionary-service: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**Done**

---

## Current Owner

-

---

## Current Phase

Closed

---

## Active Task Ledger

None — feature terminal (Done, 2026-09-05).

Historical task record (all complete):

- [x] F01.0-PS (Project Setup) — melos monorepo + 6 pure-Dart packages + Flutter `app` scaffolded per `setup-manifest.md` Steps 1–7.
- [x] F01.1-FE … F01.7-FE (Frontend/Mobile Developer) — `looplet_core` Turkish case + normalization; `looplet_dictionary` full public API; provisional `assets/tr|en/dictionary.json`; app wiring (rootBundle source + Riverpod providers + `ProviderScope`). 56 workspace tests.
- [x] F01.1-QA … F01.4-QA (QA) — AC + contract traceability; Turkish correctness + misuse matrix; fail-safe + language isolation; evidence-class + CI. Verdict: **Approved with Notes** (`qa.md`).

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
- [x] (F01.1-QA) AC + contract verification — done (`qa.md` §3/§4/§6).
- [x] (F01.2-QA) Turkish correctness + misuse matrix — done (`qa.md` §4/§10).
- [x] (F01.3-QA) Fail-safe + language isolation — done (`qa.md` §5/§10).
- [x] (F01.4-QA) Evidence class + CI coverage; verdict emitted — done (`qa.md` §0a/§17).

---

## Blockers

* None. QA verdict **Approved with Notes** (2026-09-05) — no blocking issues, no required fixes.
* Non-blocking note (docs — for Tech Lead): `architecture.md` "Integration Rules" says the **app** declares the dictionary assets; that does not work in Flutter. Implementation correctly declares them in `looplet_dictionary`'s own `pubspec.yaml` `flutter: assets:` section (bundle key + abstractions unchanged). Needs an `architecture.md` wording fix only — no code change, no re-QA. (`qa.md` §6/§20, `frontend.md` §4/§16.)
* Non-blocking note (scaffold/CI): `melos run build:app` (Android AAB) not verified locally — no Android SDK on this machine. `flutter analyze` / `flutter test` / `flutter build ios --release --no-codesign` green locally. CI (`.github/workflows/ci.yml`) runs the Android job; Tech Lead to confirm green on first run.
* Non-blocking note (content): production Turkish corpus + curated target review is a Product Owner / content deliverable (F01 PRD Open Questions). Shipped `assets/tr/dictionary.json` is a provisional 101-word list; swapping in the reviewed asset later is a content change, not code, and does not re-open F01 code.

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

* Updated By: Tech Lead
* Timestamp: 2026-09-05
* Summary: F01 closed. Reconciled QA verdict **Approved with Notes** — delivery reconciliation passed (task coverage complete, contract fully preserved per `qa.md` §6, evidence = executed automated suites + independent probe, no required fixes). Notes are genuinely non-blocking; Release Scope = none → no release gate. Terminal cleanup applied (Status = Done, Current Owner = -, Active Task Ledger = None, Next Action = Closed). Applied an additive clarification to `architecture.md` "Integration Rules" documenting the package-declares-its-own-assets bundling mechanism (`LanguageCode.assetPath` / bundle key unchanged — no contract change). `feature-board.md` and `system-state.md` synced in the same turn; F02 (grid-engine) activated.

---

## Next Role

Closed

---

## Next Action

Closed. F01 dictionary-service is Done (2026-09-05). Non-blocking follow-ups tracked in `## Blockers` (architecture clarification applied; Android CI confirmation; provisional-dictionary content swap = PO/content deliverable, no code re-open). Workflow continues at `features/f02-grid-engine/orchestration.md`.

---

## Change Log

* v1 (2026-09-03) — Tech Lead greenfield bootstrap. F01 feature created and activated; Current Owner = Project Setup for DURUM 0 scaffold; routing plan Project Setup → Frontend/Mobile Developer → QA → Tech Lead.
* v2 (2026-09-03) — Project Setup: blocked. `setup-manifest.md` missing (mandatory input). No scaffold performed. Blocker raised, Next Role → Tech Lead to author the manifest.
* v3 (2026-09-03) — Tech Lead: authored `project-authority/setup-manifest.md` (LOOPLET stack recipe, Steps 1–7 + canonical commands, containerization N/A). Blocker cleared. Current Status → In Progress; Next Role → Project Setup to execute F01.0-PS.
* v4 (2026-09-03) — Project Setup: F01.0-PS done. Melos monorepo scaffolded (6 pure-Dart packages + Flutter `app`), all gates green except Android bundle build (deferred to CI — no local Android SDK). No dep substitutions. Current Owner → Frontend/Mobile Developer; Next Role → Frontend/Mobile Developer for F01.1-FE. Scaffold on disk, uncommitted.
* v5 (2026-09-03) — Frontend/Mobile Developer: F01.1-FE … F01.7-FE done. `looplet_core` normalization + `looplet_dictionary` service + provisional assets + app wiring. 56 tests green; format/analyze/iOS-build green. One recorded deviation from an `architecture.md` note (assets declared package-side, not app-side — no contract impact; flagged for Tech Lead). Current Owner → QA; Next Role → QA (client-only). Uncommitted.
* v6 (2026-09-05) — QA: verdict **Approved with Notes**. Client-only automated functional scope. 56 tests + independent QA probe executed green against the real shipped asset. Every prd.md requirement + AC traced to an executed test; contract fully preserved. 2 non-blocking notes (architecture wording; Android CI) + 1 content follow-up. No required fixes. Current Owner → Tech Lead; Next Role → Tech Lead for global-state sync + F02 activation.
* v7 (2026-09-05) — Tech Lead: F01 reconciled and **closed (Done)**. Delivery reconciliation passed; notes non-blocking; no release gate (Release Scope = none). Terminal cleanup applied. `architecture.md` "Integration Rules" clarified (package-declares-assets mechanism; no contract change). `feature-board.md` + `system-state.md` synced same turn. F02 (grid-engine) activated → `features/f02-grid-engine/`.
