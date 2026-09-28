# F03 — puzzle-play-session: UI Design Handoff

> **Phase D1 — "Loop Glass" Play** (task F03-UI-D1, UI Designer, 2026-09-27; contract `architecture.md` §19; Visual Scope `existing-parity`).
>
> **Authority chain:**
> 1. `project-authority/design-foundation.md` — Selected: Direction C, with the user's decisions in §18.
> 2. `features/f00-design-foundation/ui-design.md` — tokens, components, states, §6 Play layout, §10 visual direction, §13 accessibility.
> 3. This handoff.
> 4. Frontend.
>
> Mandatory references: `design/design-doctrine.md`, `design/premium-ui-rubric.md`, `design/visual-quality-gate.md`.
>
> **What changed.** §1–§14 are rewritten for the Loop Glass Play surface and supersede the Direction A ("Backlit board on a dark stage") handoff for every non-`won` state: idle, drag, special tiles, HUD, back, target rail, loading, load error, and the F05 column-tutorial overlay (cross-feature, architecture §19.5). The pre-D1 text (F03-UI and F03-UI-WON) is in git history: this file last changed at `a136a9b`.
>
> **What stays.** §16 `Won composition` (F03-UI-WON, 2026-09-20) is kept verbatim. It remains the authority for the won moment until Phase D2 replaces it with the full-screen result. During D1 the won moment keeps its shipped look — the accepted hybrid period (architecture §19.3 (6)).
>
> **Unchanged interaction contract** (`architecture.md`): §6 state machine, §7 gesture mapping, §8 MOVES / Undo / Restart, §9 persistence, §11 timing and input lock, §13 routes.

---

## 1. Feature Summary

The single screen where LOOPLET is played. The player slides whole rows or columns of a 5×5 letter grid — circular, wrap-around, one cell per move — until the target word forms in one row, in as few moves as possible.

**What D1 does:**
* Rebuilds every non-`won` Play state on the Selected Foundation, using components that already exist in `app/lib/design`.
* Fixes four shipped defects:
  * **A-1:** the tutorial hint no longer overlaps undo and restart.
  * **A-2:** board glyphs no longer overflow at the largest text size.
  * **A-5:** the frozen tile gets a non-colour cue and a real thaw.
  * **A-6:** the tutorial ghost no longer plays under the finger.
* Keeps the interaction contract as it is.

**Primary user intent:** manipulate the board. The board is the interface; goal, move count, undo and restart are support.

## 2. Design Direction

`existing-parity` — no new exploration.

### Direction A — "Backlit Stage" (rejected)
* **Character:** a near-black stage, an amber resolution colour and cyan drag energy — the shipped look.
* **Renders:** `features/f00-design-foundation/design/A-01…A-10`, `sheet-A.png`.
* **Status:** rejected by the user on 2026-09-21 ("not modern, not the style I expect").

### Direction B — "Gazette" (rejected)
* **Character:** paper and ink.
* **Renders:** `features/f00-design-foundation/design/B-01…B-10`, `sheet-B.png`.
* **Status:** rejected by the user on 2026-09-21.

### Recommendation and Selection Record
* **Selected: Direction C "Loop Glass"**, by the user on 2026-09-21 (decision `F00.FOUNDATION-SELECTION`; decision set in design-foundation §18). Its tokens and components are implemented in `app/lib/design` (F00, Done).
* **Visual Scope `existing-parity`:** set by the Tech Lead on 2026-09-27 (architecture §19.2).
* **Canonical references** (selected-source): `S-01b` (Play today), `S-02` (row lifted), `S-03` (locked + frozen), `S-07` (column tutorial), `S-91` (components) and the `S-v-*` device variants.
* **D1 renders:** extend these references to the states they did not show (§12b). They contain no new visual language.
* **Deliberate differences from the S-* renders:**
  * the level label is bound to the level (S-03 / S-07 show a placeholder `SEVİYE 05`);
  * the future-scope hint line "Satırı tut · kaydır · bırak" is removed (F09);
  * `HAMLE` is 11 at 358 (12.1 pt at 393), up from 9.5 — per the design layer and the ruling of 2026-09-21;
  * restart is a 44-pt square (`GlassIconButton`).

## 3. Screen Goals

| Screen / state | Purpose | What the player does | What must be clear in the first 3 seconds |
| --- | --- | --- | --- |
| Play · idle | build the target in one row | read the goal, drag a row or column | the goal (`HEDEF DÖNGÜ` + rail), then the board (hero), then the moves count |
| Play · dragging | move one line | follow the finger, release | which line is moving (rim + rails + dimmed rest) and what wraps in (ghost) |
| Play · locked / frozen / thaw | respect the pivots | route around them | which tiles don't move, and why (lock / snowflake icons) |
| Play · column tutorial (L4–6) | learn column moves | drag any column | the hint text and which cell to try, while undo and restart stay usable |
| Play · loading | nothing to do | wait (usually under 100 ms) | the board is coming; the layout will not jump |
| Play · load error | recover | go home | this puzzle failed; one clear way out |

## 4. UX Flow Direction

* **Entry** (architecture §4, unchanged): Home CONTINUE, Result Next or Retry, a resume after a kill, or the debug chips.
  * The route resolves the puzzle: **loading** → **idle**, or **load error**.
  * On resume the board appears in its restored state; there is no replay animation.
* **Drag:**
  1. **touch-down** — the tile presses;
  2. **axis recognized** (architecture §7) — the line lifts: rim, glow, rails, rest dimmed;
  3. **tracking** — the line follows the finger 1:1, and the wrap ghost enters from the trailing edge;
  4. **release** — either the move is applied (settle to one stride, `HAMLE` +1) or it is sub-threshold / rejected (the line returns).

  Input is locked through the settle (AC5). A settle that forms a valid ≥ 4-letter run in a frozen tile's row thaws it (180 ms). A settle that solves the puzzle hands over to §16 (won; legacy look in D1).
* **Undo / restart:** an existing 120 ms grid swap. Undo spends a quota dot; restart refills the dots and has no dialog (AC7).
* **Tutorial (levels 4–6, until acknowledged):**
  * The hint pill sits between the board and the HUD; the ghost ring loops on the tutorial cell.
  * Touch-down hides the ghost. A row move keeps the tutorial, and the ghost returns after 600 ms of idle.
  * The first column move that settles dismisses it (the F05 ack is unchanged).
* **Header:** there is no system bar.
  * Top-left: the drawn back chevron plus `SEVİYE NN`. It pops to the caller, keeps the resumable snapshot, needs no confirmation (architecture §13) and hides in `won`.
  * Top-right: the `HAMLE` card.
  * System back and the edge swipe behave the same as the chevron.
* **Load error:** the chevron, or the lime pill `Ana ekrana dön` → Home. System back does the same.

## 5. Visual System

### Background Direction
* **The ground (F00 `LoopBackdrop`):** a navy gradient `#0A1030 → #070C25 → #050A1E`, a top-right light `radial 75 % × 40 % at 90 % 6 %, #2D3766 → transparent`, and a faint teal spill at the left middle `rgba(26,88,96,.32)`.
* It is static — no animated background, no texture, no blur.
* The screen avoids looking flat through three tonal layers: the ground, the darker board glass (the deepest surface, which frames the cream tiles), and the lighter chrome glass (`HAMLE` card, rail, HUD).

### Surface Direction
* **Primary surface — the board card:** darker glass `rgba(22,30,64,.86) → rgba(9,14,36,.88)`, radius 34·s, 1 px `rgba(255,255,255,.09)` edge, `0 26 60 rgba(2,4,16,.4)` shadow, and a 144·s × 2·s periwinkle top light line.
* **Secondary surfaces:**
  * `HAMLE` card — moves glass `rgba(120,132,196,.34) → rgba(70,80,140,.30)`;
  * rail tiles — `#2B2B58 → #242349` with a 1 px inner edge `rgba(150,160,235,.32)`;
  * undo pill and restart square — glass fill `rgba(255,255,255,.075)`, edge `.07`;
  * hint pill and error card — the F00 glass card gradient.
