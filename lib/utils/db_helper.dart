import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('items.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const defaultText= 'TEXT DEFAULT N/A';

    await db.execute('''
      CREATE TABLE items (
        id $idType,
        appName $textType,
        connectionName $textType,
        apiKey $textType,
        displayName $textType,
        description $textType,
        logoDark $textType,
        logoLight $textType
      )
    ''');
  }

  Future<int> insertItem(Map<String, dynamic> item) async {
    final db = await instance.database;
    return await db.insert('items', item);
  }

  Future<List<Map<String, dynamic>>> fetchAllItems() async {
    final db = await instance.database;
    return await db.query('items');
  }

  Future<int> updateItem(Map<String, dynamic> item, int id) async {
    final db = await instance.database;
    return await db.update('items', item, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteItem(int id) async {
    final db = await instance.database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }
}
