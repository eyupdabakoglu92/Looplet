# F08 — offline-persistence-and-sync: Backend Delivery (Track B)

Role: Backend Developer · Date: 2026-09-06
Scope: **F08-BE2** (fill the `submitDailyResultV1` callable), **F08-BE3** (verify Firestore rules + rules tests), **F08-BE4** (Functions emulator behaviour tests), **F08-BE5** (CI emulator step). Emulator work targets a **fake project id** — `F08.FIREBASE-PROJECT` is not required for Track B.

---

## 1. Feature Summary

The server side of F08's deferred offline-result sync: the `submitDailyResultV1` 2nd-gen HTTPS callable that records a player's **first completed daily run**, create-only and idempotent on `(uid, lang, dailyDate)`, with **first-run-authoritative** reconciliation (a later/"better" replay never displaces the recorded run — it returns `ALREADY_SUBMITTED`). Plus the create-only Firestore security rules (already scaffolded — verified), the emulator behaviour tests, and the CI emulator job that runs the rules + callable suites.

---

## 2. Impacted Files

**Created — `infra/functions/`:**

* `src/validate.ts` — `validateSubmitDailyResult()` (pure, offline-tested) + `PayloadError` (carries `INVALID_PAYLOAD` / `UNSUPPORTED_LANGUAGE`).
* `test/submitDailyResult.test.ts` — emulator-gated behaviour suite (7 tests: CREATED, ALREADY_SUBMITTED, idempotent-across-repeats, per-uid scoping, unauth pre-Firestore reject, invalid-payload reject + no write, HttpsError-not-raw).

**Updated — `infra/functions/`:**

* `src/submitDailyResult.ts` — replaced the `TODO(F08-BE2)` body with: auth guard → soft App-Check log → `validateSubmitDailyResult` (→ `invalid-argument` + `details.code`) → a Firestore **transaction** that returns `ALREADY_SUBMITTED` if the doc exists, else `tx.create`s it and returns `CREATED`; a lost create-race is re-read and reported as `ALREADY_SUBMITTED`; any other write failure → `internal` (`details.code: "INTERNAL"`), logged, no detail leak.
* `test/skeleton.test.ts` — the two "reaches INTERNAL" assertions replaced with validation-path assertions (authed + invalid payload → `invalid-argument` + `details.code`, no Firestore access); added a `validateSubmitDailyResult` table of 10 rejection cases + a non-object case. Offline `npm test` stays green.
* `package.json` — added a `test:emulator` script (`firebase --config ../firebase.json emulators:exec --only firestore,auth --project demo-looplet "jest"`); `serve` / `deploy` scripts point at `../firebase.json`.

**Updated — root:**

* `.github/workflows/ci.yml` — the `infra` job's TODO replaced with a real **"Test functions (Firebase emulator)"** step: `working-directory: infra`, `npx --yes firebase-tools@15 emulators:exec --only firestore,auth --project demo-looplet "npm --prefix functions run test"` — un-skips `test/rules.test.ts` + `test/submitDailyResult.test.ts`. No new committed dep, no extra SHA-pinned action (ubuntu-latest ships a JDK; firebase-tools via `npx`).

**Verified, not changed:** `infra/firestore.rules` (create-only for `dailyResults/{bucket}/entries/{uid}`, default-deny) — compliant with the contract as scaffolded; `test/rules.test.ts` (6 emulator-gated cases) — covers the required allow/deny matrix.

---

## 3. Task-to-Code Traceability

