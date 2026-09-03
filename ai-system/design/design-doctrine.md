# Design Doctrine

Bu dosya ürünün varsayılan görsel ve deneyimsel tasarım anayasasıdır.

Kullanıcı veya Product Owner aksi yönde açık bir yön vermediyse, tüm UI/UX kararları aşağıdaki varsayılan tasarım doktrinine göre alınmalıdır.

---

## 1. CORE DESIGN POSITIONING

Ürün hissi:

* **high premium** — mid segment değil
* modern mobile game app kalitesinde
* güçlü görsel kimlik — karakterli, tanınabilir
* playful ama childish değil
* sosyal ve akıcı ama ucuz görünmeyen
* ilk bakışta App Store featured game hissi

**Referans Tier:**
* Top mobile game uygulamaları (güçlü visual identity, atmospheric ekranlar, tatmin edici interaction)
* Premium consumer app'ler (güçlü tipografi, layered surface, distinctive color language)
* "Bu uygulama özel ve kaliteli" hissi veren her şey

Bu ürün:

* generic React Native template gibi görünmemelidir
* startup template gibi görünmemelidir
* admin panel gibi görünmemelidir
* wireframe gibi görünmemelidir
* form builder gibi görünmemelidir
* default component kütüphanesi demosu gibi görünmemelidir
* **orta segment mobil uygulama gibi görünmemelidir**
* sıradan ve basit görünmemelidir

---

## 2. TARGET VISUAL QUALITY BAR

Hedef kalite seviyesi:

* **App Store featured game seviyesi** — yaklaşmak değil, ulaşmak
* ilk bakışta “bu özel bir ürün” hissi — “bu da bir uygulama” değil
* generic değil, güçlü ve tutarlı görsel kimlik
* her ekranın kendine ait atmosferi var
* güçlü görsel hiyerarşi — kullanıcı 1 saniyede ne yapacağını biliyor
* bilinçli boşluk kullanımı — stage etkisi
* güçlü ama rafine CTA’lar — ucuz gradient değil
* flat olmayan, katmanlı ve zengin yüzey dili
* güçlü ve karakterli tipografi
* tatmin edici selection / pressed / focused / loading state’ler
* her component ürün ailesine ait hissettiriyor

**Referans sorusu (her ekran için):**
“Bu ekranı bir top mobile game’in içinde görsem doğal görünür mü?” → Hayır ise yetersiz.

---

## 3. DEFAULT VISUAL DIRECTION

Eğer feature özelinde başka yön verilmediyse varsayılan stil:

### Overall Tone
* koyu ve atmosferik hero alanı
* daha sakin, sıcak veya nötr açık body yüzeyleri
* güçlü üst alan + kontrollü içerik kartları
* ekranlar “tek dümdüz yüzey” gibi görünmemeli

### Background Approach
* Düz boş zemin kullanılmamalı
* Hafif gradient, glow, tonal geçiş veya katmanlı yüzey sistemi kurulmalı
* Arka plan dikkat dağıtmamalı ama atmosfer yaratmalı
* Hero alanı ve içerik alanı ayrışmalı

### Surface Approach
* Flat beyaz bloklar yerine layered surface mantığı
* Primary surface ve secondary surface arasında fark olmalı
* Stroke, soft shadow, tonal ayrım veya glow mantığı bilinçli kullanılmalı
* Her yüzey aynı görünmemeli

### Typography Approach
* Güçlü headline
* Sakin ama kaliteli body metin
* Yardımcı metinler baskın olmamalı
* CTA metni net ve güven verici olmalı
* Tipografi hiyerarşisi ilk bakışta okunmalı

### CTA Approach
* Primary CTA ekrandaki en baskın aksiyon olmalı
* Gradient sadece gerçekten gerekiyorsa ve kaliteli görünüyorsa kullanılmalı
* Ucuz görünen varsayılan mavi gradient butonlardan kaçınılmalı
* CTA yüzeyi, spacing’i ve ağırlığı “default button” hissi vermemeli

### Selection Approach
* Selected state sadece border ile çözülmemeli
* Seçim tatmin edici ve açık görünmeli
* Tonal dolgu, halo, inner contrast, scale veya depth hissi kullanılabilir
* Kullanıcı “seçtim” değil, “doğru şeyi seçtim” hissi almalı

---

## 4. UX POSITIONING

Tasarım sadece güzel görünmek değildir.

Her ekran:

* ilk 3 saniyede anlaşılır olmalı
* kullanıcının ne yapacağını açık göstermeli
* bilişsel yükü düşük tutmalı
* error, loading, empty, success durumlarını açık göstermeli
* kullanıcıyı gereksiz metin ve zayıf karar noktalarıyla boğmamalı

---

## 5. SPACING & COMPOSITION RULES

* 4/8pt mantığında tutarlı spacing kullanılmalı
* İçerik sıkışık görünmemeli
* Boşluk amaçsız değil, kompozisyonel olmalı
* Çok büyük boş alan bırakılıyorsa bu “stage” etkisi üretmeli; “ekran boş kalmış” hissi vermemeli
* Her ekran section’lara ayrılmış görünmeli
* Hero, content, actions bölgeleri birbirine karışmamalı

---

## 6. COMPONENT PHILOSOPHY

Component’ler:

* default UI kit hissi vermemeli
* aynı ekranda tutarlı radius / padding / emphasis dili taşımalı
* input, card, button, chip, selection tile gibi öğeler aynı ürün ailesine ait hissettirmeli
* her component sadece çalışmamalı, ürün hissi taşımalı

---

## 7. MOTION PHILOSOPHY

Motion varsa:

* subtle ama hissedilir olmalı
* state change’i açıklamalı
* selection’ı tatmin edici yapmalı
* loading’i daha rafine hissettirmeli
* abartılı olmamalı
* animasyon, ürün kalitesini artırmalı; dikkat dağıtmamalı

---

## 8. ANTI-PATTERNS (ASLA)

Aşağıdakiler varsayılan olarak başarısız çözüm sayılır:

* düz beyaz ekran + birkaç input + mavi buton
* üstte gradient, altta rastgele kartlar
* sadece border ile selected state
* büyük ama anlamsız boş alan
* generic ayar butonu / floating icon çözümü
* placeholder hissi veren avatar/option seçimleri
* form builder görünümü
* her yerde aynı kart + aynı input + aynı CTA kombinasyonu
* tipografi hiyerarşisi zayıf ekran
* sadece teknik olarak doğru ama estetik olarak vasat çözüm
* **sıradan ve basit görünen her şey**
* **generic React Native component stack'i**
* **"bu da çalışıyor" kalitesinde tasarım**
* **orta segment consumer app hissi**
* header'ların, section'ların ve component'lerin standart sistem görünümü taşıması

---

## 9. DEFAULT DESIGN DECISION WHEN UNSPECIFIED

Eğer kullanıcı tasarım yönü vermediyse veya Tech Lead özel bir estetik yön tanımlamadıysa:

* daha premium yönü seç
* daha generic olmayan yönü seç
* daha güçlü görsel hiyerarşi olan yönü seç
* daha rafine yüzey dili olan yönü seç
* daha tatmin edici selection state’i olan yönü seç
* daha pahalı görünen ama hâlâ kullanılabilir olan yönü seç

---

## 10. SUCCESS CRITERIA

Bir tasarım aşağıdakileri sağlıyorsa doctrine ile uyumludur:

* modern görünüyor
* generic görünmüyor
* premium hissettiriyor
* CTA net
* state’ler belirgin
* tipografi güçlü
* yüzey dili kurulu
* background zayıf değil
* spacing dengeli
* gerçek ürün hissi veriyor