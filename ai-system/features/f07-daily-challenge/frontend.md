# F07 — daily-challenge: Frontend Delivery Report

Role: Frontend/Mobile Developer · Mode: Direct-edit

---

# F07-TOOL — the daily pack tooling (2026-09-29)

Base: `8cc28fc` + the uncommitted working tree listed in §2. Host: macOS (Darwin 24.6.0), Dart 3.8.1, melos 6.

## 1. Feature Summary

F07-TOOL is delivered per the Current Brief (architecture D2, D9; A1 ruling 1):

* **`DailyPack`** in `looplet_content` (pure Dart): the served-pack model, `fromJson` / `toJson`, and **one validator** — `DailyPack.validate` — that returns a **named** `DailyPackViolation` for every D2 (2) rule. `fromJson` runs it and throws `DailyPackFormatException` with every violation, so F07-FE can reuse it at fetch time.
* **`CalendarDate`** in `looplet_content`: strict `YYYY-MM-DD` parsing and date-part arithmetic (D4). The validator's day numbering and contiguity use it. It is exported so that F07-FE can use the same arithmetic for D4 / D6.
* **`looplet_authoring pack-daily`**: builds `daily_pack_{lang}.json` from `daily/{lang}/daily_manifest_{lang}.json` + `pool/`. By default the output goes to `<repo-root>/build/daily/` (git-ignored by `build/`). Any rule failure gives a non-zero exit with the named rule, and nothing is written. The output is deterministic: the same source gives the same bytes. The command refuses to write into its own source directory.
* **`check`** runs the same build on every Daily manifest. Every D2 (2) rule except `datesSorted` can now fail on the source; `datesSorted` holds by construction (see §3, F07-TOOL.3).
* **Tests with named negatives:** one per rule at the pack level (`looplet_content`) and at the source level (`looplet_authoring`), plus positive round-trips and the golden-byte determinism check.
* **A dev pack fixture:** 22 days (2026-10-01 … 2026-10-22 = anchor 2026-10-15 − 14 … + 7), built as `type: daily` copies of the smoke + Journey 1–17 definitions. It lives under `tools/looplet_authoring/test/fixtures/`, not under `content/daily/tr/pool/`. A generator produces a variant shifted to any "today".

No app code, no F08 change, no product Daily content, and no dependency or lockfile change.

---

## 2. Impacted Files

**Created**

* `packages/looplet_content/lib/src/calendar_date.dart` — `CalendarDate`
* `packages/looplet_content/lib/src/daily_pack.dart` — `DailyPack`, `DailyPackDay`, `DailyPackRule`, `DailyPackViolation`, `DailyPackFormatException`
* `packages/looplet_content/test/calendar_date_test.dart` (6 tests)
* `packages/looplet_content/test/daily_pack_test.dart` (21 tests)
* `tools/looplet_authoring/lib/src/daily_source.dart` — `buildDailyPack`, `DailySourceResult`, `encodeDailyPack`
* `tools/looplet_authoring/lib/src/daily_dev_fixture.dart` — `writeDailyDevFixture`
* `tools/looplet_authoring/tool/generate_daily_dev_fixture.dart` — the fixture generator CLI
* `tools/looplet_authoring/test/daily_pack_test.dart` (29 tests)
* `tools/looplet_authoring/test/fixtures/daily_dev/daily/tr/daily_manifest_tr.json` + `pool/daily-tr-2026-10-{01…22}.json` (22 files) — the dev source
* `tools/looplet_authoring/test/fixtures/daily_pack_tr.dev.golden.json` — the `pack-daily` output for the dev source (sha256 `790b5779…d605`)

**Updated**

* `packages/looplet_content/lib/looplet_content.dart` — exports `calendar_date.dart` and `daily_pack.dart`; library doc
* `tools/looplet_authoring/lib/src/cli.dart` — the `pack-daily` command
* `tools/looplet_authoring/lib/src/content_check.dart` — the Daily manifest + pool pack rules run through `buildDailyPack`
* `tools/looplet_authoring/lib/looplet_authoring.dart` — exports `daily_source.dart` and `daily_dev_fixture.dart`; library doc

