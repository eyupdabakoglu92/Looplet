# Plain-language decision guide for F00.FOUNDATION-SELECTION (Turkish). Builds one image per decision
# from the already-rendered Direction C artefacts. Usage: python3 guide.py  (then: sh render.sh "" jobs-guide.txt)
import os
D = os.path.abspath(os.path.dirname(__file__))
JOBS = []
S = 393 / 852  # unused; phones are drawn at a fixed display width

CSS = """
@font-face{font-family:'SpaceGrotesk';src:url('fonts/SpaceGrotesk.ttf');font-weight:300 700}
*{box-sizing:border-box;margin:0;padding:0}
body{width:1240px;background:#F3F1EC;color:#1B1C22;font-family:-apple-system,'Helvetica Neue',Helvetica,Arial,sans-serif;padding:44px 52px}
.tag{display:inline-block;background:#1B1C22;color:#fff;font-weight:700;font-size:15px;letter-spacing:.08em;padding:7px 14px;border-radius:999px}
h1{font-size:40px;line-height:1.15;margin:16px 0 10px}
.ask{font-size:21px;line-height:1.45;color:#3A3C46;max-width:1100px}
.row{display:flex;gap:34px;margin-top:30px;align-items:flex-start}
.opt{flex:1;min-width:0;background:#fff;border-radius:22px;padding:22px;border:3px solid #E2DFD6}
.opt.rec{border-color:#7BB800}
.opt h2{font-size:23px;display:flex;align-items:center;gap:10px;margin-bottom:6px}
.n{display:inline-flex;width:38px;height:38px;border-radius:50%;background:#1B1C22;color:#fff;align-items:center;justify-content:center;font-size:20px}
.badge{background:#7BB800;color:#fff;font-size:13px;font-weight:800;letter-spacing:.06em;padding:5px 10px;border-radius:999px}
.opt p{font-size:18px;line-height:1.45;color:#3A3C46;margin-top:10px}
.opt b{color:#1B1C22}
.ph{position:relative;width:300px;margin:14px auto 4px}
.ph img{width:300px;display:block;border-radius:26px;box-shadow:0 10px 30px rgba(0,0,0,.25)}
.box{position:absolute;border:4px solid #FF5A3C;border-radius:12px;box-shadow:0 0 0 3px rgba(255,90,60,.25)}
.mk{position:absolute;width:34px;height:34px;border-radius:50%;background:#FF5A3C;color:#fff;font-weight:800;font-size:19px;display:flex;align-items:center;justify-content:center;border:3px solid #fff;box-shadow:0 2px 8px rgba(0,0,0,.4)}
.foot{margin-top:26px;font-size:18px;color:#3A3C46;background:#E9E6DD;border-radius:14px;padding:14px 18px;line-height:1.5}
.small{font-size:13px;color:#8A8A92;margin-top:8px}
table{border-collapse:collapse;width:100%;font-size:19px;margin-top:20px;background:#fff;border-radius:16px;overflow:hidden}
td,th{padding:12px 16px;text-align:left;border-bottom:1px solid #EEE9DF;vertical-align:top}
th{background:#1B1C22;color:#fff;font-size:15px;letter-spacing:.05em}
code{background:#1B1C22;color:#E3FB7E;padding:3px 9px;border-radius:8px;font-size:18px;font-family:Menlo,monospace}
"""

def page(name, body, h):
    html = f"<!doctype html><html><head><meta charset='utf-8'><style>{CSS}</style></head><body>{body}</body></html>"
    open(os.path.join(D, name + ".html"), "w", encoding="utf-8").write(html)
    JOBS.append(f"{name} 1240 {h} 1")

def phone(img, boxes=(), marks=(), w=300):
    k = w / 393
    inner = "".join(f"<div class='box' style='left:{x*k}px;top:{y*k}px;width:{bw*k}px;height:{bh*k}px'></div>" for x, y, bw, bh in boxes)
    inner += "".join(f"<div class='mk' style='left:{x*k-17}px;top:{y*k-17}px'>{n}</div>" for x, y, n in marks)
    return f"<div class='ph' style='width:{w}px'><img style='width:{w}px' src='../{img}.png'>{inner}</div>"

