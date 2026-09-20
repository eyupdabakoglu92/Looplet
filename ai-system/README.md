# AI System — Kullanım Rehberi

> Yeni ya da mevcut bir projeye sistemi nasıl kuracağını ve günlük nasıl çalışacağını baştan sona anlatır.

---

## Sistem Nedir (30 Saniyede)

Bu sistem, herhangi bir AI aracını **11 farklı yazılım rolünde** çalıştıran bir orkestrasyon çerçevesidir. Her rol ayrı bir prompt dosyasına sahiptir; AI aracı o promptu okuyarak yazılım ekibinin ilgili üyesi gibi davranır.

| Rol | Komut | Ne Üretir |
|---|---|---|
| Product Owner | `Run Product Owner` | product-prd.md, feature-board.md, system-state.md |
| Tech Lead | `Run Tech Lead` | platform.md, orchestration.md, architecture.md |
| Technical Analyst | `Run Technical Analyst` | analysis.md |
| Content Designer | `Run Content Designer` | content-design.md + gerçek authored content asset'leri |
| UI Designer | `Run UI Designer` | ui-design.md + rendered visual evidence; ilk UI işinde gerekirse project Design Foundation |
| Backend Developer | `Run Backend Developer` | backend.md + gerçek kod |
| Frontend/Mobile Developer | `Run Frontend/Mobile Developer` | frontend.md + gerçek kod |
| Game Developer (Unity) | `Run Game Developer (Unity)` | game-dev.md + gerçek Unity proje dosyaları (yalnız client stack Unity/mobil oyunsa) |
| DevOps/Release Engineer | `Run DevOps/Release Engineer` | release.md + CI/CD/deployment config |
| QA | `Run QA` | modüler QA planına göre qa.md + bağımsız test verdict |
| Project Setup | `Run Project Setup` | scaffold/bootstrap |

---

## Dosya Hareketleri — Ne Yapılır, Kim Yapar

Her dosya için yapılacak tek bir aksiyon var:

| Dosya / Klasör | Yapılacak İşlem | Kim Yapar |
|---|---|---|
| `prompts/` | bu repodan **kopyala** | sen (kurulum) |
| `prompt-*.md` | bu repodan **kopyala** | sen (kurulum) |
| `role-execution-contract.md` | bu repodan **kopyala** | sen (kurulum) |
| `orchestration-template.md` | bu repodan **kopyala** | sen (kurulum) |
| `templates/` | bu repodan **kopyala** | sen (kurulum) |
| `tools/` | bu repodan **kopyala** | sen (kurulum) — audit/diagnostic için |
| `design/` | bu repodan **kopyala** | sen (kurulum) — UI kullanacaksan |
| `README.md` | bu repodan **kopyala** | sen (kurulum) |
| `new-project-adoption-guide.md` | bu repodan **kopyala** | sen (kurulum) |
| `new-project-bootstrap-checklist.md` | bu repodan **kopyala** | sen (kurulum) |
| `project-authority/README.md` | bu repodan **kopyala** | sen (kurulum) |
| — | — | — |
| `product/product-prd.md` | Product Owner **oluşturur ve doldurur** | Product Owner |
| `feature-board.md` | Product Owner **oluşturur ve doldurur** | Product Owner |
| `system-state.md` | Product Owner **oluşturur ve doldurur** | Product Owner |
| `project-authority/platform.md` | Greenfield: Tech Lead üretir / Brownfield: **sen doldurursun** | Tech Lead veya sen |
| `project-authority/setup-manifest.md` | Scaffold veya backend/build doğrulaması varsa **doldurulur** | sen veya Tech Lead |
| `project-authority/release.md` | Release/deployment gate gerekiyorsa Greenfield: Tech Lead üretir / Brownfield: **sen doldurursun** | Tech Lead veya sen |
| `project-authority/design-foundation.md` | İlk user-facing işte UI Designer draft/render üretir; kullanıcı/Product Owner/yetkili Tech Lead direction seçer | UI Designer + selection authority |
| — | — | — |
| `features/{feature}/` | **dokunma** — Tech Lead oluşturur | Tech Lead |
| `bugs/`, `incidents/` | **dokunma** — delivery sırasında oluşur | AI rolleri |
| `system-history.md` | **dokunma** — delivery sırasında oluşur | AI rolleri |

