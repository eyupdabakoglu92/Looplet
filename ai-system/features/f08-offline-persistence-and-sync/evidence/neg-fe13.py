# neg-fe13.py — the F08-FE13 named negative runs (the F05 design/src/neg-d3.py pattern).
# Run from app/ with SP=<a scratch folder>. Each run replaces exactly one occurrence of <old> in
# <file>, runs the tests, restores the file from a byte copy and prints the failing tests.
# A run PASSES (the negative is caught) when at least one test fails.
import sys, shutil, subprocess, os

T = 'test/persistence/store_recovery_test.dart test/persistence/storage_full_test.dart'.split()
RUNS = [
    ('N-CLASS', 'lib/bootstrap.dart',
     'case StoreFailureKind.unreadable:\n      if (launch.recreatedThisLaunch) {',
     'case StoreFailureKind.unreadable:\n      if (true) {'),
    ('N-LOOP', 'lib/bootstrap.dart',
     'if (launch.recreatedThisLaunch) {', 'if (false) {'),
    ('N-RETRY', 'lib/bootstrap.dart',
     'if (launch.connectionStale) {', 'if (false) {'),
    ('N-FULL', 'lib/persistence/daily_result_sync_service.dart',
     'await _db.transaction(() async {\n      await _queue.enqueue(',
     'await Future.sync(() async {\n      await _queue.enqueue('),
    ('N-FULL-FATAL', 'lib/play/play_session_controller.dart',
     '} catch (error) {\n        // Storage full / write error',
     '} on StateError catch (error) {\n        // Storage full / write error'),
    ('N-TXN', 'lib/persistence/app_database.dart',
     'await transaction(() async {\n        await MigrationGuard.guardPlayerData(',
     'await Future.sync(() async {\n        await MigrationGuard.guardPlayerData('),
    ('N-QUAR', 'lib/persistence/store_recovery.dart',
     'if (!isCurrent) await entity.delete();', 'if (false) await entity.delete();'),
    ('N-GATE', 'lib/firebase_emulator.dart',
     'if (!debugBuild) return null;', '// gate removed'),
    ('N-REGAIN', 'lib/persistence/daily_result_sync_service.dart',
     '_connectivitySub = connectivityRegained?.listen((_) => drain());',
     '_connectivitySub = null;', ['test/persistence/sync_test.dart']),
]

only = sys.argv[1:]
for name, path, old, new, *tests in RUNS:
    tests = tests[0] if tests else T
    if only and name not in only:
        continue
    bak = os.environ['SP'] + '/' + os.path.basename(path) + '.bak'
    shutil.copyfile(path, bak)
    s = open(path).read()
    assert s.count(old) == 1, (name, 'pattern count', s.count(old))
    open(path, 'w').write(s.replace(old, new))
    try:
        out = subprocess.run(['flutter', 'test', '-r', 'expanded', *tests], capture_output=True, text=True).stdout
    finally:
        shutil.copyfile(bak, path)
    fails = sorted(set(l.split(': ', 1)[-1] for l in out.splitlines() if l.endswith('[E]')))
    last = [l for l in out.splitlines() if 'tests passed' in l or 'tests failed' in l]
    print(f'{name}: {len(fails)} failing — {last[-1].split(": ")[-1] if last else "?"}')
    for f in fails:
        print('   ', f.replace('/Users/eyupcandabakoglu/Projects/Looplet/app/', ''))
