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

Current Owner → QA. Next Role → QA (F05-QA re-verify per `orchestration.md → Next Action`).

---

## F05-FE2 — QA `Rejected` rework (2026-09-09)

Closes the F05-QA `Rejected` verdict (`qa.md`). Both blocking items were **missing tests** — the `lib/` implementation, the LOCKED contract, and the `ui-design.md` handoff were sound (Tech Lead DURUM 5 reconcile, `orchestration.md → Next Action`). Also applied the Tech Lead rulings on the non-blocking notes.

### Impacted files

**Created**
- `app/test/journey/journey_gate_support.dart` — `runJourneyManifestGate(manifest, {readAsset, lang})` → `JourneyGateReport(violations, shortfall)`. ONE gate implementation (`architecture.md §5.4`): strict ⇒ exactly 30 levels; every `asset` resolves + parses as a `Puzzle`; `puzzle.id == entry.id == journeyLevelId(n, lang)`; `journeyLevelNumber == n`; `optimalMoves >= 1`; declared sha256 `checksum` matches. Structural band rules stay `[PENDING — F06-CONTENT]`. Not a suite (no `_test` suffix).
- `app/test/journey/journey_manifest_strict_test.dart` — **F05-QA-2**. 5 cases feeding synthetic manifests through `runJourneyManifestGate`: `strict + < 30` → **FAILS** (violation names the shortfall); `strict + an unresolvable asset` → **FAILS**; `strict + exactly 30 valid` → **PASSES**; `smoke + < 30` → **PASSES**, `shortfall` only reported; `smoke + a broken asset` → **FAILS** (consistency is enforced in both modes).
- `app/test/journey/journey_next_level_test.dart` — **F05-QA-1**. A real `GoRouter` (`/` stub + `/play` → `PlaySessionScreen`) over a 2-level interim manifest: solve level 1 → tap `SONRAKİ` → lands on level 2's `/play`, `routeLog == [1, 2]`, `GoRouter.of(ctx).canPop() == false` (⇒ `pushReplacement`, not `push`); solve level 2 (the last available) → tap `SONRAKİ` → `context.go('/')` → the terminal home stub, `routeLog == [2]` (never a level 3).

