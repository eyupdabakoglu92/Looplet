# F05 working record — 2026-09-29 (Design Adoption Phase D3)

* **`orchestration-before-phase-d3.md`** — the terminal orchestration of F05 at its closure of 2026-09-27 (with the 2026-09-28 C-3 wording resync), byte for byte (SHA-1 `c7b7dfd3…`).
  * State: Done; final QA F05-QA-STRICT2 Approved with Notes; the full evidence records (F06.CONTENT-PROMOTE-RECONCILE, F05.STRICT-CONTENT, F05.HOME-LIVE-STATE, F05.SHARED-RUNTIME) and the change log.
  * Taken right before the Tech Lead reopened F05 on 2026-09-29 as Design Adoption Phase D3 (Home + app shell, `new-surface`, contract `architecture.md` §18).
* **`orchestration-at-po-revision.md`** — the F05 orchestration at the D3 activation (2026-09-29), byte for byte (SHA-1 `f9a6f192…`).
  * State: Blocked on the Product Owner revision of the N1 precedence; the decision F05.D3-N1-REPLAY-PRECEDENCE RESOLVED (option A); F05-UI-D3, F05-FE-D3 and F05-QA-D3 Queued; the D3 activation decision (Last Decision).
  * Taken right before the Tech Lead's resync of PO-REV-2026-09-29-F05-CONTINUE, which resynced F05 `prd.md` AC7 / AC9, made `architecture.md` §18.3 (2) effective, cleared the blocker and opened F05-UI-D3.
* **`ui-design-before-phase-d3.md`** — the whole F05 `ui-design.md` before D3 (the F05-UI Direction A handoff of 2026-09-08: the 30-tick amber ring home, the terminal variant, the column micro-tutorial overlay — superseded by F03 D1 — and the `CompletionPanel` weighting — superseded by F03 D2), byte for byte (SHA-1 `f2c133d8…`). Moved by the UI Designer on 2026-09-29, right before `ui-design.md` was rewritten for F05-UI-D3.
* **`orchestration-at-ui-d3-delivery.md`** — the F05 orchestration right after the UI Designer delivered F05-UI-D3 (2026-09-29), byte for byte (SHA-1 `5ebb6856…`).
  * State: Rework; owner Tech Lead (visual-gate checkpoint); F05-UI-D3 Done, F05-FE-D3 and F05-QA-D3 Queued; F05.D3-HANDOFF PASS; Delivery Review Pending; Visual Quality Gate Pending; the F05-UI-D3 Current Brief.
  * Taken right before the Tech Lead's D3 visual-gate checkpoint (F05 `architecture.md` §18.7), which accepted the handoff, set the gate to Ready for Implementation and opened F05-FE-D3.
* **`orchestration-at-fe-d3-delivery.md`** — the F05 orchestration right after the Frontend/Mobile Developer delivered F05-FE-D3 (2026-09-29), byte for byte (copied with `cp -p` and `cmp`-checked).
  * State: Rework; owner Tech Lead (implementation checkpoint); F05-UI-D3 and F05-FE-D3 Done, F05-QA-D3 Queued; F05.D3-PARITY PASS, F05.D3-RELEASE-ERROR-CAPTURE PENDING; Delivery Review Pending; gate Ready for Implementation; the F05-FE-D3 Current Brief; the §18.7 visual-gate Last Decision.
  * Taken right before the Tech Lead's D3 implementation checkpoint (F05 `architecture.md` §18.8). The checkpoint accepted the delivery, set the gate to Ready for QA and opened F05-QA-D3.
* **`frontend-before-phase-d3.md`** — the whole F05 `frontend.md` before D3 (the F05-FE / F05-FE3 delivery reports, 2026-09-08 … 2026-09-27), byte for byte (SHA-1 `d32a5ad0…`). Moved by the Frontend/Mobile Developer on 2026-09-29, right before `frontend.md` was rewritten for F05-FE-D3.
