# F03 — puzzle-play-session: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In Progress — Frontend delivered 2026-09-06.** Contract (`architecture.md`) LOCKED-substrate + `ui-design.md` (Direction A) delivered. **Frontend/Mobile Developer delivered F03-FE1…FE8** (`frontend.md`): the playable screen — `app/lib/play/**` (16 files) + `app_router.dart` (go_router; `MaterialApp.router`) + `home_screen.dart`. Ticker-free `PlaySessionController` state machine (idle/tracking/animatingShift/animatingBounce/won, **no input queue**); pure `GestureResolver` (threshold + dominant axis + tie-band→horizontal + one-cell); wrap-shift animation (190 ms, edge-mask + ghost) + rejected-move bounce; `MOVES`=`engine.moveCount` settled-only; 3-action Undo (dead + no prompt at 0); separated outline Restart (`restartCount++`, no confirm); write-through into the F08-frozen `ActiveSessionSnapshot` + hydrate via the F08 restore path; bounded ≤600 ms win → amber fill + **drawn L→R seam bar** (colour + shape) → minimal functional completion sheet (Retry/Close; F04 seam); `paused` cancels the gesture / commits a mid-shift move synchronously. **295 workspace tests green** (app 99 = +27 F03: 13 `gesture_resolver` + 11 `controller` + 5 `screen` widget); `flutter analyze` + `dart format --set-exit-if-changed` clean; **`flutter build ios --release --no-codesign` GREEN** (`✓ Built Runner.app 54.5MB`). 2 flagged perf deviations from `ui-design.md` (board-recede blur → dim-only; breathing ambient omitted) + 6 non-blocking Tech Lead clarifications. **Next: QA** (F03-QA — `runtime`-mandatory client QA).

F03 is activated in parallel with **F08 parked** (`In Release`, deploy deferred by user decision to end-of-MVP). F08's engineering is complete and ready; F03 is the other branch of the `F06 → (F08, F03)` critical-path fork and needs no Firebase. See F08 `orchestration.md → Last Decision (DURUM 5.5)` for the parallelization rationale.

---

## Current Owner

