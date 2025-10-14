# === OmniCom Backend Dockerfile ===
FROM node:20-slim

# Set working directory
WORKDIR /app

# Copy package files and install deps
COPY package*.json ./
RUN npm install --omit=dev

# Copy source code
COPY . .

# Expose API port
EXPOSE 4000

# Start app
CMD ["node", "src/index.js"]