* **Depth is used only for hierarchy:** tiles `0 7 16 rgba(2,4,16,.45)`; the lifted line `0 16 26 rgba(2,4,16,.55)` plus the periwinkle glow. No backdrop blur (F03 §18 performance clarification).

### Color Direction

| Role | Token | Use on Play |
| --- | --- | --- |
| Primary text | `#F4F6FF` | rail glyphs, `HAMLE` numeral, hint text, locked glyph |
| Muted text | `#AEB4CA` | `SEVİYE NN`, `HEDEF DÖNGÜ`, `HAMLE` label, back chevron |
| Tile | `#FFFCF7 → #F0E9DC`, ink `#141826` | every normal tile |
| Active (periwinkle) | `#A8B4F9` (rim, rails, glow `rgba(168,180,249,.6)`) | the dragged line, tutorial ghost, focus ring — **never lime** |
| Lime (progress / resolution) | `#D0EF58` / `#DDFA6B` | undo quota dots, the tutorial sparkle, the error pill (`#E2FB78 → #D3F04F`) |
| Locked | `#4149A0 → #2B3170`, glyph `#F4F6FF`, rim `rgba(168,180,249,.55)` | locked pivot + lock icon |
| Frozen | `#DFF1FB → #B5D6EC`, ring `#7FB0D6`, dashes `#3C6E9B` @ 75 %, icon `#3F78A8` | frozen tile + snowflake |
| Danger | none | the load error uses the calm glass card and the `loopBreak` glyph in periwinkle — no red (an error here is rare and never the player's fault) |
| Success | none on Play | resolution belongs to the won moment (§16 / D2) |

**Measured contrast** (sRGB, WCAG):

| Pair | Ratio |
| --- | --- |
| muted on ground | 9.0 : 1 |
| muted on glass | 6.1 : 1 |
| `HAMLE` label on moves glass | 4.9 : 1 (the lowest text pair) |
| text on glass | 11.7 : 1 |
| rail glyph | 12.3 – 13.8 : 1 |
| locked glyph | 7.3 – 11.0 : 1 |
| frozen ink | 11.6 – 15.2 : 1 |
| tile ink | ≥ 14.6 : 1 |
| lime ink on lime | 14.7 : 1 |

Graphical objects:
* periwinkle rim against the board card: 8.2 : 1;
* snowflake on ice: 4.1 : 1;
* lock on indigo: 7.3 : 1;
* lime dot on the undo glass: 13 : 1;
* consumed-quota dot (25 % lime): 2.0 : 1 — decorative; the count is carried by the bright dots and semantics (§14).

### Typography Direction
* **Tile and rail glyphs:** Space Grotesk 500, `tnum`. Tile glyph = 38 % of the tile (`LoopText.tileGlyph`); rail glyph = 16.5·s.
* **Counter:** Space Grotesk 500 22·s `tnum` (`LoopText.counter`).
* **Captions:** Manrope 600, uppercase authored (never locale-blind uppercasing).
  * `SEVİYE NN` and `HEDEF DÖNGÜ`: 11.5·s, +0.2 em, line-height 1.3 (`LoopText.caption`).
  * `HAMLE`: 11·s, +0.14 em (`LoopText.label`).
* **Hint:** Manrope 500 13·s, line-height 1.2.
* **Load-error headline:** Space Grotesk 500 28·s / 1.16 (`LoopText.headline`). The error pill label is Manrope 500 16·s (`LoopText.cta`).
* **Turkish:** `İ`, `I`, `Ş`, `Ğ`, `Ç`, `Ö`, `Ü` render in both families (F00 `C-90-specimen`). `SEVİYE`, `DÖNGÜ` and tile `İ` are authored strings or content, never produced by `toUpperCase()`.
* **OS text scale (C-9, architecture §19.3 (1)):**
  * Every Play text role is bound to fixed chrome or a container, so it uses `loopCappedTextScaler` (1.3× cap). This covers the header label, caption, `HAMLE` card, rail and tile glyphs, and the hint pill.
  * The glyphs stay sized by their containers.
  * The load-error screen's text follows the OS scale to AX5; its column may scroll.
  * See §14.1 for why the hint pill is capped rather than free.
  * Renders: `D1-10`, `D1-10b`, `D1-v-16e-tutorial-text-ax5-capped`.

### Motion / Sensory Direction
The executable prototype is `design/src/D1-motion-prototype.html` (`?demo=lift|thaw|ghost`, `?rm=1` for reduced motion, `?t=<ms>` for a frozen frame). The stills `D1-M-*` and `D1-06-*` are taken from it.

| Event | Element | Motion | Reduced motion |
| --- | --- | --- | --- |
| touch-down on a tile | pressed tile | scale 0.98, 90 ms ease-out (existing) | no scale |
| axis recognized | active line | rim (2 px periwinkle + `0 0 26` glow) and the deeper shadow fade in over 90 ms ease-out; the rails fade in over 90 ms | instant |
| axis recognized | rest of the board | opacity 1 → 0.42 over 90 ms ease-out | instant |
| tracking | active line | follows the finger 1:1 (no easing, no lag); the wrap ghost is at 30 % | same (user-driven) |
| release, move applied | line | settles to one stride in 190 ms `cubic-bezier(.22,1,.36,1)`, overshoot ≤ 1.5 % (keyframe 80 % = 101.5 %); wrap ghost 30 % → 100 % | 190 ms ease-out, no overshoot |
| settle | `HAMLE` numeral | swaps to +1 at the settle (no count-up) | same |
| after the settle | rim, rails, dim | fade out over 90 ms ease-in | instant |
| release sub-threshold, or move rejected | line | returns to 0 in 140 ms `cubic-bezier(.4,0,.2,1)`; rim / rails / dim fade out over 90 ms | 140 ms ease-out |
| thaw (T0 = the thawing settle) | thawed tiles | the frozen treatment cross-fades to the normal tile in 180 ms `cubic-bezier(.2,0,.2,1)`; the snowflake scales 1 → 0.6 while fading | instant at T0 |
| thaw on the winning move | — | §16 takes precedence: no cross-fade, the tile takes the winning treatment | same |
| undo / restart | grid | existing 120 ms grid swap (unchanged); the spent quota dot dims over 120 ms | instant |
| tutorial idle | ghost ring + chevrons | the ring travels up 0.45 stride and back in a 1200 ms ease-in-out loop; the chevrons pulse opacity 1 ↔ 0.6 | static |
| touch-down during the tutorial | ghost | fades out over 120 ms; stays hidden while dragging | instant |
| release, tutorial still active (a row move) | ghost | returns after 600 ms idle, fading in over 160 ms | instant after 600 ms |
| first column move settles | hint pill + ghost | fade out over 160 ms (acknowledged) | instant |
| loading → loaded | skeleton → board | the skeleton cells cross-fade to the tiles, and rail / `HAMLE` / HUD fade in, all over 160 ms | instant |
| button pressed (back, undo, restart, pill) | control | scale 0.98 over 90 ms (`_Pressable`); fill .075 → .14 and edge .07 → .18 while pressed | fill only |

*Tech Lead checkpoint correction (2026-09-28):* the "existing 120 ms grid swap" in the undo / restart row does not exist in the shipped code — the grid swaps instantly, and D1 keeps it that way (architecture §19.9 (5)). Only the spent-dot dim is new.

* **Interruption:** input stays locked through every settle (AC5). Backgrounding mid-animation resolves to the settled state (architecture §12). A thaw that is cut short snaps to its end state.
* **Audio / haptics:** F11 is not scheduled. The intended language is a soft tick per shift, a light haptic on settle and a short "crack" on thaw. Nothing depends on sound or haptics.

## 6. Layout Structure

The layout is authored in the 358 × 717 reference and scaled by width: `s = W / 358`, and the extra height `e = H − 717 s` is distributed as `e1 = 0.3 e` above the rail and board and `0.7 e` above the HUD (F00 ui-design §6).

| Element | Reference (358) | iPhone 16 393×852 (s 1.098, e 64.9) | 16e 390×844 (s 1.089, e 62.9) | Pro Max 440×956 (s 1.229, e 74.8) |
| --- | --- | --- | --- | --- |
| Back chevron + `SEVİYE NN` | (25, 96), icon 20, gap 6 | (27.4, 105.4) | (27.2, 104.6) | (30.7, 118.0) |
| `HAMLE` card | (273.5, 75), 60 × 63 min, r 22 | (300.2, 82.3), 65.9 × 69.2 | (297.9, 81.7), 65.4 × 68.6 | (336.2, 92.2), 73.7 × 77.4 |
| `HEDEF DÖNGÜ` caption | y 172 + e1 | 208.3 | 206.3 | 233.8 |
| Rail tiles | 36 × 42, gap 8, r 14, y 197 + e1 | 39.5 × 46.1 at 235.8 | 39.2 × 45.8 at 233.5 | 44.2 × 51.6 at 264.5 |
| Board card | 308.5 × 307.5, r 34, pad 11, y 261.5 + e1 | 338.7 × 337.6 at 306.6 (86 % W) | 336.1 × 335.0 at 303.8 | 379.2 × 377.9 at 343.8 |
| Tile / gap | 52 / 6.5 | 57.1 / 7.1 | 56.6 / 7.1 | 63.9 / 8.0 |
| Board bottom | — | 644.2 | 638.8 | 721.7 |
| Undo pill | (29, 592.5 + e), 98.5 × 50, r 22 | (31.8, 715.3), 108.1 × 54.9 | (31.6, 708.4) | (35.6, 803.0) |
| Restart square | x 289, 44 × 44 pt, r 17 | (317.3, 720.7) | (314.8, 713.7) | (355.2, 811.7) |
| Board → HUD gap | — | 71.1 | 69.6 | 81.3 |

**Vertical budget of the tutorial hint pill.** The pill is centred in the board → HUD gap. Its height is two lines at 13·s × 1.2 plus 2 × 7·s of padding.

| Device | Pill height at 1.0× | Clearance each side at 1.0× | Pill height at 1.3× (icon hidden) | Clearance each side at 1.3× |
| --- | --- | --- | --- | --- |
| iPhone 16 | 49.6 pt | 10.8 pt | 59.9 pt | 5.6 pt |
| 16e | 49.3 pt | 10.2 pt | 59.5 pt | 5.1 pt |
| Pro Max | 55.6 pt | 12.9 pt | 67.1 pt | 7.1 pt |

The rule: the pill never overlaps the board card or the HUD, with ≥ 4 pt of clearance. The sparkle icon is hidden above 1.15× to keep two lines.

*Tech Lead checkpoint correction (2026-09-27):* a pixel scan of `D1-v-16e-tutorial-text-ax5-capped.png` measures 4.5 pt above the pill and 4.0 pt below it. The table's computed 5.1 pt left out the pill's 1 px border. The rule still holds, with no margin to spare. The pre-agreed fallback is in `architecture.md` §19.8 (3): padding 7·s → 5·s above 1.15× if the device run measures under 4 pt.

**Rhythm.** The screen reads as three bands:
1. the header — back + level left, the `HAMLE` card right;
2. the goal (caption + rail) and the board card, which form one visual unit;
3. the HUD — undo left, restart right; nothing in the middle (future: F09 hint line).

The whitespace above the rail and below the HUD grows with `e`, so taller phones breathe instead of stretching the board.

### App Chrome & Navigation Rules
* **System / native header:** none. The status bar stays visible (light content).
* **Custom top bar:** the back chevron + `SEVİYE NN` as one control, top-left.
  * The hit box is ≥ 44 × 44 pt, starting 16 pt from the left edge and extending past the label by 8 pt.
  * Non-Journey sources (the debug set now, Daily later) have no level number: the chevron alone.
* **Back:**
  * pops to the caller — Home for Journey (architecture §13; F05 §8 `_popToCaller` → `/`);
  * keeps the resumable snapshot and needs no confirmation;
  * is hidden from T0 (`won`, §16);
  * hardware back and the edge swipe are identical.
* **Sibling parity:** the Result (D2) reuses the same top-left back glyph and position (F00 S-04), and the load error shows the same chevron. No other in-flow screen exists yet.

## 7. Component Decisions

| Component | Code (`app/lib/design` unless noted) | Role and weight | States | Why it is not generic |
| --- | --- | --- | --- | --- |
| Header back + level | `LoopIconView(LoopIcon.back)` + `LoopText.caption` in one `_Pressable` | tertiary; muted | normal, pressed, focused, hidden (`won`) | the level lives in the control, so the only chrome carries context |
| `HAMLE` card | `MovesCard` | glanceable status; secondary glass | count, capped text | a glass token, not a label in a corner; the numeral is the only large number on screen |
| Target rail | `RailTile` ×5 + caption | the goal; paired with the board | static | indigo tiles read as a *different object* from the cream tiles — the goal is not a playable row |
| Board card | `BoardCard` | the stage; deepest surface | idle; dimmed parts during a drag | framed like a device, with a periwinkle light line at the top edge |
| Tiles | `TileFace` (normal / active / locked / frozen / inactive) | hero objects | see §8 | tactile cream faces, every special state with an icon |
| Active-line rails *(new)* | a board decoration (Frontend) | cue for the moving line | row: left and right card edges; column: top and bottom edges | makes the wrap-around axis visible at the card's rim, where the tiles wrap |
| Wrap ghost | `TileFace` at 30 %, clipped to the card | explains wrap-around | tracking → 100 % on settle | the mechanic is shown, not explained |
| Undo pill | `UndoPill` (quota dots) | tertiary action + quota | enabled, disabled (55 %), 3 / 2 / 1 / 0 left, pressed, focused | the quota is part of the control; no text counter needed |
| Restart | `GlassIconButton(LoopIcon.restart)` | tertiary; away from the grid (AC7) | normal, pressed, focused | a glass square that balances the undo pill |
| Hint pill *(new)* | glass, `LoopIconView(LoopIcon.sparkle)` | instruction, secondary | shown, fading out, capped text | sits in the gap and never covers a control (A-1 fixed) |
| Tutorial ghost *(new)* | a 48·s ring + `LoopIconView(LoopIcon.upDown)` | points at the gesture | looping, hidden while touching, static (reduced) | periwinkle — the colour of "where you are / what moves" |
| Loading skeleton *(new)* | `BoardCard` + 25 glass cells | placeholder | static | exact final geometry, so there is no jump |
| Load-error card | glass card + `LimePill` (no glow, no icon) | recovery | one action | calm glass instead of a red error; the `loopBreak` glyph carries the meaning |
| `loopBreak` icon *(new, drawn)* | `LoopIcon.loopBreak` | error glyph | — | an open loop with an exclamation — the product metaphor, not a stock alert |

**`loopBreak` path** (24-unit grid, stroke 1.8, round caps and joins; matches the `icons.dart` set):
* the open ring: `M16.25 4.64 A8.5 8.5 0 1 0 20.37 10.52` (a gap from 10° to 60°);
* the exclamation stem: `M12 8.3 v4.4`;
* the dot: a 2.6-width round-cap point at (12, 15.9).

## 8. State Design

| State | Look | Difference from normal | Feeling |
| --- | --- | --- | --- |
| Idle | `D1-00` — cream tiles on the board card; the undo pill at 55 % at 0 moves | — | calm, ready |
| Loading | `D1-11` — the board card with 25 glass cells at the final geometry, and the header with its level; no rail, `HAMLE` or HUD | no content, no spinner | "almost there" — no jump when the board arrives |
| Load error | `D1-07` — a glass card (`SEVİYE NN`, `loopBreak`, "Bu bulmaca yüklenemedi."), the lime pill `Ana ekrana dön`, and the chevron | no board | calm, with one way out |
| Empty | n/a — a puzzle always has 25 tiles | — | — |
| Success | the move settle (+1) and the thaw on Play; the won moment is §16 (legacy until D2) | — | progress |
| Disabled | undo at 0 moves or 0 quota: the pill at 55 % (`D1-00`, `D1-03`) | opacity, and dim dots when the quota is spent | clear "not now" |
| Selected / active (row) | `S-02`, `D1-M-lift-*` — cream tiles with a periwinkle rim + glow + deeper shadow; rails at the side edges; the rest at 42 %; the wrap ghost at 30 % | lift + rails + dim — not colour alone | "I'm holding this line" |
| Selected / active (column) | `D1-01` — the same, with rails at the top and bottom edges | as above | as above |
| Focused (keyboard) | `D1-12` — a 2 px periwinkle ring at the control's radius (back, undo, restart, pill) | shape ring, no layout shift | accessible without touch |
| Pressed | `D1-04` — scale 0.98, fill .14, edge .18 | size + brightness | responsive |
| Locked | `D1-05` — indigo + rim + lock icon | colour + icon + rim | "this one stays" |
| Frozen | `D1-05` — ice + dashed border + snowflake | colour + dashes + icon | "this one is stuck — for now" |
| Thaw | `D1-06-t000/t090/t180` — a 180 ms cross-fade to normal | transition | "it melted" |
| Undo quota | `D1-02` (2 left), `D1-03` (exhausted) | bright vs 25 % dots, plus semantics | budget awareness |
| Tutorial | `D1-08` — pill above the HUD, ghost on the cell; `D1-09` — ghost hidden while dragging, pill stays; `D1-M-ghost-*` | added layer; HUD usable | guided, not blocked |
| Text at the cap (AX5) | `D1-10`, `D1-10b`, `D1-v-16e-tutorial-text-ax5-capped` — all Play text at 1.3× | larger labels, the same geometry | readable, stable |

## 9. Premium Differentiators

1. **The wrap is shown, not explained.** A 30 % ghost tile enters from the trailing edge, clipped to the card, and becomes solid as the move settles.
2. **The moving line is marked by rails at the card's rim** — side edges for a row, top and bottom for a column. These are the points where tiles wrap, so the mechanic and the cue are the same shape.
3. **One accent per meaning.** Periwinkle marks "what I'm touching / where I am" (rim, rails, ghost, focus); lime is reserved for progress and resolution (quota dots, the tutorial sparkle, the Result later). The dragged line is never lime.
4. **The goal is a different object.** The indigo rail tiles cannot be mistaken for a playable row, so the goal pairs with the board without competing with it.
5. **Every special state carries a shape cue:** lock icon, snowflake + dashed border, rim + rails, filled vs dim quota dots. Nothing is colour-only, and all of it reads in greyscale.
6. **The thaw is a moment:** a 180 ms melt with the snowflake shrinking away, instead of a state flip (A-5).
7. **The tutorial never takes a control away.** The hint sits in the measured gap, and the ghost steps aside the moment the finger lands (A-1, A-6).
8. **An error screen in the product's voice:** the `loopBreak` glyph (a loop that didn't close) on calm glass with one lime way home — no red alert, no raw exception.
9. **The loading state has the final geometry,** so nothing jumps when the puzzle arrives.

