// F03-UI-D1 — Design Adoption Phase D1: "Loop Glass" Play (existing-parity with the Selected Foundation).
// Derived from F00 design/src/gen-s.mjs (same tokens, fonts, 358-pt reference geometry scaled by width, drawn icons).
// Adds the D1 states that had no render: column drag, undo quota states, restart pressed, the level label bound to
// the level, L26 locked+frozen "today", the thaw (L23 SOKAK, 180 ms cross-fade), the load error, the tutorial with
// the HUD kept (C-5), the ghost hidden during a drag, OS text at the 1.3x cap (C-9), device variants, and an
// executable motion prototype (lift / shift settle / thaw / tutorial ghost; ?rm=1 reduced motion, ?t=<ms> frozen frame).
// Usage: node gen-d1.mjs .   then   sh render-d1.sh        (headless Chrome, @2x → ../<name>.png)
import fs from 'node:fs';
import path from 'node:path';
const OUT = process.argv[2] ?? '.';
const FONTS = '../../../f00-design-foundation/design/src/fonts';

// ---------------------------------------------------------------- content (real Journey levels; grids derived by the engine rule below)
const L4 = { level: 4, grid: ['BLÇIZ', 'MIENO', 'PÜLNG', 'BDERİ', 'ŞALKD'], target: 'BALIK' };
const L5 = { level: 5, grid: ['ZUÇEK', 'BÜOLŞ', 'HALUT', 'ÜRŞAG', 'DGGGŞ'], target: 'BULUT' };
const L23 = { level: 23, grid: ['DEÇSL', 'ORAKS', 'ESAÇK', 'MBZÖÖ', 'ÜDRAT'], target: 'SOKAK', frozen: ['2,1'] };
const L26 = { level: 26, grid: ['TORBİ', 'ZYYOR', 'ÜYOZT', 'ÜROLL', 'LAHŞR'], target: 'TARİH', locked: ['0,0', '0,2'], frozen: ['2,2', '2,3'] };

// F02 shift rule: locked / still-frozen cells are pivots; the movable letters of the line rotate one step.
function sim(L, moves) {
  let g = L.grid.map((r) => [...r]);
  const locked = new Set(L.locked ?? []), frozen = new Set(L.frozen ?? []);
  const movable = (r, c) => !locked.has(`${r},${c}`) && !frozen.has(`${r},${c}`);
  for (const m of moves) {
    const axis = m[0], idx = +m[1], fwd = m[2] === '+';
    const line = [0, 1, 2, 3, 4].map((i) => (axis === 'r' ? [idx, i] : [i, idx]));
    const pos = [0, 1, 2, 3, 4].filter((i) => movable(...line[i]));
    const letters = pos.map((p) => g[line[p][0]][line[p][1]]);
    const k = pos.length, ng = g.map((r) => [...r]);
    pos.forEach((p, i) => { const src = fwd ? (i - 1 + k) % k : (i + 1) % k; const [r, c] = line[p]; ng[r][c] = letters[src]; });
    g = ng;
  }
  const out = g.map((r) => r.join(''));
  if (out.includes(L.target)) throw new Error(`illustrative state must not be a win: ${out}`);
  return out;
}
const L23_THAW = sim(L23, ['r1+', 'c3+', 'c4-', 'c4-']); // row 2 becomes E·SAAT → "SAAT" (≥ 4 letters) thaws (2,1)
const label = (L) => `SEVİYE ${String(L.level).padStart(2, '0')}`;

// ---------------------------------------------------------------- tokens (identical to F00 gen-s.mjs / app/lib/design/tokens.dart)
const K = {
  lime: '#DDFA6B', limeMid: '#D0EF58', limeInk: '#0B1020',
  peri: '#A8B4F9', periLo: '#8792F0', ink: '#141826',
  text: '#F4F6FF', muted: '#AEB4CA', glassEdge: 'rgba(255,255,255,.10)',
};
const font = `
@font-face{font-family:'SpaceGrotesk';src:url('${FONTS}/SpaceGrotesk.ttf');font-weight:300 700}
@font-face{font-family:'Manrope';src:url('${FONTS}/Manrope.ttf');font-weight:200 800}`;

// ---------------------------------------------------------------- icons: thin rounded outline (F00 set) + one addition for D1 (loopBreak)
const ic = (d, c = K.text, s = 20, w = 1.7) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${c}" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round">${d}</svg>`;
const I = {
  back: (c, s) => ic('<path d="m15 5-7 7 7 7"/>', c, s, 1.9),
  sparkle: (c, s) => ic('<path d="M10 4.5 12 10l5.5 2-5.5 2-2 5.5-2-5.5-5.5-2 5.5-2Z"/><path d="M19 3.5v4M17 5.5h4"/>', c, s),
  undo: (c, s) => ic('<path d="M9 14 4 9l5-5"/><path d="M4 9h9.5a6.5 6.5 0 0 1 0 13H10"/>', c, s),
  restart: (c, s) => ic('<path d="M3.5 12a8.5 8.5 0 1 0 2.7-6.2L3.5 8.4"/><path d="M3.5 3.6v4.8h4.8"/>', c, s),
  lock: (c, s) => ic('<rect x="5" y="10.5" width="14" height="10" rx="2.6"/><path d="M8.5 10.5V8a3.5 3.5 0 0 1 7 0v2.5"/>', c, s, 1.9),
  snow: (c, s) => ic('<path d="M12 2.5v19M3.8 7.2l16.4 9.6M3.8 16.8 20.2 7.2"/><path d="m9.3 4.2 2.7 1.8 2.7-1.8M9.3 19.8l2.7-1.8 2.7 1.8"/>', c, s, 1.7),
  updown: (c, s) => ic('<path d="m7.5 9.5 4.5-4.5 4.5 4.5M7.5 14.5l4.5 4.5 4.5-4.5"/>', c, s, 1.9),
  // NEW (D1): the loop that did not close — an open ring (gap at 10°–60°) with an exclamation; replaces Material error_outline.
  loopBreak: (c, s) => ic('<path d="M16.25 4.64A8.5 8.5 0 1 0 20.37 10.52"/><path d="M12 8.3v4.4"/><path d="M12 15.9h.01" stroke-width="2.6"/>', c, s, 1.8),
};

// ---------------------------------------------------------------- frame + page
function frame(W, H) { const s = W / 358; const extra = Math.max(0, H - 717 * s); return { W, H, s, extra, e1: extra * 0.3, e2: extra * 0.7 }; }
function page(W, H, body, css = '') {
  return `<!doctype html><html><head><meta charset="utf-8"><style>${font}
