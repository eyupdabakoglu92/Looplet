# F03 — puzzle-play-session: QA Report (re-verify after F03-FE9)

---

## 0a. Evidence Mode Declaration

* **Bash / build access:** VAR
* **e2e test suite** (Detox / Patrol / `integration_test` on a device): **KISMEN** — an `integration_test/play_session_test.dart` suite now exists (scenarios 1–4). It runs on a device via `flutter test integration_test -d <device>` (wired into CI as a best-effort `continue-on-error` step). A **headless** `flutter test integration_test/` run is slow + timing-sensitive for this app's drift-backed async boot and was not carried to completion in this environment; **no device / simulator session** is available here.
* **Screenshot / browser tool:** YOK
* **Runtime validation method:** **`automated functional` (strong)** — the F03-FE9 `test/play/play_session_runtime_test.dart` suite (13 `flutter_test` widget tests) drives real gestures through the full widget tree, pumps the real ~190 ms animation window, dispatches app-lifecycle transitions, and does a dispose + remount "kill/relaunch" on a shared in-memory DB — directly targeting `qa.md §17` scenarios **1–4**. Plus **build gates**. The `repeatable integration` form (the `integration_test/` suite) is delivered but its device-matrix run is pending a device. `qa.md §17` scenarios **5–7** are pure visual / OS confirmations that still need a device pass.

