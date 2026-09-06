# F08 — offline-persistence-and-sync: Frontend Delivery (Track A + FE7/FE10; then the FE6/FE8/FE9 join)

Role: Frontend/Mobile Developer · Date: 2026-09-06
Pass 1 (Track A): **F08-FE1, FE2, FE3, FE4, FE5, FE11** + the parallel-allowed **FE7** (`DailyResultSyncService`) and **FE10** (fake producer). No Firebase.
Pass 2 (the app-Firebase join, after `F08.FIREBASE-PROJECT` + Track B): **F08-FE6** (app-init sequence + App Check provider selection), **F08-FE8** (real callable `SyncSender`), **F08-FE9** (session-level singleton + connectivity + build check). See the **"Pass 2"** section below.

---

## 1. Feature Summary

The on-device persistence core for F08: a Drift/SQLite `AppDatabase` with the full contract schema, forward-only migrations with a never-drop guard on player data, write-through repositories for every §15 aggregate, the frozen active-session snapshot model + a corrupt-safe read path, a monotonic elapsed-time helper, the `Puzzle → EngineConfig` consumer helper, and the session-restore path that rebuilds a `GridEngine` from a snapshot. Plus the session-level `DailyResultSyncService` (queue state machine + backoff + parked bounded-retry + exactly-once + first-run-authoritative reconciliation) driven by an injectable sender, and a debug-only fake daily-result producer so the sync path is exercised end-to-end without F07.

---

## 2. Impacted Files

**Created — `app/lib/`:**

* `persistence/app_database.dart` — Drift tables (10) + `AppDatabase` + `schemaVersion = 1` + `MigrationStrategy` (onCreate seed + guarded onUpgrade framework) + `DailySyncStatus` / `SyncQueueState` / `SyncQueueKind` enums.
* `persistence/app_database.g.dart` — drift codegen output (committed; CI has no `build_runner` step).
* `persistence/migration_guard.dart` — `MigrationGuard.guardPlayerData` + `MigrationDataLossError`.
* `persistence/guest_id.dart` — `newGuestId()` (RFC-4122 v4 via `Random.secure()`) + `isGuestId()`.
* `persistence/elapsed_timer.dart` — `ElapsedTimer` monotonic accumulator (+ `.resumed()`).
* `persistence/active_session_snapshot.dart` — `ActiveSessionSnapshot` (frozen JSON keys) + `PuzzleSource` / `ActiveSessionStatus` enums + `SnapshotFormatException`.
* `persistence/session_restore.dart` — `restoreSession(snapshot, puzzle, validator) → RestoredSession` + `SessionRestoreException`.
* `persistence/daily_result_sync_service.dart` — `DailyResultSyncService`, `DailyResultPayload`, `SyncSendResult`, `SyncSender`.
* `persistence/fake_daily_result_producer.dart` — `FakeDailyResultProducer` (debug/test seam).
* `persistence/persistence_providers.dart` — Riverpod providers for the DB + every repo + `currentGuestIdProvider`.
* `persistence/repositories/{player,settings,journey_progress,personal_best,daily,daily_streak,active_session}_repo.dart`, `repositories/daily_puzzle_cache.dart`, `repositories/sync_queue_repo.dart`.
* `content/puzzle_engine_config.dart` — `toEngineConfig(Puzzle) → EngineConfig`.
* `engine/move_shorthand.dart` — `parseMove` / `parseMoveList` / `formatMove` / `formatMoveList` + `MoveShorthandException`.

**Created — `app/test/persistence/`:** `guest_id_test.dart`, `elapsed_timer_test.dart`, `active_session_snapshot_test.dart`, `app_database_test.dart`, `repositories_test.dart`, `sync_test.dart`, `session_restore_test.dart` (**63 tests**).

**Not modified:** `app/lib/main.dart` (init sequence is FE6), `app/pubspec.yaml` (Firebase deps + `connectivity_plus` already added in F08.SETUP-0), `packages/looplet_engine/**` (see §4 — `restoreMoves` was already present).

---

## 3. Task-to-Code Traceability

