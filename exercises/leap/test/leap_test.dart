import 'package:test/test.dart';
import 'package:leap/leap.dart';

final Leap leap = new Leap();

void main() {
  group('Leap', () {
    test('year not divisible by 4: common year', () {
      final bool result = leap.leapYear(2015);
      expect(result, equals(false));
    }, skip: false);

    test('year divisible by 4, not divisible by 100: leap year', () {
      final bool result = leap.leapYear(1996);
      expect(result, equals(true));
    }, skip: true);

    test('year divisible by 100, not divisible by 400: common year', () {
      final bool result = leap.leapYear(2100);
      expect(result, equals(false));
    }, skip: true);

    test('year divisible by 400: leap year', () {
      final bool result = leap.leapYear(2000);
      expect(result, equals(true));
    }, skip: true);

    test('year is introduced every 4 years to adjust about a day before 400 A.D.', () {
      final bool result = leap.leapYear(4);
      expect(result, equals(true));
    }, skip: true);

    test('year is skipped every 100 years to remove an extra day before 400 A.D.', () {
      final bool result = leap.leapYear(300);
      expect(result, equals(false));
    }, skip: true);

    test('year is reintroduced every 400 years to adjust another day including 400 A.D.', () {
      final bool result = leap.leapYear(400);
      expect(result, equals(true));
    }, skip: true);
  });
}
