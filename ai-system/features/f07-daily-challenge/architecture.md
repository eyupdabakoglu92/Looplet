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
* ~~F07.DAILY-POOL-SIGNOFF~~ — superseded 2026-09-30 by the user's incident (A5): content acceptance is measured by the roles (`daily-content-spec.md`).
* **[DEFERRED — Tech Lead, A8]** DAILY-DEEP-PROFILE: weekend optimum 6–7 (the `cNorm` node bound; workflow-follow-ups). The current profile is Fri–Sun optimum 5 (`daily-content-spec.md` revision 3).
* **[RESOLVED — acceptance model, A6]** F07.TARGET-LIST-APPROVAL — user-approved PO-REV-2026-09-30-CONTENT-QUALITY delegates routine acceptance to documented curation/checks and independent QA. The actual expanded corpus and pool remain unapproved until their evidence passes.

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

---

## A4. F07-CONTENT checkpoint (Tech Lead, 2026-09-29)

**Reconciliation of F07-CONTENT** (`content-design.md`; commit 9af777f):

* **Task coverage:** all four Current Brief items are delivered.
  1. 60 pool puzzles, `content/daily/tr/pool/daily-tr-2026-11-01.json` … `2026-12-30.json`, written by `export` (`contentVersion 2026-11-01.1`).
  2. 60 definitions at `tools/looplet_authoring/drafts/daily/tr/_defs/` (outside `content/`, A3 ruling 1).
  3. `content/daily/tr/daily_manifest_tr.json` — the locked shape, 60 contiguous assignments.
  4. `content-design.md` — the per-day table, the editorial targets, the commands and exit codes, the AI-drafted / not-playtested status, the known gaps.
