# F08 — offline-persistence-and-sync: Technical Analysis

> Role: Technical Analyst · Date: 2026-09-06 · Feature: F08 offline-persistence-and-sync
> Primary input: `features/f08-offline-persistence-and-sync/prd.md`. Supporting: `product-prd.md` §5/§6/§7/§11/§12/§15/§16/§51, `platform.md` §3–§8/§11, `features/f02-grid-engine/architecture.md`, `features/f08-.../architecture.md` (skeleton), `system-state.md`, `feature-board.md`, `setup-manifest.md`.
> This document is analysis only — it makes **recommendations**, not final architecture / scope / orchestration decisions. Those belong to the Tech Lead (`architecture.md` + `orchestration.md`).

---

# 1. Feature Summary (Technical View)

F08 is Infrastructure. It delivers two coupled but separable capabilities:

1. **On-device persistence layer** (`app/`, Drift/SQLite): a write-through store for (a) the *active puzzle session* as a single transactional snapshot, and (b) durable domain data — journey progress, per-level personal bests, daily first-run results, daily streak, settings, guest identity. Forward-only schema migrations that never drop bests/streak. Every player-owned row carries a stable local guest key so a future account can adopt the data without a destructive migration.
2. **Deferred offline-result sync**: a client `sync_queue` that delivers offline daily results to the server **exactly once**, with **first-run-authoritative** reconciliation (a later offline run never displaces an earlier recorded first run). The server surface is minimal — one write path guarded by Firebase Anonymous Auth + App Check. The local result is always authoritative for the player's own experience regardless of sync state.

System-level work:

* Define the Drift schema + migration policy.
* Define the **active-session snapshot contract** now — F03 (play session) will design its state model to serialize into it.
* Build a **session-level** persistence + connectivity + sync service (owned by an app-level singleton, never by a screen — `platform.md` §7).
* Stand up the minimal Firebase backend (`infra/` DURUM 0): the sync callable (or a create-only Firestore write), Firestore security rules, App Check config, a Remote Config key placeholder for F07.
* Wire Firebase client packages into `app/`.
* Establish the exactly-once + reconciliation semantics that F07 and F12 will reuse.

F08's own dependency is only the **F02 state shape** (Done). Its sync half is the plug F07 later connects the real Daily producer to.

---

# 2. User Stories

F08 is Infrastructure; stories are framed as the player value the system guarantees.

* **As a** player mid-puzzle, **I want** my exact game state saved continuously, **so that** killing or backgrounding the app never costs me progress.
* **As a** player with no connectivity, **I want** the entire Journey to load and record progress, **so that** I can play on a plane or a subway.
* **As a** player who pre-loaded today's Daily, **I want** to play it offline and have it count, **so that** a missed connection doesn't break my streak.
* **As a** player who finished a Daily offline, **I want** the result to reach the server exactly once when I reconnect, **so that** there are no duplicates and my first run stays official.
* **As a** returning player after an app update, **I want** my bests and streak preserved, **so that** an update never feels like a reset.
* **As a** guest (no account), **I want** my data structured so a future sign-in can claim it, **so that** I don't lose history when accounts arrive.

---

# 3. Acceptance Criteria

Carried verbatim from `prd.md §Acceptance Criteria` and made testable at the backend + client seam. Each maps to a QA scenario in §16.

| # | Given / When / Then | Backend behavior | Client behavior |
| --- | --- | --- | --- |
| AC1 | **Given** a puzzle in progress, **When** the app is killed and relaunched, **Then** grid, move count, undo history, thawed tiles, and elapsed time are exactly restored. | — | On every applied move / undo / restart / thaw / timer tick boundary, the active-session snapshot is committed in one transaction. On launch, the snapshot is read, a `GridEngine` is reconstructed from `puzzleId` + `appliedMoves`, `thawedCells` re-derived by replay, counters + accumulated elapsed restored. |
| AC2 | **Given** no network, **When** the player plays Journey, **Then** all levels load and progress saves. | — | Journey content is bundled/local (F05/F06 artifacts under `content/`); no network read on the play path. `journey_progress` + `personal_best` writes are local-only and never await the network. |
| AC3 | **Given** a previously fetched daily and no network, **When** the player opens DAILY, **Then** it is playable. | — | A `DailyPuzzleCache` read returns the cached `Puzzle` for `(lang, date)`; if absent → a "needs connection" state (F07 UI). F08 owns the cache store; F07 owns population. |
| AC4 | **Given** an offline daily completion, **When** connectivity returns, **Then** the result is sent exactly once with no duplicate. | The write path is idempotent on `(guestId, lang, date)`; a second delivery of the same key is a no-op returning success. | On completion the result is enqueued in `sync_queue` (state `pending`). A connectivity-regain trigger drains the queue; an item transitions to `synced` **only** on an explicit server ack (created **or** already-exists). |
| AC5 | **Given** the server already holds a first-run result for that player and daily, **When** an offline run syncs, **Then** the earlier first run remains authoritative. | Server write is **create-only**; an existing doc is never overwritten; the call returns `ALREADY_SUBMITTED` (a client success). | Local `daily_entry.firstRun*` is set once at first local completion and is **immutable** thereafter; sync never mutates it. `ALREADY_SUBMITTED` marks the queue item `synced`. |
| AC6 | **Given** `app_backgrounded` fires, **When** it occurs, **Then** current state is already durably written (no data-loss window). | — | Write-through means the snapshot is already committed before `paused`; the `paused` handler performs a final flush + fsync barrier, not a first write. |
| AC7 | **Given** a storage-full / write-failure condition, **When** a save is attempted, **Then** the error is non-destructive and the last good state is preserved. | — | A failed transaction rolls back; the previous committed snapshot is intact; the failure is surfaced as a non-fatal event (logged, optional soft UI notice) — never a crash, never a partial write. |
| AC8 | **Given** a corrupt save on launch, **When** the app starts, **Then** it falls back to the last valid checkpoint or a clean state without crashing, and logs. | — | Snapshot read is defensive: schema/JSON/内容 validation; on failure, discard the active snapshot (durable domain tables are separate and unaffected), start at a clean menu state, log a `save_corrupt_recovered` diagnostic. |
| AC9 | **Given** a schema-version upgrade between releases, **When** the app launches, **Then** the store migrates forward and no personal best or streak is lost. | — | Drift `MigrationStrategy.onUpgrade` runs ordered steps; a guard assertion + migration test proves `personal_best`, `daily_streak`, `daily_entry` first-run rows survive every step; migrations are additive/transform-only, never `DROP`/`DELETE` on those tables. |
| AC10 | **Given** the device clock changes mid-session, **When** elapsed time is measured, **Then** it is unaffected. | — | Elapsed measured with a monotonic `Stopwatch`; persisted as accumulated `elapsedMs`; on resume the stopwatch restarts and adds to the accumulated value. Wall clock is never read for elapsed. |
| AC11 | **Given** a partial sync (network drop mid-request), **When** retried, **Then** the retry is idempotent — no duplicate server record. | Same `(guestId, lang, date)` key → create-only → second attempt is a no-op success. | An item stuck in `inFlight` past a timeout is returned to `pending` for retry; the idempotency key guarantees safety. |
| AC12 | **Given** any player-owned row, **When** written, **Then** it carries a `guestId` enabling future account adoption without a destructive migration. | — | Every player-owned table has a non-null `guestId` column (local stable UUID); no logic keys on a device id; account adoption is a future forward migration that sets an `accountId` alongside the retained `guestId`. |

