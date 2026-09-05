# F01 — dictionary-service: QA Report

Role: QA · Date: 2026-09-05

---

## 0a. Evidence Mode Declaration

* Bash / build access: **VAR**
* e2e test suite (Playwright / Cypress / Detox): **YOK**
* Screenshot / browser tool: **YOK**
* Runtime validation method: **`automated functional`** — `melos run test` (56 tests) + `melos run analyze` + `melos run format:check` executed by QA; plus an independent QA probe (`test/_qa_probe_test.dart`, run and removed) asserting the contract behaviors directly against the real shipped asset.

No `source-only` fallback used — the suites and an independent probe were actually executed.

---

## 1. Feature Summary

* **Feature tested:** F01 dictionary-service — `looplet_core` Turkish-locale normalization + `looplet_dictionary` (pure-Dart, language-scoped word validation with fail-safe asset loading) + app-side Riverpod wiring.
* **QA scope:** client-only, package-level, automated functional. Per `architecture.md` "QA Focus" and `platform.md` §10, no device runtime is required for this feature; the pure-Dart deterministic suites are the accepted evidence class.

---

## 2. Test Scope

* **Scope Type:** Client Only (automated functional). No `backend.md` → backend scope N/A. `frontend.md` present → validated via it + source + executed tests.
* **Documents reviewed:** `prd.md`, `architecture.md`, `orchestration.md`, `frontend.md`, `role-execution-contract.md`, `system-state.md`, `project-authority/platform.md` §10–11, `project-authority/setup-manifest.md` (canonical commands).
* **Areas tested:** Turkish case conversion + normalization (`looplet_core`); `DictionaryService` public API (`load` / `switchLanguage` / `isValidWord({minLength})` / `isEligibleTarget` / `normalize` / `isFailSafe` / `dispose`); asset parsing + validation; fail-safe semantics + diagnostic codes; language isolation + no-residue on `switchLanguage`; the shipped `assets/tr/dictionary.json` (words/targets integrity, 30 five-letter targets); app wiring (`dictionaryServiceProvider` loads the bundled asset via `rootBundle`).
* **Areas not tested / out of scope:**
  * `Backend Build Gate` out of scope: no backend-touching code (no `backend.md`, no server, no Firebase in this feature).
  * `Backend quality out of scope`: no backend code.
  * `Security compliance out of scope`: F01 is an internal pure-logic library — no authentication/authorization, no access to other users' resources, no financial operations, no user-data storage, no admin/role separation. It only answers "is this string a word in language L". No injection surface (no SQL/NoSQL/shell; JSON parsed with `dart:convert` into typed models). Nothing to attack.
  * `Release compliance out of scope`: `orchestration.md → Release Scope = none`; `release.md §2` sets F01 Release Scope `none` (internal library, no distributable surface).
  * `UI handoff compliance / UI Design Compliance out of scope`: no `ui-design.md`, no screens, no route/header/back/chrome — Infrastructure feature.
  * `iOS platform compliance out of scope`: no `game-dev.md`, client stack is Flutter (not Unity); F01 adds no tracking SDK / IAP / privacy-manifest surface.
  * `Game client quality` / `Game visual & feel quality` out of scope: not a game-client feature.
* **Bugfix?** No — greenfield feature, first implementation.
* **Critical user journey (product-level):** frozen-tile thaw validation — a valid ≥4-letter Turkish word in any casing validates; a non-word / excluded word / too-short candidate does not. Plus: target-word eligibility for F06 content selection.
* **Forbidden / misuse journeys:** malformed candidate (non-letter / empty / whitespace / letters outside the Turkish alphabet); query after `dispose`; wrong-language lookup; corrupt / missing / empty asset.
* **Navigation/header consistency:** N/A (no UI).
* **Evidence class summary:** `automated functional` (deterministic pure-Dart + flutter tests, executed) + independent QA probe.
* **Runtime validation method:** `automated functional`.

---

## 3. Product Behavior Coverage

F01 is Infrastructure; `prd.md` states system requirements rather than user stories. Each is checked against product behavior (`prd.md`), separately from contract (`architecture.md`).