* **Scope:** the commit touches only `content/daily/tr/`, the defs and the two F07 documents. No code, no tool, no app, no F08, no `content/journey/` change.
* **Contract compliance:** D2 (2) and (6); A3 rulings 1 (served-as-is), 3 (no definition repeats), 5 (the provisional calendar, #1 … #60); AC3 (5×5, 5-letter targets, columns on). The pool is `type: daily`, `lang tr` throughout.
* **Evidence read and re-run by the Tech Lead** (on 9af777f, clean tree):
  * `melos run content:check` → exit 0, 110 s (the delivery's 110 s; CI jobs set no `timeout-minutes`, so the +75 s is not a risk).
  * `pack-daily ../../content/daily/tr` → exit 0, `60 days 2026-11-01 … 2026-12-30, #1 … #60`; **54,106 bytes, sha256 `fb33384d…db31` — byte-identical to the delivery's pack**. Written to the scratchpad, not the repo.
  * **Independent negatives** on 5-day scratch copies (11-01 … 11-05), with an unmodified baseline → `check: OK`, exit 0:
    * a stale stored optimum (11-05: 5 → 4) → `stored optimalMoves 4 != fresh solve 5`, exit 1;
    * 11-05 carrying 11-01's definition → `duplicate puzzle definition` and `[noRepeat] … within 30 days`, exit 1;
    * 11-03 with `dailyDate` 11-04 → `check` `[puzzleDate]`, exit 1; `pack-daily` `[puzzleDate]`, `nothing written`, no output directory.
  * **The per-day table recomputed from the artifacts** (a read-only script): 60 / 60 rows match (date, `#N`, id, target, class, locked / frozen counts, `optimalMoves`, label, score). Every def matches its artifact (grid, target, locked, frozen). Every locked cell holds its target letter at its column.
  * **Editorial numbers confirmed:** 34 × opt 4, 26 × opt 5; 58 medium, 2 hard, 0 expert; columns on 60 / 60; 0 failing 7-day windows; the longest same-class run is 1; 30 distinct targets, each used exactly twice, 30 days apart; all 30 are eligible (with Turkish casing) and all 30 are Journey targets. Because 30 days is a weekday shift of 2, a word's two days always have different classes.
  * The 54 / 54 tool-test claim was not re-run: no code changed (scope above).
* **Tech Lead finding — frozen tiles that can never thaw.** A sound necessary-condition test: a frozen row can thaw only if some dictionary word of 4–5 letters fits a row window with the frozen letters at their fixed columns, **and** the other letters exist among the grid's non-frozen tiles. Failing it proves "never"; passing it does not prove a thaw is reachable.
  * **Daily:** 18 of the 26 days with frozen tiles can never thaw — 11-01, 11-04, 11-07, 11-08, 11-11, 11-14, 11-15, 11-21, 11-28, 11-29, 12-02, 12-05, 12-06, 12-09, 12-12, 12-16, 12-19, 12-27. On these days the frozen tile is a permanent pivot, like a locked tile.
  * **Journey correction:** L22 (no `A` in its grid) and L24 fail the same test, as well as the recorded L26, L27, L28 and L30. FROZEN-ROW-THAW-CONTENT said L21–L25 could thaw; it checked the frozen letter only. Recorded there; the Journey stays Done (the win never requires a thaw).
  * **Not a gate failure:** no product criterion or contract rule requires a frozen tile to be thawable, and every stored optimum is solver-proven with the frozen tiles in place.
* **Delivery Review: Accepted.** The delivery is complete and its evidence holds. Acceptance of the pool as product content is the user's sign-off (below).

**Rulings on `content-design.md` §6:**

1. **Target words (§6 item 2) — Technical ruling: 30 words, each used twice, accepted for the MVP pool, subject to the sign-off.**
   * "60 distinct targets, none a Journey target" was an editorial target in the Tech Lead's brief, not a product criterion. It is **withdrawn as infeasible** under the current corpus: `isEligibleTarget` accepts only the 30 Journey targets.
   * The product rule (product PRD F06: the pool must not duplicate Journey puzzles or repeat within a rolling window) is about puzzles. It holds and is gate-enforced: all 60 definitions are distinct from each other, from the Journey and from the smoke set.
   * The fix is a larger target list, F01-PRODUCTION-CORPUS. Days 31–60 can be re-authored from their defs, but **only before the first publish** (A3 ruling 5: published days never change).
2. **Locked and frozen tiles before the Journey teaches them (§6 item 3) — Hybrid, decided as an Assumption.**
   * The Daily ships all four mechanic classes from #1. The product sets no mechanic restriction on the Daily, and the Journey itself introduces locked (L16) and frozen (L21) tiles with no hint; only columns have a micro-tutorial (F05 §9).
   * The user's playtest tests this assumption. If the tiles confuse, the route is a Product Owner revision — for example, a first-encounter hint for locked / frozen tiles, which would also serve Journey L16 / L21 — not a content workaround. Any day is someone's first Daily, so re-ordering the pool does not solve it.
3. **Frozen thaw (Tech Lead finding above).** Consistent with the shipped Journey (6 of its 10 frozen levels cannot thaw either). Part of the sign-off; the root cause is the provisional 103-word dictionary (F01-PRODUCTION-CORPUS).
   * **Coupling recorded:** a thaw depends on the app's bundled dictionary, and a thaw can shorten the optimal path. The optimum of any content with frozen tiles is therefore proven only for the dictionary it was solved with. `content:check` re-solves every artifact, so CI catches a changed optimum before a publish. After the first Daily publish, though, a dictionary change in the app changes play on already published days. **Any dictionary asset change requires a Tech Lead impact check on the published Daily days and the Journey** (recorded in F01-PRODUCTION-CORPUS).
4. **Difficulty (§6 item 5):** medium / hard, never expert — met. No scorer re-tune in F07 (CONTENT-TOOLING-TUNING stays open).
5. **Frozen placement (§6 item 4)** and **the calendar (§6 item 6):** unchanged (A3 ruling 5).
6. **A playtest path — amends D2 (7) and D4 for debug builds only.** The pool is dated 2026-11-01 … 12-30, and the dev pack generator shifts only the dev fixture, so today nobody can play a pool day in the app.
   * F07-FE adds **`--dart-define=LOOPLET_DAILY_TODAY=YYYY-MM-DD`**: in a **debug** build it fixes the Daily's "today" for the whole process — the D3 triggers, the population window and eviction, the D4 start date and rollover, and the D6 displayed streak. Profile and release builds ignore it (a named negative test). Journey, durations and `completedAtUtcMs` are unaffected.
   * The D2 (7) pack override may point at the `pack-daily` output of the real pool. Prefer a host file path (`file://`) that the simulator can read, so that no App Transport Security change is needed. If only a plain `http://localhost` server works, report it before adding any ATS exception; none may reach release builds.
   * F07-FE documents the exact playtest recipe in `frontend.md` (build the pack, the two defines, the run command).
   * F07.FIRST-RUN-SYNC and the sync evidence use the real date, never the override.

**Decision gate F07.DAILY-POOL-SIGNOFF — opened** (orchestration → Open Decision Gates).

* **Blocking Scope `release`:** the sign-off is the precondition for publishing the pool. It blocks F07-DEVOPS, F07-QA-FINAL and Done, not F07-FE or functional QA (role-execution-contract §5.3; the A3 routing planned the review to run while F07-FE builds).
* A rework choice (options B / C) or a Product Owner revision (D) changes the pool, and so invalidates the content part of any functional QA evidence taken before it. The Tech Lead re-plans QA at that intake.

**Routing:** **F07-FE → Open** (Frontend/Mobile Developer, the orchestration Current Brief). F07-CONTENT is Done and accepted. The contract is otherwise unchanged.

---

## A5. Incident — content quality and the acceptance model (Tech Lead, 2026-09-30)

**Intake:** `Run Tech Lead. Incident:` by the user — content management must be done well by the roles and must not come to the user; the Content Designer's work was not good enough; the user asked for the content algorithm and exactly what is needed, and may improve the Content Designer role.

* **Classified Scope:** Existing Active Feature Rework (F07 content). **Root cause:** the Tech Lead's F07-CONTENT brief. It stated editorial targets without making them measured, rejecting rules; it made a user playtest the quality gate (a carry-over from F06's "human playtest" model); and it left the generator to a script outside the tools, although generators belong to a Developer (role-execution-contract). The Content Designer then delivered to the letter and handed the quality questions to the user.
* **Measured on the A4 pool** (Tech Lead, 2026-09-29 / 30, read-only scripts and the AOT-built CLI in the scratchpad):
  * filler rows holding a real dictionary word: **0 of 300**;
  * frozen-tile days that can never thaw: **18 of 26** (A4);
  * days needing a temporary displacement (`tdDegree ≥ 1`): **1 of 60**; `cNorm` ≤ 0.053 everywhere;
  * starts with a row already holding ≥ 3 target letters in place: **9 of 60**;
  * tiles removed (the first 9 tile days, 30 s solver budget): in **4 of the 5 conclusive cases** (#1, #3, #4, #8) the optimum is unchanged and the label falls from `medium` to `easy`; on #1 the tile-free optimal line `D2 R3 U2 R3` never touches the frozen row or columns, so the tiles are decorative; #7 is the one where tiles matter (3 → 4); 4 cases hit the budget (inconclusive). The run was stopped there; `audit-daily` measures this for every day (Q5).
  * The difficulty score adds +0.8 per locked and +1.2 per frozen tile whether or not the tile matters, so the labels overstate these days.
* **Workflow Impact: Re-route Current Flow.** F07-FE had not started (no app change since beb7bfe); it returns to Queued and stays independent of content.

**Rulings:**

1. **`daily-content-spec.md` is the content contract** for the Daily (Turkish, for the user and the Content Designer). Where it conflicts, it overrides the F07-CONTENT brief's editorial targets and A4 rulings 1 (30 targets × 2 is no longer accepted) and 3 (a frozen tile must be able to thaw, Q6). A4 ruling 6 (the debug today override) stays.
2. **Acceptance model:** content is accepted by measurement — the Developer's `audit-daily` (every §4 / §5 rule, with named negative tests), the Content Designer's delivery with the audit at exit 0, and QA's independent content module. **No user playtest.** The product PRD's authoring flow ("the designer playtests with real engine rules") is met by the Content Designer's `playtest` runs of the Q5 / Q6 proof lines. Quality questions go to the Tech Lead, never to the user.
3. **The corpus is expanded inside F07** (F07-CORPUS; F01-PRODUCTION-CORPUS brought into the ledger for Turkish): `targets` ≥ 120 (the 30 Journey targets unchanged), `words` ≥ 2,000. It is a content asset change; the app has not been distributed and no Daily is published, so now is the cheapest moment. **Cross-feature:** Journey levels whose optimum changes are re-exported from their defs (same grid and tiles; an F05 content change, verified by QA — F07.CORPUS-IMPACT); F01's tests must pass.
4. **The only product decision left for the user:** the product PRD F01 requires the targets to be "manually-approved" and both lists "manually reviewed". The Tech Lead cannot change that. Gate **F07.TARGET-LIST-APPROVAL** (`release`): (A) the user reads the lists (the ~2,000-word list is impractical), or (B) a Product Owner revision delegates the approval to the Content Designer's written rule set and scripted checks plus QA sampling.
5. **Tools:** `generate-daily` and `audit-daily` in `looplet_authoring` (F07-TOOL-DAILY, Frontend/Mobile Developer). `content:check` in CI is unchanged until the audit's runtime is measured.
6. **F07.DAILY-POOL-SIGNOFF — superseded** (RESOLVED): the A4 pool is not signed off. It stays in the repo so `content:check` stays green, is not publishable, and is replaced by F07-CONTENT-R1.
7. **Unchanged:** the product criteria; D1–D11; the calendar (A3 ruling 5); the Assumption on locked / frozen tiles from #1 (A4 ruling 2; a first-encounter hint would be a Product Owner revision, `daily-content-spec.md` §8).

**Routing:** F07-CORPUS Open (Content Designer) → the corpus checkpoint → F07-TOOL-DAILY (Frontend/Mobile Developer) → F07-CONTENT-R1 (Content Designer) → QA. F07-FE Queued; the Tech Lead activates it when the content chain allows.

---

## A6. User-approved content quality revision (2026-09-30)

**Authority:** the user's approval of the reviewed proposal in this chat. This is a product-policy/core-workflow revision and F07 contract resync; it does not certify the dictionary, pilot, pool or independent QA. A5's unresolved approval, corpus minimum and production sequence are superseded by the rules below; A4 remains historical evidence only.

1. **Acceptance:** product revision PO-REV-2026-09-30-CONTENT-QUALITY and F01 PRD/architecture are synchronized. F07.TARGET-LIST-APPROVAL is RESOLVED (strengthened B). All entries get source/exclusion/automated validation; Content Designer reviews all targets; QA independently reviews new targets and risk-stratified supporting words, expanding on critical defects. No new routine user sign-off. F08 deploy authorization is untouched.
2. **Quality ownership:** `prompt-content-quality-standard.md` applies. Content Designer owns editorial quality/preflight/pilot, Developer owns lasting tools, Tech Lead owns contract adequacy and gate transitions, QA owns independent validation. A known critical defect cannot be accepted merely because the previous AC omitted it.
3. **Contract:** `daily-content-spec.md` revision 2 is the current contract. It distinguishes Sbuild/S0/Send, validates real forward paths through irreversible thaw, checks mechanics separately, requires useful pre-win thaw, separates heuristic scores from proof, defines Q7 as a pool ratio and Q9 as advisory, and handles partial ISO weeks. Non-applied filters are explicit N/A; required UNKNOWN fails acceptance.
4. **Corpus:** ≥120 targets and 60 distinct non-Journey Daily targets remain required. ≥2,000 usable words is a research target to calibrate with source quality/pilot yield; padding with rare words is forbidden. Preserve legitimate existing words outside 4–5 letters; filter the production view rather than shrinking the general dictionary. Corpus validation is a permanent Developer tool. Dictionary changes require Journey/smoke/Daily re-solve, score/thaw review and bundle sync where exports change.
5. **Tools/pilot:** every search is bounded, including scoring and constrained/counterfactual searches. First calibrate and deliver a representative 8-example pilot; Tech Lead accepts its evidence before batch production. Full audit is mandatory before content acceptance/publishing even if expensive and separate from fast CI. Pack/publish must reject missing/stale full-audit evidence. These are pending Developer deliverables, not existing guarantees.
6. **Workflow:** adopt Content Quality Contract/Gate/Evidence, initially `daily-content-spec.md / Pending / None`. Activate F07-CONTENT-PREFLIGHT; tool → corpus → pilot → Tech Lead checkpoint → 60-day re-authoring. F07-FE remains independently queued under the single-owner workflow. No content task is marked complete just by this policy revision.

Historical snapshots: `../../history/f07-daily-challenge-2026-09-29/daily-content-spec-at-a5.md` and `orchestration-before-quality-revision.md` in that directory. Implementation/test evidence for the core change is recorded separately from content acceptance.

---

## A7. F07-TOOL-DAILY checkpoint (Tech Lead, 2026-09-30)

**Verdict: Delivery Review Pending — not accepted.** The tool logic reconciles with `daily-content-spec.md` revision 2, but the delivered pilot PASS is not reproducible on the delivery host, and the budgets make the contract's weekend profile unverifiable. A targeted Developer rework (F07-TOOL-DAILY-R1) is opened; F07-CORPUS stays Queued behind it.

**Re-run by the Tech Lead on 1032f8a** (scratchpad only; no repository file changed):

* `dart test`: `looplet_solver` 29 / 29, `looplet_authoring` 96 / 96; `dart analyze` (authoring) clean; `node --test ai-system/tools/tests/*.test.mjs` 93 / 93. Matches the delivery.
* `import-corpus` → staging: 517 words / 369 targets; `audit-corpus` on it PASS; on the runtime asset FAIL (expected — 103 / 30 unchanged).
* **Independent pack-gate negatives** on the superseded canonical pool: `pack-daily` without `--quality-report`, with the pilot report, and with `--development-fixture` — each exit 1, nothing written.
* **Pilot re-audit (`audit-daily` over `evidence/technical-pilot-v1`, the staging corpus, default budget), twice** — the first run concurrent with the test suites, the second on an idle host. `inputHash` and `analysisInputHash` are **identical** to the delivered report, and every file fingerprint matches. **Both runs: pilot FAIL, exit 1.** 7 of 8 days reproduce; **2026-11-04 (`lokma`, frozen, o = 5): Q4 and Q9 PASS → UNKNOWN**, `SearchLimitExceeded(optimal enumeration)`. The pool rule then fails (fewer than 8 accepted days).
* **Root cause, measured:** `Solver.enumerateOptimalSolutionsWithCoverage` for that day completes in **29.7 s against the 30 s budget** (33 optimal solutions, complete; the difficulty is identical to the export — medium, 5.2728). Its guard covers a full breadth-first ball of every state within depth o before the DFS, so the cost grows ~20^o. The delivered PASS was a wall-clock margin, not a property of the inputs.

**Reconciliation (DURUM 3.8):**

1. **Task coverage** — import/audit/impact, `generate-daily`, `audit-daily` Q1–Q12, bounded solver/scorer, fingerprints, fail-closed production pack and the 8-day pilot are all present. Incomplete item: reproducible pilot evidence.
2. **Contract compliance** — read, not only run: `searchWitness` is breadth-first (shortest witness) and `replay` requires a real engine win with no earlier win or rejected move; the Q5 equal-optimum branch refutes via the reference or a joint search in which both engines must win on the same move; Q6 requires a pre-win thaw of that row on a winning path ≤ o + 2; Q7 requires an optimal-length winning path moving an already-thawed letter (the win-move thaw does not count); the regression claim is an exhaustive non-decreasing search to depth o; Q10 reads the witness's final state; UNKNOWN never accepts. The batch path requires a current pilot PASS plus a Tech Lead acceptance record bound to the report hash. Compliant.
3. **Authority** — no conflict with A6 or revision 2. §3 already warns that time budgets can reject differently on different machines; it does not permit accepted evidence that the same host cannot reproduce.
4. **Preserved behavior** — the full existing `content/` check passes after the solver changes (delivery); the runtime dictionary is untouched; the difficulty result is unchanged when enumeration completes (verified on 2026-11-04).
5. **Evidence quality** — test counts and pack negatives reproduced; the pilot claim failed reproduction (above).

**Rulings:**

1. **Determinism (R1 scope).** An accepted verdict must not be decided by the wall clock. Node and depth limits are the deciding bounds; the time limit is an outer safety ceiling, and a stop caused by time is reported as UNKNOWN with its cause (`time` / `nodes` / `depth`) and the measured margin. The Developer may raise the time ceiling per analysis (up to 300 s) or change the algorithm, with measurements written in the delivery; the 5,000,000-node / depth-16 bounds and every quality threshold stay. Exit: the regenerated pilot re-audits to identical per-rule verdicts twice on the canonical host, once under concurrent load.
2. **Weekend profile feasibility (R1 scope).** §4 sets Fri–Sun optimum 5–7, but a breadth-first ball at depth 6–7 (~20^6–20^7 states) cannot fit 5,000,000 nodes, so enumeration (Q4), Q5 absence, the regression proof and the useful-thaw search would all return UNKNOWN for o ≥ 6 — the profile would silently shrink to o = 5. **This is an inference from the measured growth, not a measurement**; R1 measures it. The expected fix is sound pruning (for example an admissible lower bound from the solver's heuristic), proven by a named test that a pruned absence claim equals the exhaustive result on small fixtures. If o = 6–7 stays infeasible after that work, the Developer returns the measurements and the Tech Lead decides the profile as a contract change — the profile is never eased silently.
3. **Portability (R1 scope).** The report's `sourceDir` is an absolute host path and the batch gate re-fingerprints that path; it becomes repo-relative, with a negative test. The `runtime/dart` fingerprint entry (the full `Platform.version`) stays fail-closed: a production pack must be built with the same Dart runtime as its full audit, or be re-audited. This is recorded for F07-DEVOPS.
4. **Accepted as is:** the Q-rule logic above, the production-pack gate, the fixture separation, the bounded-generation CLI limits and the corpus import/audit tools.
5. **Carried into the F07-CORPUS brief (Content Designer, not tool defects):** the provisional curation carries category-template rationales ("Yaygın gündelik kavram…"), not the per-word meaning/rationale §2 requires; the exclusion list is a self-authored 12-word list, while Q11 requires a list with a named source and version, and its substring match (for example `sik`, `bok`) will over-reject — the Content Designer sources and versions the list and records the expected over-match; the staging corpus is 517 words / 369 targets against the ≥ 2,000 research target, and filler (Q10) and thaw yield must be measured, not assumed.

**Workflow impact: Continue current flow** with one inserted task. F07-TOOL-DAILY stays Done as a delivery; its review is Pending. F07-TOOL-DAILY-R1 (Frontend/Mobile Developer) Open → Tech Lead checkpoint → F07-CORPUS. Content Quality Gate Pending; F07-FE Queued; F08 paused.

## A8. F07-TOOL-DAILY-R1 checkpoint and the weekend profile (Tech Lead, 2026-09-30)

**Verdict: accepted.** F07-TOOL-DAILY and its rework R1 are accepted as tools (Delivery Review Accepted; F07.TOOL-DAILY-REVIEW PASS). The A7 symptom is closed and reproduced independently. The Developer's clarification about the weekend profile is decided below as a contract change (`daily-content-spec.md` revision 3).

**Re-run by the Tech Lead on 33c2b96** (scratchpad only; no repository file changed by the re-run):

* `dart analyze`: `looplet_solver` and `looplet_authoring` clean. `dart test`: solver **40 / 40**, authoring **105 / 105**. `node --test ai-system/tools/tests/*.test.mjs`: **93 / 93**. `melos run content:check`: SUCCESS (10.6 s).
* `import-corpus` → staging: 517 words / 369 targets (sha256 `2e0deda4…1d32`); `audit-corpus` PASS.
* **Pilot re-audit twice** (`audit-daily` over `evidence/technical-pilot-v1`, the staging corpus, the default budget): once concurrent with both `dart test` suites, once idle. Both **PASS, exit 0, 45 s**. `inputHash` / `analysisInputHash` are equal to the committed report, and with the timing fields removed **the two reports and the committed report are byte-identical** — per-rule verdicts, proofs, difficulty and per-phase peak nodes. 2026-11-04 (the A7 failure) is PASS. The committed report stores `sourceDir` repo-relative; its budget is 300 s / 5,000,000 nodes / depth 16.
* **Pack-gate negatives** on the superseded canonical pool: `pack-daily` without `--quality-report`, with the pilot report, and with `--development-fixture` — each exit 1, nothing written.
* Read, not only run: `pruning_soundness_test.dart` compares pruned solve / enumeration with the exhaustive search on 24 fixtures (all four mechanic classes, ≥ 3 optima), checks the bound for admissibility and consistency on every reachable state, and its negative — an inflated bound — is caught by the same comparison. `search_determinism_test.dart` does the same for every witness-search mode and rejects a report with an absolute source.

**Reconciliation (DURUM 3.8):**

1. **Task coverage** — R1 brief items 1–4 are closed: node / depth decide and time is an outer ceiling (≤ 300 s) with the stop cause, nodes and elapsed time on every UNKNOWN; o = 6 / 7 measured with sound pruning; `sourceDir` portable with a negative test and the README runtime note; the pilot regenerated and re-audited twice. Nothing is partial.
2. **Contract compliance** — `WinLowerBound` (`lower_bound.dart`) was checked by hand: a row move keeps the row's letter multiset, a column move changes one cell of a row, and a locked cell never changes, so `min(|M|, 1 + d)` is admissible; after a row-`r` move `|M'| ≥ d`, so the bound drops by at most one per move (consistent). Pruning therefore returns the same optima, solution lists and absence verdicts; the tests confirm it. No Q-rule, threshold, weight, label boundary or node / depth bound changed.
3. **Authority** — no conflict with A6 / A7 or revision 2. The Developer returned the profile question instead of narrowing it (A7 ruling 2).
4. **Preserved behavior** — `content:check` passes on all committed content; the 2026-11-04 difficulty is unchanged (medium 5.2728); every pilot day's difficulty equals the delivered report; the runtime dictionary, `content/` and the app are untouched.
5. **Evidence quality** — every delivery claim above was reproduced except the o = 6 / 7 table (`evidence/r1-depth-measurement.json`), a Developer measurement that takes hours and was not re-run. The profile decision does not depend on its exact figures (ruling 2).

**Rulings:**

1. **Accepted:** the stop-cause model, the 300 s ceiling, `WinLowerBound` pruning in solve / enumeration / witness searches, the portable report source and the regenerated technical pilot. The pilot stays Developer feasibility evidence (`independentQa: false`), not content or pilot acceptance. `tool/measure_search_depth.dart` is a diagnostic tool, not a gate.
2. **Weekend profile — Fri–Sun optimum exactly 5** (was 5–7; `daily-content-spec.md` revision 3 §4). Reasons: (a) `cNorm` counts every state within depth `o` by the F06 definition and cannot be pruned; at o = 5 it already reaches 0.49–0.91 M nodes (reproduced in the pilot report), and it exceeded the 5,000,000-node bound on all four measured o ≥ 6 candidates; (b) at o = 7 the Q6 thaw search (depth 9) also exceeds the bound; (c) the generator builds heavy days with 5 scramble moves and does not propose o ≥ 6 at all. The rejected options: changing the `cNorm` definition is an F06 contract change that re-scores Journey content (F05 / F06 impact) and is out of F07's scope; a larger bound for one phase is an extrapolation (o = 6 ≈ 4–14 M states, o = 7 ≈ 30–200 M) with a generator change on top, for a gain the pilot has not shown to matter. Weekend weight still comes from the mechanic (Fri locked, Sat both, Sun frozen), the medium / hard label and the unchanged hard + regression rhythm of every full ISO week; the pilot's hard 2026-11-14 day (o = 5) shows it is reachable. This is a reasoned contract decision under A7 ruling 2, not a failed pilot sliding to an easier profile; no other rule is eased.
3. **The profile must be checked explicitly — F07-TOOL-DAILY-R2.** Q3 (`daily_quality.dart`) still accepts heavy o = 5–7; today an o ≥ 6 day is rejected only because Q4 turns UNKNOWN at the node bound, which a future bound change would silently undo. R2 makes Q3 require o = 5 on Fri–Sun, with a named negative (a heavy o = 6 day FAILs Q3 with the profile reason, independent of Q4). `daily-content-spec.md` is part of the audit fingerprint (`quality_io.dart`), so revision 3 makes the committed technical-pilot report stale by design; R2 re-audits it once, and every verdict must stay the same (all pilot days have o ≤ 5).
4. **Unchanged:** the 5,000,000-node / depth-16 bounds, the F06 `cNorm` definition, all Q-rules and thresholds, the scorer weights and label cut points. o ≥ 6 is kept as the follow-up **DAILY-DEEP-PROFILE** (workflow-follow-ups) with the measured options.
5. **Carried into the F07-CORPUS brief:** A7 ruling 5 unchanged (per-word rationales, a sourced and versioned exclusion list with its over-match recorded, measured filler / thaw yield). The corpus changes the runtime dictionary (F01 / F05 impact), so F07-CORPUS returns to a Tech Lead checkpoint before the pilot.

**Workflow impact: Continue current flow** with one small inserted task. F07-TOOL-DAILY-R2 (Frontend/Mobile Developer) Open → planned direct handoff → F07-CORPUS (Content Designer; it does not use Q3) → Tech Lead checkpoint (corpus impact + R2 review, F07.TOOL-PROFILE-R2) → F07-CONTENT-PILOT → Tech Lead pilot checkpoint → F07-CONTENT-R1. Content Quality Gate Pending; F07-FE Queued; F08 paused.
