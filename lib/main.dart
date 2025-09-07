// 所有的 import 语句都必须放在文件的最顶端
import 'package:flutter/material.dart';
import 'input_screen.dart'; // 导入单词输入页面
import 'import_page.dart'; // 导入“词库导入”页面
import 'import_hive_page.dart'; // 导入单词页面
import 'prompt_hive_page.dart'; // 背单词页面

// 整个文件只有一个 main 函数
void main() {
  runApp(const MyApp());
}

// 整个文件只有一个 MyApp 类
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '日単勉強',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'NotoSansSC',
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        cardTheme: CardThemeData(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      // 使用命名路由
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: '日単勉強'),
        '/import_hive': (context) => const ImportHivePage(),
        '/prompt_hive': (context) => const PromptHivePage(),
      },
    );
  }
}

// 这是您应用的主页 Widget
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  // 一个方法用来导航到单词学习功能
  void _navigateToWordStudy(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const InputScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // 在顶部的 AppBar 添加一个菜单
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'import') {
                // 导航到导入页面
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ImportPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload_file, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('导入词库'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      // 在主页中央添加一个按钮
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ようこそ！', // 欢迎!
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => _navigateToWordStudy(context),
              child: const Text('开始单词学习'),
            ),
            const SizedBox(height: 20),

            // 两个带路由的按钮
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/import_hive'),
              child: const Text('导入单词'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/prompt_hive'),
              child: const Text('开始背单词'),
            ),
          ],
        ),
      ),
    );
  }
}

