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
    // === COLOR THEMES ===
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF33A0FF), // blue accent
        secondary: Color(0xFFFFEA00), // neon yellow
        surface: Color(0xFF141B2E),
        background: Color(0xFF0C0F1A),
      ),
      scaffoldBackgroundColor: const Color(0xFF0C0F1A),
      fontFamily: 'Roboto',
      iconTheme: const IconThemeData(color: Color(0xFFFFEA00)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF141B2E),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0044AA), // AOL blue
        secondary: Color(0xFF0066FF),
        background: Color(0xFFE4E9F4),
        surface: Color(0xFFD9E4FF),
      ),
      scaffoldBackgroundColor: const Color(0xFFE4E9F4),
      fontFamily: 'Roboto',
      iconTheme: const IconThemeData(color: Color(0xFF0044AA)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFD9E4FF),
        titleTextStyle: TextStyle(color: Color(0xFF003399), fontSize: 18),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nebula by OMNICOM',
      theme: _darkMode ? darkTheme : lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) =>
            LoginPage(onToggleTheme: _toggleTheme, darkMode: _darkMode),
        '/register': (context) =>
            RegisterPage(onToggleTheme: _toggleTheme, darkMode: _darkMode),
        '/watchparty': (context) => const WatchPartyPage(),
      },
      onGenerateRoute: (settings) {
        // Route enforcement for username
        if (settings.name == '/main') {
          final arg = settings.arguments;
          final isValidUsername = arg is String && arg.trim().isNotEmpty;

          if (!isValidUsername) {
            // invalid / empty username — send back to login
            return MaterialPageRoute(
              builder: (_) =>
                  LoginPage(onToggleTheme: _toggleTheme, darkMode: _darkMode),
            );
          }

          final username = (arg as String).trim();
          return MaterialPageRoute(
            builder: (_) => MainPage(
              darkMode: _darkMode,
              onToggleTheme: _toggleTheme,
              username: username, // ✅ required and passed
            ),
          );
        }

        // fallback 404
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
