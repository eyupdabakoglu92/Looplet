#!/bin/sh
# usage: runprobe2.sh <udid> <mode> <probe-offset> <gallery-offset> <outprefix> [wait]
D=$1; MODE=$2; POFF=$3; GOFF=$4; OUT=$5; WAIT=${6:-9}; BID=com.looplet.loopletApp
C=$(xcrun simctl get_app_container $D $BID data)
printf '%s' "$MODE" > "$C/tmp/probe_mode"; printf '%s' "$POFF" > "$C/tmp/probe_offset"; printf '%s' "$GOFF" > "$C/tmp/gallery_offset"
xcrun simctl terminate $D $BID >/dev/null 2>&1
xcrun simctl spawn $D log stream --style compact --predicate 'eventMessage CONTAINS "QAPROBE"' > "$OUT.log" 2>&1 &
LP=$!
sleep 2
xcrun simctl launch $D $BID >/dev/null
sleep $WAIT
xcrun simctl io $D screenshot "$OUT.png" >/dev/null 2>&1
kill $LP 2>/dev/null; sleep 1
xcrun simctl terminate $D $BID >/dev/null 2>&1
E=$(grep -a "QAPROBE env" "$OUT.log" | sed -E 's/^.*QAPROBE env //' | cut -c1-200)
echo "$(basename $OUT): $E"
