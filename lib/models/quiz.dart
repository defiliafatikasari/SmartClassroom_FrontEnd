class Quiz {
  final int id;
  final int moduleId;
  final String title;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      moduleId: json['module_id'],
      title: json['title'],
      questions: (json['questions_json'] as List<dynamic>?)
          ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module_id': moduleId,
      'title': title,
      'questions_json': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class Question {
  final String question;
  final List<String> options;
  final int answer;

  Question({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      answer: json['answer'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'answer': answer,
    };
  }
}

class QuizResult {
  final int score;
  final int total;
  final double percentage;
  final bool passed;

  QuizResult({
    required this.score,
    required this.total,
    required this.percentage,
    required this.passed,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      score: json['score'] ?? 0,
      total: json['total'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      passed: json['passed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'total': total,
      'percentage': percentage,
      'passed': passed,
    };
  }
}