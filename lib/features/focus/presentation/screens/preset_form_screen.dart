
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/focus_preset.dart';
import '../../domain/usecases/create_focus_preset.dart';
import '../../domain/usecases/update_focus_preset.dart';

class PresetFormScreen extends StatefulWidget {
  final CreateFocusPreset createFocusPreset;
  final UpdateFocusPreset updateFocusPreset;
  final FocusPreset? preset;

  const PresetFormScreen({
    super.key,
    required this.createFocusPreset,
    required this.updateFocusPreset,
    this.preset,
  });

  @override
  State<PresetFormScreen> createState() =>
      _PresetFormScreenState();
}

class _PresetFormScreenState extends State<PresetFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _durationController;

  late String _selectedMood;
  bool _isSaving = false;

  bool get _isEditing => widget.preset != null;

  @override
  void initState() {
    super.initState();

    // I fill in the existing values when editing a preset.
    // For a new preset, I start with a 25-minute session.
    _nameController = TextEditingController(
      text: widget.preset?.name ?? '',
    );

    _durationController = TextEditingController(
      text: widget.preset?.durationMinutes.toString() ?? '25',
    );

    _selectedMood = widget.preset?.moodTag ?? 'Focused';
  }

  @override
  void dispose() {
    // I dispose of the controllers when leaving this screen
    // because they are no longer needed.
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  // I validate the form before saving so empty names and
  // invalid durations do not get stored in the database.
  Future<void> _savePreset() async {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final name = _nameController.text.trim();
      final duration = int.parse(
        _durationController.text.trim(),
      );

      // I reuse this form for creating and editing presets.
      // The action depends on whether a preset was passed in.
      if (_isEditing) {
        final updatedRows = await widget.updateFocusPreset(
          id: widget.preset!.id!,
          name: name,
          moodTag: _selectedMood,
          durationMinutes: duration,
        );

        if (updatedRows == 0) {
          throw StateError('Preset could not be found.');
        }
      } else {
        await widget.createFocusPreset(
          name: name,
          moodTag: _selectedMood,
          durationMinutes: duration,
        );
      }

      if (!mounted) {
        return;
      }

      // Returning true tells the dashboard that a preset
      // was saved and its displayed data should be refreshed.
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Unable to update preset. Please try again.'
                : 'Unable to save preset. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Preset' : 'Create Preset',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.edit_calendar_rounded,
                          size: 52,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isEditing
                              ? 'Update Your Focus Preset'
                              : 'Create a Focus Preset',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Choose a name, mood, and duration '
                          'for your study session.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            enabled: !_isSaving,
                            maxLength: 50,
                            decoration: const InputDecoration(
                              labelText: 'Preset Name',
                              hintText: 'e.g. Algorithms Practice',
                              prefixIcon: Icon(Icons.book_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final name = value?.trim() ?? '';

                              if (name.isEmpty) {
                                return 'Please enter a preset name';
                              }

                              if (name.length > 50) {
                                return 'Name cannot exceed 50 characters';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedMood,
                            decoration: const InputDecoration(
                              labelText: 'Mood Tag',
                              prefixIcon: Icon(
                                Icons.sentiment_satisfied_alt_outlined,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Focused',
                                child: Text('Focused'),
                              ),
                              DropdownMenuItem(
                                value: 'Relaxed',
                                child: Text('Relaxed'),
                              ),
                              DropdownMenuItem(
                                value: 'Motivated',
                                child: Text('Motivated'),
                              ),
                            ],
                            onChanged: _isSaving
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedMood = value;
                                      });
                                    }
                                  },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _durationController,
                            enabled: !_isSaving,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Duration (minutes)',
                              hintText: 'Enter 1 to 180',
                              prefixIcon: Icon(Icons.timer_outlined),
                              border: OutlineInputBorder(),
                            ),

                            // I limit the duration to 1–180 minutes so
                            // users cannot create sessions that are too
                            // short or unusually long.
                            validator: (value) {
                              final duration = int.tryParse(
                                value?.trim() ?? '',
                              );

                              if (duration == null ||
                                  duration < 1 ||
                                  duration > 180) {
                                return 'Enter a duration between 1 and 180';
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _savePreset,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _isSaving
                            ? 'Saving...'
                            : _isEditing
                                ? 'Update Preset'
                                : 'Save Preset',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