## 10. Anti-Patterns to Avoid

* A lime active row (reserved for resolution, decision 1), or cyan / amber leftovers from `PlayTheme` on D1 surfaces.
* Any Material icon, the system font, or a default `FilledButton` / `CircularProgressIndicator`.
* A hint drawn over controls; a coach mark that blocks undo or restart; a ghost animating under the finger.
* Tile glyphs following the OS text scale unbounded (A-2) — or the opposite, hard-coding them so they ignore the 1.3× cap.
* A backdrop blur for the glass, or an `Opacity` on the whole board to dim it (dim the non-active tiles only).
* A thaw by state flip, a bouncing snowflake, or any extra glow on Play (the one glow belongs to the Result).
* A divider line under the rail, a "moves" text label bottom-left, or a separate quota counter.
* A red error screen, raw exception text, or English copy.
* The gesture-hint line "Satırı tut · kaydır · bırak" — that is F09, future scope.

## 11. Frontend Handoff

### 11.1 Must not break
* The interaction contract: gesture threshold and tie band, one cell per move, input lock (AC5), undo / restart semantics, snapshot write-through, routes and back.
* **Geometry (§6):** width-scaled from 358, the `e` distribution, a board card at 86 % width, restart at 44 pt.
* **Semantic colour separation (§5):** periwinkle = active and focus; lime = progress and resolution. The active line is never lime.
* **Non-colour cues** on locked, frozen, active and quota.
* **Tutorial:** the pill sits between the board and the HUD with ≥ 4 pt of clearance on all three devices at 1.0× and 1.3×; undo and restart stay usable; the ghost hides on touch-down.
* **Text scale:** the 1.3× cap on Play text (§5 Typography); tile and rail glyphs never overflow.
* **The won moment (T0 onward) stays as shipped until D2** — §16: amber row, seam, dock, F04 panel. Keep the legacy winning-row widgets (`BoardTile(winning: true)`, `docked_row.dart`) for the `won` phase only, even though the rest of the board moves to `TileFace`.
* **Reduced motion:** every motion in §5 has its reduced path.

