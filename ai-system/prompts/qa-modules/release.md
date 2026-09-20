# QA Module — Release

Bu modül release, deployment, CI/CD, container, environment, migration rollout, secret/config ownership veya observability scope'unda seçilir. QA production deploy yapmaz ve release authority'yi override etmez.

## Required inputs

* `project-authority/release.md`
* `features/{feature-name}/release.md`
* orchestration `Release Scope`, `Release Result` ve current `QA Stage`
* ilgili CI/build/deploy/smoke evidence

## Stage semantics

* Functional QA'da açıkça sonraya planlanmış release artifact henüz yok diye feature defect üretme. Functional required evidence yine zorunludur.
* Final QA ve `Release Scope != none` ise `Release Result = Release Ready` veya `Release Ready with Notes` ve aynı source/delivery fingerprint'i kapsayan release evidence zorunludur.
* Release change functional davranışı etkilediyse ilgili functional evidence invalidated olur ve yeniden doğrulanır.

## Required checks

Yalnız scope'a uygulanabilenler:

* CI build/test/lint/typecheck/security/e2e/smoke gates
* container build/run/smoke
* preview/staging runtime validation
* migration rollout ve rollback/forward-fix
* secret/env isimleri değer sızdırmadan belgeli mi
* health/readiness/smoke/observability sinyalleri
* source revision, artifact digest ve target/environment provenance

Release evidence eksikliği bir uygulama bug'ı değilse core `Tech Lead Note` içinde workflow/release blocker olarak ayır. Required runtime/release evidence eksikse `Runtime Validation Pending`; authority/onay eksikse `Decision Pending`.

## Output — Release Compliance

Exact başlık:

```text
## Release Compliance
```

| Applicable Control | Evidence IDs | Result | Notes |
| --- | --- | --- | --- |

Alakasız gate'ler için N/A satırı üretme.
