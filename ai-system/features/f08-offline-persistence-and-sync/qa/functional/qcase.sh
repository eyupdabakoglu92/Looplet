#!/bin/sh
# qcase.sh <label> <dailyDate> — QA case snapshot: the app's queue / entry rows, the emulator docs, the proxy tail.
H=$(cd "$(dirname "$0")" && pwd); U=D0011CE7-6E50-4367-93FA-B323E81270BE
{ echo "== $1 $(date -u +%FT%TZ) proxy=$(cat "$H/proxy-mode")"
  "$H/qa-f08.sh" sql $U "select 'queue', id, state, attempt_count, idempotency_key, next_attempt_at_utc_ms, last_error from sync_queue; select 'entry', daily_date, sync_status, first_run_move_count from daily_entry;"
  sh "$H/../../evidence/fs-docs.sh" "$2"
  echo "-- proxy (last 3)"; tail -3 "$H/QE-proxy.log"
  echo "-- app (last 4 sync lines)"; grep -o "flutter: \(sync\|debug-sync\).*" "$H/QE-app.log" | tail -4; } | tee -a "$H/QE-cases.txt"
