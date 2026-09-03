# infra/

Firebase project config + Cloud Functions (TypeScript) for LOOPLET's three
backend surfaces: daily content distribution, analytics ingestion, and the
offline daily-result sync callable (`ai-system/project-authority/platform.md` §3).

**Not scaffolded during F01.** This workspace is provisioned as a separate
Project Setup pass (DURUM 0), re-triggered by the Tech Lead when the first
backend feature (F07 / F08 / F12) starts. Do not add Firebase packages to
`app/` or create function code here before then.
