# F03 — puzzle-play-session: QA Report

QA run: 2026-09-20 · Task: F03-QA-RUNTIME · QA Stage: final · QA Scope: client-only · Release Scope: none
Verified revision: `7a907dd` (working tree clean; app/, packages/, content/, tools/ byte-identical to `ac7f74d`, which the first gates ran on — only `ai-system/` differs). This report replaces the 2026-09-06 report; that approval is NOT imported (its scope predates commit `e4311d3` — F04/F05 edits to `lib/play`).

---

## 0a. Evidence Mode Declaration

* Bash / build access: **VAR**
* e2e / device test suite: **VAR** — `flutter test integration_test/play_session_test.dart -d D0011CE7-6E50-4367-93FA-B323E81270BE` (iPhone 16 simulator, iOS 18.6)
* Screenshot / device tool: **VAR** — iOS Simulator control (screenshot, tap, swipe, touch_path, touch2_path, HOME button); `simctl io recordVideo` + a Swift/AVFoundation frame-sheet tool for timing evidence
* Runtime validation method: **`runtime` (simulator: iPhone 16 393×852, iPhone 16e 390×844, iPhone 16 Pro Max 440×956, debug build, real `main.dart` root and real on-disk Drift store)** + `repeatable integration` (integration_test on simulator) + `automated functional`
* Not producible with the available tooling (declared): device **rotation** (Simulator menu automation denied: assistive access −1719), a **HOME/lifecycle event while a touch is held or mid-animation** (cannot interleave two tool calls), physical-finger touch (simulator pointer is synthetic), OS Grayscale colour filter (frame luminance conversion used instead).

---

## 0b. Evidence Ledger

| Claim / Scenario | Evidence Class | Command / Action | Target / Environment | Result / Exit | Provenance | Isolation / Overrides |
| --- | --- | --- | --- | --- | --- | --- |
| Static analysis, all packages + app | static / build | `melos run analyze` | workspace | **PASS**, exit 0 | run 2026-09-20 19:2x, tree = `ac7f74d` code | none |
| Format | static | `melos run format:check` | workspace | **PASS**, exit 0 | same | none |
| Unit + widget suites | automated functional | `melos run test` | 6 packages + app | **PASS**, exit 0: content 17, core 22, dictionary 32, authoring 20, engine 83, solver 23 (=197) + app 181 = **378 passed, 0 failed; no skips reported** | same | widget tests use in-memory DB + provider overrides (not production root) |
| Debug simulator build of current tree | build | `flutter build ios --debug --simulator` | app | **PASS**, exit 0 (53.1 s) | 2026-09-20 | build ≠ boot; boot evidenced separately below |
| integration_test device-form suite | repeatable integration | `flutter test integration_test/play_session_test.dart -d <iPhone 16>` | iPhone 16 sim | groups 1–3 **10/10 PASS**; group 4 test 1 (`paused mid-drag cancels the gesture`) **did not complete [E] after 16m46s**; `tearDownAll` did not complete; group 4 test 2 never ran; runner: "Some tests failed", wrapper exit 144 | log `scratchpad/integ_16.log`, 2026-09-20 | in-memory DB + `_bootTo` harness; NOT the production bootstrap graph |
| Cold boot with empty + existing persisted state, real root graph | runtime | `simctl install` fresh; `simctl terminate` + `simctl launch`; observe splash → home | iPhone 16 | **PASS** (home renders; no init error visible; existing snapshot present on 2nd boot) | 2026-09-20 | none (debug build) |
| AC1–AC9 interaction on the real app | runtime | see §4 | iPhone 16 (393), 16e (390), 16 Pro Max (440) | **PASS** except AC9 highlight (not observed) | 2026-09-20 | simulator pointer |
| AC10 exact resume after real OS kill (Journey via CONTINUE and debug entry) | runtime | play → `simctl terminate` → `simctl launch` → re-enter | iPhone 16 | **PASS** (grid, MOVES, undo pips restored) | 2026-09-20 | elapsed/restartCount not displayed → not runtime-verified |
| Tampered `thawedFrozenCells` re-derived on the real store | runtime | kill app; `sqlite3 … update kv` set `["2,2"]`; relaunch; open smoke-tr-06 | iPhone 16 Pro Max, `Documents/looplet.sqlite` | **PASS** (tile renders frozen) | 2026-09-20 | none |
| Background → foreground (HOME) at idle | runtime | HOME, relaunch to foreground | iPhone 16 | **PASS** (same PID 84575, state identical, still playable) | 2026-09-20 | not mid-drag / mid-animation |
| Portrait lock under rotation | runtime | — | — | **PENDING / NOT RUN** (tooling) | — | static only: `main()` `setPreferredOrientations([portraitUp])`; iPhone `Info.plist` still lists LandscapeLeft/Right, so the runtime call is the only guard |
| Paused mid-drag / mid-animation on device | runtime | — | — | **PENDING / NOT RUN** (tooling + suite group 4 hang) | widget mirror `play_session_runtime_test.dart` §17.4 passes (automated functional only) | — |
| Win choreography timing / occlusion | runtime + video | `recordVideo`, 40 ms frame sheet | iPhone 16, smoke-tr-06 and Journey L1 | **FAIL** — see F03-QA-01 | `scratchpad/win.mov`, `sheet1.png` | debug build |

