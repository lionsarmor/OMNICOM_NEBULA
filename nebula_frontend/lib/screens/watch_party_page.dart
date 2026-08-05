import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../widgets/universal_player.dart';

class WatchPartyPage extends StatefulWidget {
  const WatchPartyPage({super.key});

  @override
  State<WatchPartyPage> createState() => _WatchPartyPageState();
}

class _WatchPartyPageState extends State<WatchPartyPage> {
  final TextEditingController _urlCtrl = TextEditingController();
  final TextEditingController _roomCtrl = TextEditingController();

  io.Socket? _socket;
  bool _connected = false;
  bool _loading = false;
  bool _playing = false;
  bool _isYouTube = false;

  String _roomId = 'nebula-lobby';
  String? _inviteUrl;
  String? _sourceUrl;
  String? _currentSource;
  String? _error;
  String? _status;

  Duration _position = Duration.zero;
  Duration? _seekTarget;

  @override
  void initState() {
    super.initState();
    _roomId = _initialRoomId();
    _roomCtrl.text = _roomId;
    _inviteUrl = _inviteFor(_roomId);
    _connectSocket();
  }

  @override
  void dispose() {
    _socket?.dispose();
    _urlCtrl.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }

  String _initialRoomId() {
    final fromUrl = Uri.base.queryParameters['room']?.trim();
    if (fromUrl != null && fromUrl.isNotEmpty) return fromUrl;
    return 'nebula-lobby';
  }

  String _inviteFor(String roomId) {
    final base = Uri.base.origin;
    return '$base/watchparty?room=$roomId';
  }

