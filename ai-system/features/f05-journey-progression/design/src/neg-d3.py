# neg-d3.py <name> <file> <old> <new> '<test files>' — one F05-FE-D3 negative run: replace exactly one
# occurrence of <old> in <file> (run from app/), run the tests, restore the file from a byte copy.
# Needs SP=<a scratch folder> for the copy. Prints the failing tests.
import sys, shutil, subprocess, re, os
name, path, old, new, tests = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5].split()
bak = os.environ['SP'] + '/' + os.path.basename(path) + '.bak'
shutil.copyfile(path, bak)
s = open(path).read()
assert s.count(old) == 1, (name, 'pattern count', s.count(old))
open(path, 'w').write(s.replace(old, new))
try:
    out = subprocess.run(['flutter', 'test', '-r', 'expanded', *tests], capture_output=True, text=True).stdout
finally:
    shutil.copyfile(bak, path)
fails = sorted(set(l.split(': ', 1)[-1] for l in out.splitlines() if l.endswith('[E]')))
last = [l for l in out.splitlines() if 'tests passed' in l or 'tests failed' in l]
print(f'{name}: {len(fails)} failing — {last[-1].split(": ")[-1] if last else "?"}')
for f in fails: print('   ', f.replace('/Users/eyupcandabakoglu/Projects/Looplet/app/', ''))
