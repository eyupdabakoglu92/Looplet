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
- [x] Task ID: F03-FE-D2 | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-28 — the D2 win sequence, board → result transition, full-screen `ResultView` and retry transition A implemented from `app/lib/design` per architecture §20 / §20.7 (C1–C3); `docked_row.dart`, `board_tile.dart`, `won_composition.dart` and `CompletionPanel` deleted; design-layer additions `TileFace.answer`, `StarRow.revealMs`, `ScrollBand` with component tests; tests updated (§20.4 + four F05) and added (`won_sequence_test`, `result_view_test`, `result_components_test`); app suite 503 passed, analyze / format clean, integration_test 13 / 13 on the iPhone 16. `frontend.md` Visual Parity Evidence: runtime screenshots, parity composites, 10 recordings with the frame-timing table, the text sweep and Reduce Motion on the three simulators. NTLC-D2-1 … 3 (informational / evidence limits) | Depends On: F03-UI-D2
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

Ready for Implementation

## Visual Evidence

Selected-source records for this surface, all in features/f00-design-foundation/design/:
* the result `S-04` (perfect), `S-04b` (new best), `S-05` (2★);
* the transition frames `S-08 … S-14` and the reduced frames `S-15`, `S-16`, taken from the executable prototype `design/src/S-transition-prototype.html` (F00 ui-design §11);
* the device variants `S-v-*` and the component sheet `S-91-components.png`.

Their manifest is features/f00-design-foundation/ui-design.md § Visual Evidence Manifest.

The shipped baseline is conformance-audit.md §6 and §12 (`design/audit/cur-won-*`, `cur-result-*`, `cur-a11y-ax5-result.png`, the pairs `pair-08 … pair-14`), captured at 615e94c. The current runtime (legacy won moment over the D1 board, dock on the goal rail per §19.9 (1)) is in features/f03-puzzle-play-session/qa/d1/ (QA-16-31 … 35, QV-16-won-L01-perfect.mp4) and qa/d1r/ (QA-16-L01-won-ax5-rest.jpg).

D1 records (the Play surface this transition starts from; gate Passed 2026-09-28) are listed in the archived orchestration history/f03-puzzle-play-session-2026-09-28/orchestration-before-phase-d2.md.

D2 handoff records (2026-09-28, UI Designer) are in ui-design.md §16.12b Visual Evidence Manifest:
* selected-source D2-01…D2-09b, D2-11, D2-12 and the D2-V device variants;
* accessibility D2-10 (1.3× cap on three devices) and D2-10-AX5;
* motion-prototype MP-D2 (design/src/D2-motion-prototype*.html), MP-D2-S (D2-M-* stills) and MP-D2-CHECK (design/src/timeline-check-d2.txt).

The artefacts are in features/f03-puzzle-play-session/design/. Accepted at the Tech Lead's visual-gate checkpoint on 2026-09-28 (architecture §20.7): the retry transition A is the adopted design.

D2 implementation parity records (2026-09-28, Frontend/Mobile Developer; `frontend.md` § Visual Parity Evidence) are in features/f03-puzzle-play-session/design/runtime-d2/:
* runtime-screenshot RT-16-D2-01 … 09b, RT-16-L30-terminal, RT-16e-*, RT-promax-*, RT-16e-D2-12 (pressed);
* parity-comparison PC-D2-*.jpg + parity-measurements.txt;
* runtime-video RV-16-r2 / -warm / -premount, RV-16-r0 (L26), RV-16-r4, RV-16e-r4, the retries and both reduced paths, with the frame-timing table;
* accessibility A11Y-16-sweep (large → AX5, scrolled), A11Y-16e, A11Y-pm.
The QA record is pending (see Pending Evidence).

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
  * Provenance / Note: 2026-09-28 UI Designer, HEAD 489606d + working tree. ui-design.md §16 (the D2 handoff; §1–§14 unchanged apart from cross-references). 58 PNG renders + 5 contact sheets in features/f03-puzzle-play-session/design/, from design/src/gen-d2.mjs + render-d1.sh (HTML/CSS → headless Chrome @2x, D1 tokens and geometry, F00 S-04 anchors); executable prototypes design/src/D2-motion-prototype(-row0|-row4|-frozen|-retry).html; timeline self-test design/src/timeline-check-d2.txt. Content: L4, L5, L26, L30 with BFS-verified optimal solutions replayed by the generator; the frozen-in-row case is synthetic (no shipped level can produce it). Covers the audit's D2 renders 11–18, rows 0 and 4, AX5. Generated design artefacts, not runtime; Android not rendered. **Accepted by the Tech Lead 2026-09-28** (architecture §20.7): the HTML regenerates byte-for-byte, the four solutions solve in the real engine at optimal, the self-test reproduces 7 / 7; its row-containment assertion is non-discriminating (negative control), so the row bound was verified by a displacement probe (0.00 px before 600) and C2 sets the parity measure.

