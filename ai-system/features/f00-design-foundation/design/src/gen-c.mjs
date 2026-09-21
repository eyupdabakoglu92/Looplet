// F00 round 2 — Direction C ("Loop Glass"): rendered from the user's three reference screens (design/reference/).
// Same states/content as Directions A/B (real level 1/4/5/26 puzzles) + reference-frame renders for parity.
// Layout is authored in the reference's 358x717 CSS-pixel space (its 716x1434 images are @2x) and scaled by width.
// Usage: node gen-c.mjs <outDir>   (render.sh renders jobs-c.txt)
import fs from 'node:fs';
import path from 'node:path';
const OUT = process.argv[2] ?? '.';

// ---------------------------------------------------------------- content
const L5 = { grid: ['ZUÇEK', 'BÜOLŞ', 'HALUT', 'ÜRŞAG', 'DGGGŞ'], target: 'BULUT' };
const L5_MOVED = ['ZUÇEK', 'ŞBÜOL', 'HALUT', 'ÜRŞAG', 'DGGGŞ']; // the reference's play state (row 1 moved once)
const L5_WON = ['ZUÇEK', 'ŞBÜOL', 'BULUT', 'ÜRŞAG', 'DGGGŞ'];
const L4 = { grid: ['BLÇIZ', 'MIENO', 'PÜLNG', 'BDERİ', 'ŞALKD'], target: 'BALIK' };
const L26 = { grid: ['TORBİ', 'ZYYOR', 'ÜYOZT', 'ÜROLL', 'LAHŞR'], target: 'TARİH', locked: ['0,0', '0,2'], frozen: ['2,2', '2,3'] };
const REF_WON = ['MASAL']; // the reference completion word

// ---------------------------------------------------------------- tokens (colours measured from the user's screens; see design-foundation.md §17)
const K = {
  navy0: '#050A1E', navy1: '#0D132D', glow: '#2D365C',
  lime: '#DDFA6B', limeHi: '#E8FC94', limeMid: '#D0EF58', limeLo: '#C2E23F', limeInk: '#0B1020',
  peri: '#A8B4F9', periLo: '#8792F0', cream: '#FCF7F0', creamLo: '#EEE7DA', ink: '#141826',
  text: '#F4F6FF', muted: '#AEB4CA', muted2: '#AEB3C7', glassEdge: 'rgba(255,255,255,.10)',
};
const font = `
@font-face{font-family:'SpaceGrotesk';src:url('fonts/SpaceGrotesk.ttf');font-weight:300 700}
@font-face{font-family:'Manrope';src:url('fonts/Manrope.ttf');font-weight:200 800}`;

// ---------------------------------------------------------------- icons: thin rounded outline (drawn for this project)
const ic = (d, c = K.text, s = 20, w = 1.7, extra = '') => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${c}" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round">${d}${extra}</svg>`;
const I = {
  back: (c, s) => ic('<path d="m15 5-7 7 7 7"/>', c, s, 1.9),
  sliders: (c, s) => ic('<path d="M4 7h8M18 7h2M4 17h2M12 17h8"/><circle cx="15" cy="7" r="2.6"/><circle cx="9" cy="17" r="2.6"/>', c, s),
  flame: (c, s) => ic('<path d="M12 3c.8 3.2 5.4 5 5.4 10a5.4 5.4 0 0 1-10.8 0c0-2 1-3.4 2.2-4.4.2 1.7 1 2.6 2.2 2.8C10.2 8.4 10.6 5.4 12 3Z"/>', c, s),
  sparkle: (c, s) => ic('<path d="M10 4.5 12 10l5.5 2-5.5 2-2 5.5-2-5.5-5.5-2 5.5-2Z"/><path d="M19 3.5v4M17 5.5h4"/>', c, s),
  star: (c, s, fill = 'none') => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="${fill}" stroke="${c}" stroke-width="1.6" stroke-linejoin="round"><polygon points="12,2.2 14.8,8.8 22,9.5 16.6,14.2 18.2,21.2 12,17.5 5.8,21.2 7.4,14.2 2,9.5 9.2,8.8"/></svg>`,
  undo: (c, s) => ic('<path d="M9 14 4 9l5-5"/><path d="M4 9h9.5a6.5 6.5 0 0 1 0 13H10"/>', c, s),
  restart: (c, s) => ic('<path d="M3.5 12a8.5 8.5 0 1 0 2.7-6.2L3.5 8.4"/><path d="M3.5 3.6v4.8h4.8"/>', c, s),
  upright: (c, s) => ic('<path d="M7 17 17 7"/><path d="M8.5 7H17v8.5"/>', c, s, 1.9),
  right: (c, s) => ic('<path d="M5 12h14"/><path d="m13 6 6 6-6 6"/>', c, s, 1.9),
  lock: (c, s) => ic('<rect x="5" y="10.5" width="14" height="10" rx="2.6"/><path d="M8.5 10.5V8a3.5 3.5 0 0 1 7 0v2.5"/>', c, s, 1.9),
  snow: (c, s) => ic('<path d="M12 2.5v19M3.8 7.2l16.4 9.6M3.8 16.8 20.2 7.2"/><path d="m9.3 4.2 2.7 1.8 2.7-1.8M9.3 19.8l2.7-1.8 2.7 1.8"/>', c, s, 1.7),
  updown: (c, s) => ic('<path d="m7.5 9.5 4.5-4.5 4.5 4.5M7.5 14.5l4.5 4.5 4.5-4.5"/>', c, s, 1.9),
};

