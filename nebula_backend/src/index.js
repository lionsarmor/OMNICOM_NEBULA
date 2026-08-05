import express from "express";
import cors from "cors";
import { createServer } from "http";
import { Server } from "socket.io";

import authRoutes from "./routes/auth.js";
import { verifyToken } from "./routes/auth.js";
import { listChannels, createChannel } from "./channels.js";
import { listMessages, createMessage } from "./messages.js";
import { config } from "./config.js";
import { attachWS } from "./ws.js";

const app = express();
const server = createServer(app);
const corsOptions = {
  origin: config.corsOrigins,
};

const io = new Server(server, {
  cors: {
    origin: config.corsOrigins,
    methods: ["GET", "POST"],
  },
});

app.use(express.json({ limit: "1mb" }));
app.use(cors(corsOptions));

app.get("/api/health", (req, res) =>
  res.json({
    ok: true,
    service: "nebula-backend",
    environment: config.nodeEnv,
    uptime: process.uptime(),
  })
);

app.use("/api", authRoutes);

app.get("/api/channels", verifyToken, listChannels);
app.post("/api/channels", verifyToken, createChannel);
app.get("/api/channels/:id/messages", verifyToken, listMessages);
app.post("/api/messages", verifyToken, createMessage);

attachWS(io, { jwtSecret: config.jwtSecret });

server.listen(config.port, () => {
  console.log(`OMNICOM Nebula backend listening on port ${config.port}`);
});
