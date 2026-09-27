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

- [x] Task ID: F03-UI-D1 | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-27 — ui-design.md §1–§14 rewritten for the Loop Glass Play surface; §16 won composition kept byte-for-byte (legacy until D2). 28 renders under design/: the audit's D1 missing states 1–10, plus idle (D1 corrections), loading, keyboard focus, 16e / Pro Max variants, the 1.3× text cap and motion stills. Executable motion prototype design/src/D1-motion-prototype.html (lift + settle, thaw, tutorial ghost; ?rm=1, ?t=). Rulings applied: C-5 (hint pill above the HUD, ≥ 4 pt clearance measured on three devices at 1.0× and 1.3×; ghost hides on touch-down), C-9 (1.3× cap), C-10 (180 ms thaw), locked/frozen treatments, copy. D1 acceptance list §11.5; manifest §12b. NTLC §14: the text cap applied to the whole of Play (deviates from the §19.3 (1) hint example), design-layer edits inside D1, and informational items. No code | Depends On: -
- [x] Task ID: F03-FE-D1 | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-28 — every non-won Play state on Loop Glass (LoopBackdrop; chevron + SEVİYE NN; MovesCard; HEDEF DÖNGÜ + RailTiles; BoardCard + TileFace; lift with rim, card-edge rails, rest at 42 %, wrap ghost 30 → 100 %; thaw 180 ms cross-fade; UndoPill + 44-pt restart; skeleton loading; error card + LimePill → /), the F05 tutorial re-skin (pill between board and HUD, ghost hides on touch-down and returns after 600 ms idle; §19.8 (3) fallback on after a 3.93-pt device measurement), the §19.8 (2) design-layer additions, drawn icons (no Material icon left), strings and semantics, reduced-motion paths. Tests: melos analyze / test green (app 405), integration_test 13/13 on the iPhone 16 simulator. frontend.md Visual Parity Evidence: runtime screenshots on the 16 / 16e / Pro Max, parity composites and measurements (≤ 0.83 pt vs the D1 renders), four videos, text sweep and Reduce Motion. NTLC-1: the won dock moved onto the goal (the D1 header left no §16.3 zone); NTLC-2: three design-layer edits beyond the §19.8 (2) list | Depends On: F03-UI-D1
- [ ] Task ID: F03-QA-D1 | Assigned Role: QA | Status: Open | Summary: ACTIVATED 2026-09-28 (Frontend checkpoint passed: Delivery Review Accepted, gate Ready for QA, rulings architecture.md §19.9). Final-stage independent visual QA of D1 (architecture.md §19.7): runtime rubric ≥ 93 with every dimension ≥ 8 and no fail condition on the non-won Play states and the F05 overlay; the §11.5 acceptance list on the iPhone 16 / 16e / Pro Max; regression of AC1–AC11 and F05 AC4 / AC11; the won moment against §16 as amended by §19.9 (1); text sweep to AX5; Reduce Motion on and off; Android stated as a limit. See Current Brief | Depends On: F03-FE-D1

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

## Visual Scope

existing-parity

## Design Foundation

ai-system/project-authority/design-foundation.md

## Visual Quality Gate

Ready for QA

## Visual Evidence

Selected-source renders for this surface, all in features/f00-design-foundation/design/:
* S-01b-play-idle-today.png, S-02-play-lifted-row.png, S-03-play-locked-frozen.png, S-07-tutorial-column.png;
* the device variants S-v-*, and S-91-components.png.

Their manifest is features/f00-design-foundation/ui-design.md § Visual Evidence Manifest.

The shipped-app baseline (615e94c) is conformance-audit.md §12 in the same folder: AUD-RS-08…18, AUD-A11Y-02 and AUD-A11Y-05, and AUD-PC-03…07.

D1 handoff records (2026-09-27, UI Designer) are in ui-design.md §12b Visual Evidence Manifest:
* selected-source D1-00…D1-12 and the D1-V device variants;
* accessibility D1-10 / D1-10b;
* motion-prototype MP-D1 and MP-D1-S.

The artefacts are in features/f03-puzzle-play-session/design/. The Tech Lead verified them at the 2026-09-27 checkpoint (Ready for Implementation).