---

## Yeni Projeye Kurulum (Greenfield)

### Adım 1 — Reusable Core'u Kopyala

```bash
SOURCE="<ai-system-core repo>/ai-system"
TARGET="<yeni proje repo>/ai-system"

mkdir -p "$TARGET"

cp -R "$SOURCE/prompts"                            "$TARGET/"
cp -R "$SOURCE/templates"                          "$TARGET/"
cp -R "$SOURCE/tools"                              "$TARGET/"   # audit/diagnostic için
cp -R "$SOURCE/design"                             "$TARGET/"   # UI kullanacaksan
cp    "$SOURCE/README.md"                          "$TARGET/"
cp    "$SOURCE/role-execution-contract.md"         "$TARGET/"
cp    "$SOURCE/orchestration-template.md"          "$TARGET/"
cp    "$SOURCE"/prompt-*.md                        "$TARGET/"
cp    "$SOURCE/new-project-adoption-guide.md"      "$TARGET/"
cp    "$SOURCE/new-project-bootstrap-checklist.md" "$TARGET/"

mkdir -p "$TARGET/project-authority"
cp "$SOURCE/project-authority/README.md"           "$TARGET/project-authority/"
```

### Adım 1.1 — Kurulum Kontrolü

Hedef proje repo kökünde kurulum kontrolünü çalıştır. Workflow audit için Node.js 18+ gerekir; ek paket gerekmez:

```bash
sh ai-system/tools/token-cost-audit.sh ai-system
sh ai-system/tools/workflow-state-audit.sh ai-system
```

Bu kontrol role activation adımı değildir. Henüz PO dosyaları yoksa workflow audit eksik state raporlar; PO bootstrap sonrası yeniden çalıştır. Starter-only PASS, canlı rol akışının doğrulandığı anlamına gelmez.

### Adım 2 — Product Owner ile Başla

```
Run Product Owner. Yeni proje: <ürün tanımı>
```

Product Owner gerekli dizinleri ve dosyaları (`product-prd.md`, `feature-board.md`, `system-state.md`) otomatik olarak oluşturur ve doldurur. Ayrı bir dosya oluşturma adımı yoktur.

Revize gerekiyorsa:

```
Run Product Owner. Revise: <kapsam>
```

### Adım 3 — Tech Lead ile Bootstrap

```
Run Tech Lead. Yeni proje bootstrap yap.
```

Tech Lead şunları üretir:
- `project-authority/platform.md`
- release/deployment gate gerekiyorsa `project-authority/release.md`
- `features/<ilk-feature>/prd.md`
- `features/<ilk-feature>/architecture.md`
- `features/<ilk-feature>/orchestration.md`
- `feature-board.md` ve `system-state.md` güncellenir

İlk user-facing feature ise Tech Lead ayrıca `Visual Scope` sınıflandırır. Seçilmiş Design Foundation yoksa UI Designer foundation + rendered direction task'ı implementation'dan önce planlanır.

### Adım 4 — Scaffold (Gerekiyorsa)

Proje henüz iskelet kurulmamışsa:

```
Run Project Setup
```

Project Setup normalde yalnız ilk scaffold için çalışır. Tech Lead, tamamen yeni workspace/service/infra için target boundary'si açık bir scoped re-entry açabilir.

---

## Mevcut Projeye Kurulum (Brownfield)

### Adım 1 — Reusable Core'u Kopyala

Yukarıdaki Greenfield Adım 1 ile aynı shell komutlarını çalıştır.

Ardından hedef proje repo kökünde aynı kurulum kontrolünü çalıştır:

```bash
sh ai-system/tools/token-cost-audit.sh ai-system
```

Bu brownfield onboarding'i başlatmaz; sadece `ai-system/` kurulumunun okunabilir ve ölçülebilir olduğunu doğrular.

### Adım 2 — Product Owner ile Ürünü Belgele

```
Run Product Owner. Yeni proje: <mevcut ürün özeti>
```

