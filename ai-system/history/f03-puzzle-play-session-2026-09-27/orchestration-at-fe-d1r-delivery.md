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

- [x] Task ID: F03-UI-D1 | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-27 — ui-design.md §1–§14 rewritten for the Loop Glass Play surface; §16 won composition kept byte-for-byte (legacy until D2). 28 renders under design/: the audit's D1 missing states 1–10, plus idle (D1 corrections), loading, keyboard focus, 16e / Pro Max variants, the 1.3× text cap and motion stills. Executable motion prototype design/src/D1-motion-prototype.html (lift + settle, thaw, tutorial ghost; ?rm=1, ?t=). Rulings applied: C-5 (hint pill above the HUD, ≥ 4 pt clearance measured on three devices at 1.0× and 1.3×; ghost hides on touch-down), C-9 (1.3× cap), C-10 (180 ms thaw), locked/frozen treatments, copy. D1 acceptance list §11.5; manifest §12b. NTLC §14: the text cap applied to the whole of Play (deviates from the §19.3 (1) hint example), design-layer edits inside D1, and informational items. No code | Depends On: -
- [x] Task ID: F03-FE-D1 | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-28 — every non-won Play state on Loop Glass (LoopBackdrop; chevron + SEVİYE NN; MovesCard; HEDEF DÖNGÜ + RailTiles; BoardCard + TileFace; lift with rim, card-edge rails, rest at 42 %, wrap ghost 30 → 100 %; thaw 180 ms cross-fade; UndoPill + 44-pt restart; skeleton loading; error card + LimePill → /), the F05 tutorial re-skin (pill between board and HUD, ghost hides on touch-down and returns after 600 ms idle; §19.8 (3) fallback on after a 3.93-pt device measurement), the §19.8 (2) design-layer additions, drawn icons (no Material icon left), strings and semantics, reduced-motion paths. Tests: melos analyze / test green (app 405), integration_test 13/13 on the iPhone 16 simulator. frontend.md Visual Parity Evidence: runtime screenshots on the 16 / 16e / Pro Max, parity composites and measurements (≤ 0.83 pt vs the D1 renders), four videos, text sweep and Reduce Motion. NTLC-1: the won dock moved onto the goal (the D1 header left no §16.3 zone); NTLC-2: three design-layer edits beyond the §19.8 (2) list | Depends On: F03-UI-D1
- [x] Task ID: F03-QA-D1 | Assigned Role: QA | Status: Done | Summary: DONE 2026-09-28 — verdict **Rejected** (qa.md, final, client-only, HEAD 5798c70; app/ = b8b5f60). Independent runtime rubric **87 / 100**, lowest Accessibility 7, one fail condition (clipping / overflow) → Visual Quality FAIL. Blocking: **F03-QA-D1-01** (Major) — the `HAMLE` label overflows the MovesCard's rounded bottom edge at the 1.3× cap from OS size xxL up to AX5 (D1-10 shows it inside; frontend.md NTLC-3 / A11Y-16-text "no overlap" is only true at the card centre); **F03-QA-D1-02** (Minor) — the load-error headline breaks "yüklenemedi" / "." at xxxL and every AX size (§11.5 (10)). Non-blocking: F03-QA-D1-03 — a two-finger opposite drag yields no move instead of honouring the first pointer (pre-D1 gesture code, safe outcome). Everything else PASS at runtime: suites re-run (analyze clean, app 405/0/0), integration 13/13 on the 16; parity ≤ 0.67 pt on 16 / 16e / Pro Max; lift / settle (1.5 % at 80 %), bounce, thaw cross-fade, ghost 120 / 600 / 160 ms, Reduce Motion paths; AC1–AC11, F05 AC4 / AC11; tutorial clearance ≥ 6 pt on all devices at 1.0× and AX5; won moment per §16 + §19.9 (1) (T0 + 600, dock on the goal, panel clear, Retry / Close). Evidence qa/d1/ | Depends On: F03-FE-D1
- [x] Task ID: F03-FE-D1R | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-28 — (1) `MovesCard` grows below its label by up to 13·s at the 1.3× cap (0 at 1.0×; width, anchor and default 60 × 63·s kept): label ink ≥ 2.98 pt inside the rounded card, arcs included, on the 16 / 16e / Pro Max from large to AX5 (was −4.76 pt at AX5); (2) the load-error headline uses the card's inner width: "Bu bulmaca" / "yüklenemedi." at every size, no orphaned full stop; (3) frontend.md A11Y-16-text and NTLC-3 corrected. Failing first: 33 / 39 and 12 / 28 new tests fail on HEAD code, all pass on the fix; app 472 green, integration 13 / 13. Runtime sweep + measurements in design/runtime-d1r/ (frontend.md § F03-FE-D1R). NTLC-D1R-1 / -2 informational | Depends On: F03-QA-D1
- [ ] Task ID: F03-QA-D1R | Assigned Role: QA | Status: Queued | Summary: Re-QA of D1 after F03-FE-D1R and the Tech Lead checkpoint: final stage, full regression with fingerprint-based reuse of the F03-QA-D1 evidence (§19.10 (5)); text sweep large → AX5 on the three devices, the two reworked surfaces, full rubric re-score (≥ 93, every dimension ≥ 8, no fail condition) | Depends On: F03-FE-D1R

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

