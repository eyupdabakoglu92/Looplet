# {feature-id} — {feature-name}: Orchestration

> Status: TEMPLATE / STRUCTURE ONLY
>
> Authority: role-execution-contract.md. Canlı dosyada placeholder ve kullanım açıklamalarını kaldır.

## Usage Rules

* Current Owner = Next Role = şimdi çalışacak rol. Teslim sonrası adım Handoff Plan'dadır.
* Ledger zorunludur; None mevcut boş kuyruktur, Open Tasks fallback'i değildir.
* Planlı successor task'ları dependency kontrolüyle aktive edilir; QA öncesi Tech Lead checkpoint gerekir.
* Blocked işleri korur. Yalnız Done/Closed terminal cleanup uygular.
* Yeni alanlar eski canlı dosyalara Tech Lead resync ile eklenir; audit otomatik dosya düzeltmez.
* Bütçe: varsayılan 40,000 bayt; uzun geçmiş ayrı history artifact'ına taşınır.
* QA Scope: none / backend-only / client-only / end-to-end / content-only; uygulanabilir compliance kapsamı eklenebilir.
* Current Phase, Consumed Signals ve Rework Plan yalnız gerekliyse ayrı bölümlerdir.

## Feature ID

{feature-id}

## Current Status

Not Started

## Current Owner

Tech Lead

## Next Role

Tech Lead

## Active Task Ledger

None

## Open Tasks

None

## Handoff Plan

None

## Delivery Review

Pending

## QA Scope

none

## QA Stage

none

## QA Result

None

## Release Scope

none

## Release Result

None

## Pending Evidence

None

## Open Decision Gates

None

## Blockers

None

## Last Decision

Initial planning.

## Last Update

* Updated By: Tech Lead
* Timestamp: YYYY-MM-DD
* Summary: Initial planning.

## Next Action

Resolve scope and create the first actionable task.

## Change Log

* Initial orchestration.

## Record Examples (Reference Only)

Canlı task/state değildir; gerçek kayıtları ilgili dedicated bölüme yaz.

```text
Active Task Ledger:
- [ ] Task ID: {feature-id}.1 | Assigned Role: Content Designer | Status: Open | Summary: İçerik teslimi | Depends On: -
- [ ] Task ID: {feature-id}.2 | Assigned Role: Frontend/Mobile Developer | Status: Queued | Summary: Entegrasyon | Depends On: {feature-id}.1

Handoff Plan:
| After Tasks | Next Role | Activate Tasks |
| --- | --- | --- |
| {feature-id}.1 | Frontend/Mobile Developer | {feature-id}.2 |

Pending Evidence:
- Evidence ID: {feature-id}.E1
  * Scenario: <behavior>
  * Required Class: <class>
  * Target / Environment: <target>
  * Owner Role: <canonical role>
  * Prerequisite / External Decision: <prerequisite or None>
  * Re-evaluation Trigger: <event>
  * Blocks: <stage/feature/status>
  * Result: PENDING

Open Decision Gates:
- Decision ID: {feature-id}.D1
  * Question: <decision>
  * Options / Trade-offs: <options>
  * Recommendation: <recommendation>
  * Blocks: <scope>
  * Blocking Scope: feature
  * Status: OPEN
  * Resolution: <decision when resolved>
  * Resolved At: <timestamp when resolved>
```
