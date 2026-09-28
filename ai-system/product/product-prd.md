# LOOPLET — Product PRD

Last Updated: 2026-09-29 (revision PO-REV-2026-09-29-F05-CONTINUE — see Revision Log)
Status: LIVE (Bootstrap by Product Owner)
Authoritative Source: `/LOOPLET Product Definition Document` (user-provided) — this PRD is the derived, execution-ready translation.

---

# 1. Product Overview

LOOPLET is a single-player mobile **word-based puzzle game** for iOS and Android (portrait only).

The player is shown a 5×5 grid of letters and a **visible target word**. They do not type, guess, or receive Wordle-style feedback. Instead they **slide whole rows and columns** (circular / wrap-around, one cell per move) until the target word appears horizontally, left-to-right, in a single row.

The core problem it solves: deliver a 2–5 minute puzzle session that combines **word knowledge + spatial reasoning + minimum-move optimization**, and creates a self-sustaining replay loop where players re-attempt a solved puzzle to beat their move count.

Primary language is Turkish; the architecture must be localization-ready (English next).

This is explicitly **not** a word game in the Wordle sense — it is a word-based logic puzzle. That distinction is a hard product constraint.

---

# 2. Business Goals

* Validate that the core puzzle loop (solve → see result → "I can do this in fewer moves" → retry) retains players without content volume or monetization.
* Hit the MVP validation gate: D1 ≥ 35%, D7 ≥ 15%, Tutorial Completion ≥ 85%, Level 5 Reach ≥ 60%.
* Establish a deterministic, solver-verified puzzle production pipeline so future content scales cheaply.
* Ship a localization-ready, offline-first architecture that a future account/leaderboard/duel layer can adopt without destructive migration.

Beklenen çıktı:

* A shippable single-player MVP (30 Journey levels + Daily Challenge) instrumented well enough to make a data-driven expand/iterate decision per Section 52 of the source document.
* Evidence (retention + activation KPIs) that the core loop is intrinsically motivating.

---

# 3. Target Users

## 3.1 Primary Users

* Casual puzzle and word-game players, age 16+.
* Turkish-speaking players at launch; English-speaking players in a later language pack.
* Players who enjoy "easy to learn, hard to master" optimization puzzles and short daily habits.

## 3.2 User Needs

* Understand the core mechanic within the first 30 seconds, with no long text tutorial.
* Complete a satisfying puzzle in 2–5 minutes, one-handed, in portrait.
* Get a clear, fair performance signal (stars vs. optimal) that makes "do it better" tempting.
* A single fresh puzzle each day and a streak worth protecting.
* Never lose progress; play the campaign fully offline.
* Play without relying on sound or color (accessibility).

---

# 4. Core Capabilities

* Deterministic 5×5 letter-grid model with circular row shift (left/right) and column shift (up/down); 1 cell = 1 move.
* Always-visible 5-letter target word; win = target formed in any row, left-to-right, contiguous, correct order.
* Move counter, 3 free undos per puzzle, unlimited restart.
* Pre-computed optimal-move value per puzzle and a 1–3 star rating (never 0).
* Per-level personal best and a "Perfect" (== optimal) flag.
* Journey mode: 30 handcrafted, linearly unlocked levels with a defined difficulty curve.
* Locked Tile (fixed pivot) and Frozen Tile (thaws when a valid ≥4-letter Turkish word forms in its row) mechanics.
* Daily Challenge: one shared puzzle per calendar day per language, local-midnight reset, move-count scoring, streak, spoiler-free share.
* Interactive 3-step onboarding tutorial (< 60s), gated on the player performing each move.
* Local persistence + offline play + deferred sync of offline daily results.
* Curated Turkish dictionary with Turkish-locale case handling.
* Internal authoring toolchain: level editor + solver (provable minimum moves) + solvability/difficulty verification + export.
* Required analytics event stream for KPI computation.
* SFX and haptics with independent on/off toggles.

---

# 5. High-Level User Flows

## 5.1 First Session (New Player)

1. App open → tutorial starts automatically.
2. Tutorial 1: "Slide the row" — arrow shown, advances only on the correct swipe.
3. Tutorial 2: "Slide the column" — same gating.
4. Tutorial 3: "Form the target word in one row" — completes when the target row is formed.
5. Player is dropped directly into Journey Level 1.
6. Player completes a few levels; completion panel shows stars vs optimal after each.

## 5.2 Solve → Retry Loop (North Star)

1. Player opens a level via CONTINUE.
2. Player swipes rows/columns; MOVES counter increments per settled move.
3. Target word forms → input locks → winning row highlights → success animation → completion panel.
4. Panel shows: target word, player moves, optimal moves, stars, personal best, Retry, Next Level.
5. Player taps Retry to beat their move count, or Next Level to progress.

## 5.3 Daily Challenge

1. From main menu, player taps DAILY.
2. Today's puzzle (local date, active language) loads; if never fetched and offline, a "needs connection" state is shown.
3. Player solves with unlimited moves, 3 undos, unlimited restart.
4. First completed run today is recorded as the official result; streak +1.
5. Completion panel shows move count, duration, stars, current + best streak, and Share Result.
6. Share opens the OS share sheet with a spoiler-free card (no grid, no target word).
7. Replays are allowed for personal improvement but do not change the official result or streak.

## 5.4 Resume After Interruption

1. Player backgrounds or kills the app mid-puzzle.
2. On relaunch, the active puzzle is restored exactly: grid, move count, undo history, thawed frozen tiles, elapsed time.

## 5.5 Puzzle Authoring (Internal)

1. Designer sets target word, builds initial grid, marks locked/frozen tiles in the level editor.
2. Designer runs the solver → gets provable minimum move count + solvability result.
3. Editor computes a difficulty score and Easy/Medium/Hard/Expert label.
4. Designer playtests with real engine rules.
5. Designer exports the puzzle definition + metadata (optimal moves required). Unsolvable or optimal-less puzzles cannot be published.

---

# 6. Feature List

