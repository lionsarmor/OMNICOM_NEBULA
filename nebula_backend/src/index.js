import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import { createServer } from "http";
import { Server } from "socket.io";

import authRoutes from "./routes/auth.js";
import { attachWS } from "./ws.js"; // ✅ FIXED: removed bad import

dotenv.config();

const app = express();
const server = createServer(app);

const io = new Server(server, {
  cors: {
    origin: process.env.CORS_ORIGIN?.split(",") || ["*"],
    methods: ["GET", "POST"],
  },
});

// --- Middleware ---
app.use(express.json());
app.use(
  cors({
    origin: process.env.CORS_ORIGIN?.split(",") || ["*"],
    credentials: true,
  })
);

// --- Health Check ---
app.get("/api/health", (req, res) => res.json({ ok: true }));

// --- Auth Routes ---
app.use("/api", authRoutes);

// --- Attach WebSocket Handlers ---
attachWS(io); // Handles both chat + Watch Party sync

const PORT = process.env.PORT || 4400;
server.listen(PORT, () => {
  console.log(`🚀 OMNICOM backend running on port ${PORT}`);
});
