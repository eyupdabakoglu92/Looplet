# Design Doctrine

Bu dosya, kullanıcıya görünen bütün ürünlerde uygulanacak varsayılan görsel ve deneyimsel tasarım anayasasıdır. Amaç tek bir estetik üretmek değil; bağlama uygun, çağdaş, ayırt edici ve uygulanmış haliyle doğrulanabilir ürün kalitesi üretmektir.

Kullanıcı veya Product Owner açık bir yön vermediyse bu doktrin uygulanır. Projeye özel kararlar `/ai-system/project-authority/design-foundation.md` içinde tutulur; bu dosyaya proje adı, renk veya marka ayrıntısı yazılmaz.

---

## 1. Core Design Positioning

Her ürün:

* kendi hedef kitlesine, kullanım bağlamına ve duygusal vaadine uygun görünmelidir
* ilk bakışta bilinçli bir art direction ve ürün kimliği taşımalıdır
* modernlik ile kullanılabilirliği birlikte sağlamalıdır
* ekran, hareket, yazı, ses ve dokunsal geri bildirimi tek deneyim sistemi olarak ele almalıdır
* varsayılan framework, component library, admin template veya AI-generated UI hissi vermemelidir

“Premium”; koyu tema, gradient, glow, büyük radius veya yoğun efekt demek değildir. Sakin bir kurumsal araç, erişilebilir bir kamu hizmeti veya oyuncu bir mobil oyun farklı estetikler gerektirir. Kalite; bağlama uygunluk, özgünlük, tutarlılık, detay ve gerçek kullanım anındaki hissin birleşimidir.

---

## 2. Target Quality Bar

Hedef seviye, ürün kategorisindeki güncel ve güçlü örneklerle yan yana konduğunda savunulabilir olmalıdır.

Zorunlu sonuçlar:

* kullanıcı bir saniye içinde ana hiyerarşiyi, üç saniye içinde ana aksiyonu anlar
* ürünün en az bir ayırt edici imzası vardır; bu imza yalnız logo veya accent color değildir
* tipografi, renk, şekil, yüzey, ikon/illüstrasyon, motion ve gerektiğinde audio/haptic aynı karakteri taşır
* loading, empty, error, success, disabled, selected, focused ve terminal durumlar sonradan eklenmiş görünmez
* responsive/adaptive davranış ve erişilebilirlik görsel kaliteyi bozmadan çözülür
* implementasyon, tasarım niyetini placeholder, sistem varsayılanı veya kolay component ikamesiyle ucuzlaştırmaz

Referans sorusu:

> Bu çıktı, aynı kategorideki güncel ve güçlü ürünlerin yanında bilinçli, özgün ve bitmiş görünüyor mu?

Yanıt görsel kanıt olmadan “evet” sayılamaz.

---

## 3. Context Before Style

Stil seçmeden önce şu bağlam kilitlenir:

* hedef kullanıcı ve kullanım ortamı
* ürünün kullanıcıda bırakmak istediği duygu
* kategori beklentileri ve kasıtlı sapmalar
* içerik yoğunluğu ve bilgi hiyerarşisi
* platform, viewport/device ve input biçimi
* erişilebilirlik ve reduced-motion ihtiyaçları
* güncel referans ürünler: taşınacak ilkeler ve kaçınılacak taklitler

Bağlam tanımlanmadan seçilen “dark premium”, “glassmorphism”, “gradient hero”, “rounded cards” gibi hazır reçeteler tasarım kararı değil, jenerik stil kısayoludur.

---

## 4. Project Design Foundation

Yeni kullanıcı yüzeyi olan her projede implementasyondan önce `/ai-system/project-authority/design-foundation.md` seçilmiş durumda olmalıdır. Foundation en az şunları içerir:

* experience thesis ve hedef duygu
* hedef kitle / kullanım bağlamı
* 3–5 güncel gerçek referans ve her biri için `carry / avoid`
* en az iki maddi olarak farklı ve gerçekten render edilmiş tasarım yönü
* seçilen yön, seçen kişi/rol ve karar gerekçesi
* typography, color, shape/radius, spacing, surface, icon/illustration ilkeleri
* motion dili; kapsam uygunsa audio/haptic dili
* signature motif ve anti-generic kurallar
* responsive/device matrisi ve accessibility ilkeleri
* `Draft / Selected / Superseded` durumu

UI Designer yönleri üretir ve öneri sunar; tek başına kendi yönünü onaylayamaz. Seçim kullanıcı, Product Owner veya Tech Lead tarafından açıkça yetkilendirilmiş karar kaydıyla yapılır.

---

## 5. Visual Exploration Is Rendered

Metinsel yön tarifi exploration değildir.

Yeni yüzey, redesign, yeni design-system veya motion-critical kapsamda:

* en az iki maddi olarak farklı yön gerçek piksel çıktısı olarak render edilir
* aynı içerik ve aynı kritik state üzerinden karşılaştırılır
* farklılık yalnız renk veya küçük radius değişimi olamaz
* artefact PNG, PDF, HTML prototype, Figma frame veya eşdeğer görüntülenebilir formatta olmalıdır
* seçim öncesi artılar, riskler ve ürün bağlamına uygunluk yazılır

