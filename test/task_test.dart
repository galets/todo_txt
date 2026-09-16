import 'package:test/test.dart';
import 'package:todo_txt/task.dart';

void main() {
  test('creation date without priority is parsed (spec Rule 2)', () {
    final task =
        Task.fromText('2011-03-02 Document +TodoTxt task format');

    expect(task.creationDate, DateTime(2011, 3, 2));
    expect(task.title, 'Document task format');
    expect(task.project, ['TodoTxt']);
  });
}
