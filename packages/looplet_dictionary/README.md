# looplet_dictionary

Language-scoped word validation for LOOPLET (feature F01).

## Status

Scaffold. Public API and asset format are specified in
`ai-system/features/f01-dictionary-service/architecture.md`. Implementation
starts at F01.2-FE.

## Assets

`assets/tr/dictionary.json` and `assets/en/dictionary.json` (authored in
F01.6-FE) follow the shape in the architecture doc:

```json
{ "schemaVersion": 1, "language": "tr", "words": [...], "targets": [...], "exclusionsApplied": [...] }
```

Because this is a **pure-Dart** package, it cannot bundle Flutter assets
itself. The app is responsible for making the files readable at runtime:
`app/pubspec.yaml` must declare

```yaml
flutter:
  assets:
    - packages/looplet_dictionary/assets/tr/
    - packages/looplet_dictionary/assets/en/
```

and provide a `DictionaryAssetSource` backed by `rootBundle` (wired in F01.2-FE).
Tests inject a fake `DictionaryAssetSource` and read fixture files directly.
