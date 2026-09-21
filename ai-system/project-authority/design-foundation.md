# Project Design Foundation — LOOPLET

> Status: Draft
>
> Owner: Tech Lead (lifecycle) / UI Designer (design authorship)
>
> Selection Authority: User / Product Owner / explicitly delegated Tech Lead

Last Updated: 2026-09-21
Selected At: Pending
Selected By: Pending
Decision Reference: Pending

> **This file is a Draft. Nothing here is selected. Directions A and B were rejected by the user on 2026-09-21 (see §6); Direction C is being rendered from the user's reference screens.** Two rendered directions (A, B) are compared on identical content; the UI Designer's recommendation (§6) is not a selection. Visual artefacts live in `features/f00-design-foundation/design/` (sources in `design/src/`, regenerate with `node gen.mjs . && sh render.sh && python3 sheets.py`).

---

## 1. Experience Thesis

* **Product promise (from the PRD):** a single-player Turkish word-*logic* puzzle: slide whole rows and columns of a 5×5 grid (wrap-around, one cell per move) until the visible target word forms in one row, in as few moves as possible — a satisfying 2–5 minute portrait, one-handed session with a "do it better" replay loop. It is explicitly not a Wordle-style game.
* **Desired user feeling:** *exact and satisfying* — every slide feels like a small mechanical certainty; the solve lands as a clean click into place, then a fair, legible verdict (stars vs optimal). Calm before the move, crisp during, rewarding at resolution.
* **Three experience adjectives:** exact · tactile · unhurried.
* **The product must never feel:** like a generic mobile-game template (neon-on-dark by default), like a quiz/typing game (no keyboard, no guess feedback), childish, noisy, or dependent on colour or sound to be understood (PRD accessibility need).

## 2. Audience and Context

* **Primary audience:** casual puzzle / word-game players 16+, Turkish-speaking at launch (English pack later); players who like "easy to learn, hard to master" optimisation puzzles and short daily habits.
* **Usage environment:** phone, portrait, one hand, short sessions, all lighting (commute, evening, daylight).
* **Session shape / frequency:** 2–5 minutes; daily habit + replay of solved puzzles to beat a move count.
* **Platform and input constraints:** Flutter, iOS first (canonical capture platform.md §14: iPhone 16 393×852, 16e 390×844, 16 Pro Max 440×956), Android later; touch drag on a 5×5 board; portrait-locked; OS text scale up to accessibility sizes; OS Reduce Motion (F03 §16.2).
* **Accessibility priorities:** never rely on colour alone (locked / frozen / winning / earned-star must have a non-colour cue); ≥ 44 pt targets; body-text contrast ≥ 4.5 : 1; reduced-motion end states already contracted (F03 §16.2, F04 §4, F05 §13).

## 3. Contemporary Reference Set

Reviewed 2026-09-21 in the built-in browser (product web pages / marketing sites, **not** gameplay). NYT Wordle / Games and Puzzmo could not be opened in this environment (site blocked) and are therefore **not** claimed. Principles only; no imitation.

| Reference | Surface Reviewed | Why Relevant | Carry | Avoid | Reviewed At |
| --- | --- | --- | --- | --- | --- |
| Monument Valley series — monumentvalleygame.com | series home: hero art + series navigation | a calm, single-focal-object puzzle brand that owns its atmosphere | one luminous focal object in generous quiet space; tiny wide-tracked uppercase labels as the only chrome | pastel-isometric surface, literal impossible-architecture imagery | 2026-09-21 |
| Threes — asherv.com/threes | landing page with the 1 + 2 = 3 tile demonstration | closest mechanical cousin (sliding tiles); personality without a mascot | tiles as characters through *type and colour role*; light, friendly ground; the smallest possible demo teaches the rule | cartoon faces / childlike palette | 2026-09-21 |
| Balatro — playbalatro.com | landing page: title lockup, playing-card hero | a card/tile game whose objects feel printed and physical | the atomic game object carries a printed index / corner mark; one memorable signature per screen | maximalist swirl, CRT shader, playing-card iconography | 2026-09-21 |

(A fourth candidate, linear.app — disciplined dark UI — was opened but had not finished loading when captured, so it is not counted.)

## 4. Rendered Direction A — "Backlit Stage" (an evolution of the shipped identity)

