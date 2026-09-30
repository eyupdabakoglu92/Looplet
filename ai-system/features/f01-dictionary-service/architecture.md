# F01 — dictionary-service: Architecture

> Status: CONTRACT AUTHORITY. Delivery artifacts and QA notes do not override the semantics defined here.

---

## Purpose

* **Feature objective:** Provide `looplet_dictionary` — a pure-Dart package that answers "is this a valid, allowed word in language L?" and "is this an eligible target word?", with correct Turkish-locale case handling, behind a language-keyed API.
* **Contract scope:** the package's public Dart API, the bundled asset format, the Turkish normalization specification, fail-safe semantics, and the `looplet_core` case utility this feature introduces.
* **Non-goals:** word-corpus content sourcing, English content, any UI, frozen-tile row-scanning logic (F02), remote/OTA dictionary updates, fuzzy matching.

---

## Authorities & Inputs

* Upstream PRD: `features/f01-dictionary-service/prd.md`; product PRD §6.1 (F01), §23 (Dictionary), §24 (Turkish Character Support).
* Inherited contracts: none (first feature).
* Project authority dependencies: `/ai-system/project-authority/platform.md` §3 (monorepo layout, pure-Dart packages), §11 (Turkish locale HARD RULE, naming, localization). Release: `none` (see `project-authority/release.md` §2).

---

## Actors & Permissions

| Actor | Allowed Actions | Forbidden Actions | Notes |
| --- | --- | --- | --- |
| `looplet_engine` (F02) | call `isValidWord(candidate, minLength: 4)` for frozen-tile row substrings | reimplementing normalization; caching validity across a language switch | consumes only the public API |
| `looplet_solver` / `tools/looplet_authoring` (F06) | call `isValidWord`, `isEligibleTarget`; read the target-word list | mutating assets at runtime | authoring-time use |
| `app` | construct the service, switch language, inject a logger | calling `dart:core` `toUpperCase/toLowerCase` on letters for game logic | owns the service lifecycle/provider |
| F13 daily-share | — | calling this package to render or reveal any word | share output must remain spoiler-free |

---

## Entry / Exit Paths

### Allowed Entry Paths

* `DictionaryService.load(language: LanguageCode, assetBundle: DictionaryAssetSource, {DictionaryLogger? logger})` — async factory; loads and indexes the asset for one language.
* `service.switchLanguage(LanguageCode)` — async; swaps the active index; previous language's data is released.
* Synchronous queries after a successful (or fail-safe) load: `isValidWord`, `isEligibleTarget`, `normalize`.

### Exit / Completion Paths

* `load` completes with a ready service (indexed) **or** a fail-safe service (empty index + logged diagnostic). Both are valid completions; `load` never throws for a missing/corrupt asset.
* `service.dispose()` releases in-memory structures.

### Invalid / Rejected / Terminal Paths

* Unsupported `LanguageCode` with no bundled asset → fail-safe service for that language + `logger.warn('dictionary.asset.missing', ...)`; queries return `false`.
* Corrupt/unparseable asset → fail-safe service + `logger.error('dictionary.asset.corrupt', ...)`; queries return `false`.
* Malformed candidate (non-letter chars, empty, whitespace) → query returns `false` without a list scan; never throws.
* Calling queries before `load` resolves → a `StateError` (programmer error; distinct from the missing-asset fail-safe path).

---

## Data / Domain Model

* **Key entities:**
  * `LanguageCode` — enum-like (`tr`, `en`), string value matches `looplet_content` locale keys and Flutter `gen-l10n`.
  * `DictionaryAsset` — the on-disk representation for one language: `{ schemaVersion, language, words[], targets[], exclusionsApplied[] }` (see Asset Format below).
  * In-memory index (implementation-owned): a validity lookup + a target lookup, keyed by the **normalized** form.
* **Critical identifiers:** `language` is the partition key. All lookups are `(language, normalizedWord)`.
* **Persistence rules:** none at runtime — the asset is bundled, read-only, loaded once per language. No writes, no cache files.
* **Reset / hydration rules:** `switchLanguage` fully replaces the active index (no merge, no residual entries from the prior language). A fail-safe load is not retried automatically.

### Asset Format (CONTRACT)

* Location: `packages/looplet_dictionary/assets/<language>/dictionary.json` (and an `en` stub).
* Shape:

```json
{
  "schemaVersion": 1,
  "language": "tr",
  "words": ["masal", "kitap", "..."],
  "targets": ["masal", "kalem", "..."],
  "exclusionsApplied": ["proper-nouns", "profanity", "abbreviations", "archaic-default-off"]
}
```