  Future<void> _connectSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _connected = false;
        _status = 'Sign in before joining a watch room.';
      });
      return;
    }

    final socket = io.io(
      AppConfig.backendWsBase,
      {
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {'token': token},
      },
    );

    socket.onConnect((_) {
      if (!mounted) return;
      setState(() {
        _connected = true;
        _status = 'Connected to watch relay.';
      });
      _joinRoom(_roomId, announce: false);
    });

    socket.onDisconnect((_) {
      if (!mounted) return;
      setState(() {
        _connected = false;
        _status = 'Disconnected from watch relay.';
      });
    });

    socket.on('connect_error', (data) {
      if (!mounted) return;
      setState(() {
        _connected = false;
        _status = 'Watch relay rejected the session. Sign in again.';
      });
    });

    socket.on('wp:sync', (data) => _applyRemoteState(_asMap(data)));
    socket.on('wp:url', (data) => _applyRemoteState(_asMap(data)));
    socket.on('wp:play', (data) => _applyPlayback(true, _asMap(data)));
    socket.on('wp:pause', (data) => _applyPlayback(false, _asMap(data)));
    socket.on(
      'wp:seek',
      (data) => _applySeek(_seconds(_asMap(data)['position'])),
    );

    socket.connect();
    _socket = socket;
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) {
      return data.map((key, value) => MapEntry('$key', value));
    }
    return const {};
  }

  double _seconds(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  void _joinRoom(String roomId, {bool announce = true}) {
    final cleanRoomId = roomId.trim();
    if (cleanRoomId.isEmpty) return;

    setState(() {
      _roomId = cleanRoomId;
      _roomCtrl.text = cleanRoomId;
      _inviteUrl = _inviteFor(cleanRoomId);
      if (announce) _status = 'Joined room $cleanRoomId.';
    });

    _socket?.emit('wp:join', {'roomId': cleanRoomId});
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.video);
    final path = res?.files.single.path;
    if (path == null) return;
    _urlCtrl.text = path;
    await _loadSource(path, remote: false);
  }

  Future<void> _loadSource(String src, {required bool remote}) async {
    final cleanSrc = src.trim();
    if (cleanSrc.isEmpty) {
      setState(() => _error = 'Paste a video URL or choose a local file.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _status = remote ? 'Remote source received.' : 'Loading source.';
      _isYouTube = _isYouTubeUrl(cleanSrc);
    });

    try {
      String playableSource = cleanSrc;

      if (_isYouTube) {
        final id = _extractYouTubeId(cleanSrc);
        if (id == null) {
          throw const FormatException('Could not read the YouTube video ID.');
        }
        playableSource =
            'https://www.youtube.com/embed/$id?autoplay=1&enablejsapi=1';
        if (_isLinuxDesktop) {
          await launchUrl(
            Uri.parse(cleanSrc),
            mode: LaunchMode.externalApplication,
          );
        }
      }

      setState(() {
        _sourceUrl = cleanSrc;
        _currentSource = _isLinuxDesktop && _isYouTube ? null : playableSource;
        _playing = true;
        _position = Duration.zero;
        _seekTarget = Duration.zero;
        _urlCtrl.text = cleanSrc;
        _status = remote ? 'Synced source from room.' : 'Source loaded.';
      });

      if (!remote) {
        _socket?.emit('wp:url', {'roomId': _roomId, 'url': cleanSrc});
      }
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isYouTubeUrl(String url) =>
      url.contains('youtu.be') || url.contains('youtube.');

  String? _extractYouTubeId(String url) {
    try {
      final u = Uri.parse(url);
      if (u.host.contains('youtu.be') && u.pathSegments.isNotEmpty) {
        return u.pathSegments.first;
      }
      return u.queryParameters['v'];
    } catch (_) {
      return null;
    }
  }

  Future<void> _applyRemoteState(Map<String, dynamic> state) async {
    final url = state['url'];
    if (url is String && url.isNotEmpty && url != _sourceUrl) {
      await _loadSource(url, remote: true);
    }
    _applyPlayback(state['playing'] == true, state);
    final position = state.containsKey('position')
        ? _seconds(state['position'])
        : null;
    if (position != null) _applySeek(position);
  }

  void _applyPlayback(bool playing, Map<String, dynamic> state) {
    if (!mounted) return;
    setState(() {
      _playing = playing;
      _status = playing ? 'Room playback started.' : 'Room playback paused.';
    });
  }

  void _play() {
    if (_currentSource == null && _sourceUrl == null) {
      _loadSource(_urlCtrl.text, remote: false);
      return;
    }
    setState(() {
      _playing = true;
      _status = 'Playback started.';
    });
    _socket?.emit('wp:play', {'roomId': _roomId});
  }

  void _pause() {
    setState(() {
      _playing = false;
      _status = 'Playback paused.';
    });
    _socket?.emit('wp:pause', {'roomId': _roomId});
  }

  void _seekBy(int seconds) {
    final targetSeconds = (_position.inSeconds + seconds).clamp(0, 86400);
    _applySeek(targetSeconds.toDouble());
    _socket?.emit('wp:seek', {'roomId': _roomId, 'position': targetSeconds});
  }

  void _applySeek(double seconds) {
    final target = Duration(milliseconds: (seconds * 1000).round());
    if (!mounted) return;
    setState(() {
      _position = target;
      _seekTarget = target;
      _status = 'Seek synced to ${target.inSeconds}s.';
    });
  }

  void _newRoom() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _joinRoom(id);
  }

  void _copyInvite() {
    if (_inviteUrl == null) return;
    Clipboard.setData(ClipboardData(text: _inviteUrl!));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Invite link copied.')));
  }

  @override
  Widget build(BuildContext context) {
    const neon = Color(0xFFFFD600);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch Party'),
        leadingWidth: 118,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: neon,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            label: const Text(
              'BACK',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
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
          _roomControls(neon),
          _sourceControls(),
          if (_status != null || _error != null) _statusBar(neon),
          Expanded(child: _playerArea()),
        ],
      ),
    );
  }

  Widget _roomControls(Color neon) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 220,
          child: TextField(
            controller: _roomCtrl,
            decoration: const InputDecoration(labelText: 'Room'),
            onSubmitted: (value) => _joinRoom(value),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _joinRoom(_roomCtrl.text),
          icon: const Icon(Icons.login),
          label: const Text('Join'),
        ),
        ElevatedButton.icon(
          onPressed: _newRoom,
          icon: const Icon(Icons.add),
          label: const Text('New'),
        ),
        ElevatedButton.icon(
          onPressed: _copyInvite,
          icon: const Icon(Icons.copy),
          label: const Text('Invite'),
        ),
        Chip(
          avatar: Icon(Icons.groups, color: neon, size: 18),
          label: Text(_roomId),
        ),
      ],
    ),
  );

  Widget _sourceControls() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 420,
          child: TextField(
            controller: _urlCtrl,
            decoration: const InputDecoration(
              labelText: 'Video URL or local path',
            ),
            onSubmitted: (value) => _loadSource(value, remote: false),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _loadSource(_urlCtrl.text, remote: false),
          icon: const Icon(Icons.playlist_play),
          label: const Text('Load'),
        ),
        ElevatedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.folder),
          label: const Text('Pick File'),
        ),
        ElevatedButton.icon(
          onPressed: _currentSource == null && _sourceUrl == null
              ? null
              : _play,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Play'),
        ),
        ElevatedButton.icon(
          onPressed: _currentSource == null && _sourceUrl == null
              ? null
              : _pause,
          icon: const Icon(Icons.pause),
          label: const Text('Pause'),
        ),
        IconButton(
          tooltip: 'Back 10 seconds',
          onPressed: _currentSource == null && _sourceUrl == null
              ? null
              : () => _seekBy(-10),
          icon: const Icon(Icons.replay_10),
        ),
        IconButton(
          tooltip: 'Forward 10 seconds',
          onPressed: _currentSource == null && _sourceUrl == null
              ? null
              : () => _seekBy(10),
          icon: const Icon(Icons.forward_10),
        ),
      ],
    ),
  );

  Widget _statusBar(Color neon) => Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF0B0B1A),
      border: Border.all(color: _error == null ? neon : Colors.redAccent),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      _error ?? _status ?? '',
      style: TextStyle(
        color: _error == null ? Colors.white70 : Colors.redAccent,
      ),
    ),
  );

  Widget _playerArea() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_currentSource == null && _isYouTube && _isLinuxDesktop) {
      return const Center(child: Text('YouTube opened in browser on Linux.'));
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
      return UniversalPlayer(
        source: _currentSource!,
        playing: _playing,
        seekTo: _seekTarget,
        onProgress: (position, _) {
          _position = position;
        },
      );
    }
    return const Center(
      child: Text('Create or join a room, then load a video.'),
    );
  }

  bool get _isLinuxDesktop =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
}
