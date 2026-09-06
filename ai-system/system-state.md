# System State — LOOPLET

Last Updated: 2026-09-06 (`F08-DEVOPS` delivered `release.md` → verdict `Release Validation Pending`; Tech Lead reconciled **DURUM 5.5** — user deferred the Firebase Blaze upgrade / first deploy to end-of-MVP → **F08 parked `In Release` (ready)**, `F08-DEVOPS` reopens when Blaze is approved. **F03 (`puzzle-play-session`) activated** in parallel — contract locked, `Current Owner → UI Designer`.)

> Global workflow snapshot. Stack/runtime authority lives in `project-authority/platform.md`; release authority in `project-authority/release.md`. This file carries the current snapshot only.

---

# 1. SYSTEM INITIALIZATION

## Platform Initialized

* Yes — `project-authority/platform.md` produced by Tech Lead (2026-09-03). Stack: Flutter (Dart) client, pure-Dart domain packages, Firebase BaaS backend, Drift (SQLite) persistence.

## Environment Status

* Initialized — melos monorepo (`app` + 6 pure-Dart packages + `infra/` Firebase + CI). `melos run format:check` / `analyze` / `test` / `content:check` / `infra:build` / `infra:test` green (**268 workspace tests** + 18 infra-offline tests; 13 infra emulator tests are CI-only — no JDK on the dev machine). `flutter build ios --release --no-codesign` green with the Firebase pods (`✓ Built Runner.app 53.2MB`). Android `build:app` = CI-only locally (no Android SDK on the dev machine). **Firebase `infra/` provisioned — project `looplet-712e5`, `submitDailyResultV1` callable + create-only rules + emulator suites in CI; `flutterfire configure` run + all 4 client config files committed. First `firebase deploy` (the `F08-DEVOPS` `production-readiness` gate) is PARKED — the user deferred the Blaze-plan upgrade to end-of-MVP; on Spark, 2nd-gen Cloud Functions can't deploy. `firebase` CLI 15.x is installed + logged in; `firestore.rules` + `remoteconfig` dry-runs pass; no JDK locally (emulator suites are CI-only).**

---

# 2. AUTHORITY REFERENCES

## Technical Authority

* `/ai-system/project-authority/platform.md` — Exists (Tech Lead, 2026-09-03). Amended 2026-09-05 (§11 F02 engine-primitive carve-out; §13 forward BFS). Amended 2026-09-06 (§3 + §11 shared-enum carve-out extended to `PuzzleType` / `DifficultyLabel`, F06 close-out; §6 guest-identity decouple + §13 Drift/callable notes, F08 contract; §13 App Check provider selection + iOS-App-Attest-deferred, F08 Firebase-project incident).

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

* F03 — puzzle-play-session · (F08 — offline-persistence-and-sync: **In Release / parked** — ready, deploy deferred by user decision to end-of-MVP)

## Active Orchestration Path

* `/ai-system/features/f03-puzzle-play-session/orchestration.md`
* (parked) `/ai-system/features/f08-offline-persistence-and-sync/orchestration.md`

---

# 5. WORKFLOW STATE

## Current Phase

* **F03 — puzzle-play-session** — contract locked (`features/f03-puzzle-play-session/architecture.md`); **UI Designer** produces `ui-design.md`, then Frontend/Mobile Developer (F03-FE1…FE8), then QA (`runtime`-mandatory), then Tech Lead close.
* **F08 — parked (In Release, ready).** `F08-DEVOPS` delivered `release.md` (verdict `Release Validation Pending`); the user deferred enabling Firebase billing (Blaze) — and therefore the first `firebase deploy` + the `release.md` §8 S1–S6 runtime/emulator smoke — to end-of-MVP. F08's code + config is complete and ready. Reopens with `Run DevOps/Release Engineer` when the user approves Blaze.

## Current Role

* UI Designer (F03-UI → `ui-design.md`)

## Current Reason