---

## 3. Task-to-Code Traceability

**F07-TOOL — Complete.** Brief item by item:

* **F07-TOOL.1 — the `DailyPack` model** (`daily_pack.dart`)
  * The fields `schemaVersion` (1), `contentVersion`, `lang`, `numberingEpoch` and `days` (`dailyDate`, `dailyNumber`, `puzzle`).
  * `toJson` writes lowerCamelCase keys in the D2 (1) order; the puzzle goes through `Puzzle.toJson`.
  * `fromJson` validates first and ignores unknown keys.
  * Helpers: `dayFor(date)`, `DailyPack.dailyIdFor(lang, date)`, `DailyPack.dailyNumberFor(epoch, date)`, `DailyPack.definitionKey(puzzle)`.
  * `DailyPack.validate(json, {noRepeatWindowDays = 30})` never throws. It returns `DailyPackViolation(rule, message, dailyDate)`, printed as `[rule] date: message`. The rules are:

    | `DailyPackRule` | D2 (2) rule |
    | --- | --- |
    | `datesSorted` | `days` sorted by `dailyDate` (checked in pack order) |
    | `datesContiguous` | no missing date between the first and last day (each gap named) |
    | `datesUnique` | no date twice |
    | `puzzleDate` | `puzzle.dailyDate == dailyDate` |
    | `puzzleType` | `puzzle.puzzleType == daily` |
    | `puzzleId` | `puzzle.id == "daily-{lang}-{dailyDate}"` |
    | `puzzleParses` | the puzzle parses as a `Puzzle` |
    | `puzzleSolved` | `optimalMoves ≥ 1` |
    | `dailyNumber` | `== CalendarDate(epoch).daysUntil(date) + 1`, and no day before the epoch |
    | `noRepeat` | no puzzle definition (grid, target, locked, frozen, columns) repeats within the window; exactly 30 days apart is allowed |
    | `lang` | `puzzle.language == lang` |
    | `format` | the envelope: schemaVersion 1, a non-empty contentVersion, a supported lang, a valid epoch, a non-empty `days` of objects with a strict date and an int number |

  * Date arithmetic is `CalendarDate`: a UTC midnight on the date parts, never local 24-hour spans (D4). It is tested across the EU and US DST days, leap days and year boundaries.
* **F07-TOOL.2 — `pack-daily`** (`cli.dart` `_PackDailyCommand`; `daily_source.dart` `buildDailyPack`, `encodeDailyPack`)
  * Usage: `pack-daily <daily/<lang> dir | manifest.json> [--out <path>] [--repo-root .] [--window-days 30]`.
  * Default output: `<repo-root>/build/daily/daily_pack_<lang>.json`. `git check-ignore` confirms that `build/` ignores it.
  * On any failure it prints `pack-daily FAIL: [rule] …` for each failure, then `N failure(s); nothing written`, and exits 1.
  * It refuses an `--out` inside the source directory (exit 1).
  * Determinism: days are emitted sorted by date and numbered from the manifest's `numberingEpoch`; each puzzle is re-serialized by `Puzzle.toJson` (sorted coordinates); the file is two-space JSON with a final newline. Two runs are byte-identical and equal the committed golden.
