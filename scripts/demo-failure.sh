#!/usr/bin/env bash
# Safe demo: temporarily stop/restart the backend container only.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
case "${1:-}" in
  stop-backend)
    echo 'Stopping backend for failure demo (frontend and database remain running)...'
    docker compose stop backend
    echo 'Backend stopped. Demo the client failure; restore with: scripts/demo-failure.sh recover'
    ;;
  recover)
    echo 'Starting backend again...'
    docker compose start backend
    docker compose logs --tail=30 backend
    ;;
  *)
    echo "Usage: $0 stop-backend | recover" >&2
    exit 2
    ;;
esac