Runtime parity records (2026-09-28, Frontend/Mobile Developer; frontend.md § Visual Parity Evidence) are in features/f03-puzzle-play-session/design/runtime-d1/:
* runtime-screenshot RT-* on the iPhone 16 (every §12a row), the 16e and the Pro Max (idle, tutorial, column drag);
* parity-comparison PC-*.jpg with parity-measurements.txt;
* runtime-video RV-* (row and column lift, thaw, tutorial ghost, Reduce Motion);
* accessibility records for the text sweep and Reduce Motion.

The tooling is in design/src/ (parity-d1.sh, measure-d1.swift, pill-clearance-d1.swift, video-d1.swift, seed-sim.sh). The Tech Lead verified the parity records at the 2026-09-28 checkpoint: the measurements reproduce number for number, and composites were inspected (architecture §19.9). The QA record is pending (see Pending Evidence).

## QA Modules

core, client-ui, visual-quality, stateful-flow

## Regression Depth

full

## Evidence Reuse

allowed

## Pending Evidence

- Evidence ID: F03.D1-HANDOFF
  * Scenario: The Loop Glass Play handoff for Phase D1 — F03 ui-design.md with real renders for every D1 state in architecture.md §19.2, including the tutorial HUD (§19.3 (2)), the thaw (§19.3 (3)) and an AX5 Play frame (§19.3 (1))
  * Required Class: static inspection of rendered artefacts
  * Target / Environment: features/f03-puzzle-play-session/ui-design.md and its render files (393×852, plus the 390×844 and 440×956 variants)
  * Owner Role: UI Designer
  * Prerequisite / External Decision: None
  * Re-evaluation Trigger: F03-UI-D1 delivery
  * Blocks: Visual Quality Gate = Ready for Implementation; F03-FE-D1
  * Result: PASS
  * Provenance / Note: 2026-09-27 UI Designer, HEAD 7239492 + working tree. Contents: ui-design.md §1–§14 (§16 kept byte-for-byte, verified against HEAD); 28 PNG renders in features/f03-puzzle-play-session/design/, from design/src/gen-d1.mjs + render-d1.sh (HTML/CSS → headless Chrome @2x, same tokens and geometry as F00 gen-s.mjs); the motion prototype design/src/D1-motion-prototype(-thaw|-ghost).html. Content: real Journey grids L4, L5, L23, L26; the L23 thaw state was cross-checked with the engine rule and the provisional dictionary. Manifest in ui-design.md §12b. Generated design artefacts, not runtime; Android not rendered.

