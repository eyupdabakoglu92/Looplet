# F00 — design-foundation: UI Design (design-system handoff)

> Status: VISUAL-STATE AUTHORITY (design-system scope) — produced by task F00-UI-FINALIZE, 2026-09-21.
>
> Authority chain: `project-authority/design-foundation.md` (**Status: Selected**, Direction C "Loop Glass", decision set §18) → this handoff → Frontend delivery. This file does **not** change any feature contract; the contract amendments the selection implies are listed in §17 and belong to the Tech Lead.

---

## 1. Screen / Flow Goal

* **Primary goal:** give the shipped LOOPLET surfaces one selected visual language (Loop Glass) that a Frontend/Mobile Developer can implement without guessing: tokens, type, icons, components, states, motion, and four reference surfaces (Play, Solved result, Home, Column tutorial).
* **Secondary goal:** make the visual gate checkable — every claim has a `selected-source` render or a stated limit.
* **Success condition:** the surfaces, rebuilt from this handoff on the canonical simulator, match the selected-source renders within the tolerances in §14 and pass the independent premium rubric (≥ 93 total, every dimension ≥ 8).

## 2. Inputs

* Feature PRD: none (F00 is a cross-cutting track; product behaviour is unchanged). Product promise and audience: `product/product-prd.md` §1, §3.
* Architecture: `features/f00-design-foundation/architecture.md` (scope contract).
* Design doctrine / premium rubric / visual quality gate: `design/design-doctrine.md`, `design/premium-ui-rubric.md`, `design/visual-quality-gate.md`.
* Selected project Design Foundation: `project-authority/design-foundation.md` — Selected 2026-09-21 (§17 Direction C, §18 decisions).
* Orchestration Visual Scope: `design-system` (Visual Quality Gate: Pending until the Tech Lead reconciles this handoff).
* User reference (canonical-reference): `design/reference/user-ref-1-home.png`, `user-ref-2-play.webp`, `user-ref-3-completion.webp`.

## 3. Decision Provenance

* Direction selected by: **the user** (selection authority), 2026-09-21.
* Decision reference: `F00.FOUNDATION-SELECTION` (RESOLVED) — user reply `B: 2=2, 5=Looplet`; decision set in `design-foundation.md` §18.
* Selection date: 2026-09-21.
* UI Designer recommendation: Direction C, with the recommendations of the visual guide. **Two overrides by the user:** (2) the solved screen is a **full-screen result with no Close button** (recommended: bottom sheet with Close); (5) the wordmark is **`Looplet`** (capital `L` only, last three letters lime) — a variant the UI Designer did not offer.
* Rejected: Direction A (Backlit Stage) and B (Gazette) — "neither is modern, not the style I expect".

UI Designer self-selection is not approval; none was made.

## 4. Entry Context

| Surface | Entry | Exit |
| --- | --- | --- |
| Home (F05) | app start; return from Play / Result | CONTINUE → Play (resolved level) |
| Play (F03) | Home CONTINUE, Result "Sonraki bölüm" / "Tekrar oyna" | back chevron → Home (mid-puzzle keeps the resumable snapshot); solve → Result |
| Result (F04, full screen) | a settled solving move (T0) | "Sonraki bölüm" → next level; "Tekrar oyna" → same level restarted in place; **back chevron / system back → Home** |
| Column tutorial (F05) | Journey levels 4–6 until acknowledged | first valid column move clears it |

Allowed states are the shipped ones (idle, tracking, animating, won). Forbidden: any state where the Result is visible before the win sequence has been seen; a Result without an exit.

## 5. UX Flow — the solved moment

1. The player's move settles and solves the puzzle (**T0**); input locks; back chevron and HUD stop accepting input.
2. Win sequence on the board (0–600 ms): the winning row fills lime left → right, one bloom; the rest of the board dims.
3. Transition (600–940 ms): the answer row glides to its place in the Result while the board and chrome fade out; the Result content arrives.
4. At rest (940 ms) the stars fill one by one (rest-state reveal, 940–1300 ms).
5. The player chooses: next level, retry, or back to Home. Persistence, the personal-best write and the unlock stay triggered at `won` (unchanged).

