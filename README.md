# LOOPLET

A mobile word-based logic puzzle. The player slides rows and columns of a 5×5
letter grid to form a visible target word in the fewest moves. See
`ai-system/product/product-prd.md` for the full product definition.

## Monorepo layout

| Path | What |
| --- | --- |
| `app/` | Flutter application (iOS + Android, portrait) |
| `packages/looplet_core/` | shared value types, Turkish-locale case utility |
| `packages/looplet_dictionary/` | curated word list + validation service (F01) |
| `packages/looplet_engine/` | deterministic grid model / shift / win detection (F02) |
| `packages/looplet_content/` | puzzle definition models + JSON serialization |
| `packages/looplet_solver/` | minimum-move solver library (F06) |
| `tools/looplet_authoring/` | level-authoring CLI (F06) |
| `content/` | versioned puzzle JSON artifacts |
| `infra/` | Firebase config + Cloud Functions (provisioned later) |

Domain packages (`looplet_*`) are pure Dart and import neither Flutter nor Firebase.

## Prerequisites

- Flutter stable (Dart SDK 3.4+)
- melos: `dart pub global activate melos ^6.0.0`

## Canonical commands

Authoritative source: `ai-system/project-authority/setup-manifest.md`.

```sh
melos bootstrap          # resolve all package dependencies (run after any pubspec change)
melos run format:check   # fail if code is not formatted
melos run analyze        # static analysis (all packages + flutter analyze)
melos run test           # unit tests (pure-Dart packages) + flutter test (app)
melos run build:app      # release Android App Bundle
melos exec --scope="looplet_app" -- "flutter run"   # dev run
```
