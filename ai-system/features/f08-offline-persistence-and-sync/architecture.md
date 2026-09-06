# F08 — offline-persistence-and-sync: Architecture

> Status: **CONTRACT AUTHORITY — LOCKED.** Finalized 2026-09-06 by the Tech Lead from `analysis.md` (F08.0-AN). Every prior `[PENDING ANALYSIS]` section is now `[LOCKED]`. Delivery artifacts and QA notes do not override the semantics here. The only remaining open values are the ones explicitly marked `[OPEN — …]` and belong to a downstream feature/role, not to F08 implementation.
> **Amended 2026-09-06 (Firebase-project incident):** "App Init Sequence → App Check provider selection" added — soft-enforce unchanged; debug provider in dev, Play Integrity / App Attest in release; iOS production App Attest deferred (no Apple Developer Program membership) and non-blocking because enforcement is OFF.
> `orchestration.md` is execution authority; `platform.md` / `release.md` are project authority.

---

## Purpose

* **Feature objective:** a durable on-device store (Drift/SQLite) that makes "never lose progress; play fully offline" true — active-session snapshot on every state change, journey progress, personal bests, daily first-run + streak, settings — plus a minimal, **exactly-once**, **first-run-authoritative** sync path for offline daily results, and a **guest-only** schema a future account can adopt without a destructive migration.
* **Contract scope:** the Drift schema + migration policy; the active-session snapshot shape (F03 designs to it); the `sync_queue` contract + exactly-once semantics; the reconciliation algorithm; the Firebase sync surface (callable + Firestore rules + App Check posture); the session-level service ownership boundary; the guest identity model.
* **Non-goals:** play-session UI (F03) · star computation (F04) · unlock rules / journey screens (F05) · daily fetch / cache-population / date-rollover / scoring / streak **rules** (F07) · analytics buffering (F12) · account / cloud-save UI · leaderboard · active multi-device merge · server-side streak/clock anti-cheat.

---

## Authorities & Inputs

* Upstream PRD: `features/f08-.../prd.md`; product PRD §6.1 F08, §5.4, §11.7, §12.5–12.7, §15–16, §46, §51.
* Consumed: `analysis.md` (F08.0-AN) — see `Consumed Signals` in `orchestration.md`. All 10 open items resolved into the sections below.
* Inherited contracts **[LOCKED]**:
  * **F02** — persistence captures `EngineConfig` (derived from the `Puzzle`), the ordered **applied**-`Move` list, and (as a cache only) `thawedCells`; the engine **re-derives** thaw/solved from the move history on restore. F08 stores what F02 exposes; it adds no engine state. **F08 requires a new additive F02 API:** `GridEngine.restoreMoves(List<Move>)` — replays a batch, producing the identical state to replaying `applyMove` one-by-one; non-breaking (see F02 `architecture.md` → Open Technical Decisions, promoted to "required by F08").
* Project authority **[LOCKED]**: `platform.md` §4 (JSON `lowerCamelCase`; `dailyDate` = device-local `YYYY-MM-DD`; optional fields omitted, never `null`; callable error format `{code,message,details}` + codes), §5 (Drift; write-through; forward-only migrations; `personal_best` / `daily_streak` / `daily_entry` first-run rows never dropped; UTC epoch millis + monotonic `Stopwatch`; `guestId` on every player-owned row; `kv` active-session JSON snapshot + `schemaVersion`), §6 (guest-only; Firebase Anonymous Auth; Firestore create-only rule for `dailyResults/**`; App Check soft-enforce for MVP) — **amended 2026-09-06, see Guest Identity Model below**, §7 (`sync_queue` + analytics flush are **session-level** services, never screen-owned; lifecycle `paused` → flush, `resumed` → restore + re-evaluate rollover + attempt flush; callable client timeout 10s), §8 (payload validation ranges; no PII; App Check on writes + callable), §11 (no runtime RNG on device; monotonic durations).
* Release: `release.md` — **F08 `Release Scope` = `production-readiness`** (first Firebase Functions + Firestore-rules deploy; incl. rollback-readiness for the Drift forward migration + functions redeploy + the `daily_sync_enabled` kill-switch). A `DevOps/Release Engineer` task opens **after QA**.

