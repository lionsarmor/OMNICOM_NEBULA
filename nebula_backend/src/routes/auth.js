import express from "express";
import jwt from "jsonwebtoken";
import pool from "../db.js";

// Try to load bcrypt; fall back to bcryptjs if native build fails
let bcrypt;
try {
  bcrypt = await import("bcrypt");
} catch {
  console.warn("⚠️  bcrypt native module not found, falling back to bcryptjs");
  bcrypt = await import("bcryptjs");
}

const router = express.Router();

const JWT_SECRET = process.env.JWT_SECRET || "dev_secret";
const JWT_EXPIRES = process.env.JWT_EXPIRES || "2h";

// === UTIL ===
function signToken(payload) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES });
}

// === MIDDLEWARE ===
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

// === REGISTER ===
router.post("/register", async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password)
      return res.status(400).json({ error: "Username and password required" });

    const hash = await bcrypt.hash(password, 10);

    const { rows } = await pool.query(
      `INSERT INTO users (username, password)
       VALUES ($1, $2)
       ON CONFLICT (username) DO NOTHING
       RETURNING id, username`,
      [username, hash]
    );

    if (!rows.length)
      return res.status(409).json({ error: "Username already exists" });

    return res.json({ ok: true, user: rows[0] });
  } catch (e) {
    console.error("❌ Register error:", e);
    return res.status(500).json({ error: "Server error" });
  }
});

// === LOGIN ===
router.post("/login", async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password)
      return res.status(400).json({ error: "Username and password required" });

    const { rows } = await pool.query(
      "SELECT id, username, password FROM users WHERE username = $1",
      [username]
    );

    const user = rows[0];
    if (!user) return res.status(401).json({ error: "Invalid credentials" });

    const ok = await bcrypt.compare(password, user.password);
    if (!ok) return res.status(401).json({ error: "Invalid credentials" });

    const token = signToken({ id: user.id, username: user.username });
    return res.json({ token });
  } catch (e) {
    console.error("❌ Login error:", e);
    return res.status(500).json({ error: "Server error" });
  }
});

// === PROFILE (manual decode) ===
router.get("/profile", (req, res) => {
  const auth = req.headers.authorization;
  if (!auth) return res.status(401).json({ error: "No token" });

  try {
    const token = auth.split(" ")[1];
    const decoded = jwt.verify(token, JWT_SECRET);
    return res.json({ id: decoded.id, username: decoded.username });
  } catch {
    return res.status(401).json({ error: "Invalid token" });
  }
});

// === ME (middleware verified) ===
router.get("/me", verifyToken, (req, res) => {
  return res.json({ user: req.user });
});

export default router;
