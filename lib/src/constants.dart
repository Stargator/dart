import "package:args/args.dart";

const String scriptFilename = "create-exercise";

final parser = new ArgParser()
  ..addSeparator("Usage: $scriptFilename [--spec-path path] <slug>")
  ..addOption("spec-path", help: "The location of the problem-specifications directory.", valueHelp: 'path');

