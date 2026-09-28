# F03 — puzzle-play-session: QA Raporu (F03-QA-D2 — kazanma anı, board → sonuç geçişi ve tam ekran sonuç)

QA turu: 2026-09-28 · Görev: F03-QA-D2 · QA Stage: final · QA Scope: client-only · Release Scope: none · Visual Scope: motion-critical
Doğrulanan revizyon: HEAD `86c7318` (F03-FE-D2 teslimi `67d9ecb` + Tech Lead checkpoint belgeleri). `app/` ağacı `f5641d2f9b84d6597f1c86897a54027e9b1483a2` — brief'teki evidence-reuse fingerprint'i ile birebir aynı. `git status --short app` boş.
Derleme: `flutter build ios --simulator --debug` (Flutter 3.32.8), `App.framework/App` SHA-1 `6c9243bd6ed7…`. Üç simulator'a bu build kuruldu.

Önceki rapor (F03-QA-D1R, Approved with Notes, 93 / 100) byte-for-byte arşivde: [history/f03-puzzle-play-session-2026-09-28/qa-at-d1r-verdict.md](../../history/f03-puzzle-play-session-2026-09-28/qa-at-d1r-verdict.md) (SHA-1 `07357c0a…`).
Bu turun kanıt klasörü [qa/d2/](qa/d2/):
* ekran görüntüleri `QA-*.jpg`;
* videolar `QV-*.mp4` (2 px/pt);
* kare kontak sayfaları `QS-*.jpg`;
* QA'ya ait araçlar `qa/d2/src/` (`qa-probe-d2.swift`, `qa-t0-fit.py`, `qa-timing-d2.py`).

> Bağımsızlık notu: bu oturumda QA'dan önce Tech Lead checkpoint'i (architecture §20.8) de çalıştırıldı. QA verdict'i o kabule dayanmıyor. Zamanlama ve C2 ölçümleri QA'nın kendi araçlarıyla yeni runtime kayıtlarından üretildi. Frontend'in `timing-d2.py` / `video-d2` araçları yalnız çapraz kontrol olarak kullanıldı (E-X1).

---

## 0. QA Execution Plan

