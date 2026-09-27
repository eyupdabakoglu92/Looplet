# F00 — Phase C Conformance Audit (shipped surfaces vs the Selected Foundation)

> Task `F00-UI-CONFORMANCE-AUDIT` (UI Designer), 2026-09-27.
>
> * **Contract:** `architecture.md` §8.
> * **Authority:** `project-authority/design-foundation.md` (Selected — Direction C "Loop Glass", user decision set §18) and `ui-design.md` (the design-system handoff, with the §11 motion spec). Tech Lead rulings of 2026-09-21: the Result's back chevron, the one-glow rule, count-aware copy to PO / localization, the 44 pt targets and `HAMLE` ≥ 11 pt in Phase D.
> * **Targets:** `design/S-*.png`. **Evidence:** `design/audit/`.
>
> **Purpose:** measure how far each shipped surface is from the Foundation, so the Tech Lead can set Visual Scope, the Phase D order and the contract amendments. No code or `app/` change, no new direction, no gate change.
>
> **Tech Lead reconciliation, 2026-09-27: Accepted.**
> * **Checks:** the 49 evidence files; the captures at 1179 × 2556, crops excepted; the commit touching F00 only; and the code, PRD and contract claims.
> * **Correction:** Android's launch background is not always white — see A-4 and §2.
> * **Outcome:** the decisions are in the F00 `orchestration.md` Last Decision and `workflow-follow-ups.md` (Design Adoption Route). The D1 contract is F03 `architecture.md` §19.

---

## 0. How the evidence was produced

* **Build:** `app/lib/main.dart`, debug build, HEAD `615e94c`. The working tree was clean apart from this audit's untracked files. Built with `flutter build ios --simulator --debug -t lib/main.dart` and installed fresh.
* **Device:** iOS Simulator 18.6, iPhone 16 (`D0011CE7-…`), 393 × 852 pt; captures are 1179 × 2556 px. This is the primary baseline of `platform.md` §14. OS text size was `large` and Reduce Motion was off unless a record says otherwise.
* **How each state was reached:**
  * **Played by hand:** Journey levels 1–2, covering first clear 3★ and 2★, then 1★, new best and matched best. Every CTA was used: `SONRAKİ` → next level, `Yeniden` → replay in place, `Kapat` → Home.
  * **Seeded:** with the app terminated, `journey_progress` was set and the `active_session` kv row removed:
    * 1–3 complete → the level 4 tutorial;
    * 1–25 complete → level 26 with locked + frozen tiles;
    * 1–30 complete → the terminal state.
  * **Debug smoke level `L06`:** a frozen-tile thaw that happens in the same move as the win, and the "Next not wired" result.
  * **Bootstrap error:** `looplet.sqlite` was replaced by a non-SQLite file, then restored from a backup and re-verified.
  * **Load error:** `settings.language` was set to `de`, a language with no Journey manifest, then restored to `tr`.
  * **Reduce Motion:** turned on through the simulator's `com.apple.Accessibility ReduceMotionEnabled`, then restored to 0.
  * **OS text size:** set with `xcrun simctl ui … content_size` to two sizes, then restored to `large`:
    * `extra-extra-extra-large` (≈ 1.35×);
    * `accessibility-extra-extra-extra-large` (AX5, ≈ 3.12×).
  * The app left on the simulator holds the seeded test progress (30/30).
* **Pairs** (`design/audit/pair-NN-*.jpg`): the runtime capture on the left, its `S-*` target on the right, as a 2× JPEG composite. Pairs exist only where a target render exists; every other state is marked **no target render**.
* **Measurements:** colours are 5 × 5 px sRGB averages taken from the captures. Positions are read from the captures (± 2 pt). Target positions are computed from `ui-design.md` §6 (s = 1.0978, e = 64.9 pt at 393 × 852).
* **Limits:**
  * No Android capture (`ANDROID-CI-EVIDENCE`), no real device, and no 16e or Pro Max capture.
  * Motion was observed as frame bursts about 150 ms apart, not as video, so motion gaps are qualitative unless a frame shows an unambiguous state.
  * VoiceOver was not exercised; semantics are read from code where cited.

---

## 1. Summary for the Tech Lead

1. **No shipped surface uses the Foundation.**
   * Every screen runs on `PlayTheme`: a near-black stage, amber resolution and cyan drag energy.
   * All text is in the system font. No `fontFamily` is set anywhere, so iOS renders SF Pro.
   * Six Material icons remain: `chevron_left_rounded`, `undo_rounded`, `refresh_rounded`, `push_pin`, `unfold_more_rounded` and `error_outline_rounded`.
   * The wordmark is still the uppercase `LOOPLET`.
   * Only `lib/main_gallery.dart` imports `app/lib/design`; no shipped screen does (re-checked at `615e94c`).
2. **Distance per surface:**
   * **Play — medium.** The board geometry is already close: tile ≈ 58.3 vs 57.1 pt, board card ≈ 344 vs 339 pt wide. The header/HUD layout and every colour, type, icon and state treatment change.
   * **Won moment + Result — largest.** A new composition, a specified transition and new copy; the `Kapat` button goes.
   * **Home — large.** A new composition (glass card + loop track), and three of its four states have no render.
   * **Shell — small,** but it carries two player-visible defects.
3. **Shipped defects found during the audit** (they exist with or without adoption):
   * **A-1 — tutorial hint overlap.** The column-tutorial hint text is drawn over the undo pill and the restart button (`cur-tutorial-hint-overlap-crop.png`).
   * **A-2 — AX5 text size.** At the largest OS text size:
     * tile glyphs, target letters and CTA labels are clipped;
     * the wordmark breaks as "LOOPL / ET", and `OPTİMAL` breaks mid-word;
     * the result panel grows to ≈ 84 % of the height and hides the answer row.

     At ≈ 1.35× everything holds, so the contracted F03 ui-design §16.5 rule (text scale 1.0 and 1.3×) is met. The Foundation's own rule — no clipping up to accessibility sizes — is not.
   * **A-3 — raw bootstrap error.** The bootstrap-error screen is English and prints the raw exception to the player (`SqliteException(26) … PRAGMA user_version;`).
   * **A-4 — white launch screen.** The native launch screen is white on iOS, so every cold start flashes white before the dark app. *Tech Lead correction, 2026-09-27:* on Android it is white only in light mode. `drawable-v21/launch_background.xml` uses the launch theme's `?android:colorBackground` — `Theme.Light` by day, `Theme.Black` under `values-night` — and `drawable/` (API < 21) is plain white.
   * **A-5 — frozen tile.** It carries only colour + border: no texture, no corner crystal marks and no thaw animation. F03 ui-design §7 asks for a "texture + border-marks cue, not colour-only" and a 180 ms thaw cross-fade.
   * **A-6 — tutorial ghost.** It keeps animating over the column the player is actually dragging.
4. **Proposed slices** (rationale in §8):
   * **D1 — Play:** F03 play + the F05 tutorial overlay + the F03 load error, `existing-parity`.
   * **D2 — Won moment + full-screen Result:** F03 §16 + F04, `motion-critical`.
   * **D3 — Home + app shell:** F05 home + the F08 bootstrap error + the native launch screens, `new-surface`.
5. **Contract impacts** (§9): every `DESIGN-ADOPTION-CONTRACT-AMENDMENTS` item is confirmed, and nine are added. The most important:
   * F05 PRD AC1 and F05 architecture §8 name `Close`, so the no-Close decision reaches a PRD sentence.
   * F03 §16.5's docked-row visibility rule has no meaning for a full-screen result.
   * The OS text-scale ceiling differs between F03 (1.3×) and the Foundation (accessibility sizes).
6. **Missing renders:** 26 states must be rendered before their slice is implemented (§10), mostly Home states, result variants and HUD / drag sub-states.

---

## 2. App shell — native launch, Flutter splash, bootstrap error (F08 / app shell)

| State | Current capture | Target | Pair |
| --- | --- | --- | --- |
| Native launch screen | `audit/cur-shell-splash.png` — full white. iOS `LaunchScreen.storyboard` background is `#FFFFFF`. Android (Tech Lead correction): `drawable/` is `@android:color/white`, while `drawable-v21/` uses the theme's `colorBackground` — light by day, black in night mode. | Foundation ground (`ui-design.md` §10) — not rendered | no target render |
| Flutter splash (`_SplashScreen`) | Not capturable: it lasts less than one capture interval. From code: `Scaffold(body: Center(child: Text('LOOPLET')))` on the default theme. | not rendered | no target render |
| Bootstrap error (`StoreErrorScreen`, F08 AC9) | `audit/cur-shell-bootstrap-error.png` | Pattern only, `ui-design.md` §8: ground + glass card + Space Grotesk headline + one primary pill | no target render |

