# TODOTXT specs

A single line in your todo.txt text file represents a single task.

### 1. Raw Text Sample

The sample line of text is:

```text
x 2011-03-02 2011-03-01 Review Tim's pull request +TodoTxtTouch @github due:2011-03-03
```

### 2. Component Breakdown & Annotations

The image highlights and labels each segment of the line with callout brackets/lines:

| Text Segment | Label / Element Name | Description / Rule |
| --- | --- | --- |
| **`x`** | **Completion Mark** | Lowercase `x` at the very start indicates a completed task. |
| **`2011-03-02`** | **Completion Date** | Mandatory date format `YYYY-MM-DD` directly after `x`. |
| **`2011-03-01`** | **Creation Date** | Optional date format `YYYY-MM-DD` indicating when the task was initially created. |
| **`Review Tim's pull request`** | **Task Description** | Free-form human-readable text detailing the task action. |
| **`+TodoTxtTouch`** | **Project Tag** | Prefixed with a plus sign (`+`) to categorize the task under a specific project. |
| **`@github`** | **Context Tag** | Prefixed with an `@` symbol to represent the location, tool, or context needed. |
| **`due:2011-03-03`** | **Key:Value Tag / Metadata** | Arbitrary metadata using `key:value` syntax (here specifying a due date). |

---

### 3. Key Structural Rules Expressed

1. **Ordering:** The completion mark (`x`), completion date, and creation date appear sequentially at the beginning of the line, separated by single spaces.
2. **Inline Identifiers:** Projects (`+`), Contexts (`@`), and Metadata (`key:value`) can appear anywhere in the body text after the dates/prefix.
3. 


## `todo.txt` format rules

Your `todo.txt` is a plain text file. To take advantage of structured task metadata like priority, projects, context, creation, and completion date, there are a few simple but flexible file format rules.

Philosophically, the `todo.txt` file format has two goals:

- The file contents should be human-readable without requiring any tools other than a plain text viewer or editor.
- A user can manipulate the file contents in a plain text editor in sensible, expected ways. For example, a text editor that can sort lines alphabetically should be able to sort your task list in a meaningful way.

These two goals are why, for example, lines start with priority and/or dates, so that they are easily sorted by priority or time, and completed items are marked with an `x`, which both sorts at the bottom of an alphabetical list and looks like a filled-in checkbox.

Here are the rest.


## Incomplete Tasks: 3 Format Rules

The beauty of todo.txt is that it's completely unstructured; the fields you can attach to each task are only limited by your imagination. To get started, use special notation to indicate task context (e.g. `@phone` ), project (e.g. `+GarageSale` ) and priority (e.g. `(A)` ).

A todo.txt file might look like the following:

```
(A) Thank Mom for the meatballs @phone
(B) Schedule Goodwill pickup +GarageSale @phone
Post signs around the neighborhood +GarageSale
@GroceryStore pies
```

A search and filter for the `@phone` contextual items would output:

```
(A) Thank Mom for the meatballs @phone
(B) Schedule Goodwill pickup +GarageSale @phone
```

To just see the `+GarageSale` project items would output:

```
(B) Schedule Goodwill pickup +GarageSale @phone
Post signs around the neighborhood +GarageSale
```

There are three formatting rules for current todo's.

### Rule 1: If priority exists, it ALWAYS appears first.

The priority is an uppercase character from A-Z enclosed in parentheses and followed by a space.

This task has a priority:

```
(A) Call Mom
```

These tasks do not have any priorities:

```
Really gotta call Mom (A) @phone @someday
(b) Get back to the boss
(B)->Submit TPS report
```


### Rule 2: A task's creation date may optionally appear directly after priority and a space.

If there is no priority, the creation date appears first. If the creation date exists, it should be in the format `YYYY-MM-DD`.

These tasks have creation dates:

```
2011-03-02 Document +TodoTxt task format
(A) 2011-03-02 Call Mom
```

This task doesn't have a creation date:

```
(A) Call Mom 2011-03-02
```


### Rule 3: Contexts and Projects may appear anywhere in the line _after_ priority/prepended date.

- A *context* is preceded by a single space and an at-sign (`@`).
- A *project* is preceded by a single space and a plus-sign (`+`).
- A *project* or *context* contains any non-whitespace character.
- A *task* may have zero, one, or more than one *projects* and *contexts* included in it.

For example, this task is part of the `+Family` and `+PeaceLoveAndHappiness` projects as well as the `@iphone` and `@phone` contexts:

```
(A) Call Mom +Family +PeaceLoveAndHappiness @iphone @phone
```

This task has no contexts in it:

```
Email SoAndSo at soandso@example.com
```

This task has no projects in it:

```
Learn how to add 2+2
```



## Complete Tasks: 2 Format Rules

Two things indicate that a task has been completed.


### Rule 1: A completed task starts with a lowercase x character (`x`).

If a task starts with an `x` (case-sensitive and lowercase) followed directly by a space, it is marked as complete.

This is a complete task:

```
x 2011-03-03 Call Mom
```

These are not complete tasks.

```
xylophone lesson
X 2012-01-01 Make resolutions
(A) x Find ticket prices
```

We use a lowercase x so that completed tasks sort to the bottom of the task list using standard sort tools.


### Rule 2: The date of completion appears directly after the x, separated by a space.

For example:

```
x 2011-03-02 2011-03-01 Review Tim's pull request +TodoTxtTouch @github
```

If you’ve prepended the creation date to your task, on completion it will appear directly after the completion date. This is so your completed tasks sort by date using standard sort tools. Many Todo.txt clients discard priority on task completion. To preserve it, use the `key:value` format described below (e.g. `pri:A`)

With the completed date (required), if you've used the prepended date (optional), you can calculate how many days it took to complete a task.



## Additional File Format Definitions

Tool developers may define additional formatting rules for extra metadata.

Developers should use the format `key:value` to define additional metadata (e.g. `due:2010-01-02` as a due date).

Both `key` and `value` must consist of non-whitespace characters, which are not colons. Only one colon separates the `key` and `value`.

key should start with a letter to avoid conflict with time (e.g.: "12:00" is a time, not metadata)