def opt(n, title, text, img, rec=False, boxes=(), marks=(), extra=""):
    b = "<span class='badge'>ÖNERİM</span>" if rec else ""
    return f"<div class='opt {'rec' if rec else ''}'><h2><span class='n'>{n}</span>{title} {b}</h2>{phone(img, boxes, marks)}<p>{text}</p>{extra}</div>"

# ---------------------------------------------------------------- 0 overview
three = "".join(f"<div style='text-align:center'>{phone(i)}<div style='font-size:17px;font-weight:700;margin-top:6px'>{t}</div></div>" for i, t in [("C-01-play-idle", "Oyun ekranı"), ("C-04-won-perfect", "Bulmacayı çözünce"), ("C-06-home-in-progress", "Ana ekran")])
page("guide-0-neyi-seciyorsun", f"""
<span class='tag'>ÖNCE BUNU OKU</span>
<h1>Ne seçiyorsun? Çok kısaca:</h1>
<p class='ask'>Reddettiğin iki tasarımın (A ve B) yerine, <b>senin gönderdiğin ekranlara benzeyen üçüncü bir tasarım</b> hazırladım. Adı "Direction C". Aşağıda üç örneği var — bu <b>senin ekranlarının stilinde</b>: koyu lacivert zemin, buzlu cam kartlar, lime yeşili vurgu.</p>
<div class='row' style='justify-content:space-around;margin-top:10px'>{three}</div>
<div class='foot'><b>Sorum:</b> Uygulamanın resmi görünümü bu tasarım olsun mu? Bir de senin ekranlarınla benim çizdiğim arasında <b>6 küçük fark</b> var; her birinde hangisini istediğini soruyorum. Her sayfada iki seçenek yan yana. <b>Bilmiyorsan / fark etmezse önerimi seçmiş sayılırım.</b><br>
<span class='small'>Not: "C-02, C-04" gibi kodlar benim dosya adlarımdı; bu rehberde artık kullanmıyorum.</span></div>
""", 1250)

# ---------------------------------------------------------------- 1 dragged row
page("guide-1-surukledigin-satir", f"""
<span class='tag'>KARAR 1 / 6</span>
<h1>Parmağınla tuttuğun satır nasıl görünsün?</h1>
<p class='ask'>Bir satırı kaydırırken o satırın "şu an tuttuğum satır" olduğu belli olmalı. Turuncu çerçeveyle işaretlediğim satıra bak.</p>
<div class='row'>
{opt(1, "Mor-mavi çerçeveli", "Tuttuğun satır <b>krem renkli kalır</b>, etrafında mor-mavi ışıklı çerçeve olur, diğer satırlar sönükleşir. <b>Neden önerim:</b> lime yeşilini <b>sadece doğru cevap ve ana butonlar için</b> saklıyorum. Böylece “tuttuğum satır” ile “doğru buldum” karışmaz; kazanma anı daha özel olur.", "C-02-play-lifted-row", True, boxes=[(34,441,325,69)])}
{opt(2, "Senin ekranındaki gibi lime yeşili", "Tuttuğun satır <b>lime yeşili</b> olur (senin gönderdiğin ekrandaki gibi). <b>Dikkat:</b> lime aynı zamanda “doğru cevap” rengi olduğu için, oyuncu satırın <i>tutulduğu için mi</i> yoksa <i>doğru olduğu için mi</i> yeşil olduğunu ayırt edemeyebilir.", "C-02b-play-lifted-row-reference-literal", False, boxes=[(34,441,325,69)])}
</div>
<div class='foot'>Cevabın: <b>1</b> veya <b>2</b>. (Önerim: 1)</div>
""", 1330)

