import 'package:hive/hive.dart';

part 'word.g.dart'; // 这个文件将在下一步通过命令生成

@HiveType(typeId: 1)
class Word {
  @HiveField(0)
  final String japanese;

  @HiveField(1)
  final String reading;

  @HiveField(2)
  final String meaning;

  Word({required this.japanese, required this.reading, required this.meaning});
}
