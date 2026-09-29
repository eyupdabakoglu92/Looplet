#!/usr/bin/env python3
"""F08-BE6 named negative run N-OVERWRITE (the neg-fe13.py pattern).

Mutates `infra/functions/src/submitDailyResult.ts` so an existing entry is
overwritten (the ALREADY_SUBMITTED branch is skipped and `tx.create` becomes
`tx.set`), runs `submitDailyResult.test.ts` against the Firestore emulator and
expects the first-run-authoritative tests to FAIL. The handler is restored from a
byte copy afterwards and its SHA-1 is checked.

N-OVERWRITE-OLDFIX runs the same mutation with the pre-BE6 fixture (`moves: 8`)
to show why the fix matters: the old test fails for the validation reason
whether or not the handler is broken, so it could not catch the regression.

Run from the repo root:  python3 ai-system/features/f08-offline-persistence-and-sync/evidence/neg-be6.py
Needs Java 21 on PATH for firebase-tools 15.29 (setup-manifest.md).
"""
import hashlib, os, pathlib, subprocess, sys

ROOT = pathlib.Path(__file__).resolve().parents[4]
FN = ROOT / "infra" / "functions"
HANDLER = FN / "src" / "submitDailyResult.ts"
TEST = FN / "test" / "submitDailyResult.test.ts"
OUT = pathlib.Path(__file__).resolve().parent / "runtime" / "BE6-04-neg.log.txt"
JDK = "/opt/homebrew/opt/openjdk@21"

MUTATION = [
    ("if (snapshot.exists) {", "if (false && snapshot.exists) {"),
    ("tx.create(ref, doc);", "tx.set(ref, doc);"),
]
OLD_FIXTURE = ("data: { moves: 10, stars: 3, durationMs: 40000 },",
               "data: { moves: 8, stars: 3, durationMs: 40000 },")

sha = lambda p: hashlib.sha1(p.read_bytes()).hexdigest()


def patch(path, pairs):
    text = path.read_text()
    for old, new in pairs:
        assert text.count(old) == 1, f"{path.name}: expected one '{old}'"
        text = text.replace(old, new)
    path.write_text(text)


def run(label, log):
    env = dict(os.environ, JAVA_HOME=JDK, PATH=f"{JDK}/bin:" + os.environ["PATH"])
    cmd = ["npx", "firebase", "--config", "../firebase.json", "emulators:exec",
           "--only", "firestore,auth", "--project", "demo-looplet",
           "jest --verbose test/submitDailyResult.test.ts"]
    p = subprocess.run(cmd, cwd=FN, env=env, capture_output=True, text=True)
    out = p.stdout + p.stderr
    log.write(f"\n===== {label} — exit {p.returncode}\n{out}\n")
    failed = [l.strip() for l in out.splitlines() if l.strip().startswith("✕")]
    summary = [l.strip() for l in out.splitlines() if l.strip().startswith("Tests:")]
    return p.returncode, failed, summary


def main():
    handler_bytes, test_bytes = HANDLER.read_bytes(), TEST.read_bytes()
    before = (sha(HANDLER), sha(TEST))
    results = []
    with OUT.open("w") as log:
        log.write(f"handler sha1 {before[0]}\ntest sha1 {before[1]}\n")
        try:
            patch(HANDLER, MUTATION)
            results.append(("N-OVERWRITE", *run("N-OVERWRITE (fixed fixture)", log)))
            patch(TEST, [OLD_FIXTURE])
            results.append(("N-OVERWRITE-OLDFIX", *run("N-OVERWRITE-OLDFIX (pre-BE6 fixture)", log)))
        finally:
            HANDLER.write_bytes(handler_bytes)
            TEST.write_bytes(test_bytes)
        after = (sha(HANDLER), sha(TEST))
        log.write(f"\nrestored handler sha1 {after[0]}\nrestored test sha1 {after[1]}\n")
    assert after == before, "restore failed"
    for name, code, failed, summary in results:
        print(f"{name}: exit {code}; {' '.join(summary)}")
        for f in failed:
            print(f"  {f}")
    print(f"restored byte-identical: {after == before} (handler {after[0][:12]}, test {after[1][:12]})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
