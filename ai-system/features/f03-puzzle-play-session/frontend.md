# F03 — puzzle-play-session: Frontend Delivery

> **Phase D2 — the won moment and the full-screen result** (task F03-FE-D2, Frontend/Mobile Developer, 2026-09-28).
>
> **Authority:** `architecture.md` §20 with the §20.7 rulings and corrections C1–C3; `ui-design.md` §16 (motion §16.5, layout §16.6, variants §16.8, handoff §16.11, acceptance list §16.11.1, matrix §16.12a); the `design/D2-*` renders and `design/src/D2-motion-prototype*.html`.
>
> **Source revision of this delivery:** HEAD `051c64c` + working tree ("051c64c + WT"; the harness commits it after this turn).
>
> **History:** the D1 / D1R frontend report is archived byte-for-byte in `history/f03-puzzle-play-session-2026-09-28/frontend-before-phase-d2.md` (SHA-1 `c1338d45…`); the pre-D1 reports in `history/f03-puzzle-play-session-2026-09-27/frontend-before-phase-d1.md`.

---

## 1. Feature Summary

The legacy won moment (amber row docked on the goal rail + the F04 bottom sheet with Close) is replaced by the D2 design:

* **Win sequence (0–600 ms, board only):** the winning row fills lime left → right (30 ms stagger, 90 ms per tile) over each tile's own face — locked / frozen faces, icons and dashes go with their tile's fill (C-11); one elliptical lime bloom (100–450); board and all Play chrome dim to 50 % (0–200). Nothing outside the board is visible before T0 + 600.
* **Transition (600–940):** Play chrome and board fade out 600–720; the answer row glides as one unit 600–840 on curve `E`, morphing width, height, radius and glyph from the board tile to the laid-out result slot; the result bands fade and rise in (back / badge / headline 700–860, subtitle 740–900, stars + stats 780–940, pill + link 820–940). **Rest at 940** — input unlocks; the earned stars then pop 940 / 1050 / 1160 (done 1300).
* **Full-screen result** (`ResultView`, an in-screen state of `/play`, no route, no Close): fixed back button, reserved badge row (`HARİKA` / `YENİ EN İYİ`, C-4 precedence), capped two-line display headline, free data subtitle, the answer tiles with their lime radial, `StarRow`, `StatCard` (`SEN · OPTİMAL · EN İYİ`), one flat `LimePill`, one `TextLink`; the no-optimal line; scroll only above the 1.3× cap under a fixed band.
* **Retry transition A** ("the answer returns to the goal"): the row flies into the goal rail 0–300 while the result drops out 0–140; Play fades in on the restarted grid 160–360 (the board card rises 10·s); rest at 360.
* **Reduced motion** for all three motions exactly per §16.5 (row lime and static at T0, 160 ms cross-fade 300–460, content 460–660; retry dip 0–80 / 80–160).
* **Rating read (C1):** stars and `HARİKA` from the synchronous result; `EN İYİ` `—` and no `YENİ EN İYİ` until the read-back resolves; a late badge fades into its reserved row with no layout shift; a failed write keeps `—` and no badge.
* Persistence, controller timing, routes, engine and scoring are unchanged (§20.3 (3), §20.5).

**Gates (this working tree):** `melos run analyze` SUCCESS · `dart format --set-exit-if-changed app packages tools` 0 changed · `melos run test` SUCCESS (app **503 passed**, was 472; packages 22 / 17 / 32 / 23 / 25 / 83) · `flutter test integration_test` on the iPhone 16 simulator **13 / 13, exit 0** (re-run on the final code). Runtime evidence on the three canonical simulators: § Visual Parity Evidence. F03.D2-PARITY → PASS with the stated limits.

---

## 2. Impacted Files

**Created**
* `app/lib/play/win_timeline.dart` — `WinTimeline` (regular / reduced), `RetryTimeline`, `ResultBand`, curve `E`.
* `app/lib/play/widgets/result_view.dart` — `ResultView`, `ResultMotion`.
* `app/lib/play/widgets/travelling_tile.dart` — the filling / gliding / flying answer tile.
* `app/lib/play/widgets/lime_glow.dart` — the elliptical bloom and result radial.
* `app/lib/rating/result_model.dart` — `ResultModel` (the §16.8 variant table as a pure function), `ResultBadge`, `ResultNext`.
* `app/lib/design/components/result_decor.dart` — `ScrollBand` (design-layer addition, §20.7 (6)).
* Tests: `app/test/play/won_sequence_test.dart`, `app/test/rating/result_view_test.dart`, `app/test/design/result_components_test.dart`.
* Evidence tooling: `design/src/capture-d2.sh`, `video-d2.swift`, `timing-d2.py`, `parity-d2.swift`, `parity-d2.sh`; evidence in `design/runtime-d2/`.
* `history/f03-puzzle-play-session-2026-09-28/frontend-before-phase-d2.md` (+ README entry).

**Updated**
* `app/lib/play/play_session_screen.dart` — `_PlayBody` rewritten as the `won` orchestrator; the tutorial overlay is passed into the Play group.
* `app/lib/play/widgets/puzzle_board.dart` — the legacy won rendering removed; `hiddenRow`.
* `app/lib/design/components/tile.dart` (`TileFace.answer`, `glyphSize`), `info.dart` (`StarRow.revealMs`), `design.dart` (export) — design-layer additions, §20.7 (6).
* `app/lib/play/play_strings.dart`, `app/lib/rating/rating_strings.dart` — D2 copy; legacy strings removed.
* `app/lib/play/play_theme.dart` — the won-only members D2 made dead removed (sheet colours, scrim, `winDuration`, `wonControlsOpacity`, `completionWord`, `completionStat`); a legacy note.
* Tests updated: `play_session_screen_test`, `play_session_runtime_test`, `pointer_cancel_test`, `reduce_motion_test`, `journey_next_level_test`, `journey_unlock_flow_test`, `journey_home_live_test` (comment), `integration_test/play_session_test`.

**Deleted**
* `app/lib/play/won_composition.dart`, `app/lib/play/widgets/docked_row.dart`, `app/lib/play/widgets/board_tile.dart` (only the legacy won path used it), `app/lib/rating/completion_panel.dart`.
* `app/test/play/won_composition_test.dart`, `app/test/rating/completion_panel_test.dart`, `app/test/rating/completion_cta_weighting_test.dart` — their F04 / CTA coverage moved to `result_view_test.dart` (§17).

---

## 3. Task-to-Code Traceability

