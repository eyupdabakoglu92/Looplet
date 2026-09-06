# F08 — offline-persistence-and-sync: PRD

> Status: FEATURE PRODUCT AUTHORITY (derived from `/ai-system/product/product-prd.md` §6.1 F08, §5.4, §11.7, §12.5–12.7, §15 data model, §16 domain events, §46 F08 metric, §51 open questions)
> Tech Lead output — submitted for user review.

---

## Summary

* **Problem:** LOOPLET promises "never lose progress; play the campaign fully offline." That requires a durable on-device store that captures the active puzzle mid-play (grid, moves, undo history, thawed tiles, elapsed time, puzzle ID), plus journey progress, per-level bests, the daily first-run result, the daily streak, and settings — written on every state change so a background/kill/relaunch resumes exactly. It also requires that offline daily results are queued and later synced **exactly once**, with the player's **first completed run** staying authoritative.
* **Goal:** A Drift (SQLite) persistence layer in `app/` with write-through on every domain state change, forward-only migrations that never drop bests/streak, and a guest-only schema (`guestId` on every player-owned row) that a future account can adopt without a destructive migration — plus a minimal, Tech-Lead-defined sync path (one create-only Firestore write behind Firebase Anonymous Auth + App Check) and a client `sync_queue` with idempotent retry and first-run-authoritative reconciliation.
* **User value:** the player closes the app mid-puzzle, comes back, and is exactly where they left off; the whole Journey works on a plane with no signal; a daily solved offline still counts and still extends the streak, and syncs cleanly once without ever overwriting the official first result.

---

## Dependencies

* **Upstream:** **F02 grid-engine (Done)** — for the state shape that gets persisted: `EngineConfig`, the applied-move list, and derived `thawedCells` (F02 exposes exactly what F08 needs; product PRD F02 note §47). No other feature is a hard prerequisite for the persistence core.
* **Cross-feature (sync half):** **F07 daily-challenge** owns Daily fetch/cache and the daily-result shape; F08 provides the persistence + queue + reconciliation it plugs into. F07's dependency list includes F08, so the sync path must be defined here even though its end-to-end exercise lands with F07.
* **Consumers:** F03 (persists/restores the `PlaySession`), F04 (writes `PersonalBest`), F05 (writes `JourneyProgress`), F07 (writes `DailyEntry` + `DailyStreak`, drains `sync_queue`), F10 (reads `Settings`, streak, progress), F12 (its own `analytics_event_buffer` follows the same offline-buffer + exactly-once-flush pattern — F08 sets the precedent, F12 owns its table).
* **Platform assumptions (`platform.md`):** Drift/SQLite on-device, write-through, forward-only migrations (§5); UTC epoch millis + monotonic `Stopwatch` for durations, never wall clock (§5, §11); Firebase Anonymous Auth as invisible identity + App Check soft-enforce for MVP (§6); one HTTPS-callable-or-create-only-write sync surface, no REST (§4); `sync_queue` + analytics flush are session-level services, not screen-owned (§7); no PII (§8).

---

## In Scope

