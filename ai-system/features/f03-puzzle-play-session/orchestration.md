# F03 — puzzle-play-session: Orchestration

## Feature ID

F03

## Current Status

Rework

## Current Owner

UI Designer

## Next Role

UI Designer

## Active Task Ledger

- [ ] Task ID: F03-UI-D2 | Assigned Role: UI Designer | Status: Open | Summary: The D2 handoff in F03 `ui-design.md` (replacing §16): the full-screen result in every F04 variant, the win sequence on the D1 board incl. special tiles in the winning row (C-11), the board → result and result → Play transitions with reduced paths as an executable prototype re-timed on the D1 geometry, the audit's D2 renders, AX5, a D2 acceptance list and the Visual Evidence Manifest. Contract architecture §20. Brief: Current Brief | Depends On: -
- [ ] Task ID: F03-FE-D2 | Assigned Role: Frontend/Mobile Developer | Status: Queued | Summary: Implement the D2 handoff from `app/lib/design` (the full-screen result replaces the F04 panel and the won composition; no Close; tests updated); `frontend.md` Visual Parity Evidence with screen recordings and frame timing (architecture §20.6) | Depends On: F03-UI-D2
- [ ] Task ID: F03-QA-D2 | Assigned Role: QA | Status: Queued | Summary: Final-stage independent visual QA of D2 (rubric ≥ 93 from runtime video; F04 AC1–AC10, F05 AC1 / AC12, F03 AC8 / AC11; lifecycle mid-sequence; D1 regression) (architecture §20.6) | Depends On: F03-FE-D2

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

motion-critical

## Design Foundation

ai-system/project-authority/design-foundation.md

## Visual Quality Gate

Pending

## Visual Evidence

Selected-source records for this surface, all in features/f00-design-foundation/design/:
* the result `S-04` (perfect), `S-04b` (new best), `S-05` (2★);
* the transition frames `S-08 … S-14` and the reduced frames `S-15`, `S-16`, taken from the executable prototype `design/src/S-transition-prototype.html` (F00 ui-design §11);
* the device variants `S-v-*` and the component sheet `S-91-components.png`.

Their manifest is features/f00-design-foundation/ui-design.md § Visual Evidence Manifest.

The shipped baseline is conformance-audit.md §6 and §12 (`design/audit/cur-won-*`, `cur-result-*`, `cur-a11y-ax5-result.png`, the pairs `pair-08 … pair-14`), captured at 615e94c. The current runtime (legacy won moment over the D1 board, dock on the goal rail per §19.9 (1)) is in features/f03-puzzle-play-session/qa/d1/ (QA-16-31 … 35, QV-16-won-L01-perfect.mp4) and qa/d1r/ (QA-16-L01-won-ax5-rest.jpg).

D1 records (the Play surface this transition starts from; gate Passed 2026-09-28) are listed in the archived orchestration history/f03-puzzle-play-session-2026-09-28/orchestration-before-phase-d2.md.

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
  * Result: PENDING
  * Provenance / Note: -

- Evidence ID: F03.D2-PARITY
  * Scenario: The runtime matches the D2 handoff on the canonical simulators — every variant beside its render; screen recordings of the full sequence (rows 0 and 4, a special-tile row), the retry transition and the reduced path, with frame timing (nothing outside the board before T0 + 600; rest ≤ T0 + 940; reduced ≈ 660); OS text large → AX5 on the result; Reduce Motion on and off; suites and integration_test green
  * Required Class: runtime + automated functional
  * Target / Environment: iOS Simulator 18.6 — iPhone 16 (primary), 16e, 16 Pro Max
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: F03.D2-HANDOFF accepted (gate Ready for Implementation)
  * Re-evaluation Trigger: F03-FE-D2 delivery
  * Blocks: Visual Quality Gate = Ready for QA; F03-QA-D2
  * Result: PENDING
  * Provenance / Note: -

