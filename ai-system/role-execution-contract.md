# Role Execution Contract

Last Updated: 2026-04-08

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

Bu dosya product requirement, API contract, UI visual authority veya
project-specific platform kararlarını kendisi üretmez. Bu alanlarda ilgili
project/feature authority dosyaları geçerlidir.

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
* UI Designer
* Backend Developer
* Frontend/Mobile Developer
* Game Developer (Unity)
* DevOps/Release Engineer
* QA
* Project Setup

`Game Developer (Unity)` proje `platform.md` içinde client stack Unity/mobil oyun olarak tanımlıysa Frontend/Mobile Developer'ın yerini alır; ikisi aynı feature'da eşzamanlı Current Owner olamaz.

### Tech Lead Incident / Issue Intake (CRITICAL)

Kullanıcı, eksiksiz form üretmek zorunda değildir.
Basit ve geçerli giriş:

* `Run Tech Lead. Incident: <serbest metin sorun açıklaması>`
* `Run Tech Lead. Sorun Tespiti: <serbest metin sorun açıklaması>`

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

Bir rol aktif feature'ı şu sırayla çözer:

1. `ai-system/features/*/orchestration.md` dosyalarında yalnız header alanlarını oku:
   * `Current Status`
   * `Current Owner`
   * `Next Role`
2. `Current Status` terminal ise feature'ı aday listeden çıkar:
   * `Done`
   * `Blocked`
   * `Closed`
3. `Current Owner = [Role]` olan non-terminal feature'ları aday kabul et
4. Tek aday varsa aktif feature odur
5. Birden fazla aday varsa `feature-board.md` içindeki active feature ile eşleşen aday kazanır
6. Hala birden fazla aday varsa rol çalışmaz; `Needs Tech Lead Clarification` üretir
7. Hiç aday yoksa `feature-board.md` active feature'ını bağlam olarak okuyabilir ama owner ataması yoksa iş uydurmaz

Önemli kural:

* `system-state.md` ve `feature-board.md` tie-breaker / snapshot bağlamıdır
* Feature-level execution authority yine ilgili `orchestration.md` header alanlarıdır

---

## 3. Task Resolution (CRITICAL)

Rol, aktif feature içindeki işi şu sırayla seçer:

1. Varsa `Active Task Ledger` bölümünü kullanır
2. Yoksa `Open Tasks` içinden yalnız kendi role'üne atanmış unchecked item'ları alır

`Active Task Ledger` authoritative run queue'dur. Her item en az şunu içerir:

* Task ID
* Assigned Role
* Status
* Summary

Bir task actionable sayılmak için:

* `Assigned Role` current role ile exact eşleşmeli
* status `Open` veya `In Progress` olmalı
* terminal feature altında olmamalı

**Hiç task bulunamazsa:**

* `Active Task Ledger` boş VEYA mevcut değil
* `Open Tasks` içinde current role'e atanmış unchecked item yok

Bu durumda rol çalışmaz ve şu çıktıyı üretir:

> `Needs Tech Lead Clarification — No actionable task found for [Role] in active feature. Current Owner field may be set but no tasks are assigned.`

Fallback sırasında `Open Tasks` taranırken şunlar IGNORE edilir:

* code block içindeki checklist'ler
* closeout checklist'leri
* changelog / history satırları
* `Next Action` metni
* struck-through cancelled task'lar (`~~...~~`)
* `✅ COMPLETE`, `CLOSED`, `ARCHIVED`, `REFERENCE`, `EXAMPLE` diye işaretlenmiş subsection'lar
* current role dışındaki section'lardaki unchecked item'lar

Kural:

* Rol, kendi section'ı dışında unchecked task görüp işi üzerine alamaz
* Prerequisite tamamlanmadan downstream role başlatılamaz

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

Aktif rol şunları değiştiremez:

* başka feature'ın orchestration dosyası
* `feature-board.md`
* `system-state.md`
* `architecture.md` contract authority'si (Tech Lead kararı olmadan)
* başka role ait task açıklamaları

