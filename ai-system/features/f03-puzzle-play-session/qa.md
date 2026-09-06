# F03 — puzzle-play-session: QA Report

---

## 0a. Evidence Mode Declaration

* **Bash / build access:** VAR
* **e2e test suite** (Detox / Patrol / `integration_test` on a device): **YOK** — no `integration_test/` suite was delivered; no device / simulator interactive session is available in this environment.
* **Screenshot / browser tool:** YOK
* **Runtime validation method:** **`automated functional`** (Flutter widget + unit tests, incl. a full gesture→shift→win→retry widget flow) **+ build gates**. The `architecture.md §16`-mandated **`runtime` (device/simulator)** evidence class **could not be produced** in this environment. `repeatable integration` (an on-emulator `integration_test`) was not delivered by Frontend.

Consequence (per `0a` source-only / tool-absence rule): the scenarios that `architecture.md §16` explicitly requires **device/simulator `runtime`** proof for are marked **Runtime Validation Pending** and folded into `## 17` + the Tech Lead Note. This is a tool-absence hand-off, not an approval.

---

## 0. Backend Build Gate

F03 touches **no backend** (`Release Scope = none`; no Cloud Function, no rules, no infra). The `infra/` suites are unchanged this feature. The client build/test gate (the canonical `melos` scripts) was run in full:

| Gate | Command | Result |
| --- | --- | --- |
| Format | `dart format --output=none --set-exit-if-changed .` | **PASS** — 121 files, 0 changed |
| Analyze (pure packages) | `dart analyze .` × `looplet_core / dictionary / engine / content / solver / authoring` | **PASS** — 5 clean; `looplet_solver` has **1 pre-existing `info`** (`curly_braces_in_flow_control_structures`, `solver.dart:56`, last touched in an earlier session, `dart analyze` exits 0) — **not F03**, non-blocking, noted in the Tech Lead Note |
| Analyze (app) | `flutter analyze` | **PASS** — No issues found |
| Unit + widget tests | `dart test` (6 packages) + `flutter test` (app) | **PASS — 295 / 295** (core 22, dictionary 32, engine 83, content 17, solver 23, authoring 19, **app 99** = 4 pre-existing + 68 F08 + **27 new F03**) |
| iOS release build | `flutter build ios --release --no-codesign` | **PASS** — `✓ Built build/ios/iphoneos/Runner.app (54.5MB)` |
| Android App Bundle | `flutter build appbundle --release` | **NOT RUN** — CI-only locally (no Android SDK on the dev machine; established posture, `system-state.md` §1) |

* compile PASS + widget-test runtime PASS verified separately (the 99 app tests execute the widget tree, gestures, animation pumps, and the win flow). **Real device/OS runtime not exercised** — see `0a`.
* **Gate decision: PASS → QA continues.**

---

## 1. Feature Summary

* **Feature under test:** F03 puzzle-play-session — the playable screen. A swipe manipulates the 5×5 backlit board one cell per settled move (circular/wrap), the outline-ghost target sits above it, a live `MOVES` HUD + a 3-action Undo + a physically-separated Restart sit below, and forming the target in a row runs the bounded win sequence into a minimal functional completion sheet. Play state is written through to the F08 active-session snapshot and hydrated back on open.
* **QA scope:** end-to-end **client** QA (no backend) + `ui-design.md` handoff compliance + navigation/chrome consistency, per `orchestration.md → QA Scope` and `architecture.md §16`.

---

## 2. Test Scope

* **Scope Type:** **Client Only** + **UI Handoff Compliance** + **Runtime Validation** (mandated by `architecture.md §16`; partially satisfiable here — see `0a`).
* **Documents reviewed:** `prd.md`, `architecture.md` (§3–§18), `orchestration.md`, `frontend.md`, `ui-design.md`, `design/design-doctrine.md`, `design/premium-ui-rubric.md`, `system-state.md`, `project-authority/release.md` (§2 — F03 = `none`). `analysis.md` N/A (F03 had no Technical Analyst pass).
* **Areas tested:** gesture→`Move` mapping (threshold / dominant axis / tie-band / one-cell); the `idle/tracking/animatingShift/animatingBounce/won` state machine + no-input-queue; `MOVES` = `engine.moveCount` settled-only; the 3-action Undo quota (incl. the 0 no-op) + Restart (reset + `restartCount++`, no confirm, separation from Undo); F08 write-through persistence + hydrate + `completed→clear()`; the win choreography + the minimal completion sheet (Retry / Close); `paused`/`resumed` gesture + animation handling; route `/play` + chrome (no header, quiet chevron hidden in `won`); the load-error state; `ui-design.md` Direction-A alignment.
* **Areas NOT tested / out of scope:** real backend (none exists); **Security compliance — out of scope:** F03 is pure client UI with a single actor, no authentication/authorization, no cross-user resources, no financial transaction, no endpoint; the only persistence is the local single-row `kv['active_session']` snapshot owned by F08 (whose own QA covered its security posture). No IDOR / injection / mass-assignment / auth-bypass surface exists in F03. **Release compliance — out of scope:** `Release Scope = none` (client-only screen, no infra/CI/deploy change; `architecture.md §17`, `release.md §2`). **iOS platform compliance — out of scope:** client stack is Flutter (not Unity), no `game-dev.md`; no new tracking SDK / IAP / privacy-manifest change (no `PrivacyInfo.xcprivacy` change). **Backend quality / 13 — out of scope:** no backend. **Mode/Configuration matrix — out of scope:** F03 has one actor and one mode; the puzzle-config variants (column moves on/off, locked, frozen) are covered in `## 5 Boundary Matrix` and `## 4` rather than a separate matrix.
* **Bugfix?** No — F03 is a first delivery, not a rework.
* **Critical user journeys:** (a) open a puzzle → see target + board + MOVES 0; (b) swipe a row/column → exactly one cell shift + MOVES +1; (c) sub-threshold swipe → nothing; (d) swipe during the shift animation → ignored, not queued, no double-count; (e) 3 undos then a 4th → no-op, no prompt; (f) Restart → reset, no dialog; (g) form the target → lock + win highlight + seam bar + bounded anim + completion sheet; (h) Retry → reset in place; (i) leave mid-puzzle → resume exactly (OS kill / background). **Forbidden / misuse journeys:** input during `animating`/`won`; Undo at quota 0; a rejected engine move (column-disabled / fully-immovable line); multi-touch (first pointer only); a swipe ending off-screen; device-rotation attempt; a corrupt / mismatched active-session snapshot on open; direct entry to `/play` with no stack.
* **Navigation / header consistency scope:** `/play` has no system header (contract §13); the quiet back chevron pops to the caller on button / system / gesture back and is hidden in `won`; F03 is the first in-flow screen (no sibling yet — F10/F05 come later), so sibling-source comparison is N/A and noted.
* **Evidence class summary:** `automated functional` (295 workspace tests, incl. 27 F03) + `build` (analyze / format / iOS release). **No `runtime` (device/simulator)** and **no `repeatable integration` (`integration_test` on an emulator)** — the two classes `architecture.md §16` mandates as "**Not `source-only`**".
* **Runtime validation method:** `automated functional` + build only (declared in `0a`).

