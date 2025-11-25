import 'dart:convert';
import 'api.dart';
import '../models/classroom.dart';

class ClassService {
  Future<List<Classroom>> getClasses() async {
    final response = await Api.get('/classes');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Classroom.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load classes');
    }
  }

  Future<void> joinClass(int classId) async {
    final response = await Api.post('/classes/join', body: {'class_id': classId});

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to join class');
    }
  }

  Future<Classroom> getClassDetail(int id) async {
    final response = await Api.get('/classes/$id');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Classroom.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to load class detail');
    }
  }

  Future<Map<String, dynamic>> getClassStudents(int id) async {
    final response = await Api.get('/classes/$id/students');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to load class students');
    }
  }
}