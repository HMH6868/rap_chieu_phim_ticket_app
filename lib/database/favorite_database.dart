import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movie.dart';

class FavoriteDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'favorites.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE favorites(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userEmail TEXT,
            movieId TEXT,
            title TEXT,
            posterUrl TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  static Future<void> addFavorite({
    required String userEmail,
    required String movieId,
    required String title,
    required String posterUrl,
  }) async {
    final db = await database;
    await db.insert(
      'favorites',
      {
        'userEmail': userEmail,
        'movieId': movieId,
        'title': title,
        'posterUrl': posterUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> removeFavorite(String userEmail, String movieId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'userEmail = ? AND movieId = ?',
      whereArgs: [userEmail, movieId],
    );
  }

  static Future<bool> isFavorite(String userEmail, String movieId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'userEmail = ? AND movieId = ?',
      whereArgs: [userEmail, movieId],
    );
    return result.isNotEmpty;
  }

  static Future<List<Movie>> getFavorites(String userEmail) async {
    final db = await database;
    final maps = await db.query(
      'favorites',
      where: 'userEmail = ?',
      whereArgs: [userEmail],
    );
    return maps.map((e) {
      return Movie(
        id: e['movieId'] as String? ?? '',
        title: e['title'] as String? ?? '',
        posterUrl: e['posterUrl'] as String? ?? '',
        rating: 0,
        genres: const [],
        duration: 'Không rõ',
        trailerUrl: '',
      );
    }).toList();
  }
}
