import 'package:flutter/foundation.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';

class QuizViewModel extends ChangeNotifier {
  final QuizService _quizService = QuizService();

  List<Quiz> _quizzes = [];
  bool _isLoading = false;
  String? _error;

  Quiz? _currentQuiz;
  Map<int, int> _userAnswers = {};
  bool _isSubmitting = false;
  QuizResult? _quizResult;

  // Getters
  List<Quiz> get quizzes => _quizzes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Quiz? get currentQuiz => _currentQuiz;
  Map<int, int> get userAnswers => _userAnswers;
  bool get isSubmitting => _isSubmitting;
  QuizResult? get quizResult => _quizResult;

  bool get isQuizCompleted => _quizResult != null;
  bool get canSubmitQuiz => _userAnswers.length == (_currentQuiz?.questions.length ?? 0);

  // Load quizzes
  Future<void> loadQuizzes({int? moduleId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _quizzes = await _quizService.getQuizzes(moduleId: moduleId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set current quiz for taking
  void setCurrentQuiz(Quiz quiz) {
    _currentQuiz = quiz;
    _userAnswers.clear();
    _quizResult = null;
    _error = null;
    notifyListeners();
  }

  // Answer a question
  void answerQuestion(int questionIndex, int answerIndex) {
    _userAnswers[questionIndex] = answerIndex;
    notifyListeners();
  }

  // Submit quiz
  Future<void> submitQuiz() async {
    if (_currentQuiz == null || !canSubmitQuiz) return;

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _quizService.submitQuiz(_currentQuiz!.id, _userAnswers);
      _quizResult = QuizResult.fromJson(result);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Reset quiz state
  void resetQuiz() {
    _currentQuiz = null;
    _userAnswers.clear();
    _quizResult = null;
    _error = null;
    notifyListeners();
  }

  // Get quiz result for a specific quiz
  Future<QuizResult?> getQuizResult(int quizId) async {
    try {
      final result = await _quizService.getQuizResult(quizId);
      return QuizResult.fromJson(result);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }
}