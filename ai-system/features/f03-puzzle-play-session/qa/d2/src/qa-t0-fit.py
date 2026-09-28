#!/usr/bin/env python3
"""qa-t0-fit — QA's own T0 fit from the goal-rail dim (F03-QA-D2).

  python3 qa-t0-fit.py <rail-luma.csv> <probe.csv> <row> <Wpt> <Hpt> [--reduced]

T0 = the start of the chrome dim (1 -> 0.5 over 0-200 ms, Flutter Curves.easeOut =
Cubic(0, 0, .58, 1)), fitted per frame from the rail luma (pre-level = median of the frames
before the first drop, post-level = the plateau 250-500 ms later); the report gives the median
and spread over the frames inside the dim. Reduced motion: the dim is a state at T0 (0.5), so T0
is bracketed by the last undimmed and first dimmed frames instead.
Then, against that T0: the last frame with the winning-row lime on its own cells and the first
frame it has left them (> 1 pt beyond the cells; the probe samples a 2-px grid = 0.67 pt @3x).
"""
import csv, statistics, sys

def cubic_y(x, x1=0.0, y1=0.0, x2=0.58, y2=1.0):
    lo, hi = 0.0, 1.0
    for _ in range(60):
        m = (lo + hi) / 2
        X = 3 * x1 * (1 - m) ** 2 * m + 3 * x2 * (1 - m) * m * m + m ** 3
        lo, hi = (m, hi) if X < x else (lo, m)
    m = (lo + hi) / 2
    return 3 * y1 * (1 - m) ** 2 * m + 3 * y2 * (1 - m) * m * m + m ** 3

def inv(y):
    lo, hi = 0.0, 1.0
    for _ in range(60):
        m = (lo + hi) / 2
        lo, hi = (m, hi) if cubic_y(m) < y else (lo, m)
    return (lo + hi) / 2

rail = [(float(r['t']), float(r['luma'])) for r in csv.DictReader(open(sys.argv[1]))]
probe = list(csv.DictReader(open(sys.argv[2])))
row, W, H = int(sys.argv[3]), float(sys.argv[4]), float(sys.argv[5])
reduced = '--reduced' in sys.argv
i0 = next(i for i in range(5, len(rail)) if rail[i][1] < statistics.median(l for _, l in rail[:i]) - 2.0)
pre = statistics.median(l for _, l in rail[max(0, i0 - 10):i0])
if reduced:
    t0lo, t0hi = rail[i0 - 1][0], rail[i0][0]
    t0 = t0hi
    print('reduced: T0 in (%.4f, %.4f]; using the first dimmed frame %.4f (late bound)' % (t0lo, t0hi, t0))
else:
    post = statistics.median(l for t, l in rail if rail[i0][0] + 0.25 <= t <= rail[i0][0] + 0.5)
    fits = []
    for t, l in rail[i0:]:
        f = (pre - l) / (pre - post)
        if 0.05 < f < 0.95:
            fits.append(t - inv(f) * 0.2)
        if t > rail[i0][0] + 0.2:
            break
    t0 = statistics.median(fits)
    print('dim fit over %d frames: T0 = %.4f s (spread %.1f ms); last undimmed frame %.4f, first dimmed %.4f'
          % (len(fits), t0, (max(fits) - min(fits)) * 1000, rail[i0 - 1][0], rail[i0][0]))
s = W / 358.0
e = max(0.0, H - 717 * s)
left = 24.75 * s + 11 * s
top = 261.5 * s + 0.3 * e + 11 * s + row * 58.5 * s
cell = (left, top, left + 4 * 58.5 * s + 52 * s, top + 52 * s)
last_on = first_off = None
for r in probe:
    t = float(r['t'])
    if t < t0 or not r['minX'] or int(r['limeInside']) < 1000:
        continue
    b = [float(r[k]) for k in ('minX', 'minY', 'maxX', 'maxY')]
    d = max(cell[0] - b[0], cell[1] - b[1], b[2] - cell[2], b[3] - cell[3], 0.0)
    if d <= 1.0 and first_off is None:
        last_on = t
    elif d > 1.0 and first_off is None:
        first_off = t
print('row on its cells (<= 1 pt) through T0 +%.0f ms; first frame off its cells: T0 +%.0f ms'
      % ((last_on - t0) * 1000, (first_off - t0) * 1000))
