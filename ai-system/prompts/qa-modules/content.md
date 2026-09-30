# QA Module — Authored Content

Bu modül authored content, content pack, manifest, generator veya validator scope'unda seçilir.

## Required inputs

* `features/{feature-name}/content-design.md`
* PRD/architecture içindeki content constraints ve acceptance criteria
* `prompt-content-quality-standard.md` ve orchestration'ın `Content Quality Contract` belgesi
* varsa manifest, generator, validator ve review evidence

## Required checks

* task/AC ile gerçek content çıktısı eşleşiyor mu
* manifest varsa file/id/count tutarlı mı
* uniqueness, ordering, locale/language, character/length ve category sınırları uygulanıyor mu
* validator iddia edilen kuralı pozitif ve negatif fixture ile gerçekten enforce ediyor mu
* required/advisory ayrımı, uygulanma koşulları ve gerçek ölçüm/review doğru mu; sezgisel skor kanıt gibi sunuluyor mu
* yeni/değişmiş toplu içerikte temsilî pilot ve kabul/red örnekleri mevcut mu
* editoryal doğruluk, hedef kitle, açıklık, çeşitlilik ve deneyim için gerçek örnekler üzerinde bağımsız inceleme; insan review yalnız authority gerektiriyorsa
* tüm hard invariant'lar bütün pakette denetleniyor mu; UNKNOWN/timeout/skip yanlışlıkla PASS olmuş mu
* risk sınıfları ve sınır durumlarından seçilen editoryal örneklem kaydedilmiş mi; kritik hata varsa etkilenen gruba tam inceleme genişletilmiş mi
* içerik/girdi/kural/araç fingerprint'i güncel mi; en az bir kritik probe/negatif örnek QA tarafından gerçekten çalıştırılmış mı
* runtime tüketici content'i güvenli biçimde parse/load ediyor mu

Her content teslimi için manifest/generator zorunlu değildir; authority ne istiyorsa onu doğrula. Required insan onayı eksikse `Decision Pending`, required doğrulama/runtime kanıtı eksikse `Runtime Validation Pending`, teknik veya kritik editoryal kusur varsa `Rejected`. Kullanıcı oyun testi veya liste onayı yeni bir kalite fallback'i değildir. Required kusur `Approved with Notes` olamaz. Gate'i QA ilerletmez; verdict/evidence Tech Lead'e gider.

## Output — Authored Content Compliance

Exact başlık:

```text
## Authored Content Compliance
```

Teknik geçerlilik ve editoryal kalite sonuçlarını ayrı, evidence ID ile raporla. Pilot kapsamı, bağımsız probe, örneklem ve fingerprint sınırlarını belirt; yeniden çalıştırılmış üretici raporunu bağımsız editoryal inceleme sayma.

Bu bölümde exact scalar `Content Result: PASS / FAIL / PENDING` yaz (tek değer). Bu içerik verdict'i genel QA Result'tan ayrıdır: örneğin ilgisiz UI kusuru genel QA'yı Rejected yaparken fingerprint'i geçerli içerik PASS kalabilir. Kod bloğundaki örnek veya başka bölümdeki PASS canlı verdict değildir. İlgili içerik/araç/girdi değişince sonuç PENDING ve gate Pending olur.