# ---------------------------------------------------------------- 2 completion screen
page("guide-2-cozunce-cikan-ekran", """
<span class='tag'>KARAR 2 / 6</span>
<h1>Bulmacayı çözünce çıkan ekran nasıl olsun?</h1>
<p class='ask'>Şu anki oyunda çözünce cevap satırı yukarı çıkıyor ve alttan bir sonuç paneli yükseliyor; <b>tahta arkada görünmeye devam ediyor ve "Kapat" düğmesi var</b>. Senin ekranında ise sonuç <b>tam ekran</b> ve Kapat yok.</p>
<div class='row'>
""" + opt(1, "Alttan panel (şu anki oyun mantığı)", "Cevap satırı üstte, altta sonuç paneli. <b>Kapat düğmesi var.</b> <b>Neden önerim:</b> oyunun mevcut kuralları (ör. “Kapat” olması) bozulmaz; yeni yazılacak kod daha az.", "C-04-won-perfect", True) + opt(2, "Tam ekran sonuç (senin ekranın)", "Tahta kaybolur, tüm ekran sonuç olur. <b>Kapat düğmesi yoktur</b>; sadece “Sonraki bölüm” ve “Tekrar oyna”. Bu seçilirse oyunun bazı kuralları da (Kapat, çözünce tahtanın görünmesi) değişir.", "C-04b-won-full-screen-reference-composition") + """
</div>
<div class='foot'>Cevabın: <b>1</b> veya <b>2</b>. (Önerim: 1)</div>
""", 1330)

# ---------------------------------------------------------------- 3 stats
page("guide-3-sonuc-sayilari", """
<span class='tag'>KARAR 3 / 6</span>
<h1>Sonuç kutusundaki üç sayı ne göstersin?</h1>
<p class='ask'>Çözünce üç sayı gösteriyoruz. Turuncu kutuya bak. İkisinde de ilk iki sayı aynı (<b>SEN</b> = kaç hamlede çözdün, <b>OPTİMAL</b> = en iyi ihtimal kaç hamle). Fark <b>üçüncü sayıda</b>.</p>
<div class='row'>
""" + opt(1, "EN İYİ (şu anki oyun)", "Üçüncü sayı <b>senin şimdiye kadarki en iyi sonucun</b>. <b>Neden önerim:</b> oyundaki “kişisel rekor” özelliği ve “YENİ REKOR” mesajı bununla çalışıyor; kaybolmasın.", "C-04b-won-full-screen-reference-composition", True, boxes=[(24,455,343,86)]) + opt(2, "+3 YILDIZ (senin ekranın)", "Üçüncü sayı <b>bu bölümde kazandığın yıldız</b>. Bu seçilirse kişisel rekor gösterimi sonuç ekranından kalkar (oyunun “rekor” özelliği başka bir yere taşınmalı).", "C-04c-won-reference-semantics", False, boxes=[(24,455,343,86)]) + """
</div>
<div class='foot'>Cevabın: <b>1</b> veya <b>2</b>. (Önerim: 1) &nbsp;·&nbsp; <span class='small'>Not: bu iki resim tam ekran hâlinde; karar 2'de "alttan panel" seçsen de aynı üç sayı orada da olur.</span></div>
""", 1330)

# ---------------------------------------------------------------- 4 extras
page("guide-4-fazladan-seyler", f"""
<span class='tag'>KARAR 4 / 6</span>
<h1>Senin ekranlarında olan ama oyunda henüz olmayan şeyler</h1>
<p class='ask'>Senin gönderdiğin ekranlarda, <b>oyunda şu an bulunmayan 5 şey</b> var (numaralı işaretler): <b>1</b> ayarlar butonu · <b>2</b> "Seviye 5 / Yeni mekanik" kartı · <b>3</b> "4 günlük seri" · <b>4</b> "12 yıldız" · <b>5</b> oyun ekranındaki "Satırı tut · kaydır · bırak" yazısı. Bunlar yeni özellik demek (günlük seri = günlük bulmaca özelliği, ayarlar = ayarlar ekranı...).</p>
<div class='row'>
{opt(1, "Tasarımdan çıkar", "Ana ekran <b>sadece bugün var olan şeyleri</b> gösterir. Bu 5 şey tasarımda hiç yer almaz.", "C-06b-home-shipped-scope")}
{opt(2, "Tasarımda dursun, uygulamaya sonra girsin", "Bu 5 şey <b>tasarımın parçası</b> olarak kalır ama <b>şimdi uygulamaya eklenmez</b>; ilgili özellik (günlük mod, ayarlar...) yapılınca eklenir. Ben de bunları takip listesine yazarım. <b>Neden önerim:</b> vizyonunu kaybetmezsin, ama şimdi yeni iş çıkmaz.", "C-06-home-in-progress", True, marks=[(343,82,1),(334,446,2),(30,738,3),(208,738,4)], extra="<div style='text-align:center;font-size:15px;color:#6A6A72;margin-top:14px'>Oyun ekranında 5. öğe:</div>" + phone('C-01-play-idle', marks=[(78,792,5)], w=210))}
</div>
<div class='foot'>Cevabın: <b>1</b> veya <b>2</b>. (Önerim: 2) &nbsp;·&nbsp; <span class='small'>Hangisini seçersen seç, bu karar ana ekranın <i>tasarımını</i> belirler; yeni özellik yazma kararı değildir.</span></div>
""", 1900)

