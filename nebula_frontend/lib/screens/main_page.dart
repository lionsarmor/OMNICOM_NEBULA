import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MainPage extends StatelessWidget {
  final bool darkMode;
  final VoidCallback onToggleTheme;
  final String username;

  const MainPage({
    super.key,
    required this.darkMode,
    required this.onToggleTheme,
    required this.username,
  });

  void _logout(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = darkMode;

    // Centralized color picks
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final sidebarColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final topBarColor = isDark
        ? const Color(0xFF1A1F33)
        : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final accent = isDark ? AppColors.accentDark : AppColors.primaryLight;
    final headerGradient = isDark
        ? AppColors.darkHeaderGradient
        : AppColors.lightHeaderGradient;

    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        children: [
          // ==== LEFT SIDEBAR ====
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: sidebarColor,
              border: Border(
                right: BorderSide(color: accent.withOpacity(0.2), width: 1.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // ==== HEADER LOGO ====
                Container(
                  height: 60,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(gradient: headerGradient),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "🛰️  OMNICOM",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: 1.5,
                      fontFamily: 'Orbitron',
                      shadows: [
                        Shadow(color: accent.withOpacity(0.7), blurRadius: 8),
                      ],
                    ),
                  ),
                ),

                // ==== NAVIGATION ====
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 10),
                    children: [
                      _navButton(
                        Icons.dashboard_rounded,
                        "News",
                        accent,
                        isDark,
                      ),
                      _navButton(
                        Icons.group_rounded,
                        "Buddies",
                        accent,
                        isDark,
                      ),
                      _navButton(
                        Icons.chat_rounded,
                        "Messages",
                        accent,
                        isDark,
                      ),
                      _navButton(Icons.tv_rounded, "Channels", accent, isDark),
                      _navButton(
                        Icons.ondemand_video_rounded,
                        "Watch Party",
                        accent,
                        isDark,
                        onTap: () =>
                            Navigator.pushNamed(context, '/watchparty'),
                      ),
                      _navButton(
                        Icons.memory_rounded,
                        "System",
                        accent,
                        isDark,
                      ),
                    ],
                  ),
                ),

                // ==== SIDEBAR FOOTER ====
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 4),
                  child: Text(
                    "v0.9.2 — Nebula",
                    style: TextStyle(
                      color: accent.withOpacity(0.6),
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // ==== PROFILE BAR ====
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0E1422)
                        : const Color(0xFFDCE6F9),
                    border: Border(
                      top: BorderSide(color: accent.withOpacity(0.2)),
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
                              color: accent.withOpacity(0.25),
                              border: Border.all(
                                color: accent.withOpacity(0.8),
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
                                username.isNotEmpty ? username : "Guest",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Online",
                                style: TextStyle(color: accent, fontSize: 11),
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

          // ==== MAIN PANEL ====
          Expanded(
            child: Column(
              children: [
                // ==== TOP BAR ====
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: topBarColor,
                    border: Border(
                      bottom: BorderSide(color: accent.withOpacity(0.1)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.05),
                        offset: const Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Nebula — Core Console",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.3,
                          color: textColor,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: isDark
                                ? 'Switch to Light Mode'
                                : 'Switch to Dark Mode',
                            icon: Icon(
                              isDark
                                  ? Icons.wb_sunny_rounded
                                  : Icons.dark_mode_rounded,
                              color: accent,
                            ),
                            onPressed: onToggleTheme,
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            tooltip: 'Log out',
                            icon: Icon(Icons.logout_rounded, color: accent),
                            onPressed: () => _logout(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ==== MAIN CONTENT ====
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                const Color(0xFF0B0E15),
                                const Color(0xFF0C0F20),
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
                          shadows: [
                            Shadow(
                              color: accent.withOpacity(0.4),
                              blurRadius: 12,
                            ),
                          ],
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

  // ==== NAV BUTTON ====
  Widget _navButton(
    IconData icon,
    String label,
    Color accent,
    bool darkMode, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: accent.withOpacity(0.15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: accent.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: accent),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: darkMode ? Colors.white70 : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