### 11.2 Flexible
* Motion durations may vary ±20 ms within the stated curves. The overshoot may be 0.8–1.5 %.
* The ghost loop may run 1000–1400 ms.
* Rail thickness 2.5–3·s. Wrap-ghost opacity 25–35 %.
* Whether the rails and ghost are painters or widgets.
* How the capped scaler is applied (per `Text` or with a subtree `MediaQuery`), provided the result matches `D1-10`.

### 11.3 Do not cheapen
* Keep the rim's glow and the deeper shadow on the lifted line — no border-only lift.
* Clip the wrap ghost to the card interior; do not let it float outside.
* The thaw must cross-fade, not switch.
* Keep the skeleton geometry identical to the loaded board.
* The error pill is the real `LimePill`, and the `loopBreak` glyph is drawn — no stand-ins.

### 11.4 Implementation map

| Shipped | D1 |
| --- | --- |
| `play/widgets/board_tile.dart` (non-won states) | `TileFace` |
| `target_rail.dart` | `RailTile` + `LoopText.caption` |
| `moves_hud.dart` | `MovesCard` in the header |
| `undo_button.dart` | `UndoPill` |
| `restart_button.dart` | `GlassIconButton(LoopIcon.restart, semanticLabel: …)` |
| `puzzle_board.dart` card and plate | `BoardCard` + the new rails and ghost decorations (the drag logic is unchanged) |
| `play_session_screen.dart` | header, `_LoadingBoard` → the skeleton, `_LoadErrorBody` → the error card, over `LoopBackdrop` |
| `journey/column_tutorial_overlay.dart` | the hint pill + ghost ring (cross-feature; F05 behaviour unchanged) |

* **Icons** — Material → drawn:

  | Material | Drawn |
  | --- | --- |
  | `chevron_left_rounded` | `LoopIcon.back` |
  | `undo_rounded` | `LoopIcon.undo` |
  | `refresh_rounded` | `LoopIcon.restart` |
  | `push_pin` | `LoopIcon.lock` |
  | `unfold_more_rounded` | `LoopIcon.upDown` |
  | `error_outline_rounded` | `LoopIcon.loopBreak` (new, §7) |

  After D1 no Material icon remains in the shipped app.
* **Design-layer additions** (small, in `app/lib/design`; see §14.2):
  * `TileFace` and `RailTile` glyphs take `loopCappedTextScaler`;
  * the pressed fill on `_Pressable` glass controls;
  * `LoopIcon.loopBreak`;
  * the rails, ghost-ring and hint-pill widgets.
* **Strings** (`PlayStrings`; proposed copy per decision 6):
  * `HEDEF` → `HEDEF DÖNGÜ`;
  * new `SEVİYE %02d`;
  * `loadFailed` → `Bu bulmaca yüklenemedi.`;
  * new `Ana ekrana dön`.
* **Semantics:**
  * back: "Geri, Seviye 26";
  * `HAMLE` card: "HAMLE 3" (existing `MovesCard`);
  * rail: one node, "Hedef döngü: TARİH";
  * undo: "…, 2 / 3 hak" (existing);
  * the hint is announced once (polite), and the ghost is excluded;
  * load error: the headline, then the button "Ana ekrana dön";
  * loading: "Yükleniyor" if it lasts more than 300 ms.