# ---------------------------------------------------------------- 5 wordmark
page("guide-5-logo-yazimi", """
<span class='tag'>KARAR 5 / 6</span>
<h1>Uygulamanın adı ekranlarda nasıl yazılsın?</h1>
<p class='ask'>"Küçük harf / büyük harf" derken kastettiğim şu: ana ekranın üstünde yazan <b>oyunun adı (logo yazısı)</b>. Şu an uygulamada <b>LOOPLET</b> (hepsi büyük harf) yazıyor. Senin gönderdiğin ekranda ise <b>looplet</b> (hepsi küçük harf, "let" kısmı lime yeşili).</p>
<div class='row' style='align-items:stretch'>
<div class='opt'><h2><span class='n'>·</span>Şu anki uygulama</h2><div style='background:#0B0F26;border-radius:16px;margin-top:14px;padding:26px;text-align:center'><img src='guide-assets/shipped-wordmark.png' style='width:100%'></div><p>Bugün oyunda böyle görünüyor: <b>LOOPLET</b>.</p></div>
<div class='opt rec'><h2><span class='n'>1</span>küçük harf: looplet <span class='badge'>ÖNERİM</span></h2><div style='background:#0B0F26;border-radius:16px;margin-top:14px;padding:30px;text-align:center;font-family:SpaceGrotesk;font-weight:500;font-size:62px;color:#F4F6FF;letter-spacing:-.01em'>loop<span style='color:#DDFA6B'>let</span></div><p><b>Senin ekranındaki yazım.</b> Daha samimi ve modern durur. <b>Neden önerim:</b> istediğin stil bu. Teknik bir maliyeti yok; sadece ekranlardaki yazı değişir.</p></div>
<div class='opt'><h2><span class='n'>2</span>BÜYÜK HARF: LOOPLET</h2><div style='background:#0B0F26;border-radius:16px;margin-top:14px;padding:30px;text-align:center;font-family:SpaceGrotesk;font-weight:500;font-size:46px;color:#F4F6FF;letter-spacing:.12em'>LOOP<span style='color:#DDFA6B'>LET</span></div><p>Bugünkü yazım korunur (yeni fontla). Daha ciddi ve "marka" gibi durur.</p></div>
</div>
<div class='foot'>Cevabın: <b>1</b> (küçük harf) veya <b>2</b> (büyük harf). (Önerim: 1) &nbsp;·&nbsp; <span class='small'>Bu sadece ekranlarda yazının nasıl göründüğü; mağazadaki uygulama adı ayrı bir konu.</span></div>
""", 1000)

