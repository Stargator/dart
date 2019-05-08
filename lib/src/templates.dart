import 'helpers.dart';

String exampleTemplate(String name) => """
class ${pascalCase(name)} {

}
""";

String mainTemplate(String name) => """
class ${pascalCase(name)} {
  // Put your code here
}
""";

String testCasesString = """
    test('should work', () {
      // TODO
    });""";

String testTemplate(String name) => """
import 'package:test/test.dart';
import 'package:${snakeCase(name)}/${snakeCase(name)}.dart';

void main() {
  final ${camelCase(name)} = new ${pascalCase(name)}();

  group('${pascalCase(name)}', () {
$testCasesString
  });
}
""";

String pubTemplate(String name) => """
name: '${snakeCase(name)}'
environment:
  sdk: ">=1.24.0 <3.0.0"
dev_dependencies:
  test: '<0.13.0'
""";

String analysisOptionsTemplate() => """
analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
  errors:
    unused_element:        error
    unused_import:         error
    unused_local_variable: error
    dead_code:             error

linter:
  rules:
    # Error Rules
    - avoid_relative_lib_imports
    - avoid_types_as_parameter_names
    - literal_only_boolean_expressions
    - no_adjacent_strings_in_list
    - valid_regexps
""";

String testCaseTemplate(String name, Map<String, Object> testCase, {bool firstTest = true}) {
  bool skipTests = firstTest;

  if (testCase['cases'] != null) {
    // We have a group, not a case
    String description = testCase['description'] as String;

    // Build the tests up recursively, only first test should be skipped
    List<String> testList = <String>[];
    for (Map<String, Object> caseObj in testCase['cases'] as dynamic) {
      testList.add(testCaseTemplate(name, caseObj, firstTest: skipTests));
      skipTests = false;
    }
    String tests = testList.join("\n");

    if (description == null) {
      return tests;
    }

    return """
      group('$description', () {
        $tests
      });
    """;
  }

  String description = repr(testCase['description']);
  String resultType = getFriendlyType(testCase['expected']);
  String object = camelCase(name);
  String method = camelCase(testCase['property'].toString());
  String expected = repr(testCase['expected']);

  Map<String, dynamic> input = testCase['input'] as Map<String, dynamic>;
  String arguments = input.keys.map((k) => repr(input[k])).join(', ');

  return """
    test($description, () {
      final $resultType result = $object.$method($arguments);
      expect(result, equals($expected));
    }, skip: ${!skipTests});
  """;
}