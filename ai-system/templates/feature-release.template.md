# {feature-id} — {feature-name}: Release Readiness

> Status: TEMPLATE / FEATURE ARTIFACT
>
> Bu dosya explicit release, CI/CD, deployment veya operational readiness task'i olan feature'larda `Run DevOps/Release Engineer` tarafindan uretilir.

Last Updated: YYYY-MM-DD
Owner: DevOps/Release Engineer

---

## 1. Feature / Release Summary

* Release scope:
* Environment target:
* Release objective:

---

## 2. Impacted Files

* {file}

---

## 3. Release Authority Reconciliation

* `project-authority/release.md`:
* `project-authority/platform.md`:
* `project-authority/setup-manifest.md`:
* `qa.md` verdict impact:
* Conflicts:

---

## 4. CI/CD Pipeline Plan

| Job | Trigger | Commands | Gate Effect | Failure Behavior |
| --- | --- | --- | --- | --- |
| {job} | {trigger} | {commands} | {required/optional} | {behavior} |

---

## 5. Environment & Config

| Name | Environment | Owner | Purpose | Required |
| --- | --- | --- | --- | --- |
| {SECRET_OR_ENV_NAME} | {env} | {owner} | {purpose} | Yes |

Environment coverage:

* local:
* development:
* test:
* preview:
* staging:
* production:

Containerization:

* Dockerfile path(s):
* Compose file(s):
* Image build command/job:
* Container run/smoke command:
* Registry / artifact destination:
* Image tag strategy:
* Container scan policy:

---

## 6. Deployment Plan

* Target environment:
* Image build / publish / pull expectation:
* Deployment command / job:
* Migration handling:
* Rollout strategy:
* Approval requirement:

---

## 7. Rollback Plan

* Rollback trigger:
* Rollback command / procedure:
* Data rollback / forward-fix:
* Verification:

---

## 8. Observability & Smoke Validation

* Health check:
* Smoke test:
* Logs:
* Metrics:
* Alerts:

---

## 9. Gate Evidence

Yalnız applicable gate'leri yaz; N/A satırı doldurma.

| Gate / Claim | Evidence Class | Command / Job | Target / Environment | Result / Exit / Counts | Provenance / Run ID / Artifact | Isolation / Skips |
| --- | --- | --- | --- | --- | --- | --- |
| {applicable gate} | {class} | {actually executed command/job} | {target} | {result} | {provenance} | {none or limits} |

---

## 10. Release Risks

* Blocking:
* Non-blocking:

---

## 11. Release Readiness Verdict

* Release Ready / Release Ready with Notes / Release Blocked / Release Validation Pending

---

## 12. Sonraki Komut

Release sonucu local Release Result alanına yazılır; owner/next Tech Lead'e geçirilir. Release Ready final QA veya Done değildir.

```text
Run Tech Lead
```
