import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_organizer.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 1,

      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {

    await db.execute('''
    CREATE TABLE folders(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      folder_name TEXT NOT NULL,
      timestamp TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE cards(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      card_name TEXT NOT NULL,
      suit TEXT NOT NULL,
      image_url TEXT,
      folder_id INTEGER,
      FOREIGN KEY(folder_id) REFERENCES folders(id) ON DELETE CASCADE
    )
    ''');

    await _prepopulateFolders(db);
    await _prepopulateCards(db);
  }

  Future _prepopulateFolders(Database db) async {

    final folders = ['Hearts','Diamonds','Clubs','Spades'];

    for (var folder in folders) {

      await db.insert('folders', {
        'folder_name': folder,
        'timestamp': DateTime.now().toIso8601String()
      });

    }

  }

  Future _prepopulateCards(Database db) async {

    final values = ['A','2','3','4','5','6','7','8','9','0','J','Q','K'];

    final suits = [
      {'name':'Hearts','code':'H'},
      {'name':'Diamonds','code':'D'},
      {'name':'Clubs','code':'C'},
      {'name':'Spades','code':'S'}
    ];

    for (int i = 0; i < suits.length; i++) {

      final folderId = i + 1;

      for (var value in values) {

        final imagePath = 'assets/cards/$value${suits[i]['code']}.png';

        await db.insert('cards', {
          'card_name': value,
          'suit': suits[i]['name'],
          'image_url': imagePath,
          'folder_id': folderId
        });

      }

    }

  }

}