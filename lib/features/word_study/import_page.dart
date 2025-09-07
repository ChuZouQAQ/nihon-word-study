
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'parsers.dart';
import 'word_repository.dart';
import 'models/word_entry.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  List<WordEntry> _preview = [];
  String? _error;
  bool _loading = false;

  Future<void> _pickAndParse() async {
    setState(() {
      _error = null;
      _loading = true;
      _preview = [];
    });
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'json', 'txt'],
        withData: true,
      );
      if (res == null || res.files.isEmpty) {
        setState(() => _loading = false);
        return;
      }
      final file = res.files.first;
      final name = file.name.toLowerCase();
      Uint8List? data = file.bytes;
      if (data == null) {
        // Mobile/Desktop fallback to path
        if (file.path != null) {
          data = await File(file.path!).readAsBytes();
        }
      }
      if (data == null) {
        setState(() {
          _error = '无法读取文件数据';
          _loading = false;
        });
        return;
      }
      final text = String.fromCharCodes(data);
      List<WordEntry> parsed;
      if (name.endsWith('.csv') || name.endsWith('.txt')) {
        parsed = ImportParsers.fromCsv(text);
      } else if (name.endsWith('.json')) {
        parsed = ImportParsers.fromJsonText(text);
      } else {
        parsed = [];
      }
      setState(() {
        _preview = parsed;
        _loading = false;
        if (parsed.isEmpty) {
          _error = '未解析到有效词条，请检查文件格式';
        }
      });
    } catch (e) {
      setState(() {
        _error = '导入失败：$e';
        _loading = false;
      });
    }
  }

  Future<void> _confirmImport() async {
    if (_preview.isEmpty) return;
    setState(() => _loading = true);
    try {
      final repo = WordRepository();
      await repo.append(_preview);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('导入完成')),
      );
      setState(() {
        _preview = [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '保存失败：$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导入单词'),
        actions: [
          IconButton(
            onPressed: _preview.isNotEmpty ? _confirmImport : null,
            icon: const Icon(Icons.save),
            tooltip: '确认导入',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _loading ? null : _pickAndParse,
                  icon: const Icon(Icons.file_open),
                  label: const Text('选择文件 (CSV/JSON/TXT)'),
                ),
                const SizedBox(width: 12),
                if (_loading) const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: _preview.isEmpty
                  ? const Center(child: Text('选择文件后预览将显示在这里'))
                  : ListView.separated(
                      itemCount: _preview.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final w = _preview[index];
                        return ListTile(
                          title: Text(w.word),
                          subtitle: Text(w.meaning + (w.example != null ? "\n例句：${w.example}" : "")),
                        );
                      },
                    ),
            ),
            if (_preview.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _confirmImport,
                  icon: const Icon(Icons.save),
                  label: Text('确认导入 ${_preview.length} 条'),
                ),
              )
          ],
        ),
      ),
    );
  }
}
