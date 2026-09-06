# F08 — offline-persistence-and-sync: QA Report

Role: QA · Date: 2026-09-06

---

## 0a. Evidence Mode Declaration

* Bash / build access: **VAR**
* e2e test suite (Playwright / Cypress / Detox): **YOK**
* Screenshot / browser tool: **YOK**
* Device / simulator interactive session: **YOK**
* Firebase emulator (needs a JDK): **YOK on this machine** (`java` → "Unable to locate a Java Runtime")
* **Runtime validation method: `automated functional`** — `melos run format:check` / `analyze` / `test` (**268 workspace tests**, incl. real in-memory-Drift DB tests of the seed, migration guard, snapshot round-trip + corrupt recovery, session restore/replay, `sync_queue` state machine, exactly-once dedup, first-run-authoritative reconciliation, backoff, `awaitingAuth`, parked bounded-retry, fake producer), `melos run infra:build` / `infra:test` (TS build + 18 offline function tests), `flutter build ios --release --no-codesign` (Firebase pods) + source inspection.

**Not `source-only`** (real automated + DB-backed + build evidence was produced). **But not `runtime` / `repeatable integration` either** — `architecture.md → QA Focus` explicitly requires device/emulator runtime proof for resume + offline + sync, and Firebase-emulator integration proof for the callable + rules. Those two evidence classes **could not be produced in this environment** (no device, no JDK). See §17 and the Tech Lead Note — verdict is **Runtime Validation Pending**, not because of any code defect but because the contract-mandated runtime/integration evidence is missing from this pass.

---

## 0. Backend Build Gate

F08 touches the backend (`infra/functions` — the `submitDailyResultV1` callable + Firestore rules).

* Build command: `melos run build:app` (Android app bundle — CI-only locally, no Android SDK) · `melos run infra:build` (`npm ci && tsc` in `infra/functions`) · `flutter build ios --release --no-codesign`
* Build result: **PASS** — `melos run infra:build` SUCCESS (`tsc` clean); `flutter build ios --release --no-codesign` → `✓ Built build/ios/iphoneos/Runner.app (53.2MB)` (`pod install` pulled all 6 Firebase/`connectivity_plus` pods); `melos run analyze` SUCCESS (6 packages + `flutter analyze`); `melos run format:check` SUCCESS. Android `build:app` not run locally (no Android SDK) — CI covers it (unchanged posture).
* Test command: `melos run test` · `melos run infra:test`
* Test result: **PASS — 268 / 268 workspace** (looplet_app 72, looplet_engine 83, looplet_core 22, looplet_content 17, looplet_dictionary 32, looplet_solver 23, looplet_authoring 19) **+ infra 18 / 18 offline** (`test/skeleton.test.ts` — guard + full `validateSubmitDailyResult` matrix; 13 emulator-gated cases correctly skipped without `FIRESTORE_EMULATOR_HOST`).
* Boot verification: N/A (no server process; the callable runs on Firebase; the app "boots" via the widget test — see §3).
* **Gate decision: PASS → QA continues.** Compile + automated test + release build all green. The compile-vs-runtime split: **compile / automated PASS**; **device runtime + Firebase-emulator integration NOT executed** (environment) — carried as `Runtime Validation Pending`, reported separately from the (green) build gate.

---

## 1. Feature Summary

* **Feature:** F08 offline-persistence-and-sync — the on-device Drift/SQLite persistence layer (active-session snapshot, journey progress, personal bests, daily first-run + streak, settings, guest identity, forward-only migrations with a never-drop guard) + the deferred **exactly-once**, **first-run-authoritative** sync of offline daily results via the HTTPS callable `submitDailyResultV1` (create-only Firestore write) + the app-Firebase bootstrap (Firebase init, App Check monitor with a debug-provider fallback, Anonymous Auth) + the session-level `DailyResultSyncService`.
* **QA scope:** end-to-end (app persistence `frontend.md` + Firebase backend `backend.md`), automated-functional evidence. Verified against `prd.md` (AC1–AC12), the LOCKED `architecture.md`, `frontend.md` (Pass 1 + Pass 2), `backend.md`.

---

## 2. Test Scope