## 6. Layout Structure

All layouts are authored in the reference's **358 × 717 pt space** and **scaled by width** (`s = W / 358`); on taller frames the extra height `e = H − 717 s` is distributed as stated. Measurements (pt at 358):

**Play** — safe top 59; back label "‹ SEVİYE 05" at (25, 96); HAMLE card 60 × 63 at (273.5, 75), radius 22; caption "HEDEF DÖNGÜ" at y 172 (+0.3 e); target tiles 36 × 42, gap 8, radius 14, y 197; **board card 308.5 × 307.5** at y 261.5, radius 34, padding 11, top light line 144 × 2 periwinkle; tiles 52 × 52, gap 6.5, radius 33 %; HUD (+0.3 e + 0.7 e): undo pill 98.5 × 50 at (29, 592.5) radius 22 with three lime quota dots, restart 40 × 40 radius 18 at (289, +5), hint line at +70.

**Result (full screen)** — back button 40 × 40 radius 15 at (24, 54); badge 112 × 42 at y 54 + 0.16 e (when present); display headline "Döngü tamamlandı." 33/1.13 at y 112 + 0.24 e; subtitle 14.5 at y 203 + 0.24 e; **answer tiles 52.5 × 59, radius 24, gap 6.5, y 258 + 0.4 e**; stars 19 pt, gap 14, y 349 + 0.4 e; stats card 309 × 74 radius 26 at y 392.5 + 0.4 e; primary CTA 309 × 63.5 radius 32 at y 485 + 0.4 e; secondary text link at y 568 + 0.4 e. A soft lime radial (`rgba(208,239,88,.13)`) sits behind the tiles.

**Home** — wordmark "Looplet" 25/1 at (25, 58); settings square 40 × 40 radius 15 at (293, 55) *(future scope)*; glass card 308 × 422 radius 30 at (24.5, 115 + 0.1 e); label at +31, headline 28/1.16 at +57 (emphasised word lime); loop track: nodes for levels 1–4 38 pt (radius 34 %), the current level 58 pt with a 76 pt halo, evenly spaced along a rising curve, never under another element; level-info card 257 × 123 radius 24 at +277 *(future scope)*; CTA 309 × 63 radius 32 at y 554 + 0.45 e; chips 149 × 49 radius 24 at CTA + 77 *(future scope)*. "Home · today" (`S-06b`) is the same composition without the future-scope items: card height 300, CTA below the card.

**Column tutorial** — the Play layout with the periwinkle ghost (48 pt ring + up/down chevrons) over the tutorial cell and a glass hint pill (300 × 54) in the HUD zone.

## 7. Component Blueprint

| Component | Purpose / spec |
| --- | --- |
| Glass card | container: `linear-gradient(155°, rgba(60,74,134,.50), rgba(22,30,64,.58))`, 1 px `rgba(255,255,255,.10)` edge, shadow `0 24 60 rgba(2,4,16,.35)` + inset top highlight; stats variant "slate" `rgba(46,64,84,.58) → rgba(17,25,40,.66)` |
| Board card | darker glass `rgba(22,30,64,.86) → rgba(9,14,36,.88)`, radius 34, top periwinkle light line |
| Tile | radius 33 %, face `#FFFCF7 → #F0E9DC`, glyph Space Grotesk 500 at 38 % of tile, ink `#141826`, shadow `0 7 16 rgba(2,4,16,.45)`; states in §8 |
| Target-rail tile | 36 × 42, fill `#2B2B58 → #242349`, 1 px `rgba(150,160,235,.32)` inner edge, glyph `#F4F6FF` |
| Primary CTA | full-width pill, `#E2FB78 → #D3F04F`, ink `#0B1020`, Manrope 500 16, trailing arrow icon; **Home:** lime glow `0 18 50 rgba(208,239,88,.26)`; **Result:** neutral shadow only (one-glow rule) |
| Secondary | outline pill 1 px `rgba(255,255,255,.18)`, text `#F4F6FF` — or a muted text link (`#AEB4CA`) as in the reference; disabled = 45 % opacity and "· yakında" |
| Badge | pill, olive glass `rgba(150,180,50,.26) → rgba(90,120,30,.24)`, 1 px `rgba(208,239,88,.42)`, sparkle icon + caps label lime `#D0EF58` |
| Moves card | 60 × 63 glass `rgba(120,132,196,.34) → rgba(70,80,140,.30)`, numeral Space Grotesk 500 22, "HAMLE" caps 9.5 (→ raise to ≥ 11 in Phase D) |
| Undo pill / restart / back / settings | glass `rgba(255,255,255,.075)`, 1 px `rgba(255,255,255,.07)`; icons 20–21 pt; undo carries the quota as lime dots |
| Stat card | slate glass, three cells, 1 px dividers `rgba(255,255,255,.10)`, values Space Grotesk 500 24 tabular, labels caps 10.5 |
| Loop track | rounded-square numbered nodes joined by a lime → periwinkle line; done = lime, current = periwinkle + halo |
| Star | outline `rgba(244,246,255,.55)`; earned = filled lime `#D0EF58` (no glow) |
| Wordmark | "Looplet": Space Grotesk 500, −0.01 em, `Loop` `#F4F6FF` + `let` lime `#DDFA6B` (final drawn asset: Phase D) |

