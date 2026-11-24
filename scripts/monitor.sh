#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

printf '\n=== Host resources ===\n'
command -v uptime >/dev/null && uptime || true
command -v free >/dev/null && free -h || true
command -v df >/dev/null && df -h "$ROOT" || true
printf '\n=== Compose service status ===\n'
docker compose ps
printf '\n=== Container resource usage ===\n'
docker stats --no-stream || true
printf '\n=== Published ports ===\n'
command -v ss >/dev/null && ss -tulpn || true
