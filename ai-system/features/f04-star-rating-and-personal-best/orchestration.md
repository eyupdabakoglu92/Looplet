# F04 — star-rating-and-personal-best: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In Progress — activated 2026-09-06 (after F03 → `Done`).** Initial contract (`architecture.md`) produced by the Tech Lead: substrate LOCKED — the pure `starsForResult` / `isPerfectResult` functions; the `CompletionResult` value object + `BestOutcome`; the win-path wiring into F03's `PlaySessionController` (additive, no F03 contract change); the real completion-panel contract (7 required elements + state variants); persistence via F08's existing `PersonalBestRepo` (no schema change); `Release Scope = none`. `[PENDING — UI]` (the panel handoff) + `[PENDING — F05]` (the "Next Level" route) + `[PENDING — F07]` (Daily persistence) enumerated in `architecture.md §13`.

**F04-UI done (2026-09-06).** `ui-design.md` delivered — Direction A "The seam becomes the panel": F03's win-seam docks as the panel spine; F03's `CompletionSheet` surface + 40 % scrim verbatim (chrome parity); struck-vs-recessed-socket stars as the bounded ≤ ~800 ms deterministic reveal hero; centre-weighted SEN / OPTİMAL / EN İYİ triptych with an amber `+N` gap connective (the replay hook); six outcome variants (`firstClear` / `newBest` / `matchedBest` / `noImprovement` / `Perfect` / no-optimal) each visually distinct with non-colour cues; `HARİKA` / `YENİ REKOR` markers (text + shape); Retry primary (F03 pill) / Next Level disabled ghost-pill seam; star-group `Semantics` + `N / 3` caption. Reuses F03's `PlayTheme` — **no new tokens**. Self-review 94/100. `architecture.md §13 [PENDING — UI]` resolved. 4 non-blocking `Needs Tech Lead Clarification` items (forward note on Retry-vs-Next-Level weighting once F05 lands; keeping F03's board mounted behind the panel; optionally promoting `CompletionSheet`'s inline surface constants to `PlayTheme`; microcopy). **Next: Frontend/Mobile Developer** (F04-FE1…FE5).

---

## Current Owner

Frontend/Mobile Developer

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
- [ ] Task ID: F04-FE1 | Assigned Role: Frontend/Mobile Developer | Status: **Open — NEXT** | `app/lib/rating/star_rating.dart` — the pure `starsForResult` / `isPerfectResult` functions (never 0; upper boundary inclusive; defensive `player < optimal` → 3 + log). Unit-tested against the full AC1–AC4/AC9/AC10 table.
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
- [x] (F04-UI) `ui-design.md` — completion-panel handoff delivered 2026-09-06 (Direction A "The seam becomes the panel"; chrome parity with F03; struck-vs-socket star reveal; SEN / OPTİMAL / EN İYİ triptych; six variants; Retry primary / Next Level disabled seam; Semantics + `N / 3` caption; 94/100). `architecture.md §13 [PENDING — UI]` resolved.

### Frontend
- [ ] (F04-FE1…FE5) star function + `CompletionResult` + win-path wiring + the real panel + tests, against `architecture.md` + `ui-design.md`. **NEXT.**

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

* Updated By: UI Designer
* Timestamp: 2026-09-06
* Summary: **F04-UI complete.** `ui-design.md` delivered — Direction A "The seam becomes the panel": F03's win-seam docks as the panel spine; F03's `CompletionSheet` surface + 40 % scrim reused verbatim (chrome/atmosphere parity, board stays in frame above the panel); struck-vs-recessed-socket stars as the bounded ≤ ~800 ms deterministic reveal hero (drawn faceted glyph, one bloom per star, `Perfect` lands last); centre-weighted SEN / OPTİMAL / EN İYİ triptych on a recessed track with an amber `+N` gap connective (the replay hook); six outcome variants (`firstClear` / `newBest` celebratory / `matchedBest` / `noImprovement` / `Perfect` / no-optimal reduced) each visually distinct with non-colour cues; `HARİKA` / `YENİ REKOR` = text + shape (struck plate; `▲` caret + underline wipe); Retry primary (F03 amber pill, functional) / Next Level disabled ghost-pill `[PENDING — F05]` seam; Close quiet; star-group `Semantics` + tabular `N / 3` caption; reduced-motion = end state. Reuses F03's `PlayTheme` — **no new tokens**. Self-review 94/100 (target band). `architecture.md §13 [PENDING — UI]` resolved. 4 non-blocking `Needs Tech Lead Clarification` items (§14): (1) forward note — revisit Retry-vs-Next-Level weighting per outcome once F05 enables Next Level; (2) confirm FE keeps F03's `won` board mounted behind the F04 panel; (3) confirm promoting `CompletionSheet`'s inline surface constants to `PlayTheme` is in F04-FE4's remit; (4) microcopy → PO/localization. `Current Owner → Frontend/Mobile Developer`; `Next Role → Frontend/Mobile Developer`. `feature-board.md` + `system-state.md` **not touched** (Tech Lead syncs global surfaces).