Mevcut codebase'den bilinen kısıtları (tech stack, entegrasyonlar, bağımlılıklar) ürün tanımına ekle. Product Owner dosyaları otomatik oluşturur ve doldurur.

Revize gerekiyorsa:

```
Run Product Owner. Revise: <kapsam>
```

### Adım 3 — platform.md'yi Sen Doldur

Brownfield'da gerçek stack zaten belli; `project-authority/platform.md`'yi mevcut codebase'den kendin çıkar.

Minimum içerik:
- tech stack (dil, framework, DB, servisler)
- API / contract kuralları
- auth / permission stratejisi
- persistence / runtime kuralları
- test stratejisi
- güvenlik ve observability
- release / deployment / rollback stratejisi gerekiyorsa `release.md`

### Adım 4 — setup-manifest.md'yi Doldur

Brownfield'da canonical komutlar mevcut codebase'den çıkarılmalıdır:
- build komutu
- test komutu
- boot / dev run komutu
- workspace hedefleri

Backend içeren veya QA build/test gate'i gerektiren projelerde `project-authority/setup-manifest.md` zorunludur.

### Adım 4.1 — release.md'yi Doldur (Gerekiyorsa)

Deployment, CI/CD, preview/staging, production readiness, rollback, secret/config ownership veya observability gate'i gerekiyorsa `project-authority/release.md` mevcut codebase ve deployment platformundan çıkarılmalıdır.

Minimum içerik:
- environment listesi: local/development/test/preview/staging/production
- CI/CD required gate'leri
- Docker/containerization policy: Dockerfile, compose, image build/run, registry ve scan beklentisi
- deployment ve promotion stratejisi
- rollback / recovery planı
- secrets ve config ownership
- smoke / health / observability beklentileri

### Adım 5 — Tech Lead ile Onboarding

```
Run Tech Lead. Brownfield onboarding yap.
```

Tech Lead:
- `features/` boşsa `product-prd.md` ve `feature-board.md`'den ilk managed feature'ı seçer
- `prd.md`, `architecture.md`, `orchestration.md` üretir
- Mevcut bug / rework varsa incident mantığıyla alır; yeni feature olarak açmaz

> İlk brownfield feature için: tüm projeyi tek feature yapma. Gerçek anlamda geliştirilecek küçük bir alan seç.

---

## Günlük Kullanım — Komut Akışı

### Standart Feature Döngüsü

Her komutta yalnız atanmış rolü çalıştır; bütün roller her feature'da zorunlu değildir. Current Owner ve Next Role şimdi çalışacak rolü gösterir. Sonraki teslim adımı Tech Lead'in Handoff Plan'ından çözülür.

```text
Run Tech Lead
  → scope, contract, dependency/task kuyruğu ve handoff planı

Run Technical Analyst          (gerekiyorsa)
Run Tech Lead                  (analiz kararlarını contract'a taşır)

Run Project Setup              (gerekiyorsa)
Run Tech Lead                  (scaffold ve doğrulama checkpoint'i)

Run [atanmış delivery rolü]
  → UI, content, backend veya ilgili client; yalnız planlanan sırada
  → açık planla delivery rollerine geçebilir; QA öncesi Tech Lead gerekir

Run Tech Lead
  → delivery reconciliation; QA scope/stage/modules/depth/evidence-reuse/task ataması

Run QA
  → yalnız seçili QA modüllerini yükler; release yoksa final, release gerekiyorsa functional stage
Run Tech Lead
  → defect / decision / missing evidence için ilgili recovery rotası

Release gerekiyorsa:
  Run DevOps/Release Engineer
  Run Tech Lead                → release kanıtını uzlaştırır; QA final atar
  Run QA                       → final acceptance
  Run Tech Lead                → closure koşulları tamamsa Done
```

Functional Approved veya Release Ready tek başına Done değildir. Approved / Approved with Notes yalnız final QA sonucudur. Belirsiz plan, blocker veya eksik kanıtta otomatik QA/client fallback'i yerine Tech Lead'e dönülür.

---

## Mobil Uygulama vs Unity Mobil Oyun

Client rolü `project-authority/platform.md` içindeki client stack kararına göre seçilir:

