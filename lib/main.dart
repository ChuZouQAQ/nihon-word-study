import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '背单词训练',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WordTrainerScreen(),
    );
  }
}

class WordTrainerScreen extends StatefulWidget {
  const WordTrainerScreen({super.key});

  @override
  _WordTrainerScreenState createState() => _WordTrainerScreenState();
}

class _WordTrainerScreenState extends State<WordTrainerScreen> {
  final TextEditingController _textController = TextEditingController();
  List<String> _allWords = [];
  List<String> _shuffledWords = [];
  String _currentWord = '';
  int _currentIndex = 0;
  String _currentTranslation = '';
  bool _isLoadingTranslation = false;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  // 从本地存储加载单词
  Future<void> _loadWords() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWords = prefs.getStringList('word_list') ?? [];
    if (savedWords.isNotEmpty) {
      setState(() {
        _allWords = savedWords;
        _textController.text = _allWords.join(', ');
        _shuffleWords();
      });
    }
  }

  // 保存单词到本地存储
  Future<void> _saveWords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('word_list', _allWords);
  }

  // 清空所有单词
  Future<void> _clearWords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('word_list');
    setState(() {
      _textController.clear();
      _allWords = [];
      _shuffledWords = [];
      _currentWord = '';
      _currentIndex = 0;
    });
  }

  void _processWords() {
    // 支持空格、换行、中英文逗号分隔，并转小写
    _allWords = _textController.text
        .split(RegExp(r'[\s,，]+'))
        .where((word) => word.isNotEmpty)
        .map((w) => w.trim().toLowerCase())
        .toList();
    _saveWords();
    _shuffleWords();
  }

  void _shuffleWords() {
    setState(() {
      _shuffledWords = List.from(_allWords); // 创建一个副本
      _shuffledWords.shuffle();
      _currentIndex = 0;
      _currentTranslation = '';
      _displayNextWord();
    });
  }

  void _displayNextWord() {
    if (_shuffledWords.isEmpty) {
      setState(() {
        _currentWord = '请输入单词！';
        _currentTranslation = '';
      });
      return;
    }

    if (_currentIndex < _shuffledWords.length) {
      setState(() {
        _currentWord = _shuffledWords[_currentIndex];
        _currentIndex++;
        _currentTranslation = ''; // Reset translation when showing new word
      });
    } else {
      setState(() {
        _currentWord = '训练完成！';
        _currentTranslation = '';
      });
    }
  }

  // 模拟一个异步的翻译获取
  Future<void> _getTranslation(String word) async {
    setState(() {
      _isLoadingTranslation = true;
    });

    // 假设这是调用翻译API
    await Future.delayed(const Duration(seconds: 1));
    final translations = {
      'apple': '苹果',
      'banana': '香蕉',
      'car': '汽车',
      'dog': '狗',
      'cat': '猫',
      'house': '房子',
      'school': '学校',
      'computer': '电脑',
      'book': '书',
      'table': '桌子',
      'phone': '电话',
      'friend': '朋友',
      'family': '家庭',
      'water': '水',
      'sun': '太阳',
    };

    setState(() {
      _currentTranslation = translations[word.toLowerCase()] ?? '无翻译';
      _isLoadingTranslation = false;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool trainingComplete =
        _currentIndex >= _shuffledWords.length && _shuffledWords.isNotEmpty;
    final bool canStart = _allWords.isNotEmpty && !trainingComplete;
    final double progress =
        _shuffledWords.isNotEmpty ? _currentIndex / _shuffledWords.length : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('背单词训练器'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              '请在下方输入您的单词（使用空格、逗号或换行分隔）：',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                hintText: '例如: apple, banana, car, dog',
                filled: true,
                fillColor: Color(0xFFF3F4F6),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _processWords,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('开始训练', style: TextStyle(fontSize: 18.0)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearWords,
                    icon: const Icon(Icons.delete),
                    label: const Text('清空单词', style: TextStyle(fontSize: 18.0)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentWord.isEmpty ? '请开始您的训练！' : _currentWord,
                    style: TextStyle(
                      fontSize: 48.0,
                      fontWeight: FontWeight.bold,
                      color: _currentWord.isEmpty ? Colors.grey : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_currentTranslation.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        _currentTranslation,
                        style: const TextStyle(
                          fontSize: 24.0,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_currentWord == '训练完成！')
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton.icon(
                        onPressed: _shuffleWords,
                        icon: const Icon(Icons.refresh),
                        label: const Text('再来一轮', style: TextStyle(fontSize: 18.0)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            // 进度条
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.blueAccent,
              minHeight: 10,
            ),
            const SizedBox(height: 8.0),
            Center(
              child: Text(
                _shuffledWords.isEmpty
                    ? '0/0'
                    : '第 $_currentIndex / ${_shuffledWords.length} 个',
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canStart ? _displayNextWord : null,
                    icon: const Icon(Icons.navigate_next),
                    label: const Text('下一个单词', style: TextStyle(fontSize: 18.0)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentWord.isNotEmpty && !trainingComplete
                        ? () => _getTranslation(_currentWord)
                        : null,
                    icon: _isLoadingTranslation
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.translate),
                    label: const Text('显示翻译', style: TextStyle(fontSize: 18.0)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            ElevatedButton.icon(
              onPressed: _allWords.isNotEmpty ? _shuffleWords : null,
              icon: const Icon(Icons.refresh),
              label: const Text('重新开始', style: TextStyle(fontSize: 18.0)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
