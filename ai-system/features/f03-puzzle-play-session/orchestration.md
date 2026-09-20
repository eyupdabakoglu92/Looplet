# F03 — puzzle-play-session: Orchestration

## Feature ID

F03

## Current Status

In QA

## Current Owner

Tech Lead

## Next Role

Tech Lead

## Active Task Ledger

- [x] Task ID: F03-QA-RUNTIME | Assigned Role: QA | Status: Done | Summary: Final-stage runtime QA on rev 7a907dd returned verdict Rejected (qa.md 2026-09-20); residual scenarios live in Pending Evidence | Depends On: -
- [x] Task ID: F03-UI-WON | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-20 (ui-design.md §16 Won composition, rubric self-review 92). F03-QA-01 geometry: deliver a `Won composition` section in F03 ui-design.md so the winning row + docked seam stay visible above the F04 panel for rows 0–4 and every F04 variant, per architecture.md §18 (2026-09-20); see Current UI Brief | Depends On: -
- [x] Task ID: F03-FE-WON | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-20 (frontend.md; F03.WIN-LAYOUT 33/33). F03-QA-01: implement win-sequence-then-panel sequencing (panel not before T0+600 ms) and the UI Designer's Won composition; add widget/golden layout assertions; update frontend.md | Depends On: F03-UI-WON
- [x] Task ID: F03-FE-INTEG | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-20 (12/12 exit 0 on 3 simulator widths). F03-QA-02: make integration_test/play_session_test.dart group 4 complete and exit 0 on a live simulator on 2 widths; no product-semantics change | Depends On: -
- [x] Task ID: F03-QA-REVERIFY | Assigned Role: QA | Status: Done | Summary: DONE 2026-09-20 — verdict Rejected (F03-QA-03, F03-QA-04; qa.md). Re-verify F03 final on the changed win path per Planned QA Re-verify Brief; independent verdict | Depends On: F03-FE-WON, F03-FE-INTEG
- [x] Task ID: F03-FE-CANCEL | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-21 (frontend.md). F03-QA-03: a pointer cancel aborts the drag (render Listener + controller.cancelDrag); root cause corrected: a cancel of an accepted pan is delivered as onPanEnd, not onPanCancel; widget 5/5, controller +2, device suite 13/13 on 3 simulator widths; two negative controls | Depends On:
- [x] Task ID: F03-FE-REDUCEMOTION | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-21 (frontend.md). F03-QA-04: one shared reduceMotionRequested() (reduceMotion OR disableAnimations) at all six call sites incl. F04 panel and F05 ring/tutorial; per-site tests for both flags with no-signal controls and a negative control; 243 app tests | Depends On:
- [x] Task ID: F03-QA-REVERIFY2 | Assigned Role: QA | Status: Done | Summary: DONE 2026-09-21 at HEAD 5be4dc6 (app tree = cf747f8) — verdict Approved with Notes (qa.md): real OS app switch mid-drag x3 and device lock = no move; real iOS Reduce Motion ON/OFF verified on F03 win, F04 reveal, F05 ring and tutorial; genuine-release regression, gates, device suite 13/13 on 16e and Pro Max | Depends On: F03-FE-CANCEL, F03-FE-REDUCEMOTION

## Open Tasks

None

## Handoff Plan

None

## Delivery Review

Accepted

## QA Scope

client-only

## QA Stage

final

## QA Result

Approved with Notes

## Release Scope

none

## Release Result

None

## Visual Scope

none

## Design Foundation

Not Required

## Visual Quality Gate

Not Required

## Visual Evidence

None

## QA Modules

core, client-ui, stateful-flow

## Regression Depth

full

## Evidence Reuse

allowed

## Pending Evidence

