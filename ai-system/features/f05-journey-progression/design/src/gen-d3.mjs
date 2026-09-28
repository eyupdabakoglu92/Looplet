// F05-UI-D3 — Design Adoption Phase D3: Home + app shell (contract: F05 architecture.md §18).
// Derived from F00 design/src/gen-s.mjs (`homeScreen`, tokens, fonts, 358-pt reference geometry scaled by width) and
// F03 design/src/gen-d1.mjs (`loadErrorScreen` — the store-error screen is its sibling).
// New here: the loop-track windowing rule (direction A "sliding five", recommended; direction B "band window",
// the rendered alternative), every Home state incl. the N1 terminal-with-replay state, the store-error screen,
// native launch + Flutter splash, the Home entrance motion prototype, text scale 1.3× / AX5 and device variants.
// Layout is a flow column (card → CTA → subtitle), so free text can grow with the OS scale without overlap.
// Usage: node gen-d3.mjs [outDir]   then   sh render-d3.sh D3- jobs-d3.txt
// render-d3.sh is F03 render-d1.sh with this folder as its home (same method: headless Chrome, devicePixelRatio 2).
import fs from 'node:fs';
import path from 'node:path';
const OUT = process.argv[2] ?? '.';
const FONTS = '../../../f00-design-foundation/design/src/fonts';

// ---------------------------------------------------------------- tokens (app/lib/design/tokens.dart)
const K = {
  lime: '#DDFA6B', limeMid: '#D0EF58', limeInk: '#0B1020', peri: '#A8B4F9', periLo: '#8792F0', nodeCurTop: '#B9C3FF',
  text: '#F4F6FF', muted: '#AEB4CA', glassEdge: 'rgba(255,255,255,.10)', groundTop: '#0A1030', groundMid: '#070C25', groundBottom: '#050A1E',
};
const font = `
@font-face{font-family:'SpaceGrotesk';src:url('${FONTS}/SpaceGrotesk.ttf');font-weight:300 700}
@font-face{font-family:'Manrope';src:url('${FONTS}/Manrope.ttf');font-weight:200 800}`;
const BACKDROP = `radial-gradient(75% 40% at 90% 6%,#2D3766 0%,rgba(45,55,102,0) 72%),radial-gradient(55% 26% at 0% 58%,rgba(26,88,96,.32),rgba(26,88,96,0) 72%),linear-gradient(${K.groundTop} 0%,${K.groundMid} 55%,${K.groundBottom} 100%)`;

// ---------------------------------------------------------------- icons (F00 drawn set + D1 loopBreak)
const ic = (d, c, s, w = 1.7) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${c}" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round">${d}</svg>`;
const I = {
  right: (c, s) => ic('<path d="M5 12h14"/><path d="m13 6 6 6-6 6"/>', c, s, 1.9),
  loopBreak: (c, s) => ic('<path d="M16.25 4.64A8.5 8.5 0 1 0 20.37 10.52"/><path d="M12 8.3v4.4"/><path d="M12 15.9h.01" stroke-width="2.6"/>', c, s, 1.8),
};

// ---------------------------------------------------------------- frame
function frame(W, H) { const s = W / 358; return { W, H, s, e: Math.max(0, H - 717 * s) }; }
function page(W, H, body, extraHead = '') {
  return `<!doctype html><html><head><meta charset="utf-8"><style>${font}
