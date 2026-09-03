# F01 — dictionary-service: Frontend Delivery Report

Role: Frontend/Mobile Developer · Date: 2026-09-03 · Mode: Direct-edit

---

## 1. Feature Summary

Implemented `looplet_core` Turkish-locale normalization and the `looplet_dictionary`
package — a pure-Dart, language-scoped word validator with fail-safe asset
loading — and wired it into the Flutter app behind a session-level Riverpod
provider. No UI (Infrastructure feature).

All F01 tasks (F01.1-FE … F01.7-FE) complete. Gates green: `melos run format:check`,
`melos run analyze` (6 packages + `flutter analyze`), `melos run test` (56 tests),
`flutter build ios --release --no-codesign`.

---

## 2. Impacted Files

**Created**

* `packages/looplet_core/lib/src/turkish_case.dart`
* `packages/looplet_core/lib/src/normalize.dart`
* `packages/looplet_core/test/turkish_case_test.dart`
* `packages/looplet_core/test/normalize_test.dart`
* `packages/looplet_dictionary/lib/src/language_code.dart`
* `packages/looplet_dictionary/lib/src/dictionary_asset_source.dart`
* `packages/looplet_dictionary/lib/src/dictionary_logger.dart`
* `packages/looplet_dictionary/lib/src/dictionary_asset.dart`
* `packages/looplet_dictionary/lib/src/dictionary_service.dart`
* `packages/looplet_dictionary/assets/tr/dictionary.json`
* `packages/looplet_dictionary/assets/en/dictionary.json`
* `packages/looplet_dictionary/test/support/fakes.dart`
* `packages/looplet_dictionary/test/dictionary_service_test.dart`
* `packages/looplet_dictionary/test/fail_safe_test.dart`
* `packages/looplet_dictionary/test/language_isolation_test.dart`
* `packages/looplet_dictionary/test/dictionary_asset_test.dart`
* `packages/looplet_dictionary/test/qa_word_set_test.dart`
* `app/lib/dictionary/root_bundle_asset_source.dart`
* `app/lib/dictionary/dictionary_providers.dart`
* `app/test/dictionary_wiring_test.dart`

**Updated**

* `packages/looplet_core/lib/looplet_core.dart` — barrel now exports the real API (placeholder removed)
* `packages/looplet_dictionary/lib/looplet_dictionary.dart` — barrel exports the public API
* `packages/looplet_dictionary/pubspec.yaml` — added `flutter: assets:` section
* `packages/looplet_dictionary/README.md` — usage + asset-bundling note
* `app/lib/main.dart` — wrapped in `ProviderScope`
* `app/pubspec.yaml` — removed the (non-working) app-side asset re-declaration; note added

**Removed**

* `packages/looplet_core/lib/src/placeholder.dart`, `packages/looplet_core/test/looplet_core_test.dart`
* `packages/looplet_dictionary/lib/src/placeholder.dart`, `packages/looplet_dictionary/test/looplet_dictionary_test.dart`
* `packages/looplet_dictionary/assets/{tr,en}/.gitkeep` (real assets now present)

---

## 3. Task-to-Code Traceability