| Task | Status | Files | Behavior |
| --- | --- | --- | --- |
| **F08-FE1** Drift schema | Complete | `persistence/app_database.dart` (+ `.g.dart`) | All 10 contract tables with the **exact contract table names** (`player`, `settings`, `journey_progress`, `personal_best`, `daily_entry`, `daily_attempt`, `daily_streak`, `daily_puzzle_cache`, `sync_queue`, `kv`). Composite PKs for `personal_best` / `daily_entry` / `daily_attempt` / `daily_puzzle_cache`. `syncStatus` + `state` are `textEnum` columns. `schemaVersion = 1`. `_seedDefaults()` (onCreate) inserts one `player` (fresh v4 `guestId`, null `firebaseUid`), plus `settings` / `journey_progress` / `daily_streak` defaults + a `store_meta` `kv` row, all in one transaction. `AppDatabase.forTesting(NativeDatabase.memory())` for tests. |
| **F08-FE2** Migrations + never-drop guard | Complete | `persistence/migration_guard.dart`, `app_database.dart` (`migration`) | `MigrationGuard.guardPlayerData(db, migration)` snapshots the row counts of `personal_best` / `daily_entry` / `daily_streak`, runs the migration closure, and throws `MigrationDataLossError` (propagating out of `onUpgrade` → rollback) if any shrank. `onUpgrade` is a `for v in from..to` step switch wrapped by the guard — **zero steps at v1**; a `// case 1:` placeholder marks where v1→v2 goes. Store downgrade is documented as unsupported. Migration-throw ⇒ abort-without-partial-apply (Drift default) — no silent wipe. |
| **F08-FE3** Repositories | Complete | `persistence/repositories/*.dart` | `PlayerRepo` (single row; `currentGuestId`, `currentFirebaseUid`, `setFirebaseUid`). `SettingsRepo` (read/watch + 3 setters). `JourneyProgressRepo` (`markCompleted` — CSV union + `highestUnlockedLevel = max(current, level+1)`, transactional, idempotent). `PersonalBestRepo` (`recordCompletion` — writes only if strictly better or first; `isPerfect = moves == optimal`; `firstCompletedAtUtcMs` preserved; returns whether it became the best). `DailyRepo` (`recordCompletion` — first call writes the immutable first-run + `syncStatus = local`; subsequent calls append `daily_attempt` rows with an incrementing `attemptNo` starting at 2; returns `DailyCompletionOutcome.firstRun|replay`; `setSyncStatus` mirror). `DailyStreakRepo` (store-only `read/watch/write`). `DailyPuzzleCache` (`put`/`get`/`evictOlderThan` — `YYYY-MM-DD` lexical compare). All write-through; multi-step ops in `transaction()`. |
| **F08-FE4** Active-session snapshot + restore | Complete | `persistence/active_session_snapshot.dart`, `persistence/session_restore.dart`, `repositories/active_session_repo.dart` | `ActiveSessionSnapshot` fields + `toJson`/`fromJson` use the **frozen key set** from the contract; `fromJson` validates snapshotVersion, non-empty puzzleId, supported lang, `moveCount == appliedMoves.length`, every `appliedMoves` token parses, `undosRemaining ∈ 0..3`, non-negative `restartCount`/`elapsed`, positive timestamps, `^\d+,\d+$` thawed coords — any violation → `SnapshotFormatException`. `ActiveSessionRepo` stores it as `kv['active_session']` (one `insertOnConflictUpdate`); `read()` catches decode/format errors, logs `save_corrupt_recovered`, calls `clear()`, returns null (durable tables untouched). `restoreSession()` → `toEngineConfig` → `GridEngine` → `engine.restoreMoves(parseMoveList(appliedMoves))` → `RestoredSession` (engine + counters + `ElapsedTimer.resumed`); a puzzle-id mismatch or a move that no longer applies → `SessionRestoreException` (caller falls back to a clean start). `thawedFrozenCells` is treated as a cache — authority is the engine's re-derived `thawedCells`. |
| **F08-FE5** Monotonic elapsed helper | Complete | `persistence/elapsed_timer.dart` | `ElapsedTimer` wraps a `Stopwatch`; `start`/`pause` fold into `_accumulatedMs`; `elapsedMs` = accumulated + current run; `.resumed(accumulatedMs)` restores a persisted total (paused). No `DateTime.now()` for elapsed. Negative accumulated → assert. |
| **F08-FE11** `toEngineConfig` | Complete | `content/puzzle_engine_config.dart` | Free function `toEngineConfig(Puzzle) → EngineConfig` (splits row strings to `List<List<String>>`, passes locked/frozen/columns). `looplet_content` stays `looplet_core`-only. Shared with F05. Propagates `EngineConfigError` for a structurally invalid puzzle. |
| **F08-FE7** `DailyResultSyncService` (parallel-allowed) | Complete (logic; emulator e2e joins with Track B) | `persistence/daily_result_sync_service.dart` | Session-level service. `enqueueFirstRun(payload)` → `sync_queue` row (`pending`) + `daily_entry.syncStatus = queued`, in one transaction; idempotency key `"{firebaseUid}\|{lang}\|{dailyDate}"`, or **null → `awaitingAuth`** when Auth hasn't completed. `drain()` — no-op while `daily_sync_enabled == false`; reclaims stale `inFlight` (> 20 s), backfills keys once `firebaseUid` exists, then for each due `pending`: `inFlight` → `sender(payload)` → `CREATED`/`ALREADY_SUBMITTED` ⇒ `synced` + entry `synced` (same txn); `retryable` ⇒ `pending` + `attemptCount++` + exponential backoff (base 30 s, ×2, cap 6 h, ±20 % jitter); `retryable` at `attemptCap` (10) or `nonRetryable` ⇒ `parked` + entry `parked`. `reviveParkedOnAppStart()` — bounded to 3 lifetime revivals. `connectivityRegained` stream + `SyncSender` are injected (real ones are FE9 / FE8). `dispose()` cancels the connectivity sub. |
| **F08-FE10** Fake daily-result producer (parallel-allowed) | Complete | `persistence/fake_daily_result_producer.dart` | `FakeDailyResultProducer.produce(...)` records a completion via `DailyRepo` and, on `firstRun`, calls `DailyResultSyncService.enqueueFirstRun`. `assert(false)` + no-op in release unless `allowInRelease` (tests). F07 replaces it with the real producer against the same `enqueueFirstRun`. |

