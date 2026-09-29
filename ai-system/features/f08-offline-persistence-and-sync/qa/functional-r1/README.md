# F08-QA-FUNCTIONAL-R1 — QA kanıtı (2026-09-29)

QA'nın bu turda kendisinin çalıştırdığı kanıt. İddialar ve sonuçlar: `../../qa.md` → "F08-QA-FUNCTIONAL-R1". Revizyon: HEAD `695f783` (F08-BE7 = cb96719 + yalnız doküman commit'i); `infra/firestore.rules` `aa4c5dc2…`, `rules.test.ts` `2c7df84a…`; değişmeyen: handler `bcda2662…`, `validate.ts` `8f0398ea…`, `submitDailyResult.test.ts` `cf73770d…`, `package-lock.json` `97187c5f…`; `app/` tree `9de12e6a…`, `app/pubspec.lock` `defec859…`. Hedef: macOS host (Node v24.7.0, firebase-tools 15.29.0, OpenJDK 21.0.12.1 PATH'te, Flutter 3.32.8) + iPhone 16 simülatörü `D0011CE7-…` (iOS 18.6).

| Dosya | Ne |
| --- | --- |
| `QB-R1-01-build.log`, `QB-R1-02-unit.log` | `npm ci` + `npm run build` (exit 0); `npm test` (18 passed, 15 skipped — emülatör-gated, exit 0). |
| `QB-R1-03-emulator.log` | setup-manifest komutu: `npm run test:emulator` — 3 / 3 suite, 33 / 33, exit 0. |
| `QB-R1-04-*` | N-OVERWRITE (`evidence/neg-be6.py`) — QA kopyası; teslim log'u `runtime/BE6-04-neg.log.txt` git'ten geri yüklendi. |
| `QB-R1-05-*` | N-DIRECT-CREATE (`evidence/neg-be7.py`) — QA kopyası; teslim log'u `runtime/BE7-04-neg.log.txt` git'ten geri yüklendi. |
| `qa-probe-rules-r1.test.ts`, `QB-R1-06-rules-probe.log` | QA kural probu R1 (P1–P8): P3 / P6 artık gözlem değil, `assertFails` (DENIED zorunlu) + belge yok kontrolü; P7 unauthenticated create, P8 sahibin okuması. Test dosyası yalnız koşu için `infra/functions/test/`'e kopyalandı, sonra silindi. |
| `QB-R1-07-rules-probe-control-old.log` | Aynı prob eski kurallarla (`git show 84430c9:infra/firestore.rules`, `b75628e6…`, `QA_RULES=`): yalnız P3 ve P6 fail — probun F1 regresyonunu yakaladığının kontrolü. |
| `QE-R1-setup.txt`, `QE-R1-emulators.log`, `QE-R1-build-emulator.log` | Emülatör kurulumu (auth 9099, firestore 8080, functions 5002; kurallar `aa4c5dc2…` kopyası), `--dart-define=LOOPLET_FIREBASE_EMULATOR=127.0.0.1` debug build, uninstall (store silindi) + keychain reset + install. |
| `QE-R1-00-direct-create-loaded-rules.txt` | Çalışan emülatöre, auth emülatöründen alınmış anonim ID token'ıyla doğrudan REST create (kendi entry'si, geçersiz payload; non-date bucket) → ikisi de HTTP 403 `PERMISSION_DENIED` (L21), 0 doküman. Yüklenen kuralların yeni kurallar olduğunun runtime kanıtı. |
| `QE-R1-cases.txt`, `QE-R1-proxy.log`, `QE-R1-app.log`, `QE-R1-A3-synced.png`, `qcase-r1.sh`, `qa-fn-proxy.py` | QE-A şekli: proxy `down` → produce → pending, 0 doc; `pass` + due sonrası çift drain → `CREATED`, **1 doc**, `synced`; toplam 2 istek (1 down + 1 pass). `qa-fn-proxy.py` = `qa/functional/qa-fn-proxy.py` (mode dosyası bu klasörde). |
