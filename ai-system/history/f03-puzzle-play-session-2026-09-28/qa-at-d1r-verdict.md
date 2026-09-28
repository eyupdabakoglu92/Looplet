# F03 — puzzle-play-session: QA Raporu (F03-QA-D1R — Loop Glass Play, metin ölçeği rework'ü sonrası final re-QA)

QA turu: 2026-09-28 · Görev: F03-QA-D1R · QA Stage: final · QA Scope: client-only · Release Scope: none · Visual Scope: existing-parity
Doğrulanan revizyon: HEAD `97c700e` + F03-FE-D1R çalışma ağacı (commit edilmemiş).
* `git diff 5798c70 -- app` yalnız `info.dart`, `play_session_screen.dart`, `play_test_support.dart`; izlenmeyen yeni dosyalar yalnız testler (`moves_card_ink_test.dart`, `text_ink_support.dart`, `load_error_headline_test.dart`).
* Diff SHA-1 `88f1dca3…`; `info.dart` `84f79b2c…`, `play_session_screen.dart` `7d903cc0…`.
* `packages/`, `tools/`, `pubspec.lock`, `melos.yaml`, `app/pubspec.yaml`, `app/ios` değişmedi (`git diff --stat 5798c70` boş).

Önceki tur F03-QA-D1 (Rejected, 87 / 100) byte-for-byte arşivde: [history/f03-puzzle-play-session-2026-09-27/qa-at-d1-verdict.md](../../history/f03-puzzle-play-session-2026-09-27/qa-at-d1-verdict.md). D1 kanıtı yerinde duruyor: [qa/d1/](qa/d1/).
Bu turun kanıt klasörü: [qa/d1r/](qa/d1r/):
* ekran görüntüleri `QA-*`, videolar `QV-*`, ölçüm kaydı `QM-d1r-measurements.txt`, büyütmeler `crops/`;
* QA'ya ait araçlar `qa/d1r/src/` (`qa-d1r.swift`, `qa-sweep.sh`, `qa-asset.sh`).

---

## 0. QA Execution Plan

* **Stage / Scope:** final / client-only; release scope yok (architecture §17).
* **Modüller + tetikleyici:**
  * `core` — her tur;
  * `client-ui` — `/play` header'ı (`MovesCard`) ve load-error ekranı değişti;
  * `visual-quality` — Visual Scope `existing-parity`, gate Ready for QA, rubric yeniden skorlanıyor;
  * `stateful-flow` — metin boyutunun canlı / arka planda değişmesi, AX5'te resume, kill/relaunch.
* **Regression Depth: full** (Tech Lead planı; final gate). Diff dar: shared design-layer `MovesCard` (tüketicileri Play + debug galerisi) ve `_LoadErrorView`. Değişen yüzey her boyutta ve üç cihazda yeniden çalıştırıldı. Değişmeyen yüzeyin D1 kanıtı fingerprint ile yeniden kullanıldı (§5).
* **Evidence Reuse: allowed** (§19.10 (5), §19.11). Diff'ten doğrulandı:
  * `MovesCard` `large`'da birebir 60 × 63·s (`grow = 0`; runtime'da R17);
  * gesture, zamanlama, persistence, route, tutorial ve won kodu değişmedi.
  * Geçersiz sayılanlar: `large` üstündeki her Play yakalaması, her boyutta load error, rubric.
* **Canonical target / runtime sınıfı:** iOS Simulator 18.6 — iPhone 16 `D0011CE7` (birincil), 16e `6DBDFD97`, 16 Pro Max `02FDE776`.
  * QA build: `flutter build ios --simulator --debug`, üç cihaza kuruldu (`App` SHA-1 `90c8db85…`).
  * State'e gerçek uygulama yoluyla gidildi: `design/src/seed-sim.sh` + Home DEVAM ET.
  * Metin boyutu `simctl ui content_size` ile **canlı** değiştirildi; ayrıca soğuk açılış ve arka planda değişim de denendi.
  * Kanıt sınıfları: runtime-screenshot, runtime-video (`simctl io recordVideo`), piksel ölçümü, sqlite okuması.
