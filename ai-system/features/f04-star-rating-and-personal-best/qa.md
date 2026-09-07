# F04 — star-rating-and-personal-best: QA Report

> Current state of QA for F04. Overwrites any prior version.

---

## 0a. Evidence Mode Declaration

* Bash / build access: **VAR**
* e2e test suite (Playwright / Cypress / Detox): **YOK** — the `integration_test/` device suite exists but is best-effort (not a CI gate; not run here)
* Screenshot / browser tool: **YOK**
* Runtime validation method: **`automated functional`** — `flutter_test` widget tests (`pumpAndSettle`, one-shot animation controllers), Drift in-memory `AppDatabase.forTesting`, and the **real F08 `PersonalBestRepo`**. `architecture.md §11` makes `automated functional` the mandatory class for F04 and explicitly folds `runtime` (device) *feel* + visuals into F03's already-accepted first-app-distribution device smoke (~F05) — no separate F04 device gate. Not `source-only`.

---

## 1. Feature Summary

* **Feature under test:** F04 — star rating (1–3, never 0; 3 ⇔ Perfect ⇔ `player == optimal`) + the real completion panel (replaces F03's minimal seam sheet) + per-level personal best via F08's existing `PersonalBestRepo`.
* **QA scope:** end-to-end **client** (no backend). `automated functional` mandatory; `ui-design.md` UI-handoff compliance; F03 win-path regression.

---

## 2. Test Scope

* **Scope Type:** Client Only + UI Handoff Compliance.
* **Reviewed documents:** `prd.md` (AC1–AC10, §6 constraints, §7 Replay Rate > 20 %), `architecture.md` (§4 star numbers, §5 `CompletionResult`, §6 win-path, §7 panel + 7 AC7 elements + 6 variants, §10 validation split, §11 QA focus, §12 `Release Scope = none`), `ui-design.md` (Direction A), `frontend.md` (delivery + §17 evidence), `orchestration.md` (QA Scope), `design/design-doctrine.md`, `design/premium-ui-rubric.md`.
* **Tested areas:** the pure star function boundaries; personal-best logic against the real F08 repo + in-memory DB; the `bestOutcomeFor` derivation; the completion-panel content (AC7) + reveal + `Perfect` / `firstClear` / `matchedBest` / `newBest` variants; F03 win-path integration + regression (`CompletionSheet` → `CompletionPanel` swap); `Retry` re-solve cycle; restored-solved session; chrome / atmosphere parity with F03; CTA hierarchy; reduced-motion; accessibility (star-group `Semantics`).
* **Not tested / gaps found:** the **`noImprovement`** panel variant rendering (logic-covered only); the **no-optimal bare fallback** (`_BareBody`, `rating_blocked_no_optimal`) — neither rendered nor logged in any test. See `## 8` F04-QA-2. The `flutter analyze` gate is **red** — see F04-QA-1.
* **Out-of-scope conditional sections:**
  * `0. Backend Build Gate` — no backend touched (`Release Scope = none`, client-only). The client gate results are in `## 6.7`-style prose below and `## 14`.
  * `6.5 Security Compliance Check` — **Security compliance out of scope:** single actor (the player), local-only `personal_best` table, no auth, no network, no endpoint, no cross-user data (`architecture.md §3` / `§11`).
  * `6.7 Release / CI-CD Compliance Check` — **Release compliance out of scope:** `Release Scope = none` (`architecture.md §12`, `release.md §2`) — no Cloud Functions / rules / Remote Config / content pack / schema change / new distributable surface. CI code gates still apply and are reported in `## 4` / `## 8`.
  * `6.8 iOS Platform Compliance Check` — **iOS platform compliance out of scope:** no `game-dev.md`, Flutter (not Unity) client; no new SDK / IAP / tracking. (iOS *build* still verified — see `## 4`.)
  * `13. Backend Quality` — **Backend quality out of scope:** no backend.
  * `14a` / `14b` Game sections — no `game-dev.md`.
* **Critical user journeys:** (a) solve a level → see a star rating + the comparison + Retry; (b) beat a previous best → see the "new best" treatment; (c) hit optimal → "Perfect"; (d) Retry and solve again → matched best, no false "new best".
* **Forbidden / misuse journeys:** Daily source → rating shown, **not** persisted (F07, not reachable in F04 scope — journey/debug only); a second completion of the same level must not corrupt the monotone best; a write failure must not block the panel; `Next Level` must be inert (no navigation, no toast).
* **Navigation / header consistency scope:** the panel is an overlay on `/play` (no new route); back chevron hidden in `won`; `Close` / system back → `_popToCaller`; `Retry` → in-place restart. Compared against F03's `ui-design.md §4` chrome rules and the (now-deleted) `CompletionSheet` behaviour.
* **Evidence class summary:** `automated functional` (widget + unit tests, real F08 repo, in-memory DB) for all functional/AC coverage; `source-only` cross-check for the two uncovered variants (F04-QA-2). No `runtime`/device evidence (folded into F03's device smoke per `architecture.md §11`).
* **Runtime validation method:** `automated functional`.

---

## 3. Product Behavior Coverage

| User Story (`prd.md §2`) | Test scenario | Evidence | Result |
| --- | --- | --- | --- |
| "1–3 star rating on completion, so I know how close I got" | `smoke-tr-01` (optimal 1) solved in 1 → 3 stars; `smoke-tr-02` (optimal 2) solved in 3 → 2 stars; unit table for 1-star | `completion_panel_test.dart` (2 tests) + `star_rating_test.dart` | **PASS** |
| "See optimal vs my moves and my personal best side by side, so I'm motivated to retry" | Triptych renders `SEN` / `OPTİMAL` / `EN İYİ` with values + the amber `+N` gap; asserted for Perfect (`=`) and 2-star (`+1`) | `completion_panel_test.dart` — "every AC7 element" + "smoke-tr-02 … +1 gap" | **PASS** |
| "'Perfect' marker when I hit optimal, so true mastery feels rewarded" | `player == optimal` → `HARİKA` plate + `3 / 3` caption + Semantics "3 / 3 yıldız — Harika" | `completion_panel_test.dart` — first test; `star_rating_test.dart` — Perfect rows | **PASS** |
| "See when I've beaten my previous best, so improvement feels recognized" | Seeded prior best 4 for `smoke-tr-01`, solve in 1 → `YENİ REKOR` + `▲` + best line 1 | `completion_panel_test.dart` — "a beaten prior best → new best treatment" | **PASS** |

All four user stories are covered by at least one automated scenario with a named test. Replay Rate > 20 % (`prd.md §7`) is a post-launch analytics metric (F12), not QA-verifiable here — noted, not a gap.

---

## 3a. Mode / Configuration Matrix

The panel has six logic-driven variants (`architecture.md §7`, driven by `CompletionResult.bestOutcome` + `isPerfect` + optimal-availability). Each must render distinctly.

| Variant | Expected behaviour | Tested? | Result | Evidence |
| --- | --- | --- | --- | --- |
| `firstClear` | no prior row → best = this result; `İLK` tag; no "new best" | **Yes** (path exercised) | PASS (path); tag text not asserted | `completion_panel_test.dart` "every AC7 element" — fresh DB, `EN İYİ: 1`, `YENİ REKOR` absent |
| `newBest` | beat prior best → `▲` + `YENİ REKOR` + wiping underline; best = this run | **Yes** | PASS | `completion_panel_test.dart` "a beaten prior best" |
| `matchedBest` | equalled best → no celebratory mark; best unchanged | **Yes** (path exercised) | PASS (path); no-tag state not explicitly asserted | `completion_panel_test.dart` "Retry → solve again in 1 → matched best" |
| `noImprovement` | worse than best → this-run stars shown, `daha iyi` tag, retained **better** best on `EN İYİ`, `SEN` shows the worse run | **No** | **GAP** | logic covered by `personal_best_flow_test.dart` (`bestOutcomeFor` + repo, AC5); **panel render path has no test** |
| `Perfect` | `player == optimal` (3 stars) → `HARİKA` plate, `=` connective; combines with the above | **Yes** | PASS | `completion_panel_test.dart` first test + "Retry … still Perfect" |
| no-optimal fallback | `optimalMoves < 1` → `_BareBody`: kicker + word + `SEN {moves}` + "Puan yok"; no stars / caption / triptych; `debugPrint('… rating_blocked_no_optimal …')` | **No** | **GAP** | not reachable via the debug library (all `optimalMoves >= 1`); no controller-level or provider-override test constructs a `optimalMoves: 0` puzzle |

Two variants (`noImprovement`, no-optimal) lack rendering evidence → blocking finding **F04-QA-2** (`architecture.md §11` lists all six as required; Mode/Configuration Matrix rule: an untested variant is a blocking finding).

---

## 4. Acceptance Criteria Traceability

| AC (`prd.md §3`) | Test scenario | Evidence | Covered |
| --- | --- | --- | --- |
| **AC1** optimal 6 / player 6 → 3 + "Perfect" recorded | `starsForResult(6,6)==3`, `isPerfectResult(6,6)==true`; `recordCompletion(6, opt 6)` → `isPerfect` true | `star_rating_test.dart` "player == optimal → 3"; `personal_best_flow_test.dart` "a better result → newBest … isPerfect true" | ✅ |
| **AC2** optimal 6 / player 7–9 → 2 | `starsForResult(7|8|9, 6) == 2` | `star_rating_test.dart` "optimal+1 .. optimal+3 inclusive → 2" | ✅ |
| **AC3** optimal 6 / player ≥ 10 → 1 | `starsForResult(10|16|106, 6) == 1` | `star_rating_test.dart` "optimal+4 → 1" + "arbitrarily far" | ✅ |
| **AC4** any completion → stars ≥ 1 (never 0) | `starsForResult(106, 6) == 1`; `starsForResult(5, 1) == 1` | `star_rating_test.dart` "arbitrarily far from optimal → still 1, never 0" | ✅ |
| **AC5** prior best 7 / new 9 → best stays 7 | `recordCompletion(11)` after best 9 → returns false, `read` still 9; `bestOutcomeFor(11,9)==noImprovement` | `personal_best_flow_test.dart` "a worse result → noImprovement, best unchanged" | ✅ (logic) — panel render of this state is the F04-QA-2 gap |
| **AC6** prior best 7 / new 5 → best 5, "Perfect" iff 5 == optimal | `recordCompletion(6)` after best 9 → true, `read` 6, `isPerfect` true (opt 6) | `personal_best_flow_test.dart` "a better result → newBest … isPerfect iff == optimal" | ✅ |
| **AC7** panel shows target word, player moves, optimal, stars, personal best, Retry, Next Level | asserts `MASAL`, `SEN`+`SEN: 1`, `OPTİMAL`+`OPTİMAL: 1`, `3 / 3` + `HARİKA`, `EN İYİ`+`EN İYİ: 1`, `Yeniden`, `SONRAKİ` | `completion_panel_test.dart` "every AC7 element" | ✅ |
| **AC8** no prior best → best set to current result | fresh DB, `bestOutcomeFor(9,null)==firstClear`; `read` after `recordCompletion(9)` → 9 | `personal_best_flow_test.dart` "first clear → firstClear + best = result"; `completion_panel_test.dart` first test (`EN İYİ: 1` on a fresh DB) | ✅ |
| **AC9** player exactly optimal+3 → 2 (upper boundary inclusive) | `starsForResult(9, 6) == 2`; `starsForResult(7, 4) == 2` | `star_rating_test.dart` "optimal+1 .. optimal+3 inclusive" + "boundary sweep around optimal = 4" | ✅ |
| **AC10** player exactly optimal+4 → 1 (lower boundary) | `starsForResult(10, 6) == 1`; `starsForResult(8, 4) == 1` | `star_rating_test.dart` "optimal+4 → 1" + "boundary sweep" | ✅ |

Contract items (`architecture.md`): §4 defensive `player < optimal` → 3 + log — covered (`star_rating_test.dart` "defensive player < optimal → 3 (logged)"). §5 `CompletionResult` shape — covered implicitly by `completion_panel_test.dart` + `personal_best_flow_test.dart`. §6 win-path additive wiring — covered by `completion_panel_test.dart` (win → panel with real repo values) + `play_session_*` regression suites. §6 `rating_blocked_no_optimal` — **NOT covered** (F04-QA-2). §7 six variants render distinctly — **`noImprovement` + no-optimal NOT covered** (F04-QA-2).

All 10 numbered ACs have at least one test. Two contract-level scenarios (`§6` no-optimal log, `§7` `noImprovement` render) are uncovered → F04-QA-2.

---

## 5. Boundary Matrix

| Boundary / transition | Result | Evidence |
| --- | --- | --- |
| Star function — lower edge `player == optimal` → 3 | PASS | `star_rating_test.dart` AC1 |
| Star function — 2★/1★ split at `optimal+3` / `optimal+4` | PASS | `star_rating_test.dart` AC9 / AC10 + sweep |
| Star function — far tail (`optimal+100`) → floor 1, never 0 | PASS | `star_rating_test.dart` AC4 |
| Star function — impossible `player < optimal` → 3 + log | PASS | `star_rating_test.dart` "defensive" |
| Personal best — first write (no prior row) | PASS | `personal_best_flow_test.dart` AC8 |
| Personal best — monotone: worse result is a no-op | PASS | `personal_best_flow_test.dart` AC5 |
| Personal best — improvement overwrites + sets `isPerfect` | PASS | `personal_best_flow_test.dart` AC6 |
| Personal best — equal result (`matchedBest`), no rewrite | PASS | `personal_best_flow_test.dart` "an equal result" |
| Personal best — Perfect then Perfect replay → stays optimal + Perfect, not `newBest` | PASS | `personal_best_flow_test.dart` "Perfect then a Perfect replay" |
| Reveal lifecycle — one-shot `AnimationController`, settles under `pumpAndSettle` | PASS | all `completion_panel_test.dart` tests settle; no timeout |
| Retry cycle — win → panel → `Yeniden` → panel gone → re-solve → panel again, `_completion` recomputed | PASS | `completion_panel_test.dart` "Retry → solve again in 1 → matched best" |
| Restored-solved session (`ActiveSessionStatus.completed` snapshot that failed to clear) → lands on the panel, no crash | PASS | `completion_panel_test.dart` "a restored-solved session lands on the panel without crashing" |
| Write failure → best line degrades to "—", stars still shown, panel not blocked | **NOT tested** | `personalBestMoves == 0` sentinel path (`_resolvePersonalBest` catch) has no fault-injection test — see Note N3 |
| No-optimal (`optimalMoves < 1`) → bare completion + log | **NOT tested** | F04-QA-2 |
| `noImprovement` panel render (retained better best + `daha iyi` + worse `SEN`) | **NOT tested** | F04-QA-2 |
| Daily source → rating shown, not persisted (F07 seam) | Not reachable in F04 scope (journey/debug only) — deferred to F07 | `architecture.md §6` / `§13 [PENDING — F07]` |

---

## 6. Contract Compliance Check

| Area | Result | Notes |
| --- | --- | --- |
| API contract | N/A | No API — client-only, local `personal_best` only. |
| Request / response | N/A | — |
| Error format | PASS | Persistence failure is caught (`_resolvePersonalBest` `try/catch` → `debugPrint('… best_persist_failed …')`); panel still renders computed stars; best line → "—". No user-facing error surface (matches `architecture.md §6`). Fault path itself is not test-covered (Note N3). |
| Validation | PASS | Star boundaries, "never 0" floor, defensive `player < optimal`, `isPerfect == (stars == 3)` — all match `architecture.md §4` and are unit-tested. |
| Auth | N/A | Single actor; guest id read via F08's `currentGuestIdProvider` for the `personal_best` key only. |
| Data handling | PASS | Uses F08's existing `PersonalBestRepo.recordCompletion(...)` unchanged — no new table / column / migration (`architecture.md §9`). `completedAtUtcMs` from the injected clock; only feeds `firstCompletedAtUtcMs` (preserved once set). Verified against `personal_best_repo.dart` + `app_database.dart` (`personal_best` table, PK `{guestId, levelId}`). |
| `CompletionResult` shape (`§5`) | PASS | Fields match `architecture.md §5` verbatim; the `personalBestMoves == 0` "unavailable" sentinel is a documented convention (`architecture.md §6` "degrades to —"), not a field addition. |
| Win-path additivity (`§6`) | PASS | `PlaySessionController` change is additive — `_beginCompletion()` / `_resolvePersonalBest()` appended to the existing solved branch + the restored-solved ctor branch; no F03 getter/method signature changed; `retryFromCompletion()` semantics preserved + now nulls `_completion`. F03 suites (`play_session_controller_test`, `play_session_runtime_test`, `play_session_screen_test`) all still green. |
| Contract version / breaking change | PASS | No F03 / F06 / F08 contract touched. `PlaySessionController` gained optional ctor params (`personalBestRepo`, `guestId`) — non-breaking; existing callers/tests compile unchanged. |
| Client build gate — `dart format --set-exit-if-changed .` | PASS | 130 files, 0 changed. |
| Client build gate — `flutter analyze` (app) | **FAIL** | Exit 1 — `unnecessary_import` (`info`) of `package:flutter/semantics.dart` at `test/rating/completion_panel_test.dart:3`. `melos run analyze` gate is red. → **F04-QA-1**. |
| Client build gate — `flutter test` (app) | PASS | **129 / 129**. |
| Client build gate — workspace `dart test` (pure packages) | PASS | core 22, dictionary 32, engine 83, content 17, solver 23, authoring 19 → **196 / 196**. Workspace total **325 / 325** (baseline 308 + 17 F04). |
| Client build gate — `flutter build ios --release --no-codesign` | PASS | `build/ios/iphoneos/Runner.app`, 54.6 MB (per `frontend.md §17`; not re-run this pass — no native/pubspec change since). |

---

## 7. UI Design Compliance Check

* **ui-design.md present?** Yes — Direction A "The seam becomes the panel".
* **Screen goal:** ✅ the star rating is the hero (top of the panel, largest, the animated element); the your-moves/OPTIMAL/best triptych is the clear second block; CTAs are the base. Matches `ui-design.md §3` first-3-seconds order.
* **UX flow:** ✅ panel rises over F03's `won` board (board Column stays mounted behind the `Positioned` overlay; scrim `PlayTheme.sheetScrim` ≈ 40 %); reveal is a bounded one-shot; `Retry` restarts in place; `Close` / system back → `_popToCaller`; back chevron hidden in `won`. Matches `ui-design.md §4`.
* **Visual hierarchy:** ✅ stars (46 pt drawn glyphs) > triptych (recessed track, `OPTİMAL` emphasized 32 pt) > CTAs > subordinate 22 pt word. No competing hero.
* **CTA priority:** ✅ `Retry` = F03's amber `_RetryCta` pill verbatim (primary); `Next Level` = disabled ghost pill (`Border.all(muted @ .3)`, `muted @ .45` label, `·  yakında` suffix, `Semantics(enabled: false)`, `onTap: null` — inert, no toast/dialog); `Close` = quiet muted text. Not equal-weight, not a text link. Matches `ui-design.md §7`.
* **State visibility:** ✅ `firstClear` / `newBest` (`▲` + `YENİ REKOR` + wiping underline) / `matchedBest` / `Perfect` (`HARİKA` struck plate + `=` connective) render distinctly. ⚠️ `noImprovement` + no-optimal render paths are unverified (F04-QA-2) — code inspection shows `_BestCell` handles `noImprovement` (`daha iyi` tag) and `_BareBody` handles no-optimal, but neither is exercised.
* **Background / surface / depth:** ✅ `PlayTheme.sheetSurface` `#191A2B` + top radius 28 + `BoxShadow(#80000000, y-8, blur 32)` — F03 `CompletionSheet` decoration. Recessed triptych track (`PlayTheme.sheetRecess` `#12131F` + top hairline). Struck stars raised (amber radial fill + bloom via `saveLayer` + `easeOutBack` scale) vs recessed sockets (`plate` fill + dark inner stroke, scale ≈ 0.9). Amber `_Spine` (3 pt, end-faded gradient + glow) at the panel top. ⚠️ Minor deviation: the panel `Container` omits F03's 1 px `#14FFFFFF` top-highlight border — the `_Spine` occupies that edge instead (Note N1).
* **Typography:** ✅ reuses `PlayTheme` roles — `completionStat` tabular figures, `microLabel` tracked caps, `completionWord` at reduced 22 pt for the subordinate word, `HARİKA` as `microLabel` w800 amber. No new type system.
* **Premium quality:** ✅ drawn faceted star (not `Icons.star`), struck-vs-socket depth as the non-colour cue, docked seam spine, spelled-out `+N` / `=` gap, targeted `newBest` mark (not a full-panel colour flash). Aligns with `ui-design.md` self-review 94/100; no `premium-ui-rubric.md` "Fail Conditions" present (clear hero, dominant CTA, strong state design, layered surfaces, non-generic). Rubric estimate ≥ 90.
* **Accessibility:** ✅ star group is one `Semantics(label: '3 / 3 yıldız — Harika')` node with `ExcludeSemantics` on the glyphs; triptych cells `Semantics(label: 'OPTİMAL: 1')` etc.; `HARİKA` / `YENİ REKOR` are real text + a non-colour shape (plate / `▲` + underline); reduced-motion (`accessibilityFeatures.disableAnimations`) → reveal end-state (`_startOrSettle` sets `_reveal.value = 1`). Reduced-motion path is code-verified, not test-covered (Note N2).

**UI verdict:** handoff is faithfully implemented; the only deviation is the cosmetic top-highlight (N1). Rubric ≥ 90, no fail conditions. UI is **not** the source of the blocking findings.

---

## 8. Test Findings

### F04-QA-1

* **Title:** `flutter analyze` (app) fails — `unnecessary_import` of `package:flutter/semantics.dart` in a new test file
* **Severity:** Medium (trivial code, but the `melos run analyze` CI gate is red → blocks merge)
* **Area:** Client build gate / lint
* **Related Task:** F04-FE5
* **Type:** Regression Risk (CI gate) / Functional Bug (build gate)
* **Description:** `app/test/rating/completion_panel_test.dart:3` imports `package:flutter/semantics.dart`, but every symbol used (`Semantics`, `SemanticsProperties` via `.properties`) is already provided by the `package:flutter/material.dart` import on line 2. `flutter analyze` reports `info • unnecessary_import` and **exits 1**. `frontend.md §17` claims "`flutter analyze` clean" — this is no longer true for the delivered file state.
* **Expected:** `flutter analyze` (app) exits 0 — the `melos run analyze` gate is green.
* **Actual:** `1 issue found.` / exit 1.
* **Recommendation:** remove the `package:flutter/semantics.dart` import line from `completion_panel_test.dart`. Re-run `flutter analyze` (app) → expect 0 issues.

### F04-QA-2

* **Title:** Two required panel variants have no rendering test — `noImprovement` and the no-optimal bare fallback
* **Severity:** Medium (blocking per `architecture.md §11` + the Mode/Configuration Matrix rule)
* **Area:** Frontend test coverage
* **Related Task:** F04-FE5
* **Type:** State/Flow Bug (coverage gap on a contract-mandated variant matrix)
* **Description:** `architecture.md §7` and `§11` require **all six** panel variants (`firstClear` / `newBest` / `matchedBest` / `noImprovement` / `Perfect` / no-optimal) to render distinctly, with evidence.
  * **`noImprovement`** — the panel path that shows this run's (worse) `SEN`, the retained **better** `EN İYİ`, and the `daha iyi` tag, with no "new best". Only the pure `bestOutcomeFor` + repo monotonicity is tested (`personal_best_flow_test.dart`, AC5). The `_BestCell` `noImprovement` branch (`tag = strings.betterKept`, rendered in the non-`newBest` path) is never exercised. **Reachable in the widget harness:** seed `personal_best` (guest, `smoke-tr-02`, best 2), then solve `smoke-tr-02` in 3 (one wasted row-1 shift + two row-0 shifts) → `bestOutcomeFor(3, 2) == noImprovement`, `EN İYİ` shows 2, `SEN` shows 3, `daha iyi` tag visible.
  * **no-optimal fallback** — `_beginCompletion()` with `optimalMoves < 1` sets `ratingUnavailable`, leaves `completion == null`, and `debugPrint`s `rating_blocked_no_optimal`; the screen then renders `_BareBody` (kicker + word + `SEN {moves}` + "Puan yok", no stars/caption/triptych). Nothing exercises this — all `DebugPuzzleLibrary` puzzles have `optimalMoves >= 1`. Reachable via a controller-level unit test with a hand-built `Puzzle(optimalMoves: 0)`, or a `playSessionSetupProvider` / puzzle override in a widget test.
* **Expected:** each of the six variants has at least one test proving its distinct render (per `architecture.md §11`).
* **Actual:** 4 of 6 covered; `noImprovement` and no-optimal are not.
* **Recommendation:** add (1) a `noImprovement` widget test on `smoke-tr-02` with a seeded better prior best, asserting `SEN`/`EN İYİ` values + the `daha iyi` tag + absence of `YENİ REKOR`; (2) a no-optimal test (controller-level is acceptable) asserting `ratingUnavailable == true`, `completion == null`, and — if a widget test — `_BareBody` content ("Puan yok", no `CompletionPanel` stars/triptych). Optionally also assert the `firstClear` `İLK` tag and `matchedBest` no-tag states while there.

---

## 9. Positive Scenarios

1. **Perfect first clear.** Start: `smoke-tr-01` loaded (optimal 1), no `personal_best` row. Action: swipe row 0 right → `MASAL`. Visible result: the completion panel rises; three struck stars + `HARİKA` plate + `3 / 3` caption; `SEN 1` / `OPTİMAL 1` / `EN İYİ 1` with a `=` connective; `Yeniden` (amber) + `SONRAKİ` (disabled, `yakında`) + `Kapat`. Screen reader announces "3 / 3 yıldız — Harika". Evidence: `completion_panel_test.dart` "smoke-tr-01 solved in 1 … every AC7 element".
2. **New best.** Start: `personal_best` seeded at 4 for `smoke-tr-01`. Action: solve in 1. Visible result: `YENİ REKOR` ribbon + `▲` caret + best line 1. Evidence: `completion_panel_test.dart` "a beaten prior best".
3. **Matched best, no false celebration.** Start: after a Perfect clear (best 1). Action: `Yeniden` → panel dismisses, board relights, `MOVES 0`; solve in 1 again. Visible result: panel returns, `HARİKA` still shown, **no** `YENİ REKOR`, `EN İYİ 1`. Evidence: `completion_panel_test.dart` "Retry → solve again in 1 → matched best".
4. **2-star, gap made explicit.** Start: `smoke-tr-02` (optimal 2), fresh. Action: one wasted row-1 shift + two row-0 shifts → win in 3. Visible result: `2 / 3` caption, no `HARİKA`, `+1` gap connective, `SEN 3` / `OPTİMAL 2`. Evidence: `completion_panel_test.dart` "smoke-tr-02 solved in 3".
5. **Regression — F03 win path intact.** The `CompletionSheet` → `CompletionPanel` swap did not break F03: `play_session_screen_test.dart` (winning swipe → panel with `ÇÖZÜLDÜ` / `MASAL` / `Yeniden` / `Kapat`; Retry resets + restores chevron; sub-threshold no panel; unsupported source → load error) and `play_session_runtime_test.dart` (`qa.md §17` 1–4, two surface sizes, no double-registered moves, kill/relaunch, lifecycle pause) all green.

---

## 10. Negative / Edge Cases

| Case | Behaviour | Evidence |
| --- | --- | --- |
| Second completion of the same level (Retry → solve again) | `recordCompletion` called again; F08 repo is monotone → worse-or-equal is a no-op; no best corruption; `_completion` recomputed (not stale) | `completion_panel_test.dart` "Retry → matched best"; `personal_best_flow_test.dart` "equal result → no rewrite" |
| Restored **completed** snapshot that failed to clear | Controller lands directly in `won` and `_beginCompletion()` runs; panel renders; no exception | `completion_panel_test.dart` "a restored-solved session lands on the panel without crashing" (`expect(tester.takeException(), isNull)`) |
| `Next Level` tapped in F04 scope | Inert — `onTap: null`, `Semantics(enabled: false)`; no navigation, no toast, no dialog | code-verified (`_NextLevelCta`); `completion_panel_test.dart` asserts `SONRAKİ` + `yakında` present (disabled affordance) |
| `player < optimal` (impossible / defensive) | `starsForResult` returns 3 + `debugPrint`; `isPerfectResult` stays `true` (stars == 3) | `star_rating_test.dart` "defensive player < optimal → 3 (logged)" |
| Daily source | Not reachable in F04 (journey/debug only); `_resolvePersonalBest` gates on `source == journey` → would skip the write, `ratingPersisted = false` | code-verified; `architecture.md §6` / `§13 [PENDING — F07]` |
| Personal-best **write failure** (storage full) | Caught → `debugPrint('… best_persist_failed …')`; `personalBestMoves = 0` → panel shows "—"; stars still shown; panel not blocked | code-verified only — **no fault-injection test** (Note N3; shared debt with F03 note 3 / F08 AC7) |
| no-optimal puzzle | `_BareBody` + `rating_blocked_no_optimal` log | **NOT verified** — F04-QA-2 |

---

## 12. UX & State Handling

* **Loading:** the personal-best read-back is a local Drift call; the controller publishes stars synchronously (`_beginCompletion`) and fills the best line on `_resolvePersonalBest` completion. Between the two, `personalBestMoves == 0` → `EN İYİ` shows "—". In tests this window is invisible after `pumpAndSettle`. `ui-design.md §8` "best-cell loading" shimmer is **not** implemented as a distinct shimmer — the panel shows "—" then the value. Acceptable simplification (the window is ~0 frames locally); noted, non-blocking.
* **Error:** persistence failure → "—" on the best line, stars intact, no error UI (matches `architecture.md §6`). Fault path untested (N3).
* **Empty:** N/A — a completion always has content; the closest state is the no-optimal `_BareBody` (untested — F04-QA-2).
* **Success:** the reveal — struck stars in sequence, `HARİKA` last, `newBest` underline wipe. Deterministic one-shot; `pumpAndSettle` resolves in every test.
* **Disabled:** `Next Level` — ghost pill, `muted @ .45`, `Semantics(enabled: false)`, inert. Clear and distinct from the amber `Retry`.
* **Selected / Focused:** no selectable elements on the panel; CTAs are `Semantics(button: true)`. `ui-design.md §8` focus-ring spec is inherited platform behaviour, not custom — acceptable.
* **CTA clarity:** `Retry` unmistakably dominant (amber gradient pill, shadow); `Next Level` clearly secondary/disabled; `Close` tertiary. ✅
* **Visual hierarchy / background / surface / typography / motion:** see `## 7` — all aligned; only the 1 px top highlight is dropped (N1).
* **Runtime evidence summary:** `automated functional` — widget tests drive the real `PlaySessionScreen` + `PlaySessionController` + `CompletionPanel` against a real F08 `PersonalBestRepo` on an in-memory DB; the full win → compute → persist → read-back → variant flow is exercised end-to-end for 4 of 6 variants. Device *feel* / visuals fold into F03's first-app-distribution smoke (`architecture.md §11`).

---

## 14. Frontend Quality

* **Structure:** clean new `app/lib/rating/` package (`star_rating.dart`, `completion_result.dart`, `rating_strings.dart`, `rating_providers.dart`, `completion_panel.dart`); the pure function and value object are I/O-free and well-unit-tested. `completion_sheet.dart` removed; all 5 references updated.
* **Additivity:** the `PlaySessionController` change is genuinely additive (verified against the F03 contract + the passing F03 suites). No F03 signature changed.
* **Reuse:** F08's `PersonalBestRepo` / `personalBestRepoProvider` / `currentGuestIdProvider` reused unchanged (no schema change). F03's `PlayTheme` extended with `sheet*` tokens (promotes the old inline `CompletionSheet` constants — the `ui-design.md §14.3` suggestion).
* **Determinism:** the reveal is a one-shot `AnimationController` (no `repeat()`); reduced-motion short-circuits to the end-state. Widget-test-safe.
* **Gaps:** F04-QA-1 (lint gate red), F04-QA-2 (two uncovered variants), N3 (write-failure path untested).
* **`Semantics` handle hygiene:** `completion_panel_test.dart` deliberately avoids `tester.ensureSemantics()` (reads `Semantics` widget `.properties.label` directly) — a sound choice that dodges the end-of-test handle-disposal assertion.

---

## 15. UI Handoff Alignment

* **Aligned:** panel surface = F03 `CompletionSheet` family (`PlayTheme.sheet*`); 40 % scrim; docked amber `_Spine`; struck-vs-recessed-socket stars (drawn glyph, not `Icons.star`); bounded ≤ 800 ms one-shot reveal; `HARİKA` plate lands last + glow pulse; `N / 3` caption; centre-weighted `SEN` / `OPTİMAL` / `EN İYİ` triptych on a recessed track; amber `+N` / `=` gap connective; `newBest` = `▲` + ribbon + wiping underline; `Retry` primary (F03 pill) / `Next Level` disabled ghost pill with `[PENDING — F05]` affordance / quiet `Close`; star-group `Semantics`; reduced-motion end-state; board stays mounted behind the panel.
* **Acceptable technical differences:** the "best-cell loading shimmer" (`ui-design.md §8`) is rendered as "—" → value rather than a shimmer (local read is ~0 frames); the `+N` connective omits the "amber wash on the whole track" on Perfect (shows `=` only) — a mild simplification, still legible.
* **Deviation (Note N1, non-blocking):** the panel `Container` omits F03's 1 px `#14FFFFFF` top-highlight border; the amber `_Spine` sits on that edge instead. `ui-design.md §5` lists both. Confirm the spine is the intended replacement, or restore the hairline beneath it.
* **No unacceptable UX / visual regressions.** No `premium-ui-rubric.md` fail condition. Rubric ≥ 90.

---

## 16. Regression Risk

Shared surfaces this feature touches:

| Surface | Dependents | Impact assessed |
| --- | --- | --- |
| `PlaySessionController` (F03) | `play_session_screen.dart`, F03 tests, future F05/F07 | Additive change only; new ctor params optional; `retryFromCompletion()` behaviour preserved + extended (nulls `_completion`). All F03 suites (`play_session_controller_test` 11, `play_session_runtime_test` 13, `play_session_screen_test` 5) green. **No regression.** |
| `play_session_screen.dart` (F03) | route `/play` | `CompletionSheet` → `CompletionPanel` swap; scrim literal → `PlayTheme.sheetScrim` (same value `0x66000000`); `_init()` now also resolves guest id + repo (guarded try/catch). Board Column still mounted behind the panel. Screen + runtime suites green. **No regression.** |
| `PlayTheme` (F03) | `play/*`, now `rating/*` | Four `sheet*` tokens **added** (no existing token changed). **No regression.** |
| `personal_best` table + `PersonalBestRepo` (F08) | F07 (Daily), future sync | **Read + `recordCompletion` only — no schema / method change.** F08's own tests unaffected (196 pure-package tests green). Monotonicity + `firstCompletedAtUtcMs` preservation are F08's contract, re-exercised by `personal_best_flow_test.dart`. **No regression.** |
| `integration_test/play_session_test.dart` | best-effort device gate (not CI) | `CompletionSheet` → `CompletionPanel` rename only. Not run this pass (best-effort per `release.md §4`). |
| `debug_puzzle_library.dart`, `home_screen.dart`, `app_router.dart` | — | Untouched. |

Workspace: **325 / 325** tests green (196 pure + 129 app). The only red signal is `flutter analyze` (F04-QA-1).

---

## 17. Final Verdict

**Rejected.**

Two blocking findings:

* **F04-QA-1** — `flutter analyze` (app) exits 1 (`unnecessary_import` in `completion_panel_test.dart`); the `melos run analyze` CI gate is red. `frontend.md`'s "analyze clean" claim does not hold for the delivered file state.
* **F04-QA-2** — the `noImprovement` panel variant and the no-optimal bare fallback have **no rendering test**, though `architecture.md §7` / `§11` require all six variants to render distinctly with evidence (and the Mode/Configuration Matrix rule makes an untested variant a blocking finding). Both are reachable in the existing test harness.

Everything else is sound: all 10 numbered ACs are covered; the star function, the personal-best logic (against the real F08 repo), and 4 of 6 panel variants are verified; the F03 win-path change is additive with no regression (325/325 tests green); UI-handoff compliance is strong (rubric ≥ 90, no fail conditions, one cosmetic deviation N1). The fixes are small and well-scoped.

**No `Runtime Validation Pending`** — evidence mode is `automated functional` (not `source-only`); the blocking items are a lint-gate failure and a coverage gap, not missing runtime tooling.

### Non-blocking notes (address opportunistically; not required for approval)

* **N1** — panel `Container` drops F03's 1 px `#14FFFFFF` top-highlight border; the amber `_Spine` occupies that edge. Confirm intended or restore the hairline.
* **N2** — reduced-motion end-state path and the `firstClear` `İLK` / `matchedBest` no-tag states are code-correct but not asserted; consider tightening alongside F04-QA-2.
* **N3** — the personal-best **write-failure** path (`_resolvePersonalBest` catch → `personalBestMoves = 0` → "—") has no fault-injection test. Shared debt with F03 QA note 3 / F08 AC7 (storage-full). Track, don't gate.
* **N4** — device *feel* (star strike / bloom / Perfect pulse) + real-device visual parity with F03 fold into F03's already-accepted first-app-distribution device smoke (~F05) per `architecture.md §11` — not a separate F04 gate.

---

# WORKFLOW VERDICT SUGGESTION (NON-AUTHORITATIVE)

## QA Result

* **Rejected** — 2 blocking findings (1 lint-gate failure, 1 contract-mandated variant-coverage gap). Feature logic + UI are otherwise sound; fixes are minor.

## Affected Areas

* Frontend (test file lint + test coverage). UI handoff and architecture contract are **not** at fault.

## Blocking Issues

1. **F04-QA-1** — `flutter analyze` red: remove `package:flutter/semantics.dart` from `app/test/rating/completion_panel_test.dart`.
2. **F04-QA-2** — add rendering tests for the `noImprovement` variant (seed better prior best on `smoke-tr-02`, solve in 3) and the no-optimal bare fallback (`Puzzle(optimalMoves: 0)` — controller-level acceptable).

## Suggested Fix Order

1. **Frontend/Mobile Developer** — F04-QA-1 (drop the import) + F04-QA-2 (two new tests; optionally N2's tag assertions). Re-run `flutter analyze` (app) → 0 issues; `flutter test` (app) → all green.
2. **QA** — re-verify.

---

## 19. Sonraki Komut

```
Run Tech Lead
```

---

## 20. Tech Lead Note

* Verdict **Rejected** on two small Frontend items — **not** a design or contract problem. Root cause of both is F04-FE5 (test authoring): a redundant import that reddens `flutter analyze`, and a variant-matrix coverage gap (`noImprovement` + no-optimal) that `architecture.md §11` requires closed.
* Route the fix to **Frontend/Mobile Developer** (F04-QA-1 + F04-QA-2). `ui-design.md` needs no change; the one UI deviation (N1, dropped top-highlight) is non-blocking and can be folded into the same turn or left as-is with a one-line confirmation.
* No release/state implications: `Release Scope = none`, no schema/infra change, F08's `personal_best` untouched. The F03 win-path change is additive and regression-clean (325/325 workspace tests).
* On re-verify PASS, F04 → `Done`; F05 (P0, needs the real completion panel) unblocks. N3 (write-failure fault injection) and N4 (device feel) are tracked follow-ons, consistent with the F03 close-out notes — they should not gate F04.
