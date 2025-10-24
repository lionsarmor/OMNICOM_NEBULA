import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'dart:math';
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

  void _loadVideo() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    _disposePlayers();

    setState(() {
      _videoUrl = url;
      _inviteLink = null;
      _isYouTube = url.contains("youtube.com") || url.contains("youtu.be");
    });

    if (_isYouTube) {
      final videoId = YoutubePlayerController.convertUrlToId(url);
      if (videoId != null) {
        _ytController = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          autoPlay: true,
          params: const YoutubePlayerParams(showFullscreenButton: true),
        );
      }
    } else {
      _fileController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          setState(() {});
          _fileController?.play();
        });
    }
  }

  void _generateInviteLink() {
    final randomId = Random().nextInt(999999).toString().padLeft(6, '0');
    setState(() {
      _inviteLink = "https://watch.omnicom.online/?room=$randomId";
    });
  }

  void _disposePlayers() {
    _fileController?.dispose();
    _ytController?.close();
    _fileController = null;
    _ytController = null;
  }

  @override
  void dispose() {
    _disposePlayers();
    _urlController.dispose();
    super.dispose();
  }

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
            // URL Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: "Enter YouTube or Video File URL",
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(color: textColor),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text("Play"),
                  onPressed: _loadVideo,
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

            // Player Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isDark ? Colors.black26 : Colors.grey.shade300,
                ),
                child: Center(child: _buildPlayer(textColor)),
              ),
            ),
            const SizedBox(height: 20),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: () {
                    if (_isYouTube) {
                      _ytController?.pauseVideo();
                    } else {
                      _fileController?.pause();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    if (_isYouTube) {
                      _ytController?.playVideo();
                    } else {
                      _fileController?.play();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () {
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

  Widget _buildPlayer(Color textColor) {
    if (_videoUrl == null) {
      return Text(
        "Paste a URL and press Play",
        style: TextStyle(color: textColor, fontSize: 16),
      );
    }

    if (_isYouTube && _ytController != null) {
      return YoutubePlayer(controller: _ytController!, aspectRatio: 16 / 9);
    }

    if (_fileController != null && _fileController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _fileController!.value.aspectRatio,
        child: VideoPlayer(_fileController!),
      );
    }

    return const CircularProgressIndicator();
  }
}
