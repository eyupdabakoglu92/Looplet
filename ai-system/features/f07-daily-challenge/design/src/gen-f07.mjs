// F07-UI — the Daily surfaces on the Selected Foundation (Direction C "Loop Glass"; contract: F07 architecture.md D3–D8).
// Derived from F05 design/src/gen-d3.mjs (Home: tokens, fonts, 358-pt reference geometry scaled by width, the loop track)
// and F03 design/src/gen-d2.mjs (the D1 Play pieces and the D2 full-screen result column).
// Two materially different directions on identical content:
//   A "Hafta döngüsü" (week loop, recommended) — the streak is drawn as the last seven days in the loop-track language;
//   B "Günün bileti" (daily ticket) — typographic: a large #N ticket with a perforated stub; the streak is numerals.
// Render content: the Journey level 4 grid (BALIK, optimal 4, real content/journey/tr) stands in for a Daily puzzle —
// a design fixture, not product Daily content. Today = 2026-11-03 (Salı); numbering epoch 2026-10-01 → #34.
// Usage: node gen-f07.mjs .   then   sh render-f07.sh F07- jobs-f07.txt   (headless Chrome, @2x → ../<name>.png)
//        sh fit-f07.sh  → fit-f07.txt (the measured column bottoms of every rendered page, from the page's own check script)
import fs from 'node:fs';
import path from 'node:path';
const OUT = process.argv[2] ?? '.';
const FONTS = '../../../f00-design-foundation/design/src/fonts';

// ---------------------------------------------------------------- tokens (app/lib/design/tokens.dart — unchanged, no new token)
const K = {
  lime: '#DDFA6B', limeMid: '#D0EF58', limeInk: '#0B1020', peri: '#A8B4F9', periLo: '#8792F0', nodeCurTop: '#B9C3FF',
  text: '#F4F6FF', muted: '#AEB4CA', ink: '#141826', glassEdge: 'rgba(255,255,255,.10)', outlineEdge: 'rgba(255,255,255,.18)',
  groundTop: '#0A1030', groundMid: '#070C25', groundBottom: '#050A1E',
};
const font = `
@font-face{font-family:'SpaceGrotesk';src:url('${FONTS}/SpaceGrotesk.ttf');font-weight:300 700}
@font-face{font-family:'Manrope';src:url('${FONTS}/Manrope.ttf');font-weight:200 800}`;
const BACKDROP = `radial-gradient(75% 40% at 90% 6%,#2D3766 0%,rgba(45,55,102,0) 72%),radial-gradient(55% 26% at 0% 58%,rgba(26,88,96,.32),rgba(26,88,96,0) 72%),linear-gradient(${K.groundTop} 0%,${K.groundMid} 55%,${K.groundBottom} 100%)`;

// ---------------------------------------------------------------- icons (F00 drawn set; NEW here: check, offline)
const ic = (d, c, s, w = 1.7) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${c}" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round" style="display:block;flex:none">${d}</svg>`;
const I = {
  back: (c, s) => ic('<path d="m15 5-7 7 7 7"/>', c, s, 1.9),
  right: (c, s) => ic('<path d="M5 12h14"/><path d="m13 6 6 6-6 6"/>', c, s, 1.9),
  sparkle: (c, s) => ic('<path d="M10 4.5 12 10l5.5 2-5.5 2-2 5.5-2-5.5-5.5-2 5.5-2Z"/><path d="M19 3.5v4M17 5.5h4"/>', c, s),
  flame: (c, s) => ic('<path d="M12 21.5c-3.9 0-6.8-2.7-6.8-6.4 0-3.3 2.2-5.4 3.9-7.6.5 1.7 1.4 2.8 2.6 3.3.2-2.9 1.4-5.6 3.6-7.8.2 3 1.5 4.9 2.8 6.6 1 1.4 1.7 3 1.7 5.1 0 4-3 6.8-7.8 6.8Z"/><path d="M12 21.5c-1.7 0-2.9-1.2-2.9-2.9 0-1.6 1.2-2.6 2.2-3.8.9 1.6 3.6 2.1 3.6 4 0 1.6-1.2 2.7-2.9 2.7Z"/>', c, s, 1.6),
  check: (c, s) => ic('<path d="m5 12.5 4.5 4.5L19 7.5"/>', c, s, 2.1),
  offline: (c, s) => ic('<path d="M2.8 8.9a13.6 13.6 0 0 1 5.3-3.1"/><path d="M12 5.1c3.5 0 6.7 1.4 9.2 3.8"/><path d="M5.9 12.3a9 9 0 0 1 3.9-2.4"/><path d="M15.6 10.3a9 9 0 0 1 2.5 2"/><path d="M9.2 15.6a4.6 4.6 0 0 1 5.6 0"/><path d="M12 19.4h.01" stroke-width="2.6"/><path d="M3.5 3.5l17 17"/>', c, s, 1.7),
  undo: (c, s) => ic('<path d="M9 14 4 9l5-5"/><path d="M4 9h9.5a6.5 6.5 0 0 1 0 13H10"/>', c, s),
  restart: (c, s) => ic('<path d="M3.5 12a8.5 8.5 0 1 0 2.7-6.2L3.5 8.4"/><path d="M3.5 3.6v4.8h4.8"/>', c, s),
  star: (c, s, fill = 'none') => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="${fill}" stroke="${c}" stroke-width="1.6" stroke-linejoin="round" style="display:block;flex:none"><polygon points="12,2.2 14.8,8.8 22,9.5 16.6,14.2 18.2,21.2 12,17.5 5.8,21.2 7.4,14.2 2,9.5 9.2,8.8"/></svg>`,
};

