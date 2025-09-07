import 'package:flutter/material.dart';

class PromptHivePage extends StatelessWidget {
  const PromptHivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('开始背单词'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          '这里是背单词的功能页面。',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