* **Bağımsızlık:** ölçümler QA'nın kendi aracıyla yapıldı (`qa-d1r.swift`).
  * Frontend'in `measure-d1r` aracı kartı PlayLayout sabitlerinden alıyordu. QA aracı ise kart dış hattını ve köşe yarıçapını her yakalamadan tarıyor / fit ediyor.
  * Araç önce negatif kontrollerle doğrulandı (R05).
* **Fail-fast checkpoint:** suite'ler + build (R01, R04) yeşil olunca runtime'a geçildi. Integration (R02) runtime turundan sonra çalıştı.

## 1. Evidence Ledger

Aksi belirtilmedikçe her satır **EXECUTED THIS RUN**: QA, 2026-09-28, yukarıdaki build ve üç simülatör. Ham sayılar `qa/d1r/QM-d1r-measurements.txt` içinde.

| Evidence ID | Claim / Scenario | Class | Command / Action | Target | Result / Counts | Provenance / Fingerprint | Isolation |
| --- | --- | --- | --- | --- | --- | --- | --- |
| R01 | Statik analiz + unit/widget + format | automated | `melos run analyze`; `melos run test`; `dart format --output=none --set-exit-if-changed app packages tools` | host, Flutter 3.32.8 / Dart 3.8.1 | analyze exit 0; test exit 0 — app **472 passed / 0 failed / 0 skipped**, engine 83, dictionary 32, authoring 25, solver 23, core 22, content 17; format 0 changed | WT diff `88f1dca3…`; 09:3x UTC | test dosyalarındaki override'lar; `moves_card_ink_test` gerçek glifleri rasterize ediyor |
| R02 | Cihazda integration: gesture, 0 çift sayım, resume + tampered cache, lifecycle | repeatable integration | `flutter test integration_test -d D0011CE7…` | iPhone 16 | **13 / 13 passed**, exit 0 | aynı WT | harness her testte in-memory DB açıyor (drift "created multiple times" debug uyarısı; test yapısı) |
| R03 | Fingerprint / kapsam | static | `git diff --stat 5798c70 -- app packages tools pubspec.lock melos.yaml` + dosya hash'leri | repo | yalnız 3 izlenen dosya + 3 yeni test dosyası; bağımlılık / config değişikliği yok | HEAD 97c700e + WT | — |
| R04 | QA build + kurulum | build | `flutter build ios --simulator --debug`; `simctl install` ×3 | 3 sim | exit 0; üçü kuruldu | App `90c8db85…` | — |
| R05 | QA ölçüm aracının negatif kontrolü | static (runtime yakalaması üzerinde) | `qa-d1r card` ve `headline`, D1'in rework öncesi yakalamaları | QA-16-16, QA-16-28 | kart: etiket inset **−3.80 pt**, 118 mürekkep pikseli dış hat dışında → yakalandı; başlık: 3 satır, "." **PUNCTUATION-ONLY** → yakalandı | qa/d1 (5798c70 build) | — |
| R06 | F03-QA-D1-01 re-test — `HAMLE` kartı, L26, large → AX5 (canlı) | runtime + ölçüm | Home DEVAM → L26; `qa-sweep.sh`; `qa-d1r card` | iPhone 16 | 5 boyutun hepsinde dış hat dışında **0** mürekkep pikseli (luma > 120 ve > 100). Etiket inset 3.00 / 3.69 / 3.67 / 3.41 / 3.41 pt; rakam ≥ 12.0 pt. Kart sol 300.0–300.3, üst **82.0** (sabit), genişlik 66.0–66.7 (60·s = 65.9); yükseklik 69.7 → 75.0 → 80.7 → 85.3 → 85.3 (yalnız aşağı). Yarıçap fit 24.4–24.6 (22·s = 24.15). `HEDEF DÖNGÜ`'ye boşluk ≥ **40.3 pt** | `QA-16-L26-*.png`, `crops/hamle-16-ax5.png` | — |
| R07 | Aynı, 16e | runtime + ölçüm | aynı | 16e | dışarıda 0 piksel; etiket inset ≥ **3.07 pt**; üst 81.3 sabit, genişlik 65.3–65.7; yükseklik 69.0 → 85.3; boşluk ≥ 39.3 pt | `QA-16e-L26-*.png` | — |
| R08 | Aynı, Pro Max | runtime + ölçüm | aynı | Pro Max | dışarıda 0 piksel; etiket inset ≥ **3.62 pt**; üst 92.0 sabit, genişlik 74.0; yükseklik 77.7 → 94.7; boşluk ≥ 46.7 pt | `QA-pm-L26-*.png` | — |
| R09 | AX5'te soğuk açılış + resume + iki haneli rakam | runtime + sqlite | content size AX5 → seed L5 (12 hamle, undo 2) → launch → DEVAM | iPhone 16 | birebir resume: `HAMLE 12`, iki lime nokta + bir sönük. "12" inset **11.45 pt**, etiket 3.41 pt, dışarıda 0 | `QA-16-L5-resume12-ax5-coldlaunch.png` | seed = gerçek F08 snapshot şekli |
| R10 | Kritik omurga AX5'te (AC2/3/5/6/7): satır, sütun, undo, restart | runtime-video + sqlite | satır 2 sağ; kilit sırasında gönderilen sütun; sütun 3 aşağı; undo; restart | iPhone 16 | R2 → 13; kilit sırasında gelen sütun **düşürüldü, kuyruğa alınmadı** (snapshot +0); D3 → 14; undo → 13, kota 1; restart → `[]`, 0 hamle, kota 3, restartCount 1, diyalog yok. Kart her adımda aynı (dışarıda 0) | `QV-16-ax5-spine-move-undo-restart.mp4`, `QA-16-L5-ax5-after-{R2-D3,undo}.jpg`, `QA-16-L5-ax5-after-restart.png` | — |
| R11 | Metin boyutu arka plandayken değişti + kill/relaunch | runtime + sqlite | L0; HOME; AX5 → xL; öne getir; terminate + launch → DEVAM | iPhone 16 | öne gelince kart xL yüksekliğine döndü (85.3 → 75.0 pt, inset 3.69). Kill sonrası birebir resume: `["L0"]`, 1 hamle, kota 3, restartCount 1, elapsed 270162 ms | `QA-16-L5-xl-after-bg-change.png`, `QA-16-L5-resume-after-kill.jpg` | — |
| R12 | Tutorial (F05) büyütülmüş kartla, xxL → AX5 | runtime + ölçüm | L4 ack yok; canlı tarama; 16e / Pro Max AX5'te | 3 sim | pill boşluğu (board / undo): 16 xxL **8.0 / 8.0**, AX5 **7.0 / 7.0**; 16e AX5 **6.3 / 6.3**; Pro Max AX5 **8.7 / 8.3** pt (≥ 4). Kart ile pill ayrı bölgelerde, çarpışma yok | `QA-*-L4-tutorial-*.png` | — |
| R13 | AX5'te lift, rail'ler ve thaw | runtime-video | L23 `["R1","D3","U4"]`; sütun 4 yukarı; satır / sütun basılı tut ve geri götür | iPhone 16 | thaw `["2,1"]`, buz → krem **cross-fade**, kar tanesi solarak küçülüyor. Satır lift: rim + yan ray'ler + %42 geri kalan + wrap ghost. Sütun: üst / alt ray'ler. Header değişmedi. Geri götürülen iki sürükleme **hamle üretmedi** (net eşik altı) | `QV-16-ax5-thaw-row-column-lift.mp4`, `QA-16-L23-ax5-*.jpg`, `crops/thaw-16-ax5-mid.png`, `crops/*-lift-16-ax5.png` | — |
| R14 | Reduce Motion açık + AX5 | runtime-video + kare ölçümü | `ReduceMotionEnabled 1`, relaunch; L23 thaw | iPhone 16 | tile (2,1) ortalama luma: 188 → **tek karede** 91 (anında lift) → settle karesinde 204 (**anında thaw**, ara kare yok) | `QV-16-ax5-reduced-motion-thaw.mp4`, QM | sonra 0'a geri alındı |
| R15 | F03-QA-D1-02 re-test — load-error başlığı, large → AX5, 3 cihaz | runtime + ölçüm | kurulu bundle'da `journey-tr-07.json` bozuldu (`qa-asset.sh`); L7 DEVAM; tarama; `qa-d1r headline` | 3 sim | **15 / 15** yakalamada 2 satır "Bu bulmaca" / "yüklenemedi.", 3 kelime; noktalama-only satır yok; kelime içi kırılma yok. Sağ kenar payı ≥ **55.7 pt** (16e AX5), sol ≈ 30–35 pt. Varsayılan boyut: D1-07 render'ı ve D1 runtime RT-16-07 ile satır kutuları ≤ 1 pt | `QA-{16,16e,pm}-L07-error-*.png` | bozulma yalnız simülatör bundle'ında; üçü geri yüklendi, SHA-1 `2fef993c…` = repo |
| R16 | Load error AX5 → pill → Home | runtime | pill'e dokunuş | iPhone 16 | pill iki satıra akıyor ve Home'a (`/`) dönüyor; crash yok | `QA-16-L07-error-ax5-pill-home.jpg` | — |
| R17 | Varsayılan boyut paritesi | runtime + ölçüm | `design/src/measure-d1.swift` D1-05 render ↔ `QA-16-L26-large.png` | iPhone 16 | 16 özellik **max 0.67 pt**. `HAMLE` kartı üst / sol +0.33; token ΔE ≤ 1.48; tek sapma bilinen zemin ışığı ΔE 3.35 → D1 ile aynı | QM | — |
| R18 | Won, AX5'te (gözlem) | runtime-screenshot | debug L01, R0 | iPhone 16 | chevron gizli. `HAMLE` kartı scrim altında (authority'de yalnız geri butonu `won`'da gizleniyor; D1 E23 ile aynı davranış). Legacy panel AX5'te taşıyor ve satırı örtüyor → NTLC-6, D2 kapsamı; won kodu diff'te yok | `QA-16-L01-won-ax5-rest.jpg`, `QV-16-ax5-won-L01.mp4` | yalnız destekleyici; won zamanlaması E23'ten REUSED |
| D1-E05…E14, E16–E19, E22–E24, E27–E30 | Varsayılan boyutta Play state'leri, AC1–AC11, F05 AC4 / AC11, bounce, loading, won §16, RM, multi-touch, kontrast, legacy yok | runtime | — | 3 sim | PASS (D1'de) | **REUSED — fingerprint valid**: 5798c70 build; bu yüzeylerin kodu diff dışında; `MovesCard` `large`'da birebir (R17) | qa/d1 |
| D1-E31 / E32 | VoiceOver semantiği / odak halkası | automated | R01 içinde yeniden çalıştı | widget | geçti | REUSED sınıf: automated (host sınırı, §19.9 (4)) | test harness |

