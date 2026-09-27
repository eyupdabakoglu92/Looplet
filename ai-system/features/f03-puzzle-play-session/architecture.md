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

* **Win:** target word forms on a settled move → input locks → win highlight → success animation → completion panel → the panel's actions: **Retry** (`engine.restart()` in place) or **Close** (pop to the caller / menu). On entering the completion panel, F03 writes a `status: completed` snapshot then calls `ActiveSessionRepo.clearActiveSession()` — a subsequent entry to the same puzzle starts fresh.
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
* No forward navigation from F03 except the completion panel's Close/Retry and (later) F04's "Next Level".

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

* **Won moment and result (D2):** F03 §16 and the F04 panel keep their look and timing.
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
