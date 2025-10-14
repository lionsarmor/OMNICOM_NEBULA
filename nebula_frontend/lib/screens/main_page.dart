import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  final bool darkMode;
  final VoidCallback onToggleTheme;

  const MainPage({
    super.key,
    required this.darkMode,
    required this.onToggleTheme,
  });

  void _logout(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = darkMode
        ? const Color(0xFF0C0F1A)
        : const Color(0xFFE4E9F4);
    final sidebarColor = darkMode
        ? const Color(0xFF141B2E)
        : const Color(0xFFD9E4FF);
    final topBarColor = darkMode
        ? const Color(0xFF003355)
        : const Color(0xFFCCE0FF);
    final textColor = darkMode ? Colors.white70 : Colors.black87;
    final accent = darkMode ? const Color(0xFF00E5FF) : const Color(0xFF0044AA);

    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        children: [
          // LEFT SIDEBAR — retro AOL buddy list + nav
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: sidebarColor,
              border: Border(
                right: BorderSide(
                  color: darkMode
                      ? Colors.cyan.shade900
                      : Colors.blueGrey.shade200,
                  width: 1.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: darkMode
                      ? Colors.cyanAccent.withOpacity(0.1)
                      : Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header Logo
                Container(
                  height: 60,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: darkMode
                          ? [const Color(0xFF004466), const Color(0xFF001020)]
                          : [const Color(0xFF66A3FF), const Color(0xFFE4F0FF)],
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "🛰️  OMNICOM",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: 1.5,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                ),

                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 10),
                    children: [
                      _navButton(
                        Icons.dashboard,
                        "Dashboard",
                        accent,
                        darkMode,
                      ),
                      _navButton(
                        Icons.chat_rounded,
                        "Messages",
                        accent,
                        darkMode,
                      ),
                      _navButton(
                        Icons.people_alt_rounded,
                        "Contacts",
                        accent,
                        darkMode,
                      ),
                      _navButton(
                        Icons.tv_rounded,
                        "Channels",
                        accent,
                        darkMode,
                      ),
                      _navButton(
                        Icons.storage_rounded,
                        "Servers",
                        accent,
                        darkMode,
                      ),
                      _navButton(
                        Icons.settings_rounded,
                        "Settings",
                        accent,
                        darkMode,
                      ),
                      _navButton(
                        Icons.terminal_rounded,
                        "System Log",
                        accent,
                        darkMode,
                      ),
                    ],
                  ),
                ),

                // Bottom Profile + Status
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: darkMode
                        ? const Color(0xFF0E1422)
                        : const Color(0xFFDCE6F9),
                    border: Border(
                      top: BorderSide(
                        color: darkMode
                            ? Colors.cyanAccent.withOpacity(0.15)
                            : Colors.blueGrey.shade200,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: darkMode
                                  ? Colors.cyanAccent.withOpacity(0.3)
                                  : Colors.blueGrey.shade300,
                              border: Border.all(
                                color: accent.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "User_42A",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Online",
                                style: TextStyle(
                                  color: darkMode
                                      ? Colors.greenAccent
                                      : Colors.green.shade700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        tooltip: 'Settings',
                        icon: Icon(Icons.more_vert_rounded, color: textColor),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // MAIN PANEL
          Expanded(
            child: Column(
              children: [
                // TOP BAR
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: topBarColor,
                    border: Border(
                      bottom: BorderSide(
                        color: darkMode
                            ? Colors.cyanAccent.withOpacity(0.1)
                            : Colors.blueGrey.shade200,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Nebula — Core Console",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.3,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: darkMode
                                ? 'Switch to Light Mode'
                                : 'Switch to Dark Mode',
                            icon: Icon(
                              darkMode
                                  ? Icons.wb_sunny_rounded
                                  : Icons.dark_mode_rounded,
                              color: textColor,
                            ),
                            onPressed: onToggleTheme,
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            tooltip: 'Log out',
                            icon: Icon(Icons.logout_rounded, color: textColor),
                            onPressed: () => _logout(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // MAIN CONTENT AREA
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: darkMode
                            ? [
                                const Color(0xFF0B1120),
                                const Color(0xFF091020),
                                const Color(0xFF070A12),
                              ]
                            : [
                                const Color(0xFFF3F6FF),
                                const Color(0xFFDCE6F9),
                                const Color(0xFFCBDCF8),
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '🛰️  Nebula Core Online\nWelcome to the OMNICOM main console.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          height: 1.6,
                          fontFamily: 'monospace',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, String label, Color accent, bool darkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(6),
        hoverColor: darkMode
            ? accent.withOpacity(0.15)
            : accent.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: darkMode
                  ? Colors.cyanAccent.withOpacity(0.1)
                  : Colors.blueGrey.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: darkMode
                    ? Colors.cyanAccent
                    : Colors.blueAccent.shade700,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: darkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
