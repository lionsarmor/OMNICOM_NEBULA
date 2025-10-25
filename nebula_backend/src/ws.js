// === 💬 Existing Chat Channels ===
export function attachWS(io) {
  io.on("connection", (socket) => {
    console.log("💬 Client connected (chat)");

    socket.on("join_channel", (ch) => socket.join(`ch_${ch}`));

    socket.on("send_message", (data) => {
      io.to(`ch_${data.channelId}`).emit("receive_message", {
        user: data.user,
        channelId: data.channelId,
        message: data.message,
        created_at: new Date().toISOString(),
      });
    });
  });
}

// === 🎬 New Watch Party Namespace ===
export function attachWatchParty(io) {
  const wp = io.of("/watchparty");

  wp.on("connection", (socket) => {
    console.log("🎥 WatchParty client connected:", socket.id);

    // Join a room
    socket.on("join_room", (roomId) => {
      socket.join(roomId);
      console.log(`👥 ${socket.id} joined room ${roomId}`);
      socket.emit("joined_room", roomId);
    });

    // Receive and rebroadcast play/pause/seek actions
    socket.on("sync_action", ({ roomId, type, payload }) => {
      console.log(`➡️ ${type} in room ${roomId}`);
      socket.to(roomId).emit("sync_action", { type, payload });
    });

    socket.on("disconnect", () => {
      console.log(`❌ WatchParty client disconnected: ${socket.id}`);
    });
  });
}
