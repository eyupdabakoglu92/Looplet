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

Pending

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

## Open Decision Gates

None

## Blockers

None

## Next Action

Tech Lead: review the F00-UI-DIRECTION-C delivery (design-foundation.md §17, design/parity-*.png, design/sheet-C.png, design/compare-C-*.png) and record it; ask the user to CONFIRM Direction C (selection decision F00.FOUNDATION-SELECTION) with the seven confirmations in §17.9 (direction; lifted-row accent resolved vs lime-literal; completion sheet vs full-screen; completion semantics; which non-shipped Home/Play content is wanted; lowercase wordmark; reference copy as proposed copy). Decide the contract questions in §17.11 before any Phase D task (F03 §16.3 dock location, completion composition, semantics, one-glow rule). Visual Quality Gate stays Pending; nothing visual is implemented before Status: Selected.

## Last Decision

2026-09-21 — Tech Lead opened F00 as the carrier of the Design Adoption Route (workflow-follow-ups.md) after F03 closed Done: the UI Designer prompt requires a feature orchestration to work in, and the Foundation is cross-cutting. F00 is not a PRD feature and carries no product criteria. Selection authority stays with the user / Product Owner (or an explicit delegation); nothing here selects a direction.

2026-09-21 (incident) — The user rejected BOTH rendered directions (A Backlit Stage, B Gazette): "neither is modern; not the style I expect" — and supplied three reference screens (Home, Play, Completion) as the expected style. Tech Lead decisions: (1) A and B are recorded as rejected by the selection authority; their renders stay as the explored alternatives in the Foundation (the exploration gate — two rendered, materially different directions — was met by them; C makes three rendered). (2) The user's screens are treated as a canonical-reference for VISUAL LANGUAGE (palette, type feel, radii, glass surfaces, icon style, tone, composition). Content in those screens that is not in the shipped product is NOT treated as a requirement: it is flagged as a proposal with an owner (see Current UI Brief, Content deltas) — the user may override this interpretation. (3) Direction C is rendered and confirmed by the user before it can be Selected; the recommendation is C. (4) Process lesson: the first exploration did not collect the user's aesthetic references before rendering; future direction rounds start from user references when they exist. No app, contract or product file changed.

## Last Update

