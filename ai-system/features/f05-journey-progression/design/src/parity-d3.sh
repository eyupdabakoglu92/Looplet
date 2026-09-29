#!/bin/sh
# parity-d3.sh — render-vs-runtime lime-band measurements and side-by-side composites for F05-FE-D3.
# Reuses the F03 D2 parity tool: swiftc -O ../../f03-puzzle-play-session/design/src/parity-d2.swift -o <tool>;
# PARITY_D2=<tool> sh src/parity-d3.sh. Renders are @2x, simulator captures @3x.
set -e
cd "$(dirname "$0")/.."
T="${PARITY_D2:?set PARITY_D2 to the compiled parity-d2 tool}"
OUT=runtime-d3/parity-measurements.txt
: > "$OUT"
while read -r id render runtime; do
  [ -z "$id" ] && continue
  echo "== $id: $render.png (@2x) vs runtime-d3/$runtime.png (@3x)" >> "$OUT"
  echo "-- render" >> "$OUT";  "$T" bands "$render.png" 2 >> "$OUT"
  echo "-- runtime" >> "$OUT"; "$T" bands "runtime-d3/$runtime.png" 3 >> "$OUT"
  "$T" compose "runtime-d3/$id.jpg" "$render.png" "runtime-d3/$runtime.png" > /dev/null
done <<'PAIRS'
PC-D3-01 D3-01-home-new-0of30 RT-16-D3-01-new-0of30
PC-D3-01b D3-01b-home-new-level1-in-progress RT-16-D3-01b-new-level1-in-progress
PC-D3-02 D3-02-home-mid-4of30 RT-16-D3-02-mid-4of30
PC-D3-03 D3-03-home-in-progress-4of30 RT-16-D3-03-in-progress-4of30
PC-D3-04a D3-04a-home-window-12of30 RT-16-D3-04a-window-12of30
PC-D3-04b D3-04b-home-window-25of30 RT-16-D3-04b-window-25of30
PC-D3-05 D3-05-home-replay-before-terminal RT-16-D3-05-replay-before-terminal
PC-D3-06 D3-06-home-terminal-30of30 RT-16-D3-06-terminal-30of30
PC-D3-07 D3-07-home-terminal-with-replay RT-16-D3-07-terminal-with-replay
PC-D3-10 D3-10-home-text-cap-1_3 A11Y-16-home-ip12-extra-extra-extra-large
PC-D3-10b D3-10b-home-ax5 A11Y-16-home-ip12-accessibility-extra-extra-extra-large
PC-D3-10c D3-10c-home-ax5-terminal-replay A11Y-16-home-n1-ax5
PC-D3-v-16e-ip D3-v-16e-home-in-progress RT-16e-home-in-progress
PC-D3-v-16e-n1 D3-v-16e-home-terminal-with-replay RT-16e-home-terminal-with-replay
PC-D3-v-16e-cap D3-v-16e-home-text-cap-1_3 A11Y-16e-home-w12-extra-extra-extra-large
PC-D3-v-16e-ax5 D3-v-16e-home-ax5 A11Y-16e-home-w12-ax5
PC-D3-v-promax-ip D3-v-promax-home-in-progress RT-promax-home-in-progress
PC-D3-v-promax-n1 D3-v-promax-home-terminal-with-replay RT-promax-home-terminal-with-replay
PC-D3-v-promax-cap D3-v-promax-home-text-cap-1_3 A11Y-promax-home-w12-extra-extra-extra-large
PC-D3-20c D3-20c-store-error-debug-build RT-16-D3-20c-store-error-debug
PC-D3-20b D3-20b-store-error-ax5 A11Y-16-store-error-ax5-top
PC-D3-20d D3-20d-store-error-ax5-scrolled-end A11Y-16-store-error-ax5-scrolled-end
PC-D3-v-16e-err D3-v-16e-store-error RT-16e-store-error-debug
PC-D3-v-promax-err D3-v-promax-store-error RT-promax-store-error-debug
PC-D3-21 D3-21-launch-ios COLD-16-empty-2.6
PC-D3-22 D3-22-splash COLD-16-empty-4.395
PAIRS
echo "wrote $OUT"
