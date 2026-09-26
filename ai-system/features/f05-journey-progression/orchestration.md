# F05 — journey-progression: Orchestration

## Feature ID

F05

## Current Status

In QA

## Current Owner

QA

## Next Role

QA

## Active Task Ledger

- [x] Task ID: F06-CONTENT-PROMOTE | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-13 — promoted the 30 accepted Journey levels from `tools/looplet_authoring/drafts/journey/tr/` to `content/journey/tr/` (real `Puzzle` artifacts, `contentVersion` "2026.09-v1", untouched grid/target/locked/frozen/optimalMoves data) plus a real `mode:"strict"` manifest (30 contiguous entries, sha256 checksums); `content:sync`'s existing rsync mirrored it into `app/assets/journey/tr/`, replacing the 5 interim smoke files. Found and fixed a real toolchain bug in `tools/looplet_authoring/lib/src/content_check.dart` (a Journey manifest, `{levels: [...]}` shape, was force-parsed as a `Puzzle` and rejected — had never been exercised before since no Journey manifest previously lived under `content/`); added a `levels`-key skip branch + a regression test. `flutter test` 181/181 (unchanged — no test needed a content-specific change), `looplet_authoring` `dart test` 20/20 (+1 regression test), `content:check` → OK, F05's own strict manifest gate 4/4 green for the first time against real content, `flutter build ios --release --no-codesign` green (54.7 MB, unchanged size) | Depends On: -
- [ ] Task ID: F05-QA-STRICT | Assigned Role: QA | Status: Open | Summary: ACTIVATED 2026-09-26 by the Tech Lead after F06-CONTENT-PROMOTE reconciled: verify the strict-mode gate and the structural difficulty-curve band rules against the REAL 30-level bundle (not synthetic fixtures), confirm the now-moot interim-content edge case (N1 from the prior QA round), and run full regression. F05-FE2's code-logic layer stays fingerprint-valid (Approved with Notes, unchanged this round) — only what F06-CONTENT-PROMOTE actually touched needs fresh verification. See Current QA Brief | Depends On: F06-CONTENT-PROMOTE

## Open Tasks

None

## Handoff Plan

None

## Delivery Review

Accepted

## QA Scope

client-only

## QA Stage

final

## QA Result

None

## QA Modules

core, client-ui, stateful-flow

## Regression Depth

full

## Evidence Reuse

allowed

## Release Scope

none

## Release Result

None

## Pending Evidence