* **Scope Type:** End-to-End (client persistence + Firebase callable/rules) · **+ Security Compliance** (Anonymous Auth, cross-user Firestore resource, guest-data storage) · **+ Release / CI-CD Compliance** (`Release Scope = production-readiness`).
* **Documents reviewed:** `prd.md`, `architecture.md` (LOCKED, incl. the 2026-09-06 App Check provider-selection amendment), `orchestration.md`, `frontend.md`, `backend.md`, `role-execution-contract.md`, `system-state.md`, `platform.md` §4/§5/§6/§7/§8/§10/§11/§13, `release.md` §2/§4/§6.
* **Areas tested (automated / source):**
  * Drift schema + `onCreate` seed (one `player` v4 UUID + `settings`/`journey_progress`/`daily_streak` defaults + `store_meta` kv); table names match the contract; composite keys.
  * `MigrationGuard.guardPlayerData` — throws `MigrationDataLossError` when a protected table (`personal_best` / `daily_entry` / `daily_streak`) loses rows; passes on a no-op or a non-protected change.
  * `ActiveSessionSnapshot` — lossless JSON round-trip (frozen keys); 14 malformed-input rejections; `moveCount == appliedMoves.length`; token/coord validation.
  * `ActiveSessionRepo` — single-row `kv['active_session']` upsert; `read()` catches a corrupt row → `save_corrupt_recovered` log + `clear()` + `null` (durable tables untouched).
  * `restoreSession()` — rebuilds `GridEngine` via `toEngineConfig` + `restoreMoves(parseMoveList(...))`; re-derives `thawedCells` (not trusted from the snapshot cache); id-mismatch / non-applying move → `SessionRestoreException`.
  * `ElapsedTimer` — monotonic `Stopwatch` accumulator; `.resumed(ms)`; no wall clock.
  * Repositories — `PersonalBestRepo` monotone decrease + `isPerfect` + `firstCompletedAt` preservation; `DailyRepo` first-run immutability + `attemptNo`-incrementing `daily_attempt` + `setSyncStatus` mirror; `JourneyProgressRepo` CSV union + unlock; `DailyStreakRepo` store-only; `DailyPuzzleCache` put/get/`evictOlderThan`.
  * `SyncQueueRepo` — enqueue dedup on a non-parked idempotency key; `duePending` (due + keyed only); `reviveParkedForAppStart` bounded to 3 lifetime; stale-`inFlight` reclaim.
  * `DailyResultSyncService` — `enqueueFirstRun` (queue row + entry `queued`, same txn); `drain()` state machine: `CREATED`/`ALREADY_SUBMITTED` → `synced` + entry mirror; `retryable` → `pending` + `attemptCount++` + exp backoff; cap → `parked`; `nonRetryable` → `parked`; kill-switch off → no send; `awaitingAuth` keyless backfill once `firebaseUid` set; stale-`inFlight` reclaim → retry → `synced`. Exactly-once (repeat enqueue + double drain → one send / one row). First-run-authoritative (`ALREADY_SUBMITTED` → local `firstRun*` unchanged).
  * `FakeDailyResultProducer` — first → `firstRun` + one queue row; repeat → `replay`, no new row.
  * `callable_sync_sender.dart` — `mapCallableSuccess` (`CREATED`/`ALREADY_SUBMITTED`/unknown→retryable) + `mapCallableErrorCode` (`invalid-argument`→nonRetryable, else retryable).
  * `submitDailyResult.ts` (source) — auth guard pre-Firestore; soft App-Check log; full `platform.md` §8 validation matrix → `invalid-argument` + `details.code`; create-only Firestore **transaction** (exists → `ALREADY_SUBMITTED` same `recordedAt`; absent → `tx.create` → `CREATED`; race → re-read → `ALREADY_SUBMITTED`; else `internal`/no leak). `validateSubmitDailyResult` — 10 offline rejection tests.
  * `firestore.rules` (source) — `dailyResults/{bucket}/entries/{uid}` create-only own-uid, `update`/`delete`/`read` false, catch-all deny.
  * App bootstrap (`main.dart` + `bootstrap.dart`) — widget test: splash → home; migration failure → `_StoreErrorScreen` (Retry re-runs bootstrap); Firebase init is `unawaited` + self-catching; App Check provider selection (`kReleaseMode ? playIntegrity/appAttest : debug/debug`), `activate()` wrapped so a failure is a `debugPrint` no-op.
  * Session-level ownership (source) — `dailyResultSyncServiceProvider` referenced **only** by `bootstrap.dart` (app-scoped FutureProvider) + `main.dart`'s app-level `_SessionLifecycle` observer; **no screen widget references it**; `ref.onDispose(service.dispose)` fires at root-scope teardown only.
* **Areas NOT tested in this pass (→ Runtime Validation Pending, §17 + Tech Lead Note):**
  * **Real kill/relaunch resume fidelity on a device/simulator** (AC1/AC6). Automated `restoreSession` + snapshot round-trip is a strong proxy; a true OS-process-kill cycle was not run.
  * **Firebase emulator integration** — `test/rules.test.ts` (create-only allow/deny matrix) + `test/submitDailyResult.test.ts` (CREATED / ALREADY_SUBMITTED-doc-unchanged / one-doc-across-repeats / per-uid scoping / unauth-no-write / invalid-no-write) — **written + CI-wired** (`npx firebase-tools@15 emulators:exec ... --project demo-looplet`) but **not executed here** (no JDK).
  * **Offline Journey / offline pre-fetched Daily on a device** (AC2/AC3) — the persistence layer is unit-tested; there are no F03/F05 play/journey screens yet, so an end-user offline flow cannot be exercised until F03/F05.
  * **Real connectivity-regain → drain, `paused`/`resumed` lifecycle drain on a device** — source-reviewed only.
  * **Storage-full / disk-write-failure** (AC7) — no automated fault injection; the code path (`transaction` rollback + non-fatal event) is source-reviewed.
  * **Android release build** (`flutter build appbundle --release`) — CI-only locally (no Android SDK), unchanged posture.
* **Conditional sections excluded:** `iOS Platform Compliance` out of scope (no `game-dev.md`; Flutter stack; F08 ships no gameplay). `UI Design Compliance` / `UI Handoff Alignment` out of scope (no `ui-design.md`; the only F08-owned UI is the plain `_StoreErrorScreen` migration-error screen — explicitly "no design handoff" per `architecture.md`). `Game Client Quality` / `Game Visual & Feel` out of scope (not a game client).
* **Bugfix?** No — new feature.
* **Critical journeys:** (a) kill mid-puzzle → relaunch → exact resume; (b) full offline Journey; (c) offline daily completion → reconnect → **exactly one** server record, first run authoritative; (d) forward migration never drops bests/streak; (e) guest data structured for future account adoption.
* **Forbidden / misuse journeys:** unauthenticated `submitDailyResultV1` call → rejected, no write; a second daily completion → `daily_attempt` only, no new sync; a "better" replay syncing after a server record exists → server + local first-run both unchanged; another user's `entries/{uid}` → denied by rules; a corrupt `active_session` → recover to menu, don't crash, don't touch durable tables; a migration that would drop a protected row → aborted, no partial apply, no wipe.
* **Navigation/header consistency:** minimal — F08 adds no `go_router` routes (F03/F05/F09/F10). The bootstrap gate (`_SplashScreen` → `_HomePlaceholder` / `_StoreErrorScreen`) is a conditional root, not pushed routes; back affordance N/A.
* **Evidence class summary:** `automated functional` (present, strong) + `source-only` (for fault-injection / lifecycle / device paths). **No `runtime` or `repeatable integration` evidence this pass.**
* **Runtime validation method:** `automated functional`.
* **Release compliance:** in scope — see §6.7. `Security compliance` in scope — see §6.5.

