# F05 — journey-progression: Frontend Delivery (Phase D3 — Home + app shell)

> **Task:** F05-FE-D3 (Frontend/Mobile Developer, 2026-09-29). **Contract:** `architecture.md` §18.3 and the visual-gate rulings §18.7 (rulings 1–5, corrections C1–C3). **Handoff:** `ui-design.md` (D3) §4–§12, acceptance list §11.1.
>
> The previous file (the F05-FE / F05-FE3 delivery reports, 2026-09-08 … 2026-09-27) is archived byte for byte as `history/f05-journey-progression-2026-09-29/frontend-before-phase-d3.md` (SHA-1 `d32a5ad0…`).
>
> **Provenance of this delivery:** HEAD `7c1a946` + working tree (uncommitted). `app/` fingerprint `b4ad263e…` = `git ls-files -co --exclude-standard app | grep -v '^app/build/' | sort | xargs shasum | shasum`.

---

## 1. Feature Summary

Home, the app's first screen, is rebuilt on the Loop Glass composition `S-06b`:
* the `Looplet` wordmark;
* the glass Journey card with `YOLCULUK · N / 30`, a per-situation headline with one lime word, and the new **loop track** — a window of five levels (direction A, "sliding five");
* one lime "Devam et" / "Tekrar oyna" pill with its glow, and the caption of where it leads.

The app shell joins it:
* the native launch (iOS; Android light, dark and API 31+) and the Flutter splash are one picture — the Foundation ground — with no white frame (A-4);
* the store-error screen is a Turkish glass card that never shows the raw exception to players (A-3);
* Home fits at AX5 with no clipping and no scroll (A-2 home).

**The N1 rule is live:** with all 30 levels complete and a replay in progress, CONTINUE resumes the replay; the terminal state is `continueTarget == null`, never `allComplete`.

## 2. Impacted Files

**Created**
* `app/lib/design/components/track.dart` — `LoopTrack` + `LoopTrackGeometry` (design-layer addition, §18.3 (3)).
* `app/lib/journey/journey_home_view.dart` — the pure Home view-model: window rule, C1 copy rule, CTA rule.
* `app/lib/shell/shell_layout.dart`, `shell_wordmark.dart`, `splash_screen.dart`, `store_error_screen.dart`, `shell_strings.dart` — the app shell.
* `app/tool/render_launch_backdrop_test.dart` — renders the native launch image from `LoopBackdrop` (not part of `flutter test`).
* `app/android/app/src/main/res/values/colors.xml`, `values-v31/styles.xml`, `values-night-v31/styles.xml`, `drawable-nodpi/launch_backdrop.png`.
* Tests: `app/test/journey/journey_home_view_test.dart`, `app/test/design/loop_track_test.dart`, `app/test/shell/store_error_screen_test.dart`, `app/test/shell/launch_resources_test.dart`.
* Evidence tooling: `design/src/seed-d3.sh`, `capture-d3.sh`, `parity-d3.sh`; evidence in `design/runtime-d3/`.

**Updated**
* `app/lib/home_screen.dart` (rewritten), `app/lib/app_router.dart`, `app/lib/main.dart`, `app/lib/journey/journey_strings.dart`, `app/lib/design/components/info.dart` (`LoopNode` states), `app/lib/design/design.dart` (export).
* iOS: `Runner/Base.lproj/LaunchScreen.storyboard`, `Assets.xcassets/LaunchImage.imageset/*.png`, `Runner/Info.plist` (`UIStatusBarStyle`).
* Android: `drawable/` and `drawable-v21/launch_background.xml`, `values/` and `values-night/styles.xml`.
* Tests: `app/test/journey/journey_home_test.dart` (rewritten), `journey_home_live_test.dart`, `app/test/widget_test.dart`.

## 3. Task-to-Code Traceability

**F05-FE-D3 — Complete.**

