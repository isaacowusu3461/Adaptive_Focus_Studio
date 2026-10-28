
import 'dart:convert';

class FocusBackupData {
  final List<Map<String, Object?>> presets;
  final List<Map<String, Object?>> sessions;

  const FocusBackupData({
    required this.presets,
    required this.sessions,
  });
}

class FocusBackupCodec {
  static const int formatVersion = 1;
  static const String appName = 'Adaptive Focus Studio';

  String encode({
    required List<Map<String, Object?>> presets,
    required List<Map<String, Object?>> sessions,
    required DateTime exportedAt,
  }) {
    final backup = {
      'formatVersion': formatVersion,
      'app': appName,
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'focusPresets': presets.map((preset) {
        return {
          'id': preset['id'],
          'name': preset['name'],
          'moodTag': preset['mood_tag'],
          'durationMinutes': preset['duration_minutes'],
        };
      }).toList(),
      'sessionLogs': sessions.map((session) {
        return {
          'id': session['id'],
          'presetId': session['preset_id'],
          'date': session['date'],
          'completedSeconds': session['completed_seconds'],
          'status': session['status'],
          'notes': session['notes'],
        };
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  FocusBackupData decode(String source) {
    final Object? decoded;

    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const FormatException('Invalid JSON file.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'The backup must contain a JSON object.',
      );
    }

    if (decoded['formatVersion'] != formatVersion) {
      throw const FormatException(
        'Unsupported backup format version.',
      );
    }

    if (decoded['app'] != appName) {
      throw const FormatException(
        'This file is not an Adaptive Focus Studio backup.',
      );
    }

    final exportedAt = decoded['exportedAt'];

    if (exportedAt is! String ||
        DateTime.tryParse(exportedAt) == null) {
      throw const FormatException(
        'Invalid backup export date.',
      );
    }

    final rawPresets = decoded['focusPresets'];
    final rawSessions = decoded['sessionLogs'];

    if (rawPresets is! List || rawSessions is! List) {
      throw const FormatException(
        'Backup must contain focusPresets and sessionLogs lists.',
      );
    }

    final presets = <Map<String, Object?>>[];
    final sessions = <Map<String, Object?>>[];
    final presetIds = <int>{};
    final sessionIds = <int>{};

    for (final item in rawPresets) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid preset entry.');
      }

      final id = item['id'];
      final name = item['name'];
      final mood = item['moodTag'];
      final duration = item['durationMinutes'];

      if (id is! int ||
          id <= 0 ||
          name is! String ||
          name.trim().isEmpty ||
          mood is! String ||
          !['Focused', 'Relaxed', 'Motivated'].contains(mood) ||
          duration is! int ||
          duration <= 0) {
        throw const FormatException(
          'A focus preset contains invalid data.',
        );
      }

      if (!presetIds.add(id)) {
        throw const FormatException(
          'Duplicate preset IDs in backup.',
        );
      }

      presets.add({
        'id': id,
        'name': name,
        'mood_tag': mood,
        'duration_minutes': duration,
      });
    }

    for (final item in rawSessions) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid session entry.');
      }

      final id = item['id'];
      final presetId = item['presetId'];
      final date = item['date'];
      final seconds = item['completedSeconds'];
      final status = item['status'];
      final notes = item['notes'];

      if (id is! int ||
          id <= 0 ||
          presetId is! int ||
          presetId <= 0 ||
          date is! String ||
          DateTime.tryParse(date) == null ||
          seconds is! int ||
          seconds < 0 ||
          (status != 'completed' && status != 'partial') ||
          notes is! String) {
        throw const FormatException(
          'A session log contains invalid data.',
        );
      }

      if (!sessionIds.add(id)) {
        throw const FormatException(
          'Duplicate session IDs in backup.',
        );
      }

      if (!presetIds.contains(presetId)) {
        throw const FormatException(
          'A session references a missing focus preset.',
        );
      }

      sessions.add({
        'id': id,
        'preset_id': presetId,
        'date': date,
        'completed_seconds': seconds,
        'status': status,
        'notes': notes,
      });
    }

    return FocusBackupData(
      presets: presets,
      sessions: sessions,
    );
  }
}
