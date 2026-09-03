# Prompt Alignment Matrix

> Status: SUMMARY / NON-AUTHORITATIVE
>
> Bu doküman rol yüzeylerini ve ortak beklentileri hızlı görünür kılmak için tutulur. Execution semantics, active feature/task resolution ve workflow authority için normatif kaynak `role-execution-contract.md` ve ilgili live state dosyalarıdır.

Last Updated: 2026-07-01

---

## Purpose

Bu doküman, `ai-system/prompts/` altındaki ana rollerin:

* hangi koşulda çalıştığını
* hangi input'ları kullandığını
* hangi dosyayı ürettiğini
* bir sonraki role nasıl handoff verdiğini
* mevcut sistem akışıyla ne kadar uyumlu olduğunu

tek tabloda görünür kılar.

Normatif execution authority:

* `/ai-system/role-execution-contract.md`

Read/output policy notu:

* Required Input kolonu role-level baseline'i gösterir; her dosyanın her turda tam okunacağı anlamına gelmez.
* Prompt içindeki staged read, scope-gated read ve `Consumed Signals` kuralları daha spesifikse onlar uygulanır.
* Output artifact'larında brief-first / scope-gated format esastır; blocker, conflict veya missing evidence varsa bölüm atlanamaz.

---

## Alignment Matrix

