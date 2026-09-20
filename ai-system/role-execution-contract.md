# Role Execution Contract

Last Updated: 2026-09-21

---

# GLOBAL AUTHORITY

Bu dosya execution semantics için normatif üst otoritedir.

Aşağıdaki konularda bu dosya ile herhangi bir role prompt, README,
template, supplement veya generated artifact çelişirse bu dosya kazanır:

* canonical command model
* active feature resolution
* task resolution
* local/global state ownership
* delivery handoff
* self-directing flow
* terminal cleanup
* conflict handling
* authoritative text boundaries
* evidence truth / pending-evidence propagation
* live snapshot hygiene
* visual-quality gate ownership and evidence transitions

Bu dosya product requirement, API contract, UI visual authority veya
project-specific platform kararlarını kendisi üretmez. Bu alanlarda ilgili
project/feature authority dosyaları geçerlidir.

Görsel kalite semantiği için `/ai-system/design/visual-quality-gate.md` bu contract ile birlikte normatif uygulanır; proje estetik kararları `/ai-system/project-authority/design-foundation.md` içinde kalır.

---

## Purpose

Bu doküman, `Run [Role]` komutu ile çalışan rollerin:

* aktif feature'ı nasıl bulacağını
* kendi açık işlerini nasıl seçeceğini
* hangi state dosyasını hangi kapsamda güncelleyebileceğini
* hangi metinleri authoritative kabul etmeyeceğini

generic ve tekrar kullanılabilir şekilde tanımlar.

---

## 1. Command Model

* Her çalıştırma kullanıcı komutuyla başlar: `Run [Canonical Role]`
* Rol adı exact canonical label olmalıdır
* Alias, kısaltma veya yaklaşık eşleşme command authorization sayılmaz
* Varsayılan yorum: `Run [Role]` = execution mode
* İstisna: Tech Lead için `Incident:` ve `Sorun Tespiti:` önekleri triage-only girişidir

Canonical role set:

* Product Owner
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

`Game Developer (Unity)` proje `platform.md` içinde client stack Unity/mobil oyun olarak tanımlıysa Frontend/Mobile Developer'ın yerini alır; ikisi aynı feature'da eşzamanlı Current Owner olamaz.

`Content Designer`, ayrı içerik kararları ve kabul kriterleri gerektiren metin, yerelleştirme, eğitim materyali, katalog veya referans veri paketi gibi teslimleri sahiplenir. Bu rol yalnız ilgili içerik kapsamı varsa planlanır; küçük bir metin düzeltmesi veya onaylı verinin mekanik aktarımı için ek rol zorunlu değildir. İçerik araçları ve entegrasyon kodu ilgili Developer rolünde kalır.

### Tech Lead Incident / Issue Intake (CRITICAL)

Kullanıcı, eksiksiz form üretmek zorunda değildir.
Basit ve geçerli giriş:

* `Run Tech Lead. Incident: <serbest metin sorun açıklaması>`
* `Run Tech Lead. Sorun Tespiti: <serbest metin sorun açıklaması>`
* `Run Tech Lead. Decision: <decision-id> — <kullanıcı kararı>`

Opsiyonel ek alanlar:

* `Evidence: ...`
* `Scope: ...`

`Incident:` veya `Sorun Tespiti:` önekli komut şu anlama gelir:

* execution değil, triage başlat
* Tech Lead serbest metni normalize eder
* eksik alanları mümkün olduğunca repo/state bağlamından çıkarır
* eksik kalan yerleri `Unknown`, `Needs verification` veya `Inferred from context` olarak işaretler
* sorun metni tek başına task authority üretmez

Tech Lead incident intake sonunda yalnız şu sonuçlardan birini üretir:

1. mevcut active feature altında rework aç
2. kapanmış feature'ı reopen et
3. cross-feature / system issue olarak kaydet
4. insufficient evidence / false alarm olarak işaretle

Kural:

* Incident intake completion olmadan başka role handoff verilmez
* Incident intake sırasında doğrudan implementation başlatılmaz
* Authoritative değişiklik ancak `orchestration.md`, `feature-board.md` ve `system-state.md` güncellendiğinde oluşur

