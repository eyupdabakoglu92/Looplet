# Prompt Input Authority Standard

> Status: SHARED SUPPLEMENT / NON-AUTHORITATIVE
>
> Bu doküman delivery ve review prompt'larında tekrar eden input authority omurgasını toplar. Normatif authority precedence ilgili prompt ve `role-execution-contract.md` ile birlikte okunur.

Last Updated: 2026-04-09

---

## Shared Input Authority Skeleton

Varsayılan authority omurgası:

* `architecture.md` contract authority'dir
* `orchestration.md` execution authority'dir
* `system-state.md` bağlam sağlar; tek başına contract veya task authority'sini override etmez

Prompt, gerekiyorsa buna ek role-specific authority yüzeyi ekleyebilir.

Örnek:

* `ui-design.md` visual/state authority
* `feature-board.md` bağlamsal feature görünürlüğü
* `project-authority/release.md` release/deployment authority

---

## Shared Conflict Handling Rules

Input'lar çeliştiğinde ortak minimum kurallar:

* endpoint / request / response / error formatı conflict'lerinde `architecture.md` kazanır
* task scope / current owner / next role conflict'lerinde `orchestration.md` execution authority olarak değerlendirilir
* canonical olmayan role label geçerli owner ataması sayılmaz
* prose stack/runtime/tooling ile mevcut codebase pattern'i çelişiyorsa sessiz re-platform yapılmaz
* çelişkili dokümanlar birleştirilip yeni contract uydurulmaz

---

## Role-Specific Reminder

Bu standart yalnız ortak authority omurgasını taşır.

Aşağıdakiler prompt içinde ayrıca kalmalıdır:

* QA için blocker/finding/approval sertliği
* Frontend için `ui-design.md` ile contract çelişkisi yorumu
* Backend için `feature-board.md` bağlam notu
