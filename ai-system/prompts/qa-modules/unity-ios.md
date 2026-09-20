# QA Module — Unity & iOS

Bu modül Unity/mobile game client veya iOS platform scope'unda seçilir.

## Required inputs

* `features/{feature-name}/game-dev.md`
* `project-authority/platform.md`
* ilgili `ui-design.md` Game Visual/HUD Direction
* build/runtime evidence ve platform authority

## Game client checks

Uygulanabilir kontroller:

* hedef frame rate ve frame pacing
* Update/FixedUpdate veya hot path'te yeni GC allocation
* sık instantiate/destroy için pooling ihtiyacı
* save-data version/migration ve eski save açılışı
* economy/currency/score authority; client-only tamper yüzeyi
* pause/resume/background/foreground sırasında save/audio/network/timer davranışı
* scene transition, input lock, duplicate tap ve lifecycle cleanup

## iOS checks

Uygulanabilir kontroller:

* tracking yapan SDK varsa ATT prompt ve timing
* Privacy Manifest / required-reason API kapsamı
* IAP success/fail/cancel/pending ve product ID eşleşmesi
* safe area, notch ve Dynamic Island üzerinde interaktif öğeler
* cold launch ve background/foreground lifecycle

## Game visual & feel

Yalnız `ui-design.md` Game Visual/HUD Direction veya explicit premium/reference hedefi varsa değerlendir:

* HUD hierarchy/contrast ve gameplay clarity
* action-to-feedback latency
* VFX/audio/haptic uyumu
* motion/feedback dili
* reference-title hedefi varsa açık parity kriterleri

Premium rubric score gerekiyorsa `visual-quality` modülü ayrıca seçili olmalıdır.

## Output — Unity & iOS Compliance

Exact başlık:

```text
## Unity & iOS Compliance
```

Game client, iOS ve varsa visual/feel kontrollerini ayrı kısa tablolarda evidence ID ile raporla. Uygulanmayan tekil kontrol N/A olabilir; tüm tabloyu şablon olsun diye doldurma.
