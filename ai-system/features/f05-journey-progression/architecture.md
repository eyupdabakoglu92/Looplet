# F05 — journey-progression: Architecture (Contract)

> Status: **LOCKED (2026-09-07, Tech Lead — DURUM 3).** `analysis.md` decisions D1–D8 consumed. `[PENDING — UI]` **resolved** by `ui-design.md` (F05-UI, 2026-09-08). **Amended 2026-09-09 (Tech Lead — F05-QA `Rejected` reconcile, DURUM 5):** §5.4 (interim-turn `strict`-branch unit coverage required now), §12 + §15 (AC2 satisfied by construction — test-asserted, no hot-path guard; the explicit locked affordance → `[DEFERRED — F10]`), §15 (`Next Level` needs a trigger→outcome nav test, not just the routing fn), §17 (`[DEFERRED — F10]` level-select surface + affordance + guard). **Amended 2026-09-13 (Tech Lead, on the user's decision — `F06-CONTENT-PROMOTE`):** §5.4 — corrected the levels 1–3 `optimalMoves` claim (`{3,4}` was unachievable for a rows-only 5-letter 5×5 and was never actually gate-enforced; locked to `optimalMoves == 2`, matching the accepted `F06-CONTENT-DRAFT` pack). D1–D8 **unchanged**. `[PENDING — F06-CONTENT]` **resolving this turn** — the user accepted the AI-drafted 30 levels as-is; promotion to `content/journey/tr/` routed to Frontend/Mobile Developer (`F06-CONTENT-PROMOTE`). `[PENDING — F09]` still open. **Amended 2026-09-26 (Tech Lead — F05-QA-STRICT `Rejected` reconcile):**
* §5.4: band-rule enforcement ownership on the shipped bundle, with one rejecting negative case per rule; shipped bundle == `content/` mirror; `content:check` Journey-manifest recognition.
* §6 + §10: the read-model is live on both sources. The one-shot snapshot read was the root cause of F05-QA-STRICT-3. The replay-in-progress semantics are clarified and unchanged.
* §15: QA focus now covers the warm path and the negative cases.

**Amended 2026-09-27 (Tech Lead — F05 closure):** §8 + §6 now state terminal precedence explicitly. When all 30 levels are complete, the terminal variant wins over an in-progress replay; this matches AC9, ui-design and the shipped behaviour (QA note N1). To be revisited in Design Adoption Phase D.

**Amended 2026-09-29 (Tech Lead — Design Adoption Phase D3 activation):** §18 added (Home + app shell, `new-surface`). The user decided N1: surface an in-progress replay after 30 / 30 (§18.3 (2)); it replaces the §8 terminal precedence. **Effective 2026-09-29:** the Product Owner revision PO-REV-2026-09-29-F05-CONTINUE was resynced the same day (feature PRD AC7 / AC9). §10 and §17 are superseded for the visual by §18.

Contract authority for F05. Execution state is in `orchestration.md`.

---

## 1. Purpose

Wire the isolated F03 play session into a **30-level linear campaign**. Define: the **level identity scheme**; the **bundled Journey content pack + manifest + resolver**; the **progression read-model** over F08's `journey_progress`; the **unlock write** on the F04 win path; the **CONTINUE / `Next Level` / terminal** navigation over `/` and `/play`; the **column micro-tutorial** (levels 4–6); the **minimal home surface** replacing the debug `HomeScreen`. F05 changes **no** F03/F04/F06/F08 contract — it consumes them and fills their `[PENDING — F05]` seams.

---

## 2. Authorities & Inputs

| Authority | Role |
| --- | --- |
| `product/product-prd.md` → F05 section + §6.1 F05 row + §5.1/§5.2 + §15 `JourneyProgress` + §41 KPIs | product contract |
| `features/f05-journey-progression/prd.md` | feature scope + AC1–AC14 |
| `features/f05-journey-progression/analysis.md` | Technical Analyst — D1–D8 consumed here |
| `features/f03-puzzle-play-session/architecture.md` → §13 (route/nav) + `PlaySessionArgs` | **consumed** — `/play`, `journeyLevel`, the win moment, the F08 restore path |
| `features/f04-star-rating-and-personal-best/architecture.md` → §7 (panel) + §8 (`Next Level` = `[PENDING — F05]`) | **consumed** — the `onNextLevel` seam + the win-path side-effect pattern |
| `features/f06-.../architecture.md` → `Puzzle` model + `export`/`check` + difficulty labels | **consumed** — the content format + the 30 levels (`F06-CONTENT`) |
| `app/lib/persistence/repositories/journey_progress_repo.dart` + `journey_progress` table (F08) | **consumed** — the unlock persistence (built) |
| `app/lib/persistence/active_session_snapshot.dart` (F08) | **consumed** — CONTINUE resume; **F05 reads only, never writes/extends** |
| `project-authority/platform.md` | Flutter / Riverpod / `go_router`; asset bundling; localization |
| `project-authority/release.md` | `Release Scope` decision (see §13) |
| `design/design-doctrine.md` + `design/premium-ui-rubric.md` | the home / progress / tutorial-overlay quality bar |

---

## 3. Substrate already built (consume, do not rebuild)

* **Unlock persistence (F08):** `journey_progress` table — `highestUnlockedLevel` (int, default 1), `completedLevelsCsv` (text). `JourneyProgressRepo` — `markCompleted(guestId, levelNumber)` (transactional; `highest = max(existing, N+1)`; `completedLevels ∪= {N}`; idempotent for progress), `read(guestId)`, `watch(guestId)` (a `watchSingle` stream), `completedLevels(guestId)`. `journeyProgressRepoProvider`. **No schema change.**
* **Play entry (F03):** route `/play`, `PlaySessionScreen(args: PlaySessionArgs)`, `PlaySessionArgs {PuzzleSource source, int? journeyLevel, String? debugPuzzleId}` — `journeyLevel` defined, currently unused. `app_router.dart` `Routes.play` reads `state.extra as PlaySessionArgs`.
* **Content-resolution seam (F03):** `playSessionSetupProvider = FutureProvider.family<PlaySessionSetup, PlaySessionArgs>` — handles `debugPuzzleId`, `throw UnsupportedError` for other sources. **F05 fills the `journeyLevel != null` branch.**
* **Completion → Next Level seam (F04):** `CompletionPanel({..., VoidCallback? onNextLevel})` — `null` in F04 scope → disabled ghost pill. `play_session_screen.dart` builds the panel. **F05 supplies `onNextLevel`.**
* **Win-path side-effect pattern (F04):** `PlaySessionController` takes optional `personalBestRepo` + `guestId`; on win, `_resolvePersonalBest` does prior-read → `recordCompletion` → read-back → build `CompletionResult`, **fire-and-forget with a caught failure**, never blocking the panel. **F05 mirrors this for the unlock write (D3).**
* **Engine config (F08):** `toEngineConfig(Puzzle)` in `app/lib/content/puzzle_engine_config.dart` — consumed by `PlaySessionController`.
* **Content format (F06):** `Puzzle` / `Puzzle.fromJson` (engine-free, `looplet_content`); `optimalMoves` guaranteed by `export`/`check`; `difficultyLabel ∈ {easy, medium, hard, expert}`; `columnMovesEnabled`, `lockedCells`, `frozenCells` are content properties.
* **`kv` table (F08):** generic `key` TEXT / `valueJson` TEXT. Already holds `active_session` + `store_meta`. **F05 adds one key (D2).**
* **Language (F08/F10):** `SettingsRepo.read(guestId).language` — default `'tr'`.

---

## 4. Level Identity [LOCKED — D1]

* **Journey level ⇄ id.** A Journey level `N ∈ 1..30` has `Puzzle.id == 'journey-<lang>-<NN>'` (zero-padded two digits, e.g. `journey-tr-07`) and `Puzzle.journeyLevelNumber == N`.
* **This is a HARD CONSTRAINT on `F06-CONTENT`** — every authored Journey artifact + the manifest MUST use exactly this scheme. `Puzzle.id` is the durable key for:
  * F04's `personal_best.levelId` (`levelId == puzzle.id`);
  * F03's restore (`PlaySessionController._tryRestore` fires only when `snapshot.puzzleId == puzzle.id`).
  Changing a shipped level's id orphans that player's best + any in-progress snapshot — permitted only pre-launch.
* **Level-number helpers** (F05 code): `journeyLevelId(int n, String lang) → 'journey-<lang>-<NN>'` and `parseJourneyLevel(String puzzleId) → int?` (returns `null` for a non-`journey-<lang>-NN` id — e.g. a debug/daily id). Single source of truth for the mapping.
* **The F08 active-session snapshot is NOT extended** — the in-progress Journey level is derived as `parseJourneyLevel(snapshot.puzzleId)` when `snapshot.puzzleSource == journey && snapshot.status == inProgress`.

---

## 5. Bundled Content + Manifest + Resolver [LOCKED — D5, D6, D7]

### 5.1 Asset home [D5]

* **Journey level artifacts + manifest are bundled app assets**, mirrored from the F06 `export` output:
  * source of truth (authored, checked-in): `content/journey/<lang>/journey-<lang>-NN.json` + `content/journey/<lang>/journey_manifest_<lang>.json`;
  * bundled into the app: `app/assets/journey/<lang>/…` (registered in `app/pubspec.yaml` `flutter: assets:`), kept in sync by a **`melos` mirror script** (`melos run content:sync` — copies `content/journey/**` → `app/assets/journey/**`) run in CI before `build`.
* **`looplet_content` stays pure Dart** — the loader lives in the `app` layer (reads `rootBundle`, calls `Puzzle.fromJson`).

### 5.2 Manifest schema

```
journey_manifest_<lang>.json
{
  "schemaVersion": 1,
  "contentVersion": "<string>",
  "lang": "tr",
  "mode": "smoke" | "strict",          // "smoke" while F06-CONTENT is incomplete
  "levels": [
    { "n": 1, "id": "journey-tr-01", "asset": "journey/tr/journey-tr-01.json",
      "difficultyLabel": "easy", "checksum": "<sha256 of the asset bytes>" },
    …  // n contiguous from 1; 30 entries required when mode == "strict"
  ]
}
```

### 5.3 Resolver

Fills `playSessionSetupProvider`'s `journeyLevel != null` branch (or a dedicated `journeyContentRepoProvider` the branch delegates to):

1. resolve the active language — `SettingsRepo.read(guestId).language`, default `'tr'`;
2. load + cache `journey_manifest_<lang>.json` (one parse per session; a `FutureProvider` or an in-memory map);
3. look up `levels` where `n == journeyLevel`; **absent → throw `JourneyContentException`** (a typed failure);
4. `rootBundle.loadString(<asset>)` → `jsonDecode` → `Puzzle.fromJson` (throws `PuzzleFormatException` on a malformed artifact);
5. assert `puzzle.id == manifest.id`, `puzzle.journeyLevelNumber == n`; verify the `checksum` (optional but recommended);
6. return `PlaySessionSetup(puzzle: puzzle, validator: <wordValidatorProvider.future>)`.

* **Corrupt / missing asset or manifest entry** → the resolver future errors → F03's **existing load-error state** (`_LoadErrorBody`, `Geri` → `/`). The rest of the Journey still resolves (per-level failure, not a campaign crash).
* **Caching:** per `(lang, n)`; 30 small artifacts; no eviction.

### 5.4 Content-manifest build gate [D6]

A new check — **`melos run content:check` extended** (F06's `check` / a `flutter test` asset test in `app`). Owner: **Frontend (F05-FE.GATE)** — analogous to F06's `content:check`, no DevOps.

* Always (both modes): the manifest parses, `schemaVersion` known, `levels[n]` contiguous from 1, each `asset` resolves + `Puzzle.fromJson` succeeds, `puzzle.id == manifest.id == 'journey-<lang>-<NN>'`, `journeyLevelNumber == n`, `optimalMoves >= 1`, `checksum` matches.
* **Band rules (structural):** `n ∈ 1..3` ⇒ `columnMovesEnabled == false`; `n ∈ 4..10` ⇒ `columnMovesEnabled == true`; `n ∈ 16..20` ⇒ `lockedCells` non-empty; `n ∈ 21..25` ⇒ `frozenCells` non-empty; `n ∈ 26..30` ⇒ both non-empty. **Gate-enforced by `tools/looplet_authoring check` / `content:check`** (`_expectedBands` in `content_check.dart`): `columnMovesEnabled == false` for 1–3, and `difficultyLabel` inside the level's expected band (1–6 → {easy, medium}; 7–15 → {easy, medium, hard}; 16–25 → {medium, hard, expert}; 26–30 → {hard, expert}). (Levels 11–15 "temporary-displacement weight" is a difficulty-score property — validated by the `difficultyLabel` + `F06-CONTENT` playtest, not a hard structural check.)
* **Levels 1–3 `optimalMoves` — corrected 2026-09-13 (Tech Lead, on the user's decision, F06-CONTENT-DRAFT investigation).** Earlier text here (and in `content-authoring-brief.md §4` / `prd.md` / `product-prd.md §20`'s sourcing AC) called for `optimalMoves ∈ {3,4}` on levels 1–3. **That is unachievable and was never actually gate-enforced.** A rows-only 5×5 with a 5-letter target has exactly one solve shape — a single-row cyclic rotation — so the provable minimum is `min(k, 5-k) ≤ 2` for any k; `optimalMoves` can only be 1 or 2, never 3 or 4. Neither `tools/looplet_authoring check` nor F05's own manifest gate (`journey_gate_support.dart` — "band rules deferred to `F06-CONTENT`") ever checked the `{3,4}` claim; it was aspirational text with no code behind it. **Locked decision: levels 1–3 ship at `optimalMoves == 2`** (the deliberate tutorial on-ramp — `min(2,3)=2`, the least-trivial value reachable). No gate change needed (nothing enforced the old claim to begin with); this is a documentation correction, not a contract behavior change. `content-authoring-brief.md §4` and `prd.md` amended to match this turn.
* **`mode == "smoke"`** (interim): the gate asserts consistency of whatever levels are present + logs the shortfall to `< 30`; **does not fail CI**.
* **`mode == "strict"`** (when `F06-CONTENT` lands): `levels.length == 30` **required**; any violation **fails CI**. Flipping the mode is a one-field manifest edit + the gate reads it.
* **Interim-turn coverage [amended 2026-09-09, F05-QA reconcile]:** even while the shipped manifest is `mode == "smoke"`, the gate's **`strict` branch itself is a Mode/Configuration variant that MUST carry executed coverage now** — a unit test feeding a synthetic `mode: "strict"` manifest with `< 30` levels (and one with an unresolvable `asset`) and asserting the gate **rejects** it. Only the *structural band rules* legitimately wait for `F06-CONTENT` (they need the real 30 authored levels); the bare `levels.length == 30` + asset-resolution checks do not.
* **Band-rule enforcement ownership [amended 2026-09-26, F05-QA-STRICT reconcile].** `F06-CONTENT` has been delivered, so the band rules are now due.
  * **Authority:** F05's own build gate (`runJourneyManifestGate`, run by `journey_manifest_gate_test.dart` inside `melos run test` / `content:journey`) is the authority for all six band rules, applied to the **shipped bundle** (`app/assets/journey/<lang>/`).
  * **The six rules:** R1–R5 are the structural rules above. R6 is `difficultyLabel` inside the level's band, using the same bands as `_expectedBands`.
  * **Label consistency:** the manifest entry's `difficultyLabel` must equal the asset's `difficultyLabel`.
  * **Modes:** in `mode:"strict"` every violation is a named gate violation and fails CI. In `mode:"smoke"` violations are logged as advisory.
  * **Evidence per rule:** each rule needs (a) an executable assertion and (b) a synthetic negative case asserting the gate rejects that specific violation (rule → check → negative example). A test body that asserts nothing is not coverage.
  * **`content:check`:** keeps its existing R1/R6 checks and solver re-verification on `content/` as defence in depth; it is not the band-rule authority.
  * **Out of scope:** levels 1–3 `optimalMoves == 2` remains a documented content decision, not a gate rule (unchanged).
* **Shipped bundle == verified source [amended 2026-09-26].** CI fails if `app/assets/journey/<lang>/` is not byte-identical to `content/journey/<lang>/` (the `content:sync` mirror). This makes `content:check`'s solver re-verification, which runs on `content/`, cover what actually ships. Placement is the implementer's choice (`content:check --repo-root` or an app test); a negative case is required.
* **Journey-manifest recognition in `content:check` [amended 2026-09-26].** A file is skipped as a Journey manifest only if **both** hold:
  * it is `content/journey/<lang>/journey_manifest_<lang>.json`;
  * it has the manifest shape (`schemaVersion`, `mode`, `lang`, and a `levels` list).

  Any other JSON carrying a `levels` key is validated as a `Puzzle` artifact and fails if it is not one. A malformed manifest also fails. Negative cases are required. (This closes F05-QA-STRICT-2: a stray `"levels": []` used to skip all puzzle validation.)

### 5.5 Interim content [D7]

Until `F06-CONTENT` delivers, F05 builds + QAs against a checked-in **`content/journey/tr/journey_manifest_tr.json` with `mode: "smoke"`** mapping the F06 smoke set to levels 1–5:

| n | id | source smoke puzzle | exercises |
| --- | --- | --- | --- |
| 1 | `journey-tr-01` | `content/smoke/tr/level01.json` (`smoke-tr-01`, opt 1, rows-only) | levels 1–3 band, unlock 1→2 |
| 2 | `journey-tr-02` | `smoke-tr-02` (opt 2, rows-only) | unlock 2→3 |
| 3 | `journey-tr-03` | `smoke-tr-04` (opt 1) | unlock 3→4 |
| 4 | `journey-tr-04` | `smoke-tr-05` (locked cell) | **4–6 band → the column micro-tutorial trigger**; locked-tile render |
| 5 | `journey-tr-05` | `smoke-tr-06` (frozen cell) | 4–6 band; frozen-tile render; `Next Level` past the last available level → terminal |

The 5 interim artifacts are **copies of the smoke JSON re-`id`'d to `journey-tr-0N`** (a `melos`/script step, or hand-authored copies committed under `content/journey/tr/`). `journeyLevelNumber` set to `n`. This lets F05 build + QA exercise: the resolver, unlock idempotency, CONTINUE resume, the 4–6 tutorial gate (levels 4–5), `Next Level` → terminal (from level 5, the last available). **F05 → `Done` requires the real 30 (`mode: "strict"`, gate green).**

---

## 6. Progression Read-Model [LOCKED]

Derived from `journey_progress` + the persisted active-session snapshot, **both observed live**. No new storage.

*Amended 2026-09-26 (F05-QA-STRICT reconcile):* this was a one-shot snapshot read. Because the home stays mounted under the pushed `/play` route, the one-shot read left the in-progress state and the CONTINUE target stale for the rest of the app session.

* `LevelState(n)` for `n ∈ 1..30`:
  * `locked` ⇔ `n > highestUnlockedLevel`;
  * `completed` ⇔ `n ∈ completedLevels`;
  * `unlockedIncomplete` ⇔ `n <= highestUnlockedLevel && n ∉ completedLevels`;
  * `inProgress` ⇔ an F08 snapshot exists with `puzzleSource == journey && status == inProgress && parseJourneyLevel(puzzleId) == n` (at most one).
    * This **includes a replay of an already-completed level**: for that level the in-progress state takes precedence over `completed`, and `progressCount` is unaffected.
    * CONTINUE therefore resumes the replay (product AC7: "Given an in-progress level … that level resumes") — also after all 30 levels are complete *[amended 2026-09-29, PO-REV-2026-09-29-F05-CONTINUE; the 2026-09-27 terminal-precedence exception lapsed, §8 / §18.3 (2)]*.
    * These semantics are unchanged; clarified 2026-09-26.
* `currentLevel` (for CONTINUE) = the `inProgress` level if any, else `min({n : unlockedIncomplete})`, else `null` (all 30 done → terminal).
* `progressCount` = `|completedLevels ∩ {1..30}|` (clamp — ignore strays).
* Exposed as a Riverpod provider that **re-derives whenever either source changes** [amended 2026-09-26]:
  * `JourneyProgressRepo.watch(guestId)` — win commits;
  * the active-session snapshot — session start, move, completion and clear; for example a Drift watch over its stored row.
* The same persisted state must yield the same model whether the app was just relaunched (cold) or the home stayed mounted (warm).
* No new package dependency.

**Consumers must handle all four `LevelState` values** (home tiles, the `Next Level` gate, CONTINUE).

---

## 7. Unlock Write on the Win Path [LOCKED — D3]

* `PlaySessionController` gains **optional ctor params** `journeyProgressRepo` (F08's `JourneyProgressRepo`) + `journeyLevel` (`int?`) — mirroring F04's `personalBestRepo` + `guestId`. `_LoadedPlaySession._init()` (F03) passes `widget.args.journeyLevel` in (an additive line — no F03 contract change).
* On win, in the existing win side-effect path (a sibling of `_resolvePersonalBest`, e.g. `_resolveJourneyProgress`): if `source == journey && journeyProgressRepo != null && guestId != null && journeyLevel != null` → `await journeyProgressRepo.markCompleted(guestId, journeyLevel)`, **fire-and-forget with a caught failure** (`try/catch` → `debugPrint('journey: unlock_persist_failed (non-fatal) — $error')`), **ordered after** the `personal_best` write is initiated (both are independent local writes; the fixed order only aids test assertions). **Never blocks the panel.**
* **Idempotent** — `markCompleted` is a progress no-op on re-completion (Retry → re-solve). F05 adds no dedup.
* A caught failure → the unlock is retried on the next completion of that level (or lost until then) — the same posture as F03's `_persist` / F04's `_resolvePersonalBest`. This is the **shared storage-full test-debt class** (F03 QA note 3 / F08 AC7 / F04 N3) — a fault-injection test is a tracked follow-on, not an F05 gate.

---

## 8. CONTINUE / `Next Level` / Terminal Navigation [LOCKED — D4]

* **Routes:** reuse `/` (home) and `/play`. **No new route.** The terminal "all complete" state and the tutorial overlay are **in-screen states**.
* **CONTINUE** (home primary CTA): resolve `currentLevel` (§6). If `null` → render the terminal home variant in place. Else `context.push('/play', extra: PlaySessionArgs(source: journey, journeyLevel: currentLevel))`.
  * **Terminal precedence [amended 2026-09-27, F05 closure — QA note N1].** Once all 30 levels are complete (`progressCount == 30`), the home renders the terminal variant (AC9; ui-design: `TEKRAR OYNA` → level 1), even when a replay of a completed level is in progress.
    * That replay is not surfaced; starting another level supersedes its save.
    * This is an accepted edge with low impact: it only affects post-completion personal-best replays. It is the shipped and QA-verified behaviour.
    * To be revisited when the home is redesigned in Design Adoption Phase D.
    * **[Superseded, effective 2026-09-29 — §18.3 (2), the user's N1 decision, PO-REV-2026-09-29-F05-CONTINUE resynced]:** an in-progress replay is surfaced; the terminal variant ⇔ `currentLevel == null` (`continueTarget == null`), which is the plain rule of the first bullet above. The paragraph above is kept as the record of the shipped behaviour until F05-FE-D3 replaces it.
* **`Next Level`** (fills F04's `CompletionPanel.onNextLevel`): let `n = <this session's journeyLevel>`. If `n != null && n < 30 && manifest has n+1` → `context.pushReplacement('/play', extra: PlaySessionArgs(source: journey, journeyLevel: n + 1))`. Else → `context.go('/')` (home → terminal variant). **`pushReplacement`** so the back stack never accumulates `/play` frames.
* **Back:** unchanged from F03 — chevron hidden in `won`; `Close` / system / gesture back → `_popToCaller` *[amended 2026-09-28, F03 §20.3 (7): no `Close`; the result's back button and system / gesture back]*, which **must resolve to `/`** (add a `context.go('/')` fallback when `!canPop`, e.g. a deep-link entry). From any Journey level, back lands on `/`.
* **Route graph:** `/` ⇄ `/play` only. Every `/play` exit → `/`. No 30-deep stack. No wrong-route, no empty stack.
* **`Next Level` on the last available interim level (5) or level 30** → terminal state (a valid action, never a dead no-op).

---

## 9. Column Micro-Tutorial (levels 4–6) [LOCKED — D2 for storage; `[PENDING — UI]` for the overlay]

* **Trigger:** on `/play` load (after content resolves), if `journeyLevel ∈ {4,5,6}` **and** the ack flag is false → show the overlay.
* **Behaviour:** an **action-gated** coach-mark over the F03 board — the player performs a column shift to dismiss. Persists `ack = true` **only** on the gated action completing (AC11). Distinct from F09 onboarding.
* **Re-show (AC11):** quitting before the gated action leaves `ack = false` → the overlay re-shows on the next entry to any level in 4–6.
* **Persisted flag [D2]:** a **`kv` row** — `key = 'journey_col_tutorial_ack'`, `valueJson = '{"ack": true, "atUtcMs": <int>}'`. **No F08 schema change.** A tiny `JourneyTutorialRepo` (or a generic `kv` accessor) reads/writes it. Single-guest today → a bare key; documented in the `kv` key registry (§14).
* **Visual design** of the overlay (layout, coach-mark, gating affordance, chrome parity with F03 Direction A) is **`[PENDING — UI]`**.
  * **[Amended 2026-09-27 — Design Adoption Phase D1]** Visual authority moves to F03 `architecture.md` §19 and the F03 D1 handoff (Loop Glass, render S-07). The overlay is re-skinned in the F03 reopen as a cross-feature item:
    * the hint pill sits above the HUD, and undo and restart stay usable;
    * the ghost hides while the player drags.
  * The behaviour above is unchanged, and F05 stays Done.
  * The home (§10) is re-composed in Phase D3, with F05 as the carrier.

---

## 10. Home Surface [LOCKED contract; `[PENDING — UI]` visual]

> **[Amended 2026-09-29 — Design Adoption Phase D3]** The visual, the wordmark (`Looplet`), the progress indicator (the loop track) and the terminal variant are re-specified in §18. The content rules below (AC10, live binding, no back affordance, not the F10 menu) are unchanged.

* Replaces `app/lib/home_screen.dart` (currently a debug `Wrap` of `smoke-tr-*` buttons). The debug buttons move behind `kDebugMode` or are removed (`[IMPL — Frontend]`).
* **Content (AC10):** LOOPLET wordmark; **CONTINUE** (primary CTA — §8); a **journey-progress indicator** ("`progressCount` / 30" + a completed/unlocked visual), bound to `JourneyProgressRepo.watch` (live-updates when a win commits, even after the player pops back to `/`) **and** to the active-session snapshot (§6). The in-progress state and the CONTINUE target update as soon as the player pops back to `/` [amended 2026-09-26].
* **Terminal variant ("all 30 complete"):** a distinct home state — a completion message; CONTINUE hidden or repurposed ("Replay a level" — **UI Designer's call**, Open item). No crash, no dead button.
* **Chrome:** `/` is the app root — **no back affordance**. Not the F10 menu (no DAILY, no Settings icon, no level-select map — F10 re-homes this surface).
* **Strings:** F05 UI strings follow F03's interim per-language table pattern (`PlayStrings`-style). `gen_l10n` stays `[DEFERRED — F10-or-earlier]` (F03's clarification).

---

## 11. F09 Seam [LOCKED — D8]

* F09 (`Not Started`) owns the pre-Level-1 onboarding. F05 ships the branch: `if (!onboardingComplete) → <[PENDING — F09] route into F09>  else → currentLevel resolution`, with `onboardingComplete` **hard-wired `true`** and a `// [PENDING — F09]` marker.
* Interim behaviour: a brand-new player's CONTINUE → Level 1 directly.
* F09 later supplies the real `onboardingComplete` signal (its own `kv` flag / `settings` column) and the route target.

---

## 12. Validation Responsibility [LOCKED]

* **F05:** the unlock rule (AC1/AC2/AC13 — stars never gate, no re-lock); the `LevelState` derivation; CONTINUE / `Next Level` / terminal resolution (AC7/AC8/AC9/AC12); the progress-indicator accuracy (AC10); the 4–6 micro-tutorial gate + re-show + ack-persist (AC4/AC11); the bundled-content resolver + corrupt/missing-asset degradation; offline load (AC14); the content-manifest build gate.
* **AC2 clarification [amended 2026-09-09, F05-QA reconcile]:** AC2's *"no navigation to a locked level"* is satisfied **by construction** — the home's CONTINUE resolves only to `currentLevel` (§6, always `≤ highestUnlockedLevel` or the in-progress level); `Next Level` advances only to an `N+1` the player just earned; there is no deep-link route; `/play` with no `extra` falls back to a debug id. F05 validation is a test asserting **no F05 navigation path emits a `locked` `LevelState`** (across new / mid / in-progress / terminal + the last-available boundary) — not a runtime guard on the hot path. AC2's *"clear locked affordance"* half needs a level-select surface that is **explicitly out of MVP** (`prd.md §5`, `ui-design.md §10` — "no level-select map") → `[DEFERRED — F10]` (see §17).
* **F08 `JourneyProgressRepo`:** the transactional idempotent unlock write.
* **F06 / `F06-CONTENT`:** the 30 levels exist, follow the id scheme (§4), land the curve bands (AC3/AC5/AC6), each carry `optimalMoves`.
* **F03:** the play session + the F08 restore path. **F04:** the completion panel + the `onNextLevel` seam + the win-path side-effect pattern.

---

## 13. Release / Deployment Impact [LOCKED — Tech Lead decision]

* **`Release Scope` = `none`.** F05 adds **no** deploy / container / environment / server change. The Journey content pack is **bundled in the app binary** (same posture as F01's dictionary assets + F06's smoke content, both `Release Scope = none`). The one CI addition — the content-manifest build gate + the `content:sync` mirror step — is **directly analogous to F06's `content:check`** and is a **Frontend/tooling task (F05-FE.GATE), not a DevOps turn.** **No `DevOps/Release Engineer` for F05.**
* **The first app-build distribution** (TestFlight / Play internal — needed for the Level 5 Reach / D1 / D7 KPIs, and where F03's 3-item manual device confirmation + F04's N4 reveal-feel device smoke land) is a **separate, deferred portfolio-level gate** ("first-app-distribution"), **parked** alongside F08's Firebase deploy: it needs an Apple Developer Program membership (the user has none — deferred) + Android Play Integrity SHA-256 (in the parked `F08-DEVOPS`). It is **NOT an F05 `Done` blocker**. F05 QA does `automated functional` (mandatory) + an optional ad-hoc device pass on the connected iPhone (no formal distribution).
* CI code gates (`format:check` / `analyze` / `test` / `content:check` (extended) / `build:app` / `build ios`) still apply. Rollback for the content pack = ship the previous binary (no server component).

---

## 14. `kv` Key Registry [LOCKED — housekeeping]

The shared F08 `kv` table now holds:

| key | writer | shape | notes |
| --- | --- | --- | --- |
| `store_meta` | F08 bootstrap | `{"guestId":…, "createdAtUtcMs":…}` | seed metadata |
| `active_session` | F03 (`ActiveSessionRepo`) | the frozen `ActiveSessionSnapshot` JSON | one row; F05 reads only |
| `journey_col_tutorial_ack` | **F05** (`JourneyTutorialRepo`) | `{"ack": true, "atUtcMs": <int>}` | absence ⇔ not acknowledged |

F05-FE adds `journey_col_tutorial_ack` here; any future `kv` key is added to this table (documented so keys don't collide).

---

## 15. QA Focus [LOCKED]

* **Progression (`automated functional`):** unlock N→N+1 at 1★ **and** 3★ (AC1/AC13 — the unlock write is star-agnostic, so an end-to-end 1★ solve is a *bonus*, not a gate; the required evidence is that `_resolveJourneyUnlock` fires irrespective of the star result and the CTA weighting enables `Next Level` at 1–2★); **AC2 — no F05 navigation path resolves to a `locked` level** (asserted across new / mid / in-progress / terminal + the last-available boundary; see §12 — the explicit locked *affordance* is `[DEFERRED — F10]`, no direct-entry guard on the hot path); replay a completed level → no re-lock / no progress change; `markCompleted` idempotency against the **real F08 `JourneyProgressRepo`** + an in-memory DB.
* **CONTINUE / resume:** in-progress → resumes at the exact saved state (kill/relaunch — via the F08 restore path; an ad-hoc device pass folds into the eventual first-app-distribution smoke) (AC7); no in-progress → lowest unlocked incomplete (AC8); all 30 and no session in progress → terminal, no crash (AC9); all 30 with a replay in progress → CONTINUE resumes it, warm and cold (AC7) *[amended 2026-09-29, PO-REV-2026-09-29-F05-CONTINUE]*.
* **Warm path (`automated functional`) [amended 2026-09-26, F05-QA-STRICT-3].** With the home mounted, `/play` may write, change or clear the active-session snapshot. Cases:
  * a frontier level is started;
  * a completed level is replayed;
  * a level is won.

  On return to `/`, the home must show the same in-progress caption, `Semantics` and CONTINUE target as the cold (relaunch) derivation. Widget-test at least the frontier and replay variants, and the win clearing the in-progress state.
* **`Next Level` (`automated functional`) [emphasised 2026-09-09, F05-QA reconcile]:** the evidence MUST be a **trigger → outcome** test — tapping the rendered `SONRAKİ` CTA on a real `/play` `CompletionPanel` and observing navigation: panel of N (N<30, `n+1` present) → level N+1's `/play` via `pushReplacement` (the back stack does **not** grow); panel of the last available level / level 30 → `context.go('/')` → the terminal home. Unit coverage of the pure `nextJourneyLevel(n, manifestLevelCount)` routing fn alone does **not** satisfy AC12 (this was the F05-QA-1 blocking gap).
* **Micro-tutorial (`automated functional`):** shows on first 4–6 entry (AC4); re-shows after a simulated force-quit (ack flag still false) until the gated action (AC11); not again after ack; not shown for 1–3 or 7+.
* **Content resolver (`automated functional`):** resolve by number → the right `Puzzle`; corrupt/missing asset or manifest entry → the F03 load-error state, the rest of the Journey playable; offline (no network) → loads from the bundle (AC14).
* **Build gate:** a manifest with `mode:"strict"` + `< 30` / a missing asset / a band-rule violation → the gate **fails CI**; `mode:"smoke"` → logs + passes.
  * *Amended 2026-09-26:* each of R1–R6 and the manifest-label check needs its own rejecting negative case (§5.4).
  * A shipped bundle that differs from `content/` fails.
  * `content:check` rejects a `Puzzle` artifact carrying a stray `levels` key instead of skipping it.
* **`ui-design.md` alignment:** the home CONTINUE/progress/terminal surface + the 4–6 micro-tutorial overlay vs `ui-design.md`; chrome parity with F03 Direction A; `premium-ui-rubric.md` fail conditions absent (≥ 90).
* **Regression:** the F03 play + F04 completion suites stay green; F04's `CompletionPanel` now-enabled `onNextLevel` path does not break its disabled-state tests; F04's per-outcome CTA-weighting tweak (§16) behaves.
* **Evidence class:** `automated functional` **mandatory**. `runtime` (device) is **not** an F05 gate — it folds into the deferred first-app-distribution smoke; an optional ad-hoc iPhone pass may be recorded.
* **Not `source-only`.** Security compliance N/A (single actor, local-only `journey_progress` + one `kv` flag, no auth, no endpoint) — justify in the QA scope line.

---

## 16. F04 `Next Level` CTA-Weighting Follow-on [LOCKED — in F05-UI + F05-FE scope]

F04's forward note (`f04 frontend.md §4`): once `Next Level` is live, revisit the Retry-vs-Next-Level primary/secondary weighting **per outcome**. This is F05's to close (it is exactly when `Next Level` goes live):

* **`ui-design.md` (F05-UI):** define the rule — proposal: `isPerfect` (3★) → **`Next Level` primary**, `Retry` secondary; sub-optimal (1–2★) → **`Retry` primary**, `Next Level` secondary. Applies to the existing `CompletionPanel`.
* **`completion_panel.dart` (F05-FE):** an **additive** tweak — the panel picks the primary CTA from `CompletionResult.isPerfect` (the panel already has it). No F04 contract change; the 7 AC7 elements + the six variants are unchanged.
* On a Journey **level 30** completion (or the last available interim level): `Next Level` still renders but routes to the terminal state (§8) — the weighting rule still applies to the button that's there.

---

## 17. Open Items

* `[PENDING — UI]` (F05-UI → `ui-design.md`): the minimal home surface (LOOPLET wordmark + CONTINUE + the "`N` / 30" progress indicator + the "all 30 complete" terminal variant — CONTINUE hidden vs "Replay a level"); the **levels 4–6 column micro-tutorial overlay** (action-gated coach-mark over the F03 board, re-shows until acknowledged); the F04 `CompletionPanel` **per-outcome CTA-weighting rule** (§16); chrome / atmosphere parity with F03's `ui-design.md` Direction A; `premium-ui-rubric.md` ≥ 90.
* `[PENDING — F06-CONTENT]` (**human / content deliverable — no canonical role; owner: Level Designer / user**): the 30 authored Journey levels + `journey_manifest_tr.json` with `mode: "strict"`, following the §4 id scheme + the §5.4 band rules, run through F06's `export`/`check`, committed under `content/journey/tr/`. **Hard prerequisite for F05 `Done`** — F05 code + QA proceed against the §5.5 interim (`mode: "smoke"`). Tracked in `features/f06-.../orchestration.md → Open Tasks → Content` and surfaced to the user this turn as an explicit decision (author now / defer F05 `Done`).
* `[PENDING — F09]` — the pre-Level-1 onboarding hand-off (§11). F05 ships the seam with `onboardingComplete` hard-`true`.
* `[DEFERRED — F10]` — the full menu re-homes F05's minimal home surface; F10 owns `settings` + multi-language + the language-switch-mid-progress story. **Also `[DEFERRED — F10]` (recorded 2026-09-09, F05-QA reconcile):** a **level-select surface** (the grid of level tiles) + AC2's **explicit locked affordance** + a **resolver guard** that rejects a direct `PlaySessionArgs(journeyLevel:)` request for an un-unlocked level. MVP has **no** navigation path that can produce a locked-level request (`prd.md §5` / `ui-design.md §10` — "no level-select map"; the home resolves only to `currentLevel`, `Next Level` only to an earned `N+1`, no deep links) → F05 satisfies AC2's "no navigation" clause by construction (test-asserted, §15). F10 (or a future deep-link feature) owns the affordance + the guard when a surface that can request an arbitrary level first exists.
* `[DEFERRED — F11/F12]` — audio/haptics on unlock; `level_started` / `level_completed` analytics (with the level number) are F12 seams.
* `[DEFERRED — first-app-distribution]` — TestFlight / Play internal + the folded-in F03/F04 device smokes; parked alongside F08's Firebase deploy pending the user's paid-account decision. **Not an F05 gate.**

---

## 18. Design Adoption Phase D3 — Home + app shell [LOCKED 2026-09-29; visual-gate rulings §18.7]

> **Added by:** the Tech Lead on 2026-09-29, at the D3 activation right after the D2 closure (F03 `architecture.md` §20.11). It reopens F05 as visual rework under rework control. F05 is the carrier (audit C-2). The app shell — native launch, the Flutter splash and the F08 `StoreErrorScreen` — is a cross-feature item in the same reopen (C-6, C-7).
>
> **Authority:**
> * `project-authority/design-foundation.md` — Direction C "Loop Glass"; the user's decisions in §18, in particular 4 (future-scope items stay out), 5 (wordmark `Looplet`) and 6 (reference copy as proposal), and consequences 4–5.
> * `features/f00-design-foundation/ui-design.md` — §6 Home layout, §7 components (glass card, loop track, primary CTA with glow, wordmark), §8 state design (load error / recovery pattern), §10 visual direction, §13 accessibility.
> * The selected-source renders `S-06b-home-today.png` (the shipped-scope composition) and `S-06-home-design.png` (with future-scope items — **not** to be built); `S-91-components.png`.
> * The audit: `conformance-audit.md` §2, §3, §7, §9 items 3, 5, 10, 11, §10 renders 19–26, §11 matrix rows Shell / Home; rulings C-1, C-6, C-7, C-8, C-9.
> * The D1 and D2 surfaces (F03 §19, §20): Home is the caller of `/play` and the landing of every `/play` exit.

### 18.1 User-visible symptom

Home, the first screen of every launch, still has the pre-Foundation look: an uppercase `LOOPLET`, a 30-tick amber ring with the count at its centre, an amber `DEVAM ET` pill, and the system font. Since D1 and D2 it opens into a Loop Glass Play and returns from a Loop Glass result, so the hybrid period (C-8) is most visible here.

The shell carries three player-visible defects:
* **A-4:** a white native launch frame before the dark app on iOS, and on Android in light mode;
* **A-3:** an English error screen that prints the raw exception (`SqliteException(26) …`) to the player;
* **A-2 (home):** at AX5 the wordmark breaks as "LOOPL / ET", `TAMAMLANDI` breaks mid-word, the CTA label is cut, and the debug build reports a 10 px bottom overflow (F03-QA-D2R N5).

### 18.2 Scope

* **Affected journey:** cold start (native launch → Flutter splash → Home, or → the store-error screen) → Home → CONTINUE → `/play` → back / Next to Home.
* **Surfaces and states:**
  * **Home (`/`, F05 §10):**
    * new player (0 / 30);
    * mid, no session in progress;
    * in progress (the frontier level);
    * a replay of a completed level in progress before 30 / 30;
    * terminal 30 / 30 with no session in progress;
    * terminal 30 / 30 with a replay in progress (§18.3 (2));
    * the model not yet loaded (first frame);
    * the pressed CTA;
    * AX5.
  * **Flutter splash** (`_SplashScreen`, `app_router.dart`).
  * **Store-error screen** (`StoreErrorScreen`, F08 AC9 / F08 App Init Sequence step 1): the bootstrap failure and the migration failure, both with Retry.
  * **Native launch:** the iOS `LaunchScreen.storyboard`; Android `drawable/` and `drawable-v21/launch_background.xml` and `values/` / `values-night/` `styles.xml` (`LaunchTheme` and `NormalTheme`).
  * **App-level theme** (`main.dart` `MaterialApp`): its scaffold ground, so that no frame between native launch, splash, Home and the error screen shows a different colour.
* **Visual Scope `new-surface`:** a new composition with a new component (the loop track) and unrendered states. Home motion is not specified by the Foundation (audit §3), so the scope is not `motion-critical`. Any Home motion the UI Designer proposes is specified with a reduced path, and QA judges it from video (§18.6).

### 18.3 Decisions (Tech Lead, and the user's N1 decision)

1. **Composition = `S-06b` (Home · today), future-scope items excluded.**
   * Built: the `Looplet` wordmark top-left; the glass card with the `YOLCULUK · N / 30` label, the two-line headline with its lime emphasis word and the loop track; the full-width lime CTA with its glow and trailing arrow, below the card; the subtitle under the CTA.
   * **Not built** (decision 4, audit §3): the settings square (F10), the level-info card (F05 level metadata), the streak chip (F07), the stars chip (no aggregate-stars decision), the gesture hint (F09).
   * The app root has no back affordance (F05 §10, unchanged).
2. **N1 — an in-progress replay after 30 / 30: surface it.** **User decision, 2026-09-29** (decision gate F05.D3-N1-REPLAY-PRECEDENCE, recorded in the orchestration). This replaces the 2026-09-27 terminal-precedence assumption in §8.
   * **Rule:** with 30 / 30 complete and a Journey session in progress, CONTINUE resumes that session (AC7). The card keeps the completion status (`YOLCULUK · 30 / 30`), and the subtitle reads "Seviye N · sürüyor".
   * With 30 / 30 complete and no session in progress, the terminal variant is unchanged: AC9's graceful state, and the CTA replays level 1.
   * The CTA never discards a session in progress. A secondary action that would start another level while a replay is in progress is not part of this contract. If the UI Designer proposes one, it needs a Tech Lead ruling.
   * In model terms: the terminal variant ⇔ `continueTarget == null` (`JourneyProgressModel`, §6). The §6 derivation is unchanged; only the §8 override is removed.
   * **Product precedence (AC7 over AC9 in their overlap) changes a product acceptance criterion.** It was recorded by the Product Owner as **PO-REV-2026-09-29-F05-CONTINUE** (`product/product-prd.md`) and resynced by the Tech Lead into F05 `prd.md` AC7 / AC9 on 2026-09-29. **Effective.**
3. **The loop track (new design-layer component).**
   * Rounded-square numbered nodes joined by a lime → periwinkle line along a rising curve, with the decorative swirl arcs of `S-06b`. Done = lime; current = periwinkle with the 76 pt halo; locked = the UI Designer's treatment, never colour-only.
   * **30-level windowing:** the card shows a window of the Journey, not all 30 nodes. The UI Designer proposes the rule, and it is rendered at 0 / 30, 4 / 30, 12 / 30, 25 / 30 and 30 / 30. Required: the current node is always inside the window; nodes never overlap each other or sit under another element; the window reads as a place in a longer journey.
   * Allowed in `app/lib/design` as a D3 addition, on the §19.8 (2) / §20.7 (6) terms: component tests; the F00 design tests stay green; **no token value change and no new dependency**. The shipped `_JourneyRing` painter is removed from Home.
4. **Copy (interim, through `JourneyStrings`; final with PO / localization, F10-UI-LOCALIZATION).**
   * Wordmark `Looplet` (decision 5). The label is `YOLCULUK · N / 30` (authored caps). The headline is "Sıradaki döngüyü çöz." with "döngüyü" in lime (reference copy, decision 6). The CTA is "Devam et", sentence case, with an arrow. The subtitle is "Seviye N" / "Seviye N · sürüyor".
   * The terminal variant has no Foundation copy. The UI Designer proposes its headline and CTA label ("Tekrar oyna" is the default); they are interim copy.
   * Turkish casing is authored or `tr`-aware only (`turkish_case.dart`). No locale-blind `toUpperCase`.
5. **Home `Semantics`.** The progress keeps "N / 30 seviye tamamlandı — Seviye M" (`JourneyStrings.progressSemantics`). The CTA announces its target, including "sürüyor" when it resumes. The decorative swirl arcs are excluded from the tree.
6. **Text scale (C-9) on Home and the shell.**
   * Container text uses `loopCappedTextScaler` (1.3×): the wordmark, the card label, the headline, the node numerals and the error headline.
   * Free text follows the OS scale up to AX5 with no clipping, overlap or mid-word break: the subtitle, the CTA label and the error body.
   * **Scrolling:** at every OS size up to the 1.3× cap, Home and the error screen fit without scrolling on 390 × 844 to 440 × 956. Above the cap the content column **may** scroll; the CTA stays reachable, and nothing is clipped. The same rule as the result (F03 §20.3 (9)).
   * The OPTIONAL-QUALITY-NOTES item from F03 §19.12 (6) is resolved here for the error surfaces: the `LimePill` label may outgrow the capped headline, but it must not clip, and the pill grows to fit.
7. **Store-error screen (C-6; F08 contract amended in place, see §18.4).**
   * The Foundation pattern (F00 ui-design §8): the ground, a glass card, a Space Grotesk headline, a Manrope body and one primary `LimePill` Retry (≥ 44 pt).
   * Turkish copy through a strings table (the UI Designer proposes it; interim; e.g. "Kayıtlı verilerin açılamadı." / "İlerlemen güvende. Lütfen tekrar dene." / "Tekrar dene").
   * **The raw exception is never shown to the player.** It is logged (`debugPrint`) and may be shown in debug builds only (`kDebugMode`), visibly separated from the player copy.
   * Behaviour is unchanged: Retry re-runs the bootstrap (`ref.invalidate(appBootstrapProvider)`); the data stays intact (F08 AC9).
8. **Native launch and splash (C-7).**
   * The launch background is the Foundation ground colour (a solid, the gradient's top stop or the UI Designer's choice), on iOS and on Android in light and dark mode, API < 21 included. There is no white frame anywhere.
   * The Flutter splash matches the native launch pixel for pixel, or starts from it without a visible jump. The UI Designer decides whether it shows the wordmark (the final drawn wordmark asset is a Phase D item, design-foundation §18 consequence 4). If the native launch shows the wordmark too, it is a bundled image asset, not a system font.
   * `MaterialApp`'s scaffold background moves to the ground colour. The in-app title follows decision 5 (`Looplet`).
   * Out of scope: the OS app display name and the app icon (FIRST-APP-DISTRIBUTION).
9. **Performance:** no backdrop blur (F03 §18); Home holds the mid-tier frame budget on the iPhone 16e simulator.

### 18.4 Contract amendments

* **§8 CONTINUE / terminal:** the 2026-09-27 terminal-precedence paragraph **has lapsed** and is replaced by §18.3 (2) (PO-REV-2026-09-29-F05-CONTINUE resynced 2026-09-29). The shipped app keeps the old behaviour until F05-FE-D3 lands.
* **§6 read-model:** the replay bullet's terminal exception is removed (amended in place). The derivation itself is unchanged.
* **§15 QA focus:** "all 30 → terminal" now reads "all 30 and no session in progress → terminal; all 30 with a replay in progress → CONTINUE resumes it", warm and cold.
* **§10 Home Surface:** "LOOPLET wordmark" becomes `Looplet`; the ring-style indicator becomes the loop track (§18.3 (3)); the terminal variant is rendered with copy (§18.3 (4)). AC10 is met by `YOLCULUK · N / 30` together with the track.
* **§17 Open Items:** the `[PENDING — UI]` home item is superseded by the D3 handoff.
* **F05 `ui-design.md`:** its home sections (Direction A, `PlayTheme` tokens) are superseded by the D3 handoff. The micro-tutorial overlay sections were already superseded by F03 D1 (§9).
* **F08 `architecture.md`, App Init Sequence step 1 and the failure table:** "plain text + retry; no design handoff" becomes the Foundation pattern, Turkish copy and no raw exception shown (§18.3 (7)). F08's behaviour and status are unchanged.
* **Tests:** Home and shell strings and widgets change with the rework. Affected: `journey_home_test`, `journey_home_live_test`, `journey_next_level_test`, `journey_progress_model_test` and `widget_test`, plus any F08 test on `StoreErrorScreen`. Every F05 AC keeps a passing test. The N1 terminal-precedence tests change to the §18.3 (2) rule after the resync.

### 18.5 Non-goals

* No engine, scoring, unlock, persistence, snapshot, lifecycle or route change. `/` ⇄ `/play` stays the only route graph (§8). The §6 read-model and the F09 seam (§11) are unchanged.
* Play, the tutorial overlay and the result (D1 / D2, closed). F10's menu (DAILY, settings, level select), F07's streak, F09 onboarding, F11 audio / haptics, F12 analytics.
* The app icon, the OS display name and store assets (FIRST-APP-DISTRIBUTION).
* F03-MULTITOUCH-FIRST-POINTER and RESULT-APP-SWITCHER-SNAPSHOT stay separate follow-ups.
* MOVESCARD-COUNTER-LINE-HEIGHT and RESULT-F00-COMPONENT-ALIGN may be taken if D3 touches those components. If they are taken, they are stated in the handoff and tested; otherwise they stay open.

### 18.6 Evidence and exit criteria

* **UI Designer (F05-UI-D3)** — the D3 handoff in F05 `ui-design.md`, per the handoff gate in `visual-quality-gate.md`:
  * Home on 393 × 852 plus the 390 × 844 / 440 × 956 variants, and every §18.2 state, including the terminal-with-replay state of §18.3 (2);
  * the loop track with its windowing rule rendered at 0, 4, 12, 25 and 30 / 30;
  * the store-error screen, the native launch and splash (iOS; Android light and dark), and AX5 frames for Home and the error screen;
  * components, states, copy proposals, `Semantics` and contrast;
  * the Home motion (if any) with its reduced path;
  * a Screen / State / Viewport matrix, a Visual Evidence Manifest and a **D3 acceptance list**;
  * gate → Ready for Implementation at the Tech Lead checkpoint.
* **Frontend/Mobile Developer (F05-FE-D3)** — implement from `app/lib/design` (tokens, `GlassCard`, `LoopNode`, `LimePill(glow)`, `LoopletWordmark`, `LoopBackdrop`, `LoopIconView`, and the new loop track); drop `PlayTheme` from Home and the shell; the native launch assets; the §18.3 (2) CONTINUE rule; tests updated (§18.4). `frontend.md` Visual Parity Evidence:
  * runtime screenshots of every Home state on the iPhone 16, and the main states on the 16e and Pro Max, beside the renders;
  * a **cold-start recording** on the simulator from the native launch to Home, showing no white frame and no jump at the splash hand-off. Android light / dark is stated as a limit if it cannot run (ANDROID-CI-EVIDENCE);
  * the store-error screen, forced on the simulator (e.g. a failing bootstrap), with no raw exception in a release-mode or profile-mode capture;
  * the OS text sweep large → AX5 on Home and the error screen;
  * `melos run analyze` / `test` green; `integration_test` green on the simulator.
  * **Startup impact: yes** (native launch assets, the splash, the app theme). The production-shaped cold boot (`prompt-evidence-integrity-standard.md` §4) is required, from an empty store and from an existing one.
* **QA (F05-QA-D3)** — final stage, client-only; modules core + client-ui + visual-quality + stateful-flow; regression full (startup / routing):
  * an independent runtime rubric ≥ 93, every dimension ≥ 8, no fail condition;
  * F05 AC7–AC10 and AC12 on the new Home, including the §18.3 (2) replay rule warm and cold;
  * the error screen and Retry, and cold start with no white frame;
  * D1 / D2 regression across the Home ⇄ `/play` round trip;
  * Android stated as a limit.
* **Exit:** Visual Quality Gate Passed; final QA Approved or Approved with Notes; Delivery Review Accepted. F05 then returns to Done, Phase D is complete, and the resume point is F08 local evidence (Design Adoption Route).

### 18.7 Visual-gate checkpoint rulings (Tech Lead, 2026-09-29)

The F05-UI-D3 handoff (`ui-design.md`, commit 981b807) is **accepted**. The Visual Quality Gate is **Ready for Implementation**, and F05-FE-D3 is open.

**Verified independently at the checkpoint** (HEAD 981b807, clean tree):
* **Handoff-gate items** (`visual-quality-gate.md` §2) are all present: the matrix §12a; component, typography, colour, asset and interaction decisions §5–§7; the motion spec with its reduced path §5; the manifest §12b; the selection record §2; the acceptance list §11.1.
* **Artefacts:** every PNG named in `ui-design.md` exists (45 in `design/`: 41 renders + 4 contact sheets), and the F00 pointers (`S-06b`, `A-06` / `B-06` / `C-06` / `C-06b`, `audit/cur-home-*`) exist. `node gen-d3.mjs` into a scratch folder regenerates all 45 pages and tables byte for byte, so every render traces to committed source. The contact sheets are review aids, not gate artefacts.
* **Window rule:** the frontier formula, the replay formula and the terminal window reproduce every row of `window-d3.txt` by hand (1–5, 1–5, 9–13, 22–26, 5–9, 26–30, 10–14).
* **Scope:** no future-scope item on any Home render; no back affordance; one CTA; no blur. The N1 render `D3-07` follows §18.3 (2): the card says 30 / 30, the CTA resumes, and the caption reads "Seviye 12 · sürüyor".
* **Shipped code the implementation map names** (`app/lib`): `_JourneyRing`, `_Wordmark`, `_ContinueCta` (`home_screen.dart`); `_SplashScreen` and the English `StoreErrorScreen` (`app_router.dart`); `title: 'LOOPLET'` (`main.dart`); the white iOS launch storyboard; `NormalTheme` on `?android:colorBackground` in `values/` and `values-night/`. `LimePill(glow:)`, `ScrollBand`, `loopCappedTextScaler`, `LoopletWordmark`, `GlassCard`, `LoopBackdrop`, `LoopIcon.arrowRight` / `loopBreak` and `reduceMotionRequested` exist. Two items the handoff does not cover are ruled below: `LoopNode`'s API and `Semantics` (ruling 2) and Home's `kDebugMode` `_DebugRow` (C2).
* **Renders read:** the four contact sheets, `D3-01b` (level 1 started) and `D3-20c` (the debug error box).
* **Manifest correction (structure only, no design change):** `ui-design.md` had the matrix and the manifest as level-3 headings (`### 12a.` / `### 12b.`), so the full workflow audit did not find the Visual Evidence Manifest. The Tech Lead raised both to level 2 (`## 12a.` / `## 12b.`, the F03 D2 form). No row or text changed.

**Rulings on `ui-design.md` §14:**
1. **Windowing: A ("sliding five") is adopted as the handoff design.**
   * This is not an Exploration Gate selection. The direction is Selected (Loop Glass, `S-06b`), and §18.3 (3) left the windowing rule to the UI Designer within its bounds. A meets them: the current node is always in the window; no node overlaps another node or a halo; nothing sits outside the card; and the window reads as a place in a longer journey (the lead-in line behind, the `N / 30` label for the whole).
   * B is not adopted: its band pips show the chapter metadata that design-foundation decision 4 keeps out, they compete with the label as a second progress indicator, and the node count changes from band to band (3 at 4 / 30; mostly locked at 25 / 30).
   * **QA watch point, not a defect:** in frontier windows (e.g. 4 / 30, 12 / 30) the current node sits at the right end, so nothing ahead is drawn. The label carries the whole Journey. QA judges this under the rubric.
2. **`LoopNode` state extension: inside the §18.3 (3) allowance** (it is the loop track's own node; design-layer addition on the §19.8 (2) / §20.7 (6) terms; F00 stays Done).
   * States: `done`, `current` (both unchanged), `open`, `locked`, `finish`, as in `ui-design.md` §7. The existing call form `LoopNode(number:, current:)` keeps its behaviour, so the F00 design tests (`test/design/components_test.dart`, incl. QA-02) stay green unmodified.
   * **`Semantics`:** standalone, each state keeps a spoken state — `N, tamamlandı` (done, finish), `N, geçerli seviye` (current), `N, açık` (open), `N, kilitli` (locked). Inside `LoopTrack` every node, line and swirl arc is excluded from the tree. The progress is announced once through `progressSemantics` (§18.3 (5), `ui-design.md` §12).
   * **The track is display-only.** Nodes are not buttons and have no tap handler. There is no level select (F10, §17); AC2 stays satisfied by construction.
   * The `.62` outline alphas are local constants, not tokens. No token value change and no new dependency.
3. **Headlines per situation: accepted as interim copy** through `JourneyStrings` (final copy with PO / localization, F10-UI-LOCALIZATION). The "Başla" alternative is not adopted; the CTA stays "Devam et" (§18.3 (4)).
4. **The breathing pulse and the one-shot terminal bloom are dropped: accepted.** The Foundation specifies no Home motion, and §18.2 made any Home motion optional. The runtime risk "terminal 30 / 30 bloom under Reduce Motion" lapses with the bloom.
5. **The store-error screen has one action: accepted.** F08 AC9 needs Retry and data intact; iOS has no programmatic exit, and system back on Android leaves the app (OS default).

**Tech Lead corrections to the handoff** (binding for Frontend and QA; `ui-design.md` carries a pointer):
* **C1 — the copy selection rule.** The `ui-design.md` §8 row for `D3-01b` says it differs from the new state "by the caption only". The render, the §12 copy table and `gen-d3.mjs` all switch the headline to "Sıradaki döngüyü çöz." once level 1 has started. The render and the table win. The rule, in §6 model terms (`JourneyProgressModel`: `progressCount`, `completedLevels`, `inProgressLevel`, and `currentLevel` = its `continueTarget`):
  * **Headline:** `progressCount == 30` → "Tüm döngüler tamam." (with or without a session); else `inProgressLevel ∈ completedLevels` → "Yarım kalan döngüne dön."; else `progressCount == 0 && inProgressLevel == null` → "İlk döngüyü çöz."; else "Sıradaki döngüyü çöz.".
  * **CTA:** `currentLevel == null` → "Tekrar oyna" (→ level 1); else "Devam et" (→ `currentLevel`). The model already yields the replay at 30 / 30; the shipped override is Home's `done ? 1 : continueTarget` (`home_screen.dart`), which the D3 Home drops. Terminal ⇔ `continueTarget == null`, never `allComplete`.
  * **Caption:** `currentLevel == null` → "Seviye 1"; else "Seviye M", plus " · sürüyor" iff `inProgressLevel != null`.
  * **Window** (unchanged, §6 of the handoff): replay offset (`start = current − 2`) iff a completed level above `currentLevel` exists. A replay of the highest completed level (e.g. 12 of 12 done) therefore uses the frontier window (8–12, current at the top) under the replay headline. Add that case to the §11.1 (2) component test.
* **C2 — the debug row.** Home's `_DebugRow` (the smoke-puzzle launchers) stays, **`kDebugMode` only**. It sits outside the content column, anchored to the bottom safe area in the empty lower third. It moves no §11.1 (1) anchor. It is omitted whenever it would intersect the caption (e.g. above the 1.3× cap), so a debug build never reports an overflow at AX5 (the F03-QA-D2R N5 overflow). It is exempt from §11.1 (16) (Material buttons) because players never see it. Parity and QA captures of Home are taken in a profile or release build, or else they list the row as the only debug-only deviation.
* **C3 — when the entrance plays.** Once per app process, at the first Home frame that has the Journey model (a cold start, or after the store-error Retry). Never on a return from `/play` (Home stays mounted, §6), and never when the model updates. Under reduced motion there is no animation.

**Evidence expected from Frontend** (`frontend.md` § Visual Parity Evidence, gate schema), extending §18.6:
* `runtime-screenshot` for every §12a Home row on the iPhone 16 (incl. `D3-01b`, the replay, terminal and N1 rows), and the in-progress, N1 and 1.3× rows on the 16e and Pro Max, plus the store error (normal and AX5 top / end);
* `parity-comparison` composites against the `D3-*` renders with a deviation list (±2 pt at 1.0×, the §11.1 (1) anchors);
* `runtime-video`: a cold start from the native launch to Home (empty store and existing store), with the frame where the native launch hands over to Flutter named; the Home entrance with and without Reduce Motion;
* `accessibility`: OS text default, 1.3× and AX5 on Home (in-progress and N1) and the store error (offset 0 and scrolled);
* the store error forced in a **profile or release** build (no exception text) and in a debug build (the separated box), plus the `debugPrint` line in the log;
* a component test over the window rule for every `window-d3.txt` row and the C1 cases (replay at 1, 2, 12 of 12, 29 and 30; frontier at 1–5 and 26–30; terminal); widget tests for the C1 copy rule and the §18.3 (2) CTA rule, warm and cold;
* a named negative run for each new rule: the N1 CTA reverted to terminal precedence, the window's replay offset removed, the raw exception shown outside `kDebugMode`, and `NormalTheme` back on `?android:colorBackground` (a manifest / resource test) — each caught by a failing test.