* **F07-TOOL.3 — `check` extended** (`content_check.dart`)
  * Every file with `assignments` (a Daily manifest, as before) now also goes through `buildDailyPack`. Its failures are reported as `<manifest path>: [rule] …`.
  * Source-level coverage of the D2 (2) rules:
    * `datesUnique` — a date key twice in the manifest. JSON decoding keeps the last key, so duplicates are counted while decoding.
    * `datesContiguous` — a gap in the assignments.
    * `puzzleParses`, `puzzleSolved`, `puzzleType`, `puzzleDate`, `puzzleId`, `lang` — from the pool puzzle.
    * `dailyNumber` — an assigned date before `numberingEpoch`.
    * `noRepeat` — two pool files with one definition inside the window.
  * **`datesSorted` cannot fail on a source:** the assignments are a JSON object, and the pack is sorted by construction. A test proves that reversing the key order gives the golden bytes. Its negative is at the pack level.
  * Source-only problems are tagged `[manifest]`: the manifest's shape, name or place; an assignment that matches no pool puzzle; one id in two pool files. A broken pool file that nothing assigns is still reported (`[puzzleParses] pool/<file>`).
* **F07-TOOL.4 — tests with named negatives:** listed in §17. Each negative asserts that its rule, and only that rule, fails.
* **F07-TOOL.5 — the dev pack** (`daily_dev_fixture.dart`, `tool/generate_daily_dev_fixture.dart`, `test/fixtures/daily_dev/`, the golden)
  * 22 days from anchor − 14 to anchor + 7, with the anchor at 2026-10-15 and `numberingEpoch` 2026-10-01 (#1 … #22; the anchor is #15).
  * The days copy the 5 smoke definitions, then Journey 1–17, in a fixed order, as `type: daily` with `id daily-tr-<date>`, `contentVersion dev-fixture` and no `journeyLevelNumber`.
  * **Shiftable variant:** `--anchor <date>` (and optionally `--epoch`) regenerates the fixture around any "today". F07-FE and QA can use it for runtime on the real date.
  * It is test data, not product content. It is outside `content/`, so `content:check` and F07-CONTENT's pool never see it.
* **F07-TOOL.6 — this section.**

---

## 5. Components

* **`CalendarDate`** (`looplet_content`, new public API)
  * `tryParse` is strict: it rejects `2026-10-1`, dates that do not exist, and timestamps.
  * `fromLocal(DateTime)` gives the device-local date (D4 "dailyDate = the local date when the run starts").
  * Also: `addDays`, `daysUntil`, ordering and `toString` as `YYYY-MM-DD`.
* **`DailyPack` / `DailyPackDay` / `DailyPackRule` / `DailyPackViolation` / `DailyPackFormatException`** (`looplet_content`, new public API). This is the single validator for build time and fetch time (D9).
* **`buildDailyPack(manifestPath)` → `DailySourceResult(pack?, failures)`** (`looplet_authoring`) — the source reader, shared by `pack-daily` and `check`.
* **`writeDailyDevFixture(...)`** (`looplet_authoring`) — the dev source generator.

---

## 9. Contract Compliance Check

* **D2 (1), the served pack shape — Preserved.** The keys, lowerCamelCase, nesting and a full `Puzzle` per day are as specified; no optional field is added.
* **D2 (2), the rules — Preserved, and made explicit.** Every listed rule has a named check and a negative (see §14 for the two interpretations).
* **D2 (6), the authoring side — Preserved.** The pool is under `content/daily/{lang}/pool/`; the manifest is `content/daily/{lang}/daily_manifest_{lang}.json` with `numberingEpoch` + `assignments: {date: id or file}`; the output is outside the source.
* **D4, date arithmetic — Preserved.** Calendar dates only; tested on DST, leap-day and year boundaries.
* **D9, validation responsibility — Preserved.** The authoring side runs D2 (2) at build time through `check` and `pack-daily`. The client-side validator exists (`DailyPack.fromJson` / `validate`); wiring it into the fetch is F07-FE.
* **A1 ruling 1, the day envelope — Preserved.** A `DailyPackDay` carries `dailyNumber` + `puzzle`, and `dailyNumberFor` is the numbering rule the cache row must match. The envelope write and read are F07-FE.
* **F06 `Puzzle` contract — Preserved.** No change to `puzzle.dart`.
* **F08 client surface — Not applicable.** Untouched.
* **Screen / route, navigation, UI state, async lifecycle — Not applicable.** This is tooling; there is no app code.

---

## Visual Parity Evidence

Not applicable to F07-TOOL: it has no UI surface. F07-FE owns the Visual Parity Evidence against `F07-A-*`.

---

## 10. Behavior Preserved

* **The existing `check` rules are unchanged:**
  * the Puzzle schema;
  * `optimalMoves` against a fresh solve, and the trivial / unsolvable cases;
  * target eligibility;
  * the Journey 1–3 columns rule and the difficulty bands;
  * the duplicate-definition rule across all artifacts (so Journey ↔ Daily is still enforced);
  * Journey-manifest recognition by path + shape;
  * **the original id-based 30-day no-repeat over `assignments`.** It still runs first and still prints `repeats within 30 days`; the new build adds its failures after it.
* **Every F06 test passes unchanged,** including `catches a Daily manifest that repeats a puzzle within the window`. Its `manifest.json` now also reports `[manifest]` shape failures, but the test asserts that its own message is present, and it is.
* **`melos run content:check` over the real `content/` still exits 0.** `content/daily/tr/pool/` holds only `.gitkeep` and there is no Daily manifest yet, so the new rules have nothing to read. They start to apply when F07-CONTENT commits the manifest.
* **The other commands are untouched:** `solve`, `playtest`, `export` and `fill`.

---

## 14. Assumptions

1. **Pool puzzles are served as they are (no rewriting).** A pool file must already be the day's puzzle: `puzzleType: daily`, `dailyDate` = the assigned date, `id` = `daily-{lang}-{date}`. `pack-daily` only assembles, numbers and validates. This makes every per-day D2 (2) rule checkable on the source (the brief's item 3), and it keeps the served puzzle byte-traceable to one committed file. It has a consequence — see §16.
2. **The manifest shape** (not spelled out beyond D2 (6)):
   * `{ schemaVersion: 1, lang, contentVersion, numberingEpoch, assignments }`;
   * the pack's `contentVersion` comes from the manifest;
   * the manifest must sit at `<lang>/daily_manifest_<lang>.json`, with `pool/` beside it.