// ---------------------------------------------------------------- frame scale/layout
function frame(W, H) { const s = W / 358; const extra = Math.max(0, H - 717 * s); return { W, H, s, extra, e1: extra * 0.3, e2: extra * 0.7 }; }
function page(W, H, body) {
  return `<!doctype html><html><head><meta charset="utf-8"><style>${font}
*{box-sizing:border-box;margin:0;padding:0}html,body{width:${W}px;height:${H}px;overflow:hidden}
body{position:relative;font-family:'Manrope',sans-serif;color:${K.text};
 background:radial-gradient(75% 40% at 90% 6%,#2D3766 0%,rgba(45,55,102,0) 72%),radial-gradient(55% 26% at 0% 58%,rgba(26,88,96,.32),rgba(26,88,96,0) 72%),linear-gradient(#0A1030 0%,#070C25 55%,#050A1E 100%)}
.abs{position:absolute}.sg{font-family:'SpaceGrotesk',sans-serif}
.cap{font-family:'Manrope';font-weight:600;letter-spacing:.2em;text-transform:uppercase;color:${K.muted};line-height:1}
.glass{position:absolute;background:linear-gradient(155deg,rgba(60,74,134,.50),rgba(22,30,64,.58));border:1px solid ${K.glassEdge};box-shadow:0 24px 60px rgba(2,4,16,.35),inset 0 1px 0 rgba(255,255,255,.07)}
.tile{position:absolute;display:flex;align-items:center;justify-content:center;font-family:'SpaceGrotesk';font-weight:500;line-height:1;color:${K.ink};
 background:linear-gradient(180deg,#FFFCF7,#F0E9DC);box-shadow:inset 0 1px 0 #fff,inset 0 -2px 0 rgba(120,100,70,.10),0 7px 16px rgba(2,4,16,.45),0 1px 0 rgba(0,0,0,.2)}
.tile.lime{background:linear-gradient(160deg,#E3FB7E,#CDEB4B);color:${K.limeInk};box-shadow:inset 0 1px 0 rgba(255,255,255,.45),0 10px 26px rgba(208,239,88,.34),0 1px 0 rgba(0,0,0,.2)}
.tile.locked{background:linear-gradient(160deg,#4149A0,#2B3170);color:#F4F6FF;box-shadow:inset 0 0 0 1.5px rgba(168,180,249,.55),0 7px 16px rgba(2,4,16,.45)}
.tile.frozen{background:linear-gradient(160deg,#DFF1FB,#B5D6EC);color:${K.ink};box-shadow:inset 0 0 0 1.5px #7FB0D6,0 7px 16px rgba(2,4,16,.45);border:1.5px dashed rgba(60,110,155,.75)}
.tile.lift{background:linear-gradient(180deg,#FFFFFF,#F3EEE4);box-shadow:0 0 0 2px ${K.peri},0 0 26px rgba(168,180,249,.6),0 16px 26px rgba(2,4,16,.55)}
.tile.ghost{opacity:.3;box-shadow:none}
.slot{position:absolute;border:1.5px dashed rgba(221,250,107,.5);background:rgba(221,250,107,.05)}
.glass.slate{background:linear-gradient(155deg,rgba(46,64,84,.58),rgba(17,25,40,.66))}
.pill{position:absolute;display:flex;align-items:center;justify-content:center}
</style></head><body>${body}</body></html>`;
}
const status = (F) => `<div class="abs" style="left:${25 * F.s}px;top:${15 * F.s}px;font:500 ${14.5 * F.s}px/1 Manrope;color:#fff">9:41</div>
<div class="abs" style="right:${25 * F.s}px;top:${17 * F.s}px;display:flex;gap:${5 * F.s}px;align-items:center"><svg width="${17 * F.s}" height="${11 * F.s}" viewBox="0 0 17 11" fill="#fff"><rect y="7" width="3" height="4" rx="1"/><rect x="4.7" y="4.5" width="3" height="6.5" rx="1"/><rect x="9.4" y="2" width="3" height="9" rx="1"/><rect x="14" width="3" height="11" rx="1"/></svg><svg width="${24 * F.s}" height="${11 * F.s}" viewBox="0 0 24 11" fill="none" stroke="#fff" stroke-width="1"><rect x=".5" y=".5" width="20" height="10" rx="3.2" opacity=".55"/><rect x="2" y="2" width="17" height="7" rx="1.8" fill="#fff" stroke="none"/></svg></div>
<div class="abs" style="left:${F.W / 2 - 47 * F.s}px;top:${10 * F.s}px;width:${94 * F.s}px;height:${28 * F.s}px;border-radius:${14 * F.s}px;background:#000"></div>`;
const homeBar = (F) => `<div class="abs" style="left:${F.W / 2 - 62 * F.s}px;bottom:${7 * F.s}px;width:${124 * F.s}px;height:${4.6 * F.s}px;border-radius:3px;background:rgba(255,255,255,.62)"></div>`;