## 8. State Design

| State | Design |
| --- | --- |
| Tile · normal / inactive | cream tile; inactive rows (during a drag) drop to 42 % opacity so the navy card shows through |
| Tile · **active (dragged) row** | cream + 2 px periwinkle `#A8B4F9` rim + `0 0 26 rgba(168,180,249,.6)` glow + deeper shadow (lift), periwinkle rails at the row's card edges, wrap ghost at 30 % opacity, rest dimmed — *never lime* |
| Tile · **winning** | lime `#E3FB7E → #CDEB4B`, glyph `#0B1020`, the **single glow** `0 10 26 rgba(208,239,88,.34)` (+ bloom) |
| Tile · **locked pivot** | indigo `#4149A0 → #2B3170`, glyph `#F4F6FF`, 1.5 px inner rim, **lock icon** top-right (non-colour cue) |
| Tile · **frozen** | ice `#DFF1FB → #B5D6EC`, 1.5 px dashed `#3C6E9B` border, **snowflake icon**; thaw = becomes a normal tile (existing behaviour) |
| Ghost slot | dashed lime `rgba(221,250,107,.5)` outline, `rgba(221,250,107,.05)` fill — the vacated home of the winning row |
| Undo · enabled / disabled | full / 55 % opacity; quota dots lime |
| Result · perfect | badge `HARİKA`, three earned stars, primary = "Sonraki bölüm", link = "Tekrar oyna" |
| Result · new best | badge `YENİ EN İYİ`, earned stars as scored, primary = "Tekrar oyna", link = "Sonraki bölüm" |
| Result · non-perfect | no badge, primary = "Tekrar oyna", link = "Sonraki bölüm" (F04 CTA weighting kept) |
| Result · Next not wired | link disabled: "Sonraki bölüm · yakında" |
| Load error / empty / recovery (F03 load error, F08 recovery) | same ground and glass card, headline in Space Grotesk, one primary pill (retry) — to be rendered in Phase D per surface (not in this handoff) |
| Focus / pressed | pressed = tile scale 0.98 + brighter edge (existing behaviour); focus ring (accessibility keyboards) = 2 px periwinkle |

## 9. CTA Hierarchy

* Primary: the lime pill (Result: the action the F04 weighting chooses; Home: continue).
* Secondary: the outline pill or muted text link.
* Tertiary: back chevron / system back (Result and Play), undo and restart (Play).

## 10. Visual Direction

### Rendered Alternatives (round 1 and 2)

* **Direction A — Backlit Stage** (rejected): `design/A-*.png`, `sheet-A.png`. **Direction B — Gazette** (rejected): `design/B-*.png`, `sheet-B.png`. **Direction C — Loop Glass** (selected): `design/C-*.png`, `sheet-C.png`, parity comparisons `parity-1/2/3-*.png`. The three differ in ground, type, edge language, accent system and motion, not only colour — see `design-foundation.md` §4, §5, §17.

