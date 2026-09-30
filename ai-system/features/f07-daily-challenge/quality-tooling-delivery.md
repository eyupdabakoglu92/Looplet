# F07 quality tooling delivery — 2026-09-30

Status: Developer delivery complete; Tech Lead review pending. Content Quality Gate remains Pending. This delivery does not approve a production corpus, the 60-day pool, editorial quality, independent QA or release.

## Delivered behavior

* `import-corpus` verifies pinned source bytes, preserves the legacy dictionary, applies explicit curation/quarantine rules and writes only to an explicit staging path.
* `audit-corpus` compares an asset with the reproducible sourced curation. The current runtime asset fails closed; the prospective staging asset passes.
* `audit-corpus-impact` compares current and candidate corpus behavior without modifying the runtime asset, fingerprints the content inputs and blocks promotion on incomplete analysis or unresolved re-export changes.
* `generate-daily` creates deterministic candidates outside canonical content, enforces bounded attempts/search, persists resumable checkpoints and writes only individually accepted artifacts. A changed input hash requires a new staging directory.
* Its pool planner assigns proven-regression slots before generation: the hard combined-mechanic slot in the pilot, and Monday plus Saturday in every complete production ISO week. Aggregate audit still rechecks the requirement.
* `audit-daily` replays the real engine and evaluates Q1–Q12, including fresh optimum/difficulty, per-mechanic ablation, thaw-before-win, useful thaw, all-optimal-path regression, final-state words, exact exclusion scans, pool cadence and near-duplicate checks. Timeout or resource exhaustion is UNKNOWN and rejects the candidate.
* Solver and difficulty analysis now have explicit depth/node/time limits and report incomplete enumeration instead of treating a sample as a universal proof.
* Production `pack-daily` requires a current full 60-day PASS report bound to the exact corpus, engine, tool, contract, definitions, proofs and exports. The explicit development-fixture path accepts only fixture-marked content.

The Q5 implementation searches an ablated puzzle exhaustively through the proven normal optimum. No solution through depth `o` proves only the required lower bound (`ablated optimum > o` or unsolvable); it does not invent an exact optimum or claim global unsolvability. Equal optima still require a complete joint search showing that no optimal move sequence wins in both systems.

## Technical pilot

The durable source is `evidence/technical-pilot-v1/`; the current report is `evidence/technical-pilot-v1-audit.json` (SHA-256 `98a8096aaec4a0e5b40a1a75df66ef6b3852c3d1273d4415f751e0bc1a96697b`). Candidate seeds and selection provenance are in `evidence/technical-pilot-v1-provenance.json`.

Fresh audit result: **PASS**, with `independentQa: false`.

* 8 distinct targets and 8 artifacts: 2 open, 2 locked, 2 frozen, 2 combined-mechanic.
* All applicable required daily rules PASS; N/A occurs only when the mechanic is absent.
* 4 frozen/combined days out of 4 have a useful-thaw optimal solution.
* 2 days have proven temporary regression across every optimal path. The 2026-11-14 combined-mechanic example is hard, weekend-weighted and regression-positive.
* Q12 found no target reuse or ≤2-real-move near duplicate against the pilot, Journey or smoke content.
* Search budget: 30 seconds, 5,000,000 nodes and depth 16 per analysis. The two most expensive selected audits took about 48 s and 71 s because a day performs several separately bounded analyses.

This is Developer feasibility evidence. The committed corpus curation is still labelled provisional; its editorial categories/rationales need Content Designer completion. The technical pilot must be re-audited after any corpus/tool/engine/contract change and then receive a reasoned Content Designer review plus the planned Tech Lead checkpoint. It does not authorize batch generation.

## Verification

* `dart analyze` in `tools/looplet_authoring`: no issues.
* `dart test` in `packages/looplet_solver`: 29/29 PASS.
* `dart test` in `tools/looplet_authoring`: 96/96 PASS, including bounded-search, corpus-impact comparison, exact raw schema/export matching, regression-slot planning, malformed proof, Q5/Q6/Q7, Turkish exclusion scan, duplicate, stale evidence, production-pack rejection, corpus-integrity and CLI fail-closed cases.
* `node --test ai-system/tools/tests/*.test.mjs`: 93/93 PASS.
* Full existing `content/` check after the solver changes: `check: OK`.
* Prospective `audit-corpus`: PASS. Current runtime `audit-corpus`: expected FAIL because it remains the old 103-word/30-target asset.
* Old canonical Daily pool `audit-daily --no-pilot`: expected FAIL with 67 errors; it has no current definitions/proofs and zero accepted days under the new audit.
* `git diff --check`: PASS.

## Remaining work

F07-CORPUS must complete editorial curation and run `audit-corpus-impact`; any changed accepted content is re-exported from the same grids/mechanics before promoting the runtime corpus. The superseded Daily pool is not promoted and will be replaced. F07-CONTENT-PILOT then repeats the pilot as a Content Designer delivery, including editorial replay review. Only a Tech Lead-accepted pilot unlocks F07-CONTENT-R1, which creates and audits the replacement 60-day pool. Independent QA remains required before `Content Quality Gate = Passed`.

## Sonraki Komut

Run Tech Lead
