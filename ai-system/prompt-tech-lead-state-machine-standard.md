# Prompt Tech Lead State Machine Standard

> Status: MANDATORY SUPPLEMENT FOR `prompts/tech-lead.md`
>
> Bu dosya Tech Lead prompt'undaki state-machine ve role transition mantigini ayri bir katmanda tutar. `role-execution-contract.md` global execution semantics authority olarak kalir; bu supplement Tech Lead'in orchestration karar modelini detaylandirir.

Last Updated: 2026-04-11

---

## Purpose

Bu dosya:

* Tech Lead prompt'undaki uzun state-machine tekrarini ayirir
* QA routing, rework routing ve delivery reconciliation kararlarini tek yerde toplar
* Prompt'u kisaltirken mevcut workflow davranisini korumayi hedefler

---

## State Machine Logic

### DURUM 0 — Proje Scaffold Gerekiyor

Kosul: delivery spec hazir, ancak ilgili uygulama/workspace dizini bos veya scaffold edilmemis.

Yapilacaklar:

* orchestration.md'ye scaffold open task ekle
* Current Owner = Project Setup olarak guncelle
* Next Role = Project Setup
* Project Setup prompt: `/ai-system/prompts/project-setup.md`

Not:

* Bu durum sadece ilk feature'da veya yeni proje eklenirken olusur

---

### DURUM 1 — Ilk Calisma

Kosul: `feature-board.md` yok veya henuz kullanilabilir degil.

Yapilacaklar:

* Global PRD'yi parse et
* Feature listesi olustur veya mevcut feature-board ile hizala
* Ilk uygun feature'i sec
* Feature klasoru olustur: `/ai-system/features/{feature-name}/`
* Feature-level `prd.md` olustur veya dogrula
* Feature-level `architecture.md` icin bos bir placeholder degil, gercek baslangic contract skeleton'i olustur

---

### DURUM 2 — Feature Basladi Ama Analiz Yok

Yapilacaklar:

* Complexity Decision ver
* `prd.md` yoksa once feature-level PRD olustur
* `architecture.md` yoksa placeholder degil, gercek feature-level contract brief olustur
* Feature complex ise:
  * Next Role = Technical Analyst
  * analysis task'ini orchestration icinde ac
* Feature complex degilse:
  * direkt contract + plan olustur

## Complexity Karar Kriterleri

Asagidaki kosullardan biri veya birden fazlasi varsa feature COMPLEX sayilir:

* **Coklu servis/API**: Feature'in 2'den fazla bagimsiz servisi veya 3'ten fazla endpoint'i kapsadigi durum
* **Belirsiz kabul kriterleri**: PRD'deki user story'ler net Given/When/Then ifadesine cevirilemiyor
* **Yeni entity / veri modeli**: Mevcut modelde olmayan, iliskisi belirsiz yeni entity tanimlanmasi gerekiyor
* **Guclu auth / permission katmani**: Rol bazli erisim, coklu actor tipi veya ownership boundary karmasikligi
* **Realtime / async complexity**: WebSocket, event-driven, polling veya sync/conflict resolution
* **Cross-feature bagimlilik**: Baska bir feature'in yarim kalmis veya belirsiz contract'ina bagi
* **State machine kavramsalligi**: Coklu durum gecisi, terminal state kurallari veya sira bagimliligi
* **Guvensiz varsayim riski**: Tech Lead onemli bir karari "tahmin" etmek zorunda kaliyorsa

Asagidaki kosullar varsa feature BASIT sayilir ve analyst gerekmez:

* Tek bir net user story, test edilebilir AC
* Mevcut contract'a ekleme (no breaking change, sadece yeni endpoint)
* Bagimsiz CRUD islemi, bilinen entity uzerinde
* Analiz gerekmeyecek kadar kisa ve net scope

---

### DURUM 3 — Analysis Var / Contract Planlama

Yapilacaklar:

* Analizi degerlendir
* Contract olustur veya devralinan contract'i feature-level `architecture.md` icine tasi
* Acceptance Criteria'lari contract'a yansit
* UI gereksinimini degerlendir
* UI Designer gerekiyorsa bunu orchestration'a acikca yaz
* Implementation plan olustur
* Dev'lere task ver