## 2. Acceptance & Critical Journey Coverage

| AC / Journey | Expected | Evidence IDs | Result |
| --- | --- | --- | --- |
| F03-QA-D1-01 re-test (§19.10 (1) kuralı) | her boyutta (default → AX5), 390 / 393 / 440'ta rakam ve etiket mürekkebi yuvarlak dikdörtgenin içinde, yaylar dahil, inset ≥ 2 pt; genişlik ve sol-üst sabit; yalnız aşağı büyüme; `HEDEF DÖNGÜ`'ye ≥ 8 pt; default'ta 60 × 63·s | R06, R07, R08, R09, R17, R05 | **PASS** — min inset 3.00 pt; boşluk ≥ 39.3 pt |
| F03-QA-D1-02 re-test (§19.10 (2) kuralı) | her boyutta yalnız kelime sınırında kırılma, noktalama-only satır yok, kırpma yok; pill akıyor ve `/`'e gidiyor; default D1-07 görünümü | R15, R16, R05 | **PASS** |
| Diğer Play state'lerinde header, xxL → AX5 | tutorial pill ≥ 4 pt; lift / thaw / kilitli / donmuş / HUD'da yeni çakışma yok; won §16 (+ §19.9 (1)) | R06, R12, R13, R14, R18 | PASS |
| AC1–AC11 omurgası (bağımsız, bu tur) | hamle, kilit sırasında girdi düşer, undo, restart, kill arası resume | R10, R11, R02 | PASS |
| AC1–AC11 tam matris, F05 AC4 / AC11 | D1'deki gibi | D1 E05–E24 (REUSED), R02 | PASS |
| Misuse: metin boyutu Play açıkken canlı değişti | yeniden yerleşim, çakışma yok | R06, R07, R08, R12 | PASS |
| Misuse: metin boyutu arka plandayken değişti | öne gelince doğru yerleşim | R11 | PASS |
| Misuse: AX5'te resume edilmiş oturum | birebir durum, kart doğru | R09 | PASS |
| Misuse: AX5'te load error → Home | tek çıkış, crash yok | R16 | PASS |
| Misuse: AX5'te Reduce Motion | anında lift / thaw | R14 | PASS |
| Misuse: kilit sırasında ikinci swipe | düşer, kuyruk yok | R10 | PASS |
| Misuse: basılı tut + başlangıca geri getir | hamle yok | R13 | PASS |
| Misuse: multi-touch | yalnız ilk parmak | D1 E27 | Bilinen sapma F03-MULTITOUCH-FIRST-POINTER (D1 dışı, §19.10 (3)) |

