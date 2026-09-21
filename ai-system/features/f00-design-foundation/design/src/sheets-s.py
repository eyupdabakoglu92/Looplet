# composites for the selected-source set: contact sheet, transition strip, result variants
import subprocess, os
D=os.path.abspath(os.path.join(os.path.dirname(__file__),'..'))
CH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
CSS="body{margin:0;background:#3a3a3e;font:600 13px -apple-system,Helvetica;color:#ddd}.g{display:grid;gap:14px;padding:16px}.c{text-align:center}.c img{width:100%;display:block;border-radius:14px}.c div{margin:6px 0 2px}"
def render(name, html, w, h):
    p=os.path.join(D,'src',name+'.html'); open(p,'w').write(html)
    subprocess.run([CH,'--headless=new','--disable-gpu','--no-sandbox','--hide-scrollbars','--allow-file-access-from-files','--force-device-scale-factor=1',f'--window-size={w},{h}','--virtual-time-budget=4000',f'--screenshot={D}/{name}.png',f'file://{p}'],capture_output=True,timeout=60)
    print(name,w,h)
def sheet(name, items, cols, cw=300):
    rows=(len(items)+cols-1)//cols
    cells="".join(f'<div class=c><img src="../{f}.png"><div>{t}</div></div>' for f,t in items)
    render(name, f"<html><style>{CSS}.g{{grid-template-columns:repeat({cols},{cw}px)}}</style><body><div class=g>{cells}</div></body></html>", cols*cw+(cols-1)*14+32, rows*(int(cw*852/393)+44)+32)
sheet("sheet-S",[("S-01-play-idle","Play · idle"),("S-02-play-lifted-row","Play · row lifted"),("S-03-play-locked-frozen","Play · locked + frozen"),("S-04-result-perfect","Result · Perfect"),("S-04b-result-new-best","Result · new best"),("S-05-result-two-star","Result · 2★"),("S-06-home-design","Home · design (future items)"),("S-06b-home-today","Home · today"),("S-07-tutorial-column","Column tutorial"),("S-01b-play-idle-today","Play · today (no hint)")],5)
sheet("sheet-S-transition",[("S-08-transition-t0000","T0 · 0 ms"),("S-09-transition-t0150","150 ms · row lime"),("S-10-transition-t0600","600 ms · glide starts"),("S-11-transition-t0720","720 ms · mid-glide"),("S-12-transition-t0840","840 ms · docked, content arriving"),("S-13-transition-t0940-rest","940 ms · rest"),("S-14-transition-t1400-stars","1400 ms · stars filled"),("S-15-transition-reduced-t0300","Reduced motion · 300 ms hold"),("S-16-transition-reduced-t0660-rest","Reduced motion · 660 ms rest")],5)