// ---------------------------------------------------------------- board (card + tiles); opts: grid, lift, lime row (literal), won etc.
function boardGeo(F, top) {
  const s = F.s, cw = 308.5 * s, x = (F.W - cw) / 2, pad = 11 * s, t = 52 * s, gap = 6.5 * s;
  return { s, cw, x, pad, t, gap, stride: t + gap, top, ch: 307.5 * s };
}
function board(F, B, o) {
  const { s, x, pad, t, gap, stride, top, cw, ch } = B, grid = o.grid;
  let out = `<div class="abs" style="left:${x}px;top:${top}px;width:${cw}px;height:${ch}px;border-radius:${34 * s}px;background:linear-gradient(180deg,rgba(22,30,64,.86),rgba(9,14,36,.88));border:1px solid rgba(255,255,255,.09);box-shadow:0 26px 60px rgba(2,4,16,.4);opacity:${o.cardOpacity ?? 1}"></div>
  <div class="abs" style="left:${x + cw / 2 - 72 * s}px;top:${top}px;width:${144 * s}px;height:${2 * s}px;background:linear-gradient(90deg,transparent,#8792F0,transparent);opacity:${o.cardOpacity ?? 1}"></div>`;
  const cell = (r, c, dx = 0, extra = '') => {
    const key = `${r},${c}`; let kind = '';
    if (o.wonRow === r && !o.vacated) kind = 'lime';
    else if (o.locked?.includes(key)) kind = 'locked'; else if (o.frozen?.includes(key)) kind = 'frozen';
    if (o.lime === r) kind = 'lime';
    if (o.lift === r && !o.lime) kind = (kind ? kind + ' ' : '') + 'lift';
    const icon = kind.includes('locked') ? `<i style="position:absolute;top:${4 * s}px;right:${4 * s}px;display:flex">${I.lock('#F4F6FF', 13 * s)}</i>` : kind.includes('frozen') ? `<i style="position:absolute;top:${4 * s}px;right:${4 * s}px;display:flex">${I.snow('#3F78A8', 13 * s)}</i>` : '';
    const dim = o.lift != null && o.lift !== r && !o.lime ? 'opacity:.42;' : (o.dimAll ? `filter:brightness(${1 - o.dimAll});` : '');
    return `<div class="tile ${kind} ${extra}" style="left:${x + pad + c * stride + dx}px;top:${top + pad + r * stride}px;width:${t}px;height:${t}px;border-radius:${t * 0.33}px;font-size:${t * 0.38}px;${dim}"><span>${grid[r][c]}</span>${icon}</div>`;
  };
  for (let r = 0; r < 5; r++) {
    if (o.vacated && o.wonRow === r) { for (let c = 0; c < 5; c++) out += `<div class="slot" style="left:${x + pad + c * stride}px;top:${top + pad + r * stride}px;width:${t}px;height:${t}px;border-radius:${t * 0.33}px"></div>`; continue; }
    if (o.lift === r && !o.lime) continue;
    for (let c = 0; c < 5; c++) out += cell(r, c);
  }
  if (o.lift != null && !o.lime) {
    const r = o.lift, dx = Math.round(stride * 0.55);
    let inner = ''; for (let c = 0; c < 5; c++) inner += cell(r, c, dx);
    const gh = cell(r, 4, 0, 'ghost').replace(/left:[^;]+;/, `left:${x + pad - stride + dx}px;`);
    const clipL = x + pad - 5 * s, clipW = cw - 2 * pad + 10 * s;
    out += `<div class="abs" style="left:${clipL}px;top:0;width:${clipW}px;height:${F.H}px;overflow:hidden">${(inner + gh).replace(/left:(-?[\d.]+)px/g, (m, v) => `left:${(parseFloat(v) - clipL).toFixed(2)}px`)}</div>`;
    const ry = top + pad + r * stride;
    out += `<div class="abs" style="left:${x - 1}px;top:${ry + 8 * s}px;width:${3 * s}px;height:${t - 16 * s}px;border-radius:2px;background:${K.peri};box-shadow:0 0 14px ${K.peri}"></div><div class="abs" style="left:${x + cw - 2 * s}px;top:${ry + 8 * s}px;width:${3 * s}px;height:${t - 16 * s}px;border-radius:2px;background:${K.peri};box-shadow:0 0 14px ${K.peri}"></div>`;
  }
  if (o.lime != null) { // reference-literal: the active row is lime
    const r = o.lime; let row = ''; for (let c = 0; c < 5; c++) row += cell(r, c); out += row;
  }
  return out;
}

// ---------------------------------------------------------------- shared header/target pieces (play family)
function topBar(F, o) {
  const s = F.s, op = o.dim ?? 1;
  return `<div class="abs" style="left:${25 * s}px;top:${96 * s}px;display:flex;align-items:center;gap:${6 * s}px;opacity:${op}">${I.back(K.muted, 20 * s)}<span class="cap" style="font-size:${11.5 * s}px">SEVİYE 05</span></div>
  <div class="pill" style="left:${273.5 * s}px;top:${75 * s}px;width:${60 * s}px;height:${63 * s}px;border-radius:${22 * s}px;flex-direction:column;gap:${7 * s}px;background:linear-gradient(160deg,rgba(120,132,196,.34),rgba(70,80,140,.30));border:1px solid rgba(255,255,255,.09);opacity:${op}"><span class="sg" style="font-size:${22 * s}px;font-weight:500;line-height:1">${o.moves}</span><span class="cap" style="font-size:${9.5 * s}px;letter-spacing:.16em">HAMLE</span></div>`;
}
function targetRail(F, word, e1, op = 1) {
  const s = F.s, w = 36 * s, g = 8 * s, x0 = (F.W - (5 * w + 4 * g)) / 2, y = 197 * s + e1;
  let t = `<div class="cap abs" style="left:0;width:${F.W}px;top:${172 * s + e1}px;text-align:center;font-size:${11.5 * s}px;opacity:${op}">HEDEF DÖNGÜ</div>`;
  for (let i = 0; i < 5; i++) t += `<div class="tile" style="left:${x0 + i * (w + g)}px;top:${y}px;width:${w}px;height:${42 * s}px;border-radius:${14 * s}px;font-size:${16.5 * s}px;color:${K.text};background:linear-gradient(180deg,#2B2B58,#242349);box-shadow:inset 0 0 0 1px rgba(150,160,235,.32),0 6px 14px rgba(2,4,16,.35);opacity:${op}"><span>${word[i]}</span></div>`;
  return t;
}
function hud(F, o) {
  const s = F.s, y = 592.5 * s + F.e1 + F.e2, op = o.dim ?? 1;
  const dots = '<i style="width:' + 5.5 * s + 'px;height:' + 5.5 * s + 'px;border-radius:50%;background:' + K.limeMid + ';display:block"></i>';
  return `<div class="pill" style="left:${29 * s}px;top:${y}px;width:${98.5 * s}px;height:${50 * s}px;border-radius:${22 * s}px;gap:${10 * s}px;background:rgba(255,255,255,.075);border:1px solid rgba(255,255,255,.07);opacity:${(o.undoOn ? 1 : 0.55) * op}">${I.undo(K.text, 21 * s)}<span style="display:flex;gap:${5 * s}px">${dots}${dots}${dots}</span></div>
  <div class="pill" style="left:${289 * s}px;top:${y + 5 * s}px;width:${40 * s}px;height:${40 * s}px;border-radius:${18 * s}px;background:rgba(255,255,255,.075);border:1px solid rgba(255,255,255,.07);opacity:${op}">${I.restart(K.text, 20 * s)}</div>
  ${o.hint === false ? '' : `<div class="abs" style="left:0;width:${F.W}px;top:${y + 70 * s}px;text-align:center;font:500 ${12.5 * s}px/1 Manrope;color:${K.muted};opacity:${op}">Satırı tut · kaydır · bırak</div>`}`;
}

