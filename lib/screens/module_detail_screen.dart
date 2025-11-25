import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Widget _buildContentViewer() {
    if (_module == null) return const SizedBox.shrink();

    switch (_module!.type.toLowerCase()) {
      case 'pdf':
        return _buildPdfViewer();
      case 'video':
        return _buildVideoPlayer();
      case 'text':
      default:
        return _buildTextContent();
    }
  }

  Widget _buildPdfViewer() {
    // For demo purposes, we'll show a placeholder with open button
    // In a real app, you'd load the PDF from the contentUrl
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'PDF Document',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _module!.contentUrl,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                final url = _module!.contentUrl;
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cannot open PDF')),
                  );
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open PDF'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final videoId = YoutubePlayer.convertUrlToId(_module!.contentUrl);
    if (videoId == null) {
      return _buildTextContent();
    }

    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            YoutubePlayer(
              controller: controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Video Content',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.article,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Text Content',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _module!.contentUrl,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
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
                      _buildContentViewer(),
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