#!/bin/sh
# q.sh <udid> — the app's sync_queue rows and daily_entry mirrors
"$(dirname "$0")/ev-f08.sh" sql "$1" "select 'queue', id, state, attempt_count, idempotency_key, next_attempt_at_utc_ms, last_error from sync_queue; select 'entry', daily_date, sync_status, first_run_move_count from daily_entry;"
