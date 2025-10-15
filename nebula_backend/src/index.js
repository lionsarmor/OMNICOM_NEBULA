import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import authRoutes from "./routes/auth.js";

dotenv.config();
const app = express();

app.use(express.json());
app.use(cors({ origin: process.env.CORS_ORIGIN || "*", credentials: true }));

// Health check
app.get("/api/health", (req, res) => res.json({ ok: true }));

// Auth endpoints
app.use("/api", authRoutes);

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`🚀 OMNICOM backend running on port ${PORT}`);
});