---

## 3. Product Behavior Coverage

`prd.md` is Infrastructure; user stories are framed as guaranteed player value.

| System requirement (prd.md) | Test scenario | Evidence | Result |
| --- | --- | --- | --- |
| Persist the active puzzle state on every state change; resume exactly after background/kill/relaunch | `ActiveSessionSnapshot` round-trip + `ActiveSessionRepo.save/read`; `restoreSession()` rebuilds the engine + replays moves + re-derives thawed/solved | `active_session_snapshot_test.dart` (17), `session_restore_test.dart` (7); **kill/relaunch on a device: NOT run** | PARTIAL → Runtime Validation Pending |
| Persist journey progress / personal bests / daily first-run / streak / settings locally | Repository DB tests | `repositories_test.dart` (9), `app_database_test.dart` (6) | PASS |
| Play the entire Journey with no network | Journey content is local (F05/F06 artifacts); `journey_progress`/`personal_best` writes never await the network | source (`journey_progress_repo.dart`, `personal_best_repo.dart` — no network); **device offline flow: NOT run** (no F03/F05 screens yet) | PARTIAL → Runtime Validation Pending |
| Play a pre-fetched Daily offline; queue offline results for sync | `DailyPuzzleCache.get`; `DailyResultSyncService.enqueueFirstRun` (offline → `pending` / `awaitingAuth`) | `repositories_test.dart` (cache), `sync_test.dart` (enqueue) ; **device: NOT run** | PARTIAL → Runtime Validation Pending |
| Guest-only; structure data so a future account can adopt it without a destructive migration | every player-owned row carries a local-UUID `guestId`; no device-id keys; `firebaseUid` is a separate nullable column | `app_database_test.dart` (seed), `guest_id_test.dart` (10), source (schema) | PASS |
| Reconcile synced daily results using the first completed run as authoritative | local `daily_entry.firstRun*` immutable once set; server create-only; `ALREADY_SUBMITTED` = success | `sync_test.dart` (first-run-authoritative + exactly-once), `submitDailyResult.ts` source + `submitDailyResult.test.ts` (**emulator-gated, NOT run here**) | PARTIAL → Runtime Validation Pending (logic PASS; emulator integration pending) |

No system requirement is uncovered by *logic* evidence; the runtime/emulator layer is the gap.

---

## 4. Acceptance Criteria Traceability

| AC (prd.md) | Test / evidence | Result |
| --- | --- | --- |
| **AC1** kill + relaunch → grid, moveCount, undo history, thawed tiles, elapsed exactly restored | `session_restore_test.dart` (`restoreSession` → `moveCount`, `isSolved`, counters, `ElapsedTimer.resumed`); `active_session_snapshot_test.dart` round-trip; a tampered `thawedFrozenCells` is ignored (re-derived by replay). **Real OS-kill cycle: not run.** | PASS (logic) / Runtime Validation Pending (device) |
| **AC2** no network → all Journey levels load, progress saves | source: local writes, no network on the persist path. **Device offline: not run** (needs F03/F05). | Runtime Validation Pending |
| **AC3** pre-fetched daily + no network → playable | `DailyPuzzleCache.get`; "needs connection" is F07 UI. **Device: not run.** | Runtime Validation Pending |
| **AC4** offline daily completion → sent exactly once, no duplicate | `sync_test.dart` "exactly-once: a repeated enqueue + drain still sends once" (one send / one queue row) + idempotency-key dedup; server side: create-only transaction (`submitDailyResult.ts`) + `submitDailyResult.test.ts` "one-doc-across-repeats" (**emulator-gated, not run here**) | PASS (client logic) / Runtime Validation Pending (server emulator) |
| **AC5** server already has a first run → earlier run stays authoritative | `sync_test.dart` "ALREADY_SUBMITTED → synced, local firstRunMoveCount unchanged"; `submitDailyResult.ts` returns the existing `recordedAt` and never overwrites; `submitDailyResult.test.ts` "doc unchanged" (**emulator-gated**) | PASS (client) / Runtime Validation Pending (server emulator) |
| **AC6** `app_backgrounded` → state already durably written (no data-loss window) | write-through (every repo method commits before returning); `_SessionLifecycle` `paused` → `drain()` is a flush, not a first write | PASS (source + automated write-through tests) / Runtime Validation Pending (device lifecycle) |
| **AC7** storage-full / write-failure → non-destructive, last good state kept | source: Drift `transaction` rollback; no automated fault injection | Runtime Validation Pending (fault injection) |
| **AC8** corrupt save on launch → fall back to last checkpoint / clean state, no crash, log | `active_session_repo.dart` `read()` catch → `save_corrupt_recovered` log + `clear()` + `null`; `active_session_snapshot_test.dart` 14 rejection cases; the widget test's bootstrap path continues past a null snapshot | PASS |
| **AC9** schema upgrade → migrate forward, no personal best or streak lost | `app_database_test.dart` `MigrationGuard.guardPlayerData` — passes on a no-op; **throws `MigrationDataLossError`** on a `personal_best` / `daily_entry` row delete; `onUpgrade` wraps every step in the guard; a throwing step aborts without partial apply (Drift) | PASS |
| **AC10** device clock change mid-session → elapsed unaffected | `elapsed_timer_test.dart` — monotonic `Stopwatch`, `.resumed()`; guard: no wall clock. Timestamps use `DateTime.now().toUtc()` — accepted per `architecture.md → Streak/Clock` (no server clock trust in MVP). | PASS |
| **AC11** partial sync (network drop mid-request) → idempotent retry, no duplicate | `sync_test.dart` "retryable → pending + backoff + attemptCount bump", "stale inFlight is reclaimed and retried safely → synced"; idempotency key + server create-only guarantee no dup | PASS (client logic) / Runtime Validation Pending (real transport) |
| **AC12** every player-owned row carries a `guestId` for future account adoption | `app_database_test.dart` (seed), schema source (every player table has `guestId`; PKs never a device id); `player.firebaseUid` is a separate nullable column | PASS |