// ---------------------------------------------------------------- screens
function playScreen(W, H, kind, lit = false) {
  const F = frame(W, H), s = F.s, top = 261.5 * s + F.e1;
  const B = boardGeo(F, top);
  let o = { grid: L5.grid }, moves = 0, word = L5.target, hudOp = 1;
  if (kind === 'lift') { o = { grid: L5_MOVED, lift: 2, ...(lit ? { lime: 2 } : {}) }; moves = 2; }
  if (kind === 'refstate') { o = { grid: L5_MOVED, lime: 2 }; moves = 2; }
  if (kind === 'pieces') { o = { grid: L26.grid, locked: L26.locked, frozen: L26.frozen }; word = L26.target; moves = 3; }
  const dim = kind === 'lift' && !lit ? 0.5 : 1;
  return page(W, H, `${status(F)}${topBar(F, { moves, dim })}${targetRail(F, word, F.e1, kind === 'lift' && !lit ? 0.85 : 1)}${board(F, B, o)}${hud(F, { dim: kind === 'lift' && !lit ? 0.5 : 1, undoOn: kind === 'pieces' || kind === 'lift' || kind === 'refstate' })}${homeBar(F)}`);
}
function tutorialScreen(W, H) {
  const F = frame(W, H), s = F.s, top = 261.5 * s + F.e1, B = boardGeo(F, top);
  const cx = B.x + B.pad + 2 * B.stride + B.t / 2, cy = top + B.pad + 2 * B.stride + B.t / 2;
  const ghost = `<div class="abs" style="left:${cx - 24 * s}px;top:${cy - 24 * s}px;width:${48 * s}px;height:${48 * s}px;border-radius:50%;background:rgba(168,180,249,.28);box-shadow:0 0 0 1.5px ${K.peri},0 0 26px rgba(168,180,249,.6)"></div><div class="abs" style="left:${cx - 12 * s}px;top:${cy - 66 * s}px">${I.updown(K.peri, 24 * s)}</div>`;
  const y = 592.5 * s + F.e1 + F.e2;
  const hint = `<div class="pill" style="left:${29 * s}px;top:${y}px;width:${300 * s}px;height:${54 * s}px;border-radius:${24 * s}px;background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.08);gap:${10 * s}px;font:500 ${13 * s}px/1.25 Manrope;color:${K.text};padding:0 ${16 * s}px;text-align:left">${I.sparkle(K.limeMid, 20 * s)}<span>Sütunları da kaydırabilirsin — yukarı ya da aşağı.</span></div>`;
  return page(W, H, `${status(F)}${topBar(F, { moves: 0 })}${targetRail(F, L4.target, F.e1)}${board(F, B, { grid: L4.grid })}${ghost}${hint}${homeBar(F)}`);
}

// star row for results
const stars = (n, size, gap) => `<div style="display:flex;gap:${gap}px;align-items:center">${[1, 2, 3].map((i) => (i <= n ? `<span style="filter:drop-shadow(0 0 8px rgba(208,239,88,.55));display:flex">${I.star(K.limeMid, size, K.limeMid)}</span>` : I.star('rgba(244,246,255,.55)', size))).join('')}</div>`;
const statCell = (v, l, w) => `<div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:${9 * w}px"><span class="sg" style="font-size:${24 * w}px;font-weight:500;line-height:1;font-variant-numeric:tabular-nums">${v}</span><span class="cap" style="font-size:${10.5 * w}px;letter-spacing:.14em">${l}</span></div>`;

// full-screen completion = the reference composition (also the parity frame)
function completionFull(W, H, o = {}) {
  const F = frame(W, H), s = F.s, e = F.extra * 0.4;
  const w = 52.5 * s, g = 6.5 * s, x0 = (F.W - (5 * w + 4 * g)) / 2, word = o.word ?? 'MASAL';
  let tiles = ''; for (let i = 0; i < 5; i++) tiles += `<div class="tile lime" style="left:${x0 + i * (w + g)}px;top:${258 * s + e}px;width:${w}px;height:${59 * s}px;border-radius:${24 * s}px;font-size:${22 * s}px"><span>${word[i]}</span></div>`;
  const st = o.refSemantics
    ? `${statCell('1', 'SEN', s)}<span style="width:1px;height:${44 * s}px;background:rgba(255,255,255,.10)"></span>${statCell('=', 'OPTİMAL', s)}<span style="width:1px;height:${44 * s}px;background:rgba(255,255,255,.10)"></span>${statCell('+3', 'YILDIZ', s)}`
    : `${statCell(o.n ?? 1, 'SEN', s)}<span style="width:1px;height:${44 * s}px;background:rgba(255,255,255,.10)"></span>${statCell(o.n ?? 1, 'OPTİMAL', s)}<span style="width:1px;height:${44 * s}px;background:rgba(255,255,255,.10)"></span>${statCell((o.n ?? 1) + '<sup style="font-size:.5em;color:' + K.limeMid + ';margin-left:2px">★</sup>', 'EN İYİ', s)}`;
  return page(W, H, `${status(F)}
  <div class="abs" style="left:0;top:${140 * s + e}px;width:${W}px;height:${240 * s}px;background:radial-gradient(50% 50% at 50% 50%,rgba(208,239,88,.13),rgba(208,239,88,0) 72%)"></div>
  <div class="pill" style="left:${W / 2 - 56 * s}px;top:${54 * s + e * 0.4}px;width:${112 * s}px;height:${42 * s}px;border-radius:${21 * s}px;gap:${7 * s}px;background:linear-gradient(160deg,rgba(150,180,50,.26),rgba(90,120,30,.24));border:1px solid rgba(208,239,88,.42)">${I.sparkle(K.limeMid, 18 * s)}<span class="cap" style="font-size:${11 * s}px;color:${K.limeMid};letter-spacing:.14em">${o.badge ?? 'YENİ EN İYİ'}</span></div>
  <div class="sg abs" style="left:0;width:${W}px;top:${112 * s + e * 0.6}px;text-align:center;font-size:${33 * s}px;font-weight:500;line-height:1.13;letter-spacing:-.005em">Döngü<br>tamamlandı.</div>
  <div class="abs" style="left:0;width:${W}px;top:${203 * s + e * 0.6}px;text-align:center;font:500 ${14.5 * s}px/1 Manrope;color:${K.muted}">${o.sub ?? 'Hedef tek hamlede yerine oturdu.'}</div>
  ${tiles}
  <div class="abs" style="left:0;width:${W}px;top:${349 * s + e}px;display:flex;justify-content:center">${stars(3, 19 * s, 14 * s)}</div>
  <div class="glass slate" style="left:${24 * s}px;top:${392.5 * s + e}px;width:${309 * s}px;height:${74 * s}px;border-radius:${26 * s}px;display:flex;align-items:center;padding:0 ${6 * s}px">${st}</div>
  <div class="pill" style="left:${24 * s}px;top:${485 * s + e}px;width:${309 * s}px;height:${63.5 * s}px;border-radius:${32 * s}px;justify-content:space-between;padding:0 ${23 * s}px;background:linear-gradient(180deg,#E2FB78,#D3F04F);box-shadow:0 16px 44px rgba(208,239,88,.26);color:${K.limeInk};font:500 ${16 * s}px/1 Manrope">Sonraki bölüm${I.right(K.limeInk, 20 * s)}</div>
  <div class="abs" style="left:0;width:${W}px;top:${568 * s + e}px;text-align:center;font:500 ${15.5 * s}px/1 Manrope;color:${K.muted}">Tekrar oyna</div>${homeBar(F)}`);
}

