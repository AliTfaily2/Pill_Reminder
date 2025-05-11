import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pill_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        uid INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        notif INTEGER DEFAULT 1,
        notifNum INTEGER DEFAULT 3
      );
    ''');

    await db.execute('''
      CREATE TABLE pills (
        pid INTEGER PRIMARY KEY AUTOINCREMENT,
        uid INTEGER NOT NULL,
        pname TEXT NOT NULL,
        totalp INTEGER,
        dosage INTEGER,
        pillsTook INTEGER,
        hour1 TEXT,
        minute1 TEXT,
        hour2 TEXT DEFAULT NULL,
        minute2 TEXT DEFAULT NULL,
        FOREIGN KEY(uid) REFERENCES users(uid)
      );
    ''');

    await db.execute('''
      CREATE TABLE alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(uid) REFERENCES users(uid)
      );
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
