import { db } from "./db.js";

export async function listMessages(req, res) {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id)) return res.status(400).json({ error: "Invalid channel id" });

    const result = await db.query(
      `SELECT m.id, m.channel_id, u.username, m.message, m.created_at
       FROM messages m
       JOIN users u ON u.id = m.user_id
       WHERE m.channel_id = $1
       ORDER BY m.id DESC
       LIMIT 50`,
      [id]
    );
    res.json(result.rows.reverse());
  } catch (error) {
    console.error("List messages error:", error);
    res.status(500).json({ error: "Server error" });
  }
}

export async function createMessage(req, res) {
  try {
    const channelId = Number(req.body.channelId ?? req.body.channel_id);
    const message = String(req.body.message ?? req.body.body ?? "").trim().slice(0, 2000);
    const userId = req.user.id;

    if (!Number.isInteger(channelId)) {
      return res.status(400).json({ error: "Invalid channel id" });
    }
    if (!message) return res.status(400).json({ error: "Message required" });

    const channel = await db.query("SELECT id FROM channels WHERE id = $1", [channelId]);
    if (channel.rowCount === 0) {
      return res.status(404).json({ error: "Channel not found" });
    }

    const result = await db.query(
      `INSERT INTO messages (user_id, channel_id, message)
       VALUES ($1, $2, $3)
       RETURNING id, channel_id, message, created_at`,
      [userId, channelId, message]
    );
    res.status(201).json({ ok: true, message: result.rows[0] });
  } catch (error) {
    console.error("Create message error:", error);
    res.status(500).json({ error: "Server error" });
  }
}
