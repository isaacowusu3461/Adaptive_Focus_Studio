
import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/features/focus/domain/entities/focus_preset.dart';
import 'package:adaptive_focus_studio/features/focus/domain/repositories/focus_preset_repository.dart';
import 'package:adaptive_focus_studio/features/focus/domain/usecases/update_focus_preset.dart';

class FakeFocusPresetRepository implements FocusPresetRepository {
  FocusPreset? updatedPreset;

  @override
  Future<int> updatePreset(FocusPreset preset) async {
    updatedPreset = preset;
    return 1;
  }

  @override
  Future<int> createPreset(FocusPreset preset) async {
    return 0;
  }

  @override
  Future<List<FocusPreset>> getAllPresets() async {
    return [];
  }

  @override
  Future<FocusPreset?> getPresetById(int id) async {
    return null;
  }

  @override
  Future<int> deletePreset(int id) async {
    return 0;
  }
}

void main() {
  late FakeFocusPresetRepository repository;
  late UpdateFocusPreset updateFocusPreset;

  setUp(() {
    repository = FakeFocusPresetRepository();
    updateFocusPreset = UpdateFocusPreset(repository);
  });

  test('updates a preset through the repository', () async {
    final result = await updateFocusPreset(
      id: 1,
      name: 'Advanced Algorithms',
      moodTag: 'Motivated',
      durationMinutes: 45,
    );

    expect(result, 1);
    expect(repository.updatedPreset, isNotNull);
    expect(repository.updatedPreset!.id, 1);
    expect(
      repository.updatedPreset!.name,
      'Advanced Algorithms',
    );
    expect(repository.updatedPreset!.durationMinutes, 45);
  });

  test('trims name and mood before updating', () async {
    await updateFocusPreset(
      id: 2,
      name: '  Flutter Practice  ',
      moodTag: '  Focused  ',
      durationMinutes: 30,
    );

    expect(repository.updatedPreset!.name, 'Flutter Practice');
    expect(repository.updatedPreset!.moodTag, 'Focused');
  });

  test('rejects an invalid preset ID', () async {
    await expectLater(
      updateFocusPreset(
        id: 0,
        name: 'Algorithms',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
      throwsArgumentError,
    );

    expect(repository.updatedPreset, isNull);
  });

  test('rejects an empty preset name', () async {
    await expectLater(
      updateFocusPreset(
        id: 1,
        name: '   ',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
      throwsArgumentError,
    );

    expect(repository.updatedPreset, isNull);
  });

  test('rejects a name longer than 50 characters', () async {
    await expectLater(
      updateFocusPreset(
        id: 1,
        name: 'A' * 51,
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
      throwsArgumentError,
    );

    expect(repository.updatedPreset, isNull);
  });

  test('rejects an empty mood tag', () async {
    await expectLater(
      updateFocusPreset(
        id: 1,
        name: 'Algorithms',
        moodTag: '   ',
        durationMinutes: 25,
      ),
      throwsArgumentError,
    );

    expect(repository.updatedPreset, isNull);
  });

  test('rejects a duration below 1 minute', () async {
    await expectLater(
      updateFocusPreset(
        id: 1,
        name: 'Algorithms',
        moodTag: 'Focused',
        durationMinutes: 0,
      ),
      throwsArgumentError,
    );

    expect(repository.updatedPreset, isNull);
  });

  test('rejects a duration above 180 minutes', () async {
    await expectLater(
      updateFocusPreset(
        id: 1,
        name: 'Algorithms',
        moodTag: 'Focused',
        durationMinutes: 181,
      ),
      throwsArgumentError,
    );

    expect(repository.updatedPreset, isNull);
  });

  test('accepts the minimum duration of 1 minute', () async {
    final result = await updateFocusPreset(
      id: 1,
      name: 'Quick Review',
      moodTag: 'Focused',
      durationMinutes: 1,
    );

    expect(result, 1);
    expect(repository.updatedPreset!.durationMinutes, 1);
  });

  test('accepts the maximum duration of 180 minutes', () async {
    final result = await updateFocusPreset(
      id: 1,
      name: 'Long Study Session',
      moodTag: 'Motivated',
      durationMinutes: 180,
    );

    expect(result, 1);
    expect(repository.updatedPreset!.durationMinutes, 180);
  });
}
