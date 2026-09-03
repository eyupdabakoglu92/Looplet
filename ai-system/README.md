# AI System — Kullanım Rehberi

> Yeni ya da mevcut bir projeye sistemi nasıl kuracağını ve günlük nasıl çalışacağını baştan sona anlatır.

---

## Sistem Nedir (30 Saniyede)

Bu sistem, herhangi bir AI aracını **10 farklı yazılım rolünde** çalıştıran bir orkestrasyon çerçevesidir. Her rol ayrı bir prompt dosyasına sahiptir; AI aracı o promptu okuyarak yazılım ekibinin ilgili üyesi gibi davranır.

| Rol | Komut | Ne Üretir |
|---|---|---|
| Product Owner | `Run Product Owner` | product-prd.md, feature-board.md, system-state.md |
| Tech Lead | `Run Tech Lead` | platform.md, orchestration.md, architecture.md |
| Technical Analyst | `Run Technical Analyst` | analysis.md |
| UI Designer | `Run UI Designer` | ui-design.md |
| Backend Developer | `Run Backend Developer` | backend.md + gerçek kod |
| Frontend/Mobile Developer | `Run Frontend/Mobile Developer` | frontend.md + gerçek kod |
| Game Developer (Unity) | `Run Game Developer (Unity)` | game-dev.md + gerçek Unity proje dosyaları (yalnız client stack Unity/mobil oyunsa) |
| DevOps/Release Engineer | `Run DevOps/Release Engineer` | release.md + CI/CD/deployment config |
| QA | `Run QA` | qa.md + test verdict |
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

Hedef proje repo kökünde opsiyonel diagnostic audit çalıştır:

```bash
sh ai-system/tools/token-cost-audit.sh ai-system
```

Bu kontrol role activation adımı değildir; yalnız kopyalanan reusable core ve project-instance dokümanlarının ölçülebilir durumda olduğunu gösterir.

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

### Adım 4 — Scaffold (Gerekiyorsa)

Proje henüz iskelet kurulmamışsa:

```
Run Project Setup
```

Project Setup yalnız ilk scaffold için çalışır. Sonraki adımlarda devreye girmez.

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

```
Run Tech Lead
  → prd.md + architecture.md + orchestration.md üretir, rol atar

Run Technical Analyst          (opsiyonel — karmaşık kararlar için)
  → analysis.md üretir

Run UI Designer                (opsiyonel — UI gerektiriyorsa)
  → ui-design.md üretir

Run Backend Developer
  → backend.md + kod

Run Frontend/Mobile Developer  (veya Run Game Developer (Unity) — client stack Unity/mobil oyunsa)
  → frontend.md (veya game-dev.md) + kod

Run QA
  → qa.md + test verdict (PASS veya FAIL + reopens)

Run Tech Lead                  (QA sonrası — release gate, rework veya bir sonraki feature'a geç)

Run DevOps/Release Engineer    (opsiyonel — release/deployment gate gerekiyorsa)
  → release.md + CI/CD/deployment readiness

Run Tech Lead                  (release sonrası — Done veya next feature)
```

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

Pratik kural: Unity oyun projesinde client work için komutu kendin seçme; `orchestration.md -> Next Role` ne diyorsa onu çalıştır. Belirsizse `Run Tech Lead` ile routing netleştirilir.

---

## Token / Context Politikası

Bu sistemde token optimizasyonu prompt davranışını zayıflatmak için değil, gereksiz okuma ve boş artifact üretimini azaltmak için uygulanır.

* Tech Lead input okumayı staged yapar; UI referanslarını yalnız UI scope varsa, release authority'yi yalnız release/deployment scope varsa okur.
* `orchestration.md` içindeki opsiyonel `Consumed Signals` yalnız okuma optimizasyonudur; authority üretmez ve source artifact'i silmez.
* `analysis.md` consumed edilmişse ve ilgili unresolved question yoksa downstream roller `architecture.md` authority'siyle devam eder.
* Backend, Frontend, Game Developer ve DevOps delivery artifact'ları brief-first / scope-gated yazılır; boş `N/A`, `Yok` veya placeholder bölümleri üretilmez.
* Blocker, unresolved conflict, missing evidence veya partial delivery hiçbir zaman scope-gating gerekçesiyle saklanmaz.

Tekrarlanabilir maliyet kontrolü:

```bash
sh ai-system/tools/token-cost-audit.sh ai-system
```

Opsiyonel audit kontrolleri:

```bash
sh ai-system/tools/token-cost-audit.sh ai-system --role qa
sh ai-system/tools/token-cost-audit.sh ai-system --role unity
sh ai-system/tools/token-cost-audit.sh ai-system --estimator auto
sh ai-system/tools/token-cost-audit.sh ai-system --baseline <approved-baseline> --budget <project-budget>
```

Kurulum notu:

* Yeni veya mevcut projeye ilk implementasyonda `--baseline/--budget` zorunlu değildir.
* İlk audit çıktısındaki `Estimated tokens selected` değeri proje için başlangıç baseline'ı olarak kaydedilebilir.
* Sonraki core güncellemelerinde `--baseline <approved-baseline> --budget <project-budget>` regression kontrolü olarak kullanılır.
* `--estimator auto`, `python3+tiktoken` varsa tokenizer sayımı kullanır; yoksa mevcut `chars/4` tahminine güvenli şekilde düşer.
* `--estimator tiktoken` explicit moddur ve paket yoksa kontrollü hata verir.

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

### Resume (Devam)

Hangi role atandıysa doğrudan çalıştır:

```
Run Backend Developer
Run Frontend/Mobile Developer
Run Game Developer (Unity)
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
| `Run DevOps/Release Engineer` | `Run DevOps`, `Run Release`, `Run Deployment` |
| `Run Product Owner` | `Run PO`, `Run PM` |
| `Run QA` | `Run Tests`, `Run Tester` |

---

## Kritik Kurallar

1. **`role-execution-contract.md` normatif otoritedir.** Çelişki varsa o kazanır.
2. **`architecture.md` olmadan** UI Designer, Backend, Frontend, Game Developer (Unity), DevOps/Release Engineer, QA başlatılamaz.
3. **`feature-board.md` ve `system-state.md`** yalnız Tech Lead günceller.
4. **Reusable core'a proje-spesifik içerik yazma.**
5. **Sorun bildirimi her zaman Tech Lead ile açılır** — role-targeted intake yoktur.
6. **Project Setup yalnız ilk scaffold için çalışır.** Tekrar tetiklenmez.
7. **Production deploy varsayılan değildir.** Release authority ve explicit approval olmadan DevOps/Release Engineer production deploy yapmaz.
8. **Scope-gating bilgi saklama değildir.** Conflict, blocker veya eksik kanıt varsa ilgili rol bunu açıkça raporlar.

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
