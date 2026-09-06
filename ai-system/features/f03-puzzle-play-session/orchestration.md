# F03 — puzzle-play-session: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In Progress — UI handoff delivered 2026-09-06.** Initial contract (`architecture.md`) LOCKED-substrate by the Tech Lead; **`ui-design.md` delivered by the UI Designer** — Direction A ("Backlit board on a dark stage"), self-review 94/100, resolves the `architecture.md §18 [PENDING — UI]` list (screen layout + hierarchy, target-word separation, swipe-begin highlight, diegetic input-lock affordance, win-row highlight + non-colour seam-bar cue, bounded success animation, shift duration/curve envelope 170–210 ms, minimal-but-crafted completion sheet, "no title bar + quiet back chevron" chrome, debug loading/error states). Four non-blocking `Needs Tech Lead Clarification` items (sensible defaults chosen). **Next: Frontend/Mobile Developer** (F03-FE1…FE8).

F03 is activated in parallel with **F08 parked** (`In Release`, deploy deferred by user decision to end-of-MVP). F08's engineering is complete and ready; F03 is the other branch of the `F06 → (F08, F03)` critical-path fork and needs no Firebase. See F08 `orchestration.md → Last Decision (DURUM 5.5)` for the parallelization rationale.

---

## Current Owner

Frontend/Mobile Developer

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
- [x] Task ID: F03-UI | Assigned Role: UI Designer | Status: **Done (2026-09-06)** | `features/f03-puzzle-play-session/ui-design.md` delivered. Direction A ("Backlit board on a dark stage" — spotlight stage, backlit-keycap tiles, loop-rail motif, wrap animation, outline-ghost target, amber win-fill + drawn L→R seam bar). Self-review 94/100 (target band). Resolves the `architecture.md §18 [PENDING — UI]` list. §14 has 4 non-blocking Tech Lead clarifications (no primary CTA on the playing screen; F03 owns first-pass locked/frozen tile *visuals*; proposed shared "no title bar + quiet chevron" chrome; placeholder microcopy).
- [ ] Task ID: F03-FE1 | Assigned Role: Frontend/Mobile Developer | Status: **Open — NEXT** | Screen scaffold + route `'/play'` + `PlaySessionArgs` + portrait lock + a debug puzzle entry that injects an F06 smoke-set `Puzzle` via `toEngineConfig`.
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
- [x] (F03-UI) `ui-design.md` — delivered 2026-09-06. Direction A; 94/100; resolves `architecture.md §18 [PENDING — UI]`. 4 non-blocking Tech Lead clarifications in §14.

### Frontend
- [ ] (F03-FE1…FE8) screen + gesture mapping + state machine/animation + HUD/Undo/Restart + persistence integration + completion sequence + backgrounding + localization/tests, against `architecture.md` + `ui-design.md`. **NEXT.**

### QA
- [ ] (F03-QA) end-to-end client QA — runtime mandatory. After Frontend.

---

## Blockers

* **None.** F02 (`Done`, contract locked) and the F08 on-device snapshot contract (`[LOCKED]`) are both available. F08's parked Firebase deploy is **not** a blocker — F03 uses only the on-device persistence layer + restore path, which are complete and functional.
* **Content:** F03 QA uses the F06 5-puzzle smoke set via the debug puzzle entry. The full 30-level set (`F06-CONTENT`) is a separate follow-on and is **not** required for F03 QA.
* **Not a blocker, noted:** real Journey/Daily entry (F05/F07), the real completion panel (F04), onboarding overlay (F09), audio/haptics (F11), analytics (F12) are all downstream and explicitly out of F03 scope.

---

## Last Decision