No AC is entirely uncovered; **AC1–AC7, AC11 have their runtime/emulator layer pending.**

---

## 5. Boundary Matrix

F08 has a rich state-machine / queue / retry / migration surface.

| Boundary | Result | Evidence |
| --- | --- | --- |
| snapshot: empty `appliedMoves` → engine at t=0 | PASS | `session_restore_test.dart` |
| snapshot: unsolved partial (`L0`) restores without winning | PASS | `session_restore_test.dart` |
| snapshot: winning move list (`R0`) restores solved | PASS | `session_restore_test.dart` |
| snapshot: a persisted move no longer applies (dict/config change) → `SessionRestoreException` (clean fallback) | PASS | `session_restore_test.dart` |
| snapshot: puzzle-id mismatch → `SessionRestoreException` | PASS | `session_restore_test.dart` |
| snapshot: 14 malformed-JSON classes → `SnapshotFormatException` | PASS | `active_session_snapshot_test.dart` |
| migration: no-op / non-protected change → OK; protected-row drop → `MigrationDataLossError` (rollback) | PASS | `app_database_test.dart` |
| migration: `schemaVersion` at 1, zero upgrade steps (v1→v2 placeholder) | PASS (framework in place; first real step is future) | source + `app_database_test.dart` |
| sync queue: enqueue dedup on a non-parked idempotency key | PASS | `sync_test.dart` |
| sync queue: `awaitingAuth` (null key) excluded from `duePending`; backfilled once `firebaseUid` set → sent once | PASS | `sync_test.dart` |
| sync queue: `retryable` → `pending` + `attemptCount++` + exp backoff (base 30s ×2 cap 6h ±jitter) | PASS | `sync_test.dart` |
| sync queue: attempt cap (10 / test 3) → `parked` + `daily_entry.syncStatus = parked` | PASS | `sync_test.dart` |
| sync queue: `nonRetryable` → `parked` immediately | PASS | `sync_test.dart` |
| sync queue: stale `inFlight` (> 20s) reclaimed → retried → `synced` | PASS | `sync_test.dart` |
| sync queue: bounded parked auto-retry — once/app-start, max 3 lifetime, then dormant | PASS | `sync_test.dart` |
| sync queue: kill-switch `daily_sync_enabled == false` → `drain()` no-op | PASS | `sync_test.dart` |
| reconciliation: exactly-once (repeat enqueue + double drain) → one send / one row | PASS (client) | `sync_test.dart` |
| reconciliation: server exists → `ALREADY_SUBMITTED`, local `firstRun*` untouched | PASS (client) / server emulator PENDING | `sync_test.dart` (client); `submitDailyResult.test.ts` (emulator, not run) |
| daily: 1st completion → first-run + queue item; 2nd/3rd → `daily_attempt` rows (attemptNo 2, 3), no new queue item | PASS | `repositories_test.dart`, `sync_test.dart` |
| callable mapping: `CREATED`/`ALREADY_SUBMITTED`/unknown; `invalid-argument`/other codes | PASS | `callable_sync_sender_test.dart` (11) |
| server create-race: two concurrent first writes → winner `CREATED`, loser re-reads → `ALREADY_SUBMITTED` | PENDING (emulator) | `submitDailyResult.ts` source (transaction + catch → re-read); not emulator-verified here |

---

## 6. Contract Compliance Check

Reference: `architecture.md` [LOCKED] (incl. the 2026-09-06 App Check amendment).

| Contract area | Result | Evidence |
| --- | --- | --- |
| Persistence in `app/` (Drift); domain packages Firebase-free | **Preserved** | `melos run analyze` clean; `app/lib/persistence/*` uses `drift` only; `looplet_*` packages untouched (their 196 tests unchanged). |
| Drift schema — exact contract table names + keys + `kv` snapshot | **Preserved** | `app_database.dart` (`tableName` overrides: `player`/`settings`/`journey_progress`/`personal_best`/`daily_entry`/`daily_attempt`/`daily_streak`/`daily_puzzle_cache`/`sync_queue`/`kv`); composite PKs; `app_database_test.dart`. |
| Forward-only migrations; never-drop `personal_best`/`daily_entry`/`daily_streak`; store downgrade unsupported | **Preserved** | `MigrationGuard` + test proving the throw; `onUpgrade` wraps every step; documented. |
| Active-session snapshot — frozen JSON keys; `appliedMoves` IS the undo history; `thawedFrozenCells` re-derived on restore | **Preserved** | `active_session_snapshot.dart` key set matches verbatim; `session_restore.dart` re-derives `thawedCells` via engine replay (tampered-cache test). |
| Write-through; single transactional `kv` row for the session | **Preserved** | `ActiveSessionRepo.save` = one `insertOnConflictUpdate`; multi-step repo ops use `transaction()`. |
| Guest identity — `guestId` local UUID v4 on every player row; `firebaseUid` nullable/server | **Preserved** | `guest_id.dart` (RFC-4122 v4), schema, seed test; `PlayerRepo.setFirebaseUid`. |
| `sync_queue` contract — states, `{firebaseUid}\|{lang}\|{dailyDate}` key, ack-only `synced`, backoff (30s ×2 cap 6h ±20%), cap 10 → `parked`, stale-`inFlight` sweep, `awaitingAuth`, bounded parked retry | **Preserved** | `sync_queue_repo.dart` + `daily_result_sync_service.dart`; `sync_test.dart` (14). |
| Reconciliation — local first-run immutable; server create-only; `ALREADY_SUBMITTED` = success; no read-back/merge | **Preserved** | `DailyRepo` (first-run immutable + attempts); `submitDailyResult.ts` transaction; `sync_test.dart` + (emulator, pending) `submitDailyResult.test.ts`. |
| `daily_entry.syncStatus` mirrors the queue state in the same transaction | **Preserved** | `daily_result_sync_service.dart` `_process`/`_park`/`enqueueFirstRun` all wrap the mirror in `db.transaction`. |
| Session-level ownership — `DailyResultSyncService` never screen-owned | **Preserved** | Source: referenced only by `bootstrap.dart` (app-scoped) + `main.dart` `_SessionLifecycle`; `ref.onDispose` at root teardown only; no screen imports it. |
| Callable `submitDailyResultV1` — 2nd-gen `onCall`, `enforceAppCheck: false`, request/response/error shape, `platform.md` §8 validation ranges | **Preserved** | `infra/functions/src/{index,submitDailyResult,validate,types}.ts`; `skeleton.test.ts` (18 offline incl. the validation matrix). |
| Firestore create-only rules (`dailyResults/{bucket}/entries/{uid}`: create-own only; no update/delete/read) | **Preserved (source)** — emulator run PENDING | `infra/firestore.rules`; `rules.test.ts` written + CI-wired, **not run here**. |
| App Check — soft-enforce (monitor); debug provider in dev, Play Integrity/App Attest in release; `activate()` failure = logged no-op; hard-enforce never enabled | **Preserved** | `bootstrap.dart` `_bootstrapFirebase` — `kReleaseMode ? playIntegrity/appAttest : debug/debug`, wrapped in try/catch → `debugPrint`. Matches the 2026-09-06 amendment. |
| App Init Sequence order (DB → migrate → snapshot → async best-effort Firebase → sync service → app tree); Firebase steps never fatal | **Preserved** | `appBootstrapProvider` + `_bootstrapFirebase` (no `throw`/`rethrow`; only returns `AppBootstrapMigrationError` on the local-DB failure). Widget test: splash → home. |
| `Puzzle → EngineConfig` in a consumer, not `looplet_content` | **Preserved** | `app/lib/content/puzzle_engine_config.dart`. |
| No F02 change | **Preserved** | `restoreMoves` pre-existed + tested; 83 engine tests unchanged. |
| Contract version | v1; the App Check amendment is additive (provider selection + a deferred `[OPEN — post-MVP]`), no behavior change to the sync/persistence contract. |

