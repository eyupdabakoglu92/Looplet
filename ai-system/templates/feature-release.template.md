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

| Gate | Result | Evidence / Notes |
| --- | --- | --- |
| Build | PASS / FAIL / NOT CONFIGURED / N/A | |
| Test | PASS / FAIL / NOT CONFIGURED / N/A | |
| Lint | PASS / FAIL / NOT CONFIGURED / N/A | |
| Typecheck | PASS / FAIL / NOT CONFIGURED / N/A | |
| Security | PASS / FAIL / NOT CONFIGURED / N/A | |
| Container Build | PASS / FAIL / NOT CONFIGURED / N/A | |
| Container Smoke | PASS / FAIL / NOT CONFIGURED / N/A | |
| Deploy Preview / Staging | PASS / FAIL / NOT CONFIGURED / N/A | |
| Smoke | PASS / FAIL / NOT CONFIGURED / N/A | |
| Rollback | PASS / FAIL / NOT CONFIGURED / N/A | |

---

## 10. Release Risks

* Blocking:
* Non-blocking:

---

## 11. Release Readiness Verdict

* Release Ready / Release Ready with Notes / Release Blocked / Release Validation Pending

---

## 12. Sonraki Komut

Routing authority: `orchestration.md -> Next Role`.

1. `Next Role` acikca bir role atanmissa:

```text
Run [Role]
```

2. `Next Role` bos veya `None` ise:

```text
Run Tech Lead
```

Not:

* Release readiness sonrasi genellikle `Run Tech Lead` uretilir.
* Pre-QA CI/CD config turunda `orchestration.md -> Next Role` esas alinir.
