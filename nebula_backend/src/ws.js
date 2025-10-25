export function attachWS(io) {
  const roomState = {}; // { roomId: { url, playing, position } }

  io.on("connection", (socket) => {
    console.log("🔌 Client connected:", socket.id);

    // ===== Chat System =====
    socket.on("join_channel", (ch) => socket.join(`ch_${ch}`));

    socket.on("send_message", (data) => {
      io.to(`ch_${data.channelId}`).emit("receive_message", {
        user: data.user,
        channelId: data.channelId,
        message: data.message,
        created_at: new Date().toISOString(),
      });
    });

    // ===== Watch Party =====
    socket.on("wp:join", ({ roomId }) => {
      if (!roomId) return;
      socket.join(`wp_${roomId}`);
      const state = roomState[roomId];
      if (state) socket.emit("wp:sync", state);
    });

    socket.on("wp:url", ({ roomId, url }) => {
      if (!roomId || !url) return;
      roomState[roomId] = { url, playing: true, position: 0 };
      socket.to(`wp_${roomId}`).emit("wp:url", { url });
    });

    socket.on("wp:play", ({ roomId }) => {
      if (!roomId) return;
      roomState[roomId] = { ...(roomState[roomId] || {}), playing: true };
      socket.to(`wp_${roomId}`).emit("wp:play");
    });

    socket.on("wp:pause", ({ roomId }) => {
      if (!roomId) return;
      roomState[roomId] = { ...(roomState[roomId] || {}), playing: false };
      socket.to(`wp_${roomId}`).emit("wp:pause");
    });

    socket.on("wp:seek", ({ roomId, position }) => {
      if (!roomId) return;
      roomState[roomId] = { ...(roomState[roomId] || {}), position };
      socket.to(`wp_${roomId}`).emit("wp:seek", { position });
    });

    socket.on("disconnect", () => {
      console.log("❌ Client disconnected:", socket.id);
    });
  });
}