* **`PlayTheme`** stays only for the `won` phase (§16) until D2.

### 11.5 D1 acceptance list (for Frontend and QA)

1. **Board card:** width 308.5·s (86 % of W), centred; top 261.5·s + 0.3 e; tiles 52·s; gap 6.5·s; radius 34·s; a 144·s × 2·s periwinkle top light line.
2. **Header:**
   * the back chevron at (25, 96)·s;
   * `SEVİYE NN` — 11.5·s Manrope 600, +0.2 em, `#AEB4CA` — bound to the level (two digits);
   * the back hit box ≥ 44 × 44 pt;
   * the `HAMLE` card at (273.5, 75)·s, 60 × 63·s minimum; its label ≥ 12 pt at 393.
3. **Rail:** `HEDEF DÖNGÜ` at y 172·s + 0.3 e; rail tiles 36 × 42·s at y 197·s + 0.3 e; no divider line.
4. **HUD:**
   * the undo pill at (29·s, 592.5·s + e), 98.5 × 50·s;
   * restart 44 × 44 pt at x 289·s, vertically centred on the pill;
   * no hint line (F09).
5. **Active line:**
   * the line's tiles are `TileFace.active` (2 px periwinkle rim + glow + deeper shadow); the others are at 42 %;
   * the rails are at the card edges across the line: side edges for a row, top and bottom for a column;
   * the wrap ghost is at 30 %, clipped to the card, and 100 % at the settle;
   * never lime.
6. **Special tiles:** locked = `TileFace.locked` with the lock icon; frozen = `TileFace.frozen` with dashes and the snowflake. Both are distinguishable in a greyscale capture.
7. **Thaw:** a 180 ms cross-fade (frames match `D1-06-t000/t090/t180`), instant under Reduce Motion, and §16 precedence when the thaw is also the win.
8. **Undo quota:** remaining = lime dots; consumed = 25 % lime; disabled at 55 % (0 moves or 0 quota); the semantics carry "n / 3 hak".
9. **Tutorial:**
   * the pill is centred between the board and the HUD with ≥ 4 pt of clearance on 390 / 393 / 440 at 1.0× and 1.3×;
   * undo and restart stay usable;
   * the ghost hides on touch-down and returns after 600 ms of idle;
   * the pill fades out on the first column move that settles;
   * the AC4 / AC11 behaviour is unchanged.
10. **Text scale:** no clipping, overlap or mid-word break at any OS size up to AX5. Play text is capped at 1.3×; the load-error text follows the OS scale.
11. **Motion:** timings and curves as in the §5 table; the reduced paths as listed. A screen recording shows a row lift, a column lift, a thaw and the tutorial ghost.
12. **Loading:** the board-card rect is identical before and after the load, and there is no spinner.
13. **Load error:** as in `D1-07`; the pill and system back go to `/`.
14. **Nothing legacy on D1 surfaces** — no Material icon, system font or `PlayTheme` colour — while the won moment stays legacy.
15. **Contrast:** text ≥ 4.5 : 1 (the lowest is `HAMLE` at 4.9 : 1); targets ≥ 44 pt; a 2 px periwinkle focus ring on back, undo, restart and the pill.
16. **Devices:** parity captures on the iPhone 16, 16e and Pro Max, side by side with `D1-*` / `S-*` (layout within ±2 pt, colour within ΔE 3 of the token — F00 ui-design §14).

## 12. Provisional Self-Review Against Rubric

Advisory and provisional — the independent QA scores the runtime.

| Dimension | /10 | Reason |
| --- | --- | --- |
| Experience Fit | 9 | the user's selected language applied to the core loop: calm night ground, tactile tiles, friendly Turkish; not 10 while the won moment is still legacy in D1 |
| Visual Hierarchy | 10 | one focal object per state, rendered in every frame: the board, then the lifted line, the thawing tile, the hint. The goal pairs with the board without competing; the HUD stays quiet |
| Layout, Rhythm & Responsiveness | 9 | width-scaled geometry with measured budgets on three devices and at the text cap; the 1.3× tutorial clearance on the 16e is only 5 pt |
| Typography & Content Craft | 9 | two OFL families, `tnum` numerals, Turkish casing proven, `HAMLE` at 12 pt; the copy is still proposed (PO / localization) |
| Color, Surface & Asset System | 10 | measured tokens with one role per accent; every text pair ≥ 4.5 : 1 (computed); drawn assets only, including a product-specific error glyph; depth used only for hierarchy |
| Interaction, State & Feedback | 10 | every state rendered: idle, loading, error, disabled, active row and column, focus, pressed, locked, frozen, thaw, three quota states, three tutorial states, and the text cap. Input feedback is immediate |
| Motion & Sensory Quality | 9 | an executable prototype with timings, curves, interruption and reduced paths; haptics are intent only (F11) |
| Originality & Product Identity | 9 | the loop mechanic is carried by the wrap ghost, edge rails, lime quota dots and the `loopBreak` glyph; the navy-glass recipe itself is common (F00 §17.1) |
| Accessibility & Inclusive Quality | 9 | non-colour cues everywhere, 44-pt targets, focus ring, semantics spec, reduced motion; Play text is capped at 1.3× by contract (§14.1) |
| Implementation Fidelity & Polish | 9 | the renders come from the same tokens and geometry as `app/lib/design` and the `S-*` set, with every value specified and nothing left as a placeholder; runtime fidelity is QA's to score |
| **Total** | **93** | lowest dimension 9; fail conditions: none known (provisional) |

## 12a. Screen / State / Viewport Matrix

| Screen | State | Viewport / Device | Source Artifact | Critical Assertions |
| --- | --- | --- | --- | --- |
| Play | idle | 393×852 (390×844, 440×956 via `S-v-*`) | `D1-00`, `S-01b`, `S-v-16e-play-idle`, `S-v-promax-play-idle` | §11.5 (1)–(4); undo disabled at 0 moves |
| Play | row lifted | 393×852 | `S-02`, `D1-M-lift-t0045/0400/0700/0900`, `D1-M-lift-reduced-t0045` | §11.5 (5); settle 190 ms ≤ 1.5 %; ghost → 100 % |
| Play | column drag | 393×852, 390×844 | `D1-01`, `D1-v-16e-play-column-drag` | rails top and bottom; column clipped to the card |
| Play | locked + frozen (L26) | 393×852 | `D1-05`, `S-03` | icons; greyscale-readable; `SEVİYE 26` |
| Play | thaw (L23, "SAAT") | 393×852 | `D1-06-play-thaw-L23-t000/t090/t180`, prototype `?demo=thaw` | 180 ms cross-fade; reduced = instant |
| Play | HUD — 2 left / exhausted / pressed / focus | 393×852 | `D1-02`, `D1-03`, `D1-04`, `D1-12` | §11.5 (8), (15) |
| Play | loading | 393×852 | `D1-11` | no layout jump; no spinner |
| Play | load error | 393×852 | `D1-07` | one action → `/`; `loopBreak`; no raw text |
| Tutorial | overlay | 393×852, 390×844, 440×956 | `D1-08`, `S-07`, `D1-v-16e-tutorial-hud`, `D1-v-promax-tutorial-hud` | pill clearance ≥ 4 pt; HUD usable |
| Tutorial | during a drag / dismissed | 393×852 | `D1-09`, `D1-M-ghost-t0600/1560/2400` | ghost hidden on touch; pill fades out on the first column move |
| Play, Tutorial | OS text AX5 (1.3× cap) | 393×852, 390×844 | `D1-10`, `D1-10b`, `D1-v-16e-tutorial-text-ax5-capped` | no clipping or overlap |
| Won moment | T0 onward | — | §16 (legacy until D2) | out of D1 scope |
| Android | all | — | not rendered | stated limit (ANDROID-CI-EVIDENCE) |

## 12b. Visual Evidence Manifest

