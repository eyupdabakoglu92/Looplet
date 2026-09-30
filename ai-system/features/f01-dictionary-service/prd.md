# F01 — dictionary-service: PRD

> Status: FEATURE PRODUCT AUTHORITY (derived from `/ai-system/product/product-prd.md` §6.1 F01, §23, §24)
> Acceptance policy resynced 2026-09-30 from PO-REV-2026-09-30-CONTENT-QUALITY; historical code acceptance is unchanged. Production corpus delivery and QA remain in F07.

---

## Summary

* **Problem:** The game needs a single, trustworthy way to decide whether a string of Turkish letters is a real, allowed word. Two systems depend on this: frozen-tile thawing (a valid ≥4-letter word must form in a row) and target-word curation. Turkish case rules (İ vs I) break naive string handling.
* **Goal:** A pure-Dart `looplet_dictionary` package that validates a candidate word against a curated, language-scoped word list, with correct Turkish-locale normalization, behind an API that additional languages can plug into without changing callers.
* **User value:** Frozen tiles thaw only on genuinely valid words, target words are always real and appropriate, and Turkish input behaves correctly — the player never sees a "that's not a word" moment that is actually the game's fault.

---

## Dependencies

* Upstream features: none. F01 is the first feature and a hard dependency for F02 (frozen-tile thaw) and F06 (solver/content validation).
* Required platform assumptions (`/ai-system/project-authority/platform.md`):
  * Flutter monorepo (melos); `looplet_dictionary` and `looplet_core` are pure-Dart packages (no Flutter import).
  * Turkish-locale case utility lives in `looplet_core`; default `toUpperCase()`/`toLowerCase()` on letters is forbidden in game/dictionary logic.
  * Localization is keyed by language; `tr` is the default, `en` is scaffolded.
  * Repo is not yet scaffolded — Project Setup runs first.

---

## In Scope

* A curated Turkish word-list asset bundled with the package (single reviewed source of truth).
* A curated **target-word** list (5-letter, common, accepted under the documented content-quality policy) — a subset/annotation of the dictionary usable by F06 for Journey/Daily target selection.
* Turkish-locale case normalization utility (`İ↔i`, `I↔ı`, `Ç Ğ Ö Ş Ü` preserved), used for all lookups.
* Word validation API: `isValidWord(word, {minLength})` and `isEligibleTarget(word)`, resolved against the active language.
* Language selection: the service is constructed for / switched to a language key; only that language's list is consulted.
* Exclusion handling: the curated list excludes proper nouns, profanity/slurs, abbreviations, and (by default) archaic words. The build/authoring step that produces the asset applies and records these exclusions.
* Fail-safe behavior when the asset is missing or corrupt (treat as "no valid words", log, do not throw/crash).
* Deterministic, allocation-light lookup suitable for repeated calls during play (frozen-tile checks run after moves).
* Unit tests: golden "must-accept / must-reject" QA word set, normalization tables, length-rule tests, fail-safe test, `en` stub wiring test.

## Out of Scope

* Building or sourcing the actual Turkish word corpus content (word-list curation is a Product Owner / content task; F01 defines the format and consumes the reviewed asset). The MVP ships with an initial reviewed list; expanding it is content work, not F01 code.
* English dictionary content (only the language-keyed plumbing + an `en` stub asset are in scope).
* Any UI, settings screen, or in-game "dictionary" browser.
* Frozen-tile row scanning logic (that is F02 — it calls F01 to validate candidate substrings).
* Fuzzy matching, stemming, lemmatization, or "did you mean".
* Runtime/remote dictionary updates (the list is a bundled asset for the MVP).

---

## User Stories

F01 is Infrastructure; expressed as system requirements.

* The system must validate a candidate word against a curated, language-scoped dictionary so that only real, allowed words gate frozen-tile thawing and target-word selection.
* The system must normalize case using Turkish-locale rules (treating `İ` and `I` as distinct) so that lookups are correct for Turkish letters.
* The system must exclude proper nouns, profanity/slurs, abbreviations, and (by default) archaic words so that content suits a 16+ casual audience.
* The system must expose the dictionary behind a language key so that English and further languages can be added without changes to consuming code.
* The system must fail safe when its word-list asset cannot be loaded so that a corrupt asset degrades gracefully instead of crashing the game.

---

## Acceptance Criteria

