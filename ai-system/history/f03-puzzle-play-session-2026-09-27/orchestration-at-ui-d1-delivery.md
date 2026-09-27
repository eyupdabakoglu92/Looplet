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
- [ ] Task ID: F03-FE-D1 | Assigned Role: Frontend/Mobile Developer | Status: Queued | Summary: Implement the D1 handoff from app/lib/design (architecture.md §19.7). Covers the Play header, rail, board, HUD, special tiles, thaw and load error, plus the F05 tutorial overlay (cross-feature). Drawn icons replace the Material icons on these surfaces; tests updated and green. frontend.md Visual Parity Evidence: screenshots vs renders on iPhone 16 / 16e / Pro Max; a screen recording of row lift, column lift and thaw; an AX5 text-size sweep; Reduce Motion on and off; integration_test green | Depends On: F03-UI-D1
- [ ] Task ID: F03-QA-D1 | Assigned Role: QA | Status: Queued | Summary: Final-stage independent visual QA of D1 (architecture.md §19.7): runtime rubric ≥ 93 with every dimension ≥ 8 and no fail condition; regression of AC1–AC11 and F05 AC4/AC11; text-scale sweep to AX5; Reduce Motion; Android stated as a limit | Depends On: F03-FE-D1

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

Pending

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

The artefacts are in features/f03-puzzle-play-session/design/. The parity and QA records are pending (see Pending Evidence).

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
  * Result: PENDING
  * Provenance / Note: -

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

Run Tech Lead: the visual-gate checkpoint for F03-UI-D1.
1. Verify ui-design.md (the handoff-gate items; §12b manifest; §11.5 acceptance list), the renders in design/ and the motion prototype.
2. Rule on §14.1 (the 1.3× text cap on the whole of Play, including the hint pill) and §14.2 (design-layer edits inside D1).
3. Set Delivery Review and Visual Quality Gate (→ Ready for Implementation).
4. Open F03-FE-D1 for the Frontend/Mobile Developer.

## Last Decision

2026-09-27 (Design Adoption Phase D1 reopen) — the Tech Lead accepted the Phase C conformance audit (F00, commit cc84440) and reopened F03 as visual rework.
* **Why:** the incident of 2026-09-26 — the app still shows the old design.
* **Scope:** Loop Glass Play (`existing-parity`), with the F05 column-tutorial overlay as a cross-feature item and the F03 load error. It fixes the shipped defects A-1, A-2 (board), A-5 and A-6.
* **Contract:** architecture.md §19. §13 and §18 are amended in place, and F05 architecture §9 records the move of the tutorial's visual authority.
* **Rulings in §19.3:**
  * text scale — free text to AX5, container text capped at 1.3×, Play never scrolls;
  * tutorial HUD — the pill sits above the HUD;
  * thaw — a 180 ms cross-fade;
  * the Foundation's locked / frozen treatments;
  * interim proposed copy (`HEDEF DÖNGÜ`, `SEVİYE NN`);
  * the hybrid period is accepted.
* **Next slices:** D2 (won moment + full-screen result, F03 carrier, `motion-critical`), then D3 (home + app shell, F05 carrier, `new-surface`).
* **QA plan:** fixed now and re-validated with `qa-preflight` at QA activation.

The pre-reopen terminal orchestration (Done 2026-09-21) is archived byte-for-byte in history/f03-puzzle-play-session-2026-09-27/orchestration-before-phase-d1.md.

## Last Update

* Updated By: UI Designer
* Timestamp: 2026-09-27
* Summary: F03-UI-D1 delivered — Loop Glass Play handoff (ui-design.md), 28 renders, motion prototype; F03.D1-HANDOFF PASS; Delivery Review = Pending; owner → Tech Lead (visual-gate checkpoint).

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

## Current Brief

**F03-UI-D1 — the Loop Glass Play handoff (Design Adoption Phase D1; contract: architecture.md §19)**

