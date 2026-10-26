
import 'package:flutter/material.dart';

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
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

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

      Navigator.pop(context, true);
    } catch (error) {
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              enabled: !_isSaving,
              maxLength: 50,
              decoration: const InputDecoration(
                labelText: 'Preset Name',
                hintText: 'e.g. Algorithms Practice',
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
                border: OutlineInputBorder(),
              ),
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _savePreset,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _isEditing
                          ? 'Update Preset'
                          : 'Save Preset',
                    ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _isSaving
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
