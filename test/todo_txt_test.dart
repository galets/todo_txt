import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:todo_txt/todo_txt.dart';

/// In-memory IOSink adapter for tests.
class _MemorySink implements IOSink {
  final StringBuffer buffer = StringBuffer();
  @override
  Encoding encoding = utf8;
  @override
  void write(Object? obj) => buffer.write(obj);
  @override
  void writeln([Object? obj = '']) => buffer.writeln(obj);
  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) => buffer.writeAll(objects, separator);
  @override
  void writeCharCode(int charCode) => buffer.writeCharCode(charCode);
  @override
  void add(List<int> data) {}
  @override
  void addError(Object error, [StackTrace? stackTrace]) {}
  @override
  Future<void> addStream(Stream<List<int>> stream) async {}
  @override
  Future<void> flush() async {}
  @override
  Future<void> close() async {}
  @override
  Future<void> get done => Future.value();
}

void main() {
  group('TodoTxt', () {
    test('load skips blanks and trims', () async {
      final tasks = await TodoTxt.load(
        Stream.fromIterable(['Task 1', '', '  Task 2  ']),
      );
      expect(tasks.map((t) => t.title), ['Task 1', 'Task 2']);
    });

    test('save writes lines', () async {
      final sink = _MemorySink();
      await TodoTxt.save([Task('Task 1'), Task('Task 2')], sink);
      expect(sink.buffer.toString(), 'Task 1\nTask 2\n');
    });

    test('save empty writes nothing', () async {
      final sink = _MemorySink();
      await TodoTxt.save([], sink);
      expect(sink.buffer.toString(), '');
    });
  });
}
