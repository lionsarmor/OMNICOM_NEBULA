import 'package:flutter/material.dart';
import '../services/api.dart';
import '../theme/app_colors.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool darkMode;

  const RegisterPage({
    super.key,
    required this.onToggleTheme,
    required this.darkMode,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _status;

  Future<void> _register() async {
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _status = "❌ Please enter both username and password.");
      return;
    }

    setState(() {
      _loading = true;
      _status = "Registering Nebula ID…";
    });

    try {
      final res = await ApiService.register(username, password);

      if (res.containsKey('error')) {
        setState(() {
          _loading = false;
          _status = "❌ ${res['error']}";
        });
        return;
      }

      if (res['ok'] == true) {
        setState(() {
          _loading = false;
          _status = "✅ Registration complete! Redirecting…";
        });

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          _loading = false;
          _status = "❌ Unexpected server response.";
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _status = "❌ Network error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.darkMode;

    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final panel = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final accent = isDark ? AppColors.accentDark : AppColors.primaryLight;
    final headerGradient = isDark
        ? AppColors.darkHeaderGradient
        : AppColors.lightHeaderGradient;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.primaryLight,
        title: const Text(
          'Create Nebula ID',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
              color: isDark ? AppColors.accentDark : AppColors.primaryLight,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(isDark ? 0.15 : 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ==== HEADER ====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: headerGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "REGISTER FOR NEBULA",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ==== INPUTS ====
              _inputField(
                controller: _userCtrl,
                label: 'Screen Name',
                textColor: textColor,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _inputField(
                controller: _passCtrl,
                label: 'Password',
                textColor: textColor,
                isDark: isDark,
                obscure: true,
              ),
              const SizedBox(height: 20),

              // ==== BUTTON ====
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                  elevation: 3,
                ),
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      )
                    : const Text('Create Account'),
              ),
              const SizedBox(height: 16),

              // ==== STATUS ====
              if (_status != null)
                Text(
                  _status!,
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),

              const SizedBox(height: 12),

              // ==== BACK BUTTON ====
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Back to Sign On', style: TextStyle(color: accent)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required Color textColor,
    required bool isDark,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor.withOpacity(0.9)),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: isDark ? const Color(0xFF23283B) : Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}
