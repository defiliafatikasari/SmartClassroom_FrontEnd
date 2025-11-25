class Quiz {
  final int id;
  final int moduleId;
  final String title;
  final List<Map<String, dynamic>> questionsJson;

  Quiz({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.questionsJson,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      moduleId: json['module_id'],
      title: json['title'],
      questionsJson: List<Map<String, dynamic>>.from(json['questions_json'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module_id': moduleId,
      'title': title,
      'questions_json': questionsJson,
    };
  }
}