# F08 — offline-persistence-and-sync: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In Progress — Technical Analysis**

---

## Current Owner

Technical Analyst

---

## Current Phase

Technical Analysis (F08.0-AN → `analysis.md`). Contract skeleton exists (`architecture.md`): F02-inherited substrate + `platform.md` §4–§8/§11 rules are [LOCKED]; the persistence schema, active-session snapshot contract, `sync_queue` semantics, reconciliation algorithm, Firebase sync surface, F08↔F07 scope boundary, and Release Scope are [PENDING ANALYSIS].

---

## Complexity Decision

* **COMPLEX.** Triggers: a new persistence data model (§15 → Drift tables); realtime/async + sync/conflict resolution (offline exactly-once, first-run-authoritative reconciliation); state-machine conceptuality (forward-only migration steps; `sync_queue` states); cross-feature dependency on F07 (Daily producer) with an unresolved boundary; unsafe-assumption risk (the product PRD explicitly leaves the backend sync surface to the Tech Lead). → **Technical Analyst pass before contract finalization.**
* **No UI Designer** — Infrastructure; F08 owns no screens. F10 surfaces streak/progress; F03 owns the play-session UI. F08 exposes stores + services.
* **DevOps/Release Engineer** — expected **after QA**: first Firebase deploy (Functions/rules/App Check) + a Drift forward migration ⇒ a release gate. `Release Scope` set at contract finalization.
* **Project Setup** — an `infra/` DURUM 0 (+ app Firebase wiring) is required before Backend implementation; sequencing (before vs parallel with the persistence core) is an analysis input, Tech-Lead-triggered.

---

## Active Task Ledger

- [ ] Task ID: F08.0-AN | Assigned Role: Technical Analyst | Status: Open | Produce `analysis.md` resolving the 10 open items in `architecture.md → Open Items`. Recommend the F08↔F07 scope boundary and the `infra/` DURUM 0 sequencing. Do not write contract authority — recommendations only; the Tech Lead consumes them into `architecture.md`.
- [ ] Task ID: F08.CONTRACT-TL | Assigned Role: Tech Lead | Status: Open | Consume `analysis.md` into `architecture.md` (all [PENDING ANALYSIS] → [LOCKED]); set `Release Scope`; update `release.md`; decide the scope boundary + DURUM 0 sequencing; open the Backend / Frontend / DevOps / QA tasks; route.
- [ ] Task ID: F08.SETUP-0 | Assigned Role: Project Setup | Status: Open (gated on F08.CONTRACT-TL) | `infra/` DURUM 0 — Firebase project config, Cloud Functions (TS) skeleton, Firestore rules, Remote Config template, App Check config; add the Firebase package set to `app/pubspec.yaml` per `platform.md` §3. Per `setup-manifest.md` (Workspace Targets → `infra/`).
- [ ] Task ID: F08.x-BE / F08.x-FE / F08.x-DEVOPS / F08.x-QA | Assigned Role: TBD | Status: Not opened yet | Opened by F08.CONTRACT-TL once the contract is locked.

---

## QA Scope

* **[PENDING ANALYSIS]** — expected: end-to-end (app persistence + Firebase emulator). Evidence class `runtime` (resume / offline / sync on device or emulator) + `repeatable integration` (callable/rules) + `automated functional` (schema/migration units). `platform.md` §10 requires runtime proof for resume and daily behavior.

---

## Release Scope

* **[PENDING ANALYSIS]** — Firebase Functions/rules deploy + Drift forward migration. Expected ∈ `{ staging, production-readiness, rollback-readiness }`. Set at F08.CONTRACT-TL; `release.md` updated the same turn.

---

## Open Tasks

### Analysis
- [ ] (F08.0-AN) Technical analysis of F08 — resolve the 10 open items; recommend scope boundary + DURUM 0 sequencing. Output: `features/f08-offline-persistence-and-sync/analysis.md`.

### Contract
- [ ] (F08.CONTRACT-TL) Tech Lead consumes `analysis.md` → finalizes `architecture.md`, sets `Release Scope`, updates `release.md`, opens delivery tasks.

### Project Setup
- [ ] (F08.SETUP-0) `infra/` Firebase DURUM 0 + app Firebase wiring. Gated on the contract.

### Backend / Frontend / DevOps / QA
- _(not opened — F08.CONTRACT-TL opens these against the locked contract)_

---

## Blockers

* None hard. Sequencing note: F08.SETUP-0 (infra) and all Backend/Frontend/DevOps/QA work are gated on F08.CONTRACT-TL, which is gated on F08.0-AN. The Drift **persistence core** needs no Firebase and could begin in parallel with F08.SETUP-0 once the schema is locked — the analysis recommends whether to do so.
* Cross-feature: the F08↔F07 boundary is unresolved until the analysis + contract. F07 is `Not Started` and depends on F08; F08 must define the sync path F07 plugs into, not wait for F07.

---

## Last Decision

