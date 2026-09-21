#!/usr/bin/env python3
"""F00-FE-DESIGN-SYSTEM parity boards: design/S-91-components.png (source render) beside the runtime
gallery (`app/lib/main_gallery.dart`) captured on the iPhone 16 simulator (1179 x 2556 px).

usage: python3 parity-board.py <dir-with-g_16_<offset>.png> <out-dir>
Writes three HTML boards next to the captures; render them with render.sh-style headless Chrome
(`--window-size=<w>,<h> --force-device-scale-factor=1`). Crop rectangles are in *native* pixels of each
source image; both sides of a pair are scaled to the same displayed height, so only shape, colour, glow,
type and icon drawing are compared (specimen sizes differ by design: see frontend.md "Deviations").
"""
import sys, pathlib

SRC = pathlib.Path(__file__).resolve().parent.parent / "S-91-components.png"
CAP = pathlib.Path(sys.argv[1]).resolve()
OUT = pathlib.Path(sys.argv[2]).resolve()
S_W, S_H = 1240, 1500          # S-91 native
D_W, D_H = 1179, 2556          # iPhone 16 native
F = D_H / 1500                 # review contact sheets were 1500 px high with 10 px padding


def dev(screen, sx0, sy0, sx1, sy1, offx):
    """Device crop from contact-sheet coordinates -> native px (x, y, w, h)."""
    return (screen, (sx0 - offx) * F, (sy0 - 10) * F, (sx1 - sx0) * F, (sy1 - sy0) * F)


def crop(img, iw, ih, x, y, w, h, disp_h):
    k = disp_h / h
    return (f'<div class="c" style="width:{w * k:.1f}px;height:{disp_h}px;background:url(\'{img}\') no-repeat;'
            f'background-size:{iw * k:.1f}px {ih * k:.1f}px;background-position:{-x * k:.1f}px {-y * k:.1f}px"></div>')


def s91(x, y, w, h, disp_h):
    return crop(SRC.as_uri(), S_W, S_H, x, y, w, h, disp_h)


C03 = SRC.parent / "C-03-play-locked-frozen.png"   # 786 x 1704: play frame with lock / snowflake icons


def frame(x, y, w, h, disp_h):
    return crop(C03.as_uri(), 786, 1704, x, y, w, h, disp_h)


def runtime(c, disp_h):
    screen, x, y, w, h = c
    return crop((CAP / f"g_16_{screen}.png").as_uri(), D_W, D_H, x, y, w, h, disp_h)


def pair(label, a, b, tag="S-91"):
    return (f'<div class="pair"><div class="row"><div class="cell"><span class="tag">{tag}</span>{a}</div>'
            f'<div class="cell"><span class="tag rt">iPhone 16 runtime</span>{b}</div></div>'
            f'<div class="lab">{label}</div></div>')


CSS = """
body{margin:0;background:#04081a;color:#f4f6ff;font:500 13px/1.3 -apple-system,Helvetica,Arial,sans-serif;padding:26px 30px}
h1{font:600 15px/1.2 -apple-system,Helvetica,Arial,sans-serif;letter-spacing:.12em;text-transform:uppercase;margin:0 0 4px}
p.n{margin:0 0 18px;color:#aeb4ca;max-width:1300px}
.grid{display:flex;flex-wrap:wrap;gap:22px 26px}
.pair{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.1);border-radius:14px;padding:12px 14px}
.row{display:flex;gap:16px;align-items:flex-end}
.cell{display:flex;flex-direction:column;gap:6px}
.c{border-radius:6px;background-color:#070c25}
.tag{font:600 10px/1 -apple-system,Helvetica,Arial,sans-serif;letter-spacing:.14em;text-transform:uppercase;color:#aeb4ca}
.tag.rt{color:#a8b4f9}
.lab{margin-top:8px;color:#f4f6ff}
"""


def board(name, title, note, pairs, w, h):
    html = (f'<!doctype html><meta charset="utf-8"><title>{title}</title><style>{CSS}</style>'
            f'<h1>{title}</h1><p class="n">{note}</p><div class="grid">{"".join(pairs)}</div>')
    (OUT / f"{name}.html").write_text(html)
    print(f"{name} {w}x{h}")


