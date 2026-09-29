#!/bin/sh
# offline-journey.sh <udid> — F08.OFFLINE-JOURNEY (AC2) on a REAL no-network runtime.
# Run it yourself (it changes the Mac's Wi-Fi power; Claude does not change system settings).
# It turns Wi-Fi off, proves the host is offline, lets you play in the simulator, then turns
# Wi-Fi back on. Evidence lands in evidence/runtime/offline/.
#   1. Wi-Fi off; the offline check (no route to firebaseinstallations/google) is recorded.
#   2. cold launch the app; you play: Home -> "Devam et" -> finish the level.
#   3. press Enter: the store (journey_progress, personal_best) is recorded; the app is killed
#      and relaunched offline; you look at Home; press Enter again.
#   4. Wi-Fi back on.
# Needs a debug build WITHOUT the emulator define (the production-shaped Firebase path).
set -e
U="$1"; [ -n "$U" ] || { echo "usage: offline-journey.sh <udid>"; exit 64; }
HERE=$(cd "$(dirname "$0")" && pwd); OUT="$HERE/runtime/offline"; mkdir -p "$OUT"
IF=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
APP=com.looplet.loopletApp
DB="$(xcrun simctl get_app_container "$U" "$APP" data)/Documents/looplet.sqlite"
restore() { networksetup -setairportpower "$IF" on; echo "Wi-Fi $IF back on"; }
trap restore EXIT
networksetup -setairportpower "$IF" off; sleep 3
{ date -u +%FT%TZ; echo "Wi-Fi $IF off"; networksetup -getairportpower "$IF";
  curl -sS -m 5 https://www.google.com -o /dev/null && echo "ONLINE (not a valid run)" || echo "offline confirmed (curl failed)"; } | tee "$OUT/01-offline-check.txt"
sqlite3 "$DB" "select 'before', highest_unlocked_level, completed_levels_csv from journey_progress; select 'before', level_id, best_move_count from personal_best;" | tee "$OUT/02-store-before.txt"
xcrun simctl terminate "$U" "$APP" 2>/dev/null || true; xcrun simctl launch "$U" "$APP" >/dev/null
echo "Play one level to the result in the simulator, then press Enter."; read _
xcrun simctl io "$U" screenshot "$OUT/03-result.png" >/dev/null 2>&1
sqlite3 "$DB" "select 'after', highest_unlocked_level, completed_levels_csv from journey_progress; select 'after', level_id, best_move_count, stars from personal_best;" | tee "$OUT/04-store-after.txt"
xcrun simctl terminate "$U" "$APP"; sleep 1; xcrun simctl launch "$U" "$APP" >/dev/null; sleep 6
xcrun simctl io "$U" screenshot "$OUT/05-relaunch-offline-home.png" >/dev/null 2>&1
echo "Relaunched offline — check Home shows the progress, then press Enter."; read _
{ date -u +%FT%TZ; curl -sS -m 5 https://www.google.com -o /dev/null && echo "ONLINE at the end (run invalid)" || echo "still offline at the relaunch"; } | tee "$OUT/06-still-offline.txt"
