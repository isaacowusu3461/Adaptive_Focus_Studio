
import 'package:flutter/material.dart';

import '../../domain/entities/focus_preset.dart';
import '../providers/focus_dependencies.dart';
import 'focus_timer_screen.dart';
import 'preset_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  final FocusDependencies dependencies;

  const DashboardScreen({
    super.key,
    required this.dependencies,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<FocusPreset>> _presetsFuture;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  void _loadPresets() {
    _presetsFuture =
        widget.dependencies.presetRepository.getAllPresets();
  }

  void _refreshPresets() {
    setState(() {
      _loadPresets();
    });
  }

  Future<void> _openPresetForm() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PresetFormScreen(
          createFocusPreset:
              widget.dependencies.createFocusPreset,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (saved == true) {
      _refreshPresets();
    }
  }

  void _startPreset(FocusPreset preset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FocusTimerScreen(
          preset: preset,
        ),
      ),
    );
  }

  Widget _buildPresetList(List<FocusPreset> presets) {
    if (presets.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.bookmark_border,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 12),
              Text(
                'No focus presets yet.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tap New to create your first study preset.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: presets.map((preset) {
        return Card(
          child: ListTile(
            title: Text(preset.name),
            subtitle: Text(
              'Mood: ${preset.moodTag} | '
              'Duration: ${preset.durationMinutes} minutes',
            ),
            trailing: ElevatedButton(
              onPressed: () => _startPreset(preset),
              child: const Text('Start'),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaptive Focus Studio'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Study Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Completed Sessions: 0'),
                  SizedBox(height: 8),
                  Text('Average Duration: 0 minutes'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'My Focus Presets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _openPresetForm,
                icon: const Icon(Icons.add),
                label: const Text('New'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<FocusPreset>>(
            future: _presetsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Column(
                  children: [
                    const Text(
                      'Unable to load focus presets.',
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refreshPresets,
                      child: const Text('Retry'),
                    ),
                  ],
                );
              }

              return _buildPresetList(snapshot.data ?? []);
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Session Scout',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suggested Duration: 25 minutes',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Personalized study recommendations '
                    'will be available soon.',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Session Scout coming soon!',
                              ),
                            ),
                          );
                        },
                        child: const Text('Apply'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Not now'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
