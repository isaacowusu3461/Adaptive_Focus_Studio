
import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import '../datasources/database_helper.dart';
import 'focus_backup_codec.dart';

class FocusBackupResult {
  final int presetCount;
  final int sessionCount;

  const FocusBackupResult({
    required this.presetCount,
    required this.sessionCount,
  });
}

class FocusBackupService {
  final DatabaseHelper databaseHelper;
  final FocusBackupCodec codec;

  FocusBackupService({
    required this.databaseHelper,
    FocusBackupCodec? codec,
  }) : codec = codec ?? FocusBackupCodec();

  Future<String> exportJson() async {
    final db = await databaseHelper.database;

    // Read both tables from one consistent database snapshot.
    return db.transaction((txn) async {
      final presets = await txn.query(
        DatabaseHelper.presetsTable,
        orderBy: 'id ASC',
      );

      final sessions = await txn.query(
        DatabaseHelper.sessionsTable,
        orderBy: 'id ASC',
      );

      return codec.encode(
        presets: presets,
        sessions: sessions,
        exportedAt: DateTime.now(),
      );
    });
  }

  Future<void> exportToFile() async {
    final json = await exportJson();
    final directory = await getTemporaryDirectory();

    final timestamp = DateTime.now()
        .toUtc()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');

    final file = File(
      path.join(
        directory.path,
        'adaptive_focus_backup_$timestamp.json',
      ),
    );

    await file.writeAsString(
      json,
      encoding: utf8,
      flush: true,
    );

    await SharePlus.instance.share(
      ShareParams(
        text: 'Adaptive Focus Studio backup',
        files: [
          XFile(
            file.path,
            mimeType: 'application/json',
          ),
        ],
        fileNameOverrides: [
          path.basename(file.path),
        ],
      ),
    );
  }

  Future<FocusBackupResult?> pickAndImport() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.isEmpty) {
      return null;
    }

    final selected = result.single;

    if (selected.path == null) {
      throw const FormatException(
        'Unable to access the selected backup file.',
      );
    }

    final json = await File(
      selected.path!,
    ).readAsString(
      encoding: utf8,
    );

    return importJson(json);
  }

  Future<FocusBackupResult> importJson(String source) async {
    // Validate the entire file before touching the database.
    final backup = codec.decode(source);
    final db = await databaseHelper.database;

    await db.transaction((txn) async {
      // Delete child records first to respect foreign keys.
      await txn.delete(DatabaseHelper.sessionsTable);
      await txn.delete(DatabaseHelper.presetsTable);

      // Preserve original IDs so session relationships remain valid.
      for (final preset in backup.presets) {
        await txn.insert(
          DatabaseHelper.presetsTable,
          preset,
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }

      for (final session in backup.sessions) {
        await txn.insert(
          DatabaseHelper.sessionsTable,
          session,
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
    });

    return FocusBackupResult(
      presetCount: backup.presets.length,
      sessionCount: backup.sessions.length,
    );
  }
}
