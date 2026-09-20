# F03 — puzzle-play-session: Orchestration

## Feature ID

F03

## Current Status

Rework

## Current Owner

Tech Lead

## Next Role

Tech Lead

## Active Task Ledger

- [ ] Task ID: F03-QA-RUNTIME | Assigned Role: QA | Status: Blocked | Summary: QA verdict Rejected (F03-QA-01, F03-QA-02) with runtime scenarios still pending; re-run after fixes/decision. Final-stage independent runtime/manual verification of F03 on the current revision (evidence F03.RUNTIME-MATRIX, VISUAL, ROTATION, BACK, CURRENT-REVISION) per Current QA Brief; return an independent verdict | Depends On: -

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

Rejected

## Release Scope

none

## Release Result

None

## Pending Evidence

- Evidence ID: F03.RUNTIME-MATRIX
  * Scenario: architecture.md §16/§18 critical journeys (AC1–AC11) on the required device matrix; real gesture window, no double count, lifecycle and exact resume after a real OS-level kill/relaunch
  * Required Class: runtime
  * Target / Environment: iOS simulators, one small + one large logical width (available: iPhone 16e and iPhone 16 Pro Max, iOS 18.6; iPhone 16 is booted). Real app entry (`main.dart`), not widget-test provider overrides. integration_test/play_session_test.dart plus the manual scope in qa.md
  * Owner Role: QA
  * Prerequisite / External Decision: None outstanding; simulators and Flutter/Xcode toolchain were seen present on 2026-09-20. Prior widget/build success is not this evidence
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F03 final acceptance; F05 shared play/navigation/persistence scope
  * Result: PENDING
  * Provenance / Note: partial. PASS (runtime, simulators iPhone 16/16e/16 Pro Max, rev 7a907dd, 2026-09-20): AC1–AC8, AC10 real-kill resume via CONTINUE and debug entry, tampered cache on the real store, misuse set (qa.md §4/§10); integration groups 1–3 10/10. Remaining: paused mid-drag / mid-animation on a live target; integration group 4 hangs (F03-QA-02); AC9 highlight not captured at runtime. Elapsed/restartCount unobservable in UI

- Evidence ID: F03.VISUAL
  * Scenario: Win choreography/greyscale seam readability and locked/frozen tile + thaw confirmation
  * Required Class: manual
  * Target / Environment: Simulator manual pass; qa.md §17 note 1 scenario 5 (debug row L5 = smoke-tr-05 locked pivot, L6 = smoke-tr-06 frozen tile)
  * Owner Role: QA
  * Prerequisite / External Decision: Same runtime build and content; no paid deployment required
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F03 final acceptance; applicable F05 shared visuals
  * Result: FAIL
  * Provenance / Note: (win choreography timing/occlusion, F03-QA-01: rev 7a907dd, video win.mov + 40 ms frame sheet 2026-09-20). Locked pivot (ring, stays put) and frozen tile (frost, stays put, thaws on win) PASS; greyscale seam legibility only approximated by frame luminance conversion (thin light-grey bar visible; amber-vs-cream fill collapses)

- Evidence ID: F03.ROTATION
  * Scenario: Portrait lock remains effective under OS/device rotation
  * Required Class: manual
  * Target / Environment: Simulator; qa.md §17 note 1 scenario 6
  * Owner Role: QA
  * Prerequisite / External Decision: Runtime target; if rotation cannot be driven with the available tooling, record the exact limit and leave PENDING
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F03 final acceptance
  * Result: PENDING
  * Provenance / Note: NOT RUN: Simulator rotation could not be driven (assistive access denied, osascript -1719). Static only: main() setPreferredOrientations([portraitUp]); iPhone Info.plist still lists LandscapeLeft/Right, so the runtime call is the only guard

- Evidence ID: F03.BACK
  * Scenario: Chevron, system back and edge-swipe/direct-entry behavior on the CURRENT navigation code (F05 changed `_popToCaller`: pop when a caller exists, otherwise go home)
  * Required Class: manual
  * Target / Environment: Simulator; qa.md §17 note 1 scenario 7, re-verified against the post-F05 `/play` exit rules (f05 architecture.md §8)
  * Owner Role: QA
  * Prerequisite / External Decision: Runtime target and reachable play route (home CONTINUE and debug row)
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F03 final acceptance; F05 shared navigation
  * Result: PASS
  * Provenance / Note: (runtime, iPhone 16, rev 7a907dd, 2026-09-20): chevron pop to `/`, iOS left edge-swipe to `/`, chevron hidden in won, exit from a Next-Level replaced route lands on `/` with progress `1 / 30`, resume after chevron keeps the snapshot. Literal direct entry to `/play` with an empty stack is not reachable at runtime (no URL scheme); nearest equivalent (replaced route) passes and `_popToCaller` else-branch was source-inspected

