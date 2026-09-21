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
- [x] Task ID: F00-FE-DESIGN-SYSTEM | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-21 — app/lib/design layer (tokens, type roles on the bundled Space Grotesk and Manrope variable fonts, 12 drawn icons, Looplet wordmark, Turkish casing helpers, every component in every state) plus the debug-only gallery lib/main_gallery.dart; no shipped surface changed (only tracked change is the pubspec.yaml font declaration, no dependency); analyzer, format, melos test (197 package tests, 305 app tests of which 62 new) and the F03 device suite 13 of 13 green; runtime parity on iPhone 16, 16e and 16 Pro Max beside S-91 with one deviation found and fixed (frozen tile ring and dash rhythm) and the rest listed; evidence in features/f00-design-foundation/frontend.md | Depends On: F00-UI-FINALIZE
- [ ] Task ID: F00-QA-VISUAL | Assigned Role: QA | Status: Queued | Summary: Independent visual QA of the implemented design system on the canonical simulator (visual-quality module, rubric 93 plus, every dimension 8 plus) against the selected-source renders; activated only after Tech Lead reconciliation | Depends On: F00-FE-DESIGN-SYSTEM

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

Ready for Implementation

## Visual Evidence

Selected-source and reference records: features/f00-design-foundation/ui-design.md § Visual Evidence Manifest (3 direction-render, canonical-reference, parity-comparison, selected-source and motion-prototype records); artefacts under features/f00-design-foundation/design/ (S-*.png, S-91-components.png, parity-*.png, sheet-S*.png, src/S-transition-prototype.html); user references in design/reference/. Runtime records (2026-09-21, Frontend/Mobile Developer): features/f00-design-foundation/frontend.md § Visual Parity Evidence (7 runtime-screenshot and 3 parity-comparison records; runtime-iphone16-*.png, runtime-iphone16e-sheet.png, runtime-iphone16promax-sheet.png, parity-runtime-1..3 under design/); the gate stays Ready for Implementation until the Tech Lead reconciles.

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

- Evidence ID: F00.DS-AUTOMATED
  * Scenario: Token values, Turkish uppercasing cases, component state tests, analyzer, format, full melos test suite and the F03 device suite stay green with no shipped-surface change
  * Required Class: automated functional
  * Target / Environment: workspace (melos) plus the F03 integration suite on one simulator
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: None
  * Re-evaluation Trigger: F00-FE-DESIGN-SYSTEM delivery
  * Blocks: Visual Quality Gate = Ready for QA
  * Result: PASS
  * Provenance / Note: 2026-09-21 Frontend/Mobile Developer, HEAD 9a72481 + uncommitted working tree, all commands after the final code change: melos run analyze exit 0; melos run format:check exit 0 (170 files, 0 changed); melos run test exit 0 (packages 22+17+32+20+23+83 = 197, app 305 = 243 pre-existing unchanged + 62 new in app/test/design); flutter test integration_test on the iPhone 16 iOS 18.6 simulator D0011CE7 → +13 All tests passed, exit 0 (F03 device suite, unchanged); flutter build ios --simulator --debug -t lib/main_gallery.dart exit 0. No shipped file imports app/lib/design; the only tracked change is the pubspec.yaml font declaration. Limits: widget tests render unloaded fonts with Ahem (only the gallery layout tests load the real fonts), so they prove structure, tokens, semantics and states, not pixels; contrast is computed from token values. Detail in frontend.md §17.

