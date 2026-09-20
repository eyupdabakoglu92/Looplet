# AI System Project Adoption Guide

> Status: ANALYSIS / ADOPTION GUIDE
>
> Bu dokuman, `ai-system` yapisinin hem yeni projelerde (`greenfield`) hem de mevcut projelerde (`brownfield`) nasil kullanilacagini aciklar. Ayrica reusable core ile proje-instance katmanlarini ayirir ve starter template setini referanslar.

---

## 1. Short Verdict

Bu `ai-system`:

* yeni projede kullanilabilir
* mevcutta yazilmis bir projeye sonradan oturtulabilir
* artik reusable starter template setine de sahiptir

Ama su kosulla:

* canli proje snapshot'i ile reusable core karistirilmamalidir

Kisa hukum:

* reusable core: **hazir**
* project-instance authority: **ayri katmana alinmis durumda**
* starter templates: **artik mevcut**
* brownfield onboarding: **mumkun ama baseline turu gerekir**

---

## 2. Adoption Modes

### 2.1 Greenfield

Durum:

* proje yeni basliyor
* urun/folder/workflow state'i sifirdan kurulacak

Bu modda:

* reusable core kopyalanir
* `project-authority/`, `product/`, `feature-board.md`, `system-state.md`, `features/` sifirdan initialize edilir

### 2.2 Brownfield

Durum:

* proje zaten var
* codebase mevcut
* siz bu projeyi gelistirmek veya duzene almak istiyorsunuz

Bu modda:

* `Project Setup` cogu durumda kullanilmaz
* once mevcut codebase'den authority cikarilir
* sonra sistemin file-based workflow/state katmani projeye oturtulur

Hukum:

* Bu sistem brownfield icin **uygundur**
* Ama once mevcut proje icin bir **baseline / onboarding** turu gerekir

---

## 3. Core Layering Model

Sistemi dogru kullanmak icin uc katmani ayirmak gerekir.

### 3.1 Reusable Core

Bunlar buyuk olcude projeden bagimsizdir:

* `prompts/`
* `role-execution-contract.md`
* `orchestration-template.md`
* `prompt-*.md`
* `tools/`
* `design/design-doctrine.md`
* `design/premium-ui-rubric.md`
* `design/visual-quality-gate.md`

### 3.2 Project-Instance Authority

Bunlar her projede yeniden yazilir:

* `project-authority/platform.md`
* `project-authority/setup-manifest.md`
* `project-authority/design-foundation.md` (user-facing projelerde ilk visual gate sırasında)
* `product/product-prd.md`
* `feature-board.md`
* `system-state.md`

### 3.3 Live Workflow State

Bunlar canli proje akisiyla birlikte olusur:

* `features/{feature-name}/`
* `bugs/`
* `incidents/`
* `system-history.md`

Kural:

* reusable core tasinir
* project-instance authority yeniden yazilir
* live workflow state starter pack olarak tasinmaz

---

## 4. Current Readiness Assessment

### Strong Areas

* role execution modeli net
* local/global ownership sinirlari acik
* Tech Lead orchestration modeli olgun
* QA gate yapisi guclu
* UI handoff ve premium kalite authority'si rendered/runtime evidence ile doğrulanabilir
* project authority ile prompt/core katmani artik fiziksel olarak ayrilmis durumda

### Previously Weak Areas

Asagidaki bosluklar vardi:

* `feature-board.md` template yoktu
* `system-state.md` template yoktu
* feature `prd.md`, `architecture.md`, `analysis.md`, `ui-design.md` template'leri yoktu
* greenfield ve brownfield adoption tek yerde anlatilmiyordu

Bu turda bunlar adreslendi:

* `ai-system/templates/` eklendi
* starter template seti olusturuldu
* bu rehber iki adoption modunu tek yerde birlestirdi

---

## 5. Template Set

Starter templates burada:

* [templates/README.md](templates/README.md)
* [templates/feature-board.template.md](templates/feature-board.template.md)
* [templates/system-state.template.md](templates/system-state.template.md)
* [templates/product-prd.template.md](templates/product-prd.template.md)
* [templates/project-platform.template.md](templates/project-platform.template.md)
* [templates/setup-manifest.template.md](templates/setup-manifest.template.md)
* [templates/project-release.template.md](templates/project-release.template.md)
* [templates/feature-prd.template.md](templates/feature-prd.template.md)
* [templates/feature-architecture.template.md](templates/feature-architecture.template.md)
* [templates/feature-analysis.template.md](templates/feature-analysis.template.md)
* [templates/feature-ui-design.template.md](templates/feature-ui-design.template.md)
* [templates/feature-release.template.md](templates/feature-release.template.md)