Consequence: the runtime scenarios that were `Runtime Validation Pending` at the prior verdict are now **closed to the automatable slice (1–4)**; the residual is a **3-item manual device confirmation (5–7)**, carried as Notes for the Tech Lead to accept the deferral at close-out (per the Tech Lead's Next-Action brief and `architecture.md §18 → [RUNTIME VALIDATION PENDING — F03-FE9]`).

---

## 0. Backend Build Gate

F03 touches **no backend** (`Release Scope = none`). The client build/test gate (canonical `melos` scripts) was re-run in full:

| Gate | Command | Result |
| --- | --- | --- |
| Format | `dart format --output=none --set-exit-if-changed .` | **PASS** — 123 files, 0 changed |
| Analyze (app, incl. `integration_test/`) | `flutter analyze` | **PASS** — No issues found |
| Analyze (pure packages) | `dart analyze .` ×6 | **PASS** — 5 clean; `looplet_solver` has **1 pre-existing `info`** (`solver.dart:56`, not F03, `dart analyze` exits 0, package tests pass) — noted in the Tech Lead Note |
| Unit + widget tests | `dart test` (6 packages) + `flutter test` (app) | **PASS — 308 / 308** (core 22, dictionary 32, engine 83, content 17, solver 23, authoring 19, **app 112** = 4 pre-existing + 68 F08 + 27 F03 + **13 new F03-FE9**) |
| Integration tests | `flutter test integration_test/` (best-effort, `continue-on-error` in CI) | **PENDING (device)** — analyze-clean; headless run slow/timing-sensitive, not completed here; authoritative run is `flutter test integration_test -d <emulator>` |
| iOS release build | `flutter build ios --release --no-codesign` | **PASS** — `✓ Built build/ios/iphoneos/Runner.app (54.5MB)` |
| Android App Bundle | `flutter build appbundle --release` | **NOT RUN** — CI-only locally (no Android SDK; established posture) |

* **Gate decision: PASS → QA continues.** No product-code changed since the prior verdict; F03-FE9 is additive test infrastructure + CI wiring only.

---

## 1. Feature Summary

* **Feature under test:** F03 puzzle-play-session — the playable screen (swipe → one-cell wrap shift; always-visible outline-ghost target; live `MOVES` HUD; 3-action Undo; separated Restart; bounded win → minimal completion sheet; exact resume via the F08 snapshot).
* **QA scope:** end-to-end **client** QA + `ui-design.md` handoff compliance + navigation/chrome consistency. **This pass is a re-verify** after F03-FE9 (the runtime-validation closure) and the Tech Lead's resolution of the 6 open clarifications.

---

## 2. Test Scope

* **Scope Type:** **Client Only** + **UI Handoff Compliance** + **Runtime Validation** (`architecture.md §16`) — now closed to the automatable slice via F03-FE9; 3 manual device items remain.
* **Documents reviewed (this pass):** `qa.md` (prior verdict), `frontend.md` (incl. the new **"F03-FE9"** section), `architecture.md` (incl. **§18 "Clarifications resolved 2026-09-06"** + the `[RUNTIME VALIDATION PENDING — F03-FE9]` item), `orchestration.md` (Last Decision v6 + the Tech Lead reconciliation + the Next-Action brief), `prd.md §3/§7`, `ui-design.md §11/§12/§14`, `design/design-doctrine.md`, `design/premium-ui-rubric.md`, `project-authority/release.md §2/§4`. `analysis.md` N/A.
* **Delta re-verified:** `app/test/play/play_session_runtime_test.dart` (new, 13 tests), `app/integration_test/play_session_test.dart` (new), `.github/workflows/ci.yml` (best-effort `integration` step), `melos.yaml` (`test:integration`). The full prior F03 surface (`app/lib/play/**`, `app_router.dart`, `home_screen.dart`, `main.dart`) is unchanged — the prior verdict's contract + `ui-design.md` + security + regression findings still stand and are re-confirmed below by reference.
* **Out of scope:** **Security compliance — out of scope:** pure client UI, single actor, no auth, no cross-user resources, no endpoint; the only persistence is the local single-row `kv['active_session']` snapshot owned by F08. **Release compliance — out of scope:** `Release Scope = none` (the new best-effort CI `integration` step is a CI gate, not a deployment; verified below in §6.7). **iOS platform compliance — out of scope:** Flutter (not Unity), no `game-dev.md`, no new tracking SDK / IAP / privacy-manifest change. **Backend quality / 13 — out of scope:** no backend. **Mode/Configuration matrix — out of scope:** one actor, one mode; puzzle-config variants covered in §5.
* **Bugfix?** No. F03-FE9 is additive test infrastructure for a `Runtime Validation Pending` closure.
* **Critical user journeys:** open → orient; swipe → one-cell shift + `MOVES +1`; sub-threshold → nothing; swipe during animation → dropped, not queued, no double-count; 3 undos then a 4th → no-op, no prompt; Restart → reset, no dialog; form target → lock + win highlight + seam bar + bounded anim + sheet; Retry → reset in place; leave mid-puzzle → exact resume (dispose/remount + OS kill). **Forbidden / misuse:** input during `animating`/`won`; Undo at 0; engine-rejected move; multi-touch; off-screen release; rotation; corrupt / mismatched / tampered snapshot; direct entry with an empty stack.
* **Navigation / header consistency:** `/play` has no system header (contract §13, Tech-Lead-confirmed `[LOCKED]` in §18); the quiet back chevron pops to the caller and is hidden in `won`; F03 is the first in-flow screen (the cross-screen chrome family rule is deferred to F10 per §18) — sibling-source comparison N/A.
* **Evidence class summary:** `automated functional` (308 workspace tests, incl. 27 F03 + 13 F03-FE9) + `build` (analyze / format / iOS release) + a delivered-but-device-pending `integration_test/` suite. **Manual device confirmation of `qa.md §17` 5–7 not performed** (no device).
* **Runtime validation method:** `automated functional` (strong) + build; `integration_test/` scaffold delivered, device run pending.

---

## 3. Product Behavior Coverage

| User Story (`prd.md §2`) | Test scenario | Evidence | Result |
| --- | --- | --- | --- |
| "swipe a row/column and watch it slide one cell" | row-0 right swipe on `smoke-tr-01` at 2 surface sizes → `rowRight(0)` → engine → win sheet; a legal non-winning move → `MOVES` +1 | `play_session_runtime_test.dart` §17.1 ×6; `play_session_controller_test.dart` | **PASS** — device slide *feel*: a Note item |
| "target word always visible and clearly separated from the grid" | `HEDEF` + 5 outline-ghost tiles above a `_DividerGlow` + `zoneGap`; unchanged since the prior verdict | `play_session_screen_test.dart` + source | **PASS** |
| "live MOVES counter" | `MOVES` = `engine.moveCount`, settled-only; ticks 0→1→2→3 across the F03-FE9 flows; restored after a kill/relaunch | `play_session_runtime_test.dart` §17.2/§17.3; `play_session_controller_test.dart` | **PASS** |
| "up to 3 undos and a restart to recover" | 3 undos → quota 0 → 4th is a no-op; Restart → `MOVES` 0, quota 3, `restartCount++` (persisted across a kill/relaunch) | `play_session_controller_test.dart`; `play_session_runtime_test.dart` §17.3 (Restart persists) | **PASS** |
| "accidental taps and tiny drags ignored" | a `(6,4)` sub-threshold drag at 2 surface sizes → `MOVES` 0, no sheet | `play_session_runtime_test.dart` §17.1 ×2; `gesture_resolver_test.dart` | **PASS** — real-touchscreen threshold accuracy: a Note item |
| "leave mid-puzzle and come back exactly where I was" | 3 moves → dispose (`pumpWidget(SizedBox)`) → remount on the same DB → `MOVES` 3; repo-seeded `['R1']` snapshot → hydrates to `MOVES` 1; `paused` mid-animation → committed + survives a kill/relaunch | `play_session_runtime_test.dart` §17.3 ×3, §17.4 | **PASS** — real OS-kill on hardware: a Note item |

**No user story is uncovered.** The device-`runtime` facets are now down to 3 explicitly-scoped visual/OS confirmations (Notes), not logic gaps.

---

## 4. Acceptance Criteria Traceability

| AC (`prd.md §3`) | Scenario + evidence (this pass) | Result |
| --- | --- | --- |
| **AC1** open → target + grid + `MOVES: 0` + Undo(3) + Restart; target separated | `play_session_screen_test.dart` "renders …"; `play_session_runtime_test.dart` §17.1 (`_moves == 0` at boot) | **PASS** |
| **AC2** horizontal swipe past threshold → that row shifts one cell in the swipe direction + `MOVES +1` | `play_session_runtime_test.dart` §17.1 (row-0 right → `MASAL` forms) at `360×780` **and** `430×932`; `gesture_resolver_test.dart` | **PASS** |
| **AC3** vertical swipe past threshold → that column shifts one cell + `MOVES +1` | `gesture_resolver_test.dart` (+dy → `columnDown`, −dy → `columnUp`); engine enforces on column-enabled puzzles; F03-FE9 §17.1 rejected-column case proves the wiring on a no-column puzzle | **PASS (automated)** — a real vertical swipe on a column-enabled puzzle on hardware: a Note item |
| **AC4** swipe below threshold → no shift, `MOVES` unchanged | `play_session_runtime_test.dart` §17.1 `(6,4)` at 2 sizes; `gesture_resolver_test.dart` (below-threshold → `null`) | **PASS** |
| **AC5** animation in progress → another swipe **ignored and not queued** | `play_session_runtime_test.dart` §17.2 — a second `dragFrom` fired 60 ms into the shift → `MOVES` ticks **once**; rapid same-row swipes → each counts only post-settle → `MOVES == 2`. **This directly proves the `prd.md §7` "0 double-registered moves during animation in QA" metric.** | **PASS** |
| **AC6** all 3 undos used → Undo again → nothing, no prompt/ad | `play_session_controller_test.dart` (`undo()` → `false` at quota 0); source (`UndoButton` `onTap: active ? … : null`, no dialog/ad code) | **PASS** |
| **AC7** Restart → grid reset, `MOVES = 0`, undos → 3, **no confirm dialog**; away from the grid | `play_session_runtime_test.dart` §17.3 (Restart → `MOVES` 0, persisted across a kill/relaunch); `play_session_controller_test.dart`; source (`RestartButton` no `showDialog`; `_HudBar` layout) | **PASS** |
| **AC8** target forms on settle → input locks, winning row highlights, short success anim, completion panel opens | `play_session_screen_test.dart` + `play_session_runtime_test.dart` §17.1 (win → `CompletionSheet` + `ÇÖZÜLDÜ`) | **PASS (automated)** — the seam-bar draw / bloom timing *look*: a Note item (§17.5) |
| **AC9** swipe begins → affected row/column receives a light highlight | source (`updateDrag` → `_activeLine` → the moving-line lift + `_buildRails` + 8 % dim); `gesture_resolver_test.dart` `trackingAxis` | **PASS (source + automated for the axis logic)** — visual highlight on a device: a Note item |
| **AC10** leave + return → grid, `MOVES`, undos, restart count, elapsed restored | `play_session_runtime_test.dart` §17.3 (dispose+remount → `MOVES` 3; seeded `['R1']` → `MOVES` 1; **tampered `thawedFrozenCells: ['2,2']` on `smoke-tr-06` → the tile renders `TileStatus.frozen`, not `thawed`** — the cache is re-derived by replay, not trusted); §17.4 (`paused` mid-animation → committed + survives a kill/relaunch) | **PASS** — real OS-kill on hardware: a Note item |
| **AC11** transient target-word mid-animation → no win; win on settled state only | source — the engine sets `solvedThisStep` from the **settled** next-state; the controller checks it only in `commitShift()` (post-animation); `looplet_engine` 83 tests | **PASS (source + engine tests)** |

**Every AC has ≥ 1 automated scenario, most now runtime-adjacent via F03-FE9.** The remaining device confirmations are visual/OS, listed in the Notes.

---

## 5. Boundary Matrix

Re-confirmed from the prior verdict; the F03-FE9 rows are now **automated**, not source-only:

| Boundary / transition | Result | Evidence (this pass) |
| --- | --- | --- |
| `idle → tracking → idle` (below threshold) | **PASS** | `play_session_runtime_test.dart` §17.1 `(6,4)` |
| `idle → tracking → animatingShift → idle` (legal, no win) | **PASS** | §17.2 (row 1 shift); `play_session_controller_test.dart` |
| `idle → tracking → animatingShift → won` (legal, win) | **PASS** | §17.1 (row-0 right → sheet) |
| `idle → tracking → animatingBounce → idle` (rejected move) | **PASS** | §17.1 (vertical drag on a no-column puzzle → `MOVES` unchanged) |
| `animatingShift` + a new pointer | **PASS — automated** | §17.2 (a second drag 60 ms in → dropped, `MOVES` ticks once) |
| `won` + a pointer / Undo / Restart | **PASS** | prior verdict + `canRestart`/`canUndo` false; `_TopBar` hides the chevron |
| Undo 3→2→1→0 | **PASS** | `play_session_controller_test.dart` |
| `restart()` from `idle` (persisted) | **PASS — automated** | §17.3 (Restart → `MOVES` 0 → kill/relaunch → still 0) |
| `retryFromCompletion()` from `won` | **PASS** | `play_session_screen_test.dart` "Retry … resets" |
| Config: `columnMovesEnabled == false` / `== true` | **PASS** | §17.1 (rejected column) + `gesture_resolver` |
| Config: locked pivot (`smoke-tr-05`) | **PASS (source)** — visual on device: Note §17.5 | `board_tile.dart` locked branch + F02 tests |
| Config: frozen tile (`smoke-tr-06`) | **PASS — automated (status)** | §17.3 tampered-cache test asserts `TileStatus.frozen` renders; visual + thaw cross-fade: Note §17.5 |
| App `paused` during `tracking` | **PASS — automated** | §17.4 (gesture cancelled, `MOVES` 0) |
| App `paused` during `animatingShift` | **PASS — automated** | §17.4 (move committed settled, survives kill/relaunch) |
| Open with a matching `puzzleId` snapshot | **PASS — automated** | §17.3 (seeded `['R1']` → `MOVES` 1) |
| Open with a mismatched / corrupt / tampered snapshot | **PASS** | tampered: §17.3; mismatched/corrupt: source + F08 QA |
| Direct entry to `/play` with an empty stack | **PASS (source)** — `_popToCaller` → `maybePop` | source; device edge-swipe back: Note §17.7 |

No architecture-defined boundary lacks a scenario.

---

## 6. Contract Compliance Check

Re-confirmed against `architecture.md` (unchanged since the prior verdict; §18 gained the Tech-Lead clarifications, no behavioural change):

| Contract area | Status | Note |
| --- | --- | --- |
| Route / navigation (§13) + the `[LOCKED]` "no system header, quiet chevron, hidden in `won`" (§18) | **Preserved** | `play_session_screen_test.dart` (chevron hidden in `won`, restored after Retry) |
| Screen state machine (§6) + **no input queue** | **Preserved** | `play_session_runtime_test.dart` §17.2 + `play_session_controller_test.dart` |
| Gesture → Move mapping (§7) — threshold, dominant axis, **tie-band → horizontal**, one cell, first pointer | **Preserved** | `gesture_resolver_test.dart` (13) + §17.1 at 2 sizes |
| MOVES / Undo / Restart (§8) — settled-only, no prompt/ad at 0, no dialog, separated | **Preserved** | §17.2/§17.3 + `play_session_controller_test.dart` + source |
| Persistence integration (§9) — F08-frozen keys, hydrate via restore path, `completed` + `clear()`, no F03 background work | **Preserved** | §17.3 (dispose/remount + seeded snapshot + tampered cache) |
| Completion sequence (§10) — lock → win-row highlight + **drawn seam bar (colour + shape)** → bounded ≤ 600 ms → minimal panel (no rating logic — F04 seam) | **Preserved** | §17.1 (sheet appears) + source; the *visual* readability is Note §17.5 |
| Animation / input-lock (§11) — 190 ms shift, diegetic lock (HUD dim, not a spinner), no queue, transient-word-mid-animation ≠ win | **Preserved** | §17.2 (window behaviour) + source |
| Backgrounding (§12) — gesture cancelled on `paused`; mid-shift commits synchronously; snapshot always settled | **Preserved** | §17.4 |
| Localization (§14) + the `PlayStrings` seam accepted in §18 | **Preserved** | `PlayStrings` per-language table; no hard-coded display string |
| `Release Scope` (§17) = `none` | **Preserved** | only test/CI files added; `pubspec.yaml` unchanged; iOS build green with no new pods |
| §18 clarifications applied | **Confirmed** | no playing-screen CTA (correct); F03 tile visuals present; `/play` chrome as specced; `PlayStrings` seam; perf deviations (recede blur → dim-only; breathing omitted) present and acceptable — no rubric fail |
| Contract version / breaking change | **No breaking change** | no `looplet_*` package changed; F02 83 + F08 68 + prior F03 27 tests unchanged and green |

**No contract violation.**

---

## 6.7 Release / CI-CD Compliance Check

F03 `Release Scope = none` — no deployment. This section is limited to the **new CI wiring** F03-FE9 added:

| Control | Result | Evidence / Notes |
| --- | --- | --- |
| CI gate policy for the new integration step | **PASS** | `.github/workflows/ci.yml` `verify` job — `Integration tests (play session — best-effort)` with `continue-on-error: true`; `release.md §4` explicitly permits `integration_test` as a **best-effort** gate ("failure is investigated, not auto-blocking until F03 lands"). It does not block the pipeline. |
| The best-effort step's failure mode | **PASS** | `continue-on-error: true` → a slow/partial headless run does not fail CI; the authoritative automated gate is `play_session_runtime_test.dart` inside `melos run test` (always-green). |
| `melos.yaml` `test:integration` | **PASS** | added, mirrors the CI command |
| No deploy / secret / env / container change | **PASS (N/A confirmed)** | F03 adds none; `Release Scope = none` unchanged |

No release/deployment blocker. The `integration_test/` device-matrix run is a Note (below), not a gate.

---

## 7. UI Design Compliance Check

Unchanged since the prior verdict (implementation not modified). Re-confirmed against `ui-design.md` + the §18 clarifications:

* **Screen goal / UX flow / visual hierarchy / layout / component blueprint / state design / motion intent / chrome / background-colour-type-surface / premium differentiators** — all met (see the prior verdict §7 — Direction A fully implemented; spotlight stage, backlit tiles, loop-rail + wrap animation, outline-ghost target, diegetic input-lock, amber-fill + drawn seam bar, undo pips, separated outline Restart, minimal-but-crafted sheet).
* **Accepted perf deviations** (now Tech-Lead-ratified in `architecture.md §18`): board-recede blur → dim-only (0.12); breathing spotlight ambient omitted. **No `premium-ui-rubric.md` fail condition; no `design-doctrine.md §8` anti-pattern.** Rubric ≥ 90 (design self-review 94; the two deviations stay above the threshold).
* **Runtime visual confirmation** (win choreography, tile-state visuals, rail highlight, seam-bar greyscale legibility) — a Note item (§17.5); no logic risk (the state transitions driving them are automated-covered).

**No UI Design Mismatch finding.**

---

## 9. Positive Scenarios

**Journey 1 — solve at 2 screen sizes (AC2/AC8, `prd.md §7` gesture accuracy).**
Start: `smoke-tr-01` open on a `360×780` **and** a `430×932` surface. Action: swipe row 0 right past the threshold. Visible result: the row slides exactly one cell (M wraps in from the left), settling to `M A S A L`; input locks; the winning row fills amber and the seam bar draws; the completion sheet rises. Evidence: `play_session_runtime_test.dart` §17.1 ×2 sizes.

**Journey 2 — no double move during the real animation window (AC5, `prd.md §7` "0 double-registered moves").**
Start: `smoke-tr-02`, a legal non-winning move started on row 1. Action: 60 ms into the ~190 ms shift, a second drag on the same row. Visible result: `MOVES` shows `1`, not `2` — the second gesture is dropped, not queued. Two settled swipes → `MOVES 2`. Evidence: `play_session_runtime_test.dart` §17.2 ×2.

**Journey 3 — kill and resume (AC10).**
Start: `smoke-tr-02`, 3 moves applied. Action: the widget tree is disposed (`pumpWidget(SizedBox)`), then remounted against the same in-memory DB. Visible result: `MOVES` shows `3`; then Restart → `MOVES 0` → dispose + remount → still `0`. A repo-seeded `['R1']` / quota 2 / restarts 1 snapshot → the screen hydrates to `MOVES 1`. Evidence: `play_session_runtime_test.dart` §17.3 ×3.

**Journey 4 — tampered thaw cache is not trusted (AC10, security-of-restore).**
Start: a repo-seeded `smoke-tr-06` snapshot with no moves but a bogus `thawedFrozenCells: ['2,2']`. Action: open the puzzle. Visible result: the tile at 2,2 renders **frozen** (frost + crystal border), not thawed — the engine re-derived thaw by replaying the (empty) move list, ignoring the cache. Evidence: `play_session_runtime_test.dart` §17.3.

**Journey 5 — backgrounding mid-swipe / mid-animation (AC10, `architecture.md §12`).**
Start: `smoke-tr-02`. Action: `handleAppLifecycleStateChanged(paused)` while a pointer is held mid-drag → the gesture is cancelled, `MOVES 0`, no exception. Separately: `paused` fired 50 ms into a shift → the move commits settled (`MOVES 1`) and survives a subsequent kill/relaunch. Evidence: `play_session_runtime_test.dart` §17.4 ×2.

---

## 10. Negative / Edge Cases

Re-confirmed from the prior verdict; F03-FE9 upgrades several from source-only to automated:

| Case | Result | Evidence |
| --- | --- | --- |
| Input while `phase == animatingShift` | **PASS — automated** | §17.2 (second drag dropped, `MOVES` ticks once) |
| Input while `phase == won` | **PASS** | `inputLocked` true; `_TopBar` hides the chevron; prior verdict |
| Undo with no history / during `won` | **PASS** | `canUndo` guard |
| A rejected engine move (column disabled) | **PASS — automated** | §17.1 (vertical drag on `smoke-tr-01` → bounce, `MOVES` unchanged, no error) |
| Multi-touch / two-finger | **PASS (framework)** | `GestureDetector` pan is single-pointer |
| Swipe ending off-screen | **PASS (source)** — `_onPanEnd`/`_onPanCancel` both `_release(_dragOffset)` | source — on-device: Note §17.7 |
| Fast flick vs slow drag | **PASS** | `gesture_resolver_test.dart` "one cell only" |
| Diagonal near-tie → horizontal | **PASS** | `gesture_resolver_test.dart` |
| Device-rotation attempt | **PASS (source)** — `main()` portrait lock | Note §17.6 |
| Restart during an animation | **PASS** | `canRestart` requires `idle` |
| Corrupt `active_session` on open | **PASS** | F08 `read()` catch → `null`; source |
| Mismatched-`puzzleId` snapshot | **PASS** | `_tryRestore` guard; source |
| **Tampered `thawedFrozenCells`** | **PASS — automated** | §17.3 (renders `frozen`, not `thawed`) |
| `restoreSession` throws (dict drift) | **PASS (source + F08)** | `_tryRestore` catches `SessionRestoreException` → fresh |
| App `paused` mid-drag / mid-animation | **PASS — automated** | §17.4 |
| Direct entry with an empty stack | **PASS (source)** — `maybePop` fallback | source |
| Unsupported `source` (`daily` pre-F07) | **PASS** | `play_session_screen_test.dart` "load-error state" |
| Storage full / disk write failure during persist | **PASS (source)** — `_persist` try/catch → `debugPrint('persist_failed …')`, keep playing | source — **no automated fault-injection (residual test-debt, shared with F08 AC7)** — Note |

No misuse path produced a crash, a lost/duplicated move, a wrong `MOVES`, or an unauthorized action.

---

## 12. UX & State Handling

Unchanged since the prior verdict (implementation not modified). Loading (skeleton, no spinner) / Error (contained dev-only body) / Success (bounded win sequence) / Disabled (Undo-at-0 inert, HUD dim during lock) / Pressed (0.97 tile) / Focused (`Semantics(button:, label:)`) — all present. No CTA on the playing screen (correct, `[LOCKED]` in §18); the single CTA `Retry` dominates the sheet. **Runtime evidence summary:** `automated functional` (308 workspace tests, incl. 13 F03-FE9 directly exercising the runtime scenarios) + build; the seam-bar/tile visuals and portrait/back OS behaviour are the 3 Note items.

---

## 14. Frontend Quality

* **F03-FE9 code quality:** `flutter analyze` clean incl. `integration_test/`; `dart format --set-exit-if-changed` clean. The two suites are well-structured (a shared `_app` / `_rowStart` / `_moves` helper set; per-test fresh in-memory DB; explicit dispose via `pumpWidget(SizedBox)` for the kill/relaunch). The `test/play/play_session_runtime_test.dart` mirror is the pragmatic, reliable form; the `integration_test/` suite is the device-matrix form with an honest header comment explaining the headless limitation.
* **CI wiring:** the best-effort `continue-on-error` step is the correct choice for `integration_test` per `release.md §4` — it surfaces the device suite without making a slow/flaky headless run block the pipeline; the real gate is the always-green mirror in `melos run test`.
* **No product-code regression:** the 4 pre-existing app tests + 68 F08 + 27 prior-F03 unchanged and green; 196 package tests unchanged; iOS release build unaffected.
* **Runtime evidence summary:** `automated functional` (strong — the 13 F03-FE9 tests directly target `qa.md §17` 1–4 with real gestures + animation-window + lifecycle + dispose/remount) + build; device-matrix + the 3 visual/OS items pending a device.

---

## 15. UI Handoff Alignment

Unchanged since the prior verdict — Direction A fully implemented and holding the ~94/100 bar; the 2 perf deviations are now Tech-Lead-ratified in `architecture.md §18`; no unacceptable UX/visual deviation. The seam-bar greyscale legibility + tile-state visuals + thaw cross-fade are the Note §17.5 device confirmation (no rubric fail; the state logic is automated-covered).

---

## 16. Regression Risk

* **Files changed since the prior verdict:** `app/test/play/play_session_runtime_test.dart` (new), `app/integration_test/**` (new), `.github/workflows/ci.yml` (a best-effort step), `melos.yaml` (a script), `ai-system/**` docs. **No `app/lib/**` change, no `pubspec.yaml` change, no package change.**
* **Impact:** none on runtime behaviour — additive test + CI config only. The best-effort CI step is `continue-on-error`, so it cannot break `main`.
* **Downstream dependents** (F04/F05/F07/F09/F10/F11/F12) — unaffected; they build against the unchanged F03 contract.
* **Risk: negligible.** The prior verdict's "low regression risk" (only `main.dart` was the shared-file change, and that's now several turns stable + covered) stands.