**No contract violation found.**

---

## 6.5 Security Compliance Check

Security scope = **YES** (Anonymous Auth identity; cross-user Firestore resource `dailyResults/**`; guest-data storage).

| Control | Result | Evidence / Notes |
| --- | --- | --- |
| IDOR — ownership-check layer | **PASS** | `submitDailyResultV1` takes `uid` from `context.auth.uid` **only**, never the body; the Firestore path is `entries/{uid}`; `firestore.rules` `allow create: if request.auth != null && request.auth.uid == uid`, `update/delete/read: false`, catch-all deny. Two layers (server-code path derivation + rules). `rules.test.ts` (deny-create-other / deny-read) is CI-wired — **not run here** (emulator/JDK) → the deny paths are `Runtime Validation Pending` for integration proof, source is clean. |
| Injection surface — parametrized / ORM | **PASS** | All DB access via Drift's query builder (parametrized). The only raw SQL is `MigrationGuard._counts` → `customSelect('SELECT COUNT(*) AS c FROM $table')` where `$table` ∈ a **const hardcoded** `protectedTables` list, never user input. No `dart:io` shell. |
| Response data exposure | **PASS** | Callable returns only `{status, recordedAt}`. Errors are generic (`internal` → "Could not record the result."; `invalid-argument` → a field message + `details.code`). No PII, hash, token, or internal id. `logger.error` writes context server-side only. |
| Mass assignment / overposting | **PASS** | `validateSubmitDailyResult` builds an explicit typed object from named fields; unknown body fields are ignored; the `DailyResultDoc` is constructed field-by-field with the server-set `uid` + `recordedAtUtcMs`. A client cannot set `uid` or `recordedAt`. |
| Rate limiting / abuse path | **PASS (documented MVP posture)** | No custom rate limiter — accepted per `platform.md` §6/§8 (App Check + create-only rule are the only controls; App Check soft-enforce for the MVP). Create-only means a client can write **one** doc per `(uid, lang, date)`; a flood of repeats is idempotent no-ops. Not a finding — it is the locked MVP decision. |
| Auth bypass — middleware/guard | **PASS** | The callable checks `request.auth?.uid` **before any Firestore access**; rules enforce server-side independently. App Check monitor mode is the deliberate MVP posture (`platform.md` §13). Anonymous UID is never trusted from the client. |

No security FAIL. The rules deny-matrix wants an emulator run for integration proof (CI-wired; pending here).

---

## 6.7 Release / CI-CD Compliance Check

`Release Scope = production-readiness`. `release.md` §2 marks F08 as the first Firebase-infra release gate; `F08-DEVOPS` is scheduled **after QA** (state machine DURUM 5 → In Release) — a separate `release.md` (feature-level) does not exist yet, which is correct at this stage.

