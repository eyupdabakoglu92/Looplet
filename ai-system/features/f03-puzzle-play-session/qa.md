# F03 — puzzle-play-session: QA Report (re-verify)

QA run: 2026-09-20 (second final-stage run) · Task: F03-QA-REVERIFY · QA Stage: final · QA Scope: client-only · Release Scope: none
Verified revision: `c0cba44` (clean tree; `app/`, `packages/`, `content/`, `tools/` byte-identical to the delivery commit `cf8d8f0`, 0 code files differ). Replaces the earlier 2026-09-20 report (rev 7a907dd, Rejected) — its PASS scenarios are reused below only where stated with a reason.

---

## 0a. Evidence Mode Declaration

* Bash / build access: **VAR**
* Device test suite: **VAR** — `flutter test integration_test/play_session_test.dart -d <UDID>`
* Screenshot / device tool: **VAR** — iOS Simulator control (tap/swipe/touch_path/screenshot), `simctl io recordVideo` + a Swift/AVFoundation frame-sheet tool, `simctl ui content_size`, Simulator menu automation (System Events — **Accessibility now granted**), the Settings app driven by taps
* Runtime validation method: **runtime** on iOS 18.6 simulators (iPhone 16 393×852 primary, 16e 390×844, 16 Pro Max 440×956; debug build, real `main.dart` root, real on-disk Drift store) + **repeatable integration** + **automated functional**
* Declared limits: simulator pointer is synthetic (no physical finger / threshold sweep); the OS Grayscale colour filter is not available in this simulator's Settings (luminance conversion of a real frame used); the Settings app's Home menu item and `defaults write` do not reach the app (used `simctl launch` app-switch instead).

---

## 0b. Evidence Ledger

| Claim / Scenario | Class | Command / Action | Target | Result / Exit | Provenance | Isolation |
| --- | --- | --- | --- | --- | --- | --- |
| Static + automated gates | static / automated functional | `melos run analyze` · `melos run format:check` · `melos run test` | workspace | analyze **0**, format **0** (152 files, 0 changed), **197 package + 214 app tests pass**, 0 failed | rev c0cba44, 2026-09-20 | widget tests use in-memory DB + overrides |
| Device-form suite (F03-QA-02 closure) | repeatable integration | `flutter test integration_test/play_session_test.dart -d <UDID>` | iPhone 16e; iPhone 16 Pro Max (QA); iPhone 16 (Tech Lead + Frontend on the same code) | **12/12 pass, exit 0** on 16e (1 m 19 s) and 16 Pro Max (1 m 01 s); group 4 completes | rev c0cba44 | in-memory DB, not production root |
| Debug build of this revision | build | `flutter build ios --debug --simulator` | app | **PASS**, exit 0 (24 s) | rev c0cba44 | build ≠ behaviour |
| Won moment F03-QA-01: row 0 (Journey L1, debug L01), row 1 (L3), row 2 (debug L06), row 3 (L2), row 4 (L4) | runtime + video | play via CONTINUE → Next Level ×3 and debug row, `recordVideo` + 60 ms frame sheet | iPhone 16; single-frame checks on 16e and 16 Pro Max | **PASS** — see §4/§9 | 2026-09-20 | debug build |
| F04 variants (2★ first-clear, matched, newBest + Perfect, Perfect) with Retry between | runtime | debug L01 loops | iPhone 16 | **PASS** | same | — |
| Large text (XXXL, then accessibility-medium) | runtime | `simctl ui <UDID> content_size …` | iPhone 16 | **PASS** — panel top stays ≥ 0.36 H, docked row clear, density fallback visibly engaged, controls unclipped | same | — |
| Portrait lock (F03.ROTATION) | runtime | System Events `Device > Rotate Left / Right` with the app in the foreground; Safari as a control | iPhone 16 | **PASS** — Safari rotates to landscape, LOOPLET stays portrait, unchanged layout, both directions, incl. relaunch | same | — |
| Drag lift/highlight (AC9) | runtime | 13 s held touch (`touch_path`, 1000 ms points) + screenshot at +6 s | iPhone 16 | **PASS** — dragged row lifted, brighter, wrap ghost, other rows dimmed, HUD dimmed | same | — |
| App backgrounded mid-drag (F03.LIFECYCLE-LIVE) | runtime | held drag ≥ 3 s, then `simctl launch Safari` (real OS app switch); 1 Hz screenshot log proves the touch was down | iPhone 16 | **FAIL ×2 (+1 earlier)** — the drag is committed as a move | same | see F03-QA-03 |
| iOS Reduce Motion | runtime | Settings > Accessibility > Motion > Reduce Motion **ON** (real toggle), relaunch, record a win | iPhone 16 | **FAIL** — full glide/slide and F04 star reveal at normal speed | same | see F03-QA-04 |
| Resume after real process kill via CONTINUE | runtime | move → `simctl terminate` → relaunch → CONTINUE | iPhone 16 | **PASS** exact grid + MOVES | same | — |
| Back paths | runtime | chevron, iOS left edge-swipe, Close from a Next-Level replaced-route chain | iPhone 16 | **PASS** → `/`, ring `4 / 30`, CONTINUE = level 5 | same | — |
| Misuse set | runtime | sub-threshold (10 pt), near-diagonal (60×56) | iPhone 16 | **PASS** | same | — |
| Greyscale legibility of the docked row | runtime (approximated) | luminance conversion of a real Pro Max win frame | Pro Max | **PASS (approx.)** | same | not the OS colour filter |

