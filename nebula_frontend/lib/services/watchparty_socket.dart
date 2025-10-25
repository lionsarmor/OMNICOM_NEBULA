import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config.dart';

class WatchPartySocket {
  io.Socket? _socket;

  void connect() {
    _socket ??= io.io(
      kBackendWsBase,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );
  }

  bool get connected => _socket?.connected == true;

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void joinRoom(String roomId) {
    connect();
    _socket?.emit('wp:join', {'roomId': roomId});
  }

  void emitUrl(String roomId, String url) {
    _socket?.emit('wp:url', {'roomId': roomId, 'url': url});
  }

  void emitPlay(String roomId) {
    _socket?.emit('wp:play', {'roomId': roomId});
  }

  void emitPause(String roomId) {
    _socket?.emit('wp:pause', {'roomId': roomId});
  }

  void emitSeek(String roomId, double seconds) {
    _socket?.emit('wp:seek', {'roomId': roomId, 'position': seconds});
  }

  void emitState(String roomId, Map<String, dynamic> state) {
    _socket?.emit('wp:state', {'roomId': roomId, 'state': state});
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}

final watchPartySocket = WatchPartySocket();