3. **Two readings of D2 (2), recorded:**
   * a day before `numberingEpoch` fails `dailyNumber` (`#0` / `#-1` do not exist, even when numbered consistently);
   * an empty `days` fails `format`.

   The no-repeat window counts calendar days: 29 days apart is a repeat, 30 is allowed, matching F06's existing check.
4. **`CalendarDate` is new public API in `looplet_content`.** It is additive. It is exported for F07-FE's D4 / D6 so that the date logic has one implementation.

---

## 16. Needs Tech Lead Clarification

Non-blocking; nothing in F07-TOOL waits on it.

* **Reusing a Daily definition later is effectively impossible today.** F06's existing duplicate-definition rule in `check` flags any two identical artifacts under `content/`. Under assumption 1, a definition used again after 30 days would be a second, identical pool file, so it fails `check`. The 30-day window is enforced, but the effective policy is "never repeat".
  * This is fine for F07-CONTENT (about 60 puzzles for about 60 days).
  * If reuse is wanted after the pool runs out, it needs a ruling. Options: exempt same-definition Daily pool files that are ≥ 30 days apart from the dedup rule, or let `pack-daily` stamp id / date onto a reusable pool puzzle.

---

## Notes for the Content Designer (F07-CONTENT)

* **Layout:**
  * `content/daily/tr/daily_manifest_tr.json`;
  * one pool file per day, `content/daily/tr/pool/daily-tr-YYYY-MM-DD.json`.
