// F00 Phase B — Design Foundation direction renders (UI Designer, 2026-09-21).
// Generates standalone HTML for Direction A (Backlit Stage) and Direction B (Gazette) over the SAME
// content/state/geometry, so the two are comparable pixel-for-pixel. No app code; design artefacts only.
// Usage: node gen.mjs <outDir>   (then render.sh turns each html into a PNG with headless Chrome)
import fs from 'node:fs';
import path from 'node:path';
const OUT = process.argv[2] ?? '.';
fs.mkdirSync(OUT, { recursive: true });

// ---------------------------------------------------------------- shared content (real shipped copy/puzzles)
const L1 = { grid: ['ANASL', 'OPMİS', 'ÜOİİE', 'MKÇÜZ', 'MYİRE'], target: 'ASLAN' };
const L1_WON = ['ASLAN', 'OPMİS', 'ÜOİİE', 'MKÇÜZ', 'MYİRE'];
const L4 = { grid: ['BLÇIZ', 'MIENO', 'PÜLNG', 'BDERİ', 'ŞALKD'], target: 'BALIK' };
const L26 = { grid: ['TORBİ', 'ZYYOR', 'ÜYOZT', 'ÜROLL', 'LAHŞR'], target: 'TARİH', locked: ['0,0', '0,2'], frozen: ['2,2', '2,3'] };

// ---------------------------------------------------------------- geometry (mirrors the shipped layout, scaled by width)
function geo(W, H) {
  const boardW = Math.round(W * 0.86), pad = 10, gap = 8;
  const tile = (boardW - 2 * pad - 4 * gap) / 5;
  return { W, H, boardW, pad, gap, tile, stride: tile + gap, boardX: (W - boardW) / 2, boardTop: Math.round(H * 0.319) };
}
const fontFaces = `
@font-face{font-family:'Sora';src:url('fonts/Sora.ttf');font-weight:100 900}
@font-face{font-family:'Newsreader';src:url('fonts/Newsreader.ttf');font-weight:200 800;font-style:normal}`;

// ---------------------------------------------------------------- icons (drawn, not Material) — A: rounded solid; B: square-cap hairline
const ICON = {
  A: {
    back: (c, s = 24) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${c}" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M15 4.5 7.5 12 15 19.5"/></svg>`,
    undo: (c, s = 22) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${c}" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M9 5 4 10l5 5"/><path d="M4 10h9a6 6 0 0 1 0 12h-2"/></svg>`,
    restart: (c, s = 22) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${c}" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M20 12a8 8 0 1 1-2.6-5.9"/><path d="M20 3.5v5.2h-5.2"/></svg>`,
    pin: (c, s = 14) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24"><rect x="4.5" y="10.5" width="15" height="11" rx="2.6" fill="${c}"/><path d="M8 10.5V8a4 4 0 0 1 8 0v2.5" fill="none" stroke="${c}" stroke-width="2.6" stroke-linecap="round"/></svg>`,
    snow: (c, s = 14) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${c}" stroke-width="2.2" stroke-linecap="round"><path d="M12 2v20M3.3 7l17.4 10M3.3 17 20.7 7"/><path d="m9 4 3 2 3-2M9 20l3-2 3 2"/></svg>`,
    chevUpDown: (c, s = 22) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${c}" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="m7 9 5-5 5 5M7 15l5 5 5-5"/></svg>`,
  },
  B: {
    back: (c, s = 24) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${c}" stroke-width="1.7" stroke-linecap="square" stroke-linejoin="miter"><path d="M20 12H4.5M10.5 5.5 4 12l6.5 6.5"/></svg>`,
    undo: (c, s = 22) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${c}" stroke-width="1.7" stroke-linecap="square" stroke-linejoin="miter"><path d="M9 5 4 10l5 5M4 10h10.5a5.5 5.5 0 0 1 0 11H10"/></svg>`,
    restart: (c, s = 22) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${c}" stroke-width="1.7" stroke-linecap="square" stroke-linejoin="miter"><path d="M20 12a8 8 0 1 1-2.6-5.9M20 3.5v5.2h-5.2"/></svg>`,
    pin: (c, s = 14) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${c}" stroke-width="2" stroke-linecap="square" stroke-linejoin="miter"><rect x="4.5" y="10.5" width="15" height="11"/><path d="M8 10.5V7.5a4 4 0 0 1 8 0v3"/></svg>`,
    snow: (c, s = 14) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${c}" stroke-width="1.8" stroke-linecap="square"><path d="M12 2v20M3.3 7l17.4 10M3.3 17 20.7 7"/></svg>`,
    chevUpDown: (c, s = 22) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${c}" stroke-width="1.7" stroke-linecap="square" stroke-linejoin="miter"><path d="m6 9 6-6 6 6M6 15l6 6 6-6"/></svg>`,
  },
};
const STAR = '12,1.5 14.9,8.4 22.4,9 16.7,13.9 18.5,21.2 12,17.3 5.5,21.2 7.3,13.9 1.6,9 9.1,8.4';

