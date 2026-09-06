# F04 — star-rating-and-personal-best: UI Design Handoff

> UI Designer output. Contract authority stays in `architecture.md` (§4 star numbers, §5 `CompletionResult`, §6 win-path wiring, §7 panel content + state variants, §8 route/nav). This handoff resolves `architecture.md §13 [PENDING — UI]` and must not change the contract.
> Mandatory references: `design/design-doctrine.md`, `design/premium-ui-rubric.md`, `features/f03-puzzle-play-session/ui-design.md` (Direction A — this panel has **chrome / atmosphere parity** with it). No user-specified aesthetic → default premium doctrine applies.
> Reuses F03's `PlayTheme` tokens (`app/lib/play/play_theme.dart`). **No new colour tokens.**

---

## 1. Feature Summary

The **real completion panel** — the reward reveal at the end of a solved puzzle. It replaces F03's minimal seam sheet (`app/lib/play/widgets/completion_sheet.dart`). It rises over F03's dimmed + receded board and the amber L→R seam bar, on the same 40 % scrim, in the same raised dark panel family.

**Primary user intent on this surface:** *feel the result, then decide to go again.* The player has just built the word; this panel tells them **how good that was** (1–3 stars vs the solver-optimal move count) and puts the **replay hook** in front of them — your moves vs OPTIMAL vs your personal best, legible at a glance, with the gap to Perfect made explicit.

**UI/UX job:**
* make the **star rating the reveal / hero** — a bounded (≤ ~800 ms), deterministic, *earned* moment, not a static row of icons;
* make the **your-moves / OPTIMAL / personal-best** comparison instantly readable and quietly motivating (the "so close to Perfect" hook — `prd.md §7`, Replay Rate > 20 %);
* render **six outcome variants** distinctly (`firstClear` / `newBest` / `matchedBest` / `noImprovement` / `Perfect` / no-optimal fallback), each with a **non-colour cue**;
* keep **Retry primary** and **Next Level a quiet, honestly-disabled seam** (`[PENDING — F05]`);
* stay inside F03's product family — this is F03's sheet *fully realised*, not a new surface.

---

## 2. Design Direction

### Direction A — "The seam becomes the panel" (struck stars on the dark stage)

* **Visual character:** F03's win choreography ends by drawing a solid amber **seam bar** left-to-right under the winning row. In Direction A that seam **docks** — the completion panel slides up and the seam becomes the panel's top edge: a 3 pt amber **spine** across the panel head, glowing softly, fading to transparent at both ends exactly like F03's seam. The panel is F03's exact raised dark surface (`#191A2B`, top radius 28, 1 px top highlight, long upward shadow) over the same 40 % scrim, with the dimmed/blurred board and the amber winning row still visible in the strip above it. Inside: **three "struck" stars**. At rest a star is a **recessed socket** — a star-shaped cut *into* the panel surface (`plate` fill, inner top shadow, no glow), unmistakably *empty*. On reveal, each earned star **strikes**: it fills with the amber backlit gradient (`amber → amber-lo`), rises proud of the surface, blooms a soft radial glow once, and pops 1.0 → 1.15 → 1.0. Unearned stars **stay sockets** — sunk, dark, no glow. Below the stars, the your-moves / **OPTIMAL** / best comparison sits on a recessed inset track (echoing the board plate), with the gap to optimal shown as a small amber `+N` on the divider. Retry is F03's amber pill, unchanged.
* **Why it's strong:**
  * **Literal continuity with F03** — the seam the player just drew is the line this panel hangs from; the reveal is one connected gesture from win → panel, not a context switch.
  * **The board stays on screen** — the amber winning row is visible above the panel, so "I built that" and "here's how good it was" and "go again" are one composition. That connection *is* the replay hook.
  * **Non-colour cue is structural, not bolted on** — earned = raised + filled + glowing; unearned = a recessed socket. The star count reads in greyscale and by shape, before any Semantics label. Perfect is the only state where all three stand proud.
  * **Reuses F03's surface tokens verbatim** — true parity, not a lookalike; nothing new to keep in sync.
  * Reads as an App-Store-featured puzzle game's win moment: atmospheric, restrained, tactile.
