import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/ticket.dart';

class TicketDatabase {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final path = join(await getDatabasesPath(), 'tickets.db');

    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tickets(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            movieId TEXT,
            movieTitle TEXT,
            posterUrl TEXT,
            seats TEXT,
            totalAmount REAL,
            dateTime TEXT,
            userEmail TEXT,
            theater TEXT,
            status TEXT DEFAULT 'active'
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE tickets ADD COLUMN userEmail TEXT");
          await db.execute("ALTER TABLE tickets ADD COLUMN theater TEXT");
          await db.execute(
              "ALTER TABLE tickets ADD COLUMN status TEXT DEFAULT 'active'");
        }
      },
    );

    return _database!;
  }

  static Future<void> insertTicket(Ticket ticket) async {
    final db = await getDatabase();
    await db.insert(
      'tickets',
      ticket.toMapNoId(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Ticket>> getAllTickets() async {
    final db = await getDatabase();
    final maps = await db.query('tickets');
    return maps.map((e) => Ticket.fromMap(e)).toList();
  }

  static Future<List<Ticket>> getTicketsByUser(String email) async {
    final db = await getDatabase();
    final maps = await db.query(
      'tickets',
      where: 'userEmail = ?',
      whereArgs: [email],
    );
    return maps.map((e) => Ticket.fromMap(e)).toList();
  }

  static Future<void> updateStatus(int id, String status) async {
    final db = await getDatabase();
    await db.update(
      'tickets',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteTicket(int id) async {
    final db = await getDatabase();
    await db.delete('tickets', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearAllTickets() async {
    final db = await getDatabase();
    await db.delete('tickets');
  }
}
