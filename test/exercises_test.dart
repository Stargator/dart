import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

/// Constants
const String envName = 'EXERCISE';
const String practiceExcercisesDir = 'exercises/practice';

/// Helpers
void runCmd(List<String> cmds) {
  final cmd = cmds.first;
  final other = cmds.skip(1).toList();

  final res = Process.runSync(cmd, other, runInShell: true);

  if (res.stdout.toString().isNotEmpty) {
    stdout.write(res.stdout);
  }

  if (res.stderr.toString().isNotEmpty) {
    stderr.write(res.stderr);
  }

  assert(res.exitCode == 0);
}

String getPackageName() {
  final pubspecFile = File('pubspec.yaml');

  final pubspecAsString = pubspecFile.readAsStringSync();

  final packageName = loadYaml(pubspecAsString)['name'] as String;

  return packageName;
}

void locateExercismDirAndExecuteTests() {
  final exercisesRootDir = Directory(practiceExcercisesDir);

  assert(exercisesRootDir.existsSync());

  final exercisesDirs = exercisesRootDir.listSync().whereType<Directory>();

  /// Sort directories alphabetically
  final sortedExerciseDirs = exercisesDirs.toList()..sort((a, b) => a.path.compareTo(b.path));

  for (var dir in sortedExerciseDirs) {
    runTest(dir.path);
  }
}

/// Execute a single test
void runTest(String path) {
  final current = Directory.current;

  Directory.current = path;

  final packageName = getPackageName();

  print('''
================================================================================
Running tests for: $packageName
================================================================================
''');

  var stub = File('lib/$packageName.dart');
  var example = File('.meta/lib/example.dart');

  try {
    stub = stub.renameSync('lib/$packageName.dart.bu');
    example = example.renameSync('lib/$packageName.dart');

    // ignore: prefer_foreach
    for (var cmds in [
      /// Upgrade dependencies
      ['pub', 'upgrade'],

      /// Run all exercise tests
      ['pub', 'run', 'test', '--run-skipped']
    ]) {
      runCmd(cmds);
    }
  } finally {
    example.renameSync('.meta/lib/example.dart');
    stub.renameSync('lib/$packageName.dart');

    Directory.current = current;
  }
}

/// Execute all the tests under the exercise directory
void runAllTests() {
  final dartExercismRootDir = Directory('..');

  assert(dartExercismRootDir.existsSync());

  locateExercismDirAndExecuteTests();

  Directory.current = dartExercismRootDir.parent;

  final packageName = getPackageName();

  print('''

================================================================================
Running tests for: $packageName
================================================================================
''');
}

void main() {
  final testName = Platform.environment[envName];

  test('Exercises', () {
    if (testName == null) {
      runAllTests();
    } else {
      final testPath = '${Directory.current.path}/$practiceExcercisesDir/$testName';

      if (!Directory(testPath).existsSync()) {
        throw ArgumentError('No exercise with this name: $testName');
      }

      runTest(testPath);
    }
  }, timeout: const Timeout(Duration(minutes: 20)));
}
