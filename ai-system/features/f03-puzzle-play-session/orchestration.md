# F03 — puzzle-play-session: Orchestration

## Feature ID

F03

## Current Status

In QA

## Current Owner

QA

## Next Role

QA

## Active Task Ledger

- [x] Task ID: F03-UI-D2 | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-28 — ui-design.md §16 rewritten as the D2 handoff (replaces F03-UI-WON; §1–§14 D1 unchanged apart from cross-references). The full-screen result as a flow column on the S-04 anchors (layout table for 393 / 390 / 440), all 10 variants (C-4 markers and badge precedence, CTA weighting, no-optimal, Next not wired, level 30), the win sequence re-timed on the D1 board with special tiles (C-11), the board → result and result → Play transitions with reduced paths. 58 renders in design/ (12 result, 6 text-scale incl. the 1.3× cap on three devices and AX5, 3 device variants, 37 motion stills) + 5 contact sheets; 5 executable prototypes (rows 0 / 2 / 4 from BFS-verified solutions, a synthetic frozen case, retry); a timeline self-test (rest 940 / reduced 660, first result pixel 685 ms, retry 360 / 160). D2 acceptance list §16.11.1; manifest §16.12b. NTLC §16.14: retry transition A vs B needs a selection record (non-blocking), the re-timed chrome fade, copy items, design-layer additions. No code | Depends On: -
- [x] Task ID: F03-FE-D2 | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-28 (commit 67d9ecb) — the D2 win sequence, board → result transition, full-screen `ResultView` and retry transition A implemented from `app/lib/design` per architecture §20 / §20.7 (C1–C3); `docked_row.dart`, `board_tile.dart`, `won_composition.dart` and `CompletionPanel` deleted; design-layer additions `TileFace.answer`, `StarRow.revealMs`, `ScrollBand` with component tests; tests updated (§20.4 + four F05) and added (`won_sequence_test`, `result_view_test`, `result_components_test`); app suite 503 passed, analyze / format clean, integration_test 13 / 13 on the iPhone 16. `frontend.md` Visual Parity Evidence: runtime screenshots, parity composites, 10 recordings with the frame-timing table, the text sweep and Reduce Motion on the three simulators. NTLC-D2-1 … 3 ruled in architecture §20.8. Accepted at the Tech Lead's parity checkpoint 2026-09-28 | Depends On: F03-UI-D2
- [ ] Task ID: F03-QA-D2 | Assigned Role: QA | Status: Open | Summary: Final-stage independent visual QA of D2 (rubric ≥ 93 from runtime video; the §16.11.1 acceptance list; F04 AC1–AC10, F05 AC1 / AC12, F03 AC8 / AC11; lifecycle mid-sequence; text sweep; Reduce Motion; D1 Play regression) (architecture §20.6, §20.8; Current Brief) | Depends On: F03-FE-D2

## Open Tasks

* F03-QA-D2 (QA) — the Current Brief below.

## Handoff Plan

None

## Delivery Review

Accepted

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

Ready for QA

## Visual Evidence

Selected-source records for this surface, all in features/f00-design-foundation/design/:
* the result `S-04` (perfect), `S-04b` (new best), `S-05` (2★);
* the transition frames `S-08 … S-14` and the reduced frames `S-15`, `S-16`, taken from the executable prototype `design/src/S-transition-prototype.html` (F00 ui-design §11);
* the device variants `S-v-*` and the component sheet `S-91-components.png`.

Their manifest is features/f00-design-foundation/ui-design.md § Visual Evidence Manifest.

The shipped baseline is conformance-audit.md §6 and §12 (`design/audit/cur-won-*`, `cur-result-*`, `cur-a11y-ax5-result.png`, the pairs `pair-08 … pair-14`), captured at 615e94c. The pre-D2 runtime (legacy won moment over the D1 board, dock on the goal rail per §19.9 (1)) is in features/f03-puzzle-play-session/qa/d1/ (QA-16-31 … 35, QV-16-won-L01-perfect.mp4) and qa/d1r/ (QA-16-L01-won-ax5-rest.jpg).

D1 records (the Play surface this transition starts from; gate Passed 2026-09-28) are listed in the archived orchestration history/f03-puzzle-play-session-2026-09-28/orchestration-before-phase-d2.md.

D2 handoff records (2026-09-28, UI Designer) are in ui-design.md §16.12b Visual Evidence Manifest:
* selected-source D2-01…D2-09b, D2-11, D2-12 and the D2-V device variants;
* accessibility D2-10 (1.3× cap on three devices) and D2-10-AX5;
* motion-prototype MP-D2 (design/src/D2-motion-prototype*.html), MP-D2-S (D2-M-* stills) and MP-D2-CHECK (design/src/timeline-check-d2.txt).