// ---------------------------------------------------------------- Direction A — "Backlit Stage"
const A = {
  id: 'A', name: 'Backlit Stage',
  c: { stage0: '#0B0C16', stage1: '#141322', glow: '#2A2350', plate: '#0E0F1C', tileHi: '#F7F2E9', tileLo: '#E4DBCA', ink: '#1B1A24', amber: '#FFC24B', amberLo: '#FFB020', inkAmber: '#2A1B00', cyan: '#5AA9FF', brass: '#C9A24B', frost: '#DCE8F2', frostLine: '#8FBFE6', paper: '#F4EFE6', muted: '#9391AA', sheet: '#191A2B', recess: '#12131F' },
  css: `
  body{background:linear-gradient(#0B0C16,#141322);color:#F4EFE6;font-family:'Sora',sans-serif}
  .stage{position:absolute;inset:0;background:radial-gradient(90% 46% at 50% 36%,rgba(60,50,120,.55),rgba(42,35,80,0) 70%)}
  .lbl{font-weight:600;font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:#9391AA;line-height:1}
  .num{font-weight:700;font-variant-numeric:tabular-nums;letter-spacing:0;line-height:1}
  .plate{position:absolute;background:#0E0F1C;border-radius:19px;box-shadow:0 3px 10px rgba(0,0,0,.5),inset 0 1px 0 rgba(255,255,255,.06)}
  .tile{position:absolute;display:flex;align-items:center;justify-content:center;font-weight:800;line-height:1;color:#1B1A24;
    background:linear-gradient(#F7F2E9,#E4DBCA);border-radius:19%;box-shadow:inset 0 1px 0 rgba(255,255,255,.95),inset 0 -2px 0 rgba(120,100,60,.18),0 2px 0 rgba(0,0,0,.4),0 7px 12px rgba(0,0,0,.35);letter-spacing:.02em}
  .tile span{position:relative;top:-1px}
  .tile.win{background:linear-gradient(#FFD26E,#FFB020);color:#2A1B00;box-shadow:inset 0 1px 0 rgba(255,255,255,.55),0 0 18px rgba(255,194,75,.55),0 2px 0 rgba(120,70,0,.5)}
  .tile.locked{box-shadow:inset 0 0 0 2.5px #C9A24B,inset 0 1px 0 rgba(255,255,255,.9),0 2px 0 rgba(0,0,0,.4),0 7px 12px rgba(0,0,0,.35)}
  .tile.frozen{background:linear-gradient(#EAF3FA,#D3E2EE);box-shadow:inset 0 0 0 2px #8FBFE6,inset 0 1px 0 #fff,0 2px 0 rgba(0,0,0,.4),0 7px 12px rgba(0,0,0,.35)}
  .tile.lift{background:linear-gradient(#FFFFFF,#F1E9D9);box-shadow:inset 0 1px 0 #fff,0 0 0 1.5px rgba(90,169,255,.9),0 0 18px rgba(90,169,255,.45),0 12px 20px rgba(0,0,0,.5)}
  .tile.ghost{opacity:.32;box-shadow:none}
  .slot{position:absolute;border-radius:19%;border:1.5px dashed rgba(255,194,75,.45);background:rgba(255,194,75,.05)}
  .cta{position:absolute;display:flex;align-items:center;justify-content:center;font-weight:800;letter-spacing:.14em}
  .btn{position:absolute;display:flex;align-items:center;justify-content:center;border-radius:50%;border:1.5px solid rgba(147,145,170,.4);background:rgba(255,255,255,.02)}
  `,
  status: (W) => `<div style="position:absolute;top:18px;left:34px;font:600 16px/1 Sora;color:#F4EFE6">9:41</div>
    <div style="position:absolute;top:19px;right:30px;display:flex;gap:6px;align-items:center;opacity:.95">
    <svg width="18" height="12" viewBox="0 0 18 12" fill="#F4EFE6"><rect y="8" width="3" height="4" rx="1"/><rect x="5" y="5" width="3" height="7" rx="1"/><rect x="10" y="2.5" width="3" height="9.5" rx="1"/><rect x="15" width="3" height="12" rx="1"/></svg>
    <svg width="26" height="12" viewBox="0 0 26 12" fill="none" stroke="#F4EFE6" stroke-width="1"><rect x=".5" y=".5" width="22" height="11" rx="3.5" opacity=".5"/><rect x="2" y="2" width="19" height="8" rx="2" fill="#F4EFE6" stroke="none"/></svg></div>
    <div style="position:absolute;top:11px;left:${W / 2 - 63}px;width:126px;height:37px;border-radius:19px;background:#000"></div>`,
  home: (W, H) => `<div style="position:absolute;bottom:8px;left:${W / 2 - 67}px;width:134px;height:5px;border-radius:3px;background:rgba(244,239,230,.7)"></div>`,
  glyphSize: (t) => t * 0.46,
  tileCss: (t, extra = '') => `width:${t}px;height:${t}px;font-size:${t * 0.46}px;${extra}`,
  railTile: (ch, s) => `<div class="tile" style="position:relative;width:${s}px;height:${s}px;font-size:${s * 0.5}px;border-radius:7px;background:rgba(244,239,230,.08);color:#F4EFE6;box-shadow:inset 0 0 0 1px rgba(244,239,230,.25);opacity:1">${ch}</div>`,
};

// ---------------------------------------------------------------- Direction B — "Gazette"
const B = {
  id: 'B', name: 'Gazette',
  c: { paper: '#EFE8D8', paper2: '#E6DDC8', ink: '#1B1815', cream: '#FBF7EC', shelf: '#D5CBB0', vermilion: '#C7361F', blue: '#2C4C86', muted: '#6C6353', ice: '#D9E6EC', hair: 'rgba(27,24,21,.38)' },
  css: `
  body{background:#EFE8D8;color:#1B1815;font-family:'Newsreader',serif}
  .paper{position:absolute;inset:0;background:#EFE8D8}
  .paper:after{content:'';position:absolute;inset:0;opacity:.5;mix-blend-mode:multiply;background-image:url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='240' height='240'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='.9' numOctaves='2' seed='4'/><feColorMatrix values='0 0 0 0 .45  0 0 0 0 .38  0 0 0 0 .25  0 0 0 .16 0'/></filter><rect width='240' height='240' filter='url(%23n)'/></svg>")}
  .lbl{font-family:'Newsreader';font-weight:600;font-size:11.5px;letter-spacing:.17em;text-transform:uppercase;color:#6C6353;line-height:1;font-variation-settings:'opsz' 8}
  .num{font-weight:800;font-variant-numeric:tabular-nums;line-height:1;font-variation-settings:'opsz' 72}
  .plate{position:absolute;background:#1B1815;border-radius:4px;box-shadow:0 1px 0 #000,0 5px 0 rgba(27,24,21,.16)}
  .tile{position:absolute;display:flex;align-items:center;justify-content:center;font-weight:800;line-height:1;color:#1B1815;font-variation-settings:'opsz' 72;
    background:#FBF7EC;border-radius:5px;box-shadow:inset 0 -3.5px 0 #D5CBB0,0 1px 0 #000}
  .tile span{position:relative;top:-1.5px}
  .tile.win{background:#C7361F;color:#FBF7EC;box-shadow:inset 0 -3.5px 0 #9B2715,0 1px 0 #000}
  .tile.locked{background:#1B1815;color:#FBF7EC;box-shadow:inset 0 0 0 2px #FBF7EC,0 1px 0 #000}
  .tile.frozen{background:repeating-linear-gradient(135deg,#D9E6EC 0 5px,#C4D6DF 5px 6.5px);box-shadow:inset 0 0 0 1.5px #2C4C86,inset 0 -3.5px 0 #A9C0CC,0 1px 0 #000}
  .tile.lift{background:#FFFDF6;box-shadow:inset 0 -3.5px 0 #D5CBB0,0 0 0 1.5px #2C4C86,0 9px 0 rgba(0,0,0,.55)}
  .tile.ghost{opacity:.3;box-shadow:none}
  .slot{position:absolute;border-radius:5px;border:1.5px dashed rgba(199,54,31,.7)}
  .cta{position:absolute;display:flex;align-items:center;justify-content:center;font-weight:700;letter-spacing:.16em;text-transform:uppercase;font-variation-settings:'opsz' 14}
  .btn{position:absolute;display:flex;align-items:center;justify-content:center;border:1.5px solid #1B1815;background:transparent;border-radius:2px}
  .rule2{position:absolute;height:5px;border-top:3px solid currentColor;border-bottom:1px solid currentColor;box-sizing:border-box}
  `,
  status: (W) => `<div style="position:absolute;top:18px;left:34px;font:700 16px/1 Newsreader;color:#1B1815;font-variation-settings:'opsz' 14">9:41</div>
    <div style="position:absolute;top:19px;right:30px;display:flex;gap:6px;align-items:center">
    <svg width="18" height="12" viewBox="0 0 18 12" fill="#1B1815"><rect y="8" width="3" height="4"/><rect x="5" y="5" width="3" height="7"/><rect x="10" y="2.5" width="3" height="9.5"/><rect x="15" width="3" height="12"/></svg>
    <svg width="26" height="12" viewBox="0 0 26 12" fill="none" stroke="#1B1815" stroke-width="1"><rect x=".5" y=".5" width="22" height="11" rx="3" opacity=".5"/><rect x="2" y="2" width="19" height="8" rx="1.5" fill="#1B1815" stroke="none"/></svg></div>
    <div style="position:absolute;top:11px;left:${W / 2 - 63}px;width:126px;height:37px;border-radius:19px;background:#000"></div>`,
  home: (W, H) => `<div style="position:absolute;bottom:8px;left:${W / 2 - 67}px;width:134px;height:5px;border-radius:3px;background:rgba(27,24,21,.75)"></div>`,
};

