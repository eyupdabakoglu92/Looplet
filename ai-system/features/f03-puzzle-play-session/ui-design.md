# F03 — puzzle-play-session: UI Design Handoff

> UI Designer output. Contract authority stays in `architecture.md`; this handoff resolves the `architecture.md §18 [PENDING — UI]` list and must not change the interaction contract (§6 state machine, §7 gesture mapping, §8 MOVES/Undo/Restart, §9 persistence, §11 animation timing, §13 route/chrome).
> **Addendum 2026-09-20 (F03-UI-WON):** §16 `Won composition` is the authority for the win sequence's timing, the winning row's placement and the completion-panel geometry. It supersedes the `won` row of §8 / the flow line in §4, the "Completion sheet" sizing in §7, and — where they conflict — F04 `ui-design.md` §4–§5 (strip / panel-height / spine-glow numbers). Everything else in this handoff is unchanged.
> Mandatory references: `design/design-doctrine.md`, `design/premium-ui-rubric.md`. No user-specified aesthetic → default premium doctrine applies.

---

## 1. Feature Summary

The single screen where LOOPLET is actually played. The player slides whole rows/columns of a 5×5 letter grid — **circular, wrap-around, one cell per move** — to build the always-visible target word in one row, in as few moves as possible.

**Primary user intent on this screen:** *manipulate the board.* Everything else (the goal, the move count, undo, restart) is support. The board is the interface; there is no form, no list, no primary button while playing.

**UI/UX job:** make the board the unmistakable hero; make the wrap-around mechanic legible; give gesture / animation / input-lock / win a premium, tactile, non-color-dependent feel; keep MOVES / Undo / Restart quiet but glanceable; ship a *minimal but crafted* completion panel as a seam for F04.

---

## 2. Design Direction

### Direction A — "Backlit board on a dark stage" (the loop as light-tracks)

* **Visual character:** a deep, warm-dark atmospheric stage with a single soft radial spotlight. The 5×5 board is the only bright, saturated object — tiles read as **backlit premium keycaps** (warm bone gradient, inner top highlight, ambient-occlusion shadow, a faint at-rest glow). Thin luminous **loop rails** run along the four board edges and ignite directionally while a row/column is dragged, then a tile crossing an edge **wraps** — sliding into an edge mask as its counterpart emerges from the opposite edge. Amber is the colour of resolution (active-drag energy is a cool cyan); the winning row fills amber and a solid seam-bar draws left-to-right beneath it.
* **Why it's strong:** the board is the hero with zero ambiguity; the rail + wrap language is a bespoke identity tied to the product's name ("loop"); the dark stage keeps all chrome silent so the board is loud; high contrast serves one-handed glanceability and the "no colour-only info" accessibility rule; it reads as an App-Store-featured puzzle game at first glance.
* **Risks:** dark UI plus glow can tip gamey/childish if the accent is overused — the glow must be restrained and the rails must be a whisper, not neon. The wrap animation must hit <50 ms start and 60 fps on mid-tier.

### Direction B — "Warm tactile board" (paper-and-brass, daylight)

* **Visual character:** a light warm-neutral stage (bone/sand) with a raised composite board inset; tiles as engraved warm-ceramic pieces; brass locked pins; frosted-glass frozen tiles; a single ink-blue accent for the active track and a deep green for the win. A crafted, calm, "heirloom word game" feel.
* **Why it's strong:** inviting and low-strain for long sessions; the physical-board metaphor makes locked/frozen tiles intuitive; ages well; friendlier for a first-time player.
* **Risks:** light warm boards trend toward "cozy casual" and read mid-segment / generic word-game unless the surface craft is exceptional; the shift animation is harder to make feel energetic; less "featured game" punch, more "nice app" — which the doctrine explicitly rejects as the default.

### Selected Direction — **A ("Backlit board on a dark stage")**

The doctrine's default-when-unspecified rules all point at A: the more premium, less generic, stronger-hierarchy, more atmospheric, more distinctive option. A ties its identity to the actual mechanic (the loop rail + wrap animation), makes the board the unambiguous hero, and keeps MOVES/Undo/Restart chrome near-silent — exactly right for a screen whose whole job is "swipe the board". B is the safer, cozier, more mid-segment read and would fail the "top mobile game app at first glance" bar. **We take A, with discipline:** restrained glow, rails as a subtle directional cue, accent reserved for active-drag and resolution only.

---

## 3. Screen Goals