| Proje / Feature tipi | Client rolü | Delivery artifact | Not |
|---|---|---|---|
| Web, React Native, Flutter, native mobile veya standart app client | `Run Frontend/Mobile Developer` | `frontend.md` | UI Designer handoff'u varsa frontend bunu uygular |
| Unity tabanlı mobil oyun | `Run Game Developer (Unity)` | `game-dev.md` | Frontend/Mobile Developer yerine geçer; aynı feature'da iki client owner kullanılmaz |

Unity mobil oyunlarda ek farklar:

* `platform.md` içinde `Client Type: game (Unity)`, Unity version, render pipeline, iOS target, IAP provider ve ATT kullanımı açık olmalıdır.
* UI Designer meta ekranlar (menü, ayarlar, mağaza) için her zaman devreye alınabilir.
* Yeni HUD sistemi, FTUE/tutorial overlay, win/lose/reward reveal, premium polish veya reference-title hedefi varsa UI Designer `Game Visual/HUD Direction` üretir; Game Developer (Unity) bunu Unity içinde uygular.
* QA `client-only` scope'u `frontend.md` veya `game-dev.md` üzerinden yorumlar; Unity scope'ta Game Client Quality, Game Visual & Feel Quality ve iOS Platform Compliance kontrolleri devreye girebilir.
* Release gate varsa DevOps/Release Engineer Unity batchmode build, Xcode archive/signing, TestFlight, IAP catalog, ATT ve `PrivacyInfo.xcprivacy` readiness yüzeylerini değerlendirir.
* Visual scope'ta text-only handoff yetmez: selected source render, gerçek game runtime capture ve motion-critical işte video evidence gerekir.

Pratik kural: Unity oyun projesinde client work için komutu kendin seçme; `orchestration.md -> Next Role` ne diyorsa onu çalıştır. Belirsizse `Run Tech Lead` ile routing netleştirilir.

---

## Token / Context Politikası

Bu sistemde token optimizasyonu prompt davranışını zayıflatmak için değil, gereksiz okuma ve boş artifact üretimini azaltmak için uygulanır.

* Tech Lead input okumayı staged yapar; UI referanslarını yalnız UI scope varsa, release authority'yi yalnız release/deployment scope varsa okur.
* `orchestration.md` içindeki opsiyonel `Consumed Signals` yalnız okuma optimizasyonudur; authority üretmez ve source artifact'i silmez.
* `analysis.md` consumed edilmişse ve ilgili unresolved question yoksa downstream roller `architecture.md` authority'siyle devam eder.
* Backend, Frontend, Game Developer ve DevOps delivery artifact'ları brief-first / scope-gated yazılır; boş `N/A`, `Yok` veya placeholder bölümleri üretilmez.
* QA her turda küçük core prompt'u yükler; `backend-security`, `client-ui`, `visual-quality`, `stateful-flow`, `unity-ios`, `content` ve `release` modüllerinden yalnız Tech Lead'in scope/risk planında seçtiklerini okur.
* Regression depth `targeted / impacted / full` olarak önceden kilitlenir. Full coverage geçerli fingerprint'li kanıtı körlemesine yeniden çalıştırmaz; değişen ve belirsiz yüzeyi yeniden doğrular.
* Functional/final turlar arasında evidence ancak source/config/dependency/target fingerprint'i geçerliyse yeniden kullanılır. Her QA turunda en az bir kritik bağımsız probe korunur.
* Blocker, unresolved conflict, missing evidence veya partial delivery hiçbir zaman scope-gating gerekçesiyle saklanmaz.
* Testin yazılması/CI'a eklenmesi çalıştırılmış kanıt değildir; build, boot değildir; mock/override production-shaped runtime değildir.
* Live snapshot'lar yalnız current state taşır; geçmiş `system-history.md` veya feature history artifact'ına gider.

Tekrarlanabilir maliyet kontrolü:

```bash
sh ai-system/tools/token-cost-audit.sh ai-system
sh ai-system/tools/workflow-state-audit.sh ai-system
```

Opsiyonel audit kontrolleri:

```bash
sh ai-system/tools/token-cost-audit.sh ai-system --role qa
sh ai-system/tools/token-cost-audit.sh ai-system --role unity
sh ai-system/tools/token-cost-audit.sh ai-system --estimator auto
sh ai-system/tools/token-cost-audit.sh ai-system --baseline <approved-baseline> --budget <project-budget>
node ai-system/tools/qa-preflight.mjs ai-system
```

Kurulum notu:

* Yeni veya mevcut projeye ilk implementasyonda `--baseline/--budget` zorunlu değildir.
* İlk audit çıktısındaki `Estimated tokens selected` değeri proje için başlangıç baseline'ı olarak kaydedilebilir.
* Sonraki core güncellemelerinde `--baseline <approved-baseline> --budget <project-budget>` regression kontrolü olarak kullanılır.
* `--estimator auto`, `python3+tiktoken` varsa tokenizer sayımı kullanır; yoksa mevcut `chars/4` tahminine güvenli şekilde düşer.
* `--estimator tiktoken` explicit moddur ve paket yoksa kontrollü hata verir.
* `qa-preflight.mjs` aktif QA feature'ının modül/depth/reuse planını ve required input'larını read-only doğrular; test veya verdict üretmez.

### Yeni Feature Ekle

```
Run Product Owner. Revise: <yeni feature tanımı>
```

Onaylandıktan sonra:

```
Run Tech Lead
```

### Bug / Incident

```
Run Tech Lead. Incident: <problem statement>
```

Tech Lead triage yapar; gerekli role yönlendirir. Hiçbir zaman `Run QA. Incident:`, `Run Backend Developer. Incident:`, `Run Game Developer (Unity). Incident:` veya `Run DevOps/Release Engineer. Incident:` kullanma.

### Bekleyen kullanıcı kararı

Tech Lead açık bir karar kimliği verdiyse:

```text
Run Tech Lead. Decision: <decision-id> — <karar>
```

Karar ürün gereksinimini değiştiriyorsa Product Owner revision ve Tech Lead resync ile devam edilir.

### Resume (Devam)

Hangi role atandıysa doğrudan çalıştır:

```
Run Backend Developer
Run Frontend/Mobile Developer
Run Game Developer (Unity)
Run Content Designer
Run DevOps/Release Engineer
Run QA
```

---

## Komut Standardı

Exact canonical label kullan. Alias ve kısaltma yasak.

| Doğru | Yanlış |
|---|---|
| `Run Tech Lead` | `Run TL`, `Run Lead` |
| `Run Backend Developer` | `Run Backend`, `Run BE` |
| `Run Frontend/Mobile Developer` | `Run FE`, `Run Frontend` |
| `Run Game Developer (Unity)` | `Run Game Dev`, `Run Unity` |
| `Run Content Designer` | `Run Content`, `Run CD` |
| `Run DevOps/Release Engineer` | `Run DevOps`, `Run Release`, `Run Deployment` |
| `Run Product Owner` | `Run PO`, `Run PM` |
| `Run QA` | `Run Tests`, `Run Tester` |

---

## Kritik Kurallar

1. **`role-execution-contract.md` normatif otoritedir.** Çelişki varsa o kazanır.
2. **`architecture.md` olmadan** Content Designer, UI Designer, Backend, Frontend, Game Developer (Unity), DevOps/Release Engineer, QA başlatılamaz.
3. **Global state'i Tech Lead senkronlar.** PO ilk dosyaları oluşturabilir; revision sırasında yalnız product PRD ve feature board'u değiştirir, ardından Tech Lead resync zorunludur.
4. **Reusable core'a proje-spesifik içerik yazma.**
5. **Sorun bildirimi her zaman Tech Lead ile açılır** — role-targeted intake yoktur.
6. **Project Setup feature implementation rolü değildir.** Yalnız ilk scaffold veya Tech Lead'in açık scoped new-workspace/service/infra re-entry'si için çalışır.
7. **Production deploy varsayılan değildir.** Release authority ve explicit approval olmadan DevOps/Release Engineer production deploy yapmaz.
8. **Scope-gating bilgi saklama değildir.** Conflict, blocker veya eksik kanıt varsa ilgili rol bunu açıkça raporlar.
9. **Handoff/Done öncesi state audit zorunludur.** Delivery local handoff için `--local`, Tech Lead global sync/kapanış için varsayılan full modu kullanır; görev, owner, QA/release ve kapanış gate'leri denetlenir.
10. **Görsel kalite runtime'da kanıtlanır.** Visual scope'ta seçilmiş Design Foundation, rendered exploration, implementation parity ve bağımsız QA 93+ olmadan feature kapanmaz.