---

# 4. Functional Breakdown

## 4.1 Persistence store (Drift)

* **Schema definition** — typed tables for durable domain data + one `kv` row for the active-session JSON snapshot (`platform.md` §5 names this pattern explicitly).
* **DAO layer** — one repository per aggregate (`JourneyProgressRepo`, `PersonalBestRepo`, `DailyRepo`, `SettingsRepo`, `PlayerRepo`, `ActiveSessionRepo`, `SyncQueueRepo`).
* **Write-through discipline** — every domain mutation goes through a repo method that commits before returning; no in-memory-only state that isn't also persisted.
* **Migration strategy** — `schemaVersion` integer; ordered `onUpgrade` steps; never-drop guard on bests/streak/first-run.
* **Corruption / failure handling** — defensive reads, transactional writes, rollback-safe, diagnostic logging.

## 4.2 Active-session snapshot

* **Serialize** the in-progress puzzle to a fixed JSON shape (see §6.2) on every state-change boundary.
* **Restore** on launch: rebuild `GridEngine` from `puzzleId` + `appliedMoves`; re-derive `thawedCells`; restore counters + accumulated elapsed; hand a hydrated session to F03.
* **Clear** on puzzle completion / abandonment (F03 decides "abandon"; F08 exposes `clearActiveSession()`).

## 4.3 Guest identity

* Generate a local stable `guestId` (UUID v4) on first launch, persist in `player`.
* Obtain the Firebase Anonymous UID asynchronously; persist as `player.firebaseUid` when available.
* The sync payload / Firestore path key is `firebaseUid`; the local durable key is `guestId`. **(See §17 — this decouples two things `platform.md §6` currently equates; a Tech Lead reconciliation point.)**

## 4.4 Offline Daily cache (thin, F08-owned store; F07 populates)

* `DailyPuzzleCache`: `put(lang, date, Puzzle)`, `get(lang, date) -> Puzzle?`, `evictOlderThan(days)`.
* F08 owns the table + interface; F07 owns fetch + when-to-populate + eviction policy values.

## 4.5 Deferred sync

* `DailyResultSyncService` (session-level singleton):
  * `enqueue(DailyResultPayload)` — writes a `sync_queue` row (`pending`) + sets `daily_entry.syncStatus = queued`.
  * connectivity listener → `drain()` on regain; also `drain()` on `AppLifecycleState.resumed` and after a successful foreground call.
  * `drain()` processes `pending` items oldest-first, respecting `nextAttemptAt`: mark `inFlight` → call server → on ack mark `synced` (+ `daily_entry.syncStatus = synced`) → on retryable error bump `attemptCount`, set `nextAttemptAt` via backoff, back to `pending` → on `attemptCount >= cap` mark `parked`.
  * never blocks or is cancelled by screen disposal.

## 4.6 Reconciliation

* Local first-run is written once and is immutable.
* Server is create-only; `created` and `ALREADY_SUBMITTED` are both terminal successes for the queue item.
* No read-back / merge in the MVP (no leaderboard) — the server record and the local record never need to be reconciled *into each other*; "first-run-authoritative" is enforced independently on each side (local: immutability; server: create-only).

## 4.7 Firebase backend (`infra/`)

* Callable `submitDailyResultV1` (recommended) — validates, enforces App Check, does the create-only Firestore write, returns a typed result.
* `firestore.rules` — `dailyResults/**` create-only for own uid, no update/delete/cross-read.
* App Check — soft-enforce (monitor) for MVP.
* Remote Config — create `daily_manifest_url` key (empty/placeholder) so F07 has it.

## 4.8 App wiring

* Add Firebase client packages to `app/pubspec.yaml` (`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_app_check`, `cloud_functions` if callable).
* Bootstrap Firebase + Anonymous sign-in + App Check activation in app init, non-blocking, offline-tolerant.

---

# 5. API Requirements (Contract Base)

**Recommendation: one HTTPS Callable function.** (Alternative — direct create-only Firestore write — analysed in §17.)

## Endpoint

* **Type:** Firebase HTTPS Callable (2nd gen), name `submitDailyResultV1`
* **Auth:** Firebase Anonymous Auth required (`context.auth.uid`); App Check token attached (soft-enforced in MVP)
* **Description:** Records the caller's **first completed run** for a given daily puzzle. Create-only, idempotent on `(uid, lang, date)`.

## Request

```json
{
  "lang": "tr",
  "dailyDate": "2026-09-06",
  "dailyId": "daily-tr-2026-09-06",
  "moves": 14,
  "optimalMoves": 9,
  "durationMs": 83210,
  "stars": 2,
  "completedAtUtcMs": 1757145600000,
  "clientAttemptNumber": 1
}
```

| Field | Req | Rule |
| --- | --- | --- |
| `lang` | yes | in supported set (`tr`, `en`) |
| `dailyDate` | yes | matches `^\d{4}-\d{2}-\d{2}$` (device-local date) |
| `dailyId` | yes | non-empty string |
| `moves` | yes | int, `optimalMoves <= moves` |
| `optimalMoves` | yes | int, `>= 1` |
| `durationMs` | yes | int, `>= 0` |
| `stars` | yes | int `1..3` |
| `completedAtUtcMs` | yes | int epoch millis, `> 0` |
| `clientAttemptNumber` | no | int `>= 1`; informational; server only records first-run |

`uid` is **not** in the body — taken from `context.auth`.

## Response

**Success — created:**
```json
{ "status": "CREATED", "recordedAt": 1757145601000 }
```

**Success — already recorded (reconciliation: earlier first run wins):**
```json
{ "status": "ALREADY_SUBMITTED", "recordedAt": 1757058000000 }
```

**Error** (callable error shape, `platform.md` §4 codes):
```json
{ "code": "INVALID_PAYLOAD", "message": "durationMs must be >= 0", "details": [] }
```

| `code` | When | Client action |
| --- | --- | --- |
| `INVALID_PAYLOAD` | shape / range / cross-field validation fails | **park** the item (non-retryable) + log; local result unaffected |
| `UNSUPPORTED_LANGUAGE` | `lang` not in set | park + log |
| `APP_CHECK_FAILED` | hard-enforce only (not MVP); soft-enforce logs and proceeds | retry a bounded number of times, then park |
| `INTERNAL` | unexpected server error | retryable with backoff |
| _(transport error / timeout)_ | offline, 10s client timeout, 5xx | retryable with backoff; `inFlight`→`pending` |

