#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed. Install Docker Engine and Docker Compose plugin first." >&2
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose plugin is unavailable. Install docker-compose-plugin." >&2
  exit 1
fi
if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl is required to generate deployment secrets." >&2
  exit 1
fi

if [[ -e .env ]]; then
  echo "Existing .env found; it will not be overwritten."
  exit 0
fi
cp .env.example .env
DB_SECRET="$(openssl rand -hex 24)"
JWT_SECRET="$(openssl rand -base64 48 | tr -d '\n')"
python3 - "$DB_SECRET" "$JWT_SECRET" <<'PY'
from pathlib import Path
import sys
p=Path('.env')
s=p.read_text().replace('CHANGE_ME_DATABASE_PASSWORD', sys.argv[1]).replace('CHANGE_ME_BASE64_32_BYTE_SECRET', sys.argv[2])
p.write_text(s)
PY
chmod 600 .env
echo "Created .env with generated secrets (permissions 600). Review optional SMTP/Groq settings before launching."
