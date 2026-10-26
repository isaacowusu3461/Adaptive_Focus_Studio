
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/focus_preset.dart';
import '../../domain/repositories/focus_preset_repository.dart';
import '../datasources/database_helper.dart';
import '../models/focus_preset_model.dart';

class FocusPresetRepositoryImpl implements FocusPresetRepository {
  final DatabaseHelper databaseHelper;

  FocusPresetRepositoryImpl({
    required this.databaseHelper,
  });

  @override
  Future<List<FocusPreset>> getAllPresets() async {
    final db = await databaseHelper.database;

    final results = await db.query(
      DatabaseHelper.presetsTable,
      orderBy: 'id DESC',
    );

    return results
        .map((row) => FocusPresetModel.fromMap(row))
        .toList();
  }

  @override
  Future<FocusPreset?> getPresetById(int id) async {
    final db = await databaseHelper.database;

    final results = await db.query(
      DatabaseHelper.presetsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return FocusPresetModel.fromMap(results.first);
  }

  @override
  Future<int> createPreset(FocusPreset preset) async {
    _validatePreset(preset);

    final db = await databaseHelper.database;
    final model = FocusPresetModel.fromEntity(preset);

    final data = model.toMap();
    data.remove('id');

    return db.insert(
      DatabaseHelper.presetsTable,
      data,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<int> updatePreset(FocusPreset preset) async {
    if (preset.id == null) {
      throw ArgumentError(
        'A preset ID is required for updating.',
      );
    }

    _validatePreset(preset);

    final db = await databaseHelper.database;
    final model = FocusPresetModel.fromEntity(preset);

    final data = model.toMap();
    data.remove('id');

    return db.update(
      DatabaseHelper.presetsTable,
      data,
      where: 'id = ?',
      whereArgs: [preset.id],
    );
  }

  @override
  Future<int> deletePreset(int id) async {
    if (id <= 0) {
      throw ArgumentError(
        'A valid preset ID is required for deletion.',
      );
    }

    final db = await databaseHelper.database;

    return db.delete(
      DatabaseHelper.presetsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  void _validatePreset(FocusPreset preset) {
    if (preset.name.trim().isEmpty) {
      throw ArgumentError(
        'Preset name cannot be empty.',
      );
    }

    if (preset.moodTag.trim().isEmpty) {
      throw ArgumentError(
        'Mood tag cannot be empty.',
      );
    }

    if (preset.durationMinutes <= 0) {
      throw ArgumentError(
        'Duration must be greater than zero.',
      );
    }
  }
}
