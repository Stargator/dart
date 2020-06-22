final RegExp _formatChecker = RegExp(r'^\d-?\d{3}-?\d{5}-?[\dX]$');
final RegExp _cleaner = RegExp(r'\W');

bool isValid(String isbn) {
  if (!_formatChecker.hasMatch(isbn)) {
    return false;
  }

  String clean = isbn.replaceAll(_cleaner, '');

  int checkSum = 0;
  clean.split('').toList().asMap().forEach((index, c) {
    checkSum += c == 'X' ? 10 : int.parse(c) * (10 - index);
  });

  return checkSum % 11 == 0;
}
