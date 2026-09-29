#!/bin/sh
# seed-d3.sh <udid> <completedUpTo> [sessionLevel|-]   (F05-FE-D3 runtime evidence)
# Seeds the LOOPLET simulator store: Journey levels 1…<completedUpTo> completed (strict unlock:
# the next one is unlocked) and, optionally, an in-progress Journey snapshot on <sessionLevel>
# (a frontier level or a replay of a completed one). Then relaunches the app (a cold start).
#   seed-d3.sh <udid> corrupt   overwrites the store with a non-database file (store error)
#   seed-d3.sh <udid> wipe      deletes the store (an empty store: the next launch creates it)
set -e
U="$1"; N="$2"; S="${3:--}"
APP=com.looplet.loopletApp
C=$(xcrun simctl get_app_container "$U" "$APP" data)
DB="$C/Documents/looplet.sqlite"
xcrun simctl terminate "$U" "$APP" 2>/dev/null || true
case "$N" in
  corrupt) printf 'not a database, just some bytes to fail the open\n%.0s' 1 2 3 4 5 6 7 8 > "$DB"; rm -f "$DB-wal" "$DB-shm"; echo "corrupted $DB"; exit 0 ;;
  wipe) rm -f "$DB" "$DB-wal" "$DB-shm"; echo "wiped $DB"; exit 0 ;;
esac
if [ ! -s "$DB" ] || ! sqlite3 "$DB" "select 1 from player limit 1;" >/dev/null 2>&1; then
  rm -f "$DB" "$DB-wal" "$DB-shm"
  xcrun simctl launch "$U" "$APP" >/dev/null; sleep 6
  xcrun simctl terminate "$U" "$APP" 2>/dev/null || true
fi
GUEST=$(sqlite3 "$DB" "select guest_id from player limit 1;")
CSV=""; i=1
while [ "$i" -le "$N" ]; do if [ -z "$CSV" ]; then CSV="$i"; else CSV="$CSV,$i"; fi; i=$((i + 1)); done
H=$((N + 1)); [ "$H" -gt 30 ] && H=30
NOW=$(($(date +%s) * 1000))
sqlite3 "$DB" "insert or replace into journey_progress(guest_id, highest_unlocked_level, completed_levels_csv) values ('$GUEST', $H, '$CSV');"
sqlite3 "$DB" "delete from kv where key = 'active_session';"
sqlite3 "$DB" "insert or replace into kv(key, value_json, schema_version) values ('journey_col_tutorial_ack', '{\"ack\":true,\"atUtcMs\":$NOW}', 1);"
if [ "$S" != "-" ]; then
  ID=$(printf 'journey-tr-%02d' "$S")
  JSON="{\"snapshotVersion\":1,\"puzzleId\":\"$ID\",\"puzzleSource\":\"journey\",\"lang\":\"tr\",\"appliedMoves\":[\"R1\"],\"moveCount\":1,\"undosRemaining\":3,\"restartCount\":0,\"elapsedMsAccumulated\":4200,\"thawedFrozenCells\":[],\"status\":\"inProgress\",\"startedAtUtcMs\":$NOW,\"lastPersistedAtUtcMs\":$NOW}"
  sqlite3 "$DB" "insert or replace into kv(key, value_json, schema_version) values ('active_session', '$JSON', 1);"
fi
sqlite3 "$DB" "select 'progress', highest_unlocked_level, completed_levels_csv from journey_progress; select key, substr(value_json, 1, 60) from kv where key = 'active_session';"
xcrun simctl launch "$U" "$APP" >/dev/null
echo "seeded $U: 1…$N done, session $S"
