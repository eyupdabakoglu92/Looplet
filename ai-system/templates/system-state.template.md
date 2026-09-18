# System State (Template)

> Status: TEMPLATE / GLOBAL SNAPSHOT
>
> Bu dosya canli workflow icin global snapshot surface'idir. Project-specific technical detaylarin tamami burada tutulmaz; stack ve operasyon authority'si `project-authority/` altinda yasamalidir.

Last Updated: YYYY-MM-DD

---

# 1. SYSTEM INITIALIZATION

## Platform Initialized

* Yes / No

## Environment Status

* Initialized / Partial / Blocked

---

# 2. AUTHORITY REFERENCES

## Technical Authority

* `/ai-system/project-authority/platform.md`

## Setup Authority

* `/ai-system/project-authority/setup-manifest.md`

## Release Authority

* `/ai-system/project-authority/release.md`

## Product Authority

* `/ai-system/product/product-prd.md`

---

# 3. PRODUCT STATE

## PRD

* Exists: Yes / No
* Path: `/ai-system/product/product-prd.md`

---

# 4. FEATURE SYSTEM STATE

## Source of Truth

* Feature Board = PRIMARY
* Orchestration = EXECUTION
* System State = GLOBAL SNAPSHOT
* Tech Lead state transition'da uc yuzeyi birlikte senkronlar

## Active Feature

* {feature-id} / —

## Active Orchestration Path

* `/ai-system/features/{feature-name}/orchestration.md` / —

---

# 5. WORKFLOW STATE

## Current Phase

* Planning / Analysis / Content Design / UI Design / Backend Development / Frontend Development / Game Client Development / Integration / QA / Release / Rework / —

## Current Role

* Tech Lead / Technical Analyst / Content Designer / UI Designer / Backend Developer / Frontend/Mobile Developer / Game Developer (Unity) / DevOps/Release Engineer / QA / Project Setup / —

## Current Reason

* {short explanation}

## Last Completed Action

* {role + date + short summary}

## Next Expected Action

* {short next step}

---

# 6. CROSS-FEATURE STATUS

## Portfolio Summary

* {short portfolio snapshot}

## Active Rework

* {if any}

## Paused Features

* {if any}

## Blocked Features

* {if any}

---

# 7. GLOBAL CONTRACT SNAPSHOT

## Contract Version

* `{v1 / v2 / ...}`

## Pending Breaking Change

* `{none / short note}`

## Active Cross-Feature Contract Migration

* `{none / short note}`

---

# 8. SYSTEM HISTORY REFERENCE

* `/ai-system/system-history.md`

Kural:

* `system-state.md` yalniz current snapshot tasir
* append-only tarihce `system-history.md` icinde surdurulur
* onceki veya historical status paragraflari bu dosyaya eklenmez
* current reason / last action / next action kisa tutulur; delivery raporu buraya kopyalanmaz
* default size budget 24,000 baytdir; asilirsa tarihce archive edilir

---

# 9. GLOBAL RISKS

* {risk}
* {risk}

---

# 10. SYSTEM NOTES

* Stack/runtime authority burada duplicate edilmez; `project-authority/platform.md` referans alinir
* Workflow degisirse `feature-board.md`, ilgili `orchestration.md` ve bu dosya ayni turda guncellenir
* Tech Lead transition sonunda `sh ai-system/tools/workflow-state-audit.sh ai-system` calistirir
