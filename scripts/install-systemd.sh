#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UNIT="/etc/systemd/system/smart-messenger.service"
cat > "$UNIT" <<UNITFILE
[Unit]
Description=Smart Messenger Docker Compose Stack
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$ROOT
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose stop
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
UNITFILE
systemctl daemon-reload
systemctl enable smart-messenger.service
systemctl start smart-messenger.service
systemctl status smart-messenger.service --no-pager
