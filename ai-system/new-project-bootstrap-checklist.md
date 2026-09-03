# New Project Bootstrap Checklist

> Status: OPERATIONAL CHECKLIST / COMMAND STANDARD
>
> Bu dokuman yeni bir projeye `ai-system` tasirken hangi dosyalarin oldugu gibi kopyalanacagini, hangilerinin template'ten uretilecegini ve kullanici tarafinda hangi komut standardinin izlenecegini tek sayfada toplar.

---

## 1. Three Buckets

### A. Copy As-Is

Bu dosya ve klasorler reusable core'dur. Iclerini bosaltma, yeniden yazma:

* `prompts/`
* `prompt-*.md`
* `role-execution-contract.md`
* `orchestration-template.md`
* `templates/`
* `tools/`
* `README.md`
* `new-project-adoption-guide.md`
* `project-authority/README.md`
* `design/` yalniz UI role'larini kullanacaksan

### B. Create From Template

Bu dosyalar yeni projeye ozeldir. Bos dosya yaratma; template'ten skeleton olarak uret:

* `product/product-prd.md`
* `project-authority/setup-manifest.md` gerekirse
* `project-authority/release.md` release/deployment gate gerekiyorsa
* `feature-board.md`
* `system-state.md`

Not:

* Greenfield'da `project-authority/platform.md` template'ten olusturulmaz; Tech Lead PRD Section 12'yi baz alarak uretir
* Brownfield'da `project-authority/platform.md` mevcut codebase'den cikarilir; template yalniz referans olarak kullanilabilir
* `project-authority/release.md` release/deployment gate yoksa zorunlu degildir
* `features/{feature-name}/` klasoru ve icindeki `prd.md`, `architecture.md`, `orchestration.md` dosyalari ilk `Run Tech Lead` tarafindan olusturulur
* Kullanicinin bu klasoru elle acmasina gerek yoktur

### C. Create Later

Bunlar delivery sirasinda olusur. Basi icin gerekli degildir:

* `features/{feature-name}/backend.md`
* `features/{feature-name}/frontend.md`
* `features/{feature-name}/game-dev.md` (client stack Unity/mobil oyunsa)
* `features/{feature-name}/qa.md`
* `bugs/`
* `incidents/`
* `system-history.md`

### D. Project Setup Scope Notu

* `Project Setup` yalnız **ilk kez scaffold** gerektiğinde çalışır (DURUM 0)
* İlk scaffold sonrası Backend Developer, Frontend/Mobile Developer veya client stack Unity/mobil oyunsa Game Developer (Unity) kodu doğrudan proje dosyalarına yazar
* Tamamen yeni workspace/servis eklenmedikçe Project Setup tekrar tetiklenmez

### E. Client Stack Routing Notu

* Standart web/mobil/native app client'larında `Run Frontend/Mobile Developer` kullanılır ve `frontend.md` oluşur.
* `platform.md -> Client Type = game (Unity)` ise `Run Game Developer (Unity)` kullanılır ve `game-dev.md` oluşur.
* Aynı feature'da Frontend/Mobile Developer ve Game Developer (Unity) eşzamanlı client owner yapılmaz.
* Unity oyunlarda meta ekranlar veya Game Visual/HUD Direction gereken HUD/FTUE/reward/premium polish kapsamları için `Run UI Designer` önce gelebilir; Game Developer (Unity) bu handoff'u uygular.

---

## 2. Shell Bootstrap Commands

Asagidaki komutlar yeni projeye fiziksel dosya kurulumu icin ornek standarttir.
`<source-ai-system-dir>` mevcut paylasilan `ai-system` kaynagini,
`<target-repo-dir>` yeni projeyi ifade eder.

### 2.1 Copy Reusable Core