Not:

* `features/{feature-name}/orchestration.md` icin [orchestration-template.md](orchestration-template.md) kullanilmaya devam edilir

---

## 5.1 Read / Output Optimization Policy

Bu sistemde token optimizasyonu reusable core'un parcasidir, fakat authority davranisi degildir.

Read policy:

* Tech Lead read order staged/scope-gated ilerler.
* UI referans dokumanlari Tech Lead tarafindan yalniz UI scope, UI finding veya UI handoff karari varsa okunur.
* Release authority yalniz release/deployment gate varsa devreye girer.
* `Consumed Signals` source artifact'i silmez; yalniz downstream default okuma davranisini optimize eder.
* `analysis.md` consumed edilmisse ve ilgili unresolved question yoksa downstream roller `architecture.md` authority'sini esas alir.
* QA her zaman küçük core prompt'u okur; yalnız Tech Lead'in `QA Modules` alanında seçtiği koşullu modülleri ve onların artifact'larını yükler.
* Regression depth riskten önce seçilir; fingerprint'i geçerli functional/runtime kanıt final turda tekrar kullanılabilir, değişen yüzey yeniden çalıştırılır.

Output policy:

* Delivery artifact'lari brief-first / scope-gated yazilir.
* Bos `N/A`, `Yok` veya placeholder tablo uretmek beklenmez.
* Blocker, conflict, missing evidence ve partial delivery asla scope-gating gerekcesiyle atlanmaz.

Diagnostic tooling:

```bash
sh ai-system/tools/token-cost-audit.sh ai-system
sh ai-system/tools/workflow-state-audit.sh ai-system
sh ai-system/tools/token-cost-audit.sh ai-system --role qa
sh ai-system/tools/token-cost-audit.sh ai-system --role unity
sh ai-system/tools/token-cost-audit.sh ai-system --estimator auto
sh ai-system/tools/token-cost-audit.sh ai-system --baseline <approved-baseline> --budget <project-budget>
node ai-system/tools/qa-preflight.mjs ai-system
```

Not:

* Token-cost audit manuel maliyet takibidir. Workflow-state audit handoff/Done gate'idir. QA preflight aktif QA planındaki module/depth/reuse ve input uyumunu read-only doğrular. Node.js 18+ isterler; paket kurulumu veya dosya değişikliği yapmazlar. Delivery `--local`, Tech Lead full mod kullanır; `--structure-only` yalnız tanıdır.
* Eski kurulumlarda canlı dosyaları starter ile ezme; README içindeki Mevcut Kurulumda Core Güncellemesi adımlarını ve Tech Lead resync'i uygula. Kanıt olmadan approval üretme.
* Ilk implementasyonda `--baseline/--budget` zorunlu degildir; once proje baseline'i kaydedilir.
* Sonraki core guncellemelerinde `--baseline <approved-baseline> --budget <project-budget>` regression kontrolu olarak kullanilir.
* `--estimator auto`, `python3+tiktoken` varsa tokenizer sayimi kullanir; yoksa `chars/4` fallback ile devam eder.

---

## 5.2 Client Stack / Game Role Selection

`project-authority/platform.md` client rolünü belirleyen ana authority'dir:

* Standart web/mobil/native app client'larında `Frontend/Mobile Developer` çalışır ve `frontend.md` üretir.
* Client Type `game (Unity)` ise `Game Developer (Unity)` çalışır ve `game-dev.md` üretir.
* Ayrı içerik kararları gerektiren metin, yerelleştirme, eğitim veya veri paketi için `Content Designer` çalışır ve `content-design.md` ile gerçek asset'leri üretir; araç ve entegrasyon kodu developer rolünde kalır.
* Aynı feature'da `Frontend/Mobile Developer` ve `Game Developer (Unity)` eşzamanlı client owner yapılmaz; route `orchestration.md -> Next Role` üzerinden netleşir.
* Unity oyunlarda `ui-design.md`, meta ekranlar veya Game Visual/HUD Direction gereken kapsamlar için Game Developer'a visual/state authority sağlayabilir.
* Yeni HUD sistemi, FTUE/tutorial overlay, win/lose/reward reveal, premium polish veya reference-title hedefi varsa UI Designer önce Game Visual/HUD Direction üretmeli; Game Developer bunu uygular.
* Unity/iOS release gate varsa `project-authority/release.md` içinde Unity build, Xcode signing/archive, TestFlight, IAP catalog, ATT ve Privacy Manifest readiness açık olmalıdır.

