# F04 — star-rating-and-personal-best: Architecture (Contract)

> Status: **INITIAL CONTRACT — substrate LOCKED; `[PENDING — UI]` (the completion-panel handoff) + `[PENDING — F05]` (the "Next Level" route) resolve in the UI Designer + F05 passes.**
> Contract authority for F04. Execution state is in `orchestration.md`.

---

## 1. Purpose

Define: the pure **star-rating** function; the **completion result** value object; the **real completion panel** contract (content, states, chrome parity with F03); how F04 **wires into F03's win path** (`PlaySessionController` + `play_session_screen.dart`), replacing F03's minimal seam sheet; and the **persistence** call into F08's `PersonalBestRepo`. F04 writes no backend (`Release Scope = none`).

---

## 2. Authorities & Inputs

| Authority | Role |
| --- | --- |
| `product/product-prd.md` → F04 section + §15 (`PersonalBest`) | product contract |
| `features/f04-star-rating-and-personal-best/prd.md` | feature scope + AC1–AC10 |
| `features/f03-puzzle-play-session/architecture.md` → §10 (completion sequence) + §13 (route) | **consumed contract** — the win moment + the panel seam |
| `features/f06-.../architecture.md` → `Puzzle.optimalMoves` | **consumed contract** — the optimal value |
| `app/lib/persistence/repositories/personal_best_repo.dart` + `personal_best` table (F08) | **consumed contract** — the persistence mechanism (already built) |
| `project-authority/platform.md` | Flutter / Riverpod / go_router; localization pattern |
| `design/design-doctrine.md` + `design/premium-ui-rubric.md` | the reward-reveal panel's quality bar |
| `project-authority/release.md` | `Release Scope` decision |

---

## 3. Actors & Permissions

Single actor: the player. No auth, no roles. Guest identity (F08 `guestId`) already established — F04 reads it via `currentGuestIdProvider` for the `personal_best` write.

---

## 4. Star Rating [LOCKED]

A **pure function** — no I/O, fully unit-tested.

```dart
/// `player` = the net move count after undos (F03's `engine.moveCount`).
/// `optimal` = the puzzle's solver-verified `optimalMoves` (F06; always ≥ 1).
///
/// 3 → player == optimal            ("Perfect")
/// 2 → optimal < player <= optimal + 3   (upper boundary inclusive — AC9)
/// 1 → player >= optimal + 4              (AC10) — and the floor: NEVER 0 (AC4)
int starsForResult({required int player, required int optimal});

/// `starsForResult(...) == 3` — equivalently `player == optimal`.
bool isPerfectResult({required int player, required int optimal});
```

* **Never 0** — a completion is at least 1 star even for an arbitrarily large `player` (AC4). `player < optimal` is impossible (optimal is a proven minimum) — treated defensively as 3 (Perfect) if it ever occurs, and logged.
* `optimal < 1` or a missing optimal → **not F04's to fix** (F06 gate guarantees it). Defensively: the caller (see §6) skips rating, shows the panel without stars, logs `rating_blocked_no_optimal`.
* This function is the single source of the star value; the panel and the `personal_best` write both take it.

---

## 5. Completion Result [LOCKED — value object]

Immutable; built by the F03 win path, handed to the panel.

```dart
enum BestOutcome { firstClear, newBest, matchedBest, noImprovement }

class CompletionResult {
  final String levelId;        // the puzzle id (journey/debug) — the personal_best key
  final PuzzleSource source;   // journey | daily (F03/F08 enum)
  final String targetWord;
  final int playerMoves;       // engine.moveCount
  final int optimalMoves;      // Puzzle.optimalMoves
  final int stars;             // starsForResult(...)  — 1..3
  final bool isPerfect;        // stars == 3
  final int personalBestMoves; // the best AFTER this completion is recorded
                               //   (== playerMoves on firstClear / newBest)
  final bool bestIsPerfect;    // personal_best.isPerfect after the write
  final BestOutcome bestOutcome;
  final bool ratingPersisted;  // true for journey; false for daily (F07 owns daily persistence)
}
```

