
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/word_entry.dart';

/// 简易仓库：使用 SharedPreferences 存储所有单词列表
/// key: 'word_repository.entries' -> String (json array)
class WordRepository {
  static const _kKey = 'word_repository.entries';

  Future<List<WordEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List)
        .map((e) => WordEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<void> saveAll(List<WordEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_kKey, raw);
  }

  Future<void> append(List<WordEntry> entries) async {
    final all = await getAll();
    all.addAll(entries);
    await saveAll(all);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }
}
