import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';

// 请确保这里的路径与您项目中的数据库文件路径一致
import 'database/word_database.dart';

// 这是一个独立的页面，您可以从应用的任何地方（如设置页的按钮）跳转过来
class ImportPage extends StatelessWidget {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('从 CSV 导入词库'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(Icons.upload_file, size: 100, color: Colors.deepPurple),
              const SizedBox(height: 20),
              const Text(
                '请选择一个 UTF-8 编码的 CSV 文件进行导入。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: Colors.grey[200],
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    '文件第一行必须是表头，且须包含:\nword, pronunciation, meaning, part_of_speech, level',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.folder_open, size: 28),
                onPressed: () => _importWordLibrary(context),
                label: const Text('选择文件并导入'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 处理词库导入的核心逻辑
  Future<void> _importWordLibrary(BuildContext context) async {
    try {
      // 1. 让用户选择文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('操作取消：未选择任何文件。')));
        return;
      }
      
      // 显示加载提示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("正在导入词库..."),
              ],
            ),
          );
        },
      );

      // 2. 读取并解析 CSV 文件
      final filePath = result.files.single.path!;
      final input = File(filePath).openRead();
      final fields = await input
          .transform(utf8.decoder) // 必须使用 UTF-8
          .transform(const CsvToListConverter())
          .toList();

      Navigator.of(context).pop(); // 关闭加载提示

      if (fields.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('导入失败：CSV 文件为空！')));
          return;
      }

      // 3. 获取表头并验证
      final headers = fields[0].map((e) => e.toString().trim().toLowerCase()).toList();
      final requiredHeaders = ['word', 'pronunciation', 'meaning', 'part_of_speech', 'level'];
      
      if (!requiredHeaders.every((h) => headers.contains(h))) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('导入失败：CSV 文件表头不正确或缺少必要的列！'),
            duration: Duration(seconds: 5),
            )
          );
          return;
      }
      
      // 4. 将数据转换为 Word 对象列表
      final List<Map<String, dynamic>> wordsToInsert = [];
      // 从第二行开始遍历 (i=1)
      for (int i = 1; i < fields.length; i++) {
          final row = fields[i];
          // 跳过空行或格式不正确的行
          if (row.length != headers.length) continue; 

          final wordData = Map<String, dynamic>.fromIterables(headers, row);
          
          // 基础数据校验，防止空数据导入
          if(wordData['word'] == null || wordData['word'].toString().isEmpty) continue;

          wordsToInsert.add({
              'word': wordData['word'] ?? '',
              'pronunciation': wordData['pronunciation'] ?? '',
              'meaning': wordData['meaning'] ?? '',
              'part_of_speech': wordData['part_of_speech'] ?? '',
              'level': wordData['level'] ?? '',
              'notes': wordData['notes'] ?? '',
              'mastery_level': 0, // 默认值
              'last_reviewed': null, // 默认值
          });
      }

      if (wordsToInsert.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('没有找到可导入的有效单词。')));
        return;
      }

      // 5. 插入数据库
      final dbHelper = WordDatabase.instance;
      int count = await dbHelper.batchInsertWords(wordsToInsert);

      // 6. 给用户反馈
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('导入完成'),
          content: Text('成功导入了 $count 个新单词！'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('好的'),
            ),
          ],
        ),
      );

    } catch (e) {
      // 捕获任何潜在的错误
      if (context.mounted) {
        // 确保在异步调用后 context 仍然有效
        Navigator.of(context).pop(); // 关闭可能存在的加载提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入时发生错误: $e')),
        );
      }
    }
  }
}

