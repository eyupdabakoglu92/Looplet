# F04 — star-rating-and-personal-best: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In Progress — activated 2026-09-06 (after F03 → `Done`).** Initial contract (`architecture.md`) produced by the Tech Lead: substrate LOCKED — the pure `starsForResult` / `isPerfectResult` functions; the `CompletionResult` value object + `BestOutcome`; the win-path wiring into F03's `PlaySessionController` (additive, no F03 contract change); the real completion-panel contract (7 required elements + state variants); persistence via F08's existing `PersonalBestRepo` (no schema change); `Release Scope = none`. `[PENDING — UI]` (the panel handoff) + `[PENDING — F05]` (the "Next Level" route) + `[PENDING — F07]` (Daily persistence) enumerated in `architecture.md §13`. **Next: UI Designer** (`ui-design.md` — the reward-reveal completion panel).

---

## Current Owner

UI Designer

---

## Complexity Decision

* **NOT COMPLEX → no Technical Analyst.** Checked against the criteria:
  * Multiple services / >3 endpoints — **no** (client-only, zero backend, one panel).
  * Unclear acceptance criteria — **no** (8 crisp Given/When/Then ACs + 2 boundary ACs, straight from the product PRD; the star table is fully specified).
  * New entity / data model — **no** — F08 **already built** the `personal_best` table + `PersonalBestRepo` (monotone `recordCompletion`, `isPerfect`, preserved `firstCompletedAtUtcMs`). F04 adds a pure function + a value object + a panel.
  * Strong auth / permission layer — **no** (single actor).
  * Realtime / async / sync-conflict — **no** (a fire-and-forget local write; the repo is already monotone).
  * Cross-feature dependency on an *unfinished* contract — **no** — F03 (`Done`) already names F04 as the owner of the real panel (`f03 architecture.md §10`; `completion_sheet.dart` is an "F04 seam"); F06 (`Done`) guarantees `optimalMoves`; F08's persistence is complete. The `[PENDING — F05]` "Next Level" route is a clean seam, not a dependency on unfinished work.
  * State-machine conceptuality — **no** (the panel has state *variants* driven by one value object, not a machine).
  * Unsafe-assumption risk — **none** — every rule is specified in `prd.md` + `product-prd.md`.
