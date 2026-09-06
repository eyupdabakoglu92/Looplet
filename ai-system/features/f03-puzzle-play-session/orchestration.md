# F03 — puzzle-play-session: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In Progress — activated 2026-09-06.** Initial contract (`architecture.md`) produced by the Tech Lead: substrate LOCKED (consumed F02 + F08 contracts, screen state machine, gesture→Move mapping envelope, MOVES/Undo/Restart rules, persistence integration, completion sequence, animation/input-lock, route/navigation, QA focus, `Release Scope = none`); a small set of `[PENDING — UI]` / `[PENDING — IMPL tuning]` items resolve in the UI Designer + Frontend passes. **Next: UI Designer** (`ui-design.md`).

F03 is activated in parallel with **F08 parked** (`In Release`, deploy deferred by user decision to end-of-MVP). F08's engineering is complete and ready; F03 is the other branch of the `F06 → (F08, F03)` critical-path fork and needs no Firebase. See F08 `orchestration.md → Last Decision (DURUM 5.5)` for the parallelization rationale.

---

## Current Owner

UI Designer

---

## Complexity Decision

* **NOT COMPLEX → no Technical Analyst.** Checked against the complexity criteria:
  * Multiple services / >3 endpoints — **no** (client-only, one screen, zero backend).
  * Unclear acceptance criteria — **no** (11 crisp Given/When/Then ACs in `prd.md`, straight from the product PRD).
  * New entity / data model — **no** (F02 owns grid state; F08 owns the persistence schema + the frozen snapshot shape).
  * Strong auth / permission layer — **no** (single actor, guest identity already established).
  * Realtime / async / sync-conflict complexity — **borderline but no**: gesture + animation + input-lock is time-bound interaction, not event-driven sync; the engine is pure/synchronous; there is no queue.
  * Cross-feature dependency on an unfinished contract — **no**: F02 is `Done` + locked; the F08 snapshot contract is `[LOCKED — F03 designs to this]` and on-device (F08's parked deploy is irrelevant to it).
  * State-machine conceptuality — **mild**: idle / tracking / animating / won is a small, well-understood set, fully specified in `architecture.md §6`.
  * Unsafe-assumption risk — **one** open product question (diagonal-swipe tie handling), which is a Tech Lead technical decision (favor horizontal within a tie band) already made in `architecture.md §7`. Not enough to warrant an analyst pass.
* **UI Designer REQUIRED.** New player-facing screen; the core interaction *feel* (gesture affordance, swipe-begin highlight, win reveal, Restart placement away from the grid), multiple visible states (idle / tracking / animating / won / minimal completion panel), accessibility cues (non-color win indicator, ≥44 pt hitboxes, text scaling), and premium-quality bar all need real UI/UX decisions — Frontend must not improvise them. See `design/design-doctrine.md` + `design/premium-ui-rubric.md`.
* **DevOps/Release Engineer: NOT required.** `Release Scope = none` — client-only, no infra/CI/deploy change (`architecture.md §17`, `release.md §2`).

---

## Active Task Ledger

- [x] Task ID: F03.CONTRACT-TL | Assigned Role: Tech Lead | Status: **Done (2026-09-06)** | `prd.md` + initial `architecture.md` produced. Substrate LOCKED; `[PENDING — UI]` / `[PENDING — IMPL tuning]` items enumerated in `architecture.md §18`. Complexity decided (not COMPLEX; UI Designer required; no DevOps). Routing set.
- [ ] Task ID: F03-UI | Assigned Role: UI Designer | Status: **Open — NEXT** | Produce `features/f03-puzzle-play-session/ui-design.md` — an applicable UI/UX handoff for the play screen. Must resolve the `architecture.md §18 [PENDING — UI]` list and honor `design-doctrine.md` + `premium-ui-rubric.md`. See the brief in `## Next Action`. No code.
- [ ] Task ID: F03-FE1 | Assigned Role: Frontend/Mobile Developer | Status: Open (after F03-UI) | Screen scaffold + route `'/play'` + `PlaySessionArgs` + portrait lock + a debug puzzle entry that injects an F06 smoke-set `Puzzle` via `toEngineConfig`.
- [ ] Task ID: F03-FE2 | Assigned Role: Frontend/Mobile Developer | Status: Open | Gesture recognizer → `Move` mapping per `architecture.md §7` (threshold `T`, dominant axis, tie band `B` favor-horizontal, one-cell, first-pointer-only, off-screen release). Pure, unit-tested mapping function separated from the widget.
- [ ] Task ID: F03-FE3 | Assigned Role: Frontend/Mobile Developer | Status: Open | Screen state machine (idle / tracking / animating / won), 150–250 ms shift animation with full input lock and **no queue**, <50 ms release→anim latency, swipe-begin row/column highlight.
- [ ] Task ID: F03-FE4 | Assigned Role: Frontend/Mobile Developer | Status: Open | `MOVES` HUD (= `engine.moveCount`, settled only), Undo (3-action quota, no-op + no prompt at 0), Restart (reset, no dialog, placed away from grid, `restartCount++`).
- [ ] Task ID: F03-FE5 | Assigned Role: Frontend/Mobile Developer | Status: Open | Persistence integration per `architecture.md §9`: write-through `ActiveSessionRepo.save` after every settled move/undo/restart; hydrate on open via the F08 restore path; `status: completed` + `clearActiveSession()` on completion-panel open; `ElapsedTimer` pause/resume on lifecycle.
- [ ] Task ID: F03-FE6 | Assigned Role: Frontend/Mobile Developer | Status: Open | Completion sequence (lock → win-row highlight with a non-color cue → bounded success animation → **minimal functional** completion panel: target word + player moves + Retry + Close; no rating logic — F04 seam).
- [ ] Task ID: F03-FE7 | Assigned Role: Frontend/Mobile Developer | Status: Open | Backgrounding / interruption (`architecture.md §12`): cancel in-progress gesture on `paused`; resolve mid-animation to the settled end state on `resumed`; snapshot always settled.
- [ ] Task ID: F03-FE8 | Assigned Role: Frontend/Mobile Developer | Status: Open | Localize `MOVES` + all strings; `ui-design.md` alignment; `analyze` + `format:check` + widget/unit tests green; append `frontend.md`.
- [ ] Task ID: F03-QA1…QAn | Assigned Role: QA | Status: Open (after Frontend) | End-to-end client QA per `architecture.md §16` — `runtime` (device/simulator) mandatory (0 double-registered moves during animation; gesture accuracy on a small + a large device; exactly-one-cell for flick vs drag; input-lock no-queue; background mid-animation; portrait lock; resume via F08 snapshot) + `automated functional` (gesture→Move mapping, counters, state machine, snapshot serialization) + `ui-design.md` alignment.

---

## QA Scope

* **[LOCKED]** (see `architecture.md §16`). End-to-end **client** feature. Evidence class: `runtime` (device/simulator — gesture accuracy, no double-count during animation, exact-one-cell, input-lock, backgrounding, portrait lock, F08-snapshot resume) + `automated functional` (pure gesture→`Move` mapping, MOVES/undo/restart logic, state machine, snapshot serialization). **Not `source-only`** — product Success Metrics are runtime claims. `ui-design.md` alignment in scope once it exists. No backend, no security surface.

---

## Release Scope

`none` — client-only screen; no Cloud Functions / rules / Remote Config / content-pack / distributable-surface change (`architecture.md §17`, `project-authority/release.md §2`). CI gates still run. The first app-build distribution gate is a later feature (~F05).

---

## Open Tasks

### Contract
- [x] (F03.CONTRACT-TL) `prd.md` + initial `architecture.md` — done 2026-09-06. Substrate LOCKED; `[PENDING — UI]` / `[PENDING — IMPL tuning]` enumerated.

### UI Design
- [ ] (F03-UI) `ui-design.md` — play screen handoff; resolve `architecture.md §18 [PENDING — UI]`; honor `design-doctrine.md` + `premium-ui-rubric.md`. **NEXT.**

### Frontend
- [ ] (F03-FE1…FE8) screen + gesture mapping + state machine/animation + HUD/Undo/Restart + persistence integration + completion sequence + backgrounding + localization/tests. After F03-UI.

### QA
- [ ] (F03-QA) end-to-end client QA — runtime mandatory. After Frontend.

---

## Blockers

* **None.** F02 (`Done`, contract locked) and the F08 on-device snapshot contract (`[LOCKED]`) are both available. F08's parked Firebase deploy is **not** a blocker — F03 uses only the on-device persistence layer + restore path, which are complete and functional.
* **Content:** F03 QA uses the F06 5-puzzle smoke set via the debug puzzle entry. The full 30-level set (`F06-CONTENT`) is a separate follow-on and is **not** required for F03 QA.
* **Not a blocker, noted:** real Journey/Daily entry (F05/F07), the real completion panel (F04), onboarding overlay (F09), audio/haptics (F11), analytics (F12) are all downstream and explicitly out of F03 scope.

---

## Last Decision

* 2026-09-06 — Tech Lead (**F03 activation + initial contract**):
  * **Activated F03** as the active feature while **F08 is parked** (`In Release`, deploy deferred by user decision — see F08 `orchestration.md → Last Decision, DURUM 5.5`). F03 is the other branch of the `F06 → (F08, F03)` fork, P0, depends only on F02 (`Done`), needs no Firebase. Deliberate user-directed exception to "no new feature while one is unfinished" — F08 is *ready*, not *unfinished*, and the user asked that "everything else be made ready".
  * **Complexity: NOT COMPLEX** → no Technical Analyst (rationale in `## Complexity Decision`). **UI Designer REQUIRED** — new player-facing screen, interaction feel, multiple visible states, accessibility cues, premium bar. **No DevOps** — `Release Scope = none`.
  * **Contract produced** (`architecture.md`): consumed F02 + F08 contracts pinned; screen state machine (idle/tracking/animating/won, no queue); gesture→`Move` mapping envelope (threshold `T`, dominant axis, **tie band → favor horizontal** — resolves the product PRD's open diagonal-tie question as a Tech Lead technical decision); MOVES = `engine.moveCount` (settled only); Undo = 3-action F03-owned quota, no prompt at 0; Restart = reset + `restartCount++`, no dialog, away from the grid; write-through persistence into the **F08-frozen snapshot shape** + hydrate via the F08 restore path; completion sequence with a **minimal functional** panel (F04 owns the real one); 150–250 ms animation with full input lock and no queue; portrait-locked route `'/play'`; `runtime`-mandatory QA. `Release Scope = none` (`architecture.md §17`).
  * **Deferred to Frontend + QA device tuning:** exact threshold `T` and tie band `B` values (envelopes set). **Deferred to UI Designer:** the `[PENDING — UI]` list in `architecture.md §18`.
  * Routing: **UI Designer (F03-UI → `ui-design.md`)** → Frontend/Mobile Developer (F03-FE1…FE8) → QA → Tech Lead (close). `feature-board.md` + `system-state.md` synced (Active Feature → F03).

---

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-06
* Summary: F03 activated (parallel with F08 parked). `prd.md` + initial `architecture.md` created (substrate LOCKED; `[PENDING — UI]` / `[PENDING — IMPL tuning]` enumerated). Complexity = not COMPLEX (no Analyst); UI Designer required; no DevOps. `Current Owner → UI Designer`; `Next Role → UI Designer`. `feature-board.md` + `system-state.md` synced.

---

## Next Role

UI Designer

---

## Next Action

### UI Designer — F03-UI → `ui-design.md` — ⬅ NEXT

```text
Task: produce features/f03-puzzle-play-session/ui-design.md — an applicable UI/UX handoff for the
puzzle-play screen. No code.

Authority: features/f03-puzzle-play-session/architecture.md (contract — especially §6 state model,
§7 gesture mapping, §8 MOVES/Undo/Restart, §10 completion sequence, §13 route/chrome, §18 PENDING-UI list),
features/f03-puzzle-play-session/prd.md (AC1–AC11 + §6 constraints), design/design-doctrine.md,
design/premium-ui-rubric.md.

Must deliver:
1. Screen goal + visual hierarchy — the target word is ALWAYS visible and VISUALLY SEPARATED from the
   grid (AC1); the grid occupies ~85–90% of screen width; MOVES HUD; Undo (with a clear "N left"
   affordance); Restart placed AWAY from the grid so it can't be hit while swiping (§8).
2. Layout structure + component blueprint — portrait only; one-handed reach; cell hitboxes ≥ 44×44 pt;
   OS text scaling respected; Turkish-length-tolerant.
3. All states, explicitly:
   - idle
   - gesture tracking (the swipe-begin row/column highlight — AC9)
   - animating (input-locked; how "locked" reads to the player without feeling broken)
   - won (winning-row highlight WITH A NON-COLOR CUE too — accessibility; §10 / prd §6)
   - the short success animation choreography (functional, bounded ≤ ~600 ms)
   - the MINIMAL completion panel (target word + player moves + Retry + Close only — F04 owns the real
     stars/best/Next panel later; do NOT design rating UI here, but do make the seam not look broken)
   - loading / empty / error for the debug puzzle entry (dev-only, keep minimal)
4. Motion intent — shift animation feel within 150–250 ms; release→start must feel instant (<50 ms);
   the win reveal.
5. Screen chrome — a minimal back affordance to the caller/menu (no mandated title bar); follow
   design-doctrine.md. If you propose a shared header standard, flag it for Tech Lead.
6. Background / color / typography / surface-depth decisions per the doctrine + rubric; premium
   differentiators, not a generic wireframe.

Out of scope: the real completion panel (F04), onboarding overlay (F09), audio/haptics (F11), the
Journey level list (F05). Gesture threshold / tie-band NUMBERS are Frontend+QA device tuning, not a UI
decision — but the affordance that communicates "swipe a row/column" IS yours.

End: Current Owner → Frontend/Mobile Developer; Next Role → Frontend/Mobile Developer (F03-FE1…FE8).
```

→ then `Run Frontend/Mobile Developer` → `Run QA` → `Run Tech Lead` (close).

---

## Change Log

* v1 (2026-09-06) — Tech Lead: **F03 created + activated.** P0, the other branch of the `F06 → (F08, F03)` critical-path fork; depends only on F02 (`Done`); no Firebase. Activated in parallel with **F08 parked** (`In Release` — user deferred the Firebase Blaze upgrade / first deploy to end-of-MVP; F08's engineering is complete and ready). `prd.md` derived from `product-prd.md` F03 section (AC1–AC11 + perf/a11y/animation constraints). Initial `architecture.md`: substrate LOCKED (consumed F02 + F08 contracts; screen state machine idle/tracking/animating/won with no input queue; gesture→`Move` mapping envelope with **tie band → favor horizontal** as the Tech Lead resolution of the product's open diagonal-tie question; MOVES = `engine.moveCount` settled-only; Undo = 3-action F03 quota with no prompt at 0; Restart = reset + `restartCount++`, no dialog, away from grid; write-through persistence into the F08-frozen snapshot shape + hydrate via the F08 restore path; completion sequence with a minimal functional panel as an F04 seam; 150–250 ms animation, full input lock, no queue; portrait-locked route `'/play'`; `runtime`-mandatory QA; `Release Scope = none`); `[PENDING — UI]` and `[PENDING — IMPL tuning]` items enumerated in §18. Complexity: **not COMPLEX** (no Technical Analyst); **UI Designer required**; **no DevOps/Release Engineer** (`Release Scope = none`). Routing: **UI Designer (F03-UI → `ui-design.md`)** → Frontend/Mobile Developer (F03-FE1…FE8) → QA → Tech Lead (close). `feature-board.md` + `system-state.md` synced (Active Feature → F03; F08 → In Release / parked). Nothing committed to git.
