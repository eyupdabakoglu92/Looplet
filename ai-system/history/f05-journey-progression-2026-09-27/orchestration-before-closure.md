# F05 — journey-progression: Orchestration

## Feature ID

F05

## Current Status

In QA

## Current Owner

Tech Lead

## Next Role

Tech Lead

## Active Task Ledger

- [x] Task ID: F06-CONTENT-PROMOTE | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-13 — promoted the 30 accepted Journey levels from `tools/looplet_authoring/drafts/journey/tr/` to `content/journey/tr/` (real `Puzzle` artifacts, `contentVersion` "2026.09-v1", untouched grid/target/locked/frozen/optimalMoves data) plus a real `mode:"strict"` manifest (30 contiguous entries, sha256 checksums); `content:sync`'s existing rsync mirrored it into `app/assets/journey/tr/`, replacing the 5 interim smoke files. Found and fixed a real toolchain bug in `tools/looplet_authoring/lib/src/content_check.dart` (a Journey manifest, `{levels: [...]}` shape, was force-parsed as a `Puzzle` and rejected — had never been exercised before since no Journey manifest previously lived under `content/`); added a `levels`-key skip branch + a regression test. `flutter test` 181/181 (unchanged — no test needed a content-specific change), `looplet_authoring` `dart test` 20/20 (+1 regression test), `content:check` → OK, F05's own strict manifest gate 4/4 green for the first time against real content, `flutter build ios --release --no-codesign` green (54.7 MB, unchanged size). [CORRECTED 2026-09-26, Tech Lead: the "4/4" contains no band-rule assertion (empty test body) and the `levels`-key skip is bypassable — F05-QA-STRICT-1/-2; the content promotion itself stands] | Depends On: -
- [x] Task ID: F05-QA-STRICT | Assigned Role: QA | Status: Done | Summary: DONE 2026-09-26 — verdict Rejected (qa.md § F05-QA-STRICT; final, client-only, HEAD 6fb2d23). The real pack itself is clean: independent probe 30/30 levels, 0 violations of §5.4 R1–R6 + the 2026-09-13 decision, content/ and app/assets/ identical (git tree 057f242b); full campaign 1..30 → terminal → replay L1 proven against the real bundle (real level 30 won by a real drag → SONRAKİ → TAMAMLANDI); AC7 resume across a real process kill PASS on iPhone 16; N1 moot; regression green (analyze, format, app 314/314, F05 73/73, packages 197/197, F03 device 13/13). Blocking: F05-QA-STRICT-1 (High) — the strict build gate enforces no structural band rule: F05's band test has an empty body and the gate never reads band fields (R1/R4/R5/R6 violations → passed: true); content:check rejects R1/R6 explicitly, R2/R3 only incidentally, R4/R5 not at all — the "4/4 incl. the structural band-rule case" delivery and reconcile claim is misattributed. F05-QA-STRICT-3 (Medium, AC7) — the home read-model never re-reads the active-session snapshot in-session: no in-progress state after backing out of a level, and mid-replay of a completed level makes in-session CONTINUE target the frontier (Seviye 3) while the same persisted state after relaunch targets the replay (Seviye 2 · sürüyor); reproduced at runtime and in a widget probe. Same rework: F05-QA-STRICT-2 (Medium) — a stray "levels" key makes content:check skip all puzzle validation (a wrong optimalMoves passes). Also: the brief's "F05-FE2 fingerprint-valid" was inaccurate (8 files changed since 345147e) — QA re-ran the affected suites | Depends On: F06-CONTENT-PROMOTE
- [x] Task ID: F05-FE3-GATE | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-27 (frontend.md § F05-FE3) — runJourneyManifestGate enforces §5.4 R1–R6 + manifest↔asset LABEL (strict → named violations, smoke → advisories, bandChecks non-vacuity counter); the real-bundle band test asserts strict, 0 violations, 85 checks; one rejecting synthetic case per rule (R1 L2, R2 L7, R3 L17, R4 L22, R5 L28/L27, R6 L28, LABEL L20) each asserting exactly that violation; QA's real-content probe now rejects R4 L22 / R5 L28 / R1 L02 / R6 L28 (was passed: true); byte-mirror check content/journey ↔ app/assets/journey as an app test (in melos run test/CI) with negatives; content:check recognizes a Journey manifest only by path + shape — the L05 optimalMoves-7 + "levels": [] bypass now exits 1, real content check: OK; frontend.md erratum for the F06-CONTENT-PROMOTE claims; stale interim comments fixed. looplet_authoring 25/25 | Depends On: F05-QA-STRICT
- [x] Task ID: F05-FE3-HOME | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: DELIVERED 2026-09-27 (frontend.md § F05-FE3) — ActiveSessionRepo.watch() (shares read()'s corrupt-row discard, no loop) + journeyProgressModelProvider combines journey_progress and the active-session row live (no new package; subscriptions cancelled on dispose; §6 semantics unchanged). 5 warm-path widget tests (frontier, replay, win clears, warm == cold, corrupt) — 3 of them fail against the old provider, proving they catch F05-QA-STRICT-3; 2 repo watch tests. Widget tests mounting HomeScreen use a sync-closing Drift test DB (drift's documented option; production unaffected). Runtime on iPhone 16 sim: warm frontier and warm replay show "Seviye 1 · sürüyor", CONTINUE resumes the replay exactly, identical after kill/relaunch. Regression: flutter analyze clean, flutter test 336/336, packages 202/202, format clean, F03 device suite 13/13 | Depends On: F05-QA-STRICT
- [x] Task ID: F05-QA-STRICT2 | Assigned Role: QA | Status: Done | Summary: DONE 2026-09-27 — verdict Approved with Notes (qa.md § F05-QA-STRICT2; final, client-only, HEAD 015e50e). F05-QA-STRICT-1/-2/-3 independently closed: gate read line by line vs §5.4; own real-content probe 21/21 on band boundaries (14 violations each rejected with its one named rule, 3 positive boundaries not firing, multi-break, smoke advisory, strict-29) with pairs different from the delivery's and the Tech Lead's; the real mirror test fails on a byte drift and on a bundle-only file (dotfile ignored); 4 new content:check negatives rejected, real content check: OK, fresh content probe 30/30 with 0 violations. Home: delivered suites 27/27; own adversarial edge probe 7/7 (foreign/completed/daily snapshots ignored, level switch, far-behind replay, latest-write-wins); real-bundle campaign re-run 7/7 with warm == cold. Device: F03 suite 13/13 and a fresh-install journey on iPhone 16 — warm frontier "Seviye 1 · sürüyor", AC7 kill/relaunch resume (NASLA, 1 HAMLE → 2 = optimal), the win clears the in-progress state, warm replay "Seviye 2 · sürüyor" with CONTINUE resuming the replay (MBADE, 1 HAMLE), identical after relaunch. Regression: analyze clean, format clean, app 336/336, packages 202/202. Non-blocking: N1 — with 30/30 complete, an in-progress replay is not surfaced (TEKRAR OYNA → L1 would overwrite the replay save; AC7/AC9 overlap, pre-existing), N2 — duplicated band table, N3 — mirror test relies on the app/ cwd, N4 — carried notes | Depends On: F05-FE3-GATE, F05-FE3-HOME

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