## Client & UI Compliance

| Kontrol | Evidence | Sonuç |
| --- | --- | --- |
| Header: chevron + `SEVİYE NN`; `HAMLE` kartı AX5'e kadar kabında, rakam 1–2 hane | R06–R09 | PASS |
| Load error: kart + `loopBreak` + başlık + `Ana ekrana dön` (tek aksiyon, `/`), her boyutta | R15, R16 | PASS |
| Controller → görünür UI: `HAMLE` settle'da (12 → 13 → 14 → 13 → 0), kota noktaları | R09, R10 | PASS |
| F05 overlay: pill HUD üstünde, kontroller açık, büyütülmüş kartla etkileşim yok | R12 | PASS |
| Metin ölçeği davranışı (§19.3 (1), §19.9 (3), §19.10) | R06–R08, R15 | PASS |
| `MovesCard` ikinci tüketicisi (debug galerisi) | R01 (`components_test`, `moves_card_ink_test`) | PASS — automated; oyuncu yüzeyi değil |

## Stateful Flow & Integration

| Boundary / Transition | Actor / Start State | Expected | Evidence IDs | Result |
| --- | --- | --- | --- | --- |
| OS metin boyutu değişimi (Play önde) | OS / idle | anında yeniden yerleşim, snapshot'a dokunmaz | R06, R12 | PASS |
| OS metin boyutu değişimi (arka planda) → foreground | OS / inProgress | doğru boyutta yerleşim, durum korunur | R11 | PASS |
| AX5'te soğuk açılış → CONTINUE | oyuncu / inProgress (12 hamle, kota 2) | birebir resume | R09 | PASS |
| settle / undo / restart → snapshot | oyuncu / idle | write-through | R10 | PASS |
| OS kill → relaunch → CONTINUE | OS / inProgress | birebir (restartCount, elapsed dahil) | R11, R02 | PASS |
| settle sırasında gelen girdi | oyuncu / animating | düşer | R10, R02 | PASS |
| bozuk asset → error → Home (AX5) | içerik / L7 | tek çıkış | R16 | PASS |
| paused mid-drag / mid-animation, tampered cache | OS / tracking, animating | yırtık hamle yok / yeniden türetilir | R02 | PASS |

