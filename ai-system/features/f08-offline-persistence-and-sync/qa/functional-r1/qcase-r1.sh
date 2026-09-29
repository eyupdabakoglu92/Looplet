#!/bin/sh
# qcase-r1.sh <label> <dailyDate> — QA R1 case snapshot: queue / entry rows, emulator docs (admin read), proxy + app tail.
Q=/Users/eyupcandabakoglu/Projects/Looplet/ai-system/features/f08-offline-persistence-and-sync/qa/functional-r1; DB="/Users/eyupcandabakoglu/Library/Developer/CoreSimulator/Devices/D0011CE7-6E50-4367-93FA-B323E81270BE/data/Containers/Data/Application/08235493-DC10-4BFD-A512-58E5B5499E65/Documents/looplet.sqlite"
{ echo "== $1 $(date -u +%FT%TZ) proxy=$(cat $Q/proxy-mode)"
  sqlite3 "$DB" "select 'queue', id, state, attempt_count, idempotency_key, last_error from sync_queue; select 'entry', daily_date, sync_status, first_run_move_count from daily_entry; select 'player', guest_id, firebase_uid from player;"
  sh /Users/eyupcandabakoglu/Projects/Looplet/ai-system/features/f08-offline-persistence-and-sync/evidence/fs-docs.sh "$2"
  echo "-- proxy (last 3)"; tail -3 $Q/QE-R1-proxy.log
  echo "-- app (last 4 sync lines)"; grep -o "flutter: \(sync\|debug-sync\).*" $Q/QE-R1-app.log | tail -4; } | tee -a $Q/QE-R1-cases.txt
