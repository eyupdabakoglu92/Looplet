# Feature Board (Template)

> Status: TEMPLATE / STARTER STATE
>
> Bu dosya yeni proje veya brownfield onboarding icin baslangic portfolio snapshot'idir. Canli projede placeholder alanlar temizlenmeli ve gercek feature listesi ile doldurulmalidir.

Last Updated: YYYY-MM-DD
Active Phase: —
Active Owner: -
Active Feature: -
Pending Product Revision: None
Revision Affected Features: None

---

## Status Table

| ID | Feature | Status | Owner | QA | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| F01 | {feature-name} | Not Started | - | - | P0 | {short note} |

Status set:

* Not Started
* In Progress
* In QA
* In Release
* Rework
* Done
* Blocked
* Closed

Owner set:

* Product Owner
* Tech Lead
* Technical Analyst
* Content Designer
* UI Designer
* Backend Developer
* Frontend/Mobile Developer
* Game Developer (Unity)
* DevOps/Release Engineer
* QA
* Project Setup
* -

---

## Priority Ordering & Rationale

1. `{feature-id}` — `{why first}`
2. `{feature-id}` — `{why second}`
3. `{feature-id}` — `{why third}`

---

## Optional Open Rework / Incidents

| ID | Title | Status | Scope | Priority |
| --- | --- | --- | --- | --- |
| {issue-id} | {issue-title} | Open | {scope} | P1 |

Not:

* Bu tablo yalniz acik ve aktif item'lar icin tutulur
* Kapali tarihsel incident'lar burada biriktirilmez
* Feature-level execution authority burada degil, ilgili `features/{feature-name}/orchestration.md` veya incident artifact'i icindedir

---

## Rules

* `feature-board.md` portfolio/state/priority gorunumudur
* detayli task breakdown burada tutulmaz
* global owner ve active phase bilgisi Tech Lead tarafindan senkron guncellenir
* Notes hucreleri current durumun kisa ozetidir; delivery chronology veya historical state burada biriktirilmez
* default size budget 24,000 baytdir; uzun tarihce `system-history.md` veya feature artifact'ina tasinir