* **Stage / Scope:** final · client-only · Release Scope none.
* **Modüller:**
  * `core`;
  * `client-ui` (sonuç ekranı, geri / Next / Retry navigasyonu, varyant state'leri);
  * `visual-quality` (Visual Scope `motion-critical`);
  * `stateful-flow` (`won`'da kalıcılık, yaşam döngüsü ortasında arka plan / kill / sistem geri, retry state'i).
* **Regression Depth: full.** Won yolu tamamen değişti; F04 sonucu ve F05 Next / unlock çapraz feature; ortak tasarım katmanı (`TileFace`, `StarRow`, `ScrollBand`) ve Play host'u (`play_session_screen.dart`, `puzzle_board.dart`) değişti.
* **Evidence Reuse: allowed.** Fingerprint `app/` `f5641d2f…` eşleşiyor. Frontend'in `integration_test` 13 / 13 (iPhone 16) kaydı REUSED. Analyze ve app suite bu turda yeniden çalıştırıldı (E-A1). Frontend'in runtime kayıtları ve Tech Lead ölçümleri yalnız karşılaştırma girdisi. Bütün runtime puanlaması QA'nın kendi kayıtlarından.
* **Canonical target:** iOS Simulator 18.6, debug build — iPhone 16 `D0011CE7` (birincil), 16e `6DBDFD97`, 16 Pro Max `02FDE776`. Required class: runtime + video.
* **Yöntem:**
  * `design/src/capture-d2.sh seed` / `seed-sim.sh` ile level N'i BFS-doğrulanmış çözümünden bir hamle önceye getirme; Home DEVAM ET;
  * kazanan hamle simulator touch-path ile;
  * `simctl io recordVideo` (değişken kare hızı, kare yalnız ekran değişince yazılır);
  * `simctl ui content_size`; `defaults write com.apple.Accessibility ReduceMotionEnabled`.
  * Simulator ayarları sonunda geri alındı: üç cihazda `large`, Reduce Motion 0.
* **Bağımsız T0 yöntemi (`qa-t0-fit.py`):** T0, hedef raydaki chrome kararmasının başlangıcıdır (0–200 ms, `Curves.easeOut`). Her karenin luma'sından geriye çözülür; medyan ve saçılım raporlanır. Reduced yolda kararma bir basamaktır; T0 son kararmamış ve ilk kararmış kare arasında braketlenir, içerik fade'inin doğrusal fit'i ile daraltılır.
* **C2 (§20.7):** satırın lime bounding box'ı kendi board hücrelerinin dışına > 1 pt taşıyor mu? Örnekleme 2 px ızgara, @3x'te 0.67 pt.
* **Fail-fast checkpoint:** build + kurulum + ilk kritik yolculuk (J1). Geçti.

## 1. Evidence Ledger

Hepsi EXECUTED THIS RUN, 2026-09-28 18:55–19:29, QA; aksi yazılmadıkça iPhone 16, revizyon `86c7318` / `app/` `f5641d2f…`, debug build.

| Evidence ID | Claim / Scenario | Class | Command / Action | Target | Result / Counts | Provenance / Fingerprint | Isolation |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E-A1 | Statik analiz + app suite | automated | `melos run analyze`; `cd app && flutter test` | host macOS | analyze SUCCESS (exit 0); app **503 passed**, 0 fail, 0 skip (exit 0) | 19:28, `86c7318`, `f5641d2f…` | widget testleri in-memory Drift + fake time |
| E-A2 | `integration_test` | repeatable integration | Frontend koşusu | iPhone 16 | 13 / 13, exit 0 | **REUSED** — Frontend 2026-09-28 18:34, `app/` fingerprint aynı | — |
| E-J1 | Satır 2, L5 (`D0 D1` + `D1`), Perfect ilk çözüm | runtime-video | seed → DEVAM ET → sütun 1 aşağı | 393×852 | QA T0 = 2.2506 s (6 kare, saçılım 5.2 ms). Satır hücrelerinde **+599'a kadar**, ilk hareket **+618**. Board dışında lime 0 px (T0 … +748). Başlık bölgesi luma'sı +700'e kadar düz (23.51–23.57), ilk değişim **+717**. Yıldızlar +1100'de 2, +1320'de 3. | `QV-16-r2-L5.mp4`, `QS-16-r2-L5-frames.jpg`, `QA-16-D2-01-L5-perfect.jpg` | — |
| E-J2 | Satır 0, L26 (`L0 D1 R4 R4` + `D4`), kilitli T ve R kazanan satırda (C-11) | runtime-video | aynı yöntem | 393×852 | T0 = 2.2572 s (saçılım 4.1). Hücrelerde +599, ilk hareket +618. Erken doldurma kareleri **yakalandı**: kilit ikonları +87…+137'de dolumla sönüyor, **+170'te yok** (≤ 210). Kilitli karolar komşularıyla lime. | `QV-16-r0-L26.mp4`, `QS-16-r0-L26-C11-frames.jpg`, `QA-16-L26-*.jpg` | — |
| E-J3a | Satır 4, L4 (`D0 U3 R3` + `D4`), en uzun kayma | runtime-video | aynı yöntem | 393×852 | T0 = 2.2769 s (saçılım 24.5). Hücrelerde +600, ilk hareket +616. Kare boşlukları: +451 (85 ms, sonuç mount'u, statik bekleme); kayma sırasında +766 / +801 / +835 (33–35 ms, her biri tek kare). | `QV-16-r4-L4.mp4`, `QA-16-L4-result-perfect.jpg` | debug build |
| E-J3b | Satır 4, L4 — iPhone 16e, ısınmış koşu (Retry + elle 4 hamle) | runtime-video | aynı | 390×844 | T0 = 2.3314 s (saçılım 3.9). Hücrelerde +597, ilk hareket +617. **600–1400 arasında > 30 ms kare boşluğu yok** (§16.11.1 (18)). Sonuç eşitlenen en iyi (Perfect, `HARİKA`). | `QV-16e-r4-L4-warm.mp4`, `QA-16e-L4-result-matched.jpg` | debug build |
| E-J3c | Satır 4, L4 — iPhone 16e, soğuk ilk koşu | runtime-video | aynı | 390×844 | Settle ve ilk ~130 ms doldurma **120 ms'lik tek yakalama boşluğuna** düştü; T0 bu kayıttan ±30 ms'den iyi sabitlenemiyor. Kayma penceresinde (≈ +600…+1400) tek 33 ms boşluk. C2 için kullanılmadı. | `QV-16e-r4-L4.mp4`, `QA-16e-L4-result-perfect.jpg` | debug, soğuk ilk kazanma |
| E-X1 | Çapraz kontrol: Frontend'in `timing-d2.py`'si QA'nın kendi videolarında | runtime-video | `VIDEO_D2=… timing-d2.py win …` | QA videoları | r2 596 / 615, ilk sonuç pikseli 713, pill rest 948, yıldızlar 1285. r4 (16) 567 / 601, 717, 951, 1286. 16e ısınmış 599 / 619, 718, 954, 1284. QA ölçümüyle tutarlı. | QA videoları | Frontend aracı |
| E-V1…V9 | F04 varyantları (§16.8) ve render karşılaştırması | runtime-screenshot | seed + çöz | 393×852 | Aşağıdaki satırlar | `QA-16-D2-0*.jpg`, `QS-render-vs-runtime.jpg` | — |
| E-V1 | Perfect ilk çözüm (L5, 3) | runtime | E-J1 | 16 | `HARİKA`, iki satır başlık, "Hedef üç hamlede…", 3★, `3 · 3 · 3★`, Next birincil, Retry bağlantı | `QA-16-D2-01-L5-perfect.jpg` | — |
| E-V2 | Perfect + yeni en iyi (önceki 5) | runtime | seed best 5 | 16 | Yalnız `HARİKA` (C-4 önceliği). `EN İYİ 3★`; DB `journey-tr-05 3 / 3★ perfect`; seviye 6 açık (F05 AC1). | `QA-16-D2-02-perfect-new-best.jpg` | — |
| E-V3 | Yeni en iyi 2★ (önceki 6, 5 hamle) | runtime | seed `D0 R3 L3 D1` + `D1` | 16 | `YENİ EN İYİ`, 2★, `5 · 3 · 5`, Retry birincil, "Sonraki bölüm" bağlantı | `QA-16-D2-03-new-best-2star.jpg` | — |
| E-V4 | İlk çözüm 2★ (5 hamle) | runtime | aynı, önceki yok | 16 | Rozet yok; rozet satırı ayrılmış, cevap satırı V3 ile aynı y'de | `QA-16-D2-04-first-clear-2star.jpg` | — |
| E-V5 | Eşitlenen en iyi (önceki 5, 5 hamle) | runtime | aynı, önceki 5 | 16 | Rozet yok, `5 · 3 · 5` | `QA-16-D2-05-matched-best.jpg` | — |
| E-V6 | 1★ gelişme yok (7 hamle, önceki 4) | runtime | `D0 R3 L3 R4 L4 D1` + `D1` | 16 | 1★, `7 · 3 · 4`, "yedi hamlede", en iyi 4 korunuyor (F04 AC5) | `QA-16-D2-06-1star-no-improvement.jpg` | — |
| E-V7 | Next bağlı değil (debug L01, `ASALM` → `MASAL`, 1 hamle) | runtime | Home debug L01 | 16 | Perfect ama Retry birincil; "Sonraki bölüm · yakında" soluk; dokununca etkisiz; `1 · 1 · 1★` | `QA-16-D2-08-next-not-wired.jpg` | debug kaynak |
| E-V8 | Seviye 30 Perfect (`U1 R4 U2 U2` + `D3`) | runtime | seed 30 | 16 | "Yolculuğu tamamla" birincil; ZEMİN, kilitli Z ve N lime | `QA-16-D2-09-level30-perfect.jpg` | — |
| E-V9 | Seviye 30 2★ (7 hamle) | runtime | + `R3 L3` | 16 | Retry birincil, "Yolculuğu tamamla" bağlantı, `7 · 5 · 7` | `QA-16-D2-09b-level30-2star.jpg` | — |
| E-V10 | Cihaz varyantları | runtime | seed + çöz | 16e, Pro Max | 16e Perfect ve eşitlenen en iyi (L4); Pro Max Perfect (L5). Bantlar render ile uyumlu. | `QA-16e-L4-*.jpg`, `QA-pm-D2-01-perfect.jpg` | — |
| E-R1 | Retry A, 2★ sonuçtan; **çift dokunuş** | runtime-video | "Tekrar oyna" pill'e iki hızlı dokunuş | 16 | Satır raya uçuyor, sonuç 0–80 ms'de sönüyor, Play yeniden grid'de. Board son değerinde **+290** (QA luma) / +293 (E-X1); ≤ 400. Sonra `HAMLE 0`, undo devre dışı, 3 nokta. Snapshot `restartCount 1`, hamle 0, undo 3 (çift dokunuş tek eylem). En iyi 5 / 2★ korunuyor. | `QV-16-retry-L5.mp4`, `QS-16-retry-L5-frames.jpg`, `QA-16-D2-13-after-retry.jpg` | — |
| E-N1 | "Sonraki bölüm" (1★ sonuçtan) | runtime | bağlantıya dokun | 16 | L6 açıldı (`SEVİYE 06`, `HAMLE 0`); ilerleme 6, L5 tamam, en iyi 4 | `QA-16-D2-14-next-L6.jpg` | — |
| E-N2 | "Yolculuğu tamamla" (seviye 30); ardından ikinci dokunuş | runtime | pill'e iki dokunuş | 16 | Terminal Home `TAMAMLANDI 30 / 30`; ilerleme 31, en iyi 5 / 3★, aktif oturum yok; çift navigasyon yok (F05 AC12) | `QA-16-D2-14-level30-terminal-home.jpg` | — |
| E-B1 | Rest'te geri butonu | runtime | (48, 82)'ye dokun | 16 | Home | `QA-16-D2-14-back-home.jpg` | — |
| E-B2 | Sistem geri / kenar kaydırması **≈ T0 + 220** | runtime-video | kazanan hamle + 0.35 s + sol kenardan kaydırma | 16 | T0 = 2.301 s (dim fit). Sayfa +220 civarında kaymaya başlıyor, Home geliyor. DB: L5 tamam, 6 açık, en iyi 3 / 3★, aktif oturum yok. | `QV-16-sysback-mid.mp4`, `QS-16-sysback-mid-frames.jpg`, `QA-16-D2-14-sysback-mid-home.jpg` | — |
| E-B3 | Sistem geri **settle anında** (≈ T0 − 100 … T0) — ek, daha sert durum | runtime-video | kazanan hamleden hemen sonra kenar kaydırması | 16 | Kazanma pop geçişi sırasında settle etti. Home; tamamlanma yazılmış; çökme yok. | `QV-16-sysback-at-settle.mp4`, `QS-16-sysback-at-settle-frames.jpg` | — |
| E-L1 | Arka plana alma **≈ T0 + 535** → dönüş | runtime-video | HOME tuşu, 3 s sonra `simctl launch` | 16 | T0 = 2.266 s. Dönüşte ilk canlı kare rest durumu (3★), ara pop karesi yok, tekrar oynatma yok. Zoom sırasında görünen 1★ iOS'un arka plan snapshot'ı (Not N1). | `QV-16-background-mid.mp4`, `QS-16-background-*-frames.jpg`, `QA-16-D2-16-background-resume.jpg` | — |
| E-L2 | Kill **≈ T0 + 400…485** → yeniden açılış | runtime-video | `simctl terminate`, sonra `launch` | 16 | T0 = 2.306 s; son uygulama karesi +401, springboard +486. Kill sonrası DB: L5 tamam, 6 açık, en iyi 3, aktif oturum yok. Yeniden açılış: Home "Seviye 6". | `QV-16-kill-mid.mp4`, `QA-16-D2-16-kill-relaunch.jpg` | — |
| E-M1 | Rest öncesi dokunuşlar düşürülüyor | runtime-video | L01 kazanımından hemen sonra pill ve geri butonuna dokunuş | 16 | Sonuç ekranı yerinde kaldı; Retry tetiklenmedi, Home'a dönülmedi. Rest sonrası düşselerdi işlenirlerdi; sonradan kuyruktan da işlenmediler. | `QV-16-L01-early-taps.mp4` | dokunuş zamanı videoda görünmez; sonuçtan çıkarım |
| E-M2 | Tutorial görünürken çözme (L5, ack 0) | runtime-video | seed ack 0 + kazanan sütun hamlesi | 16 | Pill sürükleme sırasında görünüyor; kazanan sütun hamlesi ack'i yazıyor ve pill'i söndürüyor (+200'de yok). Sonucun arkasında ipucu yok. C2: +585 / +619. | `QV-16-tutorial-win-L5.mp4`, `QS-16-tutorial-win-L5-frames.jpg` | — |
| E-RM1 | Reduce Motion AÇIK — kazanma | runtime-video | RM 1 + L5 | 16 | T0 braketi (2.2633, 2.3100]; içerik fade fit'i 2.279 ± 0.002. Satır T0'da lime ve statik, board %50. Çapraz geçiş +303'te başlamamış, +319'da %12. Board minimumu +466. İçerik +467 → +634'te %87; son %13 125 ms'lik tek kare boşluğuyla atlıyor. Uçuş / kayma yok. | `QV-16-reduced-win-retry.mp4`, `QA-16-D2-RM-result.jpg` | debug build |
| E-RM2 | Reduce Motion AÇIK — retry dip | runtime-video | aynı video, "Tekrar oyna" | 16 | Sonuç ≤ +50…67'de gidiyor, sonra Play yükseliyor (sıralı, çift pozlama yok); rest ≈ +152…168 | aynı, `QA-16-D2-RM-after-retry.jpg` | — |
| E-T1 | Metin ölçeği AX5, **offset 0'a iniş** | runtime | AX5 iken kazan | 16 | Geri + rozet üstte, başlık 1.3×'te sınırlı, alt başlık 3 satır (kelime arası), pill etiketi büyüyor | `QA-16-A11Y-ax5-offset0.jpg` | — |
| E-T2 | AX5 sona kaydırma / geri yukarı | runtime | yukarı / aşağı kaydır | 16 | Sonda geri butonu sabit, bant arkasında, "Tekrar oyna" home indicator'ın üstünde. Geri yukarı kaydırınca bant temizleniyor. | `QA-16-A11Y-ax5-scrolled-end.jpg`, `QA-16-A11Y-ax5-scrolled-back-top.jpg` | — |
| E-T3 | 1.3× sınırda (xxxL) kaydırma yok, üç cihaz | runtime | xxxL + kaydırma denemesi + piksel farkı | 16, 16e, Pro Max | Durum-bar altı piksel farkı: 16 `0 / 1 401 840`, 16e `0 / 1 375 920`, Pro Max `0 / 1 760 880` | `QA-16-A11Y-cap-xxxL.jpg`, `QA-16e-A11Y-cap-xxxL.jpg`, `QA-pm-A11Y-cap-xxxL.jpg` | — |
| E-T4 | 16e AX5 | runtime | canlı AX5 | 16e | Kelime arası kırılım, geri sabit | `QA-16e-A11Y-ax5.jpg` | — |
| **E-T5** | **AX5'te kaydırılmışken metin boyutu küçülünce ScrollBand takılı kalıyor** (F03-QA-D2-01) | runtime | AX5 → sona kaydır → xxxL (ve `large`) | 16 | İçerik offset ≈ 0'a dönüyor, ama bant görünür kalıyor. `HARİKA` rozeti ve geri butonu kararıyor; `large`'da rozet neredeyse görünmez. Kaydırma denemesi hiçbir şeyi değiştirmiyor (0 px). Kontrol: offset 0'dan küçülmede sorun yok (E-T2). | `QA-16-A11Y-cap-xxxL.jpg`, `QA-16-A11Y-back-to-large.jpg`, `QA-16-A11Y-ax5-top-then-large.jpg` | — |
| E-D1 | D1 Play regresyonu | runtime | L23 çözülme (`R1 D3 U4` + sütun 4 yukarı); undo; restart; L01 sütun (reddedilir); tutorial; satır / sütun sürükleme; chevron; seed'li DEVAM ET ile resume | 16 | Çözülme ✓ (`SAAT`, `HAMLE 4`). Undo `HAMLE 3`, donma geri, bir nokta harcanmış (AC6). Restart `HAMLE 0`, noktalar dolu, diyalog yok (AC7). Reddedilen hamle `HAMLE 0`. Wrap-ghost sürüklemede görünür. Resume snapshot'ları doğru açıldı (AC10). | `QA-16-D1R-*.jpg`, `QV-16-D1R-*.mp4` | — |
| E-P1 | Render ↔ runtime | parity-comparison | D2-01 / 03 / 08 yan yana | 16 | Yerleşim, rozet, CTA ağırlığı, tipografi örtüşüyor. `EN İYİ` ★ render'dan yüksek; stat etiketleri ~1–3 pt aşağıda (Frontend'in bildirdiği sapmalar). Alt başlık runtime'da render'dan hafif daha soluk. | `QS-render-vs-runtime.jpg` | — |

## 2. Acceptance & Critical Journey Coverage

| AC / Journey | Expected | Evidence IDs | Result |
| --- | --- | --- | --- |
| §16.11.1 (1) T0 … 599 yalnız board | Satır doldurma, bloom, dim; sonuç pikseli yok | E-J1, E-J2, E-J3a/b, E-X1 | PASS |
| §16.11.1 (2) C-11 | Kilitli karolar lime, ikonlar ≤ +210 | E-J2 | PASS (+170) |
| §16.11.1 (3) Kayma 600–840, yuvaya iniş | Tek birim, boyut / radius morph | E-J1 (+640 / +760 / +840 kareleri), E-J3 | PASS |
| §16.11.1 (4) Chrome +720'de 0 | Header, `HAMLE`, ray, HUD, board | E-J1 kareleri, E-X1 (`HAMLE` +730–736) | PASS (+720'den sonraki ilk karede) |
| §16.11.1 (5) Rest ≤ 940; yıldızlar ≤ 1300 | — | E-X1 (pill 947–954, yıldızlar 1284–1286), E-J1 kareleri | PASS (± bir yakalama karesi) |
| §16.11.1 (6) Reduced yol | Statik lime, çapraz geçiş 300–460, içerik 460–660 | E-RM1 | PASS |
| §16.11.1 (7) Rest öncesi input düşer; sistem geri her an | — | E-M1, E-B2, E-B3 | PASS |
| §16.11.1 (8) 1.0× yerleşim, ayrılmış rozet satırı, iki satır başlık | Üç cihaz | E-V1…V10, E-P1 | PASS |
| §16.11.1 (9) Varyant tablosu | Rozet önceliği, CTA ağırlığı, "· yakında", "Yolculuğu tamamla", eski işaretler yok | E-V1…V9 | PASS |
| §16.11.1 (10) F04 AC7 içeriği | Kelime, hamle, optimal, yıldız, en iyi, Retry, Next | E-V1…V9 | PASS |
| §16.11.1 (11) Tek parlama | Yalnız cevap satırı + radial | E-V*, E-P1 | PASS |
| §16.11.1 (12) Metin ölçeği | Sınıra kadar kaydırma yok; AX5 kaydırma, geri sabit, **bant yalnız kaydırılmışken**, offset 0'a iniş | E-T1…E-T4, **E-T5** | **FAIL** — F03-QA-D2-01 |
| §16.11.1 (13) Retry | ≤ 400, `HAMLE 0`, undo devre dışı, 3 nokta; reduced 160 | E-R1, E-RM2 | PASS |
| §16.11.1 (14) Next / geri; Close yok | — | E-N1, E-N2, E-B1…B3 | PASS |
| §16.11.1 (15) Erişilebilirlik | ≥ 44 pt hedefler, kontrast, semantics, odak halkası | E-V*, E-A1 (semantics testleri) | PASS görsel; VoiceOver ve odak halkası runtime'da sürülemedi (belirtilen sınır) |
| §16.11.1 (16) Yaşam döngüsü | Arka plan → rest; kill → Home, yazılmış | E-L1, E-L2 | PASS |
| §16.11.1 (17) Won yolunda eski öğe yok | — | E-V*, E-A1 | PASS |
| §16.11.1 (18) 16e satır 4'te görünür takılma yok | — | E-J3b | PASS (600–1400'de boşluk yok) |
| F04 AC1–AC3 (3 / 2 / 1★) | Perfect 3★ kayıtlı; 2★; 1★ | E-V1, E-V3, E-V9, E-V6 | PASS |
| F04 AC4 (yıldız ≥ 1) | Hiçbir varyantta 0★ yok | E-V*, E-A1 | PASS |
| F04 AC5 / AC6 (en iyi korunur / güncellenir, Perfect set) | — | E-V6 (4 korunur), E-V2 (5 → 3, perfect) + DB | PASS |
| F04 AC7 (içerik: kelime, hamle, optimal, yıldız, en iyi, Retry, Next) | — | E-V*, E-R1, E-N1 | PASS |
| F04 AC8 (ilk çözümde en iyi = sonuç) | — | E-V1, E-V4 | PASS |
| F04 AC9 / AC10 (opt+3 → 2★, opt+4 → 1★) | Sınırlar | AC10: E-V6 (7 = 3+4 → 1★) runtime; AC9: E-A1 (`star_rating_test`) — runtime'da tam opt+3 koşulmadı | PASS (AC9 automated sınıfta) |
| F05 AC1 (unlock Next / geri / sistem geri ile) | — | E-V2, E-N1, E-B2, E-L2 | PASS |
| F05 AC12 (30 → terminal Home) | — | E-N2 | PASS |
| F03 AC8 / AC11 (kazanma → kilit + sekans + sonuç; geçici kelime kazandırmaz) | — | E-J*, E-A1 | PASS |
| Misuse: çift Retry / çift Next | Tek eylem | E-R1, E-N2 | PASS |
| Misuse: devre dışı bağlantıya dokunuş | Etkisiz | E-V7 | PASS |
| Misuse: tutorial görünürken çözme | Sonucun arkasında ipucu yok | E-M2 | PASS |
| D1 Play regresyonu | Çözülme, undo, restart, reddedilen hamle, resume | E-D1 | PASS |

