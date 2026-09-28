#!/bin/sh
# sweep-d1r.sh <udid> <tag> <out-prefix>
# F03-FE-D1R: captures the current screen at OS text sizes large → AX5
# (xcrun simctl ui content_size), then restores `large`.
set -e
U="$1"; TAG="$2"; OUT="$3"
for SIZE in large extra-large extra-extra-large extra-extra-extra-large accessibility-extra-extra-extra-large; do
  xcrun simctl ui "$U" content_size "$SIZE"
  sleep 2
  xcrun simctl io "$U" screenshot "$OUT-$TAG-$SIZE.png" >/dev/null 2>&1
  echo "captured $OUT-$TAG-$SIZE.png"
done
xcrun simctl ui "$U" content_size large
