# Content authoring and quality gates

Run commands below from `tools/looplet_authoring`. The runtime engine is the rule authority. The F07 contract is [daily-content-spec.md](../../ai-system/features/f07-daily-challenge/daily-content-spec.md).

## Corpus (staging first)

```sh
dart run bin/looplet_authoring.dart import-corpus --repo-root ../.. --out ../../build/content-quality/prospective-dictionary.json
dart run bin/looplet_authoring.dart audit-corpus --repo-root ../.. --asset ../../build/content-quality/prospective-dictionary.json
dart run bin/looplet_authoring.dart audit-corpus-impact --repo-root ../.. --candidate ../../build/content-quality/prospective-dictionary.json --out ../../build/content-quality/corpus-impact.json
```

The importer checks vendored source hashes and explicit curation/exclusions, preserves the legacy general dictionary, and derives 4–5-letter generation inputs. Source position in `first-10K` is not a verified usage frequency. `data/tr/curation.json` is AI editorial selection, not independent QA or human approval. Import alone never approves a runtime corpus. `audit-corpus-impact` leaves the runtime asset untouched, solves and scores every Journey/smoke/Daily artifact under both corpora, fingerprints all inputs, and returns nonzero for UNKNOWN/failure or any artifact that still needs re-export. Before promotion, complete corpus review, resolve the reported changes with the same grids/mechanics, and rerun the impact audit until `promotionReady=true`.

## Bounded pilot

```sh
dart run bin/looplet_authoring.dart generate-daily --repo-root ../.. --pilot --corpus ../../build/content-quality/prospective-dictionary.json --out ../../build/content-quality/pilot --seed 20260930 --attempts 100
dart run bin/looplet_authoring.dart audit-daily ../../build/content-quality/pilot --repo-root ../.. --pilot --corpus ../../build/content-quality/prospective-dictionary.json --out ../../build/content-quality/pilot-audit.json
```

The eight dates cover two open, two locked, two frozen and two combined-mechanic slots, including heavy Saturdays. The default pilot planner requires proven regression on the final heavy combined-mechanic slot; `--require-regression` is the explicit focused feasibility override that requires it on every requested date. Full-batch planning requires regression on Monday and Saturday of every complete ISO week, which supplies two weekly proofs and a hard heavy proof by construction before the aggregate audit rechecks them. `--attempts` is per date; 100 per date gives the initial maximum 200 per mechanic class. Search defaults: 30 seconds, 5,000,000 nodes, depth 16, configurable with `--seconds`, `--nodes`, `--depth`. A cap/timeout produces UNKNOWN, never absence of a path. Scorer/enumeration also have guards. A sampled enumeration is explicitly marked incomplete; the universal regression and shared-optimum tests use separate complete bounded searches.

The generator writes accepted individual candidates only, to staging `defs/`, `pool/`, `proofs/`; it records all attempted rejection rules and timings in `generation.json`. A checkpoint is tied to tool/corpus/budget/seed/date inputs and exact accepted artifact bytes. A repeated command resumes remaining attempts; changed inputs require another staging directory. Wall-clock budget outcomes are machine-dependent. `INDIVIDUAL_CANDIDATES_READY` is not pilot or editorial acceptance. `audit-daily` reruns proofs and checks the aggregate pilot; partial/invalid pilots return exit 1.

A pilot report binds every input and pilot artifact. Batch generation (`--no-pilot`) additionally requires `--pilot-report` and `--pilot-acceptance`: a JSON Tech Lead checkpoint with `decision: accepted`, `owner: Tech Lead`, the exact `pilotReportSha256`, and a reasoned `editorialRationale`. Do not manufacture this checkpoint when a pilot fails. The generator's initial strategy may exhaust attempts; report counts and failure distribution and improve construction instead of weakening gates.

## Full production audit and pack

After an accepted corpus, pilot and editorial delivery, canonical Daily source includes `daily_manifest_tr.json`, `pool/`, `defs/`, and `proofs/` with matching IDs. The old draft definitions are historical until explicitly replaced. Reports stay outside source directories.

```sh
dart run bin/looplet_authoring.dart audit-daily ../../content/daily/tr --repo-root ../.. --no-pilot --out ../../build/content-quality/daily-audit.json
dart run bin/looplet_authoring.dart check ../../content --repo-root ../..
dart run bin/looplet_authoring.dart pack-daily ../../content/daily/tr --repo-root ../.. --quality-report ../../build/content-quality/daily-audit.json
```

Full audit requires all 60 days, runtime corpus parity, per-day Q1–Q12, each complete ISO week's rhythm, at least half of frozen days with useful thaw, and duplicate checks against Journey/smoke. The full report's source/corpus/engine/tool/contract/dependency fingerprints must still match at pack time. Missing, partial, failed, stale or inappropriate N/A evidence returns nonzero before output is written. `check` remains the faster structural gate and cannot substitute for quality audit. The audit reports technical evidence; independent QA and the content workflow gate remain separate requirements for acceptance/release.

Explicit test fixtures use `pack-daily --development-fixture`. Only `dev-fixture-*` manifest versions and `dev-fixture` puzzle versions qualify; this switch rejects production-marked pools. It does not make development content publishable.

## Proof semantics

* Reference path: every move applies, only the final state wins, length equals a fresh proven optimum. Q10 counts words in that actual final state.
* Q5 removes each mechanic group separately. A changed optimum proves impact. Exhaustive absence of an ablated solution through the normal optimum also proves a difference; it reports a lower bound, never an invented exact optimum or global unsolvability. Equal optima require an exhaustive absence of a shared optimal move sequence; one common sequence refutes relevance.
* Q6 records, for each frozen row, a path that thaws before winning and wins within optimum + 2.
* Q7 requires an optimal path that subsequently moves a previously frozen cell's letter. Merely thawing on the winning move is insufficient. Pool threshold is distinct from the individual observation.
* Regression is the absence of an optimal path whose maximum per-row correct-position count never decreases. It is a proxy, not proof of player enjoyment.
* Q11 covers exact versioned banned words in initial and recorded reference/proof/diagnostic states, horizontally and vertically in both directions. It does not prove all reachable states or all semantic appropriateness.
