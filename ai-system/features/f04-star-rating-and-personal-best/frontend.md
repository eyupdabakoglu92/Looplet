# F04 — star-rating-and-personal-best: Frontend Delivery Report

> Delivery report + traceability artifact only. Contract authority stays in `architecture.md`; visual/state authority in `ui-design.md`. Direct-edit mode — real project files were edited.

---

## 1. Feature Summary

On a solved puzzle, F04 rates the result against the solver-optimal move count (1–3 stars, never 0; 3 ⇔ Perfect ⇔ `player == optimal`) and shows the **real completion panel** — target word, player moves, OPTIMAL, stars, personal best, Retry, Next Level — replacing F03's minimal seam sheet. The per-level personal best (monotone, "Perfect" flag) is persisted via **F08's existing `PersonalBestRepo`** — no schema change. The win path in F03's `PlaySessionController` is extended **additively** (no F03 contract change; F03 §10 already names F04 the panel owner).

---

## 2. Impacted Files

**Created**
- `app/lib/rating/star_rating.dart` — pure `starsForResult` / `isPerfectResult`.
- `app/lib/rating/completion_result.dart` — `CompletionResult` value object + `BestOutcome` enum + pure `bestOutcomeFor(...)`.
- `app/lib/rating/rating_strings.dart` — `RatingStrings` per-language table (parallel to F03's `PlayStrings`).
- `app/lib/rating/rating_providers.dart` — `ratingClockProvider` (wall-clock seam; reuses F08's `personalBestRepoProvider` + `currentGuestIdProvider`).
- `app/lib/rating/completion_panel.dart` — the F04 reward panel (`ui-design.md` Direction A), replaces `completion_sheet.dart`.
- `app/test/rating/star_rating_test.dart` — the full AC1–AC4 / AC9 / AC10 boundary table.
- `app/test/rating/personal_best_flow_test.dart` — best logic against the real F08 `PersonalBestRepo` + in-memory DB.
- `app/test/rating/completion_panel_test.dart` — F04 panel widget tests (Perfect / matched / 2-star / new-best / restored-solved).

**Updated**
- `app/lib/play/play_session_controller.dart` — additive win-path wiring (`_beginCompletion` / `_resolvePersonalBest`), new optional ctor params (`personalBestRepo`, `guestId`), `completion` / `ratingUnavailable` / `ratingResolved` / `whenRatingResolved` getters.
- `app/lib/play/play_session_screen.dart` — resolves guest id + `PersonalBestRepo`, passes them to the controller; swaps `CompletionSheet` → `CompletionPanel`; scrim uses `PlayTheme.sheetScrim`.
- `app/lib/play/play_theme.dart` — added `sheetSurface` / `sheetHighlight` / `sheetRecess` / `sheetScrim` tokens (promotes F03's `CompletionSheet` inline constants — clarification #3).
- `app/test/play/play_session_screen_test.dart` — completion assertions retargeted to `CompletionPanel` + F04 markers.
- `app/test/play/play_session_runtime_test.dart` — `CompletionSheet` → `CompletionPanel` (3 sites + import); scenarios unchanged.
- `app/integration_test/play_session_test.dart` — `CompletionSheet` → `CompletionPanel` (best-effort device suite; not the CI gate).

**Deleted**
- `app/lib/play/widgets/completion_sheet.dart` — the F03 seam, replaced by `completion_panel.dart`.

---

## 3. Task-to-Code Traceability

| Task ID | Status | Files | Behaviour implemented |
| --- | --- | --- | --- |
| **F04-FE1** | Complete | `rating/star_rating.dart` | Pure `starsForResult({player, optimal})`: `player <= optimal` → 3 (the `<` branch `debugPrint`s); `optimal < player <= optimal+3` → 2 (AC9 inclusive); `player >= optimal+4` → 1 (AC10); **never 0** (AC4). `isPerfectResult` = `stars == 3` (holds the "Perfect ⇔ 3 stars" invariant even on the defensive path). Unit-tested against the full table. |
| **F04-FE2** | Complete | `rating/completion_result.dart`, `rating/rating_providers.dart` | `CompletionResult` — exactly `architecture.md §5`'s fields (+ `copyWith`, `personalBestAvailable`, `movesOverOptimal` conveniences). `BestOutcome {firstClear, newBest, matchedBest, noImprovement}`. Pure `bestOutcomeFor({player, priorBest})`. `ratingClockProvider` wall-clock seam; F08's `personalBestRepoProvider` + `currentGuestIdProvider` reused unchanged. |
| **F04-FE3** | Complete | `play/play_session_controller.dart` | On win (`_finishShift` solved branch **and** the restored-solved ctor branch): `_beginCompletion()` computes stars synchronously (needs only `moveCount` + `optimalMoves`) and publishes a preliminary `CompletionResult`; `_resolvePersonalBest()` (async, **caught** failure — same posture as `_persist`) reads prior best → `recordCompletion(...)` → reads back → fills `personalBestMoves` / `bestIsPerfect` / `bestOutcome` / `ratingPersisted`, then `notifyListeners()`. `optimalMoves < 1` → `ratingUnavailable = true`, `completion` stays `null`, logs `rating_blocked_no_optimal` (bare completion). `source != journey` (Daily → F07) or no repo/guest wired → stars stand, no best line. Write failure → best degrades to `personalBestMoves == 0` (panel shows "—"). `_applyRestart()` clears the completion so the next win recomputes. **No F03 contract field changed.** |
| **F04-FE4** | Complete | `rating/completion_panel.dart`, `play/play_session_screen.dart`, `play/play_theme.dart` | `CompletionPanel` — F03's `CompletionSheet` surface reused verbatim via new `PlayTheme.sheet*` tokens, over `PlayTheme.sheetScrim` (40%); docked amber **spine**; **drawn faceted star** (`_StarPainter`, not `Icons.star`) — struck (raised, amber-fill, one bloom, `easeOutBack` pop) vs recessed **socket**; bounded **≤ 800 ms one-shot** `AnimationController` (no `repeat()`); `Perfect` "HARİKA" struck plate lands last (`Interval(0.60, 0.82)`) + synchronised 3-star glow pulse; `N / 3` caption; kicker + subordinate 22 pt word; **SEN / OPTİMAL / EN İYİ** triptych on a recessed track with the amber `+N` gap connective (`=` + no `+N` on Perfect); EN İYİ sub-states (`İLK` / `▲` + `YENİ REKOR` + wiping underline / silent match / `daha iyi`) + `★` when `bestIsPerfect`; `Retry` = F03 amber pill; `Next Level` = disabled ghost pill with `·  yakında` affordance, inert (no toast/dialog), `Semantics(enabled: false)`; quiet `Kapat` + `_popToCaller`; star-group `Semantics` label ("3 / 3 yıldız — Harika") with `ExcludeSemantics` on the glyphs; `MediaQuery`/`platformDispatcher.accessibilityFeatures.disableAnimations` → reveal end-state. `play_session_screen.dart` resolves the guest id + repo in `_init()` and renders the panel (`result` / `ratingUnavailable` / bare `word` + `moves`). |
| **F04-FE5** | Complete | `test/rating/*`, `test/play/*` (updated) | See §17. `flutter analyze` clean (app + integration_test); `flutter test` (app) **129 green, +17 net new, no regression**; `flutter build ios --release --no-codesign` **green** (`Runner.app`, 54.6 MB). |

---

## 4. Authority Reconciliation

No contract conflict. Two `ui-design.md` `Needs Tech Lead Clarification` items were resolved with the defaults the handoff itself proposed — recorded here for Tech Lead visibility, not silent:

| Item | Source | Decision applied | Downstream |
| --- | --- | --- | --- |
| `CompletionSheet` inline surface constants → `PlayTheme` (`ui-design.md §14.3`, `architecture.md §13 [IMPL — Frontend]`) | `ui-design.md` (encouraged) | Promoted to `PlayTheme.sheetSurface` / `sheetHighlight` / `sheetRecess` / `sheetScrim`; F04's panel + the screen scrim both consume them. Touches an F03 file (`play_theme.dart`) — additive tokens only, no F03 behaviour change. | Any later sheet reuses one source. |
| Debug entry "Next Level" — open next smoke puzzle vs stay disabled (`ui-design.md §7`, `architecture.md §13 [IMPL — Frontend]`) | `ui-design.md` (default: disabled) | **Stays disabled** in F04 scope (`onNextLevel` is always `null` → ghost pill + `[PENDING — F05]` affordance). F05 wires the real handler. | None. |

Forward note (non-blocking, `ui-design.md §14.1`): once F05 enables "Next Level", the Retry/Next-Level primary/secondary weighting should be revisited per outcome. `architecture.md §7` locks Retry primary for F04 — implemented as specified.

---

## 5. Components

| Component | Responsibility | State behaviour |
| --- | --- | --- |
| `CompletionPanel` (`StatefulWidget`) | The reward surface; owns the bounded reveal (`_reveal` 800 ms one-shot, `_underline` 220 ms). | `result != null` → rated body; `result == null && ratingUnavailable` → bare body; reduced-motion → `_reveal.value = 1`. `didUpdateWidget` fires `_underline` once if the async read-back turns the result into `newBest`. |
| `_Spine` | Docked amber seam bar (3 pt, end-faded, glow). | Static. |
| `_StarRow` / `_Star` / `_StarPainter` | The 3-star hero. Drawn faceted glyph. | Per-star strike windows on `_reveal`; earned → struck (raised, amber, bloom, pop); unearned → recessed socket; Perfect → one synchronised glow pulse. |
| `_PerfectPlate` | "HARİKA" struck plate. | Built only when `isPerfect`; scales + fades in on `Interval(0.60, 0.82)`. |
| `_Triptych` / `_StatCell` / `_GapConnective` / `_CellDivider` / `_BestCell` | SEN / OPTİMAL / EN İYİ comparison + `+N` / `=` gap + best sub-states. | `_BestCell` renders `firstClear` (`İLK`), `newBest` (`▲` + `YENİ REKOR` + wiping underline), `matchedBest` (bare), `noImprovement` (`daha iyi`); `★` when `bestIsPerfect`; `—` when `personalBestMoves <= 0`. |
| `_BareBody` | No-optimal fallback. | kicker + word + `SEN {moves}` + "Puan yok" — no stars / triptych. |
| `_Actions` / `_RetryCta` / `_NextLevelCta` | CTA stack. | Retry functional; Next Level inert + disabled; Close → `_popToCaller`. |

---

## 6. Screens

Route `/play` (F03) — **no new route** (`architecture.md §8`). The panel is an overlay on the play screen (as F03's sheet was), gated by `phase == won`.

| Surface state | Header | Back affordance | Returns to |
| --- | --- | --- | --- |
| completion panel (all variants) | none | back chevron **hidden** in `won` (F03 rule); panel owns exit | `Retry` → in-place restart (`retryFromCompletion()`); `Close` / system back → `_popToCaller`; `Next Level` → inert (`[PENDING — F05]`) |

---

## 7. State Management

- **Rating / best state** lives on `PlaySessionController` (`_completion`, `_ratingUnavailable`, `_ratingResolved`) — UI state derived from the F02 engine + the F08 store, exposed as read-only getters, published via `notifyListeners()`. No new store/provider owns mutable session state.
- **Server vs UI state:** there is no server. The F08 `personal_best` table is the durable store; the panel reads a snapshot of it (`CompletionResult`) captured at win time. No live subscription.
- **Async authority:** the personal-best read-back is keyed to `puzzle.id` for the current session only; a stale result cannot apply because `_applyRestart()` nulls `_completion` and each `_beginCompletion()` starts a fresh `_ratingWork` future. Write is fire-and-forget with a caught failure — never blocks the panel.

---

## 8. API / Event Integration

No network. Persistence call: `PersonalBestRepo.recordCompletion(guestId, levelId: puzzle.id, moveCount, stars, optimalMoves, completedAtUtcMs)` — **F08's existing signature, unchanged**; then `read(guestId, puzzle.id)` for the post-write figure. Contract compliance: no new table, column, migration, or repo method (`architecture.md §9`).

---

## 9. Contract Compliance Check

| Area | Status | Note |
| --- | --- | --- |
| Star function (`architecture.md §4`) | Preserved | 3/2/1 boundaries, never 0, defensive `player < optimal` → 3 + log; `isPerfect == (stars == 3)`. |
| `CompletionResult` / `BestOutcome` (`§5`) | Preserved | Fields exactly as specified; `personalBestMoves == 0` is the documented "unavailable" sentinel (§6 "degrades to —"). |
| Win-path wiring (`§6`) | Extended | Additive on `PlaySessionController`; no F03 contract field changed; Daily gated (`source == journey`); no-optimal → bare completion + `rating_blocked_no_optimal` log; write fire-and-forget + caught. |
| Panel content — AC7 (`§7`) | Preserved | All 7 elements present (target word, player moves, optimal, stars, personal best, Retry, Next Level) — asserted in `completion_panel_test.dart`. |
| Panel state variants (`§7`) | Preserved | `firstClear` / `newBest` / `matchedBest` / `noImprovement` / `Perfect` / no-optimal each render distinctly. |
| Route / navigation (`§8`) | Preserved | No route added; `Retry` → `retryFromCompletion()`; `Next Level` inert; `Close` / back → `_popToCaller`; chevron hidden in `won`. |
| Persistence (`§9`) | Preserved | F08 `personal_best` + `PersonalBestRepo` only; no schema change. |
| `ui-design.md` alignment | Preserved | Direction A: F03 surface verbatim (`PlayTheme.sheet*`), docked spine, struck-vs-socket stars, bounded deterministic reveal, centre-weighted triptych + `+N`, Retry primary / Next Level disabled ghost pill, `N / 3` caption + star-group `Semantics`, reduced-motion end-state. |
| Accessibility | Extended | Star group is one `Semantics` node ("N / 3 yıldız [— Harika]") with `ExcludeSemantics` glyphs; triptych cells `"label: value"`; `HARİKA` / `YENİ REKOR` are text + non-colour shape (plate / `▲` + underline); CTAs `Semantics(button:)`, Next Level `enabled: false`. |
| `Release Scope` | Not Applicable | `none` — client-only, no infra/CI/deploy change. |

---

## 10. Behavior Preserved

- **F03 win choreography** (amber row + L→R seam bar + one bloom + board recede 12 % + 1.5 px blur) is untouched; the F04 panel + `PlayTheme.sheetScrim` sit over it. `_PlayBody` still keeps the board `Column` mounted behind the `Positioned` panel (F03's board is not disposed on `won`) — clarification #2 answered by keeping the existing structure.
- **F03 no-input-queue / input-lock / paused-mid-animation-commits / restore** — all `play_session_controller_test.dart` + `play_session_runtime_test.dart` scenarios still pass unchanged (the win path only *adds* a call after the existing solved-branch logic).
- **`retryFromCompletion()`** semantics unchanged (restart in place, re-arm timer, fresh `inProgress` snapshot) — plus it now nulls the completion so a re-solve recomputes the rating.
- **Restored-completed session** (authored-solved / completed-snapshot-that-failed-to-clear) still lands directly in `won`; now also builds the completion — covered by a new test, no crash.

---

## 11. UX Decisions

- **Hero = the star reveal.** Struck vs recessed-socket stars carry the count by depth + silhouette (greyscale-safe) before the `N / 3` caption and the `Semantics` label — the mandatory non-colour cue is structural, per `ui-design.md §9`.
- **Bounded deterministic reveal.** One `AnimationController` (800 ms), per-star strike intervals, Perfect plate at `Interval(0.60, 0.82)`, underline wipe 220 ms. No `repeat()` → `pumpAndSettle` resolves. Reduced-motion renders the end-state.
- **Replay hook legibility.** Centre-weighted OPTİMAL, the amber `+N` ("N from Perfect"), `=` + amber accent on Perfect — the gap is one glanceable number.
- **`noImprovement` is not scolded** — this-run stars shown, the retained better best on the EN İYİ line with a quiet `daha iyi` tag; no red, no `danger` colour anywhere on the panel.
- **Next Level reads as "coming", not "broken"** — a ghost pill with `·  yakında`, not a greyed full-weight button and not a throwaway text link; inert tap (F03's "dead means dead").
- **Best line never blocks the panel** — stars show immediately from the sync computation; `EN İYİ` shows `—` for the ~0-frame read-back window or a genuine write failure.
- **premium-ui-rubric self-check:** clear single hero, dominant amber CTA, distinct state variants, layered surfaces (scrim < panel < struck stars, recessed triptych), strong hierarchy, non-generic (drawn star + docked spine + spelled-out gap). Aligns with `ui-design.md`'s 94/100.

---

## 12. Implemented Files

| File | Change | Key dependencies |
| --- | --- | --- |
| `app/lib/rating/star_rating.dart` | new — pure functions + `debugPrint` on the defensive path | `package:flutter/foundation.dart` |
| `app/lib/rating/completion_result.dart` | new — value object + enum + `bestOutcomeFor` | `PuzzleSource` (F08 snapshot) |
| `app/lib/rating/rating_strings.dart` | new — per-language table | none |
| `app/lib/rating/rating_providers.dart` | new — `ratingClockProvider` | `flutter_riverpod` |
| `app/lib/rating/completion_panel.dart` | new — the panel + `_StarPainter` | `PlayTheme`, `PlayStrings`, `RatingStrings`, `CompletionResult` |
| `app/lib/play/play_session_controller.dart` | +`_beginCompletion` / `_resolvePersonalBest`, ctor params, getters | `PersonalBestRepo`, `star_rating.dart`, `completion_result.dart` |
| `app/lib/play/play_session_screen.dart` | resolve guest id + repo; render `CompletionPanel` | `currentGuestIdProvider`, `personalBestRepoProvider`, `RatingStrings` |
| `app/lib/play/play_theme.dart` | +`sheet*` tokens | none |
| `app/lib/play/widgets/completion_sheet.dart` | **deleted** | — |

---

## 14. Assumptions

- `AppDatabase.forTesting` seeds the `player` row via `onCreate`, so `currentGuestIdProvider` resolves in widget tests without running the full bootstrap — the F04 panel therefore shows real best values in `play_session_screen_test.dart` too.
- Local Drift reads are effectively instant; the preliminary-then-resolved `CompletionResult` means the `—` best window is ~0 frames after `pumpAndSettle`. `whenRatingResolved` is exposed for any test that needs to await it explicitly.
- The custom star is a drawn `Path` (`_StarPainter`); no asset pipeline is introduced.
- `smoke-tr-02` grid `SALMA / …` → two right shifts on row 0 form `MASAL` (optimal 2); a wasted row-1 shift first yields a deterministic 3-move / 2-star solve for the boundary widget test.

---

## 17. Test Evidence by Task

| Task / behaviour | Test type | File | Proven scenario |
| --- | --- | --- | --- |
| F04-FE1 — star boundaries | unit | `test/rating/star_rating_test.dart` | `player == optimal` → 3 + Perfect (AC1); `optimal+1..+3` → 2 incl. AC9 boundary; `optimal+4` → 1 (AC10); `optimal+10`, `optimal+100` → 1, never 0 (AC4); defensive `player < optimal` → 3 with `isPerfect` true; full sweep around `optimal = 4`. |
| F04-FE2/FE3 — personal-best logic | unit (real F08 repo + in-memory DB) | `test/rating/personal_best_flow_test.dart` | first clear → `firstClear`, best = result, not perfect (AC8); worse → `noImprovement`, best unchanged (AC5); better → `newBest`, best updates, `isPerfect` iff `== optimal` (AC6); equal → `matchedBest`, no rewrite; Perfect then Perfect replay → stays optimal + Perfect, `matchedBest`; `bestOutcomeFor` purity. |
| F04-FE3/FE4 — F03 win-path integration + panel | widget | `test/rating/completion_panel_test.dart` | `smoke-tr-01` (opt 1) solved in 1 → panel with **all 7 AC7 elements**, `HARİKA`, `3 / 3`, `=`, first-clear best 1, star-group `Semantics` "3 / 3 yıldız — Harika", no `YENİ REKOR`; Retry → panel gone → re-solve in 1 → `matchedBest`, still Perfect, no `YENİ REKOR`; `smoke-tr-02` (opt 2) solved in 3 → `2 / 3`, no `HARİKA`, `+1`, SEN 3 / OPTİMAL 2; seeded worse best (4) then solve in 1 → `YENİ REKOR` + `▲` + best 1; restored-completed snapshot → lands on the panel, no exception. |
| F04-FE4 — panel swap (F03 regression) | widget | `test/play/play_session_screen_test.dart` | Legal winning swipe → `CompletionPanel` with `ÇÖZÜLDÜ` / `MASAL` / `HARİKA` / `Yeniden` / `Kapat`; Retry resets the board + restores the chevron; sub-threshold tap → no panel; unsupported source → load-error unchanged. |
| F04-FE4 — panel swap (runtime scenarios) | widget | `test/play/play_session_runtime_test.dart` | `qa.md §17` 1–4 unchanged; `CompletionPanel` now the win surface (2 surface sizes), no double-registered moves, kill/relaunch resume, lifecycle pause — all green. |
| F04-FE5 — build gates | tooling | — | `flutter analyze` (app + `integration_test/`): **No issues found**. `flutter test` (app): **129 passed** (+17 net new for F04). `flutter build ios --release --no-codesign`: **green** (`build/ios/iphoneos/Runner.app`, 54.6 MB). `dart format --set-exit-if-changed .`: clean. |

---

## 18. Test Notes

- The `integration_test/play_session_test.dart` device suite was updated for the `CompletionPanel` rename only; it remains the **best-effort** device form (not the CI gate) per `release.md §4` / F03-FE9 — headless timing is unchanged and out of scope here.
- No new `test/rating/` device pass is required — `architecture.md §11` folds F04's `runtime` (reveal *feel* + panel visuals) into F03's already-accepted first-app-distribution device smoke (~F05).
- Not covered by automation (matches `architecture.md §11` "runtime where a device is available"): the *feel* of the star strike / bloom / Perfect pulse, and the panel's visual parity with F03 on a real device — deferred to the shared device smoke.

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

- **Completed Tasks:** F04-FE1…FE5 — pure star function, `CompletionResult` + `BestOutcome` + `bestOutcomeFor`, additive win-path wiring in `PlaySessionController`, the real `CompletionPanel` (replaces `completion_sheet.dart`), `PlayTheme.sheet*` tokens, `RatingStrings`, and tests. `flutter analyze` clean; `flutter test` (app) 129 green, no regression; iOS release build green.
- **Remaining Tasks:** F04-QA — end-to-end client QA per `architecture.md §11` (`automated functional` mandatory: star boundaries; personal-best logic vs the real repo; panel-state matrix; F03 integration) + `ui-design.md` alignment (chrome parity, reward-reveal is a moment, CTA hierarchy, `premium-ui-rubric.md`). `runtime` (device) for the reveal *feel* folds into F03's first-app-distribution smoke.
- **Blockers:** none. Two `ui-design.md` clarification items resolved with the handoff's own defaults (surface tokens promoted; Next Level stays disabled) — recorded in §4 for Tech Lead review.
- **Status Suggestion:** Ready for QA.

---

## 19. Sonraki Komut

```
Run QA
```