Bu ayrım günlük kullanımda komut farkı yaratır: normal mobil uygulamada `Run Frontend/Mobile Developer`, Unity mobil oyunda `Run Game Developer (Unity)` çalıştırılır. Kararsız kalındığında kullanıcı role doğrudan geçmez; `Run Tech Lead` ile routing düzeltilir.

---

## 6. Greenfield Adoption

### 6.1 Copy As-Is

Yeni projeye buyuk olcude aynen tasinabilecek reusable core:

* `prompts/`
* `role-execution-contract.md`
* `orchestration-template.md`
* `prompt-execution-gating-standard.md`
* `prompt-input-authority-standard.md`
* `prompt-input-integrity-standard.md`
* `prompt-delivery-footer-standard.md`
* `prompt-delivery-artifact-standard.md`
* `prompt-tech-lead-output-standard.md`
* `prompt-tech-lead-state-machine-standard.md`
* `prompt-alignment-matrix.md`
* `prompt-boilerplate-map.md`
* `tools/`

UI role'u kullanilacaksa:

* `design/design-doctrine.md`
* `design/premium-ui-rubric.md`
* `design/visual-quality-gate.md`

### 6.2 Initialize Fresh

Greenfield'da baslangic yuzeyleri su sekilde olusur:

* `product/product-prd.md` — Product Owner uretir
* `project-authority/setup-manifest.md` (gerekiyorsa)
* `project-authority/release.md` (release/deployment gate gerekiyorsa)
* `project-authority/design-foundation.md` (user-facing projede UI Designer + selection authority üretir)
* `feature-board.md` — Product Owner uretir
* `system-state.md` — Product Owner uretir
* `project-authority/platform.md` — Tech Lead uretir
* ilk feature klasoru altindaki `prd.md`, `architecture.md`, `orchestration.md` — Tech Lead uretir

### 6.3 Greenfield Bootstrap Order

1. Reusable core'u kopyala.
2. `Run Product Owner. Yeni proje: <tanım>` — product-prd.md, feature-board.md, system-state.md üretilir.
3. Çıktıları gözden geçir; gerekirse `Run Product Owner. Revise: <kapsam>`.
4. Gerekliyse `templates/setup-manifest.template.md` ile `project-authority/setup-manifest.md` olustur.
5. Release/deployment gate gerekiyorsa `templates/project-release.template.md` ile `project-authority/release.md` oluştur veya Tech Lead'in üretmesini sağla.
6. `Run Tech Lead. Yeni proje bootstrap yap.` — platform.md + gerekiyorsa release.md + ilk feature klasörü üretilir.

Not:

* `platform.md` greenfield'da Tech Lead tarafindan PRD Section 12'yi baz alarak uretilir; kullanici elle doldurmaz
* Ilk feature klasoru ve icindeki `prd.md`, `architecture.md`, `orchestration.md` dosyalari kullanici tarafindan olusturulmaz
* Tech Lead bu komutla `features/` bos oldugunu tespit eder, `product-prd.md`'den ilk feature'i turetir ve dosyalari uretir

---

## 7. Brownfield Adoption

### 7.1 Can It Work On An Existing Project?

Evet.

Sebep:

* `Project Setup` yalniz proje scaffold edilmemisse devreye girer
* Tech Lead, mevcut codebase ile authority dokumanlari arasindaki farki reconcile etmeye zorlanir
* sistemde incident, reopen, rework ve cross-feature issue modelleri vardir

Ama dogrudan delivery ile baslamak dogru degildir.

Once su baseline kurulmalidir:

* proje ne yapiyor?
* teknik authority ne?
* portfolyoda hangi feature'lar var?
* aktif olarak ne gelistirilecek?

### 7.2 Brownfield Bootstrap Order

1. Reusable core'u projeye ekle.
2. `Run Product Owner. Yeni proje: <mevcut ürün özeti>` komutuyla başla.
   * Product Owner mevcut ürünü analiz eder, `product-prd.md`, `feature-board.md` ve `system-state.md` üretir.
   * Mevcut codebase'den çıkarılabilecek kısıtları (tech stack, entegrasyonlar) kullanıcı tanımına ekle.