## Client & UI Compliance

| Kontrol | Evidence IDs | Result |
| --- | --- | --- |
| Screen goal ve kritik yolculuk (çöz → sonuç → Next / Retry / geri) | E-J1, E-N1, E-R1, E-B1 | PASS |
| Route / geri / dismiss: sonuç `/play`'in state'i; geri butonu ve sistem geri → `/`; Close yok | E-B1…B3, E-V* | PASS |
| State'ler: 10 varyant, devre dışı bağlantı, rest öncesi kilit | E-V1…V10, E-M1 | PASS |
| Duplicate action koruması | E-R1, E-N2 | PASS |
| Controller → view-model → görünür UI (yıldız, en iyi, rozet) | E-V2…V6 + DB | PASS |
| Handoff CTA hiyerarşisi ve interaction intent (§16.8, §16.11) | E-V*, E-P1 | PASS; basılı pill yalnız ölçekleniyor, kararmıyor (NTLC-D2-2) |
| Metin ölçeği / ScrollBand | E-T1…T5 | FAIL — F03-QA-D2-01 |

## Stateful Flow & Integration

| Boundary / Transition | Actor / Start State | Expected | Evidence IDs | Result |
| --- | --- | --- | --- | --- |
| `won` anında kalıcılık | Oyuncu, çözen hamle | `completed` + en iyi + unlock `won`'da yazılır | E-V2, E-B2, E-L2 (DB) | PASS |
| Sistem geri ≈ T0 + 220 | Sekans ortası | `/`; tamamlanma kalıcı | E-B2 | PASS |
| Sistem geri settle anında | T0 sınırı | `/`; tamamlanma kalıcı; çökme yok | E-B3 | PASS |
| Arka plan ≈ T0 + 535 → dönüş | Sekans ortası | Rest, tekrar oynatma yok, kilit takılmıyor | E-L1 | PASS |
| Kill ≈ T0 + 400 → yeniden açılış | Sekans ortası | Home, aktif oturum yok, en iyi + unlock yazılmış | E-L2 | PASS |
| Retry → yeniden çözme | Sonuç 2★ | Hamle 0, undo 3, restart +1; en iyi korunur | E-R1 | PASS |
| Next → N+1 / terminal | Sonuç | `pushReplacement` N+1; 30 → terminal | E-N1, E-N2 | PASS |
| Tutorial ack | L5, ack 0 | Kazanan sütun hamlesi ack'i yazar | E-M2 | PASS |
| Resume snapshot → Play | Home DEVAM ET | Seed'li hamlelerle doğru state | tüm seed'li koşular | PASS |

