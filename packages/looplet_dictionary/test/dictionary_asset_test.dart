import 'package:looplet_dictionary/looplet_dictionary.dart';
import 'package:test/test.dart';

void main() {
  DictionaryAsset parse(String json) =>
      DictionaryAsset.parse(json, expectedLanguage: LanguageCode.tr);

  test('parses a well-formed asset', () {
    final asset = parse(
      '{"schemaVersion":1,"language":"tr","words":["masal"],"targets":["masal"],'
      '"exclusionsApplied":["profanity"]}',
    );
    expect(asset.schemaVersion, 1);
    expect(asset.language, 'tr');
    expect(asset.words, <String>['masal']);
    expect(asset.targets, <String>['masal']);
    expect(asset.exclusionsApplied, <String>['profanity']);
  });

  test('exclusionsApplied is optional', () {
    final asset = parse(
      '{"schemaVersion":1,"language":"tr","words":["masal"],"targets":[]}',
    );
    expect(asset.exclusionsApplied, isEmpty);
  });

  test('rejects invalid JSON', () {
    expect(() => parse('{not json'), throwsFormatException);
  });

  test('rejects a non-object root', () {
    expect(() => parse('[]'), throwsFormatException);
    expect(() => parse('"x"'), throwsFormatException);
  });

  test('rejects an unsupported schemaVersion', () {
    expect(
      () =>
          parse('{"schemaVersion":2,"language":"tr","words":[],"targets":[]}'),
      throwsFormatException,
    );
    expect(
      () => parse(
          '{"schemaVersion":"1","language":"tr","words":[],"targets":[]}'),
      throwsFormatException,
    );
  });

  test('rejects a language mismatch', () {
    expect(
      () =>
          parse('{"schemaVersion":1,"language":"en","words":[],"targets":[]}'),
      throwsFormatException,
    );
  });

  test('rejects words/targets that are not string arrays', () {
    expect(
      () =>
          parse('{"schemaVersion":1,"language":"tr","words":{},"targets":[]}'),
      throwsFormatException,
    );
    expect(
      () =>
          parse('{"schemaVersion":1,"language":"tr","words":[1],"targets":[]}'),
      throwsFormatException,
    );
  });
}
