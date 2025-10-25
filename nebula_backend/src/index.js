import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import { createServer } from "http";
import { Server } from "socket.io";

import authRoutes from "./routes/auth.js";
import { attachWS, attachWatchParty } from "./ws.js";

dotenv.config();

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.CORS_ORIGIN || "*",
    methods: ["GET", "POST"]
  }
});

app.use(express.json());
app.use(cors({ origin: process.env.CORS_ORIGIN || "*", credentials: true }));

// Health check
app.get("/api/health", (req, res) => res.json({ ok: true }));

// Auth endpoints
app.use("/api", authRoutes);

// --- WebSockets ---
attachWS(io);          // existing chat system
attachWatchParty(io);  // 🎬 watch party sync namespace

const PORT = process.env.PORT || 4000;
server.listen(PORT, () => {
  console.log(`🚀 OMNICOM backend running on port ${PORT}`);
});