QA

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
- [x] Task ID: F03-FE1 | Assigned Role: Frontend/Mobile Developer | Status: **Done (2026-09-06)** | `app_router.dart` (go_router `/` + `/play`, `MaterialApp.router`), `home_screen.dart` (debug chip row), `play_session_screen.dart`, `play_session_args.dart`, `debug_puzzle_library.dart` (5 F06 smoke puzzles as const maps — F05 replaces). Portrait lock kept in `main()`.
- [x] Task ID: F03-FE2 | Assigned Role: Frontend/Mobile Developer | Status: **Done (2026-09-06)** | `gesture_resolver.dart` — pure `resolve()` + `trackingAxis()`; threshold 18 px, tie-band 0.15 favor-horizontal, one-cell, first-pointer-only; values exposed for QA device tuning. 13 unit tests.
- [x] Task ID: F03-FE3 | Assigned Role: Frontend/Mobile Developer | Status: **Done (2026-09-06)** | `play_session_controller.dart` (`PlaySessionPhase` state machine, **no queue**) + `widgets/puzzle_board.dart` (190 ms wrap shift `cubic-bezier(0.22,1,0.36,1)` — edge-mask + N+2 ghost tiles; 140 ms rejected-move bounce; tracking lift + directional loop rails + 8% dim).
- [x] Task ID: F03-FE4 | Assigned Role: Frontend/Mobile Developer | Status: **Done (2026-09-06)** | `widgets/moves_hud.dart` (tabular, settle-tick), `widgets/undo_button.dart` (pips; dead + no dialog/ad at 0), `widgets/restart_button.dart` (outline, spin, no confirm, divider-separated).
- [x] Task ID: F03-FE5 | Assigned Role: Frontend/Mobile Developer | Status: **Done (2026-09-06)** | controller write-through `ActiveSessionRepo.save(_snapshot(...))` on every settled boundary + initial; F08-frozen keys; hydrate via `restoreSession()` on matching `puzzleId`; `completed` snapshot + `clear()` on win; `ElapsedTimer` pause/resume; no background work (F08 owns the drain). Persist failures caught (`persist_failed`).
- [x] Task ID: F03-FE6 | Assigned Role: Frontend/Mobile Developer | Status: **Done (2026-09-06)** | `_buildSeam`/`_buildBloom` in `puzzle_board.dart` + `widgets/completion_sheet.dart`; ≤600 ms `_win` choreography (amber fill + `ink-amber` + lift + drawn L→R seam bar + one bloom + 0.12 dim of other rows) → minimal sheet (kicker + word + `HAMLE` stat + dominant Retry + quiet Close). No rating logic.
- [x] Task ID: F03-FE7 | Assigned Role: Frontend/Mobile Developer | Status: **Done (2026-09-06)** | controller `onAppPaused`/`onAppResumed`; `paused` → cancel a `tracking` gesture / `_finishShift()` a mid-animation move synchronously (settled, never torn) / pause timer / persist; `resumed` → restart timer for an unfinished session.
- [x] Task ID: F03-FE8 | Assigned Role: Frontend/Mobile Developer | Status: **Done (2026-09-06)** | `play_strings.dart` (per-language `tr`/`en` table — no `gen_l10n`, assumption flagged); `ui-design.md` alignment pass; `flutter analyze` + `dart format --set-exit-if-changed` clean; `frontend.md` written with task-to-code traceability + test evidence.
- [ ] Task ID: F03-QA1…QAn | Assigned Role: QA | Status: **Open — NEXT (2026-09-06)** | End-to-end client QA per `architecture.md §16` — `runtime` (device/simulator) mandatory (0 double-registered moves during animation; gesture accuracy on a small + a large device; exactly-one-cell for flick vs drag; input-lock no-queue; background mid-animation; portrait lock; resume via F08 snapshot) + `automated functional` (gesture→Move mapping, counters, state machine, snapshot serialization) + `ui-design.md` alignment.

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
- [x] (F03-FE1…FE8) delivered 2026-09-06 (`frontend.md`). Screen + gesture mapping + state machine/animation + HUD/Undo/Restart + persistence + completion sequence + backgrounding + localization. 295 workspace tests green; iOS release build GREEN. 6 non-blocking Tech Lead clarifications + 2 flagged perf deviations.

### QA
- [ ] (F03-QA) end-to-end client QA — `runtime` (device/simulator) mandatory. **NEXT.**

---

## Blockers

* **None.** F02 (`Done`, contract locked) and the F08 on-device snapshot contract (`[LOCKED]`) are both available. F08's parked Firebase deploy is **not** a blocker — F03 uses only the on-device persistence layer + restore path, which are complete and functional.
* **Content:** F03 QA uses the F06 5-puzzle smoke set via the debug puzzle entry. The full 30-level set (`F06-CONTENT`) is a separate follow-on and is **not** required for F03 QA.
* **Not a blocker, noted:** real Journey/Daily entry (F05/F07), the real completion panel (F04), onboarding overlay (F09), audio/haptics (F11), analytics (F12) are all downstream and explicitly out of F03 scope.

---

## Last Decision

