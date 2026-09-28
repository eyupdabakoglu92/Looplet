// Contact sheets for review (not selected-source): node sheets-d2.mjs . && sh render-d1.sh D2-sheet jobs-d2-sheets.txt
import fs from 'node:fs';
const S = {
  'D2-sheet-variants': [['D2-01-result-perfect', 'Perfect · ilk'], ['D2-02-result-perfect-new-best', 'Perfect + yeni en iyi'], ['D2-03-result-new-best-2star', 'Yeni en iyi · 2★'], ['D2-04-result-first-clear-2star', 'İlk · 2★'], ['D2-05-result-matched-best', 'En iyiye eşit'], ['D2-06-result-1star-no-improvement', '1★ · gelişme yok'], ['D2-07-result-no-optimal', 'Optimal yok'], ['D2-08-result-next-not-wired', 'Sonraki bağlı değil'], ['D2-09-result-level30-perfect', 'Seviye 30 · Perfect'], ['D2-09b-result-level30-2star', 'Seviye 30 · 2★']],
  'D2-sheet-text-and-devices': [['D2-10-result-text-cap-1_3', '1.3× cap · 16'], ['D2-v-16e-result-text-cap-1_3', '1.3× cap · 16e'], ['D2-v-promax-result-text-cap-1_3', '1.3× cap · Pro Max'], ['D2-10b-result-ax5-top', 'AX5 · kaydırma 0'], ['D2-10c-result-ax5-scrolled-end', 'AX5 · sonuna kaydırılmış'], ['D2-v-16e-result-ax5-top', 'AX5 · 16e'], ['D2-11-result-focus-back', 'odak · geri'], ['D2-12-result-cta-pressed', 'CTA basılı'], ['D2-v-16e-result-perfect', '16e · Perfect'], ['D2-v-promax-result-perfect-new-best', 'Pro Max · Perfect + yeni']],
  'D2-sheet-win-row2': [0, 60, 210, 450, 599, 680, 760, 840, 940, 1300].map((t) => [`D2-M-r2-t${String(t).padStart(4, '0')}`, `satır 2 · ${t} ms`]),
  'D2-sheet-win-rows-0-4-special': [...[0, 60, 210, 720, 940].map((t) => [`D2-M-r0-locked-t${String(t).padStart(4, '0')}`, `satır 0 · kilitli · ${t}`]), ...[210, 599, 720, 840, 940].map((t) => [`D2-M-r4-t${String(t).padStart(4, '0')}`, `satır 4 · ${t}`])],
  'D2-sheet-reduced-retry-frozen': [...[0, 300, 380, 560, 660].map((t) => [`D2-M-r2-reduced-t${String(t).padStart(4, '0')}`, `azaltılmış · ${t}`]), ...[0, 120, 220, 300, 360].map((t) => [`D2-M-retry-t${String(t).padStart(4, '0')}`, `Tekrar oyna · ${t}`]), ['D2-M-retry-reduced-t0080', 'Tekrar · azaltılmış 80'], ...[0, 60, 210].map((t) => [`D2-M-frozen-synthetic-t${String(t).padStart(4, '0')}`, `donmuş (sentetik) · ${t}`]), ['D2-v-16e-M-r4-t0720', '16e · satır 4 · 720'], ['D2-v-promax-M-r0-t0720', 'Pro Max · satır 0 · 720'], ['D2-v-16e-M-level30-r0-t0210', '16e · seviye 30 · 210']],
};
const jobs = [];
for (const [name, items] of Object.entries(S)) {
  const cols = 5, w = 240, rows = Math.ceil(items.length / cols), W = cols * (w + 16) + 16, H = rows * (w * 852 / 393 + 40) + 16;
  fs.writeFileSync(`${name}.html`, `<!doctype html><meta charset="utf-8"><style>body{margin:0;background:#15161c;font:600 13px Manrope,sans-serif;color:#cfd3e6;display:grid;grid-template-columns:repeat(${cols},${w}px);gap:16px;padding:16px}img{width:${w}px;border-radius:14px;display:block}figure{margin:0}figcaption{padding:6px 2px}</style>${items.map(([f, c]) => `<figure><img src="../${f}.png"><figcaption>${c}</figcaption></figure>`).join('')}`);
  jobs.push(`${name} ${W} ${Math.round(H)} 1`);
}
fs.writeFileSync('jobs-d2-sheets.txt', jobs.join('\n') + '\n');