3. Çıktıları gözden geçir. Değişiklik istersen: `Run Product Owner. Revise: <kapsam>`
4. Mevcut codebase'i inceleyerek `project-authority/platform.md` oluştur.
   * Bu dosyayı elle doldur — brownfield'da gerçek stack zaten bellidir; Tech Lead'e bırakma.
5. Mevcut codebase'i inceleyerek `project-authority/setup-manifest.md` oluştur.
   * Workspace target'ları, canonical build/test/boot komutlarını ve scaffold gerekirse setup recipe'yi yaz.
   * Backend içeren veya QA build/test gate'i gerektiren brownfield projelerde bu dosya zorunludur.
6. Release/deployment gate'i varsa mevcut pipeline, hosting platformu ve rollback politikasından `project-authority/release.md` oluştur.
7. `Run Tech Lead. Brownfield onboarding yap.` komutuyla akışı başlat.

Not:
* Brownfield'da `platform.md` gerçek codebase'den çıkarıldığı için Tech Lead'in üretmesine gerek yoktur.
* Brownfield'da `setup-manifest.md` de mevcut codebase komutlarından çıkarılır; QA build gate bu dosyaya bağlıdır.
* Brownfield'da `release.md` mevcut CI/CD ve deployment reality'sinden çıkarılır; DevOps/Release Engineer release gate'i bu dosyaya bağlıdır.
* Mevcut bug veya rework varsa Tech Lead bunu `Run Tech Lead. Incident: <sorun>` ile alır; yeni feature olarak açmaz.

Not:

* Ilk feature klasoru ve authority dosyalari kullanici tarafindan olusturulmaz
* Tech Lead brownfield onboarding'de `features/` bos oldugunu gorurse `product-prd.md` ve `feature-board.md`'den ilk managed feature'i secer ve dosyalari uretir
* Mevcut bug/rework varsa bunu Tech Lead incident/reopen mantigiyla alir; yeni feature olarak acmaz

### 7.3 Recommended First Brownfield Feature

Brownfield onboarding'de ilk feature olarak sunlardan biri secilmelidir:

* aktif gelistirilecek gercek urun alani
* kritik bir bugfix/rework
* cross-cutting ama sinirlari net bir stabilization alani

Tavsiyem:

* "tum projeyi tek feature yapma"
* once bir dilim sec, sonra sistemi orada calistir

### 7.4 Brownfield Rules

* Mevcut codebase pattern'i authority'yi gecersiz kilarsa once dokuman guncellenir
* Brownfield onboarding turunda "hemen implement" refleksi yerine "authority establish" onceliklidir
* Mevcut projede feature sinirlari zayifsa Tech Lead once decomposition yapmalidir

---

## 8. Required Files For Any Project

### Minimum Required To Start

* `prompts/`
* `role-execution-contract.md`
* `orchestration-template.md`
* `product/product-prd.md`
* `project-authority/platform.md`
* `feature-board.md`
* `system-state.md`
* en az bir feature klasoru:
  * `prd.md`
  * `architecture.md`
  * `orchestration.md`

### Required When Applicable

* `project-authority/setup-manifest.md`
  * Project Setup kullanılacaksa
  * backend-touching QA build/test gate'i varsa
  * canonical build/test/boot komutları gerekecekse
* `project-authority/release.md`
  * release/deployment gate'i varsa
  * CI/CD, rollback, preview/staging veya production readiness gerekiyorsa
  * Unity/iOS app store distribution, TestFlight, IAP catalog, ATT veya Privacy Manifest gate'i varsa

### Optional But Strongly Recommended

* `design/design-doctrine.md`
* `design/premium-ui-rubric.md`
* `design/visual-quality-gate.md`
  * UI feature'ları ve Unity Game Visual/HUD Direction scope'larında zorunlu reusable standartlardır
* `project-authority/design-foundation.md`
  * yeni yüzey/motion/design-system scope'unda implementation öncesi `Selected` olmalıdır
* `analysis.md`
* `ui-design.md`
  * standart UI handoff veya Unity Game Visual/HUD Direction gerekiyorsa; rendered alternatives ve Visual Evidence Manifest içerir
* `release.md`

### Diagnostic / Non-Activation Files

Bu dosyalar kurulum ve bakım için faydalıdır, fakat role activation input'u değildir:

* `prompt-alignment-matrix.md`
* `prompt-boilerplate-map.md`
* `tools/token-cost-audit.sh` ve opsiyonel audit flag'leri

