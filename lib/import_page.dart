import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nihon_word_study/database/word_database.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  bool _isLoading = false;

  Future<void> _importWordLibrary() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. 让用户选择文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      // +++ 安全检查 (修正) +++
      // 检查 Widget 是否还存在于 Widget 树中
      if (!mounted) return;

      if (result == null || result.files.single.path == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未选择任何文件。')),
        );
        setState(() { _isLoading = false; });
        return;
      }

      // 2. 读取并解析 CSV 文件
      final filePath = result.files.single.path!;
      final input = File(filePath).openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(shouldParseNumbers: false))
          .toList();

      // +++ 安全检查 (修正) +++
      if (!mounted) return;

      if (fields.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV 文件为空！')),
        );
        setState(() { _isLoading = false; });
        return;
      }

      // 3. 获取表头并验证
      final headers = fields[0].map((e) => e.toString().toLowerCase().trim()).toList();
      final requiredHeaders = ['word', 'pronunciation', 'meaning'];
      
      if (!requiredHeaders.every((h) => headers.contains(h))) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV 文件缺少必要的列 (word, pronunciation, meaning)！')),
        );
        setState(() { _isLoading = false; });
        return;
      }

      // 4. 将数据转换为 Map 列表
      final List<Map<String, dynamic>> wordsToInsert = [];
      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.length != headers.length) continue; 

        final wordData = Map<String, dynamic>.fromIterables(headers, row);

        // 跳过空行
        if (wordData['word'] == null || wordData['word'].toString().trim().isEmpty) {
          continue;
        }

        wordsToInsert.add({
          'word': wordData['word'] ?? '',
          'pronunciation': wordData['pronunciation'] ?? '',
          'meaning': wordData['meaning'] ?? '',
          'part_of_speech': wordData['part_of_speech'] ?? '',
          'level': wordData['level'] ?? '',
          'notes': wordData['notes'] ?? '',
          'mastery_level': 0,
        });
      }

      // 5. 插入数据库
      if (wordsToInsert.isNotEmpty) {
        final dbHelper = WordDatabase.instance;
        int count = await dbHelper.batchInsertWords(wordsToInsert);

        // +++ 安全检查 (修正) +++
        if (!mounted) return;

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
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有找到可导入的新单词。')),
        );
      }
    } catch (e) {
      // +++ 安全检查 (修正) +++
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入失败: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导入词库'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.upload_file, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                '请选择一个 CSV 文件',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                '文件第一行必须包含表头：\nword, pronunciation, meaning, part_of_speech, level, notes',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.folder_open),
                      label: const Text('选择文件并导入'),
                      onPressed: _importWordLibrary,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