## Visual Quality Verdict

| Rubric Dimension | Score / 10 | Runtime Evidence | Notes |
| --- | --- | --- | --- |
| Experience Fit | 10 | E-J1, E-R1, E-V* | Kazanan satır ödülün kahramanı oluyor. Board'dan sonuca kayıyor; retry'da "cevap hedefe dönüyor". Sakin, bulmacaya uygun bir ödül anı. |
| Visual Hierarchy | 10 | E-V1…V9 | Her varyantta tek odak ve tek birincil eylem. Rozet satırı ayrılmış, cevap satırı sabit yerde. Yıldızlar rest'ten sonra geliyor. |
| Layout, Rhythm and Responsiveness | 9 | E-V10, E-T1…T5 | Üç cihazda ritim tutarlı; sınıra kadar kaydırma yok; AX5'te düzgün kaydırma. Canlı metin boyutu küçülmesinde bant takılıyor (F03-QA-D2-01). |
| Typography and Content Craft | 9 | E-V*, E-T1, E-P1 | Authored iki satır başlık, harfle yazılmış sayılar, doğru Türkçe büyük harf (İ). Alt başlık render'dan hafif soluk. AX5'te pill etiketi iki satıra kırılıyor (kabul edilebilir). |
| Color, Surface and Asset System | 10 | E-V*, E-P1 | Tek parlama kuralı tam uygulanmış. Lime cevap satırı + radial, cam stat kartı, çizilmiş ikonlar; pill ve yıldızlar düz. |
| Interaction, State and Feedback | 9 | E-M1, E-R1, E-V7, E-N2 | Kilit, çift dokunuş, devre dışı bağlantı doğru. Basılı pill yalnız ölçekleniyor (NTLC-D2-2). Geç rozet fade'i runtime'da tetiklenemedi (widget testi, E-A1). |
| Motion and Sensory Quality | 9 | E-J1…J3, E-R1, E-RM1/2 | Zamanlama sözleşmeye milisaniye düzeyinde uyuyor; reduced yollar doğru. Debug build'de iPhone 16 satır 4 kaymasında üç tek kare kaçırma, reduced rest sonunda bir 125 ms boşluk. Release pacing ölçülmedi. Ses / haptik F11. |
| Originality and Product Identity | 9 | E-J1, E-R1 | Satırın board'dan sonuca ve geri raya yolculuğu ürüne özgü bir imza; Loop Glass dili tutarlı. |
| Accessibility and Inclusive Quality | 8 | E-T1…T5, E-RM1/2 | 1.3× sınır, AX5 kaydırma, reduced motion ve ≥ 44 pt hedefler iyi. F03-QA-D2-01 rozeti ve geri butonunu karartıyor. VoiceOver ve odak halkası runtime'da doğrulanamadı. |
| Implementation Fidelity and Polish | 9 | E-P1, E-V10, E-X1 | Render ile yakın parity. `EN İYİ` ★ yüksekliği, stat etiketleri ve bant hatası bilinen sapmalar. |