# ---------------------------------------------------------------- 6 texts
page("guide-6-yazilar", """
<span class='tag'>KARAR 6 / 6</span>
<h1>Ekranlardaki Türkçe yazılar</h1>
<p class='ask'>Senin ekranlarındaki yazılar, şu an oyunda yazanlardan biraz farklı. Hangisi kullanılsın?</p>
<table>
<tr><th style='width:34%'>Neresi</th><th style='width:33%'>Şu anki oyun</th><th>Senin ekranların</th></tr>
<tr><td>Çözünce başlık</td><td>ÇÖZÜLDÜ + kelime</td><td><b>Döngü tamamlandı.</b> / Hedef üç hamlede yerine oturdu.</td></tr>
<tr><td>İleri butonu</td><td>SONRAKİ</td><td><b>Sonraki bölüm</b></td></tr>
<tr><td>Tekrar butonu</td><td>Yeniden</td><td><b>Tekrar oyna</b></td></tr>
<tr><td>Rekor etiketi</td><td>YENİ REKOR</td><td><b>YENİ EN İYİ</b></td></tr>
<tr><td>Ana ekran butonu</td><td>DEVAM ET</td><td><b>5. bölüme devam</b></td></tr>
<tr><td>Ana ekran başlığı</td><td>(yok)</td><td><b>Sıradaki döngüyü çöz.</b></td></tr>
<tr><td>Hedef etiketi</td><td>HEDEF</td><td><b>HEDEF DÖNGÜ</b></td></tr>
</table>
<div class='row'>
<div class='opt rec'><h2><span class='n'>1</span>Senin ekranlarındaki yazılar <span class='badge'>ÖNERİM</span></h2><p>Tasarımda senin yazdığın metinler kullanılır. <b>Neden önerim:</b> ekranları sen tasarladın, ton (samimi, "döngü" vurgusu) sana ait. Kesin Türkçe metin kontrolünü ilerde içerik sahibi (PO / yerelleştirme) yapar; ben sadece <b>büyük/küçük harf hatalarını</b> düzelttim (ör. senin ekranında "YENI EN IYI" yazıyordu, doğrusu <b>YENİ EN İYİ</b>).</p></div>
<div class='opt'><h2><span class='n'>2</span>Şu anki oyunun yazıları</h2><p>Metinler oyundaki gibi kalır; sadece görünüm değişir. Daha az değişiklik, ama senin ekranlarındaki ton kaybolur.</p></div>
</div>
<div class='foot'>Cevabın: <b>1</b> veya <b>2</b>. (Önerim: 1)</div>
""", 1240)

# ---------------------------------------------------------------- 7 how to answer
page("guide-7-nasil-cevap-verecegim", """
<span class='tag'>SON: NASIL CEVAP VERECEKSİN?</span>
<h1>Önerilerimin hepsi sana uyuyorsa tek satır yeter</h1>
<table>
<tr><th style='width:6%'>#</th><th style='width:34%'>Karar</th><th style='width:30%'>Önerim</th><th>Değiştirmek istersen</th></tr>
<tr><td>1</td><td>Tuttuğun satır</td><td>1 — mor-mavi çerçeveli</td><td>2 = lime yeşili</td></tr>
<tr><td>2</td><td>Çözünce çıkan ekran</td><td>1 — alttan panel</td><td>2 = tam ekran</td></tr>
<tr><td>3</td><td>Sonuç kutusundaki sayılar</td><td>1 — EN İYİ</td><td>2 = +3 YILDIZ</td></tr>
<tr><td>4</td><td>Oyunda henüz olmayan 5 şey</td><td>2 — tasarımda dursun, uygulamaya sonra</td><td>1 = tasarımdan çıkar</td></tr>
<tr><td>5</td><td>Logo yazısı</td><td>1 — küçük harf (looplet)</td><td>2 = BÜYÜK HARF (LOOPLET)</td></tr>
<tr><td>6</td><td>Türkçe yazılar</td><td>1 — senin ekranlarındaki</td><td>2 = şu anki oyunun yazıları</td></tr>
</table>
<div class='foot' style='font-size:21px'>
<b>Hepsi önerdiğim gibi olsun:</b><br><code>Run Tech Lead. Decision: F00.FOUNDATION-SELECTION — A</code><br><br>
<b>Bir ya da birkaçı farklı olsun</b> (sadece değiştirdiklerini yaz; yazmadıkların önerim kalır). Örnek: 1. kararda lime yeşili, 5. kararda büyük harf istiyorsan:<br><code>Run Tech Lead. Decision: F00.FOUNDATION-SELECTION — B: 1=2, 5=2</code><br><br>
<b>Bu tasarımı hiç istemiyorsan / değişiklik istiyorsan</b> (ne değişsin, yaz):<br><code>Run Tech Lead. Decision: F00.FOUNDATION-SELECTION — C: ...</code>
</div>
""", 1000)

open(os.path.join(D, "jobs-guide.txt"), "w").write("\n".join(JOBS) + "\n")
print(len(JOBS), "pages")