Reused from the earlier run (rev 7a907dd) with reason — the paths' code is unchanged in `cf8d8f0` (`play_session_controller.dart`, `gesture_resolver.dart`, persistence untouched): AC1–AC7 basic interaction, tampered `thawedFrozenCells` re-derivation on the real store, locked-pivot and frozen-tile behaviour, multi-touch and off-plate release. The edited files (`play_session_screen.dart`, `puzzle_board.dart`, `completion_panel.dart`) were re-exercised above.

---

## 1. Feature Summary

Final-stage re-verification of F03 after the rework for F03-QA-01 (win sequence vs the F04 panel) and F03-QA-02 (device-form suite), plus the three route-A scenarios (rotation, live lifecycle, AC9) that were pending.

## 2. Test Scope

* Scope Type: client-only, final. Reviewed: architecture.md §12 and §18 (Won-sequence authority), ui-design.md §16, orchestration brief, frontend.md, code of the edited files, `PuzzleBoard` gesture handlers, Flutter `AccessibilityFeatures` docs in the local SDK.
* Journeys: CONTINUE → level 1 → Next Level ×3 (real replaced-route chain) → Close; debug wins; Retry loops; kill/relaunch resume.
* Misuse/interruption: sub-threshold, near-diagonal, held drag + OS app switch, rotation, large text, Reduce Motion.
* Out of scope: Backend build gate / quality — none touched. Security compliance — local single-player state, no auth/other-user data/finance. Release compliance — Release Scope none. iOS/Unity game sections — Flutter client. Mode matrix — widths folded into §4/§5. Storage-full injection is F08 AC7 (F08.STORAGE), neither passed nor failed here.

## 3. Product Behavior Coverage

| User story | Evidence | Result |
| --- | --- | --- |
| Swipe a row/column, one cell | wins on rows 0–4 (real levels), 2★/Perfect | PASS |
| Target always visible | rail + divider on all widths; docked row pairs under it after a win | PASS |
| Live MOVES | HUD through all runs | PASS |
| 3 undos and a restart | reused (unchanged code) + Retry loops | PASS |
| Accidental drags ignored | 10 pt no-op, diagonal tie; **an interrupted drag is not ignored — it is committed** | **FAIL (F03-QA-03)** |
| Leave and return exactly | kill/relaunch via CONTINUE, chevron, edge-swipe, replaced-route exit | PASS |

## 4. Acceptance Criteria Traceability

| AC | Evidence | Result |
| --- | --- | --- |
| AC1–AC7 | reused + spot runs (see 0b) | PASS |
| AC8 | won moment on rows 0,1,2,3,4 (Perfect) and 2★/matched/newBest variants: lock, amber row, seam, **panel only after the win sequence**, docked row visible above the panel at rest, star reveal after rest; 60 ms frame sheet of a row-4 win: amber at home ≈ 600 ms → ghost + glide → panel rises → stars strike, `HARİKA` last | **PASS** |
| AC9 | held-drag capture | **PASS** |
| AC10 | kill/relaunch resume PASS; **resume after an OS interruption mid-drag contains the interrupted swipe as a move** (persisted `appliedMoves` R3, R4 = the two interrupted drags) | PASS for kill; see F03-QA-03 |
| AC11 | widget mirror only | automated PASS |

