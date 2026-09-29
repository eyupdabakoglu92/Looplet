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

---

# F05 — journey-progression: QA Raporu (F05-QA-STRICT, 2026-09-26)

> Final-stage, client-only. Aday: HEAD `6fb2d23`, temiz çalışma ağacı. QA plan alanları Tech Lead'in kilitlediği gibi kullanıldı. Yukarıdaki bölümler (F05-FE2 turu, 2026-09-09) tarihsel kayıttır; bu bölüm onların üzerine eklenir. QA probe'ları repo dışında (session scratchpad `qa-f05/`) tutuldu; repoya dosya eklenmedi.

## 0. QA Execution Plan

* **Stage / Scope:** `final` / `client-only`.
* **Modules + trigger:** `core, client-ui, stateful-flow`. Tetikleyiciler: gerçek strict içerik ve `content_check.dart` düzeltmesi (content gate), home/CONTINUE/terminal yüzeyi (client-ui), ilerleme, aktif oturum ve süreç ölümü/yeniden açılış (stateful-flow).
* **Regression Depth:** `full`. İçerik ve araç değişikliğine ek olarak F05'in kendi dosyaları (`home_screen.dart`, `column_tutorial_overlay.dart`) ve 6 paylaşılan play/rating dosyası önceki F05 QA commit'inden (`345147e`) beri değişti.
* **Evidence Reuse:** `allowed`, parmak izi kontrollü. Brief'teki "F05-FE2 kanıtı fingerprint-valid" iddiası doğru değil: yukarıdaki 8 dosya değişti, bu yüzden etkilenen suite'ler bu turda yeniden koşuldu (QS-06). F03 final QA runtime kanıtı (`51497dd`) paylaşılan play yolu için geçerli. Son `app/lib/play` değişikliği olan `cf747f8`, `51497dd`'nin atası. `51497dd..HEAD` aralığında `lib/play`, `lib/rating`, `lib/persistence`, bootstrap, main ve router değişmedi.
* **Canonical target / runtime class:** architecture §15 gereği `automated functional` zorunlu; cihaz runtime'ı F05 kapısı değil. İsteğe bağlı ad-hoc runtime yine de kaydedildi: iPhone 16 simülatörü `D0011CE7…`, content size `large`, `flutter build ios --simulator --debug -t lib/main.dart` ve temiz kurulum.
* **Fail-fast checkpoint:** Build, analyze ve testler yeşil olduğu için fail-fast tetiklenmedi. Gate kapsam açığı bir finding olarak kaydedildi; verdict eksiksiz olsun diye kapsamın tamamı koşuldu.

## 1. Evidence Ledger