```bash
SOURCE_AI_SYSTEM="<source-ai-system-dir>"
TARGET_REPO="<target-repo-dir>"

mkdir -p "$TARGET_REPO/ai-system"

cp -R "$SOURCE_AI_SYSTEM/prompts" "$TARGET_REPO/ai-system/"
cp -R "$SOURCE_AI_SYSTEM/templates" "$TARGET_REPO/ai-system/"
cp -R "$SOURCE_AI_SYSTEM/tools" "$TARGET_REPO/ai-system/"
cp "$SOURCE_AI_SYSTEM/README.md" "$TARGET_REPO/ai-system/"
cp "$SOURCE_AI_SYSTEM/new-project-adoption-guide.md" "$TARGET_REPO/ai-system/"
cp "$SOURCE_AI_SYSTEM/new-project-bootstrap-checklist.md" "$TARGET_REPO/ai-system/"
cp "$SOURCE_AI_SYSTEM/role-execution-contract.md" "$TARGET_REPO/ai-system/"
cp "$SOURCE_AI_SYSTEM/orchestration-template.md" "$TARGET_REPO/ai-system/"
cp "$SOURCE_AI_SYSTEM"/prompt-*.md "$TARGET_REPO/ai-system/"

mkdir -p "$TARGET_REPO/ai-system/project-authority"
cp "$SOURCE_AI_SYSTEM/project-authority/README.md" "$TARGET_REPO/ai-system/project-authority/"
```

UI role'lari kullanilacaksa:

```bash
cp -R "$SOURCE_AI_SYSTEM/design" "$TARGET_REPO/ai-system/"
```

### 2.2 Create Project-Instance Files From Templates

```bash
mkdir -p \
  "$TARGET_REPO/ai-system/product" \
  "$TARGET_REPO/ai-system/project-authority" \
  "$TARGET_REPO/ai-system/features"

cp "$TARGET_REPO/ai-system/templates/product-prd.template.md" \
  "$TARGET_REPO/ai-system/product/product-prd.md"

cp "$TARGET_REPO/ai-system/templates/feature-board.template.md" \
  "$TARGET_REPO/ai-system/feature-board.md"

cp "$TARGET_REPO/ai-system/templates/system-state.template.md" \
  "$TARGET_REPO/ai-system/system-state.md"
```

`Project Setup` rolunu kullanacaksan veya backend/build doğrulaması yapılacaksa:

```bash
cp "$TARGET_REPO/ai-system/templates/setup-manifest.template.md" \
  "$TARGET_REPO/ai-system/project-authority/setup-manifest.md"
```

Release/deployment gate, CI/CD veya rollback authority gerekiyorsa `project-release.template.md` kopyalanir ve placeholder alanlari gercek proje bilgileriyle doldurulur:

```bash
cp "$TARGET_REPO/ai-system/templates/project-release.template.md" \
  "$TARGET_REPO/ai-system/project-authority/release.md"
```

### 2.3 İlk Feature Klasörü

İlk feature klasörünü kullanıcı oluşturmaz. Bu adım Tech Lead'e devredilmiştir.

`product-prd.md` ve `feature-board.md` doldurulduktan sonra:

```text
Run Tech Lead. Yeni proje bootstrap yap.
```

Tech Lead bu komutla:

* `features/` altında ilk feature klasörünü oluşturur
* `prd.md`, `architecture.md`, `orchestration.md` dosyalarını üretir
* `feature-board.md` ve `system-state.md`'yi günceller

---

## 3. File Fill Standard

### Must Be Filled Before First `Run Tech Lead`

Bu dosyalar `Run Tech Lead` öncesi dolu olmalıdır. Önerilen yol: kullanıcı `Run Product Owner` çalıştırarak bu dosyaları üretir. Alternatif: template'ten elle doldurulabilir.

* `product/product-prd.md` — `Run Product Owner` ile üretilir (canonical); alternatif: kullanıcı template'ten elle doldurur
* `feature-board.md` — `Run Product Owner` ile üretilir (canonical); alternatif: kullanıcı template'ten oluşturur
* `system-state.md` — `Run Product Owner` ile üretilir (canonical); alternatif: kullanıcı template'ten oluşturur
* `project-authority/platform.md` — Greenfield'da `Run Tech Lead` tarafından üretilir; kullanıcı elle doldurmamalı. Brownfield'da kullanıcı mevcut codebase'den çıkarır. Client stack burada net olmalıdır: standart app client mı, `game (Unity)` mi?

Tech Lead tarafindan ilk turda uretilecek dosyalar:

* `features/{feature}/prd.md`
* `features/{feature}/architecture.md`
* `features/{feature}/orchestration.md`

### Must Be Filled Before Specific Role Use

* `project-authority/setup-manifest.md`
  * `Run Project Setup` oncesi
  * backend-touching `Run QA` oncesi
  * canonical build/test/boot komutları gerektiren her doğrulama oncesi
