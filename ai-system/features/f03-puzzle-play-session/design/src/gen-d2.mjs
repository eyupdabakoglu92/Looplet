// F03-UI-D2 — Design Adoption Phase D2: the won moment + the full-screen result (motion-critical).
// Derived from gen-d1.mjs (D1 Play: tokens, fonts, 358-pt reference geometry scaled by width, drawn icons, the D1 header /
// rail / board / HUD) and F00 gen-s.mjs (the selected-source result S-04 / S-05 and the transition prototype S-08…S-16).
// What is new here:
//  * the result as a FLOW column (so free text can grow): at 1.0x it reproduces the S-04 anchors; up to the 1.3x cap it
//    fits without scrolling; above the cap it scrolls under a fixed back button (C-9, architecture §20.3 (9));
//  * every §20.2 variant (C-4 markers / badge precedence, CTA weighting, no-optimal, Next not wired, level 30);
//  * the win sequence re-timed on the D1 board (D1 header, HAMLE card, no hint line, 44-pt restart), with special tiles in
//    the winning row (C-11), and the winning row at rows 0 / 2 / 4 from REAL, BFS-verified Journey solutions;
//  * the result -> Play retry transition (the answer row flies back into the goal rail) and every reduced path;
//  * a timeline self-check (?check=1) that asserts the §20.3 (1) bounds from the running animations.
// Usage: node gen-d2.mjs .   then   sh render-d1.sh D2- jobs-d2.txt   (headless Chrome, @2x -> ../<name>.png)
import fs from 'node:fs';
import path from 'node:path';
const OUT = process.argv[2] ?? '.';
const FONTS = '../../../f00-design-foundation/design/src/fonts';

// ---------------------------------------------------------------- content (real Journey levels, content/journey/tr)
const L4 = { level: 4, grid: ['BLÇIZ', 'MIENO', 'PÜLNG', 'BDERİ', 'ŞALKD'], target: 'BALIK', opt: 4 };
const L5 = { level: 5, grid: ['ZUÇEK', 'BÜOLŞ', 'HALUT', 'ÜRŞAG', 'DGGGŞ'], target: 'BULUT', opt: 3 };
const L26 = { level: 26, grid: ['TORBİ', 'ZYYOR', 'ÜYOZT', 'ÜROLL', 'LAHŞR'], target: 'TARİH', opt: 5, locked: ['0,0', '0,2'], frozen: ['2,2', '2,3'] };
const L30 = { level: 30, grid: ['ZÇŞŞN', 'IENRI', 'REMHH', 'ÜADHL', 'RKİOÇ'], target: 'ZEMİN', opt: 5, locked: ['0,0', '0,4'], frozen: ['2,3', '2,4'] };
// F02 shift rule (locked / frozen = pivots). Thaw is not modelled: every solution below needs no thaw.
function play(L, moves) {
  let g = L.grid.map((r) => [...r]);
  const pin = new Set([...(L.locked ?? []), ...(L.frozen ?? [])]);
  for (const m of moves.split(' ')) {
    const axis = m[0], idx = +m[1], fwd = m[2] === '+';
    const line = [0, 1, 2, 3, 4].map((i) => (axis === 'r' ? [idx, i] : [i, idx]));
    const pos = [0, 1, 2, 3, 4].filter((i) => !pin.has(line[i].join(',')));
    const letters = pos.map((p) => g[line[p][0]][line[p][1]]), k = pos.length, ng = g.map((r) => [...r]);
    pos.forEach((p, i) => { const src = fwd ? (i - 1 + k) % k : (i + 1) % k; const [r, c] = line[p]; ng[r][c] = letters[src]; });
    g = ng;
  }
  return g.map((r) => r.join(''));
}
function solved(L, moves, row) {
  const g = play(L, moves), n = moves.split(' ').length;
  if (g[row] !== L.target) throw new Error(`L${L.level} ${moves}: row ${row} is ${g[row]}, not ${L.target}`);
  if (n !== L.opt) throw new Error(`L${L.level}: ${n} moves, optimal ${L.opt}`);
  return { L, grid: g, row, moves: n, seq: moves };
}
// optimal solutions found by BFS over the shipped content (scratch solver; replayed and asserted here)
const WIN_R2 = solved(L5, 'c0+ c1+ c1+', 2);               // row 2, plain tiles
const WIN_R0 = solved(L26, 'r0- c1+ r4+ r4+ c4+', 0);      // row 0, two LOCKED tiles in the winning row (C-11)
const WIN_R4 = solved(L4, 'c0+ c3- r3+ c4+', 4);           // row 4, the longest glide
const WIN_L30 = solved(L30, 'c1- r4+ c2- c2- c3+', 0);     // level 30, locked Z and N in the winning row
// C-11 frozen case: no shipped level can hold a still-frozen tile inside the winning row (every frozen letter differs
// from the target letter in its column), so this one is SYNTHETIC — rule coverage for future content (e.g. Daily).
const WIN_FZ = { L: { level: 23, target: 'SOKAK', locked: [], frozen: ['1,1'] }, grid: ['DEÇSL', 'SOKAK', 'EÇMAR', 'MBZÖÖ', 'ÜDRAT'], row: 1, moves: 4, synthetic: true };
const label = (L) => `SEVİYE ${String(L.level).padStart(2, '0')}`;

// ---------------------------------------------------------------- tokens (identical to gen-d1.mjs / app/lib/design/tokens.dart)
const K = {
  lime: '#DDFA6B', limeMid: '#D0EF58', limeInk: '#0B1020', peri: '#A8B4F9', periLo: '#8792F0', ink: '#141826',
  text: '#F4F6FF', muted: '#AEB4CA', glassEdge: 'rgba(255,255,255,.10)',
};
const font = `
@font-face{font-family:'SpaceGrotesk';src:url('${FONTS}/SpaceGrotesk.ttf');font-weight:300 700}
@font-face{font-family:'Manrope';src:url('${FONTS}/Manrope.ttf');font-weight:200 800}`;
const ic = (d, c = K.text, s = 20, w = 1.7) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${c}" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round">${d}</svg>`;
const I = {
  back: (c, s) => ic('<path d="m15 5-7 7 7 7"/>', c, s, 1.9),
  sparkle: (c, s) => ic('<path d="M10 4.5 12 10l5.5 2-5.5 2-2 5.5-2-5.5-5.5-2 5.5-2Z"/><path d="M19 3.5v4M17 5.5h4"/>', c, s),
  undo: (c, s) => ic('<path d="M9 14 4 9l5-5"/><path d="M4 9h9.5a6.5 6.5 0 0 1 0 13H10"/>', c, s),
  restart: (c, s) => ic('<path d="M3.5 12a8.5 8.5 0 1 0 2.7-6.2L3.5 8.4"/><path d="M3.5 3.6v4.8h4.8"/>', c, s),
  lock: (c, s) => ic('<rect x="5" y="10.5" width="14" height="10" rx="2.6"/><path d="M8.5 10.5V8a3.5 3.5 0 0 1 7 0v2.5"/>', c, s, 1.9),
  snow: (c, s) => ic('<path d="M12 2.5v19M3.8 7.2l16.4 9.6M3.8 16.8 20.2 7.2"/><path d="m9.3 4.2 2.7 1.8 2.7-1.8M9.3 19.8l2.7-1.8 2.7 1.8"/>', c, s, 1.7),
  right: (c, s) => ic('<path d="M5 12h14"/><path d="m13 6 6 6-6 6"/>', c, s, 1.9),
  star: (c, s, fill = 'none') => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="${fill}" stroke="${c}" stroke-width="1.6" stroke-linejoin="round"><polygon points="12,2.2 14.8,8.8 22,9.5 16.6,14.2 18.2,21.2 12,17.5 5.8,21.2 7.4,14.2 2,9.5 9.2,8.8"/></svg>`,
};

