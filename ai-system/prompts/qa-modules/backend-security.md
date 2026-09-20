# QA Module — Backend & Security

Bu modül yalnız `QA Modules` içinde `backend-security` seçiliyse okunur. Core QA prompt'undaki authority, evidence, fail-fast ve verdict kuralları aynen geçerlidir.

## Required inputs

* `features/{feature-name}/backend.md`
* `project-authority/setup-manifest.md`
* backend/API/data contract'ı için `architecture.md` ilgili bölümleri
* auth, kullanıcı verisi, finansal değer veya privileged role varsa ilgili security authority/config

## Hard prerequisite: canonical build/test

Backend-touching scope'ta ilk pahalı gate budur:

1. setup manifest'teki canonical build komutunu çalıştır.
2. Build PASS ise canonical test komutunu çalıştır.
3. Startup yolu etkileniyorsa canonical cold boot/health/ready kontrolünü çalıştır.

Build FAIL veya test suite içinde fail varsa `Rejected` ver ve diğer pahalı modül kontrollerini durdur. Compile PASS, boot PASS anlamına gelmez. Sonuçta geçen/fail/skip sayıları ayrı olmalıdır.

## Contract compliance

Uygulanabilir alanları doğrula:

* endpoint/method/route
* request/response schema ve field semantics
* validation ve canonical error formatı
* auth/role/ownership guard
* persistence, transaction/idempotency ve data handling
* downstream failure, timeout ve retry semantics

Contract violation blocking bug'dır.

## Security applicability

Aşağıdakilerden biri varsa security kontrolü zorunludur:

* authentication/authorization
* başka kullanıcı kaynağına erişim
* finansal işlem, kredi, limit veya ekonomi
* kullanıcı verisi okuma/yazma
* admin/privileged role

Uygulanabilir kontroller:

* IDOR: ownership check'in gerçek enforcement katmanı
* injection: parameter binding/ORM/raw query veya command yüzeyi
* response exposure: token, secret, stack trace, internal/hassas alan
* mass assignment: allowlist/DTO ve restricted field koruması
* abuse: server-side rate limit, replay/duplicate action koruması
* auth bypass: middleware/guard, expiry/invalidation ve role enforcement

Her kontrol PASS/FAIL/N/A olur. Security scope içindeki N/A gerekçeli olmalıdır. FAIL blocking finding'dir. Yalnız HTTP status görmek yeterli değildir; enforcement katmanı veya runtime negative probe kanıtlanır.

## Output — Backend & Security Compliance

Bu exact başlığı üret:

```text
## Backend & Security Compliance
```

İçerik:

* canonical build/test/boot evidence ID'leri
* contract controls tablosu
* security scope varsa uygulanabilir security controls tablosu
* fail-fast kararı

Raw build/test log'u gömme; evidence artifact'ına referans ver.
