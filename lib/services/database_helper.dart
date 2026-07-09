import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
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
      onOpen: _syncDatabaseWithJSON, // Checks and re-syncs JSON changes instantly on app open!
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
  }

  // Wipes and rewrites the internal database only if you update words.json items!
  Future _syncDatabaseWithJSON(Database db) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/words.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      // 1. Check how many items currently exist inside SQLite
      final countResult = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM words')) ?? 0;

      bool needsUpdate = false;

      // 2. If the count changed, we definitely need an update
      if (countResult != jsonList.length) {
        needsUpdate = true;
      } else {
        // 3. Even if the count is the same, let's verify a random sample entry 
        // to see if a word was swapped out or a typo was fixed!
        final List<Map<String, dynamic>> existingSample = await db.rawQuery('SELECT word FROM words LIMIT 1');
        if (existingSample.isNotEmpty) {
          final String firstDbWord = existingSample.first['word'];
          final String firstJsonWord = jsonList.first['word'];
          
          // If the first words don't match, the file has been altered
          if (firstDbWord != firstJsonWord) {
            needsUpdate = true;
          }
        }
      }

      // Execute wipe and reload if changes are detected
      if (needsUpdate) {
        await db.delete('words');
        
        for (var item in jsonList) {
          await db.insert('words', {
            'word': item['word'],
            'hint': item['hint'],
          });
        }
        print("Database automatically updated with ${jsonList.length} fresh words!");
      }
    } catch (e) {
      print("Database sync notice: $e");
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