- Evidence ID: F03.RUNTIME-MATRIX
  * Scenario: architecture.md §16/§18 critical journeys (AC1–AC11) on the required device matrix, real app root. 2026-09-20 QA PASSED AC1–AC8 and AC10 (real-kill resume via CONTINUE and debug entry), tampered cache on the real store and the misuse set. Residual, tracked as separate items below: F03.LIFECYCLE-LIVE, F03.AC9-HIGHLIGHT, F03.INTEG-DEVICE. Re-run of the win path is required after F03-FE-WON (F03-QA-REVERIFY)
  * Required Class: runtime
  * Target / Environment: iOS simulators, one small + one large logical width (iPhone 16e 390 / iPhone 16 Pro Max 440; iPhone 16 393), iOS 18.6, real app entry (`main.dart`)
  * Owner Role: QA
  * Prerequisite / External Decision: F03-FE-WON and F03-FE-INTEG delivered; residual items closed via the F03.RUNTIME-LIMITS = A route
  * Re-evaluation Trigger: During F03-QA-REVERIFY2
  * Blocks: F03 final acceptance; F05 shared play/navigation/persistence scope
  * Result: PASS
  * Provenance / Note: 2026-09-21 QA, HEAD 5be4dc6 (app = cf747f8): journeys AC1-AC10 on iPhone 16 (real main.dart root, on-disk Drift store) incl. Journey levels 1-5 via Next Level, kill/relaunch resume, misuse set; earlier-run paths REUSED by fingerprint (qa.md R1-R7); device suite 13/13 exit 0 on 16e and Pro Max (E3). Android capture remains Pending project-level (platform.md §14).

- Evidence ID: F03.VISUAL
  * Scenario: Win choreography readability (F03-QA-01) and locked/frozen tile + thaw confirmation; amber seam bar legible in greyscale
  * Required Class: manual
  * Target / Environment: Simulator; win-frame capture (video + frame sheet) on real reachable winning rows plus the Perfect and non-Perfect variants; debug row L5 = smoke-tr-05 locked pivot, L6 = smoke-tr-06 frozen tile
  * Owner Role: QA
  * Prerequisite / External Decision: F03-UI-WON and F03-FE-WON delivered
  * Re-evaluation Trigger: After F03-FE-WON delivery is Accepted
  * Blocks: F03 final acceptance; applicable F05 shared visuals
  * Result: PASS
  * Provenance / Note: 2026-09-20 QA, rev c0cba44: won moment on real frames rows 0–4, Perfect/2★/matched/newBest, 16/16e/Pro Max, XXXL and accessibility-medium text; ghost slot, single glow, docked row clear. Greyscale approximated by luminance conversion of a real frame (OS colour filter unavailable). Notes: dimmed row-0 strip under the seam for lower-row wins; amber stagger absent (pre-existing). Locked/frozen visuals reused from the earlier run (board_tile.dart unchanged) — spot-checked frozen thaw win on L06 2026-09-21 QA: REUSED at HEAD 5be4dc6 — fingerprint valid (files on this path unchanged since c0cba44); spot-check win rows 0 (reduced) and 4 (regular) re-run, no regression (qa.md R1-R4, E12, E14).
- Evidence ID: F03.WIN-LAYOUT
  * Scenario: Panel not visible before T0+600 ms; winning-row rect not intersected by the panel rect at rest, rows 0–4 × {Perfect, non-Perfect} × {390×844, 440×956}, all F04 variants unclipped
  * Required Class: automated functional
  * Target / Environment: app widget/golden tests (`flutter test` in app/)
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: F03-UI-WON delivered
  * Re-evaluation Trigger: F03-FE-WON delivery
  * Blocks: F03 final acceptance
  * Result: PASS
  * Provenance / Note: 2026-09-20, working tree on HEAD a136a9b (uncommitted): `flutter test test/play/won_composition_test.dart` 33/33 (8 pure + 25 widget) — rows 0–4 × Perfect/2★ × 390×844 and 440×956, 393×852 row 4, text scale 1.3, F04 variants (first-clear/matched/newBest+Perfect via Retry), reduce-motion, panel absent before T0+600 ms; mutation check proved the ordering assertions live. In-memory DB, injected Puzzle, not the production root. Full gates: analyze 0, format 0, 197 package + 214 app tests

- Evidence ID: F03.INTEG-DEVICE
  * Scenario: `flutter test integration_test/play_session_test.dart -d <simulator>` exits 0, all groups incl. group 4 (paused mid-drag, paused mid-animation) complete
  * Required Class: repeatable integration
  * Target / Environment: live iOS simulators, at least two widths
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: None
  * Re-evaluation Trigger: F03-FE-INTEG delivery
  * Blocks: F03 final acceptance
  * Result: PASS
  * Provenance / Note: 2026-09-20, working tree on HEAD a136a9b: `flutter test integration_test/play_session_test.dart -d <UDID>` 12/12 PASS, exit 0 on iPhone 16 (393×852, 56 s), iPhone 16e (390×844, 74 s) and iPhone 16 Pro Max (440×956, 57 s), iOS 18.6. Earlier 2026-09-20 QA run: group 4 hung 16m46 s (F03-QA-02). Root cause: frames stop while paused on a live binding; group 4 now never pumps while paused, asserts the settled state from the store at pause, 90 s hang guard. Harness uses in-memory DB, not the production root 2026-09-21 Frontend/Tech Lead: 13/13 exit 0 (12 + F03-QA-03 cancel-then-paused case) on iPhone 16, 16e, 16 Pro Max at cf747f8 (Tech Lead reproduced on iPhone 16).
