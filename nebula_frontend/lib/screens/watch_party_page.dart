import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_colors.dart';

class WatchPartyPage extends StatefulWidget {
  const WatchPartyPage({super.key});

  @override
  State<WatchPartyPage> createState() => _WatchPartyPageState();
}

class _WatchPartyPageState extends State<WatchPartyPage> {
  final TextEditingController _urlController = TextEditingController();

  String? _currentUrl;
  String? _inviteLink;

  // File / network player
  VideoPlayerController? _fileController;

  // YouTube
  WebViewController? _ytWebView;
  bool _isYouTube = false;

  bool _loading = false;
  String? _error;

  // ---------- Helpers ----------
  void _disposePlayers() {
    debugPrint('♻ Disposing players...');
    try {
      _fileController?.removeListener(_onVideoTick);
      _fileController?.dispose();
    } catch (_) {}
    _fileController = null;
    _ytWebView = null;
  }

  void _onVideoTick() {
    final v = _fileController?.value;
    if (v == null) return;
    if (v.hasError) {
      setState(() => _error = v.errorDescription ?? 'Unknown player error');
      debugPrint('❌ PLAYER ERROR: ${v.errorDescription}');
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
          final i = uri.pathSegments.indexOf('embed');
          if (i >= 0 && i + 1 < uri.pathSegments.length) {
            return uri.pathSegments[i + 1];
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ---------- Loader ----------
  Future<void> _loadVideo() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    _disposePlayers();
    setState(() {
      _loading = true;
      _error = null;
      _currentUrl = url;
      _inviteLink = null;
      _isYouTube = url.contains('youtube.com') || url.contains('youtu.be');
    });

    try {
      if (_isYouTube) {
        final id = _extractYouTubeId(url);
        if (id == null) {
          throw 'Invalid YouTube URL';
        }
        final embedUrl = 'https://www.youtube.com/embed/$id?autoplay=1&rel=0';
        final html =
            '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <style>
      html, body { margin:0; padding:0; background:#000; height:100%; }
      iframe { position:fixed; top:0; left:0; width:100%; height:100%; border:0; }
    </style>
  </head>
  <body>
    <iframe
      src="$embedUrl"
      title="YouTube"
      frameborder="0"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
      allowfullscreen>
    </iframe>
  </body>
</html>
''';
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadHtmlString(html);
        setState(() {
          _ytWebView = controller;
        });
        debugPrint('✅ YouTube WebView loaded.');
      } else {
        debugPrint('🎞 Loading file/stream: $url');
        final ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
        ctrl.addListener(_onVideoTick);

        await ctrl.initialize();
        await ctrl.play();

        setState(() {
          _fileController = ctrl;
        });
        debugPrint('✅ File initialized (${ctrl.value.duration}). ▶ Playing.');
      }
    } catch (e, st) {
      debugPrint('💥 Load error: $e\n$st');
      setState(() => _error = 'Failed to load: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _generateInviteLink() async {
    final randomId = Random().nextInt(999999).toString().padLeft(6, '0');
    final link = "https://watch.omnicom.online/?room=$randomId";
    setState(() => _inviteLink = link);
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔗 Invite link copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    debugPrint('🔗 Invite Link: $link (copied)');
  }

  @override
  void dispose() {
    _disposePlayers();
    _urlController.dispose();
    super.dispose();
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.accentDark; // AOL yellow for action buttons
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
            // —— URL input + play
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: 'Enter YouTube or Video File URL',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                    ),
                    style: TextStyle(color: textColor),
                    onSubmitted: (_) => _loadVideo(),
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
              ],
            ),
            const SizedBox(height: 20),

            // —— Player area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isDark ? Colors.black26 : Colors.grey.shade300,
                ),
                clipBehavior: Clip.antiAlias,
                child: Center(
                  child: _loading
                      ? const CircularProgressIndicator()
                      : (_error != null)
                      ? Text(
                          _error!,
                          style: const TextStyle(color: Colors.redAccent),
                        )
                      : _buildPlayer(textColor),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // —— Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Pause',
                  icon: const Icon(Icons.pause),
                  color: accent,
                  onPressed: () {
                    if (_isYouTube) {
                      // Basic webview embed: no direct programmatic pause.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Use YouTube controls in the player.'),
                        ),
                      );
                    } else {
                      _fileController?.pause();
                    }
                  },
                ),
                IconButton(
                  tooltip: 'Play',
                  icon: const Icon(Icons.play_arrow),
                  color: accent,
                  onPressed: () {
                    if (_isYouTube) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Use YouTube controls in the player.'),
                        ),
                      );
                    } else {
                      _fileController?.play();
                    }
                  },
                ),
                IconButton(
                  tooltip: 'Stop',
                  icon: const Icon(Icons.stop),
                  color: accent,
                  onPressed: () async {
                    if (_isYouTube) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Use YouTube controls in the player.'),
                        ),
                      );
                    } else {
                      await _fileController?.pause();
                      await _fileController?.seekTo(Duration.zero);
                    }
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
                  color: isDark
                      ? AppColors.primaryDark
                      : AppColors.primaryLight,
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
    if (_currentUrl == null) {
      return Text(
        'Paste a URL and press Play',
        style: TextStyle(color: textColor),
      );
    }

    if (_isYouTube && _ytWebView != null) {
      return WebViewWidget(controller: _ytWebView!);
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