*{box-sizing:border-box;margin:0;padding:0}html,body{width:${W}px;height:${H}px;overflow:hidden}
body{position:relative;font-family:'Manrope',sans-serif;color:${K.text};background:${BACKDROP}}
.abs{position:absolute}.sg{font-family:'SpaceGrotesk',sans-serif}
.cap{font-family:'Manrope';font-weight:600;letter-spacing:.2em;color:${K.muted};line-height:1.25;white-space:nowrap}
.glass{position:relative;background:linear-gradient(155deg,rgba(60,74,134,.50),rgba(22,30,64,.58));border:1px solid ${K.glassEdge};box-shadow:0 24px 60px rgba(2,4,16,.35),inset 0 1px 0 rgba(255,255,255,.07)}
.pill{display:flex;align-items:center;justify-content:center}
.em{color:${K.lime}}
</style>${extraHead}</head><body>${body}</body></html>`;
}
const status = (F) => `<div class="abs" style="left:${25 * F.s}px;top:${15 * F.s}px;font:500 ${14.5 * F.s}px/1 Manrope;color:#fff">9:41</div>
<div class="abs" style="right:${25 * F.s}px;top:${17 * F.s}px;display:flex;gap:${5 * F.s}px;align-items:center"><svg width="${17 * F.s}" height="${11 * F.s}" viewBox="0 0 17 11" fill="#fff"><rect y="7" width="3" height="4" rx="1"/><rect x="4.7" y="4.5" width="3" height="6.5" rx="1"/><rect x="9.4" y="2" width="3" height="9" rx="1"/><rect x="14" width="3" height="11" rx="1"/></svg><svg width="${24 * F.s}" height="${11 * F.s}" viewBox="0 0 24 11" fill="none" stroke="#fff" stroke-width="1"><rect x=".5" y=".5" width="20" height="10" rx="3.2" opacity=".55"/><rect x="2" y="2" width="17" height="7" rx="1.8" fill="#fff" stroke="none"/></svg></div>
<div class="abs" style="left:${F.W / 2 - 47 * F.s}px;top:${10 * F.s}px;width:${94 * F.s}px;height:${28 * F.s}px;border-radius:${14 * F.s}px;background:#000"></div>`;
const homeBar = (F) => `<div class="abs" style="left:${F.W / 2 - 62 * F.s}px;bottom:${7 * F.s}px;width:${124 * F.s}px;height:${4.6 * F.s}px;border-radius:3px;background:rgba(255,255,255,.62)"></div>`;
const wordmark = (F, cap = 1, op = 1, extra = '') => `<div class="abs sg" id="wm" style="left:${25 * F.s}px;top:${58 * F.s}px;font-size:${25 * F.s * cap}px;font-weight:500;line-height:1;letter-spacing:-.01em;color:${K.text};white-space:nowrap;opacity:${op};${extra}">Loop<span style="color:${K.lime}">let</span></div>`;

// ---------------------------------------------------------------- the Journey model (F05 architecture §6) → the Home view
// completed: Set of levels; inProgress: level of the active Journey snapshot (or null). Mirrors JourneyProgressModel.
function model(completedUpTo, inProgress = null, loading = false) {
  const completed = new Set(); for (let n = 1; n <= completedUpTo; n++) completed.add(n);
  const highest = Math.min(30, completedUpTo + 1);
  let current = inProgress;
  if (current == null) for (let n = 1; n <= 30; n++) if (n <= highest && !completed.has(n)) { current = n; break; }
  return { completed, highest, inProgress, current, count: completed.size, terminal: completed.size === 30, loading };
}
// Node state for level n (the track's four states + the terminal finish).
function nodeState(M, n) {
  if (M.current == null && n === 30) return 'finish';
  if (n === M.current) return 'current';
  if (M.completed.has(n)) return 'done';
  if (n <= M.highest) return 'open';
  return 'locked';
}

// ---------------------------------------------------------------- the loop track, direction A — "sliding five" (recommended)
// Window rule (§D3-W): 5 consecutive levels. terminal (current == null) → 26–30. current is the frontier (no completed
// level above it) → start = clamp(current − 4, 1, 26): the current node sits at the rising end. current is a replay
// (a completed level above it exists) → start = clamp(current − 2, 1, 26): done levels on both sides.
function windowA(M) {
  if (M.current == null) return 26;
  const replay = [...M.completed].some((n) => n > M.current);
  return Math.min(26, Math.max(1, M.current - (replay ? 2 : 4)));
}
// Card-local geometry (358-pt space). Gaps: small↔small 50, anything↔big (current / finish, 58 pt + 76 pt halo) 64.
// The chain is centred in the 308-pt card; y rises with x: y = 236 − 62·p^1.25, p = (x − 40) / 230.
function placeA(levels, states) {
  const big = (st) => st === 'current' || st === 'finish';
  const xs = [0];
  for (let i = 1; i < levels.length; i++) xs.push(xs[i - 1] + (big(states[i]) || big(states[i - 1]) ? 64 : 50));
  const off = 154 - (xs[0] + xs[xs.length - 1]) / 2;
  return xs.map((x) => { const X = x + off, p = Math.max(0, Math.min(1, (X - 40) / 230)); return { x: X, y: 236 - 62 * Math.pow(p, 1.25) }; });
}
const TRACK_TOP = 134; // card-local y where the track block starts (headline bottom 122 + 12)
let NUM_CAP = 1; // set per page from the OS text scale (capped at 1.3×)
function nodeHtml(n, st, cx, cy, s) {
  const big = st === 'current' || st === 'finish', sz = (big ? 58 : 38) * s, r = sz * 0.34;
  const L = cx - sz / 2, T = cy - sz / 2, fs = (big ? 17 : 14) * s * NUM_CAP;
  const base = `position:absolute;left:${L}px;top:${T}px;width:${sz}px;height:${sz}px;border-radius:${r}px;display:flex;align-items:center;justify-content:center;font:500 ${fs}px/1 SpaceGrotesk;`;
  if (st === 'done') return `<div data-n="${n}" data-st="done" style="${base}background:linear-gradient(160deg,#E3FB7E,#CDEB4B);color:${K.limeInk};box-shadow:0 8px 20px rgba(208,239,88,.28)">${n}</div>`;
  if (st === 'open') return `<div data-n="${n}" data-st="open" style="${base}background:rgba(255,255,255,.06);border:1.5px solid rgba(168,180,249,.62);color:${K.text}">${n}</div>`;
  if (st === 'locked') return `<div data-n="${n}" data-st="locked" style="${base}background:rgba(255,255,255,.035);border:1.5px dashed rgba(174,180,202,.62);color:${K.muted}">${n}</div>`;
  const halo = `<div style="position:absolute;left:${cx - 38 * s}px;top:${cy - 38 * s}px;width:${76 * s}px;height:${76 * s}px;border-radius:${26 * s}px;`;
  if (st === 'current') return `${halo}background:rgba(168,180,249,.16);border:1px solid rgba(168,180,249,.25)"></div><div data-n="${n}" data-st="current" style="${base}background:linear-gradient(160deg,${K.nodeCurTop},${K.periLo});color:${K.limeInk};box-shadow:0 12px 30px rgba(135,146,240,.45)">${n}</div>`;
  return `${halo}background:rgba(221,250,107,.11);border:1px solid rgba(221,250,107,.30)"></div><div data-n="${n}" data-st="finish" style="${base}background:linear-gradient(160deg,#E3FB7E,#CDEB4B);color:${K.limeInk};box-shadow:0 12px 30px rgba(208,239,88,.34)">${n}</div>`;
}
function segPath(a, b) { const dx = (b.x - a.x) * 0.45; return `M${a.x} ${a.y} C ${a.x + dx} ${a.y}, ${b.x - dx} ${b.y}, ${b.x} ${b.y}`; }
function trackA(M, s, cardW) {
  const start = windowA(M), levels = [0, 1, 2, 3, 4].map((i) => start + i), states = levels.map((n) => nodeState(M, n));
  const pts = placeA(levels, states).map((p) => ({ x: p.x * s, y: (p.y - TRACK_TOP) * s }));
  let svg = `<defs><linearGradient id="gcur" x1="0" x2="1"><stop offset="0" stop-color="${K.limeMid}"/><stop offset="1" stop-color="${K.peri}"/></linearGradient><linearGradient id="glead" x1="0" x2="1"><stop offset="0" stop-color="${K.limeMid}" stop-opacity="0"/><stop offset="1" stop-color="${K.limeMid}" stop-opacity=".9"/></linearGradient></defs>`;
  const y0 = (236 - TRACK_TOP) * s;
  if (start > 1) svg += `<path d="${segPath({ x: 0, y: y0 + 4 * s }, pts[0])}" fill="none" stroke="url(#glead)" stroke-width="${3.2 * s}" stroke-linecap="round"/>`;
  for (let i = 1; i < 5; i++) {
    const to = states[i], d = segPath(pts[i - 1], pts[i]);
    if (to === 'done' || to === 'finish') svg += `<path d="${d}" fill="none" stroke="${K.limeMid}" stroke-width="${3.2 * s}" stroke-linecap="round" opacity="${states[i - 1] === 'current' ? 0.55 : 0.9}"/>`;
    else if (to === 'current') svg += `<path d="${d}" fill="none" stroke="url(#gcur)" stroke-width="${3.2 * s}" stroke-linecap="round" opacity=".9"/>`;
    else svg += `<path d="${d}" fill="none" stroke="rgba(174,180,202,.42)" stroke-width="${2 * s}" stroke-dasharray="${2 * s} ${5 * s}" stroke-linecap="round"/>`;
  }
  const last = pts[4];
  if (start + 4 < 30 && cardW - last.x > 48 * s) svg += `<path d="M${last.x + 30 * s} ${last.y} L${cardW - 6 * s} ${last.y - 8 * s}" fill="none" stroke="rgba(174,180,202,.3)" stroke-width="${2 * s}" stroke-dasharray="${2 * s} ${5 * s}" stroke-linecap="round"/>`;
  let nodes = '';
  levels.forEach((n, i) => { nodes += nodeHtml(n, states[i], pts[i].x, pts[i].y, s); });
  return { html: `<svg class="abs" style="left:0;top:0;overflow:visible" width="${cardW}" height="${166 * s}">${svg}</svg>${nodes}`, levels, states };
}

