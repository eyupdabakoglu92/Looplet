# F00 — design-foundation: QA Raporu (F00-QA-VISUAL)

> Bağımsız final-stage görsel QA. Test edilen revizyon: commit `78b22e3` içeriği (app ağacı `d9709ad858e4eda876f00e664281fa208409f6ca`; HEAD `a499e5d` yalnızca Tech Lead belge commit'i, app ağacı değişmedi). Hedef: iOS Simulator 18.6 — iPhone 16 (393×852, birincil), 16e (390×844), 16 Pro Max (440×956). Tarih: 2026-09-21. Ham kanıt: [qa/README.md](qa/README.md).

---

## 0. QA Execution Plan

* **Stage / Scope:** final / client-only (Release Scope none).
* **Modüller ve tetikleyiciler:** `core` (her tur); `client-ui` (istemci bileşen katmanı); `visual-quality` (Visual Scope `design-system`); `stateful-flow` (preflight anahtar-kelime tetikleyicisi; katman kalıcılık/yaşam döngüsü içermediğinden dar kapsamlı olumsuz kontrol).
* **Regression Depth: full** — final gate. Fingerprint geçerli; bu turda hiçbir Frontend/TL sonucu yeniden kullanılmadı, hepsi yeniden çalıştırıldı (ucuz ve bağımsızlık daha değerli).
* **Canonical target / runtime sınıfı:** simulator runtime (debug build, gerçek Flutter motoru). Kapı çıktısı `Ready for QA` teslim sahibinin görselleriyle değil, QA'nın kendi karelerine dayanır.
* **Bağımsız kritik probe:** depo dışında bir QA probe hedefi (`qa/src/qa_probe_main.dart`) teslim edilen katmanı paket olarak içe aktarıp gerçek motorda semantik ağacı, kutu boyutlarını, taşmaları ve basılı-tutma ölçeğini üretti.
* **Fail-fast:** Delivery Review Accepted, gate Ready for QA, preflight PASS, gerekli artefaktlar mevcut → devam edildi.

---

## 1. Evidence Ledger

Hepsi `EXECUTED THIS RUN`, fingerprint: app ağacı `d9709ad…` (aksi belirtilmedikçe).

| Evidence ID | Claim / Scenario | Class | Command / Action | Target | Result / Counts | Isolation |
| --- | --- | --- | --- | --- | --- | --- |
| E1 | Kapı ve fingerprint | static | `node ai-system/tools/qa-preflight.mjs ai-system`; `git rev-parse HEAD:app` | repo | preflight PASS; app ağacı brief'tekiyle aynı; çalışma ağacı temiz | — |
| E2 | Gönderilen yüzey değişmedi | static | `git diff --stat 9a72481 HEAD -- . ':!ai-system' ':!app/lib/design' ':!app/test/design' ':!app/assets/fonts'` | repo | yalnız `app/lib/main_gallery.dart` (+54) ve `app/pubspec.yaml` (+13, bağımlılık satırı yok); lockfile/config aynı; `lib/design` dışında tek içe aktaran `main_gallery.dart` | — |
| E3 | Analiz, format, tüm testler | automated | `melos run analyze`; `melos run format:check`; `melos run test` | workspace | üçü çıkış 0; format 170 dosya 0 değişen; testler 17+22+32+23+20+83 = 197 paket, 305 uygulama, 0 başarısız | Ahem yazı tipi: yalnız galeri yerleşim testleri gerçek fontu yükler |
| E4 | F03 cihaz paketi (birlikte-var-olma) | runtime | `flutter test integration_test -d D0011CE7…` | iPhone 16, iOS 18.6 | `+13 All tests passed`, çıkış 0 | — |
| E5 | Galeri sıfırdan derlenir ve çalışır | build + runtime | `flutter build ios --simulator --debug -t lib/main_gallery.dart`; `capture-gallery.sh` ×3 | 3 simülatör | derleme çıkış 0; 15 kare (5 ofset × 3 cihaz), hepsi geçerli boyutta | debug (JIT) build |
| E6 | Renk ve yüzey ölçümü | runtime (piksel) | BMP okuma + CIEDE2000 (`qa/src/bmp.py`) | iPhone 16 karesi | 10 renk kutusu belirteçle ΔE 0,00; CTA ve krem karo degradesi ΔE ≤ 1,2; parlama (glow) vs nötr gölge piksel olarak ayırt edilir | ekran görüntüsü sRGB |
| E6b | Seçili kaynakla yan yana (S-91) QA karelerinden | runtime + karşılaştırma | `design/src/parity-board.py` QA'nın kendi `g_16_*` kareleriyle, Chrome DPR 1 | iPhone 16 | üretilen tile ve kontrol panoları Frontend'in `parity-runtime-1/2` panolarıyla **bayt-bayt aynı** (md5) ⇒ kareler tekrar üretilebilir; QA panoları inceledi: tile durumları, pill/badge/hamle/yıldız, ikon çizimi S-91 ile uyumlu (C-03 karesi kilit/kar tanesi ikonu için) | aynı aracı kullandığı için bağımsız bir karşılaştırma yöntemi değil, tekrar üretilebilirlik kanıtı |
| E7 | Çalışma zamanı geometri | runtime (probe) | RenderBox boyutları (`qa/box-sizes-*.txt`) | iPhone 16 | CTA 340,3×69,7 pt (spec 63,5×s = 69,7); kenar boşluğu 26,3 (24×s); MovesCard 65,9×69,2; StatCard 340,3×81,2; UndoPill 108,1×54,9; GlassIconButton 44×44; TextLink yüksekliği 44; LoopNode 41,7 / halka 83,4 — tümü spec'ten ≤ 0,1 pt (ui-design toleransı ±2 pt) | probe = paket olarak içe aktarım |
| E8 | Çalışma zamanı semantik ağaç | runtime (probe) | `probe_mode=gallery`; 92 düğüm | iPhone 16 | dokunma hedefleri ≥ 44 pt; **çift düğüm/etiket bulguları QA-02** | — |
| E9 | Kenar durumlar (1×) | runtime (probe) | `probe_mode=edge` | iPhone 16 | 2 basamaklı düğümler, 3 haneli hamle/istatistik, yıldız 0–3, geri-al 0–3, Türkçe büyük harfler 3 boyutta: taşma 0; uzun CTA 2 satıra sarar; **uzun `OutlinePill` etiketi kenarlığa değer (QA-04)** | — |
| E10 | Dynamic Type süpürmesi | runtime (probe) | `xcrun simctl ui … content_size` × 9 boyut × (galeri, kenar) | iPhone 16 | ≤ 1,24×: taşma 0; 1,35×: `MovesCard` 3,5 px; ≥ 1,65×: `MovesCard` 38→163 px, `StatCard` 13→124 px; **QA-01** (`qa/dynamic-type-sweep.txt`) | ayar sonunda `large`'a geri alındı |
| E11 | Dynamic Type görüntüleri | runtime | 1,65× ve 3,1× kareler | iPhone 16 | 1,65×: HAMLE etiketi "HAML/E" kırılır ve karttan taşar, istatistik etiketleri kartın altına düşer; 3,1×: probe'un uzun etiketli CTA'sı ve `OutlinePill`'i kırpılır, düğüm rakamları kesilir, galeri wordmark'ı "Loo/plet" kırılır | — |
| E12 | Reduce Motion (gerçek OS ayarı) | runtime (probe) | `defaults write …ReduceMotionEnabled`; sentetik pointer-down basılı tutma; pill genişliği ölçümü | iPhone 16 | basılı: KAPALI → 0,978×, AÇIK → 1,000× (motor `reduceMotion=true`); ayar geri alındı | pointer motor içinden gönderildi (platform dokunuşu atlandı) |
| E13 | Gönderilen uygulama soğuk açılış | build + runtime | `flutter build ios --simulator --debug`; `simctl launch` | iPhone 16 | derleme çıkış 0; eski Ana ekran (sistem yazı tipi, amber) çizilir, istisna günlüğü yok | — |
| E14 | `stateful-flow` olumsuz kontrol | static | `grep` (kalıcılık, yönlendirme, gözlemci, zamanlayıcı, stream, IO) `lib/design` | repo | eşleşme 0; yalnız iki StatefulWidget (`_Pressable`, galeri) ve `ScrollController.dispose()` | source kontrolü çalışma zamanı yerine geçmez; burada beklenen sonuç "yok" |

---

## 2. Acceptance & Critical Journey Coverage

F00 taşıyıcı özelliktir: ürün AC'si yoktur (`prd.md`). Kabul temeli: `architecture.md` §7, `ui-design.md`, rubrik.

| Senaryo (QA brief) | Beklenen | Evidence | Sonuç |
| --- | --- | --- | --- |
| 1. Galeri soğuk açılış, 3 cihaz | gerçek fontlar, taşma yok, tüm bileşen/durumlar çizili | E5, E6, E7 | **PASS** (varsayılan boyut) |
| 2. Seçili kaynakla uyum | renk, degrade, yarıçap, glow, tip, ikon, boşluk | E6, E6b, E7 | **PASS** (ΔE 0/≤1,2; geometri ≤ 0,1 pt); tam ekran kompozisyon doğrulanamaz (tüketici yok) |
| 3. Türkçe, tabular, ağırlık ekseni | İ I Ş Ğ Ç Ö Ü, ı ş ğ ç ö ü, `turkishUpper`, iki font 400–700 | E5 (2560 karesi), E11 | **PASS** |
| 4. Erişilebilirlik | hedef ≥ 44 pt; semantik; Reduce Motion; metin boyutu; kontrast | E7, E8, E10–E12 | **FAIL** — hedefler ve Reduce Motion PASS; metin boyutu QA-01, semantik QA-02, odak QA-03 |
| 5. Birlikte-var-olma | gönderilen uygulama açılır ve aynı görünür; F03 suite; kapılar | E2–E4, E13 | **PASS** |
| 6. `stateful-flow` olumsuz | kalıcılık/yaşam döngüsü/yönlendirme yok; geçici durum temiz | E14 | **PASS** |
| Yanlış/uç parametre | 2 basamaklı düğüm, uzun etiket, aralıklar | E9, E10 | **Kısmen** — uç durumlar 1×'te sağlam; uzun etiket ve büyük yazı bulguları QA-01/QA-04 |

## Client & UI Compliance

| Kontrol | Beklenen | Evidence | Sonuç |
| --- | --- | --- | --- |
| Durumlar ayırt edilebilir, yalnız renkle değil | aktif satır kenarlığı, kazanan glow, kilit ikonu, kar tanesi + kesikli halka, soluk kutu, hayalet yuva | E5, E6 | PASS |
| Birincil/ikincil hiyerarşi ve tek-glow kuralı | lime CTA glow'lu / nötr gölgeli; outline ve metin bağlantısı zayıf | E6 | PASS |
| Disabled | %45 opaklık + "· yakında" son eki | E5, E8 | PASS (semantikte etiket iki kez, QA-02) |
| Basılı durum | 0,98 ölçek; Reduce Motion'da sabit | E12 | PASS |
| **Odak durumu** (ui-design §8: 2 px periwinkle halka) | bileşen odak halkası | kod: `lib/design`'da odak işlemi yok | **FAIL — QA-03** |
| Yükleme/hata/boş | Phase D yüzeylerinde | — | kapsam dışı (ui-design §8) |
| Ekran okuyucu | kontrol başına bir düğüm, bir kez okunur (§13) | E8 | **FAIL — QA-02** |
| Büyük yazı | kırpma yok (≥ accessibility-medium, platform.md §14) | E10, E11 | **FAIL — QA-01** |

## Stateful Flow & Integration

| Sınır / Geçiş | Başlangıç durumu | Beklenen | Evidence | Sonuç |
| --- | --- | --- | --- | --- |
| Kalıcılık / hydrate / yönlendirme / yaşam döngüsü | katman | eklenmemiş | E14, E2 | PASS |
| Geçici durum sıfırlanır | `_Pressable._down`, galeri kaydırması | pointer iptal/bırakma ile temizlenir; `ScrollController` dispose edilir | E12, E14 | PASS |
| Gönderilen uygulama başlangıcı | soğuk açılış (yalnız `pubspec.yaml` font tanımı değişti) | önceki gibi açılır | E4, E13 | PASS |

## Visual Quality Verdict

Puanlar, teslim edilen **tasarım sistemi katmanını** (galeri + probe) gerçek motorda değerlendirir; ekran kompozisyonları henüz yoktur (Phase D).

| Rubric Dimension | Score / 10 | Runtime Evidence | Notes |
| --- | --- | --- | --- |
| Experience Fit | 9 | E5, E6 | Loop Glass (lime = çözüm, periwinkle = konum, krem karo) premium bir mobil kelime oyununa uyuyor; yalnız galeri. |
| Visual Hierarchy | 9 | E5, E6 | CTA baskın, outline/bağlantı geri planda; tek-glow ölçümle doğrulandı. |
| Layout, Rhythm and Responsiveness | 7 | E5, E7, E10, E11 | Varsayılan boyutta üç cihazda kusursuz ve spec'e ≤ 0,1 pt; ama platform tabanı accessibility-medium'da `MovesCard`/`StatCard` taşıyor, 3,1×'te sabit yükseklikli pill/düğüm kırpılıyor (QA-01). |
| Typography and Content Craft | 8 | E5, E9, E11 | Gerçek fontlar, Türkçe ve ağırlık ekseni doğru; ancak sarılan büyük-harf rollerinde satır aralığı 1,0 (satırlar birbirine değer) ve display'de ≥ 1,65×'te yetim "." (QA-04). |
| Color, Surface and Asset System | 9 | E6, E9 | Belirteç ΔE 0, degrade ≤ 1,2, glow/nötr gölge ölçüldü; tek ikon dili; donmuş taş halkası düzeltilmiş. |
| Interaction, State and Feedback | 7 | E6, E12 | Basılı, disabled, harcanmış, kilit/donmuş net; **odak durumu uygulanmamış ve beyan edilmemiş (QA-03)**; yükleme/hata/boş Phase D. |
| Motion and Sensory Quality | 8 | E12 | Kapsamda yalnız basılı geri bildirimi var (0,98, 90 ms), Reduce Motion'a saygılı ve gerçek OS ayarıyla doğrulandı; haptic/ses yok; Sonuç geçişi Phase D olduğundan durum geri bildirimi kalitesi üzerinden puanlandı, otomatik 10 verilmedi. |
| Originality and Product Identity | 9 | E5 | Lime `let` wordmark, periwinkle aktif kenar, cam/slate yüzeyler; şablon hissi yok. |
| Accessibility and Inclusive Quality | 6 | E7, E8, E10, E11, E12 | Hedefler ≥ 44 pt, yalnız renk olmayan ipuçları ve Reduce Motion iyi; ancak QA-01 (büyük yazı tabanında taşma), QA-02 (çift semantik), QA-03 (odak yok). |
| Implementation Fidelity and Polish | 8 | E6, E7 | Renk/geometri kaynakla birebir; sarma satır aralığı, `OutlinePill` dolgusu ve beyan edilmemiş odak boşluğu cilayı düşürüyor. |

Final Score: `80 / 100`

Lowest Dimension: `Accessibility and Inclusive Quality — 6 / 10`

Fail Conditions: `None` (rubrik listesindeki bir koşul tek başına tetiklenmedi; puan ve boyut eşiği yetersiz)

Runtime Evidence Complete: `Yes` (canonical hedef, iki varyant, kritik durumlar; kapsamda motion-critical yüzey yok; sınırlar aşağıda)

Result: `FAIL`

---

## 3. Findings

### QA-01 — Bileşenler Dynamic Type'a dayanıklı değil (MovesCard, StatCard taşar; pill/düğüm kırpılır)
* **Severity / Type:** High / implementation defect (accessibility, layout). **Bağlı olduğu:** F00-FE-DESIGN-SYSTEM; `client-ui`, `visual-quality`.
* **Authority:** `platform.md` §14 ("Dynamic Type en az accessibility-medium"), `design-foundation.md` (etiket/CTA kırpılmamalı; OS metin ölçeği erişilebilirlik boyutlarına kadar), `ui-design.md` §13 ("kırpma yok — çalışma zamanında doğrula").
* **Expected:** metin büyüdükçe bileşen büyür veya belgelenmiş bir kuralla sınırlanır; taşma/kırpma yok.
* **Actual (E10, E11):** `MovesCard` iOS'un en büyük standart boyutunda (xxxL, 1,35×) 3,5 px, accessibility-medium'da (1,65×) 38 px taşar ("HAMLE" → "HAML/E", etiket karttan çıkar); `StatCard` 1,65×'te 13 px, 3,1×'te 124 px taşar (etiketler kartın altına düşer, 2,35×'ten itibaren yatay taşma da var); 3,1×'te (probe'un uzun etiketli örneğinde) sabit yükseklikli `LimePill`/`OutlinePill` sarılan etiketi kırpar, `LoopNode` rakamları kesilir, wordmark "Loo/plet" kırılır; 1,94×–2,76× arasında pill/düğüm davranışı ayrıca gözlenmedi (yalnız `MovesCard`/`StatCard` taşma sayacı).
* **Repro:** `xcrun simctl ui <udid> content_size accessibility-medium`; galeriyi aç; CONTROLS / CARDS bölümleri (`qa/qa-dynamic-type-1.65x.jpg`, `qa/dynamic-type-sweep.txt`). Ayrıca Frontend'in galeri testi yalnız 1,3×'i sınadığı için 1,35×'i kaçırdı.
* **Root-cause önerisi (hipotez):** bileşenlerde sabit `height`/kutu (`Container(height: …)`, `SizedBox`) ve ölçeklenmiş metin; rakam/etiket rollerinde ölçek sınırı yok. Düzeltme yönü: `minHeight` + serbest yükseklik, sabit kutulu rakamlarda `FittedBox`/ölçek sınırı veya belgelenmiş `TextScaler` kısıtı, testleri 1,35× ve 1,65×'te gerçek fontlarla `RenderFlex` taşma denetimiyle genişletme.

### QA-02 — Ekran okuyucu semantiğinde çift düğüm ve çift etiket
* **Severity / Type:** Medium / implementation defect (accessibility). **Authority:** `ui-design.md` §13 ("dekoratif kopyalar dışlanır, bir kez okunur").
* **Actual (E8, çalışma zamanı semantik ağaç):** `LimePill`, `OutlinePill` ve `TextLink` için aynı boyutta iki düğüm: üstte `button+tap+etiket`, altında `tap+aynı etiket` (buton işareti yok); `LoopBadge` etiketi `"HARİKA\nHARİKA"`, devre dışı `TextLink` etiketi `"Sonraki bölüm · yakında\nSonraki bölüm · yakında"` olarak birleşir. Sonuç: VoiceOver'da aynı kontrol için iki durak / etiketin iki kez okunması bekleniyor.
* **Sınır:** VoiceOver simülatörde çalıştırılamadı; kanıt motorun semantik ağacıdır, konuşma çıktısı değildir.
* **Root-cause önerisi (hipotez):** `_Pressable`'da hem `Semantics(onTap, label)` hem `GestureDetector(onTap)` + çocuk `Text(label)`; `LoopBadge`'de `Semantics(label)` altında `Text(label)` ve `excludeSemantics` yok. Ayrıca `UndoPill` kalan hakkı yalnız çağıranın etiketiyle (galeri örneği "Geri al" — sayısız) ve `LoopNode` durumu (bitti/güncel) semantikte vermiyor (not).

### QA-03 — Odak durumu (ui-design §8) uygulanmamış ve beyan edilmemiş
* **Severity / Type:** Medium / handoff gap (state). **Authority:** `ui-design.md` §8 "Focus: 2 px periwinkle halka (erişilebilirlik klavyeleri)".
* **Actual:** `lib/design` içinde hiçbir odak işlemi yok; `frontend.md` §1 "ui-design'ın listelediği her durumda bileşen" diyor ve bu boşluğu sapma olarak listelemiyor.
* **Karar gerektirir:** ya uygulanır ya da Tech Lead/UI Designer bunu belgelenmiş bir sapma olarak kabul eder; QA bunu sessiz geçmez.

### QA-04 — Sarılan metinde cila: satır aralığı 1,0, `OutlinePill` dolgusuz, display'de yetim nokta
* **Severity / Type:** Low / polish (typography). Non-blocking, QA-01 ile birlikte ele alınabilir.
* **Actual (E9, E11):** `caption`/`label` rolleri `height: 1` olduğundan iki satıra sarınca satırlar birbirine değer (galeri başlığı "TYPE ROLES — SPACE GROTESK · MANROPE"); uzun `OutlinePill` etiketi kenarlığa değer (yatay dolgu yok); "Döngü tamamlandı." display'i ≥ 1,65×'te "." tek başına satıra düşer.

---

## 5. Regression & Evidence Reuse

* **Etkilenen yüzey ve depth:** yeni katman + `pubspec.yaml` font tanımı; `full`. Gönderilen yüzeyde regresyon yok: E2 (fark kapsamı), E3 (305 + 197 test), E4 (F03 cihaz 13/13), E13 (soğuk açılış).
* **Reused:** yok. **Invalidated:** yok (fingerprint eşleşti).
* **Bağımsız QA probe:** E7–E12 (probe hedefi, gerçek motor).
* **Sınırlar (verdict'te açıkça):** Android çekilmedi (ANDROID-CI-EVIDENCE); VoiceOver cihazda/konuşma çıktısıyla çalıştırılmadı; gerçek cihaz yok, simülatör (Metal) ve debug build; sentetik pointer platform dokunuşunu atlar; yayın paketi boyut farkı ölçülmedi (F00-DS-UNMEASURED); tüketen ekran olmadığından tam ekran kompozisyon uyumu doğrulanamadı; F00'da motion-critical yüzey yok.

---

## 6. Final Verdict

* **QA Result: `Rejected`**
* **Blocking Issues:** QA-01, QA-02 (ve QA-03: uygula ya da açık karar).
* **Required Fixes (sıralı):**
  1. QA-01 — `MovesCard`, `StatCard`, `LimePill`, `OutlinePill`, `LoopNode`, `LoopletWordmark` ve büyük-yazı davranışı: en az accessibility-medium'da kırpma/taşma yok; kural belgelenir; testler 1,35× ve 1,65×'e genişletilir (gerçek fontlar, taşma denetimi).
  2. QA-02 — kontrol başına tek semantik düğüm, etiket bir kez; `UndoPill` kalan hak ve `LoopNode` durumu için semantik kanca; testler çocuk düğüm/çift etiket denetimi yapar.
  3. QA-03 — odak halkasını uygula veya Tech Lead kararıyla sapma olarak kaydet.
* **Non-blocking Notes:** QA-04; F00-DS-UNMEASURED (yayın boyutu, cihazda performans/VoiceOver); Android.

---

## 7. Tech Lead Note

* **Root-cause alanı:** Frontend/Mobile Developer (katman uygulaması). ui-design §12 metin ölçeğini "Phase D'de" render edilmemiş bıraktığı için büyük yazıda büyüme/sınırlama kuralı el kitabında yok; Tech Lead, Frontend'in muhafazakâr bir kuralı (min-yükseklik + yeniden akış, gerekirse sınırlı ölçek) belgelemesiyle yetinilip yetinilmeyeceğine veya bir UI Designer eki isteyip istemeyeceğine karar verir.
* **Routing:** F00-FE-DESIGN-SYSTEM için rework görevi (Frontend), sonra aynı final stage'de hedefli yeniden QA: senaryo 1, 4 ve 5 (`qa/src` probe'u yeniden kullanılabilir); Regression Depth `full` kalabilir, geçerli kanıt fingerprint ile yeniden kullanılır.
* **Not:** Kapı `Passed` olamaz; F00 Done değil. Bu bulgular Phase D tüketicilerine taşınmadan katmanda düzeltilirse ucuzdur. Sıra: F05-QA-STRICT ve F08 yerel kanıt QA kuyruğunda bekliyor.

---

# F00 — design-foundation: QA Raporu (F00-QA-VISUAL2, 2026-09-23)

> Hedefli final-stage yeniden doğrulama, F00-FE-A11Y-REWORK'e karşı. Test edilen revizyon: commit `0ce257c` (app ağacı `3753ad31fc301501d2e75db709d9b437838c250d`, `app/lib/design` ağacı `0b125cf11310ae08ae9b722a727af775cd737658`) — HEAD şu an `f021401`, ancak yalnız Tech Lead belge commit'leri üstüne geldi; `git rev-parse HEAD:app` ve `HEAD:app/lib/design` bugün doğrudan doğrulandı ve brief'teki değerlerle **birebir aynı**, dolayısıyla brief hâlâ geçerli. Değişen tam yüzey: `app/lib/design/components/{buttons,info,surfaces}.dart`, `tokens.dart`, `typography.dart`, `wordmark.dart` ve testleri (`git diff --stat 5f18c89 0ce257c -- app`). Hedef: iOS Simulator 18.6, iPhone 16 (393×852, birincil). Ham kanıt: `qa/qa2/` (bu oturumun scratchpad'i; dosya adları aşağıdaki tabloda).

## 0. QA Execution Plan

* **Stage / Scope:** final / client-only (Current QA Brief'ten, Tech Lead tarafından ayarlandı).
* **Modüller:** `core`, `client-ui`, `visual-quality`, `stateful-flow`. **Regression Depth: full. Evidence Reuse: allowed** — ama yalnız brief'in izin verdiği, bu revizyonun dokunmadığı kanıt için (E6, E6b, E7-varsayılan-ölçek, E9-Türkçe/ağırlık-ekseni, E12, E14); QA-01/02/03'ün kendisi için **hiçbir eski kanıt yeniden kullanılmadı** — hepsi bu turda yeniden üretildi.
* **Frontend'in `frontend.md`/`design/rework/` anlatımına güvenilmedi:** her üç bulgu da aşağıdaki kendi çalışma-zamanı kanıtımla bağımsız doğrulandı (probe yeniden derlendi, galeri sıfırdan derlendi, kendi test dosyam yazıldı — Frontend'in test dosyası kopyalanmadı/okunarak geçilmedi).

## 1. Evidence Ledger (bu tur)

| Evidence ID | Claim / Scenario | Class | Command / Action | Target | Result / Counts |
| --- | --- | --- | --- | --- | --- |
| E15 | Fingerprint geçerli | static | `git rev-parse HEAD`, `HEAD:app`, `HEAD:app/lib/design` | repo | `f021401` / `3753ad3…` / `0b125cf…` — brief'teki app ve design ağaçlarıyla birebir aynı |
| E16 | Analiz, format, tüm testler | automated | `melos run analyze`; `dart format --output=none --set-exit-if-changed app`; `melos run format:check`; `flutter test` (app) | workspace + app | `looplet_app`: analiz 0 sorun; `looplet_solver`: 1 önceden var olan ilgisiz `info` (bu özelliğin dışında); app-scoped format 110 dosya 0 değişen; workspace `format:check` yalnız önceden var olan ilgisiz `qa/src/qa_probe_main.dart`'ta başarısız (brief'in kendisi de bunu engelleyici saymıyor); `flutter test` (app) **313/313 PASS**, 0 başarısız — F03/F04/F05 dahil tüm paket, regresyon yok |
| E17 | F03 cihaz paketi (birlikte-var-olma) | runtime | `flutter test integration_test -d D0011CE7…` | iPhone 16, iOS 18.6 | **+13 All tests passed**, çıkış 0 — bu turda yeniden çalıştırıldı (Round 1'in E4'ünü tekrar üretiyor) |
| E18 | QA-01 kendi galeri karesi, 1,65× (accessibility-medium, platform.md §14 tabanı) | runtime | `xcrun simctl ui … content_size accessibility-medium`; galeri sıfırdan derlendi; kaydırma-ofsetli tam galeri taraması | iPhone 16 | `qa2/am_sheet1.png`, `qa2/am_sheet2.png` — 5 galeri bölümü de taşma/kırpma **0**; `MovesCard` "3 / HAMLE" tam çizili (65,9×69,2 civarı, taşma yok); `StatCard` "3 · 3 · 3★ / SEN OPTİMAL EN İYİ" tam çizili; `LoopNode` izi 1-5 tam çizili; `LimePill`/`OutlinePill` etiketleri kırpılmadan gösteriliyor; wordmark sağlam. QA-04'ün yetim "." satırı hâlâ görünür (beklenen — bu rework'ün kapsamında değildi) |
| E19 | QA-01 kendi galeri karesi, 3,12× (accessibility-extra-extra-extra-large — sweep'in en büyüğü) | runtime | aynı yöntem, `content_size accessibility-extra-extra-extra-large`; ek hedefli kaydırma (5200/5800/6400) ile Frontend'in "yalnız widget testiyle doğrulandı" dediği CARDS/STATS/TRACK bölümünü de kapsayacak şekilde galeri sonuna kadar tarandı | iPhone 16 | `qa2/xxxl_sheet1.png`, `qa2/xxxl_sheet2.png`, `qa2/qa2_xxxl_cards_5200.png`, `qa2/qa2_xxxl_cards_5800.png` — taşma/kırpma **0**; `StatCard` üç hücre de 3,12×'te tam çizili (Frontend'in yalnız 1,65×'te karede, ötesinde yalnız widget testiyle doğruladığını söylediği boşluk kendi karemle kapatıldı); `LoopNode` izi (1-4 tamamlandı + 5 geçerli, halo'lu) tam çizili; `LimePill` "Sonraki bölüm (Result, no glow)" 3 satıra büyüyerek (minHeight) kırpılmadan sığıyor; galeri wordmark'ı sağlam. QA-04'ün yetim "." bu ölçekte de hâlâ var (beklenen, non-blocking, dokunulmadı) |
| E20 | QA-02 kendi semantik ağaç dökümü | runtime (probe) | `qa/src/qa_probe_main.dart` + `runprobe2.sh` bu revizyona karşı sıfırdan yeniden derlendi; `probe_mode=gallery` | iPhone 16 | `qa2/qa2_semdump.log` — **sem-count=85** (Round 1: 92); `LimePill`/`OutlinePill`/`TextLink`/`GlassIconButton`/`UndoPill`/`LoopBadge` için sıfır çift-düğüm çifti; `label="HARİKA"` (tekil, eskiden `"HARİKA\nHARİKA"`); `label="Sonraki bölüm · yakında"` (tekil, eskiden ikilenmiş); `label="Geri al, 3 / 3 hak"` (kota artık etikette — QA-02 notu düzeltilmiş); `label="1, tamamlandı"` … `label="5, geçerli seviye"` (durum artık etikette — QA-02 notu düzeltilmiş). "\|" içeren iki etiket ("Döngü \| tamamlandı.", "ı ş ğ ç ö ü · HARİKA · …") incelendi: probe'un çok satırlı gösterim metinlerinde `\n`'i "\|" ile değiştirme kuralı, çift-semantik değil — zararsız |
| E21 | QA-03 kendi bağımsız odak-halkası testi | runtime (automated, gerçek motor) | Yeni yazılan `qa_focus_check_test.dart` (Frontend'in `components_test.dart`'ından kopyalanmadı/okunarak geçilmedi — kendi kontrol seti, `UndoPill` dahil ki Frontend'in testinde yok); yöntem: `FocusManager.highlightStrategy = alwaysTraditional` + `tester.sendKeyEvent(LogicalKeyboardKey.tab)` (gerçek donanım/Bluetooth klavye bu ortamda da erişilemez — brief'in izin verdiği "simüle klavye tetikleyici" sınıfı) | `flutter test` (yerel) | 3/3 PASS — `LimePill`, `GlassIconButton`, `UndoPill`: halka dinlenmede gizli; yalnız Tab birincil odağı bileşene taşıyınca `DecoratedBox(position: foreground)` çiziliyor; halka boyut değişikliğine yol açmıyor; odak kalkınca temizleniyor |
| E22 | Gönderilen uygulama soğuk açılış (kendi karesi) | build + runtime | `flutter build ios --simulator --debug -t lib/main.dart`; sıfırdan `simctl install`/`launch` | iPhone 16 | derleme çıkış 0; Ana ekran Round 1'in E13'ü ile **aynı** (eski amber/sistem yazı tipi görünüm — F00 henüz Phase C'de benimsenmedi, beklenen); bir seviyeye girildi (`coldlaunch_play_iphone16.png`): harf ızgarası, HAMLE sayacı, geri-al/sıfırla kontrolleri normal çalışıyor, istisna yok — F00 katmanı gönderilen oyun ekranını etkilemiyor |

## 2. Hedefli Senaryo Sonuçları

| Senaryo (brief) | Round 1 Sonuç | Round 2 Sonuç | Kanıt |
| --- | --- | --- | --- |
| QA-01 — Dynamic Type | FAIL (1,35×'te 3,5 px, 1,65×'te 38 px, 3,1×'te 124 px taşma) | **RESOLVED** — 1,65× ve 3,12×'te (ikisi de dahil, ikinci ölçek Frontend'in yalnız testle doğruladığı CARDS/STATS/TRACK boşluğunu da kapatacak şekilde) taşma/kırpma sıfır | E18, E19 |
| QA-02 — çift semantik | FAIL (92 düğüm, çift etiketler) | **RESOLVED** — 85 düğüm, sıfır çift-düğüm çifti, tüm etiketler tekil ve durum/kota bilgisini içeriyor | E20 |
| QA-03 — odak durumu | FAIL (hiç uygulanmamış) | **RESOLVED** — 3 farklı bileşen tipinde bağımsız test: halka yalnız `hasPrimaryFocus`'ta çiziliyor, boyutu etkilemiyor, temizleniyor | E21 |
| Birlikte-var-olma / regresyon | PASS | **PASS** (yeniden doğrulandı) — analiz, format (app), 313 test, F03 cihaz 13/13, soğuk açılış hepsi bu turda taze | E16, E17, E22 |

## Visual Quality Verdict (yeniden puanlama)

Değişmeyen beş boyut (`Experience Fit`, `Visual Hierarchy`, `Color/Surface/Asset`, `Motion and Sensory Quality`, `Originality`) Round 1'in kanıtını fingerprint ile yeniden kullanıyor — bu revizyon oraları hiç etkilemedi (brief'in izin verdiği liste). `Typography and Content Craft` da değişmedi: QA-04 (satır aralığı, yetim nokta) bu rework'ün kapsamında değildi ve E19'da 3,12×'te hâlâ gözlemlendi — puan aynı kalıyor. Dört boyut yeniden puanlandı.

| Rubric Dimension | Round 1 | Round 2 | Runtime Evidence | Not |
| --- | --- | --- | --- | --- |
| Experience Fit | 9 | 9 (reuse) | E6 | Değişmedi. |
| Visual Hierarchy | 9 | 9 (reuse) | E6 | Değişmedi. |
| Layout, Rhythm and Responsiveness | 7 | **9** | E18, E19 | QA-01 kapandı: platform tabanında (1,65×) ve sweep'in tepesinde (3,12×) taşma sıfır, CARDS/STATS/TRACK boşluğu da kapatıldı. 10 değil, çünkü tüm ara ölçekler (1,94×-2,76×) tek tek yeniden taranmadı (Round 1'in E10 sweep'i fingerprint ile hâlâ geçerli sayılıyor, bu turda tekrar edilmedi). |
| Typography and Content Craft | 8 | 8 (reuse) | E19 (QA-04 hâlâ gözlemlendi) | Değişmedi — QA-04 açık kaldı (non-blocking, bu rework'ün kapsamında değildi). |
| Color, Surface and Asset System | 9 | 9 (reuse) | E6 | Değişmedi. |
| Interaction, State and Feedback | 7 | **9** | E21 | QA-03 kapandı: odak halkası uygulandı ve 3 bileşen tipinde bağımsız doğrulandı. 10 değil, çünkü gerçek donanım/Bluetooth klavye kanıtı hâlâ erişilemez — yalnız simüle tetikleyici. |
| Motion and Sensory Quality | 8 | 8 (reuse) | E12 | Değişmedi; Phase D sonuç-geçişi hâlâ yok, otomatik 10 yok. |
| Originality and Product Identity | 9 | 9 (reuse) | E5 | Değişmedi. |
| Accessibility and Inclusive Quality | 6 | **9** | E18, E19, E20, E21 | Üç engelleyici bulgu da (QA-01/02/03) bu turda kapandı ve taze kanıtla bağımsız doğrulandı. 10 değil: VoiceOver konuşma çıktısı hâlâ cihazda çalıştırılmadı, gerçek donanım klavye hâlâ yok — bunlar Round 1'de de aynı sınırlardı. |
| Implementation Fidelity and Polish | 8 | **9** | E20, E21 | Beyan edilmemiş odak boşluğu artık kapandı ve `frontend.md`'de dürüstçe belgelendi; kalan tek fark QA-04 (zaten non-blocking, ayrı not). |

**Final Score: `88 / 100`** (Round 1: 80/100)

**Lowest Dimension:** `Typography and Content Craft` ve `Motion and Sensory Quality` — ikisi de 8 (ikisi de bu turun kapsamı dışında, ayrı gerekçeli)

**Fail Conditions:** `None`

**Runtime Evidence Complete:** `Yes` (bu turun hedeflediği üç bulgu için; sınırlar aşağıda, Round 1'dekiyle aynı)

**Result (mekanik, ≥93 eşiğine karşı): `FAIL`** — **ama bu FAIL, bu turun brief'inin engelleyici saydığı hiçbir şeyden kaynaklanmıyor.** 88 puanın 93'e olan 5 puanlık açığı tamamen şu ikisinden geliyor: (1) `Typography and Content Craft` = 8, yalnızca QA-04 yüzünden — Tech Lead Round 1'de QA-04'ü açıkça **non-blocking** ilan etti ve bu rework'ün görev listesine hiç almadı; (2) `Motion and Sensory Quality` = 8, Phase D sonuç-geçişi yüzeyinin **henüz var olmaması** yüzünden — bu bir kusur değil, bu özelliğin bu aşamasında yapısal olarak eksik olan bir yüzey (Round 1'de de aynı gerekçeyle 8'di). Yani: F00'ın bu aşamasında (ekran kompozisyonları henüz yok, Phase D) rubrik matematiksel olarak 88-90 civarında tavana çarpıyor — QA-01/02/03 mükemmel düzeltilse bile ≥93'e ulaşmak, bu iki maddeden biri de kapanmadan mümkün değil. Bu gerilim aşağıda Tech Lead Note'ta açıkça bayraklanıyor; QA bunu sessizce göz ardı etmedi ama kapıyı da kendi kararıyla değiştirmedi.

---

## 4. Findings — durum

* **QA-01 — RESOLVED.** Bkz. E18, E19. Sıfır taşma/kırpma, hem platform tabanında hem sweep'in tepesinde, Frontend'in yalnız-testle-doğruladığı boşluk da dahil.
* **QA-02 — RESOLVED.** Bkz. E20. 85 düğüm, sıfır çift-etiket, `UndoPill`/`LoopNode` notları da düzeltilmiş.
* **QA-03 — RESOLVED.** Bkz. E21. Odak halkası uygulanmış ve bağımsız doğrulanmış.
* **QA-04 — Open, Non-blocking (değişmedi).** Round 1'deki hâliyle duruyor: `caption`/`label` satır aralığı 1,0 sarınca birbirine değiyor; uzun `OutlinePill` etiketi kenarlığa değiyor; display'de ≥1,65×'te yetim "." E19'da 3,12×'te de doğrulandı, hâlâ orada. Bu rework'ün görev listesinde değildi (Tech Lead Round 1 reconciliation'da açıkça saymadı); QA bunu kapanmış gibi göstermiyor.
* **Yeni bulgu:** Yok. Bu turda hiçbir yeni defekt gözlemlenmedi.

## 5. Regression & Evidence Reuse

* **Bu tur taze üretilen:** E15-E22 (QA-01/02/03'ün kendisi, analiz/format/test/F03/soğuk-açılış).
* **Fingerprint ile yeniden kullanılan (brief'in izin verdiği liste):** E6/E6b (renk/degrade/glow ölçümü), E7 (varsayılan-ölçek geometri — Frontend'in notu: "varsayılan OS metin boyutunda tam eskisiyle aynı 60×63" doğru, bu turda tekrar ölçülmedi), E9 (Türkçe/tabular/ağırlık ekseni), E12 (Reduce Motion gerçek OS ayarı), E14 (`stateful-flow` olumsuz kontrol — bu revizyon kalıcılık/yaşam döngüsü/yönlendirme eklemedi, `lib/design` diff'i yalnız bileşen/token dosyaları).
* **Invalidated:** yok.
* **Sınırlar (Round 1 ile aynı, tekrar):** Android çekilmedi; VoiceOver cihazda/konuşma çıktısıyla çalıştırılmadı (E20 yalnız semantik ağaç, E21 yalnız simüle Tab); gerçek donanım/Bluetooth klavye yok (E21); gerçek cihaz yok, simülatör (Metal) ve debug build; tüketen ekran olmadığından tam ekran kompozisyon uyumu doğrulanamıyor (Phase D); F00'da motion-critical yüzey yok.

---

## 6. Final Verdict (F00-QA-VISUAL2)

* **QA Result: `Approved with Notes`**
* **Gerekçe:** Tech Lead'in F00-FE-A11Y-REWORK brief'inin engelleyici saydığı üç bulgu (QA-01, QA-02, QA-03) taze, bağımsız çalışma-zamanı kanıtıyla kapandı; regresyon yok (313 test + F03 cihaz 13/13 + soğuk açılış). "Notes": (1) sayısal rubrik 88/100 — genel ≥93 eşiğinin altında, ama açık tamamen QA-04 (zaten non-blocking) ve Motion'ın Phase D boşluğundan (kusur değil, yapısal) geliyor, bu turun brief'i ikisinden hiçbirini istemedi; (2) QA-04 hâlâ açık, non-blocking; (3) Sınırlar bölümündeki kalıcı eksikler (VoiceOver konuşma, gerçek klavye, gerçek cihaz) Round 1 ile aynı.
* **Blocking Issues:** Yok.
* **Non-blocking Notes:** QA-04 (değişmedi); F00-DS-UNMEASURED (yayın boyutu, cihazda performans/VoiceOver); Android; sayısal rubrik/93 eşiği gerilimi (yukarıda gerekçeli).

---

## 7. Tech Lead Note

* **Kapıyı ayarlamak Tech Lead'in işi** — bu not, QA'nın kendi kararı değil, dikkat çekmek içindir: Round 2'nin sayısal Visual Quality Verdict'i (88/100) mekanik olarak `FAIL` (≥93 eşiği), ama bu turun brief'inin görev verdiği üç bulgu da (QA-01/02/03) kapandı ve QA Result `Approved with Notes`. Açık, Round 1'de zaten `non-blocking` sayılan QA-04 ve F00'ın bu aşamasında (Phase D'den önce) yapısal olarak var olamayan bir motion yüzeyinden geliyor — F00 şu anki kapsamında muhtemelen hiçbir zaman 93'e ulaşamaz, QA-04 kapanmadan ve/veya rubriğin Motion maddesi bu özelliğin kapsamı için yeniden yorumlanmadan. Tech Lead şunlardan birini seçebilir: (a) Visual Quality Gate'i şu haliyle Passed'e taşımak (üç engelleyici bulgu kapandı, kalan açık zaten non-blocking olarak işaretliydi); (b) QA-04'ü de bir rework turuna açmak (Low/polish, ama kapı eşiğini etkiliyor); (c) bu özellik için (ekran kompozisyonu henüz yokken) ≥93 eşiğini yapısal olarak uygulanamaz kabul edip gate kararını QA Result'a (`Approved with Notes`) dayandırmak. QA üçünü de savunulabilir buluyor ve kararı Tech Lead'e bırakıyor.
* **Sıra:** F05-QA-STRICT ve F08 yerel kanıt kuyrukta bekliyor.

---

## Sonraki Komut

```text
Run Tech Lead
```