* 2026-09-06 — Frontend/Mobile Developer (**F03-FE1…FE8 delivered — the playable screen**):
  * **`frontend.md` written.** New: `app/lib/play/**` (16 files) + `app/lib/app_router.dart` (go_router — `MaterialApp.router`, `/` bootstrap gate + `/play`) + `app/lib/home_screen.dart` (placeholder + debug chip row). Modified: `app/lib/main.dart` (router + the F08 `_SessionLifecycle` observer relocated from wrapping `home:` to the router `builder:` — a **correctness improvement** now that routing exists: a session-level resource must not unmount on navigation, `platform.md §7`).
  * **Contract honoured verbatim** (`architecture.md §6/§7/§8/§9/§11/§13`): ticker-free `PlaySessionController` state machine (idle/tracking/animatingShift/animatingBounce/won) with **no input queue** (`beginDrag` ignored unless `idle`); pure `GestureResolver` (threshold 18 px, tie-band 0.15 → horizontal, one-cell, first-pointer); 190 ms wrap-shift (edge-mask + N+2 ghost tiles) + 140 ms rejected-move bounce; `MOVES = engine.moveCount` settled-only; 3-action Undo (dead control, no dialog/ad at 0); separated outline Restart (`restartCount++`, no confirm); write-through into the **F08-frozen** `ActiveSessionSnapshot` + hydrate via `restoreSession()`; `completed` snapshot + `clear()` on win; bounded ≤600 ms win → amber fill + **drawn L→R seam bar** (colour + shape) → minimal functional completion sheet (Retry dominant / Close quiet; no stars/best/Next — F04 seam); `paused` cancels a `tracking` gesture and commits a mid-shift move synchronously (never a torn snapshot).
  * **Authority reconciliation (2 deviations from `ui-design.md`, both flagged, non-blocking):** board-recede backdrop **blur → dim-only (0.12)** during `won` — mid-tier frame-rate budget (`prd.md §6`); the optional **breathing spotlight ambient omitted** — perf + deterministic tests. Visual intent preserved in both.
  * **Gates:** `flutter analyze` (app + 6 packages) clean; `dart format --output=none --set-exit-if-changed .` clean; **295 workspace tests** (app **99** = 4 pre-existing + 68 F08 + 27 new F03 — 13 `gesture_resolver` + 11 `controller` + 5 `screen` widget); `infra` offline 18/18 (unchanged); **`flutter build ios --release --no-codesign` GREEN** (`✓ Built Runner.app 54.5MB`).
  * **6 `Needs Tech Lead Clarification` (all non-blocking, defaults implemented):** the 4 from `ui-design.md §14` (no playing-screen CTA; F03 owns first-pass locked/frozen tile visuals; shared-chrome rule timing; final microcopy) + the 2 perf deviations above.
  * Current Owner → QA; Next Role → QA (F03-QA — end-to-end client, `runtime`-mandatory).
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

* Updated By: Frontend/Mobile Developer
* Timestamp: 2026-09-06
* Summary: **F03-FE1…FE8 delivered — `frontend.md`.** The playable screen: `app/lib/play/**` (16) + `app_router.dart` (go_router) + `home_screen.dart`; `main.dart` → `MaterialApp.router` + F08 `_SessionLifecycle` relocated to the router `builder:`. Ticker-free `PlaySessionController` state machine (no queue) + pure `GestureResolver` + 190 ms wrap-shift + bounce + `MOVES` settled-only + 3-action Undo (dead at 0) + separated Restart + F08 write-through/hydrate + bounded win → drawn seam bar → minimal completion sheet + `paused` handling. `flutter analyze` + `format:check` clean; **295 workspace tests** (app 99, +27 F03); iOS release build GREEN. 2 flagged perf deviations from `ui-design.md` (blur→dim, no breathing) + 6 non-blocking Tech Lead clarifications. `Current Owner → QA`; `Next Role → QA`. `feature-board.md` / `system-state.md` not touched (Tech Lead syncs).

---

## Next Role

QA

---

## Next Action

### QA — F03-QA (end-to-end client QA) — ⬅ NEXT

