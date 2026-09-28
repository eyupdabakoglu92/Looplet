# F05 — journey-progression: UI Design Handoff (Phase D3 — Home + app shell)

> **Task:** F05-UI-D3 (UI Designer, 2026-09-29). **Contract:** `architecture.md` §18 — composition (1), N1 (2), loop track (3), copy (4), `Semantics` (5), text scale (6), store-error screen (7), launch and splash (8), performance (9); amendments §18.4; evidence §18.6.
>
> **Authority chain:** design-foundation §18 (decisions 4, 5, 6; consequences 4–5) → F00 `ui-design.md` §6–§8, §10, §13 and the selected source `S-06b-home-today.png` → this handoff → Frontend. The D1 load error (F03 `ui-design.md`, `D1-07`) is the sibling of the store-error screen.
>
> **Supersedes:** the Direction A home handoff (F05-UI, 2026-09-08: the 30-tick amber ring, `PlayTheme` tokens, the pulsing in-progress node). Its micro-tutorial sections were already superseded by F03 D1 (F03 `ui-design.md` §1–§14, architecture §19.5), and its `CompletionPanel` weighting by F03 D2 (F03 `ui-design.md` §16). The whole previous file is archived byte for byte as `history/f05-journey-progression-2026-09-29/ui-design-before-phase-d3.md` (SHA-1 `f2c133d8…`).
>
> **Unchanged:** the §6 read-model, unlock, persistence, the F09 seam, routes (`/` ⇄ `/play`). Presentation plus the N1 CONTINUE rule of §18.3 (2), which is already in the contract.

---

## 1. Feature Summary

* **What changes:** the first screen of every launch. Home becomes the Loop Glass composition of `S-06b`:
  * the `Looplet` wordmark;
  * a glass card with the Journey position (`YOLCULUK · N / 30`), a two-line headline and a **loop track** — a window of five levels along a rising line;
  * one lime "Devam et" pill with its glow, and the caption of where it leads.
* **The app shell** joins it:
  * the native launch and the Flutter splash become the same navy ground, with no white frame;
  * the store-error screen becomes a Turkish glass card that never shows the raw exception.
* **Primary user intent:** know where I am in the Journey, and get back into it in one tap.
* **Fixes carried:** A-2 home (AX5 clipping; the 10 px debug overflow of F03-QA-D2R N5), A-3 (English + raw exception), A-4 (white launch), and the N1 rule (a replay in progress is never hidden, also after 30 / 30).

## 2. Design Direction

The Exploration Gate for Home closed at F00. Three directions were rendered on Home (`A-06`, `B-06`, `C-06`, `C-06b` in `features/f00-design-foundation/design/`), and **the user selected Direction C "Loop Glass" on 2026-09-21** (design-foundation §18). D3 builds `S-06b` (the shipped-scope composition) and does not reopen the direction.

What D3 designs that the selected source did not settle is **how 30 levels fit a card that shows five**. Two materially different windowing directions are rendered on the same states (12 / 30, 25 / 30, 4 / 30):

### Direction A — "sliding five" (recommended)

* **Character:** the track is a trail. Five consecutive levels ride a rising line. The current level sits at the top end with its halo, the four behind it are lime, and a lead-in line fading in from the card's edge says "there is more behind you". It reads as climbing.
* **Why strong:** it is `S-06b` itself: the same five slots, the same rising curve and the current node at the top. It has one fixed geometry for every state (always five nodes), so layout, tests and parity are predictable. Every state stays legible, including the new player (current at the foot of the line, four dashed locked nodes ahead) and the finish (26–30 lime, 30 crowned).
* **Risks:** the absolute position in the Journey is carried by the label (`12 / 30`), not by the track; the track shows local context only.
* **Artefacts:** `design/D3-03-home-in-progress-4of30.png`, `D3-04a-home-window-12of30.png`, `D3-04b-home-window-25of30.png` (+ every state in §8).

### Direction B — "band window" (rendered alternative)

* **Character:** the window is the current **difficulty band** (1–3, 4–6, 7–10, 11–15, 16–20, 21–25, 26–30), so it shows 3 to 5 nodes. Seven band pips under the label map the whole Journey (done bands lime, the current band periwinkle, the rest outlined), with widths proportional to band size.
* **Why strong:** it shows the whole Journey at a glance, and the window matches the difficulty curve's "one new idea at a time".
* **Risks:**
  * The node count varies (3–5), so the composition changes from band to band. At 4 / 30 the card shows only three nodes and feels empty (`D3-B-04of30-band`).
  * At the start of a band the current node sits at the foot with four locked nodes (`D3-B-25of30-band`), so a player at 25 / 30 sees "mostly locked".
  * The pips imply named chapters, which is level metadata the Foundation keeps as future scope (decision 4).
  * The pips are a second progress indicator competing with the label.
* **Artefacts:** `design/D3-B-04of30-band.png`, `D3-B-12of30-band.png`, `D3-B-25of30-band.png`; side by side in `D3-sheet-windowing-A-vs-B.png`.

### Recommendation and Selection Record

* **Direction (Loop Glass, composition `S-06b`):** selected by the user, 2026-09-21 (`F00.FOUNDATION-SELECTION`). Not reopened.
* **Windowing:** the UI Designer recommends **A**. **Pending Selection** — the Tech Lead decides at the visual-gate checkpoint whether A is adopted within §18.3 (3) (the D2 precedent for retry A: a design choice inside a selected direction, not an Exploration Gate selection).
  * **Why A:** it is the selected source's own geometry, it keeps one stable layout for every state, and it adds no information the Foundation deferred.