The artefacts are in features/f03-puzzle-play-session/design/. Accepted at the Tech Lead's visual-gate checkpoint on 2026-09-28 (architecture §20.7): the retry transition A is the adopted design.

D2 implementation parity records (2026-09-28, Frontend/Mobile Developer, commit 67d9ecb; `frontend.md` § Visual Parity Evidence) are in features/f03-puzzle-play-session/design/runtime-d2/:
* runtime-screenshot RT-16-D2-01 … 09b, RT-16-L30-terminal, RT-16e-*, RT-promax-*, RT-16e-D2-12 (pressed);
* parity-comparison PC-D2-*.jpg + parity-measurements.txt;
* runtime-video RV-16-r2 / -warm / -premount, RV-16-r0 (L26), RV-16-r4, RV-16e-r4, the retries and both reduced paths, with the frame-timing table;
* accessibility A11Y-16-sweep (large → AX5, scrolled), A11Y-16e, A11Y-pm.

Accepted at the Tech Lead's parity checkpoint on 2026-09-28 (architecture §20.8): parity reproduced byte for byte, frame timing within 1–3 ms apart from two corrected cells. The QA record is pending (see Pending Evidence).

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
  * Provenance / Note: 2026-09-28 UI Designer, HEAD 489606d + working tree (committed 6352a75). ui-design.md §16; 58 PNG renders + 5 contact sheets in features/f03-puzzle-play-session/design/ from design/src/gen-d2.mjs + render-d1.sh; executable prototypes design/src/D2-motion-prototype(-row0|-row4|-frozen|-retry).html; timeline self-test design/src/timeline-check-d2.txt. Generated design artefacts, not runtime; Android not rendered. **Accepted by the Tech Lead 2026-09-28** (architecture §20.7).

- Evidence ID: F03.D2-PARITY
  * Scenario: The runtime matches the D2 handoff on the canonical simulators — every variant beside its render; screen recordings of the full sequence (rows 0 and 4, a special-tile row), the retry transition and the reduced path, with frame timing (nothing outside the board before T0 + 600; rest ≤ T0 + 940; reduced ≈ 660); OS text large → AX5 on the result; Reduce Motion on and off; suites and integration_test green
  * Required Class: runtime + automated functional
  * Target / Environment: iOS Simulator 18.6 — iPhone 16 (primary), 16e, 16 Pro Max
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: F03.D2-HANDOFF accepted (gate Ready for Implementation)
  * Re-evaluation Trigger: F03-FE-D2 delivery
  * Blocks: Visual Quality Gate = Ready for QA; F03-QA-D2
  * Result: PASS
  * Provenance / Note: 2026-09-28 Frontend/Mobile Developer, HEAD 051c64c + working tree (committed 67d9ecb; `app/` tree `f5641d2f…`), debug build on iOS Simulator 18.6 (iPhone 16 / 16e / Pro Max). `frontend.md` § Visual Parity Evidence; artefacts in design/runtime-d2/, tooling design/src/capture-d2.sh, video-d2.swift, timing-d2.py, parity-d2.swift / .sh. Limits (NTLC-D2-3): D2-07 not reachable at runtime; focus ring not injectable; VoiceOver and lifecycle mid-sequence by widget tests only; debug builds only; Android not run. **Accepted by the Tech Lead 2026-09-28** (architecture §20.8): analyze / format clean and app 503 passed re-run at 67d9ecb; seven new negative runs all caught; parity reproduced byte for byte; frame timing reproduced within 1–3 ms except two cells corrected in `frontend.md` (16e row-4 HUD region +1186, not +719, background luma with no chrome visible; 16 retry board / HUD +248, not +265).

- Evidence ID: F03.D2-VISUAL-QA
  * Scenario: An independent final-stage QA verdict on D2 — rubric ≥ 93 from runtime video (every dimension ≥ 8, no fail condition); the §16.11.1 acceptance list; F04 AC1–AC10 on the result, F05 AC1 / AC12, F03 AC8 / AC11; lifecycle mid-sequence; D1 Play regression
  * Required Class: runtime
  * Target / Environment: iOS Simulator 18.6, iPhone 16 / 16e / Pro Max; Android stated as a limit (ANDROID-CI-EVIDENCE)
  * Owner Role: QA
  * Prerequisite / External Decision: F03.D2-PARITY accepted (gate Ready for QA) — met 2026-09-28
  * Re-evaluation Trigger: F03-QA-D2 delivery
  * Blocks: Visual Quality Gate = Passed; F03 Done; D3 activation
  * Result: PENDING
  * Provenance / Note: -