// ---------------------------------------------------------------- shared drawing helpers
const esc = (s) => s;
function page(dir, W, H, body) {
  return `<!doctype html><html><head><meta charset="utf-8"><style>${fontFaces}
  *{box-sizing:border-box;margin:0;padding:0}html,body{width:${W}px;height:${H}px;overflow:hidden}
  body{position:relative}${dir.css}</style></head><body>${body}</body></html>`;
}
const dirOf = (id) => (id === 'A' ? A : B);

// board: state = { grid, lift:{row,dx}, dim:0..1, wonRow, vacated, locked:[], frozen:[], rowsDim }
function board(id, g, st) {
  const D = dirOf(id), { tile: t, stride, pad, gap, boardW } = g;
  const rad = id === 'A' ? t * 0.19 + gap : 4;
  const grid = st.grid;
  let out = `<div class="plate" style="left:${g.boardX}px;top:${g.boardTop}px;width:${boardW}px;height:${boardW}px;border-radius:${rad}px;opacity:${st.plateOpacity ?? 1}"></div>`;
  const cell = (r, c, dx = 0, extra = '') => {
    const key = `${r},${c}`, ch = grid[r][c];
    let kind = '';
    if (st.wonRow === r && !st.vacated) kind = 'win';
    else if (st.locked?.includes(key)) kind = 'locked';
    else if (st.frozen?.includes(key)) kind = 'frozen';
    if (st.lift && st.lift.row === r) kind = (kind ? kind + ' ' : '') + 'lift';
    const x = g.boardX + pad + c * stride + dx, y = g.boardTop + pad + r * stride;
    const fs = id === 'A' ? t * 0.46 : t * 0.62;
    const icon = kind.includes('locked') ? `<i style="position:absolute;top:4px;right:4px;display:flex">${ICON[id].pin(id === 'A' ? '#B5892E' : '#FBF7EC', 17)}</i>` : kind.includes('frozen') ? `<i style="position:absolute;top:4px;right:4px;display:flex">${ICON[id].snow(id === 'A' ? '#4C86B8' : '#2C4C86', 17)}</i>` : '';
    const dim = st.lift && st.lift.row !== r ? st.rowsDim ?? 0.34 : st.dimAll ?? 0;
    const dimCss = dim ? `filter:brightness(${1 - dim});` : '';
    return `<div class="tile ${kind} ${extra}" style="left:${x}px;top:${y}px;width:${t}px;height:${t}px;font-size:${fs}px;${dimCss}"><span>${ch}</span>${icon}</div>`;
  };
  const clipL = g.boardX + pad - 4, clipW = boardW - 2 * pad + 8;
  for (let r = 0; r < 5; r++) {
    if (st.vacated && st.wonRow === r) {
      for (let c = 0; c < 5; c++) out += `<div class="slot" style="left:${g.boardX + pad + c * stride}px;top:${g.boardTop + pad + r * stride}px;width:${t}px;height:${t}px"></div>`;
      continue;
    }
    if (st.lift && st.lift.row === r) continue;
    for (let c = 0; c < 5; c++) out += cell(r, c);
  }
  if (st.lift) {
    const r = st.lift.row, dx = st.lift.dx;
    let inner = '';
    for (let c = 0; c < 5; c++) inner += cell(r, c, dx);
    // wrap ghost: the tile leaving on the right re-enters on the left
    const ghostC = dx > 0 ? 4 : 0;
    const gx = dx > 0 ? -stride + dx : 5 * stride + dx;
    const gh = cell(r, ghostC, 0, 'ghost').replace(/left:[^;]+;/, `left:${g.boardX + pad + gx}px;`);
    out += `<div style="position:absolute;left:${clipL}px;top:0;width:${clipW}px;height:${H_(g)}px;overflow:hidden">${shiftLeft(inner + gh, clipL)}</div>`;
    // rails (active row edges)
    const ry = g.boardTop + pad + r * stride;
    out += id === 'A'
      ? `<div style="position:absolute;left:${g.boardX - 1}px;top:${ry + 6}px;width:3px;height:${t - 12}px;border-radius:2px;background:#5AA9FF;box-shadow:0 0 12px #5AA9FF"></div><div style="position:absolute;left:${g.boardX + boardW - 2}px;top:${ry + 6}px;width:3px;height:${t - 12}px;border-radius:2px;background:#5AA9FF;box-shadow:0 0 12px #5AA9FF"></div>`
      : `<div style="position:absolute;left:${g.boardX - 15}px;top:${ry + t / 2 - 7}px;width:0;height:0;border-left:11px solid #2C4C86;border-top:7px solid transparent;border-bottom:7px solid transparent"></div><div style="position:absolute;left:${g.boardX + boardW + 4}px;top:${ry + t / 2 - 7}px;width:0;height:0;border-right:11px solid #2C4C86;border-top:7px solid transparent;border-bottom:7px solid transparent"></div><div style="position:absolute;left:${g.boardX + pad}px;top:${ry + t + 1.5}px;width:${boardW - 2 * pad}px;height:2px;background:#2C4C86"></div>`;
  }
  // winning seam / rule under the home row
  if (st.wonRow != null && !st.vacated) {
    const ry = g.boardTop + pad + st.wonRow * stride + t + 2;
    out += id === 'A'
      ? `<div style="position:absolute;left:${g.boardX + pad}px;top:${ry + 1}px;width:${5 * t + 4 * gap}px;height:3px;border-radius:2px;background:#FFC24B;box-shadow:0 0 12px rgba(255,194,75,.8)"></div>`
      : `<div class="rule2" style="left:${g.boardX + pad}px;top:${ry - 1}px;width:${5 * t + 4 * gap}px;color:#C7361F"></div>`;
  }
  return out;
}
const H_ = (g) => g.H;
function shiftLeft(html, clipL) { return html.replace(/left:(-?[\d.]+)px/g, (m, v) => `left:${(parseFloat(v) - clipL).toFixed(2)}px`); }

