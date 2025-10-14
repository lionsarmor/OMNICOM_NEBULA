import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { db } from "./db.js";
import dotenv from "dotenv";
dotenv.config();

export async function register(req, res) {
  const { username, password } = req.body;
  try {
    const hash = await bcrypt.hash(password, 10);
    await db.query(
      "INSERT INTO users (username, password_hash) VALUES ($1,$2)",
      [username, hash]
    );
    res.send({ ok: true });
  } catch (err) {
    if (err.code === "23505") {
      return res.status(400).send({ error: "Username already exists" });
    }
    console.error(err);
    res.status(500).send({ error: "Internal server error" });
  }
}


export async function login(req, res) {
  const { username, password } = req.body;
  const result = await db.query("SELECT * FROM users WHERE username=$1", [username]);
  if (!result.rows.length) return res.status(401).send({ error: "Invalid" });
  const user = result.rows[0];
  const match = await bcrypt.compare(password, user.password_hash);
  if (!match) return res.status(401).send({ error: "Invalid" });
  const token = jwt.sign({ id: user.id, username }, process.env.JWT_SECRET);
  res.send({ token });
}

export function verifyToken(req, res, next) {
  const header = req.headers.authorization;
  if (!header) return res.status(401).send({ error: "No token" });
  try {
    req.user = jwt.verify(header.split(" ")[1], process.env.JWT_SECRET);
    next();
  } catch {
    res.status(401).send({ error: "Invalid token" });
  }
}
