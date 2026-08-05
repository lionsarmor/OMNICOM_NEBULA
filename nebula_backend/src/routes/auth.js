import express from "express";
import jwt from "jsonwebtoken";
import pool from "../db.js";
import { config } from "../config.js";

// Try to load bcrypt; fall back to bcryptjs if native build fails
let bcrypt;
try {
  bcrypt = await import("bcrypt");
} catch {
  console.warn("bcrypt native module not found, falling back to bcryptjs");
  bcrypt = await import("bcryptjs");
}

const router = express.Router();

const JWT_SECRET = config.jwtSecret;
const JWT_EXPIRES = config.jwtExpires;
const USE_MEMORY_AUTH = process.env.AUTH_STORE === "memory";
const memoryUsers = new Map();
let nextMemoryUserId = 1;

function signToken(payload) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES });
}

function cleanUsername(username) {
  return String(username || "").trim().slice(0, 100);
}

async function createUser(username, passwordHash) {
  if (USE_MEMORY_AUTH) {
    if (memoryUsers.has(username)) return null;

    const user = { id: nextMemoryUserId++, username, password: passwordHash };
    memoryUsers.set(username, user);
    return { id: user.id, username: user.username };
  }

  const { rows } = await pool.query(
    `INSERT INTO users (username, password)
     VALUES ($1, $2)
     ON CONFLICT (username) DO NOTHING
     RETURNING id, username`,
    [username, passwordHash]
  );

  return rows[0] || null;
}

async function findUser(username) {
  if (USE_MEMORY_AUTH) return memoryUsers.get(username) || null;

  const { rows } = await pool.query(
    "SELECT id, username, password FROM users WHERE username = $1",
    [username]
  );

  return rows[0] || null;
}

export function verifyToken(req, res, next) {
  const auth = req.headers.authorization || "";
  const token = auth.startsWith("Bearer ") ? auth.slice(7) : null;
  if (!token) return res.status(401).json({ error: "Missing token" });

  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch {
    return res.status(401).json({ error: "Invalid token" });
  }
}

router.post("/register", async (req, res) => {
  try {
    const username = cleanUsername(req.body.username);
    const password = String(req.body.password || "");
    if (!username || !password) {
      return res.status(400).json({ error: "Username and password required" });
    }
    if (password.length < 8) {
      return res.status(400).json({ error: "Password must be at least 8 characters" });
    }

    const hash = await bcrypt.hash(password, 10);
    const user = await createUser(username, hash);

    if (!user) return res.status(409).json({ error: "Username already exists" });

    return res.json({ ok: true, user });
  } catch (e) {
    console.error("Register error:", e);
    return res.status(500).json({ error: "Server error" });
  }
});

router.post("/login", async (req, res) => {
  try {
    const username = cleanUsername(req.body.username);
    const password = String(req.body.password || "");
    if (!username || !password) {
      return res.status(400).json({ error: "Username and password required" });
    }

    const user = await findUser(username);
    if (!user) return res.status(401).json({ error: "Invalid credentials" });

    const ok = await bcrypt.compare(password, user.password);
    if (!ok) return res.status(401).json({ error: "Invalid credentials" });

    const token = signToken({ id: user.id, username: user.username });
    return res.json({ token, user: { id: user.id, username: user.username } });
  } catch (e) {
    console.error("Login error:", e);
    return res.status(500).json({ error: "Server error" });
  }
});

router.get("/profile", verifyToken, (req, res) => {
  return res.json({ id: req.user.id, username: req.user.username });
});

router.get("/me", verifyToken, (req, res) => {
  return res.json({ user: req.user });
});

export default router;