| Brief item | Status | Files | Behaviour |
| --- | --- | --- | --- |
| **F03-FE-D2** (whole task) | **Complete** | as §2 | as §1 |
| 1 Win sequence on the D1 board | Complete | `win_timeline.dart` (`fill`, `bloom`, `chrome`), `travelling_tile.dart` (`.win`), `lime_glow.dart` (`.bloom`), `play_session_screen.dart` (`_buildTravellingRow`, `_buildBloom`, `_buildPlay`), `puzzle_board.dart` (`hiddenRow`) | the board stops drawing the winning row at T0; the travelling row draws it on its own cells; `docked_row.dart` and the amber seam are deleted |
| 2 Board → result transition | Complete | `win_timeline.dart` (`glide`, `band`, `radial`), `play_session_screen.dart` (`_slotTiles` via `GlobalKey`, per-tile `Rect.lerp` + size / radius / glyph lerp) | chrome + board out by 720 (one `Opacity` over the Play group; the board is a `RepaintBoundary` that does not repaint then); the row glides 600–840 to the **laid-out** slot at scroll offset 0; no blur |
| 3 Full-screen `ResultView` | Complete | `result_view.dart` | the §16.6 column; fixed back; reserved badge row; capped headline with the authored break; free subtitle; answer row + radial; `StarRow` + reveal; `StatCard`; `LimePill(glow: false)`; `TextLink`; no-optimal line; `SingleChildScrollView(ClampingScrollPhysics)` + `ScrollBand` |
| 4 Variants and markers | Complete | `result_model.dart`, `result_view.dart`, `rating_strings.dart` | badge precedence, CTA weighting, "Sonraki bölüm · yakında", "Yolculuğu tamamla"; `CompletionPanel`, `_GapConnective`, `PanelDensity` and every legacy marker are gone |
| 5 Rating read (C1) | Complete | `result_model.dart` (`bestKnown`), `result_view.dart` (`_badgeIn`, 160 ms) | see §1 |
| 6 Exits | Complete | `play_session_screen.dart` (`_onRetry`, `_leaveWon`, `_popToCaller`, `_nextLevelHandler`), `win_timeline.dart` (`RetryTimeline`) | back button / system back → `/` at any time in `won`; "Tekrar oyna" → `retryFromCompletion()` inside transition A; "Sonraki bölüm" → F05's handler; no Close |
| 7 Input and lifecycle | Complete | `play_session_screen.dart` (`IgnorePointer` + `ExcludeSemantics` on Play from T0 and on the result until rest; `didChangeAppLifecycleState`) | taps before rest dropped; background mid-sequence / mid-retry → rest; controller and persistence untouched |
| 8 Reduced motion | Complete | `win_timeline.dart` (`.reduced`), `RetryTimeline.reduced`, `StarRow` static | `reduceMotionRequested()` read at T0 / at the Retry tap |
| 9 Design layer (§20.7 (6)) | Complete | `tile.dart` (`TileFace.answer`, `glyphSize`), `info.dart` (`StarRow.revealMs`, `StarRow.pop`), `result_decor.dart` (`ScrollBand`) | component tests in `result_components_test.dart`; no token value or dependency change; the F00 component tests are unchanged and green |
| 10 Strings / semantics | Complete | `play_strings.dart`, `rating_strings.dart`, `result_view.dart` | TR + EN tables; spelled numbers `bir … on`; the §16.11 labels and the traversal order back → verdict → answer → stars → stats → primary → link; one polite announcement at rest (+ the badge) |
| Tests (§20.4 + four F05) | Complete | §17 | every F04 AC1–AC10 and F05 AC1 / AC12 keeps a passing test |
| Evidence (§20.6 / §20.7) | Complete (limits stated) | § Visual Parity Evidence | F03.D2-PARITY |

---

## 4. Authority Reconciliation

No contract conflict. Implementation choices inside the §16.11 "Flexible" list, and two measured deviations from the renders that sit in unchanged F00 components:

| Item | Source | Applied | Downstream impact |
| --- | --- | --- | --- |
| The retry flight's tiles stay on the rail slots 300–360 as the rail's own face, then the real `RailTile`s take over at rest | §16.11 Flexible ("a cross-faded copy, if the frame at 300 equals the rail") | the frame at 300 is the rail (rects ≤ 0.5 pt, widget test) | none; avoids a partial-opacity rail while Play fades in |
| The result is **mounted** at T0 + 450 (reduced: + 150), inside the static hold, not at T0 | performance (§20.3 (11)); not a visible change — every result opacity is 0 until 600 either way | found on the simulator: mounting at T0 cost a 153 ms frame gap on the settle frame of a cold run (`RV-16-r2-L5-before-mount-fix.mp4`) | none: the slot is laid out ≥ 150 ms before the glide; measured at runtime after the change |
| The win clock is anchored to the settle frame's timestamp | §20.3 (1) "times are ms from T0" | an `AnimationController` started from the settle callback runs one frame late | rest is exactly T0 + 940 on the frame clock |
| The ★ beside `EN İYİ` sits 4.3–6.0 pt higher than the render's superscript | F00 `StatCell(star: true)` geometry (not in the §20.7 (6) allowance) | kept as shipped | informational (NTLC-D2-2) |
| The pressed primary pill scales to 0.98 but does not darken 5 % | F00 `LimePill` / `_Pressable` (press = scale; glass controls brighten) — D2-12 shows scale + brightness | kept as shipped | informational (NTLC-D2-2) |

---

## 5. Components

* **`_PlayBodyState`** (`play_session_screen.dart`) — the orchestrator: the Play group, the bloom, the `ResultView`, the travelling row; one win clock (`Ticker` → `_win`) and one retry `AnimationController`; the snapshot of the winning row at T0 and of the result at the Retry tap.
* **`WinTimeline` / `RetryTimeline`** — pure functions of ms; the single source of every window.
* **`ResultView` + `ResultMotion`** — the result and its per-frame look (entrance, rest, retry exit).
* **`ResultModel`** — badge / stars / stats / CTA from `CompletionResult` + `ratingResolved` + the Next kind.
* **`TravellingTile`** — `.win` (own face under the lime fill) and `.flight` (lime face over the rail face); size, radius, glyph given by the caller.
* **`LimeGlow`** — `.bloom` (.30 → 0 at 70 %, 50 % × 60 %) and `.result` (.13 → 0 at 72 %).
* Design layer: **`TileFace.answer`**, **`StarRow.revealMs`**, **`ScrollBand`**.

---

## 6. Screens

`/play` only; no route added.

* **Play (idle … animating):** unchanged D1 surface.
* **`won`, 0–720:** the Play header (back + `SEVİYE NN`, `HAMLE`), rail, board, HUD and tutorial stay drawn and dim with the chrome; all input and semantics are off from T0. From the frame they reach 0 they are `Offstage` with `TickerMode` off (the tutorial ghost stops ticking behind the result).
* **`won`, result:** no top bar; only the result's own 44-pt back button (`GlassIconButton`, radius 15·s, "Ana ekrana dön"), fixed; inert until rest. Back → `_popToCaller` → `/`. **System back / edge swipe** is honoured at any time in `won` (nothing intercepts it) and lands on `/`.
* **Retry:** Play reappears on the restarted grid; header back as in D1.

---

## 7. State Management

* **Controller (unchanged):** `phase`, `completion`, `ratingResolved`, `retryFromCompletion()`; the completion is persisted at `won`.
* **UI state (`_PlayBodyState`):** `_WonSnapshot` (row, letters, faces at T0), `_win` (0 → 1 over 1300 / 660 ms), `_retry` (360 / 160 ms), `_retryModel` + `_flightFrom` frozen at the Retry tap; rest = `WinTimeline.atRest`; retry end = the frame `_retry` reaches 1 (not the `completed` status, which Flutter reports one frame later).
* **Restored straight into `won`** (authored-solved or an uncleared completed snapshot): the result at rest, no replay.

---

## 9. Contract Compliance Check

| Area | Result | Note |
| --- | --- | --- |
| Screen / route contract | Preserved | the result is an in-screen state of `/play`; no route |
| Backend response / event mapping | Not Applicable | client-only |
| Error mapping | Preserved | no-optimal fallback; a failed best write → `—`, no badge, no error UI |
| UI state / store state consistency | Extended | C1 reads `ratingResolved` + `ratingPersisted`; a late resolve updates the badge in place |
| Navigation / back / header behavior | Extended | back button + system back → `/` at any time in `won`; Next / Retry unchanged calls; no Close |
| Async authority / lifecycle / boundary semantics | Preserved | persistence and controller timing at `won` untouched; background → rest; kill → no session, best + unlock written (widget test) |

---

## 10. Behavior Preserved

* **D1 Play** (idle, lift, shift, bounce, thaw, tutorial, HUD, loading, load error): no change in any non-`won` frame; the D1 suites are unchanged and green, apart from the three won-path assertions they carried (now the result).
* **Controller / persistence:** `completed` snapshot + `clearActiveSession()`, F04's `personal_best` write, F05's unlock, `retryFromCompletion()` semantics (moves 0, undo 3, restart count + 1) — asserted in `won_sequence_test` (system back / kill / retry) and the F04 flows.
* **F05 Next:** `_nextLevelHandler()` unchanged — N+1 via `pushReplacement`, the last level → `/` (terminal); `journey_next_level_test` green; the simulator run reached the terminal Home from level 30.
* **Rotation / portrait, gesture thresholds, the multi-touch deviation (F03-MULTITOUCH-FIRST-POINTER):** untouched.

---

## 11. UX Decisions

