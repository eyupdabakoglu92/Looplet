# F00 — design-foundation: Orchestration

## Feature ID

F00

## Current Status

Rework

## Current Owner

Frontend/Mobile Developer

## Next Role

Frontend/Mobile Developer

## Active Task Ledger

- [x] Task ID: F00-UI-FOUNDATION | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-21 — project-authority/design-foundation.md (Status Draft, nothing selected): two materially different rendered directions (A Backlit Stage, B Gazette) on identical Play / lifted-row / locked+frozen / Won Perfect + 2★ / Journey home / tutorial states with won-moment stills, device variants, Turkish glyph + tabular + contrast specimens, motion language, recommendation, shipped-surface impact list | Depends On: -
- [x] Task ID: F00-UI-DIRECTION-C | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-21 — Direction C (Loop Glass) rendered from the user's reference screens on the same states as A/B (+ resolved/literal, sheet/full-screen and semantics alternatives, device variants, specimen with measured contrast) and three reference-frame parity comparisons; design-foundation.md §17 (system, motion, measured tokens, contract conflicts, deviations D1-D11, content-delta table, confirmations needed); A/B recorded as rejected; Status stays Draft | Depends On: F00-UI-FOUNDATION
- [x] Task ID: F00-UI-FINALIZE | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-21 — selected-source renders for the final decision set (Play, lifted row, locked+frozen, full-screen Result perfect / new best / 2-star, Home design + today, tutorial, device variants), an executable board-to-result transition prototype with timed and reduced-motion stills, a component/token sheet, and the design-system handoff features/f00-design-foundation/ui-design.md (Visual Evidence Manifest with selected-source and motion-prototype records); Foundation stays Selected | Depends On: F00-UI-DIRECTION-C
- [x] Task ID: F00-FE-DESIGN-SYSTEM | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-21 — app/lib/design layer (tokens, type roles on the bundled Space Grotesk and Manrope variable fonts, 12 drawn icons, Looplet wordmark, Turkish casing helpers, every component in every state) plus the debug-only gallery lib/main_gallery.dart; no shipped surface changed (only tracked change is the pubspec.yaml font declaration, no dependency); analyzer, format, melos test (197 package tests, 305 app tests of which 62 new) and the F03 device suite 13 of 13 green; runtime parity on iPhone 16, 16e and 16 Pro Max beside S-91 with one deviation found and fixed (frozen tile ring and dash rhythm) and the rest listed; evidence in features/f00-design-foundation/frontend.md | Depends On: F00-UI-FINALIZE
- [x] Task ID: F00-QA-VISUAL | Assigned Role: QA | Status: Done | Summary: DONE 2026-09-21 — verdict Rejected (qa.md; final stage, revision 78b22e3 content, app tree d9709ad): final score 80 of 100, lowest dimension Accessibility 6 of 10; blocking QA-01 (design-system components not Dynamic Type safe — MovesCard overflows from 1.35x, MovesCard and StatCard at the platform floor accessibility-medium, pills and nodes clip at the largest size), QA-02 (duplicate semantic nodes and labels on buttons, badge and disabled link), QA-03 (ui-design §8 focus state not implemented and not declared); QA-04 polish; independent runtime evidence in features/f00-design-foundation/qa/ | Depends On: F00-FE-DESIGN-SYSTEM
- [ ] Task ID: F00-FE-A11Y-REWORK | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: ACTIVATED 2026-09-23 by the Tech Lead after F00-QA-VISUAL Rejected (qa.md): fix QA-01 (Dynamic Type overflow/clip in MovesCard, StatCard, LimePill, OutlinePill, LoopNode, LoopletWordmark), QA-02 (duplicate semantic nodes/labels from _Pressable and LoopBadge), QA-03 (implement the ui-design §8 focus ring — Tech Lead ruling: implement, not a deviation); QA-04 optional in the same pass; see Current Frontend Brief | Depends On: F00-QA-VISUAL
- [ ] Task ID: F00-QA-VISUAL2 | Assigned Role: QA | Status: Queued | Summary: Targeted final-stage re-verify of F00-FE-A11Y-REWORK (scenarios 1, 4, 5 of the QA brief: cold launch, accessibility, coexistence gates); same rubric bar (93 plus, every dimension 8 plus, no fail condition); probe in qa/src is reusable; activates only after F00-FE-A11Y-REWORK delivers and Tech Lead reconciles | Depends On: F00-FE-A11Y-REWORK

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