---

## 4. Authority Reconciliation

| Conflict Source | Winning Authority | Decision | Downstream impact |
| --- | --- | --- | --- |
| `architecture.md` FE4 "**FIRST** add `GridEngine.restoreMoves(List<Move>)`" vs the actual `looplet_engine` code | codebase | `GridEngine.restoreMoves(List<Move>)` **already exists** in `packages/looplet_engine/lib/src/grid_engine.dart` with the exact required semantics (folds from t=0, throws `StateError` on a rejected move, identical result to per-move replay) and is already covered by `grid_engine_test.dart` (`group('restoreMoves', …)`). A prior session implemented it while F02's "Open Technical Decision" was still open; the Tech Lead promoted it to "required by F08" this cycle. **No F02 change was needed.** 83 F02 engine tests unchanged and green. `session_restore_test.dart` adds F08-side coverage of the resume path through it. | none — the API F08 needs is present and tested. |
| Move shorthand needed in `app` (snapshot `appliedMoves`) vs the existing copy in `tools/looplet_authoring/lib/src/move_shorthand.dart` | new app-local file | `app` cannot depend on `tools/looplet_authoring`, and adding the helper to `looplet_engine`'s public barrel would collide (`parseMoves`/`formatMove`/`MoveShorthandException`) with the `tools` copy that `cli.dart` imports. So `app/lib/engine/move_shorthand.dart` is a small local implementation (different function names: `parseMove`/`parseMoveList`/`formatMoveList`). | **Non-blocking follow-up:** a future cleanup could hoist a single shorthand helper into `looplet_engine` and have both `app` and `tools` consume it (deduping ~40 lines). Not done here to avoid touching F06's shipped `tools` suite. Flagged for the Tech Lead. |

---

## 7. State Management

* **Server vs local state:** F08 is local-first. Durable domain data + the active session live in Drift (`AppDatabase`); `DailyResultSyncService` holds only transient in-flight bookkeeping (all queue state is persisted in `sync_queue`). No server state is cached client-side (no read-back — first-run-authoritative is enforced independently on each side).
* **Providers (`persistence_providers.dart`):** `appDatabaseProvider` (singleton `AppDatabase`, `ref.onDispose(db.close)`), one `Provider` per repo, `currentGuestIdProvider` (`FutureProvider<String>`). `DailyResultSyncService` is **not** exposed as a screen-scoped provider — it is session-level (FE9 wires it as an app-scoped singleton with the real sender + connectivity stream; `platform.md` §7).
* **Exhaustive enum handling:** `DailySyncStatus` (`local`/`queued`/`synced`/`parked`) and `SyncQueueState` (`pending`/`inFlight`/`synced`/`parked`) are Dart enums; the service's `switch (result)` over `SyncSendResult` has all four arms and no `default`.