| Brief item | Code | Behaviour |
| --- | --- | --- |
| (1) Home composition | `home_screen.dart` (`_HomeColumn`, `_JourneyCard`, `_SwirlPainter`), `shell/shell_layout.dart` | Wordmark (25, 58)·s; column top `115·s + 0.1·e`, 309·s wide; card 308·s, 300·s tall at 1.0×; CTA 22·s below; caption 17·s below. `_JourneyRing`, `_Wordmark`, `_ContinueCta`, `PlayStage` / `PlayTheme` removed from Home (pulse and bloom go with them, §18.7 ruling 4). |
| (2) CONTINUE rule + C1 | `journey/journey_home_view.dart` | CTA → `continueTarget`; terminal ⇔ `continueTarget == null`. Headline: complete (30 / 30) → replay (`inProgressLevel ∈ completedLevels`) → first (0 / 30, no session) → next. Caption `Seviye N` + ` · sürüyor` iff a session is in progress. |
| (3) Design layer | `design/components/track.dart`, `info.dart` | `LoopTrack`: window of five; centres on `y = 236 − 62·p^1.25`, gaps 50 / 64; lead-in iff the window starts after 1; tail iff levels follow and ≥ 48 pt of room; segments solid / gradient / dashed per the next node. `LoopNode` gains `open` / `locked` (dashed via the existing `DashedRRectPainter`) / `finish`; `LoopNode(number:, current:)` unchanged; per-state `Semantics` standalone; the track wraps everything in `ExcludeSemantics` and has no gesture. |
| (4) Loading + motion | `home_screen.dart`, `shell/shell_wordmark.dart` | No model → the splash frame (wordmark only). Entrance card 0–240, CTA 60–300, caption 120–340 ms, 10·s rise, `Cubic(.22,.61,.36,1)`, once per process (C3); reduced motion → at once; no idle motion. |
| (5) Text scale | `home_screen.dart`, `store_error_screen.dart` | Container text (wordmark, label, headline, node numerals, error label / headline) via `loopCappedTextScaler`; free text (CTA, caption, error body, error pill) at the OS scale; NBSP joins in the caption. |
| (6) Splash | `shell/splash_screen.dart` (`LoopSplashScreen`, `ShellFrame`) | `LoopBackdrop` + the wordmark at its Home position, fading 160 ms once per process (the progress is shared, so the splash → Home hand-off continues the same fade). |
| (7) Store error | `shell/store_error_screen.dart`, `shell/shell_strings.dart` | The §6 card + one `LimePill` (no glow, no icon); TR / EN strings; `debugPrint('store: bootstrap_failed — …')` in every build; details box only when `showDetails ?? kDebugMode`; above the cap the whole page scrolls under `ScrollBand`. Retry unchanged (`ref.invalidate(appBootstrapProvider)`). |
| (8) Native launch + ground | storyboard, `LaunchImage.imageset`, Android `drawable*/`, `values*/`, `main.dart` | iOS: `#070C25` background + the launch image aspect-filled edge to edge; light status bar at launch. Android: `@color/loop_ground` + `@drawable/launch_backdrop` (fill); `LaunchTheme` and `NormalTheme` on the drawable in light and dark; API 31+ `windowSplashScreenBackground` = the ground. `MaterialApp`: `title: 'Looplet'`, scaffold / canvas `#070C25`. The launch image is rendered from `LoopBackdrop` itself (ui-design §11 "Flexible"). |
| (9) Debug row (C2) | `home_screen.dart` (`_DebugRow`, `_checkDebugRow`) | `kDebugMode` only; bottom-anchored outside the column; measured after every layout-relevant change and `Offstage` whenever it would come within 12 pt of the caption. |
| (10) Strings | `journey/journey_strings.dart` | `Devam et` / `Tekrar oyna` / `YOLCULUK · N / 30` / four authored headlines / `Seviye N · sürüyor` / CTA semantics; EN dev table; no locale-blind casing. `columnTutorialHint` kept (D1 overlay). |

## 4. Authority Reconciliation

