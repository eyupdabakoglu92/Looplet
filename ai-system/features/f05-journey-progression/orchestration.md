# F05 — journey-progression: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In Progress — activated 2026-09-07 (after F04 → `Done`).** Skeleton produced by the Tech Lead: `prd.md` (AC1–AC14, derived from `product-prd.md` F05 + §6.1 F05 row + §5.1/§5.2 + §41 KPIs) + an **initial `architecture.md` contract brief** (NOT LOCKED — the substrate already built by F03/F04/F06/F08 is enumerated; the `[PENDING — ANALYSIS]` items are listed for the Technical Analyst). **Complexity: COMPLEX** → Technical Analyst pass first, then Tech Lead DURUM 3 locks `architecture.md` + `Release Scope`. **UI Designer required.** **DevOps TBD at the contract turn** (F05 likely triggers the first app-build distribution gate + a Journey content pack).

**Next: Technical Analyst** (`analysis.md`).

---

## Current Owner

Technical Analyst

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
- [ ] Task ID: F05.ANALYSIS-TA | Assigned Role: Technical Analyst | Status: **Open — NEXT** | Produce `features/f05-journey-progression/analysis.md`. Resolve `architecture.md §14` `[PENDING — ANALYSIS]`: the progression/unlock model (§4 — level-id↔number mapping keeping F04's `personal_best` key stable; unlock-write ordering vs F04's write; CONTINUE / `Next Level` / terminal resolution algorithm); the bundled Journey manifest + asset layout + resolver + a content-manifest build gate (§5), **incl. the interim shape while `F06-CONTENT` is unfinished** (5-puzzle smoke set → `journey-tr-01..05` manifest vs a stub); where the 4–6 tutorial-acknowledged flag lives (§7/§10 — `kv` row vs a new column → flag any F08 touch-point); `push` vs `pushReplacement` + whether terminal/tutorial states need their own routes (§9); the F09 brand-new-player hand-off seam. Call out anything that needs an F08 schema amendment. No code. See the brief in `## Next Action`.
- [ ] Task ID: F05.CONTRACT-TL | Assigned Role: Tech Lead | Status: Open (after analysis) | DURUM 3 — carry the analysis decisions into a **LOCKED** `architecture.md`; decide `Release Scope` + whether `F05-DEVOPS` opens; set the UI Designer brief; route.
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
- [ ] (F05.ANALYSIS-TA) `analysis.md` — resolve `architecture.md §14`. **NEXT.**

### Contract
- [ ] (F05.CONTRACT-TL) DURUM 3 — LOCK `architecture.md` + `Release Scope`. After analysis.

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

* `analysis.md` — **not yet produced.** F05 is COMPLEX; the Technical Analyst pass is the next step. Downstream roles wait for the LOCKED `architecture.md` (DURUM 3).

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

* Updated By: Tech Lead
* Timestamp: 2026-09-07
* Summary: **F05 activated after F04 → `Done`.** `prd.md` + initial `architecture.md` contract brief created. Complexity = **COMPLEX** (progression state machine + bundled-content manifest/resolver + the unfinished `F06-CONTENT` dependency + unsafe-assumption decisions) → Technical Analyst pass first. UI Designer required; DevOps TBD at DURUM 3. Persistence substrate (`journey_progress` + `JourneyProgressRepo`) pre-built by F08 — no schema change expected (one possible tiny touch-point: the 4–6 tutorial-acknowledged flag). `Current Owner → Technical Analyst`; `Next Role → Technical Analyst`. `feature-board.md` + `system-state.md` synced.

---

## Next Role

Technical Analyst

---

## Next Action

### Technical Analyst — F05.ANALYSIS-TA → `analysis.md` — ⬅ NEXT