* **F08 `F08-DEVOPS` reconciled (2026-09-06, Tech Lead — state-machine DURUM 5.5) → PARKED.** `release.md` verdict `Release Validation Pending` accepted: no code defect (QA-confirmed), no failed code/build gate (functions `tsc` + offline tests + `firestore.rules` compile + Remote Config validate all green), rollback plan + S1–S7 smoke checklist documented. **User decision:** don't enable Firebase billing (Blaze) yet — verbatim *"şimdilik deploy yapmadan ilerleyelim … uygulama tamamlanınca buna karar veririz"*. 2nd-gen Cloud Functions can't deploy on the Spark plan, so the first `firebase deploy` + the S1–S6 runtime/emulator smoke are **parked**; production-deploy approval (`release.md` §12) is deferred with it. Per the DURUM 5.5 external-decision branch, Current Owner → — (parked), not DevOps. F08's engineering is **complete and ready**; it is held open only by a user-chosen business gate. **F07 inherits the gate** (depends on F08). **Active development moves to F03** — the other branch of the `F06 → (F08, F03)` fork, P0, depends only on F02 (`Done`), no Firebase; the user explicitly asked that "everything else be made ready". Deliberate user-directed exception to "no new feature while one is unfinished" — F08 is *ready*, not *unfinished*. F03 complexity: **not COMPLEX** (no Technical Analyst); **UI Designer required**; **no DevOps** (`Release Scope = none`).

## Last Completed Action

* Tech Lead — 2026-09-06 — Reconciled `F08-DEVOPS` (`release.md`, verdict `Release Validation Pending`) per DURUM 5.5; recorded the user's decision to defer the Blaze upgrade → **F08 parked `In Release`** (`F08-DEVOPS` reopens when Blaze is approved). Activated **F03** — created `prd.md` + initial `architecture.md` (substrate LOCKED; `[PENDING — UI]` / `[PENDING — IMPL tuning]` enumerated) + `orchestration.md`; complexity decided (not COMPLEX; UI Designer required; no DevOps). `feature-board.md` + `system-state.md` synced. Nothing committed to git.

## Next Expected Action

* `Run UI Designer` — **F03-UI** → `features/f03-puzzle-play-session/ui-design.md` per `features/f03-puzzle-play-session/orchestration.md → Next Action`:
  * Screen goal + visual hierarchy: target word ALWAYS visible + visually SEPARATED from the grid (AC1); grid ~85–90 % width; `MOVES` HUD; Undo with an "N left" affordance; **Restart placed away from the grid**.
  * All states explicitly: idle · gesture-tracking (swipe-begin row/column highlight, AC9) · animating (input-locked, reads as intentional not broken) · won (winning-row highlight **with a non-color cue**) · the bounded success animation (≤ ~600 ms) · the **minimal functional** completion panel (target word + moves + Retry + Close — F04 owns the real stars/best/Next panel) · loading/empty/error for the debug puzzle entry.
  * Motion intent (150–250 ms shift; < 50 ms release→start feel), minimal back-affordance chrome per `design-doctrine.md`, background/color/typography/surface-depth per the doctrine + `premium-ui-rubric.md`. No code. Gesture threshold / tie-band NUMBERS are Frontend+QA device tuning, not a UI decision.
* Then: `Run Frontend/Mobile Developer` (F03-FE1…FE8) → `Run QA` (F03 client QA, `runtime`-mandatory) → `Run Tech Lead` (F03 close).
* **Parked, separate track:** `Run DevOps/Release Engineer` to reopen `F08-DEVOPS` — **only** after the user approves the Blaze upgrade for `looplet-712e5` + the Tech Lead records the production-deploy approval.

---

# 6. CROSS-FEATURE STATUS

## Portfolio Summary

* 13 features. F01 `Done`, F02 `Done`, F06 `Done`. **F03 `In Progress`** — contract locked, `Current Owner = UI Designer`. **F08 `In Release` — parked/ready:** implementation + config complete, QA `Runtime Validation Pending` (no code defect), `F08-DEVOPS` delivered `release.md` (`Release Validation Pending`); the user deferred the Firebase Blaze upgrade + first deploy + the S1–S6 runtime/emulator smoke to end-of-MVP. F04, F05, F07, F09–F13 `Not Started`.
* Priority: P0 = F01✓, F02✓, F06✓, F08 (parked/ready), **F03**, F05 · P1 = F04, F09, F10, F07, F12 · P2 = F11, F13.
* Critical path: F01✓ → F02✓ → F06✓ → (F08 [parked/ready], **F03**) → F04 → F05 → F09 → F10 → F07 → F13; F12 cross-cutting and release-blocking.
* **F03 remaining:** `Run UI Designer` (`ui-design.md`) → `Run Frontend/Mobile Developer` (F03-FE1…FE8) → `Run QA` (client, `runtime`-mandatory) → `Run Tech Lead` (close).
* **F08 remaining (parked):** when the user approves the Blaze upgrade for `looplet-712e5` → `Run DevOps/Release Engineer` (reopen `F08-DEVOPS`: `firebase deploy` rules+RC then functions → S1–S6 smoke → `release.md` → `Release Ready`) → `Run Tech Lead` (close — `Done`). **F07 cannot reach `Done` until F08 does.**
* **`F06-CONTENT`** (full 30 Journey + ~60 Daily authoring) — an **open** Level-Designer follow-on split off from F06; still MVP scope; blocks F05 and F07 from reaching `Done` but did not block F06. Tech Lead schedules it when F05 / F07 need real content.