// contract-conforming won moment: the answer row lands where the target rail was; a bottom-anchored glass sheet; board dimmed behind
function wonScreen(W, H, variant, phase = 'rest', opt = {}) {
  const F = frame(W, H), s = F.s, top = 261.5 * s + F.e1, B = boardGeo(F, top);
  const perfect = variant === 'perfect', winRow = 2;
  const panelTop = Math.round(0.365 * H), panelH = H - panelTop;
  const railTop = 197 * s + F.e1, tile = B.t, dockTop = railTop + (42 * s - tile) / 2 - 2 * s;
  const rowHome = top + B.pad + winRow * B.stride;
  const scrim = { hold: 0, glide: 0.5, panel: 0.8, rest: 1 }[phase];
  const o = { grid: L5_WON, wonRow: winRow, vacated: phase !== 'hold', cardOpacity: phase === 'hold' ? 1 : 0.22, dimAll: phase === 'hold' ? 0 : 0.88 };
  let boardHtml = board(F, B, o);
  if (phase === 'hold') boardHtml = boardHtml.replace(/<div class="tile ([^"]*)" style="([^"]*)"/g, (m, k, st) => (k.includes('lime') ? m : `<div class="tile ${k}" style="${st}filter:brightness(.5);"`));
  const x0 = (W - (5 * tile + 4 * B.gap)) / 2;
  const dy = phase === 'glide' ? dockTop + (rowHome - dockTop) * 0.5 : dockTop;
  let dock = '';
  if (phase !== 'hold') {
    for (let i = 0; i < 5; i++) dock += `<div class="tile lime" style="left:${x0 + i * B.stride}px;top:${dy}px;width:${tile}px;height:${tile}px;border-radius:${tile * 0.33}px;font-size:${tile * 0.38}px;box-shadow:0 12px 30px rgba(208,239,88,.42),inset 0 1px 0 rgba(255,255,255,.6)"><span>${L5.target[i]}</span></div>`;
  }
  const rail = phase === 'hold' ? targetRail(F, L5.target, F.e1, 0.9) : '';
  const bar = `<div class="abs" style="left:${273.5 * s}px;top:${75 * s}px;width:${60 * s}px;height:${63 * s}px;opacity:.4;border-radius:${22 * s}px;background:rgba(120,132,196,.34);display:flex;flex-direction:column;align-items:center;justify-content:center;gap:${7 * s}px"><span class="sg" style="font-size:${22 * s}px;font-weight:500">${perfect ? 3 : 4}</span><span class="cap" style="font-size:${9.5 * s}px;letter-spacing:.16em">HAMLE</span></div>`;
  const scrimEl = `<div class="abs" style="inset:0;background:rgba(3,6,20,${0.46 * scrim})"></div>`;
  const rise = phase === 'panel' ? 110 : 0, pOp = phase === 'panel' ? 0.95 : 1;
  const sub = perfect ? 'Hedef üç hamlede yerine oturdu.' : 'Hedef dört hamlede yerine oturdu.';
  const badge = perfect
    ? `<div class="pill" style="position:relative;width:${104 * s}px;height:${34 * s}px;border-radius:${17 * s}px;gap:${6 * s}px;background:linear-gradient(160deg,rgba(150,180,50,.26),rgba(90,120,30,.24));border:1px solid rgba(208,239,88,.42)">${I.sparkle(K.limeMid, 16 * s)}<span class="cap" style="font-size:${10.5 * s}px;color:${K.limeMid};letter-spacing:.16em">HARİKA</span></div>`
    : `<div style="height:${34 * s}px"></div>`;
  const cell = (v, l) => statCell(v, l, s * 0.92);
  const sep = `<span style="width:1px;height:${40 * s}px;background:rgba(255,255,255,.10)"></span>`;
  const you = perfect ? 3 : 4;
  const primary = (t) => `<div class="pill" style="position:relative;width:${309 * s}px;height:${56 * s}px;border-radius:${28 * s}px;justify-content:space-between;padding:0 ${22 * s}px;background:linear-gradient(180deg,#E2FB78,#D3F04F);box-shadow:0 14px 38px rgba(208,239,88,.26);color:${K.limeInk};font:600 ${15.5 * s}px/1 Manrope">${t}${I.right(K.limeInk, 19 * s)}</div>`;
  const secondary = (t) => `<div class="pill" style="position:relative;width:${309 * s}px;height:${46 * s}px;border-radius:${23 * s}px;border:1px solid rgba(255,255,255,.18);font:500 ${14.5 * s}px/1 Manrope;color:${K.text}">${t}</div>`;
  const panelEl = phase === 'hold' || phase === 'glide' ? '' : `<div class="abs" style="left:0;top:${panelTop + rise}px;width:${W}px;height:${panelH}px;border-radius:${34 * s}px ${34 * s}px 0 0;background:linear-gradient(180deg,rgba(38,48,96,.96),rgba(16,22,50,.98));border:1px solid rgba(255,255,255,.10);border-bottom:none;box-shadow:0 -24px 60px rgba(2,4,16,.5),inset 0 1px 0 rgba(255,255,255,.08);opacity:${pOp};display:flex;flex-direction:column;align-items:center;justify-content:space-between;padding:${22 * s}px 0 ${34 * s}px">
    ${badge}
    <div class="sg" style="font-size:${28 * s}px;font-weight:500;line-height:1;text-align:center">Döngü tamamlandı.</div>
    <div style="font:500 ${13.5 * s}px/1 Manrope;color:${K.muted}">${sub}</div>
    ${stars(perfect ? 3 : 2, 30 * s, 12 * s)}
    <div class="glass slate" style="position:relative;width:${309 * s}px;height:${68 * s}px;border-radius:${24 * s}px;display:flex;align-items:center;padding:0 ${6 * s}px">${cell(you, 'SEN')}${sep}${cell(3, 'OPTİMAL')}${sep}${cell('3<sup style="font-size:.5em;color:' + K.limeMid + ';margin-left:2px">★</sup>', 'EN İYİ')}</div>
    ${perfect ? primary('Sonraki bölüm') : primary('Tekrar oyna')}
    ${perfect ? secondary('Tekrar oyna') : secondary('Sonraki bölüm')}
    <div style="font:600 ${13.5 * s}px/1 Manrope;color:${K.muted};letter-spacing:.04em">Kapat</div></div>`;
  return page(W, H, `${status(F)}${rail}${bar}${boardHtml}${scrim ? scrimEl : ''}${dock}${panelEl}${status(F)}${homeBar(F)}`);
}

