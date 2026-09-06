# F03 — puzzle-play-session: Feature PRD

> Derived from `product/product-prd.md` → "puzzle-play-session (F03)" (§ user stories / acceptance criteria / edge cases / notes), the F03 row in §6, and the cross-cutting §Performans / §Kullanılabilirlik-Erişilebilirlik / §Animasyon kısıtı constraints. Scope-specific; the product PRD remains the source of truth.

---

## 1. Summary

The in-game screen: the player manipulates the 5×5 grid by swiping rows and columns to form the always-visible target word in as few moves as possible. F03 owns the **playable screen and its interaction model** — gesture recognition, the 150–250 ms shift animation with input lock and no queue, the live `MOVES` HUD, 3 Undo actions, a separated Restart, row/column swipe feedback, and the completion sequence (input lock on settle → win highlight → success animation → completion panel).

F03 is the first player-visible feature. It consumes the **F02 grid engine** (deterministic shift/undo/restart/win/thaw), the **F08 active-session snapshot** (write-through persistence + exact resume), and **F01** word validation (via the engine's `WordValidator`). It does **not** own puzzle content (F06), star rating / personal best / the real completion panel (F04), Journey progression (F05), the Daily (F07), onboarding (F09), or audio/haptics (F11).

---

## 2. User Stories

* As a player, I want to swipe a row or column and watch it slide one cell, so that I can manipulate the grid intuitively with one hand.
* As a player, I want the target word always visible and clearly separated from the grid, so that I always know my goal.
* As a player, I want a live `MOVES` counter, so that I can judge my efficiency in real time.
* As a player, I want up to 3 undos and a restart, so that I can recover from mistakes without starting over blindly.
* As a player, I want accidental taps and tiny drags ignored, so that my move count stays honest.
* As a player, I want to leave mid-puzzle and come back exactly where I was, so that an interruption never costs me progress.

---

## 3. Acceptance Criteria

* **AC1** — Given the puzzle screen opens, When rendered, Then the target word, the grid, `MOVES: 0`, Undo (3 available), and Restart are shown; the target word is visually separated from the grid.
* **AC2** — Given a horizontal swipe that starts on a cell, exceeds the minimum threshold, and has horizontal displacement greater than vertical, When released, Then only that cell's **row** shifts one cell in the swipe direction and `MOVES` increases by 1.
* **AC3** — Given a vertical swipe on a cell that exceeds the threshold with vertical dominance, When released, Then only that cell's **column** shifts one cell and `MOVES` increases by 1.
* **AC4** — Given a swipe below the minimum threshold, When released, Then no shift occurs and `MOVES` is unchanged.
* **AC5** — Given an animation in progress (150–250 ms), When another swipe is attempted, Then it is ignored and **not queued**.
* **AC6** — Given all 3 undos are used, When Undo is tapped again, Then nothing happens and no purchase or ad prompt appears.
* **AC7** — Given the player taps Restart, When pressed, Then the grid resets, `MOVES = 0`, undos return to 3, with **no confirmation dialog**; Restart is positioned away from the grid.
* **AC8** — Given the target word forms, When the move settles, Then input locks, the winning row highlights, a short success animation plays, and the completion panel opens.
* **AC9** — Given a swipe begins, When the gesture is recognized, Then the affected row or column receives a light visual highlight.
* **AC10** — Given an in-progress puzzle and the player leaves (back to menu, app backgrounded, or OS kill), When they return via CONTINUE / relaunch, Then the grid, `MOVES`, undos remaining, restart count, and elapsed time are exactly restored (via the F08 active-session snapshot).
* **AC11** — Given the target word forms only transiently during an animation, When the move has not yet settled, Then no win is triggered; win is evaluated on the settled state only.

---

## 4. Edge Cases

* Diagonal swipe with near-equal axes → dominant axis wins; a small tie band favors horizontal (final band value tuned on device).
* Swipe starting on the grid but ending off-screen → resolves on release from the last known position.
* Multi-touch / two-finger gestures → honor only the first touch.
* Rapid repeated valid swipes on the same row → each counts, but only after the previous animation settles.
* App backgrounded mid-swipe or mid-animation → resolve to a consistent **settled** state on return; never a half-applied move.
* Undo tapped during the success animation → disallowed (input is locked).
* Undo with no move history → no-op.
* Fast flick vs slow drag → both resolve to exactly one cell.
* Device rotation attempt → app stays portrait-locked.
* Restart tapped during an animation → the animation resolves to a settled state, then the restart applies (or is ignored during the lock — see architecture).
* A move that the engine rejects (fully immovable line, column moves disabled, out of range) → no shift, `MOVES` unchanged, no error surfaced to the player.

---

## 5. Non-Goals (owned elsewhere)

* Puzzle content / optimal-move values — F06.
* Star rating, "Perfect" flag, personal best, the full completion panel (stars / optimal / best / Retry / Next Level) — F04. F03 ships a **minimal functional completion panel** as a seam.
* Journey level list, unlock, CONTINUE target resolution, per-level micro-tutorials — F05.
* Daily puzzle selection, streak, daily result submission — F07 / F08.
* Onboarding tutorial overlay / arrow prompts — F09.
* Sound effects and haptics — F11.
* Analytics events (`level_started`, `move_performed`, `undo_used`, `restart_used`, `level_completed`, …) — F12 (F03 exposes the state changes they derive from).
* Persistence storage mechanism, migrations, sync — F08 (F03 serializes into F08's locked snapshot shape).

---

## 6. Constraints (from the product PRD)

* **Animation:** grid shift 150–250 ms; input **locked** for its full duration; **no input queue**.
* **Latency:** gesture-release → animation-start imperceptible (target < 50 ms).
* **Frame rate:** smooth on mid-tier devices; the solver never runs on device (it doesn't here at all).
* **One-handed portrait:** portrait-locked; the grid occupies ~85–90 % of screen width; cell hitboxes ≥ 44×44 pt.
* **Accessibility:** no information by color alone (win highlight must have a non-color cue); high-contrast text; OS text scaling respected; fully playable with sound + haptics off.
* **Honest moves:** a minimum gesture threshold so accidental touches are never counted; rejected/settled distinction is strict — only settled moves count.
* **Localization:** `MOVES` and all user-facing strings externalized.

---

## 7. Success Metrics (from the product PRD)

* Median session 2–5 minutes.
* **0 double-registered moves during animation** in QA.
* Gesture recognition ≥ target accuracy on the device matrix.
* (Downstream, not F03-gated) Level 5 Reach > 60 %, D1 > 35 %, D7 > 15 % — F03 is the interaction substrate for these.

---

## 8. Dependencies

* **F02 grid-engine** (`Done`, contract locked) — `GridEngine` / `EngineConfig` / `Move` / `GridStep` / `GridState`; the shift/undo/restart/win/thaw semantics.
* **F08 offline-persistence-and-sync** (`In Release`, contract locked) — the `kv['active_session']` snapshot contract (frozen keys), `ActiveSessionRepo`, the restore path, `toEngineConfig(Puzzle)`, `ElapsedTimer`. F08's parked deploy does **not** block F03: the persistence layer + snapshot restore are on-device and fully functional without the Firebase deploy.
* **F01 dictionary-service** (`Done`) — via the engine's `WordValidator` adapter.
* **F06 puzzle-content-and-solver-tooling** (`Done`, toolchain) — the `Puzzle` model + the 5-puzzle smoke set for playable QA content; the full 30-level set (`F06-CONTENT`) is a separate follow-on and is **not** required for F03 QA (the smoke set suffices).