* **F01.1-FE** — Complete. `looplet_core/lib/src/turkish_case.dart` (`TurkishCase.toLowerTr` / `toUpperTr` with explicit `I↔ı`, `İ↔i`, `Ç Ğ Ö Ş Ü` maps; all other letters via ordinary casing; circumflex `â î û` untouched). `looplet_core/lib/src/normalize.dart` (`normalizeTurkish` = `toLowerTr` + trim + Turkish-alphabet-only check → `String?`; `normalizeLatin` for `en`). Barrel updated. `İ`→`i`, `I`→`ı` produce different code points → different keys.
* **F01.2-FE** — Complete. `looplet_dictionary` public API in `lib/src/`: `DictionaryService.load` / `switchLanguage` / `isValidWord({minLength})` / `isEligibleTarget` / `normalize` / `isFailSafe` / `dispose`; `DictionaryAssetSource` (abstract interface), `DictionaryLogger` (abstract interface) + `NoopDictionaryLogger`, `LanguageCode` enum. App wiring: `app/lib/dictionary/root_bundle_asset_source.dart` (`rootBundle.loadString`), `app/lib/dictionary/dictionary_providers.dart` (`dictionaryAssetSourceProvider`, `dictionaryServiceProvider` FutureProvider, session-level, `ref.onDispose(service.dispose)`), `ProviderScope` in `main.dart`.
* **F01.3-FE** — Complete. `dictionary_asset.dart` parses the `dictionary.json` contract shape; `_buildIndex` in `dictionary_service.dart` re-normalizes/dedupes on load (into a `Set<String>`), builds `words` + `targets` lookups; `targets` filtered to entries also present in `words`. In-memory representation decision + measurement below (§14).
* **F01.4-FE** — Complete. `_buildIndex` returns a fail-safe `_LanguageIndex` (`isFailSafe = true`, empty sets) on: asset read throw → `logger.warn('dictionary.asset.missing')`; `FormatException` from parse → `logger.error('dictionary.asset.corrupt')`; empty `words` → `logger.warn('dictionary.asset.empty')`. `_ensureUsable()` throws `StateError` after `dispose()`. ("Query before load" is unreachable — `load` is the only constructor and returns a fully-built instance; noted for the record.)
* **F01.5-FE** — Complete. `LanguageCode.{tr,en}`; `_buildIndex` picks `normalizeTurkish` for `tr`, `normalizeLatin` for `en`. `switchLanguage` replaces `_index` in a single field assignment (no residue); no-op when already active. `assets/en/dictionary.json` stub shipped.
* **F01.6-FE** — Complete. `assets/tr/dictionary.json`: 101 provisional hand-curated Turkish words (lowercase, normalized, no proper nouns / profanity / abbreviations), 30 curated 5-letter `targets` (each also in `words`), `exclusionsApplied` documented, `_note` flags it as provisional. `assets/en/dictionary.json`: 11-word stub.
* **F01.7-FE** — Complete. 56 tests across the workspace (see §17). `qa_word_set_test.dart` runs the golden must-accept / must-reject set against the **real shipped** `assets/tr/dictionary.json` via a disk-reading `FileAssetSource`.

---

## 4. Authority Reconciliation

* **Conflict source:** `architecture.md` "Integration Rules" note — *"Because this is a pure-Dart package, it cannot bundle Flutter assets itself. The app is responsible… `app/pubspec.yaml` must declare `- packages/looplet_dictionary/assets/tr/`"*.
* **Reality:** Flutter's app-side directory declaration resolves `packages/looplet_dictionary/assets/tr/` relative to the **app** directory and fails (`unable to find directory entry in pubspec.yaml`). The working mechanism is for the **package** to declare its assets in its own `pubspec.yaml` `flutter: assets:` section; the app then gets them in the bundle automatically and reads them as `packages/looplet_dictionary/assets/<lang>/dictionary.json`.
* **Winning authority:** `architecture.md` "Open Technical Decisions" already delegates *asset on-disk format / bundling* to implementation; the conflicting sentence is an incidental note, not a contract clause. The API contract, asset JSON shape, normalization spec, and fail-safe semantics are all implemented exactly as specified.
* **Applied decision:** `packages/looplet_dictionary/pubspec.yaml` gains a `flutter: assets:` section (package stays pure Dart — no `flutter` SDK dependency); `app/pubspec.yaml` does **not** re-declare the assets. Bundle key is unchanged (`packages/looplet_dictionary/assets/tr/dictionary.json`), so the `rootBundle`-backed source and the architecture's `LanguageCode.assetPath` are unaffected.
* **Downstream impact:** none for the contract. `architecture.md` "Integration Rules" wording should be corrected on its next revision (Tech Lead) to describe package-side declaration.

---

## 7. State Management

* `dictionaryServiceProvider` (`FutureProvider<DictionaryService>`) — session-level, resolved once, `ref.onDispose(service.dispose)`. Not screen-scoped (matches `architecture.md`: "owned by an app-level Riverpod provider (session-level)").
* `dictionaryAssetSourceProvider` (`Provider<DictionaryAssetSource>`) — indirection point so tests override the source. Default: `RootBundleDictionaryAssetSource`.
* No server state. The dictionary is a read-only bundled asset; `DictionaryService` holds an immutable `_LanguageIndex` swapped atomically on `switchLanguage`.