---

## 1. Feature Summary

F03 is the playable screen: swipe → one-cell row/column shift, live MOVES, 3 Undo actions, separated Restart, input lock, win sequence, exact resume. This run is the final-stage runtime re-verification after F04 (real completion panel) and F05 (Journey entry, unlock, `_popToCaller`) modified the F03 win/exit/persist path.

## 2. Test Scope

* Scope Type: client-only, final stage. Reviewed: prd.md, architecture.md (§5–§18), ui-design.md (won/frozen/locked/tile states), F04 ui-design.md (panel geometry/sequence), orchestration.md brief, code (`play_session_screen.dart`, `play_session_controller.dart`, `puzzle_board.dart`, `play_theme.dart`, `home_screen.dart`, `app_router.dart`, `main.dart`), integration + runtime test files.
* Critical journeys: open → swipe → win → panel → Retry / Next / Close; back → resume; kill → relaunch → resume; Journey via CONTINUE incl. Next Level and exit. Misuse: sub-threshold, rejected move, undo exhaustion, restart, diagonal tie, multi-touch, release beyond board, slow drag, tampered thaw cache, stale snapshot from another puzzle, replaced-route exit.
* Navigation/chrome: chevron, iOS edge-swipe back, hidden chevron while won, replaced-route exit. Sibling comparison: home ↔ play chrome (no header on either; quiet chevron on `/play` only) — structural source comparison of `home_screen.dart` and `play_session_screen.dart`: no header divergence found.
* Out of scope (single-line reasons): Backend build gate / backend quality — no backend touched. Security compliance out of scope: no auth, no other-user data, no finance; local single-player state. Release compliance out of scope: Release Scope = none, no deploy/CI change (CI best-effort `integration` step unchanged). iOS/Unity game-client sections — client stack is Flutter. Mode/configuration matrix — screen-size variants folded into §4/§5 (390/393/440).
* Storage-full / write-failure injection is F08 AC7 (F08.STORAGE), explicitly not an F03 criterion; neither passed nor failed here.
* Evidence classes: runtime, repeatable integration, automated functional, static. Method: see 0a.

## 3. Product Behavior Coverage

| User story | Scenario | Evidence | Result |
| --- | --- | --- | --- |
| Swipe a row/column and watch it slide one cell | row swipe (393/390/440), column swipe smoke-tr-06, slow 50 pt drag | runtime | PASS |
| Target word always visible, separated | HEDEF rail + divider on all widths | runtime | PASS |
| Live MOVES | 0→1→… on each settled move; unchanged on reject/no-op | runtime | PASS |
| Up to 3 undos and a restart | pips 3→0, 4th tap inert, Restart resets to 3 | runtime | PASS |
| Accidental taps/tiny drags ignored | 10 pt drag ×2 sizes → no move; multi-touch first pointer only | runtime | PASS |
| Leave and return exactly where I was | kill+relaunch (CONTINUE and debug), chevron, edge-swipe, HOME | runtime | PASS (elapsed/restartCount unobservable) |

