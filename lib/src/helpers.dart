import 'dart:async';
import 'dart:io';

List<String> words(final String str) {
  if (str == null) return [''];

  return str
      .toLowerCase()
      .replaceAll(new RegExp(r"[^a-z0-9]"), " ")
      .replaceAll(new RegExp(r" +"), " ")
      .trim()
      .split(" ");
}

String upperFirst(final String str) {
  if (str == null || str.length == 0) return '';

  final chars = str.split("");
  final first = chars.first;

  return first.toUpperCase() + chars.skip(1).join("");
}

String camelCase(String str, {bool isUpperFirst = false}) {
  final parts = words(str);
  final first = parts.first;
  final rest = parts.skip(1);

  return (isUpperFirst ? upperFirst(first) : first) + rest.map(upperFirst).join("");
}

String pascalCase(String str) => camelCase(str, isUpperFirst: true);

String snakeCase(String str) => words(str).join("_");

String kebabCase(String str) => words(str).join("-");

/// `repr` takes in any object and tries to coerce it to a String in such a way that it is suitable to include in code.
/// Based on the python `repr` function, but only works for basic types: String, Iterable, Map, and primitive types
String repr(Object x) {
  if (x is String) {
    String result = x.replaceAll('"', r'\"').replaceAll("\n", r"\n").replaceAll(r"$", r"\$");
    return '"$result"';
  }

  if (x is Iterable) {
    return '[${x.map(repr).join(", ")}]';
  }

  if (x is Map) {
    List<String> pairs = [];
    for (var k in x.keys) {
      pairs.add("${repr(k)}: ${repr(x[k])}");
    }

    return "{${pairs.join(', ')}}";
  }

  return "$x";
}

/// A helper method to get the inside type of an iterable
String getIterableType(Iterable iter) {
  Set<String> types = iter.map(getFriendlyType).toSet();

  if (types.length == 1) {
    return types.first;
  }

  return "Object";
}

/// Get a human-friendly type of a variable
String getFriendlyType(Object x) {
  if (x is String) {
    return "String";
  }

  if (x is Iterable) {
    return "List<${getIterableType(x)}>";
  }

  if (x is Map) {
    return "Map<${getIterableType(x.keys)}, ${getIterableType(x.values)}>";
  }

  if (x is num) {
    return "num";
  }

  return x.runtimeType.toString();
}

// runProcess runs a process, writes any stdout/stderr output.
// Returns true if the cmd was successful, false otherwise
Future<bool> runProcess(String cmd, List<String> arguments) async {
  final res = await Process.run(cmd, arguments, runInShell: true);
  if (!res.stdout.toString().isEmpty) {
    stdout.write(res.stdout);
  }

  if (!res.stderr.toString().isEmpty) {
    stderr.write(res.stderr);
  }

  return res.exitCode == 0;
}
