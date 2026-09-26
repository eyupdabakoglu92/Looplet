# System State — LOOPLET

Last Updated: 2026-09-27

## Platform Initialized

Yes. Existing Flutter/Dart client, pure-Dart packages, Drift persistence and Firebase authority are retained.

## Environment Status

Core workflow tooling requires Node.js 18+. Application/device/emulator environment was not freshly certified during this document/tooling migration. Old build, boot and CI results remain dated evidence in the original reports, not new PASS claims.

## Technical Authority

project-authority/platform.md and each feature's architecture.md — unchanged.

## Setup Authority

project-authority/setup-manifest.md — unchanged.

## Release Authority

project-authority/release.md — unchanged; explicit release approval remains required.

## Product Authority

product/product-prd.md — unchanged. The user's recorded content decisions are retained; no new product criterion was invented.

## Source of Truth

feature-board.md for portfolio; features/*/orchestration.md for execution; role-execution-contract.md for core workflow rules.

## Active Feature

F05

## Active Orchestration Path

features/f05-journey-progression/orchestration.md

## Current Phase

F05 journey-progression — final-stage re-QA (F05-QA-STRICT2) after the F05-FE3 rework

## Current Role

QA

## Current Reason

F05-QA-STRICT (2026-09-26) rejected F05's final QA on three defects:
* the strict gate enforced no band rule;
* `content:check` had a `levels`-key bypass;
* the home read-model was stale within a session (AC7 on the replay path).

The F05-FE3 rework (2026-09-27) fixed all three.

**Tech Lead reconciliation (2026-09-27):** the Tech Lead did not rely on the green suite. It read every gate check and ran its own negative cases on real content, using rule/level pairs not used before; the one-byte bundle drift test failed as expected; the new home tests fail against the old provider. `flutter analyze` is clean and the app suite is 336/336.

**Evidence:** the QA evidence records are re-opened as PENDING. F05.SHARED-RUNTIME is re-opened too, because `ActiveSessionRepo` — the resume read path — changed.

## Last Completed Action

Tech Lead reconciled F05-FE3 on 2026-09-27:
* Delivery Review = Accepted;
* F06.CONTENT-PROMOTE-RECONCILE = PASS;
* F05.STRICT-CONTENT, F05.HOME-LIVE-STATE and F05.SHARED-RUNTIME set to PENDING for re-verification;
* QA plan locked — final, client-only, core + client-ui + stateful-flow, full, allowed. The `content` module was dropped: qa-preflight failed it because there is no `content-design.md`. The validator positive/negative-fixture check is required in the brief instead. Preflight PASS;
* F05-QA-STRICT2 activated.

## Next Expected Action

Run QA on F05-QA-STRICT2 (Current QA Brief in the F05 orchestration):
* independently verify the three closures — the gate rule → check → negative mapping, the mirror, the `content:check` recognition, and the home warm == cold at runtime including the replay path;
* re-verify the shared runtime (F03 device suite + AC7 kill/relaunch);
* run full regression.

The verdict returns to the Tech Lead.

After F05 closes, the Design Adoption Route takes the next slot:
1. Phase C — UI Designer + Tech Lead audit of the F03/F04/F05 screens against the selected renders.
2. Phase D — the screens are redesigned one at a time, each through independent visual QA.

F08 local evidence follows the design adoption (incident 2026-09-26).

## Portfolio Summary

* F01, F02, F04, F06: historical scoped Done retained.
* F03: Done — final QA Approved with Notes (2026-09-21); Visual Scope none covered behaviour/accessibility only; visual surface pending the Design Adoption Route.
* F00: Done (2026-09-26) — cross-cutting Design Foundation track, Visual Scope design-system; Foundation Selected (Direction C, 2026-09-21); QA-01/02/03/04 all fixed and independently confirmed, 90/100; Visual Quality Gate Passed via a user-resolved scoped one-time exception (F00.VISUAL-93-THRESHOLD option C, not a rubric change). No shipped screen uses the new design yet (by scope). Design Adoption Route Phase C is scheduled for right after F05 closes (incident 2026-09-26).
* F05: In QA — the active feature. F05-QA-STRICT was Rejected on 2026-09-26. The F05-FE3 rework was delivered and Tech Lead-reconciled on 2026-09-27, and the final re-QA F05-QA-STRICT2 is now active.
* F08: In Progress, queued; independent local/emulator validation pending, release task Blocked, release/final acceptance pending.
* F07, F09–F13: Not Started. Pending follow-ons are in workflow-follow-ups.md.

## Release Decision

F08.DEPLOY-AUTHORIZATION is OPEN with Blocking Scope = release. The old deferral remains effective. Local/emulator proof does not require lifting the paid-deploy hold; final QA and Done still do.

## Global Risks

* F03-QA-03 / F03-QA-04 are fixed and verified on the real target (F03 final QA); not verified: physical finger, Android, terminal 30/30 bloom under Reduce Motion at runtime.
* The Design Foundation is Selected and its design-system layer passed independent visual QA 2026-09-26 (90/100, every dimension >= 8, no fail condition) via a user-resolved scoped one-time exception — not a change to the >= 93 generic bar, which still applies to future visual work (F03/F04/F05 conformance in Phase C, and any other feature/rework) unless that feature's own decision gate says otherwise. Shipped visuals (default font, Material icons, text-only legacy ui-designs, self-scores only) still have not passed the independent Visual Quality Gate. See Design Adoption Route.
* Rotation, AC9 highlight, back/exit and won-moment regular motion passed runtime QA (rev c0cba44); live lifecycle and reduced-motion runtime remain FAIL/pending until the fixes land. Info.plist still allows landscape; the portrait lock rests on runtime behaviour (rotation PASS).
* Required device/manual evidence is not established by a widget test, build or a planned CI job.
* A green suite does not prove that a rule is enforced. F05's "band-rule case" was an empty test, and it passed a Tech Lead reconciliation because the check itself was never read (2026-09-26). Every gate claim needs its check read and its negative case run.
* Startup/resume/persistence proof is shared by consuming features; reconcile the actual scope before clearing a downstream gate.
* F08 cold-boot fix evidence exists in prior delivery/Tech Lead reports; QA must review applicable provenance, not invent an approval.
* Daily content, first distribution, Android CI and other unresolved follow-ons remain OPEN in workflow-follow-ups.md.
* No emulator/simulator QA run, billing change or deployment has been executed; the migration and this Tech Lead turn added no test PASS claims.

## Contract Version

Existing product/technical contracts retained; workflow schema updated from ai-system-core working tree.

## Pending Breaking Change

None introduced by this migration.

## Active Cross-Feature Contract Migration

None. This is workflow state normalization, not a code/schema/API migration.

## History Reference

[Original complete system-state](history/core-sync-2026-09-18/system-state.md) and [migration record](history/core-sync-2026-09-18/README.md). All pre-migration chronology and environment reports are retained.