`Decision:` yalnız daha önce orchestration içinde açılmış explicit user-decision gate'ini çözer. Yeni product requirement veya task uydurmaz. Karar product scope/AC değiştiriyorsa Tech Lead `product-prd.md` dosyasını düzenlemez; `Run Product Owner. Revise: ...` rotasını açar.

`Workflow Impact` alanı şu kararlardan birini açıkça içermelidir:

* Continue Current Flow
* Pause Current Flow
* Re-route Current Flow

Kural:

* `Sorun Tespiti:` metni tek başına execution authority üretmez
* Sorun aktif feature'ı etkiliyorsa rework/pause/reroute kararı Tech Lead tarafından state dosyalarına yazılmadan başka rol çalıştırılmaz
* Sorun prompt/system/workflow seviyesindeyse de tek giriş noktası Tech Lead intake'tir
* `Run QA. Sorun Tespiti: ...` gibi role-targeted issue komutları canonical intake modeli değildir; sorun bildirimi Tech Lead üzerinden açılmalıdır

---

## 2. Active Feature Resolution (CRITICAL)

Delivery rolleri için:

1. Feature header'larını oku: `Feature ID`, `Current Status`, `Current Owner`, `Next Role`.
2. `Done/Closed` tamamlanmıştır; `Blocked` beklemektedir. Üçünde de delivery execution başlatılmaz.
3. Çalıştırılan role atanmış tek executable feature varsa onu seç.
4. Aynı delivery role atanmış birden fazla executable feature varsa dur; global snapshot ile tie-break yapma. Tech Lead tek aktif atama yapar.
5. Aday yoksa iş üretme; `Needs Tech Lead Clarification` ile dön.

`feature-board.md → Active Feature` ve `system-state.md → Active Feature` aynı feature ID'yi referanslar. Local handoff sonrası global role geçici olarak eski olabilir; Tech Lead full reconciliation bunu senkronlar. Çoklu delivery ataması bu istisnaya girmez.

**Control-plane istisnası:** Tech Lead bootstrap, reconciliation, incident, decision, resync ve unblock için delivery owner/task gating'ine tabi değildir. Başka role ait işi execute etmeden ilgili feature'ı inceler. Product Owner kendi bootstrap/revision koşullarıyla çalışır.

`Decision: <id>` için Tech Lead tüm feature'ların `Open Decision Gates` alanında exact ID arar; Blocked feature'ları dışlamaz. Tek OPEN eşleşme gerekir. Yoksa, birden fazlaysa veya zaten çözülmüşse state değiştirmeden açıklama ister.

---

## 3. Task Resolution (CRITICAL)

* `Active Task Ledger` bölümü mevcutsa, boş veya `None` olsa bile tek execution kaynağıdır; `Open Tasks` fallback'i çalışmaz.
* Yalnız ledger bölümü hiç yoksa legacy fallback olarak `Open Tasks` kullanılır. Rol section başlığı exact canonical role olmalıdır; eski belirsiz başlıkları Tech Lead normalize eder.
* Yeni/yenilenen orchestration'da ledger zorunludur. Legacy fallback geçiş kolaylığıdır; full audit/handoff öncesi normalize edilir.
* Ledger satırı: `Task ID | Assigned Role | Status | Summary | Depends On`. ID feature içinde benzersizdir. `Depends On` aynı feature'daki task ID'leri veya `-` olur.
* Status: `Queued / Open / In Progress / Blocked / Done / Cancelled`. Planned downstream işler Queued kalır.
* Actionable task: current role'e atanmış, Open/In Progress, tüm dependency'leri Done olan task.
* Aynı role ait birden fazla actionable task belge sırasıyla çalışılır; tek task şartı yoktur.
* Delivery owner varken başka role ait Open/In Progress task veya tamamlanmamış dependency varsa handoff geçersizdir. Tech Lead checkpoint'inde kısmi task'lar korunabilir.
* Actionable task yoksa delivery rolü çalışmaz; `Needs Tech Lead Clarification — No actionable task` üretir.

