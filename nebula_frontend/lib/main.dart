import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/main_page.dart';
import 'screens/register_page.dart';

void main() {
  runApp(const NebulaApp());
}

class NebulaApp extends StatefulWidget {
  const NebulaApp({super.key});

  @override
  State<NebulaApp> createState() => _NebulaAppState();
}

class _NebulaAppState extends State<NebulaApp> {
  bool _darkMode = true;

  void _toggleTheme() => setState(() => _darkMode = !_darkMode);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: _darkMode ? Brightness.dark : Brightness.light,
      useMaterial3: true,
      colorSchemeSeed: _darkMode
          ? const Color(0xFF33A0FF)
          : const Color(0xFF0044AA),
      fontFamily: 'Roboto',
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nebula by OMNICOM',
      theme: theme,
      initialRoute: '/login',
      routes: {
        '/login': (context) =>
            LoginPage(onToggleTheme: _toggleTheme, darkMode: _darkMode),
        '/main': (context) =>
            MainPage(onToggleTheme: _toggleTheme, darkMode: _darkMode),
        '/register': (context) =>
            RegisterPage(onToggleTheme: _toggleTheme, darkMode: _darkMode),
      },
    );
  }
}
