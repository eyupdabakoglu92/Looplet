# F08 — offline-persistence-and-sync: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In Progress — Analysis delivered; awaiting Tech Lead contract finalization**

---

## Current Owner

Tech Lead

---

## Current Phase

Technical Analysis **complete** (F08.0-AN → `analysis.md` delivered). Next: Tech Lead consumes `analysis.md` into `architecture.md` (flip [PENDING ANALYSIS] → [LOCKED]), makes the four explicit calls (sync surface; `guestId`/`firebaseUid` identity; F08↔F07 split; `infra/` DURUM 0 sequencing), sets `Release Scope` + updates `release.md`, triggers the `infra/` Project Setup DURUM 0, and opens the F08-BE / F08-FE / F08-QA tasks.

---

## Complexity Decision

* **COMPLEX.** Triggers: a new persistence data model (§15 → Drift tables); realtime/async + sync/conflict resolution (offline exactly-once, first-run-authoritative reconciliation); state-machine conceptuality (forward-only migration steps; `sync_queue` states); cross-feature dependency on F07 (Daily producer) with an unresolved boundary; unsafe-assumption risk (the product PRD explicitly leaves the backend sync surface to the Tech Lead). → **Technical Analyst pass before contract finalization.**
* **No UI Designer** — Infrastructure; F08 owns no screens. F10 surfaces streak/progress; F03 owns the play-session UI. F08 exposes stores + services.
* **DevOps/Release Engineer** — expected **after QA**: first Firebase deploy (Functions/rules/App Check) + a Drift forward migration ⇒ a release gate. `Release Scope` set at contract finalization.
* **Project Setup** — an `infra/` DURUM 0 (+ app Firebase wiring) is required before Backend implementation; sequencing (before vs parallel with the persistence core) is an analysis input, Tech-Lead-triggered.

---

## Active Task Ledger