Örnek, fence, history, reference/archive ve struck-through checklist task değildir. Next Action brief'i task oluşturmaz. Checkbox ve status tutarlı olmalıdır: yalnız Done/Cancelled satırları `[x]` olur.

Delivery öncesi feature-board'daki `Pending Product Revision` ve `Revision Affected Features` okunur. Etkilenen feature'da Tech Lead resync tamamlanmadan delivery çalışmaz; ilgisiz feature otomatik bloke edilmez.

---

## 4. Local vs Global State Ownership (CRITICAL)

### Tech Lead owns global state

Sadece Tech Lead şu dosyaları günceller:

* `ai-system/feature-board.md`
* `ai-system/system-state.md`

İstisna — Product Owner bootstrap ve revision haklarına sahiptir:

* **Bootstrap modu** (`Run Product Owner. Yeni proje: ...`): PO `feature-board.md` ve `system-state.md`'nin **ilk halini** oluşturur. Bu tek seferlik başlatma işlemidir.
* **Revision modu** (`Run Product Owner. Revise: ...`): PO yalnız `product-prd.md` ve `feature-board.md`'yi günceller; `system-state.md`'ye dokunmaz. Feature-board değişikliği ancak Tech Lead resync ile authoritative hale gelir.
* Bu iki mod dışında PO global state dosyalarına yazmaz; rutin workflow sırasında `feature-board.md` ve `system-state.md` yalnız Tech Lead'e aittir.

Sadece Tech Lead şunları authoritative olarak değiştirir:

* aktif feature seçimi
* cross-feature öncelik
* contract kararları
* global workflow sync
* `Visual Scope`, `Design Foundation` ve `Visual Quality Gate` sınıflandırması/geçişi
* `QA Modules`, `Regression Depth` ve `Evidence Reuse` planı

### Product authority

* `product/product-prd.md` Product Owner authority'sidir.
* Tech Lead, QA, Developer veya Content Designer product requirement, acceptance criteria veya success metric'i doğrudan değiştiremez.
* Kullanıcı kararı product semantics'i değiştiriyorsa Tech Lead etkiyi kaydeder ve Product Owner revision task'ı/komutu üretir; revision sonrası contract ve state resync yapar.

### Active role owns local execution update

Aktif rol yalnız current feature'ın `orchestration.md` dosyasındaki execution alanlarını güncelleyebilir:

* `Current Status`
* `Current Owner`
* `Active Task Ledger`
* kendi task'larının `Open Tasks` check state'i
* `Blockers`
* `Next Role`
* `Next Action`
* `Last Update`
* `Change Log`
* kendi scenario'larına ait `Pending Evidence` (kanıt/provenance ile)
* kendi teslimine ait `Visual Evidence` referansları; bu referanslar gate değerini kendiliğinden ilerletmez
* QA için `QA Result`; DevOps için `Release Result`

`QA Stage`, `QA Scope`, `QA Modules`, `Regression Depth`, `Evidence Reuse`, `Release Scope`, `Delivery Review`, `Handoff Plan` ve `Open Decision Gates` kararları Tech Lead'e aittir. Delivery rolü değişen teslimde Delivery Review = Pending yapabilir; Accepted yapamaz. Başka role ait kanıtı veya kullanıcı kararını kapatamaz.

Aktif rol şunları değiştiremez:

* başka feature'ın orchestration dosyası
* `feature-board.md`
* `system-state.md`
* `architecture.md` contract authority'si (Tech Lead kararı olmadan)
* başka role ait task açıklamaları

---

## 5. Delivery-to-Role Handoff

`Current Owner` ve `Next Role`, **şimdi çalışacak rolü** gösterir; aktif durumda eşittir. Next Role, current rolün işi bittikten sonraki rolü belirleyen plan değildir.

Teslim geçişi:

1. Yalnız gerçekten tamamlanan kendi task'larını Done yap; kısmi işleri kapatma.
2. Değişen delivery için `Delivery Review = Pending` yap; eksik kanıtı Pending Evidence içine kaydet.
3. Blocker yok ve aynı role ait actionable task kaldıysa owner değişmez.
4. İş bittiyse aşağıdaki checkpoint/plan kurallarıyla successor seç.
5. Önceden planlanmış successor task'larını dependency kontrolünden sonra Queued → Open yap. Yeni görev uydurma.
6. Current Owner, Next Role, Next Action ve kuyruğu birlikte güncelle.
7. Local handoff için `sh ai-system/tools/workflow-state-audit.sh ai-system --local` çalıştır. Global state yalnız Tech Lead tarafından full audit ile senkronlanır.
8. Kullanıcıya yalnız **güncellenmiş** Next Role komutunu ver.

### Handoff Plan

Doğrudan delivery geçişi ancak Tech Lead'in planladığı tek uygun satırla mümkündür:

| After Tasks | Next Role | Activate Tasks |
| --- | --- | --- |
| <completed task IDs> | <canonical role> | <queued task IDs> |

Tüm After Tasks current role'e ait ve Done olmalı; target task'ların role/dependency ataması uygun olmalıdır. Birden fazla uygun satır, eksik plan, self-route veya blocker varsa Tech Lead'e dönülür. None boş plandır; otomatik Frontend/QA varsayımı yoktur.

### Zorunlu Checkpoint'ler

* Technical Analyst ve QA teslimleri daima Tech Lead'e döner.
* Project Setup doğrulaması ve DevOps release readiness sonrası Tech Lead'e dönülür.
* QA'ya her girişten önce Tech Lead reconciliation yapar; Delivery Review = Accepted, QA Stage, scope, QA modules, regression depth, evidence reuse kararı ve QA task'larını yazar. Delivery rolü doğrudan QA aktive edemez.
* Visual Scope `none` değilse UI Designer → implementation ve implementation → QA geçişleri Tech Lead checkpoint'i gerektirir; ilgili visual gate kanıtını Tech Lead doğrular.
* Product revision, authority conflict, insan kararı, eksik required evidence ve plansız rework Tech Lead'e gider.
* UI → client veya developer → content gibi açık planlı, prerequisite'i tamamlanmış doğrudan delivery geçişleri korunur.
* Tech Lead kontrol çalışması için yapay delivery task gerekmez.

---

## 5.1 Self-Directing Flow (CRITICAL)

* Handoff öncesindeki Next Role kopyalanmaz; önce §5 geçişi yapılır.
* Açık plan yoksa varsayılan Run Tech Lead olur. Rol bazlı otomatik QA/client fallback'leri yoktur.
* Done/Closed için Run - veya tamamlanmış role komut üretilmez. Sonraki feature'ı yalnız Tech Lead aktive eder.
* Eksik prerequisite halinde task kapatılmaz; blocker ve Tech Lead handoff'u yapılır.

Her delivery artifact'ının ve kullanıcı yanıtının **son bölümü**:

```text
## Sonraki Komut

Run [updated canonical role]
```

---

## 5.2 QA / Release Stages

QA Stage: `functional / final / none`.
QA Result: `None / Functional Approved / Approved / Approved with Notes / Rejected / Runtime Validation Pending / Decision Pending`.

QA Modules: `core` + uygulanabilir koşullu modüller (`backend-security / client-ui / visual-quality / stateful-flow / unity-ios / content / release`).

Regression Depth: `targeted / impacted / full`. Evidence Reuse: `allowed / invalidated / not-applicable`.