---

## 3. Product Behavior Coverage

| User Story (`prd.md §2`) | Test scenario | Evidence | Result |
| --- | --- | --- | --- |
| "swipe a row/column and watch it slide one cell" | widget: `dragFrom` on row 0 of `smoke-tr-01` → one-cell right shift → `MASAL` forms; unit: `endDrag` → `DragResolution.shift` → `commitShift()` → `moveCount 1`, `appliedMoves ['R1']` | `play_session_screen_test.dart` "legal swipe → completion sheet"; `play_session_controller_test.dart` "legal drag → shift phase → commit" | **PASS (automated)** — real-device slide feel: **Runtime Pending** |
| "target word always visible and clearly separated from the grid" | widget: `HEDEF` label + 5 outline-ghost `TargetRail` tiles rendered above the board, separated by a `_DividerGlow` + `zoneGap`; `ui-design.md §7` treatment | `play_session_screen_test.dart` "renders the target…"; source `target_rail.dart` (outline + 4% fill + 0.46 scale) + `play_session_screen.dart` layout | **PASS** |
| "live MOVES counter" | widget: `HAMLE` + `0` at open; `1` after a settled move; unit: `moveCount` = `engine.moveCount`, only changes on `applyMove`/`undo` | `play_session_screen_test.dart` (AC1 + AC2); `play_session_controller_test.dart` (multiple) | **PASS** |
| "up to 3 undos and a restart to recover" | unit: 3 moves → 3 undos → `moveCount 0`, `undosRemaining 0`, `canUndo false`, 4th `undo()` → `false`; `restart()` → `moveCount 0`, `undosRemaining 3`, `restartCount 1` | `play_session_controller_test.dart` "undo: consumes the quota…", "restart: MOVES 0…" | **PASS** |
| "accidental taps and tiny drags ignored" | widget: a 6×4 px drag from board centre → `MOVES 0`, no sheet; unit: sub-threshold `resolve()` → `null`; `trackingAxis()` → `null` below threshold | `play_session_screen_test.dart` "a sub-threshold tap…"; `gesture_resolver_test.dart` (threshold group) | **PASS (automated)** — threshold tuning on a **device matrix**: **Runtime Pending** |
| "leave mid-puzzle and come back exactly where I was" | unit: hydrate from a seeded snapshot restores `moveCount / undosRemaining / restartCount`; `paused` mid-shift commits (never torn); write-through after every settled boundary | `play_session_controller_test.dart` "hydrate from a matching snapshot…", "paused mid-shift-animation commits…", "fresh start writes an initial…" | **PASS (automated)** — **real OS-kill / relaunch: Runtime Pending** |

**No user story is uncovered by automated evidence.** The device-runtime facets of stories 1/5/6 are explicitly required by `architecture.md §16` and are folded into `## 17` as Pending.

---

## 4. Acceptance Criteria Traceability

| AC (`prd.md §3`) | Test scenario + evidence | Result |
| --- | --- | --- |
| **AC1** open → target + grid + `MOVES: 0` + Undo(3) + Restart shown; target separated | `play_session_screen_test.dart` "renders the target, board, and MOVES 0" — `HEDEF`/`HAMLE`/`0`/`PuzzleBoard`/target letters; source: `_HudBar` renders `UndoButton(remaining:3)` + `RestartButton`; `TargetRail` above a `_DividerGlow` | **PASS** |
| **AC2** horizontal swipe past threshold, horiz-dominant → that row shifts one cell in the swipe direction + `MOVES +1` | `gesture_resolver_test.dart` (+dx → `rowRight(startRow)`, −dx → `rowLeft`); `play_session_screen_test.dart` (row-0 drag → shift → `MASAL`); `play_session_controller_test.dart` (`endDrag` → `shift`, `commitShift` → `moveCount 1`, `appliedMoves ['R1']`) | **PASS (automated)** — on-device accuracy: Runtime Pending |
| **AC3** vertical swipe past threshold, vert-dominant → that column shifts one cell + `MOVES +1` | `gesture_resolver_test.dart` (+dy → `columnDown(startCol)`, −dy → `columnUp`); engine enforces on `smoke-tr-04/05/06` (column-enabled) | **PASS (automated)** — on-device: Runtime Pending |
| **AC4** swipe below threshold → no shift, `MOVES` unchanged | `gesture_resolver_test.dart` (below-threshold → `null`); `play_session_screen_test.dart` "a sub-threshold tap does not change MOVES" | **PASS (automated)** — threshold `T` device sweep: Runtime Pending |
| **AC5** animation in progress → another swipe **ignored and not queued** | `play_session_controller_test.dart` "no input queue — beginDrag is ignored while not idle"; source: `beginDrag` early-returns unless `idle`; `PuzzleBoard._onPanDown` guards `if (_c.inputLocked) return` | **PASS (automated at controller/widget level)** — **0 double-registered moves during the *real* ~190 ms animation window (`prd.md §7` success metric): Runtime Pending** |
| **AC6** all 3 undos used → Undo tap again → nothing, **no purchase / ad prompt** | `play_session_controller_test.dart` (`undo()` → `false` at quota 0, no state change); source: `UndoButton` `onTap: active ? onPressed : null`, `active = enabled && remaining > 0`; **no dialog / route / ad code anywhere in `undo_button.dart` or the controller** | **PASS** |
| **AC7** Restart → grid reset, `MOVES = 0`, undos → 3, **no confirmation dialog**; Restart positioned away from the grid | `play_session_controller_test.dart` "restart: MOVES 0, undos back to 3, restartCount++"; source: `RestartButton` calls `onPressed` directly (no `showDialog`); `_HudBar` places it after a `Spacer` + 1px divider + `SizedBox(20)`, right side, outline treatment | **PASS (automated)** — thumb-clearance from the board on a real device: Runtime Pending |
| **AC8** target forms on settle → input locks, winning row highlights, short success anim, completion panel opens | `play_session_screen_test.dart` "a legal swipe that forms the target → completion sheet" (`ÇÖZÜLDÜ` + `Yeniden` + `Kapat`; sheet shows `MASAL` + `1`; back chevron hidden); source: `commitShift()` → `phase won` → `_win` 600 ms → `_buildSeam`/`_buildBloom` + `CompletionSheet` slide-in; HUD → `wonControlsOpacity 0.40` | **PASS (automated)** — animation timing / feel on device: Runtime Pending |
| **AC9** swipe begins → affected row/column receives a light visual highlight | source: `updateDrag` sets `_activeLine` past threshold → `PuzzleBoard` renders the translated moving-line layer (lift) + `_buildRails` (directional cyan) + 8% dim of the rest; `gesture_resolver_test.dart` `trackingAxis` group | **PASS (source + automated for the axis logic)** — visual highlight on device: Runtime Pending |
| **AC10** leave + return → grid, `MOVES`, undos, restart count, elapsed exactly restored | `play_session_controller_test.dart` "hydrate from a matching snapshot restores counters + moves"; F08 `session_restore` + `restoreMoves` re-derive thaw (F08 QA); write-through proven after every boundary | **PASS (automated for the hydrate path)** — **real OS-kill / relaunch + tampered-`thawedFrozenCells` re-derivation on device: Runtime Pending** |
| **AC11** target forms only transiently during animation → no win; win on settled state only | source: the engine sets `GridStep.solvedThisStep` from the **settled** next-state at `applyMove` time; the controller only checks it in `commitShift()` (post-animation); the animation is purely cosmetic (move already applied). Engine behaviour covered by `looplet_engine` 83 tests | **PASS (source + engine tests)** — device confirmation: Runtime Pending |

