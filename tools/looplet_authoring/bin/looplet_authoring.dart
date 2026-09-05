import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:looplet_authoring/looplet_authoring.dart';

Future<void> main(List<String> args) async {
  try {
    final code = await buildRunner().run(args) ?? 0;
    exit(code);
  } on UsageException catch (e) {
    stderr.writeln(e);
    exit(64);
  }
}