## Visual Quality Verdict

Bağımsız runtime skoru; Frontend self-score'u kullanılmadı. Kapsam: `won` dışındaki Play state'leri, load error ve F05 overlay, üç cihazda large → AX5. Won moment yalnız §16 (+ §19.9 (1)) kurallarıyla değerlendirildi (E23 REUSED, R18) ve puana katılmadı.

| Rubric Dimension | Score / 10 | Runtime Evidence | Notes |
| --- | --- | --- | --- |
| Experience Fit | 9 | R06, R13, D1-E05 | Loop Glass dili çekirdek döngüde sakin ve bilinçli; hybrid dönem (legacy Home / won) kabul edilmiş |
| Visual Hierarchy | 10 | R06, R13, R12 | her state'te tek odak (board, kaldırılan hat, eriyen taş, ipucu). AX5'te uzayan kart üçüncül kalıyor, hedefle yarışmıyor |
| Layout, Rhythm and Responsiveness | 9 | R06–R08, R12, R17 | geometri her boyutta sabit; kart yalnız aşağı büyüyor, `HEDEF DÖNGÜ`'ye ≥ 39 pt; tutorial ≥ 6.3 pt; default ≤ 0.67 pt. Eksi: cap'te kartın iç ritmi hafif alt ağırlıklı (rakam üstü ≈ 12 pt, etiket altı ≈ 17 pt) ve kart uzun bir hap formuna dönüşüyor |
| Typography and Content Craft | 9 | R06, R15, R17 | etiket ≥ 3 pt içeride; başlık her boyutta kelime sınırında; `tnum` iki hanede temiz. Eksi: AX5'te error ekranında pill etiketi (serbest metin) 1.3× cap'li başlıktan büyük — §19.9 (3) ile kabul edilmiş hiyerarşi tersine dönmesi; sayaç satır yüksekliği (MOVESCARD-COUNTER-LINE-HEIGHT, loglu) |
| Color, Surface and Asset System | 10 | R17, D1-E14, D1-E29 | token ΔE ≤ 1.48, anlam başına tek vurgu, çizilmiş ikonlar; zemin ışığı ΔE 3.35 kabul edilmiş gradient yaklaşımı |
| Interaction, State and Feedback | 9 | R10, R13, R15, R16, D1-E09/E10/E13 | her state ayırt edilebilir; kilitte girdi düşüyor. Eksi: multi-touch sapması (D1 öncesi, loglu) |
| Motion and Sensory Quality | 9 | R13, R14, D1-E06/E13/E16/E17 | thaw cross-fade AX5'te de aynı; RM yolları AX5'te anında. Audio / haptic yalnız niyet (F11 planlı değil) |
| Originality and Product Identity | 9 | R13, R15 | wrap ghost + kenar ray'leri, `loopBreak` glifi; navy-glass tarifi kategoride yaygın |
| Accessibility and Inclusive Quality | 9 | R06–R09, R12, R14, R15, D1-E29, E31, E32 | Play ve error'da AX5'e kadar kırpma / örtüşme / kelime içi kırılma yok (3 cihaz); RM + AX5 temiz; kontrast 5.1 : 1; 44 pt. Eksi: VoiceOver ve odak halkası yalnız automated (host sınırı) |
| Implementation Fidelity and Polish | 10 | R17, R06–R08, R15 | default'ta render'lara ≤ 0.67 pt, yarıçap 24.5 ↔ 24.15, satır kırılımları D1-07 ile ≤ 1 pt. Cap'teki kart yüksekliği D1-10'dan farklı, ama bu §19.10 (1) ile yetkili ve açıklanmış bir sapma: D1-10 render'ında etiket yayların üstüne biniyordu, runtime bunu düzeltiyor. frontend.md düzeltme notları runtime ile uyuşuyor |