* **`ui-design.md` §6 / §11.1 (1) numbers vs its own renders.** The handoff's arithmetic makes the card exactly 300·s (label 11·s), so the CTA top is 486.3 pt on 393 × 852. The renders draw the label with `line-height: 1.25` (15.1 pt), so their card is 304.5·s and their CTA sits at 491.1 pt (measured in headless Chrome with the committed `D3-03` page). **Winning authority: the §6 numbers** (a §11 "Must not break" item, ±2 pt). Runtime: CTA lime band 487.0 pt (pill top ≈ 486, the band starts ~0.7 pt inside the pill). Consequence: every Home parity pair shows the render ~5.5 pt lower than runtime (7.5 pt at 1.3× / AX5); horizontal deltas are ≤ 0.5 pt. See §16 (1).
* **The glass card's 1 px edge.** `GlassCard`'s `BoxDecoration` border insets its child by 1 px per side, which made the card 302·s. The headline block's top padding is `31·s − 2`, so the card's outer box is 300·s. No shared component changed.
* **Retry shows the splash.** `_BootstrapGate` now passes `skipLoadingOnRefresh: false, skipLoadingOnReload: false`, so the splash frame shows while Retry re-runs the bootstrap (ui-design §4). Before, the previous error stayed on screen. Retry's behaviour is otherwise unchanged.

## 5. Components

* **`LoopTrack`** (new): display-only window of levels; exposes `hasLeadIn` / `hasTail` for tests; `LoopTrackGeometry` is pure.
* **`LoopNode`** (extended): `LoopNodeState { done, current, open, locked, finish }`, `extentFor`, `isLarge`, `spokenState`.
* **`ShellFrame`** / **`LoopSplashScreen`** / **`ShellWordmark`** / **`ShellLayout`**: the shared shell frame, splash, process-wide wordmark fade and geometry.
* **`StoreErrorScreen`** (moved from `app_router.dart` to `shell/`; still exported from `app_router.dart`).
* **`JourneyHomeView`**: the pure Home view-model.

## 6. Screens

| Screen | Route | Header / back |
| --- | --- | --- |
| Splash | `/` (bootstrap loading) | none; wordmark only |
| Home | `/` | none — app root; the wordmark is not a button; system back = OS default |
| Store error | `/` (bootstrap error / migration error) | none — app root; wordmark in place of a chevron; system back = OS default |

`/` ⇄ `/play` is unchanged. CONTINUE pushes `/play` with `PlaySessionArgs(source: journey, journeyLevel: ctaTarget)`.

## 7. State Management

* **Server / persisted state:** unchanged — `journeyProgressModelProvider` (live on progress and snapshot) and `appBootstrapProvider`.
* **UI state (Home):** the entrance controller and the per-process `_entrancePlayed` flag; the debug-row fit flag. **Shell:** the per-process wordmark fade progress.
* **Error state of the read-model:** a failing Journey model falls back to the new-player view with a working CTA (level 1), as the shipped Home did; it is logged.

## 8. API / Event Integration

Not applicable — no backend, endpoint or event. The only async inputs are the local read-model and the bootstrap, both unchanged.

## 9. Contract Compliance Check

| Area | Result |
| --- | --- |
| Screen / route contract (`/` ⇄ `/play`, no back on the root) | Preserved |
| Backend response / event mapping | Not Applicable |
| Error mapping (store error: Turkish copy, no raw exception outside debug, logged, Retry) | Extended (§18.3 (7)) |
| UI state / store state consistency (§6 read-model; terminal ⇔ `continueTarget == null`) | Extended (§18.3 (2) now implemented) |
| Navigation / back / header behaviour | Preserved |
| Async authority / lifecycle (live read-model warm == cold; entrance never replays on a return) | Preserved + C3 |

## 10. Behavior Preserved

* The §6 derivation, unlock, persistence, snapshot, route graph and F09 seam are untouched; `journey_home_live_test` (warm frontier, warm replay, warm win, warm == cold, corrupt snapshot) passes with only string updates.
* Play, the tutorial overlay and the result (D1 / D2) are untouched; the whole Play / result suite passes unchanged.
* `LoopNode(number:, current:)` renders and announces exactly as before; `components_test.dart` passes unmodified.
* Retry still calls `ref.invalidate(appBootstrapProvider)`; F08 data handling is unchanged.

## 11. UX Decisions

