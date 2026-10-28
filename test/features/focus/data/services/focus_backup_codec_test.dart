
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_focus_studio/features/focus/data/services/focus_backup_codec.dart';

void main() {
  late FocusBackupCodec codec;

  setUp(() {
    codec = FocusBackupCodec();
  });

  final presets = <Map<String, Object?>>[
    {
      'id': 1,
      'name': 'Morning Study',
      'mood_tag': 'Focused',
      'duration_minutes': 25,
    },
  ];

  final sessions = <Map<String, Object?>>[
    {
      'id': 2,
      'preset_id': 1,
      'date': '2026-10-28T10:00:00.000Z',
      'completed_seconds': 1500,
      'status': 'completed',
      'notes': 'Good session',
    },
  ];

  String makeBackup({
    List<Map<String, Object?>>? focusPresets,
    List<Map<String, Object?>>? sessionLogs,
  }) {
    return codec.encode(
      presets: focusPresets ?? presets,
      sessions: sessionLogs ?? sessions,
      exportedAt: DateTime.utc(2026, 10, 28),
    );
  }

  test('encodes a valid backup', () {
    final result = jsonDecode(makeBackup()) as Map<String, dynamic>;

    expect(result['formatVersion'], 1);
    expect(result['app'], 'Adaptive Focus Studio');
    expect((result['focusPresets'] as List).length, 1);
    expect((result['sessionLogs'] as List).length, 1);
  });

  test('decodes a valid backup', () {
    final result = codec.decode(makeBackup());

    expect(result.presets.length, 1);
    expect(result.sessions.length, 1);
    expect(result.presets.first['name'], 'Morning Study');
    expect(result.sessions.first['preset_id'], 1);
  });

  test('supports empty backups', () {
    final result = codec.decode(
      makeBackup(focusPresets: [], sessionLogs: []),
    );

    expect(result.presets, isEmpty);
    expect(result.sessions, isEmpty);
  });

  test('rejects invalid JSON', () {
    expect(
      () => codec.decode('{invalid'),
      throwsFormatException,
    );
  });

  test('rejects unsupported version', () {
    final data = jsonDecode(makeBackup()) as Map<String, dynamic>;
    data['formatVersion'] = 2;

    expect(
      () => codec.decode(jsonEncode(data)),
      throwsFormatException,
    );
  });

  test('rejects incorrect app name', () {
    final data = jsonDecode(makeBackup()) as Map<String, dynamic>;
    data['app'] = 'Other App';

    expect(
      () => codec.decode(jsonEncode(data)),
      throwsFormatException,
    );
  });

  test('rejects duplicate preset IDs', () {
    final duplicated = [
      presets.first,
      Map<String, Object?>.from(presets.first),
    ];

    expect(
      () => codec.decode(
        makeBackup(focusPresets: duplicated),
      ),
      throwsFormatException,
    );
  });

  test('rejects duplicate session IDs', () {
    final duplicated = [
      sessions.first,
      Map<String, Object?>.from(sessions.first),
    ];

    expect(
      () => codec.decode(
        makeBackup(sessionLogs: duplicated),
      ),
      throwsFormatException,
    );
  });

  test('rejects sessions with missing presets', () {
    expect(
      () => codec.decode(
        makeBackup(focusPresets: []),
      ),
      throwsFormatException,
    );
  });

  test('rejects negative session duration', () {
    final invalid = Map<String, Object?>.from(sessions.first);
    invalid['completed_seconds'] = -1;

    expect(
      () => codec.decode(
        makeBackup(sessionLogs: [invalid]),
      ),
      throwsFormatException,
    );
  });

  test('rejects invalid session status', () {
    final invalid = Map<String, Object?>.from(sessions.first);
    invalid['status'] = 'unknown';

    expect(
      () => codec.decode(
        makeBackup(sessionLogs: [invalid]),
      ),
      throwsFormatException,
    );
  });

  test('rejects empty preset names', () {
    final invalid = Map<String, Object?>.from(presets.first);
    invalid['name'] = '  ';

    expect(
      () => codec.decode(
        makeBackup(focusPresets: [invalid]),
      ),
      throwsFormatException,
    );
  });

  test('rejects unsupported moods', () {
    final invalid = Map<String, Object?>.from(presets.first);
    invalid['mood_tag'] = 'Unknown';

    expect(
      () => codec.decode(
        makeBackup(focusPresets: [invalid]),
      ),
      throwsFormatException,
    );
  });
}
