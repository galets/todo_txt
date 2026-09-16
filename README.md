This package implements the todo.txt standard defined [here](https://github.com/todotxt/todo.txt). \
The main purpose is to store todos in a simple `*.txt` file, so the user has full control on his Todos.

## Features

- read Tasks from an existing file
- create tasks for a new file
- write your tasks to the specified file

## Usage

### Read from an existing `*.txt` file

```dart
var path = "/home/example/Documents/todo.txt";
var todoTxt = TodoTxt.readFromFile(path: path);
```

### Save your changes

```dart
todoTxt.writeToFile();
```

### Create a new `*.txt` file with todos

```dart
var newTodoFile = "/home/example/Documents/another_todo.txt"
var tasks = [Task("Try this awesome package!", completed: false)];
var todoTxt = TodoTxt.create(tasks: tasks, path: path);
```

## Additional information

For more information on todo.txt check their documentation on [GitHub](https://github.com/todotxt/todo.txt) or website [todo.txt](http://todotxt.org/)