## 5. Boundary Matrix

| Boundary | Result | Evidence |
| --- | --- | --- |
| tracking → OS interruption (app switch) | **FAIL** — swipe committed | timeline log + persisted snapshot |
| animating → pause | consistent, atomic and persisted (occurred as a consequence of the above: cancel → shift → pause → committed) | runtime |
| won: T0 → panel at rest, chevron hidden, input locked | PASS | frame sheets |
| won → Retry / Close / Next | PASS | runtime |
| rotation | PASS | runtime |
| large text 1.0 → ~1.6× | PASS | runtime |
| OS Reduce Motion | **FAIL** | runtime |

## 6. Contract Compliance Check

* architecture.md §18: panel not before T0+600 ms; dock; panel cap; ghost slot; single glow; persistence timing unchanged — **honoured** on all observed rows/variants. §16.5 rules verified by the 25 on-screen tests (rerun green) and by real-app frames.
* §12 backgrounding: idle pause **honoured**; **"gesture cancelled cleanly, no Move submitted" NOT honoured** on a real OS interruption (F03-QA-03).
* §18 / ui-design §16.2 reduce-motion path: **unreachable on iOS** (F03-QA-04).
* Persistence, route contract, F04 panel content: honoured.

## 7. UI Design Compliance Check

Won composition matches ui-design.md §16 on real frames: fixed dock centred under the target rail, ≥ clearance to the panel, single glow, ghost outlines at the vacated row, no clipping on 390/393/440 widths and at large text. The docked row is the brightest object in greyscale and the seam reads as a bar. Notes (not findings): the dimmed board's row 0 remains as a half-cut strip of letters directly under the docked seam when a *lower* row wins (`Y C D F G` for row 2, `M L Ç N D` for row 4) — acceptable, no rubric fail condition; the 30 ms L→R amber stagger from the original ui-design is still absent (tiles switch together) — pre-existing, non-blocking.

## 8. Test Findings

### F03-QA-03 — An app interruption during a drag commits the swipe instead of cancelling it

* Severity: Medium (an unintended move is counted; contradicts the "honest moves" principle)
* Area: `PuzzleBoard` gesture handlers × `PlaySessionController.onAppPaused`
* Type: Contract Violation (State/Flow) — `architecture.md §12` "App backgrounded mid-swipe → the in-progress gesture is cancelled cleanly (no Move submitted); state → idle"; PRD edge cases ("never a half-applied move")
* Reproduced 3 times on iPhone 16 (rev c0cba44 code): hold a drag > 18 pt for ≥ 3 s (a 1 Hz screenshot log shows the row lifted and tracking until 20:02:53), then bring another app to the front (`simctl launch com.apple.mobilesafari`, 20:02:54.8). After returning: the dragged row is shifted, `MOVES` +1, and the store holds the move (`appliedMoves` `R1 R2 R3 R4`, with R3/R4 the interrupted drags). Both the returned UI and a cold relaunch show it.
* Expected: no move; `MOVES` unchanged; state idle.
* Mechanism (hypothesis, not verified in code by a fix): iOS cancels the touch first; `PuzzleBoard._onPanCancel → _release(_dragOffset)` treats a cancel as a release, starting the shift, and the following `paused` commits it (`_finishShift`). The widget/integration mirrors send `paused` without the OS touch cancellation, so they cannot see this.
* Recommendation: Frontend/Mobile Developer — treat a pointer **cancel** as an abort (no `endDrag` resolution) while keeping genuine releases (including outside the plate) resolving; add a test that sends a real `PointerCancel` mid-drag; re-verify on a simulator with an app switch.

### F03-QA-04 — iOS "Reduce Motion" is not honoured; the new reduced-motion path is unreachable on iOS