---

## 8. API / Event Integration

* No live API calls in this pass. `DailyResultSyncService` takes a `SyncSender = Future<SyncSendResult> Function(Map<String,Object?> payload)`; the real binding to `submitDailyResultV1` is **F08-FE8** (gated on `F08.FIREBASE-PROJECT` + Track B). Response→state mapping is implemented and tested against a fake sender: `CREATED`/`ALREADY_SUBMITTED` → `synced`; `retryable` (INTERNAL / transport / timeout) → `pending` + backoff; `nonRetryable` (INVALID_PAYLOAD / UNSUPPORTED_LANGUAGE) → `parked`.
* `DailyResultPayload.toJson()` matches the callable request shape from `architecture.md → Firebase Sync Surface` (`lang`, `dailyDate`, `dailyId`, `moves`, `optimalMoves`, `durationMs`, `stars`, `completedAtUtcMs`, `clientAttemptNumber`). `uid` is never in the payload.

---

## 9. Contract Compliance Check

| Area | Result | Notes |
| --- | --- | --- |
| Persistence schema (table set + names + keys + `kv` snapshot) | **Preserved** | Exact contract table names; typed tables + one `kv` row for the active session. |
| Forward-only migrations; never-drop `personal_best`/`daily_entry`/`daily_streak` | **Preserved** | `MigrationGuard` enforces it with a test that proves it throws on a protected-row delete. `schemaVersion = 1`, no steps yet. |
| Guest identity: `guestId` local UUID on every player-owned row; `firebaseUid` nullable/server | **Preserved** | `player.guestId` = v4 UUID; `firebaseUid` nullable, set by `PlayerRepo.setFirebaseUid` (FE6). No device-id keys. |
| Active-session snapshot: frozen JSON keys; `appliedMoves` IS the undo history; `thawedFrozenCells` re-derived on restore | **Preserved** | `ActiveSessionSnapshot` keys match verbatim; no separate undo stack; `restoreSession` re-derives `thawedCells` via engine replay and does not trust the cache. |
| Write-through; single transactional `kv` row for the session | **Preserved** | `ActiveSessionRepo.save` = one `insertOnConflictUpdate`; multi-step repo ops use `transaction()`. |
| `daily_entry` first-run immutable; replays → `daily_attempt`; no second sync enqueue | **Preserved** | `DailyRepo.recordCompletion` + `FakeDailyResultProducer` + `SyncQueueRepo.enqueue` dedup on the idempotency key; test "exactly-once" proves one row / one send. |
| Reconciliation first-run-authoritative | **Preserved** | Local first-run never mutated by sync; `ALREADY_SUBMITTED` treated as success; test asserts `firstRunMoveCount` unchanged after an `ALREADY_SUBMITTED` sync. |
| `sync_queue` states + idempotency key + ack-only `synced` + backoff + cap→`parked` + stale-`inFlight` sweep + `awaitingAuth` + bounded parked retry | **Preserved** | All implemented in `SyncQueueRepo` + `DailyResultSyncService`; each has a test. |
| `daily_entry.syncStatus` mirrors the queue state in the same transaction | **Preserved** | `_process` / `_park` / `enqueueFirstRun` update both inside `db.transaction`. |
| Kill-switch: `drain()` is a no-op while `daily_sync_enabled == false` | **Preserved** | `isSyncEnabled()` gate; test "kill-switch off → no send". |
| Session-level ownership (never screen-owned) | **Preserved** | Not a screen-scoped provider; FE9 constructs it app-scoped. Documented. |
| Monotonic durations; no wall clock for elapsed | **Preserved** | `ElapsedTimer` uses `Stopwatch` only; guard test. |
| `Puzzle → EngineConfig` in a consumer, not `looplet_content` | **Preserved** | `app/lib/content/puzzle_engine_config.dart`. |
| App-init sequence, `Firebase.initializeApp`, callable binding, connectivity stream | **Not Applicable (this pass)** | FE6 / FE8 / FE9 — gated on `F08.FIREBASE-PROJECT`. |