// ---------------------------------------------------------------- frame + page (same ground as D1)
function frame(W, H) { const s = W / 358; const extra = Math.max(0, H - 717 * s); return { W, H, s, extra, e1: extra * 0.3, e2: extra * 0.7 }; }
function page(W, H, body, css = '') {
  return `<!doctype html><html><head><meta charset="utf-8"><style>${font}
*{box-sizing:border-box;margin:0;padding:0}html,body{width:${W}px;height:${H}px;overflow:hidden}
body{position:relative;font-family:'Manrope',sans-serif;color:${K.text};
 background:radial-gradient(75% 40% at 90% 6%,#2D3766 0%,rgba(45,55,102,0) 72%),radial-gradient(55% 26% at 0% 58%,rgba(26,88,96,.32),rgba(26,88,96,0) 72%),linear-gradient(#0A1030 0%,#070C25 55%,#050A1E 100%)}
.abs{position:absolute}.sg{font-family:'SpaceGrotesk',sans-serif}
.cap{font-family:'Manrope';font-weight:600;letter-spacing:.2em;color:${K.muted};line-height:1.3;white-space:nowrap}
.tile{position:absolute;display:flex;align-items:center;justify-content:center;font-family:'SpaceGrotesk';font-weight:500;line-height:1;color:${K.ink};
 background:linear-gradient(180deg,#FFFCF7,#F0E9DC);box-shadow:inset 0 1px 0 #fff,inset 0 -2px 0 rgba(120,100,70,.10),0 7px 16px rgba(2,4,16,.45),0 1px 0 rgba(0,0,0,.2)}
.tile.locked{background:linear-gradient(160deg,#4149A0,#2B3170);color:#F4F6FF;box-shadow:inset 0 0 0 1.5px rgba(168,180,249,.55),0 7px 16px rgba(2,4,16,.45)}
.tile.frozen{background:linear-gradient(160deg,#DFF1FB,#B5D6EC);color:${K.ink};box-shadow:inset 0 0 0 1.5px #7FB0D6,0 7px 16px rgba(2,4,16,.45);border:1.5px dashed rgba(60,110,155,.75)}
.pill{position:absolute;display:flex;align-items:center;justify-content:center}
.lime{background:linear-gradient(160deg,#E3FB7E,#CDEB4B);color:${K.limeInk};box-shadow:0 10px 26px rgba(208,239,88,.34),inset 0 1px 0 rgba(255,255,255,.45)}
${css}
</style></head><body>${body}</body></html>`;
}
const status = (F) => `<div class="abs" style="left:${25 * F.s}px;top:${15 * F.s}px;font:500 ${14.5 * F.s}px/1 Manrope;color:#fff;z-index:20">9:41</div>
<div class="abs" style="right:${25 * F.s}px;top:${17 * F.s}px;display:flex;gap:${5 * F.s}px;align-items:center;z-index:20"><svg width="${17 * F.s}" height="${11 * F.s}" viewBox="0 0 17 11" fill="#fff"><rect y="7" width="3" height="4" rx="1"/><rect x="4.7" y="4.5" width="3" height="6.5" rx="1"/><rect x="9.4" y="2" width="3" height="9" rx="1"/><rect x="14" width="3" height="11" rx="1"/></svg><svg width="${24 * F.s}" height="${11 * F.s}" viewBox="0 0 24 11" fill="none" stroke="#fff" stroke-width="1"><rect x=".5" y=".5" width="20" height="10" rx="3.2" opacity=".55"/><rect x="2" y="2" width="17" height="7" rx="1.8" fill="#fff" stroke="none"/></svg></div>
<div class="abs" style="left:${F.W / 2 - 47 * F.s}px;top:${10 * F.s}px;width:${94 * F.s}px;height:${28 * F.s}px;border-radius:${14 * F.s}px;background:#000;z-index:20"></div>`;
const homeBar = (F) => `<div class="abs" style="left:${F.W / 2 - 62 * F.s}px;bottom:${7 * F.s}px;width:${124 * F.s}px;height:${4.6 * F.s}px;border-radius:3px;background:rgba(255,255,255,.62);z-index:20"></div>`;

