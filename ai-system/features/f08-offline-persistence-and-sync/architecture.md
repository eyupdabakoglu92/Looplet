# F08 — offline-persistence-and-sync: Architecture

> Status: INITIAL CONTRACT SKELETON. **[LOCKED]** items are Tech Lead decisions the analysis must not reopen. **[PENDING ANALYSIS]** items go to the Technical Analyst (F08.0-AN → `analysis.md`); the Tech Lead then consumes `analysis.md` into this file and flips them to [LOCKED] before any Backend / Frontend / DevOps handoff.
> Contract authority for F08. `orchestration.md` is execution authority; `platform.md` / `release.md` are project authority.

---

## Purpose

* **Feature objective:** a durable on-device store (Drift/SQLite) that makes "never lose progress; play fully offline" true — active-session snapshot on every state change, journey progress, personal bests, daily first-run + streak, settings — plus a minimal, exactly-once, first-run-authoritative sync path for offline daily results, and a guest-only schema a future account can adopt without a destructive migration.
* **Contract scope:** the Drift schema + migration policy; the active-session snapshot shape (what F03 must design to); the `sync_queue` contract + exactly-once semantics; the reconciliation algorithm; the Firebase sync surface (callable/write + Firestore rules + App Check posture); the session-level service ownership boundary.
* **Non-goals:** play-session UI (F03) · star computation (F04) · unlock rules / journey screens (F05) · daily fetch/cache/rollover/scoring/streak *rules* (F07) · analytics buffering (F12) · account/cloud-save UI · leaderboard · active multi-device merge · server-side streak anti-cheat.

---

## Authorities & Inputs

* Upstream PRD: `features/f08-.../prd.md`; product PRD §6.1 F08, §5.4, §11.7, §12.5–12.7, §15–16, §46, §51.
* Inherited contracts **[LOCKED]**:
  * **F02** — persistence captures `EngineConfig`, the ordered applied-`Move` list, and derived `thawedCells`; the engine re-derives thaw/solved from history on restore (F02 `architecture.md`). F08 stores what F02 already exposes; it does not add engine state.
* Project authority **[LOCKED]**: `platform.md` §4 (JSON `lowerCamelCase`; `dailyDate` = device-local `YYYY-MM-DD`; optional fields omitted, never `null`; callable error format + codes), §5 (Drift; write-through; forward-only migrations; `personal_best` / `daily_streak` / `daily_entry` first-run rows never dropped; UTC epoch millis + monotonic `Stopwatch`; `guestId` on every player-owned row; `kv` active-session JSON snapshot + `schemaVersion`), §6 (guest-only; Firebase Anonymous Auth as invisible identity; Firestore create-only rule for `dailyResults/**`; App Check soft-enforce for MVP), §7 (`sync_queue` + analytics flush are **session-level** services, never screen-owned; screen disposal never cancels a sync; lifecycle `paused` → flush, `resumed` → restore + re-evaluate rollover + attempt flush; callable client timeout 10s), §8 (payload validation ranges; no PII; App Check on writes + callable), §11 (no runtime RNG on device; monotonic durations).
* Release: `release.md` — F08 `Release Scope` is **[PENDING ANALYSIS]** (Firebase deploy + Drift migration ⇒ a DevOps/Release Engineer gate is expected).

---

## Dependency Edges [LOCKED]

* Persistence lives in **`app/`** (Drift is a Flutter-side concern — `drift`, `sqlite3_flutter_libs`, `drift_dev`/`build_runner` are already in `app/pubspec.yaml` per `setup-manifest.md` Step 6). Domain packages stay pure and Firebase-free.
* Serialized enums/value types reuse `looplet_content` (which re-exports `looplet_core`) — `PuzzleType`, `DifficultyLabel`, `MoveAxis`, `MoveDirection`, `TileStatus`, `GridCoord` (`platform.md` §3/§11 carve-out). No new shared enum is introduced without a Tech Lead carve-out note.
* `infra/` (Firebase project config, Cloud Functions TS, Firestore rules, Remote Config) is scaffolded by a **Project Setup DURUM 0** triggered inside F08. Firebase client packages are added to `app/pubspec.yaml` at that point — not before.
* `app` gains a Firebase dependency set (Auth, Firestore, App Check, Core) at the DURUM 0; the exact list is fixed then, matching `platform.md` §3.

