
import 'dart:math';
import 'package:flutter/material.dart';
import 'models/word_entry.dart';
import 'word_repository.dart';

class PromptPage extends StatefulWidget {
  const PromptPage({super.key});

  @override
  State<PromptPage> createState() => _PromptPageState();
}

class _PromptPageState extends State<PromptPage> {
  final _repo = WordRepository();
  final _rand = Random();

  List<WordEntry> _pool = [];
  int _index = 0;
  bool _showAnswer = false;
  int _rememberCount = 0;
  int _forgetCount = 0;
  String _promptField = 'word'; // 'word' or 'meaning'

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await _repo.getAll();
    all.shuffle(_rand);
    setState(() {
      _pool = all;
      _index = 0;
      _showAnswer = false;
      _rememberCount = 0;
      _forgetCount = 0;
    });
  }

  void _next({required bool remembered}) {
    if (_pool.isEmpty) return;
    // 简易 SRS：没记得的插回更靠前（大概率再次出现）
    if (!remembered) {
      final current = _pool[_index];
      final insertAt = min(_index + 3, _pool.length);
      _pool.removeAt(_index);
      _pool.insert(insertAt, current);
      _forgetCount += 1;
    } else {
      _rememberCount += 1;
      _index += 1;
    }
    if (_index >= _pool.length) {
      _index = _pool.length - 1;
    }
    setState(() {
      _showAnswer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _pool.length;
    final remaining = total - _index;
    final current = total > 0 ? _pool[_index] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('提词学习'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => setState(() => _promptField = v),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'word', child: Text('以“单词”作为提示')),
              PopupMenuItem(value: 'meaning', child: Text('以“释义”作为提示')),
            ],
            icon: const Icon(Icons.tips_and_updates),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: '重新开始',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: total == 0
            ? const Center(child: Text('还没有数据，先去导入一些单词吧~'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('总数：$total'),
                      Text('剩余：$remaining'),
                      Text('记得：$_rememberCount / 没记得：$_forgetCount'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showAnswer = !_showAnswer),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: _buildCardContent(current!),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => _showAnswer = true),
                          icon: const Icon(Icons.visibility),
                          label: const Text('显示答案'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => _next(remembered: false)),
                          icon: const Icon(Icons.close),
                          label: const Text('没记得'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => _next(remembered: true)),
                          icon: const Icon(Icons.check),
                          label: const Text('记得'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
      ),
    );
  }

  Widget _buildCardContent(WordEntry current) {
    final prompt = _promptField == 'word' ? current.word : current.meaning;
    final answer = _promptField == 'word' ? current.meaning : current.word;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _showAnswer ? answer : prompt,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        if (_showAnswer) ...[
          const SizedBox(height: 12),
          if (current.example != null && current.example!.isNotEmpty)
            Text(
              current.example!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
        ]
      ],
    );
  }
}
