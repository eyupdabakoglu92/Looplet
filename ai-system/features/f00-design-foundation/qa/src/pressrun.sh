#!/bin/sh
D=$1; OUT=$2; BID=com.looplet.loopletApp
C=$(xcrun simctl get_app_container $D $BID data)
printf 'press' > "$C/tmp/probe_mode"; printf '0' > "$C/tmp/probe_offset"; rm -f "$C/tmp/gallery_offset"
xcrun simctl terminate $D $BID >/dev/null 2>&1
xcrun simctl spawn $D log stream --style compact --predicate 'eventMessage CONTAINS "QAPROBE"' > "$OUT.log" 2>&1 &
LP=$!; sleep 2
xcrun simctl launch $D $BID >/dev/null
sleep 8
xcrun simctl io $D screenshot "$OUT.png" >/dev/null 2>&1
kill $LP 2>/dev/null; sleep 1; xcrun simctl terminate $D $BID >/dev/null 2>&1
grep -a "QAPROBE press\|QAPROBE env" "$OUT.log" | sed -E 's/^.*QAPROBE/QAPROBE/' | cut -c1-220
