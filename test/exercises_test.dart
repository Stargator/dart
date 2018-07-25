import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

/// Constants
const String envName = 'EXERCISE';
const String practiceExcercisesDir = 'exercises/practice';

/// Helpers
Future runCmd(List<String> cmds) async {
  final cmd = cmds.first;
  final other = cmds.skip(1).toList();

  final res = await Process.run(cmd, other, runInShell: true);

  if (res.stdout.toString().isNotEmpty) {
    stdout.write(res.stdout);
  }

  if (res.stderr.toString().isNotEmpty) {
    stderr.write(res.stderr);
  }

  assert(res.exitCode == 0);
}

Future<String> _getPackageName() async {
  final pubspec = File('pubspec.yaml');

  final pubspecString = await pubspec.readAsString();

  final packageName = loadYaml(pubspecString)['name'] as String;

  return packageName;
}

Future _locateExercismDirAndExecuteTests() async {
  final exercisesRootDir = Directory(practiceExcercisesDir);

  assert(exercisesRootDir.existsSync());

  final exercisesDirs = exercisesRootDir.listSync().where((d) => d is Directory);

  /// Sort directories alphabetically
  final sortedExerciseDirs = exercisesDirs.toList()..sort((a, b) => a.path.compareTo(b.path));

  for (final dir in sortedExerciseDirs) {
    await runTest(dir.path);
  }
}

/// Execute a single test
Future runTest(String path) async {
  final current = Directory.current;

  Directory.current = path;

  final packageName = await _getPackageName();

  print('''
================================================================================
Running tests for: $packageName
================================================================================
''');

  var stub = File('lib/$packageName.dart');
  var example = File('.meta/lib/example.dart');

  try {
    stub = await stub.rename('lib/$packageName.dart.bu');
    example = await example.rename('lib/$packageName.dart');

    for (final cmds in [
      /// Pull dependencies
      ['dart', 'pub', 'upgrade'],

      /// Run all exercise tests
      ['dart', 'test', '--run-skipped']
    ]) {
      await runCmd(cmds);
    }
  } finally {
    await example.rename('.meta/lib/example.dart');
    await stub.rename('lib/$packageName.dart');

    Directory.current = current;
  }
}

/// Execute all the tests under the exercise directory
Future runAllTests() async {
  final dartExercismRootDir = Directory('..');

  assert(dartExercismRootDir.existsSync());

  await _locateExercismDirAndExecuteTests();

  Directory.current = dartExercismRootDir.parent;

  final packageName = await _getPackageName();

  print('''

================================================================================
Running tests for: $packageName
================================================================================
''');
}

void main() {
  final testName = Platform.environment[envName];

  test('Exercises', () async {
    if (testName == null) {
      await runAllTests();
    } else {
      final testPath = '${Directory.current.path}/$practiceExcercisesDir/$testName';

      if (!Directory(testPath).existsSync()) {
        throw ArgumentError('No exercise with this name: $testName');
      }

      await runTest(testPath);
    }
  }, timeout: const Timeout(Duration(minutes: 20)));
}
