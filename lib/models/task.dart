class Task {
  final int id;
  final int moduleId;
  final String title;
  final String? description;
  final String? dueDate;

  Task({
    required this.id,
    required this.moduleId,
    required this.title,
    this.description,
    this.dueDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      moduleId: json['module_id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['due_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module_id': moduleId,
      'title': title,
      'description': description,
      'due_date': dueDate,
    };
  }
}