### Background

Deep navy `#0A1030 → #070C25 → #050A1E` (top → bottom) with a soft light at the top right (`radial 75 % × 40 % at 90 % 6 %, #2D3766 → transparent`) and a faint teal spill at the left middle (`rgba(26,88,96,.32)`). No texture.

### Color

Roles and hex values: `design-foundation.md` §17.2 and `design/S-91-components.png`. Semantic separation (fixed): **lime = resolution, emphasis word, primary action, earned star**; **periwinkle = where you are / the active row / the current node**; **cream = the tile**; indigo = locked; ice = frozen.

### Typography

Space Grotesk 500 for display, headings, tile glyphs and numerals (`tnum` on); Manrope 500–600 for body, labels and CTAs. Scale (pt at 358, ×s): display 33/1.13, headline 28/1.16, stat 24, CTA 16, body 14.5, caption 11–11.5 caps (+0.2 em), tile glyph 38 % of tile. Both OFL 1.1, licences in `design/src/fonts/OFL-*.txt`. **Turkish casing:** `İ ı Ş Ğ Ç Ö Ü` proven in `C-90-specimen.png`; never use locale-blind uppercasing — keep authored uppercase strings (`HARİKA`, `YENİ EN İYİ`, `OPTİMAL`, `SEVİYE`) or `tr`-aware casing.

### Surface / Depth

Glass cards on the navy ground; depth only for hierarchy (lifted row, answer row, cards). No backdrop blur (F03 §18 performance clarification): glass is a gradient + edge + shadow. **One glow rule:** on the Result the only luminous element is the lime answer row (+ its bloom); stars and the Result CTA are non-glow. Home keeps the CTA glow.

### Motion / Feedback

See §11.

## 11. Motion spec — board → full-screen result

`design/src/S-transition-prototype.html` is an **executable prototype** of the sequence (open it in a browser; `?rm=1` = reduced motion, `?t=<ms>` = a frozen frame). The stills `S-08…S-14` (and `S-15/16` reduced) are frames taken **from that animation** at the stated times. Timeline (ms from T0, the settle that solves the puzzle):

| Window | Element | Motion |
| --- | --- | --- |
| 0–210 | winning row | tiles fill lime left → right, 30 ms stagger, 90 ms each (linear) |
| 100–450 | row bloom | soft lime radial, opacity 0 → 1 → 0.55 |
| 0–200 | rest of the board + chrome | dim to 50 % (ease-out) |
| 600–840 | answer row | glides from its board position to its Result position (`cubic-bezier(.22,1,.36,1)`), tile size 57.1² → 57.6 × 64.8, radius 33 % → 24 pt |
| 600–840 | board, target rail, HUD, header | fade 50 % → 0 |
| 680–860 | back button, badge, headline | fade + rise 12 pt (ease-out) |
| 720–900 | subtitle | fade + rise |
| 780–940 | stars row, stats card | fade + rise |
| 820–940 | CTAs | fade + rise |
| **940** | **rest** — inside the F03 §16 budget (≤ 940 ms) | |
| 940–1300 | stars | each earned star fills with a 140 ms pop (scale 0.6 → 1.18 → 1), 110 ms apart; a rest-state reveal |

Interruption: the sequence is non-interactive (input locked); leaving the app mid-sequence resolves to the rest state deterministically (same rule as F03 §12).

**Reduced motion** (OS Reduce Motion, iOS `reduceMotion` or Android `disableAnimations`, via the shared `reduceMotionRequested()`): the winning row is lime and static from T0; hold 300 ms; 160 ms cross-fade of board + row to the Result; Result content fades in 200 ms (460–660); stars are static; **total 660 ms** — identical to the shipped F03 §16.2 reduced timeline.

**Audio / haptic:** language intent only (F11 not scheduled): soft tick per shift, light haptic on settle, success haptic on resolution; nothing depends on sound or haptics. **Limits:** the prototype is HTML/CSS (Blink), not Flutter; a Flutter motion prototype and runtime parity are Phase D.

