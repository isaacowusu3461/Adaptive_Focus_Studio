
import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/features/focus/domain/entities/focus_preset.dart';
import 'package:adaptive_focus_studio/features/focus/domain/repositories/focus_preset_repository.dart';
import 'package:adaptive_focus_studio/features/focus/domain/usecases/create_focus_preset.dart';

class FakeFocusPresetRepository implements FocusPresetRepository {
  FocusPreset? savedPreset;

  @override
  Future<int> createPreset(FocusPreset preset) async {
    savedPreset = preset;
    return 1;
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
  Future<int> updatePreset(FocusPreset preset) async {
    return 0;
  }

  @override
  Future<int> deletePreset(int id) async {
    return 0;
  }
}

void main() {
  late FakeFocusPresetRepository repository;
  late CreateFocusPreset createFocusPreset;

  setUp(() {
    repository = FakeFocusPresetRepository();
    createFocusPreset = CreateFocusPreset(repository);
  });

  test('creates a preset using the repository', () async {
    final id = await createFocusPreset(
      name: 'Algorithms Practice',
      moodTag: 'Focused',
      durationMinutes: 25,
    );

    expect(id, 1);
    expect(repository.savedPreset, isNotNull);
    expect(repository.savedPreset!.name, 'Algorithms Practice');
    expect(repository.savedPreset!.durationMinutes, 25);
  });

  test('trims whitespace from name and mood', () async {
    await createFocusPreset(
      name: '  Mobile Development  ',
      moodTag: '  Motivated  ',
      durationMinutes: 40,
    );

    expect(repository.savedPreset!.name, 'Mobile Development');
    expect(repository.savedPreset!.moodTag, 'Motivated');
  });

  test('rejects an empty name', () async {
    await expectLater(
      createFocusPreset(
        name: '   ',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
      throwsArgumentError,
    );

    expect(repository.savedPreset, isNull);
  });

  test('rejects an empty mood tag', () async {
    await expectLater(
      createFocusPreset(
        name: 'Algorithms',
        moodTag: '',
        durationMinutes: 25,
      ),
      throwsArgumentError,
    );

    expect(repository.savedPreset, isNull);
  });

  test('rejects a duration of zero', () async {
    await expectLater(
      createFocusPreset(
        name: 'Algorithms',
        moodTag: 'Focused',
        durationMinutes: 0,
      ),
      throwsArgumentError,
    );

    expect(repository.savedPreset, isNull);
  });
}
