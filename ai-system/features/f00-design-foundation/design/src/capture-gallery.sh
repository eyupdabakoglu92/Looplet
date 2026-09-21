#!/bin/sh
# F00-FE-DESIGN-SYSTEM runtime capture: installs the debug gallery build on one simulator and screenshots it at
# fixed scroll offsets (deterministic; Platform.environment is empty on iOS, so the offset is passed as a file
# in the app container's tmp dir, read by app/lib/main_gallery.dart).
#
# build (from app/):  flutter build ios --simulator --debug -t lib/main_gallery.dart
# usage:  sh capture-gallery.sh <name> <simulator-udid> <out-dir> [app-path]
#   -> <out-dir>/g_<name>_<offset>.png for offsets 0 640 1280 1920 2560 (2560 is the bottom on iPhone 16;
#      larger offsets clamp to the same last screen). A frame under 500 kB is a launch-screen frame and is retried.
set -u
NAME=$1; UDID=$2; OUT=$3
APP=${4:-$(cd "$(dirname "$0")/../../../../../app" && pwd)/build/ios/iphonesimulator/Runner.app}
BID=com.looplet.loopletApp
mkdir -p "$OUT"
xcrun simctl terminate "$UDID" "$BID" >/dev/null 2>&1
xcrun simctl install "$UDID" "$APP" || exit 1
xcrun simctl launch "$UDID" "$BID" >/dev/null; sleep 3; xcrun simctl terminate "$UDID" "$BID"   # creates the data container
C=$(xcrun simctl get_app_container "$UDID" "$BID" data)
for off in 0 640 1280 1920 2560; do
  f="$OUT/g_${NAME}_${off}.png"; tries=0
  while [ $tries -lt 4 ]; do
    tries=$((tries+1))
    printf '%s' "$off" > "$C/tmp/gallery_offset"
    xcrun simctl launch "$UDID" "$BID" >/dev/null
    sleep $((2 + tries))
    xcrun simctl io "$UDID" screenshot "$f" >/dev/null 2>&1
    xcrun simctl terminate "$UDID" "$BID"
    [ "$(stat -f%z "$f" 2>/dev/null || echo 0)" -gt 500000 ] && break
  done
  echo "$NAME offset=$off size=$(stat -f%z "$f") tries=$tries"
done
rm -f "$C/tmp/gallery_offset"
