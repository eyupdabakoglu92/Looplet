# F00 — design-foundation: Orchestration

## Feature ID

F00

## Current Status

In Progress

## Current Owner

UI Designer

## Next Role

UI Designer

## Active Task Ledger

- [ ] Task ID: F00-UI-FOUNDATION | Assigned Role: UI Designer | Status: Open | Summary: Phase B — draft project-authority/design-foundation.md (Status Draft) with at least two materially different RENDERED directions on the same Play / Won+F04 / Journey-home / tutorial states, Turkish glyph and tabular-figure proof, bundled font + icon plan, motion language incl. reduce-motion, recommendation and shipped-surface impact list; never mark Selected | Depends On: -

## Open Tasks

None

## Handoff Plan

None

## Delivery Review

None

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

None

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
  * Result: PENDING

## Open Decision Gates

None

## Blockers

None

## Next Action

Run UI Designer on F00-UI-FOUNDATION using the Current UI Brief. The delivery returns to the Tech Lead (mandatory checkpoint) who opens the selection decision gate for the user; the UI Designer never marks the Foundation Selected.

## Last Decision

2026-09-21 — Tech Lead opened F00 as the carrier of the Design Adoption Route (workflow-follow-ups.md) after F03 closed Done: the UI Designer prompt requires a feature orchestration to work in, and the Foundation is cross-cutting. F00 is not a PRD feature and carries no product criteria. Selection authority stays with the user / Product Owner (or an explicit delegation); nothing here selects a direction.

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-21
* Summary: F00 created; Phase B task activated for the UI Designer.

## Context & Follow-ups

Why now: the ai-system upgrade (cfd6b59) made an independent visual gate (>= 93 total, every rubric dimension >= 8, rendered evidence) mandatory for visual scope, and the project has no Selected Foundation; shipped visuals use the default system font, Material icons and text-only legacy directions with self-scores only. F05-QA-STRICT and F08 local evidence continue in parallel queue positions (they are Visual Scope none / non-visual); no feature with a visual scope activates before Selected.

## History & Evidence References

* [Scope contract](architecture.md); [Design Adoption Route](../../workflow-follow-ups.md); [platform.md §14](../../project-authority/platform.md).
* Shipped identity for reference: `app/lib/play/play_theme.dart`; surfaces documented in F03 ui-design.md (§5–§8, §16), F04 ui-design.md, F05 ui-design.md.
* Canonical execution: role-execution-contract.md.

## Change Log

* 2026-09-21 — Tech Lead: F00 created; F00-UI-FOUNDATION activated.

## Current UI Brief

Task F00-UI-FOUNDATION (Phase B). Read: this orchestration, `architecture.md` (scope contract, surfaces, constraints), `templates/project-design-foundation.template.md`, `design/design-doctrine.md`, `design/premium-ui-rubric.md`, `design/visual-quality-gate.md`, `project-authority/platform.md` §14, the shipped tokens in `app/lib/play/play_theme.dart`, and the shipped surfaces' state definitions in F03 `ui-design.md` (§5–§8, §16), F04 `ui-design.md`, F05 `ui-design.md`. You may look at the running app (iOS Simulator, debug build) to see the current look; treat it as input, not authority.

Deliver:
1. `project-authority/design-foundation.md` from the template, **Status: Draft**, `Selected At / Selected By / Decision Reference: Pending`. Never write Selected.
2. **At least two materially different rendered directions** (not palette / radius / shadow variants: differ in typography, tile and surface material, iconography / glyph language, contrast strategy, composition and motion language). One may evolve the shipped identity; another must genuinely challenge it. Do not assume dark + gradient + glow is the premium default. Render the **same** states in every direction: Play idle; row lifted mid-drag (lift, brighter row, dimmed rest, wrap ghost, rail highlight); locked pivot tile; frozen tile; HUD (HAMLE, undo with quota, restart); Won moment with the docked row + F04 panel for Perfect (Next Level primary) and 2★ (Retry primary); Journey home ring with an in-progress node; column-tutorial overlay. Store artefacts under `features/f00-design-foundation/design/` and record each as a `direction-render` in the Visual Evidence Manifest.
3. **Turkish glyph and tabular-figure proof** rendered (İ ı Ş Ğ Ç Ö Ü in uppercase-heavy tile content; HAMLE / progress counters), a **bundled open-licence font plan** (family, weights, licence, size cost) and a **bundled or drawn icon plan** — the default system font and Material icons are not final assets.
4. Per direction: a provisional rubric self-review (10 dimensions, the independent QA scores later), contrast / greyscale legibility, OS text-scale behaviour up to the accessibility sizes, **motion language with the OS Reduce Motion behaviour** (match F03 §16.2's reduced timeline or state a justified change), one-glow rule and panel ≤ 64 % constraint respected or a stated exception.
5. **Recommendation** (one direction, why) — not a selection — plus the **decisions the selection authority must make** and a **shipped-surface impact list** (F03 play + won, F04 panel, F05 home/tutorial: what changes, rough size) as Phase C input.
6. Capture/limits: reference iPhone 16 393×852 frames, 16e / Pro Max variants for the critical states; Android capture Pending stated as a limit.

Non-goals: no app code; no change to product behaviour, ACs, copy semantics or the win-sequence timing contract (a direction may propose a motion-language change, flagged for Tech Lead); no selection. Return to the Tech Lead (checkpoint) with `Next Role` = Tech Lead; update your own Pending Evidence, close F00-UI-FOUNDATION and set Delivery Review = Pending only via the delivery footer rules.
