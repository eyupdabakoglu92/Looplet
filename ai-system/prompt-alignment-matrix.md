# Prompt Alignment Matrix

> Status: SUMMARY / NON-AUTHORITATIVE
>
> Bu doküman rol yüzeylerini ve ortak beklentileri hızlı görünür kılmak için tutulur. Execution semantics, active feature/task resolution ve workflow authority için normatif kaynak `role-execution-contract.md` ve ilgili live state dosyalarıdır.

Last Updated: 2026-09-17

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
| Tech Lead | Sürecin orchestration sahibi | `feature-board.md`, `system-state.md`, `product-prd.md`, seçili feature `orchestration.md` / `prd.md` / `architecture.md`, Tech Lead supplement'leri | `project-authority/release.md`, UI referansları, `analysis.md`, `content-design.md`, `ui-design.md`, delivery artifact'ları, `release.md` scope'a göre | `feature-board.md`, `system-state.md`, `architecture.md`, `orchestration.md` | Technical Analyst / Content Designer / UI Designer / Backend Developer / Frontend/Mobile Developer / Game Developer (Unity) / DevOps/Release Engineer / QA / Project Setup | Yüksek | Read order staged/scope-gated; evidence reconciliation ve state audit Done/handoff öncesi zorunludur |
| Technical Analyst | `Current Owner = Technical Analyst` | feature `prd.md`, `role-execution-contract.md` | `product-prd.md`, `feature-board.md`, `system-state.md`, `orchestration.md`, `architecture.md` | `analysis.md` | Tech Lead | Orta-Yüksek | Seçenek analizi + recommendation verir; final karar vermez; Tech Lead kabul edilen kararları architecture'a taşıyıp consumed signal bırakabilir |
| Content Designer | `Current Owner = Content Designer` | `prd.md`, `architecture.md`, `orchestration.md`, evidence standardı | `analysis.md`, `ui-design.md`, developer delivery report'u, generator/validator talimatı | Gerçek authored content asset'leri + `content-design.md` | Handoff Plan'daki delivery rolü / Tech Lead | Orta-Yüksek | Pipeline/tooling kodu developer'da, gerçek content bu roldedir; infeasible requirement'ı değiştirmez; human sign-off explicit decision gate olur |
| UI Designer | `Current Owner = UI Designer` | `architecture.md`, `orchestration.md`, execution contract, design doctrine/rubric/visual gate; visual scope'ta Design Foundation | `analysis.md`, delivery artifact'ları, `prd.md` | `ui-design.md` + rendered evidence; gerekirse Design Foundation draft | Tech Lead visual-gate checkpoint | Yüksek | Text-only direction geçmez; en az iki maddi render üretir; kendi önerisini kendi başına seçemez |
| Backend Developer | `Current Owner = Backend Developer` | `architecture.md`, `orchestration.md`, `role-execution-contract.md`, `system-state.md` | `platform.md`, `setup-manifest.md`, `release.md`, `prd.md`, `analysis.md`, `feature-board.md` | Gerçek repo değişiklikleri + `backend.md` delivery report | Handoff Plan'daki delivery rolü / Tech Lead | Yüksek | Direct-edit modunda çalışır; `backend.md` brief-first / scope-gated traceability artifact'ıdır; authority reconciliation yalnız gerçek conflict/override varsa yazılır |
| Frontend/Mobile Developer | `Current Owner = Frontend/Mobile Developer` | `architecture.md`, `orchestration.md`, execution contract; visual scope'ta selected foundation + visual standards | `platform.md`, `release.md`, `analysis.md`, `backend.md`, `ui-design.md` | Gerçek repo değişiklikleri + `frontend.md`; visual scope'ta runtime parity evidence | Tech Lead visual/QA checkpoint | Yüksek | Canonical target capture üretir; motion-critical scope static screenshot ile geçmez |
| Game Developer (Unity) | `Current Owner = Game Developer (Unity)` | `architecture.md`, `orchestration.md`, `role-execution-contract.md`, `system-state.md`, `platform.md` | `analysis.md`, `backend.md`, `ui-design.md`, `release.md` | Gerçek Unity proje değişiklikleri + `game-dev.md` delivery report | Handoff Plan'daki delivery rolü / Tech Lead | Orta-Yüksek | `platform.md` client stack Unity/mobil oyun ise Frontend/Mobile Developer yerine devreye girer; direct-edit modunda çalışır; iOS ATT/Privacy Manifest/IAP etkisi varsa DevOps/Release Engineer handoff'u yazar |
| DevOps/Release Engineer | `Current Owner = DevOps/Release Engineer` | `orchestration.md`, `role-execution-contract.md`, `system-state.md`, `platform.md`, `release.md` | `setup-manifest.md`, `prd.md`, `architecture.md`, `backend.md`, `frontend.md`, `game-dev.md`, `qa.md`, `feature-board.md` | Gerçek repo değişiklikleri + feature `release.md` | Tech Lead | Orta-Yüksek | Release scope yoksa çalışmaz; gate evidence yalnız applicable control satırlarını üretir; production deploy explicit release authority ve approval olmadan yapılmaz; client stack Unity/mobil oyunsa Xcode signing/TestFlight/App Store gate'lerini de kapsar |
| QA | Current Owner = QA; Accepted review, stage, module/depth/reuse planı ve açık QA task'ı | QA core, `prd.md`, `architecture.md`, `orchestration.md`, execution/evidence/reuse standardı | Yalnız seçili QA modülleri ve onların delivery/authority girdileri | Compact `qa.md`; seçili modül verdict'leri | Tech Lead | Yüksek | Core + conditional modules; fingerprint evidence reuse; bağımsız critical probe; visual PASS 93+/8+ ve sıfır fail condition |
| Project Setup | `Current Owner = Project Setup` ve scaffold task'ı açık | `orchestration.md`, `platform.md`, `setup-manifest.md`, `role-execution-contract.md`, evidence standardı | `prompt-execution-gating-standard.md`, `prompt-delivery-footer-standard.md` | Scaffold edilmiş workspace / proje iskeleti + command/boot evidence | Tech Lead | Orta-Yüksek | İlk scaffold veya Tech Lead'in boundary'si açık yeni workspace/service/infra re-entry'sidir; feature implementation rolü değildir |

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
* Birden fazla executable feature aynı delivery role atanmışsa global active feature ile tie-break yapılmaz; Tech Lead tek atama yapar. Blocked dahil control-plane recovery ayrı çözülür.