* **Loading:** the splash frame, no spinner; the entrance only when the model first arrives.
* **Semantics:** the progress is one node ("N / 30 seviye tamamlandı — Seviye M"); the CTA announces "Devam et, Seviye M[, sürüyor]" / "Tekrar oyna, Seviye 1"; the caption is excluded because the CTA already says it (no double reading); the track, nodes and arcs are excluded; the store error reads headline → body → "Tekrar dene"; its label, glyph and debug box are excluded.
* **Focus / press:** the shipped `LimePill` (0.98 press, periwinkle focus ring); no per-screen fork (RESULT-F00-COMPONENT-ALIGN stays open).
* **Debug details box:** capped at 1.3× — uncapped, a monospace identifier broke mid-word at AX5 (seen at runtime). Players never see it.
* **Self-check (advisory):** the runtime matches every render state; the composition, glow, halo and dashed locked edges are intact; no Material icon, `PlayTheme` or amber on Home, splash or the store error in a player build.

## Visual Parity Evidence

**Method.** Debug build (`flutter build ios --simulator --debug`) installed with `xcrun simctl install`; states seeded straight into the app's SQLite store with `design/src/seed-d3.sh` (then a cold launch); stills with `simctl io screenshot` (@3x); recordings with `simctl io recordVideo` (h264, variable frame rate) and read frame by frame with the F03 tool `video-d2.swift` (`trace` for per-region mean luma, `frames` for stills); text size with `simctl ui content_size`; Reduce Motion with `defaults write com.apple.Accessibility ReduceMotionEnabled`; touches with the simulator touch path. Parity with `design/src/parity-d3.sh` (F03 `parity-d2.swift`: lime bands in points + side-by-side composites) → `design/runtime-d3/parity-measurements.txt` and `PC-D3-*.jpg`.

**Devices:** iOS Simulator 18.6 — iPhone 16 `D0011CE7…` (primary, 393 × 852), iPhone 16e `6DBDFD97…` (390 × 844), iPhone 16 Pro Max `02FDE776…` (440 × 956). Restored afterwards to `large` and Reduce Motion 0 (checked).

**Debug-build deviations present in every capture (C2):** the debug row (smoke-puzzle launchers) at the bottom of Home at ≤ 1.3×; the details box on the store error. Release and profile builds cannot run on the simulator.

**Build note.** Home 1.0× rows on the iPhone 16 were captured on the first build. The later code changes (the debug row re-measured on a live text-size change, the capped debug text, the Reduce Motion guard) do not change those frames; `RT-16-n1-before-tap` (final build) equals `RT-16-D3-07` (first build) for the same state. All AX5, 16e, Pro Max, store-error and recording rows are from the final build.