- Evidence ID: F03.LIFECYCLE-LIVE
  * Scenario: App paused while a touch is held (mid-drag) and within the ~190 ms shift on a live target; resulting state is settled, no lost/half move
  * Required Class: runtime
  * Target / Environment: rotation/lifecycle-capable target or tool (physical iPhone, or simulator UI automation with accessibility permission)
  * Owner Role: QA
  * Prerequisite / External Decision: F03.RUNTIME-LIMITS = A (RESOLVED 2026-09-20). Accessibility observed granted by the Tech Lead (2026-09-20 read-only probe); QA first probes it itself (osascript click Simulator > Device > Rotate Left, a keystroke) and records the result
  * Re-evaluation Trigger: During F03-QA-REVERIFY2
  * Blocks: F03 final acceptance
  * Result: PASS
  * Provenance / Note: 2026-09-21 QA, HEAD 5be4dc6: held drag >= 3 s (1 Hz screenshot log proves touch down and row lifted) + real OS app switch (simctl launch Safari) x3 (row right, row left, column down): no move, MOVES unchanged, idle, store appliedMoves empty, cold relaunch unchanged; device lock (Simulator Cmd+L) mid-hold: no new move; idle app switch: unchanged (qa.md E4-E6, E9). Same repro was 3/3 FAIL on c0cba44.

- Evidence ID: F03.AC9-HIGHLIGHT
  * Scenario: Row/column lift + rail highlight visible while a drag is in progress (AC9)
  * Required Class: runtime
  * Target / Environment: simulator/device with a screenshot taken during a held touch
  * Owner Role: QA
  * Prerequisite / External Decision: F03.RUNTIME-LIMITS = A (RESOLVED 2026-09-20); same Accessibility grant and QA probe as F03.ROTATION (needs a held touch plus an interleaved HOME)
  * Re-evaluation Trigger: During F03-QA-REVERIFY2
  * Blocks: F03 final acceptance
  * Result: PASS
  * Provenance / Note: 2026-09-21 QA, HEAD 5be4dc6: held touch, full-resolution mid-hold frame: dragged row lifted and brighter, other rows dimmed, wrap ghost at the edge, left rail highlight (qa.md E8).

- Evidence ID: F03.ROTATION
  * Scenario: Portrait lock remains effective under OS/device rotation
  * Required Class: manual
  * Target / Environment: Simulator or device able to rotate; qa.md §17 scenario 6
  * Owner Role: QA
  * Prerequisite / External Decision: F03.RUNTIME-LIMITS = A (RESOLVED 2026-09-20). Accessibility observed granted by the Tech Lead (2026-09-20 read-only probe); QA first probes it itself (osascript click Simulator > Device > Rotate Left, a keystroke) and records the result
  * Re-evaluation Trigger: Accessibility grant confirmed by QA's probe, during F03-QA-REVERIFY
  * Blocks: F03 final acceptance
  * Result: PASS
  * Provenance / Note: 2026-09-20 QA: Accessibility granted; System Events `Device > Rotate Left/Right` with the app in the foreground and a Safari control that rotated to landscape; LOOPLET stayed portrait with unchanged layout, both directions, incl. relaunch. Info.plist still lists landscape, so the runtime lock is the guard 2026-09-21 QA: REUSED at HEAD 5be4dc6 — fingerprint valid (files on this path unchanged since c0cba44); spot-check win rows 0 (reduced) and 4 (regular) re-run, no regression (qa.md R1-R4, E12, E14).
- Evidence ID: F03.BACK
  * Scenario: Chevron, system back and edge-swipe/exit behavior on the current navigation code (post-F05 `_popToCaller`)
  * Required Class: manual
  * Target / Environment: Simulator; re-spot-check after F03-FE-WON because play_session_screen.dart changes
  * Owner Role: QA
  * Prerequisite / External Decision: F03-FE-WON delivered
  * Re-evaluation Trigger: After F03-FE-WON delivery is Accepted
  * Blocks: F03 final acceptance; F05 shared navigation
  * Result: PASS
  * Provenance / Note: 2026-09-20 QA, rev c0cba44: chevron, iOS left edge-swipe, Close from a Next-Level replaced-route chain → `/` with ring 4/30 and CONTINUE = level 5; chevron hidden in won. Literal direct entry still unreachable (no URL scheme) 2026-09-21 QA: REUSED at HEAD 5be4dc6 — fingerprint valid (files on this path unchanged since c0cba44); spot-check win rows 0 (reduced) and 4 (regular) re-run, no regression (qa.md R1-R4, E12, E14).
