import 'user.dart';

class Classroom {
  final int id;
  final String name;
  final String? description;
  final int teacherId;
  final User? teacher;

  Classroom({
    required this.id,
    required this.name,
    this.description,
    required this.teacherId,
    this.teacher,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      teacherId: json['teacher_id'],
      teacher: json['teacher'] != null ? User.fromJson(json['teacher']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'teacher_id': teacherId,
      'teacher': teacher?.toJson(),
    };
  }
}