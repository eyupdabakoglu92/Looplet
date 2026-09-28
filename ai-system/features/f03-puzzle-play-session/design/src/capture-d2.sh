#!/bin/sh
# capture-d2.sh — helpers for the F03-FE-D2 runtime evidence (frontend.md § Visual Parity Evidence).
# Touches (CONTINUE, the final winning swipe, taps on the result) are injected with the simulator
# touch path; this script only seeds, records and captures.
#   capture-d2.sh seed <udid> <level> <moves-json> [priorBest]   Journey <level> in progress with <moves>
#                                                               (+ a personal_best row for the level)
#   capture-d2.sh shot <udid> <name> [delaySec]                  still -> runtime-d2/<name>.png
#   capture-d2.sh rec  <udid> <name>                             start recordVideo -> runtime-d2/raw/<name>.mov
#   capture-d2.sh stop <name>                                    stop that recording
#   capture-d2.sh size <udid> <content-size>                     OS text size (live)
#   capture-d2.sh rm   <udid> 0|1                                Reduce Motion (the app is relaunched)
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
OUT="$HERE/../runtime-d2"
APP=com.looplet.loopletApp
mkdir -p "$OUT/raw"
cmd="$1"; shift
case "$cmd" in
  seed)
    U="$1"; L="$2"; MOVES="$3"; BEST="${4:-}"
    sh "$HERE/seed-sim.sh" "$U" "$L" "$MOVES" 1 >/dev/null
    C=$(xcrun simctl get_app_container "$U" "$APP" data)
    DB="$C/Documents/looplet.sqlite"
    xcrun simctl terminate "$U" "$APP" 2>/dev/null || true
    ID=$(printf 'journey-tr-%02d' "$L")
    sqlite3 "$DB" "delete from personal_best where level_id = '$ID';"
    if [ -n "$BEST" ]; then
      OPT=$(python3 -c "import json;print(json.load(open('$HERE/../../../../../content/journey/tr/$ID.json'))['optimalMoves'])")
      GUEST=$(sqlite3 "$DB" "select guest_id from player limit 1;")
      STARS=$(python3 -c "b=$BEST;o=$OPT;print(3 if b<=o else 2 if b<=o+3 else 1)")
      PERF=$([ "$BEST" -le "$OPT" ] && echo 1 || echo 0)
      sqlite3 "$DB" "insert into personal_best(guest_id, level_id, best_move_count, stars, is_perfect, first_completed_at_utc_ms) values ('$GUEST', '$ID', $BEST, $STARS, $PERF, 1757100000000);"
    fi
    sqlite3 "$DB" "select 'best', level_id, best_move_count, stars, is_perfect from personal_best where level_id = '$ID';"
    xcrun simctl launch "$U" "$APP" >/dev/null
    echo "seeded $U L$L moves $MOVES prior best ${BEST:--}"
    ;;
  shot)
    U="$1"; N="$2"; D="${3:-0}"
    sleep "$D"
    xcrun simctl io "$U" screenshot "$OUT/$N.png" >/dev/null 2>&1
    echo "$OUT/$N.png"
    ;;
  rec)
    U="$1"; N="$2"
    (cd "$OUT/raw" && nohup xcrun simctl io "$U" recordVideo --codec h264 --force "$N.mov" > "$N.log" 2>&1 &)
    sleep 2
    cat "$OUT/raw/$N.log"
    ;;
  stop)
    N="$1"
    sleep 3
    pkill -INT -f "recordVideo --codec h264 --force $N.mov" || true
    sleep 2
    tail -1 "$OUT/raw/$N.log"
    ;;
  size)
    xcrun simctl ui "$1" content_size "$2"
    echo "content size $(xcrun simctl ui "$1" content_size)"
    ;;
  rm)
    U="$1"; V="$2"
    xcrun simctl spawn "$U" defaults write com.apple.Accessibility ReduceMotionEnabled -bool "$([ "$V" = 1 ] && echo true || echo false)"
    xcrun simctl terminate "$U" "$APP" 2>/dev/null || true
    xcrun simctl launch "$U" "$APP" >/dev/null
    echo "reduce motion $(xcrun simctl spawn "$U" defaults read com.apple.Accessibility ReduceMotionEnabled)"
    ;;
esac