- Evidence ID: F00.DS-PARITY
  * Scenario: Runtime gallery screenshots of every component and state next to design/S-91-components.png and per-component crops (Visual Parity Evidence with runtime-screenshot and parity-comparison records), a Turkish-glyph and weight-axis check, deviations listed
  * Required Class: runtime
  * Target / Environment: iOS Simulator iPhone 16 (393x852) plus 16e and Pro Max variants (platform.md §14)
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: None (fonts and icons decided, platform.md §14)
  * Re-evaluation Trigger: F00-FE-DESIGN-SYSTEM delivery
  * Blocks: Visual Quality Gate = Ready for QA
  * Result: PASS
  * Provenance / Note: 2026-09-21 Frontend/Mobile Developer, HEAD 9a72481 + uncommitted working tree: real Flutter captures of the debug gallery on iOS Simulator 18.6 — iPhone 16 393x852 (5 frames at fixed scroll offsets), 16e 390x844 and 16 Pro Max 440x956 (5 frames each) — plus three side-by-side parity boards against design/S-91-components.png (and the C-03 frame for the lock and snowflake icons the specimen omits), a Turkish-glyph / tabular / weight-axis frame (all İ I Ş Ğ Ç Ö Ü and ı ş ğ ç ö ü correct, weights 400 to 700 distinct for both fonts) — artefacts runtime-iphone16-*.png, runtime-iphone16e-sheet.png, runtime-iphone16promax-sheet.png, parity-runtime-1..3 in design/, records in frontend.md Visual Parity Evidence. One real deviation was found by the parity pass and fixed (frozen tile solid ring and dash rhythm, tile.dart / icons.dart, test added; every capture retaken on the fixed build); intentional or specimen-composition differences D1-D7 are listed. Bundle cost 310,258 B (~0.30 MB) of fonts and licence texts uncompressed; the release IPA delta was NOT measured. Limits: visual side-by-side review with no pixel-diff threshold; debug build on a simulator, not release or a device; no on-device Dynamic Type render, no VoiceOver run, no performance profile; nothing consumes the design system yet. Independent scoring is F00.VISUAL-QA.

- Evidence ID: F00.VISUAL-QA
  * Scenario: Independent premium-rubric scoring of the implemented design system on the canonical target (final score, lowest dimension, fail conditions, complete runtime evidence)
  * Required Class: runtime
  * Target / Environment: iOS Simulator, debug build of the exact revision, gallery plus any surface that already consumes the design system
  * Owner Role: QA
  * Prerequisite / External Decision: F00-FE-DESIGN-SYSTEM delivered and reconciled; Visual Quality Gate = Ready for QA
  * Re-evaluation Trigger: Tech Lead activates F00-QA-VISUAL
  * Blocks: Visual Quality Gate = Passed; F00 Done
  * Result: PENDING

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

Run Tech Lead to reconcile the F00-FE-DESIGN-SYSTEM delivery (frontend.md; evidence F00.DS-AUTOMATED and F00.DS-PARITY are PASS with provenance and limits): verify the runtime records, rule on the deviation list D1-D7 (none needs a contract change), then set Delivery Review and — if accepted — Visual Quality Gate = Ready for QA and activate F00-QA-VISUAL (QA plan: visual-quality module, rubric 93 plus, every dimension 8 plus; the gallery can be reproduced with design/src/capture-gallery.sh). Phase C (conformance of F03 / F04 / F05 surfaces, each as visual rework with its contract amendment) follows the design system.

## Last Decision

2026-09-21 — Tech Lead opened F00 as the carrier of the Design Adoption Route (workflow-follow-ups.md) after F03 closed Done: the UI Designer prompt requires a feature orchestration to work in, and the Foundation is cross-cutting. F00 is not a PRD feature and carries no product criteria. Selection authority stays with the user / Product Owner (or an explicit delegation); nothing here selects a direction.

2026-09-21 (incident) — The user rejected BOTH rendered directions (A Backlit Stage, B Gazette): "neither is modern; not the style I expect" — and supplied three reference screens (Home, Play, Completion) as the expected style. Tech Lead decisions: (1) A and B are recorded as rejected by the selection authority; their renders stay as the explored alternatives in the Foundation (the exploration gate — two rendered, materially different directions — was met by them; C makes three rendered). (2) The user's screens are treated as a canonical-reference for VISUAL LANGUAGE (palette, type feel, radii, glass surfaces, icon style, tone, composition). Content in those screens that is not in the shipped product is NOT treated as a requirement: it is flagged as a proposal with an owner (see Current UI Brief, Content deltas) — the user may override this interpretation. (3) Direction C is rendered and confirmed by the user before it can be Selected; the recommendation is C. (4) Process lesson: the first exploration did not collect the user's aesthetic references before rendering; future direction rounds start from user references when they exist. No app, contract or product file changed.