* 2026-09-06 — Tech Lead (F08 activation):
  * Activated after F06 `Done`. P0, next on the critical path per `product-prd.md` §12.6 build order (`… F01, F02, F06, F08, F03, F05`) and the feature-board priority ordering — persistence is landed before the F03 play screen so it is designed in, not bolted on. F08 depends only on the F02 state shape (Done); no half-finished feature is open.
  * Complexity **COMPLEX** (new persistence data model + offline exactly-once sync + first-run-authoritative reconciliation + forward-migration state machine + F07 cross-dependency + PRD-deferred backend surface) → **Technical Analyst pass** before contract finalization.
  * **No UI Designer** (Infrastructure, no screens). **DevOps/Release Engineer** expected post-QA (first Firebase deploy + Drift migration). **Project Setup** `infra/` DURUM 0 required pre-Backend; sequencing is an analysis input.
  * `architecture.md` skeleton: **[LOCKED]** — persistence in `app/` (Drift, write-through, forward-only migrations, `guestId` on player rows, `kv` active-session snapshot, monotonic durations); `sync_queue` + connectivity watching are a session-level service never owned by a screen; Firestore `dailyResults/**` create-only + App Check; local result always authoritative; first-run never mutated by sync. **[PENDING ANALYSIS]** — schema, snapshot contract, queue semantics, reconciliation algorithm, callable-vs-write, App Check offline behavior, F08↔F07 boundary, DURUM 0 sequencing, Release Scope.
  * Routing: Technical Analyst (F08.0-AN → `analysis.md`) → Tech Lead (F08.CONTRACT-TL — finalize `architecture.md` + `release.md`, trigger Project Setup, open delivery tasks) → Project Setup (`infra/` DURUM 0) → Backend Developer + Frontend/Mobile Developer → QA → Tech Lead → DevOps/Release Engineer (release gate) → Tech Lead (close).

---

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-06
* Summary: F08 created and activated after F06 close-out. `prd.md` (derived from product PRD §6.1 F08 + §5/§11/§12/§15/§16/§51) + initial `architecture.md` skeleton (LOCKED substrate + 10 PENDING-ANALYSIS items) + this orchestration. Complexity COMPLEX → Technical Analyst. `feature-board.md` + `system-state.md` synced. Nothing committed to git.

---

## Next Role

Technical Analyst

---

## Next Action

### Technical Analyst

```text
Produce features/f08-offline-persistence-and-sync/analysis.md.

Authority to read: features/f08-.../prd.md (User Stories, Acceptance Criteria, Edge Cases, Success Metrics, Open
Questions); features/f08-.../architecture.md (LOCKED substrate + the 10 "Open Items"); project-authority/platform.md
§4 (contract rules, callable error format), §5 (Drift, write-through, forward-only migrations, never-drop
bests/streak, monotonic Stopwatch, guestId, kv snapshot), §6 (guest-only, Anonymous Auth, Firestore create-only,
App Check soft-enforce), §7 (session-level sync ownership, lifecycle), §8 (payload validation, no PII);
product-prd.md §15 (data model), §16 (domain events), §51 (open questions); features/f02-grid-engine/architecture.md
(what the engine exposes for persistence). setup-manifest.md Workspace Targets → infra/.

Resolve, with a recommendation + rationale + edge cases for each:
1. Drift schema — tables, columns, keys for product-prd §15 (PlaySession, PersonalBest, JourneyProgress, DailyEntry,
   DailyStreak, Settings, Player). Which data is a typed table vs the single kv active-session JSON row. guestId
   placement + backfill; no device-scoped PK on player data. Migration step model + an explicit "never drop
   personal_best / daily_streak / daily_entry first-run" migration rule + how it is tested.
2. Active-session snapshot JSON contract — locked key names for grid, moveCount, undoHistory, undosRemaining,
   restartCount, elapsedTimeMs, thawedFrozenCells, puzzleId, status, startedAt. What is stored vs re-derived from
   the applied-move list on restore. This is the shape F03 will design to — be precise.
3. sync_queue — item schema; states (pending / in_flight / synced / parked); idempotency key (guestId, lang, date);
   ack-only transition to synced; backoff schedule + attempt cap; parked behavior. The exactly-once mechanism end to
   end.
4. Reconciliation — first-run-authoritative algorithm; local daily_entry.firstRun* set once and never mutated by
   sync; server create-only; ALREADY_SUBMITTED treated as a client success; the "both think they're first" tie-break.
5. Firebase sync surface — HTTPS callable submitDailyResult (platform.md §4 error codes) vs a direct client
   create-only Firestore write. Recommend one, with the safety argument. Payload fields + server-side validation
   ranges (platform.md §8).
6. App Check posture for the MVP (soft-enforce) + behavior when attestation is unavailable offline.
7. F08 <-> F07 scope boundary — recommend: does F08 ship a fake/mock daily-result producer and test the queue +
   reconciliation end-to-end now (F06-style split), with F07 wiring the real producer later? Or wait on F07?
8. Streak-integrity / clock-timezone edge cases that touch storage (lastCompletedDate durability, monotonic elapsed)
   vs the streak rule (F07 owns the rule).
9. infra/ DURUM 0 sequencing — before Backend work (callable + rules exist to build against) vs parallel with the
   Drift persistence core (which needs no Firebase).
10. Inputs the Tech Lead needs to set Release Scope + update release.md (Firebase deploy gate, Drift migration
    rollback-readiness, App Check config, secret names).

Do NOT write contract authority or edit architecture.md — recommendations only. On completion set
Next Role = Tech Lead (to consume analysis.md into architecture.md and open delivery tasks).
```

---

## Change Log

* v1 (2026-09-06) — Tech Lead: F08 created and activated after F06 `Done`. P0, next on the critical path (`product-prd.md` §12.6 build order; feature-board priority). `prd.md` + initial `architecture.md` skeleton (LOCKED substrate + 10 PENDING-ANALYSIS items) + orchestration. Complexity COMPLEX → Technical Analyst pass (F08.0-AN → `analysis.md`). No UI Designer. DevOps/Release Engineer + Project Setup (`infra/` DURUM 0) expected. Routing: Technical Analyst → Tech Lead (finalize contract) → Project Setup → Backend + Frontend → QA → Tech Lead → DevOps/Release Engineer → Tech Lead. `feature-board.md` + `system-state.md` synced.