* `project-authority/release.md`
  * `Run DevOps/Release Engineer` oncesi
  * deployment, rollback, CI/CD veya release readiness gate'i gerekiyorsa
  * Unity/iOS app store distribution, TestFlight, IAP catalog, ATT veya Privacy Manifest gate'i varsa
* `features/{feature}/analysis.md`
  * `Run Technical Analyst` gerekiyorsa
* `features/{feature}/ui-design.md`
  * `Run UI Designer` gerekiyorsa
  * Unity oyunlarda meta ekran veya Game Visual/HUD Direction handoff'u gerekiyorsa

### Should Not Be Blank

Asagidaki dosyalar tamamen bos acilmaz:

* `product-prd.md`
* `platform.md`
* `feature-board.md`
* `system-state.md`

Kural:

* placeholder skeleton kabul edilir
* tamamen bos markdown kabul edilmez

---

## 4. What Each Startup File Should Contain

### `product/product-prd.md`

Asgari olarak:

* product overview
* business goals
* target users
* core capabilities
* high-level flows
* feature list
* acceptance criteria

### `project-authority/platform.md`

Asgari olarak:

* stack
* API / contract rules
* auth / permission rules
* persistence / runtime rules
* testing strategy
* security / observability

### `project-authority/setup-manifest.md`

Asgari olarak:

* workspace targets
* scaffold recipe
* canonical build command
* canonical test command
* canonical boot command
* safety rules

### `feature-board.md`

Asgari olarak:

* status table
* priority ordering
* active phase
* active owner

### `system-state.md`

Asgari olarak:

* initialization status
* authority references
* active feature
* current phase / role / reason
* next expected action
* risks

### `features/{feature}/prd.md`

Asgari olarak:

* summary
* in scope / out of scope
* user stories
* acceptance criteria
* edge cases

### `features/{feature}/architecture.md`

Asgari olarak:

* actors / permissions
* entry / exit paths
* invalid / terminal behavior
* API / event contract
* validation ownership
* state / flow semantics
* QA focus

### `features/{feature}/orchestration.md`

Asgari olarak:

* current status
* current owner
* active task ledger
* open tasks
* blockers
* last decision
* next role
* next action
* qa scope (Tech Lead QA handoff öncesi yazar: `backend-only / client-only / end-to-end / ui-handoff-compliance`)
* release scope (Tech Lead release handoff öncesi yazar: `none / ci-cd-only / deploy-preview / staging / production-readiness / rollback-readiness`)

---

## 5. User Command Standard

Execution modeli `Run [Canonical Role]` formatindadir.
Exact role label kullan:

* `Run Tech Lead`
* `Run Technical Analyst`
* `Run UI Designer`
* `Run Backend Developer`
* `Run Frontend/Mobile Developer`
* `Run Game Developer (Unity)`
* `Run DevOps/Release Engineer`
* `Run QA`
* `Run Project Setup`

Kural:

* alias kullanma
* kisaltma kullanma
* `Run FE`, `Run Backend`, `Run PM` gibi komutlar canonical degildir

### Incident / Issue Intake Standard

Sorun bildirimi icin tek canonical giris noktasi Tech Lead'dir:

* `Run Tech Lead. Incident: <free text>`
* `Run Tech Lead. Sorun Tespiti: <free text>`

Opsiyonel:

* `Evidence: ...`
* `Scope: ...`

Kural:

* `Run QA. Sorun Tespiti: ...` kullanma
* `Run Backend Developer. Incident: ...` kullanma
* once Tech Lead triage yapar, sonra gerekli role yonlendirir

---

## 6. Recommended Command Flow

### New Project Kickoff

Adım 1 — PO ile başla:

```text
Run Product Owner. Yeni proje: <ürün tanımı>
```

Adım 2 — Çıktıları onayladıktan sonra Tech Lead:

```text
Run Tech Lead. Yeni proje bootstrap yap.
```

### Brownfield Kickoff

Once `product-prd.md`, `feature-board.md`, `system-state.md`, `project-authority/platform.md` ve gerekiyorsa `project-authority/setup-manifest.md` baseline'ini kur:

```text
Run Tech Lead. Brownfield onboarding yap. Mevcut codebase'i referans al, project authority ve ilk managed feature baseline'ini kur.
```

### New Feature Intake

Mevcut bir feature tamamlandıktan sonra yeni kapsam eklenecekse:

```text
Run Product Owner. Revise: <yeni feature veya kapsam tanımı>
```