existing-parity

## Design Foundation

ai-system/project-authority/design-foundation.md

## Visual Quality Gate

Ready for Implementation

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

The tooling is in design/src/ (parity-d1.sh, measure-d1.swift, pill-clearance-d1.swift, video-d1.swift, seed-sim.sh). The Tech Lead verified the parity records at the 2026-09-28 checkpoint: the measurements reproduce number for number, and composites were inspected (architecture §19.9).

Independent QA records (2026-09-28, QA; qa.md § Visual Quality Verdict) are in features/f03-puzzle-play-session/qa/d1/:
* runtime-screenshot QA-16-*, QA-16e-*, QA-pm-* (every §12a state on the 16; idle / column drag / tutorial at 1.0× and AX5 on the 16e and Pro Max; text sweep large → AX5; won moment);
* runtime-video QV-16-* (row + column lift, bounce, thaw, tutorial ghost and undo, won, loading, Reduce Motion);
* measurement and probe logs QM-*; QA tools qa/d1/src/.

The gate evidence result is FAIL (F03.D1-VISUAL-QA).

Rework runtime records (2026-09-28, Frontend/Mobile Developer; frontend.md § F03-FE-D1R, Visual Parity Evidence) are in features/f03-puzzle-play-session/design/runtime-d1r/:
* runtime-screenshot RT-{16,16e,pm}-L26-* and RT-{16,16e,pm}-L07-error-* (content sizes large → AX5);
* parity-comparison PC-D1R-*.jpg (before / after at AX5, the 16 sweep);
* measurements-d1r.txt (card ink insets, headline lines, default-size parity).

The tooling is in design/src/ (sweep-d1r.sh, measure-d1r.swift, compose-d1r.swift).

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
  * Result: FAIL
  * Provenance / Note: 2026-09-28 QA, HEAD 5798c70 (app/ identical to b8b5f60), debug build on iOS Simulator 18.6 — iPhone 16 D0011CE7, 16e 6DBDFD97, Pro Max 02FDE776. Independent rubric **87 / 100**, lowest Accessibility and Inclusive Quality 7, fail condition clipping / overflow. Blocking F03-QA-D1-01 (the `HAMLE` label overflows the MovesCard at the 1.3× cap, xxL → AX5) and F03-QA-D1-02 (the load-error headline breaks "yüklenemedi" / "." at xxxL / AX). Everything else passed at runtime: the §11.5 items apart from (10), AC1–AC11, F05 AC4 / AC11, Reduce Motion on and off, the three devices, and the won moment per §16 + §19.9 (1). VoiceOver and the keyboard focus ring rest on the automated class (host limit; §19.9 (4)); Android not run (ANDROID-CI-EVIDENCE). Records: qa.md; artefacts in qa/d1/.