---

## 5. Delivery-to-Role Handoff

Bir rol kendi kapsamını bitirdiğinde:

1. Kendi task'larını `orchestration.md` içinde kapatır
2. `Current Owner` alanını sıradaki role geçirir
3. `Next Role` alanını aynı role ile hizalar
4. `Next Action` içine sıradaki rolün çalışacağı net brief'i bırakır
5. `Change Log` içine tarihli teslim kaydı ekler

Kural:

* Bu local handoff, feature-level execution continuity içindir
* Global source-of-truth sync'i daha sonra Tech Lead yapar

---

## 5.1 Self-Directing Flow (CRITICAL)

Her delivery rolü, teslim tamamlandığında kullanıcıya kopyalanabilir tek bir sonraki komut üretmek **zorundadır**.

### Routing Authority

* Routing authority `orchestration.md → Next Role` alanıdır
* `orchestration.md → Next Role` açıkça bir role atanmışsa → o rol geçerlidir
* `orchestration.md → Next Role` boş veya `None` ise → her rolün kendi varsayılan sonraki rolü devreye girer

### Varsayılan Sonraki Roller

| Rol | Varsayılan Sonraki |
|-----|-------------------|
| Technical Analyst | Tech Lead (sabit) |
| UI Designer | Frontend/Mobile Developer (platform.md client stack Unity/mobil oyunsa Game Developer (Unity)) |
| Backend Developer | Frontend/Mobile Developer veya Game Developer (Unity) (platform.md client stack'e bak) veya QA (Open Tasks'e bak) |
| Frontend/Mobile Developer | QA |
| Game Developer (Unity) | QA |
| DevOps/Release Engineer | QA veya Tech Lead (`orchestration.md → Next Role` ve release gate durumuna bak) |
| QA | Tech Lead (sabit) |
| Project Setup | Tech Lead veya `orchestration.md → Next Role` |

### Sabit Kurallar (override edilemez)

* **QA** her zaman `Run Tech Lead` üretir — QA verdict sonrası global state sync zorunludur
* **Technical Analyst** her zaman `Run Tech Lead` üretir — global contract kararı Tech Lead'e aittir
* Delivery rolleri arası doğrudan geçiş normaldir; Tech Lead aracı değildir
* `orchestration.md → Next Role = Tech Lead` yalnız QA verdict, release readiness, incident, rework veya belirsizlik durumlarında yazılır

### Çıktı Formatı (ZORUNLU)

```
## Sonraki Komut

Run [Role]
```

Bu bölüm her delivery artifact'ının son bölümüdür ve atlanamaz.

---

## 6. Terminal Cleanup (CRITICAL)

Bir feature terminal duruma geçtiğinde:

* `Current Owner = -`
* `Active Task Ledger = None`
* `Next Role = -` veya açıkça `Closed`
* `Next Action = Closed`
* actionable unchecked task kalmaz

Cancelled task'lar:

* `[x] ~~Task~~` formatına çevrilir
* `[ ] ~~Task~~` bırakılmaz

Completed feature içinde:

* stale owner bırakılmaz
* stale QA / FE / BE / release open task bırakılmaz
* tarihsel checklist gerekiyorsa archived/reference bölümlerine taşınır

---

## 7. Conflict Handling

Eğer şu durumlardan biri varsa rol çalışmaz:

* aynı anda birden fazla non-terminal feature `Current Owner = [Role]`
* `Current Owner` ile `Active Task Ledger` role assignment'i çelişiyor
* active feature terminal görünüyor ama actionable task var
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

Authoritative olmayan alanlar:

* `Change Log`
* `System History`
* delivery artifact içindeki workflow suggestion blokları
* prose notları
* geçmiş bug özetleri

Kural:

* Tarihçe metninden owner/task seçilmez
* Header ve ledger dışındaki serbest metin workflow authority üretmez