- Evidence ID: F03.CURRENT-REVISION
  * Scenario: Automated F03 suites, analyzer, format and iOS build on the current tree
  * Required Class: automated functional
  * Target / Environment: current working tree
  * Owner Role: QA
  * Prerequisite / External Decision: None
  * Re-evaluation Trigger: During F03-QA-REVERIFY2
  * Blocks: F03 final acceptance
  * Result: PASS
  * Provenance / Note: 2026-09-21 QA, HEAD 5be4dc6 (clean; app/ packages/ content/ identical to cf747f8): melos analyze exit 0 (1 pre-existing looplet_solver info), format:check exit 0 (155 files), 197 package + 243 app tests pass, debug simulator build exit 0, device suite 13/13 exit 0 on 16e and Pro Max (qa.md E1-E3).

- Evidence ID: F03.CANCEL-TEST
  * Scenario: a real PointerCancel during a drag (OS interruption) leaves MOVES unchanged, phase idle and no persisted move; genuine releases (incl. beyond the plate) still resolve
  * Required Class: automated functional
  * Target / Environment: app widget tests (`TestGesture.cancel()`), integration group 4 without pumping while paused
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: None
  * Re-evaluation Trigger: F03-FE-CANCEL delivery
  * Blocks: F03 final acceptance
  * Result: PASS
  * Provenance / Note: 2026-09-21, working tree on HEAD 6ad8268 (uncommitted): `flutter test test/play/pointer_cancel_test.dart` 5/5 (real PointerCancelEvent via TestGesture.cancel; cancel + paused/resumed leaves the store's appliedMoves empty; pre-slop cancel; release inside and outside the plate still resolves), play_session_controller_test +2, integration_test/play_session_test.dart 13/13 exit 0 on iPhone 16, 16e, 16 Pro Max (iOS 18.6 simulators). Negative controls: old behaviour and an onPanCancel-only fix both FAIL the mid-drag cancel test. Synthetic cancel through the live binding, not an OS touch cancel (QA LIFECYCLE-LIVE). Tech Lead reproduced 2026-09-21 at clean HEAD cf747f8: melos analyze 0, format:check 0, 197 package + 243 app tests, device suite 13/13 exit 0 on iPhone 16.
- Evidence ID: F03.REDUCE-MOTION-FLAG
  * Scenario: every reduce-motion call site (home_screen, column_tutorial_overlay, completion_panel ×2, play_session_screen, puzzle_board) reacts to `reduceMotion` and to `disableAnimations`
  * Required Class: automated functional
  * Target / Environment: app widget tests with `FakeAccessibilityFeatures(reduceMotion: true)` and `(disableAnimations: true)`
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: None
  * Re-evaluation Trigger: F03-FE-REDUCEMOTION delivery
  * Blocks: F03 final acceptance
  * Result: PASS
  * Provenance / Note: 2026-09-21, working tree on HEAD 6ad8268 (uncommitted): reduce_motion_test 12, journey_home_test +6, column_tutorial_test +3, won_composition_test reduce-motion x2 flags; each site tested under FakeAccessibilityFeatures(reduceMotion) and (disableAnimations) with a no-signal control; negative control (helper reading only disableAnimations) fails every iOS variant. melos analyze 0, format:check 0 (155 files), 197 package + 243 app tests pass. Flags are faked; that iOS Settings flips reduceMotion is QA REDUCE-MOTION-RUNTIME. Tech Lead reproduced 2026-09-21 at clean HEAD cf747f8 (same gates).
- Evidence ID: F03.REDUCE-MOTION-RUNTIME
  * Scenario: with the real Settings toggle ON: F03 win (static hold → fade → panel, no glide/slide), F04 star reveal settled, F05 ring static
  * Required Class: runtime
  * Target / Environment: iPhone 16 simulator, Settings > Accessibility > Motion > Reduce Motion
  * Owner Role: QA
  * Prerequisite / External Decision: F03-FE-REDUCEMOTION delivered and Accepted (2026-09-21)
  * Re-evaluation Trigger: During F03-QA-REVERIFY2
  * Blocks: F03 final acceptance
  * Result: PASS
  * Provenance / Note: 2026-09-21 QA, HEAD 5be4dc6: real Settings > Accessibility > Motion > Reduce Motion ON (Prefer Cross-Fade row visible): F03 win = static amber row, ~300 ms hold, dock cross-fade, scrim + panel fade, at rest ~T0+0.66 s, F04 stars struck at once; F05 ring node static (8/8 identical frames) and tutorial ghost static; controls with Reduce Motion OFF: node breathes (8/8 distinct), ghost loops (8/8 distinct), full 940 ms sequence with glide/slide/staggered stars (qa.md E10-E14). Terminal 30/30 bloom not reached at runtime (widget-tested).
## Open Decision Gates

- Decision ID: F03.RUNTIME-LIMITS
  * Question: Rotation, live app-lifecycle-during-gesture and the AC9 drag highlight could not be produced on the simulator with the tooling QA had. How should F03.ROTATION, F03.LIFECYCLE-LIVE and F03.AC9-HIGHLIGHT be closed?
  * Options / Trade-offs: (A) grant the host that runs Claude Code macOS Accessibility (and Automation for System Events) so QA can rotate the simulator and interleave lifecycle events — independent evidence, small effort; (B) user runs a manual checklist on a physical iPhone — user-attested, not QA-verifiable; (C) accept simulator-only limits as a recorded residual risk
  * Recommendation: A
  * Blocks: F03 final QA acceptance and Done if unresolved; not F03-UI-WON, F03-FE-WON or F03-FE-INTEG
  * Blocking Scope: feature
  * Status: RESOLVED
  * Resolution: A — user chose Accessibility-enabled simulator automation (`Run Tech Lead. Decision: F03.RUNTIME-LIMITS — A`). Scope: only how F03.ROTATION, F03.LIFECYCLE-LIVE and F03.AC9-HIGHLIGHT are produced; it accepts no residual risk and waives no requirement. The permission itself is a user action that no agent can perform: until it is granted and QA's probe succeeds, those three items stay PENDING; if it is not granted by re-QA, Tech Lead asks again (B or C) rather than assuming.
  * Resolved At: 2026-09-20
  * Follow-up 2026-09-20: Tech Lead observed the permission granted (System Events reads Simulator's menu bar; it was denied with -1719 during the 2026-09-20 QA). QA still probes rotate / keystroke / HOME-while-touch-held itself before relying on it.
  * Recording note: the gate had been prepared as a planned (not yet OPEN) gate because a feature-scope OPEN gate blocks delivery activation; it is recorded directly as RESOLVED at the user's explicit instruction, so there was no OPEN match to close. Applied once.

## Blockers

None

## Next Action

Tech Lead: closure review of the final QA verdict (Approved with Notes, qa.md). Required before Done: reconcile board/system-state, decide the non-blocking notes (board shift/bounce under reduce motion; terminal 30/30 bloom and multi-touch not exercised at runtime), and record that Visual Scope none covers behaviour/accessibility only — the whole-surface visual evaluation stays in the Design Adoption Route and may reopen F03 as visual rework. Then release the rework-control lock (F05-QA-STRICT, F08 local evidence) and activate the next phase.

## Last Decision

2026-09-20 — QA Rejected F03 (F03-QA-01 win sequence/geometry, F03-QA-02 integration group 4). Tech Lead: (1) sequencing is an implementation defect — F03 §10, F03 ui-design and F04 ui-design already agree that the panel follows the ≤600 ms win sequence; (2) the F04 "winning row stays visible above a 56–66 % panel" line cannot hold for rows 1–4, so geometry goes to the UI Designer first, F03 `Won composition` wins over F04 §5 numbers where they conflict, F04 stays Done; (3) F03-QA-02 goes to Frontend/Mobile Developer; (4) rotation, live lifecycle and AC9 highlight need a target/tool the user controls → decision F03.RUNTIME-LIMITS; resolved A on 2026-09-20 (Accessibility-enabled simulator automation). Update 2026-09-21 (incident intake, ai-system upgrade cfd6b59): QA verdict (F03-QA-03/04, F03-QA-01/02 closed) reconciled; both defects routed to Frontend/Mobile Developer; feature normalized to the new schema with Visual Scope = none for THIS reopen (the reopen delta is behavioural: pointer-cancel handling and the Reduce Motion flag; no visual output is added or changed) — legacy F03 visuals were accepted under the legacy rubric and are re-evaluated for the whole surface by the design adoption program, which can reopen F03 as visual rework if the independent visual verdict is < 93 / any dimension < 8. Update 2026-09-20 (reconciliation): frontend delivery accepted (see Delivery Reconciliation), F03-QA-REVERIFY activated. Update 2026-09-20 (earlier): user resolved F03.RUNTIME-LIMITS = A. Retro-rework rule applied: no QA/DevOps owner is assigned to F05/F08 while F03 rework is open. No product criterion, package or app code was changed.

2026-09-21 — Tech Lead reconciled F03-FE-CANCEL / F03-FE-REDUCEMOTION at cf747f8: Delivery Review Accepted; F03-QA-REVERIFY2 activated. Decisions: (1) QA-03 root cause is a corrected finding (an accepted pan's PointerCancel arrives as onPanEnd; the Listener is required) — no contract change; QA's real OS app-switch repro decides. (2) Board shift/bounce under reduce motion: NO contract change; iOS keeps the functional move animation, Android keeps Flutter's collapse; recorded as an optional quality note (workflow-follow-ups.md), not a rework. (3) Visual Scope stays none for this reopen; the whole-surface visual program is the Design Adoption Route.

## Last Update

* Updated By: QA
* Timestamp: 2026-09-21
* Summary: F03-QA-REVERIFY2 done — QA Result Approved with Notes; F03-QA-03/04 closed on the real target; QA-owned evidence PASS; owner Tech Lead.

## Context & Follow-ups

F03 implementation is retained; F04/F05 integration code stays; the rework delivery is Accepted (see Delivery Reconciliation). Drift and QA history: e4311d3 (2026-09-08) changed lib/play; QA 2026-09-20 verified the interaction, persistence, navigation and misuse behavior on rev 7a907dd (PASS list in qa.md §0b/§4/§10) and rejected only the win moment and the device-form suite. Storage-full injection stays with F08 (F08.STORAGE). F05.SHARED-RUNTIME may reuse F03 provenance only for unchanged paths after F03-QA-REVERIFY. Non-blocking notes carried: N1 faint pin glyph on locked tile, N2 single active-session slot replaced by any puzzle open (debug row discards a Journey session), N3 Info.plist lists landscape, N4 elapsed/restartCount not on screen, N5 Drift multi-DB warning noise in integration helper, N6 simulator pointer is synthetic (threshold sweep / physical finger not done).

## History & Evidence References

* [Original orchestration](../../history/core-sync-2026-09-18/features/f03-puzzle-play-session/orchestration.md) — historical only, not a run queue.
* [QA report](qa.md) (2026-09-20, Rejected) and [contract](architecture.md) (§18 won-sequence authority) — findings F03-QA-01/02 and scenario detail.
* [Portfolio follow-ups](../../workflow-follow-ups.md) and [migration record](../../history/core-sync-2026-09-18/README.md).
* Canonical execution: role-execution-contract.md; historical next-command text does not authorize execution.

## Change Log

* 2026-09-18 — migrated state; see the immutable pre-migration snapshot for all earlier tasks, decisions and evidence.
* 2026-09-20 — Tech Lead: reconciled delivery, activated F03-QA-RUNTIME (final), added F03.CURRENT-REVISION.
* 2026-09-20 — QA: verdict Rejected (F03-QA-01, F03-QA-02).
* 2026-09-20 — Tech Lead: rework routed (UI Designer → Frontend/Mobile Developer → Tech Lead → QA); decision F03.RUNTIME-LIMITS prepared as a planned gate.
* 2026-09-20 — Tech Lead: F03.RUNTIME-LIMITS RESOLVED = A on the user's decision; Accessibility grant is a pending user action.
* 2026-09-20 — UI Designer: F03-UI-WON delivered (ui-design.md §16); F03-FE-WON and F03-FE-INTEG activated.
* 2026-09-20 — Frontend/Mobile Developer: F03-FE-WON and F03-FE-INTEG delivered; owner → Tech Lead.
* 2026-09-20 — Tech Lead: delivery reconciled (Accepted); Accessibility observed granted; F03-QA-REVERIFY Open, status In QA.
* 2026-09-20 — QA: re-verify verdict Rejected (F03-QA-03, F03-QA-04); F03-QA-01/02 closed.
* 2026-09-21 — Tech Lead: incident intake (ai-system upgrade): verdict reconciled, F03-FE-CANCEL / F03-FE-REDUCEMOTION opened, visual/QA-plan schema fields added.
* 2026-09-21 — Frontend/Mobile Developer: F03-FE-CANCEL + F03-FE-REDUCEMOTION delivered (frontend.md); root cause of QA-03 corrected (onPanEnd, not onPanCancel).
* 2026-09-21 — Tech Lead: delivery reconciled (Accepted, cf747f8); F03-QA-REVERIFY2 activated; F03 status In QA, owner QA.
* 2026-09-21 — QA: F03-QA-REVERIFY2 final verdict Approved with Notes (qa.md); F03-QA-03/04 closed; owner -> Tech Lead.

## Delivery Reconciliation (Tech Lead, 2026-09-20, HEAD cf8d8f0)

1. **Task coverage.** F03-UI-WON → ui-design.md §16 (Direction A "The answer docks", rubric self-review 92). F03-FE-WON → `won_composition.dart` (timeline + geometry), `docked_row.dart`, `_PlayBody` coordinator in `play_session_screen.dart`, `PuzzleBoard.rowVacated`, `CompletionPanel` density/startReveal/spineGlow. F03-FE-INTEG → integration group 4 rewritten. Delivery commit cf8d8f0 = exactly the 9 files frontend.md lists.
2. **Contract compliance (architecture.md §18 "Won-sequence authority").** Sequencing: panel and scrim absent before T0+600 ms (unit tests + on-screen timeline test; mutation check proved the assertions live), dock 600–840, panel 680–940, star reveal at rest. Persistence/controller timing untouched (still at `won`). Geometry: dock fixed and centred in the free zone, panel top ≥ 0.36 H, reduce-motion path, ghost slot, single glow — asserted by 25 widget tests across rows 0–4 × Perfect/2★ × 390/440 widths, 393×852, text scale 1.3, F04 variants, Retry. Constraints carried (12 % dim, no blur).
3. **Authority reconciliation.** §16 wins over F04 ui-design §5 where they conflict, as decided; F04 ACs/copy/star/best logic unchanged; F04 stays Done. One F04-owned defect fixed in passing (Close tap target 42 → 44 pt, needed for §16.5 rule 5) — accepted.
4. **Preserved behavior.** Resume, back/exit, Retry/Next/Close, unlock and column tutorial paths unchanged by design; all 181 earlier app tests unchanged and green. Because `play_session_screen.dart` changed by ~385 lines, QA must re-spot-check these on the real app rather than reuse the 2026-09-20 PASS blindly.
5. **Evidence quality.** Reproduced by the Tech Lead at HEAD cf8d8f0: `melos run analyze` exit 0, `format:check` exit 0, `melos run test` 197 package + 214 app pass, device suite `flutter test integration_test/play_session_test.dart -d iPhone 16` 12/12 exit 0 (49 s). Frontend also ran it on iPhone 16e and 16 Pro Max (12/12 each). Harness/in-memory DB limits are declared. The developer's real-app recording is orientation, not QA evidence.

Decisions on the delivery's notes: (a) row-0 strip left visible between docked row and panel — accepted as specified; QA judges it visually against the rubric, no rework unless QA finds a fail condition. (b) the 30 ms L→R amber stagger from the original ui-design was never implemented (pre-existing, not in scope) — recorded in workflow-follow-ups.md as a non-blocking quality note; QA must not invent a blocker but may report it. (c) `PanelDensity` engagement at large text is not asserted by tests — QA checks it at a large Dynamic Type size. (d) latent: a session restored straight into `won` (unreachable in production because the snapshot is cleared at `won`) would show no docked row until a rebuild — recorded as a note only.

## Delivery Reconciliation (Tech Lead, 2026-09-21, HEAD cf747f8, clean tree)

1. **Task coverage.** F03-FE-CANCEL → `PuzzleBoard` `Listener(onPointerCancel)` + `_abort`, `PlaySessionController.cancelDrag`. F03-FE-REDUCEMOTION → `lib/reduce_motion.dart` `reduceMotionRequested()` at six sites (`home_screen`, `column_tutorial_overlay`, `completion_panel` ×2, `play_session_screen`, `puzzle_board`). Whitespace-insensitive diff of `app/lib` read: production delta is ~45 lines; nothing else changed.
2. **Contract.** §12 (cancel is a clean abort, no Move) and §18 / ui-design §16.2 (reduce-motion path) now hold in code; controller/persistence timing, threshold/tie band, shift/bounce, undo/restart untouched. F04/F05: only the flag source changed; ACs unchanged.
3. **Root cause (corrected).** QA's hypothesis (`_onPanCancel`) was incomplete: an accepted pan's PointerCancel is delivered as `onPanEnd`. Two negative controls (old behaviour; `onPanCancel`-only fix) fail the mid-drag cancel test; the Listener fix passes. Accepted.
4. **Evidence reproduced by the Tech Lead at cf747f8:** `melos run analyze` exit 0 (one pre-existing `looplet_solver` info), `format:check` exit 0 (155 files), `melos run test` 197 package + 243 app pass, `flutter test integration_test/play_session_test.dart -d iPhone 16` 13/13 exit 0. FE also ran 16e and Pro Max 13/13. Automated only: the widget/integration cancel is synthetic and the reduce-motion flags are faked — QA owns the real-OS proof.
5. **Clarifications.** Board shift/bounce under reduce motion: no authority requires it; not reworked (optional quality note). Multi-touch (a cancelled second finger while another tracks) would also abort — outside the ACs, QA may note it if observed.

## Current QA Brief (F03-QA-REVERIFY2 — activated 2026-09-21, rev cf747f8; COMPLETED, see qa.md)

Read: qa.md §8 (F03-QA-03/04 + the mechanism correction above), frontend.md "F03-FE-CANCEL / F03-FE-REDUCEMOTION", architecture.md §12/§18, prompts/qa.md modules core + client-ui + stateful-flow, prompt-qa-evidence-reuse-standard.md. First `node ai-system/tools/qa-preflight.mjs ai-system` (must PASS) and reset nothing else. Plan: QA Scope client-only · Stage final · Modules core, client-ui, stateful-flow · Depth full · Evidence Reuse allowed (fingerprints below) · Visual Scope none (no visual-quality module and no visual verdict; report any visible regression as a finding).

**Fingerprint.** Prior verified rev c0cba44 → cf747f8: the only app changes are `home_screen.dart`, `journey/column_tutorial_overlay.dart`, `play/play_session_controller.dart` (+`cancelDrag`), `play/play_session_screen.dart` (reduce-motion read), `play/widgets/puzzle_board.dart` (Listener + `_abort`; +re-indent), `rating/completion_panel.dart` (2 reads), new `reduce_motion.dart`, plus tests. No change to `main.dart`, `ios/`, pubspec, packages, persistence, content.

**EXECUTE this run (independent, real target — iPhone 16, iOS 18.6):**
1. F03-QA-03 / LIFECYCLE-LIVE: hold a drag ≥ 3 s (1 Hz screenshot log proving the touch is down and the row lifted), then a real OS interruption — `simctl launch` another app (QA's original repro, ×3), plus a second trigger if achievable (Lock button during the hold; an edge system gesture). Expect: no move, `MOVES` unchanged, idle; sqlite `appliedMoves` unchanged; cold relaunch unchanged. Idle HOME/app switch stays unchanged.
2. Gesture regression through real touch: normal swipe commits and persists; sub-threshold no-op; diagonal tie; a release **outside the plate** still commits; rejected column move bounces; AC9 lift + rail highlight (held-touch capture).
3. F03-QA-04 / REDUCE-MOTION-RUNTIME: real Settings > Accessibility > Motion > Reduce Motion ON (confirm the "Prefer Cross-Fade" row), relaunch: F03 win (static amber row + seam, hold, fade to dock, scrim + panel fade, ≈ 660 ms, no glide/slide), F04 reveal end state (stars/markers struck at once), F05 home ring static with an in-progress level and no terminal bloom, column tutorial ghost static if reachable. Then Reduce Motion OFF: the full 940 ms sequence returns (one win). Video/frame evidence for the motion claims.
4. Gates on the current tree: analyze, format:check, `melos run test`, integration suite on ≥ 2 widths, debug simulator build.

**REUSED (fingerprint unchanged):** rotation/portrait lock, kill-relaunch resume and persistence, chevron / edge-swipe / replaced-route exit, F04 variants and regular-motion won frames (spot-check rows 0 and 4 only), misuse/tampered-cache set. **INVALIDATED:** LIFECYCLE-LIVE, AC9-HIGHLIGHT, every reduce-motion path, RUNTIME-MATRIX, CURRENT-REVISION. Report each item as EXECUTED THIS RUN / REUSED / INVALIDATED / PENDING; a simulator-unavailable item is PENDING, never PASS.
