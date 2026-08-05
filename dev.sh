#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required to run Nebula." >&2
  exit 1
fi

docker compose version >/dev/null
docker compose up --build
