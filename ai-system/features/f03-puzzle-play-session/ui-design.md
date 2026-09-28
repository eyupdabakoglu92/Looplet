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
> **Phase D2 (task F03-UI-D2, 2026-09-28; contract `architecture.md` §20; Visual Scope `motion-critical`).** §16 is rewritten: the win sequence on the D1 board, the board → full-screen result transition, the result in every variant, the result → Play retry transition, and every reduced path. It supersedes the F03-UI-WON `Won composition` (dock + bottom sheet, 2026-09-20; in git history at `489606d`) and, for the result, F04 `ui-design.md` (Direction A panel). §1–§14 (D1 Play) are unchanged apart from cross-references to §16.
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

  Input is locked through the settle (AC5). A settle that forms a valid ≥ 4-letter run in a frozen tile's row thaws it (180 ms). A settle that solves the puzzle hands over to §16 (the D2 win sequence and full-screen result).
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
* **The won moment (T0 onward) stays as shipped until D2** — §16: amber row, seam, dock, F04 panel. Keep the legacy winning-row widgets (`BoardTile(winning: true)`, `docked_row.dart`) for the `won` phase only, even though the rest of the board moves to `TileFace`. *(D1 history — superseded by the D2 handoff in §16, which removes these widgets.)*
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
* **`PlayTheme`** stays only for the `won` phase (§16) until D2. *(D2 removes it from the won path — §16.11.)*

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
| Won moment | T0 onward | — | §16 (D2 — §16.12a) | out of D1 scope |
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
## 16. Phase D2 — the won moment and the full-screen result (F03-UI-D2, 2026-09-28)

> **Contract:** `architecture.md` §20 (timeline §20.3 (1), input and lifecycle (2), persistence (3), layout (4), markers (5), CTA weighting (6), exits (7), C-11 (8), text scale (9), copy (10), performance (11)).
>
> **Authority chain:** design-foundation §18 (decision 2 — full screen, no board, no Close; decision 3 — `EN İYİ`; consequences 1–3) → F00 `ui-design.md` §4–§8, §11, §13 and the selected-source `S-04`, `S-04b`, `S-05`, `S-08 … S-16`, `S-transition-prototype.html` → this section → Frontend.
>
> **Supersedes:** the F03-UI-WON `Won composition` (dock + bottom sheet, 2026-09-20; git `489606d`), and F04 `ui-design.md` for the result. F04 AC1–AC10 stay the acceptance for the content.
>
> **Unchanged:** engine, scoring and star bounds, persistence (`completed` + `clearActiveSession()`, `personal_best`, the F05 unlock — all at `won`), routes, lifecycle. Presentation only.

### 16.1 Feature Summary (D2)

* **What changes:** the payoff. After the solving settle (T0) the winning row fills lime on the D1 board, the board and its chrome recede, and the answer row glides out of the board to become the centrepiece of a **full-screen result**. There is no board behind the result and no Close; the ways out are the result's back button, system back, "Tekrar oyna" (restart in place) and "Sonraki bölüm" (F05's handler).
* **Primary user intent:** feel the solve (≤ 600 ms, on the board), then read the outcome in one glance (the row, the stars, three numbers) and choose again.
* **Fixes carried:** A-2 on the result (AX5 clipping; NTLC-6), the C-4 markers, C-9 on the result, C-11 special tiles, and the C-3 wording (Close is gone).

### 16.2 Design Direction and Selection Record

The Exploration Gate for this surface closed at F00: three directions were rendered for the won moment and its motion (`A-04`, `A-08…A-10`; `B-04`, `B-08…B-10`; `C-04`, `C-04b`, `C-08…C-10` in `features/f00-design-foundation/design/`). **The user selected Direction C on 2026-09-21 and overrode the recommended bottom sheet with a full-screen result** (design-foundation §18, decision 2). D2 extends the selected-source `S-04 / S-04b / S-05 / S-08…S-16`; it does not reopen the direction.

What D2 designs that the selected source did not settle, each with a rendered alternative where it is a real choice:

| Decision | Chosen (D2) | Alternative (rendered / specified) | Why |
| --- | --- | --- | --- |
| **Re-timing on the D1 board** | chrome and board fade **600–720** (ease-in, 120 ms) before the result's headline becomes visible (700+) | S-transition fades them over 600–840 (`S-11` at 720 ms shows the headline double-exposed over `HEDEF DÖNGÜ` and the back label) | the two layouts never overlap on screen; the moving row is the only thing in both |
| **The retry transition** (new, §20.3 (7)) | **A — "the answer returns to the goal":** the lime row flies into the target rail and becomes it, then Play fades in around it (`D2-M-retry-*`) | **B — a plain dip:** result out, Play in, no travel (this is the reduced path, `D2-M-retry-reduced-t0080`) | A tells the player what "Tekrar oyna" does — same goal, from scratch — and reuses the win transition's grammar in reverse. **Proposed, not selected:** the Tech Lead confirms A or B at the visual-gate checkpoint (§16.14 (1)). |
| **Headline line break** | authored as two lines, `Döngü⏎tamamlandı.` | natural wrap (Blink and likely Skia fit it on one line at 1.0×, which moves every result anchor up ≈ 41 pt against S-04) | the S-04 composition and a stable answer-row position across widths |
| **Variant rhythm** | every variant uses the **same anchors**: the badge row is reserved even without a badge | badge-less variants move up by the badge row | the answer row always lands at the same place, so the transition and the eye are identical in every variant |

**Selection record:** direction — user, 2026-09-21 (`F00.FOUNDATION-SELECTION`, decision 2). Visible exit = back button — the Tech Lead's accepted default (architecture §20.3 (7), F00 ui-design §17 proposal 1; the user may still veto it). Retry transition A — **Pending Selection** (UI Designer recommendation).

### 16.3 Screen Goals

| Screen / state | Purpose | What the player does | First 3 seconds |
| --- | --- | --- | --- |
| Win sequence (T0 … T0 + 600) | the solve registers on the board | nothing (input locked) | "that row is it" — lime fill L→R, one bloom, everything else recedes |
| Transition (600 … 940) | carry the answer to the result | nothing (input locked) | the row leaves the board; the result assembles around it |
| Result · rest | the outcome and the next choice | read; Next / Retry / back | headline + badge → the row → stars → three numbers → one lime action |
| Result · stars reveal (940 … 1300) | earn the stars | may already tap (input is live at 940) | how many stars, one by one |
| Retry transition | restart in place | nothing (≤ 360 ms) | "same goal, from zero" — the word returns to the goal rail |