* **Hierarchy:** one focal object at every instant (filling row → travelling row → row + stars → one lime pill); the badge row is reserved, so the row lands at the same place in every variant (asserted).
* **One glow:** the answer tiles' own lime glow + the radial; `LimePill(glow: false)`; flat stars.
* **CTA:** "Sonraki bölüm" / "Yolculuğu tamamla" primary only when Perfect and a Next handler exists; the link hit box is ≥ 44 pt and the full column width.
* **Text scale (C-9):** container text capped at 1.3× (headline, answer glyphs, stats, badge — the badge through `MediaQuery.withClampedTextScaling`, `LoopBadge` unchanged); free text (subtitle, pill label, link, no-optimal line) follows the OS to AX5 and breaks only between words (asserted on 390 / 393 / 440 at AX5).
* **Semantics:** the disabled link reads "Sonraki bölüm, yakında" (a `Semantics` wrapper; `TextLink` unchanged).
* **Rubric self-check (provisional):** no default kit look, no placeholder, drawn icons only, real fonts; the runtime matches the renders within 0.3–1.3 pt at 1.0×. Scoring is QA's (F03.D2-VISUAL-QA).

---

## Visual Parity Evidence

**Common provenance:** iOS Simulator 18.6 — iPhone 16 `D0011CE7-6E50-4367-93FA-B323E81270BE` (393×852 @3x), iPhone 16e `6DBDFD97-7BF7-4051-914C-76609DDF8697` (390×844 @3x), iPhone 16 Pro Max `02FDE776-C263-4DAB-A16A-76902AC18189` (440×956 @3x); **debug** build of `lib/main.dart` at HEAD `051c64c` + the F03-FE-D2 working tree ("051c64c + WT"), captured by the Frontend/Mobile Developer on 2026-09-28 14:50–15:15 (the pressed pill 18:40). States were reached through the real app: `design/src/capture-d2.sh seed` (wraps `seed-sim.sh`, plus an optional `personal_best` row) puts Journey level N one move short of its BFS-verified solution (the UI Designer's, §16.13), Home CONTINUE opens it, and the winning move is a simulator touch-path swipe. Stills are `simctl io … screenshot`; videos are `simctl io … recordVideo` (variable frame rate), re-encoded at exactly 2 px / pt with `design/src/video-d2.swift encode`. **Frame timing:** `design/src/timing-d2.py` (with the compiled `video-d2 trace`) reads every decoded frame with its real presentation time; T0 is fitted to the chrome dim (1 → 0.5, ease-out, 0–200 ms) over the frames inside it; the reduced path, whose dim is a state, uses the settle frame. Times are ± one capture frame (≈ 17 ms). The committed re-encodes reproduce the raw-capture numbers within 1–2 ms (`PX_PER_PT=2`). **Parity:** `design/src/parity-d2.sh` measures the lime bands (badge label, answer tiles, stars, ★, pill) in every render (@2x) and runtime capture (@3x) and composes render \| runtime sheets. The row-2 run with the mount at T0 (`…-before-mount-fix.mp4`) was taken on the first install of this tree before the §4 mount change; every other record is on the final code.

| Evidence ID | Kind | Screen / State | Viewport / Device | Artifact | Source Revision | Captured By | Captured At | Result / Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| RT-16-D2-01 | runtime-screenshot | result · Perfect first clear (L5 in 3) | 393×852 iPhone 16 | design/runtime-d2/RT-16-D2-01-perfect.png | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:09 | vs D2-01 (PC-D2-01): bands ≤ 1.0 pt; ★ 5.3 pt (§4) |
| RT-16-D2-02 | runtime-screenshot | result · Perfect + new best (prior 5) | 393×852 iPhone 16 | design/runtime-d2/RT-16-D2-02-perfect-new-best.png | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:06 | `HARİKA` only (C-4); vs D2-02 ≤ 1.0 pt |
| RT-16-D2-03 | runtime-screenshot | result · new best 2★ (prior 6, 5 moves) | 393×852 iPhone 16 | design/runtime-d2/RT-16-D2-03-new-best-2star.png | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:06 | `YENİ EN İYİ`, 5 · 3 · 5, Retry primary; ≤ 1.0 pt |
| RT-16-D2-04 | runtime-screenshot | result · first clear 2★ (5 moves) | 393×852 iPhone 16 | design/runtime-d2/RT-16-D2-04-first-clear-2star.png | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:06 | no badge, row at the same place; render shows 4 moves (5 is the shortest reachable non-optimal path with paired waste moves) — layout identical, ≤ 0.5 pt |
| RT-16-D2-05 | runtime-screenshot | result · matched best (prior 5) | 393×852 iPhone 16 | design/runtime-d2/RT-16-D2-05-matched-best.png | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:07 | no badge; ≤ 0.5 pt |
| RT-16-D2-06 | runtime-screenshot | result · 1★ no improvement (7 moves, prior 4) | 393×852 iPhone 16 | design/runtime-d2/RT-16-D2-06-1star-no-improvement.png | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:07 | 7 · 3 · 4 (render 8 · 3 · 4), "Hedef yedi hamlede…"; ≤ 0.5 pt |
| RT-16-D2-07 | runtime-screenshot | result · no-optimal fallback | — | — | — | — | — | **Not reachable in the app** (every shipped and debug puzzle has an optimal; §6 "dev-only"); covered by widget tests on the screen and on `ResultView` (§17) |
| RT-16-D2-08 | runtime-screenshot | result · Next not wired (debug L01, Perfect) | 393×852 iPhone 16 | design/runtime-d2/RT-16-D2-08-next-not-wired.png | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:09 | Retry primary even when Perfect; "Sonraki bölüm · yakında" at 45 %; ≤ 1.0 pt |
| RT-16-D2-09 / 09b | runtime-screenshot | level 30 · Perfect / 2★ (7 moves) | 393×852 iPhone 16 | design/runtime-d2/RT-16-D2-09-level30-perfect.png, RT-16-D2-09b-level30-2star.png | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:08 | "Yolculuğu tamamla" primary / link; ZEMİN with the locked Z and N lime; ≤ 1.0 pt |
| RT-16-L30-terminal | runtime-screenshot | "Yolculuğu tamamla" tapped → terminal Home | 393×852 iPhone 16 | design/runtime-d2/RT-16-L30-next-terminal-home.png | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:08 | F05 AC12: `TAMAMLANDI 30 / 30` |
| RT-16-D2-11 | runtime-screenshot | focus ring on the back button | — | — | — | — | — | **Not captured:** this host cannot inject hardware keys into the simulator (same limit as D1-12, §19.9 (4)); the ring is the unchanged `_Pressable` path, covered by the F00 Tab-trigger widget test |
| RT-16e-D2-12 | runtime-screenshot | primary pill held (2★ result) | 390×844 iPhone 16e | design/runtime-d2/RT-16e-D2-12-cta-pressed.png, PC-D2-12-pressed.jpg (rest \| held) | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 18:40 | scale ≈ 0.98 while held; no −5 % brightness (F00 `LimePill`, §4) |
| RT-16-context | runtime-screenshot | Play one move short (L26, L4); results of those runs | 393×852 iPhone 16 | design/runtime-d2/RT-16-L26-before-win.png, RT-16-L26-result-perfect.png, RT-16-L4-before-win.png, RT-16-L4-result-perfect.png | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:02–15:03 | the starting frames of RV-16-r0 / RV-16-r4 |
| RT-16e-v | runtime-screenshot | device variants: Perfect (L4), 1★, first clear 2★, after retry | 390×844 iPhone 16e | design/runtime-d2/RT-16e-L4-result-perfect.png, RT-16e-D2-06-1star.png, RT-16e-D2-04-first-clear-2star.png, RT-16e-L4-after-retry.png | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:04–18:40 | vs D2-v-16e-result-perfect / -1star: bands ≤ 1.3 pt; ★ 4.3 pt |
| RT-pm-v | runtime-screenshot | Perfect + new best | 440×956 iPhone 16 Pro Max | design/runtime-d2/RT-promax-D2-02-perfect-new-best.png | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:11 | vs D2-v-promax-result-perfect-new-best: ≤ 0.7 pt; ★ 6.0 pt |
| PC-D2 | parity-comparison | every pair above and the text-scale pairs | 393×852, 390×844, 440×956 | design/runtime-d2/PC-D2-*.jpg, design/runtime-d2/parity-measurements.txt | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:22 | **1.0×:** badge ≤ 1.0, tiles ≤ 0.3 (16) / 1.2 (16e), stars ≤ 0.5, pill ≤ 0.5–1.2 pt — inside the ±2 pt anchors; deviations below |
| A11Y-16-sweep | accessibility | result at OS text large, xL, xxL, xxxL (the cap), AX-M, AX5 (offset 0) and AX5 scrolled to the end | 393×852 iPhone 16 | design/runtime-d2/RT-16-D2-01-perfect.png, A11Y-16-result-extra-large.png, …-extra-extra-large.png, …-extra-extra-extra-large.png, …-accessibility-medium.png, …-accessibility-extra-extra-extra-large.png, A11Y-16-result-ax5-scrolled-end.png | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:09–15:10 | live `simctl ui content_size`, no relaunch. At the cap: no scroll, tiles 340.7 / stars 442.0 / pill 590.0 pt (render D2-10: 341.0 / 441.5 / 590.0). AX5: tiles 507.7 (render 507.5); scrolls; the back button stays fixed with the band behind it; every line breaks between words; the link ends above the home indicator. Restored to `large` |
| A11Y-16e / A11Y-pm | accessibility | the cap (and AX5 on the 16e) | 390×844 iPhone 16e, 440×956 Pro Max | design/runtime-d2/A11Y-16e-result-extra-extra-extra-large.png, A11Y-16e-result-accessibility-extra-extra-extra-large.png, A11Y-promax-result-extra-extra-extra-large.png | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:10–15:11 | no scroll at the cap on both; the 16e capture is the 1★ variant, whose longer subtitle wraps at xxxL and moves the column 29 pt down (permitted free-text reflow; still no scroll). AX5 on the 16e: tiles 502.7 (render 503.0). Restored to `large` |
| RV-16-r2 | runtime-video | row 2 (L5, the column-1 D move): win + transition + stars | 393×852 iPhone 16 | design/runtime-d2/RV-16-r2-L5.mp4 (+ RV-16-r2-frames-sheet.jpg: T0, +200, +586, +717, +936, +1286) | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:00 | cold first win after launch — see the timing table |
| RV-16-r2-warm | runtime-video | row 2, second win in the same session | 393×852 iPhone 16 | design/runtime-d2/RV-16-r2-L5-warm.mp4 | 051c64c + WT (before the §4 mount change) | Frontend/Mobile Developer | 2026-09-28 14:55 | timing identical to RV-16-r2 |
| RV-16-r2-premount | runtime-video | row 2, the result mounted at T0 | 393×852 iPhone 16 | design/runtime-d2/RV-16-r2-L5-before-mount-fix.mp4 | 051c64c + WT (before the §4 mount change) | Frontend/Mobile Developer | 2026-09-28 14:51 | 153 ms frame gap on the settle frame (cold debug run) — the reason for the §4 change |
| RV-16-r0 | runtime-video | row 0, L26, locked T and R in the row (C-11) | 393×852 iPhone 16 | design/runtime-d2/RV-16-r0-L26.mp4, RV-16-r0-L26-C11-sheet.jpg | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:02 | the locked tiles fill lime with the row, no lock icon from the first captured fill frame. This cold run dropped a 103 ms frame at the settle, so the early fill frames (T0 + 0 … 60) are not in the capture; the icon fade is proven by `won_sequence_test` (two icons at T0 and T0 + 60, none at T0 + 210) |
| RV-16-r4 | runtime-video | row 4, L4 (the longest glide) | 393×852 iPhone 16 | design/runtime-d2/RV-16-r4-L4.mp4 | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:03 | cold run; single-frame gaps only |
| RV-16e-r4 | runtime-video | row 4, L4 | 390×844 iPhone 16e | design/runtime-d2/RV-16e-r4-L4.mp4 | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:04 | cold run; **no frame gap > 30 ms in 600–1400** (the §16.11.1 (18) window) |
| RV-retry | runtime-video | retry A: row into the rail, Play on the restarted grid | 393×852 iPhone 16, 390×844 iPhone 16e | design/runtime-d2/RV-16-retry-L5.mp4, RV-16e-retry-L4.mp4 | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 14:53, 15:04 | `HAMLE 0`, undo disabled, three dots after rest (RT-16e-L4-after-retry) |
| RV-reduced | runtime-video / accessibility | Reduce Motion ON: win (row 2) and retry dip | 393×852 iPhone 16 | design/runtime-d2/RV-16-r2-L5-reduced.mp4, RV-16-retry-L5-reduced.mp4 | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 15:12 | set with `capture-d2.sh rm` (`defaults write com.apple.Accessibility ReduceMotionEnabled`, relaunch); restored to 0. Reduce Motion OFF = every other video |
| INT-16 | runtime (automated) | `flutter test integration_test` | 393×852 iPhone 16 | console | 051c64c + WT | Frontend/Mobile Developer | 2026-09-28 18:34 | 13 / 13, exit 0 (the suite uninstalls the app afterwards) |

**Frame timing** (ms from T0; ± one capture frame):

| Record | T0 fit | row on its cells through / first moved (C2, ≤ 0.5 pt) | first result pixel | `HAMLE` / HUD at final | pill at rest | stars done | frame gaps > 30 ms |
| --- | --- | --- | --- | --- | --- | --- | --- |
| RV-16-r2 (L5) | 5 frames | 0.00 pt through 601 / 617 | 717 | 734 / 717 | 951 | 1286 | +19 (47), +66, +434 (52), +486, +521, +751 (50) |
| RV-16-r2-warm | 5 frames | 0.00 through 600 / 620 | 717 | 734 / 717 | 950 | 1285 | +17 (67) |
| RV-16-r0 (L26) | 1 frame | 0.00 through 600 / 633 | 717 | 733 / 717 | 952 | 1287 | −17 (103), +87 (65), +450 (52), +502, +600, +633 |
| RV-16-r4 (L4) | 7 frames | 0.00 through 600 / 618 | 716 | 735 / 716 | 951 | 1286 | +33, +435, +468 (≤ 35) |
| RV-16e-r4 (L4) | 7 frames | 0.00 through 603 / 619 | 719 | 736 / 719 | 953 | 1289 | +19 (32), +436 (50), +486, +519 (33) |
| RV-16-r2-reduced | settle frame | static through 260; the cross-fade from 278 | 442 | 442 / 442 | 627 | static | ≤ 52 |
| RV-16-retry (tap window + 2 ms) | last rest frame | — | — | rail 198 · board 265 · HUD 265 | — | — | +48 (52), +198 (35) |
| RV-16e-retry (tap window + 47 ms) | last rest frame | — | — | rail 233–280 · board 283–330 · HUD 303–350 | — | — | +0 (47), +130 (67) |
| RV-16-retry-reduced (tap window + 35 ms) | last rest frame | — | — | everything final by 133–168 | — | — | +0 (35) |

Reading the table: the row holds its cells (0.00 pt, the C2 measure) on every captured frame before T0 + 600, and the first frame that shows it moving is at 616–633. The first result pixel is at 716–719 (the back button and headline start at 700, fading). The chrome's last visible residue is on the frame just before 720 (≤ 3 % opacity), and it is at its final value on the next captured frame (733–736). The pill reaches its final value on the first captured frame after 940 (the frame before it is within 0.5 % of it), and the stars finish at 1284–1289 (≤ 1300). Retry: rest by ≤ 350 (≤ 400; designed 360); reduced ≈ 160; reduced win ≈ 660. The exact windows are asserted on the app's own clock by `won_sequence_test` (§17).

**Frame gaps:** every gap > 30 ms after T0 falls at the fill start (T0 + 17 … 87, the first `won` frame of the debug build) or at the result mount (T0 + 430 … 520, a static hold where nothing moves). The row-4 16e run — the longest glide, §16.11.1 (18) — has none in 600–1400. All runs are **debug (JIT) builds**, the only mode the simulator runs; release frame pacing is not measured here.

> **Tech Lead checkpoint note (2026-09-28, architecture §20.8):** re-run from the committed re-encodes, two cells above do not reproduce. RV-16e-r4 `HUD` reaches its final value at +1186, not +719: background luma in the HUD region, since the frame at T0 + 1066 shows no Play chrome, and `HAMLE` is final at 732. RV-16-retry board / HUD are final at +248, not +265: one capture frame. All other cells reproduce within 1–3 ms. No verdict changes.

**Deviation list (runtime vs renders):**
1. The ★ beside `EN İYİ` sits 4.3–6.0 pt higher than the render's superscript — F00 `StatCell` (NTLC-D2-2).
2. The pressed pill has no −5 % brightness — F00 `LimePill` (NTLC-D2-2).
3. D2-04 / D2-06 / D2-09b are captured at 5 / 7 / 7 moves (renders 4 / 8 / 7): waste moves come in pairs (R3 L3) so the solution stays BFS-verified; layout and markers identical.
4. Stats labels read ≈ 1–3 pt lower inside the card than in the render by eye (F00 `StatCard`, Flutter vs Blink line boxes); not an §16.6 anchor; the card rect itself is within 0.5 pt.
5. The C-11 fill frames of the L26 run are missing from the capture (the cold-run stall); widget-test evidence instead.
6. Android: not run (ANDROID-CI-EVIDENCE, stated limit).

---

## 12. Implemented Files

* **`app/lib/play/win_timeline.dart`** (new) — `WinTimeline.regular / .reduced`: `fill`, `bloom`, `chrome`, `glide`, `overlayRow`, `overlayRowOpacity`, `resultRow`, `radial`, `band`, `starRevealMs`, `resultMountMs` (450 / 150), `restMs` (940 / 660), `endMs` (1300 / 660); `RetryTimeline.regular / .reduced`: `resultOut` (0–140 fade + 8·s drop; reduced 0–80), `flight` (0–300 `E`), `flightLime` (100–300), `flying` (until rest), `playIn` (160–360; reduced 80–160), `boardRise` (10·s).
* **`app/lib/play/play_session_screen.dart`** — `_PlayBody` / `_PlayBodyState` rewritten: `_buildPlay` (one group, `IgnorePointer` + `ExcludeSemantics` from T0, `Opacity` = chrome / play-in, `Offstage` + `TickerMode(false)` once at 0; board in a `RepaintBoundary` with the 10·s rise), `_buildBloom`, `_buildResult` (mounted from `resultMountMs`), `_buildTravellingRow` (fill / glide / flight), `_startWinClock` / `_onWinTick` (clock from the settle frame), `_onRetry` / `_leaveWon`, lifecycle → rest, `_next` (terminal iff `nextJourneyLevel(n, 30) == null`). `_LoadedPlaySessionState.build` passes the tutorial overlay in. Removed: `_WonMetrics`, `_WonPanelHost`, the dock / panel / scrim code.
* **`app/lib/play/widgets/result_view.dart`** (new) — `ResultMotion` (`.win`, `.retry`, `.rest`), `ResultView` (layout per §16.6: column top 54·s + .16 e, badge row 42·s, gaps 16·s + .08 e / 14.25·s / 38.3·s + .16 e / 32·s / 24.5·s / 18.5·s / 27.25·s − 22; `TextHeightBehavior` even leading as in the renders; the radial placed after layout behind the column; `ScrollBand` from scroll offset 0 → 12 pt; the badge fade; the one-shot announcement).
* **`app/lib/rating/result_model.dart`** (new) — see §5; value equality.
* **`app/lib/play/widgets/travelling_tile.dart`**, **`lime_glow.dart`** (new) — see §5.
* **`app/lib/play/widgets/puzzle_board.dart`** — `rowVacated` → `hiddenRow`; the `_win` controller, `BoardTile` use, seam, bloom, `_Receded`, `_GhostCell` and `dart:math` removed; at `won` the lift / rails / thaw are cleared as before.
* **`app/lib/design/components/tile.dart`** — `TileFace.answer(letter, scale)`, the `answer*Ref` constants, `glyphSize`.
* **`app/lib/design/components/info.dart`** — `StarRow.revealMs`, `popDuration` 140, `popStagger` 110, `revealDuration` 360, `pop(t)`; static behaviour unchanged when `revealMs` is null.
* **`app/lib/design/components/result_decor.dart`** (new) — `ScrollBand` (`#0B1234` to 78 %, then 0; 54·s + 58 pt).
* **`app/lib/play/play_strings.dart`** — removed `solvedKicker`, `retry`, `close`; added `resultHeadline` (`Döngü\ntamamlandı.`), `resultSubtitle` / `resultSubtitleOne`, `numberWords`, `nextLevel`, `playAgain`, `finishJourney`, `soonSuffix`, `answerWord`, and the `subtitleFor` / `resultHeadlineSpoken` / `nextLevelSoon(Spoken)` helpers (TR + EN).
* **`app/lib/rating/rating_strings.dart`** — rewritten for the result: badges, spoken forms, stat labels, `noRating`, `starGroupSemantics` ("3 / 3 yıldız, Harika"), `statsSemantics`.
* **`app/lib/play/play_theme.dart`** — see §2.

---

## 13. Performance Notes

* No blur, no `Opacity` over a repainting subtree: the board is a `RepaintBoundary` that does not repaint after T0; the travelling row is its own `RepaintBoundary`; the result rebuilds per frame only during its entrance / exit.
* The result mount moved into the static hold (§4); the Play group stops painting and ticking once faded.
* The win clock is read from frame timestamps, so a dropped frame never stretches the timeline (the next frame lands at the right time).
* Debug-build gaps are listed above; the §16.11.1 (18) check (16e, row 4) shows none in the motion window.

---

## 14. Assumptions

* The result subtitle for EN uses a singular form for one move ("Target set in 1 move."); TR needs none.
* `ResultNext.terminal` is decided from the Journey length (30), as F05's handler routes; with an interim manifest shorter than 30 the last available level still reads "Sonraki bölüm" and routes home (unchanged F05 behaviour).

---

## 16. Needs Tech Lead Clarification

* **NTLC-D2-1 (informational) — the result mounts at T0 + 450 (reduced + 150).** Not a visible change and inside §20.3 (1); recorded because §16.4 describes the result as built at T0. It removed a 153 ms settle-frame gap measured on a cold debug run.
* **NTLC-D2-2 (informational) — two F00-component deviations** at runtime: the `EN İYİ` ★ sits 4.3–6.0 pt higher than the D2 render's superscript, and the pressed `LimePill` scales but does not darken 5 % (D2-12). Both are shipped F00 components outside the §20.7 (6) allowance, so they are left unchanged. A later design-layer touch (D3 / F10) can align them if wanted.
* **NTLC-D2-3 (evidence limits):** D2-07 (no-optimal) is not reachable at runtime; the focus ring (D2-11) cannot be injected on this host; VoiceOver, lifecycle mid-sequence and system back mid-sequence are proven by widget tests only (runtime is QA's, §20.6); Android not run.

---

## 17. Test Evidence by Task

All commands run on this host (macOS, Flutter 3.32.8) on 2026-09-28 against 051c64c + WT: `melos run analyze` SUCCESS; `dart format --set-exit-if-changed app packages tools` 0 changed; `melos run test` SUCCESS (app 503 passed); `flutter test integration_test -d <iPhone 16>` 13 / 13, exit 0. Widget tests use real fonts where metrics matter (`loadAppFonts`), fake time and the real `PlaySessionScreen` + in-memory Drift, unless noted.

| Task / behaviour | Test | Scenario proven |
| --- | --- | --- |
| 1 Nothing outside the board before T0 + 600 | `won_sequence_test` "row 0 / 2 / 4: nothing of the result before T0 + 600 …" | every 10 ms from T0 to 599: the result is absent before 450, then every opacity 0 and not interactive |
| 1 / C2 row displacement | same | the 5 travelling tiles stay on their board cells within 0.5 pt (measured 0.0) on every frame before 600, rows 0 / 2 / 4 |
| 1 Fill, bloom, dim | `won_sequence_test` "WinTimeline (regular)" | fill 30 ms apart / 90 ms each, lime by 210; dim 50 % by 200; bloom 0 → 1 → .55, 0 by 720 |
| 1 C-11 special tiles | `won_sequence_test` "C-11 …" (+ reduced); `result_components_test` "TravellingTile (C-11)" | lock icons under the fill at T0 and T0 + 60, gone at T0 + 210; lime at T0 under Reduce Motion; frozen snowflake + dashes go with the fill |
| 2 Chrome by 720, morph, landing | `won_sequence_test` row tests; "the row lands on the laid-out slot …" | the board is offstage at 720; the travelling tile is taller than the board tile mid-glide (morph); landed within 1 pt of the result's answer tiles |
| 2 / 5 Rest and stars | same + "WinTimeline" | not interactive at 939, interactive at 940; `revealMs` 0 at 940, 110 at 1050, 360 at the end |
| 3 Layout anchors 1.0× (±2 pt) | `result_view_test` "layout anchors …" × 390 / 393 / 440 | back (24, 54)·s 44 pt; badge 54·s + .16 e; headline 112·s + .24 e and two lines; tiles 258·s + .4 e, 52.5 × 59·s, centred; stars 349·s; stats 392.5·s, 74·s, 309·s wide; pill 485·s, 63.5·s; link centre 575.75·s + .4 e (table 658.0 on 16), ≥ 44 pt, full column width |
| 3 Reserved badge row | "the badge row is reserved …" | the answer row rect is identical with and without a badge |
| 3 No scroll up to the cap | "text scale … fits, no scroll" × 3 devices × 6 scales ≤ 1.3 | `maxScrollExtent == 0`, no exception, longest CTA ("Yolculuğu tamamla") |
| 3 AX5 | "… at AX5: scrolls, back fixed, lands at 0, band only when scrolled, no mid-word break" × 3 devices | offset 0, band 0 → 1 when scrolled, back rect unchanged, headline capped 1.3, free text at 3.118 with no mid-word break (`lineBreakFaults`), link above the home indicator |
| 4 Variant table | `result_view_test` "ResultModel …" (9 unit tests) + "variants on screen" (D2-01 … D2-09b) | badge precedence, stars, stats cells, primary / link labels, disabled link (+ its spoken label), level 30 in both weightings (tap calls Next), no legacy marker (`3 / 3`, `+N`, `=`, `İLK`, "daha iyi", `ÇÖZÜLDÜ`, `YENİ REKOR`, `Kapat`, `SONRAKİ`, `Yeniden`), one glow |
| 5 C1 late read | `result_view_test` "C1 — the late personal-best read" (2) | a gated `PersonalBestRepo`: at rest `EN İYİ —`, no badge, 2★ shown; after resolve `YENİ EN İYİ` fades (mid-fade opacity in (0, 1)), `EN İYİ 2`, answer row and headline rects unchanged; a failing read → `—`, no badge |
| 6 Retry A | `won_sequence_test` "retry A …", "retry reduced …", "a board drag during the retry is dropped …" | flight on the rail rects (≤ 0.5 pt) at 300; still locked at 359, Play at 360; `HAMLE 0`, undo disabled, quota 3, five rail tiles; snapshot restart count 1, no moves, undo 3; reduced: no flight, rest at 160; a drag at + 200 dropped, the next one plays |
| 6 Back / system back | "back button at rest → Home"; "system back at T0 + 300 → Home, the completion persisted" | `/` reached; active session cleared, personal best 1, Journey level 9 completed |
| 6 Next | `journey_next_level_test` (2) | "Sonraki bölüm" → N+1 by `pushReplacement`; on the last available level → `/` |
| 7 Input lock | "taps before rest are dropped …" | pill and back tapped at T0 + 900: still the result, not Home, not restarted |
| 7 Lifecycle | "background at T0 + 300 …"; "killed at T0 + 300 …" | resume at rest (stars complete, no ticker); after unmount: no active session, best written, level 9 completed, 10 unlocked |
| 7 Tutorial | "tutorial active at T0 (L4–6) …" | the hint pill stays at 50 % until the chrome fades, is gone by T0 + 800, and nothing ticks behind the result |
| 8 Reduced motion | `won_sequence_test` "reduced motion …"; `reduce_motion_test` (iOS / Android / both + control) | row static on its cells to 299, cross-fade at 380 (0.5), rest at 660 exactly, stars static; control run fills and pops |
| 9 Design layer | `result_components_test` (11) | `TileFace.answer` size / radius / glyph and its cap at AX5; `StarRow.pop` curve, outline → pop 110 ms apart, static when null, semantics; `ScrollBand` height, invisible at 0, gradient stops, decorative |
| 10 Semantics | `result_view_test` "semantics: labels and traversal …"; `won_sequence_test` "during the sequence nothing is announced or focusable" | order back → "Harika" → "Döngü tamamlandı." → subtitle → "Cevap: BULUT" → "3 / 3 yıldız, Harika" → "Sen 3, optimal 3, en iyi 3, harika" → "Tekrar oyna" → "Sonraki bölüm, yakında"; no answer / board / pill node at T0 + 500 |
| F04 AC1 / AC7 / AC8 | `result_view_test` "smoke-tr-01 in 1 …" | Perfect, `SEN 1 · OPTİMAL 1 · EN İYİ 1★`, 3★, `HARİKA`, Retry, Next, answer node |
| F04 AC2 / AC9 | "smoke-tr-02 in 3 (optimal 2) → 2★" | 2★, not Perfect |
| F04 AC5 | "a worse result → … the retained better best" | 2★, `EN İYİ 2★`, no badge; the stored best stays 2 |
| F04 AC6 | "a beaten prior best …" | best updates to 1, `HARİKA` wins the badge |
| F04 matched / AC3 / AC4 / AC10 | "Retry → again in 1 → matched best"; `star_rating_test` (unchanged) | matched: no new-best badge; the star bounds and the never-0 floor |
| No-optimal fallback | "no-optimal puzzle → the unrated result"; the controller unit test | the line, `— · —`, no stars / badge, Retry present; `rating_blocked_no_optimal` logged |
| F05 AC1 | `journey_unlock_flow_test` (2), `won_sequence_test` system back / kill | the unlock is written at `won` and survives back / kill; Retry + re-solve is idempotent |
| F03 AC8 / AC11 | `play_session_screen_test`, `integration_test` group 1, the row tests | win → lock + highlight + sequence + result; a transient word mid-animation does not win (unchanged tests) |

**Negative controls** (each rule broken in a scratch edit, the named suite run, the file restored from a byte copy taken before the edit; the full suite re-run green afterwards):

| Broken rule | Suite | Failing tests |
| --- | --- | --- |
| N1 head / back band starts at 500 | `won_sequence_test` | 5 |
| N2 glide starts at 550 | `won_sequence_test` | 4 |
| N3 C1: `YENİ EN İYİ` before the read resolves | `result_view_test` | 2 |
| N4 badge row not reserved | `result_view_test` | 2 |
| N5 chrome fade stretched to 840 | `won_sequence_test` | 5 |
| N6 too much bottom padding → scroll at the cap | `result_view_test` | 18 |

Also caught during development: unlocking Retry on the `completed` status (one frame late) failed the 360 / 160 tests, and so did announcing from `initState`.

---

## 18. Test Notes

* **Timing in widget tests** is the app's clock. `_toT0` stops on the settle frame (the first frame that draws the travelling row), and the win clock is anchored to that frame. Tests that jump more than ~150 ms in one pump were changed to step, as a device does: a single jump lands the result mount and the checked frame together, a case that cannot happen at 60 fps.
* **Simulators restored:** content size `large` on all three, Reduce Motion 0 on the 16. The 16 no longer has the app installed (the `integration_test` run uninstalls it); `capture-d2.sh seed` reinstalls nothing, so run `flutter build ios --simulator --debug` + `simctl install` before reusing it. The 16e and Pro Max keep seeded test progress.

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** F03-FE-D2.
* **Remaining Tasks:** the Tech Lead's parity checkpoint (Visual Quality Gate → Ready for QA), then F03-QA-D2.
* **Blockers:** none. NTLC-D2-1 … 3 are informational / evidence limits.
* **Status Suggestion:** Needs Tech Lead Review.

## 19. Sonraki Komut

```text
Run Tech Lead
```

---

# F03-FE-D2R — D2 scroll-band rework

> **Task:** F03-FE-D2R (Frontend/Mobile Developer, 2026-09-28). **Contract:** `architecture.md` §20.9 (rulings on F03-QA-D2); §20.3, §20.7 and §20.8 still apply.
>
> **Source revision:** HEAD `3cd4a3b` + working tree (`app/` diff SHA-1 `262864be…`, two files). The `app/` tree at HEAD is still `f5641d2f…`, QA's fingerprint.

## 1. Feature Summary

F03-QA-D2-01 is fixed; nothing else changed.

* **Symptom:** at AX5 the player scrolls the result to its end, then lowers the OS text size. The content returns to offset 0, but the scroll band stayed drawn over the `HARİKA` badge and the back button, and the player could not clear it.
* **Cause (as ruled in §20.9):** `_band` was set only by the `ScrollController` listener. When the content shrinks, the scroll position clamps its offset during layout (`correctForNewDimensions` → `correctPixels`), which notifies no listener. Only a `ScrollMetricsNotification` is dispatched, after the frame.
* **Fix:** the band is recomputed from the position's current `pixels` on every scroll **and** on every `ScrollMetricsNotification` from the result's own scroll view. The band is therefore `clamp(pixels / 12, 0, 1)` after any metrics change, and 0 when the column cannot scroll.
* **At runtime** (iPhone 16, 16e, Pro Max): after AX5 → scrolled → xxxL and AX5 → scrolled → `large`, the band region is **pixel-identical** to the offset-0 control at the same size (0.000 % of pixels differ, all six pairs). QA's pre-fix capture of the same step differs by 51 %.

## 2. Impacted Files

**Updated**
* `app/lib/play/widgets/result_view.dart` — the band state (`_onScroll`, new `_onMetrics`, a `NotificationListener<ScrollMetricsNotification>` around the column's `SingleChildScrollView`).
* `app/test/rating/result_view_test.dart` — new group "scroll band after a live OS text-size change (§20.9 (1))", 9 tests.
* `ai-system/features/f03-puzzle-play-session/frontend.md` — this section (the D2 text above is unchanged).

**Created**
* `ai-system/features/f03-puzzle-play-session/design/src/band-d2r.swift` — band-region comparison on screenshots.
* `ai-system/features/f03-puzzle-play-session/design/runtime-d2r/` — 23 runtime screenshots, 3 re-encoded videos, `band-measurements.txt`, `timing-d2r.txt`.

No change to `ScrollBand` or anything else in `app/lib/design`, and none to layout, timeline, copy, input lock, lifecycle, persistence, routes, tokens or dependencies.

## 3. Task-to-Code Traceability

**F03-FE-D2R — Complete.**

| # | Brief item | Code | Behaviour |
| --- | --- | --- | --- |
| 1 | Band follows the scroll position after any metrics change (§20.9 (1)) | `result_view.dart` → `_onScroll` reads `_scroll.position.pixels` (guarded by `hasClients`); `_onMetrics` calls it for depth-0 `ScrollMetricsNotification`s; the listener wraps the result's `SingleChildScrollView` | Text size down or up, content extent change → `_band` recomputed on the next frame; 0 when the column no longer scrolls; the partial value for a clamped offset below 12 pt |
| 2 | `ScrollBand` only if needed | not touched | — |
| 3 | `frontend.md` section | this section | — |

## 9. Contract Compliance Check

| Area | Status | Note |
| --- | --- | --- |
| Screen / route contract | Preserved | no route or navigation change |
| Backend response / event mapping | Not Applicable | client-only |
| Error mapping | Not Applicable | — |
| UI state / store state consistency | Preserved | `_band` is local view state, now derived from the live scroll position; no controller or persistence state |
| Navigation / back / header behaviour | Preserved | the back button stays fixed; the band now never covers it at offset 0 |
| Async authority / lifecycle / boundaries | Preserved | the notification is filtered to depth 0 (only this scroll view); no timers, no lifecycle change |
| §20.3 (9) text scale / scrolling | Preserved and now met | no scroll up to the 1.3× cap; above it the column scrolls; **the band appears only when scrolled** (§16.11.1 (12)) |
| §20.9 non-goals | Preserved | layout, timeline, copy, input lock, lifecycle, persistence, routes, F00 components untouched |

## 10. Behavior Preserved

* **Scrolling by hand** still drives the band through the same listener, with the same formula (`offset` and `position.pixels` are the same value).
* **At mount** the scroll view reports its first metrics at offset 0 → `_band` stays 0 → no extra rebuild. The existing AX5 test ("lands at 0, band only when scrolled") is unchanged and green.
* **Win / retry timeline:** the timeline code is outside the diff. On the iPhone 16 the smoke recordings reproduce the D2 numbers (§17, `timing-d2r.txt`).
* **Everything else in D2** (variants, C1 late read, CTA weighting, lifecycle, reduced paths) is outside the diff; the full app suite and `integration_test` are green.

## Visual Parity Evidence

**Common provenance:** iOS Simulator 18.6 — iPhone 16 `D0011CE7-6E50-4367-93FA-B323E81270BE` (393×852 @3x), iPhone 16e `6DBDFD97-7BF7-4051-914C-76609DDF8697` (390×844 @3x), iPhone 16 Pro Max `02FDE776-C263-4DAB-A16A-76902AC18189` (440×956 @3x).
* **Build:** `flutter build ios --simulator --debug` of HEAD `3cd4a3b` + the F03-FE-D2R working tree (`App.framework/App` SHA-1 `d7a7c0af…`), installed on all three; captured by the Frontend/Mobile Developer on 2026-09-28, 20:09–20:21.
* **Reaching the state:** `design/src/capture-d2.sh seed <udid> 5 '["D0","D1"]'` at content size `large` → Home DEVAM ET → content size AX5 (`xcrun simctl ui <udid> content_size accessibility-extra-extra-extra-large`; Play is capped, so the board is unaffected) → the winning column-1 swipe (simulator touch path) → the result at AX5. Scrolling to the end: two upward touch-path drags.
* **Steps per device** (QA's E-T5 plus the controls):
  1. AX5 at offset 0 (`-01`);
  2. scrolled to the end (`-02`);
  3. live shrink → xxxL (`-03`);
  4. back to AX5, scrolled to the end again (`-04`);
  5. live shrink → `large` (`-05`);
  6. controls, shrinking without scrolling: AX5 → `large` (`-07`), AX5 → xxxL (`-08`).
  * Captures are taken 2 s after each `content_size` change (live Dynamic Type update, no relaunch).
* **Measurement:** `design/src/band-d2r.swift` compares the band region (y 60 pt to 54·s + 58 pt, full width) of a capture against its control. It reports the mean luma and the share of pixels whose luma differs by more than 8. Log: `design/runtime-d2r/band-measurements.txt`.
  * **Positive control:** each scrolled capture vs offset 0 — the band is drawn (mean luma ≈ 23 vs ≈ 39; 55 % differ).
  * **Negative control:** QA's pre-fix capture `QA-16-A11Y-back-to-large.jpg` vs QA's control `QA-16-A11Y-ax5-top-then-large.jpg` — 51.150 % differ, mean 24.62 vs 37.41. The tool flags the defect.
* **Restored afterwards:** content size `large` and Reduce Motion 0 on all three (checked); the app reinstalled on the 16 after the `integration_test` run. The simulators keep seeded L5 progress.

| Evidence ID | Kind | Screen / State | Viewport / Device | Artifact | Source Revision | Captured By | Captured At | Result / Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| RT-D2R-16 | runtime-screenshot | result L5 Perfect: AX5 offset 0, scrolled end, shrink → xxxL, shrink → `large`, controls | 393×852 iPhone 16 | design/runtime-d2r/RT-16-D2R-01 … 08.png | 3cd4a3b + WT | Frontend/Mobile Developer | 2026-09-28 20:10–20:12 | after both shrinks the band region equals its control: **0.000 %** differ (mean 39.25 / 37.78). `HARİKA` and the back button fully visible |
| RT-D2R-16e | runtime-screenshot | same | 390×844 iPhone 16e | design/runtime-d2r/RT-16e-D2R-01 … 08.png | 3cd4a3b + WT | Frontend/Mobile Developer | 2026-09-28 20:12–20:13 | **0.000 %** for both shrinks (39.22 / 37.76) |
| RT-D2R-pm | runtime-screenshot | same | 440×956 iPhone 16 Pro Max | design/runtime-d2r/RT-pm-D2R-01 … 08.png | 3cd4a3b + WT | Frontend/Mobile Developer | 2026-09-28 20:14–20:15 | **0.000 %** for both shrinks (38.13 / 36.79) |
| A11Y-D2R | accessibility | the text-size paths above; scrolled state keeps the band | 3 devices | design/runtime-d2r/band-measurements.txt | 3cd4a3b + WT | Frontend/Mobile Developer | 2026-09-28 20:23 | §16.11.1 (12) "band only when scrolled" holds after live shrinks; positive and negative controls behave |
| RV-D2R-16-win | runtime-video | full-motion win, L5 row 2, Reduce Motion off (two runs) | 393×852 iPhone 16 | design/runtime-d2r/RV-16-D2R-win-L5.mp4, RV-16-D2R-win-L5-2.mp4; timing-d2r.txt | 3cd4a3b + WT | Frontend/Mobile Developer | 2026-09-28 20:18, 20:20 | row on its cells (0.00 pt) through +599 / +597, first moves +632 / +614; first result pixel **+714** both; `HAMLE` final +730 / +731; pill at rest **+964 / +947**; stars +1285 / +1282. See the note below |
| RV-D2R-16-retry | runtime-video | Retry from the Perfect result ("Tekrar oyna" link) | 393×852 iPhone 16 | design/runtime-d2r/RV-16-D2R-retry-L5.mp4; RT-16-D2R-09-after-retry.png | 3cd4a3b + WT | Frontend/Mobile Developer | 2026-09-28 20:18 | flight in the rail +32 … +98; board final **+330**, HUD +315 (≤ 400); after: `HAMLE 0`, restarted grid |
| AND | accessibility | Android | — | — | — | — | — | not run — stated limit (ANDROID-CI-EVIDENCE) |

**Note on the pill cell (+964 in run 1).** The pill region's luma is 222.39 at +930 in run 1 and 222.33 at +934 in QA's pre-fix run `QV-16-r2-L5.mp4`; final is 223.4 in both. Run 1's last ≈ 1-luma step lands one capture frame later (+964 vs +951). Run 2 reads +947, the same as the Frontend's D2 table (947–950) and QA's E-X1 (948). The timeline code is outside the diff, so this is capture-frame jitter within the method's ± one frame, not a timing change. Both traces are in `timing-d2r.txt`.

**Videos:** raw `simctl io … recordVideo` captures, re-encoded at 2 px / pt with `design/src/video-d2.swift encode` and cut into win and retry segments (the timing tool reads "final" values at the end of a clip). The raw `.mov` files are not committed, as in D2. A first recording attempt was lost when a shell timeout ended `recordVideo` before the win (no frames); it was discarded and re-recorded.

## 12. Implemented Files

* **`app/lib/play/widgets/result_view.dart`**
  * `_onScroll` now reads `_scroll.position.pixels` after a `hasClients` guard; the doc comment records §20.9 (1) and why a listener alone is not enough.
  * New `_onMetrics(ScrollMetricsNotification)` calls `_onScroll` for depth 0 and returns `false`, so the notification keeps bubbling.
  * `build`: the column's `SingleChildScrollView` is wrapped in `NotificationListener<ScrollMetricsNotification>(onNotification: _onMetrics)`. The scroll view's arguments are unchanged.
* **`app/test/rating/result_view_test.dart`** — the new group (§17), using the file's existing `_pumpResult` harness and the real fonts.
* **`design/src/band-d2r.swift`** — CoreGraphics / ImageIO only (no PIL on the host); usage in its header.

## 17. Test Evidence by Task

**Gates on the final tree** (2026-09-28, macOS host, Flutter 3.32.8, HEAD `3cd4a3b` + WT):

| Command | Target | Result |
| --- | --- | --- |
| `melos run analyze` | all packages + app | SUCCESS |
| `dart format --output=none --set-exit-if-changed app packages tools` | Dart code | 177 files, 0 changed, exit 0 |
| `flutter test` (in `app/`) | app | **512 passed** (503 + 9 new), 0 failed |
| `flutter test integration_test -d D0011CE7-6E50-4367-93FA-B323E81270BE` | iPhone 16 simulator, iOS 18.6 | **13 / 13 passed**, exit 0 — re-run because the diff touches `ResultView`, which `play_session_test` renders |

**Failing first and negative runs** (`result_view_test.dart`, 63 tests; the fixed source kept as a byte copy, SHA-1 `cc45d505…`, and restored after each run — hash verified):

| Run | Source | Result |
| --- | --- | --- |
| Before the fix | the HEAD `result_view.dart` (SHA-1 `8230f235…`) | **9 failed**, 54 passed — every new test; band read 1.0 where 0 / 0.48–0.56 was expected, with the offset already clamped |
| N1 | the HEAD source swapped in again after the fix | **9 failed**, 54 passed |
| N2 | the fix with the listener detached (`onNotification: (_) => false`) | **9 failed**, 54 passed — the listener is what carries the fix |
| Fixed | `cc45d505…` | **63 passed** |

| Task / behaviour | Test (file → name) | Type | Proves |
| --- | --- | --- | --- |
| §20.9 (1) band → 0 after a shrink to 1.0× | `result_view_test.dart` → "{390, 393, 440} pt, AX5 scrolled → 1.0x: no band over the badge and back button" (3) | widget, real fonts, live `textScaleFactorTestValue` change | at AX5, scrolled to the end, band 1; after the drop: max extent 0, pixels 0, `ScrollBand.visibility` 0, no `Opacity` painted inside the band, `LoopBadge` and the back button present |
| same, shrink to the 1.3× cap | "… AX5 scrolled → 1.3x: …" (3) | same | same assertions at the cap |
| Partial band for a clamped offset | "… AX5 scrolled → 2.1x (still scrolls, offset clamped below the fade distance): the band matches the clamped offset" (3) | same | max extent in (0, 12) (5.8 / 6.7 / 6.2 pt), pixels = max extent, band = pixels / 12 (≈ 0.48–0.56) |
| No regression | the existing text-scale group ("… at AX5: scrolls, back fixed, lands at 0, band only when scrolled …") and the rest of the app suite | widget | unchanged and green |
| Runtime | Visual Parity Evidence above | runtime + video | the rule on three devices; the timeline unchanged; Retry intact |

**Isolation:** widget tests use the standalone `ResultView` harness (no controller, no persistence) with the test engine's text scaler; the live Dynamic Type change on the simulators is the real app path.

## 18. Test Notes

* **Entry-path matrix (retro bugfix):** the band is local view state of `ResultView`, which is the only result surface. Every way into the result (Home CONTINUE, resume, Next into a level, Retry and re-solve) mounts a fresh `ResultView` at offset 0. The failing path needs a metrics change while scrolled; covered causes are a live OS text-size change down (to 1.0×, the cap and an intermediate scrollable size) and, by the same code path, any other extent change. Text size up while at offset 0 leaves the band at 0: `RT-16-D2R-06` (`large` → AX5 at offset 0) equals `RT-16-D2R-01` in the band region, 0.000 % differ.
* **Why the probe scale 2.1×:** a sweep of 1.30–3.10 on the three widths found 2.10 as the size where the column still scrolls but less than the 12-pt fade distance, so the partial-band case is exercised. The sweep was a throwaway test file, deleted afterwards.
* **Not proven here:** Android (stated limit); a physical device; VoiceOver / the focus ring are untouched by the diff.

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE) — F03-FE-D2R

* **Completed Tasks:** F03-FE-D2R — the band follows the scroll position after metrics changes; 9 failing-first tests with two negative runs; suites and `integration_test` green; runtime text-size paths on the iPhone 16 / 16e / Pro Max and the win + retry smoke (F03.D2R-PARITY).
* **Remaining Tasks:** the Tech Lead's rework checkpoint (gate → Ready for QA), then F03-QA-D2R.
* **Blockers:** none.
* **Status Suggestion:** Needs Tech Lead Review.

---

## 19. Sonraki Komut (F03-FE-D2R)

```text
Run Tech Lead
```