**Provenance for every D1 record:**
* **Source Revision:** HEAD `7239492` + working tree (`features/f03-puzzle-play-session/design/src/gen-d1.mjs`, derived from F00 `gen-s.mjs`).
* **Method:** HTML/CSS → PNG with headless Chrome at devicePixelRatio 2 (`src/render-d1.sh`).
* **Captured By:** UI Designer. **Captured At:** 2026-09-27.
* **Nature:** generated design artefacts, not app runtime captures.
* **Content:** real Journey grids (L4, L5, L23, L26); the derived states are computed with the F02 shift rule (`sim()` in the generator).

| Evidence ID | Kind | Screen / State | Viewport / Device | Artifact | Source Revision | Captured By | Captured At | Result / Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SS-01b | selected-source | Play · idle (today) | 393×852 | features/f00-design-foundation/design/S-01b-play-idle-today.png | cc7fe3f + working tree (F00-UI-FINALIZE) | UI Designer | 2026-09-21 | canonical reference; D1 corrections in §2 |
| SS-02 | selected-source | Play · row lifted | 393×852 | features/f00-design-foundation/design/S-02-play-lifted-row.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | its hint line is future scope (F09) |
| SS-03 | selected-source | Play · locked + frozen (L26) | 393×852 | features/f00-design-foundation/design/S-03-play-locked-frozen.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | `SEVİYE 05` is a placeholder → `D1-05` |
| SS-07 | selected-source | Column tutorial | 393×852 | features/f00-design-foundation/design/S-07-tutorial-column.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | HUD placement resolved in `D1-08` (C-5) |
| SS-91 / SS-V | selected-source | components + Play idle on 16e and Pro Max | sheet; 390×844, 440×956 | features/f00-design-foundation/design/S-91-components.png, S-v-16e-play-idle.png, S-v-promax-play-idle.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | tokens and components |
| D1-00 | selected-source | Play · idle (L5, D1 corrections) | 393×852 | features/f03-puzzle-play-session/design/D1-00-play-idle.png | 7239492 + working tree | UI Designer | 2026-09-27 | `HAMLE` 12 pt; restart 44 pt |
| D1-01 | selected-source | Play · column drag (L4) | 393×852 | features/f03-puzzle-play-session/design/D1-01-play-column-drag.png | 7239492 + working tree | UI Designer | 2026-09-27 | audit missing render 1 |
| D1-02 | selected-source | HUD · undo, 2 left | 393×852 | features/f03-puzzle-play-session/design/D1-02-hud-undo-two-left.png | 7239492 + working tree | UI Designer | 2026-09-27 | missing render 2 |
| D1-03 | selected-source | HUD · undo exhausted | 393×852 | features/f03-puzzle-play-session/design/D1-03-hud-undo-exhausted.png | 7239492 + working tree | UI Designer | 2026-09-27 | missing render 3 |
| D1-04 | selected-source | HUD · restart pressed | 393×852 | features/f03-puzzle-play-session/design/D1-04-hud-restart-pressed.png | 7239492 + working tree | UI Designer | 2026-09-27 | missing render 4 |
| D1-05 | selected-source | Play · locked + frozen, `SEVİYE 26` | 393×852 | features/f03-puzzle-play-session/design/D1-05-play-locked-frozen-L26.png | 7239492 + working tree | UI Designer | 2026-09-27 | missing render 5 (two-digit label) |
| D1-06 | selected-source | Play · thaw frames t0 / t90 / t180 (L23, "SAAT") | 393×852 | features/f03-puzzle-play-session/design/D1-06-play-thaw-L23-t000.png, D1-06-play-thaw-L23-t090.png, D1-06-play-thaw-L23-t180.png | 7239492 + working tree | UI Designer | 2026-09-27 | missing render 6; frames taken from MP-D1 |
| D1-07 | selected-source | Play · load error | 393×852 | features/f03-puzzle-play-session/design/D1-07-play-load-error.png | 7239492 + working tree | UI Designer | 2026-09-27 | missing render 7 |
| D1-08 | selected-source | Tutorial · pill above the HUD | 393×852 | features/f03-puzzle-play-session/design/D1-08-tutorial-hud.png | 7239492 + working tree | UI Designer | 2026-09-27 | missing render 8 (C-5) |
| D1-09 | selected-source | Tutorial · ghost hidden during a drag | 393×852 | features/f03-puzzle-play-session/design/D1-09-tutorial-drag-ghost-hidden.png | 7239492 + working tree | UI Designer | 2026-09-27 | missing render 9 (A-6) |
| D1-10 | accessibility | Play · OS text AX5 (1.3× cap), L26 | 393×852 | features/f03-puzzle-play-session/design/D1-10-play-text-ax5-capped.png | 7239492 + working tree | UI Designer | 2026-09-27 | missing render 10 (C-9) |
| D1-10b | accessibility | Tutorial · OS text AX5 (1.3× cap) | 393×852, 390×844 | features/f03-puzzle-play-session/design/D1-10b-tutorial-text-ax5-capped.png, D1-v-16e-tutorial-text-ax5-capped.png | 7239492 + working tree | UI Designer | 2026-09-27 | pill clearance 5.6 / 5.1 pt |
| D1-11 | selected-source | Play · loading | 393×852 | features/f03-puzzle-play-session/design/D1-11-play-loading.png | 7239492 + working tree | UI Designer | 2026-09-27 | no layout jump |
| D1-12 | selected-source | HUD · keyboard focus (undo) | 393×852 | features/f03-puzzle-play-session/design/D1-12-hud-focus-undo.png | 7239492 + working tree | UI Designer | 2026-09-27 | 2 px periwinkle ring |
| D1-V | selected-source | device variants: tutorial on 16e / Pro Max; column drag on 16e | 390×844, 440×956 | features/f03-puzzle-play-session/design/D1-v-16e-tutorial-hud.png, D1-v-promax-tutorial-hud.png, D1-v-16e-play-column-drag.png | 7239492 + working tree | UI Designer | 2026-09-27 | clearance per §6 |
| MP-D1 | motion-prototype | lift + settle, thaw, tutorial ghost — executable; `?rm=1` reduced, `?t=` frame | 393×852 | features/f03-puzzle-play-session/design/src/D1-motion-prototype.html (+ D1-motion-prototype-thaw.html, D1-motion-prototype-ghost.html) | 7239492 + working tree | UI Designer | 2026-09-27 | HTML/CSS animation (Blink); a Flutter recording is Frontend's parity evidence |
| MP-D1-S | motion-prototype | stills: lift t45 / 400 / 700 / 900, reduced t45; ghost t600 / 1560 / 2400 | 393×852 | features/f03-puzzle-play-session/design/D1-M-lift-t0045.png … D1-M-ghost-t2400.png | 7239492 + working tree | UI Designer | 2026-09-27 | frames taken from MP-D1 |
| AUD-BASE | runtime-screenshot | shipped Play baseline (615e94c) | 393×852 iPhone 16 | features/f00-design-foundation/design/audit/ (AUD-RS-08…18, AUD-A11Y-02 / 05) | 615e94c | UI Designer | 2026-09-27 | the "before" for Frontend parity |

## 13. Assumptions

* **Content.** The renders use real Journey grids: L4 BALIK, L5 BULUT, L23 SOKAK and L26 TARİH. Derived states come from the F02 shift rule.
  * The L23 thaw state (`r1+ c3+ c4- c4-` → row 2 `ESAAT`, where "SAAT" thaws the frozen S) was also found by an independent search with the engine's thaw rule and the provisional dictionary. It is reachable, and it is not a win.
* **Rendering.** The renders are Blink; Flutter text metrics differ by about ±1 pt, so Frontend implements from tokens, not screenshots.
  * Flutter does not scale `letterSpacing` with the text scaler. At 1.3×, the renders slightly overstate the width of the `HAMLE` and caption labels.
* **Design-layer values.** `MovesCard`, `UndoPill`, `GlassIconButton` and `LoopText.label` keep their current values (F00 QA verified them at AX5). The consumed-quota dot keeps 25 % lime (code).
* **Hybrid period.** The won moment keeps the shipped look in D1 (C-8); D1's QA scores the non-`won` states only.
* **Copy.** New strings are proposed copy (decision 6); final Turkish copy stays with the PO / localization (F10-UI-LOCALIZATION).
* **Audio and haptics** are intent only (F11). Android is not rendered.

