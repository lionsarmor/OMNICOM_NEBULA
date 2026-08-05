FROM node:20-slim

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY src ./src

ENV NODE_ENV=production
ENV PORT=4400
EXPOSE 4400

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s \
  CMD node -e "fetch('http://127.0.0.1:' + (process.env.PORT || 4400) + '/api/health').then((r)=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

CMD ["node", "src/index.js"]
