# F03 — puzzle-play-session: Orchestration

## Feature ID

F03

## Current Status

Rework

## Current Owner

Frontend/Mobile Developer

## Next Role

Frontend/Mobile Developer

## Active Task Ledger

- [x] Task ID: F03-UI-D1 | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-27 — ui-design.md §1–§14 rewritten for the Loop Glass Play surface; §16 won composition kept byte-for-byte (legacy until D2). 28 renders under design/: the audit's D1 missing states 1–10, plus idle (D1 corrections), loading, keyboard focus, 16e / Pro Max variants, the 1.3× text cap and motion stills. Executable motion prototype design/src/D1-motion-prototype.html (lift + settle, thaw, tutorial ghost; ?rm=1, ?t=). Rulings applied: C-5 (hint pill above the HUD, ≥ 4 pt clearance measured on three devices at 1.0× and 1.3×; ghost hides on touch-down), C-9 (1.3× cap), C-10 (180 ms thaw), locked/frozen treatments, copy. D1 acceptance list §11.5; manifest §12b. NTLC §14: the text cap applied to the whole of Play (deviates from the §19.3 (1) hint example), design-layer edits inside D1, and informational items. No code | Depends On: -
- [ ] Task ID: F03-FE-D1 | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: ACTIVATED 2026-09-27 (visual-gate checkpoint passed, gate Ready for Implementation). Implement the D1 handoff (ui-design.md §1–§14, acceptance list §11.5) from app/lib/design, per architecture.md §19 and the §19.8 rulings. Scope: the Play header, rail, board, HUD, special tiles, thaw, loading and load error; the F05 tutorial overlay (cross-feature); the allowed design-layer additions. Drawn icons replace the six Material icons. Tests updated and added. frontend.md Visual Parity Evidence per §19.8 (7). The won moment stays legacy (§16) until D2. See Current Brief | Depends On: F03-UI-D1
- [ ] Task ID: F03-QA-D1 | Assigned Role: QA | Status: Queued | Summary: Final-stage independent visual QA of D1 (architecture.md §19.7): runtime rubric ≥ 93 with every dimension ≥ 8 and no fail condition; regression of AC1–AC11 and F05 AC4/AC11; text-scale sweep to AX5; Reduce Motion; Android stated as a limit | Depends On: F03-FE-D1

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

Ready for Implementation

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

The artefacts are in features/f03-puzzle-play-session/design/. The Tech Lead verified them at the 2026-09-27 checkpoint (Ready for Implementation). The parity and QA records are pending (see Pending Evidence).

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

Run Frontend/Mobile Developer on F03-FE-D1 (Current Brief below; architecture.md §19 and the §19.8 rulings; ui-design.md §11.5 acceptance list).

Then return to the Tech Lead. That checkpoint is mandatory: the Tech Lead verifies the Visual Parity Evidence and sets Ready for QA before F03-QA-D1 starts.

## Last Decision

2026-09-27 (D1 visual-gate checkpoint) — the Tech Lead reconciled F03-UI-D1 (commit 4223c55) and accepted it.

**Task coverage.** Every Deliver item is present:
* ui-design.md §1–§14 with the handoff-gate items:
  * the §12a matrix;
  * component, typography, colour, asset and interaction decisions (§5–§8);
  * the motion spec with its reduced paths (§5);
  * the §12b manifest, with the selected sources S-01b / S-02 / S-03 / S-07 and the D1 records;
  * the selection record (§2).
* The ten missing renders D1-01…D1-10, plus D1-00, D1-11, D1-12, the device variants and the motion stills.
* The acceptance list (§11.5); §16 kept.

**Evidence, checked independently:**
* The committed generator reproduces all 32 generated HTML / job files byte for byte, so every PNG traces to committed source.
* Every manifest path exists (28 PNG files).
* §16 is byte-identical to the pre-D1 file (7239492, lines 395–497).
* The delivery commit touches only F03 docs and design files — no `app/` file.
* A pixel scan of the tightest case (16e at the 1.3× cap) measures 4.5 pt / 4.0 pt of hint clearance. The handoff computed 5.1 pt without the 1 px border; this is corrected in ui-design §6.

