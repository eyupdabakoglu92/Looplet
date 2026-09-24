# F00 — design-foundation: Orchestration

## Feature ID

F00

## Current Status

In QA

## Current Owner

Tech Lead

## Next Role

Tech Lead

## Active Task Ledger

- [x] Task ID: F00-UI-FOUNDATION | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-21 — project-authority/design-foundation.md (Status Draft, nothing selected): two materially different rendered directions (A Backlit Stage, B Gazette) on identical Play / lifted-row / locked+frozen / Won Perfect + 2★ / Journey home / tutorial states with won-moment stills, device variants, Turkish glyph + tabular + contrast specimens, motion language, recommendation, shipped-surface impact list | Depends On: -
- [x] Task ID: F00-UI-DIRECTION-C | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-21 — Direction C (Loop Glass) rendered from the user's reference screens on the same states as A/B (+ resolved/literal, sheet/full-screen and semantics alternatives, device variants, specimen with measured contrast) and three reference-frame parity comparisons; design-foundation.md §17 (system, motion, measured tokens, contract conflicts, deviations D1-D11, content-delta table, confirmations needed); A/B recorded as rejected; Status stays Draft | Depends On: F00-UI-FOUNDATION
- [x] Task ID: F00-UI-FINALIZE | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-21 — selected-source renders for the final decision set (Play, lifted row, locked+frozen, full-screen Result perfect / new best / 2-star, Home design + today, tutorial, device variants), an executable board-to-result transition prototype with timed and reduced-motion stills, a component/token sheet, and the design-system handoff features/f00-design-foundation/ui-design.md (Visual Evidence Manifest with selected-source and motion-prototype records); Foundation stays Selected | Depends On: F00-UI-DIRECTION-C
- [x] Task ID: F00-FE-DESIGN-SYSTEM | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-21 — app/lib/design layer (tokens, type roles on the bundled Space Grotesk and Manrope variable fonts, 12 drawn icons, Looplet wordmark, Turkish casing helpers, every component in every state) plus the debug-only gallery lib/main_gallery.dart; no shipped surface changed (only tracked change is the pubspec.yaml font declaration, no dependency); analyzer, format, melos test (197 package tests, 305 app tests of which 62 new) and the F03 device suite 13 of 13 green; runtime parity on iPhone 16, 16e and 16 Pro Max beside S-91 with one deviation found and fixed (frozen tile ring and dash rhythm) and the rest listed; evidence in features/f00-design-foundation/frontend.md | Depends On: F00-UI-FINALIZE
- [x] Task ID: F00-QA-VISUAL | Assigned Role: QA | Status: Done | Summary: DONE 2026-09-21 — verdict Rejected (qa.md; final stage, revision 78b22e3 content, app tree d9709ad): final score 80 of 100, lowest dimension Accessibility 6 of 10; blocking QA-01 (design-system components not Dynamic Type safe — MovesCard overflows from 1.35x, MovesCard and StatCard at the platform floor accessibility-medium, pills and nodes clip at the largest size), QA-02 (duplicate semantic nodes and labels on buttons, badge and disabled link), QA-03 (ui-design §8 focus state not implemented and not declared); QA-04 polish; independent runtime evidence in features/f00-design-foundation/qa/ | Depends On: F00-FE-DESIGN-SYSTEM
- [x] Task ID: F00-FE-A11Y-REWORK | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-23 — QA-01 (Dynamic Type: MovesCard/StatCard switched fixed height to minHeight + mainAxisSize.min, kept the text-scale cap for width; GlassCard gained a minHeight option; LoopNode/LoopletWordmark kept the cap alone), QA-02 (excludeSemantics: true on _Pressable and LoopBadge — one announced node, not two; UndoPill/LoopNode labels now state quota/state), QA-03 (2 px periwinkle focus ring + Enter/Space activation via FocusableActionDetector, painted with foregroundDecoration so it never shifts layout), QA-04 (caption line-height 1.3, OutlinePill padding); a first cap-only attempt for QA-01 passed every widget test but still overflowed 1.5 pt on a real device at accessibility-medium — found and fixed via a real runtime capture, not by the automated suite; 8 new tests (70 total); analyze/format(app-scoped)/melos test/F03 device suite all green; evidence in frontend.md (F00-FE-A11Y-REWORK section) and design/rework/ | Depends On: F00-QA-VISUAL
- [x] Task ID: F00-QA-VISUAL2 | Assigned Role: QA | Status: Done | Summary: DONE 2026-09-23 — verdict Approved with Notes (qa.md § F00-QA-VISUAL2; revision commit 0ce257c content, app tree 3753ad3, design tree 0b125cf, re-confirmed unchanged under current HEAD f021401): QA-01, QA-02 and QA-03 independently RESOLVED with fresh own runtime evidence (gallery captures at 1.65x and 3.12x incl. the CARDS/STATS/TRACK gap Frontend flagged as test-only; a rebuilt semantics probe, 85 nodes, zero duplicate pairs; a new independent focus-ring widget test — not copied from Frontend's — across 3 control shapes incl. UndoPill); zero regression (313 app tests, F03 device suite 13/13, fresh shipped-app cold launch, analyzer/format clean on app); rescored 88/100 (was 80), every dimension >= 8, no fail condition; QA-04 stays open/non-blocking (unchanged, out of this round's scope); numeric score sits under the generic 93 gate purely on QA-04 (already ruled non-blocking) and the Motion dimension's pre-existing Phase-D-absence cap, flagged explicitly to the Tech Lead for the gate decision | Depends On: F00-FE-A11Y-REWORK

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