- Evidence ID: F03.D1R-PARITY
  * Scenario: The text-scale rework holds at runtime — the `MovesCard` numeral and label ink inside the card's rounded rect (≥ 2 pt inset, arcs included) and the load-error headline breaking only between words, at OS sizes large / xL / xxL / xxxL / AX5 on the iPhone 16, 16e and Pro Max; default-size parity with D1-00 / D1-07 within ±2 pt; suites and integration_test green
  * Required Class: runtime + automated functional
  * Target / Environment: iOS Simulator 18.6 — iPhone 16 D0011CE7, 16e 6DBDFD97, Pro Max 02FDE776
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: None (rulings architecture.md §19.10)
  * Re-evaluation Trigger: F03-FE-D1R delivery
  * Blocks: Visual Quality Gate = Ready for QA; F03-QA-D1R
  * Result: PASS
  * Provenance / Note: 2026-09-28 Frontend/Mobile Developer, HEAD 97c700e + the F03-FE-D1R working tree, debug build on iOS Simulator 18.6 — iPhone 16 D0011CE7, 16e 6DBDFD97, Pro Max 02FDE776; content sizes large / xL / xxL / xxxL / AX5 set live with `simctl ui content_size` (restored to large). `HAMLE` card on L26: label ink inset from the rounded rect (arcs included) 2.98–3.35 pt (16), 3.22–3.53 (16e), 3.27–4.22 (Pro Max); numeral ≥ 11.33; `HEDEF DÖNGÜ` ≥ 39.3 pt below the card; the same tool reads −4.76 pt on QA's pre-rework QA-16-16. Load error L07 (asset corrupted in the installed bundle, restored, SHA-1 2fef993c2391… = repo): two lines at every size on every device, no punctuation-only line (the tool flags QA-16-28's "." line). Default size: the error headline ink is identical to RT-16-07; the label ink at `large` equals QA's capture; D1-05 probe max 0.67 pt, unchanged. Suites: analyze clean; app 472 passed; integration_test 13 / 13 on the iPhone 16. Records: frontend.md § F03-FE-D1R; design/runtime-d1r/measurements-d1r.txt. Android not run (ANDROID-CI-EVIDENCE).

- Evidence ID: F03.D1R-VISUAL-QA
  * Scenario: An independent final-stage QA re-verdict on the D1 Play surface after the rework — rubric ≥ 93 with every dimension ≥ 8 and no fail condition; the text sweep; the reworked surfaces; regression per §19.10 (5)
  * Required Class: runtime
  * Target / Environment: iOS Simulator 18.6, iPhone 16 / 16e / Pro Max; Android stated as a limit (ANDROID-CI-EVIDENCE)
  * Owner Role: QA
  * Prerequisite / External Decision: F03.D1R-PARITY accepted (gate Ready for QA)
  * Re-evaluation Trigger: F03-QA-D1R activation
  * Blocks: Visual Quality Gate = Passed; F03 Done; D2 activation
  * Result: PENDING
  * Provenance / Note: -

## Open Decision Gates

None

## Blockers

None

## Next Action

Run Tech Lead — checkpoint on the F03-FE-D1R delivery (frontend.md § F03-FE-D1R; F03.D1R-PARITY recorded PASS):
* verify both §19.10 rules at runtime and run a negative case for each;
* rule on NTLC-D1R-1 (close MOVESCARD-CAP-MARGIN) and NTLC-D1R-2 (informational);
* Delivery Review; gate → Ready for QA; activate F03-QA-D1R.

## Last Decision

2026-09-28 (QA-verdict reconciliation) — the Tech Lead reconciled F03-QA-D1 (`qa.md`, HEAD 5798c70): **Rejected**, rubric 87 / 100, F03.D1-VISUAL-QA FAIL.