* **N1 (terminal with a replay in progress):** decided by the user, 2026-09-29 (F05.D3-N1-REPLAY-PRECEDENCE; PO-REV-2026-09-29-F05-CONTINUE). The render `D3-07` matches the preview the user answered.

## 3. Screen Goals

| Screen / state | Purpose | What the player does | First 3 seconds |
| --- | --- | --- | --- |
| Native launch → splash | cover app start | nothing | one continuous navy ground; the wordmark arrives; no white flash |
| Home · new player | start the Journey | tap "Devam et" | "İlk döngüyü çöz." — one bright node at the foot of the line, four ahead |
| Home · mid / in progress | resume | tap "Devam et" | where I am (`YOLCULUK · N / 30`), the current node at the top of the climb, "Seviye N" (· sürüyor) |
| Home · replay in progress (before 30 / 30) | finish the replay | tap "Devam et" | "Yarım kalan döngüne dön." — the replayed level is current, done levels on both sides |
| Home · terminal 30 / 30 | celebrate, offer a replay | tap "Tekrar oyna" (→ level 1) | "Tüm döngüler tamam." — 26–30 lime, 30 crowned |
| Home · terminal + replay in progress (N1) | never hide a half-played puzzle | tap "Devam et" | still "30 / 30 · Tüm döngüler tamam.", with the replay as the current node and "Seviye N · sürüyor" |
| Store error | recover calmly | tap "Tekrar dene" | "your data is safe; try again" — no technical text |

## 4. UX Flow Direction

* **Cold start:**
  1. Native launch: the ground image, with no content.
  2. Flutter splash: the same ground; the `Looplet` wordmark fades in at its Home position (0 → 1 in 160 ms; instant under reduced motion).
  3. Bootstrap OK → Home: the wordmark stays; the card, the CTA and the caption enter (§5 motion).
  4. Bootstrap or migration fails → the store-error screen.
