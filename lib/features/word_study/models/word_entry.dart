
class WordEntry {
  final String word;
  final String meaning;
  final String? example;

  WordEntry({
    required this.word,
    required this.meaning,
    this.example,
  });

  factory WordEntry.fromJson(Map<String, dynamic> json) {
    return WordEntry(
      word: (json['word'] ?? '').toString(),
      meaning: (json['meaning'] ?? '').toString(),
      example: json['example']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'word': word,
        'meaning': meaning,
        'example': example,
      };
}