- Evidence ID: F03.CURRENT-REVISION
  * Scenario: The 2026-09-06 approval (308 tests) predates F04/F05 edits to lib/play (commit e4311d3: completion panel/Journey unlock/back routing). Re-establish that the automated F03 suites, analyzer and iOS build hold on the current tree
  * Required Class: automated functional
  * Target / Environment: Current working tree; app/test/play/*, app/integration_test/play_session_test.dart, workspace analyze/format, iOS build as QA judges applicable
  * Owner Role: QA
  * Prerequisite / External Decision: None. Tech Lead's 2026-09-20 pre-QA run (`flutter test` in app/: 181 passed) is orientation only, not QA evidence
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F03 final acceptance
  * Result: PASS
  * Provenance / Note: (automated functional, 2026-09-20): `melos run analyze` exit 0, `melos run format:check` exit 0, `melos run test` exit 0 = 197 package + 181 app tests, 0 failed; `flutter build ios --debug --simulator` exit 0. Release build not re-run. NOTE: integration suite (device form) fails in group 4 — tracked under F03.RUNTIME-MATRIX / F03-QA-02, not here

## Open Decision Gates

None

## Blockers

* F03-QA-01 — win sequence cut off / winning row occluded by the completion panel (UI Design Mismatch, Medium). Authority decision + fix required; see qa.md §8/§18.
* F03-QA-02 — integration_test group 4 does not complete on a live simulator (Regression Risk, Medium). Fix required; see qa.md §8/§18.

## Next Action

Run Tech Lead: QA verdict is Rejected. Decide win-sequence/panel-geometry authority for F03-QA-01 (F03 ui-design/§10 vs F04 handoff), route the fix (Frontend/Mobile Developer; UI Designer only if a new geometry handoff is needed) and F03-QA-02 (Frontend/Mobile Developer), keep F03.ROTATION and the mid-drag/mid-animation lifecycle scenarios PENDING with an explicit target/tool or a recorded decision gate, then re-activate F03 final QA. F05 and F08 stay queued.

## Last Decision

2026-09-20 — activate F03 as the single QA feature. F03 is the dependency root of F05 (F05.SHARED-RUNTIME reuses F03.RUNTIME-MATRIX/BACK/VISUAL), all F03 evidence is producible now on available simulators with no developer task or paid prerequisite, and F03 carries no storage-failure criterion (that is F08 AC7, tracked as F08.STORAGE). Delivery Review = Accepted on artifact + diff reconciliation only; it does not import the 2026-09-06 verdict. No product, contract or code file changed.

## Last Update

* Updated By: QA
* Timestamp: 2026-09-20
* Summary: F03-QA-RUNTIME executed on rev 7a907dd (simulators iPhone 16/16e/16 Pro Max): verdict Rejected; evidence results recorded; qa.md replaced.

## Context & Follow-ups

F03 implementation is retained. Reconciliation (Tech Lead, 2026-09-20): F03-FE9 tests and qa.md §5–§17 map every AC to an automated scenario; contract §16/§18 honored per qa.md; no `looplet_*` package change. Drift since QA: e4311d3 (2026-09-08) added Journey-source resolution in playSessionSetupProvider, `_resolveJourneyUnlock` after the completion write, and `_popToCaller` via GoRouter, so preserved behavior for AC1–AC11 and back/exit paths must be re-checked, not assumed. The completion panel is now F04's. Storage-full/write-failure injection is not an F03 acceptance criterion; it stays in F08 (F08.STORAGE) and must not be claimed by F03 QA. Runtime provenance captured here is reusable by F05.SHARED-RUNTIME and F08.LOCAL-RESUME only for the identical scope and revision. Non-blocking notes carried: looplet_solver solver.dart curly-braces lint (F06), integration_test device-matrix run is part of F03.RUNTIME-MATRIX now.

## History & Evidence References

* [Original orchestration](../../history/core-sync-2026-09-18/features/f03-puzzle-play-session/orchestration.md) — historical only, not a run queue.
* [QA report](qa.md) and [contract](architecture.md) — retained unchanged; qa.md §17 is the scenario source.
* [Portfolio follow-ups](../../workflow-follow-ups.md) and [migration record](../../history/core-sync-2026-09-18/README.md).
* Canonical execution: role-execution-contract.md; historical next-command text does not authorize execution.

## Change Log

* 2026-09-18 — migrated state; see the immutable pre-migration snapshot for all earlier tasks, decisions and evidence.
* 2026-09-20 — Tech Lead: reconciled delivery, activated F03-QA-RUNTIME (final), added F03.CURRENT-REVISION.
* 2026-09-20 — QA: verdict Rejected (F03-QA-01, F03-QA-02); ROTATION and lifecycle scenarios pending.

## Current QA Brief

Environment: run the real app on simulators (small = iPhone 16e, large = iPhone 16 Pro Max; iPhone 16 already booted), debug build so the home `debug` row (L1, L2, L4, L5, L6 = smoke puzzles) is reachable; also enter through home CONTINUE to reach a real Journey level. Use `flutter test integration_test/play_session_test.dart -d <simulator UDID>` for the repeatable form. Record command, target, exit code, pass/fail/skip counts and revision for every claim (prompt-evidence-integrity-standard.md §1).

1. F03.RUNTIME-MATRIX — journeys (start → action → visible result): open a puzzle (AC1); horizontal swipe → row shifts one cell, MOVES +1 (AC2); vertical swipe → column, +1 (AC3); sub-threshold swipe → nothing (AC4); second drag ~60 ms into the ~190 ms shift → dropped, MOVES ticks once (AC5, the "0 double-registered moves" metric); 3 undos then a 4th → inert, no prompt (AC6); Restart → reset, no dialog, Restart away from grid (AC7); win → lock, highlight, seam bar, then the completion panel (AC8); swipe-begin highlight (AC9); leave/return, background, and a real OS kill (terminate the app process) then relaunch → exact resume of grid, MOVES, undo pips, restarts, elapsed (AC10); transient valid word mid-animation ≠ win (AC11). Measure gesture threshold/dominant-axis behavior on both widths; do not assert it from source.
2. Misuse/edge: diagonal near-tie → horizontal; off-screen release; two-finger touch → first pointer only; rapid same-row swipes each count post-settle; fast flick vs slow drag → exactly one cell; engine-rejected move (disabled column) → silent bounce; Restart and Undo during animation and during won; direct entry to `/play` with an empty stack; tampered `kv['active_session'].thawedFrozenCells` on smoke-tr-06 → tile renders frozen (re-derived, not trusted) — a real-app check, since the automated form uses in-memory DB and provider overrides.
3. F03.VISUAL — win choreography reads as "earned"; amber seam bar legible with colour OFF (greyscale/Increase Contrast); smoke-tr-05 locked pivot (brass ring + pin) never moves while its row rotates; smoke-tr-06 frozen tile (frost + crystal border) plays the thaw cross-fade when its row forms a valid word. Judge against ui-design.md Direction A and premium-ui-rubric.md fail conditions.
4. F03.ROTATION — rotation attempt leaves layout unchanged (portrait lock). Also inspect the iOS Info.plist orientation keys and main() lock as supporting static evidence; static alone does not close a runtime scenario.
5. F03.BACK — chevron pop, iOS system back and left edge-swipe return to the caller; chevron hidden in won; direct entry falls back safely to `/` per the post-F05 exit rule; after completing a Journey level the exits resolve to `/` with progress ring updated. Confirm each path on the current code.
6. F03.CURRENT-REVISION — re-run play/journey/rating/persistence automated suites, analyze and format on the current tree; note what changed since 2026-09-06 (e4311d3) and confirm AC1–AC11 behavior preserved through the F04 panel and F05 unlock/back changes. Reuse unchanged valid evidence with reason; scope regression to changed files.
7. Scope limits: storage-full/write-failure injection is F08 AC7 (F08.STORAGE), not an F03 criterion; do not approve or fail F03 on it, and do not claim it covered. F04 rating correctness and F05 curve/content are their own acceptance; report only F03-visible interactions.
8. Verdict rules: any scenario not actually executed stays PENDING → Runtime Validation Pending naming it; Approved with Notes cannot accept a missing required scenario. A reproduced defect → Rejected with symptom, journey, entry path and evidence; root-cause remarks are hypotheses only. Return to Tech Lead for every outcome; update only your own scenarios' Pending Evidence with provenance.