**Gaps by category**

* **Layout:**
  * A text column centred on a bare ground.
  * A full-width Material `FilledButton`.
  * The raw error string is printed below the button.
  * No card.
* **Typography:** system font — title 20 / 600, body default, message 12 pt. Target: a Space Grotesk headline and Manrope body.
* **Colour / surface:**
  * The native launch is `#FFFFFF`, shown before a near-black app (defect A-4).
  * The error screen has a near-black ground and an amber Material-primary button.
  * Target: the navy ground `#0A1030 → #050A1E` and a lime pill `#E2FB78 → #D3F04F`.
* **Iconography:** none.
* **Components:** `FilledButton` → `LimePill`; the body goes into a `GlassCard` over `LoopBackdrop`. All three exist in `app/lib/design`.
* **Copy / casing:**
  * The copy is English in a Turkish-only app: "Couldn’t open your saved data", "Your progress is safe. Please try again." and "Retry".
  * The raw exception is shown to the player (defect A-3).
  * The splash text is uppercase `LOOPLET`, where the target is `Looplet`.
* **Motion:** none required. The native → Flutter hand-off must be colour-continuous: the launch background should be the ground colour.
* **Accessibility:** the retry target is ≥ 44 pt. The exception text is noise for a screen reader.

**Scope and contract**

* **Scope proposal:** `existing-parity`. The Foundation defines the pattern, and one render is missing. It rides with D3, because launch, splash and home form one first impression.
* **Contract impacts:**
  * The F08 `StoreErrorScreen` is declared "plain by design — no design handoff" (`app_router.dart`). Adoption needs an F08 amendment: the Foundation pattern, Turkish copy through the strings table, and the raw message logged rather than shown (C-6).
  * The native launch assets have no owning feature (C-7): the iOS storyboard, and the Android drawable plus `styles.xml`.
* **Future-scope exclusions:** none.
* **Missing renders:**
  * the bootstrap error;
  * the native launch / splash: the ground, optionally with the `Looplet` wordmark. The final drawn wordmark asset is itself a Phase D item (design-foundation §18, consequence 4).

---

## 3. Journey home (F05) — new, mid, in progress, terminal

| State | Current capture | Target | Pair |
| --- | --- | --- | --- |
| New player (0/30) | `cur-home-new.png` — `SEVİYE 0 / 30`, one amber node dot, `DEVAM ET`, "Seviye 1" | None exact; S-06b shows 4/30 in progress | no target render |
| Mid, no replay in progress (1/30) | `cur-home-mid.png` — "Seviye 2" | S-06b, the closest composition | `pair-02-home-mid.jpg` |
| In progress (`· sürüyor`) | `cur-home-in-progress.png` — 0/30, "Seviye 1 · sürüyor", node with a cyan ring. Also `cur-home-late-in-progress.png` — 25/30, "Seviye 26 · sürüyor" | S-06b — "Seviye 5 · sürüyor" | `pair-01-home-in-progress.jpg` |
| Terminal (30/30) | `cur-home-terminal.png` — `TAMAMLANDI 30 / 30`, all ticks amber, `TEKRAR OYNA`, "Seviye 1" | none | no target render |
| Debug chip row (`kDebugMode` only) | Visible in every debug capture; its AX5 overflow is debug-only | Not a player surface | — |

**Gaps by category**

* **Layout:**
  * **Shipped:** a centred stack:
    * a letter-spaced wordmark at ≈ 185 pt;
    * a ≈ 232 pt 30-tick ring with the count in its centre (ring centre ≈ 353 pt);
    * a 267 × 53 pt amber CTA at ≈ 494 pt;
    * the subtitle at ≈ 566 pt.
  * **Target** (`ui-design.md` §6, S-06b):
    * the `Looplet` wordmark top-left, at ≈ (27, 64) pt;
    * a 338 × 329 pt glass card at ≈ 133 pt, holding a `YOLCULUK · N / 30` label, a two-line headline and the loop track;
    * a full-width 339 × 69 pt CTA at ≈ 486 pt, below the card;
    * the subtitle under the CTA.
* **Typography:**
  * **Shipped:** the system font, a letter-spaced uppercase wordmark, and the count numeral as the loudest element.
  * **Target:**
    * `Looplet` in Space Grotesk 500 — `Loop` in `#F4F6FF` and `let` in lime `#DDFA6B`;
    * a 28 / 1.16 headline with its emphasised word in lime;
    * caps labels at 11–11.5 pt, +0.2 em;
    * a Manrope 16 CTA.
* **Colour / surface:**

  | Element | Shipped | Target |
  | --- | --- | --- |
  | Ground | flat near-black, `#0D0D18 → #11111D` | navy gradient + top-right light + teal spill |
  | Progress | ticks in amber / grey | lime → periwinkle track line; done nodes lime |
  | CTA | amber `#FFBF44 → #FFB327`, amber glow | lime `#E2FB78 → #D3F04F` with the lime glow (Home keeps its CTA glow) |
  | In-progress node | amber dot + cyan ring | periwinkle current node + 76 pt halo |
* **Iconography:** none today. The target CTA carries a trailing `LoopIcon.arrowRight`.
* **Components:**
  * The ring is a custom painter today. The target uses `GlassCard`, `LoopNode`, `LimePill(glow: true)`, `LoopletWordmark` and `LoopBackdrop`, which all exist in `app/lib/design`.
  * **Not in the layer: the loop track itself** — the curve, the connecting line, the swirl arcs and the rule for showing 30 levels. It is a new component.
* **Copy / casing:**
  * `LOOPLET` → `Looplet` (user decision 5).
  * `DEVAM ET` → "Devam et", sentence case with an arrow.
  * The `SEVİYE N / 30` block → the `YOLCULUK · N / 30` label and the headline "Sıradaki döngüyü çöz.". This is reference copy, proposed per decision 6.
  * `TAMAMLANDI` / `TEKRAR OYNA` have no Foundation copy yet.
* **Motion:** the shipped in-progress node pulses (F05 ui-design). The Foundation specifies no Home motion; the node advance after a win can stay static.
* **Accessibility:**
  * **At AX5** (`cur-a11y-ax5-home-terminal.png`):
    * the wordmark wraps as "LOOPL / ET";
    * `TAMAMLANDI` breaks mid-word into the ring;
    * the CTA label is cut to "TEKRAR".
  * **At ≈ 1.35×:** everything fits (`cur-a11y-xxxl-home-terminal.png`).
  * The layer's `GlassCard` and `LoopNode` already pass at AX5 (evidence records F00.DS-A11Y-REWORK2 and F00.VISUAL-93-GAP-CHECK).

**Scope and contract**

* **Scope proposal:** `new-surface`. It is a new composition; three of its four states are unrendered; it needs a new component (the loop track), a copy decision and the N1 behaviour decision.
* **Contract impacts:**
  * F05 `architecture.md` §10 names the "LOOPLET wordmark" and a ring-style progress indicator. Amend it to `Looplet` + the loop track. AC10 (a progress indicator such as "12 / 30") is still met by `YOLCULUK · N / 30`.
  * The §10 terminal variant ("CONTINUE hidden or repurposed — UI Designer's call") needs a render and copy.
  * N1, the terminal precedence of §8, needs a decision; the recommendation is in C-1.
* **Future-scope exclusions — must not be built** (they appear in S-06 only; build S-06b):
  * the settings square top-right (F10);
  * the level-info card, "Seviye 5 / Yeni mekanik · sütun kaydırma" with a target preview (F05 level metadata);
  * the "4 günlük seri" chip (F07);
  * the "12 yıldız" chip (no aggregate-stars decision).
* **Missing renders:**
  * new player, 0/30: what the track shows before the first win;
  * mid with no replay: the subtitle without `· sürüyor`;
  * the 30-level windowing rule — S-06b shows nodes 1–5 only; render e.g. 12/30 and 25/30;
  * terminal 30/30, with and without a replay in progress (C-1);
  * an AX5 frame.

---

## 4. Play (F03) — idle, drag, special tiles, HUD, back, target rail, load error