---

## 17. Final Verdict

### **Approved with Notes**

* **No blocking issue. No required fix.** All build + automated gates are green: **308 / 308** workspace tests (13 new F03-FE9 directly exercising `qa.md §17` scenarios 1–4 with real gestures, the real ~190 ms animation window, app-lifecycle dispatch, and a dispose+remount kill/relaunch), `flutter analyze` (app incl. `integration_test/`) + `dart analyze` (6 packages) + `dart format --set-exit-if-changed` clean, `flutter build ios --release --no-codesign` green. The full `architecture.md` contract (incl. the §18 clarifications) is honoured, all 11 ACs have automated scenarios, `ui-design.md` Direction A holds the ~94/100 bar with no rubric fail / no doctrine anti-pattern, security is legitimately out of scope, `Release Scope = none` and the new best-effort CI `integration` step complies with `release.md §4`, and regression risk is negligible.
* **Why `Approved with Notes` (not `Approved`):** `architecture.md §16` names `runtime` (device/simulator) evidence as mandatory, and `architecture.md §18 → [RUNTIME VALIDATION PENDING — F03-FE9]` defines the closure as the `integration_test/` suite **plus** a manual device/simulator confirmation of the visual/OS items (`qa.md §17` 5–7). The automatable slice (1–4) is now **closed** by the F03-FE9 `play_session_runtime_test.dart` suite — including the headline `prd.md §7` "0 double-registered moves during animation in QA" metric. The residual is a **3-item manual device confirmation** that this environment cannot produce (no device); per the Tech Lead's Next-Action brief, these are carried as Notes for the Tech Lead to accept the deferral at close-out.
* **Why not `Runtime Validation Pending`:** the prior verdict's gap — *no* automated runtime coverage and *no* `integration_test` suite — is resolved. Repeatable automation now directly targets the runtime scenarios; the residual is explicitly-scoped, low-risk visual/OS confirmation, not an unproven critical journey. Per the QA `Approved with Notes` rule and the Tech Lead's pre-authorization, this is the correct verdict.