2026-09-21 (checkpoint) — Tech Lead reviewed the F00-UI-DIRECTION-C delivery: artefacts present and consistent with design-foundation.md §17; no app/package/content file changed; the Foundation stays Draft. Delivery Review = Accepted. Rulings on the UI Designer's clarification items: (1) the 93 / every-dimension-≥8 bar applies to implemented surfaces scored by independent QA; a Foundation draft's self-review is advisory and dimensions 7 and 10 are capped at 8 before a prototype and a runtime build — no rework needed for 87. (2) No Flutter-rendered comparison is required before selection (the user chose the style from renders); a working win-sequence motion prototype and a runtime parity pass become Phase D tasks. (3) Contract positions, effective only if the user selects C and each needing a TL contract amendment at Phase D activation: the answer row landing where the target rail was (F03 §16.3) is approved in principle because the reference header leaves no dock zone; F03 §16 sheet-over-dimmed-board and Close (F04 AC) stay; completion stats keep the shipped personal-best semantics; the one-glow rule stays unless the user asks otherwise — Phase D handoff must show one glow (the docked row) with star fill and CTA as non-glow emphasis. (4) Content deltas (settings, streak chip, stars chip, level-info card, gesture hint, copy) are not requirements; they stay proposals in workflow-follow-ups.md (USER-REFERENCE-CONTENT-DELTAS) with named owners. (5) The design folder holds ~27 MB of PNGs; after selection the rejected-direction variants may be pruned — logged as a follow-up, not done now.

2026-09-21 (incident) — The user could not understand the selection request: file codes (C-02, C-04…) and "lowercase / uppercase looplet" meant nothing to them. Tech Lead action: no state change to the decision itself, but the request was rewritten in plain language and rebuilt as an eight-image Turkish visual guide (design/guide-*.png; source src/guide.py) with side-by-side options and a one-line reply format; the gate's options above now mirror it. One recommendation changed while simplifying: decision 4 (items the game does not have yet) is recommended as "keep in the design as future scope, not implemented now" instead of removing them — it keeps the user's vision at no scope cost. Process lesson: decisions put to the user must be visual, in the user's language, with named options instead of internal codes.

