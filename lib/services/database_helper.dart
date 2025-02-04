import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notifications.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE notifications(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            body TEXT,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertNotification(Map<String, dynamic> notification) async {
    Database db = await database;
    return await db.insert('notifications', notification);
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    Database db = await database;
    return await db.query('notifications', orderBy: 'timestamp DESC');
  }

  Future<int> deleteNotification(int id) async {
    Database db = await database;
    return await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }
  Future<void> deleteAllNotifications() async {
    final db = await database;
    await db.delete('notifications');
  }
}
