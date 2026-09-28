#!/usr/bin/env python3
"""timing-d2 — the F03-FE-D2 frame-timing table from a `simctl io recordVideo` capture
(architecture §20.6, §20.7 C2; ui-design §16.11.1 (1)-(6), (13)).

  python3 timing-d2.py win   <video> <W> <H> <row> [--reduced]
  python3 timing-d2.py retry <video> <W> <H> [--reduced]

Regions come from the Play (D1, `play_layout.dart`) and result (§16.6) geometry in points
(s = W / 358, e = H - 717 s), scaled x3 to video pixels. `video-d2` (compiled from
video-d2.swift) traces every decoded frame with its real presentation time.

T0 (win) is the settle frame: tile 0 of the winning row starts to fill on the first frame after
it. The capture only shows T0 inside a window [last unchanged frame, first changed frame]; every
event is reported against both ends, so a bound holds only if it holds for the window.
"""
import csv
import io
import os
import subprocess
import sys

TOOL = os.environ.get('VIDEO_D2', os.path.join(os.path.dirname(__file__), 'video-d2'))
PX = 3  # video pixels per point; set from the video width in main()


def geometry(W, H):
    s = W / 358.0
    e = max(0.0, H - 717 * s)
    e1 = 0.3 * e
    board_left = (358 - 308.5) / 2 * s
    board_top = 261.5 * s + e1
    tile = 52 * s
    stride = 58.5 * s
    return dict(s=s, e=e, e1=e1, board_left=board_left, board_top=board_top, tile=tile, stride=stride)


def rect(x, y, w, h):
    return (int(round(x * PX)), int(round(y * PX)), max(1, int(round(w * PX))), max(1, int(round(h * PX))))


def regions(W, H, row=None):
    g = geometry(W, H)
    s, e = g['s'], g['e']
    r = {
        # empty ground in Play; the result's back button (24, 54)·s, 44 pt
        'back': rect(24 * s + 4, 54 * s + 4, 36, 30),
        # empty ground in Play (between the header and the caption); the result headline
        'head': rect(110 * s, 128 * s + 0.24 * e, 140 * s, 36 * s),
        # the HAMLE card (273.5, 75)·s, 60 x 63·s — chrome
        'moves': rect(273.5 * s + 4, 75 * s + 4, 60 * s - 8, 63 * s - 8),
        # the undo pill (29·s, 592.5·s + e), 98.5 x 50·s — chrome (ground at rest)
        'hud': rect(29 * s + 4, 592.5 * s + e + 4, 98.5 * s - 8, 50 * s - 8),
        # the result's primary pill 485·s + .4 e, 63.5·s tall
        'pill': rect(24 * s + 20, 485 * s + 0.4 * e + 8, 309 * s - 40, 63.5 * s - 16),
        # the result's stars 349·s + .4 e, 19·s
        'stars': rect(120 * s, 349 * s + 0.4 * e, 118 * s, 19 * s),
        # the whole board card
        'board': rect(g['board_left'], g['board_top'], 308.5 * s, 307.5 * s),
        # the rail tiles (the retry lands on them)
        'rail': rect((358 - (5 * 36 + 4 * 8)) / 2 * s, 197 * s + g['e1'], (5 * 36 + 4 * 8) * s, 42 * s),
    }
    if row is not None:
        top = g['board_top'] + 11 * s + row * g['stride']
        left = g['board_left'] + 11 * s
        r['tile0'] = rect(left + 8 * s, top + 30 * s, 20 * s, 14 * s)  # below the glyph
    return r, g


def trace(video, regs):
    args = [TOOL, 'trace', video] + ['%s:%d:%d:%d:%d' % ((k,) + v) for k, v in regs.items()]
    out = subprocess.run(args, check=True, capture_output=True, text=True).stdout
    rows = []
    for rec in csv.DictReader(io.StringIO(out)):
        rows.append({k: (float(v) if k.endswith('_luma') or k == 't' else v) for k, v in rec.items()})
    return rows


def lime_box(rec, name):
    n = int(rec[name + '_lime'])
    if n == 0:
        return None
    return tuple(int(rec[name + '_' + k]) for k in ('x0', 'y0', 'x1', 'y1')), n


