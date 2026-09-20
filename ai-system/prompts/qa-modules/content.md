# QA Module — Authored Content

Bu modül authored content, content pack, manifest, generator veya validator scope'unda seçilir.

## Required inputs

* `features/{feature-name}/content-design.md`
* PRD/architecture içindeki content constraints ve acceptance criteria
* varsa manifest, generator, validator ve review evidence

## Required checks

* task/AC ile gerçek content çıktısı eşleşiyor mu
* manifest varsa file/id/count tutarlı mı
* uniqueness, ordering, locale/language, character/length ve category sınırları uygulanıyor mu
* validator iddia edilen kuralı pozitif ve negatif fixture ile gerçekten enforce ediyor mu
* editorial doğruluk/tutarlılık için gerekli insan review kaydı var mı
* runtime tüketici content'i güvenli biçimde parse/load ediyor mu

Her content teslimi için manifest/generator zorunlu değildir; authority ne istiyorsa onu doğrula. Required insan onayı eksikse `Decision Pending`, runtime tüketim kanıtı eksikse `Runtime Validation Pending`, gerçek validation defect varsa `Rejected`.

## Output — Authored Content Compliance

Exact başlık:

```text
## Authored Content Compliance
```

Constraint/validator/runtime/review sonuçlarını evidence ID ile kısa tabloda raporla.
