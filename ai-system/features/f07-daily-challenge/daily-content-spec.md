# F07 — Günlük İçerik Kalite Contract'ı

> Revision: 2 — 2026-09-30, kullanıcının içerik kalite iyileştirmesi onayı; architecture A6.
> Ortak süreç: `../../prompt-content-quality-standard.md`. Ürün: product PRD F01/F06/F07; teknik authority: F02 motoru, F06 solver/export, F07 D2/D9.
> Bu belge kabul kurallarıdır; araçların yazıldığı veya havuzun geçtiği iddiası değildir. Mevcut 60 günlük havuz reddedilmiş içeriktir, yayına uygun değildir.

## 0. Teşhis ve kapsam

Mevcut havuz: 60 gün / 30 hedef (hepsi Journey'de). 300 **başlangıç** satırında mevcut sözlüğe uyan 4–5 harfli kelime yok; bu ölçüm çözüm sonu dolguyu ölçmez. 26 buzlu günün 18'inde sabit hücreler ve harf miktarı erimeyi imkânsız kılar. 9 başlangıçta hedefin ≥3 harfi aynı satırda yerindedir. Kayıtlı `tdDegree ≥ 1` yalnız 1 gündedir; bu kayıt tek başına tüm optimal yollar için kanıt değildir.

Tech Lead'in eski brief'i/kabulü kalite kusurlarını kullanıcı oyun testine bırakmış; Content Designer kalıcı araç yerine depo dışı üretici kullanmıştır. Rework, teknik kabul **ve** gerekçeli deneyim incelemesi gerektirir. A5 metni `../../history/f07-daily-challenge-2026-09-29/daily-content-spec-at-a5.md` altında tarihsel kayıttır.

Amaç: 16+ casual oyuncu için günlük, anlaşılır, farklı çözüm fikirleri taşıyan, mekaniklerinin gerçekten işe yaradığı bulmacalar. Hedef görünür; oyuncunun nadir kelime tahmin etmesi istenmez. Rutin içerik elemesi ve oyun testi kullanıcıya görev değildir.

## 1. Motor ve durum tanımları

* 5×5; 5 harfli hedef; satır/sütun dairesel kaydırma, her biri 1 hamle; herhangi bir satırda soldan sağa hedef kazanmadır.
* Kilitli hücre sabit pivottur; diğer hareketli harfler etrafında döner. Buz aynı davranır; satırında 4–5 harfli sözlük kelimesi oluşunca satırın tüm buzları kalıcı erir.
* `S0`: oyuncuya verilen başlangıç, `GridState.initial` ile t=0 erime/kazanma değerlendirmesinden sonra. Başlangıçta erimiş buz veya kazanılmış hedef kabul edilmez.
* `Sbuild`: üreticinin kelimeli taslağı; oynanabilirlik kanıtı değildir. `Send`: saklanan **optimal çözüm tanığı** gerçek motorda S0'dan oynatılınca ulaşılan son durum. Q10 yalnız Send üzerinde ölçülür.
* Erime tersinir değildir; kazanma terminaldir. Sbuild'den raw karıştırma yalnız aday üretir. Motorun kazanılmış duruma hamle uygulaması veya ters hamlelerin erimeyi geri alması varsayılmaz; her kabul ileri motor replay'iyle kanıtlanır.
* Optimal tanık tam `optimalMoves` uzunluğundadır; önceki adımlarda kazanma yok, her hamle uygulanmış, son adım kazanmadır. Farklı optimal yollar farklı Send üretebilir; rapor bütün yollar hakkında iddia etmez.

## 2. Sözlük ve kurasyon

Runtime asset: `packages/looplet_dictionary/assets/tr/dictionary.json`; API/şema korunur. Kaynak metadata'sı ve kurasyon raporu sidecar olabilir.

* **Required:** ≥120 uygun 5 harfli hedef; mevcut 30 Journey hedefi korunur, ≥90 yeni hedef. Bütün hedefler words içinde. Günlükte 60 farklı, Journey dışı hedef.
* **Araştırma hedefi:** ≥2.000 kullanılabilir 4–5 harfli kelime. Bu sayı erime/kalite garantisi değildir; sayı doldurmak için nadir/uygunsuz kelime kabul edilmez. Preflight kaynak kapsamını, pilot aday üretimini ölçer; Tech Lead toplu üretimden önce gerçek kabul profilini gerekçesiyle kilitler. A5'in kanıtsız 2.000 hard minimum'u değişir; 120 hedef ve 60 günlük kapsam gevşemez.
* `words` genel sözlüktür; mevcut 103 girdinin 19'u 4–5 harf dışındadır. Bunlar yalnız uzunluk nedeniyle silinmez. **Üretim görünümü** `4 ≤ length ≤ 5`, hedef görünümü `length == 5`; genel sözlükteki meşru uzunluklar yanlışlıkla reddedilmez.
* Türkçe normalizasyon: İ/i ve I/ı ayrı; alfabe/circumflex davranışı F01 authority'sine uygun. Duplicate yok, targets ⊆ words. Belirsiz yazım sessizce dönüştürülmez, karantinaya alınır.
* Gerçek ve yaygın Türkçe; özel isim, hakaret/küfür, kısaltma, arkaik/aşırı nadir veya uydurulmuş çekimli biçim dışlanır. Tek harf farkı veya soyut anlam tek başına red değildir; benzer hedeflerin takvim çeşitliliği ayrıca incelenir.
* Kaynak adı, sürüm/tarih, dosya hash'i, kullanım koşulları, kaynak etiketleri, sıklık ölçütü ve dışlama listelerinin kaynakları kaydedilir. Erişilemeyen kaynak kullanılmış gibi yazılmaz. Liste eşleşmesi bütün anlamsal uygunsuzlukları kanıtlamaz.
* Developer depoda sürümlenen corpus import/audit kontrollerini sağlar. Content Designer kurasyon verisini ve bütün hedeflerin gerekçeli editoryal incelemesini sahiplenir; kalıcı kabul script'i scratchpad'de kalmaz.

**Kabul modeli (kullanıcı onayıyla PO revizyonu):** bütün girdilere otomatik kontroller; bütün hedeflere Content Designer review; QA yeni hedeflerin tamamında bağımsız inceleme ve destek kelimelerinde kaynak/sıklık/risk örneklemi (en az 100 veya daha küçükse tamamı). Düşük sıklık, belirsiz kaynak/etiket ve diakritik sınırları kapsanır; kritik hata etkilenen grubun tamamına incelemeyi genişletir. Belirsiz girdiler kabul dışında kalır. AI review insan review diye kaydedilmez; kullanıcıdan liste okuması beklenmez.

**Etki:** sözlük değişince Journey/smoke/Daily yeniden çözülür; optimum, skor, erime ve bant değişimi raporlanır. Gereken Journey re-export aynı grid/hedef/taşlardan yapılır ve app/assets aynası canonical sync ile güncellenir. Journey bandı/deneyimi bozulursa ayrı rework açılır. Eski Daily havuzun geçici re-export'u yayın onayı değildir. Sözlük hash'i bütün yeni kanıtlara bağlanır.

## 3. Preflight, pilot ve üretim

Sıra: kaynak/fizibilite → corpus/araç readiness'i → **pilot** → Tech Lead checkpoint → 60 gün → bağımsız content QA. Pilot olmadan F07-CONTENT-R1 aktive edilmez.

Pilot: en az 8 kabul edilebilir örnek; açık, kilitli, buzlu, ikisi birden sınıflarından en az 2'şer; hafif/ağır günler ve Türkçe harf sınırları kapsanır. Her required filtre için ayrıca kabul/red fixture'ı gerekir. Başarısız pilot, 8 kabul varmış gibi kapanmaz.

Ölçümler: deneme sayısı, filtre başına red/UNKNOWN, kabul oranı, solve/audit süreleri, mümkünse peak kaynak kullanımı, kaynak/hedef yeterliliği. İlk bütçe sınıf başına 200 aday; her adayın solve/analiz bütçesi F06 default SearchBudget ile başlar (30 s / 5 milyon düğüm / derinlik 16). İlave aramalar da bütçeli; enumeration/skor sınırsız çalışamaz. Bütçe artışı veya algoritma değişikliği gerekçeli Developer/Tech Lead kararıdır; kalite eşiği otomatik düşmez.

1. Takvim sınıfı ve uygun hedef seç. Sbuild'de hedef satırı ve diğer satırlarda sözlük dolgusu kur; en az iki dolgu hedefle en az iki ortak harf içersin. Farklı dolgular; hedefin kendisi/dairesel kayması tekrar edilmez.
2. Sınıfa göre 1–2 kilit ve/veya 1–2 buz adayı yerleştir. Buz hedef satırında da olabilir; erime tanığı zorunludur. **Sbuild'deki buz satırında kelime yasak değildir**; yalnız S0'da t=0 erime yasaktır.
3. Pivot maskesini koruyan raw karıştırmayla aday başlangıç üret; başlangıcı gerçek motorla yeniden kur. Karıştırma, ters motor replay'i kanıtı değildir.
4. Ucuz red (şema, uygun hedef, başlangıç, erime gerekli koşulu, yasaklı liste, tekrar) → bütçeli optimum → optimal tanık → Q5/Q6/Q7/gerileme analizleri → Send dolgusu. Hesaplar bütün girdilerin hash'ine göre yeniden kullanılabilir.
5. Required FAIL/UNKNOWN adayı teslim dışı bırakır. Seed/attempt sırası deterministik; araç/motor/sözlük/config sabitlenir. Zaman bütçesi farklı makinelerde farklı red oluşturabilir; byte tekrarı yalnız aynı tamamlanmış arama sonuçlarıyla garanti edilir.
6. Kabul edilen def'i resmi export ile yaz; optimum/metadata'yı audit'te taze doğrula. Optimal/erime/counterfactual kanıtlar sidecar olabilir; runtime Puzzle şeması gereksiz yere değiştirilmez.

## 4. Havuz ve takvim

* 60 gün, geçici 2026-11-01 … 2026-12-30, epoch 2026-11-01; 60 farklı Journey dışı hedef; Journey/smoke/Daily tanım tekrarı yok.
* Varsayılan ritim: Pzt açık, Sal kilitli, Çar buzlu, Per açık, Cum kilitli, Cmt ikisi, Paz buzlu. Değişiklik gerekçeli Tech Lead contract kararıdır.
* İlk kabul profili: Pzt–Per optimum 4–5; Cum–Paz 5–7; medium/hard, easy/expert yok. Uygulanabilirlik pilotta ölçülür; başarısız pilot kendiliğinden daha kolay profile geçmez.
* Her **tam ISO haftasında** Cum–Paz en az bir hard ve kanıtlı geçici gerileme günü; haftada en az iki kanıtlı gerileme günü. İlk/son kısmi haftada yalnız günlük sınırlar; tek günlük haftaya iki gün şartı konmaz.
* Gerileme: satırlar arasındaki en yüksek doğru-konum sayısı M(s); her optimal çözümde en az bir adımda M azalır. Optimum o kanıtlandıktan sonra M'yi hiç azaltmayan ≤o kazanma yolu aranır: yol varsa özellik yok; eksiksiz arama sonunda yol yoksa kanıtlı; bütçe/cap biterse UNKNOWN. Bilişsel “aha” için göstergedir, oyuncu zevkinin kanıtı değildir.
* Aynı ilk hedef harfi/kök, baskın dolgu tekrarı ve benzer çözüm fikri editoryal çeşitlilik incelemesinde raporlanır. Salt seed/hedef değişikliği yeni deneyim sayılmaz.
* Yayın tarihi kayarsa sınıf/zorluk/hafta kontrolleri yeni tarihlerde tekrar çalışır; yalnız dosyaları adlandırmak yeterli değildir. Yayınlanmış gün/epoch değişmez (D2).

## 5. Q1–Q12: teknik kabul

Sonuçlar `PASS / FAIL / UNKNOWN / N/A` + ölçüm + evidence. N/A yalnız aşağıdaki koşullarda; required FAIL/UNKNOWN kabulü engeller. Negatif fixture kendi ihlalinden reddedilmelidir.

| ID | Kapsam / seviye | Kabul kuralı |
| --- | --- | --- |
| Q1 | Her gün, required | D2 kimlik/tarih/şema; 5×5; 5 harf uygun hedef; sütunlar açık; def/export eşleşir. |
| Q2 | Her gün, required | Taze solve ile kanıtlı optimum; kayıt eşit; tanık optimum uzunluğunda ve ileri motor replay'i kazanır. BudgetExceeded/eksik yol red. |
| Q3 | Gün + tam haftalar, required | §4 optimum ve kanıtlı gerileme ritmi; profil/ölçümler raporda. |
| Q4 | Gün + tam haftalar, required | Güncel skor/etiket yeniden hesaplanır ve §4'e uyar. Bileşenler görünür; taş sayısı tek başına anlamlı zorluk kanıtı değildir. |
| Q5 | Her mevcut mekanik grubu ayrı, required | Kilit kaldırılmış ve buz kaldırılmış kopyaları ayrı çöz; diğer grup korunur. Optimum farklıysa etki kanıtlı (yönü raporla); normal optimum o derinliğine kadar tam aramada çözüm yoksa alternatif optimum >o veya çözümsüzdür; kesin alternatif optimum/çözümsüzlük iddiası olmadan bu alt sınır da farkı kanıtlar; eşitse iki sistemde ortak optimal hamle dizisi olmadığını bütçeli ortak-yol aramasıyla kanıtla. Ortak optimal yol veya UNKNOWN red. Tek alternatif yolun değişmesi yetmez. Grup yoksa alt kontrol N/A; bütün taşları kaldırma yalnız ek tanıdır. |
| Q6 | Her buzlu satır, required | S0'da donuk. Kazanma öncesi erimeye ulaşan ve sonra kazanan gerçek motor yolu (ilk profil: toplam ≤o+2) kaydedilir. Sabit harf uyumu yalnız gerekli koşul, erişilebilirlik kanıtı değildir. Buz yoksa N/A. |
| Q7 | Her buzlu gün ölçülür; havuzdaki buzlu günlerin ≥yarısı required | En az bir **optimal** tanıkta kazanma öncesi eriyen hücredeki harf sonraki hamlede yer değiştirir. Yalnız son kazanma hamlesindeki erime geçmez. Ek güçlü kanıt: erime devre dışı aynı motor varyantında optimum uzar/çözüm kaybolur; budgetExceeded çözümsüzlük değildir. |
| Q8 | Her gün, required | S0 kazanılmış değil; hiçbir satırda ≥3 hedef harfi doğru konumda değil; near-target kontrolü açık; t=0 erimiş buz yok. |
| Q9 | Her gün, advisory | Farklı optimal ilk hamle sayısı veya bulunan alt sınır, enumeration tamamlanma bilgisiyle raporlanır. ≥2 tercih; tek başına açıklık/aha garantisi veya red kuralı değildir. |
| Q10 | Her gün, required | Saklanan optimal tanığın Send durumunda belirlenmiş kazanan satır dışındaki 4 satırın ≥3'ünde sözlükten 4–5 harfli pencere. Sbuild sayımı yeterli değil. Kelimeler raporda; S0 kelime pencereleri ayrı tanısal ölçüm. |
| Q11 | Her gün, required | Kaynak/sürümü belli yasaklı listeyle S0 ve saklanan bütün kanıt yollarında (Send dahil) yatay/dikey pencereler taranır. Yön/uzunluklar config'te açık; Türkçe case doğru. Sonuç yalnız taranan durumlar/listenin kapsamını kanıtlar, bütün ulaşılabilir gridlerde anlamsal garanti değildir. Şüpheli kelimeler review/karantinaya gider. |
| Q12 | Havuz + Journey/smoke, required | Def signature tekrarı yok; 60 farklı Journey dışı hedef. Yakın kopya: hedef/id/tarih hariç harfler, kilit/donuk/erimiş maskeleri ve sütun kuralı aynı başlangıçlar; veya bunlardan biri diğerinden gerçek motorla ≤2 uygulanmış hamlede erişilebilir. Terminal kural korunur; farklı harf multiset'leri ucuz elenir. |

Q7 bireysel “yararlı erime yok” gözlemidir; required sonuç havuz oranıdır. Taşsız günlerde Q5–Q7 N/A doğrudur. İlk 1.000 optimal çözüm evrensel önermeyi kanıtlamaz; varlık iddiasına bir geçerli tanık yeterlidir.

## 6. Araç contract'ı (Developer)

* Depoda corpus import/audit: kaynak metadata'sı, genel sözlük/üretim görünümü ayrımı, alfabe/uzunluk, duplicate/subset, dışlama kaydı; pozitif ve gerçek negatif örnekler.
* `generate-daily`: takvim/sınıf/targets/seed/config/bütçe → def + aday raporu + tanıklar. FAIL/UNKNOWN aday content/ altına yazılmaz. Attempt/checkpoint ile devam; kabul raporu girdi fingerprint'ini taşır.
* `audit-daily`: export ve sidecar tanıkları yeniden doğrular; Q1–Q12/§4 gün/hafta/havuz sonuçları, değerler, coverage ve fingerprint. Required FAIL/UNKNOWN/NOT RUN → nonzero. N/A koşulları ve Q9 advisory explicit. Bozuk/eksik sidecar, eski hash, yarım havuz, rapor/asset uyuşmazlığı negatif fixture'lardır.
* Bütün aramalar bütçeli; optimum, constrained ve counterfactual sonuçları ayrı. Unsolvable yalnız tam aramayla; timeout UNKNOWN. Mevcut scorer'ın bütçesiz enumeration/BFS yüzeyleri araç task'ında giderilir.
* Hızlı content:check korunur. Full audit pahalıysa ayrı koşabilir; **QA/kabul ve yayın öncesi zorunludur**. Pack/publish yolu güncel full-audit fingerprint'ini doğrular; eski rapor veya yalnız exit 0 metni yayın yetkisi değildir. Süre ölçülmeden hızlı CI gereksiz yavaşlatılmaz.
* Gerçek motor replay'i zorunlu. Counterfactual varyantları test edilir ve yalnız analizde kullanılır; oyunun davranışı değişmez.

## 7. Editoryal kabul ve QA

Content Designer pilotta ve havuzun gün tablosunda gerekçelendirir: hedef/dolgu yaygın ve okunabilir mi; mekanik kararı etkiliyor mu; erime için anlaşılabilir kelime fırsatı var mı; çözüm fikri önceki günleri tekrar ediyor mu; ağır/hafif ritmi skordan bağımsız makul mü? Kritik olumsuzluk rework'tür.

QA full audit'i bağımsız çalıştırır; negatif fixture assertion/fail yollarını okur. En az 8 gün: dört sınıf, iki ağır gün, gerileme ve en düşük Q7 marjı; pilotta tamamı. Önce çözümü okumadan gerçek motor/uygulama üzerinde inceleme, sonra tanık/counterfactual replay. Yöntem AI/otomatik/insan doğru etiketlenir. Kritik editoryal kusur aynı grubun tamamına incelemeyi genişletir. Kullanıcı oyun testi required değildir.

Teslim: 60 export + manifest + defs; kalıcı audit/kanıtlar; corpus/araç/motor/config/içerik hash'leri; komut/exit kodları; pilot kabulü; seed/bütçe/red dağılımı; editoryal gerekçeler ve Journey etki tablosu. content:check, pack-daily ve full audit birlikte geçer. Bağımsız QA tamamlanmadan Content Quality Gate Passed olmaz; F07 app/release QA ayrıca gerekir.

## 8. Yetki ve kararlar

F07.TARGET-LIST-APPROVAL: kullanıcı iyileştirmeyi onayladı; B'nin güçlendirilmiş hali product PRD ve F01 authority'sine işlenir. Bu sözlük/havuz onayı değildir. Açık içerik kanıtlarını kullanıcı decision'ı olarak yeniden açma.

İlk karşılaşma ipucu gibi yeni ürün davranışı ayrı PO kapsamıdır. F08 deploy ertelemesi ve yayın izinleri korunur.

## 9. Bağımlılıklar

F07-CONTENT-PREFLIGHT (Content Designer: kaynak/fizibilite ve rubric) → Tech Lead → F07-TOOL-DAILY (Developer: corpus araçları + generator/audit + bounded analysis) → F07-CORPUS (Content Designer: genişletme ve etki) → F07-CONTENT-PILOT (8 örnek) → Tech Lead pilot checkpoint → F07-CONTENT-R1 (60 gün) → F07-QA-FUNCTIONAL (app teslimiyle) → mevcut release rotası.

Developer araçları provisional sözlük/test fixture'larıyla geliştirebilir; üretim onayı veremez. F07-FE teknik olarak içerikten bağımsızdır; tek-owner workflow'da Tech Lead uygun checkpoint'te aktive eder. Bu sıranın yazılması downstream task'ların çalıştırıldığı veya tamamlandığı anlamına gelmez.
