# F00 — design-foundation: Orchestration

## Feature ID

F00

## Current Status

In Progress

## Current Owner

Tech Lead

## Next Role

Tech Lead

## Active Task Ledger

- [x] Task ID: F00-UI-FOUNDATION | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-21 — project-authority/design-foundation.md (Status Draft, nothing selected): two materially different rendered directions (A Backlit Stage, B Gazette) on identical Play / lifted-row / locked+frozen / Won Perfect + 2★ / Journey home / tutorial states with won-moment stills, device variants, Turkish glyph + tabular + contrast specimens, motion language, recommendation, shipped-surface impact list | Depends On: -
- [x] Task ID: F00-UI-DIRECTION-C | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-21 — Direction C (Loop Glass) rendered from the user's reference screens on the same states as A/B (+ resolved/literal, sheet/full-screen and semantics alternatives, device variants, specimen with measured contrast) and three reference-frame parity comparisons; design-foundation.md §17 (system, motion, measured tokens, contract conflicts, deviations D1-D11, content-delta table, confirmations needed); A/B recorded as rejected; Status stays Draft | Depends On: F00-UI-FOUNDATION
- [x] Task ID: F00-UI-FINALIZE | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-21 — selected-source renders for the final decision set (Play, lifted row, locked+frozen, full-screen Result perfect / new best / 2-star, Home design + today, tutorial, device variants), an executable board-to-result transition prototype with timed and reduced-motion stills, a component/token sheet, and the design-system handoff features/f00-design-foundation/ui-design.md (Visual Evidence Manifest with selected-source and motion-prototype records); Foundation stays Selected | Depends On: F00-UI-DIRECTION-C

## Open Tasks

None

## Handoff Plan

None

## Delivery Review

Pending

## QA Scope

none

## QA Stage

none

## QA Result

None

## Release Scope

none

## Release Result

None

## Visual Scope

design-system

## Design Foundation

ai-system/project-authority/design-foundation.md

## Visual Quality Gate

Pending

## Visual Evidence

User-supplied canonical-reference screens: features/f00-design-foundation/design/reference/user-ref-1-home.png, user-ref-2-play.webp, user-ref-3-completion.webp (provided by the user 2026-09-21; not yet a selected-source).

## QA Modules

none

## Regression Depth

not-set

## Evidence Reuse

not-evaluated

## Pending Evidence

- Evidence ID: F00.DIRECTION-RENDERS
  * Scenario: At least two materially different rendered directions (real image/PDF/HTML-render artefacts) of the same Play (idle + lifted row + locked/frozen), Won moment + F04 panel (Perfect, 2★), Journey home (in-progress ring) and tutorial states, plus a Turkish glyph / tabular-figure specimen, recorded as direction-render records in a Visual Evidence Manifest
  * Required Class: manual
  * Target / Environment: iPhone 16 393×852 reference frame (platform.md §14); 16e and 16 Pro Max variants for the critical states
  * Owner Role: UI Designer
  * Prerequisite / External Decision: None
  * Re-evaluation Trigger: F00-UI-FOUNDATION delivery
  * Blocks: Foundation selection; every visual implementation task
  * Result: PASS
  * Provenance / Note: 2026-09-21 UI Designer, HEAD 1d1ae14 + uncommitted working tree: 2 directions x 10 frames at 393x852 (Play idle, lifted row, locked+frozen, Won Perfect, Won 2-star, Journey home, tutorial, and three won-moment stills), 16e and Pro Max variants of Play idle and Won Perfect, a type/glyph/contrast specimen per direction, composites — 40 files in features/f00-design-foundation/design/ (generator in src/, HTML/CSS rendered with headless Chrome at DPR 2). Generated design artefacts, not app runtime captures; no motion prototype or video, no OS text-scale render, no Android frame; renders use Blink not Flutter, so implementation fidelity is unproven. Independent QA scoring pending selection and implementation.

