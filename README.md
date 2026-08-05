# OMNICOM Nebula

Usable boilerplate for a Flutter web client, Node/Express API, Socket.IO relay, and PostgreSQL database.

## Run

```bash
./dev.sh
```

Open:

- Frontend: http://localhost:5173
- Backend health: http://localhost:4400/api/health
- Postgres: localhost:5432

The first run builds the Flutter web app in Docker, so it can take a few minutes.

## Local Overrides

Copy `.env.example` to `.env` if you need to change ports, database credentials, CORS origins, or the JWT secret.

```bash
cp .env.example .env
```

For normal local development, the defaults in `docker-compose.yml` are enough.

## Useful Commands

```bash
docker compose ps
docker compose logs -f nebula-backend
docker compose down
docker compose down -v
```

Use `docker compose down -v` only when you want to delete the local Postgres data volume.