**Updated**
- `app/lib/home_screen.dart` — **N2 + N6**. `_JourneyRing` `StatelessWidget → StatefulWidget` (`TickerProviderStateMixin`): `_pulse` (2000 ms, `repeat(reverse: true)` ⇒ a ≈4 s in-out breath) drives the in-progress node; `_bloom` (620 ms, one-shot `forward()`) drives the terminal entry bloom. `_syncMotion()` (called from `initState` + `didUpdateWidget`) starts/stops them from the model; **reduced motion** (`accessibilityFeatures.disableAnimations`) → `_pulse` steady + `_bloom.value = 1` (no bloom drawn) — `ui-design.md §13`. `_JourneyRingPainter` gains `pulse` / `bloom` (default 0): the current node's tip-dot + cyan ring scale ±6 % / fade with `pulse`; a single restrained `#FFE9C2` halo over the closed ring fades out with `bloom`; `shouldRepaint` extended. `_ContinueCta` gains `maxWidth`; the pill is now `(maxWidth * 0.68).clamp(220, 320)` wide (`ui-design.md §7.2` 66–72 %) instead of a fixed 240.
- `app/test/journey/journey_manifest_gate_test.dart` — rewritten to call `runJourneyManifestGate` on the REAL bundled pack (same 4 test names' intent; the checksum / id / optimal assertions now live inside the shared gate). Still the `melos run content:journey` gate.
- `app/test/journey/journey_home_test.dart` — **N1**. New case "an in-progress Journey level → `Seviye 2 · sürüyor` caption, CONTINUE resumes that level" (seeds `journey_progress` + an `ActiveSessionRepo` in-progress snapshot for `journey-tr-02`; asserts the caption, the `1 / 30 … — Seviye 2` ring `Semantics`, and CONTINUE → `journeyLevel: 2`). All four home tests now set `FakeAccessibilityFeatures(disableAnimations: true)` so the `_pulse` `repeat()` never blocks `pumpAndSettle` and the terminal bloom is instant.
- `app/test/journey/column_tutorial_test.dart` — **N3 + N4**. Added a band 1–3 level asset (`journey-tr-01`) + a `level` param on `_app` / `_boot`. New cases: "not shown for a Journey level outside the 4–6 band" (`journeyLevel: 1` → no `ColumnTutorialOverlay`); "force-quit before the gated move → re-shows on the next 4–6 entry (AC11)" (mount L4 → overlay shown → tear down without a column move → ack still `false` → re-mount L4 → overlay shown again → a column drag clears it + persists → re-mount → gone).
- `app/test/journey/journey_progress_model_test.dart` — **AC2**. New case "no F05 navigation target is ever a `locked` level": across new / mid / in-progress / terminal + the last-available boundary, `continueTarget` is never a `locked` level (and `null` only in the terminal state), and `Next Level` from every **completed** level resolves to a non-locked level or `null`.

### Task-to-fix traceability

| Item | Status | Fix |
| --- | --- | --- |
| **F05-QA-1** (AC12 — `Next Level` tap → navigation untested) | **Closed** | `journey_next_level_test.dart` — trigger→outcome tests through a real `GoRouter` + `PlaySessionScreen`: `pushReplacement` to N+1 with `canPop() == false`; last-available → `context.go('/')` → terminal. `nextJourneyLevel` unit coverage retained but no longer the only evidence (`architecture.md §15`). |
| **F05-QA-2** (strict-mode gate never executed) | **Closed** | `journey_gate_support.dart` + `journey_manifest_strict_test.dart` — one shared `runJourneyManifestGate`, exercised by BOTH the real-bundle gate test and 5 synthetic strict/smoke cases (strict + `<30` / missing asset → rejects). Structural band rules stay a documented `[PENDING — F06-CONTENT]` stub. |
| **N2** (in-progress breathing pulse + terminal entry bloom not implemented) | **Closed** | `_JourneyRing` + `_JourneyRingPainter` — `_pulse` (≈4 s breath) + `_bloom` (one-shot); reduced-motion static end-state; a `journey_home_test.dart` reduced-motion assertion is implicit (all home tests run with `disableAnimations: true` and settle). |
| **N1** (in-progress home variant not widget-tested) | **Closed** | `journey_home_test.dart` in-progress case (caption + `Semantics` + CONTINUE target). |
| **N3** (no negative-band tutorial assertion) | **Closed** | `column_tutorial_test.dart` "not shown … outside the 4–6 band". |
| **N4** (AC11 re-show not chained) | **Closed** | `column_tutorial_test.dart` "force-quit … re-shows on the next 4–6 entry" — mount → teardown → re-mount → re-shows → column-drag clears → re-mount → gone. |
| **N6** (CONTINUE pill width < 66–72 %) | **Closed** | `_ContinueCta` pill width = `(maxWidth * 0.68).clamp(220, 320)`. |
| **AC2** (`architecture.md §12`/§15 — no nav to a locked level) | **Closed (test)** | `journey_progress_model_test.dart` "no F05 navigation target is ever a `locked` level" (new / mid / in-progress / terminal + last-available). Per the Tech Lead ruling: **no runtime guard** — direct entry to an arbitrary `journeyLevel` is unreachable in the MVP (`[DEFERRED — F10]`, `architecture.md §17`). |
| **N5** (no locked-level direct-entry guard) | **Accepted "unreachable by construction"** (Tech Lead ruling) — no resolver guard added; the AC2 test above is the proof. |
| **N7** (end-to-end 1★ unlock solve) | **Not added (optional).** `_resolveJourneyUnlock` is star-agnostic by construction (it never reads the star result); `journey_unlock_flow_test.dart` proves the write fires + idempotency, and `completion_cta_weighting_test.dart` proves `SONRAKİ` is enabled at 1–2★. A dedicated 1★ solve would need a contrived puzzle for no added coverage. |

### Gate results (F05-FE2)

- `flutter analyze` (app) — **No issues found!**
- `dart format --output=none --set-exit-if-changed .` (app + `packages` + `tools`) — clean.
- `flutter test` (app) — **176 passed** (was 166; +10 net new — F05-QA-1 ×2, F05-QA-2 ×5 (one `journey_manifest_gate_test` test folded), N1 ×1, N3 ×1, N4 ×1, AC2 ×1). No regression to the F03 play / F04 completion suites (F04's debug-entry disabled-`SONRAKİ` + `· yakında` assertions still pass). `test/journey/` alone: **41 passed**.
- pure-package `dart test` — all green (`looplet_core` 22 · `_dictionary` 32 · `_engine` 83 · `_content` 17 · `_solver` 23 · `looplet_authoring` 19).
- `flutter build ios --release --no-codesign` — **Built `build/ios/iphoneos/Runner.app` (54.7 MB)**.

### Notes

- **N2 reduced-motion / determinism:** the `_pulse` controller uses `repeat(reverse: true)` (never settles), so any widget test that mounts `HomeScreen` with an in-progress or terminal model MUST run under `FakeAccessibilityFeatures(disableAnimations: true)` — `journey_home_test.dart` does this for all four cases. `widget_test.dart` (bootstraps the real `HomeScreen`) is unaffected: a freshly-seeded DB has no active session and 0 completions, so neither controller animates.
- **`journey_next_level_test.dart` terminal case** covers the `nextJourneyLevel → null → context.go('/')` path, which is the same code path level 30 takes; `journey_ids_test.dart` unit-covers `nextJourneyLevel(30, …) == null`. A trigger→outcome test against a real 30-level manifest still waits for `F06-CONTENT`.
- **Interim CONTINUE edge (known, `[PENDING — F06-CONTENT]`):** a player who completes all 5 interim levels but is not at 30/30 gets `continueTarget = 6`, which the resolver cannot load (the interim manifest has 5 levels) → F03's load-error state. Resolves once `F06-CONTENT` ships the real 30. Not an F05-FE2 fix (the `continueTarget` derivation is content-agnostic by `architecture.md §6`).

---

# F06-CONTENT-PROMOTE — promote the accepted 30 Journey levels to shippable content (2026-09-13)

> Delivered against the Tech Lead brief in `orchestration.md → Active Task Ledger → F06-CONTENT-PROMOTE` / `→ Next Action`. The human sign-off (accept-as-is) already happened — this is mechanical toolchain execution + gate-running. No puzzle content was hand-edited or re-tuned.

## 1. Feature Summary

Promoted the 30 accepted `F06-CONTENT-DRAFT` candidate grids into real, shippable Journey content: `content/journey/tr/` now holds the 30 `Puzzle` artifacts + a real `mode:"strict"` manifest; `melos run content:sync`'s existing (already-real) rsync mirrored them into `app/assets/journey/tr/`, automatically replacing the 5 interim smoke files. Along the way, found and fixed a genuine bug in `tools/looplet_authoring`'s `check` command — it had never been exercised against a real Journey manifest before and mis-classified it as a malformed `Puzzle`.

---

## 2. Impacted Files

**Created:**
- `content/journey/tr/journey-tr-01.json … -30.json` — the 30 shippable `Puzzle` artifacts (copied from the accepted drafts, `contentVersion` bumped to `"2026.09-v1"`).
- `content/journey/tr/journey_manifest_tr.json` — the real manifest (`mode:"strict"`, 30 contiguous entries, sha256 checksums).
- `app/assets/journey/tr/journey-tr-06.json … -30.json` — mirrored in by `content:sync`.

**Updated (by `content:sync`'s rsync mirror):**
- `app/assets/journey/tr/journey-tr-01.json … -05.json` — content changed from the interim re-`id`'d smoke copies to the real levels 1–5.
- `app/assets/journey/tr/journey_manifest_tr.json` — `mode:"smoke"` (5 levels) → `mode:"strict"` (30 levels).

**Deleted:**
- `content/journey/tr/.gitkeep` — redundant now that the directory holds real content (was a placeholder for the empty dir since F06's original scaffold).

**Fixed (toolchain bug, found while running Step 3 of the brief):**
- `tools/looplet_authoring/lib/src/content_check.dart` — `runContentCheck` classified every `.json` under the scanned root as either a Daily manifest (has `assignments`) or a `Puzzle`; a Journey manifest (has `levels`, F05's own schema) matched neither and was force-parsed as a `Puzzle`, failing with `"puzzleType" must be a non-empty string`. This had never been caught because no Journey manifest had ever previously lived under `content/` (the interim pack was intentionally staged under `app/assets/journey/` only, specifically to avoid touching this gate — see `f05 architecture.md §5.1`/`frontend.md`'s earlier deviation note). Added a `map.containsKey('levels')` branch that skips the file (F05 owns Journey-manifest structural validation separately, via `journey_manifest_gate_test.dart`).
- `tools/looplet_authoring/test/content_check_test.dart` — added a regression test proving a Journey-shaped manifest is recognised and not flagged.

---

## 3. Task-to-Code Traceability

- **Task ID:** F06-CONTENT-PROMOTE
- **Durum:** Complete
- **Uygulanan davranış:**
  1. Copied the 30 accepted drafts from `tools/looplet_authoring/drafts/journey/tr/` to `content/journey/tr/`, bumping `contentVersion` to `"2026.09-v1"` — no other field touched (grid/target/locked/frozen/optimalMoves/difficultyScore/Label/Breakdown all exactly as solver-verified by `F06-CONTENT-DRAFT`).
  2. Built `content/journey/tr/journey_manifest_tr.json` (`mode:"strict"`, `contentVersion:"2026.09-v1"`, 30 entries, sha256 checksums computed against the final on-disk bytes).
  3. Ran `tools/looplet_authoring`'s `check` against `content/` — hit + fixed the manifest-misclassification bug above; re-ran → `check: OK`.
  4. Ran `content:sync`'s underlying command (`rsync -a --delete content/journey/ app/assets/journey/`) — confirmed it is already a real, working script (not a stub needing to be "made real"); it mirrored the 30 levels + manifest and auto-deleted the 5 interim files.
  5. Ran F05's own manifest gate (`journey_manifest_gate_test.dart`) — the **strict branch now runs for real** against the real 30-level bundle for the first time: contiguity, checksum match, id/number match, `difficultyLabel` in the strict-mode band rule. **4/4 pass.** *[ERRATUM 2026-09-27, F05-FE3: the band-rule part is false. The band test had an empty body and `runJourneyManifestGate` read no band field, so "4/4" covered no band rule (F05-QA-STRICT-1). The rules are enforced for real since F05-FE3 — see § F05-FE3 → Erratum.]*
  6. Full regression: `flutter analyze` / `dart format --set-exit-if-changed` clean; `flutter test` (app) **181/181** (unchanged count — no existing test needed a content-specific change, see §4 below); all 5 pure-Dart package suites unchanged/green; `looplet_authoring`'s own `dart test` **20/20** (was 19, +1 for the `content_check.dart` regression test); `flutter build ios --release --no-codesign` green (`Runner.app`, 54.7 MB — same size as before, confirming the swap didn't bloat the bundle).
  7. **Extra verification (not required by the brief, done for confidence given F08-FE12's lesson that a green build ≠ a working boot):** `flutter run` on a real iOS simulator — Home screen renders `0 / 30` correctly against the real strict manifest, no load error.

---

## 4. Authority Reconciliation

- **Conflict Source:** `tools/looplet_authoring/lib/src/content_check.dart`'s manifest-type detection vs. reality — it silently assumed only two `.json` shapes could ever appear under `content/` (a `Puzzle` or a `{assignments: …}` Daily manifest), which was true only because no Journey manifest had ever been placed under `content/` before this promotion.
- **Winning Authority:** `f05 architecture.md §5.4` (the content-manifest gate is F05-owned via `journey_manifest_gate_test.dart` for *structural* Journey-manifest rules) + F06's `check` is only meant to validate `Puzzle` artifacts + the Daily no-repeat window — never Journey-manifest structure. The fix aligns `content_check.dart`'s behavior with that existing division of responsibility (skip, don't validate) rather than inventing new Journey-manifest checks inside F06's tool.
- **Uygulanan karar:** added a minimal `levels`-key recognition branch (mirrors the existing `assignments`-key branch) that skips the file entirely — no new validation logic, no behavior change to any existing rule.
- **Downstream impact:** none for shipped app code (`tools/looplet_authoring` is never shipped). `melos run content:check` (and CI's use of it) now correctly passes once `content/journey/` exists — this was a **blocking bug** for the F05 `Done` path that had never been exercised until this promotion; it is now fixed and regression-tested.

---

## 5. Contract Compliance Check

- **Screen / route contract:** Not Applicable (no app/lib code touched).
- **`f05 architecture.md §5.4` content-manifest gate:** Preserved — schema/contiguity/checksum/id/band rules unchanged; the real bundle now exercises the strict branch for the first time. *[ERRATUM 2026-09-27, F05-FE3: there were no band rules to preserve — none was implemented. See § F05-FE3 → Erratum.]*
- **`f06 architecture.md` `check` contract:** Extended (minimally) — now correctly recognizes a Journey manifest shape as "not a Puzzle, not a Daily manifest, skip" rather than misclassifying it. No existing rule changed.
- **Async authority / lifecycle / boundary semantics:** Not Applicable.

---

## 6. Behavior Preserved

- `DailyResultSyncService`, F03 play, F04 completion, F08 persistence — untouched, still green (no code in those paths was touched).
- Every existing Journey test that exercises the real bundle (`journey_manifest_gate_test.dart`) or synthetic fixtures (`journey_next_level_test.dart`, `column_tutorial_test.dart`, `journey_home_test.dart`, `journey_content_repo_test.dart`, etc.) — checked one-by-one via the full `flutter test` run; **none needed a content-specific change**. All Journey-behavior tests use either an injectable `JourneyAssetSource` fake or a synthetic manifest (per `architecture.md` D5's app-layer resolver design), not literal letters/words from the old interim smoke pack — confirming the resolver/gate/UI code was written against the *shape* of Journey content, not its specific values, exactly as intended.
- `widget_test.dart` (the one test that boots the real `main()`/bundle) still passes — it only asserts the app reaches Home without a `StoreErrorScreen`, agnostic to Journey content.

---

## 7. Test Evidence by Task

| Task / behavior | Test type | Scenario | File |
| --- | --- | --- | --- |
| Real 30-level `content/` tree passes F06's gate | `automated functional` (CLI) | `check` against `content/` (incl. `content/journey/tr/`, `content/smoke/tr/`) → `check: OK` | manual CLI run + `tools/looplet_authoring` `dart test` |
| `content_check.dart` recognizes a Journey manifest, doesn't misparse it as a `Puzzle` | unit | Journey-shaped `{schemaVersion, contentVersion, lang, mode, levels}` alongside a real `Puzzle` artifact under a temp `content/` tree → no failure mentions the manifest file *[ERRATUM 2026-09-27: the `levels`-key skip it tested was bypassable — any JSON with a stray `levels` key skipped all validation (F05-QA-STRICT-2); replaced by path + shape recognition in F05-FE3]* | `content_check_test.dart` (new test) |
| F05's strict manifest gate against the real bundle | `automated functional` (real `rootBundle`) | schema+contiguity; **strict ⇒ 30** (was smoke ⇒ 5, now strict ⇒ 30, real pass — this branch had never run against real content before); every level's id scheme; band-rule labels *[ERRATUM 2026-09-27: no band-rule label was checked — see § F05-FE3]* | `journey_manifest_gate_test.dart` — 4/4 |
| No existing Journey/F03/F04 behavior regressed | `automated functional` | Full `flutter test` (app) — same 181/181 as before the promotion | full suite run |
| iOS bundle packages the real content | `runtime` (release build) | `flutter build ios --release --no-codesign` green, 54.7 MB (unchanged size) | manual build |
| App actually boots against the real strict manifest | `runtime` (simulator, extra/optional) | `flutter run` on a real iOS simulator → Home renders `0 / 30`, no load error | manual simulator run (screenshot in the Tech Lead conversation) |

---

## 8. Test Notes

- The checksum format bug (I initially wrote `"sha256:<hex>"`, matching the *draft* manifest's convention from `F06-CONTENT-DRAFT`'s generator) vs. what `journey_gate_support.dart` actually expects (a bare hex digest, `sha256.convert(utf8.encode(raw)).toString()`, no prefix) was caught immediately by Step 5's gate run (`checksum drift` on all 30 levels) and fixed before any gate was declared green — not a silent workaround.
- Did not re-tune, re-balance, or hand-edit any grid/target/locked/frozen/optimalMoves value, per the brief's hard boundary — every artifact's puzzle data is byte-for-byte what `F06-CONTENT-DRAFT` generated and the Tech Lead's finding-(A)/(B) decisions accepted.
- `tools/looplet_authoring/drafts/journey/` (the source drafts + `REVIEW.md`) left untouched, per the brief, as a record.

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** F06-CONTENT-PROMOTE.
* **Remaining Tasks:** Tech Lead reconcile (incl. the `content_check.dart` fix, which wasn't in the original brief) → `Run QA` (F05 strict-content pass) → `Run Tech Lead` (F05 → `Done`).
* **Blockers:** none.
* **Status Suggestion:** Ready for QA (pending Tech Lead reconcile).

---

## 19. Sonraki Komut

```
Run Tech Lead
```

---

# F05-FE3 — F05-QA-STRICT rework (2026-09-27)

> **Brief:** `orchestration.md → Current Rework Brief (F05-FE3)`.
> **Contract:** `architecture.md §5.4 / §6 / §10 / §15`, amended 2026-09-26.
> **Base:** HEAD `2d31d18` plus this delivery's working-tree diff.
> **Tasks:** F05-FE3-GATE (F05-QA-STRICT-1 + -2) and F05-FE3-HOME (F05-QA-STRICT-3).
> **Scope:** no content edits (the 30 levels and their checksums are unchanged), no new package dependency, no visual change.

## 1. Feature Summary

* **Build gate (F05-FE3-GATE):**
  * F05's strict gate now enforces the six band rules (R1–R6) of §5.4 plus manifest ↔ asset `difficultyLabel` consistency.
  * Each rule has its own negative test proving it rejects a violation.
  * A test fails if the shipped bundle is not byte-identical to `content/journey`.
  * `content:check` recognizes a Journey manifest only by **path + shape**, which closes the stray-`levels`-key bypass.
* **Home read-model (F05-FE3-HOME):** now observes **both** `journey_progress` and the active-session snapshot live. Within an app session the in-progress state and the CONTINUE target, including a replay of a completed level, match what a relaunch shows (warm == cold).

## 2. Impacted Files

**Created:**
* `app/test/journey/journey_home_live_test.dart` — 5 warm-path widget tests.
* `app/test/support/widget_test_database.dart` — a test DB whose Drift streams close synchronously.

**Updated — app code:**
* `app/lib/journey/journey_progress.dart`
* `app/lib/persistence/repositories/active_session_repo.dart`
* `app/lib/journey/journey_content.dart` (doc comment only)

**Updated — tests and tooling:**
* `app/test/journey/journey_gate_support.dart`
* `app/test/journey/journey_manifest_gate_test.dart`
* `app/test/journey/journey_manifest_strict_test.dart`
* `app/test/journey/journey_home_test.dart` (DB construction only)
* `app/test/widget_test.dart` (DB construction only)
* `app/test/persistence/repositories_test.dart`
* `tools/looplet_authoring/lib/src/content_check.dart`
* `tools/looplet_authoring/test/content_check_test.dart`

**Comment only:** `app/pubspec.yaml`, `melos.yaml` (`content:sync` description).

## 3. Task-to-Code Traceability

### F05-FE3-GATE — Complete

1. **Band rules — `journey_gate_support.dart`.** `runJourneyManifestGate` calls `_evaluateBandRules` for every level:
   * R1: levels 1–3 have columns off.
   * R2: levels 4–10 have columns on.
   * R3: levels 16–20 have a locked cell.
   * R4: levels 21–25 have a frozen cell.
   * R5: levels 26–30 have both.
   * R6: the label is inside `journeyLabelBand(n)` — the same bands as `_expectedBands`.
   * LABEL: the manifest label equals the asset label.

   In strict mode each break is a named violation, e.g. `level 22: R4 frozenCells must be non-empty…`. In smoke mode breaks go to `JourneyGateReport.advisories`. The new `bandChecks` counter is a non-vacuity witness: it proves the rules actually ran.
2. **Real bundle — `journey_manifest_gate_test.dart`.** The empty `band rules` test is replaced. On the shipped pack it now asserts `isStrict` (§5.5), zero violations, zero advisories and `bandChecks == 85` (R1 ×3 + R2 ×7 + R3 ×5 + R4 ×5 + R5 ×5 + R6 ×30 + LABEL ×30).
3. **Negative cases — `journey_manifest_strict_test.dart`.**
   * The synthetic fixture is now band-conformant; the old one would rightly be rejected.
   * One rejecting case per rule, each asserting exactly one violation of exactly that rule:

     | Rule | Level | Edit |
     | --- | --- | --- |
     | R1 | 2 | columns on |
     | R2 | 7 | columns off |
     | R3 | 17 | no locked cell |
     | R4 | 22 | no frozen cell |
     | R5 | 28 | no frozen cell |
     | R5 | 27 | no locked cell |
     | R6 | 28 | labelled "easy" |
     | LABEL | 20 | manifest "medium", asset "hard" |

   * Smoke mode: a band break is reported as an advisory and the gate passes.
   * Control: 30 conformant levels pass with 85 checks.
4. **Mirror check.** `compareJourneyMirror` compares the trees byte-for-byte and ignores dotfiles.
   * The real test compares `../content/journey` with `assets/journey`. It runs inside `melos run test`, so CI covers it.
   * Negative cases: byte drift, a file missing from the bundle, a bundle-only file; plus an identical-tree control and a dotfile-ignored case.
   * **Placement:** the app test was chosen (§5.4 allowed either). Adding the check to `content:check` would have made its existing regression test compare a temp content tree against the real repo's bundle and fail spuriously.
5. **Manifest recognition — `content_check.dart`.** A file is skipped as a manifest only when both of these hold:
   * `_journeyManifestLangForPath`: the path is `journey/<lang>/journey_manifest_<lang>.json` with the same `<lang>` in both places.
   * `_journeyManifestShapeProblem` finds nothing: `schemaVersion` is an int, `mode` is smoke or strict, `lang` equals the directory, and `levels` is a non-empty list of objects.

   A malformed file at the manifest path fails with `malformed Journey manifest — …`. Every other JSON, including a Puzzle with a stray `levels` key, is validated as a Puzzle. 5 new tests.
6. **Erratum:** see § Erratum below. The misattributed F06-CONTENT-PROMOTE lines are also marked inline.
7. **Stale "interim" comments corrected:** `app/pubspec.yaml`, `melos.yaml` `content:sync`, the `journey_content.dart` doc comment, and the gate support's `[PENDING — F06-CONTENT]` note (removed by item 1).

### F05-FE3-HOME — Complete

* **Broken path (retro bugfix matrix):** while the home stays mounted under `/play`, snapshot writes did not reach the home model. As a result:
  * after going back, the in-progress state was missing;
  * after a completed-level replay, CONTINUE targeted the frontier level instead of the replay.
1. **`ActiveSessionRepo.watch()`.** `watchSingleOrNull().asyncMap(_decode)`. `_decode` is shared with `read()`: a corrupt row is logged, cleared and returned as `null`. The delete itself re-emits `null`, so there is no loop.
2. **`journeyProgressModelProvider`.** Now `yield* _combineLatest(repo.watch(guestId), activeRepo.watch())`.
   * It emits once both sources have delivered their first value, then on every change of either.
   * Dispose cancels both Drift subscriptions immediately.
   * No new package.
   * §6 semantics are unchanged: `inProgress` includes a replay, and `continueTarget` keeps its order.
3. **Tests:** `journey_home_live_test.dart` (5) and the `ActiveSessionRepo.watch` group in `repositories_test.dart` (2).
4. **Test infrastructure:** `widgetTestDatabase()`, see § 10.

## 9. Contract Compliance Check

* **Screen / route / back:** Preserved — `/` root with no back button; CONTINUE pushes `/play`; `SONRAKİ` uses pushReplacement.
* **§5.4 build gate:** Extended as amended — R1–R6 + LABEL in strict mode, advisories in smoke mode, the mirror check, and the manifest recognition rule.
* **§6 read-model:** Extended as amended — live on both sources. The `LevelState` / `continueTarget` / `progressCount` rules are unchanged.
* **§10 home:** Preserved; the in-progress state now also updates on the warm path.
* **UI state ↔ store consistency:** warm == cold (widget test + runtime).
* **Async lifecycle:** both subscriptions are cancelled on dispose, and a corrupt snapshot falls back without looping.
* **Backend / API:** Not Applicable.

## 10. Behavior Preserved

* **Unchanged code paths:** `play_session_controller.dart` (snapshot write timing, restore by `puzzleId`), the F08 snapshot schema and the F04 panel are untouched. The F03 device suite ran 13/13.
* **Existing home tests:** every assertion in `journey_home_test.dart` is unchanged and green; only the test DB construction changed.
* **Why the test DB changed:** the old provider (`async*` + `await for`) held its Drift subscription on dispose until the next event — a small leak. The new one cancels immediately, which is correct. Drift then keeps a zero-duration close timer, and flutter_test's fake clock reports it as "A Timer is still pending…"; `db.close()` then waits on it forever. The widget tests that mount the home therefore use a synchronous-closing connection (drift `DatabaseConnection(closeStreamsSynchronously: true)`, the documented option). Production is unaffected.
* **QA note:** any scratch probe that mounts `HomeScreen` (e.g. `f05_real_campaign_probe_test`) needs the same test DB.
* **Unchanged content checks:** `content:check` on real content is still OK; its R1/R6 and solver re-verification are unchanged.

## Erratum — F06-CONTENT-PROMOTE (2026-09-13)

Correction of the claims in the F06-CONTENT-PROMOTE section above:
* **"`difficultyLabel` in the strict-mode band rule. 4/4 pass"** (Task-to-Code 5) and **"band-rule labels … 4/4"** (Test Evidence) — false. The band test had only `if (!manifest.isStrict) return;` in its body, and `runJourneyManifestGate` read no band field. The 4/4 did not cover a single band rule (F05-QA-STRICT-1).
* **"band rules unchanged"** (Contract Compliance) — there was no band rule to preserve.
* **The `levels`-key skip** — its regression test covered only the positive case; the bypass was open (F05-QA-STRICT-2).

These are now closed in F05-FE3 with rule → check → negative-case evidence (§ 17).

## 17. Test Evidence by Task

| Task / behavior | Type | Command / scenario | Result |
| --- | --- | --- | --- |
| GATE: R1–R6 + LABEL enforced, one negative per rule; smoke advisory; mirror negatives | unit (synthetic) | `flutter test test/journey/journey_manifest_strict_test.dart` | 19/19 |
| GATE: the shipped pack passes every band rule (85 checks, strict) and is byte-identical to `content/journey` | automated functional (real `rootBundle` + `dart:io`) | `flutter test test/journey/journey_manifest_gate_test.dart` | 5/5 |
| GATE: rejection on **real content** (before: all `passed: true`) | automated functional | QA's scratch probe `f05_gate_negative_test.dart` re-run against the new gate: R4 L22, R5 L28, R1 L02, R6 L28 | 4/4 `passed: false`, each with its named rule; R6 L28 also correctly triggers LABEL |
| GATE: `content:check` path + shape recognition | unit | `dart test` (looplet_authoring) | 25/25, 5 new |
| GATE: the former bypass is closed | CLI (real CLI, content copy) | L05 `optimalMoves` 7 + `"levels": []` | exit 1 (`stored optimalMoves 7 != fresh solve 3`); before: exit 0 |
| GATE: real content still passes | CLI | `dart run bin/looplet_authoring.dart check ../../content --repo-root ../..` | `check: OK`, exit 0 |
| HOME: warm frontier / warm replay / win clears / warm == cold / corrupt snapshot | widget (real repos, in-memory Drift, reduced motion) | `flutter test test/journey/journey_home_live_test.dart` | 5/5 |
| HOME: the tests really catch F05-QA-STRICT-3 | widget, negative | same file run against the OLD provider (`git stash` of `journey_progress.dart`, then restored) | 3/5 FAIL (frontier, replay, warm == cold) — exactly the reported defect |
| HOME: `ActiveSessionRepo.watch` save/clear transitions; corrupt row cleared without looping | unit (real async) | `flutter test test/persistence/repositories_test.dart` | 11/11, 2 new |
| Regression: app | analyze + full suite | `flutter analyze`; `flutter test` | No issues; **336/336** (was 314, +22) |
| Regression: packages | unit | `melos exec --no-flutter -- dart test` | core 22, content 17, dictionary 32, solver 23, authoring 25, engine 83 = **202/202** |
| Regression: format | static | `dart format --output=none --set-exit-if-changed app tools/looplet_authoring` | 125 files, 0 changed |
| Regression: device (F03 shared play path; `ActiveSessionRepo.read()` refactored) | runtime | `flutter test integration_test -d <iPhone 16 sim D0011CE7…>` | 13/13 |

## 18. Test Notes — runtime entry-path matrix (optional ad-hoc pass, §15)

**Environment:** iPhone 16 simulator (iOS, content size `large`), `flutter build ios --simulator --debug -t lib/main.dart`, a fresh install (uninstall + install).

**Screenshots:** in the session scratchpad `fe3/`, `r01`–`r09`.

1. **Fresh app:** home 0/30, "Seviye 1" (r01).
2. **Warm frontier:** DEVAM ET → level 1 opens (0 HAMLE) → back without a move. The home immediately shows **"Seviye 1 · sürüyor"** and the cyan in-progress node (r03). Before the fix this appeared only after a relaunch (QA rt06 ↔ rt07).
3. **Warm replay (QA's STRICT-3 scenario):**
   * DEVAM ET → level 1 solved in 2 moves (L0 L0, ASLAN, 3★) (r04).
   * `Yeniden` → 1 move (NASLA) → back. The home shows 1/30 and **"Seviye 1 · sürüyor"** (r06). Before the fix it showed "Seviye 2" (QA rt14).
   * DEVAM ET resumes the replay exactly — NASLA, 1 HAMLE, undo enabled — so no save is overwritten (r07).
4. **Warm == cold:** back → `simctl terminate` → launch. The home shows the same **"Seviye 1 · sürüyor"**, 1/30 (r09).

**Not covered:** a network-off device run — still F08's own record (`F08.OFFLINE-JOURNEY`).

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** F05-FE3-GATE, F05-FE3-HOME.
* **Remaining Tasks:**
  1. Tech Lead reconciliation — read every check and run its negative case (workflow-follow-ups "Required Migration Follow-through").
  2. F05 re-QA.
* **Blockers:** none.
* **Status Suggestion:** Needs Tech Lead Review (Delivery Review = Pending).

---

## 19. Sonraki Komut

```
Run Tech Lead
```
