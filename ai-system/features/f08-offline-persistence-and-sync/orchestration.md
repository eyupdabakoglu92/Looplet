# F08 — offline-persistence-and-sync: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In Progress — Contract LOCKED (2026-09-06). Scaffold + persistence-core phase.**

---

## Current Owner

Project Setup (F08.SETUP-0 — `infra/` Firebase DURUM 0) · Frontend/Mobile Developer may start F08-FE1…FE5 (Drift core, no Firebase) in parallel

---

## Current Phase

Contract finalized: `architecture.md` is **LOCKED** — `analysis.md` consumed, all four calls made (HTTPS **callable** `submitDailyResultV1`; **decoupled** `guestId` UUID / `firebaseUid`, `platform.md` §6 amended; **F06-style F08↔F07 split** confirmed; `infra/` DURUM 0 runs **parallel** with the Drift core). `Release Scope = production-readiness`; `release.md` §2 updated; `setup-manifest.md` gained the `infra/` DURUM 0 recipe; `platform.md` §6/§13 amended; F02 `restoreMoves` promoted to required; `connectivity_plus` approved. Delivery tasks opened (F08.SETUP-0, F08-BE1…BE5, F08-FE1…FE11, F08-QA1…QA10, F08-DEVOPS post-QA). Next: Project Setup runs the `infra/` DURUM 0.

---

## Complexity Decision

* **COMPLEX.** Triggers: a new persistence data model (§15 → Drift tables); realtime/async + sync/conflict resolution (offline exactly-once, first-run-authoritative reconciliation); state-machine conceptuality (forward-only migration steps; `sync_queue` states); cross-feature dependency on F07 (Daily producer) with an unresolved boundary; unsafe-assumption risk (the product PRD explicitly leaves the backend sync surface to the Tech Lead). → **Technical Analyst pass before contract finalization.**
* **No UI Designer** — Infrastructure; F08 owns no screens. F10 surfaces streak/progress; F03 owns the play-session UI. F08 exposes stores + services.
* **DevOps/Release Engineer** — expected **after QA**: first Firebase deploy (Functions/rules/App Check) + a Drift forward migration ⇒ a release gate. `Release Scope` set at contract finalization.
* **Project Setup** — an `infra/` DURUM 0 (+ app Firebase wiring) is required before Backend implementation; sequencing (before vs parallel with the persistence core) is an analysis input, Tech-Lead-triggered.

---

## Active Task Ledger

