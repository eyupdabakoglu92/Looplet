# Workflow Follow-ups — LOOPLET

Last Updated: 2026-09-20

These are retained, unresolved portfolio items. They do not authorize execution by themselves and are not completed merely because their source feature's scoped delivery is Done. Tech Lead must bring the applicable item into the owning feature's ledger/authority before delivery. Original wording and history remain in history/core-sync-2026-09-18/.

## Pending Scope

| ID | State | Owner / accepting feature | Retained obligation | Trigger / evidence reference |
| --- | --- | --- | --- | --- |
| F06-CONTENT-DAILY | OPEN | Content Designer; F07 | The ~60-puzzle Daily pool plus Daily manifest, content validation and required human sign-off. Journey acceptance does not accept Daily. Generator/validator changes belong to the relevant Developer, not Content Designer. | F07 planning; F06 original Open Tasks → Content; product PRD content scope. Keep existing quantity/criteria; PO handles any revision. |
| F01-PRODUCTION-CORPUS | OPEN | Product Owner / Content Designer; consuming product scope | Production Turkish dictionary and curated target review; provisional assets are not silently certified as final corpus. | Content planning; F01 qa.md / prd.md. |
| FIRST-APP-DISTRIBUTION | DEFERRED | Tech Lead / DevOps / QA | Store/internal distribution approval, Apple/Android prerequisites and actual device-feel smoke for F04/F05. This is not permission to enable billing or publish. | Explicit user approval and project release authority. F03 mandatory proof is separately reopened now; it cannot be hidden behind this later distribution item. |
| ANDROID-CI-EVIDENCE | OPEN | DevOps / QA | Review a real Android build/check run where release policy requires it. Local inability or a configured CI job is not a PASS. | F01/F02/F06 notes and first applicable distribution/release gate. |
| SHARED-PERSISTENCE-PROOF | OPEN | Frontend/Mobile Developer / QA; F03/F04/F05/F08/F07 as applicable | Exact resume, offline paths and storage-full/write-failure preservation. Reuse valid proof but retain untested required branches. | F08.LOCAL-RESUME / OFFLINE-JOURNEY / STORAGE and F07.OFFLINE-DAILY and consuming feature acceptance. |
| CONTENT-TOOLING-TUNING | OPEN | Tech Lead / Developer / Content Designer; F07 or a scoped follow-on | Remaining solver/performance budget, difficulty weighting/frequency-source and frozen-safe follow-ons. Existing accepted Journey content is not changed by this list. | F06 qa.md/frontend.md and content brief; determine actual relevance before new tasks. |
| F10-UI-LOCALIZATION | DEFERRED | Tech Lead / UI Designer / Frontend/Mobile Developer | Shared chrome, language/settings, deferred level-select affordance and localization seams; preserve scope/priority. | Existing F03/F05 open items and F10 PRD planning. |
| F11-AUDIO-HAPTICS | DEFERRED | Frontend/Mobile Developer; F11 | Existing audio/haptics seams remain future feature work. | Feature board / product PRD. |
| F12-ANALYTICS | DEFERRED | Tech Lead / Developer; F12 | Existing event/offline-buffering/exactly-once and validation-gate obligations. | Feature board / product PRD. |
| F07.OFFLINE-DAILY | OPEN | Frontend/Mobile Developer / QA; F07 | Real Daily producer, Remote Config seam and offline pre-fetched Daily proof; fake producer is not end-user coverage. | F08 qa.md and existing F07 dependency. |
| F08-PLATFORM-ATTESTATION | DEFERRED | Tech Lead / DevOps; applicable platform release | Existing post-MVP attestation and release identity/CI-secret ownership notes; no enforcement/policy change during migration. | F08 architecture and release authority. |
| OPTIONAL-QUALITY-NOTES | OPEN / non-blocking | Relevant role when touching scope | F04 reduced-motion assertion; F05 pulse-direction cosmetic and routeLog robustness; F02 Phase-2 coverage; previously noted analyzer cleanup; app/pubspec.yaml still carries an "Interim — 5 files" comment and melos `content:sync` says "no-op until F06-CONTENT" although the bundle now holds the 30-level pack (comment-only, Frontend/Mobile Developer on next touch). Do not invent blockers or claim completion. | Source qa.md reports and archived orchestrations. |

## Required Migration Follow-through

* F03's missing mandatory runtime/device proof is in its active Pending Evidence; it is not merely a non-blocking portfolio note.
* F05-QA-STRICT remains queued. Full invariant-to-check coverage must be verified; no earlier assertion that a particular gate enforces a rule is accepted without inspecting the real check.
* F08's release-only decision is kept OPEN. Local/emulator work is independent; deployment and final acceptance remain gated.
* No new requirement, release permission, feature activation, implementation defect or historical test result is created by this migration.