def settle_time(rows, name, after, tol=0.6):
    """The first time from which the region's luma stays within tol of its final value."""
    final = rows[-1][name + '_luma']
    t = None
    for rec in rows:
        if rec['t'] < after:
            continue
        if abs(rec[name + '_luma'] - final) > tol:
            t = None
        elif t is None:
            t = rec['t']
    return t, final


def first_change(rows, name, after, tol):
    base = None
    for rec in rows:
        if rec['t'] < after:
            base = rec[name + '_luma']
            continue
        if base is None:
            base = rec[name + '_luma']
            continue
        if abs(rec[name + '_luma'] - base) > tol:
            return rec['t']
    return None


def ms(x):
    return '%7.1f' % (x * 1000) if x is not None else '    n/a'


def cubic(x1, y1, x2, y2):
    """Flutter's `Cubic(x1, y1, x2, y2)` as a function of t."""
    def bez(a, b, u):
        return 3 * a * u * (1 - u) ** 2 + 3 * b * u * u * (1 - u) + u ** 3

    def f(t):
        lo, hi = 0.0, 1.0
        for _ in range(60):
            mid = (lo + hi) / 2
            if bez(x1, x2, mid) < t:
                lo = mid
            else:
                hi = mid
        return bez(y1, y2, (lo + hi) / 2)
    return f


EASE_OUT = cubic(0.0, 0.0, 0.58, 1.0)


def inverse(f, y):
    lo, hi = 0.0, 1.0
    for _ in range(60):
        mid = (lo + hi) / 2
        if f(mid) < y:
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2


