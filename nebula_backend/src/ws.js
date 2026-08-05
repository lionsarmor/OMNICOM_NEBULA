import jwt from "jsonwebtoken";

export function attachWS(io, { jwtSecret }) {
  const roomState = new Map(); // roomId -> { url, playing, position, updatedAt }

  io.use((socket, next) => {
    const authToken = socket.handshake.auth?.token;
    const header = socket.handshake.headers?.authorization || "";
    const bearerToken = header.startsWith("Bearer ") ? header.slice(7) : null;
    const token = authToken || bearerToken;

    if (!token) return next(new Error("unauthorized"));

    try {
      socket.data.user = jwt.verify(token, jwtSecret);
      return next();
    } catch {
      return next(new Error("unauthorized"));
    }
  });

  function normalizeState(data = {}) {
    return {
      url: typeof data.url === "string" ? data.url : undefined,
      playing: Boolean(data.playing),
      position: Number.isFinite(Number(data.position)) ? Number(data.position) : 0,
      updatedAt: Date.now(),
    };
  }

  function safeId(value) {
    return String(value || "")
      .trim()
      .replace(/[^\w.-]/g, "")
      .slice(0, 80);
  }

  function safeMessage(value) {
    return String(value || "").trim().slice(0, 2000);
  }

  function emitRoomState(roomId) {
    const state = roomState.get(roomId);
    if (state) io.to(`wp_${roomId}`).emit("wp:sync", state);
  }

  io.on("connection", (socket) => {
    console.log("Socket connected:", socket.id);

    socket.on("join_channel", (ch) => {
      const channelId = safeId(ch);
      if (channelId) socket.join(`ch_${channelId}`);
    });

    socket.on("send_message", (data) => {
      const channelId = safeId(data?.channelId);
      const message = safeMessage(data?.message);
      if (!channelId || !message) return;

      io.to(`ch_${channelId}`).emit("receive_message", {
        user: socket.data.user?.username,
        userId: socket.data.user?.id,
        channelId,
        message,
        created_at: new Date().toISOString(),
      });
    });

    socket.on("wp:join", ({ roomId }) => {
      roomId = safeId(roomId);
      if (!roomId) return;
      socket.join(`wp_${roomId}`);
      const state = roomState.get(roomId);
      if (state) socket.emit("wp:sync", state);
    });

    socket.on("wp:url", ({ roomId, url }) => {
      roomId = safeId(roomId);
      if (!roomId || !url) return;
      const state = normalizeState({ url, playing: true, position: 0 });
      roomState.set(roomId, state);
      io.to(`wp_${roomId}`).emit("wp:url", state);
    });

    socket.on("wp:play", ({ roomId }) => {
      roomId = safeId(roomId);
      if (!roomId) return;
      const state = { ...(roomState.get(roomId) || {}), playing: true, updatedAt: Date.now() };
      roomState.set(roomId, state);
      io.to(`wp_${roomId}`).emit("wp:play", state);
    });

    socket.on("wp:pause", ({ roomId }) => {
      roomId = safeId(roomId);
      if (!roomId) return;
      const state = { ...(roomState.get(roomId) || {}), playing: false, updatedAt: Date.now() };
      roomState.set(roomId, state);
      io.to(`wp_${roomId}`).emit("wp:pause", state);
    });

    socket.on("wp:seek", ({ roomId, position }) => {
      roomId = safeId(roomId);
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
      roomId = safeId(roomId);
      if (!roomId || !state) return;
      roomState.set(roomId, normalizeState(state));
      emitRoomState(roomId);
    });

    socket.on("disconnect", () => {
      console.log("Socket disconnected:", socket.id);
    });
  });
}
