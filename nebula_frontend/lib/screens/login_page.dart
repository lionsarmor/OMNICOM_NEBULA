import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';
import '../widgets/nebula_login_animation.dart';
import '../theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool darkMode;

  const LoginPage({
    super.key,
    required this.onToggleTheme,
    required this.darkMode,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final AudioPlayer _audio = AudioPlayer();

  bool _loading = false;
  bool _showAnim = false;
  bool _errorMode = false;
  String? _status;

  @override
  void dispose() {
    _audio.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _status = "Synchronizing with Nebula Core…";
      _loading = true;
    });

    try {
      final res = await ApiService.login(
        _userCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      if (res.containsKey('error')) {
        setState(() {
          _showAnim = true;
          _errorMode = true;
          _loading = false;
          _status = "❌ ${res['error']}";
        });
        _audio.play(AssetSource('sfx/access_denied.wav'));
        return;
      }

      if (res.containsKey('token')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', res['token']);

        String username = _userCtrl.text.trim();
        try {
          final profile = await ApiService.getProfile(res['token']);
          if (profile['username'] is String &&
              (profile['username'] as String).isNotEmpty) {
            username = profile['username'];
          }
        } catch (_) {}

        setState(() {
          _status = "Access channel locked. Initiating uplink…";
          _showAnim = true;
          _errorMode = false;
          _loading = false;
        });
      } else {
        setState(() {
          _showAnim = true;
          _errorMode = true;
          _loading = false;
          _status = "❌ Authentication failed.";
        });
        _audio.play(AssetSource('sfx/access_denied.wav'));
      }
    } catch (e) {
      setState(() {
        _showAnim = true;
        _errorMode = true;
        _loading = false;
        _status = "❌ Network error: $e";
      });
      _audio.play(AssetSource('sfx/access_denied.wav'));
    }
  }

  void _goMain(String username) {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/main', arguments: username);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.darkMode;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final panelColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final headerGradient = isDark
        ? AppColors.darkHeaderGradient
        : AppColors.lightHeaderGradient;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ===== HEADER =====
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: headerGradient,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "NEBULA",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                    fontFamily: "Orbitron",
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "by OMNICOM",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.2,
                        fontFamily: "monospace",
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: Icon(
                        isDark
                            ? Icons
                                  .wb_sunny_rounded // ☀️ show sun when in dark mode
                            : Icons
                                  .dark_mode_rounded, // 🌙 show moon when in light mode
                        color: isDark
                            ? AppColors
                                  .accentDark // neon yellow for sun in dark mode
                            : AppColors
                                  .primaryLightDark, // deep navy for moon in light mode (visible)
                      ),
                      tooltip: isDark
                          ? "Switch to Light Mode"
                          : "Switch to Dark Mode",
                      onPressed: widget.onToggleTheme,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ===== BODY =====
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _showAnim
                    ? NebulaLoginAnimation(
                        key: const ValueKey('anim'),
                        errorMode: _errorMode,
                        onPhaseChange: (phase) {
                          switch (phase) {
                            case 'charge':
                              _audio.play(AssetSource('sfx/laser_charge.wav'));
                              break;
                            case 'fire':
                              _audio.play(AssetSource('sfx/laser_fire.wav'));
                              break;
                            case 'impact':
                              _audio.play(AssetSource('sfx/impact.wav'));
                              break;
                            default:
                              break;
                          }
                        },
                        onComplete: () => _goMain(_userCtrl.text.trim()),
                        onErrorEnd: () {
                          setState(() {
                            _showAnim = false;
                            _loading = false;
                            _status = "❌ Authentication failed. Try again.";
                          });
                        },
                      )
                    : _buildLoginForm(
                        isDark,
                        panelColor,
                        textColor,
                        headerGradient,
                      ),
              ),
            ),
          ),

          // ===== FOOTER =====
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 6),
            child: Column(
              children: [
                Text(
                  "© 2186–2025 OMNICOM Networks  •  NEBULA Communication Suite",
                  style: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[700],
                    fontSize: 12,
                    fontFamily: "monospace",
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Build Node 42A-LX • Version 0.1a • Quantum Time-Sync Active",
                  style: TextStyle(
                    color: isDark ? Colors.grey[600] : Colors.grey[600],
                    fontSize: 11,
                    fontFamily: "monospace",
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(
    bool isDark,
    Color panelColor,
    Color textColor,
    Gradient headerGradient,
  ) {
    return Container(
      key: const ValueKey('form'),
      width: 440,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? Colors.blueGrey.shade800 : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.blue.withOpacity(0.1)
                : Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: headerGradient,
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Text(
              "SIGN ON TO NEBULA",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _userCtrl,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: "Screen Name",
              labelStyle: TextStyle(color: textColor.withOpacity(0.9)),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: isDark ? const Color(0xFF23283B) : Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passCtrl,
            obscureText: true,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: "Password",
              labelStyle: TextStyle(color: textColor.withOpacity(0.9)),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: isDark ? const Color(0xFF23283B) : Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.accentDark
                  : AppColors.primaryLight,
              foregroundColor: isDark ? Colors.black : Colors.white,
              elevation: 3,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            onPressed: _loading ? null : _login,
            child: _loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : const Text("Sign On"),
          ),
          const SizedBox(height: 12),
          Text(
            _status ?? "Awaiting input…",
            style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: Text(
              "Create New Nebula ID",
              style: TextStyle(
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
