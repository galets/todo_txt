import 'package:test/test.dart';
import 'package:todo_txt/task.dart';

void main() {
  test('isPriorityString validPrioString returnTrue', () {
    const prioString = '(A)';
    expect(isPriorityString(prioString), true);
  });

  test('isPriorityString invalidPrioString returnFalse', () {
    const prioString = '(a)';
    expect(isPriorityString(prioString), false);
  });

  test('isDate validDate returnTrue', () {
    const dateString = '1999-03-22';
    expect(isDateString(dateString), true);
  });

  test('isDate swappedDayMonth returnFalse', () {
    const dateString = '1999-22-03';
    expect(isDateString(dateString), false);
  });

  test('isDate 2BigValueForDay returnFalse', () {
    const dateString = '1999-03-33';
    expect(isDateString(dateString), false);
  });

  test('isDate 2BigValueForMonth returnFalse', () {
    const dateString = '1999-13-22';
    expect(isDateString(dateString), false);
  });

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

  test('creation date without priority is parsed (spec Rule 2)', () {
    final task = Task.fromText('2011-03-02 Document +TodoTxt task format');

    expect(task.creationDate, DateTime(2011, 3, 2));
    expect(task.title, 'Document task format');
    expect(task.project, ['TodoTxt']);
  });

  test('element with multiple colons is not metadata (spec: only one colon)', () {
    final task = Task.fromText('Call mom at 12:30:45');

    expect(task.metadata, isEmpty);
    expect(task.title, contains('12:30:45'));
  });

  test('metadata value may contain colons (e.g. due:12:00AM)', () {
    final task = Task.fromText('Call mom due:12:00AM');

    expect(task.metadata, {'due': '12:00AM'});
    expect(task.title, 'Call mom');
  });

  test('bare @ and + are not context/project (spec Rule 3: must contain non-whitespace)', () {
    final task = Task.fromText('Call Mom @ +');

    expect(task.context, isEmpty);
    expect(task.project, isEmpty);
    expect(task.title, contains('@'));
    expect(task.title, contains('+'));
  });

  test('lone x is not a completed task (spec: x must be followed by a space)', () {
    final task = Task.fromText('x');

    expect(task.completed, false);
    expect(task.title, 'x');
  });

  test('normal priority is parsed properly', () {
    final task = Task.fromText('(B) test that priority is B');

    expect(task.priority, 'B');
  });

  test('lowercase priority is converted to uppercase (spec Rule 1)', () {
    final task = Task.fromText('(b) Get back to the boss');

    expect(task.priority, 'B');
    expect(task.title, 'Get back to the boss');
  });

  test('priority accepts single alpha char and uppercases it', () {
    final task = Task('x', priority: 'b');

    expect(task.priority, 'B');
  });

  test('priority rejects non-single-alpha values', () {
    final task = Task('x');

    expect(() => task.priority = 'AB', throwsArgumentError);
    expect(() => task.priority = '1', throwsArgumentError);
    expect(() => task.priority = '', throwsArgumentError);
    expect(() => task.priority = '(A)', throwsArgumentError);
    expect(() => Task('x', priority: 'AB'), throwsArgumentError);
  });

  test('toText uses single spaces when context list is empty (spec ordering)', () {
    final task = Task('Hello', project: ['P']);

    expect(task.toText(), 'Hello +P');
  });

  test('empty title is rejected (a task must have description text)', () {
    expect(() => Task('', completed: true), throwsArgumentError);
    expect(() => Task('   '), throwsArgumentError);
    expect(() => Task.fromText('x '), throwsArgumentError);
  });

  test(
      'completed toText with only creationDate does not emit it as completion date (spec ordering: x completionDate creationDate)',
      () {
    final task = Task(
      'Foo',
      completed: true,
      creationDate: DateTime(2011, 3, 1),
    );
    // creating with completed:true auto-sets completionDate to today,
    // so creationDate stays in the creation slot on round-trip.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    expect(task.completionDate, today);

    final reparsed = Task.fromText(task.toText());

    expect(reparsed.completionDate, today);
    expect(reparsed.creationDate, DateTime(2011, 3, 1));
  });

  test('setting completed to true sets completionDate to today', () {
    final task = Task('Foo');
    expect(task.completionDate, isNull);
    task.completed = true;
    final now = DateTime.now();
    expect(task.completionDate, DateTime(now.year, now.month, now.day));
  });

  test('setting completed to false clears completionDate', () {
    final task = Task('Foo', completed: true);
    expect(task.completionDate, isNotNull);
    task.completed = false;
    expect(task.completionDate, isNull);
  });

  test('parsed dateless completed task keeps null completionDate', () {
    final task = Task.fromText('x completed task');
    expect(task.completed, true);
    expect(task.completionDate, isNull);
  });

  test('dateless completed task with creationDate round-trips dates in order (spec: x completionDate creationDate)', () {
    var task = Task.fromText('x completed task');
    // Dates are read-only; copyWith stamps completionDate so the
    // creation date can never slip into the completion slot.
    task = task.copyWith(creationDate: DateTime(2011, 3, 1));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final reparsed = Task.fromText(task.toText());

    expect(reparsed.completionDate, today);
    expect(reparsed.creationDate, DateTime(2011, 3, 1));
  });

  test('completed task with completion date is parsed and serialized', () {
    final task = Task.fromText('x 2011-03-02 Review pull request');

    expect(task.completed, true);
    expect(task.completionDate, DateTime(2011, 3, 2));
    expect(task.creationDate, isNull);
    expect(task.title, 'Review pull request');
    expect(task.toText(), 'x 2011-03-02 Review pull request');
  });

  test('completed task with both dates is parsed and serialized', () {
    final task = Task.fromText('x 2011-03-02 2011-03-01 Review pull request');

    expect(task.completed, true);
    expect(task.completionDate, DateTime(2011, 3, 2));
    expect(task.creationDate, DateTime(2011, 3, 1));
    expect(task.title, 'Review pull request');
    expect(task.toText(), 'x 2011-03-02 2011-03-01 Review pull request');
  });

  test('invalid calendar date in date position throws (spec: YYYY-MM-DD must be a real date)', () {
    expect(
      () => Task.fromText('2011-02-31 Document task format'),
      throwsFormatException,
    );
  });

  test('malformed date-like token in date position throws (spec: YYYY-MM-DD format)', () {
    expect(
      () => Task.fromText('2011-13-01 Document task format'),
      throwsFormatException,
    );
    expect(() => Task.fromText('x 2011-13-01 Foo'), throwsFormatException);
  });

  test('completed task preserves priority via pri metadata', () {
    final task = Task.fromText('x 2026-05-03 2026-05-01 pri:A Spray mosquito poison');
    expect(task.completed, true);
    expect(task.priority, 'A');
    expect(task.metadata['pri'], 'A');
    expect(
      task.toText(),
      'x 2026-05-03 2026-05-01 Spray mosquito poison pri:A',
    );
  });

  test('incomplete task ignores pri metadata for priority', () {
    final task = Task.fromText('(B) Call Mom pri:A');
    expect(task.completed, false);
    expect(task.priority, 'B');
    expect(task.metadata, {'pri': 'A'});
  });

  test('incomplete toText keeps (A) priority prefix', () {
    final task = Task.fromText('(A) Call Mom');
    expect(task.toText(), '(A) Call Mom');
  });

  test('completing a task moves priority into pri metadata', () {
    final task = Task.fromText('(A) Call Mom');
    task.completed = true;
    expect(task.priority, 'A');
    expect(task.metadata['pri'], 'A');
    expect(task.toText(), startsWith('x '));
    expect(task.toText(), contains('pri:A'));
    expect(task.toText(), isNot(contains('(A)')));
  });

  test('completing a priority-less task adds no pri metadata', () {
    final task = Task.fromText('Call Mom');
    task.completed = true;
    expect(task.priority, isNull);
    expect(task.metadata.containsKey('pri'), false);
  });

  test('parseStrictDate parses valid YYYY-MM-DD date', () {
    expect(parseStrictDate('2011-03-02'), DateTime(2011, 3, 2));
  });

  test('parseStrictDate accepts leap day on leap year', () {
    expect(parseStrictDate('2024-02-29'), DateTime(2024, 2, 29));
  });

  test('parseStrictDate rejects non-leap Feb 29', () {
    expect(() => parseStrictDate('2023-02-29'), throwsFormatException);
  });

  test('parseStrictDate rejects nonexistent calendar dates', () {
    expect(() => parseStrictDate('2011-02-31'), throwsFormatException);
    expect(() => parseStrictDate('2011-04-31'), throwsFormatException);
    expect(() => parseStrictDate('2011-00-10'), throwsFormatException);
    expect(() => parseStrictDate('2011-13-01'), throwsFormatException);
    expect(() => parseStrictDate('2011-01-00'), throwsFormatException);
    expect(() => parseStrictDate('2011-01-32'), throwsFormatException);
  });

  test('parseStrictDate rejects malformed format', () {
    expect(() => parseStrictDate('2011-3-2'), throwsFormatException);
    expect(() => parseStrictDate('2011-03-2'), throwsFormatException);
    expect(() => parseStrictDate('11-03-02'), throwsFormatException);
    expect(() => parseStrictDate('not-a-date'), throwsFormatException);
    expect(() => parseStrictDate(' 2011-03-02'), throwsFormatException);
    expect(() => parseStrictDate('2011-03-02 '), throwsFormatException);
    expect(() => parseStrictDate(''), throwsFormatException);
  });

  test('uncompleting a task removes pri metadata', () {
    final task = Task.fromText('x 2026-05-03 2026-05-01 pri:A Spray mosquito poison');
    task.completed = false;
    expect(task.priority, 'A');
    expect(task.metadata.containsKey('pri'), false);
    expect(task.toText(), startsWith('(A) '));
  });
}
