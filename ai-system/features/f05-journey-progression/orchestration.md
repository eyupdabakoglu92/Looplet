# F05 — journey-progression: Orchestration

## Feature ID

F05

## Current Status

Rework

## Current Owner

Frontend/Mobile Developer

## Next Role

Frontend/Mobile Developer

## Active Task Ledger

- [x] Task ID: F06-CONTENT-PROMOTE | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-13 — promoted the 30 accepted Journey levels from `tools/looplet_authoring/drafts/journey/tr/` to `content/journey/tr/` (real `Puzzle` artifacts, `contentVersion` "2026.09-v1", untouched grid/target/locked/frozen/optimalMoves data) plus a real `mode:"strict"` manifest (30 contiguous entries, sha256 checksums); `content:sync`'s existing rsync mirrored it into `app/assets/journey/tr/`, replacing the 5 interim smoke files. Found and fixed a real toolchain bug in `tools/looplet_authoring/lib/src/content_check.dart` (a Journey manifest, `{levels: [...]}` shape, was force-parsed as a `Puzzle` and rejected — had never been exercised before since no Journey manifest previously lived under `content/`); added a `levels`-key skip branch + a regression test. `flutter test` 181/181 (unchanged — no test needed a content-specific change), `looplet_authoring` `dart test` 20/20 (+1 regression test), `content:check` → OK, F05's own strict manifest gate 4/4 green for the first time against real content, `flutter build ios --release --no-codesign` green (54.7 MB, unchanged size). [CORRECTED 2026-09-26, Tech Lead: the "4/4" contains no band-rule assertion (empty test body) and the `levels`-key skip is bypassable — F05-QA-STRICT-1/-2; the content promotion itself stands] | Depends On: -
- [x] Task ID: F05-QA-STRICT | Assigned Role: QA | Status: Done | Summary: DONE 2026-09-26 — verdict Rejected (qa.md § F05-QA-STRICT; final, client-only, HEAD 6fb2d23). The real pack itself is clean: independent probe 30/30 levels, 0 violations of §5.4 R1–R6 + the 2026-09-13 decision, content/ and app/assets/ identical (git tree 057f242b); full campaign 1..30 → terminal → replay L1 proven against the real bundle (real level 30 won by a real drag → SONRAKİ → TAMAMLANDI); AC7 resume across a real process kill PASS on iPhone 16; N1 moot; regression green (analyze, format, app 314/314, F05 73/73, packages 197/197, F03 device 13/13). Blocking: F05-QA-STRICT-1 (High) — the strict build gate enforces no structural band rule: F05's band test has an empty body and the gate never reads band fields (R1/R4/R5/R6 violations → passed: true); content:check rejects R1/R6 explicitly, R2/R3 only incidentally, R4/R5 not at all — the "4/4 incl. the structural band-rule case" delivery and reconcile claim is misattributed. F05-QA-STRICT-3 (Medium, AC7) — the home read-model never re-reads the active-session snapshot in-session: no in-progress state after backing out of a level, and mid-replay of a completed level makes in-session CONTINUE target the frontier (Seviye 3) while the same persisted state after relaunch targets the replay (Seviye 2 · sürüyor); reproduced at runtime and in a widget probe. Same rework: F05-QA-STRICT-2 (Medium) — a stray "levels" key makes content:check skip all puzzle validation (a wrong optimalMoves passes). Also: the brief's "F05-FE2 fingerprint-valid" was inaccurate (8 files changed since 345147e) — QA re-ran the affected suites | Depends On: F06-CONTENT-PROMOTE
- [ ] Task ID: F05-FE3-GATE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: ACTIVATED 2026-09-26 (F05-QA-STRICT reconcile) — close F05-QA-STRICT-1 and -2 per architecture.md §5.4/§15 (amended 2026-09-26): F05's strict build gate enforces R1–R6 + the manifest-label check on the shipped bundle, each rule with its own rejecting negative test; CI fails when app/assets/journey/<lang>/ differs from content/journey/<lang>/; content:check recognizes only a real Journey manifest (path + shape) and validates everything else; frontend.md erratum for the misattributed F06-CONTENT-PROMOTE claims; stale interim comments on touch. See Current Rework Brief | Depends On: F05-QA-STRICT
- [ ] Task ID: F05-FE3-HOME | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: ACTIVATED 2026-09-26 (F05-QA-STRICT reconcile) — close F05-QA-STRICT-3 per architecture.md §6/§10/§15 (amended 2026-09-26): the home read-model re-derives on active-session snapshot changes as well as journey_progress changes, so the mounted home shows the in-progress state and the §6 CONTINUE target (incl. a completed-level replay) right after returning from /play — warm == cold for the same persisted state; warm-path widget tests. See Current Rework Brief | Depends On: F05-QA-STRICT

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

