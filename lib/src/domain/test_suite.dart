class TestSuite {

  // Define a Test Suite class that would contain as properties:
  //
  //imports
  //constructor
  //predicates for errors
  //groups which contain tests
  //tests
  //    return type
  //    method to call
  //    expect - actual and expected

  List<String> imports;
  String predicate;
  List<Group> groups;
  List<Case> cases;
  List<Test> tests;

}

class Group {
  List<Group> groups;
  List<Test> tests;

  Group([this.tests, this.groups]);
}

class Case {
}

class Test {
  //    return type
  //    method to call
  //    expect - actual and expected

  String returnType;
  String methodName;
  List<String> methodParameters;
  String expectMethod;
}