# ---------------------------------------------------------------- board 1: tiles + wordmark
HALF_S, HALF_D = 48, 123
tiles = [  # label, S-91 centre, runtime (screen, centre in review-sheet coords, offx)
    ("Normal", (82, 791), (640, 137, 762, 10)),
    ("Active row (periwinkle rim + lift)", (205, 791), (640, 311, 762, 10)),
    ("Winning (lime glow)", (328, 791), (640, 485, 762, 10)),
    ("Locked pivot (indigo + lock)", (446, 791), (640, 137, 955, 10)),
    ("Frozen (ice + snowflake + dashed)", (602, 791), (640, 311, 955, 10)),
    ("Inactive (dimmed rows)", (771, 791), (640, 485, 955, 10)),
    ("Ghost slot", (902, 791), (640, 137, 1148, 10)),
    ("Target rail tile", (1005, 779), (640, 312, 1149, 10)),
]
p1 = []
for label, (sx, sy), (scr, cx, cy, ox) in tiles:
    ncx, ncy = (cx - ox) * F, (cy - 10) * F
    p1.append(pair(label, s91(sx - HALF_S, sy - HALF_S, 2 * HALF_S, 2 * HALF_S, 150),
                   runtime((scr, ncx - HALF_D, ncy - HALF_D, 2 * HALF_D, 2 * HALF_D), 150)))
for label, (fx, fy), (scr, cx, cy, ox) in [
    ("Locked pivot + lock icon (play frame C-03: the S-91 specimen tile omits the icon its legend names)", (135, 693), (640, 137, 955, 10)),
    ("Frozen: ice + snowflake + dashed edge over a solid ring (play frame C-03)", (392, 950), (640, 311, 955, 10)),
]:
    ncx, ncy = (cx - ox) * F, (cy - 10) * F
    p1.append(pair(label, frame(fx - 72, fy - 72, 144, 144, 150),
                   runtime((scr, ncx - HALF_D, ncy - HALF_D, 2 * HALF_D, 2 * HALF_D), 150), tag="C-03"))
p1.append(pair("Wordmark: Looplet (capital L, last three letters lime)",
               s91(34, 60, 230, 80, 90),
               runtime(dev(0, 47, 180, 372, 285, 10), 90)))
board("parity-board-1-tiles", "Tile states + wordmark: S-91 vs runtime",
      "Both sides are scaled so the tile edge is the same size (the sheet specimen is 76 px, the gallery tile 60 pt x scale). "
      "Compare corner radius (33 %), cream gradient, periwinkle rim, lime glow, lock/snowflake icons, dashed border, dimming.",
      p1, 1500, 900)

# ---------------------------------------------------------------- board 2: controls
p2 = [
    pair("Primary pill with glow (LimePill glow)", s91(24, 916, 340, 88, 90),
         runtime(dev(1280, 718, 204, 1398, 371, 712), 90)),
    pair("Secondary outline pill", s91(346, 916, 260, 88, 70),
         runtime(dev(1280, 745, 505, 1371, 623, 712), 70)),
    pair("Text link + disabled link (suffix 'yakında')", s91(600, 940, 440, 40, 34),
         runtime(dev(1280, 750, 635, 1290, 685, 712), 34)),
    pair("Undo pill with quota dots", s91(1046, 925, 120, 70, 84),
         runtime(dev(1280, 750, 705, 958, 815, 712), 84)),
    pair("Restart + back squares", s91(34, 1016, 130, 64, 76),
         runtime(dev(1280, 962, 710, 1160, 808, 712), 76)),
    pair("Badge (olive glass, lime label)", s91(166, 1016, 132, 62, 70),
         runtime(dev(1280, 750, 822, 980, 920, 712), 70)),
    pair("Moves card + star row", s91(300, 1006, 210, 84, 84),
         runtime(dev(1280, 750, 928, 1105, 1066, 712), 84)),
]
board("parity-board-2-controls", "Controls: S-91 vs runtime",
      "Pairs are scaled to the same height. The runtime pills are full-width in the gallery (the sheet shows content-width specimens); "
      "compare gradient, glow, radius, stroke, type weight and icon drawing.",
      p2, 1500, 800)

# ---------------------------------------------------------------- board 3: cards, track, icons
p3 = [
    pair("Stat card (slate): SEN / OPTİMAL / EN İYİ", s91(34, 1094, 350, 104, 110),
         runtime(dev(1280, 748, 1150, 1368, 1316, 712), 110)),
    pair("Journey glass card (headline: see deviations, S-91 specimen uses 22, spec role is 28)",
         s91(394, 1094, 400, 104, 130), runtime(dev(1920, 47, 199, 665, 460, 10), 130)),
    pair("Loop track: done nodes, current node with halo", s91(794, 1094, 280, 104, 100),
         runtime(dev(1920, 47, 478, 560, 640, 10), 100)),
    pair("Icon set (12 icons + earned / empty star)", s91(34, 1205, 480, 53, 60),
         runtime(dev(1920, 47, 750, 630, 905, 10), 110)),
]
board("parity-board-3-cards-icons", "Cards, stats, track, icons: S-91 vs runtime",
      "Pairs are scaled to the same height (the runtime icon block wraps to two rows in the gallery).",
      p3, 1500, 900)
