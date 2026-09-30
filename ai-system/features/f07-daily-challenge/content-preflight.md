# F07 content preflight — 2026-09-30

Status: source/design preflight completed; production corpus, pilot, pool and independent QA NOT accepted. Executed in the user-authorized implementation session, not a claimed separate Content Designer or QA agent run.

## Source evidence

Pinned [Zemberek NLP](https://github.com/ahmetaa/zemberek-nlp/tree/330be8eeba61e17647cfc7e19206b01174f25b44) resources were retrieved read-only and vendored in `tools/looplet_authoring/data/tr/sources/zemberek/`. `source.json` records URLs, commit, bytes and SHA-256 for master-dictionary.dict, first-10K and LICENSE. The repository distributes these resources with its Apache 2.0 license notice; retain attribution and the notice. A source being a dictionary does not imply every entry is suitable for a casual game.

Reproducible preliminary count: first token of master lines; lowercase Turkish letters including â/î/û; lengths 4–5; deduplicated: **6,778** candidates (4,818 length five). Intersection with the ordered first-10K resource: **1,198** (768 length five). First 1,000 positions contain 109 candidates; first 5,000 contain 645. This is source position, not a proven frequency percentile: upstream corpus/methodology is not established. No claim of frequency verification is made.

Existing runtime corpus: 103 words, 30 targets, only 84 words of length 4–5. All legitimate existing words and all Journey targets remain compatibility inputs. A five-letter source pool of 768 makes ≥90 additional targets plausible, but source counts are NOT editorial acceptance. Proper-name readings, inflected forms and rare words occur in the intersection. Automatic bulk acceptance would reproduce the original defect.

## Curation contract

Use a versioned explicit allowlist with source entry and short meaning/review rationale for every new word. No word enters merely for being in first-10K. Choose common contemporary everyday nouns/adjectives/verbs in dictionary citation form; reject proper-only names, abbreviations, slurs/profanity, archaic/rare vocabulary and unexplained inflections. Quarantine ambiguity instead of silently normalizing it. Existing spelling exceptions are explicit compatibility records, not permission to rewrite new words.

Targets: five letters, readily understood without a clue, varied themes and initials, no Journey reuse for Daily. Review all targets. Supporting words: same safety/commonness standard; no padding to reach 2,000. The initial curated candidate corpus may be smaller; pilot yield must determine whether it is sufficient. Import/audit compares source hashes, allowlist, exclusions, target subset, alphabet and preserved legacy entries. Record AI editorial review honestly; independent QA remains outstanding.

QA examines all new targets and at least 100 supporting words (or all if fewer), covering source rank bands, Turkish dotted/dotless I, diacritics and compatibility exceptions. A critical error expands review to the affected group. Every accepted puzzle receives a reasoned review of its actual replay: meaningful choices, visible thaw opportunities, readable filler and distinct solution idea.

## Pilot and measurement

Eight accepted examples, two each open/locked/frozen/both; weekday optimum 4–5 and weekend 5–7, medium/hard only. Cover useful thaw, proven temporary regression and Turkish letters. Do not substitute eight attempted examples for eight accepted examples. Named negative fixtures exercise every required condition; pilot acceptance requires forward engine replay, each-mechanic ablation, bounded all-path claims, final-state filler and source/banlist checks. Q9 is advisory; Q7 pool ratio and partial ISO weeks retain revision 2 semantics.

Initial ceiling: 200 attempts per mechanic class; 30 seconds / 5 million states / depth 16 per search. Measure rejection/UNKNOWN by rule, elapsed time and acceptance rate. Keep rejected candidates outside canonical content. Stop a bounded run with explicit incomplete evidence; investigate inputs/search/constructive generation before increasing budget. Batch work cannot activate until the real pilot passes a Tech Lead checkpoint.

## Developer readiness gaps / checkpoint

The current solver's optimal enumeration and difficulty full-tree traversal are unbounded, and sampled paths cannot prove regression. Permanent tools must bound these surfaces; expose incomplete enumeration; provide real-engine constrained and joint counterfactual searches; record fingerprints and negative controls. Existing pack-daily can package the rejected old pool, so missing/stale quality proof must block production packing. Development fixtures must be explicitly separate.

Tech Lead checkpoint in this same authorized session: accept this preflight as an implementation input; activate F07-TOOL-DAILY. No corpus/pilot/batch acceptance is implied. Tool development may use provisional curated inputs outside the runtime asset. F08 deployment remains paused.
