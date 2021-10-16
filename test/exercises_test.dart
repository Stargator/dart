import 'dart:async';
import 'dart:io';

import 'package:exercism_dart/src/utils.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

/// Constants
const String envName = 'EXERCISE';
const String practiceExcercisesDir = 'exercises/practice';

/// Helpers
Future<String> getPackageName() async {
  final pubspec = File('pubspec.yaml');

  final String pubspecString = await pubspec.readAsString();

  final String packageName = loadYaml(pubspecString)['name'] as String;

  return packageName;
}

/// Execute a single test
Future runTest(String path) async {
  final current = Directory.current;

  Directory.current = path;

  final packageName = await getPackageName();

  print('''
================================================================================
Running tests for: $packageName
================================================================================
''');

  replaceStubsWithExamples(packageName, current);
}

/// Execute all the tests under the exercise directory
Future runAllTests() async {
  final dartExercismRootDir = Directory('..');

  assert(await dartExercismRootDir.exists());

  final orderedExercismDirs = await locateExercismDir(practiceExcercisesDir);

  for (FileSystemEntity dir in orderedExercismDirs) {
    await runTest(dir.path);
  }

  Directory.current = dartExercismRootDir.parent;

  final packageName = await getPackageName();

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

      if (!await Directory(testPath).exists()) {
        throw ArgumentError('No exercise with this name: $testName');
      }

      await runTest(testPath);
    }
  }, timeout: Timeout(Duration(minutes: 20)));
}
