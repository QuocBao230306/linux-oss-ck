#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
[[ -f .env ]] || { echo 'Missing .env; run setup-ubuntu.sh first.' >&2; exit 1; }

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 backups/database-YYYYMMDD-HHMMSS.sql.gz" >&2
  exit 2
fi
BACKUP_FILE="$1"
[[ -f "$BACKUP_FILE" ]] || { echo "Backup file not found: $BACKUP_FILE" >&2; exit 1; }
[[ "$BACKUP_FILE" == *.sql.gz ]] || { echo 'Expected a .sql.gz database backup.' >&2; exit 1; }
if ! gzip -t "$BACKUP_FILE"; then echo 'Backup archive is corrupt.' >&2; exit 1; fi
printf 'WARNING: This will overwrite data in smart_messenger_db.\nBackup: %s\n' "$BACKUP_FILE"
read -r -p 'Type RESTORE to continue: ' CONFIRM
[[ "$CONFIRM" == RESTORE ]] || { echo 'Restore cancelled.'; exit 0; }
docker compose ps --status running --services | grep -qx mysql || { echo 'MySQL is not running.' >&2; exit 1; }
set -a; source .env; set +a
gunzip -c "$BACKUP_FILE" | docker compose exec -T mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" smart_messenger_db'
echo 'Database restore completed.'
