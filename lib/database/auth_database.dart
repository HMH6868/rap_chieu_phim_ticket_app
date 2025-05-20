import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class AuthDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'auth.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  static Future<int> register(User user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<User?> login(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) return User.fromMap(result.first);
    return null;
  }

  static Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) return User.fromMap(result.first);
    return null;
  }

  static Future<int> updatePassword(String email, String newPassword) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }
}