* `bestOutcome`:
  * `firstClear` — no prior `personal_best` row (AC8).
  * `newBest` — `playerMoves < priorBest` (AC6) — drives the "new best!" panel treatment.
  * `matchedBest` — `playerMoves == priorBest`.
  * `noImprovement` — `playerMoves > priorBest` (AC5) — the panel shows this run's stars but the retained better `personalBestMoves`.
* For `source == daily` (F07 territory, not reachable in F04's scope): `ratingPersisted = false`; `personalBestMoves` / `bestOutcome` reflect **no write** (the panel shows this run's stars + "—" / a Daily-appropriate best line; exact copy is `[PENDING — F07]`).

---

## 6. Win-path Wiring [LOCKED]

F03's `PlaySessionController.commitShift()` (or `_finishShift()`) currently, on `solvedThisStep`, sets `phase = won` + `wonRow` + persists a `completed` snapshot + `ActiveSessionRepo.clear()`. **F04 extends this path** (an additive change to F03's controller — no F03 contract change; F03 §10 already names F04 as the owner of the real panel):

1. On win, F04 computes `stars = starsForResult(player: engine.moveCount, optimal: puzzle.optimalMoves)`.
   * If `puzzle.optimalMoves < 1` → skip rating; build a `CompletionResult`-less "bare completion" signal; log `rating_blocked_no_optimal`; the panel renders without stars/best. (Defensive only — F06 guarantees this never happens for a shipped puzzle.)
2. If `source == journey` (or the debug entry): `final becameBest = await personalBestRepo.recordCompletion(guestId, levelId: puzzle.id, moveCount: engine.moveCount, stars: stars, optimalMoves: puzzle.optimalMoves, completedAtUtcMs: clock.nowUtcMs)`. Then `read(guestId, puzzle.id)` for the post-write `bestMoveCount` / `isPerfect`. Derive `bestOutcome` from `becameBest` + whether a prior row existed + the compare.
   * If `source == daily`: skip `recordCompletion` (F07); `ratingPersisted = false`.