```text
Task: end-to-end QA of the F03 puzzle-play screen. CLIENT feature (no backend, no security surface).
Evidence class: `runtime` (device/simulator) is MANDATORY per architecture.md §16 — NOT source-only.
Plus `automated functional` (already delivered — 27 F03 tests) + `ui-design.md` alignment.

Authority: features/f03-puzzle-play-session/architecture.md (§6 state machine, §7 gesture mapping,
§8 MOVES/Undo/Restart, §9 persistence, §11 animation/input-lock, §12 backgrounding, §13 route/chrome,
§16 QA Focus), features/f03-puzzle-play-session/prd.md (AC1–AC11 + §6 constraints + §7 success metrics),
features/f03-puzzle-play-session/ui-design.md (§11 "must not be broken" list, §12 rubric),
features/f03-puzzle-play-session/frontend.md (§17 test evidence, §16 open clarifications, §18 runtime-only list).

Backend Build Gate (re-verify): `flutter analyze` + `dart analyze` (6 packages) + `dart format
--output=none --set-exit-if-changed .` + full `flutter test` (295 workspace) + `flutter build ios
--release --no-codesign`. (`infra` is unchanged this feature.)

RUNTIME scenarios (device or simulator — the F06 smoke set is reachable via the debug chip row on the
placeholder home: L1 quick win / L2 two-move / L4 column-enabled / L5 locked pivot / L6 frozen tile):
  1. AC1 — open: target word visible + visually SEPARATED from the grid; MOVES 0; Undo (3); Restart; grid ~85–90% width; portrait.
  2. AC2/AC3 — a horizontal swipe past threshold shifts exactly that row one cell + MOVES +1; a vertical swipe shifts that column (on L4/L5/L6); dominant-axis + threshold correct on a SMALL and a LARGE device.
  3. AC4 — a tap / tiny drag below threshold → no shift, MOVES unchanged. Measure, don't assume; sweep the threshold (GestureResolver.thresholdLogicalPx = 18) on the device matrix.
  4. AC5 + success metric "0 double-registered moves during animation" — swipe during the ~190 ms shift → ignored, NOT queued, no double-count. This is THE headline runtime check.
  5. AC11 — a transient target-word arrangement mid-animation does not win (only the settled state).
  6. one-cell for a fast flick vs a slow drag; a swipe starting on the grid but ending off-screen still resolves; multi-touch → first pointer only.
  7. AC6 — 3 undos then a 4th tap → nothing, NO dialog / ad / toast; the pip indicator reads 3→0.
  8. AC7 — Restart → grid reset, MOVES 0, undos back to 3, NO confirm dialog; Restart cannot be hit while swiping the board (placement + divider).
  9. AC8 — forming the target: input locks (diegetic — HUD dims, no spinner), winning row highlights with the amber fill AND the drawn L→R seam bar (confirm the seam is legible with colour off / greyscale — accessibility), bounded ≤~600 ms, then the minimal completion sheet (kicker + word + HAMLE stat + dominant Retry + quiet Close; NO stars/best/Next). Retry resets in place; Close pops to the caller.
  10. AC9 — swipe-begin: the affected row/column gets a light lift + loop-rail highlight (shape+motion, not colour-only).
  11. AC10 + architecture §12 — kill/relaunch mid-puzzle → grid, MOVES, undosRemaining, restartCount, elapsed exactly restored (via the F08 snapshot; thaw re-derived by replay — tamper `kv['active_session'].thawedFrozenCells` and confirm it is NOT trusted). Background mid-swipe → gesture cancelled cleanly. Background mid-animation → resolves to the settled end state on return; never a half-applied move.
  12. §13 chrome — no system header; the quiet back chevron pops to the caller on button / system / gesture back; it is HIDDEN in the won state (the sheet's Close owns exit); rotation attempt → stays portrait.
  13. Tile-state visuals (L5 locked = brass ring + pin glyph; L6 frozen = frost + crystal border; thaw cross-fade) — visual check; every special state has a NON-COLOUR cue.

`ui-design.md` alignment: Direction A intent intact (spotlight stage, backlit tiles, loop-rail + wrap
animation visible not a plain slide, outline-ghost target, diegetic lock, undo pips, separated outline
Restart, minimal-but-crafted sheet). Note the 2 accepted perf deviations (blur→dim, no breathing) —
frontend.md §11/§16; QA confirms they don't drop the screen below the premium bar / rubric fail conditions.

Not in scope: real Journey/Daily entry (F05/F07), F04 completion panel, F09 onboarding, F11 audio/haptics,
F12 analytics — all downstream. AC2/AC3 end-user offline Journey play flow needs F05 — out of F03 QA.

End: QA verdict → `Run Tech Lead` (fixed — QA always routes to Tech Lead). Tech Lead also resolves the
6 open clarifications (frontend.md §16) at close-out.
```