// ---------------------------------------------------------------- D1 Play pieces (unchanged D1 geometry: the starting frame)
function boardGeo(F) {
  const s = F.s, cw = 308.5 * s, x = (F.W - cw) / 2, pad = 11 * s, t = 52 * s, gap = 6.5 * s, top = 261.5 * s + F.e1;
  return { s, cw, x, pad, t, gap, stride: t + gap, top, ch: 307.5 * s };
}
const kindOf = (L, r, c) => (L.locked?.includes(`${r},${c}`) ? 'locked' : L.frozen?.includes(`${r},${c}`) ? 'frozen' : '');
const cornerIcon = (t, svg) => `<i class="ico" style="position:absolute;top:${t * 0.08}px;right:${t * 0.08}px;display:flex">${svg}</i>`;
const kindIcon = (kind, t) => (kind === 'locked' ? cornerIcon(t, I.lock('#F4F6FF', t * 0.27)) : kind === 'frozen' ? cornerIcon(t, I.snow('#3F78A8', t * 0.27)) : '');
function boardLayer(F, L, grid, skipRow = -1) {
  const B = boardGeo(F), { s, x, pad, t, stride, top, cw, ch } = B;
  let out = `<div class="abs" style="left:${x}px;top:${top}px;width:${cw}px;height:${ch}px;border-radius:${34 * s}px;background:linear-gradient(180deg,rgba(22,30,64,.86),rgba(9,14,36,.88));border:1px solid rgba(255,255,255,.09);box-shadow:0 26px 60px rgba(2,4,16,.4)"></div>
  <div class="abs" style="left:${x + cw / 2 - 72 * s}px;top:${top}px;width:${144 * s}px;height:${2 * s}px;background:linear-gradient(90deg,transparent,#8792F0,transparent)"></div>`;
  for (let r = 0; r < 5; r++) for (let c = 0; c < 5; c++) {
    if (r === skipRow) continue;
    const kind = kindOf(L, r, c);
    out += `<div class="tile ${kind}" style="left:${x + pad + c * stride}px;top:${top + pad + r * stride}px;width:${t}px;height:${t}px;border-radius:${t * 0.33}px;font-size:${t * 0.38}px"><span>${grid[r][c]}</span>${kindIcon(kind, t)}</div>`;
  }
  return out;
}
function playHeader(F, L, moves) {
  const s = F.s;
  return `<div class="abs" style="left:${25 * s}px;top:${96 * s}px;display:flex;align-items:center;gap:${6 * s}px">${I.back(K.muted, 20 * s)}<span class="cap" style="font-size:${11.5 * s}px">${label(L)}</span></div>
  <div class="pill" style="left:${273.5 * s}px;top:${75 * s}px;width:${60 * s}px;min-height:${63 * s}px;padding:${6 * s}px 0;border-radius:${22 * s}px;flex-direction:column;gap:${7 * s}px;background:linear-gradient(160deg,rgba(120,132,196,.34),rgba(70,80,140,.30));border:1px solid rgba(255,255,255,.09)"><span class="sg" style="font-size:${22 * s}px;font-weight:500;line-height:1;font-variant-numeric:tabular-nums">${moves}</span><span class="cap" style="font-size:${11 * s}px;letter-spacing:.14em;line-height:1">HAMLE</span></div>`;
}
const railGeo = (F) => { const s = F.s, w = 36 * s, g = 8 * s; return { w, g, h: 42 * s, x0: (F.W - (5 * w + 4 * g)) / 2, y: 197 * s + F.e1, r: 14 * s, fs: 16.5 * s }; };
function railCaption(F) { return `<div class="cap abs" style="left:0;width:${F.W}px;top:${172 * F.s + F.e1}px;text-align:center;font-size:${11.5 * F.s}px;line-height:1">HEDEF DÖNGÜ</div>`; }
function railTiles(F, word) {
  const R = railGeo(F);
  return [...word].map((ch, i) => `<div class="tile" style="left:${R.x0 + i * (R.w + R.g)}px;top:${R.y}px;width:${R.w}px;height:${R.h}px;border-radius:${R.r}px;font-size:${R.fs}px;color:${K.text};background:linear-gradient(180deg,#2B2B58,#242349);box-shadow:inset 0 0 0 1px rgba(150,160,235,.32),0 6px 14px rgba(2,4,16,.35)"><span>${ch}</span></div>`).join('');
}
const hudY = (F) => 592.5 * F.s + F.e1 + F.e2;
function hud(F, undoOn, quota = 3) {
  const s = F.s, y = hudY(F), rs = 44;
  const dot = (on) => `<i style="width:${5.5 * s}px;height:${5.5 * s}px;border-radius:50%;background:${on ? K.limeMid : 'rgba(208,239,88,.25)'};display:block"></i>`;
  return `<div class="pill" style="left:${29 * s}px;top:${y}px;width:${98.5 * s}px;height:${50 * s}px;border-radius:${22 * s}px;gap:${10 * s}px;background:rgba(255,255,255,.075);border:1px solid rgba(255,255,255,.07);opacity:${undoOn ? 1 : 0.55}">${I.undo(K.text, 21 * s)}<span style="display:flex;gap:${5 * s}px">${[0, 1, 2].map((i) => dot(i < quota)).join('')}</span></div>
  <div class="pill" style="left:${289 * s}px;top:${y + (50 * s - rs) / 2}px;width:${rs}px;height:${rs}px;border-radius:${17 * s}px;background:rgba(255,255,255,.075);border:1px solid rgba(255,255,255,.07)">${I.restart(K.text, 20 * s)}</div>`;
}

// ---------------------------------------------------------------- the full-screen result: variants (architecture §20.2, §20.3 (5)–(6), (10))
const SAY = ['sıfır', 'bir', 'iki', 'üç', 'dört', 'beş', 'altı', 'yedi', 'sekiz', 'dokuz', 'on'];
const subtitle = (n) => `Hedef ${SAY[n] ?? n} hamlede yerine oturdu.`;
const starsFor = (you, opt) => (you === opt ? 3 : you - opt <= 3 ? 2 : 1); // F04 AC1–AC3, AC9, AC10
// v: { word, you, opt, bestPrior (null = first clear), next: 'wired' | 'none' | 'terminal', unrated }
function variant(v) {
  if (v.unrated) return { ...v, badge: null, stars: 0, best: null, bestPerfect: false, outcome: null };
  const stars = starsFor(v.you, v.opt), perfect = stars === 3;
  const outcome = v.bestPrior == null ? 'firstClear' : v.you < v.bestPrior ? 'newBest' : v.you === v.bestPrior ? 'matchedBest' : 'noImprovement';
  const best = v.bestPrior == null ? v.you : Math.min(v.you, v.bestPrior);
  const badge = perfect ? 'HARİKA' : outcome === 'newBest' ? 'YENİ EN İYİ' : null; // C-4: HARİKA wins over a new best
  return { ...v, stars, perfect, outcome, best, bestPerfect: best === v.opt, badge };
}
function ctas(V) {
  const nextLabel = V.next === 'terminal' ? 'Yolculuğu tamamla' : 'Sonraki bölüm';
  const canNext = V.next !== 'none';
  if (V.perfect && canNext) return { primary: nextLabel, link: 'Tekrar oyna', linkDisabled: false };
  return { primary: 'Tekrar oyna', link: canNext ? nextLabel : 'Sonraki bölüm · yakında', linkDisabled: !canNext };
}
// Result geometry at the 358 reference, as a FLOW column. At 1.0x the anchors equal S-04: badge row 54 + .16e,
// headline 112 + .24e, subtitle 203 + .24e, answer tiles 258 + .4e, stars 349 + .4e, stats 392.5 + .4e, CTA 485 + .4e,
// link text 568 + .4e. Container text uses the 1.3x cap; free text (subtitle, CTA label, link) follows the OS scale.
const RG = (F) => { const s = F.s, e = F.extra; return {
  top: 54 * s + 0.16 * e, badgeH: 42 * s, headM: 16 * s + 0.08 * e, subM: 14.25 * s, tilesM: 38.3 * s + 0.16 * e,
  tw: 52.5 * s, th: 59 * s, tg: 6.5 * s, tr: 24 * s, tfs: 22 * s, starsM: 32 * s, starSz: 19 * s, statsM: 24.5 * s, statsH: 74 * s,
  ctaM: 18.5 * s, ctaH: 63.5 * s, linkM: 27.25 * s - 22, colX: 24 * s, colW: 309 * s,
  tilesY: 258 * s + 0.4 * e, tilesX0: (F.W - (5 * 52.5 * s + 4 * 6.5 * s)) / 2 }; };