| Screen / surface | Goal | What the player must understand in 3 seconds |
| --- | --- | --- |
| **Play screen (idle / playing)** | Manipulate the board to build the target word | "That word up top is my goal. The bright grid is the thing I move. I swipe rows and columns." |
| **Gesture / animating** | Confirm the swipe registered and one move happened | "My swipe grabbed this row; it moved exactly one cell; that cost one move." |
| **Won** | Signal the target is formed and offer the next step | "I did it — that row is the answer. I can retry or leave." |
| **Completion panel (minimal seam)** | Report the result and route out | "Solved in N moves. Retry, or close." |
| **Debug puzzle entry (dev only)** | Not flash empty / not crash on a bad puzzle | "Loading…" / "Couldn't load this puzzle." |

---

## 4. UX Flow Direction

```
enter '/play' (journey level / daily / debug entry)
  │
  ├─ active snapshot for this puzzleId?  ── yes ──▶ hydrate via F08 restore path (silent; no "resuming" UI)
  │                                        no  ──▶ fresh board, write initial snapshot
  ▼
[idle] ──touch a tile──▶ press-in feedback (<16 ms)
  │
  ├─ release below threshold / off a tile ──▶ [idle]   (nothing; MOVES unchanged — AC4)
  │
  └─ drag past threshold ──▶ affected row/col LIFTS + end rails ignite (cyan, directional)  ── AC9
        │
        release ──▶ engine.applyMove
              │
              ├─ applied ──▶ [animating] input LOCKED, no queue (190 ms wrap shift) ──settle──▶ MOVES +1 tick
              │                                                                          │
              │                                                            solvedThisStep? ── no ──▶ [idle]
              │                                                                          │
              │                                                                         yes ──▶ [won]
              │
              └─ rejected ──▶ rubber-band bounce-back (~140 ms), rails flash+die, MOVES unchanged, NO error text

[won] ── ~600 ms bounded sequence ──▶ completion panel (bottom sheet)
        │
        ├─ Retry  ──▶ engine.restart() in place, panel dismisses, board re-lights, [idle]
        └─ Close  ──▶ pop to caller (menu)

Undo (idle only, quota > 0) ──▶ engine.undo() + quota−− + snapshot write
Undo (quota 0)              ──▶ nothing. no dialog, no ad, no toast. (AC6)
Restart (idle / after settle) ──▶ engine.restart(), MOVES 0, quota 3, restartCount++, NO confirm (AC7)

back chevron / system back (idle or animating) ──▶ pop to caller; snapshot kept as inProgress (resumable)
back (won) ──▶ not available; the panel's Close owns exit
```

* **Friction removed:** no "resume?" prompt (silent hydrate); no restart confirm; no undo-limit nag; no error toasts; no modal loading. The board answers every input with motion.
* **Wait state:** only the 190 ms shift — communicated *diegetically* (controls dim, board focuses), never a spinner.
* **Result state:** the minimal completion panel — crafted, not a placeholder.

### Header / top bar behaviour

* **No system/native header. No custom top bar surface.** A single low-emphasis **back chevron** in the top-left safe area (`‹`, stroke `#8A88A0`, no background chip, 44×44 pt touch target).
* Chevron target on **pop to caller** (menu / level list). No confirmation. Hardware / gesture back = identical.
* During **animating**: chevron still works (leaving mid-animation is safe — the move is already applied to the engine; the last snapshot is settled).
* During **won**: chevron is **hidden**; the completion panel's **Close** owns exit.
* Sibling consistency: F10 (menu) and later screens should adopt the same "no title bar, quiet chevron top-left" chrome for in-flow screens; flagged for Tech Lead as a proposed shared rule, not decided here.

---

## 5. Visual System

### Background Direction

* **Stage:** full-bleed vertical gradient, `#0B0C16` (top) → `#141322` (bottom), warm undertone.
* **Spotlight:** one large soft radial glow centred slightly above board-centre — `#2A2350` at ~14 % peak opacity, radius ≈ 140 % of board width, feathered. This is what makes the board read as "lit on a stage".
* **Vignette:** subtle corner darkening, `#000` at ~18 %, feathered well inside the safe area.
* **Grain:** optional 2–3 % monochrome grain to kill gradient banding on OLED.
* **Never** a flat single-colour fill; **never** a top-gradient / bottom-cards split.
* Optional ambient: the spotlight may "breathe" ±3 % opacity over ~6 s. FE-flexible; must stay ≤ 3 % so it never reads as motion / distraction (respects the performance rule "animation must not distract").

### Surface Direction

