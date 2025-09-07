
import 'dart:convert';
import 'package:csv/csv.dart';
import 'models/word_entry.dart';

class ImportParsers {
  static List<WordEntry> fromCsv(String csvText) {
    final rows = const CsvToListConverter(eol: '\n').convert(csvText, shouldParseNumbers: false);
    if (rows.isEmpty) return [];

    // 判断是否有表头
    final first = rows.first.map((e) => e.toString().trim().toLowerCase()).toList();
    final hasHeader = first.contains('word') || first.contains('meaning');

    int wordIdx = 0, meaningIdx = 1, exampleIdx = 2;
    int startRow = 0;
    if (hasHeader) {
      wordIdx = first.indexOf('word');
      meaningIdx = first.indexOf('meaning');
      exampleIdx = first.indexOf('example');
      // 处理缺失列名的情况
      if (wordIdx < 0) wordIdx = 0;
      if (meaningIdx < 0) meaningIdx = 1;
      if (exampleIdx < 0) exampleIdx = 2;
      startRow = 1;
    }

    final List<WordEntry> out = [];
    for (int i = startRow; i < rows.length; i++) {
      final r = rows[i];
      if (r.isEmpty) continue;
      String word = (wordIdx < r.length ? r[wordIdx] : '').toString().trim();
      String meaning = (meaningIdx < r.length ? r[meaningIdx] : '').toString().trim();
      String? example = (exampleIdx < r.length ? r[exampleIdx] : null)?.toString().trim();
      if (word.isEmpty || meaning.isEmpty) continue;
      out.add(WordEntry(word: word, meaning: meaning, example: (example?.isEmpty ?? true) ? null : example));
    }
    return out;
  }

  static List<WordEntry> fromJsonText(String jsonText) {
    final decoded = jsonDecode(jsonText);
    if (decoded is! List) return [];
    final List<WordEntry> out = [];
    for (final e in decoded) {
      if (e is Map<String, dynamic>) {
        final word = (e['word'] ?? '').toString().trim();
        final meaning = (e['meaning'] ?? '').toString().trim();
        final example = e['example']?.toString().trim();
        if (word.isEmpty || meaning.isEmpty) continue;
        out.add(WordEntry(word: word, meaning: meaning, example: (example?.isEmpty ?? true) ? null : example));
      } else if (e is Map) {
        final word = (e['word'] ?? '').toString().trim();
        final meaning = (e['meaning'] ?? '').toString().trim();
        final example = e['example']?.toString().trim();
        if (word.isEmpty || meaning.isEmpty) continue;
        out.add(WordEntry(word: word, meaning: meaning, example: (example?.isEmpty ?? true) ? null : example));
      }
    }
    return out;
  }
}