// ---------------------------------------------------------------- frame / page / chrome (F05 D3 + F03 D2)
function frame(W, H) { const s = W / 358; const e = Math.max(0, H - 717 * s); return { W, H, s, e }; }
function page(W, H, body, extraHead = '', scroll = false) {
  return `<!doctype html><html><head><meta charset="utf-8"><style>${font}
*{box-sizing:border-box;margin:0;padding:0}html,body{width:${W}px;height:${H}px;overflow:hidden}
body{position:relative;font-family:'Manrope',sans-serif;color:${K.text};background:${BACKDROP}}
.abs{position:absolute}.sg{font-family:'SpaceGrotesk',sans-serif}
.cap{font-family:'Manrope';font-weight:600;letter-spacing:.2em;color:${K.muted};line-height:1.25;white-space:nowrap}
.glass{position:relative;background:linear-gradient(155deg,rgba(60,74,134,.50),rgba(22,30,64,.58));border:1px solid ${K.glassEdge};box-shadow:0 24px 60px rgba(2,4,16,.35),inset 0 1px 0 rgba(255,255,255,.07)}
.slate{position:relative;background:linear-gradient(155deg,rgba(46,64,84,.58),rgba(17,25,40,.66));border:1px solid ${K.glassEdge};box-shadow:0 24px 60px rgba(2,4,16,.35),inset 0 1px 0 rgba(255,255,255,.07)}
.num{font-family:'SpaceGrotesk';font-weight:500;line-height:1;font-variant-numeric:tabular-nums}
.em{color:${K.lime}}
.lime{background:linear-gradient(160deg,#E3FB7E,#CDEB4B);color:${K.limeInk};box-shadow:0 10px 26px rgba(208,239,88,.34),inset 0 1px 0 rgba(255,255,255,.45)}
.tile{position:absolute;display:flex;align-items:center;justify-content:center;font-family:'SpaceGrotesk';font-weight:500;line-height:1;color:${K.ink};
 background:linear-gradient(180deg,#FFFCF7,#F0E9DC);box-shadow:inset 0 1px 0 #fff,inset 0 -2px 0 rgba(120,100,70,.10),0 7px 16px rgba(2,4,16,.45),0 1px 0 rgba(0,0,0,.2)}
.skel{background:linear-gradient(90deg,rgba(255,255,255,.07),rgba(255,255,255,.12),rgba(255,255,255,.07));border-radius:8px}
</style>${extraHead}</head><body>${body}${fitScript(H)}</body></html>`;
}
// Every page reports its content column bottom + overflow in the tab title (read by fit-f07.sh with --dump-dom).
const fitScript = (H) => `<script>document.fonts.ready.then(function(){var c=document.getElementById('col');if(!c)return;var r=c.getBoundingClientRect();
document.title=JSON.stringify({colTop:+r.top.toFixed(1),colBottom:+r.bottom.toFixed(1),H:${H},spareAboveHomeBar:+(${H}-34-r.bottom).toFixed(1)});});<\/script>`;
const status = (F) => `<div class="abs" style="left:${25 * F.s}px;top:${15 * F.s}px;font:500 ${14.5 * F.s}px/1 Manrope;color:#fff;z-index:20">9:41</div>
<div class="abs" style="right:${25 * F.s}px;top:${17 * F.s}px;display:flex;gap:${5 * F.s}px;align-items:center;z-index:20"><svg width="${17 * F.s}" height="${11 * F.s}" viewBox="0 0 17 11" fill="#fff"><rect y="7" width="3" height="4" rx="1"/><rect x="4.7" y="4.5" width="3" height="6.5" rx="1"/><rect x="9.4" y="2" width="3" height="9" rx="1"/><rect x="14" width="3" height="11" rx="1"/></svg><svg width="${24 * F.s}" height="${11 * F.s}" viewBox="0 0 24 11" fill="none" stroke="#fff" stroke-width="1"><rect x=".5" y=".5" width="20" height="10" rx="3.2" opacity=".55"/><rect x="2" y="2" width="17" height="7" rx="1.8" fill="#fff" stroke="none"/></svg></div>
<div class="abs" style="left:${F.W / 2 - 47 * F.s}px;top:${10 * F.s}px;width:${94 * F.s}px;height:${28 * F.s}px;border-radius:${14 * F.s}px;background:#000;z-index:20"></div>`;
const homeBar = (F) => `<div class="abs" style="left:${F.W / 2 - 62 * F.s}px;bottom:${7 * F.s}px;width:${124 * F.s}px;height:${4.6 * F.s}px;border-radius:3px;background:rgba(255,255,255,.62);z-index:20"></div>`;
const wordmark = (F, cap = 1) => `<div class="abs sg" style="left:${25 * F.s}px;top:${58 * F.s}px;font-size:${25 * F.s * cap}px;font-weight:500;line-height:1;letter-spacing:-.01em;color:${K.text};white-space:nowrap">Loop<span style="color:${K.lime}">let</span></div>`;
function backButton(F, o = {}) {
  const s = F.s;
  return `<div class="abs" style="left:${24 * s}px;top:${54 * s}px;width:44px;height:44px;border-radius:${15 * s}px;background:rgba(255,255,255,.075);border:1px solid rgba(255,255,255,.07);display:flex;align-items:center;justify-content:center;z-index:12">${I.back(K.text, 20 * s)}${o.focus ? `<i style="position:absolute;inset:-1px;border-radius:${15 * s}px;box-shadow:inset 0 0 0 2px ${K.peri}"></i>` : ''}</div>`;
}
// Above the cap a column may scroll under a fixed band (F03 D2 `ScrollBand`): shown only when scrolled.
const scrollBand = (F) => `<div class="abs" style="left:0;top:0;width:${F.W}px;height:${54 * F.s + 58}px;background:linear-gradient(180deg,#0B1234 0%,#0B1234 78%,rgba(11,18,52,0) 100%);z-index:11"></div>`;
const toEnd = (H) => `<script>document.fonts.ready.then(function(){var c=document.getElementById('col');var b=c.getBoundingClientRect().bottom;var d=Math.max(0,b-(${H}-34));c.style.transform='translateY('+(-d)+'px)';});<\/script>`;
// LimePill / OutlinePill / TextLink (shipped components; press = scale .98, focus = 2 px periwinkle ring)
const limePill = (F, label, o = {}) => { const s = F.s, tx = o.tx ?? 1;
  return `<div style="margin-top:${(o.mt ?? 22) * s}px;position:relative;min-height:${63 * s}px;border-radius:${32 * s}px;display:flex;align-items:center;justify-content:space-between;gap:${12 * s}px;padding:${12 * s}px ${23 * s}px;background:linear-gradient(180deg,#E4FB80,#D5F252);${o.glow ? 'box-shadow:0 18px 50px rgba(208,239,88,.26);' : 'box-shadow:0 14px 32px rgba(2,4,16,.5),inset 0 1px 0 rgba(255,255,255,.4);'}color:${K.limeInk};font:500 ${16 * s * tx}px/1.2 Manrope;${o.disabled ? 'opacity:.45;' : ''}${o.pressed ? 'transform:scale(.98);' : ''}"><span>${label}</span>${o.noArrow ? '' : `<span style="display:flex;flex:none">${o.icon ?? I.right(K.limeInk, 20 * s)}</span>`}${o.focus ? `<i style="position:absolute;inset:-5px;border-radius:${36 * s}px;box-shadow:0 0 0 2px ${K.peri}"></i>` : ''}</div>`; };
const outlinePill = (F, label, o = {}) => { const s = F.s, tx = o.tx ?? 1;
  return `<div style="margin-top:${(o.mt ?? 22) * s}px;min-height:${Math.max(44, 52 * s)}px;border-radius:999px;border:1px solid ${K.outlineEdge};display:flex;align-items:center;justify-content:center;gap:${9 * s}px;padding:${10 * s}px ${20 * s}px;font:500 ${15.5 * s * tx}px/1.2 Manrope;color:${K.text};text-align:center">${o.icon ? `<span style="display:flex">${o.icon}</span>` : ''}<span>${label}</span></div>`; };
const textLink = (F, label, o = {}) => { const s = F.s, tx = o.tx ?? 1;
  return `<div style="margin-top:${(o.mt ?? 8) * s}px;min-height:44px;display:flex;align-items:center;justify-content:center;text-align:center;font:500 ${15.5 * s * tx}px/1.2 Manrope;color:${K.muted}">${label}</div>`; };
const caption = (F, text, o = {}) => `<div style="margin-top:${(o.mt ?? 17) * F.s}px;text-align:center;font:500 ${14 * F.s * (o.tx ?? 1)}px/1.3 Manrope;color:${K.muted}">${text}</div>`;

// ---------------------------------------------------------------- content (render fixtures)
const TODAY = { dom: 3, cap: '3 KASIM', long: '3 Kasım Salı', short: '3 Kasım' };
const NUM = 34;                                  // (2026-11-03 − 2026-10-01) + 1
const WD = ['ÇAR', 'PER', 'CUM', 'CMT', 'PAZ', 'PZT', 'BUGÜN'];  // Oct 28 (Çarşamba) … Nov 3 (today)
const DOM = [28, 29, 30, 31, 1, 2, 3];
// week: the last seven local dates ending today (DailyRepo.firstRun per date). done / missed / today-{available,done,offline}
const WEEK = {
  before: ['done', 'missed', 'done', 'done', 'done', 'done', 'available'],   // effective streak 4 (Oct 30 → Nov 2)
  after: ['done', 'missed', 'done', 'done', 'done', 'done', 'doneToday'],   // first run → 5
  offline: ['done', 'missed', 'done', 'done', 'done', 'done', 'offline'],
  missedBefore: ['done', 'done', 'done', 'missed', 'missed', 'missed', 'available'], // last = Oct 30 → effective 0
  missedAfter: ['done', 'done', 'done', 'missed', 'missed', 'missed', 'doneToday'], // → 1, best 12 kept
};
const WORD = 'BALIK';
const L4 = { grid: ['BLÇIZ', 'MIENO', 'PÜLNG', 'BDERİ', 'ŞALKD'], target: 'BALIK', opt: 4 };
const R = {
  first: { kind: 'first', you: 5, opt: 4, dur: '1:42', stars: 2, streak: 5, prev: 4, best: 12, week: WEEK.after },
  replay: { kind: 'replay', you: 4, opt: 4, dur: '1:18', stars: 3, streak: 5, best: 12, week: WEEK.after, official: { you: 5, dur: '1:42', stars: 2 } },
  reset: { kind: 'first', you: 4, opt: 4, dur: '0:58', stars: 3, streak: 1, best: 12, week: WEEK.missedAfter },
};
const OFFICIAL = { you: 5, opt: 4, dur: '1:42', stars: 2 };