## 12. Screen / State / Viewport Matrix

| Screen | State | Viewport / Device | Source Artifact | Critical Assertions |
| --- | --- | --- | --- | --- |
| Play | idle (with hint / today) | 393 × 852 | `S-01`, `S-01b` | board card 86 % width; tile 57.2; hint only when F09 exists |
| Play | row lifted (AC9) | 393 × 852 | `S-02` | active row = cream + periwinkle rim + rails; rest 42 %; wrap ghost |
| Play | locked + frozen | 393 × 852 | `S-03` | lock icon + indigo; snowflake + dashed ice; readable in greyscale |
| Result | perfect / new best / 2★ | 393 × 852 | `S-04`, `S-04b`, `S-05` | back button present; answer tiles at the stated position; stars earned = filled |
| Result | transition frames | 393 × 852 | `S-08 … S-14`, reduced `S-15`, `S-16` | timings as §11 |
| Home | design (future items) / today | 393 × 852 | `S-06`, `S-06b` | wordmark `Looplet`; nodes never overlap or sit under a card |
| Column tutorial | overlay | 393 × 852 | `S-07` | ghost visible; hint readable |
| Play, Result | device variants | 390 × 844, 440 × 956 | `S-v-16e-*`, `S-v-promax-*` | no clipping; extra height distributed per §6 |
| Components / tokens | — | sheet | `S-91-components.png` | token, state and component reference |
| Loading / error / recovery, OS text scale, Android | — | — | **not rendered** | Phase D per surface (stated limit) |

## 13. Accessibility / Ergonomics

* **Touch targets:** back / settings / restart squares 40 pt at 358 = 43.9 pt at 393 (target ≥ 44: use 44 in Flutter); CTAs 56–64 pt; undo pill 50 pt.
* **Contrast (computed):** muted labels `#AEB4CA` on glass 5.9 : 1, on navy 9.0 : 1; text `#F4F6FF` on navy 17.2 : 1; lime ink on lime 15.9 : 1; ink on tile 16.6 : 1 (`C-90-specimen.png`). The reference's own labels were measured at 5.6–9.6 : 1.
* **Non-colour cues:** active row (lift + rails), winning (position + drawn ghost slot + glow), locked (lock icon), frozen (snowflake + dashed border), earned star (filled vs outline).
* **Screen reader:** unchanged semantics (board label, star group "N / 3 yıldız", ring/track "N / 30 seviye tamamlandı"); the Result back button label is **"Ana ekrana dön"**; the answer row is announced once by the Result (decorative duplicates excluded).
* **Reduced motion:** §11; **text scale:** F03 §16.5 rule stays (no clipping up to accessibility sizes) — verify at runtime.

## 14. Frontend Handoff Notes

* **Guardrails:** implement from tokens, not from screenshots; one theme layer (extend `PlayTheme` or replace it) shared by F03/F04/F05/F08 screens; no hard-coded colours in widgets.
* **Assets:** bundle Space Grotesk (variable, ≈ 133 KB) and Manrope (variable, ≈ 161 KB) — `pubspec.yaml` fonts, no network loading, no system-font fallback in shipped surfaces; draw the icon set as vector (CustomPainter / bundled SVG — Frontend decides) replacing the six `Icons.*` uses (chevron_left, undo, refresh, push_pin, unfold_more, error_outline) with: back, sliders, flame, sparkle, star, undo, restart, arrow-up-right, arrow-right, lock, snowflake, up/down chevrons. The wordmark is text-set until the final drawn asset exists.
* **Intentional deviations from the user's reference (each is deliberate):** Turkish casing fixed (`İ`); earned stars filled; nodes evenly spaced and not covered; wider info-card text; active row = periwinkle rim (lime literal variant `C-02b` exists); Result CTA and stars carry no lime glow (one-glow rule) — *the user may veto this last one, which would need a contract change*.
* **Future-scope items** (settings button, streak chip, stars chip, level-info card, gesture hint): shown in `S-06` / `S-01`, **not implemented** until their features exist (F10, F07, an aggregate-stars decision, F05 level metadata, F09); implement the "today" compositions (`S-06b`, `S-01b`) first. Reference copy is *proposed copy*; final Turkish copy stays with the PO / localization.
* **Non-goals:** no change to game logic, scoring, persistence, F03 §12 lifecycle, or the timeline budget.
* **Parity tolerance:** layout within ±2 pt, colour within ΔE 3 of the token, font metrics per Skia (Blink text metrics differ slightly); forbidden substitutions: default system font, Material icons, glow on the Result CTA/stars, lime for the active row, locale-blind uppercasing, backdrop blur.

