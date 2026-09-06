# F08 — offline-persistence-and-sync: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In Progress — Track A (persistence core) delivered. Track B (sync callable + rules) next.**

---

## Current Owner

Backend Developer (Track B — fill the `submitDailyResultV1` callable + rules + emulator tests)

---

## Current Phase

Contract LOCKED; `infra/` DURUM 0 done + reconciled.
* **Track A (Frontend/Mobile Developer) — DELIVERED 2026-09-06** (`frontend.md`): Drift `AppDatabase` (10 tables + `kv`, `schemaVersion 1`, seeded), forward-only migrations + `MigrationGuard` never-drop, all write-through repositories, `ActiveSessionSnapshot` (frozen keys) + corrupt-safe `ActiveSessionRepo` + `restoreSession`, `ElapsedTimer`, `toEngineConfig`, `DailyResultSyncService` (queue state machine + backoff + exactly-once + first-run-authoritative + parked bounded-retry, injectable sender), `FakeDailyResultProducer`. **263 workspace tests green** (app 67 = 4 + 63 new); `analyze`/`format:check`/`infra:build`/`infra:test` green. F02 `GridEngine.restoreMoves` was already present + tested — no F02 change.
* **Track B (Backend Developer, emulator = fake project id) — NEXT:** fill the `submitDailyResultV1` callable → verify rules + rules-unit-tests → Functions emulator tests → CI emulator step. `F08-BE2…BE5`.
* **`F08.FIREBASE-PROJECT`** (manual, owner: user): real Firebase project + `flutterfire configure` + Anonymous Auth/App Check enable + `firebase-tools`/`FIREBASE_CI_TOKEN` in CI. Blocks `F08-FE6/FE8/FE9` + `F08-DEVOPS` (the join phase), nothing before it.

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
- [x] Task ID: F08.SETUP-0 | Assigned Role: Project Setup | Status: **Done (2026-09-06)** | `infra/` Firebase DURUM 0 scaffolded per `setup-manifest.md → ## infra/ DURUM 0 Recipe`. Created: `infra/firebase.json`, `.firebaserc` (placeholder project `looplet-mvp`), `firestore.rules` (create-only for `dailyResults/{lang}_{date}/entries/{uid}`; default-deny elsewhere), `firestore.indexes.json` (empty), `remoteconfig.template.json` (`daily_enabled`/`daily_sync_enabled`/`share_enabled`=true, `daily_manifest_url`=""), `infra/.gitignore`, `infra/README.md` (rewritten). `infra/functions/` (TypeScript, Node 20): `package.json` + `tsconfig.json` + `jest.config.js` + `src/{index,submitDailyResult,types}.ts` (`submitDailyResultV1` 2nd-gen `onCall` **skeleton** — auth guard + `enforceAppCheck:false` soft + typed wire contract; body throws `INTERNAL` with `TODO(F08-BE2)`) + `test/skeleton.test.ts` (6 offline tests green) + `test/rules.test.ts` (`@firebase/rules-unit-testing`, emulator-gated → skipped without `FIRESTORE_EMULATOR_HOST`). `npm ci && npm run build && npm test` green. CI: `infra` job added to `.github/workflows/ci.yml` (npm ci/build/test; emulator step left as `TODO(F08-BE5/F08-DEVOPS)`). `melos.yaml`: `infra:build` + `infra:test` scripts. `app/pubspec.yaml`: `firebase_core ^3.6.0`, `firebase_auth ^5.3.1`, `cloud_firestore ^5.4.4`, `cloud_functions ^5.1.3`, `firebase_app_check ^0.3.1+7`, `connectivity_plus ^6.0.5` (no `main.dart` init — F08-FE6). `flutter pub get` + `melos bootstrap` + `melos run format:check`/`analyze`/`test` all green; app `flutter analyze` + `flutter test` (4) green. **Version substitutions vs the recipe:** `firebase-functions ^6` (recipe `^5`, EOL), `firebase-admin ^13` (recipe `^12`), `@firebase/rules-unit-testing ^5` + `firebase ^12` dev-dep (recipe `^4`; `^4` peer-conflicts on `firebase@^11`). **Deferred (needs a real Firebase project + `firebase login` — not available in this environment):** `.firebaserc` real project id, `flutterfire configure` → `app/lib/firebase_options.dart` + `google-services.json` + `GoogleService-Info.plist`, `firebase-tools` in CI for the emulator suites, any `firebase deploy`. Documented in `infra/README.md`. Full native iOS/Android app build with the Firebase pods not run locally (CI / F08-FE9 verifies — consistent with the existing "Android `build:app` CI-only locally" posture).
- [x] Task ID: F08-FE1 | Assigned Role: Frontend/Mobile Developer | Status: **Done (2026-09-06)** | `app/lib/persistence/app_database.dart` (+ `.g.dart`, committed) — all 10 contract tables with exact contract names + `kv`; composite PKs; `textEnum` for `syncStatus`/`state`; `schemaVersion = 1`; `_seedDefaults()` (onCreate transaction) seeds one `player` (v4 UUID `guestId`, null `firebaseUid`) + `settings`/`journey_progress`/`daily_streak` defaults + `store_meta` kv. `AppDatabase.forTesting(NativeDatabase.memory())`. 6 tests.
- [x] Task ID: F08-FE2 | Assigned Role: Frontend/Mobile Developer | Status: **Done** | `migration_guard.dart` — `MigrationGuard.guardPlayerData` snapshots + re-checks row counts of `personal_best`/`daily_entry`/`daily_streak`, throws `MigrationDataLossError` (→ `onUpgrade` rollback) on any shrink. `AppDatabase.migration` = guarded `for v in from..to` step switch (zero steps at v1; `// case 1:` placeholder). Store downgrade documented unsupported; migration-throw = abort-without-partial-apply (no silent wipe). 4 tests incl. "throws when a protected row is deleted".
- [x] Task ID: F08-FE3 | Assigned Role: Frontend/Mobile Developer | Status: **Done** | `repositories/*.dart` — `PlayerRepo`, `SettingsRepo`, `JourneyProgressRepo` (CSV union + `highestUnlockedLevel = max(current, level+1)`), `PersonalBestRepo` (monotone ↓, `isPerfect`, `firstCompletedAt` preserved), `DailyRepo` (first-run immutable + `attemptNo`-incrementing `daily_attempt` rows + `setSyncStatus` mirror; returns `DailyCompletionOutcome`), `DailyStreakRepo` (store-only), `DailyPuzzleCache` (put/get/`evictOlderThan`), `ActiveSessionRepo`, `SyncQueueRepo`. All write-through; multi-step ops transactional. 9 repo tests.
- [x] Task ID: F08-FE4 | Assigned Role: Frontend/Mobile Developer | Status: **Done** | `active_session_snapshot.dart` (frozen JSON keys; `fromJson` validates all contract rules incl. `moveCount == appliedMoves.length` + token parse + coord format → `SnapshotFormatException`), `active_session_repo.dart` (`kv['active_session']` single-row upsert; `read()` catches decode/format → log `save_corrupt_recovered` + `clear()` + null; durable tables untouched), `session_restore.dart` (`restoreSession` → `toEngineConfig` → `GridEngine` → `restoreMoves(parseMoveList(...))` → `RestoredSession`; re-derives `thawedCells`; id-mismatch / rejected-move → `SessionRestoreException`). **F02 `GridEngine.restoreMoves(List<Move>)` was already present + tested** (prior session; Tech Lead promoted it to "required" this cycle) — no F02 change; 83 F02 tests unchanged + green. 17 snapshot + 5 restore tests.
- [x] Task ID: F08-FE5 | Assigned Role: Frontend/Mobile Developer | Status: **Done** | `elapsed_timer.dart` — `ElapsedTimer` `Stopwatch` accumulator + `.resumed(accumulatedMs)`; no wall clock for elapsed; negative → assert. 4 tests.
- [ ] Task ID: F08-FE6 | Assigned Role: Frontend/Mobile Developer | Status: Open — **gated on `F08.FIREBASE-PROJECT`** | App-init sequence per `architecture.md → App Init Sequence`: open DB → migrate → seed → read snapshot → (async, non-blocking) Firebase init + App Check + Anonymous sign-in (persist `firebaseUid` on success) → construct session-level sync service → `drain()`. Migration-failure recoverable error screen (only F08-owned UI). Wire into `app/lib/main.dart`.
- [x] Task ID: F08-FE7 | Assigned Role: Frontend/Mobile Developer | Status: **Done (logic; emulator e2e joins with Track B)** | `daily_result_sync_service.dart` — `DailyResultSyncService` session-level: `enqueueFirstRun` (queue row + entry `queued`, same txn; idempotency key `{firebaseUid}|{lang}|{dailyDate}` or null → `awaitingAuth`); `drain()` (kill-switch no-op; stale-`inFlight` sweep >20s; key backfill; `inFlight` → `sender` → `CREATED`/`ALREADY_SUBMITTED` ⇒ `synced` + entry mirror; `retryable` ⇒ `pending` + `attemptCount++` + exp backoff base 30s ×2 cap 6h ±20% jitter; cap 10 or `nonRetryable` ⇒ `parked` + entry mirror); `reviveParkedOnAppStart` bounded to 3 lifetime. `SyncSender` + `connectivityRegained` injected (real ones = FE8/FE9). 14 tests incl. exactly-once + first-run-authoritative + awaitingAuth + stale-reclaim.
- [ ] Task ID: F08-FE8 | Assigned Role: Frontend/Mobile Developer | Status: Open — **gated on `F08.FIREBASE-PROJECT` + F08-BE2** | Real `SyncSender` binding to the `submitDailyResultV1` callable (`cloud_functions`) + typed error → `SyncSendResult` mapping (mapping logic already implemented + tested in FE7 against a fake sender); client pre-enqueue payload assertion (present in `enqueueFirstRun`/`DailyResultPayload`).
- [ ] Task ID: F08-FE9 | Assigned Role: Frontend/Mobile Developer | Status: Open — **gated on `F08.FIREBASE-PROJECT`** | Construct `DailyResultSyncService` as an app-scoped singleton with the real sender + a `connectivity_plus` regain stream; guarded offline-tolerant `Firebase.initializeApp`; confirm the app builds + runs with the Firebase pods (iOS/Android).
- [x] Task ID: F08-FE10 | Assigned Role: Frontend/Mobile Developer | Status: **Done** | `fake_daily_result_producer.dart` — `FakeDailyResultProducer.produce(...)` records a completion via `DailyRepo` and, on `firstRun`, calls `enqueueFirstRun`. `assert(false)` + no-op in release. F07 replaces it against the same `enqueueFirstRun`. 1 test (first → firstRun + 1 queue row; repeat → replay + no new row).
- [x] Task ID: F08-FE11 | Assigned Role: Frontend/Mobile Developer | Status: **Done** | `content/puzzle_engine_config.dart` — `toEngineConfig(Puzzle) → EngineConfig` free function in `app/`; `looplet_content` stays `looplet_core`-only; propagates `EngineConfigError`. Shared with F05. 2 tests. (Also: `engine/move_shorthand.dart` — app-local shorthand parse/format; ~40-line duplication of the `tools` copy flagged in `frontend.md §4` for a future dedupe.)
- [ ] Task ID: F08.FIREBASE-PROJECT | Assigned Role: user (DevOps/Release Engineer fallback) | Status: Open — manual, out-of-band | Create the real Firebase project + `firebase login` + `firebase use --add` (real id → `infra/.firebaserc`) + `flutterfire configure` from `app/` (→ `app/lib/firebase_options.dart` + `google-services.json` + `GoogleService-Info.plist`, all committed — not secret, `release.md` §7) + enable Anonymous Auth + App Check (monitor). Prerequisite for F08-FE6/FE8/FE9 and F08-DEVOPS; NOT for Track A or F08-BE2/BE3/BE4 (emulator uses a fake project id). See `infra/README.md` → "Not done yet".
- [x] Task ID: F08-BE1 | Assigned Role: Project Setup | Status: folded into F08.SETUP-0 | `infra/` scaffold (see F08.SETUP-0).
- [ ] Task ID: F08-BE2 | Assigned Role: Backend Developer | Status: Open — **ready now** (fills the F08.SETUP-0 skeleton; emulator uses a fake project id) | Implement `submitDailyResultV1` in `infra/functions/src/submitDailyResult.ts`: auth guard (kept), App Check soft-enforce (kept), full payload validation (`architecture.md → Firebase Sync Surface` — `lang ∈ {tr,en}`, `dailyDate` regex, `dailyId` non-empty, `optimalMoves ≥ 1`, `optimalMoves ≤ moves`, `durationMs ≥ 0`, `stars ∈ 1..3`, `completedAtUtcMs > 0`), create-only Firestore write at `dailyResults/{lang}_{dailyDate}/entries/{uid}` (`DailyResultDoc` shape in `types.ts`), return `{status: "CREATED"|"ALREADY_SUBMITTED", recordedAt}`; typed `HttpsError` for `INVALID_PAYLOAD`/`UNSUPPORTED_LANGUAGE`/`INTERNAL`. Keep `test/skeleton.test.ts` green (update the 2 "reaches INTERNAL" assertions to the real behaviour) + add `test/submitDailyResult.test.ts` (emulator, via `firebase-functions-test` + Firestore emulator).
- [ ] Task ID: F08-BE3 | Assigned Role: Backend Developer | Status: Open — **ready now** | `infra/firestore.rules` already scaffolded (create-only own-uid, default-deny). Verify against `architecture.md`; `test/rules.test.ts` (`@firebase/rules-unit-testing`) is written and emulator-gated — make it run green under the Firestore emulator (allow-create-own, deny-create-other, deny-unauth, deny-update, deny-delete, deny-read).
- [ ] Task ID: F08-BE4 | Assigned Role: Backend Developer | Status: Open (gated on F08-BE2) | Functions emulator unit tests: valid create → `CREATED`; duplicate → `ALREADY_SUBMITTED` (existing server doc unchanged); each validation failure → its code; missing auth → `unauthenticated`.
- [ ] Task ID: F08-BE5 | Assigned Role: Backend Developer | Status: Open | CI: add a Firebase-emulator step to the `infra` job in `.github/workflows/ci.yml` (`firebase emulators:exec --only firestore,auth "npm test"` from `infra/`, needs `firebase-tools` + Java on the runner) so `test/rules.test.ts` + `test/submitDailyResult.test.ts` run for real (`release.md` §4). Any new GitHub Action (e.g. Java setup) pinned to a commit SHA.
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
- [x] (F08.SETUP-0) `infra/` Firebase DURUM 0 + `app/` Firebase client wiring — **done 2026-09-06; reconciled by the Tech Lead 2026-09-06.** Scaffold + skeleton + tests + CI + melos scripts green. Real-Firebase-project steps split out as `F08.FIREBASE-PROJECT`.