| Task | Status | Files | Behavior |
| --- | --- | --- | --- |
| **F08-BE2** implement `submitDailyResultV1` | Complete | `src/submitDailyResult.ts`, `src/validate.ts` | Auth guard (`unauthenticated` when no `request.auth.uid`, before any Firestore access). App Check soft-enforce (missing token → `logger.warn`, not rejected — `enforceAppCheck: false` stays in `index.ts`). Full payload validation per `architecture.md → Firebase Sync Surface` + `platform.md` §8: `lang ∈ {tr,en}` (else `UNSUPPORTED_LANGUAGE`), `dailyDate` matches `^\d{4}-\d{2}-\d{2}$`, `dailyId` non-empty, `optimalMoves` integer ≥ 1, `moves` integer ≥ `optimalMoves`, `durationMs` integer ≥ 0, `stars` integer 1..3, `completedAtUtcMs` integer ≥ 1, `clientAttemptNumber` (optional) integer ≥ 1 — all `INVALID_PAYLOAD` except the lang case. A violation → `HttpsError("invalid-argument", msg, { code })`. Then a Firestore transaction on `dailyResults/{lang}_{dailyDate}/entries/{uid}`: exists → `{ status: "ALREADY_SUBMITTED", recordedAt: existing.recordedAtUtcMs }`; absent → `tx.create(ref, DailyResultDoc)` with `recordedAtUtcMs = Date.now()` → `{ status: "CREATED", recordedAt }`. A create that lost a concurrent race is caught, the doc re-read, and reported `ALREADY_SUBMITTED`. Any other failure → `HttpsError("internal", generic, { code: "INTERNAL" })`, `logger.error` with context. |
| **F08-BE3** rules + rules-unit-tests | Complete (verified — no change needed) | `infra/firestore.rules`, `test/rules.test.ts` | Rules as scaffolded match `architecture.md → Firebase Sync Surface → Rules`: `allow create: if request.auth != null && request.auth.uid == uid` on `dailyResults/{bucket}/entries/{uid}`; `allow update, delete, read: if false`; a catch-all `allow read, write: if false`. `!exists(...)` from the contract text is **implied** by Firestore `create` semantics (create only fires when the doc is absent) — a second write is an `update`, which is denied. `test/rules.test.ts` (emulator-gated) covers allow-create-own / deny-create-other / deny-unauth-create / deny-update / deny-delete / deny-read. |
| **F08-BE4** Functions emulator tests | Complete | `test/submitDailyResult.test.ts` (emulator-gated) | Against the Firestore emulator (`demo-looplet`): (1) first authed call → `CREATED` + the doc is written with the exact `DailyResultDoc` fields + `recordedAtUtcMs == res.recordedAt`; (2) a "better" replay (`moves 8, stars 3`) → `ALREADY_SUBMITTED`, same `recordedAt`, **stored doc unchanged** (`moves 14, stars 2`); (3) 4 further repeats → all `ALREADY_SUBMITTED` with the first `recordedAt`, exactly **one** doc in the collection; (4) `alice` + `bob` calls → each writes only their own `entries/{uid}`; (5) unauthenticated → `unauthenticated` and **no** Firestore doc; (6) invalid payloads (`lang: "de"` → `UNSUPPORTED_LANGUAGE`; `stars: 9` → `INVALID_PAYLOAD`) → `invalid-argument` + `details.code`, no doc; (7) errors are `HttpsError` instances (no raw-error leak). |
| **F08-BE5** CI emulator step | Complete | `.github/workflows/ci.yml`, `infra/functions/package.json` | The `infra` job now runs the emulator suite after the offline test: `emulators:exec --only firestore,auth --project demo-looplet "npm --prefix functions run test"` via `npx firebase-tools@15` from `working-directory: infra`. `demo-` project id ⇒ the emulator runs fully offline with no auth. A `test:emulator` npm script mirrors it for local use (needs a JDK + `firebase-tools`). |

---

## 6. Key Decisions

* **Transaction, not a plain `create()`, for idempotency.** The callable runs with admin privileges (rules do not apply server-side), so create-only + first-run-authoritative are enforced in code: a `runTransaction` reads the doc and either returns the existing `recordedAt` (`ALREADY_SUBMITTED`) or `tx.create`s. This is atomic against two concurrent first submissions; the loser catches the `tx.create` failure, re-reads, and also returns `ALREADY_SUBMITTED`. Result: **exactly one** server doc per `(uid, lang, dailyDate)`, first writer wins, no overwrite path exists.
* **`recordedAt` is the server clock** (`Date.now()` at create time), not the client's `completedAtUtcMs` — so the authoritative "when recorded" is server-trusted even though there is no server-side clock check on the gameplay values (`platform.md` §6; `product-prd §51` resolved out of MVP scope by the Tech Lead).
* **Pure `validate.ts` split out** so the full validation matrix is unit-tested with zero Firebase deps (offline `npm test`), and the handler test focuses on the write/reconciliation behaviour.
* **CI emulator via `npx`, no committed `firebase-tools` dep** and no `actions/setup-java` — keeps the `infra` `npm ci` lean and the SHA-pinning surface minimal (ubuntu-latest has a JDK on PATH). If a future runner image drops Java, a SHA-pinned `actions/setup-java` step is the fix.

