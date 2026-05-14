export function attachWS(io) {
  const roomState = new Map(); // roomId -> { url, playing, position, updatedAt }

  function normalizeState(data = {}) {
    return {
      url: typeof data.url === "string" ? data.url : undefined,
      playing: Boolean(data.playing),
      position: Number.isFinite(Number(data.position)) ? Number(data.position) : 0,
      updatedAt: Date.now(),
    };
  }

  function emitRoomState(roomId) {
    const state = roomState.get(roomId);
    if (state) io.to(`wp_${roomId}`).emit("wp:sync", state);
  }

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
      const state = roomState.get(roomId);
      if (state) socket.emit("wp:sync", state);
    });

    socket.on("wp:url", ({ roomId, url }) => {
      if (!roomId || !url) return;
      const state = normalizeState({ url, playing: true, position: 0 });
      roomState.set(roomId, state);
      io.to(`wp_${roomId}`).emit("wp:url", state);
    });

    socket.on("wp:play", ({ roomId }) => {
      if (!roomId) return;
      const state = { ...(roomState.get(roomId) || {}), playing: true, updatedAt: Date.now() };
      roomState.set(roomId, state);
      io.to(`wp_${roomId}`).emit("wp:play", state);
    });

    socket.on("wp:pause", ({ roomId }) => {
      if (!roomId) return;
      const state = { ...(roomState.get(roomId) || {}), playing: false, updatedAt: Date.now() };
      roomState.set(roomId, state);
      io.to(`wp_${roomId}`).emit("wp:pause", state);
    });

    socket.on("wp:seek", ({ roomId, position }) => {
      if (!roomId) return;
      const state = {
        ...(roomState.get(roomId) || {}),
        position: Number.isFinite(Number(position)) ? Number(position) : 0,
        updatedAt: Date.now(),
      };
      roomState.set(roomId, state);
      io.to(`wp_${roomId}`).emit("wp:seek", state);
    });

    socket.on("wp:state", ({ roomId, state }) => {
      if (!roomId || !state) return;
      roomState.set(roomId, normalizeState(state));
      emitRoomState(roomId);
    });

    socket.on("disconnect", () => {
      console.log("❌ Client disconnected:", socket.id);
    });
  });
}
