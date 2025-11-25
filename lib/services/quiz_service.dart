import 'dart:convert';
import 'api.dart';
import '../models/quiz.dart';

class QuizService {
  Future<List<Quiz>> getQuizzes({int? moduleId}) async {
    final endpoint = moduleId != null ? '/quizzes?module_id=$moduleId' : '/quizzes';
    final response = await Api.get(endpoint);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Quiz.fromJson(e)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to load quizzes');
    }
  }

  Future<Map<String, dynamic>> submitQuiz(int id, Map<String, String> answers) async {
    final response = await Api.post('/quizzes/$id/submit', body: {
      'answers': answers,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to submit quiz');
    }
  }

  Future<Map<String, dynamic>> getQuizResult(int id) async {
    final response = await Api.get('/quizzes/$id/result');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to get quiz result');
    }
  }
}