| Evidence ID | Claim / Scenario | Class | Command / Action | Target | Result / Counts | Provenance / Fingerprint | Isolation |
| --- | --- | --- | --- | --- | --- | --- | --- |
| QS-01 | Her seviye için §5.4 R1–R6, 2026-09-13 kullanıcı kararı (1–3 `optimalMoves == 2`), id/numara/tip, sha256 ve manifest etiketi | automated functional (bağımsız probe) | `python3 band_probe.py <ağaç>` | `content/journey/tr` ve `app/assets/journey/tr` | 30/30, **0 ihlal** (iki ağaçta da) | EXECUTED THIS RUN · `HEAD:content/journey` = `HEAD:app/assets/journey` = git tree `057f242b` | scratch, repo dışı |
| QS-02 | `content:check` hangi bant kuralını gerçekten reddediyor? | automated functional (negatif) | gerçek CLI: `dart run bin/looplet_authoring.dart check <content kopyası> --repo-root <repo>`; 1 kontrol + 8 tek-dosya mutasyonu | `content/` kopyası | kontrol: exit 0 · R1 L02: exit 1 (açık kural) · R2 L07: exit 1 (**tesadüfi**, `unsolvable`) · R3 L17: exit 1 (**tesadüfi**, `budgetExceeded`) · **R4 L22: exit 0** · **R5 L28: exit 0** · R6 L28: exit 1 (açık kural) · L17 `optimalMoves 9` (gerçek 4): exit 1 · **aynı dosya + `"levels": []`: exit 0** | EXECUTED THIS RUN · `tools/looplet_authoring` tree `4d301d0c` | geçici kopya, sonra silindi |
| QS-03 | F05 gate'i (`runJourneyManifestGate`) bant ihlalini reddediyor mu? | automated functional (negatif) | `flutter test …/f05_gate_negative_test.dart`: gerçek gate çalışıyor, mutasyonlu asset'lerin checksum'ları yeniden hesaplanıyor | gerçek strict manifest + tek mutasyon | kontrol PASS · R1, R4, R5 ve R6 ihlallerinin hepsi `JourneyGateReport(passed: true, violations: [])` döndü | EXECUTED THIS RUN · `app/test/journey` tree `7b5b2787` | bellek içi |
| QS-04 | Gate ve CI kaynak eşlemesi | source review (yardımcı) | okuma | HEAD `6fb2d23` | `journey_manifest_gate_test.dart:75-80`: bant testinin gövdesi boş (`if (!manifest.isStrict) return;`) · `journey_gate_support.dart:37-39`: "not enforced here", bant alanlarına 0 referans · `content_check.dart:45`: `levels` anahtarı görülünce `continue` · `ci.yml:54-57`: `Content check` adımı engelleyici | — | — |
| QS-05 | Statik kapılar | automated | `flutter analyze` (app) · `dart format --output=none --set-exit-if-changed app` | app | analyze: No issues found · format: 110 dosya, 0 değişiklik, exit 0 | EXECUTED THIS RUN | — |
| QS-06 | Uygulama regresyonu | automated functional | `flutter test test/journey test/rating` · `flutter test` | app | **73/73** · **314/314** | EXECUTED THIS RUN (geçersizleşen F05-FE2 parmak izinin yerine) | Drift bellek içi |
| QS-07 | Paket regresyonu | automated | `melos exec --no-flutter -- dart test` · `tools/looplet_authoring`: `dart test` | 6 paket | core 22 · dictionary 32 · engine 83 · content 17 · solver 23 · authoring 20 = **197/197** · authoring tekrar koşusu 20/20 | EXECUTED THIS RUN | — |
| QS-08 | Paylaşılan play yolu, cihaz suite'i | runtime | `flutter test integration_test -d D0011CE7…` | iPhone 16 sim | **13/13** | EXECUTED THIS RUN | simülatör |
| QS-09 | Gerçek paketle 30 seviyelik kampanya, 30 → terminal ve terminalin yeniden kullanımı; STRICT-3'ün otomatik yeniden üretimi | automated functional | `flutter test …/f05_real_campaign_probe_test.dart`: gerçek derlenmiş paket baytları `rootBundle` ile okunuyor; gerçek `JourneyContentRepo`, `JourneyProgressRepo`, `PlaySessionScreen`, `HomeScreen` ve GoRouter kullanılıyor | gerçek paket | **7/7.** A1: strict, 30 ardışık seviye · A2: 30/30 seviye `loadLevel` ile yüklendi · A3: `nextJourneyLevel` 1..29 için n+1, 30 için null · B: 1..30 ilerleme, CONTINUE hedefi hiçbir zaman `locked` değil, 30'da `allComplete`, tekrar oynama idempotent · C: L30 gerçek içerikle 4 hamle geri yüklendi (çözücü yolu `R4 U1 U2 U2`), son hamle `D3` gerçek sürüklemeyle yapıldı, seviye kazanıldı; `SONRAKİ` → `TAMAMLANDI` + `TEKRAR OYNA`; L31 rotası yok; 30/30 kalıcı; aktif oturum temizlendi; `TEKRAR OYNA` → L1, ilerleme korundu · D1/D2: aşağıda QS-12 | EXECUTED THIS RUN · L30 çözüm yolu `looplet_authoring solve drafts/journey/_defs/journey-tr-30.def.json` ile alındı (def ile yayımlanan asset'in grid, locked ve frozen alanları aynı) | Drift bellek içi |
| QS-10 | Ad-hoc cihaz yolculuğu: gerçek içerik, kazanma, ilerleme, geri, kalıcılık | runtime (isteğe bağlı, §15) | temiz kurulum → home 0/30 "Seviye 1" → L1 2 hamlede çözüldü (ASLAN) → panel 3★, `SONRAKİ` birincil → L2 → geri → doğrudan home (pushReplacement) → `simctl terminate` + launch → 1/30 kalıcı | iPhone 16 sim | PASS | EXECUTED THIS RUN · ekran görüntüleri rt01–rt07 | simülatör, temiz uygulama verisi |
| QS-11 | AC7: süreç ölümünden sonra kalınan yerden devam | runtime | L2'de 1 hamle (4. satır `MBADE`) → terminate (PID 27337 sonlandı) → launch (PID 27839) → home "Seviye 2 · sürüyor" + camgöbeği düğüm → `DEVAM ET` → L2: `MBADE`, **1 HAMLE**, geri al etkin → 1 hamle daha → çözüldü, "2 SEN = 2 OPTİMAL" | iPhone 16 sim | PASS: grid, hamle sayısı ve geri al geçmişi korundu | EXECUTED THIS RUN · rt08–rt11 | simülatör |
| QS-12 | Aynı kalıcı durum oturum içinde ve yeniden açılıştan sonra farklı home/CONTINUE gösteriyor | runtime + automated | **Runtime:** L2 çözüldü → `Yeniden` → 1 hamle → geri → home **"Seviye 3"** (rt14) → CONTINUE'ya dokunmadan terminate/launch (PID 28957) → **"Seviye 2 · sürüyor"** + devam düğümü (rt15). Ön-sınır örneği: rt06 "Seviye 2" ↔ rt07 "Seviye 2 · sürüyor". **Automated:** QS-09 D1'de sıcak `[Seviye 2]` ↔ soğuk `[Seviye 2 · sürüyor]`; D2'de sıcak `[Seviye 3]` ↔ soğuk `[Seviye 2 · sürüyor]` | iPhone 16 sim + widget | **FAIL** (§6) | EXECUTED THIS RUN | simülatör / bellek içi |
| QS-13 | QS-12'nin kök nedeni | source review (yardımcı) | okuma | HEAD `6fb2d23` | `journey_progress.dart:83-94`: provider yalnız `journey_progress` tick'inde yayın yapıyor, snapshot'ı tick başına bir kez okuyor · `home_screen.dart:451-469`: CONTINUE bayat `continueTarget` değerini kullanıyor · `play_session_controller.dart:107-109`: yeni oturum açılır açılmaz tek slotlu snapshot'ı yazıyor · `:562`: geri yükleme yalnız `puzzleId` eşleşirse yapılıyor | — | — |
| REUSED | F03: rotasyon, geri, görsel, yaşam döngüsü (paylaşılan play yolu) | runtime | F03 final QA (Approved with Notes) | — | PASS | REUSED · `51497dd` (2026-09-21); parmak izi geçerli (§0) | — |
| INVALIDATED | F05-FE2 kanıtı: `home_screen.dart`, `column_tutorial_overlay.dart` + 6 paylaşılan play/rating dosyası | — | `git diff --name-only 345147e HEAD` | — | yerini QS-06 aldı | — | — |
| INVALIDATED | F06-CONTENT-PROMOTE ve `F06.CONTENT-PROMOTE-RECONCILE`: "strict gate 4/4, structural band-rule case dahil" | — | QS-03, QS-04 | — | Bant testinin gövdesi boş, dolayısıyla bant kuralları için **PASS sayılamaz** (yanlış atıf: `frontend.md:302`, `:320`, `:340`) | — | — |

## 2. Acceptance & Critical Journey Coverage

| AC / Journey | Expected | Evidence IDs | Result |
| --- | --- | --- | --- |
| AC1 | N, yıldız sayısından bağımsız tamamlanınca N+1 açılır | QS-06, QS-09 B/C, QS-10 | PASS |
| AC2 | Kilitli seviyeye gezinme yok | QS-06 (no-nav-to-locked), QS-09 B | PASS (yapısal; kilit göstergesi `[DEFERRED — F10]`) |
| AC3 | 1–3: yalnız satır hamlesi; optimal = 2 (2026-09-13 kullanıcı kararı) | QS-01, QS-10 (L1 ve L2 yalnız satırla, 2'şer hamlede) | PASS (içerik). CI koruması: R1 `content:check` ile sağlanıyor (QS-02) |
| AC4 | 4–6: sütun hamlesi + mikro-öğretici | QS-06 (`column_tutorial_test`), QS-01 (R2) | PASS (içerik + davranış). R2 için regresyon koruması güvenilir değil → STRICT-1 |
| AC5 | 7–10: satır + sütun, optimal 4–6 | QS-01 (sütun açık; `optimalMoves` her seviyede 4) | PASS |
| AC6 | 11–15 / 16–20 / 21–25 / 26–30 mekanikleri | QS-01 (R3–R5 sağlanıyor) | PASS (içerik; 11–15 notu için §6'ya bakın). R3–R5 için koruma yok → STRICT-1 |
| AC7 | Devam eden seviye, CONTINUE ile kaydedilen durumdan sürer | QS-11 ve QS-09 C (soğuk/yeniden açılış yolu PASS); QS-12 (oturum içi tekrar oynama yolu FAIL) | **FAIL (kısmi)** → STRICT-3 |
| AC8 | Devam eden seviye yoksa en düşük açık ve tamamlanmamış seviye | QS-06, QS-09 B, QS-10 | PASS |
| AC9 | 30 seviyenin tamamı bitince terminal, çökme yok | QS-09 C (gerçek paket), QS-06 | PASS |
| AC10 | İlerleme göstergesi görünür ve doğru | QS-10 (1/30, 2/30), QS-09 C (terminal) | PASS (sayım). Oturum içinde devam durumu gösterilmiyor → STRICT-3 |
| AC11 | Force-quit sonrası öğretici yeniden gösterilir | QS-06 (`column_tutorial_test` AC11 zinciri) | PASS |
| AC12 | N<30 → N+1; N==30 → terminal | QS-09 A3/C (gerçek manifest), QS-10 (runtime L1→L2; geri tuşu doğrudan home'a) | PASS |
| AC13 | 1★'da da `Next Level` görünür | QS-06 (`completion_cta_weighting_test`) | PASS |
| AC14 | Ağsız: paketlenmiş içerik + yerel kayıt | QS-09 A2; kaynak: Journey ve play yolunda ağ çağrısı yok, `bootstrap.dart` önce yereli hazırlıyor, Firebase hataları yakalanıyor | PASS (automated functional + yapısal). Ağsız cihaz koşusu burada yapılamadı; F08'in kendi kaydı `F08.OFFLINE-JOURNEY`'de (PENDING) izleniyor. §15'e göre F05 kapısı değil |
| N1 (önceki turun notu) | Ara içerikteki uç durum | QS-01, QS-09 A3/B | **Moot, kapatıldı.** Manifest 1..30 ardışık olduğu için `continueTarget` artık paketin ötesini gösteremez |
| Negatif: bant ihlalli strict paket | CI'da reddedilmeli (§15) | QS-02, QS-03 | **FAIL** → STRICT-1 |
| Negatif: `levels` anahtarı taşıyan puzzle dosyası | yine doğrulanmalı | QS-02 | **FAIL** → STRICT-2 |
| Misuse: tamamlanmış seviyeyi tekrar oynama | ilerleme şişmez, yeniden kilitlenmez | QS-09 B, QS-12 (2/30 sabit kaldı) | PASS |

## Client & UI Compliance

| Kontrol | Beklenen | Evidence | Sonuç |
| --- | --- | --- | --- |
| Home: yeni / orta / terminal | Sayaç, CONTINUE hedefi, `TAMAMLANDI` ve `TEKRAR OYNA` | QS-10 (rt01, rt06), QS-09 C | PASS |
| Home: devam eden, soğuk açılış | "Seviye N · sürüyor" + camgöbeği düğüm | QS-11 (rt09), QS-12 (rt15), QS-09 C | PASS |
| Home: devam eden, oturum içi | Soğuk açılışla aynı görünüm (§6, ui-design) | QS-12 (rt06, rt14), QS-09 D1/D2 | **FAIL** → STRICT-3 |
| CompletionPanel CTA ağırlığı | 3★ → amber `SONRAKİ`; hayalet `Yeniden`; `Kapat` | QS-10 (rt04), QS-11 (rt11), QS-06 | PASS |
| Next Level geçişi | `pushReplacement`; geri tuşu doğrudan home'a | QS-10, QS-06 | PASS |
| Debug kısayolları | Yalnız debug build'de | `home_screen.dart:65` (`kDebugMode`) | PASS |

Visual Scope tanımlı değil. Premium puanlama yapılmadı; F05 yüzeyinin Foundation'a uyumu Design Adoption Route Phase C'de değerlendirilecek.

## Stateful Flow & Integration

| Boundary / Transition | Actor / Start State | Expected | Evidence IDs | Result |
| --- | --- | --- | --- | --- |
| Soğuk açılış, boş durum | Yeni kurulum | 0/30, CONTINUE → L1 | QS-10 | PASS |
| Soğuk açılış, kalıcı ilerleme | 1/30 → kill/relaunch | 1/30, "Seviye 2" | QS-10 | PASS |
| Seviye ortasında süreç ölümü → devam | L2, 1 hamle | Grid, hamle ve geri al aynen döner | QS-11 | PASS |
| Kazanma commit'i → altta mounted home | L30 kazanıldı | Home terminal durumuna geçer | QS-09 C | PASS |
| Kazanma anı: snapshot `completed` → `markCompleted` | Kazanma | Tick anında devam eden seviye kalmaz | QS-10 ("Seviye 2", "sürüyor" yok), QS-09 C (aktif oturum `null`) | PASS (`completed` durumu `markCompleted`'dan önce kuyruğa alınıyor) |
| Oyun oturumunun snapshot yazması → mounted home | Ön-sınır L2 başlatıldı / tamamlanmış L2 tekrar oynanıyor | Home devam durumunu ve CONTINUE hedefini yansıtır (§6) | QS-12, QS-09 D1/D2 | **FAIL** → STRICT-3 |
| Tek slotlu snapshot'ın üzerine yazma | Tekrar oynama sürerken oturum içi CONTINUE (L3) | Tekrar oynamanın kaydı korunur ya da hedef tekrar oynanan seviye olur | QS-12 (hedef "Seviye 3") + `play_session_controller.dart:107-109` | FAIL (kaynaktan çıkarım; rt15 kanıtını korumak için cihazda L3'e dokunulmadı) |
| Tam döngü + terminal yeniden kullanımı | 1..30 | 30'da terminal; `TEKRAR OYNA` → L1; ilerleme korunur | QS-09 B/C | PASS |
| Idempotency | Tamamlanmış seviyeyi yeniden kazanma | İlerleme değişmez | QS-09 B, QS-06 (`journey_unlock_flow_test`) | PASS |

## 3. Findings

**F05-QA-STRICT-1: Strict build gate'i yapısal bant kurallarını uygulamıyor; teslimat kanıtı yanlış atıflı**
* Severity / Type: High / validation defect (sözleşme ihlali). **Blocking.**
* İlgili: architecture §5.4 (satır 102 ve 106), §15 "Build gate" (satır 228); AC3–AC6'nın regresyon koruması; F06-CONTENT-PROMOTE; brief madde 1.
* Expected: `mode:"strict"` bir pakette bant ihlali varsa gate CI'ı düşürür. F05 gate testi strict modda R1–R5 (ve R6) için gerçek assertion taşır.
* Actual: `journey_manifest_gate_test.dart:75-80`'in gövdesi boş; strict modda hiçbir şey assert edilmiyor. `runJourneyManifestGate` bant alanlarını hiç okumuyor. Gerçek kapsam (QS-02, QS-03):
  * R1 ve R6 yalnız `content:check` ile korunuyor (CI'da engelleyici).
  * R2 ve R3 yalnız tesadüfen reddediliyor (`unsolvable` / `budgetExceeded`); çözülebilir kalan bir ihlal geçer.
  * **R4 ve R5 hiçbir kapıda reddedilmiyor.**
* Yanlış atıf: `frontend.md:302` ("`difficultyLabel` in the strict-mode band rule … 4/4 pass"), `:320` ve `:340`. Aynı iddia `F06.CONTENT-PROMOTE-RECONCILE`, `system-state.md` ve `feature-board.md` içinde de tekrarlanıyor.
* Mevcut içeriğe etkisi yok: 30 seviyenin hepsi kurallara uyuyor (QS-01). Risk, ileride yapılacak bir içerik düzenlemesinin R2–R5'i fark edilmeden bozması.
* Tekrarlama: QS-02 (L22 veya L28 frozen hücresi silinince `content:check` exit 0) ve QS-03 (R1/R4/R5/R6 ihlali F05 gate'inden `passed: true` ile geçiyor).
* Öneri (root-cause: Frontend/Mobile Developer + content toolchain; karar Tech Lead'in): R1–R6 için tek bir kural kaynağı (ör. `runJourneyManifestGate` içinde), strict testte gerçek assertion ve her kural için reddedilmesi beklenen sentetik negatif test. `content:check`'e R2–R5 eklenip eklenmeyeceğine ya da F05 gate'inin tek otorite olarak belgelenmesine Tech Lead karar verir. Teslimat artifact'ındaki yanlış atıf düzeltilmeli.

**F05-QA-STRICT-2: `content:check`'teki `levels` anahtarı ayırt edicisi puzzle doğrulamasını atlatılabilir kılıyor**
* Severity / Type: Medium / validation defect. STRICT-1 ile aynı rework paketinde düzeltilmeli.
* İlgili: F06-CONTENT-PROMOTE araç düzeltmesi (`content_check.dart:45`); evidence standardındaki "ayırt edici ve bypass dalları negatif örnekle test edilmeli" kuralı.
* Expected: Yalnız gerçek Journey manifesti atlanır. Puzzle artifact'ları her zaman çözücüyle yeniden doğrulanır.
* Actual: Herhangi bir JSON'a `"levels": []` eklenince çözücü, eligibility, R1/R6 ve dedup kontrollerinin hepsi atlanıyor. L17'de `optimalMoves 9` (gerçek değer 4) anahtarsız exit 1 veriyor, anahtarla **exit 0** veriyor (QS-02). Eklenen regresyon testi yalnız pozitif durumu kapsıyor; negatif dal test edilmemiş.
* Öneri: Ayırt ediciyi sıkılaştırın (ör. manifest şeklinin tamamı — `schemaVersion`, `mode`, `lang`, `levels` — ve/veya dosya adı `journey_manifest_<lang>.json`). Şekli bozuk manifest hata üretsin. Negatif test ekleyin.

**F05-QA-STRICT-3: Home read-model oturum içinde aktif oturum snapshot'ını yeniden okumuyor; devam durumu görünmüyor ve tekrar oynamada CONTINUE hedefi sapıyor**
* Severity / Type: Medium / implementation defect (§6 sözleşmesi + AC7'de kısmi ihlal). **Blocking:** AC7 ihlali var; bu rework'te düzeltilmeli ya da Tech Lead açık gerekçeyle karar vermeli.
* İlgili: AC7, AC10; architecture §6 (satır 132–135); ui-design'daki devam durumu (camgöbeği düğüm, nabız, "· sürüyor"); stateful-flow modülündeki "stale state" kontrolü.
* Expected: §6'ya göre `inProgress`, `inProgress` durumundaki bir journey snapshot'ıdır; tamamlanmış seviye için istisna yoktur. CONTINUE hedefi devam eden seviyedir. Aynı kalıcı durum, süreç ne kadar süredir çalışıyor olursa olsun aynı home'u üretmelidir.
* Actual: `journeyProgressModelProvider` yalnız `journey_progress` tick'inde yayın yapıyor (`journey_progress.dart:83-94`). Home, push edilen `/play` rotasının altında mounted kaldığı için oyun oturumunun snapshot yazımları home'a hiç yansımıyor.
  * (a) **Ön-sınır yolu (en yaygın akış):** Seviyeye başlayıp geri dönünce home'da "· sürüyor" yazısı, camgöbeği düğüm ve nabız görünmüyor; yeniden açılışta görünüyor (rt06 ↔ rt07; QS-09 D1). CONTINUE yine doğru seviyeye gidiyor ve `puzzleId` eşleştiği için durum geri yükleniyor. İşlevsel etki yok, ama durum gösterimi yanlış.
  * (b) **Tekrar oynama yolu:** Tamamlanmış L2 → `Yeniden` → 1 hamle → geri. Oturum içi CONTINUE hedefi **L3** ("Seviye 3"); aynı durum yeniden açılıştan sonra **"Seviye 2 · sürüyor"** gösteriyor (rt14 ↔ rt15; QS-09 D2). Oturum içi CONTINUE'ya basılırsa L3'ün yeni oturumu tek slotlu snapshot'ın üzerine yazar (`play_session_controller.dart:107-109`) ve tekrar oynamanın ilerlemesi sessizce kaybolur (kaynaktan çıkarım). 1–2★ sonucunda birincil CTA `Yeniden` olduğu için bu akış gerçekçi.
* Test açığı: `journey_home_test.dart`'taki devam eden varyantı snapshot'ı home kurulmadan önce yazıyor; yani yalnız soğuk yolu test ediyor. Önceki turun AC7 ve N1 PASS'leri bu yolu kapsamıyordu.
* Öneri (root-cause: Frontend/Mobile Developer; sözleşme netleştirmesi Tech Lead'in): §6'daki "a read of `activeSessionRepoProvider.read()`" ifadesi, canlı olmayan tek seferlik bir okumaya izin veriyor. Model aktif oturum değiştiğinde de yeniden türetilmeli (ör. `active_session` için Drift `watch` + `journey_progress` birleşimi, ya da `/`'e dönüşte yenileme). Sıcak yol (snapshot home mounted iken yazılıyor) ve tekrar oynama varyantı için widget testleri eklenmeli.

## 4. Pending Evidence

* F05'e yeni PENDING kayıt eklenmedi.
* **Ağsız cihaz koşusu** F08'in kendi kaydı `F08.OFFLINE-JOURNEY`'de (Owner QA, PENDING) izleniyor.
  * Required class: runtime.
  * Hedef: ağdan izole bir cihaz (uçak modu) ya da ağdan izole bir simülatör hostu. Bu ortamda simülatör host'un ağını paylaşıyor ve host ağını değiştirmek kapsam dışı.
  * Yeniden değerlendirme: F08-LOCAL-EVIDENCE koşusu ya da ilk dağıtım smoke testi.
* §15'e göre bu koşu F05 kapısı değil. F05'e PENDING kayıt olarak eklenseydi audit'in "terminal feature contains PENDING" kuralı F05'i sözleşmeye aykırı biçimde kilitlerdi.

## 5. Regression & Evidence Reuse

* **Etkilenen yüzey:** gerçek 30 seviyelik içerik, `content_check.dart`, F05 home ve tutorial (F03-QA-04 değişikliği), paylaşılan play/rating. Full depth koşuldu: QS-05..QS-08 yeşil, regresyon yok.
* **Reused:** F03 final QA runtime kanıtı (`51497dd`); parmak izinin geçerliliği §0'da gerekçelendirildi.
* **Invalidated:** 8 dosya değiştiği için F05-FE2'nin parmak izi geçersiz; yerini QS-06 aldı. F06-CONTENT-PROMOTE'un "band-rule case 4/4" iddiası da geçersiz: test gövdesi boş olduğu için bant kuralı kanıtı sayılamaz.
* **Bağımsız QA probe'ları:** QS-01 (bağımsız Python kural denetçisi), QS-02/QS-03 (gerçek CLI ve gerçek gate'e negatif örnekler), QS-09 (gerçek paketle uçtan uca), QS-10..QS-12 (cihaz).

## 6. Final Verdict

* `QA Result: Rejected`
* Blocking Issues: F05-QA-STRICT-1, F05-QA-STRICT-3 (F05-QA-STRICT-2 aynı rework paketinde)
* Required Fixes (sırayla):
  1. Strict gate'te R1–R6 için gerçek assertion ve her kural için reddedilmesi beklenen negatif test (STRICT-1).
  2. `levels` ayırt edicisini sıkılaştır ve negatif test ekle (STRICT-2).
  3. Home read-model'ini aktif oturum değişimlerine bağla; sıcak yol ve tekrar oynama widget testlerini ekle (STRICT-3).
  4. `frontend.md` F06-CONTENT-PROMOTE bölümündeki yanlış atıfı düzelt.
* Non-blocking Notes:
  * 11–15 bandında `tdDegree = 0`: AC6'nın "heavier temporary-displacement" ifadesi yapısal olarak karşılanmıyor. §5.4'e göre bu sert bir kural değil ve kullanıcı 30 seviyeyi 2026-09-13'te olduğu gibi kabul etti. Defect değil; PO'nun görmesi için not.
  * `content/` ↔ `app/assets/` ayna eşitliği ve manifest `difficultyLabel` ↔ asset etiketi hiçbir kapıda kontrol edilmiyor. Bugün tutarlılar (QS-01).
  * Çözücüyle yeniden doğrulama yalnız `content/` üzerinde koşuyor, paketlenen kopyada koşmuyor.
  * `highestUnlockedLevel` 30'dan sonra 31 oluyor. Bu §33'teki `max(existing, N+1)` kuralıyla uyumlu ve zararsız.
  * Ağsız cihaz koşusu → `F08.OFFLINE-JOURNEY` (F08'in kaydı).

## 7. Tech Lead Note

* **Root-cause:**
  * STRICT-1/2 → Frontend/Mobile Developer (F05 gate testi) + content toolchain (`content_check.dart`).
  * STRICT-3 → Frontend/Mobile Developer (read-model) + §6 netleştirmesi (Tech Lead).
* **QA'nın yetki alanı dışında olduğu için düzeltilmesi gereken kayıtlar:**
  * `F06.CONTENT-PROMOTE-RECONCILE` provenance'ı, `system-state.md` Current Reason ve `feature-board.md` F05 satırı: "4/4 … structural band-rule case dahil" iddiası QS-03/QS-04 ile çürütüldü.
  * Brief'teki "F05-FE2 fingerprint-valid" ifadesi: 8 dosya değişti, QA suite'leri yeniden koştu.
  * Consumed Signals'taki "Tech-Lead-reconciled on 2026-09-13" tarihi: reconciliation 2026-09-26'da yapıldı.
  * `prd.md:30`'daki AC3 hâlâ "optimal is 3–4 moves" diyor. Aynı dosyanın 73. satırı ve `product-prd.md:328` düzeltmeyi (== 2) içeriyor; AC satırı güncellenmemiş, bu bir doküman kayması.
* **Routing:** Rework (STRICT-1/2/3) sonrası yeniden QA. Yeniden QA dar kapsamlı olabilir: strict gate negatif testleri, `content:check` negatifleri, sıcak/soğuk home ve tekrar oynama. İçerik ve ilgili kod değişmezse QS-01, QS-09 A–C, QS-10, QS-11 ve F03 kanıtı yeniden kullanılabilir.
* **Karar notu:** §6 bugün tekrar oynanan tamamlanmış bir seviyeyi "devam eden" sayıyor ve CONTINUE onu hedefliyor. Ürün açısından istenen davranış buysa korunmalı; değilse Tech Lead/PO kararı gerekir. Hangisi seçilirse seçilsin oturum içi ve soğuk yol aynı sonucu vermeli. Release veya paid deploy ile ilgisi yok.
* **F08 için girdi:** Bu turun kill/relaunch kanıtı (QS-10, QS-11), F08 QA koşusunda parmak izi eşleşirse `F08.LOCAL-RESUME` için kısmi girdi olarak kullanılabilir. Restart, thaw ve güvenilmeyen önbellekteki thaw'ın yeniden türetilmesi alt senaryoları kapsanmadı. F08 kayıtları bu turda değiştirilmedi.
* **Ortam:** iPhone 16 simülatöründe QA test verisi kaldı (2/30 ilerleme, L2 tekrar oynaması sürüyor); content size `large`.

## Sonraki Komut

```text
Run Tech Lead
```

---

# F05 — journey-progression: QA Raporu (F05-QA-STRICT2, 2026-09-27)

> Final-stage yeniden QA; F05-FE3 rework'ünden sonra. Aday: HEAD `015e50e`, temiz çalışma ağacı. Plan alanları Tech Lead'in kilitlediği gibi kullanıldı. QA probe'ları repo dışında (session scratchpad `qa2/`) tutuldu; repoya dosya eklenmedi.

## 0. QA Execution Plan

* **Stage / Scope:** `final` / `client-only`.
* **Modules + trigger:** `core, client-ui, stateful-flow`.
  * core: build gate ve validator bütünlüğü (F05-QA-STRICT-1/-2).
  * client-ui ve stateful-flow: ana ekranın canlı durumu, sıcak ve soğuk yol, süreç ölümü (F05-QA-STRICT-3).
  * `content` modülü qa-preflight'ta `content-design.md` olmadığı için düşürüldü. Validator'ın pozitif/negatif fixture kontrolü core altında yapıldı.
* **Regression Depth:** `full`.
* **Evidence Reuse:** `allowed`, parmak izi önce kontrol edildi. `content/journey` = `app/assets/journey` = git tree `057f242`, değişmemiş. Buna rağmen içerik probe'u taze koşuldu. Değişen app/persistence kodu nedeniyle QS-09 C/D, QS-10..QS-12 ve F03 runtime kanıtı yeniden çalıştırıldı.
* **Canonical target / runtime class:** `automated functional` zorunlu (§15). Buna ek olarak iPhone 16 simülatöründe (`D0011CE7…`, content size `large`) runtime doğrulaması yapıldı. Build `flutter build ios --simulator --debug -t lib/main.dart`, temiz kurulumla.
* **Fail-fast checkpoint:** tüm kapılar yeşil, fail-fast tetiklenmedi.

## 1. Evidence Ledger

| Evidence ID | Claim / Scenario | Class | Command / Action | Target | Result / Counts | Provenance / Fingerprint | Isolation |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Q2-01 | Statik kapılar | automated | `flutter analyze` (app) · `dart format --output=none --set-exit-if-changed app tools/looplet_authoring` | app + tools | No issues · 125 dosya, 0 değişiklik | EXECUTED THIS RUN · HEAD `015e50e`; ağaçlar `app/lib/journey 0e69338`, `app/lib/persistence 009256c`, `app/test/journey 698f41d`, `tools/looplet_authoring a0e4a5f` | — |
| Q2-02 | Uygulama regresyonu | automated functional | `flutter test` | app | **336/336** | EXECUTED THIS RUN | Drift bellek içi |
| Q2-03 | Paket regresyonu | automated | `melos exec --no-flutter -- dart test` | 6 paket | core 22 · content 17 · dictionary 32 · authoring 25 · solver 23 · engine 83 = **202/202** | EXECUTED THIS RUN | — |
| Q2-04 | Gerçek içerik temiz; iki ağaç aynı | automated functional | `content:check` (gerçek CLI) · `band_probe.py content/journey/tr` ve `app/assets/journey/tr` | gerçek paket | `check: OK` · iki ağaçta 30/30, **0 ihlal** | EXECUTED THIS RUN · tree `057f242` (QS-01 yeniden koşuldu, reuse edilmedi) | scratch |
| Q2-05 | Gate kuralları §5.4 ile birebir mi? | source review | `journey_gate_support.dart` okundu | HEAD | R1 1–3 sütun kapalı · R2 4–10 açık · R3 16–20 kilitli · R4 21–25 donmuş · R5 26–30 ikisi · R6 bantları {1–6: easy/medium; 7–15: +hard; 16–25: medium/hard/expert; 26–30: hard/expert} · LABEL manifest = asset · strict → violation, smoke → advisory · gerçek paket testi `isStrict` + 0 ihlal + `bandChecks == 85` + ayna | — | — |
| Q2-06 | Gate gerçek içerikte, kendi seçtiğim sınır çiftleriyle | automated functional (negatif + pozitif) | `flutter test …/qa2_gate_probe_test.dart`: gerçek gate, gerçek 30 seviye, checksum yeniden hesaplanmış, tek mutasyon | gerçek paket | **21/21.** Tek ve adlandırılmış ihlalle reddedilenler (14): R1 L03 · R2 L04, L10 · R3 L16, L20 · R4 L21, L25 · R5 L26, L29 · R6 L06, L07, L16, L26 · LABEL L25. Kuralın bandı dışında tetiklenmedi (3): L11 sütunsuz, L15 "hard", L25 "expert". Çoklu ihlal L05 → R2 + R6 · smoke R4 L21 → yalnız advisory · 29 seviyelik strict → "must ship 30" | EXECUTED THIS RUN · seviye/kural çiftleri teslimin ve Tech Lead'inkilerden farklı | bellek içi |
| Q2-07 | Gerçek ayna testi negatif | automated functional (negatif) | pakete geçici `zz_extra.json` eklendi, `journey-tr-19.json`'a 1 bayt eklendi → `flutter test test/journey/journey_manifest_gate_test.dart` → geri alındı · ayrıca geçici `.DS_Store` | `app/assets/journey` | exit 1: `tr/journey-tr-19.json: bytes differ` + `tr/zz_extra.json: in the bundle but not in the authored source` · `.DS_Store` ile exit 0 (yok sayıldı) · `git status` temiz | EXECUTED THIS RUN | repo geçici değişti, geri alındı |
| Q2-08 | `content:check` tanıma kuralı, yeni negatiflerle | automated functional (negatif) | içerik kopyası + gerçek CLI | `content/` kopyası | L23 `optimalMoves 9` + `"levels": []` → exit 1 (9 ≠ 4) · gerçek yolda `lang:"en"` → exit 1 `malformed … "lang" must be "tr"` · `tr/` içinde `journey_manifest_en.json` → exit 1 (Puzzle olarak doğrulandı) · gerçek yolda `levels` nesne → exit 1 `"levels" must be a non-empty array` | EXECUTED THIS RUN | geçici kopya, silindi |
| Q2-09 | Teslim edilen ana ekran ve repo testleri | automated functional | `flutter test test/journey/journey_home_live_test.dart test/journey/journey_home_test.dart test/widget_test.dart test/persistence/repositories_test.dart` | app | **27/27** | EXECUTED THIS RUN | Drift bellek içi (senkron kapanan) |
| Q2-10 | Canlı ana ekran uç durumları (teslimin kapsamadığı) | automated functional (adversarial) | `flutter test …/qa2_home_edge_probe_test.dart`: gerçek `HomeScreen`, gerçek repo'lar | widget | **7/7.** E1 debug-id snapshot, E2 `completed` snapshot, E3 Daily snapshot → devam sayılmadı ("Seviye 2") · E4 ekran açıkken snapshot 04 → 02 geçti → hedef 2 · E5 ön-sınırın çok gerisinde tekrar (5 tamam) → "Seviye 2 · sürüyor", clear → "Seviye 6" · E6 aynı karede 02 → 03 → clear → 05 → en son yazım kazandı: "Seviye 5 · sürüyor" · E7 gözlem → N1 | EXECUTED THIS RUN | bellek içi |
| Q2-11 | Gerçek paketle kampanya ve sıcak = soğuk | automated functional | QS-09 probe'u senkron kapanan DB ile yeniden koşuldu; D beklentisi `warm == cold` | gerçek paket | **7/7.** A1–A3, B ve C (L30 gerçek içerik → kazanç → `SONRAKİ` → terminal → `TEKRAR OYNA` → L1) geçti · **D1** sıcak `[Seviye 2 · sürüyor]` = soğuk `[Seviye 2 · sürüyor]` · **D2** sıcak `[Seviye 2 · sürüyor]` = soğuk (dün: `[Seviye 3]` ↔ `[Seviye 2 · sürüyor]`) | EXECUTED THIS RUN | bellek içi |
| Q2-12 | Paylaşılan play yolu, cihazda | runtime | `flutter test integration_test -d D0011CE7…` | iPhone 16 sim | **13/13** | EXECUTED THIS RUN (`ActiveSessionRepo.read()` değiştiği için F03 51497dd reuse edilmedi) | simülatör |
| Q2-13 | Cihazda uçtan uca yolculuk | runtime | temiz kurulum → senaryolar §2'de | iPhone 16 sim | PASS: q01–q14 | EXECUTED THIS RUN · ekran görüntüleri `qa2/q01…q14` | simülatör, temiz uygulama verisi |

## 2. Acceptance & Critical Journey Coverage

| AC / Journey | Expected | Evidence IDs | Result |
| --- | --- | --- | --- |
| **F05-QA-STRICT-1** — strict gate bant kurallarını uygular | Her kural için ihlal reddedilir; bandın dışında tetiklenmez; gerçek pakette 85 kontrol çalışır | Q2-05, Q2-06, Q2-02 | **Kapandı — PASS** |
| **F05-QA-STRICT-2** — `content:check` ayırt edicisi | Başıboş `levels` puzzle doğrulamasını atlatamaz; bozuk ya da yanlış yerdeki manifest reddedilir; gerçek içerik geçer | Q2-08, Q2-04, Q2-03 | **Kapandı — PASS** |
| **§5.4 ayna** — gönderilen paket = doğrulanmış kaynak | Kayma veya fazla dosya CI'ı düşürür | Q2-07 | PASS |
| **F05-QA-STRICT-3 / AC7** — sıcak yol, tekrar oynama dahil | Ekran açıkken yazılan snapshot home'a yansır; CONTINUE devam eden seviyeyi (tekrar dahil) sürdürür; sıcak = soğuk | Q2-09, Q2-10, Q2-11, Q2-13 (q02, q11–q14) | **Kapandı — PASS** |
| AC7 — süreç ölümünden sonra kalınan yerden devam | Grid, hamle ve geri al korunur | Q2-13 (q03–q05, q06 "2 SEN = 2 OPTİMAL") | PASS |
| AC8 / AC10 — ilerleme sayacı ve hedef | Kazanma devam durumunu temizler; hedef bir sonraki seviyeye geçer | Q2-13 (q07: 1/30, "Seviye 2", düğüm yok), Q2-10 E5 | PASS |
| AC9 / AC12 — 30 → terminal (gerçek paket) | `SONRAKİ` → `TAMAMLANDI`; `TEKRAR OYNA` → L1 | Q2-11 C | PASS |
| AC1–AC6, AC11, AC13, AC14 | Önceki turdaki kapsam, yeniden koşulan suite'lerle | Q2-02, Q2-04, Q2-11 A/B | PASS |
| Misuse/stale — journey dışı, `completed` veya Daily snapshot devam gibi görünmez; sıra dışı hızlı yazımlarda en yenisi kazanır | — | Q2-10 E1–E6 | PASS |

## Client & UI Compliance

| Kontrol | Beklenen | Evidence | Sonuç |
| --- | --- | --- | --- |
| Home: devam eden, oturum içi (sıcak) | "Seviye N · sürüyor" + camgöbeği düğüm, hemen | Q2-13 q02, q11 | PASS (dün FAIL) |
| Home: devam eden, soğuk açılış | Sıcak yolla aynı | Q2-13 q04, q14 | PASS |
| Home: kazanma sonrası | Devam durumu temiz, hedef bir sonraki seviye | Q2-13 q07 | PASS |
| CompletionPanel: `Kapat`, `Yeniden`, `SONRAKİ` | `Kapat` → home; `Yeniden` → aynı seviye taze; 3★'da `SONRAKİ` amber | Q2-13 q06, q09, q10 | PASS |
| Terminal | `TAMAMLANDI` + `TEKRAR OYNA` → L1 | Q2-11 C | PASS (N1'e bakın) |

Visual Scope tanımlı değil; görsel puanlama yapılmadı (Design Adoption Phase D'de ele alınacak).

## Stateful Flow & Integration

| Boundary / Transition | Actor / Start State | Expected | Evidence IDs | Result |
| --- | --- | --- | --- | --- |
| Snapshot yazımı → mounted home | Ön-sınır seviye açıldı | Anında devam durumu | Q2-09, Q2-13 q02 | PASS |
| Tekrar oynama snapshot'ı → mounted home | Tamamlanmış L2, `Yeniden` | CONTINUE hedefi 2; kayıt ezilmez | Q2-11 D2, Q2-13 q11–q12 | PASS |
| Kazanma (`completed` → clear → `markCompleted`) | Devam eden L1 | Devam durumu kalkar, hedef ilerler | Q2-09, Q2-13 q07 | PASS |
| Süreç ölümü → soğuk açılış | Sıcak durumlar | Sıcak = soğuk | Q2-11 D1/D2, Q2-13 q13 ↔ q14 | PASS |
| Stale / sıra dışı payload | Aynı karede 4 yazım | En yenisi kazanır | Q2-10 E6 | PASS |
| Yabancı snapshot | Debug id, `completed`, Daily | Devam sayılmaz | Q2-10 E1–E3 | PASS |
| Bozuk snapshot | Ekran açıkken bozuk satır | Satır silinir, fallback, döngü yok | Q2-09 | PASS |
| Abonelik yaşam döngüsü | Ekran dispose | İki Drift aboneliği iptal edilir | Q2-09 (testler senkron kapanan DB ile temiz iniyor) | PASS |
| Paylaşılan resume yolu | `ActiveSessionRepo.read()` refactor'u | F03 davranışı korunur | Q2-12, Q2-13 q05 | PASS |

## 5. Regression & Evidence Reuse

* **Full depth:** Q2-01..Q2-04 ve Q2-12 yeşil, regresyon yok.
* **Reuse:** yapılmadı. İçerik probe'u (QS-01) dahil ilgili her şey taze koşuldu.
* **Invalidated ve yenilenen:**
  * QS-09 C/D ve QS-10..QS-12 → Q2-11 ve Q2-13.
  * F03 51497dd runtime → Q2-12.
* **Bağımsızlık:**
  * Gate negatifleri teslimin ve Tech Lead'inkilerden farklı kural/seviye çiftleriyle, bant sınırlarında ve pozitif sınırlarla koşuldu (Q2-06).
  * Ayna negatifi farklı tipte: fazla dosya ve farklı bir seviye (Q2-07).
  * `content:check` negatifleri yeni (Q2-08).
  * Ana ekran uç durumları teslimde yok (Q2-10).

## 6. Final Verdict

* `QA Result: Approved with Notes`
* Blocking Issues: None
* Required Fixes: None
* Non-blocking Notes:
  * **N1 — terminal durum + süren tekrar oynama (Q2-10 E7).** 30/30 tamamlanmışken bir seviyenin tekrarı sürüyorsa ana ekran `TAMAMLANDI` + `TEKRAR OYNA` gösteriyor. Butona basınca L1 açılıyor ve süren tekrarın kaydı ezilecek.
    * Model doğru: `continueTarget` = tekrar oynanan seviye (§6).
    * `home_screen.dart`'taki terminal kararı (`allComplete`) önceliği alıyor. Bu mantık F05-FE2'den beri böyle; F05-FE3'le gelmedi.
    * AC9 (terminal) ile AC7 (devam) bu kenarda çakışıyor; ui-design ve §8 bu durumu tanımlamıyor.
    * Etkisi düşük: yalnızca kampanyayı bitirmiş oyuncunun kişisel rekor tekrarları etkileniyor.
    * Karar Tech Lead'in (ve gerekirse UI'ın): terminal durumda "Seviye K · sürüyor" gösterilip sürdürülsün mü, yoksa bilinçli kabul mü?
  * **N2 — bant tablosu iki yerde.** `journeyLabelBand` (F05 gate, otorite) ve `_expectedBands` (`content:check`). Eğri değişirse ikisi birlikte güncellenmeli (Tech Lead de not etti).
  * **N3 — ayna testi ve cwd.** Test `../content/journey` yolunu `flutter test` çalışma dizinine (app/) göre okuyor. melos ve CI'da bu geçerli; bilgi notu.
  * **N4 — taşınan notlar:** 11–15 `tdDegree = 0` (kabul edilmiş içerik; PO görünürlüğü); tamamlanmış seviyenin tekrarı halkada devam olarak görünüyor (§6 tasarımı); ağsız cihaz koşusu F08'in (`F08.OFFLINE-JOURNEY`; F05 kapısı değil); HomeScreen'i monte eden testler ve scratch probe'lar senkron kapanan Drift bağlantısı kullanmalı.

## 7. Tech Lead Note

* **Kapanış:** F05-QA-STRICT-1/-2/-3 bağımsız olarak kapandı. `F05.STRICT-CONTENT`, `F05.HOME-LIVE-STATE` ve `F05.SHARED-RUNTIME` PASS; Blockers None; açık karar kapısı yok. F05 kapanış incelemesine hazır.
* **N1:** bloklamayan bir kenar durum kararı. Tech Lead kapanıştan önce ya da sonra karar verebilir; tasarım uyarlaması Phase D'de F05 ana ekranı zaten yeniden ele alınacak.
* **Ortam:** iPhone 16 simülatöründe QA test verisi kaldı (2/30; L2 tekrar oynaması sürüyor, "MBADE", 1 hamle); content size `large`.

## Sonraki Komut

```text
Run Tech Lead
```
