# F03 — puzzle-play-session: QA Raporu (F03-QA-D2R — D2 re-QA: ScrollBand düzeltmesi, metin ölçeği yolları, kazanma + retry smoke)

QA turu: 2026-09-29 · Görev: F03-QA-D2R · QA Stage: final · QA Scope: client-only · Release Scope: none · Visual Scope: motion-critical
Doğrulanan revizyon: HEAD `d0ae8f1` (F03-FE-D2R teslimi `77c33b9` + Tech Lead rework checkpoint belgeleri). `app/` ağacı `5298c81a9f36163a88a32eab5e0ef4dc4676b13d` — brief'teki evidence-reuse fingerprint'i ile birebir aynı. `git status --short` başlangıçta boş.
Derleme: `flutter build ios --simulator --debug` (Flutter 3.32.8), `App.framework/App` SHA-1 `d7a7c0af…` (Frontend'in F03.D2R-PARITY build'iyle aynı). Üç simulator'a bu build kuruldu.

Önceki rapor (F03-QA-D2, Rejected, 92 / 100) byte-for-byte arşivde: [history/f03-puzzle-play-session-2026-09-28/qa-at-d2-verdict.md](../../history/f03-puzzle-play-session-2026-09-28/qa-at-d2-verdict.md) (SHA-1 `52155e9b…`).
Bu turun kanıt klasörü [qa/d2r/](qa/d2r/):
* ekran görüntüleri `QA-*.png` (kayıpsız; piksel farkı ölçümleri bunlara dayanıyor, SHA-1 listesi `data/png-sha1.txt`);
* videolar `QV-*.mov` (`simctl io recordVideo`, yeniden kodlanmamış);
* kontak sayfaları `QS-*.jpg`;
* ölçüm kayıtları `data/band-measurements-qa.txt`, `data/timing-qa.txt` ve ham CSV'ler;
* QA'ya ait yeni araçlar `qa/d2r/src/` (`qa-band-d2r.swift`, `qa-diff-d2r.swift`, `qa-pill-rest.py`); zamanlama için F03-QA-D2'deki QA araçları `qa/d2/src/` yeniden kullanıldı.

> Bağımsızlık notu (§20.10 (3)): bant ölçümü Frontend'in `band-d2r.swift`'inden farklı bir yöntemle yapıldı — boş bir şeritte bant opaklığı tahmini, rozet lime piksel sayımı, geri butonu parlaklığı, içerik kayması ve tam ekran piksel farkı. Frontend'in yakalamaları ve Tech Lead ölçümleri kullanılmadı. Frontend'in `timing-d2.py`'si yalnız QA videosu üzerinde çapraz kontrol olarak koşuldu.

---

## 0. QA Execution Plan

* **Stage / Scope:** final · client-only · Release Scope none.
* **Modüller:**
  * `core`;
  * `client-ui` (sonuç ekranının metin ölçeği durumları, Retry / Next / geri çıkışları);
  * `visual-quality` (Visual Scope `motion-critical`; tam rubric yeniden puanlama);
  * `stateful-flow` (canlı OS metin boyutu değişimi — scroll metrics ile bant durumu senkronu, çıkış sonrası Play / Home durumu).
* **Regression Depth: full** (final stage). Değişen yüzey dar: `git diff 67d9ecb 77c33b9 -- app` yalnız `result_view.dart` (bant durumu) ve `result_view_test.dart`. Değişen yüzey üç cihazda runtime'da yeniden yürütüldü. Değişmeyen yüzeyler fingerprint kuralıyla yeniden kullanıldı; bir kazanma + retry smoke'u ile bağımsız olarak teyit edildi.
* **Evidence Reuse: allowed.** Gerekçe §5'te.
* **Canonical target:** iOS Simulator 18.6, debug build — iPhone 16 `D0011CE7` (birincil), 16e `6DBDFD97`, 16 Pro Max `02FDE776`. Required class: runtime + video.
* **Yöntem:**
  * `design/src/capture-d2.sh seed` ile L5 (`D0 D1`) kazanan hamleden bir önceye getirildi; Home DEVAM ET;
  * kazanan sütun hamlesi ve kaydırmalar simulator touch-path ile;
  * `simctl ui content_size` ile canlı metin boyutu (`large` ↔ `extra-extra-extra-large` ↔ `accessibility-extra-extra-extra-large`);
  * `simctl io screenshot` (PNG) ve `recordVideo` (değişken kare hızı).
  * Simulator ayarları sonunda geri alındı: üç cihazda `large`, Reduce Motion 0.
