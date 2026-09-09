# F05 — journey-progression: QA Report (re-verify)

> Current state of QA for F05. Overwrites the prior `Rejected` report. This is a **focused re-verify** of the two blocking findings from that report (F05-QA-1, F05-QA-2) + the Tech Lead-ruling notes closed in F05-FE2 (N1/N2/N3/N4/N6 + the AC2 assertion), plus a no-regression confirmation. The first pass's verified coverage — all 14 ACs, the unlock rule against the real F08 `JourneyProgressRepo`, the read-model, CONTINUE/terminal resolution, the resolver + degradation, the F04 CTA weighting, `ui-design.md` handoff alignment — is carried forward and re-confirmed against the current tree.

---

## 0a. Evidence Mode Declaration

* Bash / build access: **VAR**
* e2e test suite (Playwright / Cypress / Detox): **YOK** — `app/integration_test/` device suite exists (best-effort, not a CI gate, not run here)
* Screenshot / browser tool: **YOK**
* Runtime validation method: **`automated functional`** — `flutter_test` widget + unit tests (`pumpAndSettle`, one-shot / reduced-motion animation, `FakeAccessibilityFeatures`), Drift in-memory `AppDatabase.forTesting`, the **real F08 `JourneyProgressRepo` / `JourneyTutorialRepo` / `ActiveSessionRepo`**, a real `GoRouter` + `PlaySessionScreen` for the navigation flow, `rootBundle` asset loading in a widget-binding test. `architecture.md §15` makes `automated functional` mandatory and folds device `runtime` into the deferred first-app-distribution smoke. **Not `source-only`** (full build/test access was used).

---

## 1. Feature Summary

* **Feature:** F05 — wire F03's isolated play session into a 30-level linear campaign: the level-identity scheme, a bundled Journey content pack + manifest + resolver, a progression read-model over F08's `journey_progress`, the unlock write on the F04 win path, CONTINUE / `Next Level` / terminal navigation, the levels 4–6 column micro-tutorial, the real home surface, and the F04 `CompletionPanel` per-outcome CTA weighting.
* **QA scope (this pass):** re-verify F05-FE2 — the AC12 `Next Level` navigation coverage (F05-QA-1), the `mode:"strict"` gate coverage (F05-QA-2), the in-progress home motion + widget coverage + tutorial-band + AC11-chain + CONTINUE-pill-width closures, and no regression. Client-only, `automated functional`, `ui-design.md` UI-handoff compliance.

---

## 2. Test Scope