- [x] Task ID: F08.0-AN | Assigned Role: Technical Analyst | Status: Done | `analysis.md` delivered. All 10 open items addressed with recommendation + trade-offs + edge cases. Key recommendations: HTTPS **callable** `submitDailyResultV1` (not a direct client write); **decouple** local `guestId` (UUID) from `firebaseUid` server identity (flagged as a `platform.md §6` reconciliation for the Tech Lead); **F06-style split** — F08 ships persistence core + `sync_queue` + reconciliation + callable/rules + a fake daily-result producer, F07 wires the real producer later; **parallel** `infra/` DURUM 0 (Drift core needs no Firebase, starts immediately). Drift schema (§6.1) + active-session snapshot contract (§6.2, locked keys, `appliedMoves` IS the undo history) + `sync_queue` state machine (§6.3) + exactly-once/reconciliation (§4.6) all specified for the Tech Lead to lock. Expected `Release Scope` = `production-readiness` + `rollback-readiness`; new dep `connectivity_plus`; requests F02 `restoreMoves(List<Move>)` batch API. Do NOT treat as consumed until the Tech Lead moves it into `architecture.md`.
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
- [x] (F08.0-AN) Technical analysis of F08 — done. All 10 open items resolved with recommendations + trade-offs. Output: `features/f08-offline-persistence-and-sync/analysis.md`. Not yet consumed into `architecture.md` (Tech Lead's next step).

### Contract
- [ ] (F08.CONTRACT-TL) Tech Lead consumes `analysis.md` → finalizes `architecture.md`, sets `Release Scope`, updates `release.md`, opens delivery tasks.

### Project Setup
- [ ] (F08.SETUP-0) `infra/` Firebase DURUM 0 + app Firebase wiring. Gated on the contract.

### Backend / Frontend / DevOps / QA
- _(not opened — F08.CONTRACT-TL opens these against the locked contract)_

---

## Blockers

* None hard. F08.SETUP-0 (infra) + all Backend/Frontend/DevOps/QA work are gated on F08.CONTRACT-TL. The analysis recommends running F08.SETUP-0 **in parallel** with the Drift persistence core (F08-FE1…FE5 need no Firebase).
* **Tech Lead decisions required at F08.CONTRACT-TL** (from `analysis.md §15/§17`): (1) sync surface — HTTPS callable (recommended) vs direct client Firestore write; (2) **`platform.md §6` reconciliation** — decouple local `guestId` (UUID) from `firebaseUid` server identity (recommended) vs keep them equivalent (then offline-first-launch sync waits for auth); (3) confirm the F08↔F07 split (recommended); (4) `infra/` DURUM 0 sequencing (parallel recommended); (5) `Release Scope` + `release.md` update; (6) approve new dep `connectivity_plus`; (7) request F02 `restoreMoves(List<Move>)` batch API; (8) App Check MVP posture (soft-enforce assumed); (9) parked-item retry policy.
* **Open product/tech question** (`product-prd §51`, surfaced in `analysis.md §17`): server-side streak/clock-integrity check — analysis assumes **not** in MVP; escalate to PO only if that assumption is wrong.
* Cross-feature: F07 is `Not Started` and depends on F08; F08 defines the sync path F07 plugs into (via a fake producer test seam), it does not wait for F07.

---

## Last Decision

* 2026-09-06 — Tech Lead (F08 activation):
  * Activated after F06 `Done`. P0, next on the critical path per `product-prd.md` §12.6 build order (`… F01, F02, F06, F08, F03, F05`) and the feature-board priority ordering — persistence is landed before the F03 play screen so it is designed in, not bolted on. F08 depends only on the F02 state shape (Done); no half-finished feature is open.
  * Complexity **COMPLEX** (new persistence data model + offline exactly-once sync + first-run-authoritative reconciliation + forward-migration state machine + F07 cross-dependency + PRD-deferred backend surface) → **Technical Analyst pass** before contract finalization.
  * **No UI Designer** (Infrastructure, no screens). **DevOps/Release Engineer** expected post-QA (first Firebase deploy + Drift migration). **Project Setup** `infra/` DURUM 0 required pre-Backend; sequencing is an analysis input.
  * `architecture.md` skeleton: **[LOCKED]** — persistence in `app/` (Drift, write-through, forward-only migrations, `guestId` on player rows, `kv` active-session snapshot, monotonic durations); `sync_queue` + connectivity watching are a session-level service never owned by a screen; Firestore `dailyResults/**` create-only + App Check; local result always authoritative; first-run never mutated by sync. **[PENDING ANALYSIS]** — schema, snapshot contract, queue semantics, reconciliation algorithm, callable-vs-write, App Check offline behavior, F08↔F07 boundary, DURUM 0 sequencing, Release Scope.
  * Routing: Technical Analyst (F08.0-AN → `analysis.md`) → Tech Lead (F08.CONTRACT-TL — finalize `architecture.md` + `release.md`, trigger Project Setup, open delivery tasks) → Project Setup (`infra/` DURUM 0) → Backend Developer + Frontend/Mobile Developer → QA → Tech Lead → DevOps/Release Engineer (release gate) → Tech Lead (close).

---

## Consumed Signals

* `analysis.md` (F08.0-AN) delivered 2026-09-06 — **NOT yet consumed** into `architecture.md`. Contract authority is still the `architecture.md` skeleton; its [PENDING ANALYSIS] items remain pending until the Tech Lead moves the `analysis.md §17` decisions in. Downstream delivery roles must not treat F08 as contract-ready.
* Unresolved analysis questions for the Tech Lead: `analysis.md §15` (12 items) + `§17` decision list — chiefly the sync-surface choice and the `guestId`/`firebaseUid` `platform.md §6` reconciliation.

---

## Last Update

* Updated By: Technical Analyst
* Timestamp: 2026-09-06
* Summary: F08.0-AN complete — `analysis.md` delivered (sections 1–19). All 10 orchestration open items resolved with recommendation + trade-offs + edge cases. Headline recommendations: HTTPS **callable** `submitDailyResultV1` (platform.md §3/§4 already pre-blesses it) over a direct client write; **decouple** local `guestId` (UUID, durable local key) from `firebaseUid` (server identity / Firestore path key) — flagged as a `platform.md §6` authority reconciliation for the Tech Lead; **F06-style split** — F08 delivers persistence layer + `DailyPuzzleCache` mechanism + `DailyResultSyncService` + callable/rules + a fake daily-result producer test seam, verified end-to-end on the Firebase emulator; F07 later wires the real Daily producer via the same `enqueue(...)`; run `infra/` DURUM 0 **parallel** with the no-Firebase Drift core. Full Drift schema (§6.1), locked active-session snapshot JSON (§6.2 — `appliedMoves` IS the undo history; `thawedFrozenCells` is a re-derived cache), `sync_queue` state machine (§6.3), exactly-once + reconciliation (§4.6), and the callable request/response/error contract (§5) all specified for the Tech Lead to lock. Task breakdown F08-BE1…BE5 / F08-FE1…FE11 / QA in §16. Contract risks + upstream conflicts in §17. Nothing committed to git.

---

## Next Role

Tech Lead

---

## Next Action

### Tech Lead — F08.CONTRACT-TL

```text
Consume analysis.md into architecture.md and open the F08 delivery tasks.

Authority: features/f08-.../analysis.md (§6 data model, §5 API contract, §4.6 reconciliation, §16 task breakdown,
§17 Delivery Note — the "Decisions to move into architecture.md" list + the four explicit calls), features/f08-.../
prd.md, features/f08-.../architecture.md (skeleton — flip [PENDING ANALYSIS] -> [LOCKED]), platform.md §3–§8/§11,
release.md, setup-manifest.md (Workspace Targets -> infra/), features/f02-grid-engine/architecture.md.

1. Move analysis.md §17 "Decisions to move into architecture.md" (items 1–8) into architecture.md; flip every
   [PENDING ANALYSIS] section to [LOCKED]. Reconcile any stale skeleton wording in the same pass.
2. Make the explicit calls and record each in architecture.md:
   - Sync surface: HTTPS callable submitDailyResultV1 (analyst-recommended) vs direct client Firestore write.
   - Identity: decouple local guestId (UUID) from firebaseUid (analyst-recommended) vs keep platform.md §6
     equivalence (then offline-first-launch sync waits for auth). If decoupled, add a platform.md §6 amendment note
     (this is a platform-authority reconciliation, Tech Lead scope).
   - F08<->F07 split: confirm F08 ships the persistence core + sync + fake producer now; F07 wires the real producer.
   - infra/ DURUM 0 sequencing: parallel with the Drift core (analyst-recommended).
3. Set orchestration.md -> Release Scope (analyst expects production-readiness + rollback-readiness) and update
   project-authority/release.md with the Firebase Functions/rules deploy gate + Drift forward-migration
   rollback-readiness + App Check config + (no) secret names. Plan a DevOps/Release Engineer task AFTER QA.
4. Trigger the infra/ Project Setup DURUM 0 (F08.SETUP-0): set Current Owner = Project Setup for that task, or
   sequence it parallel per the decision. Add the scaffold recipe pointer for infra/ to setup-manifest.md if needed.
5. Approve the new app/ dependency connectivity_plus (setup-manifest.md dep-deviation rule) and record it. Request
   the F02 restoreMoves(List<Move>) batch API on GridEngine (non-breaking additive; note in f02 architecture Open
   Technical Decisions or a small F02 amendment).
6. Open F08-BE1…BE5 + F08-FE1…FE11 + F08 QA tasks (analysis.md §16) in the Active Task Ledger with assigned roles;
   set the parallel-work strategy (Drift core FE1–FE5 || infra DURUM 0 || callable BE2–BE4).
7. Decide the two still-open policy points: App Check MVP posture (soft-enforce assumed) and parked-item retry
   policy (analyst suggests bounded auto-retry on app start).
8. If the PO must rule on a server-side streak/clock-integrity check (product-prd §51) — the analysis assumes NOT in
   MVP — either confirm that assumption or raise a PO decision item. Do not push it to implementation unresolved.

Route: after F08.CONTRACT-TL, Next Role is Project Setup (infra DURUM 0) and/or Frontend/Mobile Developer +
Backend Developer per the parallel strategy. No UI Designer.
```

---

## Change Log

* v1 (2026-09-06) — Tech Lead: F08 created and activated after F06 `Done`. P0, next on the critical path (`product-prd.md` §12.6 build order; feature-board priority). `prd.md` + initial `architecture.md` skeleton (LOCKED substrate + 10 PENDING-ANALYSIS items) + orchestration. Complexity COMPLEX → Technical Analyst pass (F08.0-AN → `analysis.md`). No UI Designer. DevOps/Release Engineer + Project Setup (`infra/` DURUM 0) expected. Routing: Technical Analyst → Tech Lead (finalize contract) → Project Setup → Backend + Frontend → QA → Tech Lead → DevOps/Release Engineer → Tech Lead. `feature-board.md` + `system-state.md` synced.
* v2 (2026-09-06) — Technical Analyst: F08.0-AN done. `analysis.md` delivered (sections 1–19). All 10 open items resolved. Recommendations: HTTPS callable `submitDailyResultV1`; decouple local `guestId` from `firebaseUid` (flagged `platform.md §6` reconciliation); F06-style F08↔F07 split (persistence core + sync + fake producer now, F07 wires real producer); parallel `infra/` DURUM 0. Specified: Drift schema (§6.1), locked active-session snapshot JSON (§6.2), `sync_queue` state machine (§6.3), exactly-once + reconciliation (§4.6), callable contract (§5), task breakdown (§16). Contract risks + upstream `platform.md §6` conflict in §17. Current Owner → Tech Lead; Next Role → Tech Lead (F08.CONTRACT-TL — consume into `architecture.md`, make the 4 calls, set Release Scope, trigger `infra/` DURUM 0, open delivery tasks).