State audit'in genel regresyon testleri (Node.js 18+):

```bash
node --test ai-system/tools/tests/*.test.mjs
```

Testler geçici, ürün bağımsız fixture'lar kullanır. Workflow audit Node.js 18+ ile paket kurulumu olmadan çalışır; dosya değiştirmez.

* Varsayılan full: yapısal kontrol + görev/rol/dependency, stage/verdict, karar, revision ve global snapshot tutarlılığı.
* `--local`: delivery sonrası geçici global owner/status farkına izin verir; görev, karar ve kapanış gate'lerini gevşetmez.
* `--structure-only`: Node gerektirmeyen biçim/bütçe tanısıdır; handoff veya Done gate'i yerine kullanılamaz.
* Audit, kanıtın gerçekten çalıştırıldığını, ürün contract'ının doğruluğunu veya AI'ın talimatları uyguladığını kanıtlamaz. Bunlar role review sorumluluğudur.

### Mevcut Kurulumda Core Güncellemesi

Reusable prompt/standard/template/tools güncellenir; canlı PRD, authority, board, system-state ve feature artifact'ları starter dosyalarla ezilmez. Önce değişiklikleri incele, ardından `Run Tech Lead. Core güncellemesi sonrası state resync yap.`

Tech Lead, canlı orchestration'ları yeni şemaya dönüştürür: gerçek Feature ID, explicit ledger/dependency/status, Handoff Plan, Delivery Review, QA Stage/Result, QA Modules/Regression Depth/Evidence Reuse, Release Result, Pending Evidence ve Open Decision Gates. Yeni/reopened UI işlerinde ayrıca Visual Scope, Design Foundation, Visual Quality Gate ve Visual Evidence alanları eklenir. Global board'a Pending Product Revision / Revision Affected Features eklenir. Eski Next Role'un anlamı tahmin edilmez; mevcut görevden current owner ve sonraki plan ayrı çözülür. Geçmiş kanıt fingerprint doğrulanmadan Accepted, Approved veya PASS için yeniden kullanılmaz. Eksik kanıt açık kalır; geçersiz Done durumları yeniden değerlendirilir. Legacy visual veya QA-plan alanlarının yokluğu tek başına geçmiş feature'ı bozmaz; yeni teslim/QA checkpoint'inde normalize edilir.

Bütçe ve scope sınırları: `role-execution-contract.md → Live Snapshot Hygiene`.

---

## Troubleshooting

| Durum | Çözüm |
|---|---|
| AI aracı rolü anlamıyor | `role-execution-contract.md` ve ilgili prompt dosyasının projede mevcut olduğunu doğrula |
| Tech Lead feature başlatmıyor | `product-prd.md` ve `feature-board.md`'nin dolu olduğunu kontrol et |
| QA FAIL verdi | `Run Tech Lead` — yeniden triage; FAIL olan task'lar reopen olarak ele alınır |
| Brownfield'da scope belirsiz | Önce küçük bir feature seç; "tüm projeyi tek feature yap" hatasından kaçın |
| platform.md boş | Brownfield'da bunu sen dolduruyorsun; Greenfield'da Tech Lead üretiyor |
| setup-manifest.md boş | Backend/build doğrulaması veya Project Setup varsa canonical build/test/boot komutlarını doldur |
| release.md boş | Deployment/CI-CD/release gate gerekiyorsa environment, gates, rollback ve approval policy'yi doldur |
| Unity oyun feature'ında hangi client rolü kullanılacak belirsiz | `platform.md` içindeki client type'ı kontrol et; `game (Unity)` ise `Run Game Developer (Unity)`, değilse `Run Frontend/Mobile Developer`; emin değilsen `Run Tech Lead` |