Final Score: 92 / 100

Lowest Dimension: Accessibility and Inclusive Quality — 8 / 10

Fail Conditions: None (premium-ui-rubric fail listesinden hiçbiri; F03-QA-D2-01 bir acceptance-list ihlali, kritik kontrast / focus / hedef / reduced-motion ihlali değil)

Runtime Evidence Complete: Yes (VoiceOver ve odak halkası belirtilen automated sınıfta; Android kapsam dışı sınır)

Result: FAIL (92 < 93; §16.11.1 (12) runtime'da başarısız)

## 3. Findings

**F03-QA-D2-01 — AX5'te kaydırılmışken OS metin boyutu küçülünce ScrollBand görünür kalıyor ve rozeti / geri butonunu karartıyor**
* **Severity / Type:** Medium · UI defect (accessibility yolu) · acceptance-list ihlali.
* **İlgili:** `ui-design.md` §16.11.1 (12) ("the scroll band appears only when scrolled"); architecture §20.3 (9) (C-9); task F03-FE-D2 brief madde 3; modül client-ui / visual-quality.
* **Expected:** içerik offset 0'a döndüğünde bant görünmez; rozet ve geri butonu tam görünür (offset 0 durumunda olduğu gibi, E-T1 / E-T2).
* **Actual:** sonuç ekranında AX5'te sona kaydırılıp OS metin boyutu canlı olarak xxxL'ye ya da `large`'a düşürülünce içerik offset ≈ 0'a dönüyor, ama bant tam görünür kalıyor. `HARİKA` rozeti ve geri butonu bandın altında kararıyor; `large`'da rozet neredeyse görünmez. Kaydırma artık mümkün değil (extent 0), bu yüzden kullanıcı bandı temizleyemiyor. Durum sonuç ekranından çıkana kadar sürüyor.
* **Adımlar (iPhone 16, `86c7318`):**
  1. `capture-d2.sh seed <udid> 5 '["D0","D1"]'`;
  2. `simctl ui <udid> content_size accessibility-extra-extra-extra-large`;
  3. DEVAM ET, sütun 1 aşağı (kazan);
  4. sonucu sona kaydır;
  5. `simctl ui <udid> content_size extra-extra-extra-large` (ya da `large`).
  * Kontrol: 4. adımda geri yukarı kaydırılıp sonra küçültülürse sorun yok.
  * Kanıt: E-T5 (`QA-16-A11Y-cap-xxxL.jpg`, `QA-16-A11Y-back-to-large.jpg`), kontrol E-T2 / `QA-16-A11Y-ax5-top-then-large.jpg`.
* **Kök neden hipotezi (yalnız hipotez, source destekli):** `result_view.dart` `_onScroll` bandı yalnız `ScrollController` dinleyicisinden günceller (satır 218–221). İçerik boyutu küçülünce `ScrollPosition` offset'i dinleyicileri bildirmeden düzeltiyor, `_band` eski değerde kalıyor.
* **Öneri (Frontend/Mobile Developer):**
  * bant görünürlüğünü scroll metrics değişiminde de yeniden hesapla (ör. `ScrollMetricsNotification` ya da layout sonrası kontrol);
  * AX5 → sona kaydır → metin ölçeği 1.0 → bant 0 olmalı diyen bir widget testi ekle;
  * negatif çalıştırma: düzeltme kaldırılınca test kırılmalı.

## 5. Regression & Evidence Reuse

* **Etkilenen yüzey:** won yolu tümüyle (win sekansı, geçiş, sonuç, retry), F04 sonucu, F05 Next / unlock / terminal, ortak tasarım katmanı, Play host'u. Depth full — hepsi runtime'da yürütüldü (E-J*, E-V*, E-R1, E-N*, E-B*, E-L*, E-D1).
* **REUSED — fingerprint geçerli:** E-A2 (`integration_test` 13 / 13, `app/` `f5641d2f…`). Widget testlerindeki semantics / VoiceOver sırası, D2-07 no-optimal ve geç rating okuma (C1) E-A1 içinde bu turda yeniden çalıştırıldı (503 geçti). Bunlar automated sınıfta sayıldı, runtime olarak değil.
* **INVALIDATED:** D1 Play runtime kanıtı (F03.D1-EVIDENCE) değişen `play_session_screen.dart` / `puzzle_board.dart` için doğrudan kullanılmadı; D1 yolculukları yeniden yürütüldü (E-D1).
* **Bağımsız QA probe'ları:**
  * C2 ve T0 QA'nın kendi aracıyla, dört koşuda (satır 0 / 2 / 4, 16 ve 16e): ilk hareketli kare +616…+619. En katı yorumla, yani T0 = son kararmamış kare alınsa bile, ≥ T0 + 600.2;
  * yeniden kodlanmış `.mp4`'ler ham kayıtları 1–2 ms içinde üretiyor (r2: 599 / 618 → 600 / 618; 16e: 597 / 617 → 599 / 619).
* **Frontend kanıtıyla fark:** Frontend'in tablosuyla çelişen bir ölçüm yok. Tech Lead'in §20.8'de düzelttiği iki hücre bu turda yeniden ölçülmedi, çünkü QA kendi videolarını kullandı.

## 6. Final Verdict

* `QA Result: Rejected`
* **Blocking Issues:** F03-QA-D2-01. §16.11.1 (12) runtime'da başarısız, görsel rubric 92 / 100 < 93. Başka bir blocker yok: kalan 17 acceptance maddesi, F04 AC1–AC10 (AC9 automated sınıfta), F05 AC1 / AC12, F03 AC8 / AC11, yaşam döngüsü ve D1 regresyonu geçti.
* **Required Fixes:**
  1. F03-QA-D2-01 — bant görünürlüğünü scroll metrics değişimiyle senkron tut; widget testi + negatif çalıştırma; AX5 → sona kaydır → küçült yolunun runtime yakalaması.
* **Non-blocking Notes:**
  * **N1:** iOS app-switcher snapshot'ı sekans ortasında alınırsa sonucu yıldız reveal'inin ortasında (1★) gösteriyor (E-L1). Rest'e atlama `paused`'da yapılıyor ve iOS snapshot'ı ondan önceki son kareden alıyor. Dönüşteki canlı kare doğru. Opsiyonel iyileştirme.
  * **N2:** Debug build kare pacing'i: iPhone 16 satır 4 kaymasında üç tek kare (33–35 ms); reduced rest sonunda 125 ms; soğuk ilk kazanmada settle karesinde 85–120 ms (sonuç mount'u ya da yakalama). 16e ısınmış koşu temiz. Release pacing ölçülmedi.
  * **N3:** F00 bileşen sapmaları runtime'da görüldü ve puanlandı: `EN İYİ` ★ yüksekliği, basılı pill'in kararmaması (RESULT-F00-COMPONENT-ALIGN). Alt başlık render'dan hafif soluk.
  * **N4:** Home AX5'te taşıyor (A-2 home, D3 kapsamı), D2 bulgusu değil.
  * **N5:** Sınırlar: VoiceOver ve odak halkası bu host'ta runtime'da sürülemedi (automated sınıf); Android koşulmadı (ANDROID-CI-EVIDENCE); D2-07 runtime'da ulaşılamaz (widget testi); yalnız debug build.

## 7. Tech Lead Note

* **Kök neden alanı:** Frontend/Mobile Developer, `app/lib/play/widgets/result_view.dart` (bant durumu). Contract veya handoff değişikliği gerekmiyor; §16.11.1 (12) net.
* **Routing önerisi:** dar bir FE rework (F03-QA-D2-01), ardından Tech Lead checkpoint'i, ardından hedefli re-QA. Değişiklik `result_view.dart` ve testleriyle sınırlı kalırsa bu turun runtime kanıtı (E-J*, E-V*, E-R1, E-N*, E-B*, E-L*, E-RM*, E-D1) yeniden kullanılabilir. Re-QA yalnız metin ölçeği yollarını (E-T1…T5, üç cihaz) ve bir kazanma / retry smoke'unu yeniden yürütmeli; görsel rubric yeniden puanlanmalı.
* **Workflow notu:** Release scope yok; ürün kararı gerekmiyor.

## Sonraki Komut

```text
Run Tech Lead
```
