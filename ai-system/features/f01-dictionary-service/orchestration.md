# F01 — dictionary-service: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**Blocked**

---

## Current Owner

Project Setup

---

## Current Phase

Planning → Project Scaffold (DURUM 0: repo is not yet scaffolded) — BLOCKED: no `setup-manifest.md`

---

## Active Task Ledger

- [ ] Task ID: F01.0-PS | Assigned Role: Project Setup | Status: Blocked | Summary: Scaffold the melos monorepo + Flutter app skeleton + pure-Dart package skeletons per `platform.md` §3, and the `looplet_dictionary` / `looplet_core` package structure with a runnable (empty) test target. BLOCKED — `project-authority/setup-manifest.md` does not exist; it is a mandatory input for `Run Project Setup` and Project Setup may not author the scaffold recipe itself.

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

* **BLOCKER — missing `project-authority/setup-manifest.md`** (raised by Project Setup, 2026-09-03)
  * Owner: Tech Lead
  * Impact: F01.0-PS cannot start. `Run Project Setup` requires `setup-manifest.md` as a mandatory input (new-project-bootstrap-checklist §3 "Must Be Filled Before Specific Role Use" / §8 step 5). The manifest carries the project-specific scaffold recipe + canonical build/test/boot commands. Project Setup is explicitly forbidden from authoring architecture/operational authority or adding dependencies beyond the manifest + platform decisions, so it cannot fabricate this recipe.
  * Resolution needed: Tech Lead creates `project-authority/setup-manifest.md` from `templates/setup-manifest.template.md`, populated for the LOOPLET stack per `platform.md` §3 (melos monorepo; `looplet_core` + `looplet_dictionary` pure-Dart packages; `app/` Flutter skeleton; CI gates per `release.md` §4). Minimum content: workspace targets, scaffold recipe, canonical Build / Test / Boot commands, containerization = N/A, safety rules.
  * After resolution: re-run `Run Project Setup` to execute F01.0-PS.
* Non-blocking note: the production-quality curated Turkish corpus + target-word review is a Product Owner / content deliverable (F01 PRD Open Questions). Implementation proceeds with a provisional reviewed list; swapping in the final asset is a content change, not code, and does not re-open F01 code.

---

## Last Decision

* 2026-09-03 — Tech Lead (greenfield bootstrap):
  * F01 selected as the first feature: P0, no dependencies, hard dependency for F02 and F06.
  * Complexity = SIMPLE/MODERATE. **No Technical Analyst** (single cohesive module, ACs already Given/When/Then, no multi-service / realtime / auth). **No UI Designer** (pure infrastructure, zero screens).
  * Repo is unscaffolded → DURUM 0: Project Setup runs first (F01.0-PS), then Frontend/Mobile Developer implements the package, then QA (client-only, automated).
  * Contract locked in `architecture.md`: public Dart API, `dictionary.json` asset shape, Turkish normalization spec (`İ ≠ I`, circumflex kept distinct), fail-safe semantics, `looplet_dictionary` may depend only on `looplet_core`.
  * Release Scope = none.

---

## Last Update

* Updated By: Project Setup
* Timestamp: 2026-09-03
* Summary: Attempted F01.0-PS. Halted before any scaffold: `project-authority/setup-manifest.md` — a mandatory input for `Run Project Setup` — does not exist, and this role may not author the scaffold recipe. Raised a blocker and routed to Tech Lead. No repo files were created or modified.

---

## Completed Tasks

* None. F01.0-PS not started (blocked — see Blockers). No filesystem changes made.

---

## Next Role

Tech Lead

---

## Next Action

### Tech Lead

```text
Create /ai-system/project-authority/setup-manifest.md from templates/setup-manifest.template.md,
populated for the LOOPLET stack per project-authority/platform.md §3 and project-authority/release.md §4.

Minimum content:
- Workspace Targets: melos monorepo root; packages/looplet_core; packages/looplet_dictionary; app/ (Flutter).
- Scaffold / Bootstrap Recipe for the F01.0-PS scope:
  * melos root: melos.yaml, root pubspec.yaml, .gitignore, shared analysis_options.yaml, README.md
  * packages/looplet_core — pure Dart (no flutter dep), lib barrel + test/ smoke test
  * packages/looplet_dictionary — pure Dart, depends only on looplet_core, lib barrel, assets/tr/ + assets/en/ folders,
    assets declared in pubspec, test/ smoke test
  * app/ — minimal Flutter skeleton that passes release builds for both platforms, no feature screens
  * optional stubs (not required to compile for F01): packages/looplet_engine, packages/looplet_solver,
    packages/looplet_content, tools/looplet_authoring, content/, infra/
  * GitHub Actions workflow running release.md §4 gates; third-party actions pinned to commit SHA
- Canonical Verification Commands:
  * Build: (single canonical command, workspace-qualified)
  * Test: (single canonical command across packages)
  * Boot / dev run: (single canonical command)
- Canonical Containerization Commands: N/A (mobile app; see release.md §6)
- Safety Rules: per template.

Then update this orchestration: clear the blocker, set Current Status = In Progress,
Current Owner = Project Setup, Next Role = Project Setup, Next Action = execute F01.0-PS.
Sync feature-board.md and system-state.md in the same turn.
```

---

## Change Log

* v1 (2026-09-03) — Tech Lead greenfield bootstrap. F01 feature created and activated; Current Owner = Project Setup for DURUM 0 scaffold; routing plan Project Setup → Frontend/Mobile Developer → QA → Tech Lead.
* v2 (2026-09-03) — Project Setup: blocked. `setup-manifest.md` missing (mandatory input). No scaffold performed. Blocker raised, Next Role → Tech Lead to author the manifest.
