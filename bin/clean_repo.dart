import 'dart:async';
import 'dart:io';
import 'package:dart2_constant/convert.dart' show utf8;

/// Cleans all generated files
void main() {
  print(Directory.current.path);
  removeItem('.dart_tool', isDirectory: true)
      .then((exitCode) => removeItem('build', isDirectory: true))
      .then((exitCode) => removeItem('.pub', isDirectory: true))
      .then((exitCode) => removeItem('.packages'))
      .then((exitCode) => removeItem('pubspec.lock'));
}

/// Removes .dart_tool/, .pub/, .packages, and pubspec.lock from exercises.
Future<int> removeItem(String itemName, {bool isDirectory = false}) async {
  var itemType = 'f';

  if (isDirectory) {
    itemType = 'd';
  }

  final fileProcessOptions = <String>['.', '-type', itemType, '-name', itemName, '-delete']; // WORKS
  final directoryProcessOptions = <String>[
    '.',
    '-type',
    itemType,
    '-name',
    itemName,
    '-delete',
    '-exec',
    'rm',
    '-r',
    '"{}"',
    '\\;'
  ];

  if (isDirectory) {
    print('DIRECTORY -> find ${directoryProcessOptions}'.replaceAll('[', '').replaceAll(']', '').replaceAll(',', ''));
  } else {
    print('FILE ->      find ${fileProcessOptions}'.replaceAll('[', '').replaceAll(']', '').replaceAll(',', ''));
  }

  if (isDirectory) {
    final process = await Process.start('find', directoryProcessOptions, runInShell: false);
    process.stdout.transform(utf8.decoder).listen(print);
    process.stderr.transform(utf8.decoder).listen(print); //
    return await process.exitCode;
  } else {
    final process = await Process.start('find', fileProcessOptions, runInShell: true);
    process.stdout.transform(utf8.decoder).listen(print);
    process.stderr.transform(utf8.decoder).listen(print);
    return await process.exitCode;
  }
}
