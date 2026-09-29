#!/bin/sh
# qa-d3.sh — F05-QA-D3 runtime capture helpers (QA's own; outputs under qa/d3/).
#   qa-d3.sh shot <udid> <name> [delaySec]     still -> qa/d3/<name>.png
#   qa-d3.sh coldrec <udid> <name> [sec]       terminate, record, launch, wait, stop -> qa/d3/raw/<name>.mov
#   qa-d3.sh launch <udid>                     terminate + launch (a cold start, no recording)
#   qa-d3.sh size <udid> <content-size>        OS text size (live)
#   qa-d3.sh rm <udid> 0|1                     Reduce Motion
# Store seeding reuses the delivery's design/src/seed-d3.sh (a direct SQLite write: an isolation
# override for reaching states, recorded as such in qa.md).
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
APP=com.looplet.loopletApp
mkdir -p "$HERE/raw"
cmd="$1"; shift
case "$cmd" in
  shot) U="$1"; N="$2"; sleep "${3:-0}"; xcrun simctl io "$U" screenshot "$HERE/$N.png" >/dev/null 2>&1; echo "$HERE/$N.png" ;;
  launch) xcrun simctl terminate "$1" "$APP" 2>/dev/null || true; sleep 1; xcrun simctl launch "$1" "$APP" >/dev/null; echo launched ;;
  coldrec)
    U="$1"; N="$2"; S="${3:-7}"
    xcrun simctl terminate "$U" "$APP" 2>/dev/null || true
    sleep 1
    (cd "$HERE/raw" && nohup xcrun simctl io "$U" recordVideo --codec h264 --force "$N.mov" > "$N.log" 2>&1 &)
    sleep 2
    xcrun simctl launch "$U" "$APP" >/dev/null
    sleep "$S"
    pkill -INT -f "recordVideo --codec h264 --force $N.mov" || true
    sleep 2; tail -1 "$HERE/raw/$N.log" ;;
  size) xcrun simctl ui "$1" content_size "$2"; echo "content size $(xcrun simctl ui "$1" content_size)" ;;
  rm) xcrun simctl spawn "$1" defaults write com.apple.Accessibility ReduceMotionEnabled -bool "$([ "$2" = 1 ] && echo true || echo false)"; echo "reduce motion $(xcrun simctl spawn "$1" defaults read com.apple.Accessibility ReduceMotionEnabled)" ;;
esac
