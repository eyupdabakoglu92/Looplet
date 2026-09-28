# F03 — puzzle-play-session: Frontend Delivery

> **Phase D1 — Loop Glass Play** (task F03-FE-D1, Frontend/Mobile Developer, 2026-09-27 → 2026-09-28).
>
> **Authority:** `architecture.md` §19 and the checkpoint rulings §19.8; `ui-design.md` §1–§14 (acceptance list §11.5, matrix §12a, manifest §12b) with §16 for the won moment; F00 `ui-design.md` (tokens, components).
>
> **Source revision of this delivery:** HEAD `991584c` + working tree (the harness commits it after this turn).
>
> **Rework F03-FE-D1R (2026-09-28):** see [§ F03-FE-D1R — D1 text-scale rework](#f03-fe-d1r--d1-text-scale-rework) at the end. The F03-FE-D1 text below stays as delivered, except the two records §19.10 (4) asked to correct (A11Y-16-text and NTLC-3, marked "Corrected").
>
> **History:** the pre-D1 F03 frontend reports (the original F03-FE, F03-FE9, F03-FE-WON / F03-FE-INTEG, F03-FE-CANCEL / F03-FE-REDUCEMOTION) are archived byte-for-byte in `history/f03-puzzle-play-session-2026-09-27/frontend-before-phase-d1.md`.

---

## 1. Feature Summary

Every non-`won` Play state now renders on the Selected Foundation (Direction C, Loop Glass), built from `app/lib/design`:

* **Ground and header:** `LoopBackdrop`; the drawn back chevron + `SEVİYE NN` as one ≥ 44-pt control (chevron alone without a level number); the `HAMLE` card top-right.
* **Goal:** `HEDEF DÖNGÜ` + indigo `RailTile`s; no divider.
* **Board:** `BoardCard` with cream `TileFace`s at the width-scaled geometry (card 308.5·s, tiles 52·s, gap 6.5·s).
* **Drag:** the lifted line gets the periwinkle rim + glow + deeper shadow, rails at the card edges across the line, the rest of the board at 42 %, and a wrap ghost at 30 % that fills to 100 % over the settle; all fade in and out over 90 ms. The settle overshoots to 101.5 % at 80 % of its 190 ms.
* **Special tiles:** locked = indigo + lock icon; frozen = ice + dashes + snowflake; **thaw = a 180 ms cross-fade** with the snowflake shrinking 1 → 0.6 (instant under Reduce Motion).
* **HUD:** `UndoPill` with lime quota dots and "n / 3 hak" semantics; restart as a 44-pt `GlassIconButton`; both brighten while pressed.
* **Loading:** the board card with 25 skeleton cells at the final geometry, then a 160 ms cross-fade to the tiles; no spinner.
* **Load error:** a calm glass card (level, the drawn `loopBreak` glyph, "Bu bulmaca yüklenemedi.") and the lime pill "Ana ekrana dön" → `/`.
* **F05 column tutorial (cross-feature):** a glass hint pill centred between the board and the HUD, and a periwinkle ghost ring on the tutorial cell that hides on touch-down and returns after 600 ms of idle. The pill fades out on the gated column move; the F05 gate, ack and re-show are unchanged.
* **Text scale:** every Play text role is capped at 1.3× (§19.3 (1), §19.8 (1)); the load-error pill label follows the OS scale and its column scrolls.
* **Icons:** the six Material icons are gone; no `Icon` widget is left in `app/lib` (a doc comment in `completion_panel.dart` still mentions `Icons.star` in prose).

**Shipped defects fixed:** A-1 (the hint no longer overlaps the HUD), A-2 for the board (tile and rail glyphs capped; no overflow at AX5), A-5 (frozen tile cue + real thaw), A-6 (the ghost steps aside under the finger).

**The won moment keeps its shipped look** (amber row, seam, bloom, dock, F04 panel), with one geometry adaptation the D1 header forced — the answer row now docks **onto** the goal rail (§4 row 1, §16 NTLC-1).

---

## 2. Impacted Files

**Created**
* `app/lib/play/play_layout.dart` — `PlayLayout` + `BoardGeometry` (pure D1 geometry).
* `app/lib/design/components/play_decor.dart` — `LineRail`, `TutorialGhost`, `HintPill`, `SkeletonCell`.
* `app/test/play/play_test_support.dart` — shared helpers for the D1 widget tests.
* `ai-system/features/f03-puzzle-play-session/design/src/measure-d1.swift`, `parity-d1.sh`, `pill-clearance-d1.swift`, `video-d1.swift`, `seed-sim.sh` — reproducible parity tooling.
* `ai-system/features/f03-puzzle-play-session/design/runtime-d1/` — runtime screenshots (`RT-*`), videos (`RV-*`), composites (`PC-*`) and `parity-measurements.txt`.
* `ai-system/history/f03-puzzle-play-session-2026-09-27/frontend-before-phase-d1.md` — the archived pre-D1 report (one index line added to that folder's README).

**Updated**
* Design layer (§19.8 (2)): `app/lib/design/components/tile.dart`, `components/buttons.dart`, `icons.dart`, `design.dart`.
* Play: `app/lib/play/play_session_screen.dart`, `play_strings.dart`, `won_composition.dart`, `widgets/puzzle_board.dart`, `widgets/target_rail.dart`, `widgets/board_tile.dart`, `widgets/docked_row.dart`.
* F05 overlay: `app/lib/journey/column_tutorial_overlay.dart`.
* Tests: `app/test/design/components_test.dart`, `test/journey/column_tutorial_test.dart`, `test/play/play_session_screen_test.dart` (rewritten), `test/play/play_session_runtime_test.dart`, `test/play/won_composition_test.dart`, `test/reduce_motion_test.dart`, `integration_test/play_session_test.dart`.

**Deleted**
* `app/lib/play/widgets/moves_hud.dart`, `undo_button.dart`, `restart_button.dart` (replaced by `MovesCard`, `UndoPill`, `GlassIconButton`). `play_stage.dart` stays — Home (D3) still uses it.

---

## 3. Task-to-Code Traceability

**F03-FE-D1 — Complete.** Per item of the brief's fix scope:

| # | Brief item | Code | Behaviour |
| --- | --- | --- | --- |
| 1 | Play screen | `play_session_screen.dart` (`_PlayScaffold`, `_PlayBody`, `_LoadingView`, `_LoadErrorView`, `_backControl`), `play_layout.dart`, `widgets/puzzle_board.dart`, `widgets/target_rail.dart` | ground, header (chevron + `SEVİYE NN`, `MovesCard`), goal, board card + `TileFace`, lift / rails / ghost / dim, thaw, HUD, skeleton loading, error card + `LimePill('Ana ekrana dön', icon: null)` → `/` |
| 2 | Tutorial overlay | `journey/column_tutorial_overlay.dart` | hint pill in the board → HUD band (§19.8 (3) fallback on — §19), ghost ring + `LoopIcon.upDown` on cell (2,2), hide on touch-down (120 ms), return after 600 ms idle (160 ms), pill + ghost fade (160 ms) on the gated move; ack written at once; announced once |
| 3 | Design layer | `tile.dart` (glyph cap; `iconScale`), `buttons.dart` (pressed fill .14 / edge .18; spent dot dims 120 ms; `LoopBackButton`), `icons.dart` (`LoopIcon.loopBreak`), `play_decor.dart` (rails, ghost ring, hint pill, skeleton cell) | each with component tests; no token value or dependency changed |
| 4 | Motion | `puzzle_board.dart` (`_lift` 90 ms ease-out / ease-in, settle keyframes 101.5 % at 80 %, ghost 30 → 100 %, bounce 140 ms, `_thaw` 180 ms), `column_tutorial_overlay.dart`, `_PlayBody._appear` (160 ms) | every path has its reduced branch (`reduceMotionRequested()`); the shift and bounce keep 190 / 140 ms with an ease-out under reduced motion |
| 5 | Strings, semantics | `play_strings.dart` (`HEDEF DÖNGÜ`, `SEVİYE %02d`, `Bu bulmaca yüklenemedi.`, `Ana ekrana dön`, `Yükleniyor`, `Hedef döngü`, "Geri, Seviye 26") | back "Geri, Seviye 26"; rail one node "Hedef döngü: TARİH"; `MovesCard` "HAMLE 3"; undo "…, 2 / 3 hak"; hint announced once, ghost excluded; loading announced after 300 ms |
| 6 | Icons | `chevron_left_rounded` → `LoopIcon.back`; `undo_rounded` → `LoopIcon.undo`; `refresh_rounded` → `LoopIcon.restart`; `push_pin` → `LoopIcon.lock` (also in the won-only `BoardTile`); `unfold_more_rounded` → `LoopIcon.upDown`; `error_outline_rounded` → `LoopIcon.loopBreak` | `grep -rn "Icons\." app/lib` finds only the prose mention in `completion_panel.dart` |
| 7 | Won moment | `puzzle_board.dart` (won branch: `BoardTile(winning: true)`, seam, bloom, `_GhostCell`, 12 % recede on `TileFace`), `docked_row.dart` (+ `gap`), `won_composition.dart` (dock onto the goal), `_PlayBody` won layers (unchanged timeline, panel host, SafeArea stack) | timeline, T0 + 600 ms rule, density concessions, Retry / Next / Close unchanged; dock geometry adapted (§4, NTLC-1) |

---

## 4. Authority Reconciliation

| Conflict | Winning authority | Applied decision | Downstream impact |
| --- | --- | --- | --- |
| §16.3 dock rule (row 12 pt under the goal, panel top ≥ 0.36 H) vs the D1 header, which moved the rail tiles' bottom to ≈ 33 % of H | §16.3 "do not let the panel cover the row" (its own escape clause: stop and raise NTLC) | The answer row docks **onto** the goal: its tiles centre on the rail tiles, which fade out beneath it (and back on Retry); the panel keeps the shipped 0.36 H cap, floored 16 pt under the docked unit. Raised as NTLC-1 | Won moment only (legacy until D2). Measured in §16 |
| ui-design §5 "the load-error text follows the OS scale to AX5" vs §19.3 (1) "display / headline roles use `loopCappedTextScaler`" | §19.3 (1) (role rule) + `LoopText.headline`'s documented cap | The error headline is capped at 1.3× (it would break mid-word at AX5); the pill label follows the OS scale (`LimePill` reflows) and the column scrolls | None |
| Architecture §8 "the counter *may* update on settle" + ui-design §5 "`HAMLE` swaps to +1 at the settle" vs the shipped count at release | ui-design §5 | `HAMLE` shows `moveCount − 1` while `animatingShift`; the engine count is unchanged | Display only; AC5 no-double-count tests unchanged and green |
| Shipped Direction-A HUD dimming to 55 % during every drag / settle vs the D1 prototype (HUD steady; undo on at the settle) | ui-design §5 / MP-D1 | The HUD keeps its look through a drag and a settle; presses during input lock are still dropped by the controller (`canUndo` / `canRestart`); `won` keeps the 40 % dim (§16.2) | None |
| F05's Direction-A re-prompt pulse (hint text scale 1.06 on a row move / 6 s idle) vs the D1 motion table (the ghost returns after 600 ms idle) | D1 handoff (visual authority moved to F03, §19.5; F05 §9 amended) | Pulse removed; the returning ghost is the re-prompt | F05 behaviour (trigger, gate, ack, re-show) unchanged |
| ui-design §5 "existing 120 ms grid swap (unchanged)" — no such swap exists in the code (`PlayTheme.swapDuration` is unused) | "unchanged" | Undo / restart still swap the grid instantly; the spent quota dot now dims over 120 ms (instant when reduced) | Informational (NTLC-5) |
| §19.8 (3) hint-pill fallback | §19.8 (3) | Device run measured 3.93 pt above the pill (16e, 1.3× cap) → `ColumnTutorialOverlay.compactPillAbove115 = true` (padding 7·s → 5·s above 1.15×); re-measured 6.27 / 6.37 pt | None; the pre-agreed fallback |

---

## 5. Components

| Component | Where | Responsibility |
| --- | --- | --- |
| `PlayLayout`, `BoardGeometry` | `play/play_layout.dart` | Pure D1 geometry: `s = min(W/358, H/717)` (= W/358 on the supported phones), `e = H − 717 s`, every rect of §6; the cell math shared by the board, the won layers and the tests |
| `PuzzleBoard` | `play/widgets/puzzle_board.dart` | Card + tiles, lift (rim / rails / 42 % rest), moving line with wrap ghosts clipped to the card interior (±5·s, open on the cross axis), settle / bounce, thaw cross-fade, skeleton cross-fade, legacy won branch. Drag logic unchanged |
| `TargetRail` | `play/widgets/target_rail.dart` | Caption + `RailTile`s from the caption's glyph-box top; one semantics node; `tileOpacity` for the won dock |
| `ColumnTutorialOverlay` | `journey/column_tutorial_overlay.dart` | Ghost ring + hint pill; hide / return / exit motion; announce once |
| `LoopBackButton` *(design layer)* | `design/components/buttons.dart` | Chevron + optional capped caps label in one `_Pressable` (≥ 44 pt, focus ring, 0.98 press) |
| `LineRail`, `TutorialGhost`, `HintPill`, `SkeletonCell` *(design layer)* | `design/components/play_decor.dart` | The §19.8 (2) decoration widgets; static — Play drives their motion |
| `TileFace` / `RailTile` *(design layer, edited)* | `design/components/tile.dart` | Glyph takes `loopCappedTextScaler`; `TileFace.iconScale` for the thaw |
| `GlassIconButton` / `UndoPill` *(design layer, edited)* | `design/components/buttons.dart` | Pressed fill .075 → .14, edge .07 → .18 (also under reduced motion); spent dot dims over 120 ms |
| `LoopIcon.loopBreak` *(design layer)* | `design/icons.dart` | The open ring + exclamation, stroke 1.8, dot 2.6 |
| `BoardTile`, `DockedAnswerRow` *(legacy, won only)* | `play/widgets/` | Amber winning row and docked unit; the pin glyph is now the drawn lock; the docked row takes the board's gap |

---

## 6. Screens

`/play` (route and args unchanged):

| State | Header / back | Notes |
| --- | --- | --- |
| Loading (provider or controller still resolving) | chevron + `SEVİYE NN` from the route args; back pops to the caller | 25 skeleton cells in the final card rect; no rail, `HAMLE` or HUD; "Yükleniyor" announced after 300 ms |
| Loaded — idle / tracking / animating | chevron + `SEVİYE NN` (chevron alone for the debug set and Daily); system back and the edge swipe behave the same (pop, snapshot kept, no confirmation) | tutorial overlay on levels 4–6 until acknowledged |
| Loaded — `won` (T0 onward) | back hidden (unchanged) | scrim, docked row on the goal, F04 panel in the safe area |
| Load error | chevron alone (the level is on the card); pops to the caller; system back the same | "Ana ekrana dön" → `context.go('/')` |

---

## 7. State Management

* **Controller** (`PlaySessionController`) — unchanged; still the only authority for phase, moves, quota and persistence.
* **Board-local** — `_shift`, `_bounce` (`AnimationBehavior.preserve`: state feedback keeps its duration under Android "remove animations"), `_win`, `_lift` (+ `_liftLine`, kept while fading out), `_thaw` (+ the set of thawing cells, taken by comparing statuses across `commitShift`).
* **Overlay-local** — `_loop`, `_ghost`, `_exit`, the 600 ms return timer.
* **Screen-local** — `_appear` (loading → loaded), the won `_timeline` / `_retire` (unchanged), the tutorial exit timer in `_LoadedPlaySessionState`.
* **Display derivations** — `HAMLE` = `moveCount − 1` while `animatingShift`; undo is enabled when not `won`, quota > 0 and the displayed count > 0.

---

## 9. Contract Compliance Check

| Area | Status | Note |
| --- | --- | --- |
| Screen / route contract (§13) | Preserved | `/play`, `PlaySessionArgs`, `_popToCaller`, no new route |
| Backend response / event mapping | Not Applicable | client-only |
| Error mapping | Extended | same trigger (setup provider error); new card, Turkish copy, no exception text |
| UI state / store state consistency | Preserved | controller authoritative; only the `HAMLE` display lags to the settle (≤ 190 ms) |
| Navigation / back / header behaviour | Extended | new chevron + label; same pop semantics; hidden in `won`; chevron alone without a level |
| Async authority / lifecycle / boundaries | Preserved | pointer cancel, `paused` mid-drag / mid-animation, input lock, persistence write-through — suites and integration green |

---

## 10. Behavior Preserved

* **Gesture → move:** threshold 18 px, tie band 0.15 → horizontal, one cell per move, first pointer only, off-plate release, OS pointer cancel = no move.
* **Input lock (AC5):** gestures during `animatingShift` / `animatingBounce` / `won` dropped, never queued — `play_session_runtime_test` §17.2 and the integration group 2 are green.
* **Undo / restart (AC6 / AC7):** quota 3, no prompt at 0, restart refills and has no dialog.
* **Persistence:** write-through after every settle / undo / restart; resume after a kill; the tampered `thawedFrozenCells` cache is re-derived, not trusted.
* **Won moment:** T0 + 600 ms before any panel or scrim; the reduced timeline (≥ 300 ms hold, fade); density concessions; Retry fades the won layers and re-lights the board; Next Level / Close unchanged. The docked row is still one `RepaintBoundary` layer.
* **F05 tutorial:** shown iff Journey level 4–6 and the `kv` ack is unset; satisfied only by a committed column-axis drag; the ack is persisted at that moment; it re-shows after a quit before the gate (AC4, AC11).
* **Reduce motion:** both OS signals (`reduceMotion`, `disableAnimations`) still read through `reduceMotionRequested()`.

---

## 11. UX Decisions

* **Hierarchy per §6 rhythm:** header band → goal + board as one unit → a quiet HUD. Nothing sits between undo and restart (no F09 hint line).
* **One accent per meaning:** periwinkle for the lifted line, rails, ghost ring and focus ring; lime only for quota dots, the sparkle and the error pill. The lifted line is never lime (a widget test asserts no `winning` face during a drag).
* **Pivots in a lifted line keep their own face** (locked / frozen, no rim) — they are the tiles that stay (engine rule). The handoff has no render of this case.
* **The wrap ghost is the active face at 30 %,** so it becomes the rimmed first tile at the settle (MP-D1); the static render D1-01 draws the ghost without the rim — at 30 % the difference is marginal.
* **Loading:** identical card rect before and after (asserted); the skeleton cross-fades under the arriving tiles (160 ms).
* **Error:** calm glass, periwinkle `loopBreak`, one lime action, the chevron; no red, no raw text.
* **Accessibility:** 44-pt targets (back hit box 16 pt from the edge, 8 pt past the label); the 2 px focus ring on back, undo, restart and the error pill (`_Pressable`); the capped text keeps the fixed geometry while VoiceOver reads the full labels.
* **Premium-rubric self-check (advisory):** the runtime matches the D1 renders to ≤ 0.83 pt on the iPhone 16 and ≤ 0.67 pt on the D1 16e / Pro Max renders, token colours within ΔE2000 1.5; no fail condition known. The independent score is QA's.

---

## Visual Parity Evidence

**Common provenance:** iOS Simulator 18.6 — iPhone 16 `D0011CE7-6E50-4367-93FA-B323E81270BE` (393×852 @3x), iPhone 16e `6DBDFD97-7BF7-4051-914C-76609DDF8697` (390×844 @3x), iPhone 16 Pro Max `02FDE776-C263-4DAB-A16A-76902AC18189` (440×956 @3x); debug build of `lib/main.dart` at HEAD `991584c` + the F03-FE-D1 working tree ("991584c + WT" in the table); captured by the Frontend/Mobile Developer. States were reached through the real app: `design/src/seed-sim.sh` sets `journey_progress` / the `active_session` snapshot / the tutorial `kv` ack, then Home CONTINUE opens the level. Stills are `xcrun simctl io … screenshot`; held gestures use the simulator touch-path with a delayed background screenshot; videos are `xcrun simctl io … recordVideo`, trimmed and re-encoded (588×1276, 1.5 Mbps) with `design/src/video-d1.swift`, which also extracted the thaw and reduced-motion frames. The two AX5 tutorial records were retaken after the §19.8 (3) fallback was switched on; that one flag does not affect the other records (it only acts on the pill above 1.15×). Artifacts are in `features/f03-puzzle-play-session/design/runtime-d1/`.

| Evidence ID | Kind | Screen / State | Viewport / Device | Artifact | Source Revision | Captured By | Captured At | Result / Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| RT-16-00 | runtime-screenshot | Play · idle (L5, 0 moves; undo disabled) | 393×852 iPhone 16 | design/runtime-d1/RT-16-00-idle-L5.png | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:20 | matches D1-00 (PC-00) |
| RT-16-lift | runtime-screenshot | Play · row 2 lifted, held ~0.55 stride (L5 after R1) | 393×852 iPhone 16 | design/runtime-d1/RT-16-lift-row-L5.png | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:04 | rim + glow, side rails, rest 42 %, wrap ghost "T" at 30 % clipped; vs D1-M-lift-t0400 / S-02 (PC-lift) |
| RT-16-01 | runtime-screenshot | Play · column 2 drag (L4 after R0 L3) | 393×852 iPhone 16 | design/runtime-d1/RT-16-01-play-column-drag.png | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:05 | rails top + bottom; ghost enters from the top; vs D1-01 (PC-01) |
| RT-16-05 | runtime-screenshot | Play · locked + frozen (L26, `SEVİYE 26`) | 393×852 iPhone 16 | design/runtime-d1/RT-16-05-play-locked-frozen-L26.png | 991584c + WT | Frontend/Mobile Developer | 2026-09-27 23:58 | lock icons + indigo; snowflakes + dashes + ice; vs D1-05 (PC-05) |
| RT-16-06 | runtime-screenshot | Play · thaw L23 ("SAAT"): T0 / T0+83 / T0+168 ms, plus before / after and a tile sheet | 393×852 iPhone 16 | design/runtime-d1/RT-16-06-thaw-L23-t000.png, …-t090.png, …-t180.png, …-before.jpg, …-after.jpg, …-tile-sheet.jpg | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:07 | frames from RV-16-thaw (≈ 50 fps); the ice face fades, the snowflake shrinks, cream at the end; at T0 the rest is still dimmed by the lift fade-out (spec) |
| RT-16-02 | runtime-screenshot | HUD · undo, 2 left (L5 after R1) | 393×852 iPhone 16 | design/runtime-d1/RT-16-02-hud-undo-two-left.png | 991584c + WT | Frontend/Mobile Developer | 2026-09-27 23:55 | two lime dots + one 25 %; vs D1-02 (PC-02) |
| RT-16-03 | runtime-screenshot | HUD · undo exhausted (L5 after R1 L3 D0 R4, quota 0) | 393×852 iPhone 16 | design/runtime-d1/RT-16-03-hud-undo-exhausted.png | 991584c + WT | Frontend/Mobile Developer | 2026-09-27 23:56 | pill at 55 %, three dim dots; vs D1-03 (PC-03) |
| RT-16-04 | runtime-screenshot | HUD · restart pressed (held) | 393×852 iPhone 16 | design/runtime-d1/RT-16-04-hud-restart-pressed.png | 991584c + WT | Frontend/Mobile Developer | 2026-09-27 23:57 | fill .14 / edge .18 while held; the release restarted with no dialog (HAMLE 3 → 0); vs D1-04 (PC-04) |
| RT-16-11 | runtime-screenshot | Play · loading → loaded (first frame under the route push) | 393×852 iPhone 16 | design/runtime-d1/RT-16-11-loading-crossfade.png | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:09 | skeleton cells cross-fading to tiles in the same card rect, no spinner; loading itself lasts < 300 ms under the push, so no clean still exists (the rect identity is asserted by a widget test); vs D1-11 (PC-11) |
| RT-16-07 | runtime-screenshot | Play · load error (level 07 asset corrupted in the installed bundle, restored after) | 393×852 iPhone 16 | design/runtime-d1/RT-16-07-play-load-error.png, RT-16-07b-load-error-pill-home.jpg | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:12 | card + `loopBreak` + lime pill; the pill went Home; vs D1-07 (PC-07) |
| RT-16-08 | runtime-screenshot | Tutorial · pill above the HUD (L4) | 393×852 iPhone 16 | design/runtime-d1/RT-16-08-tutorial-hud.png | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:00 | clearance 9.9 / 9.7 pt (pill-clearance-d1); vs D1-08 (PC-08) |
| RT-16-09 | runtime-screenshot | Tutorial · column held — ghost hidden, pill stays | 393×852 iPhone 16 | design/runtime-d1/RT-16-09-tutorial-drag-ghost-hidden.png | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:00 | vs D1-09 (PC-09) |
| RT-16-debug | runtime-screenshot | Play · debug set (no level) — chevron alone | 393×852 iPhone 16 | design/runtime-d1/RT-16-debug-smoke01-idle.jpg | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:13 | §19.8 (5) |
| RT-16-won | runtime-screenshot | Won · at rest, Perfect (smoke-tr-01) — default and AX5 | 393×852 iPhone 16 | design/runtime-d1/RT-16-won-docked-on-goal-perfect.jpg, …-ax5.jpg | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:13–00:14 | NTLC-1 evidence: row on the goal, panel regular density, clear of the row. AX5: the legacy F04 panel overflows exactly as in the audit's AUD capture `cur-a11y-ax5-result.png` (pre-existing A-2, D2 scope) |
| RT-16e-00 | runtime-screenshot | Play · idle (L5) | 390×844 iPhone 16e | design/runtime-d1/RT-16e-00-idle-L5.png | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:15 | vs S-v-16e-play-idle (PC-v16e-idle) |
| RT-16e-01 | runtime-screenshot | Play · column 2 drag (L4 after R0 L3) | 390×844 iPhone 16e | design/runtime-d1/RT-16e-01-play-column-drag.png | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:16 | vs D1-v-16e-play-column-drag (PC-v16e-01) |
| RT-16e-08 | runtime-screenshot | Tutorial (L4) | 390×844 iPhone 16e | design/runtime-d1/RT-16e-08-tutorial-hud.png | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:17 | clearance 8.9 / 9.0 pt; vs D1-v-16e-tutorial-hud (PC-v16e-08) |
| RT-pm-00 | runtime-screenshot | Play · idle (L5) | 440×956 iPhone 16 Pro Max | design/runtime-d1/RT-promax-00-idle-L5.png | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:15 | vs S-v-promax-play-idle (PC-vpm-idle) |
| RT-pm-01 | runtime-screenshot | Play · column 2 drag (L4 after R0 L3) | 440×956 iPhone 16 Pro Max | design/runtime-d1/RT-promax-01-play-column-drag.jpg | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:16 | no Pro Max render of this state exists; geometry per §6 (widget test) |
| RT-pm-08 | runtime-screenshot | Tutorial (L4) | 440×956 iPhone 16 Pro Max | design/runtime-d1/RT-promax-08-tutorial-hud.png | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:17 | clearance 11.9 / 12.0 pt; vs D1-v-promax-tutorial-hud (PC-vpm-08) |
| PC-D1 | parity-comparison | every pair above: render \| runtime \| difference, plus measured edges and colour patches | 393×852, 390×844, 440×956 | design/runtime-d1/PC-*.jpg, design/runtime-d1/parity-measurements.txt (from design/src/parity-d1.sh + measure-d1.swift) | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:27 | **Layout:** ≤ 0.83 pt against every D1 render on all three devices (16 features per pair, flat-edge probes); exceptions are explained in the deviation list below. **Colour:** token surfaces within ΔE2000 1.5 (tile, rail, `HAMLE`, undo, board card, ground bottom / left); one gradient patch at 3.32–3.35 (see list) |
| RV-16-lift | runtime-video | row lift + settle, then column lift + settle (L5 after R1) | 393×852 iPhone 16 | design/runtime-d1/RV-16-row-and-column-lift.mp4 | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:10 | lift fade-in, tracking with the 30 % ghost, settle (ghost → 100 %), rim / rails / dim fade-out |
| RV-16-thaw | runtime-video | thaw L23 (the U4 that forms "SAAT") | 393×852 iPhone 16 | design/runtime-d1/RV-16-thaw.mp4 | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:07 | 180 ms cross-fade after the settle; the visible change ends ≈ T0 + 130 ms (the curve front-loads), last pixel change at T0 + 168 ms |
| RV-16-tutorial | runtime-video | tutorial ghost loop → touch-down hides it → row move → returns after idle → column move → pill + ghost fade out | 393×852 iPhone 16 | design/runtime-d1/RV-16-tutorial-ghost.mp4 | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:02 | the ghost never plays under the finger (A-6); undo stays visible and usable |
| RV-16-rm | runtime-video | Reduce Motion ON: row lift, then the thawing column move | 393×852 iPhone 16 | design/runtime-d1/RV-16-reduced-motion-lift-thaw.mp4 (+ RT-16-rm-*.jpg frames) | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:12 | the rest dims to 42 % and back in one frame; the thaw is complete in the settle frame; the shift keeps its 190 ms ease-out |
| A11Y-16-text | accessibility | OS text default / xxxLarge / AX5 on L26 | 393×852 iPhone 16 | design/runtime-d1/RT-16-05-play-locked-frozen-L26.png, RT-16-10-a11y-xxxl-L26.jpg, RT-16-10-a11y-ax5-L26.png | 991584c + WT | Frontend/Mobile Developer | 2026-09-27 23:58 | every Play text at the 1.3× cap from xxxL up; no clipping or overlap; the `HAMLE` label sits ≈ 1.7 pt inside the card's bottom border at the cap (as in D1-10; F00 `MovesCard`, NTLC-3); vs D1-10 (PC-10). **Corrected 2026-09-28 (F03-FE-D1R, §19.10 (4)):** "no clipping or overlap" held only at the card's centre line. From xxL up the label's outer letters crossed the card's bottom corner arcs by up to 4.76 pt on the device (F03-QA-D1-01), and the load-error headline broke off its full stop from xxxL (F03-QA-D1-02). Both fixed and re-measured in RT-D1R-* / A11Y-D1R-* |
| A11Y-tutorial-ax5 | accessibility | Tutorial at AX5 (1.3× cap, fallback on) | 393×852 iPhone 16; 390×844 iPhone 16e | design/runtime-d1/RT-16-10b-a11y-ax5-tutorial.png, RT-16e-10b-a11y-ax5-tutorial.png | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:27 | two lines, sparkle hidden; clearance 7.23 / 6.99 pt (16) and 6.27 / 6.37 pt (16e) — before the fallback the 16e measured 3.93 / 4.04 pt; vs D1-10b and D1-v-16e-tutorial-text-ax5-capped (PC-10b, PC-v16e-10b) |
| A11Y-rm | accessibility | Reduce Motion on and off | 393×852 iPhone 16 | RV-16-rm (on); RV-16-lift, RV-16-thaw, RV-16-tutorial (off) | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 00:02–00:12 | set with `simctl spawn … defaults write com.apple.Accessibility ReduceMotionEnabled`, app relaunched; restored to 0 afterwards |
| A11Y-focus | accessibility | Keyboard focus ring (D1-12) | — | test/design/components_test.dart "QA-03: focus ring …" | 991584c + WT | Frontend/Mobile Developer | 2026-09-28 | **not captured at runtime:** this host cannot inject hardware Tab keys into the simulator (pasted `\t` and System Events keystrokes did not reach it). Covered by the widget test; runtime check left to QA |
| AND | accessibility | Android | — | — | — | — | — | not run — stated limit (ANDROID-CI-EVIDENCE) |

**Deviation list** (layout ±2 pt and colour ΔE 3 of the token, F00 ui-design §14):

1. **Top-right ground light, ΔE2000 3.32–3.35** (render `42,51,97` vs runtime `33,41,83` at (W − 20, 40·s)). The render draws the design's elliptical radial light; F00 `LoopBackdrop` approximates it with a circular gradient (documented in `surfaces.dart`, accepted in F00 QA). It is a gradient, not a token surface, and D1 may not change the design layer beyond §19.8 (2). Every token patch is ≤ 1.5.
2. **Active rim drawn inside vs outside the tile.** The render uses `box-shadow: 0 0 0 2px` (outside); `TileFace.active` draws a 2 px `Border` (inside) — visible as thin double outlines in the difference panels of PC-lift / PC-01 / PC-09. F00 component, unchanged.
3. **`HAMLE` label ≈ 2 pt lower than in the render.** F00 `MovesCard` sets the counter on the font's default line height; the render sets both lines at `line-height: 1`. The card rect itself matches (≤ 0.33 pt).
4. **Restart square vs the F00 S-v Pro Max render: +3.17 pt** (PC-vpm-idle). S-v predates the D1 decision "restart is a 44-pt square" (ui-design §2); against the D1 Pro Max render it is 0.00–0.33 pt.
5. **"undo pill top" probe in the AX5 tutorial pairs: 2.00 / 2.83 pt.** With the §19.8 (3) fallback the hint pill is 4.4 pt shorter than in the renders, so its bottom edge enters the probe's ±8 pt window; the undo pill's left edge matches, and widget tests assert its rect to 0.01 pt.
6. **Thaw T0 frame:** the runtime rest of the board is still at 42 % at T0 (the lift fades out over the 90 ms after the settle, per §5); the render's thaw demo has no drag in front of it.
7. **Text rasterisation:** Blink vs Flutter anti-aliasing and ≈ ±0.5 pt baseline differences; the status bar is the real one, not the render's mock.
8. **Tutorial ghost phase** differs between the stills (it loops).

---

## 12. Implemented Files

* **`app/lib/play/play_layout.dart`** (new) — `PlayLayout(Size)`: `s`, `left`, `extra`, `e1`; `backIcon`, `backHitLeft/Top/Inset`, `movesCard`, `captionTop`, `railTop/Bottom`, `boardRect`, `hudTop`, `undoRect`, `restartRect`, `hintBand`. `BoardGeometry`: card 308.5 × 307.5·s, `pad`, `gap`, `tile`, `stride`, `rowWidth`, `cellOrigin/Rect/Center`, `cellAt`, `forWidth`.
* **`app/lib/play/play_session_screen.dart`** — rewritten around `_PlayScaffold` (`AnnotatedRegion` light status bar, `LoopBackdrop`, `LayoutBuilder` → `PlayLayout` → `LoopScale`). `_PlayBody`: absolute D1 layout, `_appear`, won layers kept (now in a `SafeArea` stack, measured against the rail tiles, `DockedAnswerRow.gap`), `_WonPanelHost` unchanged. `_LoadingView`, `_LoadErrorView`, `_backControl`. Tutorial: ack on satisfaction, removal after `ColumnTutorialOverlay.exitDuration`.
* **`app/lib/play/widgets/puzzle_board.dart`** — rewritten render (see §5); `geometry` + `appear` parameters replace `boardSize`; the gesture handlers are the shipped ones (`cellAt` from `BoardGeometry`).
* **`app/lib/play/widgets/target_rail.dart`** — rewritten (caption + `RailTile`s, one semantics node, `tileOpacity`).
* **`app/lib/play/won_composition.dart`** — `WonGeometry.compute(railTopLocal, railBottomLocal, …)`: dock tiles centred on the rail tiles; `panelTopGlobal = min(max(0.36 H, dock + U + 16), stackBottom)`; row-scale fallback only for frames too short for the unit (float tolerance 1e-6). `WonTimeline` unchanged.
* **`app/lib/play/widgets/docked_row.dart`** — `gap` parameter (default `PlayTheme.tileGap`).
* **`app/lib/play/widgets/board_tile.dart`** — doc: won-only; `Icons.push_pin` → `LoopIconView(LoopIcon.lock)` (same size / alpha).
* **`app/lib/play/play_strings.dart`** — `targetLabel` → `HEDEF DÖNGÜ`; new `targetSemantics`, `levelCaps`, `levelWord`, `backHome`, `loading`; `loadFailed` → `Bu bulmaca yüklenemedi.`; `levelLabel(n)` (two digits), `backSemantics(level)`; English table mirrored.
* **`app/lib/journey/column_tutorial_overlay.dart`** — rewritten visuals (no dim layer, no Material icon); `layout` parameter; motion and timer logic per §4; `compactPillAbove115 = true` (§19.8 (3)).
* **`app/lib/design/components/tile.dart`** — glyph `textScaler: loopCappedTextScaler` on `TileFace` and `RailTile`; `TileFace.iconScale`.
* **`app/lib/design/components/buttons.dart`** — `_Pressable.builder(pressed)`; pressed fill / edge on `GlassIconButton` and `UndoPill`; dots as `AnimatedContainer` (120 ms, zero when reduced); new `LoopBackButton`.
* **`app/lib/design/icons.dart`** — `LoopIcon.loopBreak` (+ stroke 1.8).
* **`app/lib/design/components/play_decor.dart`** (new) — `LineRail`, `TutorialGhost`, `HintPill`, `SkeletonCell`; exported from `design.dart`.
* **Deleted:** `moves_hud.dart`, `undo_button.dart`, `restart_button.dart`.
* **Tests:** see §17.

---

## 13. Performance Notes

* The rest-of-board dim is **one group `Opacity`** over the static tiles (one layer), never a per-tile or whole-board opacity; at 1.0 it adds no layer.
* The lift cross-fade stacks two faces only for the 5–7 moving tiles and only during the 90 ms fades; the thaw stacks two faces only for the thawing cell(s) for 180 ms.
* The moving line is one `ClipRect` + `Transform.translate` over a `Stack` (as shipped). As before, the board rebuilds on every animation tick through its `AnimatedBuilder`; nothing new rebuilds per frame outside the board.
* Won: the docked row stays a single `RepaintBoundary` layer; no backdrop blur anywhere.
* Measured behaviour on the simulator is fluid; a mid-tier Android frame-rate check remains with QA (Android not run).

---

## 14. Assumptions

* **Safe-area insets used in the device-geometry won tests:** 16e 47 / 34, 16 59 / 34, Pro Max 62 / 34.
* **The widget tests with real fonts are representative of device text metrics** — confirmed where both exist: the hint pill measured 4.2 pt (test) vs 3.93 pt (device, including the border's anti-aliasing) on the 16e at the cap; after the fallback 6.4 pt (test) vs 6.27 / 6.37 pt (device).
* **Loading states are sub-300 ms** on the simulator; the evidence relies on the cross-fade frame plus the rect-identity test.

---

## 16. Needs Tech Lead Clarification

1. **NTLC-1 — the won dock moved onto the goal (deviation from §16.3 / §16.5 (1)).**
   * **Why:** with the D1 header the rail tiles end at 281.9 pt (393×852), so §16.3's free zone `[rail + 12, 0.36 H − 16]` is −3.2 pt on the 16, −3.5 on the 16e and +0.1 on the Pro Max — no room for a 63-pt unit.
   * **First attempt — floor the panel under the goal:** panel top = max(0.36 H, rail + 12 + U + 16). With real fonts and device insets the Perfect panel at 1.3× is 473.7 pt at tight density against 440.1 (16e) / 445.1 pt (16) of room. Every §16.3 concession combined (row scale 0.8, gaps −4 pt) still leaves 5–13 pt short, so the panel would cover the row.
   * **Implemented:** the row docks onto the goal — its tiles centre on the rail tiles, which fade out beneath it (1 − dock progress; back on Retry). The panel keeps its shipped 0.36 H cap and regular density at 1.0× on all three phones (compact at 1.3× on the 16 / 16e). All §16.5 rules hold except (1)'s "W.top ≥ dividerY + 12", replaced by "the answer tiles centre on the goal tiles". Tests: 20 rect tests (rows 0–4 × Perfect / 2★ × 390 / 440), 12 device-geometry tests (3 devices × 1.0 / 1.3 × Perfect / 2★, real fonts, insets), timeline, reduced motion, Retry. Runtime: RT-16-won.
   * **Decision needed:** accept for the D1 hybrid period (D2 replaces the whole moment), or name another fallback.
2. **NTLC-2 — design-layer edits beyond the §19.8 (2) list.** They implement accepted handoff decisions; no token value or dependency changed; each has component tests. Please confirm:
   * `LoopBackButton` — ui-design §7 specifies the header as `LoopIconView` + caption "in one `_Pressable`", and `_Pressable` is library-private;
   * `TileFace.iconScale` — the §5 thaw shrinks the snowflake 1 → 0.6;
   * `UndoPill`'s spent dot as an `AnimatedContainer` — §5 "the spent quota dot dims over 120 ms".
3. **NTLC-3 (informational) — `HAMLE` label at the 1.3× cap** sits ≈ 1.7 pt inside the card's bottom border on the device. There is no clipping or overlap, and it matches D1-10. `MovesCard` keeps its values per ui-design §13. A 2–3 pt larger minimum height at the cap would add margin if you want it.
   * **Corrected 2026-09-28 (F03-FE-D1R, §19.10 (4)):** the 1.7 pt was measured only at the card's bottom centre. The label is almost as wide as the card, and its outer letters crossed the 22·s corner arcs by 4.76 pt at AX5 (−5.07 pt in the real-font widget test), so there *was* clipping / overlap. A 2–3 pt taller card would not have been enough: the fix needed 13·s. Fixed under the §19.10 (1) allowance (see the F03-FE-D1R section).
4. **NTLC-4 (informational) — the repo-wide `melos run format:check` fails** on a pre-existing QA artefact, `ai-system/features/f00-design-foundation/qa/src/qa_probe_main.dart` (unchanged since 3647cef, outside `app/`). `app/`, `packages/` and `tools/` are formatted (0 changed). Not touched here.
5. **NTLC-5 (informational) — the "existing 120 ms grid swap"** of ui-design §5 does not exist in the shipped code, so undo / restart still swap instantly.
6. **NTLC-6 (informational) — the legacy won moment / F04 panel at AX5** overflows and covers the screen exactly as in the Phase C audit capture (pre-existing A-2, D2 scope). The §16.5 (6) scope (1.0 and 1.3×) holds.

---

## 17. Test Evidence by Task

**Gates on the final tree** (2026-09-28, macOS host, Flutter 3.32.8):

| Command | Target | Result |
| --- | --- | --- |
| `melos run analyze` | all packages + `flutter analyze` (app) | SUCCESS — "No issues found!" |
| `dart format --output=none --set-exit-if-changed app packages tools` | Dart code | 172 files, 0 changed, exit 0 |
| `melos run format:check` | whole repo | FAILED only on the pre-existing `ai-system/…/qa_probe_main.dart` (NTLC-4) |
| `melos run test` | packages + app | SUCCESS — app **405** passed; core 22, content 17, dictionary 32, authoring 25, engine 83, solver 23 |
| `flutter test integration_test -d D0011CE7-6E50-4367-93FA-B323E81270BE` | iPhone 16 simulator, iOS 18.6 | **13 / 13 passed** (groups 1–4, incl. `paused` mid-drag / mid-animation) |

**Mocks / overrides:** in-memory Drift databases; `wordValidatorProvider` / `playSessionSetupProvider` overridden with `NeverValidWordValidator` or a set validator; Journey assets from a map source (tutorial tests); a `GoRouter` with a `/` home for navigation tests. The integration suite runs the real app code on the simulator with in-memory databases.

| Task / behaviour | Test (file → name) | Type | Proves |
| --- | --- | --- | --- |
| §11.5 (1)–(4) geometry on 3 devices | `test/play/play_session_screen_test.dart` → "D1 layout … every rect sits on the width-scaled geometry" ×3; "393×852 matches the handoff table to 0.15 pt" | widget | board card, tiles, chevron (25, 96)·s, back hit box ≥ 44 from x 16, `HAMLE` card (273.5, 75)·s ≥ 60 × 63·s, label ≥ 12 pt, rail tiles, undo, restart 44 pt centred on the pill; 71.1-pt board → HUD gap |
| Header binding and back | same file → "SEVİYE NN is bound …; back pops to /", "two digits below 10", "no level number → chevron alone", "system back behaves like the chevron" | widget | `SEVİYE 26` / `07`; "Geri, Seviye 26"; pop to `/`; the debug set shows no label |
| Loading → loaded | same → "loading → loaded: the board card does not move; no spinner; 'Yükleniyor' only after 300 ms" | widget | identical card rect, 25 skeleton cells, no rail / `HAMLE` / HUD while loading, announcement timing |
| Load error | same → "calm error card", "error pill goes home (/)", "system back returns to /", "reflows at AX5" | widget | copy, `loopBreak`, no raw exception text, pill → `/`, no exception at 3.12× |
| Lift / rails / dim / ghost | same → "a lifted row …", "a lifted column …", "the lift fades in over 90 ms; reduced motion: instant" | widget | 7 active faces (5 + 2 ghosts), no lime; rails on the side / top-bottom card edges; rest 0.42; ghosts 0.30; 90 ms fade; instant when reduced |
| `HAMLE` at the settle | same → "HAMLE changes at the settle, not at release" | widget | 0 mid-settle, 1 after |
| Undo quota + semantics (AC6) | same → "undo: lime quota dots + 'n / 3 hak' …" | widget | disabled at 0 moves and at quota 0; "Geri al, 3/2/1/0 / 3 hak"; no dialog |
| Restart (AC7) | same → "restart is a 44 pt glass square with no dialog" | widget | `LoopIcon.restart`, 44 × 44, "Baştan", reset without dialog |
| Special tiles | same → "special tiles: locked = indigo + lock, frozen = ice + snowflake" | widget | states and icons |
| Thaw (A-5) | same → "a 180 ms cross-fade; the snowflake shrinks as it fades", "reduced motion: the thaw is instant at the settle" | widget | real thaw through the engine rule (set validator "SAAT"); at +90 ms: veil 0–1, icon scale 0.6–1; gone at +200 ms; instant when reduced |
| Text cap (A-2) | same → "{390×844, 393×852} at OS text {1.0, 1.35, 3.12}×: every Play text is capped …" (6) | widget, real fonts | every `Text` on Play resolves to min(scale, 1.3); glyphs inside their tiles; no exception |
| Glyph cap in the design layer | `test/design/components_test.dart` → "TileFace and RailTile glyphs are capped at 1.3× — no overflow at AX5 (3.12) on a 390-pt width (A-2)" | widget | scaler 1.3; `Ş İ Ğ` inside their tiles |
| Pressed fill | same file → "GlassIconButton / UndoPill brighten fill .075 → .14 and edge .07 → .18 while pressed — also under reduced motion" | widget | colours while held, 0.98 vs 1.0 scale |
| Dot dim, back button, decorations, `loopBreak` | same file → "UndoPill: a spent dot dims over 120 ms …", "LoopBackButton …", "LineRail …", "TutorialGhost …", "HintPill at {1.0, 1.15, 1.2, 1.3}x …", "HintPill padding …", "SkeletonCell …", "TileFace iconScale …", icons "loopBreak paints …", "every icon has a designed stroke weight" (13 icons) | widget | the §19.8 (2) additions |
| Tutorial pill vs board / HUD (A-1) | `test/journey/column_tutorial_test.dart` → "{390×844, 393×852, 440×956}, OS text {1.0, 1.3, 3.12}x: the pill sits between the board and the HUD with ≥ 4 pt clearance" (9) | widget, real fonts | ≥ 4 pt each side (fallback on: 6.4 / 7.1 / 8.5 pt at the cap), centred, no overlap with undo / restart, sparkle only ≤ 1.15× |
| Tutorial HUD usable | same → "undo and restart stay usable under the tutorial" | widget | row move → undo → restart with the overlay up |
| Ghost hide / return (A-6) | same → "the ghost hides on touch-down and returns after 600 ms idle" | widget | 0 after touch-down (+130 ms), 0 while dragging and < 600 ms idle, 1 after the timer + 160 ms fade; overlay kept after a row move |
| Pill exit + ack timing | same → "the first column move fades the pill out over 160 ms" | widget | opacity 0–1 mid-fade; ack persisted before the fade ends; overlay gone after it |
| Announcement | same → "the hint is announced once; the ghost is excluded" | widget | one `announce` message; `ExcludeSemantics` on the ghost |
| F05 gate / ack / re-show (AC4 / AC11) | same → the four pre-existing tests (rewired to `BoardGeometry`) | widget | unchanged behaviour |
| Won moment (§16 + NTLC-1) | `test/play/won_composition_test.dart` → timeline (4), `WonGeometry` (5), §16.5 at 390 / 440 × rows 0–4 × Perfect / 2★ (20), 393 row 4, text 1.3, F04 variants, T0 + 600 ms, reduced motion ×2, "D1 dock on the device geometry" (12) | unit + widget | tiles centred on the goal, rail tiles at opacity 0 at rest, panel ≥ 0.36 H and ≥ 16 pt under the unit, buttons ≥ 44 pt |
| AC1–AC11 runtime scenarios | `test/play/play_session_runtime_test.dart` (updated helpers) and `integration_test/play_session_test.dart` | widget + device integration | gesture wiring on 2 sizes, no double count, resume + tampered cache (now read through `TileFace`), lifecycle |
| Reduce-motion reads | `test/reduce_motion_test.dart` (board built with `BoardGeometry`) | widget | seam static under both OS signals |

---

## 18. Test Notes

* **Device flows exercised by hand on the simulator** (see Visual Parity Evidence): Home CONTINUE → Play for L4 / L5 / L7 / L23 / L26; row, column and thawing moves; undo quota states; the held restart press; the tutorial hiding under the finger, returning after idle and exiting on the column move; the load error's pill to Home; the chevron-only debug header; a Perfect win at rest at default and AX5.
* **Restored afterwards:** content size `large` on the 16 and 16e, Reduce Motion 0 on the 16, the level-07 asset in the 16's bundle. The simulators keep seeded test progress.
* **Not proven here:** the keyboard focus ring at runtime (A11Y-focus), Android (stated limit), and a physical-device frame-rate check.

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** F03-FE-D1 — the Loop Glass Play (every non-`won` state), the F05 tutorial re-skin, the §19.8 (2) design-layer additions, the icon swap, strings and semantics, tests, and runtime Visual Parity Evidence on the iPhone 16 / 16e / Pro Max (F03.D1-PARITY).
* **Remaining Tasks:** the Tech Lead checkpoint (Ready for QA), then F03-QA-D1.
* **Blockers:** none. NTLC-1 (won dock onto the goal) and NTLC-2 (three design-layer edits) need a ruling at the checkpoint; NTLC-3 … NTLC-6 are informational.
* **Status Suggestion:** Needs Tech Lead Review — checkpoint → Ready for QA.

---

## 19. Sonraki Komut

```text
Run Tech Lead
```

---

# F03-FE-D1R — D1 text-scale rework

> **Task:** F03-FE-D1R (Frontend/Mobile Developer, 2026-09-28). **Contract:** `architecture.md` §19.10 (rulings on F03-QA-D1); §19.3, §19.8 and §19.9 still apply.
>
> **Source revision:** HEAD `97c700e` + working tree (the harness commits it after this turn).

## 1. Feature Summary

The two blocking F03-QA-D1 findings are fixed; no behaviour changed.

* **F03-QA-D1-01 — `HAMLE` label over the card's corners.** `MovesCard` now grows **below** its label above the default text size, by up to 13·s at the 1.3× cap. The counter and the label keep their positions, and the card keeps its width and its (273.5, 75)·s anchor. On the device the label ink is now **≥ 2.98 pt inside the rounded card, corner arcs included**, at every OS size from large to AX5 on all three phones. Before the fix it was −4.76 pt at AX5 on the 16.
* **F03-QA-D1-02 — the load-error headline's orphaned full stop.** The headline no longer has the render's 230·s column limit and uses the card's inner width (257·s). At the 1.3× cap it now breaks as "Bu bulmaca" / "yüklenemedi." — two lines, only between words, on all three phones up to AX5.
* **Default size unchanged:** at `large` the card is still 60 × 63·s and every glyph is where it was. The error headline is pixel-identical to the accepted D1 capture RT-16-07, and the `HAMLE` label matches QA's `large` capture to the pixel.
* **Records corrected** (§19.10 (4)): A11Y-16-text and NTLC-3 above.

**Why QA saw more than my F03-FE-D1 measurement:** the counter's style has no line height of its own. Under the app's Material 3 theme it inherits the ambient `DefaultTextStyle` height (1.43), which puts the label ≈ 4 pt lower than in a bare widget tree. The D1 checks measured the label's layout box at the card centre, not its glyph ink against the corner arcs. The new tests measure glyph ink, in the app's theme, against the rounded rect, and they reproduce QA's device capture to within 0.5 pt (−5.07 pt vs −4.76 pt at AX5 on the 393).

## 2. Impacted Files

**Updated**
* `app/lib/design/components/info.dart` — `MovesCard` (design-layer allowance §19.10 (1); F00 stays Done).
* `app/lib/play/play_session_screen.dart` — `_LoadErrorView` headline.
* `app/test/play/play_test_support.dart` — shared `kPlayDevices` and `kOsTextScales`.
* `ai-system/features/f03-puzzle-play-session/frontend.md` — this section; the A11Y-16-text and NTLC-3 corrections.

**Created**
* `app/test/design/text_ink_support.dart` — glyph-ink and line-break probes (helpers, not a suite).
* `app/test/design/moves_card_ink_test.dart` — 39 tests.
* `app/test/play/load_error_headline_test.dart` — 28 tests.
* `ai-system/features/f03-puzzle-play-session/design/src/sweep-d1r.sh` — OS text-size sweep + capture.
* `ai-system/features/f03-puzzle-play-session/design/src/measure-d1r.swift` — card-ink and headline-line measurement on screenshots.
* `ai-system/features/f03-puzzle-play-session/design/src/compose-d1r.swift` — before / after composites.
* `ai-system/features/f03-puzzle-play-session/design/runtime-d1r/` — 30 runtime screenshots, 3 composites, `measurements-d1r.txt`.

No token value, `LoopText` role, font, tracking, dependency, route, gesture, timing or persistence change.

## 3. Task-to-Code Traceability

**F03-FE-D1R — Complete.**

| # | Brief item | Code | Behaviour |
| --- | --- | --- | --- |
| 1 | `MovesCard` rect rule (§19.10 (1)) | `info.dart` → `MovesCard.capGrowth = 13`; `build` reads the label's capped scale `t` (non-linear scalers included) and adds `grow = 13·s · clamp((t − 1) / 0.3, 0, 1)` both to `minHeight` and as bottom padding | The column lays out exactly as before in the top part; the card lengthens below the label only. 0 at 1.0×, 13·s at ≥ 1.3×. Width 60·s, anchor unchanged. Card height on the 16: 69.3 → 74.7 → 80.3 → 85.0 pt (large → xL → xxL → xxxL / AX5) |
| 2 | Headline word-boundary rule (§19.10 (2)) | `play_session_screen.dart` → `_LoadErrorView`: the `ConstrainedBox(maxWidth: 230 * s)` around the headline is removed; the `Text` keeps `LoopText.headline` + `loopCappedTextScaler` | The headline fills the card's inner column (257·s); the 1.3× cap stays (§19.9 (3)) |
| 3 | `frontend.md` corrections (§19.10 (4)) | A11Y-16-text row and NTLC-3 above, marked "Corrected" | — |

## 9. Contract Compliance Check

| Area | Status | Note |
| --- | --- | --- |
| Screen / route contract (§13) | Preserved | no route, arg or navigation change |
| Backend response / event mapping | Not Applicable | client-only |
| Error mapping | Preserved | same trigger, copy and single action; only the headline's width changed |
| UI state / store state consistency | Preserved | display-only layout change |
| Navigation / back / header behaviour | Preserved | the header row is untouched; the card only lengthens downward (≥ 39 pt clear of `HEDEF DÖNGÜ` at the cap on the device) |
| Async authority / lifecycle / boundaries | Preserved | no controller or lifecycle code touched |
| §19.10 (1) limits | Preserved | width 60·s, anchor (273.5, 75)·s, downward growth only, ≥ 8 pt above the caption, no token / role / font / tracking change |
| §19.6 non-goals | Preserved | no behaviour change; multi-touch (F03-MULTITOUCH-FIRST-POINTER) untouched; won moment / F04 panel untouched |

## 10. Behavior Preserved

* **Default size (D1-00 / D1-05 / D1-07):** the widget tests assert the card is exactly 60 × 63·s at 1.0× on all three widths. On the device the `HAMLE` label ink at `large` (x 310.67–356.00, y 134.67–143.33 pt) equals QA's `QA-16-17-L26-text-large` measurement. The error headline ink at `large` equals RT-16-07 to the pixel on both lines. The parity probe vs D1-05 is unchanged: max 0.67 pt, `HAMLE` card top / left +0.33 pt.
* **Other `MovesCard` consumers:** only Play and the debug gallery (§19.10 (1)); the gallery gets the same growth at large OS text.
* **Error screen below the headline:** the pill and scroll behaviour are unchanged. At the cap the card is one line shorter, so the pill moves up (e.g. 619.5 → 596.5 pt on the 393); it still reflows to two lines at AX5.
* **Everything else in D1** (board, rail, HUD, tutorial, won moment, motion) is outside the diff. The full suite and integration_test are green.

## 11. UX Decisions

* **Grow below, not re-centre.** Centring the content in a taller card would have moved the numeral and needed about twice the growth, because the label only gains half of it. Keeping the column where it is leaves the top of the card unchanged, which keeps the header's rhythm with `SEVİYE NN` intact. The bottom margin grows exactly where the wide label needs clearance from the arcs.
* **Growth tracks the label's own scale** (`capped.scale(labelSize) / labelSize`), so Android's non-linear font scaling gets the growth its label actually needs.
* **13·s is measured, not guessed:** 9·s left 1.05 pt at the cap in the app's text context; 13·s gives ≥ 2.83 pt in the widget test and ≥ 2.98 pt on the device.
* **Headline:** the full inner width is the smallest change that keeps the cap (§19.9 (3)) and the role size. At the cap the longest line is 250 pt of the 282-pt column on the 393 (279.7 of 309 on the Pro Max).
* **Premium-rubric self-check (advisory):** the two fail-condition items are gone at runtime. At AX5 the taller card reads as a deliberate container, not a stretched one (composite PC-D1R-hamle-sweep-16). The independent score is QA's.

## Visual Parity Evidence

**Common provenance:** iOS Simulator 18.6 — iPhone 16 `D0011CE7-6E50-4367-93FA-B323E81270BE` (393×852 @3x), iPhone 16e `6DBDFD97-7BF7-4051-914C-76609DDF8697` (390×844 @3x), iPhone 16 Pro Max `02FDE776-C263-4DAB-A16A-76902AC18189` (440×956 @3x).
* **Build:** `flutter build ios --simulator --debug` of HEAD `97c700e` + the F03-FE-D1R working tree ("97c700e + WT"), installed on all three; captured by the Frontend/Mobile Developer on 2026-09-28, 12:21–12:27.
* **Reaching the states:** `design/src/seed-sim.sh <udid> 26 - 1` → Home DEVAM ET for L26. For the error, `journey-tr-07.json` in each installed bundle was overwritten with invalid JSON (backed up first), then `seed-sim.sh <udid> 7 - 1` → DEVAM ET.
* **Sweep:** `design/src/sweep-d1r.sh` sets `xcrun simctl ui <udid> content_size` to large / extra-large / extra-extra-large / extra-extra-extra-large / accessibility-extra-extra-extra-large and takes `xcrun simctl io … screenshot` 2 s after each change (live Dynamic Type update, no relaunch).
* **Measurement:** `design/src/measure-d1r.swift` (log `design/runtime-d1r/measurements-d1r.txt`):
  * **Card:** scans the card's bottom edge. Every pixel above luma 90 / 120 inside the card counts as glyph ink, excluding the dim 1-pt border ring. It reports each glyph group's smallest inset from the rounded rect of radius 22·s, arcs included, as a signed distance.
  * **Headline:** white ink (luma > 200, blue > 180) split into lines by empty rows; a line narrower than 12 pt is flagged as punctuation-only.
  * **Negative check of the tool:** QA's pre-rework captures give −4.76 pt for the label (QA-16-16) and 3 lines with a flagged 6.33-pt "." line (QA-16-28).
* **Restored afterwards:** the three `journey-tr-07.json` copies (SHA-1 `2fef993c2391…` = repo, verified) and content size `large` on all three simulators. The simulators keep seeded test progress.

| Evidence ID | Kind | Screen / State | Viewport / Device | Artifact | Source Revision | Captured By | Captured At | Result / Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| RT-D1R-16-L26 | runtime-screenshot | Play L26 at large / xL / xxL / xxxL / AX5 | 393×852 iPhone 16 | design/runtime-d1r/RT-16-L26-{large,extra-large,extra-extra-large,extra-extra-extra-large,accessibility-extra-extra-extra-large}.png | 97c700e + WT | Frontend/Mobile Developer | 2026-09-28 12:22 | label ink inset **3.00 / 3.35 / 3.32 / 2.98 / 2.98 pt** (luma > 90); numeral ≥ 11.33 pt; card 69.3 → 85.0 pt; `HEDEF DÖNGÜ` ≥ 40.3 pt below the card |
| RT-D1R-16e-L26 | runtime-screenshot | same | 390×844 iPhone 16e | design/runtime-d1r/RT-16e-L26-*.png | 97c700e + WT | Frontend/Mobile Developer | 2026-09-28 12:24 | label **3.23 / 3.53 / 3.41 / 3.22 / 3.22 pt**; numeral ≥ 11.63; caption gap ≥ 39.3 pt |
| RT-D1R-pm-L26 | runtime-screenshot | same | 440×956 iPhone 16 Pro Max | design/runtime-d1r/RT-pm-L26-*.png | 97c700e + WT | Frontend/Mobile Developer | 2026-09-28 12:24 | label **3.79 / 4.22 / 3.78 / 3.27 / 3.27 pt**; numeral ≥ 12.82; caption gap ≥ 46.3 pt |
| RT-D1R-16-err | runtime-screenshot | Load error L07 at large … AX5 | 393×852 iPhone 16 | design/runtime-d1r/RT-16-L07-error-*.png | 97c700e + WT | Frontend/Mobile Developer | 2026-09-28 12:26 | **2 lines at every size**, no punctuation-only line; widest line 250.0 pt of the 282.1-pt inner column (x 55.4–337.6) |
| RT-D1R-16e-err | runtime-screenshot | same | 390×844 iPhone 16e | design/runtime-d1r/RT-16e-L07-error-*.png | 97c700e + WT | Frontend/Mobile Developer | 2026-09-28 12:26 | 2 lines at every size; widest 248.0 pt |
| RT-D1R-pm-err | runtime-screenshot | same | 440×956 iPhone 16 Pro Max | design/runtime-d1r/RT-pm-L07-error-*.png | 97c700e + WT | Frontend/Mobile Developer | 2026-09-28 12:27 | 2 lines at every size; widest 279.7 pt |
| PC-D1R-hamle | parity-comparison | `HAMLE` card at AX5, before (QA-16-16) \| after; plus the large → AX5 sweep on the 16 | 393×852 | design/runtime-d1r/PC-D1R-hamle-ax5-before-after.jpg, PC-D1R-hamle-sweep-16.jpg | 97c700e + WT | Frontend/Mobile Developer | 2026-09-28 12:30 | label glyphs unchanged in place (x 304.67–361.67, y 138.67–150.00 before and after); the card now extends 14.3 pt further below them |
| PC-D1R-error | parity-comparison | load error at AX5, before (QA-16-28) \| after | 393×852 | design/runtime-d1r/PC-D1R-error-ax5-before-after.jpg | 97c700e + WT | Frontend/Mobile Developer | 2026-09-28 12:30 | "yüklenemedi" / "." → "yüklenemedi." |
| PC-D1R-default | parity-comparison | default size vs D1-05 (L26) and vs the accepted D1 capture of D1-07 | 393×852 | design/runtime-d1r/measurements-d1r.txt (measure-d1 section); RT-16-L07-error-large.png vs design/runtime-d1/RT-16-07-play-load-error.png | 97c700e + WT | Frontend/Mobile Developer | 2026-09-28 12:31 | vs D1-05: max 0.67 pt, `HAMLE` card top / left +0.33 pt (same as PC-05). Error headline ink identical to RT-16-07 (both lines, to the pixel), so D1-07 parity carries over. measure-d1's Play probes do not apply to the error screen, so that pair is left out of the log |
| A11Y-D1R-text | accessibility | the text sweep above (content sizes large → AX5) | 3 devices | RT-D1R-* | 97c700e + WT | Frontend/Mobile Developer | 2026-09-28 12:22–12:27 | both §19.10 rules hold at every size on every device. Informational: the D1-10 probe "HAMLE card left" reads −2.50 pt at AX5 (was −0.83) because the probe's row now meets the straight side instead of the arc; the card's left edge is 300.24 pt = 273.5·s |
| AND | accessibility | Android | — | — | — | — | — | not run — stated limit (ANDROID-CI-EVIDENCE); the growth follows Android's non-linear scaler by construction (§11) |

## 12. Implemented Files

* **`app/lib/design/components/info.dart`** — `MovesCard`: new `static const double capGrowth = 13`; `build` computes `t` from `loopCappedTextScaler(context).scale(labelSize) / labelSize`, then `grow`, and applies `minHeight: 63·s + grow` and `padding: EdgeInsets.only(bottom: grow)`; one `capped` scaler shared by both texts. The doc comment records §19.10 (1) and the inherited line height.
* **`app/lib/play/play_session_screen.dart`** — `_LoadErrorView`: the headline `Text` is no longer wrapped in `ConstrainedBox(maxWidth: 230 * s)`; a comment gives the reason.
* **`app/test/design/text_ink_support.dart`** (new):
  * `inkPixels` repaints a laid-out `RenderParagraph` through a `TextPainter` with the same text, scaler and constraints. It asserts the same height, rasterises at 4 px / pt, and returns every non-zero-alpha pixel in global coordinates.
  * `inkInset` gives the largest deflation of an `RRect` that still contains every ink pixel, all four corners of each (binary search to 0.01 pt).
  * `inkOutside`, `inkBounds`.
  * `lineTexts` assigns each character to a line via `getBoxesForSelection`.
  * `lineBreakFaults` flags word-less lines and breaks not at a space.
* **`app/test/design/moves_card_ink_test.dart`** (new) — see §17.
* **`app/test/play/load_error_headline_test.dart`** (new) — see §17.
* **`app/test/play/play_test_support.dart`** — `kPlayDevices`, `kOsTextScales` (large, 1.059, xL, 1.176, xxL, 1.3, xxxL, AX1, AX5).

## 16. Needs Tech Lead Clarification

1. **NTLC-D1R-1 (informational) — MOVESCARD-CAP-MARGIN.** §19.10 (1) says it closes with this rework. `workflow-follow-ups.md` is not in a delivery role's write scope, so the entry is left for the Tech Lead to close.
2. **NTLC-D1R-2 (informational) — `MovesCard` takes its counter line height from the ambient theme.** `LoopText.counter` sets no `height`, so the card's inner layout depends on the surrounding `DefaultTextStyle`: Material 3 body 1.43 on Play, nothing in a bare tree. The Play look is the accepted one, and changing the role is outside §19.10 (1), so it is left as is. The new tests pin the Play context, and the doc comment says so. If the gallery or another host renders the card under a different text theme, its inner spacing differs, though the rect rule still holds there because the growth only adds room. Worth a look at the next design-layer touch or F10's global theme.

## 17. Test Evidence by Task

**Gates on the final tree** (2026-09-28, macOS host, Flutter 3.32.8):

| Command | Target | Result |
| --- | --- | --- |
| `melos run analyze` | all packages + `flutter analyze` (app) | SUCCESS — "No issues found!" |
| `dart format --output=none --set-exit-if-changed app packages tools` | Dart code | 175 files, 0 changed, exit 0 |
| `melos run test` | packages + app | SUCCESS — app **472** passed (405 + 39 + 28 new); core 22, content 17, dictionary 32, authoring 25, engine 83, solver 23 |
| `flutter test integration_test -d D0011CE7-6E50-4367-93FA-B323E81270BE` | iPhone 16 simulator, iOS 18.6 | **13 / 13 passed** (12:20) |

**Failing first** — each new suite was run against the HEAD version of the file it covers (`git show HEAD:<file> > <file>`, run, working copy restored; `git diff --stat` confirmed the restore):

| Suite | Against HEAD `info.dart` / `play_session_screen.dart` | Against the fix |
| --- | --- | --- |
| `moves_card_ink_test.dart` (39) | **33 failed**: every scale above 1.0 on the three widths (27 component + 6 Play). The 6 default-size cases pass, as they should. Label inset at the cap −4.98 / −5.07 / −5.88 pt (390 / 393 / 440); at AX5 on the 393 the label ink is x 304.6–362.1, y 138.5–150.0 pt, QA's device box to within 0.5 pt | 39 passed |
| `load_error_headline_test.dart` (28) | **12 failed**: 1.3 / 1.353 / 1.647 / 3.118 on the three widths, lines "Bu bulmaca " / "yüklenemedi" / "."; 1.0–1.235 passed (QA: xxL fine) | 28 passed |

| Task / behaviour | Test (file → name) | Type | Proves |
| --- | --- | --- | --- |
| §19.10 (1) rect rule, component | `moves_card_ink_test.dart` → "MovesCard glyph ink at every OS text size (§19.10 (1)) {390, 393, 440} pt, OS text {1.0 … 3.118}x: …" (27) | widget, real fonts, app theme (`MaterialApp` + `Scaffold`, Material 3 as in `main.dart`) | for labels `HAMLE` / `MOVES` × moves 0 / 8 / 48 / 99 / 188: numeral and label ink ≥ 2 pt inside the rounded rect, arcs included; top-left = `PlayLayout.movesCard`; width 60·s; height ≥ 63·s, exactly 63·s at 1.0; `captionTop − bottom ≥ 8` |
| §19.10 (1) on Play | same file → "MovesCard on the Play screen (§19.10 (1)) {390, 393, 440} pt, OS text {1.0, 1.235, 1.3, 3.118}x: …" (12) | widget, real fonts, real Play screen (`bootPlay`) | anchor, width, 63·s at 1.0, ≥ 8 pt above the `HEDEF DÖNGÜ` text box, ink ≥ 2 pt inside |
| §19.10 (2) word breaks | `load_error_headline_test.dart` → "{390, 393, 440} pt, OS text {1.0 … 3.118}x: … breaks only between words, capped at 1.3×" (27) | widget, real fonts, Play screen in its error state (setup throws `FormatException`, Journey L07) | no exception; scaler = min(scale, 1.3); the lines rebuild the text; no word-less line, every break at a space; ink inside the card's inner column (±1 pt) |
| The rule check itself | same file → "the rule check itself: a punctuation-only line and a split word are faults; breaks at spaces are not" | unit | the checker rejects "yüklenemedi" / "." (2 faults) and "yük" / "lenemedi." (1), accepts real breaks |
| No regression | the existing 405 app tests, incl. `components_test` "MovesCard: 60 x 63 at the reference …", `play_session_screen_test` layout / text-cap / error groups | widget | unchanged and green |
| Runtime | Visual Parity Evidence above; integration 13 / 13 | runtime | both rules on 3 devices × 5 sizes; the tool's own negative check on QA's captures |

**Isolation:** widget tests use in-memory Drift and the overridden setup provider (as in D1); ink is rasterised by the test engine, and the on-device probe (below) showed its glyph metrics match iOS CoreText to within 0.25 pt for these roles. The runtime captures run the real app with the real asset pipeline (one deliberately corrupted asset for the error state).

## 18. Test Notes

* **Entry-path matrix (retro bugfix):**
  * **`HAMLE` card:** every `/play` entry — Home CONTINUE (L26 seeded), resume after a kill (same widget), Result Retry / Next (same screen) — renders the one `MovesCard` at `PlayLayout.movesCard`. There is no state or persistence in the fix: it is a pure function of the OS text scale and `s`. It was verified live across Dynamic Type changes without a relaunch (the sweep).
  * **Load error:** reached only through the setup provider's error branch. Tests use a throwing setup for Journey L07; the device uses a corrupted bundled asset. The daily-source path (`unsupported source`) shares `_LoadErrorView` and its existing tests stay green.
* **On-device check of the test metrics:** during the investigation a throwaway `integration_test` probe ran the ink measurement on the iPhone 16 simulator. Its insets matched the widget test within 0.25 pt for the same widget tree, which ruled out a font-metric gap. The real gap was the inherited Material line height (NTLC-D1R-2). The probe was deleted and is not part of the suite.
* **Not proven here:** Android (stated limit); a physical device.

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE) — F03-FE-D1R

* **Completed Tasks:** F03-FE-D1R — the `MovesCard` rect rule and the error-headline word-boundary rule, failing-first tests (39 + 28), the frontend.md corrections, runtime text sweep on the iPhone 16 / 16e / Pro Max (F03.D1R-PARITY).
* **Remaining Tasks:** the Tech Lead checkpoint (negative run per rule; gate → Ready for QA), then F03-QA-D1R.
* **Blockers:** none. NTLC-D1R-1 / -2 are informational.
* **Status Suggestion:** Needs Tech Lead Review.

---

## 19. Sonraki Komut (F03-FE-D1R)

```text
Run Tech Lead
```