| Control | Result | Evidence / Notes |
| --- | --- | --- |
| Release authority defined | **PASS** | `release.md` §2 (F08 backend-only Firebase gate), §4 (CI gate list incl. `infra/functions` build+test + rules tests), §6 (`firebase deploy --only functions,firestore:rules`, kill-switches `daily_enabled`/`daily_sync_enabled`/`share_enabled`, forward-only Drift, never-drop). |
| Orchestration `Release Scope` set | **PASS** | `production-readiness`; `F08-DEVOPS` task defined in the ledger, opens post-QA. |
| CI gates applicable to F08 proven | **PASS (local) / PARTIAL (emulator)** | `melos run format:check`/`analyze`/`test` + `melos run infra:build`/`infra:test` green locally. The CI `infra` job adds `npx firebase-tools emulators:exec` for the rules + callable suites — **wired, not executed here** (no JDK). CI runs it. |
| Container build/run/smoke | **N/A** | `release.md` §6: containerization not applicable (mobile + Firebase CLI). |
| Deploy preview / staging / runtime validation | **PENDING → `F08-DEVOPS`** | No `firebase deploy` dry-run, no post-deploy smoke, no prod-project confirmation this pass — all correctly belong to `F08-DEVOPS`. |
| Rollback / forward-fix strategy | **PASS (documented)** | `release.md` §9 + `architecture.md`: functions redeploy-previous; `daily_sync_enabled` kill-switch; Drift forward-only (no downgrade) → mitigation = migration tests (present) + staged rollout + never-drop guard (present). `F08-DEVOPS` produces the runbook. |
| Secrets / env documented (names only) | **PASS** | `release.md` §7: `FIREBASE_CI_TOKEN` (name only; **not yet configured** — deferred to `F08-DEVOPS` per the user). Firebase client config files are not secret and are committed. |
| Health / observability | **PARTIAL** | `release.md` §8 smoke test includes "submit a daily result and confirm the Firestore create-only write" + "background+relaunch and confirm exact resume" — those are the `F08-DEVOPS` + on-device QA items. Crashlytics/Cloud Logging wiring is F12/DevOps. |

Release-readiness is **not claimed** by this QA — it is correctly a post-QA `F08-DEVOPS` gate. No workflow/release blocker; the pending items are the DevOps scope, listed in the Tech Lead Note.

---

## 9. Positive Scenarios

**Journey 1 — kill mid-puzzle, relaunch, resume (AC1):**
Start: a player is mid-puzzle (`journey-tr-1`), 1 move applied (`R0` = solved), 2 undos left, 1 restart, ~41s elapsed. Action: OS kills the app; the player relaunches. Expected visible result: the exact grid, `moveCount 1`, `undosRemaining 2`, `restartCount 1`, elapsed continuing from ~41s, and the solved/thawed state — **re-derived by replaying the applied-move list through the engine**, not read from a possibly-stale cache. Evidence: `session_restore_test.dart` (`restoreSession` → engine `moveCount`/`isSolved` + `ElapsedTimer.resumed(41200)`) + `active_session_snapshot_test.dart` round-trip. *(Real OS-kill cycle: Runtime Validation Pending.)*

