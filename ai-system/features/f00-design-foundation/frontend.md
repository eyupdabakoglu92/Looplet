# F00 — design-foundation: Frontend Delivery (F00-FE-DESIGN-SYSTEM)

> Delivery + traceability artifact. Contract authority: `architecture.md` §7. Visual authority: `ui-design.md` (tokens §7–§8, accessibility §13, handoff §14), `project-authority/design-foundation.md` (Selected, §17/§18) and `design/S-91-components.png`. Direct-edit mode — real files under `app/lib/design/`, `app/assets/fonts/`, `app/lib/main_gallery.dart`, `app/test/design/`. Source revision of every record below: **HEAD 9a72481 + uncommitted working tree** as written by the Frontend role.
>
> **Tech Lead provenance note (2026-09-21):** that working tree was committed unchanged as **`78b22e3`** (clean tree; tree `bf1c8eec8bebacda6ebf6ef5267b46b84ef84540`). Read every "HEAD 9a72481 + working tree" below as commit 78b22e3, with one exception: a doc-comment edit in `app/lib/design/icons.dart` was made after the runtime captures (no code change; analyzer, format and design tests re-run afterwards). The Tech Lead re-ran `melos run analyze`, `melos run format:check` and `melos run test` on the clean tree at 78b22e3: exit 0, packages 197, app 305. **Correction (Tech Lead):** the `F00.DS-RT-16-2560` note originally credited the runtime frame with `İLK`; the frame shows `ILIK` (from `ılık`) and `İLK` is proven by the unit test — text fixed below, evidence otherwise unchanged.

---

## 1. Feature Summary

The design-system layer of the selected Direction C ("Loop Glass") exists as a parallel, unused-by-the-app layer: tokens, type roles on two bundled variable fonts, a drawn icon set, the `Looplet` wordmark, locale-correct Turkish casing, and the shared components in every state ui-design lists — plus a debug-only gallery that is the runtime source for visual parity. **No shipped surface changed**: no shipped file imports the layer, the only tracked file modified is `app/pubspec.yaml` (font declaration, +13 lines, no dependency), and all pre-existing suites are unchanged and green.

Runtime parity was checked on the iOS 18.6 simulator (iPhone 16, 16e, 16 Pro Max) by side-by-side crops against S-91 (and the C-03 play frame where the S-91 specimen omits an icon). The comparison found one real deviation — the frozen tile lacked its solid ring and the dashed outline used a different dash rhythm than the source renders — which was **fixed in this delivery** (see §4 and §17). Remaining differences are specimen-vs-component composition and are listed as deviations.

---

## 2. Impacted Files

**Modified (1 tracked file)**

| File | Change |
| --- | --- |
| `app/pubspec.yaml` | `flutter: fonts:` declares families `SpaceGrotesk` and `Manrope` (+13 lines incl. comment). No dependency added, no bootstrap/`main.dart` change. |

**Created — `app/assets/fonts/`** (SIL OFL 1.1 variable fonts, no network loading)

| File | Bytes |
| --- | --- |
| `SpaceGrotesk.ttf` | 136,676 |
| `Manrope.ttf` | 164,700 |
| `OFL-SpaceGrotesk.txt`, `OFL-Manrope.txt` | 4,495 · 4,387 |

**Created — `app/lib/design/`** (public surface re-exported by `design.dart`; 2,144 Dart lines incl. gallery and `main_gallery.dart`)

