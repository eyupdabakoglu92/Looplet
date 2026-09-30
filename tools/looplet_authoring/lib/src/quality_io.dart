import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

Map<String, dynamic> readObject(String path) {
  final value = jsonDecode(File(path).readAsStringSync());
  if (value is! Map<String, dynamic>) {
    throw FormatException('Expected object: $path');
  }
  return value;
}

bool jsonEquivalent(Object? a, Object? b) {
  if (a is Map && b is Map) {
    if (a.length != b.length || !a.keys.every(b.containsKey)) return false;
    return a.keys.every((key) => jsonEquivalent(a[key], b[key]));
  }
  if (a is List && b is List) {
    return a.length == b.length &&
        [for (var i = 0; i < a.length; i++) jsonEquivalent(a[i], b[i])]
            .every((same) => same);
  }
  return a == b;
}

void writeObject(String path, Object value) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  final temporary = File('$path.tmp');
  temporary.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(value)}\n');
  temporary.renameSync(file.path);
}

String fileHash(String path) =>
    sha256.convert(File(path).readAsBytesSync()).toString();

List<File> jsonFiles(String dir) {
  if (!Directory(dir).existsSync()) return [];
  return Directory(dir)
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

/// Bind evidence to all algorithm/rule/corpus inputs and exact source bytes.
/// No timestamps, VCS cleanliness assumptions, or self-referential report hash.
Map<String, String> qualityFingerprint(String repoRoot, String? sourceDir) {
  final result = <String, String>{
    'runtime/dart': sha256.convert(utf8.encode(Platform.version)).toString()
  };
  void addTree(String label, String path) {
    final files = File(path).existsSync()
        ? [File(path)]
        : Directory(path)
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()
            .toList();
    for (final file in files) {
      final rel =
          File(path).existsSync() ? '' : p.relative(file.path, from: path);
      if (rel.split(p.separator).any((s) => s.startsWith('.'))) continue;
      result['$label/$rel'] = fileHash(file.path);
    }
  }

  for (final path in [
    'packages/looplet_core/lib',
    'packages/looplet_dictionary/lib',
    'packages/looplet_engine/lib',
    'packages/looplet_solver/lib',
    'packages/looplet_content/lib',
    'tools/looplet_authoring/lib',
    'tools/looplet_authoring/bin',
    'tools/looplet_authoring/data',
    'tools/looplet_authoring/pubspec.yaml',
    'tools/looplet_authoring/pubspec.lock',
    'packages/looplet_dictionary/assets/tr/dictionary.json',
    'content/journey',
    'content/smoke',
    'ai-system/features/f07-daily-challenge/daily-content-spec.md',
  ]) {
    addTree(path, p.join(repoRoot, path));
  }
  for (final package in [
    'looplet_core',
    'looplet_dictionary',
    'looplet_engine',
    'looplet_solver',
    'looplet_content'
  ]) {
    addTree('packages/$package/pubspec.yaml',
        p.join(repoRoot, 'packages/$package/pubspec.yaml'));
  }
  final overrides =
      p.join(repoRoot, 'tools/looplet_authoring/pubspec_overrides.yaml');
  result['authoring/dependency-overrides'] =
      File(overrides).existsSync() ? fileHash(overrides) : 'absent';
  // Only known source surfaces; reports are deliberately stored outside them.
  if (sourceDir != null) {
    for (final path in ['pool', 'defs', 'proofs']) {
      addTree('daily/$path', p.join(sourceDir, path));
    }
    addTree('daily/manifest', p.join(sourceDir, 'daily_manifest_tr.json'));
  }
  final keys = result.keys.toList()..sort();
  return {for (final key in keys) key: result[key]!};
}

/// Portable report path: relative to the repository root, `/`-separated.
String repoRelative(String repoRoot, String path) =>
    p.posix.joinAll(p.split(p.relative(p.normalize(p.absolute(path)),
        from: p.normalize(p.absolute(repoRoot)))));

/// Resolves a report's repo-relative source path; absolute or missing paths
/// fail closed (a report from another host must not point outside the repo).
String resolveReportSource(String repoRoot, Object? recorded) {
  if (recorded is! String || recorded.isEmpty || p.isAbsolute(recorded)) {
    throw StateError('report sourceDir must be repo-relative: $recorded');
  }
  final resolved = p.normalize(p.join(repoRoot, recorded));
  if (!Directory(resolved).existsSync()) {
    throw StateError('report sourceDir does not resolve: $recorded');
  }
  return resolved;
}

String fingerprintHash(Map<String, String> files) =>
    sha256.convert(utf8.encode(jsonEncode(files))).toString();

/// Typed navigation at the JSON boundary. Missing/non-object parents yield
/// null; callers compare exact expected values and therefore fail closed.
Object? jsonValue(Object? value, String path) {
  for (final key in path.split('.')) {
    if (value is! Map<String, dynamic>) return null;
    value = value[key];
  }
  return value;
}

Map<String, dynamic> jsonMap(Object? value) =>
    (value as Map).cast<String, dynamic>();
List<Map<String, dynamic>> jsonMaps(Object? value) =>
    (value as List).map(jsonMap).toList();
