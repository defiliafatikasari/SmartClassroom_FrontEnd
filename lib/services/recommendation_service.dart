import 'dart:convert';
import 'api.dart';
import '../models/module.dart';

class RecommendationService {
  Future<List<Module>> getRecommendations() async {
    final response = await Api.get('/recommendations');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Module.fromJson(e)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to load recommendations');
    }
  }
}