# Project Release Authority (Template)

> Status: TEMPLATE / PROJECT AUTHORITY
>
> Proje CI/CD, deployment, release, rollback veya operational readiness authority'si gerektiriyorsa `/ai-system/project-authority/release.md` olarak kopyalanir.

Last Updated: YYYY-MM-DD
Owner: Tech Lead

---

# 1. Purpose

* {release authority purpose}

---

# 2. Release Applicability

* Release gate required: {Yes / No / Conditional}
* Applies to: {backend / frontend / mobile / mobile app store distribution (Unity/iOS) / infra / data migrations / jobs}
* Conditional rule: {condition}

---

# 3. Environments

| Environment | Purpose | Deployment Mode | Approval Required | Notes |
| --- | --- | --- | --- | --- |
| local | developer workstation | manual | No | |
| development | shared development validation | automated/manual | No | |
| test | automated integration / QA validation | automated | No / Yes | |
| preview | PR validation | automated | No / Yes | |
| staging | release validation | automated/manual | Yes | |
| production | live users | controlled | Yes | |

---

# 4. CI/CD Gate Policy

Required gates:

* install / dependency restore
* lint
* typecheck
* unit tests
* integration tests
* e2e / smoke tests
* build
* security scan
* dependency audit
* migration dry-run
* artifact/container build

Gate rule:

* Required gate fail -> release blocked
* Required gate missing -> release validation pending
* Optional gate missing -> note with owner

---

# 5. Branch / Version / Promotion Strategy

* Branch strategy: {strategy}
* Versioning strategy: {strategy}
* Artifact naming: {strategy}
* Promotion path: {path}
* Release notes source: {source}

---

# 6. Deployment Strategy

* Provider / platform: {provider}
* Deployment command or pipeline: {command/job}
* Rollout strategy: {all-at-once / rolling / blue-green / canary / manual}
* Feature flag strategy: {strategy}
* Migration strategy: {strategy}
* Backward compatibility rule: {rule}

Containerization / runtime packaging:

* Containerization required: {Yes / No / Conditional}
* Dockerfile path(s): {path or N/A}
* Compose file(s): {path or N/A}
* Image build command/job: {command/job}
* Container run/smoke command: {command}
* Registry / artifact destination: {registry or N/A}
* Image tag strategy: {strategy}
* Container scan policy: {policy}

Mobile app store distribution (client stack Unity/mobil oyunsa):

* Build pipeline: {Unity batchmode command or CI job}
* Xcode archive/export ve code signing sahibi: {owner}
* Provisioning profile / certificate kaynagi: {isim, deger degil}
* TestFlight dagitim policy: {policy}
* App Store Connect metadata sahibi: {owner}
* IAP product catalog senkron sorumlusu: {owner}
* Privacy Manifest (PrivacyInfo.xcprivacy) guncelleme sorumlusu: {owner}
* ATT usage description sahibi: {owner}
* dSYM/symbol upload: {policy or N/A}

---

# 7. Secrets & Configuration

Rules:

* Secret values are never stored in repo
* Required secrets are documented by name only
* Environment-specific config must be validated before deploy
* Development, test, staging and production config names must be documented separately when they differ

Required secrets / env vars:

| Name | Environment | Owner | Purpose | Required |
| --- | --- | --- | --- | --- |
| {SECRET_NAME} | {env} | {owner} | {purpose} | Yes |

---

# 8. Observability & Health

* Health check endpoint / command: {check}
* Readiness check: {check}
* Smoke test: {test}
* Logs: {log policy}
* Metrics: {metrics}
* Traces / correlation id: {trace policy}
* Dashboards: {dashboards}
* Alerts: {alerts}

---

# 9. Rollback / Recovery

* Rollback trigger: {trigger}
* Rollback command: {command}
* Data rollback / forward-fix policy: {policy}
* Recovery time objective: {target}
* Owner: {owner}
* Verification after rollback: {steps}

---

# 10. Supply Chain & Artifact Integrity

* Lockfile policy: {policy}
* Dependency audit policy: {policy}
* Artifact provenance/signing: {policy}
* Container/image scan: {policy}
* Third-party action/package pinning: {policy}

---

# 11. Release Evidence Requirements

Each release artifact must include:

* gate results
* exact command/job and environment target
* exit/result/pass-fail-skip counts
* verified run id, URL, log or artifact provenance
* mock/stub/override, `continue-on-error`, quarantine ve skip sınırları
* deploy ve dry-run evidence'ının ayrı sınıflandırılması
* smoke/health evidence
* rollback plan
* unresolved risks

Pipeline config veya test wiring çalıştırılmış kanıt değildir. Allowed-failure/non-blocking job içeren green pipeline tek başına PASS sayılamaz; required check'in kendi sonucu ve skip durumu doğrulanır. Release policy blocking gate istiyorsa bu config koşulu ayrıca sağlanmalıdır.

---

# 12. Change Management

* Owner: {owner}
* Approval policy: {policy}
* Incident escalation path: {path}
* Active feature reassessment rule: {rule}
