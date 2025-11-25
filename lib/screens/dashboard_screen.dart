import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/class_service.dart';
import '../services/recommendation_service.dart';
import '../models/classroom.dart';
import '../models/module.dart';
import '../routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Classroom> _classes = [];
  List<Module> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final classService = Provider.of<ClassService>(context, listen: false);
      final recommendationService = Provider.of<RecommendationService>(context, listen: false);

      final classes = await classService.getClasses();
      final recommendations = await recommendationService.getRecommendations();

      if (mounted) {
        setState(() {
          _classes = classes;
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Smart Classroom',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),

                    // Classes Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Classes',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.classList);
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _classes.isEmpty
                        ? const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No classes available'),
                            ),
                          )
                        : SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _classes.length,
                              itemBuilder: (context, index) {
                                final classroom = _classes[index];
                                return Card(
                                  margin: const EdgeInsets.only(right: 16),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.classDetail,
                                        arguments: classroom.id,
                                      );
                                    },
                                    child: SizedBox(
                                      width: 200,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.school,
                                              size: 32,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              classroom.name,
                                              style: Theme.of(context).textTheme.titleMedium,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              classroom.description ?? 'No description',
                                              style: Theme.of(context).textTheme.bodySmall,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                    const SizedBox(height: 32),

                    // Recommendations Section
                    Text(
                      'Recommended for You',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    _recommendations.isEmpty
                        ? const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No recommendations available'),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _recommendations.length,
                            itemBuilder: (context, index) {
                              final module = _recommendations[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Icon(
                                    module.type == 'pdf' ? Icons.picture_as_pdf :
                                    module.type == 'video' ? Icons.video_file :
                                    Icons.article,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  title: Text(module.title),
                                  subtitle: Text(module.classroom?.name ?? 'Unknown class'),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.moduleDetail,
                                      arguments: module.id,
                                    );
                                  },
                                ),
                              );
                            },
                          ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildActionCard(
                          context,
                          'Modules',
                          Icons.library_books,
                          () => Navigator.pushNamed(context, AppRoutes.moduleList),
                        ),
                        _buildActionCard(
                          context,
                          'Tasks',
                          Icons.assignment,
                          () => Navigator.pushNamed(context, AppRoutes.taskList),
                        ),
                        _buildActionCard(
                          context,
                          'Quizzes',
                          Icons.quiz,
                          () => Navigator.pushNamed(context, AppRoutes.quizList),
                        ),
                        _buildActionCard(
                          context,
                          'Quiz History',
                          Icons.history,
                          () => Navigator.pushNamed(context, AppRoutes.quizHistory),
                        ),
                        _buildActionCard(
                          context,
                          'Recommendations',
                          Icons.lightbulb,
                          () => Navigator.pushNamed(context, AppRoutes.recommendation),
                        ),
                        _buildActionCard(
                          context,
                          'Profile',
                          Icons.person,
                          () => Navigator.pushNamed(context, AppRoutes.profile),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}