* **Scope Type:** Client Only + UI Handoff Compliance (re-verify).
* **Reviewed documents:** `qa.md` (the prior `Rejected` report), `frontend.md` "F05-FE" + the new "F05-FE2" section, `architecture.md` (LOCKED — amended 2026-09-09: §5.4 / §12 / §15 / §17), `prd.md` (AC1–AC14), `ui-design.md` (Direction A), `orchestration.md` (F05-FE2 ledger + the DURUM 5 reconcile + the re-verify brief), `design/premium-ui-rubric.md`, `design/design-doctrine.md §8`.
* **Re-verified this pass:** F05-QA-1 (the `Next Level` / `SONRAKİ` tap → navigation chain); F05-QA-2 (the gate's `mode:"strict"` failure path); N2 (`_JourneyRing` breathing pulse + terminal entry bloom, reduced-motion → static); N1 (the in-progress home widget variant); N3 (tutorial not shown outside the 4–6 band); N4 (the chained AC11 re-show); N6 (CONTINUE pill width); the AC2 "no F05 navigation path resolves to a `locked` level" assertion; full-suite no-regression; `analyze` / `format` / iOS-release-build gates.
* **Carried forward from the first pass (still valid — the only `lib/` change is `home_screen.dart`'s ring motion + the pill width; everything else is test-only):** AC1/AC3–AC11/AC13/AC14 coverage; the unlock write ordering + caught-failure posture; the `LevelState` derivation + `progressCount` clamp + `continueTarget`; CONTINUE / terminal resolution; the 4–6 tutorial gate + ack-persist + leave-doesn't-persist; the bundled-content resolver + `JourneyContentException` → F03 load-error; the F04 `CompletionPanel` one-amber-pill CTA weighting (3★ → `SONRAKİ`, 1–2★ → `Yeniden`, `· yakında` only when unwired); F03-stage chrome parity; no new `PlayTheme` tokens.
* **Deferred by contract (`[PENDING — F06-CONTENT]`, not an F05-FE2 gate):** AC3 / AC5 / AC6 difficulty-curve bands + the gate's **structural** band rules — need the 30 authored levels + a `mode:"strict"` manifest; F05 → `Done` is separately gated on "strict gate green" (`architecture.md §5.5`, §17). F05-QA-2's fix (the bare `strict ⇒ 30` + asset-resolution checks) is in place now.
* **Out-of-scope conditional sections (with reason):**
  * `0. Backend Build Gate` — **no backend**; `Release Scope = none`; the client CI gate results are in `## 6`.
  * `6.5 Security Compliance Check` — **Security compliance out of scope:** single actor, local-only `journey_progress` + one `kv` flag, no auth / network / endpoint / cross-user resource (`architecture.md §15`).
  * `6.7 Release / CI-CD Compliance Check` — **Release compliance out of scope:** `Release Scope = none` (`architecture.md §13`); no infra / CI config / deploy / container / env / schema change. Code CI gates still apply and are reported in `## 6`.
  * `6.8 iOS Platform Compliance Check` — **iOS platform compliance out of scope:** Flutter (not Unity) client, no `game-dev.md`, no new SDK / IAP / tracking. (iOS release *build* verified — `## 6`.)
  * `13. Backend Quality` — **Backend quality out of scope:** no backend.
  * `14a` / `14b` Game sections — no `game-dev.md`.
* **Critical user journeys re-checked:** solve a Journey level → tap `SONRAKİ` → advance to level N+1 (or the terminal home on the last level); the CI guarantee that a `mode:"strict"` pack shipping `< 30` / a broken asset fails; the home's in-progress resume affordance; the 4–6 tutorial gate not leaking outside its band and re-showing until acknowledged. **Forbidden / misuse:** no navigation path to a locked level (asserted); replay must not re-lock or inflate progress (carried forward).
* **Navigation / chrome scope:** `/` (app root, no back) ⇄ `/play` (F03 chrome + `_popToCaller` `/` fallback); no new routes; `Next Level` = `pushReplacement` (verified — no back-stack growth); terminal + tutorial are in-screen states.
* **Evidence class summary:** `automated functional` for every re-verified item; `source-only` cross-check only for the deferred device-feel of the new ring motion.
* **Runtime validation method:** `automated functional`.

---

## 3. Product Behavior Coverage

| User Story (`prd.md §2`) | Re-verify scenario | Evidence | Result |
| --- | --- | --- | --- |
| "30 sequential levels that unlock as I finish them" | (carried) solving a Journey level marks it complete + unlocks the next; Retry + re-solve is idempotent | `test/journey/journey_unlock_flow_test.dart` (green in the 176) | **PASS** |
| "CONTINUE drops me straight into my current level" | new → level 1; mid → the next gap; **in-progress → that level, `· sürüyor` caption**; terminal → `TEKRAR OYNA` → level 1 | `test/journey/journey_home_test.dart` (4 cases incl. the new in-progress variant) | **PASS** |
| "difficulty ramps gently, one new idea at a time" | the 4–6 column intro is gated, taught, re-shows until acknowledged, and **does not leak outside the band** | `test/journey/column_tutorial_test.dart` (5 cases incl. the new band-negative + chained AC11) | **PASS** (F05-FE part; the curve bands are `[PENDING — F06-CONTENT]`) |
| "see how far through the Journey I am" | ring `Semantics` accurate at 0 / 1 / 3 / 30 completed | `journey_home_test.dart` `hasSemanticsLabel` assertions | **PASS** |
| "`Next Level` takes me onward" (AC12) | tap `SONRAKİ` → level N+1's `/play` via `pushReplacement`; last level → terminal home | `test/journey/journey_next_level_test.dart` (2 cases) | **PASS** (was the F05-QA-1 gap) |

---

## 3a. Mode / Configuration Matrix

| Mode / Configuration | Expected | Tested? | Result | Evidence |
| --- | --- | --- | --- | --- |
| Manifest `mode:"smoke"` (interim, shipped) | gate asserts consistency, logs the `< 30` shortfall, **passes** | Yes | **PASS** | `journey_manifest_gate_test.dart` (real bundle via `runJourneyManifestGate`); `journey_manifest_strict_test.dart` "smoke + < 30 → passes, shortfall reported" |
| Manifest `mode:"strict"` + `< 30` levels | gate **FAILS** (violation names the shortfall) | **Yes (now)** | **PASS** | `journey_manifest_strict_test.dart` "strict + < 30 levels → gate FAILS" — **was F05-QA-2** |
| Manifest `mode:"strict"` + an unresolvable asset | gate **FAILS** | **Yes (now)** | **PASS** | `journey_manifest_strict_test.dart` "strict + a missing/unresolvable asset → gate FAILS" |
| Manifest `mode:"strict"` + exactly 30 valid levels | gate **PASSES**, `shortfall == 0` | Yes | **PASS** | `journey_manifest_strict_test.dart` "strict + exactly 30 valid levels → gate PASSES" |
| Manifest — a broken asset in `smoke` mode | still **FAILS** (consistency enforced in both modes) | Yes | **PASS** | `journey_manifest_strict_test.dart` "smoke + a broken asset → still FAILS" |
| `strict` **structural band rules** | deferred | No — documented | **DEFERRED** | `journey_manifest_gate_test.dart` "band rules …" stub + `journey_gate_support.dart` doc — `[PENDING — F06-CONTENT]` (needs the real 30 levels) |
| Home — brand new / mid / **in-progress** / terminal / loading | distinct render + CONTINUE target per state | Yes | **PASS** | `journey_home_test.dart` (all 4 non-loading variants; loading carried from pass 1) |
| CompletionPanel — 3★ / 1–2★ / unwired | one amber pill; 3★ → amber `SONRAKİ`; 1–2★ → amber `Yeniden` + enabled ghost `SONRAKİ`; unwired → disabled + `· yakında` | Yes (carried) | **PASS** | `test/rating/completion_cta_weighting_test.dart` (green in the 176) |
| Micro-tutorial — level ∈ 4..6 / ack set / **level ∉ 4..6** / **re-show after quit** | shown / suppressed / **not shown** / **re-shows until the gated column drag** | Yes | **PASS** | `column_tutorial_test.dart` (5 cases) |
| In-progress node motion — animate / **reduced motion** | breathing pulse + terminal bloom / static end-state | Yes | **PASS** | `journey_home_test.dart` runs all cases under `FakeAccessibilityFeatures(disableAnimations: true)` and settles; `_JourneyRing._syncMotion` guards `repeat()` / `forward()` on `!_reduceMotion` |

---

## 4. Acceptance Criteria Traceability

| AC | Requirement | Evidence | Result |
| --- | --- | --- | --- |
| **AC1** | complete N (any star) → N+1 unlocked | `journey_unlock_flow_test.dart` + `journey_progress_model_test.dart` (carried) | **PASS** |
| **AC2** | locked N+1 not openable (no navigation; locked affordance) | `journey_progress_model_test.dart` "no F05 navigation target is ever a `locked` level" (new / mid / in-progress / terminal + last-available). Per `architecture.md §12`/§15 (amended): satisfied **by construction** — no MVP surface can request an arbitrary level; the explicit locked *affordance* is `[DEFERRED — F10]` (`prd.md §5` — no level-select map). | **PASS** (by construction, test-asserted) |
| **AC3 / AC5 / AC6** | difficulty-curve bands | `[PENDING — F06-CONTENT]` — the interim smoke set knowingly re-ids F06's set; F05 `Done` gated on the strict gate | **DEFERRED (content)** — not an F05-FE gate |
| **AC4** | first 4–6 entry → column micro-tutorial + column enabled | `column_tutorial_test.dart` "shows on level 4 …" | **PASS** |
| **AC7** | CONTINUE on an in-progress level → resumes exact saved state | `journey_progress_model_test.dart` (in-progress derivation) + **`journey_home_test.dart` new in-progress variant** (`· sürüyor` caption + `Semantics` + CONTINUE → the in-progress level). The F08 restore of grid/moves/undo/thawed/elapsed is F03's proven `restoreFrom` path (`play_session_runtime_test.dart §17.3`). | **PASS** (the F05 resolution + affordance are now widget-tested; the F08 restore internals are F03's) |
| **AC8** | no in-progress → lowest unlocked-incomplete | `journey_progress_model_test.dart` + `journey_home_test.dart` | **PASS** |
| **AC9** | all 30 → graceful terminal, no crash | `journey_progress_model_test.dart` + `journey_home_test.dart` (terminal ring + `TAMAMLANDI` + `TEKRAR OYNA`, no exception) | **PASS** |
| **AC10** | progress indicator visible + accurate | `journey_home_test.dart` — ring `Semantics` exact at 0 / 1 / 3 / 30 | **PASS** |
| **AC11** | force-quit during the 4–6 tutorial → re-shows until acknowledged | `column_tutorial_test.dart` "force-quit before the gated move → re-shows on the next 4–6 entry (AC11)" — mount → tear down (no column move) → ack still `false` → re-mount → **overlay re-shows** → a column drag clears + persists → re-mount → gone | **PASS** (now a single chained scenario) |
| **AC12** | `Next Level` (N<30, n+1 present) → level N+1's `/play`; N==30 / last available → terminal | `journey_next_level_test.dart` — tap `SONRAKİ` → level N+1 via `pushReplacement` (`GoRouter.canPop() == false` — no back-stack growth; `routeLog == [1, 2]`); last-available → `context.go('/')` → terminal home (`routeLog == [2]`). Level-30 clause covered transitively (same `nextJourneyLevel → null → context.go('/')` path; `nextJourneyLevel(30, …) == null` unit-tested in `journey_ids_test.dart`; a real 30-level manifest test is `[PENDING — F06-CONTENT]`). | **PASS** (was the F05-QA-1 gap) |
| **AC13** | Journey level at 1★ → `Next Level` available | `completion_cta_weighting_test.dart` (2★ → `SONRAKİ` present + enabled, no `· yakında`; 1★ takes the identical branch) — carried | **PASS** (by construction) |
| **AC14** | offline → bundled load + local save | `journey_manifest_gate_test.dart` (real pack via `rootBundle`, no network) + source inspection (no network path in the F05 resolver) — carried | **PASS** |

**Uncovered / failing AC:** none. AC3/AC5/AC6 are contract-deferred to `F06-CONTENT`.

---

## 5. Boundary Matrix

| Boundary / transition | Result | Evidence |
| --- | --- | --- |
| `Next Level` from level N (n+1 present) → N+1 via `pushReplacement`, no stack growth | **PASS** | `journey_next_level_test.dart` case 1 (`canPop() == false`, `routeLog == [1, 2]`) |
| `Next Level` from the last available level → `context.go('/')` → terminal | **PASS** | `journey_next_level_test.dart` case 2 (`routeLog == [2]`, `HOME ROUTE` shown) |
| `Next Level` from level 30 → terminal | **PASS (transitive)** | same code branch as "last available"; `nextJourneyLevel(30, …) == null` unit-tested (`journey_ids_test.dart`) |
| Manifest `mode:"strict"` + `< 30` → gate rejects | **PASS** | `journey_manifest_strict_test.dart` |
| Manifest `mode:"strict"` + missing asset → gate rejects | **PASS** | `journey_manifest_strict_test.dart` |
| Manifest `mode:"smoke"` + `< 30` → gate passes, shortfall reported | **PASS** | `journey_manifest_strict_test.dart` + `journey_manifest_gate_test.dart` (real bundle) |
| 4–6 tutorial — shown / row-drag-doesn't-satisfy / column-drag-clears / ack-suppresses / **band-negative** / **re-show-after-quit** | **PASS** (all 6) | `column_tutorial_test.dart` (5 cases; row-drag-doesn't-satisfy is a mid-assertion of case 1) |
| `continueTarget` — never a `locked` level; `null` only in the terminal state | **PASS** | `journey_progress_model_test.dart` "no F05 navigation target is ever a `locked` level" |
| In-progress ring motion — animate vs reduced motion | **PASS** | `_JourneyRing._syncMotion` guards; `journey_home_test.dart` settles under reduced motion |
| `markCompleted` overshoot ("31") → `progressCount` clamps | **PASS (carried)** | `journey_progress_model_test.dart` |
| Resolver — missing entry / missing asset / corrupt JSON / id mismatch → `JourneyContentException`, rest playable | **PASS (carried)** | `journey_content_repo_test.dart` |