---

## 9. Contract Compliance Check

* **Public API surface** — Preserved. Signatures match `architecture.md` "Public API" verbatim (`load` named params, `isValidWord({int minLength = 1})`, `normalize` returns `String?`, `isFailSafe` getter, `switchLanguage` / `dispose` return `Future<void>`). Additive-only: `NoopDictionaryLogger` (public convenience), `LanguageCode.fromCode`, `DictionaryAsset` exported for tests — none change existing behavior.
* **Asset format** — Preserved. Parser reads `schemaVersion` (must == 1), `language` (must match), `words`, `targets`, optional `exclusionsApplied`; unknown keys (`_note`) ignored; defensive re-normalize/dedupe/sort-into-Set on load.
* **Turkish normalization** — Preserved. `İ`≠`I` (→ `i` vs `ı`), circumflex kept distinct, letters-only → else `null`, never empty string, never throws.
* **Fail-safe semantics** — Preserved. Missing/corrupt/empty → completed `load`, `isFailSafe == true`, all lookups `false`, exact diagnostic codes. `StateError` after `dispose`.
* **Error semantics** — Preserved. `dictionary.asset.missing` (warn), `dictionary.asset.corrupt` (error), `dictionary.asset.empty` (warn).
* **Dependency boundary** — Preserved. `looplet_dictionary` depends only on `looplet_core` (+ dev `test`). No `flutter`, `looplet_engine`, `looplet_content`, Firebase.
* **Navigation / back / header** — Not Applicable (no UI).
* **Async authority / lifecycle** — Preserved. `switchLanguage` swap is a single field assignment; synchronous queries cannot observe a partial index.

---

## 12. Implemented Files

| File | Change | Notes |
| --- | --- | --- |
| `looplet_core/lib/src/turkish_case.dart` | new | `_toLower` / `_toUpper` const maps + rune loop |
| `looplet_core/lib/src/normalize.dart` | new | `normalizeTurkish` (29-letter alphabet + `â î û`), `normalizeLatin` (ASCII a–z) |
| `looplet_dictionary/lib/src/language_code.dart` | new | `enum {tr, en}`, `.code`, `.assetPath`, `.fromCode` |
| `looplet_dictionary/lib/src/dictionary_asset_source.dart` | new | `abstract interface class` |
| `looplet_dictionary/lib/src/dictionary_logger.dart` | new | abstract + `NoopDictionaryLogger` |
| `looplet_dictionary/lib/src/dictionary_asset.dart` | new | `DictionaryAsset.parse` → `FormatException` on any malformed input |
| `looplet_dictionary/lib/src/dictionary_service.dart` | new | `DictionaryService` + private `_LanguageIndex` (immutable, `Set<String>` lookups) |
| `looplet_dictionary/assets/tr/dictionary.json` | new | 101 words / 30 targets, provisional |
| `looplet_dictionary/assets/en/dictionary.json` | new | 11-word stub |
| `looplet_dictionary/pubspec.yaml` | updated | `flutter: assets:` section |
| `app/lib/dictionary/root_bundle_asset_source.dart` | new | `rootBundle.loadString` |
| `app/lib/dictionary/dictionary_providers.dart` | new | two providers, session-level service |
| `app/lib/main.dart` | updated | `ProviderScope` wrap |

---

## 13. Performance Notes

* In-memory representation: `Set<String>` of normalized keys for `words` and `targets`. Average O(1) membership. Per-query allocation = one normalized `String` (the candidate), no list scans. Matches `architecture.md`'s explicitly-allowed option and its "allocation-light, O(1)/O(log n)" requirement.
* Frozen-tile checks (F02) call `isValidWord` a few times per settled move — negligible.

---

## 14. Assumptions