## 14. Needs Tech Lead Clarification

1. **The text cap applied to the whole Play screen (C-9)** — needs confirmation.
   * **The deviation.** Architecture §19.3 (1) names "the hint" and "labels outside a container" as free text that scales to AX5. On Play, every text role sits in fixed chrome or a container, so this handoff caps all of them at 1.3×, including the hint pill.
   * **Why free scaling fails at AX5 on the iPhone 16:**
     * the hint (≈ 40 pt Manrope) needs about five lines (~280 pt). That covers rows 2–4, including the ghost cell, or pushes the HUD off-screen, while Play must not scroll and the board geometry is fixed;
     * `HEDEF DÖNGÜ` would be about 400 pt wide on a 393-pt screen;
     * `SEVİYE 26` would run into the `HAMLE` card.
   * **What mitigates it:** VoiceOver reads every capped text in full, and the load-error screen keeps free text up to AX5.
   * Please confirm, or name an alternative (e.g. letting the hint card overlay the board at AX sizes).
2. **Design-layer changes inside D1.** The following need small edits in `app/lib/design` (F00 is Done). Please confirm they are in D1's Frontend scope, as a cross-feature item like the F05 overlay:
   * `TileFace` and `RailTile` glyphs take `loopCappedTextScaler` (today `TileFace` follows the OS scale, so it would overflow at AX5);
   * the pressed fill of `_Pressable` glass controls;
   * `LoopIcon.loopBreak`;
   * the rails, ghost-ring and hint-pill widgets.
3. **Consumed-quota dot contrast (informational).** At 25 % lime the consumed dot is 2.0 : 1, below 3 : 1 for graphical objects. The count is carried by the bright dots (13 : 1) and the semantics. Recommendation: keep it; 40 % would reach about 3 : 1 if you prefer.
4. **Hybrid period (informational).** There is no distribution yet (FIRST-APP-DISTRIBUTION is deferred). Running D2 right after D1 with no release in between means players never see the mixed won moment.
5. **L26 content observation (informational; content owner).** With the provisional dictionary, no word of four or more letters fits L26's frozen `O·Z` (columns 2–3 of row 2), so those tiles can never thaw — they act as permanent pivots. This is not a UI issue; F06 / F01-PRODUCTION-CORPUS may want to confirm it is intended.
6. **Header for non-Journey sources.** With no level number (the debug set now, Daily later), the header shows the chevron alone. Daily's own header belongs to F07 — please confirm.
7. **New proposed copy:** `HEDEF DÖNGÜ`, `SEVİYE NN`, `Bu bulmaca yüklenemedi.`, `Ana ekrana dön` (via `PlayStrings`; PO / localization may revise).
8. **The self-review (93) is provisional.** Runtime scoring is QA's (F03.D1-VISUAL-QA).

---

> **Legacy — authoritative for the won moment until Phase D2.** The section below is kept byte-for-byte from F03-UI-WON (2026-09-20).
> * During D1 the won moment keeps its shipped (Direction A) look — the accepted hybrid period (architecture §19.3 (6)).
> * Phase D2 replaces it with the full-screen result (F00 ui-design §11; S-04, S-05, S-08…S-16).
> * *Tech Lead checkpoint amendment (2026-09-28):* while D1 is live the docked row centres on the goal's rail tiles, which fade out beneath it. The panel keeps its 0.36 H cap, floored 16 pt under the row. The D1 header left no §16.3 free zone; architecture §19.9 (1) amends §16.3 "Dock" / "Panel cap" and §16.5 (1) accordingly.

## 16. Won composition (addendum 2026-09-20 — F03-UI-WON, post-F04)

**Why this exists.** QA (qa.md, rev 7a907dd, F03-QA-01) measured that the F04 panel rises with no delay and covers the win moment: on iPhone 16 (393×852 pt) the row centres sit at 308 / 375 / 442 / 509 / 575 pt while the panel top sits at ≈ 356 pt (non-Perfect) or ≈ 319 pt (Perfect). No panel height can keep rows 2–4 visible *where they are*, so the fix is not a smaller panel — it is moving the answer. Authority: `architecture.md §18` "Won-sequence authority" (sequencing, requirement). This section is the design that satisfies it.

### 16.1 Design direction

* **Direction A — "The answer docks" (selected).** After the win sequence, the winning row (tiles + drawn seam bar as one unit) lifts out of the board and glides *up* to a fixed **dock** between the target rail and the panel, so the finished word sits directly under the goal word it just matched. The board behind stays where it is, dimmed, its vacated row a faint outline. The panel then rises beneath. *Why strong:* the player literally sees "goal → my answer" pair up, from any row, and the panel is anchored to that pairing; one small moving object, so it is cheap to render; distance travelled is the only thing that varies by row. *Risks:* a travelling row must not read as a UI glitch (needs lift + shadow + one clean ease); vacated slot must not look broken.
* **Direction B — "Camera glide".** The whole board plate translates up so the winning row lands in the frame above the panel (rows above it slide under the target rail). *Strong:* cinematic, no copy of the row. *Risks:* up to ~340 pt of board travel would sweep 25 tiles over the target rail and top bar; needs masking; heavier repaint on mid-tier; the target rail would have to fade, breaking the "goal → answer" pairing.
* **Selected: A.** Cheaper, clearer, and it keeps the F04 idea ("the panel is anchored to the thing the player just did") true for every winning row instead of only row 0.

### 16.2 Timeline (T0 = the settle that yields `solvedThisStep`; times in ms after T0)

| t | What happens | Notes |
| --- | --- | --- |
| 0 | input locked, controls → 40 %, chevron hidden, rest of board recedes to 12 % dim (dim only, no blur) | unchanged from §8 |
| 0–150 | winning row fills amber, `ink-amber` glyphs, 1.06 lift, 30 ms L→R stagger | unchanged |
| 0–360 | 3 pt amber **seam bar** draws L→R beneath the row, soft glow | unchanged |
| 0–600 | one restrained radial bloom (~20 % peak) pulses once and is gone by 600 | unchanged; bloom stays at the row's *home* position |
| **600–840** | **dock:** row + seam translate (y only) from home to the dock, ease `cubic-bezier(0.22, 1, 0.36, 1)`; while travelling the row is lifted above the board (z-top) with a deeper shadow; at the same time the vacated slot shows the ghost | new |
| 620–840 | 40 % scrim fades in (220 ms) | scrim never before 600 |
| 680–940 | panel slides up (~260 ms, same curve) and lands as the row settles | **panel never before T0+600** |
| ≥ 940 | AT REST. F04 star reveal starts now (≤ 800 ms, F04 §4) | F04 unchanged from here |

* Input stays locked and the chevron hidden from T0 through the panel; nothing is tappable except panel controls once at rest.
* **Reduce motion (OS setting):** no stagger / bloom / travel. At T0 the row is amber with its seam already drawn; hold ≥ 300 ms; at T0+300 the row cross-fades (160 ms) to the dock while the source slot shows the ghost; scrim + panel fade in (200 ms) from T0+460; at rest ≈ T0+660.

### 16.3 Geometry — the dock and the panel cap

Terms: `H` screen height; `dividerY` = y of the hairline under the target rail; `U` = unit height of *row + seam* (tile height + ≈ 6 pt gap + 3 pt bar ≈ tile + 9). Everything is relative, not pixel-absolute.

* **Panel cap:** the panel's height is **≤ 64 % of `H`** for every variant (F04's 56–66 % band, tightened at the top) ⇒ `panelTop ≥ 0.36 H`.
* **Free zone:** `Z = [dividerY + 12 pt, 0.36 H − 16 pt]`.
* **Dock:** the row keeps its x; its y is `dockTop = (dividerY + 12) + (|Z| − U) / 2`, i.e. **centred in Z, fixed for all variants and all winning rows** (Perfect or not, so a re-win looks identical).
* Reference values (from simulator screenshots, rev 7a907dd):

