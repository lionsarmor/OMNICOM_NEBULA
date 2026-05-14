import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum _MainSection { news, buddies, messages, channels, system }

class MainPage extends StatefulWidget {
  final bool darkMode;
  final VoidCallback onToggleTheme;
  final String username;

  const MainPage({
    super.key,
    required this.darkMode,
    required this.onToggleTheme,
    required this.username,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  _MainSection _section = _MainSection.news;

  void _logout(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _select(_MainSection section) => setState(() => _section = section);

  @override
  Widget build(BuildContext context) {
    final isDark = widget.darkMode;

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
                Container(
                  height: 60,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(gradient: headerGradient),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "OMNICOM",
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
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 10),
                    children: [
                      _navButton(
                        Icons.dashboard_rounded,
                        "News",
                        accent,
                        isDark,
                        selected: _section == _MainSection.news,
                        onTap: () => _select(_MainSection.news),
                      ),
                      _navButton(
                        Icons.group_rounded,
                        "Buddies",
                        accent,
                        isDark,
                        selected: _section == _MainSection.buddies,
                        onTap: () => _select(_MainSection.buddies),
                      ),
                      _navButton(
                        Icons.chat_rounded,
                        "Messages",
                        accent,
                        isDark,
                        selected: _section == _MainSection.messages,
                        onTap: () => _select(_MainSection.messages),
                      ),
                      _navButton(
                        Icons.tv_rounded,
                        "Channels",
                        accent,
                        isDark,
                        selected: _section == _MainSection.channels,
                        onTap: () => _select(_MainSection.channels),
                      ),
                      _navButton(
                        Icons.ondemand_video_rounded,
                        "Watch Party",
                        accent,
                        isDark,
                        onTap: () => Navigator.pushNamed(context, '/watchparty'),
                      ),
                      _navButton(
                        Icons.memory_rounded,
                        "System",
                        accent,
                        isDark,
                        selected: _section == _MainSection.system,
                        onTap: () => _select(_MainSection.system),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 4),
                  child: Text(
                    "v0.9.2 - Nebula",
                    style: TextStyle(
                      color: accent.withOpacity(0.6),
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
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
                          SizedBox(
                            width: 95,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.username.isNotEmpty
                                      ? widget.username
                                      : "Guest",
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
                          ),
                        ],
                      ),
                      IconButton(
                        tooltip: 'System',
                        icon: Icon(Icons.more_vert_rounded, color: textColor),
                        onPressed: () => _select(_MainSection.system),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
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
                        _sectionTitle,
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
                            onPressed: widget.onToggleTheme,
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
                    child: _sectionBody(textColor, accent, isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _sectionTitle {
    switch (_section) {
      case _MainSection.news:
        return "Nebula - News";
      case _MainSection.buddies:
        return "Nebula - Buddies";
      case _MainSection.messages:
        return "Nebula - Messages";
      case _MainSection.channels:
        return "Nebula - Channels";
      case _MainSection.system:
        return "Nebula - System";
    }
  }

  Widget _sectionBody(Color textColor, Color accent, bool isDark) {
    switch (_section) {
      case _MainSection.news:
        return _contentPanel(
          title: "Nebula Core Online",
          subtitle: "Operations feed",
          icon: Icons.dashboard_rounded,
          lines: const [
            "Welcome to the OMNICOM main console.",
            "Backend link: localhost:4400",
            "Frontend link: localhost:5400",
          ],
          textColor: textColor,
          accent: accent,
          isDark: isDark,
        );
      case _MainSection.buddies:
        return _contentPanel(
          title: "Buddies",
          subtitle: "Presence roster",
          icon: Icons.group_rounded,
          lines: const [
            "User_42A - Online",
            "Nebula relay - Online",
            "Contacts service - Ready for backend wiring",
          ],
          textColor: textColor,
          accent: accent,
          isDark: isDark,
        );
      case _MainSection.messages:
        return _contentPanel(
          title: "Messages",
          subtitle: "Local message center",
          icon: Icons.chat_rounded,
          lines: const [
            "Inbox ready.",
            "Channel message routes exist in the backend source.",
            "Database tables still need to be added for persistent chat.",
          ],
          textColor: textColor,
          accent: accent,
          isDark: isDark,
        );
      case _MainSection.channels:
        return _contentPanel(
          title: "Channels",
          subtitle: "Directory",
          icon: Icons.tv_rounded,
          lines: const [
            "# general - Open",
            "# watch-party - Open",
            "# system - Operators only",
          ],
          textColor: textColor,
          accent: accent,
          isDark: isDark,
        );
      case _MainSection.system:
        return _contentPanel(
          title: "System",
          subtitle: "Runtime status",
          icon: Icons.memory_rounded,
          lines: const [
            "Auth store: local memory mode",
            "API health endpoint: /api/health",
            "Docker/Postgres can be enabled once sudo access is available.",
          ],
          textColor: textColor,
          accent: accent,
          isDark: isDark,
        );
    }
  }

  Widget _contentPanel({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> lines,
    required Color textColor,
    required Color accent,
    required bool isDark,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: accent, size: 34),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: accent.withOpacity(0.85),
                          fontSize: 13,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              ...lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(top: 7, right: 10),
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          line,
                          style: TextStyle(
                            color: textColor.withOpacity(isDark ? 0.86 : 0.92),
                            fontSize: 16,
                            height: 1.4,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(
    IconData icon,
    String label,
    Color accent,
    bool darkMode, {
    bool selected = false,
    VoidCallback? onTap,
  }) {
    final borderColor = selected ? accent : accent.withOpacity(0.2);
    final fillColor = selected ? accent.withOpacity(0.12) : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: accent.withOpacity(0.15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: accent),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
