# F05 — journey-progression: QA Raporu — F05-QA-D3 (Design Adoption Phase D3 — Home + app shell)

> **Görev:** F05-QA-D3 (QA, 2026-09-29). **Stage:** final. **Contract:** `architecture.md` §18.3, §18.6; kararlar §18.7 ve §18.8. **Handoff:** `ui-design.md` (D3) §4–§12, kabul listesi §11.1.
>
> Önceki dosya (F05-QA … F05-QA-STRICT2 raporları, 2026-09-08 … 2026-09-27) byte byte arşivlendi: `history/f05-journey-progression-2026-09-29/qa-before-phase-d3.md` (SHA-1 `fe23f30a…`).
>
> **Test edilen build:** HEAD `078c926` (temiz ağaç), `app/` fingerprint `b4ad263e…` (frontend.md komutuyla yeniden hesaplandı — teslimle aynı). Debug build (`flutter build ios --simulator --debug`), `xcrun simctl install`. Kanıt klasörü: `qa/d3/` (bu turun kendi araçları: `qa/d3/qa-d3.sh`; ölçüm: F03 `parity-d2.swift`, `video-d2.swift`; kontrast: `qa/d3` içindeki px örneklemesi, aşağıda).

---

## 0. QA Execution Plan

* **Stage / Scope:** final / client-only. Release Scope `none`.
* **Modüller + tetikleyici:** `core` (her tur); `client-ui` (Home, splash, store error, `/` ⇄ `/play` gezinme, CTA hedefleri, back yolları); `visual-quality` (Visual Scope `new-surface`); `stateful-flow` (canlı read-model warm/cold, relaunch/persistence, bootstrap Retry). `node ai-system/tools/qa-preflight.mjs ai-system` → **PASS** (declared = suggested).
* **Regression Depth:** `full` — startup, routing shell ve uygulama teması değişti.
* **Evidence Reuse:** `allowed`, §18.8 sınırlarıyla (bkz. §5). Frontend yakalamaları ve self-check yalnız girdi; QA kanıtı değil.
* **Canonical target / required runtime class:** iOS Simulator 18.6 — iPhone 16 `D0011CE7…` (birincil, 393 × 852), iPhone 16e `6DBDFD97…` (390 × 844), iPhone 16 Pro Max `02FDE776…` (440 × 956); `runtime` (screenshot + video) + `automated functional`. Android: belirtilmiş limit (ANDROID-CI-EVIDENCE).
* **Fail-fast checkpoint:** (1) aktif QA gate + plan → PASS; (2) fingerprint → eşleşti; (3) analyze/test → yeşil; (4) en küçük kritik probe: boş store'dan cold start (beyaz kare yok) → PASS; ardından planlanan full doğrulama.
* **Isolation / override (açık):** Home state'lerine ulaşmak için store, teslimin `design/src/seed-d3.sh` betiğiyle doğrudan SQLite'a yazıldı (journey_progress + active_session). Bu bir **test override**'ıdır. Buna karşın AC7/N1, AC8, AC12, AC1 ve warm/cold eşitliği **ayrıca override'sız** gerçek dokunma/oyun ile kanıtlandı (uygulamanın kendi yazdığı snapshot: J3, J5, J6). Store hatası, store dosyasının veritabanı olmayan baytlarla değiştirilmesiyle zorlandı (`seed-d3.sh corrupt`).

## 1. Evidence Ledger