## 15. QA Attention Points

* Active row is not lime; only the answer row glows on the Result; earned stars read as earned; the Result has a working way home (chevron + system back); `İ` cases correct; wordmark `Looplet`; labels ≥ 4.5 : 1 on glass; locked/frozen readable without colour; reduced-motion path is 660 ms and static; first-frame parity with `S-*` on the canonical simulator (iPhone 16 393 × 852) with runtime screenshots and, for the transition, a screen recording.
* Premium fail conditions to watch: default font/icons surviving, isolated visual language on any surface (F08 recovery screens), colour-only states, unexplained deviation from a `selected-source`.

## 16. Provisional Self-Review (advisory — cannot pass the gate)

| Dimension | Score | Note |
| --- | --- | --- |
| 1 Experience Fit | 9 | the user's style, friendly and clear |
| 2 Visual Hierarchy | 9 | one focal object per screen |
| 3 Layout, Rhythm, Responsiveness | 9 | scaled layout; taller frames distributed; OS text scale unrendered |
| 4 Typography and Content Craft | 9 | two OFL families, casing rule proven |
| 5 Color, Surface, Asset System | 9 | measured palette, computed contrast, drawn icons |
| 6 Interaction, State, Feedback | 9 | every state has a non-colour cue |
| 7 Motion and Sensory | 8 | an executable HTML prototype exists; Flutter prototype pending |
| 8 Originality and Product Identity | 8 | current recipe; identity rests on the loop track, swirl arcs, `Looplet` |
| 9 Accessibility and Inclusive | 9 | contrast measured; 43.9 pt targets to lift to 44 |
| 10 Implementation Fidelity and Polish | 8 | unbuilt; Blink renders |

* Total: **87 / 100** (provisional). Lowest dimension: Motion / Originality / Fidelity — 8 / 10. Fail conditions: None known (advisory).

## 17. Assumptions and Needs Tech Lead Clarification

**Contract amendments implied by the selection (not applied here; logged as DESIGN-ADOPTION-CONTRACT-AMENDMENTS):** F03 `architecture.md` §18 and `ui-design.md` §16 (won composition → full-screen result; timeline keeps its budget and intent); F04 `architecture.md` / `ui-design.md` (no Close; a visible way home; tests that reference `Kapat`); F05 home composition and copy.

**Proposals for the Tech Lead / user to accept or veto:**
1. The visible exit on the Result is a **back chevron (top-left, same glyph as Play)** plus system back / edge swipe — the user removed the Close *button*; a way home is still required.
2. **One-glow rule** on the Result (CTA and stars non-glow) deviates from the user's reference (which glows) — keep, or amend the contract.
3. The **"HAMLE" caption is 10.4 pt** at 393 pt; raise to ≥ 11 in Phase D.
4. **Data-driven subtitle** ("Hedef üç hamlede yerine oturdu.") needs count-aware Turkish copy — PO / localization.
5. Restart while on the Result ("Tekrar oyna") replaces the shipped in-place Retry fade; the F03 §16 exits are to be re-specified at the rework activation.

**Limits stated:** HTML/CSS renders and prototype (Blink), not Flutter; no OS-text-scale, loading/error/recovery or Android renders; typography identified by visual match; dark/light companions not rendered.

## 18. Visual Evidence Manifest