---

## 10. Behavior Preserved

* **F02 `looplet_engine`** — untouched. `restoreMoves` was already present + tested; 83 engine tests unchanged and green. `session_restore.dart` consumes the public `GridEngine` API only.
* **F01 dictionary wiring / existing app tests** — the 4 pre-existing app tests (`dictionary_wiring`, `widget_test`, `engine_wiring`) still pass; no change to `dictionary/` or `engine/dictionary_word_validator.dart` / `engine_providers.dart`.
* **`app/lib/main.dart`** — unchanged; still boots to the placeholder shell. Wiring the persistence init into `main` is FE6.
* **F06 `content/smoke/tr`** — used read-only as a restore fixture reference; `content:check` unaffected (no content files changed).

---

## 12. Implemented Files

(See §2 for the full list.) Key dependency notes:

* `app_database.dart` depends on `drift`, `drift/native`, `path`, `path_provider` (all pre-existing app deps) + `guest_id.dart` + `migration_guard.dart`.
* `session_restore.dart` depends on `looplet_content` (`Puzzle`), `looplet_engine` (`GridEngine`, `Move`, `WordValidator`, `NeverValidWordValidator`, `EngineConfigError`), `content/puzzle_engine_config.dart`, `engine/move_shorthand.dart`, `active_session_snapshot.dart`, `elapsed_timer.dart`.
* `daily_result_sync_service.dart` depends on `app_database.dart` + `player_repo` / `daily_repo` / `sync_queue_repo`; `dart:math` (`Random` for jitter — injectable), `dart:convert`.
* `persistence_providers.dart` depends on `flutter_riverpod` + all repos. `DailyResultSyncService` is intentionally not provided here (FE9).

---

## 13. Performance Notes