* **Bant ölçümü (`qa-band-d2r`):** bant, `#0B1234` (luma 19.8) zeminiyle `offset / 12` opaklıkta çiziliyor. QA her yakalamayı aynı metin boyutunda **hiç kaydırılmamış** bir kontrol ile karşılaştırıyor:
  * bant opaklığı, yalnız arka plan + bant çizilen boş bir şeritten (x 0.80–0.96 W, y 62 pt – bandın katı kısmı): `α = (L_kontrol − L) / (L_kontrol − 19.8)`;
  * `HARİKA` rozet metninin lime piksel sayısı (kontrolün yüzdesi);
  * geri chevron'unun maksimum parlaklığı;
  * içeriğin kontrol göre yukarı kayması (pt), buradan beklenen `α = kayma / 12`.
  * Ayrıca `qa-diff-d2r`: durum çubuğunun altında herhangi bir kanalda > 2 seviye farklı piksel sayısı ve sınır kutusu.
  * **Pozitif kontrol:** QA'nın kendi düzeltme-öncesi F03-QA-D2 yakalamaları α 1.006 ve rozet %0 okunuyor. **Negatif kontrol:** offset 0 ile sona kaydırılmış arasındaki fark 1 871 453 px.
* **Fail-fast checkpoint:** build + kurulum + fingerprint eşleşmesi + E-T5 (iPhone 16). Geçti.

## 1. Evidence Ledger

Hepsi EXECUTED THIS RUN, 2026-09-29 01:10–01:28, QA; aksi yazılmadıkça iPhone 16, revizyon `d0ae8f1` / `app/` `5298c81a…`, debug build `d7a7c0af…`. Ölçümlerin tamamı `qa/d2r/data/band-measurements-qa.txt` ve `timing-qa.txt` içinde.

