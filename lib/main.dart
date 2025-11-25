import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'services/auth_service.dart';
import 'services/class_service.dart';
import 'services/module_service.dart';
import 'services/task_service.dart';
import 'services/quiz_service.dart';
import 'services/recommendation_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ClassService>(create: (_) => ClassService()),
        Provider<ModuleService>(create: (_) => ModuleService()),
        Provider<TaskService>(create: (_) => TaskService()),
        Provider<QuizService>(create: (_) => QuizService()),
        Provider<RecommendationService>(create: (_) => RecommendationService()),
      ],
      child: MaterialApp(
        title: 'Smart Classroom',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.login,
        routes: AppRoutes.getRoutes(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
