# F00 — design-foundation: Architecture / Scope Contract

> Cross-cutting project track (not a PRD feature). Purpose: give LOOPLET a selected, evidence-backed Design Foundation and bring the shipped surfaces under the Visual Quality Gate. Authority: `project-authority/design-foundation.md` (once Selected), `design/design-doctrine.md`, `design/premium-ui-rubric.md`, `design/visual-quality-gate.md`. Product behaviour, acceptance criteria and game logic are **not** in scope.

## 1. Scope

* **Phase B (this contract's first stage):** a Draft Design Foundation with at least two materially different **rendered** directions on the same critical screens/states, a recommendation, and the impact on shipped surfaces. Status stays `Draft` until a selection authority decides.
* **Later stages (activated by the Tech Lead only after selection):** Phase C conformance audit of shipped surfaces; token / theme / typography / icon implementation as a shared design system; then per-surface conformance as visual rework of F03 / F04 / F05 (each under its own gate).

## 2. Non-goals

No app code in Phase B; no change to grid/engine/persistence/scoring/copy semantics; no new features; no silent global restyle of shipped surfaces; no selection by the UI Designer.

## 3. Surfaces the Foundation must cover (shipped, all Flutter, portrait-locked)

| Surface | States that must be rendered |
| --- | --- |
| Play (F03) | idle board; row lifted mid-drag (AC9: lift, brighter row, dimmed rest, wrap ghost, rail highlight); locked pivot tile; frozen tile + thaw; HUD (HAMLE, undo with quota, restart); back chevron |
| Won moment (F03 §16 + F04 panel) | amber winning row held, then docked above the panel; panel for Perfect (3★, Next Level primary) and non-Perfect (2★, Retry primary); newBest / matched variants; reduce-motion end state |
| Journey home (F05) | 30-tick ring (new / mid / in-progress node / all complete), single CONTINUE CTA, wordmark |
| Column tutorial (F05) | hint text + gesture ghost over the board |

Constraints carried from the shipped product: 5×5 tile grid with wrap-shift, Turkish uppercase content (İ ı Ş Ğ Ç Ö Ü must render correctly), tabular figures for counters, portrait phones 390–440 pt wide, OS text scale up to accessibility sizes, OS Reduce Motion (F03 §16.2 reduced timeline), one glow rule on the won moment, panel ≤ 64 % of screen height.

## 4. Technical constraints (from `platform.md`)

* Flutter/Dart client. Fonts must be bundled assets with an open licence recorded in the Foundation (no network font loading, no default-system-font-as-final). Icons must be a bundled or drawn set (Material default icons are not final assets). Turkish glyph coverage and tabular figures must be demonstrated in the render, not asserted.
* Capture baseline: platform.md §14 (iOS Simulator 18.6 iPhone 16 393×852 primary, 16e 390×844, 16 Pro Max 440×956). Android capture is Pending and must be stated as a limit.
* The shipped look (dark stage, cream tiles, amber resolution, cyan drag energy — see `app/lib/play/play_theme.dart`) is **input**, not authority: one direction may evolve it, but every direction is judged against the rubric on its merits.

## 5. Evidence rules

`direction-render` records (real artefact files: PNG / PDF / HTML rendered to image / equivalent) in a Visual Evidence Manifest; per-direction rubric self-review is provisional (independent QA scores later); motion language documented with reduced-motion behaviour; no Selected status without `Selected By` and a decision reference.

## 6. Lifecycle

`UI Designer (Draft + directions + recommendation)` → **Tech Lead** (records the selection decision gate) → **User / Product Owner selects** (or explicitly delegates) → Tech Lead sets `Selected` and plans Phase C. Selection is never inferred.