* **In-memory representation decision (Open Technical Decision, F01.3):** chose a plain `Set<String>`. **Measurement:** the shipped provisional list is 101 words → trivial (<10 KB retained). Projection for a full common-Turkish corpus of ~90k words at a mean ~7 chars: roughly 3–6 MB retained as a Dart `Set<String>` (string headers + UTF-16 payload + hash set overhead). That is acceptable for the mid-tier device profile in `platform.md` §10, and it is a one-time load cost, not per-query. **Recommendation:** re-measure on a real low-end device once the reviewed corpus lands (F01 PRD Open Question); if it exceeds ~8 MB, switch the internal representation to a sorted packed `Uint8List` + binary search behind the same API (no contract change). Documented here rather than deferred.
* Circumflex vowels are treated as distinct letters and preserved by `normalize` (locked in `architecture.md`; the provisional asset contains no circumflex forms, so this is currently exercised only by unit tests).
* `assets/tr/dictionary.json` is provisional and hand-curated for development; the reviewed corpus + target review is a Product Owner / content deliverable and swapping it in is a content change, not code.

---

## 16. Needs Tech Lead Clarification

* Minor: `architecture.md` "Integration Rules" says the **app** declares the dictionary assets; that does not work in Flutter. Implemented the standard package-declares-its-own-assets mechanism instead (see §4). Please correct that sentence on the next `architecture.md` revision. No contract impact.

---

## 17. Test Evidence by Task

| Task / behavior | Type | Scenario proven |
| --- | --- | --- |
| F01.1 — Turkish casing | unit (`turkish_case_test.dart`, 9) | full `Ç Ğ İ I Ö Ş Ü` map both directions; `İ`≠`I` distinct code points; `IL`→`ıl` vs `İL`→`il`; circumflex preserved; upper/lower round-trip |
| F01.1 — normalization | unit (`normalize_test.dart`, 9) | casing invariance; `İ`/`I` distinct keys; all 29 letters accepted; circumflex kept; `null` for empty/whitespace/space/hyphen/digit/punct/`q w x`/`é`; `normalizeLatin` ASCII-only |
| F01.2 — public API / validation | unit (`dictionary_service_test.dart`, 17) | load non-fail-safe; `isValidWord` casing-invariant + list membership; `İ`/`I` distinct (`kır` listed, `KİR` rejected); `minLength` short-circuit; malformed → `false`; `isEligibleTarget` true/false + orphan-target dropped; `normalize` passthrough; `StateError` after `dispose` |
| F01.3 — asset parse | unit (`dictionary_asset_test.dart`, 8) | well-formed parse; optional `exclusionsApplied`; `FormatException` for bad JSON / non-object root / bad `schemaVersion` / language mismatch / non-string-array `words`/`targets` |
| F01.4 — fail-safe | unit (`fail_safe_test.dart`, 6) | missing→`missing` warn + fail-safe; corrupt→`corrupt` error; 5 wrong-shape JSONs→fail-safe; empty `words`→`empty` warn; no-logger path does not throw |
| F01.5 — language isolation | unit (`language_isolation_test.dart`, 6) | `en` sees only English; `en` ordinary lowercasing; `switchLanguage` both directions leave no residue; no-op to active language; switch to missing language → fail-safe |
| F01.7 — golden QA set | unit (`qa_word_set_test.dart`, 6) | **real shipped `assets/tr/dictionary.json`**: 15 must-accept validate at `minLength: 4` any casing; 10 must-reject fail (incl. 3-letter `kir` at `minLength: 4`); all 30 targets are eligible + valid + exactly 5 letters; plain word `kelime` not a target |
| App wiring | flutter test (`dictionary_wiring_test.dart`, 1) | `dictionaryServiceProvider` loads the bundled Turkish asset via `rootBundle`; not fail-safe; `masal` valid, `MASAL` eligible target, `zzzz` invalid |
| App boot | flutter test (`widget_test.dart`, 1) | app boots to the placeholder shell under `ProviderScope` |
| Build | `flutter build ios --release --no-codesign` | passes with dictionary assets bundled + Riverpod |

Totals: 50 pure-Dart unit tests + 2 flutter tests + 4 scaffold smoke tests = **56** green. `melos run format:check`, `melos run analyze` green. `melos run build:app` (Android) runs in CI only — no local Android SDK.

---

## WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* Completed Tasks: F01.1-FE, F01.2-FE, F01.3-FE, F01.4-FE, F01.5-FE, F01.6-FE, F01.7-FE
* Remaining Tasks: none in frontend scope
* Blockers: none
* Status Suggestion: **Ready for QA** (client-only, automated — see `architecture.md` QA Focus)

---

## 19. Sonraki Komut

Run QA