Final Score: 93 / 100

Lowest Dimension: Experience Fit — 9 / 10 (sekiz boyut 9, iki boyut 10)

Fail Conditions: None

Runtime Evidence Complete: Yes (VoiceOver ve odak halkası belirtilen automated sınıfta; Android kapsam dışı sınır)

Result: PASS

Skor notu: 93 geçiş bandının alt sınırı. D1'in 87'sinden farkın tamamı, iki bulgunun düşürdüğü dört boyuttan geliyor (Layout 8 → 9, Typography 8 → 9, Accessibility 7 → 9, Fidelity 8 → 10). Diğer altı boyut D1 kalibrasyonuyla aynı tutuldu.

## 3. Findings

Yeni bulgu yok.

* F03-QA-D1-01 ve F03-QA-D1-02 **kapandı** (R06–R09, R15, R16).
* F03-QA-D1-03 D1 dışında follow-up olarak duruyor: F03-MULTITOUCH-FIRST-POINTER.

## 4. Pending Evidence

* Scenario: Android görünümü ve `disableAnimations` runtime davranışı.
  * Required class: runtime; target: Android emülatör / cihaz; owner: DevOps/Release Engineer (ANDROID-CI-EVIDENCE).
  * Re-evaluation trigger: Android CI / emülatör hazır olduğunda.
  * Bu gate'i durdurmaz (brief'te belirtilmiş sınır).

## 5. Regression & Evidence Reuse

* **Etkilenen yüzey / derinlik: full.**
  * Diff: `MovesCard` (Play header'ı her state'te + debug galerisi) ve `_LoadErrorView`.
  * Runtime'da yeniden çalıştırılanlar: her Play header state'i large → AX5 (idle, tutorial, lift, thaw, won gözlemi), üç cihaz; load error üç cihazda beş boyut.
  * AC omurgası AX5'te bağımsız çalıştırıldı; suite'ler ve integration yeniden çalıştı.
