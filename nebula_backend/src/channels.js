import { db } from "./db.js";

export async function listChannels(req, res) {
  try {
    const result = await db.query(
      "SELECT id, name, topic, created_at FROM channels ORDER BY name"
    );
    res.json(result.rows);
  } catch (error) {
    console.error("List channels error:", error);
    res.status(500).json({ error: "Server error" });
  }
}

export async function createChannel(req, res) {
  try {
    const name = String(req.body.name || "").trim().slice(0, 80);
    const topic = String(req.body.topic || "").trim().slice(0, 240);

    if (!name) return res.status(400).json({ error: "Channel name required" });

    const result = await db.query(
      `INSERT INTO channels (name, topic)
       VALUES ($1, $2)
       ON CONFLICT (name) DO UPDATE SET topic = EXCLUDED.topic
       RETURNING id, name, topic, created_at`,
      [name, topic || null]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error("Create channel error:", error);
    res.status(500).json({ error: "Server error" });
  }
}
