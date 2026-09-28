#!/usr/bin/env python3
"""qa-timing-d2 — QA's own reading of a qa-probe-d2 CSV (F03-QA-D2).

  python3 qa-timing-d2.py <probe.csv> <row> <Wpt> <Hpt> [--reduced]

T0 (independent of the Frontend's chrome-dim fit): the first frame with >= 40 lime pixels inside
the board. The fill of tile 0 begins at T0, so this frame is at T0 + (0 … one frame); the report
gives times from that frame, i.e. a conservative (late) T0 — events it reports "before 600" are at
most one frame later in real time.

Reports:
* lime outside the board card before T0 + 600 (must be 0 — nothing of the result, §20.3 (1));
* the lime bbox vs the winning row's own board cells before 600 (C2: displacement <= 0.5 pt,
  sampled on a 2-px grid = 0.67 pt at @3x, so a tolerance of 1.0 pt is used and stated);
* first frame the lime leaves the row cells, first lime outside the board (the glide);
* the last frame the lime bbox changes (the row lands) and the first frame of the pill lime.
"""
import csv
import sys


def main():
    path, row, W, H = sys.argv[1], int(sys.argv[2]), float(sys.argv[3]), float(sys.argv[4])
    reduced = '--reduced' in sys.argv
    s = W / 358.0
    e = max(0.0, H - 717 * s)
    left = 24.75 * s + 11 * s
    top = 261.5 * s + 0.3 * e + 11 * s + row * 58.5 * s
    tile, stride = 52 * s, 58.5 * s
    cell = (left, top, left + 4 * stride + tile, top + tile)
    rows = list(csv.DictReader(open(path)))
    t0 = None
    for r in rows:
        if int(r['limeInside']) >= 40:
            t0 = float(r['t'])
            break
    if t0 is None:
        print('no lime fill found')
        return 1
    ms = lambda r: (float(r['t']) - t0) * 1000
    prev = [r for r in rows if float(r['t']) < t0]
    print('T0 (first lime frame) = %.4f s; previous frame %.1f ms earlier' %
          (t0, (t0 - float(prev[-1]['t'])) * 1000 if prev else float('nan')))
    before = [r for r in rows if 0 <= ms(r) < 600]
    out_before = max((int(r['limeOutside']) for r in before), default=0)
    print('frames in [T0, T0+600): %d; max lime px outside the board: %d' % (len(before), out_before))
    worst = 0.0
    for r in before:
        if not r['minX']:
            continue
        box = tuple(float(r[k]) for k in ('minX', 'minY', 'maxX', 'maxY'))
        # displacement of the lime box beyond the row's own cells (0 while it sits on them)
        d = max(cell[0] - box[0], cell[1] - box[1], box[2] - cell[2], box[3] - cell[3], 0.0)
        worst = max(worst, d)
    print('C2: max lime extent beyond the row cells before 600: %.2f pt (grid 0.67 pt)' % worst)
    for r in rows:
        if ms(r) < 0 or not r['minX']:
            continue
        box = tuple(float(r[k]) for k in ('minX', 'minY', 'maxX', 'maxY'))
        d = max(cell[0] - box[0], cell[1] - box[1], box[2] - cell[2], box[3] - cell[3], 0.0)
        if d > 1.0:
            print('row lime first beyond its cells (> 1 pt): T0 +%.0f ms' % ms(r))
            break
    for r in rows:
        if ms(r) >= 0 and int(r['limeOutside']) > 50:
            print('first lime outside the board (> 50 px): T0 +%.0f ms' % ms(r))
            break
    last = None
    for a, b in zip(rows, rows[1:]):
        if ms(b) > 0 and (a['minY'], a['maxY'], a['limeOutside']) != (b['minY'], b['maxY'], b['limeOutside']):
            last = b
    if last is not None:
        print('last frame any lime changes (rest incl. stars / pill): T0 +%.0f ms' % ms(last))
    gaps = [(ms(a), (float(b['t']) - float(a['t'])) * 1000) for a, b in zip(rows, rows[1:])
            if -50 <= ms(a) <= 1400 and (float(b['t']) - float(a['t'])) * 1000 > 30]
    print('frame gaps > 30 ms in T0-50 … T0+1400: ' + (', '.join('+%.0f (%.0f ms)' % g for g in gaps) or 'none'))
    if reduced:
        moved = [ms(r) for r in rows if ms(r) >= 0 and r['minY'] and
                 abs(float(r['minY']) - cell[1]) > 1.0 and int(r['limeInside']) > 40]
        print('reduced: first frame with lime off the row inside the board: %s' %
              ('T0 +%.0f' % moved[0] if moved else 'none'))


if __name__ == '__main__':
    sys.exit(main())