* **Board plate:** a recessed dark panel behind the tiles — `#0E0F1C`, inner shadow from the top (`#000` 45 %, y+3, blur 10), a 1 px top edge highlight (`#FFFFFF` 6 %). Radius = tile-radius + tile-gap. Reads as "the board is inset into the stage".
* **Tile (neutral):** rounded-rect, radius = 19 % of tile size. Fill = vertical gradient `#F4EFE6` (top) → `#E7DFCF` (bottom). 1 px inner top highlight `#FFFFFF` 60 %. Ambient-occlusion drop shadow `#000` 22 %, y+2, blur 8, plus a tight contact shadow `#000` 30 %, y+1, blur 2. A near-invisible at-rest outer glow (`#FFE9C2` 5 %, blur 12) so tiles feel backlit, not printed.
* **Loop rails:** 2 pt gradient strokes along each board edge, colour `#5AA9FF`, opacity 0 at idle. Each rail's gradient fades to fully transparent at both ends (they never read as a hard frame).
* **Completion sheet:** raised panel `#191A2B`, 1 px top highlight `#FFFFFF` 8 %, top-corner radius 28, long soft shadow (`#000` 50 %, y-8, blur 32) above a 40 % scrim over the dimmed board.
* Three distinct surface tiers: **stage** (deep, atmospheric) < **board plate** (recessed dark) < **tiles** (bright, raised). Nothing is flat.

### Color Direction

| Role | Token | Value | Use |
| --- | --- | --- | --- |
| Stage top / bottom | `stage-0` / `stage-1` | `#0B0C16` / `#141322` | background gradient |
| Spotlight | `stage-glow` | `#2A2350` @14 % | radial glow |
| Board plate | `plate` | `#0E0F1C` | recessed board bg |
| Tile neutral | `tile-hi` / `tile-lo` | `#F4EFE6` / `#E7DFCF` | tile gradient |
| Tile letter | `ink` | `#1B1A24` | neutral-tile glyph |
| Accent / resolution | `amber` / `amber-lo` | `#FFC24B` / `#FFB020` | winning row fill, seam bar, Retry CTA, "solved" kicker |
| Win letter | `ink-amber` | `#2A1B00` | winning-tile glyph |
| Active-drag energy | `cyan` | `#5AA9FF` | loop rails, drag lift edge light |
| Muted / labels | `muted` | `#8A88A0` | `MOVES` label, back chevron, Close button, helper text |
| On-stage text hi | `paper` | `#F4EFE6` | MOVES number, kicker on dark |
| Locked-tile mark | `brass` | `#C9A24B` | locked pivot ring + pin glyph |
| Frozen-tile surface | `frost` | `#DCE8F2` | frozen tile fill (with texture) |
| Frozen accent | `frost-line` | `#9BC4E6` | frozen crystal border |
| Danger (debug error only) | `danger` | `#E06A5A` | debug load-error icon |

* No pure `#000` or `#FFF` anywhere. Amber is the *only* saturated warm; cyan the *only* saturated cool — used sparingly so both stay meaningful.

### Typography Direction

* **Tile letters:** a heavy grotesque (weight ≈ 800), optical size ≈ 46 % of tile height, centred, slight positive tracking. This is the loudest type on screen. Never system-regular.
* **MOVES number:** tabular-lining figures, weight ≈ 700, `paper`, ~28–32 pt. Animates on settle (count-tick + a 60 ms 1.0→1.06→1.0 scale pulse).
* **Micro-labels** (`HEDEF`, `MOVES`/`HAMLE`, `ÇÖZÜLDÜ`): all-caps, weight 600, tracking +8 %, `muted` (kicker in `amber` at 70 %), ~11–12 pt.
* **Completion word:** the formed word as text in the amber glyph style, weight 800, ~34 pt — the payoff, an echo of the target rail.
* **Completion stat:** `HAMLE` label (micro) + the number (tabular 700, ~30 pt).
* Helper / debug text: weight 400, `muted`, ~14 pt, never dominant.
* Three type roles only (display glyph / stat figure / micro-label) — correct restraint for a board screen; not a text-heavy surface.

---

## 6. Layout Structure

Portrait only. Three stacked zones over the stage:

