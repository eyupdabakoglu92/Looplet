#!/bin/sh
# usage: sh fit-f07.sh [name-filter] — loads each page of jobs-f07.txt headless and prints the page's own fit record
# (content column top / bottom and the spare height above the home indicator, from the page's check script) → fit-f07.txt
# A 20 s watchdog kills a hung Chrome (an occasional headless flake) and retries up to 3 times.
cd "$(dirname "$0")"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
: > fit-f07.txt
while read name w h d; do
  case "$name" in *"$1"*) ;; *) continue;; esac
  case "$name" in *play*) continue;; esac
  attempt=0; t=""
  while [ $attempt -lt 3 ] && [ -z "$t" ]; do
    attempt=$((attempt+1))
    "$CHROME" --headless=new --disable-gpu --no-sandbox --allow-file-access-from-files --window-size=$w,$h --virtual-time-budget=4000 --dump-dom "file://$PWD/$name.html" > /tmp/f07dom.$$ 2>/dev/null &
    pid=$!; n=0
    while kill -0 $pid 2>/dev/null && [ $n -lt 20 ]; do sleep 1; n=$((n+1)); done
    kill -9 $pid 2>/dev/null; wait $pid 2>/dev/null
    t=$(sed -n 's:.*<title>\(.*\)</title>.*:\1:p' /tmp/f07dom.$$ | sed 's/&quot;/"/g')
  done
  printf '%-58s %s\n' "$name" "$t" | tee -a fit-f07.txt
done < jobs-f07.txt
rm -f /tmp/f07dom.$$
