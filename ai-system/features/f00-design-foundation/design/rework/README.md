# F00-FE-A11Y-REWORK runtime evidence (Frontend/Mobile Developer, 2026-09-23)

Real Flutter captures on the canonical simulator (iPhone 16, iOS 18.6, `xcrun simctl ui <udid> content_size accessibility-medium` — the `platform.md` §14 / QA-01 floor). Revision: the seven-file diff of this task (`app/lib/design/**`, `app/test/design/components_test.dart`), on top of commit `5f18c89`.

* `before-overflow-movescard-1.65x.jpg` — **the bug, first fix attempt still present**: `MovesCard` with a fixed height plus a 1.3x text-scale ceiling (no `minHeight`) still clips "HAMLE" and shows a real `BOTTOM OVERFLOWED BY 1.5 PIXELS` banner at accessibility-medium. This is what a *widget test* at the same scale did **not** catch (`flutter test` passed) — a real device's font hinting doesn't match the test harness closely enough to trust a hand-picked scale ceiling for the last pixel. Found by this runtime capture, not by the automated suite.
* `after-fixed-movescard-1.65x.jpg` — the same frame after switching `MovesCard`/`StatCard` to a `minHeight` (not a fixed height) as the primary fix, keeping the text-scale cap only as a secondary bound: no banner, "HAMLE" fully drawn.
* `after-fixed-1.65x-sheet1.jpg`, `after-fixed-1.65x-sheet2.jpg` — all five gallery sections at accessibility-medium after the fix: colour roles/wordmark, type roles/tile states, controls, cards/stats/track, icons/Turkish glyphs/weight axis. No overflow banner anywhere.

Reproduce: `cd app && flutter build ios --simulator --debug -t lib/main_gallery.dart`, then `sh ../ai-system/features/f00-design-foundation/design/src/capture-gallery.sh <name> <udid> <out-dir>` after setting `xcrun simctl ui <udid> content_size accessibility-medium` (reset to `large` afterwards).
