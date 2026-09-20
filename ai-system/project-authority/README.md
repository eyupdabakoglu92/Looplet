# Project Authority Layer

> Status: STRUCTURE / PORTABILITY BOUNDARY
>
> Bu klasor, ai-system'in reusable prompt/core katmani ile mevcut repo'ya ozel technical authority katmani arasindaki siniri gorunur kilar.

---

## Purpose

Bu klasor:

* proje-ozel technical authority dosyalarini tek yerde toplar
* prompt'larin generic kalmasini destekler
* ai-system farkli bir projeye tasindiginda hangi dosyalarin degistirilmesinin beklendigini acikca gosterir

---

## Contains

* `platform.md`
  * proje capinda stack, contract, runtime, security, testing ve operational standardlar
  * client stack kararini kilitler: standart app client (`Frontend/Mobile Developer`) veya Unity mobil oyun (`Game Developer (Unity)`)
* `setup-manifest.md`
  * proje stack'ine ait scaffold/bootstrap recipe'leri ve operational setup adimlari
* `release.md`
  * proje capinda CI/CD, deployment, release, rollback, secrets/config ve observability authority'si
  * Unity/iOS app store distribution varsa Unity build, Xcode signing/archive, TestFlight, IAP catalog, ATT ve Privacy Manifest readiness authority'si
* `design-foundation.md`
  * proje çapında experience thesis, seçilmiş art direction, typography/color/asset/motion dili ve responsive/accessibility baseline'ı
  * `/templates/project-design-foundation.template.md` üzerinden UI Designer tarafından hazırlanır; lifecycle Tech Lead'de, seçim yetkisi kullanıcı/Product Owner veya açıkça yetkilendirilmiş Tech Lead'dedir
  * kullanıcı yüzeyi olmayan projelerde oluşturulması gerekmez

---

## Rules

* Shared role davranisi `ai-system/prompts/`, `prompt-*.md`, `role-execution-contract.md` ve `orchestration-template.md` altinda kalir
* Proje-ozel stack komutlari, scaffold recipe'leri, release policy'leri ve runtime operasyon ayrintilari prompt katmanina geri tasinmaz
* Proje-ozel marka, referans, renk, font ve art direction kararları reusable `design/` dosyalarına değil `design-foundation.md` içine yazılır
* Ai-system yeni bir projeye uyarlanirken bu klasorun dosyalari gozden gecirilir, gerekiyorsa tamamen degistirilir
* Bu klasor execution semantics authority uretmez; rol davranisini override etmez
* `platform.md` client stack'i Unity/mobil oyun olarak belirtiyorsa Frontend/Mobile Developer yerine Game Developer (Unity) kullanilir; iki client rol ayni feature'da eszamanli owner olmaz

---

## Adjacent Project-Specific Surfaces

Bu klasor disinda kalan ama yine proje-instance baglamina ait olan yuzeyler:

* `product/`
* `features/`
* `feature-board.md`
* `system-state.md`

Not:

* Bu yuzeyler aktif urun/workflow state'i tasir
* Bu klasor ise cross-feature technical authority ve setup authority tasir
