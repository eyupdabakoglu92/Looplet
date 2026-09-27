#!/bin/sh
# F03-FE-D1 parity: measures every render ↔ runtime pair with measure-d1.swift and writes
# ../runtime-d1/parity-measurements.txt; then builds the side-by-side composites
# (render | runtime | difference) as ../runtime-d1/PC-*.jpg with headless Chrome (+ sips).
# Usage: sh parity-d1.sh        (needs swiftc and Google Chrome; macOS)
set -e
cd "$(dirname "$0")"
D=..
R=../runtime-d1
F00=../../../f00-design-foundation/design
BIN=${TMPDIR:-/tmp}/measure-d1
swiftc -O -o "$BIN" measure-d1.swift
OUT="$R/parity-measurements.txt"
: > "$OUT"
# id | render | runtime | W | H | grid (1 = board idle, 0 = board dimmed / partly covered)
while IFS='|' read -r id render runtime w h grid; do
  [ -z "$id" ] && continue
  case "$id" in \#*) continue;; esac
  echo "=== $id: $(basename "$render") ↔ $(basename "$runtime")" >> "$OUT"
  "$BIN" "$render" 2 "$runtime" 3 "$w" "$h" "$grid" >> "$OUT"
  echo >> "$OUT"
done <<EOF
PC-00|$D/D1-00-play-idle.png|$R/RT-16-00-idle-L5.png|393|852|1
PC-02|$D/D1-02-hud-undo-two-left.png|$R/RT-16-02-hud-undo-two-left.png|393|852|1
PC-03|$D/D1-03-hud-undo-exhausted.png|$R/RT-16-03-hud-undo-exhausted.png|393|852|1
PC-04|$D/D1-04-hud-restart-pressed.png|$R/RT-16-04-hud-restart-pressed.png|393|852|1
PC-05|$D/D1-05-play-locked-frozen-L26.png|$R/RT-16-05-play-locked-frozen-L26.png|393|852|1
PC-01|$D/D1-01-play-column-drag.png|$R/RT-16-01-play-column-drag.png|393|852|0
PC-lift|$D/D1-M-lift-t0400.png|$R/RT-16-lift-row-L5.png|393|852|0
PC-06-t000|$D/D1-06-play-thaw-L23-t000.png|$R/RT-16-06-thaw-L23-t000.png|393|852|0
PC-06-t180|$D/D1-06-play-thaw-L23-t180.png|$R/RT-16-06-thaw-L23-t180.png|393|852|1
PC-08|$D/D1-08-tutorial-hud.png|$R/RT-16-08-tutorial-hud.png|393|852|1
PC-09|$D/D1-09-tutorial-drag-ghost-hidden.png|$R/RT-16-09-tutorial-drag-ghost-hidden.png|393|852|0
PC-10|$D/D1-10-play-text-ax5-capped.png|$R/RT-16-10-a11y-ax5-L26.png|393|852|1
PC-10b|$D/D1-10b-tutorial-text-ax5-capped.png|$R/RT-16-10b-a11y-ax5-tutorial.png|393|852|1
PC-v16e-idle|$F00/S-v-16e-play-idle.png|$R/RT-16e-00-idle-L5.png|390|844|1
PC-v16e-01|$D/D1-v-16e-play-column-drag.png|$R/RT-16e-01-play-column-drag.png|390|844|0
PC-v16e-08|$D/D1-v-16e-tutorial-hud.png|$R/RT-16e-08-tutorial-hud.png|390|844|1
PC-v16e-10b|$D/D1-v-16e-tutorial-text-ax5-capped.png|$R/RT-16e-10b-a11y-ax5-tutorial.png|390|844|1
PC-vpm-idle|$F00/S-v-promax-play-idle.png|$R/RT-promax-00-idle-L5.png|440|956|1
PC-vpm-08|$D/D1-v-promax-tutorial-hud.png|$R/RT-promax-08-tutorial-hud.png|440|956|1
EOF
echo "wrote $OUT"

# Composites: render | runtime | difference (black = identical).
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
TMP=${TMPDIR:-/tmp}/parity-d1; mkdir -p "$TMP"
while IFS='|' read -r id render runtime w h note; do
  [ -z "$id" ] && continue
  html="$TMP/$id.html"
  cat > "$html" <<HTML
