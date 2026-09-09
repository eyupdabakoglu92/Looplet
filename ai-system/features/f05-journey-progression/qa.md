# F05 — journey-progression: QA Report

> Current state of QA for F05. End-to-end **client** QA against the LOCKED `architecture.md`, `prd.md` (AC1–AC14), `ui-design.md`, and `frontend.md`. Scope is `[LOCKED]` in `orchestration.md → QA Scope` / `architecture.md §15` — `automated functional` mandatory + `ui-design.md` alignment + regression. `runtime` (device) is not an F05 gate.

---

## 0a. Evidence Mode Declaration

* Bash / build access: **VAR**
* e2e test suite (Playwright / Cypress / Detox): **YOK** — `app/integration_test/` device suite exists (best-effort, not a CI gate, not run here)
* Screenshot / browser tool: **YOK**
* Runtime validation method: **`automated functional`** — `flutter_test` widget + unit tests (`pumpAndSettle`, one-shot / reduced-motion animation), Drift in-memory `AppDatabase.forTesting`, the **real F08 `JourneyProgressRepo` + `JourneyTutorialRepo`**, `rootBundle` asset loading in a widget-binding test. `architecture.md §15` makes `automated functional` the mandatory class and folds device `runtime` into the deferred first-app-distribution smoke. **Not `source-only`** (full build/test access was used).

---

## 1. Feature Summary

* **Feature:** F05 — wire F03's isolated play session into a 30-level linear campaign: the level-identity scheme (`journey-<lang>-<NN>`), a bundled Journey content pack + manifest + resolver, a progression read-model over F08's `journey_progress`, the unlock write on the F04 win path, CONTINUE / `Next Level` / terminal navigation, the levels 4–6 column micro-tutorial, the real home surface replacing the debug `HomeScreen`, and the F04 `CompletionPanel` per-outcome CTA weighting (`architecture.md §16`).
* **QA scope:** client-only (`frontend.md` present, no `backend.md`) + UI Handoff Compliance (`ui-design.md` present) + regression (F03 play / F04 completion). Verified against the current tree at `frontend.md` "F05-FE".

---

## 2. Test Scope