function resultColumn(F, V, o = {}) {
  const s = F.s, G = RG(F), tx = o.tx ?? 1, cap = Math.min(tx, 1.3), C = ctas(V), cls = o.cls ?? {};
  const badge = V.badge ? `<div class="${cls.head ?? ''}" style="display:flex;justify-content:center;height:${G.badgeH}px"><div style="display:flex;align-items:center;gap:${7 * s}px;min-width:${112 * s}px;height:${42 * s}px;padding:0 ${16 * s}px;justify-content:center;border-radius:${21 * s}px;background:linear-gradient(160deg,rgba(150,180,50,.26),rgba(90,120,30,.24));border:1px solid rgba(208,239,88,.42)">${I.sparkle(K.limeMid, 18 * s)}<span class="cap" style="font-size:${11 * s * cap}px;color:${K.limeMid};letter-spacing:.14em;line-height:1">${V.badge}</span></div></div>` : `<div style="height:${G.badgeH}px"></div>`;
  const starsHtml = V.unrated
    ? `<div class="${cls.stars ?? ''}" style="margin-top:${G.starsM}px;min-height:${G.starSz}px;text-align:center;font:500 ${13 * s * tx}px/1.3 Manrope;color:${K.muted}">Bu bölüm puanlanamadı.</div>`
    : `<div class="${cls.stars ?? ''}" style="margin-top:${G.starsM}px;height:${G.starSz}px;display:flex;justify-content:center;gap:${14 * s}px">${[1, 2, 3].map((i) => `<span data-i="${i - 1}" style="position:relative;display:flex">${I.star('rgba(244,246,255,.55)', G.starSz)}${i <= V.stars ? `<span class="sf" style="position:absolute;inset:0;display:flex">${I.star(K.limeMid, G.starSz, K.limeMid)}</span>` : ''}</span>`).join('')}</div>`;
  const cell = (v, l) => `<div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:${9 * s}px"><span class="sg" style="font-size:${24 * s * cap}px;font-weight:500;line-height:1;font-variant-numeric:tabular-nums">${v}</span><span class="cap" style="font-size:${11 * s * cap}px;letter-spacing:.14em;line-height:1">${l}</span></div>`;
  const sep = `<span style="width:1px;height:${44 * s}px;background:rgba(255,255,255,.10)"></span>`;
  const bestV = V.best == null ? '—' : V.best + (V.bestPerfect ? `<sup style="font-size:.5em;color:${K.limeMid};margin-left:2px">★</sup>` : '');
  const stats = `<div class="${cls.stats ?? ''}" style="margin-top:${G.statsM}px;height:${G.statsH}px;border-radius:${26 * s}px;display:flex;align-items:center;padding:0 ${6 * s}px;background:linear-gradient(155deg,rgba(46,64,84,.58),rgba(17,25,40,.66));border:1px solid ${K.glassEdge};box-shadow:0 24px 60px rgba(2,4,16,.35),inset 0 1px 0 rgba(255,255,255,.07)">${cell(V.you, 'SEN')}${sep}${cell(V.unrated ? '—' : V.opt, 'OPTİMAL')}${sep}${cell(bestV, 'EN İYİ')}</div>`;
  const pressed = o.pressed === 'cta';
  const cta = `<div class="${cls.cta ?? ''}" style="margin-top:${G.ctaM}px;position:relative;min-height:${G.ctaH}px;border-radius:${32 * s}px;display:flex;align-items:center;justify-content:space-between;gap:${12 * s}px;padding:${12 * s}px ${23 * s}px;background:linear-gradient(180deg,#E2FB78,#D3F04F);box-shadow:0 14px 32px rgba(2,4,16,.5),inset 0 1px 0 rgba(255,255,255,.4);color:${K.limeInk};font:500 ${16 * s * tx}px/1.2 Manrope;${pressed ? 'transform:scale(.98);filter:brightness(.95);' : ''}"><span>${C.primary}</span><span style="display:flex;flex:none">${I.right(K.limeInk, 20 * s)}</span>${o.focus === 'cta' ? `<i style="position:absolute;inset:-4px;border-radius:${36 * s}px;box-shadow:0 0 0 2px ${K.peri}"></i>` : ''}</div>`;
  const link = `<div class="${cls.cta ?? ''}" style="margin-top:${G.linkM}px;min-height:44px;display:flex;align-items:center;justify-content:center;text-align:center;font:500 ${15.5 * s * tx}px/1.2 Manrope;color:${K.muted};${C.linkDisabled ? 'opacity:.45;' : ''}">${C.link}</div>`;
  const tileSlot = `<div class="${cls.tiles ?? ''}" id="slot" style="${o.hideTiles ? 'visibility:hidden;' : ''}margin-top:${G.tilesM}px;height:${G.th}px;display:flex;justify-content:center;gap:${G.tg}px">${[...V.word].map((ch) => `<div class="lime" style="position:relative;display:flex;align-items:center;justify-content:center;width:${G.tw}px;height:${G.th}px;border-radius:${G.tr}px;font:500 ${G.tfs * cap}px/1 SpaceGrotesk">${ch}</div>`).join('')}</div>`;
  return `<div id="col" class="abs ${o.colCls ?? ''}" style="left:${G.colX}px;top:${G.top}px;width:${G.colW}px;padding-bottom:${50}px">
    ${badge}
    <div class="sg ${cls.head ?? ''}" style="margin-top:${G.headM}px;text-align:center;font-size:${33 * s * cap}px;font-weight:500;line-height:1.13;letter-spacing:-.005em">Döngü<br>tamamlandı.</div>
    <div class="${cls.sub ?? ''}" style="margin-top:${G.subM}px;text-align:center;font:500 ${14.5 * s * tx}px/1.3 Manrope;color:${K.muted}">${subtitle(V.you)}</div>
    ${tileSlot}${starsHtml}${stats}${cta}${link}
  </div>`;
}
const radial = (F, cls = '') => { const G = RG(F); return `<div class="abs ${cls}" style="left:0;top:${G.tilesY + G.th / 2 - 120 * F.s}px;width:${F.W}px;height:${240 * F.s}px;background:radial-gradient(50% 50% at 50% 50%,rgba(208,239,88,.13),rgba(208,239,88,0) 72%)"></div>`; };
function backButton(F, o = {}) {
  const s = F.s;
  return `<div class="pill ${o.cls ?? ''}" style="left:${24 * s}px;top:${54 * s}px;width:44px;height:44px;border-radius:${15 * s}px;background:rgba(255,255,255,.075);border:1px solid rgba(255,255,255,.07);z-index:12">${I.back(K.text, 20 * s)}${o.focus ? `<i style="position:absolute;inset:0;border-radius:${15 * s}px;box-shadow:inset 0 0 0 2px ${K.peri}"></i>` : ''}</div>`;
}
// Above the cap the column scrolls under a fixed band: the ground fades in behind the back button once content passes under it.
const scrollBand = (F, on) => on ? `<div class="abs" style="left:0;top:0;width:${F.W}px;height:${54 * F.s + 44 + 14}px;background:linear-gradient(180deg,#0B1234 0%,#0B1234 78%,rgba(11,18,52,0) 100%);z-index:11"></div>` : '';
function resultScreen(W, H, V, o = {}) {
  const F = frame(W, H);
  const check = `<script>document.fonts.ready.then(function(){var sl=document.getElementById('slot').getBoundingClientRect(),col=document.getElementById('col').getBoundingClientRect();
    document.title=JSON.stringify({slotTop:+sl.top.toFixed(1),slotLeft:+sl.left.toFixed(1),colBottom:+col.bottom.toFixed(1),H:${H},overflow:+(col.bottom-${H}).toFixed(1)});});<\/script>`;
  const toEnd = o.scroll === 'END' ? `<script>document.fonts.ready.then(function(){var c=document.getElementById('col');c.style.top=(${H}-c.offsetHeight)+'px';});<\/script>` : '';
  return page(W, H, `${status(F)}${radial(F)}${scrollBand(F, !!o.scroll)}${backButton(F, { focus: o.focus === 'back' })}${resultColumn(F, V, o)}${homeBar(F)}${toEnd}${check}`);
}