**Verified independently:**
* re-measured QA's stored captures — the `HAMLE` label ink box x 304.7–361.7, y 138.7–150.0 pt at AX5; the AX5 error headline 120 pt tall (three lines). Both match qa.md;
* confirmed both root causes in the code: `MovesCard` has no inner vertical padding at the cap; the error headline is limited to `maxWidth: 230 * s`, below the card's inner width.

**Rulings** (architecture §19.10):
* F03-QA-D1-01 — implementation defect; a `MovesCard` internal-layout allowance with a rect rule; supersedes MOVESCARD-CAP-MARGIN;
* F03-QA-D1-02 — implementation defect; a word-boundary rule;
* F03-QA-D1-03 — recorded as F03-MULTITOUCH-FIRST-POINTER, outside D1 (§19.6 no behaviour change);
* frontend.md NTLC-3 / A11Y-16-text to be corrected;
* re-QA with fingerprint-based reuse.

**State:** Current Status Rework; Delivery Review Pending; Visual Quality Gate Ready for Implementation; F03-FE-D1R Open; F03-QA-D1R Queued; owner → Frontend/Mobile Developer.

The previous decision (the 2026-09-28 Frontend checkpoint) and the F03-QA-D1 brief are archived byte-for-byte in history/f03-puzzle-play-session-2026-09-27/orchestration-at-qa-d1-verdict.md.

## Last Update

* Updated By: Frontend/Mobile Developer
* Timestamp: 2026-09-28
* Summary: F03-FE-D1R delivered — `MovesCard` grows below its label at large text (ink ≥ 2.98 pt inside the arcs on three devices to AX5); the load-error headline breaks only between words; failing-first tests; F03.D1R-PARITY PASS; Delivery Review Pending; owner → Tech Lead.

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
* 2026-09-28 — QA: F03-QA-D1 done; QA Result Rejected; F03.D1-VISUAL-QA FAIL; owner → Tech Lead.
  * **Score:** 87 / 100, lowest Accessibility 7; fail condition clipping / overflow.
  * **Findings:** F03-QA-D1-01 (Major, blocking) `HAMLE` label overflow at the cap; F03-QA-D1-02 (Minor, blocking) load-error headline break; F03-QA-D1-03 (Minor, non-blocking, pre-D1) multi-touch.
  * **Evidence:** qa.md; qa/d1/. The previous qa.md (2026-09-21) is archived byte-for-byte as history/f03-puzzle-play-session-2026-09-27/qa-before-phase-d1.md.
* 2026-09-28 — Tech Lead: QA-verdict reconciliation.
  * **Verified:** both blocking findings re-measured from QA's captures; root causes confirmed in `info.dart` and `play_session_screen.dart`.
  * **Decided:** architecture §19.10 rulings; F03-MULTITOUCH-FIRST-POINTER logged outside D1; MOVESCARD-CAP-MARGIN folded into the rework.
  * **Next:** Current Status Rework; F03-FE-D1R Open; F03-QA-D1R Queued; gate Ready for Implementation; owner → Frontend/Mobile Developer. The orchestration at the QA verdict is archived as history/f03-puzzle-play-session-2026-09-27/orchestration-at-qa-d1-verdict.md.
* 2026-09-28 — Frontend/Mobile Developer: F03-FE-D1R delivered; task Done; F03.D1R-PARITY PASS; Delivery Review = Pending; owner → Tech Lead.
  * **Code:** `MovesCard` bottom growth up to 13·s at the cap (design-layer allowance §19.10 (1)); `_LoadErrorView` headline without the 230·s limit.
  * **Tests:** moves_card_ink_test (39) and load_error_headline_test (28) — 33 and 12 fail on HEAD code; app 472 green; integration 13 / 13.
  * **Evidence:** frontend.md § F03-FE-D1R; design/runtime-d1r/.
  * **NTLC:** NTLC-D1R-1 (MOVESCARD-CAP-MARGIN closure), NTLC-D1R-2 (inherited counter line height) — informational.