* **Given** a normalized 4-letter Turkish word that is present in the curated list, **When** `isValidWord(word, minLength: 4)` is called, **Then** it returns `true`.
* **Given** the strings `"İL"` and `"IL"`, **When** each is normalized and looked up, **Then** they resolve to distinct lookup keys (they are not merged), and each returns the list's actual membership for that exact letter sequence.
* **Given** a word on the exclusion list (proper noun / profanity / abbreviation), **When** `isValidWord` is called, **Then** it returns `false` even if the letters form an otherwise plausible word.
* **Given** the service is constructed for `language = 'en'`, **When** `isValidWord` is called with a Turkish-only word, **Then** only the English list is consulted (Turkish entries are not visible).
* **Given** a candidate shorter than the supplied `minLength` (e.g. 3 letters with `minLength: 4`), **When** `isValidWord` is called, **Then** it returns `false` by the length rule without consulting the list.
* **Given** mixed-case or all-caps input such as `"KİTAP"` or `"kitap"` or `"KiTaP"`, **When** validated, **Then** the result is identical for all casings of the same letter sequence.
* **Given** the word-list asset is missing or fails to parse, **When** the service initializes, **Then** initialization completes, a diagnostic is logged, and every `isValidWord` / `isEligibleTarget` call returns `false` (no exception propagates).
* **Given** the curated target list, **When** `isEligibleTarget(word)` is called for any 5-letter entry in that list, **Then** it returns `true`; for a valid dictionary word not on the target list it returns `false`.
* **Given** the QA "must-accept" and "must-reject" word sets, **When** the package test suite runs, **Then** 0 must-accept words return `false` and 0 must-reject words return `true`.

---

## Edge Cases

* All-caps grid letters (`"MASAL"`) vs list stored in another casing — must match via Turkish normalization.
* Words with multiple diacritics (`"şöyle"`, `"güğüm"`).
* Homographs differing only by `İ/I` or by a diacritic (`"kar"` vs `"kâr"` — decide whether circumflex forms are separate entries; default: circumflex normalized away only if the curated list does so, otherwise treated as distinct).
* Candidate contains a non-letter (space, hyphen, digit, punctuation) → `false`, never throws.
* Empty string or whitespace-only → `false`.
* Very long candidate (longer than the grid could ever produce) → `false` cheaply, no list scan needed beyond a membership check.
* Duplicate entries or trailing whitespace in the asset → normalized away at load; no double counting.
* Asset present but empty → behaves as "no valid words" (same as fail-safe), logged as a warning.
* Memory footprint of the full word list on low-end devices → the load format and in-memory structure must be measured; a compact set (e.g. hashed keys or a sorted packed structure) is acceptable if it keeps the AC.
* Repeated rapid calls (frozen-tile scan after every move) → lookups must be O(1)/O(log n) and allocation-light.
* Language switch at runtime (e.g. player changes app language) → subsequent calls use the new language's list; no stale results from the previous language.

---

## Success Metrics

* 0 must-accept words rejected and 0 must-reject words accepted across the curated QA word set (package test suite, CI-enforced).
* 100% of shipped MVP target words pass `isEligibleTarget`, source/exclusion validation and recorded Content Designer editorial review; QA independently reviews all newly admitted targets. Supporting words receive full automated checks and documented risk-stratified QA sampling, expanded on critical defects.
* Turkish-locale normalization table tests pass for the full `Ç Ğ İ I Ö Ş Ü` set, including `İ ≠ I`.
* Frozen-tile validation call latency is negligible in the F02 integration (no measurable frame impact from a post-move row scan).
* Fail-safe path proven by test: corrupt asset → no crash, all lookups `false`.

---

## Open Questions

* **[Content — Owner: Content Designer; QA independent]** Source/version/usage conditions and corpus curation evidence remain required in F07. Acceptance follows product revision PO-REV-2026-09-30-CONTENT-QUALITY: no routine user list approval; uncertain entries excluded. A provisional development list is not production approval.
* **[Product — Owner: Product Owner]** Circumflex vowels (`â î û`): are `"kar"`/`"kâr"` distinct playable words, or is the circumflex normalized away? Affects both normalization and the asset. Default assumption: keep them distinct (normalize circumflex only if the curated list is built without circumflex forms).
* **[Technical — Decided by Tech Lead in `architecture.md`]** In-memory representation of the word list (plain `Set<String>` of normalized keys vs a compact/packed structure) — decided against a measured footprint target during implementation.
* **[Technical — Decided by Tech Lead in `architecture.md`]** Asset format (newline-delimited text vs pre-hashed binary vs compressed) — decided during implementation with the footprint/latency ACs as the constraint.