* `words`: every entry is already **normalized** (Turkish-normalized form, see below), lowercase-normalized per the Turkish map, deduplicated, sorted. No spaces, hyphens, digits, or empty strings. The build/authoring step guarantees this.
* `targets`: a subset of `words`; every entry is exactly 5 letters for the MVP. Acceptance follows PO-REV-2026-09-30-CONTENT-QUALITY: documented provenance/exclusions, full automated checks, reasoned Content Designer target review and independent QA. The expanded corpus and cross-feature effect are delivered under F07 daily-content-spec revision 2; no runtime API/schema change.
* `exclusionsApplied`: documentation of which curation filters produced this asset (informational; surfaced in diagnostics).
* The runtime **also normalizes** at load (defensive) so a hand-edited asset cannot break the index.
* Implementation MAY transform this JSON into a more compact in-memory or pre-baked structure (e.g. a `Set` of normalized keys, or a packed sorted blob) as long as every Acceptance Criterion and the footprint/latency metrics hold. The JSON above is the authored/source contract; the in-memory representation is an Open Technical Decision resolved by the Frontend/Mobile Developer against a measured footprint target and recorded in `frontend.md`.

### Turkish Normalization (CONTRACT — lives in `looplet_core`)

* `TurkishCase.toLowerTr(String)` / `TurkishCase.toUpperTr(String)` with the explicit map:
  * `I → ı`, `İ → i`, `ı → I`, `i → İ`
  * `Ç↔ç`, `Ğ↔ğ`, `Ö↔ö`, `Ş↔ş`, `Ü↔ü` (standard pairs)
  * all other letters via ordinary casing
* `normalize(String)` used by the dictionary = `toLowerTr` + trim + reject if any character is not a Turkish/Latin letter.
* **Hard rule:** `İ` and `I` normalize to different code points (`i` vs `ı`) and therefore to different lookup keys. `"İL"` and `"IL"` are never the same key.
* Circumflex vowels (`â î û`): treated as **distinct letters** (not stripped) unless the curated asset itself omits circumflex forms. Normalization does not remove circumflex. (Tracks the F01 PRD Open Question; default locked here.)
* For `en`, the service uses ordinary Unicode lowercasing (no Turkish map).

---

## API / Event Contract

### Public API (`package:looplet_dictionary`)

```dart
enum LanguageCode { tr, en }

abstract class DictionaryAssetSource {
  Future<String> readAsset(String path); // Flutter app injects a rootBundle-backed impl; tests inject fakes
}

abstract class DictionaryLogger {
  void warn(String code, {Map<String, Object?> data});
  void error(String code, {Object? error, StackTrace? stackTrace, Map<String, Object?> data});
}

class DictionaryService {
  static Future<DictionaryService> load({
    required LanguageCode language,
    required DictionaryAssetSource assetSource,
    DictionaryLogger? logger,
  });

  LanguageCode get language;
  bool get isFailSafe; // true when the asset was missing/corrupt/empty

  Future<void> switchLanguage(LanguageCode language);

  /// Returns true iff [candidate] normalizes to a letters-only string of
  /// length >= [minLength] that exists in the active language's word list.
  bool isValidWord(String candidate, {int minLength = 1});

  /// Returns true iff [candidate] normalizes to an entry in the active
  /// language's curated target list.
  bool isEligibleTarget(String candidate);

  /// Exposes the normalization used internally (for F02/F06 to build
  /// candidates consistently). Returns null if [input] contains a non-letter.
  String? normalize(String input);

  Future<void> dispose();
}
```

### Events / Async Inputs

* None. No streams, no listeners. Language switch is an explicit imperative call.

### Request / Response Rules

* `isValidWord` / `isEligibleTarget` are **pure and synchronous**; equal inputs (any casing of the same letter sequence) always yield equal results within a fixed active language + asset.
* `minLength` default is `1`; F02 always passes `minLength: 4` for frozen-tile checks.
* `normalize` returns `null` (not throw, not empty string) for input containing any non-letter character.
* No `null` is ever returned from the boolean methods.

### Error Semantics

* `dictionary.asset.missing` (warn) — no bundled asset for the requested language; service is fail-safe.
* `dictionary.asset.corrupt` (error) — asset present but JSON/shape invalid; service is fail-safe.
* `dictionary.asset.empty` (warn) — asset valid but `words` empty; service behaves as fail-safe.
* `StateError` — query called before `load` completed, or after `dispose()`. This is a caller bug, not a data condition.

---

## Validation Responsibility

* **Package validation:** normalization, letter-only enforcement, length rule, membership lookup, fail-safe fallback, dedupe/sort/normalize-on-load.
* **Caller validation:** F02 is responsible for extracting the correct contiguous left-to-right row substring(s) to test; F06 is responsible for choosing which words to feed as targets. F01 does not know about grids.
* **Ownership boundary:** F01 owns "is this a word / target". It never owns "where in the grid" or "did the player win".

