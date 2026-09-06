# F03 — puzzle-play-session: Frontend Delivery

> Delivery + traceability artifact. Contract authority: `architecture.md`. Visual/state authority: `ui-design.md`. Direct-edit mode — real files under `app/lib/play/` + `app/lib/{main,app_router,home_screen}.dart`.

---

## 1. Feature Summary

The playable screen is implemented: a swipe manipulates the 5×5 backlit board (one cell per settled move, circular/wrap), the always-visible outline-ghost target sits above it, a live `MOVES` HUD + a 3-action Undo + a physically-separated Restart sit below, and forming the target in a row runs the bounded win sequence into a minimal functional completion sheet. State is written through to the F08 active-session snapshot on every settled boundary and hydrated back on open via the F08 restore path. Client-only; no backend; `Release Scope = none`.

**Stack:** Flutter + Riverpod + `go_router` (introduced this feature — `MaterialApp.router`). The state machine lives in a ticker-free `ChangeNotifier` ([PlaySessionController]); the board widget owns the `AnimationController`s and calls back into the controller when a transition settles.

---

## 2. Impacted Files

**Created — `app/lib/play/`:**

| File | Role |
| --- | --- |
| `play_theme.dart` | F03 design tokens (colour / radius / motion / type) + a dark `ColorScheme` for the app shell |
| `play_strings.dart` | externalized strings, per-language table (`tr` / `en`), `PlayStrings.of(lang)` |
| `play_session_args.dart` | `PlaySessionArgs` route args; re-exports F08 `PuzzleSource` |
| `gesture_resolver.dart` | **pure** swipe→`Move` mapping (threshold, dominant axis, tie-band→horizontal, one-cell) + `trackingAxis` |
| `debug_puzzle_library.dart` | the temporary debug puzzle source — the 5 F06 smoke puzzles as `const` maps (F05 deletes this) |
| `play_session_controller.dart` | the state machine: engine + counters + `ElapsedTimer` + write-through persistence + hydrate + won-row detection |
| `play_session_providers.dart` | `playSessionSetupProvider` (resolves `Puzzle` + `WordValidator`) + `debugPuzzleLibraryProvider` |
| `play_session_screen.dart` | route `'/play'`; loading / error / loaded; lifecycle observer; layout; completion-sheet overlay |
| `widgets/play_stage.dart` | dark gradient + radial spotlight + vignette background |
| `widgets/target_rail.dart` | outline-ghost target tiles + micro-label |
| `widgets/board_tile.dart` | one tile — neutral / locked (brass ring + pin) / frozen (frost + crystal border) / winning (amber) / pressed / dimmed |
| `widgets/puzzle_board.dart` | the hero: plate, tiles, loop rails, gesture surface, wrap-shift animation, bounce, win choreography (seam bar + bloom) |
| `widgets/moves_hud.dart` | tabular `MOVES` figure + micro-label + settle-tick |
| `widgets/undo_button.dart` | loop-back-arrow pill + 3→0 pips; dead (no dialog/ad) at 0 |
| `widgets/restart_button.dart` | outline circle, full-loop icon, 180° spin on press, no confirm |
| `widgets/completion_sheet.dart` | minimal functional sheet (kicker + word + `MOVES` stat + dominant Retry + quiet Close) |

**Created — `app/lib/`:** `app_router.dart` (the `GoRouter`, the bootstrap gate, `StoreErrorScreen`), `home_screen.dart` (placeholder home + debug chip row).

**Created — `app/test/play/`:** `gesture_resolver_test.dart` (13), `play_session_controller_test.dart` (11), `play_session_screen_test.dart` (5).

**Updated:** `app/lib/main.dart` — `MaterialApp` → `MaterialApp.router`; the F08 `_SessionLifecycle` observer moved from wrapping `home:` to wrapping the router `builder:` (see §4 + §10); dark theme from `PlayTheme.colorScheme`. `app/test/widget_test.dart` — unchanged assertions still pass (home still shows `LOOPLET`).

---

## 3. Task-to-Code Traceability