// ---------------------------------------------------------------- direction B — "band window" (rendered alternative)
// The window is the current difficulty band (1–3, 4–6, 7–10, 11–15, 16–20, 21–25, 26–30; 3–5 nodes); seven band pips
// under the label show the whole Journey (done lime, current periwinkle, ahead outline), widths ∝ band size.
const BANDS = [[1, 3], [4, 6], [7, 10], [11, 15], [16, 20], [21, 25], [26, 30]];
function trackB(M, s, cardW) {
  const c = M.current ?? 30, band = BANDS.find(([a, b]) => c >= a && c <= b), levels = [];
  for (let n = band[0]; n <= band[1]; n++) levels.push(n);
  const states = levels.map((n) => nodeState(M, n)), pts = placeA(levels, states).map((p) => ({ x: p.x * s, y: (p.y - TRACK_TOP + 10) * s }));
  let svg = '';
  for (let i = 1; i < levels.length; i++) {
    const to = states[i], d = segPath(pts[i - 1], pts[i]);
    svg += to === 'locked' || to === 'open' ? `<path d="${d}" fill="none" stroke="rgba(174,180,202,.42)" stroke-width="${2 * s}" stroke-dasharray="${2 * s} ${5 * s}" stroke-linecap="round"/>` : `<path d="${d}" fill="none" stroke="${to === 'current' ? K.peri : K.limeMid}" stroke-width="${3.2 * s}" stroke-linecap="round" opacity=".9"/>`;
  }
  let nodes = ''; levels.forEach((n, i) => { nodes += nodeHtml(n, states[i], pts[i].x, pts[i].y, s); });
  return { html: `<svg class="abs" style="left:0;top:0;overflow:visible" width="${cardW}" height="${166 * s}">${svg}</svg>${nodes}`, levels, states };
}
function bandPips(M, s) {
  const c = M.current ?? 31; const unit = 150 * s / 30;
  return `<div style="display:flex;gap:${4 * s}px;margin-top:${10 * s}px">${BANDS.map(([a, b]) => {
    const w = (b - a + 1) * unit, done = b < c, cur = c >= a && c <= b;
    return `<i style="display:block;width:${w}px;height:${5 * s}px;border-radius:3px;${done ? `background:${K.limeMid}` : cur ? `background:${K.peri}` : 'border:1px solid rgba(174,180,202,.45)'}"></i>`;
  }).join('')}</div>`;
}