**Contract compliance:** the §19.3 rulings are applied (C-5, C-9, C-10, tile treatments, copy, hybrid period), and the §19.6 non-goals are respected (the won moment is untouched, no F09 hint line, no new direction).

**Rulings** (architecture §19.8):
* the text cap covers all Play text, and §19.3 (1) is amended;
* design-layer edits are in D1 scope, with tests and no token or dependency change;
* the hint-pill padding fallback is pre-agreed;
* the consumed dot stays at 25 %;
* non-Journey sources show the chevron only in the header;
* the interim copy ships as proposed;
* Frontend's evidence expectations are listed.

**Informational:** the Tech Lead verified and extended the UI Designer's frozen-row observation. With the provisional dictionary, the frozen rows of L26, L27, L28 and L30 can never thaw; those of L21–L25 and L29 can. This is logged in workflow-follow-ups (content), outside F03.

**State:** Delivery Review Accepted; Visual Quality Gate Ready for Implementation; F03-FE-D1 Open; owner → Frontend/Mobile Developer.

The earlier decision (the 2026-09-27 reopen) and the UI Designer brief are archived byte-for-byte in history/f03-puzzle-play-session-2026-09-27/orchestration-at-ui-d1-delivery.md. The pre-reopen terminal state is in orchestration-before-phase-d1.md.

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-27
* Summary: D1 visual-gate checkpoint — F03-UI-D1 accepted; Visual Quality Gate Ready for Implementation; architecture §19.8 rulings; F03-FE-D1 activated for the Frontend/Mobile Developer.

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
* 2026-09-27 — Tech Lead: D1 visual-gate checkpoint.
  * **Verified:** F03-UI-D1 reconciled — HTML regenerates byte-identical, manifest paths exist, §16 identical, hint clearance measured at 4.5 / 4.0 pt.
  * **Decided:** Delivery Review Accepted; Visual Quality Gate Ready for Implementation; architecture §19.8 rulings.
  * **Next:** F03-FE-D1 Open; owner → Frontend/Mobile Developer.

## Current Brief

**F03-FE-D1 — implement the Loop Glass Play (Design Adoption Phase D1; contract: architecture.md §19, rulings §19.8)**

**User-visible symptom** (architecture §19.1): Play still shows the old look, with four shipped defects:
* **A-1:** the tutorial hint overlaps the HUD;
* **A-2:** glyphs overflow at AX5;
* **A-5:** the frozen tile has no real cue and no thaw;
* **A-6:** the tutorial ghost plays under the finger.

**Affected journey and entry paths** (§19.2):
* every non-`won` Play state, reached from Home CONTINUE, Result Next / Retry, a resume after a kill, or the debug chips;
* the F05 column tutorial (levels 4–6, until acknowledged);
* loading and the load error.

Routes, gestures, persistence and timings stay unchanged.

**Authority:**
* `ui-design.md` §1–§14 — the D1 handoff: the §11.4 implementation map, the §11.5 acceptance list and the §12a matrix;
* the renders in `design/` (D1-*) and the F00 selected sources (S-01b, S-02, S-03, S-07, S-91, S-v-*);
* the motion prototype `design/src/D1-motion-prototype.html` (`?demo=lift|thaw|ghost`, `?rm=1`, `?t=<ms>`);
* F00 `ui-design.md` (tokens, components);
* architecture §19 and §19.8.

**Fix scope:**
1. **Play screen** (`play_session_screen.dart`, `play/widgets/*`):
   * ground: `LoopBackdrop`;
   * header: the drawn back chevron plus `SEVİYE NN`, bound to `journeyLevel`, as one ≥ 44-pt control (chevron alone when there is no level number); `MovesCard` top-right;
   * goal: `HEDEF DÖNGÜ` plus the `RailTile`s;
   * board: `BoardCard`, with `TileFace` for every non-`won` tile state;
   * dragging: active-line rails, the wrap ghost at 30 % → 100 % on the settle, inactive tiles at 42 %;
   * thaw: a 180 ms cross-fade;
   * HUD: `UndoPill` with quota dots, and `GlassIconButton(LoopIcon.restart)` at 44 pt;
   * loading: the skeleton at the final geometry;
   * load error: the error card, and `LimePill('Ana ekrana dön', icon: null)` → `/`.
