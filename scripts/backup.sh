#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
[[ -f .env ]] || { echo 'Missing .env. Run scripts/setup-ubuntu.sh first.' >&2; exit 1; }
mkdir -p backups
STAMP="$(date +%Y%m%d-%H%M%S)"
set -a; source .env; set +a
if ! docker compose ps --status running --services | grep -qx mysql; then
  echo 'MySQL service is not running. Start the stack before backup.' >&2; exit 1
fi
DB_OUT="backups/database-${STAMP}.sql.gz"
UPLOAD_OUT="backups/uploads-${STAMP}.tar.gz"
docker compose exec -T mysql sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --single-transaction --routines --triggers smart_messenger_db' | gzip -c > "$DB_OUT"
BACKEND="$(docker compose ps -q backend)"
[[ -n "$BACKEND" ]] || { echo 'Backend container not found.' >&2; exit 1; }
docker exec "$BACKEND" sh -c 'cd /app && tar -czf - uploads' > "$UPLOAD_OUT"
gzip -t "$DB_OUT"
tar -tzf "$UPLOAD_OUT" >/dev/null
sha256sum "$DB_OUT" "$UPLOAD_OUT" > "backups/checksum-${STAMP}.sha256"
# Keep the latest 14 days of backup files.
find backups -type f -mtime +14 -name 'database-*.sql.gz' -delete
find backups -type f -mtime +14 -name 'uploads-*.tar.gz' -delete
find backups -type f -mtime +14 -name 'checksum-*.sha256' -delete
printf 'Backup verified:\n  %s\n  %s\n' "$DB_OUT" "$UPLOAD_OUT"
