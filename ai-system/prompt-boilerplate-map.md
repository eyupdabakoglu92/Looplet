# Prompt Boilerplate Map

Tarih: 2026-09-13
Statü: WORKING MAP / NON-AUTHORITATIVE

Amaç:

* Non-live prompt'lar arasında tekrar eden boilerplate bloklarını görünür kılmak
* Hangi blokların güvenle tekilleştirilebileceğini ayırmak
* Semantic refactor ile compatibility-preserving cleanup'i birbirinden ayırmak

---

## 1. Kapsam

Bu harita şu dosyaları karşılaştırır:

* `prompts/backend-dev.md`
* `prompts/frontend-dev.md`
* `prompts/qa.md`
* `prompts/ui-designer.md`
* `prompts/technical-analyst.md`
* `prompts/project-setup.md`
* `prompts/devops-release.md`
* referans amacıyla `prompts/tech-lead.md`

Not:

* Bu doküman authority üretmez; yalnız refactor haritası sağlar

---

## 1.1 Uygulanan Extraction Durumu

Tamamlanan extraction'lar:

* Shared execution gating standardı çıkarıldı
* Shared delivery footer standardı çıkarıldı
* Shared delivery artifact explainability standardı çıkarıldı
* Shared delivery artifact standardı brief-first / scope-gated output kurallarını da taşır hale getirildi
* Shared input integrity standardı çıkarıldı
* Shared input authority standardı çıkarıldı
* Shared evidence integrity standardı çıkarıldı
* QA evidence reuse/regression depth standardı çıkarıldı
* Monolitik QA prompt'u küçük core + koşullu `qa-modules/` yapısına ayrıldı; kalite gate'leri silinmeden scope'a göre yüklenir
* Read-only `qa-preflight.mjs`, QA module/depth/reuse planını execution öncesi doğrular
* Role prompt'lardaki uzun `EXECUTION AUTHORITY BINDING` blokları kısa compatibility-preserving cümleye indirildi
* `Consumed Signals` lifecycle'ı read optimization sinyali olarak eklendi
* `tools/token-cost-audit.sh` ile tekrar çalıştırılabilir maliyet ölçümü eklendi
* `tools/workflow-state-audit.sh` ile snapshot budget/exact header ve Node.js tabanlı task, owner, dependency, QA/release, revision ve closure gate kontrolü yapılır; `--local` yalnız geçici global drift'i tolere eder.
* Workflow handoff placeholder başlıkları ve next-command routing tekrarları shared footer standardıyla sadeleştirildi
* `backend-dev.md`, `frontend-dev.md`, `game-developer-unity.md`, `qa.md`, `ui-designer.md`, `technical-analyst.md`, `content-designer.md` ve `project-setup.md` prompt'larında ilgili tekrarlar azaltıldı
* `tech-lead.md` state-machine ve output boilerplate'i supplement dosyalara ayrıldı

Kalan odak:

* Hâlâ prompt içinde yaşaması gereken role-specific guard'ları gereksiz yere inceltmemek
* Summary/reference dokümanlarını yeni supplement yapısına göre senkron tutmak
* Scope-gated output'u blocker/conflict saklama mekanizmasına dönüştürmemek

---

## 2. Yüksek Tekrar Üreten Bloklar

### A. Active Feature & Task Resolution

Bulunduğu dosyalar:

* `backend-dev.md`
* `frontend-dev.md`
* `qa.md`
* `ui-designer.md`
* `technical-analyst.md`

Tekrarlayan çekirdek:

* `role-execution-contract.md` kurallarını uygula
* yalnız non-terminal current feature üzerinde çalış
* önce `Active Task Ledger`
* `Open Tasks` fallback
* `Change Log`, `System History`, code block checklist, cancelled/archive satırlarını ignore et

Hüküm:

* Bu blok büyük ölçüde `role-execution-contract.md` ve `prompt-execution-gating-standard.md` içine taşındı
* Prompt içinde kalan satırlar role-specific gating ve blocker davranışı içindir

Risk:

* Düşük

Öneri:

* Ek extraction yalnız gerçek tekrar kaldığı kanıtlanırsa yapılmalı
* Role-specific gating satırları korunmalı

---

