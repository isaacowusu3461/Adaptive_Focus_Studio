
import 'package:flutter/material.dart';

import '../../domain/usecases/create_focus_preset.dart';

class PresetFormScreen extends StatefulWidget {
  final CreateFocusPreset createFocusPreset;

  const PresetFormScreen({
    super.key,
    required this.createFocusPreset,
  });

  @override
  State<PresetFormScreen> createState() =>
      _PresetFormScreenState();
}

class _PresetFormScreenState extends State<PresetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController(
    text: '25',
  );

  String _selectedMood = 'Focused';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _savePreset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.createFocusPreset(
        name: _nameController.text,
        moodTag: _selectedMood,
        durationMinutes: int.parse(
          _durationController.text.trim(),
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save preset. Please try again.',
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
        title: const Text('Create Preset'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Preset Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a preset name';
                }

                return null;
              },
            ),
            const SizedBox(height: 20),
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
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final duration = int.tryParse(
                  value?.trim() ?? '',
                );

                if (duration == null || duration <= 0) {
                  return 'Enter a valid duration';
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
                  : const Text('Save Preset'),
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