Rejected

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
  * Scenario: Tech Lead independent verification of the Journey content gate's delivery claims before (re-)activating QA
  * Required Class: automated functional
  * Target / Environment: workspace (melos), content/journey/tr, app/assets/journey/tr, the F05 gate and content:check sources
  * Owner Role: Tech Lead
  * Prerequisite / External Decision: F05-FE3-GATE delivered
  * Re-evaluation Trigger: F05-FE3-GATE delivery reconciliation — Tech Lead reads each check and runs its negative case, not only the green suite
  * Blocks: F05 re-QA activation
  * Result: FAIL
  * Provenance / Note: CORRECTED 2026-09-26 (Tech Lead, after F05-QA-STRICT). The pre-QA reconciliation recorded "`content:journey` (F05's own strict gate) → 4/4 PASS including the structural band-rule case" without reading the test. That claim is false: `journey_manifest_gate_test.dart:75-80` has an empty body and `journey_gate_support.dart` reads no band field. The other verified facts still stand, re-confirmed today: the 30 real levels plus the strict manifest; the byte-identical mirror; `content:check` OK on real content; 314/314 app tests; 20/20 authoring tests. Tech Lead's own negative runs today: R4 (L24) and R5 (L27) violations → `content:check` exit 0; L05 `optimalMoves` 7 → exit 1, the same file plus `"levels": []` → exit 0. The original text is kept in history/f05-journey-progression-2026-09-26/orchestration-at-qa-strict-verdict.md.

- Evidence ID: F05.STRICT-CONTENT
  * Scenario: QA's own independent acceptance of the real 30-level strict pack, structural band invariants and now-reachable full-campaign/terminal behavior
  * Required Class: automated functional
  * Target / Environment: Current content/journey/tr, app bundle, CLI validator and Journey tests
  * Owner Role: QA
  * Prerequisite / External Decision: F05-FE3-GATE delivered and Tech Lead-reconciled (F06.CONTENT-PROMOTE-RECONCILE PASS)
  * Re-evaluation Trigger: F05 re-QA after the F05-FE3 rework
  * Blocks: F05 final acceptance
  * Result: FAIL
  * Provenance / Note: 2026-09-26 QA, HEAD 6fb2d23 (clean tree). The content itself passes: independent probe 30/30 levels, 0 violations of §5.4 R1–R6 + the 2026-09-13 levels 1–3 decision + ids/checksums/labels, both trees identical (git tree 057f242b); full campaign/terminal against the real bundle 7/7 (qa.md QS-01, QS-09). FAIL because the strict build gate does not enforce the structural band rules (architecture.md §15 "Build gate"): journey_manifest_gate_test.dart:75-80 band test has an empty body and runJourneyManifestGate passes R1/R4/R5/R6 violations with `passed: true` (QS-03); content:check passes R4/R5 violations and a stray-`levels`-key bypass (QS-02). Findings F05-QA-STRICT-1 and F05-QA-STRICT-2 in qa.md.