---

## 6. Contract Compliance Check

Client CI gates (canonical commands per `setup-manifest.md` — run directly; `melos` not on PATH):

| Gate | Command | Result |
| --- | --- | --- |
| Analyze | `flutter analyze` (app) | **PASS** — "No issues found!" |
| Format | `dart format --output=none --set-exit-if-changed app packages tools` | **PASS** — 147 files, 0 changed |
| Test (app) | `flutter test` | **PASS** — **176/176** (was 166; +10 net new F05-FE2; pre-existing drift "multiple databases" warnings in `play_session_screen_test.dart` only — non-fatal, not introduced here) |
| Test (`test/journey` + `test/rating`) | `flutter test test/journey test/rating` | **PASS** — 64/64 |
| Test (pure packages) | `dart test` in `looplet_{core,dictionary,engine,content,solver}` + `looplet_authoring` | **PASS** — 22 / 32 / 83 / 17 / 23 / 19 |
| Content-manifest gate | `flutter test test/journey/journey_manifest_gate_test.dart` (`melos run content:journey`) | **PASS** — 4/4 (smoke shortfall logged); now runs the shared `runJourneyManifestGate` |
| iOS release build | `flutter build ios --release --no-codesign` | **PASS** — `Runner.app` 54.7 MB |
| Android appbundle | `flutter build appbundle --release` (`melos run build:app`) | **NOT RUN — CI-only** (no local JDK / Android SDK; consistent with F03/F04 precedent) |