| ID | Feature Name | Description | Priority | Dependency | User Value | Success Metric |
| -- | ------------ | ----------- | -------- | ---------- | ---------- | -------------- |
| F01 | dictionary-service | Curated Turkish dictionary, Turkish-locale case normalization (İ/I distinct), word validation behind a language key; exclusion rules (proper nouns, profanity, abbreviations, archaic). | P0 | None | Guarantees real, appropriate words for target selection and frozen-tile thaw; correct Turkish handling. | 100% of shipped target words + frozen-break checks resolve correctly; 0 invalid-word acceptances and 0 valid-word rejections across the QA word set. |
| F02 | grid-engine | Deterministic 5×5 grid model: circular row/column shift, 1 cell = 1 move, move counter, left-to-right win detection, locked tile (fixed pivot), frozen tile (thaws on valid ≥4-letter row word), undo primitive, restart-to-initial. No runtime randomness. | P0 | F01 | The core manipulation that defines the game. | Identical (initial grid + move sequence) → identical end state 100% of runs; win/locked/frozen behavior matches the spec matrix 100%. |
| F03 | puzzle-play-session | The in-game screen: target word display (separated from grid), swipe→move (dominant axis, min threshold, accidental-touch rejection), 150–250ms animation with input lock and no queue, MOVES HUD, Undo (3 free), Restart (physically separated, no confirm), row/column swipe feedback, completion sequence. | P0 | F02 | Lets the player actually play a puzzle intuitively, one-handed. | Median session 2–5 min; 0 double-registered moves during animation in QA; gesture recognition ≥ target accuracy on device matrix. |
| F04 | star-rating-and-personal-best | 1–3 star rating (3=optimal/"Perfect", 2=optimal+1..+3, 1=optimal+4+, never 0); completion panel (target word, player moves, optimal, stars, personal best, Retry, Next Level); per-level best move count that only improves. | P1 | F03, F06 | Fair mastery feedback that motivates replay. | Replay Rate > 20%. |
| F05 | journey-progression | 30 handcrafted sequential levels, linear unlock by completion (stars not gating), difficulty curve per source §20, per-level micro-tutorials at levels 4–6, CONTINUE resumes current level, journey progress display. | P0 | F03, F06 | A clear, gently ramping single-player campaign. | Level 5 Reach > 60%; D1 > 35%; D7 > 15%. |
| F06 | puzzle-content-and-solver-tooling | Internal level editor + build-time solver computing provable minimum moves over {row L/R, col U/D} honoring locked/frozen; solvability check, difficulty score + Easy/Medium/Hard/Expert label, playtest, export with required metadata. Produces the 30 Journey levels + Daily pool. Unsolvable / optimal-less puzzles cannot publish. | P0 | F01, F02 | Guarantees every shipped puzzle is deterministic, solvable, and fairly rated. | 100% of shipped puzzles solver-verified with a stored optimal; solver returns provably minimum on the 5×5 test set within the authoring time budget. |
| F07 | daily-challenge | One shared puzzle per calendar day per language, local-midnight reset; 5×5 / 5-letter / unlimited moves / 3 undos / unlimited restart; move-count score (time tie-break); first completed run is official; streak (+1 per day, reset on miss), current + best streak. Leaderboard-ready data model, no leaderboard in MVP. | P1 | F03, F04, F06, F08 | A daily reason to return and a streak worth protecting. | Daily Completion Rate > 65%. |
| F08 | offline-persistence-and-sync | Local persistence of active puzzle (grid, moves, undo history, thawed tiles, elapsed time, puzzle ID), journey progress, personal bests, daily first-run results, streak, settings; full offline Journey; offline Daily if pre-fetched; deferred sync of offline daily results with first-run-authoritative reconciliation; guest-only, account-adoptable schema. | P0 | None (F02 for state shape) | Never lose progress; play anywhere. | 0 progress-loss incidents across the QA kill/relaunch/offline matrix; offline daily results sync exactly once. |
| F09 | onboarding-tutorial | Interactive 3-step tutorial (row shift / column shift / form target in a row), each step gated on the correct player action, arrow animations, < 60s, flows directly into Level 1, shown once. | P1 | F03 | Learn the game in the first 30 seconds with zero reading. | Tutorial Completion Rate > 85%. |
| F10 | main-menu-and-settings | Main screen: LOOPLET logo, CONTINUE (primary), DAILY (secondary), Journey Progress, Daily Streak, Settings icon. Settings: Sound Effects On/Off, Haptics On/Off. No Shop/Battle Pass/Clan/Events. Accessibility baseline (no color-only info, high contrast, scalable UI, one-handed portrait). | P1 | F05, F07 | One-tap entry to play; at-a-glance momentum. | Crash-free navigation ≥ 99.5%; CONTINUE/DAILY reachable one-handed on the device matrix. |
| F11 | audio-and-haptics | SFX (tile move, frozen break, puzzle complete, perfect solution, button) and haptics (light move / medium frozen break / success completion), each respecting its settings toggle; no background music; game fully completable with both off. | P2 | F03, F10 | Responsive, satisfying feedback without being required. | Correct cue on the correct event 100% in QA; toggles honored 100%; game completable with audio+haptics off. |
| F12 | analytics-instrumentation | Emit all required events with exact properties (app_open, tutorial_started/completed, level_started, move_performed, undo_used, restart_used, level_completed, daily_started, daily_completed, daily_shared, app_backgrounded); offline buffering + exactly-once flush; anonymous guest id; KPI set computable. | P1 | F03, F05, F07, F09, F13 | (System) The measurement basis for the MVP validation gate. | Event delivery ≥ 99%; property-schema conformance 100%; all Section 41 KPIs computable from the stream. |
| F13 | daily-share | "Share Result" after daily completion → spoiler-free card (LOOPLET #N, stars, move count, streak, optional directional-arrow move sequence). No grid, no target word. OS native share sheet. Reflects the official first run. | P2 | F07 | A safe way to compare and spread the daily without spoilers. | Daily Share Rate > 5% (strong > 10%); 0 spoiler leaks (grid/target/letters) in shared content across QA. |

---

# 6.1 Feature Details

## dictionary-service (F01)

### Tip

> Infrastructure

### System Requirements

* The system must validate a candidate word against a curated, language-scoped dictionary so that only real, allowed words gate frozen-tile thawing and target-word selection.
* The system must normalize case using Turkish locale rules (İ↔i, I↔ı; Ç/Ğ/Ö/Ş/Ü preserved) so that lookups are correct for Turkish, treating İ and I as distinct letters.
* The system must exclude proper nouns, profanity/slurs, abbreviations, and (by default) archaic words so that content suits a 16+ casual audience.
* The system must expose the dictionary behind a language key so that English and further languages can be added without changes to consuming features.

### Acceptance Criteria

* Given a normalized 4-letter Turkish word present in the curated list, When validation is requested, Then it returns valid.
* Given the strings "İL" and "IL", When each is normalized and looked up, Then they resolve to distinct entries (not merged).
* Given a proper noun or a profanity-list entry, When validation is requested, Then it returns invalid even if otherwise well-formed.
* Given `language = en` is active, When validation is requested, Then only the English dictionary is consulted.
* Given a word shorter than the configured minimum (4 for frozen break), When validation is requested, Then it returns invalid by the length rule.
* Given the MVP target-word list, When reviewed, Then every entry is a common, manually-approved Turkish word.

### Edge Cases

* All-caps grid letters vs mixed-case dictionary storage.
* Words containing multiple Turkish diacritics (e.g., "şöyle").
* Dictionary asset missing or corrupt at startup → fail safe: treat as "no valid words", log, do not crash.
* Homographs differing only by İ/I or by a diacritic.
* Hyphenated / space-containing candidate strings → rejected.
* Memory footprint of the full word list on low-end devices.

### Notes

* MVP target-word list and the frozen-break validation list are the same curated dictionary; both manually reviewed.
* Consumers: F02 (frozen break), F06 (solver/content validation). F13 (share) must never call this to render words.
* Dictionary ships as a versioned asset; never generated at runtime.

---

## grid-engine (F02)

### Tip

> Infrastructure

### System Requirements

* The system must represent a 5×5 grid of single letters with no empty cells, and apply a single-cell circular shift to a chosen row (left/right) or column (up/down) as exactly one move.
* The system must increment the move counter by exactly 1 per applied shift and stop counting the instant the win condition is satisfied.
* The system must detect a win when the target word appears in any row, left-to-right, contiguous, in exact order (reverse, vertical, and diagonal arrangements do not win).
* The system must hold a locked tile fixed in place while the other cells of its row/column rotate circularly around it.
* The system must keep a frozen tile immovable until a valid ≥4-letter contiguous left-to-right dictionary word exists in that tile's row, then convert it permanently to a normal tile for the remainder of the session.
* The system must provide an undo primitive that reverts exactly the last applied move and the counter, and a restart operation that returns the grid to the authored initial state with moves = 0.
* The system must never invoke randomness; identical (initial grid + move sequence) must always yield an identical state.

### Acceptance Criteria

* Given row `A B C D E`, When shifted right once, Then it becomes `E A B C D` and moves increases by 1.
* Given row `A B C D E`, When shifted left once, Then it becomes `B C D E A`.
* Given column `A / B / C / D / E`, When shifted down once, Then it becomes `E / A / B / C / D`.
* Given target `MASAL` and a row that settles as `M A S A L`, When the shift settles, Then a win is detected and the counter freezes.
* Given a row that settles as `L A S A M`, or a column reading `M A S A L`, When evaluated, Then no win is detected.
* Given a locked tile at index 2 of row `A B [C] D E`, When the row is shifted right, Then `C` stays at index 2 and `A B D E` rotate around it.
* Given a frozen tile in a row, When a valid ≥4-letter word forms contiguously left-to-right in that row, Then the tile thaws and remains normal for the rest of the session.
* Given 5 applied moves then one undo, When state is read, Then it equals the post-4-move state and moves = 4.
* Given any mid-game state, When restart is invoked, Then grid == initial and moves == 0.

### Edge Cases

* Shift requested on a fully-locked row/column → no-op, not counted as a move.
* Frozen tile and locked tile in the same row/column.
* Two frozen tiles in one row thawed by a single valid word.
* A valid word forming transiently during animation → win/thaw evaluated only on the settled state.
* Target word with repeated letters (`MASAL` has two `A`) → matching is positional, not set-based.
* Undo with no move history → no-op.
* Undo after win (input locked) → disallowed.
* A frozen-tile row forming a word that also equals the target word → resolve as a win.
* Wrap-around correctness at both ends of a row/column.

### Notes

* Engine is headless and testable independently of rendering and of the UI.
* Depends on F01 for thaw validation.
* The "3 undos" allowance is enforced by F03; the engine only exposes the undo/restore primitive and full session history.

---

## puzzle-play-session (F03)

### Tip

> User-Facing

### User Stories

* As a player, I want to swipe a row or column and watch it slide one cell, so that I can manipulate the grid intuitively with one hand.
* As a player, I want the target word always visible and clearly separated from the grid, so that I always know my goal.
* As a player, I want a live MOVES counter, so that I can judge my efficiency in real time.
* As a player, I want up to 3 undos and a restart, so that I can recover from mistakes without starting over blindly.
* As a player, I want accidental taps and tiny drags ignored, so that my move count stays honest.

### Acceptance Criteria

* Given the puzzle screen opens, When rendered, Then the target word, grid, `MOVES: 0`, Undo (3 available), and Restart are shown, and the target word is visually separated from the grid.
* Given a horizontal swipe that starts on a cell, exceeds the minimum threshold, and has horizontal displacement greater than vertical, When released, Then only that cell's row shifts one cell in the swipe direction and MOVES increases by 1.
* Given a vertical swipe on a cell that exceeds the threshold with vertical dominance, When released, Then only that cell's column shifts one cell and MOVES increases by 1.
* Given a swipe below the minimum threshold, When released, Then no shift occurs and MOVES is unchanged.
* Given an animation in progress (150–250ms), When another swipe is attempted, Then it is ignored and not queued.
* Given all 3 undos are used, When Undo is tapped again, Then nothing happens and no purchase or ad prompt appears.
* Given the player taps Restart, When pressed, Then the grid resets, MOVES = 0, undos return to 3, with no confirmation dialog; Restart is positioned away from the grid.
* Given the target word forms, When the move settles, Then input locks, the winning row highlights, a short success animation plays, and the completion panel opens.
* Given a swipe begins, When the gesture is recognized, Then the affected row or column receives a light visual highlight.

### Edge Cases

* Diagonal swipe with near-equal axes → dominant axis wins; define tie behavior (favor horizontal, or ignore within a small angle band).
* Swipe starting on the grid but ending off-screen.
* Multi-touch / two-finger gestures → honor only the first touch.
* Rapid repeated valid swipes on the same row → each counts, but only after the previous animation settles.
* App backgrounded mid-swipe or mid-animation → resolve to a consistent settled state on return.
* Undo tapped during the success animation → disallowed.
* Fast flick vs slow drag → both resolve to exactly one cell.
* Device rotation attempt → app stays portrait-locked.
* Restart tapped during an animation.

### Notes

* Animation is 150–250ms; input is locked for its duration; there is no input queue.
* All user-facing strings are externalized for localization.
* Completion visuals here are functional (input lock depends on settle), not "cosmetic polish".

---

## star-rating-and-personal-best (F04)

### Tip

> User-Facing

### User Stories

* As a player, I want a 1–3 star rating on completion, so that I know how close I got to optimal.
* As a player, I want to see optimal vs my moves and my personal best side by side, so that I'm motivated to retry.
* As a player, I want a "Perfect" marker when I hit optimal, so that true mastery feels rewarded.

### Acceptance Criteria

* Given optimal = 6 and player = 6, When completed, Then 3 stars are awarded and "Perfect" is recorded.
* Given optimal = 6 and player between 7 and 9 inclusive, When completed, Then 2 stars are awarded.
* Given optimal = 6 and player ≥ 10, When completed, Then 1 star is awarded.
* Given any completion, When rated, Then stars ≥ 1 (never 0).
* Given a prior personal best of 7 and a new result of 9, When completed, Then the personal best stays 7.
* Given a prior best of 7 and a new result of 5, When completed, Then the personal best updates to 5, and "Perfect" is set if 5 == optimal.
* Given the completion panel, When shown, Then it displays target word, player moves, optimal moves, stars, personal best, Retry, and Next Level.
* Given no prior best exists, When the level is completed for the first time, Then the personal best is set to the current result.

### Edge Cases

* Completion via an undo-heavy path → the counted result is the net move count after undos.
* Daily completions → rating is shown, but only the first run persists to best/score (see F07).
* Optimal metadata missing → the puzzle should never have shipped (F06 gate); defensively, block rating and log.
* Player result exactly optimal + 3 → 2 stars (upper boundary inclusive).
* Player result exactly optimal + 4 → 1 star (lower boundary).

### Notes

* "Perfect" is defined as solving in exactly the optimal move count (equivalently, 3 stars).
* Depends on F06 for the stored optimal value.

---

## journey-progression (F05)

### Tip

> User-Facing

### User Stories

* As a player, I want 30 sequential levels that unlock as I finish them, so that I always have a clear next step.
* As a player, I want difficulty to ramp gently and introduce one new idea at a time, so that I'm never lost.
* As a player, I want CONTINUE to drop me straight into my current level, so that resuming takes one tap.

### Acceptance Criteria

* Given level N is completed with any star count, When the completion panel closes, Then level N+1 is unlocked.
* Given level N is not completed, When the player attempts to open level N+1, Then it is unavailable.
* Given levels 1–3, When played, Then column moves are disabled and only row shifts are available; optimal is 2 moves. (Corrected 2026-09-13, Tech Lead + user decision, `f05 architecture.md §5.4`: `3–4` is unachievable for a rows-only 5×5 with a 5-letter target — the provable minimum is `min(k, 5-k) ≤ 2` for any single-row cyclic rotation.)
* Given the player first enters the levels 4–6 band, When the level loads, Then a short column-shift tutorial is shown and column shifts become available.
* Given levels 7–10, When played, Then rows and columns are both available with optimal 4–6.
* Given levels 11–15 / 16–20 / 21–25 / 26–30, When played, Then respectively: heavier temporary-displacement puzzles / locked tiles / frozen tiles / locked+frozen combos, matching the source §20 curve.
* Given an in-progress level, When CONTINUE is tapped, Then that level resumes at its saved state. This includes a replay of an already-completed level, and it applies even when all 30 levels are complete. *(Revised 2026-09-29, PO-REV-2026-09-29-F05-CONTINUE.)*
* Given all 30 levels are complete and no Journey level is in progress, When CONTINUE is tapped, Then a graceful "all levels complete" state is shown with no crash. *(Revised 2026-09-29, PO-REV-2026-09-29-F05-CONTINUE: the state applies only when no level is in progress.)*

### Edge Cases

* Stars never gate progression — 1★ still unlocks the next level.
* Replaying a completed level cannot re-lock it or reduce progress.
* All 30 levels complete and a replay left unfinished → CONTINUE resumes the replay; progress still reads 30 / 30. CONTINUE never silently discards a level in progress. *(Added 2026-09-29, PO-REV-2026-09-29-F05-CONTINUE.)*
* Corrupt or missing level asset → skip with a logged error; the rest of the Journey stays playable.
* Player force-quits during the level-4 column tutorial → it re-shows on return until acknowledged.
* Fewer than 30 levels present in a build → caught by a build gate; runtime still shows accurate progress.

### Notes

* The 30 handcrafted levels and their difficulty labels are produced via F06.
* Per-level micro-tutorials (columns at level 4) belong to this feature and are distinct from onboarding (F09).
* A full level-select map screen beyond CONTINUE + a progress indicator is a Future Consideration.

---

## puzzle-content-and-solver-tooling (F06)

### Tip

> Infrastructure

### System Requirements

* The system must provide a solver that computes the provable minimum number of moves from an initial grid to any winning state, over actions {row left, row right, column up, column down} each costing 1, honoring locked and frozen tiles, so that every puzzle has a trustworthy optimal-move value.
* The system must provide an internal level editor to set target word, initial grid, locked cells, and frozen cells; run the solver; verify solvability; compute a difficulty score and an Easy/Medium/Hard/Expert label; playtest with real engine rules; and export a puzzle definition with required metadata.
* The system must refuse to export or publish any puzzle the solver cannot solve, or any puzzle lacking an optimal-move value.
* The system must bias grid letter distribution toward Turkish letter frequency and reduce misleading nonsense strings, without requiring every row to be a real word.
* The system must produce the 30 Journey levels and the Daily puzzle pool as versioned content artifacts.

### Acceptance Criteria

* Given an initial grid and target, When the solver runs, Then it returns a move count that no shorter solution can beat, verified against exhaustive search on the test set.
* Given a puzzle with locked and/or frozen tiles, When solved, Then the solution respects immovability and thaw rules.
* Given an unsolvable configuration, When export is attempted, Then export is blocked with a clear reason.
* Given a puzzle without an optimal-move value, When publish is attempted, Then it is rejected.
* Given the difficulty parameters (optimal count, misleading intermediate states, required temporary displacement, locked count, frozen count, number of plausible routes), When computed, Then a numeric score and a label are produced.
* Given a puzzle in the editor, When "playtest" is chosen, Then it is playable under the exact engine rules that ship.

### Edge Cases

* State-space blow-up with multiple frozen tiles (branching on thaw order) → solver must still terminate with a proven minimum, or mark the puzzle "needs review".
* Target word reachable in multiple rows → solver takes the cheapest.
* Puzzle already solved at t = 0 (optimal 0) → rejected as trivial by content rules.
* Highly symmetric grids with many equal-cost solutions → reflected in the "plausible routes" metric.
* Solver time budget exceeded → the puzzle is not shipped with an unverified optimal.
* Daily pool must not duplicate Journey puzzles or repeat within a defined rolling window.

### Notes

* The solver runs only at authoring/build time — never on device.
* Solver algorithm (BFS / bidirectional BFS / IDA* / pattern database) is a Tech Lead decision; the requirement is provable minimality on the 5×5 space.
* Export format feeds F05 (Journey) and F07 (Daily); its schema must match F08 persistence expectations.
* Editor delivery form (standalone tool vs in-app debug mode vs script pipeline) is a Tech Lead decision.

---

## daily-challenge (F07)

### Tip

> User-Facing

### User Stories

* As a player, I want one shared daily puzzle that resets at my local midnight, so that I have a fresh reason to return each day.
* As a player, I want the daily scored by move count with time as the tie-break, so that efficiency is what matters.
* As a player, I want a streak that grows each day I complete and resets if I miss one, so that I'm motivated to keep the habit.
* As a player, I want to replay the daily to improve, without it changing my official result.

### Acceptance Criteria

* Given the local date rolls to a new calendar day at 00:00, When the player opens DAILY, Then the new day's puzzle for the active language is shown.
* Given two players on the same language and date, When each opens DAILY, Then they receive the identical puzzle.
* Given the daily rules, When playing, Then the grid is 5×5, the target is 5 letters, moves are unlimited, undos are 3, and restart is unlimited.
* Given the player completes the daily for the first time today, When it finishes, Then move count, duration, and completion timestamp are recorded as the official result and the streak increments by 1.
* Given the player replays the same daily, When they finish again, Then the official result and streak are unchanged and the new attempt is stored only for personal comparison.
* Given the player missed the previous day's daily, When they complete today's, Then the current streak becomes 1 and the best streak is preserved.
* Given completion, When the panel shows, Then Current Streak and Best Streak are visible, along with Share Result.

### Edge Cases

* Player starts the daily before local midnight and finishes after → result attributed to the puzzle in play at start; behavior stated explicitly to the player-facing team.
* Device clock or timezone change while travelling → streak-integrity handling (see Open Questions).
* First launch of the day, offline, with no cached daily → show a "needs connection" state; Journey remains playable.
* Daily completed offline → result queued, streak updated locally, synced later; server reconciliation uses the first completed run.
* DST transition day (23- or 25-hour day).
* Player completes the daily, then reinstalls the same day (guest, local storage cleared) → treated as a new guest; accepted MVP limitation.
* Leap day and year boundary.

### Notes

* The data model stores move count + duration + timestamp per player per daily so a leaderboard can be added later; no leaderboard ships in MVP.
* Depends on F06 (content), F08 (fetch/cache/sync), F03/F04 (play + rating).

---

## offline-persistence-and-sync (F08)

### Tip

> Infrastructure

### System Requirements

* The system must persist the active puzzle state (current grid, move count, undo history, thawed frozen tiles, elapsed time, puzzle ID) on every state change, so that the player resumes exactly where they left off after background, kill, or relaunch.
* The system must persist journey progress, per-level personal bests, daily first-run results, daily streak, and settings locally.
* The system must allow the entire Journey to be played with no network connection.
* The system must allow the Daily to be played offline when its puzzle was previously fetched, and must queue offline daily results for sync when connectivity returns.
* The system must operate guest-only (no login) while structuring stored data so a future account can adopt it without a destructive migration.
* The system must reconcile synced daily results using the player's first completed run as authoritative.

### Acceptance Criteria

* Given a puzzle in progress, When the app is killed and relaunched, Then grid, move count, undo history, thawed tiles, and elapsed time are exactly restored.
* Given no network, When the player plays Journey, Then all levels load and progress saves.
* Given a previously fetched daily and no network, When the player opens DAILY, Then it is playable.
* Given an offline daily completion, When connectivity returns, Then the result is sent exactly once with no duplicate.
* Given the server already holds a first-run result for that player and daily, When an offline run syncs, Then the earlier first run remains authoritative.
* Given `app_backgrounded` fires, When it occurs, Then current state is already durably written (no data-loss window).

### Edge Cases

* Storage full / write failure → non-destructive error; keep the last good state.
* Corrupt save file on launch → fall back to the last valid checkpoint or a clean state without crashing; log.
* Schema version upgrade between app releases → migrate forward; never lose bests or streak.
* Clock change affecting elapsed-time measurement → use a monotonic timer, not wall clock.
* Concurrent writes (autosave + explicit action).
* Partial sync (network drops mid-request) → idempotent retry.
* Future multi-device use → the model must not hard-assume a single device.

### Notes

* No account or cloud save in MVP; the architecture assumes both later (source §39).
* The backend surface for sync is minimal and is defined by the Tech Lead.

---

## onboarding-tutorial (F09)

### Tip

> User-Facing

### User Stories

* As a new player, I want a short interactive tutorial that makes me perform each move myself, so that I understand the game within the first 30 seconds.
* As a new player, I want to go straight into Level 1 afterward, so that there is no friction.

### Acceptance Criteria

* Given a first-time player, When the app starts, Then Tutorial 1 ("Slide the row") is shown with an arrow animation and does not advance until the correct swipe is performed.
* Given Tutorial 1 is complete, When it advances, Then Tutorial 2 ("Slide the column") is shown with the same gating.
* Given Tutorial 2 is complete, When it advances, Then Tutorial 3 ("Form the target word in one row") is shown and completes only when the target row is formed.
* Given Tutorial 3 completes, When it ends, Then the player is taken directly into Level 1.
* Given the tutorial at its intended pace, When measured end to end, Then it is completable in under 60 seconds.
* Given a returning player who finished the tutorial, When the app starts, Then the tutorial is not shown again.

### Edge Cases

* Player performs the wrong-direction swipe → the step does not advance; the hint is re-emphasized.
* Player backgrounds the app mid-tutorial → resumes at the same step.
* Player reaches Level 1 via debug/deep link without the tutorial → the completion flag is still respected.
* Instructions must not rely on color alone.
* Very slow or very fast players → no time-based failure; gating is action-based only.

### Notes

* Emits `tutorial_started` / `tutorial_completed` (KPI gate: > 85% completion).
* Distinct from the per-level micro-tutorials in F05.
* Re-accessing the tutorial from settings is a Future Consideration, not MVP.

---

## main-menu-and-settings (F10)

### Tip

> User-Facing

### User Stories

* As a player, I want a simple home screen with CONTINUE and DAILY, so that I can get into play in one tap.
* As a player, I want to see my journey progress and daily streak at a glance, so that I feel momentum.
* As a player, I want to toggle sound and haptics, so that I can play the way I like.

### Acceptance Criteria

* Given the main menu, When shown, Then it displays the LOOPLET logo, CONTINUE (primary), DAILY (secondary), Journey Progress, Daily Streak, and a Settings icon — and does not display Shop, Battle Pass, Clan, or Events.
* Given CONTINUE is tapped, When resolved, Then the player lands on their current or next Journey level.
* Given DAILY is tapped, When resolved, Then the player lands on today's daily, or a "needs connection" state if it is unavailable.
* Given Settings is opened, When shown, Then Sound Effects On/Off and Haptics On/Off toggles are present and persist across sessions.
* Given the game is played entirely with sound off and haptics off, When any puzzle is attempted, Then it remains completable.
* Given OS-level text scaling is increased, When screens render, Then text stays readable and key actions are not clipped.

### Edge Cases

* No journey progress yet (brand new, tutorial not done) → CONTINUE routes into the tutorial / Level 1.
* Streak = 0 → show a neutral state, not an error.
* Daily already completed today → DAILY still opens (replay allowed) and shows a completed state.
* Very small devices → CONTINUE and DAILY stay within one-handed reach.
* Settings changed mid-game → applies immediately.

### Notes

* The accessibility baseline lives here: high-contrast text, scalable UI, no color-only information, one-handed portrait.
* Surfaces state owned by F05 and F07.

---

## audio-and-haptics (F11)

### Tip

> User-Facing

### User Stories

* As a player, I want subtle sound and haptic feedback on moves and key moments, so that the game feels responsive and satisfying.
* As a player, I want to turn either off independently, so that I can play silently or without vibration.

### Acceptance Criteria

* Given sound is on, When a tile moves / a frozen tile breaks / a puzzle completes / a perfect solution is achieved / a button is pressed, Then the corresponding SFX plays.
* Given haptics is on and the device supports it, When a tile moves, Then a light haptic fires; when a frozen tile breaks, a medium haptic; when a puzzle completes, a success haptic.
* Given sound is off, When any of those events occur, Then no SFX plays.
* Given haptics is off, When any of those events occur, Then no haptic fires.
* Given a device with no haptic engine, When haptic events occur, Then the game behaves normally with no error.
* Given no background music ships, When playing, Then the absence of BGM is expected behavior.

### Edge Cases

* Rapid consecutive moves → SFX/haptics must not stack into noise; throttle.
* OS mute switch / silent mode → respect platform conventions.
* Audio focus loss (incoming call, other app audio) → pause or duck gracefully.
* Perfect + complete occur together → play the perfect cue, not both stacked.
* Toggling a setting mid-animation.

### Notes

* The SFX set is fixed per source §34; background music is out of MVP.
* Depends on F03 (event sources) and F10 (toggles).

---

## analytics-instrumentation (F12)

### Tip

> Infrastructure

### System Requirements

* The system must emit every required event with its exact properties: `app_open`; `tutorial_started`; `tutorial_completed`; `level_started` (level_id, target_word, optimal_moves); `move_performed` (level_id, move_number, direction, row_or_column_index); `undo_used`; `restart_used`; `level_completed` (level_id, moves, optimal_moves, stars, duration, restart_count, undo_count); `daily_started`; `daily_completed` (daily_id, moves, optimal_moves, duration, attempt_number, streak); `daily_shared`; `app_backgrounded`.
* The system must buffer events while offline and flush them reliably when connectivity returns, with no loss and no duplication.
* The system must attach a stable anonymous guest identifier to events without requiring login.
* The system must allow the KPI set (tutorial completion, Level 5 reach, D1/D7 retention, daily completion, replay, daily share) to be computed from the emitted events.

### Acceptance Criteria

* Given each defined in-game trigger point, When it occurs, Then exactly one event with the specified name and property schema is emitted.
* Given the app is offline, When events are generated, Then they are stored and later delivered exactly once each.
* Given `level_completed`, When emitted, Then it carries moves, optimal_moves, stars, duration, restart_count, and undo_count.
* Given `daily_completed`, When emitted, Then it carries attempt_number (1 for the first run) and the current streak.
* Given a full first session, When events are inspected, Then tutorial completion rate and Level 5 reach are derivable.
* Given a user in a tracking-restricted state, When events fire, Then handling complies with platform policy (consent model is an Open Question).

### Edge Cases

* Event generated during a crash/kill → best-effort persistence before exit.
* Clock skew affecting duration/session attribution → use monotonic timing for durations.
* Duplicate suppression across an app restart that interrupts a flush.
* Schema drift between app versions → versioned event payloads.
* High-frequency `move_performed` events → batch without dropping.
* Backgrounding immediately after an event fires.

### Notes

* Cross-cutting: instrumented incrementally as F03–F13 land, with a final schema-conformance pass before release.
* Completeness and accuracy of this feature are release-blocking because it is the measurement basis for the Section 52 validation gate.
* Analytics platform and consent handling are Tech Lead decisions.

---

## daily-share (F13)

### Tip

> User-Facing

### User Stories

* As a player who finished the daily, I want to share a spoiler-free result card, so that I can compare with friends without ruining the puzzle for them.

### Acceptance Criteria

* Given a completed daily, When the completion panel shows, Then a "Share Result" action is available.
* Given "Share Result" is tapped, When the content is generated, Then it contains the puzzle number (e.g., `LOOPLET #143`), star rating, move count, and current streak — and does not contain the grid or the target word.
* Given move-sequence arrows are included, When rendered, Then they are directional glyphs only (⬅️ ⬆️ ➡️ ⬇️) with no letters or positions that reveal the solution.
* Given "Share Result" is tapped, When invoked, Then the OS native share sheet opens with the generated text.
* Given the daily was replayed, When sharing, Then the shared result reflects the official first run.

### Edge Cases

* Sharing attempted before completion → the action is not available.
* Very long move sequences → truncate or summarize the arrows so the path is not meaningfully reconstructable.
* Localization of `MOVES`, `LOOPLET #N`, and label formatting per language.
* Share cancelled by the user → no error; emit `daily_shared` only on successful invocation (subject to platform capability).
* Emoji rendering differences across platforms.

### Notes

* Spoiler safety is the primary acceptance concern for this feature.
* Emits `daily_shared` (F12). Depends on F07.

---

# 7. MVP Scope

All of F01–F13 are in the MVP. The source document's Section 42 scope maps to these features 1:1:

* F01 dictionary-service — Turkish dictionary + Turkish character support + localization-ready architecture.
* F02 grid-engine — 5×5 grid, horizontal + vertical movement, circular shift, 5-letter target, target visible, move counter, Locked Tile, Frozen Tile, undo/restart primitives.
* F03 puzzle-play-session — the playable screen, swipe input, animation/input-lock, MOVES, 3 Undo, Restart.
* F04 star-rating-and-personal-best — 3-star rating, Personal Best, completion panel.
* F05 journey-progression — Journey with 30 handcrafted levels, difficulty curve.
* F06 puzzle-content-and-solver-tooling — optimal-move calculation, solver, level authoring (mandatory production pipeline).
* F07 daily-challenge — Daily Challenge + Daily streak.
* F08 offline-persistence-and-sync — local persistence + offline support.
* F09 onboarding-tutorial — interactive tutorial.
* F10 main-menu-and-settings — main menu, settings, accessibility baseline.
* F11 audio-and-haptics — sound + haptics.
* F12 analytics-instrumentation — basic analytics.
* F13 daily-share — Daily sharing.

Priority within the MVP:

* **P0 (core playable loop, build first):** F01, F02, F06, F08, F03, F05.
* **P1 (required for the validation launch):** F04, F09, F10, F07, F12.
* **P2 (ships with the MVP, sequenced last):** F11, F13.

Explicitly **out of MVP** (from source §43 — held as Future Considerations, not backlog):

* multiplayer, PvP, leaderboard, clans, chat, friends
* battle pass, cosmetics, shop, rewarded ads, interstitial ads, subscriptions
* user-generated levels, infinite procedural levels
* account system, cloud save, push notifications
* achievements, tournaments, portals, bombs, timed levels

Also out of MVP (deferred by the source document):

* Undo purchase / rewarded-ad Undo (source §15 — deferred to a later version).
* Global leaderboard (source §27 — data model is prepared, feature is not built).
* Phase 2 mechanics: Portal Tile, One-Way Tile, Move-Limited Puzzle, Multi-target Puzzle (source §44).
* Phase 3: Duel / asynchronous duel (source §45).
* Level-select map screen beyond CONTINUE + progress indicator.
* Re-accessible tutorial from settings.

---

# 8. Non-Functional Expectations

* **Performans:** Grid shift animation 150–250ms at a smooth frame rate on mid-tier devices; input latency from gesture-release to animation-start is imperceptible (target < 50ms); cold start under ~3s; puzzle load is instant (local content); the solver never runs on device.
* **Determinizm:** No runtime randomness in gameplay; identical (initial grid + move sequence) always yields an identical state; no letter generation during play.
* **Güvenlik / Gizlilik:** Guest-only, no login, no PII beyond an anonymous analytics guest id; compliant with App Store / Google Play privacy and tracking-consent policies; no pay-to-win now or later (a future monetization layer must not sell skill-based success).
* **Ölçeklenebilirlik:** Single-player; backend footprint limited to daily-puzzle distribution, analytics ingestion, and an offline-result sync endpoint; data model and endpoints designed so a future leaderboard, account, and cloud save can be added without destructive migration.
* **Kullanılabilirlik / Erişilebilirlik:** One-handed portrait play; grid occupies ~85–90% of screen width; cell hitboxes ≥ 44×44 pt; no information conveyed by color alone; high-contrast text; OS text scaling respected; game fully completable with sound and haptics off; minimum gesture threshold so accidental touches are not counted as moves.
* **Offline:** Journey fully playable offline; Daily playable offline when pre-fetched; offline daily results queued and synced exactly once on reconnect.
* **Localization:** All user-facing strings externalized; no hard-coded copy; dictionary swappable per language key; Turkish-locale case rules (İ/I distinct); RTL not required for MVP.
* **Dayanıklılık:** Active puzzle state written durably on every change; crash/kill-safe resume; forward-compatible persistence schema.
* **Animasyon kısıtı:** Animation ≤ 250ms, input locked during animation, no input queue.

---

# 9. Risks / Dependencies

* **Solver optimality & performance (F06):** the star rating is only fair if the stored optimal is a proven minimum. Locked + multiple frozen tiles expand the state space and the branching (thaw order); proving minimality within an acceptable authoring time budget is a real technical risk. → Owner: Tech Lead.
* **Difficulty-curve tuning (F05/F06):** 30 handcrafted levels must land the source §20 curve. This is manual, playtest-heavy work and it directly drives the Level 5 Reach and retention KPIs.
* **Turkish dictionary curation (F01):** excluding proper nouns, profanity, abbreviations, and archaic words is manual review effort; frozen-tile UX quality depends on it.
* **Local-timezone daily reset (F07):** clock manipulation, DST, and travel across midnight create streak-integrity edge cases.
* **Gesture recognition across devices (F03):** dominant-axis + threshold tuning must be right on a wide device range; a single accidental counted move erodes trust in the core promise ("every move must matter").
* **Analytics completeness is the validation gate (F12):** if instrumentation is incomplete or inaccurate, the Section 52 expand/iterate decision is compromised. Treated as release-blocking.
* **No monetization in MVP:** there is no revenue signal; validation is retention-only (accepted per source §51).
* **Forward-compatible persistence (F08):** schema must anticipate future account sync (source §39) without over-building it now.
* **Content pipeline is a hard dependency:** no F05 and no F07 without F06 output. F06 must be usable early.

---

# 10. Assumptions

* The MVP backend responsibility set is: (a) daily-puzzle distribution, (b) analytics ingestion, (c) an offline-daily-result sync endpoint. Everything else runs on-device. Stack choice is the Tech Lead's.
* Daily puzzles are pre-generated in batches by the internal tooling (F06) and distributed as static, versioned content — not generated server-side on demand.
* "Same daily for all players in the same language" means the daily pool is keyed by (calendar date, language); a device's local date selects the active daily.
* Elapsed and completion time are measured on-device with a monotonic clock and used only for tie-break and share output, not anti-cheat, in the MVP.
* "3 Undos" means 3 undo *actions* per puzzle attempt, not a 3-deep history; the engine keeps full session history for restore.
* "Perfect" == solved in exactly the optimal move count == 3 stars.
* Frozen-tile thaw is evaluated on the frozen tile's **row only** (source §22: "bulunduğu satırda"), left-to-right, contiguous, minimum 4 letters; once thawed it stays a normal tile for the rest of the session and that state is persisted.
* A locked tile is a grid coordinate that never moves; shifts on its row/column rotate the remaining non-locked cells circularly around it.
* The model permits multiple locked tiles in one row/column; level design controls whether that is used.
* Target word length is always 5 in the MVP; the frozen-break minimum word length is 4; both draw from the same curated dictionary.
* Journey level *completion* (not star count) unlocks the next level; replaying never re-locks.
* DAILY is available from first launch if a bundled/cached daily exists; otherwise it shows a "needs connection" state while Journey stays playable.
* Share uses the OS native share sheet; there is no custom share backend.
* No push notifications in the MVP (source §43); streaks are still tracked, just not reminded.
* The onboarding tutorial runs once; completion is persisted; it is not re-accessible from settings in the MVP.
* The analytics identifier is an anonymous, locally generated guest id, acceptable under store privacy policy without login.
* The main menu has CONTINUE + a journey progress indicator; a full level-select map is not built for the MVP.

---

# 11. Open Questions

* Solver algorithm and the acceptable per-puzzle authoring time budget; how minimality is proven with locked + multiple frozen tiles (BFS vs bidirectional BFS vs IDA* / pattern DB).
  → Owner: Tech Lead
* Backend footprint: static CDN + serverless ingest vs a managed BaaS; where and how offline daily results reconcile server-side.
  → Owner: Tech Lead
* Client stack: native (Swift + Kotlin) vs cross-platform (Flutter / React Native) vs Unity. The product is a light-animation portrait puzzle; Unity may be more than needed.
  → Owner: Tech Lead
* Analytics platform and tracking-consent / ATT handling per store.
  → Owner: Tech Lead
* Local persistence technology (SQLite / key-value / files) and the schema-migration strategy for future account adoption.
  → Owner: Tech Lead
* Level editor delivery form: standalone desktop tool, in-app debug mode, or a scripted pipeline.
  → Owner: Tech Lead
* Daily timezone integrity: how device clock changes / travel across midnight mid-run affect the streak, and whether any server-side check is in scope for the MVP.
  → Owner: Tech Lead
* Diagonal-swipe tie handling: favor horizontal, or ignore within a small angle band?
  → Owner: Tech Lead (with UI Designer)
* Does a Journey level completed at 1★ still show "Next Level"?
  → Decision: yes — completion alone unlocks and advances (source §19).
* Does frozen-tile thaw also consider the column?
  → Decision: no — row only, contiguous, left-to-right, ≥ 4 letters (source §22).
* Which date does a daily run started before midnight and finished after belong to?
  → Owner: Tech Lead (with Product Owner) — proposed: the puzzle in play at start.

---

# 12. Tech Preferences & Constraints

* **Platform:** iOS + Android, portrait only, phone-first (one-handed reach).
* **Dil / Framework tercihi:** Tech Lead belirleyecek. The source document does not mandate a stack; it describes a light-animation word-logic puzzle. Note: a `Game Developer (Unity)` role exists in this system, but the source does not require Unity — the choice is open.
* **Entegrasyonlar:** OS native share sheet; OS haptics APIs; an analytics SDK (TBD); a lightweight content-distribution endpoint for Daily puzzles; an offline-result sync endpoint. No third-party auth in the MVP.
* **Deployment / Hosting / CI-CD tercihi:** Tech Lead belirleyecek — App Store + Google Play distribution; daily-puzzle content hosting and analytics ingestion hosting are undecided.
* **Ölçek / Performans kısıtı:** 150–250ms shift animation with input lock and no input queue; cell hitboxes ≥ 44×44 pt; grid uses ~85–90% of screen width; the solver must never run on device; the full Journey must be playable offline.
* **Güvenlik kısıtı:** no login and no PII in the MVP; guest-only local storage; anonymous analytics id; store privacy compliance; no pay-to-win ever — a future monetization layer must not sell skill-based success (source §51).

---

# 13. Delivery Note for Tech Lead

* **What this system is:** a single-player, offline-first mobile puzzle. Runtime is a deterministic finite-state machine over a 5×5 grid (shift actions, locked/frozen tile rules, win detection). There is no real-time, no multiplayer, and no auth in the MVP. The only backend surfaces are daily-puzzle distribution, analytics ingestion, and offline-daily-result sync.
* **Critical decision areas:**
  * Solver design and proof-of-minimality strategy for locked + frozen state spaces, plus its authoring-time budget (F06). This gates content and the fairness of the star rating.
  * Client stack (native vs cross-platform vs Unity) — the source leaves this open.
  * Persistence layer + forward-compatible schema for future account sync (F08, source §39).
  * Analytics platform + consent model (F12) — release-blocking for the validation gate.
  * Backend shape for daily distribution + sync (F07/F08), designed leaderboard-ready but leaderboard-free.
* **System-level risks:** solver optimality/performance; difficulty-curve tuning of 30 handcrafted levels; Turkish dictionary curation quality; daily timezone/streak integrity; gesture-recognition consistency across devices; analytics completeness.
* **Platform decision ownership:** the platform choice is left to the Tech Lead; `platform.md` is produced from this PRD and Section 12. `Game Developer (Unity)` replaces `Frontend/Mobile Developer` only if `platform.md` sets the client stack to Unity.
* **Build order note:** F06 (tooling/solver) is a P0 dependency for F05 and F07 and should be usable early, even though it is Infrastructure and not player-visible.

---

# 14. Success Metrics

* **F09 onboarding-tutorial:** Tutorial Completion Rate > 85% (validation gate).
* **F05 journey-progression:** Level 5 Reach Rate (first session) > 60% (validation gate); D1 Retention > 35% (gate; strong ≥ 40%); D7 Retention > 15% (gate; strong ≥ 20%).
* **F04 star-rating-and-personal-best:** Replay Rate (retry after completion) > 20%.
* **F07 daily-challenge:** Daily Completion Rate (of players who start it) > 65%.
* **F13 daily-share:** Daily Share Rate (of daily completers) > 5% (strong ≥ 10%).
* **F02 grid-engine:** 100% determinism across the QA replay matrix; win/locked/frozen behavior matches the spec matrix 100%.
* **F06 puzzle-content-and-solver-tooling:** 100% of shipped puzzles solver-verified with a stored proven optimal; 0 shippable puzzles without an optimal value.
* **F01 dictionary-service:** 0 invalid-word acceptances and 0 valid-word rejections across the curated QA word set.
* **F12 analytics-instrumentation:** event delivery ≥ 99%; property-schema conformance 100%; all Section 41 KPIs computable from the stream.
* **F08 offline-persistence-and-sync:** 0 progress-loss incidents across the QA kill/relaunch/offline matrix.
* **Product validation gate (source §52):** D1 ≥ 35% AND D7 ≥ 15% AND Tutorial Completion ≥ 85% AND Level 5 Reach ≥ 60%. Below any of these → analyze the core loop (control feel, puzzle readability, difficulty, session length, replay motivation) before starting new content production.
* **North Star (source §53):** the player solves a puzzle, sees the result, thinks "I can do this in fewer moves," and retries.

---

# 15. Domain Model (PO-Level)

## Core Entities

### Puzzle

* id: unique identifier
* language: language key (e.g., `tr`, `en`)
* type: `journey` or `daily`
* journeyLevelNumber: 1–30, present for `journey`
* dailyDate: calendar date, present for `daily`
* gridWidth / gridHeight: 5 / 5 for the MVP
* initialGrid: the authored 5×5 letters
* targetWord: the 5-letter goal word (always shown to the player)
* lockedCells: coordinates that never move
* frozenCells: coordinates that are immovable until their row forms a valid ≥4-letter word
* optimalMoves: pre-computed proven minimum move count (required to publish)
* difficultyScore: numeric score from the source §48 parameters
* difficultyLabel: Easy / Medium / Hard / Expert
* columnMovesEnabled: false for levels 1–3, otherwise true
* contentVersion: version of the content artifact this puzzle came from

### GridState (runtime)

* cells: current 5×5 letters
* tileStatus per cell: `normal` / `locked` / `frozen` / `thawed`
* Not part of the authored Puzzle; derived during play.

### Move

* direction: `left` / `right` / `up` / `down`
* axis: `row` or `column`
* axisIndex: 0–4
* moveNumber: 1-based sequence number within the attempt

### PlaySession

* puzzleId
* currentGrid
* moveCount
* undoHistory: ordered record sufficient to revert moves
* undosRemaining: starts at 3
* restartCount
* elapsedTimeMs
* thawedFrozenCells
* status: `in_progress` / `completed`
* startedAt

### LevelResult / PersonalBest

* levelId
* bestMoveCount: only decreases
* stars: 1–3
* isPerfect: bestMoveCount == optimalMoves
* firstCompletedAt

### JourneyProgress

* highestUnlockedLevel
* completedLevels

### DailyEntry

* dailyDate
* firstRunMoveCount
* firstRunDurationMs
* firstRunStars
* firstRunCompletedAt
* attempts: list of later replay results (personal only)
* syncStatus: `local` / `queued` / `synced`

### DailyStreak

* currentStreak
* bestStreak
* lastCompletedDate

### Settings

* soundEnabled
* hapticsEnabled
* language

### Player (guest)

* guestId: anonymous, locally generated
* createdAt
* (structured so a future account can adopt this record without a destructive migration)

### DictionaryEntry

* word: normalized form
* language
* isEligibleTarget: passes the curated-target review
* flags: excluded / archaic / etc.

---

# 16. Core Domain Events

* `PUZZLE_STARTED` — a puzzle attempt begins (Journey level or Daily).
* `MOVE_APPLIED` — a row/column shift settles and the move counter increments.
* `MOVE_UNDONE` — the last move and the counter are reverted; an undo is consumed.
* `PUZZLE_RESTARTED` — grid returns to initial, moves to 0, undos to 3.
* `FROZEN_TILE_THAWED` — a valid ≥4-letter word formed in a frozen tile's row; it becomes normal.
* `TARGET_WORD_FORMED` — the target word appears in a row, left-to-right, contiguous, in order.
* `PUZZLE_COMPLETED` — win state reached; input locks and the counter freezes.
* `STARS_AWARDED` — a 1–3 star rating is computed from moves vs optimal.
* `PERSONAL_BEST_UPDATED` — a level's best move count improves.
* `LEVEL_UNLOCKED` — completing level N makes level N+1 available.
* `TUTORIAL_STARTED` — the interactive onboarding begins.
* `TUTORIAL_COMPLETED` — all three tutorial steps are done; the player enters Level 1.
* `DAILY_PUZZLE_FETCHED` — a new daily puzzle is retrieved and cached for a date/language.
* `DAILY_FIRST_RUN_RECORDED` — the first completed daily run of the day becomes the official result.
* `DAILY_STREAK_INCREMENTED` — a daily completion extends the current streak.
* `DAILY_STREAK_RESET` — a missed day resets the current streak (best streak preserved).
* `DAILY_RESULT_SHARED` — a spoiler-free result card is sent to the OS share sheet.
* `OFFLINE_RESULT_SYNCED` — a queued offline daily result is delivered exactly once and reconciled.
* `GAME_STATE_PERSISTED` — active session state is durably written locally.
* `GAME_STATE_RESTORED` — a saved session is restored exactly on relaunch.
* `SETTINGS_UPDATED` — a sound or haptics toggle changes.

---

# Revision Log

## PO-REV-2026-09-29-F05-CONTINUE

* **Date / authority:** 2026-09-29, Product Owner — Revise mode, on the user's decision F05.D3-N1-REPLAY-PRECEDENCE (option A, chosen by the user in chat, recorded in F05 `orchestration.md`).
* **Changed requirement:** CONTINUE precedence after all 30 Journey levels are complete. When all 30 are complete and a replay of a completed level is in progress, CONTINUE resumes that replay at its saved state (the in-progress AC). The graceful "all levels complete" state applies only when no Journey level is in progress. Progress stays 30 / 30.
* **Why:** the two ACs overlapped with no stated precedence. The shipped behaviour (a Tech Lead assumption of 2026-09-27) let the terminal state win and silently superseded an unfinished replay. The user chose that the one "continue" action never discards a half-played puzzle.
* **Changed sections:** §6.1 journey-progression (F05) — Acceptance Criteria (the in-progress AC and the all-complete AC), Edge Cases (one added). No other section changes: the §5.4 resume flow already states exact restore, and no feature, dependency, priority, MVP scope, metric or domain object changes.
* **Affected features:** F05 (Blocked in Design Adoption Phase D3; its Home CONTINUE rule, contract F05 `architecture.md` §18.3 (2), and feature PRD AC7 / AC9 need the Tech Lead resync).
* **Not affected (checked):** F10's "CONTINUE lands on the current or next Journey level" AC is consistent (a replay in progress is the current level); F09's new-player routing, F03's resume (§5.4) and F08's snapshot restore are unchanged; no dependency chain changes.