* **Name / thesis:** the board is the one lit object on a dark stage; resolution is *light closing a loop*. Continuity with what ships today, with the generic parts (system font, Material icons, weak states) replaced.
* **Material difference from Direction B:** dark stage / light tiles; geometric sans (Sora) only; soft-radius keycap tiles (19 % radius) with inner highlight and cast shadow; glow and gradient carry emphasis (amber = resolution, cyan = drag energy, brass = locked); rounded-solid 2.4 px icons; centred, symmetrical stage compositions; motion = *glide and glow*.
* **Strengths:** lowest migration cost (tokens, layout and motion already exist in `play_theme.dart` and F03 §16); board is unmistakably the hero; high contrast; strongest "win moment" glow; consistent with the shipped screens players already saw.
* **Risks:** dark + glow + rounded card is the category's default recipe (Originality is its weakest dimension); glow must stay rationed (one-glow rule) to avoid gamey noise; light-on-dark long-session fatigue; custom wordmark ring needs a final vector asset.
* **Rendered artifacts:** `A-01 … A-10`, `A-v-*`, `A-90-specimen`, `sheet-A` (see §13).

### Direction A — key decisions

| Area | Decision |
| --- | --- |
| Type | Sora (SIL OFL 1.1), one family, variable 100–800. Tile glyph 800 at 46 % of tile, +0.02 em; wordmark 800 +0.34 em; labels 600 11 pt +0.16 em caps; numbers 700 tabular (`tnum` verified). |
| Colour | stage `#0B0C16→#141322` + one radial spotlight `#2A2350`; plate `#0E0F1C`; tile `#F7F2E9→#E4DBCA`, glyph `#1B1A24`; resolution amber `#FFC24B/#FFB020` (ink `#2A1B00`); drag cyan `#5AA9FF`; locked brass `#C9A24B`; frozen frost `#DCE8F2`; muted `#9391AA` (6.4 : 1 on stage); sheet `#191A2B`. |
| Shape / surface | tile radius 19 %; recessed plate; raised dark sheet with a 1 px top highlight; depth is used for hierarchy only (lifted row, docked row, sheet), never decoratively. |
| Icons | drawn, rounded-solid: back chevron, undo, restart, padlock (locked), snowflake (frozen), up/down chevron (tutorial), faceted amber star (earned) / dark star (empty). |
| Signature motif | **the seam** — a luminous amber line that *closes the loop*: under the winning row, as the amber arc in the wordmark's second O, as the filled ticks and node of the home ring. Appears only at resolution / progress moments. |
| Non-colour cues | locked = brass ring **+ padlock**; frozen = frost fill + crystal ring **+ snowflake**; win = amber row **+ drawn seam + docked position**; empty star = dark silhouette. |

## 5. Rendered Direction B — "Gazette" (print, paper and ink)

* **Name / thesis:** a printed puzzle page. The board is a *chase* of type: cream sorts locked into an ink frame on warm newsprint; resolution is *the answer being stamped and ruled off*. It draws on the Turkish newspaper *bulmaca* habit (daily word puzzles on paper) — the cultural home of this exact audience — instead of the game-UI default.
* **Material difference from Direction A:** light paper ground / dark ink chase; a high-contrast serif (Newsreader, optical size 72 for display) only; square, hard-edged sorts (5 px radius) with a flat hard "shelf" edge instead of blur shadows; **no glow, no gradient** — emphasis comes from ink, vermilion and rules; hairline-square-cap 1.7 px icons; left-aligned editorial composition (masthead, datelines, full-width bar CTA); motion = *press and stamp*.
* **Strengths:** the most ownable, least category-default identity; cultural fit for a Turkish word-puzzle habit; excellent daylight legibility and contrast (ink on tile 16.5 : 1); non-colour cues are structural (inverse tile, hatching, rules) rather than tinted; type-led, which should tolerate OS text scaling well (not yet rendered or tested); likely to age well.
* **Risks:** restyles every shipped surface (largest Phase D); a light UI reads "serious/editorial" and must be kept playful through the stamp motion and the misregistration detail; no glow means the win moment relies on motion and the vermilion switch — must be proven in a prototype; paper texture must stay subtle (contrast) and be procedural or a small tiled asset; the wordmark casing changes to "Looplet" (a brand decision).
* **Rendered artifacts:** `B-01 … B-10`, `B-v-*`, `B-90-specimen`, `sheet-B`.

### Direction B — key decisions

