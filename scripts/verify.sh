#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
printf '[1/5] Shell syntax\n'
for script in scripts/*.sh; do bash -n "$script"; done
printf '[2/5] Required deployment/docs files\n'
for file in .env.example docker-compose.yml backend/Dockerfile frontend/Dockerfile deploy/nginx.conf database/init.sql OSS_DOCUMENTATION.md SYSTEM_ADMINISTRATION.md; do
  [[ -f "$file" ]] || { echo "Missing: $file" >&2; exit 1; }
done
printf '[3/5] .env is ignored\n'
grep -qxF '.env' .gitignore && grep -qxF '.env.*' .gitignore || { echo '.env is not ignored' >&2; exit 1; }
printf '[4/5] Compose config (if Docker is available)\n'
if command -v docker >/dev/null && docker compose version >/dev/null 2>&1; then docker compose config --quiet; else echo 'Docker/Compose unavailable; skipped config validation.'; fi
printf '[5/5] Project checks complete\n'
command -v mvn >/dev/null || echo 'Maven not installed; backend build skipped.'
command -v node >/dev/null || echo 'Node not installed; frontend build skipped.'
