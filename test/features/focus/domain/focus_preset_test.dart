
import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/features/focus/domain/entities/focus_preset.dart';

void main() {
  group('FocusPreset', () {
    test('creates a preset with expected values', () {
      const preset = FocusPreset(
        id: 1,
        name: 'Algorithms Practice',
        moodTag: 'Focused',
        durationMinutes: 25,
      );

      expect(preset.id, 1);
      expect(preset.name, 'Algorithms Practice');
      expect(preset.moodTag, 'Focused');
      expect(preset.durationMinutes, 25);
    });

    test('copyWith updates selected fields', () {
      const preset = FocusPreset(
        id: 1,
        name: 'Algorithms Practice',
        moodTag: 'Focused',
        durationMinutes: 25,
      );

      final updatedPreset = preset.copyWith(
        durationMinutes: 40,
      );

      expect(updatedPreset.id, 1);
      expect(updatedPreset.name, 'Algorithms Practice');
      expect(updatedPreset.moodTag, 'Focused');
      expect(updatedPreset.durationMinutes, 40);

      expect(preset.durationMinutes, 25);
    });
  });
}