## Visual Scope

design-system

## Design Foundation

ai-system/project-authority/design-foundation.md

## Visual Quality Gate

Ready for QA

## Visual Evidence

Selected-source and reference records: features/f00-design-foundation/ui-design.md § Visual Evidence Manifest (3 direction-render, canonical-reference, parity-comparison, selected-source and motion-prototype records); artefacts under features/f00-design-foundation/design/ (S-*.png, S-91-components.png, parity-*.png, sheet-S*.png, src/S-transition-prototype.html); user references in design/reference/. Runtime records (2026-09-21, Frontend/Mobile Developer): features/f00-design-foundation/frontend.md § Visual Parity Evidence (7 runtime-screenshot and 3 parity-comparison records; runtime-iphone16-*.png, runtime-iphone16e-sheet.png, runtime-iphone16promax-sheet.png, parity-runtime-1..3 under design/); the Tech Lead verified the records and the artefacts on 2026-09-21 (parity boards, runtime frames, a wrong İLK attribution corrected in frontend.md) and set the gate to Ready for QA.

## QA Modules

core, client-ui, visual-quality, stateful-flow

## Regression Depth

full

## Evidence Reuse

allowed

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
  * Prerequisite / External Decision: met 2026-09-21 — F00-FE-DESIGN-SYSTEM delivered and reconciled (Delivery Review Accepted, commit 78b22e3); Visual Quality Gate = Ready for QA
  * Re-evaluation Trigger: Tech Lead activated F00-QA-VISUAL (2026-09-21)
  * Blocks: Visual Quality Gate = Passed; F00 Done
  * Result: FAIL
  * Provenance / Note: 2026-09-21 QA, revision 78b22e3 content (app tree d9709ad858e4eda876f00e664281fa208409f6ca, HEAD a499e5d), iOS Simulator 18.6 (iPhone 16, 16e, 16 Pro Max), debug builds of the gallery and of an out-of-repo QA probe: independent rubric score 80 of 100, lowest dimension Accessibility 6 of 10, Fail Conditions None, Runtime Evidence Complete Yes, Result FAIL. Measured PASS: token colours delta E 0.00, gradients at most 1.2, geometry within 0.1 pt of spec on three devices, glow versus neutral shadow, Turkish glyphs and weight axis, Reduce Motion press feedback 0.978 (off) versus 1.000 (on) on the real OS setting, shipped app cold launch, F03 device suite 13 of 13, analyzer and format and 197 plus 305 tests exit 0. FAIL: QA-01 Dynamic Type overflow and clipping, QA-02 duplicate semantics, QA-03 focus state missing (QA-04 polish, non-blocking). Limits: no VoiceOver speech run, no Android, no physical device, synthetic pointer, no consuming surface, release size unmeasured. Detail: qa.md and qa/README.md.

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

Run Frontend/Mobile Developer on F00-FE-A11Y-REWORK using the Current Frontend Brief below. The delivery returns to the Tech Lead for reconciliation, which activates F00-QA-VISUAL2 (targeted final-stage re-verify). Visual Quality Gate stays Ready for QA (the runtime-parity evidence it rests on is unaffected; the rejection is an implementation-quality result, not a missing-evidence one). F00 is not Done. F05-QA-STRICT and F08 local evidence stay queued behind the F00 QA slot.

## Last Decision