- Evidence ID: F00.DIRECTION-C-RENDERS
  * Scenario: Direction C rendered from the user's reference language on the same states as A/B (Play idle, lifted row, locked+frozen, Won Perfect and 2-star, Journey home, column tutorial, won-moment stills) at 393x852, with 16e and Pro Max variants, Turkish glyph / tabular / contrast specimen, recorded as direction-render records in the Foundation manifest
  * Required Class: manual
  * Target / Environment: iPhone 16 393x852 reference frame (platform.md §14); 16e and 16 Pro Max variants for the critical states
  * Owner Role: UI Designer
  * Prerequisite / External Decision: None
  * Re-evaluation Trigger: F00-UI-DIRECTION-C delivery
  * Blocks: Foundation selection; every visual implementation task
  * Result: PASS
  * Provenance / Note: 2026-09-21 UI Designer, HEAD 8b1a3d5 + uncommitted working tree: Direction C x 14 frames at 393x852 (Play idle, row lifted resolved + reference-literal, locked+frozen, Won Perfect + 2-star as a bottom-anchored sheet, full-screen completion and reference-semantics alternatives, Home with the reference composition and shipped-scope only, column tutorial, three won-moment stills), 16e and Pro Max variants, a specimen with computed and measured contrast, composites — in features/f00-design-foundation/design/ (generator src/gen-c.mjs; HTML/CSS rendered with headless Chrome at DPR 2). Generated design artefacts, not app runtime captures; no motion prototype or video, no OS text-scale render, no Android frame; Blink not Flutter. Folder now holds ~27 MB of PNGs (65 files) — prune or compress if repo size matters.

- Evidence ID: F00.REFERENCE-PARITY
  * Scenario: Side-by-side parity between each user reference screen (Home, Play, Completion) and the corresponding Direction C render on the reference frame, with every deviation (contrast fixes, contract conflicts, shipped-content substitutions) listed and justified
  * Required Class: manual
  * Target / Environment: reference frame 716x1434 (2x of 358x717) and the 393x852 canonical frame
  * Owner Role: UI Designer
  * Prerequisite / External Decision: None
  * Re-evaluation Trigger: F00-UI-DIRECTION-C delivery
  * Blocks: Foundation selection
  * Result: PASS
  * Provenance / Note: 2026-09-21 UI Designer: parity-1-home.png, parity-2-play.png, parity-3-completion.png (user reference | Direction C render on the same 358x717 @2x frame; renders C-P1/P2/P3). Deviations D1-D11 listed in design-foundation.md §17.8 (Turkish casing fixes, earned stars filled, node overlap and text wrap fixed, status chrome, active-row accent resolved with a literal variant, contract-conforming completion with a reference variant). Palette and small-label colours MEASURED from the reference pixels (§17.4); the brief's assumption that the reference's small caps were a contrast weakness was disproved by measurement (5.6-9.6:1).

- Evidence ID: F00.SELECTED-SOURCE
  * Scenario: Selected-source renders reflecting the final decision set (§18): Play idle / lifted row / locked+frozen, full-screen solved result (Perfect and 2-star) with the board-to-result transition and a proposed visible exit, Home with future-scope items and the `Looplet` wordmark, column tutorial — recorded as `selected-source` in a Visual Evidence Manifest inside the F00 ui-design.md handoff
  * Required Class: manual
  * Target / Environment: iPhone 16 393x852 reference frame (platform.md §14); 16e and Pro Max variants for the critical states
  * Owner Role: UI Designer
  * Prerequisite / External Decision: None (F00.FOUNDATION-SELECTION RESOLVED)
  * Re-evaluation Trigger: F00-UI-FINALIZE delivery
  * Blocks: Visual Quality Gate = Ready for Implementation; every visual implementation task
  * Result: PASS
  * Provenance / Note: 2026-09-21 UI Designer, HEAD cc7fe3f + uncommitted working tree: 24 selected-source PNGs (S-01 … S-16, S-v-*, S-91) plus contact sheets in features/f00-design-foundation/design/, the executable prototype design/src/S-transition-prototype.html (frames S-08…S-16 are captured from it), and ui-design.md with a Visual Evidence Manifest (3 direction-render, 3 canonical-reference, parity-comparison, selected-source and motion-prototype records). Generated HTML/CSS renders (Blink), not Flutter or simulator captures; no OS-text-scale, loading/error/recovery or Android renders; the motion prototype is not a Flutter prototype. Independent QA scoring pending implementation.

## Open Decision Gates

