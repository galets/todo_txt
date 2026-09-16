library todo_txt;

import 'dart:io';

import 'package:todo_txt/helpers.dart';
import 'package:todo_txt/task.dart';

export 'package:todo_txt/task.dart';

/// File-backed collection of [Task]s stored as one todo.txt line per task.
class TodoTxt {
  /// Platform-normalized `.txt` file path backing this list.
  String path;

  /// Tasks in file order; blank lines are skipped on read.
  List<Task> tasks;

  TodoTxt._({required this.path, required this.tasks});

  /// read existing Tasks from File at [path]
  factory TodoTxt.readFromFile({required String path}) {
    final osPath = pathToPlatformPath(path);
    if (!osPath.endsWith('.txt')) {
      throw const FormatException('File has to end with .txt');
    }
    try {
      final file = File(osPath);
      final lines = file.readAsLinesSync();
      final List<Task> tasks = List<Task>.empty(growable: true);
      for (var line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isNotEmpty) tasks.add(Task.fromText(trimmedLine));
      }
      return TodoTxt._(path: osPath, tasks: tasks);
    } on FileSystemException catch (ex) {
      print(ex.message);
      rethrow;
    }
  }

  /// Creates and writes tasks to path
  ///
  /// [tasks] List of [Task] to store into the file specified by the [path]
  factory TodoTxt.create({required List<Task> tasks, required String path}) {
    final osPath = pathToPlatformPath(path);
    if (!osPath.endsWith('.txt')) {
      throw const FormatException('File has to end with .txt');
    }
    if (File(osPath).existsSync()) {
      throw Exception('Specified file $osPath already exists');
    }

    final todoTxt = TodoTxt._(path: osPath, tasks: tasks);
    todoTxt.writeToFile();
    return todoTxt;
  }

  /// Writes the tasks of TodoTxt into the path
  void writeToFile() {
    try {
      final file = File(path);
      final lines = tasks.map((task) => task.toText());
      file.writeAsStringSync('${lines.join('\n')}\n', flush: true);
    } on FileSystemException catch (ex) {
      print(ex);
      rethrow;
    }
  }
}
