import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;

    Future<void> printTableSchema(Database db) async {
      List<Map<String, dynamic>> result =
          await db.rawQuery('PRAGMA table_info(items)');
      result.forEach((row) {
        print('Column: ${row['name']}');
      });
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE items(
            id INTEGER PRIMARY KEY,
            englishText TEXT,
            japaneseText TEXT,
            date TEXT,
            theme TEXT,
            level TEXT,
            length TEXT,
            style TEXT,
            audioPath TEXT  -- 音声ファイルのパスを保存するカラム

          )
          ''');
      },
         onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute('ALTER TABLE items ADD COLUMN audioPath TEXT');
        }
        // 新しいカラムを追加する場合は、さらにバージョンをチェックして対応します
      },
    );
  }


  Future<void> insertItem(Map<String, dynamic> item) async {
    final db = await database;
    try {
      await db.insert(
        'items',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Inserted item: $item'); // デバッグメッセージ
    } catch (e) {
      print('Error inserting item: $e'); // エラーハンドリング
    }
  }

  Future<List<Map<String, dynamic>>> fetchItems() async {
    final db = await database;
    return await db.query('items');
  }

  Future<void> deleteItem(int id) async {
  final db = await database;
  try {
    await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('Item deleted: $id');
  } catch (e) {
    print('Error deleting item: $e');
  }
}

  Future<void> deleteAllItems() async {
    final db = await database;
    await db.delete('items');
  }
}