Approved with Notes

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
  * Result: PASS
  * Provenance / Note: 2026-09-27 Tech Lead, HEAD 8c90e21 (clean). Read the gate: `_evaluateBandRules` maps R1 (1–3 columns off), R2 (4–10 columns on), R3 (16–20 locked), R4 (21–25 frozen), R5 (26–30 both), R6 (bands = `_expectedBands`) and LABEL exactly as architecture §5.4; strict → violations, smoke → advisories; the real-bundle test asserts strict, 0 violations, 0 advisories, `bandChecks == 85` and the mirror. Own negative runs with rule/level pairs neither QA nor the delivery used, real content with recomputed checksums: R2 L05, R3 L18, R5 L30, R6 L03, LABEL L10 → each rejected with exactly its named violation; the same R3 break in smoke mode → advisory only; control → pass, 85 checks. Mirror: one appended byte in app/assets/journey/tr/journey-tr-07.json → the gate suite fails ("journey-tr-07.json: bytes differ" + checksum drift), file restored. content:check on a content copy: L12 optimalMoves 8 + `"levels": []` → exit 1 (8 != fresh solve 5); `mode:"loose"` at the real manifest path → exit 1 "malformed Journey manifest"; a manifest copy at a non-manifest path → exit 1 (validated as a Puzzle). Real content: `check: OK`. The 2026-09-26 correction note (the original "4/4 incl. band-rule case" claim was false) is kept in history/f05-journey-progression-2026-09-26/.

