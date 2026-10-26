
import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/features/focus/domain/entities/focus_preset.dart';
import 'package:adaptive_focus_studio/features/focus/domain/repositories/focus_preset_repository.dart';
import 'package:adaptive_focus_studio/features/focus/domain/usecases/delete_focus_preset.dart';

class FakeFocusPresetRepository implements FocusPresetRepository {
  int? deletedId;
  int deleteResult = 1;

  @override
  Future<int> deletePreset(int id) async {
    deletedId = id;
    return deleteResult;
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
  Future<int> updatePreset(FocusPreset preset) async {
    return 0;
  }
}

void main() {
  late FakeFocusPresetRepository repository;
  late DeleteFocusPreset deleteFocusPreset;

  setUp(() {
    repository = FakeFocusPresetRepository();
    deleteFocusPreset = DeleteFocusPreset(repository);
  });

  test('deletes a preset using its ID', () async {
    final result = await deleteFocusPreset(5);

    expect(result, 1);
    expect(repository.deletedId, 5);
  });

  test('returns zero when a preset does not exist', () async {
    repository.deleteResult = 0;

    final result = await deleteFocusPreset(999);

    expect(result, 0);
    expect(repository.deletedId, 999);
  });

  test('rejects a zero preset ID', () async {
    await expectLater(
      deleteFocusPreset(0),
      throwsArgumentError,
    );

    expect(repository.deletedId, isNull);
  });

  test('rejects a negative preset ID', () async {
    await expectLater(
      deleteFocusPreset(-10),
      throwsArgumentError,
    );

    expect(repository.deletedId, isNull);
  });

  test('accepts the minimum valid preset ID', () async {
    final result = await deleteFocusPreset(1);

    expect(result, 1);
    expect(repository.deletedId, 1);
  });
}
