# QA Module — Visual Quality

Bu modül `Visual Scope != none` olduğunda zorunludur ve yalnız `QA Modules` içinde seçiliyse okunur.

## Required inputs

* `design/design-doctrine.md`
* `design/premium-ui-rubric.md`
* `design/visual-quality-gate.md`
* `project-authority/design-foundation.md`
* `features/{feature-name}/ui-design.md`
* `features/{feature-name}/frontend.md` veya `game-dev.md`
* UI Designer direction renders ve implementation runtime captures

## Independent runtime review

* Developer/UI Designer self-score'unu verdict olarak kullanma.
* Canonical target'ta gerçek runtime capture'ı incele.
* En az selected direction ile aynı viewport/device'taki implementation evidence'ı karşılaştır.
* Motion-critical scope'ta static screenshot yeterli değildir; runtime video/prototype evidence gerekir.
* Loading/error/empty/disabled gibi in-scope state'ler görsel kaliteyi etkiliyorsa ilgili capture'ları dahil et.
* Placeholder/generic asset, hierarchy çökmesi, clipping/overflow, unreadable contrast, inconsistent chrome, asset/style drift ve interaction feedback eksikliği fail condition olabilir.

PASS için aynı anda:

* final score en az 93/100
* her dimension en az 8/10
* fail condition yok
* required runtime/motion evidence tam

Bu eşiklerden biri sağlanmıyorsa PASS yazma.

## Visual Quality Verdict

Bu exact başlık zorunludur:

| Rubric Dimension | Score / 10 | Runtime Evidence | Notes |
| --- | --- | --- | --- |
| Experience Fit | `{score}` | `{evidence id}` | `{notes}` |
| Visual Hierarchy | `{score}` | `{evidence id}` | `{notes}` |
| Layout, Rhythm and Responsiveness | `{score}` | `{evidence id}` | `{notes}` |
| Typography and Content Craft | `{score}` | `{evidence id}` | `{notes}` |
| Color, Surface and Asset System | `{score}` | `{evidence id}` | `{notes}` |
| Interaction, State and Feedback | `{score}` | `{evidence id}` | `{notes}` |
| Motion and Sensory Quality | `{score}` | `{evidence id}` | `{notes}` |
| Originality and Product Identity | `{score}` | `{evidence id}` | `{notes}` |
| Accessibility and Inclusive Quality | `{score}` | `{evidence id}` | `{notes}` |
| Implementation Fidelity and Polish | `{score}` | `{evidence id}` | `{notes}` |

Final Score: `{score} / 100`

Lowest Dimension: `{name} — score / 10`

Fail Conditions: `None / {list}`

Runtime Evidence Complete: `Yes / No`

Result: `PASS / FAIL / PENDING`
