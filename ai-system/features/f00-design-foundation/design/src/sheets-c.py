# Direction C composites: reference-parity comparisons, contact sheet, and A|B|C overview
import subprocess, os
D=os.path.abspath(os.path.join(os.path.dirname(__file__),'..'))
CH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
CSS="body{margin:0;background:#3a3a3e;font:600 14px -apple-system,Helvetica;color:#ddd}.g{display:grid;gap:14px;padding:16px}.c{text-align:center}.c img{width:100%;display:block;border-radius:14px}.c div{margin:6px 0 2px}"
def render(name, html, w, h):
    p=os.path.join(D,'src',name+'.html'); open(p,'w').write(html)
    r=subprocess.run([CH,'--headless=new','--disable-gpu','--no-sandbox','--hide-scrollbars','--allow-file-access-from-files','--force-device-scale-factor=1',f'--window-size={w},{h}','--virtual-time-budget=4000',f'--screenshot={D}/{name}.png',f'file://{p}'],capture_output=True,timeout=60)
    print(name,w,h)
def parity(name, ref, mine, title):
    cw=716
    html=f"<html><style>{CSS}.g{{grid-template-columns:{cw}px {cw}px}}</style><body><div class=g><div class=c><img src='../reference/{ref}'><div>USER REFERENCE — {title}</div></div><div class=c><img src='../{mine}.png'><div>DIRECTION C RENDER — same frame (358×717 @2x)</div></div></div></body></html>"
    render(name, html, 2*cw+14+32, 1434+80)
parity("parity-1-home","user-ref-1-home.png","C-P1-home-ref-frame","Home")
parity("parity-2-play","user-ref-2-play.webp","C-P2-play-ref-frame","Play")
parity("parity-3-completion","user-ref-3-completion.webp","C-P3-completion-ref-frame","Completion")
S=[("C-01-play-idle","Play · idle"),("C-02-play-lifted-row","Play · row lifted (AC9)"),("C-03-play-locked-frozen","Play · locked + frozen"),("C-04-won-perfect","Won · Perfect (sheet)"),("C-05-won-two-star","Won · 2★"),("C-06-home-in-progress","Home · reference composition"),("C-07-tutorial-column","Column tutorial"),("C-08-motion-t0-hold","Motion T0 hold"),("C-09-motion-t600-glide","Motion ~T0+600 glide"),("C-10-motion-t760-panel","Motion ~T0+760 panel")]
cw=300; cells="".join(f'<div class=c><img src="../{f}.png"><div>C · {t}</div></div>' for f,t in S)
render("sheet-C", f"<html><style>{CSS}.g{{grid-template-columns:repeat(5,{cw}px)}}</style><body><div class=g>{cells}</div></body></html>", 5*cw+4*14+32, 2*(int(cw*852/393)+44)+32)
alts=[("C-02b-play-lifted-row-reference-literal","Alt · lifted row, lime (reference-literal)"),("C-04b-won-full-screen-reference-composition","Alt · full-screen completion (reference composition)"),("C-04c-won-reference-semantics","Alt · reference stat semantics (+3 YILDIZ)"),("C-06b-home-shipped-scope","Home · shipped scope only")]
cells="".join(f'<div class=c><img src="../{f}.png"><div>{t}</div></div>' for f,t in alts); cw=330
render("compare-C-alternatives", f"<html><style>{CSS}.g{{grid-template-columns:repeat(4,{cw}px)}}</style><body><div class=g>{cells}</div></body></html>", 4*cw+3*14+32, int(cw*852/393)+80)
tri=[("A-04-won-perfect","A · Won"),("B-04-won-perfect","B · Won"),("C-04-won-perfect","C · Won"),("A-01-play-idle","A · Play"),("B-01-play-idle","B · Play"),("C-01-play-idle","C · Play")]
cells="".join(f'<div class=c><img src="../{f}.png"><div>{t}</div></div>' for f,t in tri); cw=300
render("compare-ABC", f"<html><style>{CSS}.g{{grid-template-columns:repeat(3,{cw}px)}}</style><body><div class=g>{cells}</div></body></html>", 3*cw+2*14+32, 2*(int(cw*852/393)+44)+32)

dev=[("C-v-16e-play-idle","C · 16e 390×844 · Play"),("C-v-16e-won-perfect","C · 16e · Won"),("C-v-promax-play-idle","C · Pro Max 440×956 · Play"),("C-v-promax-won-perfect","C · Pro Max · Won")]
cells="".join(f'<div class=c><img src="../{f}.png" style="height:640px;width:auto"><div>{t}</div></div>' for f,t in dev)
render("compare-C-devices", f"<html><style>{CSS}.g{{display:flex;gap:14px;align-items:flex-start}}</style><body><div class=g>{cells}</div></body></html>", 1500, 720)
