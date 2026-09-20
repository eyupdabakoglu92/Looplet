# F03 — puzzle-play-session: Orchestration

## Feature ID

F03

## Current Status

In QA

## Current Owner

QA

## Next Role

QA

## Active Task Ledger

- [x] Task ID: F03-QA-RUNTIME | Assigned Role: QA | Status: Done | Summary: Final-stage runtime QA on rev 7a907dd returned verdict Rejected (qa.md 2026-09-20); residual scenarios live in Pending Evidence | Depends On: -
- [x] Task ID: F03-UI-WON | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-20 (ui-design.md §16 Won composition, rubric self-review 92). F03-QA-01 geometry: deliver a `Won composition` section in F03 ui-design.md so the winning row + docked seam stay visible above the F04 panel for rows 0–4 and every F04 variant, per architecture.md §18 (2026-09-20); see Current UI Brief | Depends On: -
- [x] Task ID: F03-FE-WON | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-20 (frontend.md; F03.WIN-LAYOUT 33/33). F03-QA-01: implement win-sequence-then-panel sequencing (panel not before T0+600 ms) and the UI Designer's Won composition; add widget/golden layout assertions; update frontend.md | Depends On: F03-UI-WON
- [x] Task ID: F03-FE-INTEG | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-20 (12/12 exit 0 on 3 simulator widths). F03-QA-02: make integration_test/play_session_test.dart group 4 complete and exit 0 on a live simulator on 2 widths; no product-semantics change | Depends On: -
- [ ] Task ID: F03-QA-REVERIFY | Assigned Role: QA | Status: Open | Summary: Re-verify F03 final on the changed win path per Planned QA Re-verify Brief; independent verdict | Depends On: F03-FE-WON, F03-FE-INTEG

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

None

## Release Scope

none

## Release Result

None

## Pending Evidence

- Evidence ID: F03.RUNTIME-MATRIX
  * Scenario: architecture.md §16/§18 critical journeys (AC1–AC11) on the required device matrix, real app root. 2026-09-20 QA PASSED AC1–AC8 and AC10 (real-kill resume via CONTINUE and debug entry), tampered cache on the real store and the misuse set. Residual, tracked as separate items below: F03.LIFECYCLE-LIVE, F03.AC9-HIGHLIGHT, F03.INTEG-DEVICE. Re-run of the win path is required after F03-FE-WON (F03-QA-REVERIFY)
  * Required Class: runtime
  * Target / Environment: iOS simulators, one small + one large logical width (iPhone 16e 390 / iPhone 16 Pro Max 440; iPhone 16 393), iOS 18.6, real app entry (`main.dart`)
  * Owner Role: QA
  * Prerequisite / External Decision: F03-FE-WON and F03-FE-INTEG delivered; residual items closed via the F03.RUNTIME-LIMITS = A route
  * Re-evaluation Trigger: After F03-FE-WON / F03-FE-INTEG delivery is Accepted
  * Blocks: F03 final acceptance; F05 shared play/navigation/persistence scope
  * Result: PENDING
  * Provenance / Note: partial PASS, rev 7a907dd, 2026-09-20 (qa.md §0b/§4/§10). Reusable by F05/F08 only for unchanged paths after re-verification

- Evidence ID: F03.VISUAL
  * Scenario: Win choreography readability (F03-QA-01) and locked/frozen tile + thaw confirmation; amber seam bar legible in greyscale
  * Required Class: manual
  * Target / Environment: Simulator; win-frame capture (video + frame sheet) on real reachable winning rows plus the Perfect and non-Perfect variants; debug row L5 = smoke-tr-05 locked pivot, L6 = smoke-tr-06 frozen tile
  * Owner Role: QA
  * Prerequisite / External Decision: F03-UI-WON and F03-FE-WON delivered
  * Re-evaluation Trigger: After F03-FE-WON delivery is Accepted
  * Blocks: F03 final acceptance; applicable F05 shared visuals
  * Result: FAIL
  * Provenance / Note: 2026-09-20, rev 7a907dd: sheet starts ≈ +320 ms after settle and covers the winning row by ≈ +400 ms; Perfect variant clips row 0. Locked pivot and frozen tile PASS. Greyscale seam only approximated by frame luminance

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
  * Provenance / Note: 2026-09-20, working tree on HEAD a136a9b: `flutter test integration_test/play_session_test.dart -d <UDID>` 12/12 PASS, exit 0 on iPhone 16 (393×852, 56 s), iPhone 16e (390×844, 74 s) and iPhone 16 Pro Max (440×956, 57 s), iOS 18.6. Earlier 2026-09-20 QA run: group 4 hung 16m46 s (F03-QA-02). Root cause: frames stop while paused on a live binding; group 4 now never pumps while paused, asserts the settled state from the store at pause, 90 s hang guard. Harness uses in-memory DB, not the production root

