# F07 — Günlük İçerik Spesifikasyonu (Daily Content Spec)

> **Durum:** Tech Lead contract authority, 2026-09-30 (F07 `architecture.md` A5, kullanıcı incident'ı).
> Günlük havuzun **nasıl üretileceğini, neyin gerektiğini ve neye göre kabul edileceğini** tanımlar.
> Amaç: içerik kalitesi rollerde (Developer araç → Content Designer üretim → QA bağımsız kontrol) ölçülerek sağlanır. Kullanıcıya oyun testi veya kalite kararı **gelmez**. Kullanıcıya yalnız ürün PRD'sinin açıkça zorunlu tuttuğu tek karar gelir (§2.1 "Onay").
> Üst authority: ürün PRD'si (F01, F06, F07), F07 `architecture.md` D2 / D9 / A3 / A4, F06 `architecture.md` (Puzzle şeması, çözücü, zorluk puanı).

---

## 0. Neden bu belge var (teşhis)

İlk havuz (F07-CONTENT, 9af777f) bütün **zorunlu kapıları** geçti: çözülebilir, en az hamle kanıtlı, kopya yok, paket kuruluyor. Ama **kalite** ölçülmedi. Tech Lead ölçümleri (2026-09-29 / 30):

| Ölçüm | Sonuç | Anlamı |
| --- | --- | --- |
| Dolgu satırlarında gerçek kelime | 300 satırın **0**'ı | Hedef dışındaki 4 satır rastgele harf ("ÇLŞÜİ"). Buz erimesi için malzeme yok, ızgara "okunmuyor". |
| Buzlu taşı hiç eriyemeyen gün | 26 buzlu günün **18**'i | Buz, kilitli taştan farksız; buz mekaniği boşa gidiyor. |
| Taş kaldırılınca en az hamle değişmiyor | ölçülen ilk 9 taşlı günün kesin sonuç veren 5'inin **4**'ü (#1, #3, #4, #8); 4'ü çözücü bütçesinde belirsiz | Bu günlerde etiket `medium`'dan `easy`'ye düşüyor: "zorluk" yalnız taş **sayısından** geliyor (puan formülü taş başına +0,8 / +1,2). #1'de taşsız en iyi yol (`D2 R3 U2 R3`) buzlu satıra / sütunlara hiç dokunmuyor, yani taşlar tamamen süs. |
| Doğru harfi geçici bozmayı gerektiren gün (`tdDegree ≥ 1`) | 60 günün **1**'i | Hemen hiç "aha" anı yok; her gün "4–5 harfi düz yerine it". |
| Başlangıçta hedefin ≥ 3 harfi doğru yerde bir satır | 60 günün **9**'u | Başlangıç fazla yakın. |
| Farklı hedef kelime | **30** (her biri 2 kez; hepsi Journey'de de var) | Sözlükte yalnız 30 hedef var. |

**Kök nedenler:**

1. **Sözlük çok küçük:** 103 kelime / 30 hedef (geçici liste). Kelime yoksa ne farklı hedef ne eriyebilir buz ne de kelimeli dolgu mümkün.
2. **Kalite ölçülebilir kurala bağlanmamıştı.** Brief "editoryal hedefler" verdi ama ölçmeyi ve reddetmeyi zorunlu kılmadı. Kararı "insan oyun testi"ne bıraktı. Bu Tech Lead brief'inin hatasıdır.
3. **Üretici bir araç değildi.** Content Designer depo dışında geçici bir script kullandı; kurallar kodda değil, tekrarlanabilir değil. Rol sözleşmesine göre generator / validator Developer'ındır.

Bu belge üçünü de kapatır: §2 sözlük, §3–§5 ölçülebilir kurallar, §6 araç.

---

## 1. Oyun kuralları (üreticinin bilmesi gereken kısmı)

* **Izgara:** 5×5 harf. **Hedef:** 5 harfli kelime, ekranda görünür.
* **Hamle:** bir satırı sağa / sola ya da bir sütunu yukarı / aşağı **dairesel** kaydırmak. Her kaydırma 1 hamle.
* **Kazanma:** hedef kelime herhangi bir satırda, soldan sağa, bitişik ve doğru sırada oluşur. Ters, dikey, çapraz sayılmaz.
* **Kilitli taş:** yerinden hiç oynamaz. Satır / sütun kaydırılınca diğer harfler onun etrafında döner (pivot).
* **Buzlu taş:** kilitli gibi pivottur. Bulunduğu **satırda** soldan sağa 4–5 harfli bir sözlük kelimesi oluştuğu anda o satırdaki bütün buzlu taşlar **erir** ve oturumun geri kalanında normal taş olur (geri alma erimeyi de geri alır).
* **En az hamle (`optimalMoves`):** çözücünün kanıtladığı minimum. Yıldızlar buna göre hesaplanır (F04), o yüzden yanlış olamaz.
* **Günlük kuralları:** sütunlar açık, sınırsız hamle, 3 geri alma, sınırsız yeniden başlatma (AC3).

---

## 2. Girdiler — tam olarak ne lazım

### 2.1 Sözlük (en kritik girdi — F01-PRODUCTION-CORPUS)

Dosya: `packages/looplet_dictionary/assets/tr/dictionary.json` (`words`, `targets`; küçük harf, Türkçe normalize — İ/i ve I/ı ayrı).

| Liste | Şu an | Gereken (en az) | Hedef | Neden |
| --- | --- | --- | --- | --- |
| `targets` (5 harf) | 30 | **120** (Journey'nin 30'u + ≥ 90 yeni) | 400 (bir yıllık Günlük) | 60 gün × farklı hedef + reddedilen adaylar için yedek |
| `words` (4–5 harf; buz eritme ve dolgu) | 103 | **2.000** | 4.000+ | Buzun eriyebilmesi ve dolgu satırlarının gerçek kelime olabilmesi için |

**Kelime kuralları** (ürün PRD F01): gerçek, yaygın Türkçe kelime. Özel isim, küfür / argo / hakaret, kısaltma, arkaik veya çok nadir kelime **yok**. Her hedef aynı zamanda `words` içinde olmalı. Tekrar yok. Çekimli biçim yerine kök veya yaygın sözlük biçimi (ör. "kalem", "kalemi" değil).

**Kaynak ve süreç** (Content Designer):
1. Kaynak listeyi seç (TDK Güncel Türkçe Sözlük madde başları + bir sıklık listesi) ve kaynağı raporda yaz.
2. 4–5 harf filtresi, normalize, dışlama kuralları, sıklık eşiği.
3. **Otomatik kontroller** (script çıktısı raporda): uzunluk, alfabe (yalnız Türkçe harfler), tekrar yok, `targets ⊆ words`, bir küfür / argo listesine karşı tarama (listenin kaynağı yazılır).
4. Hedefler için ek kural: çok yaygın, somut, çocuk için de uygun; aynı kökten iki hedef yok.

**Etki (sözlük değişince):**
* Journey'nin buzlu seviyeleri (L21–L30) daha kolay eriyebilir, bu da en az hamleyi kısaltabilir. `content:check` her şeyi yeniden çözer, değişen seviye **fail** eder ve yeniden `export` gerekir (F05 içeriği; QA gerekir).
* F01 testleri kelime sayısına bağlıysa Developer günceller.
* Uygulama henüz dağıtılmadı ve Günlük yayınlanmadı. Sözlüğü değiştirmenin **en ucuz anı şimdi**. İlk yayından sonra her sözlük değişikliği yayınlanmış günleri etkiler (A4 ruling 3).

**Onay — kullanıcıya gelen tek konu:** ürün PRD F01, hedef listesi için *"every entry is a common, manually-approved Turkish word"* ve iki liste için *"both manually reviewed"* diyor. Tech Lead bunu değiştiremez. İki yol:
* **(a)** Kullanıcı listeleri okur ve onaylar: ~120 hedef kısa bir iş, ama ~2.000 kelimelik liste pratik değil.
* **(b)** Ürün kararı: `Run Product Owner. Revise: F01 — sözlük ve hedef listesi "manually reviewed" yerine Content Designer'ın yazılı kural setine ve otomatik kontrollerine göre onaylanır; QA bağımsız örneklem kontrolü yapar`.

Bu, karar kapısı **F07.TARGET-LIST-APPROVAL**'dır (yalnız yayını bekletir).

### 2.2 Takvim

* 60 gün, 2026-11-01 … 2026-12-30, `numberingEpoch` 2026-11-01 (geçici; canlı tarih yayın kapısında — A3 ruling 5).
* Hafta günü sınıf ritmi §4'te.

### 2.3 Araçlar

Mevcut: `looplet_authoring fill / solve / playtest / export / check / pack-daily`.

Gereken (Developer, §6): `generate-daily` ve `audit-daily`. Bunlar gelmeden Content Designer geçici script'le üretmez.

---

## 3. Bulmaca başına üretim algoritması

Girdi: tarih `d`, o günün sınıfı `c` (§4), hedef `T`, tohum (seed). Çıktı: bir def dosyası ve `export` ile yazılmış bir `Puzzle`.

```
1. ÇÖZÜLMÜŞ IZGARA KUR
   r_T  ← rastgele satır (0..4); satır r_T = T
   diğer 4 satır ← her biri:
       - 5 harfli bir sözlük kelimesi, VEYA
       - 4 harfli sözlük kelimesi + 1 harf (başa ya da sona)
     ek kurallar:
       - en az 2 satır T ile ≥ 2 ortak harf taşır (yem / şaşırtma malzemesi)
       - hiçbir satır T'nin kendisi ya da dairesel kaydırması değil
       - satırlar arasında tekrar yok; Günlük içinde yakın günlerde aynı dolgu kelimesi yok

2. TAŞLARI YERLEŞTİR (sınıfa göre)
   açık:     taş yok
   kilitli:  k ∈ {1,2} kilitli taş. Aday yerler:
               - r_T satırında, T'nin doğru harfi üstünde (çözümde yerinde kalır)
               - ya da çözüm yolundaki bir sütunu / satırı "bölen" hücre
   buzlu:    f ∈ {1,2} buzlu taş, r_T DIŞINDA tek bir satırda (r_F).
             r_F satırı, çözülmüş halde 4–5 harfli bir kelime İÇERMEZ
             (yoksa başlangıçta erir), ama §3 adım 4'teki "eriyebilir" testini geçer.
   kilitli+buzlu: ikisinin birleşimi, aynı hücre değil

3. KARIŞTIR
   k_raw ← hedef_optimum + 1..3 rastgele ters hamle (motor kuralıyla, pivotlara uyarak)
   en az 1 sütun hamlesi; en az 1 hamle r_T satırını bozar

4. ÇÖZ VE ÖLÇ (çözücü + skorlayıcı + ek ölçümler)
   o        ← Solver.solve  (kanıtlı en az hamle; bütçe aşılırsa aday reddedilir)
   sols     ← tüm optimal çözümler (üst sınır 1000)
   td       ← tdDegree (doğru harfi geçici bozma derecesi)
   fm       ← firstMoves (farklı ilk hamle sayısı)
   score, label ← DifficultyScorer
   taşEtkisi ← taşlar kaldırılmış kopyanın o' ve çözüm kümesi (bkz. Q5)
   erime    ← buzlu satır için: çözücü, erimenin mümkün olduğunu bir hamle dizisiyle KANITLAR
              (erimiş bir duruma ulaşan dizi bulunur ve playtest ile doğrulanır)

5. §5 FİLTRELERİNİN HEPSİNİ UYGULA → biri bile geçmezse aday atılır, yeni tohum dene
   (her gün için en fazla N deneme; hepsi başarısızsa o gün "blocked" raporlanır, gevşetilmez)

6. KABUL → def dosyasını yaz → resmi `export` ile Puzzle'ı yaz (optimum yeniden kanıtlanır)
```

**Notlar:**
* Adım 1'deki gerçek-kelime dolgusu hem ızgarayı "okunur" yapar hem erimeyi mümkün kılar. Rastgele harf dolgusu **yasak**.
* Hesap maliyeti: sütunlu 5×5'te `o ≥ 6` aday başına dakikalar sürer (F06 brief §11). Üretim AOT derlenmiş araçla, arka planda, gerekirse saatlerce çalışır. Bu kabul edilebilir; kuralı gevşetmek kabul edilmez.

---

## 4. Havuz düzeyi kurallar (60 gün)

| Kural | Değer | Tür |
| --- | --- | --- |
| Hedefler | 60 **farklı**; hiçbiri Journey hedefi değil (sözlük §2.1'e ulaşınca) | zorunlu |
| Tanım tekrarı | yok (Journey, smoke, havuz) — mevcut `check` | zorunlu (kapı) |
| Yakın kopya | hiçbir başlangıç ızgarası, başka bir bulmacanın başlangıcına ≤ 2 hamle mesafede değil | zorunlu (audit) |
| Haftalık sınıf ritmi | Pzt açık · Sal kilitli · Çar buzlu · Per açık · Cum kilitli · Cmt kilitli+buzlu · Paz buzlu | varsayılan (değişirse raporda gerekçe) |
| Zorluk ritmi | Pzt–Per: `o` 4–5, `medium` · Cum–Paz: `o` 5–7, en az biri `hard` ve `td ≥ 1` | zorunlu (audit) |
| Etiket | yalnız `medium` / `hard`; `easy` ve `expert` yok | zorunlu (audit) |
| "Aha" günleri | haftada en az 2 gün `td ≥ 1` | zorunlu (audit) |
| Aynı hedef harfi | art arda iki günün hedefi aynı harfle başlamaz | tercih |

---

## 5. Bulmaca başına kabul filtreleri (hepsi ölçülür, hepsi zorunlu)

| # | Filtre | Kural |
| --- | --- | --- |
| Q1 | Kimlik ve şema | D2 (2): `type daily`, `dailyDate`, `id daily-tr-<tarih>`, `lang tr`; 5×5; 5 harfli hedef; sütunlar açık |
| Q2 | Kanıtlı optimum | `export` ile yazılmış; `check`'in taze çözümü aynı; bütçe içinde |
| Q3 | Optimum aralığı | §4 zorluk ritmindeki gün aralığı |
| Q4 | Etiket | `medium` / `hard` (gün ritmine göre) |
| Q5 | **Taşlar anlamlı** | Taşların hepsi kaldırılmış kopya çözülür. Taşlı bulmacanın `o`'su taşsızınkinden **farklıysa** veya taşsız bulmacanın en az bir optimal çözümü taşlı bulmacada **uygulanamıyorsa** (taş o yolu kapatıyorsa) taşlar anlamlıdır. İkisi de değilse taşlar süstür → **red**. Taşsız kopya bütçeyi aşarsa sonuç "belirsiz" sayılır → red |
| Q6 | **Buz eriyebilir** | Her buzlu satırda erime, çözücü / playtest ile bulunmuş gerçek bir hamle dizisiyle **kanıtlı**. Kanıt dizisi raporda |
| Q7 | Buz anlamlı (buzlu günlerin ≥ yarısı) | Erimenin en az bir optimal çözümün parçası olması veya erimenin çözümü kısaltması |
| Q8 | Başlangıç çok yakın değil | Başlangıçta hiçbir satırda hedefin ≥ 3 harfi doğru yerde değil; hedefe 1 harf uzaklıkta pencere yok (mevcut `--avoid-near-target` kuralı) |
| Q9 | Bariz tek yol değil | `firstMoves ≥ 2` (başlangıçta birden fazla makul ilk hamle) |
| Q10 | Dolgu kelimeli | Çözülmüş ızgarada hedef dışındaki 4 satırın ≥ 3'ü bir sözlük kelimesi içerir |
| Q11 | Uygunsuz kelime yok | Başlangıç ve çözülmüş ızgaranın hiçbir satır / sütununda (soldan sağa, yukarıdan aşağı) küfür / argo listesinden bir kelime yok |
| Q12 | Tekrar / yakın kopya | §4 |

Filtre eşikleri `audit-daily`'nin yapılandırmasında durur; eşik değişikliği Tech Lead kararıdır ve raporda görünür.

---

## 6. Araç (Developer — Frontend/Mobile Developer)

Kurallar kodda olmalı ki kalite bir rolün özenine bağlı kalmasın.

* **`looplet_authoring generate-daily`:** §3 algoritması. Girdi: takvim, sınıf ritmi, hedef listesi, tohum, deneme sınırı. Çıktı: `tools/looplet_authoring/drafts/daily/<lang>/_defs/*.def.json` + aday raporu. Deterministik (aynı tohum = aynı çıktı).
* **`looplet_authoring audit-daily <daily/<lang>>`:** §4 + §5'in bütün ölçülebilir kuralları; gün gün tablo (her filtre PASS / FAIL + değerleri) ve havuz özeti; herhangi bir FAIL → exit 1. Her kural için adlandırılmış bir negatif test.
* `content:check` (CI) **değişmez**: `audit-daily` yavaş olabilir. CI'a eklenip eklenmeyeceği aracın süresi ölçüldükten sonra Tech Lead kararıdır.
* Sözlük dosyasına dokunmaz; sözlük içeriği Content Designer'ındır.

---

## 7. Content Designer'ın teslimi ve kabul

**Teslim:**
1. 60 pool dosyası + manifest (mevcut yollar, `export` ile) ve def'ler.
2. `audit-daily` çıktısı: **exit 0**, rapor dosyası repo'da (`features/f07-daily-challenge/content-audit.md` veya aracın ürettiği yol).
3. `content:check` exit 0; `pack-daily` exit 0.
4. `content-design.md`: kullanılan komutlar ve exit kodları, tohumlar, reddedilen aday sayıları, bilinen sınırlar.

**Kurallar:**
* Filtre geçmeyen gün **teslim edilmez**, "açık madde" olarak kullanıcıya bırakılmaz. Ya yeniden üretilir ya da gerekçeli **Tech Lead blocker**'ı olur (ör. "şu hedefle Q6 30 denemede geçmedi").
* Kalite sorusu kullanıcıya değil **Tech Lead'e** gider. Kullanıcıya yalnız §2.1'deki PRD onayı gider.
* "Yapılamaz" iddiası denenen yolları ve sayıları içerir.
* Kod / araç değişikliği yapmaz; araç eksikse blocker.

**QA (content modülü):** `audit-daily`'yi bağımsız çalıştırır; filtre kodunun negatif testlerini okur; en az 5 günü `solve` / `playtest` ile tekrar eder (Q5 / Q6 kanıt dizileri dahil). Kullanıcı oyun testi **gerekmez**.

---

## 8. Kullanıcıya kalan kararlar (yalnız ürün kararları)

1. **F07.TARGET-LIST-APPROVAL** — §2.1 (a) veya (b).
2. *(İsteğe bağlı, ürün)* Kilitli / buzlu taşlar ilk karşılaşmada açıklanmıyor (Journey'de de). Varsayılan: Günlük tüm sınıfları #1'den gösterir (A4 ruling 2). Değiştirmek istenirse `Run Product Owner. Revise: …` (ilk karşılaşma ipucu).

---

## 9. Sıra (bağımlılıklar)

```
F07-CORPUS (Content Designer: sözlük)  ─┐
F07-TOOL-DAILY (Developer: generate/audit) ─┼─→ F07-CONTENT-R1 (Content Designer: 60 gün, audit exit 0) → QA content
F07.TARGET-LIST-APPROVAL (kullanıcı / PO) ─┘      (yayın öncesi)
F07-FE (uygulama) — içerikten bağımsız, paralel
```
