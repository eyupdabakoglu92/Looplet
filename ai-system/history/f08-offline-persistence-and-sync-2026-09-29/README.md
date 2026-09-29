# F08 working record — 2026-09-29 (activation after Design Adoption Phase D)

* **`orchestration-before-activation.md`** — the F08 orchestration right before the Tech Lead activation of 2026-09-29, byte for byte (SHA-1 `367c52bb…`).
  * State: In Progress; owner Tech Lead; F08-LOCAL-EVIDENCE and F08-QA-FUNCTIONAL Queued, F08-DEVOPS Blocked, F08-QA-FINAL Queued; seven PENDING evidence records; F08.DEPLOY-AUTHORIZATION OPEN; the queue note of 2026-09-26 and the routing note of 2026-09-29.
  * Taken right before the activation (F08 `architecture.md` → Activation 2026-09-29), which opened F08-FE13.
* **`orchestration-before-fe13-checkpoint.md`** — the F08 orchestration right before the Tech Lead FE13 checkpoint of 2026-09-29, byte for byte (SHA-1 `4d42d6b7…`).
  * State: In Progress; owner Tech Lead; F08-FE13 and F08-LOCAL-EVIDENCE Done (the Frontend/Mobile Developer, commit beb7bfe); Delivery Review Pending; F08.STORAGE PASS; the F08-FE13 Current Brief.
  * Taken right before the checkpoint (F08 `architecture.md` → Activation 2026-09-29 → A6 / A7), which opened F08-BE6.
* **`orchestration-before-be6-checkpoint.md`** — the F08 orchestration right before the Tech Lead BE6 checkpoint of 2026-09-29, byte for byte (SHA-1 `87afd677…`).
  * State: In Progress; owner Tech Lead; F08-FE13, F08-LOCAL-EVIDENCE and F08-BE6 Done (the Backend Developer, commit c70527a); Delivery Review Pending; F08-QA-FUNCTIONAL Queued; the F08-BE6 Current Brief.
  * Taken right before the checkpoint (F08 `architecture.md` → Activation 2026-09-29 → A8), which activated F08-QA-FUNCTIONAL.
* **`orchestration-before-qa-functional-checkpoint.md`** — the F08 orchestration right before the Tech Lead checkpoint on the F08-QA-FUNCTIONAL verdict of 2026-09-29, byte for byte (SHA-1 `de601928…`).
  * State: In QA; owner Tech Lead; F08-QA-FUNCTIONAL Done with **Decision Pending** (QA, commit d882211); finding F1 in Blockers; F08.OFFLINE-JOURNEY PENDING; the F08-QA-FUNCTIONAL Current Brief.
  * Taken right before the checkpoint (F08 `architecture.md` → Activation 2026-09-29 → A9), which resolved F1 and opened F08-BE7.
* **`orchestration-before-be7-checkpoint.md`** — the F08 orchestration right before the Tech Lead BE7 checkpoint of 2026-09-29, byte for byte (SHA-1 `5e6e7504…`).
  * State: Rework; owner Tech Lead; F08-BE7 Done (the Backend Developer, commit cb96719); Delivery Review Pending; F08-QA-FUNCTIONAL-R1 Queued; F08.EMULATOR and F08.OFFLINE-JOURNEY PENDING; the F08-BE7 Current Brief.
  * Taken right before the checkpoint (F08 `architecture.md` → Activation 2026-09-29 → A10), which activated F08-QA-FUNCTIONAL-R1.
* **`orchestration-before-qa-r1-checkpoint.md`** — the F08 orchestration right before the Tech Lead checkpoint on the F08-QA-FUNCTIONAL-R1 verdict of 2026-09-29, byte for byte (SHA-1 `751190f7…`).
  * State: In QA; owner Tech Lead; F08-QA-FUNCTIONAL-R1 Done with **Runtime Validation Pending** (QA, uncommitted at the checkpoint); F1 closed; F08.EMULATOR PASS; F08.OFFLINE-JOURNEY PENDING; the F08-QA-FUNCTIONAL-R1 Current Brief.
  * Taken right before the checkpoint (F08 `architecture.md` → Activation 2026-09-29 → A11), which set F08 Blocked on the user's no-network run.
* **`orchestration-before-offline-run-intake.md`** — the F08 orchestration right before the Tech Lead intake of the user's no-network run on 2026-09-29, byte for byte (SHA-1 `da2b1880…`).
  * State: Blocked; owner Tech Lead; F08-QA-FUNCTIONAL-R2 Blocked on the user's run; F08.OFFLINE-JOURNEY PENDING; the A11 Current Brief with the user's steps.
  * Taken right before the intake (F08 `architecture.md` → Activation 2026-09-29 → A12), which activated F08-QA-FUNCTIONAL-R2.
* **`orchestration-before-functional-closure.md`** — the F08 orchestration right before the Tech Lead checkpoint on the F08-QA-FUNCTIONAL-R2 verdict of 2026-09-29, byte for byte (SHA-1 `b04358f1…`).
  * State: In QA; owner Tech Lead; F08-QA-FUNCTIONAL-R2 Done with **Functional Approved** (QA, commit 0d65c73); every functional evidence record PASS; F08-DEVOPS Blocked on F08.DEPLOY-AUTHORIZATION; the F08-QA-FUNCTIONAL-R2 Current Brief.
  * Taken right before the checkpoint (F08 `architecture.md` → Activation 2026-09-29 → A13), which closed the functional stage and set F08 Blocked on the user's release decisions (F08-DEVOPS-PREP defined, Blocked).
* **`orchestration-before-ci-push-decision.md`** — the F08 orchestration right before the Tech Lead intake of the decision F08.CI-FIRST-PUSH on 2026-09-29, byte for byte (SHA-1 `befd78a3…`).
  * State: Blocked; owner Tech Lead; functional stage closed (Functional Approved); F08-DEVOPS-PREP and F08-DEVOPS Blocked; F08.DEPLOY-AUTHORIZATION and F08.CI-FIRST-PUSH OPEN.
  * Taken right before the decision intake (F08 `architecture.md` → Activation 2026-09-29 → A14), which resolved F08.CI-FIRST-PUSH.
* **`orchestration-before-ci-incident.md`** — the F08 orchestration right before the Tech Lead intake of the CI-failure incident on 2026-09-29, byte for byte (SHA-1 `a36c8e3b…`).
  * State: Blocked; owner Tech Lead; F08.CI-FIRST-PUSH RESOLVED (A14); F08.DEPLOY-AUTHORIZATION OPEN; F08-DEVOPS-PREP (a)–(f) and F08-DEVOPS Blocked.
  * Taken right before the incident intake (F08 `architecture.md` → Activation 2026-09-29 → A15), which confirmed the three CI root causes and refined the deploy gate's options.
* **`orchestration-before-deploy-decision.md`** — the F08 orchestration right before the Tech Lead intake of the decision F08.DEPLOY-AUTHORIZATION — B on 2026-09-29, byte for byte (SHA-1 `35008bc2…`).
  * State: Blocked; owner Tech Lead; F08.DEPLOY-AUTHORIZATION OPEN (options A / B / C, A15); F08-DEVOPS-PREP and F08-DEVOPS Blocked; the A15 Current Brief.
  * Taken right before the decision intake (F08 `architecture.md` → Activation 2026-09-29 → A16), which activated F08-DEVOPS-PREP.