## Firestore document written (server-side, not client-writable directly)

Path: `dailyResults/{lang}_{dailyDate}/entries/{uid}` — **create-only**
```json
{
  "uid": "…", "lang": "tr", "dailyDate": "2026-09-06", "dailyId": "daily-tr-2026-09-06",
  "moves": 14, "optimalMoves": 9, "durationMs": 83210, "stars": 2,
  "completedAtUtcMs": 1757145600000, "recordedAtUtcMs": 1757145601000
}
```
Ordered-query-ready for a future leaderboard by `{lang, dailyDate}` → `moves` asc, `durationMs` asc.

---

# 6. Data Model (Conceptual)

## 6.1 Durable tables (Drift)

| Table | Key | Fields (high-level) | Notes |
| --- | --- | --- | --- |
| `player` | `guestId` (UUID, PK) | `guestId`, `firebaseUid?`, `createdAtUtcMs` | one row; `firebaseUid` filled async; future `accountId?` added by migration |
| `settings` | `guestId` | `soundEnabled`, `hapticsEnabled`, `language` | defaults on first run; §15 `Settings` |
| `journey_progress` | `guestId` | `highestUnlockedLevel`, `completedLevelsCsv` (or a child table `journey_level_completed`) | §15 `JourneyProgress`; written by F05 |
| `personal_best` | `(guestId, levelId)` | `bestMoveCount` (only decreases), `stars`, `isPerfect`, `firstCompletedAtUtcMs` | §15 `PersonalBest`; written by F04; **never dropped by a migration** |
| `daily_entry` | `(guestId, lang, dailyDate)` | `dailyId`, `firstRunMoveCount`, `firstRunDurationMs`, `firstRunStars`, `firstRunCompletedAtUtcMs`, `syncStatus` (`local`/`queued`/`synced`/`parked`) | §15 `DailyEntry`; first-run fields **immutable once set**; **never dropped** |
| `daily_attempt` | `(guestId, lang, dailyDate, attemptNo)` | `moveCount`, `durationMs`, `stars`, `completedAtUtcMs` | replay attempts, personal only; attemptNo ≥ 2 |
| `daily_streak` | `guestId` | `currentStreak`, `bestStreak`, `lastCompletedDate` (`YYYY-MM-DD`) | §15 `DailyStreak`; rule owned by F07, storage by F08; **never dropped** |
| `daily_puzzle_cache` | `(lang, dailyDate)` | `puzzleJson`, `fetchedAtUtcMs` | F08 store; F07 populates/evicts |
| `sync_queue` | `id` (PK) | `kind`, `idempotencyKey`, `payloadJson`, `state`, `attemptCount`, `nextAttemptAtUtcMs`, `lastError?`, `createdAtUtcMs`, `updatedAtUtcMs` | see §6.3 |
| `kv` | `key` (PK) | `key`, `valueJson`, `schemaVersion` | holds `active_session` (§6.2) + `store_meta` |

`analytics_event_buffer` and `sync_queue`-for-analytics are **F12's** — F08 sets the pattern only.

## 6.2 Active-session snapshot — `kv['active_session'].valueJson` (CONTRACT — F03 designs to this)

```json
{
  "snapshotVersion": 1,
  "puzzleId": "journey-tr-14",
  "puzzleSource": "journey",
  "lang": "tr",
  "appliedMoves": ["R0", "D2", "L4", "U1"],
  "moveCount": 4,
  "undosRemaining": 2,
  "restartCount": 1,
  "elapsedMsAccumulated": 41200,
  "thawedFrozenCells": ["4,4"],
  "status": "inProgress",
  "startedAtUtcMs": 1757145000000,
  "lastPersistedAtUtcMs": 1757145041200
}
```

