import { db } from "./db.js";
export async function listMessages(req, res) {
  const id = req.params.id;
  const result = await db.query(
    "SELECT m.id, u.username, m.message, m.created_at FROM messages m JOIN users u ON u.id=m.user_id WHERE channel_id=$1 ORDER BY m.id DESC LIMIT 50",
    [id]
  );
  res.send(result.rows);
}
export async function createMessage(req, res) {
  const { channelId, message } = req.body;
  const userId = req.user.id;
  const result = await db.query(
    "INSERT INTO messages (user_id, channel_id, message) VALUES ($1,$2,$3) RETURNING *",
    [userId, channelId, message]
  );
  res.send({ ok: true, id: result.rows[0].id });
}