PO revision onaylandıktan sonra:

```text
Run Tech Lead
```

Tech Lead aktif feature listesinden bir sonraki feature'ı seçer ve başlatır.

### Resume Assigned Work

Tech Lead already assigned ise:

```text
Run Backend Developer
Run Frontend/Mobile Developer
Run Game Developer (Unity)
Run DevOps/Release Engineer
Run QA
Run Technical Analyst
Run UI Designer
```

### After QA

```text
Run Tech Lead
```

### Bug / Incident

```text
Run Tech Lead. Incident: <problem statement>
```

---

## 7. Project Command Standard Inside `setup-manifest.md`

Prompt katmanina stack komutu yazma.
Proje komutlari yalniz `project-authority/setup-manifest.md` icinde tutulur.

Minimum standard:

* `Build: <one canonical command>`
* `Test: <one canonical command>`
* `Boot / dev run: <one canonical command>`
* `Extra verification: <optional command>`

Rules:

* her amac icin tek canonical komut yaz
* birden fazla alternatif komut yazma
* workspace varsa komutu workspace-qualified yaz
* rol kararini prompt'a degil manifest'e bagla

Good:

```text
Build: <single canonical build command>
Test: <single canonical test command>
Boot / dev run: <single canonical run command>
```

Bad:

```text
Build: npm run build / pnpm build / yarn build
Test: ask Tech Lead
Boot: choose one depending on context
```

---

## 8. Minimal Startup Checklist

1. Reusable core'u kopyala.
2. `Run Product Owner. Yeni proje: <ürün tanımı>` komutu ile başla.
   * Product Owner `product-prd.md`, `feature-board.md` ve `system-state.md` dosyalarını üretir.
   * Gerekirse soru sorar, cevapları al, sonra dosyaları üretir.
3. Çıktıları gözden geçir. Değişiklik varsa: `Run Product Owner. Revise: <kapsam>`
4. `Run Tech Lead. Yeni proje bootstrap yap.` komutu ile devam et.
   * Tech Lead `platform.md` üretir, ilk feature klasörünü açar (`prd.md`, `architecture.md`, `orchestration.md`).
5. Scaffold, backend veya build/test doğrulaması gerekiyorsa `setup-manifest.md` doldur.
6. Proje henüz scaffold edilmemişse `Run Project Setup` ile scaffold başlat.

---

## 8.1 Token Cost Audit

Kurulumdan sonra reusable core maliyetini izlemek icin:

```bash
sh ai-system/tools/token-cost-audit.sh ai-system
```

Opsiyonel kontroller:

```bash
sh ai-system/tools/token-cost-audit.sh ai-system --role qa
sh ai-system/tools/token-cost-audit.sh ai-system --role unity
sh ai-system/tools/token-cost-audit.sh ai-system --estimator auto
sh ai-system/tools/token-cost-audit.sh ai-system --baseline <approved-baseline> --budget <project-budget>
```

Kural:

* Bu arac manuel diagnostic aracidir; hicbir rol tarafindan zorunlu runtime input olarak okunmaz.
* Default rapor dependency-free `chars/4` tahminidir; trend takibi ve buyuk dosya tespiti icindir.
* Ilk implementasyonda `--baseline/--budget` zorunlu degildir; once proje baseline'i kaydedilir.
* Sonraki core guncellemelerinde `--baseline <approved-baseline> --budget <project-budget>` regression kontrolu olarak kullanilir.
* `--estimator auto`, `python3+tiktoken` varsa tokenizer sayimi kullanir; yoksa `chars/4` fallback ile devam eder.
* Feature artifact'lari proje ve aktif feature'a gore degistigi icin static baseline disindadir.

---

## 9. Daily Working Rule

* Yeni scope -> once `Run Tech Lead`
* Yeni bug / problem -> once `Run Tech Lead. Incident: ...`
* Role execution -> yalniz atanmis role `Run [Role]`
* QA verdict sonrasi -> tekrar `Run Tech Lead`
* Release readiness sonrasi -> tekrar `Run Tech Lead`
* Scaffold gerekiyorsa -> yalniz o durumda `Run Project Setup`
* `Consumed Signals` varsa ve ilgili unresolved question yoksa downstream roller consumed artifact'i tekrar okumaz
* Delivery artifact'larinda bos `N/A` / placeholder bolumleri uretme; blocker veya conflict varsa mutlaka yaz