---

## Dependency Edges [LOCKED]

* Persistence lives in **`app/`** (Drift is a Flutter-side concern — `drift`, `sqlite3_flutter_libs`, `drift_dev`, `build_runner` already in `app/pubspec.yaml` per `setup-manifest.md` Step 6; **Drift codegen IS run** for F08 — the "codegen off for MVP" note in `platform.md` §3 is about Riverpod). Domain packages stay pure and Firebase-free.
* Serialized enums/value types reuse `looplet_content` (which re-exports `looplet_core`) — `PuzzleType`, `DifficultyLabel`, `MoveAxis`, `MoveDirection`, `TileStatus`, `GridCoord` (`platform.md` §3/§11 carve-out). No new shared enum without a Tech Lead carve-out note.
* **`Puzzle → EngineConfig`** consumer helper: F08 adds a free function in `app/` (`toEngineConfig(Puzzle) → EngineConfig`) — the helper F06 QA flagged for F05/F07/F08. Shared with F05. `looplet_content` never imports `looplet_engine`.
* **New `app/` dependency:** `connectivity_plus` (connectivity-regain trigger for the sync drain) — **approved by the Tech Lead 2026-09-06** as a `setup-manifest.md` dep addition; added in F08-FE9.
* `infra/` (Firebase project config, Cloud Functions TS, Firestore rules, App Check config, Remote Config) is scaffolded by a **Project Setup DURUM 0** (`F08.SETUP-0`), triggered at contract finalization, run **in parallel** with the Drift persistence core. Firebase **client** packages are added to `app/pubspec.yaml` during that DURUM 0: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_app_check`, `cloud_functions` — the exact set, matching `platform.md` §3.
* The `app` never bundles `looplet_solver` / `tools/looplet_authoring` (unchanged from F06).

---

## Guest Identity Model [LOCKED — amends `platform.md` §6]

`platform.md` §6 states "`guestId` = anonymous UID". **F08 refines this** — the two are decoupled:

| Value | Source | Role | Notes |
| --- | --- | --- | --- |
| `player.guestId` | locally generated **UUID v4** on first launch, persisted immediately | the **durable local key** stamped on every player-owned row | available offline, before any network; survives until app uninstall; the key a future account claims by |
| `player.firebaseUid` | Firebase Anonymous Auth UID, obtained asynchronously | the **server identity** — the Firestore path segment + the `sync_queue` idempotency-key component | `null` until Auth completes; a persistent-offline install simply has no `firebaseUid` yet |

* **Rationale:** offline-first is a hard product requirement (`product-prd` §5.4/§51) and Anonymous Auth cannot complete on a first launch with no connectivity; play + local persistence must not depend on it. A local UUID is also the cleaner anchor for future account adoption (`accountId` is added alongside the retained `guestId` by a forward migration).
* **`platform.md` §6 will carry a one-line amendment** recording this decouple (Tech Lead, same cycle). Where `platform.md` says "`guestId` = anonymous UID" read "`firebaseUid` = anonymous UID; `guestId` = durable local UUID".
* Reinstall ⇒ new `guestId` ⇒ new guest (accepted — matches "guest-only, no account", `product-prd` §39).

---

## Persistence Schema [LOCKED]

Drift database `AppDatabase`, `schemaVersion = 1`. **Typed tables** for durable domain data; **one `kv` row** for the active-session JSON snapshot (`platform.md` §5 names this pattern).

| Table | Key | Fields (high-level) | Written by | Migration protection |
| --- | --- | --- | --- | --- |
| `player` | `guestId` (UUID, PK) | `guestId`, `firebaseUid?`, `createdAtUtcMs` | F08 bootstrap | — |
| `settings` | `guestId` | `soundEnabled`, `hapticsEnabled`, `language` | F10 | — |
| `journey_progress` | `guestId` | `highestUnlockedLevel`, `completedLevelsCsv` | F05 | — |
| `personal_best` | `(guestId, levelId)` | `bestMoveCount` (monotone ↓), `stars`, `isPerfect`, `firstCompletedAtUtcMs` | F04 | **never dropped/reset** |
| `daily_entry` | `(guestId, lang, dailyDate)` | `dailyId`, `firstRunMoveCount`, `firstRunDurationMs`, `firstRunStars`, `firstRunCompletedAtUtcMs`, `syncStatus` (`local`/`queued`/`synced`/`parked`) | F07 | **first-run fields immutable once set; never dropped** |
| `daily_attempt` | `(guestId, lang, dailyDate, attemptNo)` | `moveCount`, `durationMs`, `stars`, `completedAtUtcMs` | F07 | — |
| `daily_streak` | `guestId` | `currentStreak`, `bestStreak`, `lastCompletedDate` (`YYYY-MM-DD`) | F07 (rule) / F08 (store) | **never dropped/reset** |
| `daily_puzzle_cache` | `(lang, dailyDate)` | `puzzleJson`, `fetchedAtUtcMs` | F07 populates; F08 owns the store | — (player-independent) |
| `sync_queue` | `id` (PK) | `kind`, `idempotencyKey`, `payloadJson`, `state`, `attemptCount`, `postParkAttemptCount`, `nextAttemptAtUtcMs`, `lastError?`, `createdAtUtcMs`, `updatedAtUtcMs` | F08 | — |
| `kv` | `key` (PK) | `key`, `valueJson`, `schemaVersion` | F08 | holds `active_session` + `store_meta` |

* `analytics_event_buffer` is **F12's** — explicitly deferred, not created here.
* All time columns are **UTC epoch millis** (`...UtcMs`). `dailyDate` / `lastCompletedDate` are device-local `YYYY-MM-DD` strings.
* No player table uses a device id in a key or a uniqueness constraint (multi-device-safe).
* **Migration policy:** `MigrationStrategy.onCreate` seeds `player` + `settings` + `journey_progress` + `daily_streak` defaults in one transaction. `onUpgrade` runs ordered steps; **every step is asserted not to reduce the row count of `personal_best`, `daily_streak`, or `daily_entry`**, and steps on those tables are transform/add-only — never `DROP`/`DELETE`. A migration test (seed v(N-1) → upgrade → assert bests/streak/first-run intact) is mandatory (F08-FE2). A migration step that throws **aborts without partial apply**, keeps the old DB, and shows a recoverable error screen — it **never** silently recreates the store.
* **Store downgrade is unsupported** (forward-only). A v(N) DB may be unreadable by a v(N-1) binary; mitigation is staged rollout + migration tests. Recorded in `release.md`.

---

## Active-Session Snapshot Contract [LOCKED — F03 designs to this]

Stored at `kv['active_session'].valueJson`. **Key names are frozen** — F03 serializes its play state into exactly this shape:

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

* **`appliedMoves`** — the ordered **applied**-`Move` list in F06 shorthand (`R<i>`/`L<i>`/`D<i>`/`U<i>`). This **is** the undo history: F02's `undo` re-folds from t=0, so **no separate undo stack is stored**. (Resolves the `product-prd` §15 `PlaySession.undoHistory` wording — F03 must not build a redundant stack.)
* **`undosRemaining`** — the F03 3-undo quota (not an engine concept); stored explicitly, range `0..3`.
* **`restartCount`** — stored explicitly (engine doesn't track it).
* **`thawedFrozenCells`** — **cache only** (`"r,c"` strings). On restore, authority is **re-derived** by replaying `appliedMoves` through the engine (F02 integration rule: `thawedCells` is not persisted as authority). Stored so a UI can paint instantly before replay.
* **`elapsedMsAccumulated`** — monotonic; resume adds a fresh `Stopwatch` delta. Wall clock is **never** read for elapsed.
* **`status`** — `inProgress` | `completed`. `inProgress` ⇒ F10 CONTINUE is enabled and routes into F03 with the hydrated session. Cleared via `ActiveSessionRepo.clearActiveSession()` (F03 calls it on completion / explicit abandon).
* **Restore path:** read + validate → resolve `puzzleId` to a `Puzzle` (journey: local content; daily: `daily_puzzle_cache`) → `toEngineConfig(puzzle)` → `GridEngine(config, validator)` → `restoreMoves(appliedMoves)` → restore counters + accumulated elapsed → hand the hydrated session to F03. **All** entry paths (cold launch, `resumed`, post-migration first launch) go through this same path; none skips re-derivation.
* **Corrupt snapshot** (bad `snapshotVersion` / JSON / token / `moveCount != appliedMoves.length` / bad coord): discard the active snapshot **only** (durable tables are separate and unaffected), land on the menu, log `save_corrupt_recovered`.
* A future F03 shape change is a normal forward migration: bump `snapshotVersion` + a `kv` migration step.

---

## `sync_queue` Contract & Exactly-Once [LOCKED]

* **Item:** `id`, `kind` (`"daily_result"`), `idempotencyKey`, `payloadJson`, `state`, `attemptCount`, `postParkAttemptCount`, `nextAttemptAtUtcMs`, `lastError?`, `createdAtUtcMs`, `updatedAtUtcMs`.
* **`idempotencyKey = "{firebaseUid}|{lang}|{dailyDate}"`.** Until `firebaseUid` exists the item sits in the `awaitingAuth` sub-state (a `pending` item whose key cannot yet be formed); it is **not** sent. Drained once Auth completes.
* **States:** `pending` → `inFlight` → `synced` (terminal success) · `pending`/`inFlight` → `pending` (retry, backoff) · `pending` → `parked` (terminal: attempt cap hit, or a non-retryable error).
* **`drain()`** (session-level, see Ownership): process `pending` items oldest-first where `now >= nextAttemptAtUtcMs`; mark `inFlight` → call `submitDailyResultV1` → on **ack** (`CREATED` **or** `ALREADY_SUBMITTED`) mark `synced` **and** set `daily_entry.syncStatus = synced` **in the same transaction** → on a retryable error bump `attemptCount`, set `nextAttemptAtUtcMs` via backoff, back to `pending` → on `attemptCount >= 10` or a non-retryable error mark `parked` (+ `daily_entry.syncStatus = parked`).
* **Backoff:** exponential, base 30 s, factor 2, cap 6 h, ±20 % jitter. **Attempt cap:** 10 → `parked`.
* **Stale-`inFlight` sweep:** an item `inFlight` for longer than 2× the client timeout (i.e. > 20 s) is returned to `pending` on the next drain — the idempotency key + server create-only make the retry safe.
* **Parked-item retry [LOCKED]:** bounded auto-retry — on each app start, `parked` items are moved back to `pending` once, up to `postParkAttemptCount < 3` lifetime; after that they stay `parked` (diagnostic only). The **local result is always authoritative** regardless of queue state.
* **Exactly-once mechanism (end-to-end):** client idempotency key + server **create-only** Firestore write + `ALREADY_SUBMITTED` treated as a client **success**. A second delivery of the same key is a server no-op returning `ALREADY_SUBMITTED`.
* **`daily_entry.syncStatus`** is a **denormalized display mirror** of the queue item's state for that key; the queue is the source of truth for "work to do"; both are updated in the same transaction on every transition. The enum is `local` (no queue item yet) / `queued` / `synced` / `parked` — consumers handle it exhaustively (no hidden default).

---

## Reconciliation Algorithm [LOCKED]

**First-run-authoritative, enforced independently on each side — the two sides never need to be merged (no leaderboard / no read-back in the MVP).**

* **Local:** `daily_entry.firstRun*` fields are written **once**, at the first local completion of that `(guestId, lang, dailyDate)`, and are **immutable** thereafter. A later local completion writes only a `daily_attempt` row (attemptNo ≥ 2) and enqueues **no** further `sync_queue` item for that key.
* **Server:** the Firestore write is **create-only** (`allow create` iff the doc does not exist and `request.auth.uid` matches the path uid; `update`/`delete`/`read` all `false` in the MVP). The first writer wins; a later write for the same `(uid, lang, dailyDate)` returns `ALREADY_SUBMITTED`.
* **"Both think they're first":** impossible to conflict — the server record is first-writer-wins and is never read back by the client in the MVP; the local record is first-local-completion and immutable. `ALREADY_SUBMITTED` simply marks the queue item `synced`.

---

## Firebase Sync Surface [LOCKED — HTTPS Callable]

**Decision: HTTPS Callable `submitDailyResultV1` (2nd gen).** (`platform.md` §3/§4 already pre-blesses "one RPC-style HTTPS callable: `submitDailyResult`". A direct client create-only write was considered and rejected — cross-field range validation is unsafe to express in security rules alone, it couples the client to the collection layout, and it leaves no seam for a future leaderboard write.)

### Callable contract

* **Name:** `submitDailyResultV1` · **Auth:** Firebase Anonymous Auth required (`context.auth.uid`) · **App Check:** attached; **soft-enforced** in the MVP (attestation failure is logged, the call proceeds — `platform.md` §6). Hard-enforce is a **post-MVP launch-hardening item, not F08**.

**Request:**
```json
{
  "lang": "tr", "dailyDate": "2026-09-06", "dailyId": "daily-tr-2026-09-06",
  "moves": 14, "optimalMoves": 9, "durationMs": 83210, "stars": 2,
  "completedAtUtcMs": 1757145600000, "clientAttemptNumber": 1
}
```
`uid` is taken from `context.auth`, never the body.

**Server-side validation** (`platform.md` §8): `lang` in `{tr,en}`; `dailyDate` matches `^\d{4}-\d{2}-\d{2}$`; `dailyId` non-empty; `optimalMoves >= 1`; `optimalMoves <= moves`; `durationMs >= 0`; `stars` in `1..3`; `completedAtUtcMs > 0`. On failure → `INVALID_PAYLOAD` / `UNSUPPORTED_LANGUAGE`.

**Success:**
```json
{ "status": "CREATED", "recordedAt": 1757145601000 }
{ "status": "ALREADY_SUBMITTED", "recordedAt": 1757058000000 }
```

**Error** (`{code,message,details}`, `platform.md` §4): `INVALID_PAYLOAD`, `UNSUPPORTED_LANGUAGE`, `APP_CHECK_FAILED` (hard-enforce only; not MVP), `INTERNAL`.

**Client mapping:** `CREATED` / `ALREADY_SUBMITTED` → queue `synced`. `INVALID_PAYLOAD` / `UNSUPPORTED_LANGUAGE` → `parked` (non-retryable) + log. `INTERNAL` / transport error / timeout → retryable (backoff). `APP_CHECK_FAILED` → bounded retries → `parked`.

### Firestore document (server-written)

Path `dailyResults/{lang}_{dailyDate}/entries/{uid}` — **create-only**:
```json
{ "uid": "…", "lang": "tr", "dailyDate": "2026-09-06", "dailyId": "…",
  "moves": 14, "optimalMoves": 9, "durationMs": 83210, "stars": 2,
  "completedAtUtcMs": 1757145600000, "recordedAtUtcMs": 1757145601000 }