## 4. Acceptance Criteria Traceability

| AC | Scenario → Evidence | Result |
| --- | --- | --- |
| AC1 | open smoke-tr-01 / Journey L1 on 3 widths: target rail, grid, `0 HAMLE`, 3 pips, Restart bottom-right away from grid — runtime | PASS |
| AC2 | row 1 right → exactly one cell, only that row, MOVES 1 (393); 105 pt row-0 swipe wins in 1 (390) — runtime | PASS |
| AC3 | smoke-tr-06 column 0 down → one cell, MOVES 1 — runtime; tie-band diagonal (dx60/dy56) → horizontal on 440 — runtime | PASS |
| AC4 | 10 pt drag → grid + MOVES unchanged (393 and 390) — runtime | PASS |
| AC5 | integration groups 2 ×2 (second drag dropped in the ~190 ms window; rapid same-row swipes count after settle) on the live simulator — repeatable integration; widget mirror §17.2 — automated. A hand-timed double swipe was not attempted (tool latency > 190 ms) | PASS (repeatable integration) |
| AC6 | 3 undos then 4th tap: pips hollow, Undo greyed, MOVES unchanged, no dialog/ad — runtime | PASS |
| AC7 | Restart: grid reset, MOVES 0, pips 3, no dialog — runtime | PASS |
| AC8 | win → lock, amber row fill, panel opens, chevron hidden — runtime; choreography timing/visibility **FAIL** (F03-QA-01) | **FAIL (visual)** |
| AC9 | axis/tracking logic: `gesture_resolver_test.dart` `trackingAxis`, controller `tracking` phase — automated. Rail/lift highlight while dragging not observed at runtime (tool cannot capture during a held touch) | PENDING (runtime), automated PASS |
| AC10 | kill+relaunch via CONTINUE (Journey L1) and debug entry: exact grid/MOVES/pips; tampered cache re-derived; HOME round trip; back keeps snapshot — runtime | PASS (elapsed, restartCount unobservable) |
| AC11 | widget mirror only (transient word during animation ≠ win); not separately provable on-screen | automated PASS; runtime not separately executed |

## 5. Boundary Matrix