---

## Next Role

Frontend/Mobile Developer

---

## Next Action

### Frontend/Mobile Developer — F04-FE1…FE5 — ⬅ NEXT

```text
Task: implement F04 against features/f04-star-rating-and-personal-best/architecture.md (the LOCKED
contract) + features/f04-star-rating-and-personal-best/ui-design.md (the panel handoff). No contract
changes; the F03 win-path change is ADDITIVE (no F03 contract change — F03 §10 already names F04 the
panel owner).

F04-FE1 — app/lib/rating/star_rating.dart: pure starsForResult({required int player, required int
  optimal}) + isPerfectResult(...). 3 = player == optimal; 2 = optimal < player <= optimal+3
  (upper boundary inclusive); 1 = player >= optimal+4; NEVER 0; defensive player < optimal → 3 + log.
  Unit tests: the full AC1–AC4 / AC9 / AC10 table (optimal, optimal+1..3, optimal+4, +10, +100,
  player<optimal).

F04-FE2 — app/lib/rating/completion_result.dart: the CompletionResult value object + enum
  BestOutcome {firstClear, newBest, matchedBest, noImprovement} (architecture.md §5, fields verbatim).
  app/lib/rating/rating_providers.dart: reuse F08's personalBestRepoProvider + currentGuestIdProvider;
  a clock seam (DateTime Function() default () => DateTime.now().toUtc()).

F04-FE3 — win-path wiring in app/lib/play/play_session_controller.dart (ADDITIVE): on win compute
  stars = starsForResult(player: engine.moveCount, optimal: puzzle.optimalMoves); if
  puzzle.optimalMoves < 1 → skip rating, log 'rating_blocked_no_optimal', build a bare completion
  (no stars/best). If source == journey (or the debug entry): await
  personalBestRepo.recordCompletion(guestId, levelId: puzzle.id, moveCount: engine.moveCount,
  stars: stars, optimalMoves: puzzle.optimalMoves, completedAtUtcMs: clock()) fire-and-forget with a
  CAUGHT failure (debugPrint('best_persist_failed …'); best line degrades to '—'); then read(guestId,
  puzzle.id) for the post-write bestMoveCount / isPerfect; derive BestOutcome from becameBest + prior-
  row-existed + the compare. If source == daily → skip recordCompletion (F07), ratingPersisted = false.
  Build CompletionResult; expose CompletionResult? get completion; notifyListeners().

F04-FE4 — app/lib/rating/completion_panel.dart: replaces app/lib/play/widgets/completion_sheet.dart;
  renders all 7 architecture.md §7 elements + the six ui-design.md variants + the bounded ≤ ~800 ms
  deterministic star reveal (struck-vs-recessed-socket stars, drawn faceted glyph — NOT Icons.star;
  one bloom per star; Perfect plate lands last; newBest underline wipe; N/3 caption). SEN / OPTİMAL /
  EN İYİ triptych on a recessed track + amber +N connective (= + amber wash on Perfect). Retry →
  retryFromCompletion(); Next Level = disabled ghost pill with a quiet '·yakında' / [PENDING — F05]
  affordance (inert — no toast/dialog); keep the quiet Close + _popToCaller. Panel surface = F03's
  CompletionSheet decoration verbatim over the 40 % scrim; keep F03's `won` board treatment mounted
  behind it (dim + blur + winning row + docked amber seam spine). MediaQuery.disableAnimations →
  render the reveal END STATE. Star-group Semantics ("3 / 3 yıldız — Harika"); CTA + triptych labels.
  play_session_screen.dart swaps in the F04 panel. Extend PlayStrings or add RatingStrings (FE call,
  architecture.md §13 [IMPL — Frontend]). Optionally promote CompletionSheet's inline surface consts
  to PlayTheme (sheetSurface / sheetScrim / sheetHighlight) — see clarification #3.

F04-FE5 — tests: star_rating_test.dart (the full boundary table); personal_best_flow_test.dart
  (against the REAL F08 PersonalBestRepo + an in-memory AppDatabase.forTesting — first clear / worse /
  better / matched / Perfect-then-Perfect-replay, isPerfect set iff == optimal); an F04 widget test
  (solve smoke-tr-01 optimal 1 in 1 move → 3 stars + Perfect + firstClear best 1; Retry → solve in 1
  again → matchedBest, still Perfect; the panel's 7 elements present; Next Level disabled; star-group
  Semantics announced; reduced-motion end state). analyze + format:check clean; full flutter test
  green with NO regression to the 308; iOS release build green. Append frontend.md.

Out of scope: the star numbers are FIXED (architecture.md §4); the "Next Level" route (F05); Daily
copy (F07); SFX/haptics (F11). Reuse F03's PlayTheme tokens; no new colour tokens.

End: Current Owner → QA; Next Role → QA (F04-QA — end-to-end client QA per architecture.md §11).
```

→ then `Run QA` → `Run Tech Lead` (F04 close).

---

## Change Log