Earlier decisions of this track (full text in [the archived working orchestration](../../history/f00-design-foundation-2026-09-21/orchestration-at-frontend-delivery.md)): F00 opened as the carrier of the Design Adoption Route after F03 closed; the user rejected Directions A and B ("not modern, not my style") and supplied three reference screens; Direction C (Loop Glass) was rendered from them; the selection request was rebuilt as a plain-language visual guide after the user could not read the codes; the user selected Direction C with `B: 2=2, 5=Looplet` (full-screen Result without a Close button; wordmark `Looplet`), Foundation Selected 2026-09-21; the UI Designer finalized the selected source, prototype and ui-design.md; the visual-gate checkpoint set Ready for Implementation and defaulted the proposals (visible back chevron as the Result's way home; one-glow rule kept; count-aware copy stays PO / localization; 44 pt targets and an 11 pt caption corrected in Phase D). Contract amendments stay deferred to per-feature visual rework (workflow-follow-ups.md, DESIGN-ADOPTION-CONTRACT-AMENDMENTS).

2026-09-21 (F00-FE-DESIGN-SYSTEM reconciliation) — Tech Lead reconciled the delivery (frontend.md; the user committed the working tree as 78b22e3, tree clean). Task coverage: F00-FE-DESIGN-SYSTEM covers every architecture §7 item (layer, fonts, icons, components in all seven tile states, gallery, evidence). Contract compliance: no dependency, lockfile or bootstrap change; against 9a72481 the only changes outside app/lib/design, app/test/design, app/assets/fonts and the F00 docs are the app/pubspec.yaml font declaration (+13) and the new debug entry app/lib/main_gallery.dart; no shipped file imports the layer. Authority reconciliation: deviations D1-D7 accepted as authority-sourced or specimen-composition differences (ui-design §8 / §Home / §13 win over S-91 specimen values; the C-03 frame and the source CSS win for the lock and snowflake icons and the frozen ring); the frozen-ring and dash-rhythm deviation found by the parity pass was fixed with a test; none needs a contract amendment. Preserved behavior: shipped surfaces identical (diff above). Evidence quality: analyzer, format and melos test re-run by the Tech Lead on the clean tree at 78b22e3 — exit 0, packages 197 and app 305, the Frontend's numbers; F03 device suite +13 exit 0 (Frontend, iPhone 16 iOS 18.6, tree identical apart from one doc comment in icons.dart); runtime frames and boards inspected. One wrong attribution corrected in frontend.md: the Turkish frame shows ILIK from ılık, not İLK; İLK from ilk is proven by turkish_case_test.dart (full alternative evidence, so a report correction, not rework). Startup impact: none (font asset declaration only; QA smoke-launches the shipped app). Delivery Review = Accepted; Visual Quality Gate = Ready for QA (real captures on the canonical target and its two variants plus parity records exist). QA plan: final, client-only, modules core + client-ui + visual-quality + stateful-flow (the deterministic keyword trigger matches architecture.md wording; the layer holds no persistence or lifecycle, so QA runs a narrow negative check), Regression Depth full (final gate; reuse allowed only by fingerprint), Evidence Reuse allowed. prd.md created as a carrier-feature statement with no product criteria because the QA preflight requires it. Not decided here: release-bundle size delta, on-device performance, Dynamic Type and VoiceOver are logged as follow-up F00-DS-UNMEASURED and are QA evidence questions, not delivery defects. F05-QA-STRICT and F08 stay queued behind F00-QA-VISUAL (one QA feature at a time).

2026-09-23 (F00-QA-VISUAL reconciliation) — Tech Lead reconciled the QA verdict (qa.md, Rejected, score 80/100, lowest dimension Accessibility 6/10). Evidence quality: the ledger carries scenario, command, target, result and provenance for every claim; a spot check of QA-02's root-cause hypothesis against the current code (`app/lib/design/components/buttons.dart` `_Pressable`: a `Semantics(button, onTap, label)` wraps a `GestureDetector` whose child `Text(label)` is not excluded from semantics) confirms it is plausible and specific enough to route as a real defect, not a misreading. Findings accepted as-is: QA-01 (Dynamic Type overflow/clip — `platform.md` §14 requires layouts to hold to at least accessibility-medium; the gallery/tests only covered OS text scale 1.3, missing the 1.35 (xxxL) and 1.65+ (accessibility) range the OS actually offers), QA-02 (duplicate semantics — contradicts `ui-design.md` §13 "announced once"), QA-04 (non-blocking polish). Ruling on QA-03 (focus ring): **implement it**, not a documented deviation — `ui-design.md` §8 specifies it explicitly ("2 px periwinkle, accessibility keyboards"), it is a small, well-scoped addition (a `Focus`/`FocusableActionDetector` and a ring paint on the existing pressable/button primitives), and the game already commits to OS-level accessibility support elsewhere (Reduce Motion, Dynamic Type); accepting a silent gap here would be inconsistent with that bar. No contract or product change follows from any of the four findings — all are implementation-layer fixes inside `app/lib/design`. Routing: F00-FE-A11Y-REWORK opened for the Frontend/Mobile Developer (Current Frontend Brief below); F00-QA-VISUAL2 queued behind it for a targeted final-stage re-verify (scenarios 1, 4, 5 of the original QA brief — cold launch, accessibility, coexistence; the QA probe under `qa/src` is reusable). Visual Quality Gate stays Ready for QA (unchanged: the gate reflects evidence-readiness, not a pass verdict, and the runtime-parity evidence is unaffected by these defects). Delivery Review stays Accepted (the F00-FE-DESIGN-SYSTEM delivery was traceable and complete; the defects are code-level and will be reconciled fresh on the rework delivery). QA Result stays Rejected (QA's own field; the next value is QA's to write after F00-QA-VISUAL2). No app, package, product or release file changed in this turn.

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-23
* Summary: F00-QA-VISUAL Rejected verdict reconciled; findings accepted (QA-01, QA-02, QA-04) with a ruling to implement QA-03 (focus ring) rather than defer it; F00-FE-A11Y-REWORK opened for the Frontend/Mobile Developer; F00-QA-VISUAL2 queued; owner -> Frontend/Mobile Developer; global board and state synced.

## Context & Follow-ups

Why now: the ai-system upgrade (cfd6b59) made an independent visual gate (>= 93 total, every rubric dimension >= 8, rendered evidence) mandatory for visual scope, and the project has no Selected Foundation; shipped visuals use the default system font, Material icons and text-only legacy directions with self-scores only. F05-QA-STRICT and F08 local evidence continue in parallel queue positions (they are Visual Scope none / non-visual); no feature with a visual scope activates before Selected.

## History & Evidence References

* [Scope contract](architecture.md); [Design Adoption Route](../../workflow-follow-ups.md); [platform.md §14](../../project-authority/platform.md).
* Shipped identity for reference: `app/lib/play/play_theme.dart`; surfaces documented in F03 ui-design.md (§5–§8, §16), F04 ui-design.md, F05 ui-design.md.
* Canonical execution: role-execution-contract.md.
* [Frontend delivery](frontend.md) · [carrier PRD statement](prd.md) · [archived working orchestration at the Frontend delivery](../../history/f00-design-foundation-2026-09-21/orchestration-at-frontend-delivery.md).

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
* 2026-09-21 — Tech Lead: F00-FE-DESIGN-SYSTEM reconciled (commit 78b22e3); Delivery Review Accepted; Visual Quality Gate Ready for QA; QA plan locked (final, client-only, core + client-ui + visual-quality + stateful-flow, full, allowed); F00-QA-VISUAL activated; prd.md added; working orchestration archived to history/f00-design-foundation-2026-09-21.
* 2026-09-21 — QA: F00-QA-VISUAL Done with verdict Rejected (qa.md: score 80 of 100, QA-01 Dynamic Type overflow and clipping, QA-02 duplicate semantics, QA-03 focus state missing, QA-04 polish); F00.VISUAL-QA FAIL; QA Result Rejected; status Rework; owner -> Tech Lead.
* 2026-09-23 — Tech Lead: F00-QA-VISUAL verdict reconciled (Rejected accepted; QA-03 ruled to be implemented, not deferred); F00-FE-A11Y-REWORK activated for the Frontend/Mobile Developer; F00-QA-VISUAL2 queued.

## Current Frontend Brief (F00-FE-A11Y-REWORK — activated 2026-09-23)

Fixes the defects `qa.md` found in F00-FE-DESIGN-SYSTEM (score 80/100, verdict Rejected). Read `qa.md` (Findings QA-01 to QA-04, Evidence Ledger E7-E12) and its evidence under `qa/` (in particular `qa/dynamic-type-sweep.txt`, `qa/qa-dynamic-type-1.65x.jpg`, `qa/qa-dynamic-type-3.1x.jpg`, `qa/semantics-gallery-iphone16.txt`) before changing code — they name the exact components, sizes and repro steps.

**QA-01 — Dynamic Type (required).** `MovesCard` and `StatCard` must not clip or overflow at OS text scale up to at least accessibility-medium (1.65x; `platform.md` §14's stated floor), and should degrade gracefully beyond it rather than silently clipping content (`LimePill`, `OutlinePill`, `LoopNode`, `LoopletWordmark` also clip at the largest accessibility sizes per QA's sweep). Direction: replace fixed-height boxes with a `minHeight` and let the component grow with its text; where a box must stay a fixed shape (e.g. `LoopNode`'s circle, a tabular numeral), give the numeral/label a scale ceiling (e.g. `MediaQuery.textScalerOf(context).clamp(maxScaleFactor: …)` on that piece only, not the whole tree) and document the chosen ceiling in a code comment referencing this task. Whichever approach is chosen, no ui-design token (radius, colour, spacing) changes.

**QA-02 — Duplicate semantics (required).** Every interactive `_Pressable`-based component must expose exactly one semantics node with the label spoken once. Likely fix: exclude the inner `Text`/child from semantics (e.g. wrap the pressable's child in `ExcludeSemantics`, or merge instead of nesting `Semantics` nodes) so `Semantics(button: true, label: …)` is the only node VoiceOver would land on. Apply the same fix to `LoopBadge` (currently `Semantics(label) > Text(label)` with no exclusion). Also add a semantics label to `UndoPill`'s remaining-quota count and to `LoopNode`'s done/current state (QA's note in QA-02) if not already implied by the surrounding label.

**QA-03 — Focus ring (required; Tech Lead ruling, see Last Decision).** Implement the `ui-design.md` §8 focus state: a 2 px periwinkle ring on keyboard/Switch-Control focus for the pressable/button primitives (`LimePill`, `OutlinePill`, `TextLink`, `GlassIconButton`, `UndoPill`). Use `Focus`/`FocusableActionDetector` (no new package) and gate the ring on `hasPrimaryFocus`, not hover.

**QA-04 — Polish (optional, bundle if convenient).** Give wrapped `caption`/`label` text a line-height above 1.0 so two-line captions don't touch; give `OutlinePill` horizontal text padding so a long label doesn't reach the border; check whether the display role needs a no-break tweak so a trailing "." doesn't strand alone at large text sizes (only if it doesn't complicate the token).

**Hard rules (unchanged from F00-FE-DESIGN-SYSTEM):** still no shipped-surface change, still no new dependency without Tech Lead approval, still no contract/game-logic change. All four items are inside `app/lib/design`.

**Evidence (frontend.md addendum or a new dated section, exact commands/targets/results):** re-run analyzer, format, `melos run test`; extend the gallery-layout test to real-font renders at OS text scale 1.35 and 1.65 (not just 1.3) asserting no `RenderFlex` overflow; a semantics test asserting one node per pressable with the label appearing once; a focus test asserting the ring paints only under `hasPrimaryFocus`. Runtime: re-capture the gallery on iPhone 16 at 1.65x and re-run the semantics dump (QA's probe in `qa/src/qa_probe_main.dart` and `qa/src/runprobe2.sh` are reusable, or write fresh ones) showing the fixes; note in the addendum exactly which QA finding each new capture answers. Close F00-FE-A11Y-REWORK, Delivery Review = Pending, owner -> Tech Lead.

## Earlier briefs

The UI Designer briefs (F00-UI-FOUNDATION, F00-UI-DIRECTION-C, F00-UI-FINALIZE), the Frontend brief (F00-FE-DESIGN-SYSTEM) and the first QA brief (F00-QA-VISUAL, verdict Rejected) are closed; their content lives in design-foundation.md (§4-§19), ui-design.md, architecture.md §7, frontend.md, qa.md and the archived working orchestration.
