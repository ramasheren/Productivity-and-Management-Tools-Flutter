class Task {
  final int? id;
  final String title;
  final String? description;
  final String priority;
  final bool isCompleted;
  final String? dueDate;
  final String createdAt;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.priority,
    this.isCompleted = false,
    this.dueDate,
    required this.createdAt,
  });

  // Convert Task object to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
      'dueDate': dueDate,
      'createdAt': createdAt,
    };
  }

  // Convert Map from database to Task object
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      priority: map['priority'],
      isCompleted: map['isCompleted'] == 1,
      dueDate: map['dueDate'],
      createdAt: map['createdAt'],
    );
  }

  // Create a copy of Task with modified fields
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? priority,
    bool? isCompleted,
    String? dueDate,
    String? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
