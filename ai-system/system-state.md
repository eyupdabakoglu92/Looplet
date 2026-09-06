# System State — LOOPLET

Last Updated: 2026-09-06 (F06 closed; F08 activated → Technical Analyst pass done → **F08 contract LOCKED**; next = Project Setup `infra/` Firebase DURUM 0)

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

* `/ai-system/project-authority/setup-manifest.md` — Exists (Tech Lead, 2026-09-03). Melos monorepo scaffold recipe (Steps 1–7, executed) + canonical Build/Test/Boot commands; containerization N/A. **Amended 2026-09-06 (F08):** added `## infra/ DURUM 0 Recipe (Firebase — triggered by F08)` — Firebase project config + `firestore.rules` (create-only) + rules-unit-tests + Cloud Functions TS `submitDailyResultV1` skeleton + emulator smoke + Remote Config template + CI jobs + `app/` Firebase client packages + `connectivity_plus`. Workspace Targets `infra/` row updated (was "stub only" → "run on F08 trigger").
* Technical Authority updated 2026-09-05: `platform.md` §11 carve-out — engine primitive enums (`MoveAxis`/`MoveDirection`/`TileStatus`/`GridCoord`) live in `looplet_core`, re-exported by `looplet_content`. Extended 2026-09-06 (F06 close-out): `PuzzleType` / `DifficultyLabel` join the same carve-out.
* Technical Authority updated 2026-09-06 (F08 contract): `platform.md` §6 — **guest identity decoupled**: `firebaseUid` = Anonymous UID (server identity); `guestId` = durable local UUID v4 (offline-safe, stamped on every player-owned row, account-adoption anchor). `platform.md` §13 — App Check **soft-enforce locked for the MVP** (hard-enforce is post-MVP, not F07/F08); Drift schema + `submitDailyResultV1` callable pointers added. F02 `architecture.md` — `GridEngine.restoreMoves(List<Move>)` promoted to **required by F08** (additive, non-breaking).

## Release Authority

* `/ai-system/project-authority/release.md` — Exists (Tech Lead, 2026-09-03). Release gate: Conditional. F01 / F02 / F06 Release Scope: none. **F08 Release Scope: `production-readiness`** (locked 2026-09-06) — first Firebase deploy (Cloud Functions `submitDailyResultV1` + `firestore.rules` + Remote Config), a **backend-only** release gate per `release.md` §2, distinct from the first app-build distribution gate (still ~F03/F05). `release.md` §2 amended. `F08-DEVOPS` (DevOps/Release Engineer) opens **after F08 QA**; also covers rollback-readiness (functions redeploy-previous, `daily_sync_enabled` kill-switch, no Drift downgrade).

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

* Scaffold (`infra/` Firebase DURUM 0) + persistence core — F08 offline-persistence-and-sync

## Current Role

* Project Setup

## Current Reason

* F08 activated after F06 close (P0, `product-prd.md` §12.6 build order). Technical Analyst pass done (`analysis.md`, 19 sections). **F08 contract finalized 2026-09-06 (F08.CONTRACT-TL) — `architecture.md` LOCKED.** Four Tech Lead calls made: (1) sync surface = HTTPS Callable `submitDailyResultV1` (not a direct client Firestore write); (2) identity = **decouple** `guestId` (durable local UUID v4) from `firebaseUid` (Anonymous UID server identity) — `platform.md` §6 amended; (3) F08↔F07 = **F06-style split** — F08 ships the persistence layer + `DailyPuzzleCache` mechanism + `DailyResultSyncService` (exactly-once + first-run-authoritative reconciliation) + callable + rules + a fake daily-result producer test seam; F07 later wires the real Daily producer; (4) `infra/` DURUM 0 runs **parallel** with the no-Firebase Drift core. App Check soft-enforce locked for the MVP; `product-prd §51` server-side clock check ruled out of the MVP. `Release Scope = production-readiness` (first Firebase deploy; backend-only gate). **No UI Designer.** Next: **Project Setup** runs the `infra/` Firebase DURUM 0 (`setup-manifest.md → ## infra/ DURUM 0 Recipe`); Frontend/Mobile Developer may start Track A (Drift schema/migrations/repos — no Firebase) in parallel. `F08-DEVOPS` (DevOps/Release Engineer, `production-readiness`) opens after QA.

## Last Completed Action

