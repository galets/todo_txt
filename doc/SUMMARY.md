# todo_txt – Project Summary

## Overview

`todo_txt` v0.1.0 is a pure-Dart package implementing the
[todo.txt standard](http://todotxt.org/) for storing todos in plain `*.txt` files.

sdk: ">=2.17.6 <4.0.0"

## Capabilities

- Parse `todo.txt` lines into `Task` objects:
  `x <completion-date> <creation-date> title @context +project key:value`,
  `(A) <creation-date> ...` (`tmp/lib/task.dart:28-85`).
- Serialize back via `Task.toText()` (`tmp/lib/task.dart:109-132`) and
  `TodoTxt.writeToFile()` (`tmp/lib/todo_txt.dart:55-64`).
- File manager `TodoTxt` (`tmp/lib/todo_txt.dart:10-65`):
  `TodoTxt.readFromFile(path:)`, `TodoTxt.create(tasks:path:)`, `writeToFile()`.
  Enforces `.txt` suffix, normalizes path separators, skips empty lines.

## Structure

```text
lib/
  todo_txt.dart — TodoTxt class, library entry, re-exports task.dart
  task.dart     — Task model: completed, title, priority (int char-code),
                  completionDate, creationDate, project, context, metadata
                  + fromText / toText / copyWith
  helpers.dart  — dateRegex / isDateString / isPriorityString /
                  dateToDateString / paramsToString / pathToPlatformPath
test/
  todo_txt_test.dart, helpers_test.dart, resources/
pubspec.yaml, analysis_options.yaml, CHANGELOG.md, README.md, LICENSE
```