### Prerequisite (manual, out-of-band)
- [ ] (F08.FIREBASE-PROJECT) Create + wire the real Firebase project — owner: user (DevOps/Release Engineer fallback). Blocks F08-FE6/FE8/FE9 + F08-DEVOPS; not Track A or F08-BE2/BE3/BE4. See the Active Task Ledger entry + `infra/README.md`.

### Backend
- [ ] (F08-BE2) `submitDailyResultV1` implementation. (F08-BE1 folded into F08.SETUP-0.)
- [ ] (F08-BE3) `firestore.rules` create-only + rules-unit-tests.
- [ ] (F08-BE4) Functions emulator unit tests.
- [ ] (F08-BE5) CI wiring for `infra/`.

### Frontend
- [x] (F08-FE1) Drift schema + `AppDatabase` — done.
- [x] (F08-FE2) Migrations + never-drop guard + migration test harness — done.
- [x] (F08-FE3) Repositories (write-through, transactional) — done.
- [x] (F08-FE4) Active-session snapshot serialize/restore — done (F02 `restoreMoves` was already present + tested).
- [x] (F08-FE5) Monotonic elapsed helper — done.
- [ ] (F08-FE6) App-init sequence + migration-error screen — **gated on `F08.FIREBASE-PROJECT`**.
- [x] (F08-FE7) `DailyResultSyncService` (session-level; queue state machine; backoff; parked retry; kill-switch) — done (logic; real sender/connectivity = FE8/FE9).
- [ ] (F08-FE8) Callable client binding — **gated on `F08.FIREBASE-PROJECT` + F08-BE2** (response-mapping logic already done in FE7).
- [ ] (F08-FE9) Firebase init finalization + app-scoped singleton wiring — **gated on `F08.FIREBASE-PROJECT`**.
- [x] (F08-FE10) Fake daily-result producer test seam — done.
- [x] (F08-FE11) `toEngineConfig(Puzzle)` consumer helper — done.