```
Leaderboard-ready (query by `{lang,dailyDate}` → `moves` asc, `durationMs` asc) with no schema change. A composite index file is **[OPEN — deferred to the leaderboard feature]**; not seeded now.

### Rules

`dailyResults/**`: `allow create: if request.auth != null && request.auth.uid == <path uid> && !exists(...)`; `allow update, delete, read: if false`. Rules-unit-tested (F08-BE3).

### Remote Config

The DURUM 0 seeds the kill-switch keys `release.md` §6 requires: `daily_enabled`, `daily_sync_enabled`, `share_enabled` (default on), and a `daily_manifest_url` **placeholder** (empty) for F07. `DailyResultSyncService.drain()` is a no-op while `daily_sync_enabled == false`.

---

## Offline Daily Cache [LOCKED — mechanism only]

`DailyPuzzleCache`: `put(lang, dailyDate, Puzzle)`, `get(lang, dailyDate) → Puzzle?`, `evictOlderThan(days)`. F08 owns the `daily_puzzle_cache` table + this interface. **[OPEN — F07]:** when to populate, fetch cadence, retention-days value, eviction schedule.

---

## Ownership & Lifecycle [LOCKED]

* `DailyResultSyncService` + the `connectivity_plus` listener are a **session-level app service**, constructed once at app start (a Riverpod app-scoped provider / singleton), **disposed only at app termination**. **No screen** may hold, cancel, or recreate them. A screen dispose mid-sync does not stop the sync (`platform.md` §7). QA verifies this explicitly.
* **Lifecycle:** `AppLifecycleState.paused` → flush pending Drift writes + a final snapshot commit (a barrier, not a first write — write-through already committed it) + attempt a `drain()`. `resumed` → restore active session + (F07's) daily-rollover re-evaluation against the current local date + `drain()` if connectivity allows. Also `drain()` on a connectivity-regain event and after any successful foreground call.
* **Write-through:** every domain state change is committed by its repo method before it is considered applied; the active session is a single-row transactional upsert so a relaunch never sees torn state.
* **Durations:** monotonic `Stopwatch` only.

---

## App Init Sequence [LOCKED]

1. Open `AppDatabase` → run migrations (`onCreate` seeds; `onUpgrade` steps + never-drop guard). Migration failure → recoverable error screen (the only F08-owned UI; plain text + retry; no design handoff).
2. Read `kv['active_session']` (validate; corrupt → discard active only, continue).
3. **Async, non-blocking:** `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` → **App Check activation** (see below) → Anonymous `signInAnonymously()` → on success persist `player.firebaseUid`. **Every step here is best-effort — a failure is caught and logged, never rethrown**; play + local persistence proceed, and the sync queue waits in `awaitingAuth` until a `firebaseUid` exists.
4. Construct the session-level `DailyResultSyncService`; start the connectivity listener; `drain()` once.
5. Hand control to the normal `go_router` tree (or the migration-error root if step 1 failed).

### App Check provider selection [LOCKED — amended 2026-09-06]

App Check is **soft-enforce / monitor** for the whole MVP (`platform.md` §6/§13) — a missing or failed attestation token **never blocks** `initializeApp`, `signInAnonymously`, or `submitDailyResultV1`. Given that, `FirebaseAppCheck.instance.activate(...)` uses:

| Build | Android provider | Apple provider |
| --- | --- | --- |
| debug / profile / simulator / `flutter test` | `AndroidProvider.debug` | `AppleProvider.debug` |
| release | `AndroidProvider.playIntegrity` | `AppleProvider.appAttest` |

* The whole `activate(...)` call is wrapped so an activation error is logged and swallowed (init continues).
* **iOS release App Attest / DeviceCheck is not configured** — the LOOPLET Apple account is not enrolled in the Apple Developer Program (no Team ID / `.p8` key). A release iOS build will attempt App Attest and its token acquisition will fail; because enforcement is OFF this is a logged no-op and the app is fully functional. Completing iOS production App Check is an **`[OPEN — post-MVP, after Apple Developer Program enrollment]`** follow-on, not an F08 blocker.
* Android release Play Integrity needs the release-signing SHA-256 registered in the Firebase console — a launch-hardening / `F08-DEVOPS` concern (debug builds use the debug provider and don't need it).
* **Hard-enforce is never enabled in the MVP.**

---

## Resilience [LOCKED]

| Case | Behavior |
| --- | --- |
| App killed mid-write | Store at last committed transaction; no torn snapshot. |
| Storage full / write error | Transaction rolls back; last good state intact; non-fatal `persist_failed` event; keep playing from memory; retry next boundary; repeated failure → a soft UI notice (copy owned by F03/F10). Never a crash, never a partial write. |
| Corrupt `active_session` JSON | Discard active snapshot only; durable tables unaffected; land on menu; log `save_corrupt_recovered`. |
| Unreadable DB file / unrecoverable corruption | Attempt Drift recovery; last resort recreate the DB (accepted data loss, logged, `db_reinitialized`) — never a crash-loop. **[OPEN — Tech Lead, low priority]:** whether a periodic backup copy of durable tables is warranted for the MVP (default: no). |
| Migration step throws | Abort without partial apply; keep old DB; recoverable error screen; log `migration_failed`. Never silently wipe. |
| Concurrent writes (autosave tick + explicit action) | Serialized through the single Drift executor; single-row commit is always internally consistent. |
| Device clock jumps mid-session | Elapsed unaffected (monotonic `Stopwatch`). `completedAtUtcMs` uses `DateTime.now().toUtc()` — a wrong wall clock yields a wrong timestamp; **accepted in the MVP** (no server-side clock trust — see Streak/Clock below). |

---

## Streak-Integrity / Clock [LOCKED]

* F08 **owns storage only**: durable `daily_streak` (`currentStreak`, `bestStreak`, `lastCompletedDate` as a local `YYYY-MM-DD` string), monotonic elapsed measurement, UTC epoch timestamps.
* F08 does **not** own the streak increment/reset rule or the rollover decision — those are **F07**. F08 writes `daily_streak` exactly as F07 computes it.
* **No server-side clock/timezone anti-cheat in the MVP** (Tech Lead decision, consistent with `platform.md` §6 "no custom rate limiter" + App Check soft-enforce; `product-prd` §51 open item resolved as: local monotonic + local-date only; App Check + create-only rule are the only controls). If a server-side check is ever wanted it is new F07/F08 backend scope, raised separately.

---

## Scope Boundary F08 ↔ F07 [LOCKED — F06-style split]

* **F08 delivers now:** the full persistence layer; `DailyPuzzleCache` (mechanism); `DailyResultSyncService` (queue + backoff + exactly-once + reconciliation); the `submitDailyResultV1` callable + Firestore rules; and a **fake daily-result producer** test seam (`enqueueFakeDailyResult(...)` behind a debug/test flag) that fabricates a `daily_entry` + enqueues a sync item — so the queue + reconciliation + callable path are verified end-to-end against the Firebase emulator **without F07**.
* **F07 delivers later:** the real Daily fetch, `daily_puzzle_cache` population + eviction values, date-rollover, and the streak rule — calling the same `DailyRepo` / `DailyResultSyncService.enqueue(...)`. The fake producer is removed/replaced by F07.
* F08 **does not depend on F07**. F07 depends on F08.

---

## Validation Responsibility [LOCKED]

* **`app` persistence layer:** schema validity, migration correctness (+ never-drop guard), write-through completeness, restore fidelity, resilience fallbacks, snapshot shape validation.
* **`DailyResultSyncService`:** exactly-once delivery, backoff/cap, stale-`inFlight` sweep, `awaitingAuth` handling, session-level survival, `daily_entry.syncStatus` mirroring.
* **Callable + Firestore rules:** server-side create-only enforcement + full payload validation + App Check (soft).
* **F02 engine:** the restored `EngineConfig` + move list re-derive thaw/solved — F08 does not re-validate engine semantics.
* **Client pre-enqueue:** assert payload validity in debug; drop + log an invalid payload in release (never enqueue a bad item).

---

## QA Focus [LOCKED]

* **Resume fidelity (`runtime`, device/emulator):** kill + relaunch at N moves with undos + a restart + a thawed frozen tile → grid, `moveCount`, `undosRemaining`, `restartCount`, elapsed, thawed state exactly restored; a **tampered-cache test** proves `thawedCells` is re-derived, not trusted.
* **Offline Journey (`runtime`):** airplane mode → all 30 levels load, a level completes, progress + best persist, relaunch still offline → intact.
* **Offline Daily (`runtime`):** pre-populated `daily_puzzle_cache` + offline → Daily playable; no cache + offline → "needs connection" (F07 UI), Journey unaffected.
* **Exactly-once sync (`repeatable integration`, Firebase emulator, via the fake producer):** offline completion → 1 queue item; reconnect → 1 Firestore doc; forced mid-request drop → retry → still 1 doc; kill during `inFlight` → relaunch → recovered → still 1 doc; `daily_sync_enabled=false` → no send.
* **First-run-authoritative (`repeatable integration`):** seed a server doc with an earlier run → sync a later local run → server doc unchanged, queue → `synced`, local `firstRun*` unchanged; local 2nd completion → `daily_attempt` row, no new queue item.
* **Migration (`automated functional`):** seed schema v1 (bests + streak + daily first-run) → upgrade → all intact; never-drop guard; corrupt `active_session` → clean recovery, durable tables intact; simulated storage-full → non-destructive; migration-throw → abort + recoverable, no wipe.
* **Clock (`automated` + `runtime`):** clock moved backward/forward mid-session → elapsed unaffected.
* **Guest schema (`automated`):** every player-owned row has a non-null `guestId`; no device-id key.
* **Ownership (`runtime`):** trigger a completion, dispose the triggering screen → sync still completes.
* **Rules (`repeatable integration`):** create-own allowed; create-other denied; update/delete/read denied.
* **Evidence class:** `runtime` (resume / offline / sync on device or emulator) + `repeatable integration` (callable + rules via the Firebase emulator) + `automated functional` (schema / migration / serialization units). **Not `source-only`** (`platform.md` §10 requires runtime proof for resume + daily behavior).
* **QA scope:** end-to-end (app persistence + Firebase emulator). `Security compliance` in scope at the rules/callable level (create-only, auth-scoped path, payload validation, App Check attach); no PII, no cross-user read.

---

## Release / Deployment Impact [LOCKED — scope; OPEN — DevOps runbook]

* **`Release Scope` = `production-readiness`.** F08 is the **first Firebase deploy** for LOOPLET: `submitDailyResultV1` (Cloud Function), `firestore.rules`, App Check config, Remote Config keys (`daily_enabled`, `daily_sync_enabled`, `share_enabled`, `daily_manifest_url` placeholder). This is a **backend-only** release gate — distinct from the first app-build distribution gate (still expected around F03/F05).
* CI additions (`release.md` §4): `infra/functions` `npm ci && npm run build && npm test`; `@firebase/rules-unit-testing`; (best-effort) an emulator integration job.
* **Rollback-readiness** the DevOps task must cover: functions redeploy-previous; `daily_sync_enabled` kill-switch; Drift forward-migration has **no downgrade** — mitigation is migration tests + staged rollout + the never-drop guard (documented in `release.md` §6).
* Environment: `release.md` §3 — validate in the emulator; production Firebase project deploy needs Tech Lead approval (`release.md` §12). Single Firebase project for the MVP unless DevOps/Release Engineer determines otherwise. **[OPEN — DevOps]:** deploy runbook, dry-run evidence, prod-project confirmation, `FIREBASE_CI_TOKEN` wiring (name already in `release.md` §7).
* A **`DevOps/Release Engineer` task opens after QA** (state machine DURUM 5 → In Release).

---

## Open Items (downstream — NOT F08 implementation)

* **[OPEN — F07]** `daily_puzzle_cache` population trigger, fetch cadence, retention-days, eviction schedule; the real Daily producer + streak rule + date-rollover.
* **[OPEN — DevOps/Release Engineer, post-QA]** deploy runbook, prod Firebase project, dry-run + smoke evidence, composite index decision.
* **[OPEN — Tech Lead, low priority]** periodic backup copy of durable tables (default: no for the MVP).
* **[OPEN — post-MVP]** App Check hard-enforce; leaderboard + its Firestore composite index.
* **[OPEN — post-MVP, needs Apple Developer Program enrollment]** iOS production App Check (App Attest / DeviceCheck) configuration — Team ID + `.p8` auth key + Key ID. Not a blocker while App Check is soft-enforced; debug/dev uses the debug provider.
* **[OPEN — F08-DEVOPS]** Android release Play Integrity: register the release-signing SHA-256 in the Firebase console; `FIREBASE_CI_TOKEN` repo secret (deferred here per the user).