- Evidence ID: F05.HOME-LIVE-STATE
  * Scenario: Warm-path home read-model (architecture.md §6/§10/§15, amended 2026-09-26). The home stays mounted while `/play` writes, changes or clears the active-session snapshot — frontier level started, completed level replayed, level won. On return to `/` the home must show the same in-progress caption, `Semantics` and CONTINUE target as the cold (relaunch) derivation for the same persisted state.
  * Required Class: automated functional
  * Target / Environment: app widget tests with the real repos and in-memory Drift; an optional ad-hoc iPhone 16 simulator spot-check (§15)
  * Owner Role: QA
  * Prerequisite / External Decision: F05-FE3-HOME delivered and Tech Lead-reconciled
  * Re-evaluation Trigger: F05 re-QA after the F05-FE3 rework
  * Blocks: F05 final acceptance
  * Result: FAIL
  * Provenance / Note: 2026-09-26 QA, F05-QA-STRICT QS-12: runtime rt06/rt07 (frontier) and rt14/rt15 (replay); widget probe D1 warm [Seviye 2] vs cold [Seviye 2 · sürüyor], D2 warm [Seviye 3] vs cold [Seviye 2 · sürüyor]. Tech Lead re-ran the same probe on HEAD e5aaacf the same day: 7/7 with identical D1/D2 output. Root cause is the contract, not the implementation: §6 specified "a one-shot active-session snapshot read" and journey_progress.dart:83-94 implements exactly that.

