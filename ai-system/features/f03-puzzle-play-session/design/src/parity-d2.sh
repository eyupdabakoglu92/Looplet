#!/bin/sh
# parity-d2.sh — render-vs-runtime lime-band measurements and composites for F03-FE-D2.
# Needs the compiled parity tool: swiftc -O src/parity-d2.swift -o <tool>; PARITY_D2=<tool>.
set -e
cd "$(dirname "$0")/.."
T="${PARITY_D2:?set PARITY_D2 to the compiled parity-d2 tool}"
OUT=runtime-d2/parity-measurements.txt
: > "$OUT"
while read -r id render runtime; do
  [ -z "$id" ] && continue
  echo "== $id: $render.png (@2x) vs runtime-d2/$runtime.png (@3x)" >> "$OUT"
  echo "-- render" >> "$OUT";  "$T" bands "$render.png" 2 >> "$OUT"
  echo "-- runtime" >> "$OUT"; "$T" bands "runtime-d2/$runtime.png" 3 >> "$OUT"
  "$T" compose "runtime-d2/$id.jpg" "$render.png" "runtime-d2/$runtime.png" > /dev/null
done <<'PAIRS'
PC-D2-01 D2-01-result-perfect RT-16-D2-01-perfect
PC-D2-02 D2-02-result-perfect-new-best RT-16-D2-02-perfect-new-best
PC-D2-03 D2-03-result-new-best-2star RT-16-D2-03-new-best-2star
PC-D2-04 D2-04-result-first-clear-2star RT-16-D2-04-first-clear-2star
PC-D2-05 D2-05-result-matched-best RT-16-D2-05-matched-best
PC-D2-06 D2-06-result-1star-no-improvement RT-16-D2-06-1star-no-improvement
PC-D2-08 D2-08-result-next-not-wired RT-16-D2-08-next-not-wired
PC-D2-09 D2-09-result-level30-perfect RT-16-D2-09-level30-perfect
PC-D2-09b D2-09b-result-level30-2star RT-16-D2-09b-level30-2star
PC-D2-10 D2-10-result-text-cap-1_3 A11Y-16-result-extra-extra-extra-large
PC-D2-10b D2-10b-result-ax5-top A11Y-16-result-accessibility-extra-extra-extra-large
PC-D2-10c D2-10c-result-ax5-scrolled-end A11Y-16-result-ax5-scrolled-end
PC-D2-v-16e-perfect D2-v-16e-result-perfect RT-16e-L4-result-perfect
PC-D2-v-16e-1star D2-v-16e-result-1star RT-16e-D2-06-1star
PC-D2-v-16e-cap D2-v-16e-result-text-cap-1_3 A11Y-16e-result-extra-extra-extra-large
PC-D2-v-16e-ax5 D2-v-16e-result-ax5-top A11Y-16e-result-accessibility-extra-extra-extra-large
PC-D2-v-promax-new-best D2-v-promax-result-perfect-new-best RT-promax-D2-02-perfect-new-best
PC-D2-v-promax-cap D2-v-promax-result-text-cap-1_3 A11Y-promax-result-extra-extra-extra-large
PAIRS
echo "wrote $OUT"
