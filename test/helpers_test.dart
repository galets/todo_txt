import 'package:test/test.dart';
import 'package:todo_txt/helpers.dart';

void main() {
  test('isPriorityString validPrioString returnTrue', () {
    var prioString = '(A)';
    expect(isPriorityString(prioString), true);
  });

  test('isPriorityString invalidPrioString returnFalse', () {
    var prioString = '(a)';
    expect(isPriorityString(prioString), false);
  });

  test('isDate validDate returnTrue', () {
    var dateString = '1999-03-22';
    expect(isDateString(dateString), true);
  });

  test('isDate swappedDayMonth returnFalse', () {
    var dateString = '1999-22-03';
    expect(isDateString(dateString), false);
  });

  test('isDate 2BigValueForDay returnFalse', () {
    var dateString = '1999-03-33';
    expect(isDateString(dateString), false);
  });

  test('isDate 2BigValueForMonth returnFalse', () {
    var dateString = '1999-13-22';
    expect(isDateString(dateString), false);
  });

  test(
    'Linux path seperator to Windows path Seperator',
    () {
      var path = 'C:/this/is/a/path.txt';
      var expected = 'C:\\this\\is\\a\\path.txt';

      expect(pathToPlatformPath(path), expected);
    },
    onPlatform: {'!windows || browser': const Skip('Windows only test')},
  );

  test(
    'Windows path seperator to Posix path Seperator',
    () {
      var path = 'C:\\this\\is\\a\\path.txt';
      var expected = 'C:/this/is/a/path.txt';

      expect(pathToPlatformPath(path), expected);
    },
    onPlatform: {'windows || browser': const Skip('Not windows only test')},
  );

  test('isDate rejects string with prefix before date (must be exact YYYY-MM-DD)', () {
    expect(isDateString('ab2011-03-02'), false);
  });

  test('dateToDateString formats as YYYY-MM-DD', () {
    final date = DateTime(2011, 3, 2);
    expect(dateToDateString(date), '2011-03-02');
  });

  test('dateToDateString output is parseable by isDateString', () {
    final date = DateTime(2011, 3, 2);
    expect(isDateString(dateToDateString(date)), true);
  });

  test('isDate rejects non-zero-padded date (must be exact YYYY-MM-DD)', () {
    expect(isDateString('2011-3-2'), false);
    expect(isDateString('2011-03-2'), false);
    expect(isDateString('2011-3-02'), false);
  });
}
