import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0F1A),
      appBar: AppBar(
        title: const Text('Nebula — Main Console'),
        backgroundColor: const Color(0xFF004466),
      ),
      body: const Center(
        child: Text(
          'Nebula Core Online.\nWelcome to the main application.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ),
    );
  }
}