| Role | Çalışma Koşulu | Required Input | Optional Input | Output | Tipik Next Role | Uyum Durumu | Not |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Product Owner | `Run Product Owner. Yeni proje: <tanım>` veya `Run Product Owner. Revise: <kapsam>` | Kullanıcı ürün tanımı | Mevcut `product-prd.md` (revizyon modunda) | `product-prd.md`, `feature-board.md`, `system-state.md` | Tech Lead | Yüksek | Bootstrap ve revision olmak üzere iki mod var; platform.md Tech Lead'e bırakılır; kritik boşluk varsa önce soru sorar. **Delivery footer standardına dahil değildir** — PO, `orchestration.md` ile çalışmaz; handoff doğrudan kullanıcıya yönelik mesajla yapılır |
| Tech Lead | Sürecin orchestration sahibi | `feature-board.md`, `system-state.md`, `product-prd.md`, seçili feature `orchestration.md` / `prd.md` / `architecture.md`, Tech Lead supplement'leri | `project-authority/release.md`, UI referansları, `analysis.md`, `ui-design.md`, delivery artifact'ları, `release.md` scope'a göre | `feature-board.md`, `system-state.md`, `architecture.md`, `orchestration.md` | Technical Analyst / UI Designer / Backend Developer / Frontend/Mobile Developer / Game Developer (Unity) / DevOps/Release Engineer / QA / Project Setup | Yüksek | Read order staged/scope-gated; UI referansları backend-only/release-only turlarda okunmaz; state machine ve output checklist supplement dosyalardadır |
| Technical Analyst | `Current Owner = Technical Analyst` | feature `prd.md`, `role-execution-contract.md` | `product-prd.md`, `feature-board.md`, `system-state.md`, `orchestration.md`, `architecture.md` | `analysis.md` | Tech Lead | Orta-Yüksek | Seçenek analizi + recommendation verir; final karar vermez; Tech Lead kabul edilen kararları architecture'a taşıyıp consumed signal bırakabilir |
| UI Designer | `Current Owner = UI Designer` | `architecture.md`, `orchestration.md`, `role-execution-contract.md`, `system-state.md`, `design-doctrine.md`, `premium-ui-rubric.md` | `analysis.md`, `backend.md`, `frontend.md`, `game-dev.md`, `prd.md` | `ui-design.md` | Frontend/Mobile Developer (veya client stack Unity/mobil oyunsa Game Developer (Unity) — meta ekranlar veya Game Visual/HUD Direction gereken kapsam için) / Tech Lead | Yüksek | Prompt dosyaları runtime input değildir; `analysis.md` consumed ise tekrar okunmaz; contract uydurmaması gerekir |
| Backend Developer | `Current Owner = Backend Developer` | `architecture.md`, `orchestration.md`, `role-execution-contract.md`, `system-state.md` | `platform.md`, `setup-manifest.md`, `release.md`, `prd.md`, `analysis.md`, `feature-board.md` | Gerçek repo değişiklikleri + `backend.md` delivery report | Frontend/Mobile Developer / QA / Tech Lead | Yüksek | Direct-edit modunda çalışır; `backend.md` brief-first / scope-gated traceability artifact'ıdır; authority reconciliation yalnız gerçek conflict/override varsa yazılır |
| Frontend/Mobile Developer | `Current Owner = Frontend/Mobile Developer` | `architecture.md`, `orchestration.md`, `role-execution-contract.md`, `system-state.md`, `design-doctrine.md`, `premium-ui-rubric.md` | `platform.md`, `release.md`, `analysis.md`, `backend.md`, `ui-design.md` | Gerçek repo değişiklikleri + `frontend.md` delivery report | Backend Developer / QA / Tech Lead | Yüksek | Direct-edit modunda çalışır; UI handoff varsa korur; `frontend.md` brief-first / scope-gated traceability artifact'ıdır |
| Game Developer (Unity) | `Current Owner = Game Developer (Unity)` | `architecture.md`, `orchestration.md`, `role-execution-contract.md`, `system-state.md`, `platform.md` | `analysis.md`, `backend.md`, `ui-design.md`, `release.md` | Gerçek Unity proje değişiklikleri + `game-dev.md` delivery report | Backend Developer / QA / Tech Lead | Orta-Yüksek | `platform.md` client stack Unity/mobil oyun ise Frontend/Mobile Developer yerine devreye girer; direct-edit modunda çalışır; iOS ATT/Privacy Manifest/IAP etkisi varsa DevOps/Release Engineer handoff'u yazar |
| DevOps/Release Engineer | `Current Owner = DevOps/Release Engineer` | `orchestration.md`, `role-execution-contract.md`, `system-state.md`, `platform.md`, `release.md` | `setup-manifest.md`, `prd.md`, `architecture.md`, `backend.md`, `frontend.md`, `game-dev.md`, `qa.md`, `feature-board.md` | Gerçek repo değişiklikleri + feature `release.md` | QA / Tech Lead | Orta-Yüksek | Release scope yoksa çalışmaz; gate evidence yalnız applicable control satırlarını üretir; production deploy explicit release authority ve approval olmadan yapılmaz; client stack Unity/mobil oyunsa Xcode signing/TestFlight/App Store gate'lerini de kapsar |
| QA | `Current Owner = QA` ve gerekli implementasyonlar tamam | `prd.md`, `architecture.md`, `orchestration.md`, `role-execution-contract.md`, `system-state.md`; UI feature'larında design doctrine/rubric | `analysis.md`, `backend.md`, `frontend.md`, `game-dev.md`, `ui-design.md`, feature `release.md`, `project-authority/release.md` | `qa.md` | Backend Developer / Frontend/Mobile Developer / Game Developer (Unity) / UI Designer / Tech Lead | Yüksek | QA output scope matrix kullanır; mandatory evidence/verdict bölümleri korunur; UI/security/release/mode bölümleri yalnız scope varsa üretilir |
| Project Setup | `Current Owner = Project Setup` ve proje scaffold eksik | `orchestration.md`, `platform.md`, `setup-manifest.md`, `role-execution-contract.md` | `prompt-execution-gating-standard.md`, `prompt-delivery-footer-standard.md` | Scaffold edilmiş workspace / proje iskeleti | Backend Developer / Frontend/Mobile Developer / Game Developer (Unity) / QA / Tech Lead | Orta-Yüksek | Sadece scaffold ve setup recipe uygular; `backend.md` / `frontend.md` / `game-dev.md` delivery report'larını proje dosyalarına uygulamaz |

---

## Cross-Role Summary

Not:

* Aşağıdaki maddeler özet amaçlıdır
* Conflict halinde `role-execution-contract.md`, `feature-board.md`, `system-state.md` ve ilgili feature `orchestration.md` kazanır

### 1. Source of Truth

* `feature-board.md` = primary feature state
* `orchestration.md` = feature execution state
* `system-state.md` = global snapshot
* Beklenti: Tech Lead bu üç dosyayı aynı turda senkronlar

### 1.1 Authority Precedence

* `architecture.md` = contract authority
* `ui-design.md` (varsa) = visual/state authority
* `project-authority/release.md` = release/deployment authority
* `orchestration.md` = execution authority
* `feature-board.md` = feature status / priority authority
* `system-state.md` = snapshot / context
* Çelişki varsa implementation veya QA rolü bunu çözmez; Tech Lead çözer

### 1.2 Read Optimization Signals

* `orchestration.md` içindeki `Consumed Signals` bölümü authority üretmez
* Sadece downstream rollerin consumed upstream artifact'ı tekrar okuyup okumayacağını belirler
* `analysis.md` consumed edilmiş ve ilgili unresolved question yoksa downstream roller `architecture.md` authority'sini kullanır
* Task brief, blocker veya conflict açıkça `analysis.md` referansı veriyorsa ilgili bölüm yine okunur

