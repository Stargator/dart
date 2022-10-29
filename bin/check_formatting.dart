import 'dart:async';
import 'package:exercism_dart/src/utils.dart';

Future<Null> main() async {
  final utils = CommonUtils();
  var errorCode = 0;

  print('Checking all Dart files formatting...');
  errorCode = await utils
      .runCmd('dart', ['run', 'dart_style:format', '-i', '0', '-l', '120', '-n', '--set-exit-if-changed', '.']);

  if (errorCode != 0) {
    print('Checking exercise formatting failed!!');
    await utils.terminate();
    throw StateError('Formatting failed.');
  }

  await utils.terminate();
}
