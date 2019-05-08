import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../bin/create_exercise_new.dart';

Future main() {
  group('create-exercise tool', () {
// Evaluate Arguments
// * If no arguments, write an error to the console;

//X Check if the specPath is valid, if the required contents are in the directory
// Check if the specPath has a .deprecated file, exit out and print out a message.

// Check if the exercise already exists, if it does look for a .meta folder and determine the version in the pubspec.yaml

// If the version exists, check if the spec is a newer version than the current one.
// If the version does not exist, specPath has the required contents, specPath does not have a .deprecated file, then proceed with generation
//
// For generation, need exercise name, read in of canonical-data.json mapped to Test Suite
// Apply Test Suite class to templates
//
// Desire for the end product to allow dependent libraries to be mocked in order to allow testing of main function without

    group('evaluate arguments', () {
      test('parse through arguments', () {
        final List<String> passedArgs = <String>['--spec-path=test/resources', 'exercise-name'];
        ArgResults processedArgs = parseArguments(passedArgs);

        expect(processedArgs.arguments, equals(passedArgs));
        expect(processedArgs.rest, equals(passedArgs.sublist(1)));
        expect(exerciseName, equals(passedArgs[1]));
      });

      test('no arguments passed', () async {
        ArgResults processedArgs = parseArguments(<String>[]);
        MockLogger stderr;
      }, skip: true);
    });

    group('create test suite from specification', () {
      final specPath = 'test/resources';

      test('read spec directory', () async {
        Directory specDir = await getSpecDir(specPath, 'acronym');
        expect(await specDir.exists(), equals(true));
      });

      test('check that spec directory has all required files', () async {
        Directory specDir = await getSpecDir(specPath, 'acronym');
        expect(await hasRequiredFiles(specDir), equals(true));
      });

      test('check that spec directory has a .deprecated file', () async {
        final exerciseName = 'binary';
        Directory specDir = await getSpecDir(specPath, exerciseName);
        final deprecatedError = predicate(
            (AssertionError e) => e is AssertionError && e.message == 'The given exercise has been deprecated',
            'a AssertionError with the message "The given exercise has been deprecated"');

        expect(() => hasRequiredFiles(specDir), throwsA(deprecatedError));
      }, skip: true);

      test('get target exercise path', () async {
        final exerciseName = 'acronym';
        Directory targetDir = await getTargetDir(exerciseName);

        expect(targetDir.path, equals('exercises/$exerciseName'));
      });

      test('get version number of already existing exercise')
    });
  });
}

class MockLogger extends Mock implements Logger {}