- [x] Task ID: F08.0-AN | Assigned Role: Technical Analyst | Status: Done | `analysis.md` delivered (sections 1–19); all 10 open items resolved. Consumed into `architecture.md` on 2026-09-06.
- [x] Task ID: F08.CONTRACT-TL | Assigned Role: Tech Lead | Status: Done | `analysis.md` consumed into `architecture.md` → **LOCKED**. Calls made: (1) sync surface = HTTPS Callable `submitDailyResultV1`; (2) identity = **decouple** `guestId` (local UUID) from `firebaseUid` (server) — `platform.md` §6 amended; (3) F08↔F07 = F06-style split confirmed (F08 ships persistence core + sync + fake producer; F07 wires real producer); (4) `infra/` DURUM 0 runs **parallel** with the Drift core. `Release Scope = production-readiness`; `release.md` §2 + `platform.md` §6/§13 + `setup-manifest.md` (infra DURUM 0 recipe) + F02 `architecture.md` (`restoreMoves` required) amended. `connectivity_plus` approved. App Check = soft-enforce MVP (locked). Parked-item retry = bounded auto-retry once/app-start, max 3 lifetime (locked). `product-prd §51` server-side clock check = **not in MVP** (Tech Lead decision, no PO escalation — consistent with `platform.md` §6). Delivery tasks opened below.
- [ ] Task ID: F08.SETUP-0 | Assigned Role: Project Setup | Status: **Open — NEXT** | `infra/` Firebase DURUM 0 per `setup-manifest.md → ## infra/ DURUM 0 Recipe`. Firebase project config + `firestore.rules` (create-only per `architecture.md`) + rules-unit-tests + Cloud Functions TS skeleton (`submitDailyResultV1` compiling skeleton, no logic) + emulator smoke test + Remote Config template (`daily_enabled`/`daily_sync_enabled`/`share_enabled`/`daily_manifest_url` placeholder) + CI jobs + `app/pubspec.yaml` Firebase client packages + `connectivity_plus` + `firebase_options.dart` (no `main.dart` init yet) + `melos` `infra:build`/`infra:test` scripts. App must still build (`flutter build ios --release --no-codesign`, `flutter build appbundle --release`).
- [ ] Task ID: F08-FE1 | Assigned Role: Frontend/Mobile Developer | Status: Open (parallel with F08.SETUP-0 — no Firebase) | Drift schema: all `architecture.md → Persistence Schema` tables + `kv`; `AppDatabase` `schemaVersion = 1`; codegen.
- [ ] Task ID: F08-FE2 | Assigned Role: Frontend/Mobile Developer | Status: Open (parallel) | `MigrationStrategy`: `onCreate` seeds defaults; `onUpgrade` step framework; **never-drop guard** on `personal_best`/`daily_streak`/`daily_entry`; a v1→v2 dummy migration + a migration test harness (seed old → upgrade → assert bests/streak/first-run intact); migration-throw → abort + recoverable, no wipe.
- [ ] Task ID: F08-FE3 | Assigned Role: Frontend/Mobile Developer | Status: Open (parallel) | Repositories: `PlayerRepo`, `SettingsRepo`, `JourneyProgressRepo`, `PersonalBestRepo` (monotone ↓), `DailyRepo` (first-run immutability + attempts), `DailyStreakRepo` (store-only), `DailyPuzzleCache`, `ActiveSessionRepo`, `SyncQueueRepo` — all write-through + transactional.
- [ ] Task ID: F08-FE4 | Assigned Role: Frontend/Mobile Developer | Status: Open (needs F02 `restoreMoves` + `toEngineConfig`) | Active-session snapshot: serialize/deserialize per `architecture.md → Active-Session Snapshot Contract` (frozen keys); `save()` on state-change boundary; `read()` + validation + corrupt-recovery; `clearActiveSession()`; restore path rebuilding `GridEngine` via `toEngineConfig(puzzle)` + `restoreMoves` + re-derived `thawedCells`. **Includes the F02 `restoreMoves(List<Move>)` additive API** (F02-owned review).
- [ ] Task ID: F08-FE5 | Assigned Role: Frontend/Mobile Developer | Status: Open (parallel) | Monotonic elapsed helper: `Stopwatch` accumulator, persisted `elapsedMsAccumulated`, resume-safe; guard test — no wall clock for elapsed.
- [ ] Task ID: F08-FE6 | Assigned Role: Frontend/Mobile Developer | Status: Open (gated on F08.SETUP-0) | App-init sequence per `architecture.md → App Init Sequence`: open DB → migrate → seed → read snapshot → (async, non-blocking) Firebase init + App Check + Anonymous sign-in (persist `firebaseUid` on success) → construct session-level sync service → `drain()`. Migration-failure recoverable error screen (only F08-owned UI).
- [ ] Task ID: F08-FE7 | Assigned Role: Frontend/Mobile Developer | Status: Open (gated on F08.SETUP-0) | `DailyResultSyncService` (session-level singleton): `enqueue`; `connectivity_plus` listener; `drain()` state machine (`pending`/`inFlight`/`synced`/`parked` + `awaitingAuth`); exponential backoff (base 30s, ×2, cap 6h, ±20% jitter); attempt cap 10 → `parked`; stale-`inFlight` sweep (>20s); parked bounded auto-retry (once/app-start, max 3 lifetime); `daily_entry.syncStatus` mirror in the same transaction; no-op while `daily_sync_enabled == false`; wired to lifecycle (`paused` flush, `resumed` drain). **Not** screen-owned.
- [ ] Task ID: F08-FE8 | Assigned Role: Frontend/Mobile Developer | Status: Open (gated on F08.SETUP-0 + F08-BE2) | Callable client binding for `submitDailyResultV1` + response→queue-transition mapping (`CREATED`/`ALREADY_SUBMITTED` → `synced`; `INVALID_PAYLOAD`/`UNSUPPORTED_LANGUAGE` → `parked`; `INTERNAL`/transport → retryable); typed error handling; client pre-enqueue payload assertion.
- [ ] Task ID: F08-FE9 | Assigned Role: Frontend/Mobile Developer | Status: Open (paired with F08.SETUP-0) | Firebase package wiring finalization in `app/` + guarded offline-tolerant init; `connectivity_plus` integration. (Package adds happen in F08.SETUP-0; this task confirms the app runs with them.)
- [ ] Task ID: F08-FE10 | Assigned Role: Frontend/Mobile Developer | Status: Open | **Fake daily-result producer** (`enqueueFakeDailyResult(...)` behind a debug/test flag): fabricate a `daily_entry` + enqueue a sync item so the queue + reconciliation + callable path are exercised end-to-end without F07. Removed/replaced by F07.
- [ ] Task ID: F08-FE11 | Assigned Role: Frontend/Mobile Developer | Status: Open (parallel) | `toEngineConfig(Puzzle) → EngineConfig` free function in `app/` (the F06-flagged consumer helper; shared with F05).
- [ ] Task ID: F08-BE1 | Assigned Role: Project Setup | Status: folded into F08.SETUP-0 | `infra/` scaffold (see F08.SETUP-0).
- [ ] Task ID: F08-BE2 | Assigned Role: Backend Developer | Status: Open (gated on F08.SETUP-0) | Implement `submitDailyResultV1`: auth guard, App Check (soft), full payload validation (`architecture.md → Firebase Sync Surface`), create-only Firestore write at `dailyResults/{lang}_{date}/entries/{uid}`, `CREATED` / `ALREADY_SUBMITTED` / typed errors (`INVALID_PAYLOAD`/`UNSUPPORTED_LANGUAGE`/`INTERNAL`).
- [ ] Task ID: F08-BE3 | Assigned Role: Backend Developer | Status: Open (gated on F08.SETUP-0) | `firestore.rules` create-only for own uid (no update/delete/read) + `@firebase/rules-unit-testing` spec: allow-create-own, deny-create-other, deny-update, deny-delete, deny-read.
- [ ] Task ID: F08-BE4 | Assigned Role: Backend Developer | Status: Open (gated on F08-BE2) | Functions emulator unit tests: valid create; duplicate → `ALREADY_SUBMITTED`; each validation failure; missing auth.
- [ ] Task ID: F08-BE5 | Assigned Role: Backend Developer | Status: Open | CI: `infra/functions` build+test + rules tests wired into `.github/workflows/ci.yml` (`release.md` §4); actions pinned to SHA.
- [ ] Task ID: F08-QA1…QA10 | Assigned Role: QA | Status: Not opened (opens when BE + FE complete) | Per `architecture.md → QA Focus` — resume fidelity (runtime), offline Journey/Daily (runtime), exactly-once sync + first-run-authoritative (integration, emulator, via the fake producer), migration + corrupt-save + storage-full (automated), clock (automated+runtime), guest schema (automated), session-level ownership (runtime), rules (integration). Evidence: `runtime` + `repeatable integration` + `automated functional`.
- [ ] Task ID: F08-DEVOPS | Assigned Role: DevOps/Release Engineer | Status: Not opened (opens AFTER QA passes — state machine DURUM 5 → In Release) | `Release Scope = production-readiness`. Firebase Functions + rules deploy readiness (dry-run `firebase deploy --only functions,firestore:rules`), Remote Config push, prod Firebase project confirmation, `FIREBASE_CI_TOKEN` wiring, rollback-readiness (functions redeploy-previous + `daily_sync_enabled` kill-switch + "no Drift downgrade" documented), post-deploy smoke (`release.md` §8), `features/f08-.../release.md` verdict.

