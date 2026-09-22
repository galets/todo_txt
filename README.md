This package implements the [todo.txt standard](https://github.com/todotxt/todo.txt).
The main purpose is to store todos in a simple `*.txt` file, so you have full control over your todos.

## Features

- Parse todo.txt lines into `Task` objects (`priority`, `creationDate`, `completionDate`, `project`, `context`, `metadata`)
- Serialize `Task` objects back to spec-ordered todo.txt lines
- Load tasks from any `Stream<String>` (file, stdin, in-memory)
- Save tasks to any `IOSink` (file, stdout)

## Getting started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  todo_txt:
    git:
      url: https://github.com/galets/todo_txt.git
      ref: master
```

## Usage

Import the package:

```dart
import 'package:todo_txt/todo_txt.dart';
```

### Read from an existing `*.txt` file

`TodoTxt.load` takes a `Stream<String>`, one todo.txt line per event, and skips blank lines.
You own opening/closing the file.

```dart
import 'dart:convert';
import 'dart:io';

import 'package:todo_txt/todo_txt.dart';

final lines = File('/home/example/Documents/todo.txt')
    .openRead()
    .transform(utf8.decoder)
    .transform(const LineSplitter());

final List<Task> tasks = await TodoTxt.load(lines);
```

Parse or create single tasks directly:

```dart
final task = Task.fromText('(A) Call mom @home +family due:2026-09-30');

final newTask = Task(
  'Try this awesome package!',
  priority: 'A',
  creationDate: DateTime(2026, 9, 22),
  project: ['family'],
  context: ['home'],
  metadata: {'due': '2026-09-30'},
);
```

### Save your changes

`TodoTxt.save` writes each task with `toText()`, then flushes. It never closes the sink —
you own closing it.

```dart
final sink = File('/home/example/Documents/todo.txt').openWrite();
await TodoTxt.save(tasks, sink);
await sink.close();
```

See `example/dump.dart` for a complete load-and-inspect example
(file or stdin → `TodoTxt.load` → `Task` fields).

## Additional information

For more information on todo.txt check the documentation on
[GitHub](https://github.com/todotxt/todo.txt) or the [todo.txt](http://todotxt.org/) website.
File an issue at <https://github.com/galets/todo_txt>.
