#!/bin/sh
# capture-d3.sh — helpers for the F05-FE-D3 runtime evidence (frontend.md § Visual Parity Evidence).
#   capture-d3.sh shot <udid> <name> [delaySec]      still -> runtime-d3/<name>.png
#   capture-d3.sh coldrec <udid> <name> [sec]        records a cold start: terminate, start recordVideo,
#                                                    launch, wait <sec> (default 6), stop -> runtime-d3/raw/<name>.mov
#   capture-d3.sh size <udid> <content-size>         OS text size (live)
#   capture-d3.sh rm <udid> 0|1                      Reduce Motion (the app is not relaunched)
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
OUT="$HERE/../runtime-d3"
APP=com.looplet.loopletApp
mkdir -p "$OUT/raw"
cmd="$1"; shift
case "$cmd" in
  shot) U="$1"; N="$2"; sleep "${3:-0}"; xcrun simctl io "$U" screenshot "$OUT/$N.png" >/dev/null 2>&1; echo "$OUT/$N.png" ;;
  coldrec)
    U="$1"; N="$2"; S="${3:-6}"
    xcrun simctl terminate "$U" "$APP" 2>/dev/null || true
    sleep 1
    (cd "$OUT/raw" && nohup xcrun simctl io "$U" recordVideo --codec h264 --force "$N.mov" > "$N.log" 2>&1 &)
    sleep 2
    xcrun simctl launch "$U" "$APP" >/dev/null
    sleep "$S"
    pkill -INT -f "recordVideo --codec h264 --force $N.mov" || true
    sleep 2; tail -1 "$OUT/raw/$N.log" ;;
  size) xcrun simctl ui "$1" content_size "$2"; echo "content size $(xcrun simctl ui "$1" content_size)" ;;
  rm) xcrun simctl spawn "$1" defaults write com.apple.Accessibility ReduceMotionEnabled -bool "$([ "$2" = 1 ] && echo true || echo false)"; echo "reduce motion $(xcrun simctl spawn "$1" defaults read com.apple.Accessibility ReduceMotionEnabled)" ;;
esac