---

## QA Scope

* **[LOCKED]** (see `architecture.md → QA Focus`) — end-to-end (app persistence + Firebase emulator). Evidence class: `runtime` (resume / offline / sync on device or emulator) + `repeatable integration` (callable + rules via the Firebase emulator) + `automated functional` (schema / migration / serialization units). **Not `source-only`** — `platform.md` §10 requires runtime proof for resume + daily behavior. `Security compliance` in scope at the rules/callable level (create-only, auth-scoped path, payload validation, App Check attach).

---

## Release Scope

* **`production-readiness`** (LOCKED). F08 is the first Firebase deploy (Cloud Functions `submitDailyResultV1` + `firestore.rules` + Remote Config) — a **backend-only** release gate per `release.md` §2, distinct from the first app-build distribution gate. The `F08-DEVOPS` task also covers rollback-readiness (functions redeploy-previous, `daily_sync_enabled` kill-switch, no Drift downgrade). Opens **after QA**. `release.md` §2 updated 2026-09-06.

---

## Open Tasks

### Analysis
- [x] (F08.0-AN) Technical analysis — done; consumed into `architecture.md` 2026-09-06.

### Contract
- [x] (F08.CONTRACT-TL) Tech Lead — done 2026-09-06. `architecture.md` LOCKED; 4 calls made; `Release Scope` set; `release.md` / `platform.md` §6+§13 / `setup-manifest.md` / F02 `architecture.md` amended; delivery tasks opened.

