
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String databaseName = 'adaptive_focus_studio.db';
  static const int databaseVersion = 1;

  static const String presetsTable = 'focus_presets';
  static const String sessionsTable = 'session_logs';

  final DatabaseFactory _databaseFactory;
  final String? _databasePath;

  Database? _database;

  DatabaseHelper({
    DatabaseFactory? factory,
    String? databasePath,
  })  : _databaseFactory = factory ?? databaseFactory,
        _databasePath = databasePath;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    final path = _databasePath ??
        join(
          await _databaseFactory.getDatabasesPath(),
          databaseName,
        );

    _database = await _databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: databaseVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: _onCreate,
      ),
    );

    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $presetsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        mood_tag TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL
          CHECK (duration_minutes > 0)
      )
    ''');

    await db.execute('''
      CREATE TABLE $sessionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        preset_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        completed_seconds INTEGER NOT NULL
          CHECK (completed_seconds >= 0),
        status TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (preset_id)
          REFERENCES $presetsTable(id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }

    _database = null;
  }
}