2026-09-21 (selection) — The user decided F00.FOUNDATION-SELECTION as `B: 2=2, 5=Looplet`: Direction C selected; the solved screen is the FULL-SCREEN composition with NO Close button (override of the recommendation); the wordmark is `Looplet` (capital L only, last three letters `let` lime — the user's own variant); decisions 1, 3, 4, 6 keep the recommendations. Tech Lead: gate RESOLVED; design-foundation.md Status Selected (Selected By: user; Decision Reference: this gate); the decision set is recorded in §18. Interpretation: (1) Close is defined in F03/F04 feature architecture, not in the PRD, so removing it is a Tech Lead contract amendment, not a Product Owner revision; it is deferred to the F03/F04 visual-rework activation and logged in workflow-follow-ups.md (DESIGN-ADOPTION-CONTRACT-AMENDMENTS); (2) a player must still have a way home — system back/edge swipe stays and the UI Designer proposes a visible affordance the user may veto; (3) the earlier contract positions (row lands where the rail was; content-driven sheet) are superseded; the one-glow rule stays. Next: F00-UI-FINALIZE (selected-source renders + design-system handoff).

2026-09-21 (finalize) — UI Designer delivered F00-UI-FINALIZE: selected-source renders for the decision set, an executable transition prototype (frames taken from it), a component/token sheet and the design-system handoff ui-design.md. Foundation stays Selected (the UI Designer changed no selection). Open proposals for the Tech Lead / user: (a) a visible back chevron as the Result's way home (the user removed the Close button, a way home is still required); (b) one-glow rule on the Result — CTA and stars non-glow, which differs from the user's reference; plus the count-aware subtitle copy (PO / localization) and lifting 43.9 pt targets to 44 / the HAMLE caption to >= 11 pt in Phase D. Provisional self-review 87 (motion, originality, fidelity capped at 8).

2026-09-21 (visual-gate checkpoint) — Tech Lead reviewed F00-UI-FINALIZE: ui-design.md, the S-* selected-source renders, the executable transition prototype (frames taken from it), the component/token sheet and the manifest are complete and consistent with design-foundation.md §17/§18; Delivery Review = Accepted; Visual Quality Gate = Ready for Implementation (Foundation Selected, ui-design.md with a Visual Evidence Manifest and three direction-render records present). Rulings on the UI Designer's proposals (defaults stand unless the user vetoes): (1) a visible back chevron is the Result's way home — the user removed the Close BUTTON, F04 architecture keeps 'Close / system back pops to the caller', so system back / edge swipe plus the chevron satisfy the contract; (2) the one-glow rule stays on the Result — CTA and stars non-glow (differs from the user's reference; a user request would be a contract amendment); (3) count-aware subtitle copy stays a PO / localization item; the 43.9 pt targets and the 10.4 pt HAMLE caption are corrected in Phase D. Next: the design-system layer is implemented first (F00-FE-DESIGN-SYSTEM) with NO shipped-surface change, then independently QA'd; per-feature conformance follows. platform.md §14 updated (fonts and icons decided).

## Last Update

* Updated By: Frontend/Mobile Developer
* Timestamp: 2026-09-21
* Summary: F00-FE-DESIGN-SYSTEM delivered and closed; F00.DS-AUTOMATED and F00.DS-PARITY PASS; Delivery Review = Pending; owner -> Tech Lead (reconciliation). Visual Quality Gate untouched (Ready for Implementation).

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
* 2026-09-21 — Tech Lead: visual-gate checkpoint passed (Ready for Implementation); F00-FE-DESIGN-SYSTEM activated; F00-QA-VISUAL queued.
* 2026-09-21 — Frontend/Mobile Developer: F00-FE-DESIGN-SYSTEM delivered (app/lib/design, fonts, debug gallery, 62 tests, runtime parity on three simulators, frozen-tile deviation found and fixed); task Done; F00.DS-AUTOMATED and F00.DS-PARITY PASS; Delivery Review = Pending; owner -> Tech Lead.

## Current Frontend Brief (F00-FE-DESIGN-SYSTEM — activated 2026-09-21)

Read: `features/f00-design-foundation/architecture.md` **§7 (the implementation contract — binding)**, `ui-design.md` (tokens §7–§8, motion §11, accessibility §13, handoff §14), `project-authority/design-foundation.md` (Selected; §17, §18), `design/S-91-components.png` (component/token reference), the S-* selected-source renders, `project-authority/platform.md` §14 (capture methods; fonts/icons decided), `design/visual-quality-gate.md`, `app/lib/play/play_theme.dart` (the shipped tokens you must NOT restyle) and `app/lib/reduce_motion.dart`.

Deliver: the `app/lib/design/` layer exactly as architecture.md §7 lists it — bundled Space Grotesk and Manrope (variable, OFL texts, `pubspec.yaml`; verify the weight axis, tabular figures and every Turkish capital and lowercase on the simulator), tokens (colour roles, gradients, radii, shadows, spacing scaled from the 358-pt reference), type roles, the drawn icon set (no new package without approval), the `Looplet` wordmark widget (capital L, `let` lime), `turkishUpper()`, the components (glass card and slate variant, board card, tile face in all seven states, target-rail tile, lime primary pill with glow and neutral-shadow variants, outline pill, text link incl. disabled, badge, moves card, round/square/undo buttons, stat card, loop-track node, star, wordmark) and a debug-only `DesignGalleryScreen` laid out like S-91.

Hard rules: **no shipped screen changes** (F03/F04/F05/F08 look and behaviour untouched; their suites unchanged and green); no game-logic/contract change; one-glow rule and the semantic colour separation (lime resolution, periwinkle active row/position) are part of the components; reduced motion via `reduceMotionRequested()`; the HAMLE caption and the 44-pt targets are built to the corrected values (>= 11 pt caption, 44 pt targets), noted as deviations from S-91 if they differ; anything needing a dependency or a bootstrap change is a Needs-Tech-Lead-Clarification.

Evidence (frontend.md, exact commands/targets/results): analyzer, format, `melos run test`, the F03 device suite on one simulator; Visual Parity Evidence — runtime gallery screenshots on iPhone 16 (393x852) and the 16e / Pro Max variants beside S-91 and per-component crops, a Turkish-glyph screenshot, bundle-size cost, deviations list. Mock/override limits stated. Close F00-FE-DESIGN-SYSTEM, Delivery Review = Pending, owner -> Tech Lead.

## Earlier briefs

The UI Designer briefs for F00-UI-FOUNDATION, F00-UI-DIRECTION-C and F00-UI-FINALIZE are delivered; their content lives in design-foundation.md (§4–§19), ui-design.md and the change log above.