| File | Role |
| --- | --- |
| `tokens.dart` | `LoopColors`, `LoopRadii`, `LoopSpacing` (358-pt reference), `LoopGradients`, `LoopScale` (`width / 358`, clamped 0.9–1.3) |
| `typography.dart` | `LoopText` roles (Space Grotesk 500 display/headline/stat/counter/tile glyph/node/wordmark; Manrope 500–600 CTA/body/link/caption/label/badge) via `FontVariation('wght', n)`; tabular figures on numerals |
| `turkish_case.dart` | `turkishUpper` (`i→İ`, `ı→I`) and `turkishLower` (`I→ı`, `İ→i`) |
| `icons.dart` | `LoopIcon` (12 drawn icons), `LoopIconView`, `LoopIconPainter`, `DashedRRectPainter` |
| `wordmark.dart` | `LoopletWordmark` — `Looplet`, capital L, last three letters lime |
| `components/surfaces.dart` | `GlassCard` (+ slate variant), `BoardCard`, `LoopBackdrop` |
| `components/tile.dart` | `TileFace` (normal, active, winning, locked, frozen, inactive), `GhostSlot`, `RailTile` |
| `components/buttons.dart` | `LimePill` (glow / neutral-shadow), `OutlinePill`, `TextLink` (incl. disabled), `GlassIconButton`, `UndoPill` |
| `components/info.dart` | `LoopBadge`, `MovesCard`, `StatCell`/`StatCard`, `LoopNode` (done / current + halo), `StarRow` |
| `gallery/design_gallery_screen.dart` | debug-only `DesignGalleryScreen` laid out by section like S-91 |

**Created — entry point and tests**

| File | Role |
| --- | --- |
| `app/lib/main_gallery.dart` | debug-only second entry point (`flutter build ios --simulator --debug -t lib/main_gallery.dart`); never referenced by `lib/main.dart` |
| `app/test/design/tokens_typography_test.dart` (12), `turkish_case_test.dart` (6), `components_test.dart` (44) | 62 tests |

**Created — evidence and tooling under `ai-system/features/f00-design-foundation/design/`**

`runtime-iphone16-{0,640,1280,1920,2560}.png`, `runtime-iphone16e-sheet.png`, `runtime-iphone16promax-sheet.png`, `parity-runtime-1-tiles.png`, `parity-runtime-2-controls.png`, `parity-runtime-3-cards-icons.png` (5.2 MB); `src/capture-gallery.sh`, `src/parity-board.py`; `README.md` gained a "Round 4" section. Everything else in that folder is UI Designer output and untouched.

**Unchanged (proof):** `git diff --stat` = `app/pubspec.yaml | 13 +` only among tracked files; `grep -rn -E "design/|main_gallery|looplet_app/design" app/lib` outside `lib/design/` and `lib/main_gallery.dart` → no match; no existing test or integration test imports the layer.

---

## 3. Task-to-Code Traceability

**F00-FE-DESIGN-SYSTEM — Complete** (Delivery Review left to the Tech Lead). Mapping to `architecture.md` §7:

| §7 item | Status | Where |
| --- | --- | --- |
| 7.1 location and shape | done | `app/lib/design/{tokens,typography,icons,wordmark,turkish_case}.dart`, `components/`, `gallery/`, barrel `design.dart` |
| 7.2 coexistence, no shipped surface change | done | table in §2; `PlayTheme` and all shipped screens untouched; suites unchanged (§17) |
| 7.3 fonts | done | `app/assets/fonts/*`, `pubspec.yaml`; weight axis, tabular figures, all Turkish capitals and lowercase verified on the simulator (`runtime-iphone16-2560.png`); bundle cost in §13 |
| 7.4 icons | done | `icons.dart` — `CustomPainter`/`Path`, paths ported from the S-91 icon row; no package |
| 7.5 components | done | all listed components; animated piece = press feedback only, gated by `reduceMotionRequested()` |
| 7.6 gallery | done | `DesignGalleryScreen` + `main_gallery.dart` (debug entry point only) |
| 7.7 evidence | done | §17 (automated) and *Visual Parity Evidence* below (runtime); deviations listed there |
| 7.8 non-goals | respected | no restyle, no logic/persistence/contract change, no new feature content, no Flutter motion prototype |

Corrected-value items from the brief: label/HAMLE caption is **11 pt** (S-91 draws 10.4), `GlassIconButton` and `TextLink` keep a **≥ 44 pt** target (test-enforced).

---

## 4. Authority Reconciliation

Where the S-91 sheet and another authority disagree, the more specific authority won; nothing was silently resolved.