* Severity: Medium (accessibility; explicit requirement of the reworked contract)
* Area: `_PlayBodyState._enterWon`, `PuzzleBoard._onController`, `CompletionPanel._startOrSettle` (and the F05 ring), `AnimationController` behaviour
* Type: Functional Bug (Accessibility) — `architecture.md §18` / `ui-design.md §16.2` "Under OS reduce motion …"
* Evidence: Settings > Accessibility > Motion > Reduce Motion set ON through the real toggle (the extra "Prefer Cross-Fade Transitions" row appears, confirming it is active) and the app relaunched: a win still plays the full 600 ms hold → 240 ms **glide** → panel **slide**, and F04's stars strike one by one. The local Flutter SDK documents `AccessibilityFeatures.reduceMotion` as "the platform is requesting that certain animations be simplified … **Only supported on iOS**", whereas the code reads `accessibilityFeatures.disableAnimations`.
* Hypothesis: on iOS Reduce Motion arrives as `reduceMotion`, not `disableAnimations`; the widget tests fake `disableAnimations`, so they pass. The same check exists in F04 and F05 code, so the gap is wider than F03.
* Recommendation: Frontend/Mobile Developer — one shared helper `reduceMotionRequested = reduceMotion || disableAnimations` used by F03 (`_enterWon`, `PuzzleBoard`), F04 (`CompletionPanel`) and F05 (ring/tutorial); tests for both flags; `AnimationController.animationBehavior` decisions revisited; re-verify with the Settings toggle. Tech Lead to scope the F04/F05 touch.

### Notes (non-blocking)

* N1 — Journey progress and unlock, Next Level and the replaced-route exit behaved correctly; one unexplained stray entry into level 5 after tapping the debug `L01` right after closing the level-4 panel occurred once and was not reproducible (3 later attempts opened smoke-tr-01).
* N2 — Settings > Home menu item and `defaults write com.apple.Accessibility` do not affect the app; OS switch via `simctl launch` is a valid lifecycle trigger.
* N3 — Physical-finger accuracy (threshold sweep) is still not measured; the simulator pointer is synthetic.
* N4 — Row-0 strip and missing amber stagger: see §7.

## 9. Positive Scenarios

* CONTINUE → level 1 (row 0) → Next → level 2 (**row 3**) → Next → level 3 (**row 1**) → Next → level 4 (**row 4**, column tutorial) → Close → home `4 / 30`, CONTINUE = level 5 — every win: amber row at home for the win sequence, glide to the dock under the target rail, panel rises after, docked row + seam visible above the panel, `HARİKA` Perfect.
* Debug `L06`: frozen-tile thaw win in **row 2** (previously hidden) — docked and visible.
* 2★ first-clear → Retry (fresh idle board, chevron back) → same 2 moves = matched (`EN İYİ 2`, no star mark) → Retry → 1 move = `YENİ REKOR` + Perfect.
* iPhone 16e and 16 Pro Max: Perfect win, docked row clear of the panel.
* XXXL and accessibility-medium Dynamic Type: panel unclipped, docked row clear, density fallback engaged (smaller stars).

## 10. Negative / Edge Cases

Sub-threshold drag: no move. Near-diagonal (60×56): horizontal row shift. Rotation both directions with a landscape-capable control app: LOOPLET stays portrait. HOME/app switch while idle: state identical. **App switch during a held drag: the swipe is committed (F03-QA-03).** Reduce Motion on: not honoured (F03-QA-04).

## 12. UX & State Handling

Loading: splash → home; Success: verified; Disabled: Undo greyed; Tracking: lift/dim/HUD dim verified; Runtime evidence summary: simulator runtime across rows 0–4, variants, text sizes, rotation; accessibility (Reduce Motion) fails.

## 14. Frontend Quality

analyze/format clean, 214 app tests and the 12-test device suite green on 3 widths; the two open items are behaviour the automated mirrors cannot see (real touch-cancel, iOS Reduce Motion flag).

## 15. UI Handoff Alignment

Aligned (see §7). The reduced-motion clause of §16.2 cannot take effect on iOS (F03-QA-04).

## 16. Regression Risk

Edited shared files: `play_session_screen.dart`, `puzzle_board.dart`, `completion_panel.dart`. Dependents exercised on the real app: F04 panel (all variants, Close 44 pt), F05 unlock / Next Level / replaced-route exit / CONTINUE / tutorial overlay (level 4), F08 resume. F04/F05 Reduce-Motion checks share F03-QA-04's cause. Not exercised: Daily (F07), storage-failure (F08.STORAGE), all-30-complete (F05 QA).

## 17. Final Verdict

### **Rejected**

