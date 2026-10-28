
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/motion_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
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
      final preferences = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        _defaultDuration =
            (preferences.getInt('default_focus_duration') ?? 25)
                .clamp(10, 60)
                .toDouble();
        _remindersEnabled =
            preferences.getBool('reminders_enabled') ?? false;
        _reduceMotion =
            preferences.getBool('reduce_motion') ?? false;
        _soundEnabled =
            preferences.getBool('sound_enabled') ?? true;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load settings.'),
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      final preferences = await SharedPreferences.getInstance();

      await preferences.setInt(
        'default_focus_duration',
        _defaultDuration.round(),
      );
      await preferences.setBool(
        'reminders_enabled',
        _remindersEnabled,
      );
      await preferences.setBool(
        'sound_enabled',
        _soundEnabled,
      );

      await ref
          .read(reduceMotionProvider.notifier)
          .setReduceMotion(_reduceMotion);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved.'),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to save settings.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ResponsiveSettingsBody(
        child: ListView(
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
              divisions: 50,
              label: '${_defaultDuration.round()} min',
              onChanged: (value) {
                setState(() => _defaultDuration = value);
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Reminders'),
              subtitle: const Text(
                'Save your reminder preference.',
              ),
              value: _remindersEnabled,
              onChanged: (value) {
                setState(() => _remindersEnabled = value);
              },
            ),
            SwitchListTile(
              title: const Text('Reduce Motion'),
              subtitle: const Text(
                'Disable decorative animations.',
              ),
              value: _reduceMotion,
              onChanged: (value) {
                setState(() => _reduceMotion = value);
              },
            ),
            SwitchListTile(
              title: const Text('Sound'),
              subtitle: const Text(
                'Save your sound preference.',
              ),
              value: _soundEnabled,
              onChanged: (value) {
                setState(() => _soundEnabled = value);
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _saveSettings,
              child: Text(
                _saving ? 'Saving...' : 'Save Settings',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResponsiveSettingsBody extends StatelessWidget {
  final Widget child;

  const ResponsiveSettingsBody({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
