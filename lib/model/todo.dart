class ToDo {
  String id;
  String todoText;
  bool isDone;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
  });

  // Convert a ToDo object into a Map (for JSON encoding)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todoText': todoText,
      'isDone': isDone,
    };
  }

  // Create a ToDo object from a JSON map
  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'],
      todoText: json['todoText'],
      isDone: json['isDone'] ?? false,
    );
  }

  // ✅ Static method for sample list (used in HomeScreen)
  static List<ToDo> todoList() {
    return [
      ToDo(id: '01', todoText: 'This is by default', isDone: true),
    ];
  }
}