| Evidence ID | Claim / Scenario | Class | Command / Action | Target | Result / Counts | Provenance / Fingerprint | Isolation |
| --- | --- | --- | --- | --- | --- | --- | --- |
| QA-D3-E01 | Statik analiz | build | `melos run analyze` | host | exit 0, no issues | 078c926 / `b4ad263e…`, 2026-09-29 09:47, `qa/d3/raw/analyze.log` | — |
| QA-D3-E02 | Bütün birim/widget testleri | automated functional | `melos run test` | host (Flutter 3.32.8) | exit 0 — app **565** passed, core 22, content 17, dictionary 32, solver 23, authoring 25, engine 83; **0 skip** | aynı, `qa/d3/raw/test.log` | test fakes (bkz. frontend.md §17) |
| QA-D3-E03 | Cihaz entegrasyon suite'i | repeatable integration | `flutter test integration_test -d D0011CE7…` | iPhone 16, iOS 18.6 | exit 0 — **13 / 13** | aynı, `qa/d3/raw/integration.log` | uygulamayı sonunda kaldırır; sonra yeniden kuruldu |
| QA-D3-E04 | Negatif koşular — kuralı bozan değişiklik test tarafından yakalanıyor mu | automated functional | `design/src/neg-d3.py` (her biri bir kural bozar, testler koşar, dosya byte kopyadan geri yüklenir; sonunda `git status` temiz) | host | **NB-QA** (window replay offset kaldırıldı) → 7 fail; **ND-QA** (`NormalTheme` → `?android:colorBackground`) → 2 fail; **NI-QA** (yeni, QA'nın kendi vakası: 30/30 başlığı yalnız oturum yokken — N1 başlığı "Yarım kalan…"e kayar) → 3 fail | aynı | kaynak geçici olarak değiştirildi, geri yüklendi |
| QA-D3-E05 | Boş store'dan cold start: native launch → splash → Home; beyaz/açık kare yok; hand-off görünmez | runtime-video | store silindi; `qa-d3.sh coldrec` (terminate → recordVideo → launch); kare-kare `video-d2 trace` | iPhone 16 | iOS açılış zoom'u 1.90–2.22 s; **2.22 s'den Home'a kadar tam kare ortalama luma ≤ 18.0** (açık kare yok); 2.22–3.55 s kart/CTA/alt bölge ±0.3 sabit → native → Flutter hand-off **görünmez**; wordmark 3.55–3.78 s belirir; içerik 4.07 s, CTA dinlenmede 4.24 s | `qa/d3/raw/QA-16-J1-cold-empty.mov`, `…-trace.csv`, `QA-16-J1-sequence.jpg` | debug build |
| QA-D3-E06 | Mevcut store'dan (N1) cold start; Reduce Motion ile cold start | runtime-video | `coldrec` ×2 (ikincisi `ReduceMotionEnabled=1`) | iPhone 16 | mevcut store: açık kare yok (maks 48.8 = Home dinlenmede), hand-off 2.49–2.99 s görünmez, wordmark 2.99–3.13 s, içerik 3.26–3.41 s. **Reduce Motion:** kart+CTA **tek karede** (3.283 → 3.345 s: kart 17.2 → 64.2, CTA 16.4 → 193.3); wordmark ~0.16 s cross-fade (iOS embedder'ın sabit 0.2 s launch fade'i — §18.8 kararı 2) | `raw/QA-16-J9-cold-existing-n1.mov`, `raw/QA-16-J9-cold-reduce-motion.mov`, `.csv` | debug build |
| QA-D3-E07 | Her Home state'i render'la aynı (kopya, pencere, düğüm durumları, tek CTA); §6 çapaları | runtime-screenshot + parity-comparison | her state için seed → cold launch → `simctl io screenshot`; `parity-d2 bands` + `compose` | iPhone 16 (@3x) vs `D3-*` (@2x) | 9 state'in hepsi `window-d3.txt` ve C1 kuralıyla birebir. Yatay Δ **≤ 0.2 pt** (her band). Dikey: wordmark +0.7, etiket/başlık −4.5…−5.0, track −4.0…−4.2, CTA −5.5 pt — render'ın kendi §6 kayması (§18.8 kararı 1). **Runtime CTA lime band üstü 487.0 pt → pill üstü ≈ 486.3 pt = §6 çapası (±2)** | `qa/d3/QA-16-J2-D3-*.png`, `PC-QA-D3-*.jpg`, `QA-16-J2-sheet-a/b.jpg`, `parity-qa.txt` | seed override |
| QA-D3-E08 | AC7 / N1 — cold: 30/30 + replay 12 → "Devam et" → seviye 12 kayıtlı durumunda | runtime-screenshot | N1 seed → dokun | iPhone 16 | `SEVİYE 12`, HAMLE 1 (seed'lenen hamle), undo açık | `QA-16-J3-n1-cold-tap-play.jpg` | seed override |
| QA-D3-E09 | AC7 / N1 — **override'sız** warm + cold: gerçek hamle → back → Home; kill → relaunch → CONTINUE → aynı durum; undo geçmişi korunmuş | runtime-screenshot + store read | gerçek swipe (satır 1 sağa) → HAMLE 2; Play chevron → Home; `sqlite3` snapshot okundu; `qa-d3.sh launch` (terminate+launch); CONTINUE; undo | iPhone 16 | warm Home = cold Home (30/30, "Tüm döngüler tamam.", pencere 10–14, 12 geçerli, "Devam et", "Seviye 12 · sürüyor"); uygulamanın yazdığı snapshot `appliedMoves ["R1","R0"], moveCount 2`; relaunch sonrası CONTINUE → HAMLE 2, ızgara birebir; undo → HAMLE 1, önceki ızgara, kota 2/3 | `QA-16-J3-warm-vs-cold.jpg`, `…-cold-resume-L12-hamle2.jpg`, `…-undo-check.jpg` | yok (uygulama yolu) |
| QA-D3-E10 | AC8 + warm frontier + çift dokunma | runtime-screenshot | seed 29 done, oturum yok → Home; CTA'ya hızlı çift dokunma; gerçek hamle `R4`; tek back | iPhone 16 | Home `29 / 30`, pencere 26–30, "Seviye 30"; çift dokunma → `SEVİYE 30` HAMLE 0; **tek back Home'a döndü** (yığın bir kez itildi); warm Home yerinde güncellendi: "Seviye 30 · sürüyor" | `QA-16-J5-*.jpg` | seed override (başlangıç durumu) |
| QA-D3-E11 | AC12 (N = 30) + C3 + D2 regresyonu: seviye 30 çöz → sonuç → "Yolculuğu tamamla" → Home terminal, giriş animasyonu tekrar oynamaz | runtime-video + screenshot + store read | CLI çözümü `R4 U1 U2 U2 D3` dokunmayla uygulandı; recordVideo; sonuç; Next | iPhone 16 | sonuç: 5 hamle = optimal, 3★, EN İYİ 5; Next → Home **"Tüm döngüler tamam." / "Tekrar oyna" / "Seviye 1"**, 30 finish düğümü; video: Cupertino pop, Home kaydırma sırasında **zaten dinlenmede** (CTA tam lime, caption var) → **entrance tekrar oynamadı**; store: 1–30 tamam, active_session yok, personal_best L30 = 5 / 3★ | `QA-16-J6-L30-result.jpg`, `…-home-terminal-after-next30.jpg`, `QA-16-J6-return-sequence.jpg`, `raw/QA-16-J6-win30-next-home.mov` | seed override (29 tamam) |
| QA-D3-E12 | AC9: terminal → "Tekrar oyna" → seviye 1 | runtime-screenshot | E11 sonrası CTA | iPhone 16 | `SEVİYE 01`, HAMLE 0 | `QA-16-J4-terminal-replay-L1.jpg` | yok |
| QA-D3-E13 | AC12 (N < 30) + sistem geri (edge swipe) + pushReplacement | runtime-screenshot | L1 çöz (`L0 L0`) → "Sonraki bölüm" → `SEVİYE 02`; sol kenardan swipe | iPhone 16 | tek edge-back → doğrudan Home (yığın büyümedi); Home N1 durumu: replay 2, pencere 1–5 (replay offset, "replay at 2" vakası), "Seviye 2 · sürüyor" | `QA-16-J6-next-L2-then-back.jpg` | yok |
| QA-D3-E14 | AC1 + sonuç ekranı back butonu → Home (warm) | runtime-screenshot + store read | boş Journey seed → CTA → L1 çöz → sonuç `‹` | iPhone 16 | Home `1 / 30`, "Sıradaki döngüyü çöz.", pencere 1–5 (1 done, 2 current, 3–5 locked), "Seviye 2"; store `2|1`, active_session yok | `QA-16-J6-result-back.jpg` | seed override (boş) |
| QA-D3-E15 | Store hatası: Türkçe, ham istisna oyuncu metninde yok, log, Retry | runtime-screenshot + video + log | `seed-d3.sh corrupt` → launch; `log show`; recordVideo; Retry | iPhone 16 | `KAYITLI VERİLER`, `loopBreak`, "Kayıtlı verilerin açılamadı." / "İlerlemen güvende; hiçbir şey silinmedi.", tek "Tekrar dene"; istisna yalnız ayrı DEBUG kutusunda (debug build); log `flutter: store: bootstrap_failed — SqliteException(26)…` 09:59:50.486; Retry → **tek splash karesi** (1.940 s, ~17 ms) → hata ekranı tekrar; ikinci log satırı 10:00:13.467 | `QA-16-J7-store-error.png`, `raw/QA-16-J7-log-1.txt`, `…-log-2.txt`, `raw/QA-16-J7-retry.mov` | store bozuldu (override) |
| QA-D3-E16 | Metin ölçeği — Home (N1) canlı değişim large → 1.3× → AX5 → large; store error AX5 üst/son | accessibility | `simctl ui content_size` Home açıkken; swipe ile kaydırma | iPhone 16 | 1.3×: kaydırma yok, container metin kapaklı; **AX5: klip yok, kaydırma yok, CTA tek satır, caption yalnız "·" öncesi kırılıyor, debug satırı gizli (C2)**; large'a dönüşte debug satırı geri. 1.3× bandları runtime = AX5 bandları (container kapaklı); CTA AX5 76.7 pt. Store error AX5: sütun kayıyor, `ScrollBand` metni status bar altına sokmuyor, kelime bölünmesi yok, pill iki satıra büyüyor | `QA-16-J8-home-n1-*.png`, `…-sweep.jpg`, `QA-16-J8-store-error-ax5.jpg` | debug build |
| QA-D3-E17 | Cihaz varyantları: boş, in progress 4/30, N1, N1 1.3×, N1 AX5, store error | runtime-screenshot + accessibility | her cihaz: wipe → cold; seed; canlı ölçek; corrupt | 16e, Pro Max | iki cihazda da state/pencere/kopya doğru; AX5'te klip ve kaydırma yok; store error kartı + tek pill | `QA-16e-sheet.jpg`, `QA-promax-sheet.jpg` (+ tekil jpg) | seed override |
| QA-D3-E18 | Pressed CTA (0.98) | runtime-screenshot | `touch_path` 2.6 s basılı tut; 1.2 s'de arka plan screenshot | iPhone 16 | basılı pill genişliği 332.0 pt vs dinlenmede 339.0 pt → **0.979** ölçek; bırakınca `/play` | `QA-16-J9-cta-pressed.png`, `QA-16-J8-home-n1-large.png` | — |
| QA-D3-E19 | Arka plan → ön plan: entrance tekrar yok, bayat durum yok | runtime-video | Home'da HOME tuşu → recordVideo → `simctl launch` (foreground) | iPhone 16 | OS açılış zoom'u içinde Home içeriği baştan dinlenmede; state aynı | `QA-16-J9-foreground-sequence.jpg`, `raw/QA-16-J9-foreground.mov` | — |
| QA-D3-E21 | Track düğümleri gezinme üretmez (AC2 yapısal, §18.7 kararı 2) | runtime-screenshot + store read | `1 / 30` Home'da ölçülen merkezlere dokunma: kilitli 5 (321, 324), geçerli 2 (141, 377), tamamlanmış 1 (71, 391) | iPhone 16 | Home'da kalındı, `/play` açılmadı; `active_session` = 0 | `QA-16-J2-node-taps-no-nav.jpg` | seed override (E14 sonrası durum) |
| QA-D3-E20 | Kontrast (runtime pikselleri, WCAG) | static inspection of runtime capture | kutuda en parlak piksel (mürekkep) vs medyan piksel (zemin); `QA-16-J2-D3-01.png`, `QA-16-J7-store-error.png` | iPhone 16 @3x | başlık 13.21 : 1; caption 7.55; etiket 6.68; kilitli düğüm rakamı 7.14; store error gövdesi 7.51. Kesikli/açık çerçeveler (≥ 3 : 1) UI tablosundan (3.41 / 3.52) + gri tonlamada ayırt edilebilirlik gözle doğrulandı | bu rapor | örnekleme yaklaşık (antialias) |

## 2. Acceptance & Critical Journey Coverage

| AC / Journey | Expected | Evidence IDs | Result |
| --- | --- | --- | --- |
| J1 — boş store'dan cold start | beyaz/açık kare yok, hand-off görünmez, Home "new" | E05 | PASS |
| J2 — her Home state'i (cold, mevcut store) | `window-d3.txt`, C1 kopya kuralı, render'la eşleşme | E06, E07, E17 | PASS |
| AC7 / N1 (J3) — 30/30 + replay → CONTINUE kayıtlı durumu sürdürür, warm ve cold | seviye 12 kayıtlı ızgara/hamle/undo | E08, E09 | PASS |
| AC9 (J4) — 30/30, oturum yok → "Tekrar oyna" → seviye 1, çökme yok | terminal state + finish düğümü | E07 (D3-06), E11, E12 | PASS |
| AC8 / AC10 (J5) — oturum yok → en düşük açık tamamlanmamış seviye; ilerleme göstergesi doğru | `29 / 30` → Seviye 30; etiket + pencere doğru | E07, E10, E14 | PASS |
| AC12 + round trip (J6) — Next N<30 → N+1 (pushReplacement); N=30 → Home terminal; sonuç back, sistem back, Play chevron → Home; warm = cold | yerinde güncelleme, entrance tekrar yok (C3) | E09, E11, E13, E14 | PASS |
| AC1 — herhangi bir yıldızla tamamlama N+1'i açar (back ile kapanış) | `2|1`, Home "Seviye 2" | E14 | PASS |
| J7 — store hatası + Retry (§18.3 (7), F08 AC9) | Türkçe, istisna yok (oyuncu metni), log, Retry → splash → hata | E15 | PASS (Retry'deki splash tek kare — Not N2) |
| J8 — metin ölçeği (C-9) | klip/kırık kelime yok, Home AX5'te kaymıyor, error kayıyor + band | E16, E17 | PASS |
| J9 — hareket: entrance bir kez, Reduce Motion, idle motion yok | E05/E06 kayıtları; E11/E19'da tekrar yok | E05, E06, E11, E19 | PASS (debug build'de entrance ilk karesi geç gelir — Not N1) |
| Misuse — hızlı çift CTA dokunması | `/play` bir kez itilir | E10 | PASS |
| Misuse — track dokunulabilir değil / seviye seçimi yok (AC2 yapısal) | düğümler buton değil | E02 (`loop_track_test` display-only) + E21 | PASS |
| Misuse — splash / Home / store error'da back affordance yok | yok | E05, E07, E15 | PASS |
| Misuse — future-scope öğesi yok (ayarlar, seviye kartı, streak/yıldız çipi, jest ipucu) | yok | E07, E17 | PASS |
| Misuse — Home/splash/error'da Material ikon, `PlayTheme`, amber yok (oyuncu build'i) | yok | E07, E15 (debug satırının Material `OutlinedButton`'ları ve amber metni yalnız `kDebugMode` — C2 muafiyeti) | PASS |
| Türkçe büyük harf (`YOLCULUK`, `KAYITLI VERİLER`) | doğru İ/ı | E07, E15 | PASS |
| Arka plan → ön plan | entrance tekrar yok, bayat durum yok | E19 | PASS |
| AC2–AC6, AC11, AC13, AC14 (D3 değiştirmedi) | — | REUSED F05-QA-STRICT2 (bkz. §5) + E02 (suite yeşil) | PASS (reuse) |

## Client & UI Compliance

| Kontrol | Evidence | Sonuç |
| --- | --- | --- |
| Ekran hedefi: tek dokunuşla dönüş; Home her durumda tek birincil aksiyon | E07, E17 | PASS |
| Rota: `/` ⇄ `/play` değişmedi; CTA → `PlaySessionArgs(journeyLevel: ctaTarget)` | E08–E14 | PASS |
| Header/back: Home ve store error app root, back yok; sistem back (edge swipe) Play'den Home'a | E13, E15 | PASS |
| Loading: model gelmeden Home = splash karesi (boş kart/spinner yok) | E05 (3.78–4.07 s yalnız wordmark) | PASS |
| Error/recovery: store error + Retry | E15 | PASS |
| Pressed 0.98 | E18 | PASS |
| Focused (klavye odak halkası) | runtime'da sürülemedi (`simctl`); `LimePill` bileşen testleri (E02) | Limit — PENDING değil; kapsamda runtime zorunluluğu yok, not N6 |
| Duplicate action koruması | E10 | PASS |
| `ui-design.md` CTA hiyerarşisi, bileşen/state handoff, etkileşim niyeti | E07, E16, E17 | PASS |
| Semantics (VoiceOver) | runtime'da çalıştırılmadı; `journey_home_test` / `store_error_screen_test` / `loop_track_test` semantics etiket ve sıra testleri (E02) | Limit — not N6 |

## Stateful Flow & Integration

| Boundary / Transition | Actor / Start State | Expected | Evidence IDs | Result |
| --- | --- | --- | --- | --- |
| Boş store ile cold boot (gerçek bootstrap, gerçek store) | oyuncu, kurulu uygulama, store yok | Home "new" | E05 | PASS |
| Mevcut store ile cold boot | oyuncu, N1 store | Home N1, CONTINUE → replay | E06, E08, E09 | PASS |
| Bozuk store (açılamayan DB) | oyuncu | store error, veri sessizce silinmez, Retry bootstrap'ı yeniden koşar | E15 | PASS (bozuk dosya yerinde kaldı; Retry hatayı tekrar gösterdi — §18.8 kararı 4 beklenen) |
| Hydrate tamamlanmadan aksiyon | cold start | içerik yokken CTA yok (splash karesi) | E05 | PASS |
| Canlı read-model: `/play` snapshot yazar → Home yerinde güncellenir (warm) | Home mounted | warm = cold | E09, E10, E11, E13, E14 | PASS |
| Terminal yeniden kullanım: 30/30 sonrası replay → N1, sonra Next ile yeni replay | 30/30 | CONTINUE her zaman oturumdaki seviyeyi sürdürür | E09, E13 | PASS |
| Kill + relaunch sırasında oturum | L12 replay, 2 hamle | aynı ızgara, hamle, undo | E09 | PASS |
| Arka plan → ön plan | Home | durum aynı, entrance yok | E19 | PASS |
| Duplicate event (çift dokunma) | Home | tek push | E10 | PASS |
| Kazanç yazımı (unlock + best) ve oturum temizliği | L30, L1 kazanç | journey_progress güncel, active_session silinmiş | E11, E14 | PASS |

## Visual Quality Verdict

Bağımsız puan, yalnız bu turun runtime kanıtından (E05–E20). UI Designer (94) ve Frontend self-check'i girdi olarak kullanılmadı.

| Rubric Dimension | Score / 10 | Runtime Evidence | Notes |
| --- | --- | --- | --- |
| Experience Fit | 10 | E07, E09, E11 | Açılışta tek dokunuşla dönüş; N1 yarım bulmacayı asla gizlemiyor ve kart tamamlanmayı koruyor; hata ekranı sakin ve güven veriyor. |
| Visual Hierarchy | 9 | E07, E16, E15 | 1.0×'de etiket → başlık → geçerli düğüm → tek lime aksiyon → caption çok net. AX5'te serbest metin (caption, error gövdesi) kapaklı başlıktan büyüyor; contract gereği (§18.3 (6)) ama hiyerarşiyi tersine çeviriyor. |
| Layout, Rhythm and Responsiveness | 9 | E07, E16, E17 | Çapalar üç cihazda tutuyor (yatay ≤ 0.2 pt, CTA §6 ±1 pt); AX5'te kaydırmasız akış. Alt üçte bir kasıtlı boş (S-06b); Pro Max'te belirgin boşluk. |
| Typography and Content Craft | 9 | E07, E15, E16 | Durum başına yazılmış başlıklar, tek lime kelime, NBSP ile "·" öncesi kırılma, Türkçe büyük harf doğru. Kopya ara kopya (F10). AX5'te ok ikonu 20·s sabit kalıp etiketle orantı kaybediyor (Not N3). |
| Color, Surface and Asset System | 10 | E05, E07, E15, E20 | Token dışı renk yok; lime/periwinkle rolleri tutarlı; kırmızı yok; native launch → Flutter tek resim; finish düğümü lime taç. Ölçülen metin kontrastı ≥ 6.68 : 1. |
| Interaction, State and Feedback | 9 | E07, E15, E18, E10 | Her state ayırt edilebilir; press 0.98; çift dokunma korumalı. Retry anında başarısız olursa geri bildirim tek karelik (~17 ms) splash — oyuncu yeniden denendiğini algılayamayabilir (Not N2). Odak halkası runtime'da doğrulanamadı. |
| Motion and Sensory Quality | 9 | E05, E06, E11, E19 | Beyaz karesiz kesintisiz cold start; entrance bir kez; geri dönüşte/ön plana gelişte tekrar yok; Reduce Motion tek kare. Debug build'de entrance'ın ilk görünür karesi ~%80'de geliyor (görünür süre ~150–170 ms; Not N1). Ses/haptik kapsam dışı (F11) — motion yalnız görsel geri bildirimle puanlandı. |
| Originality and Product Identity | 10 | E07, E11 | Tırmanan loop track, halo ile geçerli düğüm, lime taçlı finish ve kenardan gelen lead-in çizgisi Looplet'e özgü; şablon hissi yok. |
| Accessibility and Inclusive Quality | 9 | E16, E17, E20, E06 | AX5'te klip/kaydırma yok; düğüm durumları dolgu + çerçeve türü + boyutla (renk dışı) ayrılıyor; Reduce Motion korunuyor; metin kontrastı yüksek. VoiceOver ve klavye odağı runtime'da sürülmedi (widget testleri var). |
| Implementation Fidelity and Polish | 10 | E07, E16, E17 | 9 Home state'i + varyantlar render'la birebir; tek dikey fark render'ın kendi §6 kayması (§18.8 kararı 1, açıklanmış); debug satırı ve debug kutusu tek debug-only sapma. Açıklanmamış sapma yok. |

Final Score: `94 / 100`

Lowest Dimension: `Visual Hierarchy — 9 / 10` (eşit: Layout, Typography, Interaction, Motion, Accessibility — 9)

Fail Conditions: `None`

Runtime Evidence Complete: `Yes` (iOS Simulator kapsamı; Android ve profile/release store-error yakalaması belirtilmiş limit — §18.8 kararı 3 ile release scope'a taşındı, bu verdict'i bloklamıyor)

Result: `PASS`

## 4. Pending Evidence

* **F05.D3-RELEASE-ERROR-CAPTURE** (Frontend/Mobile Developer; Blocking Scope `release`, FIRST-APP-DISTRIBUTION) — profile/release build'de store error'da istisna metni olmadığının runtime yakalaması. Bu tur için: `kDebugMode` sabiti + `showDetails: false` widget testleri (E02) + NC (TL) — QA kendi NC varyantını koşmadı; E04'te üç ayrı kural yakalandı. **Bu verdict'i bloklamaz** (Tech Lead kararı §18.8 (3)); PENDING kalır.
* Android launch/runtime (ANDROID-CI-EVIDENCE) — kaynaklar `launch_resources_test.dart` + ND-QA ile yakalandı (E04); cihaz koşusu yok.

## 5. Regression & Evidence Reuse

* **Etkilenen yüzey (`git diff --stat 5677471 078c926 -- app/lib`, Tech Lead ile aynı):** Home, `journey_home_view`, `journey_strings`, `design/components/info.dart` + `track.dart`, `shell/*`, `app_router.dart`, `main.dart`; native launch kaynakları. `app/lib/play/**`, `journey_progress.dart`, `journey_content.dart`, `persistence/`, `content/`, pubspec'ler değişmedi.
* **Depth sonucu:** full — startup (E05, E06), routing ve back yolları (E09–E14), tema zemini (E05 — native'den Home'a tek zemin) bu turda yeniden koşuldu.
* **EXECUTED THIS RUN:** E01–E21.
* **REUSED — fingerprint valid:**
  * F05-QA-STRICT2 (2026-09-27) davranış kanıtı: build gate R1–R6 + LABEL negatif vakaları, bundle mirror, `content:check` (AC3–AC6, AC14 içerik yolu), mikro-tutorial AC4/AC11, AC13 yıldız bağımsızlığı. Gerekçe: gate/içerik/`journey_content.dart`/persistence değişmedi (diff), ilgili testler E02'de yeşil.
  * F03-QA-D2R (2026-09-29, `app/` `5298c81a…`) Play ve sonuç ekranı görsel puanı (94): `app/lib/play/**` değişmedi. Buna rağmen round trip (Play açılışı, hamle, undo, sonuç, Next, back) bu turda runtime'da yeniden gözlendi (E09–E14) — regresyon yok.
* **INVALIDATED — rerun required (ve koşuldu):** önceki Home/splash/store error/cold start runtime kanıtı (D3 kodu değişti) → E05–E07, E15–E19.
* **Frontend kanıtı** (`design/runtime-d3/`): yalnız girdi; bu turun ölçümleri bağımsız yeniden üretildi ve teslimle uyuştu (ör. CTA band 487.0 pt, yatay Δ ≤ 0.2 pt).
* **Bağımsız QA probe'ları:** NI-QA (yeni negatif vaka), override'sız N1 warm/cold (E09), seviye 30'u gerçek hamlelerle çözerek AC12 N=30 (E11), çift dokunma (E10), ön plan dönüşü (E19), kontrast örneklemesi (E20).

## 6. Final Verdict

* `QA Result: Approved with Notes`
* Blocking Issues: `None`
* Required Fixes: `None`
* Non-blocking Notes:
  * **N1 — debug build'de entrance'ın ilk karesi geç** (E05, E06): içerik ilk kez göründüğünde animasyon ~%80'de; görünür entrance ~150–170 ms (spec 340 ms). JIT ilk-kare maliyeti; widget testleri zamanlamayı doğruluyor. Release pacing ölçülmedi → FIRST-APP-DISTRIBUTION'da kontrol edilmeli.
  * **N2 — Retry geri bildirimi tek kare** (E15): bootstrap anında başarısız olunca splash yalnız ~17 ms görünüyor; oyuncu Retry'nin çalıştığını fark etmeyebilir. ui-design §4'e uygun; kısa bir asgari splash/geri bildirim süresi opsiyonel iyileştirme (UI Designer / Frontend). F08-RETRY-STORE-CONNECTION ile birlikte ele alınabilir.
  * **N3 — AX5'te CTA ok ikonu sabit boyutta** (E16): etiket büyürken ok 20·s kalıyor; küçük orantı sorunu (paylaşılan `LimePill`; D2 sonuç ekranıyla aynı davranış).
  * **N4 — AX5'te hiyerarşi tersine dönüyor** (E15, E16): serbest metin (caption, error gövdesi) kapaklı başlıktan büyük; contract kararı (§18.3 (6)) — ileride tipografi ölçeği kararı için not.
  * **N5 — `highest_unlocked_level` 30 tamamlandıktan sonra 31** (E11): `max(existing, N+1)` (architecture §3); model yalnız 1…30 okuduğu için zararsız; F08/F05 veri notu.
  * **N6 — runtime'da sürülemeyenler:** klavye odağı ve VoiceOver (`simctl` sınırı) — widget testleriyle kapsanıyor; Android (ANDROID-CI-EVIDENCE); profile/release store error (F05.D3-RELEASE-ERROR-CAPTURE).
  * **N7 — hızlı art arda swipe'lar** (E11 hazırlığı): route geçişi/shift animasyonu sırasında gelen swipe'lar düşüyor (F03 input lock, kuyruk yok — F03 contract'ı). D3 bulgusu değil; bilgi amaçlı.
  * **N8 — kanıt boyutu:** `qa/d3/` ≈ 62 MB (26 MB ölçüm PNG'si, 26 MB video, 9 MB JPEG) — F00-ARTEFACT-SIZE kuralı kapsamında.

## 7. Tech Lead Note

* Root-cause alanı: bloklayan bulgu yok. Notlar N1–N3 polish (Frontend/Mobile Developer, gerekirse UI Designer); N2 F08 local-evidence aşamasında Retry ile birlikte değerlendirilebilir.
* Visual Quality Gate: bağımsız puan 94 / 100, her boyut ≥ 9, fail condition yok → **PASS** önerisi (gate geçişi Tech Lead'in).
* Routing/depth değişikliği gerekmiyor. Release scope yok; F05.D3-RELEASE-ERROR-CAPTURE release scope'ta PENDING kalıyor (verdict'i bloklamıyor, §18.8 (3)).
* **Workflow çelişkisi — Tech Lead çözmeli:** `sh ai-system/tools/workflow-state-audit.sh ai-system --local` → **FAIL**: `F05: final approval cannot coexist with required pending evidence/decision/blocker`. Audit (`workflow-flow-audit.mjs` satır 163 / 324 / 333), Blocking Scope'a bakmadan her PASS olmayan Evidence kaydını "required" sayıyor. §18.8 kararı 3 ise F05.D3-RELEASE-ERROR-CAPTURE'ı F05 ledger'ında PENDING bırakıp "verdict'i ve kapanışı bloklamaz" diyor. Bu kayıt Tech Lead'e ait; QA onu değiştirmez ve audit'i geçirmek için verdict'i değiştirmez. Öneri: kapanış checkpoint'inde kayıt F05 ledger'ından çıkarılıp yalnız FIRST-APP-DISTRIBUTION altında (workflow-follow-ups.md, zaten ekli) izlensin, ya da kanıt sahibi release'e ait ayrı bir kayda taşınsın. Aksi halde F05 Done da aynı audit kuralına takılır (satır 333).
* Simülatörler geri yüklendi: üç cihaz da text size `large`, Reduce Motion 0 (kontrol edildi). iPhone 16 store'u test sonrası durumda (1/30); 16e ve Pro Max store'ları silindi.

---

## Local Orchestration Update (QA)

* F05-QA-D3 → Done; `QA Result = Approved with Notes`; F05.D3-VISUAL-QA → PASS (provenance bu rapor).
* Owner / Next Role → Tech Lead (closure checkpoint). QA Stage, Scope, Modules, Depth, Reuse, Delivery Review, visual gate ve global state değiştirilmedi.

## Sonraki Komut

```text
Run Tech Lead
```