// target rail
function targetRail(id, g, word, opacity = 1) {
  const s = id === 'A' ? 27 : 27, gap = 8, w = 5 * s + 4 * gap;
  const y = Math.round(g.H * 0.156);
  let tiles = '';
  for (let i = 0; i < 5; i++) {
    const x = (g.W - w) / 2 + i * (s + gap);
    tiles += id === 'A'
      ? `<div class="tile" style="left:${x}px;top:${y + 17}px;width:${s}px;height:${s}px;font-size:${s * 0.5}px;border-radius:7px;background:rgba(244,239,230,.06);color:#F4EFE6;box-shadow:inset 0 0 0 1px rgba(244,239,230,.28)"><span>${word[i]}</span></div>`
      : `<div class="tile" style="left:${x}px;top:${y + 17}px;width:${s}px;height:${s}px;font-size:${s * 0.66}px;border-radius:3px;background:transparent;color:#1B1815;box-shadow:inset 0 0 0 1.5px #1B1815"><span>${word[i]}</span></div>`;
  }
  const label = id === 'A'
    ? `<div class="lbl" style="position:absolute;top:${y}px;left:0;width:${g.W}px;text-align:center">HEDEF</div>`
    : `<div class="lbl" style="position:absolute;top:${y}px;left:0;width:${g.W}px;text-align:center">HEDEF</div>`;
  const rule = id === 'A'
    ? `<div style="position:absolute;top:${y + 66}px;left:${g.boardX}px;width:${g.boardW}px;height:1px;background:linear-gradient(90deg,transparent,rgba(244,239,230,.18),transparent)"></div>`
    : `<div class="rule2" style="top:${y + 63}px;left:${g.boardX}px;width:${g.boardW}px;color:#1B1815"></div>`;
  return `<div style="opacity:${opacity}">${label}${tiles}${rule}</div>`;
}

function backBtn(id, g, opacity = 1) {
  const y = Math.round(g.H * 0.077);
  return id === 'A'
    ? `<div style="position:absolute;left:12px;top:${y}px;width:44px;height:44px;display:flex;align-items:center;justify-content:center;opacity:${opacity}">${ICON.A.back('#9391AA', 24)}</div>`
    : `<div style="position:absolute;left:18px;top:${y}px;height:44px;display:flex;align-items:center;gap:8px;opacity:${opacity}">${ICON.B.back('#1B1815', 24)}<span class="lbl" style="color:#1B1815">GERİ</span></div>`;
}

function hud(id, g, moves, { locked = false, opacity = 1, undoOn = false } = {}) {
  const y = g.H - 138;
  if (id === 'A') {
    return `<div style="opacity:${opacity}"><div class="lbl" style="position:absolute;left:${g.boardX + 4}px;top:${y - 6}px">HAMLE</div>
      <div class="num" style="position:absolute;left:${g.boardX + 4}px;top:${y - 48}px;font-size:34px">${moves}</div>
      <div class="btn" style="left:${g.boardX}px;top:${g.H - 90}px;width:${undoOn ? 78 : 78}px;height:46px;border-radius:23px;opacity:${undoOn ? 1 : 0.45};gap:9px">${ICON.A.undo('#F4EFE6', 20)}<span style="display:flex;gap:4px"><i style="width:5px;height:5px;border-radius:50%;background:#F4EFE6"></i><i style="width:5px;height:5px;border-radius:50%;background:#F4EFE6"></i><i style="width:5px;height:5px;border-radius:50%;background:#F4EFE6"></i></span></div>
      <div class="btn" style="left:${g.boardX + g.boardW - 48}px;top:${g.H - 90}px;width:48px;height:48px">${ICON.A.restart('#F4EFE6', 22)}</div></div>`;
  }
  return `<div style="opacity:${opacity}"><div class="lbl" style="position:absolute;left:${g.boardX}px;top:${y + 52}px">HAMLE</div>
    <div class="num" style="position:absolute;left:${g.boardX - 2}px;top:${y - 10}px;font-size:56px">${moves}</div>
    <div class="btn" style="left:${g.boardX + g.boardW - 108}px;top:${g.H - 92}px;width:52px;height:48px;opacity:${undoOn ? 1 : 0.4}">${ICON.B.undo('#1B1815', 22)}<span style="position:absolute;bottom:3px;font:800 9px Newsreader;letter-spacing:.08em">3</span></div>
    <div class="btn" style="left:${g.boardX + g.boardW - 48}px;top:${g.H - 92}px;width:48px;height:48px">${ICON.B.restart('#1B1815', 22)}</div></div>`;
}

const bgFor = (id) => (id === 'A' ? '<div class="stage"></div>' : '<div class="paper"></div>');

// ---------------------------------------------------------------- screens
function screenPlay(id, W, H, kind) {
  const g = geo(W, H), D = dirOf(id);
  let st, moves = 0, word = L1.target, grid = L1.grid;
  if (kind === 'idle') st = { grid };
  if (kind === 'lift') st = { grid, lift: { row: 1, dx: Math.round(g.stride * 0.55) }, rowsDim: id === 'A' ? 0.4 : 0.12 };
  if (kind === 'pieces') { st = { grid: L26.grid, locked: L26.locked, frozen: L26.frozen }; word = L26.target; moves = 3; }
  const rail = targetRail(id, g, word, kind === 'lift' ? 0.85 : 1);
  const hudOp = kind === 'lift' ? 0.45 : 1;
  const body = `${bgFor(id)}${D.status(W)}${backBtn(id, g, kind === 'lift' ? 0.45 : 1)}${rail}${board(id, g, st)}${hud(id, g, moves, { opacity: hudOp, undoOn: kind === 'pieces' })}${D.home(W, H)}`;
  return page(D, W, H, body);
}

function screenTutorial(id, W, H) {
  const g = geo(W, H), D = dirOf(id);
  const st = { grid: L4.grid };
  const hint = 'Sütunları da kaydırabilirsin — yukarı ya da aşağı.';
  const cx = g.boardX + g.pad + 2 * g.stride + g.tile / 2, cy = g.boardTop + g.pad + 2 * g.stride + g.tile / 2;
  const ghost = id === 'A'
    ? `<div style="position:absolute;left:${cx - 22}px;top:${cy - 22}px;width:44px;height:44px;border-radius:50%;background:rgba(90,169,255,.28);box-shadow:0 0 0 1.5px rgba(90,169,255,.9),0 0 22px rgba(90,169,255,.6)"></div><div style="position:absolute;left:${cx - 11}px;top:${cy - 62}px;opacity:.9">${ICON.A.chevUpDown('#5AA9FF', 22)}</div>`
    : `<div style="position:absolute;left:${cx - 20}px;top:${cy - 20}px;width:40px;height:40px;border-radius:50%;border:2px solid #2C4C86;background:rgba(44,76,134,.15)"></div><div style="position:absolute;left:${cx - 11}px;top:${cy - 58}px">${ICON.B.chevUpDown('#2C4C86', 22)}</div>`;
  const hintEl = id === 'A'
    ? `<div style="position:absolute;left:${g.boardX}px;width:${g.boardW}px;top:${H - 138}px;font:400 14px/1.4 Sora;color:#F4EFE6;text-align:center">${hint}</div>`
    : `<div style="position:absolute;left:${g.boardX}px;width:${g.boardW}px;top:${H - 142}px;font:italic 500 16px/1.3 Newsreader;color:#1B1815;text-align:center;font-variation-settings:'opsz' 14">${hint}</div>`;
  const body = `${bgFor(id)}${D.status(W)}${backBtn(id, g)}${targetRail(id, g, L4.target)}${board(id, g, st)}${ghost}${hintEl}${D.home(W, H)}`;
  return page(D, W, H, body);
}