| Contract area (`architecture.md`, incl. the 2026-09-09 amendment) | Compliance |
| --- | --- |
| §5.4 — gate `smoke` / `strict`; the `strict` branch carries interim unit coverage now | **PASS** — `journey_gate_support.dart` (one shared gate) + `journey_manifest_strict_test.dart` (5 cases); band rules stay `[PENDING — F06-CONTENT]` stub |
| §8 — `Next Level` = `pushReplacement`; last / level 30 → `context.go('/')`; no back-stack growth | **PASS** — `journey_next_level_test.dart` (trigger→outcome, `canPop() == false`) |
| §12 + §15 — AC2 satisfied by construction, test-asserted; no hot-path guard; the affordance `[DEFERRED — F10]` | **PASS** — `journey_progress_model_test.dart` no-nav-to-locked; **no resolver guard added** (per the DURUM 5 ruling — N5 accepted) |
| §16 — F04 `CompletionPanel` one-amber-pill CTA weighting | **PASS (carried)** — `completion_cta_weighting_test.dart` + F04 `completion_panel_test.dart` regression green |
| No F03/F04/F06/F08 contract change | **PASS** — the only `lib/` delta is `home_screen.dart` (ring motion + pill width, additive); `_JourneyRing` gained internal `AnimationController`s; no signature / schema / route change |
| `ui-design.md §7.1` / §11 — in-progress breathing pulse + terminal entry bloom | **PASS** — `_pulse` (≈4 s) + `_bloom` (one-shot); reduced-motion → static end-state (`ui-design.md §13`). Minor: the pulse is a 0→+6 % swell rather than a symmetric ±6 % — see Note N2. |
| `ui-design.md §7.2` — CONTINUE pill ~66–72 % width | **PASS** — `_ContinueCta` width = `(maxWidth * 0.68).clamp(220, 320)` (was a fixed 240) |