| State | Current capture | Target | Pair |
| --- | --- | --- | --- |
| Idle (L1, ASLAN) | `cur-play-idle.png` | S-01b | `pair-03-play-idle.jpg` |
| Row lifted mid-drag (AC9) | `cur-play-row-lifted.png` | S-02 | `pair-04-play-row-lifted.jpg` |
| Column drag (L4) | `cur-play-column-drag.png` | None (S-02 shows a row) | no target render |
| Locked + frozen (L26, TARİH) | `cur-play-locked-frozen.png`; crop `cur-play-locked-frozen-crop.png` | S-03 (same level content) | `pair-05-play-locked-frozen.jpg` |
| Frozen thaw | `cur-won-thaw-coincident.png` — debug L06, where the thawing move is also the winning move | None; `ui-design.md` §8 says "thaw = becomes a normal tile" | no target render |
| HUD — undo enabled (1 move, quota 3) | `cur-play-hud-after-move.png` | S-03 (undo enabled, 3 lime dots) | `pair-06-play-hud.jpg` |
| HUD — undo disabled after one undo (0 moves, 2 left) | `cur-play-hud-after-undo.png` | None; every render shows 3 dots | no target render |
| HUD — undo disabled at 0 moves (3 left) | inside `cur-play-idle.png` | S-01b (dimmed undo) | inside `pair-03` |
| Back | the chevron in every Play capture | S-01b, "‹ SEVİYE 05" | inside `pair-03` |
| Target rail | in every Play capture | S-01b / S-03 | inside `pair-03`, `pair-05` |
| Load error | `cur-play-load-error.png` | Pattern only (`ui-design.md` §8) | no target render |

**Gaps by category**

* **Layout:**

  | Element | Shipped | Target |
  | --- | --- | --- |
  | Back | a bare chevron at ≈ (21, 81) pt | "‹ SEVİYE 0N" at ≈ (27, 105) pt |
  | Moves counter | bottom-left, ≈ 703–740 pt | a 66 × 69 pt `HAMLE` card top-right, at ≈ (300, 82) pt |
  | Target rail | `HEDEF` at ≈ 116 pt; 31.5 pt tiles at ≈ 132 pt; a divider at ≈ 182 pt | `HEDEF DÖNGÜ` at ≈ 208 pt; 39.5 × 46 pt tiles at ≈ 236 pt; no divider |
  | Board card | top ≈ 269 pt, ≈ 344 pt wide | top ≈ 307 pt, 339 pt wide (86 %) |
  | Tiles | ≈ 58.3 pt | 57.1 pt |
  | Undo pill | top ≈ 764 pt | 108 × 55 pt, top ≈ 715 pt |
  | Restart | a ≈ 47 pt ring, beside a vertical divider | a 44 pt glass square |
* **Typography:**
  * **Shipped:** the system font for tile glyphs (font size 46 % of the tile, `PlayTheme.tileLetter`), captions and numerals.
  * **Target:** Space Grotesk 500 at 38 % of the tile, with `tnum` numerals; Manrope captions; the `HAMLE` caption ≥ 11 pt (ruling 2026-09-21).
* **Colour / surface:**

  | Element | Shipped | Target |
  | --- | --- | --- |
  | Ground | `#11111F` | navy gradient |
  | Board card | `#0D0E1B`, no light line | darker glass `rgba(22,30,64,.86) → rgba(9,14,36,.88)` + a 144 × 2 pt periwinkle top light line |
  | Tile face | `#F2ECE2 → #E9E1D2`, radius 19 % (`tileRadiusFraction`) | `#FFFCF7 → #F0E9DC` (close), radius 33 % |
  | Rail tile | `#181824`, outlined, grey glyph | indigo `#2B2B58 → #242349`, 1 px `rgba(150,160,235,.32)` edge, glyph `#F4F6FF` |
  | Undo pill | `#161725` | glass `rgba(255,255,255,.075)` |
  | Quota dots | cream `#F4EFE6` | lime |
* **Iconography:** these Material icons go:
  * `chevron_left_rounded`, `undo_rounded` and `refresh_rounded`;
  * `push_pin` on the locked tile — an 18 % brass watermark behind the letter;
  * `error_outline_rounded` on the load error.

  They are replaced by the drawn `LoopIcon.back`, `undo`, `restart`, `lock` and `snowflake`.
* **Components:**
  * The shipped widgets go: `BoardTile`, `UndoButton`, `RestartButton` and the `PlayTheme` values.
  * Replacements that already exist in `app/lib/design`: `TileFace` (normal / active / winning / locked / frozen / inactive), `RailTile`, `BoardCard`, `MovesCard`, `UndoPill`, `GlassIconButton` and `LoopBackdrop`.
  * **Not in the layer:** the active-row **rails** and the 30 % wrap ghost as board decorations. `TileFace.active` exists; the rails do not.
* **States:**
  * **Row lifted.**
    * Shipped: the row slides with the finger; the rest dims by an 8 % black overlay (`inactiveTileDim`); there is a wrap ghost at the edge; no lift, rim or rails.
    * Target: cream tiles with a 2 px periwinkle rim, glow and a deeper shadow; periwinkle rails at the card edges; the rest at 42 %; the wrap ghost at 30 %.
    * AC9 ("a light visual highlight") holds in both; the target's cue is far stronger.
  * **Column drag.**
    * Shipped: behaves like the row drag. A thin cyan wrap marker shows at the top edge and a cyan line on the card; the moving column is clipped at the card edge.
    * There is no target render.
  * **Locked.**
    * Shipped: a cream tile, a 2 pt brass inset ring and a faint push-pin watermark *behind* the glyph, which costs legibility.
    * Target: an indigo `#4149A0 → #2B3170` tile, a light glyph, a 1.5 px inner rim and a lock icon top-right.
  * **Frozen.**
    * Shipped: a flat ice gradient, a solid 1.5 pt blue border and the glyph at 70 %; no texture or crystal marks (defect A-5).
    * Target: ice `#DFF1FB → #B5D6EC`, a 1.5 px dashed `#3C6E9B` border and a snowflake icon.
  * **Thaw.**
    * Shipped: an instant switch. `BoardTile` is a plain `Container`, so there is no cross-fade.
    * F03 ui-design §7 specifies a 180 ms cross-fade + shimmer. The Foundation says "becomes a normal tile (existing behaviour)" and renders nothing (C-10).
  * **Undo quota.**
    * Shipped: a consumed quota shows as a hollow cream dot; disabled shows as a dim pill.
    * Target: lime dots, 55 % opacity when disabled. A consumed-quota treatment is not rendered.
* **Copy / casing:**
  * `HEDEF` → `HEDEF DÖNGÜ` (proposed copy, P2).
  * The level label `SEVİYE 0N` is new (P1, F03 UI-owned).
  * **Render errata:** S-03 and S-07 hard-code `SEVİYE 05` on level 26 and level 4 boards. Phase D renders must bind the label to the level number.
  * The load-error copy "Bu bulmaca yüklenemedi" / "Geri" is fine.
