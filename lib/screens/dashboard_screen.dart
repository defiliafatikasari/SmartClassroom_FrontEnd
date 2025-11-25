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
      final recService = Provider.of<RecommendationService>(context, listen: false);

      final classes = await classService.getClasses();
      final recs = await recService.getRecommendations();

      if (!mounted) return;

      setState(() {
        _classes = classes;
        _recommendations = recs;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $e")),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.logout();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello👋",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800)),
            Text(
              "Welcome to Smart Classroom",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 28),
            color: Colors.indigo,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 28),
            color: Colors.redAccent,
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Featured Section
                    _buildFeaturedBanner(),

                    const SizedBox(height: 24),

                    // Classes
                    _sectionTitle("Your Classes", onViewAll: () {
                      Navigator.pushNamed(context, AppRoutes.classList);
                    }),
                    const SizedBox(height: 12),

                    _classes.isEmpty
                        ? _emptyCard("No classes available")
                        : _horizontalClassList(),

                    const SizedBox(height: 32),

                    // Recommendations
                    _sectionTitle("Recommended for You"),
                    const SizedBox(height: 12),

                    _recommendations.isEmpty
                        ? _emptyCard("No recommendations available")
                        : _recommendationList(),

                    const SizedBox(height: 32),

                    // Quick Actions
                    _sectionTitle("Quick Actions"),
                    const SizedBox(height: 12),

                    _quickActionsGrid(),
                  ],
                ),
              ),
            ),
    );
  }

  // Featured Banner
  Widget _buildFeaturedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade500, Colors.deepPurple.shade400],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.white, size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Terus belajar! Jelajahi modul yang direkomendasikan untuk Anda.",
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          )
        ],
      ),
    );
  }

  // Reusable section title
  Widget _sectionTitle(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade900)),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text("View All"),
          )
      ],
    );
  }

  Widget _horizontalClassList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _classes.length,
        itemBuilder: (context, index) {
          final c = _classes[index];
          return Container(
            width: 220,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 2)
              ],
            ),
            child: InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.classDetail,
                arguments: c.id,
              ),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.class_, size: 40, color: Colors.indigo.shade600),
                    const SizedBox(height: 8),
                    Text(c.name,
                        maxLines: 2,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      c.description ?? "No description",
                      maxLines: 2,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _recommendationList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recommendations.length,
      itemBuilder: (context, index) {
        final m = _recommendations[index];
        final icon = m.type == "pdf"
            ? Icons.picture_as_pdf
            : m.type == "video"
                ? Icons.video_library
                : Icons.article;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: Icon(icon, size: 30, color: Colors.indigo),
            title: Text(m.title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            subtitle: Text(m.classroom?.name ?? "Unknown Class"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.moduleDetail,
                arguments: m.id,
              );
            },
          ),
        );
      },
    );
  }

  Widget _emptyCard(String text) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(text),
      ),
    );
  }

  Widget _quickActionsGrid() {
    List<Map<String, dynamic>> actions = [
      {"title": "Modules", "icon": Icons.library_books, "route": AppRoutes.moduleList},
      {"title": "Tasks", "icon": Icons.assignment, "route": AppRoutes.taskList},
      {"title": "Quizzes", "icon": Icons.quiz, "route": AppRoutes.quizList},
      {"title": "History", "icon": Icons.history, "route": AppRoutes.quizHistory},
      {"title": "AI Tips", "icon": Icons.lightbulb, "route": AppRoutes.recommendation},
      {"title": "Profile", "icon": Icons.person, "route": AppRoutes.profile},
    ];

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: actions.map((a) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pushNamed(context, a["route"]),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(a["icon"], size: 38, color: Colors.indigo),
                  const SizedBox(height: 12),
                  Text(a["title"],
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
