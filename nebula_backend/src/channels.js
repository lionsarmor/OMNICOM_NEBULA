import { db } from "./db.js";
export async function listChannels(req, res) {
  const result = await db.query("SELECT * FROM channels ORDER BY id");
  res.send(result.rows);
}
export async function createChannel(req, res) {
  const { name, topic } = req.body;
  const result = await db.query("INSERT INTO channels (name, topic) VALUES ($1,$2) RETURNING *", [name, topic]);
  res.send(result.rows[0]);
}
