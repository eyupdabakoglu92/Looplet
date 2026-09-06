# System State — LOOPLET

Last Updated: 2026-09-06 (F06 closed — QA Approved with Notes; F08 offline-persistence-and-sync activated → Technical Analyst)

> Global workflow snapshot. Stack/runtime authority lives in `project-authority/platform.md`; release authority in `project-authority/release.md`. This file carries the current snapshot only.

---

# 1. SYSTEM INITIALIZATION

## Platform Initialized

* Yes — `project-authority/platform.md` produced by Tech Lead (2026-09-03). Stack: Flutter (Dart) client, pure-Dart domain packages, Firebase BaaS backend, Drift (SQLite) persistence.

## Environment Status

* Initialized — melos monorepo (`app` + 6 pure-Dart packages + CI). `melos run format:check` / `analyze` / `test` / `content:check` green (**200 workspace tests**: content 17, core 22, dictionary 32, authoring 19, solver 23, engine 83, app 4). `flutter build ios --release --no-codesign` green. Android `build:app` = CI-only locally (no Android SDK on the dev machine). **Firebase `infra/` not yet provisioned — its DURUM 0 (Project Setup) + app Firebase wiring is now due, triggered within F08 after the Technical Analyst pass defines the minimal sync surface.**

---

# 2. AUTHORITY REFERENCES

## Technical Authority

* `/ai-system/project-authority/platform.md` — Exists (Tech Lead, 2026-09-03). Amended 2026-09-05 (§11 F02 engine-primitive carve-out; §13 forward BFS). Amended 2026-09-06 (§3 + §11 — shared-enum carve-out extended to `PuzzleType` / `DifficultyLabel`: defined in `looplet_core`, re-exported by `looplet_content`, at F06 close-out).

## Setup Authority

* `/ai-system/project-authority/setup-manifest.md` — Exists (Tech Lead, 2026-09-03). Melos monorepo scaffold recipe (Steps 1–7, executed) + canonical Build/Test/Boot commands; containerization N/A.
* Technical Authority updated 2026-09-05: `platform.md` §11 carve-out — engine primitive enums (`MoveAxis`/`MoveDirection`/`TileStatus`/`GridCoord`) live in `looplet_core`, re-exported by `looplet_content`. Extended 2026-09-06 (F06 close-out): `PuzzleType` / `DifficultyLabel` join the same carve-out — defined in `looplet_core` so `looplet_solver` can use `DifficultyLabel` without a `looplet_content` dependency; `looplet_content` re-exports.

## Release Authority

* `/ai-system/project-authority/release.md` — Exists (Tech Lead, 2026-09-03). Release gate: Conditional. F01 / F02 / F06 Release Scope: none. **F08 Release Scope: [PENDING]** — F08 introduces Firebase Functions + Firestore-rules deploy and a Drift forward migration; a DevOps/Release Engineer gate is expected. Scope value + `release.md` update land at F08 contract finalization (after the Technical Analyst pass).

## Product Authority

* `/ai-system/product/product-prd.md` — Exists (Product Owner bootstrap, 2026-09-03)

---

# 3. PRODUCT STATE

## PRD

* Exists: Yes
* Path: `/ai-system/product/product-prd.md`

---

# 4. FEATURE SYSTEM STATE

## Source of Truth

* Feature Board = PRIMARY
* Orchestration = EXECUTION
* System State = GLOBAL SNAPSHOT
* Tech Lead syncs the three surfaces together on state transitions.

## Active Feature

* F08 — offline-persistence-and-sync

## Active Orchestration Path

* `/ai-system/features/f08-offline-persistence-and-sync/orchestration.md`

---

# 5. WORKFLOW STATE

## Current Phase

* Technical Analysis — F08 offline-persistence-and-sync

## Current Role

* Technical Analyst

## Current Reason

* F06 closed 2026-09-06 (QA Approved with Notes; toolchain + smoke set + CI content-check delivered; contract locked & closed; enum-location + `difficultyBreakdown` reconciled into `platform.md` §3/§11 + F06 `architecture.md`; 3 notes carried to `F06-CONTENT`, 1 to the F05/F07/F08 brief backlog). Next on the critical path is **F08** (P0), per `product-prd.md` §12.6 build order (`… F01, F02, F06, F08, F03, F05`) and the feature-board priority ordering — persistence is landed before the F03 play screen so it is designed in, not bolted on. F08 depends only on the F02 state shape (Done). Complexity **COMPLEX**: a new on-device persistence data model (Drift), deferred exactly-once offline-result sync with first-run-authoritative reconciliation, a forward-only migration state machine, and a cross-feature tie to F07 (Daily fetch/cache) — the product PRD leaves the backend sync surface explicitly to the Tech Lead. → Technical Analyst pass (F08.0-AN → `analysis.md`) before contract finalization. **No UI Designer** (Infrastructure; F08 owns no screens — F10 surfaces streak/progress, F03 owns the play session). A Firebase `infra/` DURUM 0 (Project Setup) + app Firebase wiring is a known upcoming step, Tech-Lead-triggered after the analysis defines the minimal sync surface. A DevOps/Release Engineer gate is expected post-QA (Firebase deploy + Drift migration).