* Tech Lead — 2026-09-06 — F08.CONTRACT-TL: consumed `analysis.md` into `architecture.md` → LOCKED; made the four calls (callable / identity decouple / F08↔F07 split / parallel DURUM 0); set `Release Scope = production-readiness`. Amended `platform.md` §6 (guest identity decouple) + §13 (App Check soft-enforce locked; Drift schema + callable pointers); `release.md` §2 (F08 backend release gate); `setup-manifest.md` (`infra/` DURUM 0 recipe + Workspace Targets); F02 `architecture.md` (`restoreMoves` required). Approved `connectivity_plus`. Locked parked-item retry policy. Opened delivery tasks F08.SETUP-0 / F08-FE1…FE11 / F08-BE2…BE5 / F08-QA1…QA10 / F08-DEVOPS with a parallel-work strategy. Synced `feature-board.md` + `system-state.md`.

## Next Expected Action

* `Run Project Setup` — run the `infra/` Firebase DURUM 0 per `setup-manifest.md → ## infra/ DURUM 0 Recipe (Firebase — triggered by F08)` and `features/f08-.../orchestration.md → Next Action`: `firebase.json` / `.firebaserc` / `firestore.rules` (create-only for `dailyResults/{lang}_{date}/entries/{uid}`) + rules-unit-tests; `infra/functions/` TS package with a `submitDailyResultV1` **callable skeleton** (no logic — Backend Developer F08-BE2 fills it) + one emulator smoke test; Remote Config template (`daily_enabled`/`daily_sync_enabled`/`share_enabled`/`daily_manifest_url` placeholder); CI jobs (`release.md` §4); `app/pubspec.yaml` Firebase client packages + `connectivity_plus` + `firebase_options.dart` (no `main.dart` init — F08-FE6 owns it); `melos` `infra:build`/`infra:test`; confirm the app still builds. On completion → `Run Tech Lead` to reconcile the scaffold and route Backend + Frontend into F08-BE / F08-FE.
* Parallel option: `Run Frontend/Mobile Developer` — begin F08 Track A (F08-FE1 Drift schema → FE2 migrations + never-drop guard → FE3 repositories → FE5 elapsed helper; FE11 `toEngineConfig`; FE4 bundles the additive F02 `restoreMoves`). No Firebase dependency.

---

# 6. CROSS-FEATURE STATUS

## Portfolio Summary

* 13 features. F01 `Done`, F02 `Done`, F06 `Done`. F08 `In Progress` (contract LOCKED; `infra/` DURUM 0 + persistence core). F03, F04, F05, F07, F09–F13 `Not Started`.
* Priority: P0 = F01✓, F02✓, F06✓, **F08**, F03, F05 · P1 = F04, F09, F10, F07, F12 · P2 = F11, F13.
* Critical path: F01✓ → F02✓ → F06✓ → (**F08**, F03) → F04 → F05 → F09 → F10 → F07 → F13; F12 cross-cutting and release-blocking.
* F08 routing: Project Setup (`infra/` DURUM 0) → Backend Developer (callable + rules) + Frontend/Mobile Developer (Drift core, parallel) → QA → Tech Lead → DevOps/Release Engineer (`production-readiness`) → Tech Lead close.
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

