import 'package:flutter/material.dart';
import 'study_screen.dart'; // 导入学习页面

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  // 使用 TextEditingController 来获取 TextField 中的文本
  final TextEditingController _textController = TextEditingController();

  void _startStudy() {
    final String text = _textController.text.trim();
    if (text.isEmpty) {
      return; // 如果输入为空，则不执行任何操作
    }

    // 解析输入的文本，通过换行、逗号、空格等分隔符
    // 并过滤掉空字符串
    final List<String> words = text
        .split(RegExp(r'[\n,、\s]+'))
        .where((word) => word.trim().isNotEmpty)
        .toList();

    if (words.isNotEmpty) {
      // 随机打乱单词列表
      words.shuffle();

      // 跳转到学习页面 (StudyScreen)，并把单词列表传递过去
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => StudyScreen(words: words),
        ),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '单词抽认卡',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '输入单词列表开始学习',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _textController,
                  maxLines: 8, //允许多行输入
                  decoration: InputDecoration(
                    hintText: '请在此处输入单词，可以用换行、逗号或空格分隔。\n例如：\n日本語\n勉強, 学校\n友達',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _startStudy,
                  child: const Text('开始学习'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
