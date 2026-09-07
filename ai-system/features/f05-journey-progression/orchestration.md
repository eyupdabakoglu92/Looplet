# F05 — journey-progression: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In Progress — analysis delivered 2026-09-07; awaiting Tech Lead DURUM 3 (contract lock).** Skeleton (`prd.md` AC1–AC14 + an initial `architecture.md` contract brief — NOT LOCKED) → **`analysis.md` delivered** (Technical Analyst): resolves the `architecture.md §14 [PENDING — ANALYSIS]` items with 8 recommendations (D1–D8) + 3 items deliberately left for the Tech Lead at DURUM 3 (`Release Scope` / `F05-DEVOPS`; `F06-CONTENT` scheduling; the F04 `Next Level` weighting-swap scope). **No upstream business-rule conflict** — the one open PRD question (1★ → `Next Level`) is resolved by the PRD's own AC (**yes**). **No F03/F04/F06/F08 contract change needed** — F05 is a pure consumer + seam-fill; the one possible F08 touch-point (the 4–6 tutorial-acknowledged flag) is avoidable via the existing `kv` table (D2).

**Next: Tech Lead** (F05.CONTRACT-TL — DURUM 3: lock `architecture.md` with D1–D8, decide `Release Scope` + `F06-CONTENT` scheduling + the F04-weighting scope, set the UI Designer brief).

---

## Current Owner

Tech Lead (F05.CONTRACT-TL — DURUM 3, `architecture.md` lock)

---

## Complexity Decision

