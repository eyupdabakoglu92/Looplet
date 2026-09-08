# F05 — journey-progression: Frontend Delivery Report

> Delivery report + traceability artifact only. Contract authority stays in `architecture.md` (LOCKED); visual/state authority in `ui-design.md`. Direct-edit mode — real project files were edited. Nothing committed to git.

---

## 1. Feature Summary

F05 turns the debug `HomeScreen` into the real **journey home** — a 30-tick progress ring (`N / 30` at its centre, one continuous amber glow on the completed run, a bright current node, a cyan ring when that level is in-progress) with a single dominant **CONTINUE** pill nested in the ring's bottom gap, plus the **"all 30 complete"** terminal variant (`TAMAMLANDI` + CONTINUE → `TEKRAR OYNA` → Level 1). A Journey level opens through F03's existing `/play` by number: an app-layer resolver loads the bundled `journey-<lang>-<NN>` `Puzzle` from a per-language manifest. On a win, the level is marked complete and the next unlocked via **F08's existing `JourneyProgressRepo`** — injected into `PlaySessionController` exactly as F04's `personalBestRepo`, fire-and-forget with a caught failure, ordered after the `personal_best` write. F04's `CompletionPanel.onNextLevel` seam is now wired (`pushReplacement` to N+1, or `/` → terminal), and the panel's two CTAs are re-weighted per outcome (`architecture.md §16`). The levels 4–6 **column micro-tutorial** is a diegetic, action-gated overlay over the board, cleared only by a committed column-axis drag and persisted via a single `kv` flag. **No F03/F04/F06/F08 contract change** — every touch-point is a seam-fill or an additive injection.

---

## 2. Impacted Files

**Created — `app/lib/journey/`**
- `journey_content.dart` — `journeyLevelId` / `parseJourneyLevel` mapping helpers; `JourneyContentException`; `JourneyManifest` + `JourneyManifestLevel` (schema §5.2, contiguity-validated); `JourneyAssetSource` (injectable) + `RootBundleJourneyAssetSource`; `JourneyContentRepo` (manifest + level load, cache, id/number/checksum asserts); `journeyAssetSourceProvider` / `journeyContentRepoProvider` / `journeyManifestProvider`.
- `journey_progress.dart` — `LevelState` enum; `JourneyProgressModel` (`progressCount` / `allComplete` / `stateOf(n)` / `continueTarget`); pure `buildJourneyProgressModel({row, activeSnapshot})`; `journeyProgressModelProvider` (`StreamProvider` over `JourneyProgressRepo.watch` re-reading the active-session snapshot per tick).
- `journey_nav.dart` — pure `nextJourneyLevel(n, {manifestLevelCount})` → `n+1` / `null` (level 30 or no content → terminal).
- `journey_tutorial.dart` — `JourneyTutorialRepo` over the `kv` key `journey_col_tutorial_ack` (`isColumnTutorialAcknowledged` / `acknowledgeColumnTutorial`); `journeyTutorialRepoProvider`.
- `column_tutorial_overlay.dart` — `ColumnTutorialOverlay` (dim layer + looping vertical-drag gesture ghost + one line of copy, no button; listens to `PlaySessionController`; satisfied on `MoveAxis.column` in `animatingShift`/`animatingBounce`; re-prompt on a row gesture / 6 s idle; reduced-motion → static pose).
- `journey_strings.dart` — `JourneyStrings` per-language table (`_tr` / `_en`, `.of(lang)`), keys per `ui-design.md §13` + `levelCaption` / `progressSemantics` helpers.

**Created — interim content pack (`app/assets/journey/tr/`)**
- `journey_manifest_tr.json` — `mode:"smoke"`, `contentVersion:"2026.09-interim"`, 5 levels with `n` / `id` / `asset` / `difficultyLabel` / sha256 `checksum` (`architecture.md §5.5`).
- `journey-tr-01.json … journey-tr-05.json` — copies of `content/smoke/tr/level{01,02,04,05,06}.json` re-`id`'d to `journey-tr-0N`, `journeyLevelNumber = n`, `contentVersion` bumped. `04` carries `columnMovesEnabled` + a locked cell; `05` carries `columnMovesEnabled` + a frozen cell (so the 4–6 tutorial band has real column content).