* Active-session `save()` is one small (`< 1 KB`) `kv` upsert — well within a move's 150–250 ms settle window; F03 persists after the move settles, not on the animation frame.
* Restore replay: ≤ realistic move count of `engine.applyMove` calls (sub-ms; F02 is allocation-disciplined for F06's search).
* Migrations run once per upgrade at launch; MVP data is tens of rows.
* `MigrationGuard` does 3 `COUNT(*)` queries before and after — negligible; only on `onUpgrade`.

---

## 16. Needs Tech Lead Clarification

None blocking. Two items for awareness (also in §4):

1. **Move-shorthand duplication** — `app/lib/engine/move_shorthand.dart` duplicates ~40 lines of `tools/looplet_authoring/lib/src/move_shorthand.dart`. A future cleanup could hoist one helper into `looplet_engine`; not done here to avoid touching F06's `tools` suite mid-F08.
2. **`uuid` package not added** — `newGuestId()` is a hand-rolled RFC-4122 v4 generator (`Random.secure()`, ~12 lines) rather than the `uuid` package, to avoid an unapproved dependency. Swap to `uuid` later if preferred; the format + `isGuestId` validation would be unaffected.

---

## 17. Test Evidence by Task

| Task / behavior | Test type | Scenario proven | File |
| --- | --- | --- | --- |
| FE1 schema + seed | unit (in-mem Drift) | `schemaVersion == 1`; exactly one `player` (v4 guestId, null firebaseUid) + seeded `settings`/`journey_progress`/`daily_streak` defaults + `store_meta` kv; protected + fresh tables start empty | `app_database_test.dart` (6) |
| FE2 never-drop guard | unit | guard passes on a no-op migration + on a non-protected-table change; **throws `MigrationDataLossError`** when a migration deletes `personal_best` rows / `daily_entry` rows | `app_database_test.dart` (4) |
| FE3 PlayerRepo | unit | `setFirebaseUid` writes through + is idempotent | `repositories_test.dart` |
| FE3 SettingsRepo | unit | sound/haptics/language toggles persist | `repositories_test.dart` |
| FE3 JourneyProgressRepo | unit | `markCompleted` unions the CSV + unlocks N+1 + is idempotent; an out-of-order completion does **not** lower `highestUnlockedLevel` | `repositories_test.dart` (2) |
| FE3 PersonalBestRepo | unit | best move count only decreases; a worse result is rejected; `isPerfect` set; `firstCompletedAtUtcMs` preserved across a new best | `repositories_test.dart` |
| FE3 DailyRepo | unit | first completion → immutable first-run + `syncStatus local`; better replay → `attemptNo 2` row, **first-run unchanged**; 3rd → `attemptNo 3`; `setSyncStatus` mirror | `repositories_test.dart` (2) |
| FE3 DailyStreakRepo | unit | stores exactly the values F07 supplies | `repositories_test.dart` |
| FE3 DailyPuzzleCache | unit | put/get; miss → null; `evictOlderThan` removes only strictly-older `YYYY-MM-DD` rows | `repositories_test.dart` |
| FE4 snapshot model | unit | lossless round-trip; **14 malformed-input rejections** (version, empty id, unknown source/status, `moveCount` mismatch, bad token, undos range, negative restart/elapsed, bad coord, zero timestamp, wrong type, missing key); `copyWith` preserves frozen fields | `active_session_snapshot_test.dart` (17) |
| FE4 restore path | unit | rebuilds `GridEngine` + replays `["R0"]` → `moveCount 1`, `isSolved` true, counters + `ElapsedTimer` restored; unsolved partial restores without winning; empty move list → t=0; **puzzle-id mismatch throws**; **a move that no longer applies (`D0` on a columns-disabled puzzle) throws `SessionRestoreException`** | `session_restore_test.dart` (5) |
| FE4 corrupt-safe read | (covered by model rejections + `ActiveSessionRepo` catch-log-clear-null path; source-reviewed) | — | `active_session_repo.dart` |
| FE5 elapsed helper | unit | accumulates across start/pause; paused → no growth; `.resumed()` restores + keeps counting; monotonic; negative → assert | `elapsed_timer_test.dart` (4) |
| FE11 `toEngineConfig` | unit | maps grid/target/columns/locked/frozen; throws `EngineConfigError` on a non-5×5 puzzle | `session_restore_test.dart` (2) |
| FE7 SyncQueueRepo | unit | enqueue **dedups on a non-parked idempotency key** (one row); `duePending` respects `nextAttemptAt` + excludes keyless rows; `reviveParkedForAppStart` bounded to 3 lifetime | `sync_test.dart` (3) |
| FE7 sync service | unit (fake sender + fake clock) | `enqueueFirstRun` → 1 queue row + entry `queued`; **CREATED → `synced` + entry mirror, one send**; **ALREADY_SUBMITTED → `synced`, first-run unchanged (reconciliation)**; **exactly-once: repeated enqueue + double drain → one send / one row**; retryable → `pending` + `attemptCount++` + future `nextAttemptAt`; retryable at cap → `parked` + entry `parked`; nonRetryable → `parked`; **kill-switch off → no send**; **awaitingAuth keyless item backfilled + sent once `firebaseUid` set**; **stale `inFlight` reclaimed and retried to `synced`** | `sync_test.dart` (11) |
| FE10 fake producer | unit | first `produce` → `firstRun` + one queue row; repeat same date → `replay`, **no second enqueue** | `sync_test.dart` (1) |

**Suite:** `melos run analyze` clean (6 packages + `flutter analyze`); `melos run format:check` clean; `melos run test` green — **263 workspace tests** (looplet_app **67** = 4 pre-existing + 63 new; engine 83, core 22, content 17, dictionary 32, solver 23, authoring 19). `melos run infra:build` / `infra:test` unaffected + green. `app_database.g.dart` committed (CI runs no `build_runner`).

---

# =====================================================================
# PASS 2 — the app-Firebase join (F08-FE6 / FE8 / FE9), 2026-09-06
# =====================================================================

`F08.FIREBASE-PROJECT` is done + verified (project `looplet-712e5`). Track B (`backend.md`) is delivered. This pass wires the (already built + tested) persistence + sync layer into the app's Firebase runtime.

## P2.1 Impacted Files

**Created — `app/lib/`:**

* `bootstrap.dart` — `sealed AppBootstrap` (`AppBootstrapReady` / `AppBootstrapMigrationError`), `appBootstrapProvider` (`FutureProvider<AppBootstrap>`), and `_bootstrapFirebase(...)` (the best-effort Firebase chain).
* `persistence/callable_sync_sender.dart` — `callableSyncSender(FirebaseFunctions)` → the real `SyncSender`; pure `mapCallableSuccess(Object?)` + `mapCallableErrorCode(String)`.
* `persistence/sync_providers.dart` — `firebaseFunctionsProvider`, `syncSenderProvider`, `dailySyncEnabledProvider` (kill-switch seam), `connectivityRegainedProvider` (`Stream<bool>` from `connectivity_plus`), `dailyResultSyncServiceProvider` (the **app-scoped, session-level** singleton).

**Updated — `app/lib/`:** `main.dart` — `LoopletApp` is now a `ConsumerWidget` gating on `appBootstrapProvider` (splash → home / `_StoreErrorScreen`); a single app-level `_SessionLifecycle` `WidgetsBindingObserver` drains the sync queue on `paused`/`resumed`.

**Updated — `app/test/`:** `widget_test.dart` (bootstrap-aware, in-memory DB + no-op sender + empty connectivity overrides); **created** `test/persistence/callable_sync_sender_test.dart` (11 mapping assertions).

## P2.2 Task-to-Code Traceability

| Task | Status | Behavior |
| --- | --- | --- |
| **F08-FE6** app-init sequence + App Check provider selection | Complete | `appBootstrapProvider`: (1) forces migrations via `PlayerRepo.current()` — `MigrationDataLossError` (or any open/migrate failure) → `AppBootstrapMigrationError` → `_StoreErrorScreen` (the only F08-owned UI: "Couldn't open your saved data / Your progress is safe", Retry = `ref.invalidate(appBootstrapProvider)`); (2) warms `ActiveSessionRepo.read()` (a corrupt `kv['active_session']` self-heals to null there); (3) constructs the session-level `DailyResultSyncService`; (4) `unawaited(_bootstrapFirebase(...))` — **never gates the first frame**. `_bootstrapFirebase`: `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` (guarded, `Firebase.apps.isEmpty` check) → `FirebaseAppCheck.instance.activate(androidProvider: kReleaseMode ? playIntegrity : debug, appleProvider: kReleaseMode ? appAttest : debug)` **wrapped in try/catch — a failure is a `debugPrint` no-op** (per `architecture.md → App Init Sequence`, amended; iOS release App Attest is expected to fail without an Apple Developer Program membership and that is fine because App Check is monitor-only) → `FirebaseAuth.instance.signInAnonymously()` → `PlayerRepo.setFirebaseUid(uid)` → `sync.reviveParkedOnAppStart()` + `sync.drain()`. Every step try/caught, logged, never rethrown. |
| **F08-FE8** real callable `SyncSender` | Complete | `callableSyncSender(functions)` → `functions.httpsCallable('submitDailyResultV1').call(payload)` → `mapCallableSuccess(result.data)`; `on FirebaseFunctionsException` → `mapCallableErrorCode(e.code)`; any other throw → `SyncSendResult.retryable`. `mapCallableSuccess`: `CREATED` → `created`, `ALREADY_SUBMITTED` → `alreadySubmitted`, anything else → `retryable` (never drop). `mapCallableErrorCode`: `invalid-argument` → `nonRetryable`, all others (`internal`/`unavailable`/`deadline-exceeded`/`resource-exhausted`/`aborted`/`unauthenticated`/unknown) → `retryable`. The queue transitions this drives are already covered by `sync_test.dart` (FE7). |
| **F08-FE9** session-level singleton + connectivity + build check | Complete (build: see P2.5) | `dailyResultSyncServiceProvider` — an app-scoped `Provider` (constructed once when the root `ProviderScope` builds it; `ref.onDispose(service.dispose)` at app termination; **never** watched/created by a screen — `platform.md` §7). Fed: `syncSenderProvider` (FE8), `dailySyncEnabledProvider` (kill-switch), `connectivityRegainedProvider` — a `broadcast` `StreamController` over `Connectivity().onConnectivityChanged` (v6 `List<ConnectivityResult>`) emitting `true` on any non-`none` result → the service's constructor `.listen`s it to `drain()`. `main.dart`'s `_SessionLifecycle` observer calls `drain()` on `paused` + `resumed` (write-through already persisted the data; this is the sync flush). `reviveParkedOnAppStart()` runs once inside `_bootstrapFirebase`. |

## P2.3 Contract Compliance Check

| Area | Result |
| --- | --- |
| App Init Sequence order (DB → migrate → snapshot → async Firebase → sync service → app tree) | **Preserved** — `appBootstrapProvider` + `_bootstrapFirebase`. |
| Firebase steps best-effort / non-fatal | **Preserved** — every step try/caught + `debugPrint`, `unawaited` from the bootstrap. |
| App Check provider selection (debug in dev, Play Integrity/App Attest in release; `activate()` failure = no-op) | **Preserved** — matches the 2026-09-06 `architecture.md` / `platform.md` §13 amendment. Hard-enforce never set. |
| `DailyResultSyncService` session-level, never screen-owned | **Preserved** — app-scoped provider, `ref.onDispose` at app teardown only; no screen references it. |
| Callable name `submitDailyResultV1` + response/error → `SyncSendResult` mapping | **Preserved** — matches `architecture.md → Firebase Sync Surface → client mapping`. |
| `daily_sync_enabled` kill-switch | **Preserved (seam)** — `dailySyncEnabledProvider` defaults on; F07 wires the real Remote Config read (documented). |
| Migration-failure UI (recoverable, no design handoff) | **Preserved** — `_StoreErrorScreen`, plain, Retry re-runs bootstrap. |

## P2.4 Assumptions / Deferred

* **Remote Config not wired** — `dailySyncEnabledProvider` is a `() async => true` seam; F07 (or a small follow-up) reads `daily_sync_enabled`. `firebase_remote_config` is not an app dependency yet (out of F08 scope; not adding an unapproved package).
* **`connectivity_plus` in tests** — the widget test overrides `connectivityRegainedProvider` with `Stream<bool>.empty()`; the real provider is exercised at runtime / QA.

## P2.5 Test Evidence (Pass 2)

| Task / behavior | Test type | Scenario | File |
| --- | --- | --- | --- |
| FE8 success mapping | unit | `CREATED`→`created`; `ALREADY_SUBMITTED`→`alreadySubmitted`; unknown/missing/non-map status → `retryable` (never dropped) | `callable_sync_sender_test.dart` |
| FE8 error mapping | unit | `invalid-argument` → `nonRetryable`; `internal`/`unavailable`/`deadline-exceeded`/`resource-exhausted`/`aborted`/`unauthenticated`/`unknown` → `retryable` | `callable_sync_sender_test.dart` |
| FE6 bootstrap → home | widget | with an in-memory DB + no-op sender + empty connectivity: splash shows, then `pumpAndSettle` → home shell renders, **no** `_StoreErrorScreen`; Firebase init inside the provider is fire-and-forget and self-catches (no platform app) | `widget_test.dart` |
| FE9 wiring | (source-reviewed — provider graph; app-scoped `Provider` + `ref.onDispose`; lifecycle observer in `main.dart`) | — | — |

**Suite (Pass 1 + Pass 2):** `melos run analyze` clean; `melos run format:check` clean; `melos run test` green — **268 workspace tests** (looplet_app **72** = 4 pre-existing + 63 Track A + 5 Pass 2; engine 83, core 22, content 17, dictionary 32, solver 23, authoring 19). `melos run infra:build` / `infra:test` green.

**Native build:** `flutter build ios --release --no-codesign` — **GREEN**: `pod install` (137s, all 6 Firebase + `connectivity_plus` pods) + Xcode release build → `✓ Built build/ios/iphoneos/Runner.app (53.2MB)`. Android `flutter build appbundle --release` not run locally (no Android SDK on this machine) — CI covers it, same as before.

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** F08-FE1…FE11 (all Frontend tasks). Pass 1 = FE1–FE5, FE7, FE10, FE11; Pass 2 = FE6, FE8, FE9.
* **Remaining Tasks (this feature):** QA (F08-QA1…QA10) → Tech Lead → DevOps/Release Engineer (F08-DEVOPS, `production-readiness`) → Tech Lead close.
* **Blockers:** none. iOS release build GREEN with the Firebase pods (P2.5). iOS production App Check (App Attest/DeviceCheck) is a deferred `[OPEN — post-MVP]` — non-blocking (App Check is monitor-only).
* **Status Suggestion:** Ready for QA.

---

## 19. Sonraki Komut

```
Run QA
```