* v2 (2026-09-06) — UI Designer: **F04-UI complete.** `ui-design.md` delivered — **Direction A "The seam becomes the panel"** (chosen over Direction B "trophy card takeover", which breaks F03 parity and tips gamey). F03's win-seam docks as the panel spine; F03's `CompletionSheet` surface (`#191A2B`, top radius 28, `#14FFFFFF` top border, `#000 @50%` shadow) + the 40 % scrim reused **verbatim** — chrome/atmosphere parity, and F03's `won` board treatment (dim + blur + amber winning row + seam) stays rendered above the panel. **Star rating = the hero**: struck (raised, amber-filled, one-bloom) vs recessed-socket (unearned) stars, a **drawn faceted glyph** (not `Icons.star`), revealed in a bounded ≤ ~800 ms deterministic sequence, `Perfect` (3/3) lands last with a `HARİKA` struck plate + a synchronized glow-pulse. **Replay hook = a centre-weighted SEN / OPTİMAL / EN İYİ triptych** on a recessed track (echoes the board plate) with an amber `+N` gap connective ("N away from Perfect"; flips to `=` + an amber wash on Perfect). **Six outcome variants**, each visually distinct, all driven by `CompletionResult.bestOutcome`: `firstClear` (`İLK` tag), `newBest` (celebratory — `▲` caret + `YENİ REKOR` ribbon + an underline that wipes in), `matchedBest` (silent, hairline connector), `noImprovement` (retained better best, no scolding), `Perfect` (top variant, combines with the others), no-optimal (reduced panel — no stars/caption/triptych, a muted "Puan yok" line). **Non-colour cues throughout**: struck-vs-socket depth, the tabular `N / 3` caption, `HARİKA`/`YENİ REKOR` as text + shape, the star-group `Semantics` label. **CTA hierarchy**: Retry primary (F03's amber pill, functional — `retryFromCompletion()`); Next Level a **disabled ghost pill** with a quiet `·yakında` / `[PENDING — F05]` affordance (inert — no toast/dialog); Close quiet + `_popToCaller`. Reduced motion → the reveal **end state**. Reuses F03's `PlayTheme` — **no new tokens**. Self-review **94/100** (target band; no fail conditions). `architecture.md §13 [PENDING — UI]` resolved. 4 non-blocking `Needs Tech Lead Clarification` items (§14): (1) forward note — revisit Retry-vs-Next-Level primary/secondary weighting per outcome once F05 enables Next Level (`Perfect` → Next Level primary); (2) confirm FE keeps F03's `won` board mounted behind the F04 panel; (3) confirm promoting `CompletionSheet`'s inline surface constants to `PlayTheme` (`sheetSurface`/`sheetScrim`/`sheetHighlight`) sits in F04-FE4's remit; (4) TR microcopy → PO/localization (same track as F03). `Current Owner → Frontend/Mobile Developer`; `Next Role → Frontend/Mobile Developer` (F04-FE1…FE5). `feature-board.md` / `system-state.md` untouched (Tech Lead syncs global surfaces). Nothing committed to git.
* v1 (2026-09-06) — Tech Lead: **F04 created + activated** after F03 → `Done`. P1; unblocks the P0 F05 (Journey needs the real completion panel with stars). Depends on F03 (`Done`) + F06 (`Done`, the stored `optimalMoves`); persistence **already built by F08** (`personal_best` table + `PersonalBestRepo` — monotone `recordCompletion`, `isPerfect`, preserved `firstCompletedAtUtcMs`). `prd.md` derived from `product-prd.md` F04 section (AC1–AC10 incl. the two boundary ACs + `Replay Rate > 20%`). Initial `architecture.md`: substrate LOCKED — `starsForResult`/`isPerfectResult` pure functions (3 = optimal/Perfect, 2 = optimal+1..3 inclusive, 1 = optimal+4+, **never 0**, defensive `player < optimal` → 3); `CompletionResult` + `BestOutcome {firstClear, newBest, matchedBest, noImprovement}`; **additive** win-path wiring into F03's `PlaySessionController` (no F03 contract change — F03 §10 already names F04 the panel owner); the real completion panel (7 AC7 elements + state variants + a bounded ≤ ~800 ms deterministic star-reveal) replacing `completion_sheet.dart`, over F03's dimmed board + amber seam bar; persistence via F08's existing `PersonalBestRepo` (no schema change); F04 adds no route (`Retry` → F03's `retryFromCompletion()`; `Next Level` inert/disabled = `[PENDING — F05]`); `Release Scope = none`. `[PENDING — UI]` / `[PENDING — F05]` / `[PENDING — F07]` enumerated in §13. Complexity: **not COMPLEX** (no Technical Analyst — F08 pre-built the persistence, 10 fully-specified ACs); **UI Designer required** (a win/reward-reveal panel); **no DevOps** (`Release Scope = none`). Routing: **UI Designer (F04-UI → `ui-design.md`)** → Frontend/Mobile Developer (F04-FE1…FE5) → QA → Tech Lead (close). `feature-board.md` + `system-state.md` synced (Active Feature → F04; F03 → Done; F08 unchanged / parked). Nothing committed to git.
