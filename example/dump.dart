import 'dart:convert';
import 'dart:io';

import 'package:todo_txt/helpers.dart';
import 'package:todo_txt/task.dart';

/// Reads todo.txt lines from the file given as the first argument,
/// or from stdin when no argument is provided, and dumps each task as:
///
///   Task - `<line>` (toText)
///     * field: xxx
///
/// where only non-null / non-empty fields are shown, including metadata.
Future<void> main(List<String> args) async {
  final List<String> lines;
  if (args.isNotEmpty) {
    lines = await File(args[0]).readAsLines();
  } else {
    lines = await stdin.transform(utf8.decoder).transform(const LineSplitter()).toList();
  }

  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    final task = Task.fromText(line);

    print(task.toText());

    void field(String name, String value) => print('  * $name: $value');

    field('completed', task.completed.toString());
    if (task.priority != null) field('priority', task.priority!);
    if (task.completionDate != null) {
      field('completionDate', dateToDateString(task.completionDate!));
    }
    if (task.creationDate != null) {
      field('creationDate', dateToDateString(task.creationDate!));
    }
    field('title', task.title);
    if (task.context.isNotEmpty) field('context', task.context.join(', '));
    if (task.project.isNotEmpty) field('project', task.project.join(', '));
    for (final entry in task.metadata.entries) {
      field('metadata: ${entry.key}', entry.value);
    }

    print('');
  }
}