| Area | Decision |
| --- | --- |
| Type | Newsreader (SIL OFL 1.1), one family, variable opsz 6–72 × wght 200–800. Tile glyph 800 opsz 72 at 62 % of tile; display words 800; labels 600 opsz 8 caps +0.17 em; default figures are tabular (verified). |
| Colour | paper `#EFE8D8`; ink `#1B1815`; sort `#FBF7EC` (shelf `#D5CBB0`); resolution vermilion `#C7361F`; proof-blue `#2C4C86` (active track / drag); muted ink `#6C6353` (4.9 : 1 on paper); frozen ice `#D9E6EC`. |
| Shape / surface | 4–5 px radii; hard offset "shelf" edges; the ink chase frames the board; a printer's **thick-thin double rule** under the target rail, masthead, sheet top and the winning row; paper fibre texture at ≤ 16 % alpha. |
| Icons | drawn, hairline 1.7 px, square caps, miter joins: arrow-back, undo, restart, padlock, asterisk-snowflake, up/down chevrons; printed vermilion star with a 1.1 px proof-blue **misregistration** offset (earned) / dashed outline (empty). |
| Signature motif | **the rule** — the double rule that draws under the answer, plus the *misregistration* on stamped stars. Used at hierarchy breaks and resolution only; never as a border on every element. |
| Non-colour cues | locked = inverted ink sort **+ padlock**; frozen = diagonal hatching **+ blue ring + asterisk**; win = vermilion row **+ double rule + docked position**; empty star = dashed outline. |

## 6. Selection Record

* **Rejected by the selection authority (user), 2026-09-21: Direction A and Direction B** — "neither is modern; not the style I expect". The user supplied three reference screens (`features/f00-design-foundation/design/reference/`) as the expected style; **Direction C** is being rendered from them (task F00-UI-DIRECTION-C). Recorded by the Tech Lead; the sections below describe A/B as explored alternatives.
* Selected direction: **Pending Selection** (Direction C, once rendered and confirmed by the user)
* Decision maker / delegated authority: **Pending** (user / Product Owner, or an explicit delegation to the Tech Lead)
* Decision reference: **Pending**
* Why this direction fits the product: —
* Rejected direction and reason: —

**UI Designer recommendation (not a selection):** **Direction B — Gazette**, *if* the selection authority accepts a full restyle of the shipped surfaces. Reasons: it is the only direction whose identity comes from this product's audience (the Turkish newspaper bulmaca habit) rather than from the game-UI category default; its non-colour cues are structural, matching the PRD's "playable without colour" need; and it removes the glow-on-dark recipe that Direction A shares with most puzzle games. **Choose Direction A instead if** protecting shipped work and time-to-launch matters more than distinctiveness: it is a refinement of what players have already seen, with a much smaller migration than B (see the size estimate in §15, which is a rough judgement, not a measurement). A hybrid is not recommended (the two materially differ in ground, type, edge language and motion; mixing them reproduces the "isolated visual language" fail condition).

## 7. Brand and Visual System (shared rules; per-direction values in §4 / §5)

### Typography

* **Families / licensing / glyph coverage:** A = Sora, B = Newsreader — both SIL OFL 1.1, downloaded from `github.com/google/fonts` (`ofl/sora`, `ofl/newsreader`), licence texts stored beside the files (`design/src/fonts/OFL-*.txt`). Rendered proof of İ ı Ş Ğ Ç Ö Ü in tile context, uppercase words (ASLAN, ÖZGÜR, ŞİŞE, ÇÖZÜLDÜ) and tabular figures: `A-90-specimen`, `B-90-specimen`. Tabular figures were measured, not assumed: Sora `tnum` widths identical for 1111/0000/8888; Newsreader default figures tabular; Fraunces (rejected) has no `tnum`.
* **Type roles and scale (both):** tile glyph (46 % A / 62 % B of tile), target-rail glyph, display word (34–54 pt), stat numeral (30–40 pt tabular), counter (34–56 pt tabular), label (11–11.5 pt caps, tracked), CTA (15–16 pt caps tracked), helper (14–16 pt).
* **Fallbacks and dynamic type:** bundle the variable files as app assets; no network loading; no system-font fallback in final renders. Labels are ≥ 11 pt in the renders — Phase C should raise the floor to 12 pt and verify wrapping at accessibility text sizes (the shipped F03 §16.5 text-scale rule stays). App-size cost unsubsetted: Sora ≈ 109 KB, Newsreader ≈ 441 KB (subset to Latin Extended to reduce).
* **Turkish casing rule (both):** never uppercase display labels with locale-blind casing (`i` → `I` breaks `HARİKA`, `İLK`, `SEVİYE`). Keep authored uppercase strings (as shipped) or use locale-aware (`tr`) casing.