*{box-sizing:border-box;margin:0;padding:0}html,body{width:${W}px;height:${H}px;overflow:hidden}
body{position:relative;font-family:'Manrope',sans-serif;color:${K.text};
 background:radial-gradient(75% 40% at 90% 6%,#2D3766 0%,rgba(45,55,102,0) 72%),radial-gradient(55% 26% at 0% 58%,rgba(26,88,96,.32),rgba(26,88,96,0) 72%),linear-gradient(#0A1030 0%,#070C25 55%,#050A1E 100%)}
.abs{position:absolute}.sg{font-family:'SpaceGrotesk',sans-serif}
.cap{font-family:'Manrope';font-weight:600;letter-spacing:.2em;text-transform:none;color:${K.muted};line-height:1.3;white-space:nowrap}
.glass{position:absolute;background:linear-gradient(155deg,rgba(60,74,134,.50),rgba(22,30,64,.58));border:1px solid ${K.glassEdge};box-shadow:0 24px 60px rgba(2,4,16,.35),inset 0 1px 0 rgba(255,255,255,.07)}
.tile{position:absolute;display:flex;align-items:center;justify-content:center;font-family:'SpaceGrotesk';font-weight:500;line-height:1;color:${K.ink};
 background:linear-gradient(180deg,#FFFCF7,#F0E9DC);box-shadow:inset 0 1px 0 #fff,inset 0 -2px 0 rgba(120,100,70,.10),0 7px 16px rgba(2,4,16,.45),0 1px 0 rgba(0,0,0,.2)}
.tile.locked{background:linear-gradient(160deg,#4149A0,#2B3170);color:#F4F6FF;box-shadow:inset 0 0 0 1.5px rgba(168,180,249,.55),0 7px 16px rgba(2,4,16,.45)}
.tile.frozen{background:linear-gradient(160deg,#DFF1FB,#B5D6EC);color:${K.ink};box-shadow:inset 0 0 0 1.5px #7FB0D6,0 7px 16px rgba(2,4,16,.45);border:1.5px dashed rgba(60,110,155,.75)}
.tile.lift{background:linear-gradient(180deg,#FFFFFF,#F3EEE4);box-shadow:0 0 0 2px ${K.peri},0 0 26px rgba(168,180,249,.6),0 16px 26px rgba(2,4,16,.55)}
.tile.ghost{opacity:.3;box-shadow:none}
.pill{position:absolute;display:flex;align-items:center;justify-content:center}
${css}
</style></head><body>${body}</body></html>`;
}
const status = (F) => `<div class="abs" style="left:${25 * F.s}px;top:${15 * F.s}px;font:500 ${14.5 * F.s}px/1 Manrope;color:#fff">9:41</div>
<div class="abs" style="right:${25 * F.s}px;top:${17 * F.s}px;display:flex;gap:${5 * F.s}px;align-items:center"><svg width="${17 * F.s}" height="${11 * F.s}" viewBox="0 0 17 11" fill="#fff"><rect y="7" width="3" height="4" rx="1"/><rect x="4.7" y="4.5" width="3" height="6.5" rx="1"/><rect x="9.4" y="2" width="3" height="9" rx="1"/><rect x="14" width="3" height="11" rx="1"/></svg><svg width="${24 * F.s}" height="${11 * F.s}" viewBox="0 0 24 11" fill="none" stroke="#fff" stroke-width="1"><rect x=".5" y=".5" width="20" height="10" rx="3.2" opacity=".55"/><rect x="2" y="2" width="17" height="7" rx="1.8" fill="#fff" stroke="none"/></svg></div>
<div class="abs" style="left:${F.W / 2 - 47 * F.s}px;top:${10 * F.s}px;width:${94 * F.s}px;height:${28 * F.s}px;border-radius:${14 * F.s}px;background:#000"></div>`;
const homeBar = (F) => `<div class="abs" style="left:${F.W / 2 - 62 * F.s}px;bottom:${7 * F.s}px;width:${124 * F.s}px;height:${4.6 * F.s}px;border-radius:3px;background:rgba(255,255,255,.62)"></div>`;

// ---------------------------------------------------------------- board: card + tiles. o: grid, locked, frozen, liftRow, liftCol, thaw {cell, t}, tx (text cap)
function boardGeo(F) {
  const s = F.s, cw = 308.5 * s, x = (F.W - cw) / 2, pad = 11 * s, t = 52 * s, gap = 6.5 * s, top = 261.5 * s + F.e1;
  return { s, cw, x, pad, t, gap, stride: t + gap, top, ch: 307.5 * s };
}
function tileHtml(B, o, r, c, dx = 0, dy = 0, extra = '') {
  const { s, x, pad, t, stride, top } = B, key = `${r},${c}`, tx = o.tx ?? 1;
  let kind = '';
  if (o.locked?.includes(key)) kind = 'locked';
  else if (o.frozen?.includes(key)) kind = 'frozen';
  const lifted = o.liftRow === r || o.liftCol === c;
  if (lifted) kind = (kind ? kind + ' ' : '') + 'lift';
  const dim = (o.liftRow != null || o.liftCol != null) && !lifted ? 'opacity:.42;' : '';
  const glyph = t * 0.38 * tx;
  const left = x + pad + c * stride + dx, topPx = top + pad + r * stride + dy;
  const base = `left:${left}px;top:${topPx}px;width:${t}px;height:${t}px;border-radius:${t * 0.33}px;font-size:${glyph}px;${dim}`;
  const iconSize = t * 0.27;
  const cornerIcon = (svg, op = 1, sc = 1) => `<i style="position:absolute;top:${t * 0.08}px;right:${t * 0.08}px;display:flex;opacity:${op};transform:scale(${sc});transform-origin:center">${svg}</i>`;
  const cls = ['tile', kind, extra].filter(Boolean).join(' ');
  const icon = kind.includes('locked') ? cornerIcon(I.lock('#F4F6FF', iconSize)) : kind.includes('frozen') ? cornerIcon(I.snow('#3F78A8', iconSize)) : '';
  return `<div class="${cls}" style="${base}"><span>${o.grid[r][c]}</span>${icon}</div>`;
}
function board(F, o) {
  const B = boardGeo(F), { s, x, pad, t, stride, top, cw, ch } = B;
  let out = `<div class="abs" style="left:${x}px;top:${top}px;width:${cw}px;height:${ch}px;border-radius:${34 * s}px;background:linear-gradient(180deg,rgba(22,30,64,.86),rgba(9,14,36,.88));border:1px solid rgba(255,255,255,.09);box-shadow:0 26px 60px rgba(2,4,16,.4)"></div>
  <div class="abs" style="left:${x + cw / 2 - 72 * s}px;top:${top}px;width:${144 * s}px;height:${2 * s}px;background:linear-gradient(90deg,transparent,#8792F0,transparent)"></div>`;
  for (let r = 0; r < 5; r++) for (let c = 0; c < 5; c++) {
    if (o.liftRow === r || o.liftCol === c) continue;
    out += tileHtml(B, o, r, c);
  }
  const clip = (inner, cl, ct, cwid, chei) => `<div class="abs" style="left:${cl}px;top:${ct}px;width:${cwid}px;height:${chei}px;overflow:hidden">${inner
    .replace(/left:(-?[\d.]+)px/g, (m, v) => `left:${(parseFloat(v) - cl).toFixed(2)}px`)
    .replace(/top:(-?[\d.]+)px/g, (m, v) => `top:${(parseFloat(v) - ct).toFixed(2)}px`)}</div>`;
  const rail = (l, tp, w, h) => `<div class="abs" style="left:${l}px;top:${tp}px;width:${w}px;height:${h}px;border-radius:2px;background:${K.peri};box-shadow:0 0 14px ${K.peri}"></div>`;
  if (o.liftRow != null) { // row dragged right by 0.55 stride; wrap ghost enters on the left; rails at the card's side edges
    const r = o.liftRow, dx = Math.round(stride * 0.55);
    let inner = ''; for (let c = 0; c < 5; c++) inner += tileHtml(B, o, r, c, dx);
    inner += tileHtml(B, { ...o, liftRow: r }, r, 4, dx - 5 * stride, 0, 'ghost');
    out += clip(inner, x + pad - 5 * s, 0, cw - 2 * pad + 10 * s, F.H);
    const ry = top + pad + r * stride;
    out += rail(x - 1, ry + 8 * s, 3 * s, t - 16 * s) + rail(x + cw - 2 * s, ry + 8 * s, 3 * s, t - 16 * s);
  }
  if (o.liftCol != null) { // column dragged down by 0.55 stride; wrap ghost enters at the top; rails at the card's top/bottom edges
    const c = o.liftCol, dy = Math.round(stride * 0.55);
    let inner = ''; for (let r = 0; r < 5; r++) inner += tileHtml(B, o, r, c, 0, dy);
    inner += tileHtml(B, { ...o, liftCol: c }, 4, c, 0, dy - 5 * stride, 'ghost');
    out += clip(inner, 0, top + pad - 5 * s, F.W, ch - 2 * pad + 10 * s);
    const cx = x + pad + c * stride;
    out += rail(cx + 8 * s, top - 1, t - 16 * s, 3 * s) + rail(cx + 8 * s, top + ch - 2 * s, t - 16 * s, 3 * s);
  }
  return out;
}

// ---------------------------------------------------------------- chrome: header (back + level label, HAMLE card), target rail, HUD
function topBar(F, o) {
  const s = F.s, tx = o.tx ?? 1;
  const lab = o.label === false ? '' : `<span class="cap" style="font-size:${11.5 * s * tx}px">${o.label}</span>`;
  const moves = o.moves == null ? '' : `<div class="pill" style="left:${273.5 * s}px;top:${75 * s}px;width:${60 * s}px;min-height:${63 * s}px;padding:${6 * s}px 0;border-radius:${22 * s}px;flex-direction:column;gap:${7 * s}px;background:linear-gradient(160deg,rgba(120,132,196,.34),rgba(70,80,140,.30));border:1px solid rgba(255,255,255,.09)"><span class="sg" style="font-size:${22 * s * tx}px;font-weight:500;line-height:1;font-variant-numeric:tabular-nums">${o.moves}</span><span class="cap" style="font-size:${11 * s * tx}px;letter-spacing:.14em;line-height:1">HAMLE</span></div>`;
  // the back affordance: a 44-pt hit box around chevron + label (drawn only as a guide in the annotated variant)
  return `<div class="abs" style="left:${25 * s}px;top:${96 * s}px;display:flex;align-items:center;gap:${6 * s}px">${I.back(K.muted, 20 * s)}${lab}</div>${moves}`;
}
function targetRail(F, word, tx = 1) {
  const s = F.s, w = 36 * s, g = 8 * s, x0 = (F.W - (5 * w + 4 * g)) / 2, y = 197 * s + F.e1;
  let t = `<div class="cap abs" style="left:0;width:${F.W}px;top:${172 * s + F.e1}px;text-align:center;font-size:${11.5 * s * tx}px;line-height:1">HEDEF DÖNGÜ</div>`;
  for (let i = 0; i < 5; i++) t += `<div class="tile" style="left:${x0 + i * (w + g)}px;top:${y}px;width:${w}px;height:${42 * s}px;border-radius:${14 * s}px;font-size:${16.5 * s * tx}px;color:${K.text};background:linear-gradient(180deg,#2B2B58,#242349);box-shadow:inset 0 0 0 1px rgba(150,160,235,.32),0 6px 14px rgba(2,4,16,.35)"><span>${word[i]}</span></div>`;
  return t;
}
const hudY = (F) => 592.5 * F.s + F.e1 + F.e2;
function hud(F, o) {
  const s = F.s, y = hudY(F), quota = o.quota ?? 3;
  const dot = (on) => `<i style="width:${5.5 * s}px;height:${5.5 * s}px;border-radius:50%;background:${on ? K.limeMid : 'rgba(208,239,88,.25)'};display:block"></i>`;
  const dots = [0, 1, 2].map((i) => dot(i < quota)).join('');
  const undoOp = o.undoOn ? 1 : 0.55;
  const pressed = o.restartPressed;
  const rs = 44; // GlassIconButton: 44-pt edge at every width
  const ring = (r) => `<i style="position:absolute;inset:0;border-radius:${r}px;box-shadow:inset 0 0 0 2px ${K.peri}"></i>`; // _Pressable focus ring (foreground, no layout shift)
  return `<div class="pill" style="left:${29 * s}px;top:${y}px;width:${98.5 * s}px;height:${50 * s}px;border-radius:${22 * s}px;gap:${10 * s}px;background:rgba(255,255,255,.075);border:1px solid rgba(255,255,255,.07);opacity:${undoOp}">${I.undo(K.text, 21 * s)}<span style="display:flex;gap:${5 * s}px">${dots}</span>${o.focus === 'undo' ? ring(22 * s) : ''}</div>
  <div class="pill" style="left:${289 * s}px;top:${y + (50 * s - rs) / 2}px;width:${rs}px;height:${rs}px;border-radius:${17 * s}px;background:${pressed ? 'rgba(255,255,255,.14)' : 'rgba(255,255,255,.075)'};border:1px solid ${pressed ? 'rgba(255,255,255,.18)' : 'rgba(255,255,255,.07)'};transform:scale(${pressed ? 0.98 : 1})">${I.restart(K.text, 20 * s)}${o.focus === 'restart' ? ring(17 * s) : ''}</div>`;
}

// ---------------------------------------------------------------- screens
function playScreen(W, H, o) {
  const F = frame(W, H), tx = o.tx ?? 1;
  return page(W, H, `${status(F)}${topBar(F, { label: label(o.L), moves: o.moves, tx })}${targetRail(F, o.L.target, tx)}${board(F, { grid: o.grid ?? o.L.grid, locked: o.L.locked, frozen: o.L.frozen, liftRow: o.liftRow, liftCol: o.liftCol, thaw: o.thaw, tx })}${hud(F, { undoOn: o.undoOn, quota: o.quota, restartPressed: o.restartPressed, focus: o.focus })}${o.overlay ? o.overlay(F) : ''}${homeBar(F)}`);
}
// tutorial overlay (C-5): ghost ring on the tutorial cell with drawn up/down chevrons; the hint pill sits ABOVE the HUD
function tutorialOverlay(ghost, tx = 1) {
  return (F) => {
    const s = F.s, B = boardGeo(F);
    const cx = B.x + B.pad + 2 * B.stride + B.t / 2, cy = B.top + B.pad + 2 * B.stride + B.t / 2;
    const g = ghost ? `<div class="abs" style="left:${cx - 24 * s}px;top:${cy - 24 * s}px;width:${48 * s}px;height:${48 * s}px;border-radius:50%;background:rgba(168,180,249,.28);box-shadow:0 0 0 1.5px ${K.peri},0 0 26px rgba(168,180,249,.6)"></div><div class="abs" style="left:${cx - 12 * s}px;top:${cy - 66 * s}px">${I.updown(K.peri, 24 * s)}</div>` : '';
    const gapTop = B.top + B.ch, gapH = hudY(F) - gapTop;
    const showIcon = tx <= 1.15;
    const pill = `<div class="abs" style="left:0;top:${gapTop}px;width:${F.W}px;height:${gapH}px;display:flex;align-items:center;justify-content:center">
      <div style="width:${300 * s}px;border-radius:${20 * s}px;background:linear-gradient(155deg,rgba(60,74,134,.50),rgba(22,30,64,.58));border:1px solid ${K.glassEdge};box-shadow:0 12px 30px rgba(2,4,16,.35),inset 0 1px 0 rgba(255,255,255,.07);display:flex;align-items:center;gap:${10 * s}px;padding:${7 * s}px ${16 * s}px;font:500 ${13 * s * tx}px/1.2 Manrope;color:${K.text}">${showIcon ? `<span style="display:flex;flex:none">${I.sparkle(K.limeMid, 20 * s)}</span>` : ''}<span>Sütunları da kaydırabilirsin — yukarı ya da aşağı.</span></div></div>`;
    return g + pill;
  };
}
// loading (F03 `_LoadingBoard`): the board card at its final geometry with 25 glass skeleton cells; header back + level
// label (known from the route args); no rail, HAMLE card or HUD until the puzzle resolves (no layout jump when it does).
function loadingScreen(W, H, L) {
  const F = frame(W, H), B = boardGeo(F), s = F.s;
  let cells = '';
  for (let r = 0; r < 5; r++) for (let c = 0; c < 5; c++) cells += `<div class="abs" style="left:${B.x + B.pad + c * B.stride}px;top:${B.top + B.pad + r * B.stride}px;width:${B.t}px;height:${B.t}px;border-radius:${B.t * 0.33}px;background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.07)"></div>`;
  const card = `<div class="abs" style="left:${B.x}px;top:${B.top}px;width:${B.cw}px;height:${B.ch}px;border-radius:${34 * s}px;background:linear-gradient(180deg,rgba(22,30,64,.86),rgba(9,14,36,.88));border:1px solid rgba(255,255,255,.09);box-shadow:0 26px 60px rgba(2,4,16,.4)"></div>`;
  return page(W, H, `${status(F)}${topBar(F, { label: label(L) })}${card}${cells}${homeBar(F)}`);
}
// load error (F03 `_LoadErrorBody`): the Foundation's recovery pattern (F00 ui-design §8) — ground, glass card, Space Grotesk
// headline, one primary pill. Card + pill form one column, centred between the header band and the home indicator
// (free text: it may grow with the OS scale and the column scrolls if it ever exceeds the screen).
function loadErrorScreen(W, H, L) {
  const F = frame(W, H), s = F.s, bandTop = 140 * s, bandBottom = H - 40 * s;
  const body = `${status(F)}<div class="abs" style="left:${25 * s}px;top:${96 * s}px;display:flex">${I.back(K.muted, 20 * s)}</div>
  <div class="abs" style="left:${24.5 * s}px;top:${bandTop}px;width:${309 * s}px;height:${bandBottom - bandTop}px;display:flex;flex-direction:column;justify-content:center;gap:${24 * s}px">
    <div style="position:relative;border-radius:${30 * s}px;padding:${28 * s}px ${26 * s}px ${32 * s}px;background:linear-gradient(155deg,rgba(60,74,134,.50),rgba(22,30,64,.58));border:1px solid ${K.glassEdge};box-shadow:0 24px 60px rgba(2,4,16,.35),inset 0 1px 0 rgba(255,255,255,.07)">
      <div style="display:flex;justify-content:space-between;align-items:flex-start">
        <span class="cap" style="font-size:${11.5 * s}px;padding-top:${4 * s}px">${label(L)}</span>
        <span style="display:flex;opacity:.9">${I.loopBreak(K.peri, 44 * s)}</span>
      </div>
      <div class="sg" style="margin-top:${18 * s}px;font-size:${28 * s}px;font-weight:500;line-height:1.16;letter-spacing:-.005em;max-width:${230 * s}px">Bu bulmaca yüklenemedi.</div>
    </div>
    <div style="display:flex;align-items:center;min-height:${63 * s}px;border-radius:999px;background:linear-gradient(180deg,#E2FB78,#D3F04F);box-shadow:0 14px 32px rgba(2,4,16,.5);padding:0 ${23 * s}px;font:500 ${16 * s}px/1.2 Manrope;color:${K.limeInk}">Ana ekrana dön</div>
  </div>
  ${homeBar(F)}`;
  return page(W, H, body);
}

// ---------------------------------------------------------------- motion prototype (lift / shift settle, thaw, tutorial ghost)
// Timelines (ms). lift: 0 touch-down → rim + dim + rails fade in 90 ms; 90–600 the finger drags the row right to 0.55 stride;
// 600 release → the row settles to one stride in 190 ms cubic-bezier(.22,1,.36,1) with a ≤ 1.5 % overshoot; 790 HAMLE +1;
// 790–880 rim/dim/rails fade out. thaw: T0 = the settle that forms "SAAT"; 0–180 the frozen treatment cross-fades to the
// normal tile, the snowflake shrinks away. ghost: 0–1200 the ring travels up 0.45 stride and back (ease-in-out, loops);
// 1500 touch-down → the ghost fades out in 120 ms; the column follows the finger; 2100 release → the hint pill fades
// out in 160 ms (tutorial acknowledged). Reduced motion (?rm=1): rim/dim/rails switch instantly, no overshoot, the shift
// keeps its 190 ms ease-out (it is state feedback), the thaw switches at T0, the ghost is static.
function prototype(W, H, demo, T = null, rm = false, standalone = false) {
  const F = frame(W, H), s = F.s, B = boardGeo(F), stride = B.stride;
  let body = '', css = '';
  if (demo === 'lift') {
    const grid = sim(L5, ['r1+']), r = 2, rowTop = B.top + B.pad + r * B.stride;
    // static board without row 2; the moving row as one strip; the rest wrapped in .rest for the dim
    let rest = ''; for (let rr = 0; rr < 5; rr++) if (rr !== r) for (let c = 0; c < 5; c++) rest += tileHtml(B, { grid }, rr, c);
    let strip = ''; for (let c = -1; c < 5; c++) {
      const cc = (c + 5) % 5, left = B.x + B.pad + c * stride;
      strip += `<div class="tile mv ${c < 0 ? 'wrapg' : ''}" style="left:${left - (B.x + B.pad - 5 * s)}px;top:0;width:${B.t}px;height:${B.t}px;border-radius:${B.t * 0.33}px;font-size:${B.t * 0.38}px"><span>${grid[r][cc]}</span></div>`;
    }
    body = `${status(F)}${topBar(F, { label: label(L5), moves: '<span style="position:relative;display:inline-block"><span class="mc0">1</span><span class="mc1" style="position:absolute;left:0;top:0;opacity:0">2</span></span>' })}${targetRail(F, L5.target)}${board(F, { grid: ['     ', '     ', '     ', '     ', '     '] }).replace(/<div class="tile[^>]*><span> <\/span><\/div>/g, '')}
      <div class="rest">${rest}</div>
      <div class="abs" style="left:${B.x + B.pad - 5 * s}px;top:${rowTop - 12 * s}px;width:${B.cw - 2 * B.pad + 10 * s}px;height:${B.t + 24 * s}px;overflow:hidden"><div class="strip" style="position:absolute;left:0;top:${12 * s}px;width:100%;height:${B.t}px">${strip}</div></div>
      <div class="rail" style="left:${B.x - 1}px;top:${rowTop + 8 * s}px;width:${3 * s}px;height:${B.t - 16 * s}px"></div><div class="rail" style="left:${B.x + B.cw - 2 * s}px;top:${rowTop + 8 * s}px;width:${3 * s}px;height:${B.t - 16 * s}px"></div>
      ${hud(F, { undoOn: true, quota: 3 })}${homeBar(F)}`;
    const d1 = stride * 0.55, d2 = stride;
    css = `.rail{position:absolute;border-radius:2px;background:${K.peri};box-shadow:0 0 14px ${K.peri};opacity:0;animation:railIn 90ms ease-out both,railOut 90ms ease-in 790ms forwards}
.rest{animation:dimIn 90ms ease-out both,dimOut 90ms ease-in 790ms forwards}
.strip{animation:track 510ms cubic-bezier(.4,0,.6,1) 90ms both,settle 190ms cubic-bezier(.22,1,.36,1) 600ms forwards}
.tile.mv{transition:none;animation:rimIn 90ms ease-out both,rimOut 90ms ease-in 790ms forwards}
.wrapg{opacity:.3}.tile.mv.wrapg{animation:rimIn 90ms ease-out both,rimOut 90ms ease-in 790ms forwards,ghostUp 190ms cubic-bezier(.22,1,.36,1) 600ms forwards}
@keyframes ghostUp{from{opacity:.3}to{opacity:1}}
html.rm .tile.mv.wrapg{animation:rimIn 1ms linear both,rimOut 1ms linear 790ms forwards,ghostUp 190ms ease-out 600ms forwards}
.mc0{animation:hideOp 1ms linear 790ms forwards}.mc1{animation:showOp 1ms linear 790ms forwards}
@keyframes hideOp{to{opacity:0}}@keyframes showOp{to{opacity:1}}
@keyframes railIn{from{opacity:0}to{opacity:1}}@keyframes railOut{from{opacity:1}to{opacity:0}}
@keyframes dimIn{from{opacity:1}to{opacity:.42}}@keyframes dimOut{from{opacity:.42}to{opacity:1}}
@keyframes track{from{transform:translateX(0)}to{transform:translateX(${d1}px)}}
@keyframes settle{0%{transform:translateX(${d1}px)}80%{transform:translateX(${d2 * 1.015}px)}100%{transform:translateX(${d2}px)}}
@keyframes rimIn{from{box-shadow:inset 0 1px 0 #fff,0 7px 16px rgba(2,4,16,.45)}to{box-shadow:0 0 0 2px ${K.peri},0 0 26px rgba(168,180,249,.6),0 16px 26px rgba(2,4,16,.55)}}
@keyframes rimOut{from{box-shadow:0 0 0 2px ${K.peri},0 0 26px rgba(168,180,249,.6),0 16px 26px rgba(2,4,16,.55)}to{box-shadow:inset 0 1px 0 #fff,0 7px 16px rgba(2,4,16,.45)}}
html.rm .rail{animation:railIn 1ms linear both,railOut 1ms linear 790ms forwards}
html.rm .rest{animation:dimIn 1ms linear both,dimOut 1ms linear 790ms forwards}
html.rm .tile.mv{animation:rimIn 1ms linear both,rimOut 1ms linear 790ms forwards}
html.rm .strip{animation:track 510ms linear 90ms both,settleRm 190ms ease-out 600ms forwards}
@keyframes settleRm{from{transform:translateX(${d1}px)}to{transform:translateX(${d2}px)}}`;
  }
  if (demo === 'thaw') {
    const o = { grid: L23_THAW, frozen: L23.frozen };
    body = `${status(F)}${topBar(F, { label: label(L23), moves: 4 })}${targetRail(F, L23.target)}${board(F, o).replace(/<div class="tile frozen"/, '<div class="tile frozen thawing"')}${hud(F, { undoOn: true, quota: 3 })}${homeBar(F)}`;
    // add the normal tile under the frozen one
    const key = L23.frozen[0].split(',').map(Number);
    const under = tileHtml(B, { grid: L23_THAW }, key[0], key[1]);
    body = body.replace('<div class="tile frozen thawing"', `${under}<div class="tile frozen thawing"`);
    css = `.thawing{animation:thaw 180ms cubic-bezier(.2,0,.2,1) both}.thawing i{animation:flake 180ms ease-in both}
@keyframes thaw{from{opacity:1}to{opacity:0}}@keyframes flake{from{transform:scale(1)}to{transform:scale(.6)}}
html.rm .thawing{animation:thaw 1ms linear both}html.rm .thawing i{animation:none}`;
  }
  if (demo === 'ghost') {
    const cx = B.x + B.pad + 2 * B.stride + B.t / 2, cy = B.top + B.pad + 2 * B.stride + B.t / 2;
    const tut = tutorialOverlay(false)(F);
    let rest = ''; for (let rr = 0; rr < 5; rr++) for (let c = 0; c < 5; c++) if (c !== 2) rest += tileHtml(B, { grid: L4.grid }, rr, c);
    let col = ''; for (let rr = -1; rr < 5; rr++) {
      const r2 = (rr + 5) % 5, top = B.top + B.pad + rr * stride;
      col += `<div class="tile mv ${rr < 0 ? 'wrapg' : ''}" style="left:0;top:${top - (B.top + B.pad - 5 * s)}px;width:${B.t}px;height:${B.t}px;border-radius:${B.t * 0.33}px;font-size:${B.t * 0.38}px"><span>${L4.grid[r2][2]}</span></div>`;
    }
    const colX = B.x + B.pad + 2 * stride;
    body = `${status(F)}${topBar(F, { label: label(L4), moves: '<span style="position:relative;display:inline-block"><span class="mc0">0</span><span class="mc1" style="position:absolute;left:0;top:0;opacity:0">1</span></span>' })}${targetRail(F, L4.target)}${board(F, { grid: ['     ', '     ', '     ', '     ', '     '] }).replace(/<div class="tile[^>]*><span> <\/span><\/div>/g, '')}
      <div class="rest">${rest}</div>
      <div class="abs" style="left:${colX}px;top:${B.top + B.pad - 5 * s}px;width:${B.t}px;height:${B.ch - 2 * B.pad + 10 * s}px;overflow:hidden"><div class="col" style="position:absolute;left:0;top:0;width:100%;height:100%">${col}</div></div>
      <div class="ring abs" style="left:${cx - 24 * s}px;top:${cy - 24 * s}px;width:${48 * s}px;height:${48 * s}px;border-radius:50%;background:rgba(168,180,249,.28);box-shadow:0 0 0 1.5px ${K.peri},0 0 26px rgba(168,180,249,.6)"></div>
      <div class="chev abs" style="left:${cx - 12 * s}px;top:${cy - 66 * s}px">${I.updown(K.peri, 24 * s)}</div>
      <div class="finger abs" style="left:${cx - 20 * s}px;top:${cy - 20 * s}px;width:${40 * s}px;height:${40 * s}px;border-radius:50%;background:rgba(255,255,255,.22);border:1px solid rgba(255,255,255,.35)"></div>
      <div class="tut">${tut}</div><div class="hudw">${hud(F, { undoOn: false, quota: 3 })}</div>${homeBar(F)}`;
    const up = stride * 0.45, drag = stride * 0.55;
    css = `.ring{animation:travel 1200ms ease-in-out 0ms 1 both,ghostOut 120ms ease-out 1500ms forwards}
.chev{animation:chev 1200ms ease-in-out 0ms 1 both,ghostOut 120ms ease-out 1500ms forwards}
.finger{opacity:0;animation:fingerIn 80ms ease-out 1500ms forwards,fingerMove 600ms cubic-bezier(.4,0,.6,1) 1500ms forwards,ghostOut 120ms ease-out 2100ms forwards}
.rest{animation:dimIn 90ms ease-out 1500ms both,dimOut 90ms ease-in 2290ms forwards}
.col{animation:colTrack 600ms cubic-bezier(.4,0,.6,1) 1500ms both,colSettle 190ms cubic-bezier(.22,1,.36,1) 2100ms forwards}
.tile.mv{animation:rimIn 90ms ease-out 1500ms both,rimOut 90ms ease-in 2290ms forwards}
.wrapg{opacity:.3}.tile.mv.wrapg{animation:rimIn 90ms ease-out 1500ms both,rimOut 90ms ease-in 2290ms forwards,ghostUp 190ms cubic-bezier(.22,1,.36,1) 2100ms forwards}
@keyframes ghostUp{from{opacity:.3}to{opacity:1}}
@keyframes dimOut{from{opacity:.42}to{opacity:1}}
@keyframes rimOut{from{box-shadow:0 0 0 2px ${K.peri},0 0 26px rgba(168,180,249,.6),0 16px 26px rgba(2,4,16,.55)}to{box-shadow:inset 0 1px 0 #fff,0 7px 16px rgba(2,4,16,.45)}}
.tut{animation:ghostOut 160ms ease-out 2100ms forwards}
.mc0{animation:hideOp 1ms linear 2290ms forwards}.mc1{animation:showOp 1ms linear 2290ms forwards}
.hudw>.pill:first-child{animation:undoOn 1ms linear 2290ms forwards}
@keyframes hideOp{to{opacity:0}}@keyframes showOp{to{opacity:1}}@keyframes undoOn{to{opacity:1}}
@keyframes travel{0%{transform:translateY(0)}50%{transform:translateY(-${up}px)}100%{transform:translateY(0)}}
@keyframes chev{0%{opacity:1;transform:translateY(0)}50%{opacity:.6;transform:translateY(-${up}px)}100%{opacity:1;transform:translateY(0)}}
@keyframes ghostOut{to{opacity:0}}
@keyframes fingerIn{to{opacity:1}}
@keyframes fingerMove{from{transform:translateY(0)}to{transform:translateY(${drag}px)}}
@keyframes dimIn{from{opacity:1}to{opacity:.42}}
@keyframes colTrack{from{transform:translateY(0)}to{transform:translateY(${drag}px)}}
@keyframes colSettle{0%{transform:translateY(${drag}px)}80%{transform:translateY(${stride * 1.015}px)}100%{transform:translateY(${stride}px)}}
@keyframes rimIn{from{box-shadow:inset 0 1px 0 #fff,0 7px 16px rgba(2,4,16,.45)}to{box-shadow:0 0 0 2px ${K.peri},0 0 26px rgba(168,180,249,.6),0 16px 26px rgba(2,4,16,.55)}}
html.rm .ring,html.rm .chev{animation:ghostOut 1ms linear 1500ms forwards}
html.rm .rest{animation:dimIn 1ms linear 1500ms both,dimOut 1ms linear 2290ms forwards}html.rm .tile.mv{animation:rimIn 1ms linear 1500ms both,rimOut 1ms linear 2290ms forwards}
html.rm .tile.mv.wrapg{animation:rimIn 1ms linear 1500ms both,rimOut 1ms linear 2290ms forwards,ghostUp 190ms ease-out 2100ms forwards}
html.rm .col{animation:colTrack 600ms linear 1500ms both,colSettleRm 190ms ease-out 2100ms forwards}
html.rm .tut{animation:ghostOut 1ms linear 2100ms forwards}
@keyframes colSettleRm{from{transform:translateY(${drag}px)}to{transform:translateY(${stride}px)}}`;
  }
  const js = `<script>${T !== null ? `window.__T=${T};` : ''}${rm ? 'document.documentElement.classList.add("rm");' : ''}
  (function(){var q=new URLSearchParams(location.search);if(q.get('rm'))document.documentElement.classList.add('rm');
  var T=(window.__T!==undefined)?window.__T:(q.get('t')!==null?+q.get('t'):null);
  if(T!==null){document.getAnimations().forEach(function(a){a.pause();a.currentTime=T;});}})();<\/script>`;
  let html = page(W, H, body + js, css);
  if (standalone) html = html.replace(`html,body{width:${W}px;height:${H}px;overflow:hidden}`, `html,body{width:${W}px;height:${H}px;overflow:hidden}html{background:#1b1c22}body{margin:0 auto}`)
    .replace('</body>', `<div style="position:fixed;left:16px;top:12px;font:600 13px/1.5 Manrope;color:#cfd3e6;background:rgba(0,0,0,.55);padding:8px 12px;border-radius:10px;z-index:9">F03 D1 hareket prototipi · <a href="?demo=lift" style="color:#DDFA6B">satır kaldırma</a> · <a href="?demo=thaw" style="color:#DDFA6B">erime</a> · <a href="?demo=ghost" style="color:#DDFA6B">öğretici hayalet</a> · <a href="?demo=${demo}&rm=1" style="color:#DDFA6B">azaltılmış hareket</a></div></body>`);
  return html;
}

// ---------------------------------------------------------------- emit
const jobs = [];
const emit = (name, html, W, H) => { fs.writeFileSync(path.join(OUT, name + '.html'), html); jobs.push(`${name} ${W} ${H}`); };
const W = 393, H = 852;
emit('D1-00-play-idle', playScreen(W, H, { L: L5, moves: 0, undoOn: false, quota: 3 }), W, H);
emit('D1-01-play-column-drag', playScreen(W, H, { L: L4, grid: sim(L4, ['r0+', 'r3-']), moves: 2, undoOn: true, quota: 3, liftCol: 2 }), W, H);
emit('D1-02-hud-undo-two-left', playScreen(W, H, { L: L5, grid: sim(L5, ['r1+']), moves: 1, undoOn: true, quota: 2 }), W, H);
emit('D1-03-hud-undo-exhausted', playScreen(W, H, { L: L5, grid: sim(L5, ['r1+', 'r3-', 'c0+', 'r4+']), moves: 4, undoOn: false, quota: 0 }), W, H);
emit('D1-04-hud-restart-pressed', playScreen(W, H, { L: L5, grid: sim(L5, ['r1+', 'r3-', 'c0+']), moves: 3, undoOn: true, quota: 3, restartPressed: true }), W, H);
emit('D1-05-play-locked-frozen-L26', playScreen(W, H, { L: L26, moves: 0, undoOn: false, quota: 3 }), W, H);
for (const [t, tag] of [[0, 't000'], [90, 't090'], [180, 't180']]) emit(`D1-06-play-thaw-L23-${tag}`, prototype(W, H, 'thaw', t), W, H);
emit('D1-07-play-load-error', loadErrorScreen(W, H, { level: 7 }), W, H);
emit('D1-11-play-loading', loadingScreen(W, H, { level: 7 }), W, H);
emit('D1-12-hud-focus-undo', playScreen(W, H, { L: L5, grid: sim(L5, ['r1+', 'r3-']), moves: 2, undoOn: true, quota: 3, focus: 'undo' }), W, H);
emit('D1-08-tutorial-hud', playScreen(W, H, { L: L4, moves: 0, undoOn: false, quota: 3, overlay: tutorialOverlay(true) }), W, H);
emit('D1-09-tutorial-drag-ghost-hidden', playScreen(W, H, { L: L4, moves: 0, undoOn: false, quota: 3, liftCol: 2, overlay: tutorialOverlay(false) }), W, H);
emit('D1-10-play-text-ax5-capped', playScreen(W, H, { L: L26, moves: 12, undoOn: true, quota: 1, tx: 1.3 }), W, H);
emit('D1-10b-tutorial-text-ax5-capped', playScreen(W, H, { L: L4, moves: 0, undoOn: false, quota: 3, tx: 1.3, overlay: tutorialOverlay(true, 1.3) }), W, H);
emit('D1-v-16e-tutorial-hud', playScreen(390, 844, { L: L4, moves: 0, undoOn: false, quota: 3, overlay: tutorialOverlay(true) }), 390, 844);
emit('D1-v-16e-tutorial-text-ax5-capped', playScreen(390, 844, { L: L4, moves: 0, undoOn: false, quota: 3, tx: 1.3, overlay: tutorialOverlay(true, 1.3) }), 390, 844);
emit('D1-v-promax-tutorial-hud', playScreen(440, 956, { L: L4, moves: 0, undoOn: false, quota: 3, overlay: tutorialOverlay(true) }), 440, 956);
emit('D1-v-16e-play-column-drag', playScreen(390, 844, { L: L4, grid: sim(L4, ['r0+', 'r3-']), moves: 2, undoOn: true, quota: 3, liftCol: 2 }), 390, 844);
// motion stills taken from the prototype (the prototype itself is D1-motion-prototype.html)
for (const t of [45, 400, 700, 900]) emit(`D1-M-lift-t${String(t).padStart(4, '0')}`, prototype(W, H, 'lift', t), W, H);
emit('D1-M-lift-reduced-t0045', prototype(W, H, 'lift', 45, true), W, H);
for (const t of [600, 1560, 2400]) emit(`D1-M-ghost-t${String(t).padStart(4, '0')}`, prototype(W, H, 'ghost', t), W, H);
fs.writeFileSync(path.join(OUT, 'D1-motion-prototype.html'), prototype(W, H, 'lift', null, false, true)
  .replace('<script>', `<script>(function(){var d=new URLSearchParams(location.search).get('demo');if(d&&d!=='lift'){location.replace('D1-motion-prototype-'+d+'.html'+location.search);}})();</script><script>`));
fs.writeFileSync(path.join(OUT, 'D1-motion-prototype-thaw.html'), prototype(W, H, 'thaw', null, false, true));
fs.writeFileSync(path.join(OUT, 'D1-motion-prototype-ghost.html'), prototype(W, H, 'ghost', null, false, true));
fs.writeFileSync(path.join(OUT, 'jobs-d1.txt'), jobs.join('\n') + '\n');
console.log(`L23 thaw grid: ${L23_THAW.join(' ')}\n${jobs.length} pages`);
