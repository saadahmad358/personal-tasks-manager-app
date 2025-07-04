import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/todo.dart';
import '../constants/colors.dart';
import '../widgets/todo_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ToDo> todosList = [];
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();
  ToDo? _lastDeleted;

  @override
  void initState() {
    super.initState();
    _loadFromLocal();
  }

  Future<void> _saveToLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> todoJsonList =
        todosList.map((todo) => json.encode(todo.toJson())).toList();
    await prefs.setStringList('todos', todoJsonList);
  }

  Future<void> _loadFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? todoJsonList = prefs.getStringList('todos');
    setState(() {
      if (todoJsonList != null) {
        todosList = todoJsonList
            .map((item) => ToDo.fromJson(json.decode(item)))
            .toList();
      } else {
        todosList = ToDo.todoList(); // fallback
      }
      _runFilter('');
    });
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
    _saveToLocal();
  }

  void _deleteToDoItem(String id, ToDo todo) {
    setState(() {
      todosList.removeWhere((item) => item.id == id);
      _foundToDo.removeWhere((item) => item.id == id);
      _lastDeleted = todo;
    });
    _saveToLocal();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Task '${todo.todoText}' removed",
          style: const TextStyle(color: tdWhite),
        ),
        backgroundColor: tdBlack,
        action: SnackBarAction(
          label: "Undo",
          textColor: tdGreen,
          onPressed: () {
            setState(() {
              todosList.add(_lastDeleted!);
              _runFilter('');
            });
            _saveToLocal();
          },
        ),
      ),
    );
  }

  void _addToDoItem(String toDo) {
    if (toDo.trim().isEmpty) return;
    final newTodo = ToDo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      todoText: toDo,
    );
    setState(() {
      todosList.add(newTodo);
      _runFilter('');
    });
    _todoController.clear();
    _saveToLocal();
  }

  void _runFilter(String keyword) {
    List<ToDo> results = [];
    if (keyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) =>
              item.todoText.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundToDo = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                searchBox(),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'All Tasks',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: tdWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                itemCount: _foundToDo.length,
                itemBuilder: (context, index) {
                  final todo = _foundToDo.reversed.toList()[index];
                  return Dismissible(
                    key: Key(todo.id),
                    background: Container(
                      color: tdRed,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      _deleteToDoItem(todo.id, todo);
                    },
                    child: TodoItem(
                      todo: todo,
                      onToDoChanged: _handleToDoChange,
                      onDeleteItem: (id) => _deleteToDoItem(id, todo),
                    ),
                  );
                },
              ),
            ),
          ),
          _buildAddToDoBar(),
        ],
      ),
    );
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: tdWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        style: const TextStyle(color: tdBlack),
        decoration: const InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Icon(Icons.search, color: tdGreen),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 30,
            minHeight: 30,
          ),
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildAddToDoBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: tdBGColor,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: tdWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _todoController,
                decoration: const InputDecoration(
                  hintText: 'Add a new task',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _addToDoItem(_todoController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: tdGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(60, 60),
              elevation: 5,
            ),
            child: const Icon(Icons.add, size: 30, color: Colors.white),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      title: const Text(
        'Tasks List',
        style: TextStyle(
          color: tdGreen,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }
}