// ---------------------------------------------------------------- the win sequence + board -> result transition (T0 = the solving settle)
// 0–210 the row fills lime L->R (30 ms stagger, 90 ms per tile, linear); special-tile icons and the frozen dashes go with it.
// 100–450 one bloom at the row (0 -> 1 -> .55). 0–200 board + chrome dim to 50 % (ease-out). NOTHING outside the board appears.
// 600–840 the answer row glides (as one unit) to the result slot, morphing 57.1² r33% -> 57.6×64.8 r24·s, glyph 21.7 -> 24.2.
// 600–720 board, bloom, header (back + level, HAMLE card), target rail, HUD fade 50 % -> 0 (ease-in) — gone before the
//         result's headline is visible, so the two layouts never double-expose.
// 680–920 the lime radial behind the row fades in. 700–860 back button, badge, headline fade + rise 12·s (ease-out).
// 740–900 subtitle. 780–940 stars (outline) + stats card. 820–940 CTA + link. REST = 940 (input unlocks).
// 940–1300 earned stars pop (140 ms each, 110 ms apart) — a rest-state reveal, input already live.
// Reduced motion: row lime + static at T0 (icons already gone), board + chrome at 50 % at T0 (a state, not a motion);
// hold to 300; 300–460 board, chrome and board row cross-fade out while the result row + radial cross-fade in (linear);
// 460–660 the rest of the result fades in (linear); stars static (filled); REST = 660.
const EASE = 'cubic-bezier(.22,1,.36,1)';
function winPage(W, H, win, V, T = null, rm = false, standalone = false, check = false) {
  const F = frame(W, H), s = F.s, B = boardGeo(F), G = RG(F), L = win.L;
  const rowY = B.top + B.pad + win.row * B.stride;
  const kf = [];
  const rowTiles = [...L.target].map((ch, i) => {
    const kind = kindOf(L, win.row, i);
    const l0 = B.x + B.pad + i * B.stride, l1 = G.tilesX0 + i * (G.tw + G.tg);
    kf.push(`@keyframes mv${i}{from{left:${l0}px;top:${rowY}px;width:${B.t}px;height:${B.t}px;border-radius:${B.t * 0.33}px;font-size:${B.t * 0.38}px}to{left:${l1}px;top:${G.tilesY}px;width:${G.tw}px;height:${G.th}px;border-radius:${G.tr}px;font-size:${G.tfs}px}}`);
    return `<div class="rt rt${i}" data-l1="${l1}" style="left:${l0}px;top:${rowY}px;width:${B.t}px;height:${B.t}px;border-radius:${B.t * 0.33}px;font-size:${B.t * 0.38}px">
      <div class="tile base ${kind}" style="left:0;top:0;width:100%;height:100%;border-radius:inherit;font-size:inherit"><span>${ch}</span>${kindIcon(kind, B.t)}</div>
      <div class="limeov lime" style="animation-delay:${i * 30}ms"><span>${ch}</span></div></div>`;
  }).join('');
  const css = `${kf.join('\n')}
@keyframes fillL{from{opacity:0}to{opacity:1}}@keyframes dim{from{opacity:1}to{opacity:.5}}@keyframes out{from{opacity:.5}to{opacity:0}}
@keyframes outAll{from{opacity:1}to{opacity:0}}@keyframes fadeIn{from{opacity:0}to{opacity:1}}
@keyframes rise{from{opacity:0;transform:translateY(${12 * s}px)}to{opacity:1;transform:none}}
@keyframes starIn{0%{opacity:0;transform:scale(.6)}60%{opacity:1;transform:scale(1.18)}100%{opacity:1;transform:scale(1)}}
@keyframes bloom{0%{opacity:0}40%{opacity:1}100%{opacity:.55}}@keyframes bloomOut{from{opacity:.55}to{opacity:0}}
.rt{position:absolute;z-index:6;display:flex;align-items:center;justify-content:center;font-family:SpaceGrotesk;font-weight:500}
.rt .base{position:absolute;inset:0}
.rt .limeov{position:absolute;inset:0;border-radius:inherit;display:flex;align-items:center;justify-content:center;opacity:0;animation:fillL 90ms linear both}
${[0, 1, 2, 3, 4].map((i) => `.rt${i}{animation:mv${i} 240ms ${EASE} 600ms both}`).join('')}
.bl,.chrome{animation:dim 200ms ease-out both,out 120ms ease-in 600ms forwards}
.bloom{position:absolute;left:${B.x}px;top:${rowY - 22 * s}px;width:${B.cw}px;height:${B.t + 44 * s}px;background:radial-gradient(50% 60% at 50% 50%,rgba(208,239,88,.30),rgba(208,239,88,0) 70%);opacity:0;z-index:5;animation:bloom 350ms ease-out 100ms both,bloomOut 120ms ease-in 600ms forwards}
.rad{opacity:0;animation:fadeIn 240ms ease 680ms both}
.res{opacity:0}
.hd{animation:rise 160ms ease-out 700ms both}.sb{animation:rise 160ms ease-out 740ms both}
.st,.ss{animation:rise 160ms ease-out 780ms both}.ct{animation:rise 120ms ease-out 820ms both}
.bk{animation:fadeIn 160ms ease-out 700ms both}
.tl{visibility:hidden}
.sf{opacity:0;animation:starIn 140ms ease-out both}[data-i="0"] .sf{animation-delay:940ms}[data-i="1"] .sf{animation-delay:1050ms}[data-i="2"] .sf{animation-delay:1160ms}
html.rm .rt .limeov{animation:none;opacity:1}
html.rm .rt{animation:outAll 160ms linear 300ms both !important}
html.rm .tl{visibility:visible;opacity:0;animation:fadeIn 160ms linear 300ms both}
html.rm .bl,html.rm .chrome{animation:dim 1ms linear both,out 160ms linear 300ms forwards}
html.rm .bloom{animation:none;opacity:0}html.rm .rad{animation:fadeIn 160ms linear 300ms both}
html.rm .hd,html.rm .sb,html.rm .st,html.rm .ss,html.rm .ct,html.rm .bk{animation:fadeIn 200ms linear 460ms both}
html.rm .sf{animation:none;opacity:1}`;
  const cls = { head: 'res hd', sub: 'res sb', stars: 'res st', stats: 'res ss', cta: 'res ct', tiles: 'tl' };
  const chrome = `${playHeader(F, L, win.moves)}${railCaption(F)}${railTiles(F, L.target)}${hud(F, true, 3)}`;
  const body = `${status(F)}<div class="chrome">${chrome}</div><div class="bl">${boardLayer(F, L, win.grid, win.row)}</div><div class="bloom"></div>
  ${radial(F, 'rad res')}${backButton(F, { cls: 'res bk' })}${resultColumn(F, { ...V, word: L.target }, { cls })}${rowTiles}${homeBar(F)}`;
  return finish(W, H, body, css, T, rm, standalone, check, 'win');
}

