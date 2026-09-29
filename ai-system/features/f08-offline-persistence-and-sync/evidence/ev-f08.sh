#!/bin/sh
# ev-f08.sh — helpers for the F08-LOCAL-EVIDENCE runtime runs (frontend.md § F08-LOCAL-EVIDENCE).
# Evidence lands in evidence/runtime/ (stills, logs) and evidence/runtime/raw/ (videos).
#   ev-f08.sh install <udid>                 install app/build/ios/iphonesimulator/Runner.app
#   ev-f08.sh logstart <udid> <name>         stream the app's log (flutter: lines) -> runtime/<name>.log
#   ev-f08.sh logstop <name>                 stop that stream
#   ev-f08.sh launch <udid> | kill <udid>    launch / terminate (a kill = a cold relaunch next)
#   ev-f08.sh shot <udid> <name> [delay]     still -> runtime/<name>.png
#   ev-f08.sh docs <udid>                    ls -la of the app's Documents (the store + quarantine)
#   ev-f08.sh sql <udid> "<sql>"             sqlite3 on the live store (read-only unless the SQL writes)
#   ev-f08.sh coldrec <udid> <name> [sec]    terminate, record, launch, wait, stop -> runtime/raw/<name>.mov
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
OUT="$HERE/runtime"
APP=com.looplet.loopletApp
mkdir -p "$OUT/raw"
cmd="$1"; shift
docs() { echo "$(xcrun simctl get_app_container "$1" "$APP" data)/Documents"; }
case "$cmd" in
  install) xcrun simctl install "$1" "$HERE/../../../../app/build/ios/iphonesimulator/Runner.app"; echo installed ;;
  logstart)
    (nohup xcrun simctl spawn "$1" log stream --style compact --level debug \
      --predicate 'process == "Runner" AND eventMessage CONTAINS "flutter:"' > "$OUT/$2.log" 2>&1 &)
    sleep 2; echo "logging -> $OUT/$2.log" ;;
  logstop) pkill -f "log stream --style compact" || true; sleep 1; grep -c "flutter:" "$OUT/$1.log" || true ;;
  launch) xcrun simctl launch "$1" "$APP" >/dev/null; echo launched ;;
  kill) xcrun simctl terminate "$1" "$APP" 2>/dev/null || true; echo terminated ;;
  shot) sleep "${3:-0}"; xcrun simctl io "$1" screenshot "$OUT/$2.png" >/dev/null 2>&1; echo "$OUT/$2.png" ;;
  docs) ls -la "$(docs "$1")" ;;
  sql) sqlite3 "$(docs "$1")/looplet.sqlite" "$2" ;;
  coldrec)
    U="$1"; N="$2"; S="${3:-6}"
    xcrun simctl terminate "$U" "$APP" 2>/dev/null || true
    sleep 1
    (cd "$OUT/raw" && nohup xcrun simctl io "$U" recordVideo --codec h264 --force "$N.mov" > "$N.rec.log" 2>&1 &)
    sleep 2
    xcrun simctl launch "$U" "$APP" >/dev/null
    sleep "$S"
    pkill -INT -f "recordVideo --codec h264 --force $N.mov" || true
    sleep 2; tail -1 "$OUT/raw/$N.rec.log" ;;
esac