```
┌───────────────────────────────────────────────┐  ← top safe-area inset
│ ‹                                             │  back chevron (top-left, quiet)
│                                               │
│                 H E D E F                     │  TARGET ZONE  (~18–20% of safe height)
│            ▢  ▢  ▢  ▢  ▢                       │  5 outline-ghost tiles, 44–48% scale
│                                               │
│ ───────────────  faint divider glow  ──────── │  separation cue
│                                               │  ≥ 28 pt air
│         ┌───────────────────────────┐         │
│         │  ▣  ▣  ▣  ▣  ▣            │         │  BOARD ZONE  (hero)
│         │  ▣  ▣  ▣  ▣  ▣            │         │  5×5 backlit tiles on a recessed plate
│         │  ▣  ▣  ▣  ▣  ▣            │         │  board width ≈ 86–90% of screen width
│         │  ▣  ▣  ▣  ▣  ▣            │         │  loop rails on all four edges
│         │  ▣  ▣  ▣  ▣  ▣            │         │
│         └───────────────────────────┘         │
│                                               │  ≥ 28 pt air
│    14                                         │  HUD ZONE  (~16–18% of safe height)
│    MOVES                                      │  stat block
│                                               │
│   ( ↺  ● ● ● )              │      ◯          │  Undo pill (left) · divider · Restart (right, apart)
│                                               │
└───────────────────────────────────────────────┘  ← bottom safe-area inset (min 16 pt)
```

* **Spacing rhythm:** 4/8 pt. Tile gap = 8 pt at the reference width, scaling proportionally with tile size. Board plate padding = 10 pt. Zone gaps (target→board, board→HUD) = **28 pt minimum, fixed**.
* **Shrink strategy (short devices):** the board scales down first; the fixed 28 pt zone gaps hold. Only if the board hits its floor (tile ≈ 56 pt) do the gaps compress (down to 16 pt), never below. The target zone and HUD never overlap the board plate.
* **Composition intent:** the board sits on an optical-centre "stage"; the negative space above and below is deliberate breathing room that focuses the eye on the lit board — a stage effect, not an empty screen.
* **No primary CTA region while playing.** The board is the action. (The one CTA — Retry — lives in the completion sheet.) This is intentional; QA/FE must not add a floating play/submit button.

### App Chrome & Navigation Rules

| Screen state | System header | Custom top bar | Back affordance | Returns to | HW / gesture back |
| --- | --- | --- | --- | --- | --- |
| idle / playing | none | none | quiet `‹` chevron, top-left safe area | caller (menu / level list) | same as chevron; snapshot kept `inProgress` |
| animating | none | none | chevron active | caller | same; last snapshot is settled |
| won | none | none | **chevron hidden** | — | back = dismiss panel via **Close** (same as Close) |
| completion panel | none | none | panel **Close** (secondary) + **Retry** (primary) | Close → caller; Retry → in-place restart | back = Close |
| debug loading / error | none | none | `Geri` text button (error only) | caller | same |

* Portrait-locked; rotation attempts do nothing (no landscape layout exists).
* No confirm dialogs anywhere in F03.

---

## 7. Component Decisions

### Target rail (the goal)

