# QA Module — Stateful Flow & Integration

Bu modül persistence, hydration, realtime, async authority, timer/timeout, multi-actor, ordered/cyclic veya lifecycle bağımlı flow için seçilir.

## Required inputs

* `architecture.md` içindeki state machine, actor, ordering, ownership ve lifecycle contract'ları
* ilgili backend/client delivery artifact'ları
* varsa migration/schema/realtime protocol authority'si

## Required checks

Feature'a uygulanabilenleri test et:

* boş state ve mevcut persisted state ile cold boot
* eski schema/save migration ve incompatible/corrupt state davranışı
* hydrate tamamlanmadan action/route erişimi
* stale veya out-of-order payload'ın daha yeni state'i overwrite etmemesi
* duplicate event/action ve idempotency
* reconnect, retry, resume, background/foreground ve ownership cleanup
* allowed actor ve forbidden actor/misuse
* ordered/cyclic flow'da ilk adım değil full cycle ve terminal yeniden kullanım
* timer/timeout/cancel/back sonrası authoritative state
* cross-feature shared store/service/route bağımlıları

Multi-actor/state-machine behavior yalnız source review veya store unit testiyle onaylanamaz. Gerekli actor/target sağlanamıyorsa ilgili scenario runtime pending kalır.

Runtime lifecycle ownership için subscription/timer/listener creation ile cleanup owner'ını birlikte doğrula; duplicate listener veya stale callback riskini ayrıca test et.

## Output — Stateful Flow & Integration

Exact başlık:

```text
## Stateful Flow & Integration
```

Boundary/transition tablosu kullan:

| Boundary / Transition | Actor / Start State | Expected | Evidence IDs | Result |
| --- | --- | --- | --- | --- |

Yalnız uygulanabilir satırları üret.
