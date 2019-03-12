import 'package:isogram/isogram.dart';
import 'package:test/test.dart';

final isogram = new Isogram();

void main() {
  group('Isogram', () {
    group('Check if the given string is an isogram', () {
      test('empty string', () {
        final bool result = isogram.isisogram('');
        expect(result, equals(true));
      }, skip: false);

      test('isogram with only lower case characters', () {
        final bool result = isogram.isisogram('isogram');
        expect(result, equals(true));
      }, skip: true);

      test('word with one duplicated character', () {
        final bool result = isogram.isisogram('eleven');
        expect(result, equals(false));
      }, skip: true);

      test('word with one duplicated character from the end of the alphabet', () {
        final bool result = isogram.isisogram('zzyzx');
        expect(result, equals(false));
      }, skip: true);

      test('longest reported english isogram', () {
        final bool result = isogram.isisogram('subdermatoglyphic');
        expect(result, equals(true));
      }, skip: true);

      test('word with duplicated character in mixed case', () {
        final bool result = isogram.isisogram('Alphabet');
        expect(result, equals(false));
      }, skip: true);

      test('word with duplicated character in mixed case, lowercase first', () {
        final bool result = isogram.isisogram('alphAbet');
        expect(result, equals(false));
      }, skip: true);

      test('hypothetical isogrammic word with hyphen', () {
        final bool result = isogram.isisogram('thumbscrew-japingly');
        expect(result, equals(true));
      }, skip: true);

      test('hypothetical word with duplicated character following hyphen', () {
        final bool result = isogram.isisogram('thumbscrew-jappingly');
        expect(result, equals(false));
      }, skip: true);

      test('isogram with duplicated hyphen', () {
        final bool result = isogram.isisogram('six-year-old');
        expect(result, equals(true));
      }, skip: true);

      test('made-up name that is an isogram', () {
        final bool result = isogram.isisogram('Emily Jung Schwartzkopf');
        expect(result, equals(true));
      }, skip: true);

      test('duplicated character in the middle', () {
        final bool result = isogram.isisogram('accentor');
        expect(result, equals(false));
      }, skip: true);

      test('same first and last characters', () {
        final bool result = isogram.isisogram('angola');
        expect(result, equals(false));
      }, skip: true);
    });
  });
}