### Color

* Semantic roles (both): ground, ink/text, muted, tile, tile-glyph, **resolution** (A amber / B vermilion), **drag energy** (A cyan / B proof-blue), **locked**, **frozen**, sheet, danger (debug/load error only). Values in §4/§5.
* **Light/dark strategy:** each direction is single-mode in this draft (A dark, B light). A dark companion ("Gazette Night") or a light companion would be a separate, later decision — not assumed here.
* **Contrast and non-colour cues:** computed WCAG ratios are printed in each specimen. A: ink on tile 15.4, amber-CTA text 10.4, muted on stage 6.4, paper on stage 17.0, amber on sheet 10.7, muted on sheet 5.6. B: ink on sort 16.5, cream on vermilion 4.9, muted on paper 4.9, ink on paper 14.5, vermilion on cream 4.9, cream on ink 16.5. No state is colour-only (see §4/§5).

### Shape, Spacing and Surfaces

* **Shape/radius language:** A soft keycap (19 %), B square sort (5 px). **Spacing rhythm (both, unchanged from shipped):** tile gap 8, plate padding 10, board = 86 % of width, target→board and board→HUD 28. **Surface/depth rules:** depth only for hierarchy (A: lift, dock, sheet; B: shelf edge and 9 px hard lift shadow on the dragged row).

### Icons, Illustration and Imagery

* **Art direction:** one drawn set per direction (see §4/§5 icon rows); no illustration or photography in scope.
* **Asset source / licensing:** all icons in the renders are hand-drawn SVG paths authored for this project (no third-party icon licence). The shipped `Icons.*` (chevron_left_rounded, undo_rounded, refresh_rounded, push_pin, unfold_more_rounded, error_outline_rounded) are Material defaults and must be replaced in Phase D. Delivery mechanism (CustomPainter vs bundled SVG vs icon font) is a Frontend/Tech Lead decision.
* **Forbidden placeholders:** default system font as a final asset, Material icons as final assets, emoji stars, stock imagery.

## 8. Signature Motif

* **A — the seam / open loop:** an amber line that closes a loop. Where: winning-row seam, wordmark's second O (amber arc), home-ring ticks + node. Not: on every tile, button or border.
* **B — the rule and misregistration:** thick-thin double rule at hierarchy breaks and under the answer; blue offset on stamped stars. Not: as a frame around every card.
* *Wordmark note:* the A wordmark uses a custom ring-O; it reads LOOPLET (checked at render) but is a placeholder drawing — a final vector logo is a Phase D asset. B uses the typeset word "Looplet" (casing change — brand decision).

## 9. Motion and Sensory Language

Both directions keep the contracted timeline (F03 §16: win sequence ≤ 600 ms, panel not before T0 + 600 ms, dock 600–840, panel 680–940, star reveal at rest) and the reduced-motion path (§16.2). They differ in *how* it moves. Static stills of T0 hold / ~T0+600 glide / ~T0+760 panel: `A-08…10`, `B-08…10`. **No prototype or video exists** — the frame stills are illustrations of choreography, not motion evidence.

| | A — glide and glow | B — press and stamp |
| --- | --- | --- |
| Shift (≈ 190 ms) | `cubic-bezier(.22,1,.36,1)`, soft settle; cyan rail whispers | `cubic-bezier(.3,1.25,.4,1)` with ≤ 2 % overshoot then a 60 ms settle — a sort seating into the chase |
| Lift (drag) | row brightens, blue-white edge glow, wrap ghost at 32 % | shelf shadow grows 2 → 9 px (hard edge), blue guide rule under the row, blue register marks at the row ends |
| Win row | tiles fill amber left→right (30 ms stagger — the stagger specified in F03 §8 but never implemented), seam draws 0→full in 240 ms, one bloom | tiles flip to vermilion left→right (40 ms), each with a 1.06 scale "stamp" (70 ms); double rule draws linearly (press bed) in 240 ms |
| Dock → panel | row glides to the dock (ease-out), sheet rises | row slides to the dock (ease in-out), sheet is *placed* (ease-out, 1 px settle) |
| Stars | struck with a 90 ms light flash each | stamped with a 120 ms misregistration jitter (blue offset 1.1 px → 0), no glow |
| Audio / haptic | language intent only (F11, not scheduled): soft glass tick per shift, light haptic on settle, success haptic on win | wooden click per shift, same haptic mapping |
| Reduced motion / silent / haptic-off | unchanged from F03 §16.2 / F04 §4 / F05 §13: static end states, cross-fades; nothing depends on sound or haptics | same |