// ---------------------------------------------------------------- Home (F05 D3 direction A, unchanged) + the Daily entry
function nodeHtml(n, st, cx, cy, s, cap) {
  const big = st === 'current' || st === 'finish', sz = (big ? 58 : 38) * s, r = sz * 0.34;
  const L = cx - sz / 2, T = cy - sz / 2, fs = (big ? 17 : 14) * s * cap;
  const base = `position:absolute;left:${L}px;top:${T}px;width:${sz}px;height:${sz}px;border-radius:${r}px;display:flex;align-items:center;justify-content:center;font:500 ${fs}px/1 SpaceGrotesk;`;
  if (st === 'done') return `<div style="${base}background:linear-gradient(160deg,#E3FB7E,#CDEB4B);color:${K.limeInk};box-shadow:0 8px 20px rgba(208,239,88,.28)">${n}</div>`;
  if (st === 'locked') return `<div style="${base}background:rgba(255,255,255,.035);border:1.5px dashed rgba(174,180,202,.62);color:${K.muted}">${n}</div>`;
  const halo = `<div style="position:absolute;left:${cx - 38 * s}px;top:${cy - 38 * s}px;width:${76 * s}px;height:${76 * s}px;border-radius:${26 * s}px;`;
  return `${halo}background:rgba(168,180,249,.16);border:1px solid rgba(168,180,249,.25)"></div><div style="${base}background:linear-gradient(160deg,${K.nodeCurTop},${K.periLo});color:${K.limeInk};box-shadow:0 12px 30px rgba(135,146,240,.45)">${n}</div>`;
}
const segPath = (a, b) => { const dx = (b.x - a.x) * 0.45; return `M${a.x} ${a.y} C ${a.x + dx} ${a.y}, ${b.x - dx} ${b.y}, ${b.x} ${b.y}`; };
function journeyTrack(s, cardW, cap) { // window 1–5, level 5 current (4 / 30, in progress) — D3-03 parity
  const states = ['done', 'done', 'done', 'done', 'current'];
  const xs = [0, 50, 100, 150, 214], off = 154 - 107;
  const pts = xs.map((x) => { const X = x + off, p = Math.max(0, Math.min(1, (X - 40) / 230)); return { x: X * s, y: (236 - 62 * Math.pow(p, 1.25) - 134) * s }; });
  let svg = `<defs><linearGradient id="gcur" x1="0" x2="1"><stop offset="0" stop-color="${K.limeMid}"/><stop offset="1" stop-color="${K.peri}"/></linearGradient></defs>`;
  for (let i = 1; i < 5; i++) svg += states[i] === 'current' ? `<path d="${segPath(pts[i - 1], pts[i])}" fill="none" stroke="url(#gcur)" stroke-width="${3.2 * s}" stroke-linecap="round" opacity=".9"/>` : `<path d="${segPath(pts[i - 1], pts[i])}" fill="none" stroke="${K.limeMid}" stroke-width="${3.2 * s}" stroke-linecap="round" opacity=".9"/>`;
  const last = pts[4];
  svg += `<path d="M${last.x + 30 * s} ${last.y} L${cardW - 6 * s} ${last.y - 8 * s}" fill="none" stroke="rgba(174,180,202,.3)" stroke-width="${2 * s}" stroke-dasharray="${2 * s} ${5 * s}" stroke-linecap="round"/>`;
  return `<svg class="abs" style="left:0;top:0;overflow:visible" width="${cardW}" height="${166 * s}">${svg}</svg>${states.map((st, i) => nodeHtml(i + 1, st, pts[i].x, pts[i].y, s, cap)).join('')}`;
}
const swirl = (s, cardW) => `<svg class="abs" style="left:0;bottom:0" width="${cardW}" height="${300 * s}" viewBox="0 0 308 300" preserveAspectRatio="none"><g fill="none"><ellipse cx="60" cy="210" rx="170" ry="64" stroke="rgba(190,205,170,.14)" stroke-width="20" transform="rotate(-9 60 210)"/><ellipse cx="240" cy="230" rx="150" ry="80" stroke="rgba(120,132,225,.26)" stroke-width="24" transform="rotate(-14 240 230)"/></g></svg>`;
// o: tx, entry: html-producing fn (F, cap, tx) or null (hidden), entrance (ms freeze or null), rm, scroll
function homeScreen(W, H, o = {}) {
  const F = frame(W, H), s = F.s, tx = o.tx ?? 1, cap = Math.min(tx, 1.3), cardW = 308 * s;
  const cardTop = 115 * s + F.e * 0.1;
  const ent = (d) => o.entrance == null ? '' : `class="ent" style="--d:${d}ms"`;
  const card = `<div ${ent(0)}><div class="glass" style="width:${cardW}px;margin-left:${0.5 * s}px;border-radius:${30 * s}px;overflow:hidden;padding:${31 * s}px ${24.5 * s}px 0;min-height:${300 * s}px">${swirl(s, cardW)}
    <div style="position:relative"><div class="cap" style="font-size:${11 * s * cap}px">YOLCULUK · 4 / 30</div>
    <div class="sg" style="margin-top:${15 * s}px;font-size:${28 * s * cap}px;font-weight:500;line-height:1.16;letter-spacing:-.005em">Sıradaki<br><span class="em">döngüyü</span> çöz.</div></div>
    <div style="position:relative;margin:${12 * s}px ${-24.5 * s}px 0;height:${166 * s}px">${journeyTrack(s, cardW, cap)}</div></div></div>`;
  const cta = `<div ${ent(60)}>${limePill(F, 'Devam et', { tx, glow: true, pressed: o.pressed })}</div><div ${ent(120)}>${caption(F, 'Seviye 5 · sürüyor', { tx })}</div>`;
  const entry = o.entry ? `<div ${ent(180)} id="entry">${o.entry(F, cap, tx)}</div>` : '';
  const head = o.entrance == null ? '' : `<style>.ent{opacity:0;transform:translateY(${10 * s}px);animation:in 240ms cubic-bezier(.22,.61,.36,1) forwards;animation-delay:var(--d)}@keyframes in{to{opacity:1;transform:none}}${o.rm ? '.ent{animation:none;opacity:1;transform:none}' : ''}</style>
<script>addEventListener('load',()=>{document.getAnimations().forEach(a=>{a.pause();a.currentTime=${o.entrance};});});<\/script>`;
  const col = `<div class="abs" id="col" style="left:${24 * s}px;top:${cardTop}px;width:${309 * s}px">${card}${cta}${entry}</div>`;
  return page(W, H, `${o.scroll === 'END' ? `<div id="scr">${wordmark(F, cap)}${col}</div>${scrollBand(F)}` : `${wordmark(F, cap)}${col}`}${status(F)}${homeBar(F)}${o.scroll === 'END' ? toEnd(H) : ''}`, head);
}

// ---------------------------------------------------------------- the week track (direction A) — last seven days, today at the rising end
// Day node states: done (lime 28·s, day numeral), missed (dashed muted outline — the F05 locked look), today: available
// (periwinkle 44·s + halo), doneToday (lime 44·s + lime halo + check), offline (dashed periwinkle outline + offline glyph).
// Segments: into done → solid lime; into missed or out of missed → dashed muted; into today-available from a done day →
// lime→periwinkle; into doneToday → solid lime; into offline → dashed periwinkle.
function weekTrack(s, W, week, o = {}) {
  const k = o.k ?? 1, small = 28 * k, big = 44 * k, halo = 58 * k, gapS = 35 * k, gapB = 47 * k;
  const xs = [0]; for (let i = 1; i < 7; i++) xs.push(xs[i - 1] + (i === 6 ? gapB : gapS));
  const span = xs[6] + halo / 2 + small / 2, x0 = (W / s - span) / 2 + small / 2;
  const base = (o.baseY ?? 40) * k, rise = 12 * k;
  const pts = xs.map((x, i) => ({ x: (x0 + x) * s, y: (base - rise * Math.pow(i / 6, 1.4)) * s }));
  let svg = `<defs><linearGradient id="wg${o.id ?? ''}" x1="0" x2="1"><stop offset="0" stop-color="${K.limeMid}"/><stop offset="1" stop-color="${K.peri}"/></linearGradient></defs>`;
  const dashed = (d, c = 'rgba(174,180,202,.42)') => `<path d="${d}" fill="none" stroke="${c}" stroke-width="${2 * s * k}" stroke-dasharray="${2 * s * k} ${5 * s * k}" stroke-linecap="round"/>`;
  // segments run edge to edge (never through a node), so a translucent missed node never shows a line inside it
  const half = (i) => ((i === 6 ? big : small) / 2) * s;
  const trim = (i, j) => { const A = pts[i], B = pts[j], dx = B.x - A.x, dy = B.y - A.y, L = Math.hypot(dx, dy), ux = dx / L, uy = dy / L;
    return segPath({ x: A.x + ux * half(i), y: A.y + uy * half(i) }, { x: B.x - ux * half(j), y: B.y - uy * half(j) }); };
  for (let i = 1; i < 7; i++) {
    const a = week[i - 1], b = week[i], d = trim(i - 1, i);
    if (a === 'missed' || b === 'missed') svg += dashed(d);
    else if (b === 'done' || b === 'doneToday') svg += `<path d="${d}" fill="none" stroke="${K.limeMid}" stroke-width="${3 * s * k}" stroke-linecap="round" opacity=".9"/>`;
    else if (b === 'available') svg += `<path d="${d}" fill="none" stroke="url(#wg${o.id ?? ''})" stroke-width="${3 * s * k}" stroke-linecap="round" opacity=".9"/>`;
    else svg += dashed(d, 'rgba(168,180,249,.55)');
  }
  let nodes = '';
  week.forEach((st, i) => {
    const today = i === 6, sz = (today ? big : small) * s, r = sz * 0.34, cx = pts[i].x, cy = pts[i].y, L = cx - sz / 2, T = cy - sz / 2;
    const fs = (today ? 15 : 12) * s * k * (o.cap ?? 1);
    const b = `position:absolute;left:${L}px;top:${T}px;width:${sz}px;height:${sz}px;border-radius:${r}px;display:flex;align-items:center;justify-content:center;font:500 ${fs}px/1 SpaceGrotesk;`;
    const hl = (bg, edge) => `<div style="position:absolute;left:${cx - halo * s / 2}px;top:${cy - halo * s / 2}px;width:${halo * s}px;height:${halo * s}px;border-radius:${20 * s * k}px;background:${bg};border:1px solid ${edge}"></div>`;
    if (st === 'done') nodes += `<div style="${b}background:linear-gradient(160deg,#E3FB7E,#CDEB4B);color:${K.limeInk};box-shadow:0 6px 16px rgba(208,239,88,.24)">${o.numerals === false ? '' : DOM[i]}</div>`;
    else if (st === 'missed') nodes += `<div style="${b}background:rgba(255,255,255,.035);border:1.5px dashed rgba(174,180,202,.62);color:${K.muted}">${o.numerals === false ? '' : DOM[i]}</div>`;
    else if (st === 'available') nodes += `${hl('rgba(168,180,249,.16)', 'rgba(168,180,249,.25)')}<div class="wt-today" style="${b}background:linear-gradient(160deg,${K.nodeCurTop},${K.periLo});color:${K.limeInk};box-shadow:0 10px 26px rgba(135,146,240,.45)">${DOM[i]}</div>`;
    else if (st === 'doneToday') nodes += `${hl('rgba(221,250,107,.11)', 'rgba(221,250,107,.30)')}<div class="wt-today" style="${b}background:linear-gradient(160deg,#E3FB7E,#CDEB4B);color:${K.limeInk};box-shadow:0 10px 26px rgba(208,239,88,.30)">${I.check(K.limeInk, sz * 0.5)}</div>`;
    else if (st === 'offline') nodes += `<div style="${b}background:rgba(168,180,249,.06);border:1.5px dashed rgba(168,180,249,.75)">${I.offline(K.peri, sz * 0.5)}</div>`;
    else if (st === 'skeleton') nodes += `<div class="skel" style="${b}border-radius:${r}px"></div>`;
  });
  let labels = '';
  if (o.labels) WD.forEach((w, i) => { labels += `<div class="cap" style="position:absolute;left:${pts[i].x - 30 * s}px;width:${60 * s}px;top:${pts[i].y + ((i === 6 ? big : small) / 2 + (i === 6 ? 12 : 9) * k) * s}px;text-align:center;font-size:${9.5 * s * (o.cap ?? 1)}px;letter-spacing:.12em;${i === 6 ? `color:${K.text}` : ''}">${w}</div>`; });
  return `<svg class="abs" style="left:0;top:0;overflow:visible" width="${W}" height="10">${svg}</svg>${nodes}${labels}`;
}
const weekState = (w) => w[6];