// ---------------------------------------------------------------- result -> Play ("Tekrar oyna", architecture §20.3 (7)); T0 = the tap
// 0–140 result content, back button and lime radial fade out + drop 8·s (ease-in); the row's glow goes with them.
// 0–300 the answer row flies back INTO THE GOAL RAIL: each tile glides to its rail slot (36×42·s, r14·s), fill cross-fades
//       lime -> rail indigo and the glyph lime-ink -> white (100–300); at 300 it IS the rail.
// 160–360 Play arrives on the restarted grid: header (back + level, HAMLE 0), caption, board card rising 10·s, HUD (undo
//       disabled, quota full) — opacity 0 -> 1 ease-out. REST = 360 (<= 400, input unlocks).
// Reduced: a sequential dip — 0–80 the result (row included, it does not travel) fades out, 80–160 Play fades in (linear);
// no frame shows both layouts at once. REST = 160.
function retryPage(W, H, L, V, T = null, rm = false, standalone = false, check = false) {
  const F = frame(W, H), s = F.s, G = RG(F), R = railGeo(F);
  const kf = [];
  const flying = [...L.target].map((ch, i) => {
    const l0 = G.tilesX0 + i * (G.tw + G.tg), l1 = R.x0 + i * (R.w + R.g);
    kf.push(`@keyframes fly${i}{from{left:${l0}px;top:${G.tilesY}px;width:${G.tw}px;height:${G.th}px;border-radius:${G.tr}px;font-size:${G.tfs}px}to{left:${l1}px;top:${R.y}px;width:${R.w}px;height:${R.h}px;border-radius:${R.r}px;font-size:${R.fs}px}}`);
    return `<div class="fl fl${i}" style="left:${l0}px;top:${G.tilesY}px;width:${G.tw}px;height:${G.th}px;border-radius:${G.tr}px;font-size:${G.tfs}px">
      <div class="railf" style="position:absolute;inset:0;border-radius:inherit;background:linear-gradient(180deg,#2B2B58,#242349);box-shadow:inset 0 0 0 1px rgba(150,160,235,.32),0 6px 14px rgba(2,4,16,.35);display:flex;align-items:center;justify-content:center;color:${K.text}"><span>${ch}</span></div>
      <div class="limef lime" style="position:absolute;inset:0;border-radius:inherit;display:flex;align-items:center;justify-content:center"><span>${ch}</span></div></div>`;
  }).join('');
  const css = `${kf.join('\n')}
@keyframes outDrop{from{opacity:1;transform:none}to{opacity:0;transform:translateY(${8 * s}px)}}@keyframes outAll{from{opacity:1}to{opacity:0}}
@keyframes inAll{from{opacity:0}to{opacity:1}}@keyframes inRise{from{opacity:0;transform:translateY(${10 * s}px)}to{opacity:1;transform:none}}
.fl{position:absolute;z-index:6;font-family:SpaceGrotesk;font-weight:500}
${[0, 1, 2, 3, 4].map((i) => `.fl${i}{animation:fly${i} 300ms ${EASE} both}`).join('')}
.limef{animation:outAll 200ms linear 100ms both}.limef{box-shadow:0 10px 26px rgba(208,239,88,.34)}
.rcol,.rbk,.rrad{animation:outDrop 140ms ease-in both}
.pin{opacity:0;animation:inAll 200ms ease-out 160ms both}.pbd{opacity:0;animation:inRise 200ms ease-out 160ms both}
.rail{opacity:0;animation:inAll 1ms linear 300ms both}
html.rm .fl{animation:outAll 80ms linear both !important}
html.rm .limef{animation:none}
html.rm .rcol,html.rm .rbk,html.rm .rrad{animation:outAll 80ms linear both}
html.rm .pin,html.rm .pbd,html.rm .rail{animation:inAll 80ms linear 80ms both}`;
  const G2 = { ...V, word: L.target };
  const col = resultColumn(F, G2, { hideTiles: true, colCls: 'rcol' });
  const body = `${status(F)}
  <div class="rrad">${radial(F)}</div><div class="rbk">${backButton(F)}</div>${col}
  <div class="pin">${playHeader(F, L, 0)}${railCaption(F)}</div><div class="rail">${railTiles(F, L.target)}</div>
  <div class="pbd">${boardLayer(F, L, L.grid)}</div><div class="pin">${hud(F, false, 3)}</div>${flying}${homeBar(F)}`;
  return finish(W, H, body, css, T, rm, standalone, check, 'retry');
}

