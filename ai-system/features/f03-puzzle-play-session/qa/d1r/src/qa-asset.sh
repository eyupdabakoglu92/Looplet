#!/bin/sh
# qa-asset.sh <udid> corrupt|restore — F03-QA-D1R (QA-owned). Corrupts / restores
# journey-tr-07.json inside the INSTALLED simulator bundle only (the repo asset is the
# restore source; SHA-1 printed for both).
set -e
U="$1"; A=$(xcrun simctl get_app_container "$U" com.looplet.loopletApp app)/Frameworks/App.framework/flutter_assets/assets/journey/tr/journey-tr-07.json
REPO="$(git rev-parse --show-toplevel)/app/assets/journey/tr/journey-tr-07.json"
if [ "$2" = corrupt ]; then printf '{"not":"a puzzle' > "$A"; else cp "$REPO" "$A"; fi
shasum "$A" "$REPO"
