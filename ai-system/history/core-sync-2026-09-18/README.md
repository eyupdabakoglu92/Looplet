# Core transfer and state reconciliation — 2026-09-18

## Scope

* Source: ai-system-core uncommitted working tree, based on 1c163d3aa75c9d0230d268262567c263eb681504.
* Target pre-migration revision: 833d3dc24a0f3c70b92ce4000c03c39d678677a5.
* 33 shared core files transferred identically. No project-specific policy was added to those files.
* Core's CLAUDE.md and starter feature-board/system-state were NOT copied over the project.
* Product PRD, feature PRDs/architecture/QA/delivery reports, project authorities, app/packages/content/infra and CI are unchanged.
* No commit, deployment, billing action or product test run was performed by this migration.

## Preservation

Nine complete original live records are stored in this directory at their original relative paths. They are historical evidence, NOT executable current state. Their bytes were compared with the pre-migration git revision; SHA-256 and byte counts are in [manifest.json](manifest.json). No history/task/decision text was discarded.

The new live snapshots contain only current state and links to original reports/history. Unresolved future scope remains explicit in [workflow-follow-ups.md](../../workflow-follow-ups.md).

## State Decisions

| Scope | Before | After / reason |
| --- | --- | --- |
| F01 / F02 / F04 / F06 | Done with narrative headers and historical ledgers | Done with canonical fields. Existing scoped QA/Tech Lead acceptance retained; no new runtime approval. F06 excludes the separate Daily-content follow-on. |
| F03 | Done despite required device/manual evidence deferred in qa.md §17 | In Progress / Tech Lead; validation queue and pending proof restored. Architecture §16/§18 requires the missing class; implementation and old report preserved, no new code defect inferred. |
| F05 | Active strict-content QA; task existed in Open Tasks while Active Task Ledger held completed history | Still active; F05-QA-STRICT now in the authoritative ledger, Queued for Tech Lead review of strict-content and inherited evidence. Final result reset to None, not falsely inherited from interim-content QA. |
| F08 | In Release / parked with deploy and local evidence grouped together | In Progress / Tech Lead for independent local/emulator work; release task remains Blocked on F08.DEPLOY-AUTHORIZATION. Existing Runtime Validation Pending and Release Validation Pending retained. Final QA after release is mandatory. |
| F07 and future scope | Not Started; Daily content in a closed F06 checklist | Not Started, not activated. F07.OFFLINE-DAILY and Daily-content work remain OPEN in portfolio follow-ups. The existing F08 fake-producer/consumer split is retained, avoiding a circular dependency. |

## Generic Core Corrections Found During Transfer

These were corrected in ai-system-core first and synchronized identically:

* A decision may explicitly have Blocking Scope = release. It still blocks DevOps, final QA and closure, but does not block unrelated implementation or functional QA. Unspecified scope defaults to feature-wide; malformed scope fails validation.
* Template-catalog tests do not assume a consumer's live board is a starter, and work before a new consumer has created its board.

## Verification

* Run `node --test ai-system/tools/tests/*.test.mjs` for the product-independent regression suite.
* Run `sh ai-system/tools/workflow-state-audit.sh ai-system` for all seven migrated live orchestrations and global consistency.
* Shared-file equality and all nine original archive hashes are checked separately.
* Audit PASS means workflow consistency, not product acceptance or proof that an AI followed every instruction.
* Existing product build/test/device results were not rerun or re-certified.

## Resume

```text
Run Tech Lead
```

Reconcile the current F05 queue and shared F03/F08 evidence, then activate one appropriate QA feature or bounded evidence-preparation task. Do not skip directly to historical artifact commands, new feature activation, production deploy or Done.