## Current Brief

**F03-FE-D1R — D1 text-scale rework (contract: architecture.md §19.10; everything in §19.3, §19.8 and §19.9 still applies)**

**User-visible symptom** (F03-QA-D1, `qa.md` § Findings, evidence `qa/d1/`):
* with the OS text size at extra-extra-large or above, the `HAMLE` label on Play spills across the rounded bottom corners of its card;
* on the "Bu bulmaca yüklenemedi." screen at extra-extra-extra-large or above, the full stop drops onto a line of its own.

**Affected journey and entry paths:**
* any `/play` session (Home CONTINUE, Result Retry / Next, resume after a kill) with a large OS text size — the header card is always visible;
* the load-error state (a level asset that fails to load; QA used a corrupted `journey-tr-07.json` in the simulator bundle).

**Fix scope:**
1. `app/lib/design/components/info.dart` — `MovesCard`, under the §19.10 (1) allowance:
   * the numeral and label ink stay inside the card's rounded rect, corner arcs included, inset by ≥ 2 pt;
   * at every OS size default → AX5, on 390 / 393 / 440 pt widths;
   * the card keeps its width 60·s and its top-left anchor (273.5, 75)·s, grows downward only and stays ≥ 8 pt above `HEDEF DÖNGÜ`;
   * no token, `LoopText` role, font or tracking change.
2. `app/lib/play/play_session_screen.dart` — `_LoadErrorView` headline:
   * breaks only between words at every OS size default → AX5 on the three widths;
   * keep the §19.9 (3) 1.3× cap; the headline may use the card's inner width.
3. `frontend.md` — correct NTLC-3 and the A11Y-16-text record, and add the rework delivery.
   * The earlier D1 delivery text stays; append an F03-FE-D1R section.

**Tests:**
* a component test asserting the MovesCard rule with real fonts at scales 1.0 / 1.235 / 1.3 / 3.12 on the three widths — ink or glyph boxes against the rounded rect, not the bounding box;
* a widget test asserting that no headline line is punctuation-only and no word is split, at the same scales.
* Each new test must fail against the current code (show that in `frontend.md`). Existing suites stay green; `integration_test` 13/13 on the iPhone 16.

**Runtime evidence (F03.D1R-PARITY):**
* captures at large / xL / xxL / xxxL / AX5 on the iPhone 16, 16e and Pro Max — L26 for the card, the corrupted-L07 error screen for the headline (restore the asset afterwards);
* measurements of the label ink versus the card arcs;
* default-size parity with D1-00 / D1-07 (±2 pt);
* restore the simulator settings.

**Non-goals:**
* no behaviour change (gestures, input lock, persistence, routes, timing);
* F03-QA-D1-03 / multi-touch stays out (follow-up F03-MULTITOUCH-FIRST-POINTER);
* no other surface restyle; the won moment and the F04 panel stay as they are (D2);
* no dependency or token change.

**Exit:**
* both rules hold at runtime on the three devices;
* the tests fail on the old code and pass on the new;
* suites green;
* F03.D1R-PARITY recorded;
* Delivery Review → Pending, owner → Tech Lead for the checkpoint.

The Tech Lead then activates F03-QA-D1R (§19.10 (5)).

## Earlier briefs

* F03-UI-D1 (UI Designer, done 2026-09-27) — archived byte-for-byte in history/f03-puzzle-play-session-2026-09-27/orchestration-at-ui-d1-delivery.md.
* F03-FE-D1 (Frontend/Mobile Developer, done 2026-09-28) — archived byte-for-byte in history/f03-puzzle-play-session-2026-09-27/orchestration-at-fe-d1-delivery.md.
* F03-QA-D1 (QA, done 2026-09-28, Rejected) — archived byte-for-byte in history/f03-puzzle-play-session-2026-09-27/orchestration-at-qa-d1-verdict.md.