* 2026-09-06 — UI Designer (**F03-UI delivered — `ui-design.md`**):
  * **Direction A selected** — "Backlit board on a dark stage": deep atmospheric spotlight stage, the 5×5 board as the only bright/saturated cluster, **backlit-keycap tiles** (bone gradient + inner highlight + AO shadow + faint backlight), a **loop-rail motif** (fading luminous edge rails that ignite directionally on drag), a **wrap animation** (edge-mask exit + opposite-edge emergence — the shift *shows* the loop), the **target as outline-ghost tiles** (same silhouette, 44–48 % scale, separated by scale + treatment + divider glow + ≥28 pt air), and **won = amber fill + a drawn L→R seam bar** (colour AND shape → legible without colour). Direction B ("warm tactile daylight board") rejected as the more mid-segment read per the doctrine's default-premium rule.
  * **Resolves `architecture.md §18 [PENDING — UI]`:** 3-zone portrait layout (target / board / HUD) with fixed 28 pt gaps + a board-first shrink strategy; swipe-begin highlight = row/col lift + directional rail ignite + 8 % dim of the rest (shape+motion, not colour-only); **diegetic input-lock** during the 190 ms shift (controls dim, board focuses — no spinner, no modal); bounded ≤600 ms win sequence; shift duration envelope **170–210 ms** with `cubic-bezier(0.22,1,0.36,1)`; **minimal-but-crafted** completion sheet (kicker + amber word + one `HAMLE` stat + dominant Retry + quiet Close — no stars/best/Next; F04 replaces it); **"no system header, one quiet back chevron top-left, hidden in `won`"** chrome; debug loading (stage + tile silhouettes, no spinner) + error (contained, dev-only) states; locked = brass ring + pin glyph, frozen = frost texture + crystal border (non-colour cues). Colour tokens + type roles + spacing rhythm specified.
  * **Self-review 94/100** (target band 93–96); no rubric fail conditions.
  * **4 non-blocking `Needs Tech Lead Clarification` (§14)** — sensible defaults already chosen, do not block Frontend: (1) confirm "no primary CTA on the playing screen" (the board is the action; Retry in the sheet is the only CTA) so QA doesn't flag it missing; (2) confirm F03 owns the *first-pass visual* treatment of locked/frozen tile states (F02 owns behaviour); (3) whether to lock the "no title bar + quiet chevron" chrome as a cross-screen rule now or defer to F10; (4) final microcopy (`HEDEF / HAMLE / ÇÖZÜLDÜ / Yeniden / Kapat`) — PO/localization.
  * **Contract unchanged.** `architecture.md §6/§7/§8/§9/§11/§13` interaction contract fully honoured; no new behaviour. Current Owner → Frontend/Mobile Developer; Next Role → Frontend/Mobile Developer (F03-FE1…FE8).
