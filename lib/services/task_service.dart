import 'dart:convert';
import 'api.dart';
import '../models/task.dart';

class TaskService {
  Future<List<Task>> getTasks({int? moduleId}) async {
    final endpoint = moduleId != null ? '/tasks?module_id=$moduleId' : '/tasks';
    final response = await Api.get(endpoint);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to load tasks');
    }
  }

  Future<void> submitTask(int id, String submission) async {
    final response = await Api.post('/tasks/$id/submit', body: {
      'submission': submission,
    });

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to submit task');
    }
  }
}