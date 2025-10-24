import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/main_page.dart';
import 'screens/register_page.dart';
import 'screens/watch_party_page.dart';
import 'theme/app_theme.dart'; // ✅ central theme
import 'theme/app_colors.dart'; // ✅ direct color access if needed

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nebula by OMNICOM',

      // ✅ Pulls directly from centralized AppTheme
      theme: _darkMode ? AppTheme.dark : AppTheme.light,

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
          final arg = settings.arguments;
          final isValidUsername = arg is String && arg.trim().isNotEmpty;

          if (!isValidUsername) {
            // Fallback to login if username missing
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
              username: username,
            ),
          );
        }

        // Default fallback 404
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