* 2026-09-06 — Tech Lead (**F03 activation + initial contract**):
  * **Activated F03** as the active feature while **F08 is parked** (`In Release`, deploy deferred by user decision — see F08 `orchestration.md → Last Decision, DURUM 5.5`). F03 is the other branch of the `F06 → (F08, F03)` fork, P0, depends only on F02 (`Done`), needs no Firebase. Deliberate user-directed exception to "no new feature while one is unfinished" — F08 is *ready*, not *unfinished*, and the user asked that "everything else be made ready".
  * **Complexity: NOT COMPLEX** → no Technical Analyst (rationale in `## Complexity Decision`). **UI Designer REQUIRED** — new player-facing screen, interaction feel, multiple visible states, accessibility cues, premium bar. **No DevOps** — `Release Scope = none`.
  * **Contract produced** (`architecture.md`): consumed F02 + F08 contracts pinned; screen state machine (idle/tracking/animating/won, no queue); gesture→`Move` mapping envelope (threshold `T`, dominant axis, **tie band → favor horizontal** — resolves the product PRD's open diagonal-tie question as a Tech Lead technical decision); MOVES = `engine.moveCount` (settled only); Undo = 3-action F03-owned quota, no prompt at 0; Restart = reset + `restartCount++`, no dialog, away from the grid; write-through persistence into the **F08-frozen snapshot shape** + hydrate via the F08 restore path; completion sequence with a **minimal functional** panel (F04 owns the real one); 150–250 ms animation with full input lock and no queue; portrait-locked route `'/play'`; `runtime`-mandatory QA. `Release Scope = none` (`architecture.md §17`).
  * **Deferred to Frontend + QA device tuning:** exact threshold `T` and tie band `B` values (envelopes set). **Deferred to UI Designer:** the `[PENDING — UI]` list in `architecture.md §18`.
  * Routing: **UI Designer (F03-UI → `ui-design.md`)** → Frontend/Mobile Developer (F03-FE1…FE8) → QA → Tech Lead (close). `feature-board.md` + `system-state.md` synced (Active Feature → F03).

---

## Last Update

* Updated By: UI Designer
* Timestamp: 2026-09-06
* Summary: **F03-UI delivered — `ui-design.md`.** Direction A ("Backlit board on a dark stage"), self-review 94/100. Resolves the `architecture.md §18 [PENDING — UI]` list (3-zone portrait layout + shrink strategy; outline-ghost target separation; swipe-begin lift + directional rail highlight; diegetic input-lock during the 190 ms wrap shift; bounded ≤600 ms win with an amber fill + a drawn L→R seam bar as the non-colour cue; shift envelope 170–210 ms; minimal-but-crafted completion sheet; "no header + quiet back chevron, hidden in `won`" chrome; debug loading/error). Colour tokens + type roles + spacing rhythm specified. Contract unchanged. 4 non-blocking Tech Lead clarifications in §14. `Current Owner → Frontend/Mobile Developer`; `Next Role → Frontend/Mobile Developer`. `feature-board.md` / `system-state.md` not touched (Tech Lead syncs).

---

## Next Role

Frontend/Mobile Developer

---

## Next Action

### Frontend/Mobile Developer — F03-FE1…FE8 — ⬅ NEXT

```text
Task: implement the puzzle-play screen against features/f03-puzzle-play-session/architecture.md
(interaction contract) + features/f03-puzzle-play-session/ui-design.md (visual + state handoff).
Flutter / Riverpod / go_router per platform.md. Client-only; no backend; Release Scope = none.

Authority order: architecture.md (behaviour contract — §6 state machine, §7 gesture→Move, §8
MOVES/Undo/Restart, §9 persistence, §11 animation/input-lock, §12 backgrounding, §13 route/chrome,
§15 validation, §16 QA focus) > ui-design.md (visual + state design; §11 "Must not be broken" list
is binding, §11 "Flexible" list is yours to tune, §11 "Do not cheapen" is binding).

Tasks (see Active Task Ledger F03-FE1…FE8):
- FE1: screen scaffold + route '/play' + PlaySessionArgs{source, journeyLevel?} + portrait lock +
  a debug puzzle entry that injects an F06 smoke-set Puzzle via toEngineConfig (behind a debug
  affordance on the placeholder home; NOT a shipping nav path).
- FE2: pure gesture→Move mapping function (threshold T, dominant axis, tie band B → favor horizontal,
  exactly one cell, first pointer only, off-screen release) — separated from the widget, unit-tested.
  T and B numbers are yours to pick within architecture.md §7 envelopes; document the chosen values
  and expose them so QA can tune on device.
- FE3: screen state machine (idle / tracking / animating / won), 150–250 ms shift (170–210 ms
  recommended, cubic-bezier(0.22,1,0.36,1)) with FULL input lock and NO queue, <50 ms release→start,
  the wrap animation (edge-mask exit + opposite-edge emergence — must be visible, not a plain slide),
  swipe-begin row/col lift + directional loop-rail ignite + 8% dim of the rest.
- FE4: MOVES HUD (= engine.moveCount, settled only, tabular, settle-tick), Undo (3-action quota, pip
  indicator, at 0 → silent no-op, NO dialog/ad/toast), Restart (reset + restartCount++, NO confirm,
  physically separated from Undo — gap ≥24pt + divider + outline treatment, right side, clear of the
  board's swipe band).
- FE5: persistence per architecture.md §9 — write-through ActiveSessionRepo.save after every settled
  move/undo/restart (appliedMoves via app/lib/engine/move_shorthand.dart; thawedFrozenCells cache;
  ElapsedTimer for elapsed); hydrate on open via the F08 restore path when a snapshot matches
  puzzleId (silent, no "resuming" UI); status:completed snapshot + ActiveSessionRepo.clearActiveSession()
  on completion-panel open; ElapsedTimer pause on paused/won, resume on resumed. F03 schedules NO
  background work (F08's session-level lifecycle owns the paused flush + drain).
- FE6: completion sequence — lock → winning-row amber fill + ink-amber letters + L→R stagger + the
  drawn L→R amber seam bar (colour AND shape — NOT optional) → one restrained bloom → the MINIMAL
  functional completion sheet (kicker + formed word + one HAMLE stat + dominant Retry + quiet Close;
  NO stars/optimal/best/Next; NO rating logic — F04 seam). Retry = engine.restart() in place.
- FE7: backgrounding (architecture.md §12) — cancel an in-progress gesture on paused; on resumed
  resolve a mid-animation shift to its settled end state; the persisted snapshot is ALWAYS settled.
- FE8: localize MOVES + all strings (externalized; TR primary; use placeholder keys HEDEF/HAMLE/
  ÇÖZÜLDÜ/Yeniden/Kapat pending PO/loc); ui-design.md alignment pass; melos run analyze +
  format:check + test (widget + unit) green; append frontend.md with task-to-code traceability,
  authority reconciliation, preserved behaviour, and task-level test evidence.

Non-goals (do NOT build): real Journey/Daily entry (F05/F07), the real completion panel (F04),
onboarding overlay (F09), SFX/haptics (F11), analytics events (F12). Locked/frozen tile VISUALS:
render them per ui-design.md §7 first-pass (brass ring + pin glyph / frost texture + crystal border)
— F02 owns the behaviour, F05/F06 author placement.

End: Current Owner → QA; Next Role → QA (F03-QA — end-to-end client, runtime mandatory).
```

→ then `Run QA` → `Run Tech Lead` (F03 close; also resolve the 4 `ui-design.md §14` clarifications).

---

## Change Log

* v2 (2026-09-06) — UI Designer: **F03-UI delivered — `ui-design.md`.** Direction A ("Backlit board on a dark stage") selected over B ("warm tactile daylight board") per the doctrine's default-premium rule. Identity tied to the mechanic: spotlight stage + backlit-keycap tiles + a **loop-rail motif** + a **wrap animation** (edge-mask exit + opposite-edge emergence) + **outline-ghost target** (separated by scale + treatment + divider + air) + **won = amber fill + a drawn L→R seam bar** (colour AND shape → accessibility). Resolves the `architecture.md §18 [PENDING — UI]` list: 3-zone portrait layout (target/board/HUD) with fixed 28 pt gaps + board-first shrink; swipe-begin = row/col lift + directional rail ignite + 8 % dim (shape+motion cue); **diegetic input-lock** during the 190 ms shift (controls dim, board focuses — no spinner/modal); bounded ≤600 ms win sequence; shift envelope **170–210 ms** + `cubic-bezier(0.22,1,0.36,1)`; **minimal-but-crafted** completion sheet (kicker + amber word + one `HAMLE` stat + dominant Retry + quiet Close; no stars/best/Next — F04 replaces it); **"no system header + quiet back chevron top-left, hidden in `won`"** chrome (proposed as a cross-screen rule — Tech Lead to confirm); debug loading (stage + tile silhouettes, no spinner) + error (contained, dev-only). Colour tokens + 3 type roles + 4/8 spacing rhythm specified; locked = brass ring + pin glyph, frozen = frost texture + crystal border (non-colour cues). **Self-review 94/100** (target band), no rubric fail conditions. **Contract unchanged** — `architecture.md §6/§7/§8/§9/§11/§13` fully honoured. §14: 4 non-blocking Tech Lead clarifications (no playing-screen CTA; F03 owns first-pass locked/frozen tile visuals; shared-chrome rule timing; final microcopy). Current Owner → Frontend/Mobile Developer; Next Role → Frontend/Mobile Developer (F03-FE1…FE8). `feature-board.md` / `system-state.md` not touched (Tech Lead syncs). Nothing committed to git.
* v1 (2026-09-06) — Tech Lead: **F03 created + activated.** P0, the other branch of the `F06 → (F08, F03)` critical-path fork; depends only on F02 (`Done`); no Firebase. Activated in parallel with **F08 parked** (`In Release` — user deferred the Firebase Blaze upgrade / first deploy to end-of-MVP; F08's engineering is complete and ready). `prd.md` derived from `product-prd.md` F03 section (AC1–AC11 + perf/a11y/animation constraints). Initial `architecture.md`: substrate LOCKED (consumed F02 + F08 contracts; screen state machine idle/tracking/animating/won with no input queue; gesture→`Move` mapping envelope with **tie band → favor horizontal** as the Tech Lead resolution of the product's open diagonal-tie question; MOVES = `engine.moveCount` settled-only; Undo = 3-action F03 quota with no prompt at 0; Restart = reset + `restartCount++`, no dialog, away from grid; write-through persistence into the F08-frozen snapshot shape + hydrate via the F08 restore path; completion sequence with a minimal functional panel as an F04 seam; 150–250 ms animation, full input lock, no queue; portrait-locked route `'/play'`; `runtime`-mandatory QA; `Release Scope = none`); `[PENDING — UI]` and `[PENDING — IMPL tuning]` items enumerated in §18. Complexity: **not COMPLEX** (no Technical Analyst); **UI Designer required**; **no DevOps/Release Engineer** (`Release Scope = none`). Routing: **UI Designer (F03-UI → `ui-design.md`)** → Frontend/Mobile Developer (F03-FE1…FE8) → QA → Tech Lead (close). `feature-board.md` + `system-state.md` synced (Active Feature → F03; F08 → In Release / parked). Nothing committed to git.
