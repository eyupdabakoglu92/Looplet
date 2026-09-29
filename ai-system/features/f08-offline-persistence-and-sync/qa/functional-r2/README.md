# F08-QA-FUNCTIONAL-R2 — QA kanıtı (2026-09-29)

AC2 / J8 (F08.OFFLINE-JOURNEY) için QA'nın bu turda kendisinin ürettiği kanıt. İddialar ve sonuç: `../../qa.md` → "F08-QA-FUNCTIONAL-R2". Girdi: kullanıcının ağsız koşusu `../../evidence/runtime/offline/01…06` (2026-09-29 14:07:49–14:09:45Z). Revizyon: HEAD `e55176f` (R1'den beri yalnız doküman); `app/` tree `9de12e6a…`.

| Dosya | Ne |
| --- | --- |
| `QO-01-live-store-copy.sqlite` | Koşu sonrası simülatördeki canlı store'un salt-okunur `.backup` kopyası (player, journey_progress, personal_best, kv, sync_queue). |
| `QO-02-installed-bundle-assets.txt` | Simülatöre kurulu `Runner.app` içindeki `flutter_assets/assets/journey/tr/` 31 dosya ↔ `app/assets/journey/tr` ↔ `content/journey/tr` bayt karşılaştırması; manifest strict, 1–30. |
| `qa_probe_all_levels_test.dart`, `QO-03-all-levels-probe.log` | QA probu: üretim yolu `playSessionSetupProvider` (gerçek `rootBundle`, gerçek sözlük) ile seviye 1–30 açılır, her biri için `GridEngine(toEngineConfig(...))` kurulur. Test dosyası yalnız koşu için `app/test/`'e kopyalandı, sonra silindi. |
| `QO-04-all-levels-probe-control.log` | Kontrol: `QA_BREAK_LEVEL=17` → seviye 17'nin varlığı okunamaz → prob tam o seviyede fail (probun kırık seviyeyi yakaladığı). |
| `QO-05-journey-gate-tests.log` | Mevcut F05 Journey gate / içerik testleri (gerçek bundle `rootBundle` ile, 30 seviye, band kuralları, bundle aynası): 30 / 30. |
| `QO-06-build-provenance.txt` | Kurulu build = son build (zaman + `kernel_blob.bin` aynı); `DART_DEFINES` içinde `LOOPLET_FIREBASE_EMULATOR` yok; store `firebase_uid` R1 emülatör uid'lerinden farklı; emülatör portları kapalı. |