## Open Decision Gates

None

## Blockers

None

## Next Action

Run QA on F03-QA-D2 (Current Brief): independent final-stage visual QA of the D2 won moment, transition and full-screen result at runtime on the three simulators; then hand back to the Tech Lead.

## Last Decision

2026-09-28 (D2 parity checkpoint) — the Tech Lead reconciled F03-FE-D2 (commit 67d9ecb) and accepted it. Full record: architecture §20.8.

**Task coverage.** All ten Current Brief items and the test list are implemented and traced in `frontend.md` §3 / §17: the win sequence, transition, `ResultView`, variants, C1, exits, input / lifecycle, reduced motion, the three design-layer additions and the strings. The legacy won path is deleted. Every F04 AC1–AC10 and F05 AC1 / AC12 keeps a passing test.

**Contract compliance.** Timeline windows equal §20.3 (1) / §16.5 in `win_timeline.dart`. Input is locked to rest; system back is not intercepted. Persistence and controller are untouched. No route was added, and no token or dependency changed.

**Verified independently:**
* suites re-run (analyze, format, app 503 passed);
* seven new negative runs, all caught;
* parity reproduced byte for byte;
* frame timing reproduced within 1–3 ms, with two table cells corrected in `frontend.md`.

**Rulings** (§20.8):
* NTLC-D2-1 (mount at T0 + 450) accepted;
* NTLC-D2-2 (F00 `StatCell` ★ offset, `LimePill` pressed look) accepted as shipped → RESULT-F00-COMPONENT-ALIGN;
* NTLC-D2-3 limits accepted as the Frontend's evidence class — lifecycle mid-sequence, system back, focus ring and VoiceOver are QA runtime scope.

**State:** Delivery Review Accepted; Visual Quality Gate Ready for QA; QA plan final / client-only, modules core + client-ui + visual-quality + stateful-flow, regression full, evidence reuse allowed (fingerprint below); F03-QA-D2 Open; owner → QA.

The pre-checkpoint orchestration (F03-FE-D2 brief, the D2 visual-gate decision) is archived byte-for-byte as history/f03-puzzle-play-session-2026-09-28/orchestration-at-fe-d2-delivery.md.

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-28
* Summary: D2 parity checkpoint — F03-FE-D2 accepted (architecture §20.8); Visual Quality Gate Ready for QA; F03-QA-D2 Open; owner → QA.

## Context & Follow-ups

* **Phase D1 closed 2026-09-28** (Play; §19, closure §19.12). Its Play surface is the transition's starting frame and a regression input.
* **D2 inputs:** DESIGN-ADOPTION-CONTRACT-AMENDMENTS (D2 items, applied in §20); OPTIONAL-QUALITY-NOTES (the 30 ms stagger, text-scale density — both now in §20.3); NTLC-6 / A-2 result at AX5.
* **Logged at the D2 parity checkpoint:** RESULT-F00-COMPONENT-ALIGN (NTLC-D2-2).
* **Still open, outside D2:** F03-MULTITOUCH-FIRST-POINTER; MOVESCARD-COUNTER-LINE-HEIGHT; ANDROID-CI-EVIDENCE.
* **Design Adoption Route:** workflow-follow-ups.md.
* **Audit:** features/f00-design-foundation/conformance-audit.md.

## History & Evidence References

* [QA report](qa.md) (D1R, 2026-09-28), [contract](architecture.md) (§12, §18, §19, §20), [UI design](ui-design.md) (§1–§14 D1; §16 D2), [frontend delivery](frontend.md) (D2).
* [Orchestration at the F03-FE-D2 delivery](../../history/f03-puzzle-play-session-2026-09-28/orchestration-at-fe-d2-delivery.md); [orchestration at the F03-UI-D2 delivery](../../history/f03-puzzle-play-session-2026-09-28/orchestration-at-ui-d2-delivery.md); [ui-design.md before D2](../../history/f03-puzzle-play-session-2026-09-28/ui-design-before-phase-d2.md); [frontend.md before D2](../../history/f03-puzzle-play-session-2026-09-28/frontend-before-phase-d2.md).
* [Terminal D1 orchestration](../../history/f03-puzzle-play-session-2026-09-28/orchestration-before-phase-d2.md); the D1 working record in [history/f03-puzzle-play-session-2026-09-27/](../../history/f03-puzzle-play-session-2026-09-27/README.md); the [closure record of 2026-09-21](../../history/f03-closure-2026-09-21/orchestration.md) — historical only, not a run queue.
* [Portfolio follow-ups](../../workflow-follow-ups.md); [Phase C audit](../f00-design-foundation/conformance-audit.md).
* Canonical execution: role-execution-contract.md.

