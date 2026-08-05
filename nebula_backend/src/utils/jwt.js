import jwt from "jsonwebtoken";
import { config } from "../config.js";

export const signToken = (payload) => {
  return jwt.sign(payload, config.jwtSecret, {
    expiresIn: config.jwtExpires,
  });
};
