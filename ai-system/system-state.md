# System State — LOOPLET

Last Updated: 2026-09-06 (F08 implementation complete — both tracks reconciled + accepted; HELD on `F08.FIREBASE-PROJECT`, a user Firebase-Console action; no parallel feature started, per the user)

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

* F08 implementation **complete** (both tracks delivered, reconciled, accepted) — **HELD on `F08.FIREBASE-PROJECT`** (a user Firebase-Console action). No parallel feature started (user's choice).

## Current Role

* — (waiting on the user). Resume role: **Frontend/Mobile Developer** (F08-FE6/FE8/FE9 join).

## Current Reason

* F08's persistence layer + sync are fully implemented and contract-compliant: Track A (`frontend.md`) — Drift `AppDatabase` (10 contract tables + `kv`, `schemaVersion 1`, seeded), `MigrationGuard` never-drop, write-through repositories, `ActiveSessionSnapshot` + corrupt-safe `ActiveSessionRepo` + `restoreSession` (re-derives `thawedCells`), `ElapsedTimer`, `toEngineConfig`, `DailyResultSyncService` (queue state machine + exp backoff + exactly-once + first-run-authoritative + `awaitingAuth` + parked bounded-retry + `daily_sync_enabled` kill-switch; session-level, injectable sender/connectivity), `FakeDailyResultProducer`. Track B (`backend.md`) — `submitDailyResultV1` filled (full `platform.md` §8 validation + create-only Firestore transaction + `CREATED`/`ALREADY_SUBMITTED` reconciliation + `HttpsError` mapping), `firestore.rules` verified compliant, emulator suites (`rules.test.ts` + `submitDailyResult.test.ts`) written + wired into the CI `infra` job (`npx firebase-tools emulators:exec`). **263 workspace tests + `analyze` + `format:check` + `infra:build`/`infra:test` + offline `npm test` all green.** F02 `GridEngine.restoreMoves` was already present + tested — no F02 change. Non-blocking notes accepted (move-shorthand ~40-line dup vs `tools/looplet_authoring`; hand-rolled UUID; emulator suites CI-verified only — no JDK in the dev env). **Sole remaining gate:** `F08.FIREBASE-PROJECT` — a user must create the real Firebase project, run `flutterfire configure` (→ `app/lib/firebase_options.dart` + platform config), and enable Anonymous Auth + App Check (monitor). The user chose (2026-09-06) to hold F08 here rather than start F03 in parallel. **No UI Designer.** `F08-DEVOPS` (`production-readiness`) opens after QA.

## Last Completed Action

* Tech Lead — 2026-09-06 — Reconciled + accepted both F08 delivery artifacts (`frontend.md` Track A, `backend.md` Track B) against the LOCKED `architecture.md`: schema/keys, frozen snapshot keys, never-drop guard, `sync_queue` state machine + backoff + exactly-once + first-run-authoritative + session-level ownership + kill-switch, callable request/response/error shapes, `platform.md` §8 validation, create-only transaction, verified rules — all compliant. No rework, no contract change, no re-QA. Recorded the non-blocking notes. F08 held on `F08.FIREBASE-PROJECT` per the user's choice; synced `feature-board.md` + `system-state.md` to the held state.

## Next Expected Action

* **User (out-of-band):** complete `F08.FIREBASE-PROJECT` — create a Firebase project; `cd infra && firebase use --add` (commit `infra/.firebaserc`); register the iOS + Android apps; `cd app && flutterfire configure` (commit `app/lib/firebase_options.dart` + `google-services.json` + `GoogleService-Info.plist`); enable Authentication → Anonymous; enable App Check in **monitor** mode. (Optional now, required for deploy: add the `FIREBASE_CI_TOKEN` repo secret.) See `features/f08-.../orchestration.md → Next Action` for the exact checklist.
* **Then resume:** `Run Frontend/Mobile Developer` — the F08 join: `F08-FE6` (app-init sequence in `app/lib/main.dart` — open DB → migrate → seed → read snapshot → async Firebase init + App Check + `signInAnonymously` → persist `firebaseUid` → construct the session-level `DailyResultSyncService` → `drain()`; migration-failure recoverable error screen), `F08-FE8` (real `SyncSender` binding: `httpsCallable('submitDailyResultV1')` + response→`SyncSendResult` mapping — mapping logic already tested), `F08-FE9` (app-scoped singleton + `connectivity_plus` regain stream; confirm `flutter build ios --release --no-codesign` passes with the Firebase pods). → `Run QA` (F08-QA1…QA10) → `Run Tech Lead` → `Run DevOps/Release Engineer` (F08-DEVOPS) → `Run Tech Lead` (close).

---

# 6. CROSS-FEATURE STATUS

## Portfolio Summary

* 13 features. F01 `Done`, F02 `Done`, F06 `Done`. F08 `In Progress` — **implementation complete (both tracks), HELD on `F08.FIREBASE-PROJECT` (user manual step)**. F03, F04, F05, F07, F09–F13 `Not Started`.
* Priority: P0 = F01✓, F02✓, F06✓, **F08**, F03, F05 · P1 = F04, F09, F10, F07, F12 · P2 = F11, F13.
* Critical path: F01✓ → F02✓ → F06✓ → (**F08**, F03) → F04 → F05 → F09 → F10 → F07 → F13; F12 cross-cutting and release-blocking.
* F08 resume: after the user completes `F08.FIREBASE-PROJECT` → `Run Frontend/Mobile Developer` (F08-FE6/FE8/FE9 join) → QA → Tech Lead → DevOps/Release Engineer (`production-readiness`) → Tech Lead close.
* **F03 (puzzle-play-session, P0)** is the other unblocked branch of the F06 fork (depends only on F02✓, no Firebase). Not activated — the user chose to keep F08 as the single active feature rather than run F03 in parallel. It is the natural next activation once F08 closes (or if the user later opts to parallelize).
* **`F06-CONTENT`** (full 30 Journey + ~60 Daily authoring) — an **open** Level-Designer follow-on split off from F06; still MVP scope; blocks F05 and F07 from reaching `Done` but did not block F06. Tech Lead schedules it when F05 / F07 need real content.

## Active Rework

* None

## Paused Features

* None. (F08 is `In Progress` but **held** — implementation complete, awaiting the user's `F08.FIREBASE-PROJECT` step. Not marked "Paused" because no work was abandoned mid-task; it resumes at `Run Frontend/Mobile Developer`. Per the user, no other feature was started in the interim.)

## Blocked Features

* **F08 join phase (`F08-FE6/FE8/FE9`) + QA + `F08-DEVOPS`** — blocked on `F08.FIREBASE-PROJECT` (a user Firebase-Console action: create project + `flutterfire configure` + Anonymous Auth + App Check monitor). F08's Track A + Track B implementation is done and green; this is an external-provisioning gate, not a code blocker.
* Non-blocking note: production-quality curated Turkish corpus + target-word review is a Product Owner / content deliverable (F01 PRD Open Questions); F01 code proceeds on a provisional reviewed list. `F06-CONTENT` (full 30 Journey + ~60 Daily authoring) remains an open Level-Designer follow-on, prerequisite for F05 & F07 reaching `Done`.

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
* 2026-09-06 — F08 contract finalized (F08.CONTRACT-TL). `architecture.md` LOCKED. Amended: `platform.md` §6 (guest identity decouple — `guestId` local UUID / `firebaseUid` server) + §13 (App Check soft-enforce locked for MVP; Drift schema + `submitDailyResultV1` callable pointers); `release.md` §2 (F08 first Firebase-infra backend release gate, `Release Scope = production-readiness`); `setup-manifest.md` (`## infra/ DURUM 0 Recipe` + Workspace Targets); F02 `architecture.md` (`GridEngine.restoreMoves` promoted to required). `connectivity_plus` approved for `app/`.
* 2026-09-06 — `infra/` Firebase DURUM 0 executed (Project Setup, F08.SETUP-0) + Tech-Lead-reconciled. Created `infra/{firebase.json,.firebaserc,firestore.rules,firestore.indexes.json,remoteconfig.template.json,.gitignore,README.md}` + `infra/functions/` (TypeScript Node 20 — `submitDailyResultV1` `onCall` skeleton + offline tests + emulator-gated rules tests) + CI `infra` job + `melos` `infra:build`/`infra:test` + `app/pubspec.yaml` Firebase client packages + `connectivity_plus`. All workspace gates + `infra:build`/`infra:test` green. Version substitutions accepted: `firebase-functions ^6`, `firebase-admin ^13`, `@firebase/rules-unit-testing ^5` + `firebase ^12` (dev). Manual Firebase-project work (`F08.FIREBASE-PROJECT`, owner: user) — real project + `flutterfire configure` + Auth/App Check enable + `firebase-tools` in CI — blocks only the join (`F08-FE6/FE8/FE9`) + `F08-DEVOPS`. Emulator-based Track B (`F08-BE2/BE3/BE4`) runs against a fake project id and needs no real project. `main.dart` Firebase init is F08-FE6, not Project Setup.