// ---------------------------------------------------------------- home
function nodes(F, o) {
  // levels 1..4 done (lime, small), level 5 current (periwinkle, large, halo); evenly spaced, none overlapping, none under the info card
  const s = F.s, pos = o.pos, out = [];
  let html = `<svg class="abs" style="left:0;top:0" width="${F.W}" height="${F.H}" viewBox="0 0 ${F.W} ${F.H}">
    <defs><linearGradient id="tr" x1="0" x2="1"><stop offset="0" stop-color="${K.limeMid}"/><stop offset="1" stop-color="${K.peri}"/></linearGradient></defs>
    <path d="M${pos[0].x} ${pos[0].y} C ${pos[1].x} ${pos[1].y - 10 * s}, ${pos[2].x} ${pos[2].y - 12 * s}, ${pos[3].x} ${pos[3].y} S ${pos[4].x - 10 * s} ${pos[4].y + 6 * s}, ${pos[4].x} ${pos[4].y}" fill="none" stroke="url(#tr)" stroke-width="${3.2 * s}" stroke-linecap="round" opacity=".9"/></svg>`;
  pos.forEach((p, i) => {
    const cur = i === 4, sz = (cur ? 58 : 38) * s;
    html += cur
      ? `<div class="abs" style="left:${p.x - 38 * s}px;top:${p.y - 38 * s}px;width:${76 * s}px;height:${76 * s}px;border-radius:${26 * s}px;background:rgba(168,180,249,.16);border:1px solid rgba(168,180,249,.25)"></div><div class="pill" style="left:${p.x - sz / 2}px;top:${p.y - sz / 2}px;width:${sz}px;height:${sz}px;border-radius:${sz * 0.34}px;background:linear-gradient(160deg,#B9C3FF,#8792F0);color:#0B1020;font:500 ${17 * s}px/1 SpaceGrotesk;box-shadow:0 12px 30px rgba(135,146,240,.45)">${i + 1}</div>`
      : `<div class="pill" style="left:${p.x - sz / 2}px;top:${p.y - sz / 2}px;width:${sz}px;height:${sz}px;border-radius:${sz * 0.34}px;background:linear-gradient(160deg,#E3FB7E,#CDEB4B);color:#0B1020;font:500 ${14 * s}px/1 SpaceGrotesk;box-shadow:0 8px 20px rgba(208,239,88,.28)">${i + 1}</div>`;
  });
  return html;
}
function homeScreen(W, H, o = {}) {
  const F = frame(W, H), s = F.s, full = o.proposals !== false, e = F.extra;
  const swirl = `<svg class="abs" style="left:${24.5 * s}px;top:${115 * s + e * 0.1}px;overflow:hidden;border-radius:${30 * s}px" width="${308 * s}" height="${(full ? 422 : 300) * s}" viewBox="0 0 308 ${full ? 422 : 300}"><g fill="none"><ellipse cx="60" cy="${full ? 262 : 210}" rx="170" ry="64" stroke="rgba(190,205,170,.14)" stroke-width="20" transform="rotate(-9 60 ${full ? 262 : 210})"/><ellipse cx="240" cy="${full ? 300 : 230}" rx="150" ry="80" stroke="rgba(120,132,225,.26)" stroke-width="24" transform="rotate(-14 240 ${full ? 300 : 230})"/></g></svg>`;
  const cardH = (full ? 422 : 300) * s;
  const cardTop = 115 * s + e * 0.1;
  const track = { x: (px) => 24.5 * s + px * s, y: (py) => cardTop + py * s };
  const pos = full
    ? [[58, 250], [110, 240], [162, 228], [214, 214], [262, 190]].map(([a, b]) => ({ x: track.x(a), y: track.y(b - 0) }))
    : [[58, 232], [110, 222], [162, 210], [214, 196], [262, 172]].map(([a, b]) => ({ x: track.x(a), y: track.y(b) }));
  const card = `<div class="glass" style="left:${24.5 * s}px;top:${cardTop}px;width:${308 * s}px;height:${cardH}px;border-radius:${30 * s}px"></div>${swirl}
   <div class="cap abs" style="left:${49 * s}px;top:${cardTop + 31 * s}px;font-size:${11 * s}px">YOLCULUK · 4 / 30</div>
   <div class="sg abs" style="left:${49 * s}px;top:${cardTop + 57 * s}px;font-size:${28 * s}px;font-weight:500;line-height:1.16;letter-spacing:-.005em">Sıradaki<br><span style="color:${K.lime}">döngüyü</span> çöz.</div>
   ${nodes(F, { pos })}`;
  const info = full ? `<div class="abs" style="left:${50 * s}px;top:${cardTop + 277 * s}px;width:${257 * s}px;height:${123 * s}px;border-radius:${24 * s}px;background:rgba(7,11,30,.78);border:1px solid rgba(255,255,255,.08)">
     <div class="abs" style="left:${16 * s}px;top:${22 * s}px;font:500 ${17 * s}px/1 SpaceGrotesk;color:${K.text}">Seviye 5</div>
     <div class="abs" style="left:${16 * s}px;top:${52 * s}px;font:500 ${11.5 * s}px/1.5 Manrope;color:${K.muted};width:${110 * s}px">Yeni mekanik ·<br>sütun kaydırma</div>
     ${[...'BULUT'].map((ch, i) => `<div class="tile" style="left:${(108 + i * 28) * s}px;top:${(55) * s}px;width:${23 * s}px;height:${23 * s}px;border-radius:${8 * s}px;font-size:${10.5 * s}px;box-shadow:0 3px 8px rgba(0,0,0,.35);position:absolute"><span>${ch}</span></div>`).join('')}</div>` : '';
  const ctaTop = full ? 554 * s + e * 0.1 + e * 0.35 : cardTop + cardH + 22 * s;
  const cta = `<div class="pill" style="left:${24 * s}px;top:${ctaTop}px;width:${309 * s}px;height:${63 * s}px;border-radius:${32 * s}px;justify-content:space-between;padding:0 ${23 * s}px;background:linear-gradient(180deg,#E4FB80,#D5F252);box-shadow:0 18px 50px rgba(208,239,88,.26);color:${K.limeInk};font:500 ${16 * s}px/1 Manrope">${full ? '5. bölüme devam' : 'Devam et'}${full ? I.upright(K.limeInk, 20 * s) : I.right(K.limeInk, 20 * s)}</div>
   ${full ? '' : `<div class="abs" style="left:0;width:${W}px;top:${ctaTop + 80 * s}px;text-align:center;font:500 ${14 * s}px/1 Manrope;color:${K.muted}">Seviye 5 · sürüyor</div>`}`;
  const chips = full ? `<div class="pill" style="left:${24 * s}px;top:${ctaTop + 77 * s}px;width:${149 * s}px;height:${49 * s}px;border-radius:${24 * s}px;gap:${11 * s}px;justify-content:flex-start;padding-left:${17 * s}px;background:rgba(255,255,255,.055);border:1px solid rgba(255,255,255,.05);font:500 ${14 * s}px/1 Manrope;color:#B4BBD8">${I.flame('#B4BBD8', 20 * s)}4 günlük seri</div>
   <div class="pill" style="left:${184 * s}px;top:${ctaTop + 77 * s}px;width:${149 * s}px;height:${49 * s}px;border-radius:${24 * s}px;gap:${11 * s}px;justify-content:flex-start;padding-left:${17 * s}px;background:rgba(255,255,255,.055);border:1px solid rgba(255,255,255,.05);font:500 ${14 * s}px/1 Manrope;color:#B4BBD8">${I.sparkle('#B4BBD8', 20 * s)}12 yıldız</div>` : '';
  const header = `<div class="abs sg" style="left:${25 * s}px;top:${58 * s}px;font-size:${25 * s}px;font-weight:500;line-height:1;letter-spacing:-.01em;color:${K.text}">loop<span style="color:${K.lime}">let</span></div>
   ${full ? `<div class="pill" style="left:${293 * s}px;top:${55 * s}px;width:${40 * s}px;height:${40 * s}px;border-radius:${15 * s}px;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.06)">${I.sliders(K.text, 20 * s)}</div>` : ''}`;
  return page(W, H, `${status(F)}${header}${card}${info}${cta}${chips}${homeBar(F)}`);
}