## Last Completed Action

* Tech Lead — 2026-09-06 — Closed F06: reconciled QA "Approved with Notes" (non-blocking, no rework); extended the `platform.md` §3/§11 shared-enum carve-out to `PuzzleType` / `DifficultyLabel`; locked `difficultyBreakdown` as required and set F06 `architecture.md` → LOCKED & CLOSED; carried the residual notes to `F06-CONTENT` / the F05-F08 brief backlog. Activated F08 — created `features/f08-offline-persistence-and-sync/` (`prd.md` + initial `architecture.md` skeleton + `orchestration.md`); Complexity COMPLEX → Technical Analyst. Synced `feature-board.md` + `system-state.md`.

## Next Expected Action

* `Run Technical Analyst` — produce `features/f08-offline-persistence-and-sync/analysis.md` per `orchestration.md → Next Action`: resolve the F08 open items (persistence schema + migration strategy; active-session snapshot shape vs F03's future PlaySession; `sync_queue` + exactly-once semantics; first-run-authoritative reconciliation algorithm incl. client-vs-server tie-break; minimal Firebase sync surface — callable vs direct write, App Check posture; offline-Daily boundary vs F07; streak-integrity edge cases from clock/timezone change; corrupt-save / storage-full fallback; guest→account adoptability of every table). Recommend a scope boundary between "persistence core deliverable now" and "sync execution wired with F07", and whether the `infra/` DURUM 0 runs before or after Backend work.

---

# 6. CROSS-FEATURE STATUS

## Portfolio Summary

* 13 features. F01 `Done`, F02 `Done`, F06 `Done`. F08 `In Progress` (Technical Analysis). F03, F04, F05, F07, F09–F13 `Not Started`.
* Priority: P0 = F01✓, F02✓, F06✓, **F08**, F03, F05 · P1 = F04, F09, F10, F07, F12 · P2 = F11, F13.
* Critical path: F01✓ → F02✓ → F06✓ → (**F08**, F03) → F04 → F05 → F09 → F10 → F07 → F13; F12 cross-cutting and release-blocking.
* **`F06-CONTENT`** (full 30 Journey + ~60 Daily authoring) — an **open** Level-Designer follow-on split off from F06; still MVP scope; blocks F05 and F07 from reaching `Done` but did not block F06. Tech Lead schedules it when F05 / F07 need real content.

## Active Rework

* None

## Paused Features

* None

## Blocked Features

* None. Non-blocking note: production-quality curated Turkish corpus + target-word review is a Product Owner / content deliverable (F01 PRD Open Questions); F01 code proceeds on a provisional reviewed list.

---

# 7. GLOBAL CONTRACT SNAPSHOT

## Contract Version

* v1 — established 2026-09-03. Project contract rules in `platform.md` §4. F01 + F02 contracts locked and closed. **F06 contract locked & closed 2026-09-06** (`features/f06-.../architecture.md`): forward-BFS solver over F02's `canonicalKey` + `SearchBudget`; `SolveResult` = `Optimal` | `Unsolvable` | `BudgetExceeded`; `looplet_content` engine-free `Puzzle` model + JSON with **required** `difficultyBreakdown`; `PuzzleType` / `DifficultyLabel` defined in `looplet_core`, re-exported by `looplet_content`; CLI-only `tools/looplet_authoring`; `export` gate; `check` CI content gate; difficulty metric definitions locked (weights/thresholds configurable, tuned in `F06-CONTENT`). `platform.md` §3 + §11 carry the shared-enum carve-out (engine primitives + puzzle-schema enums); §13 forward-BFS (amended 2026-09-05). **F08 contract: not yet started** — Technical Analyst pass in progress; a Firebase sync surface + Drift schema will be locked in `features/f08-.../architecture.md` after analysis.

## Pending Breaking Change

* None

## Active Cross-Feature Contract Migration

* None

---

# 8. SYSTEM HISTORY REFERENCE

* `/ai-system/system-history.md` — not yet created

Kural:

* `system-state.md` carries only the current snapshot.
* Append-only history is maintained in `system-history.md`.

---

# 9. GLOBAL RISKS

* Solver optimality & performance (F06 — **closed 2026-09-06**): the star rating is only fair if the stored optimal is a proven minimum. Delivered — forward BFS over F02's `canonicalKey` + a `SearchBudget` (maxDepth 16 / maxNodes 5M / 30s); minimality BFS-by-construction and **independently verified 3 ways** in QA (IDDFS reference + depth-`m-1` no-solution probe + hand-check); `budgetExceeded` ⇒ not shippable; `check` re-solves every artifact in CI. **Residual (now owned by `F06-CONTENT`):** worst-case node/time on fully-open levels 11–15 (optimal 6–8) — ~4.6 s JIT for optimal 5; mitigations are AOT-compiled `export` or a per-machine `timeBudget` bump. A dictionary corpus change invalidates all frozen-tile `optimalMoves` (must re-`export`; `check` fails until then).
* Difficulty-curve tuning of 30 handcrafted levels (F05/F06) is manual and playtest-heavy and directly drives the Level 5 Reach and retention KPIs.
* Turkish dictionary curation quality (F01) — proper nouns / profanity / abbreviations / archaic exclusion is manual review; frozen-tile UX depends on it. Corpus sourcing is an open Product Owner item.
* Local-timezone daily reset (F07) — clock manipulation, DST, and travel across midnight create streak-integrity edge cases.
* Gesture recognition consistency across devices (F03) — one accidental counted move breaks the "every move matters" promise.
* Analytics completeness (F12) is the §52 validation gate; incomplete or inaccurate instrumentation compromises the expand/iterate decision. Release-blocking. GA4 funnel/retention sufficiency is an assumption in `platform.md` §13.
* No monetization in the MVP — no revenue signal; validation is retention-only (accepted, source §51).
* Persistence schema (F08 — **active**) must be forward-compatible with future account sync — `platform.md` §5 mandates a `guestId` column on player-owned rows and forward-only migrations. Data-loss risk on schema upgrade: `personal_best` / `daily_streak` / `daily_entry` first-run rows must never be dropped or reset by a migration.
* Offline exactly-once daily-result sync (F08 — **active**): the result must reach the server exactly once with no duplicate, and server reconciliation must keep the player's **first completed run** authoritative even when a later offline run syncs first. Client `sync_queue` marks synced only on ack; idempotency keyed by `(guestId, lang, date)` with a Firestore create-only rule (`platform.md` §5–6). Partial sync (network drop mid-request) → idempotent retry. Reconciliation algorithm + client-vs-server tie-break is a Technical Analyst item.
* Active-session durability (F08 — **active**): active puzzle state (grid, move count, undo history, thawed tiles, elapsed time, puzzle ID) must be durably written on every change with no data-loss window before `app_backgrounded`; corrupt-save on launch → fall back to last valid checkpoint or clean state without crashing; storage-full → non-destructive error keeping last good state.
* Firebase `infra/` provisioning (F08 — **active**): first backend feature ⇒ an `infra/` DURUM 0 (Cloud Functions TS + Firestore rules + Remote Config) plus app Firebase-package wiring, neither of which exists yet. Sequencing (before vs after Backend work) is a Tech Lead decision informed by the analysis.
* Firebase Anonymous Auth used as invisible device identity — assumption that this does not count as "login" per PRD §39 (`platform.md` §6). First real exercise is F08.
* Content pipeline (F06) is a hard dependency for F05 and F07 and must be usable early despite being Infrastructure.

---

# 10. SYSTEM NOTES

* Stack/runtime authority is not duplicated here; see `project-authority/platform.md`. Release authority: `project-authority/release.md`.
* Client stack is Flutter (not Unity) — `Frontend/Mobile Developer` is the client implementation role; `Game Developer (Unity)` is not used. Backend Developer owns the Firebase Cloud Functions / Firestore rules surface (from F07/F08/F12 onward).
* When the workflow changes, `feature-board.md`, the relevant `orchestration.md`, and this file are updated in the same pass by the Tech Lead.
* 2026-09-05 — Incident (System/Workflow, resolved): "how do I run the app locally / is it runnable". Runnable: **yes** — `app/` builds for the iOS simulator (`flutter build ios --simulator` green) and boots to a placeholder shell ("LOOPLET" centred); no game/menu screens yet (F03/F05/F09/F10 not started). Fixed: `setup-manifest.md` boot command (`--scope=app` → `--scope="looplet_app"`) and added a "Run the app locally" section to the root `README.md`. F06 flow not affected (continued).
* 2026-09-06 — F06 closed (QA Approved with Notes). `platform.md` §3 + §11 shared-enum carve-out extended to `PuzzleType` / `DifficultyLabel` (defined in `looplet_core`, re-exported by `looplet_content`). F06 `architecture.md` → LOCKED & CLOSED; `difficultyBreakdown` locked as required. `F06-CONTENT` remains an open follow-on. F08 offline-persistence-and-sync activated → Technical Analyst.
* F08 note: this is the first feature to touch Firebase. Per `setup-manifest.md` (Workspace Targets → `infra/`) and `platform.md` §3/§9, an `infra/` DURUM 0 (Project Setup) + app Firebase-package wiring is Tech-Lead-triggered during F08 once the Technical Analyst defines the minimal sync surface. Firebase packages are deliberately absent from `app/pubspec.yaml` until then.