## Active Rework

* None

## Paused Features

* None.

## Blocked Features

* **F03** — not blocked. F02 (`Done`, locked) + the F08 on-device snapshot contract (`[LOCKED]`) are available; F08's parked Firebase deploy is irrelevant to F03. Content: the F06 5-puzzle smoke set is enough for F03 QA.
* **F07** — will be gated on F08 reaching `Done`. F07 depends on F08; F08 is `In Release`/parked (deploy deferred by user to end-of-MVP), so F07 cannot reach `Done` until the F08 deploy + S1–S6 smoke land. Not on the near-term path (F07 is P1, well downstream).
* **F08** — `In Release`, parked by **user decision** (defer the Firebase Blaze upgrade / first deploy + the S1–S6 runtime/emulator smoke to end-of-MVP). Not a technical blocker; F08's code + config is complete and ready. `F08-DEVOPS` reopens with `Run DevOps/Release Engineer` once the user approves Blaze + Tech Lead records the production-deploy approval.
* Non-blocking, deferred (not a feature blocker): **iOS production App Check (App Attest / DeviceCheck)** — no Apple Developer Program membership; App Check is soft-enforce so a failed iOS attestation is a logged no-op; `[OPEN — post-MVP]`. `FIREBASE_CI_TOKEN` (user-owned repo secret; only needed for an automated deploy workflow — a manual first deploy needs neither it nor a service-account key) + Android release Play Integrity SHA-256 (→ the first app-distribution gate) → part of the parked `F08-DEVOPS`.
* Non-blocking note: production-quality curated Turkish corpus + target-word review is a Product Owner / content deliverable (F01 PRD Open Questions); F01 code proceeds on a provisional reviewed list. `F06-CONTENT` (full 30 Journey + ~60 Daily authoring) remains an open Level-Designer follow-on, prerequisite for F05 & F07 reaching `Done`.

---

# 7. GLOBAL CONTRACT SNAPSHOT

## Contract Version

