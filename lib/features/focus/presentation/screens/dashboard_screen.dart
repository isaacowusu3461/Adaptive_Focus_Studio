
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

  String _selectedMood = 'All';
  bool _isDeleting = false;

  static const List<String> _moods = [
    'All',
    'Focused',
    'Relaxed',
    'Motivated',
  ];

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

  Future<void> _confirmDelete(FocusPreset preset) async {
    if (_isDeleting || preset.id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Preset?'),
          content: Text(
            'Are you sure you want to delete '
            '"${preset.name}"?\n\n'
            'Any study sessions linked to this preset '
            'will also be deleted. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final deletedRows =
          await widget.dependencies.deleteFocusPreset(
        preset.id!,
      );

      if (!mounted) {
        return;
      }

      if (deletedRows == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preset was not found.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '"${preset.name}" was deleted.',
            ),
          ),
        );
      }

      _refreshPresets();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to delete preset. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  List<FocusPreset> _filterPresets(
    List<FocusPreset> presets,
  ) {
    if (_selectedMood == 'All') {
      return presets;
    }

    return presets.where((preset) {
      return preset.moodTag == _selectedMood;
    }).toList();
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

    final filteredPresets = _filterPresets(presets);

    if (filteredPresets.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.filter_alt_off_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                'No $_selectedMood presets found.',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try selecting another mood or '
                'create a new preset.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: filteredPresets.map((preset) {
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
                const SizedBox(height: 4),
                Text(
                  'Duration: ${preset.durationMinutes} minutes',
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.end,
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
                setState(() {
                  _selectedMood = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
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
