#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 backups/uploads-YYYYMMDD-HHMMSS.tar.gz" >&2
  exit 2
fi
FILE="$1"
[[ -f "$FILE" ]] || { echo "Backup file not found: $FILE" >&2; exit 1; }
tar -tzf "$FILE" >/dev/null || { echo 'Archive is invalid.' >&2; exit 1; }
BACKEND="$(docker compose ps -q backend)"
[[ -n "$BACKEND" ]] || { echo 'Backend container not found; start the stack first.' >&2; exit 1; }
printf 'WARNING: Upload restore overwrites files in backend uploads.\nArchive: %s\n' "$FILE"
read -r -p 'Type RESTORE to continue: ' CONFIRM
[[ "$CONFIRM" == RESTORE ]] || { echo 'Restore cancelled.'; exit 0; }
docker exec "$BACKEND" sh -c 'cd /app && tar -czf - uploads' > "backups/uploads-before-restore-$(date +%Y%m%d-%H%M%S).tar.gz"
docker exec -i "$BACKEND" sh -c 'cd /app && tar -xzf -' < "$FILE"
echo 'Uploads restore completed. A pre-restore copy was created in backups/.'
