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

  /// [新增] 批量插入单词的方法
  /// 使用事务（transaction）来保证数据一致性并大幅提高插入性能。
  /// @param words: 一个 Map 列表，每个 Map 代表一个单词对象。
  /// @return: 返回成功插入的单词数量。
  Future<int> batchInsertWords(List<Map<String, dynamic>> words) async {
    final db = await instance.database;
    int count = 0;

    // 使用事务可以确保所有操作要么全部成功，要么全部失败，
    // 防止数据只插入一半。同时，它比逐条插入快得多。
    await db.transaction((txn) async {
      // 创建一个批处理对象
      final batch = txn.batch();

      for (final word in words) {
        // 将插入操作添加到批处理中
        // conflictAlgorithm.ignore 表示如果单词已存在，则忽略此次插入
        batch.insert('word_table', word, conflictAlgorithm: ConflictAlgorithm.ignore);
        count++;
      }
      
      // 提交批处理，一次性执行所有插入操作
      await batch.commit(noResult: true);
    });
    
    return count;
  }

  // 您已有的其他数据库方法可以保留在这里
  // ...

  // 关闭数据库连接
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