def t0_from_dim(rows, name, t_after, t_before, duration=0.2):
    """T0 from the chrome dim 1 → 0.5 (ease-out, `duration`): every frame inside the dim gives
    t − easeOut⁻¹(f)·duration; the median of those is T0."""
    pre = [r[name + '_luma'] for r in rows if r['t'] <= t_after]
    base = pre[-1]
    hold = [r[name + '_luma'] for r in rows if t_before + 0.3 <= r['t'] <= t_before + 0.5]
    half = sorted(hold)[len(hold) // 2]
    est = []
    for r in rows:
        if r['t'] <= t_after or r['t'] > t_before + duration + 0.05:
            continue
        f = (base - r[name + '_luma']) / (base - half)
        if 0.08 < f < 0.92:
            est.append(r['t'] - inverse(EASE_OUT, f) * duration)
    est.sort()
    return est[len(est) // 2] if est else None, len(est)


def win(video, W, H, row, reduced):
    regs, g = regions(W, H, row)
    rows = trace(video, regs)
    fps = len(rows) / (rows[-1]['t'] - rows[0]['t'])
    # The settle frame: the winning row leaves the lifted-line dim (42 %) and shows at full
    # strength — tile 0's luma jumps back up in one frame.
    t_settle = None
    for a, b in zip(rows, rows[1:]):
        if b['tile0_luma'] - a['tile0_luma'] > 40 and a['tile0_luma'] < 150:
            t_settle, t_prev = b['t'], a['t']
            break
    if t_settle is None:
        print('no settle found')
        return 1
    if reduced:
        # Reduced: the dim is a state (0.5 at T0) — T0 is the settle frame itself.
        t0, n = t_settle, 0
    else:
        t0, n = t0_from_dim(rows, 'moves', t_prev, t_settle)
    print('video %s — %d frames, %.1f fps average' % (os.path.basename(video), len(rows), fps))
    print('settle frame %.4f s; T0 = %.4f s (%s)' % (
        t_settle, t0, 'the settle frame' if reduced else 'fit to the chrome dim over %d frames' % n))
    gaps = [(a['t'], (b['t'] - a['t']) * 1000) for a, b in zip(rows, rows[1:])
            if t0 - 0.05 <= a['t'] <= t0 + 1.4 and b['t'] - a['t'] > 0.030]
    print('frame gaps > 30 ms in T0-50 … T0+1400: ' + (', '.join('T0%+.0f (%.0f ms)' % ((t - t0) * 1000, d) for t, d in gaps) or 'none'))

    def rel(t):
        return '     n/a' if t is None else '%+8.0f' % ((t - t0) * 1000)

    # C2: the row's lime box, frame by frame, from full fill to the first frame that moves.
    full = None
    worst = 0.0
    last_static = first_moved = None
    for rec in rows:
        if rec['t'] < t0 + (0.0 if reduced else 0.215):
            continue
        b = lime_box(rec, 'board')
        box = b[0] if b else None
        if full is None:
            if box is None:
                continue
            full = box
        d = 999 if box is None else max(abs(box[i] - full[i]) for i in range(4)) / PX
        if d > 0.5:
            first_moved = rec['t']
            break
        worst = max(worst, d)
        last_static = rec['t']
    first_back = first_change(rows, 'back', t_settle, 1.0)
    first_head = first_change(rows, 'head', t_settle, 1.0)
    firsts = [x for x in (first_back, first_head) if x is not None]
    first_result = min(firsts) if firsts else None
    chrome_moves, _ = settle_time(rows, 'moves', t_settle)
    chrome_hud, _ = settle_time(rows, 'hud', t_settle)
    pill_rest, _ = settle_time(rows, 'pill', t_settle)
    stars_rest, _ = settle_time(rows, 'stars', t_settle)
    print('C2   row on its board cells (max displacement %.2f pt) through  T0 %s ms' % (worst, rel(last_static)))
    print('     first frame the row has left its cells (> 0.5 pt):     T0 %s ms' % rel(first_moved))
    print('     first result pixel (back-button / headline slots):     T0 %s ms' % rel(first_result))
    print('     HAMLE card at its final value from:                    T0 %s ms' % rel(chrome_moves))
    print('     HUD at its final value from:                           T0 %s ms' % rel(chrome_hud))
    print('     primary pill at rest from:                             T0 %s ms' % rel(pill_rest))
    print('     stars at rest from:                                    T0 %s ms' % rel(stars_rest))
    return 0


def retry(video, W, H, reduced):
    regs, g = regions(W, H)
    rows = trace(video, regs)
    # T0: the tap. The first frame that differs from the result at rest (the content starts to
    # fade and drop) is at most one frame after it.
    t_first = first_change(rows, 'pill', rows[0]['t'] + 0.3, 1.0)
    prev = [r['t'] for r in rows if r['t'] < t_first]
    t0 = prev[-1] if prev else t_first
    print('video %s — %d frames' % (os.path.basename(video), len(rows)))
    print('T0 = %.4f s (the last frame of the result at rest; the first changed frame is T0%+.0f ms)'
          % (t0, (t_first - t0) * 1000))
    gaps = [(a['t'], (b['t'] - a['t']) * 1000) for a, b in zip(rows, rows[1:])
            if t0 <= a['t'] <= t0 + 0.6 and b['t'] - a['t'] > 0.030]
    print('frame gaps > 30 ms in T0 … T0+600: ' + (', '.join('T0%+.0f (%.0f ms)' % ((t - t0) * 1000, d) for t, d in gaps) or 'none'))

    def rel(t):
        return '     n/a' if t is None else '%+8.0f' % ((t - t0) * 1000)

    lime_on_rail = [r['t'] for r in rows if r['t'] > t0 and int(r['rail_lime']) > 0]
    print('     lime (the flying answer) inside the rail slots:   T0 %s … %s ms' % (
        rel(lime_on_rail[0]) if lime_on_rail else '     n/a', rel(lime_on_rail[-1]) if lime_on_rail else '     n/a'))
    for name, label in (('back', 'result back-button slot'), ('head', 'result headline slot'),
                        ('rail', 'goal rail'), ('moves', 'HAMLE card'), ('board', 'board'), ('hud', 'HUD')):
        t, _ = settle_time(rows, name, t0)
        print('     %-26s at its final value from:  T0 %s ms' % (label, rel(t)))
    return 0


if __name__ == '__main__':
    kind, video, W, H = sys.argv[1], sys.argv[2], float(sys.argv[3]), float(sys.argv[4])
    # Raw simulator captures are 3 px / pt; the committed re-encodes are 588 px wide.
    PX = float(os.environ.get('PX_PER_PT', '3'))
    reduced = '--reduced' in sys.argv
    if kind == 'win':
        sys.exit(win(video, W, H, int(sys.argv[5]), reduced))
    sys.exit(retry(video, W, H, reduced))