**Notes (all non-blocking; the Tech Lead accepts the deferral at close-out):**

1. **Manual device / simulator confirmation of `qa.md §17` scenarios 5–7** — not producible in the QA env (no device). Recommend a quick device pass **or** folding into the first app-build distribution smoke (~F05):
   * **5** — win choreography reads as "earned" not a wait; the drawn L→R **amber seam bar is legible with colour OFF / in greyscale** (accessibility); `smoke-tr-05` locked pivot renders the brass ring + pin glyph and never moves while its row rotates; `smoke-tr-06` frozen tile renders the frost fill + crystal border and plays the thaw cross-fade when its row forms a valid word.
   * **6** — a device rotation attempt leaves the layout unchanged (portrait lock).
   * **7** — the quiet back chevron pops to the caller via the button, the system back, **and the edge-swipe gesture**; hidden in `won`; a direct entry to `/play` falls back safely.
2. **`integration_test/play_session_test.dart` device-matrix run** — the durable `repeatable integration` form; run `flutter test integration_test -d <emulator>` when a device/emulator is available (the CI step is best-effort `continue-on-error`; headless is slow/timing-sensitive for the drift-backed boot). Not a gate.
3. **Residual test-debt (shared with F08 AC7):** no automated storage-full / disk-write-failure fault-injection test for the persist path. The mechanism (try/catch around the Drift upsert + keep-playing-from-memory) is source-sound. Add in a follow-up.
4. **`looplet_solver/lib/src/solver.dart:56`** — one pre-existing `info`-level analyzer lint (`curly_braces_in_flow_control_structures`) from an earlier session. Not F03; `dart analyze` exits 0; package tests pass. Optional cleanup on the next F06 touch.
5. **Tech Lead's §18 clarifications** — QA confirms the implementation matches all six resolutions (no playing-screen CTA is intentional and correct; first-pass locked/frozen tile visuals are present; `/play` chrome is as specced with the family rule deferred to F10; `PlayStrings` is an acceptable localization seam pending a `gen_l10n` follow-on; the two perf deviations are present and do not drop the screen below the premium bar).

