import 'dart:io';

import 'package:looplet_authoring/src/corpus_quality.dart';
import 'package:looplet_authoring/src/quality_io.dart';
import 'package:test/test.dart';

const data = 'data/tr';
void main() {
  test('source-checked import preserves legacy and supplies target coverage',
      () {
    final asset = importCorpus(data);
    final legacy = readObject('$data/legacy-dictionary.json');
    expect(asset['words'], containsAll(legacy['words'] as List));
    expect(asset['targets'], containsAll(legacy['targets'] as List));
    expect((asset['targets'] as List).length, greaterThanOrEqualTo(120));
    expect(auditCorpus(data, asset), isEmpty);
    expect((asset['words'] as List).where((w) => (w as String).length < 4),
        isNotEmpty);
    final words = CorpusWords(asset);
    expect(words.isValidWord('ISLAK'), true);
    expect(words.isValidWord('İSLAK'), false);
    expect(words.isValidWord('LEĞEN', minLength: 5), true);
  });
  test('duplicate, missing legacy and uncurated injected words fail', () {
    final asset = importCorpus(data);
    (asset['words'] as List).add((asset['words'] as List).first);
    expect(auditCorpus(data, asset), contains('words duplicate'));
    (asset['words'] as List)
      ..remove('buz')
      ..add('uydur');
    expect(auditCorpus(data, asset),
        contains('words differ from sourced curation/legacy preservation'));
  });
  test('source hash tampering is rejected before any import', () {
    final temp = Directory.systemTemp.createTempSync('looplet_corpus');
    addTearDown(() => temp.deleteSync(recursive: true));
    for (final file
        in Directory(data).listSync(recursive: true).whereType<File>()) {
      final path = '${temp.path}/${file.path.substring(data.length + 1)}';
      File(path).parent.createSync(recursive: true);
      file.copySync(path);
    }
    File('${temp.path}/sources/zemberek/master-dictionary.dict')
        .writeAsStringSync('uydur\n');
    expect(() => importCorpus(temp.path), throwsFormatException);
  });
  test('curation cannot admit quarantined word or lose target rationale', () {
    final temp = Directory.systemTemp.createTempSync('looplet_curation');
    addTearDown(() => temp.deleteSync(recursive: true));
    for (final file
        in Directory(data).listSync(recursive: true).whereType<File>()) {
      final path = '${temp.path}/${file.path.substring(data.length + 1)}';
      File(path).parent.createSync(recursive: true);
      file.copySync(path);
    }
    final curation = readObject('${temp.path}/curation.json');
    final entry = (curation['accepted'] as List).first as Map;
    entry['review'] = '';
    writeObject('${temp.path}/curation.json', curation);
    expect(() => importCorpus(temp.path), throwsFormatException);
    entry['review'] = 'Common everyday word: explicit review';
    (curation['quarantine'] as List)
        .add({'word': entry['word'], 'reason': 'uncertain'});
    writeObject('${temp.path}/curation.json', curation);
    expect(() => importCorpus(temp.path), throwsFormatException);
  });
}
