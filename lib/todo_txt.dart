import 'dart:io';
import 'package:todo_txt/task.dart';

export 'package:todo_txt/task.dart';

/// Stream I/O for todo.txt (async only). Caller owns open/close; save flushes only.
class TodoTxt {
  TodoTxt._();

  /// Loads tasks from [source], one todo.txt line per event; skips blanks.
  static Future<List<Task>> load(Stream<String> source) async {
    final tasks = <Task>[];
    await for (final line in source) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty) tasks.add(Task.fromText(trimmed));
    }
    return tasks;
  }

  /// Writes [tasks] to [sink] as todo.txt lines and flushes (never closes).
  static Future<void> save(List<Task> tasks, IOSink sink) async {
    for (final task in tasks) {
      sink.writeln(task.toText());
    }
    await sink.flush();
  }
}