Contract **version / breaking change:** none.

---

## 7. UI Design Compliance Check

* **`ui-design.md` present:** yes (Direction A "The loop, filling"). Visual validation: `automated functional` (widget structure + `Semantics` + `CustomPainter` params) + source inspection of the `home_screen.dart` motion. No screenshot tool — pixel-level polish + on-device feel remain a device-smoke item (`architecture.md §15`).
* **Screen goal / UX flow / visual hierarchy / CTA priority / background / surface / typography:** **PASS (carried)** — unchanged by F05-FE2 (F03 `PlayStage` parity, ring hero + `N / 30` centre, one dominant amber CONTINUE, no new tokens).
* **State visibility — in-progress variant:** **PASS (now closed)** — the `cyan` current-node ring **plus the specified ~4 s breathing pulse** now ship (`_pulse` on the tip-dot scale + cyan opacity); `journey_home_test.dart` asserts the `Seviye N · sürüyor` caption + the `Semantics` line + the CONTINUE target for this state. Was N2 in the prior pass.
* **State visibility — terminal:** **PASS (now closed)** — full-amber ring + `TAMAMLANDI` **plus the "one restrained bloom on entry"** (`_bloom` one-shot, `#FFE9C2` halo fading out over ~620 ms; reduced-motion → not drawn). Was N2 in the prior pass.
* **CTA quality:** **PASS** — the CONTINUE pill is now `(maxWidth * 0.68).clamp(220, 320)` — within the `ui-design.md §7.2` 66–72 % band and still the sole filled control (was N6).
* **Premium quality:** **PASS** — `premium-ui-rubric.md` Fail Conditions **absent** (clear hero, one dominant CTA, strong hierarchy, layered surface, non-generic 30-tick loop, "top mobile game" register); no `design-doctrine.md §8` anti-pattern. Estimated rubric ≥ 90 holds; the added motion strengthens differentiator #3 ("the current node — cyan ring + breathing pulse"). Reduced-motion path renders the specified static end-states.
* **Accessibility:** **PASS (carried)** — the ring is one `Semantics` node; CONTINUE announces its target; reduced motion honoured.

---

## 8. Test Findings

No blocking findings. The two prior-pass blocking items are closed:

- **F05-QA-1 (AC12 `Next Level` navigation)** — **CLOSED.** `test/journey/journey_next_level_test.dart` drives a real `GoRouter` + `PlaySessionScreen`: solve level N → tap the rendered `SONRAKİ` → the screen shows level N+1's `/play` via `pushReplacement` (`GoRouter.of(ctx).canPop() == false` ⇒ the `/play` frame was swapped, not stacked; `routeLog == [1, 2]`); solve the last-available level → tap `SONRAKİ` → `context.go('/')` → the terminal home stub (`routeLog == [2]`). Unit coverage of `nextJourneyLevel` is retained but is no longer the only evidence (`architecture.md §15`).
- **F05-QA-2 (strict-mode gate never executed)** — **CLOSED.** `test/journey/journey_gate_support.dart` extracts the gate into one `runJourneyManifestGate(manifest, {readAsset})` → `JourneyGateReport(violations, shortfall)`, called by BOTH `journey_manifest_gate_test.dart` (the real bundled pack) and `test/journey/journey_manifest_strict_test.dart` (5 synthetic cases): `strict + < 30` → rejects (violation names the shortfall); `strict + an unresolvable asset` → rejects; `strict + 30 valid` → passes; `smoke + < 30` → passes with `shortfall` only reported; `smoke + a broken asset` → still rejects. The structural band rules remain a documented `[PENDING — F06-CONTENT]` stub — accepted per `architecture.md §5.4`.

---

## 9. Positive Scenarios

