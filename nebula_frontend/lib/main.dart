import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// === Screens ===
import 'screens/login_page.dart';
import 'screens/main_page.dart';
import 'screens/register_page.dart';
import 'screens/watch_party_page.dart';

// === Theme ===
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';

void main() {
  // ✅ Required fix for desktop builds (Linux/Windows/macOS)
  WidgetsFlutterBinding.ensureInitialized();

  // 🧠 Safe cross-platform WebView initialization
  // (No SurfaceAndroidWebView, since it's Android-only)
  try {
    if (WebViewPlatform.instance == null) {
      WebViewPlatform.instance = WebViewPlatform.instance;
    }
  } catch (_) {
    // WebViewPlatform may already be initialized on mobile
  }

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

      // ✅ Centralized app theme
      theme: _darkMode ? AppTheme.dark : AppTheme.light,

      initialRoute: '/login',

      // === Route definitions ===
      routes: {
        '/login': (context) =>
            LoginPage(onToggleTheme: _toggleTheme, darkMode: _darkMode),
        '/register': (context) =>
            RegisterPage(onToggleTheme: _toggleTheme, darkMode: _darkMode),
        '/watchparty': (context) => const WatchPartyPage(),
      },

      // === Dynamic routes (e.g. /main?user=xyz) ===
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

        // Default 404 fallback
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
