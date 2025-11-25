import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/class_service.dart';
import '../models/classroom.dart';
import '../routes.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  List<Classroom> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final classService = Provider.of<ClassService>(context, listen: false);
      final classes = await classService.getClasses();
      if (mounted) {
        setState(() {
          _classes = classes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load classes: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadClasses,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _classes.length,
                itemBuilder: (context, index) {
                  final classroom = _classes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.school,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(classroom.name),
                      subtitle: Text(classroom.description ?? 'No description'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.classDetail,
                          arguments: classroom.id,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}