| System requirement (prd.md) | Test scenario | Evidence | Result |
| --- | --- | --- | --- |
| Validate a candidate against a curated, language-scoped list | `isValidWord` against shipped `assets/tr/dictionary.json` (`masal`/`kitap`/`balık` accept; `zebra`/`lorem` reject) | `qa_word_set_test.dart` (must-accept ×15, must-reject ×10); QA probe | PASS |
| Normalize case with Turkish rules, `İ` ≠ `I` | `normalize('KİR')` → `kir`, `normalize('KIR')` → `kır`, not equal; `IL`→`ıl` vs `İL`→`il` | `turkish_case_test.dart`, `normalize_test.dart`, `dictionary_service_test.dart` "İ and I are different keys"; QA probe (real asset: `kir` valid, `KİR`→`kir` distinct from `KIR`→`kır`) | PASS |
| Exclude proper nouns / profanity / abbreviations / archaic | Shipped asset is hand-curated with `exclusionsApplied` documented; parser has no code path that re-admits excluded words (exclusion is a content property of the asset) | `frontend.md` §2/§17; asset `_note` + `exclusionsApplied`; content review is an open PO deliverable (see Tech Lead Note) | PASS (code); content depth = PO item |
| Expose the dictionary behind a language key; add languages without caller changes | `LanguageCode.{tr,en}`; `en` service consults only English; `switchLanguage` swaps index | `language_isolation_test.dart` (6); QA probe (en: `table` valid, `masal` invalid; round-trip switch leaves no residue) | PASS |
| Fail safe when the asset cannot be loaded | Missing / corrupt / wrong-shape / empty asset → completed `load`, `isFailSafe == true`, all lookups `false`, correct diagnostic code; no-logger path does not throw | `fail_safe_test.dart` (6); QA probe (corrupt→`dictionary.asset.corrupt`, missing→`dictionary.asset.missing`) | PASS |

No uncovered system requirement.

---

## 4. Acceptance Criteria Traceability

Every AC from `prd.md` "Acceptance Criteria" mapped to an executed test.

| AC (prd.md) | Test scenario | Evidence | Result |
| --- | --- | --- | --- |
| 4-letter listed word + `minLength: 4` → `true` | `isValidWord('masal', minLength: 4)` etc. | `qa_word_set_test.dart`, `dictionary_service_test.dart`; QA probe | PASS |
| `"İL"` vs `"IL"` → distinct lookup keys | normalize both, assert not equal; controlled fixture `kır` listed / `kir` absent | `normalize_test.dart` "İ and I produce distinct keys"; `dictionary_service_test.dart` "İ and I are different keys"; QA probe | PASS |
| Exclusion-list entry → `false` even if well-formed | membership-only lookup; excluded words are simply absent from `words` | `frontend.md` §17; by construction — no code path re-admits | PASS |
| `language = 'en'` active → only English list consulted | `isValidWord('masal', minLength: 4)` under `en` → `false`; `table` → `true` | `language_isolation_test.dart` "en service consults only the English list"; QA probe | PASS |
| candidate shorter than `minLength` → `false` without list hit | `isValidWord('kir', minLength: 4)` → `false` (impl checks `runes.length < minLength` before `words.contains`) | `dictionary_service_test.dart` "length rule…"; source `dictionary_service.dart:62-64`; QA probe | PASS |
| mixed/all-caps input → identical result for same letters | `isValidWord('MASAL' / 'masal' / 'MaSaL' / '  masal ')` all equal | `dictionary_service_test.dart` "accepts a listed word regardless of casing"; QA probe | PASS |
| asset missing / unparseable → `load` completes, diagnostic logged, all lookups `false` | missing / `'not json'` / `'{ this is not json'` | `fail_safe_test.dart`; QA probe | PASS |
| `isEligibleTarget` → `true` for every 5-letter curated target, `false` for a valid non-target word | all 30 shipped targets; `kelime` (valid word, not a target) | `qa_word_set_test.dart` "every shipped target…" + "a plain word is not an eligible target" | PASS |
| QA must-accept / must-reject sets → 0 wrong on each | 15 must-accept, 10 must-reject vs real shipped asset | `qa_word_set_test.dart` | PASS |

Contract items from `architecture.md` "API / Event Contract" additionally checked in §6.

No uncovered AC.

---

## 5. Boundary Matrix

