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

- [x] Task ID: F03-UI-D2 | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-28 — ui-design.md §16 rewritten as the D2 handoff (replaces F03-UI-WON; §1–§14 D1 unchanged apart from cross-references). The full-screen result as a flow column on the S-04 anchors (layout table for 393 / 390 / 440), all 10 variants (C-4 markers and badge precedence, CTA weighting, no-optimal, Next not wired, level 30), the win sequence re-timed on the D1 board with special tiles (C-11), the board → result and result → Play transitions with reduced paths. 58 renders in design/ (12 result, 6 text-scale incl. the 1.3× cap on three devices and AX5, 3 device variants, 37 motion stills) + 5 contact sheets; 5 executable prototypes (rows 0 / 2 / 4 from BFS-verified solutions, a synthetic frozen case, retry); a timeline self-test (rest 940 / reduced 660, first result pixel 685 ms, retry 360 / 160). D2 acceptance list §16.11.1; manifest §16.12b. NTLC §16.14: retry transition A vs B needs a selection record (non-blocking), the re-timed chrome fade, copy items, design-layer additions. No code | Depends On: -
- [x] Task ID: F03-FE-D2 | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-28 (commit 67d9ecb) — the D2 win sequence, board → result transition, full-screen `ResultView` and retry transition A implemented from `app/lib/design` per architecture §20 / §20.7 (C1–C3); `docked_row.dart`, `board_tile.dart`, `won_composition.dart` and `CompletionPanel` deleted; design-layer additions `TileFace.answer`, `StarRow.revealMs`, `ScrollBand` with component tests; tests updated (§20.4 + four F05) and added (`won_sequence_test`, `result_view_test`, `result_components_test`); app suite 503 passed, analyze / format clean, integration_test 13 / 13 on the iPhone 16. `frontend.md` Visual Parity Evidence: runtime screenshots, parity composites, 10 recordings with the frame-timing table, the text sweep and Reduce Motion on the three simulators. NTLC-D2-1 … 3 ruled in architecture §20.8. Accepted at the Tech Lead's parity checkpoint 2026-09-28 | Depends On: F03-UI-D2
- [x] Task ID: F03-QA-D2 | Assigned Role: QA | Status: Done | Summary: DONE 2026-09-28 — verdict **Rejected** (qa.md, final, client-only, HEAD 86c7318; app/ = f5641d2f…, the brief's fingerprint). Independent runtime rubric **92 / 100** (lowest Accessibility and Inclusive Quality 8; no fail condition). Blocking F03-QA-D2-01: after a live OS text-size reduction while the result is scrolled at AX5, the ScrollBand stays visible at offset 0 and dims the `HARİKA` badge and the back button (§16.11.1 (12)). Everything else passed at runtime on the iPhone 16 / 16e / Pro Max: the other 17 §16.11.1 items (C2 measured with QA's own tools, first moved frame +616…+619), F04 AC1–AC10 (AC9 automated), F05 AC1 / AC12, F03 AC8 / AC11, lifecycle mid-sequence (system back, background, kill), Reduce Motion on / off, D1 regression | Depends On: F03-FE-D2
- [x] Task ID: F03-FE-D2R | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-28 (HEAD 3cd4a3b + working tree; `app/` diff SHA-1 262864be, two files) — F03-QA-D2-01 fixed: `ResultView` recomputes the band from `position.pixels` on every scroll and on every depth-0 `ScrollMetricsNotification` (`result_view.dart`); `ScrollBand` untouched. 9 new widget tests (AX5 scrolled → 1.0× / 1.3× → band 0, badge and back clear; → 2.1× → band = clamped offset / 12) fail 9 / 9 on the old code and with the listener detached, pass with the fix; app 512 passed, analyze / format clean, integration_test 13 / 13 on the iPhone 16. Runtime on the 16 / 16e / Pro Max: after AX5 → scrolled → xxxL and → `large`, the band region equals the offset-0 control (0.000 % differ, 6 / 6 pairs; QA's pre-fix capture differs 51 %). Win + retry smoke on the 16: timeline as in D2 (first result pixel +714, pill rest +947 / +964 capture jitter, retry board +330). `frontend.md` § F03-FE-D2R; evidence design/runtime-d2r/ | Depends On: F03-QA-D2
- [ ] Task ID: F03-QA-D2R | Assigned Role: QA | Status: Queued | Summary: Re-QA of D2 after F03-FE-D2R and the Tech Lead checkpoint: final stage, full regression with fingerprint-based reuse of the F03-QA-D2 evidence (§20.9 (5)); the text-size paths E-T1 … E-T5 on the three devices, a win + retry smoke with video, the app suite, full rubric re-score (≥ 93, every dimension ≥ 8, no fail condition) | Depends On: F03-FE-D2R

## Open Tasks

None

## Handoff Plan

None

## Delivery Review

Pending

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

## Visual Scope

motion-critical

## Design Foundation

ai-system/project-authority/design-foundation.md

## Visual Quality Gate

Ready for Implementation

## Visual Evidence

Selected-source records for this surface, all in features/f00-design-foundation/design/:
* the result `S-04` (perfect), `S-04b` (new best), `S-05` (2★);
* the transition frames `S-08 … S-14` and the reduced frames `S-15`, `S-16`, taken from the executable prototype `design/src/S-transition-prototype.html` (F00 ui-design §11);
* the device variants `S-v-*` and the component sheet `S-91-components.png`.

Their manifest is features/f00-design-foundation/ui-design.md § Visual Evidence Manifest.

The shipped baseline is conformance-audit.md §6 and §12 (`design/audit/cur-won-*`, `cur-result-*`, `cur-a11y-ax5-result.png`, the pairs `pair-08 … pair-14`), captured at 615e94c. The pre-D2 runtime (legacy won moment over the D1 board, dock on the goal rail per §19.9 (1)) is in features/f03-puzzle-play-session/qa/d1/ (QA-16-31 … 35, QV-16-won-L01-perfect.mp4) and qa/d1r/ (QA-16-L01-won-ax5-rest.jpg).

D1 records (the Play surface this transition starts from; gate Passed 2026-09-28) are listed in the archived orchestration history/f03-puzzle-play-session-2026-09-28/orchestration-before-phase-d2.md.

D2 handoff records (2026-09-28, UI Designer) are in ui-design.md §16.12b Visual Evidence Manifest:
* selected-source D2-01…D2-09b, D2-11, D2-12 and the D2-V device variants;
* accessibility D2-10 (1.3× cap on three devices) and D2-10-AX5;
* motion-prototype MP-D2 (design/src/D2-motion-prototype*.html), MP-D2-S (D2-M-* stills) and MP-D2-CHECK (design/src/timeline-check-d2.txt).

The artefacts are in features/f03-puzzle-play-session/design/. Accepted at the Tech Lead's visual-gate checkpoint on 2026-09-28 (architecture §20.7): the retry transition A is the adopted design.

D2 implementation parity records (2026-09-28, Frontend/Mobile Developer, commit 67d9ecb; `frontend.md` § Visual Parity Evidence) are in features/f03-puzzle-play-session/design/runtime-d2/:
* runtime-screenshot RT-16-D2-01 … 09b, RT-16-L30-terminal, RT-16e-*, RT-promax-*, RT-16e-D2-12 (pressed);
* parity-comparison PC-D2-*.jpg + parity-measurements.txt;
* runtime-video RV-16-r2 / -warm / -premount, RV-16-r0 (L26), RV-16-r4, RV-16e-r4, the retries and both reduced paths, with the frame-timing table;
* accessibility A11Y-16-sweep (large → AX5, scrolled), A11Y-16e, A11Y-pm.

Accepted at the Tech Lead's parity checkpoint on 2026-09-28 (architecture §20.8): parity reproduced byte for byte, frame timing within 1–3 ms apart from two corrected cells.

D2 QA records (2026-09-28, QA, HEAD 86c7318, `app/` `f5641d2f…`) are in `qa.md` §1 and features/f03-puzzle-play-session/qa/d2/ (QA-*.jpg, QV-*.mp4, QS-*.jpg, tools in qa/d2/src). Verdict Rejected, 92 / 100 (architecture §20.9). The gate is back at Ready for Implementation for the F03-FE-D2R rework; the D2 handoff acceptance (§20.7) stands.

## QA Modules

core, client-ui, visual-quality, stateful-flow

## Regression Depth

full

## Evidence Reuse

allowed

## Pending Evidence

- Evidence ID: F03.D1-EVIDENCE (consolidated; full text archived: [orchestration-before-phase-d2.md](../../history/f03-puzzle-play-session-2026-09-28/orchestration-before-phase-d2.md))
  * Scenario: Design Adoption Phase D1 — Loop Glass Play: F03.D1-HANDOFF, F03.D1-PARITY, F03.D1-VISUAL-QA (superseded), F03.D1R-PARITY, F03.D1R-VISUAL-QA
  * Owner Role: UI Designer, Frontend/Mobile Developer and QA
  * Result: PASS
  * Provenance / Note: D1 closed 2026-09-28 — final QA F03-QA-D1R Approved with Notes, 93 / 100, gate Passed (architecture §19.12). Kept as a pointer: D2's QA reuses the D1 Play evidence only where the D2 diff leaves the Play surface unchanged.

- Evidence ID: F03.D2-HANDOFF
  * Scenario: The D2 handoff — F03 ui-design.md with real renders for every §20.2 variant (incl. the audit's D2 list 11–18, rows 0 and 4, a special-tile row, AX5) and an executable motion prototype of the win sequence, the board → result and result → Play transitions and their reduced paths, re-timed on the D1 board geometry
  * Required Class: static inspection of rendered artefacts + executable prototype
  * Target / Environment: features/f03-puzzle-play-session/ui-design.md and its render / prototype files (393 × 852, plus 390 × 844 and 440 × 956)
  * Owner Role: UI Designer
  * Prerequisite / External Decision: None (rulings architecture §20.3)
  * Re-evaluation Trigger: F03-UI-D2 delivery
  * Blocks: Visual Quality Gate = Ready for Implementation; F03-FE-D2
  * Result: PASS
  * Provenance / Note: 2026-09-28 UI Designer, HEAD 489606d + working tree (committed 6352a75). ui-design.md §16; 58 PNG renders + 5 contact sheets in features/f03-puzzle-play-session/design/ from design/src/gen-d2.mjs + render-d1.sh; executable prototypes design/src/D2-motion-prototype(-row0|-row4|-frozen|-retry).html; timeline self-test design/src/timeline-check-d2.txt. Generated design artefacts, not runtime; Android not rendered. **Accepted by the Tech Lead 2026-09-28** (architecture §20.7).

- Evidence ID: F03.D2-PARITY
  * Scenario: The runtime matches the D2 handoff on the canonical simulators — every variant beside its render; screen recordings of the full sequence (rows 0 and 4, a special-tile row), the retry transition and the reduced path, with frame timing (nothing outside the board before T0 + 600; rest ≤ T0 + 940; reduced ≈ 660); OS text large → AX5 on the result; Reduce Motion on and off; suites and integration_test green
  * Required Class: runtime + automated functional
  * Target / Environment: iOS Simulator 18.6 — iPhone 16 (primary), 16e, 16 Pro Max
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: F03.D2-HANDOFF accepted (gate Ready for Implementation)
  * Re-evaluation Trigger: F03-FE-D2 delivery
  * Blocks: Visual Quality Gate = Ready for QA; F03-QA-D2
  * Result: PASS
  * Provenance / Note: 2026-09-28 Frontend/Mobile Developer, HEAD 051c64c + working tree (committed 67d9ecb; `app/` tree `f5641d2f…`), debug build on iOS Simulator 18.6 (iPhone 16 / 16e / Pro Max). `frontend.md` § Visual Parity Evidence; artefacts in design/runtime-d2/, tooling design/src/capture-d2.sh, video-d2.swift, timing-d2.py, parity-d2.swift / .sh. Limits (NTLC-D2-3): D2-07 not reachable at runtime; focus ring not injectable; VoiceOver and lifecycle mid-sequence by widget tests only; debug builds only; Android not run. **Accepted by the Tech Lead 2026-09-28** (architecture §20.8): analyze / format clean and app 503 passed re-run at 67d9ecb; seven new negative runs all caught; parity reproduced byte for byte; frame timing reproduced within 1–3 ms except two cells corrected in `frontend.md` (16e row-4 HUD region +1186, not +719, background luma with no chrome visible; 16 retry board / HUD +248, not +265).

- Evidence ID: F03.D2-VISUAL-QA
  * Scenario: An independent final-stage QA verdict on D2 — rubric ≥ 93 from runtime video (every dimension ≥ 8, no fail condition); the §16.11.1 acceptance list; F04 AC1–AC10 on the result, F05 AC1 / AC12, F03 AC8 / AC11; lifecycle mid-sequence; D1 Play regression
  * Required Class: runtime
  * Target / Environment: iOS Simulator 18.6, iPhone 16 / 16e / Pro Max; Android stated as a limit (ANDROID-CI-EVIDENCE)
  * Owner Role: QA
  * Prerequisite / External Decision: F03.D2-PARITY accepted (gate Ready for QA) — met 2026-09-28
  * Re-evaluation Trigger: the F03-FE-D2R fix and F03-QA-D2R (superseded by F03.D2R-VISUAL-QA when that record passes)
  * Blocks: Visual Quality Gate = Passed; F03 Done; D3 activation
  * Result: FAIL
  * Provenance / Note: 2026-09-28 QA, HEAD 86c7318 (app/ f5641d2f…), debug build on iOS Simulator 18.6 — iPhone 16 D0011CE7, 16e 6DBDFD97, Pro Max 02FDE776. Independent rubric **92 / 100**, lowest Accessibility and Inclusive Quality 8, no fail condition. Blocking F03-QA-D2-01 (ScrollBand stays visible after the OS text size shrinks while the result is scrolled at AX5; §16.11.1 (12) fails). Everything else passed at runtime: the other 17 §16.11.1 items, the ten F04 variants, F05 AC1 / AC12, F03 AC8 / AC11, system back at ≈ T0 + 220 and at the settle, background ≈ T0 + 535, kill ≈ T0 + 400, Reduce Motion win and retry dip, the 1.3× cap with no scroll on three devices, AX5, D1 regression. C2 and T0 were measured with QA's own tools (qa/d2/src). VoiceOver and the focus ring rest on the automated class (host limit); Android not run (ANDROID-CI-EVIDENCE); debug builds only. Records: qa.md; artefacts in qa/d2/.

- Evidence ID: F03.D2R-PARITY
  * Scenario: The F03-QA-D2-01 fix at runtime — AX5 → scroll the result to the end → OS text size xxxL and `large`: the band is gone at offset 0 and the badge and back button are unobscured; the offset-0 control unchanged; a full-motion win + retry on video with the §20.3 timeline unchanged; the new widget test fails without the fix and passes with it; suites green
  * Required Class: runtime + automated functional
  * Target / Environment: iOS Simulator 18.6 — iPhone 16 (primary), 16e, 16 Pro Max
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: None (rulings architecture §20.9)
  * Re-evaluation Trigger: F03-FE-D2R delivery
  * Blocks: Visual Quality Gate = Ready for QA; F03-QA-D2R
  * Result: PASS
  * Provenance / Note: Opened by the Tech Lead 2026-09-28 at the F03-QA-D2 reconciliation (§20.9 (4)). 2026-09-28 Frontend/Mobile Developer, HEAD 3cd4a3b + working tree (`app/` diff SHA-1 262864be), debug build (`App` SHA-1 d7a7c0af) on iOS Simulator 18.6 — iPhone 16 / 16e / Pro Max. `frontend.md` § F03-FE-D2R (Visual Parity Evidence, §17); artefacts design/runtime-d2r/ (RT-*-D2R-*, RV-16-D2R-*, band-measurements.txt, timing-d2r.txt); tool design/src/band-d2r.swift with positive and negative controls. Tests: 9 new, failing first (9 / 9) and with the listener detached (9 / 9); app 512 passed; integration_test 13 / 13. Limits: debug builds; Android not run (ANDROID-CI-EVIDENCE). Awaiting the Tech Lead's acceptance at the rework checkpoint.

- Evidence ID: F03.D2R-VISUAL-QA
  * Scenario: An independent final-stage re-QA of D2 on the reworked revision — the text-size paths E-T1 … E-T5 on three devices, a win + retry smoke, the app suite, a full rubric re-score ≥ 93 (every dimension ≥ 8, no fail condition); F03-QA-D2 evidence reused where the diff leaves the surface unchanged
  * Required Class: runtime
  * Target / Environment: iOS Simulator 18.6, iPhone 16 / 16e / Pro Max; Android stated as a limit (ANDROID-CI-EVIDENCE)
  * Owner Role: QA
  * Prerequisite / External Decision: F03.D2R-PARITY accepted (gate Ready for QA)
  * Re-evaluation Trigger: F03-QA-D2R activation
  * Blocks: Visual Quality Gate = Passed; F03 Done; D3 activation
  * Result: PENDING
  * Provenance / Note: Opened by the Tech Lead 2026-09-28 at the F03-QA-D2 reconciliation (§20.9 (5)).

## Open Decision Gates

None

## Blockers

None

## Next Action

Run Tech Lead for the D2 rework checkpoint: reconcile F03-FE-D2R (`frontend.md` § F03-FE-D2R; F03.D2R-PARITY), set Delivery Review and the Visual Quality Gate, then activate F03-QA-D2R (§20.9 (5)).

## Last Decision

2026-09-28 (D2 QA-verdict reconciliation) — the Tech Lead accepted F03-QA-D2 **Rejected** (92 / 100, lowest Accessibility 8, no fail condition). Full record: architecture §20.9.

**Verified independently:**
* the revision — HEAD `f28aedb` keeps `app/` tree `f5641d2f…`; the QA commit touches only `ai-system/`;
* the finding — QA's captures show the band drawn over the badge and back button after the shrink, and not in the offset-0 control;
* the cause — `ResultView._band` is updated only by the scroll listener; Flutter clamps the offset on a content shrink through `correctPixels`, which does not notify listeners.

**Rulings** (§20.9):
* F03-QA-D2-01 is an implementation defect; the band must follow the current scroll position after any metrics change; the fix stays in the `ResultView` band state;
* the rubric is not re-graded by the Tech Lead;
* N1 → RESULT-APP-SWITCHER-SNAPSHOT (follow-up); N2 accepted as the debug evidence class; N3 → RESULT-F00-COMPONENT-ALIGN, subtitle noted; N4 D3; N5 stated limits.

**State:** Rework; Delivery Review Pending; Visual Quality Gate back to Ready for Implementation (handoff acceptance §20.7 stands); QA Result stays Rejected until the re-QA; F03-FE-D2R Open, F03-QA-D2R Queued; owner → Frontend/Mobile Developer.

The orchestration at the verdict is archived byte-for-byte as history/f03-puzzle-play-session-2026-09-28/orchestration-at-qa-d2-verdict.md.

## Last Update

* Updated By: Frontend/Mobile Developer
* Timestamp: 2026-09-28
* Summary: F03-FE-D2R delivered — the scroll band follows the scroll position after metrics changes (F03-QA-D2-01); 9 failing-first tests + two negative runs; suites and integration_test green; runtime on three simulators; F03.D2R-PARITY PASS; Delivery Review Pending; owner → Tech Lead.

## Context & Follow-ups

* **Phase D1 closed 2026-09-28** (Play; §19, closure §19.12). Its Play surface is the transition's starting frame and a regression input.
* **D2 inputs:** DESIGN-ADOPTION-CONTRACT-AMENDMENTS (D2 items, applied in §20); OPTIONAL-QUALITY-NOTES (the 30 ms stagger, text-scale density — both now in §20.3); NTLC-6 / A-2 result at AX5.
* **Logged at the D2 parity checkpoint:** RESULT-F00-COMPONENT-ALIGN (NTLC-D2-2).
* **Logged at the D2 QA-verdict reconciliation:** RESULT-APP-SWITCHER-SNAPSHOT (qa.md N1).
* **Still open, outside D2:** F03-MULTITOUCH-FIRST-POINTER; MOVESCARD-COUNTER-LINE-HEIGHT; ANDROID-CI-EVIDENCE.
* **Design Adoption Route:** workflow-follow-ups.md.
* **Audit:** features/f00-design-foundation/conformance-audit.md.

## History & Evidence References

* [QA report](qa.md) (D2, 2026-09-28), [contract](architecture.md) (§12, §18, §19, §20), [UI design](ui-design.md) (§1–§14 D1; §16 D2), [frontend delivery](frontend.md) (D2).
* [Orchestration at the F03-QA-D2 verdict](../../history/f03-puzzle-play-session-2026-09-28/orchestration-at-qa-d2-verdict.md); [orchestration at the F03-FE-D2 delivery](../../history/f03-puzzle-play-session-2026-09-28/orchestration-at-fe-d2-delivery.md); [orchestration at the F03-UI-D2 delivery](../../history/f03-puzzle-play-session-2026-09-28/orchestration-at-ui-d2-delivery.md); [ui-design.md before D2](../../history/f03-puzzle-play-session-2026-09-28/ui-design-before-phase-d2.md); [frontend.md before D2](../../history/f03-puzzle-play-session-2026-09-28/frontend-before-phase-d2.md).
* [Terminal D1 orchestration](../../history/f03-puzzle-play-session-2026-09-28/orchestration-before-phase-d2.md); the D1 working record in [history/f03-puzzle-play-session-2026-09-27/](../../history/f03-puzzle-play-session-2026-09-27/README.md); the [closure record of 2026-09-21](../../history/f03-closure-2026-09-21/orchestration.md) — historical only, not a run queue.
* [Portfolio follow-ups](../../workflow-follow-ups.md); [Phase C audit](../f00-design-foundation/conformance-audit.md).
* Canonical execution: role-execution-contract.md.

## Change Log

* 2026-09-18 to 2026-09-21 — migration, win-sequence rework, final QA, closure (behaviour / accessibility); full log in the closure record.
* 2026-09-27 to 2026-09-28 — Design Adoption Phase D1 (Loop Glass Play): reopened, handoff, delivery, QA Rejected, rework, re-QA Approved with Notes, gate Passed, **Done** (architecture §19; log in the archived terminal orchestration).
* 2026-09-28 — Tech Lead: D2 activation (architecture §20; Visual Scope `motion-critical`); F03-UI-D2 Open.
* 2026-09-28 — UI Designer: F03-UI-D2 delivered; F03.D2-HANDOFF PASS; owner → Tech Lead.
* 2026-09-28 — Tech Lead: D2 visual-gate checkpoint — handoff accepted; gate Ready for Implementation; §20.7 rulings (retry A) and corrections C1–C3; F03-FE-D2 Open.
* 2026-09-28 — Frontend/Mobile Developer: F03-FE-D2 delivered (67d9ecb); F03.D2-PARITY PASS; NTLC-D2-1 … 3; owner → Tech Lead.
* 2026-09-28 — Tech Lead: D2 parity checkpoint.
  * **Verified:** suites (503 passed); 7 / 7 new negative runs caught; parity byte-identical; frame timing within 1–3 ms (two cells corrected in `frontend.md`).
  * **Decided:** Delivery Review Accepted; Visual Quality Gate Ready for QA; architecture §20.8 rulings; RESULT-F00-COMPONENT-ALIGN logged.
  * **Next:** F03-QA-D2 Open; owner → QA.
* 2026-09-28 — QA: F03-QA-D2 done — **Rejected** (92 / 100, lowest Accessibility 8); blocking F03-QA-D2-01; F03.D2-VISUAL-QA FAIL; the D1R qa.md moved to history/f03-puzzle-play-session-2026-09-28/qa-at-d1r-verdict.md; owner → Tech Lead.
* 2026-09-28 — Tech Lead: D2 QA-verdict reconciliation — Rejected accepted; F03-QA-D2-01 confirmed (captures + code); §20.9 rulings; RESULT-APP-SWITCHER-SNAPSHOT logged; Rework; gate Ready for Implementation; F03-FE-D2R Open, F03-QA-D2R Queued; owner → Frontend/Mobile Developer.
* 2026-09-28 — Frontend/Mobile Developer: F03-FE-D2R delivered (working tree on 3cd4a3b); F03.D2R-PARITY PASS; Delivery Review Pending; owner → Tech Lead.

## Current Brief

**F03-FE-D2R — D2 scroll-band rework** (contract: architecture.md §20.9; everything in §20.3, §20.7 and §20.8 still applies)

**User-visible symptom** (F03-QA-D2, `qa.md` § Findings F03-QA-D2-01, evidence `qa/d2/` E-T5):
* a player with the OS text size at AX5 scrolls the result to its end, then lowers the text size (e.g. to xxxL or the default) while the result is open;
* the content jumps back to the top, but the dark scroll band stays drawn across the top of the screen;
* the `HARİKA` / `YENİ EN İYİ` badge is dimmed — barely visible at the default size — and so is the back button;
* the column can no longer scroll, so the player cannot clear the band; it stays until they leave the result.

**Affected journey and entry paths:**
* any `/play` session that reaches the full-screen result (Home CONTINUE, Next, Retry, resume) with an OS text size above the 1.3× cap, then a live OS text-size reduction (Settings / Control Center) while the result is scrolled;
* state source: `ResultView`'s `_band` (`app/lib/play/widgets/result_view.dart`), set only by the `ScrollController` listener `_onScroll`. A content shrink clamps the offset through `correctPixels`, which notifies no listener (§20.9, cause confirmed).

**Fix scope:**
1. `app/lib/play/widgets/result_view.dart` — the band state only:
   * the band's visibility equals `clamp(pixels / ResultView.bandFadeDistance, 0, 1)` for the current position at every frame, including after a scroll-metrics change (text size down or up, content extent change);
   * when the column cannot scroll (max extent 0), the band is 0;
   * recompute on metrics changes as well as on scroll — e.g. listen for `ScrollMetricsNotification`, or read the position after layout. The approach is yours; state it in `frontend.md`.
2. `ScrollBand` (`app/lib/design`) changes only if the fix needs it, inside the §20.7 (6) allowance, with its component tests green.
3. `frontend.md` — append an F03-FE-D2R section; the D2 delivery text stays.

**Tests:**
* a widget test that lays out the result at AX5 (a real text scaler), scrolls to the end, then drops the scale to 1.0 and, in a second case, to the 1.3× cap. Assert band visibility 0 and that the badge and back button are not under the band (read the `ScrollBand` visibility or its painted opacity; do not assert only the offset);
* a case where the shrunk content still scrolls: the band equals the rule's value for the clamped offset;
* **negative run:** remove the fix, show the new test fails, restore it. Record the counts in `frontend.md`;
* existing suites stay green: `melos run analyze`, `flutter test` in `app/`, `dart format` 0 changed; `integration_test` 13 / 13 on the iPhone 16 if the diff touches a path it exercises (otherwise state why it was not re-run).

**Runtime evidence (F03.D2R-PARITY):**
* QA's E-T5 steps on the iPhone 16, 16e and Pro Max: `capture-d2.sh seed <udid> 5 '["D0","D1"]'` → content size AX5 → CONTINUE → win → scroll the result to the end → `extra-extra-extra-large`, and again → `large`. Capture after each shrink: band gone, badge and back button clear;
* the offset-0 control (shrink without scrolling) — unchanged;
* one full-motion win + retry on the iPhone 16 with video, and a statement that the §20.3 timeline windows are unchanged (the timing tools may be reused);
* restore the simulator settings: `large`, Reduce Motion 0.

**Non-goals:**
* no layout, timeline, copy, input-lock, lifecycle, persistence or route change;
* N1 (app-switcher snapshot mid-reveal) stays out → RESULT-APP-SWITCHER-SNAPSHOT;
* the F00 component deviations stay out → RESULT-F00-COMPONENT-ALIGN;
* F03-MULTITOUCH-FIRST-POINTER, MOVESCARD-COUNTER-LINE-HEIGHT, Home (D3) stay out;
* no dependency or token change.

**Exit:**
* the rule holds at runtime on the three devices;
* the new test fails on the old code and passes on the new;
* suites green;
* F03.D2R-PARITY recorded (Frontend's provenance; the Tech Lead accepts it at the checkpoint);
* Delivery Review → Pending, owner → Tech Lead for the rework checkpoint.

The Tech Lead then activates F03-QA-D2R (§20.9 (5)).

## Earlier briefs

* F03-UI-D2 (UI Designer, done 2026-09-28) — archived byte-for-byte in history/f03-puzzle-play-session-2026-09-28/orchestration-at-ui-d2-delivery.md.
* F03-FE-D2 (Frontend/Mobile Developer, done 2026-09-28) — archived byte-for-byte in history/f03-puzzle-play-session-2026-09-28/orchestration-at-fe-d2-delivery.md.
* F03-QA-D2 (QA, done 2026-09-28, Rejected) — archived byte-for-byte in history/f03-puzzle-play-session-2026-09-28/orchestration-at-qa-d2-verdict.md.
* D1 briefs (F03-UI-D1, F03-FE-D1, F03-QA-D1, F03-FE-D1R, F03-QA-D1R) — archived byte-for-byte in history/f03-puzzle-play-session-2026-09-27/.
