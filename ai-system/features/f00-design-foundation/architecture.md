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

## 7. Design-system implementation contract (added 2026-09-21 at the visual-gate checkpoint)

Authority: `project-authority/design-foundation.md` (Selected) and `features/f00-design-foundation/ui-design.md` (tokens, components, states, motion, manifest). Task: `F00-FE-DESIGN-SYSTEM`.

1. **Location and shape.** A shared layer in `app/lib/design/`: `tokens.dart` (colour roles, gradients, radii, shadows, spacing referenced to the 358-pt reference and scaled by width), `typography.dart` (the type roles), `icons.dart` (the drawn icon set), `wordmark.dart` (`Looplet`), `turkish_case.dart` (locale-correct uppercasing: `i → İ`, `ı → I`), `components/` (below) and a debug-only gallery. Public API only what ui-design.md names.
2. **Coexistence — no shipped surface may change.** `PlayTheme` and every shipped screen (F03 play/won, F04 panel, F05 home/tutorial, F08 recovery) keep their current look in this task; they migrate in per-feature visual rework under `DESIGN-ADOPTION-CONTRACT-AMENDMENTS`. F03/F04/F05 suites, analyzer, format and the device suite stay green and unchanged in behaviour.
3. **Fonts.** Space Grotesk and Manrope variable files + OFL texts under `app/assets/fonts/`, declared in `pubspec.yaml`; no network loading; verify on the simulator: weight axis (500 vs 600 visibly different), tabular figures on numerals, every Turkish capital (`İ I Ş Ğ Ç Ö Ü`) and lowercase (`ı ş ğ ç ö ü`); report the bundle-size cost.
4. **Icons.** Drawn in Dart (`CustomPainter` / `Path`), parity with the S-91 icon row; **no new package** without Tech Lead approval (a dependency is a Needs-Tech-Lead-Clarification, not a silent add).
5. **Components** (state and geometry per ui-design.md §7–§8): glass card (+ slate variant), board card, tile face (normal, active/lifted, winning, locked, frozen, ghost slot, inactive), target-rail tile, primary lime pill (glow variant for Home, neutral-shadow variant for the Result), outline pill and text link (incl. disabled), badge, moves card, undo pill / round button / square button, stat card, loop-track node (done, current), star (earned/empty), `Looplet` wordmark. Any animated piece uses `reduceMotionRequested()`.
6. **Gallery.** `DesignGalleryScreen`, reachable only in debug builds, laid out like `design/S-91-components.png`, used as the runtime capture source for parity.
7. **Evidence.** Automated: token values (hex/gradients), `turkish_case` cases (`HARİKA`, `İLK`, `YENİ EN İYİ`, `OPTİMAL`, `SEVİYE` from their lowercase forms), component state tests, analyzer/format/melos clean. Runtime: gallery screenshots on iPhone 16 (393×852) and the 16e / Pro Max variants, side by side with `S-91-components.png` and per-component crops (`Visual Parity Evidence` in `frontend.md`, kinds `runtime-screenshot` and `parity-comparison`), deviations listed; a Turkish-glyph check screenshot. Startup/cold-boot gate applies only if bootstrap/init changes (it should not).
8. **Non-goals.** No shipped-surface restyle; no game-logic, persistence or contract change; no new feature content (settings, streak, etc.); no motion prototype in Flutter (that is a rework-time task for the Result transition).

## 8. Phase C — conformance audit contract (added 2026-09-27; incident 2026-09-26)

Authority: `project-authority/design-foundation.md` (Selected; §18 decisions and consequences), `features/f00-design-foundation/ui-design.md` (design-system handoff and the board → full-screen result motion spec), the selected-source renders `design/S-*.png`, `workflow-follow-ups.md` (Design Adoption Route; DESIGN-ADOPTION-CONTRACT-AMENDMENTS; USER-REFERENCE-CONTENT-DELTAS). Task: `F00-UI-CONFORMANCE-AUDIT` (UI Designer).

