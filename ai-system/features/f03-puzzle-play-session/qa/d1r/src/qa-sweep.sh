#!/bin/sh
# qa-sweep.sh <udid> <out-prefix> [sizes...]
# F03-QA-D1R (QA-owned): changes the OS content size LIVE (no relaunch) and captures
# the current screen after 2.5 s at each size; default sizes large → AX5. Does not
# restore the size (the caller does).
set -e
U="$1"; OUT="$2"; shift 2
SIZES="${*:-large extra-large extra-extra-large extra-extra-extra-large accessibility-extra-extra-extra-large}"
for SIZE in $SIZES; do
  xcrun simctl ui "$U" content_size "$SIZE"
  sleep 2.5
  xcrun simctl io "$U" screenshot "$OUT-$SIZE.png" >/dev/null 2>&1
  echo "captured $OUT-$SIZE.png"
done
