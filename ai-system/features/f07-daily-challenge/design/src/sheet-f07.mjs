// Contact sheets for review (not gate artefacts): node sheet-f07.mjs → F07-sheet-*.html (+ jobs-f07-sheets.txt)
import fs from 'node:fs';
const sheets = {
  'F07-sheet-1-directions-A-vs-B': ['F07-A-01-home-daily-available', 'F07-A-02-home-daily-done', 'F07-A-03-daily-ready', 'F07-A-04-daily-needs-connection', 'F07-A-05-result-first-run', 'F07-A-06-result-replay',
    'F07-B-01-home-daily-available', 'F07-B-02-home-daily-done', 'F07-B-03-daily-ready', 'F07-B-04-daily-needs-connection', 'F07-B-05-result-first-run', 'F07-B-06-result-replay'],
  'F07-sheet-2-A-home-and-daily-states': ['F07-A-01-home-daily-available', 'F07-A-02-home-daily-done', 'F07-A-10-home-daily-needs-connection', 'F07-A-12-home-daily-loading', 'F07-A-13-home-daily-streak-missed', 'F07-A-11-home-daily-hidden',
    'F07-A-20-daily-loading', 'F07-A-03-daily-ready', 'F07-A-21-daily-done-today', 'F07-A-04-daily-needs-connection', 'F07-A-22-daily-unavailable', 'F07-A-23-daily-ready-streak-missed'],
  'F07-sheet-3-A-play-result-motion': ['F07-A-30-play-daily-header', 'F07-A-05-result-first-run', 'F07-A-06-result-replay', 'F07-A-40-result-streak-reset-0to1', 'F07-A-41-result-share-slot-budget', 'F07-A-43-result-cta-pressed',
    'F07-A-M-streak-reveal-t0940', 'F07-A-M-streak-reveal-t1370', 'F07-A-M-streak-reveal-t1440', 'F07-A-M-home-entrance-t0120', 'F07-A-M-home-entrance-t0240', 'F07-A-M-home-entrance-t0420'],
  'F07-sheet-4-A-text-scale-and-devices': ['F07-A-50-home-text-cap-1_3', 'F07-A-51-home-ax5-top', 'F07-A-52-home-ax5-scrolled-end', 'F07-A-54-daily-ready-ax5-top', 'F07-A-55-daily-ready-ax5-scrolled-end', 'F07-A-56-daily-needs-connection-ax5-scrolled-end',
    'F07-A-42-result-share-slot-budget-cap-1_3', 'F07-A-58-result-ax5-top', 'F07-A-59-result-ax5-scrolled-end', 'F07-A-v-16e-home-text-cap-1_3', 'F07-A-v-promax-daily-done-today', 'F07-A-v-promax-result-first-run'],
};
const jobs = [];
for (const [name, list] of Object.entries(sheets)) {
  const cols = 6, cw = 300, rows = Math.ceil(list.length / cols), ch = 650 + 26;
  const cells = list.map((n) => `<figure><img src="../${n}.png"><figcaption>${n.replace('F07-', '')}</figcaption></figure>`).join('');
  fs.writeFileSync(`${name}.html`, `<!doctype html><meta charset="utf-8"><style>body{margin:0;background:#1b1e2b;display:grid;grid-template-columns:repeat(${cols},${cw}px);gap:14px;padding:14px;font:12px Menlo,monospace;color:#cfd3e6}figure{margin:0}img{width:${cw}px;height:auto;display:block;border-radius:10px}figcaption{padding-top:5px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}</style>${cells}`);
  jobs.push(`${name} ${cols * cw + (cols + 1) * 14} ${rows * ch + (rows + 1) * 14} 1`);
}
fs.writeFileSync('jobs-f07-sheets.txt', jobs.join('\n') + '\n');