// ---------------------------------------------------------------- copy (interim — F05 architecture §18.3 (4); JourneyStrings)
function copy(M) {
  const replay = M.inProgress != null && [...M.completed].some((n) => n >= M.inProgress);
  if (M.terminal) return { head: `Tüm <span class="em">döngüler</span><br>tamam.`, cta: M.inProgress != null ? 'Devam et' : 'Tekrar oyna', sub: M.inProgress != null ? `Seviye\u00A0${M.inProgress} ·\u00A0sürüyor` : 'Seviye\u00A01' };
  if (replay) return { head: `Yarım kalan<br><span class="em">döngüne</span> dön.`, cta: 'Devam et', sub: `Seviye\u00A0${M.current} ·\u00A0sürüyor` };
  if (M.count === 0 && M.inProgress == null) return { head: `İlk<br><span class="em">döngüyü</span> çöz.`, cta: 'Devam et', sub: 'Seviye\u00A01' };
  return { head: `Sıradaki<br><span class="em">döngüyü</span> çöz.`, cta: 'Devam et', sub: `Seviye\u00A0${M.current}${M.inProgress != null ? ' ·\u00A0sürüyor' : ''}` };
}

// ---------------------------------------------------------------- Home
// o: tx (OS text scale: container text capped at 1.3×, free text follows), dir 'A'|'B', pressed, focus, entrance (ms or null), rm
function homeScreen(W, H, M, o = {}) {
  const F = frame(W, H), s = F.s, tx = o.tx ?? 1, cap = Math.min(tx, 1.3), cardW = 308 * s, C = copy(M);
  NUM_CAP = cap;
  if (M.loading) return splash(W, H); // the first frame before the model loads = the splash frame (§D3 state design)
  const cardTop = 115 * s + F.e * 0.1;
  const tr = o.dir === 'B' ? trackB(M, s, cardW) : trackA(M, s, cardW);
  const swirl = `<svg class="abs" style="left:0;bottom:0" width="${cardW}" height="${300 * s}" viewBox="0 0 308 300" preserveAspectRatio="none"><g fill="none"><ellipse cx="60" cy="210" rx="170" ry="64" stroke="rgba(190,205,170,.14)" stroke-width="20" transform="rotate(-9 60 210)"/><ellipse cx="240" cy="230" rx="150" ry="80" stroke="rgba(120,132,225,.26)" stroke-width="24" transform="rotate(-14 240 230)"/></g></svg>`;
  const label = M.loading ? '' : `<div class="cap" style="font-size:${11 * s * cap}px">YOLCULUK · ${M.count} / 30</div>${o.dir === 'B' ? bandPips(M, s) : ''}`;
  const head = M.loading ? '' : `<div class="sg" style="margin-top:${15 * s}px;font-size:${28 * s * cap}px;font-weight:500;line-height:1.16;letter-spacing:-.005em;overflow-wrap:normal;word-break:keep-all">${C.head}</div>`;
  const ent = (delay) => o.entrance == null ? '' : `class="ent" style="--d:${delay}ms"`;
  const card = `<div ${ent(0)}><div class="glass" id="card" style="width:${cardW}px;margin-left:${0.5 * s}px;border-radius:${30 * s}px;overflow:hidden;padding:${31 * s}px ${24.5 * s}px 0;min-height:${300 * s}px">${swirl}
    <div style="position:relative">${label}${head}</div>
    <div id="trk" style="position:relative;margin:${12 * s}px ${-24.5 * s}px 0;height:${166 * s}px">${M.loading ? '' : tr.html}</div></div></div>`;
  const pressed = o.pressed ? 'transform:scale(.98);' : '';
  const focus = o.focus ? `outline:${2 * s}px solid ${K.peri};outline-offset:${3 * s}px;` : '';
  const cta = M.loading ? '' : `<div ${ent(60)}><div class="pill" id="cta" style="margin-top:${22 * s}px;width:${309 * s}px;min-height:${63 * s}px;border-radius:${32 * s}px;justify-content:space-between;gap:${12 * s}px;padding:${12 * s}px ${23 * s}px;background:linear-gradient(180deg,#E4FB80,#D5F252);box-shadow:0 18px 50px rgba(208,239,88,.26);color:${K.limeInk};font:500 ${16 * s * tx}px/1.2 Manrope;${pressed}${focus}"><span>${C.cta}</span><span style="display:flex;flex:none">${I.right(K.limeInk, 20 * s)}</span></div></div>
    <div ${ent(120)}><div id="sub" style="margin-top:${17 * s}px;text-align:center;font:500 ${14 * s * tx}px/1.3 Manrope;color:${K.muted}">${C.sub}</div></div>`;
  const entHead = o.entrance == null ? '' : `<style>.ent{opacity:0;transform:translateY(${10 * s}px);animation:in 240ms cubic-bezier(.22,.61,.36,1) forwards;animation-delay:var(--d)}
@keyframes in{to{opacity:1;transform:none}}${o.rm ? '.ent{animation:none;opacity:1;transform:none}' : ''}</style>
<script>addEventListener('load',()=>{const q=new URLSearchParams(location.search),t=q.get('t');if(q.get('rm')==='1'){document.getAnimations().forEach(a=>a.finish());}else if(t!=null){document.getAnimations().forEach(a=>{a.pause();a.currentTime=+t;});}});</script>`;
  const col = `<div class="abs" id="col" style="left:${24 * s}px;top:${cardTop}px;width:${309 * s}px">${card}${cta}</div>`;
  return page(W, H, `${status(F)}${wordmark(F, cap)}${col}${homeBar(F)}`, entHead);
}

