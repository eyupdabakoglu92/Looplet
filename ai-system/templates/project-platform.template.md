# Project Platform Authority (Template)

> Status: TEMPLATE / PROJECT AUTHORITY
>
> Bu dosya yeni projede proje-capinda teknik stack, contract ve runtime authority tanimlamak icin kullanilir. Shared prompt davranisini burada tekrar yazmayin; yalniz proje-instance teknik kararlarini tutun.

Last Updated: YYYY-MM-DD
Owner: Tech Lead

---

# 1. Purpose

Bu dokuman:

* proje capinda teknik standartlari kilitler
* cross-feature consistency saglar
* runtime ve contract authority olarak kullanilir

---

# 2. Global Rules

* Bu kararlar tum feature'lar icin gecerlidir
* Backend, Frontend/Mobile Developer veya Game Developer (Unity), DevOps/Release Engineer, Project Setup ve QA bu kurallara uyar
* Degisirse aktif feature impact analizi gerekir

---

# 3. Application Stack

## Backend / Services

* Language: `{language}`
* Runtime: `{runtime}`
* Framework: `{framework}`
* Architecture Style: `{style}`
* Data Layer: `{database / orm / cache}`

## Frontend / Clients

* Client Type: `{web / mobile / desktop / game (Unity)}`
* Framework: `{framework}`
* State Management: `{state strategy}`
* Navigation / Routing: `{routing strategy}`

Client Type `game (Unity)` ise:

* Client implementasyonu Frontend/Mobile Developer yerine Game Developer (Unity) tarafından yapılır
* Unity Version: `{unity version}`
* Render Pipeline: `{built-in / URP / HDRP}`
* Target iOS Version: `{minimum iOS version}`
* IAP Provider: `{Unity IAP / StoreKit / none}`
* ATT Kullanımı: `{evet/hayır — tracking yapan SDK var mı}`
* App Store submission, code signing ve TestFlight authority `project-authority/release.md`'dedir

---

# 4. API & Contract

## API Style

* `{REST / GraphQL / RPC / events / mixed}`

## Versioning Strategy

* `{strategy}`

## Contract Rules

* field naming
* null / undefined semantics
* date/time format
* breaking vs additive change policy

## Error Format

```json
{
  "code": "{ERROR_CODE}",
  "message": "Human readable description",
  "details": []
}
```

---

# 5. Data & Persistence

* primary data store
* cache / ephemeral state
* migration strategy
* transaction strategy
* idempotency / concurrency rules

---

# 6. Auth / Session / Permissions

* authentication strategy
* authorization boundaries
* token/session lifecycle
* permission ownership rules

---

# 7. Runtime / Realtime / Background Processing

* eventing / websocket / queue / polling strategy
* reconnect / retry rules
* timeout rules
* lifecycle ownership rules

---

# 8. Observability & Security

* logging
* monitoring / health checks
* tracing / correlation id
* input validation
* secrets handling
* rate limiting / abuse controls

---

# 9. Release / Deployment Boundary

* Release, deployment, rollback, CI/CD gate and environment promotion authority lives in `/ai-system/project-authority/release.md`
* Platform decisions here must not duplicate provider-specific release policy unless they are stack/runtime constraints
* Containerization/runtime packaging authority lives in `/ai-system/project-authority/release.md` unless the decision is a stack/runtime constraint

---

# 10. Testing Strategy

* backend/service testing
* client testing
* integration / e2e expectations
* QA runtime expectations

---

# 11. Cross-Cutting Rules

* naming rules
* date/time rules
* localization rules
* shared identifiers / enum synchronization

---

# 12. Change Management

* owner
* impact analysis rule
* active feature reassessment rule