// dock geometry (mirrors F03 ui-design §16.3): unit centred in [dividerBottom+12, 0.36H-16]
function dockTop(g) {
  const dividerBottom = Math.round(g.H * 0.156) + 67, zoneTop = dividerBottom + 12, zoneBottom = 0.36 * g.H - 16, unit = g.tile + 6;
  return zoneTop + (zoneBottom - zoneTop - unit) / 2;
}
function dockRow(id, g, word, top, scale = 1) {
  const t = g.tile, w = 5 * t + 4 * g.gap, x = (g.W - w) / 2;
  let tiles = '';
  for (let i = 0; i < 5; i++) {
    tiles += `<div class="tile win" style="left:${x + i * g.stride}px;top:${top}px;width:${t}px;height:${t}px;font-size:${id === 'A' ? t * 0.46 : t * 0.62}px;${id === 'A' ? 'box-shadow:inset 0 1px 0 rgba(255,255,255,.55),0 0 20px rgba(255,194,75,.6),0 8px 16px rgba(0,0,0,.55)' : ''}"><span>${word[i]}</span></div>`;
  }
  const seam = id === 'A'
    ? `<div style="position:absolute;left:${x}px;top:${top + t + 3}px;width:${w}px;height:3px;border-radius:2px;background:#FFC24B;box-shadow:0 0 12px rgba(255,194,75,.9)"></div>`
    : `<div class="rule2" style="left:${x}px;top:${top + t + 3}px;width:${w}px;color:#C7361F"></div>`;
  return tiles + seam;
}
function starSvg(id, filled, s = 44) {
  if (id === 'A') {
    return `<svg width="${s}" height="${s}" viewBox="0 0 24 24" style="overflow:visible">
      <defs><linearGradient id="sg${filled ? 1 : 0}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${filled ? '#FFD874' : '#2A2C44'}"/><stop offset="1" stop-color="${filled ? '#FFB020' : '#20213A'}"/></linearGradient></defs>
      <polygon points="${STAR}" fill="url(#sg${filled ? 1 : 0})" ${filled ? 'style="filter:drop-shadow(0 0 7px rgba(255,194,75,.65))"' : ''} stroke="${filled ? '#FFE6A8' : '#3A3C58'}" stroke-width=".6" stroke-linejoin="round"/>
      ${filled ? `<polygon points="12,1.5 14.9,8.4 12,10.2" fill="rgba(255,255,255,.55)"/><polygon points="12,17.3 18.5,21.2 16.7,13.9 12,10.2" fill="rgba(120,60,0,.22)"/>` : ''}</svg>`;
  }
  return `<svg width="${s}" height="${s}" viewBox="0 0 24 24" style="overflow:visible">
    ${filled ? `<polygon points="${STAR}" fill="none" stroke="#2C4C86" stroke-width="1.1" transform="translate(1.1 .9)" stroke-linejoin="miter"/><polygon points="${STAR}" fill="#C7361F" stroke="#C7361F" stroke-width=".6" stroke-linejoin="miter"/>` : `<polygon points="${STAR}" fill="none" stroke="#1B1815" stroke-width="1.1" stroke-dasharray="2 1.6" stroke-linejoin="miter"/>`}</svg>`;
}