_Track A delivered (`frontend.md`). FE6/FE8/FE9 remain, gated on `F08.FIREBASE-PROJECT`._

### QA
- [ ] (F08-QA1…QA10) Full matrix per `architecture.md → QA Focus`. Opens when BE + FE complete.

### DevOps / Release
- [ ] (F08-DEVOPS) `production-readiness` — Firebase deploy readiness + rollback-readiness + smoke + `features/f08-.../release.md`. Opens **after QA**.

### Parallel-work strategy (post-F08.SETUP-0)
- **Track A — Frontend/Mobile Developer, START NOW (no Firebase):** F08-FE1 (Drift schema) → FE2 (migrations + never-drop guard + test harness) → FE3 (repositories) → FE5 (elapsed helper) → FE11 (`toEngineConfig`) → FE4 (active-session snapshot + the additive F02 `restoreMoves(List<Move>)` in `looplet_engine`, re-run the 83 F02 engine tests). FE7/FE10 logic can also be written here (their emulator verification joins with Track B). → produce a partial `frontend.md`; set `Next Role = Backend Developer` (or Tech Lead) when Track A is delivered.
- **Track B — Backend Developer, in parallel (emulator uses a fake project id — no `F08.FIREBASE-PROJECT` needed):** F08-BE2 (fill the callable) → BE3 (rules + rules-unit-tests green under the emulator) → BE4 (Functions emulator tests) → BE5 (CI emulator step). → `backend.md`.
- **`F08.FIREBASE-PROJECT`** (manual, user): needed before the join.
- **Join — Frontend/Mobile Developer:** F08-FE6 (app-init) → FE8 (callable client binding, needs BE2) → FE9 (Firebase init finalization). Needs `F08.FIREBASE-PROJECT` + Track B.
- **Then:** QA (F08-QA1…QA10) → Tech Lead → DevOps/Release Engineer (F08-DEVOPS, `production-readiness`) → Tech Lead (close).