// ---------------------------------------------------------------- store-error screen (F08 `StoreErrorScreen`; sibling of D1-07)
function errorScreen(W, H, o = {}) {
  const F = frame(W, H), s = F.s, tx = o.tx ?? 1, cap = Math.min(tx, 1.3), bandTop = 118 * s, bandBottom = H - 40 * s;
  const debug = o.debug ? `<div style="border-radius:${18 * s}px;padding:${12 * s}px ${14 * s}px;background:rgba(5,10,30,.72);border:1px dashed rgba(174,180,202,.35)"><div class="cap" style="font-size:${10 * s}px;letter-spacing:.16em">DEBUG · YALNIZ GELİŞTİRME DERLEMESİ</div><div style="margin-top:${6 * s}px;font:500 ${11 * s}px/1.4 ui-monospace,Menlo,monospace;color:#8C93AE;word-break:break-all">SqliteException(26): while executing, file is not a database, PRAGMA user_version;</div></div>` : '';
  const scroll = o.scroll === 'END' ? `<script>document.fonts.ready.then(()=>{const c=document.getElementById('col'),b=c.getBoundingClientRect().bottom,d=Math.max(0,b-(${H}-${34 * s}));document.getElementById('sc').style.transform='translateY('+(-d)+'px)';});</script>` : '';
  const body = `<div id="sc">${wordmark(F, cap)}
  <div class="abs" id="col" style="left:${24.5 * s}px;top:${bandTop}px;width:${309 * s}px;min-height:${bandBottom - bandTop}px;display:flex;flex-direction:column;justify-content:center;gap:${20 * s}px">
    <div class="glass" style="border-radius:${30 * s}px;padding:${28 * s}px ${26 * s}px ${30 * s}px">
      <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:${12 * s}px">
        <span class="cap" style="font-size:${11.5 * s * cap}px;padding-top:${4 * s}px">KAYITLI VERİLER</span>
        <span style="display:flex;opacity:.9;flex:none">${I.loopBreak(K.peri, 44 * s)}</span>
      </div>
      <div class="sg" style="margin-top:${16 * s}px;font-size:${28 * s * cap}px;font-weight:500;line-height:1.16;letter-spacing:-.005em">Kayıtlı verilerin<br>açılamadı.</div>
      <div style="margin-top:${12 * s}px;font:500 ${14.5 * s * tx}px/1.4 Manrope;color:${K.muted}">İlerlemen güvende; hiçbir şey silinmedi.</div>
    </div>
    <div class="pill" style="justify-content:flex-start;min-height:${63 * s}px;border-radius:999px;background:linear-gradient(180deg,#E2FB78,#D3F04F);box-shadow:0 14px 32px rgba(2,4,16,.5);padding:${12 * s}px ${23 * s}px;font:500 ${16 * s * tx}px/1.2 Manrope;color:${K.limeInk}">Tekrar dene</div>
    ${debug}
  </div></div>${o.scroll === 'END' ? `<div class="abs" style="left:0;top:0;width:${W}px;height:${54 * s}px;background:linear-gradient(${K.groundTop} 78%,rgba(10,16,48,0))"></div>` : ''}${status(F)}${homeBar(F)}${scroll}`;
  return page(W, H, body);
}

