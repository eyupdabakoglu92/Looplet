# Prompt Tech Lead Output Standard

> Status: MANDATORY SUPPLEMENT FOR `prompts/tech-lead.md`
>
> Bu dosya Tech Lead prompt'undaki tekrar eden output iskeletini ve orchestration update checklist'ini ayri tutar. Bos section acma; yalniz o tur icin gerekli olan bolumleri doldur.

Last Updated: 2026-04-22

---

## Purpose

Bu dosya:

* Tech Lead prompt'undaki uzun output boilerplate'ini ayirir
* Orchestration update alanlarini tutarli hale getirir
* Feature planning, handoff ve closeout turlerinde ayni minimum checklist'in korunmasini saglar

---

## Core Output Checklist

### 1. Feature Breakdown

Gerekliyse global PRD'den feature listesi uret veya mevcut listeyi dogrula:

* ID
* isim (kebab-case)
* aciklama
* bagimlilik

### 2. Feature Priority & Order

Gerekliyse feature'lari sirala ve nedenini yaz.

### 3. Feature Board (Global State)

Gerekliyse su kolon yapisini koru:

| ID | Feature | Status | Owner | QA | Priority | Notes |

Status kumesi:

* Not Started
* In Progress
* In QA
* In Release
* Rework
* Done
* Blocked
* Closed

Owner kumesi:

* Tech Lead
* Technical Analyst
* Content Designer
* UI Designer
* Backend Developer
* Frontend/Mobile Developer
* Game Developer (Unity)
* DevOps/Release Engineer
* QA
* Project Setup

### 4. Selected Feature

Aktif feature'i secerken asgari olarak sunlari acikla:

* dependency durumu
* priority
* blocker durumu
* yarim kalmis is olup olmamasi

### 5. Complexity Decision

Asgari kararlar:

* Technical Analyst gerekli mi?
* UI Designer gerekli mi?
* Gerekliyse neden?
* Degilse neden?

### 6. Technical Analyst Trigger

Technical Analyst devreye girecekse brief en az sunlari kapsar:

* feature PRD analizi
* user story ve acceptance criteria netlestirme
* API / veri modeli ihtiyaclarini cikarma
* edge case ve integration kurallarini ayiklama

### 7. UI Designer Trigger

UI Designer devreye girecekse brief en az sunlari kapsar:

* uygulanabilir UI/UX handoff
* screen goal ve visual hierarchy
* layout structure ve component blueprint
* loading / error / empty / success / disabled / selected / focused state'ler
* generic / wireframe hissinden kacinma

### 8. Shared Contract & Integration Rules

Gerekliyse su basliklari netlestir:

* API Endpoints
* Request / Response
* Error Format
* Validation Responsibility
* Authentication / Authorization
* Actor / permission / ownership boundaries
* Data Rules
* Entry / exit / retry / direct-entry / restore kurallari
* Duplicate / no-op / terminal-state davranisi
* Persist / hydrate / reconnect / stale-state reset kurallari
* Integration Rules

Minimum beklenti:

* backend response -> frontend mapping net olmali
* field naming ve null handling tutarli olmali
* error handling tutarli olmali
* state consistency ve reset/hydration davranislari acik yazilmali
* business flow kritikse allowed actor, forbidden actor ve gorunur sonuc contract'a yazilmali
* varsa `ui-design.md` ile frontend implementasyon alignment zorunlu olmali

### 9. Implementation Plan

Gerekli role'ler icin plan yaz:

* UI Designer
* Content Designer
* Backend
* Frontend/Mobile
* DevOps/Release Engineer
* Parallel Work Strategy

### 10. Next Role Input - Backend Developer

Backend brief'inde en az sunlar olmali:

* contract'a uygun implementasyon
* acceptance criteria coverage
* entity/DTO/service/validation/error handling
* edge case coverage
* unit test beklentisi
* `backend.md` icinde task-to-code traceability, authority reconciliation, preserved behavior ve task-bazli test evidence beklentisi

### 11. Next Role Input - UI Designer

UI Designer brief'inde en az sunlar olmali:

* uygulanabilir UI/UX handoff
* `design-doctrine.md` ve `premium-ui-rubric.md` zorunlu referansi
* visual hierarchy, layout structure, component blueprint
* background, color, typography, surface/depth, motion intent
* CTA onceligi
* state gorunurlugu
* premium farklilastirici kararlar

### 11a. Next Role Input - Content Designer

Content brief'inde en az sunlar olmali:

* içerik türü, teslim kapsamı ve çıktı konumu; format/schema ve miktar yalnız gerekliyse
* product/feature acceptance criteria coverage
* kapsama uygulanabilen doğruluk, dil, tutarlılık, kapsam ve sıralama hedefleri
* varsa kullanılacak içerik araçları ve generator/validator talimatı
* yalnız belirsiz constraint varsa feasibility kanıtı veya unresolved blocker
* doğrulama yöntemi; executable gate varsa exact check ve pozitif/negatif örnek beklentisi
* human sign-off gerekiyorsa benzersiz decision id
* `content-design.md` ve gercek content asset teslimi

### 12. Next Role Input - Frontend/Mobile Developer

Frontend brief'inde en az sunlar olmali:

* UI olusturma
* state yonetimi
* API entegrasyonu
* generic UI uretmeme
* acceptance criteria davranisini koruma
* loading/error/empty state yonetimi
* edge case coverage
* varsa `ui-design.md` kararlarini koruma
* `frontend.md` icinde task-to-code traceability, authority reconciliation, preserved behavior ve task-bazli test evidence beklentisi

### 12a. Next Role Input - Game Developer (Unity)

Kosul: `platform.md` client stack Unity/mobil oyun ise bu brief Frontend/Mobile Developer yerine kullanilir.

Game brief'inde en az sunlar olmali:

* etkilenen scene/prefab/sistem kapsami
* IAP product ID / ekonomi sabiti / save data contract'i varsa acikca referans
* iOS platform etkisi (ATT, Privacy Manifest, IAP, Game Center) varsa belirtilmesi
* hedef frame rate / performans beklentisi
* acceptance criteria davranisini koruma
* `game-dev.md` icinde task-to-code traceability ve task-bazli test evidence beklentisi

Kapsam `GAME VISUAL OWNERSHIP MODEL`'e gore UI Designer handoff'u gerektiriyorsa (yeni HUD sistemi, FTUE/tutorial overlay, win/lose/reward reveal, premium polish hedefi) brief'e ek olarak sunlar da zorunlu:

* HUD visual hierarchy ve okunabilirlik beklentisi
* motion/VFX/audio style niyeti
* reference-title target (varsa)
* camera/feedback kurallari

### 13. QA Strategy

QA stratejisi gerektiginde su boyutlari kapsar:

* acceptance criteria -> test senaryosu eslemesi
* kritik user journey'ler: baslangic durumu -> aksiyon -> gorunur sonuc
* usage-control / misuse matrisi: wrong actor, invalid entry, stale state, duplicate submit, retry/back/cancel, terminal-state reuse
* happy path
* validation
* error
* edge case
* integration
* scope: backend-only / client-only / end-to-end / content-only ve uygulanabilir compliance
* QA Stage: functional / final; required kanıtı stage'e göre tanımla
* kanit sinifi: `runtime`, `repeatable integration`, `automated functional`, `source-only`
* runtime zorunlu senaryolar ve approval bar'i

UI Designer kullanilan feature'larda ek kontrol:

* `ui-design.md` ile frontend implementasyonu uyumu
* CTA hiyerarsisi
* state gorunurlugu
* background / typography / surface/depth / premium kalite kararlari
* `premium-ui-rubric.md` fail condition'lari

Kural:

* QA brief'i generic "AC + edge case kontrol et" seviyesinde birakilmaz; kritik journey ve misuse sinirlari feature'a ozel yazilir
* Runtime proof gerektiren bir feature'da Tech Lead, source-audit ile kapanabilecek bir QA beklentisi yazmaz
* "Tech Lead sonra manuel bakar" modeli, QA approval yerine gecmez; runtime exit criteria QA kapsaminda net yazilmalidir

### 14. Release / DevOps Strategy

Release veya deployment gate gerekiyorsa su alanlari kisa ve somut degerlendir:

* config
* CI/CD required gates
* development / test / staging / production environment topology
* Dockerfile / docker-compose / container image build policy
* logging
* deployment
* rollback
* secrets
* environment strategy
* monitoring / alerting
* smoke validation
* release approval

Kural:

* Release/deployment gerektiren feature'da bu alan generic "sonra bakilir" seviyesinde birakilmaz
* Production deploy, release authority ve explicit approval olmadan planlanmis olsa bile calistirilmis sayilmaz
* Release gate gerekiyorsa `Next Role = DevOps/Release Engineer` olarak acik task verilir

### 15. Next Role Input - DevOps/Release Engineer

DevOps/Release Engineer brief'inde en az sunlar olmali:

* release scope: `ci-cd-only / container-build / deploy-development / deploy-test / deploy-preview / staging / production-readiness / rollback-readiness`
* project authority referansi: `project-authority/release.md`
* required pipeline gates
* environment target ve approval beklentisi
* secret/env var isimleri ve owner bilgisi
* Dockerfile/compose/image build ve container smoke validation beklentisi
* deployment runbook beklentisi
* rollback ve smoke validation beklentisi
* `release.md` icinde gate evidence ve release readiness verdict beklentisi

### 16. Orchestration Update

Tech Lead'in `orchestration.md` guncellemesinde asgari olarak sunlar net olmali:

* Current Status
* Current Owner
* Active Task Ledger ve Handoff Plan
* Feature ID; global Active Feature eşleşmesi
* QA Stage / QA Result / Release Scope / Release Result / Delivery Review
* Pending Evidence / Open Decision Gates
* Open Tasks
* Blockers
* Last Decision
* Last Update
* Next Role
* Next Action
* Change Log

Opsiyonel ek not gerekiyorsa:

* delivery reconciliation ozeti assistant output'ta veya ayri delivery artifact'inda tutulur
* `Current Phase` ve `Rework Plan` yalniz gercekten gerekiyorsa acilir
* `Consumed Signals` yalniz analysis gibi upstream artifact bilgisi `architecture.md` icine tasindiysa acilir; authority uretmez, sadece downstream okuma optimizasyonu saglar

Tech Lead ic kontrol checklist'i:

* `feature-board.md` active owner / phase guncellendi mi?
* `system-state.md` active feature / phase / role guncellendi mi?
* Terminal state ise stale `Next Role` / `Next Action` temizlendi mi?
* Bu checklist ayri orchestration section'i olarak default acilmaz
