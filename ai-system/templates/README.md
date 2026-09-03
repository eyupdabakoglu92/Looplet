# Templates

> Status: STARTER KIT / NON-AUTHORITATIVE
>
> Bu klasor, yeni veya mevcut bir projeye `ai-system` kurarken kullanilacak baslangic dokumanlarini toplar. Bu dosyalar kopyalanip ilgili hedef path'e uyarlanmak icindir; kendi baslarina canli workflow authority uretmezler.

---

## Purpose

Bu klasor:

* greenfield proje baslangici icin temiz starter set saglar
* brownfield projeye sistem onboarding'i icin hizli baseline sunar
* canli proje snapshot'larini kopyalama ihtiyacini ortadan kaldirir

---

## Template Catalog

* `product-prd.template.md`
  * `product/product-prd.md` icin baslangic
* `project-platform.template.md`
  * `project-authority/platform.md` icin brownfield/manual referans
* `setup-manifest.template.md`
  * `project-authority/setup-manifest.md` icin baslangic
* `project-release.template.md`
  * `project-authority/release.md` icin baslangic
* `feature-board.template.md`
  * `feature-board.md` icin baslangic
* `system-state.template.md`
  * `system-state.md` icin baslangic
* `feature-prd.template.md`
  * `features/{feature-name}/prd.md` icin baslangic
* `feature-architecture.template.md`
  * `features/{feature-name}/architecture.md` icin baslangic
* `feature-analysis.template.md`
  * `features/{feature-name}/analysis.md` icin baslangic
* `feature-ui-design.template.md`
  * `features/{feature-name}/ui-design.md` icin baslangic; Unity projelerde meta ekran veya Game Visual/HUD Direction handoff'u icin de kullanilir
* `feature-release.template.md`
  * `features/{feature-name}/release.md` icin baslangic

Not:

* `features/{feature-name}/orchestration.md` icin ayri template yerine root seviyedeki `orchestration-template.md` kullanilir
* `project-platform.template.md` icindeki Client Type alani standart app client ile `game (Unity)` ayrimini belirler
* `project-release.template.md`, Unity/iOS app store distribution gerekiyorsa TestFlight, IAP, ATT ve Privacy Manifest readiness icin de doldurulur

---

## Greenfield Use

Yeni projede tipik sira:

1. `Run Product Owner. Yeni proje: <tanım>` ile `product/product-prd.md`, `feature-board.md` ve `system-state.md` uret.
2. Project Setup, backend veya build/test dogrulamasi gerekiyorsa `setup-manifest.template.md` -> `project-authority/setup-manifest.md`.
3. Release/deployment gate gerekiyorsa `project-release.template.md` -> `project-authority/release.md`.
4. `Run Tech Lead. Yeni proje bootstrap yap.` ile `project-authority/platform.md`, gerekiyorsa `project-authority/release.md` ve ilk feature dosyalarini uret.

Not:

* Greenfield'da `project-platform.template.md` kullanici tarafindan `platform.md` olarak doldurulmaz; Tech Lead PRD Section 12'yi baz alarak uretir
* Ilk feature icin `feature-prd.template.md`, `feature-architecture.template.md` ve `orchestration-template.md` yapisal referans olarak kalir; dosyalari Tech Lead uretir

---

## Brownfield Use

Mevcut projede tipik sira:

1. `Run Product Owner. Yeni proje: <mevcut ürün özeti>` ile `product/product-prd.md`, `feature-board.md` ve `system-state.md` uret
2. Gercek codebase'i inceleyerek `project-authority/platform.md` olustur
3. Backend, QA build/test gate'i veya canonical komut ihtiyaci varsa `setup-manifest.template.md` -> `project-authority/setup-manifest.md`
4. Release/deployment gate'i varsa mevcut pipeline ve hosting platformundan `project-release.template.md` -> `project-authority/release.md`
5. `Run Tech Lead. Brownfield onboarding yap.` ile ilk managed feature klasorunu ve authority dosyalarini uret

Not:

* Brownfield'da feature klasoru kullanici tarafindan acilmaz; Tech Lead `product-prd.md` ve `feature-board.md` uzerinden ilk managed feature'i secer
* `feature-prd.template.md`, `feature-architecture.template.md`, `feature-analysis.template.md` ve `feature-ui-design.template.md` yalniz yapisal referanstir

---

## Rules

* Template dosyalari canli snapshot yerine gecmez
* Placeholder alanlar temizlenmeden role execution baslatilmaz
* Proje-ozel kararlar prompt katmanina degil, `project-authority/`, `product/` ve `features/` katmanina yazilir
* Tarihsel bug, incident ve audit dosyalari starter pack'e dahil edilmez
