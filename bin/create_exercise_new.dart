import "dart:async";
import "dart:io";

import '../lib/src/constants.dart';
import '../lib/src/helpers.dart';
import '../lib/src/templates.dart';
import 'package:args/args.dart';
import "package:dart2_constant/convert.dart" as polyfill;
import 'package:logging/logging.dart';
import "package:path/path.dart" show dirname;

String exerciseName;
final Logger logger = new Logger(scriptFilename);
bool inTestMode;

Future<bool> hasRequiredFiles(Directory specDir) async {
  bool determination = false;
  bool hasDescriptionFile = false;
  bool hasCanonicalDataFile = false;
  bool hasMetadataFile = false;
  final List<FileSystemEntity> contents = await specDir.list(followLinks: false).toList();

  if (contents.length >= 3) {
    for(int count = 0; count < contents.length; count++) {
      FileSystemEntity entity = contents[count];
      if (await FileSystemEntity.isFile(entity.path)) {
        if (entity.path.contains('description.md')) {
          hasDescriptionFile = true;
        } else if (entity.path.contains('canonical-data.json')) {
          hasCanonicalDataFile = true;
        } else if (entity.path.contains('metadata.yml')) {
          hasMetadataFile = true;
        } else if (entity.path.contains('.deprecated')) {
          scriptFailure('The given exercise has been deprecated');
        }
      }
    }
    determination = hasDescriptionFile && hasCanonicalDataFile && hasMetadataFile;
  }

  return determination;
}

Future<Directory> getSpecDir(String specPath, String exerciseName) async {
  Directory pathDir = new Directory('$specPath/exercises/$exerciseName');

  if (await pathDir.exists() == false) {
    scriptFailure('Could not find: ${pathDir.path}');
  }

  return pathDir;
}

Directory getTargetDir(String exerciseName) => new Directory('exercises/$exerciseName');

void scriptFailure(String message) {
  logger.severe(message);
  exit(1);
}

ArgResults parseArguments(List<String> args) {
  final arguments = parser.parse(args);
  final restArgs = arguments.rest;

  if (restArgs.isEmpty) {
    scriptFailure(parser.usage);
  }

  exerciseName = restArgs.first;

  return arguments;
}

void setTestMode(bool turnTestModeOn) => inTestMode = turnTestModeOn;

Future main(List<String> args) async {
  final arguments = parseArguments(args);

  // Create dir
  final currentDir = Directory.current;
  final exerciseDir = new Directory("exercises/${kebabCase(exerciseName)}");
  final filename = snakeCase(exerciseName);

  // Get test cases from canonical-data.json, format tests
  if (arguments["spec-path"] != null) {
    String filename = "${arguments['spec-path']}/exercises/$exerciseName/canonical-data.json";
    try {
      final File canonicalDataJson = new File(filename);
      final source = await canonicalDataJson.readAsString();
      final Map<String, Object> specification = polyfill.json.decode(source) as Map<String, Object>;

      testCasesString = testCaseTemplate(exerciseName, specification);
      print("Found: ${arguments['spec-path']}/exercises/$exerciseName/canonical-data.json");
    } on FileSystemException {
      scriptFailure("Could not open file '$filename', exiting.\n");
    } on FormatException {
      scriptFailure("File '$filename' is not valid JSON, exiting.\n");
    }
  } else {
    print("Could not find: ${arguments['spec-path']}/exercises/$exerciseName/canonical-data.json");
  }

  if (await exerciseDir.exists()) {
    scriptFailure("$exerciseName already exist\n");
  }

  await new Directory("${exerciseDir.path}/lib").create(recursive: true);
  await new Directory("${exerciseDir.path}/test").create(recursive: true);

  // Create files
  String testFileName = "${exerciseDir.path}/test/${filename}_test.dart";
  await new File("${exerciseDir.path}/lib/example.dart").writeAsString(exampleTemplate(exerciseName));
  await new File("${exerciseDir.path}/lib/${filename}.dart").writeAsString(mainTemplate(exerciseName));
  await new File(testFileName).writeAsString(testTemplate(exerciseName));
  await new File("${exerciseDir.path}/pubspec.yaml").writeAsString(pubTemplate(exerciseName));
  await new File("${exerciseDir.path}/analysis_options.yaml").writeAsString(analysisOptionsTemplate());

  if (arguments["spec-path"] != null) {
    // Generate README
    final dartRoot = "${dirname(Platform.script.toFilePath())}/..";
    final configletLoc = "$dartRoot/bin/configlet";
    final genSuccess = await runProcess(
        configletLoc, ["generate", "$dartRoot", "--spec-path", '${arguments['spec-path']}', "--only", exerciseName]);
    if (genSuccess) {
      stdout.write("Successfully created README.md\n");
    } else {
      stderr.write("Warning: `configlet generate` exited with an error, 'README.md' is likely malformed.\n");
    }
  }

  // The output from file generation is not always well-formatted, use dartfmt to clean it up
  final fmtSuccess = await runProcess("dartfmt", ["-l", "120", "-w", exerciseDir.path]);
  if (fmtSuccess) {
    stdout.write("Successfully created a rough-draft of tests at '$testFileName'.\n");
    stdout.write("You should check this over and fix or refine as necessary.\n");
  } else {
    stderr.write("Warning: dartfmt exited with an error, files in '${exerciseDir.path}' may be malformed.\n");
  }

  // Install deps
  Directory.current = exerciseDir;

  final pubSuccess = await runProcess("pub", ["get"]);
  assert(pubSuccess);

  Directory.current = currentDir;
}