// ---------------------------------------------------------------- Home Daily entry — direction A: the week card
// D: { state: 'available'|'done'|'offline'|'loading', number|null, streak, week }
function entryA(D) {
  return (F, cap, tx) => {
    const s = F.s, W = 309 * s;
    const stateLine = { available: 'Bugünün döngüsü hazır', done: 'Bugün tamam · 5 hamle', offline: 'Bağlantı gerekli', loading: 'Hazırlanıyor' }[D.state];
    const label = D.number ? `GÜNLÜK · #${D.number}` : 'GÜNLÜK';
    const flame = D.state === 'done' ? K.limeMid : K.muted;
    return `<div class="slate" style="margin-top:${24 * s}px;width:${W}px;border-radius:${24 * s}px;padding:${13 * s}px ${16 * s}px ${12 * s}px;overflow:hidden">
      <div style="display:flex;justify-content:space-between;align-items:center;gap:${10 * s}px">
        <span class="cap" style="font-size:${11 * s * cap}px">${label}</span>
        <span style="display:flex;align-items:center;gap:${5 * s}px">${I.flame(flame, 16 * s)}<span class="num" style="font-size:${17 * s * cap}px">${D.streak}</span><span class="cap" style="font-size:${10 * s * cap}px;letter-spacing:.14em">SERİ</span></span>
      </div>
      <div style="position:relative;height:${42 * s}px;margin:${2 * s}px ${-16 * s}px 0">${weekTrack(s, W, D.week, { k: 0.62, baseY: 36, id: 'e', numerals: false, cap })}</div>
      <div style="display:flex;justify-content:space-between;align-items:center;gap:${10 * s}px;margin-top:${1 * s}px">
        <span style="font:600 ${14.5 * s * tx}px/1.3 Manrope;color:${D.state === 'offline' || D.state === 'loading' ? K.muted : K.text}">${stateLine}</span>
        <span style="display:flex">${I.right(K.text, 18 * s)}</span>
      </div></div>`;
  };
}
// ---------------------------------------------------------------- Home Daily entry — direction B: the ticket capsule
function entryB(D) {
  return (F, cap, tx) => {
    const s = F.s;
    const st = { available: ['Oyna', I.right(K.text, 17 * s)], done: ['Tamam', I.check(K.limeMid, 17 * s)], offline: ['Bağlantı yok', I.offline(K.muted, 17 * s)], loading: ['Hazırlanıyor', ''] }[D.state];
    return `<div style="margin-top:${24 * s}px;min-height:${58 * s}px;border-radius:999px;border:1px solid ${K.outlineEdge};background:rgba(255,255,255,.035);display:flex;align-items:stretch;overflow:hidden">
      <div style="display:flex;align-items:center;gap:${6 * s}px;padding:${8 * s}px ${14 * s}px ${8 * s}px ${20 * s}px;flex:none">${I.flame(D.state === 'done' ? K.limeMid : K.text, 18 * s)}<span class="num" style="font-size:${19 * s * cap}px">${D.streak}</span><span class="cap" style="font-size:${10 * s * cap}px;letter-spacing:.14em">SERİ</span></div>
      <div style="width:0;border-left:1.5px dashed rgba(174,180,202,.45);margin:${9 * s}px 0"></div>
      <div style="flex:1;display:flex;align-items:center;justify-content:space-between;gap:${10 * s}px;padding:${8 * s}px ${20 * s}px ${8 * s}px ${14 * s}px">
        <span style="font:600 ${15 * s * tx}px/1.25 Manrope">Günlük${D.number ? ` <span class="num" style="font-size:1.08em">#${D.number}</span>` : ''}</span>
        <span style="display:flex;align-items:center;gap:${6 * s}px;font:500 ${14.5 * s * tx}px/1.25 Manrope;color:${D.state === 'done' ? K.text : K.muted};text-align:right">${st[0]}${st[1]}</span>
      </div></div>`;
  };
}

// ---------------------------------------------------------------- stat cards (StatCard / StatCell; NEW: icon cell, stars cell)
const cell = (s, cap, v, l, o = {}) => `<div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:${9 * s}px;min-width:0"><span style="display:flex;align-items:center;gap:${5 * s}px">${o.icon ?? ''}<span class="num" style="font-size:${(o.fs ?? 24) * s * cap}px">${v}</span></span><span class="cap" style="font-size:${11 * s * cap}px;letter-spacing:.14em;line-height:1">${l}</span></div>`;
const starsCell = (s, cap, n, sz = 15) => `<div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:${9 * s}px"><span style="display:flex;gap:${4 * s}px;height:${24 * s * cap}px;align-items:center">${[1, 2, 3].map((i) => I.star(i <= n ? K.limeMid : 'rgba(244,246,255,.55)', sz * s * cap, i <= n ? K.limeMid : 'none')).join('')}</span><span class="cap" style="font-size:${11 * s * cap}px;letter-spacing:.14em;line-height:1">YILDIZ</span></div>`;
const sep = (s) => `<span style="width:1px;align-self:stretch;margin:${14 * s}px 0;background:rgba(255,255,255,.10)"></span>`;
const statCard = (s, cap, cells, o = {}) => `<div class="slate" style="margin-top:${(o.mt ?? 16) * s}px;min-height:${74 * s}px;border-radius:${26 * s}px;display:flex;align-items:center;padding:${12 * s}px ${6 * s}px">${cells.join(sep(s))}</div>`;
const streakCells = (s, cap, streak, best, lit) => [cell(s, cap, streak, 'SERİ', { icon: I.flame(lit ? K.limeMid : K.text, 19 * s * cap) }), cell(s, cap, best, 'EN İYİ')];

// ---------------------------------------------------------------- the Daily screen (/daily) — direction A
// state: loading | ready | doneToday | needsConnection | unavailable
function dailyA(W, H, state, o = {}) {
  const F = frame(W, H), s = F.s, tx = o.tx ?? 1, cap = Math.min(tx, 1.3), cardW = 308 * s;
  const week = o.week ?? (state === 'doneToday' ? WEEK.after : state === 'needsConnection' ? WEEK.offline : WEEK.before);
  const streak = o.streak ?? (state === 'doneToday' ? 5 : 4);
  const numbered = state === 'ready' || state === 'doneToday';
  const head = {
    loading: '', ready: `Bugünün<br><span class="em">döngüsü</span> hazır.`, doneToday: `Bugünün döngüsü<br><span class="em">tamam.</span>`,
    needsConnection: `Bugünün döngüsü<br>henüz gelmedi.`, unavailable: `Günlük döngü<br>bugün dinleniyor.`,
  }[state];
  const body = {
    needsConnection: 'İnternete bağlanınca hazır olur. Yolculuk bu arada açık.',
    unavailable: 'Yolculuk her zaman açık; günlük döngü yakında geri gelir.',
  }[state];
  const headHtml = state === 'loading'
    ? `<div class="skel" style="margin-top:${17 * s}px;width:${150 * s}px;height:${26 * s}px"></div><div class="skel" style="margin-top:${9 * s}px;width:${200 * s}px;height:${26 * s}px"></div>`
    : `<div class="sg" style="margin-top:${15 * s}px;font-size:${28 * s * cap}px;font-weight:500;line-height:1.16;letter-spacing:-.005em">${head}</div>`;
  const bodyHtml = body ? `<div style="margin-top:${12 * s}px;font:500 ${14.5 * s * tx}px/1.4 Manrope;color:${K.muted}">${body}</div>` : '';
  const wk = state === 'unavailable' ? '' : `<div style="position:relative;margin:${16 * s}px ${-24.5 * s}px 0;height:${86 * s}px">${weekTrack(s, cardW, state === 'loading' ? ['skeleton', 'skeleton', 'skeleton', 'skeleton', 'skeleton', 'skeleton', 'skeleton'] : week, { labels: state !== 'loading', id: 'd', cap, baseY: 40 })}</div>`;
  const card = `<div class="glass" style="width:${cardW}px;margin-left:${0.5 * s}px;border-radius:${30 * s}px;overflow:hidden;padding:${29 * s}px ${24.5 * s}px ${state === 'unavailable' ? 30 * s : 10 * s}px">${swirl(s, cardW)}
    <div style="position:relative"><div style="display:flex;justify-content:space-between;gap:${10 * s}px"><span class="cap" style="font-size:${11 * s * cap}px">${numbered ? `GÜNLÜK · #${NUM}` : 'GÜNLÜK'}</span><span class="cap" style="font-size:${11 * s * cap}px">${TODAY.cap}</span></div>${headHtml}${bodyHtml}</div>${wk}</div>`;
  let below = '';
  if (state === 'ready') below = `${statCard(s, cap, streakCells(s, cap, streak, 12, false))}${limePill(F, 'Bugünü oyna', { tx, pressed: o.pressed, focus: o.focus })}${caption(F, 'Sınırsız hamle · 3 geri alma', { tx })}`;
  if (state === 'loading') below = `${statCard(s, cap, streakCells(s, cap, streak, 12, false))}${limePill(F, 'Hazırlanıyor', { tx, disabled: true, noArrow: true })}`;
  if (state === 'doneToday') below = `${statCard(s, cap, [cell(s, cap, OFFICIAL.you, 'HAMLE'), cell(s, cap, OFFICIAL.dur, 'SÜRE'), starsCell(s, cap, OFFICIAL.stars)])}${statCard(s, cap, streakCells(s, cap, 5, 12, true), { mt: 10 })}${outlinePill(F, 'Tekrar oyna', { tx, icon: I.restart(K.text, 18 * s) })}${caption(F, 'Yeni döngü gece yarısı.', { tx, mt: 14 })}`;
  if (state === 'needsConnection') below = `${statCard(s, cap, streakCells(s, cap, streak, 12, false))}${limePill(F, 'Tekrar dene', { tx, noArrow: true })}${textLink(F, 'Yolculuğa dön', { tx })}`;
  if (state === 'unavailable') below = `${limePill(F, 'Yolculuğa dön', { tx })}`;
  const col = `<div class="abs" id="col" style="left:${24 * s}px;top:${115 * s + F.e * 0.1}px;width:${309 * s}px;padding-bottom:${24 * s}px">${card}${below}</div>`;
  return page(W, H, `${o.scroll === 'END' ? scrollBand(F) : ''}${status(F)}${backButton(F, { focus: o.focusBack })}${col}${homeBar(F)}${o.scroll === 'END' ? toEnd(H) : ''}`);
}

// ---------------------------------------------------------------- the Daily screen — direction B: the ticket
function dailyB(W, H, state, o = {}) {
  const F = frame(W, H), s = F.s, tx = o.tx ?? 1, cap = Math.min(tx, 1.3), cardW = 309 * s;
  const streak = state === 'doneToday' ? 5 : 4;
  const notch = (side) => `<i style="position:absolute;${side}:${-12 * s}px;top:${-12 * s}px;width:${24 * s}px;height:${24 * s}px;border-radius:50%;background:#080E2A;border:1px solid ${K.glassEdge}"></i>`;
  const perf = `<div style="position:relative;height:0;margin:0 ${-1}px;border-top:1.5px dashed rgba(174,180,202,.40)">${notch('left')}${notch('right')}</div>`;
  let hero;
  if (state === 'needsConnection' || state === 'unavailable' || state === 'loading') {
    const t = { needsConnection: ['Bugünün bileti<br>henüz gelmedi.', 'İnternete bağlanınca hazır olur. Yolculuk bu arada açık.'], unavailable: ['Günlük döngü<br>bugün dinleniyor.', 'Yolculuk her zaman açık.'], loading: ['', ''] }[state];
    hero = state === 'loading'
      ? `<div class="skel" style="margin-top:${22 * s}px;width:${140 * s}px;height:${84 * s}px;border-radius:${16 * s}px"></div><div class="skel" style="margin-top:${14 * s}px;width:${190 * s}px;height:${16 * s}px"></div>`
      : `${state === 'needsConnection' ? `<div style="margin-top:${20 * s}px;display:flex">${I.offline(K.peri, 54 * s)}</div>` : ''}<div class="sg" style="margin-top:${16 * s}px;font-size:${28 * s * cap}px;font-weight:500;line-height:1.16">${t[0]}</div><div style="margin-top:${12 * s}px;font:500 ${14.5 * s * tx}px/1.4 Manrope;color:${K.muted}">${t[1]}</div>`;
  } else {
    hero = `<div style="position:relative"><div class="sg" style="margin-top:${14 * s}px;font-size:${104 * s * cap}px;font-weight:500;line-height:.95;letter-spacing:-.04em"><span class="em">#</span>${NUM}</div>
      ${state === 'doneToday' ? `<div style="position:absolute;right:${-4 * s}px;top:${30 * s}px;transform:rotate(-8deg);display:flex;align-items:center;gap:${6 * s}px;padding:${9 * s}px ${14 * s}px;border:2px solid ${K.limeMid};border-radius:${14 * s}px;color:${K.limeMid};background:rgba(11,16,32,.35)">${I.check(K.limeMid, 18 * s)}<span class="cap" style="font-size:${12 * s * cap}px;color:${K.limeMid};letter-spacing:.16em">BUGÜN TAMAM</span></div>` : ''}
      <div style="margin-top:${12 * s}px;font:500 ${14.5 * s * tx}px/1.4 Manrope;color:${K.muted}">${TODAY.long.split(' ')[2]} · herkes aynı bulmacayı çözer</div></div>`;
  }
  const stub = state === 'unavailable' ? '' : state === 'doneToday'
    ? `${perf}<div style="display:flex;align-items:center;padding:${16 * s}px ${6 * s}px ${16 * s}px">${[cell(s, cap, OFFICIAL.you, 'HAMLE'), cell(s, cap, OFFICIAL.dur, 'SÜRE'), starsCell(s, cap, OFFICIAL.stars)].join(sep(s))}</div>`
    : `${perf}<div style="display:flex;align-items:center;padding:${16 * s}px ${6 * s}px ${16 * s}px">${streakCells(s, cap, streak, 12, false).join(sep(s))}</div>`;
  const card = `<div class="glass" style="width:${cardW}px;border-radius:${30 * s}px;overflow:visible">
    <div style="padding:${27 * s}px ${24.5 * s}px ${24 * s}px"><div style="display:flex;justify-content:space-between;gap:${10 * s}px"><span class="cap" style="font-size:${11 * s * cap}px">GÜNLÜK DÖNGÜ</span><span class="cap" style="font-size:${11 * s * cap}px">${TODAY.cap}</span></div>${hero}</div>${stub}</div>`;
  let below = '';
  if (state === 'ready') below = `${limePill(F, 'Bugünü oyna', { tx, mt: 24 })}${caption(F, 'Sınırsız hamle · 3 geri alma', { tx })}`;
  if (state === 'loading') below = `${limePill(F, 'Hazırlanıyor', { tx, disabled: true, noArrow: true, mt: 24 })}`;
  if (state === 'doneToday') below = `<div style="margin-top:${16 * s}px;display:flex;justify-content:center;align-items:center;gap:${7 * s}px;font:500 ${14.5 * s * tx}px/1.3 Manrope;color:${K.text}">${I.flame(K.limeMid, 18 * s)}<span>5 günlük seri · en iyi 12</span></div>${outlinePill(F, 'Tekrar oyna', { tx, icon: I.restart(K.text, 18 * s), mt: 18 })}${caption(F, 'Yeni bilet gece yarısı.', { tx, mt: 14 })}`;
  if (state === 'needsConnection') below = `${limePill(F, 'Tekrar dene', { tx, noArrow: true, mt: 24 })}${textLink(F, 'Yolculuğa dön', { tx })}`;
  if (state === 'unavailable') below = `${limePill(F, 'Yolculuğa dön', { tx, mt: 24 })}`;
  const col = `<div class="abs" id="col" style="left:${24.5 * s}px;top:${115 * s + F.e * 0.1}px;width:${309 * s}px">${card}${below}</div>`;
  return page(W, H, `${status(F)}${backButton(F)}${col}${homeBar(F)}`);
}

// ---------------------------------------------------------------- the daily Play header (D1 Play, header variant) — shared
function play(W, H, o = {}) {
  const F = frame(W, H), s = F.s, e1 = F.e * 0.3, e2 = F.e * 0.7, tx = o.tx ?? 1, cap = Math.min(tx, 1.3);
  const cw = 308.5 * s, x = (W - cw) / 2, pad = 11 * s, t = 52 * s, gap = 6.5 * s, top = 261.5 * s + e1;
  let board = `<div class="abs" style="left:${x}px;top:${top}px;width:${cw}px;height:${307.5 * s}px;border-radius:${34 * s}px;background:linear-gradient(180deg,rgba(22,30,64,.86),rgba(9,14,36,.88));border:1px solid rgba(255,255,255,.09);box-shadow:0 26px 60px rgba(2,4,16,.4)"></div><div class="abs" style="left:${x + cw / 2 - 72 * s}px;top:${top}px;width:${144 * s}px;height:${2 * s}px;background:linear-gradient(90deg,transparent,#8792F0,transparent)"></div>`;
  for (let r = 0; r < 5; r++) for (let c = 0; c < 5; c++) board += `<div class="tile" style="left:${x + pad + c * (t + gap)}px;top:${top + pad + r * (t + gap)}px;width:${t}px;height:${t}px;border-radius:${t * 0.33}px;font-size:${t * 0.38 * cap}px">${L4.grid[r][c]}</div>`;
  const rw = 36 * s, rg = 8 * s, rx = (W - (5 * rw + 4 * rg)) / 2, ry = 197 * s + e1;
  const rail = `<div class="cap abs" style="left:0;width:${W}px;top:${172 * s + e1}px;text-align:center;font-size:${11.5 * s * cap}px;line-height:1">HEDEF DÖNGÜ</div>` + [...L4.target].map((ch, i) => `<div class="tile" style="left:${rx + i * (rw + rg)}px;top:${ry}px;width:${rw}px;height:${42 * s}px;border-radius:${14 * s}px;font-size:${16.5 * s * cap}px;color:${K.text};background:linear-gradient(180deg,#2B2B58,#242349);box-shadow:inset 0 0 0 1px rgba(150,160,235,.32),0 6px 14px rgba(2,4,16,.35)">${ch}</div>`).join('');
  // header: back chevron + the day label (caps, 1.3× cap) and the date under it (Manrope 500 12·s, muted, 1.3× cap)
  const header = `<div class="abs" style="left:${25 * s}px;top:${87 * s}px;display:flex;align-items:center;gap:${6 * s}px">${I.back(K.muted, 20 * s)}<div><div class="cap" style="font-size:${11.5 * s * cap}px">GÜNLÜK · #${NUM}</div><div style="margin-top:${5 * s}px;font:500 ${12.5 * s * cap}px/1.2 Manrope;color:${K.muted}">${TODAY.long}</div></div></div>
  <div class="abs" style="left:${273.5 * s}px;top:${75 * s}px;width:${60 * s}px;min-height:${63 * s}px;padding:${6 * s}px 0;border-radius:${22 * s}px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:${7 * s}px;background:linear-gradient(160deg,rgba(120,132,196,.34),rgba(70,80,140,.30));border:1px solid rgba(255,255,255,.09)"><span class="num" style="font-size:${22 * s * cap}px">${o.moves ?? 0}</span><span class="cap" style="font-size:${11 * s * cap}px;letter-spacing:.14em;line-height:1">HAMLE</span></div>`;
  const y = 592.5 * s + e1 + e2, dot = (on) => `<i style="width:${5.5 * s}px;height:${5.5 * s}px;border-radius:50%;background:${on ? K.limeMid : 'rgba(208,239,88,.25)'};display:block"></i>`;
  const hud = `<div class="abs" style="left:${29 * s}px;top:${y}px;width:${98.5 * s}px;height:${50 * s}px;border-radius:${22 * s}px;display:flex;align-items:center;justify-content:center;gap:${10 * s}px;background:rgba(255,255,255,.075);border:1px solid rgba(255,255,255,.07)">${I.undo(K.text, 21 * s)}<span style="display:flex;gap:${5 * s}px">${[0, 1, 2].map((i) => dot(i < 3)).join('')}</span></div>
  <div class="abs" style="left:${289 * s}px;top:${y + 3 * s}px;width:44px;height:44px;border-radius:${17 * s}px;display:flex;align-items:center;justify-content:center;background:rgba(255,255,255,.075);border:1px solid rgba(255,255,255,.07)">${I.restart(K.text, 20 * s)}</div>`;
  return page(W, H, `${status(F)}${header}${rail}${board}${hud}${homeBar(F)}`);
}

// ---------------------------------------------------------------- the daily result (F03 §20 full-screen result, daily variant)
// Column (358 ref, flow): chip row 42·s (HARİKA iff Perfect on a first run; RESMÎ SONUÇ on any other first run; TEKRAR on
// a replay) → headline (2 lines) → subtitle (official / replay sentence, free text) → answer tiles → stars → stats
// (HAMLE · OPTİMAL · SÜRE of THIS run) → [replay: the official row] → streak (A: week card; B: ticket stub) → primary
// "Tamam" → link "Tekrar oyna". The F13 Share place is a fit budget between the pill and the link (see ui-design §6).
function chip(s, cap, kind) {
  if (kind === 'harika') return `<div style="display:flex;align-items:center;gap:${7 * s}px;height:${42 * s}px;padding:0 ${16 * s}px;border-radius:${21 * s}px;background:linear-gradient(160deg,rgba(150,180,50,.26),rgba(90,120,30,.24));border:1px solid rgba(208,239,88,.42)">${I.sparkle(K.limeMid, 18 * s)}<span class="cap" style="font-size:${11 * s * cap}px;color:${K.limeMid};letter-spacing:.14em;line-height:1">HARİKA</span></div>`;
  if (kind === 'official') return `<div style="display:flex;align-items:center;gap:${7 * s}px;height:${42 * s}px;padding:0 ${16 * s}px;border-radius:${21 * s}px;background:rgba(168,180,249,.10);border:1px solid rgba(168,180,249,.45)">${I.check(K.peri, 16 * s)}<span class="cap" style="font-size:${11 * s * cap}px;color:${K.text};letter-spacing:.14em;line-height:1">RESMÎ SONUÇ</span></div>`;
  return `<div style="display:flex;align-items:center;gap:${7 * s}px;height:${42 * s}px;padding:0 ${16 * s}px;border-radius:${21 * s}px;border:1px solid ${K.outlineEdge}">${I.restart(K.muted, 16 * s)}<span class="cap" style="font-size:${11 * s * cap}px;letter-spacing:.14em;line-height:1">TEKRAR</span></div>`;
}
function resultScreen(dir, W, H, V, o = {}) {
  const F = frame(W, H), s = F.s, e = F.e, tx = o.tx ?? 1, cap = Math.min(tx, 1.3);
  const perfect = V.you === V.opt;
  const chipKind = V.kind === 'replay' ? 'replay' : perfect ? 'harika' : 'official';
  const head = V.kind === 'replay' ? 'Tekrar tamam.' : `Günlük tamam.`;
  const sub = V.kind === 'replay' ? `Optimal ${V.opt} hamle. Resmî sonucun değişmedi.` : `Optimal ${V.opt} hamle. Resmî sonucun kaydedildi.`;
  const tw = 52.5 * s, th = 59 * s;
  const tiles = `<div id="slot" style="margin-top:${(24 + 0.1 * e / s) * s}px;height:${th}px;display:flex;justify-content:center;gap:${6.5 * s}px">${[...WORD].map((ch) => `<div class="lime" style="display:flex;align-items:center;justify-content:center;width:${tw}px;height:${th}px;border-radius:${24 * s}px;font:500 ${22 * s * cap}px/1 SpaceGrotesk">${ch}</div>`).join('')}</div>`;
  const stars = `<div class="stars" style="margin-top:${26 * s}px;height:${19 * s}px;display:flex;justify-content:center;gap:${14 * s}px">${[1, 2, 3].map((i) => `<span style="position:relative;display:flex">${I.star('rgba(244,246,255,.55)', 19 * s)}${i <= V.stars ? `<span style="position:absolute;inset:0;display:flex">${I.star(K.limeMid, 19 * s, K.limeMid)}</span>` : ''}</span>`).join('')}</div>`;
  const stats = statCard(s, cap, [cell(s, cap, V.you, 'HAMLE'), cell(s, cap, V.dur, 'SÜRE'), starsCell(s, cap, V.stars)], { mt: 22 });
  const official = V.official ? `<div class="slate" style="margin-top:${10 * s}px;min-height:${46 * s}px;border-radius:${20 * s}px;display:flex;align-items:center;justify-content:space-between;gap:${10 * s}px;padding:${8 * s}px ${18 * s}px"><span class="cap" style="font-size:${11 * s * cap}px;letter-spacing:.14em">RESMÎ</span><span style="display:flex;align-items:center;gap:${10 * s}px;white-space:nowrap"><span class="num" style="font-size:${17 * s * cap}px;white-space:nowrap">${V.official.you}<span style="font:600 ${10 * s * cap}px Manrope;letter-spacing:.14em;color:${K.muted}"> HAMLE</span></span><span class="num" style="font-size:${17 * s * cap}px">${V.official.dur}</span><span style="display:flex;gap:${2 * s}px">${[1, 2, 3].map((i) => I.star(i <= V.official.stars ? K.limeMid : 'rgba(244,246,255,.55)', 12 * s * cap, i <= V.official.stars ? K.limeMid : 'none')).join('')}</span></span></div>` : '';
  let streak;
  if (dir === 'A') {
    streak = `<div class="slate streak" style="margin-top:${10 * s}px;min-height:${62 * s}px;border-radius:${24 * s}px;display:flex;align-items:center;padding:${6 * s}px ${16 * s}px ${6 * s}px ${6 * s}px;gap:${8 * s}px">
      <div style="position:relative;flex:1;height:${50 * s}px">${weekTrack(s, 190 * s, V.week, { k: 0.66, baseY: 44, id: 'r' + V.kind, numerals: false, cap })}</div>
      <div style="display:flex;flex-direction:column;align-items:flex-end;gap:${6 * s}px;flex:none"><span style="display:flex;align-items:center;gap:${5 * s}px">${I.flame(K.limeMid, 18 * s * cap)}<span class="num" style="position:relative;display:inline-block;font-size:${24 * s * cap}px">${o.reveal != null && !o.rm && V.prev != null ? `<span class="sv-old" style="position:absolute;left:0;top:0">${V.prev}</span>` : ''}<span class="sv">${V.streak}</span></span><span class="cap" style="font-size:${10 * s * cap}px;letter-spacing:.14em">SERİ</span></span><span class="cap" style="font-size:${10 * s * cap}px;letter-spacing:.14em">EN İYİ ${V.best}</span></div></div>`;
  } else {
    const notch = (side) => `<i style="position:absolute;${side}:${-12 * s}px;top:50%;margin-top:${-12 * s}px;width:${24 * s}px;height:${24 * s}px;border-radius:50%;background:#070C25;border:1px solid ${K.glassEdge}"></i>`;
    streak = `<div class="slate" style="margin-top:${10 * s}px;min-height:${62 * s}px;border-radius:${22 * s}px;display:flex;align-items:center;padding:${8 * s}px ${6 * s}px;overflow:visible">${notch('left')}${notch('right')}${[cell(s, cap, V.streak, 'GÜNLÜK SERİ', { icon: I.flame(K.limeMid, 19 * s * cap) }), cell(s, cap, V.best, 'EN İYİ SERİ')].join(`<span style="width:0;align-self:stretch;margin:${6 * s}px 0;border-left:1.5px dashed rgba(174,180,202,.40)"></span>`)}</div>`;
  }
  // The F13 Share place: a 63·s round slot at the right end of the primary row (the pill shortens by 73·s when F13 adds
  // it); zero extra height, so the 1.3× no-scroll rule holds with Share present. F07 draws nothing there.
  const share = o.shareSlot ? `<div style="flex:none;width:${63 * s}px;height:${63 * s}px;border-radius:50%;border:1.5px dashed rgba(221,250,107,.6);display:flex;align-items:center;justify-content:center;text-align:center;font:700 ${8.5 * s}px/1.25 Manrope;letter-spacing:.08em;color:rgba(221,250,107,.85)">F13<br>PAYLAŞ</div>` : '';
  const primary = limePill(F, 'Tamam', { tx, mt: 0, pressed: o.pressed, icon: I.check(K.limeInk, 20 * s) });
  const col = `<div class="abs" id="col" style="left:${24 * s}px;top:${(54 + 0.16 * e / s) * s}px;width:${309 * s}px;padding-bottom:${10 * s}px">
    <div style="display:flex;justify-content:center">${chip(s, cap, chipKind)}</div>
    <div class="sg" style="margin-top:${(14 + 0.06 * e / s) * s}px;text-align:center;font-size:${31 * s * cap}px;font-weight:500;line-height:1.13;letter-spacing:-.005em">${head}</div>
    <div style="margin-top:${12 * s}px;text-align:center;font:500 ${14.5 * s * tx}px/1.3 Manrope;color:${K.muted}">${sub}</div>
    ${tiles}${stats}${official}${streak}
    <div style="margin-top:${18 * s}px;display:flex;align-items:center;gap:${10 * s}px"><div style="flex:1;min-width:0">${primary}</div>${share}</div>${textLink(F, 'Tekrar oyna', { tx, mt: 6 })}</div>`;
  const radial = `<div class="abs" style="left:0;top:${(54 + 0.26 * e / s) * s + 30 * s}px;width:${W}px;height:${240 * s}px;background:radial-gradient(50% 50% at 50% 50%,rgba(208,239,88,.13),rgba(208,239,88,0) 72%)"></div>`;
  const reveal = o.reveal == null ? '' : revealCss(s, V, o.reveal, o.rm);
  return page(W, H, `${status(F)}${radial}${o.scroll === 'END' ? scrollBand(F) : ''}${backButton(F)}${col}${homeBar(F)}${o.scroll === 'END' ? toEnd(H) : ''}`, reveal);
}
// Direction A streak reveal (a rest-state reveal after the stars, like D2's star pop): 1300–1440 today's week node fills
// lime (from the pre-run look) and the SERİ numeral steps from the previous value (rise 6·s, 140 ms, ease-out). Reduced
// motion: the final state at rest, no step. ?t=<ms> freezes the page.
function revealCss(s, V, t, rm) {
  if (rm) return '';
  return `<style>@keyframes todayIn{0%{filter:grayscale(1) brightness(.7);transform:scale(.9)}70%{transform:scale(1.08)}100%{filter:none;transform:scale(1)}}
@keyframes numIn{from{opacity:0;transform:translateY(${6 * s}px)}to{opacity:1;transform:none}}@keyframes numOut{from{opacity:1;transform:none}to{opacity:0;transform:translateY(${-6 * s}px)}}
.streak .wt-today{animation:todayIn 140ms ease-out 1300ms both}.streak .sv{display:inline-block;animation:numIn 140ms ease-out 1370ms both}.streak .sv-old{animation:numOut 70ms ease-in 1300ms both}</style>
<script>addEventListener('load',()=>{document.getAnimations().forEach(a=>{a.pause();a.currentTime=${t};});});<\/script>`;
}

// ---------------------------------------------------------------- contrast (WCAG 2.x; translucent fills composited on the navy ground)
const hex = (h) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16));
const over = (fg, a, bg) => fg.map((c, i) => c * a + bg[i] * (1 - a));
const lum = (c) => { const f = (v) => { v /= 255; return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4); }; return 0.2126 * f(c[0]) + 0.7152 * f(c[1]) + 0.0722 * f(c[2]); };
const ratio = (a, b) => { const x = lum(a), y = lum(b); return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); };
function contrastTable() {
  const gLow = hex('#070C25'), gMid = hex('#0E1638'), glass = over([60, 74, 134], 0.5, hex('#0A1030')), slate = over([46, 64, 84], 0.58, gLow);
  const periChip = over(hex('#A8B4F9'), 0.10, gMid), missedBg = over([255, 255, 255], 0.035, slate), capsule = over([255, 255, 255], 0.035, gLow);
  const rows = [
    ['entry A caps label #AEB4CA on slate', ratio(hex('#AEB4CA'), slate)],
    ['entry A state line #F4F6FF on slate', ratio(hex('#F4F6FF'), slate)],
    ['entry A offline state line #AEB4CA on slate', ratio(hex('#AEB4CA'), slate)],
    ['entry A streak numeral #F4F6FF on slate', ratio(hex('#F4F6FF'), slate)],
    ['entry B label / numeral #F4F6FF on the capsule', ratio(hex('#F4F6FF'), capsule)],
    ['entry B state #AEB4CA on the capsule', ratio(hex('#AEB4CA'), capsule)],
    ['entry B capsule edge rgba(255,255,255,.18) on ground (non-text, ≥ 3)', ratio(over([255, 255, 255], 0.18, gLow), gLow)],
    ['week: missed outline rgba(174,180,202,.62) on slate (non-text, ≥ 3)', ratio(over(hex('#AEB4CA'), 0.62, slate), slate)],
    ['week: missed numeral #AEB4CA on the missed node', ratio(hex('#AEB4CA'), missedBg)],
    ['week: done numeral #0B1020 on lime #CDEB4B', ratio(hex('#0B1020'), hex('#CDEB4B'))],
    ['week: today numeral #0B1020 on #8792F0 (darkest stop)', ratio(hex('#0B1020'), hex('#8792F0'))],
    ['week: offline outline rgba(168,180,249,.75) on glass (non-text, ≥ 3)', ratio(over(hex('#A8B4F9'), 0.75, glass), glass)],
    ['week: weekday label #AEB4CA on glass', ratio(hex('#AEB4CA'), glass)],
    ['daily headline #F4F6FF on glass', ratio(hex('#F4F6FF'), glass)],
    ['daily body #AEB4CA on glass', ratio(hex('#AEB4CA'), glass)],
    ['result chip RESMÎ SONUÇ #F4F6FF on periwinkle chip', ratio(hex('#F4F6FF'), periChip)],
    ['result chip TEKRAR #AEB4CA on the ground', ratio(hex('#AEB4CA'), gMid)],
    ['result stat #F4F6FF / label #AEB4CA on slate', ratio(hex('#F4F6FF'), slate)],
    ['result stat label #AEB4CA on slate', ratio(hex('#AEB4CA'), slate)],
    ['flame (lit) #D0EF58 on slate (graphical)', ratio(hex('#D0EF58'), slate)],
    ['ticket #N #F4F6FF on glass / lime # on glass', ratio(hex('#DDFA6B'), glass)],
    ['ticket stamp #D0EF58 on glass (text)', ratio(hex('#D0EF58'), glass)],
  ];
  return rows.map(([k, v]) => `${v.toFixed(2).padStart(6)} : 1   ${k}`).join('\n') + '\n';
}

