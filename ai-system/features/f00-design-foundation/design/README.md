# F00 design artefacts (Phase B) — how they were made

Generated design evidence for `project-authority/design-foundation.md` (Status: Draft). Not app runtime captures.

* `src/gen.mjs` — one generator, both directions, identical content/state/geometry (real shipped copy and puzzles: level 1, 4, 26).
* `src/render.sh` — headless Google Chrome, `--force-device-scale-factor=2` (specimens 1) → `../<name>.png`.
* `src/sheets.py` — contact sheets and A|B comparisons.
* `src/fonts/` — Sora and Newsreader (SIL OFL 1.1) with their licence texts.

Regenerate: `cd src && node gen.mjs . && sh render.sh && python3 sheets.py`.
Names: `A-…` / `B-…` = Direction A (Backlit Stage) / B (Gazette); `01–07` states, `08–10` won-moment stills (not motion evidence), `v-` device variants, `90-specimen` type/icon/contrast sheet, `compare-*` / `sheet-*` composites.

## Round 2 (Direction C — Loop Glass)

* `src/gen-c.mjs` — Direction C generator (job list `src/jobs-c.txt`); `src/sheets-c.py` — parity comparisons (`parity-*.png`), `sheet-C.png`, `compare-C-*.png`, `compare-ABC.png`.
* `reference/` — the user's three reference screens (canonical-reference; supplied 2026-09-21).
* Regenerate: `cd src && node gen-c.mjs . && sh render.sh "" jobs-c.txt && python3 sheets-c.py`. `render.sh` retries a headless-Chrome flake up to 3 times.
* Fonts added: Space Grotesk and Manrope (SIL OFL 1.1) with licence texts in `src/fonts/`.

## Round 3 (selected source — F00-UI-FINALIZE)

* `src/gen-s.mjs` — selected-source generator (job list `src/jobs-s.txt`): wordmark `Looplet`, full-screen Result, the board-to-Result transition as a real animation (`src/S-transition-prototype.html`; the `S-08…S-16` stills are frames taken from it), the component/token sheet `S-91-components.png`. `src/sheets-s.py` builds `sheet-S.png` and `sheet-S-transition.png`.
* Regenerate: `cd src && node gen-s.mjs . && sh render.sh "" jobs-s.txt && python3 sheets-s.py`.
* `src/guide.py` builds the plain-language decision guide (`guide-0…7`) used for F00.FOUNDATION-SELECTION.
* Handoff document: `../ui-design.md`.
