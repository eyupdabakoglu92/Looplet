# Content Quality Standard

> Status: MANDATORY SHARED SUPPLEMENT — yalnız authored-content kapsamı için.
> Execution/state authority: `role-execution-contract.md`. Ürün şartları PRD'den, alan kuralları feature contract'ından gelir.

Last Updated: 2026-09-30

## 1. Sorumluluk

* Content Designer içeriğin kullanıcıya değerini, editoryal seçimlerini ve kendi kalite incelemesini sahiplenir. Brief'e uymak tek başına yeterlilik kanıtı değildir; fark ettiği kalite boşluğunu somut örnekle Tech Lead'e taşır.
* Tech Lead brief'in yeterliliğini, ölçütlerin tutarlılığını, araç readiness'ini ve kabul kararını sahiplenir. Bilinen kritik kalite kusuru için “AC'de yasaklanmamış” diyerek Accepted vermez; gerekli contract/rework'ü açar. Ürün semantiği değişiyorsa Product Owner revision gerekir.
* Developer kalıcı generator, validator, importer ve entegrasyon kodunu sahiplenir. Content Designer mevcut araçları kullanır; eksik üretim/kabul aracını depo dışı script ile ikame etmez. Salt okunur keşif analizi kalıcı teslim kontrolünün yerine geçmez.
* QA ölçümün doğru şeyi ölçtüğünü ve gerçek teslimin hem zorunlu kuralları hem editoryal ölçütleri karşıladığını bağımsız doğrular. Aynı üretim raporunu yeniden okumak bağımsız QA değildir.
* Kullanıcı rutin içerik elemesi, kalite kontrolü veya araç eksikliği için varsayılan reviewer değildir. Açık authority'nin zorunlu tuttuğu insan/ürün kararını Tech Lead yönetir; “manual review” tek başına “bizzat kullanıcı” demek değildir. AI incelemesi insan incelemesi olarak kaydedilmez.

## 2. Üretim öncesi kalite contract'ı

Tech Lead, Content Designer'ın önerisiyle `architecture.md` içinde veya ona bağlı bir belgede aşağıdakileri kilitler. Küçük teslimde kısa bir tablo yeterlidir; her iş için generator, pilot veya matematiksel kanıt zorunlu değildir.

* Kullanıcı amacı, hedef kitle, dil, format, kapsam/miktar ve tekrar/çeşitlilik beklentisi.
* Her ölçüt için ID, authority, **required / advisory**, uygulanma koşulu, kabul/red eşiği, ölçüm veya review yöntemi, evidence ve owner.
* Teknik geçerlilik ile editoryal/deneyim kalitesi ayrı değerlendirilir; birinin PASS'i diğerini kapatmaz. Sezgisel skor, kanıtlanmış özellik veya insan deneyimi olarak sunulmaz.
* Kaynak/provenance, uygun kullanım koşulları, dışlamalar, belirsiz girdilerin karantinaya alınması ve değişiklik etkisi.
* Araç/girdi hazır oluşu, deneme ve hesap bütçesi, pilot gereksinimi, örneklem kapsamı ve escalation koşulları.

Zorunlu alan kuralı belirsiz, çelişkili veya araçta uygulanmıyorsa toplu üretim başlamaz. Bağımsız keşif/kurasyon ilerleyebilir; ürün şartı sessizce daraltılmaz. Başarı göstergeleri ve sayısal eşikler role prompt'una değil feature contract'ına yazılır.

## 3. Preflight ve pilot

1. Girdi sayısı/uygunluğu, araçlar ve zorunlu ölçütlerin birlikte sağlanabilirliğini kontrol et. Sayısal imkânsızlığı üretim başlamadan bildir.
2. Yeni veya önemli ölçüde değişmiş toplu/prosedürel içerikte her önemli sınıfı ve sınır durumu kapsayan küçük pilot hazırla. Hacmi/kapsamı contract belirler.
3. Kabul ve red örneklerini nedenleriyle kaydet. Validator hem geçerli örneği kabul etmeli hem her required kuralın ihlalini doğru nedenle reddetmeli; ilgisiz bir hatadan çıkması yeterli değildir.
4. Pilotun kalite, süre ve kabul oranını ölç. Eksik kanıtla toplu üretime geçme. Eşik değişikliği Tech Lead'in gerekçeli contract kararıdır; PRD değişiyorsa PO revision'dır.

## 4. Üret, incele, düzelt

