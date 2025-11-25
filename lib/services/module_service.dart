import 'dart:convert';
import 'api.dart';
import '../models/module.dart';

class ModuleService {
  Future<List<Module>> getModules({int? classId}) async {
    final endpoint = classId != null ? '/modules?class_id=$classId' : '/modules';
    final response = await Api.get(endpoint);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Module.fromJson(e)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to load modules');
    }
  }

  Future<Module> getModuleDetail(int id) async {
    final response = await Api.get('/modules/$id');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Module.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to load module detail');
    }
  }

  Future<void> markModuleComplete(int id) async {
    final response = await Api.post('/modules/$id/complete');

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to mark module complete');
    }
  }
}