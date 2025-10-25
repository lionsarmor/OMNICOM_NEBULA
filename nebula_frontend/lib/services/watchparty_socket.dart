import 'package:socket_io_client/socket_io_client.dart' as IO;

class WatchPartySocket {
  IO.Socket? socket;
  Function(String type, dynamic payload)? onSync;

  void connect(String roomId, {String host = "http://localhost:4000"}) {
    socket = IO.io(
      "$host/watchparty",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.onConnect((_) {
      print("🔌 Connected to WatchParty");
      socket!.emit("join_room", roomId);
    });

    socket!.on("sync_action", (data) {
      if (onSync != null) onSync!(data["type"], data["payload"]);
    });

    socket!.onDisconnect((_) => print("🛑 Disconnected from WatchParty"));
    socket!.connect();
  }

  void send(String roomId, String type, [dynamic payload]) {
    socket?.emit("sync_action", {
      "roomId": roomId,
      "type": type,
      "payload": payload,
    });
  }

  void disconnect() {
    socket?.disconnect();
    socket = null;
  }
}
