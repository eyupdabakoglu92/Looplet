# builds contact sheets / A|B comparisons from the rendered PNGs (html -> png via headless Chrome)
import subprocess, os, sys
D=os.path.abspath(os.path.join(os.path.dirname(__file__),'..'))
CH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
def render(name, html, w, h):
    p=os.path.join(D,'src',name+'.html'); open(p,'w').write(html)
    subprocess.run([CH,'--headless=new','--disable-gpu','--no-sandbox','--hide-scrollbars','--allow-file-access-from-files','--force-device-scale-factor=1',f'--window-size={w},{h}','--virtual-time-budget=4000',f'--screenshot={D}/{name}.png',f'file://{p}'],capture_output=True)
    print(name,w,h)
CSS="body{margin:0;background:#3a3a3e;font:600 13px -apple-system,Helvetica;color:#ddd}.g{display:grid;gap:14px;padding:16px}.c{text-align:center}.c img{width:100%;display:block;border-radius:14px}.c div{margin:6px 0 2px}"
def sheet(name, items, cols, cw=300):
    rows=(len(items)+cols-1)//cols
    cells="".join(f'<div class=c><img src="../{f}.png"><div>{t}</div></div>' for f,t in items)
    h=rows*(int(cw*852/393)+44)+32
    render(name, f"<html><style>{CSS}.g{{grid-template-columns:repeat({cols},{cw}px)}}</style><body><div class=g>{cells}</div></body></html>", cols*cw+(cols-1)*14+32, h)
S=[("01-play-idle","Play · idle"),("02-play-lifted-row","Play · row lifted (AC9)"),("03-play-locked-frozen","Play · locked + frozen"),("04-won-perfect","Won · Perfect"),("05-won-two-star","Won · 2★"),("06-home-in-progress","Home · in progress"),("07-tutorial-column","Column tutorial"),("08-motion-t0-hold","Motion T0 hold"),("09-motion-t600-glide","Motion ~T0+600 glide"),("10-motion-t760-panel","Motion ~T0+760 panel")]
for d,n in (("A","Direction A — Backlit Stage"),("B","Direction B — Gazette")):
    sheet(f"sheet-{d}", [(f"{d}-{f}", f"{n} · {t}") for f,t in S], 5)
def cmp(name, states, cw=330):
    cells=""
    for f,t in states:
        cells+=f'<div class=c><img src="../A-{f}.png"><div>A · {t}</div></div><div class=c><img src="../B-{f}.png"><div>B · {t}</div></div>'
    cols=len(states)*2
    render(name, f"<html><style>{CSS}.g{{grid-template-columns:repeat({cols},{cw}px)}}</style><body><div class=g>{cells}</div></body></html>", cols*cw+(cols-1)*14+32, int(cw*852/393)+80)
cmp("compare-play",[(S[0][0],S[0][1]),(S[1][0],S[1][1]),(S[2][0],S[2][1])])
cmp("compare-won",[(S[3][0],S[3][1]),(S[4][0],S[4][1])])
cmp("compare-home-tutorial",[(S[5][0],S[5][1]),(S[6][0],S[6][1])])
