# looplet_dictionary

Language-scoped word validation for LOOPLET (feature F01). Pure Dart.

## Use

```dart
final service = await DictionaryService.load(
  language: LanguageCode.tr,
  assetSource: myAssetSource, // rootBundle-backed in the app; fake in tests
);
service.isValidWord('MASAL', minLength: 4); // true
service.isEligibleTarget('masal');          // true (curated 5-letter target)
service.normalize('  KİTAP ');               // 'kitap'
service.isFailSafe;                          // true only if the asset was missing/corrupt/empty
```

Contract: `ai-system/features/f01-dictionary-service/architecture.md`.

## Assets

`assets/tr/dictionary.json` (provisional hand-curated list — replace with the
reviewed corpus per the F01 PRD Open Questions) and `assets/en/dictionary.json`
(stub). Shape:

```json
{ "schemaVersion": 1, "language": "tr", "words": [...], "targets": [...], "exclusionsApplied": [...] }
```

The package declares these under a `flutter:` `assets:` section in its own
`pubspec.yaml`, so any Flutter app depending on this package gets them in the
bundle automatically as `packages/looplet_dictionary/assets/<lang>/dictionary.json`.
The app provides a `rootBundle`-backed `DictionaryAssetSource`
(`app/lib/dictionary/root_bundle_asset_source.dart`); the app pubspec does **not**
re-declare the assets.