3. Build the `CompletionResult`; expose it on the controller (`CompletionResult? get completion`); `notifyListeners()`.
4. The screen renders the **F04 completion panel** (replacing F03's `CompletionSheet`) with `controller.completion`.

* The `personal_best` write is **fire-and-forget with a caught failure** (same posture as F03's `_persist` — storage-full → `debugPrint('best_persist_failed …')`, the panel still shows the computed stars for this run; a `noImprovement`/`firstClear` best line degrades to "—" on write failure). Never blocks the panel.
* **`completedAtUtcMs`** uses the injected clock (`DateTime.now().toUtc()` by default) — this is a wall-clock timestamp, acceptable here (it only feeds `firstCompletedAtUtcMs`, which `PersonalBestRepo` preserves once set; not used for ordering/anti-cheat).
* **Idempotency:** a second completion of the same level (Retry → solve again) calls `recordCompletion` again — `PersonalBestRepo` is already monotone (a worse-or-equal result is a no-op write). F04 adds no dedup.

---

## 7. Completion Panel [LOCKED contract; `[PENDING — UI]` visual handoff]

> **[Amended 2026-09-28 — F03 `architecture.md` §20 (Design Adoption Phase D2)]:** the panel becomes a **full-screen result** (no board behind, no Close). The content (AC7) and the variants below stay; the markers and badges follow F03 §20.3 (5), the CTA weighting §20.3 (6). The Direction A visual notes below are superseded by the F03 D2 handoff. F04 AC1–AC10 are unchanged.

Replaces `app/lib/play/widgets/completion_sheet.dart` (F03's minimal seam). Rises over F03's dimmed + recede board and the amber seam bar (F03 `ui-design.md` Direction A) — **chrome / atmosphere parity with F03**: the same raised dark panel family, the same scrim, the same amber accent language.

**Content (AC7 — all required):**

| Element | Source |
| --- | --- |
| Target word | `CompletionResult.targetWord` |
| Player moves | `playerMoves` |
| **Optimal moves** | `optimalMoves` |
| **Stars (1–3)** — the reveal | `stars` |
| **"Perfect" marker** — shown iff `isPerfect` (3 stars) | `isPerfect` |
| **Personal best** | `personalBestMoves` (+ a "Perfect" tag iff `bestIsPerfect`) |
| **"New best!" treatment** — shown iff `bestOutcome == newBest` | `bestOutcome` |
| **Retry** (primary CTA — restart the same level in place) | callback → F03's `retryFromCompletion()` |
| **Next Level** (secondary CTA) | callback — route is `[PENDING — F05]`; see below |

* **Star reveal** is the panel's moment — a bounded (≤ ~800 ms), non-cosmetic-only animation (stars fill in sequence; "Perfect" lands last). Exact choreography `[PENDING — UI]`. Deterministic finite animation (no `repeat()`), so widget tests settle.
* **State variants the panel must render distinctly** (`[PENDING — UI]` visual treatment; all logic-driven by `CompletionResult`): first clear (`firstClear`), new best (`newBest` — the celebratory variant), matched best (`matchedBest`), no improvement (`noImprovement` — this-run stars + the retained better best), Perfect (`isPerfect` — the top variant, may combine with `newBest`), and the defensive **no-optimal** fallback (completion shown, no stars/best, a muted "rating unavailable" line — dev-only in practice).
* **"Next Level"** — F04 ships the button. In F04's scope (only the debug entry / no F05 Journey), it is **disabled** with a muted `[PENDING — F05]` affordance (or, if the debug entry can resolve a "next" smoke puzzle, it opens that — Frontend's call, documented). F05 wires the real Journey-advance route + unlock. The `Retry` CTA is fully functional now.
* **Localization:** all strings externalized (extend F03's `PlayStrings` or a parallel `RatingStrings` — Frontend's call; keys proposed: `HARİKA`/"Perfect", `EN İYİ`/"Best", `YENİ REKOR`/"New best!", `TEKRAR`/Retry (reuse F03's `Yeniden`), `SONRAKİ`/Next Level, `OPTİMAL`/Optimal). Final TR copy → PO/localization (same track as F03's microcopy follow-on).
* **Accessibility:** the star count must be conveyed non-visually too (a `Semantics` label "3 / 3 stars — Perfect"); "Perfect" / "New best!" are text, not colour-only.

---

## 8. Route / Navigation Contract [LOCKED]

* F04 adds **no route**. The panel is an overlay on F03's `/play` screen (as F03's minimal sheet already is).
* `Retry` → `PlaySessionController.retryFromCompletion()` (F03) — restart in place, panel dismisses.
* `Next Level` → a callback the `/play` screen provides. In F04's scope it is inert/disabled (`[PENDING — F05]`). F05 supplies the real handler (advance the Journey, route to the next level's `/play`, respect unlock).
* `Close` / system back from the panel → pop to the caller (F03's chevron behaviour is hidden in `won`; the panel owns exit via its CTAs). Keep F03's `_popToCaller` fallback. **[Amended 2026-09-28, F03 §20.3 (7)]:** there is no `Close`; the result's back button ("Ana ekrana dön") and system back → `_popToCaller` → `/`.

---

## 9. Persistence [LOCKED]

* **Store:** F08's `personal_best` table via `PersonalBestRepo.recordCompletion(...)` — **no new table, no schema change, no migration.** The repo is already monotone + preserves `firstCompletedAtUtcMs` + sets `isPerfect`.
* **Key:** `(guestId, levelId)` where `levelId = puzzle.id`.
* **Write timing:** on win, once, fire-and-forget with a caught failure (§6). Journey only; Daily is F07.
* **Read-back:** immediately after the write, `read(guestId, puzzle.id)` for the panel's `personalBestMoves` / `bestIsPerfect`.
* No cross-user data, no network. F08's parked Firebase deploy is irrelevant.

---

## 10. Validation Responsibility [LOCKED]

* **F04:** the star boundaries (AC1–AC4, AC9, AC10); the "Perfect" ⇔ 3-stars ⇔ `player == optimal` identity; `bestOutcome` derivation; the panel content + state variants; the defensive no-optimal fallback; Journey-vs-Daily persistence gating.
* **F08 `PersonalBestRepo`:** monotone best, `firstCompletedAtUtcMs` preservation, transactional write.
* **F06:** `optimalMoves` is present and correct on every shipped artifact.
* **F03:** `engine.moveCount` is the correct net-of-undos player result; the win moment.

---

## 11. QA Focus [LOCKED]

* **Star boundaries (`automated functional`):** the full table — `player == optimal` → 3 + Perfect; `optimal+1`, `optimal+2`, `optimal+3` → 2 (AC9 boundary); `optimal+4`, `optimal+10`, `optimal+100` → 1 (AC10 boundary + AC4 floor); a defensive `player < optimal` → 3 + log.
* **Personal best (`automated functional`, against the real F08 repo with an in-memory DB):** first clear → best = result + `firstClear` (AC8); a worse result → best unchanged + `noImprovement` (AC5); a better result → best updated + `newBest`, `isPerfect` set iff `== optimal` (AC6); a matched result → `matchedBest`; a Perfect then a Perfect replay → best stays optimal, still Perfect, no "new best".
* **Panel (`runtime` where a device is available, else `automated functional` widget tests):** AC7 — all seven elements present; the star reveal plays and settles; the `newBest` / `noImprovement` / `matchedBest` / `firstClear` / `Perfect` / no-optimal variants each render distinctly; `Retry` restarts in place; `Next Level` is inert/disabled with the `[PENDING — F05]` affordance; `Semantics` announces the star count + Perfect/New-best.
* **Integration with F03 (`automated functional` — extend `play_session_runtime_test.dart` / add an F04 widget test):** solve `smoke-tr-01` (optimal 1) with exactly 1 move → 3 stars + Perfect + first-clear best 1; Retry → solve in 1 again → matched best, still Perfect; on a 2-move solve of `smoke-tr-02` (optimal 2) → 3 stars; force a longer solve → 2 or 1 stars per the boundary.
* **`ui-design.md` alignment:** chrome/atmosphere parity with F03 (raised dark panel family, scrim, amber accent); the reward-reveal is a genuine moment, not a static card; CTA hierarchy (Retry primary, Next Level secondary); `premium-ui-rubric.md` fail conditions.
* **Evidence class:** `automated functional` mandatory (the star function + the best logic + the panel-state matrix + the F03-integration); `runtime` (device) for the reveal *feel* and the panel visuals — foldable into F03's already-accepted first-app-distribution device smoke.
* **Not `source-only`.** Security compliance N/A (single actor, local-only `personal_best`, no endpoint) — justify in the QA scope line.

---

## 12. Release / Deployment Impact [LOCKED]

* **`Release Scope` = `none`.** Client-only: no Cloud Functions, no rules, no Remote Config, no content pack, no schema change (F08's `personal_best` already exists), no new distributable surface beyond the app build. Per `release.md §2` conditional rule, no release gate. CI gates (`format:check` / `analyze` / `test` / `build:app` / `build ios` / the best-effort `integration`) still run.
* No `DevOps/Release Engineer`. The first app-build distribution gate remains ~F05.

---

## 13. Open Items

* `[PENDING — UI]` (UI Designer → `ui-design.md`): the completion-panel visual handoff — layout + hierarchy of target/moves/optimal/stars/best; the **star-reveal choreography** (bounded ≤ ~800 ms, deterministic); the distinct visual treatments for `firstClear` / `newBest` (celebratory) / `matchedBest` / `noImprovement` / `Perfect` / no-optimal; CTA hierarchy (Retry primary, Next Level secondary/disabled); chrome + atmosphere **parity with F03's `ui-design.md` Direction A** (raised dark panel, scrim, amber accent, sits over the dimmed board + seam bar); the "Perfect" and "New best!" markers (text + a non-colour cue); accessibility (Semantics for the star count).
* `[PENDING — F05]` — the "Next Level" route. F04 ships the button inert/disabled; F05 supplies the Journey-advance handler + unlock.
* `[PENDING — F07]` — Daily completions show a rating but do not persist to `personal_best` (F07 owns Daily result persistence + first-run-official + streak). F04's win path already gates on `source == journey`; the Daily panel's "best" line copy is F07's.
* `[DEFERRED — F11]` — SFX / haptics on the star reveal + Perfect.
* `[DEFERRED — F12]` — the `level_completed` analytics event (stars, optimal, perfect, best).
* `[IMPL — Frontend]` — whether to extend `PlayStrings` or add `RatingStrings`; whether the debug entry's "Next Level" opens the next smoke puzzle or stays disabled.