* **Role:** show the word to build; must be legible but clearly *not* part of the board.
* **Weight:** medium — present, calm, never competes with the board.
* **Treatment:** 5 tiles using the **same rounded-rect silhouette** as the board but at **44–48 % scale**, rendered as **outline-ghost**: 1.5 pt stroke `muted` @ 55 %, fill `#FFFFFF` @ 4 %, letter in `paper` @ 80 % at the board glyph weight. Generous letter-spacing between ghost tiles (wider than the board's 8 pt gap) so it reads as a *word*, not a row. Micro-label `HEDEF` centred above, `muted`.
* **Separation from the grid** is carried by **four** cues, not one: scale, treatment (outline vs solid-backlit), a full-width faint divider glow beneath, and ≥ 28 pt of air.
* **Why not generic:** not a text string in an app bar; it visually rhymes with the board ("build this shape") while being unmistakably the target.

### Tile (board cell)

* **Role:** the atomic manipulable unit.
* **Weight:** the heaviest object on screen.
* **States:**
  * *neutral* — bone gradient + inner highlight + AO shadow + faint backlight glow.
  * *pressed* (finger down, pre-threshold) — scale 0.97, contact shadow tightens, <16 ms.
  * *in an active row/col* (drag past threshold) — parent row/col lifts (scale 1.015, shadow grows, z above siblings); non-active tiles get an 8 % `#000` dim overlay.
  * *wrapping* (during shift) — the edge-crossing tile slides into an edge mask; its counterpart emerges from the opposite edge with a 40 ms opacity + 2 px→0 blur ramp.
  * *winning* — fill → `amber`/`amber-lo` gradient, letter → `ink-amber`, scale 1.06, shadow bloom; L→R 30 ms stagger.
  * *locked* — a `brass` ring inset 2 pt from the tile edge + a small centred pin/anchor glyph behind the letter at 18 % opacity; the tile never lifts or shifts. **Shape cue, not colour-only.**
  * *frozen* — fill → `frost` with a faint crystalline texture; 1.5 pt `frost-line` border with 3–4 tiny corner crystal marks; letter in `ink` @ 70 %. On thaw: a 180 ms cross-fade to the neutral tile + a quick single frost-shatter shimmer. **Texture + border-marks cue, not colour-only.**
* **Why not generic:** gradient + layered shadow + backlight = a physical keycap, not a flat square; every special state has a non-colour cue for accessibility.

### MOVES stat block

* **Role:** live efficiency read.
* **Weight:** medium; the only "number" on the playing screen.
* **Treatment:** big tabular figure (`paper`) with a micro `MOVES` label beneath (`muted`). Settle-tick animation. No card, no border — it sits directly on the stage.
* **Why not generic:** tabular + mechanical tick matches "every move matters"; not a chip, not a pill.

### Undo control

* **Role:** the 3-action recovery.
* **Weight:** secondary; larger than Restart, on the left.
* **Treatment:** a wide-ish pill, `#1E1F30` surface, 1 px top highlight `#FFFFFF` 6 %. Inside: a **loop-back arrow** icon (echoes the mechanic) + **3 pips** showing remaining undos (filled `paper` → hollow as they're spent). Pressed: scale 0.97 + a 2 px inward nudge.
* **Disabled (quota 0):** surface drops to `#161725`, icon + all pips to `muted` @ 35 %, no highlight, no glow. Tap = nothing — **no dialog, no ad, no toast** (AC6). The deadness is the message.
* **Why not generic:** the pip quota is glanceable and on-brand; it honestly shows "0 left" without nagging.

### Restart control

* **Role:** full reset to initial.
* **Weight:** tertiary; **physically set apart** from Undo — a gap ≥ 24 pt **plus** a 1 px vertical divider (`#FFFFFF` 6 %) between them, pushed to the screen's right, smaller footprint.
* **Treatment:** ghost/outline (not filled) — a circle icon of a **full loop arrow**, stroke `muted`, no surface fill, 44×44 pt target. Pressed: 180° icon spin + scale 0.97. **No confirm** (AC7). Positioned outside the board's horizontal band and below it so a swiping thumb can't clip it.
* **Why not generic:** deliberately *unlike* Undo (outline vs filled, small vs wide, right vs left, divider between) so it is never a mis-tap — the PRD's "physically separated" made visual.

### Completion sheet (minimal seam — F04 replaces)

> Geometry and timing superseded by §16 (2026-09-20). Sizing below is historical.

* **Role:** report the result, route out. **Not** the rating panel.
* **Weight:** a focused bottom sheet, ~42–50 % screen height, not full-screen.
* **Content (top→bottom, tight):** kicker `ÇÖZÜLDÜ` (`amber` @ 70 %, micro) · the formed **word** as amber text (~34 pt, weight 800) · one stat `HAMLE  14` (micro label + tabular figure) · actions.
* **Actions:** **Retry** = the one real CTA — a filled `amber`→`amber-lo` pill, `ink-amber` text, weight 700, full-width or ≥ 62 % width, dominant. **Close** = a quiet `muted` text button, directly below or to the right, clearly secondary.
* **No** stars, optimal, personal best, "Next Level", scroll, or extra chrome.
* **Why not a placeholder:** real surface craft (raised dark panel, top highlight, long shadow, scrim), real type hierarchy, one dominant CTA. It should read as *deliberately minimal*, never as *unfinished*.

### Debug puzzle entry (dev-only)

* **Loading:** stage + spotlight render instantly; board area shows 25 tile silhouettes at 6 % fill with a slow L→R shimmer sweep (~1.1 s); target rail shows 5 ghost slots. No spinner. Should almost never appear (local content is instant).
* **Error:** centred on the stage — a small `danger` icon, one line `Bu bulmaca yüklenemedi`, a `Geri` text button. Explicitly a dev surface, not production-polished.

---

## 8. State Design

| State | How it looks | How it differs from idle | What it feels like |
| --- | --- | --- | --- |
| **idle** | Board fully lit, rails at 0, HUD at rest, optional ≤3 % spotlight breathing | baseline | calm, ready, "your move" |
| **tracking — pressed** | Touched tile scale 0.97, contact shadow tight | one tile depresses | instant acknowledgement (<16 ms), even for a tap that becomes a no-op |
| **tracking — dragging** | Whole affected row/col lifts (1.015, raised z); its two end rails ignite to ~30 % `cyan` with a directional gradient (brighter toward the swipe); other tiles dim 8 %; the row/col rubber-bands up to ~0.5 tile with the finger (never free-scrolls) | a track is "grabbed" and glowing | tactile grip; the loop tracks are alive; you can feel it's one-cell, not a scroll |
| **animating (190 ms shift)** | Input LOCKED. HUD controls → 55 % opacity for the duration; non-active tiles hold the 8 % dim; the shift plays with the wrap (edge mask + opposite-edge emergence, blur/opacity ramp); ease `cubic-bezier(0.22,1,0.36,1)` | the screen is visibly "held"; the wrap shows a tile leaving one edge and arriving at the other | decisive, physical, brief — no spinner, no modal; you *see* the loop |
| **animating — rejected move** | Row/col rubber-bands back to origin (~140 ms, firmer ease), rails flash then die, MOVES unchanged, nothing else | a bounce with no follow-through | "that can't move" — felt, never a toast |
| **won** | ≤600 ms bounded: input locks hard (controls 40 %); winning row → amber fill + `ink-amber` letters + 1.06 lift in a 30 ms L→R stagger; a solid 3 pt **amber seam bar** draws L→R beneath the row with a soft glow; one restrained amber radial bloom (~20 % peak) pulses once; rest of board recedes (12 % dim + 1.5 px blur); then the completion sheet rises | the answer row transforms and a continuous bar locks under it; the board recedes | earned, resolved; the seam bar makes it legible without colour |
| **completion panel** | Raised dark bottom sheet over a 40 % scrim; kicker + amber word + one stat + dominant Retry + quiet Close | a focused sheet owns the screen; board dim behind | "done — clean result, clear next step" |
| **disabled — Undo at 0** | Undo pill dark, icon + pips `muted` 35 %, no highlight/glow; tap inert | Undo visibly dead | honest limit; no nag, no upsell |
| **disabled — during animate/won** | Controls at 55 % / 40 % opacity, non-interactive | chrome fades | "not now" without a blocker |
| **loading (debug)** | Stage + spotlight instant; 25 tile silhouettes @6 % + slow L→R shimmer; ghost target slots | board is skeletal, still atmospheric | brief, never a blank flash |
| **error (debug)** | Centred `danger` icon + one line + `Geri` | board replaced by a tiny message | contained; dev-only |
| **focused (assistive tech)** | 2 pt `amber` focus ring, 2 pt offset, on chevron / Undo / Restart / panel buttons | a crisp ring appears | reachable, on-brand |

---

## 9. Premium Differentiators (concrete)

1. **Spotlight stage** — the board is a *lit object on a stage* (radial glow + vignette + grain), not a widget on a page.
2. **Backlit-keycap tiles** — bone gradient + inner top highlight + ambient-occlusion + tight contact shadow + faint backlight glow; physical, not flat.
3. **Loop-rail motif** — fading luminous edge rails that ignite *directionally* while dragging; a bespoke visual language for the wrap-around mechanic, tied to the name "LOOPLET".
4. **Wrap animation** — edge-mask exit + opposite-edge emergence with a blur/opacity ramp; the shift *shows* the loop instead of a plain slide.
5. **Outline-ghost target** — same tile silhouette, different treatment + scale; the goal reads as "the shape to build", separated by four cues not one.
6. **Won = amber fill + a drawn L→R seam bar** — colour *and* a distinct unbroken-bar shape, so the win is legible in greyscale / for colour-blind players and feels like the row "locks in".
7. **Diegetic input-lock** — controls dim + board focuses during the shift; no spinner, no modal, the screen simply *feels held*.
8. **Undo pip quota** on a loop-back-arrow pill — the 3→0 allowance is glanceable and on-brand; at 0 it's quietly, honestly dead.
9. **Restart set apart** — outline vs filled, small vs wide, right vs left, a divider between; the PRD's "physically separated" turned into an unmistakable visual difference.
10. **Rejected move = rubber-band bounce** — the "can't move" answer is physical; F03 never shows an error string or toast.
11. **Tabular MOVES with a settle-tick** — the count feels mechanical and exact, matching "every move matters".

---

## 10. Anti-Patterns to Avoid (F03-specific)

* A flat screen with a grid and a blue "Undo" button.
* The target word as plain body text in a system app bar.
* A native `AppBar` / back arrow with a title.
* A spinner, progress bar, or "please wait" modal during the ~190 ms shift.
* Confetti / particle explosion on win (F11 / F04 own celebration polish later; F03 is one restrained bloom + the seam bar).
* Undo and Restart as identical adjacent buttons (mis-tap risk; PRD forbids).
* A "Next Level" button in F03's completion panel.
* Toasts / snackbars for rejected moves or undo-at-zero.
* Tiles that free-scroll under the finger (must be 1 swipe = exactly 1 cell; rubber-band only).
* Colour-only win / locked / frozen indication.
* A completion sheet that looks like a TODO ("result goes here").
* Flattening tiles to solid fills, or dropping the wrap to a plain slide, or swapping the input-lock for a spinner "to keep it simple".

---

## 11. Frontend Handoff

### Must not be broken (contract-level UI decisions)

* The **board is the hero** and the only bright, saturated cluster on screen; stage stays dark and atmospheric; MOVES / Undo / Restart chrome stays quiet.
* **Target = outline-ghost tiles**, separated from the board by scale **+** treatment **+** a divider glow **+** ≥ 28 pt air.
* **Input LOCKED during the shift with a *diegetic* (non-spinner) affordance** — controls dim, board focuses — and **no input queue** (a gesture during `animating` produces no move and no press-in follow-through). QA: 0 double-registered moves during animation.
* **The wrap must be visible** — an edge tile leaves one edge and its counterpart arrives at the opposite edge; do not ship a plain linear slide.
* **Won sequence bounded ≤ ~600 ms**: amber fill + `ink-amber` letters + L→R stagger + a **drawn L→R seam bar** (colour **and** shape) + one restrained bloom, then the sheet. The seam bar is not optional "because the amber is enough".
* **Restart is physically separated from Undo**: gap ≥ 24 pt **plus** a divider, right side, outline (not filled) treatment, **no confirm**.
* **Undo at quota 0** = silent inert control; **no dialog, no ad, no toast**.
* **MOVES = `engine.moveCount`**, updated on **settle** only (never on gesture release).
* **No floating / primary CTA on the playing screen.** The one CTA is **Retry** in the completion sheet, and it must dominate; **Close** is quiet and secondary.
* Completion sheet is **minimal but crafted** — real raised surface, real type hierarchy, a dominant CTA; **no** stars / optimal / best / Next Level.
* **Portrait-locked**; **no confirm dialogs** anywhere; **no system header** — one quiet back chevron top-left, hidden in `won`.
* Every special tile state (**locked**, **frozen**, **winning**) carries a **non-colour cue** (pin glyph + ring / frost texture + crystal border / drawn seam bar).

### Flexible (FE may tune within these bounds)

* Shift **duration 170–210 ms** (inside the 150–250 band) and the exact easing curve; `cubic-bezier(0.22,1,0.36,1)` is the recommended default.
* The spotlight "breathing" ambient (optional; ≤ 3 % amplitude; drop it if it costs frames).
* Exact rail colour / opacity as long as it stays a subtle directional cue that brightens toward the swipe direction.
* Completion sheet layout: **Retry full-width with Close as a text link beneath**, *or* one row at ~62/38 — as long as Retry clearly dominates.
* The rubber-band travel distance during drag (~0.3–0.6 tile) and resistance curve.
* Exact tile radius (18–20 % of tile size), shadow blur values (±2 px), grain amount (0–3 %).
* **Gesture threshold `T` and diagonal tie-band `B` numbers** — these are Frontend + QA on-device tuning (`architecture.md §7 / §18`); design fixes only the *affordance* (press-in feedback, the lift + rail ignite past threshold, one-cell rubber-band). Design's ask: `T` large enough that a tap or micro-drag never lifts a row.

### Do not cheapen

* Don't replace the tile gradient + layered shadow with a flat fill.
* Don't turn the input-lock into a spinner or a blocking overlay.
* Don't drop the wrap animation to a plain slide.
* Don't omit the winning seam bar.
* Don't let the debug loading state flash a blank board (render the stage + silhouettes immediately).
* Don't fall back to system-regular weight for the tile letters (they carry the screen).
* Don't add a card/border around the MOVES block — it sits directly on the stage.

---

## 12. Self-Review Against Rubric

| Criterion | Score | Rationale |
| --- | --- | --- |
| Visual Hierarchy | 10 | One hero (the lit board), target clearly subordinate but legible, chrome near-silent, MOVES/Undo/Restart tiered by size + placement + treatment. |
| Layout & Composition | 9 | Three clean zones with fixed 28 pt gaps + a defined board-first shrink strategy; deliberate stage negative space. −1: very short devices force a tight board (mitigated by the gap-floor rule). |
| Surface & Depth | 10 | Stage glow + vignette + grain, recessed board plate, backlit-keycap tiles with AO + contact shadow + inner highlight, raised completion sheet. Nothing flat. |
| Typography | 9 | Heavy grotesque tile glyphs, tabular MOVES with a settle-tick, tracked micro-labels, single amber payoff word. −1: only three type roles — correct for a board screen, but not a rich type system. |
| CTA Quality | 9 | No CTA while playing (the board *is* the action) + a single dominant amber Retry in the sheet; Close deliberately quiet. −1: the "no CTA" choice needs QA/Tech Lead buy-in so it isn't read as missing. |
| Selection / Focus / State | 10 | idle / pressed / dragging / animating / rejected / won / completion / disabled(×2) / loading / error / focused all specified with distinct, *felt* treatments and non-colour cues. |
| Product Feel | 10 | Dark spotlight stage + backlit board + loop rails + wrap animation = an App-Store-featured puzzle-game identity tied to the product name. |
| Modernity | 9 | 2026 dark, layered, restrained motion, diegetic feedback; avoids skeuomorphic overkill and flat blandness. −1: dark puzzle boards are a known idiom — differentiation rides on the loop-rail / wrap language being executed well. |
| Non-Generic Originality | 9 | Loop-rail motif, wrap animation, outline-ghost target, drawn win-seam — distinctive; not a card/input/button screen. −1: a tile grid is inherently familiar; originality is in treatment, not structure. |
| Implementability | 9 | Concrete tokens, sizes, z-order, durations, easing, shrink rules. −1: the wrap / edge-mask animation needs care to hit < 50 ms start + 60 fps on mid-tier. |

**Total: 94 / 100** — within the target band (93–96). No fail conditions present (clear hero, dominant CTA where one exists, strong selected/won states, layered surfaces, strong hierarchy, non-generic identity). Finalized.

---

## 13. Assumptions

* **No brand palette provided** → the default premium doctrine (dark atmospheric stage) applies. If LOOPLET has an official palette / wordmark, the `amber` / `cyan` / `stage` tokens rebind but the structure, hierarchy, and state design hold.
* **Turkish primary** → copy shown here as TR with EN in parentheses is illustrative; final strings come from the localization layer. Proposed keys: `HEDEF` (target label), `HAMLE` (moves label), `ÇÖZÜLDÜ` (solved kicker), `Yeniden` (Retry), `Kapat` (Close), `Bu bulmaca yüklenemedi` + `Geri` (debug error). PO / localization confirms final wording.
* **F03 renders the first-pass *visual* treatment for locked & frozen tile states** (F02 owns the behaviour; F05 / F06 author which tiles). The pin-glyph + brass ring (locked) and frost-texture + crystal border (frozen) specs here are that first pass; a later dedicated tile-state visual pass may revisit.
* **The completion sheet is a temporary seam.** F04 redesigns it (stars / optimal / best / "Perfect" / Retry / Next Level). This handoff only ensures F03's version is crafted, not broken-looking.
* **Screen-reader support** is a summary accessibility label on the board (target + current grid state) + focus rings on controls; full assistive grid navigation is out of F03 scope (consistent with `architecture.md §16`).
* Motion values (190 ms shift, ≤ 600 ms win, ≤ 3 % breathing) are set to respect the product's "animation must not distract / < 50 ms input latency / smooth on mid-tier" constraints; FE + QA validate on the device matrix.

---

## 14. Needs Tech Lead Clarification

1. **No primary CTA on the playing screen** — confirm this is accepted (the board is the interaction; the only CTA is Retry in the completion sheet). QA should not flag it as a "missing CTA".
2. **Locked / frozen tile *visual* ownership** — confirm F03 owns the first-pass visual treatment for these tile states (F02 owns behaviour, F05/F06 author placement). If a dedicated tile-state visual language belongs to a later feature, say which.
3. **Shared in-flow chrome rule** — this handoff proposes "no title bar, one quiet back chevron top-left, hidden in terminal/won states" as a pattern F10 and later in-flow screens should share. Confirm whether to lock that as a cross-screen rule now or defer to F10.
4. **Microcopy** — `HEDEF / HAMLE / ÇÖZÜLDÜ / Yeniden / Kapat` are placeholders; PO / localization owns the final strings.

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

* **Completed Tasks:** F03-UI-WON — §16 `Won composition` added (2026-09-20): timeline, fixed dock geometry, panel cap, ghost slot, reduce-motion, exits, rect-testable visibility rule, rubric self-review 92.
* **Remaining Tasks:** F03-FE-WON, F03-FE-INTEG (Frontend/Mobile Developer).
* **Blockers:** none.
* **Status Suggestion:** Ready for Frontend.

---

## 15. Sonraki Komut

```
Run Frontend/Mobile Developer
```