- Evidence ID: F06.CONTENT-PROMOTE-RECONCILE
  * Scenario: Tech Lead independent verification of F06-CONTENT-PROMOTE's delivery claims before activating F05-QA-STRICT
  * Required Class: automated functional
  * Target / Environment: workspace (melos), content/journey/tr, app/assets/journey/tr
  * Owner Role: Tech Lead
  * Prerequisite / External Decision: None
  * Re-evaluation Trigger: F06-CONTENT-PROMOTE delivery
  * Blocks: F05-QA-STRICT activation
  * Result: PASS
  * Provenance / Note: 2026-09-26 Tech Lead — see Last Decision for the full reconciliation. `content/journey/tr/` holds exactly 30 `journey-tr-NN.json` files + a `mode:"strict"` manifest (confirmed directly); `diff -rq content/journey/tr/ app/assets/journey/tr/` → no differences (byte-identical mirror, confirmed); `tools/looplet_authoring/lib/src/content_check.dart`'s `levels`-key skip branch confirmed present in code; `melos run content:check` → `check: OK` (re-run, real bundle, band rules included); `melos run content:journey` (F05's own strict gate) → 4/4 PASS including the structural band-rule case, first real pass against real content; `flutter analyze` / `dart format --set-exit-if-changed .` clean except pre-existing unrelated items (`looplet_solver` info-lint, `qa/src/qa_probe_main.dart` format — both already documented elsewhere, not F05's); `flutter test` (app) 314/314 (F00 + F05 + everything else, all green together); `looplet_authoring dart test` 20/20 including the new Journey-manifest-recognition regression test.

- Evidence ID: F05.STRICT-CONTENT
  * Scenario: QA's own independent acceptance of the real 30-level strict pack, structural band invariants and now-reachable full-campaign/terminal behavior
  * Required Class: automated functional
  * Target / Environment: Current content/journey/tr, app bundle, CLI validator and Journey tests
  * Owner Role: QA
  * Prerequisite / External Decision: met 2026-09-26 — F06-CONTENT-PROMOTE reconciled (see F06.CONTENT-PROMOTE-RECONCILE above); QA still verifies with its own commands, not on Tech Lead's word alone
  * Re-evaluation Trigger: Tech Lead activated F05-QA-STRICT (2026-09-26)
  * Blocks: F05 final acceptance
  * Result: PENDING

- Evidence ID: F05.SHARED-RUNTIME
  * Scenario: Inherited play/navigation/lifecycle/resume evidence from F03 and local F08 persistence; offline Journey and failure preservation where applicable
  * Required Class: runtime
  * Target / Environment: F03.RUNTIME-MATRIX / VISUAL / ROTATION / BACK; F08.LOCAL-RESUME / OFFLINE-JOURNEY / STORAGE
  * Owner Role: QA
  * Prerequisite / External Decision: Review/reuse proof for the actual shared path; local simulator and isolated storage are independent of paid Firebase deployment
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F05 final acceptance
  * Result: PENDING

## Open Decision Gates

None

## Blockers

None

## Next Action

Run QA on F05-QA-STRICT (Current QA Brief below): verify the strict-mode gate and structural band rules against the real 30-level bundle, confirm the interim-content edge case (N1) is now moot, run full regression. F05-FE2's code-logic evidence (qa.md, Approved with Notes) is reused by fingerprint for everything content-promotion didn't touch. F05.SHARED-RUNTIME (F03/F08 inherited evidence) is still QA's to verify or reuse — not part of this reconciliation.

## Last Decision

2026-09-20 — F05 stays In Progress and queued behind F03: it depends on F03, and F05.SHARED-RUNTIME reuses F03's runtime/back/visual proof, so QA runs F03 first (one QA feature at a time). Tech Lead verified the bundled pack app/assets/journey/tr is byte-identical to content/journey/tr (`diff -rq`, 30 levels + manifest); this is orientation, not QA evidence. No product, content, application or architecture file was changed.

2026-09-26 (F06-CONTENT-PROMOTE reconciliation) — Tech Lead independently re-verified every claim in `frontend.md`'s F06-CONTENT-PROMOTE section rather than accepting it on its word: confirmed `content/journey/tr/` holds exactly 30 real levels + a `mode:"strict"` manifest; confirmed `app/assets/journey/tr/` is byte-identical (`diff -rq`, exit 0); confirmed the `content_check.dart` Journey-manifest-recognition fix is in code and covered by a real regression test; re-ran `content:check` (OK), F05's own strict gate (4/4, including the structural band-rule case — the first real pass against real content), the full `flutter test` suite (314/314, F00's and F05's work coexisting cleanly), workspace `analyze`/`format` (clean except two already-documented, unrelated pre-existing items), and `looplet_authoring`'s own tests (20/20). Delivery Review = Accepted. F05-FE2's prior QA round (`qa.md`, Approved with Notes) evidenced the code-logic layer against interim content and stays valid unchanged — this reconciliation is scoped to what F06-CONTENT-PROMOTE actually touched (content + one toolchain fix), not a re-litigation of already-approved code. F05-QA-STRICT activated — the one remaining gate before F05 can reach Done (`architecture.md §5.5`/§17).

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-26
* Summary: F06-CONTENT-PROMOTE reconciled — content promotion, toolchain fix and strict gate all independently re-verified. Delivery Review = Accepted. F05-QA-STRICT activated (QA Modules/Regression Depth/Evidence Reuse locked: core+client-ui+stateful-flow, full, allowed). Owner -> QA.

## Context & Follow-ups

F05 code and the promoted strict pack are unchanged. Previous qa.md approved the interim smoke content; it is not approval of the current strict pack. Current final approval is therefore None. Separate first-app-distribution gates remain in workflow-follow-ups.md; F08's paid deploy does not automatically block independent F05 local checks.

## History & Evidence References

* [Original orchestration](../../history/core-sync-2026-09-18/features/f05-journey-progression/orchestration.md) — historical only, not a run queue.
* [QA report](qa.md) and [contract](architecture.md) — retained unchanged.
* [Portfolio follow-ups](../../workflow-follow-ups.md) and [migration record](../../history/core-sync-2026-09-18/README.md).
* Canonical execution: role-execution-contract.md; historical next-command text does not authorize execution.

## Change Log

* 2026-09-18 — migrated state; see the immutable pre-migration snapshot for all earlier tasks, decisions and evidence.
* 2026-09-20 — Tech Lead: QA sequencing set to F03 first; F05 routing note only.
* 2026-09-20 — Tech Lead: F03 QA Rejected; F05 stays queued behind F03 rework + re-QA (rework-control rule).
* 2026-09-21 — Tech Lead: F03 Done; lock released; F05 Next Action re-pointed (delivery reconciliation, then QA-STRICT).
* 2026-09-26 — Tech Lead: F06-CONTENT-PROMOTE reconciled (content promotion, toolchain fix and strict gate independently re-verified); Delivery Review = Accepted; QA plan locked (final, client-only, core+client-ui+stateful-flow, full, allowed); F05-QA-STRICT activated.

## Consumed Signals

* analysis.md decisions D1–D8 were consumed into architecture.md; reopen only affected unresolved questions.
* F06-CONTENT-PROMOTE was Tech-Lead-reconciled on 2026-09-13; that is delivery evidence, not the outstanding QA verdict.

## Current QA Brief (F05-QA-STRICT — activated 2026-09-26)

Targeted final-stage verification of F06-CONTENT-PROMOTE. F05-FE2's code-logic layer (`qa.md`, Approved with Notes) stays fingerprint-valid — reuse it for anything content-promotion didn't touch; verify fresh only what changed (real content, the toolchain fix) plus a full regression pass.

**What changed since the last QA round:** `content/journey/tr/` now holds the real 30 levels + a `mode:"strict"` manifest (was 5 interim smoke levels, `mode:"smoke"`); `app/assets/journey/tr/` mirrors it; `tools/looplet_authoring/lib/src/content_check.dart` gained a Journey-manifest recognition fix. No `app/lib` code changed in this promotion (frontend.md's own claim — verify it).

**Tech Lead's own pre-check (F06.CONTENT-PROMOTE-RECONCILE, Pending Evidence above) — do not take on faith, reproduce with your own commands:**
1. Verify the actual strict manifest checks (contiguity, checksum, identity, `optimalMoves >= 1`) AND the structural band rules (`architecture.md §5.4`: `columnMovesEnabled` per band, `difficultyLabel` per band) against the real bundle — both `melos run content:check` (CLI, `_expectedBands`) and `melos run content:journey` (F05's own gate, `journey_manifest_gate_test.dart`, including its now-real strict-mode case). Map each claimed hard invariant to its executable assertion and a rejecting case; do not assume a green run enforces every rule without reading what it actually checks.
2. Retain the user's recorded 2026-09-13 content acceptance (levels 1–3 `optimalMoves == 2`, not the old unachievable `{3,4}` — `architecture.md §5.4` already documents this correction). Do not silently change product criteria; any unresolved conflict goes to Tech Lead/PO, not a fabricated bug.
3. Confirm the prior round's **N1 non-blocking note is now moot**: a player completing all levels while short of 30/30 (the old interim-manifest edge, `continueTarget` pointing past the 5-level pack) can no longer occur now that the real 30 are bundled — state this explicitly rather than silently dropping the note.
4. Re-verify newly-reachable all-30-complete / `Next Level` → terminal against the REAL 30-level manifest (frontend.md's own Test Notes flagged this as untested against real content, deferred pending F06-CONTENT — that block is now cleared).
5. Full regression: `flutter analyze`, `dart format --set-exit-if-changed .` (workspace `format:check`'s one pre-existing failure is `ai-system/features/f00-design-foundation/qa/src/qa_probe_main.dart` — unrelated, already documented, not F05's), `flutter test` (app — expect 314, unchanged from before this promotion since no test needed a content-specific edit; confirm, don't assume), `looplet_authoring dart test` (expect 20/20).
6. F05.SHARED-RUNTIME (F03/F08 inherited runtime evidence) is still open and still yours — F05's own automated-functional scope does not erase another component's required proof; paid deploy/store distribution are not prerequisites for local Journey testing.
7. Record actual commands, targets, results and provenance. Final verdict is independent — Tech Lead's own pre-check is a starting point, not a substitute for your own run.
