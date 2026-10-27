
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/session_log.dart';
import '../providers/focus_dependencies.dart';
import '../providers/focus_providers.dart';

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
  void reload() {
    ref.invalidate(sessionHistoryProvider);
  }

  Future<void> _showSessionForm({SessionLog? session}) async {
    List<dynamic> presets;

    try {
      presets =
          await ref.read(focusPresetRepositoryProvider).getAllPresets();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to load presets.')),
        );
      }
      return;
    }

    if (!mounted) return;

    if (presets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a focus preset first.')),
      );
      return;
    }

    final presetIds = presets.map((p) => p.id).toSet();

    int selectedId =
        session != null && presetIds.contains(session.presetId)
            ? session.presetId
            : presets.first.id as int;

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
                            ),
                            items: presets.map((preset) {
                              return DropdownMenuItem<int>(
                                value: preset.id as int,
                                child: Text(preset.name as String),
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
                          TextFormField(
                            controller: durationController,
                            enabled: !saving,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Completed Minutes',
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
                          DropdownButtonFormField<String>(
                            initialValue: status,
                            decoration: const InputDecoration(
                              labelText: 'Status',
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
                                      setDialogState(() => status = value);
                                    }
                                  },
                          ),
                          TextFormField(
                            controller: notesController,
                            enabled: !saving,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Notes (optional)',
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
                        : () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            setDialogState(() => saving = true);

                            try {
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
                                setDialogState(() => saving = false);
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
        ref.invalidate(sessionHistoryProvider);
      }
    } finally {
      durationController.dispose();
      notesController.dispose();
    }
  }

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

    if (confirmed != true || !mounted) return;

    try {
      await ref
          .read(sessionLogRepositoryProvider)
          .deleteSession(session.id!);

      if (mounted) {
        ref.invalidate(sessionHistoryProvider);
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

  Widget _buildSessionList(List<SessionLog> sessions) {
    if (sessions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No study sessions recorded yet.'),
        ),
      );
    }

    return Column(
      children: sessions.map((session) {
        final date =
            DateFormat('MMM d, yyyy - h:mm a').format(session.date);

        return Card(
          key: ValueKey('session_${session.id}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Duration: '
                  '${(session.completedSeconds / 60).toStringAsFixed(1)} '
                  'minutes',
                ),
                Text('Status: ${session.status}'),
                Text('Preset ID: ${session.presetId}'),
                if (session.notes.isNotEmpty)
                  Text('Notes: ${session.notes}'),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          _showSessionForm(session: session),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                    TextButton.icon(
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
    final history = ref.watch(sessionHistoryProvider);

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
        data: (sessions) => ListView(
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
            _buildSummary(sessions),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Sessions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh History',
                  onPressed: reload,
                  icon: const Icon(Icons.refresh),
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
    );
  }
}