---

## Blockers

* **None hard.** Contract LOCKED; `infra/` scaffold done + reconciled; **Track A delivered green** (263 workspace tests).
* **Manual prerequisite → task `F08.FIREBASE-PROJECT` (opened, owner: user, DevOps/Release Engineer fallback).** Create the real Firebase project in the Firebase Console + `firebase login` + `firebase use --add` (real id into `infra/.firebaserc`) + `flutterfire configure` from `app/` (→ `app/lib/firebase_options.dart` + `google-services.json` + `GoogleService-Info.plist`) + enable Anonymous Auth + enable App Check in **monitor** mode. Not doable in the agent environment. Scope of impact:
  * **Blocks:** `F08-FE6` (app `Firebase.initializeApp` needs `firebase_options.dart`), `F08-FE8` / `F08-FE9` (callable client + init), `F08-DEVOPS` (deploy). Required before the **join** phase.
  * **Does NOT block:** Track A (`F08-FE1…FE5`, `FE11`) — no Firebase at all. `F08-BE2/BE3/BE4` — the Firestore emulator + `@firebase/rules-unit-testing` run against **any (fake) project id**; they need only `firebase-tools` installed (an npm global — a code/CI task, `F08-BE5`), not a real project. `F08-FE7` / `F08-FE10` logic can be written against the skeleton (their end-to-end emulator verification joins with BE).