```text
Task: produce features/f05-journey-progression/analysis.md — resolve the [PENDING — ANALYSIS] items
so the Tech Lead can lock architecture.md (DURUM 3). No code.

Authority: features/f05-journey-progression/architecture.md (the contract BRIEF — §3 substrate already
built, §4–§10 the proposals, §14 the [PENDING — ANALYSIS] list), features/f05-.../prd.md (AC1–AC14 +
§6 constraints + §7 KPIs), features/f03-puzzle-play-session/architecture.md §13 (route/nav +
PlaySessionArgs), features/f04-star-rating-and-personal-best/architecture.md §7/§8 (the panel +
the Next Level [PENDING — F05] seam + the win path), features/f06-.../architecture.md (Puzzle format +
export/check), app/lib/persistence/repositories/journey_progress_repo.dart +
app/lib/persistence/active_session_snapshot.dart (the F08 substrate), project-authority/platform.md
(Flutter / go_router / asset bundling / localization).

Must resolve:
1. Progression / unlock model (architecture.md §4): the level-id ↔ journeyLevel-number mapping — it
   MUST keep F04's `personal_best` key (`levelId` = `puzzle.id`) stable across F06 content
   re-exports; the unlock-write ordering vs F04's `personal_best` write (independent local writes —
   confirm both fire-and-forget + caught, and neither blocks the panel); the exact CONTINUE /
   Next Level / "all 30 complete" terminal resolution algorithm (incl. N==30 and N+1-missing).
2. Bundled Journey content (architecture.md §5): the manifest schema + asset directory layout +
   the resolver (`playSessionSetupProvider` journeyLevel branch, or a `JourneyContentRepo`) +
   `rootBundle` load + `Puzzle.fromJson` + caching + typed corrupt/missing-asset failure; a
   content-manifest build gate (extends F06 `check` / a `melos content:check` step); AND the
   INTERIM shape while `F06-CONTENT` is unfinished — map the 5-puzzle smoke set into a
   `journey-tr-01..05` manifest, or a documented stub. Be explicit about what F05 build + QA run
   against vs what `Done` needs.
3. The 4–6 column micro-tutorial (architecture.md §7/§10): trigger (first load of level 4?),
   action-gated behaviour, re-show-until-acknowledged, and WHERE the acknowledged flag persists —
   a `kv` row vs a new `journey_progress` / `settings` column. If a new column: flag it as an F08
   forward-only-migration touch-point (the Tech Lead routes a tiny F08 amendment or mandates `kv`).
4. Routing (architecture.md §9): `push` vs `pushReplacement` for Next Level (30 stacked `/play`
   routes is wrong); whether the terminal / tutorial states are in-screen states or own routes;
   all back targets resolve to `/` (no empty stack, no wrong route).
5. The F09 brand-new-player hand-off seam (CONTINUE → onboarding → Level 1) — F09 is Not Started;
   define a clean seam + the interim (CONTINUE → Level 1).
6. Enumerate every F03 / F04 / F06 / F08 touch-point and confirm NONE needs a contract change
   (only seam-fills + possibly one tiny F08 migration for the tutorial flag).

Deliver: analysis.md with a decision + rationale for each; mark Product-Decision items (if any) for
Tech Lead → PO escalation; mark Technical-Decision items resolved.

End: Technical Analyst always emits `Run Tech Lead`.
```

→ then `Run Tech Lead` (F05.CONTRACT-TL — LOCK `architecture.md` + `Release Scope`, route to UI Designer).

---

## Change Log

* v1 (2026-09-07) — Tech Lead: **F05 created + activated** after F04 → `Done` (QA re-verify `Approved with Notes`). P0; next on the critical path (`§12.6` `… F03, F05 …`); unblocked by F04 (the real stars/best completion panel) + F03 (`Done`) + F06 (`Done`, toolchain). `prd.md` derived from `product-prd.md` F05 section + §6.1 F05 row + §5.1/§5.2 user flows + §41 KPIs (AC1–AC14 — linear unlock stars-don't-gate; the 1–3 / 4–6 / 7–10 / 11–15 / 16–20 / 21–25 / 26–30 curve bands; CONTINUE resume via the F08 restore path; the "all 30 complete" terminal; `Next Level` = F05's handler for F04's `[PENDING — F05]` seam; the 4–6 column micro-tutorial re-show-until-acknowledged; offline Journey). Initial `architecture.md` **contract brief** (NOT LOCKED): §3 enumerates the substrate already built (F08 `journey_progress` + `JourneyProgressRepo`; F03 `/play` + `PlaySessionArgs.journeyLevel` + F08 restore; F04 `CompletionPanel.onNextLevel` seam + win path; F06 `Puzzle` + `toEngineConfig` + `export`/`check`); §4–§10 propose the progression model / bundled-content manifest+resolver / CONTINUE / micro-tutorial / home surface / routing / persistence; §14 lists the `[PENDING — ANALYSIS]` items. **Complexity: COMPLEX** (state-machine conceptuality; cross-feature dependency on the **unfinished `F06-CONTENT`**; a new bundled-content manifest/resolver; unsafe-assumption decisions — level-id↔number mapping, unlock-write ordering, route strategy, tutorial-flag location, F09 seam) → **Technical Analyst pass first**. **UI Designer required** (home CONTINUE/progress surface + column micro-tutorial overlay + "all complete" state). **DevOps TBD at F05.CONTRACT-TL** (F05 likely triggers the first app-build distribution gate + a Journey content pack → probably `Release Scope != none`; F03's 3-item manual device confirmation + F04's N4 device feel fold into the F05-era smoke). **`F06-CONTENT` is the hard prerequisite for F05 `Done`** — F05 builds/QAs against the 5-puzzle smoke set mapped into an interim manifest. Changes **no** F03/F04/F06/F08 contract (seam-fills + possibly one tiny F08 migration for the tutorial-acknowledged flag). Routing: **Technical Analyst → Tech Lead (DURUM 3 contract) → UI Designer → Frontend/Mobile Developer → QA → (DevOps if gated) → Tech Lead close.** `feature-board.md` + `system-state.md` synced (F04 → `Done`; F05 → `In Progress` / Technical Analyst; F08 unchanged / parked). Nothing committed to git.