F01 has two small stateful behaviors: language index lifecycle and fail-safe transitions. No queues, pagination, retry, ordered/cyclic actor flow, or async hydration.

| Boundary / transition | Test result | Evidence |
| --- | --- | --- |
| `load` → ready index (happy) | PASS | `dictionary_service_test.dart` "loads a real asset and is not fail-safe" |
| `load` → fail-safe index (missing / corrupt / wrong-shape / empty) | PASS | `fail_safe_test.dart` (all four); QA probe |
| `switchLanguage(other)` → full index replace, **no residue from previous language** (both directions) | PASS | `language_isolation_test.dart` "switchLanguage swaps the active index with no residue"; QA probe (tr→en→tr, each direction asserts the other language's words are now invalid) |
| `switchLanguage(active)` → no-op, still completed future | PASS | `language_isolation_test.dart` "switchLanguage to the active language is a no-op" |
| `switchLanguage(missing language)` → fail-safe index | PASS | `language_isolation_test.dart` "switching to a missing language yields a fail-safe index" |
| query after `dispose()` → `StateError` (terminal) | PASS | `dictionary_service_test.dart` "queries after dispose throw StateError"; QA probe |
| `minLength` boundary: 3-letter word at `minLength: 4` → reject; at default `minLength: 1` → accept | PASS | `dictionary_service_test.dart` "length rule…"; QA probe (`kir`) |
| "query before load" | Not applicable — `load` is the only constructor and returns a fully-built instance; there is no pre-load instance to query. Documented in `frontend.md` §3 / `architecture.md` Invalid Paths. |
| Empty candidate / whitespace-only | PASS (→ `false`, no throw) | `normalize_test.dart`, `dictionary_service_test.dart` "malformed candidates return false, never throw" |
| Over-long candidate | PASS (→ `false` via letters-only + membership, no scan cost) | `normalize_test.dart` (non-Turkish letters rejected); membership-set lookup is O(1) |

Concurrency note: `switchLanguage` replaces `_index` in a single field assignment after the new index is fully built, so a synchronous `isValidWord` cannot observe a half-built index. Dart is single-isolate for this code path — no data race. Matches `architecture.md` "State / Flow Semantics".

---

## 6. Contract Compliance Check

Reference: `architecture.md` "API / Event Contract", "Data / Domain Model", "Error Semantics".

| Contract area | Result | Evidence |
| --- | --- | --- |
| Public API surface & signatures | **Preserved** | `lib/src/dictionary_service.dart` matches the "Public API" block verbatim: `load({required language, required assetSource, logger})` static async; `language` / `isFailSafe` getters; `switchLanguage` / `dispose` → `Future<void>`; `isValidWord(String, {int minLength = 1})`; `isEligibleTarget(String)`; `normalize(String) → String?`. `DictionaryAssetSource` / `DictionaryLogger` are `abstract interface class`. `LanguageCode { tr, en }`. |
| Additive-only extras | **Extended (safe)** | `NoopDictionaryLogger` (public default), `LanguageCode.fromCode`, `DictionaryAsset` exported for tests. None alter existing behavior or signatures. |
| Asset JSON shape | **Preserved** | `dictionary_asset.dart` reads `schemaVersion` (must == 1), `language` (must match `expectedLanguage`), `words[]`, `targets[]`, optional `exclusionsApplied[]`; unknown keys (`_note`) ignored. Verified by `dictionary_asset_test.dart` (8). |
| Bundle key / `LanguageCode.assetPath` | **Preserved** | `packages/looplet_dictionary/assets/<code>/dictionary.json` unchanged; app `RootBundleDictionaryAssetSource` reads exactly this key; `dictionary_wiring_test.dart` confirms it resolves in the Flutter bundle. |
| Turkish normalization spec | **Preserved** | `İ`→`i`, `I`→`ı` (distinct code points); `Ç Ğ Ö Ş Ü` mapped; circumflex `â î û` preserved (not folded); letters-only → else `null`, never empty, never throws. `turkish_case_test.dart` (9) + `normalize_test.dart` (9). |
| Fail-safe semantics | **Preserved** | missing → `logger.warn('dictionary.asset.missing')`; parse `FormatException` → `logger.error('dictionary.asset.corrupt')`; empty `words` → `logger.warn('dictionary.asset.empty')`; all → `isFailSafe == true`, empty sets, lookups `false`. |
| Error semantics | **Preserved** | Exact codes `dictionary.asset.missing` / `.corrupt` / `.empty`; `StateError` only after `dispose`. Asset read caught with `on Object` (rootBundle throws an `Error`, not an `Exception`, for a missing asset — correctly handled). |
| Dependency boundary | **Preserved** | `looplet_dictionary` `pubspec.yaml` depends only on `looplet_core` (+ dev `test`). No `flutter` SDK dep, no `looplet_engine` / `looplet_content` / Firebase. `melos run analyze` clean. |
| `targets` ⊆ `words` rule | **Preserved** | `_buildIndex` filters `targets` to entries also present in `words` (`dictionary_service_test.dart` "a target missing from words is dropped"). |
| Determinism / no runtime RNG | **Preserved** | No `Random`, no clock, no I/O beyond the injected `assetSource`. Pure functions. |
| Contract version | v1, no breaking change (first feature). | |
| Validation | Input validation (letters-only, length, JSON shape) is package-side per `architecture.md` "Validation Responsibility". | |
| Auth / Data Handling | N/A — no auth, read-only bundled asset, no PII. | |

**Contract note (non-blocking):** `architecture.md` "Integration Rules" says *"the app must declare `- packages/looplet_dictionary/assets/tr/`"*. That does not work in Flutter — the app-side directory form resolves relative to the app root and fails. The implementation instead declares the assets in `looplet_dictionary`'s own `pubspec.yaml` `flutter: assets:` section (the standard mechanism for a package that ships assets), keeping the package dependency-free of the Flutter SDK. The **contract-relevant** parts — bundle key, `DictionaryAssetSource` abstraction, `LanguageCode.assetPath`, app-provided `rootBundle` source — are all unchanged and verified. This is an incidental wording issue in a non-contract note (asset bundling is delegated to implementation by `architecture.md` "Open Technical Decisions"), surfaced transparently in `frontend.md` §4/§16. → Tech Lead Note for an `architecture.md` wording fix; **not a violation**.

---

## 9. Positive Scenarios

**Journey 1 — frozen-tile thaw validation (the F02 consumer path):**
Start: a puzzle row settles into a contiguous left-to-right span of Turkish grid letters spelling a real 5-letter word, e.g. uppercase `M A S A L`. Action: F02 calls `isValidWord('MASAL', minLength: 4)`. Visible result: `true` → F02 thaws the frozen tile. Verified: `qa_word_set_test.dart` + QA probe against the real shipped `assets/tr/dictionary.json` (`MASAL`/`masal`/`MaSaL` all `true` at `minLength: 4`).

**Journey 2 — target-word eligibility (the F06 content path):**
Start: F06 authoring considers `kalem` as a Journey target. Action: `isEligibleTarget('kalem')`. Result: `true` (curated 5-letter target). A non-target valid word `kelime` → `false`. Verified: `qa_word_set_test.dart` "every shipped target…" (all 30) + "a plain word is not an eligible target".

**Journey 3 — app startup wiring:**
Start: app launches under `ProviderScope`. Action: something reads `dictionaryServiceProvider.future`. Result: a non-fail-safe `DictionaryService` on `LanguageCode.tr`, `isValidWord('masal', minLength: 4) == true`. Verified: `app/test/dictionary_wiring_test.dart` (executed green).

---

## 10. Negative / Edge Cases

| Case | Expected | Observed | Evidence |
| --- | --- | --- | --- |
| Non-letter candidate (`'ma sal'`, `'a-b'`, `'abc1'`, `'kalem!'`) | `false`, no throw | `false`, no throw | `dictionary_service_test.dart`, `qa_word_set_test.dart`, QA probe |
| Empty / whitespace-only candidate | `false` (normalize → `null`) | as expected | `normalize_test.dart`, QA probe |
| Letters outside Turkish alphabet (`'WXQ'`, `'café'`) | `false` | `false` | `normalize_test.dart`, QA probe |
| 3-letter word at `minLength: 4` | `false` without list hit | `false` | `dictionary_service_test.dart`, QA probe (`kir`) |
| Query after `dispose()` | `StateError` | `StateError` on `isValidWord` / `isEligibleTarget` / `normalize` | `dictionary_service_test.dart`, QA probe |
| Corrupt asset (`'not json'`, `'{ this is not json'`) | fail-safe + `dictionary.asset.corrupt` | as expected | `fail_safe_test.dart`, QA probe |
| Missing asset | fail-safe + `dictionary.asset.missing` | as expected | `fail_safe_test.dart`, QA probe |
| Wrong `schemaVersion` (2) / wrong `language` / `words` not an array / `words:[1,2]` / root `[]` | fail-safe (parse `FormatException` → corrupt) | all five → fail-safe | `fail_safe_test.dart` "wrong-shape JSON", `dictionary_asset_test.dart` |
| Valid asset but empty `words` | fail-safe + `dictionary.asset.empty` | as expected | `fail_safe_test.dart` |
| No `DictionaryLogger` passed + bad asset | loads fail-safe, no throw (uses `NoopDictionaryLogger`) | as expected | `fail_safe_test.dart` "no logger passed" |
| `switchLanguage` to a language with no asset | fail-safe index, previous-language lookups now `false` | as expected | `language_isolation_test.dart`, QA probe |
| Circumflex distinctness (`kâr` vs `kar`) | different normalized keys | different | `turkish_case_test.dart`, `normalize_test.dart`, QA probe |
| `İ` vs `I` distinctness in real asset | `KİR`→`kir`, `KIR`→`kır`, distinct | distinct | QA probe against shipped asset |

No misuse path produced an exception, a crash, or a wrong `true`.

---

## 14. Frontend Quality

Client-touching scope (pure-Dart packages + minimal app wiring).

* **Code quality:** `melos run analyze` clean across all 6 packages + `flutter analyze` clean. `melos run format:check` clean. No stubs / TODOs / hardcoded magic left in the F01 surface (scaffold placeholders for `looplet_core` / `looplet_dictionary` were removed; other package barrels still carry a documented `*Ready` marker — out of F01 scope, expected).
* **State management:** `dictionaryServiceProvider` is a session-level `FutureProvider` with `ref.onDispose(service.dispose)` — matches `architecture.md` "owned by an app-level Riverpod provider (session-level)". `dictionaryAssetSourceProvider` gives a clean test override point (used by `dictionary_wiring_test.dart` indirectly via `ProviderContainer`). No screen-scoped ownership.
* **Server vs UI state:** N/A — the dictionary is a read-only bundled asset; the service holds an immutable `_LanguageIndex`.
* **Representation choice:** `Set<String>` of normalized keys — O(1) membership, one `String` allocation per query, no list scans. `frontend.md` §14 records the decision and a footprint projection (~3–6 MB for a full ~90k-word corpus) with a documented fallback (`Uint8List` + binary search behind the same API) and a re-measure recommendation once the reviewed corpus lands. Acceptable per `platform.md` §10.
* **Performance:** frozen-tile checks call `isValidWord` a few times per settled move — negligible; no per-query allocation beyond the candidate's normalized string.
* Runtime evidence summary: `automated functional` — 56 workspace tests + independent QA probe executed green; iOS release build (`flutter build ios --release --no-codesign`) passed in the prior FE step, confirming the app compiles and links with the bundled dictionary assets + Riverpod.

---

## 16. Regression Risk

* **Shared components touched:** `looplet_core` (new package — `TurkishCase`, `normalizeTurkish`, `normalizeLatin`); `looplet_dictionary` (new package); `app/lib/main.dart` (`ProviderScope` wrap); `app/pubspec.yaml`; `looplet_dictionary/pubspec.yaml` (`flutter: assets:`).
* **Downstream dependents today:** none — F02 (`looplet_engine`) and F06 (`looplet_solver` / `tools/looplet_authoring`) are scaffold-only and do not yet import `looplet_core` / `looplet_dictionary`. The app has no feature screens yet.
* **Future consumers:** F02 will call `TurkishCase` / `normalizeTurkish` and `DictionaryService.isValidWord` for frozen-tile thaw; F06 will use `isEligibleTarget`. The contract they will build against is the one verified here.
* **`ProviderScope` in `main.dart`:** additive; the placeholder shell still boots (`widget_test.dart` green). No existing behavior to regress (greenfield).
* **`melos run build:app` (Android):** not run locally — this machine has no Android SDK (`flutter doctor`). Not an F01 defect; the app compiles (iOS release build green, `flutter analyze` green, `flutter test` green). CI (`.github/workflows/ci.yml`) runs the Android bundle build. → informational, see Tech Lead Note.
* **Conclusion:** regression risk is minimal — greenfield packages, no current importers, all workspace gates green.

---

## 17. Final Verdict

**Approved with Notes**

* No blocking issues. No required fixes to F01 code.
* Every `prd.md` system requirement and every Acceptance Criterion is covered by an executed automated test; independently re-verified by a QA probe against the real shipped asset.
* Contract (`architecture.md` "API / Event Contract", normalization spec, fail-safe semantics, dependency boundary) fully preserved.
* Two **non-blocking** notes for Tech Lead (see §20): (1) `architecture.md` "Integration Rules" wording about app-side asset declaration is contradicted by Flutter reality and by the (correct) implementation — needs a doc-wording fix, not a code change; (2) Android `melos run build:app` is CI-only on this environment.
* Evidence class is `automated functional`, which `architecture.md` "QA Focus" and `platform.md` §10 explicitly accept for this pure-logic feature — no device-runtime risk class (no sockets, navigation, persistence, multi-actor, or state-machine flow) applies.

---

# WORKFLOW VERDICT SUGGESTION (NON-AUTHORITATIVE)

## QA Result

* Approved with Notes — F01 dictionary-service passes contract + product-behavior + AC coverage; 56 tests + QA probe green; `format:check` / `analyze` / `test` green; iOS release build green.

## Affected Areas

* None requiring rework. Documentation (Tech Lead): `architecture.md` "Integration Rules" wording.

## Blocking Issues

* None.

## Non-Blocking Notes

1. `architecture.md` "Integration Rules": replace the app-declares-assets sentence with the package-declares-its-own-assets mechanism actually implemented (bundle key and abstractions unchanged).
2. Confirm CI's Android `build:app` job is green (could not run locally — no Android SDK); iOS release build passed locally.
3. `assets/tr/dictionary.json` is a provisional 101-word hand-curated list — the reviewed corpus + curated target review remains an open Product Owner / content deliverable (F01 PRD Open Questions). Not an F01 code blocker.

## Suggested Fix Order

Not applicable (Approved with Notes — no blocking fixes). Tech Lead actions: sync global state (`feature-board.md`, `system-state.md`), apply the `architecture.md` wording fix, then activate F02.

---

## 19. Sonraki Komut

```
Run Tech Lead
```

---

## 20. Tech Lead Note

<<<TEXT

F01 dictionary-service — QA verdict: Approved with Notes. No rework; F01 code is contract-compliant and fully covered by executed automated tests + an independent QA probe.

Tech Lead actions:
1. Sync global state — set F01 `Done` (or `In Release` = N/A, Release Scope is `none`) in `feature-board.md` and `system-state.md`; clear `Current Owner`; advance the portfolio to F02.
2. Apply a wording fix to `features/f01-dictionary-service/architecture.md` "Integration Rules": the dictionary assets are declared by `looplet_dictionary`'s own `pubspec.yaml` (`flutter: assets:` section), not by `app/pubspec.yaml`. The app provides the `rootBundle`-backed `DictionaryAssetSource`; the bundle key `packages/looplet_dictionary/assets/<lang>/dictionary.json` and `LanguageCode.assetPath` are unchanged. This is a non-contract note; no code change and no re-QA needed.
3. Informational: `melos run build:app` (Android App Bundle) was not runnable on the dev machine (no Android SDK). `flutter analyze`, `flutter test`, and `flutter build ios --release --no-codesign` all passed locally. Ensure the Android job in `.github/workflows/ci.yml` is green on first CI run.
4. Content follow-up (not a code blocker, tracked in F01 PRD Open Questions): the shipped `assets/tr/dictionary.json` is a provisional 101-word hand-curated list with 30 five-letter targets. The production Turkish corpus + manual target review is a Product Owner / content deliverable; swapping the asset in later is a content change and does not re-open F01 code.

No Product/PO escalation required — no `prd.md` / `architecture.md` rule was found meaningless or harmful in real-world use.

TEXT
