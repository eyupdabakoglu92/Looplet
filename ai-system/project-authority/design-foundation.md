# Project Design Foundation — LOOPLET

> Status: Selected
>
> Owner: Tech Lead (lifecycle) / UI Designer (design authorship)
>
> Selection Authority: User / Product Owner / explicitly delegated Tech Lead

Last Updated: 2026-09-21
Selected At: 2026-09-21
Selected By: User (project owner), via decision F00.FOUNDATION-SELECTION — `B: 2=2, 5=Looplet` (Direction C selected with two overrides)
Decision Reference: features/f00-design-foundation/orchestration.md → Open Decision Gates → F00.FOUNDATION-SELECTION (RESOLVED 2026-09-21); user message "Run Tech Lead. Decision: F00.FOUNDATION-SELECTION — B: 2=2, 5=Sadece ilk harf büyük olsun (Looplet) fakat son 3 harfi yine yeşil olsun"

> **Status: SELECTED on 2026-09-21 — Direction C ("Loop Glass", §17), with the decision set recorded in §18. Directions A and B were rejected by the user (§6). The Foundation is the authority for visual implementation; the selected-source renders that reflect the final decision set are being produced (task F00-UI-FINALIZE).** Two rendered directions (A, B) are compared on identical content; the UI Designer's recommendation (§6) is not a selection. Visual artefacts live in `features/f00-design-foundation/design/` (sources in `design/src/`, regenerate with `node gen.mjs . && sh render.sh && python3 sheets.py`).

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