### 1.5 Active Task Resolution

* Özet: `Active Task Ledger` varsa boş olsa bile authoritative run queue'dur; Open Tasks yalnız ledger bölümü hiç yoksa legacy fallback'tir.
* Ignore kuralları ve actionable task çözümleme detayları `role-execution-contract.md` içindedir

### 2. Contract Chain

* `prd.md` → gerekirse `analysis.md` → `architecture.md` → kapsamlı delivery artifact'ları → Tech Lead review → `qa.md`; release gerekiyorsa functional QA → `release.md` → Tech Lead → final QA.
* `architecture.md`, backend ve frontend için contract authority kabul edilir
* `ui-design.md` varsa frontend visual/state authority olarak eklenir; client stack Unity/mobil oyunsa Game Visual/HUD Direction scope'unda Game Developer (Unity) için de authority sayılır
* Design Foundation + `design-doctrine.md` + `premium-ui-rubric.md` + `visual-quality-gate.md`, UI Designer / Frontend / Game Developer (Unity) / QA / Tech Lead arasında ortak görsel kalite authority zinciridir
* Görsel acceptance zinciri: rendered exploration → explicit selection → implementation runtime parity → bağımsız QA 93+
* UI feature'larında navigation/header/back davranışı da contract zincirinin parçasıdır; yalnızca stil tercihi değildir
* Shared hero/header standardı tanımlandıysa, visual chrome token/layer parity de contract zincirinin parçasıdır; yalnız layout parity yeterli değildir
* Async state kullanan feature'larda authoritative bağlam anahtarları ve runtime lifecycle ownership de contract zincirinin parçasıdır

### 3. Rework Routing

QA her zaman Tech Lead'e döner; aşağıdaki owner'ları Tech Lead task/dependency planı ile aktive eder.

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
* Bilinen blocking defect varsa Rejected; defect yok ama ürün/authority kararı eksikse Decision Pending verilir. Bütün finding'ler ayrı korunur; karar sorunu developer bugfix'e dönüştürülmez.

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
* Pending Product Revision ve Revision Affected Features etkilenen scope'ta delivery'yi resync'e kadar durdurur.
* Kontrol: Aktif feature olmasa veya hepsi Done olsa da Tech Lead resync zorunludur; eski approval etkisi incelenmeden revision flag'i temizlenmez.

