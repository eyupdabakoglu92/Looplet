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

## Round 4 (runtime parity — F00-FE-DESIGN-SYSTEM)

Real Flutter captures of the design-system gallery (`app/lib/main_gallery.dart`, debug-only) beside the selected source; evidence lives in `../frontend.md` (Visual Parity Evidence).

* `runtime-iphone16-<offset>.png` — iPhone 16 (393x852, 3x) gallery frames at scroll offsets 0 / 640 / 1280 / 1920 / 2560 (stored at 50 %; native 1179x2556). `runtime-iphone16e-sheet.png`, `runtime-iphone16promax-sheet.png` — the same five frames on the 16e (390x844) and 16 Pro Max (440x956). `runtime-iphone16-2560.png` is the Turkish-glyph / tabular-figure / weight-axis frame.
* `parity-runtime-1-tiles.png`, `-2-controls.png`, `-3-cards-icons.png` — `S-91-components.png` (or the C-03 play frame where the specimen omits an icon) beside the runtime crop, both scaled to the same size.
* Reproduce: `cd app && flutter build ios --simulator --debug -t lib/main_gallery.dart`, then `sh src/capture-gallery.sh <name> <simulator-udid> <out-dir>` (fixed scroll offsets; the offset travels as a file in the app container's tmp dir because `Platform.environment` is empty on iOS; frames under 500 kB are launch screens and are retried) and `python3 src/parity-board.py <out-dir> <board-dir>` (writes the three board HTML pages; render them with headless Chrome at DPR 1).
