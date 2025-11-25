import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/class_list_screen.dart';
import 'screens/class_detail_screen.dart';
import 'screens/module_list_screen.dart';
import 'screens/module_detail_screen.dart';
import 'screens/task_list_screen.dart';
import 'screens/quiz_list_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_panel_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String classList = '/classes';
  static const String classDetail = '/class-detail';
  static const String moduleList = '/modules';
  static const String moduleDetail = '/module-detail';
  static const String taskList = '/tasks';
  static const String quizList = '/quizzes';
  static const String recommendation = '/recommendations';
  static const String profile = '/profile';
  static const String adminPanel = '/admin';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      dashboard: (context) => const DashboardScreen(),
      classList: (context) => const ClassListScreen(),
      classDetail: (context) => const ClassDetailScreen(),
      moduleList: (context) => const ModuleListScreen(),
      moduleDetail: (context) => const ModuleDetailScreen(),
      taskList: (context) => const TaskListScreen(),
      quizList: (context) => const QuizListScreen(),
      recommendation: (context) => const RecommendationScreen(),
      profile: (context) => const ProfileScreen(),
      adminPanel: (context) => const AdminPanelScreen(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Handle dynamic routes here if needed
    return null;
  }
}