- Evidence ID: F03.LIFECYCLE-LIVE
  * Scenario: App paused while a touch is held (mid-drag) and within the ~190 ms shift on a live target; resulting state is settled, no lost/half move
  * Required Class: runtime
  * Target / Environment: rotation/lifecycle-capable target or tool (physical iPhone, or simulator UI automation with accessibility permission)
  * Owner Role: QA
  * Prerequisite / External Decision: F03.RUNTIME-LIMITS = A (RESOLVED 2026-09-20). Accessibility observed granted by the Tech Lead (2026-09-20 read-only probe); QA first probes it itself (osascript click Simulator > Device > Rotate Left, a keystroke) and records the result
  * Re-evaluation Trigger: Accessibility grant confirmed by QA's probe, during F03-QA-REVERIFY
  * Blocks: F03 final acceptance
  * Result: PENDING
  * Provenance / Note: 2026-09-20 QA could not interleave HOME with a held touch; widget mirror (§17.4) passes, idle HOME round trip PASS

- Evidence ID: F03.AC9-HIGHLIGHT
  * Scenario: Row/column lift + rail highlight visible while a drag is in progress (AC9)
  * Required Class: runtime
  * Target / Environment: simulator/device with a screenshot taken during a held touch
  * Owner Role: QA
  * Prerequisite / External Decision: F03.RUNTIME-LIMITS = A (RESOLVED 2026-09-20); same Accessibility grant and QA probe as F03.ROTATION (needs a held touch plus an interleaved HOME)
  * Re-evaluation Trigger: Accessibility grant confirmed by QA's probe, during F03-QA-REVERIFY
  * Blocks: F03 final acceptance
  * Result: PENDING
  * Provenance / Note: automated `trackingAxis` + controller `tracking` phase pass; visual not captured

- Evidence ID: F03.ROTATION
  * Scenario: Portrait lock remains effective under OS/device rotation
  * Required Class: manual
  * Target / Environment: Simulator or device able to rotate; qa.md §17 scenario 6
  * Owner Role: QA
  * Prerequisite / External Decision: F03.RUNTIME-LIMITS = A (RESOLVED 2026-09-20). Accessibility observed granted by the Tech Lead (2026-09-20 read-only probe); QA first probes it itself (osascript click Simulator > Device > Rotate Left, a keystroke) and records the result
  * Re-evaluation Trigger: Accessibility grant confirmed by QA's probe, during F03-QA-REVERIFY
  * Blocks: F03 final acceptance
  * Result: PENDING
  * Provenance / Note: 2026-09-20 NOT RUN (assistive access denied, osascript −1719). Static: main() setPreferredOrientations([portraitUp]); iPhone Info.plist still lists LandscapeLeft/Right, so the runtime call is the only guard

- Evidence ID: F03.BACK
  * Scenario: Chevron, system back and edge-swipe/exit behavior on the current navigation code (post-F05 `_popToCaller`)
  * Required Class: manual
  * Target / Environment: Simulator; re-spot-check after F03-FE-WON because play_session_screen.dart changes
  * Owner Role: QA
  * Prerequisite / External Decision: F03-FE-WON delivered
  * Re-evaluation Trigger: After F03-FE-WON delivery is Accepted
  * Blocks: F03 final acceptance; F05 shared navigation
  * Result: PASS
  * Provenance / Note: 2026-09-20 QA rev 7a907dd: chevron, iOS edge-swipe, replaced-route exit → `/`, chevron hidden in won. Literal direct entry to `/play` unreachable at runtime (no URL scheme). Spot-check again after the win-path change

- Evidence ID: F03.CURRENT-REVISION
  * Scenario: Automated F03 suites, analyzer, format and iOS build on the current tree
  * Required Class: automated functional
  * Target / Environment: current working tree
  * Owner Role: QA
  * Prerequisite / External Decision: None
  * Re-evaluation Trigger: F03-FE-WON / F03-FE-INTEG delivery changes the tree
  * Blocks: F03 final acceptance
  * Result: PASS
  * Provenance / Note: 2026-09-20 rev 7a907dd: analyze 0, format 0, 197 package + 181 app tests pass, debug simulator build 0. Valid for that revision only; re-run after the rework

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