---

## Persistence Schema [PENDING ANALYSIS]

Drift tables + columns realizing product PRD §15 (`PlaySession`, `LevelResult`/`PersonalBest`, `JourneyProgress`, `DailyEntry`, `DailyStreak`, `Settings`, `Player`). Analyst to specify:

* Table list + columns + keys; which data is typed tables vs the single `kv` active-session JSON row.
* `guestId` placement + backfill; no device-scoped primary key on player data (multi-device-safe).
* `schemaVersion` location + the forward-migration step model; the "never drop bests/streak" guard as an explicit migration rule + test.
* Time columns as UTC epoch millis; elapsed measured with a monotonic `Stopwatch`, persisted as an accumulated `elapsedTimeMs`.

## Active-Session Snapshot Contract [PENDING ANALYSIS — F03 designs to this]

The exact persisted shape for an in-progress puzzle: grid, move count, `undoHistory` (ordered, sufficient to revert), `undosRemaining`, `restartCount`, `elapsedTimeMs`, `thawedFrozenCells`, `puzzleId`, `status`, `startedAt`. Analyst to decide how much is stored vs re-derived from the applied-move list on restore, and to lock the JSON key names (F03 will read/write this).

## `sync_queue` Contract & Exactly-Once [PENDING ANALYSIS]

* Item schema; states (`pending` / `in_flight` / `synced` / `parked`); idempotency key `(guestId, lang, date)`; ack-only transition to `synced`; exponential backoff schedule + attempt cap; behavior after cap (parked, local stays authoritative).
* The exactly-once mechanism end-to-end: client key + server create-only rule + `ALREADY_SUBMITTED` treated as a client success.

## Reconciliation Algorithm [PENDING ANALYSIS]

First-run-authoritative: local `daily_entry.firstRun*` is set once on the first local completion and is **never mutated by sync**; the server write is create-only; if the server already has an entry, the client accepts it and marks the queue item `synced`. Analyst to spell out the client-vs-server tie-break and the "both think they're first" case.

## Firebase Sync Surface [PENDING ANALYSIS → Tech Lead + Project Setup]

* Callable `submitDailyResult` (per `platform.md` §4, error codes `INVALID_PAYLOAD` / `ALREADY_SUBMITTED` / `UNSUPPORTED_LANGUAGE` / `APP_CHECK_FAILED` / `INTERNAL`) **vs** direct client create-only Firestore write. Default assumption: **callable**, unless the analysis shows the direct write is strictly simpler and equally safe.
* Firestore path `dailyResults/{lang}_{date}/entries/{guestId}` — create-only rule, no update/delete, no cross-user read (`platform.md` §6). Structured for a future leaderboard query by `{lang, date}` ordered by `moves` then `durationMs`.
* App Check posture (soft-enforce MVP) + offline behavior when attestation is unavailable.
* Payload = the §15 `DailyEntry` first-run fields + `dailyDate` + `lang`; validated server-side to `1 ≤ optimalMoves ≤ moves`, `durationMs ≥ 0`, `dailyDate` matches `YYYY-MM-DD`, `lang` in the supported set (`platform.md` §8).

## Ownership & Lifecycle [LOCKED]

* `sync_queue` draining and connectivity watching are a **session-level app service**, constructed once at app start, never owned or cancelled by a screen (`platform.md` §7). Screen disposal never cancels a sync.
* Lifecycle: `AppLifecycleState.paused` → flush pending Drift writes + enqueue/flush; `resumed` → restore active session, re-evaluate daily rollover against current local date (F07 rule), attempt `sync_queue` flush if connectivity allows.
* Write-through: every domain state change writes before it is considered applied; the active session is one transactional row so relaunch never sees torn state.
* Durations: monotonic `Stopwatch` only; wall clock is never read for elapsed time.

