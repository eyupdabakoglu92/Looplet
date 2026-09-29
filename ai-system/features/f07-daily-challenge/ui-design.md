# F07 — daily-challenge: UI Design Handoff (the Daily surfaces)

> **Task:** F07-UI (UI Designer, 2026-09-29). **Contract:** `architecture.md` D3 (states), D4 (dates), D6 (the displayed streak), D7 (the kill-switch effect), D8 (surfaces, routes, copy, text scale).
>
> **Authority chain:** design-foundation §17 / §18 (Direction C "Loop Glass", Selected) → F00 `ui-design.md` (components, states, accessibility) → the shipped siblings F05 `ui-design.md` (D3 Home) and F03 `ui-design.md` §16 (D2 result), F03 `architecture.md` §19 / §20 → this handoff → Frontend/Mobile Developer.
>
> **Status: Pending Selection.** Two directions are rendered on identical content (§2). The UI Designer recommends **A "Hafta döngüsü"**; the user selects at F07.DIRECTION-SELECT (opened by the Tech Lead at the visual-gate checkpoint). Everything from §3 on is written for A; if B is selected, §3–§12b are re-issued for B before implementation.
>
> **Unchanged:** F08's schema and client API, F03's play session and win timeline (§20.3), F04's star rule, F05's Home composition above the new entry, the Foundation tokens (no new token).

---

## 1. Feature Summary

* **What F07 adds to the screen:**
  * a **secondary Daily entry on Home**, under the Journey caption;
  * the **Daily screen** (`/daily`) with the five D3 states;
  * a **daily label in the Play header** (`GÜNLÜK · #N` + the date);
  * the **daily variant of the full-screen result**: official vs replay, this run's moves / time / stars, current + best streak.
* **Primary user intent:** "Is today's puzzle waiting, and is my streak safe?" — answered at a glance on Home, one tap from play.
* **Secondary intent:** after a run, know that the official result is recorded (or, on a replay, that it did not change) and see the streak move.

## 2. Design Direction

Both directions sit on the Selected Foundation (the navy ground, glass, lime = resolution / primary, periwinkle = where you are, Space Grotesk + Manrope, the drawn icon set). They differ in **what carries the Daily's identity** and therefore in composition, the Home entry form, the Daily screen hero and the streak object. Identical content in both: today = 2026-11-03 (Salı), `#34`, streak 4 → 5, best 12, one missed day (29 Ekim), official 5 moves / 1:42 / 2★, replay 4 moves / 1:18 / 3★.

### Direction A — "Hafta döngüsü" (the week loop) — recommended

* **Character:** the streak is drawn, not written. The last seven days ride a short rising line in the **loop-track language of Home**: done days are lime nodes, a missed day is a dashed hollow node that breaks the line, and today sits at the rising end — periwinkle with its halo while it waits, lime with a check once done. The same object appears three times at three sizes: in the Home entry (mini), on the Daily screen (with dates and weekdays), and in the result's streak card, where today's node fills lime as the reward.
* **Why strong:**
  * it extends the Foundation's signature motif (design-foundation §17.2 "the loop track") to a new surface, strengthening Originality, the Foundation's weakest dimension (§17.1 risks);
  * the streak becomes a *shape you protect* — a gap in the chain is visible without reading a number;
  * the Home entry is recognisably a sibling of the Journey card, so Home stays one family;
  * every state is carried by node shape + text, never colour alone.
* **Risks:**
  * the Home entry is ~118 pt tall at 1.0× (three rows); it pushes Home into a scroll at AX5 (the Journey card, CTA and caption stay fully visible at offset 0 — §6, NTLC-4);
  * the mini chains (17–27 pt nodes) are decorative-scale; their meaning is always repeated in text (`4 SERİ`, the state line).
* **Artefacts (exploration set):** `design/F07-A-01-home-daily-available.png`, `F07-A-02-home-daily-done.png`, `F07-A-03-daily-ready.png`, `F07-A-04-daily-needs-connection.png`, `F07-A-05-result-first-run.png`, `F07-A-06-result-replay.png`.

### Direction B — "Günün bileti" (the daily ticket)

