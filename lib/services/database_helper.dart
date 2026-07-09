import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/word_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('impostor_game.db');
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
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        hint TEXT NOT NULL
      )
    ''');

    final List<Map<String, String>> initialWords = [
      {"word": "Adobo", "hint": "Toyo"},
      {"word": "Sinigang", "hint": "Sampalok"},
      {"word": "Jollibee", "hint": "Manok"},
      {"word": "Jeepney", "hint": "Pasada"},
      {"word": "Boracay", "hint": "Buhangin"},
      {"word": "Balut", "hint": "Sisiw"},
      {"word": "Halo-Halo", "hint": "Yelo"},
      {"word": "Lumpia", "hint": "Handaan"},
      {"word": "Taho", "hint": "Sago"},
      {"word": "Trisikel", "hint": "Toda"}
    ];

    for (var item in initialWords) {
      await db.insert('words', item);
    }
  }

  Future<int> getWordCount() async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM words')
    );
    return count ?? 0;
  }

  Future<WordModel?> getRandomWord() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM words ORDER BY RANDOM() LIMIT 1'
    );
    if (maps.isNotEmpty) {
      return WordModel.fromMap(maps.first);
    }
    return null;
  }
}