* **The first frame before the Journey model loads is the splash frame** (the wordmark only). The Home content enters when the model arrives. There is no empty card and no spinner (`D3-08` = `D3-22`).
* **Home → Play:** "Devam et" → `/play` with `currentLevel` (§6 / §8, unchanged). With 30 / 30 and a session in progress, "Devam et" resumes it (§18.3 (2)). With 30 / 30 and no session, "Tekrar oyna" opens level 1.
* **Play → Home** (back, system back, the result's back, Next at level 30): Home is live (§6). The track and caption reflect the new state when Home is shown again; the node advance itself is not animated (§5).
* **Store error → Retry:** re-runs the bootstrap. While it runs the splash frame shows again. The screen returns if the bootstrap fails again. There is no second action — the app has nothing else to offer without a store.
* **Chrome:** Home and the store-error screen are the app root — **no back affordance**, no top bar, and the system status bar over the ground. System back on Home leaves the app (OS default). On the store-error screen it also leaves the app; the data stays intact.

### App Chrome & Navigation Rules

| Screen | System header | Custom top bar | Back affordance | Hardware / gesture back |
| --- | --- | --- | --- | --- |
| Native launch / splash | none (status bar only) | none | none | n/a |
| Home (`/`) | none | the `Looplet` wordmark (not a button) | none — app root | OS default (leaves the app) |
| Store error | none | the wordmark | none — app root | OS default (leaves the app) |

Sibling parity: the wordmark sits at the same (25, 58)·s on the splash, Home and the store-error screen. The store-error card is the D1 load-error card (`D1-07`) with the wordmark in place of the chevron, because this screen has no caller to go back to.

## 5. Visual System

### Background Direction

* The Foundation ground (`LoopBackdrop`): navy `#0A1030 → #070C25 → #050A1E`, the top-right light and the teal spill on the left.
* The native launch shows **the same ground as a bundled image** (`D3-asset-launch-backdrop.png`, 1290 × 2796, aspect-filled) over a solid `#070C25`. The native frame, the splash and Home are therefore the same picture. No texture.

### Surface Direction

* **Primary surface:** the glass card (`GlassCard`, radius 30·s), with the two decorative swirl arcs of `S-06b` clipped inside it.
* **Secondary surfaces:** the nodes (§7) and the CTA pill.
* **Depth:** shadows only for hierarchy — the card (24 / 60), the current node (12 / 30 periwinkle), done nodes (8 / 20 lime) and the CTA glow (18 / 50 lime at .26, Home keeps its glow; F00 ui-design §7).
* No blur (§18.3 (9)).

### Color Direction

| Role | Value | Use |
| --- | --- | --- |
| Lime (resolution, emphasis, primary) | `#DDFA6B`, nodes `#E3FB7E → #CDEB4B`, CTA `#E4FB80 → #D5F252` | done nodes, the finish node, `let`, the headline's emphasis word, the CTA |
| Periwinkle (where you are) | `#B9C3FF → #8792F0`, halo `rgba(168,180,249,.16)` | the current node only; the open-node outline; the focus ring |
| Text / muted | `#F4F6FF` / `#AEB4CA` | headline, numerals / label, caption, locked numerals, error body |
| Danger | none | the store error uses the calm glass card and the periwinkle `loopBreak` glyph, as the D1 load error does — nothing is the player's fault |
| Success | lime (the finish) | 30 / 30 |

Contrast (computed, `design/src/contrast-d3.txt`): label 6.37 : 1 on glass; headline 12.19; lime emphasis 11.24; done numeral 14.05; current numeral 6.67 (on the darkest stop); open numeral 10.19; locked numeral 5.75; CTA ink 15.01; caption 9.35 on the ground; error body 6.37. Non-text: the open outline 3.52 and the **locked outline 3.41** (raised from .46 to .62 alpha to clear 3 : 1).

### Typography Direction

* **Wordmark:** Space Grotesk 500 25·s, `Loop` `#F4F6FF` + `let` lime (`LoopletWordmark`).
* **Label:** Manrope 600 11·s caps, +0.2 em, authored `YOLCULUK` — never `toUpperCase`.
* **Headline:** Space Grotesk 500 28·s / 1.16, two authored lines, one lime word.
* **Node numerals:** Space Grotesk 500, 14·s (small) / 17·s (current, finish).
* **CTA:** Manrope 500 16·s. **Caption:** Manrope 500 14·s, muted.
* **Error screen:** headline 28·s Space Grotesk, body Manrope 500 14.5·s / 1.4 muted, pill Manrope 500 16·s.

### Motion / Sensory Direction

* **Home entrance** (when the Journey model arrives; prototype `design/src/D3-motion-prototype.html`, `?t=<ms>`, `?rm=1`):
  * card 0 → 240 ms; CTA 60 → 300 ms; caption 120 → 340 ms;
  * each is opacity 0 → 1 with a 10·s rise, ease-out `cubic-bezier(.22,.61,.36,1)`;
  * at rest by 340 ms. The wordmark does not move — it is already there from the splash.
* **Reduced motion** (`reduceMotionRequested()`): everything appears at once (`D3-M-entrance-reduced`); the splash wordmark appears without a fade.
* **No idle motion on Home:**
  * The shipped breathing pulse on the in-progress node is dropped: the Foundation specifies no Home motion, and the halo already marks the place.
  * The node advance after a win is not animated. Home is not visible during the win, and on return it simply shows the new state.
* **Interruption:** if the model changes during the entrance (a very fast return from `/play`), the entrance is not restarted; the content updates in place.
* **Pressed CTA:** the shipped `LimePill` press (scale 0.98). The −5 % brightness of the Foundation render is **not** added here (RESULT-F00-COMPONENT-ALIGN stays open; do not fork the press per screen).
* **Audio / haptics:** N/A — F11.

## 6. Layout Structure

All measurements are pt at the 358 reference, × `s = W / 358`; `e = H − 717·s` is the spare height (`S-06b` parity: card top 132.8 pt, CTA top 486.3 pt on 393 × 852; the render reads 133 / 486).

* **Wordmark:** (25, 58)·s.
* **Content column:** left 24·s, width 309·s, top `115·s + 0.1·e`. It is a flow column, so free text can grow without overlap:
  1. **Card** 308·s wide (offset 0.5·s), radius 30·s, padding 31·s / 24.5·s, min-height 300·s:
     * the label (11·s caps);
     * the headline (margin-top 15·s; two lines, 28·s / 1.16);
     * the **track block**: margin-top 12·s, full card width, height 166·s. At 1.0× the card is exactly 300·s: 31 + 11 + 15 + 65 + 12 + 166. It grows only when the capped headline or label does.
  2. **CTA:** margin-top 22·s, 309·s × min 63·s, radius 32·s, padding 12·s / 23·s; the label left, `LoopIcon.arrowRight` 20·s right.
  3. **Caption:** margin-top 17·s, centred, 14·s.
* **The loop track (direction A), card-local coordinates:**
  * **Window** (`design/src/window-d3.txt` lists it for every rendered state):
    * terminal (`currentLevel == null`) → 26–30;
    * the current level is the frontier (no completed level above it) → `start = clamp(current − 4, 1, 26)`;
    * the current level is a replay (a completed level above it exists) → `start = clamp(current − 2, 1, 26)`.
  * **Spacing:** centre-to-centre 50 between two small nodes, and 64 next to a big node (current or finish, 58 pt with a 76 pt halo). The chain is centred on the card's centre (x = 154).
  * **Height:** `y = 236 − 62·p^1.25`, with `p = (x − 40) / 230` clamped to 0…1. The track block starts at card y 134, so a node's block y is `y − 134`.
  * **Lead-in:** if the window starts after level 1, a lime line fades in from the card's left edge (x 0, y 240) to the first node.
  * **Tail:** if more levels follow the window and there is ≥ 48 pt of room, a dashed muted line runs to the card's right edge.
  * **Segments:** into a done or finish node, solid lime 3.2·s (0.55 opacity when leaving the current node); into the current node, a lime → periwinkle gradient; into an open or locked node, dashed muted 2·s (2 / 5).
  * **Guarantees**, checked in the renders: nodes never overlap each other or a halo (the minimum gap to a halo edge is 64 − 38 − 19 = 7 pt); the current node is always inside the window; nothing is drawn outside the card.
* **Store-error screen:** the wordmark at (25, 58)·s; a column (card + pill, gap 20·s) centred between 118·s and `H − 40·s`, left 24.5·s, width 309·s. The card has padding 28 / 26 / 30·s; a row with the label and the 44·s `loopBreak` glyph; the headline (margin 16·s); the body (margin 12·s). Then one `LimePill` (no glow, no icon — the D1 sibling). In debug builds only, a dashed details box follows the pill (§8).
* **Rhythm:** the lower third of Home stays empty on purpose, as in `S-06b`. The card and the CTA are one group, and the eye ends on the caption.

## 7. Component Decisions

| Component | Role | Visual weight | States | Why not generic |
| --- | --- | --- | --- | --- |
| `LoopletWordmark` (existing) | identity, top-left | low–medium | capped at 1.3× | a text-set mark with a lime tail — not a logo lockup |
| `GlassCard` (existing) | the Journey card | medium | grows with the capped headline | holds the swirl arcs and the track — the card is the journey |
| **`LoopTrack`** (new, D3 design-layer addition) | the window of five levels | high | the window rule, segments, lead-in and tail (§6) | a climbing trail instead of a progress bar or ring |
| `LoopNode` (existing, **extended**) | one level | done low / current highest | **done**: lime 38·s. **current**: periwinkle 58·s + 76·s halo. **open**: glass fill `rgba(255,255,255,.06)`, 1.5·s solid periwinkle outline (.62), text numeral. **locked**: fill `.035`, 1.5·s **dashed** outline `rgba(174,180,202,.62)`, muted numeral. **finish**: lime 58·s + lime halo (`rgba(221,250,107,.11)`, edge .30) | each state differs in fill *and* edge *and* size — readable in greyscale |
| `LimePill(glow: true)` (existing) | the one action | highest | normal, pressed (0.98), focused (2·s periwinkle ring, 3·s offset), label wraps between words | the only lime surface outside the track |
| Caption | where the CTA leads | low | "Seviye N" / "Seviye N · sürüyor" | no chip; plain muted text with no-break joins (§11) |
| Store-error card | recovery | medium | normal, AX5 (scrolls), debug details | the D1 load-error card, with the wordmark in place of the chevron |
| `ScrollBand` (existing, D2) | keeps scrolled text off the status bar | — | only when the error column scrolls (AX5) | reuse, no new pattern |

## 8. State Design

| State | Render | Look | Differs from the baseline by | Feels like |
| --- | --- | --- | --- | --- |
| **Home · new (0 / 30)** | `D3-01` | label `0 / 30`; "İlk döngüyü çöz."; node 1 current at the foot, 2–5 locked (dashed); "Devam et" / "Seviye 1" | no lime yet; the line ahead is dashed | a clear first step |
| Home · new, level 1 started | `D3-01b` | as new; caption "Seviye 1 · sürüyor" | the caption only | "I've started" |
| **Home · mid (4 / 30)** | `D3-02` | 1–4 lime, 5 current at the top; "Sıradaki döngüyü çöz."; "Seviye 5" | baseline | momentum |
| **Home · in progress (4 / 30)** | `D3-03` | as mid; "Seviye 5 · sürüyor" (`S-06b` parity) | the caption | "pick up where I left" |
| Home · window 12 / 30, 25 / 30 | `D3-04a`, `D3-04b` | 9–13, 22–26; the lead-in line from the edge | the numbers and the lead-in | a longer road behind |
| **Home · replay in progress (12 / 30, replaying 7)** | `D3-05` | window 5–9: 7 current in the middle, 8–9 lime after it; "Yarım kalan döngüne dön."; "Seviye 7 · sürüyor" | the headline and the current node's position | "finish what I opened" |
| **Home · terminal (30 / 30)** | `D3-06` | 26–29 lime, 30 **finish** (lime, crowned by its halo); "Tüm döngüler tamam."; "Tekrar oyna" / "Seviye 1" | no periwinkle anywhere | earned completion |
| **Home · terminal + replay (N1)** | `D3-07` | `30 / 30`, "Tüm döngüler tamam."; window 10–14 with 12 current; "Devam et" / "Seviye 12 · sürüyor" | the CTA and caption resume; the card still says complete | nothing is lost |
| Home · loading | `D3-08` | = the splash (`D3-22`): ground + wordmark | no card or CTA yet | calm, continuous |
| Home · CTA pressed | `D3-09` | the pill at 0.98 | scale | responsive |
| Home · focus (keyboard) | `D3-11` | 2·s periwinkle ring, 3·s offset, on the pill | the ring | reachable without touch |
| Home · 1.3× | `D3-10`, `D3-v-*-text-cap-1_3` | the headline, label, wordmark and numerals at the cap; the card grows 12 pt | the size only | the same composition |
| Home · AX5 | `D3-10b`, `D3-10c`, `D3-v-16e-home-ax5` | container text at 1.3×; CTA label and caption at the OS scale; the caption wraps before "·" | larger free text; **no scroll needed** on 390–440 widths | readable, nothing clipped |
| **Store error** | `D3-20` | glass card: `KAYITLI VERİLER`, `loopBreak`; "Kayıtlı verilerin açılamadı."; "İlerlemen güvende; hiçbir şey silinmedi."; "Tekrar dene" | no board, no chevron | calm, one way forward |
| Store error · AX5 | `D3-20b` (offset 0), `D3-20d` (scrolled to the end, `ScrollBand` under the status bar) | the body and pill at the OS scale; the column scrolls; the pill is reached by scrolling | scroll | still one clear action |
| Store error · debug build | `D3-20c` | a dashed box under the pill: `DEBUG · YALNIZ GELİŞTİRME DERLEMESİ` + the exception | debug only (`kDebugMode`) | developer detail, visibly apart |
| Native launch | `D3-21` (iOS), `D3-21b` (Android; light and dark mode identical) | the ground image, nothing else | — | no white |
| Splash | `D3-22` | ground + wordmark | — | continuous |
| Entrance | `D3-M-entrance-t0000 … t0340`, `D3-M-entrance-reduced` | §5 | — | settled |

Not applicable on this surface: empty (the Journey always exists), disabled CTA (there is always a target), selected (no choice). Error is covered by the store-error screen; a Home-level content error does not exist (the model is local).

## 9. Premium Differentiators

1. **The track is a climb, not a bar:** the current node sits at the top of a rising line; the finish at 30 / 30 is crowned in lime.
2. **Four node states that read in greyscale:** fill vs outline, solid vs dashed, and size with a halo — colour is never the only cue.
3. **A lead-in line that fades from the card's edge,** so a window of five still says "there is more behind you" without a second indicator.
4. **One headline per situation, one lime word:** "İlk / Sıradaki döngüyü çöz.", "Yarım kalan döngüne dön.", "Tüm döngüler tamam." — authored lines, not a template.
5. **The N1 state keeps both truths:** the card says complete (30 / 30), and the CTA resumes the replay.
6. **One continuous picture from cold start:** the native launch image is the Flutter backdrop, the wordmark lands where Home keeps it, and only the content enters.
7. **An error screen that looks like the product:** the sibling of the D1 load-error card; calm periwinkle glyph, reassurance first, no stack trace.
8. **The same anchors as the selected source** (card 133, CTA 486 pt on 393 × 852), so the redesign reads as the Foundation, not an interpretation of it.

## 10. Anti-Patterns to Avoid

* A progress bar or percentage for the Journey, or showing all 30 nodes in the card.
* Colour-only node states; a locked node that is just greyed lime.
* The future-scope items (the settings square, the level-info card, the streak and stars chips, the gesture hint).
* Locale-blind uppercasing (`YOLCULUK`, `KAYITLI VERİLER` are authored).
* An empty card or a spinner during load — use the splash frame.
* A white or theme-dependent native launch (Android `?android:colorBackground`).
* Showing the exception text to players, or a red error treatment.
* An idle pulse or breathing animation on Home.
* A second button on Home (a "start over" beside "Devam et") — it would discard a session in progress (§18.3 (2)).

## 11. Frontend Handoff

**Must not break**
* The composition and the anchors of §6 at 1.0× (±2 pt): wordmark, card top and height 300·s, track block, CTA top, caption.
* **The window rule** and the node states exactly as in §6 / §7 (`window-d3.txt` is the expected-value table for a component test).
* The N1 CONTINUE rule: CTA = "Devam et" whenever a Journey session is in progress, including at 30 / 30; "Tekrar oyna" only when the model is terminal (`continueTarget == null`).
* Text scale: container text (wordmark, label, headline, node numerals, error headline and label) through `loopCappedTextScaler`. Free text (CTA label, caption, error body, error pill) follows the OS scale, wrapping between words only. Home does not scroll at AX5 on 390–440 widths. The error column may scroll above the cap, with `ScrollBand` at the top.
* No-break joins in the caption: `Seviye N` and `· sürüyor`.
* No raw exception outside `kDebugMode`, and the exception is logged in every build.
* The native launch: iOS `LaunchScreen.storyboard` (background `#070C25` + the launch image, aspect fill); Android `drawable/` and `drawable-v21/launch_background.xml` (solid `#070C25` + the image, fill); `LaunchTheme` **and** `NormalTheme` in `values/` and `values-night/` point at that drawable — no `?android:colorBackground`.
* The `MaterialApp` scaffold background is `#070C25`; `title: 'Looplet'`.

**Flexible**
* Entrance durations ±40 ms and the rise 8–12·s; the splash wordmark fade 120–200 ms.
* The segment curve may be any smooth monotone curve through the node centres (the renders use a symmetric cubic with 0.45 handles).
* The launch image may be regenerated from `LoopBackdrop` at build time instead of the provided PNG, if the result is the same picture.
* The debug details box's exact styling.

**Do not cheapen**
* The halo on the current and finish nodes, and the dashed locked outline at ≥ 3 : 1.
* The lead-in line (the only sign of the levels behind the window).
* The CTA glow on Home (the one place it is allowed).
* Reassurance copy on the error screen ("İlerlemen güvende…"), not a technical message.

**Implementation map**

| Shipped | D3 |
| --- | --- |
| `home_screen.dart` `PlayStage` / `PlayTheme.stage1` | `LoopBackdrop` |
| `_Wordmark` (uppercase `LOOPLET`) | `LoopletWordmark(fontSize: 25·s)` at (25, 58)·s |
| `_JourneyRing` (30-tick ring, count at its centre, one-shot terminal bloom, breathing pulse) | removed → `GlassCard` + label + headline + **`LoopTrack`** (new, in `app/lib/design`) |
| `_ContinueCta` (amber) | `LimePill(glow: true)` + `LoopIconView(arrowRight)` |
| `JourneyStrings` (`DEVAM ET`, `TEKRAR OYNA`, `SEVİYE`, `TAMAMLANDI`) | new values — §12 copy table |
| `app_router.dart` `_SplashScreen` (`Text('LOOPLET')`) | `LoopBackdrop` + `LoopletWordmark` at the Home position, fading in |
| `app_router.dart` `StoreErrorScreen` (English `FilledButton`, raw message) | the §6 card + `LimePill`; strings table; `debugPrint` the message; the details box only under `kDebugMode` |
| `main.dart` `MaterialApp` (`PlayTheme` ground, `title: 'LOOPLET'`) | ground `#070C25`, `title: 'Looplet'` |
| iOS / Android launch assets (white / theme) | the launch image over `#070C25` (§11 Must) |

**Design-layer additions (§18.3 (3); on the §19.8 (2) / §20.7 (6) terms):** `LoopTrack`; `LoopNode` gains the `open`, `locked` and `finish` states (the existing `done` and `current` states are unchanged). Each needs component tests; there is no token value change and no new dependency. The outline alphas `.62` are local constants of the component, not new tokens.

### 11.1 D3 acceptance list (for Frontend and QA)

1. **Anchors (1.0×, 393 × 852):** wordmark (25, 58)·s; card top `115·s + 0.1·e` (132.8 pt), height 300·s; CTA top card bottom + 22·s (486.3 pt); caption 17·s under the CTA — ±2 pt.
2. **Window:** for every state of `window-d3.txt` the rendered levels and node states equal the table (component test over the rule, incl. a replay at 1, 2, 29, 30 and a frontier at 1–5, 26–30).
3. **Node states** are distinguishable in greyscale (fill / outline type / size + halo); the locked outline and the open outline are ≥ 3 : 1 on the card.
4. **No overlap:** no node overlaps another node or a halo; nothing is drawn outside the card (all windows).
5. **Lead-in** present iff the window starts after level 1; **tail** only when more levels follow and there is room.
6. **Copy per state** exactly as §12 (headline, label, CTA, caption).
7. **N1:** 30 / 30 + a Journey session in progress → "Devam et" + "Seviye N · sürüyor"; the label stays `30 / 30`; tapping resumes that session at its saved state. 30 / 30 without a session → "Tekrar oyna" → level 1. Warm (Home mounted) and cold (relaunch) equal.
8. **Replay before 30 / 30:** the replayed level is current with done levels on both sides; the headline is "Yarım kalan döngüne dön."
9. **Loading:** before the model loads, the screen equals the splash frame — no empty card, no spinner.
10. **Entrance:** content at rest ≤ 340 ms after the model arrives (±40 ms); reduced motion — no animation; no idle motion afterwards.
11. **Text scale:** at 1.3× no scroll, nothing clipped; at AX5 container text capped, free text scaled, words never broken, the caption breaks only before "·", Home does not scroll on 390 × 844 – 440 × 956.
12. **CTA:** ≥ 44 pt tall at every scale; pressed = scale 0.98; a visible focus ring; `Semantics` per §12.
13. **Store error:** Turkish copy per §12; the raw exception is not visible in a profile or release build; it is logged; Retry re-runs the bootstrap; at AX5 the pill is reachable by scrolling and the text never passes under the status bar.
14. **Launch:** no white or light frame from the native launch to Home on iOS (and Android light and dark, if run); no visible jump at the splash hand-off (a cold-start recording).
15. **Chrome:** no back affordance on Home or the store-error screen; no future-scope item on Home.
16. **No Material icon, `PlayTheme` or amber** on Home, the splash or the store-error screen.

## 12. Copy, `Semantics` and the Provisional Self-Review

### Copy (interim — PO / localization, F10-UI-LOCALIZATION; `JourneyStrings` + a shell strings table)

| Where | TR | EN (dev) |
| --- | --- | --- |
| Label | `YOLCULUK · N / 30` | `JOURNEY · N / 30` |
| Headline · new (0 / 30, nothing started) | `İlk⏎döngüyü çöz.` (lime: döngüyü) | `Solve your⏎first loop.` |
| Headline · next | `Sıradaki⏎döngüyü çöz.` (lime: döngüyü) | `Solve the⏎next loop.` |
| Headline · replay in progress (before 30 / 30) | `Yarım kalan⏎döngüne dön.` (lime: döngüne) | `Back to your⏎open loop.` |
| Headline · terminal (with or without a session) | `Tüm döngüler⏎tamam.` (lime: döngüler) | `Every loop⏎complete.` |
| CTA | `Devam et`; terminal without a session `Tekrar oyna` | `Continue` / `Play again` |
| Caption | `Seviye N`, `Seviye N · sürüyor` (NBSP joins) | `Level N`, `Level N · in progress` |
| Error label / headline / body / pill | `KAYITLI VERİLER` / `Kayıtlı verilerin⏎açılamadı.` / `İlerlemen güvende; hiçbir şey silinmedi.` / `Tekrar dene` | `SAVED DATA` / `Couldn't open⏎your saved data.` / `Your progress is safe; nothing was deleted.` / `Try again` |
| Debug box label | `DEBUG · YALNIZ GELİŞTİRME DERLEMESİ` (debug only) | `DEBUG · DEVELOPMENT BUILD ONLY` |

Optional alternative for PO: the CTA "Başla" for the brand-new state (not rendered; "Devam et" is the contract default).

### `Semantics`

* **Progress:** one node — "N / 30 seviye tamamlandı — Seviye M" (`progressSemantics`). The track, nodes and swirl arcs are excluded; the headline is read as text.
* **CTA:** a button — "Devam et, Seviye M" / "Devam et, Seviye M, sürüyor" / "Tekrar oyna, Seviye 1".
* **Wordmark:** "Looplet" (existing).
* **Error:** the headline, then the body, then the button "Tekrar dene". The debug box is excluded from semantics.

### Provisional self-review (advisory; the gate score is QA's)

| Dimension | Score | Reason |
| --- | --- | --- |
| Experience Fit | 10 | one-tap return with the Journey in view; the N1 state never discards progress |
| Visual Hierarchy | 10 | label → headline → current node → one lime action; the caption closes |
| Layout, Rhythm & Responsiveness | 9 | `S-06b` anchors; a flow column that absorbs AX5 without scroll; the lower third intentionally empty (the Foundation's rhythm), which some may read as sparse on the Pro Max |
| Typography & Content Craft | 9 | authored headlines per situation; NBSP joins; copy is interim |
| Color, Surface & Asset System | 10 | tokens only; lime / periwinkle roles held; the error screen without red |
| Interaction, State & Feedback | 9 | every state rendered; the press follows the shipped component (no brightness step) |
| Motion & Sensory Quality | 9 | a short, calm entrance and a continuous cold start; no Home motion beyond it (by the Foundation) |
| Originality & Product Identity | 10 | the climbing loop track and the crowned finish are specific to Looplet |
| Accessibility & Inclusive Quality | 9 | ≥ 3 : 1 non-text, greyscale-safe nodes, AX5 without clipping; VoiceOver untested (design artefact) |
| Implementation Fidelity & Polish | 9 | geometry and states are specified as data (`window-d3.txt`); two small component extensions |
| **Total** | **94** | provisional — not an acceptance input |

### 12a. Screen / State / Viewport Matrix

| Screen | State | Viewport | Source artefact | Critical assertions |
| --- | --- | --- | --- | --- |
| Home | new 0 / 30; level 1 started | 393×852 | `D3-01`, `D3-01b` | current at the foot; 2–5 locked (dashed); §11.1 (2), (6) |
| Home | mid 4 / 30; in progress 4 / 30 | 393×852; 390×844; 440×956 | `D3-02`, `D3-03`, `D3-v-16e-home-in-progress`, `D3-v-promax-home-in-progress` | `S-06b` anchors; §11.1 (1) |
| Home | window 12 / 30, 25 / 30 | 393×852 | `D3-04a`, `D3-04b` | lead-in; window table |
| Home | replay before terminal | 393×852 | `D3-05` | current in the middle; headline |
| Home | terminal 30 / 30 | 393×852 | `D3-06` | finish node; "Tekrar oyna" |
| Home | terminal + replay (N1) | 393×852; 390×844; 440×956 | `D3-07`, `D3-v-16e-…`, `D3-v-promax-home-terminal-with-replay` | §11.1 (7) |
| Home | loading | 393×852 | `D3-08` (= `D3-22`) | §11.1 (9) |
| Home | pressed; focus | 393×852 | `D3-09`, `D3-11` | §11.1 (12) |
| Home | 1.3× | 393×852; 390×844; 440×956 | `D3-10`, `D3-v-*-home-text-cap-1_3` | no scroll, no clip |
| Home | AX5 | 393×852; 390×844 | `D3-10b`, `D3-10c`, `D3-v-16e-home-ax5` | §11.1 (11) |
| Home | windowing B (alternative) | 393×852 | `D3-B-04of30-band`, `D3-B-12of30-band`, `D3-B-25of30-band` | comparison only |
| Store error | normal; AX5 top; AX5 end; debug | 393×852; 390×844; 440×956 | `D3-20`, `D3-20b`, `D3-20d`, `D3-20c`, `D3-v-*-store-error` | §11.1 (13) |
| Shell | native launch iOS / Android; splash | 393×852; 412×915 | `D3-21`, `D3-21b`, `D3-22`; asset `D3-asset-launch-backdrop` (1290×2796) | §11.1 (14) |
| Home | entrance t 0 / 80 / 160 / 240 / 340; reduced | 393×852 | `D3-M-entrance-*`, `src/D3-motion-prototype.html` | §11.1 (10) |

### 12b. Visual Evidence Manifest

**Provenance for every D3 record:** Source Revision HEAD `9a36147` + working tree (`design/src/gen-d3.mjs`, derived from F00 `gen-s.mjs` and F03 `gen-d1.mjs`). Method: HTML/CSS → PNG with headless Chrome at devicePixelRatio 2 (`src/render-d3.sh D3- jobs-d3.txt`; the launch asset at 3); the entrance stills are frames of the prototype frozen with `?t=`. `node gen-d3.mjs` regenerates every page byte for byte. Captured by the UI Designer, 2026-09-29. Generated design artefacts, not runtime captures; Android is rendered as a frame, not run.

| Evidence ID | Kind | Screen / State | Viewport / Device | Artifact | Source Revision | Captured By | Captured At | Result / Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| DR-F00-HOME | direction-render | Exploration Gate (F00): Home in Directions A / B / C (+ C shipped scope) | 393×852 | features/f00-design-foundation/design/A-06-home-in-progress.png, B-06-home-in-progress.png, C-06-home-in-progress.png, C-06b-home-shipped-scope.png | F00 records (design-foundation.md §13 / §17.10) | UI Designer | 2026-09-21 | pointer; selection F00.FOUNDATION-SELECTION (Direction C) |
| DR-D3-A | direction-render | windowing A "sliding five" at 4 / 12 / 25 of 30 | 393×852 | design/D3-03-home-in-progress-4of30.png, D3-04a-home-window-12of30.png, D3-04b-home-window-25of30.png | 9a36147 + working tree | UI Designer | 2026-09-29 | recommended; Pending Selection (Tech Lead) |
| DR-D3-B | direction-render | windowing B "band window" at 4 / 12 / 25 of 30 | 393×852 | design/D3-B-04of30-band.png, D3-B-12of30-band.png, D3-B-25of30-band.png | 9a36147 + working tree | UI Designer | 2026-09-29 | alternative |
| SS-06b | selected-source | Home · today (shipped scope) | 393×852 | features/f00-design-foundation/design/S-06b-home-today.png | F00 | UI Designer | 2026-09-21 | anchors kept (133 / 486 pt) |
| D3-HOME | selected-source | Home · new, level 1 started, mid, in progress, replay, terminal, terminal + replay (N1), loading, pressed, focus | 393×852 | design/D3-01 … D3-09, D3-11 (*.png) | 9a36147 + working tree | UI Designer | 2026-09-29 | audit renders 19–23; window table `src/window-d3.txt` |
| D3-A11Y | accessibility | Home 1.3× / AX5; store error AX5 (top, end) | 393×852, 390×844, 440×956 | design/D3-10-home-text-cap-1_3.png, D3-10b-home-ax5.png, D3-10c-home-ax5-terminal-replay.png, D3-v-16e-home-ax5.png, D3-v-*-home-text-cap-1_3.png, D3-20b-store-error-ax5.png, D3-20d-store-error-ax5-scrolled-end.png; `src/contrast-d3.txt` | 9a36147 + working tree | UI Designer | 2026-09-29 | audit render 24; Home needs no scroll at AX5 |
| D3-SHELL | selected-source | store error (normal, debug); native launch iOS / Android; splash; launch asset | 393×852, 412×915, 1290×2796 px | design/D3-20-store-error.png, D3-20c-store-error-debug-build.png, D3-21-launch-ios.png, D3-21b-launch-android.png, D3-22-splash.png, D3-asset-launch-backdrop.png | 9a36147 + working tree | UI Designer | 2026-09-29 | audit renders 25–26 |
| D3-V | selected-source | device variants | 390×844, 440×956 | design/D3-v-16e-*.png, D3-v-promax-*.png | 9a36147 + working tree | UI Designer | 2026-09-29 | — |
| MP-D3 | motion-prototype | Home entrance (`?t=`, `?rm=1`) + stills t 0 / 80 / 160 / 240 / 340 and reduced | 393×852 | design/src/D3-motion-prototype.html; design/D3-M-entrance-*.png | 9a36147 + working tree | UI Designer | 2026-09-29 | HTML/CSS animation (Blink); the Flutter cold-start recording is Frontend's parity evidence |
| D3-SHEETS | parity-comparison | contact sheets (review aid) | sheet | design/D3-sheet-*.png | 9a36147 + working tree | UI Designer | 2026-09-29 | not a gate artefact |
| AUD-D3-BASE | runtime-screenshot | shipped Home / shell baseline | 393×852 iPhone 16 | features/f00-design-foundation/design/audit/ (cur-home-*.png, cur-a11y-ax5-home-terminal.png, cur-a11y-xxxl-home-terminal.png, cur-shell-*.png, pair-01, pair-02) | 615e94c | UI Designer | 2026-09-27 | the "before" for Frontend parity |

## 13. Assumptions

* The Journey model arrives within a few frames of the bootstrap, so "the loading state = the splash frame" is not a visible wait. If it ever takes longer, the splash frame simply stays — no spinner is added without a Tech Lead ruling.
* The launch image is aspect-filled. Modern iPhones share a ≈ 2.17 aspect (16e 2.164, 16 2.168, Pro Max 2.173), so the crop is < 1 %. On Android aspects vary, and the glow position may shift slightly (not measurable here).
* The error body text is new interim copy (the shipped one was English). "İlerlemen güvende" restates F08 AC9 (data intact); it promises nothing more.
* The finish node reuses the done lime with a halo; it is not a new token.
* The node states `open` and `locked` rarely appear together: `open` only exists in a replay window that reaches the frontier (e.g. replaying 11 with 12 done and 13 the frontier).

## 14. Needs Tech Lead Clarification

1. **Windowing A vs B** — select A (recommended) or B (§2). Non-blocking for the checkpoint if A is adopted as the handoff design within §18.3 (3).
2. **`LoopNode` state extension** (`open`, `locked`, `finish`) — confirm it is inside the §18.3 (3) allowance (it is the loop track's own node). There are no token changes.
3. **Headlines per situation** — three new interim headlines ("İlk…", "Yarım kalan…", "Tüm döngüler tamam.") beyond the contract's reference copy. The contract leaves the terminal copy to the designer; the new-player and replay headlines are proposals. With a veto, "Sıradaki döngüyü çöz." is used for those states.
4. **The breathing pulse is dropped** on the in-progress node (shipped F05-UI behaviour) — confirm; the Foundation specifies no Home motion.
5. **The store-error screen has one action only** (no "leave the app" link; iOS has no programmatic exit) — confirm.

---

## Local Orchestration Update (UI Designer)

* F05-UI-D3 → Done; F05.D3-HANDOFF → PASS (provenance above); Delivery Review → Pending.
* Visual Scope is `new-surface`, so the UI Designer → implementation transition is a mandatory Tech Lead visual-gate checkpoint (role-execution-contract §5): Current Owner = Next Role = Tech Lead. F05-FE-D3 stays Queued until the checkpoint opens it.

**Status Suggestion (non-authoritative):** Needs Tech Lead — visual-gate checkpoint (windowing selection, §14 items).

## 15. Sonraki Komut

```text
Run Tech Lead
```