* **Scope Type:** Client Only + UI Handoff Compliance.
* **Reviewed documents:** `prd.md` (AC1–AC14), `architecture.md` (LOCKED — §4–§17), `ui-design.md` (Direction A "The loop, filling"), `frontend.md` (F05-FE delivery + §17/§18 test evidence), `orchestration.md` (QA Scope `[LOCKED]`, ledger, Blockers, Next Action brief), `design/design-doctrine.md` §8, `design/premium-ui-rubric.md` (Fail Conditions), `project-authority/setup-manifest.md` (canonical commands), `features/f03-.../` + `features/f04-.../` architecture + ui-design (consumed contracts).
* **Tested (automated functional, evidence in §3/§4/§5):** the id/number mapping; the manifest parser + the bundled-content resolver (incl. corrupt / missing / id-mismatch → `JourneyContentException`); the progression read-model vs the real `JourneyProgressRepo` + in-memory DB (`LevelState`, `progressCount`, `continueTarget`, in-progress derivation); the unlock write on the win path through the real `/play` screen (`markCompleted` fires, ordered after `personal_best`, caught; Retry + re-solve idempotent); the home surface (new / mid / terminal render + ring `Semantics` accuracy + CONTINUE/REPLAY navigation); the 4–6 column micro-tutorial (shows on level 4, gated on a committed column drag, ack persisted, existing-ack suppression, leave-doesn't-persist); the F04 CTA weighting per outcome (one amber pill; 3★→`SONRAKİ` amber; 1–2★→`Yeniden` amber + `SONRAKİ` enabled; unwired→`· yakında`); the content-manifest gate (real bundled pack via `rootBundle`, `smoke`-mode shortfall logs + passes).
* **Not adequately tested — see Findings:** the `Next Level` (`SONRAKİ`) CTA tap → navigation chain (AC12) — only the `nextJourneyLevel` routing function is unit-tested (**F05-QA-1**); the manifest gate's `mode:"strict"` failure path (**F05-QA-2**).
* **Deferred by contract (`[PENDING — F06-CONTENT]`, not F05-FE's to satisfy):** AC3 / AC5 / AC6 difficulty-curve bands + the gate's structural band rules — need the 30 authored levels + a `mode:"strict"` manifest; F05 → `Done` is separately gated on "strict gate green" (`architecture.md §5.5`, §17).
* **Out-of-scope conditional sections (with reason):**
  * `0. Backend Build Gate` — **no backend**; `Release Scope = none`; client CI gate results are in `## 6`.
  * `6.5 Security Compliance Check` — **Security compliance out of scope:** single actor, local-only `journey_progress` + one `kv` flag, no auth / network / endpoint / cross-user resource (`architecture.md §15` explicitly directs this justification).
  * `6.7 Release / CI-CD Compliance Check` — **Release compliance out of scope:** `Release Scope = none` (`architecture.md §13`); no infra / CI config / deploy / container / env / schema change. Code CI gates still apply and are reported in `## 6`.
  * `6.8 iOS Platform Compliance Check` — **iOS platform compliance out of scope:** Flutter (not Unity) client, no `game-dev.md`, no new SDK / IAP / tracking / required-reason API. (iOS release *build* verified — `## 6`.)
  * `13. Backend Quality` — **Backend quality out of scope:** no backend.
  * `14a` / `14b` Game sections — no `game-dev.md`.
* **Critical user journeys:** brand-new player → CONTINUE → Level 1; mid-campaign → CONTINUE → lowest unlocked-incomplete; solve a Journey level (any star) → next unlocks + `Next Level` advances; all 30 done → terminal + `TEKRAR OYNA`; first 4–6 entry → learn the column shift by doing it. **Forbidden / misuse:** replay a completed level must not re-lock or inflate progress; a caught unlock-write failure must not block the panel; leaving the tutorial early must not persist `ack`; the home must expose no navigation to a locked level; `/` is app-root (no back).
* **Navigation / chrome scope:** `/` (app root, no back, no header) and `/play` (F03 chrome + `_popToCaller` with a `!canPop → context.go('/')` fallback); no new routes; terminal + tutorial are in-screen states.
* **Evidence class summary:** `automated functional` for all covered functional/AC/variant items; `source-only` cross-check only where noted (offline no-network path, the F08 restore internals which are F03's tested code).
* **Runtime validation method:** `automated functional`.

---

## 3. Product Behavior Coverage

| User Story (`prd.md §2`) | Test scenario | Evidence | Result |
| --- | --- | --- | --- |
| "30 sequential levels that unlock as I finish them" | Solve `journey-tr-01` via `/play` → DB `highestUnlockedLevel` 1→2, `completedLevelsCsv` contains `1`; model `stateOf(4)==unlockedIncomplete` after completing 1..3 | `test/journey/journey_unlock_flow_test.dart` ("solving a Journey level marks it complete and unlocks the next"); `test/journey/journey_progress_model_test.dart` ("after completing 1..3 …") | **PASS** |
| "difficulty ramps gently, one new idea at a time" | The 4–6 column intro is gated + taught; the ramp bands (1–3 / 7–10 / 11–30) are authored content | `column_tutorial_test.dart`; bands = `[PENDING — F06-CONTENT]` per `architecture.md §5.5`/§17 | **PARTIAL** — F05-FE part (the tutorial gate) PASS; the curve bands are deferred content |
| "CONTINUE drops me straight into my current level" | New → CONTINUE nav `journeyLevel:1`; mid (1..3 done) → `journeyLevel:4`; terminal → `TEKRAR OYNA` → `journeyLevel:1` | `test/journey/journey_home_test.dart` (all three) | **PASS** |
| "see how far through the Journey I am" | Ring `Semantics` label = `"<done> / 30 seviye tamamlandı — Seviye <current>"`, accurate at 0 / 3 / 30 completed | `journey_home_test.dart` (`hasSemanticsLabel` assertions) | **PASS** |

No user story is left entirely uncovered. The "one new idea at a time" ramp is a **content** deliverable (`F06-CONTENT`) — F05-FE ships the mechanism (the tutorial gate) and it is tested.

---

## 3a. Mode / Configuration Matrix

| Mode / Configuration | Expected behaviour | Tested? | Result | Evidence |
| --- | --- | --- | --- | --- |
| Manifest `mode:"smoke"` (interim, shipped) | Gate asserts consistency of the present levels, logs the `<30` shortfall, **passes** | Yes | **PASS** | `test/journey/journey_manifest_gate_test.dart` — "journey content gate (smoke): 5/30 levels …" printed, suite green |
| Manifest `mode:"strict"` (post-`F06-CONTENT`) | `levels.length == 30` **required**; `<30` / missing asset / band violation **fails CI** | **No** | **GAP → F05-QA-2** | The `if (manifest.isStrict)` branch in the gate test never executes (shipped manifest is `smoke`); no synthetic strict manifest is fed to the gate |
| Home — brand new (0 / 30) | ring all-dim + node at 1; `DEVAM ET` / `Seviye 1`; CONTINUE → level 1 | Yes | **PASS** | `journey_home_test.dart` ("a new player → …") |
| Home — mid-campaign | `N` amber ticks + current node; `DEVAM ET` / `Seviye N+1`; CONTINUE → next gap | Yes | **PASS** | `journey_home_test.dart` ("mid progression → …") |
| Home — in-progress level | current node gets a `cyan` ring; caption `Seviye N · sürüyor`; CONTINUE → the in-progress level | Model only | **PARTIAL → N1** | `journey_progress_model_test.dart` proves `inProgressLevel` / `continueTarget`; the home *widget* render of this variant is not asserted |
| Home — all 30 complete (terminal) | full ring + `TAMAMLANDI` kicker; CONTINUE → `TEKRAR OYNA` → level 1 | Yes | **PASS** | `journey_home_test.dart` ("all 30 complete → …") |
| CompletionPanel — 3★ / `isPerfect` | amber pill = `SONRAKİ`, ghost pill = `Yeniden`; exactly one amber pill | Yes | **PASS** | `test/rating/completion_cta_weighting_test.dart` (case 1) |
| CompletionPanel — 1–2★ (not perfect) | amber pill = `Yeniden`; ghost `SONRAKİ` **enabled**, no `· yakında` | Yes | **PASS** | `completion_cta_weighting_test.dart` (case 2, `stars:2`) |
| CompletionPanel — `Next Level` unwired (debug entry) | ghost `SONRAKİ` **disabled** with `· yakında`; amber stays `Yeniden` | Yes | **PASS** | `completion_cta_weighting_test.dart` (case 3); F04 `completion_panel_test.dart:126` still green |
| Micro-tutorial — level ∈ 4..6, ack unset | overlay shown | Yes | **PASS** | `column_tutorial_test.dart` (case 1) |
| Micro-tutorial — ack already set | overlay suppressed | Yes | **PASS** | `column_tutorial_test.dart` (case 2) |
| Micro-tutorial — level ∉ 4..6 | overlay not shown | Not asserted | **PARTIAL → N3** | gate is `level >= 4 && level <= 6` (trivially correct); other suites use `debugPuzzleId` (journeyLevel null) so the overlay is implicitly absent but never asserted |

---

## 4. Acceptance Criteria Traceability

| AC | Requirement | Test scenario / evidence | Result |
| --- | --- | --- | --- |
| **AC1** | complete N (any star) → N+1 unlocked | `journey_unlock_flow_test.dart` (solve `journey-tr-01` at 3★/Perfect → `highestUnlockedLevel==2`); `journey_progress_model_test.dart` (`markCompleted` 1..3 → `stateOf(4)==unlockedIncomplete`) | **PASS** (3★ path integration; 1★ path star-agnostic by construction — `_resolveJourneyUnlock` never reads stars — see N7) |
| **AC2** | locked N+1 not openable (no navigation, locked affordance) | `journey_progress_model_test.dart` (`stateOf(2)==locked` for a fresh guest); no navigation path emits a locked target (home → `continueTarget`, tested in `journey_home_test.dart`) | **PARTIAL** — "no navigation" holds by construction + tests; **direct entry to an arbitrary `journeyLevel` is not guarded and not tested (N5)**; the "clear locked affordance" is explicitly **out-of-MVP** (`prd.md §5`, `ui-design.md §10` — no level-select map) |
| **AC3** | levels 1–3 rows-only, opt 3–4 | `[PENDING — F06-CONTENT]` — interim smoke levels knowingly don't meet the band (`journey_manifest_tr.json` `_note`); gate band rules stubbed for strict mode | **DEFERRED (content)** — not an F05-FE gate; F05 `Done` gated on the strict gate |
| **AC4** | first 4–6 entry → column micro-tutorial + column shifts available | `column_tutorial_test.dart` (overlay shows on `journeyLevel:4`; a committed column drag clears it; `journey-tr-04` has `columnMovesEnabled:true`) | **PASS** |
| **AC5** | levels 7–10 rows+cols, opt 4–6 | `[PENDING — F06-CONTENT]` | **DEFERRED (content)** |
| **AC6** | levels 11–30 curve bands (temp-displacement / locked / frozen / combined) | `[PENDING — F06-CONTENT]`; interim `journey-tr-04` renders a locked cell, `journey-tr-05` a frozen cell (F03 render path) | **DEFERRED (content)** |
| **AC7** | CONTINUE on an in-progress level → resumes exact saved state | `journey_progress_model_test.dart` (in-progress snapshot → `inProgressLevel==2`, `continueTarget==2`); the F08 restore of grid/moves/undo/thawed/elapsed is F03's `restoreFrom` path, unchanged, proven in `test/play/play_session_runtime_test.dart §17.3` | **PASS (mechanism)** — the F05 resolution to the in-progress level is tested; the home in-progress *widget* variant is not (N1); end-to-end resume via F05's home is not chained in one test (N1) |
| **AC8** | no in-progress → lowest unlocked-incomplete | `journey_progress_model_test.dart` (`continueTarget==4` after 1..3); `journey_home_test.dart` (new → level 1; mid → level 4) | **PASS** |
| **AC9** | all 30 complete → graceful terminal, no crash | `journey_progress_model_test.dart` (`allComplete`, `continueTarget==null`); `journey_home_test.dart` (terminal: `TAMAMLANDI`, `TEKRAR OYNA`, nav to level 1, no exception) | **PASS** |
| **AC10** | progress indicator visible + accurate | `journey_home_test.dart` — ring `Semantics` label exact at `0 / 30`, `3 / 30`, `30 / 30` | **PASS** |
| **AC11** | force-quit during 4–6 tutorial → re-shows until acknowledged | `column_tutorial_test.dart` (leave without a column move → `isColumnTutorialAcknowledged()==false`; a fresh mount with `!ack` → overlay shows; `ack` set → suppressed) | **PASS (mechanism)** — the gate is `!ack` and leaving never persists; a single chained "force-quit → re-enter → re-shows" scenario is not written (N4) |
| **AC12** | `Next Level` on panel of N (N<30, n+1 present) → level N+1's `/play` via `pushReplacement`; N==30 / last available → terminal | **Only `nextJourneyLevel(n, manifestLevelCount)` is unit-tested** (`journey_ids_test.dart`). **No test taps `SONRAKİ` and verifies navigation** to N+1 or to the terminal. `completion_cta_weighting_test.dart` uses a no-op `onNextLevel`. | **FAIL (coverage) → F05-QA-1 (blocking)** |
| **AC13** | Journey level at 1★ → `Next Level` available | `completion_cta_weighting_test.dart` (case 2, `stars:2` → `SONRAKİ` present + enabled, no `· yakında`); 1★ takes the identical branch (`nextIsPrimary = isPerfect && canNext`, `isPerfect==false` for 1★ and 2★) | **PASS** (by construction; 1★ not separately solved — N7) |
| **AC14** | offline → bundled load + local save | `journey_manifest_gate_test.dart` loads the real bundled pack via `rootBundle` (no network); source inspection: `RootBundleJourneyAssetSource` is `rootBundle.loadString` only, `JourneyContentRepo` has no network path; progress persists via Drift `JourneyProgressRepo` | **PASS** (bundle load + local persist proven; no network code exists in the F05 path — no explicit airplane-mode test, none needed) |

**Uncovered / failing AC → blocking finding:** **AC12** (F05-QA-1). AC3/AC5/AC6 are contract-deferred to `F06-CONTENT` (not an F05-FE coverage gap). AC2 partial (N5). AC7/AC11 mechanism-covered with thin widget/chained coverage (N1/N4).

---

## 5. Boundary Matrix

| Boundary / transition | Test result | Evidence |
| --- | --- | --- |
| First unlock (level 1 → 2) | **PASS** | `journey_unlock_flow_test.dart` |
| Mid-run unlock (after 1..3 → level 4 current) | **PASS** | `journey_progress_model_test.dart` |
| Re-complete a completed level (idempotent — no re-lock, no progress inflation) | **PASS** | `journey_unlock_flow_test.dart` ("Retry + re-solve is idempotent — progress does not double-count": `completedLevelsCsv` still single `1`, `highestUnlockedLevel` still 2) |
| Last available interim level (5) → `Next Level` → terminal | **PARTIAL** | `nextJourneyLevel(5, manifestLevelCount:5) == null` unit-tested (`journey_ids_test.dart`); the tap → `context.go('/')` is not (F05-QA-1) |
| Level 30 → `Next Level` → terminal | **PARTIAL** | `nextJourneyLevel(30, …) == null` unit-tested; tap → terminal not (F05-QA-1); no 30-level manifest exists to run it against (interim = 5) |
| All 30 completed → `continueTarget == null` → terminal home | **PASS** | `journey_progress_model_test.dart`, `journey_home_test.dart` |
| `markCompleted` stray id (`markCompleted(30)` unlocks internal "31") → `progressCount` clamps to 1..30 | **PASS** | `journey_progress_model_test.dart` ("stray / out-of-range completed ids are clamped for the count") |
| Manifest with non-contiguous `n` | **PASS** (rejected) | `journey_content_repo_test.dart` ("manifest with non-contiguous levels → JourneyContentException") |
| Resolver: missing entry / missing asset / corrupt JSON / id mismatch → `JourneyContentException`, rest playable | **PASS** | `journey_content_repo_test.dart` (5 cases; "level 2 still resolves" after level 1 corrupt) |
| Corrupt journey asset → F03 `_LoadErrorBody` on `/play` | **PARTIAL** | resolver exception unit-tested; the screen's `setup.when(error:)` → `_LoadErrorBody` is F03's wiring, covered for the `daily` source in `play_session_screen_test.dart` ("an unsupported source shows the load-error state"); not re-exercised with a journey `JourneyContentException` (N... — folded into N... see notes) |
| Micro-tutorial: shown → column drag → satisfied + ack | **PASS** | `column_tutorial_test.dart` (case 1) |
| Micro-tutorial: shown → row drag → NOT satisfied (still shown, ack still false) | **PASS** | `column_tutorial_test.dart` (case 1, mid-assertion) |
| Micro-tutorial: leave before the gated action → ack not persisted | **PASS** | `column_tutorial_test.dart` (case 3) |
| Manifest `mode:"strict"` + `<30` / missing asset → gate fails | **NOT TESTED** | **F05-QA-2** |
| `_popToCaller` `!canPop` → `context.go('/')` fallback | **PARTIAL** | source-verified in `play_session_screen.dart` (`GoRouter.of(context)` → `canPop() ? pop() : context.go(Routes.home)`); not integration-tested (low risk — 3-line F03-adjacent change; F03's back behaviour otherwise unchanged) |

---

## 6. Contract Compliance Check

Client CI gates (canonical commands per `setup-manifest.md` — run directly; `melos` not on PATH):

| Gate | Command | Result |
| --- | --- | --- |
| Analyze | `flutter analyze` (app) | **PASS** — "No issues found!" |
| Format | `dart format --output=none --set-exit-if-changed .` (app + `packages` + `tools`) | **PASS** — 0 changed (85 + 59 files) |
| Test (app) | `flutter test` | **PASS** — **166/166** (132 baseline + 34 new F05; pre-existing drift "multiple databases" warnings in `play_session_screen_test.dart` only, non-fatal, not introduced here) |
| Test (pure packages) | `dart test` in `looplet_{core,dictionary,engine,content,solver}` + `looplet_authoring` | **PASS** — 22 / 32 / 83 / 17 / 23 / 19 |
| Content-manifest gate | `flutter test test/journey/journey_manifest_gate_test.dart` (`melos run content:journey`) | **PASS** — 4/4 (smoke-mode shortfall logged) |
| iOS release build | `flutter build ios --release --no-codesign` | **PASS** — `Runner.app` 54.7 MB |
| Android appbundle | `flutter build appbundle --release` (`melos run build:app`) | **NOT RUN — CI-only** (no local JDK / Android SDK; consistent with F03/F04 precedent) |

| Contract area (`architecture.md`) | Compliance |
| --- | --- |
| §4 — id scheme `journey-<lang>-<NN>` ↔ `journeyLevelNumber`; F08 snapshot NOT extended (in-progress level = `parseJourneyLevel(puzzleId)`) | **PASS** — `journeyLevelId` / `parseJourneyLevel` (`journey_ids_test.dart`); `buildJourneyProgressModel` derives `inProgressLevel` from `snap.puzzleId` only when `puzzleSource==journey && status==inProgress`; no snapshot field added |
| §5.2–5.3 — manifest schema + resolver (`rootBundle`, `Puzzle.fromJson`, id/number/checksum asserts, cache, `JourneyContentException` → F03 load-error) | **PASS** — `JourneyManifest.fromJson` (schemaVersion==1, mode ∈ {smoke,strict}, contiguous n), `JourneyContentRepo.loadLevel` (`journey_content_repo_test.dart` + `journey_manifest_gate_test.dart`) |
| §5.4 — content-manifest build gate, smoke/strict | **PARTIAL** — smoke path PASS; strict path untested (**F05-QA-2**); band rules stubbed for `F06-CONTENT` |
| §5.5 — interim `mode:"smoke"` manifest, F06 smoke → levels 1–5 | **PASS** — `app/assets/journey/tr/journey_manifest_tr.json` maps n=1→smoke01, 2→smoke02, 3→smoke04, 4→smoke05 (locked `3,3`, `columnMovesEnabled`, opt 2), 5→smoke06 (frozen `2,2`, `columnMovesEnabled`, opt 1); sha256 checksums verified by the gate |
| §6 — progression read-model over `watch` + one snapshot read; all four `LevelState` | **PASS** — `buildJourneyProgressModel` + `journeyProgressModelProvider`; `journey_progress_model_test.dart` covers all four states + `progressCount` clamp + `continueTarget` |
| §7 — unlock write injected into `PlaySessionController`, `unawaited`, caught, after the `personal_best` write, journey-only, idempotent | **PASS** — `_resolveJourneyUnlock()` (source-verified: guarded by `source == PuzzleSource.journey`, `try/catch → debugPrint('journey: unlock_persist_failed …')`, called by `unawaited(...)` after `_ratingWork = _resolvePersonalBest(...)`); `journey_unlock_flow_test.dart` proves the write fires + idempotency |
| §8 — CONTINUE / `Next Level` (`pushReplacement`) / terminal; no new route; all back → `/` | **PARTIAL** — CONTINUE nav PASS (`journey_home_test.dart`); `Next Level` routing *decision* PASS (`nextJourneyLevel`); the `Next Level` *tap → navigation* is untested (**F05-QA-1**); `_popToCaller` `/` fallback source-verified |
| §9 / §14 — 4–6 tutorial-ack in a `kv` row `journey_col_tutorial_ack`, no F08 schema change | **PASS** — `JourneyTutorialRepo` uses `KvRowsCompanion.insert` / `insertOnConflictUpdate` on the existing `kv` table; no migration; `column_tutorial_test.dart` |
| §11 — F09 seam `onboardingComplete` hard-`true` | **PASS** — no onboarding gate added; `/` → `HomeScreen` directly; a brand-new player's CONTINUE → Level 1 (`journey_home_test.dart`) |
| §16 — F04 `CompletionPanel` per-outcome CTA weighting, additive, one amber pill | **PASS** — `_Actions.isPerfect` + single `_CtaPill`; `completion_cta_weighting_test.dart` + F04 `completion_panel_test.dart` regression green |
| No F03/F04/F06/F08 contract change | **PASS** — `PlaySessionController` / `PlaySessionArgs` gained only *optional* params; `playSessionSetupProvider` filled its existing journey branch; `completion_panel.dart` change is additive; `content/` (F06) untouched |

Contract **version / breaking change:** none. F05 adds optional ctor params + one `kv` key + new `app/lib/journey/` files + interim assets; no signature break, no schema change, no F03/F04/F06/F08 file contract altered.

---

## 7. UI Design Compliance Check

* **`ui-design.md` present:** yes (Direction A "The loop, filling"). Runtime validation method for visuals: `automated functional` (widget structure + `Semantics`) + source inspection of `home_screen.dart` / `column_tutorial_overlay.dart` / `completion_panel.dart`. No screenshot tool — pixel-level polish is a device-smoke item (`architecture.md §15`).
* **Screen goal:** **PASS** — the home's job ("know where I am, get back in one tap") is met: ring hero + `N / 30` centre + one dominant CONTINUE.
* **UX flow:** **PASS** — no level-select map, no confirm dialogs, no spinner; CONTINUE → `currentLevel`; tutorial gates on doing.
* **Visual hierarchy:** **PASS** — `_Wordmark` (secondary) → `_JourneyRing` + `_RingCentre` count (hero) → `_ContinueCta` (dominant amber) → caption (quiet). One vertical spine, `ConstrainedBox(maxWidth: 460)` centred.
* **CTA priority:** **PASS** — exactly one filled amber pill on the home; the completion panel guarantees exactly one amber pill chosen by `isPerfect` (`§16` / `§7.4`).
* **State visibility:** **PASS with notes** — new / mid / terminal / loading render distinctly (`kicker` swaps `SEVİYE`↔`TAMAMLANDI`, CTA label `DEVAM ET`↔`TEKRAR OYNA`, ring fill length). **In-progress variant:** the `cyan` ring on the current node is drawn, **but the specified ~4 s ±6 % breathing pulse is not implemented** (static ring only) — **N2**. **Terminal:** full-amber ring + `TAMAMLANDI` render, **but the "one restrained bloom on entry" one-shot is not implemented** (static glow only) — **N2**.
* **Background system:** **PASS** — `HomeScreen` wraps content in `PlayStage` (F03's exact `stage-0 → stage-1` gradient + radial spotlight + corner vignette); `/` ⇄ `/play` is one continuous lit space. Note: `PlayStage` itself documents "ambient breathing deferred for `pumpAndSettle` determinism" — the F05 motion omissions in N2 are consistent with that established F03 precedent.
* **Surface / depth:** **PASS** — stage (deep) < ring glow + count (lit) < CONTINUE pill (raised, saturated, amber shadow). No cards, no stray borders.
* **Typography:** **PASS** — reuses `PlayTheme` roles; tabular `N` (50 pt, `paper`) + `/ 30` (22 pt, `muted`) + `SEVİYE` micro-label; wordmark w800 / 32 pt / tracking 6. Count change → `TweenAnimationBuilder` 1.06→1.0 scale settle keyed on `count` (spec asked 1.0→1.06→1.0; settle-only is an acceptable technical variance).
* **Premium quality:** **PASS** — `premium-ui-rubric.md` Fail Conditions **absent**: clear hero, unambiguous CTA, strong hierarchy, layered surface, non-generic (30-tick loop tied to product identity), "top mobile game" register. No `design-doctrine.md §8` anti-pattern (no "üstte gradient + altta rastgele kartlar", no generic blue button, no cards). Estimated rubric ≥ 90 holds structurally; N2 is polish-motion, not a fail condition.
* **Accessibility:** **PASS** — the ring is one `Semantics` node with the "N of 30 … current level" label (asserted); CONTINUE has a `Semantics(button:true, label: '<label> — Seviye <n>')`; the tutorial hint is rendered text. Reduced motion: overlay ghost → static pose (`FakeAccessibilityFeatures(disableAnimations:true)` path in `column_tutorial_test.dart`).
* **Minor:** CONTINUE pill fixed width 240 ≈ 55–62 % of a typical phone vs `ui-design.md §7.2` "~66–72 %" — dominance preserved (sole filled control); **N6**.

---

## 8. Test Findings

## [F05-QA-1]

* **Title:** AC12 — the `Next Level` (`SONRAKİ`) CTA → navigation is not tested (only the routing function is)
* **Severity:** High (blocking)
* **Area:** Frontend / Navigation / AC traceability
* **Related Task:** F05-FE.NAV, F05-FE.TESTS
* **Type:** State/Flow Bug (test-coverage gap on a headline AC + a navigation flow)
* **Description:** AC12 ("Given `Next Level` on the panel of level N (N < 30) … navigates to level N+1's play session; Given N == 30 … routes to the terminal state") and `architecture.md §15` ("`Next Level` (`automated functional`): panel of N … → level N+1's `/play` via `pushReplacement`; panel of the last available level / level 30 → terminal (AC12)") require automated-functional evidence of the **trigger → navigation** chain. The only coverage is the pure function `nextJourneyLevel(n, manifestLevelCount)` (`journey_ids_test.dart`). `completion_cta_weighting_test.dart` renders the `SONRAKİ` pill with a **no-op** `onNextLevel`. No test taps the rendered `SONRAKİ` on a real `/play` `CompletionPanel` and asserts (a) landing on N+1's `/play` via `pushReplacement` with no back-stack growth, or (b) the last-available / level-30 case routing to `context.go('/')` (terminal home). `qa.md` FAIL-FAST gate: a navigation flow whose only evidence is a unit test cannot yield `Approved`.
* **Expected:** A widget/integration test (real `/play` screen, overridden `journeyAssetSourceProvider` with ≥2 contiguous journey levels): solve level N → tap `SONRAKİ` → the screen shows level N+1 (target/board for N+1), the route was replaced (not stacked); and a second test where N is the last available level → tap `SONRAKİ` → the home terminal variant (or `/`) is shown.
* **Actual:** No such test exists; `Next Level` navigation is asserted nowhere.
* **Recommendation:** Add the two scenarios to `test/journey/` (the `_MapAssetSource` + `_app` helpers in `journey_unlock_flow_test.dart` already provide the harness — extend its manifest to 2 levels and tap `SONRAKİ` instead of `Yeniden`). Assert `find` for N+1's target word after the tap, and `find.text('PLAY ROUTE')`-style route capture / back-stack depth for the `pushReplacement` guarantee.

## [F05-QA-2]

* **Title:** The content-manifest gate's `mode:"strict"` failure path has no executed coverage
* **Severity:** Medium (blocking — Mode/Configuration variant, `architecture.md §15` explicit QA item)
* **Area:** Frontend / build gate / configuration matrix
* **Related Task:** F05-FE.GATE, F05-FE.TESTS
* **Type:** State/Flow Bug (untested configuration variant)
* **Description:** `architecture.md §5.4` / §15 require that a `mode:"strict"` manifest with `< 30` levels (or a missing asset, or a band violation) **fails CI**. The gate test's strict assertion (`if (manifest.isStrict) expect(manifest.levels.length, journeyLevelCount)`) is **guarded by `manifest.isStrict`, which is `false`** for the shipped interim manifest — so the strict branch is never executed by any test. `qa.md` Mode/Configuration Matrix: "Varyant eksikliği → blocking finding." The band-rule portion is legitimately deferred to `F06-CONTENT` (needs real content), but `strict ⇒ levels.length == 30` and `strict + missing asset → fail` are testable now with a synthetic manifest.
* **Expected:** A unit test that constructs a `mode:"strict"` manifest map with `< 30` entries (and one with a missing/unresolvable asset) and asserts the gate logic rejects it. `test/journey/journey_content_repo_test.dart` already has a `_manifest(levelCount, {mode})` helper.
* **Actual:** No test feeds a strict manifest to the gate; the strict path is dead code in test terms until `F06-CONTENT` flips the mode.
* **Recommendation:** Add a `strict`-mode unit test now (bare `levels.length == 30` + missing-asset). The structural band rules may remain a documented `[PENDING — F06-CONTENT]` stub.

## [N2] (non-blocking) — UI Design Mismatch

* **Title:** In-progress node breathing pulse + terminal entry bloom not implemented
* **Severity:** Low (non-blocking)
* **Area:** Frontend / UI handoff (`ui-design.md §7.1`, §11 "Must not be broken")
* **Type:** UI Design Mismatch
* **Description:** `ui-design.md §11` lists, under "Must not be broken": the in-progress node gets "a slow (~4 s, ±6 %) breathing pulse" and the terminal state gets "one restrained bloom on entry". `_JourneyRingPainter` draws the **static** `cyan` ring for `currentInProgress` and the **static** full-amber glow at 30/30 — no animated pulse, no one-shot bloom. The state signals (cyan ring, full-amber ring, `TAMAMLANDI`) are all present and readable; only the motion refinement is missing.
* **Expected:** A ~4 s ±6 % opacity pulse on the in-progress tip-dot; a single bloom on terminal entry (both static under reduced motion).
* **Actual:** Static ring / static glow.
* **Recommendation:** FE adds the two animations (a small `AnimationController` in `_JourneyRing`, reduced-motion → end-state), **or** Tech Lead accepts the static treatment as consistent with `PlayStage`'s established "ambient motion deferred for test determinism" precedent. Not a rubric fail condition; does not block.

---

## 9. Positive Scenarios

1. **Brand-new player continues into Level 1.** Start: fresh guest, `journey_progress` seeded (`highestUnlockedLevel 1`, no completed). Action: open `/` → tap `DEVAM ET`. Visible result: navigates to `/play` with `PlaySessionArgs(source: journey, journeyLevel: 1)`; ring shows `0 / 30`; caption `Seviye 1`. Evidence: `journey_home_test.dart` ("a new player → …").
2. **Mid-campaign resume to the next gap.** Start: levels 1–3 completed. Action: `/` → `DEVAM ET`. Result: ring `Semantics` = `"3 / 30 seviye tamamlandı — Seviye 4"`; nav → `journeyLevel: 4`. Evidence: `journey_home_test.dart` ("mid progression → …").
3. **Solve a Journey level → next unlocks.** Start: `/play` `journeyLevel:1` (`journey-tr-01`, opt 1). Action: one row-0 right swipe → MASAL → `CompletionPanel`. Result: `JourneyProgressRepo.read` shows `completedLevelsCsv` ⊇ `1`, `highestUnlockedLevel == 2`; the unlock write ran after the `personal_best` write, caught. Evidence: `journey_unlock_flow_test.dart` (case 1).
4. **Replay is idempotent.** Start: level 1 just solved. Action: tap `Yeniden` → re-solve. Result: `completedLevelsCsv` still a single `1`, `highestUnlockedLevel` still 2 — no double-count, no re-lock. Evidence: `journey_unlock_flow_test.dart` (case 2).
5. **Learn the column shift by doing it.** Start: `/play` `journeyLevel:4` (4–6 band, ack unset). Result: `ColumnTutorialOverlay` shown with the hint line; a **row** drag leaves it up (ack still false); a **column** drag fades it and writes `journey_col_tutorial_ack`. Evidence: `column_tutorial_test.dart` (case 1).
6. **Finish the whole Journey.** Start: all 30 completed. Action: open `/`. Result: kicker `TAMAMLANDI`, CTA `TEKRAR OYNA`, ring `Semantics` = `"30 / 30 seviye tamamlandı"`, tapping → `journeyLevel: 1` (replay, progress not reset), no exception. Evidence: `journey_home_test.dart` ("all 30 complete → …").
7. **3★ makes NEXT loud, 1–2★ keeps RETRY loud.** `completion_cta_weighting_test.dart`: 3★ → amber pill text is `SONRAKİ`; 2★ → amber pill stays `Yeniden`, `SONRAKİ` present + enabled; unwired → `SONRAKİ` disabled + `· yakında`. Exactly one amber pill in every case.

---

## 10. Negative / Edge Cases

* **Replay a completed level** → no re-lock, no progress inflation (`markCompleted` idempotent). **PASS** — `journey_unlock_flow_test.dart` (case 2).
* **Corrupt / missing / id-mismatched journey asset** → `JourneyContentException`; the rest of the Journey still resolves. **PASS** — `journey_content_repo_test.dart` (5 cases). The screen-level render of F03's `_LoadErrorBody` from a *journey* exception is not re-exercised (F03's `.when(error:)` is proven for the `daily` source in `play_session_screen_test.dart`) — low risk.
* **Non-contiguous manifest** → rejected at parse. **PASS**.
* **`markCompleted` overshoot** (level 30 unlocks internal "31") → `progressCount` clamps to 1..30. **PASS**.
* **Leave the 4–6 tutorial via the chevron before the gated action** → `ack` not persisted → re-shows next entry. **PASS (mechanism)** — `column_tutorial_test.dart` (case 3) + case 1's fresh-mount-shows; a single chained "force-quit → re-enter → re-shows" is not written (**N4**).
* **Tutorial not shown outside 4–6** — gate is `level >= 4 && level <= 6`; not asserted for 1–3 / 7+ (**N3**).
* **Direct entry to a locked `journeyLevel`** (e.g. `PlaySessionArgs(journeyLevel: 3)` for a fresh guest) — the resolver would load and play it, and completing it would `markCompleted(3)` → `highestUnlockedLevel = 4`, skipping the gate. **No shipping code path produces this** (home → `continueTarget`; `Next Level` → n+1 only after completing n; no deep-link config; `/play` no-extra falls back to a debug id). Not guarded, not tested. **N5** — recommend a defensive guard (`journeyLevel > highestUnlockedLevel && not in-progress → JourneyContentException`) + a test, or Tech Lead accepts "unreachable by construction" and records AC2's "locked affordance" as out-of-MVP (`prd.md §5`).
* **`Next Level` on the last available / level 30** → routing decision returns `null` → `context.go('/')`. Function-tested; tap-through not (**F05-QA-1**).
* **Caught unlock-write failure** → `debugPrint('journey: unlock_persist_failed …')`, panel unaffected. Source-verified (`_resolveJourneyUnlock` `try/catch`); consistent with F03 `_persist` / F04 `_resolvePersonalBest` posture. The fault-injection test is the shared storage-full test-debt class (`architecture.md §7` — F03 QA note 3 / F08 AC7 / F04 N3), a tracked follow-on, not an F05 gate.
* **`/` is app root** → no back affordance, no system header. **PASS** — `HomeScreen` `Scaffold` has no `AppBar`; source-verified.

---

## 11. Integration Findings

* **AC12 navigation (F05-QA-1)** — the `Next Level` CTA → `pushReplacement('/play', journeyLevel: n+1)` / `context.go('/')` chain is not integration-tested; only `nextJourneyLevel` (the decision) is. This is the single blocking integration gap.
* **In-progress home variant (N1)** — `journeyProgressModelProvider` correctly derives `inProgressLevel` / `continueTarget` (unit-tested against the real repo), but no widget test mounts `HomeScreen` with an in-progress snapshot to assert the `cyan` node + `Seviye N · sürüyor` caption + CONTINUE → the in-progress level. AC7's resume *mechanism* (F08 `restoreFrom`) is F03's, separately proven.
* **`_popToCaller` `/` fallback (N...)** — source-verified (`GoRouter.of(context)` → `canPop() ? pop() : context.go(Routes.home)`); not integration-tested. Low risk (F03-adjacent 3-line change; F03's back behaviour otherwise intact).
* No API → UI mapping (client-only, no backend). No header/back/chrome inconsistency: `/` is root (no chrome), `/play` keeps F03's chrome verbatim + the `/` fallback.

---

## 12. UX & State Handling

* **Loading:** **PASS** — `HomeScreen` renders `PlayStage` + wordmark + ring track instantly; `_RingCentre` shows a `SizedBox(height:40)` placeholder (no count) for the ≤1-frame model-load window; no spinner. `journeyProgressModelProvider.asData?.value` null-safe throughout.
* **Error:** **PASS (resolver)** — `JourneyContentException` → F03's `_LoadErrorBody` (`Geri` → `/`). The home has no error state by design (local seeded read).
* **Empty:** **PASS** — `0 / 30` is a designed state (dim ring + node at level 1), not an empty screen.
* **Success:** **PASS** — completion panel + unlock + `Next Level`/`Retry`/`Close`.
* **Disabled:** **PASS** — `SONRAKİ` renders disabled with `· yakında` only when `onNextLevel == null` (debug entry); for a real Journey session it is always enabled.
* **Selected / Focused:** ring / CONTINUE / panel CTAs carry `Semantics(button:true)` labels; the `amber` focus-ring visual is a `PlayTheme` default (not separately verified — no a11y device pass in scope).
* **CTA clarity:** **PASS** — one amber pill on the home; one amber pill on the panel, chosen by `isPerfect`.
* **Visual hierarchy / background / surface / typography / motion:** **PASS with N2** — see §7. Motion is light (settle-tick present; breathing pulse + terminal bloom absent — N2), consistent with F03's `PlayStage` "ambient deferred" precedent.
* **Runtime evidence summary:** `automated functional` — 34 new `flutter_test` cases (widget + unit + real-repo integration), full suite 166 green, iOS release build green. Device *feel* of the ring / tutorial / panel motion → deferred first-app-distribution smoke (`architecture.md §15`).

---

## 14. Frontend Quality

* **Code shape:** new code confined to `app/lib/journey/` (6 files) + interim assets; existing files (`play_session_providers.dart`, `play_session_controller.dart`, `play_session_screen.dart`, `completion_panel.dart`, `home_screen.dart`) received additive edits only — verified no F03/F04 signature or behaviour break (166 green, F04 debug-entry panel test intact).
* **Separation:** pure logic (`journeyLevelId` / `parseJourneyLevel` / `nextJourneyLevel` / `buildJourneyProgressModel` / `JourneyManifest.fromJson`) is isolated and heavily unit-tested; the `JourneyAssetSource` seam is injectable (fake source used across 3 test files); the unlock write mirrors F04's `personalBestRepo` pattern exactly (caught, `unawaited`, journey-guarded).
* **Analyze / format:** clean.
* **Weak spots:** the two blocking coverage gaps (F05-QA-1 navigation, F05-QA-2 strict gate) and the thin widget coverage of the in-progress home variant (N1) and the tutorial re-show chain (N4). The `lib/` code for all of these is present and reads correctly — the gaps are in the tests, not the implementation.
* **`content:sync` deviation (`frontend.md §4`):** the interim pack lives only under `app/assets/journey/tr/` (not `content/journey/`) and `melos run content:sync` is a documented no-op stub. **Verified:** F06's `content:check` (scans `content/`) is genuinely untouched (`looplet_authoring` tests green, unchanged); the gate (`journey_manifest_gate_test.dart`) reads the real `app/assets/journey/` pack, so the F05-FE.GATE guarantee is not weakened by the staging-location change. Acceptable; flagged for Tech Lead awareness — when `F06-CONTENT` lands, the source of truth must move to `content/journey/` per `architecture.md §5.1` and `content:sync` must become real.

---

## 15. UI Handoff Alignment

* **Aligned with `ui-design.md`:** the loop-filling home (F03 stage via `PlayStage`, `CustomPainter` 30-tick ring, ~300°/60°-gap geometry, one continuous glow on the completed run — not per-tick, `muted @ 30%` locked ticks, bright current node + `cyan` ring when in-progress, `N / 30` tabular centre + `SEVİYE`/`TAMAMLANDI` kicker); one dominant amber CONTINUE nested near the ring gap; terminal → `TEKRAR OYNA` → Level 1 (never hidden/greyed); the diegetic action-gated tutorial (dim + gesture ghost + one line, no button, cleared only by a `MoveAxis.column` drag, re-prompt on a row drag / 6 s idle, leave-doesn't-persist); the `§7.4` CTA weighting (exactly one amber pill; 3★→`SONRAKİ`; 1–2★→`Yeniden`; `· yakında` gone for wired sessions); no new `PlayTheme` tokens.
* **Deviations:** (N2) the in-progress breathing pulse + the terminal entry bloom are not implemented (static ring / static glow). (N6) CONTINUE pill width ~240 px < the "66–72 %" band. (Minor) the count settle is 1.06→1.0 not 1.0→1.06→1.0.
* **Acceptable technical differences:** the count-settle curve variance; motion deferral is consistent with `PlayStage`'s own documented precedent.
* **Unacceptable UX / visual deviations:** none — no fail condition, no anti-pattern, hero + CTA + hierarchy + stage parity all intact.
* **Premium-quality gaps:** N2 is the only handoff "Must not be broken" item not fully delivered; it is polish-motion (state readability is intact) and does not drop the rubric below 90.

---

## 16. Regression Risk

**Shared components F05 touches:**

* `PlaySessionController` (F03/F04) — +2 optional ctor params + `_resolveJourneyUnlock()`. Dependents: F03 play, F04 completion. **Tested:** `test/play/play_session_controller_test.dart` + `play_session_runtime_test.dart` + `play_session_screen_test.dart` all green; the win path, undo/restart, snapshot persist/restore unchanged. No regression.
* `playSessionSetupProvider` (F03) — filled the existing `journeyLevel` branch; `debugPuzzleId` + `UnsupportedError` (F07) paths unchanged. **Tested:** F03 screen/runtime suites green.
* `CompletionPanel` / `_Actions` (F04) — `_RetryCta` + `_NextLevelCta` collapsed into `_CtaPill`; `isPerfect` drives weighting. Dependents: F04. **Tested:** `test/rating/completion_panel_test.dart` (incl. the debug-entry `SONRAKİ` disabled + `· yakında` assertion) green; `completion_cta_weighting_test.dart` new. No regression — F04's six variants, star reveal, triptych, `Kapat` untouched.
* `home_screen.dart` — full rewrite. Old content was a debug `Wrap`; the debug shortcuts survive behind `kDebugMode` (`_DebugRow`). No other feature depends on the old home. `widget_test.dart` ("app bootstraps and shows the home shell") green.
* `app_router.dart` — **not modified** (F05 nav uses `context.push`/`pushReplacement`/`go` from within screens). No route graph change.
* `melos.yaml` — added `content:sync` (no-op stub) + `content:journey`; `content:check` untouched → F06 unaffected (`looplet_authoring` green).
* `pubspec.yaml` — added `assets: assets/journey/tr/` + `crypto: ^3.0.3` dev dep. `flutter pub get` clean; iOS build green.
* F08 `journey_progress` / `kv` — read + `markCompleted` + one new `kv` key; **no schema change** (verified — `KvRowsCompanion.insert`, no migration).

**Full-suite result:** `flutter test` 166/166 (132 baseline + 34 new). Pure packages 197 green. **No regression detected.**

---

## 17. Final Verdict

### **Rejected**

* **Blocking issues:** 2 required fixes.
  * **F05-QA-1** — AC12 (`Next Level` → navigation) has no automated-functional evidence; only the `nextJourneyLevel` routing function is unit-tested. A navigation flow whose sole evidence is a unit test triggers the `qa.md` FAIL-FAST gate.
  * **F05-QA-2** — the content-manifest gate's `mode:"strict"` failure path is never executed by any test (Mode/Configuration variant missing; `architecture.md §5.4`/§15 explicit).
* Both fixes are **test-only** and small — the `lib/` implementation (`_nextLevelHandler`, `nextJourneyLevel`, `JourneyManifest`, the gate) reads correctly and the harness helpers already exist. Root cause is a coverage gap, **not** a defect in shipping behaviour and **not** a handoff/contract problem (the LOCKED `architecture.md` + `ui-design.md` are correct and complete).
* **Non-blocking notes (do not need to be fixed for a pass, but recommended):**
  * **N1** — no widget test for the in-progress home variant (`cyan` node + `Seviye N · sürüyor` + CONTINUE → the in-progress level); the model derivation is tested. Recommend a widget test.
  * **N2** — the in-progress breathing pulse + the terminal entry bloom (`ui-design.md §11` "Must not be broken") are not implemented (static ring / static glow). State readability intact; consistent with `PlayStage`'s "ambient deferred" precedent. FE adds, or Tech Lead accepts.
  * **N3** — no explicit assertion that the 4–6 tutorial is **not** shown for bands 1–3 / 7+ (the `level >= 4 && level <= 6` guard is trivially correct).
  * **N4** — AC11 "force-quit → re-enter → re-shows" is proven only as separate pieces (leave-doesn't-persist + fresh-mount-shows), not as one chained scenario.
  * **N5** — direct entry to a locked `journeyLevel` is not guarded in the resolver and not tested. No shipping code path produces it; AC2's "locked affordance" is explicitly out-of-MVP (`prd.md §5`, `ui-design.md §10`). Recommend a cheap defensive guard + test, or a Tech Lead ruling of "unreachable by construction".
  * **N6** — CONTINUE pill width ~240 px is below the `ui-design.md §7.2` "66–72 %" band (dominance preserved).
  * **N7** — the 1★ unlock + 1★ `Next Level`-enabled path is covered by construction (the unlock write is star-agnostic; the 1★/2★ CTA branch is identical and 2★ is tested), not by an end-to-end 1★ solve.
  * **Carried context (not F05-FE's to close):** AC3/AC5/AC6 difficulty bands + the gate's structural band rules are `[PENDING — F06-CONTENT]`; F05 → `Done` remains gated on `F06-CONTENT` delivered + the strict gate green.

---

# WORKFLOW VERDICT SUGGESTION (NON-AUTHORITATIVE)

## QA Result

* **Rejected** — 2 blocking test-coverage gaps (F05-QA-1 AC12 navigation; F05-QA-2 strict-mode gate variant). All shipping behaviour verified correct; `analyze` / `format` / `flutter test` (166) / iOS build all green; no regression; UI handoff aligned (one low non-blocking motion gap, N2).

## Affected Areas

* Frontend / State / Flow (test coverage) — no contract, backend, integration-with-backend, release, or UI-handoff **defect**.

## Blocking Issues

1. **F05-QA-1** — AC12: the `Next Level` (`SONRAKİ`) tap → `pushReplacement` to N+1 / `context.go('/')` to terminal is untested (only `nextJourneyLevel` is).
2. **F05-QA-2** — the manifest gate's `mode:"strict"` failure path (`<30` / missing asset) is never executed.

## Suggested Fix Order

1. **Frontend/Mobile Developer** — add the AC12 navigation test(s): solve journey level N (2-level interim manifest) → tap `SONRAKİ` → assert N+1's `/play` via `pushReplacement` (no back-stack growth); last-available/30 → tap `SONRAKİ` → terminal/`/`.
2. **Frontend/Mobile Developer** — add a `mode:"strict"` gate unit test (`<30` levels → fails; missing asset → fails); band rules may stay a documented `[PENDING — F06-CONTENT]` stub.
3. (Optional, same turn) address N1 / N3 / N4 widget-coverage notes and decide N2 (breathing pulse / bloom) and N5 (locked-level guard) with Tech Lead.
4. **QA** — re-verify (focused: the two blocking items + no-regression).

---

## 18. Required Fixes

1. **F05-QA-1 — AC12 `Next Level` navigation coverage.** Add automated-functional evidence that tapping `SONRAKİ` on a real `/play` `CompletionPanel`:
   * for level N with N+1 present → lands on level N+1's `/play` via `pushReplacement` (back stack does not grow);
   * for the last available level (interim 5) / level 30 → routes to the terminal home (`context.go('/')`).
   Unit coverage of `nextJourneyLevel` alone does not satisfy AC12 or `architecture.md §15`.
2. **F05-QA-2 — strict-mode gate coverage.** Add a unit test feeding the gate a `mode:"strict"` manifest with `< 30` levels (and a missing/unresolvable asset) → asserts failure. The structural band rules may remain a `[PENDING — F06-CONTENT]` stub with an explicit in-file note.

---

## 19. Sonraki Komut

```
Run Tech Lead
```

---

## 20. Tech Lead Note

* **Verdict: Rejected — 2 blocking test-coverage gaps, both test-only, both small.** The F05-FE `lib/` implementation, the LOCKED `architecture.md`, and the `ui-design.md` handoff are all sound; no rework of the contract or the design is needed. Root cause = Frontend test coverage → **fix role: Frontend/Mobile Developer**.
* **F05-QA-1** is the material one: AC12 ("`Next Level` navigates to N+1 / terminal") is a headline acceptance criterion and a navigation flow, and its only evidence is a pure-function unit test — this trips the FAIL-FAST gate. **F05-QA-2** is a mandatory Mode/Configuration variant (`smoke` vs `strict`) with zero executed coverage on the `strict` side.
* **Non-blocking:** N2 (the in-progress breathing pulse + the terminal entry bloom from `ui-design.md §11` are not implemented — static treatments ship; state readability is intact and it matches `PlayStage`'s "ambient deferred for determinism" precedent) needs a Tech Lead call: accept the static treatment, or route a small motion follow-on to FE (could ride the same rework turn). N5 (no guard against direct entry to a locked `journeyLevel`) also wants a ruling — "unreachable by construction" is defensible (no deep links, home → `continueTarget` only), but a 2-line defensive `JourneyContentException` in the resolver would close it cheaply.
* **Unchanged F05 `Done` gate:** `F06-CONTENT` (the 30 authored levels + a `mode:"strict"` manifest) is still the hard prerequisite, and AC3/AC5/AC6 + the gate's structural band rules are deferred to it. F05-QA-2's fix (the bare `strict ⇒ 30` + missing-asset checks) is separable from that content work and should land now.
* **Gates that passed this turn** (carry forward on re-verify unless `lib/` changes): `flutter analyze` clean; `dart format --set-exit-if-changed` clean (app + packages + tools); `flutter test` 166/166 (132 baseline + 34 new, no regression to the F03 play / F04 completion suites); pure-package `dart test` all green; `flutter build ios --release --no-codesign` green; the smoke-mode content gate green; F04's debug-entry `CompletionPanel` disabled-`SONRAKİ` + `· yakında` assertions still green (the now-wired `onNextLevel` path did not break them). `flutter build appbundle --release` is CI-only (no local Android SDK) — unchanged from F03/F04.
* `orchestration.md` updated: F05-QA ledger item closed as Rejected; Blockers aligned; root cause recorded as Frontend test coverage. Global `feature-board.md` / `system-state.md` sync is Tech Lead's.
