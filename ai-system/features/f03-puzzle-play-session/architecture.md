# F03 — puzzle-play-session: Architecture (Contract)

> Status: **INITIAL CONTRACT — substrate LOCKED; a few `[PENDING — UI]` / `[PENDING — IMPL tuning]` items resolve during the UI Designer + Frontend passes.**
> Contract authority for F03. Execution state is in `orchestration.md`.

---

## 1. Purpose

Define the play-session screen's interaction contract: how a swipe becomes an engine `Move`, how `MOVES` / Undo / Restart behave, how the screen persists and resumes via the F08 snapshot, the screen state machine (idle / tracking / animating / won), the completion sequence, the route / navigation contract, and the QA evidence bar. F03 writes no backend and owns no persistence storage — it consumes F02 (engine) and F08 (snapshot).

---

## 2. Authorities & Inputs

| Authority | Role |
| --- | --- |
| `product/product-prd.md` → F03 section + §Performans / §Kullanılabilirlik / §Animasyon kısıtı | product contract |
| `features/f03-puzzle-play-session/prd.md` | feature scope + AC1–AC11 |
| `features/f02-grid-engine/architecture.md` | **consumed contract** — `GridEngine` / `EngineConfig` / `Move` / `GridStep` / `GridState` |
| `features/f08-offline-persistence-and-sync/architecture.md` → "Active-Session Snapshot Contract [LOCKED — F03 designs to this]" | **consumed contract** — frozen snapshot keys, restore path, `ActiveSessionRepo`, `toEngineConfig`, `ElapsedTimer` |
| `project-authority/platform.md` | Flutter/Dart, Riverpod, `go_router`, one-handed portrait |
| `design/design-doctrine.md` + `design/premium-ui-rubric.md` | UI quality bar (UI Designer pass) |
| `project-authority/release.md` | `Release Scope` decision |

---

## 3. Actors & Permissions

* **Single actor: the player.** No auth, no roles. Guest identity (F08 `guestId`) is already established; F03 does not touch it.
* The screen is **portrait-locked** at all times (rotation attempts are ignored — no landscape layout exists).

---

## 4. Entry / Exit Paths [LOCKED]

### Allowed entry paths

| From | Trigger | Args |
| --- | --- | --- |
| F05 Journey (later) | tap an unlocked level | `PlaySessionArgs(source: journey, journeyLevel: N)` |
| F05 / F10 CONTINUE (later) | resume the in-progress level | same args; the screen hydrates from the F08 snapshot |
| F07 Daily (later) | open today's Daily | `PlaySessionArgs(source: daily)` |
| F09 tutorial (later) | tutorial completes → Level 1 | `PlaySessionArgs(source: journey, journeyLevel: 1)` |
| Dev / test harness (now) | direct route with an explicit `Puzzle` | a debug entry that injects a `Puzzle` (used for F03 QA against the F06 smoke set until F05 exists) |

* F03 ships with a **debug/local puzzle entry** so the screen is playable and QA-able before F05/F07 exist. This is behind a debug affordance on the placeholder home; it is **not** a shipping navigation path.
* Route name: `'/play'`. Only the paths above are allowed; there is no deep-link / arbitrary entry.

### Exit / completion paths

* **Win:** target word forms on a settled move → input locks → win highlight → success animation → completion panel → the panel's actions: **Retry** (`engine.restart()` in place) or **Close** (pop to the caller / menu). **[Amended 2026-09-28, §20]:** the panel becomes a full-screen result; its exits are Next, Retry, the back button and system back — no Close. On entering the completion panel, F03 writes a `status: completed` snapshot then calls `ActiveSessionRepo.clearActiveSession()` — a subsequent entry to the same puzzle starts fresh.
* **Back / leave mid-puzzle:** pop to the caller. The active-session snapshot is **kept** with `status: inProgress` so CONTINUE (F05/F10) and cold-relaunch resume work. No confirmation dialog.
* **App backgrounded:** F08's session-level lifecycle owns the `paused` flush + drain; F03 guarantees the snapshot it has written always reflects a **settled** state.

### Invalid / rejected paths

* A `Move` the engine rejects → `GridStep.applied == false` → no animation, `MOVES` unchanged, no visible error.
* Undo at quota 0 or with no history → no-op, no prompt, no ad.
* Any input while `state == animating` or `state == won` → dropped (not queued).

---

## 5. Consumed Contracts [LOCKED — do not re-implement]

### F02 engine

* `EngineConfig` is built from a `Puzzle` via **`toEngineConfig(Puzzle)`** (F08-FE11, in `app/lib/content/puzzle_engine_config.dart`).
* `GridEngine(config, validator: WordValidator)` — the stateful façade. F03 holds exactly one per session.
* `engine.applyMove(Move)` → `GridStep { applied, rejectedReason?, state, thawedThisStep, solvedThisStep }`. Appends to history **iff** applied.
* `engine.undo()` — removes the last applied move, re-folds from t=0. `engine.restart()` — clears history, state = initial.
* `engine.moveCount` — **this is `MOVES`**. `engine.appliedMoves` — the ordered applied-`Move` list (→ F06 shorthand for the snapshot). `engine.state.thawedCells` — current thawed set (cache for the snapshot; re-derived on restore).
* The engine is **pure and synchronous**. It does **not** animate, time, or count undos-remaining / restarts — those are F03's.

### F08 snapshot

* Storage: `ActiveSessionRepo` (`save` / `read` / `clearActiveSession`). F03 never touches Drift or `kv` directly.
* Snapshot shape is the **frozen key set** in F08's architecture — F03 serializes into exactly that (`snapshotVersion`, `puzzleId`, `puzzleSource`, `lang`, `appliedMoves`, `moveCount`, `undosRemaining` 0..3, `restartCount`, `elapsedMsAccumulated`, `thawedFrozenCells`, `status`, `startedAtUtcMs`, `lastPersistedAtUtcMs`).
* **Restore is F08's path**: `ActiveSessionRepo.read()` → resolve `puzzleId` → `toEngineConfig` → `GridEngine` → `restoreMoves(appliedMoves)` → restore counters + `ElapsedTimer.resumed(elapsedMsAccumulated)`. F03 calls into that; it does not re-derive thaw itself.
* **Elapsed** uses F08's `ElapsedTimer` (monotonic `Stopwatch`; no wall clock). F03 pauses it on `paused` / win, resumes on `resumed`.
* **Corrupt snapshot** → F08 discards the active snapshot only and F03 starts the puzzle fresh (durable tables are untouched).

---

## 6. Screen State Model [LOCKED]

```
        ┌─────────────────────────────────────────────┐
        ▼                                             │
     [idle] ──touch-down on a cell──▶ [tracking] ──release──▶ resolve gesture
        ▲                                 │                        │
        │                          release below threshold        │
        │                          / off a cell → [idle]     applied move?
        │                                                     │        │
        │                                                   yes│      no│→ [idle] (MOVES unchanged)
        │                                                     ▼
        │                                               [animating] ──settle──▶ solvedThisStep?
        │                                                                        │       │
        └───────────────────────────────────────────── no ◀──────────────────────┘   yes │
                                                                                          ▼
                                                                                       [won]
                                                                            (input locked; success
                                                                             anim → completion panel)
```

* **No input queue.** Touch events while `tracking` is not active-for-this-pointer, or while `animating` / `won`, are dropped.
* `tracking` follows only the **first** pointer; additional pointers are ignored until it resolves.
* `animating` duration is the shift animation (150–250 ms). Input lock spans the entire `animating` state.
* `won` is terminal for the session; only the completion panel's actions leave it.

---

## 7. Gesture → Move Mapping [LOCKED envelope; `[PENDING — IMPL tuning]` for the exact numbers]

Given a pointer-down at grid cell `(row r, col c)` and a pointer-up at screen delta `(dx, dy)`:

1. **Threshold:** if `max(|dx|, |dy|) < T` → no-op (no `Move`, `MOVES` unchanged). `T` is `[PENDING — IMPL tuning]`, envelope: large enough that an accidental tap/micro-drag never registers (product §Kullanılabilirlik), small enough that a deliberate short swipe works one-handed. Expressed in logical pixels, scaled by `devicePixelRatio` as needed; tuned on the device matrix in QA.
2. **Dominant axis:** if `|dx| >= |dy|` → horizontal; else vertical. **Tie band:** when `abs(|dx| - |dy|)` is within a small band `B` (`[PENDING — IMPL tuning]`, ~ a few degrees off the diagonal), **favor horizontal** (Tech Lead decision — resolves product-prd §"Diagonal-swipe tie handling" and the F03 edge case; a fixed rule, never a per-frame guess).
3. **Move construction:**
   * horizontal, `dx > 0` → `Move.rowRight(r)`; `dx < 0` → `Move.rowLeft(r)`.
   * vertical, `dy > 0` → `Move.columnDown(c)`; `dy < 0` → `Move.columnUp(c)` (screen y grows downward; "down" = visually downward).
4. **One cell only.** The `Move` always shifts exactly one cell regardless of `|dx|`, `|dy|`, or flick velocity. Distance/velocity are **not** mapped to a multi-cell shift.
5. **Off-screen release:** use the last known pointer position; still resolves on `up`/`cancel`.
6. Submit the `Move` to `engine.applyMove`. If `applied` → enter `animating` and play the shift; else stay `idle`.

Coordinate orientation follows F02 (`GridCoord`, row/col conventions, L→R win row).

---

## 8. MOVES / Undo / Restart [LOCKED]

* **MOVES** = `engine.moveCount`, shown live. Only **settled applied** moves count. A rejected move does not increment. During `animating` the counter may update on settle (not on gesture release) — QA verifies no double-count.
* **Undo:** F03 owns an `undosRemaining` counter, initial **3** per attempt (an *action* count, not a history depth — product §"3 Undos"). Undo tap while `> 0` and `state == idle` → `engine.undo()` + `undosRemaining--` + write-through snapshot. At `0` → no-op, **no purchase/ad prompt** (AC6). Undo while `animating` / `won` → disallowed. Undo with empty history → no-op (defensive; quota should prevent it).
* **Restart:** `engine.restart()` + `MOVES → 0` + `undosRemaining → 3` + `restartCount++` + write-through snapshot. **No confirmation dialog** (AC7). The Restart control is placed **away from the grid** so it can't be hit while swiping (`[PENDING — UI]` exact placement). Restart while `animating` → the animation resolves to a settled state first, then restart applies; Restart is inert during `won` except via the completion panel's Retry.

---

## 9. Persistence Integration [LOCKED]

