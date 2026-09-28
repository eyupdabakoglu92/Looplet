#!/usr/bin/env python3
"""qa-pill-rest — F03-QA-D2R: from a qa-probe-d2 `luma` CSV of the primary-pill region, the frame the pill reaches
99 % of its final luma and the capture window (last-but-one, last] of its last change > 0.3 luma.
  python3 qa-pill-rest.py <pill.csv> <T0 seconds>"""
import csv, sys
name, T0 = sys.argv[1], float(sys.argv[2])
d=[(float(r['t']),float(r['luma'])) for r in csv.DictReader(open(name))]
w=[(t,l) for t,l in d if T0+0.7<t<T0+1.3]
fin=w[-1][1]; lo=min(l for t,l in w)
p99=next(t for t,l in w if (l-lo)/(fin-lo)>=0.99)
last=max(t for (t0,l0),(t,l) in zip(w,w[1:]) if abs(l-l0)>0.3)
before=max(t for t,l in w if t<last)
print('%s: 99%% +%.0f; last change > 0.3 luma in (+%.0f, +%.0f]'%(name,(p99-T0)*1000,(before-T0)*1000,(last-T0)*1000))