1. **Advance to the next level.** Start: `/play` `journeyLevel: 1` (interim 2-level manifest). Action: solve row 0 → `CompletionPanel` → tap `SONRAKİ`. Visible result: the screen shows level 2's `/play`; the route was **replaced** (`canPop() == false`), no `CompletionPanel`. Evidence: `journey_next_level_test.dart` case 1.
2. **Reach the terminal state via `Next Level`.** Start: `/play` `journeyLevel: 2` (the last available). Action: solve → tap `SONRAKİ`. Result: the home terminal route is shown; no board, no panel; the player was never routed to a non-existent level 3. Evidence: `journey_next_level_test.dart` case 2.
3. **A broken strict content pack cannot ship.** A synthetic `mode:"strict"` manifest with 5 levels → `runJourneyManifestGate` returns `passed == false` with a violation naming the 25-level shortfall; a 30-level strict manifest missing level 17's asset → `passed == false` naming level 17. Evidence: `journey_manifest_strict_test.dart`.
4. **Resume an in-progress level from the home.** Start: level 1 completed + an in-progress `journey-tr-02` snapshot. Open `/`. Result: caption `Seviye 2 · sürüyor`, ring `Semantics` `1 / 30 seviye tamamlandı — Seviye 2`, CONTINUE → `journeyLevel: 2`. Evidence: `journey_home_test.dart` in-progress case.
5. **Learn columns by doing it, even after a force-quit.** Enter level 4 → overlay shown → quit without a column move → ack still `false` → re-enter level 4 → overlay re-shows → a column drag clears it and persists → re-enter → gone. Evidence: `column_tutorial_test.dart` AC11 chain.
6. **No navigation to a locked level.** Across new / mid / in-progress / terminal + the last-available boundary, `continueTarget` is never a `locked` level (and `null` only when `allComplete`); `Next Level` from every completed level resolves to a non-locked level or `null`. Evidence: `journey_progress_model_test.dart` no-nav-to-locked.

---

## 10. Negative / Edge Cases

* **`pushReplacement` vs `push`** — the AC12 test distinguishes them: after the tap, `GoRouter.canPop()` is `false` (a `push` would leave it `true`). The `/play` L1 frame is disposed, not retained. **PASS.**
* **`Next Level` past the last available level / level 30** — `nextJourneyLevel` returns `null` → `context.go('/')` (a valid terminal action, never a dead no-op). **PASS.**
* **Reduced motion** — `_JourneyRing._syncMotion` guards `_pulse.repeat()` / `_bloom.forward()` on `!_reduceMotion`; under `FakeAccessibilityFeatures(disableAnimations: true)` the pulse is steady and the bloom is not drawn, and every `journey_home_test.dart` case settles under `pumpAndSettle`. **PASS** — no animation-leak / timeout.
* **`widget_test.dart` (bootstraps the real `HomeScreen`)** — a freshly-seeded DB has no active session and 0 completions, so neither `_JourneyRing` controller animates; the bootstrap test stays green in the 176. **PASS.**
* **Tutorial outside the 4–6 band** — `journeyLevel: 1` → no `ColumnTutorialOverlay`, ack untouched. **PASS.**
* **Interim CONTINUE edge (known, `[PENDING — F06-CONTENT]`)** — a player who completes all 5 interim levels but is not at 30/30 gets `continueTarget = 6`, which the interim resolver cannot load → F03's load-error state. **Not an F05-FE2 defect** — the `continueTarget` derivation is content-agnostic by `architecture.md §6`; it resolves once `F06-CONTENT` ships the real 30. See Note N1.
* **`markCompleted` idempotency / overshoot** — carried from pass 1 (`journey_unlock_flow_test.dart`, `journey_progress_model_test.dart`). **PASS.**

---

## 11. Integration Findings

No new integration findings. The prior pass's single blocking integration gap (AC12 `Next Level` → navigation asserted nowhere) is closed by `journey_next_level_test.dart` — a real `GoRouter` + `PlaySessionScreen`, trigger (`SONRAKİ` tap) → outcome (route + `canPop`) verified. No API → UI mapping (client-only). Chrome: `/` is app root (no chrome), `/play` keeps F03's chrome + the `/` fallback (carried).

---

## 12. UX & State Handling

* **Loading / Error / Empty / Success / Disabled:** **PASS (carried)** — unchanged by F05-FE2.
* **In-progress + terminal motion:** **PASS (now closed)** — `_pulse` (in-progress node breathing, ≈4 s) + `_bloom` (terminal entry bloom, one-shot ~620 ms); both `TickerProviderStateMixin`-owned, disposed in `dispose()`, guarded on `!_reduceMotion`, driven from the model in `initState` + `didUpdateWidget`. No `pumpAndSettle` regression (the widget tests that mount an in-progress / terminal `HomeScreen` run under reduced motion; `widget_test.dart` mounts a 0-progress home that never animates).
* **CTA clarity / visual hierarchy / background / surface / typography:** **PASS** — the pill is now 66–72 % wide (dominant, nested in the ring gap); everything else unchanged.
* **Runtime evidence summary:** `automated functional` — 176 `flutter_test` cases (widget + unit + real-repo + real-router integration), pure-package `dart test` green, iOS release build green. On-device *feel* of the new ring motion → the deferred first-app-distribution smoke (`architecture.md §15`), alongside F03's / F04's device items.

