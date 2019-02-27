import 'dart:async';
import 'dart:io';
import 'package:dart2_constant/convert.dart' show utf8;

Future<int> main() async {
//  final cdProcess = await Process.start('pwd', <String>[], runInShell: false);
//  cdProcess.stdout.transform(UTF8.decoder).listen(print);
//  cdProcess.stderr.transform(UTF8.decoder).listen(print);
//  await cdProcess.exitCode;
//
  final lsProcess = await Process.start('ls', <String>['-la'], runInShell: false);
  lsProcess.stdout.transform(utf8.decoder).listen(print);
  lsProcess.stderr.transform(utf8.decoder).listen(print);
  await lsProcess.exitCode;

  final process = await Process.start(
      'find', <String>['.', '-type', 'd', '-name', '\".pub\"', '-delete', '-exec', 'rm', '-R', '\"{}\"', '\;'],
      runInShell: false);
  process.stdout.transform(utf8.decoder).listen(print);
  process.stderr.transform(utf8.decoder).listen(print);
  return await process.exitCode;
}
