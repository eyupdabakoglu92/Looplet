# F05 — journey-progression: Feature PRD

> Derived from `product/product-prd.md` → "journey-progression (F05)" + the F05 row in §6.1 + §5.1/§5.2 (user flows) + §15 (`JourneyProgress`) + §41 KPIs. Scope-specific; the product PRD remains the source of truth.

---

## 1. Summary

F05 turns the isolated F03 play session into a **campaign**: 30 handcrafted, linearly-unlocked Journey levels with a gently ramping difficulty curve, a per-level micro-tutorial for the column mechanic (levels 4–6), a one-tap **CONTINUE** that drops the player straight into their current level, and an at-a-glance journey-progress display. Completing level N (at **any** star count) unlocks level N+1; replaying never re-locks.

F05 is the main single-player progression and the home of the **Level 5 Reach / D1 / D7** retention KPIs. It consumes F03 (the play screen + `PlaySessionArgs.journeyLevel` + the completion panel), F04 (the completion panel's `Next Level` CTA + the win path), F06 (the `Puzzle` content format + the 30 authored levels), and F08 (the `journey_progress` table + `JourneyProgressRepo` + the active-session snapshot's `journeyLevel`).

F05 does **not** own: the play mechanic (F03), the star rating / completion panel content (F04), the puzzle content itself and the solver-verified `optimalMoves` (F06 + `F06-CONTENT`), the persistence mechanism (F08), the onboarding tutorial that runs before Level 1 (F09), the main menu shell / settings (F10), audio/haptics (F11), analytics events (F12).

---

## 2. User Stories

* As a player, I want 30 sequential levels that unlock as I finish them, so that I always have a clear next step.
* As a player, I want difficulty to ramp gently and introduce one new idea at a time, so that I'm never lost.
* As a player, I want CONTINUE to drop me straight into my current level, so that resuming takes one tap.
* As a player, I want to see how far through the Journey I am, so that I feel momentum.

---

## 3. Acceptance Criteria

