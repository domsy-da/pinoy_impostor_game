import 'package:http/http.dart' as http;
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

  // Automatically syncs local assets without breaking online word packs
  Future _syncDatabaseWithJSON(Database db) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/words.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      // 1. Check how many items currently exist inside SQLite
      final countResult = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM words')) ?? 0;

      // 2. If the table is completely empty (0 entries), populate it immediately
      if (countResult == 0) {
        for (var item in jsonList) {
          await db.insert('words', {
            'word': item['word'],
            'hint': item['hint'],
          });
        }
        print("Database initialized with local default words!");
        return; // Exit early since it's a fresh database
      }

      // 3. Typo/Alteration Check: Compare your JSON's first word against the DB
      final List<Map<String, dynamic>> existingSample = await db.rawQuery('SELECT word FROM words LIMIT 1');
      if (existingSample.isNotEmpty) {
        final String firstDbWord = existingSample.first['word'];
        final String firstJsonWord = jsonList.first['word'];
        
        // If the asset text was altered or fixed, let's update entries safely
        if (firstDbWord != firstJsonWord) {
          // Look for any words in words.json that aren't in the DB yet and insert them
          for (var item in jsonList) {
            final String wordText = item['word'];
            final List<Map<String, dynamic>> existing = await db.query(
              'words',
              where: 'word = ?',
              whereArgs: [wordText],
            );
            
            if (existing.isEmpty) {
              await db.insert('words', {
                'word': item['word'],
                'hint': item['hint'],
              });
            }
          }
          print("Local asset modifications synced safely without overwriting packs!");
        }
      }
    } catch (e) {
      print("Database sync notice: $e");
    }
  }

  // Appends a fresh word package from Pastebin on top of existing SQLite table entries
  Future<bool> fetchOnlineWordsPackage(String rawPastebinUrl) async {
    try {
      // 1. Send the network request to Pastebin
      final response = await http.get(Uri.parse(rawPastebinUrl));

      if (response.statusCode == 200) {
        // 2. Decode the clean raw JSON text body
        final List<dynamic> newJsonList = json.decode(response.body);

        if (newJsonList.isNotEmpty) {
          final db = await instance.database;

          // REMOVED: await db.delete('words'); <- This line was erasing your old words!

          // 3. Loop and add only new words to avoid duplicates
          for (var item in newJsonList) {
            final String wordText = item['word'];
            
            // Check if this word already exists in the database
            final List<Map<String, dynamic>> existing = await db.query(
              'words',
              where: 'word = ?',
              whereArgs: [wordText],
            );

            // If it's a completely new word, insert it cleanly
            if (existing.isEmpty) {
              await db.insert('words', {
                'word': item['word'],
                'hint': item['hint'],
              });
            }
          }
          print("Successfully appended new online words!");
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Error downloading online word asset: $e");
      return false;
    }
  }
  Future<bool> resetToDefaultLocalWords() async {
    try {
      final db = await instance.database;
      final String jsonString = await rootBundle.loadString('assets/data/words.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      await db.delete('words');
      
      for (var item in jsonList) {
        await db.insert('words', {
          'word': item['word'],
          'hint': item['hint'],
        });
      }
      print("Database successfully reset back to local configuration!");
      return true;
    } catch (e) {
      print("Error processing local recovery file: $e");
      return false;
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