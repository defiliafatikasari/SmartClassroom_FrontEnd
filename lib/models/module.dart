import 'classroom.dart';
import 'task.dart';
import 'quiz.dart';

class Module {
  final int id;
  final int classId;
  final String title;
  final String type;
  final String contentUrl;
  final Classroom? classroom;
  final List<Task>? tasks;
  final List<Quiz>? quizzes;

  Module({
    required this.id,
    required this.classId,
    required this.title,
    required this.type,
    required this.contentUrl,
    this.classroom,
    this.tasks,
    this.quizzes,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      classId: json['class_id'],
      title: json['title'],
      type: json['type'],
      contentUrl: json['content_url'],
      classroom: json['classroom'] != null ? Classroom.fromJson(json['classroom']) : null,
      tasks: json['tasks'] != null ? (json['tasks'] as List).map((e) => Task.fromJson(e)).toList() : null,
      quizzes: json['quizzes'] != null ? (json['quizzes'] as List).map((e) => Quiz.fromJson(e)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'title': title,
      'type': type,
      'content_url': contentUrl,
      'classroom': classroom?.toJson(),
      'tasks': tasks?.map((e) => e.toJson()).toList(),
      'quizzes': quizzes?.map((e) => e.toJson()).toList(),
    };
  }
}