
import 'package:flutter/material.dart';

class PresetFormScreen extends StatefulWidget {
  const PresetFormScreen({super.key});

  @override
  State<PresetFormScreen> createState() => _PresetFormScreenState();
}

class _PresetFormScreenState extends State<PresetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController(
    text: '25',
  );

  String _selectedMood = 'Focused';

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _savePreset() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preset saving will be available soon!',
          ),
        ),
      );
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
              onChanged: (value) {
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
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final duration = int.tryParse(value ?? '');

                if (duration == null || duration <= 0) {
                  return 'Enter a valid duration';
                }

                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _savePreset,
              child: const Text('Save Preset'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
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
