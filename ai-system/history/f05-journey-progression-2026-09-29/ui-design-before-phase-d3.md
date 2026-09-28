# F05 — journey-progression: UI Design Handoff

> UI Designer output. Contract authority stays in `architecture.md` (LOCKED — §4 identity, §8 navigation, §9 the micro-tutorial contract, §10 the home surface contract, §16 the F04 CTA-weighting follow-on). This handoff resolves `architecture.md §17 [PENDING — UI]` and must not change the interaction contract.
> Mandatory references: `design/design-doctrine.md`, `design/premium-ui-rubric.md`, `features/f03-puzzle-play-session/ui-design.md` (Direction A — the app's established chrome), `features/f04-star-rating-and-personal-best/ui-design.md` (the `CompletionPanel` being re-weighted). No user-specified aesthetic → default premium doctrine applies.
> Reuses F03's `PlayTheme` tokens (`app/lib/play/play_theme.dart`). **No new colour tokens.**

---

## 1. Feature Summary

Three surfaces turn F03's isolated play session into a campaign:

1. **The home surface** (`/`, replaces the debug `HomeScreen`) — the first screen a real build shows. LOOPLET wordmark, one dominant **CONTINUE** CTA, and a **journey-progress ring** that reads campaign momentum at a glance. Not the F10 menu (no DAILY, no Settings, no level-select map).
2. **The "all 30 complete" terminal variant** of the home — an earned end-state; CONTINUE repurposes to "replay".
3. **The levels 4–6 column micro-tutorial** — an action-gated, diegetic coach-mark over the F03 board that teaches the column shift and re-shows until the player performs one.

Plus **(4)** a weighting rule for F04's existing `CompletionPanel` now that `Next Level` is live: at 3★ the amber pill moves to `Next Level`; at 1–2★ it stays on `Retry`.

**Primary user intent:** *know where I am in the campaign, and get back into it in one tap.* The home's job is to make "4 / 30, next node glowing" feel like momentum worth continuing — this is the surface that drives the Level 5 Reach KPI.

---

## 2. Design Direction

### Direction A — "The loop, filling" (a progress ring as the home's hero)

* **Visual character:** the same deep, warm-dark atmospheric **stage** as F03 (gradient `#0B0C16 → #141322`, one soft radial spotlight, corner vignette, optional grain). On it: the LOOPLET wordmark, and beneath it a large **progress ring** — a ~300° arc with a 60° gap at the bottom, divided into **30 tick-segments**. Completed levels light **amber** (a continuous glowing run from the top-left, clockwise); the **current** level is a brighter amber tick with a glowing node at its outer tip; locked levels are dim `muted`. At the ring's heart sits the count — a big tabular **"`N`"** with a smaller **"/ 30"** and a micro `SEVİYE` label. The **CONTINUE** pill nests into the ring's bottom gap, so the whole thing reads as one composed object: *wordmark → the loop, partly filled, with your count at its centre → CONTINUE emerging from the loop's base*. The ring is the campaign's namesake mechanic made into a progress meter, and it rhymes with F03's luminous loop-rails.
* **Why it's strong:** the momentum read is the composition, not a widget bolted to a corner — a player who opens the app sees "4 / 30" *inside a loop that's clearly meant to fill* and wants to close the gap. It ties the home to the product's identity (the loop) and to F03's visual language (amber = resolution, cyan = active, luminous edges). One hero, one CTA, deliberate stage negative space — exactly the doctrine's "App-Store-featured game at first glance". It scales cleanly (30 ticks is legible; the fill is obvious in greyscale by length).
* **Risks:** a 30-segment ring can tip fussy if the ticks are thin/noisy or the glow is overdone — the ticks must be confident, the glow a whisper, the amber run continuous (not 30 individually-glowing dots). On very short devices the ring must shrink before the wordmark/CTA do.

### Direction B — "Stacked minimal" (wordmark, a bar, a button)

* **Visual character:** LOOPLET wordmark top; a plain horizontal progress bar + "12 / 30" mid-screen; the CONTINUE pill below; centred on the dark stage.
* **Why it's strong:** trivial to build, unambiguous, fast.
* **Risks (why it loses):** it is the generic "app home" — a bar and a button on a background. It reads mid-segment / template, has no identity, and makes campaign progress a thin horizontal strip rather than the thing you feel. `design-doctrine.md §8` explicitly rejects "üstte gradient, altta rastgele kartlar / buton" as a default. It would fail the "would this look natural inside a top mobile game?" check.

### Selected Direction — **A ("The loop, filling")**

The doctrine's default-when-unspecified rules all point at A: more premium, less generic, stronger single hero, tied to the product's identity, momentum-as-composition. B is the safe bar-and-button the rubric fails. **We take A, with discipline:** confident ticks, a restrained continuous glow on the completed run, one bright current-node, the ring shrinks first on small devices, the CTA always dominates.

---

## 3. Screen Goals

| Surface | Goal | What the player must understand in 3 seconds |
| --- | --- | --- |
| **Home — mid-campaign** | Show momentum + get back in | "I'm 4 of 30 in. The next one is right there. CONTINUE." |
| **Home — brand new (0 / 30)** | Invite the first tap | "This is a 30-level journey. I start here." |
| **Home — in-progress level** | Signal "you have an unfinished level" | "Level 5 is still going — one tap resumes it exactly." |
| **Home — all 30 complete** | Reward completion, offer replay | "I finished the whole Journey. I can replay to beat my moves." |
| **4–6 micro-tutorial** | Teach the column shift, gate on doing it | "Oh — I can slide columns now, up or down. Let me try." |
| **CompletionPanel (re-weighted)** | Make the natural next action the loud one | "I nailed it — NEXT is the big button." / "Not my best — RETRY is." |

---

## 4. UX Flow Direction

```
app launch ──▶ _BootstrapGate (F08 splash → home)
  ▼
HOME (/)
  ├─ progress ring bound to JourneyProgressRepo.watch  (live; updates when a win commits elsewhere)
  ├─ CONTINUE ─▶ resolve currentLevel (architecture.md §6):
  │      in-progress level ─▶ /play (journeyLevel=N)  ─▶ F03+F08 restore exact state
  │      else lowest unlocked incomplete ─▶ /play (journeyLevel=N)  [brand new ⇒ N=1, F09 seam interim]
  │      else all 30 done ─▶ terminal variant renders in place (CONTINUE was already "Tekrar Oyna")
  └─ (no back — app root)

/play  (F03 screen; F05 additions)
  ├─ on load: journeyLevel ∈ 4..6 AND kv['journey_col_tutorial_ack'] absent
  │      ─▶ COLUMN MICRO-TUTORIAL overlay (dim board + gesture ghost + one line)
  │            player performs a column-axis drag  ─▶ overlay fades, ack persists, play continues
  │            player performs a row drag / does nothing  ─▶ overlay stays (gentle re-prompt)
  │            player leaves (back → /)  ─▶ ack NOT set; re-shows next 4–6 entry
  ├─ win ─▶ F04 win choreography ─▶ CompletionPanel (re-weighted CTAs, §7.4)
  │            unlock write fires (JourneyProgressRepo.markCompleted, fire-and-forget)
  │            Next Level ─▶ pushReplacement /play (journeyLevel=N+1)   [N<30 & content present]
  │                     ─▶ context.go('/') → terminal    [N==30 or N+1 missing]
  │            Retry ─▶ retryFromCompletion() (F04, in place)
  │            Close / back ─▶ /
  └─ chevron: F03 rule (quiet, top-left, hidden in `won`); always resolves to /
```

* **Friction removed:** no level-select map, no "are you sure", no confirm on replay. CONTINUE is one tap to the right level. The tutorial gates on *doing*, not reading.
* **Wait states:** the `journey_progress` read is local + seeded → effectively instant; the home renders the ring in its dim state for at most a frame, never a spinner.

### Header / top bar behaviour

| Surface | System header | Custom top bar | Back affordance | Returns to |
| --- | --- | --- | --- | --- |
| Home (`/`) | none | none | **none** (app root) | — |
| Home — terminal | none | none | none | — |
| `/play` + micro-tutorial | none | none | F03's quiet `‹` chevron (top-left), works during the overlay | `/` (`_popToCaller`, with a `!canPop → context.go('/')` fallback) |
| `/play` + CompletionPanel | none | none | chevron **hidden** in `won`; panel CTAs own exit | Next → N+1 `/play` (replace) · Retry → in place · Close/back → `/` |

* Portrait-locked (inherited). No confirm dialogs anywhere in F05.

---

## 5. Visual System

### Background Direction

* **The F03 stage, verbatim** — full-bleed vertical gradient `stage-0 (#0B0C16)` → `stage-1 (#141322)`; one large soft radial spotlight `stage-glow (#2A2350)` at ~12–14 % peak, centred slightly above the ring's centre; corner vignette `#000` ~18 %; optional 2–3 % grain. The home is the **same lit stage** as the play screen — a player moving `/` ⇄ `/play` feels one continuous space.
* Never a flat fill; never a top-gradient / bottom-panel split.

### Surface Direction

* **Progress ring** — not a surface, a **drawn luminous object** (a `CustomPainter`):
  * *track* (all 30 tick positions): each locked tick is a 3 pt rounded-cap radial stroke, ~12 pt long, colour `muted` @ 30 %, no glow.
  * *completed run*: the contiguous leading ticks in `amber`, full opacity, with **one** soft outer glow spanning the whole filled arc (`#FFE9C2` ~10 %, blur ~14) — not 30 separate glows.
  * *current node*: the tick at `currentLevel` in bright `amber` + a small filled dot (~5 pt) at its outer tip with a tight glow; if that level is **in-progress**, the dot gets a 1.5 pt `cyan` ring and a slow 4 s breathing pulse (±6 % opacity) — cyan is F03's "active" signal.
  * *terminal*: all 30 `amber`, the whole ring glows, one restrained bloom on entry.
* **CONTINUE pill** — F04's `_RetryCta` treatment: filled vertical gradient `amber → amber-lo`, `ink-amber` text (weight 700, ~17 pt, tracking +0.3), radius 16, a soft amber drop shadow (`#4DFFB020`, blur 20, y+6), height 54, width ≈ 66–72 % of screen. It nests visually into the ring's bottom gap (its top edge just inside the arc's inner radius).
* **No cards, no borders elsewhere.** The wordmark, the count, the caption all sit directly on the stage. Three tiers: **stage** (deep) < **ring glow / count** (lit) < **CONTINUE pill** (raised, saturated). Nothing flat.

### Color Direction

All from `PlayTheme` — **no new tokens.**

| Role | Token | Use here |
| --- | --- | --- |
| Stage | `stage-0` / `stage-1` / `stage-glow` | background gradient + spotlight |
| Progress — done / current | `amber` (`#FFC24B`) + `amber-lo` for the CTA gradient | completed ticks, current node, CONTINUE fill |
| Progress — locked | `muted` (`#8A88A0`) @ 30 % | locked ticks |
| Progress — resume accent | `cyan` (`#5AA9FF`) | the in-progress node's ring + pulse (only there) |
| Count figure | `paper` (`#F4EFE6`) | the big `N` |
| "/ 30", labels, caption | `muted` | `/ 30`, `SEVİYE`, `Seviye 12` caption, micro-labels |
| Wordmark | `paper` | LOOPLET, with a whisper of `stage-glow` behind |
| CONTINUE text | `ink-amber` (`#2A1B00`) | on the amber pill |
| Terminal kicker | `amber` @ 80 % | `TAMAMLANDI` |
| Micro-tutorial dim | `#000` @ ~45 % | board dim during the overlay |
| Micro-tutorial ghost / rails | `cyan` | the gesture ghost + the ignited column rails (F03's drag language) |

* Amber = progress + the one CTA; cyan = "active / resumable / the gesture you're learning"; nothing else is saturated. No pure `#000` / `#FFF`.

### Typography Direction

Reuse `PlayTheme` styles; no new roles.

* **LOOPLET wordmark:** `paper`, weight 800, ~30–34 pt, letter-spacing ~5–6 pt (a touch wider + larger than the current 28/4 debug home — it is the hero when there's no board). Optional: the two centre letters slightly tighter so the word reads as a unit. Type-only, no logo asset.
* **Count `N`:** `movesNumber` scaled up — tabular lining, weight 700, `paper`, ~46–54 pt. Animates a single count-tick + 1.0→1.06→1.0 pulse (140 ms) when it changes (a level completed while the home was visible).
* **`/ 30`:** `completionStat` at ~22–24 pt, `muted`, baseline-aligned to the `N`.
* **`SEVİYE` / `TAMAMLANDI` micro-label:** `microLabel` (all-caps, weight 600, tracking +1.4, `muted`; the terminal kicker in `amber` @ 80 %).
* **`Seviye 12` caption** (under CONTINUE): `helper` (weight 400, `muted`, ~13 pt); for an in-progress level add `· sürüyor` in the same style.
* **CONTINUE label:** F04's CTA text spec (17 pt / w700 / `ink-amber`).
* **Micro-tutorial line:** `helper` at ~14 pt, `paper`, one line, centred, positioned clear of the board.

---

## 6. Layout Structure

### Home surface (portrait)

```
┌───────────────────────────────────────────────┐  ← top safe-area inset
│                                               │  ~10–14 % stage air
│                 L O O P L E T                 │  WORDMARK (hero)
│                                               │  ~28–36 pt air
│              ╭───────────────╮                │
│           ╭──┤    ▏▎▍  fill  ├──╮             │  PROGRESS RING  (~62 % screen width)
│          │   │      4        │   │            │   300° arc, 60° gap at bottom
│          │   │    ─────      │   │            │   30 ticks · completed run amber + one glow
│           ╰──┤   / 30        ├──╯             │   current node bright (+ cyan ring if in-progress)
│              ╰───┐  SEVİYE ┌──╯               │   centre: N  /  30  ·  SEVİYE
│              ┌───┴─────────┴───┐              │
│              │   D E V A M   E T   │          │  CONTINUE pill (nested in the ring's gap)
│              └───────────────────┘            │
│                   Seviye 12                   │  caption (muted)
│                                               │  ~14–18 % stage air
└───────────────────────────────────────────────┘  ← bottom safe-area inset (min 16 pt)
```

* **Spacing rhythm:** 4 / 8 pt. Vertical beats: safe-area → wordmark (10–14 % air) → ring (28–36 pt below the wordmark) → CONTINUE (nested, top edge ~inside the arc inner radius) → caption (10 pt below CONTINUE) → bottom air (14–18 %). The air above and below is deliberate **stage** negative space, not emptiness — the eye lands on the ring.
* **Ring geometry:** outer diameter `min(screenWidth * 0.62, availableHeight * 0.42)`; stroke ticks ~3 pt; arc 300° (gap 60° centred on bottom). The count sits at the geometric centre. CONTINUE's width ≈ 66–72 % screen, centred, its top overlapping the arc gap.
* **Shrink strategy (short devices):** the ring diameter shrinks first (down to a floor of ~180 pt); then the wordmark→ring air compresses (to ~16 pt); the wordmark, the count, and the CONTINUE pill never shrink. The layout never scrolls.
* **Composition intent:** one vertical spine — wordmark, ring+count, CONTINUE — optically centred on the stage. No corners used, no floating chrome.

### Micro-tutorial overlay (over the F03 `/play` board)

* A full-screen dim layer (`#000` @ ~45 %) **above** the board and target rail, **below** F03's top-bar chevron.
* Centred over the board: an animated **gesture ghost** — a rounded finger/disc + a vertical double-arrow (↕), looping a ~1.4 s up-then-down drag motion; the board's vertical **loop-rails ignite** cyan at the top/bottom edges during the ghost's motion (reusing F03's drag affordance).
* One line of copy above or below the board (whichever has room), `helper` / `paper`: *"Sütunları da kaydırabilirsin — yukarı ya da aşağı."* / *"You can slide columns too — up or down."*
* No button. No "skip". The overlay clears only when the player performs a column-axis drag.

### CompletionPanel (F04 — re-weighted, layout otherwise unchanged)

* The panel's structure, star reveal, `N / 3` caption, `SEN / OPTİMAL / EN İYİ` triptych, markers, and `Close` are **exactly as F04 shipped**. Only the **two CTA rows swap treatment + order** per §7.4.

---

## 7. Component Decisions

### 7.1 Progress ring

* **Role:** the campaign-momentum read — the home's hero.
* **Weight:** the largest object on the home; the count at its centre is the loudest number.
* **States:** `0 / 30` (all-dim track + one bright node at level 1) · mid (`N` amber ticks + node) · in-progress (node gets a cyan ring + slow pulse) · `30 / 30` (full amber, one bloom on entry) · loading (dim track, count hidden ≤ 1 frame).
* **Why not generic:** not a horizontal bar, not a percentage donut with a label slapped beside it — a 30-tick loop that is *obviously meant to fill*, tied to the product name and F03's rail motif. The greyscale read is the length of the amber run.

### 7.2 CONTINUE CTA

* **Role:** one tap back into the campaign — the only real action on the home.
* **Weight:** dominant. F04's `_RetryCta` treatment (amber→amber-lo fill, `ink-amber` w700, soft amber shadow), ~66–72 % width, nested into the ring's bottom gap.
* **Label logic:** `DEVAM ET` normally; `TEKRAR OYNA` in the terminal state. Caption beneath: `Seviye {N}` (+ `· sürüyor` when resuming an in-progress level).
* **Pressed:** scale 0.97 + a 2 px inward nudge (F03's control feel). No confirm.
* **Why not generic:** it is F03/F04's established CTA — one warm dominant action, not a "default button".

### 7.3 Column micro-tutorial overlay

* **Role:** teach the column shift on first entry to the 4–6 band; gate on the player doing it (AC4/AC11).
* **Weight:** commanding but diegetic — it dims the board and points at the gesture; it does not paste a modal card of text.
* **State behaviour:** *shown* (dim + looping ghost + one line) → *satisfied* (any gesture F03 resolves to `MoveAxis.column` — applied or bounced; a committed vertical intent — fades over ~200 ms, `ack` persists) → *re-prompt* (a row gesture or 6 s idle → the ghost does one emphatic cycle + the line pulses once). Leaving via the chevron does **not** set `ack`.
* **Why not generic:** no "Got it" button to tap past without learning; the dismissal *is* the lesson. Reuses F03's spotlight-dim + cyan-rail language so it feels part of the same game, not a bolted-on tutorial SDK.

### 7.4 CompletionPanel CTA weighting [resolves `architecture.md §16`]

Now that `Next Level` is live (F05 supplies `onNextLevel`), the amber pill goes to the action the player most likely wants:

| Result | Primary (amber `_RetryCta` pill, top of the stack) | Secondary (ghost pill — `muted` outline, `muted` label) | Tertiary |
| --- | --- | --- | --- |
| **3★ / `isPerfect`** | **SONRAKİ** (`Next Level`) | **YENİDEN** (`Retry`) | `Kapat` |
| **1–2★ (not perfect)** | **YENİDEN** (`Retry`) — unchanged from F04 | **SONRAKİ** (`Next Level`) — now **enabled**; drop the `· yakında` suffix | `Kapat` |
| **no-optimal fallback** | **YENİDEN** (`Retry`) | **SONRAKİ** (`Next Level`, enabled) | `Kapat` |
| **level 30 / last available** | per the star result above | the other CTA — `Next Level` still renders; it routes to the terminal state | `Kapat` |

* This is a **weighting + order swap only** — the two CTA widgets already exist in F04's panel (`_RetryCta` = amber pill, `_NextLevelCta` = ghost pill). At 3★ they trade treatment (the ghost pill's build takes the label `SONRAKİ`, the amber pill's build takes `YENİDEN`) and swap stack order (primary always on top). Everything else in the panel is untouched.
* **Never** two amber pills; **never** an equal-weight pair. Exactly one amber pill per panel.
* The `· yakında` / disabled affordance is **gone** in F05 (F05 always supplies a real handler — even level 30's routes to the terminal). Keep F04's `RatingStrings.soon` string for a possible future disabled state; unused now.

### 7.5 LOOPLET wordmark

* **Role:** identity + the home's visual anchor above the ring.
* **Weight:** the second-loudest thing on the home (after the count). `paper`, w800, ~30–34 pt, wide tracking, a whisper of `stage-glow` behind it. Type-only.
* **Why not generic:** deliberate tracking + a faint stage-glow halo make it feel *placed*, not a default `Text('LOOPLET')`.

---

## 8. State Design

| State | How it looks | How it differs | What it feels like |
| --- | --- | --- | --- |
| **home — mid-campaign** | wordmark; ring with `N` amber ticks + a bright current node; `N / 30`; amber CONTINUE; `Seviye N+1` caption | baseline | "momentum — one tap and I'm back" |
| **home — brand new (0/30)** | ring all-dim except a single bright node at level 1; `0 / 30`; CONTINUE `DEVAM ET` / `Seviye 1` | no amber run yet | "a fresh 30-level journey; I start here" |
| **home — in-progress level** | the current node carries a `cyan` ring + a slow breathing pulse; caption `Seviye N · sürüyor` | one node is cyan-accented and alive | "I have an unfinished level waiting" |
| **home — all 30 complete (terminal)** | full amber ring + a soft one-shot bloom on entry; centre `30 / 30` + `TAMAMLANDI` kicker (amber); CONTINUE relabelled `TEKRAR OYNA` / caption `Seviye 1` | the ring is closed and glowing; the CTA is "replay" | "I finished the whole thing" — earned, not a dead-end |
| **home — loading** | stage + wordmark instant; ring track dim, count hidden; no spinner | ring is skeletal for ≤ 1 frame | never a blank flash |
| **micro-tutorial — shown** | board dimmed 45 %; looping vertical gesture ghost; cyan rails ignite on the ghost's motion; one line of copy | the board is "held" and pointed at | "oh — columns move too; let me try" |
| **micro-tutorial — re-prompt** | the ghost does one emphatic up-down cycle; the copy line pulses once | a nudge, not a scold | "no, *this* way — vertically" |
| **micro-tutorial — satisfied** | overlay fades over ~200 ms; play resumes normally; never shown again for this player | it's gone, and it stays gone | "got it" — learned by doing |
| **CompletionPanel — 3★** | amber pill on `SONRAKİ` (top), ghost pill on `YENİDEN` | the loud button is NEXT | "I nailed it — onward" |
| **CompletionPanel — 1–2★** | amber pill on `YENİDEN` (top), ghost pill on `SONRAKİ` (enabled) | the loud button is RETRY; NEXT is a real secondary | "close — let me beat that" |
| **focused (assistive tech)** | 2 pt `amber` focus ring, 2 pt offset, on CONTINUE / the panel CTAs / the ring (one focusable node announcing "12 of 30 levels complete, current level 12") | a crisp on-brand ring | reachable, on-brand |

---

## 9. Premium Differentiators (concrete)

1. **Progress-as-the-loop** — a 30-tick ring that is obviously meant to fill, named after the product, rhyming with F03's luminous rails; momentum is the composition, not a corner widget.
2. **One continuous glow on the completed run** — not 30 individually-glowing dots; the filled arc reads as a single lit stroke.
3. **The current node** — a bright amber tip-dot; **cyan ring + breathing pulse when the level is resumable** — one glance tells you "you have an unfinished level".
4. **CONTINUE nested into the ring's gap** — the CTA emerges from the loop's base; wordmark → loop → CONTINUE is one object, one vertical spine.
5. **The home shares F03's exact stage** — same gradient, spotlight, vignette; `/` ⇄ `/play` is one continuous lit space, not two different apps.
6. **The terminal state is earned, not a dead-end** — a closed glowing ring + one restrained bloom + `TAMAMLANDI` + a repurposed CTA (`TEKRAR OYNA`), never a hidden/greyed button.
7. **The micro-tutorial is diegetic and gated on doing** — board-dim + a looping gesture ghost + F03's cyan rails; no "Got it" button; the dismissal *is* the lesson; it survives a force-quit until the player actually shifts a column.
8. **Exactly one amber pill per completion panel, chosen by the result** — 3★ makes NEXT loud, 1–2★ keeps RETRY loud; the replay hook and the progress hook each get the emphasis when it matters.
9. **Tabular count with a settle-tick** — the "`N` / 30" figure count-ticks + pulses when a level completes while the home is visible (live via `JourneyProgressRepo.watch`).
10. **Zero new tokens** — the whole feature is drawn from F03's `PlayTheme`; identity parity is structural, not a re-theme.

---

## 10. Anti-Patterns to Avoid (F05-specific)

* A flat home: wordmark on top, a thin grey progress bar, a blue "Continue" button (Direction B — the rubric fails it).
* A full level-select map / grid of 30 level tiles — explicitly out of MVP scope; the ring + CONTINUE is the whole navigation.
* A percentage donut with "40 %" and a label beside it — generic dashboard language; use the tick-ring + "`N` / 30".
* 30 separately-glowing dots (noise) instead of one continuous glow on the filled run.
* A spinner / skeleton shimmer on the home while `journey_progress` reads (it's local + instant).
* A modal card of tutorial text with a "Got it" / "Skip" button — the tutorial must be diegetic and action-gated.
* The tutorial blocking the whole screen so the player can't see the board they're meant to act on.
* Two amber pills (or two ghost pills) on the completion panel; an equal-weight CTA pair.
* Keeping the `· yakında` affordance on `Next Level` in F05 (it's always enabled now).
* A dead / hidden primary CTA in the terminal state.
* A DAILY button, a Settings icon, or any F10 menu element creeping onto this surface.
* Re-theming — introducing colours/type outside `PlayTheme`, or a lighter "menu" background that breaks stage parity with `/play`.

---

## 11. Frontend Handoff

### Must not be broken (contract-level UI decisions)

* **The home is on F03's exact stage** — `stage-0 → stage-1` gradient, the radial spotlight, the vignette. `/` and `/play` must feel like one lit space.
* **One vertical spine:** LOOPLET wordmark → progress ring (count at its centre) → CONTINUE nested in the ring's bottom gap → `Seviye N` caption. Deliberate stage air above and below.
* **The ring is a drawn object** (`CustomPainter`), 30 ticks, ~300° arc / 60° bottom gap. **Completed run = one continuous amber glow**, not per-tick glows. Locked = `muted` @ 30 %. **Current node = a bright amber tip-dot**; **in-progress ⇒ that node gets a `cyan` ring + a slow (~4 s, ±6 %) breathing pulse** — the only place `cyan` appears on the home.
* **The count is `N` / `30`** (tabular, `paper` `N` big, `muted` `/ 30` smaller) + a `SEVİYE` micro-label — **not** a percentage, **not** a donut label. It **settle-ticks + pulses** when it changes (bind to `JourneyProgressRepo.watch`).
* **CONTINUE** = F04's amber `_RetryCta` treatment, ~66–72 % width, dominant, nested into the ring gap. Label `DEVAM ET` / caption `Seviye {N}` (+ `· sürüyor` for in-progress); terminal → `TEKRAR OYNA` / `Seviye 1`.
* **Terminal state:** full amber ring + **one** restrained bloom on entry + `30 / 30` + `TAMAMLANDI` (amber) + CONTINUE **repurposed** to `TEKRAR OYNA` (→ Level 1). Never hidden, never greyed.
* **Home chrome:** app root — **no back affordance**, no system header, portrait-locked.
* **No spinner** on the home; render the ring's dim state for the ≤ 1-frame read.
* **Micro-tutorial:** a dim layer (`#000` ~45 %) **above the board, below F03's chevron**; a **looping vertical-drag gesture ghost** + F03's **cyan loop-rails igniting** on its motion + **one line** of copy. **No button.** Clears **only** on a gesture F03 resolves to `MoveAxis.column` (applied or bounced). Re-prompt (one emphatic ghost cycle + copy pulse) on a row gesture / 6 s idle. Leaving via the chevron must **not** persist `ack`. Fade-out ~200 ms.
* **CompletionPanel weighting (§7.4):** exactly **one amber `_RetryCta`-style pill per panel**, primary, top of the stack. **3★ / `isPerfect` → the amber pill is `SONRAKİ`**, the ghost pill is `YENİDEN`. **1–2★ / no-optimal → the amber pill stays `YENİDEN`**, the ghost pill is `SONRAKİ` (**enabled**, no `· yakında`). `Kapat` unchanged, tertiary. Everything else in F04's panel (star reveal, `N / 3`, triptych, markers, six variants) is **untouched**.
* **Portrait-locked; no confirm dialogs; no system header** anywhere in F05.

### Flexible (FE may tune within these bounds)

* Ring: outer diameter (`min(w*0.60–0.66, h*0.40–0.44)`), tick length (10–14 pt) + weight (2.5–3.5 pt), arc sweep (290–310°) + gap (50–70°), glow blur (±4 px) / opacity (±3 %).
* Wordmark size (30–34 pt) + tracking (5–6 pt); the count figure size (46–54 pt).
* The in-progress node's pulse period (3–5 s) + amplitude (≤ 8 %).
* The gesture-ghost cycle (1.2–1.6 s) + the re-prompt idle threshold (5–8 s).
* Whether the tutorial copy sits above or below the board (device-dependent — keep it clear of the board and the chevron).
* Terminal CONTINUE target — Level 1 (recommended) vs the last completed level; FE's call, documented.
* Exact `JourneyStrings` keys / TR wording — placeholders below; PO / localization owns final copy (same track as F03's `PlayStrings` / F04's `RatingStrings`).

### Do not cheapen

* Don't replace the ring with a horizontal `LinearProgressIndicator` + a label.
* Don't render 30 discrete glowing dots; the completed run is one lit stroke.
* Don't give the home a lighter / different background than `/play`.
* Don't add a "Got it" / "Skip" button to the micro-tutorial, or make it a text modal.
* Don't leave `Next Level` showing `· yakında` in F05, and don't ship two amber pills on the panel.
* Don't let the terminal state present a dead or hidden primary button.
* Don't fall back to system-regular weight for the wordmark or the count.

---

## 12. Self-Review Against Rubric

| Criterion | Score | Rationale |
| --- | --- | --- |
| Visual Hierarchy | 10 | One hero (the ring + its count), one dominant CTA (CONTINUE), wordmark clearly secondary, caption quiet. First-3-seconds read is designed: "N / 30 → CONTINUE". |
| Layout & Composition | 9 | A single optically-centred vertical spine with deliberate stage air; a defined ring-first shrink strategy; no scroll. −1: a 300° ring + a nested CTA needs care to balance on very tall/short aspect ratios. |
| Surface & Depth | 9 | F03's layered stage (gradient + spotlight + vignette + grain), a drawn luminous ring with a single glow, a raised saturated CTA. Three real tiers. −1: the home has fewer surfaces than the play screen by nature — depth rides on the ring glow + the CTA. |
| Typography | 9 | Reuses F03's roles — tabular count with a settle-tick, tracked micro-labels, a considered wordmark. −1: no new type expression (correct restraint for a minimal home). |
| CTA Quality | 10 | One dominant amber CONTINUE, nested into the ring; the completion-panel rule guarantees exactly one amber pill and puts it on the result-appropriate action. |
| State Design | 10 | home (mid / new / in-progress / terminal / loading), micro-tutorial (shown / re-prompt / satisfied), panel (3★ / 1–2★), focused — all specified with distinct, felt treatments and non-colour cues (the amber-run length; the cyan resume ring; the closed terminal ring). |
| Product Feel | 10 | Progress-as-the-loop + shared F03 stage + a diegetic gated tutorial = an App-Store-featured campaign home tied to the product's identity, not a menu. |
| Modernity | 9 | 2026 dark, atmospheric, restrained motion, a drawn progress object over a chart widget. −1: a progress ring is a known idiom — differentiation rides on the tick/glow execution + the loop framing. |
| Non-Generic Originality | 9 | The 30-tick loop as the home hero, CONTINUE nested in its gap, the cyan resume node, the action-gated diegetic tutorial. −1: "wordmark + progress + CTA" is inherently a familiar home structure; originality is in the ring + the stage parity. |
| Implementability | 9 | `CustomPainter` ring with concrete geometry, `PlayTheme` tokens only, defined states + shrink rules, a weighting swap on an existing panel. −1: the ring painter + the gesture-ghost animation need care to hit 60 fps and read cleanly at 30 ticks. |

**Total: 93 / 100** — within the target band (93–96). No fail conditions present (clear hero, dominant CTA, strong state design, layered surface, strong hierarchy, non-generic identity, "top mobile game" register). Finalized.

---

## 13. Assumptions

* **No brand palette / logo asset** → the LOOPLET wordmark is type-only on F03's `PlayTheme`; if an official logo/palette lands later, the wordmark + `amber`/`cyan`/`stage` tokens rebind, the structure holds.
* **Turkish primary** → copy here is illustrative TR (+ EN). Proposed `JourneyStrings` keys: `continueLabel` (`DEVAM ET`), `replayLabel` (`TEKRAR OYNA`), `levelCaption` (`Seviye {n}`), `inProgressSuffix` (`· sürüyor`), `progressUnit` (`SEVİYE`), `allCompleteKicker` (`TAMAMLANDI`), `columnTutorialHint` (`Sütunları da kaydırabilirsin — yukarı ya da aşağı`). PO / localization confirms.
* **The count is `|completedLevels ∩ {1..30}|`** (`architecture.md §6 progressCount`), not `highestUnlockedLevel` — a player can have unlocked more than they've completed; the ring's amber run = *completed*, the bright node = *current* (= `currentLevel`).
* **The ring shows 30 ticks always** (even at 0 / 30) — the "shape to fill" is visible from the first launch.
* **The micro-tutorial gate = a column-axis `endDrag`** (committed vertical intent), applied or bounced — a player who attempts an illegal column move still learned the gesture. FE may tighten to "applied only" if bounced-column proves too permissive; document the choice.
* **Terminal CONTINUE → Level 1** for replay (recommended); progress is not reset — it is pure replay (F04's `personal_best` + the star chase still apply).
* **Reduced motion** (`MediaQuery.disableAnimations` / `accessibilityFeatures.disableAnimations`): the count settle-tick, the in-progress pulse, the terminal bloom, and the gesture-ghost loop all render as their **static end state** (ghost shown static, arrow visible; ring fully drawn; count final). The tutorial still gates on the column shift.
* **Screen-reader:** the ring is one `Semantics` node ("`N` of 30 levels complete — current level `N+1`"); CONTINUE announces its target level; the micro-tutorial announces its hint line. Full assistive campaign navigation is out of F05 scope (consistent with F03).

---

## 14. Needs Tech Lead Clarification

1. **Terminal CONTINUE target** — this handoff picks **`TEKRAR OYNA` → Level 1** (a working primary CTA over a hidden one). Confirm, or specify a different replay entry (last completed level / a lightweight picker — noting the "no level-select map" MVP constraint).
2. **Micro-tutorial gate strictness** — dismiss on any column-axis `endDrag` (applied **or** bounced), or only on an **applied** column move? This handoff recommends the former (the gesture is the lesson). Non-blocking; FE + QA can tune on device.
3. **Wordmark treatment** — type-only with a faint `stage-glow` halo is assumed. If a logo asset is expected before F05 ships, say so (it would replace the `Text` wordmark; the layout slot is unchanged).
4. **Microcopy** — the `JourneyStrings` keys above are placeholders; PO / localization owns final wording (same track as F03 / F04).

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** F05-UI — `ui-design.md` delivered. Resolves `architecture.md §17 [PENDING — UI]`: (1) the minimal home surface — Direction A "The loop, filling" (F03's stage; a 30-tick progress ring as the hero with `N / 30` at its centre; a dominant CONTINUE nested in the ring's gap; the in-progress cyan resume node); (2) the "all 30 complete" terminal variant (closed glowing ring + one bloom + `TAMAMLANDI` + CONTINUE → `TEKRAR OYNA`); (3) the levels 4–6 column micro-tutorial overlay (diegetic board-dim + a looping gesture ghost + F03's cyan rails + one line, action-gated on a column shift, re-shows until done); (4) the F04 `CompletionPanel` per-outcome CTA-weighting rule (3★ → amber pill on `SONRAKİ`; 1–2★ → amber pill stays on `YENİDEN`; `Next Level` always enabled, `· yakında` dropped). Reuses F03's `PlayTheme` — no new tokens. Self-review 93/100.
* **Remaining Tasks:** F05-FE.CONTENT / .GATE / .PROGRESS / .UNLOCK / .NAV / .HOME / .TUTORIAL / .STRINGS+.TESTS — implement against the LOCKED `architecture.md` + this handoff. Then QA → Tech Lead close (gated also on `F06-CONTENT`).
* **Blockers:** none for F05-FE. The four `Needs Tech Lead Clarification` items are non-blocking (sensible defaults chosen). `F06-CONTENT` remains the F05 `Done` prerequisite (user decision, tracked).
* **Status Suggestion:** Ready for Frontend.

---

## 15. Sonraki Komut

```
Run Frontend/Mobile Developer
```
