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
- [x] Task ID: F00-FE-A11Y-REWORK | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-23 — QA-01 (Dynamic Type: MovesCard/StatCard switched fixed height to minHeight + mainAxisSize.min, kept the text-scale cap for width; GlassCard gained a minHeight option; LoopNode/LoopletWordmark kept the cap alone), QA-02 (excludeSemantics: true on _Pressable and LoopBadge — one announced node, not two; UndoPill/LoopNode labels now state quota/state), QA-03 (2 px periwinkle focus ring + Enter/Space activation via FocusableActionDetector, painted with foregroundDecoration so it never shifts layout), QA-04 (caption line-height 1.3, OutlinePill padding); a first cap-only attempt for QA-01 passed every widget test but still overflowed 1.5 pt on a real device at accessibility-medium — found and fixed via a real runtime capture, not by the automated suite; 8 new tests (70 total); analyze/format(app-scoped)/melos test/F03 device suite all green; evidence in frontend.md (F00-FE-A11Y-REWORK section) and design/rework/ | Depends On: F00-QA-VISUAL
- [x] Task ID: F00-QA-VISUAL2 | Assigned Role: QA | Status: Done | Summary: DONE 2026-09-23 — targeted re-verify scenarios PASSED with real independent evidence: QA-01, QA-02 and QA-03 confirmed RESOLVED (gallery captures at 1.65x and 3.12x incl. the CARDS/STATS/TRACK gap Frontend flagged as test-only; a rebuilt semantics probe, 85 nodes, zero duplicate pairs; a new independent focus-ring widget test across 3 control shapes incl. UndoPill); zero regression (313 app tests, F03 13/13, fresh cold launch). Rescored 88/100 (was 80) — Tech Lead reconciliation corrected the reported QA Result from Approved with Notes to Rejected: premium-ui-rubric.md §Verdict Bands is unconditional ("85–92: zorunlu rework"; "92 ve altı Approved with Notes ile geçirilemez") with no carve-out for an already-non-blocking gap; QA's Round 2 Findings text was also found to be stale on 2 of QA-04's 3 items (caption line-height and OutlinePill padding are already fixed in code, confirmed directly — only the display/headline mid-word-wrap item is genuinely still open) | Depends On: F00-FE-A11Y-REWORK
- [ ] Task ID: F00-FE-A11Y-REWORK2 | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: ACTIVATED 2026-09-24 by the Tech Lead: fix the one genuinely remaining QA-04 item — at extreme OS text scale (>= accessibility-extra-extra-extra-large, ~3.12x) the `display`/`headline` roles mid-word-break long Turkish strings ("Sıradaki döngüyü çöz.", "Döngü tamamlandı.") because a single token is wider than the line, sometimes leaving an isolated trailing glyph/period on its own line (QA's E19, `qa2/xxxl_sheet1.png`/`qa2/qa2_xxxl_cards_5200.png` equivalent). Choose and document a fix (e.g. a documented scale ceiling on these two roles matching the existing `label`-role precedent, or a widow-safe wrap strategy); verify with a real runtime capture at both accessibility-medium and the largest OS size, not a widget test alone (the QA-01 lesson: a first cap-only fix passed every widget test but still failed on a real device). See Current Frontend Brief | Depends On: F00-QA-VISUAL2

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
  * Result: PASS
  * Provenance / Note: 2026-09-23 QA, revision commit 0ce257c content (app tree 3753ad31fc301501d2e75db709d9b437838c250d, design tree 0b125cf11310ae08ae9b722a727af775cd737658), re-confirmed identical under current HEAD f021401 (doc-only commits since). QA-01: own gallery captures at 1.65x (am_sheet1/2.png) and 3.12x (xxxl_sheet1/2.png + two extra targeted scroll offsets reaching CARDS/STATS/TRACK, the section Frontend's frontend.md flagged as confirmed only by widget test beyond 1.65x) — zero overflow/clip on MovesCard, StatCard, LimePill/OutlinePill, LoopNode, LoopletWordmark at either scale; QA-04's orphan "." still present at 3.12x as expected (out of this rework's scope, unchanged). QA-02: rebuilt qa/src/qa_probe_main.dart + runprobe2.sh against this revision, probe_mode=gallery: sem-count=85 (Round 1: 92), zero duplicate node pairs for LimePill/OutlinePill/TextLink/GlassIconButton/UndoPill/LoopBadge, labels single ("HARİKA", "Sonraki bölüm · yakında") and now state/quota-aware ("Geri al, 3 / 3 hak", "5, geçerli seviye"). QA-03: new QA-authored widget test (qa_focus_check_test.dart, not copied from Frontend's components_test.dart; covers LimePill, GlassIconButton and UndoPill, the last not in Frontend's own test) using FocusManager.highlightStrategy=alwaysTraditional + tester.sendKeyEvent(Tab) — the "simulated keyboard focus trigger" class the brief itself sanctions since real hardware/Bluetooth keyboard is out of reach here too: 3/3 PASS, ring hidden at rest, paints only on primary focus, no layout-size change, clears on unfocus. Regression: melos run analyze (looplet_app 0 issues; looplet_solver 1 pre-existing unrelated info-lint, out of scope), dart format --set-exit-if-changed app (110 files, 0 changed), workspace format:check (fails only on the pre-existing unrelated qa/src/qa_probe_main.dart, as the brief itself already discounts), flutter test app (313/313 PASS), flutter test integration_test -d iPhone16 (+13 PASS, fresh this round), shipped-app cold launch (own fresh install+launch, home screen unchanged/legacy per Phase C not started, a live play session renders and functions normally). Rescored rubric: 88/100 (Layout 7->9, Interaction 7->9, Accessibility 6->9, Implementation 8->9; five dimensions reused by fingerprint per the brief's allowlist since this revision didn't touch them; Typography stays 8, QA-04 still open). Every dimension >= 8, no fail condition. The 5-point gap under the generic >= 93 threshold is entirely QA-04 (Round 1 already ruled non-blocking, not in this rework's task list) and the Motion dimension's structural Phase-D-surface-absence cap (not a defect, identical reasoning to Round 1) — flagged explicitly in qa.md § Tech Lead Note for the gate decision, not resolved unilaterally by QA. Limits unchanged from Round 1: no VoiceOver speech run, no real hardware/Bluetooth keyboard, no real device (simulator/Metal, debug build), no consuming screen for full composition. Detail: qa.md (F00-QA-VISUAL2 section). Tech Lead correction 2026-09-24: this record's own PASS stands (QA-01/02/03 are genuinely fixed and independently verified) but the qa.md QA Result field this evidence was filed under (`Approved with Notes`) was corrected to `Rejected` on reconciliation — premium-ui-rubric.md's Verdict Bands are unconditional (88 falls in "85–92: zorunlu rework"; "92 ve altı Approved with Notes ile geçirilemez") with no exception for a shortfall already labelled non-blocking elsewhere. See Last Decision.

- Evidence ID: F00.DS-A11Y-REWORK2
  * Scenario: F00-FE-A11Y-REWORK2 fixes the one remaining QA-04 item (mid-word wrap / isolated trailing glyph on `display`/`headline` at extreme OS text scale) with real runtime evidence at accessibility-medium and the largest OS size, not a widget test alone
  * Required Class: automated functional + runtime
  * Target / Environment: workspace (melos); iOS Simulator 18.6 iPhone 16 for the runtime captures
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: None
  * Re-evaluation Trigger: F00-FE-A11Y-REWORK2 delivery
  * Blocks: F00-QA-VISUAL3 (re-verify + honest rescore)
  * Result: PENDING
  * Provenance / Note: Not yet delivered.

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

Run Frontend/Mobile Developer on F00-FE-A11Y-REWORK2 (Current Frontend Brief below): fix the one remaining QA-04 item (mid-word wrap on `display`/`headline` at extreme OS text scale). Then Run QA on F00-QA-VISUAL3: verify the fix with real runtime evidence and rescore all ten rubric dimensions honestly against premium-ui-rubric.md's literal per-dimension text — QA-01/02/03 evidence stays fingerprint-valid and is not re-verified. F05-QA-STRICT and F08 stay queued behind this QA slot.

## Last Decision

Earlier decisions of this track, full text archived: [Direction A/B rejection through the visual-gate checkpoint (through 2026-09-21)](../../history/f00-design-foundation-2026-09-21/orchestration-at-frontend-delivery.md); [the F00-FE-DESIGN-SYSTEM reconciliation (commit 78b22e3: task coverage, contract compliance, deviations D1-D7 accepted, QA plan locked) and the F00-QA-VISUAL Rejected-verdict reconciliation (score 80/100; findings QA-01-04 accepted; QA-03 focus ring ruled to be implemented, not deferred; F00-FE-A11Y-REWORK opened)](../../history/f00-design-foundation-2026-09-23/orchestration-at-a11y-reconciliation.md). Summary: F00 opened as the Design Adoption Route carrier after F03 closed; the user rejected Directions A/B and supplied reference screens; Direction C rendered and selected (`B: 2=2, 5=Looplet` — full-screen Result, no Close button, wordmark `Looplet`), Foundation Selected 2026-09-21; design-system layer delivered 2026-09-21 (commit 78b22e3), reconciled, sent to QA; QA Rejected it 2026-09-21 on accessibility grounds (score 80/100); Tech Lead ruled the missing focus ring must be implemented and opened the rework task.

2026-09-23 (F00-FE-A11Y-REWORK reconciliation, full text archived: [orchestration-at-qa-visual2-verdict.md](../../history/f00-design-foundation-2026-09-23/orchestration-at-qa-visual2-verdict.md)) — Tech Lead reconciled the rework delivery: all four findings addressed and independently code-verified (QA-01/02/03 fix mechanisms confirmed in `buttons.dart`/`info.dart`/`surfaces.dart`), contract compliance confirmed (7 files, only under `app/lib/design`/`app/test/design`), evidence re-run independently (analyze/format/test/F03 all exit 0), one mis-cropped "before" evidence JPEG found and corrected (report correction, not rework). Delivery Review = Accepted; F00-QA-VISUAL2 activated with a targeted re-verify brief.

2026-09-23 (F00-QA-VISUAL2 verdict) — QA delivered Approved with Notes, 88/100 (was 80); QA-01/02/03 independently RESOLVED with fresh runtime evidence (own gallery captures at 1.65x and 3.12x, a rebuilt semantics probe, a new independent focus-ring widget test), zero regression (313 tests, F03 13/13, fresh cold launch); QA-04 stays open/non-blocking; the 5-point gap under the generic >= 93 gate is entirely QA-04 (already non-blocking) and Motion's pre-existing Phase-D-absence cap, flagged to Tech Lead rather than resolved unilaterally. Full text: qa.md § F00-QA-VISUAL2 and [orchestration-at-qa-visual2-verdict.md](../../history/f00-design-foundation-2026-09-23/orchestration-at-qa-visual2-verdict.md).

2026-09-24 (F00-QA-VISUAL2 reconciliation) — Tech Lead reconciled. Credited and accepted at face value: QA-01/02/03 are genuinely RESOLVED — independently re-ran analyzer/format/`flutter test` (313/313) myself on the committed tree (commit `9371468`) and they pass; the runtime-capture and probe/widget-test methodology QA describes is sound and consistent with the already-verified code. Corrected two things QA got wrong, neither of which reopens QA-01/02/03: (1) **QA Result.** `premium-ui-rubric.md` § Verdict Bands is unconditional — "85–92: hedef bandın altında; zorunlu rework" and "92 ve altı `Approved with Notes` ile geçirilemez," with no carve-out for a shortfall already labelled non-blocking elsewhere (`visual-quality-gate.md` §Independent QA Gate: "93 altını mandatory rework yapar," same unconditional framing). An 88 cannot be `Approved with Notes` regardless of *why* it's 88; QA conflated "QA-04 doesn't have to be fixed in the a11y-rework task" (true, Round 1's ruling) with "QA-04 no longer counts toward the numeric gate" (not true — corrected `QA Result: Rejected`). (2) **QA-04 status.** Read the current code directly: `app/lib/design/typography.dart:106` (`caption` role, height 1.3) and `app/lib/design/components/buttons.dart:195-199` (`OutlinePill`, horizontal padding added) show 2 of QA-04's 3 items are *already fixed* — QA's Round 2 Findings carried forward Round 1's "QA-04 unchanged" prose without diffing it against the current tree. Only the third item (long Turkish words mid-word-wrapping at extreme OS text scale, isolating a trailing glyph — real, confirmed by QA's own `xxxl` captures) is genuinely open. Also removed a stray `app/9.png` (a screenshot accidentally committed into the app tree by QA's own commit, contaminating the `app` fingerprint QA itself cites — not referenced anywhere, no history before this commit). Routing: F00-FE-A11Y-REWORK2 activated, narrowly scoped to the one real remaining item; then F00-QA-VISUAL3 to verify it and rescore honestly — QA is invited to re-examine whether its own conservative "yalnız galeri" ceiling applies to every dimension, or, per the rubric's own dimension-7 text, only clearly to Motion (the only dimension whose text explicitly withholds an automatic 10 absent a real motion surface); this is a question for QA's own evidence-based judgment, not a score Tech Lead is assigning. Full text: [orchestration-at-fe-rework2-activation.md](../../history/f00-design-foundation-2026-09-24/orchestration-at-fe-rework2-activation.md).

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-24
* Summary: F00-QA-VISUAL2 reconciled. QA-01/02/03 credited as genuinely RESOLVED (independently re-ran analyze/format/test myself, 313/313 green). QA Result corrected from Approved with Notes to Rejected (premium-ui-rubric.md's Verdict Bands are unconditional; 88 is "zorunlu rework," and "92 ve altı Approved with Notes ile geçirilemez" — no non-blocking exception exists). QA-04 status corrected: 2 of 3 items already fixed in code (verified directly); only the display/headline mid-word-wrap item is genuinely open. Stray app/9.png removed. F00-FE-A11Y-REWORK2 activated, narrowly scoped; owner -> Frontend/Mobile Developer.

## Context & Follow-ups

Why now: the ai-system upgrade (cfd6b59) made an independent visual gate (>= 93 total, every rubric dimension >= 8, rendered evidence) mandatory for visual scope, and the project has no Selected Foundation; shipped visuals use the default system font, Material icons and text-only legacy directions with self-scores only. F05-QA-STRICT and F08 local evidence continue in parallel queue positions (they are Visual Scope none / non-visual); no feature with a visual scope activates before Selected.

## History & Evidence References

* [Scope contract](architecture.md); [Design Adoption Route](../../workflow-follow-ups.md); [platform.md §14](../../project-authority/platform.md).
* Shipped identity for reference: `app/lib/play/play_theme.dart`; surfaces documented in F03 ui-design.md (§5–§8, §16), F04 ui-design.md, F05 ui-design.md.
* Canonical execution: role-execution-contract.md.
* [Frontend delivery](frontend.md) · [QA verdict](qa.md) · [carrier PRD statement](prd.md) · archived working orchestrations: [at the first Frontend delivery](../../history/f00-design-foundation-2026-09-21/orchestration-at-frontend-delivery.md) · [at the accessibility-rework reconciliation](../../history/f00-design-foundation-2026-09-23/orchestration-at-a11y-reconciliation.md) · [at the F00-QA-VISUAL2 verdict](../../history/f00-design-foundation-2026-09-23/orchestration-at-qa-visual2-verdict.md).

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
* 2026-09-24 — Tech Lead: F00-QA-VISUAL2 reconciled; QA-01/02/03 credited (independently re-verified, 313/313 tests green); QA Result corrected Approved with Notes -> Rejected (premium-ui-rubric.md Verdict Bands unconditional at 88/100 — "92 ve altı Approved with Notes ile geçirilemez"); QA-04 status corrected (2 of 3 items already fixed in code, only the mid-word-wrap item open); stray app/9.png removed; F00-FE-A11Y-REWORK2 activated for the Frontend/Mobile Developer, narrowly scoped; F00-QA-VISUAL3 queued.

## Current Frontend Brief (F00-FE-A11Y-REWORK2 — activated 2026-09-24)

Narrow rework of the one QA-04 item that's genuinely still open. Do not touch QA-01/02/03's fix mechanisms (`minHeight`, `excludeSemantics`, the focus ring) — they're independently verified and closed; this task's diff should be small.

**The defect (QA's own E19 evidence, `qa.md` § F00-QA-VISUAL2):** at OS text scale >= accessibility-extra-extra-extra-large (~3.12x), the `display` and `headline` type roles (`typography.dart`) render long Turkish strings ("Sıradaki döngüyü çöz.", "Döngü tamamlandı.") wider than the available line width; Flutter's `TextPainter` then breaks a single token mid-word with no hyphen (observed: "tamamlandı." split into "tama"/"mland"/"ı." across three lines, the trailing "ı." isolated on its own). Not a widow in the word-wrap sense — a forced mid-word break because the token itself doesn't fit.

**Already fixed, do not re-touch (verified directly in code 2026-09-24):** `caption` role line-height (`typography.dart:106`, now 1.3) and `OutlinePill` horizontal padding (`buttons.dart:195-199`) — QA's Round 2 report mis-stated these as still open; they are not.

**Fix direction (your call, document the reasoning):** a documented scale ceiling on `display`/`headline` via `loopCappedTextScaler`, matching the precedent already set for `label` (`typography.dart` — a documented exception, not silent); or a wrap-safe strategy that avoids the mid-word break. Either way, state the rule in a doc comment the way the existing QA-01/QA-04 fixes do.

**Evidence bar (the QA-01 lesson applies):** a widget test alone is not sufficient — the first QA-01 fix passed every widget test including a stress test to 3.12x and still overflowed 1.5 pt on a real device. Capture the real gallery at OS `accessibility-medium` (1.65x, the floor) **and** `accessibility-extra-extra-extra-large` (~3.12x) on iPhone 16, confirm no mid-word break/isolated glyph at either scale, re-run `melos run analyze` / `dart format --set-exit-if-changed app` / `melos run test` / the F03 device suite.

**Exit:** frontend.md, a new dated section; Delivery Review stays QA's to reset, you set it to Pending on delivery per the standard footer.

## Earlier briefs

The UI Designer briefs (F00-UI-FOUNDATION, F00-UI-DIRECTION-C, F00-UI-FINALIZE), the Frontend briefs (F00-FE-DESIGN-SYSTEM, F00-FE-A11Y-REWORK) and both QA briefs (F00-QA-VISUAL verdict Rejected, F00-QA-VISUAL2 scenarios PASSED but overall QA Result corrected to Rejected on reconciliation — see Last Decision) are closed; their content lives in design-foundation.md (§4-§19), ui-design.md, architecture.md §7, frontend.md, qa.md and the archived working orchestrations.