* Cross-feature (not a blocker): F07 `Not Started`, depends on F08; F08 delivers the sync path via the fake-producer seam. `[OPEN — F07]` items are out of F08 scope.
* Resolved/recorded: `product-prd §51` server-side clock check → not in the MVP.

---

## Last Decision

* 2026-09-06 — Tech Lead (**F08.SETUP-0 reconciliation + implementation routing**):
  * **F08.SETUP-0 accepted.** The `infra/` scaffold matches the LOCKED contract: `firestore.rules` create-only for `dailyResults/{lang}_{date}/entries/{uid}` (+ default-deny) = `architecture.md → Firebase Sync Surface → Rules`; the `submitDailyResultV1` 2nd-gen `onCall` skeleton (auth guard + `enforceAppCheck:false` soft + `types.ts` wire contract, body deferring to F08-BE2) = the callable contract; `app/pubspec.yaml` Firebase client set (`firebase_core`/`auth`/`firestore`/`functions`/`app_check`) + `connectivity_plus` = `architecture.md → Dependency Edges`; Remote Config keys = `release.md` §6. Gates green (`format:check`/`analyze`/`test`/`infra:build`/`infra:test`/`bootstrap` + app `analyze`/`test`). **Version substitutions accepted:** `firebase-functions ^6` (recipe `^5`, EOL), `firebase-admin ^13` (`^12`), `@firebase/rules-unit-testing ^5` + `firebase ^12` dev (`^4` peer-conflicts) — current stable, no contract impact.
  * **Manual Firebase-project step split out as `F08.FIREBASE-PROJECT`** (owner: user; DevOps/Release Engineer fallback). It blocks `F08-FE6/FE8/FE9` + `F08-DEVOPS` only — **not** Track A and **not** `F08-BE2/BE3/BE4` (the Firestore emulator + `@firebase/rules-unit-testing` run against a fake project id; they need only `firebase-tools`, which is `F08-BE5`'s CI task).
  * **Routing:** parallel. **Next Role = Frontend/Mobile Developer** for **Track A** (`F08-FE1 → FE2 → FE3 → FE5 → FE11 → FE4` incl. the additive F02 `restoreMoves`); **Backend Developer** runs **Track B** (`F08-BE2 → BE3 → BE4 → BE5`) in parallel (user may `Run Backend Developer` any time). Join (`FE6/FE8/FE9`) needs `F08.FIREBASE-PROJECT` + Track B. Then QA → Tech Lead → DevOps/Release Engineer → Tech Lead.
  * No contract change. No re-QA of the scaffold needed.
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

* Updated By: Frontend/Mobile Developer
* Timestamp: 2026-09-06
* Summary: **F08 Track A delivered** (`frontend.md`). FE1 (Drift `AppDatabase` — 10 contract tables + `kv`, `schemaVersion 1`, onCreate seed), FE2 (`MigrationGuard` never-drop + guarded `onUpgrade` framework + migration-throw = no wipe), FE3 (all write-through transactional repositories), FE4 (`ActiveSessionSnapshot` frozen keys + corrupt-safe `ActiveSessionRepo` + `restoreSession` re-deriving `thawedCells`; F02 `GridEngine.restoreMoves` was already present + tested — no F02 change needed), FE5 (`ElapsedTimer` monotonic), FE11 (`toEngineConfig`), plus FE7 (`DailyResultSyncService` — queue state machine + exp backoff + exactly-once + first-run-authoritative + `awaitingAuth` + stale-`inFlight` reclaim + parked bounded auto-retry + kill-switch; injectable sender/connectivity) and FE10 (`FakeDailyResultProducer`). **263 workspace tests green** (app 67 = 4 pre-existing + 63 new); `melos run analyze` / `format:check` / `infra:build` / `infra:test` green; `app_database.g.dart` committed. Non-blocking notes (`frontend.md §4/§16`): move-shorthand ~40-line duplication vs `tools/looplet_authoring` (future dedupe); `uuid` package not added (hand-rolled v4). **FE6/FE8/FE9 remain — gated on `F08.FIREBASE-PROJECT`.** Nothing committed to git.

---

## Next Role

Backend Developer

---

## Next Action

### Frontend/Mobile Developer — F08 Track A (persistence core) — ✅ DELIVERED 2026-09-06

See `frontend.md`. FE1–FE5, FE7, FE10, FE11 complete; 263 workspace tests green. FE6 / FE8 / FE9 remain, gated on `F08.FIREBASE-PROJECT`.

### Backend Developer — F08 Track B (NEXT)

```text
Fill the submitDailyResultV1 skeleton + finalize the rules. The Firestore/Functions emulator runs against
a FAKE project id — F08.FIREBASE-PROJECT is NOT required for Track B.

Authority: architecture.md -> "Firebase Sync Surface [LOCKED — HTTPS Callable]" (request/validation/
response/error tables), "Reconciliation Algorithm", "Validation Responsibility"; platform.md §4 (error
format + codes) / §8 (payload ranges) / §6 (create-only rule, App Check soft-enforce).

F08-BE2 — infra/functions/src/submitDailyResult.ts: keep the auth guard + soft App Check; add full
  payload validation; do the create-only Firestore write at dailyResults/{lang}_{dailyDate}/entries/{uid}
  (DailyResultDoc shape); return { status: "CREATED" | "ALREADY_SUBMITTED", recordedAt }; typed HttpsError
  for INVALID_PAYLOAD / UNSUPPORTED_LANGUAGE / INTERNAL. Update the 2 skeleton.test.ts assertions that
  currently expect "internal".
F08-BE3 — verify infra/firestore.rules vs architecture.md; make test/rules.test.ts green under the
  Firestore emulator (it is already written + emulator-gated).
F08-BE4 — test/submitDailyResult.test.ts (firebase-functions-test + Firestore emulator): valid -> CREATED;
  duplicate -> ALREADY_SUBMITTED (server doc unchanged); each validation failure -> its code; no auth ->
  unauthenticated.
F08-BE5 — add the emulator step to the `infra` CI job (firebase emulators:exec ... "npm test"); pin any
  new action to a SHA.

Produce features/f08-.../backend.md. On completion set Next Role = Tech Lead.
(Track A is DONE — the client is ready to consume the callable; only the join tasks FE6/FE8/FE9 remain
and they are gated on F08.FIREBASE-PROJECT, not on Track B.)
```

---

## Change Log

* v1 (2026-09-06) — Tech Lead: F08 created and activated after F06 `Done`. P0, next on the critical path (`product-prd.md` §12.6 build order; feature-board priority). `prd.md` + initial `architecture.md` skeleton (LOCKED substrate + 10 PENDING-ANALYSIS items) + orchestration. Complexity COMPLEX → Technical Analyst pass (F08.0-AN → `analysis.md`). No UI Designer. DevOps/Release Engineer + Project Setup (`infra/` DURUM 0) expected. Routing: Technical Analyst → Tech Lead (finalize contract) → Project Setup → Backend + Frontend → QA → Tech Lead → DevOps/Release Engineer → Tech Lead. `feature-board.md` + `system-state.md` synced.
* v2 (2026-09-06) — Technical Analyst: F08.0-AN done. `analysis.md` delivered (sections 1–19). All 10 open items resolved. Recommendations: HTTPS callable `submitDailyResultV1`; decouple local `guestId` from `firebaseUid` (flagged `platform.md §6` reconciliation); F06-style F08↔F07 split (persistence core + sync + fake producer now, F07 wires real producer); parallel `infra/` DURUM 0. Specified: Drift schema (§6.1), locked active-session snapshot JSON (§6.2), `sync_queue` state machine (§6.3), exactly-once + reconciliation (§4.6), callable contract (§5), task breakdown (§16). Contract risks + upstream `platform.md §6` conflict in §17. Current Owner → Tech Lead; Next Role → Tech Lead (F08.CONTRACT-TL).
* v3 (2026-09-06) — Tech Lead: **F08.CONTRACT-TL done — `architecture.md` LOCKED.** `analysis.md` consumed. Calls: (1) HTTPS Callable `submitDailyResultV1`; (2) decouple `guestId` (local UUID) / `firebaseUid` (server) — `platform.md` §6 amended; (3) F06-style F08↔F07 split confirmed (F08 = persistence + sync + fake producer; F07 = real producer); (4) `infra/` DURUM 0 parallel with the Drift core. `Release Scope = production-readiness` (`release.md` §2 amended). `platform.md` §6 + §13 amended (identity decouple; App Check soft-enforce locked; Drift schema + callable pointers). `setup-manifest.md` gained the `infra/` DURUM 0 recipe + Workspace Targets update. F02 `architecture.md` — `restoreMoves(List<Move>)` promoted to required (additive). `connectivity_plus` approved. App Check soft-enforce + parked-item retry (bounded auto-retry, once/app-start, max 3 lifetime) locked. `product-prd §51` server-side clock check ruled out of the MVP. Delivery tasks opened: F08.SETUP-0 (Project Setup, NEXT), F08-FE1…FE11 (Frontend/Mobile Developer — Track A parallel now), F08-BE2…BE5 (Backend Developer), F08-QA1…QA10 (QA, post BE+FE), F08-DEVOPS (DevOps/Release Engineer, post-QA). Current Owner → Project Setup; Next Role → Project Setup (F08.SETUP-0). `feature-board.md` + `system-state.md` synced by the Tech Lead this turn.
* v4 (2026-09-06) — Project Setup: **F08.SETUP-0 done — `infra/` Firebase DURUM 0 scaffolded.** `infra/` config (`firebase.json`, `.firebaserc` placeholder, `firestore.rules` create-only, `firestore.indexes.json`, `remoteconfig.template.json`, `.gitignore`, `README.md`) + `infra/functions/` TypeScript package (`submitDailyResultV1` 2nd-gen `onCall` skeleton — auth guard + soft App Check + typed wire contract; `TODO(F08-BE2)` body) + `test/skeleton.test.ts` (6 offline, green) + `test/rules.test.ts` (emulator-gated) + `jest.config.js`. `npm ci && build && test` green. CI `infra` job added (`.github/workflows/ci.yml`; emulator step deferred to `F08-BE5`/`F08-DEVOPS`). `melos.yaml` `infra:build`/`infra:test`. `app/pubspec.yaml` + Firebase client packages (`firebase_core ^3.6.0`, `firebase_auth ^5.3.1`, `cloud_firestore ^5.4.4`, `cloud_functions ^5.1.3`, `firebase_app_check ^0.3.1+7`) + `connectivity_plus ^6.0.5`. `flutter pub get` + `melos bootstrap` + `melos run format:check`/`analyze`/`test` + `melos run infra:build`/`infra:test` + app `flutter analyze`/`test` (4) all green. Version substitutions vs recipe: `firebase-functions ^6` (recipe `^5`), `firebase-admin ^13` (`^12`), `@firebase/rules-unit-testing ^5` + `firebase ^12` dev (`^4` peer-conflicts). Deferred (needs a real Firebase project + `firebase login`): `.firebaserc` real id, `flutterfire configure` → `firebase_options.dart` + platform config, `firebase-tools` in CI, deploy — recorded in `infra/README.md`. Current Owner → Tech Lead; Next Role → Tech Lead (reconcile scaffold + route Backend Developer + Frontend/Mobile Developer). Nothing committed to git.
* v5 (2026-09-06) — Tech Lead: **F08.SETUP-0 reconciled + accepted; implementation routed.** Scaffold matches the LOCKED contract (create-only rules, callable skeleton, Firebase client package set, Remote Config keys); all gates green; version substitutions accepted (no contract impact). Manual Firebase-project work split into `F08.FIREBASE-PROJECT` (owner: user; DevOps/Release Engineer fallback) — blocks only `F08-FE6/FE8/FE9` + `F08-DEVOPS`; **not** Track A and **not** `F08-BE2/BE3/BE4` (emulator uses a fake project id). Routing: **Next Role = Frontend/Mobile Developer** → Track A (`F08-FE1 → FE2 → FE3 → FE5 → FE11 → FE4`, incl. the additive `GridEngine.restoreMoves(List<Move>)` in `looplet_engine`; FE7/FE10 logic allowed too). **Backend Developer** runs Track B (`F08-BE2 → BE3 → BE4 → BE5`) in parallel. Join (`FE6/FE8/FE9`) needs `F08.FIREBASE-PROJECT` + Track B. Then QA → Tech Lead → DevOps/Release Engineer → Tech Lead. No contract change; no scaffold re-QA. `feature-board.md` + `system-state.md` synced (Active Owner → Frontend/Mobile Developer).
* v6 (2026-09-06) — Frontend/Mobile Developer: **F08 Track A delivered** (`frontend.md`). Completed F08-FE1 (Drift `AppDatabase` — 10 contract tables + `kv`, `schemaVersion 1`, onCreate seed), FE2 (`MigrationGuard` never-drop guard + guarded `onUpgrade` framework; migration-throw = abort, no wipe), FE3 (write-through transactional repositories: `Player`/`Settings`/`JourneyProgress`/`PersonalBest`(monotone)/`Daily`(first-run-immutable + attempts)/`DailyStreak`(store-only)/`DailyPuzzleCache`/`ActiveSession`/`SyncQueue`), FE4 (`ActiveSessionSnapshot` frozen keys + validation + corrupt-safe `ActiveSessionRepo` + `restoreSession` re-deriving `thawedCells`; **F02 `GridEngine.restoreMoves` was already implemented + tested by a prior session — no F02 change made**, 83 F02 tests unchanged), FE5 (`ElapsedTimer` monotonic, no wall clock), FE11 (`toEngineConfig(Puzzle)` in `app/`), FE7 (`DailyResultSyncService` — queue state machine + exp backoff base30s×2cap6h±20% + attempt cap 10 → `parked` + stale-`inFlight` reclaim + `awaitingAuth` backfill + parked bounded auto-retry(3) + `daily_entry.syncStatus` mirror + `daily_sync_enabled` kill-switch; injectable `SyncSender`/connectivity), FE10 (`FakeDailyResultProducer` debug seam). **263 workspace tests green** (app **67** = 4 + 63 new); `analyze`/`format:check`/`infra:build`/`infra:test` green; `app_database.g.dart` committed. Non-blocking (`frontend.md §4/§16`): move-shorthand ~40-line dup vs `tools/looplet_authoring`; `uuid` package not added (hand-rolled v4). **Remaining: FE6/FE8/FE9 — gated on `F08.FIREBASE-PROJECT`.** Current Owner → Backend Developer; Next Role → Backend Developer (Track B — fill the `submitDailyResultV1` callable + rules + emulator tests).