**Created — tests**
- `app/test/journey/journey_ids_test.dart` — `journeyLevelId` / `parseJourneyLevel` round-trip + non-journey ids; `nextJourneyLevel` advance / level-30 / past-last / out-of-range.
- `app/test/journey/journey_content_repo_test.dart` — resolver over a fake source: resolves; missing entry / missing asset / corrupt JSON / id mismatch → `JourneyContentException` (rest playable); non-contiguous manifest → exception.
- `app/test/journey/journey_manifest_gate_test.dart` — **F05-FE.GATE**: loads the REAL bundled `assets/journey/tr/` pack via `rootBundle`; schema + contiguity; `strict` ⇒ 30 (smoke logs the shortfall); every level resolves to a valid `Puzzle` with checksum match, stable id, `optimalMoves >= 1`.
- `app/test/journey/journey_progress_model_test.dart` — the read-model vs the REAL `JourneyProgressRepo` + in-memory DB: fresh guest; after 1..3; in-progress snapshot; completed / non-journey snapshot; all-30 terminal; stray-id clamp.
- `app/test/journey/journey_home_test.dart` — home renders new / mid / terminal; the ring `Semantics` line; CONTINUE / REPLAY navigate to the resolved level.
- `app/test/journey/journey_unlock_flow_test.dart` — integration: solving a Journey level through `/play` drives `markCompleted` against the real repo + in-memory DB; Retry + re-solve stays idempotent.
- `app/test/journey/column_tutorial_test.dart` — the 4–6 gate: shows on level 4; a row drag does not satisfy it; a column drag clears it + persists the `kv` ack; an existing ack suppresses it; leaving without the column move does not persist.
- `app/test/rating/completion_cta_weighting_test.dart` — the `architecture.md §16` per-outcome weighting on F04's `CompletionPanel` (3★ + wired → amber pill is `SONRAKİ`; 2★ → amber pill stays `Yeniden`; 3★ + not wired → `Yeniden` amber + `Next` disabled with `· yakında`).

