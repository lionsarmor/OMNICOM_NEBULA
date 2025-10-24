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
    // === DARK THEME (unchanged) ===
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF33A0FF), // Blue accent
        secondary: Color(0xFFFFEA00), // Neon yellow
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

    // === LIGHT THEME (AOL / AIM style) ===
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0066CC), // AOL deep blue
        secondary: Color(0xFF0088FF), // brighter highlight blue
        background: Color(0xFFF2F6FF), // soft off-white
        surface: Color(0xFFE5EEFF), // light blue tint for panels
      ),
      scaffoldBackgroundColor: const Color(0xFFF2F6FF),
      fontFamily: 'Roboto',

      // ✅ AOL glossy gradient bar color
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        shadowColor: Colors.blue.shade700,
        elevation: 3,
      ),

      iconTheme: const IconThemeData(color: Color(0xFF0066CC)),

      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Color(0xFF001133)),
        bodyLarge: TextStyle(color: Color(0xFF001133)),
        titleLarge: TextStyle(color: Color(0xFF0044AA)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0077EE),
          foregroundColor: Colors.white,
          shadowColor: Colors.blueAccent.withOpacity(0.3),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        labelStyle: const TextStyle(color: Color(0xFF003366)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        border: const OutlineInputBorder(),
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
        // ✅ Keep username routing strict
        if (settings.name == '/main') {
          final arg = settings.arguments;
          final isValidUsername = arg is String && arg.trim().isNotEmpty;

          if (!isValidUsername) {
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

        // Default 404 page
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
