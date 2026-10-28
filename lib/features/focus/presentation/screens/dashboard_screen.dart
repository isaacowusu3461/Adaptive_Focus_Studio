
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/animation/app_motion.dart';
import '../../../../core/widgets/animated_focus_indicator.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/entities/focus_preset.dart';
import '../../domain/entities/session_log.dart';
import '../../domain/entities/session_scout_recommendation.dart';
import '../providers/focus_dependencies.dart';
import '../providers/focus_providers.dart';
import '../providers/motion_provider.dart';
import 'focus_timer_screen.dart';
import 'preset_form_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final FocusDependencies dependencies;

  const DashboardScreen({
    super.key,
    required this.dependencies,
  });

  @override
  ConsumerState<DashboardScreen> createState() =>
      DashboardScreenState();
}

class DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedMood = 'All';
  String _scoutMood = 'Focused';
  bool _isDeleting = false;
  bool _showRecommendation = false;

  static const _moods = [
    'All',
    'Focused',
    'Relaxed',
    'Motivated',
  ];

  void reload() {
    ref.invalidate(focusPresetsProvider);
    ref.invalidate(sessionHistoryProvider);
    setState(() => _showRecommendation = false);
  }

  Future<void> _openPresetForm({FocusPreset? preset}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PresetFormScreen(
          createFocusPreset: ref.read(createFocusPresetProvider),
          updateFocusPreset: ref.read(updateFocusPresetProvider),
          preset: preset,
        ),
      ),
    );

    if (mounted && saved == true) reload();
  }

  Future<void> _startPreset(FocusPreset preset) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => FocusTimerScreen(
          preset: preset,
          saveSessionLog: ref.read(saveSessionLogProvider),
        ),
      ),
    );

    if (mounted) reload();
  }

  Future<void> _confirmDelete(FocusPreset preset) async {
    if (_isDeleting || preset.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Preset?'),
        content: Text(
          'Delete "${preset.name}"? Related session logs '
          'will also be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      await ref.read(deleteFocusPresetProvider)(preset.id!);

      if (!mounted) return;

      reload();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${preset.name}" was deleted.')),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to delete preset.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _applyRecommendation(
    SessionScoutRecommendation recommendation,
  ) async {
    try {
      final presets =
          await ref.read(focusPresetRepositoryProvider).getAllPresets();

      if (!mounted) return;

      final matching = presets
          .where((preset) => preset.moodTag == recommendation.moodTag)
          .toList();

      if (matching.isEmpty) {
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

      final selected = await showDialog<FocusPreset>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: const Text('Apply to Focus Preset'),
          children: matching.map((preset) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, preset),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '${preset.name} (${preset.durationMinutes} min)',
                ),
              ),
            );
          }).toList(),
        ),
      );

      if (selected == null || !mounted) return;

      final updated = await ref.read(updateFocusPresetProvider)(
        id: selected.id!,
        name: selected.name,
        moodTag: selected.moodTag,
        durationMinutes: recommendation.suggestedMinutes,
      );

      if (updated == 0) throw StateError('Preset not found.');
      if (!mounted) return;

      reload();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${selected.name} updated to '
            '${recommendation.suggestedMinutes} minutes.',
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to apply recommendation.'),
          ),
        );
      }
    }
  }

  Widget _buildSummary(List<SessionLog> sessions) {
    final completed =
        sessions.where((s) => s.status == 'completed').length;

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
    final filtered = _selectedMood == 'All'
        ? presets
        : presets.where((p) => p.moodTag == _selectedMood).toList();

    if (presets.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No focus presets yet.'),
        ),
      );
    }

    if (filtered.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No $_selectedMood presets found.'),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 650 ? 2 : 1;
        final cardWidth = columns == 2
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: filtered.map((preset) {
            return SizedBox(
              width: cardWidth,
              child: Card(
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
                                : () => _openPresetForm(preset: preset),
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
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSessionScout(bool reduceMotion) {
    final recommendationState = _showRecommendation
        ? ref.watch(sessionScoutProvider(_scoutMood))
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedFocusIndicator(
                  isActive: _showRecommendation,
                  reduceMotion: reduceMotion,
                  size: 48,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Get a study duration recommendation '
                    'based on your recent sessions.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: const ValueKey('scout_mood'),
              initialValue: _scoutMood,
              decoration: const InputDecoration(
                labelText: 'Select Mood',
                border: OutlineInputBorder(),
              ),
              items: _moods.skip(1).map((mood) {
                return DropdownMenuItem(
                  value: mood,
                  child: Text(mood),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _scoutMood = value;
                    _showRecommendation = false;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(sessionScoutProvider(_scoutMood));
                setState(() => _showRecommendation = true);
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Get Recommendation'),
            ),
            AnimatedSize(
              duration: AppMotion.duration(
                AppMotion.medium,
                reduceMotion: reduceMotion,
              ),
              curve: AppMotion.standardCurve,
              alignment: Alignment.topCenter,
              child: _showRecommendation
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _buildRecommendationResult(
                        recommendationState!,
                        reduceMotion,
                      ),
                    )
                  : const SizedBox(
                      key: ValueKey('scout_hidden'),
                      width: double.infinity,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationResult(
    AsyncValue<SessionScoutRecommendation> state,
    bool reduceMotion,
  ) {
    return state.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Unable to generate a recommendation.'),
          TextButton(
            onPressed: () {
              ref.invalidate(sessionScoutProvider(_scoutMood));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
      data: (recommendation) => AnimatedOpacity(
        opacity: 1,
        duration: AppMotion.duration(
          AppMotion.short,
          reduceMotion: reduceMotion,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Suggested Duration: '
              '${recommendation.suggestedMinutes} minutes',
              key: const ValueKey('scout_result'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(recommendation.explanation),
            const SizedBox(height: 12),
            Text('Sessions Used: ${recommendation.sessionsUsed}'),
            if (recommendation.usedFallback)
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
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      _applyRecommendation(recommendation),
                  child: const Text('Apply'),
                ),
                OutlinedButton(
                  onPressed: () {
                    setState(() => _showRecommendation = false);
                  },
                  child: const Text('Not now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final presetsState = ref.watch(focusPresetsProvider);
    final sessionsState = ref.watch(sessionHistoryProvider);
    final reduceMotion =
    ref.watch(reduceMotionProvider).when(
      data: (value) => value,
      loading: () => false,
      error: (error, stackTrace) => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaptive Focus Studio'),
      ),
      body: ResponsiveContent(
        child: ListView(
          children: [
            const Text(
              'Study Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            sessionsState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => TextButton(
                onPressed: () =>
                    ref.invalidate(sessionHistoryProvider),
                child: const Text('Retry Loading Summary'),
              ),
              data: _buildSummary,
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
                  setState(() => _selectedMood = value);
                }
              },
            ),
            const SizedBox(height: 16),
            presetsState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => TextButton(
                onPressed: () =>
                    ref.invalidate(focusPresetsProvider),
                child: const Text('Retry Loading Presets'),
              ),
              data: _buildPresetList,
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
            _buildSessionScout(reduceMotion),
          ],
        ),
      ),
    );
  }
}