## Resilience [LOCKED — behaviors; PENDING ANALYSIS — mechanism]

* Corrupt save on launch → fall back to last valid checkpoint or a clean state, no crash, log.
* Storage full / write failure → non-destructive error, keep last good state.
* Concurrent writes (autosave + explicit action) → serialized within a transaction boundary, no torn state.
* App killed mid-write → store left at the last committed transaction.

## Scope Boundary F08 ↔ F07 [PENDING ANALYSIS → Tech Lead decision]

Whether F08 delivers the persistence core + `sync_queue` + reconciliation as a **now** deliverable tested against a fake daily-result producer, with F07 wiring the real Daily fetch/cache/producer later (an F06-style split), or F08 waits on F07. The analysis recommends; the Tech Lead locks it at contract finalization.

## Validation Responsibility [LOCKED]

* **`app` persistence layer:** schema validity, migration correctness, write-through completeness, restore fidelity, resilience fallbacks.
* **`sync_queue` service:** exactly-once delivery, backoff/cap, session-level survival.
* **Firestore rules / callable:** server-side create-only enforcement + payload validation + App Check.
* **F02 engine:** the restored `EngineConfig` + move list re-derive thaw/solved — F08 does not re-validate engine semantics.

## QA Focus [PENDING ANALYSIS — refine after contract]

* Kill/relaunch resume fidelity (grid, moves, undo history, thawed tiles, elapsed) — device/emulator runtime (`platform.md` §10 requires runtime proof for resume behavior).
* Full offline Journey; offline pre-fetched Daily.
* Offline daily completion → exactly-once sync; partial-sync / retry / background-mid-sync matrix; first-run-authoritative when the server already has a run.
* Forward migration preserves bests/streak; corrupt-save fallback; storage-full non-destructive error; monotonic elapsed under a clock change.
* Guest schema: every player-owned row carries `guestId`.
* **Evidence class:** `runtime` for resume + offline + sync behavior (device/emulator + Firebase emulator); `repeatable integration` for the callable/rules; `automated functional` for schema/migration unit tests. Not `source-only`.

## Release / Deployment Impact [PENDING ANALYSIS → Tech Lead + DevOps/Release Engineer]

* First Firebase deploy for LOOPLET: Cloud Functions (if callable) + Firestore rules + App Check config + Remote Config scaffold. Environment topology (dev/test/prod Firebase projects), deploy runbook, rollback (repoint / redeploy previous), secret names.
* Drift forward migration → rollback-readiness expectation (a bad migration must not lose bests/streak).
* Expected `Release Scope` ∈ `{ staging, production-readiness, rollback-readiness }` — set precisely at contract finalization; a DevOps/Release Engineer task opens after QA.

---

## Open Items → Technical Analyst (F08.0-AN)

1. Drift schema + columns + keys for §15; typed tables vs `kv` JSON for the active session; migration step model + the never-drop-bests/streak guard.
2. Active-session snapshot JSON contract (locked key names) — the shape F03 designs to; stored-vs-re-derived split.
3. `sync_queue` item schema + states + backoff + cap + exactly-once mechanism.
4. Reconciliation algorithm + client/server "both first" tie-break.
5. Callable `submitDailyResult` vs direct create-only write — recommend, with the safety argument.
6. App Check posture + offline-attestation behavior.
7. F08↔F07 scope boundary — recommend split-now vs wait, F06-style.
8. Streak-integrity / clock-timezone edge cases that touch *storage* (`lastCompletedDate` durability) vs the *rule* (F07).
9. `infra/` DURUM 0 sequencing — before Backend vs parallel with the persistence core.
10. Inputs for the Tech Lead's `Release Scope` + `release.md` update.
