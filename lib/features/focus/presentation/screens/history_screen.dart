
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/focus_preset.dart';
import '../../domain/entities/session_log.dart';
import '../../domain/entities/study_statistics.dart';
import '../providers/focus_dependencies.dart';
import '../providers/focus_providers.dart';
import '../providers/study_statistics_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  final FocusDependencies dependencies;

  const HistoryScreen({
    super.key,
    required this.dependencies,
  });

  @override
  ConsumerState<HistoryScreen> createState() =>
      HistoryScreenState();
}

class HistoryScreenState extends ConsumerState<HistoryScreen> {
  // I reload the history after changes so the latest sessions
  // show up without having to restart the app.
  void reload() {
    ref.invalidate(sessionHistoryProvider);
  }

  // I use the same form for adding and editing session logs
  // since both actions need almost the same information.
  Future<void> _showSessionForm({
    SessionLog? session,
  }) async {
    List<FocusPreset> presets;

    try {
      presets = await ref
          .read(focusPresetRepositoryProvider)
          .getAllPresets();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load presets.'),
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    if (presets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create a focus preset first.'),
        ),
      );
      return;
    }

    final presetIds = presets.map((p) => p.id).toSet();

    int selectedId =
        session != null && presetIds.contains(session.presetId)
            ? session.presetId
            : presets.first.id!;

    final durationController = TextEditingController(
      text: session == null
          ? '25'
          : (session.completedSeconds / 60).toStringAsFixed(1),
    );

    final notesController = TextEditingController(
      text: session?.notes ?? '',
    );

