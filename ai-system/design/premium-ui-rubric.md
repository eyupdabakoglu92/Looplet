# Premium UI Rubric

Bu rubric UI Designer, Frontend/Mobile Developer, Game Developer (Unity), QA ve Tech Lead için ortak görsel kalite ölçüsüdür. Ürün kategorisinden bağımsızdır; “premium” kelimesini belirli bir stile değil, bağlama uygun ve kanıtlanmış uygulama kalitesine bağlar.

---

## Scoring Authority

* 10 boyutun her biri 10 üzerinden puanlanır.
* UI Designer ve developer puanı `Provisional Self-Review` olarak yazar; kabul yetkisi değildir.
* Final puanı QA, gerçek çalışan canonical target ve kayıtlı visual evidence üzerinden verir.
* Kaynak kod, tasarım metni veya static mockup tek başına implementation polish kanıtı değildir.
* Motion-critical kapsam static screenshot ile puanlanamaz.

## Verdict Bands

* **97–100:** referans seviye
* **93–96:** güçlü, release adayı premium kalite
* **85–92:** hedef bandın altında; zorunlu rework
* **0–84:** kabul edilmez

Ek kabul koşulları:

* hiçbir boyut 8'in altında olamaz
* herhangi bir fail condition doğrudan `FAIL / Rejected` üretir
* gerekli runtime veya motion kanıtı yoksa skor provisional kalır ve sonuç `Runtime Validation Pending` olur
* 92 ve altı `Approved with Notes` ile geçirilemez

---

## 1. Experience Fit /10

* Görsel yön hedef kullanıcıya, ürün vaadine ve kullanım ortamına uygun mu?
* Estetik kararlar kategori klişesinden mi geliyor, gerçek experience thesis'ten mi?
* Ürün “pahalı görünmeye çalışan” değil, kendi bağlamında güvenilir ve bilinçli mi?

## 2. Visual Hierarchy /10

* Kullanıcı ana amacı ve aksiyonu hızlı anlıyor mu?
* Primary/secondary/tertiary önem doğru mu?
* İçerik yoğunluğu ve progressive disclosure iyi yönetilmiş mi?

## 3. Layout, Rhythm and Responsiveness /10

* Kompozisyon dengeli ve bilinçli mi?
* Spacing ritmi, alignment ve gruplama tutarlı mı?
* Küçük/büyük viewport, safe area, keyboard, orientation ve dynamic type davranışı güçlü mü?

## 4. Typography and Content Craft /10

* Font seçimi karakterli, okunabilir ve lisans/glyph/fallback açısından uygulanabilir mi?
* Ölçek, ağırlık, line-height, tracking ve wrapping gerçek içerikte iyi mi?
* Mikro metin ve tone of voice ürün hissini destekliyor mu?

## 5. Color, Surface and Asset System /10

* Semantic renk rolleri, kontrast ve state renkleri doğru mu?
* Surface/depth yaklaşımı hiyerarşiye hizmet ediyor mu?
* İkon, illüstrasyon, fotoğraf ve diğer asset'ler tek, bitmiş bir sanat dili taşıyor mu?

## 6. Interaction, State and Feedback /10

* Pressed, selected, focused, disabled, loading, error, empty, success ve recovery state'leri ayırt edilebilir mi?
* Feedback gecikmesiz, anlaşılır ve tatmin edici mi?
* CTA davranışı ve input ergonomisi güven veriyor mu?

## 7. Motion and Sensory Quality /10

* Motion state değişimini, devamlılığı veya önemi açıklıyor mu?
* Timing, easing, choreography ve interruption rafine mi?
* Uygunsa audio/haptic aynı feedback diliyle çalışıyor mu?
* Reduced-motion, sessiz ve haptic-off davranışı düşünülmüş mü?

Scope gerçekten motion/audio/haptic içermiyorsa QA, nedenini kanıtla birlikte yazar ve bu boyutu görsel/state feedback kalitesi üzerinden değerlendirir; otomatik 10 vermez.

## 8. Originality and Product Identity /10

* Ürünün logo dışında tanınabilir bir signature motif'i var mı?
* Çıktı AI template/component-library demo hissinden uzak mı?
* Referanslardan ilke alıp taklitten kaçınıyor mu?

## 9. Accessibility and Inclusive Quality /10

* Kontrast, touch target, focus, screen reader sırası ve non-color cues yeterli mi?
* Dynamic type/text expansion ve reduced motion kaliteyi koruyor mu?
* Erişilebilir alternatifler ikinci sınıf bir deneyim üretmiyor mu?

## 10. Implementation Fidelity and Polish /10

* Gerçek target, seçilmiş direction ve handoff ile görsel olarak eşleşiyor mu?
* Pixel-level spacing, wrapping, radius, color, asset ve safe-area ayrıntıları doğru mu?
* Placeholder/default ikameler veya platformlar arası kontrolsüz sapmalar var mı?
* Runtime capture, kaynak revision'ı ve target bilgisiyle izlenebilir mi?

---

## Mandatory Evidence

Final puan için en az:

* seçilmiş Design Foundation
* karşılaştırılabilir source render/mockup
* gerçek simulator/device/browser/game runtime screenshot'ları
* kritik state'lerin ekran kanıtı
* motion-critical kapsam için video/screen recording/prototype kanıtı
* viewport/device, revision, capture owner ve tarih bilgisi
* referans ile implementasyon arasındaki sapma listesi

gereklidir.

## Fail Conditions

Aşağıdakilerden biri varsa skor ne olursa olsun sonuç `FAIL / Rejected` olur:

* render edilmemiş text-only design direction
* yalnız renk/radius farkıyla üretilmiş sahte alternatifler
* generic template, default UI kit veya eski nesil uygulama hissi
* ana CTA/hiyerarşi belirsizliği
* kritik state veya recovery akışının eksikliği
* placeholder/default font, icon, illustration, avatar, audio veya copy'nin final çıktıda kalması
* selected/focused state'in yalnız zayıf border/renk farkına dayanması
* gerçek target yerine source-only review ile görsel PASS
* motion iddiasının hareket kanıtı olmadan kabul edilmesi
* reference render ile implementasyon arasında açıklanmamış belirgin sapma
* erişilebilirlikte kritik kontrast, focus, touch target veya reduced-motion ihlali
* Design Foundation ile çelişen veya projede izole bir görsel dil oluşturan yüzey
* self-score'un bağımsız QA puanı gibi sunulması