* v1 — established 2026-09-03. Project contract rules in `platform.md` §4. F01 + F02 contracts locked and closed. **F06 contract locked & closed 2026-09-06** (`features/f06-.../architecture.md`): forward-BFS solver over F02's `canonicalKey` + `SearchBudget`; `SolveResult` = `Optimal` | `Unsolvable` | `BudgetExceeded`; `looplet_content` engine-free `Puzzle` model + JSON with **required** `difficultyBreakdown`; `PuzzleType` / `DifficultyLabel` defined in `looplet_core`, re-exported by `looplet_content`; CLI-only `tools/looplet_authoring`; `export` gate; `check` CI content gate; difficulty metric definitions locked (weights/thresholds configurable, tuned in `F06-CONTENT`). `platform.md` §3 + §11 carry the shared-enum carve-out (engine primitives + puzzle-schema enums); §13 forward-BFS (amended 2026-09-05). **F08 contract LOCKED 2026-09-06** (`features/f08-.../architecture.md`): HTTPS Callable `submitDailyResultV1` (2nd gen) as the only sync write path; create-only Firestore `dailyResults/{lang}_{date}/entries/{uid}` + rules; exactly-once via idempotency key `{firebaseUid}|{lang}|{dailyDate}` + create-only + `ALREADY_SUBMITTED`=success; first-run-authoritative = local `daily_entry.firstRun*` immutable once set + server first-writer-wins (no read-back/merge in MVP); Drift schema (typed tables + `kv` active-session snapshot; forward-only migrations; never-drop bests/streak; store downgrade unsupported); frozen active-session snapshot JSON (`appliedMoves` = undo history; `thawedFrozenCells` re-derived on restore); `DailyResultSyncService` session-level (never screen-owned); guest identity decoupled (`guestId` local UUID / `firebaseUid` server); App Check soft-enforce (MVP). F06-style F08↔F07 split. `Release Scope = production-readiness`.

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
* Offline exactly-once daily-result sync (F08 — **active, contract locked**): mechanism = idempotency key `{firebaseUid}|{lang}|{dailyDate}` + Firestore **create-only** rule + `ALREADY_SUBMITTED` treated as client success; `sync_queue` marks `synced` only on ack; stale-`inFlight` sweep + backoff (base 30s ×2 cap 6h) + attempt cap 10 → `parked` (bounded auto-retry). First-run-authoritative = local `daily_entry.firstRun*` immutable once set + server first-writer-wins; the two sides are never merged (no leaderboard/read-back in MVP). Residual risk lives in QA — the partial-sync / kill-mid-`inFlight` / background-mid-drain matrix must prove one and only one server doc.
* Active-session durability (F08 — **active, contract locked**): active puzzle state written write-through as a single transactional `kv` row (`appliedMoves` list = undo history; `thawedFrozenCells` re-derived on restore); `paused` flush is a barrier not a first write. Corrupt snapshot → discard active only (durable tables separate), land on menu, log. Storage-full → rollback, keep last good, non-fatal. Migration-throw → abort + recoverable screen, never silent wipe. Store downgrade unsupported (forward-only) — mitigation = migration tests + staged rollout + never-drop guard.
* Firebase `infra/` provisioning (F08 — **active**): `infra/` DURUM 0 recipe authored in `setup-manifest.md`; runs **parallel** with the Drift core (Tech Lead decision, locked). Cloud Functions TS + Firestore rules + Remote Config + `app/` Firebase client packages + `connectivity_plus` land in this DURUM 0. `submitDailyResultV1` skeleton by Project Setup; logic by Backend Developer (F08-BE2).
* Firebase Anonymous Auth used as invisible device identity — assumption that this does not count as "login" per PRD §39 (`platform.md` §6). First real exercise is F08.
* Content pipeline (F06) is a hard dependency for F05 and F07 and must be usable early despite being Infrastructure.

---

# 10. SYSTEM NOTES

* Stack/runtime authority is not duplicated here; see `project-authority/platform.md`. Release authority: `project-authority/release.md`.
* Client stack is Flutter (not Unity) — `Frontend/Mobile Developer` is the client implementation role; `Game Developer (Unity)` is not used. Backend Developer owns the Firebase Cloud Functions / Firestore rules surface (from F07/F08/F12 onward).
* When the workflow changes, `feature-board.md`, the relevant `orchestration.md`, and this file are updated in the same pass by the Tech Lead.
* 2026-09-05 — Incident (System/Workflow, resolved): "how do I run the app locally / is it runnable". Runnable: **yes** — `app/` builds for the iOS simulator (`flutter build ios --simulator` green) and boots to a placeholder shell ("LOOPLET" centred); no game/menu screens yet (F03/F05/F09/F10 not started). Fixed: `setup-manifest.md` boot command (`--scope=app` → `--scope="looplet_app"`) and added a "Run the app locally" section to the root `README.md`. F06 flow not affected (continued).
* 2026-09-06 — F06 closed (QA Approved with Notes). `platform.md` §3 + §11 shared-enum carve-out extended to `PuzzleType` / `DifficultyLabel` (defined in `looplet_core`, re-exported by `looplet_content`). F06 `architecture.md` → LOCKED & CLOSED; `difficultyBreakdown` locked as required. `F06-CONTENT` remains an open follow-on. F08 offline-persistence-and-sync activated → Technical Analyst.
* 2026-09-06 — F08 contract finalized (F08.CONTRACT-TL). `architecture.md` LOCKED. Amended this turn: `platform.md` §6 (guest identity decouple — `guestId` local UUID / `firebaseUid` server) + §13 (App Check soft-enforce locked for MVP; Drift schema + `submitDailyResultV1` callable pointers); `release.md` §2 (F08 first Firebase-infra backend release gate, `Release Scope = production-readiness`); `setup-manifest.md` (`## infra/ DURUM 0 Recipe` + Workspace Targets); F02 `architecture.md` (`GridEngine.restoreMoves` promoted to required). `connectivity_plus` approved for `app/`. Next: Project Setup runs the `infra/` Firebase DURUM 0; Frontend/Mobile Developer may run Track A (Drift core, no Firebase) in parallel. Firebase client packages land in the DURUM 0 (deliberately absent from `app/pubspec.yaml` until then); `main.dart` Firebase init is F08-FE6, not Project Setup.