- Evidence ID: F05.STRICT-CONTENT
  * Scenario: QA's own independent acceptance of the real 30-level strict pack, structural band invariants and now-reachable full-campaign/terminal behavior
  * Required Class: automated functional
  * Target / Environment: Current content/journey/tr, app bundle, CLI validator and Journey tests
  * Owner Role: QA
  * Prerequisite / External Decision: met 2026-09-27 — F05-FE3-GATE delivered and Tech Lead-reconciled (F06.CONTENT-PROMOTE-RECONCILE PASS)
  * Re-evaluation Trigger: F05-QA-STRICT2 (activated 2026-09-27)
  * Blocks: F05 final acceptance
  * Result: PASS
  * Provenance / Note: 2026-09-27 QA, HEAD 015e50e (clean), qa.md § F05-QA-STRICT2. Content: fresh probe 30/30, 0 violations in both trees (tree 057f242); `content:check` OK (Q2-04); Gate: read against §5.4 (Q2-05). Own real-content probe 21/21 on band boundaries, with pairs different from the delivery's and the Tech Lead's (Q2-06): each violation rejected with its one named rule; the positive boundaries did not fire; multi-break, smoke advisory and strict-29 all correct; Mirror: the real test fails on a byte drift and on a bundle-only file (Q2-07); `content:check`: 4 new negatives rejected (Q2-08); Full campaign → terminal against the real bundle: 7/7 (Q2-11); Previous FAIL (2026-09-26, QS-02/QS-03) is closed.

- Evidence ID: F05.HOME-LIVE-STATE
  * Scenario: Warm-path home read-model (architecture.md §6/§10/§15, amended 2026-09-26). The home stays mounted while `/play` writes, changes or clears the active-session snapshot — frontier level started, completed level replayed, level won. On return to `/` the home must show the same in-progress caption, `Semantics` and CONTINUE target as the cold (relaunch) derivation for the same persisted state.
  * Required Class: automated functional
  * Target / Environment: app widget tests with the real repos and in-memory Drift; an optional ad-hoc iPhone 16 simulator spot-check (§15)
  * Owner Role: QA
  * Prerequisite / External Decision: met 2026-09-27 — F05-FE3-HOME delivered and Tech Lead-reconciled
  * Re-evaluation Trigger: F05-QA-STRICT2 (activated 2026-09-27)
  * Blocks: F05 final acceptance
  * Result: PASS
  * Provenance / Note: 2026-09-27 QA, HEAD 015e50e, qa.md § F05-QA-STRICT2. Delivered home and repo suites: 27/27 (Q2-09); Own adversarial edge probe: 7/7 (Q2-10). Foreign, completed and Daily snapshots are ignored; a level switch is followed; a far-behind replay and its clear are reflected; the latest write wins; Real-bundle campaign re-run: D1/D2 warm `[Seviye 2 · sürüyor]` == cold (Q2-11); Runtime on the iPhone 16 simulator (Q2-13): warm frontier "Seviye 1 · sürüyor" (q02); the win clears the in-progress state (q07); warm replay "Seviye 2 · sürüyor" (q11); CONTINUE resumes the replay — MBADE, 1 HAMLE (q12); identical after kill/relaunch (q14); Previous FAIL (2026-09-26, QS-12) is closed; Non-blocking N1: with 30/30 complete, the terminal state does not surface an in-progress replay (see qa.md).

