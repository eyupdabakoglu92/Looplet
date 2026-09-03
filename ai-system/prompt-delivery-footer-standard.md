# Prompt Delivery Footer Standard

> Status: SHARED SUPPLEMENT / NON-AUTHORITATIVE
>
> Bu doküman delivery/verdict footer'larında tekrar eden ortak kuralları toplar. Execution semantics authority üretmez; normatif local/global ownership kuralları `role-execution-contract.md` içinde yaşar.

Last Updated: 2026-07-02

---

## Purpose

Bu dosya:

* delivery prompt'larda tekrar eden workflow footer kurallarını kısaltmak
* non-authoritative suggestion bloklarını tutarlı hale getirmek
* local orchestration update tekrarını azaltmak

---

## Shared Workflow Suggestion Rules

* Delivery veya verdict suggestion blokları **non-authoritative**'dir
* Suggestion blokları şu dört başlığı kullanır: `Completed Tasks`, `Remaining Tasks`, `Blockers`, `Status Suggestion`
* `feature-board.md` ve `system-state.md` üzerinde resmi workflow/state sync yalnız Tech Lead tarafından yapılır
* Current feature `orchestration.md` içindeki local execution alanları delivery rolü tarafından güncellenebilir
* Suggestion/verdict metni, aynı çıktı içindeki evidence, blockers ve unresolved conflict alanlarıyla çelişemez
* Unresolved authority conflict, açık blocker veya kısmi task varken tamamlandı sinyali verilmez

---

## Shared Local Execution Update Rules

Teslim tamamlandığında delivery rolü yalnız current feature `orchestration.md` içinde:

* kendi task'larını kapatır
* kendi role section'ındaki `Open Tasks` item'larını uygun şekilde kapatır
* kendi role'üne ait `Active Task Ledger` item'larını kapatır
* gerekiyorsa `Current Status` alanını teslim/verdict sonucu ile hizalar
* `Current Owner`, `Next Role` ve `Next Action` alanlarını sıradaki role göre hizalar
* gerekli `Blockers` senkronunu yapar
* `Change Log` içine tarihli teslim kaydı ekler

Kural:

* `feature-board.md` ve `system-state.md` dosyalarına dokunulmaz
* başka role ait task açıklamaları, contract authority veya Tech Lead kararları delivery rolü tarafından override edilmez

---

## Sonraki Komut Kuralı (ZORUNLU)

Her delivery rolü, teslim tamamlandığında kullanıcıya kopyalanabilir tek bir sonraki komut üretmek zorundadır.

Kurallar:

* Sonraki komut bu çıktının **son bölümüdür** ve zorunludur
* "WORKFLOW HANDOFF SUGGESTION" bölümündeki non-authoritative öneriyle karıştırılmaz; bu ayrı ve zorunludur
* Routing authority `orchestration.md → Next Role` alanıdır
* `orchestration.md → Next Role` açıkça bir role atanmışsa o rol geçerlidir; aksi hâlde her rolün kendi varsayılan sonraki rolü devreye girer
* **QA** ve **Technical Analyst** her zaman `Run Tech Lead` üretir — bu sabit; `orchestration.md` override edemez
* DevOps/Release Engineer, release readiness sonrasi global state sync gerekiyorsa `Run Tech Lead` uretir

Çıktı formatı:

```
## Sonraki Komut

Run [Role]
```

---

## Role-Specific Reminder

Bu standart, role-specific verdict mantığının yerini tutmaz.

Örnek:

* Backend/Frontend için status suggestion seçenekleri
* QA için verdict, root cause ve fix-order mantığı
* UI Designer için handoff readiness ve tasarım niyeti koruma notları

prompt içinde ayrıca kalmalıdır.
