import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../theme/app_colors.dart';

class WatchPartyPage extends StatefulWidget {
  const WatchPartyPage({super.key});

  @override
  State<WatchPartyPage> createState() => _WatchPartyPageState();
}

class _WatchPartyPageState extends State<WatchPartyPage> {
  final TextEditingController _urlController = TextEditingController();
  String? _videoUrl;
  String? _inviteLink;

  VideoPlayerController? _fileController;
  YoutubePlayerController? _ytController;
  bool _isYouTube = false;
  bool _loading = false;
  String? _error;

  // 🔹 MAIN VIDEO LOADER
  void _loadVideo() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    _disposePlayers();
    debugPrint("🔸 INIT: Loading new URL -> $url");

    setState(() {
      _loading = true;
      _error = null;
      _videoUrl = url;
      _inviteLink = null;
      _isYouTube = url.contains("youtube.com") || url.contains("youtu.be");
    });

    try {
      if (_isYouTube) {
        final videoId = YoutubePlayerController.convertUrlToId(url);
        if (videoId == null) {
          debugPrint("❌ YT: Could not extract ID.");
          setState(() {
            _loading = false;
            _error = "Invalid YouTube URL.";
          });
          return;
        }

        debugPrint("🎥 YT: Extracted ID = $videoId");
        _ytController = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          autoPlay: true,
          params: const YoutubePlayerParams(
            showFullscreenButton: true,
            enableCaption: false,
          ),
        );

        _ytController?.listen((event) {
          debugPrint("🎬 YT Event: ${event.playerState}");
        });

        await Future.delayed(const Duration(milliseconds: 300));
        setState(() => _loading = false);
        debugPrint("✅ YT: Controller ready.");
      } else {
        debugPrint("🎞 FILE: Initializing stream...");
        _fileController = VideoPlayerController.networkUrl(Uri.parse(url));

        _fileController!.addListener(() {
          if (_fileController!.value.hasError) {
            debugPrint("❌ FILE: ${_fileController!.value.errorDescription}");
          }
        });

        await _fileController!.initialize();
        debugPrint("✅ FILE: Initialized (${_fileController!.value.duration}).");
        await _fileController!.play();
        debugPrint("▶ FILE: Playback started.");
        setState(() => _loading = false);
      }
    } catch (e, st) {
      debugPrint("💥 ERROR: $e\n$st");
      setState(() {
        _loading = false;
        _error = "Failed to load: $e";
      });
    }
  }

  void _disposePlayers() {
    debugPrint("♻ Disposing players...");
    try {
      _fileController?.dispose();
      _ytController?.close();
    } catch (e) {
      debugPrint("⚠ Dispose error: $e");
    }
    _fileController = null;
    _ytController = null;
  }

  void _generateInviteLink() {
    final randomId = Random().nextInt(999999).toString().padLeft(6, '0');
    setState(() {
      _inviteLink = "https://watch.omnicom.online/?room=$randomId";
    });
    debugPrint("🔗 Invite Link Generated: $_inviteLink");
  }

  @override
  void dispose() {
    _disposePlayers();
    _urlController.dispose();
    super.dispose();
  }

  // 🔹 UI
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.accentDark; // AOL yellow
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎬 Watch Party"),
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
      ),
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ===== INPUT =====
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: "Enter YouTube or Video File URL",
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                    ),
                    style: TextStyle(color: textColor),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text("Play"),
                  onPressed: _loading ? null : _loadVideo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ===== PLAYER AREA =====
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isDark ? Colors.black26 : Colors.grey.shade300,
                ),
                child: Center(
                  child: _loading
                      ? const CircularProgressIndicator()
                      : _error != null
                      ? Text(
                          _error!,
                          style: const TextStyle(color: Colors.redAccent),
                        )
                      : _buildPlayer(textColor),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== CONTROLS =====
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.pause),
                  color: accent,
                  onPressed: () {
                    debugPrint("⏸ Pause");
                    if (_isYouTube) {
                      _ytController?.pauseVideo();
                    } else {
                      _fileController?.pause();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  color: accent,
                  onPressed: () {
                    debugPrint("▶ Play");
                    if (_isYouTube) {
                      _ytController?.playVideo();
                    } else {
                      _fileController?.play();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  color: accent,
                  onPressed: () {
                    debugPrint("⏹ Stop");
                    if (_isYouTube) {
                      _ytController?.stopVideo();
                    } else {
                      _fileController?.pause();
                      _fileController?.seekTo(Duration.zero);
                    }
                  },
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _generateInviteLink,
                  icon: const Icon(Icons.share),
                  label: const Text("Invite"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),

            if (_inviteLink != null) ...[
              const SizedBox(height: 8),
              SelectableText(
                "Invite Link: $_inviteLink",
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  fontFamily: "monospace",
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 🔹 PLAYER BUILDER
  Widget _buildPlayer(Color textColor) {
    if (_videoUrl == null) {
      return Text(
        "Paste a URL and press Play",
        style: TextStyle(color: textColor),
      );
    }

    if (_isYouTube && _ytController != null) {
      debugPrint("📺 Rendering YouTube player...");
      return YoutubePlayer(controller: _ytController!, aspectRatio: 16 / 9);
    }

    if (_fileController != null && _fileController!.value.isInitialized) {
      debugPrint(
        "📼 Rendering file player (${_fileController!.value.duration.inSeconds}s)",
      );
      return AspectRatio(
        aspectRatio: _fileController!.value.aspectRatio,
        child: VideoPlayer(_fileController!),
      );
    }

    debugPrint("⏳ Waiting for video init...");
    return const CircularProgressIndicator();
  }
}