- Evidence ID: F03.D2-PARITY
  * Scenario: The runtime matches the D2 handoff on the canonical simulators — every variant beside its render; screen recordings of the full sequence (rows 0 and 4, a special-tile row), the retry transition and the reduced path, with frame timing (nothing outside the board before T0 + 600; rest ≤ T0 + 940; reduced ≈ 660); OS text large → AX5 on the result; Reduce Motion on and off; suites and integration_test green
  * Required Class: runtime + automated functional
  * Target / Environment: iOS Simulator 18.6 — iPhone 16 (primary), 16e, 16 Pro Max
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: F03.D2-HANDOFF accepted (gate Ready for Implementation)
  * Re-evaluation Trigger: F03-FE-D2 delivery
  * Blocks: Visual Quality Gate = Ready for QA; F03-QA-D2
  * Result: PASS
  * Provenance / Note: 2026-09-28 Frontend/Mobile Developer, HEAD 051c64c + working tree, debug build on iOS Simulator 18.6 (iPhone 16 / 16e / Pro Max). `frontend.md` § Visual Parity Evidence; artefacts in design/runtime-d2/, tooling design/src/capture-d2.sh, video-d2.swift, timing-d2.py, parity-d2.swift / .sh. Frame timing (T0 fitted to the chrome dim, ± one capture frame): the row holds its board cells (0.00 pt, C2) on every frame before T0 + 600 and first moves at 616–633; first result pixel 716–719; chrome final on the first frame after 720; pill at rest on the first frame after 940; stars done 1284–1289; retry ≤ 350 (reduced ≈ 160); reduced win ≈ 660; no gap > 30 ms in 600–1400 on the 16e row-4 run. Parity at 1.0× within 0.3–1.3 pt of the D2 renders on three devices. Suites: analyze / format clean, app 503 passed, integration_test 13 / 13 on the iPhone 16. Limits (NTLC-D2-3): D2-07 not reachable at runtime; focus ring not injectable (widget test); VoiceOver and lifecycle mid-sequence by widget tests only; debug builds only; Android not run. Two F00-component deviations recorded (NTLC-D2-2).

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

Run Tech Lead — the mandatory D2 parity checkpoint: reconcile F03-FE-D2 (`frontend.md`, Delivery Review Pending), verify F03.D2-PARITY and the frame-timing table, rule on NTLC-D2-1 … 3, and set the Visual Quality Gate to Ready for QA and open F03-QA-D2 if accepted.

## Last Decision

2026-09-28 (D2 visual-gate checkpoint) — the Tech Lead reconciled F03-UI-D2 (commit 6352a75) and accepted it.

**Task coverage.** Every Current Brief item is present:
* the result layout on 393 × 852 with the 390 × 844 / 440 × 956 table (§16.6);
* all ten variants with the C-4 markers, badge precedence and CTA weighting (§16.8; renders D2-01…D2-09b);
* the win sequence, board → result and result → Play motion with reduced paths, as five executable prototypes plus 37 timed stills (§16.5);
* the renders for rows 0 / 2 / 4, a locked row (L26), a synthetic frozen row, the 1.3× cap on three devices and AX5;
* copy proposals, accessibility, the §16.12a matrix, the §16.12b manifest and the §16.11.1 acceptance list.

**Evidence, checked independently** (architecture §20.7):
* the generator reproduces all 70 HTML / job files byte-for-byte; 63 PNGs present; contrast 14 / 14;
* the content matches `content/journey/tr`, and the four solutions solve in the real engine with the production dictionary at `optimalMoves`;
* star rule and CTA weighting match the shipped code;
* the timeline self-test reproduces 7 / 7;
* negative controls: early headline and early radial caught; late CTA reported; an early row glide **not** caught by the containment check — a displacement probe shows the delivered rows hold still (0.00 px) before 600;
* the delivery commit touches no code or authority file; the superseded §16 is archived.
* manifest traceability: three `direction-render` pointer rows to the F00 exploration (named in §16.2) were added to §16.12b by the Tech Lead; the full state audit then passes.