## Change Log

* 2026-09-18 to 2026-09-21 — migration, win-sequence rework, final QA, closure (behaviour / accessibility); full log in the closure record.
* 2026-09-27 to 2026-09-28 — Design Adoption Phase D1 (Loop Glass Play): reopened, handoff, delivery, QA Rejected, rework, re-QA Approved with Notes, gate Passed, **Done** (architecture §19; log in the archived terminal orchestration).
* 2026-09-28 — Tech Lead: D2 activation (architecture §20; Visual Scope `motion-critical`); F03-UI-D2 Open.
* 2026-09-28 — UI Designer: F03-UI-D2 delivered; F03.D2-HANDOFF PASS; owner → Tech Lead.
* 2026-09-28 — Tech Lead: D2 visual-gate checkpoint — handoff accepted; gate Ready for Implementation; §20.7 rulings (retry A) and corrections C1–C3; F03-FE-D2 Open.
* 2026-09-28 — Frontend/Mobile Developer: F03-FE-D2 delivered (67d9ecb); F03.D2-PARITY PASS; NTLC-D2-1 … 3; owner → Tech Lead.
* 2026-09-28 — Tech Lead: D2 parity checkpoint.
  * **Verified:** suites (503 passed); 7 / 7 new negative runs caught; parity byte-identical; frame timing within 1–3 ms (two cells corrected in `frontend.md`).
  * **Decided:** Delivery Review Accepted; Visual Quality Gate Ready for QA; architecture §20.8 rulings; RESULT-F00-COMPONENT-ALIGN logged.
  * **Next:** F03-QA-D2 Open; owner → QA.

## Current Brief

**F03-QA-D2 — independent final-stage visual QA of the D2 won moment, board → result transition and full-screen result** (contract: architecture.md §20; rulings §20.7 and §20.8)

**Surface under test:**
* `/play` in `won` — the win sequence on the D1 board, including locked / frozen tiles in the winning row (C-11);
* the board → result transition and its reduced path;
* the full-screen result in every F04 variant, including level 30 and Next not wired;
* its exits — Retry (transition A and the reduced dip), Next, the back button, system back / edge swipe.

Cross-feature: the F04 result content (F04 §7 / §8 as amended) and F05 AC1 / AC12. Delivery: `frontend.md` (commit `67d9ecb`); evidence in `design/runtime-d2/`.

**Authority:**
* `ui-design.md` §16 — the **§16.11.1 acceptance list** (items 1–18), the §16.5 motion tables, the §16.6 layout table, the §16.8 variant table, the §16.12a matrix;
* the renders `design/D2-*` and the prototypes `design/src/D2-motion-prototype(-row0|-row4|-frozen|-retry).html` (`?rm=1`, `?t=<ms>`);
* architecture §20.3 with the §20.7 rulings and corrections. **C1:** the stars and `HARİKA` never wait for the rating read; only `EN İYİ` / `YENİ EN İYİ` do. **C2:** the row bound before 600 is its displacement from its own board cell. **C3:** the reduced win path is a contracted cross-fade;
* the §20.8 rulings;
* F04 PRD AC1–AC10; F05 PRD AC1 / AC12; F03 PRD AC8 / AC11; F00 `ui-design.md` (tokens, components);
* `design/visual-quality-gate.md`, `premium-ui-rubric.md`, `design-doctrine.md`.

**QA plan:**
* QA Scope client-only; QA Stage final; Release Scope none.
* QA Modules: core, client-ui, visual-quality, stateful-flow.
* **Regression Depth full**, because:
  * the whole won path was replaced;
  * the F04 result and the F05 Next / unlock paths are cross-feature;
  * shared design-layer components changed (`TileFace`, `StarRow`, new `ScrollBand`);
  * `play_session_screen.dart`, the Play host, was rewritten.