function panel(id, g, variant, { top, rise = 0, op = 1 }) {
  const perfect = variant === 'perfect', stars = perfect ? 3 : 2, you = perfect ? 2 : 3, W = g.W, H = g.H;
  const h = H - top;
  const stat = (lab, val, extra = '') => `<div style="display:flex;flex-direction:column;align-items:center;gap:8px;flex:1"><span class="num" style="font-size:${id === 'A' ? 30 : 40}px;${id === 'A' ? 'color:#F4EFE6' : ''}">${val}${extra}</span><span class="lbl">${lab}</span></div>`;
  if (id === 'A') {
    return `<div style="position:absolute;left:0;top:${top + rise}px;width:${W}px;height:${h}px;background:linear-gradient(#1D1E31,#161728);border-radius:30px 30px 0 0;box-shadow:inset 0 1px 0 rgba(255,255,255,.09),0 -18px 40px rgba(0,0,0,.45);opacity:${op}">
      ${perfect ? `<div style="position:absolute;top:22px;left:0;width:${W}px;display:flex;justify-content:center"><span style="padding:8px 16px;border:1.5px solid rgba(255,194,75,.7);border-radius:8px;color:#FFC24B;font:800 12px/1 Sora;letter-spacing:.24em;background:rgba(255,194,75,.08)">HARİKA</span></div>` : ''}
      <div style="position:absolute;top:${perfect ? 72 : 44}px;left:0;width:${W}px;display:flex;justify-content:center;gap:12px">${[1, 2, 3].map((i) => starSvg('A', i <= stars, 52)).join('')}</div>
      <div class="lbl" style="position:absolute;top:${perfect ? 142 : 114}px;left:0;width:${W}px;text-align:center;letter-spacing:.2em">${stars} / 3</div>
      <div class="lbl" style="position:absolute;top:${perfect ? 178 : 150}px;left:0;width:${W}px;text-align:center;color:#FFC24B;letter-spacing:.26em">ÇÖZÜLDÜ</div>
      <div style="position:absolute;top:${perfect ? 200 : 172}px;left:0;width:${W}px;text-align:center;font:800 36px/1.1 Sora;letter-spacing:.14em;color:#FFC24B">ASLAN</div>
      <div style="position:absolute;top:${perfect ? 250 : 222}px;left:${g.boardX}px;width:${g.boardW}px;height:88px;border-radius:18px;background:#12131F;box-shadow:inset 0 2px 6px rgba(0,0,0,.5);display:flex;align-items:center;padding:0 8px">${stat('SEN', you)}<span class="num" style="font-size:20px;color:#9391AA">${perfect ? '=' : '›'}</span>${stat('OPTİMAL', 2)}<span style="width:1px;height:38px;background:rgba(255,255,255,.08)"></span>${stat('EN İYİ', perfect ? '2<sup style="font-size:13px;color:#FFC24B;margin-left:2px">★</sup>' : '2<sup style="font-size:13px;color:#FFC24B;margin-left:2px">★</sup>')}</div>
      <div class="cta" style="left:${g.boardX}px;top:${perfect ? 354 : 326}px;width:${g.boardW}px;height:56px;border-radius:28px;font-size:15px;background:linear-gradient(#FFC94F,#FFB020);color:#2A1B00;box-shadow:0 10px 26px rgba(255,176,32,.32),inset 0 1px 0 rgba(255,255,255,.5)">${perfect ? 'SONRAKİ' : 'YENİDEN'}</div>
      <div class="cta" style="left:${g.boardX}px;top:${perfect ? 422 : 394}px;width:${g.boardW}px;height:50px;border-radius:25px;font-size:13px;font-weight:700;border:1.5px solid rgba(244,239,230,.28);color:#F4EFE6">${perfect ? 'Yeniden' : 'SONRAKİ'}</div>
      <div style="position:absolute;top:${perfect ? 494 : 466}px;left:0;width:${W}px;text-align:center;font:600 14px/1 Sora;color:#9391AA;letter-spacing:.06em">Kapat</div></div>`;
  }
  return `<div style="position:absolute;left:0;top:${top + rise}px;width:${W}px;height:${h}px;background:#FBF7EC;border-top:2.5px solid #1B1815;box-shadow:0 -9px 0 rgba(27,24,21,.10);opacity:${op}">
    <div class="rule2" style="left:0;top:5px;width:${W}px;height:5px;color:#1B1815"></div>
    ${perfect ? `<div style="position:absolute;top:34px;left:${g.boardX}px;width:${g.boardW}px;display:flex;align-items:center;gap:12px"><span style="flex:1;height:1px;background:#1B1815"></span><span style="font:800 13px/1 Newsreader;letter-spacing:.32em;color:#C7361F;font-variation-settings:'opsz' 14">HARİKA</span><span style="flex:1;height:1px;background:#1B1815"></span></div>` : ''}
    <div style="position:absolute;top:${perfect ? 68 : 40}px;left:0;width:${W}px;display:flex;justify-content:center;gap:16px">${[1, 2, 3].map((i) => starSvg('B', i <= stars, 50)).join('')}</div>
    <div class="lbl" style="position:absolute;top:${perfect ? 136 : 108}px;left:0;width:${W}px;text-align:center">${stars} / 3</div>
    <div class="lbl" style="position:absolute;top:${perfect ? 172 : 144}px;left:0;width:${W}px;text-align:center;color:#C7361F;letter-spacing:.3em">ÇÖZÜLDÜ</div>
    <div style="position:absolute;top:${perfect ? 190 : 162}px;left:0;width:${W}px;text-align:center;font:800 54px/1.05 Newsreader;letter-spacing:.06em;font-variation-settings:'opsz' 72">ASLAN</div>
    <div style="position:absolute;top:${perfect ? 246 : 218}px;left:${g.boardX}px;width:${g.boardW}px;height:86px;border-top:1px solid #1B1815;border-bottom:1px solid #1B1815;display:flex;align-items:center">${stat('SEN', you)}<span style="width:1px;height:46px;background:rgba(27,24,21,.35)"></span>${stat('OPTİMAL', 2)}<span style="width:1px;height:46px;background:rgba(27,24,21,.35)"></span>${stat('EN İYİ', '2<sup style="font-size:15px;color:#C7361F;margin-left:2px">★</sup>')}</div>
    <div class="cta" style="left:${g.boardX}px;top:${perfect ? 350 : 322}px;width:${g.boardW}px;height:56px;font-size:15px;background:#1B1815;color:#FBF7EC;border-radius:2px;box-shadow:0 5px 0 rgba(27,24,21,.22)">${perfect ? 'Sonraki' : 'Yeniden'}<span style="margin-left:14px;color:#E8583F;font-size:18px">→</span></div>
    <div class="cta" style="left:${g.boardX}px;top:${perfect ? 420 : 392}px;width:${g.boardW}px;height:48px;font-size:13px;border:1.5px solid #1B1815;border-radius:2px;color:#1B1815">${perfect ? 'Yeniden' : 'Sonraki'}</div>
    <div style="position:absolute;top:${perfect ? 488 : 460}px;left:0;width:${W}px;text-align:center;font:600 14px/1 Newsreader;color:#1B1815;text-decoration:underline;text-underline-offset:4px;letter-spacing:.12em;text-transform:uppercase">Kapat</div></div>`;
}

function screenWon(id, W, H, variant, phase = 'rest') {
  const g = geo(W, H), D = dirOf(id);
  const st = { grid: L1_WON, wonRow: 0, vacated: phase !== 'hold', plateOpacity: id === 'A' ? 1 : 0.18, dimAll: id === 'A' ? 0.86 : 0 };
  const top = Math.round(0.365 * H), dt = dockTop(g);
  const rowHomeY = g.boardTop + g.pad;
  let dockY = dt, panelRise = 0, panelOp = 1, scrim = 1;
  if (phase === 'hold') { scrim = 0; }
  if (phase === 'glide') { dockY = rowHomeY + (dt - rowHomeY) * 0.5; scrim = 0.5; panelOp = 0; }
  if (phase === 'panel') { panelRise = 120; panelOp = 0.95; scrim = 0.8; }
  let bo = phase === 'hold' ? '' : '';
  const boardHtml = phase === 'hold'
    ? board(id, g, { grid: L1_WON, wonRow: 0, dimAll: 0, rowsDim: 0, lift: null, ...(id === 'A' ? {} : {}) }).replace(/filter:brightness\([\d.]+\);/g, '')
    : board(id, g, st);
  const dimmed = phase === 'hold' ? '' : '';
  const scrimEl = id === 'A'
    ? `<div style="position:absolute;inset:0;background:rgba(0,0,0,${0.4 * scrim})"></div>`
    : `<div style="position:absolute;inset:0;background:rgba(239,232,216,${0.5 * scrim})"></div>`;
  const chrome = `${bgFor(id)}${targetRail(id, g, L1.target, 0.6)}${hud(id, g, 2, { opacity: 0.4 })}`;
  // in 'hold' the whole board is lit with the winning row amber in place; others dimmed to 12% by the brightness filter
  let boardOut = boardHtml;
  if (phase === 'hold') {
    boardOut = board(id, g, { grid: L1_WON, wonRow: 0, dimAll: 0 });
    // dim non-winning rows
    boardOut = boardOut.replace(/<div class="tile ([^"]*)" style="([^"]*)"/g, (m, k, s) => (k.includes('win') ? m : `<div class="tile ${k}" style="${s}filter:brightness(${id === 'A' ? 0.45 : 0.55});"`));
  }
  const dock = phase === 'hold' ? '' : dockRow(id, g, L1.target, dockY);
  const pn = phase === 'hold' || phase === 'glide' ? '' : panel(id, g, variant, { top, rise: panelRise, op: panelOp });
  return page(D, W, H, `${chrome}${boardOut}${scrim ? scrimEl : ''}${dock}${pn}${D.status(W)}${D.home(W, H)}`);
}

