# Prompt Input Integrity Standard

> Status: SHARED SUPPLEMENT / NON-AUTHORITATIVE
>
> Bu doküman input completeness ve inherited contract clarity ile ilgili tekrar eden kuralları toplar. Contract authority yine ilgili prompt ve `role-execution-contract.md` referanslarıyla birlikte değerlendirilir.

Last Updated: 2026-04-09

---

## Shared Input Integrity Rules

* `architecture.md` contract authority'dir
* Eğer contract başka bir feature'dan devralınıyorsa bu bilgi `architecture.md` veya `orchestration.md` içinde açıkça yazılmış olmalıdır
* Zorunlu input'lardan biri eksikse veya contract authority net değilse API/flow uydurulmaz

---

## Escalation Reminder

Input integrity bozulduğunda rol kendi başına eksik contract'ı tamamlamaz.

Role-specific prompt içinde tanımlı sonuç uygulanır.

Örnek:

* implementasyona başlamama
* tasarım handoff üretmeme
* `Needs Tech Lead Clarification` altında blocker yazma