- Evidence ID: F05.SHARED-RUNTIME
  * Scenario: Inherited play/navigation/lifecycle/resume evidence from F03 and local F08 persistence; offline Journey and failure preservation where applicable
  * Required Class: runtime
  * Target / Environment: F03.RUNTIME-MATRIX / VISUAL / ROTATION / BACK; F08.LOCAL-RESUME / OFFLINE-JOURNEY / STORAGE
  * Owner Role: QA
  * Prerequisite / External Decision: Review/reuse proof for the actual shared path; local simulator and isolated storage are independent of paid Firebase deployment
  * Re-evaluation Trigger: F05-QA-STRICT2 — `ActiveSessionRepo` (the resume read path) changed in F05-FE3-HOME
  * Blocks: F05 final acceptance
  * Result: PASS
  * Provenance / Note: 2026-09-27 QA (qa.md § F05-QA-STRICT2), re-verified on HEAD 015e50e: F03 device suite 13/13 on iPhone 16 (Q2-12); AC7 mid-level kill/relaunch on a fresh install: "NASLA", 1 HAMLE restored, and the second move scored "2 SEN = 2 OPTİMAL" (Q2-13 q03–q06); the refactored `ActiveSessionRepo.read()` also passes the corrupt-row and watch tests (Q2-09); Offline and storage-failure device branches remain F08's (not an F05 gate, §13/§15); History: re-opened on 2026-09-27 because its own validity condition no longer held. The 2026-09-26 PASS (QA: F03 51497dd reuse + device suite 13/13 + kill/relaunch resume on iPhone 16, qa.md QS-08/QS-10/QS-11) was valid "unless the persistence or restore code changes". F05-FE3-HOME refactored `ActiveSessionRepo.read()` into a shared `_decode` and added `watch()`. The delivery's own F03 device run (13/13) is delivery evidence; QA re-verifies. The offline and storage-failure device branches stay F08's (F08.OFFLINE-JOURNEY, F08.STORAGE) and do not gate F05 (architecture §13/§15).

## Open Decision Gates

None

## Blockers

None

## Next Action

Run Tech Lead to reconcile F05-QA-STRICT2 (qa.md § F05-QA-STRICT2): QA Result Approved with Notes.
* All three QA evidence records are PASS; Blockers None; no open decision gate.
* F05 is ready for the closure review.
* Non-blocking N1 needs a Tech Lead call: with 30/30 complete, the terminal state does not surface an in-progress replay (AC7/AC9 overlap, pre-existing).
* N2–N4 are informational.

## Last Decision

2026-09-27 (F05-FE3 reconciliation) — Tech Lead reconciled F05-FE3-GATE and F05-FE3-HOME. Following workflow-follow-ups "Required Migration Follow-through", it read every check and ran its own negative cases rather than relying on the green suite.

* **Gate:** the rule mapping matches §5.4 line for line.
* **Own negatives (rule/level pairs not used before):**
  * the band rules on real content were rejected with exactly their named violation;
  * the smoke advisory behaved as specified;
  * a one-byte bundle drift failed the suite;
  * three `content:check` negatives were rejected, and real content still passes.
* **Home:** the 5 warm-path tests pass on the new provider. 3 of them fail with the old provider swapped back in, so they do catch F05-QA-STRICT-3.
* **Regression (own run):** `flutter analyze` clean, app 336/336, authoring 25/25, format 0 changed. The content tree is unchanged (057f242).
* **Test-infra change accepted:** widget tests that mount HomeScreen use a sync-closing Drift connection. The new provider correctly cancels its subscriptions on dispose, and drift's delayed-close timer is otherwise reported as pending by flutter_test. This is drift's documented option and is test-only.
* **Non-blocking observation:** the label-band table now exists twice — `journeyLabelBand` in the F05 gate (the §5.4 authority) and `_expectedBands` in content:check (defence in depth). A curve change must update both.
* **Outcome:**
  * Delivery Review = Accepted; F06.CONTENT-PROMOTE-RECONCILE = PASS.
  * F05.STRICT-CONTENT and F05.HOME-LIVE-STATE → PENDING, awaiting re-verification.
  * F05.SHARED-RUNTIME → PENDING: its validity condition (persistence code unchanged) no longer holds.
