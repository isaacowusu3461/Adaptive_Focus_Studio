
import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/features/focus/data/models/focus_preset_model.dart';
import 'package:adaptive_focus_studio/features/focus/data/models/session_log_model.dart';

void main() {
  group('FocusPresetModel', () {
    test('converts a preset to a database map', () {
      const preset = FocusPresetModel(
        id: 1,
        name: 'Algorithms Practice',
        moodTag: 'Focused',
        durationMinutes: 25,
      );

      final map = preset.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Algorithms Practice');
      expect(map['mood_tag'], 'Focused');
      expect(map['duration_minutes'], 25);
    });

    test('creates a preset from a database map', () {
      final map = <String, Object?>{
        'id': 2,
        'name': 'Mobile Development',
        'mood_tag': 'Motivated',
        'duration_minutes': 40,
      };

      final preset = FocusPresetModel.fromMap(map);

      expect(preset.id, 2);
      expect(preset.name, 'Mobile Development');
      expect(preset.moodTag, 'Motivated');
      expect(preset.durationMinutes, 40);
    });
  });

  group('SessionLogModel', () {
    test('converts a session log to a database map', () {
      final session = SessionLogModel(
        id: 1,
        presetId: 2,
        date: DateTime(2026, 10, 25, 14, 30),
        completedSeconds: 1500,
        status: 'completed',
        notes: 'Finished studying algorithms',
      );

      final map = session.toMap();

      expect(map['id'], 1);
      expect(map['preset_id'], 2);
      expect(map['completed_seconds'], 1500);
      expect(map['status'], 'completed');
      expect(
        map['notes'],
        'Finished studying algorithms',
      );
    });

    test('creates a session log from a database map', () {
      final map = <String, Object?>{
        'id': 3,
        'preset_id': 1,
        'date': '2026-10-25T14:30:00.000',
        'completed_seconds': 750,
        'status': 'completed',
        'notes': 'Good session',
      };

      final session = SessionLogModel.fromMap(map);

      expect(session.id, 3);
      expect(session.presetId, 1);
      expect(session.completedSeconds, 750);
      expect(session.completedMinutes, 12.5);
      expect(session.status, 'completed');
      expect(session.notes, 'Good session');
    });
  });
}
