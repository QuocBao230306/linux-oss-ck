#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CRON_FILE="/etc/cron.d/smart-messenger-backup"
if ! command -v cron >/dev/null 2>&1 && ! command -v crontab >/dev/null 2>&1; then
  echo 'Cron is not installed. Install it with: sudo apt install cron' >&2
  exit 1
fi
cat > "$CRON_FILE" <<CRON
# Daily Smart Messenger backup at 02:00 (project owner should review this schedule)
0 2 * * * root $ROOT/scripts/backup.sh >> $ROOT/backups/backup-cron.log 2>&1
CRON
chmod 644 "$CRON_FILE"
systemctl enable --now cron 2>/dev/null || true
echo "Installed daily backup schedule: $CRON_FILE"
