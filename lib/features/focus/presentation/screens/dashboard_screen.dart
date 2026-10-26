
import 'package:flutter/material.dart';

import '../../domain/entities/focus_preset.dart';
import '../../domain/entities/session_log.dart';
import '../../domain/entities/session_scout_recommendation.dart';
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
  String _scoutMood = 'Focused';

  bool _isDeleting = false;
  bool _isLoadingRecommendation = false;

  SessionScoutRecommendation? _recommendation;

  static const List<String> _moods = [
    'All',
    'Focused',
    'Relaxed',
    'Motivated',
  ];

  static const List<String> _scoutMoods = [
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
    setState(() {
      _loadData();
      _recommendation = null;
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

  Future<void> _getRecommendation() async {
    if (_isLoadingRecommendation) return;

    setState(() {
      _isLoadingRecommendation = true;
      _recommendation = null;
    });

    try {
      final result = await widget.dependencies
          .getSessionScoutRecommendation(
        moodTag: _scoutMood,
      );

      if (!mounted) return;

      setState(() {
        _recommendation = result;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to generate a recommendation.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRecommendation = false;
        });
      }
    }
  }

  Future<void> _applyRecommendation() async {
    final recommendation = _recommendation;

    if (recommendation == null) return;

    try {
      final presets =
          await widget.dependencies.presetRepository.getAllPresets();

      if (!mounted) return;

      final matchingPresets = presets
          .where((preset) =>
              preset.moodTag == recommendation.moodTag)
          .toList();

      if (matchingPresets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Create a ${recommendation.moodTag} preset '
              'before applying this recommendation.',
            ),
          ),
        );
        return;
      }

      final selectedPreset = await showDialog<FocusPreset>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: const Text('Apply to Focus Preset'),
          children: matchingPresets.map((preset) {
            return SimpleDialogOption(
              onPressed: () =>
                  Navigator.pop(dialogContext, preset),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: Text(
                  '${preset.name} '
                  '(${preset.durationMinutes} min)',
                ),
              ),
            );
          }).toList(),
        ),
      );

      if (selectedPreset == null || !mounted) return;

      final updatedRows =
          await widget.dependencies.updateFocusPreset(
        id: selectedPreset.id!,
        name: selectedPreset.name,
        moodTag: selectedPreset.moodTag,
        durationMinutes: recommendation.suggestedMinutes,
      );

      if (!mounted) return;

      if (updatedRows == 0) {
        throw StateError('Preset not found.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${selectedPreset.name} updated to '
            '${recommendation.suggestedMinutes} minutes.',
          ),
        ),
      );

      reload();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to apply recommendation.',
          ),
        ),
      );
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

  Widget _buildSessionScout() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Get a study duration recommendation '
              'based on your recent sessions.',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: const ValueKey('scout_mood'),
              initialValue: _scoutMood,
              decoration: const InputDecoration(
                labelText: 'Select Mood',
                border: OutlineInputBorder(),
              ),
              items: _scoutMoods.map((mood) {
                return DropdownMenuItem(
                  value: mood,
                  child: Text(mood),
                );
              }).toList(),
              onChanged: _isLoadingRecommendation
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _scoutMood = value;
                          _recommendation = null;
                        });
                      }
                    },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoadingRecommendation
                  ? null
                  : _getRecommendation,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Get Recommendation'),
            ),
            if (_isLoadingRecommendation) ...[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
            if (_recommendation != null) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Suggested Duration: '
                '${_recommendation!.suggestedMinutes} minutes',
                key: const ValueKey('scout_result'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(_recommendation!.explanation),
              const SizedBox(height: 12),
              Text(
                'Sessions Used: '
                '${_recommendation!.sessionsUsed}',
              ),
              if (_recommendation!.usedFallback)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Using the standard duration until '
                    'more study history is available.',
                  ),
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: _applyRecommendation,
                    child: const Text('Apply'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _recommendation = null;
                      });
                    },
                    child: const Text('Not now'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
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
          _buildSessionScout(),
        ],
      ),
    );
  }
}
