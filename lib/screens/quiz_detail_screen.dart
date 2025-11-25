import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quiz_viewmodel.dart';
import '../models/quiz.dart';
import '../widgets/question_card.dart';
import '../widgets/submit_button.dart';

class QuizDetailScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizDetailScreen({super.key, required this.quiz});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizViewModel>().setCurrentQuiz(widget.quiz);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onAnswerSelected(int questionIndex, int answerIndex) {
    context.read<QuizViewModel>().answerQuestion(questionIndex, answerIndex);
  }

  void _onSubmitQuiz() async {
    final viewModel = context.read<QuizViewModel>();
    await viewModel.submitQuiz();

    if (viewModel.quizResult != null && mounted) {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    final viewModel = context.read<QuizViewModel>();
    final result = viewModel.quizResult!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          result.passed ? 'Congratulations! 🎉' : 'Quiz Completed',
          style: TextStyle(
            color: result.passed ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: ${result.score}/${result.total}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Percentage: ${result.percentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: result.passed
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.passed
                    ? 'You passed the quiz! Great job!'
                    : 'You didn\'t pass this time. Keep learning!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: result.passed ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to quiz list
            },
            child: const Text('Back to Quizzes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizViewModel>(
      builder: (context, viewModel, child) {
        final quiz = viewModel.currentQuiz;
        if (quiz == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(quiz.title),
            actions: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${_currentPage + 1}/${quiz.questions.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentPage + 1) / quiz.questions.length,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              ),

              // Questions
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                  itemCount: quiz.questions.length,
                  itemBuilder: (context, index) {
                    final question = quiz.questions[index];
                    return QuestionCard(
                      question: question,
                      questionIndex: index,
                      selectedAnswer: viewModel.userAnswers[index],
                      onAnswerSelected: (answerIndex) =>
                          _onAnswerSelected(index, answerIndex),
                    );
                  },
                ),
              ),

              // Navigation and submit
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Previous button
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                        ),
                      )
                    else
                      const Spacer(),

                    const SizedBox(width: 16),

                    // Next/Submit button
                    Expanded(
                      flex: 2,
                      child: viewModel.canSubmitQuiz && _currentPage == quiz.questions.length - 1
                          ? SubmitButton(
                              onPressed: viewModel.isSubmitting ? null : _onSubmitQuiz,
                              isLoading: viewModel.isSubmitting,
                              text: 'Submit Quiz',
                            )
                          : FilledButton.icon(
                              onPressed: _currentPage < quiz.questions.length - 1
                                  ? () {
                                      _pageController.nextPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.arrow_forward),
                              label: Text(
                                _currentPage < quiz.questions.length - 1
                                    ? 'Next'
                                    : 'Submit Quiz',
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}