- Evidence ID: F03.D2-VISUAL-QA
  * Scenario: An independent final-stage QA verdict on D2 — rubric ≥ 93 from runtime video (every dimension ≥ 8, no fail condition); F04 AC1–AC10 on the result, F05 AC1 / AC12, F03 AC8 / AC11; lifecycle mid-sequence; D1 Play regression
  * Required Class: runtime
  * Target / Environment: iOS Simulator 18.6, iPhone 16 / 16e / Pro Max; Android stated as a limit (ANDROID-CI-EVIDENCE)
  * Owner Role: QA
  * Prerequisite / External Decision: F03.D2-PARITY accepted (gate Ready for QA)
  * Re-evaluation Trigger: F03-QA-D2 activation
  * Blocks: Visual Quality Gate = Passed; F03 Done; D3 activation
  * Result: PENDING
  * Provenance / Note: -

## Open Decision Gates

None

## Blockers

None

## Next Action

Run UI Designer on F03-UI-D2 — the D2 handoff (Current Brief; architecture §20).

## Last Decision

2026-09-28 (D2 activation) — the Tech Lead reopened F03 as **Design Adoption Phase D2 — won moment + full-screen result** right after the D1 closure (§19.12).

**Classified:** Visual Scope `motion-critical` (audit §6, §8); carrier F03 with the F04 amendments and the F05 wording resync in the same reopen (C-2); Foundation Selected; gate Pending.