* **Risks:** the struck-star treatment needs care — sockets must read as *empty slots*, not broken tiles; the bloom must be one restrained pulse, not a particle burst (F03's anti-pattern list forbids confetti). The custom star glyph must be drawn (not `Icons.star`) or it collapses to a generic results card.

### Direction B — "Trophy card takeover" (centred achievement card on a full scrim)

* **Visual character:** the board is fully hidden behind a 70 % scrim + heavy blur; a centred floating card animates in (scale + settle), stars in a large arc across its head, a ribbon/medal motif, the stats as a stacked list, Retry and Next Level as two full-width buttons.
* **Why it's strong:** a bigger, more discrete "achievement unlocked" beat; the card can be more ornate; the arc of stars is a familiar, immediately-legible reward shape.
* **Risks (why it loses):** it **breaks F03 parity hard** — F03's sheet rises over the *still-visible* board + seam; a centred card that hides the board severs the "I made that row" payoff and throws away the seam-docking continuity. The "gacha reward card" language tips toward exactly the gamey/childish register F03's Direction A explicitly disciplined against, and the ornate floating card is the canonical *generic results card* the doctrine and rubric fail. It's the safer, louder, more templated option.

### Selected Direction — **A ("The seam becomes the panel")**

The doctrine's default-when-unspecified rules point at A: more premium, less generic, stronger continuity, more atmospheric. A extends F03's win choreography instead of interrupting it, keeps the board and the winning row in frame so the panel *is* the replay hook, reuses F03's surface tokens for real parity, and gets its mandatory non-colour star cue from structure (raised vs recessed) rather than colour. B is the templated "results card" the rubric rejects and it discards F03's hard-won continuity. **We take A, with discipline:** one restrained bloom per star, a drawn faceted star glyph, sockets that read as empty slots, the amber accent reserved for stars + spine + `+N` + Retry.

---

## 3. Screen Goals

| Surface | Goal | What the player must understand in 3 seconds |
| --- | --- | --- |
| **Completion panel — reveal** | Deliver the star rating as an earned moment | "Two of three stars just lit up. I did well — not perfect." |
| **Completion panel — at rest** | Show the result + the gap + the next step | "I solved TABLA in 9. Optimal is 6 — three away. My best is 7. Retry." |
| **`newBest` variant** | Recognise the improvement | "That underline + 'New best!' — I beat my old best." |
| **`Perfect` variant** | Reward true mastery | "All three stars are up and 'HARİKA' landed. That was optimal." |
| **`noImprovement` variant** | Show the retained better best without scolding | "This run was worse, but my 7 is still there to chase." |
| **no-optimal fallback (dev only)** | Not look broken | "Solved. (No rating on this one.) Retry." |

First 3 seconds, always: **stars first** (how good), **then** the OPTIMAL number (the target), **then** Retry (what next). The solved word is confirmation, not headline.

---

## 4. UX Flow Direction

```
F03 win sequence (≤600 ms: amber row + L→R seam bar + one bloom, board recedes 12% + 1.5px blur)
  │
  ▼
F04 completion panel slides up over the 40% scrim (~260 ms)  ── seam bar docks as the panel spine
  │   stars are empty sockets; word + triptych present but held at ~30% opacity
  ▼
STAR REVEAL  (bounded, deterministic, ≤ ~800 ms total — no infinite animation)
  ├─ ~120 ms  star 1 strikes  (fill + rise + one bloom + 1.0→1.15→1.0)      [always: stars ≥ 1]
  ├─ ~260 ms  star 2 — strikes if earned, else a faint sweep passes the socket
  ├─ ~400 ms  star 3 — strikes if earned, else stays a socket
  ├─ ~560 ms  IF Perfect (3/3): "HARİKA" struck plate drops in (top beat) + all 3 stars glow-pulse once
  ├─ ~560 ms  triptych (SEN / OPTİMAL / EN İYİ) fades + rises to full opacity (staggered ~60 ms)
  └─ ~700 ms  IF newBest: the EN İYİ cell's amber underline wipes in L→R + the ▲ caret lands
  ▼
AT REST  (all animation settled; pumpAndSettle resolves)
  ├─ Retry (primary)      → PlaySessionController.retryFromCompletion()  → panel dismisses, board re-lights, F03 [idle]
  ├─ Next Level (disabled) → inert; quiet [PENDING — F05] affordance (F05 wires the Journey advance)
  └─ Close / system back  → pop to caller (F03 _popToCaller); back chevron stays hidden in `won`
```

* **Friction removed:** no "you got N stars" dialog, no tap-to-continue gate, no separate score screen, no confirm on Retry. The panel reveals itself and waits.
* **Wait state:** the personal-best read-back (`architecture.md §6`) is a local DB read — effectively instant. If it hasn't resolved when the panel opens, the **EN İYİ** cell shows a 1-line shimmer placeholder, then fills; on write/read failure it degrades to `—` (see §8 error state). The **stars never wait on persistence** — they are computed from `engine.moveCount` + `optimalMoves` and shown immediately.
* **Reduced motion:** if `MediaQuery.disableAnimations` is set, the panel appears with stars already struck, markers already in place — the *end state*, no stagger, no bloom.
* **Result state is the whole surface** — there is no "playing" underneath to return to except via Retry/Close.

### Header / top bar behaviour

* **No system header, no custom top bar** (inherited from F03). The back chevron is **hidden** in `won` (F03 rule) — the panel owns exit via its CTAs.
* **System / gesture back** = **Close** = pop to caller. Identical to F03.
* Portrait-locked (inherited). No confirm dialogs anywhere in F04.

---

## 5. Visual System

### Background Direction

* **No background of its own.** F04 inherits F03's stage: the `stage-0 → stage-1` gradient, the radial spotlight, the vignette, and — critically — **F03's `won` treatment left running behind the panel**: the board dimmed 12 % + blurred 1.5 px, the winning row still amber, the seam bar still drawn.
* Over that: F03's **40 % scrim** (`#000` @ 40 %), unchanged. The panel sits on the scrim.
* The strip of screen **above** the panel (~34–42 % of height) keeps the blurred board + amber winning row visible. This is deliberate — the panel is anchored to the thing the player just did.
* **Never** a fresh full-bleed colour, **never** hide the board completely, **never** a second competing glow.

### Surface Direction

* **Panel:** F03's `CompletionSheet` decoration, **verbatim** — `#191A2B` fill, `BorderRadius.vertical(top: 28)`, 1 px top border `#14FFFFFF`, `BoxShadow(#000 @50%, y-8, blur 32)`. Height **56–66 %** of screen (taller than F03's 42–50 % — more content), never full-screen.
* **Panel spine:** a 3 pt horizontal **amber bar** flush with the panel's top edge, gradient-faded to transparent at both ends (mirrors F03's seam bar), soft outer glow `#FFC24B` @ ~18 %, blur 12. Visually rhymes with the seam width and colour: *the seam docked here.*
* **Star socket (unearned):** a star-shaped recess cut into the panel surface — `plate` (`#0E0F1C`) fill, inner shadow from the top (`#000` @ 45 %, y+2, blur 6), **no** highlight, **no** glow. Reads as *below* the panel plane.
* **Star struck (earned):** the same star silhouette raised *above* the panel plane — vertical gradient `amber → amber-lo`, 1 px inner top highlight `#FFFFFF` @ 55 %, a tight contact shadow (`#000` @ 30 %, y+1, blur 3), and a soft outer bloom `#FFE9C2` @ ~14 %, blur 16 (echoes F03's backlit-keycap tile). A faint faceted centre line suggests a *struck medal*, not a sticker.
* **Comparison track (triptych):** a single recessed inset panel spanning the content width — fill a touch darker than the panel (`#12131F`, i.e. between `plate` and the panel; FE may derive or reuse `plate`), inner top shadow `#000` @ 35 %, radius 16, 1 px top highlight `#FFFFFF` @ 5 %. Echoes F03's board plate ("the numbers are inset, like the board is inset").
* **CTAs:** Retry = F03's `_RetryCta` amber pill, unchanged. Next Level = a *ghost* pill (no fill, 1 px `muted` @ 30 % stroke). Close = a `muted` text button.
* Three surface tiers again: **scrim/receded board** (deep) < **panel** (raised dark) < **struck stars** (raised, lit). The triptych track is a deliberate recess *within* the panel. Nothing is flat.

### Color Direction

All from `PlayTheme` — **no new tokens.**

| Role | Token | Value | Use here |
| --- | --- | --- | --- |
| Panel surface | (F03 `CompletionSheet`) | `#191A2B` | the panel |
| Panel top highlight | (F03) | `#14FFFFFF` | 1 px top border |
| Scrim | (F03 `ui-design.md` §5) | `#000` @ 40 % | over the receded board |
| Spine / stars / accent | `amber` / `amber-lo` | `#FFC24B` / `#FFB020` | docked spine, struck stars, `+N` gap, Retry fill, `newBest` underline, `HARİKA` plate text |
| Star socket | `plate` | `#0E0F1C` | recessed unearned star |
| Triptych recess | `plate` (or derived `#12131F`) | — | inset comparison track |
| Stat figures | `paper` | `#F4EFE6` | SEN / OPTİMAL / EN İYİ numbers, star `N / 3` caption digits |
| Solved word | `amber` @ ~85 % | — | subordinate word under the stars |
| Retry text | `ink-amber` | `#2A1B00` | on the amber pill |
| Labels / captions / Close / disabled | `muted` | `#8A88A0` | `HAMLE` / `OPTİMAL` / `EN İYİ` labels, `N / 3` caption, Close, Next Level stroke + label |
| OPTİMAL label accent | `amber` @ 70 % | — | marks the centre cell as *the target* |
| Danger | `danger` | `#E06A5A` | **not used** in F04 (no error icon on this panel) |

* Amber stays the only saturated warm (F03 rule holds). Cyan is **not** used on this panel — the drag/energy colour has no role in a resolved state.
* No pure `#000` / `#FFF`.

### Typography Direction

Reuse `PlayTheme` styles; no new type roles.

* **Star `N / 3` caption:** `microLabel` (11 pt, w600, tracked, `muted`), tabular digits — sits directly under the star row. A blunt, honest, greyscale-safe readout of the count.
* **`HARİKA` / Perfect plate:** `microLabel.copyWith(fontWeight: w800, fontSize: 13, color: amber, letterSpacing: 3)` — a struck caps wordmark, the top beat.
* **`YENİ REKOR` / New best! ribbon:** `microLabel.copyWith(fontWeight: w700, color: amber, letterSpacing: 2)` — small, above/beside the EN İYİ figure, paired with a `▲` caret.
* **Solved word:** `completionWord` at **reduced scale** — `.copyWith(fontSize: 22, color: amber.withValues(alpha: 0.85), letterSpacing: 1.5)`. Present, confirms *what* was solved, does **not** headline (that's the stars).
* **Kicker `ÇÖZÜLDÜ`:** `microLabel.copyWith(color: amber.withValues(alpha: 0.7), letterSpacing: 3)` — F03's exact kicker treatment, now paired with the smaller word.
* **Triptych figures:** `completionStat` (30 pt, w700, `paper`, tabular). The **OPTİMAL** figure may render 1–2 pt larger or the side figures 2 pt smaller, to weight the centre.
* **Triptych labels:** `microLabel`; the `OPTİMAL` label in `amber` @ 70 %.
* **`+N` gap connective:** `completionStat.copyWith(fontSize: 18, color: amber)` with a leading `+` — small, on the divider between SEN and OPTİMAL.
* **Retry text:** F03's 17 pt / w700 / `ink-amber` (unchanged). **Close:** `helper.copyWith(fontWeight: w600)` (F03's Close, unchanged).

---

## 6. Layout Structure

Portrait only. The panel, top → bottom:

```
        ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁         ← blurred board + amber winning row visible above
┌─────────────────────────────────────────────────┐
│━━━━━━━━━━━━━  amber spine (docked seam)  ━━━━━━━━│  3 pt, glows, fades at ends
│                                                 │  22 pt top pad
│                    H A R İ K A                   │  [Perfect only] struck plate, overlaps star tops
│              ★        ★        ☆                 │  STAR ROW (hero) — struck / struck / socket
│                     2 / 3                        │  tabular caption, muted
│                                                 │  20 pt
│                    ÇÖZÜLDÜ                       │  kicker, amber @70%
│                     T A B L A                    │  solved word, amber @85%, 22 pt (subordinate)
│                                                 │  22 pt
│   ┌───────────────────────────────────────────┐ │
│   │   9        +3      6            7  ▲       │ │  TRIPTYCH on a recessed track
│   │  SEN            OPTİMAL       EN İYİ       │ │  centre cell weighted; ▲ + underline = newBest
│   │                              ▔▔▔▔▔        │ │  [newBest] amber underline wipe
│   └───────────────────────────────────────────┘ │
│                                                 │  22 pt
│  ┌───────────────────────────────────────────┐  │
│  │                 YENİDEN                    │  │  RETRY — F03 amber pill, primary, ~full width
│  └───────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────┐  │  10 pt
│  │            SONRAKİ   ·   yakında           │  │  NEXT LEVEL — ghost pill, disabled, [PENDING—F05]
│  └───────────────────────────────────────────┘  │
│                    Kapat                        │  CLOSE — quiet muted text
└─────────────────────────────────────────────────┘  ← bottom safe-area inset (min 20 pt)
```

* **Spacing rhythm:** 4/8 pt (F03). Panel side padding **28 pt** (F03's `CompletionSheet`). Vertical beats: top pad 22 · stars→caption 10 · caption→kicker 20 · word→triptych 22 · triptych→Retry 22 · Retry→Next 10 · Next→Close 6 · Close→safe-area ≥ 20.
* **Star row:** 3 stars, box ~46 pt each, gap 18 pt → ~174 pt, centred. On a 360 pt screen (304 pt content) that leaves generous margin.
* **Triptych:** three cells on one recessed track. Centre (OPTİMAL) ~40 % width, sides ~30 %. The `+N` connective floats on the SEN↔OPTİMAL hairline divider, vertically centred on the figures. A 1 px `#FFFFFF` @ 6 % divider between each cell.
* **Shrink strategy (short devices):** the panel is scroll-free. If content exceeds ~66 % height: first the top pad and inter-beat gaps compress toward 12 pt; then the solved word may drop to 20 pt; the star row, the triptych figures, and the CTAs never shrink. If it still overflows (very small devices + the `newBest` ribbon), the panel height may grow to 70 % — never a scrollbar, never a clipped CTA.
* **Composition intent:** the stars own the optical centre of the upper panel; the triptych is a единый inset block; the CTAs are a clean stacked base. Three zones — **reveal / comparison / action** — that never blur together.
* **No extra chrome.** No close "X" in a corner (Close is the text button + system back), no drag handle unless FE wants the standard 4×36 pt grabber at the very top (optional; keep it `muted` @ 25 % and *below* the spine so it never competes).

### App Chrome & Navigation Rules

| State | System header | Custom top bar | Back affordance | Returns to | HW / gesture back |
| --- | --- | --- | --- | --- | --- |
| completion panel (all variants) | none | none | panel **Close** (quiet) + **Retry** (primary); back chevron **hidden** (F03 `won` rule) | Close → caller; Retry → in-place restart (`retryFromCompletion()`) | back = Close |
| Next Level (F04 scope) | none | none | inert | — | n/a (disabled) |

* Portrait-locked; rotation does nothing (inherited).
* No route added (`architecture.md §8`). The panel is an overlay on `/play`.
* **Forward note (non-binding):** when F05 enables Next Level, the primary/secondary weighting should be revisited *per outcome* (a `Perfect` result probably wants **Next Level** primary; a sub-optimal result keeps **Retry** primary). In F04 scope Next Level is disabled, so Retry is unambiguously primary now — as `architecture.md §7` locks it. Flagged in §14.

---

## 7. Component Decisions

### Star (the reveal unit) — 3×

* **Role:** the rating, and the emotional payoff.
* **Weight:** the heaviest thing on the panel — the hero.
* **Glyph:** a **drawn** faceted star (rounded points, a subtle inner facet line) — `CustomPainter` or a tuned `Path`. **Never `Icons.star` / `Icons.star_rounded`** — the default icon is the generic-results-card tell.
* **States:**
  * *socket (unearned)* — star-shaped recess, `plate` fill, inner top shadow, no glow. Sits below the panel plane. Reads as *an empty slot*, not a disabled control, not a broken tile.
  * *striking (reveal, ~140 ms)* — fills `amber → amber-lo`, rises to proud, one radial bloom (`#FFE9C2` @ ~14 %, blur 16, single pulse — **not** particles), scale 1.0 → 1.15 → 1.0.
  * *struck (at rest)* — raised, amber, inner top highlight, tight contact shadow, a faint steady outer glow. The faceted centre line catches the light.
  * *Perfect glow-pulse* — only when 3/3: after star 3, all three do **one** synchronised 1.0 → 1.06 → 1.0 + glow lift (~180 ms). The "lands last" beat.
* **Non-colour cue:** earned = **raised + filled + glowing**; unearned = **recessed socket**. Legible in greyscale and by silhouette depth alone. Backed by the `N / 3` caption and the Semantics label.
* **Why not generic:** three yellow `Icons.star` in a `Row` is the canonical AI results card. Struck-vs-socket depth ties the stars to F03's backlit-keycap / recessed-plate language and carries the accessibility cue structurally.

### Star count caption — `N / 3`

* **Role:** a blunt, glance-and-greyscale-safe readout of the rating.
* **Weight:** minor; `microLabel`, tabular, `muted`, directly under the star row.
* **Why:** it makes the count unambiguous the instant the reveal ends, helps colour-blind / low-vision players, and reads in a screenshot. Cheap, honest, on-brand (F03's tabular-figure discipline).

### Solved word + kicker

* **Role:** confirm *what* was solved.
* **Weight:** subordinate — a step below F03's sheet, where it was the 34 pt hero. Here: kicker `ÇÖZÜLDÜ` (`amber` @ 70 %, micro) + the word (`completionWord` at 22 pt, `amber` @ 85 %).
* **Why not generic:** it visually rhymes with F03's target rail and the winning row (amber glyph style) without competing with the stars. It is present for AC7, not headlined.

### Comparison triptych — SEN / OPTİMAL / EN İYİ

* **Role:** the replay hook. The gap to Perfect, made concrete.
* **Weight:** the second-loudest block — a single recessed inset track, three tabular figures.
* **Layout:** SEN (your moves this run) left · **OPTİMAL** centre, weighted (larger figure, `amber` @ 70 % label) · **EN İYİ** (personal best after this completion) right. A small amber **`+N`** on the SEN↔OPTİMAL divider = "N away from Perfect" (omit when `+0` — i.e. Perfect — and instead wash the track faint amber + show a small `=` where the `+N` was).
* **EN İYİ sub-states** (driven by `CompletionResult.bestOutcome`):
  * *firstClear* — figure + a small `İLK` micro-tag beneath + a gentle amber tick. Quietly positive; **not** the ribbon.
  * *newBest* — figure + a `▲` caret to its left + a `YENİ REKOR` ribbon above + an amber **underline that wipes in L→R** on reveal. The celebratory variant.
  * *matchedBest* — figure only, no tag; a faint hairline connector links SEN and EN İYİ (their numbers are equal). Distinct by the *absence* of celebration.
  * *noImprovement* — figure shows the **retained better** best; a faint `daha iyi` micro-tag; SEN shows the worse run; the `+N` still reflects *this run's* gap. No scolding copy, no red.
  * *bestIsPerfect* (orthogonal to the above) — a small `★` struck mark next to the EN İYİ figure (non-colour: a shape, plus the tag `HARİKA`).
* **Why not generic:** not a stacked "Your score / Best score" list. One inset triptych, centre-weighted on the *target*, with the gap spelled out — the motivational unit, not a scoreboard.

### Retry CTA (primary)

* **Role:** go again, same level, in place (`retryFromCompletion()`).
* **Weight:** dominant. F03's `_RetryCta` **unchanged** — filled `amber → amber-lo` pill, `ink-amber` w700 text, soft amber shadow, ~full width (or ≥ 64 %).
* **State:** pressed → scale 0.97. No confirm.
* **Why not generic:** it *is* F03's CTA — deliberate continuity, one dominant warm action.

### Next Level CTA (secondary, disabled — `[PENDING — F05]`)

* **Role:** a **real seam** F05 will wire (Journey advance + unlock). Shipped visible, honestly disabled.
* **Weight:** clearly below Retry — a **ghost pill**: no fill, 1 px `muted` @ 30 % stroke, `muted` @ 45 % label, a tiny lock or "·yakında" ("soon") suffix `muted` @ 45 %. **Not** a text link (it's a button that will light up), **not** equal weight to Retry.
* **State:** permanently inert in F04 — tap does nothing (no toast, no dialog — F03's "dead means dead" discipline). `Semantics(enabled: false, button: true, label: "Sonraki bölüm — yakında")`.
* **Why not generic:** a greyed full-weight second button reads as "broken"; a text link reads as "minor forever". The quiet ghost pill with a "soon" affordance reads as "coming" — which is true.
* **`[IMPL — Frontend]`** (`architecture.md §13`): if the debug entry can resolve a "next" smoke puzzle, Frontend *may* wire Next Level to open it (documented). Default: disabled.

### Close (tertiary)

* **Role:** leave to the caller.
* **Weight:** quietest — `muted` text button, panel base. F03's Close, unchanged. System / gesture back mirrors it.
* **Why kept:** with Next Level disabled, a `firstClear` player on the debug entry needs a non-Retry exit that isn't a system gesture.

---

## 8. State Design

| State | How it looks | How it differs from the resting panel | What it feels like |
| --- | --- | --- | --- |
| **reveal (transient, ≤ ~800 ms)** | Panel up; sockets → earned stars strike in sequence with one bloom each; `HARİKA` plate drops (Perfect only); triptych fades/rises in; `newBest` underline wipes | the only moving state; deterministic, finite | earned, paced, decisive — a moment, not a loop |
| **idle / at rest (`firstClear`)** | 1–3 struck stars + sockets for the rest; `N / 3`; word; triptych with `İLK` tag + gentle tick on EN İYİ | baseline | "logged — that's the bar now" |
| **`newBest`** | as idle + `▲` caret + `YENİ REKOR` ribbon + settled amber underline on EN İYİ | a celebratory mark on the best cell | "I beat it" — recognised, not shouted |
| **`matchedBest`** | as idle; SEN == EN İYİ; faint hairline connector; no ribbon | celebration deliberately withheld | "held my ground" |
| **`noImprovement`** | this-run stars; EN İYİ shows the retained *better* number + faint `daha iyi`; `+N` = this run's gap | best cell shows a number better than SEN | "still there to chase" — no sting |
| **`Perfect` (3/3)** | all three stars proud; `HARİKA` struck plate; triptych washed faint amber, `=` where `+N` would be; combines with `newBest`/`matchedBest`/`firstClear` markers on EN İYİ | every star raised — the only state where none is a socket | mastery — the top beat |
| **best-cell loading** | EN İYİ shows a 1-line shimmer placeholder; stars + SEN + OPTİMAL + Retry fully present | one cell pending (~1 frame in practice) | nothing stalls; the rating is already there |
| **error — best persist/read failed** | EN İYİ → `—` (em dash), no ribbon/tag; stars + SEN + OPTİMAL + Retry unaffected; `debugPrint('best_persist_failed …')` | one cell reads `—` | this run's stars are valid; the best just isn't available |
| **no-optimal fallback (defensive, dev-only)** | **No stars, no `N / 3`, no triptych.** Panel shows: kicker + word + a single `SEN 9` figure + a muted line "Puan yok" + Retry + Close | the reveal + comparison are simply *absent* | a deliberately reduced "just a completion" — not broken |
| **disabled — Next Level** | ghost pill, `muted` @ 45 % label, "·yakında", inert | visibly not-yet | "coming, not now" |
| **pressed — Retry / Next Level / Close** | scale 0.97 (Retry/Next), text dim (Close) | brief depress | tactile ack |
| **focused (assistive tech)** | 2 pt `amber` focus ring, 2 pt offset, on Retry → Next Level → Close (in that order); the star group is one focusable node | a crisp on-brand ring | reachable, ordered |
| **reduced motion** | end state only — stars struck, markers placed, underline settled; no stagger/bloom | the reveal is skipped | instant, still complete |

### Accessibility (mandatory — `architecture.md §7`)

* The **star group** is a single `Semantics` node with a label like `"3 / 3 yıldız — Harika"` / `"2 / 3 yıldız"` / (no-optimal) `"Puanlama yok"`. Individual stars are `excludeSemantics`.
* `HARİKA` / `YENİ REKOR` are **real text**, never colour-only — plus their non-colour shape cues (struck plate; `▲` caret + underline).
* The `N / 3` caption is live text, not an image.
* Triptych: each cell is `"$label: $value"` (`"Optimal: 6"`, `"En iyi: 7, yeni rekor"`).
* Retry / Next Level / Close are `Semantics(button: true)`; Next Level adds `enabled: false`.
* Contrast: `paper` on `#191A2B` and `amber` on `#191A2B` both clear AA at these sizes; `muted` is used only for ≥ micro-label weight text and non-essential tags.

---

## 9. Premium Differentiators (concrete)

1. **The seam docks as the panel spine** — F03's drawn L→R win-seam becomes the panel's top edge; win → panel is one connected gesture, not a screen change.
2. **The board stays in frame** — the blurred board + amber winning row remain visible above the panel, so "I built that / here's how good / go again" is one composition. The panel *is* the replay hook.
3. **Struck-vs-socket stars** — earned stars are raised, filled, and blooming; unearned stars are star-shaped *recesses* in the panel. The rating reads by depth and silhouette, in greyscale, before any label.
4. **Drawn faceted star glyph** — a struck-medal shape with an inner facet line, not `Icons.star`; tied to F03's backlit-keycap surface language.
5. **One restrained bloom per star** — a single radial pulse, no particles/confetti (honours F03's anti-pattern list); the reveal is paced, not explosive.
6. **The gap spelled out** — a small amber `+N` on the SEN↔OPTİMAL divider turns "how far from Perfect" into one glanceable number; on Perfect it flips to `=` and the track washes amber.
7. **Centre-weighted triptych on a recessed track** — OPTIMAL is the visual centre and target; the numbers are inset like F03's board plate, not a flat scoreboard list.
8. **`newBest` = caret + ribbon + an underline that wipes in** — three non-colour cues, an earned mark on one cell, not a full-panel colour flip.
9. **Four distinct EN İYİ sub-states** (`İLK` tag / celebratory ribbon / silent match / retained-better) — the same cell, unmistakably different, driven by one enum.
10. **Honestly-disabled Next Level** — a quiet ghost pill with a "·yakında" affordance, not a broken-looking greyed full button and not a throwaway text link.
11. **Reduced-motion path is the end state, not a degraded loop** — the panel is always complete and always settles (`pumpAndSettle`-safe).
12. **Zero new tokens** — F04 reuses F03's `PlayTheme` and `CompletionSheet` surface verbatim; parity is structural, not a re-implementation.

---

## 10. Anti-Patterns to Avoid (F04-specific)

* Three yellow `Icons.star` in a `Row` on a rounded card — the canonical AI results screen.
* A centred floating "achievement / trophy" card that hides the board (Direction B — breaks F03 parity, tips gamey).
* Confetti / particle burst / screen-shake on the reveal (F03 forbids it; F11 owns any celebration polish later).
* A full-panel colour flash for `newBest` / `Perfect` instead of a targeted mark.
* Next Level as an equal-weight second button (reads as broken) **or** as a tiny text link (reads as permanently minor).
* Red / "you did worse" scolding on `noImprovement`.
* A "you earned N stars!" dialog or a tap-to-continue gate before the panel.
* The solved word rendered as large as F03's sheet — it must step down; the stars are the hero now.
* An infinite shimmer / pulsing star / looping glow — the reveal must be bounded and deterministic (`architecture.md §7`).
* A scrollable panel or a clipped CTA on short devices — grow the panel height, never scroll.
* `Icons.star` outline for the unearned slot — it must be a *recessed socket*, structurally different, not just a thinner icon.
* Dropping the `N / 3` caption or the Semantics label "because the stars are obvious" — they carry the non-visual and greyscale reading.
* Reusing F03's `danger` colour anywhere (no error icon lives on this panel).

---

## 11. Frontend Handoff

### Must not be broken (contract-level UI decisions)

* **The star rating is the hero and an earned, bounded, deterministic reveal** — struck stars in sequence (≤ ~800 ms total, `architecture.md §7`), one restrained bloom each, "Perfect" / all-3 lands last. **No infinite animation.** `pumpAndSettle` must resolve.
* **Struck vs socket** — earned = raised + amber-filled + glowing; unearned = a **recessed star-shaped socket**. This is the mandatory non-colour cue; do not reduce it to filled-vs-outline colour.
* **The star glyph is drawn**, not `Icons.star*`.
* **The `N / 3` caption and the star-group `Semantics` label are both required** (greyscale + screen-reader reading of the count).
* **`HARİKA` and `YENİ REKOR` are text + a non-colour shape cue** (struck plate; `▲` caret + underline). Never colour-only.
* **The board stays visible above the panel** — keep F03's `won` treatment (12 % dim + 1.5 px blur + amber winning row + seam) running behind the 40 % scrim. Do not blank or fully blur it.
* **Panel surface = F03's `CompletionSheet` decoration verbatim** (`#191A2B`, top radius 28, `#14FFFFFF` top border, `#000 @50%` y-8 blur 32 shadow) over F03's 40 % scrim. The docked amber **spine** (3 pt, end-faded, soft glow) is required.
* **Six variants, each visually distinct**, all driven by `CompletionResult` (`firstClear` / `newBest` / `matchedBest` / `noImprovement` / `Perfect` / no-optimal). The no-optimal fallback renders **without** stars / caption / triptych — a reduced panel, not a broken one.
* **Triptych: SEN / OPTİMAL / EN İYİ**, centre-weighted on OPTİMAL, on a recessed inset track, with the amber `+N` gap connective (`=` + amber wash on Perfect).
* **CTA hierarchy: Retry primary (F03's amber pill, functional now — `retryFromCompletion()`); Next Level secondary and disabled** with a quiet `[PENDING — F05]` "·yakında" affordance — **not** equal-weight, **not** a text link. Keep the quiet **Close** text button + `_popToCaller` fallback. Back chevron stays hidden in `won`.
* **Stars never wait on persistence** — compute from `engine.moveCount` + `optimalMoves`, show immediately. Only the **EN İYİ** cell may show a brief shimmer, degrading to `—` on write/read failure (`architecture.md §6`) — the panel still shows this run's stars.
* **Reduced motion** (`MediaQuery.disableAnimations`) → render the reveal's **end state** directly.
* **Portrait-locked; no confirm dialogs; no route added; no toasts** (a disabled tap does nothing).

### Flexible (FE may tune within these bounds)

* Reveal beat timings — recommended: panel rise ~260 ms, per-star strike ~140 ms, stagger ~140 ms, Perfect plate ~180 ms, newBest underline ~200 ms — as long as the **total ≤ ~800 ms** and it's deterministic. Suggested token names if promoted to `PlayTheme`: `revealStarStagger`, `revealStarStrike`, `revealMarkerDrop`.
* Exact star size (44–52 pt) and gap (16–20 pt); bloom opacity (±4 %) and blur (±4 px).
* Panel height (56–66 %, up to 70 % only to avoid a scroll on small devices + `newBest`).
* Triptych cell proportions (centre 38–42 %); whether the centre figure is +1–2 pt or the sides −2 pt; the exact recess fill (derive `#12131F` or reuse `plate`).
* Whether to promote F03's inline `CompletionSheet` surface constants to shared `PlayTheme` tokens (`sheetSurface` / `sheetScrim` / `sheetHighlight`) so F04's panel and F03's (now-removed) sheet share one source — a clean small refactor, encouraged.
* `[IMPL — Frontend]` `architecture.md §13`: `PlayStrings` extension vs a new `RatingStrings`; whether the debug entry's Next Level opens the next smoke puzzle or stays disabled (default: disabled).
* Optional 4×36 pt drag grabber at the very top (`muted` @ 25 %, below the spine).
* Exact TR copy — placeholders here (`HARİKA` / `YENİ REKOR` / `OPTİMAL` / `EN İYİ` / `SEN` / `İLK` / `daha iyi` / `SONRAKİ` / `yakında`) go to PO / localization on the same track as F03's microcopy.

### Do not cheapen

* Don't swap the struck/socket stars for filled/outline `Icons.star`.
* Don't drop the bloom to nothing, or inflate it to particles.
* Don't headline the solved word (it steps down from F03).
* Don't turn `newBest` into a full-panel colour wash.
* Don't render Next Level as a full-weight greyed button or a bare text link.
* Don't hide the board behind the panel.
* Don't let the panel scroll or clip a CTA — grow it.
* Don't skip the `N / 3` caption or the Semantics label.
* Don't add an error icon / `danger` colour to this panel.

---

## 12. Self-Review Against Rubric

| Criterion | Score | Rationale |
| --- | --- | --- |
| Visual Hierarchy | 10 | One hero (the struck-star reveal), the triptych a clear second (the replay hook, centre-weighted on OPTIMAL), CTAs a clean stacked base, the solved word deliberately subordinate. First-3-seconds order is designed: stars → OPTIMAL → Retry. |
| Layout & Composition | 9 | Three non-blurring zones (reveal / comparison / action), F03's 28 pt padding, a defined no-scroll shrink strategy. −1: the `newBest` ribbon + a very small device is the one tight case (mitigated by the panel-grows rule). |
| Surface & Depth | 10 | F03's raised panel verbatim, a recessed triptych track echoing the board plate, struck stars raised *above* the plane and sockets cut *below* it, the docked glowing spine. Three real tiers; nothing flat. |
| Typography | 9 | Reuses F03's roles (tabular figures, tracked micro-labels, the amber glyph word) with a clear step-down for the solved word and struck-caps markers. −1: no new type expression — correct restraint for parity, but not a fresh system. |
| CTA Quality | 9 | F03's dominant amber Retry, unchanged; Next Level an honestly-disabled ghost pill (not broken-looking, not a throwaway link); Close deliberately quiet. −1: Retry-as-primary-on-a-Perfect is a known compromise until F05 (flagged §14). |
| State Design | 10 | reveal / firstClear / newBest / matchedBest / noImprovement / Perfect / best-loading / best-error / no-optimal / disabled / pressed / focused / reduced-motion — all specified, each with a distinct *felt* treatment and a non-colour cue. |
| Product Feel | 10 | The seam-docks-as-spine continuity + the board staying in frame make this read as one premium win moment, tied to F03's identity — an App-Store-featured puzzle-game reward, not a results card. |
| Modernity | 9 | 2026 dark, layered, restrained deterministic motion, structural accessibility. −1: a 3-star rating is an established idiom — differentiation rides on the struck/socket execution. |
| Non-Generic Originality | 9 | Struck-vs-socket stars, the docked seam spine, the gap-spelled-out triptych, four distinct EN İYİ sub-states — distinctive. −1: the underlying "stars + stats + retry" structure is inherently familiar; originality is in treatment. |
| Implementability | 9 | Concrete tokens (all reused), sizes, beat timings, z-order, shrink rules, variant logic mapped 1:1 to `CompletionResult`. −1: the drawn star glyph + the struck/socket depth needs care to not read as a broken tile. |

**Total: 94 / 100** — within the target band (93–96). No fail conditions present (clear hero, dominant CTA, strong state design, layered surfaces, strong hierarchy, non-generic identity, "top mobile game" register). Finalized.

---

## 13. Assumptions

* **F03's `won` treatment is left rendering behind the panel** (12 % dim + 1.5 px blur + amber winning row + seam bar). The panel adds F03's 40 % scrim over that. If F03's implementation currently tears the board down before the sheet, FE keeps it up for F04.
* **The personal-best read-back is effectively instant** (local Drift DB, `architecture.md §6/§9`). The shimmer state is a safety net, expected to be < 1 frame in practice.
* **No brand palette** → F03's `PlayTheme` tokens hold; if LOOPLET later gets an official palette, `amber` / surface rebind and this structure/hierarchy survives.
* **Turkish primary** → copy shown (`HARİKA` / `YENİ REKOR` / `OPTİMAL` / `EN İYİ` / `SEN` / `İLK` / `daha iyi` / `SONRAKİ` / `yakında` / reuse `ÇÖZÜLDÜ` + `Yeniden` + `Kapat`) is illustrative; PO / localization owns final strings (same track as F03's microcopy follow-on, `f03 ui-design.md §14`).
* **The star glyph is bespoke** — FE draws it (`CustomPainter` / `Path`). No asset pipeline exists yet; a vector path is the expectation, not an SVG/image asset.
* **SFX / haptics on the reveal are out of scope** (F11). The choreography here is visual-only; F11 can layer audio/haptic onto the same beats later.
* **`Semantics` grid navigation** stays as F03 set it (summary label on the board); F04 adds the star-group node + the CTA/triptych labels, no full assistive-tree redesign.
* **Motion values** respect the product's "animation must not distract / < 50 ms input latency / smooth on mid-tier" constraints; FE + QA validate the reveal on the device matrix (folds into F03's already-accepted first-app-distribution device smoke, `architecture.md §11`).

---

## 14. Needs Tech Lead Clarification

1. **Retry-primary on a `Perfect` result** — `architecture.md §7` locks Retry as the primary CTA and Next Level as disabled in F04 scope, so this is settled *for F04*. Non-blocking forward note: when **F05** enables Next Level, the primary/secondary weighting should be revisited per outcome (`Perfect` → Next Level primary; sub-optimal → Retry primary). Recording it here so it isn't lost; no F04 action.
2. **F03 board persistence behind the panel** — this handoff assumes F03's `won` board treatment (dim + blur + winning row + seam) stays rendered under the F04 panel. If F03's current implementation disposes the board before showing the sheet, confirm FE should keep it mounted for F04's parity.
3. **Promoting `CompletionSheet`'s inline surface constants to `PlayTheme`** (`sheetSurface` / `sheetScrim` / `sheetHighlight`) — encouraged as a small refactor so F04's panel and F03's surface share one source. Confirm this is in F04-FE4's remit (it touches F03 files) or should be a separate follow-on.
4. **Microcopy** — the TR strings above are placeholders; PO / localization owns final wording (same track as F03).

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** F04-UI — `ui-design.md` delivered. Resolves `architecture.md §13 [PENDING — UI]`: the panel's visual hierarchy (star reveal hero → centre-weighted OPTIMAL triptych → Retry primary → subordinate word); the bounded ≤ ~800 ms deterministic star-reveal choreography; the six outcome variants each visually distinct with non-colour cues; the `HARİKA` / `YENİ REKOR` markers (text + shape); CTA hierarchy (Retry primary functional, Next Level disabled ghost-pill seam); chrome / atmosphere parity with F03 Direction A (F03's `CompletionSheet` surface verbatim, 40 % scrim, docked amber seam spine, board stays in frame); accessibility (star-group `Semantics` + `N / 3` caption). Reuses F03's `PlayTheme` — no new tokens. Self-review 94/100.
* **Remaining Tasks:** F04-FE1…FE5 (Frontend/Mobile Developer) — the pure `starsForResult` / `isPerfectResult`, `CompletionResult` + `BestOutcome`, additive win-path wiring in `PlaySessionController`, the real `completion_panel.dart` replacing `completion_sheet.dart`, and tests — against `architecture.md` + this handoff. Then QA → Tech Lead (F04 close).
* **Blockers:** none. The four `Needs Tech Lead Clarification` items are non-blocking (sensible defaults chosen; #1 is a forward note for F05, #2–#3 confirmable in review or F04 close-out, #4 is the standard microcopy track).
* **Status Suggestion:** Ready for Frontend.

---

## 15. Sonraki Komut

```
Run Frontend/Mobile Developer
```