* **Evidence Reuse allowed**, fingerprint `app/` tree `f5641d2f9b84d6597f1c86897a54027e9b1483a2` at `67d9ecb`:
  * the Frontend's and the Tech Lead's automated runs (analyze, format, app 503 passed) and the Frontend's `integration_test` 13 / 13 may be reused only if the QA revision's `app/` tree hash is unchanged;
  * the D1 Play evidence (F03.D1-EVIDENCE) may be reused only for Play states the D2 diff leaves unchanged — the non-`won` frames. `play_session_screen.dart` and `puzzle_board.dart` changed, so re-check at least one D1 journey at runtime;
  * the Frontend's runtime captures and the Tech Lead's re-measurements are comparison inputs, never a substitute for QA's own runtime scoring.

**Critical journeys** (start → action → visible result) on the iPhone 16 (primary), with the 16e and Pro Max where noted:
1. **Row 2, L5** (`c0+ c1+ c1+`, Perfect in 3), Reduce Motion off:
   * record the win → rest → stars;
   * nothing outside the board before T0 + 600, and the row still on its cells (C2);
   * the chrome gone by 720;
   * the row glides as one unit and morphs onto the slot;
   * rest ≤ 940; stars pop and are done by 1300 (§16.11.1 (1), (3)–(5)).
2. **Row 0, L26** (locked T and R in the winning row): the locked tiles turn lime with their neighbours; the lock icons are gone by T0 + 210 (C-11, §16.11.1 (2)). Capture the early fill frames — the Frontend's cold run lost them.
3. **Row 4, L4** (`c0+ c3- r3+ c4+`, the longest glide) on the iPhone 16 **and the 16e**: no visible frame drops (§16.11.1 (18), §20.3 (11)).
4. **Variants** (§16.8, §16.11.1 (8)–(11)), each against its `D2-0x` render:
   * Perfect first clear; Perfect + new best (`HARİKA` wins); new best 2★ (`YENİ EN İYİ`, Retry primary); first clear 2★; matched best; 1★ no improvement;
   * Next not wired (debug L01) — Retry primary, "Sonraki bölüm · yakında" disabled;
   * level 30 Perfect and 2★ — "Yolculuğu tamamla";
   * on each: the badge row reserved, the headline on two lines, one glow, and F04 AC7 content (word, moves, optimal, stars, best, Retry, Next).
5. **Retry** from a 2★ result: the row flies into the rail, and Play is on the restarted grid at rest by 360 (≤ 400) with `HAMLE 0`, undo disabled and 3 dots. A second solve → matched or new best as appropriate (§16.11.1 (13), AC7).
6. **Next:**
   * "Sonraki bölüm" → N+1 (F05 `pushReplacement`), and N+1 is unlocked (F05 AC1);
   * "Yolculuğu tamamla" on level 30 → the terminal Home `TAMAMLANDI 30 / 30` (F05 AC12);
   * there is no Close anywhere (§16.11.1 (14)).
7. **Back:** the result's back button at rest → Home; system back / edge swipe **at ≈ T0 + 300** (mid-sequence) → Home, and then CONTINUE / the Journey shows the level completed and the next unlocked (§20.3 (2), F05 AC1).
8. **Lifecycle mid-sequence** (§16.11.1 (16)):
   * background at ≈ T0 + 300, then resume → the result at rest (stars complete), no replay, no stuck lock;
   * kill at ≈ T0 + 300, then relaunch → Home with no active session; best and unlock written.
9. **Reduce Motion ON** (§16.11.1 (6)):
   * the win: row lime and static at T0; hold to 300; cross-fade 300–460 (C3); content 460–660; stars static; rest ≈ 660;
   * the retry dip: rest ≈ 160.
   * Also check with Reduce Motion OFF.
10. **D1 Play regression** (non-`won`), at least on the iPhone 16:
    * idle L5; a row and a column drag with the settle;
    * a thaw (L23) and the F05 tutorial on L4–6 (pill, ghost);
    * undo / restart;
    * leave and resume.

**Misuse, invalid entry, stale state:**
* taps on the board, back, pill or link before rest → dropped, not queued (§16.11.1 (7));
* a board drag during the retry transition → dropped; after rest it plays;
* a double tap on Retry or Next → one action only;
* a solve with the F05 tutorial visible (L4–6) → it dims and fades with the chrome and is not visible or ticking behind the result;
* Retry and re-solve → the unlock is idempotent;
* restoring straight into `won` (e.g. killed after rest, before leaving) → the result at rest with no replay, if reachable.