**Rulings** (§20.7): retry transition A adopted (Assumption — the user may veto for B, no new round); chrome fade 600–720, "Yolculuğu tamamla", the no-optimal line and the authored headline break accepted; the design-layer additions allowed on the §19.8 (2) terms.

**Corrections** (binding): C1 — stars and `HARİKA` never wait for the rating read; only `EN İYİ` and `YENİ EN İYİ` wait for `ratingResolved`. C2 — the row bound is measured as displacement from its board cell. C3 — the reduced win cross-fade is contracted.

**State:** Delivery Review Accepted; Visual Quality Gate Ready for Implementation; F03-FE-D2 Open; owner → Frontend/Mobile Developer.

The pre-checkpoint orchestration (D2 activation decision, F03-UI-D2 brief) is archived byte-for-byte as history/f03-puzzle-play-session-2026-09-28/orchestration-at-ui-d2-delivery.md.

## Last Update

* Updated By: Frontend/Mobile Developer
* Timestamp: 2026-09-28
* Summary: F03-FE-D2 delivered — task Done; F03.D2-PARITY PASS (with stated limits); Delivery Review Pending; owner → Tech Lead (mandatory parity checkpoint before QA).

## Context & Follow-ups

* **Phase D1 closed 2026-09-28** (Play; §19, closure §19.12). Its Play surface is the transition's starting frame and a regression input.
* **D2 inputs:** DESIGN-ADOPTION-CONTRACT-AMENDMENTS (D2 items, applied in §20); OPTIONAL-QUALITY-NOTES (the 30 ms stagger, text-scale density — both now in §20.3); NTLC-6 / A-2 result at AX5.
* **Still open, outside D2:** F03-MULTITOUCH-FIRST-POINTER; MOVESCARD-COUNTER-LINE-HEIGHT; ANDROID-CI-EVIDENCE.
* **Design Adoption Route:** workflow-follow-ups.md.
* **Audit:** features/f00-design-foundation/conformance-audit.md.

## History & Evidence References

* [QA report](qa.md) (D1R, 2026-09-28), [contract](architecture.md) (§12, §18, §19, §20), [UI design](ui-design.md) (§1–§14 D1; §16 D2), [frontend delivery](frontend.md) (D1 / D1R).
* [Orchestration at the F03-UI-D2 delivery](../../history/f03-puzzle-play-session-2026-09-28/orchestration-at-ui-d2-delivery.md); [ui-design.md before D2](../../history/f03-puzzle-play-session-2026-09-28/ui-design-before-phase-d2.md) (the superseded F03-UI-WON §16).
* [Terminal D1 orchestration](../../history/f03-puzzle-play-session-2026-09-28/orchestration-before-phase-d2.md); the D1 working record in [history/f03-puzzle-play-session-2026-09-27/](../../history/f03-puzzle-play-session-2026-09-27/README.md); the [closure record of 2026-09-21](../../history/f03-closure-2026-09-21/orchestration.md) — historical only, not a run queue.
* [Portfolio follow-ups](../../workflow-follow-ups.md); [Phase C audit](../f00-design-foundation/conformance-audit.md).
* Canonical execution: role-execution-contract.md.

## Change Log

* 2026-09-18 to 2026-09-21 — migration, win-sequence rework, final QA, closure (behaviour / accessibility); full log in the closure record.
* 2026-09-27 to 2026-09-28 — Design Adoption Phase D1 (Loop Glass Play): reopened, handoff, delivery, QA Rejected, rework, re-QA Approved with Notes, gate Passed, **Done** (architecture §19; log in the archived terminal orchestration).
* 2026-09-28 — Tech Lead: D2 activation.
  * **Decided:** architecture §20 (contract and rulings); in-place amendments in F03 / F04 / F05; Visual Scope `motion-critical`; gate Pending.
  * **Next:** F03-UI-D2 Open; owner → UI Designer.