// ---------------------------------------------------------------- specimen
const lum = (hex) => { const n = parseInt(hex.slice(1), 16), f = (v) => { v /= 255; return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; }; return 0.2126 * f((n >> 16) & 255) + 0.7152 * f((n >> 8) & 255) + 0.0722 * f(n & 255); };
const cr = (a, b) => { const x = lum(a), y = lum(b), hi = Math.max(x, y), lo = Math.min(x, y); return ((hi + 0.05) / (lo + 0.05)).toFixed(1); };
function specimen() {
  const W = 786, H = 1180;
  const tiles = (word, size, cls = '') => [...word].map((ch) => `<div class="tile ${cls}" style="position:relative;display:inline-flex;margin:0 6px 6px 0;width:${size}px;height:${size}px;border-radius:${size * 0.33}px;font-size:${size * 0.38}px"><span>${ch}</span></div>`).join('');
  const rows = [['Ink on cream tile', K.ink, K.cream], ['Lime-ink on lime CTA', K.limeInk, '#DCF868'], ['Text on navy', K.text, '#0A1030'], ['Muted label (#AEB4CA) on navy', K.muted, '#0A1030'], ['Muted label (#AEB4CA) on glass card', K.muted, '#2A345A'], ['Lime on navy (emphasis word)', K.lime, '#DDFA6B' === '' ? '' : '#0A1030'], ['MEASURED in the reference: caption on glass card', '#AEB3C7', '#273155'], ['MEASURED in the reference: caption on chip', '#AEB3C7', '#2E353E'], ['MEASURED in the reference: label on stats card', '#ACB8C6', '#2B3D4C']];
  const table = rows.map(([n, a, b]) => `<tr><td>${n}</td><td><i style="display:inline-block;width:14px;height:14px;background:${a};border:1px solid #888;vertical-align:-2px"></i> ${a}</td><td><i style="display:inline-block;width:14px;height:14px;background:${b};border:1px solid #888;vertical-align:-2px"></i> ${b}</td><td><b>${cr(a, b)} : 1</b></td></tr>`).join('');
  return page(W, H, `<div class="abs" style="left:40px;top:34px;right:40px">
   <div class="cap">DIRECTION C — LOOP GLASS · TYPE, GLYPH, ICON AND CONTRAST SPECIMEN</div>
   <div style="margin-top:22px">${tiles('İIŞĞÇÖÜ', 62)}</div>
   <div class="cap" style="margin-top:4px;letter-spacing:.1em">Turkish capitals in tile context — İ  I  Ş  Ğ  Ç  Ö  Ü</div>
   <div style="margin-top:20px">${tiles('BULUT', 62)}&nbsp;&nbsp;${tiles('ÖZGÜR', 62)}</div>
   <div style="margin-top:6px">${tiles('ŞİŞE', 62)}&nbsp;&nbsp;${tiles('ÇÖZÜLDÜ', 46)}&nbsp;&nbsp;${tiles('MASAL', 46, 'lime')}</div>
   <div style="margin-top:26px;display:flex;gap:44px;align-items:flex-end">
    <div><div class="cap">HAMLE — tabular</div><div class="sg" style="font-size:52px;font-weight:500;margin-top:10px;font-variant-numeric:tabular-nums;line-height:1.05">0 1 1 1 1<br>8 8 8 8 8</div></div>
    <div><div class="cap">Heading (Space Grotesk 500)</div><div class="sg" style="font-size:40px;font-weight:500;margin-top:10px;line-height:1.1">Sıradaki <span style="color:${K.lime}">döngüyü</span> çöz.<br>Döngü tamamlandı.</div></div></div>
   <div style="margin-top:20px"><div class="cap">Body / label (Manrope 500–600)</div><div style="font:500 17px/1.5 Manrope;color:${K.muted};margin-top:8px">Hedef üç hamlede yerine oturdu. · YENİ EN İYİ · OPTİMAL · SEVİYE 05 — İ ve ı doğru: HARİKA, İLK, SEVİYE</div></div>
   <div style="margin-top:26px;display:flex;gap:26px;align-items:center" class="cap">ICONS<span style="display:flex;gap:16px">${['back', 'sliders', 'flame', 'sparkle', 'undo', 'restart', 'upright', 'right', 'lock', 'snow', 'updown'].map((k) => I[k](K.text, 28)).join('')}</span><span style="display:flex;gap:6px">${I.star(K.limeMid, 28, K.limeMid)}${I.star(K.limeMid, 28, K.limeMid)}${I.star('rgba(244,246,255,.55)', 28)}</span></div>
   <div class="cap" style="margin-top:34px;letter-spacing:.12em">CONTRAST — WCAG 2.x (computed from token hex values)</div>
   <table style="margin-top:12px;border-collapse:collapse;font:13px/1.9 Manrope;color:${K.text}"><tr style="text-align:left;opacity:.6"><th style="width:340px">Pair</th><th style="width:150px">Foreground</th><th style="width:150px">Background</th><th>Ratio</th></tr>${table}</table>
   <div style="margin-top:20px;font:13px/1.55 Manrope;color:${K.muted}">Families: Space Grotesk (variable 300–700) and Manrope (variable 200–800), both SIL OFL 1.1; tnum verified for both. Small-label colours were MEASURED from the reference pixels (brightest text pixel vs adjacent background: #AEB3C7–#B7BACE, 5.5–9.6 : 1) — the reference's labels are not a contrast weak spot; this direction uses #AEB4CA; small caps are 10.4–12.6 pt at 393 pt (the HAMLE card label is the smallest). Unsubsetted: Space Grotesk ≈ 133 KB, Manrope ≈ 161 KB.</div></div>`);
}

