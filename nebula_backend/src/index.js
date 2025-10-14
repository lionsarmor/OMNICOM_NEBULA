import express from "express";
import cors from "cors";
import { createServer } from "http";
import { Server } from "socket.io";
import { register, login, verifyToken } from "./auth.js";
import { listChannels, createChannel } from "./channels.js";
import { listMessages, createMessage } from "./messages.js";
import { attachWS } from "./ws.js";
import dotenv from "dotenv";
dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());
app.post("/api/register", register);
app.post("/api/login", login);
app.get("/api/channels", listChannels);
app.post("/api/channels", verifyToken, createChannel);
app.get("/api/channels/:id/messages", verifyToken, listMessages);
app.post("/api/message", verifyToken, createMessage);

const httpServer = createServer(app);
const io = new Server(httpServer, { cors: { origin: "*" } });
attachWS(io);

httpServer.listen(process.env.PORT, () => console.log("OmniCom backend running on", process.env.PORT));