* **REUSED — fingerprint valid:** D1 E05–E14, E16–E19, E22–E24, E27–E30 (default boyutta Play, AC matrisi, F05, bounce, loading, won, RM, kontrast).
  * Gerekçe 1: bu yüzeylerin kodu diff dışında.
  * Gerekçe 2: `MovesCard` `large`'da `grow = 0` ile birebir 60 × 63·s. Kaynakta doğrulandı; runtime'da R17 (kart üst / sol +0.33 pt) ve R06 (yükseklik 69.7 ≈ 63·s + AA).
  * Ek: E31 / E32 automated sınıfı R01'de yeniden çalıştı.
* **INVALIDATED — rerun required (yapıldı):** D1 E15, E20, E21, E25 / E26'nın AX5 kısımları ve rubric. Yerlerine R06–R08, R12, R15 ve yeni skor geçti.
* **Bağımsız QA probe'ları:**
  * QA aracı `qa-d1r` negatif kontrolle doğrulandı (R05). Frontend'in PlayLayout tabanlı aracından farklı olarak dış hattı ölçüyor.
  * AX5'te omurga, canlı / arka plan boyut değişimi, soğuk açılış resume'u (R09–R11), RM + AX5 (R14).
* **Regression risk:** header'daki büyüme board, rail ve HUD geometrisini etkilemiyor (üst sabit, board ve tutorial bantları değişmedi). Won katmanında kart scrim altında kalıyor (R18). Yeni regresyon gözlenmedi.

## 6. Final Verdict

* `QA Result: Approved with Notes`
* Blocking Issues: None
* Required Fixes: None
* Non-blocking Notes:
  * Rubric 93 / 100, geçiş bandının alt sınırında; en düşük boyutlar 9.
  * F03-MULTITOUCH-FIRST-POINTER ve MOVESCARD-COUNTER-LINE-HEIGHT loglu, D1 dışında.
  * AX5'te error ekranında pill etiketi başlıktan büyük görünüyor (§19.9 (3) kabulü). Karar D3 / F10 tipografi turuna bırakılabilir.
  * Legacy Home (AUD-A11Y-04 → D3) ve won paneli (NTLC-6 → D2) AX5'te taşıyor; D1 dışında, bu turda değişmedi.
  * Android, VoiceOver runtime ve donanım odak halkası belirtilen sınırlar.

## 7. Tech Lead Note

* **Kök neden alanı / rol:** yok; iki D1 bulgusu Frontend rework'ü ile kapandı.
* **Routing / depth:** değişiklik yok. Gate'in Passed'e geçişi ve F03 Done / D2 aktivasyonu Tech Lead kararı.
* **Workflow notları:**
  * **Brief ifadesi:** Current Brief (3) "the card hides in `won`" diyor. Authority'de (ui-design §6 / §7, architecture §19.4) yalnız geri butonu `won`'da gizleniyor. Runtime authority ile ve D1 E23 ile uyumlu: kart scrim altında kalıyor. Bulgu açılmadı; brief ifadesinin düzeltilmesi önerilir.
  * **qa.md yapısı:** brief D1R'nin eklenmesini istiyordu. `workflow-flow-audit.mjs` ise `qa.md` içindeki **ilk** `Final Score` / `Lowest Dimension` eşleşmesini okuyor. D1 raporu (87, en düşük 7) önde kalsaydı gate Passed'e geçerken denetim hata verirdi. Bu yüzden D1 raporu, D1'deki QA emsaliyle byte-for-byte `history/f03-puzzle-play-session-2026-09-27/qa-at-d1-verdict.md`'ye taşındı (SHA-1 `276ec217…`, `cmp` birebir) ve buradan link verildi.
  * **Rework commit edilmemiş:** rework hâlâ çalışma ağacında. Commit sonrası fingerprint için `git diff 5798c70 -- app` SHA-1 `88f1dca3…` karşılaştırılabilir.
* **Simülatör durumu geri yüklendi:** üç cihazda content size `large`, Reduce Motion 0, `journey-tr-07.json` repo hash'inde (`2fef993c…`).
  * iPhone 16'da son kurulu build, integration koşusunun build'i.
  * Seed'ler simülatör DB'lerinde kaldı (yalnız test verisi).

## Sonraki Komut

```text
Run Tech Lead
```
