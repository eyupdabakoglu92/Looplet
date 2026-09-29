# F08 — offline-persistence-and-sync: Architecture

> Status: **CONTRACT AUTHORITY — LOCKED.** Finalized 2026-09-06 by the Tech Lead from `analysis.md` (F08.0-AN). Every prior `[PENDING ANALYSIS]` section is now `[LOCKED]`. Delivery artifacts and QA notes do not override the semantics here. The only remaining open values are the ones explicitly marked `[OPEN — …]` and belong to a downstream feature/role, not to F08 implementation.
> **Amended 2026-09-06 (Firebase-project incident):** "App Init Sequence → App Check provider selection" added — soft-enforce unchanged; debug provider in dev, Play Integrity / App Attest in release; iOS production App Attest deferred (no Apple Developer Program membership) and non-blocking because enforcement is OFF.
> **Amended 2026-09-29 (Tech Lead — F08 activation after Design Adoption Phase D):** "Activation 2026-09-29" added at the end — the unreadable-DB recovery gap (Resilience row, AC8) is closed in code by F08-FE13; Retry reopens the database connection; a debug-only emulator connection and fake-producer trigger; the local evidence plan and its methods. No semantic change to the locked sections.
> **Amended 2026-09-29 (Tech Lead — the F08-BE6 checkpoint):** "Activation 2026-09-29 → A8" added — F08-BE6 accepted; the Java 21 command corrected (Java 21 must be first on `PATH`); A6 ruling 5's premise about the CI emulator job corrected (the step exists since F08-BE5 and has never run); F08-QA-FUNCTIONAL activated under A7. No semantic change to the locked sections.
> **Amended 2026-09-29 (Tech Lead — the checkpoint on the F08-QA-FUNCTIONAL verdict, Decision Pending):** "Activation 2026-09-29 → A9" added, and the locked **Rules** row corrected: clients may not write `dailyResults/**` at all; only the callable writes, through the Admin SDK (QA finding F1). The same correction is made in "Reconciliation Algorithm → Server", "Validation Responsibility" and "QA Focus → Rules", and in `platform.md` §6 / §8. This resolves a conflict inside the locked Firebase Sync Surface section in favour of its own decision (callable; a direct client write was rejected). No product criterion changes.
> **Amended 2026-09-29 (Tech Lead — the F08-BE7 checkpoint):** "Activation 2026-09-29 → A10" added — F08-BE7 accepted (the rules now match the corrected Rules row); F08-QA-FUNCTIONAL-R1 activated under A9 ruling 4. No semantic change to the locked sections.
> **Amended 2026-09-29 (Tech Lead — the checkpoint on the F08-QA-FUNCTIONAL-R1 verdict, Runtime Validation Pending):** "Activation 2026-09-29 → A11" added — F1 closed; F08 Blocked only on the user's no-network run (AC2). The `sync_queue` **Backoff** line is clarified to the delivered schedule (first retry ≈ 60 s; QA note N1-R1). No product criterion changes.
> **Amended 2026-09-29 (Tech Lead — intake of the user's no-network run):** "Activation 2026-09-29 → A12" added — the run is valid; F08-QA-FUNCTIONAL-R2 activated under A11 ruling 4. No contract change.
> **Amended 2026-09-29 (Tech Lead — the checkpoint on the F08-QA-FUNCTIONAL-R2 verdict, Functional Approved):** "Activation 2026-09-29 → A13" added — the functional stage is closed; the release stage waits on the user's decisions (F08.DEPLOY-AUTHORIZATION, and the new gate F08.CI-FIRST-PUSH); F08-DEVOPS-PREP is defined and Blocked. No contract change.
> **Amended 2026-09-29 (Tech Lead — decision F08.CI-FIRST-PUSH):** "Activation 2026-09-29 → A14" added — the user pushed `main`; CI's first run is recorded (the emulator step failed); F08 stays Blocked on F08.DEPLOY-AUTHORIZATION. No contract change.
> **Amended 2026-09-29 (Tech Lead — incident: CI run #1 logs):** "Activation 2026-09-29 → A15" added — the three CI root causes confirmed; Technical Decisions on the format scope and CI toolchain parity; the F08.DEPLOY-AUTHORIZATION options refined. No product or runtime contract change.
> **Amended 2026-09-29 (Tech Lead — decision F08.DEPLOY-AUTHORIZATION — B):** "Activation 2026-09-29 → A16" added — the deploy stays deferred; the non-deploy release work (F08-DEVOPS-PREP) is activated; F08.DEPLOY-GO is opened at the PREP checkpoint. No contract change.
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
* **Backoff:** exponential, base 30 s, factor 2, cap 6 h, ±20 % jitter: after the n-th failed attempt the next attempt is due in `30 s × 2^n` (first retry ≈ 60 s, then 120 s, 240 s …), capped at 6 h, then ±20 % jitter, never above 6 h. **Attempt cap:** 10 → `parked`. *[Clarified 2026-09-29, A11 ruling 3: the first-retry delay was not stated; this is the delivered and tested schedule.]*
* **Stale-`inFlight` sweep:** an item `inFlight` for longer than 2× the client timeout (i.e. > 20 s) is returned to `pending` on the next drain — the idempotency key + server create-only make the retry safe.
* **Parked-item retry [LOCKED]:** bounded auto-retry — on each app start, `parked` items are moved back to `pending` once, up to `postParkAttemptCount < 3` lifetime; after that they stay `parked` (diagnostic only). The **local result is always authoritative** regardless of queue state.
* **Exactly-once mechanism (end-to-end):** client idempotency key + server **create-only** Firestore write + `ALREADY_SUBMITTED` treated as a client **success**. A second delivery of the same key is a server no-op returning `ALREADY_SUBMITTED`.
* **`daily_entry.syncStatus`** is a **denormalized display mirror** of the queue item's state for that key; the queue is the source of truth for "work to do"; both are updated in the same transaction on every transition. The enum is `local` (no queue item yet) / `queued` / `synced` / `parked` — consumers handle it exhaustively (no hidden default).

---

## Reconciliation Algorithm [LOCKED]

**First-run-authoritative, enforced independently on each side — the two sides never need to be merged (no leaderboard / no read-back in the MVP).**

* **Local:** `daily_entry.firstRun*` fields are written **once**, at the first local completion of that `(guestId, lang, dailyDate)`, and are **immutable** thereafter. A later local completion writes only a `daily_attempt` row (attemptNo ≥ 2) and enqueues **no** further `sync_queue` item for that key.
* **Server:** the Firestore write is **create-only**, done by the callable only: its transaction creates the doc iff it does not exist, for the uid from `context.auth`. Clients cannot write, update, delete or read `dailyResults/**` (rules: all `false` in the MVP). The first writer wins; a later write for the same `(uid, lang, dailyDate)` returns `ALREADY_SUBMITTED`. *[Corrected 2026-09-29, A9: this line used to describe a client `allow create` rule; see "Rules".]*
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

`dailyResults/**`: `allow create, update, delete, read: if false` — no client access. Only `submitDailyResultV1` writes, through the Admin SDK, which security rules do not apply to. Create-only / first-writer-wins is enforced by the callable's transaction (`snapshot.exists` → `ALREADY_SUBMITTED`); the payload validation above runs before every write. Rules-unit-tested (F08-BE3; the deny-own-create case F08-BE7).

*[Corrected 2026-09-29, A9 — QA finding F1. The row used to read `allow create: if request.auth != null && request.auth.uid == <path uid> && !exists(...)`. That rule let any signed-in client skip the callable: it could write an unvalidated entry for itself, which the callable then kept as the first run, and create entries under any bucket name. It contradicted this section's own decision ("a direct client create-only write was considered and rejected") and the "server-written" document.]*

### Remote Config

The DURUM 0 seeds the kill-switch keys `release.md` §6 requires: `daily_enabled`, `daily_sync_enabled`, `share_enabled` (default on), and a `daily_manifest_url` **placeholder** (empty) for F07. `DailyResultSyncService.drain()` is a no-op while `daily_sync_enabled == false`.

---

## Offline Daily Cache [LOCKED — mechanism only]

`DailyPuzzleCache`: `put(lang, dailyDate, Puzzle)`, `get(lang, dailyDate) → Puzzle?`, `evictOlderThan(days)`. F08 owns the `daily_puzzle_cache` table + this interface. **[OPEN — F07]:** when to populate, fetch cadence, retention-days value, eviction schedule.

* **Cross-feature note (F07 `architecture.md` A1 ruling 1, 2026-09-29):** F07 stores the pack's day envelope `{"dailyNumber": N, "puzzle": {…}}` in `puzzle_json` so an offline day keeps its number. The schema and the `DailyPuzzleCache` signatures (`puzzleJson` text) are unchanged; F07 is the only reader. F07 D3 resolves the `[OPEN — F07]` items above.

---

## Ownership & Lifecycle [LOCKED]

* `DailyResultSyncService` + the `connectivity_plus` listener are a **session-level app service**, constructed once at app start (a Riverpod app-scoped provider / singleton), **disposed only at app termination**. **No screen** may hold, cancel, or recreate them. A screen dispose mid-sync does not stop the sync (`platform.md` §7). QA verifies this explicitly.
* **Lifecycle:** `AppLifecycleState.paused` → flush pending Drift writes + a final snapshot commit (a barrier, not a first write — write-through already committed it) + attempt a `drain()`. `resumed` → restore active session + (F07's) daily-rollover re-evaluation against the current local date + `drain()` if connectivity allows. Also `drain()` on a connectivity-regain event and after any successful foreground call.
* **Write-through:** every domain state change is committed by its repo method before it is considered applied; the active session is a single-row transactional upsert so a relaunch never sees torn state.
* **Durations:** monotonic `Stopwatch` only.

---

## App Init Sequence [LOCKED]

1. Open `AppDatabase` → run migrations (`onCreate` seeds; `onUpgrade` steps + never-drop guard). Migration failure → recoverable error screen (the only F08-owned UI; plain text + retry; no design handoff). *[Amended 2026-09-29 — Design Adoption Phase D3, F05 `architecture.md` §18.3 (7), audit C-6: the screen adopts the Foundation pattern (glass card, Space Grotesk headline, one `LimePill` Retry), Turkish copy through a strings table, and the raw exception is logged, never shown to the player (debug builds only). Behaviour unchanged: Retry re-runs the bootstrap; data stays intact (AC9).]*
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
* **Callable + Firestore rules:** server-side create-only enforcement + full payload validation + App Check (soft). The callable is the only write path; the rules deny every client read and write on `dailyResults/**` (A9).
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
* **Rules (`repeatable integration`):** a direct client create is denied — own entry, another user's entry, unauthenticated, an invalid payload, a non-date bucket; update/delete/read denied; the callable still creates (Admin SDK). *[Corrected 2026-09-29, A9: was "create-own allowed".]*
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

---

## Activation 2026-09-29 (Tech Lead — after Design Adoption Phase D)

> F08 was queued behind the F05 rework and Phase D (incident 2026-09-26). Phase D closed on 2026-09-29 (F05 `architecture.md` §18.9). This section re-bases the local-evidence work on the current app (`b4ad263e…`, HEAD b7493d6) and records the decisions taken now. Execution is in `orchestration.md`.

### A1. Gap found: an unreadable database file is a dead end (Resilience row; AC8)

**Observed** (F05-QA-D3 E15 at runtime, and the code):
* `appBootstrapProvider` maps **every** open or migrate failure to `AppBootstrapMigrationError` → the store-error screen.
* A store file that is not a database (`SqliteException(26)`, `file is not a database`) shows the error screen. Retry fails again and again, so the app is unusable until it is reinstalled.

This breaks two authorities:
* the locked Resilience row "Unreadable DB file / unrecoverable corruption → attempt Drift recovery; last resort recreate the DB (accepted data loss, logged, `db_reinitialized`) — never a crash-loop";
* PRD AC8 "corrupt save file on launch → … a clean state without crashing, and logs the event".

The earlier F08 QA read AC8 as the `active_session` row only (qa.md AC8), so this path was never exercised. **Classified as an implementation gap against a locked contract** — not a product change. F08-FE13 closes it.

**Rules (Tech Lead decisions, inside the locked row):**
1. **Classification.** The bootstrap separates three outcomes:
   * **unreadable** — a `SqliteException` whose (extended) result code is `SQLITE_NOTADB` (26) or `SQLITE_CORRUPT` (11), raised while opening or on the first query;
   * **migration failure** — `MigrationDataLossError`, or an exception thrown by a migration step;
   * **other** — anything else (e.g. `SQLITE_CANTOPEN`, `SQLITE_IOERR`, `SQLITE_FULL`, `SQLITE_BUSY`).
2. **Unreadable → recover:**
   * close the connection;
   * **quarantine** the file (and its `-wal` / `-shm`) by renaming it to `looplet.sqlite.corrupt-<utcMs>` in the same directory — never delete it; keep at most the newest one quarantined copy;
   * recreate the database (the normal `onCreate` seed: a new guest);
   * log `db_reinitialized` with the result code, via `debugPrint` in every build;
   * continue to Home.

   "Attempt Drift recovery" means exactly this: there is no partial-page repair in the MVP. The quarantined bytes are kept for a manual support recovery.
3. **Loop guard.** If the recreated database also fails to open, the bootstrap returns the error state. It never recreates twice in one launch, so there is never a crash-loop and never a recreate-loop.
4. **Migration failure** (AC9) is unchanged: keep the old database, show the store-error screen, Retry. The screen's copy ("İlerlemen güvende; hiçbir şey silinmedi.") stays true, because this is the only remaining path to it with a readable store.
5. **Other failures** → the store-error screen, and Retry re-runs the bootstrap on a **fresh connection** (A2).
6. **Player notice:** none in this scope. AC8 asks for a clean state and a log, not a message. A future notice after `db_reinitialized` ("your saved progress could not be read …") is copy for PO / F10 — tracked as DB-REINIT-NOTICE in `workflow-follow-ups.md`. **Assumption (hybrid):** a silent reset is acceptable for the MVP because the store only becomes unreadable through device-level corruption.

### A2. Retry reopens the database connection (F08-RETRY-STORE-CONNECTION)

* Retry (`StoreErrorScreen`) invalidates the database connection provider as well as `appBootstrapProvider`, so a store that became readable while the app runs (e.g. space freed, a transient I/O error) recovers without a relaunch. The old connection is closed first.
* F08 AC9 behaviour is otherwise unchanged.
* **The one-frame Retry feedback (F05-QA-D3 N2) is not in this scope.** It is a visual timing change on a surface whose gate passed in D3. It stays in `workflow-follow-ups.md` for the next shell visual touch, so F08 needs no visual gate.

### A3. Debug-only emulator wiring and fake-producer trigger (test tooling)

The QA Focus calls for client ↔ emulator runs ("exactly-once sync … via the fake producer"; "Ownership … dispose the triggering screen → sync still completes"). Today the app has no way to reach the emulator, so F08-FE13 adds:
* **`--dart-define=LOOPLET_FIREBASE_EMULATOR=<host>`**, honoured only when `kDebugMode`. After `Firebase.initializeApp` it calls `useAuthEmulator` / `useFirestoreEmulator` / `useFunctionsEmulator` against the `infra/firebase.json` ports, with the project `demo-looplet`. The whole block is compiled out of release builds; there is no runtime switch in release.
* **A debug-only trigger for `FakeDailyResultProducer`**, reachable without a Daily screen: e.g. an extra launcher in Home's `kDebugMode` debug row (C2 rules: outside the column, hidden when it would hit the caption), or a debug-only route. It must not appear in profile or release builds.
* No new dependency beyond the Firebase packages already present.

### A4. Local evidence plan (F08-LOCAL-EVIDENCE; reuse is QA's call at F08-QA-FUNCTIONAL)

| Scenario (ledger) | Method | Notes |
| --- | --- | --- |
| **F08.EMULATOR** — rules and callable (create-only, auth isolation, idempotency) | `cd infra/functions && npm ci && npm run build && npm run test:emulator` (project `demo-looplet`, no billing). *[Corrected at the A6 checkpoint: firebase-tools 15.29 needs **Java 21+**, not JDK 17 — `JAVA_HOME=/opt/homebrew/opt/openjdk@21`; see A6 ruling 5. Corrected again at A8: Java 21 must also be first on `PATH`.]* | The developer confirms the harness runs and records the result. QA re-runs it independently. |
| **Exactly-once client ↔ emulator** (AC4, AC5, AC11; part of F08.EMULATOR / F08.LIFECYCLE) | A3 wiring + the fake producer on the iPhone 16 simulator against `firebase emulators:start --only auth,firestore,functions`:<br>• offline completion → 1 queue item;<br>• reconnect → 1 doc;<br>• a forced mid-request drop (stop the emulator mid-call) → retry → still 1 doc;<br>• a kill during `inFlight` → relaunch → still 1 doc;<br>• a server doc seeded with an earlier run → local later run syncs → server unchanged;<br>• `daily_sync_enabled=false` → no send. | "Offline" here = emulator unreachable (stopped), stated as such. It is not device airplane mode. |
| **F08.LIFECYCLE** — screen dispose mid-sync; `paused` / `resumed` → `drain()`; connectivity regain → `drain()` | The same setup: trigger, then leave the triggering screen at once; HOME button / relaunch; stop and start the emulator | Record the emulator request log and the queue rows (`sqlite3`) as evidence. |
| **F08.LOCAL-RESUME** — AC1 / AC6 | iPhone 16 debug build:<br>• a level with frozen tiles (21–30): N moves + an undo + a restart + a thawed tile → kill → relaunch → exact restore of grid, `moveCount`, `undosRemaining`, `restartCount`, elapsed (± capture resolution) and thaw;<br>• tamper `thawedFrozenCells` in `kv['active_session']` → relaunch → thaw re-derived, not trusted. | Grid / moves / undo on a replay are already proven at `b4ad263e…` (F05-QA-D3 E09). The FE13 build changes the database-open path, so the whole scenario is re-run on it. |
| **F08.OFFLINE-JOURNEY** — AC2 | A real no-network runtime:<br>• the user turns the Mac's network off, or runs a developer-provided script that does so and restores it (Claude may not change system settings);<br>• or a physical device in airplane mode.<br>Then: levels load, a level completes, progress and best persist, relaunch offline → intact. | If no such runtime is available in the turn, the scenario stays PENDING with this prerequisite. It is not replaced by a simulated offline mode. |
| **F08.STORAGE** — AC7 | Repeatable integration on a **real file database**: lower `PRAGMA max_page_count` until the next write hits `SQLITE_FULL`; assert:<br>• the transaction rolls back;<br>• the last good state is intact;<br>• the non-fatal `persist_failed` path runs;<br>• play continues from memory;<br>• the next boundary retries.<br>Plus a runtime pass if feasible (a debug-only hook applying the same pragma). | A negative run must show the test fails when the rollback is bypassed. |
| **AC8 unreadable DB** (new, from A1) | Runtime: `seed-d3.sh corrupt` → cold launch → Home "new"; the quarantined file exists; the `db_reinitialized` log. Automated: classification tests (NOTADB, CORRUPT → recover; migration error → error screen; recreate fails → error, no loop). | Negative runs: remove the classification (all → error screen) and remove the loop guard, each caught. |
| **F08.COLD-BOOT-REVIEW** | QA reviews F08-FE12 provenance at F08-QA-FUNCTIONAL. The production-shaped cold boot (empty / existing store) is re-run on the FE13 build by the developer (startup impact: yes). | F05-QA-D3 E05 / E06 are at `b4ad263e…`; FE13 changes the bootstrap, so they are supporting only. |
| **F08.DEPLOY-SMOKE** | Unchanged — release scope, F08.DEPLOY-AUTHORIZATION OPEN. | Not in this activation. |

**Offline Daily (AC3)** stays with F07 (F07.OFFLINE-DAILY). **Clock (AC10)** stays automated-only: the simulator follows the host clock, and changing it is a system setting. It is stated as a limit.

### A5. Visual scope

`none` for this F08 work:
* the recovery path lands on the existing Home "new" state;
* Retry keeps the D3 screens unchanged;
* the debug trigger is `kDebugMode` only (the C2 rules).

No UI Designer task and no visual gate. If FE13 needs any player-visible change, that is Needs Tech Lead Clarification.


### A6. Implementation checkpoint 2026-09-29 (F08-FE13 + F08-LOCAL-EVIDENCE, commit beb7bfe)

**Delivery reviewed:** `frontend.md` → "F08-FE13" and "F08-LOCAL-EVIDENCE"; the code diff of `bootstrap.dart`, `app_database.dart`, `migration_guard.dart`, `firebase_emulator.dart`, `sync_providers.dart`; the migration-failure tests and the N-TXN mutation in `evidence/neg-fe13.py`; the backend test named in `frontend.md` §16.1 against `infra/functions/src/validate.ts`. The committed `app/` tree `9de12e6a…` equals the tree `frontend.md` records.

**Tech Lead re-run (not a QA claim):** `flutter test test/persistence/store_recovery_test.dart test/persistence/storage_full_test.dart test/shell/store_error_screen_test.dart` at beb7bfe, 2026-09-29, macOS host → 29 / 29, exit 0.

**Task coverage:**
* F08-FE13 closes A1 rules 1–5 (classify, quarantine + recreate, `db_reinitialized`, loop guard, migration / other → the error screen), A2 (Retry closes and replaces the connection), A3 (the emulator define under `kDebugMode`, the `/debug/sync` trigger) and the A4 storage-full harness.
* F08-LOCAL-EVIDENCE covers every A4 row except the offline Journey. That row waits for a real no-network runtime, as A4 allows.

**Contract compliance:**
* No schema, migration-step, snapshot, repository or callable change.
* `StoreErrorScreen`, the splash and Home are unchanged (Visual Scope `none` holds).
* Additive:
  * `/debug/sync` (debug only);
  * the `debugSyncDisabledProvider` stand-in;
  * the callable failure log line.
* The release binary gate was checked by strings (LE-08). QA re-checks it.

**Rulings:**
1. **Migration transaction — Accepted (in contract).** Wrapping the guarded `onUpgrade` loop in `transaction` restores the locked Resilience row "Migration step throws → abort without partial apply; keep old DB". This is not a new behaviour. Without it the row was false on a real connection: a guard violation left the partial delete behind. The row was never proven on a real connection before (the F08-FE2 claim). `MigrationStepError` keeps a throwing step, even one with a SQLite CORRUPT cause, on the migration path and never the recreate path (A1 rule 1). N-TXN catches the removal. **Limit:** `schemaVersion = 1`, so no real step exists yet. The first real migration must add its own v(n) → v(n+1) test on a real file database.
2. **Quarantining `-journal` — Accepted.** It is an extension of A1 rule 2 that the rule needs: a hot rollback journal left beside a new store would roll into it.
3. **A named emulator app, and App Check skipped against the emulators — Accepted.**
   * Both are debug + define only.
   * The production path still uses the default app: `loopletFirebaseApp()` returns `Firebase.app()` when no emulator app exists, and `FirebaseFunctions.instanceFor(app: Firebase.app())` is the old `FirebaseFunctions.instance`.
   * The FE12 lazy getter is preserved.
4. **The debug kill switch — Accepted as test tooling, with a scope limit.**
   * `dailySyncEnabledProvider` is still the constant `true` outside debug. The real Remote Config read is F07's (locked Remote Config section).
   * LE-04 E therefore proves the `drain()` no-op when the switch is off. It does not prove the Remote Config wiring.
   * QA records it that way. It is not an F08 gap.
5. **Tooling: Java 21.** firebase-tools 15.29 needs Java 21+. `openjdk@21` is installed keg-only (the user approved it; the system Java is unchanged).
   * The canonical local command is now in `project-authority/setup-manifest.md` → Canonical Verification Commands.
   * A CI emulator job, when F08-DEVOPS adds one (`release.md` §4, best-effort), must pin Java 21.
6. **Backend test-data defect — Backend Developer, F08-BE6.**
   * The test `infra/functions/test/submitDailyResult.test.ts` "ALREADY_SUBMITTED on a repeat" sends `moves: 8` against the base payload's `optimalMoves: 9`. `validate.ts` (`moves` min = `optimalMoves`) correctly returns `INVALID_PAYLOAD`, so the test fails for a reason unrelated to what it names.
   * The handler is right; the fixture is wrong. The suite has been 30 / 31 since it was first run against the emulator.
   * F08.EMULATOR cannot pass on a red suite, so the fix comes before QA.
   * The behaviour itself is also shown client ↔ emulator (LE-04 D). That is supporting evidence only; it does not replace the suite.
7. **Identity after a recreate — Accepted as a note, no change.**
   * On iOS the anonymous Firebase user lives in the Keychain and survives a store recreate. The new `guestId` is linked to the same `firebaseUid`.
   * A recreated store's later run of a day already submitted is therefore `ALREADY_SUBMITTED`. That is consistent with first-run-authoritative and the create-only rule (Guest Identity Model: `firebaseUid` is the server identity).
   * The quarantined bytes remain the support path (A1 rule 2).
8. **Emulator run procedure** (`frontend.md` §16.4): a simulator that was ever signed in to the real project needs `xcrun simctl keychain <udid> reset` before an emulator run. Otherwise the real anonymous user is restored and the Auth emulator rejects its token. This is part of the QA method, not a defect.

**Delivery Review:** F08-FE13 and F08-LOCAL-EVIDENCE are accepted. The feature-level review stays Pending until F08-BE6 is reconciled.

### A7. F08-QA-FUNCTIONAL plan (locked now; activated at the checkpoint after F08-BE6)

**Stage:** functional (Release Scope `production-readiness`; the release stage stays blocked on F08.DEPLOY-AUTHORIZATION).

**QA Modules:**
* `core`;
* `backend-security` — callable validation, create-only rules, auth-scoped path;
* `client-ui` — the store-error → Retry → Home flow, the debug-only route that must not exist in release;
* `stateful-flow` — persistence, resume, migration, queue lifecycle, cold boot.

`visual-quality` is not included (Visual Scope `none`). `release` is not included in the functional stage.

**Regression Depth:** `full`. FE13 touches startup / routing, persistence and migration, and the Firebase init path shared by F03 / F04 / F05.

**Evidence Reuse:** `invalidated` for the app side. The earlier F08 QA (2026-09-06) and F05-QA-D3 E05 / E06 / E09 are at earlier trees, and FE13 changes the open path and the bootstrap. They are supporting evidence only. The unchanged backend handler / rules source may be reused if QA confirms that its fingerprint is unchanged since 8479ddb; the test files change in F08-BE6.

**Critical journeys (start → action → visible result):**
1. Unreadable store (`seed-d3.sh corrupt`) → cold launch → Home "new":
   * one quarantine file;
   * the `db_reinitialized` log;
   * a second corruption keeps only the newest quarantine;
   * a recreate that also fails → the error screen, no second recreate in the launch (automated).
2. Transient open failure (e.g. a directory at the store path) → error screen → remove the cause → Retry → Home, no relaunch.
3. Migration failure (automated, real file DB) → error screen, rows and `user_version` intact, no quarantine, `migration_failed` log.
4. Resume: a frozen-tile level with moves + undo + restart + thaw → kill → relaunch → exact restore; tampered `thawedFrozenCells` → re-derived.
5. Exactly-once against the emulator (the six A4 cases). "Offline" is the functions proxy / emulator being down — not airplane mode, and stated as such.
6. Lifecycle: leave the triggering screen mid-sync → the doc arrives; paused / resumed → drain; connectivity regain → drain (automated + N-REGAIN; the simulator cannot toggle it).
7. Production-shaped cold boot, empty and existing store: no light frame, no init error.
8. Offline Journey (AC2) — only if the user has run `evidence/offline-journey.sh` on a real no-network runtime. Otherwise it stays PENDING with that prerequisite; it is not replaced by a simulated offline mode.

**Misuse / negative checks QA runs itself:**
* re-run the named negatives — at least N-CLASS, N-LOOP, N-RETRY, N-TXN, N-FULL, N-GATE — and the backend negative from F08-BE6;
* rules: create-other, update, delete and read are denied;
* callable: an invalid payload → `INVALID_PAYLOAD` → the client parks the item;
* the release binary contains none of the emulator / debug-route strings.

**Methods:**
* iPhone 16 simulator (iOS 18.6) debug builds;
* Java 21 for the emulator suite: `JAVA_HOME=/opt/homebrew/opt/openjdk@21 PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH` (*corrected at A8 — `JAVA_HOME` alone is not enough*);
* the keychain reset from A6 ruling 8;
* no real Firebase project write beyond the existing production-shaped anonymous sign-in, no deploy, no billing.

**Exit (functional):**
* every F08 Pending Evidence record in scope is PASS, or explicitly PENDING with an owner and a prerequisite;
* the verdict is Functional Approved, or Runtime Validation Pending if AC2 is still missing.

**Known limits (not findings):**
* Clock (AC10) is automated-only.
* Offline Daily (AC3) is F07.
* The Remote Config kill-switch wiring is F07 (A6 ruling 4).
* The profile / release store-error capture is FIRST-APP-DISTRIBUTION.

### A8. Implementation checkpoint 2026-09-29 (F08-BE6, commit c70527a)

**Delivery reviewed:** `backend.md` → "F08-BE6"; the diff of `infra/functions/test/submitDailyResult.test.ts`; `evidence/neg-be6.py`; the logs `BE6-00` to `BE6-04`; the validator (`src/validate.ts`) and `firestore.rules`.

**Fingerprints at c70527a** (they match `backend.md`):
* the test `cf73770d…`;
* the handler `submitDailyResult.ts` `bcda2662…`;
* `validate.ts` `8f0398ea…`;
* `firestore.rules` `b75628e6…`.

`src/` and the rules are unchanged since 8479ddb.

**Tech Lead re-run (not a QA claim):**
* Command: `npm run build`, then `JAVA_HOME=/opt/homebrew/opt/openjdk@21 PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm run test:emulator`.
* Where: `infra/functions` at c70527a, 2026-09-29T09:29Z, macOS host.
* Result: Test Suites 3 / 3, Tests 31 / 31, exit 0.
* Jest printed "A worker process has failed to exit gracefully". The same line is in the backend logs. It is a teardown leak in the test harness, not a failure; see ruling 4.

**Task coverage:**
* F08-BE6 is closed. The second call is now a valid "better" replay: `moves: 10` (≥ `optimalMoves` 9), `stars: 3`, `durationMs: 40000`. The validator has no other rule that couples these fields, so the call reaches the `snapshot.exists` branch the test names.
* The assertions are kept and made stronger: the stored `durationMs` and `recordedAtUtcMs` must not change either.
* The scan of the other two test files found no fixture of the same kind.

**Contract compliance:** only test code changed. The callable contract, the validation, the rules and the error format are unchanged.

**Evidence quality:**
* The negative run is real. N-OVERWRITE makes the handler overwrite an existing entry; the fixed test fails with `Expected "ALREADY_SUBMITTED", Received "CREATED"`.
* N-OVERWRITE-OLDFIX shows why the fix matters. With the old fixture the test failed for the validation reason whether the handler was broken or not, so it could never catch this regression.
* Both files were restored byte for byte, and the SHA-1s were checked.

**Rulings:**
1. **F08-BE6 — Accepted.**
   * F08.EMULATOR now has a green suite and a named negative. It stays PENDING until QA re-runs it; it is a QA-owned record.
2. **The Java 21 command — corrected** (`backend.md` §14.1).
   * `JAVA_HOME` alone is not enough: firebase-tools uses the first `java` on `PATH`. The attempt in `BE6-01` shows the failure.
   * The canonical command in `project-authority/setup-manifest.md` now also puts Java 21 first on `PATH`. The same correction is made in the A4 table and the A7 methods.
3. **The CI emulator step — the premise of A6 ruling 5 is corrected** (`backend.md` §14.2).
   * A6 ruling 5 said "when F08-DEVOPS adds one". That is wrong. `.github/workflows/ci.yml` → job `infra` → "Test functions (Firebase emulator — rules + callable behaviour)" has existed since F08-BE5. It runs `npx --yes firebase-tools@15 emulators:exec …`.
   * The step is **CI-wired but has never been CI-executed**. The GitHub Actions API reports 0 runs for the repository, and `origin/main` is still the bootstrap commit b1a65a0. So no CI result exists, red or green.
   * When it first runs, it will probably fail. firebase-tools 15 needs Java 21. The step relies on the runner's default Java, which is probably 17 on `ubuntu-latest` (*Needs verification* from a real run). Until BE6 it would also have failed on the fixture.
   * The fix is CI config. It belongs to DevOps/Release Engineer, not to the Tech Lead or the Backend Developer. Recorded as the follow-up **CI-EMULATOR-JAVA21** (`workflow-follow-ups.md`), next to CI-FORMAT-GATE. F08-DEVOPS carries it too.
   * **It does not block F08-QA-FUNCTIONAL.** F08.EMULATOR allows an isolated local emulator run, and QA runs it locally.
4. **Jest teardown warning — a note, no task.**
   * "A worker process has failed to exit gracefully" appears on green and red runs alike, and the exit code is right each time.
   * QA records it if it hides a failure; otherwise it stays a harness note.
5. **`firestore.rules` has no `!exists(...)` — Accepted as equivalent; no change** (`backend.md` §14.3).
   * The locked Rules section writes `… && !exists(...)`. Firestore evaluates `create` only when the document does not exist, and a write to an existing document is an `update`, which is always `false`. The meaning is the same.
   * `rules.test.ts` → "denies update" covers it. QA's rules checks (create-other, update, delete, read denied) stay as they are in A7.

**Delivery Review: Accepted** for F08-FE13, F08-LOCAL-EVIDENCE and F08-BE6.

**QA:** F08-QA-FUNCTIONAL is active under the plan locked in A7. Two changes:
* the method correction in ruling 2;
* the backend negative to re-run is N-OVERWRITE (`evidence/neg-be6.py`).

The backend handler and rules fingerprints above are the ones A7's reuse clause refers to. The test files changed in BE6, so QA re-runs the suite and does not reuse the old result.

### A9. QA checkpoint 2026-09-29 (F08-QA-FUNCTIONAL — verdict Decision Pending, commit d882211)

**Verdict reviewed:** `qa.md` → "F08-QA-FUNCTIONAL" (§0–§7) and its evidence in `qa/functional/`. QA tested HEAD 84430c9: `app/` tree `9de12e6a…`; `firestore.rules` `b75628e6…`; the handler `bcda2662…`; `validate.ts` `8f0398ea…`; the test `cf73770d…`. The Tech Lead checked that these SHA-1s are still the working tree's.

**Result of the stage:**
* PASS, run by QA this turn: F08.EMULATOR (31 / 31, N-OVERWRITE caught), F08.LOCAL-RESUME, F08.LIFECYCLE, F08.COLD-BOOT-REVIEW, F08.UNREADABLE-DB, F08.STORAGE; every A7 journey except J8; every misuse check except the rules probe below; the release binary gate.
* PENDING: F08.OFFLINE-JOURNEY (AC2) — the user's no-network run.
* **F1 (High, security — authority conflict):** QA's own rules probe (`qa/functional/qa-probe-rules.test.ts`, log `QB-05-rules-probe.log`) shows that a signed-in client can skip the callable. P3: a direct create of its own entry with `moves 1 < optimalMoves 9`, `stars 9` and an extra field — ALLOWED. P6: a direct create under the bucket `zz_not-a-date-123` — ALLOWED.

**Tech Lead verification of F1:**
* `infra/firestore.rules` allows `create` when `request.auth.uid == uid` and checks nothing else. That is exactly what the locked Rules row said.
* The callable writes through `firebase-admin/firestore` (`submitDailyResult.ts`). Security rules do not apply to the Admin SDK, so the callable does not need any client rule.
* The app never writes Firestore directly. The only `cloud_firestore` use in `app/lib` is `firebase_emulator.dart`, the debug emulator wiring.
* So the client `allow create` rule serves no shipped path. It is only a bypass.

**Rulings:**
1. **F1 — resolved as a Technical Decision: clients get no access to `dailyResults/**`.**
   * The locked section contradicted itself. Its decision says the sync surface is the callable and "a direct client create-only write was considered and rejected", and the document is "server-written". Its Rules row still allowed that rejected write. `platform.md` §6 carried the same wording from before the callable decision (the F08 PRD had left "callable or direct write" open).
   * The decision wins over the stale row. The Rules row, "Reconciliation Algorithm → Server", "Validation Responsibility", "QA Focus → Rules" and `platform.md` §6 / §8 are corrected now.
   * **Rejected alternative — validate the fields and the bucket in the rules.** It would keep a second write path that the contract already rejected, and duplicate the callable's validation in a language where cross-field rules are hard to keep in sync. It gives nothing the callable does not.
   * **What does not change:** the callable, its validation, its error format and its create-only transaction; the client mapping; the app. AC4 / AC5 / AC11 are still proved through the callable. No product criterion changes, so no Product Owner revision is needed.
   * **Effect:** a player can no longer pre-write a fake "first run" that the callable would then protect with `ALREADY_SUBMITTED`, and no client can create documents under invented bucket names.
2. **F08-BE7 is opened (Backend Developer):** apply ruling 1 in `infra/firestore.rules` and `infra/functions/test/rules.test.ts`, with a named negative. Brief: `orchestration.md` → Current Brief.
3. **Evidence:** F08.EMULATOR goes back to PENDING. Its callable and idempotency part stays valid for the unchanged handler, but its rules part is at the old rules, and the rules and their test change in BE7. QA re-runs it at the BE7 revision. The other PASS records stay PASS; the app is not touched.
4. **QA re-run plan — F08-QA-FUNCTIONAL-R1** (locked now; activated at the BE7 checkpoint after the preflight):
   * **Stage:** functional. **Scope:** end-to-end.
   * **Modules:** `core`, `backend-security`, `client-ui`, `stateful-flow`. `client-ui` stays because the scope is end-to-end; its evidence can be reused.
   * **Regression Depth:** `full` — an auth / security rule changes.
   * **Evidence Reuse:** `allowed`, only while these fingerprints are unchanged: `app/` tree `9de12e6a…`; the handler `bcda2662…`; `validate.ts` `8f0398ea…`; `submitDailyResult.test.ts` `cf73770d…`. Everything tied to `firestore.rules` or `rules.test.ts` is `invalidated` and re-run. If a fingerprint differs, QA re-runs what depends on it.
   * **QA runs itself:**
     * the emulator suite at the BE7 revision (the setup-manifest command);
     * N-OVERWRITE again (`evidence/neg-be6.py`) and the BE7 negative;
     * its own rules probe P1–P6 — P3 and P6 must now be DENIED, and P1, P2, P4, P5 stay denied;
     * one client ↔ emulator exactly-once case (QE-A shape) with the new rules loaded in the emulator — it shows that the callable still writes and the app still syncs;
     * AC2 / J8, if the user has run `evidence/offline-journey.sh` by then.
   * **Verdict:** Functional Approved only if every in-scope record is PASS; Runtime Validation Pending if only F08.OFFLINE-JOURNEY is missing; Rejected with findings.
5. **QA's non-blocking notes:**
   * N1 (no timer — a due item waits for the next trigger): conforms to "Ownership & Lifecycle"; no change.
   * N2 (`evidence/fn-proxy.py` closes the connection on an upstream 4xx / 5xx, so the client sees a network drop): a defect in the delivered evidence tool, not in the app. LE-04 therefore never tested an error response through the proxy; QA's corrected copy covered it (QE-M). Recorded as the follow-up **F08-EVIDENCE-PROXY-ERRORS** (Frontend/Mobile Developer, non-blocking). QA keeps using its own copy.
   * N3 (the Jest teardown line): as A8 ruling 4.
   * N4 (the CI emulator step never ran): CI-EMULATOR-JAVA21, as A8 ruling 3.
6. **Release:** the new rules ship in the same first Firebase deploy, so the release scope does not change and nothing is deployed now. The F08-DEVOPS rollback check "create-own allowed / create-other denied" (`release.md` → rollback table) is out of date. When F08-DEVOPS resumes, DevOps/Release Engineer changes it to "a direct client create is denied; the callable creates". F1 must be closed before any deploy.

**Delivery Review:** Pending until F08-BE7 is reconciled at the next Tech Lead checkpoint.

### A10. Implementation checkpoint 2026-09-29 (F08-BE7, commit cb96719)

**Delivery reviewed:** `backend.md` → "F08-BE7"; the diff of `infra/firestore.rules`, `infra/functions/test/rules.test.ts` and `infra/README.md` at cb96719; `evidence/neg-be7.py`; the logs `BE7-00` to `BE7-04`.

**Fingerprints at cb96719** (they match `backend.md`):
* `firestore.rules` `aa4c5dc2…` (was `b75628e6…`);
* `rules.test.ts` `2c7df84a…` (was `9d4db0bb…`);
* unchanged: the handler `bcda2662…`, `validate.ts` `8f0398ea…`, `submitDailyResult.test.ts` `cf73770d…`; `app/` tree `9de12e6a…`.

**Tech Lead re-run (not a QA claim):**
* The emulator suite with the setup-manifest command, `infra/functions` at cb96719, 2026-09-29T10:32Z, macOS host: Test Suites 3 / 3, Tests 33 / 33, exit 0.
* `python3 evidence/neg-be7.py`: N-DIRECT-CREATE — exit 1, 3 failed / 5 passed / 8; the three failures are exactly the own-entry, invalid-payload and non-date-bucket tests; the rules restored byte for byte. The script rewrites `runtime/BE7-04-neg.log.txt`; the delivery's copy was restored from git, so that file stays the developer's evidence.

**Task coverage:** F08-BE7 is closed. All five brief items are done: the rules deny every client access; the own-entry create is now denied, and the P3 and P6 shapes are two new tests; the named negative; build, `npm test` (18 passed, 15 skipped) and the emulator suite; the `infra/README.md` row.

**Contract compliance:** the rules match the corrected Rules row. The callable, the validation, the error format and the create-only transaction are unchanged. The callable suite passes with the new rules loaded in the emulator, so the server path still writes. No app change.

**Evidence quality:**
* Every rules test is now an `assertFails`, so a green rules suite alone would not show that the rules are the reason. The negative run does: with the old rule back, exactly the three new tests fail, and the other five pass under both rules. `assertFails` requires a permission-denied error, so a broken connection would not pass as a denial.
* The one invocation error before `BE7-02` (a `--verbose` argument that firebase-tools rejected; no test ran) is disclosed in the log and in `backend.md`. It is not a result.
* Not run in BE7 and not claimed: the app ↔ emulator path under the new rules. It is in the QA plan (A9 ruling 4).

**Rulings:**
1. **F08-BE7 — Accepted.** QA finding F1 is fixed in code. It is not closed until QA re-runs its own rules probe (P3 / P6 must be DENIED).
2. **F08.EMULATOR stays PENDING** — it is QA's record; QA re-runs it at cb96719 or later.
3. **F08-QA-FUNCTIONAL-R1 — activated** under A9 ruling 4, unchanged. Evidence reuse is allowed because the four fingerprints A9 names are unchanged at cb96719 (checked above).

**Delivery Review: Accepted** for F08-FE13, F08-LOCAL-EVIDENCE, F08-BE6 and F08-BE7.

### A11. QA checkpoint 2026-09-29 (F08-QA-FUNCTIONAL-R1 — verdict Runtime Validation Pending)

**Verdict reviewed:** `qa.md` → "F08-QA-FUNCTIONAL-R1" (§0–§7) and `qa/functional-r1/`. QA tested HEAD 695f783. The Tech Lead checked that the fingerprints QA records are still the working tree's: `firestore.rules` `aa4c5dc2…`, `rules.test.ts` `2c7df84a…`, the handler `bcda2662…`, `validate.ts` `8f0398ea…`, `submitDailyResult.test.ts` `cf73770d…`, `app/` tree `9de12e6a…`. `infra/` and `app/` have no uncommitted change.

**Evidence checked (logs read, not re-run):**
* the emulator suite 33 / 33, exit 0 (`QB-R1-03`);
* QA's own rules probe 8 / 8 — P3 and P6 are now `assertFails`, and each also checks that no document was written (`QB-R1-06`);
* the same probe against the old rules `b75628e6…` fails exactly P3 and P6 (`QB-R1-07`). So the probe detects F1; it is not a probe that passes under any rules;
* a direct REST create against the running emulator returns 403 twice and writes nothing (`QE-R1-00`). So the emulator in the client run had the new rules loaded;
* the client ↔ emulator case: `down` → one `pending` item and 0 documents; `pass` → `CREATED`, one document, queue and entry `synced`; two requests in total (`QE-R1-cases.txt`, `QE-R1-proxy.log`).
* The reuse list is sound. Since 84430c9 only `infra/firestore.rules`, `rules.test.ts` and `infra/README.md` changed outside `ai-system/`. The app, packages, tools and both lockfiles are identical, and the app never writes Firestore directly (A9).

**Rulings:**
1. **F1 — closed.** The fix is in code (A10), and QA's own probe now shows P3 and P6 denied. The condition "F1 must be closed before any deploy" (A9 ruling 6) is met.
2. **F08.EMULATOR — PASS**, accepted as QA recorded it. The other PASS records stay PASS by fingerprint.
3. **N1-R1 (the first retry comes after ≈ 60 s, not 30 s) — Technical Decision: the delivered schedule is the contract.** The PRD marks the backoff schedule `[Technical]`. The locked line gave the base and the factor but not the first delay. The code uses `30 s × 2^attemptCount`, counted after each failure. It keeps the cap, the jitter, the attempt cap and exactly-once unchanged. A 30 s first retry would give no player-visible benefit; drains also run on connectivity regain, pause/resume and app start. The Backoff line is clarified; no code or test change. A test that pins the first delay is optional (the next time `sync_test.dart` is touched).
4. **F08.OFFLINE-JOURNEY (AC2) is the only open functional scenario.** It needs a real no-network runtime (A4). Only the user can provide it: the script turns the Mac's Wi-Fi off, and Claude does not change system settings. No delivery role has executable work on it. So F08 becomes **Blocked**. The blocking scope is the environment prerequisite, not a defect. Owner and next role: Tech Lead.
   * **F08-QA-FUNCTIONAL-R2** (QA, targeted, reuse allowed) is added **Blocked** on the user's run. After the run, the Tech Lead checks that the output exists and the fingerprints are unchanged, then activates it. Its plan (locked now): stage functional; scope end-to-end; modules `core`, `client-ui`, `stateful-flow` (no backend change since R1); regression depth `targeted` — only AC2 / J8 are new, and nothing else changed; evidence reuse `allowed` by the R1 fingerprints.
   * **Preparing the run is part of the user's instructions** (orchestration → Current Brief). The simulator must first get a debug build **without** the emulator define: uninstall, reset the simulator keychain, install, and launch once while online, so that a store exists before the script starts.
5. **Release:** unchanged. F08-DEVOPS stays Blocked on F08.DEPLOY-AUTHORIZATION. Its A9 ruling 6 item (the rollback check "a direct client create is denied; the callable creates") and CI-EMULATOR-JAVA21 still apply when it resumes.
6. **Non-blocking notes carried:** N1 (no timer), N3 (Jest teardown line), N4 (CI-EMULATOR-JAVA21), F08-EVIDENCE-PROXY-ERRORS — as A9 ruling 5.

**Delivery Review:** Accepted (unchanged; no delivery since A10).

### A12. Intake 2026-09-29 — the user's no-network run (F08.OFFLINE-JOURNEY)

**Input:** `Run Tech Lead. Incident:` — the user's step-by-step report and console output of `evidence/offline-journey.sh`. It reports no defect: it completes A11 ruling 4's prerequisite.
* **Classified Scope:** Insufficient Evidence — a false alarm as an incident; a status report.
* **Workflow Impact:** Continue Current Flow.

**Tech Lead checks:**
* **Outputs:** all six files are present in `evidence/runtime/offline/`.
  * Offline at the start (14:07:49Z) and at the offline relaunch (14:09:45Z).
  * Store before: level 1 unlocked, nothing completed. Store after: levels 1 and 2 completed, 3 unlocked, two bests.
  * Screenshots: the result of level 2, and Home "2 / 30" after the offline relaunch.
* **Build:**
  * The installed `Runner.app` has the same timestamp (14:05:34Z) as the last build.
  * That build's `DART_DEFINES` (`app/ios/Flutter/Generated.xcconfig`) carry no `LOOPLET_FIREBASE_EMULATOR`.
  * The store's `firebase_uid` is set, and the emulators were down, so the online launch signed in to the configured project.
  * So the run used the production-shaped path.
* **Fingerprints of A11 hold:** `app/` `9de12e6a…`, rules `aa4c5dc2…`, handler `bcda2662…`, `validate.ts` `8f0398ea…`, callable test `cf73770d…`; `app/` and `infra/` are clean. HEAD 4cb836a — the F08-QA-FUNCTIONAL-R1 verdict, committed by the user.
* **Deviations from the steps:**
  * the Wi-Fi was switched off by hand before the script;
  * two levels were played instead of one;
  * the app was not quit by hand; the script terminates it before its offline launch.
  * None of these obviously invalidates the run; QA judges.

**Rulings:**
1. **The run is valid input for AC2.** It is the user's evidence, not a PASS; QA judges it.
2. **F08-QA-FUNCTIONAL-R2 is activated** under A11 ruling 4, corrected by ruling 4 below: functional; end-to-end; `core`, `backend-security`, `client-ui`, `stateful-flow`; `targeted`; reuse `allowed`. QA Result → None; Blockers → None.
3. **"All 30 levels load"** (QA Focus → Offline Journey) is QA's call from the evidence. If QA needs another no-network run, it names exactly what the run must capture, and the verdict is Runtime Validation Pending.
4. **Correction to A11 ruling 4 — `backend-security` added.**
   * The QA preflight failed on the A11 plan: an end-to-end scope requires `backend-security`. The core QA prompt also calls a plan invalid when the scope and the required modules disagree.
   * Narrowing the scope to the client is rejected. R2's verdict closes the whole functional stage, which is end-to-end.
   * The backend is unchanged since R1: the rules, handler, validator and callable test fingerprints are the same. So the module's build/test prerequisite and its compliance tables are met by reusing R1's backend evidence by fingerprint (QB-R1-01…07, QE-R1-00, QE-R1-A). QA re-runs it only if a backend fingerprint differs.
   * Depth stays `targeted`.

### A13. QA checkpoint 2026-09-29 (F08-QA-FUNCTIONAL-R2 — verdict Functional Approved, commit 0d65c73)

**Verdict reviewed:** `qa.md` → "F08-QA-FUNCTIONAL-R2" and `qa/functional-r2/`. The Tech Lead read the probe log (30 / 30 levels opened), its control (it fails at level 17 exactly), the gate tests (30 / 30), the bundle comparison (31 / 31 byte-identical) and the build provenance (no emulator define). No probe file is left in `app/test/`. The fingerprints are unchanged: `app/` `9de12e6a…`, rules `aa4c5dc2…`, handler `bcda2662…`, `validate.ts` `8f0398ea…`.

**Assessment:**
* **AC2 is met.** The user's offline run shows levels 1–2 completed and level 3 opened offline, and the progress intact after an offline cold relaunch. QA checked this at store level, including the timestamps.
* **"All 30 levels load"** is covered by a sound argument, not only by a sample:
  * the level-open path is the same for every level and uses no network;
  * that path ran offline at runtime;
  * the same production path opens all 30 levels;
  * the 30 installed assets are byte-identical to the source.
* **N1-R2** is an honest limit, not a gap: levels 4–30 were not opened at the offline runtime. A full offline device tour can ride FIRST-APP-DISTRIBUTION; F08 does not need it.

**Rulings:**
1. **F08-QA-FUNCTIONAL-R2 — accepted. The functional stage is closed.**
   * **QA Result:** Functional Approved.
   * **Evidence:** every functional record is PASS — F08.EMULATOR, LOCAL-RESUME, LIFECYCLE, OFFLINE-JOURNEY, STORAGE, COLD-BOOT-REVIEW, UNREADABLE-DB.
   * **Not Done yet.** Release Scope is `production-readiness`, so F08 still needs release readiness and final QA.
2. **The release stage waits on the user. `F08-DEVOPS` is split, and both parts are Blocked.**
   * Contract §5.3: an OPEN release-scoped decision gate does not stop developer work or functional QA, but **DevOps activation, final QA and Done wait**. F08.DEPLOY-AUTHORIZATION is such a gate. The workflow audit enforces this.
     * This checkpoint first opened a local prep task for DevOps. The audit refused it, and the rule is right: a release-scoped gate holds every DevOps activation, not only the deploy. That draft was not kept.
   * F08 has no other executable work, so F08 is **Blocked**, and the owner and next role are Tech Lead.
   * **F08-DEVOPS-PREP** (DevOps/Release Engineer, **Blocked**) is the local release work that needs neither a deploy nor a push. It runs first once the gates allow a DevOps activation.
     * **(a) CI on Java 21.** Put Java 21 on `PATH` for the `infra` job's emulator step in `.github/workflows/ci.yml` (CI-EMULATOR-JAVA21), with any new action pinned to a commit SHA (`release.md` §10). Verify locally: the workflow file parses, and the same command passes on Java 21.
     * **(b) Refresh the feature `release.md` to the current contract.**
       * The rules rollback check and smoke S1 become "a direct client create is denied; the callable creates" (A9 ruling 6).
       * The storage-full residual test-debt line is out of date (F08.STORAGE PASS).
       * The gate evidence points to the functional QA records (R1 / R2).
       * Re-check the deploy runbook and the smoke list against the current rules and code.
     * **(c) Record a readiness verdict** in `release.md` and in the Release Result field.
     * **Non-goals:** no deploy, no billing, no Remote Config change, no push without the user's approval, no app or rules change.
   * **F08-DEVOPS** (Blocked, after the prep) covers the first real CI run, the authorized deploy per the runbook, and the post-deploy smoke (F08.DEPLOY-SMOKE).
3. **New decision gate — F08.CI-FIRST-PUSH** (Blocking Scope: release). CI has never run: `origin/main` is still the bootstrap commit b1a65a0. The first real run needs the local `main` pushed to `origin` (`github.com/eyupdabakoglu92/Looplet`). That publishes the whole working history, including `ai-system/`, to that repository. It is the user's call.
   * Options: (1) push `main` once F08-DEVOPS-PREP is done; (2) push only a branch; (3) keep CI local-only for now, and the CI evidence stays PENDING.
   * Recommendation: option 1 or 2, if the repository's visibility is what the user intends.
4. **F08.DEPLOY-AUTHORIZATION stays OPEN**; nothing changes without the user's decision.
   * The user answers with `Run Tech Lead. Decision: F08.DEPLOY-AUTHORIZATION — <karar>` and `Run Tech Lead. Decision: F08.CI-FIRST-PUSH — <karar>`.
   * If both are approved, the next Tech Lead turn activates F08-DEVOPS-PREP, then F08-DEVOPS.
   * If the deploy stays deferred, F08 stays Blocked with its functional acceptance intact. The Tech Lead then chooses the next executable feature (feature-selection rules: Blocked features are skipped). F09 depends only on F03; F07 depends on F08's release too.
5. **Final QA (F08-QA-FINAL)** stays Queued behind F08-DEVOPS. The functional evidence can be reused there by fingerprint.

**Delivery Review:** Accepted (unchanged).

### A14. Decision F08.CI-FIRST-PUSH (2026-09-29) — the user pushed `main`

**Input:** `Run Tech Lead. Decision: F08.CI-FIRST-PUSH — Ben push işlemini yaptım` ("I did the push").
* Exactly one OPEN gate matched. Classified as option (1), push `main`.
* The user ran the push, not Claude.

**Tech Lead verification (read-only):**
* **Remote:** `git ls-remote origin` → `refs/heads/main` = `8a0522f` (the A13 checkpoint) = the local `main`. The working tree is clean.
* **Visibility:** the repository `github.com/eyupdabakoglu92/Looplet` is **public**. The whole history, `ai-system/` included, is now published.
* **Tracked-file scan:** no private key, service-account file, token or `.env` is tracked. The Firebase client configs `app/android/app/google-services.json` and `app/ios/Runner/GoogleService-Info.plist` are public by design (Firebase client identifiers), but they are now world-readable.
* **CI run #1** — GitHub Actions run `36590316947` (workflow CI, event push, head `8a0522f`, 2026-09-29T15:27:22Z):
  * **`infra · functions build + test` — failure** (57 s). Checkout, Node, `npm ci`, `tsc` and the offline tests passed. **"Test functions (Firebase emulator — rules + callable behaviour)" failed**: "Process completed with exit code 1".
  * The step log needs a signed-in GitHub account ("Sign in to view logs"); the Tech Lead did not sign in. **The cause is not verified.** A failure right after the step starts fits the known risk CI-EMULATOR-JAVA21: firebase-tools 15 needs Java 21, and the runner's default is probably older.
  * The same suite passes locally on Java 21 (QB-R1-03, 33 / 33). This is a CI environment defect, not a functional regression.
  * `format · analyze · test` — **failure at "Format check"**, as CI-FORMAT-GATE predicted (a pre-existing F00 QA probe file). `iOS release build (no codesign)` was still running at the time of this record.
  * Notices: Node 20 actions are forced onto Node 24 (the pinned `actions/checkout`); `ubuntu-latest` moves to Ubuntu 26 from 2026-10-19.

**Rulings:**
1. **F08.CI-FIRST-PUSH — RESOLVED:** the user pushed `main` (option 1) to the public `origin`. CI now runs on every push to `main`.
2. **The CI evidence is no longer "never run" — it is FAIL.** CI-EMULATOR-JAVA21 is confirmed as a real failing gate, cause pending verification. It stays in **F08-DEVOPS-PREP**, which also gains:
   * **(d) the first run's other results** — read the full run, including the format gate (CI-FORMAT-GATE) and the iOS build, and fix or route each red step. Reading the logs needs a signed-in account: the DevOps role uses the user's `gh` / browser session only if the user provides it; otherwise it asks the user for the log text;
   * **(e) public-repository hygiene** — check that the Firebase API keys are restricted (application / API restrictions) and note App Check's monitor mode for a public client config. Any console change is an account-settings change: recommend it, and the user approves or makes it;
   * **(f)** the Node 20 → 24 action notice and the Ubuntu 26 migration: pin or update the affected actions.
3. **F08 stays Blocked.** F08.DEPLOY-AUTHORIZATION is still OPEN with Blocking Scope release, and it holds every DevOps activation (contract §5.3). The CI fix waits on the same gate.
   * This means a red CI stays red until the user decides the deploy. That is the contract's rule for a release-scoped gate, and it is recorded here so the user can see the trade-off.
   * If the user wants the CI fixed first without deciding the deploy, the gate's scope is the thing to change — by a new user decision, not a Tech Lead shortcut.
4. **Global risk added:** the public repository (ruling 2 (e)); CI's first run is red.

### A15. Incident 2026-09-29 — CI run #1 logs (the user pasted them)

**Input:** `Run Tech Lead. Incident:` — the step logs of the three failed jobs of run `36590316947`. The user pasted them; they are data. They give the causes that A14 could not verify.

* **Classified Scope:** Existing Active Feature Rework — the F08 release stage (CI is `release.md` §4 scope; it sits in F08-DEVOPS-PREP since A13 / A14).
* **Affected feature:** F08 (release stage). The CI pipeline is shared, so every later feature inherits a red `main` until this is fixed.
* **Workflow Impact:** Continue Current Flow. F08 stays Blocked on F08.DEPLOY-AUTHORIZATION; the fixes are defined now and run in F08-DEVOPS-PREP.

**Root causes (from the logs; reproduced locally where possible):**

1. **`infra` — the emulator step: Java.**
   * The log reads "firebase-tools no longer supports Java version before 21".
   * **Confirmed:** CI-EMULATOR-JAVA21 is the cause. The code is not at fault: the same suite passes locally on Java 21 (QB-R1-03).
2. **`format · analyze · test` — Format check: two QA evidence files under `ai-system/`.**
   * `melos run format:check` runs `dart format … .` over the whole repository. It flags exactly `ai-system/features/f00-design-foundation/qa/src/qa_probe_main.dart` (since 3647cef, known as CI-FORMAT-GATE) and `ai-system/features/f08-offline-persistence-and-sync/qa/functional-r2/qa_probe_all_levels_test.dart`.
     * The second file was added by F08-QA-FUNCTIONAL-R2 (0d65c73). That QA turn stored an unformatted probe under `ai-system/` and made the known red gate worse. Recorded as a process note; the probe's content is correct.
   * **Reproduced locally** with Dart 3.8.1: over `.` the same two files change; over `app packages tools`, 194 files and 0 changed.
   * The "Package resolution error … `package:lints/recommended.yaml`" lines are warnings. The root `analysis_options.yaml` cannot resolve `lints` for files outside a package. They are not the failure.
3. **iOS release build: toolchain drift. The code is not at fault.**
   * Swift errors in `firebase-ios-sdk/FirebaseSharedSwift/.../FirebaseDataEncoder.swift:288`: "Cannot find type 'sending' in scope". `sending` is Swift 6 syntax.
   * The failing path is `app/build/ios/SourcePackages/checkouts/firebase-ios-sdk`, so CI resolved the Firebase iOS SDK through **Swift Package Manager**.
   * Locally the app builds through **CocoaPods** (`Podfile.lock`: `FirebaseSharedSwift 11.15.0`), with Flutter **3.32.8**, Xcode **16.4** and Swift 6.1.2. SPM is not enabled locally.
   * CI installs **unpinned** Flutter (`subosito/flutter-action` with `channel: stable` and no version), so CI builds with a newer Flutter than the canonical local one. The `ios-build` job runs on **`macos-14`**, whose default Xcode predates Swift 6. So:
     * a newer Flutter plus SPM resolved a newer Firebase iOS SDK;
     * that SDK needs Swift 6;
     * the runner's Xcode cannot compile it.
   * *Inferred:* the exact Flutter / SDK / Xcode versions on the runner are not in the pasted log. The cause chain is consistent with every observed fact.
   * The same unpinned Flutter also runs the `format · analyze · test` job.

**Rulings (Technical Decisions — setup / CI authority; no product change):**
1. **TD-FORMAT-SCOPE — `format` / `format:check` cover only the Dart code the workspace owns: `app`, `packages`, `tools`.** This resolves CI-FORMAT-GATE.
   * Evidence under `ai-system/` is a record. It must not be rewritten to satisfy a formatter: the QA reports cite these files, and formatting them would change bytes that later turns may compare.
   * Future probes stored as evidence cannot break CI again.
   * `melos.yaml` and `setup-manifest.md` (the canonical command) change together, in F08-DEVOPS-PREP. `analyze` already runs per package, so no change there.
2. **TD-CI-TOOLCHAIN — CI uses the canonical local toolchain.**
   * **Flutter:** pinned to **3.32.8** in every CI job (`flutter-version`), matching the local environment every QA verdict was produced on.
   * **iOS job:** a runner / Xcode with Swift 6 support, at least Xcode 16.4, matching local. DevOps chooses between a newer macOS runner and an SHA-pinned Xcode selection. It verifies the Xcode version in the job log, and keeps the iOS dependency manager consistent with local (CocoaPods; SPM not enabled) unless a later Tech Lead decision changes it.
   * **`infra` job:** Java 21 first on `PATH` (CI-EMULATOR-JAVA21).
   * **A Flutter upgrade is a separate decision** — a dependency / toolchain change with full regression. It is not part of this fix.
3. **F08-DEVOPS-PREP scope updated** to these confirmed causes; (d)'s "read the logs" is done. A CI fix is proven only by a green run after a push; the push needs the user's approval in chat.
4. **F08.DEPLOY-AUTHORIZATION — options refined.** The fixes are ready to run, but the gate holds every DevOps activation (contract §5.3). The user now decides between:
   * **(A)** authorize the deploy — Blaze / billing and the named target. DevOps runs PREP, then the deploy.
   * **(B)** keep deferring the deploy, but allow the non-deploy release work now — PREP: the CI fixes, the `release.md` refresh, a readiness verdict. The Tech Lead records the deferral, resolves this gate, and opens a narrower gate, **F08.DEPLOY-GO**, that holds only F08-DEVOPS (deploy + smoke), final QA and Done.
   * **(C)** defer everything. F08 stays Blocked, and `main` stays red for every later feature.
   * **Recommendation: (B).** A green CI is needed whatever the deploy date, and it costs no billing.
5. **Process note (QA):** QA probe files stored as `.dart` under `ai-system/` are fine after TD-FORMAT-SCOPE. Until then, a QA turn that adds one worsens the red format gate. No retroactive change to the R2 evidence.

### A16. Decision F08.DEPLOY-AUTHORIZATION — B (2026-09-29)

**Input:** `Run Tech Lead. Decision: F08.DEPLOY-AUTHORIZATION — B`. Exactly one OPEN gate matched; option (B) as defined at A15 ruling 4.

**Decision recorded:**
* **The deploy stays deferred.** This is the 2026-09-06 deferral, confirmed by the user today. No Blaze plan, no billing, no Firebase deploy, no Remote Config change, no production action.
* **The non-deploy release work runs now:** F08-DEVOPS-PREP. That is the CI repair (TD-FORMAT-SCOPE, TD-CI-TOOLCHAIN, Java 21), the feature `release.md` refresh, public-repo hygiene recommendations, and a readiness verdict.
* No product criterion changes, so no Product Owner revision.

**Rulings:**
1. **F08.DEPLOY-AUTHORIZATION — RESOLVED (B).**
2. **F08-DEVOPS-PREP is activated.** F08 → In Release; Current Owner = Next Role = DevOps/Release Engineer; Blockers None. Its dependency F08-QA-FUNCTIONAL-R2 is Done.
3. **When F08.DEPLOY-GO opens — a correction to A15 ruling 4, which said "opens" at this turn.**
   * An OPEN release-scoped gate holds every DevOps activation (contract §5.3; the workflow audit enforces it). Opening F08.DEPLOY-GO now would block the very prep that option (B) releases.
   * So the Tech Lead opens F08.DEPLOY-GO at the **PREP checkpoint**, when F08 has no DevOps work left. Its question: may the first Firebase deploy run now, for which target and with which billing? It holds F08-DEVOPS (deploy + smoke), F08-QA-FINAL and Done.
   * **The deploy stays held in the meantime by four independent records:**
     * this recorded deferral;
     * F08-DEVOPS stays **Blocked**;
     * F08-DEVOPS-PREP's non-goals forbid any deploy, billing, Remote Config or console change;
     * project `release.md` §3: production requires approval.
4. **Push:** a CI fix is proven only by a green run after a push. Each push needs the user's explicit approval in chat for that push. The user may also push.
5. **Release Result** stays Release Validation Pending until the PREP verdict. `Release Ready` is impossible without the deploy smoke (F08.DEPLOY-SMOKE).

### A17. DevOps checkpoint 2026-09-29 (F08-DEVOPS-PREP — verdict Release Validation Pending, commit c592081)

**Delivery reviewed:** `release.md` (refreshed), `evidence/devops-prep/` DP-01…13, and the diff of c592081. It changes only `.github/workflows/ci.yml`, `melos.yaml`, `setup-manifest.md`, `infra/README.md` and `ai-system/` documents; there is no app, package, rules or function change. So no functional evidence is invalidated.

**CI run #2 — read by the Tech Lead through the public GitHub API and job page** (run `36597006854`, event push, head `c592081`, 16:20:36–16:40:12Z; the user pushed):
* **`format · analyze · test` — success** (`ubuntu-24.04`, 10 m 30 s). Format check, analyze, test, content check and the AAB build each succeeded. This is the first time analyze, test, the content check and the AAB build have run on CI (run #1 stopped at format).
* **`infra · functions build + test` — success** (`ubuntu-24.04`, 1 m 30 s). Set up Java 21, the offline tests and **the emulator step (rules + callable) succeeded**; CI-EMULATOR-JAVA21 is fixed.
* **`iOS release build (no codesign)` — success** (`macos-15`, 19 m 27 s). Select Xcode 16.4, disable SPM and the iOS build each succeeded; CI-IOS-TOOLCHAIN is fixed.
* **The integration step's own result: FAILED.** The `verify` job carries the annotation "Process completed with exit code 1". "Integration tests (play session — best-effort)" is the only `continue-on-error` step, and every other step succeeded, so the failure is that step. The job stays green by design. **The cause is not read:** step logs need a signed-in GitHub account. *Inferred:* `app/` has no `linux/` platform and the Ubuntu runner has no emulator, so `flutter test integration_test/` has no device to run on. This step has never run on CI before.
* **Printed versions: not read**, for the same reason. The versions are enforced by construction: `flutter-action` with `flutter-version: 3.32.8` fails if that version cannot be installed; the Xcode step exits 1 unless `/Applications/Xcode_16.4.app` exists; `setup-java` installs Temurin 21. The printed text is read in F08-DEVOPS (S1 at the deploy revision requires the `infra` log anyway). *Correction to `release.md` §10 item 1:* a public run's summary, steps and annotations are readable without signing in; its logs are not.
* **Annotations:** the Node 20 warning now names only `actions/cache@v4`, which `subosito/flutter-action` uses internally; the checkout warning and the Ubuntu 26 notice are gone.

**Rulings:**
1. **F08-DEVOPS-PREP — accepted. Delivery Review: Accepted.**
   * The CI repair is proven by a green run.
   * CI-FORMAT-GATE, CI-IOS-TOOLCHAIN and CI-EMULATOR-JAVA21 are **CLOSED**.
   * **Release Result stays Release Validation Pending.** What remains: the deploy decision, the deploy, F08.DEPLOY-SMOKE (S1 at the deploy revision, S2–S4), and final QA.
2. **TD-CI-INTEGRATION-GATE — the integration step is not a gate yet.**
   * Project `release.md` §4 said "not auto-blocking until F03 lands". F03 has landed, but CI never had the emulator that §4 assumes, so a blocking gate would turn `main` red on a step that has no device and gives no signal.
   * **Decision:** the step stays non-blocking. It becomes a **required gate at the first app-build release gate** (FIRST-APP-DISTRIBUTION), on a real emulator or simulator target. A green `verify` job never counts as an integration PASS (contract §9).
   * F08 does not depend on it: it is a backend-only release. The F03 play session is gated by the required mirror `play_session_runtime_test.dart` and by F03's runtime QA.
   * Project `release.md` §4 is amended. New follow-up **CI-INTEGRATION-TARGET** (DevOps/Release Engineer): read the step log, then give the step a real device target or remove it.
3. **N-1 — done.** The project `release.md` §4 format line now reads `app packages tools`.
4. **N-2 — accepted. The F08 deploy needs no kill-switch.** The Tech Lead checked the claim in the code:
   * `dailySyncEnabledProvider` is always on outside debug (`app/lib/persistence/sync_providers.dart`);
   * the debug sync route exists only under `kDebugMode` (`app_router.dart`);
   * `FakeDailyResultProducer` asserts it never runs in release.
   * So release builds send the callable no traffic before F07.
   * New F07 obligation (release-blocking for F07): **wire the Remote Config read of `daily_sync_enabled` before the Daily ships** — follow-up F07-KILL-SWITCH. The project `release.md` §2 note is amended.
5. **N-3 — TD-FUNCTIONS-RUNTIME: Cloud Functions move to Node.js 22.**
   * **Source:** the Google Cloud runtime-support page, read 2026-09-29.
     * Node.js 20: deprecated 2026-04-30; **decommissioned 2026-10-30**. "After the decommission date, you can no longer create new workloads or update existing workloads using the runtime."
     * Node.js 22: deprecated 2027-04-30; decommissioned 2027-10-31.
   * A Node 20 deploy after 2026-10-30 is impossible. A deploy before that date could never be updated. So the runtime changes **whatever the deploy date**.
   * **Node 22, not 24:** Node 22 is the current LTS that the installed `firebase-functions` 6.6 / `firebase-admin` 13.10 line supports. The CI `infra` job pins it explicitly in F08-DEVOPS instead of relying on the runner's default Node (reported as 22 in `release.md` §3; not verified). Node 24 would lengthen the runway by one year but has not been checked against this toolchain; the Backend Developer reports if 22 is not viable.
   * `platform.md` §3 and `setup-manifest.md` are amended. The implementation is **F08-BE8** (Backend Developer). This is developer work, so the release-scoped gate below does not hold it (contract §5.3).
   * **Evidence impact:** the handler and validator are unchanged. The local suites ran on the host's Node 24, not on Node 20, so the functional PASS is not tied to the runtime. F08.EMULATOR stays PASS. F08-QA-FINAL re-runs the suite at the final revision (dependency / build-config change → Regression Depth `full`).
6. **N-4 — the user's environment; not a gate.** The local Android build JDK is recorded in `setup-manifest.md`, with the non-global workaround. No global setting is changed here.
7. **N-5 and the deploy — new decision gate F08.DEPLOY-GO** (Blocking Scope: release), opened now as A16 ruling 3 planned. F08 has no DevOps work left. The gate holds F08-DEVOPS, F08-QA-FINAL and Done. It does not hold F08-BE8.
   * **(A) The full first deploy:** the Blaze plan with a budget alert; rules + Remote Config + the function (on Node 22, after F08-BE8) to `looplet-712e5`. F08-DEVOPS then:
     * reads the live project state;
     * pins Node 22 in the CI `infra` job;
     * needs a green CI at the deploy revision, with its logs read (S1);
     * deploys per the runbook and runs smoke S2–S4.
     * Then F08-QA-FINAL, then Done. This is the only route to F08 Done and to F07.
   * **(B) The rules only, now:** Spark, no billing.
     * DevOps reads the live Firestore rules and deploys the committed deny-all rules, then runs smoke S2.
     * The function and Remote Config deploys stay deferred. F08 stays in its release stage, and the Tech Lead narrows the remaining gate to the function deploy.
     * This closes the unknown exposure of a public client config pointing at a database whose rules are unknown (release.md §5 item 3).
   * **(C) Defer everything.** After F08-BE8, F08 is Blocked with its functional acceptance intact. The Tech Lead activates the next executable feature (F09 depends only on F03).
   * **Recommendation: (B)** while billing stays deferred. It removes the only live risk at no cost, and it is reversible. Choose (A) once billing is acceptable.
8. **Routing:**
   * F08 stays **In Release**.
   * **F08-BE8 Open:** Current Owner = Next Role = Backend Developer.
   * F08-DEVOPS Blocked on F08.DEPLOY-GO and F08-BE8; F08-QA-FINAL Queued.
   * The user can answer the gate while F08-BE8 runs. The Tech Lead checkpoint after F08-BE8 takes in the decision.

### A18. Implementation checkpoint 2026-09-29 (F08-BE8, commit 9f6b6e6)

**Delivery reviewed:** `backend.md` § F08-BE8, `evidence/runtime/BE8-00…03`, and the diff of 9f6b6e6. The diff touches only `infra/functions/package.json` (`engines.node` "22", `@types/node` `^22.20.4`), `package-lock.json` (the root and `@types/node` 20.19.43 → 22.20.4) and `infra/README.md`. `src/**`, `test/**`, `firestore.rules`, `firebase.json`, `.github/` and `app/` are unchanged.

**Tech Lead re-run at 9f6b6e6 (not a QA claim):** `npm ci` exit 0; `tsc` started by Node 22.23.3 exit 0; the emulator suite with firebase-tools and jest started by Node 22 (`jest host node: v22.23.3`) → 3 / 3 suites, **33 / 33**, exit 0. `origin/main` is still c592081, so CI has not run on 9f6b6e6.

**Assessment:**
* TD-FUNCTIONS-RUNTIME is implemented as ruled. The Node 22 proof is BE8-01 / BE8-02, where every tool is started directly by Node 22.
* The Backend Developer found that on this host an npm script runs the system Node, whatever Node is first on `PATH`. npm puts its global prefix bin, `/opt/homebrew/bin`, first on a script's `PATH`. This caught a wrong proof before it was recorded: BE8-03 is kept as the control and is marked as not Node 22 evidence. A good catch.
* **The host changed.** Installing `node@22` upgraded Homebrew's shared `simdjson` and broke the system `node` 24.7.0. With the user's choice, the system `node` is now `node@24` 24.21.0. `node@22` 22.23.3 is keg-only. The old keg is unlinked. No fingerprint depends on the host Node patch version.

**Rulings:**
1. **F08-BE8 — accepted.** Delivery Review: Accepted.
2. **`setup-manifest.md` records the local Node 22 check** as BE8-02's direct-invocation form, plus the npm-script `PATH` caveat, so that no later role repeats the wrong proof. The CI form stays valid on CI: the runner has one Node, and F08-DEVOPS pins 22.
3. **Runtime calendar:** the Google page (Node 22 decommissioned 2027-10-31) is authoritative over firebase-tools' own table (2028-10-31). `infra/README.md` already uses the earlier date. Re-check before each deploy.
4. **The old `node` 24.7.0 keg** is the user's to remove or keep; nothing depends on it.
5. **F08 has no executable work left.** F08-DEVOPS now waits only on F08.DEPLOY-GO (still OPEN, A17 ruling 7); F08-QA-FINAL stays Queued. **F08 → Blocked**; Current Owner = Next Role = Tech Lead. Functional acceptance and every functional evidence record stay intact.
   * The user's answer goes through `Run Tech Lead. Decision: F08.DEPLOY-GO — A / B / C`. The intake then activates F08-DEVOPS in the chosen scope (A or B), or, with C, records the deferral and activates the next executable feature (F09 depends only on F03).
6. **F08-QA-FINAL scope, unchanged from A17:** Regression Depth `full` (dependency / build-config change); the emulator suite re-run at the final revision, on Node 22.

### A19. Decision F08.DEPLOY-GO — B (2026-09-29): the Firestore rules only

**Input:** `Run Tech Lead. Decision: F08.DEPLOY-GO — B`, with the user's question "why did we skip F07?". Exactly one OPEN gate matched; option (B) as defined at A17 ruling 7. The question is answered in the turn reply and below; it changes no state.

**Decision recorded:**
* **Authorized now:** a rules-only production deploy — the committed `infra/firestore.rules` (sha1 `aa4c5dc2…`, the BE7 / QA-R1 revision) to `looplet-712e5`, on the Spark plan, no billing. **Tech Lead approval** for this deploy is given here (project `release.md` §12). The user's decision is the other half.
* **Still deferred:** Blaze / billing, the function deploy (`submitDailyResultV1`, `nodejs22`), the Remote Config template, indexes. No product criterion changes, so no Product Owner revision.
* **Why the rules first:** the repository is public, so the Firebase client config is world-readable. The `(default)` database has had unknown console rules since 2026-09-06. The committed rules deny every client path (A9). The app never reads or writes Firestore directly (only through the callable, which is not deployed), so the deploy cannot break the app.

**Rulings:**
1. **F08.DEPLOY-GO — RESOLVED (B).**
2. **New task F08-DEVOPS-RULES** (DevOps/Release Engineer, **Open**): read the live rules, verify the source, dry-run, deploy the rules only, run the rules-scope smoke, and record it in `release.md`. The brief is in the orchestration.
   * **Smoke in rules scope (a subset of S2):**
     * the live ruleset source is byte-identical to the committed file;
     * unauthenticated REST create / get / update / delete under `dailyResults/**` → 403, and no document is written.
   * **No test user is created in production.** The authenticated own-uid, other-uid, invalid-payload and non-date-bucket denials are proven on the identical file by the emulator suite (33 / 33; QA R1 probe P1–P8). The live authenticated probe rides S3 in the function deploy, where the debug app creates its anonymous user anyway.
   * **S1 for the rules:** CI run #2 (c592081) ran the rules suite green on the same `firestore.rules` and `rules.test.ts` bytes. DevOps re-runs the suite locally at the deploy revision. A push is not needed for this deploy.
3. **F08-DEVOPS (the function + Remote Config deploy and S3 / S4) stays Blocked**, with a narrower scope.
   * It needs a new gate, **F08.FUNCTION-DEPLOY-GO** (Blaze + the function deploy). That gate opens at the F08-DEVOPS-RULES checkpoint, not now: an OPEN release-scoped gate holds every DevOps activation (contract §5.3), the same reason as A16 ruling 3.
   * **The function deploy stays held in the meantime by:**
     * this recorded deferral;
     * F08-DEVOPS stays Blocked;
     * F08-DEVOPS-RULES's non-goals;
     * project `release.md` §3.
4. **Release Result stays Release Validation Pending.** F08 cannot be Done without the function deploy and S3 (the callable is F08's backend deliverable). F08-QA-FINAL stays Queued.
5. **F08 → In Release;** Current Owner = Next Role = DevOps/Release Engineer; Blockers None.
6. **The next feature (after the rules checkpoint) — the F07 question.**
   * F07 (daily-challenge) was never skipped. Under the feature-selection rules it has not been selectable. The product PRD lists its dependencies as F03, F04, F06 and **F08**, and F08 is not Done.
   * F07's own delivery also needs the backend that option B defers:
     * the daily result sync (the callable);
     * the Remote Config read and kill-switch (F07-KILL-SWITCH);
     * the daily content distribution.
   * F07 also needs the Daily content pool (F06-CONTENT-DAILY: about 60 puzzles plus human sign-off).
   * So while billing stays deferred, F07 cannot be released.
   * **Options** at the rules checkpoint, when F08 waits on F08.FUNCTION-DEPLOY-GO:
     * **(1)** F09 (onboarding-tutorial; depends only on F03) — fully executable;
     * **(2)** F07 development against the emulator. This needs a Tech Lead ruling that F07 may start on F08's *functional* acceptance, with F07's release gated on the function deploy. It is allowed by contract §5.3 only with an explicit dependency justification and a pause / resume record;
     * **(3)** authorize the function deploy (Blaze) and finish F08 first.
   * The Tech Lead puts these to the user at that checkpoint.

### A20. DevOps checkpoint 2026-09-29 (F08-DEVOPS-RULES — held by the user, commit b2873cc)

**Delivery reviewed:** feature `release.md` → "F08-DEVOPS-RULES" and `evidence/deploy-rules/` DR-01…06. Steps 1–4 are done. They were all read-only or a dry-run: the database list, the rules releases and rulesets through the CLI's own session, unauthenticated REST GETs, the emulator suite and a compile-only dry-run. At step 5 the user answered "Hayır, bekle" (wait) to the deploy confirmation. **Nothing on `looplet-712e5` changed.** The evidence files hold no account data or token.

**Finding — option B's premise did not hold:**
* A17 ruling 7 and A19 assumed the `(default)` database had unknown console rules since 2026-09-06, possibly open.
* The live project has **no rules release and no ruleset** (DR-02 / DR-03). Unauthenticated reads on `dailyResults` → **403** (DR-04): with no release, Firestore applies its implicit lock.
* *Limit:* writes were not probed, correctly, since a successful probe would have written to production. The implicit lock is the documented behaviour of a database with no rules release, and the read result is consistent with it.
* So there is no exposure to close. A rules-only deploy now would add only explicit, versioned rules — and the function deploy's runbook deploys the same rules anyway (feature `release.md` §6 step 3).

**Rulings:**
1. **F08-DEVOPS-RULES — Cancelled (folded into F08-DEVOPS).** This follows the user's "wait" and the finding, and it is reversible: the user can ask for a rules-only deploy at any time.
   * Steps 1–4 and their evidence are kept.
   * F08.LIVE-RULES stays PENDING and moves to F08-DEVOPS, which deploys rules + Remote Config + the function together and runs F08.LIVE-RULES, S2–S4.
   * Delivery Review: Accepted — the held delivery is accurate and complete up to the hold.
2. **F08 has no executable work left. New decision gate F08.FUNCTION-DEPLOY-GO** (Blocking Scope: release), as A19 ruling 3 planned. It also carries the next-feature choice that A19 ruling 6 promised:
   * **(A) Deploy now.** The user enables Blaze with a budget alert. F08-DEVOPS then:
     * reads the live state;
     * pins Node 22 in the CI `infra` job;
     * gets a green CI at the deploy revision with its logs read;
     * dry-runs, then deploys rules + Remote Config + `submitDailyResultV1` (`nodejs22`);
     * runs F08.LIVE-RULES and S2–S4.
     * Then F08-QA-FINAL and Done. F07 then becomes selectable.
   * **(B) Defer the deploy; start F09** (onboarding-tutorial, P1; depends only on F03). It is fully executable and needs no dependency exception.
   * **(C) Defer the deploy; start F07 development on the emulator.**
     * This needs a Tech Lead dependency ruling: F07 may start on F08's functional acceptance, and F07's release waits on the function deploy.
     * F07 also needs the Daily content pool (F06-CONTENT-DAILY, about 60 puzzles plus human sign-off) and the Remote Config kill-switch (F07-KILL-SWITCH).
     * Larger and not releasable until (A).
   * **Recommendation: (B)** while billing stays deferred. The product PRD lists the P1 launch set as F04, F09, F10, F07, F12, and F09 is the next one with every dependency met. Choose (C) if the Daily matters more to you now; (A) once billing is acceptable.
   * With B or C, F08 stays Blocked with its functional acceptance, PREP, BE8 and the evidence intact (pause record); it resumes at F08-DEVOPS when the user answers (A) later.
3. **F08 → Blocked;** Current Owner = Next Role = Tech Lead. F08-DEVOPS Blocked on the gate; F08-QA-FINAL Queued.

### A21. Decision F08.FUNCTION-DEPLOY-GO — C (2026-09-29): deploy deferred; F07 starts on the emulator

**Input:** `Run Tech Lead. Decision: F08.FUNCTION-DEPLOY-GO — C`. Exactly one OPEN gate matched; option (C) as defined at A20 ruling 2.

**Decision recorded:**
* **The first Firebase deploy stays deferred:** no Blaze, billing, rules, Remote Config or function deploy.
* **F07 (daily-challenge) starts now, on the Firebase emulator,** under the dependency ruling below. No product criterion changes, so no Product Owner revision.

**Rulings:**
1. **F08.FUNCTION-DEPLOY-GO — RESOLVED (C).**
2. **F08 is paused — Blocked; pause record:**
   * everything is kept: Functional Approved (A13), PREP (A17), BE8 (A18), the rules-hold findings (A20), every evidence record;
   * F08-DEVOPS stays Blocked, F08-QA-FINAL Queued;
   * **resume point: F08-DEVOPS**, when the user authorizes the deploy.
3. **New gate F08.DEPLOY-RESUME** (Blocking Scope: release) keeps that channel open: "Authorize the first Firebase deploy now (Blaze with a budget alert; rules + Remote Config + the `nodejs22` function)?"
   * Its answer activates F08-DEVOPS.
   * It is safe to open now because F08 has no DevOps work in flight.
   * **It also gates F07's release:** F07's official results reach the server only through the deployed callable.
4. **Dependency ruling for F07** (feature-selection rules; contract §5.3):
   * F07 depends on F08 in two ways. The first is the **client surface**: storage, `DailyPuzzleCache`, `DailyResultSyncService`, the callable contract. That surface is implemented and **Functional Approved**, so F07's delivery work may start on it.
   * The second is the **deployed backend**: the callable. F07's **release** waits on it — F07-DEVOPS depends on F08-DEVOPS.
   * Until then, F07's sync evidence runs against the emulator, as F08's did.
   * F08 must not change its client contract while F07 builds on it. Any change goes through the Tech Lead.
5. **The fake producer** (`FakeDailyResultProducer`, debug-only) stays until F08 is Done. F07 does not remove it, because F08's final QA may reuse the client ↔ emulator path (F08 `architecture.md` → Scope Boundary; amended here).