---

## 14. Frontend Quality

* **Scope of change:** F05-FE2 is test-heavy — 2 new test files (`journey_next_level_test.dart`, `journey_manifest_strict_test.dart`) + 1 shared support file (`journey_gate_support.dart`) + edits to 4 existing journey test files; the only `lib/` change is `home_screen.dart` (`_JourneyRing` `Stateless → Stateful` + painter `pulse`/`bloom` params + `_ContinueCta` width). No F03/F04/F06/F08 file touched.
* **Gate extraction:** `runJourneyManifestGate` is a clean single source of truth for the content-manifest gate — the real-bundle test and the synthetic strict/smoke tests now exercise the same code, which is what `architecture.md §5.4` intends. The `sha256` checksum check lives in the shared support (a test-tier concern; `crypto` is a dev dependency).
* **Motion:** the `_JourneyRing` controllers are correctly lifecycle-managed (disposed; `repeat()` / `forward()` guarded; `_bloom.forward()` idempotent via a `dismissed`-status check). `shouldRepaint` extended for `pulse` / `bloom`.
* **Weak spots:** the `journey_next_level_test.dart` `routeLog == [1, 2]` exact-match is mildly coupled to go_router's builder-call cadence (a spurious route rebuild would append a duplicate) — it passes deterministically across the FE run + this re-verify, and the `canPop()` assertion is the primary proof; acceptable. See Note N3.
* **Analyze / format:** clean.

---

## 15. UI Handoff Alignment