## 10. Responsive and Device Matrix

| Viewport / Device | Orientation | Input | Key Constraints | Required Evidence |
| --- | --- | --- | --- | --- |
| iPhone 16 393×852 (reference) | portrait-locked | touch | board 86 % width; tile ≈ 57.2; panel top ≥ 0.36 H, ≤ 64 % H | `A-01…10`, `B-01…10` (rendered) |
| iPhone 16e 390×844 | portrait-locked | touch | tightest height; panel stack must clear the home indicator | `*-v-16e-play-idle`, `*-v-16e-won-perfect` |
| iPhone 16 Pro Max 440×956 | portrait-locked | touch | panel content is top-anchored in the renders and leaves empty space below; Phase C: bottom-anchor the CTA stack on tall frames | `*-v-promax-play-idle`, `*-v-promax-won-perfect` |
| OS text scale (up to accessibility sizes) | portrait | touch | labels / CTAs must not clip; F03 §16.5 rule stays | **not rendered in Phase B** — Phase D runtime evidence |
| Android (any) | portrait | touch | capture Pending (platform.md §14) | **Pending** — stated as a limit |

## 11. Accessibility Baseline

* **Contrast:** §7 (computed from the token hex values; every pair listed in the specimens is ≥ 4.9 : 1). B's paper-texture overlay lowers effective contrast slightly and must be re-measured on the runtime capture; dimmed/disabled states (e.g. the target rail under the win scrim) are intentionally lower and decorative.
* **Touch/focus:** back 44 pt, undo 46×78 (A) / 52×48 (B), restart 48×48, CTAs 56–60 pt tall, secondary 48–50 pt; Close/"Kapat" remains a text control and must keep the shipped 44 pt minimum height (F04 fix) in either direction.
* **Screen reader order/labels:** unchanged from shipped `Semantics` (board label, star-group "N / 3 yıldız", ring "N / 30 seviye tamamlandı"); the docked row stays `ExcludeSemantics` (decorative).
* **Text expansion / localization:** English pack lengthens CTAs (CONTINUE vs DEVAM ET) — all CTAs are full-width bars/pills and absorb it; labels are single-line caps.
* **Reduced motion / flashing:** §9; no flashing element (glow is static; the stamp is a single 70 ms scale, not a flash).

## 12. Anti-Generic Rules

* Patterns this product must not default to: default system font; Material `Icons.*` as final assets; dark-gradient-glow *as a default* (allowed only if Direction A is selected and then rationed by the one-glow rule); every surface in a rounded card; border-only selected state; the same layout in two colours.
* Category clichés to avoid: neon puzzle-game glow; mascot faces; confetti-on-everything; hint-coin economy chrome; flat pastel "wellness" surfaces.
* Component-library defaults that require replacement: `Icon(Icons.*)`, default `ThemeData` text styles, `Material` ink ripples on tiles, default `Chip`/`ElevatedButton` shapes, system fonts in tiles.

## 13. Foundation Evidence Manifest

Source revision for every record: HEAD `1d1ae14` + uncommitted working tree (design generator `design/src/gen.mjs`; HTML/CSS rendered to PNG with headless Google Chrome, devicePixelRatio 2 for frames, 1 for specimens). Captured By: UI Designer. Captured At: 2026-09-21. **Generated design artefacts, not app runtime captures.**