### 6. `QA Scope` alanı doldurulmadan QA tetiklenirse scope belirsizliği kalır

* QA artifact mevcudiyetinden scope tahmin etmez. Eksik scope/stage/review halinde clarification ister.
* Kontrol: Tech Lead QA handoff öncesi scope, stage, modules, regression depth, evidence reuse ve task'ları açıkça atar; audit/preflight eksik gate'i reddeder.

### 7. `Runtime Validation Pending` dependency propagation gerektirir

* QA bu verdict'i ürettiğinde Tech Lead her senaryoyu evidence id, target, owner ve blocking scope ile ledger'a taşır
* Aynı entry point/provider/persistence/lifecycle substrate'ını kullanan downstream feature bu borcu miras alır
* Deploy/billing bekleyişi deploy gerektirmeyen local cold boot'u park edemez
* Kontrol: `prompt-evidence-integrity-standard.md` ve `workflow-state-audit.sh`

### 8. Security scope modül planında kaybolabilir

* Auth/veri/finansal/privileged scope'ta `backend-security` modülü Tech Lead tarafından QA planına eklenir.
* QA preflight scope ile modülün uyuşmadığı belirlenebilen durumları QA başlamadan reddeder; modül içindeki bağımsız security probe korunur.

### 9. Release gate scope'u Tech Lead tarafindan net yazilmazsa DevOps/QA ayrimi bulanabilir

* `Release Scope` bos veya muglak kalirsa DevOps/Release Engineer hangi gate'i kanitlayacagini, QA ise release-readiness compliance'i hangi seviyede kontrol edecegini net ayiramaz
* Oneri: Tech Lead release etkisi olan her feature'da `Release Scope` alanini `none / ci-cd-only / container-build / deploy-development / deploy-test / deploy-preview / staging / production-readiness / rollback-readiness` degerlerinden biriyle doldurmalidir

---

## Execution Trigger Summary (KRİTİK)

* Her rol yalnızca kullanıcının açık komutuyla (`Run [Role]`) tetiklenir
* Tech Lead için `Run Tech Lead. Incident: ...` ve `Run Tech Lead. Sorun Tespiti: ...` triage-only girişleridir
* `Run Tech Lead. Decision: <decision-id> — <karar>` yalnız önceden açılmış explicit decision gate'ini çözer
* Sorun bildirimi için canonical intake noktası Tech Lead'dir; role-targeted issue komutu kullanılmaz
* Active feature resolution, active task resolution, local/global ownership, delivery handoff ve terminal cleanup detayları `role-execution-contract.md` içinde normatif olarak tanımlıdır
* Bu doküman ambiguity çözmek için değil, hızlı cross-role görünürlük için kullanılmalıdır

### Self-Directing Flow Özeti

* Her delivery rolü teslim sonunda zorunlu `## Sonraki Komut` üretir.
* Current Owner = Next Role = şimdi çalışacak rol; teslim sonrası adım ayrı Handoff Plan'dadır.
* Planlı, prerequisite'i tamamlanmış delivery geçişi mümkündür; plan yoksa veya belirsizse Tech Lead.
* QA, Technical Analyst, Project Setup ve DevOps teslimleri Tech Lead'e döner.
* Her QA girişinden önce Tech Lead reconciliation ve Accepted review gerekir.
* QA functional → release → QA final sırası yalnız release scope varsa uygulanır.
* Detaylar: `role-execution-contract.md §5–5.3`.

---

## Recommended Working Order

1. Tech Lead feature seçer ve gerekli authority'leri doğrular.
2. Gerekirse Technical Analyst analiz, Project Setup scaffold üretir; her biri Tech Lead'e döner.
3. Tech Lead contract, task/dependency ve handoff planını çıkarır.
4. UI, content ve developer teslimleri yalnız scope/dependency planında gereken sırada ilerler.
5. Tech Lead delivery reconciliation yapar ve QA scope/stage/task'larını aktive eder.
6. Release yoksa QA final verdict; release varsa önce functional QA.
7. Her verdict Tech Lead'e döner; defect, decision veya evidence recovery uygulanır.
8. Functional Approved sonrası DevOps release evidence üretir; Tech Lead final QA'yı aktive eder.
9. QA final kabulü ve tüm closure gate'leri tamamlanınca Tech Lead Done ve global state sync yapar.
