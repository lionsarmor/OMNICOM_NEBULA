import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ added
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../widgets/universal_player.dart';

class WatchPartyPage extends StatefulWidget {
  const WatchPartyPage({super.key});
  @override
  State<WatchPartyPage> createState() => _WatchPartyPageState();
}

class _WatchPartyPageState extends State<WatchPartyPage> {
  final TextEditingController _urlCtrl = TextEditingController();
  String? _currentSource;
  bool _isYouTube = false;

  io.Socket? _socket;
  bool _connected = false;
  String? _roomId;
  String? _inviteUrl;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  void _connectSocket() {
    final socket = io.io(
      'http://localhost:4000',
      io.OptionBuilder().setTransports(['websocket']).build(),
    );
    socket.onConnect((_) => setState(() => _connected = true));
    socket.onDisconnect((_) => setState(() => _connected = false));
    setState(() => _socket = socket);
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.video);
    final path = res?.files.single.path;
    if (path == null) return;
    _urlCtrl.text = path;
    _playSource(path);
  }

  Future<void> _playSource(String src, {bool remote = false}) async {
    setState(() {
      _loading = true;
      _error = null;
      _isYouTube = src.contains('youtu');
    });
    try {
      if (_isYouTube) {
        final id = _extractYT(src);
        final embed = 'https://www.youtube.com/embed/$id?autoplay=1';
        if (!kIsWeb && Platform.isLinux) {
          await launchUrl(Uri.parse(src), mode: LaunchMode.externalApplication);
          setState(() => _currentSource = null);
        } else {
          setState(() => _currentSource = embed);
        }
      } else {
        setState(() => _currentSource = src);
      }
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  String? _extractYT(String url) {
    try {
      final u = Uri.parse(url);
      if (u.host.contains('youtu.be')) return u.pathSegments.first;
      if (u.queryParameters['v'] != null) return u.queryParameters['v'];
    } catch (_) {}
    return null;
  }

  void _newRoom() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _roomId = id;
      _inviteUrl = 'https://nebula.app/join/$id';
    });
  }

  void _copyInvite() {
    if (_inviteUrl == null) return;
    Clipboard.setData(ClipboardData(text: _inviteUrl!)); // ✅ works now
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Invite link copied.')));
  }

  @override
  Widget build(BuildContext context) {
    const neon = Color(0xFFFFD600);
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎬 Watch Party'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: neon),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              _connected ? Icons.cloud_done : Icons.cloud_off,
              color: _connected ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _controls(neon),
          if (_roomId != null) _roomBanner(neon),
          Expanded(child: _playerArea(neon)),
        ],
      ),
    );
  }

  Widget _controls(Color neon) => Padding(
    padding: const EdgeInsets.all(12),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        SizedBox(
          width: 400,
          child: TextField(
            controller: _urlCtrl,
            decoration: const InputDecoration(
              labelText: 'Paste video URL or path',
            ),
            onSubmitted: _playSource,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _playSource(_urlCtrl.text.trim()),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Play'),
        ),
        ElevatedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.folder),
          label: const Text('Pick File'),
        ),
        ElevatedButton.icon(
          onPressed: _newRoom,
          icon: const Icon(Icons.fiber_new),
          label: const Text('New Room'),
        ),
        ElevatedButton.icon(
          onPressed: _copyInvite,
          icon: const Icon(Icons.copy),
          label: const Text('Invite'),
        ),
      ],
    ),
  );

  Widget _roomBanner(Color neon) => Container(
    margin: const EdgeInsets.all(8),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: const Color(0xFF0B0B1A),
      border: Border.all(color: neon),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(Icons.groups, color: neon),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Room $_roomId  |  $_inviteUrl',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    ),
  );

  Widget _playerArea(Color neon) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (_currentSource == null && _isYouTube && Platform.isLinux) {
      return const Center(
        child: Text('YouTube opened in browser (Linux fallback).'),
      );
    }
    if (_isYouTube &&
        _currentSource != null &&
        _currentSource!.contains('youtube.com/embed')) {
      return InAppWebView(
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          allowsInlineMediaPlayback: true,
          mediaPlaybackRequiresUserGesture: false,
        ),
        initialUrlRequest: URLRequest(url: WebUri(_currentSource!)),
      );
    }
    if (_currentSource != null) {
      return UniversalPlayer(source: _currentSource!);
    }
    return const Center(child: Text('Pick a file or paste a link to begin.'));
  }
}