2. **Tutorial overlay** (`journey/column_tutorial_overlay.dart`, cross-feature):
   * the hint pill is centred between the board and the HUD, with ≥ 4 pt of clearance (fallback §19.8 (3));
   * a ghost ring with `LoopIcon.upDown`; it hides on touch-down and returns after 600 ms of idle;
   * the pill fades out on the first column move that settles;
   * F05 ack and re-show are unchanged (AC4, AC11).
3. **Design layer** (`app/lib/design`, §19.8 (2)), each with component tests:
   * the glyph cap on `TileFace` and `RailTile`;
   * the pressed fill on glass controls;
   * `LoopIcon.loopBreak`;
   * the rails, ghost-ring, hint-pill and skeleton-cell widgets.
4. **Motion** per the `ui-design.md` §5 table, including every reduced-motion path (`reduceMotionRequested()`).
5. **Strings** (`PlayStrings`): `HEDEF DÖNGÜ`, `SEVİYE %02d`, `Bu bulmaca yüklenemedi.`, `Ana ekrana dön`. **Semantics** per `ui-design.md` §11.4.
6. **Icons:** replace the six Material icons with drawn `LoopIcon`s; none may remain in the app:
   * `chevron_left_rounded`, `undo_rounded`, `refresh_rounded`;
   * `push_pin`, `unfold_more_rounded`, `error_outline_rounded`.
7. **Won moment:** from T0 onward it stays exactly as shipped (§16: amber row, seam, dock, F04 panel). Keep `BoardTile(winning)`, `docked_row.dart` and `PlayTheme` for the `won` phase only.

**Tests:**
* **Update** the F03 / F05 tests that look up `HEDEF`, `Icons.*` or `PlayTheme` values.
* **Add tests for:**
  * the glyph cap — no overflow at text scale 3.12 on a 390-pt width;
  * the tutorial pill rect against the board and HUD rects, at 1.0× and 1.3×, on 390×844 / 393×852 / 440×956;
  * the thaw timing — 180 ms, instant under Reduce Motion;
  * the undo quota rendering and semantics;
  * the header label binding, and back → `/`;
  * the load-error pill → `/`;
  * the board rect unchanged from loading to loaded.
* **Suites:** `melos run analyze`, `dart format --set-exit-if-changed` and `melos run test` green; `flutter test integration_test` on the iPhone 16 simulator green (the existing device suite).

**Evidence** — `frontend.md` § Visual Parity Evidence, in the gate schema (§19.8 (7)):
* **`runtime-screenshot`:** one per `ui-design.md` §12a row on the iPhone 16, plus 16e and Pro Max for idle, the tutorial and the column drag;
* **`parity-comparison`:** composites against `D1-*` / `S-*`, with a deviation list (±2 pt, ΔE 3);
* **`runtime-video`:** a screen recording (`xcrun simctl io … recordVideo`) of a row lift, a column lift, a thaw (e.g. Journey L23 after `r1+ c3+ c4- c4-`) and the tutorial ghost hiding and returning;
* **`accessibility`:** OS text at default / xxxLarge / AX5, and Reduce Motion on and off.

Record the revision, device, time and owner for each. State Android as a limit.

**Non-goals:**
* the won moment and full-screen result (D2);
* Home, the app shell and the F08 error screen (D3);
* the F09 gesture hint;
* token changes and new dependencies;
* any engine, gesture, persistence, route or timing change.

**Exit:** F03-FE-D1 Done with `frontend.md`; F03.D1-PARITY PASS with provenance; Delivery Review = Pending. Hand back to the Tech Lead (mandatory checkpoint → Ready for QA) before F03-QA-D1. Any deviation beyond §19.8 (3) goes to Needs Tech Lead Clarification.

## Earlier briefs

* F03-UI-D1 (UI Designer, done 2026-09-27) — archived byte-for-byte in history/f03-puzzle-play-session-2026-09-27/orchestration-at-ui-d1-delivery.md.
