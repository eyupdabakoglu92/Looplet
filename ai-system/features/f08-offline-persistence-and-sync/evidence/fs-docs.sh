#!/bin/sh
# fs-docs.sh <dailyDate> [lang] — the Firestore emulator documents under
# dailyResults/<lang>_<date>/entries (admin read: "Bearer owner" bypasses the rules),
# one line per doc: uid moves stars recordedAtUtcMs.
D="$1"; L="${2:-tr}"
curl -s -H 'Authorization: Bearer owner' \
  "http://127.0.0.1:8080/v1/projects/demo-looplet/databases/(default)/documents/dailyResults/${L}_${D}/entries" |
python3 -c '
import json,sys
docs=json.load(sys.stdin).get("documents",[])
print(f"docs={len(docs)}")
for d in docs:
    f=d["fields"]; v=lambda k: list(f[k].values())[0] if k in f else None
    print(" ", d["name"].split("/")[-1], "moves", v("moves"), "stars", v("stars"), "recordedAtUtcMs", v("recordedAtUtcMs"), "completedAtUtcMs", v("completedAtUtcMs"))'