// ---------------------------------------------------------------- common: freeze (?t=), reduced (?rm=1), self-check (?check=1), standalone bar
function finish(W, H, body, css, T, rm, standalone, check, kind) {
  const js = `<script>${T !== null ? `window.__T=${T};` : ''}${rm ? 'document.documentElement.classList.add("rm");' : ''}${check ? 'window.__CHECK=1;' : ''}
  (function(){var q=new URLSearchParams(location.search);if(q.get('rm'))document.documentElement.classList.add('rm');
  var T=(window.__T!==undefined)?window.__T:(q.get('t')!==null?+q.get('t'):null);
  if(T!==null){document.getAnimations().forEach(function(a){a.pause();a.currentTime=T;});}
  if(window.__CHECK||q.get('check')){document.fonts.ready.then(function(){
    var an=document.getAnimations();an.forEach(function(a){a.pause();});
    var seek=function(t){an.forEach(function(a){a.currentTime=t;});};
    var outBoard=function(){var r=[].slice.call(document.querySelectorAll('.res,.tl'));var m=0;r.forEach(function(e){var o=+getComputedStyle(e).opacity;if(getComputedStyle(e).visibility!=='hidden')m=Math.max(m,o);});return m;};
    var restNoStars=0,restAll=0;an.forEach(function(a){var t=a.effect.getComputedTiming();var end=t.endTime;var star=a.effect.target&&a.effect.target.classList&&a.effect.target.classList.contains('sf');if(!star)restNoStars=Math.max(restNoStars,end);restAll=Math.max(restAll,end);});
    var res={kind:'${kind}',reduced:document.documentElement.classList.contains('rm'),restMs:Math.round(restNoStars),endWithStarsMs:Math.round(restAll)};
    if('${kind}'==='win'){var first=-1;for(var t=0;t<1000;t+=5){seek(t);if(outBoard()>0.01){first=t;break;}}res.firstResultVisibleMs=first;var maxBefore=0;for(var t=0;t<600;t+=5){seek(t);maxBefore=Math.max(maxBefore,outBoard());}res.maxResultOpacityBefore600=+maxBefore.toFixed(3);
      var card=document.querySelector('.bl > div').getBoundingClientRect();var inside=true;for(var t=0;t<600;t+=5){seek(t);document.querySelectorAll('.rt').forEach(function(e){if(getComputedStyle(e).opacity==='0')return;var r=e.getBoundingClientRect();if(r.left<card.left-0.5||r.right>card.right+0.5||r.top<card.top-0.5||r.bottom>card.bottom+0.5)inside=false;});}res.rowInsideBoardBefore600=inside;
      seek(res.restMs);var sl=document.querySelector('#slot > div').getBoundingClientRect();var r0=document.querySelector('.rt0').getBoundingClientRect();res.rowOnSlotAtRestPx=+Math.max(Math.abs(sl.left-r0.left),Math.abs(sl.top-r0.top)).toFixed(2);}
    document.title=JSON.stringify(res);});}
  })();<\/script>`;
  let html = page(W, H, body + js, css);
  if (standalone) html = html.replace(`html,body{width:${W}px;height:${H}px;overflow:hidden}`, `html,body{width:${W}px;height:${H}px;overflow:hidden}html{background:#1b1c22}body{margin:0 auto}`)
    .replace('</body>', `<div style="position:fixed;left:12px;top:12px;font:600 13px/1.6 Manrope;color:#cfd3e6;background:rgba(0,0,0,.6);padding:8px 12px;border-radius:10px;z-index:99;max-width:260px">F03 D2 hareket prototipi<br><a href="D2-motion-prototype.html" style="color:#DDFA6B">kazanma · satır 2</a> · <a href="D2-motion-prototype-row0.html" style="color:#DDFA6B">satır 0 (kilitli)</a> · <a href="D2-motion-prototype-row4.html" style="color:#DDFA6B">satır 4</a> · <a href="D2-motion-prototype-frozen.html" style="color:#DDFA6B">donmuş (sentetik)</a> · <a href="D2-motion-prototype-retry.html" style="color:#DDFA6B">Tekrar oyna</a><br><a href="?rm=1" style="color:#DDFA6B">azaltılmış hareket</a> · <a href="?" style="color:#DDFA6B">yeniden oynat</a> · <a href="?t=720" style="color:#DDFA6B">720 ms kare</a> · <a href="?check=1" style="color:#DDFA6B">zaman testi (sekme başlığı)</a></div></body>`);
  return html;
}

// ---------------------------------------------------------------- contrast (sRGB, WCAG) — composited on the lightest ground the element can sit on
const hex = (h) => { const n = parseInt(h.slice(1), 16); return [(n >> 16) & 255, (n >> 8) & 255, n & 255]; };
const over = (fg, a, bg) => fg.map((v, i) => Math.round(v * a + bg[i] * (1 - a)));
const lum = (c) => { const f = (v) => { v /= 255; return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; }; return 0.2126 * f(c[0]) + 0.7152 * f(c[1]) + 0.0722 * f(c[2]); };
const cr = (a, b) => { const x = lum(a), y = lum(b); return +((Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05)).toFixed(1); };
function contrast() {
  const gTop = hex('#2D3766'), gMid = hex('#0E1638'), gLow = hex('#070C25'); // top-light peak, headline band, lower screen
  const slate = over([46, 64, 84], 0.58, gLow), badge = over([150, 180, 50], 0.26, gMid), backG = over([255, 255, 255], 0.075, gTop);
  return [
    ['headline #F4F6FF on the ground (headline band)', cr(hex('#F4F6FF'), gMid)],
    ['subtitle #AEB4CA on the ground (headline band)', cr(hex('#AEB4CA'), gMid)],
    ['badge label #D0EF58 on the olive glass', cr(hex('#D0EF58'), badge)],
    ['answer glyph #0B1020 on lime (darker stop #CDEB4B)', cr(hex('#0B1020'), hex('#CDEB4B'))],
    ['stat value #F4F6FF on slate glass', cr(hex('#F4F6FF'), slate)],
    ['stat label #AEB4CA on slate glass', cr(hex('#AEB4CA'), slate)],
    ['CTA label #0B1020 on the lime pill (#D3F04F)', cr(hex('#0B1020'), hex('#D3F04F'))],
    ['link #AEB4CA on the lower ground', cr(hex('#AEB4CA'), gLow)],
    ['link disabled (45 %) on the lower ground — exempt, informational', cr(over(hex('#AEB4CA'), 0.45, gLow), gLow)],
    ['"Bu bölüm puanlanamadı." #AEB4CA on the ground', cr(hex('#AEB4CA'), gLow)],
    ['back icon #F4F6FF on the back glass (top-light peak)', cr(hex('#F4F6FF'), backG)],
    ['earned star #D0EF58 on the ground (graphical)', cr(hex('#D0EF58'), gLow)],
    ['empty star outline 55 % #F4F6FF on the ground (graphical)', cr(over(hex('#F4F6FF'), 0.55, gLow), gLow)],
    ['best-is-perfect ★ #D0EF58 on slate', cr(hex('#D0EF58'), slate)],
  ];
}