* Required FAIL: adayı reddet ve bütçe içinde yeniden üret/düzelt. Bütçe biterse `Content Blocked`: denenen yöntem, aday sayısı, hata dağılımı, süre, eksik girdi/araç ve önerilen next action.
* Required UNKNOWN / NOT RUN / timeout: PASS değildir; `Content Validation Pending` veya eksik prerequisite için `Content Blocked`. Ölçüm belirsizliği içerik imkânsızlığı iddiasına dönüştürülmez.
* Advisory eksik: etki ve gerekçeyi kaydet; required kusuru advisory'ye taşıyarak kabul etme.
* N/A: yalnız contract'ın açık uygulanma koşulu sağlanmıyorsa, gerekçesiyle. Kontrolü atlamak için kullanılmaz.
* Kritik kalite kusuru, ölçüt tablosunda unutulmuş olsa da Tech Lead'e rework/contract finding'dir; kullanıcı sign-off'una aktarılmaz.
* Editoryal inceleme gerçek örnekleri ve gerekçeleri içerir: doğruluk, hedef kitleye uygunluk, açıklık, çeşitlilik ve amaçla ilgili deneyim. Otomatik skor tek başına “eğlenceli / adil / anlaşılır” kanıtı değildir.

## 5. Kanıt ve değişiklik etkisi

`prompt-evidence-integrity-standard.md` uygulanır. İçerik raporu ölçüt → gerçek kontrol/review → gözlenen sonuç zincirini gösterir.

* Tekrarlanabilir paketlerde içerik, girdiler/sözlük, kural/config, araç ve motor sürümü/hash'i; komutlar, tohumlar ve bütçeler kaydedilir. Tohum tek başına aynı sonucu garanti etmez.
* Gerçek kontrol çıktıları depoda erişilebilir evidence dosyalarına bağlanır. Eksik veya eski rapor current PASS değildir.
* İlgili içerik, kaynak, kural veya araç değişirse etkilenen evidence geçersizleşir; `Content Quality Gate = Pending`. Etkilenmeyen kanıt yalnız gerekçeli fingerprint karşılaştırmasıyla korunur.
* Tam kalite denetimi pahalıysa hızlı kontroller ayrı çalışabilir; required tam denetim QA/kabul/yayın öncesi zorunlu kalır. Workflow audit yalnız akış tutarlılığını kontrol eder, içerik kalitesini kanıtlamaz.

## 6. Kabul ve bağımsız QA

Yeni veya yeniden açılan authored-content işlerinde orchestration alanları:

* `Content Quality Contract`: feature dizinine göre kalite contract dosyasının yolu; içerik kapsamı yoksa `Not Required`.
* `Content Quality Gate`: `Not Required / Pending / Ready for QA / Passed`.
* `Content Quality Evidence`: güncel rapor/evidence referansları; henüz yoksa `None`.

Tech Lead sınıflandırma ve gate ilerlemesini sahiplenir. Delivery rolleri yalnız etkilenen gate'i Pending'e geri alabilir ve kendi evidence referansını güncelleyebilir. QA verdict üretir; Tech Lead bağımsız QA kanıtını reconcile ederek Passed yapar.

* Pending → Ready for QA: uygulanabilir tüm required kontroller PASS, editoryal inceleme tamam, gerekiyorsa pilot kabul edilmiş, açık kritik finding yok; Tech Lead evidence'i okumuş ve Delivery Review Accepted.
* Ready for QA → Passed: QA kuralları bağımsız doğrulamış, gerçek asset'ler üzerinde kritik probe/negatif örnek çalıştırmış ve kapsamla ilgili editoryal örnekleri gerekçeli incelemiş. Functional QA ile content gate geçebilir; feature kapanışı ayrıca final QA/release gerektirir.
* QA girişinde content modülü için Ready for QA veya değişmeden yeniden kullanılan Passed gerekir. Passed reuse gerekçesi evidence'de olmalı; eksik doğrulama Ready for QA olamaz.
* Required FAIL için QA `Rejected`; required eksik kanıt için uygun pending verdict. “Approved with Notes” kritik kusur veya eksik required kanıtı örtemez.
* Sonlu paketin otomatik hard invariant'ları bütün kayıtlarda kontrol edilir. Editoryal örneklem risk sınıfları, sınır durumları ve seçim yöntemiyle kaydedilir; kritik hata bulunursa etkilenen grubun tamamına genişler.
* Eski kapanmış feature'lar salt core güncellemesiyle yeniden açılmaz. Yeni/reopened içerik işinde Tech Lead alanları ekler; legacy alan yokluğu kalite PASS anlamına gelmez.