| Evidence ID | Kind | Screen / State | Viewport / Device | Artifact | Source Revision | Captured By | Captured At | Result / Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| RT-D3-HOME-16 | runtime-screenshot | Home: new 0 / 30, level 1 started, mid 4 / 30, in progress 4 / 30, 12 / 30, 25 / 30, replay before 30 / 30, terminal, terminal + replay (N1) | iPhone 16 | design/runtime-d3/RT-16-D3-01-new-0of30.png, RT-16-D3-01b-…, RT-16-D3-02-…, RT-16-D3-03-…, RT-16-D3-04a-…, RT-16-D3-04b-…, RT-16-D3-05-…, RT-16-D3-06-…, RT-16-D3-07-… | 7c1a946 + working tree | Frontend/Mobile Developer | 2026-09-29 | PASS — every state, copy, window and node state equals the render; debug row present (debug build) |
| PC-D3-HOME | parity-comparison | the nine Home states | iPhone 16 vs render @2x | design/runtime-d3/PC-D3-01.jpg … PC-D3-07.jpg; parity-measurements.txt | 7c1a946 + working tree | Frontend/Mobile Developer | 2026-09-29 | Horizontal Δ −0.2 pt on every band. Vertical: runtime CTA lime band 487.0 vs render 492.5 (Δ −5.5): the render's own 4.8 pt drift from §6 (§4). Runtime meets the §6 anchor (486.3 ± 2). |
| RT-D3-VAR | runtime-screenshot | in progress 4 / 30; N1 | iPhone 16e, Pro Max | RT-16e-home-in-progress.png, RT-16e-home-terminal-with-replay.png, RT-promax-home-in-progress.png, RT-promax-home-terminal-with-replay.png | 7c1a946 + working tree | Frontend/Mobile Developer | 2026-09-29 | PASS; PC-D3-v-16e-ip / -n1 Δ −6.7 vertical, ±0.3 horizontal; PC-D3-v-promax-ip / -n1 Δ −5.2, +0.2 / −0.5 |
| A11Y-D3-HOME | accessibility | 12 / 30 at 1.3× and AX5 (live change from large); back to large; N1 at AX5 | iPhone 16; 16e (1.3×, AX5); Pro Max (1.3×) | A11Y-16-home-ip12-extra-extra-extra-large.png, A11Y-16-home-ip12-accessibility-extra-extra-extra-large.png, A11Y-16-home-ip12-back-to-large.png, A11Y-16-home-n1-ax5.png, A11Y-16e-home-w12-extra-extra-extra-large.png, A11Y-16e-home-w12-ax5.png, A11Y-promax-home-w12-extra-extra-extra-large.png | 7c1a946 + working tree | Frontend/Mobile Developer | 2026-09-29 | PASS — no clipping, no scroll, the headline keeps two lines, the caption breaks only before "·", the CTA label on one line; the debug row hidden at AX5 and shown again at large. PC-D3-10 / 10b / 10c Δ −7.5; 16e Δ −6.8; Pro Max Δ −6.2 |
| RT-D3-ERR | runtime-screenshot | store error forced (a non-database file as the store): normal (debug), AX5 top, AX5 scrolled to the end; after Retry | iPhone 16; 16e and Pro Max (normal) | RT-16-D3-20c-store-error-debug.png, A11Y-16-store-error-ax5-top.png, A11Y-16-store-error-ax5-scrolled-end.png, RT-16-store-error-before-retry.png, RT-16-store-error-after-retry.png, RT-16e-store-error-debug.png, RT-promax-store-error-debug.png | 7c1a946 + working tree | Frontend/Mobile Developer | 2026-09-29 | PASS for copy, card, glyph, pill, scrolling and the band. The debug box shows (debug build). Retry re-ran the bootstrap (second log line) and the screen returned because the store was still unreadable in-process (§16 (4)). PC-D3-20b Δ −12.7 (AX5 text metrics); 20c / 20d / v-*-err differ by the debug box height (render without or with a shorter message) |
| LOG-D3-ERR | runtime-screenshot | the exception is logged | iPhone 16 | `log show` excerpt: `flutter: store: bootstrap_failed — SqliteException(26): … file is not a database (code 26)` at 03:08:07.333 and again after Retry at 03:09:18.081 | 7c1a946 + working tree | Frontend/Mobile Developer | 2026-09-29 | PASS |
| RT-D3-N1-TAP | runtime-screenshot | N1: 30 / 30 + a replay of 12 → tap "Devam et" | iPhone 16 | RT-16-n1-before-tap.png, RT-16-n1-after-tap-play-L12.png | 7c1a946 + working tree | Frontend/Mobile Developer | 2026-09-29 | PASS — Play opens `SEVİYE 12` at its saved state (HAMLE 1, the seeded move) |
| RV-D3-COLD-EMPTY | runtime-video | cold start, empty store (store deleted), full motion | iPhone 16 | design/runtime-d3/raw/COLD-16-empty-store.mov; stills COLD-16-empty-2.1 / 2.6 / 4.0 / 4.2 / 4.395 / 4.6.png | 7c1a946 + working tree | Frontend/Mobile Developer | 2026-09-29 | PASS — the iOS open zoom (2.02–2.20 s) already shows the navy launch; from 2.20 s the full-frame mean luma stays ≤ 22 (no white or light frame); the card, wordmark and background regions do not change by ≥ 1 luma from 2.40 to 4.11 s, so the native → Flutter hand-off is invisible; the wordmark fades in 4.11–4.33 s; the card enters at 4.395 s |
| RV-D3-COLD-EXISTING | runtime-video | cold start, existing store (N1 state), full motion | iPhone 16 | raw/COLD-16-existing-store-n1.mov | 7c1a946 + working tree | Frontend/Mobile Developer | 2026-09-29 | PASS — no light frame after the open zoom (max 48.8 = Home at rest); hand-off invisible (1.99–2.84 s static); wordmark 2.84–3.05 s; card and CTA from 3.12 s, CTA at rest 3.26 s |
| RV-D3-COLD-RM | runtime-video | cold start with Reduce Motion | iPhone 16 | raw/COLD-16-reduce-motion.mov | 7c1a946 + working tree | Frontend/Mobile Developer | 2026-09-29 | PASS for the content — card and CTA appear in one frame (3.048 → 3.055 s: card 17.7 → 61.5, CTA 16.5 → 206.6). The wordmark still arrives over ~0.17 s: the iOS embedder's fixed 0.2 s cross-fade of the launch view (§16 (2)) |
| RT-D3-LAUNCH | runtime-screenshot | the native launch and the splash | iPhone 16 | COLD-16-empty-2.6.png (launch), COLD-16-empty-4.2.png (splash mid-fade), COLD-16-empty-4.395.png (splash, wordmark full); PC-D3-21.jpg, PC-D3-22.jpg | 7c1a946 + working tree | Frontend/Mobile Developer | 2026-09-29 | PASS — the same ground as `D3-21` / `D3-22`; the image is rendered from `LoopBackdrop` (`tool/render_launch_backdrop_test.dart`) |
| RT-D3-ANDROID | runtime-screenshot | Android launch (light / dark / API 31+) | — | — | — | Frontend/Mobile Developer | 2026-09-29 | **Not run** (ANDROID-CI-EVIDENCE). Resources are asserted by `launch_resources_test.dart` |
| RT-D3-RELEASE-ERR | runtime-screenshot | store error in a profile or release build (no exception text) | — | — | — | Frontend/Mobile Developer | 2026-09-29 | **PENDING** — the iOS Simulator cannot run profile or release builds, and no physical device was used. Covered by widget tests (`showDetails: false`) and the `kDebugMode` constant (§16 (3)) |