<!doctype html><html><head><meta charset="utf-8"><style>
body{margin:0;background:#15161c;font:600 13px/1.3 -apple-system,Helvetica,sans-serif;color:#e8eaf2}
.row{display:flex;gap:12px;padding:12px}.col{width:${w}px}.cap{height:34px}
.frame{position:relative;width:${w}px;height:${h}px;overflow:hidden;border-radius:6px}
.frame img{position:absolute;left:0;top:0;width:${w}px;height:${h}px}
.diff img.top{mix-blend-mode:difference}
</style></head><body><div class="row">
<div class="col"><div class="cap">$(basename "$render")<br><span style="color:#9aa0b8">design render</span></div><div class="frame"><img src="file://$PWD/$render"></div></div>
<div class="col"><div class="cap">$(basename "$runtime")<br><span style="color:#9aa0b8">runtime (simulator)</span></div><div class="frame"><img src="file://$PWD/$runtime"></div></div>
<div class="col diff"><div class="cap">difference<br><span style="color:#9aa0b8">$note</span></div><div class="frame"><img src="file://$PWD/$render"><img class="top" src="file://$PWD/$runtime"></div></div>
</div></body></html>
HTML
  W3=$((w * 3 + 48)); H3=$((h + 58))
  rm -f "$R/$id.png"
  "$CHROME" --headless=new --disable-gpu --no-sandbox --hide-scrollbars --allow-file-access-from-files \
    --force-device-scale-factor=1 --window-size=$W3,$H3 --screenshot="$R/$id.png" "file://$html" >/dev/null 2>&1
  sips -s format jpeg -s formatOptions 85 "$R/$id.png" --out "$R/$id.jpg" >/dev/null && rm "$R/$id.png"
  echo "$id.jpg"
done <<EOF
PC-00|$D/D1-00-play-idle.png|$R/RT-16-00-idle-L5.png|393|852|same state (L5, 0 moves)
PC-01|$D/D1-01-play-column-drag.png|$R/RT-16-01-play-column-drag.png|393|852|L4 after R0 L3, column 2 held ~0.55 stride
PC-02|$D/D1-02-hud-undo-two-left.png|$R/RT-16-02-hud-undo-two-left.png|393|852|L5 after R1, quota 2
PC-03|$D/D1-03-hud-undo-exhausted.png|$R/RT-16-03-hud-undo-exhausted.png|393|852|L5 after R1 L3 D0 R4, quota 0
PC-04|$D/D1-04-hud-restart-pressed.png|$R/RT-16-04-hud-restart-pressed.png|393|852|restart held (pressed fill)
PC-05|$D/D1-05-play-locked-frozen-L26.png|$R/RT-16-05-play-locked-frozen-L26.png|393|852|L26 idle
PC-06-t000|$D/D1-06-play-thaw-L23-t000.png|$R/RT-16-06-thaw-L23-t000.png|393|852|T0 — runtime rest still dimmed (lift fade-out)
PC-06-t090|$D/D1-06-play-thaw-L23-t090.png|$R/RT-16-06-thaw-L23-t090.png|393|852|T0+83 ms (nearest frame)
PC-06-t180|$D/D1-06-play-thaw-L23-t180.png|$R/RT-16-06-thaw-L23-t180.png|393|852|T0+168 ms (last change)
PC-07|$D/D1-07-play-load-error.png|$R/RT-16-07-play-load-error.png|393|852|level 07 asset corrupted in the bundle
PC-08|$D/D1-08-tutorial-hud.png|$R/RT-16-08-tutorial-hud.png|393|852|ghost loop phase differs
PC-09|$D/D1-09-tutorial-drag-ghost-hidden.png|$R/RT-16-09-tutorial-drag-ghost-hidden.png|393|852|column held: ghost hidden, pill stays
PC-10|$D/D1-10-play-text-ax5-capped.png|$R/RT-16-10-a11y-ax5-L26.png|393|852|AX5 (1.3× cap); render HUD shows 12 moves
PC-10b|$D/D1-10b-tutorial-text-ax5-capped.png|$R/RT-16-10b-a11y-ax5-tutorial.png|393|852|AX5 (1.3× cap)
PC-11|$D/D1-11-play-loading.png|$R/RT-16-11-loading-crossfade.png|393|852|runtime: skeleton → tiles cross-fade under the route push
PC-lift|$D/D1-M-lift-t0400.png|$R/RT-16-lift-row-L5.png|393|852|row 2 held ~0.55 stride (prototype t=400)
PC-v16e-idle|$F00/S-v-16e-play-idle.png|$R/RT-16e-00-idle-L5.png|390|844|16e idle (S-v render content differs)
PC-v16e-01|$D/D1-v-16e-play-column-drag.png|$R/RT-16e-01-play-column-drag.png|390|844|16e column drag
PC-v16e-08|$D/D1-v-16e-tutorial-hud.png|$R/RT-16e-08-tutorial-hud.png|390|844|16e tutorial
PC-v16e-10b|$D/D1-v-16e-tutorial-text-ax5-capped.png|$R/RT-16e-10b-a11y-ax5-tutorial.png|390|844|16e tutorial at AX5
PC-vpm-idle|$F00/S-v-promax-play-idle.png|$R/RT-promax-00-idle-L5.png|440|956|Pro Max idle (S-v render content differs)
PC-vpm-08|$D/D1-v-promax-tutorial-hud.png|$R/RT-promax-08-tutorial-hud.png|440|956|Pro Max tutorial
EOF