### B. Role Gating / Current Owner Check

Bulunduğu dosyalar:

* `backend-dev.md`
* `frontend-dev.md`
* `qa.md`
* `ui-designer.md`
* `project-setup.md`

Tekrarlayan çekirdek:

* Sadece şu durumda çalış:
  * `Current Owner = [Role]`
  * actionable task mevcut
* Koşul sağlanmıyorsa işlem yapma

Hüküm:

* Yapısal olarak tekrar var
* Ama bazı roller ek ön koşul taşıyor:
  * QA: gerekli implementasyonlar tamamlanmış olmalı
  * Project Setup: hedef dizin scaffold edilmemiş olmalı
  * DevOps/Release Engineer: release/deployment task'i açık olmalı

Risk:

* Düşük-Orta

Öneri:

* Ortak gating skeleton'ı `prompt-execution-gating-standard.md` içinde tutulur
* Role-specific prerequisites prompt içinde kalmalıdır

---

### C. Local Orchestration Update

Bulunduğu dosyalar:

* `backend-dev.md`
* `frontend-dev.md`
* `qa.md`
* `ui-designer.md`
* `technical-analyst.md`
* `project-setup.md`

Tekrarlayan çekirdek:

* yalnız current feature `orchestration.md` güncellenir
* task'lar kapatılır
* `Current Owner`, `Next Role`, `Next Action` hizalanır
* `Change Log` kaydı eklenir
* `feature-board.md` ve `system-state.md` güncellenmez

Hüküm:

* Execution semantics `role-execution-contract.md` içinde yaşar
* Prompt'lardaki local update dili mümkün olduğunca kısa tutulmalıdır

Risk:

* Düşük

Öneri:

* Ortak orchestration footer ve execution gating standardı kullanılsın
* Yalnız role-specific verdict/routing satırları ayrı kalsın

---

### D. "Do Not Touch Global State" Uyarısı

Bulunduğu dosyalar:

* `backend-dev.md`
* `frontend-dev.md`
* `qa.md`
* `ui-designer.md`
* `technical-analyst.md`
* `project-setup.md`

Tekrarlayan çekirdek:

* `feature-board.md` ve `system-state.md` dosyalarına dokunma

Hüküm:

* Tek satırlık tekrar ama çok yaygın
* Bu kural execution ownership açısından kritik olduğu için tamamen kaybolmamalıdır

Risk:

* Düşük

Öneri:

* Shared footer/gating standardı içinde referanslanabilir; promptlarda kısa hatırlatma kalabilir

---

## 3. Yakın Tekrar Üreten Bloklar

### E. Input Authority & Conflict Handling

Bulunduğu dosyalar:

* `backend-dev.md`
* `frontend-dev.md`
* `qa.md`

Yakın ortak yapı:

* `architecture.md` contract authority
* `orchestration.md` execution authority
* `system-state.md` bağlam
* task scope / owner mismatch → `orchestration.md`
* stack/codebase conflict → sessiz re-platform etme
* conflicting docs → yeni contract uydurma

Role-specific ekler:

* Frontend: `ui-design.md` authority
* QA: blocker/finding ayrımı ve approval gating daha sert
* Backend: `feature-board.md` bağlamsal input olarak dahil

Hüküm:

* Exact duplicate değil
* Ama ortak bir kısa authority preamble çıkarılabilir

Risk:

* Orta

Öneri:

* İki katmanlı yapı:
  * shared authority skeleton
  * role-specific conflict rules

---

### F. Input Integrity Rule

Bulunduğu dosyalar:

* `frontend-dev.md`
* `ui-designer.md`

Yakın ortak yapı:

* `architecture.md` authority
* inherited contract açık yazılmış olmalı
* zorunlu input eksikse flow uydurma
* blocker üret

Hüküm:

* Neredeyse aynı

Risk:

* Düşük

Öneri:

* Shared "contract presence / inheritance clarity" kuralına indirgenebilir

---

### G. Delivery Explainability Rules

Bulunduğu dosyalar:

* `backend-dev.md`
* `frontend-dev.md`

Yakın ortak yapı:

* task-to-code traceability
* authority reconciliation
* unchanged/inherited behavior
* test evidence by task
* “tamamlandı” deyip geçmeme

