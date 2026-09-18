import 'package:meta/meta.dart';
import 'package:todo_txt/helpers.dart';

final RegExp _dateRegex = RegExp(r'^(\d{4})[\-](0[1-9]|1[012])[\-](0[1-9]|[12][0-9]|3[01])$');
final RegExp _metadataRegex = RegExp(r'^([A-Za-z][^:\s]*):(\S+)$');
final RegExp _priorityRegex = RegExp(r'^[A-Za-z]$');
final RegExp _dateLikeRegex = RegExp(r'^\d{4}-\d{1,2}-\d{1,2}$');

/// Test-only accessor for [_dateRegex]; do not use outside tests.
@visibleForTesting
bool isDateString(String date) => _dateRegex.hasMatch(date);

DateTime _parseStrictDate(String date) {
  if (!_dateRegex.hasMatch(date)) {
    throw FormatException('Invalid date', date);
  }
  final parts = date.split('-');
  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]);
  final day = int.parse(parts[2]);
  final parsed = DateTime(year, month, day);
  if (parsed.year != year || parsed.month != month || parsed.day != day) {
    throw FormatException('Invalid date', date);
  }
  return parsed;
}

/// A single todo.txt task line (spec Rules 1–3 + completed Rules 1–2).
class Task {
  bool _completed;

  /// Free-form description text of the task.
  String title;

  int? _priority;
  DateTime? _completionDate;
  DateTime? _creationDate;

  /// Completion date (`x YYYY-MM-DD ...`); null when open or dateless.
  DateTime? get completionDate => _completionDate;

  /// Creation date, directly after priority or leading the line.
  DateTime? get creationDate => _creationDate;

  /// Project tags without the `+` prefix (spec Rule 3).
  List<String> project;

  /// Context tags without the `@` prefix (spec Rule 3).
  List<String> context;

  /// Arbitrary `key:value` metadata (e.g. `due:2011-03-03`, `pri:A`).
  Map<String, String> metadata;

  /// Whether the line starts with `x ` (completed Rule 1).
  bool get completed => _completed;