**Contract (architecture §20):**
* the timeline — nothing outside the board before T0 + 600, rest ≤ T0 + 940, reduced 660 ms; input locked until rest;
* system back honoured at any time in `won` (today's behaviour; the completion is persisted at `won`);
* the full-screen layout with only its own back button at rest, and one glow;
* C-4 markers (drop `3 / 3`, delta, `İLK`, "daha iyi"; `HARİKA` over `YENİ EN İYİ`) and the shipped CTA weighting;
* no Close; Retry restarts in place; Next is F05's handler;
* C-11 special tiles; C-9 on the result — fits without scroll up to the 1.3× cap, may scroll above it with a fixed back button;
* interim copy; no behaviour, scoring, persistence or route change.

**Amended in place:** F03 §4, §10, §13; F04 `architecture.md` §7 / §8; F05 `prd.md` AC1 and `architecture.md` §8 (C-3 wording resync, no PO revision); the design-foundation §18 correction marked applied. F04 and F05 stay Done.

**State:** Current Status Rework; F03-UI-D2 Open, F03-FE-D2 and F03-QA-D2 Queued; Delivery Review Pending; owner → UI Designer.

The terminal D1 orchestration is archived byte-for-byte as history/f03-puzzle-play-session-2026-09-28/orchestration-before-phase-d2.md.

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-28
* Summary: D2 activation — F03 reopened (`motion-critical`, architecture §20); F03-UI-D2 Open; owner → UI Designer.

## Context & Follow-ups

* **Phase D1 closed 2026-09-28** (Play; §19, closure §19.12). Its Play surface is the transition's starting frame and a regression input.
* **D2 inputs:** DESIGN-ADOPTION-CONTRACT-AMENDMENTS (D2 items, applied in §20); OPTIONAL-QUALITY-NOTES (the 30 ms stagger, text-scale density — both now in §20.3); NTLC-6 / A-2 result at AX5.
* **Still open, outside D2:** F03-MULTITOUCH-FIRST-POINTER; MOVESCARD-COUNTER-LINE-HEIGHT; ANDROID-CI-EVIDENCE.
* **Design Adoption Route:** workflow-follow-ups.md.
* **Audit:** features/f00-design-foundation/conformance-audit.md.

## History & Evidence References

* [QA report](qa.md) (D1R, 2026-09-28), [contract](architecture.md) (§12, §18, §19, §20), [UI design](ui-design.md) (§1–§14 D1; §16 won — superseded by D2), [frontend delivery](frontend.md).
* [Terminal D1 orchestration](../../history/f03-puzzle-play-session-2026-09-28/orchestration-before-phase-d2.md); the D1 working record in [history/f03-puzzle-play-session-2026-09-27/](../../history/f03-puzzle-play-session-2026-09-27/README.md); the [closure record of 2026-09-21](../../history/f03-closure-2026-09-21/orchestration.md) — historical only, not a run queue.
* [Portfolio follow-ups](../../workflow-follow-ups.md); [Phase C audit](../f00-design-foundation/conformance-audit.md).
* Canonical execution: role-execution-contract.md.

## Change Log

* 2026-09-18 to 2026-09-21 — migration, win-sequence rework, final QA, closure (behaviour / accessibility); full log in the closure record.
* 2026-09-27 to 2026-09-28 — Design Adoption Phase D1 (Loop Glass Play): reopened, handoff, delivery, QA Rejected, rework, re-QA Approved with Notes, gate Passed, **Done** (architecture §19; log in the archived terminal orchestration).
* 2026-09-28 — Tech Lead: D2 activation.
  * **Decided:** architecture §20 (contract and rulings); in-place amendments in F03 / F04 / F05; Visual Scope `motion-critical`; gate Pending.
  * **Next:** F03-UI-D2 Open; owner → UI Designer.

## Current Brief

**F03-UI-D2 — the D2 handoff: win sequence, transition and full-screen result** (contract: architecture.md §20; authority: design-foundation §18, F00 ui-design §4–§8, §11, §13)

**Deliver in F03 `ui-design.md`** — replace §16 (won composition) with the D2 sections. Keep §1–§14 (D1 Play) intact apart from cross-references.

**Must cover:**
1. **Layout** of the full-screen result per F00 ui-design §6, measured on the D1 Play geometry's device set: 393 × 852 primary, 390 × 844 and 440 × 956 variants. Only the result's own back button is chrome at rest (§20.3 (4)).
2. **Every variant** (§20.2), with the C-4 markers and badge rule and the CTA weighting (§20.3 (5–6)):
   * Perfect; Perfect + new best (`HARİKA` wins);
   * new best (2★); first clear; matched best; no improvement (1★, worse than best);
   * the no-optimal fallback; Next not wired ("Sonraki bölüm · yakında");
   * level 30 (Next → terminal; propose the label).
3. **Motion**, each with its reduced path (§20.3 (1), (7), (8)):
   * the win sequence on the D1 board: 30 ms stagger, bloom, dim; special tiles in the winning row turn lime and their icons fade (C-11);
   * the board → result transition: the row glides and morphs from the D1 tile to the result tile; chrome fades;
   * the result → Play transition for "Tekrar oyna" (≤ 400 ms).
   * Deliver an **executable prototype re-timed on the D1 geometry**, plus timed frame stills. The bounds are T0 + 600 / rest ≤ T0 + 940 / reduced 660; state any deviation as Needs Tech Lead Clarification.
4. **Renders:** every variant above; the winning row at rows 0 and 4; a locked / frozen tile in the winning row; an **AX5** result (container text capped, free text scaling, the scroll rule of §20.3 (9)); transition frames.
5. **Copy proposals** (interim, §20.3 (10)): the data-driven subtitle, the level-30 label, the back button's semantics "Ana ekrana dön". Turkish casing authored.
6. **Accessibility:** targets ≥ 44 pt; contrast of every label on its surface; the star count and badges in `Semantics`; non-colour cues for the win and earned stars.
7. **Screen / State / Viewport matrix, Visual Evidence Manifest, and a D2 acceptance list** that Frontend and QA can test item by item.

**The visible exit:** the back button (F00 ui-design §17 proposal 1) is the Tech Lead's accepted default. The user may still veto it; if the design needs another exit, raise it as Needs Tech Lead Clarification rather than changing it silently.

**Non-goals:** no engine, scoring, persistence, route or lifecycle change; Home (D3); audio / haptics (F11, intent only); no code.

**Exit:** the handoff with renders and prototype, F03.D2-HANDOFF recorded, Delivery Review Pending, owner → Tech Lead (visual-gate checkpoint).

## Earlier briefs

* D1 briefs (F03-UI-D1, F03-FE-D1, F03-QA-D1, F03-FE-D1R, F03-QA-D1R) — archived byte-for-byte in history/f03-puzzle-play-session-2026-09-27/.
