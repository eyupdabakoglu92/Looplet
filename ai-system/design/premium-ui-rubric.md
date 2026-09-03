# Premium UI Rubric

Bu rubric UI Designer, Frontend/Mobile Developer, Game Developer (Unity) (Game Visual/HUD Direction scope'unda), QA ve Tech Lead tarafından ortak kalite çıtası olarak kullanılmalıdır.

Amaç:
* “iyi görünüyor gibi” yerine ölçülebilir kalite değerlendirmesi yapmak
* generic tasarımı erken tespit etmek
* premium kaliteyi zorlamak

Puanlama:
* Her madde 10 üzerinden puanlanır
* 8 altı zayıf
* 9 güçlü
* 10 çok güçlü / referans seviye

Toplam skor hedefi:
* 85 altı → kabul edilmez
* 85–92 → iyi ama revizyon gerekebilir
* 93+ → güçlü kalite (hedef band)
* 97+ → referans seviye

**Önemli:** Skor ne olursa olsun, ekran "sıradan / basit / generic" hissi veriyorsa kabul edilmez.
"Top mobile game app" referans tierinde görünüp görünmediği subjektif ama zorunlu bir kontrol noktasıdır.

---

## 1. Visual Hierarchy /10

Sorular:
* Kullanıcı ilk bakışta ana aksiyonu anlıyor mu?
* En baskın öğe doğru öğe mi?
* Başlık, body, yardımcı metin ve CTA iyi ayrışıyor mu?
* Ekranda her şey aynı ağırlıkta mı görünüyor?

---

## 2. Layout & Composition /10

Sorular:
* Ekran dengeli mi?
* Section’lar net mi?
* Boşluk bilinçli kullanılmış mı?
* Ekran sıkışık veya eksik doldurulmuş gibi mi?
* Hero / content / action ilişkisi güçlü mü?

---

## 3. Surface & Depth Quality /10

Sorular:
* Kartlar/yüzeyler flat ve ucuz mu, yoksa katmanlı ve kaliteli mi?
* Primary ve secondary surface farkı net mi?
* Stroke/shadow/tonal farklar bilinçli mi?
* Tasarım “bloklardan oluşan bir wireframe” gibi mi?

---

## 4. Typography Quality /10

Sorular:
* Başlıklar güçlü mü?
* Yardımcı metinler baskın mı, dengeli mi?
* Font boyutu/ağırlık/ritim iyi mi?
* Ekran default sistem tipografisi gibi mi duruyor?

---

## 5. CTA Clarity & Action Design /10

Sorular:
* Primary CTA net mi?
* Secondary action’lar doğru seviyede mi?
* Buton default/generic mi görünüyor?
* CTA ürün kalitesini aşağı çekiyor mu?

---

## 6. Selection / Focus / State Design /10

Sorular:
* Selected state tatmin edici mi?
* Focus state güçlü mü?
* Error / loading / disabled state açık mı?
* State’ler sadece teknik olarak mı var, yoksa gerçekten hissediliyor mu?

---

## 7. Product Feel /10

Sorular:
* Ekran gerçek ürün hissi veriyor mu?
* Demo/template hissi var mı?
* App Store’da görünse “kaliteli ürün” hissi verir mi?
* Ürün dili tutarlı mı?

---

## 8. Modernity /10

Sorular:
* Bu ekran güncel mi görünüyor?
* 2026 standardında çağdaş hissediyor mu?
* Eski nesil mobil UI kararları var mı?
* Tasarım modern ama ruhsuz mu, yoksa modern ve rafine mi?

---

## 9. Non-Generic Originality /10

Sorular:
* Ekran diğer binlerce AI-generated UI ile aynı mı?
* Ayırt edici bir görsel yön var mı?
* Generic kart/input/buton kombinasyonundan çıkabilmiş mi?
* Karakterli ama kontrollü mü?

---

## 10. Implementation Polish /10

Sorular:
* Pixel-level hissi iyi mi?
* Padding/radius/border dengesi doğru mu?
* Component’ler aynı aileden mi?
* Frontend uygulaması designer kararını ucuzlaştırmış mı?

---

# Verdict Bands

## 97–100
* Referans seviye — top mobile game app kalitesi
* Release adayı

## 93–96
* Güçlü premium kalite
* Release adayı olabilir

## 85–92
* İyi kalite ama hedef bandın altında
* Revizyon gerekir

## 0–84
* Generic / vasat / yetersiz
* Kabul edilmez

---

# Fail Conditions

Aşağıdakilerden biri varsa skor ne olursa olsun ekran zayıf sayılmalıdır:

* wireframe/template hissi
* ana CTA belirsizliği
* selected state’in zayıf olması
* çok generic kart/input/buton dizilimi
* belirgin görsel hiyerarşi eksikliği
* flat ve ucuz yüzey dili
* aşırı boş ama kompozisyonsuz ekran
* **sıradan ve basit görünüm — "top mobile game app" referans tierinde görünmüyor**
* **generic React Native component stack hissi**
* **orta segment consumer app estetiği**