| Point | S-91 specimen | Winner and why |
| --- | --- | --- |
| Label size | 10.4 px HAMLE / 10 px small captions | ui-design §17.3 and the brief: ≥ 11 pt |
| Touch targets | 43.9–44 px squares at 1× | ui-design §13 / brief: ≥ 44 pt (built with a 44 minimum) |
| Journey card headline | 22 px in a 380×84 specimen | ui-design §Home: headline **28/1.16** inside the card — the runtime uses the `headline` role, so it wraps to two lines in the gallery's full-width card |
| Loop-track current node | glow only | ui-design §8 loop-track: "current = periwinkle **+ halo**" — runtime draws the 58-pt node with a 76-pt halo |
| Frozen / locked tile icons | specimen tile row shows no icons although its legend names them | legend, ui-design and the C-03 play frame: lock / snowflake drawn (`size × 0.27` at `0.08` inset) |
| Frozen tile edge | CSS `border: 1.5px dashed` **plus** `inset 0 0 0 1.5px #7FB0D6` ring; browser `dashed` rhythm (dash about 3 × and gap about 2 × the stroke for strokes under 3 px — Chromium's rule as recalled, confirmed here only by eye against S-91 / C-03) | source CSS (`gen-c.mjs` / `gen-s.mjs`) — **deviation found by the parity pass and fixed**: solid `frozenRing` (3 pt border under the dashes) and `DashedRRectPainter` default dash 3 × / gap 2 × stroke (previously 5 / 4, no ring) |

---

## 9. Contract Compliance Check

* No game-logic, persistence, route, event or content contract touched (no `packages/`, `content/`, `infra/` change; `PlayTheme`, `reduce_motion.dart` and every shipped screen unchanged).
* One-glow rule is part of the components: `LimePill(glow: true)` carries the lime glow, the default `LimePill` a neutral shadow (Result CTA); `TileFace(winning)` is the single glow of the Result; star fill is non-glow (tests).
* Semantic colour separation is part of the tokens/components: lime = resolution / emphasis / primary action; periwinkle = active row rim, current node; cream = tile face (tests).
* State is never colour-only: locked = lock icon, frozen = snowflake + dashed edge, disabled link = suffix text, star = filled vs outline (tests).
* Reduced motion: press feedback (98 % scale) is skipped when `reduceMotionRequested()` (test).
* Semantics: buttons are semantic buttons with labels; `StarRow` announces "N / 3 yıldız"; `MovesCard` announces once; decorative icons are excluded (tests).
* Startup/cold-boot gate: **not triggered** — `pubspec.yaml` declares font assets only; no `main.dart`, bootstrap or init change (architecture §7.7).

---

## 10. Behavior Preserved

Every shipped F03/F04/F05/F08 screen keeps its current look and behaviour: the layer is not imported by any shipped file, so the release entry point (`lib/main.dart`) does not reach it and the F03 device suite ran unchanged on the final revision (13/13, §17).

---

## Visual Parity Evidence

Source revision for all records: HEAD 9a72481 + uncommitted working tree. Captured By: Frontend/Mobile Developer. Captured At: 2026-09-21. Target: iOS Simulator 18.6, debug build of `lib/main_gallery.dart` (`flutter build ios --simulator --debug -t lib/main_gallery.dart`), frames taken with `design/src/capture-gallery.sh` (fixed scroll offsets). All artifacts are under `ai-system/features/f00-design-foundation/design/`. Runtime frames are **real Flutter captures, not renders**; the source side is HTML/CSS (Blink) — S-91 and C-03 are generated design artefacts.

| Evidence ID | Kind | Screen / State | Viewport / Device | Artifact | Source Revision | Captured By | Captured At | Result / Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| F00.DS-RT-16-0 | runtime-screenshot | Gallery top: wordmark, colour roles, start of type roles | iPhone 16 393x852 @3x (iOS 18.6) | runtime-iphone16-0.png | HEAD 9a72481 + working tree | Frontend/Mobile Developer | 2026-09-21 | Real fonts load; wordmark `Looplet` with lime `let`; ten colour swatches (nine roles + slate). Stored at 50 % (native 1179x2556). |
| F00.DS-RT-16-640 | runtime-screenshot | Type roles, tabular figures, tile states (normal, active, winning, locked, frozen, inactive, ghost slot, rail tile) | iPhone 16 393x852 | runtime-iphone16-640.png | HEAD 9a72481 + working tree | Frontend/Mobile Developer | 2026-09-21 | All eight tile states drawn with their non-colour cues (lock, snowflake + dashed edge, dashed ghost); no clipping. |
| F00.DS-RT-16-1280 | runtime-screenshot | Controls: lime pill with glow and without, outline pill, text link + disabled link, undo pill, round/square buttons, badge, moves card, stars; stat card | iPhone 16 393x852 | runtime-iphone16-1280.png | HEAD 9a72481 + working tree | Frontend/Mobile Developer | 2026-09-21 | Glow vs neutral CTA visibly different; `HARİKA` / `OPTİMAL` / `EN İYİ` keep the dotted İ. |
| F00.DS-RT-16-1920 | runtime-screenshot | Journey glass card, loop track with current-node halo, icon block (stat card cut at the top edge; shown whole in the 1280 frame) | iPhone 16 393x852 | runtime-iphone16-1920.png | HEAD 9a72481 + working tree | Frontend/Mobile Developer | 2026-09-21 | Wave track, halo on node 5, headline wraps to two lines (deviation D3). |
| F00.DS-RT-16-2560 | runtime-screenshot | Turkish-glyph check: tiles İ I Ş Ğ Ç Ö Ü, lowercase ı ş ğ ç ö ü, `turkishUpper` output, tabular numerals, weight axis 400/500/600/700 of both families | iPhone 16 393x852 | runtime-iphone16-2560.png | HEAD 9a72481 + working tree | Frontend/Mobile Developer | 2026-09-21 | Every capital and lowercase renders correctly; `turkishUpper("harika · yeni en iyi · optimal · seviye · ılık")` renders `HARİKA · YENİ EN İYİ · OPTİMAL · SEVİYE · ILIK` — dotted and dotless cases both correct (`İLK` from `ilk` is proven by `turkish_case_test.dart`, not by this frame); weights 400→700 are visibly distinct for both fonts; `1` and `8` columns align (tabular). Frame is also the Turkish-glyph screenshot required by §7.7. |
| F00.DS-RT-16E | runtime-screenshot | All five gallery frames | iPhone 16e 390x844 (iOS 18.6) | runtime-iphone16e-sheet.png | HEAD 9a72481 + working tree | Frontend/Mobile Developer | 2026-09-21 | No overflow, clipping or wrapping regression versus iPhone 16. |
| F00.DS-RT-PROMAX | runtime-screenshot | All five gallery frames | iPhone 16 Pro Max 440x956 (iOS 18.6) | runtime-iphone16promax-sheet.png | HEAD 9a72481 + working tree | Frontend/Mobile Developer | 2026-09-21 | Scale 1.23; no overflow or clipping; proportions hold. |
| F00.DS-PARITY-TILES | parity-comparison | Tile states, wordmark: S-91 (C-03 for locked / frozen icons) beside runtime | iPhone 16 | parity-runtime-1-tiles.png | HEAD 9a72481 + working tree | Frontend/Mobile Developer | 2026-09-21 | Matches on radius, gradient, rim, glow, dimming, icons. Frozen ring and dash rhythm deviation found and fixed (§4); residual: 1× vs 3× hairlines (D6). |
| F00.DS-PARITY-CONTROLS | parity-comparison | Lime pill, outline pill, links, undo pill, restart/back, badge, moves card + stars: S-91 beside runtime | iPhone 16 | parity-runtime-2-controls.png | HEAD 9a72481 + working tree | Frontend/Mobile Developer | 2026-09-21 | Gradient, glow, radius, stroke, type weight and icon drawing match; runtime pills are full width in the gallery (D5); labels are 11 pt and targets ≥ 44 pt by design (D1). |
| F00.DS-PARITY-CARDS | parity-comparison | Stat card, journey card, loop track, icon set: S-91 beside runtime | iPhone 16 | parity-runtime-3-cards-icons.png | HEAD 9a72481 + working tree | Frontend/Mobile Developer | 2026-09-21 | Stat card, track shape and all icons match; journey headline size and halo differ by authority (D3, D4). |

**Deviations from S-91 (all intentional, sourced, or specimen-composition; none silent):**

* **D1 — corrected values.** Small labels 11 pt (specimen 10.4); touch targets ≥ 44 pt (specimen 43.9–44 px). ui-design §13 / brief.
* **D2 — specimen omits tile icons.** S-91's tile row draws no lock / snowflake though its legend names them; the runtime draws them as the C-03 play frame does (compared against C-03).
* **D3 — journey card headline.** Specimen 22 px vs role `headline` 28/1.16 (ui-design §Home). Wraps to two lines at the gallery card width; not a defect.
* **D4 — loop-track current node.** Specimen glow only; runtime halo per ui-design §8.
* **D5 — gallery composition.** Gallery tiles 60 pt × scale (sheet 76 px), pills / stat card / glass card full width (sheet: content width), icons wrap to two rows, wordmark 44 pt (shipped size will be 25). Components take size and width from parameters / parent.
* **D6 — resolution.** S-91 is a 1× specimen; the runtime is 3×. Hairlines (1–1.5 pt borders, dashes) look crisper and slightly heavier on the device. No geometry or colour difference.
* **D7 — backdrop.** `LoopBackdrop` approximates the top light and teal spill with circular radial gradients (Flutter `RadialGradient` is circular, the specimen uses ellipses), no backdrop blur (F03 §18). Visible only as a slightly different glow shape at the top and left edge.
* **Found and fixed in this delivery:** frozen tile solid ring + dash rhythm (§4) — `tile.dart`, `icons.dart`, `tokens.dart` (`frozenRing`); test added; all captures above were retaken on the fixed build.

**Not verified here (needs QA or later work):** OS text scale beyond the widget test at 1.3 (no on-device Dynamic Type render); VoiceOver on a device (semantics are proven by widget tests only); Android (out of scope, not a target); performance / profile of `LoopBackdrop` and shadows on hardware; reduced-motion on a device (press-scale suppression proven in a widget test); the design system inside a real surface (none consumes it yet). Parity is a side-by-side visual review with no pixel-diff threshold; the simulator uses Metal, which can differ slightly from a physical GPU.

---

## 13. Performance Notes

* **Bundle cost.** Assets added to the app bundle: 136,676 + 164,700 B of variable fonts + 8,882 B of licence texts = **310,258 B (~0.30 MB) uncompressed**; the fonts ship even though no surface uses them yet (declared in `pubspec.yaml`). The release IPA / AAB delta was **not measured** (TrueType compresses; expect less than the raw figure). The Dart code of the layer and the gallery is not reachable from `lib/main.dart`, so AOT tree-shaking should drop it — expected, not measured.
* No shipped runtime path changed; no cold-boot or startup measurement is needed (§9).

---

## 17. Test Evidence by Task

All commands ran on 2026-09-21 against HEAD 9a72481 + the uncommitted working tree, **after the final code change** (frozen ring and dash fix).

| Task / behaviour | Command / target | Result | What it proves |
| --- | --- | --- | --- |
| Workspace static analysis | `melos run analyze` (6 packages `dart analyze` + app `flutter analyze`) | exit 0, no issues | layer and gallery compile clean; no lint regression |
| Formatting | `melos run format:check` (`dart format --output=none --set-exit-if-changed .`) | exit 0, 170 files, 0 changed | formatted |
| Full unit/widget suite | `melos run test` | exit 0 — packages 22 + 17 + 32 + 20 + 23 + 83 = **197**; app **305** (243 pre-existing unchanged + **62 new**) | no regression; shipped suites unchanged |
| Token values, contrast, type roles (§7.1, 7.3) | `app/test/design/tokens_typography_test.dart` (12) | pass | semantic colour separation, label/ink contrast pairs (dart:math), gradient endpoints, Space Grotesk / Manrope through the `wght` axis at 500/600, tabular numerals, label 11 pt, tile glyph 38 %, `LoopScale` width/358 clamp and override |
| Turkish casing (§7.7) | `turkish_case_test.dart` (6) | pass | `HARİKA`, `İLK`, `YENİ EN İYİ`, `OPTİMAL`, `SEVİYE` from lowercase; `I↔ı`, `İ↔i` |
| Tile states never colour-only (§7.5) | `components_test.dart` — `TileFace states` (9) incl. the new frozen-ring assertion and the dash-pattern test | pass | normal / active / winning (single glow) / locked (lock icon) / frozen (ring, snowflake, dashed painter) / inactive 42 % / non-square tile / ghost slot and rail sizes; dash 3 × / gap 2 × stroke (the ratio is asserted; that it equals the browser's is judged visually) |
| Buttons, semantics, reduced motion, targets (§7.5) | `components_test.dart` — `buttons` | pass | glow vs neutral pill; semantic button + enabled/disabled flags; disabled 45 % opacity; `TextLink` suffix and 44-pt target; `GlassIconButton` ≥ 44; undo quota dots; press scale 98 % and none under reduced motion |
| Info components, wordmark, surfaces, icons | `components_test.dart` — `info components`, `surfaces`, `icons` | pass | badge, moves card 60×63 announced once, stat card 74 pt with earned star, node 38/58 + 76 halo, `StarRow` "N / 3 yıldız", wordmark colours, glass/slate/board gradients, every icon paints at 24 and 48, labelled vs unlabelled icon semantics |
| Gallery layout and font assets (§7.3, 7.6) | `components_test.dart` — `gallery layout` (real fonts loaded via `FontLoader`), `font assets` | pass | no overflow/exception at 393x852, 390x844, 440x956 and at OS text scale 1.3; both fonts and OFL texts present and declared in the font manifest |
| Shipped behaviour unchanged (§7.2) | `flutter test integration_test -d D0011CE7-6E50-4367-93FA-B323E81270BE` (iPhone 16, iOS 18.6 simulator) | `+13: All tests passed!`, exit 0 | F03 play-session device suite unchanged and green on the final revision |
| Debug gallery builds | `cd app && flutter build ios --simulator --debug -t lib/main_gallery.dart` | exit 0 | runtime capture source builds |
| Runtime parity (§7.7) | `sh design/src/capture-gallery.sh <name> <udid> <out>` on iPhone 16 `D0011CE7-…`, 16e `6DBDFD97-…`, 16 Pro Max `02FDE776-…`; boards from `design/src/parity-board.py` | 15 frames, all valid (> 500 kB), one attempt each | see *Visual Parity Evidence* |

**Mock / override limits.** (1) `flutter test` renders unloaded fonts with the Ahem test font; only the gallery layout tests load the real fonts (`FontLoader`), so the other widget tests prove structure, tokens, semantics and states — **pixel fidelity is proven only by the simulator captures**. (2) Contrast is computed from token values, not measured on rendered pixels of the gallery. (3) The runtime frames are of a debug (JIT) build on a simulator with the real status-bar clock (17:xx), not of a release build or a device.

**Tooling note (not a product change).** `Platform.environment` is empty in Dart on iOS, so an environment variable cannot carry the gallery's scroll offset; `main_gallery.dart` reads `gallery_offset` from the app container's `tmp/` (absent = top). An earlier capture attempt with the env var produced five identical top frames and was discarded.

---

## F00-FE-A11Y-REWORK — accessibility rework (2026-09-23)

> Fixes the defects `qa.md` found in F00-FE-DESIGN-SYSTEM (verdict Rejected, score 80/100, lowest dimension Accessibility 6/10): QA-01 (Dynamic Type overflow/clip), QA-02 (duplicate VoiceOver semantics), QA-03 (missing focus ring; Tech Lead ruled implement, not defer), QA-04 (polish, bundled). Source revision: this section's diff on top of commit `5f18c89` (clean tree at start; not committed by this delivery). No shipped surface, dependency, or contract changed — every change is inside `app/lib/design/` (+ its own tests).

### Impacted files

| File | Change |
| --- | --- |
| `app/lib/design/components/buttons.dart` | `_Pressable`: `excludeSemantics: true` (QA-02, single node); `FocusableActionDetector` + `Actions`/`Shortcuts` for a 2 px periwinkle focus ring and Enter/Space activation (QA-03), painted via `foregroundDecoration` so it never shifts layout; new `focusRadius` param, set per control's own shape. `LimePill`/`OutlinePill`: fixed height → `minHeight` (grow instead of clip if a label wraps, QA-01); `OutlinePill` gained horizontal/vertical padding it never had (QA-04). `UndoPill`: semantic label now states the remaining quota, not just "Geri al" (QA-02 note). |
| `app/lib/design/components/info.dart` | `LoopBadge`: `excludeSemantics: true` (QA-02). `MovesCard`, `StatCard`: fixed height → `minHeight` + `mainAxisSize: MainAxisSize.min` on the inner `Column`(s), **plus** kept `loopCappedTextScaler` on their texts (QA-01 — see "What actually fixed it" below). `LoopNode`: semantic label states done vs current, not just the bare number (QA-02 note); numeral capped with `loopCappedTextScaler`. |
| `app/lib/design/components/surfaces.dart` | `GlassCard` gained an optional `minHeight` (a floor, not a fixed size) so `StatCard` didn't have to reimplement border/padding-aware sizing itself. |
| `app/lib/design/tokens.dart` | New `loopCappedTextScaler(context)` — `MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3)` — for pieces whose width can't reflow. |
| `app/lib/design/typography.dart` | `caption` role: line height 1.0 → 1.3, so a wrapped two-line caption's lines don't touch (QA-04). `label` role: left at 1.0 — it is always a short single word inside the now-`minHeight` `MovesCard`/`StatCard` boxes and never reaches a second line (documented in the token's own doc comment, not a silent skip). |
| `app/lib/design/wordmark.dart` | `LoopletWordmark` capped with `loopCappedTextScaler`: uncapped, "Looplet" wrapped **mid-word** ("Loo" / "plet") at the largest OS sizes wherever it sits in a width-constrained header. |
| `app/test/design/components_test.dart` | +8 tests (70 total, was 62, unchanged since F00-FE-DESIGN-SYSTEM): new group `accessibility rework (F00-FE-A11Y-REWORK)`, 3 tests (single-semantics-node check across every pressable + the badge; `LoopNode` state label; focus-ring + Enter/Space activation with a `MaterialApp` host for real Tab/keyboard shortcuts); `gallery layout` group's single OS-scale check (1.3x) expanded to five (1.3/1.35/1.65/2.35/3.12x), +4; one new dedicated `MovesCard`/`StatCard`/`LoopNode`/`LoopletWordmark` stress test at the same four larger scales with their longest realistic content (`moves: 100`, `128`/`OPTİMAL`/`9★`, node `30` current, 44 pt wordmark), +1. |

### What actually fixed it (and what didn't, by itself)

The **first** attempt was `loopCappedTextScaler` alone on `MovesCard`'s fixed-height box (matching `qa.md`'s own suggested direction). It passed every widget test, including a dedicated one added for this task that stress-tested `MovesCard`/`StatCard`/`LoopNode`/`LoopletWordmark` at OS scale up to 3.12x with real fonts. It still failed on a **real device**: a runtime capture at accessibility-medium (1.65x, the required floor) showed a genuine `BOTTOM OVERFLOWED BY 1.5 PIXELS` banner on `MovesCard` (evidence: `design/rework/before-overflow-movescard-1.65x.jpg`) — real font hinting on the simulator doesn't match `flutter_test`'s rendering closely enough to trust a hand-picked ceiling for the very last pixel. This was caught only because the brief asked for a real capture at the platform floor, not because any automated check flagged it.

Fix: `MovesCard` and `StatCard` switched their **height** from fixed to `minHeight` (with `mainAxisSize: MainAxisSize.min` on the inner `Column`(s), since `Column`'s default `MainAxisSize.max` otherwise fills all available space the moment the outer constraint stops being tight — the first version of this fix rendered the cards at 600 pt tall in a test before that was added). The text-scale cap stayed **on both**: `MovesCard`'s width is fixed at 60 pt with no `Expanded`/`Row`-sharing to reflow, and `StatCard`'s three cells each have a fixed `Expanded` width share — removing the cap to test the reflow-only idea was tried and immediately reproduced a **different**, genuine overflow (`RenderFlex overflowed by 18 pixels on the right` at 2.35x, in the stress test, from an uncapped 3-digit stat value no longer fitting its cell). So both components now carry **two** protections for two different axes: the cap bounds *width* (which can't reflow), `minHeight` absorbs *height* (including the last real-device pixel a cap alone couldn't predict). `GlassCard` gained a `minHeight` option (border/padding-aware, unlike a plain `ConstrainedBox` wrapped around its child — an earlier version of the `StatCard` fix that wrapped the child directly landed at 76 pt instead of 74 because it constrained the content *inside* `GlassCard`'s 1 px border, and the border's own implicit padding then added on top; `GlassCard.minHeight` constrains the whole card, correctly reproducing the exact 74 pt at rest).

`LoopNode` and `LoopletWordmark` kept the cap alone (no `minHeight` — a circle can't grow taller than wide without breaking its own shape, and the wordmark isn't boxed): both were re-verified in the same 1.65x runtime capture with no overflow and no mid-word wrap, and their sizes are exact-shape assertions in the automated suite (`Size(38,38)` / `Size(76,76)` unchanged) that a `minHeight` swap would have broken anyway.

### Evidence

| Evidence ID | Kind | Scenario | Command / Target | Result | Provenance |
| --- | --- | --- | --- | --- | --- |
| RW-1 | automated functional | Analyzer, format, full test suite | `melos run analyze`; `dart format --output=none --set-exit-if-changed app` (workspace-wide `melos run format:check` fails on one **pre-existing, unrelated** file outside this task's scope — see Notes); `melos run test` | analyze exit 0; app-scoped format exit 0 (110 files, 0 changed); tests exit 0 — packages 197 (unchanged), app **313** (was 305 at the F00-QA-VISUAL baseline; +8, see the test-file row above) | this session, final code |
| RW-2 | automated functional | New accessibility tests pass | `flutter test test/design` | exit 0, 70/70 (see file list above for what each new test proves) | this session, final code |
| RW-3 | runtime | The real defect that automated tests missed, and its fix | `flutter build ios --simulator --debug -t lib/main_gallery.dart`; `xcrun simctl ui <udid> content_size accessibility-medium`; `capture-gallery.sh` | before: real `BOTTOM OVERFLOWED BY 1.5 PIXELS` on `MovesCard`; after: same frame and all 5 gallery sections, no overflow banner anywhere | iPhone 16, iOS 18.6 simulator; `design/rework/` (before/after JPEGs + README) |
| RW-4 | runtime | Coexistence unaffected | `flutter build ios --simulator --debug`; cold launch | shipped Home identical to the F00-QA-VISUAL baseline capture (system font, amber, Material icons) — no shipped file imports `app/lib/design` | iPhone 16 |
| RW-5 | runtime | F03 device suite unaffected | `flutter test integration_test -d <iPhone 16>` | `+13 All tests passed`, exit 0 | iPhone 16, run twice across this task (mid-way and on the final code) |

**Limits, stated plainly:** QA-02 (single semantics node) and QA-03 (focus ring, Enter/Space activation) are verified by widget tests only — the same `SemanticsNode`/`Focus` APIs a real screen reader or keyboard reads, but not a real VoiceOver speech pass or a real hardware/Bluetooth keyboard on a device; no consuming screen exists yet to test either in a real composition. `LoopNode`'s 2-digit case (`30`) and the wordmark's 44 pt case at extreme scale were verified by the widget-test suite and, at the required 1.65x floor, by the runtime capture; they were **not** individually re-verified by a *dedicated* runtime capture at 3.12x the way `MovesCard` was after its bug — the general lesson (widget-test pass ≠ real-device pass, by as little as 1.5 pt) applies to them too, in principle, though neither showed a problem at any tested scale. Bundle-size, on-device performance and Android remain unmeasured (unchanged from the original delivery, `F00-DS-UNMEASURED`).

**Note on `melos run format:check`.** It fails at the full-workspace level on `ai-system/features/f00-design-foundation/qa/src/qa_probe_main.dart` — QA's own evidence file, added in a prior commit, outside `app/` and outside this task's scope. Not touched here (altering another role's committed evidence without being asked isn't this role's call); flagged for whoever owns that path to run `dart format` on it. `app/`-scoped formatting (this task's actual surface) is clean.

## Sonraki Komut

```text
Run Tech Lead
```
