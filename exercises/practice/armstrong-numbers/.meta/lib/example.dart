import 'dart:math' show pow;

class ArmstrongNumbers {
  /// The parameters and variables within the method that are set to final in order to prevent the accidentally modification of the value.
  /// As those variables are not needed to be changed.
  bool isArmstrongNumber(final num input) {
    final numberAsString = input.toString();
    final numOfDigits = numberAsString.length;
    var sum = 0;

    for (var count = 0; count < numOfDigits; count++) {
      final digitAsString = numberAsString.substring(count, count + 1);
      final digit = int.parse(digitAsString);
      sum += pow(digit, numOfDigits).toInt();
    }

    return input == sum;
  }
}