* **The manifest:**
  ```json
  {
    "schemaVersion": 1,
    "lang": "tr",
    "contentVersion": "2026-10-01.1",
    "numberingEpoch": "2026-10-01",
    "assignments": { "2026-10-01": "daily-tr-2026-10-01", "2026-10-02": "daily-tr-2026-10-02.json" }
  }
  ```
  * An assignment names the pool puzzle's `id`, or its file under `pool/` (ends in `.json`).
  * Dates must be contiguous, and none may come before `numberingEpoch`.
  * `numberingEpoch` fixes `#N` for good: **do not change it after the first release.**
* **A pool puzzle:** `export` it from a def with `"puzzleType": "daily"`, `"dailyDate": "YYYY-MM-DD"`, `"id": "daily-tr-YYYY-MM-DD"`, `"language": "tr"`:
  ```sh
  cd tools/looplet_authoring
  dart run bin/looplet_authoring.dart export <def.json> --repo-root ../.. \
    --out ../../content/daily/tr/pool/daily-tr-2026-10-01.json --content-version 2026-10-01.1
  ```
* **Gates, both of which must exit 0:**
  ```sh
  dart run bin/looplet_authoring.dart check ../../content/daily/tr --repo-root ../..
  dart run bin/looplet_authoring.dart pack-daily ../../content/daily/tr --repo-root ../..
  ```
  * `pack-daily` writes `build/daily/daily_pack_tr.json`, which is not committed.
  * `melos run content:check` runs the same rules in CI.
* **Rules that apply to the whole pool:**
  * no pool puzzle may duplicate a Journey or smoke definition, or another pool puzzle (§16);
  * every target must be dictionary-eligible;
  * the stored `optimalMoves` must match a fresh solve.

## Notes for F07-FE

* **At fetch:** use `DailyPack.fromJson(json)`. Catch `DailyPackFormatException`, log `daily_pack_invalid` with `violations`, and derive `unavailable` (D3).
* **The cache envelope (A1 ruling 1):** `{"dailyNumber": day.dailyNumber, "puzzle": day.puzzle.toJson()}`. On read, check `dailyNumber` with `DailyPack.dailyNumberFor(CalendarDate.tryParse(numberingEpoch)!, date)` if the epoch is known; otherwise use the stored number.
* **Dev pack for runtime on the real date:**
  ```sh
  cd tools/looplet_authoring
  dart run tool/generate_daily_dev_fixture.dart --anchor "$(date +%F)" --epoch 2026-10-01 --out ../../build/daily/dev-source
  dart run bin/looplet_authoring.dart pack-daily ../../build/daily/dev-source/daily/tr --repo-root ../..
  ```
  Then serve `build/daily/` (D2 (7) `LOOPLET_DAILY_PACK_URL`).

---

## 17. Test Evidence by Task

All runs were on this host on 2026-09-29, over the working tree in §2. They are not CI runs.