Run QA on F03-QA-REVERIFY (QA Stage = final) using the Current QA Brief. Independent verdict; every outcome returns to Tech Lead. F05 and F08 stay queued behind this.

## Last Decision

2026-09-20 — QA Rejected F03 (F03-QA-01 win sequence/geometry, F03-QA-02 integration group 4). Tech Lead: (1) sequencing is an implementation defect — F03 §10, F03 ui-design and F04 ui-design already agree that the panel follows the ≤600 ms win sequence; (2) the F04 "winning row stays visible above a 56–66 % panel" line cannot hold for rows 1–4, so geometry goes to the UI Designer first, F03 `Won composition` wins over F04 §5 numbers where they conflict, F04 stays Done; (3) F03-QA-02 goes to Frontend/Mobile Developer; (4) rotation, live lifecycle and AC9 highlight need a target/tool the user controls → decision F03.RUNTIME-LIMITS; resolved A on 2026-09-20 (Accessibility-enabled simulator automation). Update 2026-09-20 (reconciliation): frontend delivery accepted (see Delivery Reconciliation), F03-QA-REVERIFY activated. Update 2026-09-20 (earlier): user resolved F03.RUNTIME-LIMITS = A. Retro-rework rule applied: no QA/DevOps owner is assigned to F05/F08 while F03 rework is open. No product criterion, package or app code was changed.

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-20
* Summary: Frontend delivery reconciled and accepted at HEAD cf8d8f0; F03-QA-REVERIFY activated with an updated brief; feature status In QA.

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

## Current UI Brief

Task F03-UI-WON. Read: F03 ui-design.md (won, tile states), F04 ui-design.md §4–§5 (timeline + panel geometry), F03 architecture.md §10 and §18 "Won-sequence authority" (2026-09-20), qa.md §8 F03-QA-01, design-doctrine.md, premium-ui-rubric.md. Do not write code.

Problem (QA, iPhone 16 393×852 pt, rev 7a907dd): the F04 panel rises with no delay, so the win stagger/seam/bloom are not seen; row centres sit at 36 / 44 / 52 / 60 / 68 % of screen height; the panel top is at ≈ 42 % (non-Perfect) and ≈ 38 % (Perfect, `HARİKA` plate), so rows 2–4 are always covered and Perfect clips row 0. Evidence stills: qa.md §8.