1. **Purpose.** Measure how far every shipped surface is from the Selected Foundation, so the Tech Lead can decide, per feature, the Visual Scope, the reopen order for Phase D and the contract amendments. No design exploration (the Foundation is Selected) and no code.
2. **Surfaces and states** (the shipped app, `lib/main.dart`; debug build on the iPhone 16 simulator — the capture baseline of `platform.md` §14):
   * **F05 Home:** new (0/30), mid (N/30), in-progress (`· sürüyor`), terminal (`TAMAMLANDI` / `TEKRAR OYNA`), plus the app shell's splash and bootstrap-error screen.
   * **F03 Play:** idle, row lifted mid-drag, column drag (levels 4+), locked tile, frozen tile and thaw, HUD (HAMLE, undo quota states, restart), back chevron, target rail, the load-error state.
   * **F03 won moment + F04 completion panel:** the win sequence; 3★ / 2★ / 1★; first clear, new best, matched best; `SONRAKİ` / `Yeniden` / `Kapat`; the reduced-motion path.
   * **F05 column tutorial (levels 4–6).**
3. **Deliverable.** `features/f00-design-foundation/conformance-audit.md`, with evidence under `design/audit/`. For every surface and state:
   * **Pair:** a fresh runtime capture of the current app next to its target render (or "no target render" when none exists).
   * **Gaps:** a gap list by category — layout, typography, colour/surface, iconography, components, copy/casing, motion, accessibility.
   * **Scope proposal:** `existing-parity` / `new-surface` / `motion-critical`, with a reason. The decision stays with the Tech Lead.
   * **Contract impacts:** AC/contract impacts, confirming or extending DESIGN-ADOPTION-CONTRACT-AMENDMENTS — e.g. the full-screen result without `Kapat`, the `Looplet` wordmark, Turkish copy.
   * **Future-scope exclusions:** items visible in the renders that must NOT be built (USER-REFERENCE-CONTENT-DELTAS).
   * **Missing renders:** states Phase D must still render before implementation.

   The document ends with:
   * a proposed Phase D grouping and order, with a rationale (player-visible impact, dependency on `app/lib/design` components, risk);
   * a Screen / State / Viewport matrix;
   * a Visual Evidence Manifest (records of kind `runtime-screenshot` and `parity-comparison`).
4. **Exit.** The Tech Lead can decide Visual Scope, the reopen order and the first Phase D brief from the audit alone.
5. **Non-goals.** No code or asset changes in `app/`. No change to `design-foundation.md` beyond flagging conflicts. No rewrite of the F03/F04/F05 `ui-design.md` (that is Phase D). No new feature content. No Visual Quality Gate change: the audit ships no UI, so F00's gate record stays as is.
6. **Outcome (Tech Lead, 2026-09-27).** `conformance-audit.md` was accepted (commit `cc84440`), and Phase C is complete. The Phase D plan is set in three slices, one reopen at a time:

   | Slice | Carrier | Visual Scope | Scope |
   | --- | --- | --- | --- |
   | D1 — Play | F03 (active now) | `existing-parity` | Play; the F05 column tutorial as a cross-feature item; the F03 load error. Contract: F03 `architecture.md` §19. |
   | D2 — Won moment + full-screen result | F03 | `motion-critical` | The F04 amendments are made in the same reopen. |
   | D3 — Home + app shell | F05 | `new-surface` | Native launch, the splash and the F08 bootstrap-error screen, as cross-feature items. |

   Rulings on the audit's clarifications: C-2, C-5, C-8, C-9 and C-10 are decided in F03 §19. C-3, C-4, C-6, C-7 and C-11 are decided as slice inputs. C-1 (N1) waits for D3, where it needs a product decision. The full list is in `workflow-follow-ups.md` (Design Adoption Route). F00 returns to Done: it carries no Phase D work.
