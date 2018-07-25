class Anagram {
  List<String> findAnagrams(String subject, List<String> candidates) {
    final subjectCharsMap = countCharacters(subject);

    final matchTracker = <String>[];

    for (final possible in candidates) {
      if (possible.toLowerCase() != subject.toLowerCase()) {
        final possibleCharMap = countCharacters(possible);

        if (mapsMatch(subjectCharsMap, possibleCharMap)) {
          matchTracker.add(possible);
        }
        possibleCharMap.clear();
      }
    }

    return matchTracker;
  }

  Map<String, int> countCharacters(String word) {
    final charTracker = <String, int>{};

    for (var counter = 0; counter < word.length; counter++) {
      final key = word[counter].toLowerCase();

      charTracker[key] = charTracker.containsKey(key) ? charTracker[key]! + 1 : 1;
    }

    return charTracker;
  }
}

bool mapsMatch(Map<String, int> subjectCharsMap, Map<String, int> possibleCharMap) {
  final trackingMatches = <bool>[];

  for (final key in possibleCharMap.keys) {
    if (subjectCharsMap.containsKey(key)) {
      trackingMatches.add(subjectCharsMap[key] == possibleCharMap[key]);
    } else {
      return false;
    }
  }

  for (final result in trackingMatches) {
    if (result == false) {
      return false;
    }
  }

  return trackingMatches.length == subjectCharsMap.length;
}