| Transition / boundary | Result | Evidence |
| --- | --- | --- |
| idle → tracking → resolve (threshold, tie band, first pointer, off-plate release) | PASS | runtime (10 pt / 60×56 / two-finger / release at x=439) |
| animating: input dropped, not queued | PASS | integration groups 2 on simulator |
| won: input locked; only panel actions | PASS | runtime (Retry, Next, Close) |
| snapshot: fresh puzzle, matching puzzleId, mismatching puzzleId (another puzzle's slot replaced on open), tampered cache | PASS | runtime |
| one active-session slot: opening a different puzzle replaces the previous in-progress session | matches F08/§9 contract (note N2) | runtime |
| background: idle HOME round trip | PASS | runtime |
| background: mid-drag / mid-animation | **PENDING** | not producible; widget mirror passes; suite group 4 hangs |
| rotation | **PENDING** | not producible |
| exit paths: chevron, edge-swipe, replaced-route (Next Level → chevron) → `/` | PASS | runtime |
| literal direct entry `/play` with empty stack | not reachable at runtime (no URL scheme registered); nearest equivalent (replaced route) PASS; `_popToCaller` else-branch source-inspected | static |

## 6. Contract Compliance Check

* §6 state machine, §7 gesture mapping (one cell, tie → horizontal, first pointer), §8 counters, §9 persistence (hydrate on matching id, fresh + initial snapshot otherwise, `completed` + clear on panel open), §13 route: **honoured** on the current code; `_popToCaller` (post-F05) returns to `/` on every observed exit.
* §10 completion sequence: lock, highlight, seam bar, bounded ≤600 ms **then** panel — sequencing and row visibility **not honoured** (F03-QA-01).
* §11 animation lock: honoured (integration). §12 backgrounding: idle verified; mid-drag/mid-animation pending.
* No contract change or breaking change observed in packages (all package suites unchanged and green).

## 7. UI Design Compliance Check

* Screen goal/hierarchy/state: HEDEF rail, recessed board plate, quiet HUD, no playing-screen CTA (intended, §18), Undo pips, separated Restart — consistent with Direction A.
* Special tiles: locked = brass ring (pin glyph very faint, note N1), frozen = frost fill + crystal border, thaw on win: PASS as static states.
* Win: fill + drawn seam bar exist in code and appear briefly, but are not visible for their designed duration (F03-QA-01).
* Premium rubric: not re-scored this run (no visual redesign); the win-moment mismatch is the only deviation found.

## 8. Test Findings

### F03-QA-01 — Win choreography is cut off / occluded by the completion panel

* Severity: Medium (core "win moment"; regression introduced after the 2026-09-06 approval)
* Area: F03 win path × F04 panel integration (`app/lib/play/play_session_screen.dart:314-345`, `app/lib/play/widgets/puzzle_board.dart` win animation)
* Type: UI Design Mismatch
* Related authority: F03 `ui-design.md` (won: ≤600 ms L→R amber stagger + drawn amber seam bar + bloom, **then** the sheet; "seam bar is not optional"); F04 `ui-design.md` (F03 win sequence completes, then the panel rises; "the amber winning row is visible above the panel … deliberate"); F03 architecture §10 (highlight → success animation → open panel).
* Description / Actual: `CompletionPanel` is revealed with `AnimatedSlide(320 ms)` the instant `phase == won`; `PlayTheme.winDuration` (600 ms) drives the board's stagger/seam/bloom concurrently. 40 ms frame sheet of smoke-tr-06 (win row 2): shift settles ≈ +240 ms, row turns amber ≈ +280 ms, sheet starts ≈ +320 ms, winning row fully covered by ≈ +400 ms. The amber row is visible ≈ 1–3 frames (≈ 40–120 ms); the seam bar/bloom are effectively never seen. For rows 2–4 the row is always hidden behind the panel; with the Perfect variant (`HARİKA` plate) the sheet also clips the lower half of the **row-0** win tiles (Journey L1 on 393 and smoke-tr-01 on 390 widths). Non-Perfect row-0 wins keep the row visible.
* Expected: choreography plays to completion, seam bar drawn, then the panel; winning row remains visible above the panel (F04 handoff) — for any winning row.
* Reproduce: iPhone 16, debug build, home → L06 → swipe (63,442)→(63,540); or CONTINUE → level 1 → two left swipes on row 0.
* Recommendation (hypothesis, not a verdict on cause): the F04 handoff geometry (a 34–42 % strip above a 56–66 % panel) cannot hold win rows 2–4, and the implementation has no sequencing delay. Tech Lead to settle sequencing/geometry authority; then Frontend/Mobile Developer implements; UI Designer only if the geometry needs a new handoff.
* Not a finding against AC8's literal wording: input locks, the row highlights and the panel opens.

### F03-QA-02 — Device-form integration suite does not complete on a live simulator

* Severity: Medium (required closure artifact per architecture §18 is not green)
* Area: `app/integration_test/play_session_test.dart` group 4
* Type: Regression Risk (validation)
* Actual: on iPhone 16, groups 1–3 pass (10/10); `paused mid-drag cancels the gesture, no move` never completes (16m46s, `[E]`), `tearDownAll` fails, the second lifecycle test never runs; run = "Some tests failed". The CI step is `continue-on-error`, so this is invisible in CI.
* Hypothesis only: `handleAppLifecycleStateChanged(paused)` disables frame scheduling on the live binding, after which `pumpAndSettle` cannot settle.
* Recommendation: Frontend/Mobile Developer makes group 4 complete on a live device binding (or replaces it with device-safe assertions) so `flutter test integration_test -d <sim>` exits 0; then QA re-runs it.

### Notes (non-blocking, no verdict effect)

* N1 — locked-tile pin glyph is very faint behind the letter; ring + fill carry the cue.
* N2 — opening any puzzle replaces the single active-session slot (per §9/F08); a debug-row entry discards a Journey session in progress. Debug-only today; confirm intent for F07/F10.
* N3 — iPhone `Info.plist` lists LandscapeLeft/Right; the portrait lock exists only as the runtime call in `main()`.
* N4 — elapsed time and restartCount have no on-screen surface; their restore is verified only by automated tests.
* N5 — integration helper builds several `AppDatabase` instances per run (Drift multiple-database warning noise in debug logs).
* N6 — simulator pointer is synthetic; the "gesture accuracy ≥ target on the device matrix" success metric is measured only at a few points (10 pt no-op; 50/105/120 pt one-cell; 60×56 tie), not a threshold sweep or physical-finger run.

## 9. Positive Scenarios

* Start: `smoke-tr-01`, `MOVES 0`. Action: row 1 right. Result: `G B C D F`, MOVES 1, Undo enabled. Then row 0 right → `MASAL`, lock, amber row, panel (2/3 stars, SEN 2 / OPTİMAL 1 / EN İYİ İLK 2), chevron hidden.
* Start: CONTINUE → Journey L1 (`ASLAN`). Action: two left swipes on row 0. Result: `HARİKA`, 3/3, SEN 2 = OPTİMAL 2, SONRAKİ primary → level 2 (`BADEM`) → chevron → home `1 / 30`, CONTINUE = Seviye 2.
* Start: L1 with 1 move + 2 undos left; kill process; relaunch; L01 → identical grid, MOVES 1, 2 pips.

## 10. Negative / Edge Cases

* Sub-threshold 10 pt (393, 390): ignored. Column swipe on column-disabled puzzle: MOVES unchanged, no error surfaced. 4th Undo: inert. Restart: no dialog. Diagonal 60×56 (440): horizontal. Two-finger (440): first pointer's row only, +1 move. Release at x=439 beyond the plate (440): resolves on last position (+1). Slow 50 pt drag: exactly one cell. Locked pivot (smoke-tr-05): pivot stayed while its row rotated (`V P R U T`). Frozen tile (smoke-tr-06): stays put while its row rotates (`L X S A A`), thaws on win. Stale/mismatching snapshot: opening another puzzle starts fresh, no crash. Tampered thaw cache on the real store: re-derived (frozen).
* Not executed: rotation; HOME during held touch / mid-animation; hand-timed double swipe.

## 12. UX & State Handling

Loading: bounded splash → home; Error: not triggered; Success: see F03-QA-01; Disabled: Undo greyed at 0; Pressed/tracking: not visually captured; Focused/Semantics: not exercised (accessibility tree unavailable for Flutter in this tool). Runtime evidence summary: simulator runtime for AC1–AC8/AC10 and misuse cases; win visuals fail on timing/occlusion.

## 14. Frontend Quality

analyze/format clean, 181 app tests green; the integration suite defect (F03-QA-02) and the win sequencing (F03-QA-01) are the only quality gaps found.

## 15. UI Handoff Alignment

Aligned: stage, tiles, HUD, Undo pips, Restart placement, chevron rule, locked/frozen states. Deviating: won sequence order and winning-row visibility (F03-QA-01), affecting the F03 `ui-design.md` "seam bar not optional" and the F04 "winning row stays in frame" requirements.

## 16. Regression Risk

Shared files touched since the last approval: `play_session_controller.dart`, `play_session_providers.dart`, `play_session_screen.dart` (e4311d3), plus F04 rating wiring. Dependents: F04 panel, F05 Journey/unlock, F08 persistence. Exercised at runtime: unlock + Next Level + exit, resume, completion panel variants (non-Perfect, Perfect). Not exercised: Daily source (F07 unimplemented), F08 storage-failure path (F08.STORAGE), all-30-complete state (F05 QA).

## 17. Final Verdict

### **Rejected**

* Blocking: **F03-QA-01** (reproduced deviation from two UI authorities on the win moment, regression after the prior approval) and **F03-QA-02** (required device-form suite fails). Functional interaction, persistence, navigation and misuse behaviour are otherwise sound on the current revision.
* Missing required runtime evidence (kept separate from the defects, still required before any approval): rotation (F03.ROTATION); paused mid-drag / mid-animation on a live target (part of F03.RUNTIME-MATRIX); AC9 rail highlight at runtime; hand-timed AC5 optional.
* Why not Approved / Approved with Notes: a blocking defect exists and required scenarios are unexecuted; `Approved with Notes` cannot absorb either.

## 18. Required Fixes

1. F03-QA-01 — sequencing/geometry so the winning row and seam bar are seen for their designed duration before the panel covers the board, for every winning row and the Perfect variant. Authority decision first (Tech Lead), implementation Frontend/Mobile Developer, UI Designer only if a new geometry handoff is needed.
2. F03-QA-02 — make `integration_test` group 4 complete and green on a live simulator; re-run on ≥ 2 widths.
3. Re-verification (QA) after 1–2: win visuals on rows 0–4 + Perfect variant with a frame capture; integration suite exit 0; then the still-pending items below.

---

# WORKFLOW VERDICT SUGGESTION (NON-AUTHORITATIVE)

## QA Result

* **Rejected**

## Affected Areas

* UI Design / Frontend (win sequencing); Integration test (Frontend); Multiple (F03 × F04 panel).

## Blocking Issues

* F03-QA-01, F03-QA-02.

## Suggested Fix Order

1. Tech Lead — decide win-sequence/panel-geometry authority (F03 §10 vs F04 handoff); route a UI Designer geometry handoff only if needed.
2. Frontend/Mobile Developer — implement sequencing/geometry; fix integration group 4.
3. QA — re-verify F03 (final), reuse the PASS scenarios listed in §0b for unchanged code paths.

## Pending Validation Scenarios (independent of the defects)

* F03.ROTATION — needs a rotation-capable target/tool (physical device or simulator UI automation with accessibility permission).
* Paused mid-drag and mid-animation on a live target (HOME while a touch is held; HOME within ~190 ms of a shift).
* AC9 swipe-begin highlight captured during a held drag.

---

## 19. Sonraki Komut

```
Run Tech Lead
```

---

## 20. Tech Lead Note

<<<TEXT

F03 final QA on `7a907dd`: **Rejected** (two blocking findings), plus pending runtime scenarios that no code fix will close.

WHAT PASSED (runtime, iPhone 16 / 16e / 16 Pro Max simulators, real app root and on-disk store): AC1–AC8 interaction, AC10 exact resume after real process kill through CONTINUE and the debug entry, tampered thaw cache re-derived on the real store, chevron / iOS edge-swipe / replaced-route exit to home, Journey win → Next Level → progress `1 / 30`, and the misuse set (sub-threshold, rejected move, undo exhaustion, restart, tie-band, two-finger, off-plate release, locked pivot, frozen tile). Gates: analyze 0, format 0, 378 tests pass, debug sim build OK.

BLOCKING: (1) F03-QA-01 — the F04 completion panel starts rising ≈40 ms after the amber fill, so the ≤600 ms win sequence (stagger, drawn seam bar, bloom) is effectively hidden; for winning rows 2–4 the row is always under the panel, and the Perfect variant clips even row 0. This contradicts F03 ui-design ("seam bar is not optional"; sheet after the sequence) and F04 ui-design ("winning row stays visible"), and is a regression from e4311d3 — the 2026-09-06 approval could not have seen it. Authority question for you: sequencing and geometry (the F04 34–42 % strip cannot hold rows 2–4). (2) F03-QA-02 — integration group 4 never completes on a live simulator (16m46s, then "Some tests failed"); hypothesis only: paused lifecycle + pumpAndSettle.

STILL PENDING (not defects): rotation (tooling denied), HOME during a held touch / mid-animation, AC9 highlight capture. Suggest scheduling a QA pass on a target/tool that can rotate and interleave lifecycle events, or record an explicit decision gate if you want to accept the simulator-only limits (that acceptance is yours/the user's, not QA's).

DO NOT read this as a product/PO escalation: no requirement conflict was found. F08.STORAGE stays with F08. F05.SHARED-RUNTIME may reuse only the PASS scenarios above for identical scope (resume, CONTINUE, exits); the win-moment scenario is open.

TEXT
