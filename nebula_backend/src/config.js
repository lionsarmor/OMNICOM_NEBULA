import dotenv from "dotenv";

dotenv.config();

const isProduction = process.env.NODE_ENV === "production";
const devJwtSecret = "dev-only-nebula-secret-change-me";

function requireEnv(name) {
  const value = process.env[name];
  if (!value) throw new Error(`Missing required environment variable: ${name}`);
  return value;
}

function parseOrigins(value) {
  if (!value) return ["http://localhost:5173", "http://127.0.0.1:5173"];
  if (value.trim() === "*") return "*";
  return value
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean);
}

const jwtSecret = process.env.JWT_SECRET || (isProduction ? requireEnv("JWT_SECRET") : devJwtSecret);

if (isProduction && jwtSecret === devJwtSecret) {
  throw new Error("JWT_SECRET must be set to a strong value in production.");
}

export const config = {
  nodeEnv: process.env.NODE_ENV || "development",
  port: Number(process.env.PORT || 4400),
  databaseUrl: process.env.DATABASE_URL || "",
  jwtSecret,
  jwtExpires: process.env.JWT_EXPIRES || "2h",
  corsOrigins: parseOrigins(process.env.CORS_ORIGIN),
};