* **COMPLEX → Technical Analyst REQUIRED.** Checked against the criteria (`prompt-tech-lead-state-machine-standard.md` DURUM 2):
  * **State-machine conceptuality — YES.** A progression/unlock state machine: per-level `locked` / `unlocked-not-completed` / `completed` / `in-progress`; the 4–6 band column micro-tutorial gate (shown once, re-shows until acknowledged, persisted); the "all 30 complete" terminal state; CONTINUE / `Next Level` / terminal resolution.
  * **Cross-feature dependency on an *unfinished* contract — YES.** `F06-CONTENT` (the 30 authored Journey levels + a manifest) does **not exist yet** — it is an open Level-Designer follow-on. F05 must define the interim bundled-content shape (map the 5-puzzle smoke set into a `journey-tr-01..05` manifest vs a stub) and **cannot reach `Done` without `F06-CONTENT`**.
  * **New entity / data model surface — PARTIAL.** No new *table* (F08 built `journey_progress` + `JourneyProgressRepo`), but a new **bundled Journey manifest + asset layout + resolver** is real design work, and the 4–6 tutorial-acknowledged flag may need a new `kv` row or a `journey_progress` / `settings` column (→ a possible F08 forward-only-migration touch-point).
  * **Unsafe-assumption risk — YES.** Multiple decisions the Tech Lead would otherwise guess: the level-id ↔ number mapping (which must keep F04's `personal_best` key stable across content re-exports); the unlock-write ordering vs F04's `personal_best` write; `push` vs `pushReplacement` for `Next Level`; where the tutorial flag lives; the F09 hand-off seam.
  * Multiple services / >3 endpoints — no (client-only, zero backend). Strong auth — no (single actor). Realtime / sync-conflict — no (a fire-and-forget local write; `JourneyProgressRepo` is transactional + idempotent).
* **UI Designer REQUIRED.** A new **home CONTINUE + Journey-progress surface** (replaces the debug `HomeScreen`), a new **action-gated column micro-tutorial overlay** (levels 4–6), and the **"all levels complete"** state — all need real UI/UX decisions + chrome parity with F03 Direction A. See `design/design-doctrine.md` + `design/premium-ui-rubric.md`.
* **DevOps/Release Engineer: TBD at the F05 DURUM 3 contract turn.** F05 ships a **Journey content pack** and is the plausible point for the **first playable app-build distribution** (F03 + F04 both folded their device smokes into "the first app-build distribution ~F05") + the Level 5 Reach / D1 / D7 KPIs need a distributed build. The Tech Lead locks `Release Scope` (likely `production-readiness` for the app-distribution gate, or a narrower content-pack gate) after the analysis; if `!= none`, `F05-DEVOPS` opens after QA.

---

## Active Task Ledger

- [x] Task ID: F05.SKELETON-TL | Assigned Role: Tech Lead | Status: **Done (2026-09-07)** | `prd.md` + initial `architecture.md` contract **brief** produced (substrate enumerated; `[PENDING — ANALYSIS]` items listed). Complexity decided (COMPLEX; Technical Analyst first; UI Designer required; DevOps TBD at DURUM 3). Routing set.
- [x] Task ID: F05.ANALYSIS-TA | Assigned Role: Technical Analyst | Status: **Done (2026-09-07)** | `analysis.md` delivered. Resolves `architecture.md §14 [PENDING — ANALYSIS]` with recommendations **D1–D8** (D1 id scheme `journey-<lang>-<NN>` ↔ `journeyLevelNumber`, no new F08 snapshot field; D2 tutorial-ack flag in the existing `kv` table — **no F08 schema change**; D3 unlock write injected into `PlaySessionController` mirroring F04's `personalBestRepo` pattern, fire-and-forget caught, after the `personal_best` write; D4 `Next Level` = `pushReplacement`, terminal + tutorial as in-screen states, no new routes; D5 app-layer `rootBundle` loader with assets in `app/assets/journey/<lang>/` mirrored from `content/`, keeping `looplet_content` pure Dart; D6 a content-manifest build gate with smoke/strict modes; D7 an interim `journey_manifest_tr.json` mapping the F06 smoke set to levels 1–5; D8 the F09 seam shipped with `onboardingComplete` hard-`true`). 3 items left for the Tech Lead at DURUM 3 (`Release Scope` / `F05-DEVOPS`; `F06-CONTENT` scheduling; the F04 `Next Level` weighting-swap scope). No upstream business-rule conflict (1★ → `Next Level` resolved by the PRD AC — **yes**). No F03/F04/F06/F08 contract change needed. Full task breakdown (F05-FE.CONTENT/GATE/PROGRESS/UNLOCK/NAV/HOME/TUTORIAL/STRINGS/TESTS) + QA scope in `analysis.md §16`.
- [ ] Task ID: F05.CONTRACT-TL | Assigned Role: Tech Lead | Status: **Open — NEXT** | DURUM 3 — carry D1–D8 into a **LOCKED** `architecture.md` (lock the id scheme D1 as a hard constraint for `F06-CONTENT`); decide `Release Scope` + whether `F05-DEVOPS` opens; decide `F06-CONTENT` scheduling; decide the F04 `Next Level` weighting-swap scope; set the UI Designer brief (home CONTINUE/progress/terminal + the 4–6 column micro-tutorial overlay); route.
- [ ] Task ID: F05-UI | Assigned Role: UI Designer | Status: Open (after contract) | `ui-design.md` — the minimal home CONTINUE + Journey-progress surface (replaces the debug `HomeScreen`); the levels 4–6 column micro-tutorial overlay (action-gated, re-shows until acknowledged); the "all levels complete" state. Chrome parity with F03 Direction A; `design-doctrine.md` + `premium-ui-rubric.md` ≥ 90.
- [ ] Task ID: F05-FE1…FEn | Assigned Role: Frontend/Mobile Developer | Status: Open (after UI) | The bundled Journey content resolver (`playSessionSetupProvider` `journeyLevel` branch + a `JourneyContentRepo` + the manifest/assets); the unlock write into F04's win path (`JourneyProgressRepo.markCompleted`, fire-and-forget caught); the `Next Level` handler + terminal state; CONTINUE resolution + the F08 restore wiring; the home surface + the 4–6 micro-tutorial overlay (per `ui-design.md`); the content-manifest build gate; tests. Against the LOCKED `architecture.md` + `ui-design.md`.
- [ ] Task ID: F05-QA1…QAn | Assigned Role: QA | Status: Open (after Frontend) | End-to-end **client** QA per the LOCKED `architecture.md §12` — `automated functional` mandatory (unlock rule + idempotency vs the real F08 repo; CONTINUE / `Next Level` / terminal resolution; the micro-tutorial gate + re-show; the content resolver + corrupt-asset degradation + offline load) + `ui-design.md` alignment. `runtime` (device) for CONTINUE-resume + the tutorial + the home visuals — **the likely first app-build distribution device smoke** (F03 + F04 device follow-ons fold in). Security compliance N/A (single actor, local-only progress, no endpoint — justify).
- [ ] Task ID: F05-DEVOPS | Assigned Role: DevOps/Release Engineer | Status: Open **IFF** `Release Scope != none` (Tech Lead decides at F05.CONTRACT-TL) | The first app-build distribution runbook + the folded-in F03/F04 device smokes + the Journey content-pack release gate + rollback. `release.md`.

---

## QA Scope

* **[PENDING — LOCK at F05.CONTRACT-TL].** Draft (from `architecture.md §12`): end-to-end **client** feature; `automated functional` **mandatory** (the unlock rule + idempotency against F08's real `JourneyProgressRepo` + an in-memory DB; CONTINUE / `Next Level` / terminal resolution; the 4–6 micro-tutorial gate + re-show + acknowledge-persist; the bundled-content resolver + corrupt/missing-asset degradation + offline load) + `ui-design.md` alignment (home CONTINUE/progress surface + tutorial overlay; chrome parity with F03; `premium-ui-rubric.md` ≥ 90). `runtime` (device) for CONTINUE-resume feel + the tutorial + the home visuals — **folds into / is the first app-build distribution device smoke** (F03's 3-item manual device confirmation + F04's N4 device feel fold in here). **Not `source-only`.** Security compliance out of scope (single actor, local-only journey progress, no auth, no endpoint — justify in the QA output).

---

## Release Scope

`[PENDING — Tech Lead decision at F05.CONTRACT-TL]`. Candidate: **`production-readiness`** — F05 ships a Journey content pack (30 bundled level assets + manifest) and is the plausible point for the first playable app-build distribution (the Level 5 Reach / D1 / D7 validation gate; F03 + F04 folded their device smokes into "the first app-build distribution ~F05"). Alternative: a narrower content-pack gate. CI code gates + a new content-manifest check apply regardless. If `!= none`, `F05-DEVOPS` opens after QA and F05 is not `Done` until release readiness is reconciled.

---

## Open Tasks

### Skeleton
- [x] (F05.SKELETON-TL) `prd.md` + initial `architecture.md` brief — done 2026-09-07. Substrate enumerated; `[PENDING — ANALYSIS]` listed; complexity + routing set.

### Analysis
- [x] (F05.ANALYSIS-TA) `analysis.md` — delivered 2026-09-07. Resolves `architecture.md §14` with D1–D8 + 3 Tech-Lead-at-DURUM-3 items; no upstream conflict; no F03/F04/F06/F08 contract change needed.

### Contract
- [ ] (F05.CONTRACT-TL) DURUM 3 — LOCK `architecture.md` (D1–D8) + `Release Scope` + `F06-CONTENT` scheduling + F04-weighting scope + UI brief. **NEXT.**

### UI Design
- [ ] (F05-UI) `ui-design.md` — home CONTINUE/progress + 4–6 micro-tutorial overlay + "all complete" state. After contract.

### Frontend
- [ ] (F05-FE1…FEn) content resolver + unlock write + `Next Level` + CONTINUE + home surface + micro-tutorial + build gate + tests. After UI.

### QA
- [ ] (F05-QA) end-to-end client QA. After Frontend.

### DevOps (conditional)
- [ ] (F05-DEVOPS) app-build distribution runbook + device smokes + content-pack gate. IFF `Release Scope != none`, after QA.

---

## Consumed Signals

* `analysis.md` — **delivered 2026-09-07 (Technical Analyst).** Decisions D1–D8 + a full task breakdown; 3 items deferred to the Tech Lead at DURUM 3 (`Release Scope` / `F05-DEVOPS`; `F06-CONTENT` scheduling; F04 `Next Level` weighting-swap scope). **Not yet consumed into `architecture.md`** — the Tech Lead carries D1–D8 into the LOCKED contract at F05.CONTRACT-TL. Downstream roles (UI Designer, Frontend, QA) wait for the LOCKED `architecture.md`. Unresolved analysis questions: the 3 Tech-Lead items above (Open Questions 4/5/7 in `analysis.md §15`).

---

## Blockers

* **`F06-CONTENT` — hard prerequisite for F05 reaching `Done` (not for F05 build/QA).** The 30 authored Journey levels + a manifest do not exist yet (open Level-Designer follow-on, split off F06, still MVP scope). F05 is built + QA'd against the 5-puzzle smoke set mapped into an interim `journey-tr-01..05` manifest (shape confirmed by the analysis). **F05 → `Done` requires `F06-CONTENT` delivered + the levels landing the difficulty-curve bands.** Tech Lead schedules `F06-CONTENT` (tracked in `features/f06-.../orchestration.md → Open Tasks → Content`) so it lands before / alongside F05 QA.
* **F09 (`Not Started`)** — the pre-Level-1 onboarding hand-off is a `[PENDING — F09]` seam. Not a blocker — F05 ships a clean seam + an interim (CONTINUE → Level 1 for a brand-new player).
* **Possible F08 touch-point** — if the 4–6 tutorial-acknowledged flag needs a new column (vs a `kv` row), that is a tiny F08 forward-only migration the Tech Lead routes at DURUM 3. The analysis flags it.
* **Not a blocker, noted:** F10 will re-home F05's minimal home surface; F11 (audio/haptics on unlock) + F12 (`level_started`/`level_completed`) are downstream. F04's follow-ons (N3 storage-full test-debt; N4 device feel) fold into the F05-era first-app-distribution smoke.

---

## Last Decision

* 2026-09-07 — Tech Lead (**F05 activation — skeleton + complexity**):
  * **Activated F05** after F04 → `Done` (QA re-verify `Approved with Notes`). F05 is next on the critical path (`§12.6` build order `… F03, F05 …`), unblocked by F04 (the real stars/best completion panel), F03 (`Done`), F06 (`Done`, toolchain).
  * **Complexity: COMPLEX** → **Technical Analyst pass first** (rationale in `## Complexity Decision` — a progression/unlock state machine + the 4–6 micro-tutorial gate + the terminal state; a cross-feature dependency on the **unfinished `F06-CONTENT`**; a new bundled-content manifest/resolver; several unsafe-assumption decisions). **UI Designer required** (home CONTINUE/progress surface + the column micro-tutorial overlay + the "all complete" state). **DevOps TBD at the DURUM 3 contract turn** (F05 likely triggers the first app-build distribution gate + a Journey content pack → probably `Release Scope != none`).
  * **Substrate already built** (`architecture.md §3`): F08's `journey_progress` table + `JourneyProgressRepo` (`markCompleted` linear-unlock idempotent, `read`/`watch`/`completedLevels`); F03's `/play` + `PlaySessionArgs.journeyLevel` + the F08 restore path; F04's `CompletionPanel.onNextLevel` seam + the win path; F06's `Puzzle`/`Puzzle.fromJson` + `toEngineConfig` + `export`/`check`. F05 changes **no** F03/F04/F06/F08 contract — it consumes them and fills the `[PENDING — F05]` seams.
  * **Skeleton produced:** `prd.md` (AC1–AC14) + an initial `architecture.md` **contract brief** (NOT LOCKED — `[PENDING — ANALYSIS]` items in §14). The LOCKED contract is a Tech Lead DURUM 3 output after the analysis.
  * **F06-CONTENT** is the hard prerequisite for F05 `Done` — F05 builds/QAs against the 5-puzzle smoke set mapped into an interim manifest; the analysis confirms that shape. Tech Lead schedules `F06-CONTENT` to land before/alongside F05 QA.
  * Routing: **Technical Analyst (F05.ANALYSIS-TA → `analysis.md`)** → Tech Lead (F05.CONTRACT-TL → LOCK `architecture.md` + `Release Scope`) → UI Designer (F05-UI) → Frontend/Mobile Developer (F05-FE1…FEn) → QA → (DevOps if gated) → Tech Lead close. `feature-board.md` + `system-state.md` synced (F04 → `Done`; F05 → `In Progress` / Technical Analyst; F08 unchanged / parked).

---

## Last Update

* Updated By: Technical Analyst
* Timestamp: 2026-09-07
* Summary: **F05.ANALYSIS-TA complete.** `analysis.md` delivered — resolves `architecture.md §14 [PENDING — ANALYSIS]` with recommendations **D1–D8**: D1 id scheme `journey-<lang>-<NN>` ↔ `journeyLevelNumber` (durable key for `personal_best`/resume; **no new F08 snapshot field**); D2 the 4–6 tutorial-ack flag in the existing **`kv`** table (**no F08 schema change**; alt = a `journey_progress` column + a migration); D3 the unlock write **injected into `PlaySessionController`** mirroring F04's `personalBestRepo` pattern (fire-and-forget caught, after the `personal_best` write; alt = a screen-level reaction); D4 `Next Level` = **`pushReplacement`**, terminal + tutorial as **in-screen states** (no new routes), all back paths → `/`; D5 an **app-layer `rootBundle` loader** with assets in `app/assets/journey/<lang>/` mirrored from `content/` (keeps `looplet_content` pure Dart; alt = bundle in `looplet_content`); D6 a **content-manifest build gate** (smoke/strict modes); D7 an **interim `journey_manifest_tr.json`** mapping the F06 smoke set (`smoke-tr-01/02/04/05/06`) to levels 1–5 for F05 build+QA; D8 the **F09 seam** shipped with `onboardingComplete` hard-`true`. **3 items left for the Tech Lead at DURUM 3:** `Release Scope` + whether `F05-DEVOPS` opens (F05 is the plausible first app-build distribution gate); `F06-CONTENT` scheduling (hard prerequisite for F05 `Done`, not for build/QA); the F04 `Next Level` weighting-swap scope (F05-UI or deferred). **No upstream business-rule conflict** — the one open PRD question (1★ → `Next Level`) is resolved by the PRD's own AC (**yes**). **No F03/F04/F06/F08 contract change needed** — F05 is a pure consumer + seam-fill. Contract risk flagged: the id scheme (D1) is load-bearing for `personal_best` + resume → must be written into `architecture.md` as a hard constraint on `F06-CONTENT`; the shared `kv` table wants a documented key registry. Full task breakdown (F05-FE.CONTENT/GATE/PROGRESS/UNLOCK/NAV/HOME/TUTORIAL/STRINGS/TESTS) + QA scope in `analysis.md §16`. `Current Owner → Tech Lead` (F05.CONTRACT-TL); `Next Role → Tech Lead`. `feature-board.md` + `system-state.md` **not touched** (Technical Analyst does not sync global surfaces; Tech Lead does at DURUM 3).

---

## Next Role

Tech Lead

---

## Next Action

### Tech Lead — F05.CONTRACT-TL (DURUM 3 — LOCK `architecture.md`) — ⬅ NEXT

```text
Input: analysis.md (D1–D8 recommendations + §15 Open Questions + §17 Delivery Note), the
architecture.md contract BRIEF, prd.md (AC1–AC14), project-authority/release.md.

Carry the analysis into a LOCKED architecture.md (DURUM 3):
1. Lock D1–D8 (analysis.md §17):
   - D1 id scheme `journey-<lang>-<NN>` ↔ `journeyLevelNumber` — write it as a HARD CONSTRAINT on
     `F06-CONTENT`; no new F08 snapshot field (in-progress level parsed from `puzzleId`).
   - D2 tutorial-ack flag → the existing `kv` table (recommended, no F08 schema change). If you
     instead want a `journey_progress` column: route a tiny F08 forward-only migration + an F08
     `architecture.md` amendment THIS turn.
   - D3 unlock write → injected into `PlaySessionController` (mirror F04's `personalBestRepo`), fire-
     and-forget caught, after the `personal_best` write. (Or lock the screen-level alternative.)
   - D4 `Next Level` = `pushReplacement`; terminal + tutorial = in-screen states, no new routes;
     all back paths → `/`.
   - D5 content asset home + loader (app-layer `rootBundle`, keep `looplet_content` pure).
   - D6 content-manifest build gate (smoke/strict modes).
   - D7 interim `journey_manifest_tr.json` (F06 smoke set → levels 1–5) for F05 build + QA.
   - D8 F09 seam shipped with `onboardingComplete` hard-`true`.
2. Add a documented `kv` key registry note (shared table: `active_session`, `store_meta`, + the
   new tutorial-ack key) — to `f05 architecture.md` or `f08 architecture.md`.
3. DECIDE `Release Scope` (analysis.md Open Question 4): is F05 the first app-build distribution
   gate (`production-readiness` + open `F05-DEVOPS` after QA — the F03 3-item manual device
   confirmation + F04's N4 reveal feel fold into that smoke), a narrower content-pack gate, or
   `none` with distribution deferred? Set `orchestration.md → Release Scope` + the QA Scope line.
4. DECIDE `F06-CONTENT` scheduling (Open Question 5): open it now (parallel to F05 build) or gate
   F05 QA on it. F05 CANNOT reach `Done` without the 30 real levels landing the curve bands.
5. DECIDE the F04 `Next Level` weighting-swap scope (Open Question 7): in F05-UI's brief, or
   deferred. (F04's forward note: once `Next Level` is live, Perfect → Next Level primary,
   sub-optimal → Retry primary.)
6. Write the UI Designer brief: the minimal home CONTINUE + Journey-progress + "all 30 complete"
   surface (replaces the debug `HomeScreen`); the 4–6 column micro-tutorial overlay (action-gated,
   re-shows until acknowledged); chrome parity with F03 Direction A; `premium-ui-rubric.md` ≥ 90.
7. Sync feature-board.md + system-state.md; set Next Role → UI Designer.

End: `Run UI Designer` (F05-UI → `ui-design.md`).
```

→ then `Run UI Designer` → `Run Frontend/Mobile Developer` → `Run QA` → (`Run DevOps/Release Engineer` if gated) → `Run Tech Lead` (F05 close).

---

## Change Log

* v2 (2026-09-07) — Technical Analyst: **F05.ANALYSIS-TA complete.** `analysis.md` delivered — resolves `architecture.md §14 [PENDING — ANALYSIS]` with **D1–D8** (D1 id scheme `journey-<lang>-<NN>` ↔ `journeyLevelNumber`, no new F08 snapshot field — in-progress level parsed from `puzzleId`; D2 the 4–6 tutorial-ack flag in the existing **`kv`** table → **no F08 schema change** (alt = a `journey_progress` column + a forward-only migration); D3 the unlock write **injected into `PlaySessionController`** mirroring F04's `personalBestRepo` pattern, fire-and-forget caught, after the `personal_best` write (alt = a screen-level reaction); D4 `Next Level` = **`pushReplacement`**, terminal + tutorial = **in-screen states** (no new routes), all back paths → `/`; D5 an **app-layer `rootBundle` loader** with assets in `app/assets/journey/<lang>/` mirrored from `content/` (keeps `looplet_content` pure Dart; alt = bundle in `looplet_content`); D6 a **content-manifest build gate** with smoke/strict modes; D7 an **interim `journey_manifest_tr.json`** mapping the F06 smoke set (`smoke-tr-01/02/04/05/06`) to levels 1–5 for F05 build+QA; D8 the **F09 seam** shipped with `onboardingComplete` hard-`true`). **3 items deliberately left for the Tech Lead at DURUM 3** (`analysis.md §15` Open Questions 4/5/7): `Release Scope` + whether `F05-DEVOPS` opens (F05 is the plausible first app-build distribution gate; F03's 3-item manual device confirmation + F04's N4 reveal feel fold into that smoke); `F06-CONTENT` scheduling (hard prerequisite for F05 `Done`, not for build/QA against the interim manifest); the F04 `Next Level` weighting-swap scope. **No upstream business-rule conflict** — the one open PRD question (1★ → `Next Level`) is resolved by the PRD's own AC (**yes**, stars never gate); no PO escalation. **No F03/F04/F06/F08 contract change needed** — F05 is a pure consumer + seam-fill. **Contract risks flagged for the Tech Lead:** the id scheme (D1) is load-bearing for `personal_best` (F04) + snapshot resume (F03/F08) → must be written into `architecture.md` as a hard constraint on `F06-CONTENT`; the shared `kv` table wants a documented key registry. Full task breakdown (`analysis.md §16` — F05-FE.CONTENT/GATE/PROGRESS/UNLOCK/NAV/HOME/TUTORIAL/STRINGS/TESTS + QA scope). `Current Owner → Tech Lead` (F05.CONTRACT-TL); `Next Role → Tech Lead`. `feature-board.md` + `system-state.md` untouched (Technical Analyst does not sync global surfaces). Nothing committed to git.
* v1 (2026-09-07) — Tech Lead: **F05 created + activated** after F04 → `Done` (QA re-verify `Approved with Notes`). P0; next on the critical path (`§12.6` `… F03, F05 …`); unblocked by F04 (the real stars/best completion panel) + F03 (`Done`) + F06 (`Done`, toolchain). `prd.md` derived from `product-prd.md` F05 section + §6.1 F05 row + §5.1/§5.2 user flows + §41 KPIs (AC1–AC14 — linear unlock stars-don't-gate; the 1–3 / 4–6 / 7–10 / 11–15 / 16–20 / 21–25 / 26–30 curve bands; CONTINUE resume via the F08 restore path; the "all 30 complete" terminal; `Next Level` = F05's handler for F04's `[PENDING — F05]` seam; the 4–6 column micro-tutorial re-show-until-acknowledged; offline Journey). Initial `architecture.md` **contract brief** (NOT LOCKED): §3 enumerates the substrate already built (F08 `journey_progress` + `JourneyProgressRepo`; F03 `/play` + `PlaySessionArgs.journeyLevel` + F08 restore; F04 `CompletionPanel.onNextLevel` seam + win path; F06 `Puzzle` + `toEngineConfig` + `export`/`check`); §4–§10 propose the progression model / bundled-content manifest+resolver / CONTINUE / micro-tutorial / home surface / routing / persistence; §14 lists the `[PENDING — ANALYSIS]` items. **Complexity: COMPLEX** (state-machine conceptuality; cross-feature dependency on the **unfinished `F06-CONTENT`**; a new bundled-content manifest/resolver; unsafe-assumption decisions — level-id↔number mapping, unlock-write ordering, route strategy, tutorial-flag location, F09 seam) → **Technical Analyst pass first**. **UI Designer required** (home CONTINUE/progress surface + column micro-tutorial overlay + "all complete" state). **DevOps TBD at F05.CONTRACT-TL** (F05 likely triggers the first app-build distribution gate + a Journey content pack → probably `Release Scope != none`; F03's 3-item manual device confirmation + F04's N4 device feel fold into the F05-era smoke). **`F06-CONTENT` is the hard prerequisite for F05 `Done`** — F05 builds/QAs against the 5-puzzle smoke set mapped into an interim manifest. Changes **no** F03/F04/F06/F08 contract (seam-fills + possibly one tiny F08 migration for the tutorial-acknowledged flag). Routing: **Technical Analyst → Tech Lead (DURUM 3 contract) → UI Designer → Frontend/Mobile Developer → QA → (DevOps if gated) → Tech Lead close.** `feature-board.md` + `system-state.md` synced (F04 → `Done`; F05 → `In Progress` / Technical Analyst; F08 unchanged / parked). Nothing committed to git.