// ---------------------------------------------------------------- home
function tickRing(id, cx, cy, r, done, current) {
  let out = '';
  for (let i = 0; i < 30; i++) {
    const a = ((i / 30) * 360 - 90) * (Math.PI / 180);
    const isDone = i < done, isCur = i === current;
    const x = cx + r * Math.cos(a), y = cy + r * Math.sin(a), deg = (i / 30) * 360;
    if (id === 'A') {
      const len = isDone ? 15 : 12, w = isDone ? 4 : 3.4;
      const col = isDone ? '#FFC24B' : 'rgba(147,145,170,.42)';
      out += `<div style="position:absolute;left:${x - w / 2}px;top:${y - len / 2}px;width:${w}px;height:${len}px;border-radius:2px;background:${col};transform:rotate(${deg}deg);${isDone ? 'box-shadow:0 0 8px rgba(255,194,75,.5)' : ''}"></div>`;
      if (isCur) out += `<div style="position:absolute;left:${x - 9}px;top:${y - 9}px;width:18px;height:18px;border-radius:50%;background:radial-gradient(#FFD874,#FFB020);box-shadow:0 0 0 4px rgba(255,194,75,.25),0 0 18px rgba(255,194,75,.8)"></div>`;
    } else {
      const len = isDone ? 16 : 11, w = isDone ? 3.2 : 1.6;
      const col = isDone ? '#C7361F' : 'rgba(27,24,21,.7)';
      out += `<div style="position:absolute;left:${x - w / 2}px;top:${y - len / 2}px;width:${w}px;height:${len}px;background:${col};transform:rotate(${deg}deg)"></div>`;
      if (isCur) out += `<div style="position:absolute;left:${x - 11 + 1.6}px;top:${y - 11 + 1.2}px;width:22px;height:22px;border-radius:50%;border:2px solid #2C4C86"></div><div style="position:absolute;left:${x - 11}px;top:${y - 11}px;width:22px;height:22px;border-radius:50%;background:#C7361F;border:2px solid #FBF7EC;box-shadow:0 0 0 1.5px #C7361F"></div>`;
    }
  }
  return out;
}
function screenHome(id, W, H) {
  const D = dirOf(id), done = 3, current = 3;
  if (id === 'A') {
    const cx = W / 2, cy = Math.round(H * 0.415), r = 116;
    const body = `${bgFor(id)}${D.status(W)}
      <div style="position:absolute;top:${Math.round(H * 0.198)}px;left:0;width:${W}px;text-align:center;font:800 34px/1 Sora;letter-spacing:.34em;padding-left:.34em;text-shadow:0 0 26px rgba(120,100,220,.45)">LO<svg width="26" height="26" viewBox="0 0 26 26" style="vertical-align:-1.5px;margin:0 .13em 0 .11em;overflow:visible"><circle cx="13" cy="13" r="10.6" fill="none" stroke="#F4EFE6" stroke-width="4.6"/><circle cx="13" cy="13" r="10.6" fill="none" stroke="#FFC24B" stroke-width="5" stroke-linecap="round" stroke-dasharray="9 58" stroke-dashoffset="-2" transform="rotate(-70 13 13)"/></svg>PLET</div>
      ${tickRing('A', cx, cy, r, done, current)}
      <div class="lbl" style="position:absolute;top:${cy - 50}px;left:0;width:${W}px;text-align:center;letter-spacing:.24em">SEVİYE</div>
      <div style="position:absolute;top:${cy - 26}px;left:0;width:${W}px;text-align:center"><span class="num" style="font-size:66px;font-weight:800">${done}</span><span class="num" style="font-size:26px;color:#9391AA;margin-left:10px">/ 30</span></div>
      <div class="cta" style="left:${W / 2 - 134}px;top:${Math.round(H * 0.579)}px;width:268px;height:58px;border-radius:29px;font-size:16px;background:linear-gradient(#FFC94F,#FFB020);color:#2A1B00;box-shadow:0 12px 30px rgba(255,176,32,.32),inset 0 1px 0 rgba(255,255,255,.5)">DEVAM ET</div>
      <div style="position:absolute;top:${Math.round(H * 0.579) + 76}px;left:0;width:${W}px;text-align:center;font:400 14px/1 Sora;color:#9391AA">Seviye 4 · sürüyor</div>${D.home(W, H)}`;
    return page(D, W, H, body);
  }
  const cx = W / 2, cy = Math.round(H * 0.44), r = 112;
  const body = `${bgFor(id)}${D.status(W)}
    <div style="position:absolute;top:${Math.round(H * 0.105)}px;left:26px;right:26px">
      <div class="lbl" style="display:flex;justify-content:space-between"><span>Bulmaca Oyunu</span><span>Sayı 4</span></div>
      <div style="font:800 60px/1 Newsreader;letter-spacing:.005em;margin-top:14px;font-variation-settings:'opsz' 72">Looplet</div>
      <div class="rule2" style="position:relative;margin-top:14px;width:100%;color:#1B1815"></div>
    </div>
    ${tickRing('B', cx, cy, r, done, current)}
    <div class="lbl" style="position:absolute;top:${cy - 52}px;left:0;width:${W}px;text-align:center">SEVİYE</div>
    <div style="position:absolute;top:${cy - 34}px;left:0;width:${W}px;text-align:center"><span class="num" style="font-size:76px">${done}</span><span class="num" style="font-size:28px;color:#6C6353;margin-left:8px;font-weight:600">/ 30</span></div>
    <div class="cta" style="left:26px;top:${Math.round(H * 0.66)}px;width:${W - 52}px;height:60px;font-size:16px;background:#1B1815;color:#FBF7EC;border-radius:2px;box-shadow:0 6px 0 rgba(27,24,21,.2)">Devam Et<span style="margin-left:16px;color:#E8583F;font-size:20px">→</span></div>
    <div style="position:absolute;top:${Math.round(H * 0.66) + 78}px;left:0;width:${W}px;text-align:center;font:italic 500 16px/1 Newsreader;color:#1B1815;font-variation-settings:'opsz' 14">Seviye 4 · sürüyor</div>${D.home(W, H)}`;
  return page(D, W, H, body);
}