* Updated By: UI Designer
* Timestamp: 2026-09-21
* Summary: F00-UI-DIRECTION-C delivered (Direction C rendered from the user's references, parity comparisons, §17); F00.DIRECTION-C-RENDERS and F00.REFERENCE-PARITY PASS; Delivery Review Pending; owner Tech Lead. Nothing selected.

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

## Current UI Brief (F00-UI-DIRECTION-C — activated 2026-09-21; DELIVERED, see design-foundation.md §17)

Read: the three user-supplied reference screens in `features/f00-design-foundation/design/reference/` (`user-ref-1-home.png` Home, `user-ref-2-play.webp` Play, `user-ref-3-completion.webp` Completion; 716×1434 = 2× a 358×717 frame), this orchestration, `architecture.md`, `project-authority/design-foundation.md` (A/B sections and §14), `design/design-doctrine.md`, `design/premium-ui-rubric.md`, `design/visual-quality-gate.md`, the shipped tokens in `app/lib/play/play_theme.dart` and F03 §16 / F04 / F05 ui-design for contracts.

**What happened:** the user rejected A and B as not modern and supplied these screens as the style they expect. This is now the design source. Reproduce its visual language faithfully; do not "improve" it back toward A or B.

**Visual language to carry (measured from the screens, not guessed):** very deep navy ground `#050A1E → #0D132D` with a soft lighter top-right glow (`≈ #2D365C`); frosted / glass rounded cards (`≈ #2A345A`, large radius ≈ 28–32 pt, 1 px light edge, soft light spill); one **lime** accent (`≈ #D0EF58 → #E4FA87`, ink text on it) for the emphasised word, primary CTA, resolution and the active row; **periwinkle** secondary (`≈ #A8B4F9`) for the current node / secondary emphasis; warm cream tiles (`≈ #FCF7F0`) with a large radius (≈ 28 % of tile); dark bordered target tiles; pill buttons; thin rounded **outline** icons (sliders, flame, sparkle, star, undo, restart); a modern grotesque for headings (the emphasised word coloured lime) and a tabular/mono-feeling face for tile letters; friendly sentence-case Turkish microcopy; lowercase wordmark `looplet` with `let` in lime; generous spacing; a curved journey track with numbered nodes on the home card. Identify the closest **OFL** faces (confirm İ ı Ş Ğ Ç Ö Ü, tabular figures, licence, app-size cost) — do not assume the reference's fonts; say "not identified" if you cannot.

**Deliver (same evidence discipline as before):**
1. **Direction C** rendered on the same states as A/B at 393×852 — Play idle; row lifted (AC9); locked pivots + frozen tiles; Won Perfect (docked row + F04 panel) and 2★; Journey home in progress; column tutorial; three won-moment stills — plus 16e and Pro Max variants of Play idle and Won Perfect, a Turkish glyph / tabular / computed-contrast specimen, and composites. Store under `design/`, record each as `direction-render` in the manifest.
2. **Reference parity (`F00.REFERENCE-PARITY`):** for the three reference screens, a side-by-side of the reference and your render on the reference frame, recorded as `parity-comparison`; list every deviation and why (contrast fixes, contract conflicts, shipped-content substitutions).
3. **Update `design-foundation.md`:** add Direction C (thesis, system, motif, motion language incl. reduced-motion, accessibility, impact list), record A and B as **rejected by the user on 2026-09-21** in §6, recommend C, keep Status **Draft** (the user confirms the C render; you never write Selected), refresh the manifest and the provisional self-review (honest; motion/fidelity dimensions stay capped without a prototype).

**Content deltas — visual language is adopted; new product content is a PROPOSAL, not a requirement.** For each row give a "Content delta" table entry (reference element → shipped equivalent → contract/AC affected → proposed handling → decision owner) and render only what is marked:

| Ref | Element in the user's screen | Shipped / contract | Default handling |
| --- | --- | --- | --- |
| H1 | lowercase wordmark `looplet` | uppercase `LOOPLET` | adopt (brand decision flagged to the user) |
| H2 | settings icon button (top right of Home) | no Settings until F10 | render as a labelled proposal; not required |
| H3 | Home card: "YOLCULUK · 4 / 30", headline "Sıradaki döngüyü çöz.", curved numbered journey track | F05 = 30-tick ring + count | render the new composition; flag F05 layout change |
| H4 | level info card "Seviye 5 / Yeni mekanik · sütun kaydırma" with target preview | no per-level info / mechanic note in F05 | render as a proposal; flag content-metadata need |
| H5 | CTA "5. bölüme devam ↗" | `DEVAM ET` + "Seviye N · sürüyor" | adopt style; copy flagged to PO/localization |
| H6 | chips "4 günlük seri" and "12 yıldız" | daily streak = F07 (not started); no total-stars aggregate | render as proposals clearly labelled; not required |
| P1 | top bar "‹ SEVİYE 05" + moves card "2 HAMLE" top-right | HUD bottom-left; back chevron | adopt as a layout proposal (F03 layout is UI-owned); keep AC and touch targets |
| P2 | caption "HEDEF DÖNGÜ" | `HEDEF` | copy flagged |
| P3 | permanent hint "Satırı tut · kaydır · bırak" | none (onboarding is F09) | proposal |
| P4 | lime = the active/lifted row | F03: amber = resolution, cyan = drag | **resolve the semantic collision** (one accent doing two jobs) and keep non-colour cues; justify |
| C1 | full-screen completion, no board | F03 §16: docked row + sheet over the dimmed board (contract) | render the contract-conforming composition as primary; render the reference composition as an alternative and flag the contract change |
| C2 | badge "YENİ EN İYİ", headline "Döngü tamamlandı.", sub "Hedef tek hamlede yerine oturdu." | `YENİ REKOR`, `ÇÖZÜLDÜ` + word | copy flagged to PO/localization; final TR copy is not decided here |
| C3 | stats "SEN 1 = OPTİMAL +3 YILDIZ", three **outlined** stars | `SEN / OPTİMAL / EN İYİ`; earned stars filled (F04 ACs: personal best) | render the shipped semantics as primary and the reference semantics as a marked variant; **earned stars must read as earned** (the reference shows all outlines) |
| C4 | CTAs "Sonraki bölüm →", "Tekrar oyna"; no Close | `SONRAKİ` / `Yeniden` / `Kapat` (Close is an F04 AC) | keep a Close path or flag the AC change |

**Constraints that do not move:** F03 §16 timeline and reduced-motion path; 5×5 wrap-shift interaction and contracts; F04/F05 ACs; ≥ 44 pt targets; no colour-only state (locked / frozen / winning / earned-star / active row); body text ≥ 4.5 : 1 (measure the muted labels — the reference's grey-blue small caps are the likely weak spot; fix and log it as a deviation); bundled OFL font(s) and a bundled/drawn icon set with licences recorded (a permissively licensed open icon set is acceptable if its licence is recorded); Turkish casing rule.

Non-goals: no app code; no product decision; no selection; do not copy a third party's brand assets — the reference is the user's own supplied direction, render your own original artefacts in that language. Return to the Tech Lead (checkpoint) with `Next Role` = Tech Lead.