* v1 — established 2026-09-03. Project contract rules in `platform.md` §4. F01 + F02 contracts locked and closed. **F06 contract locked & closed 2026-09-06** (`features/f06-.../architecture.md`): forward-BFS solver over F02's `canonicalKey` + `SearchBudget`; `SolveResult` = `Optimal` | `Unsolvable` | `BudgetExceeded`; `looplet_content` engine-free `Puzzle` model + JSON with **required** `difficultyBreakdown`; `PuzzleType` / `DifficultyLabel` defined in `looplet_core`, re-exported by `looplet_content`; CLI-only `tools/looplet_authoring`; `export` gate; `check` CI content gate; difficulty metric definitions locked (weights/thresholds configurable, tuned in `F06-CONTENT`). `platform.md` §3 + §11 carry the shared-enum carve-out (engine primitives + puzzle-schema enums); §13 forward-BFS (amended 2026-09-05). **F08 contract LOCKED 2026-09-06** (`features/f08-.../architecture.md`): HTTPS Callable `submitDailyResultV1` (2nd gen) as the only sync write path; create-only Firestore `dailyResults/{lang}_{date}/entries/{uid}` + rules; exactly-once via idempotency key `{firebaseUid}|{lang}|{dailyDate}` + create-only + `ALREADY_SUBMITTED`=success; first-run-authoritative = local `daily_entry.firstRun*` immutable once set + server first-writer-wins (no read-back/merge in MVP); Drift schema (typed tables + `kv` active-session snapshot; forward-only migrations; never-drop bests/streak; store downgrade unsupported); frozen active-session snapshot JSON (`appliedMoves` = undo history; `thawedFrozenCells` re-derived on restore); `DailyResultSyncService` session-level (never screen-owned); guest identity decoupled (`guestId` local UUID / `firebaseUid` server); App Check soft-enforce (MVP). F06-style F08↔F07 split. `Release Scope = production-readiness`. **F08 deploy PARKED (2026-09-06, user decision)** — the contract is unchanged; only the first `firebase deploy` + the release smoke are deferred to end-of-MVP. **F03 contract INITIAL/LOCKED-substrate 2026-09-06** (`features/f03-.../architecture.md`): consumes F02 (`GridEngine`/`Move`/`GridStep`) + the F08 on-device snapshot contract; screen state machine idle/tracking/animating/won with **no input queue**; gesture→`Move` mapping envelope (threshold + dominant axis + **tie band → favor horizontal**, exactly one cell, first pointer only); `MOVES` = `engine.moveCount` (settled only); Undo = a 3-**action** F03-owned quota (no prompt/ad at 0); Restart = reset + `restartCount++`, no dialog, placed away from the grid; write-through into the F08-frozen snapshot + hydrate via the F08 restore path; minimal functional completion panel (F04 owns the real one); 150–250 ms shift animation, full input lock, `<50 ms` release→start; portrait-locked route `'/play'`; `runtime`-mandatory QA; `Release Scope = none`. `[PENDING — UI]` (UI Designer) + `[PENDING — IMPL tuning]` (threshold/tie-band numbers, device-tuned) enumerated in `architecture.md §18`.

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
* Firebase `infra/` provisioning (F08 — **done**): `infra/` DURUM 0 executed; `submitDailyResultV1` callable implemented (F08-BE2) + rules + emulator suites in CI. Real Firebase project `looplet-712e5` created + `flutterfire configure` run + verified (2026-09-06). **Residual, non-blocking:** iOS production App Check (App Attest / DeviceCheck) not configurable without Apple Developer Program membership — App Check is soft-enforce so this is a logged no-op; `[OPEN — post-MVP]`. Android release Play Integrity SHA-256 + `FIREBASE_CI_TOKEN` → `F08-DEVOPS`.
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
* 2026-09-06 — F08 `infra/` DURUM 0 executed (Project Setup) + reconciled; Track A (`frontend.md`) + Track B (`backend.md`) implementation delivered + reconciled + accepted (263 workspace tests + `analyze`/`format:check`/`infra:build`/`infra:test` + offline `npm test` green; emulator suites CI-verified only — no JDK in dev env).
* 2026-09-06 — **Incident (System/Workflow, resolved): `F08.FIREBASE-PROJECT` done.** User created Firebase project `looplet-712e5` (Android `com.looplet.looplet_app` + iOS `com.looplet.loopletApp`), ran `flutterfire configure`, enabled Anonymous Auth, App Check monitor. Tech Lead verified all 4 config files + Android Gradle plugin wiring + iOS `project.pbxproj` refs present/consistent/committed; `flutter analyze` (app) clean. `architecture.md → App Init Sequence` + `platform.md` §13 amended with the App Check provider-selection rule (debug provider in dev; Play Integrity/App Attest in release; `activate()` wrapped so failure is a logged no-op). **iOS production App Attest/DeviceCheck deferred** — no Apple Developer Program membership; non-blocking (soft-enforce); `[OPEN — post-MVP]`. `FIREBASE_CI_TOKEN` + Android Play Integrity SHA-256 → `F08-DEVOPS`. Hard-enforce never enabled in the MVP. F08 resumed at the app-Firebase join (FE6 → FE8 → FE9).
* 2026-09-06 — F08 join (FE6/FE8/FE9) delivered + QA'd. QA verdict **`Runtime Validation Pending`** (`qa.md`): no blocking code issue, no required fix; Backend Build Gate PASS (268/268 workspace + 18/18 infra-offline + `analyze`/`format:check`/`infra:build`/`infra:test` + iOS release build GREEN); full [LOCKED] contract honored; Security §6.5 all PASS. Not `Approved` only because the QA env had no device/simulator + no JDK → the contract-mandated `runtime` + Firebase-emulator evidence could not be produced. **Tech Lead reconciled per state-machine DURUM 5:** verdict accepted, no rework, no contract change; **Status → In Release, Current Owner → DevOps/Release Engineer**; the six `qa.md §17` pending scenarios folded into the `F08-DEVOPS` `release.md` §8 device/emulator smoke (kill/relaunch → exact resume; lifecycle/connectivity `drain()`; exactly-one create-only Firestore doc + `syncStatus = synced`; repeat → `ALREADY_SUBMITTED` doc unchanged; screen-dispose mid-sync → sync completes; CI `infra` emulator job GREEN on the F08 branch). Deferred non-blocking: iOS prod App Attest/DeviceCheck `[OPEN — post-MVP]` (App Check MONITOR, never hard-enforce); AC7 storage-full fault-injection test (residual test-debt); AC2/AC3 end-user offline play (needs F03/F05 → F05/F07 QA); `dailySyncEnabledProvider` + `FakeDailyResultProducer` = F07 seams. `orchestration.md` Change Log v12; `feature-board.md` + `system-state.md` synced. F08 **not `Done`** until `F08-DEVOPS` passes.
* 2026-09-06 — **`F08-DEVOPS` delivered + reconciled (DURUM 5.5) → F08 PARKED; F03 activated.** DevOps/Release Engineer produced `features/f08-.../release.md`, verdict `Release Validation Pending`: no code defect; functions `tsc` build + `melos infra:test` (18 pass / 13 emulator-skip) green; `firebase deploy --only firestore:rules --dry-run` → rules compile OK; `--only remoteconfig --dry-run` → OK after adding a `remoteconfig` block to `infra/firebase.json`; deploy runbook + rollback plan + the `qa.md §17` → S1–S7 device/emulator smoke checklist authored into `release.md` §6/§7/§8 + `infra/README.md`; App Check confirmed monitor. `firebase deploy --only functions --dry-run` **stops on the Blaze-plan requirement** (2nd-gen Cloud Functions need `cloudbuild`/`artifactregistry`/`cloudfunctions`; `looplet-712e5` is on Spark). Dry-run side effect: `firestore.googleapis.com` enabled + a `(default)` Firestore DB created (benign, F08 needs it). **User decision:** defer Firebase billing (Blaze) + the first deploy + the S1–S6 runtime/emulator smoke to end-of-MVP ("şimdilik deploy yapmadan ilerleyelim … uygulama tamamlanınca buna karar veririz"). Tech Lead reconciled per **DURUM 5.5 external-decision branch** → **F08 `In Release`, PARKED (ready)**; `F08-DEVOPS` reopens with `Run DevOps/Release Engineer` when Blaze is approved. **F07 inherits the gate** (depends on F08). **F03 (`puzzle-play-session`, P0) activated in parallel** — the other branch of the `F06 → (F08, F03)` fork, depends only on F02 (`Done`), no Firebase; the user asked that everything else be made ready. Created `features/f03-puzzle-play-session/{prd.md, architecture.md, orchestration.md}`; contract substrate LOCKED (`[PENDING — UI]` / `[PENDING — IMPL tuning]` enumerated); complexity = not COMPLEX (no Technical Analyst), **UI Designer required**, no DevOps (`Release Scope = none`). `Current Owner → UI Designer`; `Next Role → UI Designer`. `feature-board.md` + `system-state.md` synced.
* 2026-09-06 — `infra/` Firebase DURUM 0 executed (Project Setup, F08.SETUP-0) + Tech-Lead-reconciled. Created `infra/{firebase.json,.firebaserc,firestore.rules,firestore.indexes.json,remoteconfig.template.json,.gitignore,README.md}` + `infra/functions/` (TypeScript Node 20 — `submitDailyResultV1` `onCall` skeleton + offline tests + emulator-gated rules tests) + CI `infra` job + `melos` `infra:build`/`infra:test` + `app/pubspec.yaml` Firebase client packages + `connectivity_plus`. All workspace gates + `infra:build`/`infra:test` green. Version substitutions accepted: `firebase-functions ^6`, `firebase-admin ^13`, `@firebase/rules-unit-testing ^5` + `firebase ^12` (dev). Manual Firebase-project work (`F08.FIREBASE-PROJECT`, owner: user) — real project + `flutterfire configure` + Auth/App Check enable + `firebase-tools` in CI — blocks only the join (`F08-FE6/FE8/FE9`) + `F08-DEVOPS`. Emulator-based Track B (`F08-BE2/BE3/BE4`) runs against a fake project id and needs no real project. `main.dart` Firebase init is F08-FE6, not Project Setup.
