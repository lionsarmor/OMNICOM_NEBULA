import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool darkMode;

  const RegisterPage({
    super.key,
    required this.onToggleTheme,
    required this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = darkMode;
    final bg = isDark ? const Color(0xFF0B0E19) : const Color(0xFFF2F4FF);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF004466) : const Color(0xFF33A0FF),
        title: const Text('Create Nebula ID'),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
            ),
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF171C28) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.blueGrey.shade700 : Colors.blueGrey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black54 : Colors.grey.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Register for Nebula',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Screen Name',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF23283B) : Colors.white,
                ),
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 12),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF23283B) : Colors.white,
                ),
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF0066CC) : const Color(0xFFFFD700),
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Create Account'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Back to Sign On',
                  style: TextStyle(color: isDark ? Colors.blue[200] : Colors.blue[800]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