* **Now aligned (previously deviations):** the in-progress node breathing pulse + the terminal entry bloom (`ui-design.md §7.1` / §11 "Must not be broken", differentiator #3) are implemented with the specified reduced-motion static end-state; the CONTINUE pill is widened to the `ui-design.md §7.2` 66–72 % band.
* **Acceptable technical difference:** the breathing pulse is a 0→+6 % swell (grow-and-relax) rather than a symmetric ±6 % oscillation around the resting size — the "breathing" intent is met; a symmetric range would dip the node below its resting size, which reads worse at a 4–5 pt dot. Non-blocking (Note N2).
* **Unacceptable UX / visual deviations:** none.
* **Premium-quality gaps:** none — the added motion raises, not lowers, the differentiator score; the reduced-motion path renders the handoff's specified static end-states.

---

## 16. Regression Risk

**Shared components F05-FE2 touches:**

* `home_screen.dart` `_JourneyRing` / `_ContinueCta` — the home is F05-owned; no other feature depends on it. `widget_test.dart` ("app bootstraps and shows the home shell") green in the 176; `journey_home_test.dart` 4 cases green. The `_ContinueCta` `maxWidth` param is threaded from the existing `LayoutBuilder` — no new layout constraint. **No regression.**
* `journey_manifest_gate_test.dart` — rewritten to call `runJourneyManifestGate`; still the `melos run content:journey` gate, still asserts schema + contiguity + the id scheme + (via the shared gate) checksum / parse / optimal on the real bundled pack. 4/4 green. **No regression** to the gate's guarantee.
* No `lib/` change outside `home_screen.dart`; `PlaySessionController` / `playSessionSetupProvider` / `completion_panel.dart` / `journey/*.dart` untouched this turn.
* F03 play suite + F04 completion suite (incl. `completion_panel_test.dart` debug-entry `SONRAKİ` disabled + `· yakında`) — green in the 176.

**Full-suite result:** `flutter test` **176/176** (166 baseline + 10 net new). Pure packages **197** green. **No regression detected.**

---

## 17. Final Verdict

### **Approved with Notes**

* **Blocking issues:** none. Both prior-pass blocking findings (F05-QA-1 AC12 navigation, F05-QA-2 strict-mode gate) are closed with executed **trigger→outcome** / **configuration-variant** tests. No required fixes.
* **Non-blocking notes (record in the orchestration change log; none require action before F05 proceeds):**
  * **N1 — interim CONTINUE edge (`[PENDING — F06-CONTENT]`).** A player who completes all 5 interim Journey levels while not at 30/30 gets `continueTarget = 6`, which the interim resolver cannot load → F03's load-error state. This is a **content gap, not a code defect** — `continueTarget` is content-agnostic by `architecture.md §6`, and the real 30 levels close it. Recommend it be listed against `F06-CONTENT` tracking so it is not rediscovered as a bug; an optional interim clamp (`continueTarget` to the available manifest length) is a possible cheap guard but is **not required** for F05.
  * **N2 — breathing-pulse direction.** `_JourneyRingPainter` applies `pulse` as a 0→+6 % swell (grow/relax) rather than a symmetric ±6 % oscillation. The "breathing" intent (`ui-design.md §7.1`) is met; a follow-on could make it symmetric, but the current treatment is arguably better at a small dot. Cosmetic.
  * **N3 — `routeLog` exact-match coupling.** `journey_next_level_test.dart` asserts `routeLog == [1, 2]` / `[2]`, which is mildly coupled to go_router's route-builder call cadence; the `GoRouter.canPop() == false` assertion is the primary, robust proof. If this proves flaky in CI, relax the `routeLog` assertion to "last entry == expected level".
  * **N4 — device feel of the new ring motion.** The pulse / bloom timing + amplitude on a real device folds into the deferred first-app-distribution smoke (`architecture.md §15`), alongside F03's 3-item manual device confirmation + F04's N4.
  * **Carried, unchanged:** AC3/AC5/AC6 difficulty bands + the gate's **structural** band rules are `[PENDING — F06-CONTENT]`; **F05 → `Done` still additionally requires `F06-CONTENT` delivered + the strict gate green** (a Tech Lead close-gate matter, not a QA blocker — F05 is code-complete / QA-passed against interim content, the F08 shape).

---

# WORKFLOW VERDICT SUGGESTION (NON-AUTHORITATIVE)

## QA Result

* **Approved with Notes** — F05-FE2 closes both blocking findings (AC12 `Next Level` navigation now trigger→outcome tested; the `mode:"strict"` gate failure path now executed) with no regression. `flutter analyze` / `dart format` / `flutter test` (176) / pure `dart test` / `flutter build ios --release --no-codesign` all green. `ui-design.md` handoff now fully aligned (breathing pulse + terminal bloom + pill width). 4 non-blocking notes, none requiring action before F05 proceeds.

## Affected Areas

* Frontend (test coverage + `home_screen.dart` ring motion / pill width). No contract, backend, integration-with-backend, release, or UI-handoff **defect**.

## Blocking Issues

* None.

## Suggested Fix Order

* Not applicable — `Approved with Notes`, no `Required Fixes`. The non-blocking notes (N1 `F06-CONTENT` tracking; N2 pulse direction; N3 test-assertion robustness; N4 device feel) can be actioned opportunistically. **F05 close-out remains gated on `F06-CONTENT` + the strict gate green** — a Tech Lead decision, not a QA fix.

---

## 19. Sonraki Komut

```
Run Tech Lead
```

---

## 20. Tech Lead Note

* **Verdict: `Approved with Notes`.** F05-FE2 closed both F05-QA `Rejected` blocking findings with proper evidence — the AC12 `Next Level` chain is now proven through a real `GoRouter` + `PlaySessionScreen` (`SONRAKİ` tap → `pushReplacement` to N+1 with `canPop() == false`, or `context.go('/')` → terminal), and the content-manifest gate's `mode:"strict"` failure path is now executed against synthetic manifests via a shared `runJourneyManifestGate`. The Tech Lead-ruling notes (N1 in-progress home widget test, N2 breathing pulse + terminal bloom with a reduced-motion static end-state, N3 negative-band tutorial, N4 chained AC11, N6 pill width, the AC2 no-nav-to-locked assertion) are all in place. N5 was correctly implemented as "no guard" per the DURUM 5 ruling. **176/176 `flutter test`, no regression to the F03 play / F04 completion suites; `analyze` / `format` / iOS release build green.**
* **`ui-design.md` is now fully aligned** — the two "Must not be broken" motion items (differentiator #3 + the terminal bloom) ship, reduced-motion honoured; `premium-ui-rubric.md` ≥ 90 holds, no fail condition, no anti-pattern.
* **F05 is code-complete + QA-passed against the interim `mode:"smoke"` content.** It is **not yet `Done`** — `architecture.md §5.5` / §17 gate `Done` on `F06-CONTENT` (the 30 authored levels + a `mode:"strict"` `journey_manifest_tr.json`) delivered + the strict gate green. This is the F08 shape (code-complete, parked on an external deliverable). Recommend: F05 → `In Progress` (or a "code-complete, awaiting content" state) with the `F06-CONTENT` decision surfaced to the user as it was at F05.CONTRACT-TL; do **not** activate the next feature until F05 closes (Retro Bug / Rework Control — the rework is done, but F05 is still the active feature).
* **Non-blocking notes for the change log:** N1 (interim `continueTarget = 6` edge — a `F06-CONTENT` content gap, not a code defect; optional cheap clamp available); N2 (pulse is a one-directional swell vs symmetric ±6 % — cosmetic); N3 (`routeLog` exact-match in `journey_next_level_test.dart` — relax if CI-flaky; `canPop()` is the primary proof); N4 (device feel of the new ring motion → deferred first-app-distribution smoke). None need a rework turn.
* `orchestration.md` updated: F05-QA re-verify closed `Approved with Notes`; Blockers aligned (the F05-QA blocker removed; `F06-CONTENT` + the strict gate remain the `Done` prerequisites). Global `feature-board.md` / `system-state.md` sync is Tech Lead's.