### Live Delivery Outputs

Bunlar zamanla olusur:

* `backend.md`
* `frontend.md`
* `game-dev.md` (client stack Unity/mobil oyunsa)
* `qa.md`
* `release.md` (release/deployment gate gerekiyorsa)
* `bugs/`
* `incidents/`
* `system-history.md`

---

## 9. What Each File Must Contain

### `product/product-prd.md`

Asgari olarak:

* product overview
* business goals
* target users
* core capabilities
* high-level user flows
* feature list
* user stories
* acceptance criteria
* edge cases
* success metrics

### `project-authority/platform.md`

Asgari olarak:

* stack
* contract rules
* error semantics
* auth/session strategy
* data/persistence rules
* runtime/realtime rules
* testing strategy
* security/observability

### `project-authority/setup-manifest.md`

Asgari olarak:

* scaffold/bootstrap recipe
* workspace targets
* canonical verification commands
* safety rules

### `feature-board.md`

Asgari olarak:

* status table
* priority ordering
* active phase
* active owner
* varsa yalniz acik rework / incident ozeti

### `system-state.md`

Asgari olarak:

* initialization/environment status
* authority references
* active feature
* current phase
* current role
* current reason
* last completed action
* next expected action
* global contract snapshot
* cross-feature snapshot
* history pointer
* global risks

### `features/{feature}/prd.md`

Asgari olarak:

* summary
* dependencies
* in scope / out of scope
* user stories
* acceptance criteria
* edge cases
* success metrics

### `features/{feature}/architecture.md`

Asgari olarak:

* actors and permissions
* entry/exit paths
* API/event contract
* error semantics
* validation ownership
* state/flow semantics
* integration rules
* QA focus

### `features/{feature}/analysis.md`

Asgari olarak:

* problem framing
* options
* trade-offs
* recommendation
* edge cases
* QA implications

### `features/{feature}/ui-design.md`

Asgari olarak:

* screen goals
* UX flow
* layout structure
* component blueprint
* CTA hierarchy
* state design
* visual direction
* accessibility
* handoff notes

---

## 10. What Not To Copy As Starter State

Yeni proje veya brownfield onboarding baslangicina bunlar tasinmamali:

* mevcut `features/*` canli dosyalari
* mevcut `bugs/`
* mevcut `incidents/`
* `system-history.md`
* `bug-prompt-retro.md`
* `prompt-and-core-audit.md`
* `refactor-rollout-plan.md`
* `snapshot-slimming-prep.md`
* `.DS_Store`

---

## 11. Recommended Folder Tree

```text
ai-system/
  prompts/
  design/
  product/
    product-prd.md
  project-authority/
    README.md
    platform.md
    setup-manifest.md
    release.md
  templates/
    README.md
    feature-board.template.md
    system-state.template.md
    product-prd.template.md
    project-platform.template.md
    setup-manifest.template.md
    project-release.template.md
    feature-prd.template.md
    feature-architecture.template.md
    feature-analysis.template.md
    feature-ui-design.template.md
    feature-release.template.md
  features/
    {feature-name}/
      prd.md
      architecture.md
      orchestration.md
      release.md        # gerekirse
      analysis.md
      ui-design.md
      backend.md
      frontend.md
      game-dev.md    # client stack Unity/mobil oyunsa
      qa.md
  feature-board.md
  system-state.md
  role-execution-contract.md
  orchestration-template.md
  prompt-*.md
```

---

## 12. Remaining Limitations

Sistem artik cok daha reusable durumda, ama bazi sinirlar devam ediyor:

* canonical role set opinionated
* file-based state management zorunlu kabul ediliyor
* Tech Lead-centric orchestration modeli korunuyor

Bunlar eksik degil; tasarim tercihidir. Farkli ekip modeli istenirse ayri adaptasyon gerekir.

---

## 13. Final Recommendation

Bu `ai-system` artik iki senaryo icin de kurulabilir:

* yeni proje baslatmak
* mevcut projeyi devralip disipline etmek

En saglikli kullanim modeli:

1. reusable core'u sabit tut
2. project authority'yi yeniden yaz
3. templates ile baslangic dokumanlarini olustur
4. live workflow state'i sifirdan ya da kontrollu onboarding ile kur

Kisa hukum:

* Greenfield readiness: **yuksek**
* Brownfield readiness: **yuksek, ama onboarding turu gerekli**
* Reusability: **artik pratik olarak uygulanabilir**