* **AC1** — Given level N is completed with **any** star count, When the completion panel closes (via `Next Level` or `Close`), Then level N+1 is unlocked.
* **AC2** — Given level N is not completed, When the player attempts to open level N+1, Then it is unavailable (no navigation, a clear locked affordance).
* **AC3** — Given levels **1–3**, When played, Then column moves are disabled and only row shifts are available; optimal is 2 moves. *(Resynced 2026-09-26 by the Tech Lead to the authoritative `product-prd.md` AC, which was corrected 2026-09-13 on the user's decision — `3–4` is unachievable for a rows-only 5×5 with a 5-letter target; see §6 below and `architecture.md §5.4`. Derived-copy sync only; no semantic change.)*
* **AC4** — Given the player **first** enters the **4–6** band, When the level loads, Then a short column-shift micro-tutorial is shown and column shifts become available.
* **AC5** — Given levels **7–10**, When played, Then rows and columns are both available with optimal 4–6.
* **AC6** — Given levels **11–15 / 16–20 / 21–25 / 26–30**, When played, Then respectively: heavier temporary-displacement / locked tiles / frozen tiles / locked+frozen combos, matching the difficulty curve.
* **AC7** — Given an in-progress level, When **CONTINUE** is tapped, Then that level resumes at its **saved state** (grid, moves, undo history, thawed tiles, elapsed time — via the F08 restore path).
* **AC8** — Given no in-progress level, When **CONTINUE** is tapped, Then the player lands on their **lowest un-completed unlocked level** (Level 1 for a brand-new player, subject to F09 — see §5).
* **AC9** — Given all 30 levels are complete, When CONTINUE is tapped, Then a graceful "**all levels complete**" state is shown with no crash.
* **AC10** — Given the Journey, When shown, Then a **progress indicator** (e.g. "12 / 30" + completed/unlocked state) is visible and accurate.
* **AC11** — Given the player force-quits during the 4–6 column micro-tutorial, When they return, Then it **re-shows** until acknowledged.
* **AC12** — Given `Next Level` on the F04 completion panel of level N (N < 30), When tapped, Then the player navigates to level N+1's play session; Given N == 30, Then it routes to the "all levels complete" state.
* **AC13** — Given a Journey level completed at 1★, When the completion panel is shown, Then `Next Level` is available (stars never gate — resolves the product PRD open question §... "Does a Journey level completed at 1★ still show Next Level?" → **yes**).
* **AC14** — Given no network, When the player plays any Journey level, Then it loads from bundled content and progress saves locally (full offline Journey — F08 guarantee).

---

## 4. Edge Cases

* **Stars never gate progression** — 1★ still unlocks the next level (AC13).
* **Replaying a completed level** cannot re-lock it or reduce progress (`JourneyProgressRepo.markCompleted` is idempotent for progress).
* **Corrupt or missing level asset** → skip with a logged error; the rest of the Journey stays playable (do not crash the whole campaign).
* **Fewer than 30 levels present in a build** → caught by a build gate (content-manifest check, extends F06's `check`); runtime still shows accurate progress against whatever is present.
* **Player at level 30, not complete** → `Next Level` on level 29's panel goes to 30; level 30's `Next Level` → the "all complete" state.
* **CONTINUE with a stale F08 snapshot for a level the player has since restarted from elsewhere** → the snapshot is authoritative for *that* `journeyLevel`; F08's restore path already re-derives from `appliedMoves`.
* **The 4–6 micro-tutorial** is per-band, shown once, acknowledged flag persisted (survives force-quit until acknowledged — AC11).
* **F09 interaction (brand-new player)** — the onboarding tutorial (F09) runs before Level 1; F05's CONTINUE for a player with no progress and no tutorial-done flag routes into F09 / Level 1 (exact hand-off is a `[PENDING — F09]` seam; F09 is `Not Started`).

---

## 5. Non-Goals (owned elsewhere)

* The play mechanic, gesture handling, MOVES/Undo/Restart, the win moment — **F03**.
* The star rating, the completion-panel content (target word / moves / optimal / stars / best / Retry / Next Level) — **F04**. F05 only supplies the **`Next Level` handler** (the `[PENDING — F05]` seam) + the post-completion unlock write.
* The puzzle content — the 30 authored Journey levels, their grids / targets / locked / frozen / `optimalMoves` / difficulty labels — **F06 + `F06-CONTENT`** (the Level-Designer follow-on). F05 defines/consumes the **bundled manifest format** and resolves a `Puzzle` by level number.
* The persistence mechanism — the `journey_progress` table + `JourneyProgressRepo` + the active-session snapshot — **F08** (already built).
* The pre-Level-1 onboarding tutorial (row / column / form-target, gated) — **F09**.
* The main menu shell (LOOPLET logo, DAILY, Settings icon, layout) — **F10**. F05 ships a **minimal** CONTINUE + progress surface now; F10 absorbs / re-homes it. A full level-select map is a **Future Consideration**, not MVP (product PRD §... "a full level-select map screen beyond CONTINUE + a progress indicator is a Future Consideration").
* Audio / haptics — **F11**. Analytics (`level_started` / `level_completed` with the journey level number) — **F12**.

---

## 6. Constraints (from the product PRD)

* Linear unlock: completing level N unlocks N+1; **stars do not gate**; replaying never re-locks.
* The 30 levels + their difficulty labels are produced via **F06** (`F06-CONTENT`). The difficulty-curve bands (1–3 rows-only, `optimalMoves == 2` — corrected 2026-09-13, `3–4` was unachievable for a rows-only 5-letter 5×5; 4–6 column intro; 7–10 rows+cols opt 4–6; 11–15 temp-displacement; 16–20 locked; 21–25 frozen; 26–30 locked+frozen) must be landed by the authored content — see `architecture.md §5.4` for the locked spec and `f06 content-authoring-brief.md §4` for the shipped `2026.09-v1` pack's actual per-band values.
* Per-level micro-tutorials (the column intro at 4–6) belong to F05 and are **distinct** from onboarding (F09).
* The full Journey must be **playable offline** (bundled content; F08 local persistence).
* The **solver never runs on device** — every level ships with a pre-computed `optimalMoves` (F06 gate).
* Portrait-locked; cell hitboxes ≥ 44×44 pt; the shift animation stays 150–250 ms with input lock and no queue (all inherited from F03).
* Localization-ready — any F05 UI strings externalized (same pattern as F03's `PlayStrings`).

---

## 7. Success Metrics (from the product PRD §41)

* **Level 5 Reach Rate (first session) > 60 %** — the validation gate. F05 owns the ramp that gets a new player to level 5.
* **D1 Retention > 35 %** (gate; strong ≥ 40 %).
* **D7 Retention > 15 %** (gate; strong ≥ 20 %).

These are post-launch analytics metrics (F12 + a distributed build) — not QA-verifiable in isolation, but they drive the difficulty-curve tuning in `F06-CONTENT` and the "one new idea at a time" pacing.

---

## 8. Dependencies

* **F03 puzzle-play-session** (`Done`) — the `/play` route, `PlaySessionScreen`, `PlaySessionArgs` (`source`, `journeyLevel`, `debugPuzzleId`), the `PlaySessionController` win path, the F08 restore path already wired in.
* **F04 star-rating-and-personal-best** (`Done`) — the real completion panel; its `CompletionPanel.onNextLevel` callback is the `[PENDING — F05]` seam F05 fills; F04's win path is where F05 hooks the `JourneyProgressRepo.markCompleted` write.
* **F06 puzzle-content-and-solver-tooling** (`Done`, toolchain) — the `looplet_content` `Puzzle` model + `Puzzle.fromJson` + `tools/looplet_authoring` `export`/`check` + `toEngineConfig` (built by F08). **`F06-CONTENT`** (the 30 authored Journey levels + a manifest) is an **open Level-Designer follow-on** — a hard prerequisite for F05 reaching `Done`. F05 builds and QAs against the 5-puzzle smoke set + a manifest; the full 30 land via `F06-CONTENT`.
* **F08 offline-persistence-and-sync** (`In Release` / parked, but its **on-device persistence is complete**) — `journey_progress` table (`highestUnlockedLevel`, `completedLevelsCsv`) + `JourneyProgressRepo` (`markCompleted` linear-unlock idempotent, `read` / `watch` / `completedLevels`) + `currentGuestIdProvider` + the active-session snapshot (`journeyLevel` key, restore path). F08's parked Firebase deploy is irrelevant — journey progress is on-device only.
* **F09 onboarding-tutorial** (`Not Started`) — runs before Level 1; the brand-new-player CONTINUE hand-off is a `[PENDING — F09]` seam.
* **F10 main-menu-and-settings** (`Not Started`) — will re-home F05's minimal CONTINUE/progress surface.
