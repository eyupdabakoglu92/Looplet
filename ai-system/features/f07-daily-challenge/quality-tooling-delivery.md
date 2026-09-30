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

---

# F07-TOOL-DAILY-R1 — tooling rework (Frontend/Mobile Developer, 2026-09-30)

Authority: `architecture.md` A7 rulings 1–3; brief: orchestration Current Brief. Delivery Review Pending; Content Quality Gate remains Pending. No change to `content/`, the runtime dictionary, the curation data, the app, CI, any Q-rule, threshold, scorer weight or label boundary.

## Summary

The A7 symptom is closed: the committed technical pilot re-audits to identical verdicts twice, once under load, and every UNKNOWN names its cause. Weekend profile: optimum 6 and 7 are **not feasible** within the 5,000,000-node bound, because the F06 difficulty term `cNorm` counts every state within depth `o` and cannot be pruned. The measurements are below; the profile decision is returned to the Tech Lead (§ Needs Tech Lead Clarification).

## Task-to-code traceability

| Brief item | Status | Files | Behaviour |
| --- | --- | --- | --- |
| 1. Deterministic verdicts | Complete | `packages/looplet_solver/lib/src/solve_result.dart`, `tools/looplet_authoring/lib/src/quality_cli.dart`, `daily_quality.dart`, `daily_pool_quality.dart`, `quality_search.dart` | `SearchGuard.check` tests the node bound before the clock; `SearchLimitExceeded` / `BudgetExceeded` carry `cause` (`nodes` / `depth` / `time`), `nodes` and `elapsed`. Every Q-rule UNKNOWN stores `stop: {phase, cause, nodes, elapsedMs}`. `SearchStats` records per-phase peak nodes and duration; each audited day reports them under `search` (diagnostic only; not in exports or verdicts). CLI `--seconds` for `generate-daily`, `audit-daily`, `audit-corpus-impact`: default and maximum 300 (`analysisSeconds`); node/depth bounds unchanged. |
| 2. o = 6 / 7 feasibility | Complete — measured; not feasible (cNorm) | `packages/looplet_solver/lib/src/lower_bound.dart`, `solver.dart`, `difficulty.dart`, `tools/looplet_authoring/lib/src/quality_search.dart`, `tool/measure_search_depth.dart` | `WinLowerBound`: `min over (row, window) of min(|M|, 1 + d)`; a wrong locked cell makes a window unreachable. Proof of admissibility and consistency in the file. `Solver.solve`: breadth-first search under an increasing bound (byte-identical sequence to the unpruned BFS by consistency). Optimal enumeration: bounded depth-first walk plus a (state, remaining) no-completion memo; same list and order. `searchWitness` (Q5 ablation and common search, Q6, Q7, regression): children with `depth + bound > maxDepth` are dropped; the common search uses the larger bound of both engines. `cNorm` is left unpruned by definition. Measurement tool added. |
| 3. Portability | Complete | `quality_io.dart` (`repoRelative`, `resolveReportSource`), `daily_pool_quality.dart`, `quality_cli.dart`, tool `README.md` | Reports store `sourceDir` repo-relative and `/`-separated; the batch gate resolves it from `--repo-root` and rejects absolute, empty or missing paths. The README records that a production pack needs the Dart runtime of its full audit (`runtime/dart` fingerprint). |
| 4. Regenerated pilot | Complete | `evidence/technical-pilot-v1-audit.json` (regenerated), `evidence/technical-pilot-v1-provenance.json` (`reaudits`) | Source bytes unchanged (fingerprint entries for defs/pool/proofs/manifest are equal to the delivered report); the report is regenerated with the changed tools. |

## Evidence records

All on the working tree based on 1032f8a plus this delivery; host: the canonical macOS workstation; corpus: `import-corpus` of the committed curation (517 words / 369 targets), byte-identical to the A7 staging corpus. No mocks; the real F02 engine throughout.

