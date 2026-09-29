#!/usr/bin/env python3
"""F08-BE7 named negative run N-DIRECT-CREATE (the neg-be6.py pattern).

Puts the pre-BE7 client create rule back into `infra/firestore.rules`
(`allow create: if request.auth != null && request.auth.uid == uid;`), runs
`rules.test.ts` against the Firestore emulator and expects the three direct-create
tests to FAIL: the own valid entry, the own invalid payload (QA probe P3) and the
non-date bucket (QA probe P6). The other rules tests must still pass. The rules
file is restored from a byte copy afterwards and its SHA-1 is checked.

Run from the repo root:  python3 ai-system/features/f08-offline-persistence-and-sync/evidence/neg-be7.py
Needs Java 21 on PATH for firebase-tools 15.29 (setup-manifest.md).
"""
import hashlib, os, pathlib, subprocess, sys

ROOT = pathlib.Path(__file__).resolve().parents[4]
FN = ROOT / "infra" / "functions"
RULES = ROOT / "infra" / "firestore.rules"
OUT = pathlib.Path(__file__).resolve().parent / "runtime" / "BE7-04-neg.log.txt"
JDK = "/opt/homebrew/opt/openjdk@21"

MUTATION = (
    "      allow create, update, delete, read: if false;",
    "      allow create: if request.auth != null\n"
    "                    && request.auth.uid == uid;\n"
    "      allow update, delete, read: if false;",
)
EXPECTED_FAILS = [
    "denies a signed-in user's direct create of their own valid entry",
    "denies a direct create of an own entry with an invalid payload",
    "denies a direct create in a non-date bucket",
]

sha = lambda p: hashlib.sha1(p.read_bytes()).hexdigest()


def run(log):
    env = dict(os.environ, JAVA_HOME=JDK, PATH=f"{JDK}/bin:" + os.environ["PATH"])
    cmd = ["npx", "firebase", "--config", "../firebase.json", "emulators:exec",
           "--only", "firestore,auth", "--project", "demo-looplet",
           "jest --verbose test/rules.test.ts"]
    p = subprocess.run(cmd, cwd=FN, env=env, capture_output=True, text=True)
    out = p.stdout + p.stderr
    log.write(f"\n===== N-DIRECT-CREATE — exit {p.returncode}\n{out}\n")
    lines = [l.strip() for l in out.splitlines()]
    failed = [l for l in lines if l.startswith("✕")]
    passed = [l for l in lines if l.startswith("✓")]
    summary = [l for l in lines if l.startswith("Tests:")]
    return p.returncode, failed, passed, summary


def main():
    rules_bytes = RULES.read_bytes()
    before = sha(RULES)
    with OUT.open("w") as log:
        log.write(f"rules sha1 {before}\n")
        try:
            text = rules_bytes.decode()
            assert text.count(MUTATION[0]) == 1, "expected one deny-all line"
            RULES.write_text(text.replace(MUTATION[0], MUTATION[1]))
            log.write(f"mutated rules sha1 {sha(RULES)}\n")
            code, failed, passed, summary = run(log)
        finally:
            RULES.write_bytes(rules_bytes)
        after = sha(RULES)
        log.write(f"\nrestored rules sha1 {after}\n")
    assert after == before, "restore failed"
    print(f"N-DIRECT-CREATE: exit {code}; {' '.join(summary)}")
    for f in failed:
        print(f"  {f}")
    caught = all(any(name in f for f in failed) for name in EXPECTED_FAILS)
    only_expected = len(failed) == len(EXPECTED_FAILS)
    print(f"expected failures caught: {caught}; no other failure: {only_expected}; passed: {len(passed)}")
    print(f"restored byte-identical: {after == before} (rules {after[:12]})")
    return 0 if code != 0 and caught and only_expected else 1


if __name__ == "__main__":
    sys.exit(main())
