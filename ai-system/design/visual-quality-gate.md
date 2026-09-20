# Visual Quality Gate

> Status: NORMATIVE / REUSABLE CORE

Bu standart kullanıcıya görünen işler için görsel kaliteyi fikirden gerçek runtime'a kadar kanıt zinciriyle yönetir. `design-doctrine.md` hedefi, `premium-ui-rubric.md` puanlamayı, bu dosya ise geçiş kapılarını tanımlar.

---

## 1. Scope Classification

Tech Lead her yeni veya yeniden açılan feature için `orchestration.md` içinde bir `Visual Scope` seçer:

* `none` — kullanıcıya görünen çıktı yok
* `existing-parity` — seçilmiş design system/pattern birebir genişletiliyor
* `new-surface` — yeni ekran, akış veya anlamlı yeniden tasarım
* `motion-critical` — hareket, VFX, audio veya haptic ürün kalitesinin önemli parçası
* `design-system` — proje çapı görsel sistem kuruluyor/değişiyor

`existing-parity`, kanıtı atlamak için kullanılamaz. Yalnız exploration sayısını azaltabilir; referans yüzey ve runtime parity yine zorunludur.

---

## 2. Gate Stages

### Foundation Gate

`new-surface`, `motion-critical` veya `design-system` kapsamda `/ai-system/project-authority/design-foundation.md` `Selected` olmalıdır. Dosya yoksa UI Designer'ın ilk görevi foundation üretmektir; implementasyon başlamaz.

### Exploration Gate

* En az iki maddi olarak farklı direction gerçek görsel artefact olarak render edilir.
* Karşılaştırma aynı kritik screen/state/content üzerinden yapılır.
* UI Designer önerir; kullanıcı, Product Owner veya yetkilendirilmiş Tech Lead seçimi kaydeder.
* Text-only açıklama, ASCII wireframe veya token listesi yeterli değildir.

`existing-parity` için iki yeni direction yerine seçilmiş foundation ve canonical sibling/reference capture kullanılabilir. Sapma varsa yeniden exploration gerekir.

### Handoff Gate

`ui-design.md` şunları içermeden implementasyona hazır değildir:

* screen/state/viewport matrisi
* component, typography, color, asset ve interaction kararları
* motion spec veya açık `not applicable` gerekçesi
* source render/prototype kayıtları
* Visual Evidence Manifest
* seçimin karar kaydı

### Implementation Parity Gate

Frontend/Mobile Developer veya Game Developer (Unity):

* canonical simulator/device/browser/game target'ı çalıştırır
* aynı viewport ve state'lerde gerçek capture üretir
* source render ile yan yana karşılaştırır
* açıklanamayan sapmaları düzeltir veya blocker olarak Tech Lead'e taşır
* `frontend.md` / `game-dev.md` içinde `Visual Parity Evidence` yazar

Static capture motion kanıtı değildir. Motion-critical kapsam video/screen recording veya çalıştırılabilir prototype ister.

### Independent QA Gate

QA:

* self-score'u yeniden kullanmaz; gerçek runtime'ı bağımsız puanlar
* `premium-ui-rubric.md` 10 boyutunu ayrı puanlar
* final score, minimum-dimension ve fail-condition sonucunu yazar
* 93 altını mandatory rework yapar
* eksik runtime/motion kanıtında `Runtime Validation Pending` verir

---

## 3. Orchestration Values

`Visual Quality Gate` yalnız şu değerlerden biri olabilir:

* `Not Required`
* `Pending`
* `Ready for Implementation`
* `Ready for QA`
* `Passed`

Geçişler:

* `none` → `Not Required`
* Foundation + exploration + handoff tamam → `Ready for Implementation`
* runtime parity evidence tamam → `Ready for QA`
* bağımsız QA 93+, her boyut ≥8, fail condition yok → `Passed`

Bir role ait metinsel tamamlandı beyanı gate değerini kendiliğinden ilerletmez; Tech Lead reconciliation sırasında kanıtı doğrular.

---

## 4. Visual Evidence Manifest

Her kayıt en az şu alanları taşır:

| Evidence ID | Kind | Screen / State | Viewport / Device | Artifact | Source Revision | Captured By | Captured At | Result / Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |

`Kind` örnekleri: `direction-render`, `selected-source`, `runtime-screenshot`, `runtime-video`, `parity-comparison`, `accessibility`.

Kurallar:

* Artifact görüntülenebilir gerçek path/link olmalıdır; “hazırlandı” yazısı kanıt değildir.
* Source revision commit, worktree revision veya açık working-tree provenance taşır.
* Generated/mock asset ile final asset ayrımı belirtilir.
* Eksik kanıt `PASS` değil `PENDING` olur.

---

## 5. Legacy Adoption

Eski canlı feature'larda visual alanların bulunmaması otomatik geçmiş reddi üretmez. Ancak:

* yeni feature
* yeniden açılan feature
* görsel rework
* core standardı sonrası yeni UI teslimi

Tech Lead tarafından yeni şemaya normalize edilir. Mevcut canlı artefact'lar starter template ile ezilmez.
