# F08-QA-FUNCTIONAL — QA kanıtı (2026-09-29)

QA'nın bu turda kendisinin çalıştırdığı kanıt. İddialar ve sonuçlar: `../../qa.md` → "F08-QA-FUNCTIONAL". Revizyon: HEAD `84430c9`, `app/` tree `9de12e6a…`, `infra/functions` test `cf73770d…` / handler `bcda2662…` / `validate.ts` `8f0398ea…`, `firestore.rules` `b75628e6…`. Hedef: iPhone 16 simülatörü `D0011CE7-…`, iOS 18.6.

| Dosya | Ne |
| --- | --- |
| `QB-01…QB-04` | Backend kapısı: `npm ci` + build, `npm test`, emülatör suite'i (Java 21 PATH'te), N-OVERWRITE (`evidence/neg-be6.py`). |
| `QB-05-rules-probe.log`, `qa-probe-rules.test.ts` | QA'nın kural probu (P1–P6). Test dosyası yalnız koşu için `infra/functions/test/`'e kopyalandı, sonra silindi. |
| `QA-01…QA-05` | App: analyze + format, `melos run test`, `evidence/neg-fe13.py` (9 negatif), debug build, `flutter test integration_test`. |
| `QJ1*` | Okunamaz store (NOTADB) → karantina + recreate + `db_reinitialized`; ikinci bozulma → yalnız en yeni karantina. |
| `QJ2*` | Store yolu dizin (CANTOPEN) → hata ekranı → sebep varken Retry → yine hata → sebep kalkınca Retry → Home; PID aynı. |
| `QJ4*` | Resume: seviye 21, restart + L1 U3 R4 + undo + L0 D0 (erime) → kill → relaunch → birebir; `thawedFrozenCells` tamper → yeniden türetildi; restore sonrası undo / redo. |
| `QJ7*`, `raw/QJ7*` | Production-shaped cold boot (emülatör define'sız debug), boş ve mevcut store; video + kare-kare luma izi (`video-d2.swift trace`). |
| `QE-*`, `QL*`, `qcase.sh`, `qa-fn-proxy.py`, `qa-firebase.emulators.json` | Client ↔ emülatör vakaları A–E, M1/M2 (geçersiz payload → parked), L1/L2 (lifecycle), P1 (parked revival). `QE-cases.txt` vaka kaydı; `QE-proxy.log` istek kaydı; `QE-app-part1.log` / `QE-app2.log` app log'u. |
| `QR-*` | Emülatör define'lı release build: gate string taraması (UTF-8 + UTF-16LE). |
| `qa-f08.sh` | `evidence/ev-f08.sh`'in QA kopyası (çıktı bu klasöre). |

`qa-fn-proxy.py`, `evidence/fn-proxy.py`'nin kopyasıdır; tek fark 4xx/5xx yanıtlarını geçirmesi (teslim proxy'si `HTTPError`'da bağlantıyı kapatıyordu — bkz. qa.md N2).
