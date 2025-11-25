import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/class_service.dart';
import '../services/module_service.dart';
import '../models/classroom.dart';
import '../models/module.dart';
import '../routes.dart';

class ClassDetailScreen extends StatefulWidget {
  const ClassDetailScreen({super.key});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  Classroom? _classroom;
  List<Module> _modules = [];
  bool _isLoading = true;
  int? _classId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _classId = ModalRoute.of(context)?.settings.arguments as int?;
    if (_classId != null) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_classId == null) return;

    try {
      final classService = Provider.of<ClassService>(context, listen: false);
      final moduleService = Provider.of<ModuleService>(context, listen: false);

      final classroom = await classService.getClassDetail(_classId!);
      final modules = await moduleService.getModules(classId: _classId);

      if (mounted) {
        setState(() {
          _classroom = classroom;
          _modules = modules;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_classroom?.name ?? 'Class Detail'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classroom == null
              ? const Center(child: Text('Class not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _classroom!.name,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _classroom!.description ?? 'No description available',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Teacher: ${_classroom!.teacher?.name ?? 'Unknown'}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Modules',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      _modules.isEmpty
                          ? const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No modules available'),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _modules.length,
                              itemBuilder: (context, index) {
                                final module = _modules[index];
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
                                    subtitle: Text('Type: ${module.type}'),
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
                    ],
                  ),
                ),
    );
  }
}