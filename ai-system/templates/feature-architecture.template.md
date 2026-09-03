# {feature-id} — {feature-name}: Architecture

> Status: TEMPLATE / CONTRACT AUTHORITY
>
> Bu dosya feature-level contract authority olarak kullanilir. Delivery artifact'lar veya QA notlari buradaki semantigi override etmez.

---

## Purpose

* Feature objective:
* Contract scope:
* Non-goals:

---

## Authorities & Inputs

* Upstream PRD:
* Inherited contracts:
* Project authority dependencies:

---

## Actors & Permissions

| Actor | Allowed Actions | Forbidden Actions | Notes |
| --- | --- | --- | --- |
| {actor} | {actions} | {forbidden} | {notes} |

---

## Entry / Exit Paths

### Allowed Entry Paths

* {entry path}
* {entry path}

### Exit / Completion Paths

* {exit path}
* {exit path}

### Invalid / Rejected / Terminal Paths

* {invalid path behavior}
* {invalid path behavior}

---

## Data / Domain Model

* Key entities/resources:
* Critical identifiers:
* Persistence rules:
* Reset / hydration rules:

---

## API / Event Contract

### Endpoints / Commands

* `{method}` `{path}` — `{purpose}`

### Events / Async Inputs

* `{event}` — `{purpose}`

### Request / Response Rules

* request semantics
* response semantics
* null / optional field rules

### Error Semantics

* `{error code}` — `{meaning}`

---

## Validation Responsibility

* Backend/service validation:
* Client validation:
* Ownership boundaries:

---

## State / Flow Semantics

* happy path
* boundary transitions
* ordering / queue / retry / timeout behavior
* no-op / duplicate / terminal-state behavior
* realtime / background / reconnect ownership

---

## Integration Rules

* backend -> frontend mapping
* actor/permission visibility
* stale payload protection
* navigation / route contract if applicable

---

## QA Focus

* acceptance criteria coverage
* critical user journey
* forbidden / misuse journey

---

## Release / Deployment Impact

* Release scope: none / ci-cd-only / container-build / deploy-development / deploy-test / deploy-preview / staging / production-readiness / rollback-readiness
* Required release gates:
* Environment/config impact:
* Migration/rollback impact:
* Observability/smoke validation impact:
* boundary matrix
* runtime evidence expectation

---

## Open Technical Decisions

* {decision}
* {decision}
