import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/module_service.dart';
import '../models/module.dart';

class ModuleDetailScreen extends StatefulWidget {
  const ModuleDetailScreen({super.key});

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  Module? _module;
  bool _isLoading = true;
  int? _moduleId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _moduleId = ModalRoute.of(context)?.settings.arguments as int?;
    if (_moduleId != null) {
      _loadModule();
    }
  }

  Future<void> _loadModule() async {
    if (_moduleId == null) return;

    try {
      final moduleService = Provider.of<ModuleService>(context, listen: false);
      final module = await moduleService.getModuleDetail(_moduleId!);
      if (mounted) {
        setState(() {
          _module = module;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load module: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markComplete() async {
    if (_moduleId == null) return;

    try {
      final moduleService = Provider.of<ModuleService>(context, listen: false);
      await moduleService.markModuleComplete(_moduleId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Module marked as completed!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark complete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_module?.title ?? 'Module Detail'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _module == null
              ? const Center(child: Text('Module not found'))
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
                                _module!.title,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Class: ${_module!.classroom?.name ?? 'Unknown'}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Chip(
                                label: Text('Type: ${_module!.type}'),
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Content',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(
                                _module!.type == 'pdf' ? Icons.picture_as_pdf :
                                _module!.type == 'video' ? Icons.video_file :
                                Icons.article,
                                size: 64,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _module!.contentUrl,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _markComplete,
                        child: const Text('Mark as Completed'),
                      ),
                    ],
                  ),
                ),
    );
  }
}