---

# WORKFLOW VERDICT SUGGESTION (NON-AUTHORITATIVE)

## QA Result

* **Approved with Notes** — implementation contract-compliant and `ui-design.md`-aligned; all build + automated gates green; the F03-FE9 suites close the automatable slice of `qa.md §17` (scenarios 1–4, incl. the `prd.md §7` "0 double-registered moves" metric). Residual: a 3-item manual device confirmation (`qa.md §17` 5–7) + 2 non-blocking follow-ups, carried as Notes.

## Affected Areas

* None requiring code rework. The residual is a device confirmation the environment cannot perform.

## Blocking Issues

* None.

## Suggested Fix Order

Not a rework. Tech Lead close-out:
1. Accept the 3-item manual device deferral (Notes 1) — record the acceptance; recommend the F05 app-distribution smoke as the home for it, or a quick standalone device pass.
2. Record Notes 2–4 in the change log / follow-on tracking.
3. Mark F03 `Done` (per DURUM 5 `Approved with Notes` — notes are non-blocking) and sync `feature-board.md` + `system-state.md`.

---

## 19. Sonraki Komut

```
Run Tech Lead
```

---

## 20. Tech Lead Note

<<<TEXT

F03 puzzle-play-session — re-verify after F03-FE9. Verdict: **Approved with Notes**. No blocking issue, no required fix.

