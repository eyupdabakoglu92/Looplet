# F00 — design-foundation: Orchestration

## Feature ID

F00

## Current Status

Blocked

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
- [x] Task ID: F00-QA-VISUAL2 | Assigned Role: QA | Status: Done | Summary: DONE 2026-09-23 — targeted re-verify scenarios PASSED with real independent evidence: QA-01, QA-02 and QA-03 confirmed RESOLVED (gallery captures at 1.65x and 3.12x incl. the CARDS/STATS/TRACK gap Frontend flagged as test-only; a rebuilt semantics probe, 85 nodes, zero duplicate pairs; a new independent focus-ring widget test across 3 control shapes incl. UndoPill); zero regression (313 app tests, F03 13/13, fresh cold launch). Rescored 88/100 (was 80) — Tech Lead reconciliation corrected the reported QA Result from Approved with Notes to Rejected: premium-ui-rubric.md §Verdict Bands is unconditional ("85–92: zorunlu rework"; "92 ve altı Approved with Notes ile geçirilemez") with no carve-out for an already-non-blocking gap; QA's Round 2 Findings text was also found to be stale on 2 of QA-04's 3 items (caption line-height and OutlinePill padding are already fixed in code, confirmed directly — only the display/headline mid-word-wrap item is genuinely still open) | Depends On: F00-FE-A11Y-REWORK
- [x] Task ID: F00-FE-A11Y-REWORK2 | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-26 — the one genuinely remaining QA-04 item fixed: `display`/`headline` roles now require `textScaler: loopCappedTextScaler(context)` at their 3 gallery call sites (documented in `typography.dart`, same pattern as `MovesCard`/`StatCard`/`LoopNode`/`LoopletWordmark`), so no word can outgrow the line and force a mid-word break at extreme OS text scale. Real runtime capture at both accessibility-medium (1.65x) and accessibility-extra-extra-extra-large (~3.12x) on iPhone 16 confirms clean word-boundary wrapping at both scales, both call-site instances (`_TypeRoles` specimen and the journey `GlassCard`); +1 widget test (314 total); analyze/format(app-scoped)/melos test/F03 device suite all green. QA-01/02/03 untouched. Evidence in frontend.md (F00-FE-A11Y-REWORK2 section) | Depends On: F00-QA-VISUAL2
- [x] Task ID: F00-QA-VISUAL3 | Assigned Role: QA | Status: Done | Summary: DONE 2026-09-26 — verdict Rejected (qa.md § F00-QA-VISUAL3; mechanical, per premium-ui-rubric.md's unconditional Verdict Bands): QA-04's remaining item (display/headline mid-word-wrap at extreme OS text scale) confirmed RESOLVED with fresh own runtime evidence at 1.65x and ~3.12x, both call sites, identical clean two-line rendering at both scales; zero regression (314 tests, F03 13/13). Rescored 90/100 (was 88) — Typography 8->9 and Implementation Fidelity 9->10 (QA-04 fully closed, no known remaining defect), eight dimensions reused by fingerprint or held for genuine, specific, still-open reasons (Motion capped by the rubric's own dimension-7 text; Layout/Interaction/Accessibility each held by a real, named verification gap this environment cannot close: partial iOS accessibility-category sweep, no real hardware keyboard, no VoiceOver speech pass). Every dimension >= 8, no fail condition, but total still short of 93. Key finding, distinct from Round 2's mistake: the shortfall is no longer reducible to one non-blocking item — it may be structurally out of reach for this design-system-only, pre-Phase-D scope under this environment's own testing limits (no physical device, no VoiceOver), regardless of further code fixes. Flagged explicitly for Tech Lead; no further code fix proposed this round | Depends On: F00-FE-A11Y-REWORK2

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

- Evidence ID: F00.UI-FOUNDATION-EVIDENCE (consolidated; full text archived: [orchestration-at-fe-rework2-activation.md](../../history/f00-design-foundation-2026-09-24/orchestration-at-fe-rework2-activation.md))
  * Scenario: UI Designer's four Round-1 foundation-stage records (Direction A/B renders, Direction C renders, reference parity, selected-source renders) — all PASS, all superseded by F00.FOUNDATION-SELECTION RESOLVED and the later implementation evidence below
  * Owner Role: UI Designer
  * Result: PASS
  * Provenance / Note: IDs were F00.DIRECTION-RENDERS, F00.DIRECTION-C-RENDERS, F00.REFERENCE-PARITY, F00.SELECTED-SOURCE (2026-09-21). Kept here as a pointer only — the Foundation is Selected, implementation evidence (F00.DS-AUTOMATED/DS-PARITY/DS-A11Y-REWORK/VISUAL-QA2 below) is what current work relies on.

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
  * Result: PASS
  * Provenance / Note: 2026-09-26 Frontend/Mobile Developer, working tree on top of commit 0ec7f46 (Tech Lead reconciliation correction 2026-09-26: the original note cited `9371468`, whose `app` tree still carried the stray `app/9.png`; `0ec7f46` is the commit that removed it, the only difference between the two commits' `app` trees — `app/lib/design` and `app/test/design` themselves are byte-identical at both, so this task's own diff is unaffected either way; not committed by this delivery; 3 files changed — `typography.dart`, `gallery/design_gallery_screen.dart`, `test/design/components_test.dart` — no shipped file, dependency or pubspec change): `melos run analyze` exit 0 (`looplet_app` and every package clean except the pre-existing unrelated `looplet_solver` info-lint); `dart format --output=none --set-exit-if-changed app` exit 0 (110 files, 0 changed; workspace `format:check` still fails only on the pre-existing unrelated `qa/src/qa_probe_main.dart`); `melos run test` exit 0 (app 314, was 313, +1). Runtime: gallery rebuilt, captured at OS `accessibility-medium` (1.65x) and `accessibility-extra-extra-extra-large` (~3.12x) on iPhone 16 — both `display`/`headline` call sites (`_TypeRoles` specimen, journey `GlassCard`) wrap at clean word boundaries at both scales, no mid-word break, no isolated glyph; `StatCard`/`LoopNode` in the same 3.12x frame confirm QA-01's fix still holds (untouched by this task). `flutter test integration_test -d <iPhone 16>` → `+13 All tests passed`, exit 0. Detail: frontend.md (F00-FE-A11Y-REWORK2 section).

- Evidence ID: F00.VISUAL-QA3
  * Scenario: Independent targeted final-stage re-verify of F00-FE-A11Y-REWORK2 — QA's own runtime evidence that QA-04's remaining item is fixed, plus a full regression pass and an honestly re-examined rubric score
  * Required Class: runtime
  * Target / Environment: iOS Simulator 18.6, iPhone 16, debug build of the gallery (QA's own fresh capture, not Frontend's)
  * Owner Role: QA
  * Prerequisite / External Decision: met 2026-09-26 — F00-FE-A11Y-REWORK2 reconciled (Delivery Review Accepted, working tree on commit 0ec7f46)
  * Re-evaluation Trigger: Tech Lead activated F00-QA-VISUAL3 (2026-09-26)
  * Blocks: Visual Quality Gate = Passed; F00 Done
  * Result: PASS
  * Provenance / Note: 2026-09-26 QA, working tree on commit 0ec7f46 (`app/lib/design` tree `0b125cf1…`, unchanged from Round 2 except this task's own 3 files): own fresh gallery captures at accessibility-medium (1.65x) and accessibility-extra-extra-extra-large (~3.12x) on iPhone 16, both `display`/`headline` call sites (`_TypeRoles` specimen and the journey `GlassCard`) — identical clean two-line word-boundary wrapping at both scales, no mid-word break, no isolated glyph; `StatCard`/`LoopNode` unaffected in the same frames. Regression: `melos run analyze`/`dart format --set-exit-if-changed app`/`melos run test` (app 314/314) all exit 0; `flutter test integration_test -d iPhone16` +13 exit 0. Rescored rubric: 90/100 (was 88) — Typography 8->9, Implementation Fidelity 9->10 (QA-04 fully closed, no known remaining defect); eight dimensions held at their Round 2 value for genuine, specific, still-open reasons (not blanket conservatism — see qa.md § F00-QA-VISUAL3 for the per-dimension rationale QA was asked to re-examine). Every dimension >= 8, no fail condition; still short of 93. Key finding: unlike Round 2's claim, the shortfall is not reducible to one already-non-blocking item — Motion is capped by the rubric's own dimension-7 text (unconditional), and Layout/Interaction/Accessibility are each held by a real, named verification gap this environment cannot close (partial iOS accessibility-category sweep, no real hardware keyboard, no VoiceOver speech pass) rather than a fixable code defect. Detail: qa.md (F00-QA-VISUAL3 section).

- Evidence ID: F00.VISUAL-93-GAP-CHECK
  * Scenario: Tech Lead independently checked whether QA's three cited "structural" gaps (partial iOS accessibility-category sweep, no real hardware keyboard, no VoiceOver speech pass) are actually all environment-unclosable, or whether one is simply untested-but-testable
  * Required Class: runtime
  * Target / Environment: iOS Simulator 18.6, iPhone 16
  * Owner Role: Tech Lead
  * Prerequisite / External Decision: None
  * Re-evaluation Trigger: F00-QA-VISUAL3 verdict reconciliation (2026-09-26)
  * Blocks: F00.VISUAL-93-THRESHOLD decision (below)
  * Result: PASS
  * Provenance / Note: 2026-09-26 Tech Lead. `xcrun simctl ui <udid> content_size` lists exactly 12 categories (7 standard + 5 `accessibility-*`); every round's evidence only ever named real runtime captures at 2 of the 5 accessibility categories (medium, extra-extra-extra-large) — the 3 middle ones (`accessibility-large`, `accessibility-extra-large`, `accessibility-extra-extra-large`) had never been captured. Captured all 3 fresh on iPhone 16, both the `_TypeRoles` specimen and the `CARDS, STATS, TRACK` section (`MovesCard`/`StatCard`/`LoopNode`, the journey `GlassCard`): clean at every one, no overflow, no mid-word break. This specific sub-gap is closed — it was a real but closeable testing gap, not an environment limitation. The other two (real hardware/Bluetooth keyboard, a VoiceOver speech pass with live text output) remain genuinely out of reach: both require driving separate physical hardware or a macOS GUI accessibility tool (Accessibility Inspector) that this session's tools cannot operate. Net effect on the rubric: `Layout, Rhythm and Responsiveness` could reasonably move 9->10 on this new evidence (QA's own call to make, not Tech Lead's); the realistic ceiling given the remaining two genuine gaps plus Motion's unconditional dimension-7 text is approximately 91/100 — still short of 93.

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

- Decision ID: F00.VISUAL-93-THRESHOLD
  * Question: F00-QA-VISUAL3 (Rejected, 90/100, potentially ~91 if QA credits the new accessibility-category evidence — F00.VISUAL-93-GAP-CHECK above) closed every named defect (QA-01/02/03/04). The remaining gap under the mandatory-rework 93 line is no longer a fixable code defect — it is `premium-ui-rubric.md`'s own unconditional Motion cap (dimension 7, no real motion surface exists pre-Phase-D) plus two verification methods this session's tools genuinely cannot drive (a real hardware/Bluetooth keyboard; a VoiceOver speech pass via Accessibility Inspector). Under the rubric's own unconditional Verdict Bands, no further Frontend/QA round can close this — how should F00 proceed?
  * Options / Trade-offs: (A) Keep F00 `Rejected`/`Ready for QA`, wait indefinitely for physical-device + VoiceOver + hardware-keyboard access before re-scoring; most rule-faithful, but likely blocks F00 (and, per "one QA feature at a time," the queued F05-QA-STRICT/F08) for an unknown period. (B) Revise `premium-ui-rubric.md`/`visual-quality-gate.md` (marked NORMATIVE / REUSABLE CORE) to define an adjusted bar, or an explicit N/A treatment, for `Visual Scope: design-system` / carrier-with-no-screens features; a project-wide policy change affecting every current and future similarly-scoped feature, not just F00 — deserves explicit sign-off, not a silent Tech Lead edit. (C) Record a one-time, explicitly-scoped exception for F00 only (not a rubric rewrite): accept the current score — every dimension >= 8, zero fail conditions, every named defect fixed, the only shortfall being the rubric's own textually-mandated Motion cap plus two tools this session cannot operate — as sufficient to move Visual Quality Gate to Passed and F00 to Done; noted explicitly as a one-off so it does not silently become precedent. (C) also unblocks the F05/F08 queue as a side effect.
  * Recommendation: C
  * Blocks: Visual Quality Gate = Passed; F00 Done; the F05-QA-STRICT / F08 QA queue (per "one QA feature at a time")
  * Blocking Scope: feature
  * Status: OPEN (user)

## Blockers

F00.VISUAL-93-THRESHOLD open (Blocking Scope: feature) — no executable code/QA task remains until resolved; independent F05/F08 work is not itself blocked by this gate but its QA activation is queued behind F00's slot.

## Next Action

Awaiting the user's decision on F00.VISUAL-93-THRESHOLD (see Open Decision Gates): `Run Tech Lead. Decision: F00.VISUAL-93-THRESHOLD — <A/B/C>`. No executable code or QA task remains — every named defect is fixed; the residual gap under the generic 93 line is the rubric's own unconditional Motion cap plus two verification methods this session cannot drive. F05-QA-STRICT and F08 stay queued behind F00's QA slot until this resolves.

## Last Decision

Earlier decisions of this track, full text archived: [Direction A/B rejection through the visual-gate checkpoint (through 2026-09-21)](../../history/f00-design-foundation-2026-09-21/orchestration-at-frontend-delivery.md); [the F00-FE-DESIGN-SYSTEM reconciliation (commit 78b22e3: task coverage, contract compliance, deviations D1-D7 accepted, QA plan locked) and the F00-QA-VISUAL Rejected-verdict reconciliation (score 80/100; findings QA-01-04 accepted; QA-03 focus ring ruled to be implemented, not deferred; F00-FE-A11Y-REWORK opened)](../../history/f00-design-foundation-2026-09-23/orchestration-at-a11y-reconciliation.md). Summary: F00 opened as the Design Adoption Route carrier after F03 closed; Direction C selected (`B: 2=2, 5=Looplet`), Foundation Selected 2026-09-21; design-system layer delivered, reconciled, sent to QA; QA Rejected on accessibility grounds (80/100); Tech Lead ruled the focus ring must be implemented, opened the rework task.

2026-09-23 (F00-FE-A11Y-REWORK reconciliation, full text archived: [orchestration-at-qa-visual2-verdict.md](../../history/f00-design-foundation-2026-09-23/orchestration-at-qa-visual2-verdict.md)) — Tech Lead reconciled the rework delivery: all four findings addressed and independently code-verified (QA-01/02/03 fix mechanisms confirmed in `buttons.dart`/`info.dart`/`surfaces.dart`), contract compliance confirmed (7 files, only under `app/lib/design`/`app/test/design`), evidence re-run independently (analyze/format/test/F03 all exit 0), one mis-cropped "before" evidence JPEG found and corrected (report correction, not rework). Delivery Review = Accepted; F00-QA-VISUAL2 activated with a targeted re-verify brief.

2026-09-23 (F00-QA-VISUAL2 verdict, full text archived: [orchestration-at-fe-rework2-activation.md](../../history/f00-design-foundation-2026-09-24/orchestration-at-fe-rework2-activation.md)) — QA delivered Approved with Notes, 88/100 (was 80), on the claim that the shortfall was entirely a non-blocking, out-of-scope gap; see the next entry for why Tech Lead corrected this.

2026-09-24 (F00-QA-VISUAL2 reconciliation, full text archived: [orchestration-at-fe-rework2-activation.md](../../history/f00-design-foundation-2026-09-24/orchestration-at-fe-rework2-activation.md)) — QA-01/02/03 credited RESOLVED; QA Result corrected `Approved with Notes` → `Rejected` (premium-ui-rubric.md's Verdict Bands are unconditional at 88/100); QA-04 status corrected (2 of 3 items already fixed); stray `app/9.png` removed; F00-FE-A11Y-REWORK2 activated.

2026-09-26 (F00-FE-A11Y-REWORK2 reconciliation, full text archived: [orchestration-at-qa-visual3-activation.md](../../history/f00-design-foundation-2026-09-26/orchestration-at-qa-visual3-activation.md)) — Tech Lead reconciled: task coverage/contract compliance confirmed directly (exactly 3 files, no shipped surface), evidence re-run independently (314/314), runtime captures personally reviewed; one provenance correction (base commit `9371468` → `0ec7f46`, code diff unaffected). Delivery Review = Accepted; F00-QA-VISUAL3 activated.

2026-09-26 (F00-QA-VISUAL3 verdict, full text archived: [orchestration-at-qa-visual3-verdict.md](../../history/f00-design-foundation-2026-09-26/orchestration-at-qa-visual3-verdict.md)) — QA delivered Rejected, 90/100 (was 88): QA-04's remaining item confirmed resolved with fresh own evidence at 1.65x/~3.12x, zero regression; correctly reported Rejected per the rubric's unconditional Verdict Bands (not repeating Round 2's mistake). Key finding: the shortfall no longer traces to one fixable item — it combines the rubric's own unconditional Motion cap with real, named verification gaps this environment cannot currently close (no physical device, no VoiceOver speech pass, no real hardware keyboard, partial iOS accessibility-category sweep). qa.md § Tech Lead Note lays out three paths (wait for device/VoiceOver access; revise the normative rubric for taşıyıcı/no-screen scopes — a project-wide call, not a single-feature one; escalate to the user/PO) and leaves the choice open.

## Last Update

* Updated By: QA
* Timestamp: 2026-09-26
* Summary: F00-QA-VISUAL3 Done — verdict Rejected (qa.md § F00-QA-VISUAL3). QA-04's remaining item confirmed RESOLVED with fresh own runtime evidence at 1.65x and ~3.12x; zero regression (314 tests, F03 13/13); rescored 90/100 (was 88), every dimension >= 8. Correctly reported Rejected per the rubric's unconditional Verdict Bands — not repeating Round 2's mistake. Key finding: the remaining gap is no longer one fixable defect but a combination of the rubric's own Motion cap and this environment's real, specific verification limits (no physical device, no VoiceOver, no real hardware keyboard); flagged for Tech Lead, no further code fix proposed. Owner -> Tech Lead.

## Context & Follow-ups

Why now: the ai-system upgrade (cfd6b59) made an independent visual gate (>= 93 total, every rubric dimension >= 8, rendered evidence) mandatory for visual scope, and the project has no Selected Foundation; shipped visuals use the default system font, Material icons and text-only legacy directions with self-scores only. F05-QA-STRICT and F08 local evidence continue in parallel queue positions (they are Visual Scope none / non-visual); no feature with a visual scope activates before Selected.

## History & Evidence References

* [Scope contract](architecture.md); [Design Adoption Route](../../workflow-follow-ups.md); [platform.md §14](../../project-authority/platform.md).
* Shipped identity for reference: `app/lib/play/play_theme.dart`; surfaces documented in F03 ui-design.md (§5–§8, §16), F04 ui-design.md, F05 ui-design.md.
* Canonical execution: role-execution-contract.md.
* [Frontend delivery](frontend.md) · [QA verdict](qa.md) · [carrier PRD statement](prd.md) · archived working orchestrations: `history/f00-design-foundation-2026-09-{21,23,24,26}/` (each folder's own README explains its checkpoint, oldest to newest).

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
* 2026-09-26 — Frontend/Mobile Developer: F00-FE-A11Y-REWORK2 delivered (the one remaining QA-04 item fixed via `loopCappedTextScaler` on `display`/`headline`, real runtime evidence at 1.65x and ~3.12x, +1 test to 314, zero regression); task Done; F00.DS-A11Y-REWORK2 PASS; Delivery Review = Pending; owner -> Tech Lead.
* 2026-09-26 — Tech Lead: F00-FE-A11Y-REWORK2 reconciled (task coverage, contract compliance and evidence independently re-verified; a base-commit provenance mistake found and corrected, code diff unaffected); Delivery Review = Accepted; F00-QA-VISUAL3 activated for the QA role; QA Result reset to None.
* 2026-09-26 — QA: F00-QA-VISUAL3 Done with verdict Rejected (qa.md: QA-04's remaining item confirmed RESOLVED with fresh own runtime evidence, zero regression, rescored 90/100 of 100, every dimension >= 8, no fail condition; key finding — the shortfall is no longer one fixable item, it combines the rubric's unconditional Motion cap with real environment-testing limits this project currently cannot close); F00.VISUAL-QA3 PASS (mandated scope); QA Result Rejected; owner -> Tech Lead.

## Current Brief

None active — awaiting Tech Lead's reconciliation of F00-QA-VISUAL3 and a decision on the structural-93 finding (qa.md § Tech Lead Note). No implementation task is open.

## Earlier briefs

The UI Designer briefs (F00-UI-FOUNDATION, F00-UI-DIRECTION-C, F00-UI-FINALIZE), the Frontend briefs (F00-FE-DESIGN-SYSTEM, F00-FE-A11Y-REWORK, F00-FE-A11Y-REWORK2) and all three QA briefs (F00-QA-VISUAL verdict Rejected; F00-QA-VISUAL2 scenarios PASSED but overall QA Result corrected to Rejected on reconciliation; F00-QA-VISUAL3 verdict Rejected, 90/100, QA-04 confirmed resolved but the shortfall now structural — see Last Decision) are closed; their content lives in design-foundation.md (§4-§19), ui-design.md, architecture.md §7, frontend.md, qa.md and the archived working orchestrations (full brief text: [orchestration-at-qa-visual3-verdict.md](../../history/f00-design-foundation-2026-09-26/orchestration-at-qa-visual3-verdict.md)).
