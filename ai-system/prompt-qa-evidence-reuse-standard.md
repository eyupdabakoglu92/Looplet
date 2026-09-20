# QA Evidence Reuse & Regression Depth Standard

Bu belge bütün QA rollerinde evidence tekrar kullanımı ve regresyon derinliği için normatiftir. Amaç test sayısını keyfi azaltmak değil, aynı geçerli kanıtı tekrar üretmeden değişen riske odaklanmaktır.

## 1. Evidence Fingerprint

Tekrar kullanılabilir her evidence kaydı en az şunları taşır:

* source revision veya working-tree fingerprint
* ilgili changed-path scope/hash
* dependency lock/build-config fingerprint (uygulanıyorsa)
* exact command/action
* target, environment ve önemli runtime/toolchain sürümü
* result, exit code ve pass/fail/skip counts
* provenance: run id, timestamp ve artifact reference
* isolation, mock, fake, override veya production-path sapması

Alanlardan biri ilgili claim için belirsizse evidence yalnız supporting evidence olur; required gate'i tek başına karşılamaz.

## 2. Reuse Kuralı

Evidence yalnız şu koşulların tamamında tekrar kullanılabilir:

* claim/scenario ve expected behavior aynıdır
* ilgili source/config/data/dependency yüzeyi değişmemiştir
* canonical target/environment sınıfı aynıdır
* evidence required class'ı karşılar
* run PASS'tir; unexplained failure/skip yoktur
* provenance doğrulanabilir ve artifact erişilebilirdir

Functional QA evidence'ı final QA'da, delivery/release değişikliği ilgili fingerprint'i bozmadıysa tekrar kullanılabilir. Reuse kararı `REUSED`, source run ve gerekçeyle ledger'a yazılır.

## 3. Invalidators

Aşağıdakiler ilgili evidence'ı geçersiz kılar:

* claim'i etkileyen code, config, schema, migration, data/content veya route değişikliği
* dependency/lockfile, compiler, SDK, build flag veya environment değişikliği
* target/device/runtime class değişikliği
* failed, flaky, cancelled veya açıklanamayan skipped run
* runtime claim için yalnız source/unit evidence
* UI/motion implementation değiştiğinde eski runtime capture/video
* release artifact digest/source revision uyuşmazlığı
* mock/fake'in production path'teki değişen sınırı atlaması

Invalidation bütün suite'i otomatik geçersiz kılmaz; yalnız etkilenen claim/dependency yüzeyine yayılır.

## 4. Regression Depth

### targeted

İzole leaf change. Değişen scenario, yakın negatif sınır ve doğrudan consumer doğrulanır.

### impacted

Değişen package/feature, doğrudan dependents, shared contract ve yakın cross-feature behavior doğrulanır.

### full

Şunlardan biri varsa varsayılandır:

* final/release gate
* shared core/platform değişikliği
* startup, boot, routing veya navigation shell
* persistence, schema veya migration
* auth, security, payment, economy veya privileged data
* dependency/lockfile/build/CI config
* cross-feature store/realtime/lifecycle state
* geniş refactor veya impact sınırı güvenilir biçimde çıkarılamayan değişiklik

`full`, bütün geçerli kanıtı yeniden üretmek değildir. Full coverage gerekir; fingerprint'i geçerli evidence coverage'a sayılabilir. Değişen ve belirsiz yüzey yeniden çalıştırılır.

## 5. Bağımsız QA Tabanı

Her QA turunda QA en az bir kritik in-scope scenario'yu bağımsız çalıştırır. Aşağıdaki yüksek risklerde yalnız developer/CI özetine dayanılmaz:

* security/auth/payment/economy
* migration/persistence/startup
* multi-actor/realtime/ordered lifecycle
* release artifact/source eşleşmesi
* visual quality ve motion parity

Bağımsız probe canonical target'ta çalıştırılamıyorsa scenario pending kalır; daha düşük sınıf kanıt approval'a yükseltilmez.

## 6. Reporting

QA artifact'ı şunları açıkça ayırır:

* `EXECUTED THIS RUN`
* `REUSED — fingerprint valid`
* `INVALIDATED — rerun required`
* `PENDING — required class unavailable`

Raw log yerine artifact/run reference, command, result ve counts yazılır. Evidence reuse kararı QA kalitesini düşüren bir muafiyet değil, doğrulanabilir bir kapsam kararıdır.