## 12. Implemented Files

* `app/lib/home_screen.dart` — rewritten: `HomeScreen` (stateful; entrance; C2 row; model-error fallback), `_HomeColumn`, `_JourneyCard`, `_SwirlPainter`, `_Enter`, `_DebugRow`.
* `app/lib/journey/journey_home_view.dart` — new: `JourneyHomeView`, `JourneyHeadline`.
* `app/lib/journey/journey_strings.dart` — D3 copy; `JourneyHeadlineText`; `journeyLabel`, `ctaSemantics`; NBSP caption. Removed: `progressUnit`, `allCompleteKicker`, `inProgressSuffix` (no other user).
* `app/lib/design/components/track.dart` — new: `LoopTrack`, `LoopTrackGeometry`, `_LoopTrackPainter`.
* `app/lib/design/components/info.dart` — `LoopNodeState`; `LoopNode` states, `extentFor`, `isLarge`, `spokenState`.
* `app/lib/shell/*` — new shell (§5).
* `app/lib/app_router.dart` — `_SplashScreen` and the English `StoreErrorScreen` removed; `LoopSplashScreen` / `StoreErrorScreen` wired; splash during Retry.
* `app/lib/main.dart` — title `Looplet`; scaffold / canvas `#070C25`.
* Native files and launch images (§2).

## 13. Performance Notes