**Every AC has ≥ 1 automated scenario.** The device-`runtime` facets flagged above are the `architecture.md §16` mandate that this environment cannot satisfy.

---

## 5. Boundary Matrix

The play session is a state machine (`architecture.md §6`) with puzzle-config variants; explicit boundaries:

| Boundary / transition | Expected | Result | Evidence |
| --- | --- | --- | --- |
| `idle → tracking → idle` (below-threshold release) | no move, `MOVES` unchanged | **PASS** | `play_session_controller_test.dart` (rejected/none paths); `gesture_resolver` threshold |
| `idle → tracking → animatingShift → idle` (legal move, no win) | one cell, `MOVES +1`, snapshot persisted | **PASS** | controller "legal drag → shift → commit"; snapshot `appliedMoves ['R1']` |
| `idle → tracking → animatingShift → won` (legal move, win) | lock, `wonRow` computed, `completed` snapshot then `clear()` | **PASS** | controller "solving the puzzle → won…"; screen widget flow |
| `idle → tracking → animatingBounce → idle` (rejected move) | rubber-band back, `MOVES` unchanged, **not persisted** | **PASS** | controller "rejected move → bounce…" (vertical drag on `columnMovesEnabled:false`) |
| `animatingShift` + a new pointer | ignored, **not queued** | **PASS (controller/widget)** — real-animation double-count: **Runtime Pending** | controller "no input queue…"; `_onPanDown` guard |
| `won` + a pointer / Undo / Restart | inert (only the sheet's Close / Retry leave `won`) | **PASS** | `canRestart`/`canUndo` false in `won`; `inputLocked` true; `_TopBar showBack:!won` |
| Undo at quota 3 → 2 → 1 → 0 | each consumes one; at 0 `canUndo` false, further taps inert | **PASS** | controller "undo: consumes the quota, stops at 0" |
| `restart()` from `idle` (mid-puzzle) | `MOVES 0`, quota 3, `restartCount++`, `phase idle` | **PASS** | controller "restart…" |
| `retryFromCompletion()` from `won` | restart in place, timer re-armed, fresh `inProgress` snapshot, `phase idle` | **PASS** | `play_session_screen_test.dart` "Retry … resets the board" |
| Config variant: `columnMovesEnabled == false` (`smoke-tr-01/02`) | a vertical drag → engine rejects → bounce; `MOVES` unchanged | **PASS** | controller "rejected move → bounce" |
| Config variant: `columnMovesEnabled == true` (`smoke-tr-04`) | a vertical drag → column shift + `MOVES +1` | **PASS (automated — engine + resolver)** — on-device: Runtime Pending | `gesture_resolver` column cases; engine tests |
| Config variant: a locked pivot (`smoke-tr-05`, `3,3`) | the locked cell renders `brass` ring + pin glyph and never moves; other cells rotate around it | **PASS (source)** — **visual check on device: Runtime Pending** | `board_tile.dart` locked branch; engine locked-pivot behaviour (F02 tests) |
| Config variant: a frozen tile (`smoke-tr-06`, `2,2`) | renders `frost` fill + `frostLine` crystal border; immovable until a valid ≥4-letter word forms its row, then thaws | **PASS (source + engine)** — **visual + thaw cross-fade on device: Runtime Pending** | `board_tile.dart` frost branch; engine thaw (F02 tests) |
| App `paused` during `tracking` | gesture cancelled, no move, timer paused | **PASS** | controller "paused mid-drag cancels the gesture" |
| App `paused` during `animatingShift` | move committed synchronously (settled), snapshot written, never torn | **PASS (automated)** — **real background/foreground on a device: Runtime Pending** | controller "paused mid-shift-animation commits…" |
| Open with a **matching** `puzzleId` snapshot | hydrate via the F08 restore path | **PASS** | controller "hydrate from a matching snapshot…" |
| Open with a **mismatched** `puzzleId` snapshot | ignore it, start fresh + overwrite (architecture §9) | **PASS (source)** — `_tryRestore` returns null on `puzzleId != puzzle.id`; a fresh initial snapshot is then written | source review + the fresh-start test |
| Open with a **corrupt** snapshot | F08 discards active only → F03 starts fresh (architecture §9) | **PASS (source + F08 QA)** — `ActiveSessionRepo.read()` catch path (F08); F03 gets `null` and starts fresh | F08 `qa.md` + source |
| Direct entry to `/play` with an empty nav stack | `_popToCaller` falls back to `maybePop` | **PASS (source)** — `Navigator.canPop()` guard + `maybePop` fallback | source review |

No architecture-defined boundary is left without a scenario. The **Runtime Pending** rows are the device-visual / real-timing / real-lifecycle facets, not logic gaps.

---

## 6. Contract Compliance Check

| Contract area (`architecture.md`) | Status | Evidence |
| --- | --- | --- |
| Route / navigation (§13) — `/play`, `PlaySessionArgs`, portrait-locked, no system header + quiet chevron hidden in `won`, back keeps a resumable snapshot | **Preserved** | `app_router.dart` `GoRoute('/play')`; `main()` portrait lock; `_TopBar showBack:!won`; `home_screen.dart` uses `context.push` (pop-able); `play_session_screen_test.dart` (chevron findsNothing in `won`, findsOneWidget after Retry) |
| Screen state machine (§6) — `idle/tracking/animatingShift/animatingBounce/won`, **no input queue** | **Preserved** | `PlaySessionPhase` enum; `beginDrag` idle-guard; `_onPanDown` `inputLocked` guard; `play_session_controller_test.dart` no-queue test |
| Gesture → Move mapping (§7) — threshold, dominant axis, **tie-band → horizontal**, exactly one cell, first pointer, off-screen release | **Preserved** | `gesture_resolver.dart` + 13 unit tests; `GestureDetector` pan is single-pointer; `resolve()` ignores magnitude |
| MOVES / Undo / Restart (§8) — `MOVES = engine.moveCount` settled-only; Undo 3-action quota, no prompt/ad at 0; Restart reset + `restartCount++`, no dialog, separated from Undo | **Preserved** | `moveCount` getter; `undo_button.dart` (no dialog/ad code); `restart_button.dart` (no `showDialog`); `_HudBar` layout; controller tests |
| Persistence integration (§9) — write-through into the **F08-frozen** snapshot keys; hydrate via the F08 restore path; `completed` + `clear()` on win; `paused` flush; **no F03-scheduled background work** | **Preserved** | `_snapshot()` builds `ActiveSessionSnapshot` with the exact frozen keys; `_tryRestore` → `restoreSession`; `_persistCompletedThenClear`; the sync drain stays on F08's app-level `_SessionLifecycle`; controller tests |
| Completion sequence (§10) — lock → win-row highlight **+ drawn seam bar (colour + shape)** → bounded ≤ 600 ms anim → **minimal** panel (no stars/optimal/best/Next — F04 seam) | **Preserved** | `_buildSeam` (3 pt amber bar, L→R width by `_win.value`) + `BoardTile winning`; `PlayTheme.winDuration = 600 ms`; `CompletionSheet` has only kicker + word + `HAMLE` stat + Retry + Close |
| Animation / input-lock (§11) — 150–250 ms shift, full input lock for the phase, no queue, diegetic lock (HUD dim, not a spinner), transient valid word mid-animation does not win | **Preserved** | `PlayTheme.shiftDuration = 190 ms`; `_HudBar` `AnimatedOpacity` to `lockedControlsOpacity 0.55`; no spinner widget anywhere; `solvedThisStep` from the settled engine state checked only at `commitShift` |
| Backgrounding (§12) — gesture cancelled on `paused`; mid-shift commits synchronously; snapshot always settled | **Preserved** | `onAppPaused` switch (`tracking` → cancel; `animatingShift` → `_finishShift()`); controller tests |
| Localization (§14) — `MOVES` + all strings externalized | **Preserved (with a flagged assumption)** | `PlayStrings` per-language `tr`/`en` table — no widget has a hard-coded display string. **Assumption:** no `gen_l10n`/`.arb` toolchain; `PlayStrings.of(lang)` matches the "look up by language key" shape the dictionary layer uses. Contract says "externalized" — satisfied. Tech Lead to confirm the pattern (already an open clarification). |
| Validation responsibility (§15) — F03 owns the undo quota, no-moves-during-animation, out-of-range guard, gesture rules, state machine, snapshot serialization, portrait lock | **Preserved** | as above; engine owns move legality; F08 owns storage + restore |
| `Release Scope` (§17) | **Preserved** — `none`; no infra/CI/deploy change; CI gates unaffected | `git status` shows only `app/**` + `ai-system/**`; `pubspec.yaml` unchanged; iOS build green with no new pods |
| Contract version / breaking change | **No breaking change** | F02 / F08 consumed via public APIs only; no package modified; F02 83 + F08 68 tests unchanged and green |

**No contract violation found.**

---

## 7. UI Design Compliance Check

`ui-design.md` present (Direction A, self-review 94/100). Assessed against it + `design-doctrine.md` + `premium-ui-rubric.md`.

| Dimension | Assessment |
| --- | --- |
| **Screen goal** — "manipulate the board; the board is the interface" | **Met** — the lit board is the single hero; no form/list/primary-button while playing; the one CTA (`Retry`) lives only in the sheet. |
| **UX flow** — silent hydrate, no restart confirm, no undo nag, no error toasts, diegetic wait | **Met** — `_init()` hydrates without a "resuming" UI; `restart()` has no dialog; Undo-at-0 is inert; rejected moves bounce (no toast); the 190 ms lock is a HUD dim, not a spinner. |
| **Visual hierarchy** — board loud, chrome quiet, MOVES/Undo/Restart tiered, target subordinate-but-legible | **Met** — `PlayStage` dark; `BoardTile` backlit-keycap gradient + AO shadow + inner highlight; `TargetRail` outline-ghost at 0.46 scale; `MovesHud` no card; chevron `PlayTheme.muted`, no chip. |
| **Layout structure** — 3 zones, fixed 28 pt gaps, board-first shrink, grid ~85–90% width | **Met (source)** — `_PlayBody` `LayoutBuilder`: `boardWidthFraction 0.88`, `zoneGap 28` constants, `boardFloor` = `5·minTile + plate + gaps`. Device-matrix confirmation of the ≥ 44 pt hitbox + one-handed reach: **Runtime Pending**. |
| **Component blueprint** — outline-ghost target, backlit tiles, loop rails, undo pips, outline Restart, minimal-but-crafted sheet | **Met** — all present: `target_rail.dart`, `board_tile.dart`, `puzzle_board.dart` `_buildRails`, `undo_button.dart` pips, `restart_button.dart` outline circle + spin, `completion_sheet.dart` raised panel + dominant amber Retry + quiet Close. |
| **State design** — idle / pressed / dragging / animating / rejected / won / disabled(undo-0 + lock) / loading / error / focused | **Met** — every state is rendered with a distinct treatment (see `## 12`). Non-colour cues present: winning row = amber fill **and** a drawn seam bar; locked = brass ring + pin glyph; frozen = frost + crystal border. |
| **Motion intent** — 190 ms wrap shift (edge-mask + emerging ghost), < 50 ms release→start, bounded win | **Met (source)** — `shiftDuration 190`, `shiftCurve cubic(0.22,1,0.36,1)`; `endDrag` calls `engine.applyMove` synchronously then starts `_shift` (no awaited work on the path); the wrap is a `ClipRRect` + N+2 ghost tiles, **not** a plain slide. Perceived latency + wrap feel on device: **Runtime Pending**. |
| **Chrome** — no system header, one quiet chevron top-left, hidden in `won` | **Met** — `_TopBar`; F03 is the first in-flow screen so there is **no sibling to compare** (F10/F05 later) — noted; the cross-screen locking of this rule is an open Tech Lead clarification. |
| **Background / colour / typography / surface-depth** | **Met** — `PlayStage` gradient + radial spotlight + vignette; `PlayTheme` tokens (amber / cyan / stage / brass / frost); heavy grotesque tile glyphs (`fontWeight w800`), tabular `MOVES`, tracked micro-labels; 3 surface tiers (stage < plate < tiles < sheet). Not flat, not a card-stack. |
| **Premium differentiators** | Spotlight stage, backlit-keycap tiles, loop-rail motif, wrap animation, outline-ghost target, amber-fill + drawn seam bar, diegetic input-lock, undo pips, separated outline Restart, rubber-band bounce — **all present in source**. |
| **Accepted deviations (Frontend-flagged, `frontend.md §4/§11/§16`)** | (1) board-recede **blur → dim-only (0.12)** during `won` — mid-tier frame-rate; (2) breathing spotlight ambient **omitted** — perf + test determinism. QA assessment: (1) preserves the "board recedes, winning row + sheet own focus" intent and does not trip a rubric fail condition; (2) `ui-design.md §5/§11` marks the ambient optional/flexible ("drop it if it costs frames"). **Both accepted as non-blocking**; the "add the blur behind a device-tier gate?" call is Tech Lead's (`frontend.md §16` #5–6). |
| **`design-doctrine.md` §8 anti-patterns** | None present — no white-card stack, no cheap blue-gradient primary button (the amber Retry gradient is intentional and dark-text), no border-only selected state, no form-builder look, no empty-but-uncomposed screen, no system-default component look. |
| **`premium-ui-rubric.md` fail conditions** | None triggered — clear hero, dominant CTA where one exists (`Retry`), strong won state (fill + seam bar + bloom + recede), layered surfaces, strong hierarchy, non-generic identity. |

**UI verdict:** the implementation holds the `ui-design.md` intent and the ~94/100 bar. No UI Design Mismatch finding. Rubric ≥ 90 (design self-review 94; implementation adds the two accepted perf deviations, which stay above the 90 threshold and trigger no fail condition). **Visual states on a real screen (win choreography, tile-state visuals, rail highlight, sheet slide) are `runtime` items** — see `## 17`.

---

## 9. Positive Scenarios

**Journey 1 — open and orient (AC1).**
Start: a player opens `/play` for `smoke-tr-01` (via the debug chip). Action: the screen loads. Visible result: the dark stage with a spotlit board; `HEDEF` above 5 outline-ghost tiles spelling the target; the 5×5 board of backlit tiles; `HAMLE 0`; an Undo pill showing 3 pips; a Restart outline circle set apart on the right; a quiet back chevron top-left. Evidence: `play_session_screen_test.dart` "renders the target, board, and MOVES 0" + source layout.

**Journey 2 — solve in one move (AC2 / AC8 / AC9 / AC11).**
Start: `smoke-tr-01`, row 0 = `A S A L M`. Action: the player swipes row 0 to the right past the threshold. Visible result: the row lifts + the end loop-rails ignite (AC9); on release the row slides exactly one cell with the wrap (M enters from the left), settling to `M A S A L`; `HAMLE` ticks to `1`; input locks (HUD dims); the winning row fills amber and a solid amber seam bar draws left-to-right beneath it (colour **and** shape); a single bloom pulses; the completion sheet rises with `ÇÖZÜLDÜ`, `MASAL`, `HAMLE 1`, a dominant `Yeniden`, and a quiet `Kapat`; the back chevron is gone. Evidence: `play_session_screen_test.dart` "a legal swipe that forms the target → completion sheet"; `play_session_controller_test.dart` "solving the puzzle → won, wonRow 0, completed snapshot then cleared" (`repo.read()` → `null`).

**Journey 3 — recover with Undo then Restart (AC6 / AC7).**
Start: `smoke-tr-02`, 3 legal moves applied, no win. Action: tap Undo 3×, then a 4th time, then Restart. Visible result: each of the first 3 taps steps the grid back one move and dims one pip; the 4th tap does nothing — no dialog, no ad, no toast (AC6); Restart snaps the grid to the authored layout, `HAMLE` to `0`, the pips back to 3, with no confirmation dialog (AC7). Evidence: `play_session_controller_test.dart` "undo: consumes the quota, stops at 0 with no effect" + "restart: MOVES 0, undos back to 3, restartCount++" (snapshot `restartCount 1`).

**Journey 4 — leave and resume (AC10).**
Start: a player mid-`smoke-tr-02` (1 move, 1 undo used, 2 restarts, ~41 s elapsed) — a snapshot exists. Action: the app is killed; the player reopens the same puzzle. Visible result: the grid, `HAMLE 1`, `undosRemaining 2`, `restartCount 2`, and the accumulated elapsed are exactly restored; the thawed state (if any) is re-derived by engine replay, not read from the cache. Evidence: `play_session_controller_test.dart` "hydrate from a matching snapshot restores counters + moves" (`hydratedFromSnapshot`, `moveCount 1`, `undosRemaining 2`, `restartCount 2`) + F08's `session_restore` tests. **The real OS-kill cycle + tampered-cache re-derivation on a device: Runtime Pending.**

**Journey 5 — a move the engine rejects.**
Start: `smoke-tr-01` (`columnMovesEnabled == false`). Action: the player swipes a column down past the threshold. Visible result: the column lifts, then rubber-bands back to origin on release; `HAMLE` stays `0`; no error text, no toast. Evidence: `play_session_controller_test.dart` "rejected move → bounce phase → commitBounce → idle, MOVES unchanged, nothing persisted".

---

## 10. Negative / Edge Cases

| Case | Expected | Result | Evidence |
| --- | --- | --- | --- |
| Input while `phase == animatingShift` | ignored, **not queued**, no second move | **PASS (controller/widget)** — real-animation-window double-count: **Runtime Pending** | controller "no input queue…"; `_onPanDown` `inputLocked` guard |
| Input while `phase == won` | inert; only the sheet's Close / Retry leave `won` | **PASS** | `inputLocked` true in `won`; `canUndo`/`canRestart` false; `_TopBar` hides the chevron |
| Undo with no move history (defensive) | `undo()` → `false` (`canUndo` also requires `moveCount > 0`) | **PASS** | `canUndo` guard; controller |
| Undo during the success animation / `won` | disallowed | **PASS** | `canUndo` requires `phase == idle` |
| A rejected engine move (column disabled / fully-immovable line) | bounce-back, `MOVES` unchanged, no error surfaced, **not persisted** | **PASS** | controller "rejected move → bounce…" |
| Multi-touch / two-finger gesture | first pointer only | **PASS (framework)** — `GestureDetector` pan tracks a single pointer; a second pointer does not start a second drag | source + Flutter gesture-arena behaviour |
| Swipe starting on the grid, ending off-screen | resolves from the last known delta on `up` / `cancel` | **PASS (source)** — `_onPanEnd` / `_onPanCancel` both call `_release(_dragOffset)` with the accumulated delta | source review — **on-device: Runtime Pending** |
| Fast flick vs slow drag | both → exactly one cell | **PASS** | `gesture_resolver_test.dart` "one cell only — a long flick and a short drag map the same" |
| Diagonal swipe, near-equal axes | dominant axis = horizontal (tie band) | **PASS** | `gesture_resolver_test.dart` "near-equal axes resolves to a row move" |
| Device-rotation attempt | stays portrait | **PASS (source)** — `main()` `SystemChrome.setPreferredOrientations([portraitUp])` | source — **on a rotating device: Runtime Pending** |
| Restart tapped during an animation | inert (`canRestart` requires `idle`); resolves on settle then a fresh tap works | **PASS** | `canRestart` guard |
| Corrupt `active_session` on open | F08 discards active only → F03 starts fresh, durable tables intact | **PASS (F08 QA + source)** — `ActiveSessionRepo.read()` catch → `null`; `_tryRestore(null)` → fresh | F08 `qa.md` + source |
| Mismatched-`puzzleId` snapshot on open | ignored; fresh start + overwrite (architecture §9) | **PASS (source)** — `_tryRestore` guards `snapshot.puzzleId != puzzle.id` | source |
| `restoreSession` throws (dict drift → a persisted move no longer applies) | fall back to a clean start (architecture §5 restore path) | **PASS (source + F08)** — `_tryRestore` catches `SessionRestoreException` → `debugPrint` + fresh | source; F08 `session_restore` tests |
| App `paused` mid-drag | gesture cancelled, no move | **PASS** | controller "paused mid-drag cancels the gesture" |
| App `paused` mid-shift-animation | move committed synchronously, snapshot settled, never torn | **PASS (automated)** — **real background/foreground: Runtime Pending** | controller "paused mid-shift-animation commits…" |
| Direct entry to `/play` with an empty stack | `_popToCaller` → `maybePop` fallback | **PASS (source)** | source review |
| Unsupported `source` (`daily` / journey pre-F05) | contained dev-only load-error body + a `Geri` button | **PASS** | `play_session_screen_test.dart` "an unsupported source shows the load-error state" |
| Storage full / disk write failure during a persist | non-fatal — keep playing from memory, retry next boundary | **PASS (source)** — `_persist()` / `_persistCompletedThenClear()` wrap `_repo.save` in try/catch → `debugPrint('persist_failed …')` (architecture §Resilience) | source — no automated fault-injection (residual test-debt, shared with F08 AC7) |

No misuse path produced a crash, a lost/duplicated move, an unauthorized action, or a wrong `MOVES` in the automated + source evidence.

---

## 12. UX & State Handling

* **Loading** — `_LoadingBoard`: the stage + spotlight render immediately; 25 dim tile silhouettes with a slow shimmer; ghost target slots; **no spinner**. Practically never seen (the debug source is `const` maps) but present so a future async source can't flash blank.
* **Error** — `_LoadErrorBody`: a contained `Icons.error_outline` + `Bu bulmaca yüklenemedi` + a `Geri` text button. Dev-only (F05/F07 wire real sources), by design not a premium surface.
* **Empty** — n/a (there is always a puzzle or an error).
* **Success** — the win choreography (lock → amber fill + `ink-amber` letters + lift + a drawn L→R seam bar + one bloom + 0.12 dim of other rows) into the minimal completion sheet. Bounded to `winDuration` 600 ms.
* **Disabled** — Undo at quota 0: dark pill, muted icon + hollow pips, inert tap, no glow. HUD controls → 0.55 opacity during animation, 0.40 in `won` — the diegetic input-lock, **no spinner/modal**.
* **Selected / pressed** — a touched tile scales to 0.97 within ~90 ms even for a tap that becomes a no-op, so input always feels acknowledged.
* **Focused** — controls carry `Semantics(button:, enabled:, label:)`; the board carries a `Semantics` label (target + move count). Full assistive-tech grid navigation is out of F03 scope (architecture §16 / `ui-design.md §13`).
* **Validation feedback** — n/a (no form); an invalid/rejected move is answered by the rubber-band bounce, never a message.
* **CTA clarity** — there is **no CTA on the playing screen** (the board is the action — an intentional decision, `ui-design.md §14` open clarification #1). The single CTA is `Retry` in the completion sheet, and it dominates (`Close` is a quiet text link).
* **Visual hierarchy / background / surface-depth / typography** — see `## 7`; all applied.
* **Motion / feedback quality** — 190 ms wrap shift, 140 ms rejected bounce, 600 ms win, 320 ms restart-icon spin, 140 ms MOVES settle-tick — all bounded finite `AnimationController`s / `AnimatedX` widgets (no `repeat()`), so `pumpAndSettle` is deterministic and there are no leaked tickers.
* **Runtime evidence summary** — `automated functional` only: 295 workspace tests (27 F03) + `analyze`/`format` + iOS release build, all green. **No device/simulator runtime evidence** — the `architecture.md §16` mandate — see `## 17`.

---

## 14. Frontend Quality

* **Code quality** — `flutter analyze` (app) + `dart analyze` (6 packages) clean apart from **one pre-existing `info` in `looplet_solver`** (`solver.dart:56`, not F03, `dart analyze` exits 0). `dart format --set-exit-if-changed` clean. No stubs / TODOs on the F03 surface. `debug_puzzle_library.dart` is an explicit, self-documenting scaffold (F05 replaces it); `PlayStrings` is an explicit localization seam.
* **Architecture** — clean separation: a **ticker-free** `PlaySessionController` (`ChangeNotifier`) owns the state machine + engine + counters + `ElapsedTimer` + write-through persistence and is fully unit-testable without a `TickerProvider`; the board widget owns the `AnimationController`s and calls back on settle (`commitShift`/`commitBounce`) — a sound split. The F08 sync service stays session-scoped (app-level `_SessionLifecycle`); the F03 controller is screen-scoped and disposed with the screen — correct lifecycle ownership (`platform.md §7`).
* **Preserved-behaviour correctness** — the F08 `_SessionLifecycle` observer was **moved** from wrapping `home:` to wrapping `MaterialApp.router`'s `builder:`. This is a **correctness improvement**, not a regression: under `home:` it would unmount on the first navigation to `/play` and stop draining the sync queue; at the router `builder:` it stays mounted app-wide, which is what a session-level resource requires. The drain trigger is byte-identical. The F08 recovery screens (`_SplashScreen` / `StoreErrorScreen` / the migration-error branch) moved verbatim to `app_router.dart`; `widget_test.dart` still asserts the same strings and passes.
* **Resilience** — corrupt/mismatched snapshot → fresh start; `restoreSession` throw → fresh start; persist failure → caught + logged, keep playing; the completion snapshot is written **then** cleared (a crash during the sheet doesn't resurrect a finished puzzle).
* **Determinism** — the controller is deterministic under an injected clock; all screen animations are finite. 27 F03 tests are stable.
* **The debug entry** (`home_screen.dart` chip row → `context.push('/play', extra: …)`) is dev-only and does not affect the shipping nav surface (there is none yet).
* **Runtime evidence summary** — `automated functional` + build only; **device/simulator runtime not exercised** (see `## 17`).

---

## 15. UI Handoff Alignment

* **Aligned with `ui-design.md`:** Direction A fully implemented — spotlight stage, backlit-keycap tiles, loop-rail motif, wrap animation (edge-mask + emerging ghost, **not** a plain slide), outline-ghost target (scale + treatment + divider + air), diegetic input-lock (HUD dim, no spinner), amber win-fill + **drawn L→R seam bar** (colour + shape), undo pips (3→0), separated outline Restart with a divider, rubber-band bounce on a rejected move, minimal-but-crafted completion sheet (raised panel + dominant amber Retry + quiet Close, no rating UI). Colour tokens, 3 type roles, 4/8 spacing rhythm, non-colour cues for locked/frozen/winning — all present.
* **Deviations (accepted, non-blocking):** board-recede **blur → dim-only (0.12)** (mid-tier frame-rate); breathing spotlight ambient **omitted** (`ui-design.md §5/§11` marks it optional). Both Frontend-flagged (`frontend.md §16` #5–6); neither drops the screen below the premium bar or trips a `premium-ui-rubric.md` fail condition.
* **Acceptable technical differences:** the loading skeleton uses a `Wrap` of dim boxes rather than pixel-exact tile silhouettes (dev-only, never really seen); the win bloom is a simple radial `DecoratedBox` opacity pulse rather than a shader.
* **Unacceptable UX / visual deviations:** **none found.**
* **Premium-quality gaps:** none blocking. The two perf deviations are the only distance from the design's 10/10 ceiling on "Surface & Depth" / "Modernity"; still ≥ 90.

---

## 16. Regression Risk

* **Shared components touched:** `app/lib/main.dart` (`MaterialApp` → `MaterialApp.router`; the F08 `_SessionLifecycle` relocated to the router `builder:`; dark theme from `PlayTheme.colorScheme`). `app/lib/app_router.dart`, `app/lib/home_screen.dart`, `app/lib/play/**` — all **new**. **No `looplet_*` package changed; no `app/lib/persistence/**` or `app/lib/engine/**` or `app/lib/content/**` changed** (`git status` + `git diff` confirm only `main.dart` modified + new files).
* **Downstream dependents:** F04 (will replace `CompletionSheet` with the real rating panel — F03's is a documented seam with no rating logic to unwind); F05 (will replace `debug_puzzle_library.dart` + wire real Journey resolution into `playSessionSetupProvider` — the provider shape is ready); F07 (Daily source into the same provider); F09 (onboarding overlay on this screen); F11 (SFX/haptics on move/thaw/win/button); F12 (analytics from F03's state changes). None exist yet — F03 is the contract they build against.
* **Existing behaviour:** the 4 pre-existing app tests + the 68 F08 tests are unchanged and green; `looplet_engine` 83 + `looplet_content` 17 + the F08 persistence suites unchanged. `widget_test.dart` re-run: home still shows `LOOPLET`, no `StoreErrorScreen` — the `MaterialApp.router` switch preserved the boot behaviour. The F08 sync-drain trigger is byte-identical (relocated, not changed).
* **Risk:** the `main.dart` rewrite (router + observer relocation) is the only shared-file change. It is covered by `widget_test.dart` (boot → home) and the observer relocation is a strict improvement (see `## 14`). **Low regression risk.** The untested surface is device/OS-level, not the Dart wiring.

---

## 17. Final Verdict

### **Runtime Validation Pending**

* **No blocking code issue. No required fix.** Every piece of automated + build evidence is green: **295 / 295** workspace tests (27 new F03: 13 `gesture_resolver`, 11 `play_session_controller`, 5 `play_session_screen` widget), `flutter analyze` + `dart analyze` (6 packages) + `dart format --set-exit-if-changed` clean, `flutter build ios --release --no-codesign` green (`Runner.app 54.5MB`). The full `architecture.md` contract (§6 state machine + no queue, §7 gesture mapping incl. tie-band→horizontal, §8 MOVES/Undo/Restart, §9 F08 write-through + hydrate + `completed→clear()`, §10 bounded win + drawn seam bar + minimal panel, §11 190 ms shift + diegetic lock, §12 backgrounding, §13 route/chrome, §14 externalized strings, §15 validation split, §17 `Release Scope = none`) is honoured. All 11 ACs have ≥ 1 automated scenario. `ui-design.md` Direction A is implemented and holds the ~94/100 bar; no rubric fail condition; no `design-doctrine.md §8` anti-pattern. Security compliance is legitimately out of scope (pure client UI, single actor, no auth, no cross-user data, no endpoint). Release compliance is out of scope (`Release Scope = none`).

* **Why not `Approved` / `Approved with Notes`:** `architecture.md §16` **explicitly requires `runtime` (device/simulator) evidence** for resume, gesture accuracy, and the animation behaviour and states "**Not `source-only`** — `platform.md §10` requires runtime proof". `prd.md §7` makes two of those a hard **success metric** — "**0 double-registered moves during animation in QA**" and "**gesture recognition ≥ target accuracy on the device matrix**". This QA pass has **no device / simulator session and no `integration_test` suite** (`0a`); the available evidence class is `automated functional` (strong — a widget test drives a real gesture through the full tree, animation pumps, the win sequence and the sheet — but not a touchscreen, not a real OS process, not a device matrix). Per the QA fail-fast + runtime-verdict rules, a feature with this runtime-risk surface (gesture feel, real-animation-window input handling, real OS-kill resume, real lifecycle, rotation, tile-state visuals) cannot be `Approved` on `automated functional` evidence alone.

* **This is an environment gap, not an implementation defect.** The same posture as F08's QA. The logic is proven; the device facets are not producible here.

**Pending validation scenarios → the Tech Lead Note.**

---

# WORKFLOW VERDICT SUGGESTION (NON-AUTHORITATIVE)

## QA Result

* **Runtime Validation Pending** — implementation is contract-compliant, `ui-design.md`-aligned, and green on all available automated + build evidence; the `architecture.md §16`-mandated `runtime` (device/simulator) and `repeatable integration` (`integration_test`) evidence could not be produced in this environment.

## Affected Areas

* None requiring code rework. The gap is **validation-method** (device/simulator runtime), not correctness.

## Blocking Issues

* None (no code defect).

## Pending Validation Scenarios

1. **Gesture accuracy on a device matrix** (AC2/AC3/AC4/AC9; `prd.md §7`) — on a small-width and a large-width device: swipe → exactly the intended row/column shifts one cell; sub-threshold tap/micro-drag → nothing; sweep `GestureResolver.thresholdLogicalPx` (18) and `tieBandRatio` (0.15) — confirm the threshold is large enough that accidental touches never count and small enough for one-handed play; near-diagonal → horizontal; fast flick vs slow drag → exactly one cell; swipe ending off-screen still resolves; multi-touch → first pointer only.
2. **0 double-registered moves during the *real* ~190 ms animation window** (AC5; `prd.md §7` success metric — the headline runtime check) — rapid repeated swipes on the same row → each counts, but only after the previous settles; a swipe during `animatingShift` → no move, not queued, `MOVES` unchanged.
3. **Kill / relaunch resume fidelity on a device/simulator** (AC10; `architecture.md §12/§16`) — start mid-puzzle with N moves + undo(s) + a restart + (on `smoke-tr-06`) a thawed frozen tile → OS-kill the process → relaunch the same puzzle → grid, `MOVES`, `undosRemaining`, `restartCount`, elapsed exactly restored; tamper `kv['active_session'].thawedFrozenCells` and confirm it is **re-derived** by replay, not trusted.
4. **App lifecycle on a device** (AC-adjacent; `architecture.md §12`) — background mid-swipe → gesture cancelled cleanly on return; background mid-animation → resolves to the settled end state, never a half-applied move; confirm the timer pauses/resumes and the persisted snapshot is always settled.
5. **Win choreography + tile-state visuals on a real screen** (AC8/AC9; `ui-design.md §7/§8`) — the amber fill + the **drawn L→R seam bar** legible with colour off / in greyscale (accessibility); bounded ≤ ~600 ms, reads as "earned" not a wait; `smoke-tr-05` locked pivot = brass ring + pin glyph and never moves; `smoke-tr-06` frozen tile = frost + crystal border, immovable until a valid ≥4-letter word forms its row, then the thaw cross-fade.
6. **Portrait lock on a rotating device** — a rotation attempt leaves the layout unchanged.
7. **Navigation on a device** — the quiet back chevron pops to the caller on button / system / gesture back; it is hidden in `won` (the sheet's Close owns exit); direct entry to `/play` falls back safely.
8. **Recommended durable form:** an `integration_test/` suite (runnable on a CI emulator — `release.md §4` already lists `integration_test` as a best-effort CI gate "not auto-blocking until F03 lands"; F03 has now landed) covering scenarios 1–4 would convert most of this from manual device QA into a repeatable gate — analogous to how F08 folded its emulator suites into CI.

## Suggested Fix Order

Not a rework. The Tech Lead coordinates the pending validation:
1. A simulator/device pass for scenarios 1–7 (Tech Lead / user), **or**
2. Frontend adds an `integration_test/` suite for scenarios 1–4 and wires it into the CI `verify`/`integration` job (closes 1–4 repeatably), then a shorter device pass for 5–7.
3. Re-run QA (or accept the device-pass evidence as the runtime closure — Tech Lead's call), then `Run Tech Lead` to close F03.

---

## 19. Sonraki Komut

```
Run Tech Lead
```

---

## 20. Tech Lead Note

<<<TEXT

F03 puzzle-play-session — QA verdict: **Runtime Validation Pending**. No blocking code issue, no required fix. All automated + build evidence green: 295/295 workspace tests (27 new F03 — gesture_resolver 13, play_session_controller 11, play_session_screen widget 5), flutter analyze + dart analyze (6 packages) + dart format --set-exit-if-changed clean, flutter build ios --release --no-codesign green (Runner.app 54.5MB). Full architecture.md contract honoured (§6 state machine + NO input queue, §7 gesture→Move incl. tie-band→horizontal, §8 MOVES settled-only / Undo 3-action no-prompt-at-0 / Restart no-confirm + separated, §9 F08 write-through + hydrate + completed→clear, §10 bounded win + drawn seam bar + minimal panel = F04 seam, §11 190 ms shift + diegetic lock no-spinner, §12 backgrounding, §13 route/chrome, §14 externalized strings, §15 validation split, §17 Release Scope = none). All 11 ACs have automated coverage. ui-design.md Direction A implemented and holds the ~94/100 bar; no rubric fail condition; no doctrine anti-pattern.

WHY NOT APPROVED: architecture.md §16 explicitly mandates `runtime` (device/simulator) + `repeatable integration` evidence and states "Not source-only"; prd.md §7 makes "0 double-registered moves during animation in QA" and "gesture recognition ≥ target accuracy on the device matrix" hard success metrics. This QA environment has no device/simulator session and no integration_test suite — evidence class is `automated functional` + build only. Same posture as F08's QA. Environment gap, not a defect.

RECOMMENDED ROUTE (mirrors F08's DURUM 5 handling):
- Per state-machine DURUM 5 ("Runtime Validation Pending"): if closeable via a simulator/device pass, set Status accordingly and coordinate that pass; F03 has no release gate (Release Scope = none), so there is no F08-DEVOPS-style folding — the runtime closure is a direct device/simulator QA pass or an integration_test suite.
- BEST DURABLE OPTION: have Frontend add an `integration_test/` suite (CI-emulator-runnable — release.md §4 already lists integration_test as a best-effort CI gate "not auto-blocking until F03 lands"; it has landed) covering: gesture accuracy + threshold sweep on a couple of surface sizes, 0-double-count during the real 190 ms window, kill/relaunch resume, background mid-swipe / mid-animation. Then a short manual device pass for the visual items (win choreography readability, locked/frozen tile visuals, rotation, chevron/back).
- Then Run QA again (or accept the device-pass evidence as closure — your call) → Run Tech Lead to close F03.

OPEN CLARIFICATIONS carried from ui-design.md §14 + frontend.md §16 (all non-blocking, defaults implemented — resolve at close-out):
1. Confirm "no primary CTA on the playing screen" (the board is the action; Retry in the sheet is the only CTA) so it is not treated as a missing CTA.
2. Confirm F03 owns the first-pass VISUAL treatment of locked/frozen tiles (brass ring + pin / frost + crystal border), or name the later feature that owns a dedicated tile-state visual pass.
3. Decide whether to lock "no system header + quiet back chevron, hidden in terminal states" as a cross-screen chrome rule now (F10) or leave it feature-local. F03 is the first in-flow screen — no sibling exists to compare against yet.
4. Final microcopy for PlayStrings (HEDEF / HAMLE / ÇÖZÜLDÜ / Yeniden / Kapat / Geri) — PO / localization. Also: no gen_l10n/.arb toolchain — PlayStrings is a per-language table; confirm this pattern or schedule a localization-layer task.
5-6. The two Frontend-flagged perf deviations from ui-design.md: board-recede blur → dim-only (0.12) during `won`; breathing spotlight ambient omitted. QA assessment: both acceptable, no rubric fail condition, ui-design.md marks the ambient optional. Accept, or require the blur behind a device-tier gate?

NON-F03 OBSERVATION: `looplet_solver/lib/src/solver.dart:56` has one pre-existing `info`-level analyzer lint (`curly_braces_in_flow_control_structures`) from an earlier session — `dart analyze` exits 0, CI is unaffected, not F03. Optional cleanup on the next F06 touch.

RESIDUAL (shared with F08 AC7): no automated storage-full / disk-write-failure fault-injection test for the persist path (the mechanism — try/catch around the Drift upsert + keep-playing-from-memory — is source-sound). Add in a follow-up.
TEXT