### 16.4 UX Flow Direction

1. **T0** — the solving move settles (`solvedThisStep`). `won`: input locks (board, back chevron, undo, restart, and later every result control until rest); the `ElapsedTimer` pauses; persistence runs as today (§20.3 (3)).
2. **0–600, win sequence** (board only): lime fill L→R, bloom, board + chrome dim to 50 %.
3. **600–940, transition:** chrome and board fade out (600–720), the answer row glides and morphs into the result (600–840), the result content fades and rises in (680–940).
4. **Rest at 940:** input unlocks. Stars pop 940–1300 (a rest-state reveal; tapping during it is allowed, the reveal simply completes or is cut to its end state).
5. **Exits** (architecture §20.3 (7)):
   * **"Sonraki bölüm"** → F05 `_nextLevelHandler()` (pushReplacement to N+1; level 30 → `/`, terminal). The route transition is the shipped one; D2 adds none.
   * **"Tekrar oyna"** → `retryFromCompletion()`; the retry transition (§16.5 motion) — Play at rest ≤ 360 ms.
   * **Back button** (top-left, "Ana ekrana dön") and **system back / edge swipe** → `_popToCaller` → `/`. System back is honoured at any time in `won`, including mid-sequence (the completion is already persisted).
6. **Waiting / error:** the result never waits on the rating read longer than today. If `CompletionResult` has not resolved by the time the content fades in, the stats card shows `—` for `EN İYİ` and the stars row stays in outline until it arrives (no spinner); the no-optimal fallback is §16.8.
7. **Interruptions:** backgrounded mid-sequence → resumes at the rest state (architecture §12 rule). OS kill mid-sequence → relaunch lands on Home with no active session.
8. **Header / top bar:** the Play header (back + `SEVİYE NN`, `HAMLE` card) is visible and dimmed until 600 and gone by 720. The result has **no top bar**: only its own 44-pt back button at rest (§20.3 (4)).

### 16.5 Visual System (D2)

**Background.** The same static `LoopBackdrop` as Play. The result adds one lime radial behind the answer row (`rgba(208,239,88,.13)` → 0 at 72 %, 240·s tall, centred on the row) — part of the single glow. No blur, no texture, no animated ground.

**Surfaces.** The answer tiles (`TileFace.winning`, 52.5 × 59·s, radius 24·s — the highest luminance on screen); the stats card (slate glass, `StatCard`, ≥ 74·s tall); the badge (olive glass, `LoopBadge`); the back button (`GlassIconButton`, 44 pt, radius 15·s). Depth is used only for the row (lime glow `0 10 26 rgba(208,239,88,.34)`) and the stats card shadow. **One glow** (design-foundation §18 consequence 3): the primary pill carries a neutral shadow only (`LimePill(glow: false)`), stars are flat.

**Colour roles on this surface.**

| Role | Token | Use |
| --- | --- | --- |
| Resolution | lime `#E3FB7E → #CDEB4B`, ink `#0B1020` | the winning row (board and result), the radial |
| Primary action | CTA `#E2FB78 → #D3F04F`, ink `#0B1020` | the one lime pill |
| Earned | `#D0EF58` | filled stars, the `bestIsPerfect` ★, badge label + sparkle |
| Text / muted | `#F4F6FF` / `#AEB4CA` | headline, stat values / subtitle, stat labels, link |
| Unearned / disabled | outline `rgba(244,246,255,.55)`; link at 45 % | empty stars; "· yakında" |
| Danger | none | nothing on this surface is an error |

**Measured contrast** (sRGB, WCAG; composited on the lightest ground the element sits on; `gen-d2.mjs` `contrast()`):

| Pair | Ratio |
| --- | --- |
| headline on the ground | 16.4 : 1 |
| subtitle on the ground | 8.6 : 1 |
| badge label on olive glass | 8.5 : 1 |
| answer glyph on lime (darker stop) | 14.0 : 1 |
| stat value / stat label on slate | 13.3 : 1 / 7.0 : 1 |
| CTA label on the lime pill | 14.7 : 1 |
| link on the ground | 9.4 : 1 |
| "Bu bölüm puanlanamadı." | 9.4 : 1 |
| back icon on its glass (top-light peak) | 8.4 : 1 |
| earned star / empty-star outline (graphical, ≥ 3 : 1) | 14.9 : 1 / 5.8 : 1 |
| `bestIsPerfect` ★ on slate | 11.1 : 1 |
| disabled link "· yakında" (45 %) | 2.7 : 1 — disabled controls are exempt; the state is also carried by the words "· yakında" and `Semantics` |

**Typography** (roles in `LoopText`; sizes at 358 × s):

| Element | Role | Scale rule (C-9) |
| --- | --- | --- |
| "Döngü⏎tamamlandı." | `display` 33 / 1.13, Space Grotesk 500 | capped 1.3× (container / display role) |
| subtitle | `bodyText` 14.5, line-height 1.3, muted | **free** (OS scale to AX5, wraps) |
| answer glyph | `tileGlyph`, 22·s in the result tile | capped 1.3× |
| badge label | `LoopBadge` caps 11, +0.14 em, lime | capped 1.3× |
| stat value / label | `stat` 24 `tnum` / `label` 11 caps | capped 1.3× (`StatCard`) |
| CTA label | `cta` 16, line-height 1.2 | **free** (the pill grows, `LimePill` min-height) |
| link | `link` 15.5, line-height 1.2 | **free** (hit box ≥ 44 pt) |
| no-optimal line | Manrope 500 13, muted | **free** |

All caps strings are authored (`HARİKA`, `YENİ EN İYİ`, `OPTİMAL`, `EN İYİ`, `SEN`); never locale-blind uppercasing.

**Motion / sensory direction.** Executable prototypes: `design/src/D2-motion-prototype.html` (row 2), `-row0.html` (locked tiles in the row), `-row4.html`, `-frozen.html` (synthetic), `-retry.html`; `?rm=1` reduced, `?t=<ms>` frozen frame, `?check=1` timeline self-test (result in the tab title). Every still `D2-M-*` is a frame of these pages.

**Win sequence + board → result** (ms from T0; curve `E` = `cubic-bezier(.22,1,.36,1)`):

