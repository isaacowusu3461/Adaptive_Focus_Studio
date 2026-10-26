
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _durationKey = 'default_focus_duration';
  static const _remindersKey = 'reminders_enabled';
  static const _reduceMotionKey = 'reduce_motion';
  static const _soundKey = 'sound_enabled';

  double _defaultDuration = 25;
  bool _remindersEnabled = false;
  bool _reduceMotion = false;
  bool _soundEnabled = true;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        _defaultDuration =
            (preferences.getInt(_durationKey) ?? 25)
                .clamp(10, 60)
                .toDouble();
        _remindersEnabled =
            preferences.getBool(_remindersKey) ?? false;
        _reduceMotion =
            preferences.getBool(_reduceMotionKey) ?? false;
        _soundEnabled =
            preferences.getBool(_soundKey) ?? true;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        _showMessage('Unable to load saved settings.');
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);

    try {
      final preferences =
          await SharedPreferences.getInstance();

      final results = await Future.wait([
        preferences.setInt(
          _durationKey,
          _defaultDuration.round(),
        ),
        preferences.setBool(
          _remindersKey,
          _remindersEnabled,
        ),
        preferences.setBool(
          _reduceMotionKey,
          _reduceMotion,
        ),
        preferences.setBool(
          _soundKey,
          _soundEnabled,
        ),
      ]);

      if (results.any((success) => !success)) {
        throw StateError('Unable to persist settings.');
      }

      if (mounted) {
        _showMessage('Settings saved successfully.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to save settings.');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Focus Preferences',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Default Focus Duration: '
                  '${_defaultDuration.round()} minutes',
                ),
                Slider(
                  value: _defaultDuration,
                  min: 10,
                  max: 60,
                  divisions: 10,
                  label: '${_defaultDuration.round()} min',
                  onChanged: _saving
                      ? null
                      : (value) {
                          setState(() {
                            _defaultDuration = value;
                          });
                        },
                ),
                SwitchListTile(
                  title: const Text('Enable Reminders'),
                  subtitle: const Text(
                    'Save your reminder preference',
                  ),
                  value: _remindersEnabled,
                  onChanged: _saving
                      ? null
                      : (value) {
                          setState(() {
                            _remindersEnabled = value;
                          });
                        },
                ),
                SwitchListTile(
                  title: const Text('Reduce Motion'),
                  value: _reduceMotion,
                  onChanged: _saving
                      ? null
                      : (value) {
                          setState(() {
                            _reduceMotion = value;
                          });
                        },
                ),
                SwitchListTile(
                  title: const Text('Enable Sound'),
                  value: _soundEnabled,
                  onChanged: _saving
                      ? null
                      : (value) {
                          setState(() {
                            _soundEnabled = value;
                          });
                        },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _saveSettings,
                  child: Text(
                    _saving ? 'Saving...' : 'Save Settings',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Reminder notifications, animations, and '
                  'sound effects will be connected in later '
                  'commits. These preferences are saved now.',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
    );
  }
}
