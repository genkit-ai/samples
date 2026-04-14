import 'package:flutter/material.dart';
import 'package:eli5_flutter/home_page.dart';
import 'package:eli5_flutter/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ELI5',
      debugShowCheckedModeBanner: false,
      theme: Eli5Theme.light(),
      darkTheme: Eli5Theme.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