    final formKey = GlobalKey<FormState>();
    String status = session?.status ?? 'completed';
    bool saving = false;

    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(
                  session == null
                      ? 'Add Session Log'
                      : 'Edit Session Log',
                ),
                content: SizedBox(
                  width: 350,
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<int>(
                            initialValue: selectedId,
                            decoration: const InputDecoration(
                              labelText: 'Focus Preset',
                              prefixIcon: Icon(Icons.book_outlined),
                            ),
                            items: presets.map((preset) {
                              return DropdownMenuItem<int>(
                                value: preset.id!,
                                child: Text(preset.name),
                              );
                            }).toList(),
                            onChanged: saving
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setDialogState(() {
                                        selectedId = value;
                                      });
                                    }
                                  },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: durationController,
                            enabled: !saving,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Completed Minutes',
                              prefixIcon: Icon(Icons.timer_outlined),
                            ),
                            validator: (value) {
                              final minutes =
                                  double.tryParse(value ?? '');

                              if (minutes == null ||
                                  !minutes.isFinite ||
                                  minutes <= 0 ||
                                  minutes > 180 ||
                                  (minutes * 60).round() == 0) {
                                return 'Enter a duration above 0 and up to 180';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: status,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              prefixIcon: Icon(
                                Icons.check_circle_outline,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'completed',
                                child: Text('Completed'),
                              ),
                              DropdownMenuItem(
                                value: 'partial',
                                child: Text('Partial'),
                              ),
                            ],
                            onChanged: saving
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setDialogState(() {
                                        status = value;
                                      });
                                    }
                                  },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: notesController,
                            enabled: !saving,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Notes (optional)',
                              prefixIcon: Icon(Icons.notes),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.pop(
                              dialogContext,
                              false,
                            ),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            setDialogState(() {
                              saving = true;
                            });

                            try {
                              // The form accepts minutes, but I convert
                              // them to seconds before saving to match
                              // how session durations are stored.
                              final seconds = (double.parse(
                                        durationController.text,
                                      ) *
                                      60)
                                  .round();

                              if (session == null) {
                                await ref.read(saveSessionLogProvider)(
                                  presetId: selectedId,
                                  date: DateTime.now(),
                                  completedSeconds: seconds,
                                  status: status,
                                  notes: notesController.text,
                                );
                              } else {
                                await ref
                                    .read(sessionLogRepositoryProvider)
                                    .updateSession(
                                  SessionLog(
                                    id: session.id,
                                    presetId: selectedId,
                                    date: session.date,
                                    completedSeconds: seconds,
                                    status: status,
                                    notes: notesController.text.trim(),
                                  ),
                                );
                              }

                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext, true);
                              }
                            } catch (_) {
                              if (dialogContext.mounted) {
                                ScaffoldMessenger.of(dialogContext)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Unable to save session.',
                                    ),
                                  ),
                                );

                                setDialogState(() {
                                  saving = false;
                                });
                              }
                            }
                          },
                    child: Text(
                      session == null ? 'Add' : 'Save Changes',
                    ),
                  ),
                ],
              );
            },
          );
        },
      );

      if (saved == true && mounted) {
        reload();
      }
    } finally {
      durationController.dispose();
      notesController.dispose();
    }
  }

  // I ask for confirmation before deleting a session because
  // removing it will also affect the study statistics.
  Future<void> _deleteSession(SessionLog session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Session?'),
        content: const Text(
          'This session log will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              false,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () => Navigator.pop(
              dialogContext,
              true,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref
          .read(sessionLogRepositoryProvider)
          .deleteSession(session.id!);

      if (mounted) {
        reload();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to delete session.'),
          ),
        );
      }
    }
  }

  Widget _summaryTile(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // I keep the statistics in small cards so users can quickly
  // see their study progress without opening each session.
  Widget _buildSummary(StudyStatistics statistics) {
    final tiles = [
      _summaryTile(
        'Completed Sessions',
        '${statistics.completedSessions}',
        Icons.check_circle_outline,
        AppTheme.secondaryColor,
      ),
      _summaryTile(
        'Partial Sessions',
        '${statistics.partialSessions}',
        Icons.timelapse,
        const Color(0xFFD97706),
      ),
      _summaryTile(
        'Total Study Time',
        '${statistics.totalMinutes.toStringAsFixed(1)} min',
        Icons.schedule,
        AppTheme.primaryColor,
      ),
      _summaryTile(
        'Average Duration',
        '${statistics.averageMinutes.toStringAsFixed(1)} min',
        Icons.bar_chart,
        const Color(0xFF7C3AED),
      ),
      _summaryTile(
        'Longest Session',
        '${statistics.longestSessionMinutes.toStringAsFixed(1)} min',
        Icons.emoji_events_outlined,
        const Color(0xFFD97706),
      ),
      _summaryTile(
        'Completion Rate',
        '${statistics.completionRate.toStringAsFixed(1)}%',
        Icons.trending_up,
        AppTheme.secondaryColor,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 650 ? 2 : 1;
        final width = columns == 2
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: tiles.map((tile) {
            return SizedBox(width: width, child: tile);
          }).toList(),
        );
      },
    );
  }

  // I show an empty state when there are no logs yet,
  // otherwise I display the sessions with their details.
  Widget _buildSessionList(List<SessionLog> sessions) {
    if (sessions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Image.asset(
                'assets/images/empty_history.png',
                height: 130,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.history_edu_outlined,
                    size: 65,
                    color: AppTheme.secondaryColor,
                  );
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'No study sessions recorded yet.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your completed sessions will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: sessions.map((session) {
        final date = DateFormat(
          'MMM d, yyyy - h:mm a',
        ).format(session.date);

        final completed = session.status == 'completed';
        final statusColor = completed
            ? AppTheme.secondaryColor
            : const Color(0xFFD97706);

        return Card(
          key: ValueKey('session_${session.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.event_note,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        date,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Chip(
                  avatar: Icon(
                    completed
                        ? Icons.check_circle_outline
                        : Icons.timelapse,
                    size: 18,
                    color: statusColor,
                  ),
                  label: Text(
                    completed ? 'Completed' : 'Partial',
                    style: TextStyle(color: statusColor),
                  ),
                  backgroundColor:
                      statusColor.withValues(alpha: 0.10),
                  side: BorderSide.none,
                ),
                const SizedBox(height: 8),
                Text(
                  'Duration: '
                  '${(session.completedSeconds / 60).toStringAsFixed(1)} '
                  'minutes',
                ),
                const SizedBox(height: 4),
                Text('Preset ID: ${session.presetId}'),
                if (session.notes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('Notes: ${session.notes}'),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.secondaryColor,
                        side: const BorderSide(
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      onPressed: () => _showSessionForm(
                        session: session,
                      ),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      onPressed: () => _deleteSession(session),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
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
    // I watch the providers so the screen updates when the
    // saved sessions or calculated statistics change.
    final history = ref.watch(sessionHistoryProvider);
    final statistics = ref.watch(studyStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History & Insights'),
      ),
      body: history.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: ElevatedButton(
            onPressed: reload,
            child: const Text('Retry Loading History'),
          ),
        ),
        data: (sessions) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
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
                statistics.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => TextButton(
                    onPressed: () {
                      ref.invalidate(studyStatisticsProvider);
                    },
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
                        'Recent Sessions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh History',
                      onPressed: reload,
                      icon: const Icon(
                        Icons.refresh,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSessionList(sessions),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showSessionForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Manual Log'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
