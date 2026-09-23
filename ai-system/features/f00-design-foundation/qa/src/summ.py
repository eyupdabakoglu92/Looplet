import re,sys,glob,os
comps=['MovesCard','StatCard','LoopBadge','UndoPill','OutlinePill','LimePill','TextLink','GlassIconButton','LoopNode','StarRow','TileFace','GlassCard','LoopletWordmark','RailTile','GhostSlot','_Controls','_Cards','_Icons','_TypeRoles','_GlyphCheck','_TileStates','_EdgeScreen']
order=['large','extra-large','extra-extra-large','extra-extra-extra-large','accessibility-medium','accessibility-large','accessibility-extra-large','accessibility-extra-extra-large','accessibility-extra-extra-extra-large']
for m in ('gallery','edge'):
    print('==',m)
    for cs in order:
        p=f'sweep/{m}_{cs}.log'
        L=[l for l in open(p,errors='ignore') if 'QAPROBE' in l]
        env=[l for l in L if 'QAPROBE env' in l]
        ts=re.search(r'textScale=([\d.]+)',env[0]).group(1) if env else '?'
        errs=[re.sub(r'^.*QAPROBE flutter-error: ','',l).strip() for l in L if 'flutter-error:' in l]
        wid=[re.sub(r'^.*QAPROBE flutter-error-widget: ','',l).strip() for l in L if 'flutter-error-widget:' in l]
        rows=[]
        for e,w in zip(errs,wid):
            amt=re.search(r'overflowed by ([\d.]+) pixels on the (\w+)',e)
            chain=w.split(' ⏎ ')[0]
            who=[c for c in comps if c in chain]
            rows.append(f"{amt.group(1)}px/{amt.group(2)} in {'+'.join(who[:2]) or '?'}" if amt else e[:40])
        print(f'  {cs:36s} scale {float(ts):.2f}  overflows={len(errs)}  ', '; '.join(rows))