| Evidence ID | Kind | Screen / State | Viewport / Device | Artifact | Source Revision | Captured By | Captured At | Result / Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| DR-A-01 | direction-render | A · Play idle (level 1, target ASLAN) | 393×852 | features/f00-design-foundation/design/A-01-play-idle.png | 1d1ae14 + working tree | UI Designer | 2026-09-21 | rendered |
| DR-A-02 | direction-render | A · Play, row lifted mid-drag (lift, brighter row, dimmed rest, wrap ghost, rail highlight) | 393×852 | …/design/A-02-play-lifted-row.png | 1d1ae14 + working tree | UI Designer | 2026-09-21 | rendered |
| DR-A-03 | direction-render | A · Play, locked pivots + frozen tiles (level 26) | 393×852 | …/design/A-03-play-locked-frozen.png | 1d1ae14 + working tree | UI Designer | 2026-09-21 | rendered |
| DR-A-04 | direction-render | A · Won, Perfect (docked row + F04 panel, Next primary) | 393×852 | …/design/A-04-won-perfect.png | 1d1ae14 + working tree | UI Designer | 2026-09-21 | rendered |
| DR-A-05 | direction-render | A · Won, 2★ (Retry primary) | 393×852 | …/design/A-05-won-two-star.png | 1d1ae14 + working tree | UI Designer | 2026-09-21 | rendered |
| DR-A-06 | direction-render | A · Journey home, in progress (3 / 30) | 393×852 | …/design/A-06-home-in-progress.png | 1d1ae14 + working tree | UI Designer | 2026-09-21 | rendered |
| DR-A-07 | direction-render | A · Column tutorial overlay (level 4) | 393×852 | …/design/A-07-tutorial-column.png | 1d1ae14 + working tree | UI Designer | 2026-09-21 | rendered |
| DR-A-08…10 | direction-render | A · won-moment stills: T0 hold, ~T0+600 glide, ~T0+760 panel | 393×852 | …/design/A-08-motion-t0-hold.png, A-09-…glide.png, A-10-…panel.png | 1d1ae14 + working tree | UI Designer | 2026-09-21 | stills only, not motion evidence |
| DR-A-V | direction-render | A · Play idle + Won Perfect on 16e and Pro Max | 390×844, 440×956 | …/design/A-v-16e-*.png, A-v-promax-*.png | 1d1ae14 + working tree | UI Designer | 2026-09-21 | rendered |
| DR-A-90 | accessibility | A · glyph / tabular / icons / contrast specimen | 786×1100 | …/design/A-90-specimen.png | 1d1ae14 + working tree | UI Designer | 2026-09-21 | Turkish capitals, tnum, contrast computed |
| DR-B-01 … B-07 | direction-render | B · same seven states as A-01…07 | 393×852 | …/design/B-01-play-idle.png … B-07-tutorial-column.png | 1d1ae14 + working tree | UI Designer | 2026-09-21 | rendered |
| DR-B-08…10 | direction-render | B · won-moment stills | 393×852 | …/design/B-08…10-*.png | 1d1ae14 + working tree | UI Designer | 2026-09-21 | stills only |
| DR-B-V | direction-render | B · Play idle + Won Perfect on 16e and Pro Max | 390×844, 440×956 | …/design/B-v-*.png | 1d1ae14 + working tree | UI Designer | 2026-09-21 | rendered |
| DR-B-90 | accessibility | B · specimen | 786×1100 | …/design/B-90-specimen.png | 1d1ae14 + working tree | UI Designer | 2026-09-21 | Turkish capitals, tabular default, contrast computed |
| DR-CMP | direction-render | side-by-side A | B: play, won, home/tutorial, devices; contact sheets | mixed | …/design/compare-play.png, compare-won.png, compare-home-tutorial.png, compare-devices.png, sheet-A.png, sheet-B.png | 1d1ae14 + working tree | UI Designer | 2026-09-21 | composites of the records above |

**Limits stated:** renders are HTML/CSS (Blink text metrics), not Flutter (Skia); implementation fidelity is unproven until Phase D runtime capture. No motion prototype or video. No OS-text-scale render. No Android frame. The dark/light companion of each direction is not rendered.

## 14. Provisional Self-Review Against `premium-ui-rubric.md`

**Provisional, advisory, and not an acceptance.** Independent QA scores implemented surfaces only. Dimensions 7 (Motion) and 10 (Implementation Fidelity) cannot be honestly scored above 8 before there is a prototype and a runtime build; I therefore cap them at 8 rather than claim 93+. This is flagged for the Tech Lead (§16).