| Window | Element | Motion | Reduced motion |
| --- | --- | --- | --- |
| 0–210 | winning row | each tile fills lime in 90 ms (linear), 30 ms stagger L→R; the glyph goes to lime ink | lime and static at T0 |
| 0–210 | lock / snowflake icons, frozen dashes, locked indigo (C-11) | covered by the fill of their own tile — they fade out with it (90 ms) | gone at T0 |
| 100–450 | bloom | one lime radial at the row's board position, 0 → 1 → 0.55 (ease-out) | none |
| 0–200 | rest of the board + all Play chrome (header, `HAMLE`, rail, HUD, tutorial pill if shown) | opacity 1 → 0.5 (ease-out) | 0.5 at T0 (a state, not a motion) |
| **< 600** | anything outside the board | **nothing appears** (asserted: max result opacity 0 before 600; the row stays inside the board card) | result appears from 300 (the contracted reduced path) |
| 600–720 | board, bloom, header, `HAMLE`, rail, HUD | 0.5 → 0 (ease-in) | 300–460: → 0 (linear) |
| 600–840 | answer row (one unit) | glides to the result slot and morphs: 57.1² r 18.8 → 57.6 × 64.8 r 26.3 (iPhone 16), glyph 21.7 → 24.2; `E` | 300–460: the board row fades out while the result row fades in (no travel) |
| 680–920 | lime radial behind the row | fade in (ease) | 300–460 (linear) |
| 700–860 | back button, badge, headline | fade + rise 12·s (ease-out) | 460–660 fade (linear) |
| 740–900 | subtitle | fade + rise 12·s | 460–660 |
| 780–940 | stars (outline) + stats card | fade + rise 12·s | 460–660; stars already filled |
| 820–940 | primary pill + link | fade + rise 12·s (120 ms) | 460–660 |
| **940** | **rest — input unlocks** | | **660 — rest** |
| 940–1300 | earned stars | pop: 140 ms, scale 0.6 → 1.18 → 1, starts at 940 / 1050 / 1160 | static |

Travel on the iPhone 16 (row top → result tile top): row 0 −9.4 pt, row 2 −137.9, row 4 −266.3 (16e −9.5 / −137.0 / −264.4; Pro Max −10.3 / −154.1 / −297.9). The glide target is the **laid-out** result slot at scroll offset 0 (measure it with a `GlobalKey`; it moves down at larger text: 339.9 pt at 1.3× on the iPhone 16, ≈ 507 pt at AX5).

**Result → Play ("Tekrar oyna"; T0 = the tap; §20.3 (7) bound ≤ 400 ms):**

| Window | Element | Motion | Reduced |
| --- | --- | --- | --- |
| 0–140 | result content, back button, lime radial | fade out + drop 8·s (ease-in) | 0–80 fade out (linear) |
| 0–300 | answer row | each tile flies to its target-rail slot (39.5 × 46.1, r 15.4 at 16), `E`; its fill cross-fades lime → rail indigo and the glyph lime ink → `#F4F6FF` (100–300); at 300 it *is* the rail | fades out with the result (0–80) |
| 160–360 | Play on the restarted grid: header (`SEVİYE NN`, `HAMLE 0`), `HEDEF DÖNGÜ`, board card (rises 10·s), HUD (undo disabled, 3 quota dots) | fade in (ease-out, 200 ms) | 80–160 fade in (linear) |
| **360** | **rest — input unlocks** (≤ 400) | | **160** |

No frame of the retry shows both layouts at full strength; the reduced path is a sequential dip (never a double exposure).

**Measured by the timeline self-test** (`design/src/timeline-check-d2.txt`, headless Chrome on the prototypes): rest 940 (rows 0, 2, 4; 393 and 390 wide), stars end 1300, first result pixel 685 ms, row inside the board card for every sample < 600, row on its slot at rest within 0.53 px; reduced rest 660; retry rest 360, reduced 160.

**Special cases:**
* **A thaw on the winning settle:** a frozen tile that thaws at T0 takes its thawed look at T0 with no 180-ms cross-fade (D1 §5 precedence); if it is in the winning row it simply fills lime with the others.
* **Tutorial active at T0** (L4–6): the hint pill and ghost belong to the chrome — they dim and fade with it.
* **Background mid-sequence:** jump to the rest state on resume. **Kill:** Home, no session.
* **Audio / haptics** (F11, intent only): a light success haptic at T0, a soft chime on the lime fill, one tick per star pop. Nothing depends on them; silent / haptics-off change nothing visual.

### 16.6 Layout Structure (result)

The result is **one vertical column** (x 24·s, width 309·s) laid out in the 358 reference, scaled by width (`s = W / 358`), with the extra height `e = H − 717·s` distributed as in S-04. At 1.0× the anchors are exactly S-04's; above 1.0× free text pushes everything below it down (the gaps are constant). The back button is **outside** the column and fixed.

