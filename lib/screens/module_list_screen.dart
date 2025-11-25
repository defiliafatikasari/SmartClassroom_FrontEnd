import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/module_service.dart';
import '../models/module.dart';
import '../routes.dart';

class ModuleListScreen extends StatefulWidget {
  const ModuleListScreen({super.key});

  @override
  State<ModuleListScreen> createState() => _ModuleListScreenState();
}

class _ModuleListScreenState extends State<ModuleListScreen> {
  List<Module> _modules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    try {
      final moduleService = Provider.of<ModuleService>(context, listen: false);
      final modules = await moduleService.getModules();
      if (mounted) {
        setState(() {
          _modules = modules;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load modules: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modules'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadModules,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
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
                      subtitle: Text('${module.classroom?.name ?? 'Unknown class'} • ${module.type}'),
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
            ),
    );
  }
}