**Journey 2 — offline daily, reconnect, exactly once (AC4/AC5/AC11):**
Start: airplane mode; the player finishes the daily. Result: `daily_entry` first-run written (immutable), `syncStatus = queued`, one `sync_queue` row (`pending`, or `awaitingAuth` if Anonymous Auth hasn't completed). Action: connectivity returns. Visible result: **exactly one** Firestore doc at `dailyResults/tr_<date>/entries/<uid>` (create-only transaction), `syncStatus = synced`; a forced mid-request drop → the item goes back to `pending` with backoff and is retried; a kill during `inFlight` → the item is reclaimed on next launch and still results in one doc. A later "better" replay: `daily_attempt` row only, **no** new sync, server + local first-run unchanged. Evidence: `sync_test.dart` (exactly-once, first-run-authoritative, stale-reclaim, awaitingAuth) + `submitDailyResult.ts` source. *(Server emulator run: Runtime Validation Pending.)*

**Journey 3 — app update with a schema migration (AC9):**
Start: a returning player after an app update that bumps `schemaVersion`. Action: launch. Visible result: the store migrates forward inside `onUpgrade`; **every** `personal_best` / `daily_streak` / `daily_entry` row survives (the `MigrationGuard` throws `MigrationDataLossError` and rolls the whole migration back if any would be dropped); no "reset" is ever shown. Evidence: `app_database_test.dart` (guard passes on safe steps, throws on a protected delete).

**Journey 4 — corrupt save on launch (AC8):**
Start: `kv['active_session']` is truncated/garbled. Action: launch. Visible result: the corrupt snapshot is discarded (a `save_corrupt_recovered` diagnostic is logged), the **durable tables are untouched**, and the app lands on the home shell — no crash, no data loss beyond the in-progress puzzle. Evidence: `active_session_repo.dart` `read()` catch path + `active_session_snapshot_test.dart` (14 rejection classes) + the widget test continuing past a null snapshot.

---

## 10. Negative / Edge Cases

| Case | Expected | Observed | Evidence |
| --- | --- | --- | --- |
| Unauthenticated `submitDailyResultV1` call | `HttpsError("unauthenticated")` **before** any Firestore access; no doc | as expected (source + `submitDailyResult.test.ts` emulator-gated) | `submitDailyResult.ts`; `skeleton.test.ts` |
| Invalid payload (`lang: "de"` / `stars: 9` / `moves < optimalMoves` / bad date / …) | `HttpsError("invalid-argument", …, {code})`; no doc | as expected — 10 offline rejection tests + a handler test | `skeleton.test.ts`, `submitDailyResult.ts` |
| Another user's `entries/{uid}` (create/read/update/delete) | denied by rules | as expected (source); emulator matrix CI-wired, not run here | `firestore.rules`, `rules.test.ts` (pending) |
| Second daily completion (any result) | `daily_attempt` row only; first-run + sync untouched | as expected | `repositories_test.dart`, `sync_test.dart` |
| "Better" replay syncs after a server record exists | `ALREADY_SUBMITTED`; server + local first-run unchanged | as expected (client); server side pending | `sync_test.dart`; `submitDailyResult.test.ts` (pending) |
| Migration step that throws | abort without partial apply; keep old DB; no wipe | as expected — Drift default + `_StoreErrorScreen` on the local-DB failure path | `bootstrap.dart`, source |
| Migration that would drop a protected row | `MigrationDataLossError` → rollback | as expected | `app_database_test.dart` |
| Corrupt `active_session` JSON (14 classes) | `SnapshotFormatException` → discard active only → recover | as expected | `active_session_snapshot_test.dart` |
| Persisted move no longer applies (dict/config drift) on restore | `SessionRestoreException` → caller falls back to a clean start | as expected | `session_restore_test.dart` |
| Firebase init / App Check activate / anon sign-in fails (offline, no attestation, etc.) | logged `debugPrint`, **never** blocks the app; sync items wait in `awaitingAuth` | as expected — `_bootstrapFirebase` has no `throw`/`rethrow`; widget test boots with no platform Firebase | `bootstrap.dart`, `widget_test.dart` |
| `daily_sync_enabled == false` | `drain()` no-op | as expected | `sync_test.dart` |
| Device clock moved backward/forward mid-session | elapsed unaffected (monotonic) | as expected | `elapsed_timer_test.dart` |
| Storage full / disk write failure | non-destructive, keep last good | source-reviewed (transaction rollback); **no automated fault injection** | source |
| Screen disposed mid-sync | sync completes (app-scoped service) | source-verified (no screen owns the provider) | grep: only `bootstrap.dart` + `main.dart` reference it |

No misuse path produced a crash, a data-loss, a wrong `Optimal`/duplicate, or an unauthorized write in the automated + source evidence.

---

## 14. Frontend Quality

Client-touching scope (Drift persistence + bootstrap + the migration-error screen).

* **Code quality:** `melos run analyze` clean (6 packages + `flutter analyze`); `format:check` clean. No stubs/TODOs on the F08 surface (the `dailySyncEnabledProvider` kill-switch is a documented `() async => true` seam for F07's Remote Config read — an intentional boundary, not a stub). `app_database.g.dart` committed (CI runs no `build_runner`).
* **Architecture:** clean layering — pure snapshot/elapsed/guest models, write-through repos, an injectable-everything `DailyResultSyncService` (sender + clock + connectivity + kill-switch all injectable → fully unit-testable), an app-scoped provider graph, a fire-and-forget Firebase bootstrap that never blocks the first frame or crashes on failure.
* **Resilience:** corrupt snapshot self-heals; migration failure is recoverable (Retry re-runs bootstrap); every Firebase step is best-effort; the sync queue tolerates no-auth (`awaitingAuth`), transport errors (`retryable` + backoff), and a stuck `inFlight` (stale sweep).
* **Determinism:** the sync service is deterministic under an injected clock + `Random(0)` jitter (verified across the `sync_test.dart` matrix).
* **The one F08-owned UI** (`_StoreErrorScreen`) is plain by design (`architecture.md`: "no design handoff") — a centered message ("Your progress is safe"), a `FilledButton` Retry, and the raw error in muted small text. Adequate for a rare recoverable failure; not a premium-UI surface.
* Runtime evidence summary: `automated functional` — 268 workspace tests + 18 infra offline tests + iOS release build, all green. **No device/emulator runtime evidence** (see §17).

---

## 16. Regression Risk

* **Shared components touched:** `app/lib/main.dart` (rewritten — `LoopletApp` now `ConsumerWidget` gating on `appBootstrapProvider`; the old unconditional placeholder is gone). `app/lib/persistence/**` (new). `app/lib/bootstrap.dart`, `content/puzzle_engine_config.dart`, `engine/move_shorthand.dart` (new). `app/pubspec.yaml` + `app/ios/Podfile.lock` + Android Gradle (Firebase plugins — from `flutterfire configure`). `infra/**` (F08.SETUP-0 + BE2–BE5). `.github/workflows/ci.yml` (`infra` job). No change to `looplet_*` packages.
* **Downstream dependents:** F03 (will consume `ActiveSessionRepo` + the frozen snapshot contract), F04 (`PersonalBestRepo`), F05 (`JourneyProgressRepo` + `toEngineConfig`), F07 (`DailyRepo` / `DailyPuzzleCache` / `DailyResultSyncService.enqueueFirstRun` + the real Remote Config kill-switch, replacing `FakeDailyResultProducer`), F10 (`SettingsRepo` + streak/progress read models), F12 (its own analytics buffer, same pattern). None exist yet — this is the contract they will build against.
* **Existing behavior:** the 4 pre-existing app tests (`dictionary_wiring`, `engine_wiring`, and the rewritten `widget_test`) pass; the 196 pure-package tests are unchanged. `looplet_engine` untouched (`restoreMoves` pre-existed). The app still "boots to `LOOPLET`" — now behind a fast local-only bootstrap gate.
* **Risk:** the `main.dart` rewrite is the notable change — it moves the first screen behind `appBootstrapProvider`. The widget test covers splash → home and the migration-error branch is source-clear; the bootstrap does only fast local work before the first frame (Firebase is `unawaited`). Low regression risk; **the untested surface is device/OS-level (kill/relaunch, real lifecycle, real Firebase), not the Dart logic.**

---

## 17. Final Verdict

**Runtime Validation Pending**

* **No blocking code issue. No required fix.** Every piece of automated + source evidence is green: 268 workspace tests + 18 infra offline tests + `analyze` + `format:check` + `melos infra:build`/`infra:test` + `flutter build ios --release --no-codesign` (with the Firebase pods). The full [LOCKED] contract — Drift schema, never-drop migration guard, frozen snapshot keys + re-derived thaw on restore, `sync_queue` state machine + exactly-once + first-run-authoritative + session-level ownership + kill-switch, the `submitDailyResultV1` request/response/error shape + `platform.md` §8 validation + create-only transaction, the create-only Firestore rules, and the amended App Check provider selection — is honored. Security checks all PASS.
* **Why not `Approved` / `Approved with Notes`:** `architecture.md → QA Focus` **explicitly requires `runtime` (device/emulator) proof for resume + offline + sync and `repeatable integration` (Firebase emulator) proof for the callable + rules**, and states "**Not `source-only`**". This QA pass could produce neither class — **no device/simulator** and **no JDK** (so the Firebase emulator, and therefore `test/rules.test.ts` + `test/submitDailyResult.test.ts`, could not run here). Per the QA fail-fast + runtime-verdict rules, a feature with this runtime-risk surface (kill/relaunch resume, real exactly-once sync, session-level lifecycle) cannot be `Approved` on `automated functional` evidence alone. The automated tests are a strong logic proxy, not a substitute for the contract-mandated classes.
* **This is an environment gap, not an implementation defect.** The emulator suites are written and CI-wired; a machine with a JDK (or CI) runs them. The device scenarios need a simulator pass (and, for the true end-user offline Journey/Daily flows, F03/F05 screens, which don't exist yet).

Pending-validation scenarios → the Tech Lead Note.

---

# WORKFLOW VERDICT SUGGESTION (NON-AUTHORITATIVE)

## QA Result

* **Runtime Validation Pending** — implementation contract-compliant and green on all available automated + build evidence; the contract-mandated `runtime` (device/simulator) and `repeatable integration` (Firebase emulator) evidence could not be produced in this environment.

## Affected Areas

* None requiring code rework. The gap is **validation-method** (runtime + emulator), not correctness.

## Blocking Issues

* None (no code defect).

## Pending Validation Scenarios

1. **Firebase emulator suites** — run `cd infra && firebase emulators:exec --only firestore,auth --project demo-looplet "npm --prefix functions run test"` on a machine with a JDK (or confirm the CI `infra` emulator job is green on the branch): `test/rules.test.ts` (create-own allow / create-other deny / unauth deny / update deny / delete deny / read deny) + `test/submitDailyResult.test.ts` (CREATED; ALREADY_SUBMITTED with the doc unchanged; one doc across repeats; per-uid scoping; unauth → no write; invalid → no write).
2. **Kill / relaunch resume fidelity on a simulator/device** (AC1/AC6) — start a puzzle, N moves + undo(s) + a restart + a thawed frozen tile, kill the OS process, relaunch → exact restore; tamper `kv['active_session'].thawedFrozenCells` and confirm it is re-derived, not trusted.
3. **App lifecycle + connectivity on a device** — `paused`/`resumed` → `drain()`; connectivity regain → `drain()`; the `DailyResultSyncService` survives a screen dispose mid-sync.
4. **Offline Journey / offline pre-fetched Daily on a device** (AC2/AC3) — needs F03/F05 play screens; can be folded into F05/F07 QA or a later F08 on-device smoke.
5. **Storage-full / disk-write-failure fault injection** (AC7) — non-destructive, last-good-state kept.
6. **Post-deploy smoke** (`release.md` §8) — belongs to `F08-DEVOPS`: submit a daily result against the real project and confirm the create-only write + a background+relaunch resume on a build.

## Suggested Fix Order

Not a rework. The Tech Lead coordinates the pending validation:
1. Confirm the CI `infra` emulator job is green on the F08 branch (or run it with a JDK) → closes scenario 1.
2. A simulator pass for scenarios 2–3 (Tech Lead / user, or fold into `F08-DEVOPS` on-device smoke).
3. Route to `F08-DEVOPS` (`production-readiness`) — its smoke test (`release.md` §8) naturally covers scenarios 1, 2, and 6.
4. Scenario 4 → tracked for F05/F07 QA (no F08 code change).
5. Re-run QA (or accept the DevOps smoke as the runtime closure, Tech Lead's call).

---

## 19. Sonraki Komut

```
Run Tech Lead
```

---

## 20. Tech Lead Note

<<<TEXT

F08 offline-persistence-and-sync — QA verdict: **Runtime Validation Pending**. No blocking code issue, no required fix. All automated + build evidence green (268 workspace + 18 infra-offline tests, analyze, format:check, infra:build/infra:test, `flutter build ios --release --no-codesign` with the Firebase pods). Full [LOCKED] contract honored (schema, never-drop guard, frozen snapshot + re-derived thaw, sync_queue state machine + exactly-once + first-run-authoritative + session-level ownership + kill-switch, callable request/response/error + §8 validation + create-only transaction, create-only rules, amended App Check provider selection). Security checks all PASS.

The verdict is Runtime Validation Pending — NOT Approved — because `architecture.md → QA Focus` explicitly mandates `runtime` (device/emulator) + `repeatable integration` (Firebase emulator) evidence and this environment has neither a device/simulator nor a JDK (so `test/rules.test.ts` + `test/submitDailyResult.test.ts` could not run). This is an environment/tooling gap, not an implementation defect.

Tech Lead actions:
1. Close the runtime gap via ONE of:
   a. Confirm the CI `infra` emulator job (`npx firebase-tools emulators:exec --project demo-looplet`) is green on the F08 branch — closes the rules + callable integration scenarios; AND
   b. A simulator pass for kill/relaunch resume + lifecycle + connectivity (scenarios 2–3 in "Pending Validation Scenarios") — or fold it into `F08-DEVOPS`'s on-device smoke (`release.md` §8 already lists "submit a daily result + confirm the create-only write" and "background+relaunch + confirm exact resume").
2. Given (1), the cleanest route is: `Run DevOps/Release Engineer` (F08-DEVOPS, `production-readiness`) — its smoke test covers the pending runtime + emulator + deploy scenarios in one pass; then reconcile F08 → Done. If you prefer a QA re-run after the emulator/simulator evidence exists, route back to `Run QA` first.
3. `FIREBASE_CI_TOKEN` is documented (`release.md` §7) but not configured — deferred to `F08-DEVOPS` per the user. Android release Play Integrity SHA-256 → `F08-DEVOPS`. iOS production App Attest/DeviceCheck → `[OPEN — post-MVP, after Apple Developer Program enrollment]` in `architecture.md` — non-blocking (App Check is monitor-only).
4. Sync `feature-board.md` + `system-state.md` (F08 stays `In Progress` — implementation complete, runtime validation pending; Active Owner → whichever role you route to).
5. Non-code follow-ons already tracked (not QA blockers): move-shorthand ~40-line dup vs `tools/looplet_authoring`; `dailySyncEnabledProvider` is a seam awaiting F07's Remote Config read; offline Journey/Daily end-user flows need F03/F05 screens.

No Product/PO escalation required.

TEXT