**Why:** players still see the old look on the screen where they spend their time. The Foundation is Selected and its design-system layer (`app/lib/design/`) exists. This handoff is what lets Frontend rebuild Play on it.

**Symptom and scope:** architecture.md §19.1–§19.2 — every non-`won` state of `/play`, the load error, and the F05 column tutorial.

**Inputs:**
* **Authority:** `project-authority/design-foundation.md` (§17–§18). In `features/f00-design-foundation/ui-design.md`: §6 Play layout (358-pt reference, scaled by width), §7 components, §8 states, §10 visual direction, §13 accessibility, §14 guardrails.
* **Selected-source renders** (F00 `design/`): S-01b (the "today" target, without the future-scope hint line), S-02, S-03, S-07; the device variants S-v-*; the component sheet S-91.
* **Audit:** `features/f00-design-foundation/conformance-audit.md`:
  * §4 and §5 — the gaps by category, with measured values;
  * §10, items 1–10 — the missing renders;
  * §11 — the matrix rows;
  * the current-app captures in F00 `design/audit/` (the baseline).
* **Code layer:** `app/lib/design` — `TileFace` (normal / active / winning / locked / frozen / inactive), `RailTile`, `BoardCard`, `MovesCard`, `UndoPill`, `GlassIconButton`, `GlassCard`, `LoopBackdrop` and `LoopIconView`, all available. Missing, to be specified:
  * the active-row rails and the 30 % wrap ghost as board decorations;
  * the back label;
  * the hint pill;
  * the ghost ring;
  * the error card.
* **Tooling:** F00's generator (`design/src/gen-s.mjs`, HTML/CSS → PNG) can be extended so the new renders match the S-* set.

**Deliver** — F03 `ui-design.md`, rewritten or extended as you judge best. The pre-D1 text is in git history.
* The Loop Glass Play sections supersede the Direction A visuals (§2, §5–§11) for this surface. **§16 (won composition) stays authoritative until D2.**
* Include the handoff-gate items of `design/visual-quality-gate.md`:
  * the Screen/State/Viewport matrix;
  * component, typography, colour, asset and interaction decisions;
  * a motion spec with reduced paths;
  * source-render records;
  * the Visual Evidence Manifest (`selected-source` records for S-01b/S-02/S-03/S-07, plus your new renders);
  * the selection record (Foundation Selected 2026-09-21; Visual Scope `existing-parity`).
* **Render these missing states as real image files**, under `features/f03-puzzle-play-session/design/`:
  1. column drag (vertical rails);
  2. undo with 2 left;
  3. undo exhausted;
  4. restart pressed;
  5. a two-digit back label (`SEVİYE 26`);
  6. the thaw per §19.3 (3), as a frame pair or sequence;
  7. the load error;
  8. the tutorial with the HUD per §19.3 (2);
  9. the ghost during a real drag;
  10. AX5 Play per §19.3 (1).
* **Apply the §19.3 rulings:**
  * the text-scale rule;
  * the tutorial pill above the HUD, and the ghost hiding on touch-down;
  * the 180 ms thaw;
  * the Foundation's locked / frozen treatments, readable in greyscale;
  * the copy `HEDEF DÖNGÜ` / `SEVİYE NN` bound to the level;
  * `HAMLE` ≥ 11 pt;
  * targets ≥ 44 pt.
* **A D1 acceptance list** that Frontend and QA can check (rects, tokens, states, timings).

**Non-goals:**
* the won moment and result (D2), home and app shell (D3);
* the gesture-hint line (F09) and other future-scope items;
* no code or `app/` change;
* no new direction (the Foundation is Selected);
* no change to engine, gesture, persistence or timing contracts.

**Exit:** set Delivery Review = Pending, mark F03.D1-HANDOFF with provenance, and hand back to the Tech Lead. The Tech Lead verifies the visual-gate items and sets Ready for Implementation before activating F03-FE-D1. Unresolved design questions go under Needs Tech Lead Clarification.