// ---------------------------------------------------------------- emit
const jobs = [];
const emit = (name, html, W, H, dsf = 2) => { fs.writeFileSync(path.join(OUT, name + '.html'), html); jobs.push(`${name} ${W} ${H}${dsf === 1 ? ' 1' : ''}`); };
const W = 393, H = 852;
emit('C-01-play-idle', playScreen(W, H, 'idle'), W, H);
emit('C-02-play-lifted-row', playScreen(W, H, 'lift'), W, H);
emit('C-02b-play-lifted-row-reference-literal', playScreen(W, H, 'lift', true), W, H);
emit('C-03-play-locked-frozen', playScreen(W, H, 'pieces'), W, H);
emit('C-04-won-perfect', wonScreen(W, H, 'perfect'), W, H);
emit('C-05-won-two-star', wonScreen(W, H, 'two'), W, H);
emit('C-04b-won-full-screen-reference-composition', completionFull(W, H, { word: 'BULUT', sub: 'Hedef üç hamlede yerine oturdu.', badge: 'HARİKA', n: 3 }), W, H);
emit('C-04c-won-reference-semantics', completionFull(W, H, { word: 'MASAL', refSemantics: true }), W, H);
emit('C-06-home-in-progress', homeScreen(W, H, { proposals: true }), W, H);
emit('C-06b-home-shipped-scope', homeScreen(W, H, { proposals: false }), W, H);
emit('C-07-tutorial-column', tutorialScreen(W, H), W, H);
emit('C-08-motion-t0-hold', wonScreen(W, H, 'perfect', 'hold'), W, H);
emit('C-09-motion-t600-glide', wonScreen(W, H, 'perfect', 'glide'), W, H);
emit('C-10-motion-t760-panel', wonScreen(W, H, 'perfect', 'panel'), W, H);
for (const [tag, w, h] of [['16e', 390, 844], ['promax', 440, 956]]) {
  emit(`C-v-${tag}-play-idle`, playScreen(w, h, 'idle'), w, h);
  emit(`C-v-${tag}-won-perfect`, wonScreen(w, h, 'perfect'), w, h);
}
// reference-frame renders (358x717 @2x = 716x1434, the reference images' size) for parity
emit('C-P1-home-ref-frame', homeScreen(358, 717, { proposals: true }), 358, 717);
emit('C-P2-play-ref-frame', playScreen(358, 717, 'refstate'), 358, 717);
emit('C-P3-completion-ref-frame', completionFull(358, 717, { word: 'MASAL', refSemantics: true }), 358, 717);
emit('C-90-specimen', specimen(), 786, 1180, 1);
fs.writeFileSync(path.join(OUT, 'jobs-c.txt'), jobs.join('\n') + '\n');
console.log(jobs.length + ' pages');