* No blur; the glass is a gradient, an edge and shadows. The track is one `CustomPaint` plus five nodes; `shouldRepaint` compares states.
* At rest the entrance adds no `Opacity` layer (`_Enter` returns the child when t ≥ 1).
* **Debug pacing only.** In the debug build the first Home frame arrives mid-entrance (the recording's first content frame is already near rest), a JIT first-frame cost. Release pacing cannot be measured on the simulator (as in D2; FIRST-APP-DISTRIBUTION).

## 14. Assumptions

* The window's tail rule (≥ 48 pt of room) never triggers with five nodes and one large node — matching every render (no tail is drawn in `D3-01` … `D3-07`). The rule is implemented as specified and tested with an all-small chain.
* The launch image is aspect-filled on iOS (the crop is < 1 % on the three phones) and `fill`-stretched on Android; the soft gradient tolerates both.

## 16. Needs Tech Lead Clarification

Non-blocking; recorded for the checkpoint.

1. **The render's own vertical drift.** The renders sit 4.8 pt below their §6 numbers (label line-height 1.25). I implemented the §6 numbers ("Must not break"). Parity composites therefore show a constant 5–7.5 pt vertical offset with ≤ 0.5 pt horizontal deltas. Please confirm §6 as the authority, so QA reads the composites on that basis.
2. **Reduce Motion and the iOS launch cross-fade.** Flutter's iOS embedder removes the launch view with a fixed `UIView animateWithDuration:0.2` alpha fade (`FlutterViewController.mm`, `removeSplashScreenWithCompletion`), whatever the Reduce Motion setting. The grounds are identical, so under Reduce Motion the only visible effect is that the wordmark cross-fades in over ~0.2 s instead of appearing at once. Dart code cannot change this. Options: (a) accept it as platform behaviour; (b) put the wordmark into the native launch image (a bundled image, §18.3 (8)) so both sides of the cross-fade are the same picture — a design decision.
3. **Profile / release capture of the store error** (RT-D3-RELEASE-ERR). It needs a physical device or a distribution build. I propose tracking it as pending evidence tied to FIRST-APP-DISTRIBUTION; the rule itself is covered by tests and a compile-time constant.
4. **Retry cannot recover a store repaired while the app runs** (F08, observed, not changed). The open database connection (`appDatabaseProvider`) is not invalidated by Retry, so a store fixed in place still fails until the next launch; a relaunch recovers. This is pre-existing F08 behaviour and outside D3 (§18.5); F08 AC9's migration-failure case is unaffected.

## 17. Test Evidence by Task

All runs 2026-09-29 on the host (macOS, Flutter stable), working tree fingerprint `b4ad263e…`.

| Behaviour | Test (type) | Command / result |
| --- | --- | --- |
| Window rule — every `window-d3.txt` row; frontier 1–5 and 26–30; replay at 1, 2, 12 of 12, 29, 30; open frontier; current always in the window (all 30 × sessions) | `test/journey/journey_home_view_test.dart` (unit) | in `melos run test` |
| C1 headline / CTA / caption / semantics; terminal ⇔ `continueTarget == null` | same | same |
| Every §8 Home state, copy, nodes, CTA target | `test/journey/journey_home_test.dart` (widget, real fonts) | same |
| N1 warm, N1 cold (relaunch), replay cleared → terminal | same | same |
| Loading = splash frame; entrance at rest by 340 ms; no idle motion; no entrance on a return from `/play` or a remount; reduced motion; Reduce Motion switched on mid-fade | same | same |
| §11.1 (1) anchors at 1.0× (±2 pt) | same | same |
| 390 / 393 / 440 at 1.3× and 3.118×: no scroll, no overflow, capped container text, two headline lines, caption break before "·", one-line CTA | same | same |
| C2 debug row: shown at 1.0×, hidden at AX5, hidden and shown again on a live text-size change | same | same |
| Chrome: no back, no Material icon, one action, no future-scope item | same | same |
| `LoopNode` sizes, per-state semantics, greyscale-distinct edges; track geometry (no overlap, inside the card, rising line), lead-in / tail, display-only, excluded from semantics | `test/design/loop_track_test.dart` (unit + widget) | same |
| Store error: TR copy, no exception text with details off, logged once, debug box apart and out of semantics, layout at 1.0×, AX5 scroll + band on 390 / 440, gate: failure → error → Retry → splash → error again | `test/shell/store_error_screen_test.dart` (widget) | same |
| Native launch resources (Android themes light / dark / v31, no white or theme colour, drawable layers, image sizes; iOS colour, aspect fill, edges, status bar) | `test/shell/launch_resources_test.dart` (file assertions) | same |
| Live read-model (unchanged) | `test/journey/journey_home_live_test.dart` | same |
| App boots to the D3 Home; title and ground | `test/widget_test.dart` | same |

**Suites**
* `melos run analyze` — SUCCESS (all packages; `flutter analyze` in `app/`: no issues).
* `dart format --set-exit-if-changed app packages tools` — 189 files, 0 changed.
* `melos run test` — SUCCESS: `looplet_app` **565 passed**; `looplet_content` 17, `looplet_core` 22, `looplet_dictionary` 32, `looplet_authoring` 25, `looplet_solver` 23, `looplet_engine` 83 — all passed, 0 skipped.
* `flutter test integration_test -d D0011CE7…` (iPhone 16, iOS 18.6) — **13 / 13 passed** (it uninstalls the app afterwards; reinstalled for the later captures).

**Named negative runs** (each: one rule broken, the named suites run, the file restored from a byte copy and `cmp`-checked; `design/src/neg-d3.py`, run from `app/`):

| ID | Rule broken | Caught by |
| --- | --- | --- |
| NA | N1 reverted: `current = allComplete ? null : continueTarget` | 5 tests fail (N1 warm, N1 cold, CTA rule, replay 29 / 30, `termReplay` row) |
| NB | Window replay offset removed (`current − 4` always) | 7 fail (N1 warm / cold, replay state, open frontier, replay 29 / 30, `replay` and `termReplay` rows) |
| NC | Raw exception shown outside `kDebugMode` (`details = … \|\| true`) | 2 fail (TR copy / no exception text; 1.0× layout) |
| ND | `NormalTheme` back on `?android:colorBackground` (`values/styles.xml`) | 2 fail (theme test; no-white-resource test) |
| NE1 | Per-process entrance flag removed | 1 fails (no entrance on return / remount) |
| NE2 | Both entrance guards removed | 1 fails (same) |
| NF | "İlk" headline kept after level 1 starts | 2 fail (C1 widget and unit) |
| NG | Debug-row check not re-run on a live text-size change (the runtime defect below) | 1 fails (live 1.0× → AX5) |
| NH | Reduce Motion switched on mid-fade ignored by the wordmark | 1 fails |

A first NE variant (only the per-State guard removed) was **not** caught — correctly: the per-process flag still prevents the replay, so the rule held. NE1 / NE2 break the rule itself.

## 18. Test Notes

**Defects found at runtime and fixed in this delivery**
* **Debug row over the caption after a live change to AX5** (C2). The widget test set the text scale before the first frame, so it passed. At runtime the size changed while Home was mounted, and the fit check never re-ran (the builder did not depend on the text scale). Fix: Home's `State` depends on `textScalerOf` / `sizeOf` and re-measures after every such change. New test + NG.
* **Debug details text breaking mid-word at AX5** — now capped at 1.3×.

**Entry-path matrix (the N1 symptom and the shell)**
* Fresh store (cold) → Home new; existing store (cold) → Home per state; Home mounted while a session starts / ends / is replayed (warm) → updates in place; relaunch with a replay after 30 / 30 → "Devam et" → the saved replay (runtime + tests).
* Store unreadable → error screen → Retry → splash → error again (store still unreadable); relaunch with a good store → Home.
* Header / back: no back affordance on the splash, Home or the store error; `/play` exits land on `/` (unchanged D1 / D2 tests).

**Not captured at runtime:** the pressed and focused CTA (`simctl` cannot hold a touch or drive a keyboard focus) — covered by the shipped `LimePill` component tests; VoiceOver was not run.

---

## Local Orchestration Update (Frontend/Mobile Developer)

* F05-FE-D3 → Done; F05.D3-PARITY → PASS for the iOS Simulator scope, with two items split out as their own pending evidence (the profile / release store-error capture; Android stated as a limit); Delivery Review → Pending.
* Visual Scope is `new-surface`: implementation → QA needs the Tech Lead checkpoint (role-execution-contract §5). Current Owner = Next Role = Tech Lead; F05-QA-D3 stays Queued.

**Status Suggestion (non-authoritative):** Needs Tech Lead Review — the implementation checkpoint (→ Ready for QA) and §16 items 1–4.

## 19. Sonraki Komut

```text
Run Tech Lead
```