| Claim | Class | Command | Result |
| --- | --- | --- | --- |
| Pruned solve / enumeration equal exhaustive search; inflated bound caught; bound admissible + consistent on every state within depth 2; stop causes; nodes decide before the clock; scorer stats | unit | `dart test` in `packages/looplet_solver` (new `test/pruning_soundness_test.dart`, 11 tests over 24 generated fixtures — open / locked / frozen / both, ≥ 3 distinct optima) | exit 0, 40 / 40 |
| Pruned witness search equals exhaustive in every audit mode (plain, absence below optimum, nondecreasing, Q5 common, Q6 thaw, Q7 useful, win-move thaw); inflated bound caught; UNKNOWN stop record; stats do not change verdicts; `--seconds` 1..300; repo-relative source; batch gate rejects an absolute pilot source | unit + CLI | `dart test` in `tools/looplet_authoring` (new `test/search_determinism_test.dart`, 9 tests) | exit 0, 105 / 105 |
| Static analysis | static | `dart analyze` in both packages | No issues |
| Preserved behaviour on all committed content | repeatable integration | `melos run content:check` | SUCCESS, exit 0 (10.5 s; the A4 re-run took 110 s) |
| Pilot re-audit run 1 | repeatable integration | `audit-daily ../../ai-system/features/f07-daily-challenge/evidence/technical-pilot-v1 --repo-root ../.. --corpus <staging> --out ../../ai-system/features/f07-daily-challenge/evidence/technical-pilot-v1-audit.json` (2026-09-30T15:36:19Z, idle) | exit 0, PASS, 45 s |
| Pilot re-audit run 2 | repeatable integration | same command to a scratch report, concurrent with both `dart test` suites (2026-09-30T15:37:12Z) | exit 0, PASS, 45 s |
| o = 6 / 7 feasibility | measurement | `dart run tool/measure_search_depth.dart <staging corpus> <out> --attempts 3000 --max-extra 6` (seed 20260930) | exit 0; `evidence/r1-depth-measurement.json` |

Run 1 vs run 2: identical `inputHash` / `analysisInputHash`, per-rule verdicts, difficulty, proofs, regression results and **per-phase peak nodes**. Both equal the delivered report's per-rule verdicts; 2026-11-04 is PASS in both (the A7 failure).

**Before / after (preserved difficulty):** 2026-11-04 `lokma` — medium, 5.2728 (breakdown `o 5, cNorm 0.0034, tdDegree 0, firstMoves 5, distinctOptimalSolutions 33, complete`) before and after. Every pilot day's `difficulty` object is identical to the delivered report.

**Pilot resource use (run 1, peak nodes / ms):**

| Day | o | solve | enumeration | cNorm state tree | largest witness search |
| --- | --- | --- | --- | --- | --- |
| 11-02 open | 4 | 27 / 19 | 29 / 11 | 65,550 / 612 | regression 21 |
| 11-03 locked | 4 | 152 / 26 | 181 / 45 | 60,553 / 626 | Q5 locked ablated 135 |
| 11-04 frozen | 5 | 726 / 148 | 801 / 280 | 803,418 / 10,403 | Q5 frozen ablated 960 |
| 11-07 both | 5 | 2,055 / 352 | 2,096 / 723 | 489,876 / 6,929 | Q5 locked ablated 3,427 |
| 11-09 open | 5 | 1,906 / 313 | 1,945 / 589 | 907,445 / 9,446 | — |
| 11-10 locked | 4 | 222 / 24 | 236 / 54 | 60,353 / 552 | Q5 locked ablated 227 |
| 11-11 frozen | 4 | 268 / 38 | 314 / 86 | 60,774 / 695 | Q5 frozen ablated 369 |
| 11-14 both | 5 | 606 / 130 | 614 / 234 | 658,164 / 8,743 | Q5 frozen ablated 1,415 |

The 2026-11-04 enumeration now uses 801 prefixes and 0.28 s (A7: 29.7 s, a full breadth-first ball). The largest remaining cost at o = 5 is the unpruned `cNorm` tree: ≤ 907,445 nodes (18 % of the bound), ≤ 10.4 s.

**o = 6 / 7 measurement** (796 attempts; fresh optima seen: 1: 38, 2: 99, 3: 133, 4: 119, 5: 60, 6: 15, 7: 2; peak nodes / ms; bound 5,000,000 nodes):

