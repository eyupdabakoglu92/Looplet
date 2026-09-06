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
* Header / chrome: a minimal back affordance that pops to the caller; no mandated title bar. Exact chrome is `[PENDING — UI]` and must follow `design-doctrine.md`. If a shared header standard emerges across screens later, this section is amended.
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
* **Locked / frozen tile *visual* treatment — F03 owns the first pass.** F02 owns the behaviour; F05/F06 author *which* tiles are locked/frozen. The `brass` ring + pin glyph (locked) and `frost` fill + crystal border + thaw cross-fade (frozen) shipped by F03-FE are the accepted first-pass visuals; there is **no separate tile-state visual feature** — a later polish revision, if wanted, is a scoped follow-on, not a blocker. (Confirms `ui-design.md §14` #2.)
* **Shared in-flow chrome ("no system header, one quiet back chevron top-left, hidden in terminal/`won` states") — locked for `/play`; cross-screen family rule deferred to F10.** F03 is the first in-flow screen, so there is no sibling to converge on yet; F10 (menu + settings) defines the shared chrome family and reconciles siblings then. (Confirms `ui-design.md §14` #3.)
* **Localization — `PlayStrings` per-language table accepted as the seam for F03.** A proper `gen_l10n` / `.arb` localization layer is a `[DEFERRED — F10-or-earlier follow-on]` (not F03); the final Turkish strings (`HEDEF / HAMLE / ÇÖZÜLDÜ / Yeniden / Kapat / Geri`) are a PO / localization deliverable, tracked with that task. Contract requirement ("externalized") is satisfied. (Confirms `ui-design.md §14` #4.)
* **Perf deviations from `ui-design.md` — accepted for the MVP.** (1) Board-recede during `won` is a **12 % dim only**, not dim + backdrop blur — preserves the "board recedes, winning row + sheet own focus" intent within the mid-tier frame-rate budget (`prd.md §6`); a device-tier-gated blur is a `[DEFERRED — post-MVP polish]`. (2) The optional breathing spotlight ambient is **omitted** — `ui-design.md §5/§11` marks it optional/flexible. Neither trips a `premium-ui-rubric.md` fail condition. (Resolves `frontend.md §16` #5–6.)

### Still open

* **`[RUNTIME VALIDATION PENDING — F03-FE9]`** (Frontend/Mobile Developer, then QA): `architecture.md §16` mandates `runtime` / `repeatable integration` evidence that the QA environment could not produce. Closure = an `integration_test/` suite (CI-runnable — `release.md §4` lists `integration_test` as a best-effort gate "not auto-blocking until F03 lands") covering `qa.md §17` scenarios 1–4 (gesture accuracy + threshold sweep on ≥2 surface sizes; 0 double-registered moves during the real ~190 ms window; kill/relaunch resume + tampered-`thawedFrozenCells` re-derivation; background mid-swipe / mid-animation), plus a short manual device/simulator confirmation of the visual items (`qa.md §17` 5–7: win-choreography readability, locked/frozen tile visuals, portrait lock on rotation, chevron/back). Then re-QA → close.
* `[PENDING — IMPL tuning]` (Frontend + QA on device): the gesture threshold `T` (18 logical px shipped) and the diagonal tie band `B` (ratio 0.15 shipped) — final values validated / adjusted on the device matrix via F03-FE9.
* `[DEFERRED — F04]` the real completion panel (stars / optimal / best / Perfect / Retry / Next Level) replaces F03's minimal panel.
* `[DEFERRED — F05]` real Journey entry + CONTINUE target resolution replace F03's debug puzzle entry.
* `[DEFERRED — F09]` onboarding overlay / arrow prompts layered on this screen.
* `[DEFERRED — F11]` SFX + haptics on move / thaw / win / button.
* `[DEFERRED — F12]` analytics events derived from F03's state changes.
