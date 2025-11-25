class Progress {
  final int id;
  final int userId;
  final int moduleId;
  final bool completed;
  final double? score;

  Progress({
    required this.id,
    required this.userId,
    required this.moduleId,
    required this.completed,
    this.score,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['id'],
      userId: json['user_id'],
      moduleId: json['module_id'],
      completed: json['completed'] ?? false,
      score: json['score'] != null ? double.parse(json['score'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'module_id': moduleId,
      'completed': completed,
      'score': score,
    };
  }
}