| Element | Rule (358 ref) | iPhone 16 393×852 (s 1.098, e 64.9) | 16e 390×844 (s 1.089, e 62.9) | Pro Max 440×956 (s 1.229, e 74.8) |
| --- | --- | --- | --- | --- |
| Back button (fixed) | (24, 54)·s, 44 pt, r 15·s | (26.3, 59.3) | (26.1, 58.8) | (29.5, 66.4) |
| Badge row (reserved even with no badge) | top 54·s + 0.16 e, 42·s tall; pill min 112·s wide, 16·s side padding | 69.7 | 68.9 | 78.3 |
| Headline (2 lines, authored break) | top 112·s + 0.24 e | 138.5 | 137.1 | 155.6 |
| Subtitle (free text, lh 1.3) | 14.25·s below the headline (glyph line = S-04's 203·s) | 238.4 (glyph top) | 236.2 | 267.4 |
| **Answer tiles** | 38.3·s + 0.16 e below the subtitle → **258·s + 0.4 e**; 5 × 52.5 × 59·s, gap 6.5·s, r 24·s, centred | **309.2**, 57.6 × 64.8 | 306.2, 57.2 × 64.3 | 347.0, 64.5 × 72.5 |
| Stars | +32·s; 19·s, gap 14·s | 409.1 | 405.4 | 458.8 |
| Stats card | +24.5·s; 309 × ≥ 74·s, r 26·s | 456.8, 339.2 × 81.2 | 452.7 | 512.3 |
| Primary pill | +18.5·s; 309·s × ≥ 63.5·s, r 32·s, label left, arrow right | 558.4, h 69.7 | 553.5 | 626.0 |
| Link | text centre 27.25·s below the pill; hit box ≥ 44 pt tall, full column width | centre 658.0 | 652.4 | 737.5 |
| Column bottom at 1.0× | — | 679.9 | — | — |

**Fit (C-9), measured in the renders:**

| OS text | iPhone 16 | 16e | Pro Max | Rule |
| --- | --- | --- | --- | --- |
| 1.0× | bottom 679.9, 138 pt spare above the home indicator | fits | fits | no scroll |
| **1.3× (the cap)** | answer row at 339.9; bottom 710.6 → **107 pt spare** | row 336.7; **105 pt spare** | row 381.3; **128 pt spare** | **no scroll** (§20.3 (9)) |
| AX5 (≈ 3.12× free text) | content 247 pt taller than the screen; answer row at ≈ 507 (on screen at offset 0) | 246 pt; row ≈ 502 | — | the column scrolls; back button fixed; lands at offset 0 |

**Scrolling above the cap:** the column scrolls under a fixed top band (the ground colour `#0B1234` to 78 %, then a fade; height 54·s + 58 pt) that sits behind the back button, so scrolled text never collides with it. The band is invisible at offset 0. The scroll view is `ClampingScrollPhysics` (no overscroll glow, no bounce past the top that would reveal the band early); the transition always lands at offset 0.

**Rhythm:** three bands — (1) *verdict:* badge + headline + subtitle; (2) *the object:* the answer row with its glow, then the stars; (3) *numbers and choice:* stats card, one lime pill, one quiet link. The bottom ≈ 16 % of the screen stays empty at 1.0× — deliberate air, and the room the text scale needs.

#### App Chrome & Navigation Rules (result)
* **System header:** none; status bar light.
* **Custom top bar:** none. Only the back button (top-left) — `GlassIconButton(LoopIcon.back, semanticLabel: 'Ana ekrana dön')`, 44 pt.
* **Back:** → `_popToCaller` → `/` (Home). Hidden and inert until rest (it fades in 700–860 but input unlocks at 940). System back / edge swipe → the same route **at any time in `won`**.
* **Sibling parity:** same drawn back glyph as Play's header and the load error; on the result it sits in a glass square because there is no level label to anchor it (S-04). *Deliberate, recorded chrome difference from Play's bare chevron.*
* **No Close** anywhere (decision 2).

### 16.7 Component Decisions

| Component | Code (`app/lib/design`) | Role / weight | States | Why not generic |
| --- | --- | --- | --- | --- |
| Winning tile (board) | `TileFace(state: winning)` over the tile's own face (normal / locked / frozen) | hero at T0 | filling (per-tile 90 ms), lime | the fill covers special faces, so a locked or frozen tile joins the word without a special case (C-11) |
| Answer row (result) | `TileFace.winning`, 52.5 × 59·s, r 24·s, one `RepaintBoundary` layer | the focal object; the one glow | arriving (glide), rest, leaving (retry) | the same five tiles the player built travel to the result — no re-drawn "word" label |
| Bloom | a lime radial painter | one-off emphasis | 100–450 only | once, at the row, then gone |
| Badge | `LoopBadge(label: 'HARİKA' \| 'YENİ EN İYİ')` | verdict tag | shown / absent (row reserved) | text + sparkle, never colour alone; precedence rule C-4 |
| Headline | `LoopText.display`, capped | verdict | — | calm sentence, not a shouted `ÇÖZÜLDÜ` |
| Subtitle | `LoopText.bodyText` (lh 1.3), free | data | — | tells the number in words |
| Stars | `StarRow(earned: n)` + a D2 reveal (per-star pop) | earned rating | outline → filled (940–1300); static (reduced) | filled vs outline = shape cue; no glow |
| Stats card | `StatCard([SEN, OPTİMAL, EN İYİ])`, `StatCell(star: bestIsPerfect)` | the numbers | values, `—` (unavailable) | the old delta / `İLK` / "daha iyi" markers are gone; the three numbers speak |
| Primary | `LimePill(glow: false)` + `LoopIcon.arrowRight` | the one action | normal, pressed (scale .98), focused (2 px periwinkle ring), locked (pre-rest: inert) | a single lime object below the row; no second pill |
| Secondary | `TextLink(disabledSuffix: 'yakında')` | the other action | enabled, disabled (45 %, "· yakında"), focused | a quiet link, so the weighting is unmistakable |
| Back | `GlassIconButton(LoopIcon.back, semanticLabel: 'Ana ekrana dön')` | tertiary exit | normal, pressed, focused, inert pre-rest | the visible way home decision 2 requires |
| Scroll band *(new)* | a gradient box behind the back button, shown only when scrolled | legibility above the cap | hidden at offset 0 | keeps the fixed button readable at AX5 |
| Retry flight *(new)* | five tile layers interpolating result tile → `RailTile` | transition | 0–300 | the answer literally becomes the goal again |

`GhostSlot` (F00's vacated-home outline) is **not used**: the whole board leaves in D2, so there is no vacated home to show.

### 16.8 State Design

Variant logic (unchanged, from `CompletionResult`): stars from F04 AC1–AC3 / AC9 / AC10; badge **`HARİKA` iff Perfect** (wins over a new best), **`YENİ EN İYİ` iff `newBest` and not Perfect**, otherwise none (C-4); the primary is "Sonraki bölüm" iff Perfect **and** a Next handler exists, otherwise "Tekrar oyna" (§20.3 (6)).

| Variant | Render | Badge | Stars | Stats (SEN · OPTİMAL · EN İYİ) | Primary / link | Feeling |
| --- | --- | --- | --- | --- | --- | --- |
| Perfect · first clear | `D2-01` (L5) | HARİKA | 3 | 3 · 3 · 3★ | Sonraki bölüm / Tekrar oyna | top |
| Perfect + new best | `D2-02` | HARİKA (not YENİ EN İYİ) | 3 | 3 · 3 · 3★ | Sonraki bölüm / Tekrar oyna | top, one badge only |
| New best (2★) | `D2-03` | YENİ EN İYİ | 2 | 5 · 3 · 5 | Tekrar oyna / Sonraki bölüm | progress |
| First clear (2★) | `D2-04` | — (`İLK` dropped) | 2 | 4 · 3 · 4 | Tekrar oyna / Sonraki bölüm | done, room to improve |
| Matched best | `D2-05` | — | 2 | 5 · 3 · 5 | Tekrar oyna / Sonraki bölüm | steady |
| No improvement (1★) | `D2-06` | — ("daha iyi" dropped) | 1 | 8 · 3 · 4 (the retained best) | Tekrar oyna / Sonraki bölüm | honest, not punishing |
| No-optimal fallback (debug) | `D2-07` | — | none: the line "Bu bölüm puanlanamadı." in the stars slot | 3 · — · — | Tekrar oyna / Sonraki bölüm · yakında | neutral |
| Next not wired (non-Journey) | `D2-08` | per variant (HARİKA here) | per variant | per variant | Tekrar oyna / **Sonraki bölüm · yakında** (disabled) — even when Perfect | clear "not yet" |
| Level 30 · Perfect | `D2-09` (ZEMİN) | HARİKA | 3 | 5 · 5 · 5★ | **Yolculuğu tamamla** / Tekrar oyna | the end of the road |
| Level 30 · 2★ | `D2-09b` | — | 2 | 7 · 5 · 7 | Tekrar oyna / **Yolculuğu tamamla** | — |
| Rating not resolved yet | (no render; = D2-01 with `—`) | — until resolved | outline until resolved | SEN · OPTİMAL · — | per variant | no spinner, no wait beyond today |

Interaction states:

| State | Render | Look |
| --- | --- | --- |
| Pre-rest (input locked) | `D2-M-*-t0680 … t0840` | controls visible but inert; no pressed feedback |
| Focused (keyboard) | `D2-11` (back) | 2 px periwinkle ring at the control's radius; also on the pill and link |
| Pressed | `D2-12` (primary) | scale 0.98, brightness −5 % (`_Pressable`) |
| Disabled | `D2-07`, `D2-08` | link at 45 % + "· yakında"; not focusable as a button (`Semantics` enabled: false) |
| Text at the cap / AX5 | `D2-10`, `D2-10b`, `D2-10c`, `D2-v-*-text-cap-1_3`, `D2-v-16e-result-ax5-top` | §16.6 fit table |
| Win with special tiles | `D2-M-r0-locked-*` (L26, locked T and R), `D2-M-frozen-synthetic-*` | the fill covers indigo / ice; icons and dashes go with it |
| Empty / loading / error | n/a — the result exists only after a solve; a failed rating write shows `—` (no error UI) | — |

### 16.9 Premium Differentiators

1. **The word the player built is the result.** The same five tiles leave the board and become the centrepiece — no label re-typing the answer.
2. **Clean hand-over, no double exposure:** Play's chrome is gone (720) before the result's headline is visible (700 → rising), so only the travelling row exists in both worlds.
3. **Special tiles join the word:** locked indigo and frozen ice are swallowed by the lime fill in stagger order, icons fading with their own tile — the pivots become part of the answer (C-11).
4. **Retry reverses the story:** the answer flies back into the goal rail and turns indigo — "same goal, from zero" said by motion, in 360 ms.
5. **One glow, one lime action:** the row (+ its radial) glows; the pill is lime but flat; stars are flat. The eye goes row → stars → pill.
6. **Fixed rhythm across variants:** the badge row is reserved, so the answer lands at the same place in every variant, and a re-win looks identical.
7. **Stars are earned after rest:** the reveal starts when control returns, so it rewards rather than delays.
8. **Honest numbers, fewer markers:** three tabular numbers with a small lime ★ for a perfect best replace `3 / 3`, `+N`, `İLK` and "daha iyi".
9. **Accessible by construction:** the display text is capped, every sentence is free text, the column scrolls only above the cap, and a fixed band keeps the one exit readable.
10. **Level 30 is named:** the last Next says "Yolculuğu tamamla", not a dead "Sonraki bölüm".

### 16.10 Anti-Patterns to Avoid

* Any result element (badge, headline, back, radial, stars, CTA) visible before T0 + 600; a scrim; a bottom sheet; the board behind the result.
* A second glow (glowing pill, glowing stars, a spine bar); backdrop blur; `Opacity` on a subtree that repaints the board every frame.
* Teleporting or cross-fading the row outside reduced motion; scaling the whole board; per-row bespoke timings.
* Lock / snowflake icons surviving on lime tiles; a special-tile "exception" colour inside the answer.
* Re-introducing `3 / 3`, `+N` / `=`, `İLK`, "daha iyi", `ÇÖZÜLDÜ`, `YENİ REKOR`, `Kapat`, `SONRAKİ`, `Yeniden`, amber, or the system font.
* Uncapped display text (it breaks mid-word at AX5 — `LoopText.display` note); capped *sentences* (subtitle, CTA, link must follow the OS).
* A spinner or delay while the rating resolves; a Close button; a result that scrolls at or below the 1.3× cap.

### 16.11 Frontend Handoff

**Must not break**
* Timeline bounds: nothing outside the board before T0 + 600; rest ≤ 940 (reduced 660); retry rest ≤ 400 (designed 360; reduced 160). Input locked T0 → rest; taps dropped, not queued.
* System back honoured at any time in `won`; persistence / controller timing unchanged (§20.3 (2–3)).
* The layout anchors of §16.6 at 1.0× (±2 pt), the reserved badge row, the authored two-line headline, and the fit rule: no scroll up to 1.3× on 390–440 widths.
* C-4 badge precedence and markers; CTA weighting incl. "· yakında" and level 30.
* One glow; `LimePill(glow: false)`; no blur.
* C-11: the whole winning row lime; icons and frozen dashes fade with their tile's fill.
* Reduced paths exactly as specified (`reduceMotionRequested()`).

**Flexible**
* Durations ±20 ms inside each window, as long as the bounds hold; the stagger 25–35 ms.
* Rise distance 8–14·s; the bloom's peak 0.8–1.0.
* Whether the glide is one transform on a copy of the row or the real row layer; the radius morph may be a custom painter or `ShapeBorder.lerp`.
* The retry flight may use `RailTile` at the end or a cross-faded copy, if the frame at 300 equals the rail.

**Do not cheapen**
* The glide must morph size and radius (not a fade, not a scale-only); the row must travel as one unit.
* The chrome fade must finish by 720 — do not stretch it to 840 (double exposure).
* The star reveal is a pop with an overshoot, not an opacity fade; it is static under reduced motion.
* The fixed band above the cap; the ≥ 44-pt link hit box.

**Implementation map**

| Shipped | D2 |
| --- | --- |
| `play/widgets/board_tile.dart` (`winning: true`), `docked_row.dart`, the amber seam | `TileFace(state: winning)` filling over the tile face; the row as one layer; **delete** `docked_row.dart` and the seam |
| `play/won_composition.dart` (dock + panel geometry, 0.36 H cap) | a `won` orchestrator: the §16.5 timeline driving board dim / chrome fade / row glide / result entrance; the result screen as an in-screen state of `/play` |
| `rating/completion_panel.dart` (`CompletionPanel`, `_BareBody`, `_Actions`, `_CtaPill`, `_GapConnective`, `PanelDensity`) | a full-screen `ResultView`: `GlassIconButton` back, `LoopBadge`, `LoopText.display`, subtitle, answer row, `StarRow` + reveal, `StatCard`, `LimePill(glow: false)`, `TextLink`; the no-optimal line; scroll above the cap |
| `PlayTheme` on the won path | removed (`app/lib/design` only) |
| `retryFromCompletion()` | unchanged call; wrapped by the retry transition |

**Strings** (interim, §20.3 (10); `PlayStrings` / `RatingStrings`):

| Key | TR | EN (existing table) |
| --- | --- | --- |
| headline | `Döngü\ntamamlandı.` | `Loop\ncomplete.` |
| subtitle | `Hedef {n} hamlede yerine oturdu.` — `{n}` spelled `bir … on` for 1–10, digits above | `Target set in {n} moves.` |
| primary / link | `Sonraki bölüm`, `Tekrar oyna`, `Yolculuğu tamamla` (level 30) | `Next level`, `Play again`, `Finish the journey` |
| disabled suffix | `yakında` → rendered "Sonraki bölüm · yakında" | `soon` |
| badges | `HARİKA`, `YENİ EN İYİ` | `PERFECT`, `NEW BEST` |
| stat labels | `SEN`, `OPTİMAL`, `EN İYİ` | `YOU`, `OPTIMAL`, `BEST` |
| no-optimal line | `Bu bölüm puanlanamadı.` | `This level has no rating.` |
| back semantics | `Ana ekrana dön` | `Back to home` |
| removed | `ÇÖZÜLDÜ`, `Kapat`, `Yeniden`, `SONRAKİ`, `YENİ REKOR`, `İLK`, `daha iyi`, `{n} / 3` caption | — |

Turkish: `hamlede` takes no plural after a number, so one template serves every count; the level-30 label is a proposal (PO / localization, F10-UI-LOCALIZATION).

**Semantics**
* At rest, announce once (polite): "Döngü tamamlandı. Hedef üç hamlede yerine oturdu." Then the badge "Harika" / "Yeni en iyi" when shown.
* Answer row: one node, "Cevap: BULUT" (tiles excluded individually).
* Stars: `StarRow` "N / 3 yıldız" (+ ", Harika" when Perfect).
* Stats: one node, "Sen 3, optimal 3, en iyi 3" (+ ", harika" when `bestIsPerfect`).
* Buttons: "Sonraki bölüm" / "Tekrar oyna" / "Yolculuğu tamamla"; the disabled link "Sonraki bölüm, yakında" (disabled).
* Back: "Ana ekrana dön". Traversal: back → verdict → answer → stars → stats → primary → link.
* During the sequence (T0 → rest): the board and result are excluded; nothing is focusable.

#### 16.11.1 D2 acceptance list (for Frontend and QA)

1. **T0 + 0 … 599:** only the board changes — the winning row fills lime L→R (30 ms stagger, 90 ms per tile), one bloom, board and chrome dim to 50 %. No result pixel (radial, back, badge, headline, stars, stats, CTA) has opacity > 0 before 600 — video frame timing (architecture §20.6).
2. **Special tiles (C-11):** on L26 (`r0- c1+ r4+ r4+ c4+`, winning row 0 with locked T and R) the locked tiles turn lime with their neighbours and the lock icons are gone by T0 + 210; under Reduce Motion they are lime at T0. Matches `D2-M-r0-locked-t0060/t0210`.
3. **Glide:** the row travels as one unit 600–840, morphing size and radius, from rows 0, 2 and 4 (L26, L5 `c0+ c1+ c1+`, L4 `c0+ c3- r3+ c4+`) to the result slot; at rest it is on the slot within 1 pt.
4. **Chrome fade:** header, `HAMLE`, rail, HUD and board at opacity 0 by T0 + 720.
5. **Rest ≤ T0 + 940** (input unlocks); stars pop 940 / 1050 / 1160, done by 1300.
6. **Reduced motion:** row lime and static at T0; hold to 300; cross-fade 300–460; content 460–660; stars static; rest ≈ 660.
7. **Input:** taps on the board, back, pill or link before rest are dropped (not queued); system back works at any time in `won` and lands on Home.
8. **Layout at 1.0×:** the §16.6 table on 393 × 852, 390 × 844 and 440 × 956 (±2 pt); the badge row reserved in every variant; the headline on two lines.
9. **Variants:** each row of the §16.8 table renders as its `D2-0x` render — badge precedence (HARİKA over YENİ EN İYİ), no `3 / 3`, no delta, no `İLK`, no "daha iyi", the CTA weighting, "Sonraki bölüm · yakında" disabled, "Yolculuğu tamamla" on level 30.
10. **F04 AC7 content** on every rated variant: target word (the answer row), player moves, optimal, stars, personal best, Retry, Next.
11. **One glow:** only the answer row and its radial are luminous; the pill has a neutral shadow; stars flat.
12. **Text scale:** no scroll at every OS size up to the 1.3× cap on the three devices (spare ≥ 100 pt); at AX5 the column scrolls, the back button stays fixed and reachable, the scroll band appears only when scrolled, and nothing clips, overlaps or breaks mid-word; the transition lands at offset 0.
13. **Retry:** "Tekrar oyna" → the row flies into the rail (0–300), Play on the restarted grid (`HAMLE 0`, undo disabled, 3 dots) at rest by 360 (≤ 400); reduced: dip, 160. Moves 0, undo 3, restart count as today.
14. **Next / back:** "Sonraki bölüm" → N+1 (level 30 → terminal Home); back button / system back → Home. No Close exists.
15. **Accessibility:** targets ≥ 44 pt (back, pill, link); contrast as §16.5; the semantics above; focus ring on back, pill and link.
16. **Lifecycle:** background at T0 + 300 → resume at rest; kill at T0 + 300 → Home, no active session, best and unlock written.
17. **Nothing legacy on the won path:** no `PlayTheme`, amber, Material icon or system font; `docked_row.dart` and `CompletionPanel` are gone; the §20.4 test strings are updated and every F04 AC keeps a passing test.
18. **Performance:** no visible frame drops on the iPhone 16e simulator recording of the row-4 sequence (the longest glide).

### 16.12 Provisional Self-Review Against Rubric (D2)

Advisory and provisional — the independent QA scores the runtime from video.

| Dimension | /10 | Reason |
| --- | --- | --- |
| Experience Fit | 10 | the user's own decision (full screen, no Close) delivered with the payoff kept on the board first; calm Turkish verdict |
| Visual Hierarchy | 10 | one focal object at every instant: the filling row, the travelling row, then row → stars → one lime pill |
| Layout, Rhythm & Responsiveness | 9 | S-04 anchors, fixed rhythm across variants, measured fit at the cap on three devices; AX5 relies on scrolling (contracted) |
| Typography & Content Craft | 9 | capped display vs free sentences; authored caps; spelled numbers; copy still interim (PO / localization) |
| Color, Surface & Asset System | 10 | one glow, measured contrast for every pair, drawn icons, special faces resolved by the fill |
| Interaction, State & Feedback | 9 | ten variants, pre-rest lock, focus, pressed, disabled, unresolved rating; the retry transition awaits selection |
| Motion & Sensory Quality | 10 | executable prototypes on real solutions, a self-test that asserts the contract bounds, no double exposure, reduced paths for all three motions; haptics intent only |
| Originality & Product Identity | 9 | the answer tiles as the result and the answer returning to the goal are specific to this game; the glass recipe is common |
| Accessibility & Inclusive Quality | 9 | C-9 fit measured, scroll band, semantics order, shape cues; the 45 % disabled link is 2.7 : 1 (exempt, worded) |
| Implementation Fidelity & Polish | 9 | built from `app/lib/design` components and the D1 geometry; Blink, not Skia — runtime fidelity is QA's |
| **Total** | **94** | lowest dimension 9; fail conditions: none known (provisional) |

#### 16.12a Screen / State / Viewport Matrix (D2)

| Screen | State | Viewport / Device | Source Artifact | Critical Assertions |
| --- | --- | --- | --- | --- |
| Win sequence | row 2, plain tiles (L5) | 393×852 | `D2-M-r2-t0000 … t0599`, prototype | §16.11.1 (1); nothing outside the board < 600 |
| Win sequence | row 0, locked tiles (L26) | 393×852, 440×956 | `D2-M-r0-locked-*`, `D2-v-promax-M-r0-t0720`, `-row0.html` | (2); icons gone by 210 |
| Win sequence | row 4 (L4) | 393×852, 390×844 | `D2-M-r4-*`, `D2-v-16e-M-r4-t0720`, `-row4.html` | (3); longest glide |
| Win sequence | frozen tile in the row (synthetic) | 393×852 | `D2-M-frozen-synthetic-*`, `-frozen.html` | ice + dashes covered by the fill |
| Win sequence | level 30, locked Z and N | 390×844 | `D2-v-16e-M-level30-r0-t0210` | C-11 on the last level |
| Transition | 600 → 940 → 1300 | 393×852 | `D2-M-r2-t0680/0760/0840/0940/1300` | (4), (5) |
| Transition | reduced | 393×852 | `D2-M-r2-reduced-t0000/0300/0380/0560/0660`, `?rm=1` | (6) |
| Result | 10 variants | 393×852 | `D2-01 … D2-09b` | (8)–(11) |
| Result | text cap 1.3× | 393×852, 390×844, 440×956 | `D2-10`, `D2-v-16e-result-text-cap-1_3`, `D2-v-promax-result-text-cap-1_3` | (12) no scroll |
| Result | AX5 | 393×852, 390×844 | `D2-10b` (offset 0), `D2-10c` (scrolled to end), `D2-v-16e-result-ax5-top` | (12) scroll, fixed back |
| Result | focus / pressed / disabled | 393×852 | `D2-11`, `D2-12`, `D2-07`, `D2-08` | (15) |
| Result | device variants | 390×844, 440×956 | `D2-v-16e-result-perfect`, `D2-v-16e-result-1star`, `D2-v-promax-result-perfect-new-best` | (8) |
| Retry | result → Play | 393×852 | `D2-M-retry-t0000/0120/0220/0300/0360`, `-retry.html` | (13) |
| Retry | reduced | 393×852 | `D2-M-retry-reduced-t0080` | (13) |
| Contact sheets (review aids) | all of the above | — | `D2-sheet-variants`, `-text-and-devices`, `-win-row2`, `-win-rows-0-4-special`, `-reduced-retry-frozen` | — |
| Android | all | — | not rendered | stated limit (ANDROID-CI-EVIDENCE) |

#### 16.12b Visual Evidence Manifest (D2)

**Provenance for every D2 record:** Source Revision HEAD `489606d` + working tree (`design/src/gen-d2.mjs`, derived from `gen-d1.mjs` and F00 `gen-s.mjs`). Method: HTML/CSS → PNG with headless Chrome at devicePixelRatio 2 (`src/render-d1.sh D2- jobs-d2.txt`); stills are frames of the prototypes frozen with `?t=`. Captured by the UI Designer, 2026-09-28. Generated design artefacts, not runtime captures. Content: real Journey grids with **BFS-verified optimal solutions**, replayed and asserted by the generator (L4, L5, L26, L30); the frozen-in-row case is synthetic and labelled.

| Evidence ID | Kind | Screen / State | Viewport / Device | Artifact | Source Revision | Captured By | Captured At | Result / Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SS-04/05 | selected-source | result perfect / new best / 2★ | 393×852 | features/f00-design-foundation/design/S-04-result-perfect.png, S-04b-result-new-best.png, S-05-result-two-star.png | cc7fe3f + working tree | UI Designer | 2026-09-21 | anchors kept; D2 corrections in §16.2 |
| SS-08…16 | selected-source | transition frames + reduced | 393×852 | features/f00-design-foundation/design/S-08 … S-16, src/S-transition-prototype.html | cc7fe3f + working tree | UI Designer | 2026-09-21 | re-timed on the D1 board (§16.5) |
| D2-01…09b | selected-source | result · 10 variants | 393×852 | features/f03-puzzle-play-session/design/D2-01-result-perfect.png … D2-09b-result-level30-2star.png | 489606d + working tree | UI Designer | 2026-09-28 | audit D2 renders 11–16 |
| D2-10 | accessibility | result · 1.3× cap | 393×852, 390×844, 440×956 | design/D2-10-result-text-cap-1_3.png, D2-v-16e-result-text-cap-1_3.png, D2-v-promax-result-text-cap-1_3.png | 489606d + working tree | UI Designer | 2026-09-28 | no scroll; spare 107 / 105 / 128 pt |
| D2-10-AX5 | accessibility | result · AX5 (offset 0, end) | 393×852, 390×844 | design/D2-10b-result-ax5-top.png, D2-10c-result-ax5-scrolled-end.png, D2-v-16e-result-ax5-top.png | 489606d + working tree | UI Designer | 2026-09-28 | audit render 18; scroll + fixed back |
| D2-11/12 | selected-source | focus on back; primary pressed | 393×852 | design/D2-11-result-focus-back.png, D2-12-result-cta-pressed.png | 489606d + working tree | UI Designer | 2026-09-28 | — |
| D2-V | selected-source | device variants | 390×844, 440×956 | design/D2-v-16e-result-perfect.png, D2-v-16e-result-1star.png, D2-v-promax-result-perfect-new-best.png | 489606d + working tree | UI Designer | 2026-09-28 | — |
| MP-D2 | motion-prototype | win sequence + transition (rows 0 / 2 / 4, frozen), retry; `?rm=1`, `?t=`, `?check=1` | 393×852 | design/src/D2-motion-prototype.html, -row0.html, -row4.html, -frozen.html, -retry.html | 489606d + working tree | UI Designer | 2026-09-28 | HTML/CSS animation (Blink); Flutter recording is Frontend's parity evidence |
| MP-D2-S | motion-prototype | stills: row 2 (10), row 0 locked (5), row 4 (5), frozen (3), reduced (5), retry (5 + 1), device (3) | 393×852, 390×844, 440×956 | design/D2-M-*.png, D2-v-16e-M-*.png, D2-v-promax-M-*.png | 489606d + working tree | UI Designer | 2026-09-28 | audit render 17 = `D2-M-r0-locked-*` (+ synthetic frozen) |
| MP-D2-CHECK | motion-prototype | timeline self-test | 393×852, 390×844 | design/src/timeline-check-d2.txt (pages `D2-check-*.html`) | 489606d + working tree | UI Designer | 2026-09-28 | rest 940 / 660; first result pixel 685; retry 360 / 160; slot error ≤ 0.53 px |
| D2-SHEETS | parity-comparison | contact sheets (review aid) | sheet | design/D2-sheet-*.png | 489606d + working tree | UI Designer | 2026-09-28 | not a gate artefact |
| AUD-D2-BASE | runtime-screenshot | shipped won moment + panel baseline | 393×852 iPhone 16 | features/f00-design-foundation/design/audit/ (cur-won-*, cur-result-*, cur-a11y-ax5-result.png, pair-08…14); qa/d1/, qa/d1r/ | 615e94c; D1 runtime | QA / UI Designer | 2026-09-27 / 28 | the "before" for Frontend parity |

### 16.13 Assumptions (D2)

* **Content.** The solutions are optimal and reachable; they were found by a BFS over the shipped content without thaw and are replayed by the generator (a mismatch throws). No shipped Journey level can hold a still-frozen tile in the winning row (each frozen letter differs from the target letter in its column); the frozen render is synthetic rule coverage for future content (e.g. Daily).
* **AX5 factor.** Renders use 3.12× for free text (iOS body 17 → 53 pt), the value consistent with the D1 runtime captures; Skia wraps differ from Blink by a word here and there — assert the rule, not the line count.
* **Rendering.** Blink, not Skia; ±1 pt text metrics. The morph in the prototype animates layout properties; Flutter should use a transform on a layer (§20.3 (11)).
* **The rating read** normally resolves before 680 ms; if it does not, the `—` / outline states apply (no new waiting UI).
* **Copy** is interim; the English row mirrors the existing `RatingStrings._en` table.
* **Next route transition** stays the shipped one (not in D2 scope). Audio / haptics intent only (F11). Android not rendered.

### 16.14 Needs Tech Lead Clarification

1. **Retry transition — select A or B (non-blocking).** A: the answer returns to the goal rail (recommended; `D2-M-retry-*`, `-retry.html`, 360 ms). B: the plain dip that is already the reduced path (160 ms). Both meet §20.3 (7). The UI Designer cannot select; please record the choice at the checkpoint (or route it to the user).
2. **Re-timed chrome fade (informational, within the bounds).** The Play chrome and board fade 600–720 instead of S-transition's 600–840, to remove the double exposure seen in `S-11`. §20.3 (1) bounds are unchanged; this deviates only from the F00 per-element windows, which §20.3 (1) leaves to the UI Designer.
3. **Level-30 label (copy, PO / localization):** "Yolculuğu tamamla" for Next on level 30 (both weightings). F05 AC12 behaviour unchanged.
4. **No-optimal fallback (informational):** the stars slot shows "Bu bölüm puanlanamadı." and the stats show `—` for OPTİMAL and EN İYİ (replacing "Puan yok"). Dev-only in practice.
5. **Authored headline break:** `Döngü\ntamamlandı.` as the string value (EN `Loop\ncomplete.`). If localization prefers no embedded line breaks, the alternative is a max width of 250·s on the headline — same result in TR.
6. **Design-layer additions in D2's Frontend scope** (cross-feature, like D1 §14.2): a star-reveal option on `StarRow` (or a wrapper), the scroll band, and a result-tile size variant of `TileFace.winning` (52.5 × 59·s, r 24·s). No token changes.
7. **Self-review 94 is provisional;** runtime scoring is QA's (F03.D2-VISUAL-QA).

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** F03-UI-D2 — the D2 handoff (§16, replacing F03-UI-WON). Evidence:
  * 12 result renders (10 variants, focus, pressed) + 6 text-scale renders (1.3× on three devices, AX5 at offset 0 and scrolled, AX5 on the 16e) + 3 device variants;
  * 5 executable prototypes (rows 0 / 2 / 4, frozen, retry; reduced and frame modes) and 37 timed stills;
  * a timeline self-test asserting the §20.3 (1) / (7) bounds (`timeline-check-d2.txt`);
  * the D2 acceptance list (§16.11.1) and the Visual Evidence Manifest (§16.12b).
* **Remaining Tasks:** the Tech Lead's visual-gate checkpoint (→ Ready for Implementation), then F03-FE-D2 and F03-QA-D2.
* **Blockers:** none. §16.14 (1) needs a selection record (non-blocking; B is already specified as the fallback); (2)–(6) are informational or copy.
* **Status Suggestion:** Needs Tech Lead — visual-gate checkpoint.

---

## 15. Sonraki Komut

```
Run Tech Lead
```