→ then `Run QA` → `Run Tech Lead` (F03 close; resolve the `frontend.md §16` clarifications).

---

## Change Log

* v3 (2026-09-06) — Frontend/Mobile Developer: **F03-FE1…FE8 delivered — `frontend.md`.** The playable screen implemented against `architecture.md` + `ui-design.md`. New: `app/lib/play/**` (16 files — `play_theme`/`play_strings`/`play_session_args`/`gesture_resolver`/`debug_puzzle_library`/`play_session_controller`/`play_session_providers`/`play_session_screen` + `widgets/{play_stage,target_rail,board_tile,puzzle_board,moves_hud,undo_button,restart_button,completion_sheet}`) + `app/lib/app_router.dart` (go_router; `MaterialApp.router`; `/` bootstrap gate + `/play`; `StoreErrorScreen`) + `app/lib/home_screen.dart` (placeholder + debug chip row). Modified `app/lib/main.dart` (`MaterialApp.router`; the F08 `_SessionLifecycle` sync-drain observer relocated from wrapping `home:` to the router `builder:` — a correctness fix now that routing exists, `platform.md §7`; dark theme from `PlayTheme.colorScheme`). **Contract honoured verbatim** (`architecture.md §6/§7/§8/§9/§11/§13`): ticker-free `PlaySessionController` state machine with **no input queue**; pure `GestureResolver` (threshold 18 px, tie-band 0.15 → horizontal, one cell, first pointer); 190 ms wrap-shift (`ClipRRect` edge-mask + N+2 ghost tiles, `cubic-bezier(0.22,1,0.36,1)`) + 140 ms rejected-move bounce; `MOVES = engine.moveCount` settled-only + settle-tick; 3-action Undo with a pip indicator, dead + **no dialog/ad/toast** at 0; Restart reset + `restartCount++`, no confirm, divider-separated outline treatment right of Undo; write-through into the **F08-frozen** `ActiveSessionSnapshot` on every settled boundary + initial + hydrate via `restoreSession()` on matching `puzzleId`, `completed` + `clear()` on win; bounded ≤600 ms win → amber fill + `ink-amber` letters + lift + a **drawn L→R amber seam bar** (colour AND shape — the non-colour cue) + one bloom + 0.12 dim of other rows → minimal functional completion sheet (kicker + word + `HAMLE` stat + dominant Retry + quiet Close; NO stars/optimal/best/Next — F04 seam); `paused` cancels a `tracking` gesture and commits a mid-shift move synchronously (never a torn snapshot). Portrait-locked; no confirm dialogs; no system header + a quiet back chevron hidden in `won`. Localization via `PlayStrings` (`tr`/`en` table — no `gen_l10n`; assumption flagged). **2 flagged non-blocking deviations from `ui-design.md`** (perf on mid-tier): board-recede blur → dim-only (0.12); the optional breathing spotlight ambient omitted. **Gates:** `flutter analyze` (app + 6 packages) + `dart format --output=none --set-exit-if-changed .` clean; **295 workspace tests green** (app **99** = 4 pre-existing + 68 F08 + **27 new F03**: `gesture_resolver_test` 13, `play_session_controller_test` 11, `play_session_screen_test` 5); `infra` offline 18/18 (unchanged); **`flutter build ios --release --no-codesign` GREEN** (`✓ Built build/ios/iphoneos/Runner.app 54.5MB`). **6 `Needs Tech Lead Clarification` (all non-blocking, defaults implemented):** `ui-design.md §14` ×4 (no playing-screen CTA; F03 owns first-pass locked/frozen tile visuals; shared-chrome rule timing; final microcopy) + the 2 perf deviations. Current Owner → QA; Next Role → QA (F03-QA — end-to-end client, `runtime`-mandatory). `feature-board.md` / `system-state.md` not touched (Tech Lead syncs). Nothing committed to git.
* v2 (2026-09-06) — UI Designer: **F03-UI delivered — `ui-design.md`.** Direction A ("Backlit board on a dark stage") selected over B ("warm tactile daylight board") per the doctrine's default-premium rule. Identity tied to the mechanic: spotlight stage + backlit-keycap tiles + a **loop-rail motif** + a **wrap animation** (edge-mask exit + opposite-edge emergence) + **outline-ghost target** (separated by scale + treatment + divider + air) + **won = amber fill + a drawn L→R seam bar** (colour AND shape → accessibility). Resolves the `architecture.md §18 [PENDING — UI]` list: 3-zone portrait layout (target/board/HUD) with fixed 28 pt gaps + board-first shrink; swipe-begin = row/col lift + directional rail ignite + 8 % dim (shape+motion cue); **diegetic input-lock** during the 190 ms shift (controls dim, board focuses — no spinner/modal); bounded ≤600 ms win sequence; shift envelope **170–210 ms** + `cubic-bezier(0.22,1,0.36,1)`; **minimal-but-crafted** completion sheet (kicker + amber word + one `HAMLE` stat + dominant Retry + quiet Close; no stars/best/Next — F04 replaces it); **"no system header + quiet back chevron top-left, hidden in `won`"** chrome (proposed as a cross-screen rule — Tech Lead to confirm); debug loading (stage + tile silhouettes, no spinner) + error (contained, dev-only). Colour tokens + 3 type roles + 4/8 spacing rhythm specified; locked = brass ring + pin glyph, frozen = frost texture + crystal border (non-colour cues). **Self-review 94/100** (target band), no rubric fail conditions. **Contract unchanged** — `architecture.md §6/§7/§8/§9/§11/§13` fully honoured. §14: 4 non-blocking Tech Lead clarifications (no playing-screen CTA; F03 owns first-pass locked/frozen tile visuals; shared-chrome rule timing; final microcopy). Current Owner → Frontend/Mobile Developer; Next Role → Frontend/Mobile Developer (F03-FE1…FE8). `feature-board.md` / `system-state.md` not touched (Tech Lead syncs). Nothing committed to git.
* v1 (2026-09-06) — Tech Lead: **F03 created + activated.** P0, the other branch of the `F06 → (F08, F03)` critical-path fork; depends only on F02 (`Done`); no Firebase. Activated in parallel with **F08 parked** (`In Release` — user deferred the Firebase Blaze upgrade / first deploy to end-of-MVP; F08's engineering is complete and ready). `prd.md` derived from `product-prd.md` F03 section (AC1–AC11 + perf/a11y/animation constraints). Initial `architecture.md`: substrate LOCKED (consumed F02 + F08 contracts; screen state machine idle/tracking/animating/won with no input queue; gesture→`Move` mapping envelope with **tie band → favor horizontal** as the Tech Lead resolution of the product's open diagonal-tie question; MOVES = `engine.moveCount` settled-only; Undo = 3-action F03 quota with no prompt at 0; Restart = reset + `restartCount++`, no dialog, away from grid; write-through persistence into the F08-frozen snapshot shape + hydrate via the F08 restore path; completion sequence with a minimal functional panel as an F04 seam; 150–250 ms animation, full input lock, no queue; portrait-locked route `'/play'`; `runtime`-mandatory QA; `Release Scope = none`); `[PENDING — UI]` and `[PENDING — IMPL tuning]` items enumerated in §18. Complexity: **not COMPLEX** (no Technical Analyst); **UI Designer required**; **no DevOps/Release Engineer** (`Release Scope = none`). Routing: **UI Designer (F03-UI → `ui-design.md`)** → Frontend/Mobile Developer (F03-FE1…FE8) → QA → Tech Lead (close). `feature-board.md` + `system-state.md` synced (Active Feature → F03; F08 → In Release / parked). Nothing committed to git.
