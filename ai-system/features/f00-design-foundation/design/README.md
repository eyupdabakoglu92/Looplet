# F00 design artefacts (Phase B) — how they were made

Generated design evidence for `project-authority/design-foundation.md` (Status: Draft). Not app runtime captures.

* `src/gen.mjs` — one generator, both directions, identical content/state/geometry (real shipped copy and puzzles: level 1, 4, 26).
* `src/render.sh` — headless Google Chrome, `--force-device-scale-factor=2` (specimens 1) → `../<name>.png`.
* `src/sheets.py` — contact sheets and A|B comparisons.
* `src/fonts/` — Sora and Newsreader (SIL OFL 1.1) with their licence texts.

Regenerate: `cd src && node gen.mjs . && sh render.sh && python3 sheets.py`.
Names: `A-…` / `B-…` = Direction A (Backlit Stage) / B (Gazette); `01–07` states, `08–10` won-moment stills (not motion evidence), `v-` device variants, `90-specimen` type/icon/contrast sheet, `compare-*` / `sheet-*` composites.
