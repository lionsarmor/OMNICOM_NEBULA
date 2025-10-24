import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/main_page.dart';
import 'screens/register_page.dart';
import 'screens/watch_party_page.dart';

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
      colorSchemeSeed:
          _darkMode ? const Color(0xFF33A0FF) : const Color(0xFF0044AA),
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
        '/register': (context) =>
            RegisterPage(onToggleTheme: _toggleTheme, darkMode: _darkMode),
        '/watchparty': (context) => const WatchPartyPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          final username = (settings.arguments as String?) ?? 'Guest';
          return MaterialPageRoute(
            builder: (_) => MainPage(
              darkMode: _darkMode,
              onToggleTheme: _toggleTheme,
              username: username,
            ),
          );
        }

        // Optional: simple 404 fallback if route not found
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                '404 — Page Not Found',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
      },
    );
  }
}