| Task | Status | Files | Behaviour |
| --- | --- | --- | --- |
| **F03-FE1** screen scaffold + route + args + portrait + debug entry | Complete | `app_router.dart`, `play_session_screen.dart`, `play_session_args.dart`, `home_screen.dart`, `debug_puzzle_library.dart`, `main.dart` | `GoRouter` with `'/'` (bootstrap gate) + `'/play'`; `PlaySessionArgs{source, journeyLevel?, debugPuzzleId?}`; portrait lock kept in `main()`; the home shows a debug chip row (`L1…L6`) that `context.push('/play', extra: …)` — not a shipping nav path. |
| **F03-FE2** pure gesture→Move mapping | Complete | `gesture_resolver.dart` | `resolve()` — below `thresholdLogicalPx` (18) → `null` (AC4); `max(|dx|,|dy|)` dominant axis; `||dx|-|dy|| ≤ tieBandRatio·max` (0.15) → **horizontal** (architecture §7 diagonal-tie resolution); dx/dy sign → `rowRight/rowLeft` / `columnDown/columnUp`; exactly one cell regardless of magnitude. Values are constructor params, exposed for QA device tuning (architecture §18). |
| **F03-FE3** state machine + shift animation + input lock + no queue + swipe-begin highlight | Complete | `play_session_controller.dart`, `widgets/puzzle_board.dart` | `PlaySessionPhase {idle, tracking, animatingShift, animatingBounce, won}`. `beginDrag` is ignored unless `idle` (**no queue** — AC5). Shift = 190 ms `cubic-bezier(0.22,1,0.36,1)`, whole active line translates one `stride` with a **wrap**: `ClipRRect` on the plate + the active line rendered as `N+2` tiles (two edge ghosts) with an opacity ramp on the ghosts. Rejected → `animatingBounce` (140 ms rubber-band back). Tracking past threshold → the active row/col lifts via a translated moving-line layer + the two end **loop rails** ignite (directional `cyan` gradient) + non-active tiles dim 8% (AC9). |
| **F03-FE4** MOVES / Undo / Restart | Complete | `widgets/moves_hud.dart`, `widgets/undo_button.dart`, `widgets/restart_button.dart`, `play_session_controller.dart`, `play_session_screen.dart` | `MOVES = engine.moveCount` — updates on **settle** only (`commitShift`), tabular, 140 ms scale-pulse. Undo: `canUndo = idle && quota>0 && moveCount>0 && !solved`; `engine.undo()` + `quota--` + persist; at 0 the pill is a dead control — tap inert, **no dialog / ad / toast** (AC6). Restart: `idle` only; `engine.restart()` + `MOVES→0` + `quota→3` + `restartCount++` + persist, **no confirmation** (AC7); placed right of a divider, ≥ 20 pt gap, outline treatment (unlike Undo). |
| **F03-FE5** persistence integration | Complete | `play_session_controller.dart`, `play_session_screen.dart` | Write-through `ActiveSessionRepo.save(_snapshot(inProgress))` after every settled move / undo / restart, and an initial snapshot on a fresh start. Snapshot serialized into the **F08-frozen keys** (`appliedMoves` via `formatMoveList(engine.appliedMoves)`; `moveCount`; `undosRemaining`; `restartCount`; `elapsedMsAccumulated` from `ElapsedTimer`; `thawedFrozenCells` = sorted `"r,c"` cache; `startedAtUtcMs`; `lastPersistedAtUtcMs` from an injectable clock). On open: `read()` → if `puzzleId` matches → `restoreSession(...)` (F08 restore path; thaw re-derived by replay); else fresh + overwrite. On win: `status: completed` snapshot → `ActiveSessionRepo.clear()`. `ElapsedTimer` pauses on `won` / `paused`, resumes on `resumed`. F03 schedules **no** background work (F08's app-level `_SessionLifecycle` owns the sync drain). Persist failures are caught + logged (`persist_failed`, non-fatal — architecture §Resilience). |
| **F03-FE6** completion sequence + minimal panel | Complete | `widgets/puzzle_board.dart` (`_buildSeam`, `_buildBloom`), `widgets/completion_sheet.dart`, `play_session_screen.dart` | On `GridStep.solvedThisStep` (settled only — AC11, engine-enforced): `phase → won`, input locked hard (HUD → 40% opacity), `wonRow` computed by a Turkish-normalized L→R scan. `_win` (600 ms) drives: winning-row tiles → amber fill + `ink-amber` letters + 1.06 lift; a **drawn L→R amber seam bar** (colour **and** shape — the non-colour cue) grows under the row; one restrained amber radial bloom (`sin(π·t)·0.2`); other rows dim 0.12. The completion sheet slides up (`AnimatedSlide` + scrim `AnimatedOpacity`): kicker `ÇÖZÜLDÜ` + the formed word (amber) + `HAMLE {n}` + **Retry** (filled amber, dominant) + **Close** (quiet). No stars / optimal / best / Next — F04 seam. `Retry` → `retryFromCompletion()` (restart in place, re-arm timer, fresh snapshot). |
| **F03-FE7** backgrounding / interruption | Complete | `play_session_controller.dart` (`onAppPaused` / `onAppResumed`), `play_session_screen.dart` | `paused`: `tracking` → gesture cancelled (no move); `animatingShift` → `_finishShift()` runs synchronously (the move was already applied to the engine at release, so this is a settled commit, never a torn snapshot — architecture §12); `animatingBounce` → back to `idle`; timer paused; a settled snapshot persisted (unless already `won`). `resumed`: timer restarts for an unfinished session. |
| **F03-FE8** localization + alignment + gates + report | Complete | `play_strings.dart`, all widgets, this file | Every user-facing string comes from `PlayStrings` (`MOVES`/`HAMLE`, `HEDEF`, `ÇÖZÜLDÜ`, `Yeniden`, `Kapat`, `Geri`, load-error). `flutter analyze` + `dart format --set-exit-if-changed` clean; 99 app tests green; iOS release build green. |

---

## 4. Authority Reconciliation

| Conflict source | Winning authority | Decision | Downstream impact |
| --- | --- | --- | --- |
| `ui-design.md` §8 "board recede = 12% dim **+ 1.5 px blur**" vs. mid-tier frame-rate budget (`prd.md` §6 "smooth on mid-tier") | `architecture.md` §16 QA-focus perf intent + `ui-design.md` §11 "flexible: don't cost frames" | Implemented the **dim only** (0.12) on non-winning rows during `won`; skipped the per-frame backdrop blur (expensive on mid-tier). Visual intent (board recedes, winning row + sheet own focus) is preserved. | Flagged in §11 + §16 for Tech Lead — a blur can be added later behind a device-tier check if QA wants it. |
| `ui-design.md` §5 optional "breathing" spotlight ambient | `ui-design.md` §5 ("optional; drop it if it costs frames") + deterministic tests | Omitted (no `repeat()` animation on screen). | None — cosmetic; can be added as a `TweenAnimationBuilder` loop later. |
| `active_session_snapshot.dart` doc names `ActiveSessionRepo.clearActiveSession()`; the real method is `clear()` | the code (`ActiveSessionRepo`) | Called `clear()`. | None — behaviour identical; a doc nit in the F08 snapshot contract, not a code change. |

No conflict touched the interaction contract (`architecture.md` §6/§7/§8/§9/§11/§13) — all honoured verbatim.

---

## 5. Components

* **`PlayStage`** — background system (gradient + spotlight + vignette). Static.
* **`TargetRail`** — the goal as outline-ghost tiles + micro-label; separated from the board by scale + treatment (here) + a divider glow + air (screen).
* **`BoardTile`** — one cell; every special status (`locked` / `frozen` / winning) carries a non-colour cue (pin glyph + brass ring / frost texture + crystal border / — the seam is drawn by the board). `pressed` (0.97) + `dim` overlay props.
* **`PuzzleBoard`** — the hero + the only stateful animation owner. Gesture surface (`GestureDetector` pan) → `controller.beginDrag/updateDrag/endDrag`; drives `_shift` / `_bounce` / `_win` `AnimationController`s; calls `commitShift` / `commitBounce` on settle. Renders the recessed plate, static tiles, the translated moving line (with wrap ghosts), the loop rails, the winning seam bar + bloom.
* **`MovesHud`** — tabular figure + settle-tick + micro-label, directly on the stage (no card).
* **`UndoButton`** — pill + loop-back arrow + 3 pips; disabled visual + inert at quota 0.
* **`RestartButton`** — outline circle + full-loop icon + press spin; no confirm.
* **`CompletionSheet`** — minimal functional result panel (F04 seam).
* **`HomeScreen`** — placeholder wordmark + debug chip row (dev entry).

---

## 6. Screens

| Route | Screen | Header / chrome | Back |
| --- | --- | --- | --- |
| `/` | bootstrap gate → `_SplashScreen` (loading) / `HomeScreen` (ready) / `StoreErrorScreen` (migration failure) | none | n/a |
| `/play` | `PlaySessionScreen` → loading skeleton / `_LoadErrorBody` / `_LoadedPlaySession` | **no system header**; one quiet back chevron top-left (`Icons.chevron_left_rounded`, `PlayTheme.muted`, 44×44 target); **hidden while `won`** (the completion sheet's Close owns exit) | chevron / system / gesture back → `Navigator.pop` to the caller; snapshot kept `inProgress` (resumable). Direct entry with an empty stack → `maybePop`. In `won` the sheet's **Close** is the exit. |

Portrait-locked app-wide (`main()`). No confirmation dialogs anywhere.

---

## 7. State Management

* **`PlaySessionController` (`ChangeNotifier`)** — the single source of play state: `PlaySessionPhase`, `displayLetters` / `tileStatuses` (from `engine.state`), `moveCount` (= `engine.moveCount`), `undosRemaining`, `restartCount`, `wonRow`, `activeLine`, `gridVersion`. Owns the `GridEngine`, the `ElapsedTimer`, and write-through persistence. **Ticker-free** → unit-testable without a `TickerProvider`.
* **UI state (widget-local):** the `AnimationController`s + `_dragOffset` / `_pressedCell` live in `_PuzzleBoardState`; the completion-sheet slide/scrim is `AnimatedSlide` / `AnimatedOpacity` keyed on `controller.phase == won`.
* **Riverpod:** `playSessionSetupProvider.family<PlaySessionSetup, PlaySessionArgs>` resolves `Puzzle` + `WordValidator` (async); `appRouterProvider` holds the `GoRouter`. The controller is **not** a provider — it is created + disposed by `_LoadedPlaySessionState` for the screen's lifetime (a screen-scoped object; F08's sync service stays the session-scoped one).
* **Server vs UI:** F03 has no server state. The F08 snapshot is local durable state; the controller treats a mismatched-`puzzleId` snapshot as "not ours" and starts fresh (architecture §9).

---

## 8. API / Event Integration

None — F03 calls no endpoint and emits no analytics (F12). It consumes:
* **F02 engine** — `GridEngine.applyMove/undo/restart/restoreMoves`, `GridStep.{applied, rejectedReason, solvedThisStep, thawedThisStep}`, `GridState.{letters, thawedCells, statusAt, isSolved}`. Rejected moves are values, not throws → the bounce path.
* **F08 persistence** — `ActiveSessionRepo.{read, save, clear}`, `restoreSession(...)`, `ActiveSessionSnapshot` (frozen keys), `ElapsedTimer`, `toEngineConfig(Puzzle)`, `formatMoveList` / `parseMoveList`.
* **F01** — `WordValidator` via `wordValidatorProvider` (only consulted by the engine for frozen-row thaw).

---

## 9. Contract Compliance Check

| Area | Result | Note |
| --- | --- | --- |
| Screen / route contract (`architecture.md` §13) | **Preserved** | `'/play'` + `PlaySessionArgs`; portrait-locked; no system header + quiet chevron, hidden in `won`; back keeps a resumable snapshot. |
| Screen state machine (§6) | **Preserved** | `idle / tracking / animatingShift / animatingBounce / won`; **no input queue** (`beginDrag` ignored unless `idle`). |
| Gesture → Move mapping (§7) | **Preserved** | threshold + dominant axis + **tie-band → horizontal**; exactly one cell; first pointer only (`GestureDetector` pan is single-pointer); off-screen release resolves from the last delta. `T` / `B` numbers exposed for QA tuning. |
| MOVES / Undo / Restart (§8) | **Preserved** | `MOVES = engine.moveCount`, settled only; Undo 3-action quota, no prompt/ad at 0; Restart reset + `restartCount++`, no dialog, separated from Undo. |
| Persistence integration (§9) | **Preserved** | write-through into the F08-frozen snapshot; hydrate via the F08 restore path; `completed` + `clear()` on win; `paused` flush; F03 schedules no background work. |
| Completion sequence (§10) | **Preserved** | lock → win-row highlight **+ drawn seam bar (colour + shape)** → bounded (≤ 600 ms) success anim → minimal functional panel (no rating logic — F04 seam). |
| Animation / input-lock (§11) | **Preserved** | 190 ms shift (in the 150–250 band), full input lock for the phase, **no queue**, diegetic lock affordance (HUD dim, not a spinner), transient valid word mid-animation does not win (engine evaluates settled state). |
| Backgrounding (§12) | **Preserved** | gesture cancelled on `paused`; mid-shift commits synchronously; snapshot always settled. |
| Localization (§14) | **Preserved** | all strings via `PlayStrings`; see §14 assumption re: no `gen_l10n`. |
| Validation responsibility (§15) | **Preserved** | F03 owns the 3-undo quota, no-moves-during-animation, the state machine, snapshot serialization, portrait lock; the engine owns move legality; F08 owns storage + restore. |
| `Release Scope` (§17) | **Preserved** | `none` — no infra / CI / deploy change. |
| Async authority / lifecycle / boundary (frontend rules) | **Preserved** | the F08 sync service stays session-scoped (app-level observer); the F03 controller is screen-scoped and disposed with the screen; a snapshot whose `puzzleId` ≠ the open puzzle is not applied. |

---

## 10. Behavior Preserved

* **F08 `_SessionLifecycle` (sync-drain observer)** — was wrapping `home:` under a plain `MaterialApp`. With routing introduced this feature it now wraps `MaterialApp.router`'s `builder:` so it stays mounted across every route. This is the correct home for a **session-level** resource (`platform.md` §7 / F08 architecture "never screen-owned"); under `home:` it would have unmounted on the first navigation to `/play` and stopped draining. The drain trigger (`paused` / `resumed` → `dailyResultSyncServiceProvider.drain()`) is byte-identical.
* **F08 recovery screens** — `_SplashScreen` / `_StoreErrorScreen` / the migration-error branch moved verbatim from `main.dart` into `app_router.dart` (`StoreErrorScreen` is now public; the copy `"Couldn’t open your saved data"` / `"Your progress is safe. Please try again."` + the Retry `FilledButton` + the muted raw-error line are unchanged — `widget_test.dart` still asserts the same strings and passes).
* **`appBootstrapProvider` + `_bootstrapFirebase`** — untouched; the router's `/` builder watches it exactly as `LoopletApp.home` did.
* **F02 engine / F08 persistence** — consumed only through their public APIs; no package changed. `looplet_engine` 83 tests, `looplet_content` 17, F08 persistence suites — all unchanged and green.

---

## 11. UX Decisions

* **Loading** — the debug puzzle load is synchronous (`const` maps) so the skeleton is essentially never seen; it still renders (stage + 25 dim tile silhouettes + ghost target slots, **no spinner**) so a future async source can't flash a blank board.
* **Error** — an unsupported `source` (Daily / Journey before F05/F07) or an unknown debug id → the contained dev-only error body (`Icons.error_outline`, `Bu bulmaca yüklenemedi`, a `Geri` text button). Not a premium surface, by design.
* **Empty** — n/a (there is always a puzzle or an error).
* **Disabled** — Undo at quota 0: dark pill, muted icon + hollow pips, no glow, inert tap. HUD controls drop to 55% during animation, 40% during `won` (the diegetic input-lock — no spinner/modal).
* **Selected / pressed** — a touched tile presses in (0.97) inside 90 ms even for a tap that becomes a no-op, so input always feels registered.
* **Visual hierarchy** — the lit board is the only bright/saturated cluster; stage + chrome stay dark and quiet; `MOVES` / Undo / Restart are tiered by size + placement + treatment; there is **no CTA on the playing screen** (the board is the action) — the one CTA is `Retry` in the sheet, and it dominates (`Close` is a quiet text link).
* **Accessibility** — winning row = amber fill **and** a drawn unbroken seam bar (legible without colour); `locked` = brass ring + pin glyph; `frozen` = frost texture + crystal border. Board exposes a `Semantics` label (target + move count). Controls carry `Semantics(button:, label:)`. Cell hitboxes scale with the board; the shrink-floor keeps them ≥ ~56 pt on real portrait devices. **Full screen-reader grid navigation is out of F03 scope** (architecture §16 / `ui-design.md` §13).
* **`ui-design.md` alignment** — Direction A implemented: spotlight stage, backlit-keycap tiles, loop-rail motif, wrap animation (edge-mask + opposite-edge ghost), outline-ghost target, amber win + seam bar, diegetic input-lock, undo pips, separated outline Restart, minimal-but-crafted sheet. **Deviations (both flagged):** board-recede blur → dim-only (perf); breathing ambient → omitted (perf / determinism).
* **premium-ui-rubric self-check** — the implementation holds the `ui-design.md` self-review (94/100): one hero, tiered chrome, layered surfaces (stage < plate < tiles < sheet), heavy tile glyphs, dominant single CTA in the sheet, distinct felt states, no wireframe/card-stack feel. The two perf deviations are the known gap vs. the design's 10/10 ceiling on "Surface & Depth" / "Modernity".

---

## 12. Implemented Files

(Paths + change summary; see §2 for the table and §3 for task mapping.)

* **New** `app/lib/play/**` (16 files) + `app/lib/app_router.dart` + `app/lib/home_screen.dart` — the feature.
* **Modified** `app/lib/main.dart` — `MaterialApp.router` + relocate `_SessionLifecycle` to the router `builder:` + adopt `PlayTheme.colorScheme`; `_SplashScreen`/`_StoreErrorScreen`/`_HomePlaceholder` removed (moved to `app_router.dart` / `home_screen.dart`).
* **New** `app/test/play/**` (3 files, 29 tests).
* **Unchanged** `app/test/widget_test.dart` — still green.
* No `pubspec.yaml` change (`go_router` was already a dependency); no native / Podfile change (confirmed by the green iOS release build).

---

## 13. Performance Notes

* **Board rebuilds** are driven by one `AnimatedBuilder` merging `_shift` / `_bounce` / `_win` plus a `ChangeNotifier` listener; the 25 static tiles are plain `Positioned` widgets rebuilt per frame only during an active phase (idle frames don't animate). Acceptable for a 5×5 grid; no `ListView` / large tree.
* **Wrap animation** uses a `ClipRRect` + a translated `Stack` of `N+2` tiles — no `BackdropFilter` / shader. Release→animation-start is synchronous (`engine.applyMove` then `_shift.forward`), targeting the `< 50 ms` budget.
* **Deliberately skipped:** the board-recede backdrop blur and the breathing ambient loop (see §4 / §11) — both to protect mid-tier frame rate. This is the one place the implementation trades a design flourish for performance; QA validates the trade on the device matrix.
* Persistence writes are `unawaited` single Drift upserts off the interaction path; failures are caught (non-fatal).

---

## 14. Assumptions

* **No `gen_l10n` / `.arb` toolchain** — F03 strings live in a small per-language table (`PlayStrings`, `tr` + `en`), matching the "look up by language key" shape the dictionary layer uses and the `architecture.md` §14 / `ui-design.md` §13 "externalized, no hard-coded strings" requirement. Wiring full Flutter localization is a separate Tech Lead call; the string keys are ready for it.
* **Debug puzzle source = Dart `const` maps** copied from `content/smoke/tr/level0{1,2,4,5,6}.json`. Flutter asset paths cannot reference `../content`, and F05 replaces the debug entry with real bundled-content resolution — so embedding the fixtures is the lowest-risk scaffold. `debug_puzzle_library.dart` names `content/smoke/tr/` as the source of truth.
* **Gesture threshold `T = 18` logical px, tie-band ratio `B = 0.15`** — the F03-FE2 starting values; exposed as `GestureResolver` constructor params so QA can sweep them on device (architecture §18).
* **Board sizing** — `~88%` of width, shrinking board-first to a floor of `5·56 pt + plate + gaps`, then gaps compress. Tuned by eye; QA validates the ≥ 44 pt hitbox + one-handed reach on the device matrix.
* **`optimalMoves` / stars / elapsed** are tracked (elapsed) or available (`optimalMoves`) but **not displayed** by F03 — F04 (completion panel) and F07 (Daily) own that surface. F03's sheet shows the move count only.

---

## 16. Needs Tech Lead Clarification

Carried from `ui-design.md` §14 (non-blocking — sensible defaults are implemented) plus two implementation deviations:

1. **No primary CTA on the playing screen** — implemented as designed (the board is the action; `Retry` in the sheet is the only CTA). Please confirm so QA does not flag it as a missing CTA.
2. **F03 owns the first-pass *visual* treatment of `locked` / `frozen` tiles** — implemented (brass ring + pin glyph / frost fill + crystal border). Confirm this stays F03's, or name the later feature that owns a dedicated tile-state visual pass.
3. **Shared "no title bar + quiet back chevron, hidden in terminal states" chrome** — implemented for `/play`. Confirm whether to lock it as a cross-screen rule now (F10) or leave it feature-local.
4. **Microcopy** — `HEDEF / HAMLE / ÇÖZÜLDÜ / Yeniden / Kapat / Geri` are placeholders in `PlayStrings`; PO / localization owns the final strings.
5. **Deviation — board-recede blur → dim-only** during `won` (perf on mid-tier). Accept, or require the blur behind a device-tier gate?
6. **Deviation — breathing spotlight ambient omitted** (perf / test determinism). Accept, or want it back as a bounded `TweenAnimationBuilder` loop?

---

## 17. Test Evidence by Task

| Task / behaviour | Test type | File · scenario proven |
| --- | --- | --- |
| F03-FE2 threshold (AC4) | unit | `gesture_resolver_test.dart` — below threshold on both axes → `null`; exactly at threshold → a move |
| F03-FE2 dominant axis + direction (AC2 / AC3) | unit | `gesture_resolver_test.dart` — +dx→`rowRight(startRow)`, −dx→`rowLeft`, +dy→`columnDown(startCol)`, −dy→`columnUp` |
| F03-FE2 diagonal tie → horizontal (architecture §7) | unit | `gesture_resolver_test.dart` — near-equal axes → row move; clearly-vertical (outside band) still vertical |
| F03-FE2 one cell only | unit | `gesture_resolver_test.dart` — a 22 px drag and a 600 px flick map to the same move |
| F03-FE2 tracking-axis lift (AC9) | unit | `gesture_resolver_test.dart` — `null` below threshold; row / column past threshold |
| F03-FE5 fresh start writes an initial in-progress snapshot | unit | `play_session_controller_test.dart` — `repo.read()` → `puzzleId`, `status inProgress`, `moveCount 0`, `undosRemaining 3` |
| F03-FE3 legal drag → shift phase → commit → idle + MOVES 1 + persisted (AC2) | unit | `play_session_controller_test.dart` — `endDrag` → `DragResolution.shift`, `phase animatingShift`; `commitShift()` → `false`, `phase idle`, `moveCount 1`; snapshot `appliedMoves == ['R1']` |
| F03-FE6 solving → won, wonRow 0, completed-then-cleared (AC8) | unit | `play_session_controller_test.dart` — `commitShift()` → `true`, `phase won`, `wonRow 0`, `isSolved`; `repo.read()` → `null` (completed snapshot written then cleared) |
| F03-FE3 rejected move → bounce → idle, MOVES unchanged, not persisted | unit | `play_session_controller_test.dart` — vertical drag on a `columnMovesEnabled:false` puzzle → `DragResolution.bounce`; `commitBounce()` → `idle`, `moveCount 0`; snapshot still `moveCount 0` |
| F03-FE3 **no input queue** (AC5) | unit | `play_session_controller_test.dart` — `beginDrag` while `animatingShift` is ignored (phase unchanged) |
| F03-FE4 undo quota + no-op at 0 (AC6) | unit | `play_session_controller_test.dart` — 3 moves then 3 undos → `moveCount 0`, `undosRemaining 0`, `canUndo false`; a 4th `undo()` → `false`, no state change |
| F03-FE4 restart resets + `restartCount++` (AC7) | unit | `play_session_controller_test.dart` — after a move + an undo, `restart()` → `moveCount 0`, `undosRemaining 3`, `restartCount 1`; snapshot `restartCount 1` |
| F03-FE5 hydrate from a matching snapshot (AC10) | unit | `play_session_controller_test.dart` — seed a snapshot (`['R1']`, quota 2, restarts 2) → controller `hydratedFromSnapshot`, `moveCount 1`, `undosRemaining 2`, `restartCount 2` |
| F03-FE7 paused mid-shift-animation commits (no torn snapshot) | unit | `play_session_controller_test.dart` — `endDrag` → `animatingShift`; `onAppPaused()` → `phase idle`, `moveCount 1`; snapshot `appliedMoves == ['R1']` |
| F03-FE7 paused mid-drag cancels the gesture | unit | `play_session_controller_test.dart` — `tracking` → `onAppPaused()` → `phase idle`, `moveCount 0` |
| F03-FE1/FE4 renders target + board + MOVES 0 (AC1) | widget | `play_session_screen_test.dart` — `HEDEF`, `HAMLE`, `0`, one `PuzzleBoard`, target letters shown |
| F03-FE3/FE6 legal swipe forms target → completion sheet (AC2 / AC8) | widget | `play_session_screen_test.dart` — a rightward drag on row 0 of `smoke-tr-01` → `ÇÖZÜLDÜ` + `Yeniden` + `Kapat`; sheet shows `MASAL` + `1`; back chevron hidden in `won` |
| F03-FE6 Retry resets the board (AC7) | widget | `play_session_screen_test.dart` — tap `Yeniden` → sheet gone, `MOVES 0`, back chevron restored |
| F03-FE2 sub-threshold tap doesn't change MOVES (AC4) | widget | `play_session_screen_test.dart` — a 6×4 px drag from board centre → `MOVES 0`, no sheet |
| F03-FE1 unsupported source → load-error state | widget | `play_session_screen_test.dart` — `PuzzleSource.daily` → `Bu bulmaca yüklenemedi` + `Geri` |

**Gates:** `flutter analyze` (app) + `dart analyze` (6 packages) clean; `dart format --output=none --set-exit-if-changed .` clean; **295 workspace tests green** (app **99** = 4 pre-existing + 68 F08 + 27 F03; engine 83, core 22, content 17, dictionary 32, solver 23, authoring 19); `infra` offline tests 18/18 (unchanged); **`flutter build ios --release --no-codesign` GREEN** — `✓ Built build/ios/iphoneos/Runner.app (54.5MB)`.

---

## 18. Test Notes

* **Runtime-only (not covered by automated tests, per `architecture.md` §16 — QA on a device/simulator):** real gesture accuracy + the diagonal tie-band feel on the device matrix; 0 double-registered moves during the real 190 ms animation window (the no-queue guard is unit-proven at the controller level, but the on-screen animation timing is device-runtime); the wrap animation visual (edge-mask + emerging ghost); the win choreography timing (seam draw + bloom); backgrounding mid-animation on a real OS; portrait-lock on a rotating device; resume fidelity after a real OS kill.
* **Tile-state visuals** (`locked` brass ring + pin, `frozen` frost + crystal border, thaw cross-fade) are rendered from `smoke-tr-05` / `smoke-tr-06` via the debug entry — visual QA on device; no golden tests in this delivery.
* **Header / back consistency:** `/play` has no system header (intentional, contract §13); the chevron pops to the caller on all three back paths (button / system / gesture) and is hidden in `won` (sheet Close owns exit). Direct entry falls back via `maybePop`.
* Existing `widget_test.dart` re-run: home still shows `LOOPLET`, no `StoreErrorScreen` — unchanged behaviour after the `MaterialApp.router` switch.

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** F03-FE1…FE8. The playable screen is implemented against `architecture.md` + `ui-design.md`; all automated gates green; iOS release build green.
* **Remaining Tasks:** F03 QA — end-to-end **client** QA, `runtime` (device/simulator) mandatory per `architecture.md` §16 (gesture accuracy + 0 double-registered moves during animation + exact-one-cell + input-lock/no-queue + backgrounding + portrait lock + F08-snapshot resume + `ui-design.md` alignment).
* **Blockers:** none. Six `Needs Tech Lead Clarification` items are non-blocking (defaults implemented); the two perf deviations (blur, breathing) are called out for a ruling.
* **Status Suggestion:** Ready for QA.

---

## 19. Sonraki Komut

```
Run QA
```