// ---------------------------------------------------------------- emit
const jobs = [];
const emit = (name, html, W, H) => { fs.writeFileSync(path.join(OUT, name + '.html'), html); jobs.push(`${name} ${W} ${H}`); };
const W = 393, H = 852, AX5 = 3.12;
const E = {
  available: { state: 'available', number: NUM, streak: 4, week: WEEK.before },
  done: { state: 'done', number: NUM, streak: 5, week: WEEK.after },
  offline: { state: 'offline', number: null, streak: 4, week: WEEK.offline },
  loading: { state: 'loading', number: null, streak: 4, week: WEEK.before.map((x, i) => (i === 6 ? 'skeleton' : x)) },
  missed: { state: 'available', number: NUM, streak: 0, week: WEEK.missedBefore },
};
// ---- Exploration (identical content in A and B)
for (const [d, entry, daily] of [['A', entryA, dailyA], ['B', entryB, dailyB]]) {
  emit(`F07-${d}-01-home-daily-available`, homeScreen(W, H, { entry: entry(E.available) }), W, H);
  emit(`F07-${d}-02-home-daily-done`, homeScreen(W, H, { entry: entry(E.done) }), W, H);
  emit(`F07-${d}-03-daily-ready`, daily(W, H, 'ready'), W, H);
  emit(`F07-${d}-04-daily-needs-connection`, daily(W, H, 'needsConnection'), W, H);
  emit(`F07-${d}-05-result-first-run`, resultScreen(d, W, H, R.first), W, H);
  emit(`F07-${d}-06-result-replay`, resultScreen(d, W, H, R.replay), W, H);
}
// ---- Direction A (recommended): the full state set
emit('F07-A-10-home-daily-needs-connection', homeScreen(W, H, { entry: entryA(E.offline) }), W, H);
emit('F07-A-11-home-daily-hidden', homeScreen(W, H, {}), W, H);
emit('F07-A-12-home-daily-loading', homeScreen(W, H, { entry: entryA(E.loading) }), W, H);
emit('F07-A-13-home-daily-streak-missed', homeScreen(W, H, { entry: entryA(E.missed) }), W, H);
emit('F07-A-20-daily-loading', dailyA(W, H, 'loading'), W, H);
emit('F07-A-21-daily-done-today', dailyA(W, H, 'doneToday'), W, H);
emit('F07-A-22-daily-unavailable', dailyA(W, H, 'unavailable'), W, H);
emit('F07-A-23-daily-ready-streak-missed', dailyA(W, H, 'ready', { week: WEEK.missedBefore, streak: 0 }), W, H);
emit('F07-A-24-daily-cta-pressed', dailyA(W, H, 'ready', { pressed: true }), W, H);
emit('F07-A-25-daily-focus-cta', dailyA(W, H, 'ready', { focus: true }), W, H);
emit('F07-A-30-play-daily-header', play(W, H), W, H);
emit('F07-A-31-play-daily-header-text-cap-1_3', play(W, H, { tx: 1.3 }), W, H);
emit('F07-A-40-result-streak-reset-0to1', resultScreen('A', W, H, R.reset), W, H);
emit('F07-A-41-result-share-slot-budget', resultScreen('A', W, H, R.first, { shareSlot: true }), W, H);
emit('F07-A-42-result-share-slot-budget-cap-1_3', resultScreen('A', W, H, R.replay, { shareSlot: true, tx: 1.3 }), W, H);
emit('F07-A-43-result-cta-pressed', resultScreen('A', W, H, R.first, { pressed: true }), W, H);
// motion stills (the direction A streak reveal; D2 timeline otherwise unchanged)
for (const t of [940, 1300, 1370, 1440]) emit(`F07-A-M-streak-reveal-t${String(t).padStart(4, '0')}`, resultScreen('A', W, H, R.first, { reveal: t }), W, H);
emit('F07-A-M-streak-reveal-reduced', resultScreen('A', W, H, R.first, { reveal: 0, rm: true }), W, H);
// Home entrance with the entry (entry 180–420 ms)
for (const t of [0, 120, 240, 420]) emit(`F07-A-M-home-entrance-t${String(t).padStart(4, '0')}`, homeScreen(W, H, { entry: entryA(E.available), entrance: t }), W, H);
// text scale: 1.3× cap and AX5 (free text follows the OS scale)
emit('F07-A-50-home-text-cap-1_3', homeScreen(W, H, { tx: 1.3, entry: entryA(E.available) }), W, H);
emit('F07-A-51-home-ax5-top', homeScreen(W, H, { tx: AX5, entry: entryA(E.available), scroll: true }), W, H);
emit('F07-A-52-home-ax5-scrolled-end', homeScreen(W, H, { tx: AX5, entry: entryA(E.available), scroll: 'END' }), W, H);
emit('F07-A-53-daily-ready-text-cap-1_3', dailyA(W, H, 'ready', { tx: 1.3 }), W, H);
emit('F07-A-54-daily-ready-ax5-top', dailyA(W, H, 'ready', { tx: AX5, scroll: true }), W, H);
emit('F07-A-55-daily-ready-ax5-scrolled-end', dailyA(W, H, 'ready', { tx: AX5, scroll: 'END' }), W, H);
emit('F07-A-56-daily-needs-connection-ax5-scrolled-end', dailyA(W, H, 'needsConnection', { tx: AX5, scroll: 'END' }), W, H);
emit('F07-A-57-result-text-cap-1_3', resultScreen('A', W, H, R.replay, { tx: 1.3 }), W, H);
emit('F07-A-58-result-ax5-top', resultScreen('A', W, H, R.first, { tx: AX5, scroll: true }), W, H);
emit('F07-A-59-result-ax5-scrolled-end', resultScreen('A', W, H, R.first, { tx: AX5, scroll: 'END' }), W, H);
// device variants (16e, Pro Max)
for (const [tag, w, h] of [['16e', 390, 844], ['promax', 440, 956]]) {
  emit(`F07-A-v-${tag}-home-daily-available`, homeScreen(w, h, { entry: entryA(E.available) }), w, h);
  emit(`F07-A-v-${tag}-home-text-cap-1_3`, homeScreen(w, h, { tx: 1.3, entry: entryA(E.available) }), w, h);
  emit(`F07-A-v-${tag}-daily-ready`, dailyA(w, h, 'ready'), w, h);
  emit(`F07-A-v-${tag}-daily-done-today`, dailyA(w, h, 'doneToday'), w, h);
  emit(`F07-A-v-${tag}-play-daily-header`, play(w, h), w, h);
  emit(`F07-A-v-${tag}-result-first-run`, resultScreen('A', w, h, R.first), w, h);
  emit(`F07-A-v-${tag}-result-replay-text-cap-1_3`, resultScreen('A', w, h, R.replay, { tx: 1.3 }), w, h);
}
emit('F07-A-v-16e-result-share-slot-budget-cap-1_3', resultScreen('A', 390, 844, R.replay, { shareSlot: true, tx: 1.3 }), 390, 844);
emit('F07-A-v-16e-home-ax5-top', homeScreen(390, 844, { tx: AX5, entry: entryA(E.available), scroll: true }), 390, 844);
fs.writeFileSync(path.join(OUT, 'jobs-f07.txt'), jobs.join('\n') + '\n');
fs.writeFileSync(path.join(OUT, 'contrast-f07.txt'), '# F07-UI contrast (WCAG 2.x; translucent fills composited on the navy ground; gen-f07.mjs contrastTable)\n' + contrastTable());
console.log(jobs.length + ' pages');
