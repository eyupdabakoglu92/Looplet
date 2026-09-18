# Project Setup Manifest (Template)

> Status: TEMPLATE / OPERATIONAL
>
> Bu dosya `Project Setup` rolunun kullanacagi proje-spesifik scaffold/bootstrap recipe'si icin baslangic skeleto nudur. Project Setup rolunu kullanmayacaksaniz bu dosya opsiyoneldir.

Last Updated: YYYY-MM-DD

---

## Purpose

Bu dosya:

* stack-specific setup recipe tasir
* prompt katmanina komut gomulmesini engeller
* scaffold ve verification komutlarini tek yerde toplar

---

## Governing Docs

* Role behavior: `/ai-system/prompts/project-setup.md`
* Platform stack authority: `/ai-system/project-authority/platform.md`
* Execution semantics: `/ai-system/role-execution-contract.md`

---

## Workspace Targets

| Target | Purpose | Required | Notes |
| --- | --- | --- | --- |
| `{workspace-name}` | `{purpose}` | Yes | `{notes}` |

---

## Scaffold / Bootstrap Recipe

### `{workspace-name}`

Hedef dizin:

* `{path}`

Canonical setup adimlari:

1. `{command or action}`
2. `{command or action}`
3. `{command or action}`

Uygulama kurallari:

* `{rule}`
* `{rule}`

---

## Canonical Verification Commands

* Build: `{command}`
* Test: `{command}`
* Boot / dev run: `{command}`
* Extra verification: `{command}`

Her komut icin Project Setup evidence record'i:

* Target / environment: `{target}`
* Expected ready signal: `{health/home/ready output}`
* Required on first scaffold: `Yes / No`

Kural:

* Command syntax'i scaffold turunda gercekten calistirilarak dogrulanir
* Build success boot success yerine gecmez
* App entry point / provider graph / SDK init varsa production-shaped cold boot ayri gate'tir
* Calistirilmayan komut `PASS` degil `PENDING / NOT RUN` olarak raporlanir

---

## Canonical Containerization Commands

* Dockerfile path(s): `{path or N/A}`
* Compose file(s): `{path or N/A}`
* Image build: `{command or N/A}`
* Container run: `{command or N/A}`
* Compose up / down: `{command or N/A}`
* Container smoke test: `{command or N/A}`

Kural:

* Docker/container komutlari project authority'de gerekli degilse `N/A` yazilir
* Container build/run komutlari release gate olarak kullanilacaksa `project-authority/release.md` ile uyumlu olmalidir

---

## Safety Rules

* Manifest role authority uretmez; yalniz operasyon recipe'si tasir
* Manifest ile delivery spec conflict varsa Project Setup blocker uretir
* Extra bagimlilik veya scaffold farki gerekiyorsa Tech Lead karari olmadan sessizce uygulanmaz
