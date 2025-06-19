import 'package:flutter/material.dart';
import '../model/todo.dart';
import '../constants/colors.dart';

class TodoItem extends StatelessWidget {
  final ToDo todo;
  final onToDoChanged;
  final onDeleteItem;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToDoChanged,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: tdBlack,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: IconButton(
          icon: Icon(
            todo.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: todo.isDone ? tdGreen : tdGrey,
          ),
          onPressed: () => onToDoChanged(todo),
        ),
        title: Text(
          todo.todoText,
          style: TextStyle(
            color: tdWhite,
            fontSize: 18,
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: tdRed),
          onPressed: () => onDeleteItem(todo.id),
        ),
      ),
    );
  }
}
