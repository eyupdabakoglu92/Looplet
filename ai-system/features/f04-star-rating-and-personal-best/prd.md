# F04 — star-rating-and-personal-best: Feature PRD

> Derived from `product/product-prd.md` → "star-rating-and-personal-best (F04)" + the F04 row in §6 + §15 (`PersonalBest`) + §16/§20. Scope-specific; the product PRD remains the source of truth.

---

## 1. Summary

On puzzle completion, F04 rates the player's result against the solver-verified **optimal** move count: **1–3 stars** (3 = optimal and "Perfect"; 2 = optimal + 1..3; 1 = optimal + 4 or more; **never 0**). It shows the **real completion panel** — target word, player moves, optimal moves, stars, personal best, Retry, Next Level — replacing F03's minimal seam sheet. It persists a **per-level personal best move count that only improves** (monotone decrease), with the "Perfect" flag when the best equals optimal.

F04 is the mastery-feedback and replay hook. It consumes F03 (the play session + the win moment) and F06 (the stored `optimalMoves` on every puzzle artifact). Its persistence is **largely pre-built by F08** — the `personal_best` table + `PersonalBestRepo` (monotone `recordCompletion`, `isPerfect`, preserved `firstCompletedAtUtcMs`) already exist.

F04 does **not** own: the play mechanic (F03), puzzle content / the optimal value's derivation (F06), Journey progression / what "Next Level" actually navigates to (F05), the Daily's first-run-official scoring + streak (F07), audio/haptics on the star reveal (F11), analytics events (F12).

---

## 2. User Stories

* As a player, I want a 1–3 star rating on completion, so that I know how close I got to optimal.
* As a player, I want to see optimal vs my moves and my personal best side by side, so that I'm motivated to retry.
* As a player, I want a "Perfect" marker when I hit optimal, so that true mastery feels rewarded.
* As a player, I want to see when I've beaten my previous best, so that improvement feels recognized.

---

## 3. Acceptance Criteria

* **AC1** — Given optimal = 6 and player = 6, When completed, Then **3 stars** are awarded and **"Perfect" is recorded**.
* **AC2** — Given optimal = 6 and player between **7 and 9 inclusive**, When completed, Then **2 stars** are awarded.
* **AC3** — Given optimal = 6 and player **≥ 10**, When completed, Then **1 star** is awarded.
* **AC4** — Given any completion, When rated, Then **stars ≥ 1** (never 0).
* **AC5** — Given a prior personal best of 7 and a new result of 9, When completed, Then the personal best **stays 7**.
* **AC6** — Given a prior best of 7 and a new result of 5, When completed, Then the personal best **updates to 5**, and **"Perfect" is set if 5 == optimal**.
* **AC7** — Given the completion panel, When shown, Then it displays **target word, player moves, optimal moves, stars, personal best, Retry, and Next Level**.
* **AC8** — Given no prior best exists, When the level is completed for the first time, Then the personal best is **set to the current result**.

Boundary ACs (from the product PRD edge cases):

* **AC9** — Given player result **exactly optimal + 3**, When rated, Then **2 stars** (upper boundary inclusive).
* **AC10** — Given player result **exactly optimal + 4**, When rated, Then **1 star** (lower boundary).

---

## 4. Edge Cases

* Completion via an undo-heavy path → the counted result is the **net move count after undos** (F03 already reports `engine.moveCount`, which is exactly this — undo removes the move from history).
* **Daily** completions → the rating is **shown**, but only the first run persists to best/score (F07 owns Daily persistence). For F04's scope (only Journey/debug entries exist), the Daily branch is a `[PENDING — F07]` seam: compute + show stars, do **not** call `PersonalBestRepo.recordCompletion`.
* **Optimal metadata missing** → the puzzle should never have shipped (F06 `export`/`check` gate guarantees `optimalMoves`). Defensively: block rating (show the completion without stars) and log; never crash.
* Player result **exactly optimal + 3** → 2 stars (AC9). Player result **exactly optimal + 4** → 1 star (AC10).
* Replay after a "Perfect" → the best stays at optimal, still "Perfect"; the panel shows "Perfect" again (no regression, no "new best" banner since it didn't improve).
* A worse result after any best → best unchanged (AC5); the panel still shows the current-run stars for *this* attempt but the "personal best" line shows the retained better best.

---

## 5. Non-Goals (owned elsewhere)

* The play mechanic, the win detection, `engine.moveCount` — F03.
* The `optimalMoves` value and its solver derivation — F06.
* What **"Next Level"** navigates to (Journey advance, unlock) — F05. F04's panel exposes the button; its route is a `[PENDING — F05]` seam.
* Daily first-run-official scoring, streak, and Daily result persistence — F07.
* The `personal_best` table + `PersonalBestRepo` mechanism — F08 (already built).
* Audio / haptics on the star reveal — F11.
* Analytics (`level_completed` with stars/optimal/perfect) — F12.

---

## 6. Constraints (from the product PRD)

* Stars are **1–3, never 0** — a completion is always at least 1 star.
* "**Perfect**" ⇔ solved in exactly the optimal move count ⇔ 3 stars.
* Personal best is **per level** and **only improves** (monotone decrease of move count).
* The comparison (**your moves / optimal / best**) must be legible at a glance on the completion panel.
* The panel is a **premium reward-reveal surface** (`design-doctrine.md` — win/reward reveals are a named UI-Designer trigger). It rises over F03's dimmed board + amber seam bar — chrome/atmosphere parity with F03's `ui-design.md` Direction A.
* Localization-ready: all panel strings externalized (same pattern as F03's `PlayStrings`).

---

## 7. Success Metrics (from the product PRD)

* **Replay Rate > 20 %** — F04 is the primary replay hook (stars + "so close to Perfect" + a visible best to beat).

---

## 8. Dependencies

* **F03 puzzle-play-session** (`Done`) — the play session, the win moment, `engine.moveCount`, and the completion-panel seam (`app/lib/play/widgets/completion_sheet.dart`, explicitly "F04 seam"). F04 replaces the minimal sheet with the real panel and wires the star-rating into `PlaySessionController`'s win path.
* **F06 puzzle-content-and-solver-tooling** (`Done`) — the stored `optimalMoves` on every `Puzzle` artifact (guaranteed present by the `export`/`check` gate).
* **F08 offline-persistence-and-sync** (`In Release` / parked, but its **on-device persistence is complete**) — `personal_best` table + `PersonalBestRepo.recordCompletion(...)` (monotone, `isPerfect`, preserved `firstCompletedAtUtcMs`) + `currentGuestIdProvider`. F08's parked Firebase deploy is irrelevant — `personal_best` is on-device only.
* **F05 journey-progression** (`Not Started`) — the "Next Level" navigation target. F04 ships the button as a seam; the route is `[PENDING — F05]`.