// ---------------------------------------------------------------- native launch + Flutter splash
const launch = (W, H, android = false) => { const F = frame(W, H); return page(W, H, android ? '' : status(F)); };
const splash = (W, H) => { const F = frame(W, H); return page(W, H, `${status(F)}${wordmark(F)}${homeBar(F)}`); };
// Entrance prototype: launch backdrop → splash (wordmark fades in 0–160 ms) → the Home content (card 0–240, CTA 60–300,
// subtitle 120–340 ms; 10·s rise, ease-out). ?t=<ms> freezes; ?rm=1 = reduced motion (content appears at once).
function entrancePrototype(W, H, M) {
  return homeScreen(W, H, M, { entrance: 0 });
}

// ---------------------------------------------------------------- contrast (WCAG, composited on the navy ground)
const hex = (h) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16));
const over = (fg, a, bg) => fg.map((c, i) => c * a + bg[i] * (1 - a));
const lum = (c) => { const f = (v) => { v /= 255; return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4); }; return 0.2126 * f(c[0]) + 0.7152 * f(c[1]) + 0.0722 * f(c[2]); };
const ratio = (a, b) => { const x = lum(a), y = lum(b); return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); };
function contrastTable() {
  const navy = hex('#0A1030'), glass = over([60, 74, 134], 0.5, navy), glassLo = over([22, 30, 64], 0.58, over([0, 0, 0], 0, hex('#070C25')));
  const lockedBg = over([255, 255, 255], 0.035, glass), openBg = over([255, 255, 255], 0.06, glass);
  const rows = [
    ['wordmark "Loop" #F4F6FF on navy', ratio(hex('#F4F6FF'), navy)],
    ['wordmark "let" #DDFA6B on navy', ratio(hex('#DDFA6B'), navy)],
    ['label #AEB4CA on glass (top)', ratio(hex('#AEB4CA'), glass)],
    ['headline #F4F6FF on glass (top)', ratio(hex('#F4F6FF'), glass)],
    ['headline lime #DDFA6B on glass (top)', ratio(hex('#DDFA6B'), glass)],
    ['done numeral #0B1020 on lime #CDEB4B', ratio(hex('#0B1020'), hex('#CDEB4B'))],
    ['current numeral #0B1020 on #8792F0 (darkest stop)', ratio(hex('#0B1020'), hex('#8792F0'))],
    ['open numeral #F4F6FF on open node', ratio(hex('#F4F6FF'), openBg)],
    ['locked numeral #AEB4CA on locked node', ratio(hex('#AEB4CA'), lockedBg)],
    ['locked outline rgba(174,180,202,.62) on glass (non-text, ≥ 3)', ratio(over(hex('#AEB4CA'), 0.62, glass), glass)],
    ['open outline rgba(168,180,249,.62) on glass (non-text, ≥ 3)', ratio(over(hex('#A8B4F9'), 0.62, glass), glass)],
    ['CTA ink #0B1020 on #D5F252', ratio(hex('#0B1020'), hex('#D5F252'))],
    ['subtitle #AEB4CA on ground mid #070C25', ratio(hex('#AEB4CA'), hex('#070C25'))],
    ['error body #AEB4CA on glass (top)', ratio(hex('#AEB4CA'), glass)],
    ['error glyph #A8B4F9 on glass (non-text)', ratio(hex('#A8B4F9'), glass)],
  ];
  return rows.map(([k, v]) => `${v.toFixed(2).padStart(6)} : 1   ${k}`).join('\n') + '\n';
}

