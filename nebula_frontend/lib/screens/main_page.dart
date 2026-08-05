import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

enum _MainSection { news, buddies, messages, channels, system, settings }

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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!mounted) return;
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
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 10),
                    children: [
                      _navButton(
                        'assets/icons/news.svg',
                        "News",
                        accent,
                        isDark,
                        selected: _section == _MainSection.news,
                        onTap: () => _select(_MainSection.news),
                      ),
                      _navButton(
                        'assets/icons/buddies.svg',
                        "Buddies",
                        accent,
                        isDark,
                        selected: _section == _MainSection.buddies,
                        onTap: () => _select(_MainSection.buddies),
                      ),
                      _navButton(
                        'assets/icons/messages.svg',
                        "Messages",
                        accent,
                        isDark,
                        selected: _section == _MainSection.messages,
                        onTap: () => _select(_MainSection.messages),
                      ),
                      _navButton(
                        'assets/icons/channels.svg',
                        "Channels",
                        accent,
                        isDark,
                        selected: _section == _MainSection.channels,
                        onTap: () => _select(_MainSection.channels),
                      ),
                      _navButton(
                        'assets/icons/watch_party.svg',
                        "Watch Party",
                        accent,
                        isDark,
                        onTap: () =>
                            Navigator.pushNamed(context, '/watchparty'),
                      ),
                      _navButton(
                        'assets/icons/system.svg',
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
                    "v0.9.2 — Nebula",
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
                        tooltip: 'Settings',
                        icon: _assetIcon(
                          'assets/icons/settings.svg',
                          textColor,
                          size: 22,
                        ),
                        onPressed: () => _select(_MainSection.settings),
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
                    children: [
                      Expanded(
                        child: Text(
                          _titleFor(_section),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.3,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                        tooltip: 'Settings',
                        icon: Icon(Icons.settings_rounded, color: accent),
                        onPressed: () => _select(_MainSection.settings),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        tooltip: 'Log out',
                        icon: Icon(Icons.logout_rounded, color: accent),
                        onPressed: _logout,
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
                    child: _dashboardBody(textColor, accent, isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _titleFor(_MainSection section) {
    switch (section) {
      case _MainSection.news:
        return "Nebula — News";
      case _MainSection.buddies:
        return "Nebula — Buddies";
      case _MainSection.messages:
        return "Nebula — Messages";
      case _MainSection.channels:
        return "Nebula — Channels";
      case _MainSection.system:
        return "Nebula — System";
      case _MainSection.settings:
        return "Nebula — Settings";
    }
  }

  String _iconAssetFor(_MainSection section) {
    switch (section) {
      case _MainSection.news:
        return 'assets/icons/news.svg';
      case _MainSection.buddies:
        return 'assets/icons/buddies.svg';
      case _MainSection.messages:
        return 'assets/icons/messages.svg';
      case _MainSection.channels:
        return 'assets/icons/channels.svg';
      case _MainSection.system:
        return 'assets/icons/system.svg';
      case _MainSection.settings:
        return 'assets/icons/settings.svg';
    }
  }

  Widget _assetIcon(String asset, Color color, {double size = 20}) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  Widget _dashboardBody(Color textColor, Color accent, bool isDark) {
    final content = _contentFor(_section);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _sectionHeader(content, textColor, accent),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: content.metrics
                  .map((metric) => _metricTile(metric, textColor, accent))
                  .toList(),
            ),
            const SizedBox(height: 18),
            _infoPanel(
              title: "What Belongs Here",
              icon: Icons.assignment_rounded,
              lines: content.plannedItems,
              textColor: textColor,
              accent: accent,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _infoPanel(
              title: "Current Placeholder Data",
              icon: Icons.storage_rounded,
              lines: content.placeholderItems,
              textColor: textColor,
              accent: accent,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  _SectionContent _contentFor(_MainSection section) {
    switch (section) {
      case _MainSection.news:
        return const _SectionContent(
          title: "News",
          subtitle: "Operations feed and personal updates",
          metrics: [
            _Metric("Unread", "4", Icons.markunread_rounded),
            _Metric("Invites", "1", Icons.local_activity_rounded),
            _Metric("System", "OK", Icons.verified_rounded),
          ],
          plannedItems: [
            "Global OMNICOM announcements",
            "Friend activity and recent joins",
            "Watch Party invites and room highlights",
            "Service notices from the backend",
          ],
          placeholderItems: [
            "Nebula relay is online at localhost:4400",
            "Watch Party route is available from the sidebar",
            "Dashboard modules are now selectable",
          ],
        );
      case _MainSection.buddies:
        return const _SectionContent(
          title: "Buddies",
          subtitle: "Roster, presence, and friend requests",
          metrics: [
            _Metric("Online", "3", Icons.circle_rounded),
            _Metric("Away", "1", Icons.schedule_rounded),
            _Metric("Requests", "0", Icons.person_add_alt_1_rounded),
          ],
          plannedItems: [
            "Buddy list with online, away, and offline states",
            "Add, remove, block, and favorite actions",
            "Direct message and invite-to-watch-party shortcuts",
            "Profile preview with status text",
          ],
          placeholderItems: [
            "User_42A — Online",
            "Nebula Relay — Online",
            "Demo Contact — Away",
          ],
        );
      case _MainSection.messages:
        return const _SectionContent(
          title: "Messages",
          subtitle: "Inbox and direct communication",
          metrics: [
            _Metric("Inbox", "2", Icons.inbox_rounded),
            _Metric("Drafts", "0", Icons.edit_note_rounded),
            _Metric("Alerts", "1", Icons.notifications_rounded),
          ],
          plannedItems: [
            "One-to-one conversations",
            "Unread indicators and message search",
            "Attachments and shared watch links",
            "Delivery, typing, and read status",
          ],
          placeholderItems: [
            "Welcome packet from OMNICOM",
            "Watch Party room link test message",
            "System alert: auth running in local memory mode",
          ],
        );
      case _MainSection.channels:
        return const _SectionContent(
          title: "Channels",
          subtitle: "Rooms and shared spaces",
          metrics: [
            _Metric("Open", "3", Icons.tag_rounded),
            _Metric("Private", "1", Icons.lock_rounded),
            _Metric("Live", "1", Icons.sensors_rounded),
          ],
          plannedItems: [
            "Public and private channel directory",
            "Channel posts and member lists",
            "Pinned media rooms for Watch Party",
            "Moderation and invite controls",
          ],
          placeholderItems: [
            "# general — Open",
            "# watch-party — Open",
            "# system — Operators only",
          ],
        );
      case _MainSection.system:
        return const _SectionContent(
          title: "System",
          subtitle: "Runtime, diagnostics, and service health",
          metrics: [
            _Metric("API", "UP", Icons.api_rounded),
            _Metric("Auth", "MEM", Icons.key_rounded),
            _Metric("Web", "5400", Icons.public_rounded),
          ],
          plannedItems: [
            "Backend health and latency",
            "Auth provider and session status",
            "Database connection state",
            "Build version and feature flags",
          ],
          placeholderItems: [
            "API health endpoint: /api/health",
            "Frontend served at localhost:5400",
            "Auth store: memory mode for local development",
          ],
        );
      case _MainSection.settings:
        return const _SectionContent(
          title: "Settings",
          subtitle: "Account and client preferences",
          metrics: [
            _Metric("Theme", "2", Icons.contrast_rounded),
            _Metric("Profile", "1", Icons.badge_rounded),
            _Metric("Privacy", "ON", Icons.shield_rounded),
          ],
          plannedItems: [
            "Account profile and display name",
            "Theme, sound, and animation controls",
            "Notification preferences",
            "Watch Party playback defaults",
          ],
          placeholderItems: [
            "Theme toggle is active in the top bar",
            "Login sounds are enabled",
            "Animations are enabled",
          ],
        );
    }
  }

  Widget _sectionHeader(
    _SectionContent content,
    Color textColor,
    Color accent,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.16),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accent.withOpacity(0.55)),
          ),
          child: Center(
            child: _assetIcon(_iconAssetFor(_section), accent, size: 30),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                content.subtitle,
                style: TextStyle(
                  color: textColor.withOpacity(0.72),
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricTile(_Metric metric, Color textColor, Color accent) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(metric.icon, color: accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.label,
                  style: TextStyle(
                    color: textColor.withOpacity(0.65),
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  metric.value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoPanel({
    required String title,
    required IconData icon,
    required List<String> lines,
    required Color textColor,
    required Color accent,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF111827) : Colors.white).withOpacity(
          isDark ? 0.58 : 0.82,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 21),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
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
                        color: textColor.withOpacity(0.85),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton(
    String iconAsset,
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
              _assetIcon(iconAsset, accent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: darkMode ? Colors.white70 : AppColors.textLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionContent {
  final String title;
  final String subtitle;
  final List<_Metric> metrics;
  final List<String> plannedItems;
  final List<String> placeholderItems;

  const _SectionContent({
    required this.title,
    required this.subtitle,
    required this.metrics,
    required this.plannedItems,
    required this.placeholderItems,
  });
}

class _Metric {
  final String label;
  final String value;
  final IconData icon;

  const _Metric(this.label, this.value, this.icon);
}
