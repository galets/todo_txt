import 'package:test/test.dart';
import 'package:todo_txt/task.dart';

void main() {
  test('creation date without priority is parsed (spec Rule 2)', () {
    final task = Task.fromText('2011-03-02 Document +TodoTxt task format');

    expect(task.creationDate, DateTime(2011, 3, 2));
    expect(task.title, 'Document task format');
    expect(task.project, ['TodoTxt']);
  });

  test('element with multiple colons is not metadata (spec: only one colon)',
      () {
    final task = Task.fromText('Call mom at 12:30:45');

    expect(task.metadata, isEmpty);
    expect(task.title, contains('12:30:45'));
  });

  test('metadata value may contain colons (e.g. due:12:00AM)', () {
    final task = Task.fromText('Call mom due:12:00AM');

    expect(task.metadata, {'due': '12:00AM'});
    expect(task.title, 'Call mom');
  });

  test(
      'bare @ and + are not context/project (spec Rule 3: must contain non-whitespace)',
      () {
    final task = Task.fromText('Call Mom @ +');

    expect(task.context, isEmpty);
    expect(task.project, isEmpty);
    expect(task.title, contains('@'));
    expect(task.title, contains('+'));
  });

  test('lone x is not a completed task (spec: x must be followed by a space)',
      () {
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
}
