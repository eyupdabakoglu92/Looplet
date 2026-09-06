# F04 — star-rating-and-personal-best: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In Progress — activated 2026-09-06 (after F03 → `Done`).** Initial contract (`architecture.md`) produced by the Tech Lead: substrate LOCKED — the pure `starsForResult` / `isPerfectResult` functions; the `CompletionResult` value object + `BestOutcome`; the win-path wiring into F03's `PlaySessionController` (additive, no F03 contract change); the real completion-panel contract (7 required elements + state variants); persistence via F08's existing `PersonalBestRepo` (no schema change); `Release Scope = none`. `[PENDING — UI]` (the panel handoff) + `[PENDING — F05]` (the "Next Level" route) + `[PENDING — F07]` (Daily persistence) enumerated in `architecture.md §13`.

**F04-UI done (2026-09-06).** `ui-design.md` delivered — Direction A "The seam becomes the panel": F03's win-seam docks as the panel spine; F03's `CompletionSheet` surface + 40 % scrim verbatim (chrome parity); struck-vs-recessed-socket stars as the bounded ≤ ~800 ms deterministic reveal hero; centre-weighted SEN / OPTİMAL / EN İYİ triptych with an amber `+N` gap connective (the replay hook); six outcome variants (`firstClear` / `newBest` / `matchedBest` / `noImprovement` / `Perfect` / no-optimal) each visually distinct with non-colour cues; `HARİKA` / `YENİ REKOR` markers (text + shape); Retry primary (F03 pill) / Next Level disabled ghost-pill seam; star-group `Semantics` + `N / 3` caption. Reuses F03's `PlayTheme` — **no new tokens**. Self-review 94/100. `architecture.md §13 [PENDING — UI]` resolved. 4 non-blocking `Needs Tech Lead Clarification` items (forward note on Retry-vs-Next-Level weighting once F05 lands; keeping F03's board mounted behind the panel; optionally promoting `CompletionSheet`'s inline surface constants to `PlayTheme`; microcopy). **Next: Frontend/Mobile Developer** (F04-FE1…FE5).

---

## Current Owner

