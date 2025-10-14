import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/api.dart';
import '../widgets/nebula_login_animation.dart';

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

  Future<void> _login() async {
    setState(() {
      _status = "Synchronizing with Nebula Core…";
      _loading = true;
    });

    try {
      await ApiService.login(_userCtrl.text, _passCtrl.text);
      // ✅ Successful login
      setState(() {
        _showAnim = true;
        _errorMode = false;
      });
    } catch (e) {
      // ❌ Failed login
      setState(() {
        _showAnim = true;
        _errorMode = true;
      });
    }
  }

  void _goMain() {
    Navigator.of(context).pushReplacementNamed('/main');
  }

  @override
  void dispose() {
    _audio.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.darkMode;
    final bgColor = isDark ? const Color(0xFF0C0F1A) : const Color(0xFFEAF3FF);
    final panelColor = isDark ? const Color(0xFF171C28) : const Color(0xFFE0E6F2);
    final textColor = isDark ? Colors.white : Colors.black87;

    final headerGradient = isDark
        ? const LinearGradient(colors: [Color(0xFF004466), Color(0xFF000820)])
        : const LinearGradient(colors: [Color(0xFF33A0FF), Color(0xFF005CBB)]);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: headerGradient,
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
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
                      "by OmniCom",
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
                        isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
                        color: Colors.white,
                      ),
                      tooltip: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
                      onPressed: widget.onToggleTheme,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _showAnim
                    ? Container(
                        key: const ValueKey('anim'),
                        width: 520,
                        height: 400,
                        decoration: BoxDecoration(
                          color: panelColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? Colors.blueGrey.shade800
                                : Colors.blueGrey.shade200,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.blue.withOpacity(0.08)
                                  : Colors.black12,
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: NebulaLoginAnimation(
                            errorMode: _errorMode,
                            onComplete: () async {
                              await _playSoundSequence(success: true);
                              _goMain();
                            },
                            onErrorEnd: () async {
                              await _playSoundSequence(success: false);
                              setState(() {
                                _showAnim = false;
                                _loading = false;
                                _status = "❌ Authentication failed. Try again.";
                              });
                            },
                            onPhaseChange: (phase) => _handlePhaseSound(phase),
                          ),
                        ),
                      )
                    : Container(
                        key: const ValueKey('form'),
                        width: 440,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: panelColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? Colors.blueGrey.shade800
                                : Colors.blueGrey.shade200,
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
                                labelStyle:
                                    TextStyle(color: textColor.withOpacity(0.9)),
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor:
                                    isDark ? const Color(0xFF23283B) : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _passCtrl,
                              obscureText: true,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle:
                                    TextStyle(color: textColor.withOpacity(0.9)),
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor:
                                    isDark ? const Color(0xFF23283B) : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFF0066CC)
                                    : const Color(0xFFFFD700),
                                foregroundColor:
                                    isDark ? Colors.white : Colors.black,
                                elevation: 3,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 14),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              onPressed: _loading ? null : _login,
                              child: const Text("Sign On"),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _status ?? "Awaiting input…",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: textColor.withOpacity(0.7)),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/register'),
                              child: Text(
                                "Create New Nebula ID",
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.blue[200]
                                        : Colors.blue[800]),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 6),
            child: Column(
              children: [
                Text(
                  "© 2186–2025 OmniCom Networks  •  NEBULA Communication Suite",
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

  // 🎵 Handle sound phases
  void _handlePhaseSound(String phase) async {
    switch (phase) {
      case 'charge':
        await _audio.play(AssetSource('sfx/laser_charge.wav'));
        break;
      case 'fire':
        await _audio.play(AssetSource('sfx/laser_fire.wav'));
        break;
      case 'impact':
        await _audio.play(AssetSource('sfx/impact.wav'));
        break;
      case 'error':
        await _audio.play(AssetSource('sfx/access_denied.wav'));
        break;
    }
  }

  // 🎵 Sequence for completion or error
  Future<void> _playSoundSequence({required bool success}) async {
    if (success) {
      await _audio.play(AssetSource('sfx/impact.wav'));
    } else {
      await _audio.play(AssetSource('sfx/access_denied.wav'));
    }
  }
}
