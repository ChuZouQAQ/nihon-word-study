import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// 这是一个单例类，用于管理整个应用的数据库连接
class WordDatabase {
  static final WordDatabase instance = WordDatabase._init();

  static Database? _database;

  WordDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('words.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // 创建数据库表的函数
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const nullableTextType = 'TEXT';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE word_table ( 
  id $idType, 
  word $textType,
  pronunciation $textType,
  meaning $textType,
  part_of_speech $nullableTextType,
  level $nullableTextType,
  mastery_level $integerType DEFAULT 0,
  last_reviewed $nullableTextType,
  notes $nullableTextType
  )
''');
  }

  // --- 您项目中已有的其他数据库方法 ---
  // 例如：
  // Future<Word> create(Word word) async { ... }
  // Future<Word> readWord(int id) async { ... }
  // ...

  /// [新增] 批量插入单词的方法
  /// 使用事务来保证数据一致性并提高性能
  Future<int> batchInsertWords(List<Map<String, dynamic>> words) async {
    final db = await instance.database;
    int count = 0;

    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final word in words) {
        // 使用 replace 策略，如果单词已存在（基于主键），则会替换它。
        // 如果要防止重复（基于单词本身），则需要先查询。
        // 为简化，这里直接插入。
        batch.insert('word_table', word, conflictAlgorithm: ConflictAlgorithm.ignore);
        count++;
      }
      await batch.commit(noResult: true);
    });
    
    return count;
  }


  // 关闭数据库连接
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