* 2026-09-28 — UI Designer: F03-UI-D2 delivered; task Done; F03.D2-HANDOFF PASS; Delivery Review = Pending; owner → Tech Lead.
  * **Handoff:** ui-design.md §16 (replaces F03-UI-WON); 58 renders + 5 prototypes + timeline self-test; acceptance list §16.11.1.
  * **NTLC:** §16.14 (1) retry transition A / B selection; (2) chrome fade re-timed within the bounds; (3)–(6) copy and design-layer items.
* 2026-09-28 — Tech Lead: D2 visual-gate checkpoint.
  * **Verified:** HTML regenerates byte-identical; solutions solve in the real engine; self-test 7 / 7; negative controls (the row-containment check is non-discriminating — displacement probe 0.00 px before 600).
  * **Decided:** Delivery Review Accepted; Visual Quality Gate Ready for Implementation; architecture §20.7 rulings (retry A; items 2–6) and corrections C1–C3.
  * **Next:** F03-FE-D2 Open; owner → Frontend/Mobile Developer.
* 2026-09-28 — Frontend/Mobile Developer: F03-FE-D2 delivered; task Done; F03.D2-PARITY PASS; Delivery Review = Pending; owner → Tech Lead.
  * **Delivery:** `frontend.md` (D2; the D1 / D1R report archived as history/f03-puzzle-play-session-2026-09-28/frontend-before-phase-d2.md).
  * **NTLC:** NTLC-D2-1 result mounted at T0 + 450; NTLC-D2-2 F00 `StatCell` ★ and `LimePill` pressed look; NTLC-D2-3 evidence limits.

## Current Brief

**F03-FE-D2 — implement the D2 win sequence, transition and full-screen result** (contract: architecture.md §20; rulings and corrections §20.7)

**User-visible symptom** (§20.1): after a solve the row turns amber, docks on the goal rail and a legacy bottom sheet (system font, amber glow, Close) rises over the dimmed board; at AX5 it covers the row and clips (A-2 result, NTLC-6). The user decided on a full-screen result with no board and no Close.

**Affected journey and entry paths** (§20.2): a settled solving move (T0) on any Journey level or debug / non-Journey source → win sequence → transition → result → Next / Retry / back button / system back. Also: a solve with the F05 tutorial visible (L4–6), a thaw on the winning settle, locked tiles in the winning row (L26, L30), level 30, and the app backgrounded or killed mid-sequence.

**Authority:**
* `ui-design.md` §16 — the §16.5 motion tables, the §16.6 layout table, the §16.8 variant table, the §16.11 handoff (must-not-break / flexible / do-not-cheapen, implementation map, strings, semantics) and the **§16.11.1 acceptance list**;
* the renders `design/D2-*` and the prototypes `design/src/D2-motion-prototype(-row0|-row4|-frozen|-retry).html` (`?rm=1`, `?t=<ms>`, `?check=1`);
* architecture §20.3 and the §20.7 rulings, which override §16 where they differ (C1 on the rating read).

**Fix scope:**
1. **Win sequence** on the D1 board: `TileFace(state: winning)` filling over each tile's face (30 ms stagger, 90 ms per tile), icons and frozen dashes fading with the fill (C-11); one bloom; board and chrome dim to 50 %. Delete `docked_row.dart` and the amber seam.
2. **Board → result transition:** a `won` orchestrator driving the §16.5 windows — chrome and board out by 720, the row glides as one layer 600–840 morphing size and radius to the **laid-out** result slot (GlobalKey, scroll offset 0), result content 700–940, stars pop 940–1300. Transforms on layers; no `Opacity` over a repainting board; no blur.
3. **Full-screen `ResultView`** (in-screen state of `/play`, no new route): fixed back button, reserved badge row, capped display headline on two authored lines, free subtitle, the answer row, `StarRow` + reveal, `StatCard` (`SEN` · `OPTİMAL` · `EN İYİ`), `LimePill(glow: false)`, `TextLink` (disabled "· yakında"); the no-optimal line; scroll above the 1.3× cap under the fixed band (`ClampingScrollPhysics`), never at or below it.
4. **Variants and markers** exactly as §16.8 (badge precedence, CTA weighting, "Sonraki bölüm · yakında", "Yolculuğu tamamla" on level 30). Remove `CompletionPanel`, `_GapConnective`, `PanelDensity` and every legacy marker.
5. **Rating read (C1):** stars and `HARİKA` from the synchronous result; `EN İYİ` `—` and no `YENİ EN İYİ` until `ratingResolved`; a late badge fades into the reserved row with no layout shift; write failure → `—`, no badge.
6. **Exits:** back button and system back → `_popToCaller` → `/` at any time in `won`; "Tekrar oyna" → `retryFromCompletion()` wrapped by the **retry transition A** (row flies into the rail 0–300, Play in 160–360; reduced: 160 ms dip); "Sonraki bölüm" → `_nextLevelHandler()`. No Close anywhere.
7. **Input and lifecycle:** input locked T0 → rest (940 / reduced 660; retry 360 / 160); taps dropped, not queued; background mid-sequence → rest on resume; persistence and controller timing unchanged (§20.3 (2–3)).
8. **Reduced motion** (`reduceMotionRequested()`) for all three motions, exactly per §16.5.
9. **Design layer** (§20.7 (6)): the `StarRow` reveal option, the scroll band, the result-size `TileFace.winning`, each with component tests; no token value or dependency change.
10. **Strings / semantics** per §16.11 through `PlayStrings` / `RatingStrings` (TR and the existing EN table).

