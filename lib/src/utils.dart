import 'dart:async';
import 'dart:io';
import 'package:io/io.dart';

class CommonUtils {
  final ProcessManager _manager = ProcessManager();

  /// Fetches the configlet file if it doesn't exist already, and returns the
  /// exit code.
  Future<int> fetchConfiglet() async {
    final configletFile = File('bin/configlet');

    if (!configletFile.existsSync()) {
      print('Fetching configlet...');
      return _exit(await runCmdIfExecutable('bin/fetch-configlet'));
    }

    return 0;
  }

  /// Returns a [Future] with the exit code resulting from running the
  /// [executable] with [arguments].
  Future<int> runCmd(String executable, [List<String> arguments = const []]) async {
    final spawn = await _manager.spawn(executable, arguments);
    return _exit(await spawn.exitCode);
  }

  /// Returns a [Future] with the exit code resulting from running the
  /// [executable] with [arguments].
  ///
  /// If [executable] isn't executable, returns a [Future] with exit code 1 and
  /// shows an error message.
  Future<int> runCmdIfExecutable(String executable, [List<String> arguments = const []]) async {
    final result = isExecutable(executable);

    if (result is bool && !result || result is Future && !await result) {
      print('Unable to run "$executable". Make sure that it\'s executable and that you have permissions to run it.');
      return Future.value(1);
    }

    return runCmd(executable, arguments);
  }

  /// Terminates the global `stdin` listener.
  Future<Null> terminate() async {
    await ProcessManager.terminateStdIn();
  }
}

/// Returns [exitCode] and shows an error message if it is different from 0.
int _exit(int exitCode) {
  if (exitCode != 0) print('Failed. Error code: $exitCode.');
  return exitCode;
}

Future<List<FileSystemEntity>> locateExercismDir(String exercisesDir) async {
  final exercisesRootDir = Directory(exercisesDir);

  assert(await exercisesRootDir.exists());

  final exercisesDirs = exercisesRootDir.listSync().where((d) => d is Directory);

  /// Sort directories alphabetically
  final sortedExerciseDirs = exercisesDirs.toList();
  sortedExerciseDirs.sort((a, b) => a.path.compareTo(b.path));

  return sortedExerciseDirs;
}

Future replaceStubsWithExamples(String packageName, Directory currentDir) async {
  File stub = File('lib/${packageName}.dart');
  File example = File('.meta/lib/example.dart');

  try {
    stub = await stub.rename('lib/${packageName}.dart.bu');
    example = await example.rename('lib/${packageName}.dart');

    for (List<String> cmds in [
      /// Pull dependencies
      ['dart', 'pub', 'upgrade'],

      /// Run all exercise tests
      ['dart', 'test', '--run-skipped']
    ]) {
      await runCmd(cmds);
    }
  } finally {
    await example.rename('.meta/lib/example.dart');
    await stub.rename('lib/${packageName}.dart');

    Directory.current = currentDir;
  }
}

Future runCmd(List<String> cmds) async {
  final cmd = cmds.first;
  final other = cmds.skip(1).toList();

  final res = await Process.run(cmd, other, runInShell: true);

  if (!res.stdout.toString().isEmpty) {
    stdout.write(res.stdout);
  }

  if (!res.stderr.toString().isEmpty) {
    stderr.write(res.stderr);
  }

  assert(res.exitCode == 0);
}
