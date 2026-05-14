import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class UniversalPlayer extends StatefulWidget {
  final String source;
  final bool playing;
  final Duration? seekTo;
  final void Function(Duration position, Duration? total)? onProgress;

  const UniversalPlayer({
    super.key,
    required this.source,
    this.playing = true,
    this.seekTo,
    this.onProgress,
  });

  @override
  State<UniversalPlayer> createState() => _UniversalPlayerState();
}

class _UniversalPlayerState extends State<UniversalPlayer> {
  late final Player _player;
  late final VideoController _controller;
  StreamSubscription<Duration>? _positionSub;
  Duration? _lastSeek;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _open(widget.source);
    _positionSub = _player.stream.position.listen(
      (pos) => widget.onProgress?.call(pos, _player.state.duration),
    );
  }

  Future<void> _open(String src) async {
    final isLocal = !src.startsWith('http');
    final media = isLocal ? Media(Uri.file(src).toString()) : Media(src);
    await _player.open(media, play: widget.playing);
  }

  @override
  void didUpdateWidget(UniversalPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) _open(widget.source);
    if (oldWidget.playing != widget.playing) {
      widget.playing ? _player.play() : _player.pause();
    }
    final seekTo = widget.seekTo;
    if (seekTo != null && seekTo != _lastSeek) {
      _lastSeek = seekTo;
      _player.seek(seekTo);
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _player.dispose(); // ✅ only player needs disposing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Video(controller: _controller),
    );
  }
}
