import 'package:flutter/material.dart';
import 'dart:math';

class WatchPartyPage extends StatefulWidget {
  const WatchPartyPage({super.key});

  @override
  State<WatchPartyPage> createState() => _WatchPartyPageState();
}

class _WatchPartyPageState extends State<WatchPartyPage> {
  final TextEditingController _urlController = TextEditingController();
  String? _videoUrl;
  String? _inviteLink;

  void _loadVideo() {
    setState(() {
      _videoUrl = _urlController.text.trim();
      _inviteLink = null;
    });
  }

  void _generateInviteLink() {
    final randomId = Random().nextInt(999999).toString().padLeft(6, '0');
    setState(() {
      _inviteLink = "https://watch.omnicom.online/?room=$randomId";
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF00E5FF) : const Color(0xFF0044AA);
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎬 Watch Party"),
        backgroundColor: isDark ? const Color(0xFF003355) : const Color(0xFFCCE0FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // URL Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: "Enter YouTube or File URL",
                      border: const OutlineInputBorder(),
                    ),
                    style: TextStyle(color: textColor),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text("Play"),
                  onPressed: _loadVideo,
                  style: ElevatedButton.styleFrom(backgroundColor: accent),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Player area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isDark ? Colors.black26 : Colors.grey.shade300,
                ),
                child: Center(
                  child: _videoUrl == null
                      ? Text(
                          "Paste a URL and press Play",
                          style: TextStyle(color: textColor, fontSize: 16),
                        )
                      : Text(
                          "▶ Playing: $_videoUrl",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textColor, fontSize: 16),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.pause), onPressed: () {}),
                IconButton(icon: const Icon(Icons.stop), onPressed: () {}),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _generateInviteLink,
                  icon: const Icon(Icons.share),
                  label: const Text("Invite"),
                  style: ElevatedButton.styleFrom(backgroundColor: accent),
                ),
              ],
            ),

            if (_inviteLink != null) ...[
              const SizedBox(height: 8),
              SelectableText(
                "Invite Link: $_inviteLink",
                style: TextStyle(color: accent, fontWeight: FontWeight.bold),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