Hüküm:

* Çok yakın kopya
* Shared explainability standardına taşındı ve brief-first / scope-gated output ile güncellendi

Risk:

* Düşük

Öneri:

* Ortak davranış `prompt-delivery-artifact-standard.md` içinde kalmalı
* Prompt içinde yalnız backend/frontend-specific örnekler ve riskler kalır

---

### H. Workflow Suggestion / Next Role Input / Ek Kurallar

Bulunduğu dosyalar:

* `backend-dev.md`
* `frontend-dev.md`
* `qa.md`
* `ui-designer.md`

Tekrarlayan çekirdek:

* next role text bloğu
* status suggestion / verdict suggestion
* `Cevabı Türkçe ver`
* global state değiştirme uyarısı

Hüküm:

* Yüksek görünür gürültü üretir
* Ama bazı role-specific farklar anlamlıdır
* Delivery artifact'larında boş footer/placeholder üretimi Phase 2 ile azaltıldı

Risk:

* Orta

Öneri:

* Ortak minimum footer korunmalı
* Role-specific verdict ve routing ekleri ayrı kalmalı
* Boş `N/A`/`Yok` bölümleri yeniden eklenmemeli

---

## 4. Düşük Tekrar Ama Yüksek Riskli Alanlar

### I. QA Runtime / Boundary / Evidence Gates

Dosya:

* `qa.md`

Hüküm:

* Uzun ama boilerplate değil
* Bu kısım yanlışlıkla “gürültü” sanılıp kesilmemeli

Risk:

* Yüksek

Öneri:

* Kısaltılacaksa yapısal konsolidasyon yapılmalı; güvenlik barı düşürülmemeli

---

### J. UI Designer Premium / Parity / Chrome Kuralları

Dosya:

* `ui-designer.md`

Hüküm:

* Uzun ama tekrar değil; rendered exploration, selection provenance ve visual evidence guard'ı

Risk:

* Orta-Yüksek

Öneri:

* Normatif ortak kısım `design/visual-quality-gate.md` içindedir; prompt role-specific output ve davranışı taşır

---

### K. Tech Lead State Machine

Dosya:

* `tech-lead.md`

Hüküm:

* En büyük gürültü kaynağıydı ve en riskli yüzeydi
* Boilerplate reduction mantığıyla değil, modülerleştirme mantığıyla ele alındı

Risk:

* Yüksekten düşürüldü, ama hâlâ hassas yüzey

Öneri:

* Ayrı supplement dosyalar üzerinden yürütülmeli; execution semantics authority `role-execution-contract.md` içinde kalmalı

---

## 5. Öncelikli Tekilleştirme Adayları

### Aday 1

* Active Feature & Task Resolution
* Local Orchestration Update
* Global state'e dokunmama kuralı

Risk:

* Düşük

### Aday 2

* Delivery Explainability Rules
* Workflow Suggestion footer

Risk:

* Düşük-Orta

### Aday 3

* Input authority skeleton
* Input integrity skeleton

Risk:

* Orta

### Son Aday

* Tech Lead modularization

Risk:

* Çok yüksek

---

## 6. Bu Haritaya Göre Sonraki Güvenli Adım

Yeni supplement yapısından sonra güvenli kalan edit türü:

* summary/reference dokümanlarında eski inline prompt bloklarını temizlemek
* shared standardlara taşınmış alanlar için stale açıklamaları güncellemek
* role-specific guard'lar arasında gerçekten atıl kalmış tekrar varsa yalnız onu sadeleştirmek
* audit raporu ile büyük dosyaları gözlemlemek; sırf büyük olduğu için guardrail silmemek

Ama koşul:

* Edit semantic değil compatibility-preserving olmalı
* live authority dosyalarına ve aktif orchestration state'ine dokunulmamalı
* `Consumed Signals` authority gibi kullanılmamalı
* brief-first output blocker veya missing evidence saklamak için kullanılmamalı

Şu anki öneri sıra:

1. audit raporu ile gerçek maliyet yüzeyini izle
2. kalan prompt'larda gerçekten atıl veya redundant kalan role-specific satırları kanıtla
3. ancak ihtiyaç varsa ikinci tur sadeleştirme yap
