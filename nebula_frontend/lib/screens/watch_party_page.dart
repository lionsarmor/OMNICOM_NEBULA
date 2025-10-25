import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_colors.dart';
import '../services/watchparty_socket.dart';

class WatchPartyPage extends StatefulWidget {
  const WatchPartyPage({super.key});

  @override
  State<WatchPartyPage> createState() => _WatchPartyPageState();
}

class _WatchPartyPageState extends State<WatchPartyPage> {
  final TextEditingController _urlController = TextEditingController();
  final _socket = WatchPartySocket();

  String? _currentUrl;
  String? _roomLink;
  String? _roomId;

  VideoPlayerController? _fileController;
  WebViewController? _ytWebView;
  bool _isYouTube = false;
  bool _loading = false;
  String? _error;

  // ---------- Helpers ----------
  void _disposePlayers() {
    try {
      _fileController?.removeListener(_onVideoTick);
      _fileController?.dispose();
    } catch (_) {}
    _fileController = null;
    _ytWebView = null;
  }

  void _onVideoTick() {
    final v = _fileController?.value;
    if (v != null && v.hasError) {
      setState(() => _error = v.errorDescription ?? 'Unknown player error');
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

  // ---------- Video Loader ----------
  Future<void> _loadVideo() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    _disposePlayers();
    setState(() {
      _loading = true;
      _error = null;
      _currentUrl = url;
      _isYouTube = url.contains('youtube.com') || url.contains('youtu.be');
    });

    try {
      if (_isYouTube) {
        final id = _extractYouTubeId(url);
        if (id == null) throw 'Invalid YouTube URL';
        final embedUrl = 'https://www.youtube.com/embed/$id?autoplay=1&rel=0';
        final html =
            '''
<!DOCTYPE html>
<html>
<head><meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<style>html,body{margin:0;padding:0;background:#000;height:100%;}
iframe{position:fixed;top:0;left:0;width:100%;height:100%;border:0;}
</style></head>
<body><iframe src="$embedUrl" allowfullscreen></iframe></body></html>
''';
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadHtmlString(html);
        setState(() => _ytWebView = controller);
      } else {
        final ctrl = url.startsWith('http')
            ? VideoPlayerController.networkUrl(Uri.parse(url))
            : VideoPlayerController.file(File(url));
        ctrl.addListener(_onVideoTick);
        await ctrl.initialize();
        await ctrl.play();
        setState(() => _fileController = ctrl);
      }
    } catch (e) {
      setState(() => _error = 'Failed to load: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // ---------- Local File Picker ----------
  Future<void> _pickLocalFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.video);
      if (result == null || result.files.single.path == null) return;
      final path = result.files.single.path!;
      _disposePlayers();
      setState(() {
        _loading = true;
        _error = null;
        _currentUrl = path;
        _isYouTube = false;
      });
      final ctrl = VideoPlayerController.file(File(path));
      ctrl.addListener(_onVideoTick);
      await ctrl.initialize();
      await ctrl.play();
      setState(() {
        _fileController = ctrl;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load file: $e';
        _loading = false;
      });
    }
  }

  // ---------- Watch Party ----------
  void _createNewParty() {
    final randomId = Random().nextInt(999999).toString().padLeft(6, '0');
    final link = "https://watch.omnicom.online/?room=$randomId";
    setState(() {
      _roomId = randomId;
      _roomLink = link;
    });

    _socket.connect(randomId, host: "http://localhost:4000");
    _socket.onSync = (type, payload) {
      if (type == "PLAY") _fileController?.play();
      if (type == "PAUSE") _fileController?.pause();
      if (type == "SEEK") {
        final ms = payload is int
            ? payload
            : int.tryParse(payload.toString()) ?? 0;
        _fileController?.seekTo(Duration(milliseconds: ms));
      }
    };
  }

  Future<void> _copyInviteLink() async {
    if (_roomLink == null) return;
    await Clipboard.setData(ClipboardData(text: _roomLink!));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied: $_roomLink')));
  }

  @override
  void dispose() {
    _disposePlayers();
    _socket.disconnect();
    _urlController.dispose();
    super.dispose();
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.accentDark;
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: 'Enter YouTube or Video URL',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                    ),
                    style: TextStyle(color: textColor),
                    onSubmitted: (_) => _loadVideo(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  color: accent,
                  iconSize: 34,
                  tooltip: 'Pick Local File',
                  onPressed: _loading ? null : _pickLocalFile,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.fiber_new),
                  label: const Text('New Party'),
                  onPressed: _createNewParty,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Invite'),
                  onPressed: _roomLink != null ? _copyInviteLink : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _roomLink != null
                        ? accent
                        : Colors.grey.shade500,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (_roomLink != null) ...[
              const SizedBox(height: 8),
              SelectableText(
                _roomLink!,
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
        'Paste a URL or pick a file to start',
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