* **Character:** typographic. The Daily screen is a **ticket**: a glass card with a 104·s `#34` (lime `#`), "Salı · herkes aynı bulmacayı çözer", a perforated tear line with two punched notches, and a stub holding the numbers (`4 SERİ` | `12 EN İYİ`). Done today stamps the ticket with a rotated lime `BUGÜN TAMAM` mark. The Home entry is a **one-line capsule** (the reference's chip language): flame + `4 SERİ` | dashed perforation | `Günlük #34` … `Oyna →`. The result's streak card is a ticket stub (`GÜNLÜK SERİ` / `EN İYİ SERİ`, notched edges).
* **Why strong:** the shared-puzzle idea ("everyone solves #34 today") is loud and simple; the Home entry is the lightest possible (58·s, one line); the ticket/stamp gives the Daily a collectible feel that F13's share card could inherit.
* **Risks:**
  * the streak is only numerals — a missed day is invisible until the number drops;
  * the big-number hero is a common pattern (less Looplet-specific than the loop track);
  * the capsule edge `rgba(255,255,255,.18)` (the shipped `OutlinePill` edge) is 1.66 : 1 on the ground — the label identifies the control, but the boundary itself is weak;
  * the stamp rotated over the numeral needs care at 1.3× (it overlaps more).
* **Artefacts:** `design/F07-B-01-home-daily-available.png`, `F07-B-02-home-daily-done.png`, `F07-B-03-daily-ready.png`, `F07-B-04-daily-needs-connection.png`, `F07-B-05-result-first-run.png`, `F07-B-06-result-replay.png`.

Side by side: `design/F07-sheet-1-directions-A-vs-B.png` (top row A, bottom row B, same states).

**Material difference (not a colour variant):** A = graphic chain of days, three-row glass entry, card + separate stat card on `/daily`, streak shown as a week; B = typographic ticket with perforation and stamp, one-line capsule entry, numbers-only streak stub. Shared by necessity: the Home above the entry, the Play header, the result's answer row and stats (F03 D2 siblings).

### Recommendation and Selection Record

* **UI Designer recommendation:** **A "Hafta döngüsü"** — it carries the product's own signature into the habit loop, makes the streak legible as a shape, and keeps Home one visual family. B is a strong alternative if the user prefers a lighter Home entry.
* **Selected direction:** **Pending Selection** (F07.DIRECTION-SELECT).
* **Selection authority / reference:** the user, through the Tech Lead's decision gate. This handoff does not self-select.

---

## 3. Screen Goals

| Screen | Goal | First 3 seconds |
| --- | --- | --- |
| Home (with the Daily entry) | Journey stays the hero; the Daily is noticed, not competing | "Devam et" is the only lime action; below it, today's Daily and my streak |
| `/daily` | Start today's puzzle, or see today's result | today's state in the headline (`hazır` / `tamam` / `henüz gelmedi`), the week, the streak, one action |
| Play (daily) | Play; know it is the Daily | `GÜNLÜK · #34` + the date where the level label usually is |
| Result (daily) | Know the official result is recorded (or unchanged); see the streak | chip `RESMÎ SONUÇ` / `HARİKA` / `TEKRAR` → headline → the answer row → numbers → streak |

## 4. UX Flow Direction

1. **Home → `/daily`:** tap the Daily entry (the whole card is one target). The Journey CTA is untouched.
2. **`/daily` (ready) → Play:** "Bugünü oyna" → `/play` with `PuzzleSource.daily` (D8).
3. **Play → result:** the F03 §20 win sequence, unchanged; the result is the daily variant (§8).
4. **Result exits:**
   * "Tamam" (primary) → back to `/daily`, which now shows `doneToday` (D8 "back to `/daily`");
   * "Tekrar oyna" (link) → replay in place (the D2 retry flight, unchanged);
   * the back button and system back → `/daily`.
5. **`/daily` (doneToday):** the official result, the streak, "Tekrar oyna" (outline, secondary) → a replay run. "Yeni döngü gece yarısı." explains when the next one comes.
6. **`/daily` (needsConnection):** "Tekrar dene" (lime) re-triggers the fetch (D3 trigger); "Yolculuğa dön" (link) → Home. Connectivity regain re-fetches silently (D3); on success the screen becomes `ready` in place.
7. **`/daily` (unavailable):** one calm line + "Yolculuğa dön". Not an error.
8. **Rollover (D4):** `/daily` not mid-run and showing yesterday → switches to today's state in place on resume (no animation beyond the content swap). A run in progress keeps its start date; its header keeps `#N` and the date of the start.
9. **Friction removed:** no confirmation dialogs; Retry never shows a spinner longer than the fetch (10 s timeout, D3); `loading` shows the local streak immediately (it needs no network).

### App Chrome & Navigation Rules

| Screen | System header | Custom top bar | Back affordance | Target | Hardware / gesture back |
| --- | --- | --- | --- | --- | --- |
| Home | none | wordmark only (F05) | none | — | OS default (leaves the app) |
| `/daily` | none | none | `GlassIconButton(LoopIcon.back)` at (24, 54)·s, 44 pt, `Semantics` "Ana ekrana dön" — the D2 result's back button (sibling parity) | Home (`/`) | same, safe at any state |
| Play (daily) | none | the D1 header: bare chevron + `GÜNLÜK · #34` / date, `HAMLE` card | the D1 chevron | `/daily` | same (the F03 exit rules) |
| Result (daily) | none | none | the D2 back button, `Semantics` "Günlük ekrana dön" | `/daily` | same, honoured at any time in `won` (§20.3 (2)) |

* **Sibling parity:** `/daily` has no wordmark (it is not a root); its back button, card, stat card and pills are the D2 / D3 components. **Deliberate chrome deviation:** the Play header's label block is two lines (label + date) instead of D1's one; it stays left of the `HAMLE` card and inside the D1 header band (§6).

## 5. Visual System

### Background Direction

* The shipped `LoopBackdrop` on every Daily surface (navy ground, top-right light, teal spill). No new gradient. The result keeps D2's single lime radial behind the answer row (the one glow).

### Surface Direction

* **Primary surface:** the glass card (`GlassCard`, radius 30·s, the two swirl arcs clipped inside) — the Daily card on `/daily` is the Journey card's sibling.
* **Secondary surfaces:** the slate `StatCard` (radius 24–26·s) for numbers and the streak; the Home entry is slate too (so it reads *below* the glass Journey card in depth).
* **Depth:** shadows for hierarchy only (card 24 / 60, today node 10 / 26, done nodes 6 / 16). No blur.

### Color Direction

| Role | Value (tokens.dart) | Daily use |
| --- | --- | --- |
| Lime — resolution / primary | `lime`, node `limeTileTop → limeTileBottom`, CTA `ctaTop → ctaBottom` | done days, **today done** (+ check), the lit flame (streak kept today), the primary pill, the answer row, earned stars |
| Periwinkle — where you are | `nodeCurrentTop → periwinkleLow`, halo `rgba(168,180,249,.16)` | **today, waiting**; the `RESMÎ SONUÇ` chip edge; the offline today outline; focus rings |
| Text / muted | `text` / `muted` | numerals, headlines / labels, weekdays, state lines when not actionable |
| Danger | none | needsConnection and unavailable are calm (no red, no error glyph); nothing is the player's fault |
| Success | lime | today done, the streak step |

* **Flame:** muted (`#AEB4CA`) while today is still open, lime once today is done — the flame is "kept", not a warning. A streak of 0 keeps the muted flame and the numeral `0`.
* Contrast (computed, `design/src/contrast-f07.txt`): entry label 6.96 : 1 on slate; entry state line 13.32; missed outline 3.62 (non-text); missed numeral 6.28; done numeral 14.05; today numeral 6.67; offline outline 4.43 (non-text); weekday label 6.37 on glass; `RESMÎ SONUÇ` 13.61; `TEKRAR` 8.55; stat label 6.96. (B only: the capsule edge 1.66 — see §2 risks.)

### Typography Direction

* **Caps labels** (`GÜNLÜK · #34`, `3 KASIM`, `SERİ`, `EN İYİ`, weekdays, chips): Manrope 600, +0.2 em (chips/stat labels +0.14 em, weekdays +0.12 em), authored in Turkish capitals — never `toUpperCase` (`turkish_case.dart`). Capped at 1.3×.
* **Headlines:** Space Grotesk 500, 28·s / 1.16 on `/daily` (two authored lines, one lime word when the state is positive); 31·s / 1.13 on the result (**one line**: "Günlük tamam." / "Tekrar tamam." — shorter than D2's two lines to make room for the streak card, §6). Capped at 1.3×.
* **Numerals:** Space Grotesk 500, tabular (`tnum`): stats 24·s, streak in the entry 17·s, today numeral 15·s, day numerals 12·s. Durations `m:ss` ("1:42"); `Semantics` "1 dakika 42 saniye".
* **Free text** (state line, body, subtitle, pill labels, caption, link): Manrope 500–600, 14–16·s, follows the OS scale up to AX5 (C-9).

### Motion / Sensory Direction

* **Home entrance (F05 D3, extended):** card 0–240, CTA 60–300, caption 120–340, **Daily entry 180–420 ms** — opacity 0 → 1 with a 10·s rise, `cubic-bezier(.22,.61,.36,1)`. Stills `F07-A-M-home-entrance-t0000 / t0120 / t0240 / t0420`. Reduced motion: all at once (F05 rule). If the Daily state arrives after the entrance (a slow cache read), the entry fades in alone (160 ms, same curve); no layout jump above it.
* **`/daily` entrance:** none beyond the route transition (the platform push). A state change in place (loading → ready, needsConnection → ready) cross-fades the card content 160 ms; reduced motion: instant.
* **Result:** the F03 §20.3 win sequence and the retry flight are **unchanged** (timings, input lock, reduced path). Daily differences:
  * the stars pop inside the stats card's `YILDIZ` cell at the D2 times (940 / 1050 / 1160, 140 ms each);
  * **streak reveal (A):** 1300–1440 ms — today's node in the streak card goes from the pre-run look to lime with a check (scale .9 → 1.08 → 1, 140 ms ease-out); the `SERİ` numeral steps from the previous value (4 fades up and out 1300–1370) to the new one (5 rises in 1370–1440). Only on a **first run whose streak changed**; a replay shows the final state at rest. Stills: `F07-A-M-streak-reveal-t0940 / t1300 / t1370 / t1440`; reduced motion: `F07-A-M-streak-reveal-reduced` (final values at rest, no step). Input is already live from 940 (a rest-state reveal, like D2's stars).
  * Interruption: backgrounding resolves to rest (the §20.3 (2) rule covers the reveal too).
* **Audio / haptics:** N/A — F11 (the Foundation's intent: a success haptic on resolution, not added here).

## 6. Layout Structure

All values are pt at the 358 reference, × `s = W / 358`; `e = H − 717·s` (F05 / F03 convention).

* **Home with the entry:** the F05 D3 flow column unchanged (card, CTA, caption); the **Daily entry follows the caption**:
  * margin-top 24·s; width 309·s; slate; radius 24·s; padding 13·s / 16·s / 12·s;
  * row 1: `GÜNLÜK · #34` (11·s caps) left; flame 16·s + numeral 17·s + `SERİ` (10·s caps) right;
  * row 2: the mini week track, 42·s tall, full entry width (node scale 0.62: day nodes 17.4·s, today 27.3·s, halo 36·s; nodes carry no numerals at this size);
  * row 3: the state line (Manrope 600 14.5·s, free text) left, `LoopIcon.arrowRight` 18·s right.
  * **Measured** (`design/src/fit-f07.txt`, column bottom vs `H − 34`): 1.0× — 16: 743.4 (74.6 spare), 16e 72.4, Pro Max 90; **1.3× — 16: 30.9 spare, 16e 29, Pro Max 41 → no scroll**; AX5 — the column is 257 pt taller than the screen → **Home scrolls** (below).
  * **AX5:** Home becomes a clamped scroll view (the D2 `ScrollBand` appears only once scrolled). At offset 0 the wordmark, Journey card, CTA and caption are fully visible (`F07-A-51-home-ax5-top`); the entry is reached by scrolling (`F07-A-52-home-ax5-scrolled-end`). **This amends F05's "no scroll at AX5" outcome — NTLC-4.**
  * **Hidden** (`daily_enabled == false`): the entry is absent and Home is exactly F05 D3 (`F07-A-11-home-daily-hidden`).
* **`/daily`:** back button fixed at (24, 54)·s. Content column left 24·s, width 309·s, top `115·s + 0.1·e` (the Home card's top — the two screens align on push):
  1. **Daily card** (glass, radius 30·s, padding 29·s / 24.5·s / 10·s): row `GÜNLÜK · #34` | `3 KASIM` (11·s caps); headline (margin 15·s); body when the state has one (margin 12·s, 14.5·s / 1.4, muted); the **week track** block (margin 16·s, full card width, 86·s tall):
     * day nodes 28·s (r 34 %), numerals = day of month 12·s; today 44·s + halo 58·s (r 20·s), numeral 15·s or a glyph;
     * centre spacing 35·s between days, 47·s into today; the chain is centred on the card; `y = 40 − 12·(i/6)^1.4` (a gentle rise to today);
     * weekday labels 9.5·s caps under each node (`ÇAR … PZT`, today `BUGÜN` in text colour);
     * segments edge-to-edge (never through a node): into a done day solid lime 3·s; into or out of a missed day dashed muted 2·s (2 / 5); into today-waiting a lime → periwinkle gradient; into today-offline dashed periwinkle.
  2. **Stat card(s)** (margin 16·s; 10·s between two): `SERİ` (flame) | `EN İYİ`; in `doneToday` first the official result `HAMLE` | `SÜRE` | `YILDIZ`.
  3. **Action:** `LimePill` (margin 22·s) — "Bugünü oyna" (ready), "Tekrar dene" (needsConnection), "Yolculuğa dön" (unavailable), disabled "Hazırlanıyor" (loading); in `doneToday` an `OutlinePill` "Tekrar oyna" instead (no lime on a finished day).
  4. **Caption / link** (margin 17·s): "Sınırsız hamle · 3 geri alma" (ready) — AC3 said once, quietly; "Yeni döngü gece yarısı." (doneToday); `TextLink` "Yolculuğa dön" (needsConnection).
  * Measured: 1.0× bottoms 608.6 (loading) – 726.2 (doneToday) on the 16; 1.3× ready 129.8 spare; AX5 scrolls (`F07-A-54` top, `F07-A-55` end; needsConnection `F07-A-56`).
* **Play header (daily):** the D1 header with a two-line label block: the bare chevron 20·s, then `GÜNLÜK · #34` (11.5·s caps) over the date "3 Kasım Salı" (Manrope 500 12.5·s, muted, margin 5·s); the block's top at 87·s (D1's single label sits at 96·s — the pair is centred on the same line); `HAMLE` card, target rail, board and HUD unchanged (D1 geometry). Both lines are capped at 1.3× (container text in the header band; `F07-A-31-play-daily-header-text-cap-1_3`).
* **Result (daily):** the D2 column (x 24·s, width 309·s, top `54·s + 0.16·e`) with the daily order:
  1. chip row 42·s (§7);
  2. headline, **one line** (margin `14·s + 0.06·e`);
  3. subtitle (margin 12·s): "Optimal 4 hamle. Resmî sonucun kaydedildi." / "… değişmedi.";
  4. the answer row (margin `24·s + 0.1·e`), D2 tiles 52.5 × 59·s;
  5. stats card (margin 22·s): `HAMLE` | `SÜRE` | `YILDIZ` (stars in the cell — replaces D2's separate star row);
  6. replay only: the **official row** (margin 10·s, min 46·s, slate, radius 20·s): `RESMÎ` left; `5 HAMLE`, `1:42`, three 12·s stars right;
  7. the **streak card** (margin 10·s, min 62·s): the week track at scale 0.66 (190·s wide) left; flame + numeral 24·s + `SERİ`, then `EN İYİ 12` (10·s caps) right;
  8. the primary row (margin 18·s): `LimePill` "Tamam" + `LoopIcon.check` 20·s — **and the F13 Share place** (below);
  9. `TextLink` "Tekrar oyna" (margin 6·s).
  * **Measured:** 1.0× first run bottom 641.7 (176 spare); **1.3× replay (the tallest variant) 758.5 → 59.5 spare on the 16, 57.4 on the 16e** — no scroll at the cap (§20.3 (9) holds); AX5 scrolls under the fixed back button (`F07-A-58` top, `F07-A-59` end), landing at offset 0.
  * **The F13 Share place:** a 63·s round slot at the **right end of the primary row** (gap 10·s); when F13 adds its control, "Tamam" shrinks by 73·s. It costs no height, so the 1.3× fit above already includes Share (`F07-A-41`, `F07-A-42`, `F07-A-v-16e-result-share-slot-budget-cap-1_3` show the budget as a dashed annotation — **F07 draws nothing there**). A stacked Share pill under "Tamam" was measured and rejected: it overflowed by 28–30 pt at 1.3×.
* **Rhythm:** Home keeps its two groups (Journey, then "Bugün"); the 24·s gap plus the entry's darker slate separates them. `/daily` mirrors Home's card → numbers → one action. The result has three bands (verdict; the object; numbers and choice) as in D2.

## 7. Component Decisions

| Component | Code (`app/lib/design`) | Role / weight | States | Why not generic |
| --- | --- | --- | --- | --- |
| **`WeekTrack`** *(new)* | new painter + node layout, sibling of `LoopTrack`; three scales (entry 0.62, result 0.66, `/daily` 1.0) | the streak as a shape | per day: done, missed; today: waiting, done, offline; skeleton (loading); weekday labels on/off; numerals on/off | the Home loop track applied to days — a chain you can break, not a progress bar |
| `LoopNode` *(extended)* | existing | one day | adds **`missed`** (= the F05 `locked` look: fill `.035`, 1.5·s dashed outline `.62`, muted numeral), **`todayDone`** (lime + lime halo + `check`), **`todayOffline`** (dashed periwinkle outline `.75`, fill `.06`, `offline` glyph) and a size parameter | each state differs in fill *and* edge *and* size or glyph — readable in greyscale |
| **`DailyEntryCard`** *(new)* | slate surface, `_Pressable` (press .98), one `Semantics` button | the secondary Home entry | available, done, needsConnection, loading, hidden; pressed; focused (2·s periwinkle ring) | a small sibling of the Journey card, not a second lime CTA or a banner |
| `GlassCard` | existing | the Daily card | grows with capped headline / free body | holds the week the way the Journey card holds the track |
| `StatCard` / `StatCell` *(extended)* | existing | numbers | adds an **icon** slot (flame, 19·s) and a **stars** cell (`YILDIZ`, three 15·s stars, D2 star pop inside the cell) | the D2 stats language, no new card type |
| **Official row** *(new, small)* | slate row | replay comparison | replay only | the official numbers stay in view without a second full card |
| **Result chip** | `LoopBadge` (HARİKA, existing) + two variants: **`RESMÎ SONUÇ`** (periwinkle edge `.45`, fill `.10`, `check` 16·s) and **`TEKRAR`** (outline edge `.18`, `restart` 16·s, muted) | the verdict tag | one chip per result, precedence below | text + icon + edge, never colour alone |
| `LimePill` | existing (+ trailing icon parameter: `check` for "Tamam") | the one lime action per screen | normal, pressed, focused, disabled (45 %, "Hazırlanıyor") | — |
| `OutlinePill` | existing (+ leading icon `restart`) | secondary "Tekrar oyna" on doneToday | normal, pressed, focused | no lime on a finished day |
| `TextLink` | existing | tertiary "Yolculuğa dön", "Tekrar oyna" | normal, focused | — |
| `GlassIconButton` (back) | existing | exit | normal, pressed, focused | the D2 back button |
| `SkeletonCell` | existing | loading headline / week | — | shapes of the real content, no spinner |
| `ScrollBand` | existing (D2) | AX5 only, once scrolled | hidden at offset 0 | reuse |
| **Icons** *(new, drawn)* | `LoopIcon.check` (a 2.1-stroke tick), `LoopIcon.offline` (signal arcs with a slash) | today done / "Tamam"; offline today | — | the drawn thin-outline family (F00 §7), no icon package |

**Chip precedence:** replay → `TEKRAR` (always, even when the replay is Perfect — a replay is never presented as official); first run and Perfect → `HARİKA`; any other first run → `RESMÎ SONUÇ`. `YENİ EN İYİ` does not apply (a daily writes no personal best).

## 8. State Design

### Home Daily entry (A)

| State | When (D3 / D7) | Render | Look | Feels like |
| --- | --- | --- | --- | --- |
| **available** | today cached, no official result | `F07-A-01` | `GÜNLÜK · #34`; muted flame `4 SERİ`; chain: today periwinkle; "Bugünün döngüsü hazır" (text colour) → | an invitation, not a nag |
| **done today** | official result exists | `F07-A-02` | lime flame `5 SERİ`; today lime + check; "Bugün tamam · 5 hamle" | kept |
| **needs connection** | offline / fetch failed, not cached | `F07-A-10` | `GÜNLÜK` (no number — unknown without the pack); today offline glyph; "Bağlantı gerekli" (muted) → | calm; still tappable (opens `/daily` with Retry) |
| loading | fetch in flight, not cached | `F07-A-12` | `GÜNLÜK`; today as a skeleton; "Hazırlanıyor" (muted) | quiet (proposal — NTLC-2) |
| streak missed | `lastCompletedDate` before yesterday | `F07-A-13` | `0 SERİ` muted; three dashed days before today | honest, not punishing |
| **hidden** | `daily_enabled == false` (and, proposed, every other `unavailable` reason — NTLC-2) | `F07-A-11` | no entry; Home = F05 D3 | nothing to explain |
| pressed / focused | — | — | scale .98 / 2·s periwinkle ring, 3·s offset, radius 24·s | responsive |

### `/daily` (A)

| State | Render | Headline / body | Week | Numbers | Action |
| --- | --- | --- | --- | --- | --- |
| **loading** | `F07-A-20` | skeleton bars | skeleton nodes | the local streak (no network needed) | disabled "Hazırlanıyor" |
| **ready** | `F07-A-03` | "Bugünün **döngüsü** hazır." | today waiting | `4 SERİ` · `12 EN İYİ` | "Bugünü oyna" + "Sınırsız hamle · 3 geri alma" |
| ready, streak 0 | `F07-A-23` | same | three missed days | `0 SERİ` | same |
| **doneToday** | `F07-A-21` | "Bugünün döngüsü **tamam.**" | today lime + check | official `5 HAMLE · 1:42 · ★★☆`; `5 SERİ` (lit) · `12 EN İYİ` | outline "Tekrar oyna"; "Yeni döngü gece yarısı." |
| **needsConnection** | `F07-A-04` | "Bugünün döngüsü henüz gelmedi." / "İnternete bağlanınca hazır olur. Yolculuk bu arada açık." | today offline | `4 SERİ` · `12 EN İYİ` | "Tekrar dene" + link "Yolculuğa dön" |
| **unavailable** | `F07-A-22` | "Günlük döngü bugün dinleniyor." / "Yolculuk her zaman açık; günlük döngü yakında geri gelir." | none | none | "Yolculuğa dön" |
| pressed / focused | `F07-A-24`, `F07-A-25` | — | — | — | scale .98 / periwinkle ring |

* No raw error text in any state (D8); the fetch error, invalid pack or empty URL never reach the screen as text.
* `#N` appears only when today's day is known (ready, doneToday). needsConnection / loading / unavailable show `GÜNLÜK` without a number (NTLC-1).

### Play (daily)

| State | Render | Notes |
| --- | --- | --- |
| idle | `F07-A-30`, `F07-A-v-16e-play-daily-header`, `F07-A-v-promax-play-daily-header` | `GÜNLÜK · #34` / "3 Kasım Salı"; `HAMLE 0`; undo dots 3; restart — AC3 needs no extra chrome (unlimited moves and restarts are the defaults) |
| text at the cap | `F07-A-31` | the label block fits left of the `HAMLE` card |
| loading / load error | D1 `D1-11`, `D1-07` | unchanged (a daily loads from the cache) |

### Result (daily)

| Variant | Render | Chip | Headline / subtitle | Stats (this run) | Extra | Streak card | Primary / link |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **first run, 2★** | `F07-A-05` | RESMÎ SONUÇ | "Günlük tamam." / "Optimal 4 hamle. Resmî sonucun kaydedildi." | 5 · 1:42 · ★★☆ | — | today lime ✓; `5 SERİ` (lit), `EN İYİ 12` | Tamam ✓ / Tekrar oyna |
| first run, Perfect, streak 0 → 1 | `F07-A-40` | HARİKA | same | 4 · 0:58 · ★★★ | — | three missed days, today lime; `1 SERİ`, `EN İYİ 12` (best preserved — AC6) | same |
| **replay** | `F07-A-06` | TEKRAR | "Tekrar tamam." / "Optimal 4 hamle. Resmî sonucun değişmedi." | 4 · 1:18 · ★★★ | official row `RESMÎ 5 HAMLE 1:42 ★★☆` | unchanged `5 SERİ` (no reveal) | same |
| pressed | `F07-A-43` | — | — | — | — | — | "Tamam" at .98 |
| Share budget | `F07-A-41`, `F07-A-42` | — | — | — | the dashed F13 slot (annotation only) | — | — |
| rating unresolved | (no render — D2 rule) | per variant | same | `YILDIZ` outline until resolved | — | — | — |

* The streak shows the **effective** value (D6) everywhere: Home, `/daily`, result.
* A run that started yesterday and finished after midnight (D4) shows **its** `#N` in the Play header and is recorded for its date; the result's copy is date-neutral ("Günlük tamam.") for that reason.

## 9. Premium Differentiators

1. **The streak is a chain you can see break** — the Home loop track, reused for days; a missed day is a dashed hollow in the line.
2. **One object at three scales** (Home, `/daily`, result) — the Daily reads as one system, not three screens.
3. **Today is where you are** — periwinkle while it waits, lime once done: the Foundation's two accents keep their exact meanings.
4. **The reward lands after rest** — today's node fills and the numeral steps 4 → 5, after the stars, never delaying control.
5. **Official vs replay is said three ways** — chip (text + icon), subtitle sentence, and the official row with the numbers that did not change.
6. **Home keeps one lime action** — the entry is slate, secondary, and still says number, streak and state at a glance.
7. **Offline is calm and useful** — "Yolculuk bu arada açık" plus Retry; no red, no raw error, the streak still visible.
8. **Share costs no height** — its place is reserved in the primary row, so F13 cannot break the 1.3× fit.
9. **Honest numbers:** no `#N` is shown when it cannot be known; `0 SERİ` is shown when the streak is gone.

## 10. Anti-Patterns to Avoid

* A second lime pill on Home, or a lime Daily banner above the Journey card.
* A calendar grid or a 30-day heatmap (too heavy for Home; F07 needs seven days).
* A fire emoji or a red "streak lost" warning; guilt copy.
* A spinner on `/daily`; a raw error string; "Hata" anywhere.
* A disabled grey Share button in F07.
* Colour-only day states (every state has a shape / edge / glyph difference).
* Uppercasing Turkish in code (`i` → `I`); author the caps.
* Re-typing the answer word as a label on the result (the D2 row is the object).

## 11. Frontend Handoff

**Do not break:**

* one lime action per screen; the Home entry is slate and secondary;
* `WeekTrack` geometry and segment rules (§6), including edge-to-edge segments;
* the chip precedence (§7) and the three official/replay signals (§9.5);
* the effective streak (D6) and `#N` only when known;
* the result's 1.3× no-scroll fit with the Share place counted (§6);
* the D2 win timeline and retry flight (F03 §20.3) — the daily adds only the in-cell star pop and the A streak reveal;
* Turkish copy only through `DailyStrings` (§11.1); no raw error text.

**Flexible:**

* the week data source: seven `DailyRepo.firstRun(guestId, lang, date)` reads for today − 6 … today (no F08 API change) or one query of your choice inside F07 code;
* the exact painter for segments (any smooth monotone curve edge-to-edge);
* the entrance delay for the entry if the Daily state is late (160 ms fade, §5).

**Do not cheapen:**

* the missed-day node must stay hollow + dashed (not just dimmer);
* today's halo and the check glyph;
* weekday labels on `/daily` (they make the chain a week);
* the streak reveal (A) on a first run — no numeral jump without the step.

**Assets / fonts:** none new (Space Grotesk and Manrope already bundled, OFL). Two drawn icons (`check`, `offline`) in `icons.dart` from the paths in `design/src/gen-f07.mjs` (`I.check`, `I.offline`, 24-unit viewBox).

**Parity tolerance:** the D2 / D3 tolerances; the renders are HTML/CSS (Blink), not Flutter — compare composition, spacing and states, not glyph rasterisation.

### 11.1 Strings (interim Turkish — `DailyStrings`; final with PO / localization, F10-UI-LOCALIZATION)

| Key | Text |
| --- | --- |
| `entryLabel(n)` / `entryLabelUnknown` | `GÜNLÜK · #{n}` / `GÜNLÜK` |
| `streakLabel` | `SERİ` |
| `entryAvailable` / `entryDone(moves)` / `entryNeedsConnection` / `entryLoading` | `Bugünün döngüsü hazır` / `Bugün tamam · {moves} hamle` / `Bağlantı gerekli` / `Hazırlanıyor` |
| `entrySemantics` | `Günlük döngü #{n}, {durum}. {streak} günlük seri.` |
| `dateCaps` / `dateLong` | `3 KASIM` / `3 Kasım Salı` (`tr` locale) |
| weekdays | `PZT SAL ÇAR PER CUM CMT PAZ`, today `BUGÜN` |
| `headReady` | `Bugünün` / `döngüsü` (lime) ` hazır.` |
| `headDone` | `Bugünün döngüsü` / `tamam.` (lime) |
| `headNeedsConnection` / `bodyNeedsConnection` | `Bugünün döngüsü henüz gelmedi.` / `İnternete bağlanınca hazır olur. Yolculuk bu arada açık.` |
| `headUnavailable` / `bodyUnavailable` | `Günlük döngü bugün dinleniyor.` / `Yolculuk her zaman açık; günlük döngü yakında geri gelir.` |
| `play` / `retryFetch` / `backToJourney` / `preparing` | `Bugünü oyna` / `Tekrar dene` / `Yolculuğa dön` / `Hazırlanıyor` |
| `rulesCaption` / `nextCaption` | `Sınırsız hamle · 3 geri alma` / `Yeni döngü gece yarısı.` |
| stat labels | `HAMLE`, `SÜRE`, `YILDIZ`, `SERİ`, `EN İYİ`, `RESMÎ` |
| `playHeader(n)` | `GÜNLÜK · #{n}` + `dateLong` |
| chips | `HARİKA`, `RESMÎ SONUÇ`, `TEKRAR` |
| `resultHeadFirst` / `resultHeadReplay` | `Günlük tamam.` / `Tekrar tamam.` |
| `resultSubFirst(opt)` / `resultSubReplay(opt)` | `Optimal {opt} hamle. Resmî sonucun kaydedildi.` / `Optimal {opt} hamle. Resmî sonucun değişmedi.` |
| `done` / `replay` | `Tamam` / `Tekrar oyna` |
| back semantics | `/daily`: `Ana ekrana dön`; result: `Günlük ekrana dön` |
| duration semantics | `{m} dakika {s} saniye` |

Join `·` separators and numbers with NBSP where a line may wrap (F05 rule: wrap before `·`).

## 12. Provisional Self-Review Against Rubric (Direction A; advisory — the gate score is QA's)

| Dimension | Score | Reason |
| --- | --- | --- |
| Experience Fit | 10 | the habit loop in one glance on Home; offline keeps the Journey open; replay never threatens the official result |
| Visual Hierarchy | 10 | Home: Journey → one lime CTA → caption → Daily; result: chip → headline → row → numbers → streak → one action |
| Layout, Rhythm & Responsiveness | 9 | measured fit on 16 / 16e / Pro Max, no scroll at 1.3× on any surface; Home now scrolls at AX5 (NTLC-4) |
| Typography & Content Craft | 9 | authored caps, tabular numerals, date-neutral result copy; copy is interim |
| Color, Surface & Asset System | 10 | tokens only; lime and periwinkle keep their Foundation meanings; two drawn icons in the family |
| Interaction, State & Feedback | 9 | every D3 state + loading / disabled / pressed / focus / offline / hidden rendered; the press follows the shipped component |
| Motion & Sensory Quality | 9 | a small, specified reveal and entrance with reduced paths; stills only (not motion-critical) |
| Originality & Product Identity | 10 | the loop track becomes the week — specific to Looplet |
| Accessibility & Inclusive Quality | 9 | non-text ≥ 3 : 1, text ≥ 6.28 : 1, greyscale-safe day states, AX5 without clipping; VoiceOver untested (design artefact) |
| Implementation Fidelity & Polish | 9 | geometry as rules and measured fits; one new painter and three small component extensions |
| **Total** | **94** | provisional — not an acceptance input. Lowest dimension 9. Fail conditions: none known. |

Direction B, same scale (advisory): about 90 — weaker Originality (8, the big-number ticket is a common pattern) and Accessibility (8, the capsule edge 1.66 : 1), otherwise similar.

## 12a. Screen / State / Viewport Matrix (Direction A)

| Screen | State | Viewport / Device | Source Artifact | Critical Assertions |
| --- | --- | --- | --- | --- |
| Home | Daily available | 393×852, 390×844, 440×956 | `F07-A-01`, `F07-A-v-16e-home-daily-available`, `F07-A-v-promax-home-daily-available` | one lime action; entry slate; `#34`, `4 SERİ`, today periwinkle; bottom ≥ 72 pt above the home indicator |
| Home | done today | 393×852 | `F07-A-02` | lime flame + today check; "Bugün tamam · 5 hamle" |
| Home | needs connection / loading | 393×852 | `F07-A-10`, `F07-A-12` | no `#N`; offline glyph / skeleton; muted state line |
| Home | streak missed | 393×852 | `F07-A-13` | `0 SERİ`; dashed gaps |
| Home | hidden | 393×852 | `F07-A-11` | identical to F05 D3 |
| Home | 1.3× | 393×852, 390×844, 440×956 | `F07-A-50`, `F07-A-v-16e-home-text-cap-1_3`, `F07-A-v-promax-home-text-cap-1_3` | no scroll (≥ 29 pt spare) |
| Home | AX5 | 393×852, 390×844 | `F07-A-51`, `F07-A-52`, `F07-A-v-16e-home-ax5-top` | card + CTA + caption visible at offset 0; entry by scroll; band only when scrolled |
| Home | entrance | 393×852 | `F07-A-M-home-entrance-t0000 … t0420` | entry 180–420 ms after the caption |
| `/daily` | loading | 393×852 | `F07-A-20` | skeletons; streak shown; pill disabled 45 % |
| `/daily` | ready | 393×852, 390×844, 440×956 | `F07-A-03`, `F07-A-v-16e-daily-ready`, `F07-A-v-promax-daily-ready` | week with weekdays; one lime action; AC3 caption |
| `/daily` | ready, streak 0 | 393×852 | `F07-A-23` | `0 SERİ`; three missed |
| `/daily` | doneToday | 393×852, 390×844, 440×956 | `F07-A-21`, `F07-A-v-16e-daily-done-today`, `F07-A-v-promax-daily-done-today` | official numbers; no lime pill; outline replay |
| `/daily` | needsConnection | 393×852 | `F07-A-04`, `F07-A-56` (AX5 end) | calm copy; Retry lime; link to Journey; no `#N` |
| `/daily` | unavailable | 393×852 | `F07-A-22` | no week, no numbers; one way back |
| `/daily` | pressed / focus | 393×852 | `F07-A-24`, `F07-A-25` | .98 / periwinkle ring |
| `/daily` | 1.3× / AX5 | 393×852 | `F07-A-53`, `F07-A-54`, `F07-A-55` | no scroll at 1.3×; AX5 scroll, back button fixed |
| Play | daily header | 393×852, 390×844, 440×956 | `F07-A-30`, `F07-A-v-16e-play-daily-header`, `F07-A-v-promax-play-daily-header` | two-line label block left of `HAMLE`; board unchanged |
| Play | header at 1.3× | 393×852 | `F07-A-31` | no collision with the `HAMLE` card |
| Result | first run | 393×852, 390×844, 440×956 | `F07-A-05`, `F07-A-v-16e-result-first-run`, `F07-A-v-promax-result-first-run` | `RESMÎ SONUÇ`; streak 5 / best 12 |
| Result | replay | 393×852 | `F07-A-06` | `TEKRAR`; official row unchanged; no reveal |
| Result | streak 0 → 1, Perfect | 393×852 | `F07-A-40` | `HARİKA`; `1 SERİ`; `EN İYİ 12` preserved |
| Result | pressed | 393×852 | `F07-A-43` | .98 |
| Result | Share budget (1.0× / 1.3×) | 393×852, 390×844 | `F07-A-41`, `F07-A-42`, `F07-A-v-16e-result-share-slot-budget-cap-1_3` | the tallest variant + Share fits at 1.3× (≥ 57 pt spare) |
| Result | 1.3× / AX5 | 393×852, 390×844, 440×956 | `F07-A-57`, `F07-A-58`, `F07-A-59`, `F07-A-v-*-result-replay-text-cap-1_3` | no scroll at the cap; AX5 scroll lands at 0 |
| Result | streak reveal | 393×852 | `F07-A-M-streak-reveal-t0940 / t1300 / t1370 / t1440 / reduced` | after the stars; reduced = final state |

## 12b. Visual Evidence Manifest

**Provenance for every record:** Source Revision HEAD `642e1d2` + working tree (`design/src/gen-f07.mjs`, SHA-1 `d0715519dc22…`, derived from F05 `gen-d3.mjs` and F03 `gen-d2.mjs`). Method: HTML/CSS → PNG with headless Chrome at devicePixelRatio 2 (`sh design/src/render-f07.sh F07- jobs-f07.txt`); `node gen-f07.mjs .` regenerates every page; `sh fit-f07.sh` writes the measured fits (`fit-f07.txt`); `contrast-f07.txt` is computed by the generator; motion stills are frames frozen with a fixed animation time. Captured by the UI Designer, 2026-09-29. Generated design artefacts, not runtime captures; the board and answer word are Journey level 4 (BALIK) as a fixture, not Daily content.

| Evidence ID | Kind | Screen / State | Viewport / Device | Artifact | Source Revision | Captured By | Captured At | Result / Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| DR-F07-A | direction-render | A "Hafta döngüsü": Home available / done; `/daily` ready / needsConnection; result first run / replay | 393×852 | features/f07-daily-challenge/design/F07-A-01 … F07-A-06 (*.png) | 642e1d2 + working tree | UI Designer | 2026-09-29 | recommended; Pending Selection (F07.DIRECTION-SELECT) |
| DR-F07-B | direction-render | B "Günün bileti": the same six states | 393×852 | features/f07-daily-challenge/design/F07-B-01 … F07-B-06 (*.png) | 642e1d2 + working tree | UI Designer | 2026-09-29 | alternative |
| DR-F07-CMP | direction-render | A vs B side by side | 1898×1394 | features/f07-daily-challenge/design/F07-sheet-1-directions-A-vs-B.png | 642e1d2 + working tree | UI Designer | 2026-09-29 | composite of DR-F07-A / B |
| F07-A-STATES | selected-source *(candidate — becomes selected-source only if A is selected)* | Home entry: available, done, needs connection, loading, streak missed, hidden; `/daily`: loading, ready, ready-streak-0, doneToday, needsConnection, unavailable, pressed, focus | 393×852 | design/F07-A-01 … 04, 10 … 13, 20 … 25 (*.png); sheet F07-sheet-2 | 642e1d2 + working tree | UI Designer | 2026-09-29 | full state set |
| F07-A-PLAY | selected-source *(candidate)* | Play daily header (1.0×, 1.3×) | 393×852, 390×844, 440×956 | design/F07-A-30, F07-A-31, F07-A-v-*-play-daily-header (*.png) | 642e1d2 + working tree | UI Designer | 2026-09-29 | — |
| F07-A-RESULT | selected-source *(candidate)* | result: first run, replay, 0 → 1 Perfect, pressed, Share budget | 393×852, 390×844, 440×956 | design/F07-A-05, 06, 40 … 43, F07-A-v-*-result-* (*.png); sheet F07-sheet-3 | 642e1d2 + working tree | UI Designer | 2026-09-29 | Share budget = annotation only |
| F07-A-A11Y | accessibility | 1.3× and AX5 on Home, `/daily`, result; contrast table; fit table | 393×852, 390×844, 440×956 | design/F07-A-50 … 59, F07-A-v-*-text-cap-1_3, F07-A-v-16e-home-ax5-top (*.png); `src/contrast-f07.txt`; `src/fit-f07.txt`; sheet F07-sheet-4 | 642e1d2 + working tree | UI Designer | 2026-09-29 | no scroll at 1.3× anywhere; Home scrolls at AX5 (NTLC-4) |
| F07-A-MOTION | motion-prototype *(stills)* | Home entrance with the entry; the result streak reveal + reduced | 393×852 | design/F07-A-M-home-entrance-t0000 … t0420, F07-A-M-streak-reveal-t0940 … t1440, F07-A-M-streak-reveal-reduced (*.png); timing in `gen-f07.mjs` (`revealCss`, `homeScreen` entrance) | 642e1d2 + working tree | UI Designer | 2026-09-29 | stills of a timed CSS prototype; not motion-critical scope |

**Limits stated:** HTML/CSS (Blink), not Flutter; iOS frames only (Android not rendered); no runtime capture; VoiceOver not exercised; B's full state set is not rendered (exploration states only).

## 13. Assumptions

* The week shows the **last seven local dates** ending today (not a calendar week), derived from first-run entries; days before the player's first Daily read as missed (a new player sees six hollow days — a week to fill).
* When the stored streak and the week disagree (a clock moved back, D6), the numeral shows the effective streak and the week shows the recorded dates; neither is corrected by the UI.
* "Tamam" returning to `/daily` (not Home) follows D8 "From the daily result → back to `/daily`".
* The Play header's back target is `/daily` (the caller).
* The result copy is date-neutral because a run can finish after midnight (D4).
* AC3 needs no extra Play chrome: unlimited moves and restarts and 3 undos are the shipped defaults; the `/daily` caption states it once.

## 14. Needs Tech Lead Clarification

1. **NTLC-1 — `#N` offline (contract gap).** D8 shows `#N` on the Home entry, the Play header and `/daily`, and D3 makes a cached day playable offline — but `daily_puzzle_cache` stores only `puzzleJson` (F08 schema, frozen), and `dailyNumber` / `numberingEpoch` live in the pack. Offline, a cached day cannot show its number. Options: (a) cache the pack's day object (`{dailyNumber, puzzle}`) in `puzzleJson` — no schema change, a content-semantics ruling; (b) persist `numberingEpoch` somewhere F07 owns and compute `#N` by D2 (2) — `SettingsRepo` has no free slot, so this needs a schema or storage decision; (c) omit `#N` whenever the pack is not in memory. **Recommendation: (a).** The design already omits `#N` when the day is unknown (needsConnection / loading / unavailable).
2. **NTLC-2 — Home entry mapping of the other states.** D8 names available / done today / needs connection / hidden. Proposed: `loading` → the quiet "Hazırlanıyor" entry (`F07-A-12`), tappable; `unavailable` for any reason (not only `daily_enabled == false`) → **hidden**, because Home has nothing useful to say about an empty URL or an invalid pack.
3. **NTLC-3 — the Share place.** "The layout reserves its place" is implemented as a **zero-height slot at the right end of the primary row** (§6), measured to fit at 1.3×; F07 draws nothing. F13 inherits a 63·s round button or brings its own fit proof. Please confirm this reading of D8 / prd Open Questions (1).
4. **NTLC-4 — Home at AX5 now scrolls.** With the entry, Home at AX5 is 257 pt taller than the screen; F05 D3 needed no scroll at AX5. The Journey card, CTA and caption stay fully visible at offset 0 and the entry is reached by scrolling (the D2 `ScrollBand` pattern). This amends F05 §18's text-scale outcome (a cross-feature ruling). The alternative — capping the entry's state line at 1.3× (container text) — removes ~40 pt but still scrolls.
5. **NTLC-5 — daily result deviations from D2 (for the record):** one-line headline; stars inside the stats card (`YILDIZ`) instead of a separate row; `OPTİMAL` moved into the subtitle; no `EN İYİ` stat (a daily writes no personal best). They keep the 1.3× no-scroll rule with the streak card and the Share place. The D2 win sequence itself is unchanged.
6. **Design-layer additions for F07-FE (no token change):** `WeekTrack`, `DailyEntryCard`, the official row, `LoopNode` states `missed` / `todayDone` / `todayOffline` + size, `StatCell` icon and stars cells, `LimePill` / `OutlinePill` icon slots, icons `check` and `offline`.

---

## Sonraki Komut

Run Tech Lead
