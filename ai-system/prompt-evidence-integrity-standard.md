# Prompt Evidence Integrity Standard

> Status: MANDATORY SHARED SUPPLEMENT
>
> Test, build, runtime, içerik ve release kanıtlarının anlamını tanımlar. Execution semantics authority: `role-execution-contract.md`.

Last Updated: 2026-09-16

---

## 1. Evidence Record

PASS, verified veya eşdeğer iddia en az şu alanları taşır:

* Claim / Scenario: kanıtlanan davranış veya kural
* Evidence class: static inspection / build / unit / automated functional / repeatable integration / runtime / manual
* Command / action: gerçekten çalıştırılan komut ya da tekrarlanabilir review adımları
* Target / environment: component, dosya/veri seti, process, platform veya CI run
* Result: exit code ve uygulanabiliyorsa pass/fail/skip sayıları
* Provenance: zaman, kontrol edilen revision veya çalışma ağacı, erişilebilir run/log/artifact bilgisi
* Isolation: kullanılan mock, fake, stub, override ve testin çalıştırmadığı sınırlar

Toplam test sayısı tek başına evidence record değildir. Platform, araç, dosya yolu, veri miktarı ve ürün eşikleri project/feature authority'den alınır; bu standart bunları sabitlemez.

---

## 2. Evidence Truth Rules

* Yazılmış, planlanmış veya CI'a eklenmiş test henüz çalıştırılmadıysa sonuç `PENDING / NOT RUN`dır.
* Pipeline'ın green olması tüm required check'lerin geçtiğini göstermez. Allowed-failure/non-blocking job varsa check'in gerçek sonucu, exit code ve skip sayısı ayrıca incelenir.
* Check'in kendisi gerçekten PASS ise bu dar sonuç kaydedilebilir; release policy blocking gate istiyorsa pipeline'ın bunu enforce etmesi ayrı bir gereksinimdir.
* Skipped, quarantined, boş gövdeli veya required assertion'a ulaşmadan dönen test ilgili davranışa PASS kanıtı vermez.
* Build başarısı boot; dry-run deploy; mock sonucu gerçek servis entegrasyonu kanıtı değildir.
* Eski kanıt yeni revision için otomatik geçerli sayılmaz. Etkilenen kod, içerik, veri, config, schema, bağımlılık ve ortamı karşılaştır; değişmeyen kapsamın kanıtını gerekçesiyle yeniden kullan.
* Terminal sonucu gözlenmemiş işlem için beklenen sonucu raporlama.

---

## 3. Rule-to-Check Traceability

`Gate-enforced` denilen her required invariant için şu zincir gösterilir:

`requirement → actual check/assertion → input/branch → executed result`

* Test adı, yorum, etiket, sınıflandırma veya toplam sayı tek başına gerçek invariant kontrolü değildir.
* Validator/gate eklendiğinde veya değiştiğinde ilgili kuralı bozan negatif örneğin reddedildiğini, geçerli örneğin kabul edildiğini doğrula.
* Başka araca devredilen kontrol için o aracın exact assertion/fail yolunu göster. Kuralların yalnız bir bölümünün kapsanması full coverage değildir.
* Bir veri türünü gate dışında bırakmak yalnız ilgili doğrulama başka bir kontrol tarafından tam kapsanıyorsa kabul edilir. Bilinmeyen/bozuk girdinin discriminator veya bypass dalından sessizce geçmesini negatif örneklerle kontrol et.
* Sonlu bir veri setindeki her kayda uygulanması gereken hard invariant, birkaç örnek incelemekle enforce edilmiş sayılmaz. Örnekleme yalnız authority'nin örneklemeye izin verdiği kalite kriterlerinde kullanılır.
* Yanlış kanıt atfı delivery artifact'ında düzeltilir. Gerçek alternatif kanıt tam ise bu rapor düzeltmesidir; eksikse açık validation/rework task'ıdır.

---

## 4. Startup / Cold-Boot Gate

Çalıştırılabilir bir bileşenin başlangıç akışını etkileyen entry point, bağımlılık kurulumu, config/SDK initialization, persistence açılışı, root navigation veya lifecycle değişikliklerinde uygulanır.

