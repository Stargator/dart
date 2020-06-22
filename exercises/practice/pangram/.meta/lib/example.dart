class Pangram {
  bool isPangram(String sentence) {
    Set<String> uniqueLetters = Set();
    String cleanSentence = sentence.toLowerCase().replaceAll(RegExp(r"[^a-zA-Z]"), "");
    uniqueLetters.addAll(cleanSentence.split(""));

    return uniqueLetters.length == 26;
  }
}