WHAT CHANGED SINCE THE PRIOR VERDICT (`Runtime Validation Pending`): F03-FE9 added `app/test/play/play_session_runtime_test.dart` (13 flutter_test widget tests — the fast, always-green runtime closure in `melos run test`) + `app/integration_test/play_session_test.dart` (device-matrix form, best-effort `continue-on-error` CI step per release.md §4) + a `melos.yaml` `test:integration` script. No product-code change. The 13 tests directly target qa.md §17 scenarios 1–4 with real gestures, the real ~190 ms animation window (a second drag 60ms in → MOVES ticks ONCE — this is the prd.md §7 "0 double-registered moves during animation in QA" metric, now automated-proven), app-lifecycle dispatch, a dispose+remount kill/relaunch on a shared in-memory DB, and a tampered `thawedFrozenCells: ['2,2']` snapshot on smoke-tr-06 → the tile renders TileStatus.frozen not thawed (cache re-derived, not trusted).

GATES: 308/308 workspace tests (app 112 = 99 + 13 F03-FE9); flutter analyze (incl. integration_test/) + dart analyze (6 pkg) + dart format --set-exit-if-changed clean; flutter build ios --release --no-codesign GREEN (54.5MB). Full architecture.md contract + the §18 clarifications honoured; all 11 ACs automated-covered; ui-design.md Direction A ~94/100, no rubric fail; regression risk negligible (only test + CI-config files changed).