1. Authority'deki canonical komutla ilgili bileşeni başlat.
2. Değişen kritik başlangıç bağımlılıklarını atlamayan gerçek çalışma yolunu kullan.
3. Authority'nin tanımladığı ready/health/UI state veya başarılı komut sonucunu gözle.
4. Beklenmeyen initialization hatası olmadığını doğrula.
5. Kalıcı state etkileniyorsa izole test ortamında boş state ve mevcut state ile yeniden açılışı ayrı doğrula.

Hedef bileşene göre process, CLI, container, browser, simulator/device veya uygun host harness kullanılır. Saf kütüphane, doküman veya statik asset teslimine ilgisiz bir app boot şartı eklenmez. İlgisiz bağımlılık izolasyonu mümkündür; doğrulanan kritik yolun atlanmadığı açıklanır.

Unit/component testi, gerçek başlangıç yolunu veya kritik boundary'yi atlıyorsa bu gate'i kapatmaz. Build PASS yeterli değildir. Required ortam yoksa `Runtime Validation Pending` kaydedilir.

---

## 5. Pending Evidence Ledger

Her required pending scenario ayrı item olur:

* Evidence ID ve scenario/invariant
* Required evidence class ve execution target
* Owner role
* Prerequisite / external decision ve yeniden değerlendirme tetikleyicisi
* Engellediği feature/status/dependency
* Sonuç: PENDING / PASS / FAIL

Owner, bileşen ve doğrulama türüne göre seçilir: ilgili developer çalışma yolunu/araçlarını hazırlar; QA kabul kriterlerini değerlendirir; CI/deployment görevi release rolüne gider. Ürün kabulü Product Owner veya kapsamı kayıtlı kullanıcı kararına bağlıdır.

Bir kontrolün prerequisite'i bağımsız başka bir kontrolü bekletmez. Farklı scenario'lar tek belirsiz bekleme maddesinde birleştirilmez.

---

## 6. Change Impact & Deferred Validation

* İçerik/veri/config/schema/dependency güncellemesi, uygulama kodu değişmese de davranışı ve önceki approval'ın geçerliliğini etkileyebilir.
* Geçici veri veya eksik ortam nedeniyle ertelenmiş kontrolün prerequisite'i sağlandığında ilgili task yeniden değerlendirilir. `Deferred` yorumu yeni koşul altında otomatik muafiyet değildir.
* Ortak runtime, veri veya araç yolundaki eksik kanıt aynı yolu kullanan downstream feature'da görünür kalır.
* Bağımsız kapsam ilerleyebilir; bağımsızlık somut component/path ve criterion bazında açıklanır.
* Reconciliation aynı testleri gerekçesiz tekrar çalıştırmayı gerektirmez; geçerli evidence kullanılır. Değişen veya şüpheli kapsam için hedefli doğrulama yapılır.

---

## 7. Independent Verdicts

* `Full contract honored` yalnız tüm required criterion ve evidence tamamlandığında söylenir.
* `No defect observed` yalnız incelenen kapsam için geçerlidir; eksik kanıtı gizlemez.
* `Approved with Notes` missing required evidence'i kabul etme yolu değildir.
* Release scope varsa functional QA yalnız kendi stage'inin kriterlerini kabul eder ve `Functional Approved` verir. Authority'de açıkça sonraya planlanan release kanıtı final stage'de zorunludur; bu ayrım eksik functional runtime kanıtını ertelemez. Final approval bütün required kapsamı içerir.
* Tech Lead'in delivery kabulü, önceki QA approval'ı veya root-cause tahmini yeni QA verdict'ini belirlemez. QA çelişen kanıta dayanarak finding açabilir.
* “Başka yerde kontrol ediliyor”, “önceden kabul edildi”, “kod değişmedi” veya “bulgu açma” yönlendirmesi somut doğrulama zorunluluğunu kaldırmaz.
* Product requirement değişikliği Product Owner revision; teknik doğrulama yöntemi değişikliği ilgili contract authority üzerinden, gerekçesi ve downstream etkisiyle kaydedilir. Eksik kanıt rapor notuna dönüştürülerek kapatılamaz.
