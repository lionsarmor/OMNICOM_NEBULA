export function attachWS(io) {
  io.on("connection", socket => {
    console.log("Client connected");
    socket.on("join_channel", ch => socket.join(`ch_${ch}`));
    socket.on("send_message", data => {
      io.to(`ch_${data.channelId}`).emit("receive_message", {
        user: data.user,
        channelId: data.channelId,
        message: data.message,
        created_at: new Date().toISOString()
      });
    });
  });
}