* **Motion:**
  * The shift already matches: 190 ms with `cubic-bezier(.22,1,.36,1)` (`PlayTheme.shiftDuration` / `shiftCurve`, inside F03 AC5's 150–250 ms band).
  * New in the target (design-foundation §17.3): the ≤ 1.5 % spring settle, the lift, and a 90 ms rim fade-in.
  * The inactive dim changes from an 8 % black overlay to 42 % opacity.
  * None of this was captured as video.
* **Accessibility:**
  * **AX5:** tile glyphs and rail letters follow the OS text scale and overflow their tiles, so the board becomes unreadable (`cur-a11y-ax5-play-idle.png`).
  * **≈ 1.35×:** the board holds (`cur-a11y-xxxl-play-idle.png`).
  * Tile glyphs are sized by the tile; they should not follow OS text scale, or should be capped (`loopCappedTextScaler` exists in the layer).
  * The locked-tile watermark lowers glyph contrast; the target moves the cue to a corner icon.
  * The squares must be ≥ 44 pt in Flutter (ruling 2026-09-21).

**Scope and contract**

* **Scope proposal:** `existing-parity`.
  * S-01b / S-02 / S-03 are selected-source renders of this very screen.
  * The geometry is close, and every component except the rails exists.
  * The missing sub-states extend rendered ones.
  * The lift is feel-critical, so D1 should still require a short screen recording of the row and column lift.
* **Contract impacts:**
  * F03 `ui-design.md` (the Direction A look) is superseded for this surface: the Phase D ui-design replaces its §5–§8 visuals.
  * The chevron-only back becomes "‹ SEVİYE 0N" (P1, F03 UI-owned).
  * AC1 (moves, Undo 3, Restart shown) and AC7 (Restart away from the grid) still hold in the target.
  * Tests will change: the `'HEDEF'` lookup (1), `Icons.*` references (6, in 4 test files) and `PlayTheme.*` (3).
* **Future-scope exclusions:** the gesture hint "Satırı tut · kaydır · bırak" in S-02 / S-03 belongs to F09. Build the S-01b HUD without it.
* **Missing renders:**
  * column drag, with vertical rails;
  * undo with 2 and with 1 left, plus exhausted;
  * restart pressed;
  * a two-digit back label (e.g. `SEVİYE 26`);
  * the thaw, if kept (C-10);
  * the load error;
  * an AX5 Play frame showing the glyph cap.

---

## 5. Column tutorial (F05, levels 4–6)

| State | Current capture | Target | Pair |
| --- | --- | --- | --- |
| Overlay shown (L4, BALIK) | `cur-tutorial-column.png`; collision crop `cur-tutorial-hint-overlap-crop.png` | S-07 | `pair-07-tutorial-column.jpg` |
| Player drags a column while the overlay is up | `cur-play-column-drag.png` | none | no target render |
| Dismissed after the first column move | `cur-tutorial-dismissed.png` | the S-01b equivalent | — |

**Gaps by category**

* **Layout:**
  * The hint line is drawn in the HUD zone *over* the undo pill and the restart button (defect A-1).
  * Target: a 300 × 54 glass pill in the HUD zone, with a sparkle icon and two lines of text.
  * **S-07 shows no undo or restart while the pill is up** — where the HUD controls go during the tutorial is unresolved (C-5).
* **Typography:** a single line in the system font, ≈ 15 pt. Target: Manrope 14.5 on two lines.
* **Colour / surface:**
  * Shipped: bare text on the ground; the ghost is a white translucent disc with a blue chevron.
  * Target: a periwinkle 48 pt ring over the cell, with drawn up / down chevrons.
* **Iconography:** `unfold_more_rounded` → `LoopIcon.upDown`, plus a `LoopIcon.sparkle` on the pill.
* **Components:** new — the hint pill (`GlassCard` + `LoopIconView`) and the ghost ring.
* **Copy:** the same sentence in both, "Sütunları da kaydırabilirsin — yukarı ya da aşağı." — keep it.
* **Motion:**
  * The shipped ghost loops up and down, and keeps looping over the column the player is dragging (defect A-6).
  * The target shows a static ring and chevrons; its motion is unspecified.
  * Recommendation: the ghost hides on touch-down and returns when the board is idle; under reduced motion it is static.
* **Accessibility:** the hint overlaps two controls. The ghost should be excluded from semantics, with the hint announced once (check in Phase D).

**Scope and contract**

* **Scope proposal:** `existing-parity`, inside D1 — it overlays the Play HUD and board, and S-07 exists.
* **Contract impacts:** F05 `architecture.md` §9 ("visual design [PENDING — UI]", "chrome parity with F03 Direction A") → Loop Glass. AC4 and AC11 are unchanged.
* **Future-scope exclusions:** none. The tutorial is F05 scope; the permanent gesture hint is F09.
* **Missing renders:**
  * the HUD while the pill is shown (C-5);
  * the ghost during a real drag.

---

## 6. Won moment (F03 §16) + result (F04)

| State | Current capture | Target | Pair |
| --- | --- | --- | --- |
| Win sequence on the board | `cur-won-sequence-mid.png` | S-10 (600 ms); frames S-08…S-12 | `pair-08-won-sequence.jpg` |
| Result entrance, stars not lit yet | `cur-result-entrance-mid.png` (debug L06) | S-13 (940 ms, stars in outline) | `pair-09-result-entrance.jpg` |
| 3★ first clear — Next primary | `cur-result-3star-first-clear.png` | S-04 | `pair-10-result-3star.jpg` |
| 2★ first clear — Retry primary | `cur-result-2star-first-clear.png` | S-05 | `pair-11-result-2star.jpg` |
| 1★, worse than best | `cur-result-1star.png` | none | no target render |
| New best (3★ after 2★) | `cur-result-new-best.png` | S-04b, which shows a **2★** new best | `pair-12-result-new-best.jpg` |
| Matched best | `cur-result-matched-best.png` | none | no target render |
| Next not wired (debug only) | `cur-result-next-disabled-debug.png` — "SONRAKİ · yakında" | `ui-design.md` §8 "Sonraki bölüm · yakında" — not rendered | no target render |
| Frozen thaw + win in one move | `cur-won-thaw-coincident.png` | none | — |
| Reduced motion — cross-fade | `cur-won-reduced-motion-crossfade.png` | S-15 (300 ms hold) | `pair-13-reduced-crossfade.jpg` |
| Reduced motion — rest | `cur-result-reduced-motion-end.png` | S-16 (660 ms) | `pair-14-reduced-end.jpg` |
| CTAs: `SONRAKİ` (primary / secondary), `Yeniden` (primary / secondary), `Kapat` | In the result captures; all three were exercised | S-04 / S-05: "Sonraki bölüm →", "Tekrar oyna", the back button | inside `pair-10` / `pair-11` |

**Gaps by category**

* **Layout:**
  * **Shipped:** the answer row docks under the target rail, and a bottom sheet (top at ≈ 0.41–0.44 H, height ≤ 0.64 H) sits over the dimmed board. A board row stays visible between the two.
  * **Target** (`ui-design.md` §6): full screen with no board, top to bottom:

    | Element | Position | Size |
    | --- | --- | --- |
    | Back button | (26, 59) pt | 44 pt square |
    | Badge | ≈ 70 pt | — |
    | Headline | ≈ 139 pt | two lines |
    | Subtitle | ≈ 238 pt | — |
    | Answer tiles | ≈ 309 pt | 57.6 × 64.8 pt |
    | Stars | ≈ 409 pt | — |
    | Stats card | ≈ 457 pt | 339 × 81 pt |
    | Primary pill | ≈ 558 pt | — |
    | Text link | ≈ 650 pt | — |
* **Typography:**
  * **Shipped:** the system font; the `ÇÖZÜLDÜ` kicker and the word in letter-spaced amber caps; system numerals.
  * **Target:** the display line "Döngü tamamlandı." in Space Grotesk 33 / 1.13; a Manrope subtitle; stat numerals in Space Grotesk 24 with `tnum`; caps labels at 10.5 pt (≥ 11 in Phase D).
* **Colour / surface:**

  | Element | Shipped | Target |
  | --- | --- | --- |
  | Win row | amber `#FEBE42`, amber seam, amber glow | lime `#E3FB7E → #CDEB4B` — the **only** glow |
  | Panel / stats | panel `#191A2B`, stats card `#12131F` | slate glass stats card |
  | Earned stars | faceted amber `#EBB241` | filled lime `#D0EF58`, no glow |
  | Empty stars | dark-filled `#0E0F1C` | outline `rgba(244,246,255,.55)` |
  | Primary CTA | amber, glowing | lime pill with a neutral shadow |
  | Badge | amber outline | olive glass + sparkle icon |

  With the CTA and stars glowing, the shipped panel has three luminous elements. The target has one (the one-glow rule).
* **Iconography:** none on the shipped panel. The target uses back, sparkle (badge), arrow-right (CTA) and the drawn star (filled / outline).
* **Components:**
  * `CompletionPanel` → `LoopBadge`, `TileFace.winning`, `GhostSlot` (for the transition), `StarRow`, `StatCard` / `StatCell`, `LimePill` (no glow), `TextLink`, `GlassIconButton` (back). All exist.
  * **New:** the full-screen result layout, and the board → result transition.
* **Copy / casing:**
  * `ÇÖZÜLDÜ` + word → the headline "Döngü tamamlandı." + a data-driven subtitle. Count-aware copy goes to PO / localization (ruling 2026-09-21).
  * `SONRAKİ` → "Sonraki bölüm" and `Yeniden` → "Tekrar oyna".
  * `Kapat` is removed: the back button (label "Ana ekrana dön") plus system back replace it.
  * `YENİ REKOR ▲` → the badge `YENİ EN İYİ`.
  * Shipped casing is inconsistent: each action keeps its own case whatever its role (`SONRAKİ` in caps, `Yeniden` in sentence case), so the primary and secondary buttons differ in case between variants. The target uses sentence case for every CTA.
  * These shipped markers have **no counterpart in the target** — keeping, moving or dropping each is a decision (C-4):
    * the `3 / 3` count line;
    * the `+4` / `=` delta between SEN and OPTİMAL;
    * the `İLK` (first clear) marker;
    * the "daha iyi" (worse than best) marker.
* **Motion:**
  * **Shipped:**
    * The row turns amber; all tiles switch together, because the 30 ms stagger was never implemented (OPTIONAL-QUALITY-NOTES).
    * The row then holds and docks under the rail.
    * The sheet slides up, and the stars strike in sequence.
  * **Target** (`ui-design.md` §11, prototype MP-1):
    * **0–210 ms:** a left → right lime fill with a 30 ms stagger;
    * **100–450 ms:** a bloom;
    * **0–200 ms:** the board and chrome dim;
    * **600–840 ms:** the row glides to its result position, morphing size and radius;
    * **680–940 ms:** the content fades and rises;
    * **940–1300 ms:** the stars pop.
  * **Reduced motion** (verified): the shipped path is hold → cross-fade → static stars with the row already docked. That is the same structure as S-15 / S-16; only the composition differs.
* **Accessibility:**
  * **At AX5** (`cur-a11y-ax5-result.png`):
    * the panel grows to ≈ 84 % H and covers the answer row;
    * `OPTİMAL` breaks as "OPTİ / MAL" and `EN İYİ` wraps;
    * the primary label is clipped;
    * a debug overflow stripe appears in the stats card.
  * **At ≈ 1.35×:** everything holds (`cur-a11y-xxxl-result.png`).
  * The target's non-colour cues: position + ghost slot + glow for the win, and filled vs outline stars.

**Scope and contract**

* **Scope proposal:** `motion-critical`. The composition is new and driven by a specified transition (§11, executable prototype MP-1), so the gate needs video or frame-sequence evidence. One Phase D reopen should cover F03 §16 and the F04 result together (carrier: C-2).
* **Contract impacts:**
  * **Confirmed — the full-screen result:** F03 `architecture.md` §18 and ui-design §16 change to a full-screen result. Input lock, the win-sequence-first rule, the reduced path and the controller / persistence timing stay.
  * **New — the visibility rule:** F03 ui-design §16.5 (docked row vs panel, `P.height ≤ 0.64 H`) no longer applies. It needs a replacement rule for the full-screen result:
    * the answer-row rect;
    * a back target ≥ 44 pt;
    * CTAs inside the safe area;
    * no clipping up to the agreed text-scale ceiling (C-9).
  * **The exits (F03 §16.4):** "Tekrar oyna" restarts in place instead of the Retry slide-out (`ui-design.md` §17 #5), and the Close row goes.
  * **F04 `architecture.md`:** "Close / system back pops to the caller" → the back button + system back (ruled 2026-09-21).
  * **F04 tests:** they reference `Kapat` (2), `Yeniden` (13), `SONRAKİ` (8), `ÇÖZÜLDÜ` (4) and `YENİ REKOR` (4) — counts across the app's `test` and `integration_test`.
  * **F04 AC7** (target word, moves, optimal, stars, personal best, Retry, Next) is still met.
  * **New — Close in F05:** F05 PRD AC1 ("When the completion panel closes (via `Next Level` or `Close`) … N+1 is unlocked") and F05 `architecture.md` §8 ("`Close` / system / gesture back → `_popToCaller`") both name Close.
    * The unlock itself stays at `won` (`ui-design.md` §5), so only the wording must be resynced.
    * design-foundation §18, consequence 2, says Close is "not in the PRD". That is true for F03 and F04, but not for F05 (C-3).
  * **F05 AC12** (Next on level 30 → the terminal state): the level-30 result needs a render.
* **Future-scope exclusions:** none on this surface. The reference's `+3 YILDIZ` stat was declined (decision 3).
* **Missing renders:**
  * 1★ and matched best;
  * first clear, if a marker is kept;
  * perfect + new best — badge precedence (C-4);
  * the level-30 result, where Next leads to the terminal state;
  * Next not wired (`· yakında`);
  * a locked or frozen tile inside the winning row at T0 (C-11);
  * an AX5 frame.

---

## 7. Cross-surface items

* **Type:** SF Pro is used everywhere → Space Grotesk / Manrope. Both are bundled (310 KB, F00-DS-UNMEASURED) and unused today.
* **Icons:** the six Material icons listed in §1 → the drawn 12-icon `LoopIcon` set (`icons.dart`, star included).
* **Casing:** the shipped caps strings are authored (`HARİKA`, `ÇÖZÜLDÜ`, `SEVİYE`, `SONRAKİ`), and every `İ` in the captures is correct. Keep authored caps or `turkish_case` in Phase D.
* **Theme migration:** `PlayTheme` is the single shipped theme. Migrating surface by surface creates a hybrid period — e.g. after D1, a Loop Glass board opened from the old Home and ending in the old sheet (C-8).
* **Text scale:** the shipped surfaces follow the OS scale with fixed-height pills and tiles. The design layer caps display text (`loopCappedTextScaler`) and passes at AX5. Phase D needs one ceiling rule for every surface (C-9).
* **Evidence size:** `design/audit/` is ≈ 38 MB — 35 PNG captures (kept lossless for colour sampling) and 14 JPEG pairs. This is relevant to F00-ARTEFACT-SIZE.

---

## 8. Proposed Phase D grouping and order

| Slice | D1 — Play | D2 — Won moment + Result | D3 — Home + app shell |
| --- | --- | --- | --- |
| Surfaces / states | F03 play (all states of §4) + F05 tutorial overlay (§5) + F03 load error | F03 §16 win sequence and transition + F04 full-screen result, including reduced motion (§6) | F05 home, 4 states (§3) + native launch, splash and the F08 bootstrap error (§2) |
| Visual Scope | `existing-parity` | `motion-critical` | `new-surface` |
| Carrier (proposal) | F03; the F05 overlay as a cross-feature item | F03 (owner of the §16 timeline, input lock and exits), with the F04 amendments in the same reopen — or F04 (C-2) | F05; the F08 error screen and launch assets as cross-feature items (C-7) |
| Reuses from `app/lib/design` | `TileFace`, `RailTile`, `BoardCard`, `MovesCard`, `UndoPill`, `GlassIconButton`, `GlassCard`, `LoopBackdrop`, `LoopIconView` (back, undo, restart, lock, snowflake, upDown, sparkle), tokens, typography | `TileFace.winning`, `GhostSlot`, `LoopBadge`, `StarRow`, `StatCard`, `LimePill`, `TextLink`, `GlassIconButton`, `LoopIconView` (back, sparkle, arrowRight) | `GlassCard`, `LoopNode`, `LimePill(glow)`, `LoopletWordmark`, `LoopBackdrop`, `LoopIconView(arrowRight)` |
| New pieces | active-row rails + wrap ghost; back label; hint pill; ghost ring; error card | full-screen result layout; board → result transition (Flutter port of MP-1) | the loop-track component (curve, line, swirl arcs, 30-level windowing); the terminal state; launch assets |
| Contract size | small: F03 ui-design visuals, F05 §9 visual, copy P1 / P2 | large: F03 §16 / §16.5 / §18, F04 architecture + ui-design, F05 AC1 / §8 wording, ≈ 30 test string references | medium: F05 §10 + N1 (§8), F08 error-screen contract and copy, native assets |
| Risk | Low–medium. The engine, gestures and persistence stay; the theme swap touches every Play widget; ≈ 10 test references change. | High. The timing contract, persistence at `won`, route / exit changes, and video evidence required. | Medium. A new component, unrendered states and an N1 behaviour change. |
| Player-visible impact | high — where the time is spent | very high — the payoff moment, and the user's own override (full screen, no Close) | very high — the first screen of every launch |

**Order: D1 → D2 → D3.**

1. **D1 first.**
   * Its main states have selected-source renders, and almost every component exists.
   * It has the smallest contract and the lowest behavioural risk.
   * It sets the per-surface migration pattern (`PlayTheme` → tokens) that D2 and D3 reuse.
   * It fixes shipped defects A-1, A-2 (on the board), A-5 and A-6.
2. **D2 second.**
   * Its transition starts from the Play board: the §11 size / radius morph (57.1² → 57.6 × 64.8) is specified from the new board geometry. Building it before D1 would mean re-tuning it later.
   * It needs the most contract work up front, and it is the riskiest slice, so it benefits from D1's pattern.
3. **D3 third.**
   * Home is route-independent of D1 / D2, but three of its four states and the loop track need design work first.
   * If the Tech Lead allows it under rework control, the UI Designer can render D3's missing states while D1 / D2 are implemented.
   * **Alternative:** if the first impression outweighs the risk, run D3 first, once its renders exist. The cost is waiting on design before any code starts.

**First Phase D brief — D1 skeleton** (enough for the Tech Lead to write it):

* **Carrier:** F03, reopened as visual rework, with Visual Scope `existing-parity`. The gate goes Pending → Ready for Implementation after the D1 ui-design.
* **UI Designer step:** a Loop Glass Play ui-design for F03 that replaces the Direction A visual sections.
  * Selected sources: S-01b / S-02 / S-03 / S-07.
  * New renders: the D1 list in §10, and the C-5, C-9 and C-10 outcomes.
* **Frontend step:**
  * Migrate the Play screen, the tutorial overlay and the load error to `app/lib/design` tokens and components.
  * Replace the five Material icons used on these surfaces.
  * Engine, gestures and persistence stay untouched.
  * Evidence: Visual Parity Evidence on the iPhone 16 / 16e / Pro Max, plus a screen recording of the row and column lift.
* **Acceptance assertions:**
  * Board card at 86 % width; tiles 57.1 pt at 393 pt.
  * Active row: cream + periwinkle rim + rails; the rest at 42 %; the wrap ghost at 30 %.
  * Locked tile: indigo + lock icon. Frozen tile: ice + dashed border + snowflake. Both readable in greyscale.
  * HUD per S-01b: the `HAMLE` card top-right; the undo pill with lime dots.
  * The tutorial hint never overlaps a control.
  * No clipping at the agreed text-scale ceiling.
  * No Material icon on the surface; `HAMLE` ≥ 11 pt; targets ≥ 44 pt.
* **Non-goals:**
  * the won moment and the result (D2);
  * the home (D3);
  * the gesture hint (F09).

---

## 9. Contract impacts (consolidated)

| # | Item | Where | Owner | Relation to DESIGN-ADOPTION-CONTRACT-AMENDMENTS |
| --- | --- | --- | --- | --- |
| 1 | Won moment → full-screen result. Input lock, win-first, the reduced path and the timing stay. | F03 `architecture.md` §18, ui-design §16 | Tech Lead | confirmed |
| 2 | No Close: a back button + system back ("Ana ekrana dön"). F03 §16.4 exits re-specified. | F04 `architecture.md` + ui-design; F03 ui-design §16.4 | Tech Lead (ruled 2026-09-21) | confirmed |
| 3 | Home composition: loop track, `Looplet`, reference copy; future-scope items stay out | F05 `architecture.md` §10, ui-design | Tech Lead; copy with PO / localization | confirmed |
| 4 | Turkish casing, bundled fonts, drawn icons for the six `Icons.*` | all surfaces | Frontend | confirmed; the six icons are located in §1 |
| 5 | N1: terminal precedence vs an in-progress replay | F05 `architecture.md` §8 | Tech Lead | confirmed; recommendation C-1 |
| 6 | F05 PRD AC1 and `architecture.md` §8 name `Close` | F05 `prd.md`, `architecture.md` | PO (PRD) / Tech Lead | **new** (C-3) |
| 7 | F03 §16.5's visibility rule is obsolete → a full-screen result rule | F03 ui-design §16.5 | UI Designer + Tech Lead | **new** |
| 8 | Text-scale ceiling: 1.0 / 1.3× vs "accessibility sizes" | F03 ui-design §16.5; F00 ui-design §13; F00 `architecture.md` §3 | Tech Lead | **new** (C-9) |
| 9 | Result markers without a target counterpart (`3 / 3`, delta, `İLK`, "daha iyi") and badge precedence | F04 ui-design | UI Designer / Tech Lead | **new** (C-4) |
| 10 | F08 `StoreErrorScreen` "plain by design" → Foundation pattern, Turkish copy, no raw exception | F08 `architecture.md`; `app_router.dart` | Tech Lead | **new** (C-6) |
| 11 | Native launch screens (iOS, Android) have no owner | app shell | Tech Lead | **new** (C-7) |
| 12 | Frozen cue and thaw: the shipped tile misses F03 ui-design §7's texture, crystal marks and 180 ms thaw; the Foundation says "becomes a normal tile" | F03 ui-design §7 | Tech Lead | **new** (C-10) |
| 13 | The tutorial HUD while the hint pill is shown | F05 `architecture.md` §9, ui-design | UI Designer | **new** (C-5) |
| 14 | Locked / frozen tiles inside the winning row | F03 §16 (D2) | UI Designer | **new** (C-11) |
| 15 | Header copy `HEDEF DÖNGÜ` and the level label `SEVİYE 0N` | F03 ui-design (P1 / P2) | PO / localization for copy; UI Designer | confirmed (design-foundation §17.9) |

---

## 10. Missing renders — Phase D renders these before implementation

**D1 — Play and tutorial (10)**

1. column drag, with vertical rails;
2. undo with 2 left;
3. undo exhausted (0 left, disabled);
4. restart pressed;
5. a two-digit back label (`SEVİYE 26`);
6. the thaw moment (C-10);
7. the load error;
8. the tutorial with the HUD resolved (C-5);
9. the ghost during a real drag;
10. AX5 Play.

**D2 — Won moment and result (8)**

11. 1★;
12. matched best;
13. first clear, if a marker is kept (C-4);
14. perfect + new best (C-4);
15. the level-30 result (Next → terminal);
16. Next not wired (`· yakında`);
17. a locked / frozen tile inside the winning row (C-11);
18. AX5 result.

**D3 — Home and shell (8)**

19. new player (0/30);
20. mid, no replay;
21. the 30-level windowing rule (12/30, 25/30);
22. terminal 30/30;
23. terminal with a replay in progress (C-1);
24. AX5 Home;
25. the bootstrap error;
26. the native launch / splash.

---

## 11. Screen / State / Viewport matrix

Every row: viewport 393 × 852 (iPhone 16). Phase D adds 390 × 844 and 440 × 956 for every rendered state (only S-v-* play idle / result perfect exist today).

| Screen | State | Current artifact | Target artifact | Critical assertions for Phase D |
| --- | --- | --- | --- | --- |
| Shell | native launch | `cur-shell-splash.png` | none | launch background = ground colour; no white frame |
| Shell | bootstrap error | `cur-shell-bootstrap-error.png` | none (pattern `ui-design.md` §8) | Turkish copy; no raw exception; glass card + lime pill; ≥ 44 pt retry |
| Home | new 0/30 | `cur-home-new.png` | none | `Looplet` wordmark; track shows the start; CTA "Devam et" |
| Home | mid 1/30 | `cur-home-mid.png` | S-06b (closest) | label `YOLCULUK · N / 30`; nodes never overlap or sit under the card |
| Home | in progress | `cur-home-in-progress.png`, `cur-home-late-in-progress.png` | S-06b | current node periwinkle + halo; subtitle `· sürüyor` |
| Home | terminal 30/30 | `cur-home-terminal.png` | none | AC9 graceful state; N1 per C-1 |
| Play | idle | `cur-play-idle.png` | S-01b | board card 86 % width; tile 57.1 pt; no Material icon |
| Play | row lifted | `cur-play-row-lifted.png` | S-02 | cream + periwinkle rim + rails; rest 42 %; wrap ghost 30 %; never lime |
| Play | column drag | `cur-play-column-drag.png` | none | vertical rails; column never clipped outside the card radius |
| Play | locked + frozen | `cur-play-locked-frozen.png` (+ crop) | S-03 | lock icon + indigo; snowflake + dashed ice; readable in greyscale |
| Play | thaw | `cur-won-thaw-coincident.png` | none | per C-10; reduced motion instant |
| Play | HUD undo enabled / disabled / consumed | `cur-play-hud-after-move.png`, `cur-play-hud-after-undo.png`, `cur-play-idle.png` | S-03, S-01b | lime quota dots; disabled 55 %; `HAMLE` ≥ 11 pt |
| Play | back + target rail | in every Play capture | S-01b | "‹ SEVİYE N" bound to the level; rail indigo tiles |
| Play | load error | `cur-play-load-error.png` | none | pattern `ui-design.md` §8; drawn icon |
| Tutorial | overlay | `cur-tutorial-column.png`, `cur-tutorial-hint-overlap-crop.png` | S-07 | hint never overlaps a control; ghost hides during a drag |
| Tutorial | dismissed | `cur-tutorial-dismissed.png` | S-01b | no residue |
| Won | win sequence | `cur-won-sequence-mid.png` | S-08…S-12 | lime fill 30 ms stagger; one bloom; timings §11 (video) |
| Result | entrance | `cur-result-entrance-mid.png` | S-13, S-14 | stars pop 940–1300 ms after rest |
| Result | 3★ first clear | `cur-result-3star-first-clear.png` | S-04 | back button; answer tiles at the §6 position; Next primary |
| Result | 2★ | `cur-result-2star-first-clear.png` | S-05 | Retry ("Tekrar oyna") primary; star 3 outline |
| Result | 1★ | `cur-result-1star.png` | none | Retry primary; Next available (F05 AC13) |
| Result | new best | `cur-result-new-best.png` | S-04b | badge `YENİ EN İYİ` (precedence C-4) |
| Result | matched best | `cur-result-matched-best.png` | none | no new-best badge |
| Result | Next not wired | `cur-result-next-disabled-debug.png` | none | "Sonraki bölüm · yakında" at 45 % |
| Result | reduced motion | `cur-won-reduced-motion-crossfade.png`, `cur-result-reduced-motion-end.png` | S-15, S-16 | 300 ms hold, 160 ms cross-fade, content 460–660 ms, static stars |
| All | OS text ≈ 1.35× | `cur-a11y-xxxl-*.png` | none | holds today; must still hold |
| All | OS text AX5 | `cur-a11y-ax5-*.png` | none | per C-9: no clipping or overlap; fixed-size glyphs capped |

---

## 12. Visual Evidence Manifest

Every record below has the same provenance:

* **Source Revision:** `615e94c` — a debug build of `app/lib/main.dart`; working tree clean apart from `design/audit/`.
* **Captured By:** UI Designer. **Captured At:** 2026-09-27.
* **Device:** iOS Simulator 18.6, iPhone 16.
* **Artifacts:** under `features/f00-design-foundation/design/audit/`.
* **Nature:** runtime captures of the shipped app, not renders. `parity-comparison` records are generated composites of a capture and an existing `S-*` selected-source render (`cc7fe3f` + working tree, F00-UI-FINALIZE).

| Evidence ID | Kind | Screen / State | Viewport / Device | Artifact | Source Revision | Captured By | Captured At | Result / Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AUD-RS-01 | runtime-screenshot | Shell · native launch | 393×852 iPhone 16 | `audit/cur-shell-splash.png` | 615e94c | UI Designer | 2026-09-27 | white frame (A-4) |
| AUD-RS-02 | runtime-screenshot | Shell · bootstrap error (corrupt store) | 393×852 iPhone 16 | `audit/cur-shell-bootstrap-error.png` | 615e94c | UI Designer | 2026-09-27 | English + raw exception (A-3); store restored after |
| AUD-RS-03 | runtime-screenshot | Home · new 0/30 | 393×852 iPhone 16 | `audit/cur-home-new.png` | 615e94c | UI Designer | 2026-09-27 | fresh install |
| AUD-RS-04 | runtime-screenshot | Home · mid 1/30 | 393×852 iPhone 16 | `audit/cur-home-mid.png` | 615e94c | UI Designer | 2026-09-27 | — |
| AUD-RS-05 | runtime-screenshot | Home · in progress 0/30 | 393×852 iPhone 16 | `audit/cur-home-in-progress.png` | 615e94c | UI Designer | 2026-09-27 | — |
| AUD-RS-06 | runtime-screenshot | Home · in progress 25/30 | 393×852 iPhone 16 | `audit/cur-home-late-in-progress.png` | 615e94c | UI Designer | 2026-09-27 | progress seeded |
| AUD-RS-07 | runtime-screenshot | Home · terminal 30/30 | 393×852 iPhone 16 | `audit/cur-home-terminal.png` | 615e94c | UI Designer | 2026-09-27 | progress seeded |
| AUD-RS-08 | runtime-screenshot | Play · idle L1 | 393×852 iPhone 16 | `audit/cur-play-idle.png` | 615e94c | UI Designer | 2026-09-27 | — |
| AUD-RS-09 | runtime-screenshot | Play · row lifted mid-drag | 393×852 iPhone 16 | `audit/cur-play-row-lifted.png` | 615e94c | UI Designer | 2026-09-27 | captured during a held drag |
| AUD-RS-10 | runtime-screenshot | Play · column drag L4 (tutorial up) | 393×852 iPhone 16 | `audit/cur-play-column-drag.png` | 615e94c | UI Designer | 2026-09-27 | ghost over the dragged column (A-6) |
| AUD-RS-11 | runtime-screenshot | Play · locked + frozen L26 | 393×852 iPhone 16 | `audit/cur-play-locked-frozen.png`, `audit/cur-play-locked-frozen-crop.png` | 615e94c | UI Designer | 2026-09-27 | progress seeded; the crop is a pixel crop |
| AUD-RS-12 | runtime-screenshot | Play / Won · thaw coinciding with the win (debug L06) | 393×852 iPhone 16 | `audit/cur-won-thaw-coincident.png` | 615e94c | UI Designer | 2026-09-27 | debug smoke level |
| AUD-RS-13 | runtime-screenshot | Play · HUD undo enabled | 393×852 iPhone 16 | `audit/cur-play-hud-after-move.png` | 615e94c | UI Designer | 2026-09-27 | — |
| AUD-RS-14 | runtime-screenshot | Play · HUD after one undo | 393×852 iPhone 16 | `audit/cur-play-hud-after-undo.png` | 615e94c | UI Designer | 2026-09-27 | — |
| AUD-RS-15 | runtime-screenshot | Play · load error | 393×852 iPhone 16 | `audit/cur-play-load-error.png` | 615e94c | UI Designer | 2026-09-27 | `settings.language=de`, restored |
| AUD-RS-16 | runtime-screenshot | Tutorial · overlay L4 | 393×852 iPhone 16 | `audit/cur-tutorial-column.png` | 615e94c | UI Designer | 2026-09-27 | progress seeded |
| AUD-RS-17 | runtime-screenshot | Tutorial · hint / HUD collision | 393×852 iPhone 16 | `audit/cur-tutorial-hint-overlap-crop.png` | 615e94c | UI Designer | 2026-09-27 | crop of AUD-RS-16 (A-1) |
| AUD-RS-18 | runtime-screenshot | Tutorial · dismissed | 393×852 iPhone 16 | `audit/cur-tutorial-dismissed.png` | 615e94c | UI Designer | 2026-09-27 | — |
| AUD-RS-19 | runtime-screenshot | Won · win sequence on the board | 393×852 iPhone 16 | `audit/cur-won-sequence-mid.png` | 615e94c | UI Designer | 2026-09-27 | — |
| AUD-RS-20 | runtime-screenshot | Result · entrance (stars not lit) | 393×852 iPhone 16 | `audit/cur-result-entrance-mid.png` | 615e94c | UI Designer | 2026-09-27 | debug L06 burst frame |
| AUD-RS-21 | runtime-screenshot | Result · 3★ first clear | 393×852 iPhone 16 | `audit/cur-result-3star-first-clear.png` | 615e94c | UI Designer | 2026-09-27 | — |
| AUD-RS-22 | runtime-screenshot | Result · 2★ first clear | 393×852 iPhone 16 | `audit/cur-result-2star-first-clear.png` | 615e94c | UI Designer | 2026-09-27 | — |
| AUD-RS-23 | runtime-screenshot | Result · 1★ worse than best | 393×852 iPhone 16 | `audit/cur-result-1star.png` | 615e94c | UI Designer | 2026-09-27 | — |
| AUD-RS-24 | runtime-screenshot | Result · new best (3★ after 2★) | 393×852 iPhone 16 | `audit/cur-result-new-best.png` | 615e94c | UI Designer | 2026-09-27 | — |
| AUD-RS-25 | runtime-screenshot | Result · matched best | 393×852 iPhone 16 | `audit/cur-result-matched-best.png` | 615e94c | UI Designer | 2026-09-27 | — |
| AUD-RS-26 | runtime-screenshot | Result · Next not wired (debug) | 393×852 iPhone 16 | `audit/cur-result-next-disabled-debug.png` | 615e94c | UI Designer | 2026-09-27 | debug smoke level only |
| AUD-RS-27 | runtime-screenshot | Won · reduced-motion cross-fade | 393×852 iPhone 16 | `audit/cur-won-reduced-motion-crossfade.png` | 615e94c | UI Designer | 2026-09-27 | OS Reduce Motion on, then restored |
| AUD-RS-28 | runtime-screenshot | Result · reduced-motion rest | 393×852 iPhone 16 | `audit/cur-result-reduced-motion-end.png` | 615e94c | UI Designer | 2026-09-27 | static stars |
| AUD-A11Y-01 | accessibility | Home terminal · OS text ≈ 1.35× | 393×852 iPhone 16 | `audit/cur-a11y-xxxl-home-terminal.png` | 615e94c | UI Designer | 2026-09-27 | holds |
| AUD-A11Y-02 | accessibility | Play idle · OS text ≈ 1.35× | 393×852 iPhone 16 | `audit/cur-a11y-xxxl-play-idle.png` | 615e94c | UI Designer | 2026-09-27 | holds |
| AUD-A11Y-03 | accessibility | Result 3★ · OS text ≈ 1.35× | 393×852 iPhone 16 | `audit/cur-a11y-xxxl-result.png` | 615e94c | UI Designer | 2026-09-27 | holds |
| AUD-A11Y-04 | accessibility | Home terminal · OS text AX5 | 393×852 iPhone 16 | `audit/cur-a11y-ax5-home-terminal.png` | 615e94c | UI Designer | 2026-09-27 | wordmark / label / CTA break (A-2) |
| AUD-A11Y-05 | accessibility | Play idle · OS text AX5 | 393×852 iPhone 16 | `audit/cur-a11y-ax5-play-idle.png` | 615e94c | UI Designer | 2026-09-27 | tile glyphs clipped (A-2) |
| AUD-A11Y-06 | accessibility | Result 3★ · OS text AX5 | 393×852 iPhone 16 | `audit/cur-a11y-ax5-result.png` | 615e94c | UI Designer | 2026-09-27 | panel ≈ 84 % H, mid-word breaks (A-2) |
| AUD-PC-01 | parity-comparison | Home in progress vs S-06b | 393×852 | `audit/pair-01-home-in-progress.jpg` | 615e94c + S-06b | UI Designer | 2026-09-27 | composite |
| AUD-PC-02 | parity-comparison | Home mid vs S-06b (closest) | 393×852 | `audit/pair-02-home-mid.jpg` | 615e94c + S-06b | UI Designer | 2026-09-27 | composite |
| AUD-PC-03 | parity-comparison | Play idle vs S-01b | 393×852 | `audit/pair-03-play-idle.jpg` | 615e94c + S-01b | UI Designer | 2026-09-27 | composite |
| AUD-PC-04 | parity-comparison | Row lifted vs S-02 | 393×852 | `audit/pair-04-play-row-lifted.jpg` | 615e94c + S-02 | UI Designer | 2026-09-27 | composite |
| AUD-PC-05 | parity-comparison | Locked + frozen vs S-03 | 393×852 | `audit/pair-05-play-locked-frozen.jpg` | 615e94c + S-03 | UI Designer | 2026-09-27 | composite |
| AUD-PC-06 | parity-comparison | HUD undo enabled vs S-03 | 393×852 | `audit/pair-06-play-hud.jpg` | 615e94c + S-03 | UI Designer | 2026-09-27 | composite |
| AUD-PC-07 | parity-comparison | Column tutorial vs S-07 | 393×852 | `audit/pair-07-tutorial-column.jpg` | 615e94c + S-07 | UI Designer | 2026-09-27 | composite |
| AUD-PC-08 | parity-comparison | Win sequence vs S-10 | 393×852 | `audit/pair-08-won-sequence.jpg` | 615e94c + S-10 | UI Designer | 2026-09-27 | composite; stills, not motion evidence |
| AUD-PC-09 | parity-comparison | Result entrance vs S-13 | 393×852 | `audit/pair-09-result-entrance.jpg` | 615e94c + S-13 | UI Designer | 2026-09-27 | composite |
| AUD-PC-10 | parity-comparison | Result 3★ vs S-04 | 393×852 | `audit/pair-10-result-3star.jpg` | 615e94c + S-04 | UI Designer | 2026-09-27 | composite |
| AUD-PC-11 | parity-comparison | Result 2★ vs S-05 | 393×852 | `audit/pair-11-result-2star.jpg` | 615e94c + S-05 | UI Designer | 2026-09-27 | composite |
| AUD-PC-12 | parity-comparison | New best (3★) vs S-04b (2★) | 393×852 | `audit/pair-12-result-new-best.jpg` | 615e94c + S-04b | UI Designer | 2026-09-27 | composite; star counts differ by design |
| AUD-PC-13 | parity-comparison | Reduced motion cross-fade vs S-15 | 393×852 | `audit/pair-13-reduced-crossfade.jpg` | 615e94c + S-15 | UI Designer | 2026-09-27 | composite |
| AUD-PC-14 | parity-comparison | Reduced motion rest vs S-16 | 393×852 | `audit/pair-14-reduced-end.jpg` | 615e94c + S-16 | UI Designer | 2026-09-27 | composite |

---

## 13. Assumptions and limits

* The debug build at `615e94c` shows players what the release build shows. The only exception is the `kDebugMode` chip row, which is excluded from every finding.
* Seeded progress states are equivalent to naturally reached ones: they are read through the same repositories and read-model.
* Simulator content-size categories stand for OS text scale. The scale factors (≈ 1.35×, ≈ 3.12×) are approximate.
* **Brief errata:** the brief maps the debug chips as `L04` locked and `L05` frozen. The smoke set is actually `L04` column-enabled, `L05` locked pivot and `L06` frozen (`debug_puzzle_library.dart`). Locked + frozen were captured on Journey level 26 instead, the same content as S-03.
* **Render errata:** in the S-03 and S-07 renders, `SEVİYE 05` is placeholder copy.
* **Tooling:** the pair composites and colour samples come from scratch AppKit scripts, which are not committed. Only their outputs are evidence.
* **Motion:** motion statements rest on burst frames, the code and the §11 spec. No video was recorded.

---

## 14. Needs Tech Lead Clarification

* **C-1 — N1: terminal state vs an in-progress replay.**
  * **Recommendation:** surface the replay. When 30/30 is complete and a replay is in progress, the CTA resumes it ("Devam et", subtitle "Seviye N · sürüyor"), and the card keeps the completion status (e.g. `YOLCULUK · 30 / 30`).
  * Without a replay, the terminal CTA stays "Tekrar oyna" → level 1.
  * **Reason:** the single "continue" CTA should never discard a mid-puzzle state silently.
  * **Needs:** an F05 `architecture.md` §8 amendment and a D3 render.
* **C-2 — Carriers.**
  * **D2:** F03, which owns the §16 timeline, input lock and exits, with the F04 amendments applied in the same reopen; or F04, which owns the result content.
  * **D1:** does it carry the F05 tutorial overlay as a cross-feature item?
  * **D3:** does it carry the F08 error screen?
* **C-3 — `Close` in F05.** F05 PRD AC1 and F05 `architecture.md` §8 name it, so the no-Close decision needs a PRD wording resync: a Product Owner revision, or a Tech Lead resync as done for AC3 on 2026-09-26. design-foundation §18's statement that Close is "not in the PRD" should be corrected when this is settled.
* **C-4 — Result markers with no target counterpart.** Recommendations:
  * Drop the `3 / 3` line (the stars say it; it is already the first concession in F03 §16.3).
  * Drop the `+N` / `=` delta (SEN and OPTİMAL sit side by side).
  * Drop `İLK` and "daha iyi" (the EN İYİ value explains itself).
  * When a result is both perfect and a new best, show `HARİKA` (perfect implies the best); use `YENİ EN İYİ` for non-perfect improvements.
  * These are F04 ui-design decisions; F04's PRD ACs are unaffected.
* **C-5 — Tutorial HUD.** S-07 shows no undo or restart while the hint pill is up. Options:
  * (a) the pill sits above the HUD, and the HUD stays;
  * (b) the pill replaces the HUD until the first column move.

  **Recommendation:** (a). Undo and restart must stay reachable, because the player may make row moves before the column move.
* **C-6 — F08 `StoreErrorScreen`.** Adopt the Foundation pattern, localise the copy, and stop showing the raw exception to players: log it, or show it only in debug builds.
* **C-7 — Native launch screens.** They need an owner. Proposal: D3, as a cross-feature shell item. Setting the launch background to the ground colour is a one-line asset change per platform.
* **C-8 — Hybrid period.** Between D1 and D3, a Loop Glass board sits between the old Home and the old sheet. **Recommendation:** accept it rather than run a global font / colour swap without the layouts, since such a swap would need gate evidence on every surface anyway.
* **C-9 — Text-scale ceiling for Phase D acceptance.** F03 ui-design §16.5 covers 1.0 and 1.3×; F00 ui-design §13 and `architecture.md` §3 say "accessibility sizes".
  * **Recommendation:** text scales to AX5 with no clipping or overlap. Glyphs sized to a container (tiles, rail, answer tiles, wordmark, card numerals) use the capped scaler.
  * Decide whether the full-screen result may scroll at AX4–AX5. F03 §16.5 (5) forbids scrolling today.
* **C-10 — Thaw.** Implement F03 ui-design §7's 180 ms cross-fade (instant under reduced motion), or accept the Foundation's plain switch. **Recommendation:** implement it. It is cheap and makes a state change readable. Render it in D1.
* **C-11 — Special tiles in the winning row.** **Recommendation:** the whole answer row turns lime at T0 (the resolution colour), and the lock / snowflake icons fade out with the fill. Render it in D2.