* **Write-through:** after every settled `applyMove`, `undo`, and `restart`, F03 builds the snapshot and calls `ActiveSessionRepo.save(snapshot)`. The snapshot always reflects the **settled** engine state (never mid-animation).
  * `appliedMoves` = `engine.appliedMoves` mapped to F06 shorthand (`R<i>`/`L<i>`/`D<i>`/`U<i>`) via `app/lib/engine/move_shorthand.dart`.
  * `moveCount` = `engine.moveCount` (== `appliedMoves.length`).
  * `thawedFrozenCells` = `engine.state.thawedCells` as `"r,c"` strings — **cache only**.
  * `elapsedMsAccumulated` = the `ElapsedTimer` accumulated ms.
  * `status` = `inProgress` until win; `completed` when the completion panel opens.
* **On open:** `ActiveSessionRepo.read()`; if a snapshot exists **and** its `puzzleId` matches the requested puzzle → hydrate through the F08 restore path (engine replay re-derives thaw). Otherwise start fresh and immediately write an initial `inProgress` snapshot.
* **On win:** write a `completed` snapshot, open the completion panel, then `ActiveSessionRepo.clearActiveSession()`. (Clearing on panel-open, not on panel-dismiss, so a crash during the panel doesn't resurrect a finished puzzle.)
* **On `paused`:** F08's session-level lifecycle does the flush + snapshot barrier + drain. F03 pauses the `ElapsedTimer`. F03 must not itself schedule background work.
* **On `resumed`:** F03 resumes the `ElapsedTimer`; if the screen was rebuilt, it hydrates from the snapshot (same restore path).

---

## 10. Completion Sequence [LOCKED behavior; `[PENDING — UI]` choreography]

1. `GridStep.solvedThisStep == true` on a settled move → `state → won`, input locked, `ElapsedTimer` paused.
2. Highlight the winning row (left-to-right). **Non-color cue required** as well as color (accessibility — product §"no information by color alone").
3. A **short** success animation — functional, not cosmetic polish; bounded (~≤ 600 ms) so it never feels like a wait. Exact choreography is `[PENDING — UI]`.
4. Open the completion panel.
   * **F04 owns the real panel** (target word, player moves, optimal, stars, "Perfect", personal best, Retry, Next Level).
   * **F03 ships a minimal functional panel** as a seam: target word, player move count, **Retry** (`engine.restart()` in place, back to `idle`), **Close** (pop to caller). No stars, no best, no "Next". F04 replaces this panel; F03's version must not encode any rating logic.
   * **[Amended 2026-09-28, §20]:** the step becomes the board → full-screen result transition (timeline §20.3 (1)); no Close.
5. On panel open: `status: completed` snapshot → `clearActiveSession()`.

---

## 11. Animation & Input-Lock Contract [LOCKED]

* Shift animation: **150–250 ms**, smooth on mid-tier devices. Exact duration + curve `[PENDING — UI]` within that band.
* Input is **locked for the entire `animating` state**. Gestures during animation are **dropped, never queued** (AC5, product §Animasyon kısıtı).
* Gesture-release → animation-start latency: target **< 50 ms** (no awاiting async work on that path; the engine call is synchronous).
* Rapid repeated valid swipes on one row → each counts, but only after the previous animation **settles** (they can't overlap because input is locked).
* A transiently-valid target word **during** an animation does not win — win is evaluated on the **settled** `GridState` only (AC11; mirrors F02's "win/thaw evaluated only on the settled state").

---

## 12. Backgrounding & Interruption [LOCKED]

* App backgrounded mid-swipe → the in-progress gesture is cancelled cleanly (no `Move` submitted); `state → idle`.
* App backgrounded mid-animation → on return, the animation **resolves deterministically to its settled end state** (the move was already applied to the engine at animation start; the visual just completes). Never a half-applied move, never a lost move.
* OS kill at any point → the last write-through snapshot (always settled) is the resume point (AC10).
* Device clock changes → no effect (elapsed is monotonic via `ElapsedTimer`).

---

## 13. Route / Navigation Contract [LOCKED]

* Route: `'/play'` (go_router). Args: `PlaySessionArgs { PuzzleSource source; int? journeyLevel; /* daily needs no extra arg */ }` where `PuzzleSource` reuses F08's `{ journey, daily }`.
* **Portrait-locked** for the whole screen lifetime.
* Header / chrome: a minimal back affordance that pops to the caller; no mandated title bar. Exact chrome is `[PENDING — UI]` and must follow `design-doctrine.md`. If a shared header standard emerges across screens later, this section is amended. **[Amended 2026-09-27, §19]:** the back affordance becomes the drawn back chevron with the `SEVİYE NN` level label, plus the `HAMLE` card top-right; the behaviour is unchanged.
* Back mid-puzzle keeps the resumable `inProgress` snapshot (§9). Back is confirm-less.
* No forward navigation from F03 except the completion panel's Close/Retry and (later) F04's "Next Level". **[Amended 2026-09-28, §20.3 (7)]:** the result's exits are Next, Retry, the back button and system back.

---

## 14. Localization [LOCKED]

* `MOVES` label and every user-facing string (completion panel text, any hint text) are externalized through the app's localization layer (same pattern as F01). No hard-coded display strings.
* Turkish is primary; the layout must tolerate longer strings without clipping the grid.

---

## 15. Validation Responsibility [LOCKED]

* **F03:** the 3-undo quota; not sending moves during animation; not sending out-of-range indices; gesture threshold + dominant-axis + tie-band rules; the screen state machine; snapshot serialization into the F08-frozen shape; portrait lock.
* **F02 engine:** move legality, shift/undo/restart/win/thaw semantics, `EngineConfig` structural validation.
* **F08:** snapshot storage, corrupt-snapshot recovery, restore-path thaw re-derivation, elapsed timing.
* **F01 (via `WordValidator`):** word validity + normalization.

---

## 16. QA Focus [LOCKED]

* **Evidence class:** `runtime` (device/simulator) is **mandatory** — not `source-only`. Product §Success Metrics require "0 double-registered moves during animation in QA" and "gesture recognition ≥ target accuracy on the device matrix"; both are runtime claims. Plus `automated functional` for the pure gesture→`Move` mapping, the MOVES/undo/restart counter logic, the screen state machine, and snapshot serialization.
* **Critical runtime journeys:** open → render (AC1); horizontal swipe → row shift + `MOVES` +1 (AC2); vertical swipe → column shift +1 (AC3); sub-threshold swipe → nothing (AC4); swipe during animation → dropped, not queued, **no double count** (AC5); 3 undos then a 4th → no-op, no prompt (AC6); Restart → reset, no dialog (AC7); win → lock + highlight + success anim + panel (AC8); swipe-begin highlight (AC9); leave + return (back / background / OS kill) → exact resume (AC10); transient valid word mid-animation → no win (AC11).
* **Misuse / edge matrix:** diagonal tie → horizontal; off-screen release; multi-touch → first only; rapid same-row swipes → each counts post-settle; fast flick vs slow drag → exactly one cell; rotation → stays portrait; undo during success anim → disallowed; engine-rejected move → silent no-op; Restart during animation.
* **Device matrix:** at least one small + one large logical-width device; threshold + dominant-axis accuracy measured, not asserted from source.
* **Persistence:** resume fidelity via the F08 snapshot (grid, `MOVES`, `undosRemaining`, `restartCount`, elapsed); tampered `thawedFrozenCells` → re-derived (shared with F08's QA focus).
* **UI Designer alignment:** if `ui-design.md` is produced, QA also checks the implementation matches it — CTA/affordance placement (Restart away from the grid), win-highlight non-color cue, state visibility (idle / tracking highlight / animating lock / won), and the `premium-ui-rubric.md` fail conditions.

---

## 17. Release / Deployment Impact [LOCKED]

* **`Release Scope` = `none`.** F03 is a client-only screen: no Cloud Functions, no Firestore rules, no Remote Config, no content pack, no new distributable surface beyond the app build. Per `release.md` §2 conditional rule, no release gate. CI gates (`format:check` / `analyze` / `test` / `build:app` / `build ios`) still run.
* The first **app-build distribution** gate (TestFlight / Play internal) is still expected around F05, when there is a full playable Journey to dogfood. F03 does not trigger it.

---

## 18. Open Items

### Clarifications resolved 2026-09-06 (Tech Lead, post-QA)

* **No primary CTA on the playing screen — `[LOCKED]`.** The board *is* the interaction; the only CTA is `Retry` in the completion sheet. QA must not flag the absence of a floating play/submit button as a defect. (Confirms `ui-design.md §14` #1 + this doc §8.)
* **Locked / frozen tile *visual* treatment — F03 owns the first pass.** F02 owns the behaviour; F05/F06 author *which* tiles are locked/frozen. The `brass` ring + pin glyph (locked) and `frost` fill + crystal border + thaw cross-fade (frozen) shipped by F03-FE are the accepted first-pass visuals; there is **no separate tile-state visual feature** — a later polish revision, if wanted, is a scoped follow-on, not a blocker. (Confirms `ui-design.md §14` #2.) **[Superseded 2026-09-27 by §19.3 (3–4)]:** the Foundation treatments replace these visuals. Correction: the thaw cross-fade is *not* in the code at `615e94c` — `puzzle_board.dart` renders `BoardTile(status)` with no transition, and `BoardTile` is a plain `Container`. D1 implements it.
* **Shared in-flow chrome ("no system header, one quiet back chevron top-left, hidden in terminal/`won` states") — locked for `/play`; cross-screen family rule deferred to F10.** F03 is the first in-flow screen, so there is no sibling to converge on yet; F10 (menu + settings) defines the shared chrome family and reconciles siblings then. (Confirms `ui-design.md §14` #3.)
* **Localization — `PlayStrings` per-language table accepted as the seam for F03.** A proper `gen_l10n` / `.arb` localization layer is a `[DEFERRED — F10-or-earlier follow-on]` (not F03); the final Turkish strings (`HEDEF / HAMLE / ÇÖZÜLDÜ / Yeniden / Kapat / Geri`) are a PO / localization deliverable, tracked with that task. Contract requirement ("externalized") is satisfied. (Confirms `ui-design.md §14` #4.)
* **Perf deviations from `ui-design.md` — accepted for the MVP.** (1) Board-recede during `won` is a **12 % dim only**, not dim + backdrop blur — preserves the "board recedes, winning row + sheet own focus" intent within the mid-tier frame-rate budget (`prd.md §6`); a device-tier-gated blur is a `[DEFERRED — post-MVP polish]`. (2) The optional breathing spotlight ambient is **omitted** — `ui-design.md §5/§11` marks it optional/flexible. Neither trips a `premium-ui-rubric.md` fail condition. (Resolves `frontend.md §16` #5–6.)

### Won-sequence authority — resolved 2026-09-20 (Tech Lead, post-QA F03-QA-01 / F03-QA-02) `[LOCKED]`

QA (qa.md, rev 7a907dd) reproduced that the F04 completion panel rises with no delay (`AnimatedSlide` 320 ms as soon as `phase == won`) while the board's 600 ms win animation runs underneath, so the stagger / drawn seam bar / bloom are effectively hidden, the winning row is covered for rows 2–4, and the Perfect variant clips even row 0. Resolution:

* **Sequencing (authority already unanimous; implementation defect).** §10, F03 `ui-design.md` (won) and F04 `ui-design.md` (§4 timeline) all say: win sequence first (≤ 600 ms), *then* the panel. Contract: `T0` = the settle that yields `solvedThisStep`. The board win sequence runs `T0 … T0 + PlayTheme.winDuration (600 ms)`. The scrim and panel slide start **no earlier than `T0 + 600 ms`** and take ≈ 260 ms (F04 `ui-design.md`); F04's star reveal starts after the panel is up. Under OS "reduce motion" the amber fill + seam render static immediately and the panel follows after a ≥ 300 ms hold. During `T0 … panel-at-rest`: input stays locked, chevron stays hidden, the state is `won`.
* **Persistence / controller semantics unchanged.** `completed` snapshot + `clearActiveSession()`, F04's `personal_best` write, F05's `_resolveJourneyUnlock` and `controller.completion` remain triggered at `won` (§9/§10). Only *presentation* timing changes. The panel must not wait on a slow rating read longer than today (`ratingUnavailable` path unchanged).
* **Geometry (needs a design answer).** F04 `ui-design.md` §5 ("~34–42 % strip above a 56–66 % panel keeps the winning row visible") cannot hold for winning rows 1–4 on a 5×5 board (measured on iPhone 16: row centres at 36 / 44 / 52 / 60 / 68 % of screen height; panel top at ≈ 42 % non-Perfect, ≈ 38 % Perfect). Requirement: **at rest, the winning row and the docked seam bar remain visible above the panel for winning rows 0–4, for every F04 variant (first-clear, matched, newBest, Perfect), on widths 390–440 pt and heights 844–956 pt**, with all F04 panel content unclipped and tappable (≥ 44 pt). The UI Designer delivers this as a `Won composition` section in F03 `ui-design.md`; where it conflicts with the F04 `ui-design.md` §5 numbers, **the F03 `Won composition` section wins** (F03 owns the `won` treatment; F04 owns the panel's content and product ACs, which are unchanged). If no geometry meets the requirement on the smallest device, the UI Designer states the fallback (panel may cover the row *after* the full ≥ 600 ms sequence) and raises `Needs Tech Lead Clarification`; the Tech Lead then decides whether the F04 line is withdrawn.
* **Constraints carried:** the 12 % dim-only recede (no backdrop blur) and the mid-tier frame-rate budget from the 2026-09-06 perf clarification stay in force.
* **F04 status:** stays `Done` (its ACs and star/best logic are not changed). F03 re-QA must cover every panel variant; F04 tests may need timing/geometry updates and must stay green.
* **Exit evidence (F03-FE-WON):** widget/golden assertions that the panel is not visible before `T0 + 600 ms` and that the winning-row rect is not intersected by the panel rect at rest, for rows 0–4 × {Perfect, non-Perfect} × {390×844, 440×956}; then QA runtime frame capture on real rows reachable in the bundle.
* **F03-QA-02:** the `integration_test/` device form must complete (exit 0) on a live simulator, group 4 included; a CI `continue-on-error` step is not evidence of a pass.

### Still open

* **`[RUNTIME VALIDATION PENDING — F03-FE9]`** (Frontend/Mobile Developer, then QA): `architecture.md §16` mandates `runtime` / `repeatable integration` evidence that the QA environment could not produce. Closure = an `integration_test/` suite (CI-runnable — `release.md §4` lists `integration_test` as a best-effort gate "not auto-blocking until F03 lands") covering `qa.md §17` scenarios 1–4 (gesture accuracy + threshold sweep on ≥2 surface sizes; 0 double-registered moves during the real ~190 ms window; kill/relaunch resume + tampered-`thawedFrozenCells` re-derivation; background mid-swipe / mid-animation), plus a short manual device/simulator confirmation of the visual items (`qa.md §17` 5–7: win-choreography readability, locked/frozen tile visuals, portrait lock on rotation, chevron/back). 2026-09-20 update: QA ran groups 1–3 green (10/10) on a live iPhone 16 simulator; group 4 (`paused mid-drag …`) never completed — closure now also requires group 4 to exit 0 (F03-FE-INTEG). Then re-QA → close.
* `[PENDING — IMPL tuning]` (Frontend + QA on device): the gesture threshold `T` (18 logical px shipped) and the diagonal tie band `B` (ratio 0.15 shipped) — final values validated / adjusted on the device matrix via F03-FE9.
* `[DEFERRED — F04]` the real completion panel (stars / optimal / best / Perfect / Retry / Next Level) replaces F03's minimal panel.
* `[DEFERRED — F05]` real Journey entry + CONTINUE target resolution replace F03's debug puzzle entry.
* `[DEFERRED — F09]` onboarding overlay / arrow prompts layered on this screen.
* `[DEFERRED — F11]` SFX + haptics on move / thaw / win / button.
* `[DEFERRED — F12]` analytics events derived from F03's state changes.

---

## 19. Design Adoption Phase D1 — Loop Glass Play visual rework [LOCKED 2026-09-27]

> **Added by:** the Tech Lead on 2026-09-27, when reconciling the Phase C conformance audit (`features/f00-design-foundation/conformance-audit.md`, accepted). It reopens F03 as visual rework under rework control.
>
> **Authority:**
> * `project-authority/design-foundation.md` — Selected: Direction C "Loop Glass", the user's decisions in §18.
> * `features/f00-design-foundation/ui-design.md` — §6 Play layout, §7 components, §8 states, §10 visual direction, §13 accessibility.
> * The selected-source renders `design/S-01b`, `S-02`, `S-03` and `S-07` (F00), plus the device variants `S-v-*` and the component sheet `S-91`.
> * The audit: §4 Play, §5 tutorial, §10 missing renders 1–10, and the defects A-1, A-2, A-5 and A-6.
>
> The Tech Lead rulings of 2026-09-21 also apply: the `HAMLE` caption ≥ 11 pt, and targets ≥ 44 pt.

### 19.1 User-visible symptom

The app still shows the pre-Foundation look (incident 2026-09-26). Play — the screen where players spend their time — runs on `PlayTheme` (near-black stage, amber, cyan), the system font and Material icons. Four shipped defects sit on this surface:
* **A-1:** the column-tutorial hint is drawn over the undo pill and the restart button (`Positioned(bottom: 40)` in `column_tutorial_overlay.dart`).
* **A-2:** at the largest OS text size, the tile and rail letters overflow their tiles.
* **A-5:** the frozen tile carries colour + border only, and it thaws with no transition.
* **A-6:** the tutorial ghost keeps animating over the column the player is dragging.

### 19.2 Scope

* **Affected journey:**
  * **Enter:** Home CONTINUE, Result Next / Retry, or resume after a kill.
  * **Play:** idle, row / column drag, locked / frozen / thaw, undo / restart.
  * **Leave:** back to Home.

  Entry paths (§4), route (§13) and state model (§6) are unchanged. The won moment and result are **D2**, not D1.
* **Surfaces and states** — `/play` in every non-`won` state:
  * the header: back chevron + level label, and the `HAMLE` card;
  * the target rail;
  * the board card and tiles: normal; active, for row and column drags; inactive; wrap ghost; locked; frozen; thaw;
  * the HUD: undo pill — enabled, disabled, quota 3 / 2 / 1 / 0 — and restart;
  * the load-error state (`_LoadErrorBody`);
  * the F05 column-tutorial overlay (§19.5).
* **Visual Scope `existing-parity`:** the Foundation is Selected, and S-01b / S-02 / S-03 / S-07 are its selected-source renders of this screen. The missing sub-states extend them; there is no new direction.

### 19.3 Decisions (Tech Lead, from the audit's clarifications)

1. **Text scale (C-9).** This applies to every Phase D surface (D1–D3). For the surfaces it reworks, it supersedes the "1.0 and 1.3×" scope of F03 ui-design §16.5 (6).
   * **Free text** — the hint, labels outside a container, body text — follows the OS text scale up to `accessibility-extra-extra-extra-large` (AX5) with no clipping, overlap or mid-word break. The layout may reflow; for example, the hint pill may grow.
   * **Text bound to a fixed-size container** — tile, rail and answer glyphs, card numerals and captions, pill labels, the wordmark, and the display / headline roles — uses `loopCappedTextScaler` (1.3× cap, `app/lib/design/tokens.dart`) and is sized by its container.
   * Play never scrolls, and the board geometry does not change with text scale.
   * **Applied to Play (ruling at the D1 checkpoint, 2026-09-27; `ui-design.md` §14.1):** on Play every text role sits in fixed chrome or a container, so every Play text role uses the 1.3× cap. This covers the header label, `HEDEF DÖNGÜ`, the `HAMLE` card, the rail and tile glyphs, and the tutorial hint pill.
     * This supersedes the "hint = free text" example above.
     * VoiceOver carries the full text.
     * Free text up to AX5 applies where the layout can reflow or scroll — on D1, the load-error screen.
2. **Tutorial HUD (C-5):**
   * The hint pill sits **above** the HUD; undo and restart stay visible and usable while the tutorial is up, because the player may make row moves before the column move.
   * The gesture ghost hides on touch-down and returns once the board is idle.
   * Under Reduce Motion the ghost is static.
3. **Thaw (C-10):** a 180 ms cross-fade from the frozen treatment to the normal tile, instant under Reduce Motion (F03 ui-design §7, never implemented).
4. **Special tiles** (supersedes the §18 first-pass visuals), per the Foundation's `ui-design.md` §8:
   * **Locked:** indigo tile + inner rim + lock icon.
   * **Frozen:** ice tile + dashed border + snowflake icon.

   Both must stay readable in greyscale.
5. **Copy (user decision 6 — the reference wording as proposed copy):**
   * `HEDEF` → `HEDEF DÖNGÜ`.
   * The level label `SEVİYE NN` has two digits and is bound to the level number; the `05` in S-03 / S-07 is placeholder copy.
   * Both ship through `PlayStrings` as interim copy. PO / localization may revise them there (F10-UI-LOCALIZATION).
   * The tutorial sentence is unchanged.
6. **Hybrid period (C-8) is accepted.** Home, the won moment and the result keep the legacy look until D2 / D3. There is no global font or colour swap outside the reworked surface.

### 19.4 Contract amendments

* **§13 chrome:** as amended in place — back chevron + `SEVİYE NN`, and the `HAMLE` card. Back still pops to the caller, keeps the snapshot, needs no confirmation and hides in `won`.
* **§8 Restart "away from the grid":** still holds; the HUD sits below the board (S-01b).
* **§14:** every new string goes through `PlayStrings`.
* **§18 (2026-09-06) tile visuals:** superseded by §19.3 (3–4).
* **F03 `ui-design.md`:** the Direction A visual sections (§2, §5–§11) are superseded for the Play surface by the D1 handoff. §16 (won composition) stays authoritative until D2.
* **ACs unchanged:** AC1 (moves, Undo 3 and Restart shown) and AC7 hold; AC9 is met by the active-row rim + rails.

### 19.5 Cross-feature item — the F05 column tutorial

* The overlay (`app/lib/journey/column_tutorial_overlay.dart`) is re-skinned in this reopen per S-07 and §19.3 (2).
* F05 behaviour is unchanged: the trigger, the action-gated dismissal and the ack / re-show (F05 §9, AC4, AC11).
* F05 stays Done. Precedent: the 2026-09-20 F03 rework changed F04 panel code while F04 stayed Done.
* F05 `architecture.md` §9 records that its visual authority has moved here.

### 19.6 Non-goals

* **Won moment and result (D2):** F03 §16 and the F04 panel keep their look and timing. *[Amended 2026-09-28, §19.9 (1)]:* the dock position moves onto the goal rail, because the D1 header left no §16.3 zone; look, timing and every other §16 rule are unchanged.
* **Home, app shell, F08 error screen (D3).**
* **No behaviour change:** no engine, gesture-threshold, input-lock, persistence, snapshot, route or timing change. The shift already matches the Foundation (190 ms, `cubic-bezier(.22,1,.36,1)`).
* **No future-scope content:** the gesture-hint line "Satırı tut · kaydır · bırak" (F09), settings, the streak and the stars.
* **No new dependency:** the fonts are bundled and the icons are drawn in `app/lib/design`.

### 19.7 Evidence and exit criteria

* **UI Designer (F03-UI-D1)** — the Loop Glass Play handoff in F03 `ui-design.md`, per the handoff gate in `visual-quality-gate.md`:
  * **Layout:** per F00 ui-design §6, at 393 pt and on the 16e / Pro Max variants.
  * **Decisions:** components, states and interaction.
  * **Motion spec:** lift, rim fade-in, settle, inactive dim, thaw and the ghost, each with its reduced path.
  * **Screen / State / Viewport matrix.**
  * **Visual Evidence Manifest:** `selected-source` records for S-01b, S-02, S-03 and S-07, plus new real renders for the audit's D1 missing states 1–10 — including the AX5 Play frame and the tutorial per §19.3 (2).
  * **A D1 acceptance list.**
  * **Gate:** Visual Quality Gate → Ready for Implementation at the Tech Lead checkpoint.
* **Frontend/Mobile Developer (F03-FE-D1)** — implement from `app/lib/design` tokens and components:
  * Replace the Material icons on this surface with drawn ones — `chevron_left_rounded`, `undo_rounded`, `refresh_rounded`, `push_pin`, `error_outline_rounded`, and the tutorial's `unfold_more_rounded`.
  * Drop `PlayTheme` from the reworked widgets; it stays for the won moment until D2.
  * Update tests (string / icon lookups); all green.
  * **`frontend.md` Visual Parity Evidence:**
    * runtime screenshots on the iPhone 16, 16e and Pro Max, side by side with the renders;
    * a screen recording of a row lift, a column lift and a thaw;
    * an OS text-size sweep up to AX5;
    * Reduce Motion on and off;
    * `integration_test` still green on the simulator.
* **QA (F03-QA-D1)** — final stage, client-only; modules core + client-ui + visual-quality + stateful-flow; regression full:
  * an independent runtime rubric score ≥ 93, with every dimension ≥ 8 and no fail condition;
  * regression over AC1–AC11 — gestures, no double count, resume across a kill — plus the tutorial's AC4 / AC11 re-show;
  * the text-scale sweep and Reduce Motion;
  * Android stated as a limit.
* **Exit:**
  * Visual Quality Gate Passed;
  * final QA Approved or Approved with Notes;
  * Delivery Review Accepted.

  F03 then returns to Done, and D2 is activated.

### 19.8 Visual-gate checkpoint rulings (Tech Lead, 2026-09-27)

The F03-UI-D1 handoff (`ui-design.md` §1–§14, 28 renders, motion prototype; commit `4223c55`) is **accepted**. The Visual Quality Gate is **Ready for Implementation**. The rulings on `ui-design.md` §14:

1. **Text cap on the whole of Play (§14.1): accepted**, as written into §19.3 (1).
2. **Design-layer edits (§14.2): in D1 scope** as a cross-feature item. F00 stays Done — the same precedent as the F05 overlay (§19.5) and the 2026-09-20 F04 edit.
   * **Allowed in `app/lib/design`:**
     * `TileFace` and `RailTile` glyphs take `loopCappedTextScaler` — without it they overflow at AX5;
     * the pressed fill of `_Pressable` glass controls (fill .075 → .14, edge .07 → .18);
     * a new drawn `LoopIcon.loopBreak`, path in `ui-design.md` §7;
     * new decoration widgets: active-line rails, tutorial ghost ring, hint pill, loading skeleton cell.
   * **Requirements:** each change needs component tests; the existing F00 design tests stay green; the debug gallery may show the new pieces.
   * **Not allowed:** token value changes or new dependencies.
3. **Hint-pill fallback (measured at the checkpoint):**
   * On the 390 × 844 render at the 1.3× cap, the pill clears the board card by 4.5 pt and the undo pill by 4.0 pt. The handoff table's 5.1 pt left out the 1 px border.
   * Flutter line metrics may differ. If the device run measures under 4 pt, the pill's vertical padding drops from 7·s to 5·s above a 1.15× text scale.
   * This fallback is pre-agreed; no new handoff round. Any other deviation is Needs Tech Lead Clarification.
4. **Consumed-quota dot:** stays at 25 % lime (decorative; the count is carried by the bright dots and the semantics).
5. **Non-Journey header:** the chevron alone. Daily's header belongs to F07.
6. **New copy:** `HEDEF DÖNGÜ`, `SEVİYE NN`, `Bu bulmaca yüklenemedi.` and `Ana ekrana dön` ship as interim copy through `PlayStrings` (decision 6). PO / localization may revise it (F10-UI-LOCALIZATION).
7. **Evidence expected from Frontend** (`frontend.md` § Visual Parity Evidence, gate schema):
   * `runtime-screenshot` records for every `ui-design.md` §12a row on the iPhone 16, plus 16e / Pro Max for idle, tutorial and column drag;
   * `parity-comparison` composites against the D1 / S renders, with a deviation list;
   * a `runtime-video` screen recording of a row lift, a column lift, a thaw, and the tutorial ghost hiding and returning;
   * `accessibility` records for OS text at default, xxxLarge and AX5, and for Reduce Motion on and off.
8. **Informational items:**
   * D2 follows D1 with no release in between — there is no distribution anyway.
   * The frozen-row content observation is logged in `workflow-follow-ups.md` (content), outside F03.

### 19.9 Frontend checkpoint rulings (Tech Lead, 2026-09-28)

The F03-FE-D1 delivery (commit `b8b5f60`; `frontend.md`) is **accepted**. The Visual Quality Gate is **Ready for QA**, and F03-QA-D1 is open.

**Verified independently at the checkpoint:**
* **Scope:** the commit touches only the D1 surfaces, the F05 overlay, the allowed design-layer files, the tests and the F03 evidence. No token value, dependency, `feature-board.md`, `system-state.md`, `architecture.md` or `ui-design.md` changed. No Material `Icon` is left in `app/lib`.
* **Suites re-run:** `melos run analyze` clean; `flutter test` 405 passed.
* **Negative runs** — each rule broken on purpose, its test run, the file restored from git; all seven caught:
  * N1 hint-pill clearance (A-1) — 9 tests fail;
  * N2 tile glyph cap (A-2) — 6 fail;
  * N3 ghost hides on touch-down (A-6) — 1 fails;
  * N4 thaw cross-fade (A-5) — 1 fails;
  * N5 panel floor under the docked row (ruling 1 below) — 10 fail;
  * N6 `HAMLE` at the settle — 1 fails;
  * N7 undo disabled at quota 0 (AC6) — 1 fails.
* **Parity:** `design/src/measure-d1.swift` re-run on all 19 pairs reproduces `design/runtime-d1/parity-measurements.txt` number for number. Composites PC-08 and PC-06-t090 were inspected.

**Rulings on the Frontend's clarifications (`frontend.md` §16):**
1. **NTLC-1 — the won dock moves onto the goal: accepted for the D1 hybrid period.**
   * **Why:** the accepted D1 header ends the rail tiles at ≈ 33 % of H, so §16.3's free zone is negative on every supported phone. The only in-rule alternative — flooring the panel under the rail — leaves the Perfect panel 5–13 pt short at 1.3× on 390 / 393-pt phones even after every §16.3 concession, i.e. the panel would cover the row, which §16.3 forbids. The implemented variant keeps every hard §16 invariant (T0 + 600 ms, the panel never over the row, ≤ 64 % of H, one fixed dock for all variants and rows, controls ≥ 44 pt, one glow, no blur) and restores the shipped panel geometry (regular density at 1.0×).
   * **Amended rules** (they replace the ones cited while D1 is live):
     * §16.3 "Dock": the docked tiles centre vertically on the goal's rail tiles, which fade out beneath the row as it arrives (and back on Retry); the row keeps its x.
     * §16.3 "Panel cap": the panel top is `max(0.36 H, dock bottom + 16 pt)`; the row-scale fallback (≥ 0.8) applies only to frames too short for the unit.
     * §16.5 (1): "`W.top ≥ dividerY + 12 pt`" is replaced by "the docked tiles centre on the goal tiles (± 0.5 pt) and the goal tiles are at opacity 0 at rest". The other §16.5 rules are unchanged.
   * **Lifetime:** D2 replaces the whole moment with the full-screen result, so no UI Designer round is opened for it. `ui-design.md` §16 carries a pointer to this ruling.
2. **NTLC-2 — three design-layer edits beyond the §19.8 (2) list: accepted in D1 scope.**
   * The edits: `LoopBackButton`, `TileFace.iconScale`, and the `UndoPill` spent dot as an `AnimatedContainer`.
   * **Why:** each implements an accepted handoff decision — the §7 header "in one `_Pressable`", the §5 thaw snowflake 1 → 0.6 and the §5 120 ms dot dim. None changes a token value or adds a dependency; each has component tests; the F00 suite is green. F00 stays Done.
3. **Reconciliation items (`frontend.md` §4): accepted as implemented.**
   * `HAMLE` swaps at the settle (§8 "may update on settle"; ui-design §5).
   * The HUD keeps its look through a drag and a settle; the controller still drops presses while input is locked (MP-D1).
   * The F05 re-prompt pulse is removed; the returning ghost is the re-prompt (visual authority §19.5).
   * On the load error, the headline role is capped at 1.3× (§19.3 (1) role rule; it would break mid-word at AX5), the pill label follows the OS scale (`LimePill` reflows) and the column scrolls.
   * The §19.8 (3) hint-pill fallback is on: the device measured 3.93 pt on the 16e at the cap, and 6.27 pt after the fallback.
4. **Focus-ring evidence class (D1-12).** The runtime capture could not be made: this host cannot inject hardware keys into the simulator. The sub-state is accepted on the automated Tab-trigger widget test — the same evidence class F00 QA accepted for this ring (F00 `qa.md` E21), on the same `_Pressable` path. QA checks the ring at runtime if its environment can send hardware keys; otherwise it stays a stated limit, as in F00.
5. **Informational — no F03 action:**
   * **NTLC-3:** the `HAMLE` label sits ≈ 1.7 pt inside the card border at the 1.3× cap. That matches D1-10; there is no clipping or overlap. Logged as MOVESCARD-CAP-MARGIN in `workflow-follow-ups.md`, for the next design-layer touch.
   * **NTLC-5:** ui-design §5's "existing 120 ms grid swap" never existed; undo / restart swap instantly, unchanged. The line is corrected in `ui-design.md` §5.
   * **NTLC-6:** the legacy won moment / F04 panel at AX5 overflows as in the Phase C audit (A-2) — D2 scope.
   * **NTLC-4:** CI runs the repo-wide `melos run format:check`, which fails on the F00 QA probe `ai-system/features/f00-design-foundation/qa/src/qa_probe_main.dart` (unchanged since 3647cef), so the CI format step is red independent of F03. `app/`, `packages/` and `tools/` are formatted. Logged as CI-FORMAT-GATE (owner DevOps/Release Engineer). It does not gate F03-QA-D1.

**QA focus for F03-QA-D1** (the brief is in the orchestration's Current Brief):
* the §11.5 acceptance list at runtime on the iPhone 16, 16e and Pro Max;
* the independent rubric ≥ 93 with every dimension ≥ 8 and no fail condition — the won moment is scored only against §16 as amended by ruling 1 (hybrid period);
* regression of AC1–AC11 and the F05 AC4 / AC11 re-show;
* the text sweep to AX5 and Reduce Motion on and off;
* Android stated as a limit.

### 19.10 QA-verdict rulings (Tech Lead, 2026-09-28)

F03-QA-D1 (`qa.md`, HEAD 5798c70) is **Rejected**: an independent rubric of 87 / 100, lowest Accessibility 7, with one fail condition (clipping / overflow). F03.D1-VISUAL-QA is FAIL.

The Tech Lead re-measured both blocking findings from QA's stored captures (same numbers) and confirmed their root causes in the code. F03 goes to **Rework**; the handoff and the §19.3 / §19.8 / §19.9 rulings stay in force.

1. **F03-QA-D1-01 — the `HAMLE` label overflows the `MovesCard` at the text cap: accepted as an implementation defect.**
   * **Cause:** `MovesCard` (F00 design layer, `app/lib/design/components/info.dart`) is a 60·s-wide column with a 63·s minimum height and no inner vertical padding. At the 1.3× cap the label (≈ 57 of 64 pt wide) sits against the bottom edge, so its outer glyphs cross the 22·s corner arcs (xxL → AX5).
   * **Design-layer allowance (cross-feature, the §19.8 (2) precedent; F00 stays Done):** `MovesCard` may change its internal layout — inner vertical padding and/or minimum-height growth at scales above 1.0 — to satisfy the rule below. The card keeps its width (60·s) and its top-left anchor (273.5, 75)·s. It may grow downward only, and must stay ≥ 8 pt above the `HEDEF DÖNGÜ` caption. No token value, `LoopText` role, font or tracking may change.
   * **Rule (rect-testable):** at every OS text size from default to AX5, on 390, 393 and 440 pt widths, the ink of the numeral and of the label lies inside the card's rounded rectangle — corner arcs included — inset by ≥ 2 pt. The default-size look stays as in D1-00 (layout within ±2 pt).
   * **Consumers:** only Play and the debug gallery render `MovesCard`.
   * **Follow-up:** this supersedes MOVESCARD-CAP-MARGIN, which closes with the rework.
2. **F03-QA-D1-02 — the load-error headline breaks "yüklenemedi" / "." at xxxL and above: accepted as an implementation defect.**
   * **Cause:** in `_LoadErrorView` (`app/lib/play/play_session_screen.dart`) the headline is constrained to `maxWidth: 230 * s` (≈ 252 pt at 393), narrower than the card's inner width (257·s ≈ 282 pt). At the §19.9 (3) cap the word no longer fits.
   * **Rule:** at every OS text size from default to AX5, on 390, 393 and 440 pt widths, the headline breaks only between words — no line consisting only of punctuation, no break inside a word.
   * The §19.9 (3) 1.3× cap on the headline stays. The headline may use up to the card's inner width.
   * The D1-07 look at the default size is unchanged (layout within ±2 pt).
3. **F03-QA-D1-03 — a two-finger drag does not honour the first pointer: recorded, not in D1.**
   * QA observed at runtime that two simultaneous fingers moving in opposite directions produce no move, where §6 and the PRD edge case say "first touch only". The outcome is safe: no double move and no torn state.
   * The gesture code predates D1 (3a6e854), and §19.6 forbids behaviour changes in this visual rework.
   * Logged as follow-up **F03-MULTITOUCH-FIRST-POINTER** (`workflow-follow-ups.md`; owner Frontend/Mobile Developer, then QA). It is scheduled as a behaviour rework after Phase D and does not block D1's closure. §6 stays unchanged.
4. **Evidence correction.** `frontend.md` NTLC-3 and A11Y-16-text say "no clipping or overlap" at the cap. That is true only at the card centre, and the Frontend corrects it in the rework delivery.
5. **Re-QA (F03-QA-D1R, queued):**
   * Final stage; modules core, client-ui, visual-quality, stateful-flow; Regression Depth full with Evidence Reuse allowed.
   * QA's F03-QA-D1 evidence stays valid for every surface the rework's `app/` diff does not touch. QA confirms that from the diff.
   * The text sweep (large → AX5) on the three devices, the two reworked surfaces and a full rubric re-score are required.

### 19.11 Rework checkpoint rulings (Tech Lead, 2026-09-28)

The F03-FE-D1R delivery (working tree on `97c700e`; `frontend.md` § F03-FE-D1R) is **accepted**. The Visual Quality Gate is **Ready for QA**, and F03-QA-D1R is open.

**Verified independently at the checkpoint:**
* **Scope:** the `app/` diff touches only `MovesCard` (`app/lib/design/components/info.dart`, inside the §19.10 (1) allowance), the `_LoadErrorView` headline (`app/lib/play/play_session_screen.dart`, the `ConstrainedBox(maxWidth: 230 * s)` removed, the cap kept) and tests. No token value, `LoopText` role, font, tracking, dependency, route, gesture, timing or persistence change. `MovesCard` has two consumers — Play and the debug gallery — as §19.10 (1) states. `feature-board.md`, `system-state.md`, `architecture.md` and `ui-design.md` were not touched by the delivery.
* **Suites re-run:** `melos run analyze` clean; `flutter test` (app) 472 passed; `dart format` 0 changed in `app`, `packages`, `tools`. `integration_test` 13 / 13 on the iPhone 16 is the Frontend's record (not re-run here — the diff has no behaviour path it exercises).
* **Tests read:** `moves_card_ink_test.dart` rasterises the real glyphs (bundled fonts, app Material theme) and measures them against the card's rounded rect, arcs included — not a layout box. `load_error_headline_test.dart` reads the laid-out lines and flags punctuation-only lines and mid-word breaks; the checker has its own negative unit test.
* **Negative runs** — each rule broken on purpose, the tests run, the file restored (SHA-1 verified):
  * N1 `capGrowth = 0` (no growth) — 33 fail;
  * N1b `capGrowth = 9` (too little) — 26 fail;
  * N3 full growth at the default size — 7 fail (the 60 × 63·s default-size checks, incl. `components_test`);
  * N2 the HEAD `play_session_screen.dart` (230·s limit) — 12 fail;
  * N2c the headline uncapped — 9 fail.
  * A 245·s limit passes, correctly: the test checks the word-break rule, not a width.
* **Runtime measurements:** `design/src/measure-d1r.swift` re-run on all 30 captures in `design/runtime-d1r/` reproduces `measurements-d1r.txt` line for line (165 / 165). On QA's pre-rework captures the same tool reads −4.76 pt (QA-16-16) and flags the "." line (QA-16-28). Label inset after the fix: ≥ 2.98 pt (16), ≥ 3.22 (16e), ≥ 3.27 (Pro Max); the headline is two lines at every size. Composites PC-D1R-hamle-ax5 and PC-D1R-error-ax5 and the 16e AX5 capture were inspected.

**Rulings on the Frontend's clarifications (`frontend.md` § F03-FE-D1R §16):**
1. **NTLC-D1R-1:** MOVESCARD-CAP-MARGIN is **closed** in `workflow-follow-ups.md` (superseded by §19.10 (1), fixed and verified here).
2. **NTLC-D1R-2 — the counter inherits the ambient line height: accepted as is for D1; logged.** The Play look is the accepted one, the tests pin the app's Material context, and the rect rule still holds in another context because the growth only adds room. Changing `LoopText.counter` is outside §19.10 (1). Logged as **MOVESCARD-COUNTER-LINE-HEIGHT** (`workflow-follow-ups.md`) for the next design-layer touch (D3 or F10's global theme).
3. **§19.10 (4) evidence correction: done** — A11Y-16-text and NTLC-3 carry "Corrected" notes; the original D1 text is kept.

**Evidence reuse for F03-QA-D1R (§19.10 (5)):** QA's F03-QA-D1 evidence (HEAD 5798c70, `app/` = b8b5f60) stays valid for every surface and state the rework does not render differently — QA confirms from `git diff 5798c70 -- app/`. Invalidated and re-run: every Play capture at an OS size above `large` (the `HAMLE` card is in every Play header, the tutorial included), the load-error state at every size, and the rubric score, which is re-scored in full. Default-size Play captures stay valid where the diff leaves the card at exactly 60 × 63·s.

### 19.12 D1 closure rulings (Tech Lead, 2026-09-28)

F03-QA-D1R (`qa.md`; HEAD 97c700e + the F03-FE-D1R working tree) returned **Approved with Notes**. The independent rubric is **93 / 100**, every dimension ≥ 9, with no fail condition and complete runtime evidence. F03.D1R-VISUAL-QA is PASS. The verdict is **accepted**; the Visual Quality Gate is **Passed**, and D1 closes (F03 Done).

**Verified independently at the closure:**
* **Revision:** `git diff 5798c70 -- app` still hashes to QA's value (`88f1dca3…`), and the three new test files and both changed sources match QA's SHA-1s. The verdict covers exactly the delivered rework.
  * The rework, the rework checkpoint and the QA run are uncommitted. The closure binds to that fingerprint; the next commit must contain it unchanged.
* **Measurements:** QA's own tool (`qa/d1r/src/qa-d1r.swift`, SHA-1 `fa328093…`) was recompiled and re-run on every capture. It reproduces `qa/d1r/QM-d1r-measurements.txt` line for line (253 / 253).
* **The tool catches violations** — negative checks not run by QA:
  * a label-coloured 1-pt patch painted outside the card's bottom-left arc: 4 pixels flagged outside, inset −6.49 pt;
  * the same patch 1 pt inside the arc: inset 0.46 pt, below the ≥ 2 pt rule;
  * QA's own negatives on the D1 captures (−3.80 pt; the "." line) reproduce.
  * Caveat: a bright patch inside the corner scan region nudges the radius fit (label inset 3.41 → 3.66 pt on that capture). The violation is still flagged. A future reuse of the tool should keep a negative control beside every run.
* **Suite:** `flutter test` (app) re-run — 472 passed.
* **Captures read:** the 16e L26 and the Pro Max load error, both at AX5. Label inside its card, headline on two lines between words, pill reflowed.
* **Simulators:** the 16e and Pro Max are at `large`, Reduce Motion 0, and `journey-tr-07.json` equals the repo (`2fef993c…`), as QA recorded.

**Rulings:**
1. **Score at the threshold: accepted.** The change from 87 to 93 sits entirely in the four dimensions D1 lowered only for F03-QA-D1-01 / -02: Layout, Typography, Accessibility and Fidelity. The other six keep the D1 calibration.
   * Fidelity 10 relies on the cap-size card height deviating from D1-10. That deviation is required by §19.10 (1), and D1-10 itself showed the label on the arcs. It is explained, not a fail condition.
   * The score was not re-scored here; the Tech Lead does not grade in QA's place (visual-quality-gate.md §3).
2. **Brief correction — the `HAMLE` card in `won`.** The F03-QA-D1R brief said "the card hides in `won`". That is wrong.
   * The authority hides only the back chevron in `won` (§19.4; ui-design §6 / §7). The card stays under the scrim, as runtime shows and as F03-QA-D1 E23 accepted.
   * QA was right to follow the authority and open no finding. D2 replaces the moment, and its contract must state the result screen's chrome explicitly.
3. **`qa.md` layout: accepted.** QA moved the D1 report byte-for-byte to `history/f03-puzzle-play-session-2026-09-27/qa-at-d1-verdict.md` instead of appending the D1R report under it.
   * Reason: the flow audit reads the first `Final Score` / `Lowest Dimension` in `qa.md`. This follows QA's own D1 precedent (`qa-before-phase-d1.md`).
4. **F03.D1-VISUAL-QA re-evaluated as superseded: accepted.** QA owns the record. The scenario is re-met by F03.D1R-VISUAL-QA on the reworked revision.
   * The D1 run's FAIL text is kept verbatim in the record and in the archive.
   * Same pattern as F00's consolidated superseded records.
5. **QA environment note corrected.** `qa.md` §7 says the iPhone 16 holds the integration build. In fact the app is not installed there: the `integration_test` run uninstalls it, and the seeded database went with it.
   * No evidence depends on that state; later runs reinstall and reseed (`design/src/seed-sim.sh` handles a fresh install).
6. **Non-blocking notes routed:**
   * **Error screen at AX5 — the pill label outgrows the capped headline.** The `LimePill` follows the OS scale (§19.9 (3)); the headline stays at 1.3×. Accepted for D1. Logged in `workflow-follow-ups.md` (OPTIONAL-QUALITY-NOTES) for D3, which sets the shared text-scale treatment of error surfaces (C-6, C-9).
   * **Won moment / panel at AX5 overflows and covers the row.** Known as NTLC-6 and A-2 (result). It is D2 scope, and D2 must meet C-9 up to AX5.
   * **Legacy Home at AX5:** AUD-A11Y-04, D3.
   * **Still open:** F03-MULTITOUCH-FIRST-POINTER, MOVESCARD-COUNTER-LINE-HEIGHT, ANDROID-CI-EVIDENCE; VoiceOver and the hardware focus ring rest on the automated class (§19.9 (4)).

**Closure:** every D1 task is Done, Delivery Review is Accepted and QA is final Approved with Notes. There is no release scope. Every Pending Evidence record is PASS, and there is no blocker or open decision. F03 returns to **Done**. The resume point is **Phase D2 — won moment + full-screen result**, carried by F03 with F04 amendments (`motion-critical`; Design Adoption Route). It is activated by the next Tech Lead turn, which writes the D2 contract (§20) and opens the UI Designer task.

## 20. Design Adoption Phase D2 — won moment + full-screen result [LOCKED 2026-09-28]

> **Added by:** the Tech Lead on 2026-09-28, at the D2 activation right after the D1 closure (§19.12). It reopens F03 as visual rework under rework control; F03 is the carrier (audit C-2), with the F04 amendments and the F05 wording resync applied in the same reopen.
>
> **Authority:**
> * `project-authority/design-foundation.md` — Direction C "Loop Glass"; the user's decisions in §18, in particular decision 2 (**full-screen result, no board behind, no Close button**) and decision 3 (third stat = `EN İYİ`), and consequences 1–3.
> * `features/f00-design-foundation/ui-design.md` — §4 entry/exit, §5 flow, §6 Result layout, §7 components, §8 Result states, §11 motion spec, §13 accessibility.
> * The selected-source renders `S-04`, `S-04b`, `S-05`, the frames `S-08 … S-16` and the executable prototype `design/src/S-transition-prototype.html` (F00); the device variants `S-v-*`.
> * The audit: `conformance-audit.md` §6, §9 items 1, 2, 6, 7, 9, 14, §10 renders 11–18; rulings C-3, C-4, C-9 and C-11.
> * The D1 surface (§19) is the starting frame of the transition.

### 20.1 User-visible symptom

The payoff moment still has the pre-Foundation look. After a solving move the row turns amber, docks on the goal rail, and a bottom sheet with the system font, amber glow and three luminous elements rises over the dimmed Loop Glass board. The user decided on 2026-09-21 that the solved screen is a full-screen result with no board and no Close button. At AX5 the sheet grows to ≈ 84 % H, covers the answer row, and clips its labels (A-2 result; NTLC-6).

### 20.2 Scope

* **Affected journey:** a settled solving move (T0) → win sequence → transition → full-screen result → Next / Retry / back.
* **Surfaces and states** (`/play` in `won`, plus the transition out of it):
  * the win sequence on the D1 board, including locked / frozen tiles in the winning row (C-11);
  * the board → result transition and its reduced-motion path;
  * the full-screen result in every F04 variant: `firstClear`, `newBest`, `matchedBest`, `noImprovement`, Perfect (alone and with a new best), the defensive no-optimal fallback, Next not wired (non-Journey), and the level-30 result (Next → terminal, F05 AC12);
  * the exit from the result: Retry back into Play, Next, the back button, system back.
* **Visual Scope `motion-critical`:** the composition is new and driven by a specified transition, so video / frame-sequence evidence is required at every gate.

### 20.3 Decisions (Tech Lead)

1. **Timeline — the §18 (2026-09-20) intent is kept, the composition is replaced.** Times are ms from T0.
   * **0–600: win sequence on the board.** The winning row fills lime left → right with a 30 ms stagger (90 ms per tile); one bloom; board and chrome dim. **Nothing outside the board may appear before T0 + 600** (the purpose of the old T0 + 600 panel rule).
   * **600–940: transition.** The answer row glides from its board position to its result position, morphing tile size and radius (from the D1 board tile to the result tile). Board, target rail, HUD and the Play header (back label, `HAMLE` card) fade to 0. Result content fades and rises in.
   * **Rest ≤ T0 + 940.** The stars then fill one by one (≈ 940–1300, rest-state reveal; F04 "≤ ~800 ms" reveal bound).
   * **Reduced motion** (the shared `reduceMotionRequested()`): the row is lime and static from T0; hold 300 ms; 160 ms cross-fade to the result; content fades in; stars static; **total 660 ms**.
   * The exact curves and per-element windows are the UI Designer's (F00 ui-design §11 is the starting point, re-timed on the D1 board geometry). Any change to the bounds above needs a Tech Lead ruling.
2. **Input and lifecycle.**
   * Input to the board and every result control is locked from T0 until rest (reduced path included). Taps before rest are dropped, not queued.
   * **System back / edge swipe is honoured at any time in `won`**: it pops to the caller and resolves to `/` (`_popToCaller`, F05 §8). This is today's behaviour and it is safe: the completion is persisted at `won` (item 3).
   * App backgrounded mid-sequence → on return the sequence resolves deterministically to the rest state (§12 rule). OS kill mid-sequence → relaunch lands on Home with no active session; best and unlock already written.
3. **Persistence / controller semantics unchanged.** The `completed` snapshot + `clearActiveSession()`, F04's `personal_best` write, F05's unlock and `controller.completion` stay triggered at `won`. Only presentation changes. The result must not wait on a slow rating read longer than today (`ratingUnavailable` path unchanged).
4. **Result layout (F00 ui-design §6), full screen, no board.** Top to bottom: back button; badge (when present); display headline; subtitle; the answer tiles (the row that won, with the ghost slot / lime radial per the design); stars; stats card (`SEN` · `OPTİMAL` · `EN İYİ`, decision 3); primary pill; secondary text link.
   * **Chrome at rest (§19.12 (2)):** the result shows **only** its own back button. The Play header (back label, `HAMLE` card), target rail, board and HUD are gone at rest.
   * **One glow:** the lime answer row (+ bloom) is the only luminous element; the primary pill and stars carry no glow (design-foundation §18 consequence 3).
5. **Result markers and badges (C-4, confirmed here; F04 ui-design decisions, PRD unaffected):**
   * dropped: the `3 / 3` line, the `+N` / `=` delta, `İLK`, "daha iyi";
   * badge `HARİKA` iff Perfect (it wins over a new best); badge `YENİ EN İYİ` iff `newBest` and not Perfect; no badge otherwise;
   * the star count stays announced non-visually (`Semantics` "N / 3 yıldız", plus "Harika" / "Yeni en iyi" when shown).
6. **CTA weighting (F04 §7 as shipped):** Perfect → primary "Sonraki bölüm", link "Tekrar oyna"; every other variant → primary "Tekrar oyna", link "Sonraki bölüm". Non-Journey sessions (no Next handler) → the link is disabled as "Sonraki bölüm · yakında". **Level 30:** Next routes to the terminal home (F05 AC12); the UI Designer proposes its label (copy → PO / localization).
7. **Exits.**
   * **Back button** (top-left, `GlassIconButton` with the drawn back icon, ≥ 44 pt, `Semantics` "Ana ekrana dön") and system back → `_popToCaller` → `/`. **There is no Close button** (decision 2).
   * **"Tekrar oyna"** → `retryFromCompletion()`: restart the same level in place (unchanged semantics: moves 0, undo 3, restart count as today). The result → Play transition is designed by the UI Designer: bounded (≤ 400 ms), input locked during it, instant / cross-fade under reduced motion.
   * **"Sonraki bölüm"** → F05's `_nextLevelHandler()` (unchanged: `pushReplacement` to N+1, or `/` → terminal).
8. **Special tiles in the winning row (C-11):** the whole answer row turns lime at T0; lock and snowflake icons fade out with the fill (instant under reduced motion). Rendered in the handoff.
9. **Text scale (C-9) on the result.**
   * Container text (answer tiles, stat values and labels, badge, display headline) uses `loopCappedTextScaler` (1.3×).
   * Free text (subtitle, CTA labels, link) follows the OS scale up to AX5 with no clipping, overlap or mid-word break.
   * **Scrolling (the C-9 open point):** at every OS size up to the 1.3× cap the result fits without scrolling on 390 × 844 to 440 × 956. Above the cap the content column **may** scroll; the back button stays fixed and reachable, and the transition always lands at scroll offset 0. Play itself never scrolls (§19.3 (1)).
10. **Copy (interim, through `PlayStrings` / the rating strings; final with PO / localization, F10-UI-LOCALIZATION):** headline "Döngü tamamlandı."; a data-driven subtitle (the UI Designer proposes it, e.g. "Hedef N hamlede yerine oturdu."); "Sonraki bölüm", "Tekrar oyna"; badges `HARİKA`, `YENİ EN İYİ`; stat labels `SEN`, `OPTİMAL`, `EN İYİ`. Turkish casing authored or `tr`-aware only.
11. **Performance:** no backdrop blur; the mid-tier frame budget from §18 (2026-09-06) stays; the transition must not drop frames visibly on the iPhone 16e simulator (QA observes it on video).

### 20.4 Contract amendments

* **F03 §4 exit, §10 (4), §13:** "completion panel → Retry / Close" becomes "full-screen result → Next / Retry / back button / system back" (§20.3 (6–7)); no Close.
* **F03 §18 won-sequence authority (2026-09-20):** its sequencing, persistence and input rules stand as restated in §20.3 (1–3). Its geometry requirement (row visible above the panel) and the §19.9 (1) dock amendments lapse when D2 ships; the full-screen rule in §20.3 (4) and (9) replaces them.
* **F03 `ui-design.md` §16 (won composition):** superseded by the D2 handoff.
* **F04 `architecture.md` §7 / §8:** the panel becomes the full-screen result (content per AC7, variants per §20.3 (5–6)); `Close` is removed, back = the result's back button + system back. F04 `ui-design.md` (Direction A panel) is superseded for the result by the D2 handoff. **F04 AC1–AC10 are unchanged** and stay the acceptance for the content; F04 stays Done (precedent: the 2026-09-20 F03 rework).
* **F05 PRD AC1 and `architecture.md` §8 (C-3):** the wording "(via `Next Level` or `Close`)" becomes "(via `Next Level`, the back button or system back)". The unlock is written at `won`, so the product semantics are unchanged; the product PRD says only "when the completion panel closes". Tech Lead resync of the feature-level text; no Product Owner revision. F05 stays Done.
* **Tests:** the strings `Kapat`, `Yeniden`, `SONRAKİ`, `ÇÖZÜLDÜ`, `YENİ REKOR` in `app/test` and `app/integration_test` change with the rework (`completion_panel_test`, `won_composition_test`, `play_session_screen_test`, `play_session_runtime_test`, `integration_test/play_session_test`). Every F04 AC keeps a passing test.

### 20.5 Non-goals

* No engine, scoring, star-boundary, persistence, snapshot, lifecycle or route change; no new route (the result stays an in-screen state of `/play`).
* Home and the app shell (D3). F09 onboarding, F11 audio / haptics (intent only), F12 analytics, F07 Daily result copy, aggregate stars (decision 4).
* F03-MULTITOUCH-FIRST-POINTER stays a separate behaviour follow-up.

### 20.6 Evidence and exit criteria

* **UI Designer (F03-UI-D2)** — the D2 handoff in F03 `ui-design.md` (replacing §16), per the handoff gate in `visual-quality-gate.md`:
  * the result layout on 393 × 852 and the 390 × 844 / 440 × 956 variants;
  * components, states, interaction and copy proposals (§20.3 (5–7), (10));
  * **motion:** the win sequence, the board → result transition and the result → Play retry transition, each with its reduced path, as an **executable prototype re-timed on the D1 board geometry** plus timed frame stills;
  * **renders:** every §20.2 variant, including the audit's D2 list (1★, matched best, first clear, Perfect + new best, level 30, Next not wired, a locked / frozen tile in the winning row, AX5), the winning row at rows 0 and 4, and the transition frames;
  * a Screen / State / Viewport matrix, a Visual Evidence Manifest and a **D2 acceptance list**;
  * gate → Ready for Implementation at the Tech Lead checkpoint.
* **Frontend/Mobile Developer (F03-FE-D2)** — implement from `app/lib/design`; drop `PlayTheme` from the won path; update the tests (§20.4). `frontend.md` Visual Parity Evidence:
  * runtime screenshots of every variant on the iPhone 16, and of the main variants on the 16e and Pro Max, beside the renders;
  * **screen recordings** of the full sequence (rows 0 and 4, a special-tile row), the retry transition, and the reduced path, with frame-timing measurements: nothing outside the board before T0 + 600, rest ≤ T0 + 940, reduced total ≈ 660;
  * an OS text sweep large → AX5 on the result; Reduce Motion on and off;
  * `melos run analyze` / `test` green; `integration_test` green on the simulator.
* **QA (F03-QA-D2)** — final stage, client-only; modules core + client-ui + visual-quality + stateful-flow; regression full:
  * an independent runtime rubric ≥ 93, every dimension ≥ 8, no fail condition, from video for the motion;
  * F04 AC1–AC10 on the result, F05 AC1 / AC12, F03 AC8 / AC11, and the D1 Play surface regression;
  * lifecycle mid-sequence (background, kill, system back);
  * Android stated as a limit.
* **Exit:** Visual Quality Gate Passed; final QA Approved or Approved with Notes; Delivery Review Accepted. F03 then returns to Done and D3 is activated.

### 20.7 Visual-gate checkpoint rulings (Tech Lead, 2026-09-28)

The F03-UI-D2 handoff (`ui-design.md` §16, 58 renders, 5 contact sheets, 5 executable prototypes, the timeline self-test; commit `6352a75`) is **accepted**. The Visual Quality Gate is **Ready for Implementation**, and F03-FE-D2 is open.

**Verified independently at the checkpoint:**
* **Scope:** the delivery commit touches only F03 `design/`, `orchestration.md` and `ui-design.md` — no `app/`, contract, board or state file. In `ui-design.md` §1–§14 only five cross-reference lines changed. The superseded F03-UI-WON §16 is archived byte-for-byte from `489606d` as `history/f03-puzzle-play-session-2026-09-28/ui-design-before-phase-d2.md`.
* **Handoff-gate items** (`visual-quality-gate.md` §2) are all present: the matrix §16.12a; component, typography, colour, asset and interaction decisions §16.5–§16.8; the motion spec with every reduced path §16.5; the manifest §16.12b; the selection record §16.2; the acceptance list §16.11.1.
* **Artefacts:** every render and prototype named in §16 exists (63 PNG). `node gen-d2.mjs` regenerates all 70 HTML / job files byte-for-byte, so every PNG traces to committed source. The contrast table (§16.5) reproduces 14 / 14.
* **Content:** the L4, L5, L26 and L30 grids, targets, locked / frozen cells and optimal counts in the generator equal `content/journey/tr`. Each solution was replayed with the real engine and the production dictionary (`looplet_authoring playtest`): each solves on its last move, at `optimalMoves` (3 / 5 / 4 / 5). The frozen-in-row case is synthetic and labelled.
* **Shipped semantics:** the generator's star rule and CTA weighting match the app (`starsForResult`; `nextIsPrimary = isPerfect && canNext` in `completion_panel.dart`), as do F04 AC1–AC3.
* **Timeline self-test:** re-run in headless Chrome — 7 / 7 results identical to `timeline-check-d2.txt` (rest 940, reduced 660, first result pixel 685 ms, retry 360 / 160).
* **Negative controls** (scratch copies of the check page, each with one rule broken):
  * headline entrance moved to 500 ms — caught (first result pixel 505, opacity 0.78 before 600);
  * radial moved to 560 ms — caught (opacity 0.18 before 600);
  * CTA entrance moved to 900 ms — reported (rest 1020);
  * the row glide started at 450 ms — **not caught**: `rowInsideBoardBefore600` stays true, because the result slot lies inside the board card's rectangle for rows 0, 2 and 4, so a row moving early never leaves it. A displacement probe (the row's rect against its own T0 rect) measures **0.00 px before 600 for rows 0, 2 and 4** in the delivered prototypes and **135.7 px** in the broken copy. The prototypes meet the bound; the self-test's containment assertion does not prove it (ruling C2).
  * The reduced check's `rowOnSlotAtRestPx` 137.95 measures the board-row layer, which by design fades in place and does not travel. Not applicable, not a defect.
* **Manifest correction (traceability, no new design):** §16.2 cites the F00 exploration of this surface (Directions A / B / C, `C-04` vs `C-04b`), but the §16.12b manifest had no `direction-render` record, so the full workflow audit failed on the motion-critical exploration rule. The Tech Lead added three pointer rows to the existing F00 renders (all 13 files present; records already in `design-foundation.md`), labelled as checkpoint additions. The audit then passes.
* **Renders read:** the five contact sheets (variants; row 2; rows 0 / 4 and special tiles; text scale and devices; reduced, retry and frozen) and `D2-10c` (AX5, scrolled to the end: the back button stays clear of the scrolled text).

**Rulings on `ui-design.md` §16.14:**
1. **Retry transition: A ("the answer returns to the goal") is adopted as the handoff design.**
   * This is not an Exploration Gate selection. The direction is Selected (decision 2), and §20.3 (7) left this transition's design to the UI Designer within its bounds. A meets them: rest 360 ≤ 400, input locked, a 160 ms dip under reduced motion.
   * **Assumption (hybrid decision):** the user may veto A in favour of B. B is already specified — it is A's reduced path — so a veto needs no new design round; the Frontend then plays the dip for both settings.
2. **Chrome fade 600–720: accepted.** It stays inside the §20.3 (1) bounds and removes the double exposure of `S-11`. §16.11 "Do not cheapen" binds it.
3. **Level-30 label "Yolculuğu tamamla": accepted as interim copy** through the strings. F05 AC12 behaviour is unchanged: the action is still F05's Next handler, routing to the terminal Home. Final copy is with PO / localization (F10-UI-LOCALIZATION), like the rest of §20.3 (10).
4. **No-optimal fallback: accepted.** The line "Bu bölüm puanlanamadı." replaces "Puan yok"; `—` for `OPTİMAL` and `EN İYİ`. Dev-only in practice (§6).
5. **Authored headline break: accepted.** `Döngü\ntamamlandı.` (EN `Loop\ncomplete.`) is the string value, and the §16.6 anchors are asserted with the two-line headline. If localization later rejects embedded breaks, the 250·s max-width alternative is pre-agreed (same TR result); no new handoff round.
6. **Design-layer additions: in D2 scope**, as a cross-feature item on the §19.8 (2) terms. F00 stays Done.
   * **Allowed in `app/lib/design`:** a star-reveal option on `StarRow` (or a wrapper); the scroll-band widget; a result-size variant of `TileFace.winning` (52.5 × 59·s, r 24·s).
   * **Requirements:** component tests for each; the F00 design tests stay green.
   * **Not allowed:** token value changes or new dependencies.
7. **Self-review 94:** provisional and not used. Runtime scoring is QA's (F03.D2-VISUAL-QA).

**Tech Lead corrections to the handoff** (binding for Frontend and QA; `ui-design.md` §16 carries a pointer):
* **C1 — the rating read (§16.4 (6) and the last §16.8 row).** The handoff says the stars stay in outline until `CompletionResult` resolves. That does not match the controller: at `won` it builds the result synchronously with `stars` and `isPerfect`. Only the personal-best read-back resolves later (`ratingResolved`; until then `personalBestMoves` is the sentinel 0 and `bestOutcome` is `firstClear`). Therefore:
  * the stars, their reveal and `HARİKA` never wait for the read;
  * `EN İYİ` shows `—` (and no ★) until `ratingResolved`, as today's sentinel does;
  * `YENİ EN İYİ` is shown only once resolved. If that happens after the badge row has entered, the badge fades in inside the reserved row — no layout shift;
  * if the write fails (`ratingPersisted` false), `EN İYİ` stays `—` and no best badge is shown;
  * no spinner and no wait beyond today (§20.3 (3)).
* **C2 — timing evidence for the row.** "The row stays on the board before T0 + 600" is proven by the row's **displacement from its own board cell** — ≤ 0.5 pt in position and size on every frame before T0 + 600 — not by containment in the board card, which cannot fail (above). The Frontend's frame-timing evidence (§20.6) and QA both use this measure.
* **C3 — the reduced win path is a cross-fade.** Between 300 and 460 ms the result row fades in over the board's upper rows while the board fades out (`D2-M-r2-reduced-t0380`). That is the contracted 160 ms cross-fade (§20.3 (1)), not a double-exposure finding. The "no double exposure" rule applies to the full-motion paths and to the retry dip.

**Evidence expected from Frontend** (`frontend.md` § Visual Parity Evidence, gate schema), extending §20.6:
* `runtime-screenshot` for every §16.12a result row on the iPhone 16, and the perfect, 1★ and 1.3× rows on the 16e and Pro Max;
* `parity-comparison` composites against the `D2-*` renders with a deviation list (±2 pt at 1.0×; the §16.6 anchors);
* `runtime-video` of the row-0 (L26, locked tiles), row-2 (L5) and row-4 (L4, on the 16e too) sequences, the retry, and both reduced paths — with a frame-timing table: the C2 displacement before 600, the first result pixel, the chrome at 0 by 720, rest ≤ 940 (reduced ≈ 660), retry ≤ 400 (reduced ≈ 160);
* `accessibility` records for OS text default, the 1.3× cap and AX5 (offset 0 and scrolled) on the result, and Reduce Motion on and off;
* the C1 late-read path shown by a widget test that delays the read-back (no badge, `—`, then the badge fades in with no layout shift).

### 20.8 Frontend checkpoint rulings (Tech Lead, 2026-09-28)

The F03-FE-D2 delivery (commit `67d9ecb`; `frontend.md`) is **accepted**. The Visual Quality Gate is **Ready for QA**, and F03-QA-D2 is open.

**Verified independently at the checkpoint** (HEAD `67d9ecb`, `app/` tree `f5641d2f…`):
* **Scope:** the commit touches only the D2 won path (`app/lib/play`, `app/lib/rating`), the three allowed design-layer additions (`TileFace.answer` + `glyphSize`, `StarRow.revealMs`, `ScrollBand`), the tests, the F03 evidence and the Frontend's own records.
  * No token value, dependency, `feature-board.md`, `system-state.md`, `architecture.md` or `ui-design.md` changed. `play_theme.dart` only loses the won-only members.
  * No `PopScope` / `WillPopScope` in `app/lib`, so system back is not intercepted in `won`. No Material `Icons.*`, blur, or `PlayTheme` on the won path. No legacy won string or widget is left in `lib` or `integration_test`.
* **Suites re-run:** `melos run analyze` SUCCESS; `dart format --set-exit-if-changed app packages tools` 0 changed; `flutter test` in `app/` **503 passed**. `integration_test` was not re-run (the Frontend's 13 / 13 on the iPhone 16 stands as its record; QA runs it).
* **Negative runs:** seven rules the Frontend did not break were broken on purpose. Each time the named suites were run and the file restored from a byte copy (the tree is clean afterwards). All seven were caught:
  * NA — result controls interactive before rest (§20.3 (2)): 6 tests fail;
  * NB — no jump to rest when backgrounded mid-sequence (§20.3 (2)): 1 fails;
  * NC — `HARİKA` waits for the rating read (C1): 1 fails;
  * ND — reduced rest 660 → 700: 6 fail;
  * NE — retry rest 360 → 420 (> 400, §20.3 (7)): 2 fail;
  * NF — CTA weighting ignores a missing Next handler: 7 fail;
  * NG — C-11 icons stay under the full lime face: 4 fail.
* **Frame timing re-measured** from the committed videos (`video-d2` and `parity-d2` compiled from `design/src`; `timing-d2.py` with `PX_PER_PT=2`):
  * rows 0 / 2 / 4 on the 16 and row 4 on the 16e reproduce the table within 1–3 ms: the row is at 0.00 pt from its cells through 595–599, first moves at 613–632, first result pixel 712–716, `HAMLE` final 730–733, pill at rest 947–950, stars done 1282–1286;
  * the 16e row-4 run has no frame gap > 30 ms in 600–1400 (§16.11.1 (18));
  * reduced: static through 278, first result pixel 442, rest 627; retry on the 16e at rest by 350; retry on the 16 at rest by 248;
  * **two table cells do not reproduce from the committed re-encodes.** On the 16e row-4 run the HUD region settles at +1186, not +719. On the iPhone 16 retry, board and HUD are final at +248, not +265. Neither changes a verdict:
    * the 16e frame at T0 + 1066 shows no Play chrome — the late value is background luma in the HUD measurement region, and the contracted "chrome at 0 by 720" is carried by `HAMLE` at 732 and that frame;
    * the retry difference is one capture frame inside the ≤ 400 bound.
  * The note in `frontend.md` under the timing table records this correction.
* **Parity:** `parity-d2.sh` re-run on all 18 pairs reproduces `runtime-d2/parity-measurements.txt` and every composite byte for byte (then restored from git). Composites PC-D2-03 (new best 2★) and PC-D2-10b (AX5, offset 0) were inspected: no clipping, the back button fixed, words broken only between words.

**Rulings on the Frontend's clarifications (`frontend.md` §16):**
1. **NTLC-D2-1 — result mounted at T0 + 450 (reduced + 150): accepted.**
   * §20.3 (1) bounds what is *visible*, and every result opacity stays 0 until 600 (reduced: 300). `won_sequence_test` asserts the result absent before 450 and at opacity 0 and not interactive to 599, every 10 ms.
   * The change removed a measured 153 ms settle-frame gap (`RV-16-r2-L5-before-mount-fix.mp4`).
   * `ui-design.md` §16.4 "built at T0" is read as "laid out before the glide".
2. **NTLC-D2-2 — two F00-component deviations: accepted as shipped for D2**, and logged as RESULT-F00-COMPONENT-ALIGN in `workflow-follow-ups.md`:
   * the `EN İYİ` ★ sits 4.3–6.0 pt above the render's superscript;
   * the pressed `LimePill` scales to 0.98 without the −5 % brightness of D2-12.
   * **Why:** both are shipped F00 components (`StatCell`, `LimePill` / `_Pressable`) outside the §20.7 (6) allowance. The ★ is not a §16.6 anchor, and the ±2 pt rule applies to those anchors. Changing F00 press behaviour for one surface would split the component's behaviour across screens.
   * QA scores the runtime as it is and may raise either item as a finding.
3. **NTLC-D2-3 — evidence limits: accepted as the Frontend's evidence class. They are QA's runtime scope, not waivers:**
   * **D2-07 (no-optimal):** not reachable at runtime — dev-only (§20.7 (4)). Widget tests on the screen and on `ResultView` stand.
   * **Focus ring (D2-11):** same ruling as §19.9 (4). QA checks it at runtime if its environment can send hardware keys; otherwise it stays a stated limit on the F00 Tab-trigger widget-test class.
   * **Lifecycle mid-sequence and system back mid-sequence:** §20.6 makes these QA runtime items (background, kill, system back / edge swipe at ≈ T0 + 300).
   * **VoiceOver:** QA runtime if available; otherwise a stated limit on the widget-test semantics.
   * **Debug builds only; Android not run:** stated limits (ANDROID-CI-EVIDENCE). The §20.3 (11) performance observation is made on debug simulator video, as in D1.
4. **Reconciliation items (`frontend.md` §4): accepted as implemented.**
   * The retry flight holds on the rail as the rail's face 300–360 (§16.11 "Flexible").
   * The win clock is anchored to the settle frame's timestamp, so rest is T0 + 940 on the frame clock.
   * The D2-04 / D2-06 captures use 5 / 7 moves instead of 4 / 8: waste moves come in pairs, so the solution stays BFS-verified. Layout and markers are identical.
5. **Informational — no F03 action:**
   * the 16e 1★ subtitle wraps at xxxL and moves the column 29 pt down, with still no scroll — permitted free-text reflow (§20.3 (9));
   * `ResultNext.terminal` is taken from the Journey length (30), matching F05's handler.

**QA focus for F03-QA-D2** (the brief is in the orchestration's Current Brief):
* the §16.11.1 acceptance list at runtime on the iPhone 16, 16e and Pro Max;
* an independent rubric ≥ 93 from runtime video, every dimension ≥ 8, no fail condition;
* F04 AC1–AC10 on the result, F05 AC1 / AC12, F03 AC8 / AC11;
* lifecycle mid-sequence, the text sweep to AX5, Reduce Motion on and off;
* D1 Play regression. Android is stated as a limit.