- Evidence ID: F03.D1-PARITY
  * Scenario: The runtime implementation matches the D1 handoff on the canonical simulators — every §19.2 state side by side with its render; a screen recording of row lift, column lift and thaw; OS text sizes up to AX5 with no clipping or overlap (§19.3 (1)); Reduce Motion on and off; the automated suites and integration_test green
  * Required Class: runtime + automated functional
  * Target / Environment: iOS Simulator 18.6 — iPhone 16 (393×852) primary, 16e (390×844) and 16 Pro Max (440×956)
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: F03.D1-HANDOFF accepted (gate Ready for Implementation)
  * Re-evaluation Trigger: F03-FE-D1 delivery
  * Blocks: Visual Quality Gate = Ready for QA; F03-QA-D1
  * Result: PASS
  * Provenance / Note: 2026-09-28 Frontend/Mobile Developer, HEAD 991584c + the F03-FE-D1 working tree, debug build on iOS Simulator 18.6 — iPhone 16 D0011CE7, 16e 6DBDFD97, Pro Max 02FDE776. Runtime screenshots cover every §12a row on the 16, plus idle / tutorial / column drag on the 16e and the Pro Max. Parity: ≤ 0.83 pt against every D1 render (19 measured pairs); token colours within ΔE2000 1.5; one gradient patch at 3.35 (F00 LoopBackdrop's circular light). Videos: row + column lift, thaw (L23), tutorial ghost, Reduce Motion ON. Text sweep default / xxxL / AX5 with every Play text at the 1.3× cap; hint-pill clearance ≥ 6.27 pt after the §19.8 (3) fallback (3.93 pt before it on the 16e). Suites: melos analyze and test green (app 405), dart format 0 changed in app / packages / tools, integration_test 13/13 on the iPhone 16. Gaps stated in frontend.md: the keyboard focus ring is covered by a widget test only (this host cannot inject Tab keys into the simulator); Android not run (ANDROID-CI-EVIDENCE). **Accepted at the Tech Lead checkpoint 2026-09-28** (architecture §19.9): scope clean, suites re-run green, seven negative runs caught, parity measurements reproduced. NTLC-1 and NTLC-2 were accepted; the focus-ring sub-state is accepted on the automated Tab-trigger class (the F00 E21 precedent).

- Evidence ID: F03.D1-VISUAL-QA
  * Scenario: An independent final-stage QA verdict on the D1 Play surface — a rubric score from real runtime (≥ 93, every dimension ≥ 8, no fail condition), full regression of AC1–AC11 and F05 AC4/AC11, a text-scale sweep and Reduce Motion
  * Required Class: runtime
  * Target / Environment: iOS Simulator 18.6, iPhone 16 / 16e / Pro Max; Android capture stated as a limit (ANDROID-CI-EVIDENCE)
  * Owner Role: QA
  * Prerequisite / External Decision: F03.D1-PARITY accepted (gate Ready for QA)
  * Re-evaluation Trigger: F03-QA-D1 activation
  * Blocks: Visual Quality Gate = Passed; F03 Done; D2 activation
  * Result: PENDING
  * Provenance / Note: -

## Open Decision Gates

None

## Blockers

None

## Next Action

Run QA on F03-QA-D1 — the independent final-stage visual QA of Phase D1 (Current Brief below; architecture.md §19.7 and §19.9).

After QA:
* Approved or Approved with Notes, with the rubric ≥ 93 → the Tech Lead closes D1 (Visual Quality Gate Passed, F03 Done) and activates D2.
* Rejected → rework routes through the Tech Lead.

## Last Decision

2026-09-28 (Frontend checkpoint) — the Tech Lead reconciled F03-FE-D1 (commit b8b5f60) and accepted it.

**Task coverage:** every fix-scope item 1–7 of the F03-FE-D1 brief maps to files in frontend.md §3. There are no partial items.

**Contract compliance:**
* route, args, gestures, input lock, persistence and the F05 gate / ack are unchanged — the suites and integration_test are green;
* the §19.3 and §19.8 rulings are applied, including the §19.8 (3) fallback after a device measurement of 3.93 pt;
* no token, dependency or global-doc change;
* no Material icon left.

**Evidence, checked independently:**
* `melos run analyze` clean; `flutter test` 405 passed.
* **Seven negative runs**, each rule broken and restored from git, all caught: hint clearance (A-1), glyph cap (A-2), ghost hide (A-6), thaw (A-5), the panel floor under the docked row, `HAMLE` at the settle, undo at quota 0 (AC6).
* `measure-d1.swift` reproduces all 19 parity measurements; composites were inspected.

**Rulings** (architecture §19.9):
* NTLC-1 — the won dock onto the goal is accepted for the D1 hybrid period, with the amended §16.3 / §16.5 (1) rules; `ui-design.md` §16 banner points to it.
* NTLC-2 — `LoopBackButton`, `TileFace.iconScale` and the `UndoPill` dot animation are accepted in D1 scope.
* The frontend.md §4 reconciliation items are accepted as implemented.
* Focus-ring evidence class: the automated Tab trigger (F00 E21 precedent).
* Informational: NTLC-3 → follow-up MOVESCARD-CAP-MARGIN; NTLC-4 → follow-up CI-FORMAT-GATE (the CI format step is red on a pre-existing F00 QA probe, independent of F03); NTLC-5 → `ui-design.md` §5 corrected; NTLC-6 → D2 (A-2).

**State:** Delivery Review Accepted; Visual Quality Gate Ready for QA; Current Status In QA; F03-QA-D1 Open; owner → QA.

The previous decision (the 2026-09-27 visual-gate checkpoint) and the F03-FE-D1 brief are archived byte-for-byte in history/f03-puzzle-play-session-2026-09-27/orchestration-at-fe-d1-delivery.md.

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-28
* Summary: Frontend checkpoint — F03-FE-D1 accepted after independent verification (suites re-run, seven negative runs caught, parity reproduced); rulings architecture §19.9 (NTLC-1 won dock onto the goal, NTLC-2 design-layer edits); Visual Quality Gate Ready for QA; F03-QA-D1 activated for QA.

## Context & Follow-ups

* **Prior closure (2026-09-21):** behaviour and accessibility only; that final QA verdict stays the historical record.
* **Still valid as regression inputs:** the non-blocking notes in workflow-follow-ups.md (OPTIONAL-QUALITY-NOTES). The 30 ms stagger and the result's text-scale density belong to D2.
* **Design Adoption Route:** workflow-follow-ups.md.
* **Audit:** features/f00-design-foundation/conformance-audit.md.

## History & Evidence References

* [QA report](qa.md) (2026-09-21, Approved with Notes), [contract](architecture.md) (§12, §18, §19), [UI design](ui-design.md) (§16), [frontend delivery](frontend.md).
* [Closure record with the full working orchestration](../../history/f03-closure-2026-09-21/orchestration.md), [terminal orchestration before the D1 reopen](../../history/f03-puzzle-play-session-2026-09-27/orchestration-before-phase-d1.md) and [original pre-migration orchestration](../../history/core-sync-2026-09-18/features/f03-puzzle-play-session/orchestration.md) — historical only, not a run queue.
* [Portfolio follow-ups](../../workflow-follow-ups.md) (Design Adoption Route); [Phase C audit](../f00-design-foundation/conformance-audit.md).
* Canonical execution: role-execution-contract.md.

## Change Log

* 2026-09-18 — migrated state; see the immutable pre-migration snapshot.
* 2026-09-20 to 2026-09-21 — win-sequence rework, F03-QA-01..04, final QA; full log in the closure record.
* 2026-09-21 — Tech Lead: closure review; status Done.
* 2026-09-27 — Tech Lead: reopened as Design Adoption Phase D1 (visual rework, existing-parity) after the Phase C audit; architecture.md §19; F03-UI-D1 Open, F03-FE-D1 and F03-QA-D1 Queued; owner → UI Designer.
* 2026-09-27 — UI Designer: F03-UI-D1 delivered; task Done; F03.D1-HANDOFF PASS; Delivery Review = Pending; owner → Tech Lead.
  * **Handoff:** ui-design.md §1–§14 rewritten, §16 kept verbatim; 28 renders + motion prototype; acceptance list §11.5.
  * **NTLC:** §14.1 text cap on the whole of Play; §14.2 design-layer edits.
* 2026-09-27 — Tech Lead: D1 visual-gate checkpoint.
  * **Verified:** F03-UI-D1 reconciled — HTML regenerates byte-identical, manifest paths exist, §16 identical, hint clearance measured at 4.5 / 4.0 pt.
  * **Decided:** Delivery Review Accepted; Visual Quality Gate Ready for Implementation; architecture §19.8 rulings.
  * **Next:** F03-FE-D1 Open; owner → Frontend/Mobile Developer.
* 2026-09-28 — Frontend/Mobile Developer: F03-FE-D1 delivered; task Done; F03.D1-PARITY PASS; Delivery Review = Pending; owner → Tech Lead.
  * **Code:** Loop Glass Play (every non-won state), F05 tutorial re-skin, §19.8 (2) design-layer additions, drawn icons, strings and semantics; the §19.8 (3) hint-pill fallback switched on after the device measurement.
  * **Evidence:** frontend.md § Visual Parity Evidence; design/runtime-d1/; tooling in design/src/.
  * **NTLC:** NTLC-1 won dock onto the goal; NTLC-2 design-layer edits beyond the list; NTLC-3 … NTLC-6 informational.
  * **History:** the pre-D1 frontend.md is archived byte-for-byte as history/f03-puzzle-play-session-2026-09-27/frontend-before-phase-d1.md.
* 2026-09-28 — Tech Lead: Frontend checkpoint.
  * **Verified:** scope clean; analyze clean and 405 tests passed on re-run; seven negative runs caught; the 19 parity measurements reproduce.
  * **Decided:** Delivery Review Accepted; architecture §19.9 rulings (NTLC-1, NTLC-2, reconciliation items, focus-ring evidence class); Visual Quality Gate Ready for QA; follow-ups MOVESCARD-CAP-MARGIN and CI-FORMAT-GATE logged.
  * **Next:** Current Status In QA; F03-QA-D1 Open; owner → QA. The F03-FE-D1 brief is archived as history/f03-puzzle-play-session-2026-09-27/orchestration-at-fe-d1-delivery.md.

## Current Brief

**F03-QA-D1 — independent final-stage visual QA of the Loop Glass Play (Design Adoption Phase D1; contract: architecture.md §19, rulings §19.8 and §19.9)**

**Surface under test:**
* every non-`won` `/play` state, the loading state and the load error;
* the F05 column-tutorial overlay (cross-feature);
* the design-layer additions of §19.8 (2) and §19.9 (2);
* the won moment's dock geometry (§19.9 (1)).

Delivery: `frontend.md` (commit `b8b5f60`); evidence in `design/runtime-d1/`.

**Authority:**
* `ui-design.md` §1–§14 — the §11.5 acceptance list, the §12a matrix, the §5 motion table (with its Tech Lead correction);
* §16 as amended by architecture §19.9 (1);
* architecture §6–§13 (behaviour) and §19;
* F00 `ui-design.md` (tokens, components);
* `design/visual-quality-gate.md`, `premium-ui-rubric.md`, `design-doctrine.md`.

**QA plan:**
* QA Scope client-only; QA Stage final; Release Scope none.
* QA Modules: core, client-ui, visual-quality, stateful-flow.
* **Regression Depth full**, because:
  * the whole Play surface was re-rendered;
  * a cross-feature overlay (F05) and shared design-layer components changed;
  * the won geometry moved.
* **Evidence Reuse allowed.** Fingerprint: the Frontend's automated suites and integration run were taken at `b8b5f60`. Reuse them only if the QA revision's `app/` tree is unchanged since. The Frontend's runtime captures are comparison inputs, never a substitute for QA's own runtime scoring.

**Critical journeys** (start → action → visible result) on the iPhone 16 (primary), with the 16e and Pro Max where noted:
1. **Home CONTINUE → L5 idle:** chevron + `SEVİYE 05`, `HAMLE 0`, `HEDEF DÖNGÜ` + BULUT, the board card, the undo pill at 55 %, restart 44 pt (§11.5 (1)–(4); all three devices).
2. **Row drag, held:**
   * rim + glow + side rails, the rest at 42 %, the wrap ghost at 30 % clipped to the card;
   * on release the line settles (≤ 1.5 % overshoot) and `HAMLE` +1 appears at the settle;
   * the ghost reaches 100 %, and the rim, rails and dim fade out (§11.5 (5), §5).
3. **Column drag on L4:** rails on the top and bottom edges (all three devices). A sub-threshold drag → the line returns, no move (AC4).
4. **Rejected move** (a column on a rows-only level, L1–L3): the 140 ms bounce; `HAMLE` unchanged.
5. **L26 locked + frozen:** lock icons, snowflakes and dashes; readable in greyscale (§11.5 (6)).
6. **L23 thaw** (seed `["R1","D3","U4"]`, then swipe column 4 up): the 180 ms cross-fade and the snowflake shrink; under Reduce Motion it is instant (§11.5 (7)).
7. **Undo quota 3 → 0:** a spent dot dims (120 ms); the pill is disabled at 0 moves and at quota 0; the semantics say "n / 3 hak"; no prompt (AC6, §11.5 (8)).
8. **Restart:** no dialog; the dots refill (AC7).
9. **Tutorial, L4–6 with the ack unset:**
   * the pill sits between the board and the HUD with ≥ 4 pt clearance at 1.0× and at the 1.3× cap, on all three devices;
   * the ghost hides on touch-down and returns after 600 ms of idle; undo and restart stay usable;
   * the first column move fades the pill and persists the ack (F05 AC4);
   * a force-quit before the gate → it re-shows (F05 AC11) (§11.5 (9)).
10. **Loading → loaded:** the board card rect does not move; no spinner (§11.5 (12)).
11. **Load error:** corrupt a level asset in the simulator bundle (Frontend used level 07; restore afterwards). Expect the card + `loopBreak` + pill → `/`; system back → the caller; no raw exception text (§11.5 (13)).
12. **Leave and resume:** the chevron, system back and the edge swipe → Home with the snapshot kept; CONTINUE resumes the same state; a kill / relaunch resumes too (AC10).
13. **Won moment:** e.g. debug L01, a 1-move Perfect, and a 2★ via one wasted move, at 1.0× and 1.3×:
    * nothing of the panel before T0 + 600 ms;
    * the row docks onto the goal while the rail tiles fade out;
    * the panel never covers the row; its controls are ≥ 44 pt;
    * Retry brings the rail back (§16 as amended; §16.5 (6)).

**Misuse, invalid entry, stale state:**
* gestures during a settle, a bounce or `won` → dropped, never queued (AC5); multi-touch → first pointer only; a diagonal tie → horizontal;
* taps on undo / restart during a settle → no effect;
* backgrounding mid-drag or mid-settle → never a torn move (§12);
* Next Level / Close / Retry from the panel;
* the tutorial on a level outside 4–6 → not shown; once acknowledged → never again.

**Text scale and accessibility** (§11.5 (10), (15)):
* default / xxxLarge / AX5 on L26 and on the tutorial: every Play text at the 1.3× cap, no clipping or overlap;
* the load-error pill label reflows at AX5 and its column scrolls;
* VoiceOver: back "Geri, Seviye 26"; the rail as one node; `HAMLE`; undo "…, n / 3 hak"; the hint announced once; the ghost excluded; "Yükleniyor" only after 300 ms;
* contrast (the lowest pair is `HAMLE` at 4.9 : 1) and 44-pt targets;
* focus ring: check it at runtime if the environment can send hardware keys; otherwise the §19.9 (4) evidence class stands as a stated limit.

**Reduce Motion** (§11.5 (11)): check on and off. The iOS `reduceMotion` signal is checked at runtime; Android `disableAnimations` is widget-tested only.

**Inherited or known limits.** These are not F03-FE-D1 defects unless QA's evidence says otherwise, and QA may raise any of them as a finding:
* Android not run (ANDROID-CI-EVIDENCE); physical-finger gesture accuracy;
* the legacy won / F04 panel overflow at AX5 (A-2, D2);
* Home in the legacy look (D3, hybrid period C-8);
* the top-right ground light at ΔE 3.35 (F00 `LoopBackdrop` approximation);
* the red CI format step on a pre-existing F00 QA probe (CI-FORMAT-GATE).

**Startup impact:** none — no entry point, bootstrap, persistence-open or root-navigation change. The `/play` resume after a kill is covered as journey 12.

**Runtime method:**
* debug build on iOS Simulator 18.6 — iPhone 16 `D0011CE7`, 16e `6DBDFD97`, Pro Max `02FDE776`;
* `design/src/seed-sim.sh <udid> <level> [moves] [ack] [undos]` seeds Journey progress, the active-session snapshot and the tutorial ack; Home CONTINUE then opens the level;
* content size: `xcrun simctl ui <udid> content_size …`;
* Reduce Motion: `xcrun simctl spawn <udid> defaults write com.apple.Accessibility ReduceMotionEnabled -int 1|0`, then relaunch;
* recordings: `xcrun simctl io … recordVideo`;
* restore the simulator settings afterwards.

**Exit criteria (Approved):**
* an independent runtime rubric ≥ 93 with every dimension ≥ 8 and no `premium-ui-rubric` fail condition, scored on the non-`won` Play states and the F05 overlay. The won moment is judged only against §16 as amended (hybrid period);
* every §11.5 item verified at runtime (the focus ring may rest on its stated evidence class);
* AC1–AC11 and F05 AC4 / AC11 regressions pass;
* the text sweep and Reduce Motion pass;
* Android stated as a limit.

On approval, QA sets F03.D1-VISUAL-QA to PASS, and the Tech Lead then sets the Visual Quality Gate to Passed. Findings are welcome wherever the evidence contradicts this brief.

**Deliver:**
* `qa.md` — the final-stage report with the rubric table, runtime evidence records in the gate schema, and findings;
* the F03.D1-VISUAL-QA record;
* the local orchestration update, per the QA prompt.

## Earlier briefs

* F03-UI-D1 (UI Designer, done 2026-09-27) — archived byte-for-byte in history/f03-puzzle-play-session-2026-09-27/orchestration-at-ui-d1-delivery.md.
* F03-FE-D1 (Frontend/Mobile Developer, done 2026-09-28) — archived byte-for-byte in history/f03-puzzle-play-session-2026-09-27/orchestration-at-fe-d1-delivery.md.