Approved with Notes

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

- Evidence ID: F00.DS-A11Y-REWORK
  * Scenario: F00-FE-A11Y-REWORK fixes QA-01 (Dynamic Type overflow/clip), QA-02 (duplicate semantics), QA-03 (focus ring + keyboard activation) and QA-04 (polish) with automated and real-device evidence
  * Required Class: automated functional + runtime
  * Target / Environment: workspace (melos); iOS Simulator 18.6 iPhone 16 for the runtime captures and the F03 device suite
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: None (Tech Lead ruling on QA-03 recorded in Last Decision)
  * Re-evaluation Trigger: F00-FE-A11Y-REWORK delivery
  * Blocks: F00-QA-VISUAL2 (re-verify)
  * Result: PASS
  * Provenance / Note: 2026-09-23 Frontend/Mobile Developer, working tree on top of commit 5f18c89 (not committed by this delivery; 7 files changed under app/lib/design and app/test/design only, no shipped file, dependency or pubspec change): melos run analyze exit 0; dart format --output=none --set-exit-if-changed app exit 0 (110 files, 0 changed — the workspace-wide melos run format:check fails only on a pre-existing, unrelated file outside this task, ai-system/features/f00-design-foundation/qa/src/qa_probe_main.dart, not touched here); melos run test exit 0 (packages 197 unchanged, app 313 = 305 + 8 new); flutter test integration_test on iPhone 16 iOS 18.6 -> +13 All tests passed, exit 0, run twice (mid-task and on the final code). Runtime: gallery rebuilt and captured at OS accessibility-medium (1.65x, the platform.md §14 floor) on iPhone 16 — a first QA-01 fix (text-scale cap alone) passed every widget test including a dedicated stress test up to 3.12x, but the real capture showed a genuine BOTTOM OVERFLOWED BY 1.5 PIXELS on MovesCard; fixed by switching MovesCard/StatCard to a minHeight (kept the cap for width, which a real overflow-free re-capture of all 5 gallery sections then confirmed) -- design/rework/ (before/after captures, README). Shipped app cold launch re-verified unchanged (system font, Material icons, no file under app/lib/design imported). Limits: QA-02/QA-03 verified by widget tests (SemanticsNode / Focus APIs), not a real VoiceOver speech pass or a real hardware keyboard on a device; LoopNode's 2-digit case and the 44 pt wordmark were stress-tested by widget test and confirmed at the required 1.65x floor by the runtime capture, not individually re-captured at 3.12x the way MovesCard was after its bug. Detail: frontend.md (F00-FE-A11Y-REWORK section).