* Closed from the previous verdict: **F03-QA-01** (won moment: fixed on rows 0–4 and all variants) and **F03-QA-02** (device suite: 12/12 exit 0 on three widths). The three route-A scenarios were produced: rotation **PASS**, AC9 highlight **PASS**, live lifecycle **FAIL**.
* Blocking: **F03-QA-03** (contract §12 violated on a real OS interruption) and **F03-QA-04** (iOS Reduce Motion not honoured, reduced-motion path of §18/§16.2 unreachable).
* No required evidence is pending: the verdict is a defect verdict. Approved / Approved with Notes are barred while either finding stands.

## 18. Required Fixes

1. F03-QA-03 — treat a pointer cancel as an abort; keep releases resolving; add a real-cancel test; QA re-verify with an OS app switch mid-drag (idle pause must stay unchanged).
2. F03-QA-04 — honour `reduceMotion || disableAnimations` in F03, F04 and F05 sites; tests for both flags; QA re-verify with the Settings toggle (static hold → fade → panel; no glide/slide; F04 reveal settled).

---

# WORKFLOW VERDICT SUGGESTION (NON-AUTHORITATIVE)

## QA Result

* **Rejected**

## Affected Areas

* Frontend (gesture handling; accessibility flag) · Multiple (F03 × F04 × F05 for the Reduce Motion check).

## Blocking Issues

* F03-QA-03, F03-QA-04.

## Suggested Fix Order

1. Tech Lead — scope the fix (F03 files for QA-03; a shared helper touching F04/F05 call sites for QA-04; decide whether F04/F05 acceptance needs a QA note).
2. Frontend/Mobile Developer — implement both with tests.
3. QA — re-verify F03-QA-03/04 and re-spot-check the won moment; reuse this run's PASS scenarios for unchanged paths.

---

## 19. Sonraki Komut

```
Run Tech Lead
```

---

## 20. Tech Lead Note

<<<TEXT

F03 re-verify on `c0cba44` (code = delivery commit `cf8d8f0`): **Rejected** — two new defects; the two earlier ones are closed.

CLOSED: F03-QA-01 — the won moment now matches ui-design §16 on real frames for winning rows 0 (L1/L01), 1 (L3), 2 (L06), 3 (L2) and 4 (L4), Perfect / 2★ / matched / newBest, 16 / 16e / 16 Pro Max, and at XXXL and accessibility-medium text (density fallback engaged, panel top ≥ 0.36 H). A 60 ms frame sheet of the row-4 win shows amber-at-home ≈ 600 ms → ghost + glide → panel → star reveal after rest. F03-QA-02 — device suite 12/12, exit 0 on 16e (1:19) and Pro Max (1:01); analyze 0 / format 0 / 197 + 214 tests. Route A (your decision) worked: Accessibility is granted and used — ROTATION **PASS** (Safari control rotates, LOOPLET stays portrait, both directions), AC9 highlight **PASS**.

NEW BLOCKING: (1) **F03-QA-03** — with a drag in progress, an OS app switch commits the swipe as a move (3 reproductions; a 1 Hz screenshot log proves the finger was down; the store then holds R3/R4 = the interrupted drags). Contradicts architecture §12 ("gesture cancelled cleanly, no Move submitted"). Hypothesis: iOS sends touchesCancelled first and `_onPanCancel` releases the gesture. This was invisible to the mirrors because they send `paused` without the touch cancel — exactly why route A mattered. (2) **F03-QA-04** — with iOS Reduce Motion really ON (Settings toggle; the "Prefer Cross-Fade" row confirms it), the app still glides/slides and F04's stars strike normally. The SDK documents iOS Reduce Motion as `AccessibilityFeatures.reduceMotion` ("Only supported on iOS") while the code reads `disableAnimations`, so the §16.2 reduced path cannot fire on iOS; the same check lives in F04/F05 (your call whether their acceptance needs a note). Widget tests fake `disableAnimations`, hence green.

NOT PENDING any more: every route-A scenario now has a result. Notes only: row-0 strip and missing amber stagger (see §7), an unreproduced stray level-5 entry once, simulator pointer is synthetic. Storage-full stays with F08. F05.SHARED-RUNTIME may reuse: CONTINUE / Next Level / replaced-route exit / kill-resume / back paths PASS on this revision; the interruption and Reduce-Motion items are open.

TEXT
