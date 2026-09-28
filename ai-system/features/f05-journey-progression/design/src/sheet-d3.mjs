// Contact sheets for review (not gate artefacts): node sheet-d3.mjs → D3-sheet-*.html (+ jobs-d3-sheets.txt)
import fs from 'node:fs';
const sheets = {
  'D3-sheet-home-states': ['D3-01-home-new-0of30', 'D3-02-home-mid-4of30', 'D3-03-home-in-progress-4of30', 'D3-04a-home-window-12of30', 'D3-04b-home-window-25of30', 'D3-05-home-replay-before-terminal', 'D3-06-home-terminal-30of30', 'D3-07-home-terminal-with-replay'],
  'D3-sheet-windowing-A-vs-B': ['D3-03-home-in-progress-4of30', 'D3-04a-home-window-12of30', 'D3-04b-home-window-25of30', 'D3-B-04of30-band', 'D3-B-12of30-band', 'D3-B-25of30-band'],
  'D3-sheet-text-and-devices': ['D3-10-home-text-cap-1_3', 'D3-10b-home-ax5', 'D3-10c-home-ax5-terminal-replay', 'D3-v-16e-home-ax5', 'D3-v-16e-home-in-progress', 'D3-v-promax-home-terminal-with-replay', 'D3-08-home-loading', 'D3-09-home-cta-pressed'],
  'D3-sheet-shell-and-entrance': ['D3-21-launch-ios', 'D3-22-splash', 'D3-M-entrance-t0080', 'D3-M-entrance-t0160', 'D3-M-entrance-t0340', 'D3-20-store-error', 'D3-20b-store-error-ax5', 'D3-20d-store-error-ax5-scrolled-end'],
};
const jobs = [];
for (const [name, list] of Object.entries(sheets)) {
  const cols = 4, cw = 300, rows = Math.ceil(list.length / cols), ch = 650 + 26;
  const cells = list.map((n) => `<figure><img src="../${n}.png"><figcaption>${n}</figcaption></figure>`).join('');
  fs.writeFileSync(`${name}.html`, `<!doctype html><meta charset="utf-8"><style>body{margin:0;background:#1b1e2b;display:grid;grid-template-columns:repeat(${cols},${cw}px);gap:14px;padding:14px;font:12px Menlo,monospace;color:#cfd3e6}figure{margin:0}img{width:${cw}px;height:auto;display:block;border-radius:10px}figcaption{padding-top:5px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}</style>${cells}`);
  jobs.push(`${name} ${cols * cw + (cols + 1) * 14} ${rows * ch + (rows + 1) * 14} 1`);
}
fs.writeFileSync('jobs-d3-sheets.txt', jobs.join('\n') + '\n');