| Dimension | A — Backlit Stage | B — Gazette |
| --- | --- | --- |
| 1 Experience Fit | 9 — board is the hero, quiet chrome | 9 — audience-native (bulmaca), calm and exact |
| 2 Visual Hierarchy | 9 | 9 |
| 3 Layout, Rhythm, Responsiveness | 9 (Pro Max panel needs bottom-anchoring) | 9 (same note) |
| 4 Typography and Content Craft | 9 — one family, tabular figures, tracked caps | 9 — high-contrast serif, İ/ı proven, tabular default |
| 5 Color, Surface, Asset System | 9 | 9 |
| 6 Interaction, State, Feedback | 9 — non-colour cues on locked/frozen/win/star | 9 — structural cues (inverse, hatch, rule) |
| 7 Motion and Sensory | 8 — specified, not prototyped | 8 — specified, not prototyped |
| 8 Originality and Product Identity | 8 — evolves a category-default recipe; the seam is ownable | 9 — rule + misregistration + bulmaca context |
| 9 Accessibility and Inclusive | 9 | 9 |
| 10 Implementation Fidelity and Polish | 8 — unbuilt | 8 — unbuilt |
| **Total (provisional)** | **87** | **88** |

What would lift each to the ≥ 93 / every-dimension ≥ 8 bar after selection: a working motion prototype (win sequence) and a runtime parity pass (dims 7, 10); for A a stronger ownable signature beyond the seam (dim 8); for B a proven playful win moment without glow (dim 6/7) and a final wordmark decision.

## 15. Shipped-Surface Impact (Phase C input)

| Surface (owner feature) | Direction A change | Direction B change |
| --- | --- | --- |
| Play screen (F03) — tiles, plate/chase, rail, HUD, icons | replace system font + Material icons; refine states; keep layout | re-skin tiles to sorts, plate → chase, new rail, HUD re-composition, new icons, paper ground |
| Won moment (F03 §16) — docked row, scrim, ghost slot, panel | adopt seam/wordmark language; implement the 30 ms amber stagger; keep timeline | stamp + rule choreography; scrim → paper wash; panel → cream sheet; keep timeline |
| Completion panel (F04) — stars, stat trio, CTAs | drawn faceted star, tabular stats, CTA pill retuned | printed star + misregistration, ledger stat row, bar CTAs |
| Journey home (F05) — wordmark, ring, CTA | ring-O wordmark (final vector), ring ticks retuned | masthead composition, printed tick dial, bar CTA (re-composition) |
| Column tutorial (F05) | ghost + hint restyled | proof-blue ghost + italic hint |
| Error / recovery screens (F03 load error, F08) | adopt tokens | adopt tokens (light scheme) |
| **Rough size** | **S–M** (tokens, font, icon set, wordmark, panel retune) | **L** (new palette/theme, tile/chase/rule painters, paper ground, star painters, home re-composition, panel re-layout) |

Asset/plumbing tasks either way (Frontend/Tech Lead): bundle the selected font(s) in `pubspec.yaml`; replace six `Icons.*` uses with the drawn set; centralise tokens beyond `PlayTheme`; locale-aware uppercase rule; reduced-motion parity kept.

## 16. Assumptions and Needs Tech Lead Clarification

**Decisions the selection authority must make** (the UI Designer cannot):

1. Select Direction A or B (or ask for a third / a revision). §6 holds the recommendation and the conditions.
2. Wordmark casing and mark: keep uppercase `LOOPLET` (A) or `Looplet` (B); approve a final drawn logo asset.
3. Appetite for a companion mode (dark for B, light for A) — not assumed.
4. Accept the proposed motion-language changes (A: the 30 ms amber stagger; B: stamp/press) as a contract change to F03 §16 / §8 before Phase D — flagged, not applied.
5. Accept bundling the chosen OFL font and its app-size cost.

**Needs Tech Lead clarification:**

* The prompt says not to finalise below 93; the honest provisional totals are 87 (A) / 88 (B) because dims 7 and 10 are unscorable pre-implementation. Please confirm that a Foundation draft is exempt from the 93 bar (advisory only) or say how it should be scored.
* Selection is required before any visual implementation task; F03/F04/F05 surfaces are not visually accepted under the new rubric (Design Adoption Route Phase C/D).
* The renders are HTML, not Flutter; if a Flutter-rendered comparison is wanted before selection, that is a Frontend prototype task (not done here).

**Assumptions:** the shipped copy and puzzles (real level 1, 4, 26 data) are used as-is; the status-bar/dynamic-island strip is device chrome drawn for realism; audio/haptic are language notes only.