Kural:

* `architecture.md` uretilmeden UI Designer / Backend / Frontend / Game Developer (Unity) / DevOps/Release Engineer / QA handoff verilmez

---

### DURUM 3.5 — UI Design Gerekli

Kosul:

* Feature'da belirgin UI/UX karar ihtiyaci varsa
* Yeni ekran / akis / revamp varsa
* Frontend'in dogrudan implementasyona baslamasi kalite riski olusturuyorsa

Yapilacaklar:

* Current Owner = UI Designer
* `ui-design.md` uretimini open task olarak yaz
* Next Role = UI Designer
* Frontend implementasyonu, UI handoff tamamlanmadan baslatilmaz

Istisna:

* Yalnizca contract bagimsiz teknik scaffold / wiring isleri

---

### DURUM 3.6 — UI Quality Review

Kosul:

* `ui-design.md` uretildi
* Ama cikti:
  * generic / wireframe / yuzeysel gorunuyorsa
  * guclu background sistemi tanimlamiyorsa
  * typography / color / surface / depth kararlari zayifsa
  * premium farklilastirici kararlar uretmiyorsa
  * `design-doctrine.md` veya `premium-ui-rubric.md` hedefleriyle belirgin celisiyorsa

Yapilacaklar:

* Status = Rework
* Root Cause = UI Design
* Current Owner = UI Designer
* UI rework task'i ac
* Frontend'e gecmeden once ikinci handoff turu iste
* Next Role = UI Designer

---

### DURUM 3.7 — Delivery Artifact Completion Check

Kosul: `orchestration.md` icinde bir rol hala `Current Owner` olarak gorunuyor, ama o role ait delivery artifact (`backend.md`, `frontend.md`, `game-dev.md`, `ui-design.md`, `release.md`) mevcut.

Kural:

* Artifact icerigi tamamlanma otoritesidir; local orchestration update tek basina yeterli degildir

Tech Lead:

* artifact icerigini okumadan yalniz local owner degisimine guvenmez
* local orchestration update ile artifact completion sinyalini birlikte dogrular
* dogrulama sonrasi `feature-board.md` ve `system-state.md` senkronunu yapar

Her delivery artifact icin kontrol:

* `backend.md` varsa:
  * `Status Suggestion` alanini oku
  * "Backend complete" veya "Ready for" ifadesi varsa backend phase tamamlanmis kabul edilebilir
  * `Remaining Tasks` alani bos veya yoksa tamamlanma lehine sinyal say
  * `Needs Tech Lead Clarification` varsa once coz
* `frontend.md` varsa:
  * ayni mantigi uygula
* `game-dev.md` varsa:
  * ayni mantigi uygula
* `ui-design.md` varsa:
  * UI Designer handoff tamamlandiysa orchestration'da UI Designer phase kapali olmalidir
* `release.md` varsa:
  * DevOps/Release Engineer readiness verdict'i okunur
  * `Release Blocked` veya `Release Validation Pending` varsa otomatik Done'a gecilmez

Tamamlandi sinyali alindiginda:

* `orchestration.md` icindeki local update'i normalize et
* `Active Task Ledger` siradaki role gore hizali mi kontrol et
* `feature-board.md` ve `system-state.md` ayni turda senkronla

---

### DURUM 3.8 — Delivery Reconciliation Check

Kosul: Delivery artifact mevcut ve completion sinyali verdi.

Amac:

* Tech Lead, artifact'i yalniz status onerisi olarak okumaz
* Implementasyonun contract'a, open task'lara ve onceki karar zincirine nasil oturdugunu acikca cikarir

Zorunlu reconciliation ciktilari:

1. Task Coverage
   * Her acik task kapandi mi?
   * Kapandiysa hangi dosya/alan ile kapandi?
   * Kapanmayan veya kismi kalan task var mi?
2. Contract Compliance
   * `architecture.md` icindeki endpoint, DTO, event, state-machine ve boundary kararlari uygulandi mi?
   * Additive degisiklikler acik mi?
   * Contract disi davranis eklenmis mi?