// ---------------------------------------------------------------- emit
const jobs = [];
const emit = (name, html, W, H, dsf = 2) => { fs.writeFileSync(path.join(OUT, name + '.html'), html); jobs.push(`${name} ${W} ${H}${dsf !== 2 ? ' ' + dsf : ''}`); };
const W = 393, H = 852;
const S = {
  new: model(0),                    // 0 / 30, nothing in progress
  new_ip: model(0, 1),              // level 1 started
  mid: model(4),                    // 4 / 30, level 5 not started
  ip: model(4, 5),                  // 4 / 30, level 5 in progress — S-06b parity
  w12: model(12, 13),               // windowing 12 / 30
  w25: model(25),                   // windowing 25 / 30
  replay: model(12, 7),             // 12 / 30, replaying level 7 (frontier 13)
  term: model(30),                  // 30 / 30, nothing in progress
  termReplay: model(30, 12),        // 30 / 30, replay of level 12 in progress (N1, §18.3 (2))
  loading: { ...model(0), loading: true },
};
emit('D3-01-home-new-0of30', homeScreen(W, H, S.new), W, H);
emit('D3-01b-home-new-level1-in-progress', homeScreen(W, H, S.new_ip), W, H);
emit('D3-02-home-mid-4of30', homeScreen(W, H, S.mid), W, H);
emit('D3-03-home-in-progress-4of30', homeScreen(W, H, S.ip), W, H);
emit('D3-04a-home-window-12of30', homeScreen(W, H, S.w12), W, H);
emit('D3-04b-home-window-25of30', homeScreen(W, H, S.w25), W, H);
emit('D3-05-home-replay-before-terminal', homeScreen(W, H, S.replay), W, H);
emit('D3-06-home-terminal-30of30', homeScreen(W, H, S.term), W, H);
emit('D3-07-home-terminal-with-replay', homeScreen(W, H, S.termReplay), W, H);
emit('D3-08-home-loading', homeScreen(W, H, S.loading), W, H);
emit('D3-09-home-cta-pressed', homeScreen(W, H, S.ip, { pressed: true }), W, H);
emit('D3-10-home-text-cap-1_3', homeScreen(W, H, S.w12, { tx: 1.3 }), W, H);
emit('D3-10b-home-ax5', homeScreen(W, H, S.w12, { tx: 3.12 }), W, H);
emit('D3-10c-home-ax5-terminal-replay', homeScreen(W, H, S.termReplay, { tx: 3.12 }), W, H);
emit('D3-11-home-focus-cta', homeScreen(W, H, S.ip, { focus: true }), W, H);
// direction B (band window) — the rendered alternative at the same states
emit('D3-B-04of30-band', homeScreen(W, H, S.ip, { dir: 'B' }), W, H);
emit('D3-B-12of30-band', homeScreen(W, H, S.w12, { dir: 'B' }), W, H);
emit('D3-B-25of30-band', homeScreen(W, H, S.w25, { dir: 'B' }), W, H);
// shell
emit('D3-20-store-error', errorScreen(W, H), W, H);
emit('D3-20b-store-error-ax5', errorScreen(W, H, { tx: 3.12 }), W, H);
emit('D3-20d-store-error-ax5-scrolled-end', errorScreen(W, H, { tx: 3.12, scroll: 'END' }), W, H);
emit('D3-20c-store-error-debug-build', errorScreen(W, H, { debug: true }), W, H);
emit('D3-21-launch-ios', launch(W, H), W, H);
emit('D3-21b-launch-android', launch(412, 915, true), 412, 915);
emit('D3-22-splash', splash(W, H), W, H);
// the native launch asset (no status bar): 430×932 @3x = 1290×2796 px, aspect-filled over a solid groundMid (#070C25)
emit('D3-asset-launch-backdrop', page(430, 932, ''), 430, 932, 3);
// entrance stills (prototype frozen at t)
for (const t of [0, 80, 160, 240, 340]) emit(`D3-M-entrance-t${String(t).padStart(4, '0')}`, homeScreen(W, H, S.ip, { entrance: 0 }).replace("q.get('t')", `(q.get('t')??'${t}')`), W, H);
emit('D3-M-entrance-reduced', homeScreen(W, H, S.ip, { entrance: 0, rm: true }), W, H);
// device variants
for (const [tag, w, h] of [['16e', 390, 844], ['promax', 440, 956]]) {
  emit(`D3-v-${tag}-home-in-progress`, homeScreen(w, h, S.ip), w, h);
  emit(`D3-v-${tag}-home-terminal-with-replay`, homeScreen(w, h, S.termReplay), w, h);
  emit(`D3-v-${tag}-home-text-cap-1_3`, homeScreen(w, h, S.w12, { tx: 1.3 }), w, h);
  emit(`D3-v-${tag}-store-error`, errorScreen(w, h), w, h);
}
emit('D3-v-16e-home-ax5', homeScreen(390, 844, S.w12, { tx: 3.12 }), 390, 844);
fs.writeFileSync(path.join(OUT, 'D3-motion-prototype.html'), entrancePrototype(W, H, S.ip));
fs.writeFileSync(path.join(OUT, 'jobs-d3.txt'), jobs.join('\n') + '\n');
fs.writeFileSync(path.join(OUT, 'contrast-d3.txt'), '# F05-UI-D3 contrast (WCAG 2.x; translucent fills composited on the navy ground; gen-d3.mjs contrastTable)\n' + contrastTable());
// window table for the acceptance list: the level window and node states per state
const wt = Object.entries(S).filter(([k]) => k !== 'loading').map(([k, M]) => { const st = windowA(M); return `${k.padEnd(11)} count ${String(M.count).padStart(2)} inProgress ${String(M.inProgress ?? '-').padStart(2)} current ${String(M.current ?? '-').padStart(2)} → window ${st}–${st + 4}: ${[0, 1, 2, 3, 4].map((i) => `${st + i}:${nodeState(M, st + i)}`).join(' ')}`; });
fs.writeFileSync(path.join(OUT, 'window-d3.txt'), '# F05-UI-D3 loop-track window (direction A) per rendered state — gen-d3.mjs windowA / nodeState\n' + wt.join('\n') + '\n');
console.log(jobs.length + ' pages + prototype');
