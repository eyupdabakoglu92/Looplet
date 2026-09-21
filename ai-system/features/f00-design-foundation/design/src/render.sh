#!/bin/sh
# usage: sh render.sh [filter]  — renders every page listed in jobs.txt to ../<name>.png with headless Chrome
# (iPhone-class frames at devicePixelRatio 2; specimen at 1). Requires: node gen.mjs . first.
cd "$(dirname "$0")"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
while read name w h; do
  case "$name" in *"$1"*) ;; *) continue;; esac
  dsf=2; case "$name" in *specimen*) dsf=1;; esac
  "$CHROME" --headless=new --disable-gpu --no-sandbox --hide-scrollbars --allow-file-access-from-files \
    --force-device-scale-factor=$dsf --window-size=$w,$h --virtual-time-budget=4000 \
    --screenshot="../$name.png" "file://$PWD/$name.html" >/dev/null 2>&1
  echo "$name ${w}x${h}@${dsf}x"
done < jobs.txt