| Candidate | o | solve | enumeration | cNorm → Q4 | Q5 searches | Q6 thaw (depth o + 2) | Q7 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 11-07 both `koyun` | 6 | 9,003 / 1,895 | 9,108 / 3,354 | **5,000,001 / 60,964 → UNKNOWN (nodes)** | ≤ 16,047 | 1,441,550 / 219,676 (PASS) | 9,004 |
| 11-07 both `yunus` | 6 | 8,063 / 1,587 | 8,257 / 2,952 | **5,000,001 / 62,443 → UNKNOWN (nodes)** | ≤ 16,409 | PASS on the reference path (no search) | PASS on the reference path |
| 11-07 both `mizah` | 7 | 129,676 / 26,997 | 133,556 / 45,915 | **5,000,001 / 64,440 → UNKNOWN (nodes)** | ≤ 235,710 | **5,000,001 → UNKNOWN (nodes)** | 129,698 |
| 11-07 both `işlem` | 7 | 119,491 / 24,519 | 122,425 / 47,949 | **5,000,001 / 76,599 → UNKNOWN (nodes)** | ≤ 250,005 | **5,000,001 → UNKNOWN (nodes)** | 119,561 |

Every stop is `nodes`; none is `time` (the slowest phase took 227 s under the 300 s ceiling). Solve, enumeration, Q5, Q7 and regression fit at o = 6 and 7 with pruning. **The cNorm tree exceeds the bound at o = 6 on every measured candidate**, so Q4 is UNKNOWN and no o ≥ 6 day can be accepted; the tree grows ~×8–15 per depth (o = 4: ~60 k, o = 5: 0.49–0.91 M). At o = 7, Q6's constrained thaw search (depth 9) also exceeds the bound, because the lower bound ignores the thaw requirement. Q5 FAIL on all four is a property of these deliberately randomised candidates, not of feasibility.

Limits of this measurement: the construction was deepened at random and reached o ≥ 6 only on the Saturday combined-mechanic date (4 candidates); Friday-locked and Sunday-frozen o ≥ 6 were not reached. The generator's own construction scrambles at most 5 moves (`daily_generator.dart`, "Five moves plus two mechanics"), so `generate-daily` does not propose o ≥ 6 candidates at all today.

## Behaviour preserved

* Optima, `Optimal.sequence` bytes, optimal-solution lists and order, witness paths and absence verdicts are unchanged — proven equal to the exhaustive search on fixtures, and in practice by `content:check` and the pilot (identical proofs, difficulty and verdicts).
* Exported `difficultyBreakdown` keys and values: unchanged (stats live outside the breakdown).
* The production pack gate, fixture separation and all Q-rules: unchanged code paths; their existing negative tests pass.
* Behaviour that changes only from UNKNOWN / BudgetExceeded to a proven result: pruning can finish searches the old code could not; an all-windows-locked start is now `Unsolvable` at once (it was a full search).

## Needs Tech Lead Clarification

1. **Weekend profile vs the F06 `cNorm` definition (A7 ruling 2).** With the unchanged 5,000,000-node bound, Q4 is UNKNOWN for every measured o ≥ 6 day because `cNorm` needs the full state tree within depth `o`. Pruning cannot apply (it is a count, not a search). This is a contract decision; options as measured:
   * narrow the heavy-day optimum profile to 5 (§4 contract change);
   * change the F06 difficulty definition for `cNorm` (for example a depth-capped tree), which would also re-score Journey content above that depth (an F05 / F06 content impact);
   * a larger node bound for this one phase (~×8–15 per extra depth from the o = 5 sizes: o = 6 about 4–14 million, o = 7 about 30–200 million states — an extrapolation, not a measurement; the upper range is not practical on this host).
2. **Q6 at o = 7** (depth o + 2 = 9) exceeds the bound on both measured candidates; if o = 7 stays in the profile, a thaw-aware bound or a smaller `o + 2` allowance is needed.
3. **Generator construction depth** is at most 5 moves; if o = 6 / 7 stays in the profile after decision 1, a construction change is a separate Developer task.

## Workflow suggestion (non-authoritative)

Completed: F07-TOOL-DAILY-R1. Remaining: Tech Lead checkpoint (A7 re-review, the profile decision above). Status suggestion: Needs Tech Lead Review.

## Sonraki Komut

Run Tech Lead
