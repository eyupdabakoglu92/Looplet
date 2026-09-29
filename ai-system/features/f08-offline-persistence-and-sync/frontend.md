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

---

# F08-FE12 — Bugfix: app-boot Firebase ordering crash (2026-09-13)

> Delivered against the Tech Lead incident brief in `orchestration.md → Active Task Ledger → F08-FE12` / `→ Next Action`. Root cause, fix, and required regression test were pre-specified by the Tech Lead's source-level investigation; this delivery implements and verifies it.

## 1. Feature Summary

Every cold launch of the real app crashed before the home screen ever rendered: `appBootstrapProvider` (`bootstrap.dart`) constructed `dailyResultSyncServiceProvider` — which eagerly resolved `FirebaseFunctions.instance` — **before** `Firebase.initializeApp()` had run, throwing `[core/no-app]` on every boot. Fixed by making the `FirebaseFunctions` access **lazy**: the getter is now only invoked at actual send-time, inside `callableSyncSender`'s closure, where the code's pre-existing "no-Firebase-app → retryable" catch-all already handles it correctly. Verified live on a real iOS simulator: the app now boots straight to the Home screen.

---

## 2. Impacted Files

**Updated:**
- `app/lib/persistence/sync_providers.dart`
- `app/lib/persistence/callable_sync_sender.dart`
- `app/test/persistence/callable_sync_sender_test.dart`

**Created:**
- `app/test/persistence/sync_providers_test.dart`

---

## 3. Task-to-Code Traceability

- **Task ID:** F08-FE12
- **Durum:** Complete
- **Güncellenen dosyalar:** `sync_providers.dart`, `callable_sync_sender.dart`, `callable_sync_sender_test.dart`; yeni `sync_providers_test.dart`
- **Uygulanan davranış:** `firebaseFunctionsProvider` artık çözülmüş bir `FirebaseFunctions` değil, bir `FirebaseFunctions Function()` getter döndürüyor (`sync_providers.dart`). `callableSyncSender` bu getter'ı yalnız döndürdüğü closure içinde, gönderim anında çağırıyor (`callable_sync_sender.dart`) — provider inşa anında hiçbir Firebase çağrısı yapılmıyor. Sonuç: `appBootstrapProvider`'ın `ref.watch(dailyResultSyncServiceProvider)` satırı artık `Firebase.initializeApp()` tamamlanmadan asla patlamıyor.

---

## 4. Authority Reconciliation

Bu bir contract değişikliği değil — `architecture.md → App Init Sequence`'te tarif edilen adım **sırası değişmedi** (yerel DB → `dailyResultSyncServiceProvider` inşası → `unawaited(_bootstrapFirebase)`); sadece `dailyResultSyncServiceProvider`'ın inşası artık Firebase'e hiç dokunmuyor (daha önce yanlışlıkla dokunuyordu). Tech Lead'in brief'inde sunduğu (a)/(b) seçeneklerinden **(a) — lazy `FirebaseFunctions.instance`** uygulandı: daha küçük, tek dosyaya yakın bir değişiklik ve kodun zaten var olan "no-Firebase-app → retryable" catch-all'ının niyetini olduğu gibi tamamlıyor. `architecture.md`'de değişecek bir satır yok — Tech Lead'e raporlanacak bir sapma yok.

---

## 5. Root Cause (kanıtla)