  /// Sets completion; completing stamps today and preserves priority as `pri:A`.
  set completed(bool value) {
    final wasCompleted = _completed;
    _completed = value;
    if (value) {
      _completionDate ??= _today();
      if (_priority != null) {
        metadata['pri'] = priority!;
      } else {
        metadata.remove('pri');
      }
    } else {
      _completionDate = null;
      // Only strip preserved priority when transitioning completed -> open.
      // Constructing/parsing an open task must keep a literal pri entry.
      if (wasCompleted) {
        metadata.remove('pri');
      }
    }
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Priority letter `A`–`Z` (spec Rule 1, `(A)`); lowercase is uppercased.
  String? get priority => _priority == null ? null : String.fromCharCode(_priority!);

  /// Sets priority; kept as `pri:A` metadata while completed.
  set priority(String? value) {
    if (value == null) {
      _priority = null;
      if (_completed) {
        metadata.remove('pri');
      }
      return;
    }
    if (!_priorityRegex.hasMatch(value)) {
      throw ArgumentError.value(
        value,
        'priority',
        'Must be a single alpha character (A-Z)',
      );
    }
    _priority = value.toUpperCase().codeUnitAt(0);
    if (_completed) {
      metadata['pri'] = priority!;
    }
  }

  /// Creates a task; empty [title] throws [ArgumentError].
  Task(
    this.title, {
    bool completed = false,
    String? priority,
    DateTime? completionDate,
    DateTime? creationDate,
    this.project = const [],
    this.context = const [],
    Map<String, String> metadata = const {},
  })  : _completed = false,
        _completionDate = completionDate,
        _creationDate = creationDate,
        metadata = Map.of(metadata) {
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'Must not be empty');
    }
    this.priority = priority;
    this.completed = completed;
  }

  /// Parses a todo.txt line into a [Task] per spec ordering and tags.
  /// check positional args and remove them from list: completed, priority, creation-date
  /// incompleted example: (A) <- Priority 2022-03-21 <- creationDate ...
  /// completed full example: x <- completed 2022-03-22 <- completionDate 2022-03-21 <-creation Date
  /// completion replaces priority because there is no real use for prio on completed todos, which can be additionally sorted by latest completed
  factory Task.fromText(String todoLine) {
    final elements = todoLine.split(' ');
    var completed = false;
    var title = '';
    String? priority;
    DateTime? creationDate;
    DateTime? completionDate;
    final projects = <String>[];
    final contexts = <String>[];
    final params = <String, String>{};

    // if completed: 'x' must be followed by a space (spec Rule 1),
    // so a lone 'x' with nothing after it is not a completed task.
    if (elements[0] == 'x' && elements.length > 1) {
      completed = true;
      elements.removeAt(0);
      // followed by completion Date
      if (elements.isNotEmpty && (_dateRegex.hasMatch(elements[0]) || _dateLikeRegex.hasMatch(elements[0]))) {
        completionDate = _parseStrictDate(elements[0]);
        elements.removeAt(0);
      }
      // else if prio
    } else if (isPriorityString(elements[0]) || isPriorityString(elements[0].toUpperCase())) {
      priority = elements[0].toUpperCase()[1];
      elements.removeAt(0);
    }

    // creationDate comes directly after priority/completion,
    // or first when there is no priority (spec Rule 2).
    // For completed tasks it requires a completion date before it.
    // A date-like token in this slot that is not a valid YYYY-MM-DD
    // date is a malformed date, not title text.
    if (elements.isNotEmpty && (_dateRegex.hasMatch(elements[0]) || _dateLikeRegex.hasMatch(elements[0]))) {
      if (!completed || completionDate != null) {
        creationDate = _parseStrictDate(elements[0]);
        elements.removeAt(0);
      }
    }

    // remaining elements can be parsed on easy for loop @ -> context + -> projet contains : -> key/value pair
    for (var element in elements) {
      if (element.startsWith('@') && element.length > 1) {
        contexts.add(element.substring(1));
      } else if (element.startsWith('+') && element.length > 1) {
        projects.add(element.substring(1));
      } else if (_metadataRegex.hasMatch(element)) {
        final match = _metadataRegex.firstMatch(element)!;
        params[match.group(1)!] = match.group(2)!;
      } else {
        title += ' $element';
      }
    }

    title = title.trim();

    // Completed tasks preserve priority in pri metadata; incomplete tasks
    // keep a literal pri entry as plain metadata.
    if (completed) {
      final pri = params.remove('pri');
      if (pri != null && priority == null && _priorityRegex.hasMatch(pri)) {
        priority = pri.toUpperCase();
      }
    }

    final task = Task(
      title,
      completed: completed,
      priority: priority,
      creationDate: creationDate,
      completionDate: completionDate,
      context: contexts,
      project: projects,
      metadata: params,
    );
    // Parsed completed tasks without any date (e.g. "x completed task")
    // are the only case allowed to keep a null completionDate.
    if (completed && completionDate == null) {
      task._completionDate = null;
    }
    return task;
  }

  /// Returns a copy with the given fields replaced.
  Task copyWith({
    String? title,
    bool? completed,
    String? priority,
    DateTime? creationDate,
    DateTime? completionDate,
    List<String>? project,
    List<String>? context,
    Map<String, String>? metadata,
  }) {
    return Task(
      title ?? this.title,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      creationDate: creationDate ?? this.creationDate,
      completionDate: completionDate ?? this.completionDate,
      context: context ?? this.context,
      project: project ?? this.project,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Serializes this task to a spec-ordered todo.txt line.
  String toText() {
    var text = '';

    if (completed) {
      text += 'x';
      if (completionDate != null) {
        text += ' ${dateToDateString(completionDate!)}';
      }
    } else if (priority != null) {
      text += '($priority)';
    }

    if (creationDate != null) {
      text += ' ${dateToDateString(creationDate!)}';
    }

    text += ' $title';
    if (context.isNotEmpty) {
      text += ' ${context.map((e) => '@$e').join(' ')}';
    }
    if (project.isNotEmpty) {
      text += ' ${project.map((e) => '+$e').join(' ')}';
    }
    final meta = paramsToString(metadata);
    if (meta.isNotEmpty) {
      text += ' $meta';
    }

    text = text.trim();
    return text;
  }
}