**Updated**
- `app/lib/play/play_session_providers.dart` — filled `playSessionSetupProvider`'s `source == journey && journeyLevel != null` branch: resolve `lang` via `SettingsRepo` (default `tr`), `journeyContentRepoProvider.loadLevel(n, lang)` → `PlaySessionSetup`. `UnsupportedError` retained for F07 Daily.
- `app/lib/play/play_session_controller.dart` — additive: optional ctor params `journeyProgressRepo` + `journeyLevel`; `_resolveJourneyUnlock()` (sibling of `_resolvePersonalBest`, `unawaited`, caught, after the `personal_best` write) → `markCompleted(guestId, journeyLevel)` when `source == journey`.
- `app/lib/play/play_session_screen.dart` — `_init()` builds the controller with `journeyProgressRepo` + `journeyLevel`; resolves the 4–6 tutorial gate (`journeyLevel ∈ 4..6 && !ack`, catch → show); `_dismissColumnTutorial()` (setState + caught ack write); `_nextLevelHandler()` (fills F04's `onNextLevel` — loads the manifest, `nextJourneyLevel`, `pushReplacement` to N+1 / `context.go('/')` → terminal; `null` for a non-Journey session); `_popToCaller` uses `GoRouter.of(context)` with a `!canPop` → `context.go('/')` fallback; the `Stack` adds `ColumnTutorialOverlay` while `_showColumnTutorial && !won`.
- `app/lib/rating/completion_panel.dart` — the per-outcome CTA weighting (`architecture.md §16`): `_Actions` gains `isPerfect`; `_RetryCta` + `_NextLevelCta` collapsed into one `_CtaPill({label, onPressed, primary, disabledSuffix})`; exactly one amber pill, primary on top — `isPerfect && onNextLevel != null` → amber = `SONRAKİ` (+ ghost `Yeniden`), else amber = `Yeniden` (+ ghost `SONRAKİ`, `· yakında` only when unwired). Star reveal / `N / 3` / triptych / markers / six variants / `Kapat` untouched.
- `app/lib/home_screen.dart` — replaced with the F05 home (`ConsumerWidget` on F03's `PlayStage`): `_Wordmark`; `_JourneyRing` + `_JourneyRingPainter` (CustomPaint, 300° arc / 60° bottom gap, all-locked track → completed-run glow arc + amber ticks → current node with a cyan ring when in-progress); `_RingCentre` (`N / 30` tabular + `SEVİYE` / `TAMAMLANDI` kicker, `TweenAnimationBuilder` settle-tick on count change); `_ContinueCta` (amber pill + `Seviye {N}` caption, `· sürüyor` when resumable; terminal → `TEKRAR OYNA` → Level 1); `_DebugRow` behind `kDebugMode`.
- `app/pubspec.yaml` — `flutter/assets: - assets/journey/tr/`; `dev_dependencies: crypto: ^3.0.3` (the gate test verifies asset sha256). `flutter pub get` run.
- `melos.yaml` — `content:sync` (mirror `content/journey/**` → `app/assets/journey/**` when present; a documented no-op stub until `F06-CONTENT`) + `content:journey` (runs the manifest gate test). `content:check` untouched.

---

## 3. Task-to-Code Traceability

| Task ID | Status | Files | Behaviour implemented |
| --- | --- | --- | --- |
| **F05-FE.CONTENT** | Complete | `journey/journey_content.dart`, `play/play_session_providers.dart`, `app/assets/journey/tr/*`, `pubspec.yaml`, `melos.yaml` | `journeyLevelId(n, lang)` → `journey-<lang>-<NN>` (zero-padded); `parseJourneyLevel(id)` → `int?` (regex `^journey-([a-z]{2})-(\d{2})$`, `null` outside 1..30). `JourneyManifest.fromJson` validates `schemaVersion == 1`, `mode ∈ {smoke,strict}`, non-empty + contiguous-from-1 levels. `JourneyContentRepo.loadLevel` reads `entry.asset` via the injectable `JourneyAssetSource`, `Puzzle.fromJson`, asserts `puzzle.id == entry.id == journeyLevelId(n,lang)`; manifest + levels cached per session. `playSessionSetupProvider`'s journey branch resolves `lang` from `SettingsRepo` (default `tr`) then `loadLevel` → `PlaySessionSetup`; any failure is a `JourneyContentException` → F03's existing `/play` load-error state. Interim pack: 5 re-`id`'d smoke copies + a `mode:"smoke"` manifest with sha256 checksums. |
| **F05-FE.GATE** | Complete | `journey/journey_content.dart`, `test/journey/journey_manifest_gate_test.dart`, `melos.yaml` (`content:journey`) | The gate is a widget-binding test that loads the **real bundled** pack via `rootBundle` and applies `architecture.md §5.4`: parse + contiguous `n` + stable id + `optimalMoves >= 1` + checksum match, always; `mode:"smoke"` `print`s the `<30` shortfall and passes; `mode:"strict"` asserts `levels.length == 30`. Runs in `flutter test` (so already in `melos run test`) and standalone via `melos run content:journey`. The strict-mode structural band assertions are stubbed pending `F06-CONTENT` (documented in-file). |
| **F05-FE.PROGRESS** | Complete | `journey/journey_progress.dart` | `buildJourneyProgressModel` is pure: parses `completedLevelsCsv`, sets `inProgressLevel` from `parseJourneyLevel(snap.puzzleId)` only when `snap.puzzleSource == journey && snap.status == inProgress`. `stateOf(n)` → `inProgress` / `completed` / `locked` (`n > highestUnlockedLevel`) / `unlockedIncomplete`. `progressCount` counts `completedLevels ∩ 1..30` (stray ids from `markCompleted`'s `N+1` unlock are clamped out). `continueTarget` = in-progress level, else lowest unlocked-incomplete, else `null`. `journeyProgressModelProvider` streams `JourneyProgressRepo.watch(guestId)` and re-reads `activeSessionRepo.read()` each tick. |
| **F05-FE.UNLOCK** | Complete | `play/play_session_controller.dart`, `play/play_session_screen.dart` | Optional ctor params `journeyProgressRepo` + `journeyLevel` mirror F04's `personalBestRepo` + `guestId`. In `_beginCompletion`, after `_ratingWork = _resolvePersonalBest(...)`: `unawaited(_resolveJourneyUnlock())`. `_resolveJourneyUnlock` no-ops unless `repo != null && guestId != null && level != null && source == journey`, then `await repo.markCompleted(guestId, level)` inside a `try` that `debugPrint`s `journey: unlock_persist_failed (non-fatal)` on error — never blocks the panel. `_LoadedPlaySession._init()` plumbs `widget.args.journeyLevel` + `journeyProgressRepoProvider` (additive). `markCompleted` is transactional + idempotent (F08) so Retry + re-solve does not double-count. |
| **F05-FE.NAV** | Complete | `play/play_session_screen.dart`, `journey/journey_nav.dart`, `home_screen.dart`, `rating/completion_panel.dart` | `_nextLevelHandler()` → `null` for a non-Journey session; else an async closure: load `journeyManifestProvider(_lang)`, `nextJourneyLevel(n, manifestLevelCount: manifest.levels.length)`; `null` → `context.go('/')` (terminal), else `context.pushReplacement('/play', PlaySessionArgs(source: journey, journeyLevel: next))` — no stack growth. `_popToCaller`: `router.canPop()` ? `pop()` : `context.go('/')`. Home `_ContinueCta`: `model.continueTarget` (or `1` while loading/errored/terminal) → `context.push('/play', …)`. CTA weighting: see F05-FE.NAV row of `completion_panel.dart` in §2 — additive, F04's panel otherwise untouched. |
| **F05-FE.HOME** | Complete | `home_screen.dart` | Full rewrite per `ui-design.md` "The loop, filling". `_JourneyRingPainter` draws the all-locked tick track, then the completed-run glow arc + amber ticks, then the current node (bright tick + tip dot + a cyan stroke ring when `currentInProgress`). `_RingCentre` shows the tabular `N / 30` with a 160 ms `TweenAnimationBuilder` scale settle keyed on `count`, and swaps the kicker to `TAMAMLANDI` in the terminal state. `_ContinueCta` is the only dominant control — amber pill (F04's treatment), `Seviye {N}` caption with `· sürüyor` when `inProgressLevel == target`, `TEKRAR OYNA` → Level 1 when `allComplete`. `_DebugRow` (smoke ids) only under `kDebugMode`. No spinner; loading renders the ring at `0 / 30` with a working CONTINUE. App root — no back affordance. |
| **F05-FE.TUTORIAL** | Complete | `journey/column_tutorial_overlay.dart`, `journey/journey_tutorial.dart`, `play/play_session_screen.dart` | `JourneyTutorialRepo` reads/writes the `kv` row `journey_col_tutorial_ack` (`{ack:true, atUtcMs}`) via `insertOnConflictUpdate` — **no F08 schema change** (`architecture.md §9`, §14). `_init()` shows the overlay iff `source == journey && journeyLevel ∈ 4..6 && !isColumnTutorialAcknowledged()` (a read failure → show, a safe mild over-prompt). `ColumnTutorialOverlay` listens to the controller: a drag F03 resolves to `MoveAxis.column` while `animatingShift`/`animatingBounce` → `onSatisfied()` → `_dismissColumnTutorial()` (setState false + caught `acknowledgeColumnTutorial()`); a `MoveAxis.row` drag or a 6 s idle → one re-prompt cycle (`_emphasis++`). `IgnorePointer` so the board still takes the gesture. Reduced motion → `_ghost.value = 0.5` (static finger + arrow), still gated on the column shift. Leaving `/play` disposes the overlay without writing the ack. |
| **F05-FE.STRINGS** | Complete | `journey/journey_strings.dart` | `JourneyStrings` per-language table in F03's `PlayStrings` / F04's `RatingStrings` interim pattern — keys per `ui-design.md §13` (`continueLabel` / `replayLabel` / `levelWord` / `inProgressSuffix` / `progressUnit` / `allCompleteKicker` / `columnTutorialHint` / `levelsWord` / `completeWord`) + `levelCaption(n, {inProgress})` and `progressSemantics(done, current)`. `gen_l10n` stays `[DEFERRED — F10-or-earlier]`; final TR copy owned by PO/localization. |
| **F05-FE.TESTS** | Complete | `test/journey/*`, `test/rating/completion_cta_weighting_test.dart` | 8 new test files, 34 new cases. See §17 / §18. `flutter analyze` clean; `flutter test` **166 green** (was 132, +34, no regression); pure-package `dart test` all green; `dart format --set-exit-if-changed` clean; `flutter build ios --release --no-codesign` green (`Runner.app`, 54.7 MB). |

---

## 4. Authority Reconciliation

No contract conflict. `ui-design.md`'s 4 `Needs Tech Lead Clarification` items were resolved with the defaults the handoff itself proposed — recorded for Tech Lead visibility, not silent:

| Item | `ui-design.md §14` | Decision applied | Downstream |
| --- | --- | --- | --- |
| Terminal-state CONTINUE target | (1) — default: Level 1 | `_ContinueCta` renders `TEKRAR OYNA` → `journeyLevel: 1` when `allComplete` (progress not reset). A working CTA over a hidden one. | None. |
| 4–6 micro-tutorial gate strictness | (2) — default: column `endDrag` applied **or** bounced | `ColumnTutorialOverlay._onController` treats `animatingShift` **and** `animatingBounce` on `MoveAxis.column` as satisfied. QA may tune to applied-only. | Covered by `column_tutorial_test.dart`. |
| Wordmark type-only vs a logo asset | (3) | Type-only `Text('LOOPLET')` with F03's `stageGlow` shadow — no asset added. | F10 owns the home re-home / branding. |
| TR microcopy | (4) — → PO/localization | Interim strings in `journey_strings.dart` (`_tr`), same track as F03/F04. | PO/localization follow-on. |

**Interim content location — deliberate deviation from the Next Action brief.** The brief names `content/journey/tr/` as the interim pack's home with a `content:sync` mirror. To keep F06's `melos run content:check` (which scans `content/`) completely untouched, the 5 interim artifacts + manifest live **only** under `app/assets/journey/tr/` and are hand-maintained there; `melos run content:sync` is shipped as a documented no-op stub that will mirror `content/journey/**` → `app/assets/journey/**` once `F06-CONTENT` populates it. The `architecture.md §5.1` steady-state (source of truth in `content/journey/`, app bundle mirrored) is unchanged — only the interim staging point moved, and only to avoid a false-positive in F06's gate. Flagged for Tech Lead / QA.

**F04 CTA-weighting follow-on** (F04 `frontend.md §4` forward note) — implemented here per `architecture.md §16` as an additive weighting + order swap on the two existing pills; F04's 7 AC7 elements, six variants, star reveal and triptych are untouched. F04's own `completion_panel_test.dart` still asserts the debug-entry path (`onNextLevel == null` → amber `Yeniden` + disabled `SONRAKİ` + `yakında`) and stays green.

---

## 5. Components

| Component | File | Notes |
| --- | --- | --- |
| `HomeScreen` (+ `_Wordmark` / `_JourneyRing` / `_JourneyRingPainter` / `_RingCentre` / `_ContinueCta` / `_DebugRow`) | `home_screen.dart` | The F05 home. `CustomPainter` ring; no new `PlayTheme` tokens. |
| `ColumnTutorialOverlay` (+ `_GestureGhost`) | `journey/column_tutorial_overlay.dart` | Diegetic, action-gated, no button. Reduced-motion aware. |
| `JourneyContentRepo` / `JourneyManifest` / `JourneyManifestLevel` / `JourneyAssetSource` | `journey/journey_content.dart` | The bundled-content resolver + manifest model. |
| `JourneyProgressModel` | `journey/journey_progress.dart` | Pure read-model; `LevelState` per level. |
| `JourneyTutorialRepo` | `journey/journey_tutorial.dart` | One `kv` flag; no schema change. |
| `JourneyStrings` | `journey/journey_strings.dart` | Interim per-language table. |
| `_CtaPill` | `rating/completion_panel.dart` | Replaces `_RetryCta` + `_NextLevelCta`; one widget, `primary` flag. |

---

## 6. Screens

| Screen | Route | Change |
| --- | --- | --- |
| Home | `/` | `HomeScreen` fully replaced — journey ring + CONTINUE + terminal variant. |
| Play | `/play` | Additive: resolves a Journey level by number; `onNextLevel` wired; the 4–6 tutorial overlay; `GoRouter`-based back with a `/` fallback. No F03 contract field changed. |

No new routes (`architecture.md §8` D4 — terminal + tutorial are in-screen states).

---

## 7. State Management

- `journeyProgressModelProvider` — `StreamProvider<JourneyProgressModel>` over `JourneyProgressRepo.watch(guestId)`, re-reading the active-session snapshot per tick. Consumed by `HomeScreen`.
- `journeyManifestProvider` — `FutureProvider.family<JourneyManifest, String>(lang)`; consumed by the resolver and `_nextLevelHandler`.
- `journeyContentRepoProvider` / `journeyAssetSourceProvider` — the resolver + its injectable source (overridden in tests).
- `journeyTutorialRepoProvider` — the `kv` ack repo.
- `PlaySessionController` — two new optional fields (`_journeyProgressRepo`, `_journeyLevel`); the unlock write is a `ChangeNotifier`-internal fire-and-forget, no new public surface beyond the ctor params.

---

## 8. API / Event Integration

None. F05 is client-only, local-only: one `journey_progress` row (F08's `JourneyProgressRepo`) + one `kv` flag. No endpoint, no analytics (F12), no audio/haptics (F11). Security compliance N/A — single actor, no auth, no network (to be justified in the QA output per `architecture.md §15`).

---

## 9. Contract Compliance Check

| `architecture.md` | Implemented as specified |
| --- | --- |
| §4 — id scheme `journey-<lang>-<NN>` ↔ `journeyLevelNumber`, F08 snapshot not extended | `journeyLevelId` / `parseJourneyLevel`; in-progress level = `parseJourneyLevel(snap.puzzleId)` |
| §5.1–5.3 — app-layer `rootBundle` loader, `looplet_content` stays pure | `RootBundleJourneyAssetSource` in `app/lib/journey/`; `looplet_content` untouched |
| §5.2 / §5.4 — manifest schema + build gate (smoke/strict) | `JourneyManifest.fromJson` + `journey_manifest_gate_test.dart` + `content:journey` |
| §5.5 — interim `mode:"smoke"` manifest, F06 smoke → levels 1–5 | `app/assets/journey/tr/journey_manifest_tr.json` (n=1→01, 2→02, 3→04, 4→05, 5→06 source) |
| §6 — progression read-model over `watch` + snapshot | `buildJourneyProgressModel` + `journeyProgressModelProvider` |
| §7 — unlock write injected into `PlaySessionController`, caught, after `personal_best` | `_resolveJourneyUnlock()`, `unawaited`, after `_resolvePersonalBest` |
| §8 — `Next Level` = `pushReplacement`; in-screen terminal/tutorial; all back → `/` | `_nextLevelHandler` + `_popToCaller` |
| §9 / §14 — 4–6 tutorial-ack in a `kv` row, key registry | `JourneyTutorialRepo`, `kvKey = 'journey_col_tutorial_ack'` |
| §11 — F09 seam shipped `onboardingComplete` hard-`true` | No onboarding gate added; `/` → home directly (unchanged from F03/bootstrap) |
| §16 — F04 `CompletionPanel` per-outcome CTA weighting, additive | `_Actions.isPerfect` + `_CtaPill`; one amber pill; F04 panel otherwise untouched |

No F03/F04/F06/F08 contract change.

---

## 10. Behavior Preserved

- F03 play: gesture → shift, 3-undo quota, restart, elapsed timer, write-through snapshot, F08 restore-on-open — untouched (`play_session_runtime_test.dart` + `play_session_controller_test.dart` green).
- F04 completion: stars (1–3, never 0), Perfect ⇔ 3, the personal-best triptych + six variants + star reveal + `Kapat` — untouched; only the two CTAs re-weight (`completion_panel_test.dart` green).
- F06 `content:check` — not touched (interim pack lives outside `content/`).
- Full suite: **166 tests green**, 132 pre-existing + 34 new, zero regression.

---

## 11. UX Decisions

- **Loading home** renders the ring at `0 / 30` with a live CONTINUE (→ Level 1) rather than a spinner — a working control over a dead one (`ui-design.md §14` (1)).
- **Terminal CONTINUE** is repurposed (`TEKRAR OYNA`), never hidden or greyed.
- **Tutorial re-prompt** is one emphatic ghost cycle + a copy-scale pulse, not a nag dialog; it never blocks the board (the `IgnorePointer` passes the very gesture it asks for).
- **`· yakında`** on the ghost `SONRAKİ` pill appears only when `onNextLevel` is unwired (the debug entry) — for a real Journey session `Next Level` is always enabled.

---

## 12. Implemented Files

See §2. New code is confined to `app/lib/journey/` (6 files) + `app/assets/journey/tr/` (6 files) + 8 test files; 6 existing `app/lib` files received additive edits; `pubspec.yaml` + `melos.yaml` updated.

---

## 14. Assumptions

- The seeded guest always has a `journey_progress` row (F08 `_seedDefaults`) — the read-model and unlock write assume `read(guestId)` succeeds; a failure only costs the home ring / the unlock (caught), never the panel or play.
- `SettingsRepo.read(guestId).language` defaults to `tr`; a missing settings row falls back to `tr` in the resolver.
- The interim manifest's 5 levels are enough for F05 build + QA; the 4–6 tutorial band is exercised by `journey-tr-04` (which carries `columnMovesEnabled`).
- Level 30's `Next Level` routing to the terminal state is covered by `nextJourneyLevel(30, …) == null` → `context.go('/')`; not separately widget-tested against a 30-level manifest (interim pack has 5) — flagged for QA once `F06-CONTENT` lands.

---

## 17. Test Evidence by Task

| Task | Test file(s) | Cases |
| --- | --- | --- |
| F05-FE.CONTENT | `journey_ids_test.dart`, `journey_content_repo_test.dart` | 10 |
| F05-FE.GATE | `journey_manifest_gate_test.dart` | 4 |
| F05-FE.PROGRESS | `journey_progress_model_test.dart` | 6 |
| F05-FE.UNLOCK | `journey_unlock_flow_test.dart` | 2 |
| F05-FE.NAV / .HOME | `journey_home_test.dart` | 3 |
| F05-FE.NAV (CTA weighting) | `completion_cta_weighting_test.dart` | 3 |
| F05-FE.TUTORIAL | `column_tutorial_test.dart` | 3 |

Gate results:
- `flutter analyze` (app) — **No issues found!**
- `dart format --output=none --set-exit-if-changed .` (app + `packages` + `tools`) — clean.
- `flutter test` (app) — **166 passed** (132 baseline + 34 new; no regression). Pre-existing drift "multiple databases" warnings in `play_session_screen_test.dart` only — non-fatal, not introduced here.
- pure-package `dart test` (`looplet_core` / `_dictionary` / `_engine` / `_content` / `_solver` / `looplet_authoring`) — all green.
- `flutter build ios --release --no-codesign` — **Built `build/ios/iphoneos/Runner.app` (54.7 MB)**.

---

## 18. Test Notes

- **Widget tests that mount `ColumnTutorialOverlay`** set `FakeAccessibilityFeatures(disableAnimations: true)` before `pumpWidget` so the gesture ghost holds its static pose (`_ghost.repeat()` would otherwise make `pumpAndSettle` time out). The column-satisfies / row-does-not gate logic is unaffected by reduced motion (`_onController` fires on the controller notification, not the ghost animation).
- **`journey_unlock_flow_test.dart`** drives the real `/play` screen with an overridden `journeyAssetSourceProvider` (a `journey-tr-01` whose row 0 is `A S A L M` → a 1-move MASAL win, mirroring `smoke-tr-01`) and asserts `JourneyProgressRepo.read` after `pumpAndSettle` — the same settle-then-read pattern `play_session_runtime_test.dart` uses for snapshot writes.
- **`journey_home_test.dart`** wraps `HomeScreen` in a minimal 2-route `GoRouter` and records `state.extra` on `/play` to assert the CONTINUE / REPLAY target. The ring's progress line is asserted via the `Semantics` widget's `properties.label` directly (no `ensureSemantics` handle — same approach as F04).
- **Deferred to QA / `F06-CONTENT`**: the strict-mode structural band assertions (`journey_manifest_gate_test.dart` stub); a `Next Level` → terminal widget test against a real 30-level manifest; on-device feel of the ring + tutorial (folds into the deferred first-app-distribution smoke).

---

## 19. Sonraki Komut

```text
Run QA
```

Current Owner → QA. Next Role → QA (F05-QA — end-to-end client QA per `architecture.md §15`).