QA

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
- [x] Task ID: F04-UI | Assigned Role: UI Designer | Status: **Done (2026-09-06)** | `ui-design.md` delivered — Direction A "The seam becomes the panel" (F03 win-seam docks as the panel spine; F03 `CompletionSheet` surface + 40 % scrim verbatim; struck-vs-socket stars as the bounded ≤ ~800 ms deterministic reveal hero; centre-weighted SEN / OPTİMAL / EN İYİ triptych + amber `+N` gap connective; six outcome variants each visually distinct with non-colour cues; `HARİKA` / `YENİ REKOR` = text + shape; Retry primary F03 pill / Next Level disabled ghost-pill seam; star-group `Semantics` + `N / 3` caption). Reuses F03 `PlayTheme` — no new tokens. Self-review 94/100. `architecture.md §13 [PENDING — UI]` resolved. 4 non-blocking Tech Lead clarification notes recorded (§14).
- [x] Task ID: F04-FE1 | Assigned Role: Frontend/Mobile Developer | Status: **Done (2026-09-06)** | `app/lib/rating/star_rating.dart` — pure `starsForResult` / `isPerfectResult` (3 = `player <= optimal`, `<` branch logs; 2 = `optimal+1..+3` inclusive; 1 = `optimal+4+`; never 0). `isPerfect = stars == 3`. Unit-tested: full AC1–AC4 / AC9 / AC10 table + sweep around `optimal = 4`.
- [x] Task ID: F04-FE2 | Assigned Role: Frontend/Mobile Developer | Status: **Done (2026-09-06)** | `app/lib/rating/completion_result.dart` — `CompletionResult` (exactly `architecture.md §5` fields + `copyWith` / `personalBestAvailable` / `movesOverOptimal`) + `BestOutcome` + pure `bestOutcomeFor({player, priorBest})`. `app/lib/rating/rating_providers.dart` — `ratingClockProvider` seam; F08's `personalBestRepoProvider` + `currentGuestIdProvider` reused unchanged. `app/lib/rating/rating_strings.dart` — `RatingStrings` per-language table (chose a parallel table over extending `PlayStrings`).
- [x] Task ID: F04-FE3 | Assigned Role: Frontend/Mobile Developer | Status: **Done (2026-09-06)** | Additive win-path wiring in `play_session_controller.dart` (`_beginCompletion` sync stars → preliminary `CompletionResult`; `_resolvePersonalBest` async, **caught** failure → prior read → `recordCompletion` → read-back → `bestOutcomeFor` → `copyWith` + `notifyListeners`). New optional ctor params `personalBestRepo` / `guestId`; getters `completion` / `ratingUnavailable` / `ratingResolved` / `whenRatingResolved`. Daily → skip write (`ratingPersisted = false`). No-optimal → `ratingUnavailable`, `completion` stays `null`, logs `rating_blocked_no_optimal`. Write failure → `personalBestMoves == 0` sentinel ("—"). `_applyRestart` clears the completion. **No F03 contract field changed.**
- [x] Task ID: F04-FE4 | Assigned Role: Frontend/Mobile Developer | Status: **Done (2026-09-06)** | `app/lib/rating/completion_panel.dart` (replaces `completion_sheet.dart`, now **deleted**). All 7 AC7 elements + six variants + bounded ≤ 800 ms **one-shot** reveal (`_StarPainter` drawn faceted star — struck vs recessed socket; Perfect plate lands last + glow pulse; `N / 3` caption; SEN / OPTİMAL / EN İYİ triptych + amber `+N` / `=`; EN İYİ sub-states `İLK` / `▲`+`YENİ REKOR`+wipe underline / silent / `daha iyi` / `★`). Retry = F03 amber pill; Next Level = disabled ghost pill `·  yakında` inert (`[PENDING — F05]`); Close + `_popToCaller`. Star-group `Semantics` + `ExcludeSemantics` glyphs; reduced-motion → end-state. `play_session_screen.dart` resolves guest id + repo and renders the panel. `PlayTheme.sheetSurface`/`sheetHighlight`/`sheetRecess`/`sheetScrim` tokens added (promotes F03's inline `CompletionSheet` constants — clarification #3). `RatingStrings` chosen (clarification `[IMPL — Frontend]`); debug-entry "Next Level" stays disabled (clarification #2 default).
- [x] Task ID: F04-FE5 | Assigned Role: Frontend/Mobile Developer | Status: **Done (2026-09-06)** | `test/rating/star_rating_test.dart` (boundary table), `test/rating/personal_best_flow_test.dart` (real F08 `PersonalBestRepo` + in-memory DB — first clear / worse / better / matched / Perfect-replay + `bestOutcomeFor`), `test/rating/completion_panel_test.dart` (Perfect+firstClear all-7-AC7 + `Semantics`; Retry → matched; `smoke-tr-02` 3-move → 2 stars + `+1`; seeded worse best → `YENİ REKOR` + `▲`; restored-solved → no crash). `test/play/play_session_screen_test.dart` + `play_session_runtime_test.dart` + `integration_test/play_session_test.dart` retargeted to `CompletionPanel`. `flutter analyze` clean; `flutter test` (app) **129 green, +17 net new, no regression**; `flutter build ios --release --no-codesign` **green**; `dart format --set-exit-if-changed .` clean. `frontend.md` written.
- [ ] Task ID: F04-QA1…QAn | Assigned Role: QA | Status: **Open — NEXT** | End-to-end **client** QA per `architecture.md §11` — `automated functional` mandatory (star boundaries; personal-best logic against the real repo; panel-state matrix; F03 integration); `ui-design.md` alignment (chrome parity, reward-reveal is a moment, CTA hierarchy, `premium-ui-rubric.md`). `runtime` (device) for the reveal *feel* + panel visuals → foldable into F03's already-accepted first-app-distribution device smoke. Security compliance N/A (single actor, local-only `personal_best`, no endpoint — justify).

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
- [x] (F04-UI) `ui-design.md` — completion-panel handoff delivered 2026-09-06 (Direction A "The seam becomes the panel"; chrome parity with F03; struck-vs-socket star reveal; SEN / OPTİMAL / EN İYİ triptych; six variants; Retry primary / Next Level disabled seam; Semantics + `N / 3` caption; 94/100). `architecture.md §13 [PENDING — UI]` resolved.

### Frontend
- [x] (F04-FE1…FE5) star function + `CompletionResult` + additive win-path wiring + `CompletionPanel` (replaces `completion_sheet.dart`) + `RatingStrings` + `PlayTheme.sheet*` tokens + tests — delivered 2026-09-06. `flutter analyze` clean; `flutter test` (app) 129 green (+17 net new, no regression); iOS release build green. See `frontend.md`.

### QA
- [ ] (F04-QA) end-to-end client QA — `automated functional` mandatory. **NEXT.**

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

* Updated By: Frontend/Mobile Developer
* Timestamp: 2026-09-06
* Summary: **F04-FE1…FE5 complete.** New `app/lib/rating/`: `star_rating.dart` (pure `starsForResult` / `isPerfectResult` — 3 = `player <= optimal`, `<` logs; 2 = `optimal+1..+3` inclusive; 1 = `optimal+4+`; never 0), `completion_result.dart` (`CompletionResult` per `architecture.md §5` + `BestOutcome` + pure `bestOutcomeFor`), `rating_strings.dart` (`RatingStrings` per-language table — chosen over extending `PlayStrings`), `rating_providers.dart` (`ratingClockProvider`; F08's `personalBestRepoProvider` + `currentGuestIdProvider` reused unchanged), `completion_panel.dart` (the reward panel — replaces `completion_sheet.dart`, now **deleted**). `play_session_controller.dart` — **additive** win-path wiring (`_beginCompletion` publishes sync stars; `_resolvePersonalBest` async + **caught** — prior read → `recordCompletion` → read-back → `bestOutcomeFor` → `copyWith` + `notifyListeners`), new optional ctor params `personalBestRepo` / `guestId`, getters `completion` / `ratingUnavailable` / `ratingResolved` / `whenRatingResolved`; **no F03 contract field changed**. `play_session_screen.dart` — resolves guest id + repo, renders `CompletionPanel`. `play_theme.dart` — `sheetSurface` / `sheetHighlight` / `sheetRecess` / `sheetScrim` tokens added (promotes F03's inline `CompletionSheet` constants — clarification #3 resolved). All 7 AC7 elements + six variants + bounded ≤ 800 ms **one-shot** reveal (`_StarPainter` drawn faceted star, struck-vs-socket; Perfect plate lands last; `N / 3` caption; SEN / OPTİMAL / EN İYİ triptych + `+N` / `=`; EN İYİ sub-states; `▲` + `YENİ REKOR` + wipe underline). Retry = F03 pill; Next Level = disabled ghost pill `·  yakında` inert (`[PENDING — F05]`, clarification #2 default: debug entry stays disabled); star-group `Semantics` + `ExcludeSemantics` glyphs; reduced-motion → end-state. Clarification #1 (Retry-vs-Next-Level weighting once F05 lands) recorded as a forward note in `frontend.md §4`; clarification #4 (microcopy) unchanged → PO/localization. **`flutter analyze` clean; `flutter test` (app) 129 green (+17 net new, no regression); `flutter build ios --release --no-codesign` green; `dart format --set-exit-if-changed .` clean.** `frontend.md` written. `Current Owner → QA`; `Next Role → QA`. `feature-board.md` + `system-state.md` **not touched** (Tech Lead syncs global surfaces).

---

## Next Role

QA

---

## Next Action

### QA — F04-QA → `qa.md` — ⬅ NEXT

```text
Task: end-to-end CLIENT QA for F04 per architecture.md §11 + orchestration.md `QA Scope`. Verdict to
qa.md. Not source-only. Security compliance N/A (single actor, local-only `personal_best`, no auth,
no endpoint) — justify in the QA scope line. `Release Scope = none` → no release gate.

Authority: features/f04-star-rating-and-personal-best/architecture.md (§4 star numbers, §5
CompletionResult, §6 win-path, §7 panel + 7 AC7 elements + 6 variants, §10 validation split, §11 QA
focus), prd.md (AC1–AC10 + §7 "Replay Rate > 20%"), ui-design.md (Direction A — chrome parity, the
reward-reveal as a genuine moment, CTA hierarchy, premium-ui-rubric fail conditions), frontend.md
(delivery report + §17 test evidence).

Verify (automated functional — MANDATORY):
1. Star boundaries — the full table: player == optimal → 3 + Perfect; optimal+1/+2/+3 → 2 (AC9
   upper boundary); optimal+4/+10/+100 → 1 (AC10 + AC4 floor, never 0); defensive player < optimal
   → 3 + log. (test/rating/star_rating_test.dart)
2. Personal best vs the REAL F08 PersonalBestRepo + in-memory DB: first clear → firstClear + best =
   result, not perfect (AC8); worse → noImprovement, best unchanged (AC5); better → newBest, best
   updated, isPerfect iff == optimal (AC6); matched → matchedBest; Perfect then Perfect replay →
   stays optimal + Perfect, no newBest. (test/rating/personal_best_flow_test.dart)
3. Panel + F03 integration: solve smoke-tr-01 (opt 1) in 1 → all 7 AC7 elements, HARİKA, 3/3, first
   clear best 1; Retry → re-solve in 1 → matchedBest, still Perfect, no YENİ REKOR; smoke-tr-02
   (opt 2) in 3 → 2 stars, +1 gap; seeded worse best → YENİ REKOR + ▲; restored-solved snapshot →
   panel, no crash; star-group Semantics "3 / 3 yıldız — Harika". (test/rating/completion_panel_test.dart)
4. No regression: the F03 play/runtime/screen suites still green after the CompletionSheet →
   CompletionPanel swap; the bounded reveal is a one-shot (pumpAndSettle resolves); reduced-motion
   renders the end-state.
5. ui-design.md alignment: chrome/atmosphere parity with F03 Direction A (F03 CompletionSheet surface
   verbatim via PlayTheme.sheet*, 40% scrim, docked amber spine, board stays in frame); struck-vs-
   recessed-socket stars are a real non-colour cue (not filled/outline colour); drawn glyph (not
   Icons.star); Retry primary / Next Level disabled ghost pill (not equal-weight, not a text link);
   the six variants each render distinctly; premium-ui-rubric fail conditions absent.
6. Evidence: confirm `flutter analyze` clean, `flutter test` (app) green with no regression, and the
   iOS release build green (frontend.md §17). `runtime` (device) feel + visuals FOLD INTO F03's
   already-accepted first-app-distribution device smoke (~F05) — no separate F04 device gate.

End: QA always emits `Run Tech Lead`.
```

→ then `Run Tech Lead` (F04 close).

---

## Change Log

* v3 (2026-09-06) — Frontend/Mobile Developer: **F04-FE1…FE5 complete.** New `app/lib/rating/` package: `star_rating.dart` (pure `starsForResult` / `isPerfectResult` — 3 = `player <= optimal` with the `<` branch logging, 2 = `optimal+1..+3` inclusive, 1 = `optimal+4+`, never 0; `isPerfect = stars == 3`), `completion_result.dart` (`CompletionResult` with exactly `architecture.md §5`'s fields + `copyWith` / `personalBestAvailable` / `movesOverOptimal`; `BestOutcome`; pure `bestOutcomeFor({player, priorBest})`), `rating_strings.dart` (`RatingStrings` per-language table — chose a parallel table over extending `PlayStrings`, `[IMPL — Frontend]`), `rating_providers.dart` (`ratingClockProvider`; F08's `personalBestRepoProvider` + `currentGuestIdProvider` reused unchanged), `completion_panel.dart` (the F04 reward panel — replaces `app/lib/play/widgets/completion_sheet.dart`, now **deleted**). **Additive** win-path wiring in `play_session_controller.dart`: `_beginCompletion()` computes stars synchronously (needs only `moveCount` + `optimalMoves`) and publishes a preliminary `CompletionResult`; `_resolvePersonalBest()` (async, **caught** failure — same posture as `_persist`) reads the prior best → `recordCompletion(...)` → reads back → `bestOutcomeFor` → `copyWith` + `notifyListeners()`. New optional ctor params `personalBestRepo` / `guestId`; getters `completion` / `ratingUnavailable` / `ratingResolved` / `whenRatingResolved`. `optimalMoves < 1` → `ratingUnavailable`, `completion` stays `null`, logs `rating_blocked_no_optimal` (bare completion). Daily (`source != journey`) → skip write, `ratingPersisted = false`. Write failure → `personalBestMoves == 0` sentinel ("—"). `_applyRestart()` clears the completion. **No F03 contract field changed** (F03 §10 already names F04 the panel owner). `play_session_screen.dart` resolves the guest id + `PersonalBestRepo` in `_init()` and renders `CompletionPanel` (scrim → `PlayTheme.sheetScrim`). `play_theme.dart` — `sheetSurface` / `sheetHighlight` / `sheetRecess` / `sheetScrim` tokens added (promotes F03's inline `CompletionSheet` constants — **clarification #3 resolved**, additive, no F03 behaviour change). Panel: all 7 AC7 elements + six variants (`firstClear` / `newBest` / `matchedBest` / `noImprovement` / `Perfect` / no-optimal) + a bounded ≤ 800 ms **one-shot** `AnimationController` reveal (no `repeat()` → `pumpAndSettle` resolves): `_StarPainter` **drawn faceted star** (not `Icons.star`) — struck (raised, amber, one bloom, `easeOutBack` pop) vs **recessed socket**; `HARİKA` struck plate lands last (`Interval(0.60, 0.82)`) + synchronised 3-star glow pulse; `N / 3` caption; kicker + 22 pt subordinate word; **SEN / OPTİMAL / EN İYİ** triptych on a recessed track + amber `+N` connective (`=` on Perfect); EN İYİ sub-states (`İLK` / `▲` + `YENİ REKOR` + wiping underline / silent match / `daha iyi` + `★` when `bestIsPerfect`); `—` when `personalBestMoves <= 0`. Retry = F03 amber pill (`retryFromCompletion()`); Next Level = disabled ghost pill with `·  yakında` affordance, inert (no toast/dialog), `Semantics(enabled: false)` — **clarification #2 default: debug-entry Next Level stays disabled**; Close + `_popToCaller`; chevron hidden in `won`. Star-group `Semantics` ("3 / 3 yıldız — Harika") + `ExcludeSemantics` glyphs; triptych cells `"label: value"`; reduced-motion (`accessibilityFeatures.disableAnimations`) → reveal **end-state**. **Clarification #1** (revisit Retry-vs-Next-Level weighting per outcome once F05 enables Next Level — `Perfect` → Next Level primary) recorded as a forward note in `frontend.md §4`; **clarification #4** (microcopy) unchanged → PO/localization. Tests: `test/rating/star_rating_test.dart` (boundary table + sweep), `test/rating/personal_best_flow_test.dart` (real F08 `PersonalBestRepo` + in-memory DB — first clear / worse / better / matched / Perfect-replay + `bestOutcomeFor`), `test/rating/completion_panel_test.dart` (Perfect + firstClear all-7-AC7 + `Semantics`; Retry → matched; `smoke-tr-02` 3-move → 2 stars + `+1`; seeded worse best → `YENİ REKOR` + `▲`; restored-solved → no crash). `test/play/play_session_screen_test.dart` + `play_session_runtime_test.dart` + `integration_test/play_session_test.dart` retargeted to `CompletionPanel` (scenarios unchanged). **`flutter analyze` clean (app + integration_test); `flutter test` (app) 129 passed — +17 net new for F04, no regression; `flutter build ios --release --no-codesign` green (`Runner.app`, 54.6 MB); `dart format --output=none --set-exit-if-changed .` clean.** `frontend.md` written. `Current Owner → QA`; `Next Role → QA`. `feature-board.md` / `system-state.md` untouched (Tech Lead syncs global surfaces). Nothing committed to git.
* v2 (2026-09-06) — UI Designer: **F04-UI complete.** `ui-design.md` delivered — **Direction A "The seam becomes the panel"** (chosen over Direction B "trophy card takeover", which breaks F03 parity and tips gamey). F03's win-seam docks as the panel spine; F03's `CompletionSheet` surface (`#191A2B`, top radius 28, `#14FFFFFF` top border, `#000 @50%` shadow) + the 40 % scrim reused **verbatim** — chrome/atmosphere parity, and F03's `won` board treatment (dim + blur + amber winning row + seam) stays rendered above the panel. **Star rating = the hero**: struck (raised, amber-filled, one-bloom) vs recessed-socket (unearned) stars, a **drawn faceted glyph** (not `Icons.star`), revealed in a bounded ≤ ~800 ms deterministic sequence, `Perfect` (3/3) lands last with a `HARİKA` struck plate + a synchronized glow-pulse. **Replay hook = a centre-weighted SEN / OPTİMAL / EN İYİ triptych** on a recessed track (echoes the board plate) with an amber `+N` gap connective ("N away from Perfect"; flips to `=` + an amber wash on Perfect). **Six outcome variants**, each visually distinct, all driven by `CompletionResult.bestOutcome`: `firstClear` (`İLK` tag), `newBest` (celebratory — `▲` caret + `YENİ REKOR` ribbon + an underline that wipes in), `matchedBest` (silent, hairline connector), `noImprovement` (retained better best, no scolding), `Perfect` (top variant, combines with the others), no-optimal (reduced panel — no stars/caption/triptych, a muted "Puan yok" line). **Non-colour cues throughout**: struck-vs-socket depth, the tabular `N / 3` caption, `HARİKA`/`YENİ REKOR` as text + shape, the star-group `Semantics` label. **CTA hierarchy**: Retry primary (F03's amber pill, functional — `retryFromCompletion()`); Next Level a **disabled ghost pill** with a quiet `·yakında` / `[PENDING — F05]` affordance (inert — no toast/dialog); Close quiet + `_popToCaller`. Reduced motion → the reveal **end state**. Reuses F03's `PlayTheme` — **no new tokens**. Self-review **94/100** (target band; no fail conditions). `architecture.md §13 [PENDING — UI]` resolved. 4 non-blocking `Needs Tech Lead Clarification` items (§14): (1) forward note — revisit Retry-vs-Next-Level primary/secondary weighting per outcome once F05 enables Next Level (`Perfect` → Next Level primary); (2) confirm FE keeps F03's `won` board mounted behind the F04 panel; (3) confirm promoting `CompletionSheet`'s inline surface constants to `PlayTheme` (`sheetSurface`/`sheetScrim`/`sheetHighlight`) sits in F04-FE4's remit; (4) TR microcopy → PO/localization (same track as F03). `Current Owner → Frontend/Mobile Developer`; `Next Role → Frontend/Mobile Developer` (F04-FE1…FE5). `feature-board.md` / `system-state.md` untouched (Tech Lead syncs global surfaces). Nothing committed to git.
* v1 (2026-09-06) — Tech Lead: **F04 created + activated** after F03 → `Done`. P1; unblocks the P0 F05 (Journey needs the real completion panel with stars). Depends on F03 (`Done`) + F06 (`Done`, the stored `optimalMoves`); persistence **already built by F08** (`personal_best` table + `PersonalBestRepo` — monotone `recordCompletion`, `isPerfect`, preserved `firstCompletedAtUtcMs`). `prd.md` derived from `product-prd.md` F04 section (AC1–AC10 incl. the two boundary ACs + `Replay Rate > 20%`). Initial `architecture.md`: substrate LOCKED — `starsForResult`/`isPerfectResult` pure functions (3 = optimal/Perfect, 2 = optimal+1..3 inclusive, 1 = optimal+4+, **never 0**, defensive `player < optimal` → 3); `CompletionResult` + `BestOutcome {firstClear, newBest, matchedBest, noImprovement}`; **additive** win-path wiring into F03's `PlaySessionController` (no F03 contract change — F03 §10 already names F04 the panel owner); the real completion panel (7 AC7 elements + state variants + a bounded ≤ ~800 ms deterministic star-reveal) replacing `completion_sheet.dart`, over F03's dimmed board + amber seam bar; persistence via F08's existing `PersonalBestRepo` (no schema change); F04 adds no route (`Retry` → F03's `retryFromCompletion()`; `Next Level` inert/disabled = `[PENDING — F05]`); `Release Scope = none`. `[PENDING — UI]` / `[PENDING — F05]` / `[PENDING — F07]` enumerated in §13. Complexity: **not COMPLEX** (no Technical Analyst — F08 pre-built the persistence, 10 fully-specified ACs); **UI Designer required** (a win/reward-reveal panel); **no DevOps** (`Release Scope = none`). Routing: **UI Designer (F04-UI → `ui-design.md`)** → Frontend/Mobile Developer (F04-FE1…FE5) → QA → Tech Lead (close). `feature-board.md` + `system-state.md` synced (Active Feature → F04; F03 → Done; F08 unchanged / parked). Nothing committed to git.
