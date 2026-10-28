
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/notifications/focus_notification_service.dart';
import '../providers/focus_backup_provider.dart';
import '../providers/focus_providers.dart';
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
  bool _backupBusy = false;

  final FocusNotificationService _notificationService =
      LocalFocusNotificationService();

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
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load settings.'),
        ),
      );
    }
  }

  Future<void> _saveSettings() async {
    if (_saving || _backupBusy) return;

    setState(() => _saving = true);

    try {
      bool remindersToSave = _remindersEnabled;

      if (remindersToSave) {
        final permissionGranted =
            await _notificationService.requestPermission();

        if (!permissionGranted) {
          remindersToSave = false;

          if (mounted) {
            setState(() => _remindersEnabled = false);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Notification permission was not granted. '
                  'Reminders remain disabled.',
                ),
              ),
            );
          }
        }
      }

      final preferences = await SharedPreferences.getInstance();

      await preferences.setInt(
        'default_focus_duration',
        _defaultDuration.round(),
      );

      await preferences.setBool(
        'reminders_enabled',
        remindersToSave,
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
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save settings.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _exportBackup() async {
    if (_backupBusy || _saving) return;

    setState(() => _backupBusy = true);

    try {
      await ref.read(focusBackupServiceProvider).exportToFile();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Backup prepared. Save a copy using the share sheet.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to export backup.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _backupBusy = false);
      }
    }
  }

  Future<void> _importBackup() async {
    if (_backupBusy || _saving) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: const Text(
          'Importing a backup will replace all current '
          'focus presets and session history. '
          'This cannot be undone unless you have another backup. '
          'Export your current data first if you want to keep it.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    setState(() => _backupBusy = true);

    try {
      final result = await ref
          .read(focusBackupServiceProvider)
          .pickAndImport();

      if (!mounted) return;

      if (result == null) {
        return;
      }

      ref.invalidate(focusPresetsProvider);
      ref.invalidate(sessionHistoryProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Backup restored: ${result.presetCount} presets '
            'and ${result.sessionCount} sessions.',
          ),
        ),
      );
    } on FormatException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid backup: ${error.message}'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to restore backup. Existing data was not changed.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _backupBusy = false);
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

    final busy = _saving || _backupBusy;

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
              onChanged: busy
                  ? null
                  : (value) {
                      setState(() => _defaultDuration = value);
                    },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Reminders'),
              subtitle: const Text(
                'Notify me when a focus session finishes.',
              ),
              value: _remindersEnabled,
              onChanged: busy
                  ? null
                  : (value) {
                      setState(() => _remindersEnabled = value);
                    },
            ),
            SwitchListTile(
              title: const Text('Reduce Motion'),
              subtitle: const Text(
                'Disable decorative animations.',
              ),
              value: _reduceMotion,
              onChanged: busy
                  ? null
                  : (value) {
                      setState(() => _reduceMotion = value);
                    },
            ),
            SwitchListTile(
              title: const Text('Sound'),
              subtitle: const Text(
                'Save your sound preference.',
              ),
              value: _soundEnabled,
              onChanged: busy
                  ? null
                  : (value) {
                      setState(() => _soundEnabled = value);
                    },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: busy ? null : _saveSettings,
              child: Text(
                _saving ? 'Saving...' : 'Save Settings',
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Data Backup',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Export your focus presets and study history '
              'to a JSON file, or restore a previous backup.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Restoring a backup replaces your current '
              'presets and session history. Settings are not included.',
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: busy ? null : _exportBackup,
              icon: const Icon(Icons.file_upload_outlined),
              label: const Text('Export JSON Backup'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: busy ? null : _importBackup,
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('Import JSON Backup'),
            ),
            if (_backupBusy) ...[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
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
