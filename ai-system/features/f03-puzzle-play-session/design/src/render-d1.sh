#!/bin/sh
# usage: sh render-d1.sh [name-filter] [jobs-file] — renders each page in the job list to ../<name>.png with headless Chrome
# at devicePixelRatio 2 (same method as F00 design/src/render.sh). Job line: <name> <width> <height> [dsf].
# A 30 s watchdog kills a hung Chrome (an occasional headless flake) and retries up to 3 times.
cd "$(dirname "$0")"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
JOBS="${2:-jobs-d1.txt}"
while read name w h d; do
  case "$name" in *"$1"*) ;; *) continue;; esac
  dsf=${d:-2}
  attempt=0
  while [ $attempt -lt 3 ]; do
    attempt=$((attempt+1)); rm -f "../$name.png"
    "$CHROME" --headless=new --disable-gpu --no-sandbox --hide-scrollbars --allow-file-access-from-files \
      --force-device-scale-factor=$dsf --window-size=$w,$h --virtual-time-budget=4000 \
      --screenshot="../$name.png" "file://$PWD/$name.html" >/dev/null 2>&1 &
    pid=$!; n=0
    while kill -0 $pid 2>/dev/null && [ $n -lt 30 ]; do sleep 1; n=$((n+1)); done
    if kill -0 $pid 2>/dev/null; then kill -9 $pid 2>/dev/null; wait $pid 2>/dev/null; echo "$name attempt $attempt TIMEOUT"; else echo "$name ${w}x${h}@${dsf}x ${n}s"; break; fi
  done
done < "$JOBS"
