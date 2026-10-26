
import 'package:flutter/material.dart';

import '../../domain/entities/focus_preset.dart';
import '../../domain/entities/session_log.dart';
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
      DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late Future<List<FocusPreset>> _presetsFuture;
  late Future<List<SessionLog>> _sessionsFuture;

  String _selectedMood = 'All';
  bool _isDeleting = false;

  static const _moods = [
    'All',
    'Focused',
    'Relaxed',
    'Motivated',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _presetsFuture =
        widget.dependencies.presetRepository.getAllPresets();

    _sessionsFuture =
        widget.dependencies.sessionRepository.getAllSessions();
  }

  void reload() {
    setState(_loadData);
  }

  Future<void> _openPresetForm({FocusPreset? preset}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PresetFormScreen(
          createFocusPreset:
              widget.dependencies.createFocusPreset,
          updateFocusPreset:
              widget.dependencies.updateFocusPreset,
          preset: preset,
        ),
      ),
    );

    if (mounted && saved == true) {
      reload();
    }
  }

  Future<void> _startPreset(FocusPreset preset) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => FocusTimerScreen(
          preset: preset,
          saveSessionLog:
              widget.dependencies.saveSessionLog,
        ),
      ),
    );

    if (mounted) {
      reload();
    }
  }

  Future<void> _confirmDelete(FocusPreset preset) async {
    if (_isDeleting || preset.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Preset?'),
        content: Text(
          'Are you sure you want to delete '
          '"${preset.name}"?\n\n'
          'Any study sessions linked to this preset '
          'will also be deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final deletedRows =
          await widget.dependencies.deleteFocusPreset(
        preset.id!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            deletedRows == 0
                ? 'Preset was not found.'
                : '"${preset.name}" was deleted.',
          ),
        ),
      );

      reload();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to delete preset.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Widget _buildSummary(List<SessionLog> sessions) {
    final completed = sessions
        .where((session) => session.status == 'completed')
        .length;

    final totalSeconds = sessions.fold<int>(
      0,
      (sum, session) => sum + session.completedSeconds,
    );

    final average = sessions.isEmpty
        ? 0.0
        : totalSeconds / sessions.length / 60;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Completed Sessions: $completed'),
            const SizedBox(height: 8),
            Text(
              'Total Study Time: '
              '${(totalSeconds / 60).toStringAsFixed(1)} minutes',
            ),
            const SizedBox(height: 8),
            Text(
              'Average Duration: '
              '${average.toStringAsFixed(1)} minutes',
            ),
          ],
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
              Icon(Icons.bookmark_border, size: 48),
              SizedBox(height: 12),
              Text('No focus presets yet.'),
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

    final filtered = _selectedMood == 'All'
        ? presets
        : presets
            .where((preset) =>
                preset.moodTag == _selectedMood)
            .toList();

    if (filtered.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No $_selectedMood presets found.',
          ),
        ),
      );
    }

    return Column(
      children: filtered.map((preset) {
        return Card(
          key: ValueKey('preset_${preset.id}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preset.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Mood: ${preset.moodTag}'),
                Text(
                  'Duration: ${preset.durationMinutes} minutes',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isDeleting
                          ? null
                          : () => _openPresetForm(
                                preset: preset,
                              ),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isDeleting
                          ? null
                          : () => _confirmDelete(preset),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isDeleting
                          ? null
                          : () => _startPreset(preset),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                    ),
                  ],
                ),
              ],
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
          FutureBuilder<List<SessionLog>>(
            future: _sessionsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text(
                  'Unable to load study summary.',
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return _buildSummary(snapshot.data!);
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
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
                onPressed: _isDeleting
                    ? null
                    : () => _openPresetForm(),
                icon: const Icon(Icons.add),
                label: const Text('New'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: const ValueKey('mood_filter'),
            initialValue: _selectedMood,
            decoration: const InputDecoration(
              labelText: 'Filter by Mood',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.filter_list),
            ),
            items: _moods.map((mood) {
              return DropdownMenuItem(
                value: mood,
                child: Text(mood),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedMood = value);
              }
            },
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<FocusPreset>>(
            future: _presetsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ElevatedButton(
                  onPressed: reload,
                  child: const Text('Retry'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return _buildPresetList(snapshot.data!);
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
