import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config.dart';

class WatchPartySocket {
  io.Socket? _socket;

  Future<void> connect() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return;

    _socket ??= io.io(
      AppConfig.backendWsBase,
      {
        'transports': ['websocket'],
        'autoConnect': true,
        'auth': {'token': token},
      },
    );
  }

  bool get connected => _socket?.connected == true;

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  Future<void> joinRoom(String roomId) async {
    await connect();
    _socket?.emit('wp:join', {'roomId': roomId});
  }

  Future<void> emitUrl(String roomId, String url) async {
    await connect();
    _socket?.emit('wp:url', {'roomId': roomId, 'url': url});
  }

  Future<void> emitPlay(String roomId) async {
    await connect();
    _socket?.emit('wp:play', {'roomId': roomId});
  }

  Future<void> emitPause(String roomId) async {
    await connect();
    _socket?.emit('wp:pause', {'roomId': roomId});
  }

  Future<void> emitSeek(String roomId, double seconds) async {
    await connect();
    _socket?.emit('wp:seek', {'roomId': roomId, 'position': seconds});
  }

  Future<void> emitState(String roomId, Map<String, dynamic> state) async {
    await connect();
    _socket?.emit('wp:state', {'roomId': roomId, 'state': state});
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}

final watchPartySocket = WatchPartySocket();