WHY "APPROVED WITH NOTES" (not Approved): architecture.md §16 names device/simulator `runtime` evidence mandatory, and §18 → [RUNTIME VALIDATION PENDING — F03-FE9] defines the closure as the integration_test/ suite PLUS a manual device confirmation of the visual/OS items (qa.md §17 5–7). The automatable slice (1–4) is now closed; the residual is a 3-item manual device confirmation the QA env cannot produce. Per your Next-Action brief ("automatable slice green AND manual items explicitly deferred with the Tech Lead's acceptance → Approved / Approved with Notes"), this is the verdict.

CLOSE-OUT ACTIONS FOR YOU:
1. Accept the 3-item manual device deferral (Notes 1): (5) win-choreography readability + the amber seam bar legible in GREYSCALE (accessibility) + smoke-tr-05 locked pin/ring + smoke-tr-06 frost/crystal + thaw cross-fade; (6) portrait lock survives a rotation attempt; (7) chevron/back on button + system + EDGE-SWIPE, hidden in `won`. Recommend folding into the first app-build distribution smoke (~F05) or a quick standalone device pass. Record the acceptance.
2. Notes 2–4 to the change log / follow-on tracking: the integration_test/ device-matrix run (`flutter test integration_test -d <emulator>`); the residual storage-full fault-injection test-debt (shared with F08 AC7); the pre-existing looplet_solver:56 info lint (not F03).
3. Per DURUM 5 `Approved with Notes` (notes non-blocking): mark F03 `Done`, record the notes, sync feature-board.md + system-state.md. F03's critical-path successors (F04 completion panel, F05 Journey) can then activate. F08 stays In Release / parked (unchanged).
TEXT
