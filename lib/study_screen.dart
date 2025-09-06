import 'package:flutter/material.dart';

// 学习页面需要管理当前显示的单词索引，所以使用 StatefulWidget
class StudyScreen extends StatefulWidget {
  final List<String> words;

  // 构造函数，接收从输入页面传来的单词列表
  const StudyScreen({super.key, required this.words});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  int _currentIndex = 0;
  late List<String> _studyWords;

  @override
  void initState() {
    super.initState();
    // 初始化时，直接使用传入的已经打乱的单词列表
    _studyWords = widget.words;
  }

  void _nextWord() {
    setState(() {
      // 如果是最后一个单词
      if (_currentIndex >= _studyWords.length - 1) {
        // 重新洗牌，并从第一个开始
        _studyWords.shuffle();
        _currentIndex = 0;
        // (可选) 给用户一个提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('列表已学完！已重新开始。'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        // 否则，显示下一个单词
        _currentIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习中'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 主要显示区域
              Expanded(
                child: Center(
                  child: Card(
                    child: Container(
                      width: double.infinity,
                      height: 250,
                      alignment: Alignment.center,
                      child: Text(
                        _studyWords[_currentIndex], // 显示当前单词
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              // 进度指示器
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  '${_currentIndex + 1} / ${_studyWords.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              
              // “下一个”按钮
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _nextWord,
                child: const Text('下一个'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
