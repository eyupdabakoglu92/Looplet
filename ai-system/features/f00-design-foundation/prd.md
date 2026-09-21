# F00 — design-foundation: Feature PRD (carrier feature)

> **Not a product-PRD feature.** F00 is derived from no section of `product/product-prd.md`, adds no product requirement, no user story, no acceptance criterion and no success metric, and changes none. Created by the Tech Lead (2026-09-21) because the QA preflight and the feature template expect a `prd.md`; it states only what F00 is and which authorities its acceptance rests on.

---

## 1. Summary

F00 is the workflow carrier of the cross-cutting **Design Adoption Route** (`workflow-follow-ups.md`): the project-level Design Foundation (`project-authority/design-foundation.md`, Selected 2026-09-21, Direction C "Loop Glass"), the design-system handoff (`ui-design.md`) and the shared design-system layer in `app/lib/design/` (`architecture.md` §7). It exists because the independent Visual Quality Gate (`design/visual-quality-gate.md`) needs a selected Foundation and a rendered, runtime-verified design system before any surface can be reworked visually.

Player value is indirect: F03 / F04 / F05 / F08 surfaces will adopt this system in later per-feature visual rework, each with its own contract amendment. F00 itself changes no shipped screen.

---

## 2. Acceptance basis (no product criteria)

F00 is accepted against, in this order:

1. `architecture.md` §7 — the design-system implementation contract (location, coexistence with no shipped-surface change, bundled fonts, drawn icons, components, debug gallery, evidence, non-goals).
2. `ui-design.md` and `project-authority/design-foundation.md` §17–§18 — tokens, component states, accessibility, the selected decision set.
3. `design/visual-quality-gate.md`, `design/design-doctrine.md`, `design/premium-ui-rubric.md` — the independent runtime score (≥ 93 total, every dimension ≥ 8, no fail condition, complete runtime evidence).
4. `project-authority/platform.md` §14 — canonical capture targets (iOS Simulator iPhone 16 393×852; 16e and 16 Pro Max variants), fonts and icons decisions.

---

## 3. Non-goals

* No product behaviour, game logic, persistence, route, content or contract change.
* No restyle of any shipped surface in F00 (per-feature visual rework and its contract amendments are logged in `workflow-follow-ups.md`, `DESIGN-ADOPTION-CONTRACT-AMENDMENTS`).
* No feature content from the user's reference screens that the game does not have yet (settings, streak chip, stars chip, level-info card, gesture hint): kept in the design as future scope only (`USER-REFERENCE-CONTENT-DELTAS`).