| Evidence ID | Claim / Scenario | Class | Command / Action | Target | Result / Counts | Provenance / Fingerprint | Isolation |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E-A1 | Statik analiz + app suite | automated | `melos run analyze`; `cd app && flutter test` | host macOS | analyze SUCCESS (exit 0); app **512 passed**, 0 fail, 0 skip (exit 0) — F03-FE-D2R'nin 9 yeni bant testi dahil | 01:13, `d0ae8f1`, `5298c81a…` | widget testleri in-memory Drift + fake time |
| E-A2 | `integration_test` | repeatable integration | Frontend koşusu | iPhone 16 | 13 / 13, exit 0 | **REUSED** — F03.D2R-PARITY, `app/` fingerprint aynı | — |
| **E-T5** | **F03-QA-D2-01 yeniden testi:** AX5 → kazan → sona kaydır → canlı küçültme | runtime | L5 kazan (AX5) → sona kaydır → `xxxL`; ikinci koşu → `large` | 16 | Sonda α 1.001, kayma 158 pt. **xxxL:** α **0.000**, rozet **%100**, geri Δ 0.0; offset-0 kontrolüne göre **0 / 2 801 304 px** fark. **large:** α 0.000, rozet %100, **0 px** fark. Düzeltme öncesi (F03-QA-D2): α 1.006, rozet %0. | `QA-16-T2-*`, `QA-16-T5-shrunk-xxxL.png`, `QA-16-T5-shrunk-large.png`, kontroller `QA-16-C1/C2-*`, `QS-16-T5-before-after.jpg` | — |
| E-T5e | E-T5, iPhone 16e | runtime | aynı | 390×844 | Sonda α 1.001, kayma 156.3 pt. xxxL ve large: α 0.000, rozet %100, kontrole göre **0 / 2 751 840 px** (iki çift) | `QA-16e-T2*`, `QA-16e-T5-*`, `QA-16e-C1/C2-*`, `QS-16e-pm-T5.jpg` | — |
| E-T5p | E-T5, iPhone 16 Pro Max | runtime | aynı | 440×956 | Sonda α 1.001, kayma 171.7 pt. xxxL ve large: α 0.000, rozet %100, kontrole göre **0 / 3 548 160 px** (iki çift) | `QA-pm-T2*`, `QA-pm-T5-*`, `QA-pm-C1/C2-*`, `QS-16e-pm-T5.jpg` | — |
| E-T1 | AX5, offset 0'a iniş (üç cihaz) | runtime | AX5 iken kazan | 16, 16e, Pro Max | Geri + `HARİKA` üstte; başlık 1.3×'te iki satır; alt başlık kelime arasında 3 satır; bant yok (α 0) | `QA-16-T1-ax5-offset0.png`, `QA-16e-T1-T4-ax5-offset0.png`, `QA-pm-T1-ax5-offset0.png` | — |
| E-T2 | AX5, sona kaydırılmış (üç cihaz, cihaz başına iki kez) | runtime | yukarı kaydır | 16, 16e, Pro Max | Geri butonu sabit (parlaklık Δ 0.0), bant arkasında tam (α 1.001), "Tekrar oyna" home indicator'ın üstünde | `QA-*-T2-*.png`, `QA-*-T2b-*.png` | — |
| E-T3 | 1.3× sınırda (xxxL) kaydırma yok, üç cihaz | runtime | xxxL + 600 pt'lik sürükleme denemesi + piksel farkı | 16, 16e, Pro Max | Sürükleme öncesi / sonrası: 16 `0 / 2 801 304`, 16e `0 / 2 751 840`, Pro Max `0 / 3 548 160` px | `QA-*-T3-cap-xxxL-*.png` | — |
| E-T4 | 16e AX5 | runtime | canlı AX5 | 16e | Kelime arası kırılım, geri sabit, rozet görünür | `QA-16e-T1-T4-ax5-offset0.png` | — |
| E-M1 | Misuse: metin boyutu offset 0'da **büyütülünce** bant yok (üç cihaz) | runtime | xxxL / large (offset 0) → AX5 | 16, 16e, Pro Max | α 0.000, rozet %100, kayma 0 | `QA-*-M1-up-at-offset0-ax5.png` | — |
| E-M2 | Kısmi kaydırma → orantılı bant; geri kaydırınca temizleniyor | runtime | AX5'te birkaç pt'lik sürükleme; sonra geri | 16 | **6.3 pt → α 0.514** (beklenen 0.528). 18.3 pt → α 1.001 (12 pt üstü, beklenen 1). Geri yukarı → α 0.000, rozet %100. Drag videosunda 1.3 pt → α 0.092 (beklenen 0.108). | `QA-16-M2c-partial-small-ax5.png`, `QA-16-M2-partial-scroll-ax5.png`, `QA-16-M2b-scrolled-back-top-ax5.png`, `data/M3b-frames.csv` | — |
| E-M3 | Aktif sürükleme sırasında küçültme (parmak basılıyken) | runtime-video | yavaş touch-path (≈ 6 s) + arka planda zamanlanmış `content_size xxxL` | 16 | İçerik sona ulaşıyor (α ≈ 1). Parmak hâlâ basılıyken küçültme: 5.4383 s α 1.005 → **5.4533 s α −0.007, rozet 1921** (tek kare, 15 ms). Sonuç kontrole göre 0 px. | `QV-16-M3b-drag-shrink.mov`, `data/M3b-frames.csv`, `QA-16-M3b-after-drag-shrink-xxxL.png` | — |
| E-M3b | Fling sonrası küçültme | runtime-video | hızlı fling + zamanlanmış xxxL | 16 | Fling, 158 pt'lik extent'te küçültmeden önce durdu; **gerçek bir fling-ortası küçültme yakalanamadı**. Rest'te küçültme: 3.8300 → 3.8467 s'de α 1.027 → −0.015 (tek kare). Kontrole göre 0 px. | `QV-16-M3-fling-shrink.mov`, `data/M3-frames.csv`, `QA-16-M3-after-fling-shrink-xxxL.png` | fling-ortası ulaşılamadı (E-M3 daha sert durumu kapsıyor) |
| E-M4 | Metin boyutu değişiminden sonra sonuçtan çıkış: Retry / geri / Next | runtime | (a) AX5 → sona kaydır → xxxL → "Tekrar oyna"; (b) → `large` → geri butonu; (c) → xxxL → "Sonraki bölüm" | 16 | Çıkıştan önce α 0, kontrole göre 0 px (c) / yalnız home indicator farkı (b, not). (a) Play L5 `HAMLE 0`, undo devre dışı, 3 nokta. (b) Home "Seviye 6", 5 / 30. (c) Play `SEVİYE 06`, `HAMLE 0`. Bant kalıntısı yok. | `QA-16-M4-retry-after-size-change-xxxL.png`, `QA-16-M4b-*.png`, `QA-16-M4c-*.png` | (b) çiftindeki 6 263 px farkın tamamı 127…266 × 839…844 pt'de: iOS home indicator (sistem katmanı) |
| E-S1 | Smoke: kazanma + retry, tam hareket, video — koşu 1 | runtime-video | seed L5 → DEVAM ET → sütun 1 aşağı; rest'te "Tekrar oyna" | 16, `large` | QA T0 = 2.8063 s (dim fit, 7 kare, saçılım 2.8 ms). Satır hücrelerinde **+602'ye kadar**, ilk hareket **+617**. T0 … +600 arasında board dışında lime **0 px**. İlk sonuç pikseli (başlık bölgesi) **+719**. Pill %99 **+935**, son değişim (+935, +950]. **Retry:** board son değerinde **+320** (≤ 400). Retry sonrası `HAMLE 0`. Rest'teki sonuç, kontrole göre 0 px. | `QV-16-S1-win-retry-L5.mov`, `QA-16-S1-result-rest.png`, `QA-16-S1-after-retry.png`, `data/timing-qa.txt` | debug build |
| E-S2 | Smoke: kazanma — koşu 2 | runtime-video | aynı, yalnız kazanma | 16, `large` | T0 = 2.8641 s (saçılım 2.8). Hücrelerde +601, ilk hareket +619. Board dışı lime 0. İlk sonuç pikseli **+716**. Pill %99 **+938**, son değişim (+949, +974] — arada 25 ms'lik yakalama boşluğu. | `QV-16-S2-win-L5.mov`, `data/timing-qa.txt` | debug build |
| E-X1 | Çapraz kontrol: Frontend'in `timing-d2.py`'si QA'nın S2 videosunda | runtime-video | `VIDEO_D2=… timing-d2.py win … 2` | QA videosu | T0 2.8664 (QA 2.8641), C2 599 / 617, ilk sonuç pikseli 714, `HAMLE` 750, pill rest **972**, yıldızlar **1287**. Pill değeri E-S2'nin (+949, +974] penceresinin üst ucu; §5'teki yorum. | QA videosu | Frontend aracı |
| E-J*, E-V*, E-R1, E-N1/N2, E-B1…B3, E-L1/L2, E-M1/M2 (D2), E-RM1/RM2, E-D1, E-P1 | F03-QA-D2 runtime yolculukları: satır 0 / 2 / 4, C-11, 10 F04 varyantı, Retry A, Next, terminal, geri / sistem geri, arka plan / kill, rest öncesi input, tutorial, Reduce Motion, D1 regresyonu, render parity | runtime / runtime-video | F03-QA-D2 | 16, 16e, Pro Max | Hepsi PASS (arşivlenen rapor §1) | **REUSED** — F03-QA-D2, 2026-09-28, `app/` `f5641d2f…`; geçerlilik §5 | — |

