
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _defaultDuration = 25;
  bool _remindersEnabled = false;
  bool _reduceMotion = false;
  bool _soundEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Default Focus Duration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text('${_defaultDuration.round()} minutes'),
          Slider(
            value: _defaultDuration,
            min: 10,
            max: 60,
            divisions: 10,
            label: '${_defaultDuration.round()} minutes',
            onChanged: (value) {
              setState(() {
                _defaultDuration = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Enable Local Reminders'),
            value: _remindersEnabled,
            onChanged: (value) {
              setState(() {
                _remindersEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Reduce Motion'),
            value: _reduceMotion,
            onChanged: (value) {
              setState(() {
                _reduceMotion = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Enable Sound'),
            value: _soundEnabled,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Data & File Operations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'JSON export feature coming soon!',
                  ),
                ),
              );
            },
            child: const Text('Save Local Session Summary'),
          ),
        ],
      ),
    );
  }
}