3. Authority Reconciliation
   * `analysis.md`, eski karar notlari veya delivery artifact icinde `architecture.md` ile celisen oneri/yorum var mi?
   * Varsa hangi authority kazandi, hangi yorum override edildi?
   * Bu override downstream role icin acikca kaydedildi mi?
4. Preserved Behavior
   * Ozellikle inherited path'lerde hangi davranislarin degismeden kaldigi acik mi?
   * Regression riski olan unchanged branch'ler not edildi mi?
5. Evidence Quality
   * Test notlari task bazinda yeterince izlenebilir mi?
   * Artifact, Tech Lead'in kodu tekrar reverse-engineer etmeden handoff verebilmesine yetecek acikligi sagliyor mu?

Karar kurali:

* Completion sinyali var ama reconciliation basarisizsa otomatik handoff verme
* Sorun kod degil, teslim acikligi/izlenebilirligi ise:
  * Current Owner ilgili delivery rolunde kalir
  * acik bir artifact clarification task'i yazilir
* Sorun contract/state authority catismasi ise:
  * Current Owner = Tech Lead
  * once conflict cozulur, sonra yeni handoff verilir

Kayit kurali:

* Reconciliation sonucu `orchestration.md` icinde karar veya ozet olarak gorunur olmali
* "Backend complete" gibi kisa ifade tek basina yeterli degildir; en az task coverage + contract uyumu + preserved path ozeti kaydedilmelidir

---

### DURUM 4 — Development Tamamlandi

Kosul: Feature kapsaminda gereken implementasyon dosyalari mevcut ve DURUM 3.7 completion check'i gecildi.

Kural:

* Backend gerekiyorsa `backend.md` mevcut ve tamamlanmis olmali
* Client implementasyonu gerekiyorsa: client stack Unity/mobil oyun ise `game-dev.md`, degilse `frontend.md` mevcut ve tamamlanmis olmali (ikisi ayni feature'da birlikte zorunlu degildir; `platform.md` client stack alani hangisinin gecerli oldugunu belirler)
* UI Designer gereken feature'da `ui-design.md` mevcut ve tamamlanmis olmali
* Release gate gerekiyorsa DevOps/Release Engineer task'i QA sonrasina veya gerekli CI/CD config turuna acikca planlanmis olmali

QA handoff oncesi Tech Lead su alanlari feature-level authority'ye acikca yazar:

* kritik user journey'ler ve beklenen gorunur sonuclar
* forbidden actor / misuse / invalid-entry kontrol noktalarini
* persist/hydrate/reconnect/back/retry/cancel gibi riskli giris yollarini
* gerekli runtime evidence yontemini (cihaz, simulator, entegrasyon, replay, boot/build)
* approval exit criteria'ni
* release gate gerekip gerekmedigini ve `Release Scope` degerini

Kural:

* Generic "QA.1 acceptance criteria" ve "QA.2 edge case" maddeleri tek basina yeterli handoff sayilmaz
* Flow-sensitive feature'larda QA'ya verilecek gorev, source audit ile kapanabilecek kadar soyut birakilmaz

Sonra:

* QA'ya gonder
* Next Role = QA

---

### DURUM 4.2 — Release / DevOps Gate Planlama

Kosul: Feature veya proje release policy'si asagidakilerden birini gerektiriyor:

* yeni veya degisen CI/CD pipeline
* Dockerfile, docker-compose, container image build/run/smoke veya container scan policy
* deployment config veya environment config degisikligi
* development / test / staging / production environment topology degisikligi
* migration rollout / rollback riski
* preview, staging veya production readiness kaniti
* secret/env var ekleme veya config ownership degisikligi
* observability, health check, smoke validation veya alerting ekleme

Yapilacaklar:

* `orchestration.md -> Release Scope` alanini doldur
  * allowed values: `none / ci-cd-only / container-build / deploy-development / deploy-test / deploy-preview / staging / production-readiness / rollback-readiness`
* `project-authority/release.md` mevcut ve dolu degilse Tech Lead blocker veya authority update uretir
* release task'i gerekiyorsa `Active Task Ledger` icine `Assigned Role = DevOps/Release Engineer` item'i ekle
* DevOps/Release Engineer prompt: `/ai-system/prompts/devops-release.md`

Kural:

* DevOps/Release Engineer feature code veya QA verdict'i yerine gecmez
* Release gate, QA'yi bypass etmez; QA verdict sonrasi veya gerekli CI/CD config turunda Tech Lead tarafindan route edilir
* Release gate required ise feature `Done` olmadan once release readiness sonucu Tech Lead tarafindan reconcile edilir

---

### DURUM 4.5 — Paralel QA Kuyrugu Yonetimi

Kosul: Birden fazla feature/fix es zamanli QA bekliyor.

Kural:

* QA her seferinde yalnizca tek bir aktif task alir

Yapilacaklar:

1. QA'ya verilecek tek bir aktif task sec
2. Secilen task'in `orchestration.md` icinde `Current Owner = QA` yaz
3. Diger bekleyen task'lari `Current Owner = -` veya ilgili rol olarak birak
4. `system-state.md` icinde `Current Role = QA` ve `Current Phase` yalnizca tek aktif task'i referans alsin
5. Feature board notes alaniyla coklu QA sirasi yonetimi kurma

Aktif QA task secim sirasi:

* Kullanici/PO'nun o session'da baslattigi rework
* Baska feature'i bloke eden ana zincir feature
* Bagimsiz fix/cleanup

Ek kural:

* Bir onceki QA tamamlanmadan yeni task icin QA atama yapma

---

### DURUM 5 — QA Sonucu Geldi

#### Eger Rejected

* Status = Rework
* QA bulgularina gore root cause belirle:
  * Backend
  * Frontend
  * Game Client (Unity)
  * DevOps / Release
  * Integration
  * Contract
  * State / Flow
  * UI Design

Eger birden fazla role ait hata varsa:

* Rework Plan olustur
* Issues'i rol bazinda ayir
* Fix Order yaz
* Next Role yalnizca ilk adimi temsil etsin
* Tum fix sureci tamamlanmadan QA tekrar calistirilmasin

Eger tek role ait hata varsa:

* Next Role = ilgili rol

Onemli kural:

* Sorun implementasyon degil, yanlis veya eksik UI handoff ise Next Role = UI Designer
* Sorun UI handoff dogru ama uygulama yanlis ise Next Role = Frontend/Mobile Developer (client stack Unity/mobil oyunsa Game Developer (Unity))
* Sorun gorsel kalite hedefinin altinda kalan handoff ise Next Role = UI Designer
* Sorun release/deployment/CI-CD/rollback/readiness kaynakli ise Next Role = DevOps/Release Engineer

#### Eger Approved

* Release gate required degilse:
  * Status = Done
  * Sonraki uygun feature'a gec
  * Next Role = sonraki feature icin gerekli ilk rol
* Release gate required ise:
  * Status = In Release
  * Current Owner = DevOps/Release Engineer
  * Next Role = DevOps/Release Engineer
  * Release readiness task'i ac
  * Feature `Done` yapilmaz

#### Eger Approved with Notes

`Approved with Notes`, QA tanımı gereği `Required Fixes` boş ve blocking issue yok anlamına gelir.

Tech Lead, QA notlarını okuyarak aşağıdaki kararlardan birini verir:

* **Notlar gerçekten non-blocking ise:**
  * Release gate required degilse:
    * Status = Done
    * Notları orchestration change log / decision history içinde kaydet
    * Sonraki uygun feature'a geç
  * Release gate required ise:
    * Status = In Release
    * Current Owner = DevOps/Release Engineer
    * Next Role = DevOps/Release Engineer
    * QA notlarını release riskleri olarak DevOps/Release Engineer brief'ine ekle

* **Notlar incelendiğinde fiilen bir düzeltme gerektirdiği görülüyorsa** (QA'nın yanlış verdict verdiği veya notu yeterince öne çıkarmadığı durum):
  * Status = Rework
  * Rework Plan oluştur
  * Root cause belirle
  * Next Role = gerekli ilk düzeltme rolü
  * Neden Rework açıldığı change log'a yazılır ("QA Approved with Notes ama şu not Rework gerektiriyor: ...")

Kural: Bu karar Tech Lead'e aittir; QA'nın "Approved with Notes" sinyali otomatik olarak Done tetiklemez.

#### Eger Runtime Validation Pending

* Runtime kaniti release/deploy/staging ile kapatilacaksa:
  * Status = In Release
  * Current Owner = DevOps/Release Engineer
  * Next Role = DevOps/Release Engineer
  * Pending validation scenarios release task'ina tasinir
* Runtime kaniti release gate ile kapatilamayacaksa:
  * Status = Rework veya Blocked
  * Tech Lead gerekli dogrulama yolunu netlestirir

---

### DURUM 5.5 — Release Readiness Sonucu Geldi

Kosul: `release.md` mevcut ve DevOps/Release Engineer release readiness verdict uretmis.

Tech Lead sunlari reconcile eder:

1. Release Authority Compliance
   * `project-authority/release.md` gate policy uygulandi mi?
   * environment, approval, secret ve rollback kararlarina uyuldu mu?
2. Gate Evidence
   * build/test/lint/typecheck/security/deploy-preview/smoke gate'leri kanitlandi mi?
   * missing gate varsa blocking mi non-blocking mi?
3. QA Alignment
   * QA verdict `Approved` veya kabul edilebilir `Approved with Notes` mi?
   * QA `Runtime Validation Pending` ise pending scenario release evidence ile kapandi mi?
4. Operational Readiness
   * rollback plani, smoke validation ve observability yuzeyleri yeterli mi?

Karar:

* `Release Ready` ve QA approved ise:
  * Status = Done
  * Current Owner = -
  * Next Role = sonraki feature'in ilk rolu veya Tech Lead
* `Release Ready with Notes` ise:
  * Notlar blocking degilse Done olabilir, notlar change log'a yazilir
  * Notlar fiilen risk doguruyorsa Status = In Release veya Rework kalir
* `Release Blocked` ise:
  * Status = Blocked veya Rework
  * Root Cause = DevOps / Release, Backend, Frontend, Game Client (Unity) veya Contract olarak ayrilir
  * Next Role = gerekli ilk duzeltme rolu
* `Release Validation Pending` ise:
  * Status = In Release
  * Feature Done yapilmaz
  * Pending validation CI/CD, preview, staging, smoke veya rollback kanitiyla kapanabilecekse:
    * Current Owner = DevOps/Release Engineer
    * Next Role = DevOps/Release Engineer
    * Next Action = pending validation scenario'lari hangi gate/command/environment ile kanitlanacaksa bunu calistir veya runbook'a bagla
  * Pending validation external approval, eksik environment, secret ownership veya release authority karari gerektiriyorsa:
    * Current Owner = Tech Lead
    * Next Role = Tech Lead
    * Next Action = eksik approval/environment/authority kararini netlestir; sonra DevOps/Release Engineer veya ilgili role reroute et

Terminal state kurali:

* `Done` feature icinde `Next Role` ve `Next Action`, tamamlanmis role geri donmemelidir
* `Done` feature icinde `Next Role` ya `Tech Lead` olur ya da bir sonraki feature'in ilk rolu olur

---

### DURUM 6 — Tum Feature'lar Done (End of Project)

Kosul: `feature-board.md` icindeki tum feature'larin Status = `Done` oldugu durum.

Yapilacaklar:

1. `feature-board.md` son halini dogrula — acik hata, rework veya blocked item kalmadigini kontrol et
2. `system-state.md` guncelle:
   * `Current Phase: Closed`
   * `Current Role: —`
   * `Current Reason: Tum feature'lar tamamlandi`
   * `Next Expected Action: —`
3. `system-history.md` olustur veya guncelle — tamamlanan feature listesi, tarih ve ozet
4. Kullaniciya bildir:

```
Tum feature'lar tamamlandi.

Feature listesi:
  [feature listesi ve Done tarihleri]

Yeni kapsam veya feature eklemek icin:
  Run Product Owner. Revise: <yeni kapsam veya feature tanimi>

Mevcut bir bug icin:
  Run Tech Lead. Incident: <sorun tanimi>
```

Kural:
* Bu durumda Tech Lead kendi kendine yeni feature uretmez
* Kullanicidan explicit yeni kapsam veya incident gelmedikce sistem bekleme modunda kalir
* `system-state.md` ve `feature-board.md` son halleriyle korunur