* **Rejected by the selection authority (user), 2026-09-21: Direction A and Direction B** — "neither is modern; not the style I expect". The user supplied three reference screens (`features/f00-design-foundation/design/reference/`) as the expected style; **Direction C — Loop Glass (§17)** was rendered from them (task F00-UI-DIRECTION-C). Recorded by the Tech Lead; §4–§5 describe A/B as explored alternatives.
* **Selected direction: Direction C — Loop Glass (§17), on 2026-09-21, by the user, with the decision set in §18** (two overrides of the UI Designer's recommendations: the solved screen is the full-screen composition, and the wordmark is `Looplet`).
* Decision maker / delegated authority: **the user (selection authority)**
* Decision reference: F00.FOUNDATION-SELECTION (RESOLVED 2026-09-21) — see the header and §18
* Why this direction fits the product: it is the visual language the user asked for (their own reference screens), rendered with parity, with measured colours and contrast and Turkish casing corrected. Its weakest dimension is Originality (§17.7); the loop identity must be carried by the journey track, the swirl arcs and the `Looplet` wordmark.
* Rejected directions and reason: A (Backlit Stage) and B (Gazette) — rejected by the user 2026-09-21: "neither is modern, not the style I expect".

**Round-1 recommendation (superseded — the user rejected A and B):** Direction B — Gazette, *if* the selection authority accepts a full restyle of the shipped surfaces. Reasons: it is the only direction whose identity comes from this product's audience (the Turkish newspaper bulmaca habit) rather than from the game-UI category default; its non-colour cues are structural, matching the PRD's "playable without colour" need; and it removes the glow-on-dark recipe that Direction A shares with most puzzle games. **Choose Direction A instead if** protecting shipped work and time-to-launch matters more than distinctiveness: it is a refinement of what players have already seen, with a much smaller migration than B (see the size estimate in §15, which is a rough judgement, not a measurement). A hybrid is not recommended (the two materially differ in ground, type, edge language and motion; mixing them reproduces the "isolated visual language" fail condition).

**Round-2 recommendation (not a selection): Direction C — Loop Glass (§17).** It is the direction the selection authority asked for; it is rendered on the same states as A/B plus reference-frame parity renders. Judged on its merits it is polished and modern; its weakest dimension is Originality (§17.7): the navy-glass-plus-lime recipe is current and widely used, so the product-specific signature (the loop track, the open-loop wordmark, the swirl arcs) must be carried through implementation.

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

**Direction C records:** see §17.8 (DR-C-…, parity records, canonical-reference records of the user's screens).

**Limits stated (A/B):** renders are HTML/CSS (Blink text metrics), not Flutter (Skia); implementation fidelity is unproven until Phase D runtime capture. No motion prototype or video. No OS-text-scale render. No Android frame. The dark/light companion of each direction is not rendered.

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

---

## 17. Direction C — "Loop Glass" (round 2, rendered from the user's reference screens)

Source: three screens supplied by the user on 2026-09-21 (`design/reference/user-ref-1-home.png`, `user-ref-2-play.webp`, `user-ref-3-completion.webp`; 716×1434 = a 358×717 frame at 2×). They are recorded as `canonical-reference`; they are **not** yet a `selected-source` (nothing is Selected). Directions A and B were rejected by the user ("not modern, not the expected style"). Everything below is an original render in that visual language; no third-party brand assets are used.

### 17.1 Thesis

* **Name / thesis:** *Loop Glass* — a deep-navy night ground lit by soft top-right light; frosted glass cards hold the content; **lime** marks the moment that matters (the emphasised word, the primary action, resolution); **periwinkle** marks "where you are"; cream tiles are the only warm, tactile objects. Friendly, human Turkish microcopy ("Sıradaki döngüyü çöz.").
* **Material difference from A and B:** a *cool* ground with *frosted, large-radius glass* (A: dark stage with a hard-lit keycap board; B: paper and ink); *lime + periwinkle* dual accent (A amber/cyan, B vermilion/blue); *grotesque* Space Grotesk + Manrope (A Sora; B Newsreader); *thin outline* icons; *pill* controls and rounded-square tiles at ≈ 33 % radius; centred, card-based compositions with a curved journey track; motion = soft spring and light.
* **Strengths:** exactly the language the user asked for; the most current-feeling of the three; strong legibility and contrast; a clear two-accent semantic system; friendly tone; the panel is bottom-anchored and content-driven, which also fixes the round-1 tall-frame gap.
* **Risks:** the navy + glass + lime recipe is widely used in 2025–26 apps, so **Originality** is the weakest dimension — the loop identity must be carried by the journey track, the open-loop swirl arcs and the `looplet` wordmark (lime `let`); glass needs contrast discipline (every small label was measured, see 17.4); lime is used for several jobs in the reference (the emphasised word, CTA, resolution, the active row) and must be rationed (17.5); the won moment as rendered has three luminous elements (docked row, star glow, CTA shadow) versus the contracted "single glow" (flagged in 17.6).

### 17.2 System

| Area | Decision |
| --- | --- |
| Type | **Space Grotesk** (variable 300–700, SIL OFL 1.1) for headings, tile letters and numerals (`tnum` verified); **Manrope** (variable 200–800, SIL OFL 1.1) for body, labels, CTAs (`tnum` verified). Both identified as the closest match to the reference typography (single-storey `g` and the flagged `1` are Space Grotesk; the geometric body is Manrope); if the user's designer used other faces, say so — the identification is a visual judgement, not a lookup. Both cover İ ı Ş Ğ Ç Ö Ü (specimen `C-90-specimen`). Sizes (at 358 pt): headline 28–33, tile letter 0.38 × tile, stat numeral 24, CTA 16, body 13.5–14.5, cap labels 9.5–11.5 (reference values; 10.4–12.6 pt at 393 pt — the HAMLE card label stays 10.4 pt and should be raised in Phase D). Licences stored beside the files (`design/src/fonts/OFL-*.txt`); unsubsetted ≈ 133 KB + 161 KB. |
| Colour (measured, 17.4) | ground `#050A1E → #0D132D` with a top-right light `≈ #2D365C`; glass `≈ #2A345A`; **lime** `#DDFA6B` (tile `#E3FB7E → #CDEB4B`, ink `#0B1020`); **periwinkle** `#A8B4F9 → #8792F0`; cream tile `#FCF7F0 → #F0E9DC`, ink `#141826`; text `#F4F6FF`; muted label `#AEB4CA`; stats-card slate `#27394B`. |
| Shape / surface | cards 30–34 pt radius, 1 px `rgba(255,255,255,.10)` edge and a soft light spill; tiles 33 % radius; pills fully round; depth only for hierarchy (glass cards, lifted row, docked row, sheet). |
| Icons | drawn for this project, thin (1.7–1.9 px) rounded outline: back, sliders, flame, sparkle, undo, restart, arrow-up-right, arrow-right, lock, snowflake, up/down chevrons, outline/filled star. No third-party icon licence involved. |
| Signature motif | **the loop track**: a curved line of numbered rounded-square nodes that ends at the current level (periwinkle) inside a glass card with large translucent swirl arcs; echoed by the lime `let` in the lowercase wordmark and the lime dots of the undo quota. Not applied to every card. |
| Non-colour cues | active/lifted row = raised + periwinkle rim + rails + dimmed rest (17.5); winning row = lime **+ docked position + dashed ghost slot**; locked = indigo tile + **lock icon**; frozen = pale-ice tile + **snowflake + dashed border**; earned star = filled lime, empty = outline. |

### 17.3 Motion and sensory language

Timeline and reduced-motion path stay as contracted (F03 §16.2). Stills `C-08…10` illustrate the choreography; **no prototype/video exists**.

* Shift ≈ 190 ms `cubic-bezier(.22,1,.36,1)` with a ≤ 1.5 % spring settle; lift: periwinkle rim fades in over 90 ms, the rest dims to 42 %; wrap ghost at 30 %.
* Win row: tiles fill lime left → right (30 ms stagger — the stagger F03 §8 specified but never implemented), one soft bloom; the row then **glides to where the target rail was** (240 ms, the rail fades) — see 17.6 for why; the sheet rises 260 ms with a 1.5 % overshoot; stars fill lime with a 90 ms pop each once the sheet is at rest.
* Audio/haptic: language intent only (F11 not scheduled): a soft tick per shift, a light haptic on settle, a success haptic on resolution. Reduced motion / silent / haptic-off: unchanged from F03 §16.2 / F04 §4 / F05 §13.

### 17.4 What was measured from the reference (not guessed)

Pixel samples of the user's screens (sRGB): ground top-right `#1F2849 / #2D365C`, ground bottom `#0D132D`, deepest `#050A1E`; glass card `#2A345A`; chip `#262D3C`; stats card `#27394B`; lime CTA `#DEFB6D–#E4FA87`, lime tile `#D0EF58 / #DDFB6C`; periwinkle node `#A8B4F9`; cream tile `#FCF7F0`; target tile `#28254A`. **Small-label text colours** (brightest text pixel vs adjacent background): `#AEB3C7` on glass `#273155` = 6.1 : 1; `#AEB3C7` on chip `#2E353E` = 5.9 : 1; `#ACB8C6` on the stats card `#2B3D4C` = 5.6 : 1; subtitle `#B7BACE` on the ground = 9.1 : 1; captions on the ground 9.3–9.6 : 1. **Correction to the round-2 brief:** the brief assumed the reference's small caps were a likely contrast weakness; the measurement shows they are not (the "HAMLE" label was not measured — the region sample failed). Direction C therefore uses `#AEB4CA` for muted labels (my first draft used a darker `#9BA3C6`).

### 17.5 Resolved design conflict — one accent, two jobs (the "lime active row")

In the reference's Play screen the **active row is lime**, while lime is also the resolution / primary-action colour. With the contracted separation (F03: resolution vs drag energy) a player could not tell "the row I am dragging" from "a matching row". **Primary render (`C-02`):** the active row keeps cream tiles and gains a **periwinkle rim + glow, lift, rails and a dimmed rest**; lime is reserved for resolution, the emphasised word and primary actions. **Reference-literal alternative (`C-02b`):** the active row is lime exactly as in the reference. Recommendation: the resolved version; the choice is the user's (17.9).

### 17.6 Contract conflicts found (flagged, not applied)

1. **Docked row location.** F03 §16.3 docks the answer row *under the target rail* in `[dividerBottom + 12, 0.36 H − 16]`. In the reference layout the header (moves card, "HEDEF DÖNGÜ" caption, taller rail) fills that zone (it collapses to a negative height at 393×852). Direction C therefore lands the row **in the place of the target rail** (the rail fades out; the answer *becomes* the target) and anchors the sheet to the bottom with content-driven spacing (top ≥ 0.365 H). The row-0 strip that A/B left visible is gone. **Requires a contract change to F03 §16.3** (Tech Lead / Frontend), or the header must be compacted. **SUPERSEDED 2026-09-21** by the user's decision 2 (full-screen result, §18): the dock/sheet composition no longer applies.
2. **Full-screen completion.** The reference completion has no board and no Close; F03 §16 / F04 keep the docked row + sheet over the dimmed board and Close is an F04 AC. Primary render `C-04` conforms; the reference composition is rendered as `C-04b` for comparison and would change F03 §16 and F04.
3. **Completion semantics.** The reference stats are `SEN 1 = OPTİMAL +3 YILDIZ` (no personal best); F04 shows `SEN / OPTİMAL / EN İYİ`. Primary renders keep the shipped semantics; `C-04c` renders the reference semantics for comparison. The reference's three **outlined** stars next to "+3 YILDIZ" read as *not earned*; Direction C fills earned stars and outlines empty ones.
4. **One-glow rule.** F03 §16 allows a single glow at the won moment; C shows the docked-row glow, star glow and a soft CTA shadow. Flagged for a decision.

### 17.7 Provisional self-review (advisory; independent QA scores implemented surfaces only)

| Dimension | C — Loop Glass |
| --- | --- |
| 1 Experience Fit | 9 — the user's stated style; friendly and clear |
| 2 Visual Hierarchy | 9 |
| 3 Layout, Rhythm, Responsiveness | 9 — bottom-anchored content-driven sheet; header/dock conflict flagged (17.6) |
| 4 Typography and Content Craft | 9 — two OFL families, Turkish casing fixed, tabular numerals |
| 5 Color, Surface, Asset System | 9 — measured palette, contrast verified |
| 6 Interaction, State, Feedback | 9 — non-colour cues on every state; accent conflict resolved |
| 7 Motion and Sensory | 8 — specified, not prototyped |
| 8 Originality and Product Identity | 8 — current recipe; identity rests on the loop track / swirl / wordmark |
| 9 Accessibility and Inclusive | 9 — muted-label pairs computed ≥ 5.9 : 1 (reference measured ≥ 5.6 : 1); targets ≈ 44 pt (restart and settings 43.9 at 393 pt) |
| 10 Implementation Fidelity and Polish | 8 — unbuilt |
| **Total (provisional)** | **87** |

To reach the ≥ 93 / every-dimension ≥ 8 bar after selection: a motion prototype of the win sequence and a runtime parity pass (dims 7, 10); a stronger product-specific signature carried through the surfaces (dim 8).

### 17.8 Deviations from the user's references (each one is intentional)

| # | Reference | Direction C | Why |
| --- | --- | --- | --- |
| D1 | "YENİ EN **I**YI", "OPT**I**MAL" (dotless) | `YENİ EN İYİ`, `OPTİMAL` | Turkish casing bug in the reference (locale-blind uppercasing) |
| D2 | three outlined stars beside "+3 YILDIZ" | earned = filled lime, empty = outline | outlines read as "not earned" |
| D3 | journey nodes overlap; node 1 is hidden behind the info card | five evenly spaced nodes, none covered | legibility |
| D4 | info-card helper wraps to three lines | two lines (wider column) | legibility |
| D5 | small caps ≈ 9.5–11.5 pt (at 358 pt) | 10.4–12.6 pt at 393 pt (most ≥ 11.5; the HAMLE card label is 10.4 pt — flagged) | modest accessibility uplift, not a full floor yet |
| D6 | three white dots as status icons; phone bezel | real signal/battery glyphs; no bezel | device chrome |
| D7 | muted label colour (measured `#AEB3C7`) | `#AEB4CA` | matched, not weakened |
| D8 | lime active row | periwinkle-rim active row (literal variant provided) | 17.5 |
| D9 | full-screen completion, no Close | sheet + docked row, Close kept (reference variant provided) | 17.6 |
| D10 | stats "SEN = OPTİMAL +3 YILDIZ" | shipped semantics (reference variant provided) | F04 ACs |
| D11 | slightly flatter lime, darker stats slate | tuned to match after side-by-side | parity |

### 17.9 Content deltas (visual language adopted; new product content = proposal) and confirmations needed

| Ref | Element | Shipped / contract | Handling in the renders | Decision owner |
| --- | --- | --- | --- | --- |
| H1 | lowercase `looplet` with lime `let` | uppercase `LOOPLET` | adopted (brand decision) | user |
| H2 | settings icon button | none until F10 | rendered, labelled proposal (`C-06` / `C-P1`); absent in `C-06b` | user / F10 |
| H3 | Home card "YOLCULUK · 4 / 30", headline "Sıradaki döngüyü çöz.", loop track | F05 30-tick ring + count | rendered (new composition) | user / F05 |
| H4 | level info card "Seviye 5 / Yeni mekanik · sütun kaydırma" + target preview | none | rendered, proposal (needs per-level metadata) | user / PO |
| H5 | CTA "5. bölüme devam ↗" | `DEVAM ET` + "Seviye N · sürüyor" | reference copy in `C-06`; shipped-scope copy in `C-06b` | PO / localization |
| H6 | chips "4 günlük seri", "12 yıldız" | streak = F07 (not started); no star aggregate | rendered, proposals | user / F07 |
| P1 | top bar "‹ SEVİYE 05" + HAMLE card top-right | HUD bottom-left | adopted as the layout | user (F03 UI-owned) |
| P2 | "HEDEF DÖNGÜ" | `HEDEF` | reference copy | PO / localization |
| P3 | hint "Satırı tut · kaydır · bırak" | none (F09) | rendered, proposal | user / F09 |
| C2 | badge "YENİ EN İYİ", "Döngü tamamlandı.", data-driven subtitle ("Hedef üç hamlede yerine oturdu.") | `YENİ REKOR`, `ÇÖZÜLDÜ` + word | reference copy; subtitle needs count-aware copy | PO / localization |
| C4 | CTAs "Sonraki bölüm →", "Tekrar oyna", no Close | `SONRAKİ` / `Yeniden` / `Kapat` | reference copy; Close kept | PO / F04 |

**What the user should confirm** (the UI Designer cannot decide): (1) Direction C as the selected direction; (2) the active row — periwinkle-rimmed (`C-02`, recommended) or lime as in the reference (`C-02b`); (3) the completion — contract-conforming sheet with the row landing where the rail was (`C-04`, recommended) or the full-screen reference composition (`C-04b`); (4) completion stats — shipped `SEN / OPTİMAL / EN İYİ` (recommended) or `+3 YILDIZ` (`C-04c`); (5) which of settings button, streak chip, stars chip, level card and gesture hint are wanted at all (otherwise `C-06b`); (6) lowercase `looplet`; (7) the reference copy as *proposed* copy (final Turkish copy remains PO / localization).

### 17.10 Evidence manifest additions

Source revision for every record: HEAD `8b1a3d5` + uncommitted working tree (generator `design/src/gen-c.mjs`, HTML/CSS → PNG with headless Chrome at devicePixelRatio 2; specimen at 1). Captured By: UI Designer. Captured At: 2026-09-21. Generated design artefacts, not app runtime captures.

| Evidence ID | Kind | Screen / State | Viewport / Device | Artifact | Source Revision | Captured By | Captured At | Result / Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| REF-1 | canonical-reference | User reference — Home | 716×1434 (358×717 @2×) | features/f00-design-foundation/design/reference/user-ref-1-home.png | user-supplied 2026-09-21 | User | 2026-09-21 | not a selected-source |
| REF-2 | canonical-reference | User reference — Play | 716×1434 | …/design/reference/user-ref-2-play.webp | user-supplied | User | 2026-09-21 | — |
| REF-3 | canonical-reference | User reference — Completion | 716×1434 | …/design/reference/user-ref-3-completion.webp | user-supplied | User | 2026-09-21 | — |
| DR-C-01 | direction-render | C · Play idle (level 5, BULUT) | 393×852 | …/design/C-01-play-idle.png | 8b1a3d5 + working tree | UI Designer | 2026-09-21 | rendered |
| DR-C-02 / 02b | direction-render | C · row lifted: resolved (periwinkle) / reference-literal (lime) | 393×852 | …/design/C-02-play-lifted-row.png, C-02b-…reference-literal.png | 8b1a3d5 + working tree | UI Designer | 2026-09-21 | rendered |
| DR-C-03 | direction-render | C · locked pivots + frozen tiles (level 26) | 393×852 | …/design/C-03-play-locked-frozen.png | 8b1a3d5 + working tree | UI Designer | 2026-09-21 | rendered |
| DR-C-04 / 05 | direction-render | C · Won Perfect / 2★ (docked row + bottom-anchored sheet) | 393×852 | …/design/C-04-won-perfect.png, C-05-won-two-star.png | 8b1a3d5 + working tree | UI Designer | 2026-09-21 | rendered |
| DR-C-04b / 04c | direction-render | C · full-screen completion (reference composition) / reference stat semantics | 393×852 | …/design/C-04b-…png, C-04c-…png | 8b1a3d5 + working tree | UI Designer | 2026-09-21 | comparison alternatives |
| DR-C-06 / 06b | direction-render | C · Home with the reference composition / shipped-scope only | 393×852 | …/design/C-06-home-in-progress.png, C-06b-home-shipped-scope.png | 8b1a3d5 + working tree | UI Designer | 2026-09-21 | rendered |
| DR-C-07 | direction-render | C · column tutorial (level 4) | 393×852 | …/design/C-07-tutorial-column.png | 8b1a3d5 + working tree | UI Designer | 2026-09-21 | rendered |
| DR-C-08…10 | direction-render | C · won-moment stills (T0 hold, ~T0+600 glide, ~T0+760 panel) | 393×852 | …/design/C-08…10-*.png | 8b1a3d5 + working tree | UI Designer | 2026-09-21 | stills only, not motion evidence |
| DR-C-V | direction-render | C · Play idle + Won Perfect on 16e and Pro Max | 390×844, 440×956 | …/design/C-v-*.png | 8b1a3d5 + working tree | UI Designer | 2026-09-21 | rendered |
| PC-1 / 2 / 3 | parity-comparison | reference vs C on the reference frame: Home / Play / Completion | 716×1434 each | …/design/parity-1-home.png, parity-2-play.png, parity-3-completion.png (render frames C-P1/P2/P3) | 8b1a3d5 + working tree | UI Designer | 2026-09-21 | deviations D1–D11 |
| DR-C-90 | accessibility | C · glyph / tabular / icon / measured-contrast specimen | 786×1180 | …/design/C-90-specimen.png | 8b1a3d5 + working tree | UI Designer | 2026-09-21 | Turkish capitals, tnum, contrast computed + measured |
| DR-C-CMP | direction-render | composites | mixed | …/design/sheet-C.png, compare-C-alternatives.png, compare-C-devices.png, compare-ABC.png | 8b1a3d5 + working tree | UI Designer | 2026-09-21 | composites of the records above |

**Limits stated (C):** HTML/CSS (Blink), not Flutter; no motion prototype/video; no OS-text-scale render; no Android frame; dark/light companions not rendered; typography is identified by visual match, not by the reference author; blur/glass is drawn with gradients and shadows (no backdrop blur — consistent with the F03 §18 perf clarification).

### 17.11 Needs Tech Lead clarification (round 2)

* **Contract change decision** for 17.6 (docked row replaces the rail; completion composition; semantics; one-glow rule) before any Phase D task.
* **Content deltas** in 17.9 need owners: several are new product scope (streak chip = F07, stars aggregate, settings = F10, per-level info, hint line = F09) — none is implemented or required by this Foundation.
* The 93 bar for a Foundation draft (as in §16): C is provisionally 87 for the same reason as A/B.

---

## 18. Selection decisions (authority: the user, 2026-09-21)

The user decided through six plain-language sub-decisions (visual guide `design/guide-0 … guide-7`). Recommended options were kept except where marked.

| # | Decision | Result | Source render / note |
| --- | --- | --- | --- |
| 1 | Dragged (active) row | **Cream tile with a periwinkle rim + lift + rails + dimmed rest** (recommended); lime stays reserved for resolution and primary actions | `C-02-play-lifted-row.png` |
| 2 | Solved screen | **Full-screen result, no board behind, no Close button** — *the user overrode the recommendation* | `C-04b-won-full-screen-reference-composition.png` (the 2★ full-screen variant is to be produced) |
| 3 | Third stat in the result box | **`EN İYİ` (personal best) — shipped semantics kept** (recommended) | `C-04b` |
| 4 | Items in the user's screens the game does not have yet (settings button, "4 günlük seri", "12 yıldız", "Seviye 5 / Yeni mekanik" card, gesture hint) | **Keep in the design as future scope; not implemented until the owning feature exists** (recommended) | `C-06-home-in-progress.png`, `C-01-play-idle.png` |
| 5 | Wordmark | **`Looplet`** — capital `L` only; the last three letters `let` stay lime — *the user's own variant, neither of the two options offered* | to be rendered (the current renders show lowercase `looplet`) |
| 6 | Turkish copy | **The reference's wording as proposed copy** (recommended); final Turkish copy remains with the PO / localization | design-foundation §17.9 |

**Consequences recorded by the Tech Lead (not yet applied):**

1. **The won moment changes composition.** Decision 2 replaces the F03 §16 composition (answer row docked under the target rail + bottom sheet over the dimmed board) with a full-screen result. The earlier §17.6 proposals (row lands where the rail was; content-driven sheet) are **superseded**. The contracted intent stays: input locks at the win, the result is not shown before the win sequence has been seen (the T0 + 600 ms rule's purpose), the reduced-motion path exists, controller/persistence timing is unchanged. The transition from the board to the full-screen result must be designed (UI Designer) and contracted (Tech Lead: `architecture.md` §18 amendment at the F03 visual-rework activation).
2. **No Close button.** Close is specified in F03 `architecture.md` (§13/§10) and F04 `architecture.md` (Close / system back pops to the caller), **not in the PRD**, so this is a feature-contract amendment (Tech Lead), not a Product Owner revision.
   * *Correction (Tech Lead, 2026-09-27, Phase C audit C-3):* the F05 **feature** PRD does name it — AC1 reads "(via `Next Level` or `Close`)" — and so does F05 `architecture.md` §8 (Back).
   * The **product** PRD AC only says "when the completion panel closes", and the unlock is written at `won` (F05 §7). The product semantics are therefore unchanged, and no Product Owner revision is needed.
   * The Tech Lead resyncs the F05 wording at D2 activation, when Close is actually removed. A player must still have a way home: system back / edge swipe stays; the UI Designer must propose a visible, reference-consistent exit affordance for the full-screen result (the user may veto it). F04 tests that reference `Kapat` change with that rework.
3. **One-glow rule.** With the sheet gone, the full-screen result carries the lime tile row glow only as its single glow; star fill and CTA are non-glow emphasis (contract position kept).
4. **Wordmark `Looplet`** replaces `LOOPLET` on the Home surface; the lime `let` is kept; a final drawn asset is a Phase D item.
5. The five future-scope items stay owned by their features (F07 streak, F10 settings, F09 hint, F05 level info, an aggregate-stars decision) — see `workflow-follow-ups.md` (USER-REFERENCE-CONTENT-DELTAS).

---

## 19. Finalization (task F00-UI-FINALIZE, 2026-09-21)

* Selected-source renders reflecting the final decision set: `design/S-*.png` (Play, row lifted, locked + frozen, **full-screen Result** in three variants, Home in *design* and *today* forms, tutorial, device variants), the executable transition prototype `design/src/S-transition-prototype.html` with timed stills, and the component/token sheet `design/S-91-components.png`. Generator: `design/src/gen-s.mjs`.
* The design-system handoff is **`features/f00-design-foundation/ui-design.md`** (tokens, components, states, motion spec incl. reduced motion, screen/state/viewport matrix, Visual Evidence Manifest with `selected-source` and `motion-prototype` records).
* The earlier `C-*` renders show the lowercase `looplet`; the selected wordmark is **`Looplet`** (capital L, last three letters lime) — the `S-*` renders and the handoff are authoritative where they differ.
* Two UI Designer proposals await the Tech Lead / user: the Result's visible exit (a back chevron) and the one-glow rule on the Result (CTA and stars non-glow, which differs from the user's reference) — ui-design.md §17.