**Text scale and accessibility** (§16.11.1 (12), (15)):
* OS text large → the 1.3× cap: no scroll on the three devices;
* AX5: the column scrolls, the back button stays fixed and reachable, the scroll band appears only when scrolled, nothing clips / overlaps / breaks mid-word, and the transition lands at offset 0;
* targets ≥ 44 pt (back, pill, link); contrast per §16.5;
* VoiceOver: order back → badge → headline → subtitle → "Cevap: …" → stars "N / 3 yıldız…" → stats → primary → link; the disabled link read "Sonraki bölüm, yakında"; nothing announced or focusable during the sequence. Check it at runtime if VoiceOver can be driven; otherwise a stated limit on the widget-test semantics (§20.8 (3));
* focus ring on back / pill / link: at runtime if hardware keys can be sent; otherwise the §19.9 (4) evidence class.

**Known deviations and limits.** These are not F03-FE-D2 defects unless QA's evidence says otherwise, and QA may raise any of them as a finding or score them:
* the `EN İYİ` ★ sits 4.3–6.0 pt above the render's superscript, and the pressed pill has no −5 % brightness (F00 components; §20.8 (2), RESULT-F00-COMPONENT-ALIGN);
* the D2-04 / D2-06 captures use 5 / 7 moves;
* D2-07 (no-optimal) is not reachable at runtime — widget-tested;
* debug builds only; Android not run (ANDROID-CI-EVIDENCE); physical-finger feel;
* Home in the legacy look (D3, hybrid period C-8);
* the red CI format step on the F00 QA probe (CI-FORMAT-GATE).

**Startup impact:** none — no entry point, bootstrap, persistence-open or root-navigation change. The kill mid-sequence → relaunch in journey 8 covers the one startup-adjacent path.

**Runtime method:**
* debug build on iOS Simulator 18.6 — iPhone 16 `D0011CE7`, 16e `6DBDFD97`, Pro Max `02FDE776`. The 16 has no app installed after the Frontend's `integration_test` run: `flutter build ios --simulator --debug` and `simctl install` first;
* `design/src/capture-d2.sh seed` (wraps `seed-sim.sh`, optional `personal_best` row) puts Journey level N one move short of its BFS-verified solution; Home CONTINUE opens it; the winning move is a simulator touch-path swipe;
* content size: `xcrun simctl ui <udid> content_size …`;
* Reduce Motion: `capture-d2.sh rm` or `xcrun simctl spawn <udid> defaults write com.apple.Accessibility ReduceMotionEnabled -int 1|0`, then relaunch;
* recordings: `xcrun simctl io … recordVideo`. `design/src/video-d2.swift` and `timing-d2.py` may be used or replaced; state the method;
* restore the simulator settings afterwards.

**Exit criteria (Approved):**
* an independent runtime rubric ≥ 93 from video for the motion, every dimension ≥ 8, no `premium-ui-rubric` fail condition, scored on the D2 surfaces;
* every §16.11.1 item verified at runtime (the focus ring and VoiceOver may rest on their stated evidence classes);
* F04 AC1–AC10, F05 AC1 / AC12 and F03 AC8 / AC11 pass;
* lifecycle mid-sequence, the text sweep and Reduce Motion pass;
* the D1 Play regression passes;
* Android stated as a limit.

On approval, QA sets F03.D2-VISUAL-QA to PASS; the Tech Lead then sets the Visual Quality Gate to Passed and closes D2. Findings are welcome wherever the evidence contradicts this brief.

**Deliver:**
* **`qa.md`** — the final-stage report with the rubric table, runtime evidence records in the gate schema, and findings.
  * Before rewriting it, move the current D1R report byte-for-byte to `history/f03-puzzle-play-session-2026-09-28/qa-at-d1r-verdict.md` and add a README entry.
  * **Why:** `tools/workflow-flow-audit.mjs` reads the first `Final Score` / `Lowest Dimension` in `qa.md` (§19.12 (3)).
* QA evidence in `qa/d2/`.
* The F03.D2-VISUAL-QA record.
* The local orchestration update, per the QA prompt.

## Earlier briefs

* F03-UI-D2 (UI Designer, done 2026-09-28) — archived byte-for-byte in history/f03-puzzle-play-session-2026-09-28/orchestration-at-ui-d2-delivery.md.
* F03-FE-D2 (Frontend/Mobile Developer, done 2026-09-28) — archived byte-for-byte in history/f03-puzzle-play-session-2026-09-28/orchestration-at-fe-d2-delivery.md.
* D1 briefs (F03-UI-D1, F03-FE-D1, F03-QA-D1, F03-FE-D1R, F03-QA-D1R) — archived byte-for-byte in history/f03-puzzle-play-session-2026-09-27/.