**Tests:**
* **Update** the tests that reference the removed strings or widgets — §20.4's list (`completion_panel_test`, `won_composition_test`, `play_session_screen_test`, `play_session_runtime_test`, `integration_test/play_session_test`) **plus** `completion_cta_weighting_test`, `journey_home_live_test`, `journey_unlock_flow_test` and `journey_next_level_test` (F05; found at the checkpoint). Every F04 AC1–AC10 and F05 AC1 / AC12 keeps a passing test.
* **Add tests for:** nothing outside the board before T0 + 600 and the row's displacement from its board cell ≤ 0.5 pt before 600 (C2); rest at 940 / 660 and taps dropped before rest; the retry transition at 360 / 160 and moves 0, undo 3 after it; system back at T0 + 300 → `/` with the completion persisted; the variant table (badge, stars, stats, CTA) including level 30 and no Next handler; the layout anchors at 1.0× (±2 pt) and no scroll up to the 1.3× cap on 390 / 393 / 440 widths; AX5 scroll with the back button fixed and landing at offset 0; the C1 late-read path; semantics order and labels.
* **Suites:** `melos run analyze`, `dart format --set-exit-if-changed` (app / packages / tools) and `melos run test` green; `flutter test integration_test` on the iPhone 16 simulator green.

**Evidence** — `frontend.md` § Visual Parity Evidence, gate schema (§20.6, §20.7 "Evidence expected from Frontend"): runtime screenshots and parity composites for every §16.12a result row; screen recordings of rows 0 / 2 / 4 (row 4 also on the 16e), the retry and both reduced paths, with the frame-timing table (C2 displacement, first result pixel, chrome at 0 by 720, rest, retry rest); OS text default / 1.3× / AX5 on the result; Reduce Motion on and off. Record revision, device, time and owner; state Android as a limit. Before rewriting `frontend.md`, archive the current D1 / D1R file byte-for-byte as `history/f03-puzzle-play-session-2026-09-28/frontend-before-phase-d2.md`.

**Non-goals:** engine, scoring, star bounds, persistence, snapshot, lifecycle or route changes; the Next route transition (shipped one stays); Home and the app shell (D3); F11 audio / haptics (intent only); F03-MULTITOUCH-FIRST-POINTER; token changes and new dependencies.

**Exit:** F03-FE-D2 Done with `frontend.md`; F03.D2-PARITY PASS with provenance; Delivery Review = Pending. Hand back to the Tech Lead (mandatory checkpoint → Ready for QA) before F03-QA-D2. Any deviation from §16 / §20.7 beyond the §16.11 "Flexible" list goes to Needs Tech Lead Clarification.

## Earlier briefs

* F03-UI-D2 (UI Designer, done 2026-09-28) — archived byte-for-byte in history/f03-puzzle-play-session-2026-09-28/orchestration-at-ui-d2-delivery.md.
* D1 briefs (F03-UI-D1, F03-FE-D1, F03-QA-D1, F03-FE-D1R, F03-QA-D1R) — archived byte-for-byte in history/f03-puzzle-play-session-2026-09-27/.
