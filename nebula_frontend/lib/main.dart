import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'screens/login_page.dart';
import 'screens/main_page.dart';
import 'screens/register_page.dart';
import 'screens/watch_party_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized(); // ✅ not async
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

  ThemeData _neonTheme(bool dark) {
    const neon = Color(0xFFFFD600);
    return ThemeData(
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: dark ? const Color(0xFF00000F) : Colors.white,
      colorScheme: (dark ? const ColorScheme.dark() : const ColorScheme.light())
          .copyWith(primary: neon, secondary: neon, onPrimary: Colors.black),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0B0B1A),
        foregroundColor: neon,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neon,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      iconTheme: const IconThemeData(color: neon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nebula by OMNICOM',
      debugShowCheckedModeBanner: false,
      theme: _neonTheme(_darkMode),
      initialRoute: '/login', // ✅ back to dashboard flow
      routes: {
        '/login': (context) =>
            LoginPage(onToggleTheme: _toggleTheme, darkMode: _darkMode),
        '/register': (context) =>
            RegisterPage(onToggleTheme: _toggleTheme, darkMode: _darkMode),
        '/main': (context) => MainPage(
          darkMode: _darkMode,
          onToggleTheme: _toggleTheme,
          username:
              ModalRoute.of(context)?.settings.arguments as String? ?? 'Guest',
        ),
        '/watchparty': (context) => const WatchPartyPage(),
      },
    );
  }
}