### Project Setup
- [ ] (F08.SETUP-0) `infra/` Firebase DURUM 0 per `setup-manifest.md → ## infra/ DURUM 0 Recipe` + `app/` Firebase client wiring. **NEXT.**

### Backend
- [ ] (F08-BE2) `submitDailyResultV1` implementation. (F08-BE1 folded into F08.SETUP-0.)
- [ ] (F08-BE3) `firestore.rules` create-only + rules-unit-tests.
- [ ] (F08-BE4) Functions emulator unit tests.
- [ ] (F08-BE5) CI wiring for `infra/`.

### Frontend
- [ ] (F08-FE1) Drift schema + `AppDatabase`.
- [ ] (F08-FE2) Migrations + never-drop guard + migration test harness.
- [ ] (F08-FE3) Repositories (write-through, transactional).
- [ ] (F08-FE4) Active-session snapshot serialize/restore + F02 `restoreMoves` additive API.
- [ ] (F08-FE5) Monotonic elapsed helper.
- [ ] (F08-FE6) App-init sequence + migration-error screen.
- [ ] (F08-FE7) `DailyResultSyncService` (session-level; queue state machine; backoff; parked retry; kill-switch).
- [ ] (F08-FE8) Callable client binding + response mapping.
- [ ] (F08-FE9) Firebase package wiring finalization + guarded init.
- [ ] (F08-FE10) Fake daily-result producer test seam.
- [ ] (F08-FE11) `toEngineConfig(Puzzle)` consumer helper.

### QA
- [ ] (F08-QA1…QA10) Full matrix per `architecture.md → QA Focus`. Opens when BE + FE complete.

### DevOps / Release
- [ ] (F08-DEVOPS) `production-readiness` — Firebase deploy readiness + rollback-readiness + smoke + `features/f08-.../release.md`. Opens **after QA**.

### Parallel-work strategy
- **Track A (no Firebase, start now):** F08-FE1 → FE2 → FE3 → FE5, and FE11; FE4 needs the F02 `restoreMoves` API (small, F02-owned).
- **Track B (scaffold):** F08.SETUP-0 (Project Setup) → then F08-BE2/BE3/BE4/BE5 (Backend Developer).
- **Join:** F08-FE6/FE7/FE8/FE9 need Track B done. FE10 any time. Then QA, then DevOps.

---

## Blockers

* **None.** Contract is LOCKED; all Tech Lead decision points from `analysis.md §15/§17` are resolved and recorded in `architecture.md` / `platform.md` / `release.md` / `setup-manifest.md`.
* Sequencing (not a blocker): F08-FE6/FE7/FE8/FE9 need F08.SETUP-0 (infra) done; Track A (FE1–FE5, FE11) has no Firebase dependency and runs in parallel. FE4 needs the F02 `restoreMoves` additive API (small, F02-owned, bundled into FE4).
* Cross-feature (not a blocker): F07 is `Not Started` and depends on F08; F08 delivers the sync path via a fake-producer test seam (`architecture.md → Scope Boundary F08 ↔ F07`), it does not wait for F07. `[OPEN — F07]` items (cache population trigger, retention values, real Daily producer, streak rule) are explicitly out of F08 scope.
* Resolved and recorded: `product-prd §51` server-side streak/clock-integrity check → **not in the MVP** (Tech Lead decision, consistent with `platform.md` §6 — App Check soft-enforce + create-only rule are the only controls; no PO escalation needed).

