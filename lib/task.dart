import 'package:todo_txt/helpers.dart';

final RegExp metadataRegex = RegExp(r'^([A-Za-z][^:\s]*):(\S+)$');
final RegExp priorityRegex = RegExp(r'^[A-Za-z]$');

class Task {
  bool completed;
  String title;
  int? _priority;
  DateTime? completionDate;
  DateTime? creationDate;
  List<String> project;
  List<String> context;
  Map<String, String> metadata;

  String? get priority =>
      _priority == null ? null : String.fromCharCode(_priority!);

  set priority(String? value) {
    if (value == null) {
      _priority = null;
      return;
    }
    if (!priorityRegex.hasMatch(value)) {
      throw ArgumentError.value(
          value, 'priority', 'Must be a single alpha character (A-Z)');
    }
    _priority = value.toUpperCase().codeUnitAt(0);
  }

  Task(
    this.title, {
    this.completed = false,
    String? priority,
    this.completionDate,
    this.creationDate,
    this.project = const [],
    this.context = const [],
    this.metadata = const {},
  }) {
    this.priority = priority;
  }

  /// check positional args and remove them from list: completed, priority, creation-date
  /// incompleted example: (A) <- Priority 2022-03-21 <- creationDate ...
  /// completed full example: x <- completed 2022-03-22 <- completionDate 2022-03-21 <-creation Date
  /// completion replaces priority because there is no real use for prio on completed todos, which can be additionally sorted by latest completed
  factory Task.fromText(String todoLine) {
    var elements = todoLine.split(' ');
    var completed = false;
    var title = '';
    String? priority;
    DateTime? creationDate;
    DateTime? completionDate;
    var projects = <String>[];
    var contexts = <String>[];
    var params = <String, String>{};

    // if completed: 'x' must be followed by a space (spec Rule 1),
    // so a lone 'x' with nothing after it is not a completed task.
    if (elements[0] == 'x' && elements.length > 1) {
      completed = true;
      elements.removeAt(0);
      // followed by completion Date
      if (elements.isNotEmpty && isDateString(elements[0])) {
        completionDate = DateTime.tryParse(elements[0]);
        elements.removeAt(0);
      }
      // else if prio
    } else if (isPriorityString(elements[0]) ||
        isPriorityString(elements[0].toUpperCase())) {
      priority = elements[0].toUpperCase()[1];
      elements.removeAt(0);
    }

    // creationDate comes directly after priority/completion,
    // or first when there is no priority (spec Rule 2).
    // For completed tasks it requires a completion date before it.
    if (elements.isNotEmpty && isDateString(elements[0])) {
      if (!completed || completionDate != null) {
        creationDate = DateTime.tryParse(elements[0]);
        elements.removeAt(0);
      }
    }

    // remaining elements can be parsed on easy for loop @ -> context + -> projet contains : -> key/value pair
    for (var element in elements) {
      if (element.startsWith('@') && element.length > 1) {
        contexts.add(element.substring(1));
      } else if (element.startsWith('+') && element.length > 1) {
        projects.add(element.substring(1));
      } else if (metadataRegex.hasMatch(element)) {
        var match = metadataRegex.firstMatch(element)!;
        params[match.group(1)!] = match.group(2)!;
      } else {
        title += ' $element';
      }
    }

    title = title.trim();

    return Task(title,
        completed: completed,
        priority: priority,
        creationDate: creationDate,
        completionDate: completionDate,
        context: contexts,
        project: projects,
        metadata: params);
  }

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
