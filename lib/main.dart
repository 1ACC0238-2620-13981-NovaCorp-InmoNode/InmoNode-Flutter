import 'package:flutter/material.dart';
import 'package:inmonode/core/di/dependency_injection.dart';
import 'package:inmonode/core/theme.dart';

void main() {
  setupDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = const TextTheme();
    return MaterialApp(
      title: 'InmoNode',
      debugShowCheckedModeBanner: false,
      theme: MaterialTheme(textTheme).light(),
      darkTheme: MaterialTheme(textTheme).dark(),
      home: const Scaffold(
        body: SafeArea(child: Center(child: Text('InmoNode'))),
      ),
    );
  }
}
