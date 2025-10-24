import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../theme/app_colors.dart';

class WatchPartyPage extends StatefulWidget {
  const WatchPartyPage({super.key});

  @override
  State<WatchPartyPage> createState() => _WatchPartyPageState();
}

class _WatchPartyPageState extends State<WatchPartyPage> {
  final TextEditingController _urlController = TextEditingController();
  final YoutubeExplode _yt = YoutubeExplode();

  String? _videoUrl;
  String? _inviteLink;

  VideoPlayerController? _controller;
  bool _loading = false;
  String? _error;

  // ------------- Helpers -------------
  void _disposePlayer() {
    debugPrint('♻ Disposing player...');
    _controller?.removeListener(_onVideoTick);
    _controller?.dispose();
    _controller = null;
  }

  void _onVideoTick() {
    final v = _controller?.value;
    if (v == null) return;
    if (v.hasError) {
      debugPrint('❌ PLAYER ERROR: ${v.errorDescription}');
      setState(() => _error = v.errorDescription ?? 'Unknown player error');
    }
  }

  // ------------- Loader -------------
  Future<void> _loadVideo() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    _disposePlayer();
    setState(() {
      _videoUrl = url;
      _inviteLink = null;
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse(url);
      final isYouTube =
          uri.host.contains('youtube.com') || uri.host.contains('youtu.be');

      if (isYouTube) {
        debugPrint('🎬 Fetching YouTube stream for: $url');

        // Extract video id (supports youtu.be and youtube.com/watch?v=...)
        final videoId = _extractYouTubeId(url);
        if (videoId == null) throw 'Invalid YouTube URL';

        // Get manifest and choose highest bitrate muxed stream
        final manifest = await _yt.videos.streamsClient.getManifest(videoId);
        final muxed = manifest.muxed.withHighestBitrate();
        if (muxed == null) throw 'No playable muxed stream found';

        final direct = muxed.url.toString();
        debugPrint('✅ YouTube direct URL resolved: $direct');

        _controller = VideoPlayerController.networkUrl(Uri.parse(direct));
      } else {
        debugPrint('🎞 Loading network/local stream: $url');
        _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      }

      _controller!.addListener(_onVideoTick);

      await _controller!.initialize();
      debugPrint(
        '✅ Video initialized, duration: ${_controller!.value.duration}',
      );
      await _controller!.play();
      debugPrint('▶ Playback started.');
    } catch (e, st) {
      debugPrint('💥 Load error: $e\n$st');
      setState(() => _error = 'Failed to load: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  String? _extractYouTubeId(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      }
      if (uri.host.contains('youtube.com')) {
        final v = uri.queryParameters['v'];
        if (v != null && v.isNotEmpty) return v;
        // /embed/VIDEOID
        if (uri.pathSegments.contains('embed')) {
          final idx = uri.pathSegments.indexOf('embed');
          if (idx >= 0 && idx + 1 < uri.pathSegments.length) {
            return uri.pathSegments[idx + 1];
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void _generateInviteLink() {
    final randomId = Random().nextInt(999999).toString().padLeft(6, '0');
    setState(() {
      _inviteLink = "https://watch.omnicom.online/?room=$randomId";
    });
    debugPrint('🔗 Invite Link: $_inviteLink');
  }

  @override
  void dispose() {
    _disposePlayer();
    _yt.close();
    _urlController.dispose();
    super.dispose();
  }

  // ------------- UI -------------
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent =
        AppColors.accentDark; // AOL yellow (your “basic button” color)
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎬 Watch Party'),
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
            // ---- URL input + play
            Row(
              children: {
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: 'Enter YouTube or Video File URL',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                    ),
                    style: TextStyle(color: textColor),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Play'),
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
              }.toList(),
            ),
            const SizedBox(height: 20),

            // ---- Player area
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

            // ---- Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.pause),
                  color: accent,
                  onPressed: () => _controller?.pause(),
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  color: accent,
                  onPressed: () => _controller?.play(),
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  color: accent,
                  onPressed: () async {
                    await _controller?.pause();
                    await _controller?.seekTo(Duration.zero);
                  },
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _generateInviteLink,
                  icon: const Icon(Icons.share),
                  label: const Text('Invite'),
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
                'Invite Link: $_inviteLink',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
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
        'Paste a URL and press Play',
        style: TextStyle(color: textColor),
      );
    }
    if (_controller != null && _controller!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      );
    }
    return const CircularProgressIndicator();
  }
}
