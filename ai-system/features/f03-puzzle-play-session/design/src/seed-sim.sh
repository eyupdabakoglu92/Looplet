#!/bin/sh
# seed-sim.sh <udid> <level> [moves-json|-] [tutorialAck 0|1] [undosRemaining]
# Seeds the LOOPLET simulator DB so CONTINUE opens Journey <level>, optionally
# with an in-progress snapshot (moves in F06 shorthand, e.g. '["R1","D3","U4"]').
set -e
U="$1"; L="$2"; MOVES="${3:--}"; ACK="${4:-1}"; UNDOS="${5:-3}"
C=$(xcrun simctl get_app_container "$U" com.looplet.loopletApp data)
DB="$C/Documents/looplet.sqlite"
# A fresh install has no database yet (and sqlite3 would create an empty file):
# launch the app once so it creates and seeds its own schema.
if [ ! -s "$DB" ]; then
  rm -f "$DB"
  xcrun simctl launch "$U" com.looplet.loopletApp >/dev/null
  sleep 5
fi
xcrun simctl terminate "$U" com.looplet.loopletApp 2>/dev/null || true
GUEST=$(sqlite3 "$DB" "select guest_id from player limit 1;")
CSV=""
i=1
while [ "$i" -lt "$L" ]; do
  if [ -z "$CSV" ]; then CSV="$i"; else CSV="$CSV,$i"; fi
  i=$((i + 1))
done
NOW=$(($(date +%s) * 1000))
sqlite3 "$DB" "insert or replace into journey_progress(guest_id, highest_unlocked_level, completed_levels_csv) values ('$GUEST', $L, '$CSV');"
sqlite3 "$DB" "delete from kv where key = 'active_session';"
if [ "$MOVES" != "-" ]; then
  ID=$(printf 'journey-tr-%02d' "$L")
  N=$(printf '%s' "$MOVES" | tr -cd ',' | wc -c | tr -d ' ')
  N=$((N + 1))
  JSON="{\"snapshotVersion\":1,\"puzzleId\":\"$ID\",\"puzzleSource\":\"journey\",\"lang\":\"tr\",\"appliedMoves\":$MOVES,\"moveCount\":$N,\"undosRemaining\":$UNDOS,\"restartCount\":0,\"elapsedMsAccumulated\":0,\"thawedFrozenCells\":[],\"status\":\"inProgress\",\"startedAtUtcMs\":$NOW,\"lastPersistedAtUtcMs\":$NOW}"
  sqlite3 "$DB" "insert or replace into kv(key, value_json, schema_version) values ('active_session', '$JSON', 1);"
fi
if [ "$ACK" = "1" ]; then
  sqlite3 "$DB" "insert or replace into kv(key, value_json, schema_version) values ('journey_col_tutorial_ack', '{\"ack\":true,\"atUtcMs\":$NOW}', 1);"
else
  sqlite3 "$DB" "delete from kv where key = 'journey_col_tutorial_ack';"
fi
sqlite3 "$DB" "select 'progress', highest_unlocked_level, completed_levels_csv from journey_progress; select key, substr(value_json, 1, 90) from kv;"
xcrun simctl launch "$U" com.looplet.loopletApp >/dev/null
echo "seeded $U level $L moves $MOVES ack $ACK"