| Device (pt) | tile | dividerY | U | Z | |Z| | slack | dock row top→bottom (incl. seam) | gap to panelTop (worst case = 16 + slack/2) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 390×844 (16e) | 58 | 170 | 67 | 182–288 | 106 | 39 | ≈ 202–269 | ≈ 35 |
| 393×852 (16) | 59 | 182 | 68 | 194–291 | 97 | 29 | ≈ 208–276 | ≈ 30 |
| 440×956 (16 Pro Max) | 67 | 189 | 76 | 201–328 | 127 | 51 | ≈ 227–303 | ≈ 42 |

* Travel on 393×852 (row centre → dock centre ≈ 238): row 0 −70, row 1 −137, row 2 −204, row 3 −271, row 4 −337 pt. A row always travels *upward over the rows above it*; that is intended (it is lifted).
* **Vacated slot ("ghost"):** the five home cells show a 1 pt `amber` @ 25 % outline at the tile radius (0.19 × tile) on the `plate` colour, no fill, so the board reads as "this row left", not "broken". It sits under the 12 % dim and the 40 % scrim.
* **Docked row:** scale 1.06 (as lifted), contact shadow `#000` @ 45 %, y+6, blur 16 at rest (y+10, blur 24 while travelling). The seam keeps its glow.
* **Panel spine (F04):** keep the 3 pt amber bar flush with the panel's top edge but **drop its outer glow** while a docked row is present — one glow only (the seam's). The bar now rhymes with the seam above it; the two are joined visually by the 16–40 pt of dark between them, not by a second bloom.
* **Concessions if the panel exceeds the cap** (OS text scaling up to 1.3×, longer Turkish strings), in this order and no other: (1) shrink inter-block gaps to ≥ 60 %; (2) stars to 88 %; (3) drop the `3 / 3` count line (stars already say it); (4) never clip, scroll or shrink below 44 pt the Retry / Next / Close controls or the amber word. If |Z| < U + 16 after (1)–(3), scale the docked row down to ≥ 0.8; if still short, stop and raise `Needs Tech Lead Clarification` — do not let the panel cover the row.
* No backdrop blur anywhere. The travelling row is one `RepaintBoundary` layer moved by a transform; nothing else on the board repaints during the dock (mid-tier 60 fps budget, §18 perf clarification stays).

### 16.4 States and exits

| From | Behaviour |
| --- | --- |
| **Retry** (primary) | panel slides out (~180 ms), docked row + seam fade out (140 ms), dim and scrim clear, board re-lights on the *restarted* grid, state → `idle`. The row does **not** fly home (the restarted grid no longer contains it). |
| **Next Level** (F05 primary when enabled) | route replacement carries the transition; no extra choreography. |
| **Close** | pop / go home as today; no extra choreography. |
| **Kill / relaunch during T0…rest** | unchanged contract: the `completed` snapshot was cleared at `won` (§9); relaunch shows a fresh idle board or home per F05 — nothing in this section changes persistence. |

* **Non-colour cue (accessibility):** seam bar (shape) + the *displacement* of the row to sit under the target rail + lift/shadow. In greyscale the amber/cream tiles collapse in luminance, so shape and position carry the win; the panel's text (`ÇÖZÜLDÜ` + word + stars) repeats it. The docked row is decorative: `ExcludeSemantics`; the panel announces the result.

### 16.5 Testable visibility rule (rects, not pixels — for Frontend/QA)

At rest (panel and dock animations finished), for winning row ∈ {0,1,2,3,4}, variants ∈ {first-clear, matched, newBest, Perfect}, sizes 390×844 and 440×956 (and 393×852):

1. `W` = docked row + seam rect, `P` = panel rect (including its spine), `R` = target-rail rect. `W ∩ P = ∅`; `P.top − W.bottom ≥ 16 pt`; `W.top ≥ dividerY + 12 pt`; `W` inside the safe area; all five glyphs fully unclipped.
2. `P.height ≤ 0.64 H` (so `P.top ≥ 0.36 H`).
3. At `T0 + 599 ms` the panel is not visible (offset fully off-screen or opacity 0) and the scrim alpha is 0; at `T0 + 600 ms` the dock has just begun.
4. The home row cells are ghost outlines from the dock start; no tile of the winning word remains in the board at rest.
5. Retry / Next / Close hit boxes ≥ 44 pt and fully inside the screen above the home-indicator inset; no scrolling panel.
6. With OS text scale 1.0 and 1.3 the same assertions hold (concession order in §16.3 applies).

### 16.6 Component and premium decisions

* **Docked answer row:** primary focus of the won frame — highest luminance + amber + shadow on a receded stage; the goal rail above it is the only sibling of equal meaning. Not generic: it turns a static "result card" into a spatial payoff.
* **Ghost slot, single glow, fixed dock, one travelling layer, ease shared with the panel** are the deliberate details; do not replace them with a cross-fade, a scale-to-fit or a fade of the board.
* **Anti-patterns for this moment:** panel earlier than T0+600; panel covering the row after it docks; teleporting/cross-fading the row instead of gliding (outside reduce-motion); a second bloom or spine glow; backdrop blur; scaling the whole board; per-row bespoke dock positions; showing a spinner while the panel waits for the rating read.

### 16.7 Frontend handoff for §16

* **Must not break:** T0+600 rule; fixed dock rule; ≤ 64 % panel cap; the ghost slot; the single-glow rule; reduce-motion path; input lock and hidden chevron through the whole moment; controller / persistence timing unchanged.
* **Flexible:** exact gaps within ±4 pt (12 / 16 pt), travel duration 220–260 ms and panel slide 240–280 ms within the shared curve, ghost outline alpha 20–30 %, whether the docked row is a copy or the real row layer.
* **Do not cheapen:** no `Opacity` on the whole board, no backdrop filter, no separate glow for the spine, no scroll view around the panel, no bespoke per-row offsets.

### 16.8 Self-review against the rubric (won moment only)

| Item | /10 | Reason |
| --- | --- | --- |
| Visual Hierarchy | 10 | one lifted amber object under the goal rail; everything else receded |
| Layout & Composition | 9 | goal → answer → panel column, fixed dock, measured clearances |
| Surface & Depth | 9 | z-lift, contact shadow, ghost slot, scrim tiers |
| Typography | 9 | unchanged from F03/F04 |
| CTA Quality | 9 | Retry / Next dominance untouched, now unobstructed |
| State Design | 9 | reduce-motion, Retry/Next/Close, concession order defined |
| Product Feel | 10 | the "I built that" beat now actually lands from any row |
| Modernity | 9 | restrained motion, one glow |
| Non-Generic Originality | 10 | answer docking under the goal is specific to this game |
| Implementability | 8 | needs a measured panel top and a transform layer; rules are rect-testable, concessions ordered |
| **Total** | **92** | ≥ 90 threshold; the won moment is the scope of this score |

### 16.9 Assumptions and clarification

* Measurements (tile size, `dividerY`, row centres, panel heights) come from simulator screenshots of rev 7a907dd; Frontend should read the real layout values, not these constants.
* F04 panel content order and copy are unchanged; only its height cap, timing and spine glow change here.
* **Needs Tech Lead Clarification:** none blocking. Informational: the dock replaces F04's "seam docks as panel spine" narrative with "seam stays under the docked row"; the panel keeps its spine bar without glow — confirm during reconciliation if you prefer to keep the F04 wording.

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** F03-UI-D1 — the Loop Glass Play handoff (§1–§14). Evidence:
  * 28 real renders under `design/`, covering every D1 state, device variants, the text cap and motion stills;
  * an executable motion prototype with reduced-motion paths;
  * the D1 acceptance list (§11.5);
  * the Visual Evidence Manifest (§12b).
  §16 is kept verbatim for the won moment until D2.
* **Remaining Tasks:** F03-FE-D1 (Frontend/Mobile Developer, after the Tech Lead's visual-gate checkpoint), then F03-QA-D1.
* **Blockers:** none. §14.1 (the text cap on the whole of Play) and §14.2 (design-layer edits inside D1) need a Tech Lead ruling at the checkpoint.
* **Status Suggestion:** Needs Tech Lead — visual-gate checkpoint → Ready for Implementation.

---

## 15. Sonraki Komut

```
Run Tech Lead
```