Deliver in F03 `ui-design.md` a new section `Won composition` (F03's `won` treatment wins over F04 §5 geometry where they conflict):
1. Geometry that keeps the winning row and the docked amber seam visible above the panel at rest for winning rows 0–4, for every variant (first-clear, matched, newBest, Perfect), widths 390–440 pt, heights 844–956 pt, with all F04 panel content unclipped and tappable (≥ 44 pt), OS text scaling tolerated. Explore, choose and justify (e.g. board translate/scale, panel height cap, lifting/docking the winning row); no backdrop blur; mid-tier 60 fps budget; keep the 12 % dim recede.
2. Timeline with numbers: T0 = settle; win sequence T0…T0+600 ms; panel starts ≥ T0+600 ms (~260 ms slide); star reveal after the panel is up; behavior under reduce-motion; input stays locked, chevron hidden.
3. Per-state behavior on Retry / Close / Next Level (how the board returns to idle).
4. A premium-rubric self-review of the won moment and a testable statement of the visibility rule that the Frontend Developer can assert (rects, not pixels).
Non-goals: F04 product ACs, star/best logic and copy; new features; controller/persistence semantics. If no geometry works on the smallest device, state the fallback (panel may cover the row only after the full ≥ 600 ms sequence) and raise `Needs Tech Lead Clarification`. Handoff status: Ready for Frontend/Mobile Developer.

## Delivery Reconciliation (Tech Lead, 2026-09-20, HEAD cf8d8f0)

1. **Task coverage.** F03-UI-WON → ui-design.md §16 (Direction A "The answer docks", rubric self-review 92). F03-FE-WON → `won_composition.dart` (timeline + geometry), `docked_row.dart`, `_PlayBody` coordinator in `play_session_screen.dart`, `PuzzleBoard.rowVacated`, `CompletionPanel` density/startReveal/spineGlow. F03-FE-INTEG → integration group 4 rewritten. Delivery commit cf8d8f0 = exactly the 9 files frontend.md lists.
2. **Contract compliance (architecture.md §18 "Won-sequence authority").** Sequencing: panel and scrim absent before T0+600 ms (unit tests + on-screen timeline test; mutation check proved the assertions live), dock 600–840, panel 680–940, star reveal at rest. Persistence/controller timing untouched (still at `won`). Geometry: dock fixed and centred in the free zone, panel top ≥ 0.36 H, reduce-motion path, ghost slot, single glow — asserted by 25 widget tests across rows 0–4 × Perfect/2★ × 390/440 widths, 393×852, text scale 1.3, F04 variants, Retry. Constraints carried (12 % dim, no blur).
3. **Authority reconciliation.** §16 wins over F04 ui-design §5 where they conflict, as decided; F04 ACs/copy/star/best logic unchanged; F04 stays Done. One F04-owned defect fixed in passing (Close tap target 42 → 44 pt, needed for §16.5 rule 5) — accepted.
4. **Preserved behavior.** Resume, back/exit, Retry/Next/Close, unlock and column tutorial paths unchanged by design; all 181 earlier app tests unchanged and green. Because `play_session_screen.dart` changed by ~385 lines, QA must re-spot-check these on the real app rather than reuse the 2026-09-20 PASS blindly.
5. **Evidence quality.** Reproduced by the Tech Lead at HEAD cf8d8f0: `melos run analyze` exit 0, `format:check` exit 0, `melos run test` 197 package + 214 app pass, device suite `flutter test integration_test/play_session_test.dart -d iPhone 16` 12/12 exit 0 (49 s). Frontend also ran it on iPhone 16e and 16 Pro Max (12/12 each). Harness/in-memory DB limits are declared. The developer's real-app recording is orientation, not QA evidence.

Decisions on the delivery's notes: (a) row-0 strip left visible between docked row and panel — accepted as specified; QA judges it visually against the rubric, no rework unless QA finds a fail condition. (b) the 30 ms L→R amber stagger from the original ui-design was never implemented (pre-existing, not in scope) — recorded in workflow-follow-ups.md as a non-blocking quality note; QA must not invent a blocker but may report it. (c) `PanelDensity` engagement at large text is not asserted by tests — QA checks it at a large Dynamic Type size. (d) latent: a session restored straight into `won` (unreachable in production because the snapshot is cleared at `won`) would show no docked row until a rebuild — recorded as a note only.

## Current QA Brief (F03-QA-REVERIFY — final, client-only)

Environment: simulators iPhone 16e (390) / 16 (393) / 16 Pro Max (440), debug build of HEAD, real `main.dart` root; Accessibility is granted — probe it first.

1. **F03-QA-01 closure (F03.VISUAL, F03.WIN-LAYOUT cross-check).** Frame-capture (`simctl io recordVideo` + frame sheet) the won moment on every winning row reachable in the bundle (debug smoke L1 row 0, L6 row 2; Journey levels via CONTINUE — find and record other rows) with Perfect and non-Perfect results and first-clear / matched / newBest variants (Retry loops). Verify: amber row visible for the win sequence, dock glide, panel after ≥ 600 ms, docked row + seam visible above the panel at rest, star reveal after rest, nothing clipped. Judge the residual dimmed row-0 strip and the missing amber stagger against ui-design.md and the rubric; report, do not invent blockers.
2. **F03-QA-02 / F03.INTEG-DEVICE.** Run the device suite yourself on ≥ 2 simulator widths; exit 0 required.
3. **Large text / reduce motion.** Set a large Dynamic Type size (`xcrun simctl ui <UDID> content_size accessibility-large` or similar) and confirm the panel is unclipped, controls tappable and the docked row still clear; if feasible enable Reduce Motion and confirm the static hold → fade → panel sequence.
4. **Route A scenarios (F03.ROTATION, F03.LIFECYCLE-LIVE, F03.AC9-HIGHLIGHT).** Probe Accessibility (rotate the simulator; send a keystroke; press HOME while a touch is held). Then: rotation attempt leaves the portrait layout unchanged; HOME during a held drag and within ~190 ms of a shift → settled state, no lost/half move; capture the row/column lift and rail highlight during a held drag. If the probe fails record Runtime Validation Pending with the exact error — no static substitution. Greyscale: use an OS colour filter if it can be driven; otherwise say so.
5. **Re-spot-check unchanged paths on the real app** (play_session_screen.dart changed): chevron, iOS edge-swipe, replaced-route exit after Next Level, Close, Retry, kill/relaunch resume (CONTINUE and debug entry), tampered thaw cache on the real store, a sub-threshold / rejected / multi-touch / diagonal set, locked pivot and frozen tile. Reuse the 2026-09-20 PASS only where the path is provably unchanged, with the reason.
6. Record command, target, exit, counts and revision for every claim; independent verdict; return to Tech Lead for every outcome. Storage-full injection stays out (F08.STORAGE).