// ---------------------------------------------------------------- emit
const jobs = [];
const emit = (name, html, W, H) => { fs.writeFileSync(path.join(OUT, name + '.html'), html); jobs.push(`${name} ${W} ${H}`); };
const W = 393, H = 852;
const B5 = (you, bestPrior, next = 'wired') => variant({ word: 'BULUT', you, opt: 3, bestPrior, next });
const VAR = {
  perfect: B5(3, null),                 // Perfect, first clear          → HARİKA, primary Next
  perfectNewBest: B5(3, 5),             // Perfect + new best            → HARİKA (wins), primary Next
  newBest: B5(5, 6),                    // new best, 2★                  → YENİ EN İYİ, primary Retry
  firstClear: B5(4, null),              // first clear, 2★ (İLK dropped) → no badge
  matched: B5(5, 5),                    // matched best, 2★              → no badge
  noImprove: B5(8, 4),                  // 1★, worse than best (daha iyi dropped) → no badge, best 4 retained
  unrated: variant({ word: 'BULUT', you: 3, opt: null, next: 'none', unrated: true }),  // defensive no-optimal (debug only)
  notWired: B5(3, null, 'none'),        // Perfect but no Next handler   → primary Retry, link "· yakında"
  l30: variant({ word: 'ZEMİN', you: 5, opt: 5, bestPrior: null, next: 'terminal' }),
  l30two: variant({ word: 'ZEMİN', you: 7, opt: 5, bestPrior: null, next: 'terminal' }),
};
emit('D2-01-result-perfect', resultScreen(W, H, VAR.perfect), W, H);
emit('D2-02-result-perfect-new-best', resultScreen(W, H, VAR.perfectNewBest), W, H);
emit('D2-03-result-new-best-2star', resultScreen(W, H, VAR.newBest), W, H);
emit('D2-04-result-first-clear-2star', resultScreen(W, H, VAR.firstClear), W, H);
emit('D2-05-result-matched-best', resultScreen(W, H, VAR.matched), W, H);
emit('D2-06-result-1star-no-improvement', resultScreen(W, H, VAR.noImprove), W, H);
emit('D2-07-result-no-optimal', resultScreen(W, H, VAR.unrated), W, H);
emit('D2-08-result-next-not-wired', resultScreen(W, H, VAR.notWired), W, H);
emit('D2-09-result-level30-perfect', resultScreen(W, H, VAR.l30), W, H);
emit('D2-09b-result-level30-2star', resultScreen(W, H, VAR.l30two), W, H);
emit('D2-10-result-text-cap-1_3', resultScreen(W, H, VAR.newBest, { tx: 1.3 }), W, H);
emit('D2-10b-result-ax5-top', resultScreen(W, H, VAR.newBest, { tx: 3.12 }), W, H);
emit('D2-10c-result-ax5-scrolled-end', resultScreen(W, H, VAR.newBest, { tx: 3.12, scroll: 'END' }), W, H);
emit('D2-11-result-focus-back', resultScreen(W, H, VAR.firstClear, { focus: 'back' }), W, H);
emit('D2-12-result-cta-pressed', resultScreen(W, H, VAR.firstClear, { pressed: 'cta' }), W, H);
emit('D2-v-16e-result-perfect', resultScreen(390, 844, VAR.perfect), 390, 844);
emit('D2-v-16e-result-1star', resultScreen(390, 844, VAR.noImprove), 390, 844);
emit('D2-v-16e-result-text-cap-1_3', resultScreen(390, 844, VAR.newBest, { tx: 1.3 }), 390, 844);
emit('D2-v-16e-result-ax5-top', resultScreen(390, 844, VAR.newBest, { tx: 3.12 }), 390, 844);
emit('D2-v-promax-result-perfect-new-best', resultScreen(440, 956, VAR.perfectNewBest), 440, 956);
emit('D2-v-promax-result-text-cap-1_3', resultScreen(440, 956, VAR.newBest, { tx: 1.3 }), 440, 956);
// motion stills, all taken from the prototype pages (the prototype files are D2-motion-prototype*.html)
const pad4 = (t) => String(t).padStart(4, '0');
for (const t of [0, 60, 210, 450, 599, 680, 760, 840, 940, 1300]) emit(`D2-M-r2-t${pad4(t)}`, winPage(W, H, WIN_R2, VAR.perfect, t), W, H);
for (const t of [0, 60, 210, 720, 940]) emit(`D2-M-r0-locked-t${pad4(t)}`, winPage(W, H, WIN_R0, variant({ word: 'TARİH', you: 5, opt: 5, bestPrior: null, next: 'wired' }), t), W, H);
for (const t of [210, 599, 720, 840, 940]) emit(`D2-M-r4-t${pad4(t)}`, winPage(W, H, WIN_R4, variant({ word: 'BALIK', you: 4, opt: 4, bestPrior: null, next: 'wired' }), t), W, H);
for (const t of [0, 60, 210]) emit(`D2-M-frozen-synthetic-t${pad4(t)}`, winPage(W, H, WIN_FZ, variant({ word: 'SOKAK', you: 4, opt: 4, bestPrior: null, next: 'wired' }), t), W, H);
for (const t of [0, 300, 380, 560, 660]) emit(`D2-M-r2-reduced-t${pad4(t)}`, winPage(W, H, WIN_R2, VAR.perfect, t, true), W, H);
for (const t of [0, 120, 220, 300, 360]) emit(`D2-M-retry-t${pad4(t)}`, retryPage(W, H, L5, VAR.firstClear, t), W, H);
emit('D2-M-retry-reduced-t0080', retryPage(W, H, L5, VAR.firstClear, 80, true), W, H);
emit('D2-v-16e-M-r4-t0720', winPage(390, 844, WIN_R4, variant({ word: 'BALIK', you: 4, opt: 4, bestPrior: null, next: 'wired' }), 720), 390, 844);
emit('D2-v-promax-M-r0-t0720', winPage(440, 956, WIN_R0, variant({ word: 'TARİH', you: 5, opt: 5, bestPrior: null, next: 'wired' }), 720), 440, 956);
emit('D2-v-16e-M-level30-r0-t0210', winPage(390, 844, WIN_L30, VAR.l30, 210), 390, 844);
// executable prototypes (+ self-check pages)
const proto = [
  ['D2-motion-prototype', () => winPage(W, H, WIN_R2, VAR.perfect, null, false, true)],
  ['D2-motion-prototype-row0', () => winPage(W, H, WIN_R0, variant({ word: 'TARİH', you: 5, opt: 5, bestPrior: null, next: 'wired' }), null, false, true)],
  ['D2-motion-prototype-row4', () => winPage(W, H, WIN_R4, variant({ word: 'BALIK', you: 4, opt: 4, bestPrior: null, next: 'wired' }), null, false, true)],
  ['D2-motion-prototype-frozen', () => winPage(W, H, WIN_FZ, variant({ word: 'SOKAK', you: 4, opt: 4, bestPrior: null, next: 'wired' }), null, false, true)],
  ['D2-motion-prototype-retry', () => retryPage(W, H, L5, VAR.firstClear, null, false, true)],
];
for (const [n, f] of proto) fs.writeFileSync(path.join(OUT, n + '.html'), f());
const checks = [
  ['D2-check-win-r2', winPage(W, H, WIN_R2, VAR.perfect, null, false, false, true)],
  ['D2-check-win-r0', winPage(W, H, WIN_R0, variant({ word: 'TARİH', you: 5, opt: 5, bestPrior: null, next: 'wired' }), null, false, false, true)],
  ['D2-check-win-r4', winPage(W, H, WIN_R4, variant({ word: 'BALIK', you: 4, opt: 4, bestPrior: null, next: 'wired' }), null, false, false, true)],
  ['D2-check-win-r4-16e', winPage(390, 844, WIN_R4, variant({ word: 'BALIK', you: 4, opt: 4, bestPrior: null, next: 'wired' }), null, false, false, true)],
  ['D2-check-win-r2-reduced', winPage(W, H, WIN_R2, VAR.perfect, null, true, false, true)],
  ['D2-check-retry', retryPage(W, H, L5, VAR.firstClear, null, false, false, true)],
  ['D2-check-retry-reduced', retryPage(W, H, L5, VAR.firstClear, null, true, false, true)],
];
for (const [n, h] of checks) fs.writeFileSync(path.join(OUT, n + '.html'), h);
fs.writeFileSync(path.join(OUT, 'jobs-d2.txt'), jobs.join('\n') + '\n');
console.log(JSON.stringify({ WIN_R2: WIN_R2.grid, WIN_R0: WIN_R0.grid, WIN_R4: WIN_R4.grid, WIN_L30: WIN_L30.grid }));
console.log(contrast().map(([k, v]) => `${v.toFixed(1)} : 1  ${k}`).join('\n'));
console.log(`${jobs.length} pages`);
