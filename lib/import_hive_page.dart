import 'package:flutter/material.dart';

class ImportHivePage extends StatelessWidget {
  const ImportHivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导入单词'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          '这里是导入单词的功能页面。',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