## 2. Acceptance & Critical Journey Coverage

| AC / Journey | Expected | Evidence IDs | Result |
| --- | --- | --- | --- |
| §16.11.1 (12) Metin ölçeği — **F03-QA-D2-01** | Sınıra kadar kaydırma yok; AX5 kaydırma, geri sabit; bant yalnız kaydırılmışken ve kaydırmayla orantılı; offset 0'a iniş; canlı küçültmede bant temizleniyor | E-T1…E-T5, E-T5e, E-T5p, E-M1…E-M3 | **PASS** — üç cihaz, iki hedef boyut, piksel düzeyinde kontrolle aynı |
| §16.11.1 (1) T0 … 599 yalnız board | Satır doldurma, bloom, dim; sonuç pikseli yok | E-S1, E-S2, E-X1; REUSED E-J* | PASS (board dışı lime 0 px) |
| §16.11.1 (3) Kayma 600–840 | Satır +600'e kadar hücrelerinde | E-S1 (+602 / +617), E-S2 (+601 / +619), E-X1 (599 / 617) | PASS |
| §16.11.1 (4)–(5) Chrome +720'de 0; rest ≤ 940 (± bir kare); yıldızlar ≤ 1300 | — | E-S1 (pill (+935, +950]), E-S2 (+938 %99; (+949, +974]), E-X1 (`HAMLE` 750, yıldızlar 1287) | PASS (± bir yakalama karesi; §20.10 (1) ile tutarlı) |
| §16.11.1 (13) Retry ≤ 400, `HAMLE 0`, undo devre dışı, 3 nokta | — | E-S1 (+320), E-M4 (a) | PASS |
| §16.11.1 (14) Next / geri; Close yok | — | E-M4 (b), (c); REUSED E-N*, E-B* | PASS |
| §16.11.1 (2), (6)–(11), (15)–(18) | C-11, reduced yol, rest öncesi input, 1.0× yerleşim, varyantlar, F04 AC7 içeriği, tek parlama, erişilebilirlik, yaşam döngüsü, eski öğe yok, 16e pacing | REUSED (F03-QA-D2 E-J2, E-RM*, E-M1, E-V*, E-P1, E-L*, E-J3b); E-S1 rest sonucu kontrole 0 px | PASS (yeniden kullanım, §5) |
| F04 AC1–AC10 | Sonuç içeriği, yıldız sınırları, en iyi | REUSED E-V1…V9, E-R1, E-N1; E-A1 (`star_rating_test`, AC9) | PASS (AC9 automated sınıfta) |
| F05 AC1 / AC12 | Unlock Next / geri ile; 30 → terminal | E-M4 (b) Home "Seviye 6", (c) L6; REUSED E-N2 | PASS |
| F03 AC8 / AC11 | Kazanma → kilit + sekans + sonuç; geçici kelime kazandırmaz | E-S1, E-S2; E-A1; REUSED E-J* | PASS |
| Misuse: offset 0'da metin büyütme | Bant yok | E-M1 (üç cihaz) | PASS |
| Misuse: kısmi kaydırma / geri kaydırma | Orantılı bant; offset 0'da temiz | E-M2 | PASS |
| Misuse: sürükleme / fling sırasında küçültme | Bant bir karede temizleniyor | E-M3 (sürükleme ortası); E-M3b (fling sonrası; fling ortası ulaşılamadı) | PASS |
| Misuse: metin değişiminden sonra çıkış | Play / Home normal | E-M4 | PASS |