* **QA plan:** final, client-only, full, allowed; modules core + client-ui + stateful-flow.
  * `content` was considered, but qa-preflight failed it: the module requires `content-design.md`, which F05 has no authority for (its content came through F06 drafts + REVIEW.md + the user's as-is acceptance).
  * The validator positive/negative-fixture check is therefore required explicitly in the brief, under core — as in F05-QA-STRICT.
  * F05-QA-STRICT2 is activated; qa-preflight PASS.

Earlier decisions are in history/f05-journey-progression-2026-09-26/ and history/f05-journey-progression-2026-09-27/.

## Last Update

* Updated By: QA
* Timestamp: 2026-09-27
* Summary: F05-QA-STRICT2 done — QA Result Approved with Notes. F05.STRICT-CONTENT, F05.HOME-LIVE-STATE and F05.SHARED-RUNTIME → PASS. Non-blocking N1–N4. Owner → Tech Lead.

## Context & Follow-ups

* **Content is unchanged:** the 30 real levels are clean (QA QS-01) and untouched by the rework (content tree 057f242).
* **Carried non-blocking notes:**
  * 11–15 `tdDegree = 0` — accepted as-is content; noted for PO visibility.
  * A replayed completed level renders as in-progress on the ring — this is by §6 design.
  * The label-band table exists twice (see Last Decision).
* **Tracked elsewhere:**
  * Offline and storage-failure device branches: workflow-follow-ups.md SHARED-PERSISTENCE-PROOF and F08.
  * First-app-distribution: workflow-follow-ups.md; not an F05 gate.
* **Incident 2026-09-26 ("the app still shows the old design"):** the Design Adoption Route (Phase C audit, then Phase D screen by screen) takes the next slot after F05 closes, ahead of F08. F05's home and tutorial are Phase D surfaces.

## History & Evidence References

* [Original orchestration](../../history/core-sync-2026-09-18/features/f05-journey-progression/orchestration.md) — historical only, not a run queue.
* [Snapshot at the F05-QA-STRICT verdict](../../history/f05-journey-progression-2026-09-26/orchestration-at-qa-strict-verdict.md) and [snapshot at the F05-FE3 delivery](../../history/f05-journey-progression-2026-09-27/orchestration-at-fe3-delivery.md) (the full rework brief).
* [QA report](qa.md), [delivery report](frontend.md) (§ F05-FE3) and [contract](architecture.md) (amended 2026-09-26).
* [Portfolio follow-ups](../../workflow-follow-ups.md) and [migration record](../../history/core-sync-2026-09-18/README.md).
* Canonical execution: role-execution-contract.md; historical next-command text does not authorize execution.

## Change Log

* 2026-09-18 — migrated state; see the immutable pre-migration snapshot for all earlier tasks, decisions and evidence.
* 2026-09-20 — Tech Lead: QA sequencing set to F03 first; F05 routing note only.
* 2026-09-20 — Tech Lead: F03 QA Rejected; F05 stays queued behind F03 rework + re-QA (rework-control rule).
* 2026-09-21 — Tech Lead: F03 Done; lock released; F05 Next Action re-pointed (delivery reconciliation, then QA-STRICT).
* 2026-09-26 — Tech Lead: F06-CONTENT-PROMOTE reconciled; Delivery Review = Accepted; QA plan locked; F05-QA-STRICT activated.
* 2026-09-26 — QA: F05-QA-STRICT Rejected (F05-QA-STRICT-1/-2/-3); F05.STRICT-CONTENT FAIL, F05.SHARED-RUNTIME PASS; owner -> Tech Lead.
* 2026-09-26 — Tech Lead: F05-QA-STRICT reconciled (findings re-verified; own pre-QA band-rule claim corrected); contract §5.4/§6/§10/§15 amended; prd.md AC3 resynced; F05-FE3-GATE + F05-FE3-HOME activated; status Rework.
* 2026-09-26 — Tech Lead: incident triage ("the app still shows the old design") — Continue Current Flow; design adoption is scheduled right after F05 closes, ahead of F08.
* 2026-09-27 — Frontend/Mobile Developer: F05-FE3-GATE + F05-FE3-HOME delivered; Delivery Review = Pending; owner → Tech Lead.
* 2026-09-27 — Tech Lead: F05-FE3 reconciled (own negative runs); Delivery Review = Accepted; evidence re-opened for re-verification; QA plan locked (core+client-ui+stateful-flow; the content module was rejected by qa-preflight — no content-design.md); F05-QA-STRICT2 activated; status In QA.
* 2026-09-27 — QA: F05-QA-STRICT2 Approved with Notes (N1–N4 non-blocking); the three QA evidence records → PASS; owner → Tech Lead.

## Consumed Signals

* analysis.md decisions D1–D8 were consumed into architecture.md; reopen only affected unresolved questions.
* F06-CONTENT-PROMOTE was Tech-Lead-reconciled on 2026-09-26; its band-rule claim was later disproven (F05-QA-STRICT-1). That is delivery evidence, not a QA verdict.

## Current QA Brief (F05-QA-STRICT2 — activated 2026-09-27)

Final-stage re-QA after the F05-FE3 rework. Your verdict is independent: the Tech Lead's own negative runs (F06.CONTENT-PROMOTE-RECONCILE) are a starting point, not a substitute.

**What changed since F05-QA-STRICT (commit 8c90e21; details and evidence in frontend.md § F05-FE3):**
* Gate and tooling:
  * `app/test/journey/journey_gate_support.dart` — band rules, advisories, `bandChecks`, `compareJourneyMirror`.
  * `journey_manifest_gate_test.dart` and `journey_manifest_strict_test.dart`.
  * `tools/looplet_authoring/lib/src/content_check.dart` and its test — path + shape manifest recognition.
* App code:
  * `app/lib/journey/journey_progress.dart` — the provider is now live on both sources.
  * `app/lib/persistence/repositories/active_session_repo.dart` — `watch()`; `read()` refactored into a shared `_decode`.
* Test infrastructure: `app/test/support/widget_test_database.dart`, used by the three tests that mount HomeScreen.
* Unchanged: content, `play_session_controller.dart`, the F08 schema.

**Verify:**
1. **F05-QA-STRICT-1/-2 — core (gate integrity; the validator must enforce each claimed rule with positive and negative fixtures).**
   * Read each check in `_evaluateBandRules` and map rule → check → negative case for R1–R6 + LABEL. Use the synthetic per-rule cases, plus your own real-content mutations with recomputed checksums — choose rule/level pairs different from the delivery's and the Tech Lead's.
   * Confirm the smoke-mode advisory behaviour and the `bandChecks == 85` non-vacuity assertion on the shipped pack.
   * Mirror check: exercise the real test with a temporary drift, then restore the file.
   * `content:check`: the former `levels`-key bypass and malformed or misplaced manifests must be rejected, and real content must still pass.
2. **F05-QA-STRICT-3 — stateful-flow + client-ui (home live state).**
   * Widget tests plus runtime on the iPhone 16 simulator:
     * warm frontier — start a level, go back → "· sürüyor" immediately;
     * warm replay — `Yeniden` → back → CONTINUE resumes the replay, and its save is not overwritten;
     * the win clears the in-progress state;
     * warm == cold after a kill/relaunch;
     * a corrupt snapshot falls back without looping.
   * Consider an adversarial check that the tests are not vacuous, e.g. against the pre-FE3 provider.
3. **Shared runtime (F05.SHARED-RUNTIME).** `ActiveSessionRepo.read()` changed, so re-run the F03 device suite and an AC7 mid-level kill/relaunch resume on the device.
4. **Full regression:** `flutter analyze`, `dart format --set-exit-if-changed app tools/looplet_authoring`, `flutter test` (the delivery reports 336), package `dart test` (202), and `content:check` on real content.
5. **Evidence reuse — fingerprint first.**
   * Reusable:
     * QS-01 (content probe) — the content tree 057f242 is unchanged;
     * QS-09 A/B (resolver, `nextJourneyLevel`, model) — those files are unchanged.
   * Must be re-run: QS-09 C/D and QS-10..QS-12 — they touch the home provider or persistence.
   * Test-DB note: any scratch probe that mounts HomeScreen must use a sync-closing Drift connection (`widgetTestDatabase()` or `DatabaseConnection(..., closeStreamsSynchronously: true)`); otherwise flutter_test reports a pending drift timer and `db.close()` hangs. The delivery explains why in frontend.md § F05-FE3 § 10.
6. **Carried notes** (tdDegree, replay ring rendering, duplicated label-band table) are non-blocking unless you find a contract violation.

No visual scope: the F05 home stays on the legacy look until Design Adoption Phase D. Record commands, targets, results and provenance; the verdict returns to the Tech Lead.
