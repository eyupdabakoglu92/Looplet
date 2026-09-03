# F01 — dictionary-service: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In Progress**

---

## Current Owner

Project Setup

---

## Current Phase

Planning → Project Scaffold (DURUM 0: repo is not yet scaffolded)

---

## Active Task Ledger

- [ ] Task ID: F01.0-PS | Assigned Role: Project Setup | Status: Open | Summary: Scaffold the melos monorepo + Flutter app skeleton + pure-Dart package skeletons per `project-authority/setup-manifest.md` "Scaffold / Bootstrap Recipe" (Steps 1–7). Unblocked 2026-09-03 — `setup-manifest.md` now exists.

---

## QA Scope

* client-only (package-level, automated `dart test`; no device runtime required — see `architecture.md` QA Focus and `platform.md` §10)

---

## Release Scope

* none

---

## Open Tasks

### Project Setup
- [ ] (F01.0-PS) Create the melos-managed monorepo exactly as `platform.md` §3 "Monorepo Layout" specifies. Minimum for this feature:
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

* None. (Resolved 2026-09-03: `project-authority/setup-manifest.md` created by Tech Lead. The earlier blocker — missing setup manifest — is cleared.)
* Non-blocking note: the production-quality curated Turkish corpus + target-word review is a Product Owner / content deliverable (F01 PRD Open Questions). Implementation proceeds with a provisional reviewed list; swapping in the final asset is a content change, not code, and does not re-open F01 code.

---

## Last Decision

* 2026-09-03 — Tech Lead (greenfield bootstrap):
  * F01 selected as the first feature: P0, no dependencies, hard dependency for F02 and F06.
  * Complexity = SIMPLE/MODERATE. **No Technical Analyst** (single cohesive module, ACs already Given/When/Then, no multi-service / realtime / auth). **No UI Designer** (pure infrastructure, zero screens).
  * Repo is unscaffolded → DURUM 0: Project Setup runs first (F01.0-PS), then Frontend/Mobile Developer implements the package, then QA (client-only, automated).
  * Contract locked in `architecture.md`: public Dart API, `dictionary.json` asset shape, Turkish normalization spec (`İ ≠ I`, circumflex kept distinct), fail-safe semantics, `looplet_dictionary` may depend only on `looplet_core`.
  * Release Scope = none.
* 2026-09-03 — Tech Lead (blocker resolution): authored `project-authority/setup-manifest.md`. Scaffold decisions locked there: melos ^6 monorepo; all `looplet_*` packages scaffolded now as compiling skeletons (not just F01's two) so F02/F06 devs fill logic rather than re-scaffold; `app` gets Riverpod + go_router + Drift + sqlite libs now, **no Firebase packages** until the F07/F08/F12 `infra` DURUM 0; containerization N/A; version-substitution rule = nearest lower compatible, same major, recorded.

---

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-03
* Summary: Resolved the F01.0-PS blocker by authoring `project-authority/setup-manifest.md` for the LOOPLET stack (melos monorepo, `looplet_*` pure-Dart packages, Flutter `app`, CI per `release.md` §4, containerization N/A, Steps 1–7 recipe + canonical commands). F01 unblocked; Current Owner back to Project Setup to execute F01.0-PS.

---

## Next Role

Project Setup

---

## Next Action

### Project Setup

```text
Execute F01.0-PS. Follow project-authority/setup-manifest.md "Scaffold / Bootstrap Recipe" Steps 1–7 exactly:
1. repo root (melos): melos.yaml with the named scripts, root pubspec.yaml, shared analysis_options.yaml, .gitignore,
   README.md, .github/workflows/ci.yml (gates per release.md §4; third-party actions pinned to commit SHA).
2. packages/looplet_core — pure Dart, no flutter dep, barrel + smoke test.
3. packages/looplet_dictionary — pure Dart, depends only on looplet_core, assets/tr/ + assets/en/ (.gitkeep), barrel + smoke test.
4. skeleton packages looplet_engine, looplet_content, looplet_solver — barrels + smoke tests, dependency edges per manifest.
5. tools/looplet_authoring — Dart console package, placeholder main + smoke test.
6. app — flutter create (ios,android), portrait lock, path deps + the listed runtime/dev deps, NO Firebase packages,
   iOS target 13.0 / Android minSdk 24, no feature screens.
7. content/README.md + infra/README.md stubs. Do NOT scaffold infra/functions (future separate DURUM 0).

Then verify green (from repo root):
  melos bootstrap
  melos run format:check
  melos run analyze
  melos run test
  melos run build:app
  flutter build ios --release --no-codesign   (best-effort locally; CI enforces on macOS runner)

Commit all pubspec.lock files. If a listed dependency version does not resolve, pick the nearest lower compatible
version keeping the same major and record the substitution in the Project Setup report — do not change majors or swap packages.
On any conflict with platform.md / release.md / this orchestration, stop and raise a Tech Lead blocker.

On success: close F01.0-PS, set Next Role = Frontend/Mobile Developer, Next Action = F01.1-FE (TurkishCase + normalize in looplet_core).
```

---

## Change Log

* v1 (2026-09-03) — Tech Lead greenfield bootstrap. F01 feature created and activated; Current Owner = Project Setup for DURUM 0 scaffold; routing plan Project Setup → Frontend/Mobile Developer → QA → Tech Lead.
* v2 (2026-09-03) — Project Setup: blocked. `setup-manifest.md` missing (mandatory input). No scaffold performed. Blocker raised, Next Role → Tech Lead to author the manifest.
* v3 (2026-09-03) — Tech Lead: authored `project-authority/setup-manifest.md` (LOOPLET stack recipe, Steps 1–7 + canonical commands, containerization N/A). Blocker cleared. Current Status → In Progress; Next Role → Project Setup to execute F01.0-PS.