### 1.3 Canonical Role Labels

* `Current Owner` ve `Next Role` alanlarında exact canonical role label kullanılmalıdır
* Alias, kısaltma veya yakın anlamlı varyantlar state drift sebebidir
* Rol adı normalization'ı Tech Lead sorumluluğudur

### 1.4 Active Feature Resolution

* Özet: roller aktif feature'ı önce feature-level `orchestration.md` header alanlarından çözer
* Tie-breaker, ambiguity ve "rol çalışmaz" koşullarının detayları `role-execution-contract.md` içindedir

### 1.5 Active Task Resolution

* Özet: `Active Task Ledger` authoritative run queue, `Open Tasks` fallback inventory'dir
* Ignore kuralları ve actionable task çözümleme detayları `role-execution-contract.md` içindedir

### 2. Contract Chain

* `prd.md` → `analysis.md` → `architecture.md` → `backend.md` / `frontend.md` (veya client stack Unity/mobil oyunsa `game-dev.md`) / `ui-design.md` → `qa.md` → gerekirse `release.md`
* `architecture.md`, backend ve frontend için contract authority kabul edilir
* `ui-design.md` varsa frontend visual/state authority olarak eklenir; client stack Unity/mobil oyunsa Game Visual/HUD Direction scope'unda Game Developer (Unity) için de authority sayılır
* `design-doctrine.md` + `premium-ui-rubric.md`, UI Designer / Frontend / Game Developer (Unity) (Game Visual/HUD Direction scope'unda) / QA / Tech Lead arasında ortak görsel kalite authority’sidir
* UI feature'larında navigation/header/back davranışı da contract zincirinin parçasıdır; yalnızca stil tercihi değildir
* Shared hero/header standardı tanımlandıysa, visual chrome token/layer parity de contract zincirinin parçasıdır; yalnız layout parity yeterli değildir
* Async state kullanan feature'larda authoritative bağlam anahtarları ve runtime lifecycle ownership de contract zincirinin parçasıdır

### 3. Rework Routing

* Backend implementasyon sorunu → Backend Developer
* Frontend implementasyon sorunu → Frontend/Mobile Developer
* Game client (Unity) implementasyon sorunu → Game Developer (Unity)
* UI handoff sorunu → UI Designer
* Release / CI-CD / deployment / rollback sorunu → DevOps/Release Engineer
* Contract / state machine / orchestration sorunu → Tech Lead
* Product requirement hatası → Tech Lead (Tech Lead gerekirse Product Owner'ı tetikler)

### 3.1 QA → Product Owner Eskalasyon Kuralı

* QA doğrudan Product Owner'ı tetikleyemez
* Product requirement hatası tespit edilirse: QA `Tech Lead Note` bölümüne yazar → Tech Lead değerlendirerek `Run Product Owner. Revise: <kapsam>` tetikler
* Implementasyon hatası ile product requirement hatası aynı `Rejected` verdict'ine karıştırılmaz; ayrı finding olarak raporlanır

### 4. Architecture Gate

* UI Designer, Frontend, Game Developer (Unity), DevOps/Release Engineer ve QA akışları feature-level `architecture.md` olmadan başlatılmamalıdır
* Contract başka feature’dan devralınsa bile bu feature içinde özet bir `architecture.md` bulunmalıdır

### 5. Terminal State Rule

* `Done` feature içinde stale `Next Role` ve stale `Next Action` bırakılmaz
* Kapalı feature, tamamlanmış role geri handoff vermez

### 5.1 Delivery vs Workflow Ownership

* Delivery rollerinin iki farklı sorumluluğu vardır:
  * gerçek repo değişikliği yapmak veya role-specific artifact üretmek
  * delivery report / verdict artifact üretmek
  * current feature `orchestration.md` içindeki local execution alanlarını güncellemek
* Global workflow/source-of-truth sync (`feature-board.md`, `system-state.md`) yalnız Tech Lead sorumluluğundadır
* Delivery artifact içindeki `Status Suggestion` tek başına global transition değildir

### 5.2 Delivery Reconciliation Rule

* Tech Lead, delivery artifact'ı yalnız completion sinyali için değil reconciliation amacıyla da okur
* Role transition öncesi en az şu sorular cevaplanmalıdır:
  * Hangi open task hangi artifact/kod alanı ile kapandı?
  * Contract authority ile uyumlu mu?
  * Analysis veya önceki notlarla çelişen yorum override edildiyse açıkça kaydedildi mi?
  * Hangi inherited davranışlar korunarak bırakıldı?
* Delivery artifact izlenebilir değilse Tech Lead otomatik handoff vermez
* Backend, frontend ve game-dev artifact'larında task-level traceability, contract compliance ve test evidence beklenir
* Authority reconciliation ve preserved behavior bölümleri yalnız gerçek conflict, override, inherited path veya regression riski varsa yazılır

### 6. Retro Bugfix Rule

* Kapanmış bir feature bug nedeniyle yeniden açılırsa aynı feature tekrar active feature olur
* Rework kapanmadan yeni feature aktivasyonu yapılmaz
* `feature-board.md`, `system-state.md` ve ilgili `orchestration.md` aynı turda senkron güncellenir
* QA verdict'i kullanıcı semptomunun giderildiğini açıkça kanıtlamalıdır

### 7. Shared Chrome Rule

* Yerleşik referans ekranlar, sonraki sibling ekranlar için shared chrome authority olabilir
* Tech Lead bu authority'yi orchestration/architecture içinde adlandırmalıdır
* UI Designer, Frontend (veya Unity meta ekranlarında/Game Visual-HUD Direction scope'unda Game Developer (Unity)) ve QA bu referans ekranı yalnız yapısal olarak değil görsel katmanlar (gradient, glow, vignette, z-index, opacity/surface hissi) üzerinden de karşılaştırmalıdır

### 8. Async Authority Rule

* REST response, socket event, background sync veya hydration ile gelen veri yalnız doğru bağlam için uygulanmalıdır
* `architecture.md`, gerektiğinde entity/resource/version/actor/scope gibi authority anahtarlarını açıkça tanımlamalıdır
* QA, stale veya out-of-order payload'ın state'i yanlış mutate etmediğini doğrulamalıdır

### 9. Runtime Lifecycle Rule

* Socket, polling, stream gibi paylaşılan runtime kaynaklarının owner katmanı açıkça belirlenmelidir
* Screen unmount cleanup ile app/session cleanup ayrımı promptlar arasında tutarlı olmalıdır
* Timing farkları (connect önce/sonra, membership önce/sonra, remount, reconnect) test kapsamına girmelidir

### 10. Boundary Semantics Rule

* Architecture'da tanımlanan state transition, sıra, queue, wrap-around, completion ve no-op boundary kuralları contract zincirinin parçasıdır
* `analysis.md`, `backend.md`, `frontend.md` veya `qa.md` bu semantiği yeniden yorumlayamaz
* QA, ordered/cyclic flow'larda full-cycle doğrulamasını açık kanıtla raporlamalıdır; ilk geçiş kanıtı tek başına yeterli değildir

### 11. Release Gate Rule

* Release/deployment etkisi olan feature'larda `project-authority/release.md` authority olarak okunmalıdır
* Tech Lead, `Release Scope` alanını `none` dışında bir değere çekerse DevOps/Release Engineer task'i açmalıdır
* DevOps/Release Engineer release readiness üretir; QA verdict'i veya Tech Lead state sync'ini override etmez
* Production deploy explicit release policy ve approval olmadan varsayılan olarak yapılmaz

---

## Residual Risks

### 1. Project Setup hala manifest kalitesine bağımlı

* `setup-manifest.md` eksik veya özet içerik taşıyorsa scaffold ve QA build gate akışı zayıflar

### 2. Technical Analyst ile Tech Lead sınırı dikkat gerektiriyor

* Analyst recommendation sunabilir
* Ama storage strategy, socket scope, persistence boundary gibi konularda final kararın Tech Lead'de kaldığı disiplin korunmalı

### 3. Template ile gerçek kullanım düzenli gözden geçirilmeli

* Yeni bir rol alanı eklenirse `orchestration-template.md` ve ilgili promptlar birlikte güncellenmeli

### 4. Delivery artifact kalitesi düşükse Tech Lead darboğazı oluşur

* Reconciliation için gerekli traceability yoksa implementasyon doğru olsa bile orchestration kalitesi düşer

### 5. PO Revision sonrası `system-state.md` senkronsuz kalabilir

* PO Revision Mode yalnız `product-prd.md` ve `feature-board.md` günceller; `system-state.md` güncellenmez
* Kullanıcı Tech Lead resync komutunu çalıştırmadan devam ederse global snapshot geçici olarak senkronsuz kalır
* Kontrol: PO revision sonrası `Run Tech Lead` komutu verildiğinde Tech Lead bu iki dosyayı karşılaştırıp gerekirse hizalamalıdır

### 6. `QA Scope` alanı doldurulmadan QA tetiklenirse scope belirsizliği kalır

* Tech Lead, orchestration.md'de `QA Scope` alanını boş bırakırsa QA kendi scope kararını artifact mevcudiyetine göre üretir
* Bu genellikle doğru sonuç verir; ancak kısmi delivery senaryosunda (backend tamam, frontend devam ediyor ama frontend.md kısmen oluştu) hatalı end-to-end scope alınabilir
* Öneri: Tech Lead QA handoff öncesi `QA Scope` alanını her zaman açıkça doldurmalıdır

### 7. `Runtime Validation Pending` verdict Tech Lead koordinasyonu gerektirir

* QA bu verdict'i ürettiğinde Tech Lead, hangi senaryoların nasıl doğrulanacağını kullanıcıyla koordine etmelidir
* Koordinasyon yapılmadan yeni feature'a geçilirse runtime kanıtsız bir feature `Done` olarak kapanabilir
* Öneri: Tech Lead, `Runtime Validation Pending` gördüğünde `system-state.md`'ye bu notu eklemeli ve feature'ı Done'a almadan önce doğrulamayı beklemeli

### 8. Security scope tespiti QA'ya bırakılmıştır

* Security testing scope'u QA'nın feature içeriğine bakarak kendi tespit etmesi gerekiyor
* Tech Lead, auth/veri/finansal içeren feature'larda `orchestration.md`'e `Security Scope: zorunlu` notu düşerse QA tespiti garantilenmiş olur; bu opsiyoneldir ama önerilen yoldur

### 9. Release gate scope'u Tech Lead tarafindan net yazilmazsa DevOps/QA ayrimi bulanabilir

* `Release Scope` bos veya muglak kalirsa DevOps/Release Engineer hangi gate'i kanitlayacagini, QA ise release-readiness compliance'i hangi seviyede kontrol edecegini net ayiramaz
* Oneri: Tech Lead release etkisi olan her feature'da `Release Scope` alanini `none / ci-cd-only / container-build / deploy-development / deploy-test / deploy-preview / staging / production-readiness / rollback-readiness` degerlerinden biriyle doldurmalidir

---

## Execution Trigger Summary (KRİTİK)

* Her rol yalnızca kullanıcının açık komutuyla (`Run [Role]`) tetiklenir
* Tech Lead için `Run Tech Lead. Incident: ...` ve `Run Tech Lead. Sorun Tespiti: ...` triage-only girişleridir
* Sorun bildirimi için canonical intake noktası Tech Lead'dir; role-targeted issue komutu kullanılmaz
* Active feature resolution, active task resolution, local/global ownership, delivery handoff ve terminal cleanup detayları `role-execution-contract.md` içinde normatif olarak tanımlıdır
* Bu doküman ambiguity çözmek için değil, hızlı cross-role görünürlük için kullanılmalıdır

### Self-Directing Flow Özeti

* Her delivery rolü teslim sonunda zorunlu `## Sonraki Komut` bölümü üretir
* Routing authority `orchestration.md → Next Role`'dur
* Tech Lead feature aktive ederken `Next Role`'u kesin yazar; delivery rolleri arası her geçişte tekrar çalışmaz
* **QA** ve **Technical Analyst** her zaman `Run Tech Lead` üretir (sabit)
* **DevOps/Release Engineer** release readiness sonrası genellikle `Run Tech Lead` üretir; pre-QA CI/CD config turunda `orchestration.md → Next Role` esas alınır
* Diğer delivery rolleri `orchestration.md → Next Role` değeri boşsa kendi varsayılan sonraki rolüne geçer
* Detaylar: `role-execution-contract.md §5.1`

Detaylı trigger ve execution kuralları için:

* `/ai-system/role-execution-contract.md`

---

## Recommended Working Order

1. Tech Lead feature seçer ve `prd.md` varlığını doğrular
2. Gerekirse Technical Analyst analiz üretir
3. Tech Lead contract + orchestration planını çıkarır
4. Gerekirse UI Designer handoff üretir
5. Backend ve client (Frontend/Mobile veya Game Developer (Unity)) implementation yapılır
6. QA verdict verir
7. Tech Lead rework, release gate veya next feature kararını verir
8. Release gate gerekiyorsa DevOps/Release Engineer `release.md` ve readiness evidence üretir
9. Tech Lead release sonucunu reconcile ederek Done veya rework/blocked kararını verir
