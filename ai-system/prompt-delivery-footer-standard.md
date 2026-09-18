# Prompt Delivery Footer Standard

> SHARED SUPPLEMENT / NON-AUTHORITATIVE. Execution authority: role-execution-contract.md §5–5.3.

## Local Update

* Yalnız tamamlanan kendi task'larını Done yap; kısmi/blocked işi kapatma.
* Kendi Pending Evidence kayıtlarını result/provenance ile güncelle; başkasının kanıtını kapatma.
* Değişen delivery'de Delivery Review = Pending; Accepted kararını yalnız Tech Lead verir.
* QA kendi QA Result'unu, DevOps kendi Release Result'unu yazar; stage/policy'yi değiştirmez.
* Successor eski Next Role'den değil Handoff Plan ve zorunlu checkpoint'lerden seçilir.
* Blocker yok ve actionable iş kaldıysa aynı role devam edilir. Yoksa tek geçerli planın Queued task'ları dependency kontrolüyle Open olur; plan yoksa Tech Lead.
* Current Owner, Next Role, Next Action ve ledger birlikte güncellenir.
* Karar/kanıt/authority blocker'ı Tech Lead'e gider; tamamlanmamış task korunur.
* Global feature-board/system-state delivery rolü tarafından değiştirilmez.
* `sh ai-system/tools/workflow-state-audit.sh ai-system --local` PASS olmadan handoff verme.

## Mandatory Checkpoints

* Technical Analyst, QA, Project Setup, DevOps teslimi → Tech Lead.
* QA aktivasyonu öncesi → Tech Lead reconciliation.
* Authority, karar, required evidence, product revision veya plansız rework → Tech Lead.
* Açık planlı UI/client/developer/content geçişleri checkpoint gerekmiyorsa doğrudandır.
* Tech Lead kontrol işi için delivery task gerekmez.

## Workflow Suggestion

Completed Tasks / Remaining Tasks / Blockers / Status Suggestion blokları non-authoritative'dir; kanıt/state ile çelişemez. İlgisiz boş bölüm üretme.

## Sonraki Komut

Önce transition, sonra güncellenmiş Next Role. Eski header'ı kopyalama; otomatik QA/client fallback'i yoktur. Tamamlanmış feature için Run - üretme.

Delivery artifact'ının ve kullanıcı yanıtının son bölümü:

```text
## Sonraki Komut

Run [updated canonical role]
```