* **Active-session snapshot:** persist the in-progress puzzle as a single transactional row (`kv` per `platform.md` §5) covering current grid, move count, undo history sufficient to revert, `undosRemaining`, `restartCount`, `elapsedTimeMs`, thawed frozen cells, puzzle ID, status, `startedAt` — written on every domain state change; restored exactly on relaunch.
* **Progress & results:** `journey_progress` (highest unlocked + completed levels), `personal_best` (best move count that only decreases, stars, `isPerfect`, `firstCompletedAt`), `daily_entry` (first-run move count / duration / stars / completed-at + later replay attempts + `syncStatus`), `daily_streak` (current, best, `lastCompletedDate`), `settings` (sound, haptics, language).
* **Guest identity:** a locally generated anonymous `guestId` (`player` row: `guestId`, `createdAt`), stamped on every player-owned row; Firebase Anonymous UID adopted as the `guestId` value where a server identity is needed.
* **Offline play:** the entire Journey loads and saves with no network; a previously fetched Daily is playable offline and its result is queued.
* **Deferred sync:** a `sync_queue` table; offline daily results enqueued on completion; drained with exponential backoff on connectivity regain; each item delivered **exactly once** (idempotency key `(guestId, lang, date)`); marked synced only on server ack; local result stays authoritative regardless of sync state.
* **Reconciliation:** synced daily results reconcile with the **first completed run** authoritative — if the server already holds a first-run result for `(player, daily)`, a later offline run does not replace it (`ALREADY_SUBMITTED` is a success from the client's view).
* **Migrations:** Drift schema migrations, forward-only; `personal_best`, `daily_streak`, `daily_entry` first-run rows are never dropped or reset.
* **Resilience:** corrupt save on launch → fall back to last valid checkpoint or a clean state without crashing, and log; storage-full / write failure → non-destructive error, keep last good state; concurrent writes (autosave + explicit action) serialized.
* **Firebase surface:** the minimal `infra/` for the sync write — Firestore `dailyResults/{lang}_{date}/entries/{guestId}` create-only collection + rules + App Check + the callable-or-direct-write decision (Tech Lead / Technical Analyst), and the app-side Firebase wiring.

## Out of Scope

* The play-session UI, gestures, animation, MOVES HUD, Undo/Restart affordances → **F03** (F08 persists/restores the session `PlaySession` that F03 produces).
* Star computation and the completion panel → **F04** (F08 stores `PersonalBest`).
* Level unlock rules / difficulty curve / journey screens → **F05** (F08 stores `JourneyProgress`).
* Daily puzzle **fetch, cache-population, date rollover, scoring, streak rules** → **F07** (F08 stores `DailyEntry` / `DailyStreak` and provides the queue + reconciliation; F07 decides *when* the streak increments/resets).
* Analytics event buffering + flush → **F12** (same pattern, its own table).
* Any user-facing login / account / cloud-save UI → not in the MVP (schema must merely *anticipate* it, source §39).
* A leaderboard, cross-user reads, server-side gameplay authority → out (Firestore is leaderboard-*ready*, leaderboard-free).
* Multi-device real-time merge — the model must not *hard-assume* a single device, but no active multi-device sync is built.
* Server-side clock/timezone anti-cheat for streaks — MVP posture is a Tech Lead open question (F07 area).

---

## User Stories

F08 is Infrastructure; expressed as system requirements.

* The system must persist the active puzzle state (current grid, move count, undo history, thawed frozen tiles, elapsed time, puzzle ID) on every state change, so the player resumes exactly where they left off after background, kill, or relaunch.
* The system must persist journey progress, per-level personal bests, daily first-run results, daily streak, and settings locally.
* The system must allow the entire Journey to be played with no network connection.
* The system must allow the Daily to be played offline when its puzzle was previously fetched, and must queue offline daily results for sync when connectivity returns.
* The system must operate guest-only (no login) while structuring stored data so a future account can adopt it without a destructive migration.
* The system must reconcile synced daily results using the player's first completed run as authoritative.

---

## Acceptance Criteria

* **Given** a puzzle in progress, **When** the app is killed and relaunched, **Then** grid, move count, undo history, thawed tiles, and elapsed time are exactly restored.
* **Given** no network, **When** the player plays Journey, **Then** all levels load and progress saves.
* **Given** a previously fetched daily and no network, **When** the player opens DAILY, **Then** it is playable.
* **Given** an offline daily completion, **When** connectivity returns, **Then** the result is sent exactly once with no duplicate.
* **Given** the server already holds a first-run result for that player and daily, **When** an offline run syncs, **Then** the earlier first run remains authoritative.
* **Given** `app_backgrounded` fires, **When** it occurs, **Then** current state is already durably written (no data-loss window).
* **Given** a storage-full or write-failure condition, **When** a save is attempted, **Then** the error is non-destructive and the last good state is preserved.
* **Given** a corrupt save file on launch, **When** the app starts, **Then** it falls back to the last valid checkpoint or a clean state without crashing, and logs the event.
* **Given** a schema-version upgrade between app releases, **When** the app launches, **Then** the store migrates forward and no personal best or streak is lost.
* **Given** elapsed-time measurement, **When** the device clock changes mid-session, **Then** elapsed time is unaffected (monotonic timer, not wall clock).
* **Given** a partial sync (network drops mid-request), **When** retried, **Then** the retry is idempotent and produces no duplicate server record.
* **Given** any player-owned row, **When** written, **Then** it carries a `guestId` such that a future account could claim it without a destructive migration.

---

## Edge Cases

* Storage full / write failure → non-destructive error; keep the last good state.
* Corrupt save file on launch → fall back to the last valid checkpoint or a clean state without crashing; log.
* Schema version upgrade between app releases → migrate forward; never lose bests or streak.
* Clock change affecting elapsed-time measurement → use a monotonic timer, not wall clock.
* Concurrent writes (autosave + explicit action) → serialized; last write wins within a single transaction boundary, no torn state.
* Partial sync (network drops mid-request) → idempotent retry keyed by `(guestId, lang, date)`.
* Future multi-device use → the model must not hard-assume a single device (no device-scoped primary keys on player data).
* App killed *during* a write → the store is left at the last committed transaction, never half-written.
* Daily completed offline, then the same daily completed again offline before any sync → only the first completed run is queued as official; the second is a personal replay attempt.
* Connectivity returns, sync starts, app backgrounded mid-sync → sync is session-level, survives screen disposal; resumes/retries, still exactly once.
* `sync_queue` item repeatedly failing → capped attempts then parked; local result stays authoritative; no crash, no infinite retry.
* Anonymous Auth UID not yet available on first launch offline → local `guestId` generated locally; server identity reconciled to it when Auth completes.

---

## Success Metrics

* **0 progress-loss incidents** across the QA kill / relaunch / offline matrix (source §46, §12.7).
* Offline daily results sync **exactly once** — 0 duplicate server records across the QA partial-sync / retry / background-mid-sync matrix.
* First-run-authoritative reconciliation holds 100% — a later offline run never overwrites an existing server first-run result.
* Forward migration preserves 100% of `personal_best` / `daily_streak` / `daily_entry` first-run rows across a simulated version upgrade.
* No wall-clock use for elapsed/session durations (review + test); no PII written to the store or sent to the server.

---

## Open Questions

_Resolved by the Technical Analyst pass (F08.0-AN) and then locked in `architecture.md` by the Tech Lead; nothing here blocks starting the analysis._

* **[Technical — Analyst → Tech Lead]** Persistence schema: exact Drift tables + columns for the §15 model; the active-session snapshot as one `kv` JSON row vs typed tables; migration-strategy shape (`schemaVersion` in `kv`, upgrade steps, backfill of `guestId`).
* **[Technical]** Active-session snapshot contract vs F03's future `PlaySession` — F08 must define the persisted shape now so F03 designs to it; how much of `GridEngine` history is stored vs re-derived on restore.
* **[Technical]** `sync_queue` semantics — item schema, states (`pending` / `in_flight` / `synced` / `parked`), backoff schedule, attempt cap, and the exactly-once guarantee mechanism (ack-only marking + idempotency key).
* **[Technical]** Reconciliation algorithm — client-vs-server tie-break when both hold a "first" run (server create-only + `ALREADY_SUBMITTED` treated as success; local `daily_entry.firstRun*` never mutated by sync).
* **[Hybrid — assume, confirm]** Minimal Firebase sync surface: HTTPS **callable** `submitDailyResult` (per `platform.md` §4) vs a direct client create-only Firestore write guarded by rules. Assume callable unless the analysis shows the direct write is strictly simpler and equally safe.
* **[Technical]** App Check posture for the MVP (soft-enforce per `platform.md` §6) and behavior when App Check attestation is unavailable offline.
* **[Cross-feature boundary — Tech Lead]** Where the F08/F07 line sits: does F08 ship a fake/mock daily-result producer to test the queue + reconciliation end-to-end now, with F07 wiring the real producer later (an F06-style scope split)?
* **[Product/Tech — from source §51]** Daily timezone integrity: whether any server-side check is in MVP scope, or purely local monotonic + local-date (F07 owns the streak rule; F08 owns durable storage of `lastCompletedDate`).
* **[Process — Tech Lead]** Sequencing of the `infra/` DURUM 0 (Project Setup) — before Backend work (so the callable + rules exist to build against) or in parallel with the Drift persistence core (which needs no Firebase).
* **[Release — Tech Lead]** `Release Scope` value + `release.md` update: Firebase Functions + Firestore-rules deploy gate, Drift forward-migration rollback-readiness, App Check config, secret names.
