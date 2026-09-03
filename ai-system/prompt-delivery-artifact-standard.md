# Prompt Delivery Artifact Standard

> Status: SHARED SUPPLEMENT
>
> Bu doküman delivery artifact explainability beklentilerini ortaklaştırır. Execution semantics authority üretmez; ancak kendisine referans veren delivery prompt'ların zorunlu supplement'idir.

Last Updated: 2026-07-01

---

## Purpose

Bu dosya:

* Backend ve Frontend delivery artifact'larında tekrar eden explainability beklentilerini tek yerde toplar
* Tech Lead'in artifact'ı kodu baştan reverse-engineer etmeden okuyabilmesini hedefler
* "tamamlandı" sinyali ile "ne yapıldığı anlaşılabiliyor" sinyalini birbirinden ayırır

---

## Shared Delivery Explainability Rules

Bir delivery artifact yalnız "iş bitti" özeti değildir.

Artifact içinde açıkça görünür olmalıdır:

* her açık task için izlenebilir task-to-code karşılığı
* authority conflict veya override varsa hangi dokümanın kazandığı
* değişmeden kalan inherited / unchanged behavior
* test kanıtının task veya davranış bazında eşleştirilmesi

Tech Lead artifact'tan şu soruların cevabını çıkarabilmelidir:

* Hangi task hangi dosya/alan ile kapandı?
* Hangi authority kazanarak implementasyon yapıldı?
* Hangi mevcut davranış korunarak bırakıldı?
* Hangi test hangi kritik davranışı doğruladı?

---

## Brief-First / Scope-Gated Output Rules

Delivery artifact'ları brief-first yazılır:

* önce ne değiştiği ve hangi task'ın kapandığı görünür
* sonra yalnız gerçek sinyal taşıyan ek bölümler yazılır
* boş, N/A veya "Yok" dolgu bölümleri üretilmez

Her zaman korunması gereken bölümler:

* feature/release summary
* impacted veya implemented files
* task-to-code / task-to-config traceability
* contract veya release compliance
* test / gate evidence
* workflow handoff suggestion
* sonraki komut

Koşullu yazılması gereken bölümler:

* authority reconciliation — yalnız gerçek conflict, override veya authority drift varsa
* assumptions — yalnız teknik varsayım yapıldıysa
* missing / TODO — yalnız eksik iş veya takip işi varsa
* needs clarification — yalnız unresolved karar veya blocker varsa
* performance notes — yalnız performans davranışı değiştiyse veya risk varsa
* behavior preserved — yalnız inherited path, regression risk veya unchanged branch gerçekten etkilendiyse

Kural:

* Koşullu bölüm atlanıyorsa kalan bölüm numaraları yeniden düzenlenmez; referans stabilitesi korunur.
* Blocker, unresolved conflict veya partial delivery hiçbir zaman "token azaltma" gerekçesiyle atlanamaz.
* Scope dışı bilgi gerekiyorsa tek satır gerekçe yeterlidir; tablo veya placeholder üretme.

---

## Incomplete Delivery Signals

Aşağıdakiler eksik teslim sayılır:

* "tamamlandı" deyip hangi dosya veya davranışın değiştiğini göstermemek
* authority conflict'i sessiz geçmek
* unchanged path'leri hiç belirtmemek ve downstream role'de regression şüphesi bırakmak
* test geçti deyip hangi davranışın doğrulandığını söylememek

---

## Role-Specific Reminder

Shared explainability standardı ortak iskeleti tanımlar.

Role-specific ayrıntılar prompt içinde ayrıca kalmalıdır.

Örnek:

* Backend: handler / DTO / event / state-machine davranışı
* Frontend: screen / store / navigation / async mapping davranışı