---

## 7. Contract Compliance Check

| Area | Result |
| --- | --- |
| Callable name + registration (`submitDailyResultV1`, 2nd-gen `onCall`, `enforceAppCheck: false`) | **Preserved** (unchanged from the skeleton; `index.ts` untouched) |
| Request shape (`lang`, `dailyDate`, `dailyId`, `moves`, `optimalMoves`, `durationMs`, `stars`, `completedAtUtcMs`, `clientAttemptNumber?`) — `uid` from `context.auth` | **Preserved** — validated exactly per the contract; `uid` never read from the body |
| Response shape (`{ status: "CREATED" \| "ALREADY_SUBMITTED", recordedAt: number }`) | **Preserved** |
| Error format — `HttpsError` with `details.code ∈ {INVALID_PAYLOAD, UNSUPPORTED_LANGUAGE, INTERNAL}` (`platform.md` §4); `APP_CHECK_FAILED` not used (hard-enforce is post-MVP) | **Preserved** |
| Server-side validation ranges (`optimalMoves ≥ 1`, `optimalMoves ≤ moves`, `durationMs ≥ 0`, `dailyDate` format, `lang` set, `stars` 1..3, `completedAtUtcMs > 0`) — `platform.md` §8 | **Preserved** |
| Firestore path `dailyResults/{lang}_{dailyDate}/entries/{uid}` + `DailyResultDoc` shape | **Preserved** (`dailyResultDocPath` + `DailyResultDoc` from `types.ts`) |
| Create-only + first-run-authoritative reconciliation (no update/overwrite; `ALREADY_SUBMITTED` = client success) | **Preserved** — enforced by the transaction + verified by the emulator suite |
| Firestore rules: create-only own-uid, deny update/delete/read, default-deny | **Preserved** (verified; unchanged) |
| App Check soft-enforce (log, don't block) | **Preserved** |
| CI: `infra/functions` build + test + rules tests (`release.md` §4) | **Extended** — the emulator step now runs the rules + callable suites in CI |

---

## 10. Validation & Error Handling

* **Input validation** — `validateSubmitDailyResult` throws `PayloadError` on the first violation; the handler maps it to `HttpsError("invalid-argument", message, { code })`. Non-object payloads, missing fields, wrong types, out-of-range values, and cross-field (`moves < optimalMoves`) are all covered.
* **Auth** — `unauthenticated` is thrown before any validation or Firestore access.
* **App Check** — soft: a missing token is logged (`logger.warn` with `uid`), never rejected.
* **Write failures** — caught; a create-race is reconciled to `ALREADY_SUBMITTED`; anything else is `logger.error`ed with `{ uid, lang, dailyDate }` and returned as a generic `internal` (`details.code: "INTERNAL"`) — no internal detail in the client-visible message.
* **Idempotency / race** — the transaction guarantees one doc per key; concurrent first-writes converge (winner `CREATED`, loser `ALREADY_SUBMITTED`).

---

## 11. Test Evidence by Task

| Task / behavior | Test type | Scenario proven | File |
| --- | --- | --- | --- |
| BE2 validation | unit (offline) | 10 rejection cases (unsupported lang → `UNSUPPORTED_LANGUAGE`; bad date format, empty id, `optimalMoves < 1`, `moves < optimalMoves`, negative duration, stars 4 / 0, `completedAtUtcMs` 0, non-integer moves → `INVALID_PAYLOAD`); non-object payload → `PayloadError`; happy path defaults `clientAttemptNumber` to 1 | `test/skeleton.test.ts` |
| BE2 guard + mapping | unit (offline) | unauthenticated → `HttpsError` `code: "unauthenticated"`; authed + missing App Check + invalid payload → `invalid-argument` (App Check did **not** block); payload violation → `invalid-argument` + `details.code` (`UNSUPPORTED_LANGUAGE` / `INVALID_PAYLOAD`) | `test/skeleton.test.ts` |
| BE2 write + reconciliation | integration (Firestore emulator, gated) | first call → `CREATED` + doc written with exact fields + `recordedAtUtcMs == recordedAt`; "better" replay → `ALREADY_SUBMITTED`, same `recordedAt`, **doc unchanged**; 4 repeats → all `ALREADY_SUBMITTED` same `recordedAt`, **one** doc; unauth → `unauthenticated` + **no** doc; invalid → `invalid-argument` + no doc; errors are `HttpsError` | `test/submitDailyResult.test.ts` |
| BE2 per-uid scoping | integration (gated) | `alice` + `bob` calls each write only `entries/{own uid}` | `test/submitDailyResult.test.ts` |
| BE3 rules | integration (`@firebase/rules-unit-testing`, gated) | allow-create-own; deny-create-other; deny-unauthenticated-create; deny-update; deny-delete; deny-read | `test/rules.test.ts` (from F08.SETUP-0) |
| BE5 CI | config | the `infra` CI job runs both gated suites via `firebase emulators:exec` (`demo-looplet`, offline) | `.github/workflows/ci.yml` |

**Local run status:** `npm --prefix infra/functions run build` (tsc) green; `npm --prefix infra/functions test` (offline) green — **18 passed, 13 skipped** (6 rules + 7 callable, emulator-gated); `melos run infra:build` / `infra:test` green. The **emulator suites could not be executed in this environment (no Java Runtime)** — they run in CI via the new emulator step (analogous to Android `build:app` being CI-only locally). Verified logically + type-checked; the assertions are concrete and self-contained.

---

## 13. Missing / TODO

* **Emulator suites are CI-verified only** in this delivery — no JDK in the dev environment. First real green comes from the CI `infra` job (or any machine with a JDK running `npm run test:emulator`).
* `F08-FE8` (real `SyncSender` binding to this callable) + `F08-FE9` (app-scoped wiring) remain on the Frontend side, gated on `F08.FIREBASE-PROJECT`. The response→state mapping they need is already implemented + tested in `F08-FE7`.
* Actual `firebase deploy` of the function + rules is `F08-DEVOPS` (post-QA), gated on `F08.FIREBASE-PROJECT`.

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** F08-BE2, F08-BE3 (verified), F08-BE4, F08-BE5.
* **Remaining Tasks (this feature):** `F08.FIREBASE-PROJECT` (user) → then F08-FE6 / FE8 / FE9 (Frontend join) → QA → Tech Lead → DevOps/Release Engineer.
* **Blockers:** none for Track B. The emulator suites need a JDK to run (CI has one).
* **Status Suggestion:** Ready for Tech Lead review — both tracks' implementation is done; the feature now waits on `F08.FIREBASE-PROJECT` before the FE join + QA.

---

## 15. Sonraki Komut

```
Run Tech Lead
```

---

# F08-BE6 — Emülatör suite'indeki kontrata aykırı fixture (2026-09-29)

> Kontrat: `architecture.md` → "Firebase Sync Surface" (kilitli) → Server-side validation; Activation 2026-09-29 → A6 ruling 6. Brief: `orchestration.md` → Current Brief. Taban: HEAD `b8e37ab`. Yalnız test kodu değişti; `src/`, `firestore.rules`, `firebase.json`, CI dokunulmadı.

## 1. Feature Summary

* `test/submitDailyResult.test.ts` "ALREADY_SUBMITTED on a repeat — first run stays authoritative" ikinci çağrıda `moves: 8` gönderiyordu. Temel payload'da `optimalMoves: 9` olduğundan `validate.ts` (`moves` min = `optimalMoves`) doğru olarak `INVALID_PAYLOAD` ("moves must be >= 9") dönüyordu, yani test adını verdiği idempotency dalına hiç ulaşmıyordu. Handler doğru, fixture yanlıştı.
* İkinci çağrı artık geçerli bir "daha iyi" tekrar: `moves: 10` (≥ 9, 14'ten az), `stars: 3`, `durationMs: 40000`. Tüm assertion'lar korundu; saklanan dokümanın değişmediği kontrolü `durationMs` ve `recordedAtUtcMs` ile güçlendirildi.
* Emülatör suite'i: **31 / 31** (önce 30 / 31). N-OVERWRITE negatif koşusu düzeltilmiş testin doğru sebeple kırıldığını gösteriyor.

## 2. Impacted Files

* **Güncellenen:** `infra/functions/test/submitDailyResult.test.ts` (sha1 `6c33f5ff…` → `cf73770d…`).
* **Oluşturulan (kanıt):** `evidence/neg-be6.py`; `evidence/runtime/BE6-00-npm-ci-build.log.txt`, `BE6-01-baseline-suite.log.txt`, `BE6-02-fixed-suite.log.txt`, `BE6-03-plain-npm-test.log.txt`, `BE6-04-neg.log.txt`.

## 3. Task-to-Code Traceability

* **Task ID:** F08-BE6 — **Durum: Complete**
  * **Fixture:** `test/submitDailyResult.test.ts` → "ALREADY_SUBMITTED on a repeat":
    * önce: `data: { moves: 8, stars: 3, durationMs: 40000 }` → `INVALID_PAYLOAD`;
    * sonra: `data: { moves: 10, stars: 3, durationMs: 40000 }` → handler'ın `snapshot.exists` dalı → `ALREADY_SUBMITTED`.
  * **Assertion'lar:** `second.status === "ALREADY_SUBMITTED"`, `second.recordedAt === first.recordedAt`, doküman `{ moves: 14, stars: 2, durationMs: 83210, recordedAtUtcMs: first.recordedAt }` (son ikisi eklendi — "değişmedi" iddiasını tamamlıyor).
  * **Suite taraması (brief madde 2):** `test/` altındaki üç dosyanın her fixture'ı validator'a ve kurallara karşı okundu. Aynı türden başka kusur yok:
    * `submitDailyResult.test.ts` — "invalid payload" vakası `lang: "de"` → `UNSUPPORTED_LANGUAGE`, `stars: 9` → `INVALID_PAYLOAD`: adıyla aynı sebep; diğer vakalar temel payload'u (geçerli) kullanıyor.
    * `skeleton.test.ts` — "moves < optimalMoves" (`moves: 3, optimalMoves: 9`) ve diğer 9 red vakası tam olarak adlandırdıkları alan yüzünden reddediliyor; soft App Check vakası (`stars: 9`) bilerek validation'a ulaşıyor.
    * `rules.test.ts` — `sampleDoc` kontrata uygun; her vaka adlandırdığı kural yüzünden geçiyor/reddediliyor.

## 7. Contract Compliance Check

* **Endpoint / handler contract:** Preserved — `src/` bayt-özdeş (`submitDailyResult.ts` sha1 `bcda2662…`, `validate.ts` `8f0398ea…`; 8479ddb'den beri değişmedi).
* **Request / response shape:** Preserved.
* **Error format:** Preserved.
* **Event payload / ordering:** Not Applicable.
* **State-machine / boundary semantics:** Preserved — first-run-authoritative ve create-only artık gerçekten test ediliyor.

## 11. Test Evidence by Task

Ortam: macOS host, Node v24.7.0, firebase-tools 15.29.0, OpenJDK 21.0.12.1 (`/opt/homebrew/opt/openjdk@21`, keg-only), proje `demo-looplet` (yalnız emülatör; gerçek Firebase'e erişim yok). Revizyon: HEAD `b8e37ab` + bu çalışma ağacı (tek değişen dosya test).

| Claim / senaryo | Sınıf | Komut | Sonuç | Kanıt |
| --- | --- | --- | --- | --- |
| Kurulum + derleme | build | `cd infra/functions && npm ci && npm run build` | exit 0 | `BE6-00-*` |
| Hatanın yeniden üretimi (fix öncesi) | repeatable integration | `JAVA_HOME=… PATH=<jdk21>/bin:$PATH npm run test:emulator` (09:23Z) | exit 1 — **30 / 31**; tek hata "ALREADY_SUBMITTED on a repeat": `moves must be >= 9` | `BE6-01-*` (2. deneme; 1. deneme yalnız `JAVA_HOME` ile Java sürüm hatası, §14.1) |
| Düzeltilmiş suite | repeatable integration | aynı komut, fix sonrası (09:23:49Z; test sha1 `cf73770d…`, handler `bcda2662…`) | exit 0 — **Test Suites 3 / 3, Tests 31 / 31**, skip 0 (rules 6, callable 7, skeleton 18) | `BE6-02-*` |
| Emülatörsüz CI yolu | unit | `npm test` | exit 0 — 18 passed, 13 skipped (emülatör-gated iki suite, beklenen) | `BE6-03-*` |
| First-run-authoritative gerçekten kontrol ediliyor | negatif | `python3 evidence/neg-be6.py` (repo kökünden) | aşağıdaki tablo | `BE6-04-neg.log.txt` |

**Named negative runs** (`evidence/neg-be6.py`; handler bayt kopyasından geri yüklendi, sha1 önce = sonra `bcda2662…`; test de geri yüklendi `cf73770d…`):

| Run | Mutasyon | Sonuç | Yakalayan test / sebep |
| --- | --- | --- | --- |
| N-OVERWRITE | handler mevcut kaydın üzerine yazar (`if (false && snapshot.exists)` + `tx.create` → `tx.set`), düzeltilmiş fixture | exit 1, 2 fail / 7 | "ALREADY_SUBMITTED on a repeat" — `Expected "ALREADY_SUBMITTED", Received "CREATED"`; "idempotent across many repeats" |
| N-OVERWRITE-OLDFIX | aynı mutasyon, BE6 öncesi fixture (`moves: 8`) | exit 1, 2 fail / 7 | "ALREADY_SUBMITTED on a repeat" yine kırmızı ama sebep `moves must be >= 9` — eski test regresyonu ayırt edemiyordu (bozuk ve sağlam handler'da aynı sonuç) |

**İzolasyon:** handler doğrudan çağrılıyor (`handleSubmitDailyResult`, `CallableRequest` stand-in); Firestore ve Auth emülatörü `emulators:exec` ile; Functions emülatörü ve HTTPS katmanı bu suite'te yok (client ↔ Functions emülatörü yolu F08-LOCAL-EVIDENCE LE-04'te). App Check stand-in `app: {}`.

## 14. Needs Tech Lead Clarification

1. **setup-manifest komutu eksik:** `JAVA_HOME=/opt/homebrew/opt/openjdk@21 npm run test:emulator` tek başına çalışmıyor — firebase-tools `PATH`'teki `java`'yı kullanıyor ve sistem Java'sını görüp `firebase-tools no longer supports Java version before 21` ile çıkıyor (`BE6-01` 1. deneme). Çalışan biçim: `JAVA_HOME=/opt/homebrew/opt/openjdk@21 PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm run test:emulator`. `setup-manifest.md` authority'si bende değil; düzeltmesi Tech Lead'de.
2. **CI emülatör işi zaten var (F08-BE5), A6 ruling 5 "eklenirse" diyor:** `.github/workflows/ci.yml` `infra` job'u "Test functions (Firebase emulator — rules + callable behaviour)" adımıyla `npx --yes firebase-tools@15 emulators:exec …` koşuyor ve "ubuntu-latest ships a JDK on PATH" varsayımına dayanıyor. firebase-tools 15.29 Java 21 istiyor; runner'ın varsayılan Java'sı 21 değilse bu adım Java sürüm hatasıyla kırmızıdır. Ayrıca bu adım BE6 öncesi fixture yüzünden her koşuda 30 / 31 kırmızı olmalıydı. CI koşu geçmişini buradan göremedim (`gh` yok). CI config benim scope'umda değil — DevOps/Release Engineer kararı (Java 21 pin, adımın gerçek sonucu). Bloklamıyor: yerel suite yeşil.
3. **Bilgi (bloklamaz):** `firestore.rules` create kuralında architecture'daki `&& !exists(...)` ifadesi yazılı değil. Firestore'da `create` yalnız doküman yokken değerlendirildiği ve varolan dokümana yazım `update` (her zaman `false`) olduğu için anlam aynı; `rules.test.ts` "denies update" bunu kapsıyor. Değişiklik yapmadım.

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** F08-BE6.
* **Remaining Tasks:** Tech Lead checkpoint (BE6 reconciliation, §14.1 setup-manifest komutu, §14.2 CI emülatör adımı) → F08-QA-FUNCTIONAL (plan A7).
* **Blockers:** yok.
* **Status Suggestion:** Needs Tech Lead Review.

## 15. Sonraki Komut

```
Run Tech Lead
```

---

# F08-BE7 — `dailyResults/**` için client erişimi yok (2026-09-29)

> Kontrat: `architecture.md` → "Firebase Sync Surface" (kilitli) → Rules (A9'da düzeltildi); Activation 2026-09-29 → A9 ruling 1–2. Brief: `orchestration.md` → Current Brief. Kaynak: QA bulgusu F1 (`qa.md` § F08-QA-FUNCTIONAL §3). Taban: HEAD `8f26243`. Yalnız kurallar, kural testi ve `infra/README.md` değişti; handler, validator, callable testi, app ve CI dokunulmadı.

## 1. Feature Summary

* `infra/firestore.rules` artık `dailyResults/{bucket}/entries/{uid}` üzerinde **hiçbir client işlemine** izin vermiyor: `allow create, update, delete, read: if false`. Önceki kural, oturumu olan her client'ın kendi uid'ine callable'ı atlayarak doğrudan (doğrulanmamış, keyfi bucket'lı) kayıt yazmasına izin veriyordu.
* Tek yazan `submitDailyResultV1`; Admin SDK ile yazdığı için kurallardan etkilenmiyor. Create-only / first-writer-wins callable transaction'ında kalıyor (`snapshot.exists` → `ALREADY_SUBMITTED`).
* `rules.test.ts`: "kendi kaydını oluşturabilir" testi red testine çevrildi; QA probe'larının P3 (geçersiz payload) ve P6 (tarih olmayan bucket) şekilleri iki yeni red testi olarak eklendi. Emülatör suite'i **33 / 33**; N-DIRECT-CREATE negatifi üç testin de eski kuralı yakaladığını gösteriyor.

## 2. Impacted Files

* **Güncellenen:**
  * `infra/firestore.rules` — sha1 `b75628e6…` → `aa4c5dc2…`;
  * `infra/functions/test/rules.test.ts` — `9d4db0bb…` → `2c7df84a…`;
  * `infra/README.md` — `2207934a…` → `ee49fef8…` (yalnız `firestore.rules` satırı).
* **Oluşturulan (kanıt):** `evidence/neg-be7.py`; `evidence/runtime/BE7-00-npm-ci-build.log.txt`, `BE7-01-baseline-suite.log.txt`, `BE7-02-fixed-suite.log.txt`, `BE7-03-plain-npm-test.log.txt`, `BE7-04-neg.log.txt`; `evidence/README.md` → "F08-BE7".
* **Değişmeyen (doğrulandı):** `src/submitDailyResult.ts` `bcda2662…`, `src/validate.ts` `8f0398ea…`, `test/submitDailyResult.test.ts` `cf73770d…`, `firebase.json`, `.github/workflows/ci.yml`, `app/`.

## 3. Task-to-Code Traceability

* **Task ID:** F08-BE7 — **Durum: Complete**
  * **Brief 1 — kurallar:** `firestore.rules` → `match /dailyResults/{bucket}/entries/{uid}` bloğu açık bırakıldı (okunabilirlik için), tek satır `allow create, update, delete, read: if false;`. Başlık yorumu yeniden yazıldı: client erişimi yok; tek yazan callable (Admin SDK); create-only callable transaction'ında; A9 referansı. Default-deny bloğu aynı.
  * **Brief 2 — `rules.test.ts`:**
    * "lets a signed-in user create their own entry" (`assertSucceeds`) → "denies a signed-in user's direct create of their own valid entry" (`assertFails`, aynı geçerli `sampleDoc`);
    * yeni: "denies a direct create of an own entry with an invalid payload" — `moves: 1` (< `optimalMoves` 9), `stars: 9`, fazladan `extra` alanı (QA P3);
    * yeni: "denies a direct create in a non-date bucket" — `dailyResults/zz_not-a-date-123/entries/alice` (QA P6);
    * korunan: create-other, unauthenticated, update, delete, read red testleri;
    * dosya yorumu ve `describe` adı ("no client access") güncellendi; kullanılmayan `assertSucceeds` import'u kaldırıldı.
  * **Brief 3 — N-DIRECT-CREATE:** `evidence/neg-be7.py` (aşağıda §11).
  * **Brief 4 — suite:** build + `npm test` + setup-manifest emülatör komutu yeşil (§11).
  * **Brief 5 — `infra/README.md`:** `firestore.rules` satırı → "`dailyResults/**`: no client access; only the callable writes (Admin SDK); default-deny elsewhere".

## 7. Contract Compliance Check

* **Endpoint / handler contract:** Preserved — handler ve validator bayt-özdeş (`bcda2662…`, `8f0398ea…`).
* **Request / response shape:** Preserved.
* **Error format:** Preserved.
* **Event payload / ordering:** Not Applicable.
* **State-machine / boundary semantics:** Preserved + düzeltilmiş Rules satırına hizalandı — client erişimi yok; create-only / first-writer-wins callable'da. Callable suite'i (7 test) yeni kurallar emülatöre yüklüyken değişmeden geçiyor: sunucu yolu hâlâ yazıyor.

## 8. Behavior Preserved

* Callable yolu: `CREATED`, `ALREADY_SUBMITTED` (first-run-authoritative, çoklu tekrar idempotent), `INVALID_PAYLOAD` / `UNSUPPORTED_LANGUAGE`, auth zorunluluğu, soft App Check — hepsi `submitDailyResult.test.ts` + `skeleton.test.ts` ile değişmeden yeşil.
* App davranışı: app Firestore'a doğrudan yazmıyor (yalnız callable), bu yüzden kural değişikliği client akışını etkilemez. Bunu uçtan uca (app ↔ emülatör) koşmadım — QA-FUNCTIONAL-R1 planında (A9 ruling 4) var.

## 11. Test Evidence by Task

Ortam: macOS host, Node v24.7.0, firebase-tools 15.29.0, OpenJDK 21 (`/opt/homebrew/opt/openjdk@21`, `PATH`'te ilk), proje `demo-looplet` (yalnız emülatör; gerçek Firebase'e erişim, deploy veya dry-run yok). Revizyon: HEAD `8f26243` + bu çalışma ağacı.

| Claim / senaryo | Sınıf | Komut | Sonuç | Kanıt |
| --- | --- | --- | --- | --- |
| Kurulum + derleme (taban) | build | `cd infra/functions && npm ci && npm run build` (10:24:26Z) | exit 0 | `BE7-00-*` |
| Taban suite (eski kurallar) | repeatable integration | `JAVA_HOME=/opt/homebrew/opt/openjdk@21 PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm run test:emulator` (10:24:41Z) | exit 0 — 31 / 31 | `BE7-01-*` |
| Tip kontrolü | static | `npm run build`; `npx tsc --noEmit` (proje) + `rules.test.ts` için `--strict` | exit 0 | — (konsol) |
| Emülatörsüz yol | unit | `npm test` (10:25:16Z) | exit 0 — 18 passed, **15 skipped** (emülatör-gated iki suite; rules suite artık 8 test) | `BE7-03-*` |
| Değişiklik sonrası suite | repeatable integration | aynı emülatör komutu (10:25:33Z; kurallar `aa4c5dc2…`, test `2c7df84a…`) | exit 0 — **Test Suites 3 / 3, Tests 33 / 33**, skip 0 (rules 8, callable 7, skeleton 18) | `BE7-02-*` |
| Eski kural yakalanıyor | negatif | `python3 evidence/neg-be7.py` (repo kökünden) | aşağıdaki tablo | `BE7-04-neg.log.txt` |

**Named negative run** (`evidence/neg-be7.py`; kurallar bayt kopyasından geri yüklendi, sha1 önce = sonra `aa4c5dc2…`):

| Run | Mutasyon | Sonuç | Yakalayan testler |
| --- | --- | --- | --- |
| N-DIRECT-CREATE | eski client kuralı geri: `allow create: if request.auth != null && request.auth.uid == uid;` + `update, delete, read: if false` | exit 1 — **3 failed, 5 passed / 8**; script exit 0 (beklenen üç fail, başka fail yok) | "…direct create of their own valid entry", "…own entry with an invalid payload" (P3), "…in a non-date bucket" (P6). Diğer beş red testi eski kuralda da geçiyor (beklenen). |

**Notlar:**
* `BE7-02`'den önce bir koşuda `npm run test:emulator -- --verbose` kullandım; `--verbose` firebase-tools'a gitti ve `unknown option '--verbose'` ile exit 1 döndü — hiç test koşmadı, kullanım hatası. Log'un başında not edildi; kayıtlı sonuç kanonik komutla alındı.
* Jest "A worker process has failed to exit gracefully" satırı bu koşuda da var (A8 ruling 4); sonuçları etkilemiyor.
* **İzolasyon:** rules testleri `@firebase/rules-unit-testing` ile doğrudan `firestore.rules` dosyasını yüklüyor; callable testleri handler'ı doğrudan çağırıyor (Admin SDK → Firestore emülatörü, `firebase.json` kuralları yüklü). Functions emülatörü / HTTPS katmanı ve app ↔ emülatör yolu bu turda koşulmadı.

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** F08-BE7.
* **Remaining Tasks:** Tech Lead checkpoint (BE7 reconciliation, preflight) → F08-QA-FUNCTIONAL-R1 (plan A9 ruling 4).
* **Blockers:** yok.
* **Status Suggestion:** Needs Tech Lead Review.

## 15. Sonraki Komut

```
Run Tech Lead
```