Source revision for every record: HEAD `cc7fe3f` + uncommitted working tree (generators `design/src/gen.mjs`, `gen-c.mjs`, `gen-s.mjs`; HTML/CSS rendered with headless Chrome, devicePixelRatio 2; specimens/sheets at 1). Captured By: UI Designer. Captured At: 2026-09-21. **Generated design artefacts, not app runtime captures.**

| Evidence ID | Kind | Screen / State | Viewport / Device | Artifact | Source Revision | Captured By | Captured At | Result / Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| DR-A-01 | direction-render | Direction A · Play idle (rejected) | 393×852 | features/f00-design-foundation/design/A-01-play-idle.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | rejected by the user |
| DR-B-01 | direction-render | Direction B · Play idle (rejected) | 393×852 | features/f00-design-foundation/design/B-01-play-idle.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | rejected by the user |
| DR-C-01 | direction-render | Direction C · Play idle (selected direction) | 393×852 | features/f00-design-foundation/design/C-01-play-idle.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | selected |
| REF-1…3 | canonical-reference | user's reference: Home / Play / Completion | 716×1434 | features/f00-design-foundation/design/reference/user-ref-1-home.png, user-ref-2-play.webp, user-ref-3-completion.webp | user-supplied 2026-09-21 | User | 2026-09-21 | source of the visual language |
| PC-1…3 | parity-comparison | reference vs Direction C | 716×1434 | features/f00-design-foundation/design/parity-1-home.png, parity-2-play.png, parity-3-completion.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | deviations D1–D11 (design-foundation §17.8) |
| SS-01 | selected-source | Play · idle (design, with hint) | 393×852 | features/f00-design-foundation/design/S-01-play-idle.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | final decision set |
| SS-01b | selected-source | Play · idle (today, no hint) | 393×852 | …/design/S-01b-play-idle-today.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | first implementation target |
| SS-02 | selected-source | Play · row lifted (AC9) | 393×852 | …/design/S-02-play-lifted-row.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | periwinkle rim |
| SS-03 | selected-source | Play · locked + frozen | 393×852 | …/design/S-03-play-locked-frozen.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | — |
| SS-04 | selected-source | Result · perfect | 393×852 | …/design/S-04-result-perfect.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | full screen, back chevron, EN İYİ |
| SS-04b | selected-source | Result · new best | 393×852 | …/design/S-04b-result-new-best.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | — |
| SS-05 | selected-source | Result · 2★ | 393×852 | …/design/S-05-result-two-star.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | Retry primary |
| SS-06 | selected-source | Home · design (future-scope items shown) | 393×852 | …/design/S-06-home-design.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | `Looplet` wordmark |
| SS-06b | selected-source | Home · today (shipped scope) | 393×852 | …/design/S-06b-home-today.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | first implementation target |
| SS-07 | selected-source | Column tutorial | 393×852 | …/design/S-07-tutorial-column.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | — |
| SS-V | selected-source | Play idle + Result perfect on 16e and Pro Max | 390×844, 440×956 | …/design/S-v-16e-*.png, S-v-promax-*.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | — |
| SS-91 | selected-source | component + token sheet | 1240×1500 | …/design/S-91-components.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | token/state reference |
| SS-90 | accessibility | glyph / tabular / icon / contrast specimen | 786×1180 | features/f00-design-foundation/design/C-90-specimen.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | — |
| MP-1 | motion-prototype | board → full-screen result (executable, `?rm=1` reduced, `?t=` frame) | 393×852 | features/f00-design-foundation/design/src/S-transition-prototype.html | cc7fe3f + working tree | UI Designer | 2026-09-21 | HTML/CSS animation; Flutter prototype = Phase D |
| MP-2 | motion-prototype | timed stills 0/150/600/720/840/940/1400 ms | 393×852 | …/design/S-08…S-14-transition-*.png, sheet-S-transition.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | frames taken from MP-1 |
| MP-3 | motion-prototype | reduced-motion stills 300 / 660 ms | 393×852 | …/design/S-15-*.png, S-16-*.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | frames taken from MP-1 (`rm`) |
| SS-CMP | selected-source | contact sheet | mixed | …/design/sheet-S.png, sheet-S-transition.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | composites of the records above |