- Evidence ID: F05.SHARED-RUNTIME
  * Scenario: Inherited play/navigation/lifecycle/resume evidence from F03 and local F08 persistence; offline Journey and failure preservation where applicable
  * Required Class: runtime
  * Target / Environment: F03.RUNTIME-MATRIX / VISUAL / ROTATION / BACK; F08.LOCAL-RESUME / OFFLINE-JOURNEY / STORAGE
  * Owner Role: QA
  * Prerequisite / External Decision: Review/reuse proof for the actual shared path; local simulator and isolated storage are independent of paid Firebase deployment
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F05 final acceptance
  * Result: PASS
  * Provenance / Note: 2026-09-26 QA — PASS for the shared path F05 consumes. F03 play/navigation/lifecycle: REUSED F03 final QA runtime (51497dd; fingerprint-valid — the last app/lib/play change cf747f8 is its ancestor and nothing in lib/play, lib/rating, lib/persistence, bootstrap, main or router changed since) plus the F03 device suite re-run 13/13 on iPhone 16 (qa.md QS-08). F08 local persistence/resume through F05's Journey screens: EXECUTED on iPhone 16 — journey progress survived a real kill/relaunch; a mid-level kill → CONTINUE restored grid, move count and undo history exactly (QS-10, QS-11). Not claimed here: the network-off device run and storage-failure runtime stay F08's own PENDING records (F08.OFFLINE-JOURNEY, F08.STORAGE in F08's orchestration); per architecture.md §15 device runtime does not gate F05, and AC14 is covered by automated functional + the local-only Journey path. The in-session home staleness (F05-QA-STRICT-3) is an F05 read-model defect, not a failure of the inherited evidence. Tech Lead 2026-09-26: accepted. The fingerprint claims were re-confirmed with `git merge-base` / `git diff`. The untested offline and storage branches remain tracked in F08 and in the SHARED-PERSISTENCE-PROOF entry of workflow-follow-ups.md; architecture §13/§15 exclude them from the F05 gate. F05-FE3-HOME touches only the read-model, so this record stays valid unless the persistence or restore code changes.

## Open Decision Gates

None

## Blockers

None

## Next Action

Run Frontend/Mobile Developer on F05-FE3-GATE and F05-FE3-HOME (Current Rework Brief below; architecture.md §5.4/§6/§10/§15 amended 2026-09-26). Deliver both; record the rule → check → negative-case mapping and the warm-path test evidence in frontend.md (new F05-FE3 section, including the F06-CONTENT-PROMOTE erratum); set Delivery Review = Pending and hand back to Tech Lead for reconciliation, then the F05 re-QA.

## Last Decision

2026-09-26 (F05-QA-STRICT reconciliation) — Tech Lead reconciled QA's Rejected verdict and re-verified all three findings with its own commands before accepting them.

* **Re-verification:**
  * Read the band test body (`journey_manifest_gate_test.dart:75-80`: empty) and the gate (`journey_gate_support.dart`: 0 reads of band fields).
  * Mutated levels QA had not used and ran the real `content:check`:
    * R4 on L24 and R5 on L27 → `check: OK`.
    * L05 `optimalMoves` 7 → rejected; the same file plus `"levels": []` → `check: OK`.
  * Re-ran QA's real-bundle probe (7/7; warm `[Seviye 3]` vs cold `[Seviye 2 · sürüyor]` reproduced) and read `journey_progress.dart:83-94`.
  * Confirmed QA's fingerprint claims: 8 F05/shared files changed since 345147e; the F03 runtime evidence at 51497dd is still valid.
* **Accepted:** QA Result Rejected. F05-QA-STRICT-1 (High) and -3 (Medium, AC7) are blocking; -2 (Medium) is in the same rework.
* **Own errors corrected:**
  * The pre-QA reconciliation earlier today accepted "4/4 including the structural band-rule case" without reading the test. workflow-follow-ups.md "Required Migration Follow-through" explicitly forbade exactly that.
  * The QA brief called F05-FE2 "fingerprint-valid", which was wrong.
  * F06.CONTENT-PROMOTE-RECONCILE is now FAIL with a correction note, and the F06-CONTENT-PROMOTE task summary is annotated.
* **Contract (Tech Lead authority):**
  * STRICT-3's root cause was §6's own "one-shot active-session snapshot read". §6/§10 now require the read-model to be live on both sources.
  * The replay semantics stay unchanged and are clarified: a completed-level replay in progress is the in-progress level and CONTINUE resumes it. Product AC7 already says this, so no PO decision is needed.
  * §5.4/§15 now make F05's gate the authority for R1–R6 plus the manifest-label check on the shipped bundle, with one negative case per rule. They also require a byte-identical `content/` mirror and path+shape Journey-manifest recognition in `content:check`.
  * prd.md AC3 is resynced to the authoritative product-prd.md AC (2 moves). This is a derived-copy sync with no semantic change.
* **Shared runtime:** F05.SHARED-RUNTIME PASS is accepted. The offline and storage-failure device branches stay with F08 and SHARED-PERSISTENCE-PROOF; §13/§15 exclude them from the F05 gate.
* **Routing:** F05-FE3-GATE + F05-FE3-HOME → Frontend/Mobile Developer; then Tech Lead reconciliation; then an F05 re-QA. F08 stays queued behind F05 (rework control).

Earlier decisions (2026-09-20 QA sequencing; the 2026-09-26 pre-QA reconciliation in full) are in history/f05-journey-progression-2026-09-26/orchestration-at-qa-strict-verdict.md.

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-26
* Summary: F05-QA-STRICT reconciled — QA's three findings independently re-verified and accepted (QA Result Rejected). Contract amended (§5.4, §6, §10, §15); prd.md AC3 resynced. F05-FE3-GATE and F05-FE3-HOME activated; status Rework; owner → Frontend/Mobile Developer.

## Context & Follow-ups

* **Rework scope:** F05 is in Rework for the build gate and the home read-model only.
* **Content is out of scope:** the 30 real levels are clean (QA QS-01) and are not edited in this rework.
* **Carried non-blocking notes:**
  * 11–15 `tdDegree = 0` — accepted as-is content; noted for PO visibility.
  * A replayed completed level renders as in-progress on the ring — this is by §6 design.
* **Tracked elsewhere:**
  * Offline and storage-failure device branches: workflow-follow-ups.md SHARED-PERSISTENCE-PROOF and F08.
  * First-app-distribution: workflow-follow-ups.md; not an F05 gate.

## History & Evidence References

* [Original orchestration](../../history/core-sync-2026-09-18/features/f05-journey-progression/orchestration.md) — historical only, not a run queue.
* [Snapshot at the F05-QA-STRICT verdict](../../history/f05-journey-progression-2026-09-26/orchestration-at-qa-strict-verdict.md) — the full QA brief and the uncorrected pre-QA reconciliation.
* [QA report](qa.md) (§ F05-QA-STRICT) and [contract](architecture.md) (amended 2026-09-26).
* [Portfolio follow-ups](../../workflow-follow-ups.md) and [migration record](../../history/core-sync-2026-09-18/README.md).
* Canonical execution: role-execution-contract.md; historical next-command text does not authorize execution.

## Change Log

* 2026-09-18 — migrated state; see the immutable pre-migration snapshot for all earlier tasks, decisions and evidence.
* 2026-09-20 — Tech Lead: QA sequencing set to F03 first; F05 routing note only.
* 2026-09-20 — Tech Lead: F03 QA Rejected; F05 stays queued behind F03 rework + re-QA (rework-control rule).
* 2026-09-21 — Tech Lead: F03 Done; lock released; F05 Next Action re-pointed (delivery reconciliation, then QA-STRICT).
* 2026-09-26 — Tech Lead: F06-CONTENT-PROMOTE reconciled (content promotion, toolchain fix and strict gate independently re-verified); Delivery Review = Accepted; QA plan locked (final, client-only, core+client-ui+stateful-flow, full, allowed); F05-QA-STRICT activated.
* 2026-09-26 — QA: F05-QA-STRICT Rejected (F05-QA-STRICT-1/-2/-3); F05.STRICT-CONTENT FAIL, F05.SHARED-RUNTIME PASS; owner -> Tech Lead.
* 2026-09-26 — Tech Lead: F05-QA-STRICT reconciled (findings re-verified; own pre-QA band-rule claim corrected); contract §5.4/§6/§10/§15 amended; prd.md AC3 resynced; F05-FE3-GATE + F05-FE3-HOME activated; status Rework.

## Consumed Signals

* analysis.md decisions D1–D8 were consumed into architecture.md; reopen only affected unresolved questions.
* F06-CONTENT-PROMOTE was Tech-Lead-reconciled on 2026-09-26; its band-rule claim was later disproven (F05-QA-STRICT-1). That is delivery evidence, not a QA verdict.

## Current Rework Brief (F05-FE3 — activated 2026-09-26)

Both tasks belong to the Frontend/Mobile Developer. They are independent of each other and can be delivered in one turn. Record the evidence in a new F05-FE3 section of frontend.md.

### F05-FE3-GATE — F05-QA-STRICT-1 + F05-QA-STRICT-2

* **Symptom:** CI stays green when a Journey level breaks the difficulty curve. For example, a 21–25 level loses its frozen tile, or a 26–30 level loses its locked+frozen combination (QA QS-02/QS-03; Tech Lead re-ran L24/L27). Separately, a stray `"levels"` key in a level file silently skips every `content:check` validation of that file, so a wrong `optimalMoves` would ship and skew star thresholds.
* **Affected journey:** all 30 Journey levels — the AC3–AC6 curve, and star-rating correctness through `optimalMoves`.
* **Entry points / sources:**
  * `app/test/journey/journey_gate_support.dart` (`runJourneyManifestGate`);
  * `app/test/journey/journey_manifest_gate_test.dart` (the band test at 75-80 has an empty body);
  * `app/test/journey/journey_manifest_strict_test.dart` (synthetic cases);
  * `tools/looplet_authoring/lib/src/content_check.dart` (manifest discriminator at lines 41-50);
  * `.github/workflows/ci.yml` (Content check step);
  * `melos.yaml` (`content:check`, `content:journey`, `content:sync`).
* **Fix scope:**
  1. Extend `runJourneyManifestGate` with R1–R6 from architecture §5.4, plus manifest-entry `difficultyLabel` == asset `difficultyLabel`. Strict mode reports named violations and fails; smoke mode logs them as advisory.
  2. Replace the empty band-test body with an assertion of zero band violations on the shipped strict pack.
  3. Add synthetic negatives: one rejecting case per rule (R1…R6 plus the label mismatch), each asserting its specific violation, next to a control that passes.
  4. Make CI fail when `app/assets/journey/<lang>/` is not byte-identical to `content/journey/<lang>/`. Placement is your choice (`content:check --repo-root` or an app test); include a negative case.
  5. Apply the `content:check` recognition rule from §5.4 (path **and** shape) and add negatives:
     * a Puzzle plus a stray `levels` key is still validated (a wrong `optimalMoves` is rejected);
     * a malformed file at the manifest path fails;
     * the real manifest is still recognized (existing regression test).
  6. In frontend.md, add an erratum for the F06-CONTENT-PROMOTE lines that claimed band-rule coverage (around 302, 320 and 340), and list the rule → check → negative mapping.
  7. Comment-only fixes while you are in these files: `app/pubspec.yaml:60` ("Interim — 5 files"), `melos.yaml:47` ("no-op until F06-CONTENT"), `journey_content.dart:155` (interim note) and `journey_gate_support.dart:38` ("[PENDING — F06-CONTENT]").
* **Non-goals:**
  * No content edits: the 30 levels and their checksums stay unchanged, and the `tdDegree` note is not addressed.
  * No new gate rule for levels 1–3 `optimalMoves == 2`.
  * No CI restructuring beyond what the mirror check needs.
  * No new dependency.
* **Exit criteria:**
  * Each rule's negative case makes the gate fail for that rule, and the real pack passes.
  * `content:check` is green on real content, and its negatives are green.
  * `flutter analyze`, `dart format --set-exit-if-changed` (app + tools), `flutter test` and the package `dart test` runs are all green.
  * frontend.md is updated.

### F05-FE3-HOME — F05-QA-STRICT-3

* **Symptom:**
  * After starting a level and pressing back, the home shows "Seviye N" with no "· sürüyor", no cyan node and no pulse until the app restarts.
  * After "Yeniden" on a completed level and leaving mid-replay, the in-session DEVAM ET opens the next frontier level instead. The replay's saved state is then silently overwritten, because a fresh session persists on open (`play_session_controller.dart:107-109`).
  * After a restart, the same persisted state shows "Seviye K · sürüyor" and resumes the replay (QA rt14/rt15).
* **Affected journey:** the home ↔ `/play` round trip — CONTINUE → play → back; win panel `Yeniden` → back; `SONRAKİ` → back.
* **Entry points / sources:**
  * `app/lib/journey/journey_progress.dart:83-94` (`journeyProgressModelProvider`);
  * `app/lib/persistence/repositories/active_session_repo.dart` — the snapshot is the single `kv_rows` row `active_session`, and there is no watch yet;
  * `app/lib/home_screen.dart` (consumer; no logic change expected).
* **Fix scope:**
  1. Re-derive the model when the active-session row changes as well as when `journey_progress` changes (§6 as amended). One option: an `ActiveSessionRepo` watch over that `kv_rows` row, combined with `JourneyProgressRepo.watch`, with no new package.
     * Decode the row exactly as `read()` does.
     * Make sure a corrupt row's `clear()` cannot trigger a re-entrant loop.
  2. Add widget tests using the real repos, in-memory Drift and reduced motion:
     * (a) warm frontier: with the home mounted, a snapshot for level N is written → "Seviye N · sürüyor", the `Semantics` line and CONTINUE target N;
     * (b) warm replay: completed {1,2} plus a snapshot for journey-tr-02 → CONTINUE target 2, "Seviye 2 · sürüyor";
     * (c) the win path clears it: the snapshot is completed/cleared and the level marked completed → the in-progress state disappears and the target advances;
     * (d) warm == cold for the same state.
* **Non-goals:**
  * §6 semantics stay unchanged: a replay is in-progress and CONTINUE resumes it.
  * No change to the snapshot schema, persistence write timing or the F08 restore.
  * No home visual redesign (Design Adoption Phase C/D).
  * No level-select.
* **Exit criteria:**
  * The warm/cold parity tests are green.
  * The existing `journey_home_test.dart` cases are unchanged and green.
  * The full suite is green, with no `pumpAndSettle` hang.
  * frontend.md is updated; an optional ad-hoc simulator check may be recorded.