// ---------------------------------------------------------------- specimen (glyph, figures, roles, colour + real contrast)
function lum(hex) {
  const n = parseInt(hex.slice(1), 16), f = (v) => { v /= 255; return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; };
  return 0.2126 * f((n >> 16) & 255) + 0.7152 * f((n >> 8) & 255) + 0.0722 * f(n & 255);
}
const cr = (a, b) => { const x = lum(a), y = lum(b), hi = Math.max(x, y), lo = Math.min(x, y); return ((hi + 0.05) / (lo + 0.05)).toFixed(1); };
function specimen(id) {
  const D = dirOf(id), W = 786, H = 1100;
  const c = D.c;
  const tiles = (word, size) => [...word].map((ch) => `<div class="tile" style="position:relative;display:inline-flex;margin:0 6px 6px 0;width:${size}px;height:${size}px;font-size:${id === 'A' ? size * 0.46 : size * 0.62}px"><span>${ch}</span></div>`).join('');
  const bg = id === 'A' ? '#0B0C16' : '#EFE8D8', fg = id === 'A' ? '#F4EFE6' : '#1B1815';
  const rows = id === 'A'
    ? [['Ink on tile (glyph)', c.ink, c.tileHi], ['Amber CTA text', c.inkAmber, c.amber], ['Muted label on stage', c.muted, c.stage0], ['Paper on stage (numbers)', c.paper, c.stage0], ['Amber on sheet (ÇÖZÜLDÜ)', c.amber, c.sheet], ['Muted on sheet (Kapat)', c.muted, c.sheet]]
    : [['Ink on tile (glyph)', c.ink, c.cream], ['Cream on vermilion (win tile)', c.cream, c.vermilion], ['Muted label on paper', c.muted, c.paper], ['Ink on paper (numbers)', c.ink, c.paper], ['Vermilion on cream (ÇÖZÜLDÜ)', c.vermilion, c.cream], ['Cream on ink (CTA)', c.cream, c.ink]];
  const ratios = rows.map(([n, a, b]) => `<tr><td>${n}</td><td><i style="display:inline-block;width:14px;height:14px;background:${a};border:1px solid #888;vertical-align:-2px"></i> ${a}</td><td><i style="display:inline-block;width:14px;height:14px;background:${b};border:1px solid #888;vertical-align:-2px"></i> ${b}</td><td><b>${cr(a, b)} : 1</b></td></tr>`).join('');
  const body = `${id === 'A' ? '<div style="position:absolute;inset:0;background:#0B0C16"></div>' : '<div class="paper"></div>'}
  <div style="position:absolute;left:40px;top:34px;right:40px;color:${fg}">
    <div class="lbl">DIRECTION ${id} — ${D.name.toUpperCase()} · TYPE, GLYPH AND FIGURE SPECIMEN</div>
    <div style="margin-top:22px">${tiles('İıŞĞÇÖÜ'.toUpperCase().replace('Iİ', 'İ'), 62)}</div>
    <div style="margin-top:2px;font-size:15px;opacity:.7" class="lbl">Turkish capitals in tile context — İ  I  Ş  Ğ  Ç  Ö  Ü (dotted İ and dotless I both present)</div>
    <div style="margin-top:22px">${tiles('ASLAN', 62)}&nbsp;&nbsp;${tiles('ÖZGÜR', 62)}</div>
    <div style="margin-top:10px">${tiles('ŞİŞE', 62)}&nbsp;&nbsp;${tiles('ÇÖZÜLDÜ', 46)}</div>
    <div style="margin-top:26px;display:flex;gap:46px;align-items:flex-end">
      <div><div class="lbl">HAMLE — tabular</div><div class="num" style="font-size:${id === 'A' ? 44 : 60}px;margin-top:10px">0 1 1 1 1<br>8 8 8 8 8</div></div>
      <div><div class="lbl">Progress</div><div class="num" style="font-size:${id === 'A' ? 44 : 60}px;margin-top:10px">3 <span style="font-size:22px;opacity:.6">/ 30</span></div></div>
      <div><div class="lbl">Title</div><div style="font:${id === 'A' ? '800 34px Sora;letter-spacing:.14em' : '800 46px Newsreader;font-variation-settings:\'opsz\' 72'};margin-top:10px">ÇÖZÜLDÜ</div></div>
    </div>
    <div style="margin-top:28px;display:flex;gap:34px;align-items:center" class="lbl">ICONS<span style="display:flex;gap:22px">${['back', 'undo', 'restart', 'pin', 'snow', 'chevUpDown'].map((k) => ICON[id][k](fg, 34)).join('')}</span><span style="display:flex;gap:10px">${starSvg(id, true, 40)}${starSvg(id, true, 40)}${starSvg(id, false, 40)}</span></div>
    <div style="margin-top:34px" class="lbl">CONTRAST — WCAG 2.x (computed from the token hex values)</div>
    <table style="margin-top:12px;border-collapse:collapse;font:13px/1.9 ${id === 'A' ? 'Sora' : 'Newsreader'};color:${fg}"><tr style="text-align:left;opacity:.6"><th style="width:270px">Pair</th><th style="width:150px">Foreground</th><th style="width:150px">Background</th><th>Ratio</th></tr>${ratios}</table>
    <div style="margin-top:22px;font-size:13px;opacity:.75;line-height:1.5;font-family:${id === 'A' ? 'Sora' : 'Newsreader'}">Family: ${id === 'A' ? 'Sora (variable 100–800), SIL OFL 1.1 — one family for tile glyphs, display, labels, numbers; tnum verified.' : 'Newsreader (variable opsz 6–72, wght 200–800), SIL OFL 1.1 — one family for tile glyphs, display, labels, numbers; default figures are tabular.'}<br>Bundled as an app asset (${id === 'A' ? '≈ 109 KB' : '≈ 441 KB'} unsubsetted${id === 'A' ? '' : '; subsetting to Latin Extended shrinks it'}); no network font loading; no system-font fallback in final renders.</div>
  </div>`;
  return page(D, W, H, body);
}

// ---------------------------------------------------------------- emit
const jobs = [];
const emit = (name, html, W, H) => { fs.writeFileSync(path.join(OUT, name + '.html'), html); jobs.push(`${name} ${W} ${H}`); };
for (const id of ['A', 'B']) {
  const W = 393, H = 852;
  emit(`${id}-01-play-idle`, screenPlay(id, W, H, 'idle'), W, H);
  emit(`${id}-02-play-lifted-row`, screenPlay(id, W, H, 'lift'), W, H);
  emit(`${id}-03-play-locked-frozen`, screenPlay(id, W, H, 'pieces'), W, H);
  emit(`${id}-04-won-perfect`, screenWon(id, W, H, 'perfect'), W, H);
  emit(`${id}-05-won-two-star`, screenWon(id, W, H, 'two'), W, H);
  emit(`${id}-06-home-in-progress`, screenHome(id, W, H), W, H);
  emit(`${id}-07-tutorial-column`, screenTutorial(id, W, H), W, H);
  emit(`${id}-08-motion-t0-hold`, screenWon(id, W, H, 'perfect', 'hold'), W, H);
  emit(`${id}-09-motion-t600-glide`, screenWon(id, W, H, 'perfect', 'glide'), W, H);
  emit(`${id}-10-motion-t760-panel`, screenWon(id, W, H, 'perfect', 'panel'), W, H);
  // device variants for the critical states (16e 390x844, 16 Pro Max 440x956)
  for (const [tag, w, h] of [['16e', 390, 844], ['promax', 440, 956]]) {
    emit(`${id}-v-${tag}-play-idle`, screenPlay(id, w, h, 'idle'), w, h);
    emit(`${id}-v-${tag}-won-perfect`, screenWon(id, w, h, 'perfect'), w, h);
  }
  emit(`${id}-90-specimen`, specimen(id), 786, 1100);
}
fs.writeFileSync(path.join(OUT, 'jobs.txt'), jobs.join('\n') + '\n');
console.log(jobs.length + ' pages');