---

## Last Decision

* 2026-09-06 — Tech Lead (**F08.CONTRACT-TL — contract finalized, `architecture.md` LOCKED**):
  * `analysis.md` consumed into `architecture.md`; every `[PENDING ANALYSIS]` section flipped to `[LOCKED]`.
  * **Call 1 — sync surface:** HTTPS Callable `submitDailyResultV1` (2nd gen). Direct client create-only write rejected — range/cross-field validation unsafe in rules alone, couples the client to the collection layout, no seam for a future leaderboard write. Matches `platform.md` §3/§4's pre-blessed "one RPC-style callable".
  * **Call 2 — identity:** **decouple** `player.guestId` (local UUID v4, durable local key, available offline) from `player.firebaseUid` (Anonymous UID, server identity / Firestore path / idempotency-key component, `null` until Auth completes). `platform.md` §6 **amended** to record this (offline-first forbids gating local play on Anonymous Auth, which can't complete offline on first launch; the local UUID is also the cleaner account-adoption anchor).
  * **Call 3 — F08↔F07:** F06-style split **confirmed**. F08 ships the persistence layer + `DailyPuzzleCache` mechanism + `DailyResultSyncService` + callable + rules + a fake daily-result producer test seam (emulator-verified end-to-end). F07 later wires the real Daily producer via the same `enqueue(...)`.
  * **Call 4 — `infra/` DURUM 0 sequencing:** **parallel** with the Drift core. F08.SETUP-0 (Project Setup) runs alongside Track A (F08-FE1…FE5, FE11 — no Firebase).
  * **Release Scope = `production-readiness`** — first Firebase deploy (Functions + rules + Remote Config); a backend-only gate per `release.md` §2. `release.md` §2 amended. `F08-DEVOPS` opens after QA and also covers rollback-readiness.
  * **App Check:** soft-enforce (monitor) for the MVP — locked. Hard-enforce is post-MVP, not F08. `platform.md` §13 amended.
  * **Parked-item retry:** bounded auto-retry — once per app start, max 3 lifetime post-park attempts, then dormant — locked.
  * **`product-prd §51` server-side streak/clock check:** **not in the MVP** — Tech Lead decision (retry/abuse-control ownership is Tech Lead per Open Questions Handling; consistent with `platform.md` §6). No PO escalation.
  * **`setup-manifest.md`** gained a full `## infra/ DURUM 0 Recipe (Firebase — triggered by F08)`; Workspace Targets `infra/` row updated. **F02 `architecture.md`** — `restoreMoves(List<Move>)` promoted from "decide during implementation" to **required by F08** (additive, non-breaking). **`connectivity_plus`** approved as a new `app/` dependency.
  * Delivery tasks opened: F08.SETUP-0 (Project Setup, next), F08-FE1…FE11 (Frontend/Mobile Developer), F08-BE2…BE5 (Backend Developer), F08-QA1…QA10 (QA, after BE+FE), F08-DEVOPS (DevOps/Release Engineer, after QA).
  * Routing: **Project Setup (F08.SETUP-0)** → Backend Developer (F08-BE2…BE5) + Frontend/Mobile Developer (F08-FE, Track A already parallel) → QA → Tech Lead → DevOps/Release Engineer (`production-readiness` gate) → Tech Lead (close). No UI Designer.
* 2026-09-06 — Tech Lead (F08 activation): activated after F06 `Done`; P0, next on the critical path (`product-prd.md` §12.6 build order; feature-board priority). Complexity COMPLEX → Technical Analyst pass. No UI Designer.

---

## Consumed Signals

* `analysis.md` (F08.0-AN) **consumed into `architecture.md` on 2026-09-06.** Downstream roles use `architecture.md` as contract authority; read `analysis.md` only for deeper rationale (§5 API detail, §8 edge-case catalogue, §16 task breakdown, §17 trade-off analysis).
* Unresolved analysis questions: **None that block implementation.** The remaining `[OPEN — …]` markers in `architecture.md` belong to F07 (Daily cache/producer/streak-rule), the DevOps/Release Engineer (deploy runbook, prod project, composite index), and a low-priority Tech Lead item (durable-table backup) — none is on F08's implementation path.

---

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-06
* Summary: **F08.CONTRACT-TL done — `architecture.md` LOCKED.** `analysis.md` consumed; 4 calls made (HTTPS callable `submitDailyResultV1`; decoupled `guestId`/`firebaseUid` with a `platform.md` §6 amendment; F06-style F08↔F07 split confirmed; `infra/` DURUM 0 parallel with the Drift core). `Release Scope = production-readiness` (`release.md` §2 amended). `platform.md` §6 + §13 amended (identity decouple; App Check soft-enforce locked; Drift schema + callable pointers). `setup-manifest.md` gained the `infra/` DURUM 0 recipe. F02 `architecture.md` — `restoreMoves` promoted to required. `connectivity_plus` approved. App Check soft-enforce + parked-item retry policy locked. `product-prd §51` server-side clock check ruled out of the MVP (no PO escalation). Delivery tasks opened: F08.SETUP-0 (Project Setup, next), F08-FE1…FE11, F08-BE2…BE5, F08-QA1…QA10, F08-DEVOPS (post-QA). Parallel-work strategy set (Track A no-Firebase FE || Track B infra+BE). Nothing committed to git.

---

## Next Role

Project Setup

---

## Next Action

### Project Setup — F08.SETUP-0

```text
Run the infra/ Firebase DURUM 0. This is a separate one-time Project Setup run (not Steps 1-7).

Authority: project-authority/setup-manifest.md -> "## infra/ DURUM 0 Recipe (Firebase — triggered by F08)"
(the step list); features/f08-offline-persistence-and-sync/architecture.md -> "Firebase Sync Surface" (the
create-only rule + callable contract the rules/skeleton must match), "Dependency Edges" (the exact Firebase client
package set), "App Init Sequence" (Project Setup does NOT add main.dart init — F08-FE6 owns it); project-authority/
platform.md §3/§6 (TypeScript Node 20, 2nd-gen callable, single MVP Firebase project, App Check soft-enforce);
project-authority/release.md §4 (CI jobs) / §7 (FIREBASE_CI_TOKEN name only).

Deliverables (see the recipe for the full step list):
1. infra/ project files: firebase.json, .firebaserc, firestore.rules (create-only for
   dailyResults/{lang}_{date}/entries/{uid} per architecture.md), firestore.indexes.json (empty),
   remoteconfig.template.json (daily_enabled / daily_sync_enabled / share_enabled = true; daily_manifest_url = "").
   Replace infra/README.md stub with a real overview.
2. infra/functions/ TS Firebase Functions package: package.json + tsconfig.json + src/index.ts exporting a 2nd-gen
   submitDailyResultV1 CALLABLE SKELETON (auth guard + enforceAppCheck:false + TODO body returning a typed INTERNAL
   — NO validation/write logic; that is Backend Developer F08-BE2). One emulator smoke test (unauthenticated call
   rejected). npm run build + npm test green.
3. @firebase/rules-unit-testing spec: allow-create-own / deny-create-other / deny-update / deny-delete / deny-read —
   green in the emulator.
4. CI wiring in .github/workflows/ci.yml (release.md §4): infra/functions npm ci && build && test; rules tests;
   gated on infra/** changes; actions pinned to SHA.
5. app/pubspec.yaml: add firebase_core ^3, firebase_auth ^5, cloud_firestore ^5, firebase_app_check ^0.3,
   cloud_functions ^5, connectivity_plus ^6 (nearest resolving versions; keep majors; record substitutions).
   Generate firebase_options.dart via the FlutterFire CLI + platform config files. DO NOT initialize Firebase in
   main.dart. Confirm flutter build ios --release --no-codesign AND flutter build appbundle --release still pass.
6. melos.yaml: add infra:build / infra:test scripts. Do not add infra/functions to the Dart packages: globs.
7. melos bootstrap; commit every pubspec.lock + infra/functions/package-lock.json.

If anything conflicts with platform.md / release.md / F08 architecture.md, stop and raise a Tech Lead blocker
(do not resolve silently). Produce the Project Setup report. On completion set Next Role = Tech Lead
(to reconcile the scaffold and route Backend Developer + Frontend/Mobile Developer into the F08-BE / F08-FE tasks).
```

**Parallel note (not blocked by F08.SETUP-0):** Frontend/Mobile Developer may begin **Track A** now — F08-FE1 (Drift schema) → FE2 (migrations + guard) → FE3 (repositories) → FE5 (elapsed helper), plus FE11 (`toEngineConfig`). FE4 bundles the additive F02 `restoreMoves(List<Move>)` API (F02-owned review). These need no Firebase. If the user runs `Run Frontend/Mobile Developer` before Project Setup, that is a valid parallel start; `orchestration.md → Next Role` names Project Setup as the primary long-pole.

---

## Change Log

* v1 (2026-09-06) — Tech Lead: F08 created and activated after F06 `Done`. P0, next on the critical path (`product-prd.md` §12.6 build order; feature-board priority). `prd.md` + initial `architecture.md` skeleton (LOCKED substrate + 10 PENDING-ANALYSIS items) + orchestration. Complexity COMPLEX → Technical Analyst pass (F08.0-AN → `analysis.md`). No UI Designer. DevOps/Release Engineer + Project Setup (`infra/` DURUM 0) expected. Routing: Technical Analyst → Tech Lead (finalize contract) → Project Setup → Backend + Frontend → QA → Tech Lead → DevOps/Release Engineer → Tech Lead. `feature-board.md` + `system-state.md` synced.
* v2 (2026-09-06) — Technical Analyst: F08.0-AN done. `analysis.md` delivered (sections 1–19). All 10 open items resolved. Recommendations: HTTPS callable `submitDailyResultV1`; decouple local `guestId` from `firebaseUid` (flagged `platform.md §6` reconciliation); F06-style F08↔F07 split (persistence core + sync + fake producer now, F07 wires real producer); parallel `infra/` DURUM 0. Specified: Drift schema (§6.1), locked active-session snapshot JSON (§6.2), `sync_queue` state machine (§6.3), exactly-once + reconciliation (§4.6), callable contract (§5), task breakdown (§16). Contract risks + upstream `platform.md §6` conflict in §17. Current Owner → Tech Lead; Next Role → Tech Lead (F08.CONTRACT-TL).
* v3 (2026-09-06) — Tech Lead: **F08.CONTRACT-TL done — `architecture.md` LOCKED.** `analysis.md` consumed. Calls: (1) HTTPS Callable `submitDailyResultV1`; (2) decouple `guestId` (local UUID) / `firebaseUid` (server) — `platform.md` §6 amended; (3) F06-style F08↔F07 split confirmed (F08 = persistence + sync + fake producer; F07 = real producer); (4) `infra/` DURUM 0 parallel with the Drift core. `Release Scope = production-readiness` (`release.md` §2 amended). `platform.md` §6 + §13 amended (identity decouple; App Check soft-enforce locked; Drift schema + callable pointers). `setup-manifest.md` gained the `infra/` DURUM 0 recipe + Workspace Targets update. F02 `architecture.md` — `restoreMoves(List<Move>)` promoted to required (additive). `connectivity_plus` approved. App Check soft-enforce + parked-item retry (bounded auto-retry, once/app-start, max 3 lifetime) locked. `product-prd §51` server-side clock check ruled out of the MVP. Delivery tasks opened: F08.SETUP-0 (Project Setup, NEXT), F08-FE1…FE11 (Frontend/Mobile Developer — Track A parallel now), F08-BE2…BE5 (Backend Developer), F08-QA1…QA10 (QA, post BE+FE), F08-DEVOPS (DevOps/Release Engineer, post-QA). Current Owner → Project Setup; Next Role → Project Setup (F08.SETUP-0). `feature-board.md` + `system-state.md` synced by the Tech Lead this turn.