- Decision ID: F00.FOUNDATION-SELECTION
  * Question: Which direction becomes the project Design Foundation (Status: Selected)? Directions A and B were rejected by the user on 2026-09-21; Direction C ("Loop Glass", design-foundation.md §17) was rendered from the user's reference screens.
  * Options / Trade-offs: The choice is presented to the user as a plain-language visual guide (design/guide-0 … guide-7, Turkish) with six sub-decisions, each with two options and a recommendation: (1) dragged row: 1 = cream tile with a periwinkle rim (recommended) · 2 = lime as in the user's reference; (2) solved screen: 1 = bottom sheet over the board with Close kept (recommended) · 2 = full-screen result; (3) result numbers: 1 = SEN / OPTİMAL / EN İYİ (recommended) · 2 = SEN / OPTİMAL / +3 YILDIZ; (4) the five items in the user's screens that the game does not have yet (settings button, streak chip, stars chip, level-info card, gesture hint): 1 = remove from the design · 2 = keep in the design as future scope, not implemented until their feature exists (recommended); (5) wordmark: 1 = lowercase `looplet` (recommended) · 2 = uppercase `LOOPLET`; (6) Turkish copy: 1 = the reference's wording as proposed copy (recommended) · 2 = the current game's wording. Answers: A) select Direction C with every recommendation; B) select Direction C with overrides written as `B: <decision>=<option>, ...` (unlisted decisions keep the recommendation); C) do not select — request a revision (state it).
  * Recommendation: A
  * Blocks: Foundation Status Selected, Design Adoption Route Phase C/D and every visual implementation task; not the F05 / F08 queue
  * Blocking Scope: feature
  * Status: RESOLVED
  * Resolution: B — the user selected Direction C (Loop Glass) with two overrides (`B: 2=2, 5=Looplet`): decision 2 = full-screen solved result with no Close button (option 2); decision 5 = wordmark `Looplet` (capital L only, the last three letters `let` lime) — a variant of their own; decisions 1, 3, 4, 6 keep the recommendations (periwinkle-rim active row; EN İYİ personal best; the five not-yet-existing items stay in the design as future scope; the reference's Turkish wording as proposed copy). Recorded in design-foundation.md §18; the Foundation is Status: Selected.
  * Resolved At: 2026-09-21

## Blockers

None

## Next Action

Tech Lead (mandatory visual-gate checkpoint): review F00-UI-FINALIZE — ui-design.md, the S-* selected-source renders, the transition prototype and the manifest — and record the delivery. If complete, set Visual Quality Gate = Ready for Implementation (the audit then requires the selected Foundation reference, ui-design.md with a Visual Evidence Manifest, and >= 2 direction-render records — all present). Ask the user about the two open proposals (visible exit chevron on the Result; one-glow rule on the Result) or decide them. Then plan the Frontend design-system task (bundle fonts, tokens/theme, drawn icon set, `Looplet` wordmark, shared components) and Phase C (conformance audit of F03 / F04 / F05 surfaces; contract amendments DESIGN-ADOPTION-CONTRACT-AMENDMENTS at each visual-rework activation).

## Last Decision

2026-09-21 — Tech Lead opened F00 as the carrier of the Design Adoption Route (workflow-follow-ups.md) after F03 closed Done: the UI Designer prompt requires a feature orchestration to work in, and the Foundation is cross-cutting. F00 is not a PRD feature and carries no product criteria. Selection authority stays with the user / Product Owner (or an explicit delegation); nothing here selects a direction.

2026-09-21 (incident) — The user rejected BOTH rendered directions (A Backlit Stage, B Gazette): "neither is modern; not the style I expect" — and supplied three reference screens (Home, Play, Completion) as the expected style. Tech Lead decisions: (1) A and B are recorded as rejected by the selection authority; their renders stay as the explored alternatives in the Foundation (the exploration gate — two rendered, materially different directions — was met by them; C makes three rendered). (2) The user's screens are treated as a canonical-reference for VISUAL LANGUAGE (palette, type feel, radii, glass surfaces, icon style, tone, composition). Content in those screens that is not in the shipped product is NOT treated as a requirement: it is flagged as a proposal with an owner (see Current UI Brief, Content deltas) — the user may override this interpretation. (3) Direction C is rendered and confirmed by the user before it can be Selected; the recommendation is C. (4) Process lesson: the first exploration did not collect the user's aesthetic references before rendering; future direction rounds start from user references when they exist. No app, contract or product file changed.

2026-09-21 (checkpoint) — Tech Lead reviewed the F00-UI-DIRECTION-C delivery: artefacts present and consistent with design-foundation.md §17; no app/package/content file changed; the Foundation stays Draft. Delivery Review = Accepted. Rulings on the UI Designer's clarification items: (1) the 93 / every-dimension-≥8 bar applies to implemented surfaces scored by independent QA; a Foundation draft's self-review is advisory and dimensions 7 and 10 are capped at 8 before a prototype and a runtime build — no rework needed for 87. (2) No Flutter-rendered comparison is required before selection (the user chose the style from renders); a working win-sequence motion prototype and a runtime parity pass become Phase D tasks. (3) Contract positions, effective only if the user selects C and each needing a TL contract amendment at Phase D activation: the answer row landing where the target rail was (F03 §16.3) is approved in principle because the reference header leaves no dock zone; F03 §16 sheet-over-dimmed-board and Close (F04 AC) stay; completion stats keep the shipped personal-best semantics; the one-glow rule stays unless the user asks otherwise — Phase D handoff must show one glow (the docked row) with star fill and CTA as non-glow emphasis. (4) Content deltas (settings, streak chip, stars chip, level-info card, gesture hint, copy) are not requirements; they stay proposals in workflow-follow-ups.md (USER-REFERENCE-CONTENT-DELTAS) with named owners. (5) The design folder holds ~27 MB of PNGs; after selection the rejected-direction variants may be pruned — logged as a follow-up, not done now.

2026-09-21 (incident) — The user could not understand the selection request: file codes (C-02, C-04…) and "lowercase / uppercase looplet" meant nothing to them. Tech Lead action: no state change to the decision itself, but the request was rewritten in plain language and rebuilt as an eight-image Turkish visual guide (design/guide-*.png; source src/guide.py) with side-by-side options and a one-line reply format; the gate's options above now mirror it. One recommendation changed while simplifying: decision 4 (items the game does not have yet) is recommended as "keep in the design as future scope, not implemented now" instead of removing them — it keeps the user's vision at no scope cost. Process lesson: decisions put to the user must be visual, in the user's language, with named options instead of internal codes.

2026-09-21 (selection) — The user decided F00.FOUNDATION-SELECTION as `B: 2=2, 5=Looplet`: Direction C selected; the solved screen is the FULL-SCREEN composition with NO Close button (override of the recommendation); the wordmark is `Looplet` (capital L only, last three letters `let` lime — the user's own variant); decisions 1, 3, 4, 6 keep the recommendations. Tech Lead: gate RESOLVED; design-foundation.md Status Selected (Selected By: user; Decision Reference: this gate); the decision set is recorded in §18. Interpretation: (1) Close is defined in F03/F04 feature architecture, not in the PRD, so removing it is a Tech Lead contract amendment, not a Product Owner revision; it is deferred to the F03/F04 visual-rework activation and logged in workflow-follow-ups.md (DESIGN-ADOPTION-CONTRACT-AMENDMENTS); (2) a player must still have a way home — system back/edge swipe stays and the UI Designer proposes a visible affordance the user may veto; (3) the earlier contract positions (row lands where the rail was; content-driven sheet) are superseded; the one-glow rule stays. Next: F00-UI-FINALIZE (selected-source renders + design-system handoff).

2026-09-21 (finalize) — UI Designer delivered F00-UI-FINALIZE: selected-source renders for the decision set, an executable transition prototype (frames taken from it), a component/token sheet and the design-system handoff ui-design.md. Foundation stays Selected (the UI Designer changed no selection). Open proposals for the Tech Lead / user: (a) a visible back chevron as the Result's way home (the user removed the Close button, a way home is still required); (b) one-glow rule on the Result — CTA and stars non-glow, which differs from the user's reference; plus the count-aware subtitle copy (PO / localization) and lifting 43.9 pt targets to 44 / the HAMLE caption to >= 11 pt in Phase D. Provisional self-review 87 (motion, originality, fidelity capped at 8).

## Last Update

* Updated By: UI Designer
* Timestamp: 2026-09-21
* Summary: F00-UI-FINALIZE delivered (selected-source renders, transition prototype, component sheet, ui-design.md); F00.SELECTED-SOURCE PASS; Delivery Review Pending; owner Tech Lead for the visual-gate checkpoint.

## Context & Follow-ups

Why now: the ai-system upgrade (cfd6b59) made an independent visual gate (>= 93 total, every rubric dimension >= 8, rendered evidence) mandatory for visual scope, and the project has no Selected Foundation; shipped visuals use the default system font, Material icons and text-only legacy directions with self-scores only. F05-QA-STRICT and F08 local evidence continue in parallel queue positions (they are Visual Scope none / non-visual); no feature with a visual scope activates before Selected.

## History & Evidence References

* [Scope contract](architecture.md); [Design Adoption Route](../../workflow-follow-ups.md); [platform.md §14](../../project-authority/platform.md).
* Shipped identity for reference: `app/lib/play/play_theme.dart`; surfaces documented in F03 ui-design.md (§5–§8, §16), F04 ui-design.md, F05 ui-design.md.
* Canonical execution: role-execution-contract.md.

## Change Log

* 2026-09-21 — Tech Lead: F00 created; F00-UI-FOUNDATION activated.
* 2026-09-21 — UI Designer: F00-UI-FOUNDATION delivered; owner -> Tech Lead (selection decision to be opened).
* 2026-09-21 — Tech Lead: incident — user rejected A and B and supplied reference screens; delivery Accepted; F00-UI-DIRECTION-C activated for the UI Designer.
* 2026-09-21 — UI Designer: F00-UI-DIRECTION-C delivered; owner -> Tech Lead (user confirmation of Direction C to be requested).
* 2026-09-21 — Tech Lead: delivery Accepted; gate F00.FOUNDATION-SELECTION OPEN (user); clarification items ruled.
* 2026-09-21 — Tech Lead: incident — decision request re-presented as a plain-language visual guide (design/guide-*.png).
* 2026-09-21 — Tech Lead: decision F00.FOUNDATION-SELECTION RESOLVED (B: 2=2, 5=Looplet); Foundation Selected; F00-UI-FINALIZE activated.
* 2026-09-21 — UI Designer: F00-UI-FINALIZE delivered; owner -> Tech Lead (visual-gate checkpoint).

## Current UI Brief (F00-UI-FINALIZE — activated 2026-09-21; DELIVERED, see ui-design.md)

Read: `project-authority/design-foundation.md` (Status **Selected**; §17 Direction C; **§18 the user's decision set**), this orchestration, the A/B/C renders and the user's reference screens (`design/reference/`), `design/design-doctrine.md`, `design/premium-ui-rubric.md`, `design/visual-quality-gate.md`, `templates/feature-ui-design.template.md`, F03 `ui-design.md` §16 and F03 `architecture.md` §18 (current won-moment contract), F04 `architecture.md` (exit behaviour) and `ui-design.md`.

**What the user decided (§18):** Direction C. Active row = cream + periwinkle rim. **Solved screen = full-screen result, no board behind, no Close button.** Third stat = EN İYİ. The five items the game does not have yet stay in the design as future scope. **Wordmark = `Looplet`** (capital L only, last three letters `let` lime). Reference Turkish wording as proposed copy.

**Deliver (task F00-UI-FINALIZE):**
1. **Selected-source renders** (same evidence discipline: real images under `design/`, generator source kept, recorded as `selected-source` in the manifest) for: Play idle · lifted row · locked + frozen · **full-screen solved result** (Perfect, and the 2★ variant with Retry as the primary action) · Home (with the future-scope items, marked so) · column tutorial. The wordmark is `Looplet` everywhere it appears. Correct any remaining case bug (`İ`/`ı`).
2. **Solved-result design decisions the user left to you:** (a) a **visible way home** without a Close button (a small, reference-consistent affordance — e.g. a back chevron consistent with the Play screen — plus system back/edge swipe); the user may veto it; (b) the **board → full-screen result transition**: how the winning row and the result content arrive, keeping the contracted intent (input locked at the win, the result not shown before the win sequence has been seen, ≤ 940 ms total, one glow, the reduced-motion path of F03 §16.2); provide timed frame stills and, if feasible, a short timed frame sequence — note that a working prototype is a Phase D task; (c) how **2★ / new-best** variants read on the same composition.
3. **`features/f00-design-foundation/ui-design.md`** — the design-system handoff (use the feature template): tokens (colour roles, type roles and scale, spacing, radii, shadows/glow rules), the two OFL font families and the drawn icon set (delivery mechanism is a Frontend decision), component decisions (glass card, tile states incl. active/locked/frozen/winning, pills, stat card, node track, badges), state design, motion/sensory spec incl. reduced motion, screen/state/viewport matrix, **Visual Evidence Manifest with `selected-source` records**, provisional self-review (honest), Frontend handoff.
4. Update `design-foundation.md` only where the final renders change it (e.g. the §17.6 items now superseded); keep it Selected — you never change the selection.

Constraints that do not move: portrait, 5×5 wrap-shift interaction, ≥ 44 pt targets, no colour-only state, measured contrast (labels ≥ 4.5 : 1), Turkish casing rule, bundled OFL fonts, no third-party assets. Non-goals: no app code; no product decision; no contract edit (contract amendments for F03 §16/§18 and F04 belong to the Tech Lead at the visual-rework activation). Return to the Tech Lead (mandatory visual-gate checkpoint) with `Next Role` = Tech Lead.