`app/lib/bootstrap.dart`:
```dart
final sync = ref.watch(dailyResultSyncServiceProvider);   // <- eskiden burada patlıyordu
unawaited(_bootstrapFirebase(ref, sync));                  // <- Firebase.initializeApp() burada, bir satır GEÇ
```
`dailyResultSyncServiceProvider` → `syncSenderProvider` → `firebaseFunctionsProvider` eskiden `FirebaseFunctions.instance`'ı **provider inşa anında, senkron** olarak çağırıyordu. Bu getter `Firebase.app()`'i çözer ve `Firebase.initializeApp()` tamamlanmadıysa `[core/no-app]` fırlatır — hiçbir platform kanalı gerektirmeden, saf Dart tarafında. Bu throw `appBootstrapProvider`'ın try/catch'inin (yalnız iki yerel-DB `await`'ini sarmalıyor) **dışında** kalıyordu ve `_BootstrapGate`'in genel `error:` dalına (`StoreErrorScreen`) düşüyordu.

**Neden hiç yakalanmamıştı:** `app/test/widget_test.dart` — gerçek `main()` ağacını boot eden TEK test — `syncSenderProvider`'ı doğrudan sahte bir `SyncSender` ile override ediyor (`syncSenderProvider.overrideWithValue((...) async => SyncSendResult.retryable)`). Bu, `firebaseFunctionsProvider`'a hiç uğramadan `dailyResultSyncServiceProvider`'ın inşasını tamamlıyor — yani tam olarak kırık olan zinciri baştan atlıyor. `sync_test.dart` da `DailyResultSyncService`'i `callableSyncSender` kullanmadan, elle yazılmış bir `sender` fonksiyonuyla kuruyor. Hiçbir test gerçek `firebaseFunctionsProvider`/`syncSenderProvider` zincirini, Firebase hiç initialize edilmemişken çalıştırmıyordu — tam da bu regresyon testini `sync_providers_test.dart` olarak ekledim.

---

## 6. Fix

`sync_providers.dart`:
```dart
final firebaseFunctionsProvider = Provider<FirebaseFunctions Function()>(
  (ref) => () => FirebaseFunctions.instance,
);
```
`callable_sync_sender.dart`:
```dart
SyncSender callableSyncSender(FirebaseFunctions Function() functions) {
  return (Map<String, Object?> payload) async {
    try {
      final callable = functions().httpsCallable('submitDailyResultV1');
      ...
    } catch (_) {
      return SyncSendResult.retryable; // artık gerçekten ulaşılabilir
    }
  };
}
```
`FirebaseFunctions.instance` artık yalnız gönderim anında, closure içinde çağrılıyor — provider inşa sırasında değil. Gönderim anına kadar `_bootstrapFirebase` normalde `Firebase.initializeApp()`'i çoktan tamamlamış oluyor; tamamlamamışsa bile closure'ın kendi catch-all'ı `retryable` döndürüyor (kuyruk öğesi kaybolmuyor) — kodun zaten taşıdığı "Transport / plugin / no-Firebase-app — transient, keep the item" niyeti artık gerçekten çalışıyor.

---

## 7. Contract Compliance Check

- **Screen / route contract:** Preserved — `_BootstrapGate` / route yapısı değişmedi.
- **App Init Sequence adım sırası (`architecture.md`):** Preserved — sıra aynı, yalnız `dailyResultSyncServiceProvider` artık Firebase'e erken dokunmuyor.
- **`DailyResultSyncService` / `sync_queue` state machine:** Preserved — `callableSyncSender`'ın davranışı (başarı/hata eşlemesi) değişmedi, yalnız `FirebaseFunctions` erişim zamanı değişti.
- **UI state / store state consistency:** Not Applicable (görsel değişiklik yok).
- **Navigation / back / header behavior:** Not Applicable.

---

## 8. Behavior Preserved

- `callableSyncSender`'ın başarı/hata → `SyncSendResult` eşlemesi (`mapCallableSuccess`/`mapCallableErrorCode`) hiç değişmedi — testleri aynen geçiyor.
- `DailyResultSyncService`'in kuyruk state machine'i (`sync_test.dart`, `callableSyncSender`'a hiç dokunmuyor) etkilenmedi.
- Gerçek cihazda Firebase başarıyla initialize olduğunda (asıl akış) davranış birebir aynı — tek fark, artık initialize olmadan önce bir çökme olmuyor.

---

## 9. Retro Bugfix Disiplini (zorunlu self-check)

- **Kırık kullanıcı yolu (tek cümle):** Her soğuk uygulama açılışı, ana ekrana ulaşmadan önce `StoreErrorScreen` ile çöküyordu.
- **Bu yolu tetikleyen tüm entry path'ler:** Tek path var — `main()` → `LoopletApp` → `appRouterProvider` → `_BootstrapGate` → `appBootstrapProvider`. Uygulamanın **tek** girişi bu; alternatif bir entry yok.
- **Store alanları / action'lar:** `appBootstrapProvider`'ın kendisi bir Riverpod `FutureProvider`; okuduğu tek "durum" `Firebase.apps` (boş/dolu) ve yerel DB'nin açılabilirliği. Yazan action yok — bu bir inşa-zamanı sıralama hatası, bir mutation hatası değil.
- **Etkilenmeyen branch'ler:** `AppBootstrapMigrationError` yolu (Drift migration hatası) hiç dokunulmadı — hâlâ aynı şekilde çalışıyor. `_bootstrapFirebase`'in kendi içindeki try/catch'ler (App Check, anonim giriş, sync drain) değişmedi.
- **Kök neden kapatıldı mı, yoksa semptom mu maskelendi:** Kök neden kapatıldı — `FirebaseFunctions.instance`'a erken erişim tamamen ortadan kaldırıldı (maskeleme değil, örneğin sadece `appBootstrapProvider`'a bir try/catch eklemek gibi bir semptom-gizleme yapılmadı).

**Self-check matrisi:**
- ✅ **fresh session:** `sync_providers_test.dart` — `Firebase.apps` boşken `dailyResultSyncServiceProvider` fırlatmıyor; gerçek simülatörde ilk kurulumdan sonra ana ekrana ulaşıyor (ekran görüntüsü ile doğrulandı).
- ✅ **persisted stale session:** Bu hata herhangi bir persist edilmiş state'e bağlı değildi (saf provider-inşa sıralaması); N/A ama etkilenmediği doğrulandı — `widget_test.dart` (in-memory DB, önceden var olan seed davranışı) hâlâ geçiyor.
- ✅ **alternate entry path:** Uygulamanın tek girişi olduğu için N/A — kontrol edildi, başka bir `main()`/bootstrap yolu yok.
- ✅ **actor / permission / user-state farkları:** N/A — bu katmanda actor/permission kavramı yok (tek yerel oyuncu, F08 kapsamı).

---

## 17. Test Evidence by Task

| Task / davranış | Test türü | Kanıtlanan senaryo | Dosya |
| --- | --- | --- | --- |
| F08-FE12 kök neden regresyonu | unit (`ProviderContainer`, gerçek zincir) | `Firebase.apps` boşken **gerçek** `firebaseFunctionsProvider`/`syncSenderProvider` override edilmeden `dailyResultSyncServiceProvider` inşa ediliyor, fırlatmıyor | `sync_providers_test.dart` |
| F08-FE12 gönderim-anı davranışı | unit | Gerçek `syncSenderProvider`'ın döndürdüğü sender, Firebase initialize edilmeden çağrıldığında `retryable` dönüyor (fırlatmıyor) | `sync_providers_test.dart` |
| `callableSyncSender` lazy'liği | unit | Getter, sender **inşa edilirken** hiç çağrılmıyor (çağrılsaydı hemen fırlardı) | `callable_sync_sender_test.dart` |
| `callableSyncSender` catch-all artık ulaşılabilir | unit | Gönderim anında fırlatan bir getter → `retryable` (çökme yok) | `callable_sync_sender_test.dart` |
| Regresyon yok — mevcut eşleme testleri | unit | `mapCallableSuccess`/`mapCallableErrorCode` tüm vakalar aynen geçiyor | `callable_sync_sender_test.dart` (değişmedi) |
| Regresyon yok — kuyruk state machine | unit | `sync_test.dart` (elle yazılmış sender, `callableSyncSender`'a dokunmuyor) aynen geçiyor | `sync_test.dart` |
| Regresyon yok — mevcut boot widget testi | widget | `widget_test.dart` ("app bootstraps and shows the home shell") aynen geçiyor | `widget_test.dart` |
| **Gerçek cihaz doğrulaması (zorunlu, brief'te istendi)** | runtime | `flutter run -d <iPhone 16 simulator>` ile gerçek boot: **öncesi** — `StoreErrorScreen` + `[core/no-app]`; **sonrası** — doğrudan Home ekranı (LOOPLET, 0/30 Journey halkası, DEVAM ET). Ekran görüntüsü bu sohbette paylaşıldı. | manuel simülatör çalıştırması |

**Suite:** `flutter analyze` (app) clean; `dart format --output=none --set-exit-if-changed app` clean; `flutter test` (app) **181/181** (176 + 5 yeni test; regresyon yok). Pure-package suites (`looplet_core` 22, `looplet_engine` 83, `looplet_content` 17, `looplet_solver` 23, `looplet_dictionary` 32) yeniden çalıştırıldı — hepsi yeşil, bu paketlerden hiçbirine dokunulmadı.

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** F08-FE12 (bugfix).
* **Remaining Tasks:** Tech Lead reconcile → karar (ağırlığına göre bir QA re-verify turu mu, yoksa doğrudan kapanış mı) → F08-DEVOPS (Blaze/deploy) ayrı ve değişmeden parked kalıyor.
* **Blockers:** yok.
* **Status Suggestion:** Needs Tech Lead Review.

---

## 19. Sonraki Komut

```
Run Tech Lead
```

---

# F08-FE13 — Bozuk store kurtarma, Retry yeniden bağlanma, emülatör araçları, storage-full harness (2026-09-29)

> Kontrat: `architecture.md` → "Activation 2026-09-29" A1–A5 + kilitli "Resilience", "App Init Sequence", "Ownership & Lifecycle", "QA Focus". Brief: `orchestration.md` → Current Brief. Taban: HEAD `1d373d7` + commit'lenmemiş çalışma ağacı; teslim edilen `app/` ağacı `9de12e6a82077a19178bb4e4cae2398d110c3e7d` (`git write-tree --prefix=app/`, geçici index). Kanıt dosyaları: `evidence/` (`evidence/README.md`).

## 1. Feature Summary

* **Bozuk store artık çıkmaz sokak değil (A1, AC8):** bootstrap açılış/ilk sorgu hatasını sınıflandırıyor. `SQLITE_NOTADB` (26) / `SQLITE_CORRUPT` (11) → bağlantı kapanır, dosya (+ `-wal` / `-shm` / `-journal`) `looplet.sqlite.corrupt-<utcMs>` olarak karantinaya alınır (yalnız en yeni kopya tutulur), store yeniden oluşturulur (yeni misafir), `store: db_reinitialized — <kod>` log'u, Home. Aynı launch'ta ikinci bozukluk → hata ekranı, ikinci recreate yok (loop guard). Migration hatası → bugünkü hata ekranı, veri korunur. Diğer her hata → hata ekranı.
* **Retry yeni bağlantı açıyor (A2):** hatayla biten bir bootstrap bağlantıyı "stale" işaretler; Retry'ın başlattığı yeniden çalıştırma önce eski bağlantıyı kapatır (await), `appDatabaseProvider`'ı invalidate eder, taze bağlantıyla açar. Hata ekranı ve splash görsel olarak değişmedi.
* **Debug-only emülatör bağlantısı + sahte üretici tetikleyicisi (A3):** `--dart-define=LOOPLET_FIREBASE_EMULATOR=<host>` yalnız `kDebugMode`'da; adlandırılmış bir Firebase app (`looplet-emulator`, proje `demo-looplet`) auth 9099 / firestore 8080 / functions 5001'e bağlanır. Home debug satırında `sync` → `/debug/sync` (yalnız debug'da kayıtlı route): produce, produce + leave, drain, tarih ±1 gün, `daily_sync_enabled` anahtarı, canlı `sync_queue` listesi. Release binary'sinde hiçbiri yok (LE-08).
* **Storage-full harness (A4, AC7):** gerçek dosya DB'si + üretim bağlantısı üzerinde `PRAGMA max_page_count` ile `SQLITE_FULL`; rollback, son iyi durum, `persist_failed`, bellekten devam, sonraki sınırda yeniden deneme ve çok satırlı transaction'da kısmi yazım olmaması test ediliyor.
* **Bulunan ve düzeltilen gizli hata:** Drift `onUpgrade`'i transaction'a sarmıyordu — başarısız bir migration adımı veya never-drop guard ihlali **kısmi uygulanmış** kalıyordu (test: `personal_best` 1 → 0 satır). Guard'lı adımlar artık bir `transaction` içinde (bkz. §4).

## 2. Impacted Files

**Oluşturulan:** `app/lib/persistence/store_recovery.dart`, `app/lib/firebase_emulator.dart`, `app/lib/debug/debug_sync_screen.dart`, `app/test/persistence/store_recovery_test.dart`, `app/test/persistence/storage_full_test.dart`; kanıt araçları `evidence/*.sh|*.py|*.json|README.md`, kanıtlar `evidence/runtime/**`.

**Güncellenen:** `app/lib/bootstrap.dart`, `app/lib/persistence/app_database.dart`, `app/lib/persistence/migration_guard.dart`, `app/lib/persistence/persistence_providers.dart`, `app/lib/persistence/sync_providers.dart`, `app/lib/persistence/callable_sync_sender.dart`, `app/lib/app_router.dart`, `app/lib/home_screen.dart`, `app/test/shell/store_error_screen_test.dart`, `app/test/persistence/sync_test.dart`.

## 3. Task-to-Code Traceability

* **Task ID:** F08-FE13 — **Durum: Complete**
  * **A1 sınıflandırma:** `store_recovery.dart` `classifyStoreFailure` — drift sarmalayıcılarını açar (`DriftRemoteException.remoteCause`: üretim bağlantısı arka plan isolate'inde; `CouldNotRollBackException.cause`: SQLite `SQLITE_FULL`'da transaction'ı kendisi geri alır), `extendedResultCode & 0xff` ile 26 / 11 → `unreadable`; `MigrationDataLossError` / `MigrationStepError` → `migration`; gerisi → `other`.
  * **A1 kurtarma + loop guard:** `bootstrap.dart` `appBootstrapProvider` → `_openStore` (player + active_session ilk sorguları) → `_recoverStore`: kapat → `quarantineStoreFile` → `ref.invalidate(appDatabaseProvider)` → yeniden aç → `store: db_reinitialized — SQLITE_NOTADB (26); quarantined as …`. `StoreLaunchState.recreatedThisLaunch` (`storeLaunchStateProvider`, hiç invalidate edilmez) ikinci recreate'i engeller. Hata durumu `AppBootstrapStoreError(kind, message)` (eski `AppBootstrapMigrationError`'ın yerini aldı; router eşlemesi aynı: `StoreErrorScreen`).
  * **A1 kural 4 (migration):** `app_database.dart` — adımlar `upgradeStep(m, from)`'da; guard'lı döngü `transaction` içinde; atılan her hata `MigrationStepError` olarak yeniden fırlatılır (bozuk bir sayfaya çarpan bir adım asla recreate'e yol açmaz). `store: migration_failed — …` log'u.
  * **A2:** `bootstrap.dart` — `finally` bloğu Ready olmayan her çalışmada `connectionStale = true`; sonraki çalışma `_replaceConnection` (await `close`, `invalidate`). Store sağlayıcıları bootstrap içinde `ref.read` ile okunuyor ki bağlantı değişimi bootstrap'ı kendi içinde yeniden başlatmasın.
  * **A3:** `firebase_emulator.dart` (`firebaseEmulatorHost`, `initializeEmulatorFirebaseApp`, `loopletFirebaseApp`); `bootstrap.dart` `_bootstrapFirebase` emülatör modunda adlandırılmış app'i başlatır, App Check'i atlar, `FirebaseAuth.instanceFor(app: loopletFirebaseApp())`; `sync_providers.dart` `firebaseFunctionsProvider` → `FirebaseFunctions.instanceFor(app: loopletFirebaseApp())` (varsayılan app için birebir `FirebaseFunctions.instance`; getter hâlâ lazy — FE12 korunuyor). Tetikleyici: `debug/debug_sync_screen.dart`, `app_router.dart` `if (kDebugMode) GoRoute('/debug/sync')`, `home_screen.dart` `_DebugRow` → `sync`. Kill-switch: `sync_providers.dart` `debugSyncDisabledProvider` (yalnız `kDebugMode`).
  * **A4 harness:** `test/persistence/storage_full_test.dart`.
  * **Teşhis log'u:** `callable_sync_sender.dart` — callable hatası artık `sync: submitDailyResultV1 failed — <kod>: <mesaj>` olarak loglanıyor (eşleme değişmedi). Emülatör kablolamasındaki iki sorunu bu log ortaya çıkardı (§16).
* **Task ID:** F08-LOCAL-EVIDENCE — **Durum: Complete** (F08.OFFLINE-JOURNEY kullanıcı runtime'ı bekliyor — ayrı bölüm).

## 4. Authority Reconciliation

| Konu | Kazanan authority | Uygulanan karar | Downstream etki |
| --- | --- | --- | --- |
| Migration transaction'sız (gizli hata, A1 kapsamı dışında bulundu) | Kilitli Resilience "Migration step throws → abort without partial apply; keep old DB" + A1 kural 4 ("Store error copy stays true") | Guard'lı `onUpgrade` döngüsü `transaction` içine alındı; şema, adım ve guard semantiği değişmedi (bugün adım yok, `schemaVersion = 1`). N-TXN negatifi yakalıyor. | Tech Lead doğrulamalı: A1 listesinde olmayan ama A1 kural 4'ün doğruluğu için gerekli bir düzeltme. F08-FE2'nin "no partial apply" iddiası gerçek bağlantıda bugüne dek doğrulanmamıştı. |
| Karantinada `-journal` | A1 kural 2 (`-wal` / `-shm`) | `-journal` da taşınıyor: store varsayılan rollback-journal modunda; yeni store'un yanında kalan sıcak bir journal ona geri sarılırdı. | Yok. |
| Retry'ın bağlantıyı yenileme yeri | A2 ("Retry invalidates the connection provider … closed first") | Sıfırlama buton handler'ında değil, Retry'ın tetiklediği bootstrap çalışmasının başında yapılıyor (splash hemen görünür, kapatma await edilir). Hatadan sonra bootstrap'ı yalnız Retry yeniden çalıştırır. | Yok; N-RETRY yakalıyor. |
| Emülatör: varsayılan app yerine adlandırılmış app | A3 ("after `Firebase.initializeApp` … project `demo-looplet`") | iOS'ta varsayılan app `GoogleService-Info.plist` projesinde kalıyor (Dart `copyWith(projectId:)` etkisiz, callable yolu `/looplet-712e5/…` oldu). Adlandırılmış app `demo-looplet` ile doğru yolu kullanıyor. | Yok; üretim yolu varsayılan app. |
| Emülatör modunda App Check atlanıyor | App Init step 3 (best-effort, soft-enforce) | Emülatörler attest etmez; debug-token değişimi gerçek App Check backend'ine giderdi. Yalnız debug + define. | Yok. |
| Debug ekranında tarih ±1 gün ve kill-switch anahtarı | A3 (tetikleyici) / A4 (`daily_sync_enabled=false` vakası) | A4 vakaları için debug-only araç; release'de derlenmiyor (LE-08). | Yok. |

## 7. State Management

* `appDatabaseProvider` artık `appStoreFileProvider`'dan (varsayılan `<Documents>/looplet.sqlite`) `AppDatabase.at(locate)` kuruyor; testler dosya yolunu geçici dizine çevirerek gerçek bağlantıyı çalıştırıyor. In-memory override kullanan mevcut testler değişmedi.
* `storeLaunchStateProvider` — launch ömürlü `StoreLaunchState` (`recreatedThisLaunch`, `connectionStale`).
* `debugSyncDisabledProvider` (`StateProvider<bool>`) — yalnız debug'da `dailySyncEnabledProvider`'ı etkiler (`!(kDebugMode && …)`; release'de sabit `true`).

## 8. API / Event Integration

* `submitDailyResultV1` kontratı, istek/yanıt ve hata eşlemesi değişmedi (`mapCallableSuccess` / `mapCallableErrorCode` aynı). Yalnız log satırları eklendi.
* Emülatörde doğrulanan uçtan uca eşleme: CREATED → `synced`; ALREADY_SUBMITTED → `synced` + sunucu değişmez; bağlantı kopması / yanıt kaybı → retryable + backoff (LE-04).

## 9. Contract Compliance Check

* **Screen / route contract:** Preserved — `/`, `/play` aynı; `/debug/sync` yalnız debug'da (Extended, test tooling).
* **Backend response / event mapping:** Preserved.
* **Error mapping:** Extended — bootstrap hata sınıflandırması (A1); oyuncuya gösterilen kopya ve ekran aynı.
* **UI state / store state consistency:** Preserved — kurtarma normal `onCreate` tohumuna iner (Home "new"); `AppBootstrapStoreError` tüm hata yollarını tek ekrana eşler (exhaustive `switch`).
* **Navigation / back / header behavior:** Preserved — hata ekranı / splash / Home değişmedi; debug ekranı standart AppBar geri oku (yalnız debug).
* **Async authority / lifecycle / boundary semantics:** Preserved — sync servisi session-level; ekran dispose'u senkronu durdurmuyor (LE-05); Retry eski bağlantıyı kapatıp yenisini açıyor.

## 10. Behavior Preserved

* İyi store ve boş store yolları: aynı guest, aynı veri, karantina yok (`store_recovery_test` "a good store opens untouched", "no store → created"); cold boot'larda açık kare yok (LE-07).
* Bozuk `active_session` JSON'u: `save_corrupt_recovered` yolu dokunulmadan (`ActiveSessionRepo`, `session_restore_test`).
* FE12 tembel `FirebaseFunctions` erişimi: `sync_providers_test` aynen geçiyor (getter hâlâ gönderim anında çözülüyor).
* `StoreErrorScreen` / splash / Home görünümü ve D3 Retry davranışı (splash karesi): `store_error_screen_test` aynen geçiyor (yalnız sınıf adı güncellendi).
* Play write-through ve `persist_failed` yolu değişmedi; harness şimdi bunu gerçek bir disk-dolu hatasıyla doğruluyor.

## 12. Implemented Files

* `lib/persistence/store_recovery.dart` — `StoreFailureKind`, `StoreFailure`, `classifyStoreFailure`, `quarantineStoreFile`, `StoreLaunchState`.
* `lib/bootstrap.dart` — sınıflandır / kurtar / loop guard / stale bağlantı; `AppBootstrapStoreError`; emülatör init dalı; App Check emülatörde atlanır.
* `lib/firebase_emulator.dart` — define kapısı, portlar, `demo-looplet`, adlandırılmış app, `loopletFirebaseApp()`.
* `lib/persistence/app_database.dart` — `AppDatabase.at`, `storeFileName`, `defaultStoreFile`, `upgradeStep`, guard'lı döngü `transaction` + `MigrationStepError`.
* `lib/persistence/migration_guard.dart` — `MigrationStepError`.
* `lib/persistence/persistence_providers.dart` — `appStoreFileProvider`, `storeLaunchStateProvider`.
* `lib/persistence/sync_providers.dart` — `instanceFor(app: loopletFirebaseApp())`; `debugSyncDisabledProvider`.
* `lib/persistence/callable_sync_sender.dart` — hata log'u.
* `lib/debug/debug_sync_screen.dart`, `lib/app_router.dart`, `lib/home_screen.dart` — debug tetikleyici.
* Testler: `store_recovery_test.dart` (20), `storage_full_test.dart` (2), `sync_test.dart` (+1 regain), `store_error_screen_test.dart` (sınıf adı).

## 14. Assumptions

* Kurtarma sonrası oyuncuya bildirim yok (A1 kural 6; DB-REINIT-NOTICE takipte).
* Keychain'deki Firebase Auth kullanıcısı store silinince / yeniden oluşturulunca **kalır**: yeni `guestId` aynı `firebaseUid`'i alır (LE-04 hazırlığında görüldü). İdempotency anahtarı `firebaseUid|lang|date` olduğundan kurtarma sonrası aynı güne ait yeni bir koşu sunucuda `ALREADY_SUBMITTED` olur — first-run-authoritative ile tutarlı; not olarak kaydedildi, davranış değiştirilmedi.

## 16. Needs Tech Lead Clarification

1. **Backend test verisi hatası (F08.EMULATOR):** `infra/functions/test/submitDailyResult.test.ts` "ALREADY_SUBMITTED on a repeat" testi `moves: 8`, `optimalMoves: 9` gönderiyor; kontrat (`optimalMoves <= moves`) gereği handler doğru olarak `INVALID_PAYLOAD` dönüyor. Suite 30/31. Kod değil test hatası; sahibi Backend Developer (kapsamım dışı, dokunmadım). Aynı davranış client ↔ emülatör seviyesinde LE-04 D ile kanıtlandı.
2. **Araç ön koşulu:** kurulu `firebase-tools` 15.29.0 **Java 21+** istiyor (Activation'daki "JDK 17 yeterli" notu geçersiz). Kullanıcı onayıyla `brew install openjdk@21` kuruldu (keg-only, link edilmedi; sistem Java'sı değişmedi). `test:emulator` için `JAVA_HOME=/opt/homebrew/opt/openjdk@21`. `setup-manifest.md` / CI emülatör işi için Tech Lead / DevOps kararı.
3. **Migration transaction düzeltmesi** (§4) — A1 listesinde yoktu; Tech Lead kabulü gerekiyor.
4. **Emülatör çalıştırma prosedürü:** simülatör daha önce gerçek projeye bağlandıysa `xcrun simctl keychain <udid> reset` gerekiyor (aksi halde gerçek projenin anonim kullanıcısı geri yüklenir, auth emülatörü token'ı reddeder). QA re-run'ı için kayıt.

## 17. Test Evidence by Task

**Suite'ler (final kod, 2026-09-29 ~09:00–09:05Z, macOS host, Flutter 3.32.8):**

| Komut | Sonuç |
| --- | --- |
| `melos run analyze` | exit 0 |
| `dart format --output=none --set-exit-if-changed app packages tools` | exit 0 (193 dosya, 0 değişiklik) |
| `melos run test` | exit 0 — app **588/588**, core 22, content 17, dictionary 32, solver 23, authoring 25, engine 83; skip 0 |
| `flutter test integration_test -d <iPhone 16>` | **13/13**, exit 0 (`evidence/runtime/integration-final.log.txt`) |

**Davranış bazında (unit / widget / repeatable integration — `flutter test`, host sqlite3):**

| Task / davranış | Test | Kanıtlanan | İzolasyon |
| --- | --- | --- | --- |
| A1 sınıflandırma | `store_recovery_test` "classifyStoreFailure" (4) | 26/11/779 → unreadable; **gerçek üretim bağlantısının** `DriftRemoteException`'ları (NOTADB, CORRUPT, CANTOPEN); migration tipleri; `CouldNotRollBackException(FULL)` → other | yok (gerçek dosya, arka plan isolate) |
| A1 karantina | "quarantineStoreFile" (2) | isimlendirme, companion'lar, baytlar silinmez; yalnız en yeni kopya | geçici dizin |
| A1 kurtarma | "bootstrap recovery" (7) | NOTADB (seed-d3 baytları) ve CORRUPT → Ready, yeni guest, log; iyi store ve boş store dokunulmaz; `MigrationDataLossError` ve CORRUPT nedenli adım → hata, dosya satırları korunur (1 player, 1 best, `user_version` 1), karantina yok; CANTOPEN → other, karantina yok | `ProviderContainer`; sync sender / connectivity override (ağ yok) |
| A1 loop guard | "the loop guard" (1) | recreate de bozuk → hata; tam 1 recreate / 1 karantina; aynı launch'ta Retry → yine hata, recreate yok | dosyayı her bağlantıda bozan override |
| A2 Retry | "Retry reconnects" (3) | CANTOPEN → sebep kalkınca Retry → Ready, yeni bağlantı örneği; eski bağlantı kapalı; Ready iken bağlantı korunur | — |
| A3 kapı | "the emulator gate" (3) | `debugBuild: false` → define ne olursa olsun null | — |
| A4 storage-full | `storage_full_test` (2) | Active session: `SQLITE_FULL` → tek `persist_failed (code 13)`, `moveCount` 2 bellekte, DB'de son iyi snapshot birebir, `integrity_check` ok; hâlâ dolu → ikinci deneme de başarısız; yer açılınca sonraki sınır 4 hamlenin tamamını yazar. Çok satırlı transaction (queue insert + `daily_entry` mirror): hiçbiri kalıcı değil, first-run alanları aynı | gerçek dosya + üretim bağlantısı; sayfa doldurma `max_page_count` + filler |
| Lifecycle regain | `sync_test` "a connectivity-regain event drains the queue" | servis kendi listener'ı ile drain eder | sahte sender, stream |

**Named negative runs** (`evidence/neg-fe13.py`, final kod, her biri dosyayı bayt kopyasından geri yükler; `evidence/runtime/neg-fe13.log.txt`):

| Run | Mutasyon | Yakalayan testler |
| --- | --- | --- |
| N-CLASS | unreadable da hata ekranına | 3 (NOTADB, CORRUPT, loop guard) |
| N-LOOP | loop guard kaldırıldı | 1 (loop guard: Retry'da ikinci recreate) |
| N-RETRY | stale bağlantı yenilenmiyor | 2 (Retry recovery, loop guard) |
| N-FULL | `enqueueFirstRun` transaction'ı bypass | 1 (çok satırlı yazım: kısmi queue satırı kalıyor) |
| N-FULL-FATAL | `persist_failed` catch'i daraltıldı | 1 (active session harness) |
| N-TXN | migration transaction'ı kaldırıldı | 1 (`MigrationDataLossError` → satır kaybı) |
| N-QUAR | eski karantina silinmiyor | 1 |
| N-GATE | `if (!debugBuild) return null;` kaldırıldı | 1 |
| N-REGAIN | connectivity listener kaldırıldı | 1 |

**Release derleme kapısı (LE-08):** `flutter build ios --release --no-codesign --dart-define=LOOPLET_FIREBASE_EMULATOR=127.0.0.1` exit 0; `App.framework/App` (sha256 `dc9ae88b…`) içinde `demo-looplet`, `looplet-emulator`, `firebase: emulators at`, `debug-sync:`, `/debug/sync`, `produce + leave`, `+ 1 day` = 0; kontrol dizgileri (`submitDailyResultV1` 2, `looplet.sqlite` 1, `active_session` 4, `.corrupt-` 1) mevcut. Kontrol: debug `kernel_blob.bin`'de `demo-looplet` 3, `/debug/sync` 2. (Em dash içeren dizgiler iki baytlı saklandığı için `strings` ile görünmez — yalnız ASCII dizgiler karşılaştırıldı.)

---

# F08-LOCAL-EVIDENCE — Yerel / emülatör / runtime kanıtı (2026-09-29, A4)

> Hedef: iPhone 16 simülatörü `D0011CE7-…`, iOS 18.6, debug build'ler. Resume koşusu (LE-02) FE13'ün ilk build'inde (bootstrap store yolu final ile aynı; sonraki değişiklikler Firebase kablolaması, log ve debug ekranı); emülatör vakaları (LE-04/05) final `lib/` ile; cold boot ve bozuk store final build'de yeniden koşuldu (LE-07c/d, LE-01d). **QA-owned kayıtlar PASS işaretlenmedi** — aşağıdaki teslim kanıtı F08-QA-FUNCTIONAL incelemesi içindir.

## Evidence Ledger

| ID | Senaryo (ledger) | Sınıf | Komut / aksiyon | Sonuç | Kanıt |
| --- | --- | --- | --- | --- | --- |
| LE-01 | Bozuk store (AC8, F08.UNREADABLE-DB) | runtime | `seed-d3.sh <udid> corrupt` → launch; log stream; Documents listesi | Home "new" (0/30, Seviye 1); `store: db_reinitialized — SQLITE_NOTADB (26); quarantined as …/looplet.sqlite.corrupt-1790669966380`; 392 baytlık karantina + yeni 86016 baytlık store; yeni guest, `journey_progress` 1. İkinci bozukluk → yalnız en yeni karantina (`…-1790669991538`). Final build'de tekrar (LE-01d) aynı. | `LE-01-*`, `LE-01b-*`, `LE-01d-*`, `LE-notes.txt` |
| LE-01c | Retry yeniden bağlanma (A2) | runtime | Documents'ta `looplet.sqlite` dizini (CANTOPEN) → launch → hata ekranı → dizin silindi → "Tekrar dene" | Hata ekranı (debug kutusu `SqliteException(14)`), `store: bootstrap_failed` log'u; Retry → Home, yeni store; relaunch yok | `LE-01c-store-error.png`, `LE-01c-after-retry-home.png`, `LE-01c-retry-reconnect.log.txt` |
| — | Migration hatası runtime | — | — | Debug'da güvenle zorlanamıyor (v2 binary gerekir); gerçek dosya + arka plan bağlantıyla otomatik testler kapsıyor (FE13 §17) | — |
| LE-02 | Resume fidelity (AC1/AC6, F08.LOCAL-RESUME) | runtime | Seviye 21 (donmuş 0,1): L1 → restart → L1 U3 R4 → undo → L0 D0 (erime: satır 0 "AYNA"; dizi `looplet_authoring` motoruyla BFS ile bulundu); kill → relaunch → "Devam et" | Snapshot kill öncesi ve sonrası birebir: `appliedMoves [L1,U3,L0,D0]`, `moveCount 4`, `undosRemaining 2`, `restartCount 1`, `elapsedMsAccumulated 64457`, `thawedFrozenCells ["0,1"]`; ızgara, HAMLE 4, 2 undo noktası, erimiş Y ekranda birebir | `LE-02a-*`, `LE-02b/c-*` |
| LE-02d | Tamper (thaw yeniden türetme) | runtime | kill → `thawedFrozenCells` `[]` yapıldı → relaunch | Y yine erimiş gösteriliyor (önbellek değil replay); sonraki hamlede (R2) snapshot `thawedFrozenCells ["0,1"]` yeniden yazıldı, `restartCount 1`, `undosRemaining 2`, `elapsed 84509` (ölü süre sayılmadı: duvar saati farkı 91.8 s, elapsed +20.1 s) | `LE-02d-*`, `LE-02e-*`, `LE-02f-*` |
| LE-03 | Emülatör kurallar / callable suite (F08.EMULATOR) | repeatable integration | `cd infra/functions && npm ci && npm run build && npm run test:emulator` (JDK 21, `demo-looplet`) | **1 failed, 30 passed / 31**; `rules.test.ts` PASS, `skeleton.test.ts` PASS; `submitDailyResult` "ALREADY_SUBMITTED on a repeat" FAIL — test verisi kontratı ihlal ediyor (§16.1) | `LE-03-emulator-suite.log.txt` |
| LE-04 | Exactly-once client ↔ emülatör (AC4/AC5/AC11) | runtime + repeatable integration | `firebase emulators:start --only auth,firestore,functions --project demo-looplet`; app `--dart-define=LOOPLET_FIREBASE_EMULATOR=127.0.0.1`; `fn-proxy.py` :5001 → :5002; "offline" = proxy `down` (functions ulaşılamaz — **uçak modu değil**) | A: offline → 1 kuyruk öğesi (pending, 0 doc); proxy pass + drain → `synced`, **1 doc** (CREATED). B: `drop` (sunucu yazdı, yanıt kayboldu) → pending; retry → ALREADY_SUBMITTED, **1 doc**, `recordedAt` aynı. C: `hold` → `inFlight` iken kill → >20 s sonra relaunch → stale sweep + başlangıç drain'i → ALREADY_SUBMITTED, **1 doc**. D: sunucuya önceki koşu (9 hamle, 3★) tohumlandı → yerel sonraki koşu (12 hamle) → ALREADY_SUBMITTED, sunucu **değişmedi**, kuyruk `synced`, yerel first-run 12; ikinci yerel tamamlanma → `daily_attempt` #2, yeni kuyruk öğesi yok. E: `daily_sync_enabled=false` → öğe `pending a=0`, drain dahil **hiç istek yok**. | `LE-04-cases.txt`, `LE-04-proxy.log.txt`, `LE-04-emulators.log.txt`, `LE-04-app*.log.txt` |
| LE-05 | Ownership / lifecycle (F08.LIFECYCLE) | runtime | L1: proxy `slow` (4 s) + "produce + leave" (ekran hemen pop). L2: proxy down → öğe; HOME (paused) → drain denemesi; arka planda due; foreground (resumed, aynı PID) → drain | L1: 08:52:26Z'de Home görünür (debug ekranı dispose edilmiş), öğe `inFlight`, 0 doc → 08:52:27.3Z doc yazıldı, `synced`. L2: HOME'da istek 08:54:33Z (paused drain); foreground'da 08:56:40Z CREATED → `synced` (Runner[54932] boyunca aynı). Connectivity regain: simülatörde host ağı değişmeden tetiklenemiyor — otomatik test + N-REGAIN (FE13 §17) | `LE-05*`, `LE-04-cases.txt` (L1b, L2a–c) |
| LE-06 | Storage-full runtime (F08.STORAGE) | repeatable integration | Debug hook eklenmedi; kanıt Part 1 harness'ı (gerçek dosya DB, üretim bağlantısı) + N-FULL / N-FULL-FATAL | PASS (harness) | FE13 §17 |
| LE-07 | Production-shaped cold boot (startup impact) | runtime-video | emülatör define'sız debug build; `ev-f08.sh coldrec`; `video-d2.swift trace` tam kare luma | Boş store (final, 07c): iOS açılış zoom'undan sonra (2.45 s) ilk Home karesine (4.63 s) kadar maks. ortalama luma **18.0**; Home dinlenmede 45.2; yeni guest + `firebaseUid` alındı. Mevcut store (final, 07d, 20/30 + seviye 21 oturumu): maks **17.9** (ilk Home karesi 3.59 s), dinlenmede 49.1, "Seviye 21 · sürüyor". İlk FE13 build'i (07a/07b): 18.4 / 17.9. Açık kare yok; init hatası log'u yok. | `LE-07*`, `raw/*.mov`, `raw/*-trace.csv` |
| — | Offline Journey (AC2, F08.OFFLINE-JOURNEY) | runtime | **Koşulmadı.** Gerçek ağsız runtime gerekiyor; ağ ayarını değiştiremem. Kullanıcı için `evidence/offline-journey.sh <udid>` hazır (Wi-Fi kapat → offline doğrula → oyna → store oku → offline relaunch → Wi-Fi aç; define'sız debug build) | PENDING | — |
| — | Clock (AC10) | automated | değişmedi — yalnız otomatik (host saati sistem ayarı) | — | mevcut `elapsed_timer_test` |

**İzolasyon / sınırlar:** tüm runtime debug build (profile/release capture FIRST-APP-DISTRIBUTION'da); "offline" sync yolu için proxy ile simüle; emülatör vakaları öncesi simülatör keychain'i sıfırlandı; `firestore.rules` bayt-özdeş kopya ile koşuldu; hiçbir gerçek Firebase projesine yazma, deploy, billing veya Remote Config değişikliği yok (production-shaped cold boot'un anonim girişi FE12'den beri mevcut davranış).

## Pending Evidence güncellemesi (kendi kayıtlarım)

* **F08.UNREADABLE-DB:** teslim kanıtı tam (LE-01, LE-01c, LE-01d + otomatik testler + N-CLASS / N-LOOP / N-RETRY / N-QUAR). QA incelemesi bekliyor → Result: PENDING (QA review).
* **F08.STORAGE:** PASS — repeatable integration harness + negatifler; runtime hook yok (brief'in izin verdiği biçimde).
* QA-owned kayıtlara (F08.EMULATOR, F08.LOCAL-RESUME, F08.LIFECYCLE, F08.COLD-BOOT-REVIEW, F08.OFFLINE-JOURNEY) yalnız teslim kanıtı notu eklendi.

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** F08-FE13, F08-LOCAL-EVIDENCE.
* **Remaining Tasks:** Tech Lead checkpoint (delivery reconciliation: §4 migration transaction, §16 bulguları) → F08-QA-FUNCTIONAL planı; F08.OFFLINE-JOURNEY kullanıcı runtime'ı bekliyor; backend test verisi düzeltmesi (Backend Developer).
* **Blockers:** yok (release stage F08.DEPLOY-AUTHORIZATION ile ayrıca bekliyor).
* **Status Suggestion:** Needs Tech Lead Review.

## 19. Sonraki Komut

```
Run Tech Lead
```