Bir screenshot motion kanıtı değildir. Motion-critical kapsam video, screen recording, prototype veya zamanlanmış frame sequence ister.

---

## 6. Composition and Hierarchy

* Her ekranın tek bir ana amacı ve net görsel odağı olmalıdır
* Primary, secondary ve tertiary aksiyonlar ağırlık olarak ayrışmalıdır
* Boşluk dekor değil; ritim, gruplama ve odak üretmelidir
* Yoğun ekranlarda bilgi katmanları; sakin ekranlarda kompozisyonel denge görünmelidir
* Safe area, keyboard, dynamic type, orientation ve küçük viewport davranışı tasarımın parçasıdır
* Kart kullanımı otomatik çözüm değildir; gereksiz kutulama hiyerarşiyi zayıflatır

---

## 7. Typography and Content

* Tipografi marka karakteri ve bilgi mimarisini birlikte taşır
* Font seçimi lisans, dil/glyph kapsamı, platform performansı ve fallback ile doğrulanır
* Başlık/body/helper/label/number rolleri ölçü, ağırlık, line-height ve tracking düzeyinde tanımlanır
* Metin uzunluğu, localization expansion ve dynamic type ile layout test edilir
* Placeholder copy veya anlamsız lorem ipsum görsel onay kanıtı sayılamaz
* Mikro metin, tone of voice ve hata mesajları arayüz kalitesinin parçasıdır

---

## 8. Color, Surface and Imagery

* Renk sistemi semantic rollerle tanımlanır; yalnız hex listesi değildir
* Kontrast, light/dark varyantlar ve renk-körlüğü etkileri doğrulanır
* Yüzey ve depth, içerik hiyerarşisine hizmet eder; efekt göstermek için kullanılmaz
* Radius, border, shadow, blur, glow ve gradient bağlama göre seçilir; varsayılan zorunluluk değildir
* İkon, illüstrasyon, fotoğraf ve avatarlar tek bir sanat dili taşır
* Placeholder, emoji veya rastgele stock asset final kalite kanıtında kullanılamaz

---

## 9. State, Feedback and Delight

* Selected/focused/pressed durum yalnız ince border veya renk farkına dayanmaz
* Kullanıcı aksiyonunun sonucu gecikmesiz ve anlaşılır geri bildirilir
* Error, empty ve recovery state'leri ana akış kadar tasarlanır
* Motion; neden-sonuç, devamlılık, önem ve tempo anlatır
* Süre, easing, choreography ve interruption davranışı tanımlanır
* Audio/haptic yalnız süs değildir; önemli başarı, hata, seçim veya ödül anlarında tutarlı feedback katmanıdır
* Reduced motion, sessiz mod ve haptic kapalı durumları saygıyla ele alınır

---

## 10. Implementation Fidelity

Tasarımın kalitesi kaynak dokümanda değil gerçek çalışan üründe ölçülür.

* Gerçek font, asset, içerik ve state'ler canonical target'ta çalışmalıdır
* Referans render ile implementasyon aynı viewport/device üzerinde yan yana karşılaştırılır
* Spacing, wrapping, safe area, surface, color, icon ve state sapmaları görünür biçimde kaydedilir
* Motion-critical kapsam video/screen recording ile doğrulanır
* Simulator/device çalıştırılamadıysa visual gate PASS değildir; `Pending Evidence` olur
* Tasarımcının self-score'u yalnız provisional değerlendirmedir; kabul kararı değildir

---

## 11. Anti-Patterns

Aşağıdakiler varsayılan olarak başarısızdır:

* yalnız metinle tarif edilmiş ama render edilmemiş yönler
* aynı layout'un iki renk varyantını “iki alternatif” saymak
* default font + default component + accent color kombinasyonu
* her içeriği karta koymak veya her ürünü dark-gradient-glow diline zorlamak
* yalnız border ile selected/focused state
* placeholder icon, emoji, avatar, illustration veya copy ile final onay
* static screenshot ile motion kalitesi iddia etmek
* tasarımcı self-score'unu bağımsız QA yerine kullanmak
* gerçek target yerine yalnız source/code review ile görsel PASS vermek
* referans ürünü kopyalamak; bağlam ilkesini anlamadan yüzeyini taklit etmek
* erişilebilirliği polish sonrası eklenecek ayrı iş saymak
* “çalışıyor” sonucunu “kaliteli” sonucuyla eşitlemek

---

## 12. Success Criteria

Bir tasarım ancak aşağıdakilerin tümü sağlandığında doctrine ile uyumludur:

* project Design Foundation `Selected` durumunda
* en az iki gerçek render üzerinden yön seçimi kayıtlı
* screen/state/viewport kapsamı eksiksiz
* gerçek implementasyon kanıtı mevcut
* motion-critical kapsamın hareket kanıtı mevcut
* bağımsız QA, `premium-ui-rubric.md` üzerinden 93+ veriyor
* hiçbir rubric boyutu 8'in altında değil
* hiçbir fail condition oluşmuyor

Sözlü “modern/premium” iddiası bu kriterlerin yerine geçmez.