| Task / behaviour | Type | Command / target | Result | Proves |
| --- | --- | --- | --- | --- |
| F07-TOOL.1 pack rules | unit | `cd packages/looplet_content && dart test` | exit 0, **44 passed** (17 existing + 27 new) | one named negative per rule — `datesSorted`, `datesContiguous`, `datesUnique`, `puzzleDate`, `puzzleType`, `puzzleId`, `puzzleParses`, `puzzleSolved`, `dailyNumber` (off by one; before the epoch, twice), `noRepeat` (29 days; the window as a parameter), `lang`, `format` (8 envelope cases); each asserts its rule set `== {rule}`. Positives: a clean pack, `fromJson`/`toJson` deep equality and a byte round-trip, `dayFor`, stable numbering in a later pack (#51), DST / leap / year-boundary packs, a repeat allowed at exactly 30 days, `DailyPackFormatException` naming several rules |
| F07-TOOL.1 date arithmetic | unit | same run, `calendar_date_test.dart` | 6 passed | strict parsing (13 rejects, the leap-day accept); `addDays` across month, year and leap boundaries; `daysUntil` across EU / US DST days, 365 / 366; `fromLocal`; ordering |
| F07-TOOL.2 / .3 / .5 | unit + CLI | `cd tools/looplet_authoring && dart test` | exit 0, **54 passed** (25 existing + 29 new), 18 s | the dev fixture regenerates byte for byte (23 files); it covers anchor − 14 … + 7 as #1 … #22; the shifted variant (anchor 2028-03-01, the leap day inside, epoch kept) builds clean; **`check test/fixtures/daily_dev` exits 0** (fresh solve of all 22); `pack-daily` twice equals the golden bytes, and the output parses with `DailyPack.fromJson`; default output path; key order does not change the bytes; refuses with `[lang]`, exit 1 and no file; refuses to write into the source; a directory without a manifest exits 1 |
| F07-TOOL.3 named negatives on the source | unit | same run, group `named negatives on the source` | 11 passed | the unedited source is clean (baseline); then one negative each for `datesUnique` (the planted duplicate is asserted to exist first — the test caught its own no-op edit during development), `datesContiguous`, `puzzleParses`, `puzzleSolved`, `puzzleType`, `puzzleDate`, `puzzleId`, `dailyNumber`, `noRepeat` (exact message), `lang` — each `== {rule}` |
| F07-TOOL.3 source-only problems | unit | group `manifest problems` | 5 passed | an unknown reference; missing `numberingEpoch` / `lang` / `contentVersion`; a wrong manifest name; one id in two files; an unassigned broken pool file |
| F07-TOOL.3 through `check` | integration (solver + dictionary) | group `check runs the pack rules` | 3 passed | a clean 5-day source under `content/` passes; `[puzzleDate]` is reported with the manifest path; a date gap fails `check`, not only `pack-daily` |
| Existing `check` behaviour | unit | the F06 tests in the same run | 25 passed, unchanged | §10 |
| `pack-daily` on the dev fixture (by hand) | CLI | `dart run bin/looplet_authoring.dart pack-daily test/fixtures/daily_dev/daily/tr --repo-root ../..` | exit 0; `wrote ../../build/daily/daily_pack_tr.json (tr, 22 days 2026-10-01 … 2026-10-22, #1 … #22, …)`; sha256 `790b5779…d605` = the golden | the brief's item 6 command |
| `pack-daily` negative (by hand) | CLI | the generator into the scratchpad, then pool 10-06 `language: en`, then `pack-daily … --out <scratch>/neg-out/daily_pack_tr.json` | exit 1; `pack-daily FAIL: [lang] 2026-10-06: puzzle.language "en" != pack lang "tr"`; `nothing written`; the out dir does not exist | a non-zero exit with the named violation |
| Workspace gates | static / suite | `melos run format:check` · `melos run analyze` · `melos run test` · `melos run content:check` | all exit 0. analyze: no errors or warnings (2 pre-existing `curly_braces` infos in `solver.dart:56` and `content_check.dart:204`, the Journey-manifest helper from before this task). test: core 22, dictionary 32, content 44, solver 23, engine 83, authoring 54, app **588** — all passed. content:check over `content/`: SUCCESS | no regression anywhere; the new `looplet_content` exports do not clash in the app |

**Limits:**

* No CI run: nothing was pushed.
* No runtime or device evidence was needed: tooling only, with no app startup graph touched.
* The build output `build/daily/` was removed after the hand runs.

---

## WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed:** F07-TOOL.
* **Remaining:**
  * F07-CONTENT (Content Designer; its dependency F07-TOOL is now Done);
  * F07-FE (Frontend/Mobile Developer; after the Tech Lead reconciliation, per the brief);
  * F07-QA-FUNCTIONAL, F07-DEVOPS (Blocked), F07-QA-FINAL.
* **Blockers:** none. §16 is a non-blocking policy note.
* **Status suggestion:** Needs Tech Lead Review. The brief routes F07-TOOL to a Tech Lead reconciliation, and there is no Handoff Plan.

## 19. Sonraki Komut

Run Tech Lead