* **`appliedMoves`** — the ordered applied-`Move` list in F06 shorthand (`R<i>`/`L<i>`/`D<i>`/`U<i>`). This **is** the undo history: F02's `undo` re-folds from t=0, so no separate undo stack is stored (see §17 modeling note vs `product-prd §15 PlaySession.undoHistory`).
* **`undosRemaining`** — the F03 3-undo quota; not an engine concept; stored explicitly.
* **`restartCount`** — stored explicitly (engine doesn't track it).
* **`thawedFrozenCells`** — **cache only**; on restore, authority is re-derived by replaying `appliedMoves` through the engine (F02 integration rule: "`thawedCells` is not persisted as authority"). Stored so a UI can render instantly pre-replay.
* **`elapsedMsAccumulated`** — monotonic; resume adds a fresh `Stopwatch` delta.
* **`puzzleId` → `EngineConfig`** — resolved via the `Puzzle` artifact (journey: local content; daily: `daily_puzzle_cache`) + a consumer-side `Puzzle → EngineConfig` (the helper F06 QA flagged for F05/F07/F08 — F08 needs it here).

## 6.3 `sync_queue` item states

`pending` → `inFlight` → `synced` (terminal, success) · `pending`/`inFlight` → `pending` (retry, backoff) · `pending` → `parked` (terminal, attempt cap hit or non-retryable error). `parked` items are retained for diagnostics; local result stays authoritative.

## 6.4 Relationships

* `player 1—1 settings`, `1—1 journey_progress`, `1—1 daily_streak`, `1—* personal_best`, `1—* daily_entry`, `1—* daily_attempt`, `1—* sync_queue`.
* `daily_entry 1—* daily_attempt` (by `(lang, dailyDate)`).
* `daily_entry —(produces)→ sync_queue` item on first completion (1—0..1).
* `daily_puzzle_cache` is player-independent (shared content), keyed by `(lang, dailyDate)`.

---

# 7. Validation Rules

## 7.1 Input Validation

**Snapshot read (client):** `snapshotVersion` supported; `puzzleId` non-empty; `appliedMoves` is a list of valid shorthand tokens; `moveCount == appliedMoves.length`; `undosRemaining` in `0..3`; `elapsedMsAccumulated >= 0`; `thawedFrozenCells` entries match `^\d+,\d+$`. Any failure → discard snapshot, clean-state recovery (AC8).

**Sync payload (client, before enqueue):** `optimalMoves >= 1`; `optimalMoves <= moves`; `durationMs >= 0`; `stars in 1..3`; `dailyDate` matches date regex; `lang` supported. A payload that fails here is a programming error — assert in debug, drop + log in release (do not enqueue an invalid item).

**Sync payload (server, callable):** re-validate all of the above; `context.auth` present; App Check evaluated (soft). Fail → `INVALID_PAYLOAD` / `UNSUPPORTED_LANGUAGE`.

## 7.2 Business Validation

* **First-run immutability:** if `daily_entry(guestId, lang, dailyDate)` exists with first-run fields set, a subsequent completion writes a `daily_attempt` row only — never touches first-run fields, never enqueues a second `sync_queue` item for that key.
* **Personal best monotonicity:** `personal_best.bestMoveCount` is written only if the new count is strictly lower (or no row exists). `isPerfect = bestMoveCount == optimalMoves`.
* **Streak storage:** F08 writes `daily_streak` exactly as F07 computes it; F08 does not independently increment/reset. `lastCompletedDate` is a plain local-date string.
* **Idempotency:** `sync_queue.idempotencyKey = "{firebaseUid}|{lang}|{dailyDate}"`; the queue rejects a second `enqueue` with an existing non-`parked` key for the same fact.
* **Migration guard:** every `onUpgrade` step is asserted not to reduce row counts of `personal_best` / `daily_streak` / `daily_entry`; a migration test seeds v(N-1), upgrades, and checks all first-run/best/streak data intact.
* **Create-only (server rule):** `allow create` iff `request.auth.uid == uid` in path and the doc does not exist; `allow update, delete: if false`; `allow read: if false` (MVP — no cross-user read).

---

# 8. Edge Cases

| Case | Expected behavior |
| --- | --- |
| App killed **during** a write | Transaction not committed → store at last committed state on next launch. No torn snapshot. |
| Storage full / disk write error | Transaction rolls back; last good state intact; non-fatal `persist_failed` event; no crash. Repeated failure → surface a soft UI notice (F10/F03 copy), keep playing from memory, retry on next boundary. |
| Corrupt `active_session` JSON on launch | Discard active snapshot only; durable tables unaffected; land on menu; log `save_corrupt_recovered`. |
| Corrupt durable table / unreadable DB file | Drift open fails → attempt Drift's recovery; if unrecoverable, recreate DB (accepted data loss, logged, extremely rare) — never crash-loop. **Flag for Tech Lead:** is full-DB-loss acceptable in MVP or is a periodic backup copy warranted? (§17) |
| Schema upgrade v1→v2 mid-rollout | Forward migration runs once on first launch of the new binary; bests/streak/first-run preserved (AC9). |
| **App version rollback** (v2 binary → v1 binary) | Forward-only migrations mean a v2 DB may be unreadable by v1. Not supported. Mitigation: staged rollout + migration tests; document that store downgrades are not supported. (§12, §17) |
| Device clock jumps forward/backward mid-session | Elapsed unaffected (monotonic `Stopwatch`). Timestamps use `DateTime.now().toUtc()` millis — a wrong wall clock yields a wrong `completedAtUtcMs`; acceptable in MVP (no server-side clock trust; F07 owns any streak-integrity policy). |
| Concurrent writes: autosave tick + explicit "undo" at the same frame | All writes go through the same serialized Drift executor; last transaction wins; snapshot is always internally consistent (single-row commit). |
| Network drops mid-request | Item left `inFlight`; a stale-`inFlight` sweep (age > 2×client timeout) returns it to `pending`; create-only + idempotency key make the retry safe (AC11). |
| Daily completed offline, then completed again offline before any sync | First completion → first-run + one queue item. Second → `daily_attempt` row only. One sync, one server doc. |
| Connectivity returns → drain starts → app backgrounded mid-drain | Sync service is session-level; survives; `paused` handler lets the in-flight call finish or times out; remaining items stay `pending`; drain resumes on `resumed`/next connectivity event. |
| `sync_queue` item fails `attemptCap` times | → `parked`; `daily_entry.syncStatus = parked`; local result fully intact; a manual/next-app-start retry of parked items is allowed but rate-limited. |
| Firebase Anonymous sign-in never completes (persistent offline) | Local `guestId` still generated; play + local persistence fully functional; `sync_queue` items wait (no `firebaseUid` → cannot build idempotency key / path) in a `pending` sub-state `awaitingAuth`; drained once auth completes. |
| Two devices, same future account (not MVP) | No device-scoped keys; `guestId` is per-install; account adoption later merges by `accountId`. Model must not assume single device — satisfied by keying on `guestId`, not a device id. |
| `daily_puzzle_cache` miss offline | F07 shows "needs connection"; Journey unaffected. |
| Empty / first-ever launch | `player` + `settings` + `journey_progress` + `daily_streak` seeded with defaults in one bootstrap transaction; no active session; land on menu/onboarding (F09). |
| Undo history longer than expected (many undos+redos) | `appliedMoves` only ever holds **applied** moves (F02: rejected moves and undo don't append); list length ≤ realistic move count; no unbounded growth. |

---

# 9. Error Scenarios

| Scenario | Detection | Response | Code / signal |
| --- | --- | --- | --- |
| Snapshot write fails (disk) | Drift throws on commit | rollback; keep last good; non-fatal event; retry next boundary | `persist_failed` (local diagnostic) |
| Snapshot read invalid | validation in `ActiveSessionRepo.read()` | discard active snapshot; clean recovery | `save_corrupt_recovered` |
| DB open fails | Drift open throws | recovery attempt → recreate as last resort | `db_reinitialized` |
| Migration step throws | `onUpgrade` exception | abort migration, do not partially apply; keep old DB; block launch with a recoverable error screen; log | `migration_failed` (**must not silently wipe**) |
| Sync: transport error / 5xx / timeout | callable future error | `attemptCount++`, backoff, `pending` | retryable |
| Sync: `INVALID_PAYLOAD` / `UNSUPPORTED_LANGUAGE` | callable error code | `parked` (non-retryable); log for investigation; local result unaffected | non-retryable |
| Sync: `ALREADY_SUBMITTED` | callable success variant | `synced`; `daily_entry.syncStatus = synced` | success (reconciliation) |
| Sync: `APP_CHECK_FAILED` (if hard-enforced later) | callable error code | bounded retries → `parked` | retryable-bounded |
| Anonymous auth error (not offline, actual failure) | `FirebaseAuthException` | retry with backoff at app level; persistence + play unaffected; sync waits | `auth_anon_failed` |
| Enqueue of invalid payload | client pre-validation | assert(debug) / drop+log(release); never enqueue | programming error |

Guiding rule: **no server or storage error is ever allowed to lose or mutate the local authoritative result, or crash the app.** Local-first, always.

---

# 10. Client / UI Expectations — Frontend

F08 ships **no screens**. Its client surface is services + repositories consumed by other features. UI expectations are the hooks it must provide:

* **Boot:** an app-init step opens the DB, runs migrations, seeds defaults, reads the active snapshot, initializes Firebase (non-blocking), starts the sync service. A migration-failure recoverable error screen is the only F08-owned UI (minimal, text; no design handoff needed).
* **Loading state:** app init shows the existing launch/splash until the DB is open + snapshot read (fast, local). No spinner for sync — it is always background.
* **Error state:** storage-full → a non-blocking soft notice (copy owned by F03/F10); migration-failure → recoverable error screen with a "retry" affordance; corrupt-save → silent recovery to menu.
* **Empty state:** first launch → defaults seeded → normal menu/onboarding; no F08-specific empty UI.
* **Validation UX:** none (no user input).
* **User flow:** transparent. The player never sees "saving"; resume is instant on next launch.
* **Header / top bar:** n/a.
* **Back button:** n/a (the migration error screen is a root, not a pushed route).
* **Consumed by:** F03 (`ActiveSessionRepo`), F04 (`PersonalBestRepo`), F05 (`JourneyProgressRepo`), F07 (`DailyRepo`, `DailyPuzzleCache`, `DailyResultSyncService`), F10 (`SettingsRepo` + read models for streak/progress), F12 (its own buffer, same pattern).

---

# 11. Integration Rules

* **Backend → client mapping:** callable `status` → queue transition: `CREATED`/`ALREADY_SUBMITTED` → `synced`; error `code` → retryable (`INTERNAL`, transport) vs non-retryable (`INVALID_PAYLOAD`, `UNSUPPORTED_LANGUAGE`) → `parked`.
* **Field naming:** JSON `lowerCamelCase` everywhere (`platform.md` §4). Dates: `dailyDate` = local `YYYY-MM-DD`; all instants = UTC epoch millis with a `UtcMs` suffix. Durations = integer millis.
* **Null handling:** optional fields omitted, never `null` (`platform.md` §4). `firebaseUid` absent until auth completes — represented as a missing column value, and code paths branch on presence.
* **Error handling consistency:** callable errors use `{code,message,details}` (`platform.md` §4). Client never throws on a sync failure — it records queue state.
* **State consistency:** `daily_entry.syncStatus` is a **denormalized mirror** of the `sync_queue` item state for that key; both are updated in the **same transaction** on every transition. The queue is the source of truth for "work to do"; `syncStatus` is for display.
* **Navigation-affecting state:** `kv['active_session'].status` — `inProgress` means F10's CONTINUE is enabled and routes into F03 with the hydrated session; absent/`completed` means CONTINUE is hidden/disabled. `journey_progress.highestUnlockedLevel` drives F05's CONTINUE target. `daily_entry` presence for today drives F07's DAILY state (playable / already-done / needs-connection).
* **Which action sets/resets persisted fields:**
  * `active_session` — set by F03 on every applied move/undo/restart/timer boundary; cleared by F03 on completion or explicit abandon (`clearActiveSession()`).
  * `personal_best` — set by F04 on completion if improved.
  * `journey_progress` — set by F05 on level completion (unlock N+1).
  * `daily_entry` first-run — set once by F07 on first daily completion; `daily_attempt` appended on replays.
  * `daily_streak` — set by F07 per its rule on daily completion and on rollover evaluation.
  * `settings` — set by F10.
  * `sync_queue` — `enqueue` by F07 on first daily completion; transitions by `DailyResultSyncService`.
* **All entry paths to a restored session:** cold launch, background→foreground (`resumed`), post-migration first launch — all go through the same `ActiveSessionRepo.read()` + engine-replay path; none bypasses re-derivation of `thawedCells`.
* **Enum exhaustiveness:** `syncStatus` (`local`/`queued`/`synced`/`parked`) and `sync_queue.state` (`pending`/`inFlight`/`synced`/`parked`) must be handled exhaustively by consumers (sealed/`switch` with no default that hides a new case).
* **Route graph:** n/a (no F08 routes). The migration-error screen is a conditional root before the normal `go_router` tree.
* **Session-level ownership (`platform.md` §7):** `DailyResultSyncService` + connectivity listener are constructed once at app start and disposed only at app termination. **No screen** may hold, cancel, or recreate them. QA must verify a screen dispose mid-sync does not stop the sync.

---

# 12. Non-Functional Considerations

## Performance

* Write-through must be cheap: the active snapshot is a single `kv` row upsert (~one small JSON blob, < 1 KB) inside one transaction — target < 5 ms on a mid device, comfortably within a move's 150–250 ms animation window. Not on the UI-critical frame path (persist after the move settles, `platform.md` §7 `paused` also flushes).
* Restore replay: ≤ ~30 engine `applyMove` calls (realistic max move count) — sub-millisecond (F02 is allocation-disciplined for F06's millions-of-states search).
* Sync is fully background; no user-perceived latency; 10 s callable timeout.
* Migrations run once per upgrade at launch; keep steps O(rows) and bounded (MVP data is tiny — tens of rows).

## Security

* No PII stored or transmitted (`platform.md` §8). `guestId`/`firebaseUid` are opaque.
* Firestore create-only rule + App Check are the only abuse controls (MVP; `platform.md` §6). No custom rate limiter.
* The callable trusts `context.auth.uid` for the path — a client cannot write another uid's entry.
* App Check soft-enforce: attestation failures are logged, not blocked, in MVP.
* No secrets in the repo — Firebase config is not secret; the callable needs no additional secret (`platform.md` §8).

## Scalability

* Firestore layout (`dailyResults/{lang}_{date}/entries/{uid}`) is leaderboard-ready (query by partition, order by `moves`,`durationMs`) without a schema change — satisfies `product-prd §12.7` "no destructive migration for a future leaderboard".
* Guest schema with `guestId` on every player row + no device-scoped keys → future account adoption is an additive forward migration.

## Release / Deployment / Rollback

* **First Firebase deploy for LOOPLET.** Surface: 1 callable function (`submitDailyResultV1`), `firestore.rules`, `firestore.indexes.json` (composite index for the future leaderboard query — optional now, cheap to add), App Check config, a Remote Config `daily_manifest_url` placeholder.
* **Environment topology:** `platform.md`/`release.md` do not mandate multi-project. **Recommendation:** one Firebase project for the MVP validation build; a separate prod project only if `release.md` requires it. (Tech Lead + DevOps/Release Engineer decision — §17.)
* **Rollback:** functions → redeploy previous version; rules → revert the repo file + redeploy; Remote Config → repoint. **DB migration rollback is NOT supported** (forward-only) — mitigation is migration tests + staged rollout + the never-drop guard; a bad migration is a forward-fix, not a downgrade.
* **Expected `Release Scope`:** `production-readiness` + `rollback-readiness` (functions/rules deploy readiness + migration rollback-readiness). A `DevOps/Release Engineer` task opens **after QA**.
* CI: add `infra/` function build + rules-unit-tests + (optionally) an emulator integration job.

---

# 13. Dependencies

## External services

* **Firebase**: Anonymous Auth, Cloud Firestore, App Check, Cloud Functions (if callable), Remote Config (placeholder key). Provisioned by an `infra/` **Project Setup DURUM 0** (`setup-manifest.md` Workspace Targets → `infra/`; `platform.md` §3).
* **Connectivity signal**: `connectivity_plus` (or equivalent) for regain-triggered drain — add to `app/pubspec.yaml`. (Not in the current setup manifest dep list → a Tech Lead dep addition, §17.)

## Internal modules

* **F02 `looplet_engine`** (Done) — `EngineConfig`, `GridEngine(config, validator)`, `appliedMoves`, `applyMove`, replay for `thawedCells` re-derivation. A `restoreMoves(List<Move>)` batch API on `GridEngine` is listed as an F02 "Open Technical Decision" — **F08 should request it now** (non-breaking; makes resume clean).
* **F06 `looplet_content`** — `Puzzle` model + JSON (for `daily_puzzle_cache` and resolving `puzzleId`). Needs the consumer-side `Puzzle → EngineConfig` helper F06 QA flagged (F08 is a first consumer).
* **F03** (Not Started) — produces the `PlaySession` that serializes into the active snapshot; F08 defines the shape, F03 conforms. No code dependency now; contract dependency.
* **F07** (Not Started) — real Daily producer + streak rule + rollover; plugs into `DailyRepo` + `DailyResultSyncService` + `DailyPuzzleCache`. **F08 does not depend on F07**; F07 depends on F08.
* **F12** — reuses the offline-buffer + exactly-once pattern for analytics; its own table.
* **Drift toolchain** — `drift`, `sqlite3_flutter_libs`, `drift_dev`, `build_runner` already in `app/pubspec.yaml` (`setup-manifest.md` Step 6). `build_runner` codegen is currently "off for MVP" for Riverpod but Drift needs it — confirm Drift codegen is run (it is standard; §14 assumption).

---

# 14. Assumptions

1. **Drift is the store** (`platform.md` §5, not reopened). Drift codegen (`build_runner`) is run for the schema — the "codegen off for MVP" note in `platform.md` §3 refers to Riverpod, not Drift.
2. **Active session as one `kv` JSON row** (not a typed table) — `platform.md` §5 explicitly describes this ("a single `kv` row updated inside a transaction"). Durable domain data is typed tables.
3. **One callable function** is acceptable infra for the MVP (vs a pure client-write design). Recommended, not locked — §17.
4. **Single Firebase project** for the MVP validation build unless `release.md` says otherwise.
5. **Anonymous Auth UID is stable per install** and survives app restarts (Firebase default: persisted). Reinstall = new UID = new guest (accepted; matches "guest-only, no account" — `product-prd §39`).
6. **`guestId` (local UUID) is the durable local key; `firebaseUid` is the server identity.** This is a *decoupling* of `platform.md §6`'s "`guestId` = anonymous UID". Flagged for Tech Lead reconciliation (§17). If the Tech Lead prefers strict equivalence, the fallback is: block sync (not play) until auth completes, then adopt the UID as `guestId`.
7. **No server-side clock/timezone anti-cheat** in the MVP (`product-prd §51` open item; App Check + create-only are the only controls). F07 owns any local streak-integrity policy.
8. **`daily_puzzle_cache` eviction policy values** (how many days retained) are F07's to set; F08 provides the mechanism.
9. **Full-DB-loss on unrecoverable corruption is tolerable** for the MVP (no cloud backup). Rare; flagged (§17) in case the Tech Lead wants a periodic snapshot copy.
10. **`connectivity_plus`-style package** may be added to `app/pubspec.yaml` (dep-list addition — Tech Lead approves per `setup-manifest.md` "no dependency deviation without a Tech Lead decision").
11. **The F08↔F07 split** (fake producer now, real producer in F07) is the intended path — mirrors the F06/F06-CONTENT split. Recommended, Tech Lead locks it.
12. **`stars` in the sync payload** is computed by F04's rule; F08/F07 pass it through. If F04 is not yet available when F08's fake-producer tests run, a stub star value is fine for the queue/reconciliation tests.

---

# 15. Open Questions

Technical points needing a decision before or at contract finalization (Tech Lead unless marked):

1. **Callable vs direct client Firestore write** for the sync surface. (Recommendation: callable — §17.)
2. **`guestId` vs `firebaseUid`** — decouple (recommended) or keep `platform.md §6` strict equivalence (block sync until auth). **Platform authority reconciliation.**
3. **Single vs multi Firebase project** for MVP (Tech Lead + DevOps/Release Engineer; `release.md`).
4. **F08↔F07 scope boundary** — ship persistence core + sync + fake producer now, F07 wires the real producer later? (Recommendation: yes, split — §17.)
5. **`infra/` DURUM 0 sequencing** — parallel with the Drift core, or strictly before all Backend work? (Recommendation: parallel — §17.)
6. **`restoreMoves(List<Move>)` batch API on `GridEngine`** — add to F02 now (non-breaking) for clean resume? (Recommendation: yes.)
7. **Unrecoverable DB corruption** — accept full local data loss (MVP) or add a periodic backup copy of durable tables?
8. **App-version downgrade** — explicitly declare "store downgrade unsupported" in release notes / `release.md`?
9. **`connectivity_plus`** (or platform channel) as a new `app/` dependency — approve.
10. **Composite Firestore index** for the future leaderboard query — add `firestore.indexes.json` now (cheap) or defer to F07/leaderboard?
11. **Parked-item retry policy** — automatic bounded retry on each app start, or manual only? (Recommendation: bounded auto-retry, e.g. once per app start, max 3 lifetime.)
12. **App Check offline behavior** confirmation — proceed-and-log in soft-enforce is assumed; confirm no MVP scenario needs hard-enforce.

---

# 16. Task Breakdown

## Backend Tasks (Firebase / `infra/`)

* **F08-BE1** — `infra/` scaffold via Project Setup DURUM 0: Firebase project config, `firebase.json`, `firestore.rules`, `firestore.indexes.json`, Functions TS project skeleton, App Check config, Remote Config template with `daily_manifest_url` placeholder. (Project Setup role; Tech Lead triggers.)
* **F08-BE2** — `submitDailyResultV1` callable: auth check, App Check (soft), payload validation (all §7 rules), create-only Firestore write at `dailyResults/{lang}_{date}/entries/{uid}`, `CREATED` / `ALREADY_SUBMITTED` / typed errors.
* **F08-BE3** — `firestore.rules`: `dailyResults/**` create-only for own uid, no update/delete/read; rules-unit-tests (`@firebase/rules-unit-testing`) for allow-create-own, deny-create-other, deny-update, deny-read.
* **F08-BE4** — Functions unit tests against the Firebase emulator: valid create, duplicate → `ALREADY_SUBMITTED`, each validation failure, missing auth.
* **F08-BE5** — CI: `infra/` build + rules tests + emulator test job wired into `.github/workflows/ci.yml`.

## Client Tasks (Frontend/Mobile Developer, `app/`)

* **F08-FE1** — Drift schema: all §6.1 tables + `kv`; `AppDatabase` with `schemaVersion = 1`; codegen.
* **F08-FE2** — `MigrationStrategy`: `onCreate` seeds defaults; `onUpgrade` step framework; **never-drop guard** on `personal_best` / `daily_streak` / `daily_entry`; a v1→v2 dummy migration + migration test harness (seed old, upgrade, assert intact).
* **F08-FE3** — Repositories: `PlayerRepo`, `SettingsRepo`, `JourneyProgressRepo`, `PersonalBestRepo` (monotonic), `DailyRepo` (first-run immutability + attempts), `DailyStreakRepo` (store-only), `DailyPuzzleCache`, `ActiveSessionRepo`, `SyncQueueRepo` — all write-through, all transactional.
* **F08-FE4** — Active-session snapshot: serialize/deserialize per §6.2 (locked keys); `save()` on state-change boundary; `read()` with full validation + corrupt-recovery; `clearActiveSession()`; restore path that rebuilds `GridEngine` (via `Puzzle → EngineConfig` + `restoreMoves`) and re-derives `thawedCells`.
* **F08-FE5** — Elapsed-time helper: monotonic `Stopwatch` accumulator, persisted `elapsedMsAccumulated`, resume-safe. Guard: no wall clock for elapsed.
* **F08-FE6** — App-init sequence: open DB → migrate → seed → read snapshot → (async, non-blocking) Firebase init + Anonymous sign-in + App Check activation → start sync service. Migration-failure recoverable error screen.
* **F08-FE7** — `DailyResultSyncService` (session-level singleton): `enqueue`, connectivity listener, `drain()` state machine (pending/inFlight/synced/parked), exponential backoff + attempt cap, stale-`inFlight` sweep, `awaitingAuth` sub-state, `daily_entry.syncStatus` mirror in the same transaction. Wired into app lifecycle (`paused` flush, `resumed` drain). **Not** owned by any screen.
* **F08-FE8** — Callable client binding + response→queue-transition mapping; typed error handling.
* **F08-FE9** — Firebase package wiring in `app/pubspec.yaml` (+ `connectivity_plus`); `firebase_options.dart` via FlutterFire CLI; init guarded for offline.
* **F08-FE10** — **Fake daily-result producer** (test/dev seam): a function that fabricates a `daily_entry` + enqueues a sync item, so the queue + reconciliation + callable path are exercised end-to-end without F07. (Removed/replaced by F07's real producer.)
* **F08-FE11** — `Puzzle → EngineConfig` consumer helper in `app/` (the F06-flagged helper); shared with F05.

## QA Tasks

* **Resume fidelity (runtime, device/emulator):** kill + relaunch at N moves with undos, a restart, and a thawed frozen tile → grid, `moveCount`, `undosRemaining`, `restartCount`, elapsed, thawed state all exactly restored; `thawedCells` proven re-derived (not trusted from cache) by a tampered-cache test.
* **Offline Journey (runtime):** airplane mode → all 30 levels load, complete a level, progress + best persist, relaunch still offline → progress intact.
* **Offline Daily (runtime):** pre-populate `daily_puzzle_cache`, go offline → Daily playable; no cache + offline → "needs connection", Journey still works.
* **Exactly-once sync (integration, emulator):** complete daily offline → 1 queue item; reconnect → 1 Firestore doc; force a mid-request drop → retry → still 1 doc; kill app during `inFlight` → relaunch → item recovered → still 1 doc.
* **First-run-authoritative (integration):** seed a server doc with an earlier run → sync a later local run → server doc unchanged, queue item → `synced`, local `firstRun*` unchanged; local second completion → `daily_attempt` row, no new queue item.
* **Migration (automated):** seed schema v1 with bests + a streak + a daily first-run → upgrade to v2 → all rows intact; never-drop guard test; corrupt `active_session` → clean recovery, durable tables intact; simulated storage-full → non-destructive, last good state kept.
* **Clock (automated + runtime):** move device clock backward/forward mid-session → elapsed unaffected.
* **Guest schema (automated):** every player-owned row has non-null `guestId`; no unique/logic key on a device id.
* **Ownership (runtime):** start a sync, navigate/dispose the screen that triggered completion → sync still completes (session-level).
* **Rules (integration):** create-own allowed; create-other denied; update/delete/read denied.
* **Evidence class:** `runtime` for resume/offline/sync-on-device; `repeatable integration` for callable + rules (Firebase emulator); `automated functional` for schema/migration/serialization units. Not `source-only` (`platform.md` §10 requires runtime proof for resume + daily behavior).

---

# 17. Delivery Note for Tech Lead

## Decisions to move into `architecture.md`

1. **Drift schema** — §6.1 table set + `kv` active-session row; `schemaVersion = 1`; forward-only `MigrationStrategy` with the explicit never-drop guard on `personal_best` / `daily_streak` / `daily_entry`.
2. **Active-session snapshot contract** — §6.2 JSON with **locked key names**; `appliedMoves` (F06 shorthand) IS the undo history (no separate stack); `thawedFrozenCells` is a cache, authority re-derived by replay on restore. F03 must design to this.
3. **`sync_queue` contract** — §6.3 states + `idempotencyKey = "{firebaseUid}|{lang}|{dailyDate}"` + ack-only `synced` transition + exponential backoff + attempt cap → `parked` + stale-`inFlight` sweep + `awaitingAuth` sub-state.
4. **Reconciliation** — local first-run immutable; server create-only; `CREATED` and `ALREADY_SUBMITTED` both terminal-success; no read-back/merge in MVP; "first-run-authoritative" enforced independently on each side.
5. **`daily_entry.syncStatus`** is a denormalized mirror of the queue item state, updated in the same transaction.
6. **Session-level ownership** — `DailyResultSyncService` + connectivity listener constructed once at app start, never screen-owned or screen-cancelled (`platform.md` §7). Put this in the contract explicitly — it is a common regression.
7. **Server contract** — the §5 callable request/response/error table, or (if the Tech Lead picks the alternative) the equivalent Firestore create-only rule contract.
8. **Migration failure never wipes** — abort-and-block-with-recovery, not silent recreate.

## Analyst Recommendation — Sync surface

* **Recommendation:** **HTTPS Callable `submitDailyResultV1`.**
* **Alternatives considered:** (a) direct client create-only Firestore write guarded purely by security rules; (b) callable function.
* **Trade-offs:**
  * *Direct write:* no Cloud Function to deploy/maintain, lowest infra. But cross-field range validation (`optimalMoves <= moves`, `durationMs >= 0`, date format) is awkward-to-unsafe in rules; the client is coupled to the exact collection layout; App Check on Firestore writes is coarser; no room for future server logic (leaderboard aggregation) without a client change.
  * *Callable:* one function + a cold-start (~hundreds of ms, irrelevant — the call is always background with a 10 s timeout and offline-queued); clean typed contract (`platform.md` §4 already anticipates `submitDailyResult`); server-side validation + App Check enforcement point; versioned (`V1` suffix) for a future breaking change; a natural home for later leaderboard writes.
  * `platform.md` §3/§4 **already names** "one RPC-style HTTPS callable: `submitDailyResult`" — the callable is the pre-blessed path; the direct write would be a deviation.

## Analyst Recommendation — F08 ↔ F07 scope boundary

* **Recommendation:** **Split, F06-style.** F08 delivers: the full persistence layer, `DailyPuzzleCache` (mechanism), `DailyResultSyncService`, the callable + rules, and a **fake daily-result producer** test seam — with end-to-end queue + reconciliation + exactly-once verified against the Firebase emulator. **F07 later** wires the real Daily fetch/cache-population/date-rollover/streak-rule and calls the same `enqueue(...)`.
* **Alternatives considered:** (a) F08 waits until F07 exists so the real Daily flow is testable; (b) fold all Daily sync into F07 and make F08 persistence-only.
* **Trade-offs:** F08's only dependency is F02 (Done); F07 depends on F08 — waiting creates a stall with nothing else P0-unblocked to do, and risks persistence being retrofitted after F03. The fake producer fully exercises the risky parts (exactly-once, reconciliation, migration, resume). (b) would leave F08 without a demonstrable sync guarantee and duplicate the queue design pressure into F07. The split keeps each feature independently verifiable and matches the precedent the team just set with F06/F06-CONTENT.

## Analyst Recommendation — `infra/` DURUM 0 sequencing

* **Recommendation:** **Parallel.** At contract finalization, the Tech Lead (1) locks the Drift schema + snapshot contract and (2) triggers the `infra/` Project Setup DURUM 0. Client tasks **F08-FE1…FE5** (schema, migrations, repos, snapshot, elapsed) need **no Firebase** and start immediately. Firebase-dependent tasks (**F08-FE6…FE9**, **F08-BE2…BE5**) gate on the DURUM 0 landing. This is critical-path-optimal.
* **Alternative:** strictly serialize (DURUM 0 fully done before any Backend/Frontend). Simpler to track, but idles the persistence core for no reason.

## Architectural risks

* **Forward-only migration + no downgrade** — a bad migration in a released build cannot be rolled back by shipping the old binary. Mitigation: migration test harness (mandatory, F08-FE2), staged rollout, never-drop guard. Tech Lead should decide whether to state "store downgrades unsupported" in `release.md`.
* **Snapshot contract churn** — F03 doesn't exist yet; if the snapshot shape is wrong, F03 forces a snapshot `snapshotVersion` bump + a `kv` migration. Mitigation: `snapshotVersion` field is already in the shape; treat a bump as a normal forward migration. Keep the shape minimal (moves + counters + ids), lean on engine replay.
* **`guestId` vs `firebaseUid` decoupling** contradicts `platform.md §6` ("`guestId` = anonymous UID"). If kept equivalent, offline-first-launch sync must wait for auth (fine — the result is queued anyway). **This is a platform-authority reconciliation the Tech Lead must make explicitly**, not leave to implementation.
* **App Check soft-enforce** — abuse surface is open in the MVP (a determined actor could post fake daily results for their own uid). Accepted per `platform.md §6` (hard-enforce deferred to F07/F08 — this *is* F08; Tech Lead should confirm soft-enforce is still the intended MVP posture or promote it here).
* **New dependency** `connectivity_plus` (or equivalent) — outside the `setup-manifest.md` dep list; needs an explicit Tech Lead approval + manifest note.

## Contract risks (watch carefully)

* `product-prd §15 PlaySession.undoHistory` reads like a separate structure; F02's design makes it equal to the applied-move list. The contract should state this explicitly so F03 doesn't build a redundant undo stack.
* `product-prd §15 DailyEntry.syncStatus` (`local`/`queued`/`synced`) vs the `sync_queue` table — two representations; the contract must define which is authoritative for what (queue = work; `syncStatus` = display mirror) and mandate same-transaction updates. Note the enum needs a 4th value `parked` beyond the PRD's three.
* `platform.md §5` table list is "indicative" — the contract's table list becomes the real one; make sure `daily_attempt`, `daily_puzzle_cache`, and `sync_queue` (as specified here) are included and `analytics_event_buffer` is explicitly deferred to F12.
* Idempotency key depends on `firebaseUid`; until auth completes it can't be formed — the `awaitingAuth` sub-state must be in the contract or items risk being enqueued with a null key.

## Upstream business-rule conflicts / unresolved semantic drift

* **`guestId` identity** (above) — `platform.md §6` vs this analysis. Explicit Tech Lead reconciliation required.
* **Streak-integrity / clock manipulation** (`product-prd §51`) — still an open product/tech question. F08's position: store-only, monotonic elapsed, local-date string, no server clock check in MVP. If the Tech Lead/PO wants a server-side check, that is new F07/F08 backend scope and should be called out now.

## Decisions that must stay OPEN (not for `architecture.md` yet)

* Multi-Firebase-project topology + secret/environment specifics → **DevOps/Release Engineer** at the post-QA release gate (`release.md` update).
* `daily_puzzle_cache` retention values, real fetch cadence, rollover timing → **F07**.
* Hard-enforce App Check timing → confirm MVP posture with the Tech Lead; promotion is a later decision.
* Composite Firestore index / leaderboard query shape → defer to the leaderboard feature (post-MVP) unless the Tech Lead wants the index file seeded now.

---

# 18. Sonraki Komut

```
Run Tech Lead
```

Context for the Tech Lead:

* Consume the §17 "Decisions to move into `architecture.md`" into `features/f08-.../architecture.md`, flipping the `[PENDING ANALYSIS]` items to `[LOCKED]`.
* Make the four explicit calls: sync surface (callable recommended), `guestId`/`firebaseUid` identity (platform-authority reconciliation), F08↔F07 split (recommended), `infra/` DURUM 0 sequencing (parallel recommended).
* Set `Release Scope` (expected `production-readiness` + `rollback-readiness`) and update `release.md`; plan a `DevOps/Release Engineer` task after QA.
* Trigger the `infra/` Project Setup DURUM 0; approve the `connectivity_plus` dependency addition + request the F02 `restoreMoves` batch API.
* Open the F08-BE / F08-FE / F08-QA tasks against the locked contract and route (Frontend/Mobile Developer + Backend Developer; no UI Designer).

---

# 19. Orchestration Signals for Tech Lead

* **Analysis ready:** Yes — all 10 orchestration open items addressed with a recommendation + trade-offs + edge cases.
* **Blocker:** None hard. Two items need an explicit Tech Lead call before Backend/Frontend handoff: (1) sync surface callable-vs-write, (2) `guestId` vs `firebaseUid` platform reconciliation.
* **Product clarification needed:** Only if the PO/Tech Lead wants a server-side streak/clock-integrity check in the MVP (`product-prd §51`) — the analysis assumes not.
* **Tech Lead decision needed:** sync surface; identity model; F08↔F07 split; DURUM 0 sequencing; `Release Scope` + `release.md`; new `connectivity_plus` dep; F02 `restoreMoves` request; parked-item retry policy.
* **Ready for contract planning:** Yes — proceed to finalize `architecture.md`, trigger the `infra/` DURUM 0, and open delivery tasks.