* Release gate yoksa ilk QA final'dır.
* Release gate varsa önce functional QA yapılır. Ürün/uygulama kriterleri değerlendirilir; authority'de açıkça sonraya planlanmış release kanıtı henüz yok diye başarısız sayılmaz. Eksik functional runtime kanıtı ise pending kalır.
* Functional kapsam geçerse Functional Approved üretilir; feature Done değildir. Tech Lead release task'larını aktive eder.
* DevOps Release Ready / Release Ready with Notes verirse Tech Lead QA'yı final stage'de aktive eder. QA `/ai-system/prompt-qa-evidence-reuse-standard.md` fingerprint'i hâlâ geçerli functional kanıtı tekrar kullanır; release kanıtını ve değişen riskleri hedefli doğrular.
* Release değişikliği functional kabulü etkilediyse önce o QA kapsamı yenilenir.
* Final/release gate, shared core, startup/routing, persistence/migration, auth/security/payment/economy, dependency/lockfile/build config, cross-feature state veya geniş refactor `Regression Depth = full` gerektirir. Full coverage, geçerli fresh evidence'ı körlemesine yeniden çalıştırmak anlamına gelmez.
* Her QA turunda riskle orantılı en az bir kritik scenario QA tarafından bağımsız çalıştırılır; yüksek riskli gate yalnız delivery sahibinin özetine dayanmaz.
* Approved / Approved with Notes yalnız final stage'de, tüm required kanıt ve kararlar tamamlandığında verilir.
* Bilinen blocking defect varsa Rejected; defect yok ama current stage'i engelleyen ürün/authority/onay kararı eksikse Decision Pending; karar net ama required runtime ortam/kanıtı eksikse Runtime Validation Pending.
* Decision Pending developer bugfix talebi değildir; Tech Lead decision gate veya PO revision açar.
* Her QA verdict sonrası Tech Lead çalışır. DevOps QA verdict'ini değiştirmez, Tech Lead QA adına approval vermez.
* Pending kanıt tamamlanınca ilgili QA stage'e dönülür; DevOps kanıtı tek başına final approval olmaz.
* Release Scope != none ise final QA için Release Result = Release Ready / Release Ready with Notes gerekir.

---

## 5.3 Blocked / Decision / Revision Recovery

* Blocked terminal cleanup değildir. Ledger, kanıt ve kararlar korunur; Current Owner = Next Role = Tech Lead.
* Decision gate `Blocking Scope: feature / release` taşır; yoksa feature kabul edilir. Yalnız release yetkisi/önkoşulu bekleyen gate release olarak açıkça sınırlanabilir. Bu gate bağımsız developer işi veya functional QA'yı durdurmaz; DevOps aktivasyonu, final QA ve Done yine bekler. Belirsiz scope daraltılmaz.
* Blockers bölümü current execution'ı gerçekten durduran engellerdir. Release-only bekleyişi ayrıca feature-wide Blockers metnine kopyalayıp bağımsız işleri kilitleme; açık decision/evidence kaydı ve Blocked release task'ı korunur. Yapılabilir yerel işler varsa Tech Lead feature'ı executable tutar; tamamen bekleyen scope için Blocked kullanır.
* Prerequisite tamamlanınca Tech Lead doğrular; karar sonucunu, zamanı ve etkilenen authority'yi kaydeder. Çözümlenmiş gate RESOLVED olur.
* Ürün kriteri değişiyorsa önce PO revision ve resync yapılır; kullanıcı kararı doğrudan implementation yetkisi değildir.
* Ardından status executable duruma alınır; mevcut pending task'lar dependency kontrolünden sonra aktive edilir.
* PO her revision sonrası benzersiz revision ID ve etkilenen feature ID'lerini feature-board'a yazar. Aktif feature olmasa veya hepsi Done olsa da Tech Lead resync zorunludur.
* Tech Lead etkilenen PRD/contract/kanıtları uzlaştırır; gerekiyorsa Done feature'ı reopen eder. Pending Product Revision = None ancak etki kaydı ve güvenli routing sonrası yazılır.

---

## 6. Terminal Cleanup (CRITICAL)

Bir feature `Done` veya `Closed` durumuna geçtiğinde (`Blocked` bekleyen işlerin silinmesi anlamına gelmez):