---

## State / Flow Semantics

* Happy path: `load(tr)` → indexed service → many synchronous `isValidWord` calls during play.
* Boundary transitions: `switchLanguage` atomically replaces the active index; in-flight synchronous calls cannot observe a half-swapped state (swap is a single field assignment after the new index is fully built).
* Ordering / retry / timeout: n/a — synchronous pure functions; `load`/`switchLanguage` have no retry (a fail-safe result is terminal until the caller reconstructs the service).
* No-op / duplicate: `switchLanguage(currentLanguage)` is a no-op that still returns a completed future. Repeated identical queries are idempotent.
* Terminal state: a fail-safe service stays fail-safe; `isFailSafe == true`; all lookups return `false`. The app MAY surface this to diagnostics but the game must remain playable (frozen tiles simply never thaw via an invalid asset — an authoring/build defect, caught in CI, not a runtime user path).
* Realtime / background: none.

---

## Integration Rules

* Backend → frontend mapping: n/a (no backend).
* The Flutter app provides the concrete `DictionaryAssetSource` (backed by `rootBundle`) and `DictionaryLogger` (backed by the app logger / Crashlytics non-fatal). Tests provide fakes.
* Asset bundling: `looplet_dictionary` declares its own asset files in its `pubspec.yaml` `flutter:` `assets:` section (a package that ships assets — the package stays free of a `flutter` SDK dependency). The app therefore gets them in the bundle automatically and reads them at the key `packages/looplet_dictionary/assets/<lang>/dictionary.json` (= `LanguageCode.assetPath`). The app pubspec does **not** re-declare these assets. (Impl decision reconciled 2026-09-05 — the app-side directory declaration form does not resolve a dependency's assets in Flutter.)
* `looplet_dictionary` depends on `looplet_core` only. It must not depend on `flutter`, `looplet_engine`, `looplet_content`, or any Firebase package.
* The service instance is owned by an app-level Riverpod provider (session-level, not screen-level); screens never construct or dispose it.
* Navigation / route contract: n/a (no UI).

---

## QA Focus

* **Acceptance criteria coverage:** every AC in the F01 PRD mapped to a package test.
* **Critical journey:** frozen-tile validation path — a 4/5-letter Turkish word in any casing validates; a non-word / excluded word does not; a 3-letter candidate with `minLength: 4` is rejected without a scan.
* **Turkish correctness:** `İ ≠ I` produces different keys; all-caps == lowercase == mixed-case for the same sequence; full `Ç Ğ İ I Ö Ş Ü` normalization table.
* **Fail-safe:** missing asset, corrupt asset, empty asset → no throw, `isFailSafe == true`, all lookups `false`, correct diagnostic code logged.
* **Language isolation:** `en` service does not see `tr` entries; `switchLanguage` leaves no residue.
* **Robustness:** non-letter input, empty/whitespace, over-long candidate → `false`, no throw.
* **Evidence class:** `automated functional` (pure-Dart `dart test` suite). No device runtime required for this feature.
* QA scope for F01: **client-only** (package-level), source + automated tests.

---

## Release / Deployment Impact

* Release scope: **none**. `looplet_dictionary` is an internal library with no distributable surface; it ships inside the app later.
* Required release gates: standard CI gates only (format, analyze, `dart test`).
* Environment/config impact: none.
* Migration/rollback impact: none (bundled read-only asset; `schemaVersion` reserved for future format changes).
* Observability/smoke validation impact: fail-safe diagnostics route to the app logger once wired; no release smoke step for F01 itself.
* Boundary matrix: no actors with elevated permissions; no misuse surface beyond malformed input (covered in QA Focus).
* Runtime evidence expectation: none — automated test evidence is sufficient per `platform.md` §10.

---

## Open Technical Decisions

* **In-memory representation** (`Set<String>` of normalized keys vs compact/packed structure): resolved by the Frontend/Mobile Developer during implementation against a measured memory-footprint target on a low-end device profile; the choice and the measurement are recorded in `frontend.md`. Contract requirement: all ACs and the "allocation-light, O(1)/O(log n) lookup" metric hold.
* **Asset on-disk format** (newline-delimited text vs the JSON above vs a pre-baked binary): the authored **source** contract is the JSON shape above; an implementation may pre-bake a derived asset at build time. Any derived format must be reproducible from the JSON and validated in CI.
* **Circumflex vowels:** locked here as *distinct letters, not normalized away* — unless the curated asset is delivered without circumflex forms, in which case the authoring step (not F01 code) owns that choice. Revisit only if the Product Owner answers the F01 PRD Open Question differently.