## Client & UI Compliance

| Kontrol | Evidence IDs | Result |
| --- | --- | --- |
| Screen goal ve kritik yolculuk (çöz → sonuç → Next / Retry / geri) | E-S1, E-M4; REUSED E-J*, E-N*, E-B* | PASS |
| Route / geri / dismiss: sonuç `/play`'in state'i; geri → `/`; Next → N+1 | E-M4 (b), (c) | PASS |
| Metin ölçeği state'leri ve ScrollBand (offset 0, kısmi, son, canlı küçültme / büyütme) | E-T1…T5, E-M1…M3 | PASS |
| 10 varyant, devre dışı bağlantı, rest öncesi kilit, çift dokunuş koruması | REUSED E-V*, E-M1 (D2), E-R1, E-N2 | PASS |
| Handoff CTA hiyerarşisi (§16.8) — 1.0× ve AX5 | E-S1, E-T1, E-T2; REUSED E-P1 | PASS; basılı pill yalnız ölçekleniyor (NTLC-D2-2, bilinen) |

## Stateful Flow & Integration

| Boundary / Transition | Actor / Start State | Expected | Evidence IDs | Result |
| --- | --- | --- | --- | --- |
| OS metin boyutu küçülmesi, sonuç kaydırılmış (içerik extent'i küçülür, offset dinleyicisiz düzeltilir) | Oyuncu, AX5, offset = son | Bant durumu yeni offset'e (0) iner; rozet / geri temiz | E-T5, E-T5e, E-T5p | PASS |
| Aynı geçiş, parmak basılıyken | Aktif sürükleme | Tek karede temizleniyor; sürükleme bitince tutarlı | E-M3 | PASS |
| OS metin boyutu büyümesi, offset 0 | Oyuncu, xxxL / large | Bant 0 kalır | E-M1 | PASS |
| Kısmi kaydırma ↔ bant | Oyuncu, AX5 | Bant = clamp(offset / 12) | E-M2 | PASS |
| Metin değişimi → çıkış (Retry / geri / Next) | Sonuç, küçültülmüş | Hedef ekranda kalıntı yok; kalıcılık ve unlock doğru | E-M4 | PASS |
| Listener yaşam döngüsü | `ResultView` | `NotificationListener` widget ağacına bağlı; ayrı subscription yok, dispose gerektirmiyor. `_onScroll` `hasClients` korumalı. | kaynak inceleme (yardımcı) + E-A1 | PASS (yardımcı) |
| `won` kalıcılığı, yaşam döngüsü ortası, retry state'i | — | F03-QA-D2 ile aynı | REUSED E-B*, E-L*, E-R1 | PASS |

## Visual Quality Verdict

| Rubric Dimension | Score / 10 | Runtime Evidence | Notes |
| --- | --- | --- | --- |
| Experience Fit | 10 | E-S1, E-S2; REUSED E-J*, E-R1 | Değişmedi. Kazanan satır ödülün kahramanı; board'dan sonuca kayış ve retry'da raya dönüş sakin, bulmacaya uygun bir ödül anı. |
| Visual Hierarchy | 10 | E-S1, E-T1; REUSED E-V* | Her varyantta tek odak ve tek birincil eylem. Rozet satırı ayrılmış. AX5'te de rozet → başlık → cevap → yıldız → stat → CTA sırası korunuyor. |
| Layout, Rhythm and Responsiveness | 10 | E-T1…E-T5p, E-M1…M3, E-S1 | Önceki 9'un tek gerekçesi F03-QA-D2-01'di. Artık: üç cihazda 1.3× sınırında kaydırma yok (0 px), AX5'te düzgün kaydırma, ve canlı metin boyutu değişiminden sonra ekran hiç kaydırılmamış durumla **piksel düzeyinde aynı**. |
| Typography and Content Craft | 9 | E-T1, E-S1; REUSED E-P1 | Authored iki satır başlık, harfle yazılmış sayılar, doğru Türkçe İ. AX5'te pill etiketi iki satıra kırılıyor (kabul edilebilir). Alt başlık render'dan hafif soluk. |
| Color, Surface and Asset System | 10 | E-S1; REUSED E-V*, E-P1 | Tek parlama kuralı; lime cevap satırı + radial, cam stat kartı, çizilmiş ikonlar. Bant zemini arka planla dikişsiz. |
| Interaction, State and Feedback | 9 | E-M2, E-M4; REUSED E-M1 (D2), E-R1, E-V7 | Bant kaydırmayla orantılı ve geri alınabilir; çıkışlar temiz. Basılı pill yalnız ölçekleniyor (NTLC-D2-2). Geç rozet fade'i yalnız widget testinde. |
| Motion and Sensory Quality | 9 | E-S1, E-S2, E-X1, E-M3; REUSED E-J*, E-RM* | Zamanlama iki koşuda D2 ile ms düzeyinde aynı; bant geçişi tek karede. Debug build'de T0 öncesi / statik bekleme içinde 33–52 ms'lik tekil kare boşlukları; pill rest'i ± bir kare. Release pacing ölçülmedi. Ses / haptik F11. |
| Originality and Product Identity | 9 | E-S1; REUSED E-J1, E-R1 | Satırın board → sonuç → ray yolculuğu ürüne özgü bir imza; Loop Glass dili tutarlı. |
| Accessibility and Inclusive Quality | 9 | E-T1…E-T5p, E-M1…M3; REUSED E-RM*; E-A1 | F03-QA-D2-01 giderildi. Rozet ve geri butonu her metin boyutu yolunda tam görünür. 1.3× sınırı, AX5 kaydırma, reduced motion ve ≥ 44 pt hedefler iyi. VoiceOver ve odak halkası hâlâ yalnız automated sınıfta (host sınırı). |
| Implementation Fidelity and Polish | 9 | E-S1, E-T*; REUSED E-P1, E-V10 | Render ile yakın parity; rework yalnız bant durumunu değiştirdi, sonuç render'ı 1.0×'te kontrole 0 px. Bilinen sapmalar: `EN İYİ` ★ yüksekliği, stat etiketleri (RESULT-F00-COMPONENT-ALIGN). |

Final Score: 94 / 100

Lowest Dimension: Typography and Content Craft — 9 / 10 (eşit: Interaction, Motion, Originality, Accessibility, Implementation Fidelity)

Fail Conditions: None (premium-ui-rubric fail listesinden hiçbiri)

Runtime Evidence Complete: Yes (motion video ile; VoiceOver ve odak halkası belirtilen automated sınıfta; Android kapsam dışı sınır)

Result: PASS (94 ≥ 93, her boyut ≥ 9, fail condition yok; §16.11.1 (12) üç cihazda runtime'da geçti)

## 5. Regression & Evidence Reuse

* **Etkilenen yüzey:** `result_view.dart` bant durumu (`_onScroll` artık `position.pixels` okuyor, `hasClients` korumalı) ve depth-0 `ScrollMetricsNotification` dinleyicisi. `ScrollBand`, zaman çizelgesi, yerleşim, metin, yaşam döngüsü ve kalıcılık değişmedi. Diff'i QA kendisi okudu (`git diff 67d9ecb 77c33b9 -- app`: iki dosya, +99 / −10).
* **Yeniden kullanım gerekçesi (F03-QA-D2 runtime kanıtı):**
  * `ClampingScrollPhysics` altında `position.pixels` ile önceki `offset` her zaman aynı değerdir;
  * yeni dinleyici yalnız `_onScroll`'u çağırıyor; bu da `_band` yalnız değer değişince `setState` yapıyor;
  * kaydırılmayan bir sonuçta (1.0× ve 1.3× sınırı, bütün varyantlar) `_band` 0'da kalır, dolayısıyla render aynıdır;
  * kaydırma çoğaltılmadı; kazanma sekansı, geçiş, retry / Next / geri, yaşam döngüsü ve Reduce Motion yolları `result_view.dart`'ın bant state'ine dokunmuyor.
  * **Bağımsız teyit:** E-S1 / E-S2'de zamanlama D2 ile aynı (hücrelerde +599…602, ilk hareket +617…619, ilk sonuç pikseli +714…719; D2: +599 / +616…619 / +717). Rest'teki sonuç, kaydırılmamış kontrolle 0 px farklı.
  * Bu yüzden E-J*, E-V*, E-R1, E-N*, E-B*, E-L*, E-M1/M2 (D2), E-RM*, E-D1, E-P1 **REUSED — fingerprint geçerli** (değişen yüzey claim'lerini etkilemiyor).
* **REUSED — fingerprint geçerli:** E-A2 (`integration_test` 13 / 13, `app/` `5298c81a…`).
* **INVALIDATED:** F03-QA-D2 E-T5 (F03-QA-D2-01) — değişen yüzey; bu turda üç cihazda yeniden yürütüldü. E-T1…E-T4 aynı yüzeyde olduğu için yeniden kullanılmadı, yeniden yürütüldü.
* **Bağımsız QA probe'ları:**
  * yeni bant ölçüm aracı; pozitif kontrol (D2 yakalamaları α 1.006) ve negatif kontrol (offset 0 ↔ son: 1.87 M px) ile doğrulandı;
  * sürükleme ortası küçültme videosu (E-M3) — Frontend'in kapsamında yoktu.
* **Pill rest yorumu (E-S2 / E-X1 +972):** pill bölgesi luma'sı +938'de son değerinin %99'unda (214.2 / 215.2). Kalan 0.9 luma'lık adım 25 ms'lik bir yakalama boşluğunun (+949 → +974) arkasında. Aynı dönüşüm S1'de (+935, +950] içinde bitiyor. D2'de QA 947–954, Frontend 947 / 964 ölçmüştü. Zaman çizelgesi kodu 67d9ecb'den beri değişmedi. Bu nedenle §20.10 (1) ile aynı sonuç: yakalama jitter'ı, bir defect değil.
* **Frontend kanıtıyla fark:** çelişen ölçüm yok. Frontend'in "0.000 % differ" sonucu QA'nın farklı yöntemiyle de (tam ekran 0 px) yeniden üretildi.

## 6. Final Verdict

* `QA Result: Approved with Notes`
* **Blocking Issues:** None. F03-QA-D2-01 runtime'da üç cihazda kapandı. §16.11.1'in 18 maddesi, F04 AC1–AC10 (AC9 automated sınıfta), F05 AC1 / AC12 ve F03 AC8 / AC11 geçti (değişen yüzey yeniden yürütüldü, değişmeyen yüzey fingerprint kuralıyla yeniden kullanıldı). Görsel rubric 94 / 100, her boyut ≥ 9, fail condition yok.
* **Required Fixes:** None.
* **Non-blocking Notes:**
  * **N1:** RESULT-APP-SWITCHER-SNAPSHOT (F03-QA-D2 N1) açık kalıyor. Sekans ortasında alınan iOS app-switcher snapshot'ı 1★ ara durumu gösteriyor; dönüşteki canlı kare doğru. Bu turda yeniden yürütülmedi (kod değişmedi).
  * **N2:** Debug build kare pacing'i: T0 çevresinde ve statik bekleme içinde tekil 33–52 ms boşluklar; pill rest'i ± bir yakalama karesi. Release pacing ölçülmedi.
  * **N3:** F00 bileşen sapmaları (`EN İYİ` ★ yüksekliği, basılı pill'in kararmaması — RESULT-F00-COMPONENT-ALIGN) ve render'dan hafif soluk alt başlık; bilinen, puanlandı.
  * **N4:** Fling ortasında küçültme ulaşılamadı (158–172 pt'lik extent'te fling küçültmeden önce duruyor). Daha sert olan sürükleme ortası durum (E-M3) geçti.
  * **N5:** Home AX5'te taşıyor ("BOTTOM OVERFLOWED BY 10 PIXELS", debug) — A-2 home, D3 kapsamı; D2 bulgusu değil.
  * **N6:** Sınırlar: VoiceOver ve odak halkası bu host'ta runtime'da sürülemedi (automated sınıf); Android koşulmadı (ANDROID-CI-EVIDENCE); D2-07 runtime'da ulaşılamaz (widget testi); yalnız debug build.
  * **N7:** Kanıt klasörü `qa/d2r/` ≈ 95 MB. Bunun ≈ 73 MB'ı kayıpsız PNG; piksel farkı iddiaları kayıpsız yakalamaya dayandığı için tutuldu (§20.10'daki Frontend emsali). Tech Lead isterse ölçüm çiftleri dışındakiler JPEG'e çevrilebilir.

## 7. Tech Lead Note

* **Kök neden alanı:** F03-QA-D2-01'in sahibi Frontend/Mobile Developer'dı (`result_view.dart`); rework runtime'da doğrulandı. Yeni finding yok.
* **Routing / depth:** Değişiklik gerekmiyor. F03.D2R-VISUAL-QA PASS; F03.D2-VISUAL-QA bu kayıtla superseded olarak işaretlendi (D1R emsali, §19.12 (4)). Visual Quality Gate'i `Passed`'e çekmek ve D2'yi kapatmak Tech Lead kararı.
* **Workflow notu:** Release scope yok; ürün kararı gerekmiyor. Açık takipler değişmedi: RESULT-APP-SWITCHER-SNAPSHOT, RESULT-F00-COMPONENT-ALIGN, F03-MULTITOUCH-FIRST-POINTER, MOVESCARD-COUNTER-LINE-HEIGHT, ANDROID-CI-EVIDENCE. Home AX5 taşması D3'e.

## Sonraki Komut

```text
Run Tech Lead
```