* `Current Owner = -`
* `Active Task Ledger = None`
* `Handoff Plan = None` (tamamlanan plan history'ye taşınır)
* `Next Role = -` veya açıkça `Closed`
* `Next Action = -` veya açıkça `Closed`
* actionable unchecked task kalmaz
* PENDING/FAIL kanıt, açık blocking karar veya blocker kalmaz
* QA Stage = final, QA Result = Approved / Approved with Notes, Delivery Review = Accepted olmalıdır
* Release required ise readiness ve final QA aynı geçerli teslimi kapsar

Cancelled task'lar:

* Ledger satırı canonical alanlarını korur: `[x]`, Status = Cancelled; field adları strike-through yapılmaz.
* Legacy Open Tasks/history checklist'inde `[x] ~~Task~~` kullanılabilir; `[ ] ~~Task~~` bırakılmaz.

Completed feature içinde:

* stale owner bırakılmaz
* stale QA / FE / BE / release open task bırakılmaz
* tarihsel checklist gerekiyorsa archived/reference bölümlerine taşınır

---

## 7. Conflict Handling

Eğer şu durumlardan biri varsa rol çalışmaz:

* aynı delivery role atanmış birden fazla executable feature
* `Current Owner` ile `Active Task Ledger` role assignment'i çelişiyor
* completed feature altında actionable task veya açık blocking kanıt/karar var
* task metni current role için yeterince net değil

Bu durumda çıktı:

* delivery artifact yerine `Needs Tech Lead Clarification`
* conflict kısa ve somut biçimde yazılır

---

## 8. Authoritative Text Boundaries

Rol yalnız dedicated alanları authoritative kabul eder.

Authoritative:

* `Current Status`
* `Current Owner`
* `Active Task Ledger`
* `Open Tasks`
* `Blockers`
* `Next Role`
* `Next Action`
* `Handoff Plan`, `Pending Evidence`, `Open Decision Gates`
* `QA Scope`, `QA Modules`, `Regression Depth`, `Evidence Reuse`, `QA Stage`, `QA Result`, `Release Scope`, `Release Result`, `Delivery Review`
* `Visual Scope`, `Design Foundation`, `Visual Quality Gate`, `Visual Evidence`

Authoritative olmayan alanlar:

* `Change Log`
* `System History`
* delivery artifact içindeki workflow suggestion blokları
* prose notları
* geçmiş bug özetleri

Kural:

* Tarihçe metninden owner/task seçilmez
* Header ve ledger dışındaki serbest metin workflow authority üretmez

---

## 9. Evidence Integrity & Pending Evidence (CRITICAL)

Evidence truth kuralları için zorunlu supplement:

* `/ai-system/prompt-evidence-integrity-standard.md`

Normatif minimum:

* Yazılmış, planlanmış, CI'a bağlanmış veya gelecekte çalışacak test PASS değildir.
* Required testin gerçek sonucu pipeline status'undan ayrı doğrulanır; allowed-failure veya non-blocking job'ı içeren green pipeline tek başına PASS değildir. Testin kendisi FAIL/NOT RUN/skipped ise required gate kapanmaz.
* Build/compile sonucu boot/runtime sonucu değildir.
* Mock/provider override production startup graph'ını atlıyorsa o graph için runtime kanıtı değildir.
* Current stage'in required evidence'ı eksikse sonuç PENDING kalır; o stage'in QA approval'ı üretilemez. Final approval ve Tech Lead Done için bütün required stage kanıtları tamam olmalıdır.
* Pending evidence scenario bazında owner/target/blocking-scope taşır; bir kontrolün prerequisite'i bağımsız başka bir kontrolü bekletmek için kullanılamaz.
* Ortak runtime, veri, config veya araç akışına ait pending scenario, aynı yolu kullanan downstream feature'a taşınır.
* Boş/no-op test gerekli davranışı kanıtlamaz. Kontrol başka araca devredildiyse rule → check → negatif örnek eşlemesi yapılır.
* QA, Tech Lead'in delivery kabulünden bağımsız verdict üretir; eski approval yalnız kanıtın kapsamı hâlâ geçerliyse kullanılabilir.

## 9.1 Visual Quality Evidence (CRITICAL)

Yeni veya yeniden açılan kullanıcı-yüzü işlerinde `orchestration.md` şu alanları taşır:

* `Visual Scope`
* `Design Foundation`
* `Visual Quality Gate`
* `Visual Evidence`

Kurallar:

* Allowed değerler ve stage geçişleri `/ai-system/design/visual-quality-gate.md` içinde tanımlıdır.
* `none` dışındaki scope için text-only direction visual evidence değildir.
* `Ready for Implementation`, seçilmiş Design Foundation ve görüntülenebilir UI exploration/handoff kanıtı olmadan verilemez.
* `Ready for QA`, canonical target runtime capture ve implementation parity kaydı olmadan verilemez.
* `Passed`, bağımsız QA score 93+, her boyut en az 8 ve sıfır fail condition olmadan verilemez.
* UI Designer/developer self-score'u provisional'dır; acceptance authority üretmez.
* Static screenshot motion kanıtı değildir. Motion-critical scope video, recording, prototype veya zamanlanmış frame sequence ister.
* Canonical simulator/device/browser/game runtime çalıştırılamadıysa ilgili visual claim `Pending Evidence` olur; feature görsel PASS veya terminal olamaz.
* Legacy canlı orchestration bu alanlar yok diye otomatik reddedilmez; yeni/reopened visual işte Tech Lead şemayı normalize eder.

---

## 10. Live Snapshot Hygiene (CRITICAL)

`system-state.md`, `feature-board.md` ve orchestration header alanları current snapshot'tır; tarihçe deposu değildir.

Kurallar:

* `Current Status` tam olarak tek status token'ıdır; açıklama veya eski status zinciri taşımaz.
* `Current Owner` tam olarak tek canonical role veya `-` değeridir.
* `Next Role` tam olarak tek canonical role, `Closed` veya `-` değeridir.
* Current Status, Current Owner, Current Phase, Blockers ve Last Update içine superseded-state blokları yığılmaz.
* Global tarihçe `system-history.md`; uzun feature tarihçesi ayrı `{feature}-history.md` veya delivery artifact'larında tutulur.
* Change Log kısa index niteliğindedir; tam delivery raporlarını kopyalamaz.
* Tech Lead her global transition sonunda üç live yüzeyi aynı turda senkronlar ve `sh ai-system/tools/workflow-state-audit.sh ai-system` çalıştırır.

Default audit bütçeleri:

* `system-state.md`: 24,000 bayt
* `feature-board.md`: 24,000 bayt
* her `orchestration.md`: 40,000 bayt

Bu değerler ürün limiti değil, varsayılan dosya boyutu bütçeleridir; UTF-8 bayt olarak ölçülür. `WORKFLOW_MAX_SYSTEM_STATE_BYTES`, `WORKFLOW_MAX_FEATURE_BOARD_BYTES`, `WORKFLOW_MAX_ORCHESTRATION_BYTES` ile farklı çalışma ortamlarına uyarlanabilir. Değiştirilmiş bütçe execution notunda kaydedilir; tarihçeyi snapshot'ta biriktirme izni vermez.

Bütçe aşımı bilgi kaybıyla kısaltılmaz; tarihçe archive yüzeyine taşınır. Audit yapısal ve workflow kontrolünü birlikte çalıştırır (Node.js 18+ gerekir). --local global snapshot farkını geçici kabul eder; --structure-only diagnostic amaçlıdır ve handoff/Done gate'ini kapatmaz. Gerçek test kanıtının doğruluğunu Tech Lead/QA ayrıca doğrular.

---

## 11. Project Setup Re-entry

Project Setup normalde ilk scaffold rolüdür. Ancak Tech Lead, tamamen yeni bir workspace/service/infra surface için scoped DURUM 0 task'ı açabilir.

Re-entry koşulları:

* hedef yeni scaffold'dur; aynı açık scaffold task/target kapsamındaki kısmi çalışmanın sürdürülmesi yeni re-entry sayılmaz
* `setup-manifest.md` içinde hedefe özel recipe + canonical verification commands vardır
* existing workspace'e feature logic eklemek değildir
* Current Owner ve ledger exact Project Setup olarak atanmıştır

Project Setup her çalışmada canonical build/test/boot komutlarının uygulanabilirliğini gerçekten doğrular; çalıştırılmayan komutu PASS diye raporlamaz.


Project Setup resume: aynı açık task ve target boundary içinde oluşturulmuş dosyaları koruyarak eksik adımları/verification'ı tekrar çalıştırabilir. Hedef dolu diye körlemesine durmaz; yeniden scaffold ederek dosyaları ezmez. İlgisiz dosya veya sahiplik belirsizse clarification gerekir.