- Evidence ID: F00.VISUAL-QA2
  * Scenario: Independent targeted final-stage re-verify of F00-FE-A11Y-REWORK — QA's own runtime evidence that QA-01/02/03 are actually fixed, plus a full regression pass and a rescored rubric
  * Required Class: runtime
  * Target / Environment: iOS Simulator 18.6, iPhone 16, debug builds of the gallery, an independently rebuilt QA probe and a new QA-authored widget test
  * Owner Role: QA
  * Prerequisite / External Decision: met 2026-09-23 — F00-FE-A11Y-REWORK reconciled (Delivery Review Accepted, commit 0ce257c)
  * Re-evaluation Trigger: Tech Lead activated F00-QA-VISUAL2 (2026-09-23)
  * Blocks: Visual Quality Gate = Passed; F00 Done
  * Result: PASS (mandated scope) — rubric mechanically FAIL against the generic >= 93 gate; see Note
  * Provenance / Note: 2026-09-23 QA, revision commit 0ce257c content (app tree 3753ad31fc301501d2e75db709d9b437838c250d, design tree 0b125cf11310ae08ae9b722a727af775cd737658), re-confirmed identical under current HEAD f021401 (doc-only commits since). QA-01: own gallery captures at 1.65x (am_sheet1/2.png) and 3.12x (xxxl_sheet1/2.png + two extra targeted scroll offsets reaching CARDS/STATS/TRACK, the section Frontend's frontend.md flagged as confirmed only by widget test beyond 1.65x) — zero overflow/clip on MovesCard, StatCard, LimePill/OutlinePill, LoopNode, LoopletWordmark at either scale; QA-04's orphan "." still present at 3.12x as expected (out of this rework's scope, unchanged). QA-02: rebuilt qa/src/qa_probe_main.dart + runprobe2.sh against this revision, probe_mode=gallery: sem-count=85 (Round 1: 92), zero duplicate node pairs for LimePill/OutlinePill/TextLink/GlassIconButton/UndoPill/LoopBadge, labels single ("HARİKA", "Sonraki bölüm · yakında") and now state/quota-aware ("Geri al, 3 / 3 hak", "5, geçerli seviye"). QA-03: new QA-authored widget test (qa_focus_check_test.dart, not copied from Frontend's components_test.dart; covers LimePill, GlassIconButton and UndoPill, the last not in Frontend's own test) using FocusManager.highlightStrategy=alwaysTraditional + tester.sendKeyEvent(Tab) — the "simulated keyboard focus trigger" class the brief itself sanctions since real hardware/Bluetooth keyboard is out of reach here too: 3/3 PASS, ring hidden at rest, paints only on primary focus, no layout-size change, clears on unfocus. Regression: melos run analyze (looplet_app 0 issues; looplet_solver 1 pre-existing unrelated info-lint, out of scope), dart format --set-exit-if-changed app (110 files, 0 changed), workspace format:check (fails only on the pre-existing unrelated qa/src/qa_probe_main.dart, as the brief itself already discounts), flutter test app (313/313 PASS), flutter test integration_test -d iPhone16 (+13 PASS, fresh this round), shipped-app cold launch (own fresh install+launch, home screen unchanged/legacy per Phase C not started, a live play session renders and functions normally). Rescored rubric: 88/100 (Layout 7->9, Interaction 7->9, Accessibility 6->9, Implementation 8->9; five dimensions reused by fingerprint per the brief's allowlist since this revision didn't touch them; Typography stays 8, QA-04 still open). Every dimension >= 8, no fail condition. The 5-point gap under the generic >= 93 threshold is entirely QA-04 (Round 1 already ruled non-blocking, not in this rework's task list) and the Motion dimension's structural Phase-D-surface-absence cap (not a defect, identical reasoning to Round 1) — flagged explicitly in qa.md § Tech Lead Note for the gate decision, not resolved unilaterally by QA. Limits unchanged from Round 1: no VoiceOver speech run, no real hardware/Bluetooth keyboard, no real device (simulator/Metal, debug build), no consuming screen for full composition. Detail: qa.md (F00-QA-VISUAL2 section).

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

Run Tech Lead to reconcile the F00-QA-VISUAL2 verdict (qa.md § F00-QA-VISUAL2, 2026-09-23): QA-01/02/03 independently RESOLVED with fresh runtime evidence, QA Result Approved with Notes, rescored 88/100 (every dimension >= 8, no fail condition), zero regression. The numeric score sits under the generic >= 93 gate solely because of QA-04 (already ruled non-blocking in Round 1, not in this rework's scope) and the Motion dimension's pre-existing Phase-D-surface-absence cap (not a defect) — qa.md § Tech Lead Note lays out three defensible options (pass the gate now; open a QA-04 rework round; treat >= 93 as structurally inapplicable at this pre-Phase-D stage) and leaves the choice to the Tech Lead. F05-QA-STRICT and F08 local evidence stay queued behind this QA slot.

## Last Decision

Earlier decisions of this track, full text archived: [Direction A/B rejection through the visual-gate checkpoint (through 2026-09-21)](../../history/f00-design-foundation-2026-09-21/orchestration-at-frontend-delivery.md); [the F00-FE-DESIGN-SYSTEM reconciliation (commit 78b22e3: task coverage, contract compliance, deviations D1-D7 accepted, QA plan locked) and the F00-QA-VISUAL Rejected-verdict reconciliation (score 80/100; findings QA-01-04 accepted; QA-03 focus ring ruled to be implemented, not deferred; F00-FE-A11Y-REWORK opened)](../../history/f00-design-foundation-2026-09-23/orchestration-at-a11y-reconciliation.md). Summary: F00 opened as the Design Adoption Route carrier after F03 closed; the user rejected Directions A/B and supplied reference screens; Direction C rendered and selected (`B: 2=2, 5=Looplet` — full-screen Result, no Close button, wordmark `Looplet`), Foundation Selected 2026-09-21; design-system layer delivered 2026-09-21 (commit 78b22e3), reconciled, sent to QA; QA Rejected it 2026-09-21 on accessibility grounds (score 80/100); Tech Lead ruled the missing focus ring must be implemented and opened the rework task.

2026-09-23 (F00-FE-A11Y-REWORK reconciliation) — Tech Lead reconciled the rework delivery. Task coverage: all four findings addressed; code read directly confirms the claims — `_Pressable` (`buttons.dart`) carries `excludeSemantics: true` and a `FocusableActionDetector` with `Actions`/`Shortcuts` painting a `foregroundDecoration` ring (QA-02/QA-03); `MovesCard`/`StatCard` (`info.dart`) use `constraints: BoxConstraints(minHeight: …)` with `mainAxisSize: MainAxisSize.min` plus `loopCappedTextScaler` (QA-01); `GlassCard` (`surfaces.dart`) gained a border/padding-aware `minHeight`. Contract compliance: `git diff --stat 5f18c89 HEAD -- app` touches exactly the claimed 7 files, all under `app/lib/design/` and `app/test/design/`; no shipped file, `pubspec.yaml`/lockfile or `analysis_options.yaml` changed (verified directly, not just cited). Evidence quality: re-ran independently on the committed tree — `melos run analyze` exit 0, `dart format --output=none --set-exit-if-changed app` exit 0 (110 files), the workspace-wide `format:check` still fails only on the pre-existing unrelated `qa/src/qa_probe_main.dart` (confirmed, not this task's scope), `melos run test` exit 0 (197 + 313), F03 device suite `+13` exit 0. Runtime evidence: reviewed the `design/rework/` captures — found the archived "before" JPEG was mis-cropped (didn't show the claimed overflow banner, a packaging mistake, not a fabricated claim — the underlying capture in the delivery's own working session did show it); re-cropped it correctly from the same source capture, confirmed the red `BOTTOM OVERFLOWED BY 1.5 PIXELS` banner, and replaced the file (report correction, real alternative evidence was already complete, per evidence-integrity rules; not sent back for rework). The "after" sheets were independently reviewed and show no overflow anywhere across all 5 gallery sections at 1.65x. Preserved behavior: no shipped file imports `app/lib/design` (verified directly); coexistence confirmed by construction plus Frontend's own capture. No contract or product change. Routing: F00-QA-VISUAL2 activated (Current QA Brief below) for a **targeted** re-verify — QA rescoring reuses its own prior PASS evidence by fingerprint for code this task didn't touch (colour/geometry measurements, Turkish glyphs, Reduce Motion, the frozen-tile fix) and re-verifies fresh only what changed. Visual Quality Gate stays Ready for QA (unchanged; only a qualifying QA verdict can move it to Passed). Delivery Review = Accepted; QA Result reset to None for the new round (QA's own field to write next).

## Last Update

* Updated By: QA
* Timestamp: 2026-09-23
* Summary: F00-QA-VISUAL2 Done — verdict Approved with Notes (qa.md § F00-QA-VISUAL2). QA-01/02/03 independently RESOLVED with QA's own fresh runtime evidence (own captures, a rebuilt probe, a new QA-authored widget test — none of it taken on Frontend's word); zero regression; rescored 88/100 (was 80), every dimension >= 8. Score sits under the generic 93 gate only via QA-04 (already non-blocking) and Motion's pre-existing Phase-D-absence cap; flagged to Tech Lead, not resolved by QA. Owner -> Tech Lead.

## Context & Follow-ups

Why now: the ai-system upgrade (cfd6b59) made an independent visual gate (>= 93 total, every rubric dimension >= 8, rendered evidence) mandatory for visual scope, and the project has no Selected Foundation; shipped visuals use the default system font, Material icons and text-only legacy directions with self-scores only. F05-QA-STRICT and F08 local evidence continue in parallel queue positions (they are Visual Scope none / non-visual); no feature with a visual scope activates before Selected.

## History & Evidence References

* [Scope contract](architecture.md); [Design Adoption Route](../../workflow-follow-ups.md); [platform.md §14](../../project-authority/platform.md).
* Shipped identity for reference: `app/lib/play/play_theme.dart`; surfaces documented in F03 ui-design.md (§5–§8, §16), F04 ui-design.md, F05 ui-design.md.
* Canonical execution: role-execution-contract.md.
* [Frontend delivery](frontend.md) · [QA verdict](qa.md) · [carrier PRD statement](prd.md) · archived working orchestrations: [at the first Frontend delivery](../../history/f00-design-foundation-2026-09-21/orchestration-at-frontend-delivery.md) · [at the accessibility-rework reconciliation](../../history/f00-design-foundation-2026-09-23/orchestration-at-a11y-reconciliation.md).

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
* 2026-09-23 — Frontend/Mobile Developer: F00-FE-A11Y-REWORK delivered (QA-01/02/03 fixed, QA-04 bundled; real-device overflow found and fixed after a widget-test-only fix passed but didn't hold on device); task Done; Delivery Review = Pending; owner -> Tech Lead.
* 2026-09-23 — Tech Lead: F00-FE-A11Y-REWORK reconciled (Delivery Review Accepted; corrected a mis-cropped "before" evidence JPEG); F00-QA-VISUAL2 activated for the QA role (targeted re-verify); QA Result reset to None.
* 2026-09-23 — QA: F00-QA-VISUAL2 Done with verdict Approved with Notes (qa.md: QA-01/02/03 independently RESOLVED with fresh own runtime evidence, zero regression, rescored 88/100 of 100, every dimension >= 8, no fail condition; QA-04 stays open/non-blocking, unchanged; numeric score under the generic >= 93 gate solely via QA-04 and Motion's pre-existing Phase-D cap, flagged for the Tech Lead's gate decision); F00.VISUAL-QA2 PASS (mandated scope); QA Result Approved with Notes; owner -> Tech Lead.

## Current QA Brief (F00-QA-VISUAL2 — activated 2026-09-23)

Targeted final-stage re-verify of F00-FE-A11Y-REWORK. Stage final, scope client-only, modules core + client-ui + visual-quality + stateful-flow, Regression Depth full, Evidence Reuse allowed.

**Revision under test:** commit `0ce257c` (clean tree; app tree `3753ad31fc301501d2e75db709d9b437838c250d`, `app/lib/design` tree `0b125cf11310ae08ae9b722a727af775cd737658`). Reuse of your own F00-QA-VISUAL evidence (E1-E14 in qa.md) is valid only for code this revision did not touch — colour/gradient/geometry measurements, Turkish glyphs and weight axis, Reduce Motion press feedback, the frozen-tile fix, `stateful-flow`. It changed exactly `app/lib/design/components/{buttons,info,surfaces}.dart`, `tokens.dart`, `typography.dart`, `wordmark.dart` and their tests (`git diff --stat 5f18c89 0ce257c -- app`) — verify those fresh with your own runtime evidence, not by trusting Frontend's frontend.md or `design/rework/` captures (cross-check material only, same rule as the first round).

**Read:** qa.md (your own prior Findings QA-01-04 and their exact repro/evidence), frontend.md § "F00-FE-A11Y-REWORK — accessibility rework" (the fix and its own honestly-stated limits — note in particular that a first cap-only QA-01 fix passed every widget test but still failed on a real device; your job is to independently confirm the *current* code on your own capture, not take that narrative on faith), `design/rework/` (Frontend's before/after captures — the Tech Lead found and corrected one mis-cropped "before" file during reconciliation).

**Targeted scenarios** (own runtime evidence for each; an unobtainable one becomes Runtime Validation Pending with its scenario id):
1. QA-01: your own gallery capture on iPhone 16 at OS accessibility-medium (1.65x, the `platform.md` §14 floor) **and** at least one larger accessibility size (e.g. 2.35x or 3.12x) — confirm no clip/overflow on `MovesCard`, `StatCard`, `LimePill`/`OutlinePill` (a long-label case), `LoopNode`, `LoopletWordmark`. Frontend's frontend.md flags that `LoopNode`'s 2-digit case and the 44 pt wordmark were confirmed at 1.65x by capture but only by widget test at more extreme sizes — close that gap with your own capture if practical, otherwise carry it forward as a limit, not silently upgraded to full confidence.
2. QA-02: your own semantics-tree dump of the gallery (the probe in `qa/src/qa_probe_main.dart` + `runprobe2.sh` is reusable, or write your own) — confirm every pressable and `LoopBadge` is a single node with the label spoken once, and that nothing else in the tree regressed.
3. QA-03: confirm the focus ring — state exactly which method you used (a real/simulated keyboard focus trigger on the simulator, or an automated check that `hasPrimaryFocus` is what paints it) since a real hardware/Bluetooth keyboard on a device is out of reach here too.
4. Coexistence and regression: shipped app cold launch (own capture, unchanged expected); `flutter test integration_test -d <iPhone 16>`; `melos run analyze`; `dart format --output=none --set-exit-if-changed app`; `melos run test`. The workspace-wide `melos run format:check` fails only on a pre-existing, unrelated file (`qa/src/qa_probe_main.dart`, outside this feature's own scope) — this does not block a verdict; note it if you want it addressed, but it is not this feature's defect.

**Rescoring:** all ten rubric dimensions, using your own fresh evidence for what changed (Accessibility and its neighbours — Layout/Rhythm, Interaction/State, Implementation Fidelity) and fingerprint-valid reuse of your own prior evidence for what didn't. PASS bar unchanged: 93 or more, every dimension at least 8, no fail condition, complete runtime evidence.

**Exit:** qa.md updated (a new dated section, or a fresh document — your call) with a new Visual Quality Verdict, Findings for anything still open or newly observed, and the QA Result field. Update only your own evidence record(s) (e.g. a new F00.VISUAL-QA2, or extend F00.VISUAL-QA) and your own ledger item; the Tech Lead sets the gate.

## Earlier briefs

The UI Designer briefs (F00-UI-FOUNDATION, F00-UI-DIRECTION-C, F00-UI-FINALIZE), the Frontend briefs (F00-FE-DESIGN-SYSTEM, F00-FE-A11Y-REWORK) and the first QA brief (F00-QA-VISUAL, verdict Rejected) are closed; their content lives in design-foundation.md (§4-§19), ui-design.md, architecture.md §7, frontend.md, qa.md and the archived working orchestrations.