* **UI Designer REQUIRED.** A **win / reward-reveal panel** is a named UI-Designer trigger (`design-doctrine.md`; the Tech Lead prompt's "Win/lose/reward reveal ekranı yeni tasarlanıyorsa"). Multiple distinct states (first clear / new best / matched / no improvement / Perfect), the star-reveal as a moment, CTA hierarchy, and chrome/atmosphere parity with F03's Direction A all need real UI/UX decisions. See `design/design-doctrine.md` + `design/premium-ui-rubric.md`.
* **DevOps/Release Engineer: NOT required.** `Release Scope = none` — client-only, no infra/CI/deploy change (`architecture.md §12`, `release.md §2`). CI gates still run.

---

## Active Task Ledger

- [x] Task ID: F04.CONTRACT-TL | Assigned Role: Tech Lead | Status: **Done (2026-09-06)** | `prd.md` + initial `architecture.md` produced. Substrate LOCKED (star function, `CompletionResult`, win-path wiring, panel contract, F08-persistence reuse, `Release Scope = none`). `[PENDING — UI]` / `[PENDING — F05]` / `[PENDING — F07]` enumerated (`architecture.md §13`). Complexity decided (not COMPLEX; UI Designer required; no DevOps). Routing set.
- [ ] Task ID: F04-UI | Assigned Role: UI Designer | Status: **Open — NEXT** | Produce `features/f04-star-rating-and-personal-best/ui-design.md` — the completion-panel handoff. Resolve `architecture.md §13 [PENDING — UI]`; parity with F03's `ui-design.md` Direction A (raised dark panel, scrim, amber accent, sits over the dimmed board + seam bar); the star-reveal as a bounded (≤ ~800 ms, deterministic) moment; distinct treatments for `firstClear` / `newBest` (celebratory) / `matchedBest` / `noImprovement` / `Perfect` / no-optimal; CTA hierarchy (Retry primary, Next Level secondary/disabled with a `[PENDING — F05]` affordance); "Perfect" + "New best!" markers (text + non-colour cue); accessibility (Semantics for the star count). No code. See the brief in `## Next Action`.
- [ ] Task ID: F04-FE1 | Assigned Role: Frontend/Mobile Developer | Status: Open (after F04-UI) | `app/lib/rating/star_rating.dart` — the pure `starsForResult` / `isPerfectResult` functions (never 0; upper boundary inclusive; defensive `player < optimal` → 3 + log). Unit-tested against the full AC1–AC4/AC9/AC10 table.
- [ ] Task ID: F04-FE2 | Assigned Role: Frontend/Mobile Developer | Status: Open | `app/lib/rating/completion_result.dart` — the `CompletionResult` value object + `BestOutcome` enum. `app/lib/rating/rating_providers.dart` — `personalBestRepoProvider` (F08), `currentGuestIdProvider` reuse, a `clock` seam.
- [ ] Task ID: F04-FE3 | Assigned Role: Frontend/Mobile Developer | Status: Open | Win-path wiring in `app/lib/play/play_session_controller.dart` (additive — no F03 contract change): on win, compute stars → (journey only) `PersonalBestRepo.recordCompletion(...)` fire-and-forget with a caught failure → read-back → build `CompletionResult` → expose `CompletionResult? get completion` + `notifyListeners()`. Daily → skip the write (`ratingPersisted = false`, `[PENDING — F07]`). No-optimal → skip rating, log `rating_blocked_no_optimal`, bare completion.
- [ ] Task ID: F04-FE4 | Assigned Role: Frontend/Mobile Developer | Status: Open | `app/lib/rating/completion_panel.dart` — replaces `app/lib/play/widgets/completion_sheet.dart`; renders all 7 `architecture.md §7` elements + the state variants + the bounded star-reveal; `Retry` → `retryFromCompletion()`; `Next Level` inert/disabled (`[PENDING — F05]`); `Semantics` for the star count. `play_session_screen.dart` swaps in the F04 panel. Extend `PlayStrings` or add `RatingStrings` (Frontend's call). Follows `ui-design.md`.
- [ ] Task ID: F04-FE5 | Assigned Role: Frontend/Mobile Developer | Status: Open | Tests: `star_rating_test.dart` (the full boundary table); `personal_best_flow_test.dart` (against the real F08 `PersonalBestRepo` + an in-memory DB — first clear / worse / better / matched / Perfect-replay); an F04 widget test (solve `smoke-tr-01` in 1 → 3 stars + Perfect + first-clear best; Retry → matched; the panel's 7 elements + `Next Level` disabled + `Semantics`). `analyze` + `format:check` clean; full `flutter test` green (no regression to the 308); iOS release build green. Append `frontend.md`.
- [ ] Task ID: F04-QA1…QAn | Assigned Role: QA | Status: Open (after Frontend) | End-to-end **client** QA per `architecture.md §11` — `automated functional` mandatory (star boundaries; personal-best logic against the real repo; panel-state matrix; F03 integration); `ui-design.md` alignment (chrome parity, reward-reveal is a moment, CTA hierarchy, `premium-ui-rubric.md`). `runtime` (device) for the reveal *feel* + panel visuals → foldable into F03's already-accepted first-app-distribution device smoke. Security compliance N/A (single actor, local-only `personal_best`, no endpoint — justify).

---

## QA Scope

* **[LOCKED]** (see `architecture.md §11`). End-to-end **client** feature. Evidence class: `automated functional` **mandatory** (the pure star function; the personal-best logic against F08's real `PersonalBestRepo` + an in-memory DB; the panel-state matrix; the F03 win-path integration) + `ui-design.md` alignment (chrome/atmosphere parity with F03 Direction A; the reward-reveal is a genuine moment; CTA hierarchy; `premium-ui-rubric.md` fail conditions). `runtime` (device) for the reveal *feel* + panel visuals — **foldable into F03's already-accepted first-app-distribution device smoke** (no separate F04 device gate). **Not `source-only`.** Security compliance out of scope (single actor, local-only `personal_best`, no auth, no endpoint — justify in the QA output). No backend; `Release Scope = none`.

---

## Release Scope

`none` — client-only; no Cloud Functions / rules / Remote Config / content-pack / schema change (F08's `personal_best` already exists) / distributable-surface change (`architecture.md §12`, `project-authority/release.md §2`). CI gates still run. No DevOps/Release Engineer.

---

## Open Tasks

### Contract
- [x] (F04.CONTRACT-TL) `prd.md` + initial `architecture.md` — done 2026-09-06. Substrate LOCKED; `[PENDING — UI]` / `[PENDING — F05]` / `[PENDING — F07]` enumerated.

### UI Design
- [ ] (F04-UI) `ui-design.md` — the completion-panel handoff; resolve `architecture.md §13 [PENDING — UI]`; parity with F03 Direction A; honour `design-doctrine.md` + `premium-ui-rubric.md`. **NEXT.**

### Frontend
- [ ] (F04-FE1…FE5) star function + `CompletionResult` + win-path wiring + the real panel + tests, against `architecture.md` + `ui-design.md`. After F04-UI.

### QA
- [ ] (F04-QA) end-to-end client QA — `automated functional` mandatory. After Frontend.

---

## Blockers

* **None.** F03 (`Done`) already names F04 as the owner of the real completion panel (`f03 architecture.md §10`; `completion_sheet.dart` = "F04 seam"); F06 (`Done`) guarantees `optimalMoves`; F08's on-device persistence (`personal_best` + `PersonalBestRepo`) is complete (F08's parked Firebase deploy is irrelevant — `personal_best` is local-only). Content: the F06 5-puzzle smoke set is enough (every artifact carries `optimalMoves`).
* **Not a blocker, noted:** the "Next Level" route is `[PENDING — F05]` (F04 ships the button inert/disabled — a clean seam, not a dependency); Daily rating persistence is `[PENDING — F07]` (F04's win path gates on `source == journey`); SFX/haptics on the reveal → F11; the `level_completed` analytics event → F12. Final TR panel copy → PO/localization (same track as F03's microcopy follow-on).

---

## Last Decision

* 2026-09-06 — Tech Lead (**F04 activation + initial contract**):
  * **Activated F04** after F03 → `Done` (QA `Approved with Notes`). F04 is next on the critical path — P1 but it **unblocks the P0 F05** (Journey needs the real completion panel with stars). F03 (`Done`) + F06 (`Done`) are its dependencies; F08's on-device `personal_best` persistence is already built.
  * **Complexity: NOT COMPLEX** → no Technical Analyst (rationale in `## Complexity Decision` — F08 pre-built the persistence; F04 = a pure function + a value object + a panel; 10 fully-specified ACs). **UI Designer REQUIRED** — a reward-reveal panel with multiple states + a reveal moment + chrome parity with F03. **No DevOps** — `Release Scope = none`.
  * **Contract produced** (`architecture.md`): `starsForResult` / `isPerfectResult` pure functions (3 = optimal / Perfect; 2 = optimal+1..3 inclusive; 1 = optimal+4+; **never 0**; defensive `player < optimal` → 3); `CompletionResult` value object + `BestOutcome {firstClear, newBest, matchedBest, noImprovement}`; **additive** win-path wiring into F03's `PlaySessionController` (compute stars → journey-only `PersonalBestRepo.recordCompletion` fire-and-forget with a caught failure → read-back → `CompletionResult` → `notifyListeners`); the real completion panel (7 required elements per AC7 + state variants + a bounded ≤ ~800 ms deterministic star-reveal), replacing F03's minimal seam sheet, over F03's dimmed board + amber seam bar; persistence = **F08's existing `personal_best` + `PersonalBestRepo`, no schema change**; F04 adds no route (`Retry` → F03's `retryFromCompletion()`; `Next Level` inert/disabled = `[PENDING — F05]`); `runtime`-for-feel QA foldable into F03's already-accepted first-app-distribution device smoke; `Release Scope = none`.
  * `[PENDING — UI]` (panel handoff) + `[PENDING — F05]` ("Next Level" route) + `[PENDING — F07]` (Daily persistence) enumerated in `architecture.md §13`.
  * Routing: **UI Designer (F04-UI → `ui-design.md`)** → Frontend/Mobile Developer (F04-FE1…FE5) → QA → Tech Lead (close). `feature-board.md` + `system-state.md` synced (Active Feature → F04; F03 → Done; F08 unchanged / parked).

---

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-06
* Summary: F04 activated after F03 → `Done`. `prd.md` + initial `architecture.md` created (substrate LOCKED; `[PENDING — UI]` / `[PENDING — F05]` / `[PENDING — F07]` enumerated). Complexity = not COMPLEX (no Analyst); UI Designer required (reward-reveal panel); no DevOps (`Release Scope = none`). Persistence reuses F08's `personal_best` + `PersonalBestRepo` — no schema change. `Current Owner → UI Designer`; `Next Role → UI Designer`. `feature-board.md` + `system-state.md` synced.

---

## Next Role

UI Designer

---

## Next Action

### UI Designer — F04-UI → `ui-design.md` — ⬅ NEXT

```text
Task: produce features/f04-star-rating-and-personal-best/ui-design.md — the completion-panel handoff
(a win / reward-reveal surface). No code.

Authority: features/f04-star-rating-and-personal-best/architecture.md (§7 the panel contract + the 7
required elements + the state variants; §13 the [PENDING — UI] list), features/f04-.../prd.md
(AC1–AC10 + §6 constraints + §7 "Replay Rate > 20%"), features/f03-puzzle-play-session/ui-design.md
(Direction A — the panel must have chrome/atmosphere PARITY with it: it rises over F03's dimmed +
receded board and the amber L→R seam bar), design/design-doctrine.md, design/premium-ui-rubric.md.

Must deliver:
1. The panel's visual hierarchy — the STAR RATING is the reveal / hero; then the your-moves vs
   OPTIMAL vs PERSONAL BEST comparison (legible at a glance — this is the replay hook); then the two
   CTAs (Retry primary, Next Level secondary). Target word present but subordinate.
2. The STAR-REVEAL as a bounded moment (≤ ~800 ms, deterministic — no infinite animation): stars
   fill in sequence; "Perfect" (3 stars) lands last as the top beat; motion intent (not technical
   implementation).
3. All state variants, each visually distinct (logic is driven by CompletionResult.bestOutcome):
   - firstClear — first time this level is cleared (best = this result)
   - newBest — beat the previous best → the CELEBRATORY variant ("New best!" marker)
   - matchedBest — equalled the best
   - noImprovement — worse than the best → this-run stars shown, but the retained BETTER best on the
     "personal best" line (no "new best")
   - Perfect — solved in exactly optimal (3 stars) → the top variant; may combine with newBest
   - no-optimal fallback (defensive, dev-only in practice) — completion shown, NO stars/best, a
     muted "rating unavailable" line
4. The "Perfect" and "New best!" markers — text + a NON-COLOUR cue (accessibility); the star count
   must be conveyed for screen readers (Semantics label, e.g. "3 / 3 stars — Perfect").
5. CTA hierarchy: Retry = primary (functional now — restarts the level in place); Next Level =
   secondary, and in F04's scope it is DISABLED with a quiet [PENDING — F05] affordance (F05 wires
   the Journey advance). Do not design it as an equal-weight button.
6. Chrome / atmosphere PARITY with F03's Direction A: the same raised dark panel family, the same
   scrim over the dimmed board, the same amber accent language, sitting above F03's seam bar. This
   is the same product-family surface as F03's minimal sheet, just fully realised.
7. Background / colour / typography / surface-depth per the doctrine + rubric; premium
   differentiators for a reward moment; not a generic results card.

Out of scope: the star-computation numbers (architecture.md §4 fixes them); where "Next Level" routes
(F05); Daily-specific copy (F07); SFX/haptics (F11). Reuse F03's PlayTheme tokens.

End: Current Owner → Frontend/Mobile Developer; Next Role → Frontend/Mobile Developer (F04-FE1…FE5).
```

→ then `Run Frontend/Mobile Developer` → `Run QA` → `Run Tech Lead` (F04 close).

---

## Change Log

* v1 (2026-09-06) — Tech Lead: **F04 created + activated** after F03 → `Done`. P1; unblocks the P0 F05 (Journey needs the real completion panel with stars). Depends on F03 (`Done`) + F06 (`Done`, the stored `optimalMoves`); persistence **already built by F08** (`personal_best` table + `PersonalBestRepo` — monotone `recordCompletion`, `isPerfect`, preserved `firstCompletedAtUtcMs`). `prd.md` derived from `product-prd.md` F04 section (AC1–AC10 incl. the two boundary ACs + `Replay Rate > 20%`). Initial `architecture.md`: substrate LOCKED — `starsForResult`/`isPerfectResult` pure functions (3 = optimal/Perfect, 2 = optimal+1..3 inclusive, 1 = optimal+4+, **never 0**, defensive `player < optimal` → 3); `CompletionResult` + `BestOutcome {firstClear, newBest, matchedBest, noImprovement}`; **additive** win-path wiring into F03's `PlaySessionController` (no F03 contract change — F03 §10 already names F04 the panel owner); the real completion panel (7 AC7 elements + state variants + a bounded ≤ ~800 ms deterministic star-reveal) replacing `completion_sheet.dart`, over F03's dimmed board + amber seam bar; persistence via F08's existing `PersonalBestRepo` (no schema change); F04 adds no route (`Retry` → F03's `retryFromCompletion()`; `Next Level` inert/disabled = `[PENDING — F05]`); `Release Scope = none`. `[PENDING — UI]` / `[PENDING — F05]` / `[PENDING — F07]` enumerated in §13. Complexity: **not COMPLEX** (no Technical Analyst — F08 pre-built the persistence, 10 fully-specified ACs); **UI Designer required** (a win/reward-reveal panel); **no DevOps** (`Release Scope = none`). Routing: **UI Designer (F04-UI → `ui-design.md`)** → Frontend/Mobile Developer (F04-FE1…FE5) → QA → Tech Lead (close). `feature-board.md` + `system-state.md` synced (Active Feature → F04; F03 → Done; F08 unchanged / parked). Nothing committed to git.
