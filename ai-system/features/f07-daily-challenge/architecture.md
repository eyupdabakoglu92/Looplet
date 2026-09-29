# F07 — daily-challenge: Architecture

> Contract authority for F07. Tech Lead, activation 2026-09-29 (F08 `architecture.md` A21 — the user's decision F08.FUNCTION-DEPLOY-GO — C).
> Authorities: `product/product-prd.md` (F07, §5.3, §11, §15, §16); `project-authority/platform.md` (§3 / §4 content distribution, §5 persistence, §6 security, §10 testing, §14 visual); `project-authority/release.md` (§2 content packs served to clients); F08 `architecture.md` (Persistence Schema, `sync_queue` contract, Reconciliation, Firebase Sync Surface, Offline Daily Cache, Ownership & Lifecycle, Streak-Integrity / Clock, Scope Boundary F08 ↔ F07); F03 `architecture.md` (play session, §19 Play, §20 result); F04 (rating); F05 `architecture.md` §18 (Home); `project-authority/design-foundation.md`.

---

## Dependency Edges [LOCKED]

* **F08 client surface** (Functional Approved; frozen for F07 — F08 A21 ruling 4):
  * the Drift tables `daily_entry`, `daily_attempt`, `daily_streak`, `daily_puzzle_cache`, `sync_queue`;
  * `DailyRepo`, `DailyStreakRepo`, `DailyPuzzleCache`;
  * `DailyResultSyncService.enqueue` / `drain`;
  * the `submitDailyResultV1` request contract.
  * F07 composes these. It does not change their signatures or the schema. A needed change goes to the Tech Lead first.
* **F08 deployed backend:** the callable in production. It is needed only for **F07's release** (F07-DEVOPS depends on F08-DEVOPS; the gate F08.DEPLOY-RESUME). Delivery and functional QA use the Firebase emulator (the F08-FE13 debug wiring).
* **F03 play session:** `PuzzleSource.daily` already exists in the active-session snapshot. The Play screen runs a daily puzzle with its own rules (AC3). Undos 3, unlimited restart and unlimited moves are already F03's session rules; `columnMovesEnabled` comes from the puzzle.
* **F04 rating:** stars for a daily completion come from the same moves-vs-`optimalMoves` rule. Daily completions never write `personal_best` (Journey only; product PRD §6.1 F04 note).
* **F06 toolchain:**
  * `Puzzle` (type `daily` + `dailyDate`) in `looplet_content`;
  * `looplet_authoring` `solve` / `playtest` / `export` / `check`. `check` already enforces a 30-day no-repeat window over a manifest's `assignments`.

---

## D1. Dependency ruling [LOCKED — F08 A21 ruling 4]

* F07 delivery starts on F08's Functional Approved client surface.
* F07's release waits on F08's deployed callable.
* F07's sync evidence runs against the Firebase emulator (debug define), as F08's did.

---

## D2. Daily content: pack format and distribution [LOCKED]

1. **Served artifact — one self-contained pack per language:** `daily_pack_{lang}.json` (UTF-8, `lowerCamelCase`, optional fields omitted):
   ```json
   {
     "schemaVersion": 1,
     "contentVersion": "2026-10-01.1",
     "lang": "tr",
     "numberingEpoch": "2026-10-01",
     "days": [
       { "dailyDate": "2026-10-01", "dailyNumber": 1, "puzzle": { "id": "daily-tr-2026-10-01", "type": "daily", "dailyDate": "2026-10-01", "...": "the full Puzzle JSON (looplet_content)" } }
     ]
   }
   ```
2. **Rules the pack must satisfy** (the authoring `check` rules, and the client's validation):
   * `days` is sorted by `dailyDate`, contiguous, and has no duplicate date;
   * for each day, `puzzle.dailyDate == dailyDate`, `puzzle.type == daily`, `puzzle.id == "daily-{lang}-{dailyDate}"`, and the puzzle parses as a `Puzzle` with `optimalMoves ≥ 1` (solved);
   * `dailyNumber` is the number of days since `numberingEpoch`, plus 1. It is stable across packs, so F13's `LOOPLET #N` is well defined;
   * the 30-day no-repeat window holds over the puzzle definitions;
   * `lang` matches every puzzle.
3. **Identity (AC2):** the puzzle for `(lang, dailyDate)` is exactly the pack's entry. Every client reads the same pack, so the same language and date give the identical puzzle.
4. **Pointer:** Remote Config `daily_manifest_url` holds the **pack URL** (`platform.md` §4 "points at the current daily pack"). Rollback = repoint to the previous pack. An empty value means no Daily is available.
5. **Hosting** is provider-neutral for the client: any HTTPS URL.
   * Production hosting (Cloud Storage per `platform.md` §3, or Firebase Hosting) and its plan / billing needs are decided at **F07's release gate** by the Tech Lead with DevOps. *[Needs verification at that gate: whether the chosen host needs the Blaze plan.]*
   * Nothing is deployed during delivery.
6. **Authoring side (repo):**
   * the daily puzzle definitions and exports live under `content/daily/{lang}/pool/`;
   * the date assignments live in `content/daily/{lang}/daily_manifest_{lang}.json` — `numberingEpoch` plus `assignments: { "YYYY-MM-DD": "<puzzle id or file>" }`, the shape `check` already reads;
   * a new `looplet_authoring pack-daily` command builds the served pack from the manifest and the pool, into a build-output path that is not the source.
7. **Development / test source:** debug builds may override the pack URL with `--dart-define=LOOPLET_DAILY_PACK_URL=<url>`, for example a local static server over the `pack-daily` output. Tests use an injected fetcher. Remote Config is not emulated, so debug builds never need the real project for Daily content.

---

## D3. Fetch, cache and eviction [LOCKED — resolves F08 "[OPEN — F07]"]

* **Interface:** `DailyContentSource.fetchPack(lang) → DailyPack` (HTTPS GET of the pack URL; 10 s timeout; one attempt per trigger, no retry loop). The implementation is swappable (tests, debug override).
* **Triggers** (each only if today's `(lang, dailyDate)` is not cached; all non-blocking for Home and Journey):
  * app start, after bootstrap;
  * `resumed`;
  * opening the Daily screen;
  * Retry on the "needs connection" state;
  * connectivity regain while the Daily screen shows "needs connection".
* **Population:** on a valid pack, `DailyPuzzleCache.put` the entries for **today through today + 7**. This is the prefetch that makes the next week playable offline.
  * An entry already cached for a date is **not** overwritten. The day's puzzle never changes under a player, even if a later pack differs.
  * **Exception:** a date with no official result yet may be replaced by a newer `contentVersion`.
* **Eviction:** `evictOlderThan(today − 14 days)` at app start. A date with an in-progress session or an unsynced official result keeps its cache row until resolved.
* **Validation:** the client rejects a pack that fails D2 (2) — wrong `lang`, a date mismatch, an unparseable puzzle. A rejected pack caches nothing and is logged (`daily_pack_invalid`). The state becomes **unavailable**, not a crash.
* **States the Daily screen derives** (exhaustive):
  * `loading` — a fetch is in flight and nothing is cached;
  * `ready` — today is cached and there is no official result yet;
  * `doneToday` — an official result exists for today;
  * `needsConnection` — offline or the fetch failed, and today is not cached;
  * `unavailable` — `daily_enabled == false`, an empty `daily_manifest_url`, no pack entry for today, or an invalid pack.

---

## D4. Dates and rollover [LOCKED]

* `dailyDate` = the device-local calendar date (`YYYY-MM-DD`) **when the run starts**.
  * The run keeps it until it completes, including across midnight and across a kill / relaunch (**product PRD §11 proposal adopted**: the puzzle in play at start).
  * The completion is recorded for that date and counts for that date's streak.
* **Restore:** the active snapshot stores `puzzleSource = daily` and `puzzleId = daily-{lang}-{date}`. The date comes from the id, and the puzzle from `daily_puzzle_cache` (kept by D3 eviction).
  * If the cache row is gone (not expected), the snapshot is discarded as F08 does for a corrupt snapshot, and the player lands on Home.
* **Rollover re-evaluation:** on opening the Daily screen and on `resumed`, recompute today.
  * A Daily screen that is **not mid-run** and shows a past date switches to today's state (AC1).
  * A run in progress is never interrupted.
* **Date arithmetic** uses calendar dates (`DateTime(y, m, d)` in local time, then `+1 day` on the date parts), never 24-hour spans. This holds on DST days, leap days and year boundaries.

---

## D5. Official result and attempts [LOCKED]

* **On a daily completion, in one Drift transaction:**
  1. `DailyRepo.recordCompletion(...)` (F08 contract, unchanged). The first completion of `(guestId, lang, dailyDate)` → `firstRun`; a later one → `replay` (an attempt row).
  2. If `firstRun`: apply the streak rule (D6) through `DailyStreakRepo.write`.
  3. If `firstRun`: `DailyResultSyncService.enqueue(...)` with the F08 request fields:
     * `lang`, `dailyDate`, `dailyId`;
     * `moves`, `optimalMoves`, `durationMs` (the monotonic elapsed);
     * `stars`, `completedAtUtcMs`;
     * `clientAttemptNumber = 1`.
     * The enqueue participates in the same transaction. If F08's `enqueue` cannot join a caller's transaction, the Frontend/Mobile Developer reports it before changing anything (Dependency Edges).
* **A replay** writes only the attempt. The official result, the streak and the queue are unchanged (AC5).
* **Score** = move count, then duration as the tie-break (both stored; no leaderboard in the MVP).
* **Stars** = F04's rule. Daily completions never write `personal_best`.

---

## D6. Streak rule [LOCKED — F07 owns the rule; F08 stores it]

* **On a first run for date `D`,** with `L = lastCompletedDate`:
  * `L == null` → `current = 1`;
  * `D == L + 1 day` → `current = current + 1`;
  * `D > L + 1 day` → `current = 1` (a missed day; AC6);
  * `D ≤ L` (the clock moved back, travel westward, or an old in-progress run finished late) → `current` unchanged, no double count;
  * then `best = max(best, current)` and `lastCompletedDate = max(L, D)`.
* **Displayed current streak** (effective, derived — never a separate write):
  * `currentStreak` if `lastCompletedDate ∈ {today, yesterday}`, else **0**;
  * best is always the stored `bestStreak`.
  * This is the product's `DAILY_STREAK_RESET`: a missed day shows 0 at once, and the stored value resets on the next completion.
* **No server-side check** (F08 locked). A clock moved forward can inflate a streak — an accepted MVP limitation, like the reinstall case.

---

## D7. Remote Config and the kill-switch [LOCKED — closes F07-KILL-SWITCH]

* **Dependency:** add `firebase_remote_config` at a version compatible with the pinned `firebase_core` line; add `http` for the pack fetch.
  * No Flutter or Firebase upgrade (a separate decision); the lockfile changes only by these additions.
* **In-app defaults** (used offline and before the first fetch): `daily_enabled = true`, `daily_sync_enabled = true`, `share_enabled = true`, `daily_manifest_url = ""`.
* **Fetch:** `fetchAndActivate` at app start, non-blocking and best-effort (a failure is logged and the defaults / last activated values stay). Minimum fetch interval: 1 h in release, 0 in debug.
* **Effects:**
  * `daily_enabled == false` → the Home Daily entry is hidden, and a restored or deep-linked Daily shows `unavailable`. **An in-progress daily run is not killed:** it can finish, and its result is recorded.
  * `daily_sync_enabled` → `dailySyncEnabledProvider` reads the activated value in release builds. The debug override (`debugSyncDisabledProvider`) stays. `drain()` stays a no-op while it is false (F08).
  * `daily_manifest_url` → D2 (4).
  * `share_enabled` → read by F13; not used by F07.
* **Debug / emulator:** Remote Config is not emulated. Debug builds use the defaults plus the D2 (7) pack override. The kill-switch paths are proven with an injected Remote Config fake.

---

## D8. Surfaces, routes and navigation [LOCKED — contract; visual design by the UI Designer]

* **Routes:** `/daily` — the Daily screen. It hosts the D3 states and starts the play session through the existing `/play` with `PuzzleSource.daily`.
  * Back / system back from `/daily` → Home.
  * From the daily result → back to `/daily` (which then shows `doneToday`), or replay in place.
  * No Next Level on a daily result. No other route changes.
* **Home (cross-feature amendment of F05 §18):**
  * a **secondary** Daily entry — not a second lime CTA; F05's one-primary-CTA rule holds;
  * it shows the day's number (`#N`), the effective current streak, and its state (available / done today / needs connection);
  * it is hidden when `daily_enabled == false`.
  * F10 later owns the main-menu layout. The Home placement is interim, and F05 stays Done (its §18 notes this amendment).
* **Play header for a daily:**
  * the day's label (`GÜNLÜK · #N`, with the date);
  * moves unlimited, 3 undos, unlimited restart, as AC3 states.
* **Daily result** (the F03 §20 full-screen result, daily variant):
  * moves, duration, stars;
  * **official** vs **replay** labelling — a replay says the official result is unchanged and shows it for comparison;
  * **Current Streak + Best Streak**;
  * Retry (replay) and back.
  * **No Share control in F07.** The layout reserves its place for F13 (prd Open Questions (1)).
* **`needsConnection`** says Journey is still playable and offers Retry. **`unavailable`** is calm and not an error.
* **Copy:** Turkish, through a strings table (interim copy; PO / localization later — F10-UI-LOCALIZATION). No raw error text is ever shown to the player.
* **Visual Scope `new-surface`** on the Selected Foundation. It needs at least two rendered directions, a recorded selection, and a handoff with a Visual Evidence Manifest before implementation (`visual-quality-gate.md`). Accessibility: C-9 text scale up to AX5 (F03 / F05 rule); never colour-only.

---

## D9. Validation responsibility [LOCKED]

* **Authoring tooling:** the pack rules D2 (2) at build time (`check`, `pack-daily`), with named negative cases.
* **Client:**
  * the pack validation D2 (2) at fetch time;
  * D4 date attribution;
  * D5 transactional completion;
  * D6 streak;
  * D7 kill-switch effects.
* **F08 (unchanged):** exactly-once delivery, queue states, server create-only, callable validation.
* **Content Designer:** the pool's editorial quality and coverage. The human sign-off is a decision gate (F07.DAILY-POOL-SIGNOFF), opened when the pool is delivered.

---

## D10. Evidence plan [LOCKED — the QA plan is locked at QA activation]

* **Automated functional:**
  * the streak table — first day, consecutive, missed day, same day replay, clock back, DST day, leap day, year boundary;
  * the rollover and midnight-crossing attribution;
  * pack validation with a negative case for each D2 (2) rule;
  * the completion transaction — first run → entry + streak + one queue item; replay → attempt only; each with a named negative run;
  * the kill-switch effects through a Remote Config fake.
* **Repeatable integration:** against the Firebase emulator, a real daily first run → exactly one server doc; a replay → no new queue item, the doc unchanged.
* **Runtime (canonical simulator):**
  * Daily open → play → first-run result with the streak;
  * a replay shows the official result unchanged;
  * kill / relaunch mid-daily → exact restore with the start date;
  * offline with a cached day → playable (F07.OFFLINE-DAILY);
  * offline with no cache → `needsConnection`, and Journey plays.
* **Real no-network run:** as F08 A4 — the user switches the network off; Claude does not change system settings.
* **Visual:** Visual Parity Evidence by the Frontend/Mobile Developer; independent QA ≥ 93, every dimension ≥ 8.
* **Content:** `check` + `pack-daily` exit 0 over the real pool, and the sign-off gate.

---

## D11. Release impact [LOCKED — scope; OPEN — the DevOps runbook at F07's release]

* **Release Scope `production-readiness`:** a content pack served to clients plus a Remote Config value (project `release.md` §2).
* **F07-DEVOPS** (Blocked until F08-DEVOPS is done and F07's functional QA passes):
  * the pack hosting;
  * publishing `daily_manifest_url`;
  * the rollback by repointing;
  * the smoke — the release build fetches the pack; a first run syncs once.
* No deploy happens during delivery. The app-build distribution is still FIRST-APP-DISTRIBUTION.

---

## Non-goals [LOCKED]

* Share (F13); leaderboard; analytics events (F12); the main-menu layout and Settings (F10); server-side anti-cheat; an English pool; any change to F08's schema or client API; a Flutter or Firebase upgrade; any deploy.

---

## Open Items

* **[OPEN — F07 release gate, Tech Lead + DevOps]** the production pack host and its plan / billing needs.
* **[OPEN — Product Owner, optional]** AC7's Share wording (prd Open Questions (1)).
* ~~F07.DIRECTION-SELECT~~ — RESOLVED 2026-09-29: Direction A (A2).
* **[OPEN — decision gate, later]** F07.DAILY-POOL-SIGNOFF — the user signs off the pool; opened when F07-CONTENT delivers.

---

## A1. F07-UI visual-gate checkpoint (Tech Lead, 2026-09-29)

**Reconciliation of F07-UI** (`ui-design.md`, renders in `design/`, sources `design/src/gen-f07.mjs`):

* **Task coverage:** every Current Brief item is delivered.
  * Two materially different directions on identical content — A "Hafta döngüsü" (the streak drawn as the last seven days in the loop-track language) and B "Günün bileti" (a typographic ticket, a one-line capsule entry). Each covers the Home entry (available, done), `/daily` (ready, needsConnection) and the result (first run 5 / best 12, replay). They differ in composition, entry form, hero and streak object, not in colour.
  * The full state set for the recommended A: Home entry available / done / needs connection / loading / streak 0 / hidden; `/daily` loading / ready / doneToday / needsConnection / unavailable, pressed, focus; the Play header; the result (first run, replay, 0 → 1 Perfect with best kept, pressed); the Share place; iPhone 16 / 16e / Pro Max; 1.3× and AX5; motion stills with the reduced path.
  * The screen / state / viewport matrix, components, typography, colour, motion, the strings table and the Visual Evidence Manifest are in `ui-design.md` §5–§12b.
* **Evidence read, not only listed:**
  * 63 renders + 4 sheets exist in `design/` (counted);
  * the fit table `design/src/fit-f07.txt` comes from each page's own check script;
  * its negative case is recorded: a stacked Share pill overflowed by 28–30 pt at 1.3×, and the slot was moved into the primary row.
  * Limits stated in the handoff: HTML/CSS renders (not Flutter), no runtime, iOS frames only.
* **Contract compliance:**
  * D3 states: all five, plus the Home mapping ruled below.
  * D6: the effective streak everywhere.
  * D7: the Home entry is hidden when `daily_enabled == false`.
  * D8: a secondary entry, with **one lime CTA on Home**; `/daily` back → Home; the result → `/daily` or replay in place; no Next; no Share control; calm needsConnection / unavailable; no raw error text; Turkish copy through a strings table.
  * C-9: container text capped at 1.3×, free text to AX5.
* **Self-score:** 94 for A, lowest dimension 9. It is provisional — QA scores the runtime.
* **Delivery Review:** Accepted.

**Rulings on `ui-design.md` §14:**

1. **NTLC-1 — `#N` offline → option (a).**
   * F07 stores the pack's **day envelope**, `{"dailyNumber": N, "puzzle": { …the Puzzle JSON… }}`, in `daily_puzzle_cache.puzzle_json`.
   * F08's schema and `DailyPuzzleCache` signatures are unchanged: the column is text, and F07 is its only reader (`put` / `get` have no other production caller, checked 2026-09-29).
   * D3 population and D4 restore read the envelope. `dailyNumber` must equal D2 (2)'s numbering, and a row that fails to parse counts as absent (D4: a discarded snapshot → Home).
   * Recorded as a cross-feature note in F08 `architecture.md` (Offline Daily Cache).
   * Surfaces show `#N` only when today's day is known (ready, doneToday, the Play header of a cached day). loading / needsConnection / unavailable show `GÜNLÜK` without a number.
2. **NTLC-2 — the Home entry mapping (amends D8's state list):**
   * available / done today / needs connection as designed;
   * `loading` (a fetch in flight, nothing cached) → the quiet "Hazırlanıyor" entry, still tappable;
   * **`unavailable` for any reason → hidden** — not only `daily_enabled == false`, but also an empty `daily_manifest_url`, no pack entry for today, or an invalid pack;
   * a deep-linked or restored `/daily` still shows `unavailable`.
3. **NTLC-3 — the Share place:**
   * D8's "the layout reserves its place" means a **zero-height slot at the right end of the result's primary row** (63·s round, 10·s gap). F07 draws nothing there.
   * The 1.3× no-scroll fit is proven with the slot counted (`F07-A-42`, `F07-A-v-16e-result-share-slot-budget-cap-1_3`).
   * F13 inherits the slot, or brings its own fit proof under the same rule.
4. **NTLC-4 — Home at AX5 scrolls (direction A):**
   * **Accepted, as a cross-feature amendment of F05 §18.3 (6)'s AX5 outcome.** With the entry, Home is a clamped scroll view **only above the 1.3× cap**. It needs no scroll up to the cap on 390–440 pt widths (≥ 29 pt spare, measured).
   * At offset 0, the wordmark, the Journey card, the CTA and the caption stay fully visible. The D2 `ScrollBand` appears only once scrolled. The entrance lands at offset 0.
   * With the entry hidden, Home is exactly F05 D3 (no scroll at AX5).
   * If B is selected, this ruling is re-measured before implementation. Recorded in F05 `architecture.md` §18.10.
5. **NTLC-5 — the daily result layout (amends F03 §20.3 (4) / (10) for daily sessions only):**
   * a one-line headline;
   * the stars inside the stats card (`HAMLE · SÜRE · YILDIZ`), with the D2 star pop in the cell at the same times;
   * `OPTİMAL` moved into the subtitle;
   * no `EN İYİ` stat — a daily writes no personal best (Dependency Edges, F04);
   * the replay's official row;
   * the streak card;
   * the chip precedence `TEKRAR` > `HARİKA` > `RESMÎ SONUÇ` (`YENİ EN İYİ` does not apply).
   * The §20.3 (1)–(3) win timeline, input lock, lifecycle and reduced path, and the retry flight, are **unchanged**.
   * The A streak reveal (1300–1440 ms) is a rest-state reveal after input unlocks, like the stars.
   * Journey results are unchanged.
6. **Design-layer additions (no token change): accepted.**
   * `WeekTrack`, `DailyEntryCard` and the official row;
   * the `LoopNode` states `missed` / `todayDone` / `todayOffline` and a size parameter;
   * `StatCell` icon and stars cells; `LimePill` / `OutlinePill` icon slots;
   * the drawn icons `check` and `offline`.
   * The week data comes from seven `DailyRepo.firstRun` reads (no F08 API change).

**Gate:** Foundation Selected, exploration and handoff complete → **Visual Quality Gate stays Pending until the selection is recorded** (`visual-quality-gate.md` §3). F07.DIRECTION-SELECT is opened for the user. If B is chosen, the UI Designer re-issues §3–§12b for B (a new F07-UI-B task) before F07-FE.

**Routing:** the feature waits on F07.DIRECTION-SELECT (a feature-scoped gate parks delivery). F07-TOOL is briefed and is activated at the decision intake; F07-FE follows F07-TOOL and the selection.

---

## A2. Decision F07.DIRECTION-SELECT — A (the user, 2026-09-29)

* **Selected:** Direction A "Hafta döngüsü" (`ui-design.md` §2, recommended). Selection authority: the user, through this decision gate. B "Günün bileti" is not built.
* **Consequences:**
  * The `F07-A-*` renders are the **selected source** for F07-FE's Visual Parity Evidence and for QA.
  * The A1 rulings apply as written, including ruling 4: Home scrolls above the 1.3× cap when the entry is shown.
  * **Visual Quality Gate → Ready for Implementation:** the Foundation is Selected; the exploration, handoff and selection record are complete.
* **Routing:** F07-TOOL is activated (Frontend/Mobile Developer, the Current Brief). F07-FE follows F07-TOOL through the Tech Lead reconciliation. The selection no longer blocks anything.
* Nothing else in the contract changes.

---

## A3. F07-TOOL checkpoint (Tech Lead, 2026-09-29)

**Reconciliation of F07-TOOL** (`frontend.md`, F07-TOOL section; commit 209daf1):

* **Task coverage:** all six Current Brief items are delivered.
  1. `DailyPack` and one validator, `DailyPack.validate`: a named `DailyPackRule` for every D2 (2) rule, plus `format` for the envelope. `fromJson` throws `DailyPackFormatException` with every violation.
  2. `pack-daily`: the default output is `<repo-root>/build/daily/daily_pack_<lang>.json` (ignored by git). The output is deterministic (golden bytes), it refuses to write into the source, and it writes nothing on a failure.
  3. `check` runs the same build on every Daily manifest.
  4. Named negatives: one per rule at the pack level and at the source level.
  5. The dev pack fixture (2026-10-01 … 10-22, #1 … #22), outside `content/`, and a generator that shifts it to any "today".
  6. The delivery report.
* **Contract compliance:** D2 (1) / (2) / (6), D4 (calendar arithmetic, via `CalendarDate`), D9 and A1 ruling 1 are preserved. No app code, no F08 change, no dependency change. `Puzzle` is unchanged.
* **Preserved:**
  * every F06 `check` rule, including the id-based 30-day window and the duplicate-definition rule;
  * the other commands;
  * the 25 F06 tool tests;
  * `content:check` over `content/` (no Daily manifest yet).
* **Evidence read, not only listed:**
  * The test bodies assert each negative's rule set exactly, `== {rule}`, and the clean baseline is asserted first. The delivery records that the duplicate-date negative caught its own no-op edit.
  * **Re-run by the Tech Lead on 209daf1:** `looplet_content` 44 / 44, `looplet_authoring` 54 / 54.
  * **Independent negatives, on scratch copies:**
    * a 5-day source → `check: OK`, exit 0;
    * a pool day copying Journey 20's definition → `duplicate puzzle definition` (Journey ↔ Daily, product PRD F06), exit 1;
    * `numberingEpoch` after the first two days → two `[dailyNumber] … before numberingEpoch`, `nothing written`, exit 1.
  * The workspace gates reported in `frontend.md` §17 (format, analyze, test with app 588, content:check) are the delivery's host runs. Nothing touching the app changed between them and 209daf1.
* **Delivery Review:** Accepted.

**Rulings:**

1. **The served-as-is pool model — accepted; it clarifies D2 (6).**
   * A pool file is exactly one day's puzzle: `type: daily`, `dailyDate` = the assigned date, `id` = `daily-{lang}-{date}`, at `content/daily/{lang}/pool/daily-{lang}-{date}.json`.
   * `pack-daily` assembles, numbers and validates; it never rewrites a puzzle.
   * The manifest is locked as `{schemaVersion: 1, lang, contentVersion, numberingEpoch, assignments: {date: id | file}}` at `content/daily/{lang}/daily_manifest_{lang}.json`. The pack's `contentVersion` comes from the manifest.
   * Definition files for the pool live outside `content/`, at `tools/looplet_authoring/drafts/daily/{lang}/_defs/`: `check` reads every `.json` under `content/`.
2. **Readings of D2 (2) — accepted as contract:**
   * a day before `numberingEpoch` fails `dailyNumber`;
   * an empty `days` fails `format`;
   * the window counts calendar days: 29 days apart is a repeat, 30 is allowed;
   * `datesSorted` is a pack-level rule. A source cannot break it: the pack is sorted by construction, and a test proves it.
3. **Daily reuse (`frontend.md` §16) → no definition repeats anywhere in the pool for the MVP.**
   * The duplicate-definition rule stays as it is. It is stricter than, and compatible with, the product rule ("must not duplicate Journey puzzles or repeat within a defined rolling window").
   * About 60 puzzles cover about 60 days.
   * Reuse after the window is a later decision (workflow-follow-ups DAILY-POOL-REUSE). Nothing is built for it now.
4. **`CalendarDate` is the one date implementation.** F07-FE uses it for D4 (the start date, rollover) and D6 (the streak arithmetic). No second date helper is added.
5. **The pool calendar — Technical decision:**
   * F07-CONTENT uses a **provisional calendar**: `numberingEpoch` 2026-11-01, 60 contiguous days 2026-11-01 … 2026-12-30 (#1 … #60).
   * The live first day is fixed at **F07's release gate** (F07-DEVOPS, with the Tech Lead). If it differs, the pool is re-dated as a block before the first publish. The re-date keeps the order and moves the ids, dates, file names and manifest together (a toolchain task opened then — DAILY-POOL-CALENDAR).
   * **After the first publish,** `numberingEpoch` and every published day never change (D2 (2): `#N` stable).
   * **Cadence:** the next batch must be published at least 8 days before the last covered day, because the client prefetches today … today + 7 (D3). Otherwise the Daily becomes `unavailable` — calm, never a crash. This is tracked as DAILY-POOL-CALENDAR.

**Routing:**

* **F07-CONTENT → Open** (Content Designer, Current Brief). Its dependency, F07-TOOL, is Done and accepted.
* **F07-FE stays Queued.** It is activated at the F07-CONTENT checkpoint, where the Tech Lead also opens the sign-off gate F07.DAILY-POOL-SIGNOFF. The user's review of the pool can then run while F07-FE builds.
* The contract is otherwise unchanged.
