# {feature-id} — {feature-name}: Orchestration

> Status: TEMPLATE / STRUCTURE ONLY
>
> Bu dosya sekil sablonudur. Execution semantics, active feature/task resolution, local/global state ownership ve terminal cleanup kurallarini normatif olarak tanimlamaz; bunlar `role-execution-contract.md` icinde yasar.

---

## Usage Rules

* Minimum required sections:
  * Current Status
  * Current Owner
  * Active Task Ledger
  * Open Tasks
  * Blockers
  * Last Decision
  * Last Update
  * Next Role
  * Next Action
  * Change Log
* Optional sections:
  * Current Phase
  * Consumed Signals
  * Rework Plan
* `ai-system/role-execution-contract.md` bu dosyanin execution semantics authority'sidir
* `feature-board.md` ve `system-state.md` global state yuzeyleridir; authoritative sync Tech Lead tarafindan yapilir
* Default sablon minimum yuzey tasir; agir QA tracking, completed-task mirror veya delivery recap bolumleri ancak gercek ihtiyac varsa ayri artifact'ta tutulur
* UI Designer / Backend / Frontend / Game Developer (Unity) / DevOps/Release Engineer / QA handoff verilecek her feature'da feature-level `architecture.md` bulunmalidir
* Contract baska feature'dan devraliniyorsa bile feature-level `architecture.md` icine inherited contract ozeti yazilir
* Sablon mumkun oldugunca yalin tutulmali; tarihsel veya artik kullanilmayan checklist'ler ayri archive/reference yuzeylerine tasinmalidir

---

## Current Status

**Not Started / In Progress / In QA / In Release / Rework / Done / Blocked**

---

## Current Owner

* Tech Lead
* Technical Analyst
* UI Designer
* Backend Developer
* Frontend/Mobile Developer
* Game Developer (Unity)
* DevOps/Release Engineer
* QA
* Project Setup

---

## Active Task Ledger

Kural:
* Bu bolum `Run [Role]` icin authoritative run queue'dur
* Her item exact canonical role label tasir
* Bir rol once bu bolumu okur; `Open Tasks` yalniz fallback'tir
* Feature terminal ise deger `None` olmalidir

Ornek:

- [ ] Task ID: {feature-id}.2-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: API mapping + state wiring
- [ ] Task ID: {feature-id}.3-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: error/loading UX parity

Client stack Unity/mobil oyunsa Assigned Role = Game Developer (Unity) kullanilir (Frontend/Mobile Developer degil):

- [ ] Task ID: {feature-id}.2-GD | Assigned Role: Game Developer (Unity) | Status: Open | Summary: gameplay sistem + save data wiring

---

## QA Scope

* backend-only / client-only / end-to-end / ui-handoff-compliance

Kural:
* Tech Lead bu alanı QA handoff öncesi açıkça yazar
* `client-only`, client stack'e göre `frontend.md` veya `game-dev.md` üzerinden değerlendirilir
* QA bu alanı esas alır; alanın boş olması durumunda mevcut artifact'lara (backend.md, frontend.md, game-dev.md, ui-design.md) bakarak kendi scope kararını üretir ve bunu QA output başına yazar

---

## Release Scope

* none / ci-cd-only / container-build / deploy-development / deploy-test / deploy-preview / staging / production-readiness / rollback-readiness

Kural:
* Tech Lead bu alani yalniz release/deployment gate gerekiyorsa doldurur
* `none` ise DevOps/Release Engineer handoff'u verilmez
* Production deployment gerektiren durumlarda release authority ve explicit approval olmadan deploy yapilmaz

---

## Current Phase (Optional)

* Planning / Analysis / UI Design / Backend Development / Frontend Development / Game Client Development / Integration / QA / Release / Rework / Closed

Not:
* Bu alan opsiyoneldir; yalniz gercekten anlamliysa tutulur

---

## Open Tasks

Kural:
* Bu bolum task inventory'dir
* Actionable routing icin once `Active Task Ledger` kullanilir
* Code block, closeout checklist, archived brief veya changelog icindeki unchecked item'lar task sayilmaz

### Analysis
- [ ] ({feature-id}.0-AN) Description

### UI Design
- [ ] ({feature-id}.0-UI) Screen goal, visual hierarchy, layout structure ve state handoff
- [ ] ({feature-id}.1-UI) Component blueprint ve CTA onceligi

### Backend
- [ ] ({feature-id}.1-BE) Description
- [ ] ({feature-id}.2-BE) Description

### Frontend
- [ ] ({feature-id}.1-FE) Description
- [ ] ({feature-id}.2-FE) Description

### Game Client (Unity — client stack Unity/mobil oyunsa; Frontend yerine kullanilir)
- [ ] ({feature-id}.1-GD) Description
- [ ] ({feature-id}.2-GD) Description

### Integration
- [ ] ({feature-id}.1-INT) Backend-Frontend mapping dogrulama
- [ ] ({feature-id}.2-INT) End-to-end flow dogrulama

### QA
- [ ] ({feature-id}.1-QA) Acceptance Criteria + contract dogrulama
- [ ] ({feature-id}.2-QA) Kritik user journey + misuse / permission dogrulama
- [ ] ({feature-id}.3-QA) State transition, recovery path ve runtime risk dogrulama
- [ ] ({feature-id}.4-QA) UI handoff uyumu kontrolu (varsa `ui-design.md`)

### Release
- [ ] ({feature-id}.1-REL) CI/CD gate ve release readiness dogrulama
- [ ] ({feature-id}.2-REL) Deployment runbook, rollback ve smoke validation plani

---

## Rework Plan (Optional)

Not:
* Bu bolum yalniz feature `Rework` durumundayken veya yakin rework routing'i varsa tutulur

### Root Cause
* Backend
* Frontend
* Game Client (Unity)
* DevOps / Release
* Integration
* Contract
* State / Flow
* UI Design

### Fix Plan
1. ...
2. ...
3. QA

### Current Rework Owner
* ...

### Scope Lock
* User-visible symptom:
* Affected journey:
* Entry paths to retest:
* Forbidden / misuse paths to retest:
* Required runtime evidence:
* Exit criteria:

---

## Blockers

* None / Description:
  * Owner:
  * Impact:

---

## Last Decision

* Tarihli son kararlar
* Son contract / scope / rework karari

---

## Consumed Signals (Optional)

Kural:
* Bu bolum yalniz upstream artifact bilgisi authoritative dosyaya tasindiginda tutulur
* Okuma optimizasyonu saglar; execution, contract veya product authority uretmez
* Source artifact silinmez veya gecersiz sayilmaz
* Unresolved question varsa downstream roller ilgili source artifact bolumunu okuyabilir

Ornek:

* analysis.md consumed into architecture.md on YYYY-MM-DD.
* Downstream roles must use architecture.md unless unresolved questions below are relevant to their task.
* Unresolved analysis questions: None

---

## Last Update

* Updated By:
* Timestamp:
* Summary:

---

## Next Role

* Tech Lead
* Technical Analyst
* UI Designer
* Backend Developer
* Frontend/Mobile Developer
* Game Developer (Unity)
* DevOps/Release Engineer
* QA
* Project Setup
* Closed

---

## Next Action

### {Next Role}

```text
Buraya bir sonraki rol icin net gorev yazilir
```

Kural:
* Eger feature `Done` ise bu alan completed role'a geri donmez
* Eger terminal durumdaysa deger `Closed` olur

---

## Change Log

* v1: initial orchestration
